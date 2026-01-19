import 'dart:async';
import 'package:flutter/foundation.dart'; // Wajib untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'qr_generator_screen.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // CONFIG: autoStart false agar kita pegang kendali penuh
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
    autoStart: false, 
  );

  String? _barcodeValue;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Jalankan kamera diam-diam
    _startCameraSilent();
  }

  Future<void> _startCameraSilent() async {
    // Delay kecil untuk safety rendering UI
    await Future.delayed(const Duration(milliseconds: 100));

    // Cek izin di HP (tanpa popup snackbar error)
    if (!kIsWeb) {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        await Permission.camera.request();
      }
    }

    // Coba start kamera. Jika gagal, biarkan saja (catch block kosong).
    try {
      await _controller.start();
    } catch (e) {
      // Silent catch: Tidak melakukan apa-apa jika error.
      // Layar akan tetap hitam (dari placeholder).
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return; 
    if (!_controller.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_selectedIndex == 0) _controller.start();
        break;
      case AppLifecycleState.inactive:
        _controller.stop();
        break;
      default:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildScannerView();
      case 1:
        return const QrGeneratorScreen();
      case 2:
        return const Center(
          child: Text("History Screen", style: TextStyle(color: Colors.black)),
        );
      default:
        return _buildScannerView();
    }
  }

  Widget _buildScannerView() {
    // Ukuran area scan
    const double scanAreaSize = 260.0;

    return Stack(
      children: [
        // 1. KAMERA (Paling Bawah)
        Positioned.fill(
          child: MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            // HAPUS SEMUA TAMPILAN ERROR
            // Jika error, return widget kosong (Hitam)
            errorBuilder: (context, error,) {
              return const ColoredBox(color: Colors.black);
            },
            // Saat loading juga Hitam
            placeholderBuilder: (context,) {
              return const ColoredBox(color: Colors.black);
            },
          ),
        ),

        // 2. OVERLAY MANUAL (4 Kotak Hitam - Aman untuk Web)
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            final double verticalGap = (height - scanAreaSize) / 2;
            final double horizontalGap = (width - scanAreaSize) / 2;

            return Stack(
              children: [
                // Atas
                Positioned(
                  top: 0, left: 0, right: 0, height: verticalGap,
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
                // Bawah
                Positioned(
                  bottom: 0, left: 0, right: 0, height: verticalGap,
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
                // Kiri
                Positioned(
                  top: verticalGap, left: 0, width: horizontalGap, height: scanAreaSize,
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
                // Kanan
                Positioned(
                  top: verticalGap, right: 0, width: horizontalGap, height: scanAreaSize,
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ],
            );
          },
        ),

        // 3. BORDER HIASAN (Pojok Putih)
        Center(
          child: Container(
            width: scanAreaSize,
            height: scanAreaSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
            ),
            child: CustomPaint(
              painter: ScannerOverlayPainter(),
            ),
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
          _buildBody(),

          // HEADER UI
          if (_selectedIndex == 0)
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
                          Text('Hello,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('M. Galih', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.white),
                        onPressed: () => _controller.toggleTorch(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // NAVBAR BAWAH
          Positioned(
            left: 24, right: 24, bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2).withOpacity(0.95),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
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
        if (index != 0) {
           _controller.stop();
        } else {
           _startCameraSilent();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.blueAccent : Colors.grey[600], size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.blueAccent : Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _handleBarcode(BarcodeCapture capture) {
    final Uint8List? image = capture.image;
    final barcode = capture.barcodes.firstOrNull;

    if (barcode != null && barcode.rawValue != null && image != null) {
      if (!kIsWeb) _controller.stop(); 
      setState(() => _barcodeValue = barcode.rawValue);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('QR Terdeteksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(image, height: 180),
              const SizedBox(height: 16),
              SelectableText(_barcodeValue!, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (!kIsWeb) _controller.start();
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 5.0;
    const cornerLength = 30.0;
    final path = Path();
    path.moveTo(0, cornerLength); path.lineTo(0, 0); path.lineTo(cornerLength, 0);
    path.moveTo(size.width - cornerLength, 0); path.lineTo(size.width, 0); path.lineTo(size.width, cornerLength);
    path.moveTo(0, size.height - cornerLength); path.lineTo(0, size.height); path.lineTo(cornerLength, size.height);
    path.moveTo(size.width - cornerLength, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}