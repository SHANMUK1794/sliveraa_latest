import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/extensions.dart';
import '../../theme/app_colors.dart';
import '../home/payment_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final bool isGold;
  final double totalAmount;
  final String metalType;

  const CheckoutScreen({
    super.key, 
    required this.isGold, 
    required this.totalAmount,
    required this.metalType,
  });

  @override
  Widget build(BuildContext context) {
    bool isLargeAmount = totalAmount >= 100000;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkText),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Need Help?',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildAmountInfo(context),
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isLargeAmount ? _buildLargeAmountOptions() : _buildSmallAmountOptions(),
            ),
          ),
          if (isLargeAmount) _buildLimitNotice(),
          _buildPayButton(isLargeAmount, context),
        ],
      ),
    );
  }

  Widget _buildAmountInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          'Buying ${isGold ? '0.1' : '868'}gm $metalType for',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '₹${totalAmount.toLocaleString()}',
            style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'in ${metalType.characters.first.toUpperCase() + metalType.substring(1)} Savings',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showBreakdownModal(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isGold ? const Color(0xFFF5EDE3) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View breakdown',
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    fontWeight: FontWeight.w700, 
                    color: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_outward_rounded, 
                  size: 14, 
                  color: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallAmountOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentOffers(),
        const SizedBox(height: 32),
        Text(
          'Pay via UPI',
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildUPIItem('Paytm', Icons.account_balance_wallet_rounded),
            _buildUPIItem('PhonePe', Icons.wallet_rounded),
            _buildUPIItem('GPay', Icons.account_balance_wallet_outlined),
            _buildUPIItem('Jupiter', Icons.rocket_launch_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeAmountOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pay via NetBanking',
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBankItem('HDFC Bank', Icons.account_balance),
            _buildBankItem('ICICI Bank', Icons.account_balance),
            _buildBankItem('Axis Bank', Icons.account_balance),
            _buildBankItem('All banks', Icons.apps),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          'Pay via Bank Transfer',
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBankItem('SBI Bank', Icons.account_balance),
            _buildBankItem('Kotak Bank', Icons.account_balance),
            _buildBankItem('Other Banks', Icons.more_horiz),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOffers() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.percent_rounded, color: Colors.purple, size: 24),
          const SizedBox(width: 12),
          Text(
            'Payment Offers',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
          ),
          const Spacer(),
          Text(
            'View all offers',
            style: GoogleFonts.inter(
              fontSize: 12, 
              fontWeight: FontWeight.w700, 
              color: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_rounded, 
            size: 14, 
            color: isGold ? const Color(0xFFB45309) : const Color(0xFF1E293B)
          ),
        ],
      ),
    );
  }

  Widget _buildUPIItem(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Icon(
            icon, 
            color: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B), 
            size: 28
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildBankItem(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Icon(
            icon, 
            color: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B), 
            size: 28
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildLimitNotice() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5EDE3),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFC8A27B)),
          const SizedBox(width: 10),
          Text(
            'Pay via UPI is allowed for investments under ₹1 lakh',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(bool isLarge, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_rounded, 
                size: 16, 
                color: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)
              ),
              const SizedBox(width: 8),
              Text(
                '100% secured payment',
                style: GoogleFonts.inter(
                  fontSize: 12, 
                  fontWeight: FontWeight.w600, 
                  color: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentScreen(amount: totalAmount)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLarge ? const Color(0xFFE2E8F0) : (isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isLarge ? 'Pay ₹${totalAmount.toLocaleString()}' : 'Autosave ₹${totalAmount.toLocaleString()}',
                  style: GoogleFonts.manrope(
                    fontSize: 18, 
                    fontWeight: FontWeight.w700, 
                    color: isLarge ? const Color(0xFF94A3B8) : Colors.white
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBreakdownModal(BuildContext context) {
    final double metalValue = totalAmount / 1.03;
    final double gstValue = totalAmount - metalValue;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Breakdown',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            _buildBreakdownRow('${metalType.characters.first.toUpperCase() + metalType.substring(1)} value', '₹${metalValue.toLocaleString()}'),
            const SizedBox(height: 16),
            _buildBreakdownRow('GST (3%)', '₹${gstValue.toLocaleString()}'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildBreakdownRow('Total Amount', '₹${totalAmount.toLocaleString()}', isTotal: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGold ? AppColors.primaryBrownGold : const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Close', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 14, 
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? const Color(0xFF111827) : const Color(0xFF64748B)
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: isTotal ? 18 : 14, 
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
                color: const Color(0xFF111827)
              ),
            ),
          ),
        ),
      ],
    );
  }
}
