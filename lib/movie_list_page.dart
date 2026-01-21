import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'service/movie_service.dart';

class MovieListPage extends StatefulWidget {
  final MovieService movieService;

  const MovieListPage({super.key, required this.movieService});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<Movie> movies = [];
  final Set<String> favorites = {};
  String searchQuery = '';
  String sortBy = 'titre'; // 'titre' ou 'annee'

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    final loadedMovies = await widget.movieService.loadLocalMovies();
    setState(() => movies = loadedMovies);
  }

  void toggleFavorite(String title) {
    setState(() {
      if (favorites.contains(title)) {
        favorites.remove(title); // Retire le favori
      } else {
        favorites.add(title); // Ajoute le favori
      }
    });
  }

  List<Movie> get filteredAndSortedMovies {
    // Filtrer par recherche
    var filtered = movies.where((movie) {
      return movie.title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Trier
    if (sortBy == 'titre') {
      filtered.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == 'annee') {
      filtered.sort((a, b) => b.year.compareTo(a.year)); // Plus récent en premier
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final displayedMovies = filteredAndSortedMovies;
    
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'MMI',
              style: TextStyle(
                color: Color(0xFFE50914),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'FILMS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Color(0xFFE50914), size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesPage(
                  favorites: favorites,
                  movies: movies,
                  toggleFavorite: toggleFavorite,
                ),
              ),
            ),
          ),
        ],
      ),
      body: movies.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE50914),
              ),
            )
          : Column(
              children: [
                // Barre de recherche et tri
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Barre de recherche
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un film...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFE50914)),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white54),
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Menu de tri
                      Row(
                        children: [
                          const Icon(Icons.sort, color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Trier par:',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: sortBy,
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: const Color(0xFF2A2A2A),
                                style: const TextStyle(color: Colors.white),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'titre',
                                    child: Text('Titre (A-Z)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'annee',
                                    child: Text('Année (récent)'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    sortBy = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Grille de films
                Expanded(
                  child: displayedMovies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.white38,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun film trouvé pour "$searchQuery"',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: displayedMovies.length,
                          itemBuilder: (context, index) => NetflixMovieCard(
                            movie: displayedMovies[index],
                            isFavorite: favorites.contains(displayedMovies[index].title),
                            onFavoriteTap: () => toggleFavorite(displayedMovies[index].title),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final Set<String> favorites;
  final List<Movie> movies;
  final Function(String) toggleFavorite;

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.movies,
    required this.toggleFavorite,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    // Filtre les films pour ne garder que les favoris
    final favoriteMovies = widget.movies
        .where((movie) => widget.favorites.contains(movie.title))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text(
          'MES FAVORIS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favoriteMovies.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Color(0xFFE50914),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun favori pour le moment',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez des films à vos favoris !',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                return NetflixMovieCard(
                  movie: movie,
                  isFavorite: true,
                  onFavoriteTap: () {
                    setState(() {
                      widget.toggleFavorite(movie.title);
                    });
                  },
                  showDeleteIcon: true,
                );
              },
            ),
    );
  }
}

class NetflixMovieCard extends StatefulWidget {
  final Movie movie;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final bool showDeleteIcon;

  const NetflixMovieCard({
    super.key,
    required this.movie,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.showDeleteIcon = false,
  });

  @override
  State<NetflixMovieCard> createState() => _NetflixMovieCardState();
}

class _NetflixMovieCardState extends State<NetflixMovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFavoriteTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onFavoriteTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailPage(
            movie: widget.movie,
            isFavorite: widget.isFavorite,
            onFavoriteTap: widget.onFavoriteTap,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        child: Stack(
          children: [
            // Image du film
            Hero(
              tag: 'movie-poster-${widget.movie.title}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.movie.poster,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1F1F1F),
                      child: const Center(
                        child: Icon(
                          Icons.movie,
                          color: Colors.white38,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Gradient overlay pour meilleure lisibilité
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Bouton favori en haut à droite avec animation
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: IconButton(
                    icon: Icon(
                      widget.showDeleteIcon
                          ? Icons.delete
                          : (widget.isFavorite ? Icons.favorite : Icons.favorite_border),
                      color: const Color(0xFFE50914),
                      size: 24,
                    ),
                    onPressed: _handleFavoriteTap,
                  ),
                ),
              ),
            ),
            // Titre en bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.movie.year}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final IconData? favoriteIcon;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.favoriteIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(
              movie: movie,
              isFavorite: isFavorite,
              onFavoriteTap: onFavoriteTap,
            ),
          ),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              movie.poster,
              width: 50,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 75,
                  color: Colors.grey,
                  child: const Icon(Icons.error, color: Colors.white),
                );
              },
            ),
          ),
          title: Text(movie.title),
          subtitle: Text('${movie.year}'),
          trailing: IconButton(
            icon: Icon(
              favoriteIcon ?? (isFavorite ? Icons.favorite : Icons.favorite_border),
              color: isFavorite && favoriteIcon == null ? Colors.red : null,
            ),
            onPressed: onFavoriteTap,
          ),
        ),
      ),
    );
  }
}
class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final bool initialIsFavorite;
  final VoidCallback onFavoriteTap;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required bool isFavorite,
    required this.onFavoriteTap,
  }) : initialIsFavorite = isFavorite;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialIsFavorite;
  }

  void _toggleFavorite() {
    setState(() => isFavorite = !isFavorite);
    widget.onFavoriteTap();
  }

  Future<void> _launchTrailer() async {
    final trailerUrl = widget.movie.trailer;
    if (trailerUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun trailer disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.parse(trailerUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Ouvre dans l'app YouTube ou navigateur
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le trailer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: CustomScrollView(
        slivers: [
          // AppBar avec image de fond
          SliverAppBar(
            expandedHeight: 500,
            pinned: true,
            backgroundColor: const Color(0xFF141414),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.movie.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF1F1F1F),
                        child: const Icon(Icons.movie, size: 100, color: Colors.white38),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF141414).withOpacity(0.7),
                          const Color(0xFF141414),
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFE50914),
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Année et réalisateur
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.movie.year}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      const Icon(Icons.movie_filter, color: Colors.white54, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.movie.realisateur,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bouton Play - Trailer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchTrailer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        'Regarder la bande-annonce',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Info trailer
                  if (widget.movie.trailer.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.youtube_searched_for, color: Color(0xFFE50914), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Ouvre dans YouTube',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Synopsis
                  Text(
                    widget.movie.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}