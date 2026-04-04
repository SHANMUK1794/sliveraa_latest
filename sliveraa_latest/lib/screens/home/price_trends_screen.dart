import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../invest/invest_screen.dart';
import '../invest/savings_plan_screen.dart';
import '../invest/investment_options_screen.dart';
import '../../widgets/price_chart.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import '../../theme/app_colors.dart';

class PriceTrendsScreen extends StatefulWidget {
  final bool initialIsGold;
  final bool hideBackButton;
  
  const PriceTrendsScreen({
    super.key,
    this.initialIsGold = true,
    this.hideBackButton = false,
  });

  @override
  State<PriceTrendsScreen> createState() => _PriceTrendsScreenState();
}

class _PriceTrendsScreenState extends State<PriceTrendsScreen> {
  late bool isGoldSelected;
  String selectedTimeframe = '6M';
  bool isAlertOn = false;
  double selectedAlertPercent = -1.0;

  @override
  void initState() {
    super.initState();
    isGoldSelected = widget.initialIsGold;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Component with Rose Gold block
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBrownGold, AppColors.secondaryBrownGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (!widget.hideBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        'Price Trends',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                _buildProfessionalToggle(),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                children: [
                  _buildPerformanceInfo(),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: PriceChart(
                      isGold: isGoldSelected,
                      timeframe: selectedTimeframe,
                      lineColor: isGoldSelected ? const Color(0xFFD4A017) : const Color(0xFF2E5F52),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTimeframeSelector(),
                ],
              ),
            ),
          ),
          
          _buildBottomActionPanel(),
        ],
      ),
    );
  }

  Widget _buildProfessionalToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildSolidToggleButton('Gold', isGoldSelected, () => setState(() => isGoldSelected = true)),
          _buildSolidToggleButton('Silver', !isGoldSelected, () => setState(() => isGoldSelected = false)),
        ],
      ),
    );
  }

  Widget _buildSolidToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E5F52) : Colors.transparent, // Dark Green
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceInfo() {
    return Column(
      children: [
        Text(
          'Overall annualised performance',
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          PriceData.getPerformance(isGoldSelected, selectedTimeframe),
          style: GoogleFonts.inter(
            color: const Color(0xFF256241), // Deep Forest Green
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    final times = ['6M', '1Y', '3Y', '5Y', 'Max'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: times.map((t) {
        bool isSelected = t == selectedTimeframe;
        return GestureDetector(
          onTap: () => setState(() => selectedTimeframe = t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8FAF3).withValues(alpha: 0.3) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFF256241) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Text(
              t,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF256241) : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                )
              ],
            ),
            child: Icon(
              isAlertOn ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
              color: const Color(0xFF0F172A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isGoldSelected ? 'Gold' : 'Silver'} Price Alert',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get timely alerts when prices drop',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAlertOn,
            onChanged: (val) {
              if (val) {
                _showAlertBottomSheet();
              } else {
                setState(() => isAlertOn = false);
              }
            },
            activeColor: const Color(0xFF256241),
            activeTrackColor: const Color(0xFF256241).withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  void _showAlertBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Alert me when price drops by',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAlertPill(-1.0, setSheetState),
                  const SizedBox(width: 12),
                  _buildAlertPill(-1.5, setSheetState),
                  const SizedBox(width: 12),
                  _buildAlertPill(-2.0, setSheetState),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Compared to last week\'s average price',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Last week\'s average price: ₹15,603.51/gm',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'You will be notified through App Notifications\n& whatsapp messages',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => isAlertOn = true);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Price alert set at ${selectedAlertPercent.abs()}% drop'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF256241),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Set Alert',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertPill(double val, StateSetter setSheetState) {
    bool isSelected = selectedAlertPercent == val;
    return GestureDetector(
      onTap: () {
        setSheetState(() => selectedAlertPercent = val);
        setState(() => selectedAlertPercent = val);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8FAF3).withOpacity(0.3) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF256241) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Text(
          '${val.toStringAsFixed(isSelected ? (val == -1.5 ? 1 : 0) : 0)}%', // Matching screenshot decimals 1% vs 1.5%
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isSelected ? const Color(0xFF256241) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
  Widget _buildBottomActionPanel() {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + (bottomPadding > 0 ? bottomPadding : 0)),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Current ${isGoldSelected ? 'gold' : 'silver'} price for\n1gm of ${isGoldSelected ? '24k gold (99.9%)' : '999 pure silver'}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8), 
                    fontSize: 13, 
                    fontWeight: FontWeight.w500,
                    height: 1.3
                  ),
                ),
              ),
              Text(
                '₹${(isGoldSelected ? PriceData.goldPrice : PriceData.silverPrice).toLocaleString()}/gm',
                style: GoogleFonts.inter(
                  fontSize: 22, 
                  fontWeight: FontWeight.w800, 
                  color: const Color(0xFF0F172A)
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InvestmentOptionsScreen(isGold: isGoldSelected)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isGoldSelected 
                    ? const Color(0xFFB08C65) // Warm Gold
                    : const Color(0xFF64748B), // Slate Silver
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Buy ${isGoldSelected ? 'Gold' : 'Silver'}',
                style: GoogleFonts.inter(
                  fontSize: 16, 
                  fontWeight: FontWeight.w700
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
