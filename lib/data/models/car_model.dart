import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String id;
  final String name;
  final String brand;
  final String category; // SUV, Sedan, Hatchback, Luxury
  final int year;
  final double pricePerDay;
  final List<String> images;
  final int seats;
  final String fuelType; // Petrol, Diesel, Electric, Hybrid
  final String transmission; // Manual, Automatic
  final String mileage;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final String description;
  final List<String> features;
  final List<String> pickupLocations;
  final String ownerId; // ID of the user who listed this car
  final DateTime createdAt;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.year = 2024,
    required this.pricePerDay,
    required this.images,
    required this.seats,
    required this.fuelType,
    required this.transmission,
    required this.mileage,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    required this.description,
    required this.features,
    required this.pickupLocations,
    this.ownerId = '',
    required this.createdAt,
  });

  factory CarModel.fromMap(Map<String, dynamic> map, String docId) {
    return CarModel(
      id: docId,
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      year: map['year'] ?? 2024,
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      seats: map['seats'] ?? 4,
      fuelType: map['fuelType'] ?? 'Petrol',
      transmission: map['transmission'] ?? 'Manual',
      mileage: map['mileage'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      pickupLocations: List<String>.from(map['pickupLocations'] ?? []),
      ownerId: map['ownerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'category': category,
      'year': year,
      'pricePerDay': pricePerDay,
      'images': images,
      'seats': seats,
      'fuelType': fuelType,
      'transmission': transmission,
      'mileage': mileage,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'description': description,
      'features': features,
      'pickupLocations': pickupLocations,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CarModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    int? year,
    double? pricePerDay,
    List<String>? images,
    int? seats,
    String? fuelType,
    String? transmission,
    String? mileage,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    String? description,
    List<String>? features,
    List<String>? pickupLocations,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      year: year ?? this.year,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      images: images ?? this.images,
      seats: seats ?? this.seats,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      mileage: mileage ?? this.mileage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      features: features ?? this.features,
      pickupLocations: pickupLocations ?? this.pickupLocations,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get firstImage => images.isNotEmpty ? images.first : '';
}
