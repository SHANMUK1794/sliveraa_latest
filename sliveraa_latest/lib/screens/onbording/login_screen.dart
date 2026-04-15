import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'login_with_otp_screen.dart';
import '../home/home_screen.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import '../../core/biometric_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    // Automatic Biometric Prompt (PhonePe Style)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAutoBiometric();
    });
  }

  Future<void> _triggerAutoBiometric() async {
    // Wait a brief moment for the UI to settle
    await Future.delayed(const Duration(milliseconds: 500));
    final appState = AppState();
    if (appState.isBiometricEnabled && (appState.userId.isNotEmpty || appState.biometricUserId.isNotEmpty)) {
      _handleBiometricLogin();
    }
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() => _isBiometricSupported = available);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final appState = AppState();
    if (!appState.isBiometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable biometric login in Security settings first.')),
      );
      return;
    }

    final authenticated = await _biometricService.authenticate(
      reason: 'Use your fingerprint to login safely into Silvra',
    );

    if (authenticated) {
      if (appState.userId.isNotEmpty || appState.biometricUserId.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        try {
          // If the in-memory token was cleared during "Logout", restore it from storage
          final prefs = await SharedPreferences.getInstance();
          final savedToken = prefs.getString('authToken');
          
          if (savedToken != null && savedToken.isNotEmpty) {
            ApiService().setToken(savedToken);
          }

          final response = await ApiService().getUserProfile();
          if (mounted) {
            Navigator.pop(context); // Close loading
             appState.updateFromMap(response.data);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session expired. Please login with your password once.')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login with your password once to link your biometric.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
            // Top Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Text(
                      'SILVRA',
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryBrownGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

              Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width < 360 ? 18 : 24,
              ),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height < 700 ? 24 : 40),
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.28,
                    height: MediaQuery.of(context).size.height * 0.1,
                    errorBuilder: (context, error, stackTrace) =>
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ),
                  const SizedBox(height: 16),

                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1A1C1C),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to your account to continue',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5D5E5F),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height < 700 ? 32 : 48),

                  // Email / Phone Identifier Field
                  _buildInputField(
                    label: 'EMAIL ADDRESS / PHONE NUMBER',
                    hintText: 'name@example.com or 9999999999',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    formatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9@.-]'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Password Field
                  _buildInputField(
                    label: 'PASSWORD',
                    hintText: '••••••••',
                    controller: _passwordController,
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryBrownGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height < 700 ? 20 : 32),

                  // Login Button with Gradient
                  GestureDetector(
                    onTap: () async {
                      String identifier = _emailController.text.trim();
                      String password = _passwordController.text;

                      if (identifier.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter credentials')),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final response = await ApiService().login(identifier, password);
                        if (mounted) {
                          final responseData = response.data;
                          if (responseData['token'] != null) {
                            await AppState().setToken(responseData['token']);
                          }
                          AppState().updateFromMap(responseData['user'] ?? responseData);

                          Navigator.pop(context); // Close loading
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(context); // Close loading
                          String errorMsg = 'Login failed. Please try again.';
                          if (e is DioException && e.response?.data != null) {
                            errorMsg = e.response?.data['error'] ?? errorMsg;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMsg),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height < 700 ? 52 : 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrownGold,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBrownGold.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Login',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login with OTP Option & Biometric Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginWithOtpScreen(
                                initialPhone: _emailController.text,
                                initialPassword: _passwordController.text,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Login with OTP instead',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryBrownGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_isBiometricSupported) ...[
                        const SizedBox(width: 8),
                        const Text('|', style: TextStyle(color: Color(0xFFE2E8F0))),
                        const SizedBox(width: 8),
                         IconButton(
                          onPressed: _handleBiometricLogin,
                          icon: const Icon(Icons.fingerprint, color: Color(0xFF10B981)),
                          tooltip: 'Biometric Login',
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height < 700 ? 32 : 48),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account? ',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4D4635),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryBrownGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height < 700 ? 32 : 48),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            color: const Color(0xFF4D4635),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.60,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(18),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            inputFormatters: formatters,
            keyboardType: keyboardType ?? TextInputType.text,
            style: GoogleFonts.inter(
              color: const Color(0xFF1A1C1C),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: AppColors.accentBrownGold.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
