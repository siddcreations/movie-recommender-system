import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CinematicApp());
}

class CinematicApp extends StatelessWidget {
  const CinematicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinematic Matchmaker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090E17),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const MovieDashboard(),
    );
  }
}

class MovieDashboard extends StatefulWidget {
  const MovieDashboard({super.key});

  @override
  State<MovieDashboard> createState() => _MovieDashboardState();
}

class _MovieDashboardState extends State<MovieDashboard> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _recommendations = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _fetchMatches() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _recommendations = [];
    });

    final url = Uri.parse('http://127.0.0.1:8000/recommendations/$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _recommendations = data['data'];
          });
        } else {
          setState(() => _errorMessage = data['message'] ?? 'No match found.');
        }
      } else {
        setState(() => _errorMessage = 'Server disconnected.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Ensure your Python backend is running.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE50914).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover',
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Your next favorite film awaits.',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Glassmorphism Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            decoration: InputDecoration(
                              hintText: 'Type a movie (e.g., The Dark Knight)',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 20.0, right: 12.0),
                                child: Icon(Icons.search_rounded, color: Colors.white54, size: 28),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE50914)),
                                  onPressed: _fetchMatches,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            onSubmitted: (_) => _fetchMatches(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // State Management for Results
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFFE50914)),
                          ),
                        )
                      : _errorMessage.isNotEmpty
                          ? SizedBox(
                              height: 300,
                              child: Center(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                                ),
                              ),
                            )
                          : _recommendations.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 32.0, bottom: 40.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Top Matches',
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        height: 350,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: _recommendations.length,
                                          itemBuilder: (context, index) {
                                            final movie = _recommendations[index];
                                            return PremiumMovieCard(
                                              title: movie['title'],
                                              posterUrl: movie['poster_url'],
                                              delay: index * 100, // Staggered animation feel
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumMovieCard extends StatelessWidget {
  final String title;
  final String posterUrl;
  final int delay;

  const PremiumMovieCard({
    super.key,
    required this.title,
    required this.posterUrl,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF1A2232),
                        child: const Icon(Icons.movie_creation_rounded, color: Colors.white24, size: 50),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFF1A2232),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white24),
                          ),
                        );
                      },
                    ),
                    // Inner shadow gradient for premium depth
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}