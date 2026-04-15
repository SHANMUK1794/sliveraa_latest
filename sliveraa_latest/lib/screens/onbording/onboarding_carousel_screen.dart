import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';

class OnboardingCarouselScreen extends StatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  State<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState extends State<OnboardingCarouselScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        // Optional: Loop back to start or stay at last page?
        // User said "auto scrolling one screen only", maybe they just want it to progress once.
        // I'll stop at the last page for now.
        _timer?.cancel();
      }
    });
  }

  final List<OnboardingData> _pages = [
    OnboardingData(
      titlePart1: 'Faster Transfer\n',
      titlePart2: 'of Gold',
      titlePart1Color: AppColors.primaryBrownGold,
      titlePart2Color: Colors.black,
      description:
          'Fund your wallet instantly and start trading gold and silver at live prices',
      imagePath: 'assets/images/rocket_gold.png',
    ),
    OnboardingData(
      titlePart1: 'Get Physical ',
      titlePart2: 'Gold delivered',
      titlePart1Color: Colors.black,
      titlePart2Color: AppColors.primaryBrownGold,
      description:
          'Convert your digital gold into physical delivery secured and seamless',
      imagePath: 'assets/images/physical_gold.png',
    ),
    OnboardingData(
      titlePart1: 'The peak of ',
      titlePart2: 'Transparency',
      titlePart1Color: Colors.black,
      titlePart2Color: AppColors.primaryBrownGold,
      description:
          'See realtime prices, clear breakdowns, and zero hidden charges',
      imagePath: 'assets/images/peak_of_transparency.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background glow
            Positioned(
              left: -140,
              bottom: 120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryBrownGold.withOpacity(0.22),
                      Colors.white,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -160,
              top: 100,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryBrownGold.withOpacity(0.16),
                      Colors.white,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 18),
                  child: Text(
                    'SILVARA',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnboardingSlide(data: _pages[index]);
                    },
                  ),
                ),

                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    final bool isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: isActive ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryBrownGold
                            : const Color(0xFFD8D8D8),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 26),

                // Next Button
                 Padding(
                   padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    bottom: MediaQuery.of(context).size.height < 700 ? 24 : 40,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Request OS permissions as system popups (no custom screen)
                        await Permission.notification.request();
                        try {
                          final auth = LocalAuthentication();
                          final canCheck = await auth.canCheckBiometrics ||
                              await auth.isDeviceSupported();
                          if (canCheck) {
                            await auth.authenticate(
                              localizedReason:
                                  'Enable fingerprint for quick login',
                              options: const AuthenticationOptions(
                                biometricOnly: false,
                                stickyAuth: true,
                              ),
                            );
                          }
                        } catch (_) {}
                        // Mark permissions as done
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('permissions_shown', true);
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height < 700 ? 50 : 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC8A27B), Color(0xFFB18960)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBrownGold.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Next',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingData data;

  const OnboardingSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image Section with Decorative circles
        Expanded(
          flex: 5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -20,
                top: 40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrownGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -40,
                bottom: 20,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrownGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.36,
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  child: Image.asset(data.imagePath, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),

        // Text Section
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.manrope(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: data.titlePart1,
                        style: TextStyle(color: data.titlePart1Color),
                      ),
                      TextSpan(
                        text: data.titlePart2,
                        style: TextStyle(color: data.titlePart2Color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.78,
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF5A5C5C),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  final String titlePart1;
  final String titlePart2;
  final Color titlePart1Color;
  final Color titlePart2Color;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.titlePart1,
    required this.titlePart2,
    this.titlePart1Color = Colors.black,
    this.titlePart2Color = AppColors.primaryBrownGold,
    required this.description,
    required this.imagePath,
  });
}
