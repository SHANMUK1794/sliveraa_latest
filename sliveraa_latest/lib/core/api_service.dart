import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';

class ApiService {
  // Automatically detect machine IP or localhost
  // Automatically switch between local and production
  static String get _baseUrl {
    // Railway Production URL
    const productionUrl = 'https://sliveraalatest-production.up.railway.app';
    
    // Use localhost for Windows development, otherwise use Production
    final baseUrl = (!kIsWeb && Platform.isWindows) ? 'http://localhost:3000' : productionUrl;
    return '$baseUrl/api/';
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 5),
  ));

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio get dio => _dio;

  Future<Response> post(String path, dynamic data) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  // Add interceptors for JWT token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Auth Methods
  Future<Response> login(String phone, String password) async {
    return _dio.post('auth/login', data: {
      'phone': phone,
      'password': password,
    });
  }

  Future<Response> sendOtp(String phone, {String? intent}) async {
    return await _dio.post('auth/send-otp', data: {
      'phone': phone,
      'intent': intent,
    });
  }

  Future<Response> verifyOtp(String phone, String code, {String? name, String? email, String? intent, String? password}) async {
    return await _dio.post('auth/verify-otp', data: {
      'phone': phone,
      'code': code,
      'name': name,
      'email': email,
      'intent': intent,
      'password': password,
    });
  }

  // Profile & Transactions
  Future<Response> getUserProfile() async {
    return await _dio.get('profile/me');
  }

  Future<Response> getTransactions() async {
    return await _dio.get('profile/transactions');
  }

  Future<Response> updateProfile(String name, String email) async {
    return await _dio.patch('profile/update', data: {
      'name': name,
      'email': email,
    });
  }

  // Price Methods
  Future<Response> getLivePrices() async {
    return await _dio.get('prices/live');
  }

  // Payment Methods
  Future<Response> createOrder(double amount, String assetType, double grams, String userId) async {
    return await _dio.post('payments/create-order', data: {
      'amount': amount,
      'assetType': assetType,
      'grams': grams,
      'userId': userId,
    });
  }

  Future<Response> verifyPayment(Map<String, dynamic> data) async {
    return await _dio.post('payments/verify-payment', data: data);
  }

  // KYC Methods
  Future<Response> startKyc(String userId, {String idType = 'AADHAAR', String idNumber = '000000000000'}) async {
    return await _dio.post('kyc/start', data: {
      'userId': userId,
      'idType': idType,
      'idNumber': idNumber,
    });
  }

  Future<Response> checkKycStatus(String userId) async {
    return await _dio.get('kyc/status/$userId');
  }
}
