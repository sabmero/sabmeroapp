import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Address input that lets the user either fetch their real live location
/// (with full permission / service handling) or type the address manually.
///
/// The text field is always editable so manual entry remains available even
/// when location permission is denied.
class LocationAddressField extends ConsumerStatefulWidget {
  const LocationAddressField({
    super.key,
    required this.controller,
    required this.onLocationResolved,
  });

  final TextEditingController controller;

  /// Called with the resolved coordinates when the user shares live location.
  /// Passes null/null if the user clears or only types manually.
  final void Function(double? latitude, double? longitude) onLocationResolved;

  @override
  ConsumerState<LocationAddressField> createState() =>
      _LocationAddressFieldState();
}

class _LocationAddressFieldState extends ConsumerState<LocationAddressField> {
  static const _locationService = LocationService();
  bool _isFetching = false;
  bool _usingLiveLocation = false;

  Future<void> _useMyLocation() async {
    setState(() => _isFetching = true);
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _isFetching = false);

    switch (result.status) {
      case LocationStatus.success:
        widget.controller.text =
            result.address ??
            '${result.latitude!.toStringAsFixed(5)}, '
                '${result.longitude!.toStringAsFixed(5)}';
        widget.onLocationResolved(result.latitude, result.longitude);
        setState(() => _usingLiveLocation = true);
        _showSnack('Live location added', AppColors.successColor);
        break;
      case LocationStatus.serviceDisabled:
        _showServiceDisabledDialog();
        break;
      case LocationStatus.permissionDenied:
        _showSnack(
          'Location permission denied. Please allow it or enter your '
          'address manually below.',
          AppColors.warningColor,
        );
        break;
      case LocationStatus.permissionDeniedForever:
        _showPermissionDeniedForeverDialog();
        break;
      case LocationStatus.failed:
        _showSnack(
          'Could not get your location. Please enter your address manually.',
          AppColors.errorColor,
        );
        break;
    }
  }

  void _showServiceDisabledDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Turn on Location'),
        content: const Text(
          'Your device location is turned off. Please enable it to share '
          'your real location, or close this and enter your address manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Enter Manually'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _locationService.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Location Permission Needed'),
        content: const Text(
          'Location permission is permanently denied. Open settings to enable '
          'it, or close this and enter your address manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Enter Manually'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _locationService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: widget.controller,
          label: 'Full Address',
          hint: 'Street, Area, City',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 2,
          onChanged: (_) {
            // Editing manually drops the previously attached live coordinates.
            if (_usingLiveLocation) {
              setState(() => _usingLiveLocation = false);
              widget.onLocationResolved(null, null);
            }
          },
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Address is required' : null,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isFetching ? null : _useMyLocation,
                icon: _isFetching
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded, size: 18),
                label: Text(
                  _isFetching ? 'Getting location...' : 'Use My Location',
                ),
              ),
            ),
            if (_usingLiveLocation) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.successColor,
                size: 22,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _usingLiveLocation
              ? 'Live location attached. You can still edit the address above.'
              : 'Share your real location or type your address manually.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
