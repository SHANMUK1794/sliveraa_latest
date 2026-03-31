import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../utils/app_state.dart';
import '../../utils/extensions.dart';
import '../../theme/app_colors.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Refer & Earn',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkText),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildReferralCodeCard(context),
            _buildStatsSection(),
            _buildHowItWorks(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primaryBrownGold.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Icon(Icons.card_giftcard_rounded, color: AppColors.primaryBrownGold, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            'Give ₹100, Get ₹100',
            style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          Text(
            'Invite your friends to Silvra. When they complete their first investment, you both get ₹100 worth of Gold!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(BuildContext context) {
    final String code = AppState().referralCode.isEmpty ? "SILVRA-${AppState().userId}" : AppState().referralCode;
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Text('YOUR REFERRAL CODE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                    Text(code, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF111827), letterSpacing: 2)),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard!')));
                  },
                  icon: Icon(Icons.copy_rounded, color: AppColors.primaryBrownGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrownGold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Invite Friends', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatBox('Total Invited', AppState().referralCount.toString(), Icons.people_outline_rounded),
          const SizedBox(width: 16),
          _buildStatBox('Earned Gold', '₹${AppState().referralEarnings.toLocaleString()}', Icons.stars_rounded),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryBrownGold, size: 24),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _buildStep(1, 'Share your unique referral code with friends.'),
          _buildStep(2, 'Your friends sign up and complete their KYC.'),
          _buildStep(3, 'They make their first investment of ₹100 or more.'),
          _buildStep(4, 'Success! You both receive ₹100 worth of Gold in your vaults.'),
        ],
      ),
    );
  }

  Widget _buildStep(int num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: AppColors.primaryBrownGold, shape: BoxShape.circle),
            child: Center(child: Text('$num', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B), height: 1.4))),
        ],
      ),
    );
  }
}
