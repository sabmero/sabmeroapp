import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';

/// Outcome of a location request, so the UI can react appropriately.
enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  failed,
}

class LocationResult {
  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? address;

  const LocationResult({
    required this.status,
    this.latitude,
    this.longitude,
    this.address,
  });
}

/// Handles location permission, service-enabled checks, live position
/// fetching, and reverse geocoding for the app.
class LocationService {
  const LocationService();

  /// Whether the device location service (GPS) is turned on.
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// Opens the OS location settings so the user can switch GPS on.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Opens the app settings so the user can grant a permanently denied
  /// permission.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Requests permission (if needed) and returns the current position with a
  /// best-effort reverse-geocoded address.
  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning('Location service disabled', tag: 'LocationService');
        return const LocationResult(status: LocationStatus.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationStatus.permissionDeniedForever,
        );
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult(status: LocationStatus.permissionDenied);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final address = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      AppLogger.info(
        'Location resolved: ${position.latitude}, ${position.longitude}',
        tag: 'LocationService',
      );

      return LocationResult(
        status: LocationStatus.success,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to get current location',
        tag: 'LocationService',
        error: e,
        stackTrace: st,
      );
      return const LocationResult(status: LocationStatus.failed);
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = <String>[
        if ((p.name ?? '').isNotEmpty && p.name != p.street) p.name!,
        if ((p.street ?? '').isNotEmpty) p.street!,
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
        if ((p.locality ?? '').isNotEmpty) p.locality!,
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
      ];
      // Deduplicate while preserving order.
      final seen = <String>{};
      final unique = parts.where((e) => seen.add(e)).toList();
      return unique.isEmpty ? null : unique.join(', ');
    } catch (e) {
      AppLogger.warning('Reverse geocoding failed: $e', tag: 'LocationService');
      return null;
    }
  }
}
