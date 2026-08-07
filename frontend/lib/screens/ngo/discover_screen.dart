import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  bool _isMapView = false;
  String _searchQuery = '';
  final Set<String> _selectedCategories = {};

  final List<String> _categories = [
    'All', 'Bakery', 'Produce', 'Dairy', 'Meat', 'Prepared', 'Beverages'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              hintText: 'Find food...',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {},
                ),
              ],
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategories.contains(category) || 
                                  (category == 'All' && _selectedCategories.isEmpty);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (category == 'All') {
                          _selectedCategories.clear();
                        } else {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // List/Map toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('List'), icon: Icon(Icons.list)),
                ButtonSegment(value: true, label: Text('Map'), icon: Icon(Icons.map)),
              ],
              selected: {_isMapView},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() => _isMapView = newSelection.first);
              },
            ),
          ),
          
          // Content
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Claims'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }

  Widget _buildListView() {
    // TODO: Replace with API call to /api/v1/listings/nearby
    final listings = _getMockListings();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        return _buildListingCard(listings[index]);
      },
    );
  }

  Widget _buildMapView() {
    // TODO: Integrate google_maps_flutter
    return const Center(
      child: Text('Map view — integrate google_maps_flutter'),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
    final theme = Theme.of(context);
    final hoursUntilExpiry = listing['hoursUntilExpiry'] as int;
    final isUrgent = hoursUntilExpiry < 4;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donor info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    listing['donorName'][0],
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['donorName'],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: theme.colorScheme.secondary),
                          Text(
                            ' ${listing['rating']} · ${listing['donationCount']} donations',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Image
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            // Title
            Text(
              listing['title'],
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            // Expiry progress
            LinearProgressIndicator(
              value: hoursUntilExpiry / 24,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(
                isUrgent ? theme.colorScheme.error : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            // Expiry text
            Text(
              'Expires: ${listing['expiryText']}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isUrgent ? theme.colorScheme.error : theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            
            // Distance and claim button
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.colorScheme.outline),
                Text(
                  ' ${listing['distance']}km · ${listing['driveTime']}min drive',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    // TODO: Navigate to claim detail
                  },
                  child: const Text('Claim Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockListings() {
    return [
      {
        'donorName': 'Spar Supermarket',
        'rating': 4.8,
        'donationCount': 120,
        'title': 'Fresh vegetables — 5kg',
        'hoursUntilExpiry': 3,
        'expiryText': 'Today 6PM',
        'distance': 1.2,
        'driveTime': 5,
      },
      {
        'donorName': 'Checkers',
        'rating': 4.5,
        'donationCount': 45,
        'title': 'Bakery items',
        'hoursUntilExpiry': 18,
        'expiryText': 'Tomorrow 8AM',
        'distance': 2.5,
        'driveTime': 12,
      },
    ];
  }
}