import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = '27e40f8908c43842c92ebf644063dbf9'; 

  // 1. Mengambil list movie yang sedang tayang di bioskop
  Future<List<Map<String, dynamic>>> getAllMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey'),
    );

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // 2. Mengambil list movie trending minggu ini
  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
    );

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // 3. Mengambil list movie populer
  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
    );

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // 4. Mengambil list movie berdasarkan pencarian
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
    );

    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }
}