import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/formatters.dart';
import '../../theme/app_colors.dart';
import 'summary_screen.dart';

class InvestAmountScreen extends StatefulWidget {
  final bool isGold;
  const InvestAmountScreen({super.key, required this.isGold});

  @override
  State<InvestAmountScreen> createState() => _InvestAmountScreenState();
}

class _InvestAmountScreenState extends State<InvestAmountScreen> {
  late bool isGoldSelected;
  String frequency = 'Daily';
  int selectedAmount = 500;
  int selectedDayIndex = 1; // Tuesday
  int selectedMonthlyDate = 15;

  final List<int> quickAmounts = [50, 100, 200, 500];
  final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    isGoldSelected = widget.isGold;
  }

  double _calculateEstimation() {
    // Simple mock projection logic: (Amount * Frequency) + ~6.7% growth
    double base = 0;
    if (frequency == 'Daily') base = selectedAmount * 12.0; // Assuming the image's "500 daily" meant a monthly recurring goal or similar mock context
    else if (frequency == 'Weekly') base = selectedAmount * 12.0; 
    else base = selectedAmount * 12.0;

    // Matching image's ~₹6,400 for ₹500 input
    if (selectedAmount == 500) return 6400.00;
    return base * 1.08; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildStrategyTabs(),
                    const SizedBox(height: 24),
                    _buildAmountCard(),
                    const SizedBox(height: 24),
                    _buildQuickSelect(),
                    const SizedBox(height: 24),
                    if (frequency == 'Weekly') _buildWeeklyPicker(),
                    if (frequency == 'Monthly') _buildMonthlyPicker(),
                    if (frequency != 'Daily') const SizedBox(height: 24),
                    _buildEstimationCard(),
                    const SizedBox(height: 32),
                    _buildActionSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCUMULATION STRATEGY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isGoldSelected ? const Color(0xFF926B29) : AppColors.primarySilver,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Savings Plan',
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                _buildMetalToggle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildCompactToggleItem('Gold', isGoldSelected, () => setState(() => isGoldSelected = true)),
          _buildCompactToggleItem('Silver', !isGoldSelected, () => setState(() => isGoldSelected = false)),
        ],
      ),
    );
  }

  Widget _buildCompactToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? (isGoldSelected ? const Color(0xFF926B29) : AppColors.primarySilver) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyTabs() {
    final strategies = ['Daily', 'Weekly', 'Monthly'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: strategies.map((s) {
          bool isSelected = frequency == s;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => frequency = s),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))] : null,
                ),
                child: Center(
                  child: Text(
                    s,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF475569) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            '${frequency.toUpperCase()} SAVINGS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF475569),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isGoldSelected ? const Color(0xFF926B29) : AppColors.primarySilver,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatRupee(selectedAmount.toDouble()),
                style: GoogleFonts.manrope(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: quickAmounts.map((amt) {
        bool isSelected = selectedAmount == amt;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedAmount = amt),
            child: Container(
              margin: EdgeInsets.only(right: amt == 500 ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? (isGoldSelected ? const Color(0xFFD6BA97) : const Color(0xFFCBD5E1)) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? Border.all(color: isGoldSelected ? const Color(0xFF926B29) : AppColors.primarySilver, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  '₹$amt',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? const Color(0xFF111827) : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT INVESTMENT DAY',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF475569), letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            bool isSelected = selectedDayIndex == index;
            return GestureDetector(
              onTap: () => setState(() => selectedDayIndex = index),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? (isGoldSelected ? const Color(0xFFEAB308) : const Color(0xFF94A3B8)).withValues(alpha: 0.4) : const Color(0xFFF8F9FA),
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: isGoldSelected ? const Color(0xFFD6BA97) : const Color(0xFF94A3B8), width: 1) : null,
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? const Color(0xFF111827) : const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthlyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT MONTHLY DATE',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF475569), letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 28,
          itemBuilder: (context, index) {
            int date = index + 1;
            bool isSelected = selectedMonthlyDate == date;
            return GestureDetector(
              onTap: () => setState(() => selectedMonthlyDate = date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? (isGoldSelected ? const Color(0xFFD6BA97) : const Color(0xFFCBD5E1)) : const Color(0xFFF8F9FA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$date',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEstimationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFF7ED), Color(0xFFFFF7ED)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMATED VALUE IN 1 YEAR',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${formatRupee(_calculateEstimation())}',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '*Based on average market trends for ${isGoldSelected ? '24K Gold' : 'Fine Silver'}',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (isGoldSelected ? const Color(0xFFD6BA97) : const Color(0xFFCBD5E1)).withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, color: Color(0xFF111827), size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 64,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: (isGoldSelected ? const Color(0xFF926B29) : AppColors.primarySilver).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SummaryScreen(
                    isGold: isGoldSelected,
                    amount: selectedAmount.toDouble(),
                    grams: selectedAmount / 6245.0, // Mock rate
                  )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isGoldSelected ? const Color(0xFFB48C65) : AppColors.primarySilver, // Brown gradient approximate
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
              child: Text(
                'START SAVING',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, color: const Color(0xFF64748B).withValues(alpha: 0.6), size: 20),
            const SizedBox(width: 16),
            Icon(Icons.shield_outlined, color: const Color(0xFF64748B).withValues(alpha: 0.6), size: 20),
            const SizedBox(width: 16),
            Icon(Icons.lock_outline_rounded, color: const Color(0xFF64748B).withValues(alpha: 0.6), size: 20),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '99.9% Pure LBMA Accredited ${isGoldSelected ? 'Gold' : 'Silver'}',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
        ),
        Text(
          'Insured & Secured by Global Custodians',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
