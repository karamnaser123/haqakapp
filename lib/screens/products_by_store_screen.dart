import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../core/models/product_model.dart';
import '../core/models/store_model.dart' as store_model;
import '../core/services/products_by_store_service.dart';
import '../core/services/auth_service.dart';
import 'product_details_screen.dart';

class ProductsByStoreScreen extends StatefulWidget {
  final store_model.Store store;

  const ProductsByStoreScreen({
    super.key,
    required this.store,
  });

  @override
  State<ProductsByStoreScreen> createState() => _ProductsByStoreScreenState();
}

class _ProductsByStoreScreenState extends State<ProductsByStoreScreen> with TickerProviderStateMixin {
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
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    
    _scrollController.addListener(_onScroll);
    _loadProducts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _lastPage) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    try {
      setState(() {
        if (refresh) {
          _isLoading = true;
          _currentPage = 1;
          _products.clear();
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
        setState(() {
          if (refresh) {
            _products = response.products;
          } else {
            _products.addAll(response.products);
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
          } else if (errorMsg.contains('Authentication failed')) {
            _errorMessage = AppLocalizations.of(context)!.pleaseLoginToViewProducts;
          } else {
            _errorMessage = errorMsg.replaceAll('Exception: ', '');
          }
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    try {
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
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--; // Revert page increment on error
        });
      }
    }
  }

  void _searchProducts() {
    setState(() {
      _searchQuery = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
      _currentPage = 1;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.store.name,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2d3748),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: const Icon(Icons.sort, color: Color(0xFF667eea)),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadProducts(refresh: true),
                  child: _buildProductsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
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
    ).animate().slideY(
      duration: 600.ms,
      delay: 200.ms,
      begin: 0.3,
    );
  }

  Widget _buildProductsList() {
    if (_isLoading && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.loading,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

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

    return Column(
      children: [
        // Pagination info
        if (_products.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.page} $_currentPage ${AppLocalizations.of(context)!.off} $_lastPage',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${_products.length} ${AppLocalizations.of(context)!.products}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        // Products Grid
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _products.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _products.length) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                );
              }
              final product = _products[index];
              return _buildProductCard(product, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToProductDetails(product),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: product.hasImages
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product.firstImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 40,
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                // Product Name
                Expanded(
                  flex: 2,
                  child: Text(
                    product.nameAr.isNotEmpty ? product.nameAr : product.nameEn,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2d3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                // Price
                Row(
                  children: [
                    Text(
                      '${product.price} ${AppLocalizations.of(context)!.jd}',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF667eea),
                      ),
                    ),
                    if (product.discount != '0.00' && product.discount != product.price) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${product.discount} ${AppLocalizations.of(context)!.jd}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Badges
                Row(
                  children: [
                    if (product.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
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
                    if (product.isNew && product.isBestSeller) const SizedBox(width: 4),
                    if (product.isBestSeller)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
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
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(
      duration: 600.ms,
      delay: (300 + index * 100).ms,
      begin: 0.3,
    );
  }

  void _navigateToProductDetails(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(productId: product.id),
      ),
    );
  }
}
