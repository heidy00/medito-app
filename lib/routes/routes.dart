import 'dart:async';

import 'package:Medito/models/models.dart';
import 'package:Medito/providers/providers.dart';
import 'package:Medito/views/home/home_view.dart';
import 'package:Medito/views/notifications/notification_permission_view.dart';
import 'package:Medito/views/search/search_view.dart';
import 'package:Medito/widgets/widgets.dart';
import 'package:Medito/constants/constants.dart';
import 'package:Medito/views/root/root_page_view.dart';
import 'package:Medito/utils/utils.dart';
import 'package:Medito/views/auth/join_email_view.dart';
import 'package:Medito/views/auth/join_intro_view.dart';
import 'package:Medito/views/auth/join_verify_OTP_view.dart';
import 'package:Medito/views/auth/join_welcome_view.dart';
import 'package:Medito/views/background_sound/background_sound_view.dart';
import 'package:Medito/views/downloads/downloads_view.dart';
import 'package:Medito/views/pack/pack_view.dart';
import 'package:Medito/views/player/player_view.dart';
import 'package:Medito/views/track/track_view.dart';
import 'package:Medito/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return router;
});
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();
final router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteConstants.root,
  routes: [
    GoRoute(
      path: RouteConstants.root,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: SplashView(),
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.joinIntroPath,
      pageBuilder: (context, state) {
        final params =
            state.extra != null ? state.extra as JoinRouteParamsModel : null;

        return MaterialPage(
          key: state.pageKey,
          child: JoinIntroView(fromScreen: params?.screen ?? Screen.splash),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.joinEmailPath,
      pageBuilder: (context, state) {
        final params =
            state.extra != null ? state.extra as JoinRouteParamsModel : null;

        return MaterialPage(
          key: state.pageKey,
          child: JoinEmailView(fromScreen: params?.screen ?? Screen.splash),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.joinVerifyOTPPath,
      pageBuilder: (context, state) {
        final params =
            state.extra != null ? state.extra as JoinRouteParamsModel : null;

        return MaterialPage(
          key: state.pageKey,
          child: JoinVerifyOTPView(
            email: params?.email ?? '',
            fromScreen: params?.screen ?? Screen.splash,
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: RouteConstants.joinWelcomePath,
      pageBuilder: (context, state) {
        final params =
            state.extra != null ? state.extra as JoinRouteParamsModel : null;

        return MaterialPage(
          key: state.pageKey,
          child: JoinWelcomeView(
            email: params?.email ?? '',
            fromScreen: params?.screen ?? Screen.splash,
          ),
        );
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => RootPageView(
        firstChild: child,
      ),
      routes: [
        GoRoute(
          path: RouteConstants.homePath,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: HomeView(),
          ),
          routes: [
            _getWebviewRoute(),
          ],
        ),
        _getTrackRoute(fromRoot: true),
        _getWebviewRoute(fromRoot: true),
        _getConnectivityErrorRoute(fromRoot: true),
        _getDownloadsRoute(fromRoot: true),
        _getSearchRoute(fromRoot: true),
        GoRoute(
          path: RouteConstants.collectionPath,
          pageBuilder: (context, state) => getCollectionMaterialPage(state),
        ),
        GoRoute(
          path: RouteConstants.packPath,
          routes: [
            _getTrackRoute(),
            _getWebviewRoute(),
            GoRoute(
              path: 'pack2/:p2id',
              routes: [
                _getTrackRoute(),
                _getWebviewRoute(),
                GoRoute(
                  path: 'pack3/:p3id',
                  pageBuilder: (context, state) => getFolderMaterialPage(state),
                  routes: [
                    _getTrackRoute(),
                    _getWebviewRoute(),
                  ],
                ),
              ],
              pageBuilder: (context, state) => getFolderMaterialPage(state),
            ),
          ],
          pageBuilder: (context, state) => getFolderMaterialPage(state),
        ),
      ],
    ),
    _getBackgroundSoundRoute(),
    _getNotificationPermissionRoute(),
    _getPlayerRoute(),
  ],
);

GoRoute _getTrackRoute({bool fromRoot = false}) {
  return GoRoute(
    path: fromRoot
        ? RouteConstants.trackPath
        : RouteConstants.trackPath.sanitisePath(),
    routes: [
      _getWebviewRoute(),
    ],
    pageBuilder: (context, state) => getTrackOptionsMaterialPage(state),
  );
}

GoRoute _getPlayerRoute() {
  return GoRoute(
    parentNavigatorKey: _rootNavigatorKey,
    path: RouteConstants.playerPath,
    pageBuilder: (context, state) {
      var track = state.extra as TrackModel;
      
      return CustomTransitionPage<void>(
        key: state.pageKey,
        opaque: false,
        child: PlayerView(
          trackModel: track,
          file: track.audio.first.files.first,
        ),
        transitionDuration: Duration(milliseconds: 500),
        reverseTransitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );
    },
  );
}

GoRoute _getBackgroundSoundRoute() {
  return GoRoute(
    parentNavigatorKey: _rootNavigatorKey,
    path: RouteConstants.backgroundSoundsPath,
    pageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: BackgroundSoundView(),
      );
    },
  );
}

GoRoute _getNotificationPermissionRoute() {
  return GoRoute(
    parentNavigatorKey: _rootNavigatorKey,
    path: RouteConstants.notificationPermissionPath,
    pageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: NotificationPermissionView(),
      );
    },
  );
}

GoRoute _getWebviewRoute({bool fromRoot = false}) {
  return GoRoute(
    path: fromRoot
        ? RouteConstants.webviewPath
        : RouteConstants.webviewPath.sanitisePath(),
    pageBuilder: (context, state) {
      final url = state.extra! as Map;

      return MaterialPage(
        key: state.pageKey,
        child: MeditoWebViewWidget(url: url['url']!),
      );
    },
  );
}

GoRoute _getConnectivityErrorRoute({bool fromRoot = false}) {
  return GoRoute(
    parentNavigatorKey: _shellNavigatorKey,
    path: fromRoot
        ? RouteConstants.connectivityErrorPath
        : RouteConstants.connectivityErrorPath.sanitisePath(),
    pageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: ConnectivityErrorWidget(),
      );
    },
  );
}

