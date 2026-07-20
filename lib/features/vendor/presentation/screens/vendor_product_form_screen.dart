import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../shop/domain/entities/category_entity.dart';
import '../providers/vendor_products_provider.dart';

class VendorProductFormScreen extends ConsumerStatefulWidget {
  const VendorProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<VendorProductFormScreen> createState() =>
      _VendorProductFormScreenState();
}

class _VariantDraft {
  final String id;
  final TextEditingController labelController;
  final TextEditingController priceController;
  final TextEditingController stockController;
  final TextEditingController unitController;

  _VariantDraft({
    required this.id,
    String label = '',
    String price = '',
    String stock = '',
    String unit = 'pcs',
  })  : labelController = TextEditingController(text: label),
        priceController = TextEditingController(text: price),
        stockController = TextEditingController(text: stock),
        unitController = TextEditingController(text: unit);

  void dispose() {
    labelController.dispose();
    priceController.dispose();
    stockController.dispose();
    unitController.dispose();
  }
}

class _VendorProductFormScreenState
    extends ConsumerState<VendorProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _uuid = const Uuid();

  String _categoryId = 'cat_electronics';
  final List<_VariantDraft> _variants = [];
  bool _isSubmitting = false;

  static const _categories = [
    ('cat_electronics', 'Electronics'),
    ('cat_clothing', 'Clothing'),
    ('cat_footwear', 'Footwear'),
    ('cat_grocery', 'Grocery'),
    ('cat_home', 'Home & Living'),
    ('cat_sports', 'Sports'),
  ];

  bool get _isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final products = ref.read(vendorProductsNotifierProvider).asData?.value ?? [];
      final existing = products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => products.first,
      );
      _nameController.text = existing.name;
      _descController.text = existing.description;
      _categoryId = existing.categoryId;
      for (final v in existing.variants) {
        _variants.add(_VariantDraft(
          id: v.id,
          label: v.label,
          price: v.price.toStringAsFixed(0),
          stock: '${v.stock}',
          unit: v.unit,
        ));
      }
    }
    if (_variants.isEmpty) {
      _variants.add(_VariantDraft(id: _uuid.v4()));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final v in _variants) {
      v.dispose();
    }
    super.dispose();
  }

  void _addVariant() {
    setState(() => _variants.add(_VariantDraft(id: _uuid.v4())));
  }

  void _removeVariant(int index) {
    if (_variants.length <= 1) return;
    setState(() {
      _variants[index].dispose();
      _variants.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final variants = _variants
        .map((v) => ProductVariantEntity(
              id: v.id,
              label: v.labelController.text.trim(),
              price: double.tryParse(v.priceController.text.trim()) ?? 0,
              stock: int.tryParse(v.stockController.text.trim()) ?? 0,
              unit: v.unitController.text.trim().isEmpty
                  ? 'pcs'
                  : v.unitController.text.trim(),
            ))
        .toList();

    final categoryName =
        _categories.firstWhere((c) => c.$1 == _categoryId).$2;

    final product = ProductEntity(
      id: widget.productId ?? 'vnd_prd_${_uuid.v4().substring(0, 8)}',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      categoryId: _categoryId,
      categoryName: categoryName,
      vendorId: 'vnd_001',
      vendorName: 'My Store',
      imageUrls: ['https://picsum.photos/seed/${_uuid.v4()}/400/400'],
      variants: variants,
      basePrice: variants.isNotEmpty ? variants.first.price : 0,
      rating: _isEditing ? 0 : 0,
      reviewCount: 0,
      isAvailable: true,
      createdAt: DateTime.now(),
    );

    setState(() => _isSubmitting = true);
    try {
      if (_isEditing) {
        await ref.read(vendorProductsNotifierProvider.notifier).updateProduct(product);
      } else {
        await ref.read(vendorProductsNotifierProvider.notifier).createProduct(product);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Product updated' : 'Product created'),
          backgroundColor: AppColors.successColor,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'e.g. Samsung Galaxy A55',
              prefixIcon: Icons.shopping_bag_outlined,
              validator: (v) => Validators.required(v, fieldName: 'Product name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descController,
              label: 'Description',
              hint: 'Describe your product',
              maxLines: 4,
              validator: (v) => Validators.required(v, fieldName: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v!),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Variants',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addVariant,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Variant'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Add size, color, or unit options (e.g. S - White, 1 Kg, 256GB)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ..._variants.asMap().entries.map((entry) {
              return _VariantFormCard(
                draft: entry.value,
                index: entry.key,
                canRemove: _variants.length > 1,
                onRemove: () => _removeVariant(entry.key),
              );
            }),
            const SizedBox(height: 32),
            AppButton(
              label: _isEditing ? 'Save Changes' : 'Create Product',
              onPressed: _submit,
              isLoading: _isSubmitting,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _VariantFormCard extends StatelessWidget {
  const _VariantFormCard({
    required this.draft,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  final _VariantDraft draft;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Variant ${index + 1}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
            ],
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: draft.labelController,
            label: 'Variant Label',
            hint: 'e.g. M - Blue, 1 Kg, 128GB',
            validator: (v) => Validators.required(v, fieldName: 'Label'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: draft.priceController,
                  label: 'Price (Rs.)',
                  keyboardType: TextInputType.number,
                  validator: Validators.price,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  controller: draft.stockController,
                  label: 'Stock',
                  keyboardType: TextInputType.number,
                  validator: Validators.quantity,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  controller: draft.unitController,
                  label: 'Unit',
                  hint: 'pcs, Kg...',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
