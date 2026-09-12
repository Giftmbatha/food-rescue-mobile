import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';

class DonorHomeScreen extends ConsumerWidget {
  const DonorHomeScreen({super.key});

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final listingsAsync =
    ref.watch(listingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(listingsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(listingsProvider);

          await ref.read(listingsProvider.future);
        },
        child: listingsAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return _buildErrorState(
              context,
              ref,
              error,
            );
          },
          data: (listings) {
            return _buildDashboard(
              context,
              ref,
              listings,
            );
          },
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () async {
          await context.push(
            '/donor/create-listing',
          );

          ref.invalidate(listingsProvider);
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Donate Food',
        ),
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context,
      WidgetRef ref,
      List<ListingModel> listings,
      ) {
    final available = listings
        .where(
          (listing) =>
      listing.status == 'AVAILABLE',
    )
        .length;

    final completed = listings
        .where(
          (listing) =>
      listing.status == 'COMPLETED',
    )
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        const Text(
          'Welcome back 👋',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Manage your food donations and help reduce food waste.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 24),

        // ------------------------------------------------------
        // STAT CARDS
        // ------------------------------------------------------

        Row(
          children: [
            Expanded(
              child: _statCard(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'Total',
                value: listings.length
                    .toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                context,
                icon: Icons.volunteer_activism_outlined,
                title: 'Available',
                value: available
                    .toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                context,
                icon: Icons.check_circle_outline,
                title: 'Completed',
                value: completed
                    .toString(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ------------------------------------------------------
        // CREATE DONATION
        // ------------------------------------------------------

        InkWell(
          borderRadius:
          BorderRadius.circular(16),
          onTap: () async {
            await context.push(
              '/donor/create-listing',
            );

            ref.invalidate(
              listingsProvider,
            );
          },
          child: Container(
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(16),
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                  BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donate food',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a new food donation for NGOs.',
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ------------------------------------------------------
        // DONATIONS
        // ------------------------------------------------------

        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Donations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (listings.isNotEmpty)
              Text(
                '${listings.length} donation${listings.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (listings.isEmpty)
          _buildEmptyState(context)
        else
          ...listings.map(
                (listing) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 12,
                ),
                child: _listingCard(
                  context,
                  listing,
                ),
              );
            },
          ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _statCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listingCard(
      BuildContext context,
      ListingModel listing,
      ) {
    final status = listing.status;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // We will connect this to the
          // listing details screen next.
        },
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _listingImage(listing),

              const SizedBox(width: 14),

              Expanded(
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
                            listing.title,
                            style:
                            const TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                        _statusBadge(status),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${listing.quantityKg} kg',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _formatCategory(
                        listing.category,
                      ),
                      style:
                      const TextStyle(
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
      ),
    );
  }

  Widget _listingImage(
      ListingModel listing,
      ) {
    if (listing.imageUrls.isEmpty) {
      return Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(10),
          color: Colors.grey.shade200,
        ),
        child: const Icon(
          Icons.fastfood_outlined,
          size: 35,
          color: Colors.grey,
        ),
      );
    }

    final image = listing.imageUrls.first;

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(10),
      child: Image.network(
        image,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) {
          return Container(
            width: 85,
            height: 85,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.fastfood_outlined,
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(
      String status,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        color: _statusColor(status)
            .withValues(alpha: 0.12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _statusColor(status),
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

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.volunteer_activism_outlined,
            size: 55,
            color: Colors.grey,
          ),

          const SizedBox(height: 16),

          const Text(
            'No donations yet',
            style: TextStyle(
              fontSize: 18,
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

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              context.push(
                '/donor/create-listing',
              );
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Create Donation',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      WidgetRef ref,
      Object error,
      ) {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),

        const Icon(
          Icons.error_outline,
          size: 60,
          color: Colors.red,
        ),

        const SizedBox(height: 16),

        const Text(
          'Unable to load donations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: ElevatedButton(
            onPressed: () {
              ref.invalidate(
                listingsProvider,
              );
            },
            child: const Text(
              'Try Again',
            ),
          ),
        ),
      ],
    );
  }
}