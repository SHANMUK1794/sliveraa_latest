import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'otp_verification_screen.dart';
import '../../core/api_service.dart';
import '../../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCAA779),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SILVRA',
          style: GoogleFonts.manrope(
            color: AppColors.primaryBrownGold,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please provide your details to begin your journey.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    _buildFormLabel('FULL NAME'),
                    _buildGreyField(
                      controller: _nameController,
                      hint: 'Johnathan Silver',
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildFormLabel('DATE OF BIRTH'),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildGreyField(
                          controller: _dobController,
                          hint: 'DD/MM/YYYY',
                          validator: (v) {
                            if (v!.isEmpty) return 'Date of birth is required';
                            try {
                              final parts = v.split('/');
                              final day = int.parse(parts[0]);
                              final month = int.parse(parts[1]);
                              final year = int.parse(parts[2]);
                              final dob = DateTime(year, month, day);
                              final now = DateTime.now();
                              int age = now.year - dob.year;
                              if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
                                age--;
                              }
                              if (age < 18) return 'You must be 18+ years old';
                            } catch (e) {
                              return 'Invalid date format';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildFormLabel('EMAIL ADDRESS'),
                    _buildGreyField(
                      controller: _emailController,
                      hint: 'john@vault.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.isEmpty) return 'Email is required';
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    _buildFormLabel('MOBILE NUMBER'),
                    _buildPhoneField(
                      validator: (v) => v!.length != 10 ? 'Enter 10 digit number' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildFormLabel('PASSWORD'),
                    _buildGreyField(
                      controller: _passwordController,
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFD1D5DB)),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => v!.length < 6 ? 'Password too short' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildFormLabel('CONFIRM PASSWORD'),
                    _buildGreyField(
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFD1D5DB)),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'Confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 56),
                    
                    _buildCreateButton(),
                    const SizedBox(height: 24),
                    
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'By joining, you agree to our ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Gold Custody',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFFB48C65),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            _buildSiteFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4B5563),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGreyField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111827),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFD1D5DB),
        ),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }

  Widget _buildPhoneField({String? Function(String?)? validator}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '+91',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: validator,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
            decoration: InputDecoration(
              hintText: '000-000-0000',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD1D5DB),
              ),
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFCCAC8B), Color(0xFFB48C65)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB48C65).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: Text(
          'Create Account',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSiteFooter() {
    return Column(
      children: [
        Text(
          '© 2024 The Digital Vault. Secure Institutional Grade Encryption.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _footerLink('Privacy\nPolicy'),
            _footerLink('Terms of Gold\nCustody'),
            _footerLink('Security\nGuarantee'),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF94A3B8),
        height: 1.4,
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        String cleanPhone = _phoneController.text.trim();
        // Remove non-digit characters
        cleanPhone = cleanPhone.replaceAll(RegExp(r'\D'), '');
        
        await ApiService().sendOtp(cleanPhone, intent: 'register');
        
        if (mounted) {
          Navigator.pop(context); // Close loading
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: '+91 ${_phoneController.text}',
                name: _nameController.text,
                email: _emailController.text,
                intent: 'register',
                password: _passwordController.text,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          String errorMsg = 'Failed to send OTP. Please try again.';
          if (e is DioException && e.response?.data != null) {
            errorMsg = e.response?.data['error'] ?? errorMsg;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
