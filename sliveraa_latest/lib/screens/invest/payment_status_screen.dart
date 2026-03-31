import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../home/home_screen.dart';
import '../../utils/extensions.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool isSuccess;
  final double amount;
  final String transactionId;
  final String paymentMethod;
  final String? userName;

  const PaymentStatusScreen({
    super.key,
    required this.isSuccess,
    required this.amount,
    this.transactionId = 'INV483920',
    this.paymentMethod = 'UPI',
    this.userName = 'Rahul Sharma',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 20),
            ),
          ),
        ),
        title: Text(
          'Payment Status',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Status Icon with Blur Effect
            _buildStatusIcon(),
            
            const SizedBox(height: 32),
            
            // Status Text
            Text(
              isSuccess ? 'Investment Successful' : 'Investment Unsuccessful',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSuccess 
                  ? 'You have successfully invested ₹${amount.toLocaleString()} with $userName.'
                  : 'Your Payment is Unsuccessfull',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Transaction Details Card
            _buildTransactionCard(),
            
            const SizedBox(height: 48),
            
            // Buttons
            _buildActionButtons(context),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final color = isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow/Blur
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 10,
              )
            ],
          ),
        ),
        // Main Circle
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Icon(
            isSuccess ? Icons.check_rounded : Icons.close_rounded,
            color: Colors.white,
            size: 50,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard() {
    final String currentDate = DateFormat('Today, h:mm a').format(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('TRANSACTION ID', transactionId),
          _buildDivider(),
          _buildDetailRow('DATE', currentDate),
          _buildDivider(),
          _buildDetailRow('AMOUNT PAID', '₹${amount.toLocaleString()}'),
          _buildDivider(),
          _buildDetailRow('PAYMENT METHOD', paymentMethod, showUpiIcon: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showUpiIcon = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                if (showUpiIcon) ...[
                  const SizedBox(width: 8),
                  Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined, size: 12, color: Color(0xFF1E293B)),
                ),
              ],
            ],
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: const Color(0xFFF1F5F9), thickness: 1),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // VIEW INVESTMENT
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFCAA779), Color(0xFFA67C41)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC1A27B).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to portfolio or investment summary
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const HomeScreen()), 
                  (route) => false
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'VIEW INVESTMENT',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // BACK TO HOME
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const HomeScreen()), 
                (route) => false
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              'BACK TO HOME',
              style: GoogleFonts.manrope(
                color: const Color(0xFF475569),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
