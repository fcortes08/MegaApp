import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ⚠️ IMPORTANTE: Cambia esta URL según tu caso
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // OPCIONES DE URL:
  // Emulador Android: http://10.0.2.2:8000/api
  // Dispositivo físico: http://192.168.X.X:8000/api (tu IP de PC)
  // Web: http://localhost:8000/api
  
  final storage = const FlutterSecureStorage();

  // ========== REGISTRO DE USUARIO ==========
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nombre': nombre,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Guardar token de forma segura
        await storage.write(key: 'auth_token', value: data['token']);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Error en registro'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ========== LOGIN DE USUARIO ==========
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Guardar token de forma segura
        await storage.write(key: 'auth_token', value: data['token']);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Credenciales inválidas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ========== OBTENER TOKEN GUARDADO ==========
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // ========== VERIFICAR SI HAY SESIÓN ACTIVA ==========
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ========== CERRAR SESIÓN ==========
  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
  }

  // ========== PETICIONES AUTENTICADAS ==========
  Future<http.Response> authenticatedRequest(String endpoint) async {
    final token = await getToken();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}