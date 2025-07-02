import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<_MenuOption> options = const [
    _MenuOption(title: 'Predicción de Género', icon: Icons.person_search, route: '/gender'),
    _MenuOption(title: 'Predicción de Edad', icon: Icons.cake, route: '/age'),
    _MenuOption(title: 'Universidades por País', icon: Icons.school, route: '/universities'),
    _MenuOption(title: 'Clima en RD', icon: Icons.wb_sunny, route: '/weather'),
    _MenuOption(title: 'Información Pokémon', icon: Icons.catching_pokemon, route: '/pokemon'),
    _MenuOption(title: 'Noticias WordPress', icon: Icons.newspaper, route: '/news'),
    _MenuOption(title: 'Acerca de', icon: Icons.info, route: '/about'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Caja de Herramientas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Logo de Toolbox
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/toolbox.jpg', // Ruta de tu imagen de toolbox
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Título debajo del logo
          const Text(
            'Caja de Herramientas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Seleccione una herramienta para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Grid de opciones
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _buildOptionCard(context, option);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, _MenuOption option) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, option.route),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(option.icon, size: 42, color: Colors.blue.shade700),
              const SizedBox(height: 12),
              Text(
                option.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOption {
  final String title;
  final IconData icon;
  final String route;

  const _MenuOption({
    required this.title,
    required this.icon,
    required this.route,
  });
}