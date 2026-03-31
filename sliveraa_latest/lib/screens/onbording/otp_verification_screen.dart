import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../home/home_screen.dart';
import 'package:dio/dio.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? intent;
  final String? password;
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.name,
    this.email,
    this.intent,
    this.password,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<void> _sendOtp() async {
    try {
      String cleanPhone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length >= 10) cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
      
      await ApiService().sendOtp(cleanPhone, intent: widget.intent);
    } catch (e) {
      String errorMsg = e.toString();
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['error'] ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
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

  String get _timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white for header space
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification',
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          // Faint Top background glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFF7ED).withValues(alpha: 0.8), // Faint orange tint
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFF7ED).withValues(alpha: 0.6), // Faint orange tint
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Body
          Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC), // Faint grey backing for form field body
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Verify your phone',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F172A),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Enter the 6-digit code sent to ',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: widget.phoneNumber,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // OTP Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            bool isFocused = _focusNodes[index].hasFocus;
                            bool hasText = _controllers[index].text.isNotEmpty;
                            
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.12,
                              height: MediaQuery.of(context).size.width * 0.13,
                              child: TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hintText: '·', // Faint tiny dot
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
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
                                  setState(() {}); // refresh border color logic
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
                        
                        // Timer logic
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Resend code in ',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _timerText,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFC1A27B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Check Spam Logic
                        Center(
                          child: GestureDetector(
                            onTap: _secondsRemaining == 0 ? () {
                              _sendOtp(); 
                              setState(() {
                                _secondsRemaining = 45;
                                _startTimer();
                              });
                            } : null,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Didn\'t receive the code? ',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Check Spam',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF2E5F52), // Forest Green check
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Verify Button
                        GestureDetector(
                          onTap: _isOtpComplete() ? () => _verifyOtp() : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isOtpComplete()
                                    ? const [Color(0xFFCAA779), Color(0xFFA67C41)] // Warm Gold Gradient
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
                                'Verify & Proceed',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 80),
                        
                        // Shield | Help Bottom Block
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCircleFooterIcon(Icons.shield_outlined, 'SECURITY'),
                            const SizedBox(width: 56),
                            _buildCircleFooterIcon(Icons.help_outline_rounded, 'HELP'),
                          ],
                        ),
                        
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleFooterIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  bool _isOtpComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((c) => c.text).join();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String cleanPhone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length >= 10) cleanPhone = cleanPhone.substring(cleanPhone.length - 10);

      final response = await ApiService().verifyOtp(
        cleanPhone, 
        otp, 
        name: widget.name, 
        email: widget.email,
        intent: widget.intent,
        password: widget.password,
      );
      
      if (mounted) {
        final responseData = response.data;
        if (responseData['token'] != null) {
          ApiService().setToken(responseData['token']);
        }
        
        AppState().updateFromMap(responseData);

        Navigator.pop(context); // Close loading
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
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
