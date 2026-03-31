import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MockGalleryScreen extends StatelessWidget {
  final String label;
  const MockGalleryScreen({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select $label',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Text('Recents', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-${1600000000000 + index}?auto=format&fit=crop&w=300&q=80'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: index == 0 ? const Center(child: Icon(Icons.camera_alt_rounded, color: Colors.white54)) : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MockCameraScreen extends StatefulWidget {
  final String label;
  const MockCameraScreen({super.key, required this.label});

  @override
  State<MockCameraScreen> createState() => _MockCameraScreenState();
}

class _MockCameraScreenState extends State<MockCameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock Camera Preview
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1554080353-a576cf803bda?auto=format&fit=crop&w=800&q=80'),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
              ),
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Icon(Icons.flash_off_rounded, color: Colors.white, size: 24),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Place your ${widget.label} within the frame',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(bottom: 60, top: 20),
                  color: Colors.black45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.photo_library_rounded, color: Colors.white, size: 30),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                      const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
