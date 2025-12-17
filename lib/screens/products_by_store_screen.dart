import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../core/models/product_model.dart';
import '../core/models/store_model.dart' as store_model;
import '../core/services/products_by_store_service.dart';
import '../core/widgets/network_image_widget.dart';
import 'product_details_screen.dart';

// Separate widget for product image gallery
class _ProductImageGallery extends StatefulWidget {
  final ProductModel product;

  const _ProductImageGallery({required this.product});

  @override
  State<_ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<_ProductImageGallery> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // إذا لم تكن هناك صور، نعرض placeholder
    if (widget.product.allImages.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withOpacity(0.1),
              const Color(0xFF764ba2).withOpacity(0.1),
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.shopping_bag,
            size: 40,
            color: Color(0xFF667eea),
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        // PageView to display all images
        PageView.builder(
          controller: _pageController,
          itemCount: widget.product.allImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return SizedBox.expand(
              child: ProductImageWidget(
                imageUrl: widget.product.allImages[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
        
        // Image indicators (dots)
        if (widget.product.allImages.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.product.allImages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        
        // Image counter
        if (widget.product.allImages.length > 1)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${widget.product.allImages.length}',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        
        // Navigation arrows
        if (widget.product.allImages.length > 1) ...[
          // Left arrow
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          // Right arrow
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_currentImageIndex < widget.product.allImages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

}

class ProductsByStoreScreen extends StatefulWidget {
  final store_model.Store store;

  const ProductsByStoreScreen({
    super.key,
    required this.store,
  });

  @override
  State<ProductsByStoreScreen> createState() => _ProductsByStoreScreenState();
}

class _ProductsByStoreScreenState extends State<ProductsByStoreScreen> {
  final ProductsByStoreService _productsService = ProductsByStoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _lastPage = 1;
  String? _searchQuery;
  String? _selectedCategory;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';
  
  // للتحكم في تحميل المزيد من المنتجات
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // التحقق من أن الـ scroll controller جاهز
    if (!_scrollController.hasClients) return;
    
    // التحقق من أن المستخدم قريب من النهاية
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // إذا لم يكن هناك محتوى للتمرير، لا نفعل شيء
    if (maxScroll <= 0) return;
    
    // تحميل عند 500 بكسل قبل النهاية (تحميل أبكر)
    final threshold = maxScroll - 500;
    
    // تحميل مباشر بدون debounce إذا كان قريب من النهاية
    if (currentScroll >= threshold && !_hasReachedEnd) {
      // تحميل فوري بدون انتظار
      if (mounted && 
          _scrollController.hasClients &&
          !_isLoadingMore && 
          _currentPage < _lastPage) {
        _loadMoreProducts();
      }
    }
    
    // إعادة تعيين _hasReachedEnd إذا عاد المستخدم للأعلى
    if (currentScroll < maxScroll - 600) {
      _hasReachedEnd = false;
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    try {
      setState(() {
        if (refresh) {
          _isLoading = true;
          _currentPage = 1;
          _products.clear();
          _hasReachedEnd = false; // إعادة تعيين عند التحديث
        } else {
          _isLoading = true;
        }
        _errorMessage = '';
      });

      // Check if user is authenticated
      if (!_authService.isLoggedIn()) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.pleaseLoginToViewProducts;
        });
        return;
      }

      final response = await _productsService.getProductsByStore(
        storeId: widget.store.id,
        page: _currentPage,
        search: _searchQuery,
        categoryId: _selectedCategory,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      
      if (mounted) {
        // طباعة للتشخيص
        print('Loading products - Page: $_currentPage');
        print('  - Received ${response.products.length} products');
        print('  - Per page: ${response.perPage}');
        print('  - Total products: ${response.total}');
        print('  - Last page: ${response.lastPage}');
        
        setState(() {
          if (refresh) {
            _products = response.products;
            print('  - Total products after refresh: ${_products.length}');
          } else {
            final beforeCount = _products.length;
            _products.addAll(response.products);
            print('  - Products before: $beforeCount, after: ${_products.length}');
          }
          _lastPage = response.lastPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          String errorMsg = e.toString();
          if (errorMsg.contains('FormatException')) {
            _errorMessage = 'خطأ في تنسيق البيانات. يرجى المحاولة مرة أخرى.';
          } else if (errorMsg.contains('Invalid data format')) {
            _errorMessage = 'تنسيق البيانات غير صحيح. يرجى المحاولة مرة أخرى.';
          } else if (errorMsg.contains('Authentication failed') || errorMsg.contains('User not authenticated')) {
            _errorMessage = AppLocalizations.of(context)!.pleaseLoginToViewProducts;
          } else if (errorMsg.contains('Failed to load products')) {
            _errorMessage = 'فشل في تحميل المنتجات. يرجى المحاولة مرة أخرى.';
          } else {
            _errorMessage = errorMsg.replaceAll('Exception: ', '');
          }
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    // منع تحميل مزدوج
    if (_isLoadingMore || _currentPage >= _lastPage) {
      return;
    }

    try {
      // تعيين flag فوراً لمنع تحميل مزدوج
      _hasReachedEnd = true;
      
      setState(() {
        _isLoadingMore = true;
      });

      _currentPage++;
      final response = await _productsService.getProductsByStore(
        storeId: widget.store.id,
        page: _currentPage,
        search: _searchQuery,
        categoryId: _selectedCategory,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
      
      if (mounted) {
        setState(() {
          _products.addAll(response.products);
          _lastPage = response.lastPage; // تحديث lastPage
          _isLoadingMore = false;
          
          // إعادة تعيين _hasReachedEnd بعد اكتمال التحميل مباشرة
          _hasReachedEnd = false;
          
          // إذا لم يعد هناك صفحات إضافية
          if (_currentPage >= response.lastPage) {
            _hasReachedEnd = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--; // Revert page increment on error
          _hasReachedEnd = false; // السماح بالمحاولة مرة أخرى
        });
      }
    }
  }

  void _searchProducts() {
    setState(() {
      _searchQuery = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
      _currentPage = 1;
      _hasReachedEnd = false; // إعادة تعيين عند البحث
    });
    _loadProducts(refresh: true);
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSortOptions(),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.sortBy,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildSortOption('created_at', AppLocalizations.of(context)!.newest),
          _buildSortOption('price_asc', AppLocalizations.of(context)!.priceLowToHigh),
          _buildSortOption('price_desc', AppLocalizations.of(context)!.priceHighToLow),
          _buildSortOption('name_asc', AppLocalizations.of(context)!.nameAtoZ),
          _buildSortOption('name_desc', AppLocalizations.of(context)!.nameZtoA),
        ],
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    final isSelected = _sortBy == value;
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.cairo(
          color: isSelected ? const Color(0xFF667eea) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF667eea)) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
          _sortOrder = value.contains('_desc') ? 'desc' : 'asc';
        });
        Navigator.pop(context);
        _loadProducts(refresh: true);
      },
    );
  }

  // Calculate discount percentage
  String _getDiscountPercentage(ProductModel product) {
    final originalPrice = double.tryParse(product.price) ?? 0.0;
    final discountValue = double.tryParse(product.discount) ?? 0.0;
    
    if (originalPrice == 0) return '0';
    
    // If discount is greater than 1, it's a percentage
    if (discountValue > 1) {
      return discountValue.toStringAsFixed(0);
    } else {
      // If discount is less than or equal to 1, calculate percentage
      final percentage = (discountValue / originalPrice) * 100;
      return percentage.toStringAsFixed(0);
    }
  }

  Widget _buildProductCard(ProductModel product, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: product.id,
            ),
          ),
        );
      },
      child: Container(
        height: 280,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.1),
                      const Color(0xFF764ba2).withOpacity(0.1),
                    ],
                  ),
                ),
                child: _buildProductImage(product),
              ),
            ),
            
            // Product Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      Localizations.localeOf(context).languageCode == 'ar' 
                          ? product.nameAr 
                          : product.nameEn,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2d3748),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Price and Discount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.hasDiscount) ...[
                          // Price after discount
                          Text(
                            '${product.finalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Original price and discount percentage in one row
                          Row(
                            children: [
                              // Original price
                              Text(
                                '${double.parse(product.price).toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Discount percentage
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${AppLocalizations.of(context)!.discount} ${_getDiscountPercentage(product)}%',
                                  style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else
                          Text(
                            '${product.finalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667eea),
                            ),
                          ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Stock and Badges
                    Row(
                      children: [
                        if (product.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.newProduct,
                              style: GoogleFonts.cairo(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (product.isBestSeller) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.bestSeller,
                              style: GoogleFonts.cairo(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${AppLocalizations.of(context)!.stock}: ${product.stock}',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: product.isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildProductImage(ProductModel product) {
    // طباعة للتشخيص
    print('_buildProductImage - Product ID: ${product.id}');
    print('  - hasImages: ${product.hasImages}');
    print('  - productImages.length: ${product.productImages.length}');
    print('  - allImages.length: ${product.allImages.length}');
    if (product.allImages.isNotEmpty) {
      print('  - allImages[0]: ${product.allImages[0]}');
    }
    
    // Check if product has images
    if (product.hasImages && product.allImages.isNotEmpty) {
      print('  - Returning _buildProductImageGallery');
      return _buildProductImageGallery(product);
    }
    
    // Show default icon if no images
    print('  - Returning _buildDefaultProductIcon');
    return _buildDefaultProductIcon();
  }

  Widget _buildProductImageGallery(ProductModel product) {
    return _ProductImageGallery(product: product);
  }

  Widget _buildDefaultProductIcon() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea).withOpacity(0.2),
            const Color(0xFF764ba2).withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 40,
              color: const Color(0xFF667eea),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.product,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF667eea),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreCard() {
    return GestureDetector(
      onTap: _loadMoreProducts,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF667eea).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoadingMore)
              const CircularProgressIndicator(
                color: Color(0xFF667eea),
                strokeWidth: 2,
              )
            else
              Icon(
                Icons.refresh,
                color: const Color(0xFF667eea),
                size: 32,
              ),
            const SizedBox(height: 8),
            Text(
              _isLoadingMore ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.loadMore,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667eea),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Directionality.of(context) == TextDirection.rtl 
                              ? Icons.arrow_forward 
                              : Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.store.name,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_products.isNotEmpty)
                            Text(
                              '${_products.length} ${AppLocalizations.of(context)!.product}',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    
                    IconButton(
                      onPressed: _showSortOptions,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.sort,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    onSubmitted: (value) => _searchProducts(),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchProducts,
                      hintStyle: GoogleFonts.cairo(
                        color: Colors.grey[600],
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF667eea),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _searchProducts();
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : IconButton(
                              onPressed: _searchProducts,
                              icon: const Icon(Icons.search),
                            ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF667eea),
                          ),
                        )
                      : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage.isNotEmpty && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadProducts(refresh: true),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noProductsFound,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tryAdjustingSearch,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.60,
        ),
        itemCount: _products.length + (_currentPage < _lastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length && _currentPage < _lastPage) {
            return _buildLoadMoreCard();
          }
          final product = _products[index];
          return _buildProductCard(product, index);
        },
      ),
    );
  }
}