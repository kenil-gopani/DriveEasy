import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/booking_datasource.dart';
import '../../data/models/booking_model.dart';
import 'auth_provider.dart';

// Datasource provider
final bookingDatasourceProvider = Provider((ref) => BookingDatasource());

// User bookings stream provider
final userBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final datasource = ref.watch(bookingDatasourceProvider);
  
  return user.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return datasource.userBookingsStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// All bookings stream provider (for admin)
final allBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final datasource = ref.watch(bookingDatasourceProvider);
  return datasource.allBookingsStream();
});

// Single booking provider
final bookingByIdProvider = FutureProvider.family<BookingModel?, String>((ref, bookingId) async {
  final datasource = ref.watch(bookingDatasourceProvider);
  return datasource.getBookingById(bookingId);
});

// Booking state for creating new booking
class BookingState {
  final String? carId;
  final String? carName;
  final String? carImage;
  final double? pricePerDay;
  final DateTime? pickupDate;
  final DateTime? dropDate;
  final String? pickupLocation;
  final String? paymentMethod;

  BookingState({
    this.carId,
    this.carName,
    this.carImage,
    this.pricePerDay,
    this.pickupDate,
    this.dropDate,
    this.pickupLocation,
    this.paymentMethod,
  });

  BookingState copyWith({
    String? carId,
    String? carName,
    String? carImage,
    double? pricePerDay,
    DateTime? pickupDate,
    DateTime? dropDate,
    String? pickupLocation,
    String? paymentMethod,
  }) {
    return BookingState(
      carId: carId ?? this.carId,
      carName: carName ?? this.carName,
      carImage: carImage ?? this.carImage,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      pickupDate: pickupDate ?? this.pickupDate,
      dropDate: dropDate ?? this.dropDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  int get totalDays {
    if (pickupDate == null || dropDate == null) return 0;
    return dropDate!.difference(pickupDate!).inDays + 1;
  }

  double get totalPrice {
    if (pricePerDay == null) return 0;
    return pricePerDay! * totalDays;
  }

  bool get isComplete {
    return carId != null &&
        pickupDate != null &&
        dropDate != null &&
        pickupLocation != null &&
        paymentMethod != null;
  }
}

// Booking notifier
class BookingNotifier extends StateNotifier<BookingState> {
  final BookingDatasource _datasource;

  BookingNotifier(this._datasource) : super(BookingState());

  void setCar({
    required String carId,
    required String carName,
    required String carImage,
    required double pricePerDay,
  }) {
    state = state.copyWith(
      carId: carId,
      carName: carName,
      carImage: carImage,
      pricePerDay: pricePerDay,
    );
  }

  void setDates({
    required DateTime pickupDate,
    required DateTime dropDate,
  }) {
    state = state.copyWith(
      pickupDate: pickupDate,
      dropDate: dropDate,
    );
  }

  void setPickupLocation(String location) {
    state = state.copyWith(pickupLocation: location);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<String> createBooking(String userId) async {
    if (!state.isComplete) {
      throw Exception('Booking details incomplete');
    }

    final booking = BookingModel(
      id: '',
      userId: userId,
      carId: state.carId!,
      carName: state.carName!,
      carImage: state.carImage!,
      pickupDate: state.pickupDate!,
      dropDate: state.dropDate!,
      pickupLocation: state.pickupLocation!,
      totalDays: state.totalDays,
      totalPrice: state.totalPrice,
      paymentMethod: state.paymentMethod!,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final bookingId = await _datasource.createBooking(booking);
    reset();
    return bookingId;
  }

  Future<void> cancelBooking(String bookingId) async {
    await _datasource.cancelBooking(bookingId);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _datasource.updateBookingStatus(bookingId, status);
  }

  void reset() {
    state = BookingState();
  }
}

final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.watch(bookingDatasourceProvider));
});

// Booking status list
const List<String> bookingStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
