import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_state.dart';

class AddDeliveryAddressScreen extends StatefulWidget {
  final bool isEditing;
  final int? editIndex;
  const AddDeliveryAddressScreen({super.key, this.isEditing = false, this.editIndex});

  @override
  State<AddDeliveryAddressScreen> createState() => _AddDeliveryAddressScreenState();
}

class _AddDeliveryAddressScreenState extends State<AddDeliveryAddressScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  
  String? _selectedState;
  bool _saveForFuture = false;

  final List<String> _indianStates = [
    'Choose State',
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.editIndex != null && widget.editIndex! < AppState().addresses.length) {
      String existing = AppState().addresses[widget.editIndex!];
      // Basic parse effort since it's just a concatenated string
      _nameController.text = 'Rahul Sharma';
      _phoneController.text = '9876543210';
      _addressController.text = existing;
      _cityController.text = 'Hyderabad';
      _pincodeController.text = '500034';
      _selectedState = 'Telangana';
      _saveForFuture = true;
    } else if (widget.isEditing) {
      _nameController.text = 'Rahul Sharma';
      _phoneController.text = '9876543210';
      _addressController.text = 'Flat 203, Sunshine Residency, Road No. 12, Banjara Hills';
      _cityController.text = 'Hyderabad';
      _pincodeController.text = '500034';
      _selectedState = 'Telangana';
      _saveForFuture = true;
    } else {
      _selectedState = 'Choose State';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF111827), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'SILVRA',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD4B184), // Match 'SILVRA' text color
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSecureBadge(),
              const SizedBox(height: 24),
              Text(
                'Delivery Address',
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Where should your vault assets be securely\ndispatched?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Form Fields
              _buildFormSection(),
              
              const SizedBox(height: 24),
              
              // Toggle
              _buildSaveAddressToggle(),
              
              const SizedBox(height: 48),
              
              // Action Button
              _buildSaveButton(),
              
              const SizedBox(height: 48), // Bottom safe area
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecureBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBE1), // Pale beige
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_rounded, color: AppColors.primaryBrownGold, size: 16),
          const SizedBox(width: 8),
          Text(
            'SECURE DELIVERY',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBrownGold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('FULL NAME'),
        _buildTextField(_nameController, 'Enter your full legal name'),
        const SizedBox(height: 20),
        
        _buildLabel('MOBILE NUMBER'),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+91',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(_phoneController, '98765 43210', keyboardType: TextInputType.phone),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        _buildLabel('ADDRESS LINE'),
        _buildTextField(_addressController, 'House / Flat No., Building, Street'),
        const SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('CITY'),
                  _buildTextField(_cityController, 'Your City'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('PINCODE'),
                  _buildTextField(_pincodeController, '6-digit PIN', keyboardType: TextInputType.number),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        _buildLabel('SELECT STATE'),
        _buildStateSelector(),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF6B7280),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedState,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF6B7280)),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _selectedState == 'Choose State' ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
          ),
          items: _indianStates.map((String state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedState = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSaveAddressToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Save address for future deliveries',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 24, // Control the visual height
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: _saveForFuture,
                onChanged: (val) {
                  setState(() {
                    _saveForFuture = val;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: AppColors.primaryBrownGold,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD1D5DB),
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
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [const Color(0xFFD4B184), AppColors.primaryBrownGold],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrownGold.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_addressController.text.trim().isEmpty) return;

          String title = 'Home'; // Could be selectable, defaulting to Home
          String newStr = '$title - ${_nameController.text.isNotEmpty ? _nameController.text + ', ' : ''}${_phoneController.text}\n${_addressController.text}\n${_cityController.text}, ${_selectedState == "Choose State" ? "" : _selectedState} - ${_pincodeController.text}';

          if (widget.isEditing && widget.editIndex != null) {
            AppState().addresses[widget.editIndex!] = newStr;
          } else {
            AppState().addresses.add(newStr);
          }
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          'SAVE & CONTINUE',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
