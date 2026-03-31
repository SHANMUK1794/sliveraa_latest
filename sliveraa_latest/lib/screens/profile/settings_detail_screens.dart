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

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      try {
        final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
        final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
        
        if (!canAuthenticate) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometrics not available on this device'))
          );
          return;
        }

        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
        );

        if (didAuthenticate) {
          setState(() {
            AppState().biometricEnabled = true;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: $e'))
        );
      }
    } else {
      setState(() {
        AppState().biometricEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildSettingsBase(
      context, 
      'Security', 
      [
        _buildActionTile(Icons.lock_outline_rounded, 'Change Password', 'Update your account password regularly', onTap: _showChangePasswordDialog),
        _buildBiometricTile('Biometric Login', 'Use Fingerprint or Face ID for faster access'),
        _buildActionTile(Icons.devices_rounded, 'Active Devices', 'Manage all devices currently logged in', onTap: _showActiveDevicesDialog),
        _buildActionTile(Icons.history_rounded, 'Login History', 'View your recent login activities'),
        _buildActionTile(Icons.delete_forever_rounded, 'Deactivate Account', 'Temporarily disable your Silvra account', isDestructive: true, onTap: _showDeactivateDialog),
      ],
    );
  }

  void _showActiveDevicesDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Active Devices', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              ...AppState().activeDevices.map((device) => ListTile(
                leading: Icon(Icons.devices_rounded, color: device['status'] == 'Current Device' ? AppColors.primaryBrownGold : const Color(0xFF64748B)),
                title: Text(device['name']!, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                subtitle: Text('${device['location']} • ${device['status']}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                trailing: device['status'] == 'Current Device' ? null : IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  onPressed: () {
                    setModalState(() {
                      AppState().activeDevices.remove(device);
                    });
                    setState(() {});
                  },
                ),
              )).toList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deactivate Account', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFFEF4444))),
        content: Text('Are you sure you want to temporarily deactivate your account? You will be logged out from all devices.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
               // RESET STATE AS MOCK DEACTIVATION
               AppState().kycStatus = "Unverified";
               Navigator.pushAndRemoveUntil(
                 context, 
                 MaterialPageRoute(builder: (context) => const OnboardingCarouselScreen()), 
                 (route) => false,
               );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text('Deactivate', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Current Password', labelStyle: GoogleFonts.inter())),
            TextField(decoration: InputDecoration(labelText: 'New Password', labelStyle: GoogleFonts.inter())),
            TextField(decoration: InputDecoration(labelText: 'Confirm New Password', labelStyle: GoogleFonts.inter())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBrownGold),
            child: Text('Update', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricTile(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: SwitchListTile(
        value: AppState().biometricEnabled,
        onChanged: _toggleBiometrics,
        activeColor: const Color(0xFFD4AF37),
        title: Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
      ),
    );
  }
}

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
