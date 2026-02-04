import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/car_card.dart';
import '../../core/widgets/empty_state.dart';
import '../providers/auth_provider.dart';
import '../providers/car_provider.dart';
import '../providers/favorites_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);
    final favoriteIds = ref.watch(favoriteCarIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: AppStrings.searchCars,
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textLight),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? _buildInitialState()
          : searchResults.when(
              data: (cars) {
                if (cars.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: AppStrings.noCarsFound,
                    subtitle: 'Try searching with different keywords',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return CarCard(
                      id: car.id,
                      name: car.name,
                      brand: car.brand,
                      imageUrl: car.firstImage,
                      pricePerDay: car.pricePerDay,
                      rating: car.rating,
                      transmission: car.transmission,
                      fuelType: car.fuelType,
                      seats: car.seats,
                      isFavorite: favoriteIds.contains(car.id),
                      onTap: () => context.push('/car/${car.id}'),
                      onFavoriteToggle: () {
                        final userId = ref
                            .read(currentUserProvider)
                            .valueOrNull
                            ?.uid;
                        if (userId != null) {
                          ref
                              .read(favoritesNotifierProvider.notifier)
                              .toggleFavorite(userId, car.id);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error searching')),
            ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: carCategories.map((category) {
              return ActionChip(
                label: Text(category),
                onPressed: () {
                  _searchController.text = category;
                  ref.read(searchQueryProvider.notifier).state = category;
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text('Search Tips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildTip('Search by car name, brand, or category'),
          _buildTip('Try "SUV" for family trips'),
          _buildTip('Try "Luxury" for premium cars'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
