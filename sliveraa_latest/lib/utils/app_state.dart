import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class BankAccount {
  String bankName;
  String accountHolder;
  String accountNumber;
  String ifsc;
  bool isPrimary;

  BankAccount({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    this.isPrimary = false,
  });
}

class AppState extends ChangeNotifier {
  // Singleton Pattern
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Biometric Status
  bool _isBiometricEnabled = false;
  bool get isBiometricEnabled => _isBiometricEnabled;
  set isBiometricEnabled(bool value) {
    _isBiometricEnabled = value;
    _saveBiometricPreference(value);
    notifyListeners();
  }

  // Load from SharedPreferences
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
      userId = prefs.getString('userId') ?? "";
      userName = prefs.getString('userName') ?? "";
      
      final savedToken = prefs.getString('authToken');
      if (savedToken != null && savedToken.isNotEmpty) {
        ApiService().setToken(savedToken);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  Future<void> _saveBiometricPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricEnabled', value);
  }

  // Portfolio Balances (Grams)
  double goldGrams = 0.0;
  double silverGrams = 0.0;

  // KYC Status
  String _kycStatus = "NOT_STARTED";
  String get kycStatus => _kycStatus;
  set kycStatus(String value) {
    _kycStatus = value.toUpperCase();
    notifyListeners();
  }

  bool get isKycVerified => kycStatus == "VERIFIED";

  // User Details
  String userId = "";
  String userName = "";
  Map<String, dynamic> currentUser = {};

  String get userPhone => currentUser['phone'] ?? currentUser['phoneNumber'] ?? '';
  String get userEmail => currentUser['email'] ?? '';
  
  int auraPoints = 0;
  String referralCode = "";
  int referralCount = 0;
  double referralEarnings = 0.0;

  // Addresses & Bank Accounts
  List<String> addresses = [];
  List<BankAccount> bankAccounts = [];

  // Settings
  Map<String, bool> notificationSettings = {
    'Price Alerts': true,
    'Market Updates': true,
    'Transaction Alerts': true,
    'Security Alerts': true,
    'Promotional Offers': false,
  };

  List<Map<String, String>> activeDevices = [
    {'name': 'Samsung Galaxy S24 Ultra', 'location': 'Mumbai, India', 'status': 'Current Device'},
  ];

  // Portfolio Metrics
  double get goldWeightRatio => (goldGrams + silverGrams) > 0 
      ? (goldGrams / (goldGrams + silverGrams)) 
      : 0.5;
  double get totalSavingsThisMonth => 12450.0; // Mocked value

  // Recent Activity/Transactions list
  List<Map<String, dynamic>> recentActivity = [];
  List<Map<String, dynamic>> get transactions => recentActivity;

  void updateFromMap(Map<String, dynamic> data) {
    currentUser = data;
    // Exhaustive search for ID
    userId = data['id']?.toString() ?? 
             data['_id']?.toString() ?? 
             data['userId']?.toString() ?? 
             userId;
    userName = data['name'] ?? userName;
    _kycStatus = (data['kycStatus'] ?? _kycStatus).toString().toUpperCase();
    
    // Portfolio / Aura
    if (data['goldBalance'] != null) goldGrams = double.tryParse(data['goldBalance'].toString()) ?? goldGrams;
    if (data['silverBalance'] != null) silverGrams = double.tryParse(data['silverBalance'].toString()) ?? silverGrams;
    if (data['auraPoints'] != null) auraPoints = int.tryParse(data['auraPoints'].toString()) ?? auraPoints;
    
    _saveIdentity();
    notifyListeners();
  }

  Future<void> _saveIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('userName', userName);
    
    // Save token if currently set in ApiService headers
    // Note: Best practice is to set it explicitly, but this is a fail-safe
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    ApiService().setToken(token);
  }

  void updateRecentActivity(List<dynamic> data) {
    recentActivity = data.map((t) => t as Map<String, dynamic>).toList();
    notifyListeners();
  }

  void updateTransactions(List<dynamic> data) => updateRecentActivity(data);

  void clear() {
    userId = "";
    userName = "";
    currentUser = {};
    _kycStatus = "NOT_STARTED";
    goldGrams = 0.0;
    silverGrams = 0.0;
    auraPoints = 0;
    recentActivity = [];
    addresses = [];
    bankAccounts = [];
    
    // Clear Token
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('authToken');
      prefs.remove('userId');
      prefs.remove('userName');
    });
    ApiService().clearToken();
    
    notifyListeners();
  }

  Future<void> refreshStatus() async {
    // This is typically called from KycScreen or DigiLockerWebView
    // Implementation can be added here once ApiService().getUserProfile() is verified
  }
}
