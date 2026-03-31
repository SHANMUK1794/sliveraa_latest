import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'otp_verification_screen.dart';
import 'forgot_password_otp_screen.dart';
import '../../core/api_service.dart';
import '../../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Elegant warm off-white background from the design
    final Color bgColor = const Color(0xFFFCF8F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC59F70)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'GOLD & SILVER',
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Massive Central Elevated Card
            Container(
              padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Lock Badge
                  _buildLockResetBadge(),
                  
                  const SizedBox(height: 32),
                  
                  // Central Heading
                  Text(
                    'Forgot Password',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F172A),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle Text
                  Text(
                    'Please Enter Your Email Address To\nReceive a Verification Code.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Form Area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Pill shaped Input box
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Very light soft grey
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Try another way link
                  GestureDetector(
                    onTap: () {
                      // Future logic to toggle email/phone
                    },
                    child: Text(
                      'Try another way',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFC0392B), // Rust Red
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Send Button
                  GestureDetector(
                    onTap: _handleSendOtp,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFCAA779), Color(0xFFA67C41)], // Warm Gold Gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC1A27B).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Send',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                  
                  // Footer Inside Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remembered your password? ',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFC1A27B),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // Base Footer Text outside the card
            Text(
              'SECURE EDITORIAL GRADE ENCRYPTION',
              style: GoogleFonts.inter(
                color: const Color(0xFFCBD5E1),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLockResetBadge() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF3EAE0), // Very light soft gold
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFFC59F70), // Rich brown gold
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.manage_history_rounded, // Best fit for the reset-lock combination icon
              color: Color(0xFF4A3419), // Dark brown lock
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendOtp() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length > 10) cleanPhone = cleanPhone.substring(cleanPhone.length - 10);

      // We maintain the backend call structure as previously established
      await ApiService().sendOtp(cleanPhone, intent: 'reset-password');
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordOtpScreen(
              phoneNumber: '+91 $phone',
              intent: 'reset-password',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        String errorMsg = e.toString();
        if (e is DioException && e.response?.data != null) {
          errorMsg = e.response?.data['error'] ?? errorMsg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }
}
