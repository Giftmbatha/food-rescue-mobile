import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/donor_model.dart';
import '../../models/donor_stats_model.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final profileAsync =
    ref.watch(donorProfileProvider);

    final statsAsync =
    ref.watch(donorStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(
                donorProfileProvider,
              );

              ref.invalidate(
                donorStatsProvider,
              );
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, _) {
          return _errorState(
            context,
            ref,
            error,
          );
        },
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text(
                'Donor profile not found.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                donorProfileProvider,
              );

              ref.invalidate(
                donorStatsProvider,
              );

              await ref.read(
                donorProfileProvider.future,
              );
            },
            child: ListView(
              padding:
              const EdgeInsets.all(16),
              children: [
                _profileHeader(profile),

                const SizedBox(height: 20),

                _statsSection(
                  statsAsync,
                ),

                const SizedBox(height: 24),

                _sectionTitle(
                  'Organisation',
                ),

                _infoCard(
                  children: [
                    _infoRow(
                      Icons.business_outlined,
                      'Organisation',
                      profile.orgName,
                    ),
                    _infoRow(
                      Icons.category_outlined,
                      'Organisation Type',
                      _formatOrgType(
                        profile.orgType,
                      ),
                    ),
                    _infoRow(
                      Icons.location_on_outlined,
                      'Address',
                      profile.address,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  'Contact',
                ),

                _infoCard(
                  children: [
                    _infoRow(
                      Icons.person_outline,
                      'Contact Person',
                      profile.contactPerson,
                    ),
                    _infoRow(
                      Icons.phone_outlined,
                      'Phone',
                      profile.phone ??
                          'Not provided',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updated =
                      await context.push(
                        '/donor/profile/edit',
                      );

                      if (updated == true) {
                        ref.invalidate(
                          donorProfileProvider,
                        );

                        ref.invalidate(
                          donorStatsProvider,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text(
                      'Edit Profile',
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileHeader(
      DonorModel profile,
      ) {
    final initial =
    profile.orgName.isNotEmpty
        ? profile.orgName[0]
        .toUpperCase()
        : 'D';

    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 32,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          profile.orgName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          _formatOrgType(
            profile.orgType,
          ),
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star,
              size: 18,
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            Text(
              (profile.ratingAvg ?? 0)
                  .toStringAsFixed(1),
              style: const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statsSection(
      AsyncValue<DonorStatsModel> statsAsync,
      ) {
    return statsAsync.when(
      loading: () {
        return const SizedBox(
          height: 100,
          child: Center(
            child:
            CircularProgressIndicator(),
          ),
        );
      },
      error: (_, __) {
        return const SizedBox.shrink();
      },
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _statCard(
                Icons.inventory_2_outlined,
                stats.totalListings
                    .toString(),
                'Donations',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                Icons.volunteer_activism_outlined,
                stats.completedClaims
                    .toString(),
                'Completed',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                Icons.scale_outlined,
                '${stats.totalKgDonated.toStringAsFixed(1)} kg',
                'Donated',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(
      IconData icon,
      String value,
      String label,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign:
            TextAlign.center,
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                  const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style:
                  const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(
      BuildContext context,
      WidgetRef ref,
      Object error,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(
                  donorProfileProvider,
                );

                ref.invalidate(
                  donorStatsProvider,
                );
              },
              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOrgType(
      String value,
      ) {
    if (value.isEmpty) {
      return 'Not provided';
    }

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) {
        if (word.isEmpty) {
          return word;
        }

        return word[0].toUpperCase() +
            word.substring(1).toLowerCase();
      },
    )
        .join(' ');
  }
}