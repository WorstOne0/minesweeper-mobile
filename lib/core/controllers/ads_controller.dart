// Dart
import 'dart:async';

// Flutter packages
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Repositories
import '/core/repositories/settings_repository.dart';

/// An interstitial every [gamesPerAd] new games; the state is the count since the last one.
/// Debug builds use the Google test unit, as AdMob policy requires.
class AdsController extends Notifier<int> {
  static const gamesPerAd = 3;
  static const adUnitId = kDebugMode
      ? "ca-app-pub-3940256099942544/1033173712"
      : "ca-app-pub-8266409518147572/2414888963";

  late final SettingsRepository repository;
  InterstitialAd? ready;

  @override
  int build() {
    repository = ref.watch(settingsRepositoryProvider);
    return repository.gamesSinceAd;
  }

  /// Counts a new game; on the [gamesPerAd]th, shows the ad and only answers once it is closed.
  /// The ad is loaded one game early so the show is instant, and skipped when it is not there.
  Future<void> countGame() async {
    state = state + 1;
    await repository.saveGamesSinceAd(state);

    if (state == gamesPerAd - 1) load().then((ad) => ready = ad);
    if (state < gamesPerAd) return;

    state = 0;
    await repository.saveGamesSinceAd(0);

    final ad = ready ?? await load();
    ready = null;
    if (ad == null) return;

    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        closed.complete();
      },
    );
    await ad.show();
    await closed.future;
  }

  Future<InterstitialAd?> load() {
    final loaded = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (error) => loaded.complete(null),
      ),
    );

    return loaded.future.timeout(const Duration(seconds: 3), onTimeout: () => null);
  }
}

final adsProvider = NotifierProvider<AdsController, int>(AdsController.new);
