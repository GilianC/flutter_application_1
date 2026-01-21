import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/movie.dart';

class MovieService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.watchmode.com/v1';

  // Récupère la clé API depuis les variables d'environnement
  static const String _apiKey = String.fromEnvironment(
    'WATCHMODE_API_KEY',
    defaultValue: '', // Valeur par défaut si la clé n'est pas fournie
  );

  Future<List<MovieListItem>> getMovies({int limit = 20}) async {
    debugPrint('🎬 Début getMovies - API Key: ${_apiKey.substring(0, 10)}...');
    
    // Vérifie que la clé API est bien fournie
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé API manquante ! Lance l\'app avec --dart-define=WATCHMODE_API_KEY=ta_clé'
      );
    }

    try {
      final url = '$_baseUrl/list-titles/';
      debugPrint('🌐 URL: $url');
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'apiKey': _apiKey,
          'types': 'movie',
          'limit': limit,
        },
      );

      debugPrint('📡 Status code: ${response.statusCode}');
      debugPrint('📦 Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        final List<dynamic> titles = response.data['titles'];
        debugPrint('✅ Nombre de films reçus: ${titles.length}');
        return titles.map((json) => MovieListItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des films');
      }
    } catch (e) {
      debugPrint('❌ Erreur getMovies: $e');
      throw Exception('Erreur réseau : $e');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    debugPrint('🎬 Chargement détails film ID: $movieId');
    
    if (_apiKey.isEmpty) {
      throw Exception(
        'Clé API manquante ! Lance l\'app avec --dart-define=WATCHMODE_API_KEY=ta_clé'
      );
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/title/$movieId/details/',
        queryParameters: {
          'apiKey': _apiKey,
        },
      );

      debugPrint('📡 Détails film $movieId - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return Movie.fromJson(response.data);
      } else {
        throw Exception('Erreur lors du chargement des détails');
      }
    } catch (e) {
      debugPrint('❌ Erreur getMovieDetails($movieId): $e');
      throw Exception('Erreur réseau : $e');
    }
  }

  // Charge les films depuis le fichier JSON local
  Future<List<Movie>> loadLocalMovies() async {
    try {
      final String response = await rootBundle.loadString('assets/data/movies.json');
      final List<dynamic> data = json.decode(response);
      
      return data.asMap().entries.map((entry) {
        final index = entry.key;
        final json = entry.value;
        
        return Movie(
          id: index,
          title: json['title'] ?? 'Sans titre',
          plotOverview: json['description'] ?? 'Aucune description disponible',
          year: json['year'] ?? 0,
          poster: json['poster'],
          backdrop: null,
          userRating: 0.0,
          genreNames: [],
          trailer: json['trailer'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement du fichier JSON : $e');
    }
  }
}