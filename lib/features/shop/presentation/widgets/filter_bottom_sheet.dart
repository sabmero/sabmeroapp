import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialSortBy,
    required this.onApply,
  });

  final double? initialMinPrice;
  final double? initialMaxPrice;
  final String? initialSortBy;
  final void Function({double? minPrice, double? maxPrice, String? sortBy})
  onApply;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(0, 200000);
  String _sortBy = 'newest';

  static const _sortOptions = [
    ('newest', 'Newest First'),
    ('price_asc', 'Price: Low to High'),
    ('price_desc', 'Price: High to Low'),
    ('rating', 'Best Rated'),
    ('popular', 'Most Popular'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMinPrice != null || widget.initialMaxPrice != null) {
      _priceRange = RangeValues(
        widget.initialMinPrice ?? 0,
        widget.initialMaxPrice ?? 200000,
      );
    }
    if (widget.initialSortBy != null) {
      _sortBy = widget.initialSortBy!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() {
                  _priceRange = const RangeValues(0, 200000);
                  _sortBy = 'newest';
                }),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _sortOptions.map((option) {
              final isSelected = _sortBy == option.$1;
              return ChoiceChip(
                label: Text(option.$2),
                selected: isSelected,
                onSelected: (_) => setState(() => _sortBy = option.$1),
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Price Range', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Rs. ${_priceRange.start.toInt()} — Rs. ${_priceRange.end.toInt()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 200000,
            divisions: 200,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Apply Filters',
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(
                minPrice: _priceRange.start,
                maxPrice: _priceRange.end,
                sortBy: _sortBy,
              );
            },
          ),
        ],
      ),
    );
  }
}
