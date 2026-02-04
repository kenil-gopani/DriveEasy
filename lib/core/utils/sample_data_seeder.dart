/// Sample data for RentCarPro
/// Run this script to populate Firestore with initial data
///
/// Usage: Add this to your app and call seedSampleData() once

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/car_model.dart';

class SampleDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedSampleData() async {
    await _seedCars();
    print('Sample data seeded successfully!');
  }

  Future<void> _seedCars() async {
    final cars = [
      CarModel(
        id: '',
        name: 'Model X',
        brand: 'Tesla',
        category: 'SUV',
        pricePerDay: 120,
        images: [
          'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800',
          'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800',
        ],
        seats: 7,
        fuelType: 'Electric',
        transmission: 'Automatic',
        mileage: '340 km/charge',
        rating: 4.8,
        reviewCount: 127,
        isAvailable: true,
        description:
            'The Tesla Model X is a luxury all-electric SUV with falcon wing doors, advanced autopilot, and incredible acceleration. Perfect for families who want both sustainability and performance.',
        features: [
          'Autopilot',
          'Falcon Wing Doors',
          'Premium Audio',
          'Panoramic Windshield',
          'Heated Seats',
          'Full Self-Driving Capable',
        ],
        pickupLocations: [
          'Airport Terminal 1',
          'Downtown Office',
          'Central Station',
        ],
        createdAt: DateTime.now(),
      ),
      CarModel(
        id: '',
        name: 'Camry',
        brand: 'Toyota',
        category: 'Sedan',
        pricePerDay: 55,
        images: [
          'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800',
          'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=800',
        ],
        seats: 5,
        fuelType: 'Petrol',
        transmission: 'Automatic',
        mileage: '14 km/l',
        rating: 4.5,
        reviewCount: 89,
        isAvailable: true,
        description:
            'The Toyota Camry is a reliable mid-size sedan known for its comfort, fuel efficiency, and excellent safety ratings. Ideal for business trips and daily commuting.',
        features: [
          'Apple CarPlay',
          'Android Auto',
          'Lane Departure Alert',
          'Adaptive Cruise Control',
          'Wireless Charging',
        ],
        pickupLocations: ['Airport Terminal 2', 'Mall Parking', 'Hotel Zone'],
        createdAt: DateTime.now(),
      ),
      CarModel(
        id: '',
        name: 'Civic',
        brand: 'Honda',
        category: 'Sedan',
        pricePerDay: 45,
        images: [
          'https://images.unsplash.com/photo-1606611013016-969c19ba27bb?w=800',
        ],
        seats: 5,
        fuelType: 'Petrol',
        transmission: 'Manual',
        mileage: '16 km/l',
        rating: 4.3,
        reviewCount: 156,
        isAvailable: true,
        description:
            'The Honda Civic is a compact sedan that offers a perfect blend of sportiness, efficiency, and practicality. Great for city driving and weekend getaways.',
        features: [
          'Honda Sensing',
          'Apple CarPlay',
          'LED Headlights',
          'Sunroof',
          'Remote Start',
        ],
        pickupLocations: ['Airport', 'City Center', 'Suburban Office'],
        createdAt: DateTime.now(),
      ),
      CarModel(
        id: '',
        name: 'Polo',
        brand: 'Volkswagen',
        category: 'Hatchback',
        pricePerDay: 35,
        images: [
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800',
        ],
        seats: 5,
        fuelType: 'Diesel',
        transmission: 'Manual',
        mileage: '20 km/l',
        rating: 4.2,
        reviewCount: 78,
        isAvailable: true,
        description:
            'The Volkswagen Polo is a stylish and fuel-efficient hatchback, perfect for city driving. Compact yet spacious with German engineering quality.',
        features: [
          'Touchscreen Infotainment',
          'Parking Sensors',
          'Cruise Control',
          'Climate Control',
          'Alloy Wheels',
        ],
        pickupLocations: ['Airport', 'Train Station', 'University Area'],
        createdAt: DateTime.now(),
      ),
      CarModel(
        id: '',
        name: 'S-Class',
        brand: 'Mercedes-Benz',
        category: 'Luxury',
        pricePerDay: 250,
        images: [
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
          'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800',
        ],
        seats: 5,
        fuelType: 'Petrol',
        transmission: 'Automatic',
        mileage: '10 km/l',
        rating: 4.9,
        reviewCount: 45,
        isAvailable: true,
        description:
            'The Mercedes-Benz S-Class represents the pinnacle of luxury sedans. With state-of-the-art technology, supreme comfort, and prestigious presence, it\'s perfect for special occasions.',
        features: [
          'Massage Seats',
          'Burmester Audio',
          'Night Vision',
          'Air Suspension',
          'Ambient Lighting',
          'Rear Entertainment',
          'Fragrance System',
        ],
        pickupLocations: [
          'VIP Terminal',
          'Five Star Hotels',
          'Business District',
        ],
        createdAt: DateTime.now(),
      ),
      CarModel(
        id: '',
        name: 'Wrangler',
        brand: 'Jeep',
        category: 'SUV',
        pricePerDay: 95,
        images: [
          'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
        ],
        seats: 5,
        fuelType: 'Petrol',
        transmission: 'Automatic',
        mileage: '8 km/l',
        rating: 4.6,
        reviewCount: 112,
        isAvailable: true,
        description:
            'The Jeep Wrangler is an iconic off-road vehicle built for adventure. With its rugged design and 4x4 capability, it\'s ready for any terrain.',
        features: [
          '4x4 Drive',
          'Removable Doors',
          'Fold-Down Windshield',
          'All-Terrain Tires',
          'Trail Rated',
          'Waterproof Interior',
        ],
        pickupLocations: ['Adventure Base Camp', 'Mountain Resort', 'Airport'],
        createdAt: DateTime.now(),
      ),
      CarModel(
        id: '',
        name: 'Mustang',
        brand: 'Ford',
        category: 'Luxury',
        pricePerDay: 180,
        images: [
          'https://images.unsplash.com/photo-1584345604476-8ec5f82d718c?w=800',
          'https://images.unsplash.com/photo-1547744152-14d985cb937f?w=800',
        ],
        seats: 4,
        fuelType: 'Petrol',
        transmission: 'Automatic',
        mileage: '9 km/l',
        rating: 4.7,
        reviewCount: 93,
        isAvailable: true,
        description:
            'The Ford Mustang is an American muscle car icon. With its powerful V8 engine and classic design, it delivers an exhilarating driving experience.',
        features: [
          'V8 Engine',
          'Premium Sound',
          'Track Apps',
          'Launch Control',
          'MagneRide Suspension',
          'Recaro Seats',
        ],
        pickupLocations: [
          'Luxury Car Center',
          'Beach Front',
          'Downtown Showroom',
        ],
        createdAt: DateTime.now(),
      ),
      CarModel(
        id: '',
        name: 'Swift',
        brand: 'Maruti Suzuki',
        category: 'Hatchback',
        pricePerDay: 28,
        images: [
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
        ],
        seats: 5,
        fuelType: 'Petrol',
        transmission: 'Manual',
        mileage: '22 km/l',
        rating: 4.1,
        reviewCount: 234,
        isAvailable: true,
        description:
            'The Maruti Suzuki Swift is India\'s favorite hatchback. Sporty, fuel-efficient, and easy to drive, it\'s perfect for city navigation.',
        features: [
          'SmartPlay Infotainment',
          'Auto Climate',
          'Push Start',
          'LED DRLs',
          'Dual Airbags',
        ],
        pickupLocations: ['City Hub', 'Metro Station', 'Shopping Complex'],
        createdAt: DateTime.now(),
      ),
    ];

    final batch = _firestore.batch();
    for (final car in cars) {
      final docRef = _firestore.collection('cars').doc();
      batch.set(docRef, car.toMap());
    }
    await batch.commit();
  }
}
