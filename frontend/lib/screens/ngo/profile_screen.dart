import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ngo_model.dart';
import '../../providers/ngo_provider.dart';

class NgoProfileScreen extends ConsumerStatefulWidget {
  const NgoProfileScreen({super.key});

  @override
  ConsumerState<NgoProfileScreen> createState() =>
      _NgoProfileScreenState();
}

class _NgoProfileScreenState
    extends ConsumerState<NgoProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(ngoProvider.notifier)
          .loadProfileAndStats();
    });
  }

  Future<void> _refresh() async {
    await ref
        .read(ngoProvider.notifier)
        .loadProfileAndStats();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ngoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: state.isLoading && state.profile == null
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 300),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        )
            : state.profile == null
            ? _buildError(state.error)
            : _buildProfile(
          state.profile!,
          state,
        ),
      ),
    );
  }

  Widget _buildProfile(
      NgoModel profile,
      NgoState state,
      ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(profile),

        const SizedBox(height: 24),

        if (state.stats != null)
          _buildStats(state),

        const SizedBox(height: 24),

        _buildSection(
          title: 'Organization Information',
          children: [
            _infoRow(
              Icons.business_outlined,
              'Organization',
              profile.orgName,
            ),
            _infoRow(
              Icons.badge_outlined,
              'Registration',
              profile.regNumber,
            ),
            _infoRow(
              Icons.phone_outlined,
              'Phone',
              profile.phone,
            ),
            _infoRow(
              Icons.person_outline,
              'Contact',
              profile.contactPerson,
            ),
            _infoRow(
              Icons.location_on_outlined,
              'Address',
              profile.address,
            ),
            _infoRow(
              Icons.map_outlined,
              'Service Area',
              profile.serviceArea,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(NgoModel profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 42,
          child: Text(
            profile.orgName.isNotEmpty
                ? profile.orgName[0].toUpperCase()
                : 'N',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          profile.orgName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'NGO',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(NgoState state) {
    final stats = state.stats!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Impact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _statItem(
                    'Claims',
                    stats.totalClaims.toString(),
                  ),
                ),
                Expanded(
                  child: _statItem(
                    'Completed',
                    stats.completedPickups.toString(),
                  ),
                ),
                Expanded(
                  child: _statItem(
                    'Kg Received',
                    '${stats.totalKgReceived}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
      String label,
      String value,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      IconData icon,
      String label,
      String? value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true
                  ? value!
                  : 'Not provided',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.person_off_outlined,
          size: 60,
        ),
        const SizedBox(height: 16),
        const Text(
          'Unable to load profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error ?? 'Something went wrong.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}