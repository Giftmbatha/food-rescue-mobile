import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/organization_setup_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/organization_setup_screen.dart';
import 'screens/donor/donor_home_screen.dart';
import 'screens/donor/create_listing_screen.dart';
import 'screens/ngo/discover_screen.dart';

final routerProvider =
    Provider<GoRouter>((ref) {
  final authAsync =
      ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final auth =
          authAsync.value;

      // Keep splash/loading behavior simple.
      // The auth provider will trigger router
      // rebuilds when its state changes.
      if (authAsync.isLoading) {
        return null;
      }

      if (auth == null) {
        return '/login';
      }

      final location =
          state.matchedLocation;

      final isAuthRoute =
          location == '/login' ||
          location == '/register';

      final isSetupRoute =
          location == '/organization-setup';

      if (!auth.isAuthenticated &&
          !isAuthRoute) {
        return '/login';
      }

      if (auth.isAuthenticated &&
          auth.needsOrganizationSetup &&
          !isSetupRoute) {
        return '/organization-setup';
      }

      if (auth.isAuthenticated &&
          auth.hasOrganizationProfile &&
          isAuthRoute) {
        return auth.user?.role == 'DONOR'
            ? '/donor/home'
            : '/ngo/discover';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) =>
            const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (_, __) =>
            const RegisterScreen(),
      ),

      GoRoute(
        path: '/organization-setup',
        builder: (context, state) {
          final role =
              state.extra
                  as OrganizationRole?;

          final userRole =
              ref.read(userRoleProvider);

          final resolvedRole =
              role ??
                  (userRole == 'DONOR'
                      ? OrganizationRole.donor
                      : OrganizationRole.ngo);

          return OrganizationSetupScreen(
            role: resolvedRole,
          );
        },
      ),

      GoRoute(
        path: '/donor/home',
        builder: (_, __) =>
            const DonorHomeScreen(),
      ),

      GoRoute(
        path: '/donor/create-listing',
        builder: (_, __) =>
            const CreateListingScreen(),
      ),

      GoRoute(
        path: '/ngo/discover',
        builder: (_, __) =>
            const DiscoverScreen(),
      ),
    ],
  );
});
