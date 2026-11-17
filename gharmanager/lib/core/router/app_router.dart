import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/forgot_password_screen.dart';
import '../../features/authentication/presentation/sign_in_screen.dart';
import '../../features/authentication/presentation/sign_up_screen.dart';
import '../../features/dashboard/presentation/home_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/setup/presentation/setup_screen.dart';
import '../services/providers.dart';
import 'auth_router_refresh.dart';

final startupIssueProvider = Provider<String?>((ref) => null);

final appRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final startupIssue = ref.watch(startupIssueProvider);
  AuthRouterRefresh? authRefresh;
  if (client != null) {
    authRefresh = AuthRouterRefresh(client.auth.onAuthStateChange);
    ref.onDispose(authRefresh.dispose);
  }

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == '/splash') return null;
      if (startupIssue != null || client == null) {
        return location == '/setup' ? null : '/setup';
      }

      final isAuthenticated = client.auth.currentSession != null;
      const authenticationRoutes = {'/sign-in', '/sign-up', '/forgot-password'};
      if (!isAuthenticated && !authenticationRoutes.contains(location)) {
        return '/sign-in';
      }
      if (isAuthenticated && authenticationRoutes.contains(location)) {
        return '/home';
      }
      if (location == '/setup') {
        return isAuthenticated ? '/home' : '/sign-in';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/splash'),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/setup', builder: (context, state) => const SetupScreen()),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
