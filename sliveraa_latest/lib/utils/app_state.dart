import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class BankAccount {
  final String id;
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final bool isPrimary;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    this.isPrimary = false,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? '',
      bankName: json['bankName'] ?? '',
      accountHolder: json['accountHolder'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifsc: json['ifsc'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
    );
  }
}

class DeliveryRequest {
  final String id;
  final String metalType;
  final double weight;
  final String status;
  final String? trackingId;
  final DateTime createdAt;
  final Map<String, dynamic>? address;

  DeliveryRequest({
    required this.id,
    required this.metalType,
    required this.weight,
    required this.status,
    this.trackingId,
    required this.createdAt,
    this.address,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      id: json['id'] ?? '',
      metalType: json['metalType'] ?? 'GOLD',
      weight: double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'PENDING',
      trackingId: json['trackingId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      address: json['address'],
    );
  }
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
      biometricUserId = prefs.getString('biometricUserId') ?? "";
      userName = prefs.getString('userName') ?? "";
      _kycStatus = prefs.getString('kycStatus') ?? "NOT_STARTED";
      referralCode = prefs.getString('referralCode') ?? "";
      
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
  
  // Wealth Milestones (Targets in Grams)
  double goldTarget = 1.0; // Next target: 1g Gold Coin
  double silverTarget = 100.0; // Next target: 100g Silver Bar
  
  // Investment Performance Tracker (Average Buy Price)
  double goldAvgPrice = 6100.0; // Simulated average buy price
  double silverAvgPrice = 90.0; // Simulated average buy price

  double getGoldPerformance() => goldGrams > 0 ? ( goldGrams * (6250.0 - goldAvgPrice) ) : 0.0;
  double getSilverPerformance() => silverGrams > 0 ? ( silverGrams * (95.0 - silverAvgPrice) ) : 0.0;

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
  String biometricUserId = ""; // Persists after logout specifically for fingerprint prompt
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
  List<DeliveryRequest> deliveries = [];

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

  void updateFromMap(Map<String, dynamic> rawData) {
    // If the data is wrapped in a 'user' key (common in some API responses)
    final Map<String, dynamic> data = (rawData.containsKey('user') && rawData['user'] is Map) 
        ? rawData['user'] 
        : rawData;
        
    currentUser = data;
    // Exhaustive search for ID
    userId = data['id']?.toString() ?? 
             data['_id']?.toString() ?? 
             data['userId']?.toString() ?? 
             userId;
    userName = data['name'] ?? userName;
    _kycStatus = (data['kycStatus'] ?? _kycStatus).toString().toUpperCase();
    referralCode = data['referralCode']?.toString() ?? referralCode;
    
    // Portfolio / Aura
    if (data['goldBalance'] != null) goldGrams = double.tryParse(data['goldBalance'].toString()) ?? goldGrams;
    if (data['silverBalance'] != null) silverGrams = double.tryParse(data['silverBalance'].toString()) ?? silverGrams;
    if (data['auraPoints'] != null) auraPoints = int.tryParse(data['auraPoints'].toString()) ?? auraPoints;
    
    if (userId.isNotEmpty) {
      biometricUserId = userId; // Remember this ID for next biometric login
    }
    
    _saveIdentity();
    notifyListeners();
  }

  Future<void> _saveIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('biometricUserId', biometricUserId);
    await prefs.setString('userName', userName);
    await prefs.setString('kycStatus', kycStatus);
    await prefs.setString('referralCode', referralCode);
    
    // Save token if currently set in ApiService headers
    // Note: Best practice is to set it explicitly, but this is a fail-safe
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    ApiService().setToken(token);
  }

  void updateRecentActivity(List<dynamic> data) {
    recentActivity = data.map((t) {
      final map = t as Map<String, dynamic>;
      // Map backend 'metalType' to frontend 'assetType' if necessary
      if (map.containsKey('metalType') && !map.containsKey('assetType')) {
        map['assetType'] = map['metalType'];
      }
      if (map.containsKey('weight') && !map.containsKey('grams')) {
        map['grams'] = map['weight'];
      }
      return map;
    }).toList();
    notifyListeners();
  }

  Future<void> fetchBankAccounts() async {
    try {
      final response = await ApiService().getBankAccounts();
      if (response.statusCode == 200) {
        final List data = response.data;
        bankAccounts = data.map((b) => BankAccount.fromJson(b)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching bank accounts: $e');
    }
  }

  void updateTransactions(List<dynamic> data) => updateRecentActivity(data);

  Future<void> clear() async {
    final bool biometricWasEnabled = _isBiometricEnabled;
    final String lastBiometricUserId = biometricUserId;
    
    // Clear in-memory user data
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
    
    // Persistent Storage Logic
    final prefs = await SharedPreferences.getInstance();
    
    if (biometricWasEnabled) {
      // If biometrics are enabled, we "Lock" the session rather than destroying it.
      // We keep: authToken, biometricUserId, isBiometricEnabled.
      // We only remove: userId, userName (to show "Locked" state vs "Logged In" state if needed)
      await prefs.remove('userId');
      await prefs.remove('userName');
      
      // Keep authToken and isBiometricEnabled intact
      debugPrint('AppState: Session LOCKED via Biometrics. Token preserved.');
    } else {
      // Standard full purge
      await prefs.remove('authToken');
      await prefs.remove('userId');
      await prefs.remove('userName');
      await prefs.remove('isBiometricEnabled');
      await prefs.remove('biometricUserId');
      await prefs.remove('kycStatus');
      await prefs.remove('referralCode');
      debugPrint('AppState: Full Session Purge completed.');
    }
    
    ApiService().clearToken();
    notifyListeners();
  }

  Future<void> refreshStatus() async {
    // This is typically called from KycScreen or DigiLockerWebView
    // Implementation can be added here once ApiService().getUserProfile() is verified
  }

  Future<void> fetchDeliveries() async {
    try {
      final response = await ApiService().getDeliveries();
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['deliveries'] ?? [];
        deliveries = list.map((e) => DeliveryRequest.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching deliveries: $e');
    }
  }
}
