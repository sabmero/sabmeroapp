// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sab_mero/core/provider/appversion_provider.dart';
// import '../../../../core/theme/theme_mode_provider.dart';

// class SettingsScreen extends ConsumerWidget {
//   const SettingsScreen({super.key});

//   String _themeLabel(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return 'Light';
//       case ThemeMode.dark:
//         return 'Dark';
//       case ThemeMode.system:
//         return 'System default';
//     }
//   }

//   IconData _themeIcon(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return Icons.light_mode_outlined;
//       case ThemeMode.dark:
//         return Icons.dark_mode_outlined;
//       case ThemeMode.system:
//         return Icons.brightness_auto_outlined;
//     }
//   }

//   Future<void> _pickTheme(
//     BuildContext context,
//     WidgetRef ref,
//     ThemeMode current,
//   ) async {
//     final selected = await showModalBottomSheet<ThemeMode>(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (sheetContext) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 12),
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Theme.of(sheetContext).dividerColor,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Appearance',
//                     style: Theme.of(sheetContext).textTheme.titleMedium
//                         ?.copyWith(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//               RadioGroup<ThemeMode>(
//                 groupValue: current,
//                 onChanged: (value) => Navigator.of(sheetContext).pop(value),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     for (final mode in ThemeMode.values)
//                       RadioListTile<ThemeMode>(
//                         value: mode,
//                         secondary: Icon(_themeIcon(mode)),
//                         title: Text(_themeLabel(mode)),
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         );
//       },
//     );

//     if (selected != null) {
//       await ref.read(themeModeProvider.notifier).setThemeMode(selected);
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final themeMode = ref.watch(themeModeProvider);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: Icon(_themeIcon(themeMode)),
//             title: const Text('Theme'),
//             subtitle: Text(_themeLabel(themeMode)),
//             trailing: const Icon(Icons.chevron_right_rounded),
//             onTap: () => _pickTheme(context, ref, themeMode),
//           ),
//           const Divider(),
//           SwitchListTile(
//             title: const Text('Push Notifications'),
//             subtitle: const Text('Order and repair updates'),
//             value: true,
//             onChanged: (_) {},
//           ),
//           SwitchListTile(
//             title: const Text('Promotional Alerts'),
//             subtitle: const Text('Deals and offers'),
//             value: false,
//             onChanged: (_) {},
//           ),
//           const Divider(),
//           // ListTile(
//           //   title: const Text('Language'),
//           //   subtitle: const Text('English'),
//           //   trailing: const Icon(Icons.chevron_right_rounded),
//           //   onTap: () =>
//           //       context.push(RouteNames.comingSoon, extra: 'Language Settings'),
//           // ),
//           const SizedBox(height: 16),
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(horizontal: 16),
//           //   child: Text(
//           //     'App Version 1.0.0',
//           //     style: Theme.of(context).textTheme.bodySmall,
//           //     textAlign: TextAlign.center,
//           //   ),
//           // ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Consumer(
//               builder: (context, ref, _) {
//                 final version = ref.watch(appVersionProvider);
//                 return Text(
//                   version.asData?.value ?? 'App Version …',
//                   style: Theme.of(context).textTheme.bodySmall,
//                   textAlign: TextAlign.center,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabmeroapp/core/provider/appversion_provider.dart';
import 'package:sabmeroapp/features/notifications/presentation/providers/notification_prefs_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Appearance',
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              RadioGroup<ThemeMode>(
                groupValue: current,
                onChanged: (value) => Navigator.of(sheetContext).pop(value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final mode in ThemeMode.values)
                      RadioListTile<ThemeMode>(
                        value: mode,
                        secondary: Icon(_themeIcon(mode)),
                        title: Text(_themeLabel(mode)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await ref.read(themeModeProvider.notifier).setThemeMode(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notifPrefs = ref.watch(notificationPrefsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(_themeIcon(themeMode)),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(themeMode)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickTheme(context, ref, themeMode),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Order and repair updates'),
            value: notifPrefs.pushNotifications,
            onChanged: (value) => ref
                .read(notificationPrefsProvider.notifier)
                .setPushNotifications(value),
          ),
          SwitchListTile(
            title: const Text('Promotional Alerts'),
            subtitle: const Text('Deals and offers'),
            value: notifPrefs.promotionalAlerts,
            onChanged: (value) => ref
                .read(notificationPrefsProvider.notifier)
                .setPromotionalAlerts(value),
          ),
          const SizedBox(height: 16),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: Text(
          //     'App Version 1.0.0',
          //     style: Theme.of(context).textTheme.bodySmall,
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer(
              builder: (context, ref, _) {
                final version = ref.watch(appVersionProvider);
                return Text(
                  version.asData?.value ?? 'App Version …',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
