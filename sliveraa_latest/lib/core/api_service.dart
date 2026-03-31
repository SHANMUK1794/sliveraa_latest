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
  ApiService._internal() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
          final message = e.message ?? '';
          if (message.contains('Failed host lookup')) {
            // This is almost certainly a Jio/ISP DNS blocking issue
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: 'Network issue (Jio/ISP DNS block). Please switch to Wi-Fi or set your Private DNS to "dns.google" in phone settings.',
                type: DioExceptionType.connectionError,
              ),
            );
          }
        }
        return handler.next(e);
      },
    ));
  }

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
  Future<Response> login(String identifier, String password) async {
    return await _dio.post('auth/login', data: {
      'phone': identifier,
      'password': password,
    });
  }

  Future<Response> sendOtp(String phone, {String? intent, String? email}) async {
    final data = {
      'phone': phone,
      'intent': intent,
    };
    if (email != null && email.trim().isNotEmpty) {
      data['email'] = email.trim();
    }
    return await _dio.post('auth/send-otp', data: data);
  }

  Future<Response> verifyOtp(String phone, String code, {String? name, String? email, String? intent, String? password}) async {
    final Map<String, dynamic> data = {
      'phone': phone,
      'code': code,
      'intent': intent,
    };
    if (name != null && name.isNotEmpty) data['name'] = name;
    if (email != null && email.isNotEmpty) data['email'] = email;
    if (password != null && password.isNotEmpty) data['password'] = password;
    
    return await _dio.post('auth/verify-otp', data: data);
  }

  Future<Response> updatePassword(String newPassword) async {
    return await _dio.patch('profile/update-password', data: {
      'password': newPassword,
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
  Future<Response> startKyc(String idType, String idNumber) async {
    return await _dio.post('kyc/start', data: {
      'idType': idType,
      'idNumber': idNumber,
    });
  }

  Future<Response> initDigiLocker() async {
    return await _dio.get('kyc/digilocker/init');
  }

  Future<Response> submitAadhaarOtp(String clientId, String otp) async {
    return await _dio.post('kyc/submit-aadhaar-otp', data: {
      'clientId': clientId,
      'otp': otp,
    });
  }

  Future<Response> finalizeDigiLocker(String clientId) async {
    return await _dio.post('kyc/digilocker/finalize', data: {
      'clientId': clientId,
    });
  }
}
