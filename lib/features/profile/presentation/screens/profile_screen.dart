// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/route_names.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/widgets/skeleton_loaders.dart';
// import '../../../auth/presentation/providers/auth_provider.dart';
// import '../../../auth/domain/entities/user_entity.dart';
// import '../widgets/profile_menu_tile.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(authNotifierProvider).asData?.value;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: user == null
//           ? ListView(
//               children: const [
//                 ProfileHeaderSkeleton(),
//                 SizedBox(height: 8),
//                 TileListSkeleton(itemCount: 5),
//               ],
//             )
//           : ListView(
//               children: [
//                 ProfileHeader(user: user),
//                 const SizedBox(height: 8),
//                 MenuSection(
//                   title: 'Account',
//                   tiles: [
//                     ProfileMenuTile(
//                       icon: Icons.person_outline,
//                       title: 'Edit Profile',
//                       onTap: () => context.push(RouteNames.editProfile),
//                     ),
//                     ProfileMenuTile(
//                       icon: Icons.location_on_outlined,
//                       title: 'Saved Addresses',
//                       onTap: () => context.push(RouteNames.addressList),
//                     ),
//                     ProfileMenuTile(
//                       icon: Icons.verified_user_outlined,
//                       title: 'KYC Status',
//                       subtitle: user.isKycVerified ? 'VERIFIED' : 'PENDING',
//                       iconColor: user.isKycVerified
//                           ? AppColors.successColor
//                           : AppColors.warningColor,
//                       onTap: () => context.push(
//                         RouteNames.comingSoon,
//                         extra: 'KYC Verification',
//                       ),
//                     ),
//                   ],
//                 ),
//                 MenuSection(
//                   title: 'Settings',
//                   tiles: [
//                     ProfileMenuTile(
//                       icon: Icons.settings_outlined,
//                       title: 'App Settings',
//                       onTap: () => context.push(RouteNames.settings),
//                     ),
//                     ProfileMenuTile(
//                       icon: Icons.help_outline,
//                       title: 'Help & Support',
//                       onTap: () => context.push(
//                         RouteNames.comingSoon,
//                         extra: 'Help & Support',
//                       ),
//                     ),
//                   ],
//                 ),
//                 MenuSection(
//                   title: '',
//                   tiles: [
//                     ProfileMenuTile(
//                       icon: Icons.logout_rounded,
//                       title: 'Sign Out',
//                       isDestructive: true,
//                       onTap: () => _confirmLogout(context, ref),
//                       trailing: const SizedBox.shrink(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//               ],
//             ),
//     );
//   }

//   Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Sign Out'),
//         content: const Text('Are you sure you want to sign out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext, true),
//             child: const Text(
//               'Sign Out',
//               style: TextStyle(color: AppColors.errorColor),
//             ),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) {
//       // Defer the logout until the dialog has fully popped, so the router's
//       // auth redirect doesn't run while the navigator stack is still unwinding
//       // (which caused the "popped the last page off the stack" assertion).
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref.read(authNotifierProvider.notifier).logout();
//       });
//     }
//   }
// }

// class ProfileHeader extends StatelessWidget {
//   const ProfileHeader({required this.user});
//   final dynamic user;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       child: Row(
//         children: [
//           ClipOval(
//             child: CachedNetworkImage(
//               imageUrl:
//                   user.profileImageUrl ?? 'https://i.pravatar.cc/150?img=12',
//               width: 72,
//               height: 72,
//               fit: BoxFit.cover,
//               errorWidget: (_, _, _) => const CircleAvatar(
//                 radius: 36,
//                 child: Icon(Icons.person, size: 40),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user.name,
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(user.phone, style: Theme.of(context).textTheme.bodySmall),
//                 if (user.email != null && (user.email as String).isNotEmpty)
//                   Text(
//                     user.email!,
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 const SizedBox(height: 6),
//                 _RoleBadge(role: user.role),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RoleBadge extends StatelessWidget {
//   const _RoleBadge({required this.role});
//   final UserRole role;

