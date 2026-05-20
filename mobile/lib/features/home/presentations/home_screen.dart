import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../shared/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../product/presentations/product_detail_screen.dart';
import '../../map/presentations/map_screen.dart';
import '../../order/presentations/orders_screen.dart';
import '../../order/providers/order_provider.dart';
import '../../profile/presentations/profile_screen.dart';
import '../providers/home_provider.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeBannerIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchNearbyDeals();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<HomeProvider>(context, listen: false).fetchNearbyDeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _selectedIndex == 0 ? _buildAppBar(context) : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeBody(),
          const MapScreen(),
          const OrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: kPrimaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const _SearchBar(),
            const SizedBox(height: 16),
            const _UserInfoCard(),
            const SizedBox(height: 20),
            _BannerCarousel(
              activeIndex: _activeBannerIndex,
              onPageChanged: (index) =>
                  setState(() => _activeBannerIndex = index),
            ),
            const SizedBox(height: 20),
            const _CategorySection(),
            const SizedBox(height: 20),
            const _NearbyDealsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) {
        setState(() => _selectedIndex = i);
        if (i == 2) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final userId = (auth.user?['id'] as num?)?.toInt() ?? 0;
          Provider.of<OrderProvider>(context, listen: false).fetchUserOrders(userId);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey[400],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      elevation: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map_rounded),
          label: 'Peta',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          const Text(
            'Jakarta Selatan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Mau selamatkan produk apa hari ini?',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(Icons.search, color: kPrimaryColor),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final name = auth.userName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, const Color(0xFF2D8A78)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha:0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withValues(alpha:0.25),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $name!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Arudo Credits: 0',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Pemula',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _banners = [
  _BannerData(
    title: 'Daily Eco Deals',
    subtitle: 'Hemat lebih banyak,\nbuang lebih sedikit!',
    color: Color(0xFF39A28F),
    icon: Icons.eco_outlined,
  ),
  _BannerData(
    title: 'Bakery Flash Sale',
    subtitle: 'Roti & kue segar\nhingga 70% OFF!',
    color: Color(0xFFF2994A),
    icon: Icons.bakery_dining_outlined,
  ),
  _BannerData(
    title: 'Sayuran Segar',
    subtitle: 'Langsung dari petani,\nharga bersahabat!',
    color: Color(0xFF4CAF50),
    icon: Icons.grass_outlined,
  ),
];

class _BannerData {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

class _BannerCarousel extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onPageChanged;

  const _BannerCarousel({
    required this.activeIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 150,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) => onPageChanged(index),
          ),
          items: _banners.map((banner) {
            return Container(
              decoration: BoxDecoration(
                color: banner.color,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          banner.subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Lihat Sekarang',
                            style: TextStyle(
                              color: banner.color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(banner.icon,
                      size: 72, color: Colors.white.withValues(alpha:0.25)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activeIndex == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: activeIndex == i ? kPrimaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _categories = [
  _CategoryData(label: 'Belanja', icon: Icons.shopping_bag_outlined),
  _CategoryData(label: 'Bakery', icon: Icons.bakery_dining_outlined),
  _CategoryData(label: 'Sayuran', icon: Icons.eco_outlined),
  _CategoryData(label: 'Siap Saji', icon: Icons.fastfood_outlined),
];

class _CategoryData {
  final String label;
  final IconData icon;

  const _CategoryData({required this.label, required this.icon});
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kategori',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _categories.map((cat) {
              return _CategoryItem(data: cat);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final _CategoryData data;

  const _CategoryItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: kPrimaryColor, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _NearbyDealsSection extends StatelessWidget {
  const _NearbyDealsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Deals',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(color: kPrimaryColor, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        Consumer<HomeProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                ),
              );
            }
            if (provider.nearbyDeals.isEmpty) {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: Text('Belum ada produk tersedia.',
                      style: TextStyle(color: Colors.grey)),
                ),
              );
            }
            return SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.nearbyDeals.length,
                separatorBuilder: (_, idx) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _DealCard(product: provider.nearbyDeals[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  final ProductModel product;

  const _DealCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
      const Color(0xFFE3F2FD),
      const Color(0xFFF3E5F5),
      const Color(0xFFFCE4EC),
    ];
    final iconColors = [
      const Color(0xFF4CAF50),
      kOrangeColor,
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
    ];
    final colorIndex = int.parse(product.id) % colors.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.imageUrl != null
                        ? Hero(
                            tag: 'product_${product.id}',
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) =>
                                  progress == null
                                      ? child
                                      : Container(
                                          color: colors[colorIndex],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: kPrimaryColor),
                                          ),
                                        ),
                              errorBuilder: (ctx, e, st) => Container(
                                color: colors[colorIndex],
                                child: Center(
                                  child: Icon(Icons.fastfood_outlined,
                                      size: 48,
                                      color: iconColors[colorIndex]),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: colors[colorIndex],
                            child: Center(
                              child: Icon(Icons.fastfood_outlined,
                                  size: 48, color: iconColors[colorIndex]),
                            ),
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: kOrangeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.merchantName,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${_formatPrice(product.originalPrice)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${_formatPrice(product.discountPrice)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: kOrangeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 12, color: Colors.grey[400]),
                          Text(
                            '${product.distanceKm} km',
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
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final val = price.toInt();
    if (val >= 1000) {
      return '${(val ~/ 1000)}.${((val % 1000) ~/ 100).toString().padLeft(3, '0')}'
          .replaceAll('.000', '.000');
    }
    return val.toString();
  }
}
