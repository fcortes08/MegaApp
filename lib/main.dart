import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MegaApp());
}

class MegaApp extends StatelessWidget {
  const MegaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MegaApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Mostrar splash por 2 segundos
    await Future.delayed(const Duration(seconds: 2));
    
    // Verificar si hay token guardado
    final isAuthenticated = await _apiService.isAuthenticated();
    
    if (!mounted) return;
    
    // Navegar según el resultado
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isAuthenticated 
            ? const HomeScreen()   // Si hay token → HomeScreen
            : const LoginScreen(), // Si no hay token → LoginScreen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono grande de bus
            const Icon(
              Icons.directions_bus,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            
            // Título
            const Text(
              'MegaApp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Subtítulo
            const Text(
              'Tracking de Mega Bus',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            
            // Loading
            const CircularProgressIndicator(
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}