import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../shared/theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final qrCode = order['qr_code'] as String? ?? '';
    final productName = order['product_name'] as String? ?? '';
    final merchantName = order['merchant_name'] as String? ?? '';
    final quantity = order['quantity'] as int? ?? 1;
    final totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _SuccessIcon(),
              const SizedBox(height: 20),
              const Text(
                'Pesanan Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tunjukkan QR Code ini saat mengambil pesananmu',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 28),
              _OrderCard(
                productName: productName,
                merchantName: merchantName,
                quantity: quantity,
                totalPrice: totalPrice,
              ),
              const SizedBox(height: 20),
              _QrCard(qrCode: qrCode),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Pesan Lagi',
                  style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String productName;
  final String merchantName;
  final int quantity;
  final double totalPrice;

  const _OrderCard({
    required this.productName,
    required this.merchantName,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Produk', value: productName),
          const SizedBox(height: 8),
          _InfoRow(label: 'Merchant', value: merchantName),
          const SizedBox(height: 8),
          _InfoRow(label: 'Jumlah', value: '$quantity porsi'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _InfoRow(
            label: 'Total Bayar',
            value: 'Rp ${_fmt(totalPrice)}',
            valueStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kOrangeColor),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _QrCard extends StatelessWidget {
  final String qrCode;
  const _QrCard({required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              const Text('QR Code Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: qrCode.isEmpty ? 'INVALID' : qrCode,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
            errorStateBuilder: (ctx, err) => const SizedBox(
              height: 200,
              child: Center(child: Text('QR tidak valid')),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              qrCode,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: kPrimaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Scan QR ini di merchant untuk klaim pesananmu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

String _fmt(double price) {
  final val = price.toInt();
  if (val >= 1000000) {
    final jt = val / 1000000;
    return '${jt.toStringAsFixed(jt.truncateToDouble() == jt ? 0 : 1)} jt';
  }
  if (val >= 1000) {
    return '${val ~/ 1000}.${(val % 1000).toString().padLeft(3, '0')}';
  }
  return val.toString();
}
