import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Méthode intelligente pour détecter la plateforme
  static String get baseUrl {
    if (Platform.isAndroid) {
      print('📱 Plateforme: Android');
      // Pour émulateur Android
      return 'http://localhost:3000/api';
      // Pour device Android physique (décommentez et mettez votre IP):
      // return 'http://192.168.1.100:3000/api';
    } else if (Platform.isIOS) {
      print('📱 Plateforme: iOS');
      // Pour iOS Simulator
      return 'http://localhost:3000/api';
    } else {
      print('📱 Plateforme: Web/Desktop');
      // Pour web et autres
      return 'http://localhost:3000/api';
    }
  }
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Tentative de connexion: $email');
      print('🌍 URL API: ${baseUrl}auth/login');
      
      final response = await http.post(
        Uri.parse('${baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📦 Réponse: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur de connexion (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Erreur API: $e');
      throw Exception('Impossible de se connecter au serveur: $e\nVérifiez:\n1. Le serveur backend tourne-t-il?\n2. L\'URL est-elle correcte? ($baseUrl)\n3. Avez-vous les permissions réseau?');
    }
  }

  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Token invalide');
      }
    } catch (e) {
      throw Exception('Erreur de vérification: $e');
    }
  }
}
