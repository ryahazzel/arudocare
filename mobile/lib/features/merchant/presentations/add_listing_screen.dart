import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/merchant_provider.dart';

const _categories = {
  1: 'Makanan Siap Saji',
  2: 'Bakery',
  3: 'Sayuran',
  4: 'Belanja',
};

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _originalPriceCtrl = TextEditingController();
  final _discountPriceCtrl = TextEditingController();
  int _stock = 1;
  int _selectedCategoryId = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _originalPriceCtrl.dispose();
    _discountPriceCtrl.dispose();
    super.dispose();
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _displayTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) { _startTime = picked; } else { _endTime = picked; }
    });
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final originalPrice = double.tryParse(_originalPriceCtrl.text.trim()) ?? 0;
    final discountPrice = double.tryParse(_discountPriceCtrl.text.trim()) ?? 0;

    if (name.isEmpty || originalPrice <= 0 || discountPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama, harga asli, dan harga diskon wajib diisi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (discountPrice >= originalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga diskon harus lebih kecil dari harga asli'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final merchantId = (auth.user?['id'] as num?)?.toInt() ?? 0;
    final merchantName = auth.userName;

    final success = await context.read<MerchantProvider>().addProduct(
          merchantId: merchantId,
          merchantName: merchantName,
          name: name,
          description: _descCtrl.text.trim(),
          originalPrice: originalPrice,
          discountPrice: discountPrice,
          stock: _stock,
          categoryId: _selectedCategoryId,
          pickupTimeStart: _fmtTime(_startTime),
          pickupTimeEnd: _fmtTime(_endTime),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil diposting!'),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final err = context.read<MerchantProvider>().error ?? 'Gagal menambah produk';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<MerchantProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Tambah Listing Baru',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              title: 'Informasi Produk',
              icon: Icons.fastfood_outlined,
              children: [
                _label('Nama Produk'),
                const SizedBox(height: 8),
                _textField(controller: _nameCtrl, hint: 'Contoh: Nasi Kotak Sisa Siang'),
                const SizedBox(height: 14),
                _label('Deskripsi (opsional)'),
                const SizedBox(height: 8),
                _textField(
                  controller: _descCtrl,
                  hint: 'Ceritakan kondisi makanan, bahan, dll...',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _label('Kategori'),
                const SizedBox(height: 8),
                _CategorySelector(
                  selected: _selectedCategoryId,
                  onChanged: (id) => setState(() => _selectedCategoryId = id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Harga & Stok',
              icon: Icons.monetization_on_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Harga Asli (Rp)'),
                          const SizedBox(height: 8),
                          _textField(
                            controller: _originalPriceCtrl,
                            hint: '50000',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Harga Diskon (Rp)'),
                          const SizedBox(height: 8),
                          _textField(
                            controller: _discountPriceCtrl,
                            hint: '20000',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _label('Jumlah Porsi (Stok)'),
                const SizedBox(height: 8),
                _StockSelector(
                  value: _stock,
                  onDecrement: () { if (_stock > 1) setState(() => _stock--); },
                  onIncrement: () { if (_stock < 99) setState(() => _stock++); },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Waktu Pengambilan',
              icon: Icons.access_time_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TimePicker(
                        label: 'Mulai',
                        time: _displayTime(_startTime),
                        onTap: () => _pickTime(true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('—', style: TextStyle(color: Colors.grey[400], fontSize: 20)),
                    ),
                    Expanded(
                      child: _TimePicker(
                        label: 'Selesai',
                        time: _displayTime(_endTime),
                        onTap: () => _pickTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: kPrimaryColor.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Text(
                        'Customer harus mengambil dalam rentang waktu ini',
                        style: TextStyle(fontSize: 11, color: kPrimaryColor.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  isSubmitting ? 'Memposting...' : 'Posting Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          ...children,
        ],
      ),
    );
  }
}

// ── Category selector ─────────────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _CategorySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.entries.map((e) {
        final isSelected = e.key == selected;
        return GestureDetector(
          onTap: () => onChanged(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? kPrimaryColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey.shade200),
            ),
            child: Text(
              e.value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Stock selector ────────────────────────────────────────────────────────────

class _StockSelector extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _StockSelector({required this.value, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QtyBtn(icon: Icons.remove, onTap: value > 1 ? onDecrement : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _QtyBtn(icon: Icons.add, onTap: value < 99 ? onIncrement : null),
        const SizedBox(width: 12),
        Text('porsi', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? kPrimaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: enabled ? Colors.white : Colors.grey[400]),
      ),
    );
  }
}

// ── Time picker tile ──────────────────────────────────────────────────────────

class _TimePicker extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;
  const _TimePicker({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: kPrimaryColor),
                const SizedBox(width: 6),
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kPrimaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _label(String text) =>
    Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600));

Widget _textField({
  required TextEditingController controller,
  required String hint,
  int maxLines = 1,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      ),
    ),
  );
}
