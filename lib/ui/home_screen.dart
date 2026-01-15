import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_scanner_screen.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 1. FUNGSI UNTUK MENAMPILKAN KONTEN (Penting: Scanner dipisah ke fungsi sendiri)
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildScannerView(); // Memanggil tampilan kamera
      case 1:
        return const QrGeneratorScreen(); // Memanggil tampilan generator
      case 2:
        return const Center(
          child: Text("History Screen", style: TextStyle(color: Colors.white)),
        );
      default:
        return _buildScannerView();
    }
  }

  // 2. FUNGSI KHUSUS UNTUK UI SCANNER
  Widget _buildScannerView() {
    return Stack(
      children: [
        // SCANNER SEBAGAI BACKGROUND
        Positioned.fill(
          child: MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              // Logika handle barcode
            },
          ),
        ),

        // OVERLAY GELAP DENGAN LUBANG
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

        // BORDER PUTIH DI POJOK
        Center(
          child: CustomPaint(
            size: const Size(260, 260),
            painter: ScannerOverlayPainter(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // TAMPILKAN BODY (Hanya satu yang aktif: Scanner ATAU Generator)
          _buildBody(),

          // UI LAYER ATAS (Hanya muncul jika sedang di mode Scan)
          if (_selectedIndex == 0)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Kamu',
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

          // NAVBAR MELAYANG (Muncul di semua halaman)
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2).withOpacity(0.95),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
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
      onTap: () {
        setState(() => _selectedIndex = index);
        // Mengatur kamera agar berhenti saat tidak digunakan
        if (index != 0) {
          _controller.stop();
        } else {
          _controller.start();
        }
      },
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
