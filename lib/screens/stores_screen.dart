import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../core/models/store_model.dart';
import '../core/services/stores_service.dart';
import '../core/services/auth_service.dart';
import '../utils/maps_launcher.dart';
import 'products_by_store_screen.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> with TickerProviderStateMixin {
  final StoresService _storesService = StoresService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Store> _stores = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _lastPage = 1;
  String? _searchQuery;
  
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
    _loadStores();
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
        _loadMoreStores();
      }
    }
  }

  Future<void> _loadStores({bool refresh = false}) async {
    try {
      setState(() {
        if (refresh) {
          _isLoading = true;
          _currentPage = 1;
          _stores.clear();
        } else {
          _isLoading = true;
        }
        _errorMessage = '';
      });

      // Check if user is authenticated
      if (!_authService.isLoggedIn()) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppLocalizations.of(context)!.pleaseLoginToViewStores;
        });
        return;
      }

      final response = await _storesService.getStores(
        page: _currentPage,
        search: _searchQuery,
      );
      
      if (mounted) {
        setState(() {
          if (refresh) {
            _stores = response.data;
          } else {
            _stores.addAll(response.data);
          }
          _lastPage = response.lastPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadMoreStores() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      _currentPage++;
      final response = await _storesService.getStores(
        page: _currentPage,
        search: _searchQuery,
      );
      
      if (mounted) {
        setState(() {
          _stores.addAll(response.data);
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

  void _searchStores() {
    setState(() {
      _searchQuery = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
      _currentPage = 1;
    });
    _loadStores(refresh: true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadStores(refresh: true),
                  child: _buildStoresList(),
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
          onSubmitted: (value) => _searchStores(),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchStores,
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
                      _searchStores();
                    },
                    icon: const Icon(Icons.clear),
                  )
                : IconButton(
                    onPressed: _searchStores,
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

  Widget _buildStoresList() {
    if (_isLoading && _stores.isEmpty) {
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

    if (_errorMessage.isNotEmpty && _stores.isEmpty) {
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
            if (_errorMessage.contains('log in') || _errorMessage.contains('login'))
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.goToLogin),
              )
            else
              ElevatedButton(
                onPressed: () => _loadStores(refresh: true),
                child: Text(AppLocalizations.of(context)!.retry),
              ),
          ],
        ),
      );
    }

    if (_stores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noStoresFound,
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
        if (_stores.isNotEmpty)
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
                  '${_stores.length} ${AppLocalizations.of(context)!.stores}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        // Stores Grid
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.54,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
            itemCount: _stores.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _stores.length) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                );
              }
              final store = _stores[index];
              return _buildStoreCard(store, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(Store store, int index) {
    return GestureDetector(
      onTap: () => _showStoreDetails(store),
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
            // Store Image Section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(20),
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
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: store.image != null && store.image!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              store.image!,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.store,
                                  size: 30,
                                  color: Color(0xFF667eea),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.store,
                            size: 30,
                            color: Color(0xFF667eea),
                          ),
                  ),
                ),
              ),
            ),
            
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Store Name
                    Text(
                      store.name,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2d3748),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: store.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        store.isActive 
                            ? AppLocalizations.of(context)!.active 
                            : AppLocalizations.of(context)!.inactive,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    
                    // Cashback Rate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 12,
                          color: const Color(0xFF667eea),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${store.cashbackRate}% ${AppLocalizations.of(context)!.cashbackRate}',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: const Color(0xFF667eea),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // View Products Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToProducts(store),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.viewProducts,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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


  void _navigateToProducts(Store store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsByStoreScreen(store: store),
      ),
    );
  }

  void _showStoreDetails(Store store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStoreDetailsModal(store),
    );
  }

  Widget _buildStoreDetailsModal(Store store) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Header
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF667eea).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: store.image != null && store.image!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  store.image!,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.store,
                                      color: Color(0xFF667eea),
                                      size: 40,
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.store,
                                color: Color(0xFF667eea),
                                size: 40,
                              ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2d3748),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              store.displayEmail,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              store.displayPhone,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Store Details
                  Text(
                    AppLocalizations.of(context)!.storeDetails,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2d3748),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.local_offer,
                    AppLocalizations.of(context)!.cashbackRate,
                    '${store.cashbackRate}%',
                  ),
                  _buildDetailRow(
                    Icons.toggle_on,
                    AppLocalizations.of(context)!.status,
                    store.isActive ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive,
                  ),
                  if (store.storeDetails != null) ...[
                    if (store.storeDetails!.website != null)
                      _buildClickableDetailRow(
                        Icons.web,
                        AppLocalizations.of(context)!.website,
                        store.storeDetails!.website!,
                        () => MapsLauncher.launchWebUrl(store.storeDetails!.website!, context),
                      ),
                    if (store.storeDetails!.deliveryPrice != '0.00')
                      _buildDetailRow(
                        Icons.local_shipping,
                        AppLocalizations.of(context)!.deliveryPrice,
                        '${store.storeDetails!.deliveryPrice} ${AppLocalizations.of(context)!.jd}',
                      ),
                  ],
                  const SizedBox(height: 24),
                  // Action Buttons
                  if (store.storeDetails != null) ...[
                    Row(
                      children: [
                        if (store.storeDetails!.whatsapp != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                MapsLauncher.launchWhatsApp(store.storeDetails!.whatsapp!, context);
                              },
                              icon: const Icon(Icons.chat),
                              label: Text(AppLocalizations.of(context)!.whatsapp),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        if (store.storeDetails!.whatsapp != null && store.storeDetails!.location != null)
                          const SizedBox(width: 12),
                        if (store.storeDetails!.location != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await MapsLauncher.launchGoogleMaps(store.storeDetails!.location!, context);
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error opening maps: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.location_on),
                              label: Text(AppLocalizations.of(context)!.visitStore),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (store.storeDetails!.facebook != null || store.storeDetails!.instagram != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (store.storeDetails!.facebook != null)
                            Expanded(
                              child: ElevatedButton.icon(
                              onPressed: () {
                                MapsLauncher.launchWebUrl(store.storeDetails!.facebook!, context);
                              },
                                icon: const Icon(Icons.facebook),
                                label: Text(AppLocalizations.of(context)!.facebook),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1877F2),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          if (store.storeDetails!.facebook != null && store.storeDetails!.instagram != null)
                            const SizedBox(width: 12),
                          if (store.storeDetails!.instagram != null)
                            Expanded(
                              child: ElevatedButton.icon(
                              onPressed: () {
                                MapsLauncher.launchWebUrl(store.storeDetails!.instagram!, context);
                              },
                                icon: const Icon(Icons.camera_alt),
                                label: Text(AppLocalizations.of(context)!.instagram),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE4405F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement contact store functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.contactFunctionalityComingSoon),
                                ),
                              );
                            },
                            icon: const Icon(Icons.phone),
                            label: Text(AppLocalizations.of(context)!.contactStore),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF48BB78),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement visit store functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.visitStoreFunctionalityComingSoon),
                                ),
                              );
                            },
                            icon: const Icon(Icons.location_on),
                            label: Text(AppLocalizations.of(context)!.visitStore),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF667eea)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2d3748),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableDetailRow(IconData icon, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF667eea)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2d3748),
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: const Color(0xFF667eea),
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: const Color(0xFF667eea),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
