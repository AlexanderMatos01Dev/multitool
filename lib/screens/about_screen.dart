import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de Mí'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto de perfil con decoración
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 15,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const CircleAvatar(
                  radius: 90,
                  backgroundImage: AssetImage('assets/yo.jpeg'),
                ),
              ),
              const SizedBox(height: 48),

              // Nombre con estilo destacado
              const Text(
                'Smith Rodriguez',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),

              // Título profesional
              const Text(
                'Desarrollador Flutter',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),

              // Tarjeta de información
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Información de contacto
                      _buildContactInfo(
                        icon: Icons.email,
                        label: 'Email',
                        value: 'smithrodriguez345@gmail.com',
                        onTap: () => _launchEmail('smithrodriguez345@gmail.com'),
                      ),
                      const SizedBox(height: 16),

                      _buildContactInfo(
                        icon: Icons.code,
                        label: 'GitHub',
                        value: 'github.com/smith-ch',
                        onTap: () => _launchUrl('https://github.com/smith-ch'),
                      ),
                      const SizedBox(height: 16),

                      _buildContactInfo(
                        icon: Icons.work,
                        label: 'Portafolio',
                        value: 'smithdev.com',
                        onTap: () => _launchUrl('https://smithdev.com'),
                      ),
                      const SizedBox(height: 24),

                      // Botón de contacto
                      ElevatedButton.icon(
                        onPressed: () => _launchEmail('smithrodriguez345@gmail.com'),
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar Mensaje'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Descripción personal
              const Text(
                'Desarrollador móvil especializado en Flutter con experiencia '
                    'en creación de aplicaciones intuitivas y de alto rendimiento. '
                    'Apasionado por implementar soluciones innovadoras que mejoran '
                    'la experiencia del usuario.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Función para abrir URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Función para abrir cliente de email
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}