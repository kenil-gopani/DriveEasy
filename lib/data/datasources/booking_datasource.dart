import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  // Create booking
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _bookingsCollection.add(booking.toMap());
    return docRef.id;
  }

  // Get user bookings
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _bookingsCollection
        .where('userId', isEqualTo: userId)
        .get();
    final bookings = snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
    bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }

  // Stream user bookings
  Stream<List<BookingModel>> userBookingsStream(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort in memory to avoid Firestore composite index requirement
          bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return bookings;
        });
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    final doc = await _bookingsCollection.doc(bookingId).get();
    if (!doc.exists) return null;
    return BookingModel.fromMap(doc.data()!, doc.id);
  }

  // Admin: Get all bookings
  Future<List<BookingModel>> getAllBookings() async {
    final snapshot = await _bookingsCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Admin: Stream all bookings
  Stream<List<BookingModel>> allBookingsStream() {
    return _bookingsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingsCollection.doc(bookingId).update({'status': status});
  }

  // Update booking dates / location
  Future<void> updateBooking(
    String bookingId, {
    DateTime? pickupDate,
    DateTime? dropDate,
    String? pickupLocation,
    int? totalDays,
    double? totalPrice,
  }) async {
    final data = <String, dynamic>{};
    if (pickupDate != null) data['pickupDate'] = Timestamp.fromDate(pickupDate);
    if (dropDate != null) data['dropDate'] = Timestamp.fromDate(dropDate);
    if (pickupLocation != null) data['pickupLocation'] = pickupLocation;
    if (totalDays != null) data['totalDays'] = totalDays;
    if (totalPrice != null) data['totalPrice'] = totalPrice;
    if (data.isEmpty) return;
    await _bookingsCollection.doc(bookingId).update(data);
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await _bookingsCollection.doc(bookingId).update({'status': 'cancelled'});
  }

  // Get bookings by status
  Future<List<BookingModel>> getBookingsByStatus(String status) async {
    final snapshot = await _bookingsCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
