import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/price_data.dart';
import '../../utils/extensions.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import '../../core/api_service.dart';

class WithdrawScreen extends StatefulWidget {
  final bool isGoldInitial;
  const WithdrawScreen({super.key, this.isGoldInitial = true});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  late bool isGold;
  final TextEditingController _amountController = TextEditingController();
  String selectedAmount = '₹2,000';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isGold = widget.isGoldInitial;
    _amountController.text = '2000';
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    await AppState().fetchBankAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get withdrawableAmount => currentBalance * currentPrice;
  double get currentBalance => isGold ? AppState().goldGrams : AppState().silverGrams;
  double get currentPrice => isGold ? PriceData.goldPrice : PriceData.silverPrice;
  double get gramsEquivalent => (double.tryParse(_amountController.text) ?? 0) / currentPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF715B3E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Withdraw',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF715B3E),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Metal Toggle
            _buildMetalToggle(),
            
            const SizedBox(height: 24),
            
            // Withdrawable Amount Card
            _buildWithdrawableCard(),
            
            const SizedBox(height: 24),
            
            // Enter Amount Card
            _buildAmountInputCard(),
            
            const SizedBox(height: 24),
            
            // Bank Card
            _buildBankCard(),
            
            const SizedBox(height: 24),
            
            // Hint
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text(
                  'Minimum withdrawal: ₹100',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Actions
            isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFB08C65)))
              : ElevatedButton(
                  onPressed: _processWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB08C65),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 12,
                    shadowColor: const Color(0xFFB08C65).withOpacity(0.4),
                  ),
                  child: Text(
                    'WITHDRAW NOW',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            
            const SizedBox(height: 12),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMetalToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGold = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isGold ? const Color(0xFFC6A17A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: isGold ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    'GOLD',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isGold ? Colors.white : const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isGold = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isGold ? const Color(0xFF64748B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: !isGold ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    'SILVER',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: !isGold ? Colors.white : const Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawableCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.04,
              child: Icon(Icons.payments_rounded, size: 84, color: Colors.black),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'WITHDRAWABLE AMOUNT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${withdrawableAmount.toLocaleString()}',
                style: GoogleFonts.manrope(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF111827),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can withdraw up to this amount',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentBalance.toStringAsFixed(4)} GM ${isGold ? 'GOLD' : 'SILVER'}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF854D0E),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    'Live price applied',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTER AMOUNT',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Input Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Text(
                  '₹',
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: GoogleFonts.manrope(color: const Color(0xFFCBD5E1)),
                    ),
                    onChanged: (val) {
                      final amount = double.tryParse(val.replaceAll(',', '')) ?? 0;
                      if (amount > withdrawableAmount) {
                        _amountController.text = withdrawableAmount.toInt().toString();
                        _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length));
                      }
                      setState(() {});
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _amountController.text = withdrawableAmount.toInt().toString();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MAX',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Min ₹100 • Available ₹${withdrawableAmount.toLocaleString()}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          // Summary Row (Light grey box)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You will receive',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${(double.tryParse(_amountController.text) ?? 0).toLocaleString()}',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Based on live market price',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '≈ ${gramsEquivalent.toStringAsFixed(3)} gm',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB08C65),
                          ),
                        ),
                      ),
                      Text(
                        isGold ? 'Gold' : 'Silver',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB08C65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick Select Buttons
          Row(
            children: ['₹500', '₹1,000', '₹2,000', '₹5,000'].map((e) {
              bool isSelected = '₹${(double.tryParse(_amountController.text) ?? 0).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}' == e;
              // Simple check for match - might need better logic for exact match
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _amountController.text = e.replaceAll('₹', '').replaceAll(',', '');
                  }),
                  child: Container(
                    margin: EdgeInsets.only(right: e == '₹5,000' ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC6A17A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      e,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard() {
    final primaryBank = AppState().bankAccounts.firstWhere(
      (b) => b.isPrimary,
      orElse: () => AppState().bankAccounts.isNotEmpty 
          ? AppState().bankAccounts.first 
          : BankAccount(id: '', bankName: 'No Bank Account', accountHolder: '', accountNumber: '', ifsc: ''),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: _showBankSelection,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.account_balance_rounded, color: Color(0xFF64748B), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryBank.id.isNotEmpty
                      ? '${primaryBank.bankName} •••• ${primaryBank.accountNumber.substring(primaryBank.accountNumber.length - 4)}'
                      : 'No Bank account added',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primaryBank.id.isNotEmpty ? const Color(0xFF22C55E) : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        primaryBank.id.isNotEmpty ? 'Instant transfer enabled' : 'Add account to withdraw',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              primaryBank.id.isNotEmpty ? 'Change' : 'Add',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB08C65),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB08C65), size: 20),
          ],
        ),
      ),
    );
  }

  void _showBankSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BankSelectionSheet(
        onAccountSelected: () {
          setState(() {});
        },
      ),
    );
  }

  void _processWithdrawal() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;
    
    if (amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum withdrawal is ₹100')));
      return;
    }

    if (amount > withdrawableAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient metal balance')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService().withdraw(amount, isGold ? 'GOLD' : 'SILVER');
      
      if (response.statusCode == 200) {
        // Update local app state
        final weightDeducted = (response.data['weightDeducted'] as num).toDouble();
        if (isGold) {
          AppState().goldGrams -= weightDeducted;
        } else {
          AppState().silverGrams -= weightDeducted;
        }
        
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception(response.data['error'] ?? 'Withdrawal failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Withdrawal Successful',
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            Text(
              'Your request for ₹${_amountController.text} has been initiated. Funds will be credited to your primary bank account shortly.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280), height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back from Withdraw screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Back to Portfolio', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BankSelectionSheet extends StatefulWidget {
  final VoidCallback onAccountSelected;
  const _BankSelectionSheet({required this.onAccountSelected});

  @override
  State<_BankSelectionSheet> createState() => _BankSelectionSheetState();
}

class _BankSelectionSheetState extends State<_BankSelectionSheet> {
  bool isAdding = false;
  final _bankNameController = TextEditingController();
  final _holderController = TextEditingController();
  final _accNoController = TextEditingController();
  final _ifscController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAdding ? 'Add Bank Account' : 'Select Bank Account',
                  style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isAdding) ...[
              if (AppState().bankAccounts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance_rounded, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No bank accounts added yet', style: GoogleFonts.inter(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ...AppState().bankAccounts.map((b) => _buildBankItem(b)),
              const SizedBox(height: 16),
              _buildAddButton(),
            ] else ...[
              _buildInputField('Bank Name', _bankNameController),
              _buildInputField('Account Holder Name', _holderController),
              _buildInputField('Account Number', _accNoController, isNumeric: true),
              _buildInputField('IFSC Code', _ifscController),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveBank,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrownGold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save Bank Account', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankItem(BankAccount b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: b.isPrimary ? const Color(0xFFFDFBF7) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: b.isPrimary ? AppColors.primaryBrownGold : const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: () async {
          await ApiService().setPrimaryBank(b.id);
          await AppState().fetchBankAccounts();
          widget.onAccountSelected();
          Navigator.pop(context);
        },
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF1F5F9),
          child: Icon(Icons.account_balance_rounded, color: Color(0xFF64748B), size: 20),
        ),
        title: Text(b.bankName, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '•••• ${b.accountNumber.length > 4 ? b.accountNumber.substring(b.accountNumber.length - 4) : b.accountNumber}', 
          style: GoogleFonts.inter(fontSize: 12)
        ),
        trailing: b.isPrimary ? Icon(Icons.check_circle_rounded, color: AppColors.primaryBrownGold) : null,
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () => setState(() => isAdding = true),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text('Add Another Account', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _saveBank() async {
    setState(() => isLoading = true);
    try {
      await ApiService().addBankAccount({
        'bankName': _bankNameController.text,
        'accountHolder': _holderController.text,
        'accountNumber': _accNoController.text,
        'ifsc': _ifscController.text,
      });
      await AppState().fetchBankAccounts();
      widget.onAccountSelected();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
