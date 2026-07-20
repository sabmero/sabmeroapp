// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/router/route_names.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/utils/app_date_utils.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../../../../core/widgets/app_text_field.dart';
// import '../../../payment/presentation/widgets/payment_qr_card.dart';
// import '../../domain/entities/repair_category_entity.dart';
// import '../providers/repair_categories_provider.dart';
// import '../widgets/damage_photo_uploader.dart';
// import '../widgets/location_address_field.dart';
// import '../widgets/slot_picker.dart';

// class RepairBookingScreen extends ConsumerStatefulWidget {
//   const RepairBookingScreen({
//     super.key,
//     required this.categoryId,
//     required this.categoryName,
//   });

//   final String categoryId;
//   final String categoryName;

//   @override
//   ConsumerState<RepairBookingScreen> createState() =>
//       _RepairBookingScreenState();
// }

// class _RepairBookingScreenState extends ConsumerState<RepairBookingScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _addressController = TextEditingController();
//   final _descController = TextEditingController();
//   DateTime? _selectedDate;
//   String? _selectedSlot;
//   final List<String> _photoPaths = [];
//   double? _latitude;
//   double? _longitude;
//   // Backend accepts "Cash" | "QR". Defaults to Cash.
//   String _paymentMethod = 'Cash';
//   // Local path of the QR payment-proof screenshot (uploaded on submit).
//   String? _paymentScreenshotPath;

//   static final _availableDates = AppDateUtils.nextNDays(7);

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   Future<void> _confirmBooking() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedDate == null) {
//       _showError('Please select a date');
//       return;
//     }
//     if (_selectedSlot == null) {
//       _showError('Please select a time slot');
//       return;
//     }
//     if (_paymentMethod == 'QR' && _paymentScreenshotPath == null) {
//       _showError('Please upload your payment screenshot for QR payment');
//       return;
//     }

//     final booking = await ref
//         .read(repairBookingNotifierProvider.notifier)
//         .createBooking(
//           categoryId: widget.categoryId,
//           categoryName: widget.categoryName,
//           address: _addressController.text.trim(),
//           scheduledDate: _selectedDate!,
//           timeSlot: _selectedSlot!,
//           problemDescription: _descController.text.trim().isNotEmpty
//               ? _descController.text.trim()
//               : null,
//           damagePhotoUrls: _photoPaths,
//           latitude: _latitude,
//           longitude: _longitude,
//           paymentMethod: _paymentMethod,
//           paymentScreenshotLocalPath: _paymentScreenshotPath,
//         );

//     if (!mounted) return;
//     if (booking != null) {
//       await _showSuccessDialog(booking);
//     } else {
//       final error = ref.read(repairBookingNotifierProvider).error;
//       _showError(error ?? 'Booking failed');
//     }
//   }

//   Future<void> _showSuccessDialog(RepairBookingEntity booking) async {
//     await showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         final primary = Theme.of(dialogContext).colorScheme.primary;
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 72,
//                 height: 72,
//                 decoration: BoxDecoration(
//                   color: AppColors.successColor.withAlpha(28),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_circle_rounded,
//                   color: AppColors.successColor,
//                   size: 44,
//                 ),
//               ),
//               const SizedBox(height: 18),
//               Text(
//                 'Booking Confirmed!',
//                 style: Theme.of(
//                   dialogContext,
//                 ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Your ${booking.categoryName} service is booked. '
//                 'It is currently pending — a technician will be assigned soon.',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
//                   color: AppColors.textSecondaryLight,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.warningColor.withAlpha(28),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.schedule_rounded,
//                       size: 16,
//                       color: AppColors.warningColor,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Status: Pending',
//                       style: Theme.of(dialogContext).textTheme.labelMedium
//                           ?.copyWith(
//                             color: AppColors.warningColor,
//                             fontWeight: FontWeight.w700,
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Booking #${booking.id} • Payment via ${booking.paymentMethod}',
//                 style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
//                   color: AppColors.textSecondaryLight,
//                 ),
//               ),
//             ],
//           ),
//           actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           actions: [
//             Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   child: FilledButton.icon(
//                     style: FilledButton.styleFrom(backgroundColor: primary),
//                     onPressed: () {
//                       Navigator.of(dialogContext).pop();
//                       // Replace so the back button returns to the category list,
//                       // not this form.
//                       context.pushReplacement(
//                         RouteNames.repairTracking.replaceFirst(
//                           ':id',
//                           booking.id,
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.timeline_rounded, size: 18),
//                     label: const Text('Track Status'),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 SizedBox(
//                   width: double.infinity,
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.of(dialogContext).pop();
//                       context.go(RouteNames.myRepairs);
//                     },
//                     child: const Text('View in My Bookings'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: AppColors.errorColor),
//     );
//   }

