import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme.dart';
import '../../home/models/product_model.dart';
import '../../home/providers/home_provider.dart';
import '../../product/presentations/product_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setFilter({String query = '', String? category}) {
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
      _selectedCategory = category;
    });
  }

  List<ProductModel> _filter(List<ProductModel> products) {
    return products.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchQ = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.merchantName.toLowerCase().contains(q);
      final matchC = _selectedCategory == null ||
          p.category.toLowerCase().contains(_selectedCategory!.toLowerCase());
      return matchQ && matchC;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final all = provider.nearbyDeals;
    final filtered = _filter(all);
    final cats = [
      'Semua',
      ...{...all.map((p) => p.category).where((c) => c.isNotEmpty)},
    ];

    return Column(
      children: [
        _SearchHeader(
          controller: _searchController,
          query: _searchQuery,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() {
            _searchQuery = '';
            _searchController.clear();
          }),
        ),
        if (cats.length > 1)
          _CategoryChips(
            categories: cats,
            selected: _selectedCategory,
            onSelect: (cat) =>
                setState(() => _selectedCategory = cat == 'Semua' ? null : cat),
          ),
        Expanded(
          child: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor))
              : filtered.isEmpty
                  ? _EmptyState(
                      isFiltered: _searchQuery.isNotEmpty ||
                          _selectedCategory != null)
                  : RefreshIndicator(
                      color: kPrimaryColor,
                      onRefresh: () =>
                          context.read<HomeProvider>().fetchNearbyDeals(),
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _ProductCard(product: filtered[i]),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jelajahi',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Cari produk atau merchant...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          size: 18, color: Colors.grey),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected =
              (cat == 'Semua' && selected == null) || cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? kPrimaryColor
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorIndex = int.parse(product.id) % _bgColors.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: product.imageUrl != null
                    ? Hero(
                        tag: 'explore_product_${product.id}',
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imageFallback(colorIndex),
                        ),
                      )
                    : _imageFallback(colorIndex),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: kOrangeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.storefront_outlined,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            product.merchantName,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (product.category.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                              fontSize: 10, color: kPrimaryColor),
                        ),
                      ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rp ${_fmt(product.originalPrice)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'Rp ${_fmt(product.discountPrice)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: kOrangeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 12, color: Colors.grey[400]),
                            Text(
                              '${product.distanceKm.toStringAsFixed(1)} km',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(int colorIndex) {
    return Container(
      color: _bgColors[colorIndex],
      child: Center(
        child: Icon(Icons.fastfood_outlined,
            size: 36, color: _iconColors[colorIndex]),
      ),
    );
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
}

class _EmptyState extends StatelessWidget {
  final bool isFiltered;
  const _EmptyState({required this.isFiltered});

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
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.store_outlined,
                size: 40,
                color: kPrimaryColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'Produk tidak ditemukan'
                  : 'Belum ada produk tersedia',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Coba kata kunci atau kategori lain'
                  : 'Merchant belum memposting produk',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

const _bgColors = [
  Color(0xFFE8F5E9),
  Color(0xFFFFF3E0),
  Color(0xFFE3F2FD),
  Color(0xFFF3E5F5),
  Color(0xFFFCE4EC),
];

const _iconColors = [
  Color(0xFF4CAF50),
  Color(0xFFF2994A),
  Color(0xFF2196F3),
  Color(0xFF9C27B0),
  Color(0xFFE91E63),
];
