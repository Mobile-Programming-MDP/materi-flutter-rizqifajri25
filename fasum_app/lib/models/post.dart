import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? id;
  final String category;
  final String description;
  String? imageBase64;
  final String? latitude;
  final String? longitude;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String? userId;
  String? userFullName;

  Post({
    this.id,
    required this.category,
    required this.description,
    this.imageBase64,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.userFullName,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageBase64: data['image_base_64'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      userId: data['user_id'],
      userFullName: data['user_full_name'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'category': category,
      'description': description,
      'image_base_64': imageBase64,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_id': userId,
      'user_full_name': userFullName,
    };
  }
}