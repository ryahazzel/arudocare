import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/merchant_provider.dart';
import 'add_listing_screen.dart';
import 'inventory_screen.dart';
import 'qr_scanner_screen.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrders());
  }

  Future<void> _fetchOrders() async {
    final auth = context.read<AuthProvider>();
    final merchantId = (auth.user?['id'] as num?)?.toInt() ?? 0;
    await context.read<MerchantProvider>().fetchOrders(merchantId);
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _openAddListing() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddListingScreen()),
    );
    if (result == true && mounted) await _fetchOrders();
  }

  Future<void> _openScanner() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?'),
        content: const Text('Kamu akan keluar dari akun merchant ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final merchant = context.watch<MerchantProvider>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(auth.userName),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardBody(merchant),
          const InventoryScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: 'Inventori',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? _PostingFAB(onTap: _openAddListing)
          : null,
    );
  }

  Widget _buildDashboardBody(MerchantProvider merchant) {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: kPrimaryColor,
      child: merchant.isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GreetingHeader(name: context.read<AuthProvider>().userName),
                      const SizedBox(height: 16),
                      _StatsSection(
                        revenue: merchant.todayRevenue,
                        portionsSaved: merchant.portionsSaved,
                        pendingCount: merchant.pendingOrders.length,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        title: 'Pesanan Masuk',
                        count: merchant.pendingOrders.length,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                if (merchant.pendingOrders.isEmpty)
                  SliverToBoxAdapter(child: _EmptyOrders())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _OrderCard(order: merchant.pendingOrders[i]),
                        ),
                        childCount: merchant.pendingOrders.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(String name) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          Icon(Icons.storefront_rounded, size: 22),
          SizedBox(width: 8),
          Text('Merchant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          tooltip: 'Scan QR',
          onPressed: _openScanner,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Keluar',
          onPressed: _logout,
        ),
      ],
    );
  }
}

// ── Header greeting ───────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String name;
  const _GreetingHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang,',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _greetingByHour(),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _greetingByHour() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Semangat pagi! Ada makanan sisa yang mau diposting?';
    if (h < 15) return 'Selamat siang! Cek pesanan masuk yuk.';
    if (h < 18) return 'Selamat sore! Jangan lupa update stok.';
    return 'Selamat malam! Rekap pesanan hari ini.';
  }
}

// ── Stats cards ───────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  final double revenue;
  final int portionsSaved;
  final int pendingCount;
  const _StatsSection({
    required this.revenue,
    required this.portionsSaved,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.payments_outlined,
              label: 'Pendapatan Hari Ini',
              value: 'Rp ${_fmt(revenue)}',
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.restaurant_outlined,
              label: 'Porsi Terselamatkan',
              value: '$portionsSaved porsi',
              color: kOrangeColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.pending_actions_outlined,
              label: 'Menunggu',
              value: '$pendingCount pesanan',
              color: const Color(0xFF5C6BC0),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kOrangeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kOrangeColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final productName = order['product_name'] as String? ?? '-';
    final quantity = order['quantity'] as int? ?? 1;
    final totalPrice = (order['total_price'] as num?)?.toDouble() ?? 0;
    final createdAt = _fmtDate(order['created_at'] as String?);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kOrangeColor.withValues(alpha: 0.3)),
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
              color: kOrangeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long_outlined, color: kOrangeColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$quantity porsi  •  $createdAt',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kOrangeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Siapkan',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kOrangeColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${_fmt(totalPrice)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 36,
                color: kPrimaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum ada pesanan masuk',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap tombol + untuk posting makanan sisa',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _PostingFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _PostingFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_circle_outline_rounded),
      label: const Text('Posting Makanan Sisa', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmt(double price) {
  final val = price.toInt();
  if (val >= 1000000) {
    final jt = val / 1000000;
    return '${jt.toStringAsFixed(jt.truncateToDouble() == jt ? 0 : 1)} jt';
  }
  if (val >= 1000) return '${val ~/ 1000}.${(val % 1000).toString().padLeft(3, '0')}';
  return val.toString();
}

String _fmtDate(String? iso) {
  if (iso == null) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${dt.day} ${months[dt.month - 1]}, ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  } catch (_) {
    return '-';
  }
}
