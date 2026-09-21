import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/claim_model.dart';
import '../../providers/claim_provider.dart';

class ClaimDetailsScreen extends ConsumerStatefulWidget {
  final ClaimModel claim;

  const ClaimDetailsScreen({
    super.key,
    required this.claim,
  });

  @override
  ConsumerState<ClaimDetailsScreen> createState() =>
      _ClaimDetailsScreenState();
}

class _ClaimDetailsScreenState
    extends ConsumerState<ClaimDetailsScreen> {
  Future<void> _cancelClaim() async {
    final claimId = widget.claim.id;

    if (claimId == null || claimId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid claim ID.'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Claim'),
          content: const Text(
            'Are you sure you want to cancel this claim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Claim'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Claim'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await ref
        .read(claimProvider.notifier)
        .cancelClaim(claimId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim cancelled successfully.'),
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(claimProvider).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Failed to cancel claim.',
          ),
        ),
      );
    }
  }

  Future<void> _completeClaim() async {
    final claimId = widget.claim.id;

    if (claimId == null || claimId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid claim ID.'),
        ),
      );
      return;
    }

    final success = await ref
        .read(claimProvider.notifier)
        .completeClaim(claimId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pickup marked as completed.',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      final error = ref.read(claimProvider).error;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Failed to complete pickup.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final claim = widget.claim;
    final state = ref.watch(claimProvider);

    final status = claim.status.toUpperCase();

    final canCancel = status == 'PENDING';
    final canComplete = status == 'APPROVED';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(claim),

          const SizedBox(height: 24),

          _buildSection(
            title: 'Claim Information',
            children: [
              _infoRow(
                Icons.fastfood_outlined,
                'Food',
                claim.listingTitle ?? 'Food Listing',
              ),
              _infoRow(
                Icons.business_outlined,
                'Organization',
                claim.ngoOrgName ?? 'Organization',
              ),
              _infoRow(
                Icons.calendar_month_outlined,
                'Pickup',
                _formatDateTime(
                  claim.proposedPickupTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildSection(
            title: 'Your Message',
            children: [
              Text(
                claim.message?.isNotEmpty == true
                    ? claim.message!
                    : 'No message provided.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),

          if (claim.donorResponse != null &&
              claim.donorResponse!.isNotEmpty) ...[
            const SizedBox(height: 20),

            _buildSection(
              title: 'Donor Response',
              children: [
                Text(
                  claim.donorResponse!,
                  style: const TextStyle(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],

          if (claim.completedAt != null) ...[
            const SizedBox(height: 20),

            _buildSection(
              title: 'Completed',
              children: [
                Text(
                  _formatDateTime(
                    claim.completedAt,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          if (canCancel)
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed:
                state.isSubmitting ? null : _cancelClaim,
                child: const Text(
                  'Cancel Claim',
                ),
              ),
            ),

          if (canComplete)
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                state.isSubmitting ? null : _completeClaim,
                child: state.isSubmitting
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Mark Pickup as Completed',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ClaimModel claim) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _statusColor(
              claim.status,
            ).withValues(alpha: 0.12),
          ),
          child: Icon(
            _statusIcon(claim.status),
            size: 36,
            color: _statusColor(claim.status),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          claim.listingTitle ?? 'Food Listing',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        _statusBadge(claim.status),
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
                fontSize: 17,
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
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _statusColor(normalized)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatStatus(normalized),
        style: TextStyle(
          color: _statusColor(normalized),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
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

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_outline;
      case 'COMPLETED':
        return Icons.task_alt;
      case 'REJECTED':
        return Icons.cancel_outlined;
      case 'CANCELLED':
        return Icons.block_outlined;
      case 'PENDING':
      default:
        return Icons.hourglass_empty;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Not specified';
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