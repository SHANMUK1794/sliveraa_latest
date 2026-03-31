import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';

import '../invest/payment_status_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate payment processing delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Toggle this for testing failure: widget.amount == 1337
        bool isSuccess = true; 
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentStatusScreen(
              isSuccess: isSuccess,
              amount: widget.amount,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProcessingIcon(),
              const SizedBox(height: 48),
              Text(
                'Processing Payment...',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please do not close the app or press the back button.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL PAID',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '₹${widget.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrownGold.withOpacity(0.2)),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrownGold),
          ),
        ),
        const Icon(Icons.security_rounded, size: 40, color: Color(0xFF1E293B)),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFFDCFCE7),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 60, color: Color(0xFF16A34A)),
    );
  }
}
