import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  final FocusNode _bankNameFocus = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (AppState().bankAccounts.isNotEmpty) {
      final account = AppState().bankAccounts.first;
      _bankNameController.text = account.bankName;
      _accountNumberController.text = account.accountNumber;
      _confirmAccountController.text = account.accountNumber;
      _ifscController.text = account.ifsc;
      _holderNameController.text = account.accountHolder;
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    _bankNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bank Details',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_outlined, color: Color(0xFF111827), size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AppState().bankAccounts.isNotEmpty) _buildSavedAccountSection(),
            const SizedBox(height: 32),
            Text(
              AppState().bankAccounts.isEmpty ? 'Add Details' : 'Update Details',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your banking information to ensure secure fund transfers.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildFormLabel('BANK NAME'),
            _buildBankField(controller: _bankNameController, hint: 'Chase Bank', focusNode: _bankNameFocus),
            const SizedBox(height: 20),
            _buildFormLabel('ACCOUNT NUMBER'),
            _buildBankField(controller: _accountNumberController, hint: '.... .... .... ....', isSecure: true),
            const SizedBox(height: 20),
            _buildFormLabel('CONFIRM ACCOUNT NUMBER'),
            _buildBankField(controller: _confirmAccountController, hint: '.... .... .... ....', isSecure: true),
            const SizedBox(height: 20),
            _buildFormLabel('IFSC / SWIFT CODE'),
            _buildBankField(controller: _ifscController, hint: 'CHASUS33XXX'),
            const SizedBox(height: 20),
            _buildFormLabel('ACCOUNT HOLDER NAME'),
            _buildBankField(controller: _holderNameController, hint: 'Johnathan Silver', icon: Icons.person_outline_rounded),
            const SizedBox(height: 32),
            _buildSecurityCard(),
            const SizedBox(height: 40),
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedAccountSection() {
    final account = AppState().bankAccounts.first;
    String last4 = account.accountNumber.length >= 4 
        ? account.accountNumber.substring(account.accountNumber.length - 4) 
        : account.accountNumber;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SAVED BANK ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF94A3B8),
                letterSpacing: 1,
              ),
            ),
            Text(
              'ACTIVE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFB48C65),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEDC9AF).withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB48C65).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: Color(0xFFB48C65), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.bankName,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          account.accountHolder,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFFB48C65)),
                    onPressed: () {
                      _bankNameFocus.requestFocus();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'ACCOUNT NUMBER',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFCBD5E1),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                     Text(
                      '● ● ● ●   ● ● ● ●',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      last4,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4B5563),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBankField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool isSecure = false,
    FocusNode? focusNode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: isSecure 
              ? const Icon(Icons.lock_outline_rounded, color: Color(0xFFD1D5DB), size: 20)
              : (icon != null ? Icon(icon, color: const Color(0xFFD1D5DB), size: 20) : null),
        ),
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFB48C65), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Silvra uses bank-level encryption (AES-256) to protect your financial data. Your account numbers are never stored in plain text and are only used for settlement purposes.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: _isLoading 
            ? [const Color(0xFFD1D5DB), const Color(0xFF9CA3AF)] 
            : [const Color(0xFFCCAC8B), const Color(0xFFB48C65)],
        ),
        boxShadow: _isLoading ? null : [
          BoxShadow(
            color: const Color(0xFFB48C65).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () async {
          final bankName = _bankNameController.text.trim();
          final accNum = _accountNumberController.text.trim();
          final confAccNum = _confirmAccountController.text.trim();
          final ifsc = _ifscController.text.trim();
          final holder = _holderNameController.text.trim();

          // Validation
          if (bankName.isEmpty || accNum.isEmpty || ifsc.isEmpty || holder.isEmpty) {
            _showSnackBar('Please fill in all bank details.');
            return;
          }

          if (accNum != confAccNum) {
            _showSnackBar('Account numbers do not match.');
            return;
          }

          if (accNum.length < 8) {
            _showSnackBar('Please enter a valid account number.');
            return;
          }

          setState(() => _isLoading = true);
          try {
            // 1. Send to Backend
            await ApiService().addBankAccount({
              'bankName': bankName,
              'accountHolder': holder,
              'accountNumber': accNum,
              'ifsc': ifsc,
            });

            // 2. Synchronize AppState
            await AppState().fetchBankAccounts();

            _showSnackBar('Bank details updated successfully!', isError: false);
            if (mounted) Navigator.pop(context);
          } catch (e) {
             String errorMessage = 'Failed to save details. Please try again.';
             if (e is DioException) {
               errorMessage = e.response?.data?['message'] ?? e.message ?? errorMessage;
             }
            _showSnackBar(errorMessage);
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: _isLoading 
          ? const SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppState().bankAccounts.isEmpty ? 'Save Bank Details' : 'Update Bank Details',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
              ],
            ),
      ),
    );
  }
}
