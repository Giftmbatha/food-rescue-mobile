import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/donor/donor_home_screen.dart';
import 'screens/ngo/discover_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final userRole = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Not logged in → login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Logged in on auth route → home
      if (isAuthenticated && isAuthRoute) {
        return userRole == 'DONOR' ? '/donor/home' : '/ngo/discover';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/donor/home', builder: (context, state) => const DonorHomeScreen()),
      GoRoute(path: '/ngo/discover', builder: (context, state) => const DiscoverScreen()),
    ],
  );
});