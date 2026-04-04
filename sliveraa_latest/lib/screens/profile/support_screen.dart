import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../support/concierge_support_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
          'Help & Support',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkText),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSupportHeader(),
            _buildContactOptions(context),
            _buildFAQs(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFFF5EDE3), shape: BoxShape.circle),
            child: Icon(Icons.headset_mic_rounded, color: AppColors.primaryBrownGold, size: 40),
          ),
          const SizedBox(height: 24),
          Text(
            'How can we help you?',
            style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            'Our support team is available 24/7 to assist you with any questions.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConciergeSupportScreen())),
            child: _buildSupportTile('Live Chat', 'Average response time: 2 mins', Icons.chat_bubble_outline_rounded, const Color(0xFF16A34A)),
          ),
          const SizedBox(height: 12),
          _buildSupportTile('Email Support', 'support@silvra.com', Icons.alternate_email_rounded, const Color(0xFF2563EB)),
          const SizedBox(height: 12),
          _buildSupportTile('Call Us', '+91 1800-456-789', Icons.phone_in_talk_rounded, AppColors.primaryBrownGold),
        ],
      ),
    );
  }

  Widget _buildSupportTile(String title, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildFAQs() {
    final faqs = [
      {'q': 'How safe is my gold?', 'a': 'Your gold is 100% insured and stored in secure, Grade-A bank vaults managed by trusted custodians like Brinks and Sequel.'},
      {'q': 'Can I withdraw my physical gold?', 'a': 'Yes, you can request physical delivery of your gold in the form of certified coins and bars starting from 0.5gm.'},
      {'q': 'Is there a minimum investment?', 'a': 'You can start saving in digital gold with as little as ₹10.'},
      {'q': 'Are there any hidden charges?', 'a': 'Silvras pricing is transparent. We include all taxes and vaulting fees in the displayed price. No hidden locker charges.'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular Questions', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          ...faqs.map((faq) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: ExpansionTile(
              title: Text(faq['q']!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Text(faq['a']!, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.5)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