//   // Estimated service charge shown on the QR card. Uses the category's base
//   // charge; the final charge is set by the technician on completion.
//   double _serviceCharge() {
//     final categories = ref.read(repairCategoriesProvider).asData?.value;
//     if (categories != null) {
//       for (final c in categories) {
//         if (c.id == widget.categoryId) return c.baseCharge;
//       }
//     }
//     return 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = ref.watch(repairBookingNotifierProvider).isLoading;

//     return Scaffold(
//       appBar: AppBar(title: Text('Book ${widget.categoryName}')),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             _SectionLabel('Your Address'),
//             const SizedBox(height: 8),
//             LocationAddressField(
//               controller: _addressController,
//               onLocationResolved: (lat, lng) {
//                 setState(() {
//                   _latitude = lat;
//                   _longitude = lng;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             _SectionLabel('Select Date'),
//             const SizedBox(height: 10),
//             SizedBox(
//               height: 80,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _availableDates.length,
//                 itemBuilder: (context, i) {
//                   final date = _availableDates[i];
//                   final isSelected =
//                       _selectedDate != null &&
//                       AppDateUtils.isSameDay(_selectedDate!, date);
//                   return GestureDetector(
//                     onTap: () => setState(() => _selectedDate = date),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       margin: EdgeInsets.only(right: 10, left: i == 0 ? 0 : 0),
//                       width: 60,
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? Theme.of(context).colorScheme.primary
//                             : Theme.of(context).cardColor,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isSelected
//                               ? Theme.of(context).colorScheme.primary
//                               : Theme.of(context).colorScheme.outline,
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             [
//                               'Mon',
//                               'Tue',
//                               'Wed',
//                               'Thu',
//                               'Fri',
//                               'Sat',
//                               'Sun',
//                             ][date.weekday - 1],
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: isSelected ? Colors.white : null,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             '${date.day}',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                               color: isSelected ? Colors.white : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             _SectionLabel('Select Time Slot'),
//             const SizedBox(height: 10),
//             SlotPicker(
//               slots: AppConstants.repairTimeSlots,
//               selectedSlot: _selectedSlot,
//               onSlotSelected: (s) => setState(() => _selectedSlot = s),
//             ),
//             const SizedBox(height: 20),
//             _SectionLabel('Problem Description (Optional)'),
//             const SizedBox(height: 8),
//             AppTextField(
//               controller: _descController,
//               label: 'Describe the issue',
//               hint: 'e.g. Living room switch not working',
//               maxLines: 3,
//             ),
//             const SizedBox(height: 20),
//             _SectionLabel('Upload Damage Photos (Optional)'),
//             const SizedBox(height: 10),
//             DamagePhotoUploader(
//               photoPaths: _photoPaths,
//               onPhotoAdded: (path) => setState(() => _photoPaths.add(path)),
//               onPhotoRemoved: (index) =>
//                   setState(() => _photoPaths.removeAt(index)),
//             ),
//             const SizedBox(height: 20),
//             _SectionLabel('Payment Method'),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: _PaymentOption(
//                     label: 'Cash',
//                     subtitle: 'Pay after service',
//                     icon: Icons.payments_outlined,
//                     selected: _paymentMethod == 'Cash',
//                     onTap: () => setState(() => _paymentMethod = 'Cash'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _PaymentOption(
//                     label: 'QR',
//                     subtitle: 'Pay online',
//                     icon: Icons.qr_code_2_rounded,
//                     selected: _paymentMethod == 'QR',
//                     onTap: () => setState(() => _paymentMethod = 'QR'),
//                   ),
//                 ),
//               ],
//             ),
//             if (_paymentMethod == 'QR') ...[
//               const SizedBox(height: 16),
//               PaymentQrCard(
//                 amount: _serviceCharge(),
//                 screenshotPath: _paymentScreenshotPath,
//                 onScreenshotPicked: (path) =>
//                     setState(() => _paymentScreenshotPath = path),
//                 onScreenshotCleared: () =>
//                     setState(() => _paymentScreenshotPath = null),
//               ),
//             ],
//             const SizedBox(height: 32),
//             AppButton(
//               label: 'Confirm Booking',
//               onPressed: _confirmBooking,
//               isLoading: isLoading,
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SectionLabel extends StatelessWidget {
//   const _SectionLabel(this.text);
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: Theme.of(
//         context,
//       ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
//     );
//   }
// }

// class _PaymentOption extends StatelessWidget {
//   const _PaymentOption({
//     required this.label,
//     required this.subtitle,
//     required this.icon,
//     required this.selected,
//     required this.onTap,
//   });

//   final String label;
//   final String subtitle;
//   final IconData icon;
//   final bool selected;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final primary = Theme.of(context).colorScheme.primary;
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//         decoration: BoxDecoration(
//           color: selected ? primary.withAlpha(20) : Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: selected ? primary : Theme.of(context).colorScheme.outline,
//             width: selected ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: selected ? primary : null, size: 28),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: selected ? primary : null,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               subtitle,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                 color: AppColors.textSecondaryLight,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../payment/presentation/widgets/payment_qr_card.dart';
import '../../domain/entities/repair_category_entity.dart';
import '../providers/repair_categories_provider.dart';
import '../widgets/damage_photo_uploader.dart';
import '../widgets/location_address_field.dart';
import '../widgets/slot_picker.dart';

class RepairBookingScreen extends ConsumerStatefulWidget {
  const RepairBookingScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  ConsumerState<RepairBookingScreen> createState() =>
      _RepairBookingScreenState();
}

class _RepairBookingScreenState extends ConsumerState<RepairBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSlot;
  final List<String> _photoPaths = [];
  double? _latitude;
  double? _longitude;
  // Backend accepts "Cash" | "QR". Defaults to Cash.
  String _paymentMethod = 'Cash';
  // Local path of the QR payment-proof screenshot (uploaded on submit).
  String? _paymentScreenshotPath;

  static final _availableDates = AppDateUtils.nextNDays(7);

  @override
  void dispose() {
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Please select a date');
      return;
    }
    if (_selectedSlot == null) {
      _showError('Please select a time slot');
      return;
    }
    if (_paymentMethod == 'QR' && _paymentScreenshotPath == null) {
      _showError('Please upload your payment screenshot for QR payment');
      return;
    }

    final booking = await ref
        .read(repairBookingNotifierProvider.notifier)
        .createBooking(
          categoryId: widget.categoryId,
          categoryName: widget.categoryName,
          address: _addressController.text.trim(),
          scheduledDate: _selectedDate!,
          timeSlot: _selectedSlot!,
          problemDescription: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          damagePhotoUrls: _photoPaths,
          latitude: _latitude,
          longitude: _longitude,
          paymentMethod: _paymentMethod,
          paymentScreenshotLocalPath: _paymentScreenshotPath,
        );

    if (!mounted) return;
    if (booking != null) {
      await _showSuccessDialog(booking);
    } else {
      final error = ref.read(repairBookingNotifierProvider).error;
      _showError(error ?? 'Booking failed');
    }
  }

  Future<void> _showSuccessDialog(RepairBookingEntity booking) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final primary = Theme.of(dialogContext).colorScheme.primary;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.successColor.withAlpha(28),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successColor,
                  size: 44,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Booking Confirmed!',
                style: Theme.of(
                  dialogContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Your ${booking.categoryName} service is booked. '
                'It is currently pending — a technician will be assigned soon.',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withAlpha(28),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.warningColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Status: Pending',
                      style: Theme.of(dialogContext).textTheme.labelMedium
                          ?.copyWith(
                            color: AppColors.warningColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Booking #${booking.id} • Payment via ${booking.paymentMethod}',
                style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: primary),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      // Replace so the back button returns to the category list,
                      // not this form.
                      context.pushReplacement(
                        RouteNames.repairTracking.replaceFirst(
                          ':id',
                          booking.id,
                        ),
                      );
                    },
                    icon: const Icon(Icons.timeline_rounded, size: 18),
                    label: const Text('Track Status'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go(RouteNames.myRepairs);
                    },
                    child: const Text('View in My Bookings'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.errorColor),
    );
  }

  // Estimated service charge shown on the QR card. Uses the category's base
  // charge; the final charge is set by the technician on completion.
  double _serviceCharge() {
    final categories = ref.read(repairCategoriesProvider).asData?.value;
    if (categories != null) {
      for (final c in categories) {
        if (c.id == widget.categoryId) return c.baseCharge;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(repairBookingNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.categoryName}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel('Your Address'),
            const SizedBox(height: 8),
            LocationAddressField(
              controller: _addressController,
              onLocationResolved: (lat, lng) {
                setState(() {
                  _latitude = lat;
                  _longitude = lng;
                });
              },
            ),
            const SizedBox(height: 20),
            _SectionLabel('Select Date'),
            const SizedBox(height: 12),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableDates.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final date = _availableDates[i];
                  final isSelected =
                      _selectedDate != null &&
                      AppDateUtils.isSameDay(_selectedDate!, date);
                  return _DateCard(
                    date: date,
                    selected: isSelected,
                    onTap: () => setState(() => _selectedDate = date),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Select Time Slot'),
            const SizedBox(height: 10),
            SlotPicker(
              slots: AppConstants.repairTimeSlots,
              selectedSlot: _selectedSlot,
              onSlotSelected: (s) => setState(() => _selectedSlot = s),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Problem Description (Optional)'),
            const SizedBox(height: 8),
            AppTextField(
              controller: _descController,
              label: 'Describe the issue',
              hint: 'e.g. Living room switch not working',
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            _SectionLabel('Upload Damage Photos (Optional)'),
            const SizedBox(height: 10),
            DamagePhotoUploader(
              photoPaths: _photoPaths,
              onPhotoAdded: (path) => setState(() => _photoPaths.add(path)),
              onPhotoRemoved: (index) =>
                  setState(() => _photoPaths.removeAt(index)),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Payment Method'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PaymentOption(
                    label: 'Cash',
                    subtitle: 'Pay after service',
                    icon: Icons.payments_outlined,
                    selected: _paymentMethod == 'Cash',
                    onTap: () => setState(() => _paymentMethod = 'Cash'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PaymentOption(
                    label: 'QR',
                    subtitle: 'Pay online',
                    icon: Icons.qr_code_2_rounded,
                    selected: _paymentMethod == 'QR',
                    onTap: () => setState(() => _paymentMethod = 'QR'),
                  ),
                ),
              ],
            ),
            if (_paymentMethod == 'QR') ...[
              const SizedBox(height: 16),
              PaymentQrCard(
                amount: _serviceCharge(),
                screenshotPath: _paymentScreenshotPath,
                onScreenshotPicked: (path) =>
                    setState(() => _paymentScreenshotPath = path),
                onScreenshotCleared: () =>
                    setState(() => _paymentScreenshotPath = null),
              ),
            ],
            const SizedBox(height: 32),
            AppButton(
              label: 'Confirm Booking',
              onPressed: _confirmBooking,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 66,
        decoration: BoxDecoration(
          color: selected ? primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? primary : Theme.of(context).colorScheme.outline,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weekdays[date.weekday - 1],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white.withAlpha(220)
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _months[date.month - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white.withAlpha(200)
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withAlpha(20) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? primary : Theme.of(context).colorScheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? primary : null, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? primary : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
