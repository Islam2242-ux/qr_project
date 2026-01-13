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
    
    // Timer untuk pindah halaman setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      // Pastikan route '/home' sudah terdaftar di main.dart
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF553FB8), // Warna brand utama
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash.png', // Mengambil aset gambar
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),
            const Text(
              'QRODE',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Manrope', // Menggunakan font Manrope
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'QR Generator & Scanner',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} // Tutup kurung state di sini