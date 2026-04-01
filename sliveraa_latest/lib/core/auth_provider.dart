import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../utils/app_state.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get userData => _userData;

  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.sendOtp(phone);
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.verifyOtp(phone, code);
      if (response.statusCode == 200) {
        _token = response.data['token'];
        _userData = response.data['user'];
        _apiService.setToken(_token!);
        
        // Update AppState singleton (legacy support)
        // Responsibility: Updating the entire user map to keep all screens in sync
        final appState = AppState();
        final Map<String, dynamic> userMap = {
          'id': appState.userId,
          'name': _userData?['name'] ?? 'Gold Trader',
          'phone': phone,
          'kycStatus': appState.kycStatus,
        };
        appState.updateFromMap(userMap);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    _userData = null;
    _apiService.clearToken();
    notifyListeners();
  }
}
