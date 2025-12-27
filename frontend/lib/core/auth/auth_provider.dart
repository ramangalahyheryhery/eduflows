import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';  // IMPORT AJOUTÉ
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _token;  // VARIABLE AJOUTÉE

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  String? get token => _token;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJson = prefs.getString('user');
      
      if (token != null && userJson != null) {
        // Vérifier si le token est toujours valide
        try {
          final verification = await ApiService.verifyToken(token);
          
          if (verification['success'] == true) {
            _token = token;
            final userData = json.decode(userJson) as Map<String, dynamic>;
            _user = User.fromJson(userData);
            print('✅ Session restaurée: ${_user!.email}');
          } else {
            await _clearStorage();
          }
        } catch (e) {
          print('❌ Token invalide: $e');
          await _clearStorage();
        }
      }
    } catch (e) {
      print('❌ Erreur restauration session: $e');
      await _clearStorage();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🚀 Tentative de connexion API...');
      
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        _token = response['token'];
        _user = User.fromJson(response['user']);
        
        // Sauvegarder dans SharedPreferences
        await _saveToPrefs();
        
        print('✅ Connexion réussie: ${_user!.email} (${_user!.role})');
        return true;
      } else {
        print('❌ Échec connexion: ${response['message']}');
        return false;
      }
      
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _clearStorage();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MÉTHODE AJOUTÉE
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('token', _token!);
      }
      if (_user != null) {
        final userJson = json.encode(_user!.toJson());
        await prefs.setString('user', userJson);
      }
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
    }
  }

  // MÉTHODE AJOUTÉE
  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      _user = null;
      _token = null;
    } catch (e) {
      print('❌ Erreur nettoyage: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _saveToPrefs();
    notifyListeners();
  }
}