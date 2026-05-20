import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../shared/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    final auth = context.read<AuthProvider>();
    final userId = (auth.user?['id'] as num?)?.toInt() ?? 0;
    await context.read<OrderProvider>().fetchUserOrders(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(tabController: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ActiveTab(onRefresh: _fetchOrders),
              const _HistoryTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TabController tabController;
  const _Header({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: EdgeInsets.fromLTRB(
        20, MediaQuery.of(context).padding.top + 16, 20, 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pesanan Saya',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabs: const [Tab(text: 'Aktif'), Tab(text: 'Riwayat')],
          ),
        ],
      ),
    );
  }
}

// ── Active tab ────────────────────────────────────────────────────────────────

class _ActiveTab extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _ActiveTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (provider.activeOrders.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'Belum ada pesanan aktif',
        sub: 'Pesanan yang menunggu pengambilan akan muncul di sini',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: kPrimaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.activeOrders.length,
        separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => _ActiveOrderCard(order: provider.activeOrders[i]),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _ActiveOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final qrCode = order['qr_code'] as String? ?? '';
    final productName = order['product_name'] as String? ?? '-';
    final merchantName = order['merchant_name'] as String? ?? '-';
    final quantity = order['quantity'] as int? ?? 1;
    final totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0;
    final createdAt = _fmtDate(order['created_at'] as String?);

    return Container(
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
          // Top info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(productName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    _StatusChip(status: 'pending'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.storefront_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(merchantName, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('$quantity porsi  •  ',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    Text('Rp ${_fmtPrice(totalPrice)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kOrangeColor)),
                    const Spacer(),
                    Text(createdAt, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Divider(height: 1)),
          // QR Code section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, color: kPrimaryColor, size: 18),
                    const SizedBox(width: 6),
                    const Text('Tunjukkan ke merchant saat ambil',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: QrImageView(
                      data: qrCode.isEmpty ? 'INVALID' : qrCode,
                      version: QrVersions.auto,
                      size: 160,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  qrCode,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── History tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (provider.completedOrders.isEmpty) {
      return _EmptyState(
        icon: Icons.history_rounded,
        message: 'Belum ada riwayat pesanan',
        sub: 'Pesanan yang sudah selesai akan muncul di sini',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.completedOrders.length,
      separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _HistoryOrderCard(order: provider.completedOrders[i]),
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _HistoryOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final productName = order['product_name'] as String? ?? '-';
    final merchantName = order['merchant_name'] as String? ?? '-';
    final quantity = order['quantity'] as int? ?? 1;
    final totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0;
    final completedAt = _fmtDate(order['completed_at'] as String? ?? order['created_at'] as String?);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_outline_rounded, color: kPrimaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(merchantName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$quantity porsi  •  $completedAt',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusChip(status: 'completed'),
              const SizedBox(height: 6),
              Text('Rp ${_fmtPrice(totalPrice)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kOrangeColor)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPending ? kOrangeColor : kPrimaryColor).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isPending ? 'Menunggu' : 'Selesai',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isPending ? kOrangeColor : kPrimaryColor,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyState({required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: kPrimaryColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(sub,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtDate(String? iso) {
  if (iso == null) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '-';
  }
}

String _fmtPrice(double price) {
  final val = price.toInt();
  if (val >= 1000000) {
    final jt = val / 1000000;
    return '${jt.toStringAsFixed(jt.truncateToDouble() == jt ? 0 : 1)} jt';
  }
  if (val >= 1000) return '${val ~/ 1000}.${(val % 1000).toString().padLeft(3, '0')}';
  return val.toString();
}
