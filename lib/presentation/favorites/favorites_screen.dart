import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/car_card.dart';
import '../../core/widgets/empty_state.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCarsAsync = ref.watch(favoriteCarsProvider);
    final favoriteIds = ref.watch(favoriteCarIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text(AppStrings.favorites)),
      body: favoriteCarsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_outline,
              title: AppStrings.noFavorites,
              subtitle: 'Start adding cars to your favorites',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
