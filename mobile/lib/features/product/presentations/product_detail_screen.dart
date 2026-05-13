import 'package:flutter/material.dart';
import '../../home/models/product_model.dart';
import '../../../shared/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(context),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: _ContentCard(product: product),
                ),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'product_${product.id}',
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, st) => _imageFallback(),
                  )
                : _imageFallback(),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      color: kPrimaryColor.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.fastfood_outlined, size: 80, color: kPrimaryColor),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed: product.stock > 0
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} berhasil diamankan!'),
                      backgroundColor: kPrimaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.shield_outlined),
          label: Text(
            product.stock > 0 ? 'Amankan Makanan' : 'Stok Habis',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final ProductModel product;

  const _ContentCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeRow(),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  product.merchantName,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.place_outlined, size: 16, color: Colors.grey[400]),
              Text(
                ' ${product.distanceKm} km',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPriceSection(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          _buildInfoRow(
            Icons.access_time_outlined,
            'Waktu Pengambilan',
            _pickupTimeLabel(),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.inventory_2_outlined,
            'Sisa Porsi',
            '${product.stock} porsi tersedia',
            valueColor: _stockColor(),
          ),
          if (product.description != null && product.description!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              product.description!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeRow() {
    return Row(
      children: [
        _badge('-${product.discountPercent}%', kOrangeColor),
        const SizedBox(width: 8),
        _badge('Sisa ${product.stock} porsi', _stockColor()),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rp ${_fmt(product.originalPrice)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              'Rp ${_fmt(product.discountPrice)}',
              style: TextStyle(
                fontSize: 26,
                color: kOrangeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: kOrangeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Hemat Rp ${_fmt(product.originalPrice - product.discountPrice)}',
            style: TextStyle(
              color: kOrangeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String _pickupTimeLabel() {
    if (product.pickupTimeStart != null && product.pickupTimeEnd != null) {
      return '${product.pickupTimeStart} - ${product.pickupTimeEnd}';
    }
    return 'Tidak tersedia';
  }

  Color _stockColor() {
    if (product.stock > 5) return kPrimaryColor;
    if (product.stock > 1) return kOrangeColor;
    return Colors.red;
  }

  String _fmt(double price) {
    final val = price.toInt();
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)} jt';
    }
    if (val >= 1000) {
      final thousands = val ~/ 1000;
      final remainder = val % 1000;
      return remainder == 0
          ? '$thousands.000'
          : '$thousands.${remainder.toString().padLeft(3, '0')}';
    }
    return val.toString();
  }
}
