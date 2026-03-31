import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';

class ApiService {
  // Automatically detect machine IP or localhost
  // Automatically switch between local and production
  static String get _baseUrl {
    // Railway Production URL
    const productionUrl = 'https://sliveraalatest-production.up.railway.app';
    
    // Always use Production URL for testing
    final baseUrl = productionUrl;
    return '$baseUrl/api/';
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
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
    final Map<String, dynamic> data = {
      'phone': phone,
      'code': code,
      'intent': intent,
    };
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    
    return await _dio.post('auth/verify-otp', data: data);
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
