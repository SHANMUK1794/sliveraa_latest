import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavbar({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90, 
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), 
                  blurRadius: 15, 
                  offset: const Offset(0, -5)
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_filled, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.show_chart_rounded, Icons.show_chart_rounded, 'Market'),
                const SizedBox(width: 60), // Space for center button
                _buildNavItem(3, Icons.card_giftcard_rounded, Icons.card_giftcard_rounded, 'Rewards'),
                _buildNavItem(4, Icons.history_rounded, Icons.history_rounded, 'History'),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onItemTapped(2),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFB08C65), // AppColors.primaryBrownGold constant match
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB08C65).withOpacity(0.5), 
                      blurRadius: 10, 
                      offset: const Offset(0, 4)
                    )
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded, 
                  color: Colors.white, 
                  size: 28
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    bool isSelected = selectedIndex == index;
    Color color = isSelected ? const Color(0xFFB08C65) : const Color(0xFF94A3B8);
    
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : inactiveIcon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
