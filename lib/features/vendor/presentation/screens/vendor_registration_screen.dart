import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/widgets/kyc_upload_card.dart';
import '../providers/vendor_provider.dart';

class VendorRegistrationScreen extends ConsumerStatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  ConsumerState<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState
    extends ConsumerState<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _kycDocPath;
  String? _businessDocPath;

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(vendorProfileProvider.notifier).register(
          businessName: _businessNameController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.hourglass_top_rounded,
              color: AppColors.warningColor, size: 56),
          title: const Text('Application Submitted'),
          content: const Text(
            'Your vendor application is under review. You will be notified once approved. You can view your dashboard status anytime.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go(RouteNames.vendorDashboard);
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      );
    } else {
      final error = ref.read(vendorProfileProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Registration failed'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(vendorProfileProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Become a Vendor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.storefront_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Start selling on sabmero. Fill in your business details below to begin the application process.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _businessNameController,
              label: 'Business Name',
              hint: 'e.g. Hari Electronics Store',
              prefixIcon: Icons.business_outlined,
              validator: (v) => Validators.required(v, fieldName: 'Business name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Business Phone Number',
              hint: '98XXXXXXXX',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _addressController,
              label: 'Business Address',
              hint: 'Shop / warehouse address',
              prefixIcon: Icons.location_on_outlined,
              maxLines: 2,
              validator: (v) => Validators.required(v, fieldName: 'Address'),
            ),
            const SizedBox(height: 24),
            Text(
              'Owner KYC Document',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Citizenship, passport, or national ID',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            KycUploadCard(
              filePath: _kycDocPath,
              onFilePicked: (p) => setState(() => _kycDocPath = p),
            ),
            const SizedBox(height: 20),
            Text(
              'Business Registration Document',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'PAN/VAT certificate or company registration',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            KycUploadCard(
              filePath: _businessDocPath,
              onFilePicked: (p) => setState(() => _businessDocPath = p),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Submit Application',
              onPressed: _submit,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
