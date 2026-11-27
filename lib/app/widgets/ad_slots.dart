import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/extensions/context_x.dart';
import '../services/ads_service.dart';
import '../theme/app_dimens.dart';
import '../translations/locale_keys.dart';

bool _adsOn() =>
    Get.isRegistered<AdsService>() && Get.find<AdsService>().showAds;

/// Native-ad spacing for long lists: every 12 items, or 0 (no ad slots at
/// all) when ads are off or the user has Premium.
int nativeAdEvery() => _adsOn() ? 12 : 0;

/// Adaptive banner (Name detail). Collapses when ads are off or not loaded.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad != null || !_adsOn()) return;
    final int width = MediaQuery.sizeOf(context).width.truncate();
    AdSize.getLargeAnchoredAdaptiveBannerAdSize(width).then((s) {
      if (!mounted || s == null) return;
      _ad = BannerAd(
        adUnitId: AdUnits.banner,
        size: s,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) => setState(() => _loaded = true),
          onAdFailedToLoad: (ad, _) => ad.dispose(),
        ),
      )..load();
    });
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BannerAd? ad = _ad;
    if (!_loaded || ad == null || !_adsOn()) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

/// Native ad card for lists (template rendering, no platform code needed).
class NativeAdSlot extends StatefulWidget {
  const NativeAdSlot({super.key});

  @override
  State<NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends State<NativeAdSlot> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad != null || !_adsOn()) return;
    _ad = NativeAd(
      adUnitId: AdUnits.native,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: context.colors.surface,
        cornerRadius: AppRadius.card,
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NativeAd? ad = _ad;
    if (!_loaded || ad == null || !_adsOn()) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.adLabel.tr,
          style: Theme.of(
            context,
          ).textTheme.labelSmall!.copyWith(color: context.palette.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 90, maxHeight: 120),
            child: AdWidget(ad: ad),
          ),
        ),
      ],
    );
  }
}
