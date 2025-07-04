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

class _PokemonScreenState extends State<PokemonScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  Map<String, dynamic>? _pokemonData;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPlaying = false;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.elasticOut,
    );
  }

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
        _animationController?.forward();

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

  void _reset() {
    setState(() {
      _controller.clear();
      _pokemonData = null;
      _errorMessage = '';
      _isPlaying = false;
    });
    _animationController?.reset();
  }

  @override
  void dispose() {
    _player.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFF4ECDC4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personalizada
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Buscador de Pokémon',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (_pokemonData != null || _errorMessage.isNotEmpty)
                      IconButton(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Contenido principal
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Icono decorativo
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.catching_pokemon,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Campo de búsqueda
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (value) => _fetchPokemon(),
                            decoration: InputDecoration(
                              labelText: 'Nombre del Pokémon',
                              hintText: 'Ej: pikachu, charizard...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.search, color: Colors.white),
                              ),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _reset,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón de búsqueda
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _fetchPokemon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Buscar Pokémon',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Mensaje de error
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Resultados
                        if (_pokemonData != null)
                          Expanded(child: _buildPokemonCard())
                        else if (_errorMessage.isEmpty && !_isLoading)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(30),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.catching_pokemon,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Busca un Pokémon por su nombre',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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

    return ScaleTransition(
      scale: _scaleAnimation!,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTypeColor(types.first).withOpacity(0.1),
                _getTypeColor(types.first).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _getTypeColor(types.first).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Encabezado con ID y nombre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(types.first).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#${id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(types.first),
                      ),
                    ),
                  ),
                  Text(
                    name[0].toUpperCase() + name.substring(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Botón de sonido
                  Container(
                    decoration: BoxDecoration(
                      color: _isPlaying ? Colors.red.shade100 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.volume_up : Icons.volume_off,
                        color: _isPlaying ? Colors.red : Colors.grey.shade600,
                      ),
                      onPressed: _isPlaying ? _stopSound : () => _playPokemonSound(id),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Imagen del Pokémon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getTypeColor(types.first).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 150,
                  width: 150,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error, size: 150),
                ),
              ),
              const SizedBox(height: 20),

              // Tipos
              Wrap(
                spacing: 8,
                children: types.map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getTypeColor(type).withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Habilidades',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: abilities.map((ability) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            ability,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Estadísticas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estadísticas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...stats.map<Widget>((stat) {
                      final statName = stat['stat']['name'] as String;
                      final value = stat['base_stat'] as int;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatStatName(statName),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$value',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getStatColor(value),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: (value / 150).clamp(0.0, 1.0),
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getStatColor(value),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    final colors = {
      'normal': Colors.grey[400]!,
      'fire': Colors.orange,
      'water': Colors.blue,
      'electric': Colors.yellow[700]!,
      'grass': Colors.green,
      'ice': Colors.cyan,
      'fighting': Colors.red[700]!,
      'poison': Colors.purple,
      'ground': Colors.brown,
      'flying': Colors.indigo[200]!,
      'psychic': Colors.pink,
      'bug': Colors.lightGreen,
      'rock': Colors.brown[400]!,
      'ghost': Colors.deepPurple,
      'dragon': Colors.indigo,
      'dark': Colors.brown[900]!,
      'steel': Colors.blueGrey,
      'fairy': Colors.pink[200]!,
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

