import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String userId;
  final String carId;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.createdAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map, String docId) {
    return FavoriteModel(
      id: docId,
      userId: map['userId'] ?? '',
      carId: map['carId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'carId': carId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
