import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';
import 'auth/otp_verification_screen.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import '../core/services/auth_service.dart';
import '../core/services/cart_service.dart';

// Global stream controller for cart updates
class CartUpdateNotifier {
  static final StreamController<void> _cartUpdateController = StreamController<void>.broadcast();
  
  static Stream<void> get cartUpdateStream => _cartUpdateController.stream;
  
  static void notifyCartUpdate() {
    _cartUpdateController.add(null);
  }
  
  static void dispose() {
    _cartUpdateController.close();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Cart variables
  int _cartItemsCount = 0;
  final AuthService _authService = AuthService();
  StreamSubscription? _cartUpdateSubscription;
  
  // Banner carousel variables
  late PageController _bannerPageController;
  int _currentBannerIndex = 0;
  late Timer _bannerTimer;

  List<Map<String, dynamic>> get _banners => [
    {
      'title': 'عرض خاص!',
      'subtitle': 'خصم يصل إلى 50% على أحدث الهواتف',
      'description': 'اكتشف أفضل العروض والخصومات الحصرية',
      'buttonText': 'تسوق الآن',
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
      'icon': Icons.local_offer,
    },
    {
      'title': 'شحن مجاني!',
      'subtitle': 'شحن مجاني لجميع الطلبات فوق 500 ${AppLocalizations.of(context)!.jd}',
      'description': 'توصيل سريع وآمن لجميع أنحاء المملكة',
      'buttonText': 'اطلب الآن',
      'gradient': [Color(0xFF48BB78), Color(0xFF38A169), Color(0xFF2F855A)],
      'icon': Icons.local_shipping,
    },
    {
      'title': 'أحدث التقنيات',
      'subtitle': 'اكتشف أحدث الهواتف الذكية والتقنيات',
      'description': 'تقنيات متطورة وأداء متميز في كل جهاز',
      'buttonText': 'استكشف',
      'gradient': [Color(0xFFF56565), Color(0xFFE53E3E), Color(0xFFC53030)],
      'icon': Icons.phone_android,
    },
    {
      'title': 'ضمان شامل',
      'subtitle': 'ضمان شامل لمدة سنتين على جميع المنتجات',
      'description': 'خدمة عملاء متميزة ودعم فني متاح 24/7',
      'buttonText': 'اعرف المزيد',
      'gradient': [Color(0xFF9F7AEA), Color(0xFF805AD5), Color(0xFF6B46C1)],
      'icon': Icons.verified_user,
    },
  ];

  List<Map<String, dynamic>> get _phones => [
    {
      'name': 'iPhone 15 Pro Max',
      'price': '4,999 ${AppLocalizations.of(context)!.jd}',
      'image': '📱',
      'discount': '15%',
      'rating': 4.8,
    },
    {
      'name': 'Samsung Galaxy S24 Ultra',
      'price': '4,299 ${AppLocalizations.of(context)!.jd}',
      'image': '📱',
      'discount': '20%',
      'rating': 4.7,
    },
    {
      'name': 'Google Pixel 8 Pro',
      'price': '3,999 ${AppLocalizations.of(context)!.jd}',
      'image': '📱',
      'discount': '10%',
      'rating': 4.6,
    },
    {
      'name': 'OnePlus 12',
      'price': '2,999 ${AppLocalizations.of(context)!.jd}',
      'image': '📱',
      'discount': '25%',
      'rating': 4.5,
    },
  ];


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _bannerPageController = PageController();
    _startBannerTimer();
    
    _animationController.forward();
    _checkEmailVerification();
    
    // Load cart items count
    _loadCartItemsCount();
    
    // Listen for cart updates
    _cartUpdateSubscription = CartUpdateNotifier.cartUpdateStream.listen((_) {
      _loadCartItemsCount();
    });
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerPageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      final authService = AuthService();
      if (authService.isLoggedIn()) {
        final user = await authService.getUserInfo();
        
        if (mounted) {
          // التحقق من حالة تأكيد البريد الإلكتروني
          if (user.emailVerifiedAt == null || user.emailVerifiedAt!.isEmpty) {
            // البريد الإلكتروني غير مؤكد - الانتقال لصفحة OTP
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  email: user.email,
                  userId: user.id.toString(),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      // في حالة الخطأ، يمكن إما تجاهل الخطأ أو تسجيل الخروج
      print('Error checking email verification: $e');
    }
  }

  Future<void> _loadCartItemsCount() async {
    try {
      final cartResponse = await _authService.getCart();
      if (mounted) {
        setState(() {
          _cartItemsCount = cartResponse.totalItems;
        });
      }
    } catch (e) {
      print('Error loading cart items count: $e');
      // في حالة الخطأ، استخدم CartService كبديل
      try {
        final count = await CartService().getCartItemsCount();
        if (mounted) {
          setState(() {
            _cartItemsCount = count;
          });
        }
      } catch (e2) {
        print('Error loading cart from local storage: $e2');
      }
    }
  }

  // دالة عامة لتحديث عداد السلة (يمكن استدعاؤها من الخارج)
  Future<void> refreshCartCount() async {
    await _loadCartItemsCount();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerPageController.dispose();
    _bannerTimer.cancel();
    _cartUpdateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 3 
        ? const ProfileScreen() // صفحة Profile بدون header
        : _selectedIndex == 1
          ? const CategoriesScreen() // صفحة Categories بدون header
          : _selectedIndex == 2
            ? _buildFavoritesContent() // صفحة Favorites بدون header
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667eea),
                      Color(0xFF764ba2),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildAppBar(),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: _buildHomeContent(), // فقط محتوى Home
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      bottomNavigationBar: _buildBottomNavigationBar(), // navbar موجود دائماً
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ).animate().scale(
                  duration: 600.ms,
                  delay: 200.ms,
                  curve: Curves.elasticOut,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Welcome',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(
                      duration: 800.ms,
                    ),
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Discover the best phones',
                          textStyle: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'Search for phones...',
          hintStyle: GoogleFonts.cairo(
            color: const Color(0xFF718096),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF667eea),
          ),
          border: InputBorder.none,
        ),
      ),
    ).animate().slideY(
      duration: 600.ms,
      delay: 400.ms,
      begin: 0.3,
    );
  }


  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerSection(),
          const SizedBox(height: 30),
          _buildFeaturedPhonesSection(),
          const SizedBox(height: 30),
          _buildOffersSection(),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerPageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return _buildBannerCard(banner, index);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildBannerIndicators(),
      ],
    ).animate().fadeIn(
      duration: 800.ms,
      delay: 200.ms,
    ).slideY(
      duration: 600.ms,
      delay: 200.ms,
      begin: 0.3,
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> banner, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: banner['gradient'] as List<Color>,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (banner['gradient'] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        banner['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner['title'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner['subtitle'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        banner['description'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        banner['buttonText'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildBannerIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _banners.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentBannerIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentBannerIndex == index
                ? const Color(0xFF667eea)
                : const Color(0xFF667eea).withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedPhonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Phones',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2d3748),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(
          duration: 600.ms,
          delay: 400.ms,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _phones.length,
            itemBuilder: (context, index) {
              final phone = _phones[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Image
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667eea).withOpacity(0.1),
                            const Color(0xFF764ba2).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          phone['image'],
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                    
                    // Phone Details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phone['name'],
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2d3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                phone['rating'].toString(),
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: const Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                phone['price'],
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF667eea),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF48BB78),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  phone['discount'],
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(
                duration: 600.ms,
                delay: (500 + index * 100).ms,
                begin: 0.3,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Offers',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get up to 50% off on all phones',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Explore Offers',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(
      duration: 600.ms,
      delay: 800.ms,
      begin: 0.3,
    );
  }


  Widget _buildFavoritesContent() {
    return Center(
      child: Text(
        'Favorites',
        style: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2d3748),
        ),
      ),
    );
  }


  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // Cart tab - navigate to cart screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            ).then((_) {
              // Refresh cart count when returning from cart screen
              _loadCartItemsCount();
            });
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: const Color(0xFF718096),
        selectedLabelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w500,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.category_outlined),
            activeIcon: const Icon(Icons.category),
            label: AppLocalizations.of(context)!.categories,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (_cartItemsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _cartItemsCount > 99 ? '99+' : _cartItemsCount.toString(),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItemsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _cartItemsCount > 99 ? '99+' : _cartItemsCount.toString(),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: AppLocalizations.of(context)!.cart,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}
