import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import 'otp_verification_screen.dart';

class LoginWithOtpScreen extends StatefulWidget {
  final String? initialPhone;
  final String? initialPassword;
  const LoginWithOtpScreen({super.key, this.initialPhone, this.initialPassword});
 
  @override
  State<LoginWithOtpScreen> createState() => _LoginWithOtpScreenState();
}
 
class _LoginWithOtpScreenState extends State<LoginWithOtpScreen> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Elegant off-white background from the design
    final Color bgColor = const Color(0xFFFCFCFD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Match standard brand leading or retain SILVARA header
        leading: widget.initialPhone == null // Optional back logic or keep it as close
            ? null 
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'SILVARA',
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Refined 3D Coin Logo
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Hero Text
            Text(
              'Secure access to your\ninvestments',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Institutional grade security for your digital assets',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF475569),
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Massive White Card encapsulating inputs
            Container(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOBILE NUMBER',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mobile Input Field Frame
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 16),
                          child: Text(
                            '+91',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFFE2E8F0),
                        ),
                        Expanded(
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
                              hintText: 'Enter 10 digit number',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Continue Button with warm gold hue
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue with OTP',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Shield Footer Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF0F766E), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% secure & encrypted institutional custody',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0F766E),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            // Bottom Footer
            Container(height: 1, color: const Color(0xFFF1F5F9)),
            const SizedBox(height: 24),
            
            Text(
              '© 2024 The Digital Vault. Secure Institutional Grade Encryption.',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: [
                _footerLink('PRIVACY POLICY'),
                _footerLink('TERMS OF GOLD'),
                _footerLink('GUARANTEE'),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _footerLink(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
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

      await ApiService().sendOtp(cleanPhone, intent: 'login');
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: '+91 $phone',
              intent: 'login',
              password: widget.initialPassword,
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
