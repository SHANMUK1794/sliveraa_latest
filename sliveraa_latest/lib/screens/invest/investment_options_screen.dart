import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../core/price_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import 'summary_screen.dart';
import '../../widgets/price_chart.dart';

class InvestmentOptionsScreen extends StatefulWidget {
  final bool isGold;
  const InvestmentOptionsScreen({super.key, required this.isGold});

  @override
  State<InvestmentOptionsScreen> createState() => _InvestmentOptionsScreenState();
}

class _InvestmentOptionsScreenState extends State<InvestmentOptionsScreen> {
  bool isSIP = true;
  String frequency = 'Monthly';
  double amount = 500.0; // Default min SIP for Gold
  
  // For Silver UI variation
  double quantity = 1.0; 

  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: amount.toInt().toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PriceProvider>(
      builder: (context, priceProvider, child) {
        final currentPrice = widget.isGold ? priceProvider.goldPrice : priceProvider.silverPrice;
        
        return Scaffold(
          backgroundColor: widget.isGold ? const Color(0xFFFEF9EC) : const Color(0xFF111827),
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 340,
                  child: _buildTopSection(currentPrice),
                ),
                _buildSelectionPanel(currentPrice),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final textColor = widget.isGold ? Colors.black : Colors.white;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isGold ? Colors.white : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.isGold ? Colors.transparent : Colors.white24),
              ),
              child: Text(
                'Need Help?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection(double currentPrice) {
    final double annualRate = 0.14;
    double projectedReturn;
    double earnings;
    double totalInvested;

    if (isSIP) {
      final double r;
      final int n;
      
      if (frequency == 'Daily') {
        r = annualRate / 365;
        n = 365 * 5;
        totalInvested = amount * 365 * 5;
      } else if (frequency == 'Weekly') {
        r = annualRate / 52;
        n = 52 * 5;
        totalInvested = amount * 52 * 5;
      } else {
        // Monthly
        r = annualRate / 12;
        n = 12 * 5;
        totalInvested = amount * 12 * 5;
      }
      
      projectedReturn = amount * ((math.pow(1 + r, n) - 1) / r) * (1 + r);
    } else {
      // One-Time Lumpsum Formula: P * (1 + r)^n
      totalInvested = quantity * currentPrice;
      projectedReturn = totalInvested * math.pow(1 + annualRate, 5);
    }

    earnings = projectedReturn - totalInvested;

    final textColor = widget.isGold ? const Color(0xFF0F172A) : Colors.white;
    final subColor = widget.isGold ? const Color(0xFF64748B) : Colors.white70;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isSIP ? 'Projected returns in 5 years (SIP)' : 'Projected returns in 5 years',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₹${projectedReturn.toLocaleString(decimals: 2)}',
                style: GoogleFonts.manrope(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: _buildProjectionStat('Investment:', '₹${totalInvested.toLocaleString(decimals: 0)}', widget.isGold)),
              Container(width: 1, height: 16, color: Colors.grey.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 12)),
              Flexible(child: _buildProjectionStat('Earning:', '₹${earnings.toLocaleString(decimals: 0)} 🥳', widget.isGold)),
            ],
          ),
          const SizedBox(height: 32),
          _buildPerformanceLink(widget.isGold ? 'gold' : 'silver'),
        ],
      ),
    );
  }

  Widget _buildProjectionStat(String label, String val, bool isGold) {
    final labelColor = isGold ? const Color(0xFF64748B) : Colors.white70;
    final valColor = isGold ? const Color(0xFF0F172A) : Colors.white;
    
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: RichText(
        text: TextSpan(
          text: '$label ',
          style: GoogleFonts.inter(fontSize: 13, color: labelColor, fontWeight: FontWeight.w500),
          children: [
            TextSpan(
              text: val,
              style: GoogleFonts.inter(fontSize: 13, color: valColor, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceLink(String metal) {
    return GestureDetector(
      onTap: _showPerformanceBottomSheet,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 14, color: widget.isGold ? const Color(0xFFB08C65) : Colors.white60),
          const SizedBox(width: 8),
          Text(
            'View $metal performance',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isGold ? const Color(0xFFB08C65) : Colors.white60,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.call_made_rounded, size: 14, color: widget.isGold ? const Color(0xFFB08C65) : Colors.white60),
        ],
      ),
    );
  }

  Widget _buildSelectionPanel(double currentPrice) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                // Live Price Badge in Selection Panel (Subtle)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live ${widget.isGold ? "Gold" : "Silver"} Price: ₹${currentPrice.toLocaleString()}/gm',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Toggle
                Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildModeButton('Setup SIP', isSIP, () => setState(() => isSIP = true)),
                _buildModeButton('One Time', !isSIP, () => setState(() => isSIP = false)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          if (isSIP) ...[
            // Frequency Pills
            Row(
              children: [
                Expanded(child: _buildFreqPill('Daily')),
                const SizedBox(width: 8),
                Expanded(child: _buildFreqPill('Monthly')),
                const SizedBox(width: 8),
                Expanded(child: _buildFreqPill('Weekly')),
              ],
            ),
            const SizedBox(height: 40),
          ],
          
          // Amount / Quantity Input
          _buildInteractiveInput(),
          
          const SizedBox(height: 12),
          Text(
            isSIP 
              ? 'Amount payable: ₹${amount.toLocaleString(decimals: 0)}' 
              : 'Amount payable: ₹${(currentPrice * quantity * 1.03).toLocaleString(decimals: 0)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 32),
          
  // Quick Selection
          Row(
            children: [
              if (isSIP) ...[
                Expanded(child: _buildQuickPill('₹500', () => _selectAmount(500))),
                const SizedBox(width: 8),
                Expanded(child: _buildQuickPill('₹1000', () => _selectAmount(1000))),
                const SizedBox(width: 8),
                Expanded(child: _buildQuickPill('₹2000', () => _selectAmount(2000))),
              ] else ...[
                Expanded(child: _buildQuickPill('2 gm', () => _selectGrams(2))),
                const SizedBox(width: 8),
                Expanded(child: _buildQuickPill('5 gm', () => _selectGrams(5))),
                const SizedBox(width: 8),
                Expanded(child: _buildQuickPill('10 gm', () => _selectGrams(10))),
              ],
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Proceed Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                double totalAmount;
                double totalGrams;

                if (isSIP) {
                  // User entered AMOUNT (Inclusive of GST)
                  totalAmount = double.tryParse(_amountController.text) ?? amount;
                  if (totalAmount < 500) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum SIP amount is ₹500')));
                     return;
                  }
                  totalGrams = (totalAmount / 1.03) / currentPrice;
                } else {
                  // User selected GRAMS (Exclusive of GST)
                  totalGrams = double.tryParse(_amountController.text) ?? quantity;
                  totalAmount = (totalGrams * currentPrice) * 1.03;
                }
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(
                      isGold: widget.isGold, 
                      amount: totalAmount,
                      grams: totalGrams,
                      isSIP: isSIP,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isGold ? const Color(0xFFB08C65) : const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Proceed',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (widget.isGold ? const Color(0xFFB08C65) : const Color(0xFF1E293B)) : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreqPill(String label) {
    bool isSelected = frequency == label;
    return GestureDetector(
      onTap: () => setState(() => frequency = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected 
              ? Border.all(color: const Color(0xFF0F172A), width: 1.5)
              : Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildRoundButton(Icons.remove, () {
          setState(() {
            if (isSIP) {
              if (amount > 500) {
                amount -= 100;
                _amountController.text = amount.toInt().toString();
              }
            } else {
              if (quantity > 1) {
                quantity -= 1;
                _amountController.text = quantity.toStringAsFixed(2);
              }
            }
          });
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSIP ? '₹' : 'gm',
                style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      double? v = double.tryParse(val);
                      if (v != null) {
                        if (isSIP) {
                          amount = v;
                        } else {
                          quantity = v;
                        }
                      }
                    });
                  },
                  style: GoogleFonts.manrope(fontSize: 48, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildRoundButton(Icons.add, () {
          setState(() {
            if (isSIP) {
              amount += 100;
              _amountController.text = amount.toInt().toString();
            } else {
              quantity += 1;
              _amountController.text = quantity.toStringAsFixed(2);
            }
          });
        }),
      ],
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFFB08C65)),
      ),
    );
  }

  Widget _buildQuickPill(String label, VoidCallback onTap) {
    bool isSelected = !isSIP && (label.contains(quantity.toStringAsFixed(0)));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? (widget.isGold ? const Color(0xFFB08C65) : const Color(0xFF1E293B)) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFF1F5F9)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  void _selectGrams(double g) {
    setState(() {
      isSIP = false;
      quantity = g;
      _amountController.text = quantity.toStringAsFixed(0);
    });
  }

  void _selectAmount(double a) {
    setState(() {
      isSIP = true;
      amount = a;
      _amountController.text = amount.toInt().toString();
    });
  }

  void _showPerformanceBottomSheet() {
    final metalName = widget.isGold ? 'Gold' : 'Silver';
    final buttonColor = widget.isGold ? const Color(0xFFB45309) : const Color(0xFF1E293B); 
    final lineColor = widget.isGold ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8); 
    final performance = PriceData.getPerformance(widget.isGold, '5Y');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    'Annual Returns with $metalName',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              performance,
              style: GoogleFonts.inter(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF16A34A),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '5 year annualised performance',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 220,
              width: double.infinity,
              child: PriceChart(
                isGold: widget.isGold,
                timeframe: '5Y',
                lineColor: lineColor,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'Got it',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
