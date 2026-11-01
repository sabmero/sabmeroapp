import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabmeroapp/reponsive.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _gender; // 'Male' | 'Female' | null
  String _originalPhone = '';
  final _picker = ImagePicker();
  String? _pickedImagePath;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).asData?.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone;
      _addressController.text = user.address;
      _gender = user.gender;
      _originalPhone = user.phone;
      _existingImageUrl = user.profileImageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pickedImagePath = picked.path);
    }
  }

  bool get _phoneChanged =>
      Validators.normalizePhone(_phoneController.text.trim()) !=
      _originalPhone;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      final updated = await ref
          .read(profileNotifierProvider.notifier)
          .updateProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneChanged
                ? Validators.normalizePhone(_phoneController.text.trim())
                : null,
            address: _addressController.text.trim(),
            gender: _gender ?? '',
            currentPassword: _phoneChanged
                ? _passwordController.text.trim()
                : null,
            imagePath: _pickedImagePath,
          );

      // Push the fresh user straight into shared auth state so the profile
      // header and everywhere else update instantly (no logout/login needed).
      ref.read(authNotifierProvider.notifier).setUser(updated);

      // If the photo changed, evict the old image from the cache so the new
      // one is actually shown instead of the stale cached bytes.
      final imageUrl = updated.profileImageUrl;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final fullUrl = imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiConstants.serverOrigin}$imageUrl';
        await CachedNetworkImage.evictFromCache(fullUrl);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      // e.g. "That email is already used by another account."
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  ImageProvider? _avatarImage() {
    if (_pickedImagePath != null) return FileImage(File(_pickedImagePath!));
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      final url = _existingImageUrl!.startsWith('http')
          ? _existingImageUrl!
          : '${ApiConstants.serverOrigin}${_existingImageUrl!}';
      return CachedNetworkImageProvider(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileNotifierProvider).isLoading;
    final avatar = _avatarImage();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.formMaxWidth(context),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      backgroundImage: avatar,
                      child: avatar == null
                          ? const Icon(Icons.person, size: 52)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: Theme.of(context).colorScheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _pickImage,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        validator: (v) =>
                            Validators.required(v, fieldName: 'Name'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '98XXXXXXXX',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.phone,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_phoneChanged) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your phone number is your login ID. Enter your '
                          'current password to change it.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Current Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (v) => Validators.required(
                            v,
                            fieldName: 'Current password',
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          return t.isEmpty ? null : Validators.email(t);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _addressController,
                        label: 'Address',
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Gender (optional)',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _GenderChoice(
                              label: 'Male',
                              icon: Icons.male,
                              selected: _gender == 'Male',
                              onTap: () => setState(
                                () => _gender = _gender == 'Male'
                                    ? null
                                    : 'Male',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GenderChoice(
                              label: 'Female',
                              icon: Icons.female,
                              selected: _gender == 'Female',
                              onTap: () => setState(
                                () => _gender = _gender == 'Female'
                                    ? null
                                    : 'Female',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Save Changes',
                  onPressed: _save,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          border: Border.all(color: selected ? scheme.primary : scheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : null),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
