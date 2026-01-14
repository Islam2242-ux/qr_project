import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_scanner_screen.dart'; // Tetap import untuk ScannerOverlayPainter
import 'qr_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  int _selectedIndex = 0;

  // Fungsi untuk menampilkan konten berdasarkan index
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return QrScannerScreen(); // Pindahkan UI Scanner ke sini
      case 1:
        return const QrGeneratorScreen(); // File yang ingin kamu hubungkan
      case 2:
        return const Center(child: Text("History Screen", style: TextStyle(color: Colors.white)));
      default:
        return QrScannerScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan extendBody agar kamera masuk ke area bawah navbar
      extendBody: true,
      // Menggunakan extendBodyBehindAppBar agar kamera masuk ke area status bar
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBody(),
          
          // 1. SCANNER SEBAGAI BACKGROUND FULL (Paling Belakang)
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                // Logika handle barcode
              },
            ),
          ),

          // 2. OVERLAY GELAP DENGAN LUBANG SCANNER
          // ColorFiltered membuat efek lubang transparan di tengah background hitam transparan
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BORDER SCANNER (Putih di pojok-pojok)
          Center(
            child: CustomPaint(
              size: const Size(260, 260),
              painter: ScannerOverlayPainter(), 
            ),
          ),

          // 4. UI LAYER ATAS (Profil, Nama, Flash)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          'Ade Setiawan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. NAVBAR MELAYANG DI BAWAH
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2).withOpacity(0.95), // Warna abu-abu navbar
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.qr_code_scanner, "Scan", 0),
                  _buildNavItem(Icons.add_box_rounded, "Create", 1),
                  _buildNavItem(Icons.history, "History", 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blueAccent : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}