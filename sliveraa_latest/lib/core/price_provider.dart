import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/price_data.dart';
import 'api_service.dart';

class PriceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  double _goldPrice = PriceData.goldPrice;
  double _silverPrice = PriceData.silverPrice;
  bool _isLoading = false;
  Timer? _timer;

  double get goldPrice => _goldPrice;
  double get silverPrice => _silverPrice;
  bool get isLoading => _isLoading;

  PriceProvider() {
    fetchPrices();
    _startPriceUpdates();
  }

  void _startPriceUpdates() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchPrices();
    });
  }

  Future<void> fetchPrices() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getLivePrices();
      if (response.statusCode == 200) {
        _goldPrice = response.data['gold']['price'].toDouble();
        _silverPrice = response.data['silver']['price'].toDouble();
        // Synchronize static helper for non-reactive components
        PriceData.updatePrices(_goldPrice, _silverPrice);
      }
    } catch (e) {
      debugPrint('Error fetching prices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
