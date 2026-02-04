import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String carId;
  final String carName;
  final String carImage;
  final DateTime pickupDate;
  final DateTime dropDate;
  final String pickupLocation;
  final int totalDays;
  final double totalPrice;
  final String paymentMethod; // UPI, Card, Cash
  final String status; // pending, confirmed, cancelled, completed
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carName,
    required this.carImage,
    required this.pickupDate,
    required this.dropDate,
    required this.pickupLocation,
    required this.totalDays,
    required this.totalPrice,
    required this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookingModel(
      id: docId,
      userId: map['userId'] ?? '',
      carId: map['carId'] ?? '',
      carName: map['carName'] ?? '',
      carImage: map['carImage'] ?? '',
      pickupDate: (map['pickupDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dropDate: (map['dropDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickupLocation: map['pickupLocation'] ?? '',
      totalDays: map['totalDays'] ?? 0,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'carId': carId,
      'carName': carName,
      'carImage': carImage,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'dropDate': Timestamp.fromDate(dropDate),
      'pickupLocation': pickupLocation,
      'totalDays': totalDays,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? carId,
    String? carName,
    String? carImage,
    DateTime? pickupDate,
    DateTime? dropDate,
    String? pickupLocation,
    int? totalDays,
    double? totalPrice,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      carId: carId ?? this.carId,
      carName: carName ?? this.carName,
      carImage: carImage ?? this.carImage,
      pickupDate: pickupDate ?? this.pickupDate,
      dropDate: dropDate ?? this.dropDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      totalDays: totalDays ?? this.totalDays,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
