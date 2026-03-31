import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../home/home_screen.dart';
import 'create_new_password_screen.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String intent;

  const ForgotPasswordOtpScreen({
    super.key,
    required this.phoneNumber,
    required this.intent,
  });

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F5), // Warm off-white background
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Central White Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
                children: [
                  // Lock Badge with Checkmark
                  _buildLockBadge(),
                  
                  const SizedBox(height: 32),
                  
                  // Text Content
                  Text(
                    'Create New\nPassword',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Enter the 6-digit code sent to ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: widget.phoneNumber,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // OTP Input Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      bool hasText = _controllers[index].text.isNotEmpty;
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.11,
                        height: 52,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '·',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: hasText ? const Color(0xFFC1A27B) : const Color(0xFFE2E8F0),
                                width: hasText ? 1.5 : 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFC1A27B), width: 1.5),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Resend Link
                  GestureDetector(
                    onTap: _secondsRemaining == 0 ? () async {
                      // Actual Resend logic
                      try {
                        String cleanPhone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
                        if (cleanPhone.length > 10) cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
                        
                        await ApiService().sendOtp(cleanPhone, intent: widget.intent);
                        
                        setState(() {
                          _secondsRemaining = 60;
                          _startTimer();
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verification code resent!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to resend code: $e')),
                        );
                      }
                    } : null,
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC0392B), // Rust Red
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Verify Button
                  GestureDetector(
                    onTap: _isOtpComplete() ? _verifyOtp : null,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isOtpComplete()
                              ? const [Color(0xFFCAA779), Color(0xFFA67C41)]
                              : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: _isOtpComplete()
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFC1A27B).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'VERIFY',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Contact Support
                  Text(
                    'NEED HELP? CONTACT SUPPORT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Outer Footer
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

  Widget _buildLockBadge() {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Color(0xFFF3EAE0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFC59F70),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Color(0xFF4A3419),
                size: 32,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFC1A27B),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isOtpComplete() {
    return _controllers.every((c) => c.text.isNotEmpty);
  }

  Future<void> _verifyOtp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String otp = _controllers.map((c) => c.text).join();
      String cleanPhone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length > 10) cleanPhone = cleanPhone.substring(cleanPhone.length - 10);

      final response = await ApiService().verifyOtp(
        cleanPhone, 
        otp, 
        intent: widget.intent,
      );
      
      if (mounted) {
        // Store the reset token so it can be used on the CreateNewPasswordScreen
        if (response.data != null && response.data['token'] != null) {
          ApiService().setToken(response.data['token']);
        }
        
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateNewPasswordScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        String errorMsg = e.toString();
        if (e is DioException && e.response?.data != null) {
          final data = e.response?.data;
          errorMsg = data is Map ? (data['message'] ?? data['error'] ?? errorMsg) : errorMsg;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    }
  }
}
