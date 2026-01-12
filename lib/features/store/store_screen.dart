import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constant/app_colors.dart';
import '../../core/constant/app_texts.dart';
import '../../core/di/inject.dart' as di;
import 'add_product_screen.dart';
import 'data/models/product_models.dart';
import 'data/repo/product_repository.dart';
import 'product_details_screen.dart';
import 'widgets/product_item_widget.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final ProductRepository _productRepository = di.sl<ProductRepository>();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  Timer? _searchDebounceTimer;
  String _searchQuery = '';
  String? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _searchController.addListener(() {
      setState(() {}); // Rebuild to show/hide clear icon
    });
    _loadProducts();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        _products = [];
        _filteredProducts = [];
        _errorMessage = null;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } else {
      if (_isLoading || _isLoadingMore || !_hasMore) return;
    }

    setState(() {
      if (_currentPage == 1) {
        _isLoading = true;
        _isLoadingMore = false;
      } else {
        _isLoading = false;
        _isLoadingMore = true;
      }
    });

    try {
      final pageToLoad = refresh ? 1 : _currentPage;

      final response = await _productRepository.getProducts(
        page: pageToLoad,
        type: _selectedTypeFilter,
      );

      if (mounted) {
        setState(() {
          if (pageToLoad == 1) {
            _products = response.data;
            _currentPage = 2;
          } else {
            _products.addAll(response.data);
            _currentPage++;
          }
          _hasMore = response.meta?.hasMorePages ?? false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final currentQuery = _searchController.text.trim();
    if (currentQuery == _searchQuery) return;

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _searchController.text.trim() == currentQuery) {
        setState(() {
          _searchQuery = currentQuery;
          _applyFilters();
        });
      }
    });
  }

  void _applyFilters() {
    if (_searchQuery.trim().isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      final searchLower = _searchQuery.trim().toLowerCase();
      _filteredProducts = _products.where((product) {
        final nameMatch = product.name.toLowerCase().contains(searchLower);
        final descriptionMatch =
            product.description?.toLowerCase().contains(searchLower) ?? false;
        final sellerMatch = product.user.userName.toLowerCase().contains(
          searchLower,
        );
        return nameMatch || descriptionMatch || sellerMatch;
      }).toList();
    }
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadProducts();
    }
  }

  Future<void> _openAddProduct() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddProductScreen()));

    if (result == true) {
      await _loadProducts(refresh: true);
    }
  }

  void _openProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(productId: product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.storeTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openAddProduct,
            icon: Icon(Icons.add, color: AppColors.primary, size: 32.r),
            tooltip: AppTexts.addProduct,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProducts(refresh: true),
        child: Column(
          children: [
            _buildSearchField(),
            _buildTypeFilter(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(8.w),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return TextFormField(
            controller: _searchController,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: AppTexts.productsSearchPlaceholder,
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 15.sp,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: 22.sp,
                      ),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(14.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(8.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 40.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTypeChip(null, AppTexts.allTypes),
              SizedBox(width: 4.w),
              _buildTypeChip('person', AppTexts.productTypePerson),
              SizedBox(width: 4.w),
              _buildTypeChip('company', AppTexts.productTypeCompany),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String? value, String label) {
    final isSelected =
        _selectedTypeFilter == value ||
        (_selectedTypeFilter == null && value == null);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (!selected) return;
        setState(() {
          _selectedTypeFilter = value;
        });
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        _loadProducts(refresh: true);
      },
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textOnPrimary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: AppColors.surfaceVariant,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _products.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => _loadProducts(refresh: true),
                    child: const Text(AppTexts.retry),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_products.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 64.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppTexts.noProductsYet,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppTexts.tapToAddFirstProduct,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_filteredProducts.isEmpty && _searchQuery.isNotEmpty) {
      return ListView(
        children: [
          SizedBox(height: 120.h),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppTexts.noProductsFound,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppTexts.tryDifferentKeywords,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      cacheExtent: 500,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemCount: _filteredProducts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredProducts.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final product = _filteredProducts[index];
        return ProductItemWidget(
          product: product,
          index: index,
          onTap: () => _openProductDetails(product),
        );
      },
    );
  }
}
