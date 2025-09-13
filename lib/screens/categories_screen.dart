import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../core/models/category_model.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with TickerProviderStateMixin {
  List<CategoryModel> _categories = [];
  List<CategoryModel> _parentCategories = [];
  List<CategoryModel> _subCategories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasNextPage = false;
  int? _selectedParentId;
  String _selectedParentName = '';
  
  // متغيرات منفصلة للفئات الفرعية
  int _subCategoriesCurrentPage = 1;
  bool _subCategoriesHasNextPage = false;
  bool _subCategoriesLoadingMore = false;
  
  // متغيرات للتحكم في timeout الصور
  final Map<String, Timer> _imageTimers = {};
  final Map<String, bool> _imageLoadStates = {};
  
  // متغيرات لتخزين عدد المنتجات للفئات الفرعية
  final Map<int, int> _subCategoriesProductsCount = {};
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadCategories();
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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _loadCategories({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        setState(() {
          _currentPage = 1;
          _categories.clear();
          _parentCategories.clear();
        });
      }
      
      print('Loading categories - Page: $_currentPage, isRefresh: $isRefresh');
      
      final authService = AuthService();
      final response = await authService.getCategories(page: _currentPage);
      
      print('Response received - Categories count: ${response.categories.length}');
      print('Has next page: ${response.hasNextPage}');
      print('Current page: ${response.currentPage}, Last page: ${response.lastPage}');
      
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _categories = response.categories;
            _parentCategories = response.parentCategories;
          } else {
            // إضافة الفئات الجديدة فقط (تجنب التكرار)
            for (final category in response.categories) {
              if (!_categories.any((existing) => existing.id == category.id)) {
                _categories.add(category);
              }
            }
            // تحديث الفئات الرئيسية
            _parentCategories = _categories.where((category) => category.isParent).toList();
          }
          _hasNextPage = response.hasNextPage;
          _isLoading = false;
          _isLoadingMore = false;
        });
        
        print('Total categories after load: ${_categories.length}');
        print('Total parent categories after load: ${_parentCategories.length}');
        print('Has next page: $_hasNextPage');
        
        if (_currentPage == 1) {
          _animationController.forward();
        }
      }
    } catch (e) {
      print('Error loading categories: $e');
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

  Future<void> _loadMoreCategories() async {
    print('Load more called - isLoadingMore: $_isLoadingMore, hasNextPage: $_hasNextPage');
    
    if (_isLoadingMore || !_hasNextPage) {
      print('Load more cancelled - isLoadingMore: $_isLoadingMore, hasNextPage: $_hasNextPage');
      return;
    }
    
    print('Starting load more - current page: $_currentPage');
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // زيادة رقم الصفحة قبل التحميل
    _currentPage++;
    print('Page incremented to: $_currentPage');
    
    await _loadCategories();
  }

  Future<void> _loadMoreSubCategories() async {
    print('Load more subcategories called - isLoadingMore: $_subCategoriesLoadingMore, hasNextPage: $_subCategoriesHasNextPage');
    
    if (_subCategoriesLoadingMore || !_subCategoriesHasNextPage) {
      print('Load more subcategories cancelled');
      return;
    }
    
    print('Starting load more subcategories - current page: $_subCategoriesCurrentPage');
    
    setState(() {
      _subCategoriesLoadingMore = true;
    });
    
    // زيادة رقم الصفحة قبل التحميل
    _subCategoriesCurrentPage++;
    print('Subcategories page incremented to: $_subCategoriesCurrentPage');
    
    await _loadSubCategories();
  }

  Future<void> _loadSubCategories({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        setState(() {
          _subCategoriesCurrentPage = 1;
          _subCategories.clear();
        });
      }
      
      print('Loading subcategories - Page: $_subCategoriesCurrentPage, Parent ID: $_selectedParentId');
      
      final authService = AuthService();
      final response = await authService.getCategories(page: _subCategoriesCurrentPage);
      
      // تصفية الفئات الفرعية فقط
      final subCategoriesFromResponse = response.categories
          .where((category) => category.parentId == _selectedParentId)
          .toList();
      
      print('Subcategories response - Count: ${subCategoriesFromResponse.length}');
      print('Has next page: ${response.hasNextPage}');
      
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _subCategories = subCategoriesFromResponse;
          } else {
            // إضافة الفئات الفرعية الجديدة فقط
            for (final category in subCategoriesFromResponse) {
              if (!_subCategories.any((existing) => existing.id == category.id)) {
                _subCategories.add(category);
              }
            }
          }
          _subCategoriesHasNextPage = response.hasNextPage;
          _subCategoriesLoadingMore = false;
        });
        
        // جلب عدد المنتجات لكل فئة فرعية
        _loadProductsCountForSubCategories(subCategoriesFromResponse);
        
        print('Total subcategories after load: ${_subCategories.length}');
        print('Subcategories has next page: $_subCategoriesHasNextPage');
      }
    } catch (e) {
      print('Error loading subcategories: $e');
      if (mounted) {
        setState(() {
          _subCategoriesLoadingMore = false;
        });
        _showSnackBar(
          e.toString().replaceFirst('Exception: ', '').replaceFirst('Exception:', ''),
          Colors.red,
        );
      }
    }
  }

  void _onScroll() {
    final pixels = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final threshold = maxExtent - 200;
    
    print('Scroll position: $pixels, Max extent: $maxExtent, Threshold: $threshold');
    
    if (pixels >= threshold) {
      print('Scroll threshold reached, calling load more');
      _loadMoreCategories();
    }
  }

  void _showSubCategories(int parentId, String parentName) {
    setState(() {
      _selectedParentId = parentId;
      _selectedParentName = parentName;
      _subCategories = _categories.where((category) => category.parentId == parentId).toList();
      // إعادة تعيين pagination للفئات الفرعية
      _subCategoriesCurrentPage = 1;
      _subCategoriesHasNextPage = false;
    });
    
    // تحميل الفئات الفرعية مع pagination
    _loadSubCategories(isRefresh: true);
  }

  void _goBackToParentCategories() {
    setState(() {
      _selectedParentId = null;
      _selectedParentName = '';
      _subCategories = [];
      // إعادة تعيين pagination للفئات الفرعية
      _subCategoriesCurrentPage = 1;
      _subCategoriesHasNextPage = false;
      _subCategoriesLoadingMore = false;
      // تنظيف بيانات عدد المنتجات
      _subCategoriesProductsCount.clear();
    });
  }

  int _getSubCategoriesCount(int parentId) {
    return _categories.where((category) => category.parentId == parentId).length;
  }

  bool _shouldShowLoadMore() {
    if (_selectedParentId != null) {
      // للفئات الفرعية
      return _subCategoriesHasNextPage;
    } else {
      // للفئات الرئيسية
      return _hasNextPage;
    }
  }

  Widget _buildLoadMoreCard() {
    final isSubCategories = _selectedParentId != null;
    final isLoading = isSubCategories ? _subCategoriesLoadingMore : _isLoadingMore;
    
    return GestureDetector(
      onTap: () {
        print('Load More card tapped - isSubCategories: $isSubCategories');
        if (isSubCategories) {
          _loadMoreSubCategories();
        } else {
          _loadMoreCategories();
        }
      },
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
            if (isLoading)
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
              isLoading ? 'Loading...' : 'Load More',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF667eea),
            strokeWidth: 2,
          ),
          const SizedBox(height: 8),
          Text(
            'Loading...',
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: const Color(0xFF667eea),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithTimeout(String imageUrl, CategoryModel category) {
    return StatefulBuilder(
      builder: (context, setState) {
        // إضافة timeout للصورة
        _startImageTimeout(imageUrl, category);
        
        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) {
            // timeout أقصر للفئات الفرعية
            final timeoutDuration = _selectedParentId != null 
                ? const Duration(seconds: 3) 
                : const Duration(seconds: 5);
            
            return FutureBuilder<bool>(
              future: Future.delayed(timeoutDuration, () => true),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  print('Image timeout reached for ${category.nameAr}');
                  return _buildDefaultIcon(category);
                }
                return _buildImagePlaceholder();
              },
            );
          },
          errorWidget: (context, url, error) {
            print('Image load error for ${category.nameAr}: $error');
            _cancelImageTimeout(imageUrl);
            return _buildDefaultIcon(category);
          },
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 100),
          memCacheWidth: 200,
          memCacheHeight: 200,
          maxWidthDiskCache: 300,
          maxHeightDiskCache: 300,
          httpHeaders: const {
            'Cache-Control': 'max-age=3600',
          },
          imageBuilder: (context, imageProvider) {
            _cancelImageTimeout(imageUrl);
            return Image(
              image: imageProvider,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                print('Image builder error for ${category.nameAr}: $error');
                return _buildDefaultIcon(category);
              },
            );
          },
        );
      },
    );
  }

  void _startImageTimeout(String imageUrl, CategoryModel category) {
    // إلغاء الـ timer السابق إذا كان موجود
    _cancelImageTimeout(imageUrl);
    
    // timeout أقصر للفئات الفرعية
    final timeoutDuration = _selectedParentId != null 
        ? const Duration(seconds: 6) 
        : const Duration(seconds: 8);
    
    // بدء timer جديد
    _imageTimers[imageUrl] = Timer(timeoutDuration, () {
      print('Image timeout for ${category.nameAr} (${_selectedParentId != null ? 'Subcategory' : 'Category'})');
      if (mounted) {
        setState(() {
          _imageLoadStates[imageUrl] = false;
        });
      }
    });
  }

  void _cancelImageTimeout(String imageUrl) {
    _imageTimers[imageUrl]?.cancel();
    _imageTimers.remove(imageUrl);
  }

  Future<void> _loadProductsCountForSubCategories(List<CategoryModel> subCategories) async {
    final authService = AuthService();
    
    for (final category in subCategories) {
      try {
        final productsCount = await authService.getProductsCountByCategory(category.id);
        if (mounted) {
          setState(() {
            _subCategoriesProductsCount[category.id] = productsCount;
          });
        }
        print('Products count for ${category.nameAr}: $productsCount');
      } catch (e) {
        print('Error loading products count for ${category.nameAr}: $e');
        if (mounted) {
          setState(() {
            _subCategoriesProductsCount[category.id] = 0;
          });
        }
      }
    }
  }

  Widget _buildSubCategoryImage(String imageUrl, CategoryModel category) {
    return StatefulBuilder(
      builder: (context, setState) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) {
            // timeout أقصر للفئات الفرعية
            return FutureBuilder<bool>(
              future: Future.delayed(const Duration(seconds: 3), () => true),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  print('Subcategory image timeout for ${category.nameAr}');
                  return _buildDefaultIcon(category);
                }
                return _buildImagePlaceholder();
              },
            );
          },
          errorWidget: (context, url, error) {
            print('Subcategory image load error for ${category.nameAr}: $error');
            return _buildDefaultIcon(category);
          },
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          memCacheWidth: 150,
          memCacheHeight: 150,
          maxWidthDiskCache: 200,
          maxHeightDiskCache: 200,
          httpHeaders: const {
            'Cache-Control': 'max-age=1800', // cache أقصر للفئات الفرعية
          },
        );
      },
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    
    // تنظيف جميع الـ timers
    for (final timer in _imageTimers.values) {
      timer.cancel();
    }
    _imageTimers.clear();
    _imageLoadStates.clear();
    
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
                    if (_selectedParentId != null)
                      IconButton(
                        onPressed: _goBackToParentCategories,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    
                    Expanded(
                      child: Text(
                        _selectedParentId != null ? _selectedParentName : AppLocalizations.of(context)!.categories,
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
              ).animate().fadeIn(
                duration: 600.ms,
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
    final categoriesToShow = _selectedParentId != null ? _subCategories : _parentCategories;
    
    if (categoriesToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedParentId != null 
                  ? 'No subcategories found'
                  : 'No categories found',
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: categoriesToShow.length + (_shouldShowLoadMore() ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == categoriesToShow.length && _shouldShowLoadMore()) {
                return _buildLoadMoreCard();
              }
              final category = categoriesToShow[index];
              return _buildCategoryCard(category, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, int index) {
    return GestureDetector(
      onTap: () {
        if (category.isParent) {
          _showSubCategories(category.id, category.nameAr);
        } else {
          // فتح صفحة المنتجات عند الضغط على الفئة الفرعية
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsScreen(
                categoryId: category.id,
                categoryName: category.nameAr,
              ),
            ),
          );
        }
      },
      child: Container(
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
            // Image
            Expanded(
              flex: 3,
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
                child: category.image != null && category.image!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: _selectedParentId != null 
                            ? _buildSubCategoryImage(category.image!, category)
                            : _buildImageWithTimeout(category.image!, category),
                      )
                    : _buildDefaultIcon(category),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${category.nameAr} / ${category.nameEn}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2d3748),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    if (category.isParent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: const Color(0xFF667eea),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${AppLocalizations.of(context)!.subcategories} (${_getSubCategoriesCount(category.id)})',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: const Color(0xFF667eea),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      // عرض عدد المنتجات للفئات الفرعية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            size: 12,
                            color: const Color(0xFF667eea),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_subCategoriesProductsCount[category.id] ?? 0} ${AppLocalizations.of(context)!.product}',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: const Color(0xFF667eea),
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
      ).animate().scale(
        duration: 600.ms,
        delay: (index * 100).ms,
        curve: Curves.elasticOut,
      ),
    );
  }

  Widget _buildDefaultIcon(CategoryModel category) {
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
        child: Icon(
          category.isParent ? Icons.category : Icons.label,
          size: 40,
          color: const Color(0xFF667eea),
        ),
      ),
    );
  }
}
