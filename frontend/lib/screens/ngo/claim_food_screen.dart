import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/listing_model.dart';
import '../../providers/claim_provider.dart';

class ClaimFoodScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const ClaimFoodScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<ClaimFoodScreen> createState() =>
      _ClaimFoodScreenState();
}

class _ClaimFoodScreenState
    extends ConsumerState<ClaimFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _pickupTime;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Default pickup time: tomorrow at 10:00
    final tomorrow = DateTime.now().add(
      const Duration(days: 1),
    );

    _pickupTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      10,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickupTime),
    );

    if (time == null || !mounted) return;

    setState(() {
      _pickupTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final claim = await ref
        .read(claimProvider.notifier)
        .createClaim(
      listingId: widget.listing.id,
      proposedPickupTime: _pickupTime,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
    );

    if (!mounted) return;

    if (claim != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Food claim submitted successfully.',
          ),
        ),
      );

      context.pop();
      return;
    }

    final error = ref.read(claimProvider).error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Failed to submit claim.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final claimState = ref.watch(claimProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Food'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildListingSummary(),

            const SizedBox(height: 24),

            const Text(
              'Pickup Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildPickupTimeField(),

            const SizedBox(height: 20),

            TextFormField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Message to donor',
                hintText:
                'Add any information the donor should know...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),

            _buildClaimSummary(),

            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                claimState.isSubmitting ? null : _submitClaim,
                child: claimState.isSubmitting
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Submit Claim',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingSummary() {
    final listing = widget.listing;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              listing.donorOrgName,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.scale_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('${listing.quantityKg} kg'),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(listing.pickupAddress),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupTimeField() {
    return InkWell(
      onTap: _selectPickupTime,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Proposed pickup time',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_month_outlined),
        ),
        child: Text(
          _formatDateTime(_pickupTime),
        ),
      ),
    );
  }

  Widget _buildClaimSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Claim Summary',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Food',
            widget.listing.title,
          ),

          _summaryRow(
            'Quantity',
            '${widget.listing.quantityKg} kg',
          ),

          _summaryRow(
            'Pickup',
            _formatDateTime(_pickupTime),
          ),

          _summaryRow(
            'Status',
            'Pending donor approval',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
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

  String _formatDateTime(DateTime dateTime) {
    final date =
        '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';

    final hour =
    dateTime.hour.toString().padLeft(2, '0');

    final minute =
    dateTime.minute.toString().padLeft(2, '0');

    return '$date at $hour:$minute';
  }
}