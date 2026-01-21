import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Movie {
  // TODO: Déclare les 4 propriétés finales :
  // - title (String)
  // - year (int)
  // - poster (String)
  // - description (String)
  final String _title;
  final int _year;
  final String _poster;
  final String _description;
  final String _realisateur;
  final String _trailer;

  // TODO: Crée le constructeur avec des paramètres nommés required
  Movie({
    required String title,
    required int year,
    required String poster,
    required String description,
    required String realisateur,
    required String trailer,
  })  : _title = title,
        _year = year,
        _poster = poster,
        _description = description,
        _realisateur = realisateur,
        _trailer = trailer;

  // TODO: Crée un getter pour chaque propriété
  String get title => _title;
  int get year => _year;
  String get poster => _poster;
  String get description => _description;
  String get realisateur => _realisateur;
  String get trailer => _trailer;

  // TODO: Crée un factory constructor Movie.fromJson(Map<String, dynamic> json)
  // qui retourne une instance de Movie en lisant les valeurs du json
factory Movie.fromJson(Map<String, dynamic> json) {
  return Movie(
    title: json['title'],
    year: json['year'],
    poster: json['poster'],
    description: json['description'],
    realisateur: json['realisateur'] ?? 'Inconnu',
    trailer: json['trailer'] ?? '',
  );
}
}

class MovieService {
  Future<List<Movie>> loadLocalMovies() async {
    final data = await rootBundle.loadString('assets/data/movies.json');
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Movie.fromJson(json)).toList();
  }
}
