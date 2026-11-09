package com.homilabs.appmanager

import android.app.Activity
import android.app.AppOpsManager
import android.app.usage.StorageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.PermissionInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.os.UserHandle
import android.os.storage.StorageManager
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * The one native seam of the app (channel `com.homilabs.appmanager/apps`).
 *
 * Android lets a normal app read the app list, sizes and permissions, and open the system
 * uninstall dialog. It does not let it clear another app's cache or change its permissions:
 * for those, [openAppSettings] opens that app's system page.
 */
class AppManagerChannel(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, CHANNEL)
    private val worker: ExecutorService = Executors.newFixedThreadPool(2)
    private val main = Handler(Looper.getMainLooper())
    private val pm: PackageManager get() = activity.packageManager
    private var pendingUninstall: Pair<String, MethodChannel.Result>? = null

    init {
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        worker.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            dispatch(call, result)
        } catch (e: IllegalArgumentException) {
            result.error("bad_args", e.message, null)
        }
    }

    private fun dispatch(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "listApps" -> background(result) { listApps() }
            "getIcon" -> background(result) { icon(call.pkg(), call.argument<Int>("sizePx") ?: 96) }
            "getSizes" -> background(result) { sizes() }
            "getPermissions" -> background(result) { permissions(call.pkg()) }
            "hasUsageAccess" -> result.success(hasUsageAccess())
            "openUsageAccessSettings" -> result.success(
                start(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)),
            )
            "openAppSettings" -> result.success(
                start(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, packageUri(call.pkg()))),
            )
            "launchApp" -> result.success(
                pm.getLaunchIntentForPackage(call.pkg())?.let { start(it) } ?: false,
            )
            "uninstall" -> uninstall(call.pkg(), result)
            "isInstalled" -> result.success(isInstalled(call.pkg()))
            else -> result.notImplemented()
        }
    }

    /** Called by [MainActivity]; true when the request was ours. */
    fun onActivityResult(requestCode: Int): Boolean {
        if (requestCode != REQUEST_UNINSTALL) return false
        val (pkg, result) = pendingUninstall ?: return true
        pendingUninstall = null
        result.success(!isInstalled(pkg))
        return true
    }

    private fun listApps(): List<Map<String, Any?>> {
        val own = activity.packageName
        return installedPackages(PackageManager.GET_META_DATA)
            .filter { it.packageName != own && it.applicationInfo != null }
            .map { info ->
                val app = info.applicationInfo!!
                mapOf(
                    "packageName" to info.packageName,
                    "label" to app.loadLabel(pm).toString(),
                    "versionName" to (info.versionName ?: ""),
                    "versionCode" to info.longVersionCode,
                    "isSystem" to (app.flags and ApplicationInfo.FLAG_SYSTEM != 0),
                    "isUpdatedSystem" to (app.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP != 0),
                    "isEnabled" to app.enabled,
                    "hasLauncher" to (pm.getLaunchIntentForPackage(info.packageName) != null),
                    "firstInstallMillis" to info.firstInstallTime,
                    "lastUpdateMillis" to info.lastUpdateTime,
                    "targetSdk" to app.targetSdkVersion,
                    "minSdk" to app.minSdkVersion,
                    "installer" to installer(info.packageName),
                )
            }
    }

    private fun icon(pkg: String, sizePx: Int): ByteArray? {
        val drawable = try {
            pm.getApplicationIcon(pkg)
        } catch (e: PackageManager.NameNotFoundException) {
            return null
        }
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, sizePx, sizePx)
        drawable.draw(canvas)
        val out = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        bitmap.recycle()
        return out.toByteArray()
    }

    /** Sizes for every package, or null without usage access. Keys: app, data, cache (bytes). */
    private fun sizes(): Map<String, Map<String, Long>>? {
        if (!hasUsageAccess()) return null
        val stats = activity.getSystemService(StorageStatsManager::class.java)
        val user: UserHandle = Process.myUserHandle()
        val out = HashMap<String, Map<String, Long>>()
        for (info in installedPackages(0)) {
            try {
                val s = stats.queryStatsForPackage(StorageManager.UUID_DEFAULT, info.packageName, user)
                out[info.packageName] = mapOf(
                    "app" to s.appBytes,
                    "data" to s.dataBytes,
                    "cache" to s.cacheBytes,
                )
            } catch (e: Exception) {
                // App on removable storage or gone since the list was read: no size for it.
            }
        }
        return out
    }

    private fun permissions(pkg: String): List<Map<String, Any?>> {
        val info = try {
            packageInfo(pkg, PackageManager.GET_PERMISSIONS)
        } catch (e: PackageManager.NameNotFoundException) {
            return emptyList()
        }
        val names = info.requestedPermissions ?: return emptyList()
        val flags = info.requestedPermissionsFlags ?: IntArray(names.size)
        return names.mapIndexed { i, name ->
            val perm = try {
                pm.getPermissionInfo(name, 0)
            } catch (e: PackageManager.NameNotFoundException) {
                null
            }
            mapOf(
                "name" to name,
                "label" to perm?.loadLabel(pm)?.toString(),
                "description" to perm?.loadDescription(pm)?.toString(),
                "protection" to protection(perm),
                "granted" to (flags[i] and PackageInfo.REQUESTED_PERMISSION_GRANTED != 0),
            )
        }
    }

    private fun protection(perm: PermissionInfo?): String {
        if (perm == null) return "unknown"
        val base = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            perm.protection
        } else {
            @Suppress("DEPRECATION")
            perm.protectionLevel and PermissionInfo.PROTECTION_MASK_BASE
        }
        val appop = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            perm.protectionFlags and PermissionInfo.PROTECTION_FLAG_APPOP != 0
        } else {
            @Suppress("DEPRECATION")
            perm.protectionLevel and PermissionInfo.PROTECTION_FLAG_APPOP != 0
        }
        return when {
            base == PermissionInfo.PROTECTION_DANGEROUS -> "dangerous"
            appop -> "special"
            base == PermissionInfo.PROTECTION_SIGNATURE -> "signature"
            else -> "normal"
        }
    }

    private fun uninstall(pkg: String, result: MethodChannel.Result) {
        if (pendingUninstall != null) {
            result.error("busy", "Another uninstall is waiting for the user", null)
            return
        }
        @Suppress("DEPRECATION")
        val intent = Intent(Intent.ACTION_UNINSTALL_PACKAGE, packageUri(pkg))
            .putExtra(Intent.EXTRA_RETURN_RESULT, true)
        pendingUninstall = pkg to result
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, REQUEST_UNINSTALL)
        } catch (e: Exception) {
            pendingUninstall = null
            result.error("cannot_start", e.message, null)
        }
    }

    private fun hasUsageAccess(): Boolean {
        val ops = activity.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ops.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), activity.packageName)
        } else {
            @Suppress("DEPRECATION")
            ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), activity.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun isInstalled(pkg: String): Boolean = try {
        packageInfo(pkg, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    private fun installer(pkg: String): String? = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            pm.getInstallSourceInfo(pkg).installingPackageName
        } else {
            @Suppress("DEPRECATION")
            pm.getInstallerPackageName(pkg)
        }
    } catch (e: Exception) {
        null
    }

    private fun installedPackages(flags: Int): List<PackageInfo> =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(flags.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(flags)
        }

    private fun packageInfo(pkg: String, flags: Int): PackageInfo =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getPackageInfo(pkg, PackageManager.PackageInfoFlags.of(flags.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(pkg, flags)
        }

    private fun start(intent: Intent): Boolean = try {
        activity.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        true
    } catch (e: Exception) {
        false
    }

    private fun packageUri(pkg: String): Uri = Uri.fromParts("package", pkg, null)

    private fun MethodCall.pkg(): String = argument<String>("packageName")
        ?: throw IllegalArgumentException("packageName is required")

    /** Runs [work] off the main thread and replies on it. */
    private fun background(result: MethodChannel.Result, work: () -> Any?) {
        worker.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("native_error", e.message, null) }
            }
        }
    }

    private companion object {
        const val CHANNEL = "com.homilabs.appmanager/apps"
        const val REQUEST_UNINSTALL = 4201
    }
}
