import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/price_data.dart';
import 'summary_screen.dart';
import '../../theme/app_colors.dart';

class SavingsPlanScreen extends StatefulWidget {
  final bool isGoldInitial;
  final String initialFrequency;
  const SavingsPlanScreen({
    super.key, 
    this.isGoldInitial = true, 
    this.initialFrequency = 'Daily'
  });

  @override
  State<SavingsPlanScreen> createState() => _SavingsPlanScreenState();
}

class _SavingsPlanScreenState extends State<SavingsPlanScreen> {
  late bool isGold;
  String frequency = 'Daily'; // Daily, Weekly, Monthly
  double amount = 500;
  final List<double> quickAmounts = [50, 100, 200, 500];
  late TextEditingController _amountController;
  String selectedDay = 'TUE';
  int selectedDate = 15;

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
    frequency = widget.initialFrequency;
    _amountController = TextEditingController(text: amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get estimatedValue {
    // Correct SIP Calculation for 14% p.a.
    // FV = P * [((1 + i)^n - 1) / i] * (1 + i)
    double p = amount / 1.03; // Deduct 3% GST from every installment for accuracy
    double rAnnual = 0.14;
    double i; // periodic rate
    int n;    // total periods
    
    if (frequency == 'Daily') {
      i = rAnnual / 365;
      n = 365;
    } else if (frequency == 'Weekly') {
      i = rAnnual / 52;
      n = 52;
    } else {
      i = rAnnual / 12;
      n = 12;
    }

    // Standard Future Value of Annuity formula
    double fv = p * ((math.pow(1 + i, n) - 1) / i) * (1 + i);
    return fv;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = isGold ? AppColors.primaryBrownGold : AppColors.primarySilver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Digital Vault',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'ACCUMULATION STRATEGY',
              style: GoogleFonts.inter(
                color: themeColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings Plan',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                _buildMetalToggle(),
              ],
            ),
            const SizedBox(height: 32),
            _buildFrequencyToggle(),
            const SizedBox(height: 40),
            _buildAmountCard(),
            const SizedBox(height: 32),
            _buildQuickAmountChips(themeColor),
            const SizedBox(height: 32),
            _buildFrequencySelectionOptions(themeColor),
            const SizedBox(height: 32),
            _buildProjectionCard(themeColor),
            const SizedBox(height: 48),
            _buildStartSavingButton(themeColor),
            const SizedBox(height: 32),
            _buildSecurityInfo(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, color: Color(0xFF94A3B8), size: 18),
            const SizedBox(width: 12),
            const Icon(Icons.shield_outlined, color: Color(0xFF94A3B8), size: 18),
            const SizedBox(width: 12),
            const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8), size: 18),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '99.9% Pure LBMA Accredited ${isGold ? 'Gold' : 'Silver'}\nInsured & Secured by Global Custodians',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelectionOptions(Color themeColor) {
    if (frequency == 'Daily') return const SizedBox.shrink();

    if (frequency == 'Weekly') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'SELECT INVESTMENT DAY',
            style: GoogleFonts.inter(
              color: const Color(0xFF4B5563),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'].map((day) {
              bool isSelected = selectedDay == day;
              return GestureDetector(
                onTap: () => setState(() => selectedDay = day),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? themeColor : const Color(0xFFF1F5F9)),
                    boxShadow: isSelected ? [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 4)] : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    if (frequency == 'Monthly') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'SELECT MONTHLY DATE',
            style: GoogleFonts.inter(
              color: const Color(0xFF4B5563),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              int date = index + 1;
              bool isSelected = selectedDate == date;
              return GestureDetector(
                onTap: () => setState(() => selectedDate = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? themeColor : const Color(0xFFF1F5F9)),
                    boxShadow: isSelected ? [BoxShadow(color: themeColor.withValues(alpha: 0.2), blurRadius: 4)] : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    date.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMetalToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _miniToggleItem('Gold', isGold, () => setState(() => isGold = true)),
          _miniToggleItem('Silver', !isGold, () => setState(() => isGold = false)),
        ],
      ),
    );
  }

  Widget _miniToggleItem(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: active ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyToggle() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _freqItem('Daily'),
          _freqItem('Weekly'),
          _freqItem('Monthly'),
        ],
      ),
    );
  }

  Widget _freqItem(String label) {
    bool active = frequency == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => frequency = label),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: active ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final themeColor = isGold ? AppColors.primaryBrownGold : AppColors.primarySilver;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Text(
            '${frequency.toUpperCase()} SAVINGS',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: themeColor,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: IntrinsicWidth(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textAlign: TextAlign.center,
                      cursorHeight: 48,
                      cursorWidth: 2,
                      cursorColor: const Color(0xFF1F2937),
                      style: GoogleFonts.manrope(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                      ),
                      onChanged: (val) {
                        double? newVal = double.tryParse(val.replaceAll(',', ''));
                        if (newVal != null) {
                          setState(() {
                            amount = newVal;
                          });
                        }
                      },
                      controller: _amountController,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChips(Color themeColor) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: quickAmounts.map((amt) {
          bool selected = amount == amt;
          return GestureDetector(
            onTap: () {
              setState(() {
                amount = amt;
                _amountController.text = amt.toStringAsFixed(0);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? themeColor : const Color(0xFFE2E8F0), 
                  width: selected ? 2 : 1
                ),
                boxShadow: selected ? [
                  BoxShadow(color: themeColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                ] : null,
              ),
              child: Text(
                '₹${amt.toInt()}',
                style: GoogleFonts.inter(
                  color: selected ? themeColor : const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProjectionCard(Color themeColor) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFFFFBEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMATED VALUE IN 1 YEAR (14% P.A.)',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatter.format(estimatedValue),
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '*Based on average market trends for ${isGold ? '24K Gold' : 'Fine Silver'}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5B98A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.lock_rounded, color: Color(0xFF332009), size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildStartSavingButton(Color themeColor) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isGold ? AppColors.goldGradient : AppColors.silverGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
          double price = PriceData.getPrice(isGold);
          double netAmount = amount / 1.03;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SummaryScreen(
              isGold: isGold,
              amount: amount, // Total paid
              grams: netAmount / price, // Correct allotment
            )),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          'START SAVING',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

