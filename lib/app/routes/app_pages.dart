import 'package:get/get.dart';

import '../modules/compare/bindings/compare_binding.dart';
import '../modules/compare/views/compare_view.dart';
import '../modules/family_vote/bindings/vote_bindings.dart';
import '../modules/family_vote/views/vote_views.dart';
import '../modules/full_name/bindings/full_name_binding.dart';
import '../modules/full_name/views/full_name_view.dart';
import '../modules/match/bindings/match_binding.dart';
import '../modules/match/views/match_view.dart';
import '../modules/matches/bindings/matches_binding.dart';
import '../modules/matches/views/matches_view.dart';
import '../modules/name_detail/bindings/name_detail_binding.dart';
import '../modules/name_detail/views/name_detail_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/premium/bindings/premium_binding.dart';
import '../modules/premium/views/premium_view.dart';
import '../modules/partner/bindings/partner_binding.dart';
import '../modules/partner/views/partner_view.dart';
import '../modules/reveal_video/bindings/reveal_video_binding.dart';
import '../modules/reveal_video/views/reveal_video_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/share_card/bindings/share_card_binding.dart';
import '../modules/share_card/views/share_card_view.dart';
import '../modules/shell/bindings/shell_binding.dart';
import '../modules/shell/views/shell_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_nav.dart';

part 'app_routes.dart';

abstract final class AppPages {
  static const String initial = Routes.splash;

  static final List<GetPage<dynamic>> routes = [
    GetPage<void>(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: _Paths.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: _Paths.shell,
      page: () => const ShellView(),
      binding: ShellBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage<void>(
      name: _Paths.nameDetail,
      page: () => NameDetailView(args: NameDetailArgs.current()),
      binding: NameDetailBinding(),
    ),
    GetPage<void>(
      name: _Paths.compare,
      page: () => const CompareView(),
      binding: CompareBinding(),
    ),
    GetPage<void>(
      name: _Paths.partner,
      page: () => const PartnerView(),
      binding: PartnerBinding(),
    ),
    GetPage<void>(
      name: _Paths.matches,
      page: () => const MatchesView(),
      binding: MatchesBinding(),
    ),
    GetPage<void>(
      name: _Paths.match,
      page: () => const MatchView(),
      binding: MatchBinding(),
      transition: Transition.zoom,
      fullscreenDialog: true,
    ),
    GetPage<void>(
      name: _Paths.fullName,
      page: () => const FullNameView(),
      binding: FullNameBinding(),
    ),
    GetPage<void>(
      name: _Paths.premium,
      page: () => const PremiumView(),
      binding: PremiumBinding(),
      fullscreenDialog: true,
    ),
    GetPage<void>(
      name: _Paths.shareCard,
      page: () => const ShareCardView(),
      binding: ShareCardBinding(),
    ),
    GetPage<void>(
      name: _Paths.revealVideo,
      page: () => const RevealVideoView(),
      binding: RevealVideoBinding(),
    ),
    GetPage<void>(
      name: _Paths.voteCreate,
      page: () => const VoteCreateView(),
      binding: VoteCreateBinding(),
    ),
    GetPage<void>(
      name: _Paths.voteResults,
      page: () => const VoteResultsView(),
      binding: VoteResultsBinding(),
    ),
    GetPage<void>(
      name: _Paths.votes,
      page: () => const VotesView(),
      binding: VotesBinding(),
    ),
  ];
}
