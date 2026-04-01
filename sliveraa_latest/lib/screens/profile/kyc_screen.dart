import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';
import 'package:dio/dio.dart';
import 'digilocker_webview.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _clientId;
  bool _isOtpStep = false;
  bool isDigiLockerStep = true;
  bool isVerifying = false;
  // Removed ImagePicker for OTP-only test
  Map<String, bool> uploadedDocs = {
    'Aadhaar Card (Front)': false,
    'Aadhaar Card (Back)': false,
    'PAN Card': false,
  };

  @override
  void initState() {
    super.initState();
    // Refresh status on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshStatus();
    });
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    _otpController.dispose();
    _fullNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch status for reactive updates
    final status = context.watch<AppState>().kycStatus;

    Widget body;
    if (isVerifying) {
      body = _buildVerifyingState();
    } else if (status == 'VERIFIED') {
      body = _buildVerifiedState();
    } else if (status == 'PENDING') {
      body = _buildPendingState();
    } else if (_isOtpStep) {
      body = _buildOtpVerifyStep();
    } else if (isDigiLockerStep) {
      body = _buildDigiLockerStep();
    } else {
      body = _buildManualStep();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        leadingWidth: 48,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verification',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.help_outline_rounded, color: Color(0xFF1A1C1C), size: 20),
                const SizedBox(height: 2),
                Text(
                  'HELP',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: body,
    );
  }

  Widget _buildVerifyingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrownGold),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Verifying Documents...',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This usually takes less than a minute',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDigiLockerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          Text(
            'Verify your identity',
            style: GoogleFonts.manrope(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
              height: 1.1,
            ),
          ),
          Text(
            'instantly',
            style: GoogleFonts.manrope(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7A6015),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Use DigiLocker for fastest KYC.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          
          // White Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row of card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCFA67E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'RECOMMENDED',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: const Color(0xFF3B2810),
                        ),
                      ),
                    ),
                    const Icon(Icons.verified_user_rounded, color: Color(0xFFCFA67E), size: 28),
                  ],
                ),
                const SizedBox(height: 24),
                // Card Title
                Text(
                  'DigiLocker',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                const SizedBox(height: 24),
                // List items
                _buildFeatureItem(Icons.check_circle_outline_rounded, 'No document uploads'),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.bolt_outlined, 'Faster approval'),
                const SizedBox(height: 16),
                _buildFeatureItem(Icons.account_balance_outlined, 'Secure & government verified'),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Button
          Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [Color(0xFFC8A57D), Color(0xFF9E7E59)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9E7E59).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DigiLockerWebView()),
                  );
                },
                child: Center(
                  child: Text(
                    'Continue with DigiLocker',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Manual Option
          Center(
            child: TextButton(
              onPressed: () => setState(() => isDigiLockerStep = false),
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(
                'Verify manually instead',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF7A6015),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Footer Security Note
          Center(
            child: Column(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Color(0xFF9CA3AF), size: 28),
                const SizedBox(height: 16),
                Text(
                  'BANK-GRADE 256-BIT ENCRYPTION',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'YOUR DATA REMAINS PRIVATE & SECURE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFCFA67E), size: 22),
        const SizedBox(width: 16),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildManualStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual Upload',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please provide high-quality photos of your government issued ID documents.',
            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildIdInputCard('Enter 12-digit Aadhaar Number', _aadhaarController, Icons.badge_outlined, isAadhaar: true),
          const SizedBox(height: 16),
          _buildIdInputCard('Enter 10-digit PAN Number', _panController, Icons.credit_card_outlined, isPan: true),
          const SizedBox(height: 16),
          _buildIdInputCard('Full Name (as per PAN)', _fullNameController, Icons.person_outline_rounded),
          const SizedBox(height: 16),
          _buildDobInputCard('Date of Birth', _dobController),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: isVerifying ? null : () {
              if (_panController.text.isNotEmpty) {
                _verifyPan();
              } else if (_aadhaarController.text.isNotEmpty) {
                _initiateAadhaarOtp();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an ID number')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrownGold,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Submit for Verification',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIdInputCard(String label, TextEditingController controller, IconData icon, {bool isAadhaar = false, bool isPan = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC), 
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(icon, color: const Color(0xFF94A3B8), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 14, 
                    fontWeight: FontWeight.w700, 
                    color: const Color(0xFF1E293B)
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            keyboardType: isPan ? TextInputType.text : TextInputType.number,
            maxLength: isPan ? 10 : 12,
            textCapitalization: isPan ? TextCapitalization.characters : TextCapitalization.none,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.5),
            decoration: InputDecoration(
              counterText: '',
              hintText: isPan ? 'ABCDE1234F' : '0000 0000 0000',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8).withOpacity(0.5)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDobInputCard(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            readOnly: true,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primaryBrownGold,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                controller.text = formattedDate;
              }
            },
            decoration: InputDecoration(
              hintText: 'YYYY-MM-DD',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8).withOpacity(0.5)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: const Icon(Icons.calendar_month_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerifyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify OTP',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter the 6-digit verification code sent to your Aadhaar-linked mobile number.',
            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 8),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: isVerifying ? null : _verifyAadhaarOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrownGold,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              isVerifying ? 'Verifying...' : 'Complete Verification',
              style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isOtpStep = false),
              child: Text('Change Aadhaar Number', style: GoogleFonts.inter(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateAadhaarOtp() async {
    if (_aadhaarController.text.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 12-digit Aadhaar number')));
      return;
    }

    setState(() => isVerifying = true);
    try {
      final response = await ApiService().startKyc('AADHAAR', _aadhaarController.text);
      
      if (response.data['success']) {
        setState(() {
          _clientId = response.data['data']['client_id'];
          _isOtpStep = true;
          isVerifying = false;
        });
      } else {
        throw response.data['message'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      setState(() => isVerifying = false);
      String errorMsg = 'Failed to initiate Aadhaar KYC';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  Future<void> _verifyAadhaarOtp() async {
    if (_otpController.text.length < 6) return;

    setState(() => isVerifying = true);
    try {
      final response = await ApiService().submitAadhaarOtp(_clientId!, _otpController.text);

      if (response.data['success']) {
        AppState().kycStatus = "Verified";
        _showSuccessDialog();
      } else {
        throw response.data['message'] ?? 'Verification failed';
      }
    } catch (e) {
      setState(() => isVerifying = false);
      String errorMsg = 'Verification failed';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() => isVerifying = false);
    }
  }

  Future<void> _verifyPan() async {
    String pan = _panController.text.toUpperCase();
    if (pan.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid 10-digit PAN number')));
      return;
    }
    if (_fullNameController.text.trim().isEmpty || _dobController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Date of Birth are required for PAN verification')));
       return;
    }

    setState(() => isVerifying = true);
    try {
      final response = await ApiService().startKyc(
        'PAN', 
        pan, 
        fullName: _fullNameController.text.trim(),
        dob: _dobController.text.trim(),
      );

      if (response.data['success']) {
        AppState().kycStatus = "Verified";
        _showSuccessDialog();
      } else {
        throw response.data['message'] ?? 'PAN verification failed';
      }
    } catch (e) {
      setState(() => isVerifying = false);
      String errorMsg = 'PAN verification failed';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      setState(() => isVerifying = false);
    }
  }

  // Removed obsolete manual upload methods

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Application Submitted!',
              style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your documents are being reviewed. This usually takes 24-48 hours. You will be notified once approved.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Pop dialog
                  Navigator.pop(context); // Pop KycScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrownGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Awesome!', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildVerifiedState() {
    final state = context.read<AppState>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBBF7D0), width: 4),
              ),
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 64),
            ),
            const SizedBox(height: 32),
            Text(
              'KYC DONE!',
              style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w900, color: const Color(0xFF16A34A), letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Successfully Verified',
              style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 16),
            Text(
              'Hey ${state.userName.isEmpty ? 'Silveraa User' : state.userName}, your account is now fully verified. You can start investing in gold and silver without any restrictions!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                elevation: 0,
              ),
              child: Text(
                'GO TO HOME',
                style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryBrownGold),
            const SizedBox(height: 32),
            Text(
              'Verification in Progress',
              style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF111827)),
            ),
            const SizedBox(height: 12),
            Text(
              'We are finalizing your identity details with Surepass. This shouldn\'t take long.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