//   @override
//   Widget build(BuildContext context) {
//     final label = switch (role) {
//       UserRole.vendor => 'Vendor',
//       UserRole.technician => 'Technician',
//       UserRole.deliveryRider => 'Delivery Rider',
//       UserRole.admin => 'Admin',
//       UserRole.customer => 'Customer',
//     };
//     final color = Theme.of(context).colorScheme.primary;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withAlpha(26),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.badge_outlined, size: 13, color: color),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.labelSmall?.copyWith(
//               color: color,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class MenuSection extends StatelessWidget {
//   const MenuSection({required this.title, required this.tiles});
//   final String title;
//   final List<Widget> tiles;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (title.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
//             child: Text(
//               title,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.5,
//                 color: Theme.of(context).colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withAlpha(8),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           // The Material both carries the card colour and gives the ListTiles a
//           // surface to paint their background and ink ripples on. ClipRRect keeps
//           // the ripple inside the rounded corners.
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Material(
//               color: Theme.of(context).cardColor,
//               child: Column(children: tiles),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/profile_menu_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: user == null
          ? ListView(
              children: const [
                ProfileHeaderSkeleton(),
                SizedBox(height: 8),
                TileListSkeleton(itemCount: 5),
              ],
            )
          : ListView(
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 8),
                MenuSection(
                  title: 'Account',
                  tiles: [
                    ProfileMenuTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      onTap: () => context.push(RouteNames.editProfile),
                    ),
                  ],
                ),
                MenuSection(
                  title: 'Settings',
                  tiles: [
                    ProfileMenuTile(
                      icon: Icons.settings_outlined,
                      title: 'App Settings',
                      onTap: () => context.push(RouteNames.settings),
                    ),
                    ProfileMenuTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => context.push(RouteNames.helpSupport),
                    ),
                    ProfileMenuTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      onTap: () => context.push(RouteNames.privacyPolicy),
                    ),
                    ProfileMenuTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => context.push(RouteNames.termsOfService),
                    ),
                  ],
                ),
                MenuSection(
                  title: '',
                  tiles: [
                    ProfileMenuTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      isDestructive: true,
                      onTap: () => _confirmLogout(context, ref),
                      trailing: const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Defer the logout until the dialog has fully popped, so the router's
      // auth redirect doesn't run while the navigator stack is still unwinding
      // (which caused the "popped the last page off the stack" assertion).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authNotifierProvider.notifier).logout();
      });
    }
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});
  final UserEntity user;

  String get _initials {
    final parts = user.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String? get _avatarUrl {
    final raw = user.profileImageUrl;
    if (raw == null || raw.isEmpty) return null;
    return raw.startsWith('http') ? raw : '${ApiConstants.serverOrigin}$raw';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = _avatarUrl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with a subtle ring; falls back to initials.
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.primary.withAlpha(120)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: scheme.primary.withAlpha(26),
                backgroundImage: url != null
                    ? CachedNetworkImageProvider(url)
                    : null,
                child: url == null
                    ? Text(
                        _initials,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Name, role, contact details.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _RoleBadge(role: user.role),
                  const SizedBox(height: 10),
                  _ContactRow(icon: Icons.phone_outlined, text: user.phone),
                  if (user.email != null && user.email!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _ContactRow(
                      icon: Icons.email_outlined,
                      text: user.email!,
                    ),
                  ],
                ],
              ),
            ),
            // Quick edit shortcut.
            IconButton(
              onPressed: () => context.push(RouteNames.editProfile),
              icon: Icon(Icons.edit_outlined, color: scheme.primary),
              tooltip: 'Edit Profile',
              style: IconButton.styleFrom(
                backgroundColor: scheme.primary.withAlpha(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.vendor => 'Vendor',
      UserRole.technician => 'Technician',
      UserRole.deliveryRider => 'Delivery Rider',
      UserRole.admin => 'Admin',
      UserRole.customer => 'Customer',
    };
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge_outlined, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuSection extends StatelessWidget {
  const MenuSection({super.key, required this.title, required this.tiles});
  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          // The Material both carries the card colour and gives the ListTiles a
          // surface to paint their background and ink ripples on. ClipRRect keeps
          // the ripple inside the rounded corners.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Theme.of(context).cardColor,
              child: Column(children: tiles),
            ),
          ),
        ),
      ],
    );
  }
}
