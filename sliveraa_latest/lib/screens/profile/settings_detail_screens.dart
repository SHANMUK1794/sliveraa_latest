import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import '../onbording/onboarding_carousel_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildSettingsBase(
      context, 
      'Notifications', 
      [
        _buildSwitchTile('Price Alerts', 'Get notified when gold/silver prices change significantly'),
        _buildSwitchTile('Market Updates', 'Daily summaries of market trends and news'),
        _buildSwitchTile('Transaction Alerts', 'Notifications for all your buy/sell activities'),
        _buildSwitchTile('Security Alerts', 'Alerts for login and account changes'),
        _buildSwitchTile('Promotional Offers', 'Special rewards and seasonal offers'),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle) {
    bool value = AppState().notificationSettings[title] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: (val) {
          setState(() {
            AppState().notificationSettings[title] = val;
          });
        },
        activeColor: const Color(0xFFD4AF37),
        title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
      ),
    );
  }
}


// SecurityScreen removed - Now using the premium implementation in lib/screens/profile/security_screen.dart

Widget _buildSettingsBase(BuildContext context, String title, List<Widget> children) {
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
        title,
        style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkText),
      ),
      centerTitle: true,
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: children,
    ),
  );
}

Widget _buildActionTile(IconData icon, String title, String subtitle, {bool isDestructive = false, VoidCallback? onTap}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    child: ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDestructive ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF64748B), size: 22),
      ),
      title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16, color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
    ),
  );
}
