import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/models/product_model.dart';
import '../providers/order_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final ProductModel product;
  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _qty = 1;
  String _paymentMethod = 'ewallet';

  double get _subtotal => widget.product.discountPrice * _qty;
  double get _originalTotal => widget.product.originalPrice * _qty;
  double get _saved => _originalTotal - _subtotal;

  Future<void> _placeOrder() async {
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final userId = (auth.user?['id'] as num?)?.toInt() ?? 0;

    final success = await orderProvider.createOrder(
      userId: userId,
      product: widget.product,
      quantity: _qty,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: orderProvider.lastOrder!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Gagal membuat pesanan'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OrderProvider>().isLoading;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductCard(product: widget.product),
            const SizedBox(height: 12),
            _QtyCard(
              qty: _qty,
              maxQty: widget.product.stock,
              onDecrement: () { if (_qty > 1) setState(() => _qty--); },
              onIncrement: () { if (_qty < widget.product.stock) setState(() => _qty++); },
            ),
            const SizedBox(height: 12),
            _SectionLabel('Metode Pembayaran'),
            const SizedBox(height: 8),
            _PaymentOption(
              value: 'ewallet',
              groupValue: _paymentMethod,
              icon: Icons.account_balance_wallet_outlined,
              title: 'E-Wallet',
              subtitle: 'GoPay / OVO / DANA',
              onChanged: (v) => setState(() => _paymentMethod = v),
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              value: 'cod',
              groupValue: _paymentMethod,
              icon: Icons.payments_outlined,
              title: 'Bayar di Tempat',
              subtitle: 'Bayar saat pengambilan (COD)',
              onChanged: (v) => setState(() => _paymentMethod = v),
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              value: 'credits',
              groupValue: _paymentMethod,
              icon: Icons.stars_rounded,
              title: 'Arudo Credits',
              subtitle: '0 kredit tersedia',
              onChanged: (v) => setState(() => _paymentMethod = v),
              disabled: true,
            ),
            const SizedBox(height: 12),
            _PriceSummaryCard(
              originalTotal: _originalTotal,
              subtotal: _subtotal,
              saved: _saved,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        total: _subtotal,
        isLoading: isLoading,
        onPressed: isLoading ? null : _placeOrder,
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(product.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stack) => const Icon(Icons.fastfood_outlined, color: kPrimaryColor, size: 32)),
                  )
                : const Icon(Icons.fastfood_outlined, color: kPrimaryColor, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(product.merchantName,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Rp ${_fmt(product.originalPrice)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400], decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${_fmt(product.discountPrice)}',
                      style: const TextStyle(fontSize: 14, color: kOrangeColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyCard extends StatelessWidget {
  final int qty;
  final int maxQty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _QtyCard({required this.qty, required this.maxQty, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: kPrimaryColor, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Jumlah Porsi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          _QtyButton(icon: Icons.remove, onTap: qty > 1 ? onDecrement : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          _QtyButton(icon: Icons.add, onTap: qty < maxQty ? onIncrement : null),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: enabled ? Colors.white : Colors.grey[400]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String title;
  final String subtitle;
  final ValueChanged<String> onChanged;
  final bool disabled;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value && !disabled;
    return GestureDetector(
      onTap: disabled ? null : () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.grey[200]!,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: disabled
                    ? Colors.grey[100]
                    : (selected ? kPrimaryColor.withValues(alpha: 0.1) : kPrimaryColor.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: disabled ? Colors.grey[400] : kPrimaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: disabled ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[disabled ? 400 : 500]),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: disabled ? Colors.grey[300]! : (selected ? kPrimaryColor : Colors.grey[400]!),
                  width: 2,
                ),
                color: selected && !disabled ? kPrimaryColor : Colors.transparent,
              ),
              child: selected && !disabled
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final double originalTotal;
  final double subtotal;
  final double saved;
  const _PriceSummaryCard({required this.originalTotal, required this.subtotal, required this.saved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _PriceRow('Harga Asli', 'Rp ${_fmt(originalTotal)}', Colors.grey[600]!),
          const SizedBox(height: 8),
          _PriceRow('Diskon', '- Rp ${_fmt(saved)}', Colors.green[600]!),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          _PriceRow('Total Bayar', 'Rp ${_fmt(subtotal)}', Colors.black87,
              bold: true, valueColor: kOrangeColor),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final bool bold;
  final Color? valueColor;
  const _PriceRow(this.label, this.value, this.labelColor, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: labelColor, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: bold ? 16 : 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: valueColor ?? labelColor)),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double total;
  final bool isLoading;
  final VoidCallback? onPressed;
  const _BottomBar({required this.total, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Bayar', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                'Rp ${_fmt(total)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kOrangeColor),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
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
