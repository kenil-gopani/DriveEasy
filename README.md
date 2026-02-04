# RentCarPro - Complete Car Rental Mobile Application

A fully functional car rental mobile application built with Flutter and Firebase. This app includes both customer and admin functionality with a complete booking flow.

## 📱 Features

### Customer Features

#### Authentication Module
- ✅ Splash Screen with animations
- ✅ Onboarding Screens (3 pages)
- ✅ Sign Up (name, email, phone, password)
- ✅ Login (email/password)
- ✅ Phone OTP Authentication
- ✅ Forgot Password
- ✅ Logout with confirmation
- ✅ Auth guard (redirect based on auth state)

#### Home Module
- ✅ Search bar for finding cars
- ✅ Car categories (SUV, Sedan, Hatchback, Luxury)
- ✅ Featured cars slider with auto-play
- ✅ Recommended cars list
- ✅ Bottom navigation (Home, Bookings, Favorites, Profile)

#### Car Details
- ✅ Image carousel with pagination
- ✅ Price per day display
- ✅ Specifications (seats, fuel, transmission, mileage)
- ✅ Features list
- ✅ Pickup locations
- ✅ Add to favorites
- ✅ View reviews
- ✅ Book Now button

#### Booking Module
- ✅ Date selection (pickup & drop-off)
- ✅ Location selection
- ✅ Price calculation
- ✅ Payment method selection (UPI, Card, Cash)
- ✅ Booking confirmation
- ✅ Booking history with status
- ✅ Cancel pending bookings

#### Profile Module
- ✅ View profile
- ✅ Edit profile with photo upload
- ✅ Change password
- ✅ Settings page
- ✅ Logout

#### Extra Features
- ✅ Favorites (wishlist cars)
- ✅ Ratings & Reviews
- ✅ Notifications system
- ✅ Help & Support page
- ✅ Terms & Privacy page

### Admin Features
- ✅ Admin Dashboard with statistics
- ✅ Add new car with image upload
- ✅ Edit existing cars
- ✅ Delete cars
- ✅ View all bookings
- ✅ Update booking status
- ✅ Role-based access control

## 🏗️ Architecture

```
lib/
├── app/
│   ├── app.dart              # Main app widget
│   └── routes.dart           # GoRouter configuration
├── core/
│   ├── constants/
│   │   ├── app_colors.dart   # Color palette
│   │   └── app_strings.dart  # String constants
│   ├── theme/
│   │   └── app_theme.dart    # Material theme
│   ├── utils/
│   │   ├── helpers.dart      # Utility functions
│   │   └── validators.dart   # Form validators
│   └── widgets/
│       ├── car_card.dart     # Reusable car card
│       ├── custom_text_field.dart
│       ├── empty_state.dart
│       ├── loading_overlay.dart
│       └── primary_button.dart
├── data/
│   ├── datasources/
│   │   ├── auth_datasource.dart
│   │   ├── booking_datasource.dart
│   │   ├── car_datasource.dart
│   │   ├── notification_datasource.dart
│   │   └── user_datasource.dart
│   ├── models/
│   │   ├── booking_model.dart
│   │   ├── car_model.dart
│   │   ├── favorite_model.dart
│   │   ├── notification_model.dart
│   │   ├── review_model.dart
│   │   └── user_model.dart
│   └── seed_data.dart        # Demo data seeding
├── presentation/
│   ├── admin/
│   │   ├── add_edit_car_screen.dart
│   │   ├── admin_car_list_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   └── manage_bookings_screen.dart
│   ├── auth/
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── phone_login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── splash_screen.dart
│   ├── booking/
│   │   ├── booking_confirmation_screen.dart
│   │   ├── booking_history_screen.dart
│   │   └── booking_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   ├── home/
│   │   ├── car_details_screen.dart
│   │   ├── category_screen.dart
│   │   ├── home_screen.dart
│   │   └── search_screen.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   ├── payment/
│   │   └── payment_screen.dart
│   ├── profile/
│   │   ├── change_password_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── booking_provider.dart
│   │   ├── car_provider.dart
│   │   ├── favorites_provider.dart
│   │   ├── notification_provider.dart
│   │   └── user_provider.dart
│   ├── reviews/
│   │   └── reviews_screen.dart
│   └── support/
│       ├── help_support_screen.dart
│       └── terms_privacy_screen.dart
├── firebase_options.dart     # Firebase config (auto-generated)
└── main.dart                 # App entry point
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase CLI
- Node.js (for Firebase tools)

### Step 1: Clone and Install Dependencies

```bash
cd my_app
flutter pub get
```

### Step 2: Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project (e.g., "RentCarPro")
   - Enable Google Analytics (optional)

2. **Configure Firebase for Flutter**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

3. **Enable Firebase Services**

   **Authentication:**
   - Go to Firebase Console → Authentication
   - Click "Get Started"
   - Enable "Email/Password" provider
   - Enable "Phone" provider (optional)

   **Firestore Database:**
   - Go to Firebase Console → Firestore Database
   - Click "Create database"
   - Start in test mode (we'll add rules later)
   - Choose a region close to your users

   **Storage:**
   - Go to Firebase Console → Storage
   - Click "Get Started"
   - Start in test mode

4. **Deploy Security Rules**
   ```bash
   # Deploy Firestore rules
   firebase deploy --only firestore:rules
   
   # Deploy Storage rules
   firebase deploy --only storage
   ```

### Step 3: Create Admin User

Add sample data and create an admin user by modifying `main.dart` temporarily:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Uncomment to seed data (run once)
  // await SeedData.seedCars();
  // await SeedData.createAdminUser(
  //   email: 'admin@rentcarpro.com',
  //   password: 'Admin@123',
  //   name: 'Admin User',
  //   phone: '+1234567890',
  // );
  
  runApp(const ProviderScope(child: RentCarProApp()));
}
```

