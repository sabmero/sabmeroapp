import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  static const String _lastUpdated = 'Last updated: June 2026';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _PolicyHeader(title: 'Terms of Service', subtitle: _lastUpdated),
          SizedBox(height: 24),
          _Section(
            title: '1. Acceptance of Terms',
            body:
                'By creating an account or using ${AppConstants.appName}, you '
                'agree to these Terms of Service. If you do not agree with any '
                'part of these terms, please do not use the app.',
          ),
          _Section(
            title: '2. Using the App',
            body:
                'You must provide accurate information when registering and keep '
                'your account details up to date. You are responsible for all '
                'activity that happens under your account, so keep your login '
                'credentials secure. You must be of legal age to enter into a '
                'binding contract in your jurisdiction.',
          ),
          _Section(
            title: '3. Orders and Repair Bookings',
            body:
                'When you place an order or book a repair service, you make an '
                'offer to purchase that is confirmed once accepted. Prices, '
                'availability, and service charges are shown in the app and may '
                'change. Final repair charges are confirmed by the technician '
                'on completion of the work.',
          ),
          _Section(
            title: '4. Payments',
            body:
                'Payments can be made by cash on delivery or completion, or '
                'online via the QR payment method shown in the app. For QR '
                'payments you may be asked to upload a payment screenshot for '
                'verification. You agree to pay all charges associated with '
                'your orders and bookings.',
          ),
          _Section(
            title: '5. Cancellations and Refunds',
            body:
                'Repair bookings can be cancelled from the app while they are '
                'still pending. Once a technician has started work, '
                'cancellation may not be possible. Refund eligibility for '
                'orders and services depends on the situation and applicable '
                'consumer law; contact support for help with a specific case.',
          ),
          _Section(
            title: '6. Vendors and Technicians',
            body:
                'Some services and products are provided by independent vendors '
                'and technicians using the platform. While we work to maintain '
                'quality, ${AppConstants.appName} acts as a marketplace '
                'connecting you with these providers and is not the direct '
                'seller of every item or service.',
          ),
          _Section(
            title: '7. Acceptable Use',
            body:
                'You agree not to misuse the app, including attempting to '
                'access it through unauthorised means, interfering with its '
                'operation, submitting false information, or using it for any '
                'unlawful purpose. We may suspend or terminate accounts that '
                'violate these terms.',
          ),
          _Section(
            title: '8. Limitation of Liability',
            body:
                'The app is provided on an "as is" basis. To the extent '
                'permitted by law, ${AppConstants.appName} is not liable for '
                'indirect or consequential losses arising from your use of the '
                'service. Nothing in these terms limits rights you have under '
                'applicable law.',
          ),
          _Section(
            title: '9. Changes to These Terms',
            body:
                'We may update these Terms of Service from time to time. The '
                'date above reflects the latest revision. Continued use of the '
                'app after changes take effect means you accept the updated '
                'terms.',
          ),
          _Section(
            title: '10. Contact Us',
            body:
                'For any questions about these terms, please reach us through '
                'the Help & Support screen in the app.',
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
          child: Icon(Icons.description_outlined, color: primary, size: 30),
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
