import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _gender;
  double? _probability;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _predictGender() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa un nombre');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _gender = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.genderize.io/?name=$name'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['gender'] == null) {
          setState(() => _errorMessage = 'No se pudo predecir el género');
        } else {
          setState(() {
            _gender = data['gender'];
            _probability = data['probability'];
          });
        }
      } else {
        setState(() => _errorMessage = 'Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error de conexión');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _gender = null;
      _probability = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    IconData icon = Icons.person_outline;

    if (_gender == 'male') {
      color = Colors.blue;
      icon = Icons.male;
    } else if (_gender == 'female') {
      color = Colors.pink;
      icon = Icons.female;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicción de Género'),
        actions: [
          if (_gender != null || _errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reiniciar',
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
              onSubmitted: (_) => _predictGender(),
            ),
            const SizedBox(height: 20),

            // Botón de predicción
            ElevatedButton(
              onPressed: _isLoading ? null : _predictGender,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Predecir Género'),
            ),

            // Mensaje de error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // Resultado
            if (_gender != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono grande
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 3),
                      ),
                      child: Icon(
                        icon,
                        size: 120,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Género
                    Text(
                      _gender == 'male' ? 'Masculino' : 'Femenino',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Probabilidad
                    if (_probability != null)
                      Text(
                        'Probabilidad: ${(_probability! * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 20),
                      ),
                  ],
                ),
              )
            else if (!_isLoading && _errorMessage == null)
              const Expanded(
                child: Center(
                  child: Icon(Icons.transgender, size: 120, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}