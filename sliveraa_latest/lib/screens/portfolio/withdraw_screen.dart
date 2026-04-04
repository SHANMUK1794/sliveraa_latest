import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';

class WithdrawScreen extends StatefulWidget {
  final bool isGoldInitial;
  const WithdrawScreen({super.key, this.isGoldInitial = true});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  late bool isGold;
  final TextEditingController _amountController = TextEditingController();
  String selectedAmount = '₹2,000';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
    _amountController.text = '2000';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get withdrawableAmount => currentBalance * currentPrice;
  double get currentBalance => isGold ? AppState().goldGrams : AppState().silverGrams;
  double get currentPrice => isGold ? PriceData.goldPrice : PriceData.silverPrice;
  double get gramsEquivalent => (double.tryParse(_amountController.text) ?? 0) / currentPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF715B3E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Withdraw',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF715B3E),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Metal Toggle
            _buildMetalToggle(),
            
            const SizedBox(height: 24),
            
            // Withdrawable Amount Card
            _buildWithdrawableCard(),
            
            const SizedBox(height: 24),
            
            // Enter Amount Card
            _buildAmountInputCard(),
            
            const SizedBox(height: 24),
            
            // Bank Card
            _buildBankCard(),
            
            const SizedBox(height: 24),
            
            // Hint
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  'Minimum withdrawal: ₹100',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Actions
            isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB08C65)))
              : ElevatedButton(
                  onPressed: _processWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB08C65),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 12,
                    shadowColor: const Color(0xFFB08C65).withOpacity(0.4),
                  ),
                  child: Text(
                    'WITHDRAW NOW',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            
            const SizedBox(height: 12),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMetalToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGold = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isGold ? const Color(0xFFC6A17A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: isGold ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    'GOLD',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isGold ? Colors.white : const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGold = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isGold ? const Color(0xFF64748B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: !isGold ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    'SILVER',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: !isGold ? Colors.white : const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawableCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.04,
              child: Icon(Icons.payments_rounded, size: 84, color: Colors.black),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'WITHDRAWABLE AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${withdrawableAmount.toLocaleString()}',
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF111827),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can withdraw up to this amount',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9C3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '1.24 GM GOLD',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF854D0E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Live price applied',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w500,
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

  Widget _buildAmountInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTER AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Input Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Text(
                  '₹',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: GoogleFonts.manrope(color: const Color(0xFFCBD5E1)),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _amountController.text = withdrawableAmount.toInt().toString();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MAX',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Min ₹100 • Available ₹${withdrawableAmount.toLocaleString()}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          // Summary Row (Light grey box)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You will receive',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${(double.tryParse(_amountController.text) ?? 0).toLocaleString()}',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Based on live market price',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '≈ ${gramsEquivalent.toStringAsFixed(3)} gm',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB08C65),
                          ),
                        ),
                      ),
                      Text(
                        isGold ? 'Gold' : 'Silver',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB08C65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick Select Buttons
          Row(
            children: ['₹500', '₹1,000', '₹2,000', '₹5,000'].map((e) {
              bool isSelected = '₹${(double.tryParse(_amountController.text) ?? 0).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}' == e;
              // Simple check for match - might need better logic for exact match
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _amountController.text = e.replaceAll('₹', '').replaceAll(',', '');
                  }),
                  child: Container(
                    margin: EdgeInsets.only(right: e == '₹5,000' ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC6A17A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      e,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.account_balance_rounded, color: Color(0xFF64748B), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HDFC Bank •••• 4821',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Instant transfer enabled',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'Change',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB08C65),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB08C65), size: 20),
        ],
      ),
    );
  }

  void _processWithdrawal() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;
    
    if (amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum withdrawal is ₹100')));
      return;
    }

    if (amount > withdrawableAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient metal balance')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().withdraw(amount, isGold ? 'GOLD' : 'SILVER');
      
      if (response.statusCode == 200) {
        // Update local app state
        final weightDeducted = (response.data['weightDeducted'] as num).toDouble();
        if (isGold) {
          AppState().goldGrams -= weightDeducted;
        } else {
          AppState().silverGrams -= weightDeducted;
        }
        
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception(response.data['error'] ?? 'Withdrawal failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Withdrawal Initiated',
              style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your request for withdrawal of ₹${_amountController.text} has been received. Funds will be credited to your bank account within 2-3 business days.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111827),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Done', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
