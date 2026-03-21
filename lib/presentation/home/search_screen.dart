import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/car_card.dart';
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
    final allCars = ref.watch(carsStreamProvider);
    final query = ref.watch(searchQueryProvider);
    final favoriteIds = ref.watch(favoriteCarIdsProvider);

    final displayAsync = query.isEmpty ? allCars : searchResults;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadowLight,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search cars, brands...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              suffixIcon: query.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
        automaticallyImplyLeading: true, // Allow back navigation
      ),
      body: displayAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Cars Found',
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try searching with different keywords',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                  final userId = ref.read(currentUserProvider).valueOrNull?.uid;
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
        error: (_, __) => const Center(child: Text('Error loading cars')),
      ),
    );
  }
}
