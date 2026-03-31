import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_state.dart';
import '../../theme/app_colors.dart';
import '../delivery/add_delivery_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  void _deleteAddress(int index) {
    setState(() {
      AppState().addresses.removeAt(index);
    });
  }

  void _addNewAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDeliveryAddressScreen()),
    ).then((_) {
      // Refresh the screen when returning (in a real app we'd get data back)
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final addresses = AppState().addresses;

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
          'Saved Addresses',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: addresses.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: addresses.length,
            itemBuilder: (context, index) => _buildAddressCard(index, addresses[index]),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAddress,
        backgroundColor: AppColors.primaryBrownGold,
        label: Text('Add New', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No saved addresses',
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(int index, String address) {
    String type = address.split(' - ')[0];
    String details = address.contains(' - ') ? address.split(' - ')[1] : address;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              type.toLowerCase() == 'home' ? Icons.home_rounded : 
              type.toLowerCase() == 'office' ? Icons.work_rounded : Icons.location_on_rounded,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8), height: 1.4),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDeliveryAddressScreen(isEditing: true, editIndex: index)),
                ).then((_) {
                  setState(() {});
                });
              } else {
                _deleteAddress(index);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