### Step 4: Run the App

```bash
# For Android
flutter run

# For iOS
cd ios && pod install && cd ..
flutter run

# For Web (limited support)
flutter run -d chrome
```

## 📊 Firestore Database Schema

### users
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "photoUrl": "string",
  "role": "user | owner | admin",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### cars
```json
{
  "name": "string",
  "brand": "string",
  "category": "SUV | Sedan | Hatchback | Luxury",
  "pricePerDay": "number",
  "images": ["string"],
  "seats": "number",
  "fuelType": "Petrol | Diesel | Electric | Hybrid",
  "transmission": "Manual | Automatic",
  "mileage": "string",
  "rating": "number",
  "reviewCount": "number",
  "isAvailable": "boolean",
  "description": "string",
  "features": ["string"],
  "pickupLocations": ["string"],
  "ownerId": "string",
  "createdAt": "timestamp"
}
```

### bookings
```json
{
  "userId": "string",
  "carId": "string",
  "carName": "string",
  "carImage": "string",
  "pickupDate": "timestamp",
  "dropDate": "timestamp",
  "pickupLocation": "string",
  "totalDays": "number",
  "totalPrice": "number",
  "paymentMethod": "UPI | Card | Cash",
  "status": "pending | confirmed | cancelled | completed",
  "createdAt": "timestamp"
}
```

### reviews
```json
{
  "userId": "string",
  "userName": "string",
  "userPhoto": "string",
  "carId": "string",
  "rating": "number",
  "comment": "string",
  "createdAt": "timestamp"
}
```

### favorites
```json
{
  "userId": "string",
  "carId": "string",
  "createdAt": "timestamp"
}
```

### notifications
```json
{
  "userId": "string",
  "title": "string",
  "message": "string",
  "type": "booking | system | promo",
  "isRead": "boolean",
  "createdAt": "timestamp"
}
```

## 🔒 Security Rules

Firestore security rules are defined in `firestore.rules`:
- Users can only read/write their own data
- Admins have full access to cars and bookings
- Cars are readable by all authenticated users
- Reviews are public but only owners can delete

Storage security rules are defined in `storage.rules`:
- Profile photos limited to 5MB
- Only authenticated users can upload
- Car images require admin access

## 📦 Dependencies

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.13.0
  firebase_auth: ^5.6.0
  cloud_firestore: ^5.6.6
  firebase_storage: ^12.4.5
  
  # State Management
  flutter_riverpod: ^2.6.1
  
  # Navigation
  go_router: ^14.8.1
  
  # UI Components
  google_fonts: ^6.2.1
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  carousel_slider: ^5.0.0
  smooth_page_indicator: ^1.2.0+3
  flutter_rating_bar: ^4.0.1
  
  # Forms
  flutter_form_builder: ^10.2.0
  form_builder_validators: ^11.1.0
  
  # Utils
  intl: any
  image_picker: ^1.1.2
  uuid: ^4.5.1
  fluttertoast: ^8.2.10
  shared_preferences: ^2.3.5
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

RentCarPro - Built with ❤️ using Flutter

---

For any questions or support, please open an issue on the repository.
