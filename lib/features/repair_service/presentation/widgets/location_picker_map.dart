import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LocationPickerMap extends StatelessWidget {
  const LocationPickerMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationPicked,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final void Function(double lat, double lng) onLocationPicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map_outlined, size: 48, color: AppColors.primaryLight),
          const SizedBox(height: 12),
          Text(
            'Tap to share your location',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => onLocationPicked(27.7172, 85.3240),
            icon: const Icon(Icons.my_location_rounded, size: 18),
            label: const Text('Use My Location'),
          ),
        ],
      ),
    );
  }
}
