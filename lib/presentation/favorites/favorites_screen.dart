import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/car_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/car_model.dart';
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
              return _SwipeableFavoriteCard(
                car: car,
                isFavorite: favoriteIds.contains(car.id),
                onTap: () => context.push('/car/${car.id}'),
                onRemove: () async {
                  final userId = ref.read(currentUserProvider).valueOrNull?.uid;
                  if (userId == null) return;

                  await ref
                      .read(favoritesNotifierProvider.notifier)
                      .toggleFavorite(userId, car.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${car.name} removed from favorites',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.textSecondary,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: AppColors.accent,
                            onPressed: () {
                              ref
                                  .read(favoritesNotifierProvider.notifier)
                                  .toggleFavorite(userId, car.id);
                            },
                          ),
                        ),
                      );
                  }
                },
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

class _SwipeableFavoriteCard extends StatelessWidget {
  final CarModel car;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onFavoriteToggle;

  const _SwipeableFavoriteCard({
    required this.car,
    required this.isFavorite,
    required this.onTap,
    required this.onRemove,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('fav-${car.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.favorite_border, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onRemove();
        return false; // Let the provider remove it reactively
      },
      child: CarCard(
        id: car.id,
        name: car.name,
        brand: car.brand,
        imageUrl: car.firstImage,
        pricePerDay: car.pricePerDay,
        rating: car.rating,
        transmission: car.transmission,
        fuelType: car.fuelType,
        seats: car.seats,
        isFavorite: isFavorite,
        onTap: onTap,
        onFavoriteToggle: onFavoriteToggle,
      ),
    );
  }
}
