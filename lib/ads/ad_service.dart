import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ads: a banner under the app list, and one interstitial at a natural break (after a batch
/// uninstall finishes). Never on the app detail screen or over a system dialog.
abstract interface class AdService {
  /// Asks for consent where required, then starts the ad SDK.
  Future<void> start();

  /// A banner for the bottom of the app list; empty when no ad is ready.
  Widget banner();

  /// Shows the full-screen ad at a break, if the frequency cap allows.
  Future<void> showBreakInterstitial();

  /// True where the law requires a way to change ad consent (EEA, UK).
  Future<bool> privacyChoicesRequired();

  /// Opens the consent form so the user can change their choices.
  Future<void> showPrivacyChoices();
}

/// Used in tests and whenever ads are not wired in.
class NoAdService implements AdService {
  const NoAdService();

  @override
  Future<void> start() async {}

  @override
  Widget banner() => const SizedBox.shrink();

  @override
  Future<void> showBreakInterstitial() async {}

  @override
  Future<bool> privacyChoicesRequired() async => false;

  @override
  Future<void> showPrivacyChoices() async {}
}

final Provider<AdService> adServiceProvider = Provider<AdService>(
  (ref) => const NoAdService(),
);

/// Whether the menu should offer "Privacy choices".
final FutureProvider<bool> privacyChoicesRequiredProvider = FutureProvider<bool>(
  (ref) => ref.watch(adServiceProvider).privacyChoicesRequired(),
);
