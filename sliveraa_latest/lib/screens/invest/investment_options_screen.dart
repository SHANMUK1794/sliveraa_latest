import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String frequency = 'Daily';
  double amount = 50.0;
  
  // For Silver UI variation
  double quantity = 1.0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isGold ? const Color(0xFFFEF9EC) : const Color(0xFF111827),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 340,
              child: _buildTopSection(),
            ),
            _buildSelectionPanel(),
          ],
        ),
      ),
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

  Widget _buildTopSection() {
    if (widget.isGold) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Projected returns in 5 years',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '₹${(amount * 1.29).toStringAsFixed(2)}', // Simulating a higher value
              style: GoogleFonts.manrope(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProjectionStat('Investment:', '₹${amount.toStringAsFixed(2)}'),
                Container(width: 1, height: 16, color: Colors.grey.withOpacity(0.3), margin: const EdgeInsets.symmetric(horizontal: 12)),
                _buildProjectionStat('Earning:', '₹${(amount * 0.29).toStringAsFixed(2)} 🥳'),
              ],
            ),
            const SizedBox(height: 32),
            _buildPerformanceLink('gold'),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Amount',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF475569), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '₹${(PriceData.silverPrice * quantity).toLocaleString()}',
                    style: GoogleFonts.manrope(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'for $quantity gm',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildPerformanceLink('silver'),
          ],
        ),
      );
    }
  }

  Widget _buildProjectionStat(String label, String val) {
    return RichText(
      text: TextSpan(
        text: '$label ',
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
        children: [
          TextSpan(
            text: val,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF0F172A), fontWeight: FontWeight.w800),
          ),
        ],
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

  Widget _buildSelectionPanel() {
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
              ? 'Amount payable: ₹${amount.toLocaleString()}' 
              : 'Amount payable: ₹${((widget.isGold ? PriceData.goldPrice : PriceData.silverPrice) * quantity * 1.03).toLocaleString()}',
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
              Expanded(child: _buildQuickPill('2 gm', () => _selectGrams(2))),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickPill('5 gm', () => _selectGrams(5))),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickPill('10 gm', () => _selectGrams(10))),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Proceed Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                final double currentPrice = widget.isGold ? PriceData.goldPrice : PriceData.silverPrice;
                double totalAmount;
                double totalGrams;

                if (isSIP) {
                  // User entered AMOUNT (Inclusive of GST)
                  totalAmount = amount;
                  totalGrams = (amount / 1.03) / currentPrice;
                } else {
                  // User selected GRAMS (Exclusive of GST)
                  totalGrams = quantity;
                  totalAmount = (quantity * currentPrice) * 1.03;
                }
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(
                      isGold: widget.isGold, 
                      amount: totalAmount,
                      grams: totalGrams,
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
              if (amount > 50) amount -= 50;
            } else {
              if (quantity > 1) quantity -= 1;
            }
          });
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                '₹',
                style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isSIP ? amount.toStringAsFixed(0) : (quantity * (widget.isGold ? PriceData.goldPrice : PriceData.silverPrice)).toStringAsFixed(0),
                    style: GoogleFonts.manrope(fontSize: 56, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildRoundButton(Icons.add, () {
          setState(() {
            if (isSIP) {
              amount += 50;
            } else {
              quantity += 1;
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
