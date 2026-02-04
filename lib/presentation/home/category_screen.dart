import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/car_card.dart';
import '../../core/widgets/empty_state.dart';
import '../providers/auth_provider.dart';
import '../providers/car_provider.dart';
import '../providers/favorites_provider.dart';

class CategoryScreen extends ConsumerWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsByCategoryProvider(category));
    final favoriteIds = ref.watch(favoriteCarIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text('$category Cars')),
      body: carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car_outlined,
              title: 'No $category Cars',
              subtitle: 'Check back later for new arrivals',
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
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