GoRoute _getSearchRoute({bool fromRoot = false}) {
  return GoRoute(
    path:
        fromRoot ? RouteConstants.search : RouteConstants.search.sanitisePath(),
    pageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: SearchView(),
      );
    },
  );
}

GoRoute _getDownloadsRoute({bool fromRoot = false}) {
  return GoRoute(
    parentNavigatorKey: _shellNavigatorKey,
    path: fromRoot
        ? RouteConstants.downloadsPath
        : RouteConstants.downloadsPath.sanitisePath(),
    pageBuilder: (context, state) {
      return MaterialPage(
        key: state.pageKey,
        child: DownloadsView(),
      );
    },
  );
}

//ignore: prefer-match-file-name
enum Screen {
  splash,
  pack,
  player,
  stats,
  track,
  url,
}

MaterialPage<void> getTrackOptionsMaterialPage(GoRouterState state) {
  return MaterialPage(
    key: state.pageKey,
    child: TrackView(id: state.params['sid'] ?? ''),
  );
}

MaterialPage<void> getTrackOptionsDailyPage(GoRouterState state) {
  return MaterialPage(
    key: state.pageKey,
    child: TrackView(id: state.params['did'] ?? ''),
  );
}

//Can be altered to open other pages in the app other than Downloads (eg Faves)
MaterialPage<void> getCollectionMaterialPage(GoRouterState state) {
  return MaterialPage(key: state.pageKey, child: DownloadsView());
}

MaterialPage<void> getFolderMaterialPage(GoRouterState state) {
  var packId =
      state.params['p3id'] ?? state.params['p2id'] ?? state.params['pid'];

  return MaterialPage(
    key: state.pageKey,
    child: PackView(id: packId ?? ''),
  );
}

Future<void> handleNavigation(
  String? place,
  List<String?> ids, {
  BuildContext? context,
  WidgetRef? ref,
  GoRouter? goRouterContext,
}) async {
  ids.removeWhere((element) => element == null);
  var path;
  var params;
  if (place == TypeConstants.TRACK) {
    path = RouteConstants.trackPath.replaceAll(':sid', ids.first!);
  } else if (place != null && place.contains('pack3')) {
    path = RouteConstants.pack3Path
        .replaceAll(':pid', ids.first!)
        .replaceAll(':p2id', ids[1]!)
        .replaceAll(':p3id', ids[2]!);
  } else if (place != null && place.contains('pack2')) {
    path = RouteConstants.pack2Path
        .replaceAll(':pid', ids.first!)
        .replaceAll(':p2id', ids[1]!);
  } else if (place == TypeConstants.PACK) {
    path = RouteConstants.packPath.replaceAll(':pid', ids.first!);
  } else if (place == TypeConstants.URL) {
    await launchURLInBrowser(ids.last ?? StringConstants.meditoUrl);

    return;
  } else if (place == TypeConstants.LINK) {
    path = RouteConstants.webviewPath;
    params = {'url': ids.last};
  } else if (place == TypeConstants.FLOW) {
    path = ids.first != null ? '/${ids.first}' : RouteConstants.joinIntroPath;
    params = JoinRouteParamsModel(screen: Screen.track);
  } else if (place == TypeConstants.EMAIL) {
    if (ref != null) {
      var deviceAppAndUserInfo =
          await ref.read(deviceAppAndUserInfoProvider.future);
      var _info =
          '${StringConstants.debugInfo}\n$deviceAppAndUserInfo\n${StringConstants.writeBelowThisLine}';

      await launchEmailSubmission(
        path.toString(),
        body: _info,
      );
    }

    return;
  }
  if (context != null) {
    unawaited(context.push(path, extra: params));
  } else if (goRouterContext != null) {
    unawaited(goRouterContext.push(path, extra: params));
  }
}
