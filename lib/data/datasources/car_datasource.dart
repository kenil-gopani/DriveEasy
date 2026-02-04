import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/car_model.dart';

class CarDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _carsCollection =>
      _firestore.collection('cars');

  // Get all cars - simplified query without ordering to avoid index issues
  Future<List<CarModel>> getAllCars() async {
    try {
      final snapshot = await _carsCollection.get();
      return snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all cars: $e');
      return [];
    }
  }

  // Stream all cars - simplified without ordering
  Stream<List<CarModel>> carsStream() {
    return _carsCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // Get car by ID
  Future<CarModel?> getCarById(String carId) async {
    try {
      final doc = await _carsCollection.doc(carId).get();
      if (!doc.exists) return null;
      return CarModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error getting car by ID: $e');
      return null;
    }
  }

  // Get cars by category - simplified query
  Future<List<CarModel>> getCarsByCategory(String category) async {
    try {
      final snapshot = await _carsCollection
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data(), doc.id))
          .where((car) => car.isAvailable)
          .toList();
    } catch (e) {
      print('Error getting cars by category: $e');
      return [];
    }
  }

  // Get featured cars - simplified to just get all available cars
  Future<List<CarModel>> getFeaturedCars({int limit = 5}) async {
    try {
      final snapshot = await _carsCollection.get();
      final cars = snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data(), doc.id))
          .where((car) => car.isAvailable)
          .toList();
      // Sort by rating in memory to avoid index requirement
      cars.sort((a, b) => b.rating.compareTo(a.rating));
      return cars.take(limit).toList();
    } catch (e) {
      print('Error getting featured cars: $e');
      return [];
    }
  }

  // Get recommended cars - simplified
  Future<List<CarModel>> getRecommendedCars({int limit = 10}) async {
    try {
      final snapshot = await _carsCollection.get();
      final cars = snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data(), doc.id))
          .where((car) => car.isAvailable)
          .toList();
      // Sort by review count in memory to avoid index requirement
      cars.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      return cars.take(limit).toList();
    } catch (e) {
      print('Error getting recommended cars: $e');
      return [];
    }
  }

  // Search cars
  Future<List<CarModel>> searchCars(String query) async {
    try {
      final queryLower = query.toLowerCase();
      final snapshot = await _carsCollection.get();

      return snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data(), doc.id))
          .where(
            (car) =>
                car.isAvailable &&
                (car.name.toLowerCase().contains(queryLower) ||
                    car.brand.toLowerCase().contains(queryLower) ||
                    car.category.toLowerCase().contains(queryLower)),
          )
          .toList();
    } catch (e) {
      print('Error searching cars: $e');
      return [];
    }
  }

  // Admin: Add car
  Future<String> addCar(CarModel car) async {
    final docRef = await _carsCollection.add(car.toMap());
    return docRef.id;
  }

  // Admin: Update car
  Future<void> updateCar(CarModel car) async {
    await _carsCollection.doc(car.id).update(car.toMap());
  }

  // Admin: Delete car
  Future<void> deleteCar(String carId) async {
    await _carsCollection.doc(carId).delete();
  }

  // Upload car images
  Future<List<String>> uploadCarImages(String carId, List<File> files) async {
    final List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final ref = _storage.ref().child('cars/$carId/image_$i.jpg');
      await ref.putFile(files[i]);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  // Update car rating
  Future<void> updateCarRating(
    String carId,
    double newRating,
    int newReviewCount,
  ) async {
    await _carsCollection.doc(carId).update({
      'rating': newRating,
      'reviewCount': newReviewCount,
    });
  }

  // Stream cars by owner - simplified
  Stream<List<CarModel>> carsByOwnerStream(String ownerId) {
    return _carsCollection
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CarModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
