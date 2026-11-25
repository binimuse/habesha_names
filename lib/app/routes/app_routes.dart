part of 'app_pages.dart';

abstract final class Routes {
  static const String splash = _Paths.splash;
  static const String onboarding = _Paths.onboarding;
  static const String shell = _Paths.shell;
  static const String settings = _Paths.settings;
  static const String nameDetail = _Paths.nameDetail;
  static const String compare = _Paths.compare;
  static const String partner = _Paths.partner;
  static const String matches = _Paths.matches;
  static const String match = _Paths.match;
  static const String fullName = _Paths.fullName;
  static const String premium = _Paths.premium;
  static const String shareCard = _Paths.shareCard;
  static const String revealVideo = _Paths.revealVideo;
  static const String voteCreate = _Paths.voteCreate;
  static const String voteResults = _Paths.voteResults;
  static const String votes = _Paths.votes;
}

abstract final class _Paths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String shell = '/';
  static const String settings = '/settings';
  static const String nameDetail = '/name';
  static const String compare = '/compare';
  static const String partner = '/partner';
  static const String matches = '/matches';
  static const String match = '/match';
  static const String fullName = '/full-name';
  static const String premium = '/premium';
  static const String shareCard = '/share-card';
  static const String revealVideo = '/reveal-video';
  static const String voteCreate = '/vote/new';
  static const String voteResults = '/vote';
  static const String votes = '/votes';
}
