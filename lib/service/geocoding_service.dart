import 'package:geocoding/geocoding.dart';

class GeocodingService {
  /// Converts latitude and longitude to a human-readable address
  static Future<String> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build address string with available components
        List<String> addressComponents = [];

        // Add city/locality if available
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressComponents.add(place.locality!);
        }

        // Add administrative area (state) if available
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressComponents.add(place.administrativeArea!);
        }

        // Add country if available
        if (place.country != null && place.country!.isNotEmpty) {
          addressComponents.add(place.country!);
        }

        // If no specific components, use the formatted address
        if (addressComponents.isEmpty && place.name != null) {
          return place.name!;
        }

        return addressComponents.join(', ');
      }

      return 'Address not found';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Unable to retrieve address';
    }
  }

  /// Gets the city name from coordinates
  static Future<String> getCityFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Return locality (city) if available
        if (place.locality != null && place.locality!.isNotEmpty) {
          return place.locality!;
        }

        // Fallback to subAdministrativeArea if locality is not available
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          return place.subAdministrativeArea!;
        }

        // Fallback to administrativeArea (state) if neither is available
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          return place.administrativeArea!;
        }
      }

      return 'Unknown location';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Location unavailable';
    }
  }
}
