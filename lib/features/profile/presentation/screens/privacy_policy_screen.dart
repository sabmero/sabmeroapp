import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _lastUpdated = 'Last updated: June 2026';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _PolicyHeader(title: 'Your privacy matters', subtitle: _lastUpdated),
          SizedBox(height: 24),
          _Section(
            title: '1. Information We Collect',
            body:
                'When you use ${AppConstants.appName}, we collect information you '
                'provide directly, such as your name, phone number, email '
                'address, delivery addresses, and KYC documents where required. '
                'We also collect data generated while using the app, including '
                'your orders, repair bookings, payment records, and device '
                'information needed to keep the service secure.',
          ),
          _Section(
            title: '2. How We Use Your Information',
            body:
                'We use your information to create and manage your account, '
                'process orders and repair bookings, arrange delivery, handle '
                'payments, provide customer support, and send you important '
                'updates about your transactions. We may also use it to improve '
                'the app and to detect and prevent fraud or misuse.',
          ),
          _Section(
            title: '3. Location Data',
            body:
                'With your permission, we use your device location to set your '
                'delivery and repair-service address accurately and to show '
                'nearby vendors and technicians. You can disable location '
                'access at any time from your device settings, though some '
                'features may then require you to enter your address manually.',
          ),
          _Section(
            title: '4. Sharing Your Information',
            body:
                'We share only the information necessary to complete your '
                'requests — for example, sharing your delivery address with the '
                'assigned vendor, technician, or delivery rider. We do not sell '
                'your personal data to third parties. We may disclose '
                'information when required by law or to protect the rights and '
                'safety of our users.',
          ),
          _Section(
            title: '5. Data Security',
            body:
                'We use industry-standard measures to protect your data, '
                'including secure storage of authentication tokens and encrypted '
                'transmission of sensitive information. No system is completely '
                'secure, so we encourage you to keep your login credentials '
                'private and to notify us of any unauthorised activity.',
          ),
          _Section(
            title: '6. Your Rights',
            body:
                'You can review and update your profile information at any time '
                'from the app. You may request deletion of your account and '
                'associated data by contacting our support team. Some records '
                'may be retained where required for legal or accounting '
                'purposes.',
          ),
          _Section(
            title: '7. Changes to This Policy',
            body:
                'We may update this Privacy Policy from time to time. When we '
                'make significant changes, we will update the date above and, '
                'where appropriate, notify you within the app. Continued use of '
                '${AppConstants.appName} after changes means you accept the '
                'updated policy.',
          ),
          _Section(
            title: '8. Contact Us',
            body:
                'If you have questions about this Privacy Policy or how your '
                'data is handled, please reach us through the Help & Support '
                'screen in the app.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _PolicyHeader extends StatelessWidget {
  const _PolicyHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: primary.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.shield_outlined, color: primary, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
