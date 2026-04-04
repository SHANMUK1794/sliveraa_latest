import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_state.dart';
import 'package:intl/intl.dart';
import '../profile/profile_screen.dart';
import 'transaction_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService().getTransactions();
      if (response.statusCode == 200) {
        AppState().updateTransactions(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _allTransactions => AppState().transactions;

  List<Map<String, dynamic>> get _filteredTransactions {
    return _allTransactions.where((t) {
      final title = t['title'] ?? (t['type'] == 'BUY' ? 'Buy ${t['assetType']}' : 'Sell ${t['assetType']}');
      bool categoryMatch = selectedFilter == 'All' || 
                           (selectedFilter == 'Gold' && t['assetType'] == 'GOLD') ||
                           (selectedFilter == 'Silver' && t['assetType'] == 'SILVER');
      
      bool searchMatch = title.toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                        t['amount'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();
  }

  String _formatDate(dynamic date) {
    if (date == null) return "Unknown";
    try {
      final dt = DateTime.parse(date.toString());
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) return "TODAY";
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.day == yesterday.day && dt.month == yesterday.month && dt.year == yesterday.year) return "YESTERDAY";
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  String _formatTime(dynamic date) {
    if (date == null) return "";
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilters(),
            isLoading 
              ? const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primaryBrownGold)))
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshTransactions,
                    color: AppColors.primaryBrownGold,
                    child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._buildGroupedList(),
                  const SizedBox(height: 16),
                  _buildMonthlySummary(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBrownGold, AppColors.accentBrownGold],
                ),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
          ),
          Text(
            'Transaction History',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    // keeping function for reference but removed from usage
    return Container();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search transactions',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 16),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Gold', 'Silver', 'Withdraw'];
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((f) {
          bool isSelected = f == selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: isSelected 
                  ? Border(bottom: BorderSide(color: AppColors.primaryBrownGold, width: 3))
                  : null,
              ),
              child: Text(
                f,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryBrownGold : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final filtered = _filteredTransactions;
    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(child: Text('No transactions found', style: GoogleFonts.inter(color: Colors.grey))),
        )
      ];
    }

    Map<String, List<Map<String, dynamic>>> groups = {};
    for (var t in filtered) {
      String dateLabel = _formatDate(t['createdAt']);
      groups.putIfAbsent(dateLabel, () => []).add(t);
    }

    List<Widget> children = [];
    // Process unique dates in order
    final dates = groups.keys.toList();
    
    for (var label in dates) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
          ),
        ),
      );
      children.addAll(groups[label]!.map((t) => _buildTransactionItem(t)));
    }
    return children;
  }

  Widget _buildTransactionItem(Map<String, dynamic> t) {
    bool isBuy = t['type'] == 'BUY';
    String assetType = t['assetType'] ?? 'GOLD';
    
    // Default styling from backend model
    IconData icon = Icons.shopping_bag_outlined;
    Color iconColor = const Color(0xFFD97706);
    Color bgColor = const Color(0xFFFEF3C7);
    String title = assetType == 'GOLD' ? 'Gold' : 'Silver';
    String status = isBuy ? 'Purchased' : 'Sold';

    if (t['type'] == 'WITHDRAWAL') {
      title = 'Withdrawal';
      icon = Icons.account_balance_wallet_outlined;
      iconColor = const Color(0xFF16A34A);
      bgColor = const Color(0xFFDCFCE7);
      status = 'Bank Transfer';
    } else if (assetType == 'SILVER') {
      icon = Icons.toll_outlined;
      iconColor = const Color(0xFF94A3B8);
      bgColor = const Color(0xFFF1F5F9);
    } else if (assetType == 'GOLD') {
      icon = Icons.monetization_on_outlined;
      iconColor = AppColors.primaryBrownGold;
      bgColor = const Color(0xFFFAF5ED);
    }

    String subText = '${_formatTime(t['createdAt'])}';
    if (t['type'] == 'WITHDRAW') subText += ' • Income';

    double amount = (t['amount'] ?? 0).toDouble();
    String sign = isBuy ? '-' : '+';
    Color amountColor = isBuy ? const Color(0xFF0F172A) : const Color(0xFF16A34A);
    // Overrides for exact match
    if (t['type'] == 'WITHDRAW') {
      sign = '+';
      amountColor = const Color(0xFF16A34A);
    } else if (status == 'Silver') {
      sign = '-';
      amountColor = const Color(0xFF0F172A);
    }

    return GestureDetector(
      onTap: () => _showTrackingDetails(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subText,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$sign₹${NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2).format(amount)}",
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 6),
                _buildBadge(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackingDetails(Map<String, dynamic> t) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailsScreen(transaction: t),
      ),
    );
  }

  Widget _buildBadge(String status) {
    Color bg;
    Color text;

    if (status == 'Debited') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFD97706);
    } else if (status == 'Credited') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
    } else {
      bg = const Color(0xFFE2E8F0);
      text = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB89674), Color(0xFF9E7756)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB89674).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(Icons.auto_graph_rounded, color: Colors.white.withOpacity(0.4), size: 48),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MONTHLY SUMMARY',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2).format(AppState().totalSavingsThisMonth > 0 ? AppState().totalSavingsThisMonth : 12450.00),
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Expenses Oct 2023',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
