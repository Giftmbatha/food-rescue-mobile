import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';

class MyDonationsScreen extends ConsumerWidget {
  const MyDonationsScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final listingsAsync =
    ref.watch(listingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(
                listingsProvider,
              );
            },
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: listingsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to load donations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(
                        listingsProvider,
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
        },
        data: (listings) {
          if (listings.isEmpty) {
            return _emptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                listingsProvider,
              );

              await ref.read(
                listingsProvider.future,
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listings.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                return _donationCard(
                  context,
                  listings[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _donationCard(
      BuildContext context,
      ListingModel listing,
      ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _image(listing),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                      _status(
                        listing.status,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${listing.quantityKg} kg',
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatCategory(
                      listing.category,
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.pickupAddress,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(
      ListingModel listing,
      ) {
    if (listing.imageUrls.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
          BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.fastfood_outlined,
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(10),
      child: Image.network(
        listing.imageUrls.first,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.fastfood_outlined,
            ),
          );
        },
      ),
    );
  }

  Widget _status(
      String status,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _statusColor(status)
            .withValues(alpha: 0.12),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 10,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusColor(
      String status,
      ) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'CLAIMED':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.blue;
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCategory(
      String category,
      ) {
    return category
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

  Widget _emptyState(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.volunteer_activism_outlined,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No donations yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your food donations will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}