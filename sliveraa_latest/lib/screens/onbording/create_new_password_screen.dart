import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F5), // Warm off-white
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
                  // Lock Badge with Checkmark (Same as OTP screen)
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
                  Text(
                    'Your New Password Must Be\nDifferent from Previously Used\nPassword.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Password Fields
                  _buildPasswordField('NEW PASSWORD', _passwordController, _isPasswordVisible, () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  }),
                  
                  const SizedBox(height: 24),
                  
                  _buildPasswordField('CONFIRM PASSWORD', _confirmPasswordController, _isConfirmVisible, () {
                    setState(() => _isConfirmVisible = !_isConfirmVisible);
                  }),
                  
                  const SizedBox(height: 32),
                  
                  // Change Password Link
                  GestureDetector(
                    child: Text(
                      'CHANGE PASSWORD',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC0392B), // Rust Red
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  GestureDetector(
                    onTap: () {
                      // BYPASS: Navigate to Home as "Saved"
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                      return;

                      /*
                      // Future Backend Integration:
                      if (_passwordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match')),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        // await ApiService().resetPassword(widget.phone, _passwordController.text);
                        
                        if (mounted) {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      }
                      */
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFCAA779), Color(0xFFA67C41)],
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
                          'SAVE',
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
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Outer Footer
            Text(
              'SECURE ENCRYPTION ACTIVE',
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

  Widget _buildPasswordField(String label, TextEditingController controller, bool visible, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Light grey background
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextField(
            controller: controller,
            obscureText: !visible,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: '········',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
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
}
