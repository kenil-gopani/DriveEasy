import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../data/datasources/car_datasource.dart';
import '../../data/models/car_model.dart';

// Datasource provider
final carDatasourceProvider = Provider((ref) => CarDatasource());

// All cars stream provider
final carsStreamProvider = StreamProvider<List<CarModel>>((ref) {
  final datasource = ref.watch(carDatasourceProvider);
  return datasource.carsStream();
});

// Featured cars provider
final featuredCarsProvider = FutureProvider<List<CarModel>>((ref) async {
  final datasource = ref.watch(carDatasourceProvider);
  return datasource.getFeaturedCars();
});

// Recommended cars provider
final recommendedCarsProvider = FutureProvider<List<CarModel>>((ref) async {
  final datasource = ref.watch(carDatasourceProvider);
  return datasource.getRecommendedCars();
});

// Cars by category provider
final carsByCategoryProvider = FutureProvider.family<List<CarModel>, String>((
  ref,
  category,
) async {
  final datasource = ref.watch(carDatasourceProvider);
  return datasource.getCarsByCategory(category);
});

// Single car provider
final carByIdProvider = FutureProvider.family<CarModel?, String>((
  ref,
  carId,
) async {
  final datasource = ref.watch(carDatasourceProvider);
  return datasource.getCarById(carId);
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search results provider
final searchResultsProvider = FutureProvider<List<CarModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final datasource = ref.watch(carDatasourceProvider);
  return datasource.searchCars(query);
});

// Selected category provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Car management notifier for admin operations
class CarManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final CarDatasource _datasource;

  CarManagementNotifier(this._datasource) : super(const AsyncValue.data(null));

  Future<String> addCar(CarModel car, {List<File>? images}) async {
    state = const AsyncValue.loading();
    try {
      List<String> imageUrls = car.images;

      if (images != null && images.isNotEmpty) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrls = await _datasource.uploadCarImages(tempId, images);
      }

      final carId = await _datasource.addCar(car.copyWith(images: imageUrls));
      state = const AsyncValue.data(null);
      return carId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCar(CarModel car, {List<File>? newImages}) async {
    state = const AsyncValue.loading();
    try {
      List<String> imageUrls = car.images;

      if (newImages != null && newImages.isNotEmpty) {
        final additionalUrls = await _datasource.uploadCarImages(
          car.id,
          newImages,
        );
        imageUrls = [...imageUrls, ...additionalUrls];
      }

      await _datasource.updateCar(car.copyWith(images: imageUrls));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteCar(String carId) async {
    state = const AsyncValue.loading();
    try {
      await _datasource.deleteCar(carId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final carManagementProvider =
    StateNotifierProvider<CarManagementNotifier, AsyncValue<void>>((ref) {
      return CarManagementNotifier(ref.watch(carDatasourceProvider));
    });

// Car categories
const List<String> carCategories = ['SUV', 'Sedan', 'Hatchback', 'Luxury'];
const List<String> fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
const List<String> transmissionTypes = ['Manual', 'Automatic'];

// My cars provider (for owners)
final myCarsProvider = StreamProvider.family<List<CarModel>, String>((
  ref,
  ownerId,
) {
  final datasource = ref.watch(carDatasourceProvider);
  return datasource.carsByOwnerStream(ownerId);
});
