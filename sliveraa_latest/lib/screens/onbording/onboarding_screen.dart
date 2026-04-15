import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_carousel_screen.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_state.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    // Delay check until after first frame so context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  void _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final appState = AppState();

    // Already logged in → skip everything
    if (appState.userId.isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return;
    }

    // Permissions already shown → skip to login
    final permissionsShown = prefs.getBool('permissions_shown') ?? false;
    if (permissionsShown) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
    // else: stay on onboarding screen for fresh first-launch flow
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Color Gradients (Subtle corners)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF9F0FF).withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8FAF3).withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFDF0F6).withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Decorative Rings
          Positioned(
            left: -screenWidth * 0.18,
            top: screenHeight * 0.32,
            child: _buildRing(size: 140, borderWidth: 8),
          ),
          Positioned(
            left: screenWidth * 0.08,
            top: screenHeight * 0.06,
            child: _buildRing(size: 80, borderWidth: 6),
          ),
          Positioned(
            right: screenWidth * 0.12,
            top: screenHeight * 0.04,
            child: _buildRing(size: 36, borderWidth: 5),
          ),

          // Main Center Imagery
          Positioned(
            top: screenHeight * 0.18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Typography
          Positioned(
            top: screenHeight * 0.50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Easy ways to',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'manage your',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900, // Extra bold
                      color: const Color(0xFF0F172A),
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'finances',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Buy, track, and grow your\ngold aand silver investments\nin one place',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Swipe Button
          Positioned(
            bottom: screenHeight * 0.08,
            left: 40,
            right: 40,
            child: const _CustomSwipeButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildRing({required double size, required double borderWidth}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: borderWidth,
          color: const Color(0xFFC1A27B).withValues(alpha: 0.6), // Metallic Gold opacity
        ),
      ),
    );
  }
}

class _CustomSwipeButton extends StatefulWidget {
  const _CustomSwipeButton();

  @override
  State<_CustomSwipeButton> createState() => _CustomSwipeButtonState();
}

class _CustomSwipeButtonState extends State<_CustomSwipeButton> {
  double _dragPosition = 0.0;
  bool _isFinished = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isFinished) return;
    
    setState(() {
      _dragPosition += details.delta.dx;
      // Define button width as 60 and max drag distance
      const buttonWidth = 60.0;
      final maxDistance = maxWidth - buttonWidth - 8; // padding

      if (_dragPosition < 0) {
        _dragPosition = 0;
      } else if (_dragPosition >= maxDistance) {
        _dragPosition = maxDistance;
        _isFinished = true;
        _navigateToNext();
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) {
    if (_isFinished) return;
    
    const buttonWidth = 60.0;
    final maxDistance = maxWidth - buttonWidth - 8;
    
    // Snap back if not fully swiped
    if (_dragPosition < maxDistance * 0.8) {
      setState(() {
        _dragPosition = 0.0;
      });
    } else {
      setState(() {
        _dragPosition = maxDistance;
        _isFinished = true;
      });
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingCarouselScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Text is centered in the space after the slider block
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 64),
                  child: Center(
                    child: Text(
                      'Swipe To Get Started',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8BA3BA),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _dragPosition + 4, // 4 padding from left
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, maxWidth),
                  onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, maxWidth),
                  child: Container(
                    width: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4B184), Color(0xFFB48C65)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
