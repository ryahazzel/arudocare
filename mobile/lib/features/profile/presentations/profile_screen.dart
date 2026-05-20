import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../order/providers/order_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();
    final completedCount = orders.completedOrders.length;
    final co2Saved = completedCount * 0.5;

    return SingleChildScrollView(
      child: Column(
        children: [
          _ProfileHeader(
            name: auth.userName,
            email: auth.user?['email'] as String? ?? '',
            role: auth.user?['role'] as String? ?? 'customer',
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ImpactCard(completedCount: completedCount, co2Saved: co2Saved),
                const SizedBox(height: 12),
                _StatsRow(completedCount: completedCount),
                const SizedBox(height: 12),
                _AccountCard(
                  name: auth.userName,
                  email: auth.user?['email'] as String? ?? '',
                  role: auth.user?['role'] as String? ?? 'customer',
                ),
                const SizedBox(height: 20),
                _LogoutButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  const _ProfileHeader({required this.name, required this.email, required this.role});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final isMerchant = role == 'merchant';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20, MediaQuery.of(context).padding.top + 24, 20, 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, const Color(0xFF2D8A78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isMerchant ? 'Merchant' : 'Customer',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Impact card (gamifikasi) ──────────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  final int completedCount;
  final double co2Saved;
  const _ImpactCard({required this.completedCount, required this.co2Saved});

  String get _level {
    if (completedCount == 0) return 'Pemula';
    if (completedCount <= 3) return 'Eco Starter';
    if (completedCount <= 9) return 'Green Hero';
    return 'Eco Warrior';
  }

  Color get _levelColor {
    if (completedCount == 0) return Colors.grey;
    if (completedCount <= 3) return const Color(0xFF81C784);
    if (completedCount <= 9) return kPrimaryColor;
    return const Color(0xFF1B5E20);
  }

  IconData get _levelIcon {
    if (completedCount == 0) return Icons.eco_outlined;
    if (completedCount <= 3) return Icons.park_outlined;
    if (completedCount <= 9) return Icons.forest_outlined;
    return Icons.nature_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withValues(alpha: 0.08),
            const Color(0xFF4CAF50).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              const Text('Environmental Impact',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _levelColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_levelIcon, size: 13, color: _levelColor),
                    const SizedBox(width: 4),
                    Text(_level,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _levelColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ImpactStat(
                  icon: Icons.restaurant_outlined,
                  value: '$completedCount',
                  label: 'Makanan\nDiselamatkan',
                ),
              ),
              Container(width: 1, height: 48, color: kPrimaryColor.withValues(alpha: 0.15)),
              Expanded(
                child: _ImpactStat(
                  icon: Icons.cloud_outlined,
                  value: '${co2Saved.toStringAsFixed(1)} kg',
                  label: 'CO₂\nDikurangi',
                ),
              ),
            ],
          ),
          if (completedCount < 10) ...[
            const SizedBox(height: 14),
            _LevelProgressBar(count: completedCount),
          ],
        ],
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _ImpactStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3)),
      ],
    );
  }
}

class _LevelProgressBar extends StatelessWidget {
  final int count;
  const _LevelProgressBar({required this.count});

  @override
  Widget build(BuildContext context) {
    final int next = count <= 3 ? 4 : 10;
    final double progress = count / next;
    final String nextLevel = count <= 3 ? 'Green Hero' : 'Eco Warrior';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Menuju $nextLevel',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('$count / $next makanan',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
        ),
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int completedCount;
  const _StatsRow({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_outlined,
            value: '${orders.activeOrders.length}',
            label: 'Pesanan Aktif',
            color: kOrangeColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline_rounded,
            value: '$completedCount',
            label: 'Selesai',
            color: kPrimaryColor,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Account info ──────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  const _AccountCard({required this.name, required this.email, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _InfoTile(icon: Icons.person_outline, label: 'Nama', value: name),
          const Divider(height: 1, indent: 56),
          _InfoTile(icon: Icons.email_outlined, label: 'Email', value: email),
          const Divider(height: 1, indent: 56),
          _InfoTile(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: role == 'merchant' ? 'Merchant' : 'Customer',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Logout ────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[400],
          side: BorderSide(color: Colors.red.shade200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Keluar?'),
              content: const Text('Kamu akan keluar dari akun ini.'),
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

          if (confirmed != true) return;
          if (!context.mounted) return;

          await context.read<AuthProvider>().logout();
          if (!context.mounted) return;

          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        },
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('Keluar dari Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}
