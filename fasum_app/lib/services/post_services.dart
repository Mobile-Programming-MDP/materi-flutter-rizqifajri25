import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fasum_app/models/post.dart';

class PostService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;

  static final CollectionReference _postsCollection =
      _database.collection('posts');

  static Future<void> addPost(Post post) async {
    await _postsCollection.add({
      'category': post.category,
      'description': post.description,
      'image_base_64': post.imageBase64,
      'latitude': post.latitude,
      'longitude': post.longitude,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'user_id': post.userId,
      'user_full_name': post.userFullName,
    });
  }
}