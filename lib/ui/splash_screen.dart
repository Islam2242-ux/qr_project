import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Timer 3 detik tetap dipertahankan
    Timer(const Duration(seconds: 3), () {
      // Menggunakan pushReplacementNamed agar Splash Screen dihapus dari memori
      // dan digantikan oleh HomeScreen sebagai satu-satunya halaman aktif
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bagian UI ini tetap sama persis seperti kode kamu (tidak akan berubah tampilannya)
    return Scaffold(
      backgroundColor: const Color(0xFF553FB8), // Warna brand utama
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash.png', width: 180, height: 180),
            const SizedBox(height: 24),
            const Text(
              'QRODE',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope',
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'QR Generator & Scanner',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
