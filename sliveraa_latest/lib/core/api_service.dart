import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';

class ApiService {
  // Automatically detect machine IP or localhost
  // Automatically switch between local and production
  static String get _baseUrl {
    // Custom Production URL from GoDaddy
    const productionUrl = 'https://api.silvras.com';
    
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
      onError: (DioException e, handler) async {
        // Check for DNS failure / Connection Error
        if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
           final message = (e.message ?? '').toLowerCase();
           final isDnsFailure = message.contains('failed host lookup') || 
                                message.contains('getaddrinfo failed') ||
                                message.contains('errno 7') ||
                                message.contains('errno 11001');

           if (isDnsFailure) {
             debugPrint('ApiService: DNS Failure detected. Attempting Secure DNS Fallback (DoH)...');
             
             final uri = e.requestOptions.uri;
             final resolvedIp = await _resolveDnsWithHttps(uri.host);
             
             if (resolvedIp != null) {
               debugPrint('ApiService: DNS Resolved to $resolvedIp. Retrying request...');
               
               // 1. Create a new URL with the IP instead of the hostname
               final newUrl = e.requestOptions.uri.replace(host: resolvedIp).toString();
               
               // 2. Clone the request with the new URL and the original Host header
               final options = e.requestOptions;
               options.path = newUrl;
               // Crucial: The "Host" header must stay as the original domain for Railway to route correctly
               options.headers['Host'] = uri.host;
               
               try {
                 final response = await _dio.fetch(options);
                 return handler.resolve(response);
               } catch (retryError) {
                 debugPrint('ApiService: Fallback retry failed: $retryError');
               }
             } else {
               debugPrint('ApiService: DNS Fallback failed to resolve IP.');
             }

             // Original informative error if fallback fails
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

  /// Resolve a hostname using Google DNS-over-HTTPS
  Future<String?> _resolveDnsWithHttps(String host) async {
    try {
      // Use a separate Dio instance to avoid circular interceptor calls
      final dnsDio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));
      final response = await dnsDio.get(
        'https://dns.google/resolve',
        queryParameters: {'name': host, 'type': 'A'},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final answers = data['Answer'] as List<dynamic>?;
        
        if (answers != null && answers.isNotEmpty) {
          // Return the first valid A record IP
          return answers[0]['data'] as String?;
        }
      }
    } catch (e) {
      debugPrint('ApiService: DNS-over-HTTPS error: $e');
    }
    return null;
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
  Future<Response> startKyc(String idType, String idNumber, {String? fullName, String? dob}) async {
    final Map<String, dynamic> data = {
      'idType': idType,
      'idNumber': idNumber,
    };
    if (fullName != null) data['fullName'] = fullName;
    if (dob != null) data['dob'] = dob;
    
    return await _dio.post('kyc/start', data: data);
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
