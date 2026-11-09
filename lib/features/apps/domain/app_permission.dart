import 'package:flutter/foundation.dart';

/// How Android guards a permission, which decides whether the user can change it.
enum PermissionKind {
  /// Runtime permission (camera, location, contacts…): the user allows or denies it.
  dangerous,

  /// Special access (draw over apps, all files…): switched in its own Settings page.
  special,

  /// Granted at install; the user cannot change it.
  normal,

  /// Only for apps signed by the same developer or the system.
  signature,

  /// Declared by an app that is not installed, or unknown to this Android version.
  unknown
  ;

  /// Dangerous and special permissions are the ones a user can switch.
  bool get isUserAdjustable => this == dangerous || this == special;

  static PermissionKind parse(String? raw) =>
      values.firstWhere((k) => k.name == raw, orElse: () => unknown);
}

/// One permission an app asks for.
@immutable
final class AppPermission {
  const AppPermission({
    required this.name,
    required this.kind,
    required this.isGranted,
    this.label,
    this.description,
  });

  /// e.g. `android.permission.CAMERA`.
  final String name;
  final PermissionKind kind;
  final bool isGranted;

  /// The system's own label (`take pictures and videos`), when it has one.
  final String? label;
  final String? description;

  /// A readable title: the system label, else the name turned into words.
  String get displayName {
    final systemLabel = label?.trim();
    if (systemLabel != null && systemLabel.isNotEmpty && systemLabel != name) {
      return systemLabel[0].toUpperCase() + systemLabel.substring(1);
    }
    final words = name.split('.').last.toLowerCase().split('_').where((w) => w.isNotEmpty);
    final text = words.join(' ');
    return text.isEmpty ? name : text[0].toUpperCase() + text.substring(1);
  }

  @override
  bool operator ==(Object other) =>
      other is AppPermission &&
      other.name == name &&
      other.kind == kind &&
      other.isGranted == isGranted &&
      other.label == label &&
      other.description == description;

  @override
  int get hashCode => Object.hash(name, kind, isGranted, label, description);
}

/// An app's permissions sorted into what the user can change and what they cannot.
@immutable
final class PermissionGroups {
  const PermissionGroups({
    required this.allowed,
    required this.denied,
    required this.special,
    required this.fixed,
  });

  /// Splits [permissions]; each list is sorted by [AppPermission.displayName].
  factory PermissionGroups.of(List<AppPermission> permissions) {
    List<AppPermission> pick(bool Function(AppPermission p) test) =>
        List.unmodifiable(permissions.where(test).toList()..sort(_byName));
    return PermissionGroups(
      allowed: pick((p) => p.kind == PermissionKind.dangerous && p.isGranted),
      denied: pick((p) => p.kind == PermissionKind.dangerous && !p.isGranted),
      special: pick((p) => p.kind == PermissionKind.special),
      fixed: pick((p) => !p.kind.isUserAdjustable),
    );
  }

  final List<AppPermission> allowed;
  final List<AppPermission> denied;
  final List<AppPermission> special;
  final List<AppPermission> fixed;

  bool get isEmpty => allowed.isEmpty && denied.isEmpty && special.isEmpty && fixed.isEmpty;

  static int _byName(AppPermission a, AppPermission b) =>
      a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
}
