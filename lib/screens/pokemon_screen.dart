import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPlaying = false;

  Future<void> _fetchPokemon() async {
    final name = _controller.text.toLowerCase().trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un nombre');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _pokemonData = null;
      _isPlaying = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _pokemonData = data);

        // Intentar reproducir sonido
        await _playPokemonSound(data['id']);
      } else {
        setState(() => _errorMessage = 'Pokémon no encontrado');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playPokemonSound(int id) async {
    try {
      final soundUrl = 'https://pokemoncries.com/cries/$id.mp3';
      await _player.play(UrlSource(soundUrl));
      setState(() => _isPlaying = true);
    } catch (e) {
      // No mostrar error si falla el sonido
    }
  }

  Future<void> _stopSound() async {
    await _player.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de Pokémon'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: _controller,
              onSubmitted: (value) => _fetchPokemon(),
              decoration: InputDecoration(
                labelText: 'Nombre del Pokémon',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _pokemonData = null;
                      _errorMessage = '';
                    });
                  },
                )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Botón de búsqueda
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchPokemon,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Buscar Pokémon', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),

            // Mensaje de error
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            // Resultados
            if (_pokemonData != null) _buildPokemonCard(),

            // Espacio vacío inicial
            if (_pokemonData == null && _errorMessage.isEmpty && !_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.catching_pokemon,
                        size: 150,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Busca un Pokémon por su nombre',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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

  Widget _buildPokemonCard() {
    final name = _pokemonData!['name'];
    final id = _pokemonData!['id'];
    final imageUrl = _pokemonData!['sprites']['front_default'];
    final types = (_pokemonData!['types'] as List).map<String>((type) => type['type']['name'] as String).toList();
    final abilities = (_pokemonData!['abilities'] as List).map<String>((ability) => ability['ability']['name'] as String).toList();
    final stats = _pokemonData!['stats'] as List;
    final height = _pokemonData!['height'] / 10; // Convertir a metros
    final weight = _pokemonData!['weight'] / 10; // Convertir a kg

    return Expanded(
      child: SingleChildScrollView(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Encabezado con ID y nombre
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      name[0].toUpperCase() + name.substring(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Botón de sonido
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.volume_up : Icons.volume_off,
                        color: _isPlaying ? Colors.red : Colors.grey,
                      ),
                      onPressed: _isPlaying ? _stopSound : () => _playPokemonSound(id),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Imagen del Pokémon
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 180,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                const SizedBox(height: 16),

                // Tipos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: types.map((type) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Características
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeature('Altura', '${height.toStringAsFixed(1)} m', Icons.height),
                    _buildFeature('Peso', '${weight.toStringAsFixed(1)} kg', Icons.scale),
                  ],
                ),
                const SizedBox(height: 24),

                // Habilidades
                const Text(
                  'Habilidades',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: abilities.map((ability) {
                    return Chip(
                      label: Text(ability),
                      backgroundColor: Colors.blue[50],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Estadísticas
                const Text(
                  'Estadísticas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...stats.map<Widget>((stat) {
                  final statName = stat['stat']['name'] as String;
                  final value = stat['base_stat'] as int;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatStatName(statName),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('$value'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: value / 100,
                          backgroundColor: Colors.grey[200],
                          color: _getStatColor(value),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 36, color: Colors.grey),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getTypeColor(String type) {
    final colors = {
      'normal': Colors.grey[400],
      'fire': Colors.orange,
      'water': Colors.blue,
      'electric': Colors.yellow[700],
      'grass': Colors.green,
      'ice': Colors.cyan,
      'fighting': Colors.red[700],
      'poison': Colors.purple,
      'ground': Colors.brown,
      'flying': Colors.indigo[200],
      'psychic': Colors.pink,
      'bug': Colors.lightGreen,
      'rock': Colors.brown[400],
      'ghost': Colors.deepPurple,
      'dragon': Colors.indigo,
      'dark': Colors.brown[900],
      'steel': Colors.blueGrey,
      'fairy': Colors.pink[200],
    };

    return colors[type] ?? Colors.grey;
  }

  Color _getStatColor(int value) {
    if (value >= 90) return Colors.green;
    if (value >= 70) return Colors.lightGreen;
    if (value >= 50) return Colors.yellow[700]!;
    if (value >= 30) return Colors.orange;
    return Colors.red;
  }

  String _formatStatName(String name) {
    final names = {
      'hp': 'HP',
      'attack': 'Ataque',
      'defense': 'Defensa',
      'special-attack': 'Ataque Especial',
      'special-defense': 'Defensa Especial',
      'speed': 'Velocidad',
    };

    return names[name] ?? name;
  }
}