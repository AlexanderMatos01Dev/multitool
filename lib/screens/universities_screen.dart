import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  final TextEditingController _controller = TextEditingController(text: 'Dominican Republic');
  List _universities = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentCountry = 'Dominican Republic';

  Future<void> _searchUniversities() async {
    final country = _controller.text.trim();
    if (country.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un país');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _universities = [];
      _currentCountry = country;
    });

    try {
      final encodedCountry = Uri.encodeComponent(country);
      final url = Uri.parse('http://universities.hipolabs.com/search?country=$encodedCountry');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isEmpty) {
          setState(() => _errorMessage = 'No se encontraron universidades para $country');
        } else {
          setState(() => _universities = data);
        }
      } else {
        setState(() => _errorMessage = 'Error: ${response.statusCode}');
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
    _searchUniversities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades por País'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _searchUniversities,
          )
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => _searchUniversities(),
                    decoration: InputDecoration(
                      labelText: 'Buscar por país (en inglés)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {});
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchUniversities,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),

          // Información del país
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'País:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _currentCountry,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Text(
                  'Universidades: ${_universities.length}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mensajes de estado
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),

          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

          // Lista de universidades
          Expanded(
            child: _buildUniversitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitiesList() {
    if (_universities.isEmpty && !_isLoading && _errorMessage.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text('No se encontraron universidades', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _universities.length,
      itemBuilder: (context, index) {
        final university = _universities[index];
        final name = university['name'] ?? 'Nombre no disponible';
        final domain = university['domains']?.isNotEmpty == true
            ? university['domains'][0]
            : 'dominio.com';
        final website = university['web_pages']?.isNotEmpty == true
            ? university['web_pages'][0]
            : null;
        final country = university['country'] ?? 'País desconocido';
        final state = university['state-province'] ?? '';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, size: 36, color: Colors.blue),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (state.isNotEmpty) Text('Estado: $state'),
                Text('Dominio: $domain'),
              ],
            ),
            trailing: website != null
                ? IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.blue),
              onPressed: () => _launchWebsite(website),
            )
                : null,
            onTap: website != null ? () => _launchWebsite(website) : null,
          ),
        );
      },
    );
  }

  Future<void> _launchWebsite(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir: $url')),
      );
    }
  }
}