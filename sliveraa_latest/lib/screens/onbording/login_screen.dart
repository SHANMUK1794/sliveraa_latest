import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'login_with_otp_screen.dart';
import '../home/home_screen.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import '../../utils/app_state.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 80),
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

                  const SizedBox(height: 48),

                  // Email Field
                  _buildInputField(
                    label: 'EMAIL ADDRESS/ PHONE NUMBER',
                    hintText: 'name@example.com',
                    controller: _emailController,
                    formatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9@.]'),
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

                  const SizedBox(height: 32),

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
                            ApiService().setToken(responseData['token']);
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
                      height: 60,
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

                  // Login with OTP Option
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

                  const SizedBox(height: 48),

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

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
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
