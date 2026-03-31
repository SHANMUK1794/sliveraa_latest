import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://sliveraalatest-production.up.railway.app/api/',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  
  try {
    print("Testing API...");
    final result = await dio.post('auth/send-otp', data: {
      'phone': '9652812202',
      'intent': 'register'
    });
    print(result.data);
  } catch(e) {
    if (e is DioException) {
      print("DioError: ${e.message} \n Response: ${e.response?.data}");
    } else {
      print("Error: $e");
    }
  }
}
