import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import 'kyc_screen.dart';
import 'kyc_pending_screen.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'bank_accounts_screen.dart';
import 'referral_screen.dart';
import 'support_screen.dart';
import 'legal_screen.dart';
import 'settings_detail_screens.dart';
import '../onbording/onboarding_screen.dart';
import '../../core/api_service.dart';
import '../history/delivery_tracking_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFFB48C65)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildIdentitySection(),
            const SizedBox(height: 40),
            _buildCategoryHeader('ACCOUNT SETTINGS'),
            _buildProfileCard(
              icon: Icons.inventory_2_rounded,
              title: 'Your Orders',
              subtitle: 'Track and manage your deliveries',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryTrackingScreen())),
            ),
            _buildProfileCard(
              icon: Icons.location_on_rounded,
              title: 'Address',
              subtitle: 'Change your location',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressesScreen())),
            ),
            _buildProfileCard(
              icon: Icons.account_balance_rounded,
              title: 'Bank Details',
              subtitle: 'Manage your payment methods',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BankAccountsScreen())),
            ),
            _buildProfileCard(
              icon: Icons.card_giftcard_rounded,
              title: 'Refer & Earn',
              subtitle: 'Invite friends and get rewards',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen())),
            ),
            _buildProfileCard(
              icon: Icons.verified_user_rounded,
              title: 'KYC Status',
              subtitle: 'Verify your identity for investing',
              showBadge: true,
              onTap: () async {
                if (AppState().kycStatus == "Pending") {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const KycPendingScreen()));
                } else {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const KycScreen()));
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            _buildCategoryHeader('PREFERENCES'),
            _buildProfileCard(
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Manage your alerts',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
            ),
            _buildProfileCard(
              icon: Icons.lock_rounded,
              title: 'Security',
              subtitle: 'Password & Biometrics',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen())),
            ),
            _buildProfileCard(
              icon: Icons.help_center_rounded,
              title: 'Help & Support',
              subtitle: 'Contact our team',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen())),
            ),
            _buildProfileCard(
              icon: Icons.gavel_rounded,
              title: 'Legal',
              subtitle: 'Terms & Conditions',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LegalScreen())),
            ),
            const SizedBox(height: 32),
            _buildFooter(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Image.network(
                  'https://ui-avatars.com/api/?name=${AppState().userName}&background=F5EDE3&color=B48C65&size=200',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 4,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB48C65),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          AppState().userName,
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        Text(
          '@${AppState().userName.toLowerCase().replaceAll(' ', '')}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF2E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Member since Oct 2023',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB48C65),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 24, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    final bool isVerified = AppState().kycStatus == "Verified";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3E2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFFB48C65), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              if (showBadge && isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                      const SizedBox(width: 6),
                      Text(
                        'VERIFIED',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFFCBD5E1), size: 14),
            const SizedBox(width: 8),
            Text(
              'Your data is secured and encrypted',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _showLogoutDialog,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Sign Out', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to sign out? You will need to sign in again to access your vault.', 
          style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              AppState().clear();
              ApiService().clearToken();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                (route) => false,
              );
            },
            child: Text('Sign Out', style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
