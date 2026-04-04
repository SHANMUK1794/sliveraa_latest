import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final currentPrice = isGoldSelected ? PriceData.goldPrice : PriceData.silverPrice;
    final performance = PriceData.getPerformance(isGoldSelected, selectedTimeframe);
    final bool isPositive = performance.startsWith('+');

    return Column(
      children: [
        Text(
          'Current ${isGoldSelected ? 'gold' : 'silver'} price per gram',
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '₹${currentPrice.toLocaleString()}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF1E293B),
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: (isPositive ? const Color(0xFF22C55E) : Colors.redAccent).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isPositive ? const Color(0xFF22C55E) : Colors.redAccent).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: isPositive ? const Color(0xFF22C55E) : Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    performance,
                    style: GoogleFonts.inter(
                      color: isPositive ? const Color(0xFF22C55E) : Colors.redAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                '₹${(isGoldSelected ? PriceData.goldPrice : PriceData.silverPrice).toLocaleString()}',
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
