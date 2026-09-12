import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/listing_provider.dart';

class DiscoverScreen
    extends ConsumerWidget {
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
      body: listings.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
          ),
        ),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) {
            final listing = items[index];

            return ListTile(
              title: Text(listing.title),
              subtitle: Text(
                '${listing.quantityKg} kg • '
                '${listing.category}',
              ),
            );
          },
        ),
      ),
    );
  }
}
