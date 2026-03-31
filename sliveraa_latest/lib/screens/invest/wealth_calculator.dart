import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'savings_plan_screen.dart';
import '../../utils/price_data.dart';
import '../../theme/app_colors.dart';
import 'summary_screen.dart';

class WealthCalculator extends StatefulWidget {
  final bool isGoldInitial;
  const WealthCalculator({super.key, this.isGoldInitial = true});

  @override
  State<WealthCalculator> createState() => _WealthCalculatorState();
}

class _WealthCalculatorState extends State<WealthCalculator> {
  late bool isGold;
  double amount = 0;
  double tenureValue = 6;
  bool isMonths = true;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get rate => 0.14; // 14% p.a. return

  double get estimatedProfit {
    if (amount <= 0) return 0;
    double years = isMonths ? (tenureValue / 12.0) : tenureValue;
    return amount * (math.pow(1 + rate, years) - 1);
  }

  double get maturityValue => amount + estimatedProfit;

  double get metalWeight {
    if (amount <= 0) return 0;
    double pricePerGm = isGold ? 6245.0 : 75.40;
    return amount / pricePerGm;
  }

  void _reset() {
    setState(() {
      amount = 0;
      tenureValue = 6;
      isMonths = true;
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = isGold ? const Color(0xFFB48C65) : const Color(0xFF1F2937);
    final accentColor = isGold ? const Color(0xFFCCAC8B) : const Color(0xFF374151);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wealth Calculator',
          style: GoogleFonts.manrope(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.darkText),
            onPressed: _reset,
            tooltip: 'Reset',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildGoldSilverToggle(themeColor),
            const SizedBox(height: 48),
            _buildProfitHeader(),
            const SizedBox(height: 48),
            _buildInvestmentCard(themeColor),
            const SizedBox(height: 48),
            _buildTenureSelector(themeColor),
            const SizedBox(height: 56),
            _buildWeightProjectionCard(themeColor),
            const SizedBox(height: 24),
            _buildAutoInvestPromo(),
            const SizedBox(height: 48),
            _buildActionButtons(themeColor, accentColor),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldSilverToggle(Color themeColor) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Row(
        children: [
          _toggleItem('GOLD', isGold, () => setState(() => isGold = true)),
          _toggleItem('SILVER', !isGold, () => setState(() => isGold = false)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? (label == 'GOLD' ? const Color(0xFFB48C65) : const Color(0xFF1F2937)) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: active ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? Colors.white : const Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfitHeader() {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Column(
      children: [
        Text(
          'ESTIMATED PROFIT',
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '+${currency.format(estimatedProfit)}',
          style: GoogleFonts.manrope(
            color: const Color(0xFF0D9488),
            fontSize: 52,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFCCFBF1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'YOU EARN ${currency.format(estimatedProfit)} EXTRA',
            style: GoogleFonts.inter(
              color: const Color(0xFF0F766E),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryMetric('TOTAL INVESTED', currency.format(amount)),
            _buildSummaryMetric('MATURITY VALUE', currency.format(maturityValue)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: const Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentCard(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVESTMENT AMOUNT',
            style: GoogleFonts.inter(
              color: const Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹ ',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF111827),
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => amount = double.tryParse(val.replaceAll(',', '')) ?? 0),
                  style: GoogleFonts.manrope(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                  decoration: InputDecoration(
                    hintText: '2,000',
                    hintStyle: GoogleFonts.manrope(
                      color: const Color(0xFFE5E7EB),
                      fontWeight: FontWeight.w800,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 48,
                color: const Color(0xFF111827),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Most users invest ₹2,000',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenureSelector(Color themeColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SELECT TENURE',
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildUnitToggle('Mo', isMonths, () => setState(() => isMonths = true)),
                  _buildUnitToggle('Yr', !isMonths, () => setState(() => isMonths = false)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Stack(
          clipBehavior: Clip.none,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: themeColor.withValues(alpha: 0.4),
                inactiveTrackColor: const Color(0xFFF3F4F6),
                thumbColor: themeColor,
                trackHeight: 12,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                overlayColor: themeColor.withValues(alpha: 0.1),
                tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
                activeTickMarkColor: themeColor.withValues(alpha: 0.6),
                inactiveTickMarkColor: const Color(0xFFD1D5DB),
              ),
              child: Slider(
                value: tenureValue,
                min: 1,
                max: 8,
                divisions: 7,
                onChanged: (val) => setState(() => tenureValue = val),
              ),
            ),
            _buildTenureBubble(themeColor),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(8, (index) => Text(
            '${index + 1}${isMonths ? "MO" : "YR"}',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF9CA3AF),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildTenureBubble(Color themeColor) {
    // Basic calculation for thumb positioning relative to slider
    double percentage = (tenureValue - 1) / 7;
    return Positioned(
      top: -48,
      left: 10 + (MediaQuery.of(context).size.width - 68) * percentage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              '${tenureValue.round()} ${isMonths ? "Mo" : "Yr"}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            // Minimalist arrow indicator would go here if needed
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF111827) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            if (active) ...[
              Text(
                '${tenureValue.round()} ',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                color: active ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightProjectionCard(Color themeColor) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTIMATED ${isGold ? "GOLD" : "SILVER"} WEIGHT',
                style: GoogleFonts.inter(
                  color: AppColors.subtext,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isGold ? 'PURE 24K' : '999 SILVER',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: metalWeight.toStringAsFixed(3),
                  style: GoogleFonts.manrope(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                    letterSpacing: -1,
                  ),
                ),
                TextSpan(
                  text: ' gm',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inactive,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Worth ${currency.format(amount)} today',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE PRICE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoInvestPromo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_graph_rounded, color: Color(0xFF111827), size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Invest Plan',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  'Recommended for better returns',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color themeColor, Color accentColor) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [accentColor, themeColor],
            ),
            boxShadow: [
              BoxShadow(
                color: themeColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (amount <= 0) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SummaryScreen(
                  isGold: isGold,
                  amount: amount,
                  grams: metalWeight,
                )),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Start Investing',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.trending_up_rounded, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsPlanScreen())),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
            ),
            child: Text(
              'Set Monthly Plan',
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return Center(
      child: GestureDetector(
        onTap: _reset,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFB48C65).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                'RESET',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
