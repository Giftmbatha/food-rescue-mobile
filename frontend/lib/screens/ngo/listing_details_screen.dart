import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/listing_model.dart';

class ListingDetailsScreen extends StatelessWidget {
  final ListingModel listing;

  const ListingDetailsScreen({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImages(),

            const SizedBox(height: 20),

            Text(
              listing.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                _statusBadge(),
                const SizedBox(width: 10),
                Text(
                  '${listing.quantityKg} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _sectionTitle('Donor'),

            const SizedBox(height: 8),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.business),
              ),
              title: Text(
                listing.donorOrgName,
              ),
              subtitle: Text(
                _formatText(listing.donorOrgType),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle('Food Information'),

            const SizedBox(height: 12),

            _infoRow(
              Icons.category_outlined,
              'Category',
              _formatText(listing.category),
            ),

            _infoRow(
              Icons.scale_outlined,
              'Quantity',
              '${listing.quantityKg} kg',
            ),

            _infoRow(
              Icons.calendar_today_outlined,
              'Expiry Date',
              _formatDate(listing.expiryDate),
            ),

            if (listing.description != null &&
                listing.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                listing.description!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 24),

            _sectionTitle('Pickup Information'),

            const SizedBox(height: 12),

            _infoRow(
              Icons.location_on_outlined,
              'Address',
              listing.pickupAddress,
            ),

            _infoRow(
              Icons.access_time_outlined,
              'Pickup Window',
              listing.pickupWindow,
            ),

            if (listing.pickupNotes != null &&
                listing.pickupNotes!.trim().isNotEmpty)
              _infoRow(
                Icons.notes_outlined,
                'Pickup Notes',
                listing.pickupNotes!,
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                listing.status == 'AVAILABLE'
                    ? () {
                  context.push(
                    '/ngo/discover/listing/${listing.id}/claim',
                    extra: listing,
                  );
                }
                    : null,
                icon: const Icon(
                  Icons.volunteer_activism,
                ),
                label: const Text(
                  'Claim Food',
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImages() {
    if (listing.imageUrls.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.fastfood_outlined,
          size: 70,
          color: Colors.grey,
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: listing.imageUrls.length,
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius:
            BorderRadius.circular(16),
            child: Image.network(
              listing.imageUrls[index],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.fastfood_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
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
      const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        color: Colors.green.withValues(
          alpha: 0.12,
        ),
      ),
      child: Text(
        _formatText(listing.status),
        style: const TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatText(String value) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}