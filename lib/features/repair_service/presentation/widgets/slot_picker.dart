// import 'package:flutter/material.dart';

// class SlotPicker extends StatelessWidget {
//   const SlotPicker({
//     super.key,
//     required this.slots,
//     required this.selectedSlot,
//     required this.onSlotSelected,
//   });

//   final List<String> slots;
//   final String? selectedSlot;
//   final void Function(String) onSlotSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: slots.map((slot) {
//         final isSelected = selectedSlot == slot;
//         return GestureDetector(
//           onTap: () => onSlotSelected(slot),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? Theme.of(context).colorScheme.primary
//                   : Theme.of(context).cardColor,
//               border: Border.all(
//                 color: isSelected
//                     ? Theme.of(context).colorScheme.primary
//                     : Theme.of(context).colorScheme.outline,
//               ),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               slot,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: isSelected ? Colors.white : null,
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A premium, two-step time picker. The user first picks a period
/// (Morning / Afternoon / Evening); only then do the matching slots reveal,
/// keeping the screen calm instead of showing a wall of nine boxes at once.
class SlotPicker extends StatefulWidget {
  const SlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final List<String> slots;
  final String? selectedSlot;
  final void Function(String) onSlotSelected;

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

enum _Period { morning, afternoon, evening }

class _SlotPickerState extends State<SlotPicker> {
  _Period? _period;

  @override
  void initState() {
    super.initState();
    // If a slot is already chosen (e.g. returning to the form), expand its
    // period so the selection stays visible.
    if (widget.selectedSlot != null) {
      _period = _periodOf(widget.selectedSlot!);
    }
  }

  _Period _periodOf(String slot) {
    final hour = _hour24(slot);
    if (hour < 12) return _Period.morning;
    if (hour < 17) return _Period.afternoon;
    return _Period.evening;
  }

  int _hour24(String slot) {
    // Expects formats like "09:00 AM" / "02:00 PM".
    final parts = slot.trim().split(' ');
    var hour = int.tryParse(parts.first.split(':').first) ?? 0;
    final meridiem = parts.length > 1 ? parts[1].toUpperCase() : '';
    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    return hour;
  }

  List<String> get _slotsForPeriod {
    if (_period == null) return const [];
    return widget.slots.where((s) => _periodOf(s) == _period).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _PeriodTab(
              label: 'Morning',
              icon: Icons.wb_twilight_rounded,
              selected: _period == _Period.morning,
              onTap: () => setState(() => _period = _Period.morning),
            ),
            const SizedBox(width: 10),
            _PeriodTab(
              label: 'Afternoon',
              icon: Icons.wb_sunny_rounded,
              selected: _period == _Period.afternoon,
              onTap: () => setState(() => _period = _Period.afternoon),
            ),
            const SizedBox(width: 10),
            _PeriodTab(
              label: 'Evening',
              icon: Icons.nightlight_round,
              selected: _period == _Period.evening,
              onTap: () => setState(() => _period = _Period.evening),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _period == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _slotsForPeriod.map((slot) {
                      final isSelected = widget.selectedSlot == slot;
                      return _SlotChip(
                        label: slot,
                        selected: isSelected,
                        onTap: () => widget.onSlotSelected(slot),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
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
    final primary = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? primary.withAlpha(20)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? primary : Theme.of(context).colorScheme.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: selected ? primary : null),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? primary : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary : Theme.of(context).cardColor,
          border: Border.all(
            color: selected ? primary : Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
