import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../core/models/product_model.dart';
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

  Widget _buildImagePlaceholder() {
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
        child: CircularProgressIndicator(
          color: Color(0xFF667eea),
          strokeWidth: 2,
        ),
      ),
    );
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
}

class ProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasNextPage = false;
  int _productsCount = 0;
  
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  Future<void> _loadProducts({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        setState(() {
          _currentPage = 1;
          _products.clear();
        });
      }
      
      print('Loading products - Page: $_currentPage, Category ID: ${widget.categoryId}');
      
      final authService = AuthService();
      await authService.initialize(); // التأكد من تحميل الـ token
      final response = await authService.getProductsByCategory(
        categoryId: widget.categoryId,
        page: _currentPage,
      );
      
      print('Products response - Count: ${response.products.length}');
      print('Has next page: ${response.hasNextPage}');
      
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _products = response.products;
            _productsCount = response.productsCount;
          } else {
            // Add new products only (avoid duplicates)
            for (final product in response.products) {
              if (!_products.any((existing) => existing.id == product.id)) {
                _products.add(product);
              }
            }
          }
          _hasNextPage = response.hasNextPage;
          _isLoading = false;
          _isLoadingMore = false;
        });
        
        print('Total products after load: ${_products.length}');
        print('Products count from API: $_productsCount');
        print('Has next page: $_hasNextPage');
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception:', ''),
          Colors.red,
        );
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    print('Load more called - isLoadingMore: $_isLoadingMore, hasNextPage: $_hasNextPage');
    
    if (_isLoadingMore || !_hasNextPage) {
      print('Load more cancelled - isLoadingMore: $_isLoadingMore, hasNextPage: $_hasNextPage');
      return;
    }
    
    print('Starting load more - current page: $_currentPage');
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Increment page number before loading
    _currentPage++;
    print('Page incremented to: $_currentPage');
    
    await _loadProducts();
  }

  void _onScroll() {
    final pixels = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final threshold = maxExtent - 200;
    
    print('Scroll position: $pixels, Max extent: $maxExtent, Threshold: $threshold');
    
    if (pixels >= threshold) {
      print('Scroll threshold reached, calling load more');
      _loadMoreProducts();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Store Info - At the top inside the card
            if (product.store != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF667eea).withOpacity(0.08),
                      const Color(0xFF764ba2).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    // Store Icon
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: StoreImageWidget(
                          imageUrl: product.store!.image,
                          fit: BoxFit.cover,
                          width: 20,
                          height: 20,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Store Name
                    Expanded(
                      child: Text(
                        product.store!.name,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2d3748),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Cashback Rate
                    if (product.store!.cashbackRate > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer,
                              size: 10,
                              color: const Color(0xFF667eea),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${product.store!.cashbackRate}%',
                              style: GoogleFonts.cairo(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            
            // Product Image
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: product.store != null
                    ? BorderRadius.zero
                    : const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF667eea).withOpacity(0.05),
                        const Color(0xFF764ba2).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: _buildProductImage(product),
                ),
              ),
            ),
            
            // Product Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      Localizations.localeOf(context).languageCode == 'ar' 
                          ? product.nameAr 
                          : product.nameEn,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2d3748),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Price and Discount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.hasDiscount) ...[
                          // Price after discount
                          Text(
                            '${product.finalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF667eea),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Original price and discount percentage
                          Row(
                            children: [
                              // Original price
                              Text(
                                '${double.parse(product.price).toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Discount percentage
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${AppLocalizations.of(context)!.discount} ${_getDiscountPercentage(product)}%',
                                  style: GoogleFonts.cairo(
                                    fontSize: 8,
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
                              fontSize: 15,
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
                        // Badges
                        Wrap(
                          spacing: 4,
                          children: [
                            if (product.isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.newProduct,
                                  style: GoogleFonts.cairo(
                                    fontSize: 7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (product.isBestSeller)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.bestSeller,
                                  style: GoogleFonts.cairo(
                                    fontSize: 7,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        // Stock
                        Text(
                          '${AppLocalizations.of(context)!.stock}: ${product.stock}',
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: product.isAvailable ? Colors.green[700] : Colors.red[700],
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
    // Check if product has images
    if (product.hasImages && product.allImages.isNotEmpty) {
      return _buildProductImageGallery(product);
    }
    
    // Show default icon if no images
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                            widget.categoryName,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_productsCount > 0)
                            Text(
                              '$_productsCount ${AppLocalizations.of(context)!.product}',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 48),
                  ],
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
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noProductsInThisCategory,
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_productsCount == 0)
              Text(
                '${AppLocalizations.of(context)!.productsCount}: 0',
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
        itemCount: _products.length + (_hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length && _hasNextPage) {
            return _buildLoadMoreCard();
          }
          final product = _products[index];
          return _buildProductCard(product, index);
        },
      ),
    );
  }
}
