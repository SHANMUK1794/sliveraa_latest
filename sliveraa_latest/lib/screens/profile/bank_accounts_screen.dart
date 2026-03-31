import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _confirmAccountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final FocusNode _bankNameFocus = FocusNode();

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
            border: Border.all(color: const Color(0xFFEDC9AF).withOpacity(0.5), width: 1.5),
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

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFCCAC8B), Color(0xFFB48C65)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB48C65).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_accountNumberController.text.isNotEmpty && _ifscController.text.isNotEmpty) {
            setState(() {
              if (AppState().bankAccounts.isEmpty) {
                AppState().bankAccounts.add(BankAccount(
                  bankName: _bankNameController.text,
                  accountHolder: _holderNameController.text,
                  accountNumber: _accountNumberController.text,
                  ifsc: _ifscController.text,
                  isPrimary: true,
                ));
              } else {
                final account = AppState().bankAccounts.first;
                account.bankName = _bankNameController.text;
                account.accountHolder = _holderNameController.text;
                account.accountNumber = _accountNumberController.text;
                account.ifsc = _ifscController.text;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Bank details updated successfully!'),
              backgroundColor: Color(0xFF059669),
            ));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Save Bank Details',
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
