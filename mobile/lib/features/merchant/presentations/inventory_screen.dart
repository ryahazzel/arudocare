import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/merchant_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    final merchantId = (context.read<AuthProvider>().user?['id'] as num?)?.toInt() ?? 0;
    await context.read<MerchantProvider>().fetchInventory(merchantId);
  }

  @override
  Widget build(BuildContext context) {
    final merchant = context.watch<MerchantProvider>();
    final inventory = merchant.inventory;

    if (merchant.isInventoryLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      color: kPrimaryColor,
      child: inventory.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada produk',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambahkan produk via tombol + di Dashboard',
                          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: inventory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final product = inventory[index];
                return _InventoryCard(
                  product: product,
                  onToggle: () => context.read<MerchantProvider>().toggleProduct(
                    (product['id'] as num).toInt(),
                  ),
                );
              },
            ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onToggle;
  const _InventoryCard({required this.product, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] as String? ?? '-';
    final originalPrice = (product['original_price'] as num?)?.toDouble() ?? 0;
    final discountPrice = (product['discount_price'] as num?)?.toDouble() ?? 0;
    final stock = product['stock'] as int? ?? 0;
    final category = product['category'] as String? ?? '-';
    final isActive = product['is_active'] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (isActive ? kPrimaryColor : Colors.grey).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.fastfood_rounded,
              color: isActive ? kPrimaryColor : Colors.grey[400],
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? Colors.black87 : Colors.grey[400],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Stok: $stock',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Rp ${_fmt(discountPrice)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: kOrangeColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Rp ${_fmt(originalPrice)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Switch(
                value: isActive,
                onChanged: (_) => onToggle(),
                activeColor: kPrimaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                isActive ? 'Tersedia' : 'Habis',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? kPrimaryColor : Colors.grey[400],
                ),
              ),
            ],
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
  if (val >= 1000) return '${val ~/ 1000}.${(val % 1000).toString().padLeft(3, '0')}';
  return val.toString();
}
