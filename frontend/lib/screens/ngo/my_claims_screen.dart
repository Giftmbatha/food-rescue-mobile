import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/claim_model.dart';
import '../../providers/claim_provider.dart';

class MyClaimsScreen extends ConsumerStatefulWidget {
  const MyClaimsScreen({super.key});

  @override
  ConsumerState<MyClaimsScreen> createState() =>
      _MyClaimsScreenState();
}

class _MyClaimsScreenState
    extends ConsumerState<MyClaimsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(claimProvider.notifier).loadMyClaims();
    });
  }

  Future<void> _refresh() async {
    await ref.read(claimProvider.notifier).loadMyClaims();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(claimProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ClaimState state) {
    if (state.isLoading && state.claims.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.claims.isEmpty) {
      return _buildError(state.error!);
    }

    if (state.claims.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: state.claims.length,
        itemBuilder: (context, index) {
          final claim = state.claims[index];

          return _ClaimCard(
            claim: claim,
            onTap: () {
              context.push(
                '/ngo/claim/${claim.id}',
                extra: claim,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline,
            size: 56,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load claims',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _refresh,
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.assignment_outlined,
            size: 64,
          ),
          const SizedBox(height: 20),
          const Text(
            'No claims yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Food you claim from donors will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/ngo/discover');
              },
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Discover Food'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  final ClaimModel claim;
  final VoidCallback onTap;

  const _ClaimCard({
    required this.claim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final listingTitle =
        claim.listingTitle ?? 'Food Listing';

    final organizationName =
        claim.ngoOrgName ?? 'Organization';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      listingTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  _StatusBadge(
                    status: claim.status,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      organizationName,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(
                      claim.proposedPickupTime,
                    ),
                  ),
                ],
              ),

              if (claim.message != null &&
                  claim.message!.isNotEmpty) ...[
                const SizedBox(height: 10),

                Text(
                  claim.message!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [
                  Text(
                    'View details',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDateTime(
      DateTime? dateTime,
      ) {
    if (dateTime == null) {
      return 'Pickup time not specified';
    }

    final date =
        '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';

    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';

    return '$date at $time';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _statusColor(normalized)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatStatus(normalized),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _statusColor(normalized),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      case 'PENDING':
      default:
        return Colors.orange;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Approved';
      case 'COMPLETED':
        return 'Completed';
      case 'REJECTED':
        return 'Rejected';
      case 'CANCELLED':
        return 'Cancelled';
      case 'PENDING':
        return 'Pending';
      default:
        return status;
    }
  }
}