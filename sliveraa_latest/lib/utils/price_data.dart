import 'dart:math';

class PriceData {
  static double goldPrice = 6200.00;
  static double silverPrice = 92.00;
  
  static double getPrice(bool isGold) => isGold ? goldPrice : silverPrice;

  static void updatePrices(double gold, double silver) {
    goldPrice = gold;
    silverPrice = silver;
  }

  static String getPerformance(bool isGold, String timeframe) {
    final random = Random(isGold ? 1 : 2);
    double basePerf;
    
    switch (timeframe) {
      case '6M': basePerf = isGold ? 8.5 : 12.2; break;
      case '1Y': basePerf = isGold ? 14.8 : 18.5; break;
      case '3Y': basePerf = isGold ? 42.1 : 55.4; break;
      case '5Y': basePerf = isGold ? 88.5 : 110.2; break;
      default: basePerf = isGold ? 19.58 : 25.75;
    }
    
    final variance = (random.nextDouble() - 0.5) * 0.1;
    final total = basePerf + variance;
    
    return "${total >= 0 ? '+' : ''}${total.toStringAsFixed(2)}%";
  }
}
