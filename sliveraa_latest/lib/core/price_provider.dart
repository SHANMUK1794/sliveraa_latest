import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
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
    // 1-second timer for the "Live" feel
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick % 30 == 0) {
        // Every 30 seconds, sync with real data from backend
        fetchPrices();
      } else {
        // Every other second, provide visual micro-fluctuations for "Real Live" feel
        _applyMicroFluctuations();
      }
    });
  }

  void _applyMicroFluctuations() {
    // Simulate real-market micro-movements (±0.01% - 0.05%)
    final random = math.Random();
    
    // For Gold
    double goldChange = (_goldPrice * 0.0001) * (random.nextDouble() > 0.5 ? 1 : -1);
    _goldPrice += goldChange;
    
    // For Silver (more volatile)
    double silverChange = (_silverPrice * 0.0002) * (random.nextDouble() > 0.5 ? 1 : -1);
    _silverPrice += silverChange;
    
    notifyListeners();
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
