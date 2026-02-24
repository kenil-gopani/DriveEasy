import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedData {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // ────────────────────────────────────────────────────────────
  //  Clear ALL existing cars from Firestore
  // ────────────────────────────────────────────────────────────
  static Future<String> clearAllCars() async {
    final snapshot = await _firestore.collection('cars').get();
    if (snapshot.docs.isEmpty) return 'ℹ️ No cars found to delete.';

    // Firestore batch limit = 500
    final batches = <WriteBatch>[];
    WriteBatch batch = _firestore.batch();
    int count = 0;

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;
      if (count == 500) {
        batches.add(batch);
        batch = _firestore.batch();
        count = 0;
      }
    }
    if (count > 0) batches.add(batch);

    for (final b in batches) {
      await b.commit();
    }
    return '🗑️ Deleted ${snapshot.docs.length} cars.';
  }

  // ────────────────────────────────────────────────────────────
  //  Build 25 luxury cars (₹50 Lakh+)
  //  Each car has 2–3 real Unsplash photo URLs matching the car
  // ────────────────────────────────────────────────────────────
  static List<Map<String, dynamic>> buildCars(String ownerId) => [
    // ── 1. Lamborghini Huracán EVO ──────────────────────────
    {
      'name': 'Lamborghini Huracán EVO',
      'brand': 'Lamborghini',
      'category': 'Supercar',
      'description':
          'The Lamborghini Huracán EVO is a naturally-aspirated V10 masterpiece. '
          '0–100 km/h in 2.9 s, 640 hp, rear-wheel steering and Lamborghini '
          'Dinamica Veicolo Integrata (LDVI) make it one of the most dynamic '
          'supercars ever built.',
      'pricePerDay': 55000.0,
      'images': [
        'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1600712242805-5f78671b24da?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 2,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.0,
      'engineCC': 5204,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 4.9,
      'reviewCount': 38,
      'features': [
        'V10 Naturally Aspirated',
        'Launch Control',
        'Carbon Ceramic Brakes',
        'Lamborghini Active Aerodynamics',
        'Sport Exhaust',
        'Bose Premium Audio',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 2. Ferrari F8 Tributo ───────────────────────────────
    {
      'name': 'Ferrari F8 Tributo',
      'brand': 'Ferrari',
      'category': 'Supercar',
      'description':
          'A tribute to Ferrari\'s most powerful V8 engine ever. '
          '720 hp twin-turbo V8, 0–100 km/h in 2.9 s, top speed 340 km/h. '
          'The F8 Tributo carries the Soul of the 488 GTB to new heights.',
      'pricePerDay': 60000.0,
      'images': [
        'https://images.unsplash.com/photo-1583121274602-3e2820c69888?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1592198084033-aade902d1aae?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1558981359-219d6364c9c8?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 2,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 7.5,
      'engineCC': 3902,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 5.0,
      'reviewCount': 44,
      'features': [
        'Twin-Turbo V8',
        'Ferrari Side Slip Control',
        'Carbon Fibre Body Kit',
        'Racing Seats',
        'Ferrari Telemetry',
        'Magneride Suspension',
      ],
      'location': 'Delhi, NCR',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 3. Rolls-Royce Ghost ────────────────────────────────
    {
      'name': 'Rolls-Royce Ghost',
      'brand': 'Rolls-Royce',
      'category': 'Ultra Luxury',
      'description':
          'The Rolls-Royce Ghost is the most technologically advanced '
          'Rolls-Royce ever made. Planar suspension, satellite-aided '
          'transmission and the iconic Spirit of Ecstasy define true opulence.',
      'pricePerDay': 80000.0,
      'images': [
        'https://images.unsplash.com/photo-1631295868223-63265b40d9e4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1617531653332-bd46c16f7d22?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 6.5,
      'engineCC': 6749,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 5.0,
      'reviewCount': 21,
      'features': [
        '6.75L V12 Twin-Turbo',
        'Starlight Headliner',
        'Bespoke Audio by Rolls-Royce',
        'Planar Suspension',
        'Rear Theatre Config',
        'Picnic Tables',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 4. Porsche 911 Carrera S ────────────────────────────
    {
      'name': 'Porsche 911 Carrera S',
      'brand': 'Porsche',
      'category': 'Sports',
      'description':
          'Porsche 911 — an icon that needs no introduction. '
          '450 hp, rear-engine layout, 0–100 in 3.5 s. '
          'The 992-generation 911 Carrera S is sharper, smarter and '
          'more powerful than ever.',
      'pricePerDay': 35000.0,
      'images': [
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1611651338412-8403fa6e3599?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1583356322960-d6a2d2b2e3e6?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 4,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 10.5,
      'engineCC': 2981,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 4.9,
      'reviewCount': 57,
      'features': [
        'Rear-Engine Flat-6',
        'Sport Chrono Package',
        'PASM Adaptive Suspension',
        'Porsche Torque Vectoring',
        'Burmester Surround Sound',
        'Night Vision Assist',
      ],
      'location': 'Pune, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 5. Bentley Continental GT ───────────────────────────
    {
      'name': 'Bentley Continental GT',
      'brand': 'Bentley',
      'category': 'Luxury GT',
      'description':
          'The Bentley Continental GT is the definitive luxury grand tourer. '
          'W12 or V8 options, handcrafted British interior with diamond-quilted '
          'leather, rotating dashboard display. Pure Bentley.',
      'pricePerDay': 65000.0,
      'images': [
        'https://images.unsplash.com/photo-1617469767612-2d9c0c7b5beb?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1619405399517-d7fce0f13302?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1621415813738-e9fd7e5f1e66?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 4,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.0,
      'engineCC': 5950,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 4.9,
      'reviewCount': 29,
      'features': [
        'W12 Twin-Turbo 635 hp',
        'Rotating Dashboard Display',
        'Diamond-Stitched Leather',
        'Naim Audio System',
        'All-Wheel Drive',
        'Air Suspension',
      ],
      'location': 'Bangalore, Karnataka',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 6. Mercedes-AMG G 63 ────────────────────────────────
    {
      'name': 'Mercedes-AMG G 63',
      'brand': 'Mercedes-Benz',
      'category': 'SUV',
      'description':
          'The AMG G 63 is a legend. 585 hp handcrafted V8 biturbo, '
          '3 locking differentials, 0–100 in 4.5 s inside a body that\'s '
          'barely changed since 1979 — because it was perfect then.',
      'pricePerDay': 45000.0,
      'images': [
        'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1617623009780-14d71f07b3e3?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1563720223523-d4a90b6e5d8c?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 6.8,
      'engineCC': 3982,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.8,
      'reviewCount': 63,
      'features': [
        'AMG 4.0L V8 Biturbo',
        '3 Locking Differentials',
        'AMG Performance Exhaust',
        'Burmester Surround Sound',
        'Heated/Ventilated Seats',
        'AMG Ride Control',
      ],
      'location': 'Delhi, NCR',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 7. BMW M5 Competition ───────────────────────────────
    {
      'name': 'BMW M5 Competition',
      'brand': 'BMW',
      'category': 'Sports Sedan',
      'description':
          '625 hp M TwinPower Turbo V8, 0–100 in 3.3 s. '
          'The BMW M5 Competition is the world\'s most powerful '
          'production BMW — a super-saloon that dominates every road.',
      'pricePerDay': 30000.0,
      'images': [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1625247811671-d5e2a8b8e2cc?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 9.5,
      'engineCC': 4395,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.8,
      'reviewCount': 74,
      'features': [
        'S63 V8 625 hp',
        'M xDrive AWD',
        'Active M Differential',
        'Carbon Ceramic Brakes',
        'Harman Kardon Audio',
        'Launch Control',
      ],
      'location': 'Hyderabad, Telangana',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 8. Audi R8 V10 Performance ──────────────────────────
    {
      'name': 'Audi R8 V10 Performance',
      'brand': 'Audi',
      'category': 'Supercar',
      'description':
          '620 hp naturally-aspirated V10, 0–100 in 3.1 s, top speed 330 km/h. '
          'The Audi R8 is the only everyday supercar with a mid-mounted '
          'V10 and Quattro all-wheel drive.',
      'pricePerDay': 50000.0,
      'images': [
        'https://images.unsplash.com/photo-1603386329225-868f9b1ee6c9?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1514867644123-6385d58d3cd4?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 2,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 7.8,
      'engineCC': 5204,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 4.9,
      'reviewCount': 41,
      'features': [
        'V10 620 hp Naturally Aspirated',
        'Mid-Engine Layout',
        'Quattro AWD',
        'Magnetic Ride Suspension',
        'Bang & Olufsen 3D Audio',
        'Virtual Cockpit Plus',
      ],
      'location': 'Chennai, Tamil Nadu',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 9. McLaren 720S ─────────────────────────────────────
    {
      'name': 'McLaren 720S',
      'brand': 'McLaren',
      'category': 'Supercar',
      'description':
          '720 hp twin-turbo V8, 0–100 in 2.9 s, top speed 341 km/h. '
          'The McLaren 720S with its dihedral doors and carbon fibre '
          'MonoCell II chassis is the most driver-focused supercar from Woking.',
      'pricePerDay': 70000.0,
      'images': [
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1570733577524-3a047079e80d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 2,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 7.5,
      'engineCC': 3994,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 5.0,
      'reviewCount': 26,
      'features': [
        'M840T 4.0L V8 Twin-Turbo',
        'Carbon Fibre MonoCell II',
        'Proactive Chassis Control II',
        'Dihedral Doors',
        'Bowers & Wilkins Audio',
        'Track Telemetry',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 10. Range Rover Autobiography ──────────────────────
    {
      'name': 'Range Rover Autobiography',
      'brand': 'Land Rover',
      'category': 'Luxury SUV',
      'description':
          'The Range Rover Autobiography is the pinnacle of luxury SUVs. '
          'Executive rear seating with airline-style recline, Meridian Signature '
          'Sound system and go-anywhere capability.',
      'pricePerDay': 40000.0,
      'images': [
        'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1569452563046-4f4e5c26c0e3?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.0,
      'engineCC': 4395,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.8,
      'reviewCount': 52,
      'features': [
        'SV696 V8 532 hp',
        'Terrain Response 2',
        'Executive Class Rear Seats',
        'Meridian Signature Sound',
        'Configurable Ambient Lighting',
        'Head-Up Display',
      ],
      'location': 'Bangalore, Karnataka',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 11. Lamborghini Urus ────────────────────────────────
    {
      'name': 'Lamborghini Urus',
      'brand': 'Lamborghini',
      'category': 'Luxury SUV',
      'description':
          'The world\'s first Super Sport Utility Vehicle. 650 hp V8 biturbo, '
          '0–100 in 3.6 s, top speed 305 km/h. The Urus combines Lamborghini '
          'DNA with everyday usability.',
      'pricePerDay': 48000.0,
      'images': [
        'https://images.unsplash.com/photo-1621135802920-133df287f89c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1580274455191-1c62238fa1c4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1583416750470-965b2707b355?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.5,
      'engineCC': 3996,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 4.9,
      'reviewCount': 47,
      'features': [
        'V8 Biturbo 650 hp',
        'ANIMA Driving Modes',
        'Torque Vectoring AWD',
        'Carbon Ceramic Brakes',
        'Bang & Olufsen 3D',
        'Lamborghini Lifestyle Pack',
      ],
      'location': 'Delhi, NCR',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 12. Mercedes-Benz S 580 ─────────────────────────────
    {
      'name': 'Mercedes-Benz S 580',
      'brand': 'Mercedes-Benz',
      'category': 'Ultra Luxury',
      'description':
          'The Mercedes-Benz S-Class is the reference for all luxury sedans. '
          '496 hp V8, E-Active body control, augmented reality HUD and '
          'the new MBUX Hyperscreen redefine automotive luxury.',
      'pricePerDay': 38000.0,
      'images': [
        'https://images.unsplash.com/photo-1618843479619-f3d0d81e4d10?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1616455579100-2ceaa4eb2d37?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 10.5,
      'engineCC': 3982,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.8,
      'reviewCount': 68,
      'features': [
        'V8 Biturbo 496 hp',
        'MBUX Hyperscreen',
        'E-Active Body Control',
        'Burmester 4D Audio',
        'AR Navigation HUD',
        'Rear Axle Steering',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 13. BMW 7 Series 760Li ──────────────────────────────
    {
      'name': 'BMW 760Li xDrive',
      'brand': 'BMW',
      'category': 'Ultra Luxury',
      'description':
          'The new BMW 7 Series with 544 hp V12, Swarovski crystal lights, '
          'Theatre Screen rear display, and an optional remote-controlled '
          'parking. The pinnacle of BMW luxury.',
      'pricePerDay': 35000.0,
      'images': [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1571987502227-9231b837d92a?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 9.0,
      'engineCC': 4395,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.7,
      'reviewCount': 43,
      'features': [
        'V8 544 hp',
        'Theatre Screen Rear',
        'Swarovski Crystal Lights',
        'Bowers & Wilkins Diamond',
        'Executive Lounge Seating',
        'Sky Lounge Roof',
      ],
      'location': 'Hyderabad, Telangana',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 14. Porsche Cayenne Turbo GT ────────────────────────
    {
      'name': 'Porsche Cayenne Turbo GT',
      'brand': 'Porsche',
      'category': 'Performance SUV',
      'description':
          '640 hp twin-turbo V8, 0–100 in 3.3 s — the fastest Cayenne ever. '
          'PASM Sport suspension, rear-axle steering, and ceramic composite '
          'brakes make this SUV faster than many sports cars.',
      'pricePerDay': 42000.0,
      'images': [
        'https://images.unsplash.com/photo-1584345604476-8ec5f82d5291?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1571987502227-9231b837d92a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1559416523-140ddc3d238c?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.5,
      'engineCC': 3996,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.8,
      'reviewCount': 35,
      'features': [
        'Turbo GT 640 hp V8',
        'PASM Sport Suspension',
        'Rear-Axle Steering',
        'Carbon Ceramic Brakes',
        'Sport Chrono Package',
        'Burmester 3D Surround',
      ],
      'location': 'Pune, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 15. Aston Martin Vantage ────────────────────────────
    {
      'name': 'Aston Martin Vantage',
      'brand': 'Aston Martin',
      'category': 'Sports',
      'description':
          '503 hp AMG-sourced twin-turbo V8, 0–100 in 3.6 s. '
          'The Aston Martin Vantage is a pure British sports car with '
          'rear-wheel drive, a stunning silhouette and race-bred dynamics.',
      'pricePerDay': 52000.0,
      'images': [
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606152421802-db97b4c6a6d1?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1614200179396-2bdb77ebf81b?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 2,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 9.5,
      'engineCC': 3982,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.8,
      'reviewCount': 27,
      'features': [
        'AMG V8 Twin-Turbo 503 hp',
        'Rear-Wheel Drive',
        'Electronic Rear Differential',
        'Adaptive Damping',
        'Bang & Olufsen Audio',
        'Carbon Fibre Dash',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 16. Maserati GranTurismo ────────────────────────────
    {
      'name': 'Maserati GranTurismo Trofeo',
      'brand': 'Maserati',
      'category': 'Luxury GT',
      'description':
          '550 hp twin-turbo Nettuno V6 derived from the MC20 supercar. '
          'The all-new Maserati GranTurismo Trofeo is Italy\'s most exciting '
          'grand touring coupe with a dramatic 2+2 silhouette.',
      'pricePerDay': 45000.0,
      'images': [
        'https://images.unsplash.com/photo-1580274455191-1c62238fa1c4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 4,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 9.0,
      'engineCC': 2994,
      'year': 2024,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.7,
      'reviewCount': 19,
      'features': [
        'Nettuno V6 550 hp',
        'Active Sound Generator',
        'Sonus Faber Audio',
        'Carbon Fibre Interior',
        'Maserati Integrated Sensors',
        'Corsa Mode',
      ],
      'location': 'Bangalore, Karnataka',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 17. Jaguar F-Type R ─────────────────────────────────
    {
      'name': 'Jaguar F-Type R',
      'brand': 'Jaguar',
      'category': 'Sports',
      'description':
          '575 hp supercharged V8, 0–100 in 3.5 s. The Jaguar F-Type R '
          'is the most powerful production Jaguar outside of Formula E. '
          'Active sports exhaust, carbon ceramic brakes — pure drama.',
      'pricePerDay': 30000.0,
      'images': [
        'https://images.unsplash.com/photo-1601580394439-c7e6e2e20dde?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1521556933869-cb5a0bfaf1ac?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 2,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 9.0,
      'engineCC': 5000,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.7,
      'reviewCount': 33,
      'features': [
        'Supercharged V8 575 hp',
        'Active Exhaust System',
        'Carbon Ceramic Brakes',
        'All-Wheel Drive',
        'Adaptive Dynamics',
        'Meridian Sound System',
      ],
      'location': 'Chennai, Tamil Nadu',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 18. Land Rover Defender 110 V8 ─────────────────────
    {
      'name': 'Land Rover Defender 110 V8',
      'brand': 'Land Rover',
      'category': 'SUV',
      'description':
          '525 hp supercharged V8, 0–100 in 4.9 s in a true off-road icon. '
          'The Defender V8 is the fastest Defender ever, combining extreme '
          'capability with supercar-baiting performance.',
      'pricePerDay': 28000.0,
      'images': [
        'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1607853212498-ec956bb1f7ef?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.0,
      'engineCC': 5000,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.7,
      'reviewCount': 48,
      'features': [
        'Supercharged V8 525 hp',
        'Terrain Response 2',
        'Wade Sensing',
        'Air Suspension',
        'Meridian Sound',
        'ClearSight Pro',
      ],
      'location': 'Delhi, NCR',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 19. Ferrari Roma ────────────────────────────────────
    {
      'name': 'Ferrari Roma',
      'brand': 'Ferrari',
      'category': 'Luxury GT',
      'description':
          '620 hp twin-turbo V8, 0–100 in 3.4 s. The Ferrari Roma '
          'brings the convivial spirit of life in Rome to a new generation. '
          'A 2+ sports coupe with grand touring elegance.',
      'pricePerDay': 58000.0,
      'images': [
        'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1583121274602-3e2820c69888?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1592198084033-aade902d1aae?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 4,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.0,
      'engineCC': 3855,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 4.9,
      'reviewCount': 22,
      'features': [
        'V8 Twin-Turbo 620 hp',
        'Italian Design',
        '8-Speed DCT',
        'Ferrari e-Diff',
        'JBL Pro Audio',
        'GT HVAC',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 20. Rolls-Royce Cullinan ────────────────────────────
    {
      'name': 'Rolls-Royce Cullinan',
      'brand': 'Rolls-Royce',
      'category': 'Ultra Luxury SUV',
      'description':
          'The Rolls-Royce Cullinan — the world\'s most luxurious SUV. '
          '563 hp 6.75L V12, the Magic Carpet ride, bespoke interior and '
          'viewing suite make this the first Rolls-Royce to go truly off-road.',
      'pricePerDay': 95000.0,
      'images': [
        'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1631295868223-63265b40d9e4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1617531653332-bd46c16f7d22?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 5,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 6.0,
      'engineCC': 6749,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 5.0,
      'reviewCount': 14,
      'features': [
        '6.75L V12 563 hp',
        'Magic Carpet Suspension',
        'Starlight Headliner',
        'Viewing Suite',
        'Bespoke Trunk',
        'All-Terrain Modes',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 21. Mercedes-Benz GLS 600 Maybach ──────────────────
    {
      'name': 'Mercedes-Maybach GLS 600',
      'brand': 'Mercedes-Benz',
      'category': 'Ultra Luxury SUV',
      'description':
          'The Mercedes-Maybach GLS 600 with 557 hp V8, E-Active Body Control, '
          'chauffeur package and rear executive seats with adjustable '
          'footrests is the Rolls-Royce of SUVs.',
      'pricePerDay': 55000.0,
      'images': [
        'https://images.unsplash.com/photo-1618843479619-f3d0d81e4d10?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1606016159991-dfe4f2746ad5?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1550355291-bbee04a92027?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 4,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 8.5,
      'engineCC': 3982,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.9,
      'reviewCount': 18,
      'features': [
        'V8 Biturbo 557 hp',
        'E-Active Body Control',
        'Chauffeur Package',
        'Burmester 4D Audio',
        'Rear Fridge',
        'AAmbient Lighting 64-Color',
      ],
      'location': 'Delhi, NCR',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 22. BMW X7 M60i ─────────────────────────────────────
    {
      'name': 'BMW X7 M60i',
      'brand': 'BMW',
      'category': 'Luxury SUV',
      'description':
          '530 hp S68 V8 TwinPower Turbo, 0–100 in 4.7 s in a 7-seat luxury SUV. '
          'The BMW X7 M60i with split-screen headlights, panoramic sky lounge '
          'roof and Bowers & Wilkins Diamond audio is an SUV like no other.',
      'pricePerDay': 32000.0,
      'images': [
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1571987502227-9231b837d92a?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 7,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 9.5,
      'engineCC': 4395,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.7,
      'reviewCount': 36,
      'features': [
        'S68 V8 530 hp',
        'BMW xDrive AWD',
        'Sky Lounge Panorama Roof',
        'Bowers & Wilkins Diamond',
        '7-Seat Configuration',
        'Driving Assist Pro',
      ],
      'location': 'Bangalore, Karnataka',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 23. Porsche Panamera Turbo S ────────────────────────
    {
      'name': 'Porsche Panamera Turbo S',
      'brand': 'Porsche',
      'category': 'Sports Sedan',
      'description':
          '620 hp twin-turbo V8, 0–100 in 3.1 s. The Porsche Panamera Turbo S '
          'is the world\'s most powerful sports sedan — 4 doors, 4 seats, '
          'Porsche Active Suspension Management and Sport Chrono.',
      'pricePerDay': 44000.0,
      'images': [
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1611651338412-8403fa6e3599?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1584345604476-8ec5f82d5291?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 4,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 9.0,
      'engineCC': 3996,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.8,
      'reviewCount': 29,
      'features': [
        'V8 Twin-Turbo 620 hp',
        'Porsche Active Suspension',
        'Sport Chrono Package',
        'Rear-Axle Steering',
        'Burmester 3D Sound',
        '4WD Torque Vectoring',
      ],
      'location': 'Hyderabad, Telangana',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 24. Lexus LC 500 ────────────────────────────────────
    {
      'name': 'Lexus LC 500',
      'brand': 'Lexus',
      'category': 'Luxury GT',
      'description':
          '460 hp naturally-aspirated V8, 10-speed automatic. '
          'The Lexus LC 500 with its dramatic spindle grille, Mark Levinson '
          'audio and precision-crafted interior is a Japanese GT masterpiece.',
      'pricePerDay': 26000.0,
      'images': [
        'https://images.unsplash.com/photo-1621135802920-133df287f89c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1614162692292-7ac56d7f7f1e?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1580274455191-1c62238fa1c4?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 4,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 10.5,
      'engineCC': 4969,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': false,
      'rating': 4.7,
      'reviewCount': 22,
      'features': [
        'V8 NA 460 hp',
        'Mark Levinson 13-Speaker',
        '10-Speed Automatic',
        'Adaptive Variable Suspension',
        'HUD Display',
        'Lexus Driving Signature',
      ],
      'location': 'Chennai, Tamil Nadu',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },

    // ── 25. Bugatti Chiron ──────────────────────────────────
    {
      'name': 'Bugatti Chiron Sport',
      'brand': 'Bugatti',
      'category': 'Hypercar',
      'description':
          '1479 hp quad-turbocharged 8.0L W16. The Bugatti Chiron Sport is '
          'one of the fastest production cars ever made — top speed of '
          '420 km/h, 0–100 in 2.4 s. An experience beyond compare.',
      'pricePerDay': 150000.0,
      'images': [
        'https://images.unsplash.com/photo-1580274455191-1c62238fa1c4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1570733577524-3a047079e80d?auto=format&fit=crop&w=800&q=80',
      ],
      'seats': 2,
      'fuelType': 'Petrol',
      'transmission': 'Automatic',
      'mileage': 4.0,
      'engineCC': 7993,
      'year': 2023,
      'isAvailable': true,
      'isFeatured': true,
      'rating': 5.0,
      'reviewCount': 7,
      'features': [
        'W16 Quad-Turbo 1479 hp',
        'Carbon Fibre Monocoque',
        'Aerodynamic Active Body',
        'Bespoke Interior',
        'Chiron Sport Handling Mode',
        'Speed Limiter Key',
      ],
      'location': 'Mumbai, Maharashtra',
      'ownerId': ownerId,
      'createdAt': Timestamp.now(),
    },
  ];

  // ────────────────────────────────────────────────────────────
  //  Clear old cars, then seed 25 luxury cars
  // ────────────────────────────────────────────────────────────
  static Future<String> seedCarsForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return 'Error: No user logged in. Please log in first.';

    // Step 1 – delete ALL existing cars
    await clearAllCars();

    // Step 2 – seed fresh luxury fleet
    final cars = buildCars(user.uid);
    final batch = _firestore.batch();
    final carsRef = _firestore.collection('cars');

    for (final car in cars) {
      batch.set(carsRef.doc(), car);
    }
    await batch.commit();

    return '✅ ${cars.length} luxury cars seeded for ${user.email}';
  }
}
