import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  bool _isVerifying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;
    final code = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isScanning = false;
      _isVerifying = true;
    });

    try {
      final response = await ApiClient().dio.put(
        '/orders/verify',
        data: {'qr_code': code},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _showResult(true, 'Pesanan berhasil diverifikasi!');
      } else {
        _showResult(false, 'QR Code tidak valid atau sudah dipakai');
      }
    } catch (_) {
      if (!mounted) return;
      _showResult(false, 'Gagal menghubungi server. Coba lagi.');
    }
  }

  void _showResult(bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? kPrimaryColor : Colors.red[400],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
    if (success) {
      Navigator.pop(context, true);
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isScanning = true;
            _isVerifying = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Scan QR Pelanggan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            tooltip: 'Senter',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          CustomPaint(
            painter: _OverlayPainter(),
            child: const SizedBox.expand(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 56),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
              child: Column(
                children: [
                  if (_isVerifying)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  else
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 30,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _isVerifying
                        ? 'Memverifikasi pesanan...'
                        : 'Arahkan kamera ke QR Code pelanggan',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutSize = size.width * 0.65;
    final cutout = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: cutoutSize,
      height: cutoutSize,
    );

    final overlayPaint = Paint()..color = Colors.black54;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    final cornerPaint = Paint()
      ..color = kPrimaryColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const c = 22.0;
    // Top-left
    canvas.drawLine(cutout.topLeft + const Offset(c, 0), cutout.topLeft, cornerPaint);
    canvas.drawLine(cutout.topLeft, cutout.topLeft + const Offset(0, c), cornerPaint);
    // Top-right
    canvas.drawLine(cutout.topRight + const Offset(-c, 0), cutout.topRight, cornerPaint);
    canvas.drawLine(cutout.topRight, cutout.topRight + const Offset(0, c), cornerPaint);
    // Bottom-left
    canvas.drawLine(cutout.bottomLeft + const Offset(c, 0), cutout.bottomLeft, cornerPaint);
    canvas.drawLine(cutout.bottomLeft, cutout.bottomLeft + const Offset(0, -c), cornerPaint);
    // Bottom-right
    canvas.drawLine(cutout.bottomRight + const Offset(-c, 0), cutout.bottomRight, cornerPaint);
    canvas.drawLine(cutout.bottomRight, cutout.bottomRight + const Offset(0, -c), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
