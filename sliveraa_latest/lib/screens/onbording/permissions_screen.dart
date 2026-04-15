import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import '../../utils/app_state.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final LocalAuthentication _localAuth = LocalAuthentication();

  // null = not asked, true = granted, false = denied
  bool? _notifStatus;
  bool? _biometricStatus;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Triggers the real Android system notification permission popup
  Future<void> _requestNotifications() async {
    setState(() => _isProcessing = true);
    final status = await Permission.notification.request();
    setState(() {
      _notifStatus = status.isGranted;
      _isProcessing = false;
    });
  }

  /// Triggers the real device biometric prompt (fingerprint / face ID)
  Future<void> _requestBiometric() async {
    setState(() => _isProcessing = true);
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck && !isDeviceSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Biometric not available on this device.')),
          );
        }
        setState(() {
          _biometricStatus = false;
          _isProcessing = false;
        });
        return;
      }

      // Show the actual fingerprint / face ID prompt
      final authenticated = await _localAuth.authenticate(
        localizedReason:
            'Verify your identity to enable quick biometric login',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN fallback
          stickyAuth: true,
        ),
      );

      // If authenticated, save biometric preference
      if (authenticated) {
        // Enable biometric via AppState setter (also persists to SharedPreferences)
        AppState().isBiometricEnabled = true;
      }

      setState(() {
        _biometricStatus = authenticated;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _biometricStatus = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_shown', true);
    if (!mounted) return;
    final appState = AppState();
    if (appState.userId.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  bool get _allAsked => _notifStatus != null && _biometricStatus != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFC1A27B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFC1A27B)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '✦  QUICK SETUP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC1A27B),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Let\'s set\nyou up right',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Allow these permissions to unlock\nthe full Silvra experience.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white54,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Notifications — triggers Android system popup
                  _PermissionCard(
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFFFFB347),
                    title: 'Notifications',
                    subtitle:
                        'Price alerts, SIP reminders & transaction updates.',
                    status: _notifStatus,
                    onTap: _isProcessing ? null : _requestNotifications,
                    accentColor: const Color(0xFFFFB347),
                  ),

                  const SizedBox(height: 16),

                  // Biometrics — triggers real fingerprint/face prompt
                  _PermissionCard(
                    icon: Icons.fingerprint_rounded,
                    iconColor: const Color(0xFF34D399),
                    title: 'Biometric Login',
                    subtitle:
                        'Sign in instantly with fingerprint or face ID.',
                    status: _biometricStatus,
                    onTap: _isProcessing ? null : _requestBiometric,
                    accentColor: const Color(0xFF34D399),
                  ),

                  const Spacer(),

                  Column(
                    children: [
                      if (_allAsked) ...[
                        _buildPrimaryButton('Continue →', _finish),
                      ] else ...[
                        _buildPrimaryButton(
                          'Allow All & Continue',
                          _isProcessing
                              ? null
                              : () async {
                                  await _requestNotifications();
                                  await _requestBiometric();
                                  await _finish();
                                },
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _finish,
                          child: Center(
                            child: Text(
                              'Skip for now',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [Color(0xFFD4B184), Color(0xFFB08C65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF1E293B)],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: const Color(0xFFC1A27B).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Center(
          child: _isProcessing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final String title;
  final String subtitle;
  final bool? status;
  final VoidCallback? onTap;

  const _PermissionCard({
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = status == true;
    final isDenied = status == false;
    final isPending = status == null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isGranted
            ? accentColor.withValues(alpha: 0.08)
            : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGranted
              ? accentColor.withValues(alpha: 0.4)
              : isDenied
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.06),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white54,
                        height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isPending ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isGranted
                    ? accentColor.withValues(alpha: 0.15)
                    : isDenied
                        ? Colors.red.withValues(alpha: 0.12)
                        : const Color(0xFFC1A27B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isGranted
                      ? accentColor.withValues(alpha: 0.5)
                      : isDenied
                          ? Colors.red.withValues(alpha: 0.4)
                          : const Color(0xFFC1A27B).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isGranted ? '✓ Allowed' : isDenied ? '✗ Denied' : 'Allow',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isGranted
                      ? accentColor
                      : isDenied
                          ? Colors.red
                          : const Color(0xFFC1A27B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
