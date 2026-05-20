import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme.dart';
import '../../home/models/product_model.dart';
import '../../home/providers/home_provider.dart';
import '../../product/presentations/product_detail_screen.dart';

// Mock coordinates untuk Jakarta Selatan — diganti dengan data GPS dari backend nanti
final Map<String, LatLng> _merchantCoords = {
  'Warung Bu Siti':    LatLng(-6.2615, 106.8106),
  'Roti Kita Bakery':  LatLng(-6.2658, 106.8172),
  'Pasar Segar':       LatLng(-6.2707, 106.8231),
  'Hana Kitchen':      LatLng(-6.2743, 106.8267),
  'Artisan Bread Co.': LatLng(-6.2798, 106.8328),
};

final _fallbackCoords = [
  LatLng(-6.2550, 106.8050),
  LatLng(-6.2680, 106.8020),
  LatLng(-6.2730, 106.8150),
];

class _MerchantPin {
  final String merchantName;
  final LatLng position;
  final List<ProductModel> products;

  const _MerchantPin({
    required this.merchantName,
    required this.position,
    required this.products,
  });
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  List<_MerchantPin> _buildPins(List<ProductModel> products) {
    final Map<String, List<ProductModel>> grouped = {};
    for (final p in products) {
      grouped.putIfAbsent(p.merchantName, () => []).add(p);
    }

    int fallbackIdx = 0;
    return grouped.entries.map((e) {
      final coord = _merchantCoords[e.key] ?? _fallbackCoords[fallbackIdx++ % _fallbackCoords.length];
      return _MerchantPin(merchantName: e.key, position: coord, products: e.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<HomeProvider>().nearbyDeals;
    final pins = _buildPins(products);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(-6.2680, 106.8190),
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.arudocare.app',
            ),
            MarkerLayer(
              markers: pins.map((pin) => Marker(
                point: pin.position,
                width: 52,
                height: 52,
                child: GestureDetector(
                  onTap: () => _showMerchantSheet(context, pin),
                  child: _MapMarker(productCount: pin.products.length),
                ),
              )).toList(),
            ),
          ],
        ),
        // Header overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: kPrimaryColor, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Peta Makanan Terdekat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${pins.length} restoran',
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMerchantSheet(BuildContext context, _MerchantPin pin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MerchantBottomSheet(pin: pin),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final int productCount;
  const _MapMarker({required this.productCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 22),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kOrangeColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              '$productCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MerchantBottomSheet extends StatelessWidget {
  final _MerchantPin pin;
  const _MerchantBottomSheet({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront_outlined, color: kPrimaryColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pin.merchantName,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text(
                          '${pin.products.first.distanceKm} km dari kamu',
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pin.products.length} produk',
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Text(
            'Produk Tersedia',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...pin.products.map((p) => _ProductRow(product: p)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: pin.products.first),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text(
                'Lihat Produk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final ProductModel product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: kPrimaryColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              product.name,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${_fmt(product.discountPrice)}',
            style: const TextStyle(
              fontSize: 13,
              color: kOrangeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double price) {
    final val = price.toInt();
    if (val >= 1000) {
      return '${val ~/ 1000}.${(val % 1000).toString().padLeft(3, '0')}';
    }
    return val.toString();
  }
}
