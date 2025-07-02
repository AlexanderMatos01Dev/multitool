import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  Future<void> _fetchNews() async {
    try {
      const apiUrl = 'https://kinsta.com/wp-json/wp/v2/posts?_embed&per_page=3';
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _posts = data);
      } else {
        setState(() => _errorMessage = 'Error al cargar noticias: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias WordPress'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNews,
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(_errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchNews,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text('No se encontraron noticias', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, index) => const SizedBox(height: 24),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final title = post['title']['rendered'] ?? 'Sin título';
        final excerpt = _cleanExcerpt(post['excerpt']['rendered']);
        final link = post['link'] ?? '';
        final featuredImage = _getFeaturedImage(post);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo del sitio + imagen destacada
              Stack(
                children: [
                  if (featuredImage != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CachedNetworkImage(
                        imageUrl: featuredImage,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                    ),

                  // Logo de WordPress
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'WP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Contenido de la noticia
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titular
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Resumen
                    Text(
                      excerpt,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón para visitar
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(link),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Visitar noticia'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _cleanExcerpt(String htmlExcerpt) {
    // Eliminar etiquetas HTML
    String cleanText = htmlExcerpt.replaceAll(RegExp(r'<[^>]*>'), '');
    // Reemplazar entidades HTML
    cleanText = cleanText.replaceAll('&nbsp;', ' ');
    cleanText = cleanText.replaceAll('&#8217;', "'");
    cleanText = cleanText.replaceAll('&amp;', '&');
    cleanText = cleanText.replaceAll('&hellip;', '...');
    // Eliminar espacios extra
    return cleanText.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _getFeaturedImage(dynamic post) {
    try {
      if (post['_embedded'] != null &&
          post['_embedded']['wp:featuredmedia'] != null &&
          post['_embedded']['wp:featuredmedia'][0]['source_url'] != null) {
        return post['_embedded']['wp:featuredmedia'][0]['source_url'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir: $url')),
      );
    }
  }
}