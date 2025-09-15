import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../core/services/cart_service.dart';
import '../core/models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with TickerProviderStateMixin {
  ProductDetails? _productDetails;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  int _selectedQuantity = 1;
  bool _isAddingToCart = false;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
    _loadProductDetails();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadProductDetails() async {
    try {
      print('Loading product details for ID: ${widget.productId}');
      
      final authService = AuthService();
      final productDetails = await authService.getProductDetails(widget.productId);
      
      if (mounted) {
        setState(() {
          _productDetails = productDetails;
          _isLoading = false;
        });
        
        _animationController.forward();
      }
    } catch (e) {
      print('Error loading product details: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception:', ''),
          Colors.red,
        );
      }
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

  Future<void> _addToCart() async {
    if (_productDetails == null) return;
    
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartService = CartService();
      final success = await cartService.addToCart(
        _productDetails!.product,
        quantity: _selectedQuantity,
      );

      if (mounted) {
        if (success) {
          _showSnackBar(
           AppLocalizations.of(context)!.addedToCart,
            Colors.green,
          );
        } else {
          _showSnackBar(
            AppLocalizations.of(context)!.failedToAddToCart,
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('DIFFERENT_STORE')) {
          _showDifferentStoreDialog();
        } else {
          _showSnackBar(
            AppLocalizations.of(context)!.error + ': ${e.toString()}',
            Colors.red,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  void _showDifferentStoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.store,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.differentStoreWarning,
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: GoogleFonts.cairo(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _addToCartWithClear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
              child: Text(
                AppLocalizations.of(context)!.clearCartAndAdd,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addToCartWithClear() async {
    if (_productDetails == null) return;
    
    setState(() {
      _isAddingToCart = true;
    });

    try {
      final cartService = CartService();
      final success = await cartService.addToCartWithClear(
        _productDetails!.product,
        quantity: _selectedQuantity,
      );

      if (mounted) {
        if (success) {
          _showSnackBar(
            AppLocalizations.of(context)!.addedToCart,
            Colors.green,
          );
        } else {
          _showSnackBar(
            AppLocalizations.of(context)!.failedToAddToCart,
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context)!.error + ': ${e.toString()}',
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_productDetails == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.productNotFound,
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        _buildHeader(),
        
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildProductContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
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
            child: Text(
              AppLocalizations.of(context)!.productDetails,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: 48),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildProductContent() {
    final product = _productDetails!.product;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Images
          _buildProductImages(),
          
          // Product Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' 
                      ? product.nameAr 
                      : product.nameEn,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2d3748),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Price
                _buildPriceSection(),
                const SizedBox(height: 20),
                
                // Category
                if (_productDetails!.category != null) _buildCategorySection(),
                
                // Description
                _buildDescriptionSection(),
                const SizedBox(height: 20),
                
                // Product Features
                _buildFeaturesSection(),
                const SizedBox(height: 20),
                
                // Stock Info
                _buildStockSection(),
                const SizedBox(height: 20),
                
                // Quantity Selector
                _buildQuantitySelector(),
                const SizedBox(height: 20),
                
                // Add to Cart Button
                _buildAddToCartButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImages() {
    final product = _productDetails!.product;
    
    if (!product.hasImages) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noProductImages,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 400,
      child: Stack(
        children: [
          // PageView for images
          PageView.builder(
            controller: _pageController,
            itemCount: product.allImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: product.allImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) {
                  print('Product image load error: $error');
                  return _buildDefaultImage();
                },
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 100),
                memCacheWidth: 400,
                memCacheHeight: 400,
                maxWidthDiskCache: 600,
                maxHeightDiskCache: 600,
                httpHeaders: const {
                  'Cache-Control': 'max-age=3600',
                },
              );
            },
          ),
          
          // Image indicators
          if (product.allImages.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  product.allImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
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
          if (product.allImages.length > 1)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${product.allImages.length}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
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

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.imageNotAvailable,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final product = _productDetails!.product;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF667eea).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF667eea).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_money,
            color: const Color(0xFF667eea),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.price,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (product.hasDiscount) ...[
                  Text(
                    '${product.finalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF667eea),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.of(context)!.originalPrice}: ${double.parse(product.price).toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ] else
                  Text(
                    '${product.finalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF667eea),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final category = _productDetails!.category!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.category,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' 
                      ? category.nameAr 
                      : category.nameEn,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2d3748),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final product = _productDetails!.product;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.description,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2d3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Localizations.localeOf(context).languageCode == 'ar' 
                ? (product.descriptionAr.isNotEmpty ? product.descriptionAr : product.descriptionEn)
                : (product.descriptionEn.isNotEmpty ? product.descriptionEn : product.descriptionAr),
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final product = _productDetails!.product;
    final features = <Widget>[];
    
    if (product.isNew) {
      features.add(_buildFeatureChip(AppLocalizations.of(context)!.newProduct, Colors.green));
    }
    if (product.isBestSeller) {
      features.add(_buildFeatureChip(AppLocalizations.of(context)!.bestSeller, Colors.orange));
    }
    if (product.isTopRated) {
      features.add(_buildFeatureChip(AppLocalizations.of(context)!.topRated, Colors.blue));
    }
    if (product.isFeatured) {
      features.add(_buildFeatureChip(AppLocalizations.of(context)!.featured, Colors.purple));
    }
    
    if (features.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.features,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2d3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStockSection() {
    final product = _productDetails!.product;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: product.isAvailable 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: product.isAvailable 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory,
            color: product.isAvailable ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.stock,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.isAvailable 
                      ? '${AppLocalizations.of(context)!.available} (${product.stock} ${AppLocalizations.of(context)!.pieces})'
                      : AppLocalizations.of(context)!.unavailable,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: product.isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    final product = _productDetails!.product;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '${AppLocalizations.of(context)!.quantity}:',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2d3748),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _selectedQuantity > 1 
                      ? () => setState(() => _selectedQuantity--)
                      : null,
                  icon: Icon(
                    Icons.remove,
                    color: _selectedQuantity > 1 ? Colors.grey[700] : Colors.grey[400],
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    _selectedQuantity.toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2d3748),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _selectedQuantity < product.stock 
                      ? () => setState(() => _selectedQuantity++)
                      : null,
                  icon: Icon(
                    Icons.add,
                    color: _selectedQuantity < product.stock ? Colors.grey[700] : Colors.grey[400],
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    final product = _productDetails!.product;
    
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (product.isAvailable && !_isAddingToCart) ? _addToCart : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: product.isAvailable 
              ? const Color(0xFF667eea)
              : Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF667eea).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isAddingToCart
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.addingToCart,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    product.isAvailable ? Icons.shopping_cart : Icons.shopping_cart_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    product.isAvailable 
                        ? '${AppLocalizations.of(context)!.addToCart} (${_selectedQuantity})'
                        : AppLocalizations.of(context)!.outOfStock,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0);
  }

}