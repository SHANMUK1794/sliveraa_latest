import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../home/home_screen.dart';
import '../../utils/extensions.dart';
import 'package:lottie/lottie.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool isSuccess;
  final double amount;
  final String transactionId;
  final String paymentMethod;
  final String? userName;
  final String? errorMessage;

  const PaymentStatusScreen({
    super.key,
    required this.isSuccess,
    required this.amount,
    this.transactionId = 'TXN_PENDING',
    this.paymentMethod = 'UPI/Razorpay',
    this.userName = 'Silvra User',
    this.errorMessage,
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
                  ? 'You have successfully invested ₹${amount.toLocaleString()} in your account.'
                  : errorMessage ?? 'Your payment could not be processed. Please try again or contact support if the amount was debited.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            const SizedBox(height: 48),
            
            // Transaction Details Card with Slide-up Animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildTransactionCard(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // Buttons with fade-in
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: _buildActionButtons(context),
                );
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final lottieUrl = isSuccess
        ? 'https://lottie.host/80400b14-07d4-4f90-8e1d-c5643a6d71b8/6npxM9fK5w.json'
        : 'https://lottie.host/cb0b8a21-9964-42f4-8a4d-06487e472621/72Z1e6dAnP.json';

    // Celebration Lottie for success
    const coinBurstUrl = 'https://lottie.host/6276063e-6d73-455a-9d9e-108873099905/U4aXvjX9mH.json';

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (isSuccess)
          Positioned(
            top: -100,
            child: SizedBox(
              width: 400,
              height: 400,
              child: Lottie.network(
                coinBurstUrl,
                repeat: true,
              ),
            ),
          ),
        // Outer Glow/Blur
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isSuccess ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withValues(alpha: 0.1),
                blurRadius: 50,
                spreadRadius: 20,
              )
            ],
          ),
        ),
        // Lottie Animation
        SizedBox(
          width: 160,
          height: 160,
          child: Lottie.network(
            lottieUrl,
            repeat: false,
            fit: BoxFit.contain,
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
          _buildDetailRow('PAYMENT METHOD', paymentMethod, showMethodIcon: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showMethodIcon = false}) {
    IconData methodIcon = Icons.payment_rounded;
    if (value.toLowerCase().contains('upi')) {
      methodIcon = Icons.qr_code_2_rounded;
    } else if (value.toLowerCase().contains('card')) {
      methodIcon = Icons.credit_card_rounded;
    } else if (value.toLowerCase().contains('bank') || value.toLowerCase().contains('net')) {
      methodIcon = Icons.account_balance_rounded;
    }

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
                if (showMethodIcon) ...[
                  const SizedBox(width: 8),
                  Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(methodIcon, size: 12, color: const Color(0xFF1E293B)),
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
