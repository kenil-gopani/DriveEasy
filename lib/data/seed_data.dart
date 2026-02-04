// Sample Data Seeding Script for RentCarPro
// Run this once to populate your Firestore with demo data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Sample car data with realistic images from Unsplash
class SeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sample cars data
  static final List<Map<String, dynamic>> sampleCars = [
    {
      'name': 'Toyota Fortuner',
      'brand': 'Toyota',
      'category': 'SUV',
      'pricePerDay': 150.0,
      'images': [
        'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800',
        'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
      ],
      'seats': 7,
      'fuelType': 'Diesel',
      'transmission': 'Automatic',
      'mileage': '12 km/l',
      'rating': 4.8,
      'reviewCount': 24,
      'isAvailable': true,
      'description':
          'The Toyota Fortuner is a rugged and reliable SUV perfect for family adventures and off-road excursions. With its powerful engine and spacious interior, it offers comfort and capability in one package.',
      'features': [
        'Cruise Control',
        'Bluetooth',
        'Backup Camera',
        'Leather Seats',
        'Sunroof',
        'Navigation',
      ],
      'pickupLocations': [
        'Airport Terminal 1',
        'Downtown Office',
        'Mall Parking Lot',
      ],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Honda City',
      'brand': 'Honda',
      'category': 'Sedan',
      'pricePerDay': 75.0,
      'images': [
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800',
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': '18 km/l',
      'rating': 4.5,
      'reviewCount': 45,
      'isAvailable': true,
      'description':
          'The Honda City is a stylish and fuel-efficient sedan that combines comfort with performance. Ideal for city driving and long highway trips alike.',
      'features': [
        'Apple CarPlay',
        'Android Auto',
        'Keyless Entry',
        'Push Button Start',
        'Alloy Wheels',
      ],
      'pickupLocations': [
        'Central Station',
        'Airport Terminal 2',
        'Business District',
      ],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Maruti Swift',
      'brand': 'Maruti Suzuki',
      'category': 'Hatchback',
      'pricePerDay': 45.0,
      'images': [
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800',
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Manual',
      'mileage': '22 km/l',
      'rating': 4.3,
      'reviewCount': 89,
      'isAvailable': true,
      'description':
          'The Maruti Swift is a compact and agile hatchback perfect for navigating city streets. With excellent fuel economy and a zippy engine, it\'s the ideal choice for urban commuters.',
      'features': [
        'Touchscreen Infotainment',
        'ABS',
        'Dual Airbags',
        'Power Windows',
        'Central Locking',
      ],
      'pickupLocations': ['Railway Station', 'City Center', 'Shopping Complex'],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Mercedes-Benz E-Class',
      'brand': 'Mercedes-Benz',
      'category': 'Luxury',
      'pricePerDay': 350.0,
      'images': [
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
        'https://images.unsplash.com/photo-1617531653332-bd46c24f2068?w=800',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': '14 km/l',
      'rating': 4.9,
      'reviewCount': 18,
      'isAvailable': true,
      'description':
          'The Mercedes-Benz E-Class represents the pinnacle of luxury and sophistication. With its elegant design, advanced technology, and supreme comfort, it\'s perfect for VIPs and special occasions.',
      'features': [
        'Premium Sound System',
        'Massage Seats',
        'Panoramic Sunroof',
        'Ambient Lighting',
        'Advanced Safety Pack',
        'Wireless Charging',
      ],
      'pickupLocations': [
        'VIP Lounge',
        'Five Star Hotel',
        'Private Jet Terminal',
      ],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Hyundai Creta',
      'brand': 'Hyundai',
      'category': 'SUV',
      'pricePerDay': 100.0,
      'images': [
        'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800',
        'https://images.unsplash.com/photo-1489824904134-891ab64532f1?w=800',
      ],
      'seats': 5,
      'fuelType': 'Diesel',
      'transmission': 'Automatic',
      'mileage': '16 km/l',
      'rating': 4.6,
      'reviewCount': 56,
      'isAvailable': true,
      'description':
          'The Hyundai Creta is a compact SUV that offers great value for money. It combines SUV practicality with sedan-like driving dynamics for a versatile driving experience.',
      'features': [
        'Ventilated Seats',
        'Bose Audio',
        '360 Camera',
        'Wireless Charging',
        'Smart Key',
      ],
      'pickupLocations': ['Airport', 'Tech Park', 'Convention Center'],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'BMW 3 Series',
      'brand': 'BMW',
      'category': 'Luxury',
      'pricePerDay': 280.0,
      'images': [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
        'https://images.unsplash.com/photo-1556189250-72ba954cfc2b?w=800',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': '15 km/l',
      'rating': 4.7,
      'reviewCount': 32,
      'isAvailable': true,
      'description':
          'The BMW 3 Series is the ultimate driving machine. It combines sporty performance with refined luxury, delivering an exhilarating yet comfortable driving experience.',
      'features': [
        'iDrive System',
        'M Sport Package',
        'Harman Kardon Audio',
        'Sport Seats',
        'Head-up Display',
      ],
      'pickupLocations': ['Premium Showroom', 'Business Hotel', 'Golf Club'],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Tata Nexon EV',
      'brand': 'Tata',
      'category': 'SUV',
      'pricePerDay': 90.0,
      'images': [
        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=800',
        'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800',
      ],
      'seats': 5,
      'fuelType': 'Electric',
      'transmission': 'Automatic',
      'mileage': '312 km/charge',
      'rating': 4.4,
      'reviewCount': 28,
      'isAvailable': true,
      'description':
          'The Tata Nexon EV is an all-electric SUV that offers zero emissions and exciting performance. Perfect for eco-conscious drivers who don\'t want to compromise on style.',
      'features': [
        'Fast Charging',
        'Connected Car Tech',
        'Regenerative Braking',
        'EV Route Planner',
        'Ziptron Technology',
      ],
      'pickupLocations': [
        'Green Energy Hub',
        'Tech Campus',
        'EV Charging Station',
      ],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
    {
      'name': 'Ford Endeavour',
      'brand': 'Ford',
      'category': 'SUV',
      'pricePerDay': 180.0,
      'images': [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800',
        'https://images.unsplash.com/photo-1519244703995-f4e0900656b4?w=800',
      ],
      'seats': 7,
      'fuelType': 'Diesel',
      'transmission': 'Automatic',
      'mileage': '11 km/l',
      'rating': 4.7,
      'reviewCount': 41,
      'isAvailable': true,
      'description':
          'The Ford Endeavour is a full-size SUV built for adventure. With its commanding presence and exceptional off-road capability, it\'s ready for any terrain you throw at it.',
      'features': [
        'Terrain Management System',
        '4x4',
        'Tow Package',
        'Hill Descent Control',
        'Premium Leather',
      ],
      'pickupLocations': [
        'Adventure Base Camp',
        'Mountain Resort',
        'Beach Club',
      ],
      'ownerId': '',
      'createdAt': Timestamp.now(),
    },
  ];

  /// Seed cars into Firestore
  static Future<void> seedCars() async {
    final batch = _firestore.batch();
    final carsRef = _firestore.collection('cars');

    for (final car in sampleCars) {
      final docRef = carsRef.doc();
      batch.set(docRef, car);
    }

    await batch.commit();
    print('✅ Seeded ${sampleCars.length} cars successfully!');
  }

  /// Create an admin user
  static Future<void> createAdminUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = {
        'uid': credential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': '',
        'role': 'admin', // Admin role
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      await _firestore.collection('users').doc(credential.user!.uid).set(user);

      print('✅ Admin user created successfully!');
      print('   Email: $email');
      print('   Role: admin');
    } catch (e) {
      print('❌ Error creating admin user: $e');
    }
  }

  /// Seed sample notifications for a user
  static Future<void> seedNotifications(String userId) async {
    final notifications = [
      {
        'userId': userId,
        'title': 'Welcome to RentCarPro!',
        'message': 'Start exploring our wide range of cars available for rent.',
        'type': 'system',
        'isRead': false,
        'createdAt': Timestamp.now(),
      },
      {
        'userId': userId,
        'title': 'Special Offer!',
        'message':
            'Get 20% off on your first booking. Use code FIRST20 at checkout.',
        'type': 'promo',
        'isRead': false,
        'createdAt': Timestamp.now(),
      },
    ];

    final batch = _firestore.batch();
    for (final notification in notifications) {
      final docRef = _firestore.collection('notifications').doc();
      batch.set(docRef, notification);
    }
    await batch.commit();
    print('✅ Seeded notifications for user!');
  }

  /// Clear all data (use with caution!)
  static Future<void> clearAllData() async {
    // Delete cars
    final carsSnapshot = await _firestore.collection('cars').get();
    for (final doc in carsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete bookings
    final bookingsSnapshot = await _firestore.collection('bookings').get();
    for (final doc in bookingsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete reviews
    final reviewsSnapshot = await _firestore.collection('reviews').get();
    for (final doc in reviewsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete favorites
    final favoritesSnapshot = await _firestore.collection('favorites').get();
    for (final doc in favoritesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete notifications
    final notificationsSnapshot = await _firestore
        .collection('notifications')
        .get();
    for (final doc in notificationsSnapshot.docs) {
      await doc.reference.delete();
    }

    print('✅ All data cleared!');
  }
}

/*
===========================================
FIRESTORE SCHEMA REFERENCE
===========================================

Collection: users
------------------------------------------
{
  uid: string,
  name: string,
  email: string,
  phone: string,
  photoUrl: string,
  role: 'user' | 'owner' | 'admin',
  createdAt: timestamp,
  updatedAt: timestamp
}

Collection: cars
------------------------------------------
{
  name: string,
  brand: string,
  category: 'SUV' | 'Sedan' | 'Hatchback' | 'Luxury',
  pricePerDay: number,
  images: string[],
  seats: number,
  fuelType: 'Petrol' | 'Diesel' | 'Electric' | 'Hybrid',
  transmission: 'Manual' | 'Automatic',
  mileage: string,
  rating: number,
  reviewCount: number,
  isAvailable: boolean,
  description: string,
  features: string[],
  pickupLocations: string[],
  ownerId: string,
  createdAt: timestamp
}

Collection: bookings
------------------------------------------
{
  userId: string,
  carId: string,
  carName: string,
  carImage: string,
  pickupDate: timestamp,
  dropDate: timestamp,
  pickupLocation: string,
  totalDays: number,
  totalPrice: number,
  paymentMethod: 'UPI' | 'Card' | 'Cash',
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed',
  createdAt: timestamp
}

Collection: reviews
------------------------------------------
{
  userId: string,
  userName: string,
  userPhoto: string,
  carId: string,
  rating: number,
  comment: string,
  createdAt: timestamp
}

Collection: favorites
------------------------------------------
{
  userId: string,
  carId: string,
  createdAt: timestamp
}

Collection: notifications
------------------------------------------
{
  userId: string,
  title: string,
  message: string,
  type: 'booking' | 'system' | 'promo',
  isRead: boolean,
  createdAt: timestamp
}
*/
