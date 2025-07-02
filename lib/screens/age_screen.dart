import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  final TextEditingController _controller = TextEditingController();
  int? _age;
  bool _isLoading = false;
  String? _error;
  String? _imageAsset;

  Future<void> _getAge() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Por favor ingresa un nombre');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _age = null;
      _imageAsset = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.agify.io/?name=$name'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final age = data['age'] as int?;

        if (age == null) {
          setState(() => _error = 'No se pudo predecir la edad');
          return;
        }

        setState(() {
          _age = age;
          // Asignar imagen según la categoría de edad con límites corregidos
          if (age < 18) {
            _imageAsset = 'assets/joven.jpg'; // Joven
          } else if (age < 60) {
            _imageAsset = 'assets/adulto.jpg'; // Adulto
          } else {
            _imageAsset = 'assets/anciano.jpg'; // Anciano
          }
        });
      } else {
        setState(() => _error = 'Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _age = null;
      _error = null;
      _imageAsset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Edad'),
        actions: [
          if (_age != null || _error != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Campo de entrada
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _reset,
                )
                    : null,
              ),
              onSubmitted: (_) => _getAge(),
            ),
            const SizedBox(height: 20),

            // Botón
            ElevatedButton(
              onPressed: _isLoading ? null : _getAge,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Predecir Edad'),
            ),

            // Mensaje de error
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // Resultado
            if (_age != null)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    // Imagen según categoría con mejor ajuste
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getAgeColor().withOpacity(0.1),
                        border: Border.all(
                          color: _getAgeColor(),
                          width: 3,
                        ),
                        image: _imageAsset != null
                            ? DecorationImage(
                          image: AssetImage(_imageAsset!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Edad
                    Text(
                      '$_age años',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _getAgeColor(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Categoría con texto en mayúscula inicial
                    Text(
                      _getAgeCategory(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getAgeColor(),
                      ),
                    ),
                  ],
                ),
              )
            else if (!_isLoading && _error == null)
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Icon(Icons.person_search, size: 100, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  String _getAgeCategory() {
    if (_age == null) return '';
    if (_age! < 18) return 'Joven';
    if (_age! < 60) return 'Adulto';
    return 'Anciano';
  }

  Color _getAgeColor() {
    if (_age == null) return Colors.blue;
    if (_age! < 18) return Colors.green;
    if (_age! < 60) return Colors.blue;
    return Colors.orange;
  }
}