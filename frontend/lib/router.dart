import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/listing_model.dart';

import 'providers/auth_provider.dart';
import 'providers/organization_setup_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/organization_setup_screen.dart';

import 'screens/donor/donor_home_screen.dart';
import 'screens/donor/donor_shell.dart';
import 'screens/donor/my_donations_screen.dart';
import 'screens/donor/profile_screen.dart';
import 'screens/donor/edit_profile_screen.dart';
import 'screens/donor/create_listing_screen.dart';

import 'screens/ngo/discover_screen.dart';
import 'screens/ngo/ngo_shell.dart';
import 'screens/ngo/my_claims_screen.dart';
import 'screens/ngo/profile_screen.dart';
import 'screens/ngo/listing_details_screen.dart';

final routerProvider =
Provider<GoRouter>((ref) {
  final authAsync =
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final auth =
          authAsync.value;

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
      // ----------------------------------------------------------
      // AUTHENTICATION
      // ----------------------------------------------------------

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
          ref.read(
            userRoleProvider,
          );

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

      // ----------------------------------------------------------
      // DONOR APPLICATION
      // ----------------------------------------------------------

      StatefulShellRoute.indexedStack(
        builder: (
            context,
            state,
            navigationShell,
            ) {
          return DonorShell(
            navigationShell:
            navigationShell,
          );
        },
        branches: [
          // ------------------------------------------------------
          // DONOR HOME
          // ------------------------------------------------------

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/donor/home',
                builder: (_, __) =>
                const DonorHomeScreen(),
              ),
            ],
          ),

          // ------------------------------------------------------
          // DONOR DONATIONS
          // ------------------------------------------------------

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/donor/donations',
                builder: (_, __) =>
                const MyDonationsScreen(),
              ),
            ],
          ),

          // ------------------------------------------------------
          // DONOR PROFILE
          // ------------------------------------------------------

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/donor/profile',
                builder: (_, __) =>
                const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, __) =>
                    const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ----------------------------------------------------------
      // CREATE DONATION
      // ----------------------------------------------------------

      GoRoute(
        path: '/donor/create-listing',
        builder: (_, __) =>
        const CreateListingScreen(),
      ),

      // ----------------------------------------------------------
      // NGO APPLICATION
      // ----------------------------------------------------------

      StatefulShellRoute.indexedStack(
        builder: (
            context,
            state,
            navigationShell,
            ) {
          return NgoShell(
            navigationShell:
            navigationShell,
          );
        },
        branches: [
          // ------------------------------------------------------
          // NGO DISCOVER
          // ------------------------------------------------------

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ngo/discover',
                builder: (_, __) =>
                const DiscoverScreen(),
                routes: [
                  // Listing Details
                  GoRoute(
                    path: 'listing/:id',
                    builder: (_, state) {
                      final listing =
                      state.extra
                      as ListingModel;

                      return ListingDetailsScreen(
                        listing: listing,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ------------------------------------------------------
          // NGO MY CLAIMS
          // ------------------------------------------------------

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ngo/claims',
                builder: (_, __) =>
                const MyClaimsScreen(),
              ),
            ],
          ),

          // ------------------------------------------------------
          // NGO PROFILE
          // ------------------------------------------------------

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ngo/profile',
                builder: (_, __) =>
                const NgoProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});