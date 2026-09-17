import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/listing_provider.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final listings =
    ref.watch(listingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(listingsProvider);
          await ref.read(
            listingsProvider.future,
          );
        },
        child: listings.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 150),
              Center(
                child: Text(
                  error.toString(),
                ),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text(
                      'No food donations available.',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding:
              const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, index) {
                final listing =
                items[index];

                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),
                  clipBehavior:
                  Clip.antiAlias,
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.all(12),
                    leading: _listingImage(
                      listing.imageUrls,
                    ),
                    title: Text(
                      listing.title,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 6,
                      ),
                      child: Text(
                        '${listing.quantityKg} kg • '
                            '${_formatCategory(listing.category)}\n'
                            '${listing.donorOrgName}',
                      ),
                    ),
                    trailing:
                    const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      context.push(
                        '/ngo/discover/listing/${listing.id}',
                        extra: listing,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _listingImage(
      List<String> imageUrls,
      ) {
    if (imageUrls.isEmpty) {
      return Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
          BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.fastfood_outlined,
          color: Colors.grey,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(10),
      child: Image.network(
        imageUrls.first,
        width: 65,
        height: 65,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) {
          return Container(
            width: 65,
            height: 65,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.fastfood_outlined,
            ),
          );
        },
      ),
    );
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
}