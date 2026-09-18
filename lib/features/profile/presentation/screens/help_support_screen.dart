import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  // Update these with your real support channels.
  static const String _supportEmail = 'support@sabmero.com';
  static const String _supportPhone = '+977 9747737597';

  Future<void> _launch(Uri uri, BuildContext context) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _showError(context, 'Could not open ${uri.scheme}');
      }
    } catch (e, st) {
      AppLogger.error(
        'Failed to launch ${uri.scheme}',
        tag: 'HelpSupport',
        error: e,
        stackTrace: st,
      );
      if (context.mounted) _showError(context, 'Something went wrong');
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.errorColor),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          _Intro(),
          const SizedBox(height: 20),
          _SectionLabel('Contact Us'),
          const SizedBox(height: 10),
          _ContactCard(
            children: [
              _ContactTile(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: _supportEmail,
                onTap: () => _launch(
                  Uri(
                    scheme: 'mailto',
                    path: _supportEmail,
                    query:
                        'subject=${Uri.encodeComponent('${AppConstants.appName} Support')}',
                  ),
                  context,
                ),
              ),
              const _TileDivider(),
              _ContactTile(
                icon: Icons.call_outlined,
                title: 'Call Us',
                subtitle: _supportPhone,
                onTap: () =>
                    _launch(Uri(scheme: 'tel', path: _supportPhone), context),
              ),
              const _TileDivider(),
              _ContactTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'WhatsApp',
                subtitle: 'Chat with our team',
                onTap: () => _launch(
                  Uri.parse(
                    'https://wa.me/${_supportPhone.replaceAll('+', '')}',
                  ),
                  context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel('Frequently Asked Questions'),
          const SizedBox(height: 10),
          _FaqCard(),
          const SizedBox(height: 24),
          _SectionLabel('Legal'),
          const SizedBox(height: 10),
          _ContactCard(
            children: [
              _ContactTile(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                onTap: () => context.push(RouteNames.privacyPolicy),
              ),
              const _TileDivider(),
              _ContactTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => context.push(RouteNames.termsOfService),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: primary.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.support_agent_rounded, color: primary, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can we help?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'We usually reply within a few hours.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Theme.of(context).cardColor,
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: primary),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).dividerColor.withAlpha(60),
    );
  }
}

class _FaqCard extends StatelessWidget {
  static const List<({String q, String a})> _faqs = [
    (
      q: 'How do I track my order?',
      a:
          'Open the Activity tab, select your order, and tap Track to see its '
          'current status and delivery progress.',
    ),
    (
      q: 'How do I book a repair service?',
      a:
          'From the Home screen, tap the Repair section, choose a category such '
          'as Electrical or CCTV, pick a date and time slot, and confirm your '
          'booking.',
    ),
    (
      q: 'Can I cancel a repair booking?',
      a:
          'Yes — while a booking is still pending you can cancel it from My '
          'Bookings. Once a technician starts work it can no longer be '
          'cancelled from the app.',
    ),
    (
      q: 'What payment methods are accepted?',
      a:
          'You can pay with cash on delivery or completion, or online using the '
          'QR payment method. For QR payments you may need to upload a payment '
          'screenshot for verification.',
    ),
    (
      q: 'How do I update my profile or address?',
      a:
          'Go to the Profile tab, then Edit Profile or Saved Addresses to update '
          'your details.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Theme.of(context).cardColor,
          child: Theme(
            // Remove the default ExpansionTile top/bottom dividers for a
            // cleaner card look.
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Column(
              children: [
                for (var i = 0; i < _faqs.length; i++) ...[
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    title: Text(
                      _faqs[i].q,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Text(
                        _faqs[i].a,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  if (i != _faqs.length - 1) const _TileDivider(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
