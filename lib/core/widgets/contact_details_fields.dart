import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../utils/validators.dart';
import 'app_text_field.dart';

/// Holds the "who should we contact" name and phone shown when ordering or
/// booking a service. Both are required.
class ContactDetailsController {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool _filled = false;

  /// Fills the fields once from the logged-in account (the person can still
  /// change them, e.g. to order for someone else).
  void fillOnce(String accountName, String accountPhone) {
    if (_filled) return;
    name.text = accountName;
    phone.text = accountPhone;
    _filled = true;
  }

  /// Returns an error message, or null when both are filled in correctly.
  String? validate() {
    if (name.text.trim().isEmpty) return 'Please enter your name';
    return Validators.phone(phone.text.trim());
  }

  String get cleanPhone => Validators.normalizePhone(phone.text.trim());

  /// Address plus the contact line, so the seller / technician always sees
  /// who to call.
  String withAddress(String address) =>
      '${address.trim()}\nContact: ${name.text.trim()}, $cleanPhone';

  void dispose() {
    name.dispose();
    phone.dispose();
  }
}

class ContactDetailsFields extends ConsumerStatefulWidget {
  const ContactDetailsFields({super.key, required this.controller});

  final ContactDetailsController controller;

  @override
  ConsumerState<ContactDetailsFields> createState() =>
      _ContactDetailsFieldsState();
}

class _ContactDetailsFieldsState extends ConsumerState<ContactDetailsFields> {
  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).asData?.value;
    if (user != null) {
      widget.controller.fillOnce(user.name, user.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          controller: widget.controller.name,
          label: 'Your Name',
          prefixIcon: Icons.person_outline,
          validator: (v) => Validators.required(v, fieldName: 'Name'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: widget.controller.phone,
          label: 'Phone Number',
          hint: '98XXXXXXXX',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
        ),
      ],
    );
  }
}
