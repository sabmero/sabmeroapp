import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../providers/categories_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/product_grid.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String _currentQuery = '';

  // Currently applied filter/sort, kept so the sheet reopens with them.
  double _minPrice = 0;
  double _maxPrice = 200000;
  String _sortBy = 'newest';

  // Single source of truth for the family key. Empty categoryId (e.g. coming
  // from the home search button) maps to null so the watch and the search
  // notifier calls hit the SAME provider instance.
  String? get _categoryKey =>
      widget.categoryId.isNotEmpty ? widget.categoryId : null;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fetch the next page a little before the user hits the bottom so the grid
  // keeps filling until every product in the category is shown.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(productsNotifierProvider(_categoryKey).notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        setState(() => _currentQuery = query);
        final notifier = ref.read(
          productsNotifierProvider(_categoryKey).notifier,
        );
        if (query.isEmpty) {
          notifier.clearSearch();
        } else {
          notifier.search(query);
        }
      },
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FilterBottomSheet(
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialSortBy: _sortBy,
        onApply: ({minPrice, maxPrice, sortBy}) {
          setState(() {
            _minPrice = minPrice ?? 0;
            _maxPrice = maxPrice ?? 200000;
            _sortBy = sortBy ?? 'newest';
          });
          ref
              .read(productsNotifierProvider(_categoryKey).notifier)
              .applyFilters(
                minPrice: _minPrice,
                maxPrice: _maxPrice,
                sortBy: _sortBy,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsNotifierProvider(_categoryKey));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: productsState.when(
              data: (state) => state.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 56),
                          const SizedBox(height: 12),
                          Text(
                            _currentQuery.isNotEmpty
                                ? 'No products found for "$_currentQuery"'
                                : 'No products in this category yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                      ],
                      ),
                    )
                  : ProductGrid(
                      products: state.items,
                      controller: _scrollController,
                      isLoadingMore: state.isLoadingMore,
                    ),
              loading: () => const ProductGridSkeleton(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () =>
                    ref.invalidate(productsNotifierProvider(_categoryKey)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
