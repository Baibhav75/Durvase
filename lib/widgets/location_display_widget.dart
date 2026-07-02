import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/geocoding_service.dart';

class LocationDisplayWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String locationName;
  final bool isLocating;
  final VoidCallback? onRefresh;

  const LocationDisplayWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.locationName = "Current Location",
    this.isLocating = false,
    this.onRefresh,
  });

  @override
  State<LocationDisplayWidget> createState() => _LocationDisplayWidgetState();
}

class _LocationDisplayWidgetState extends State<LocationDisplayWidget> {
  String? _address;
  bool _isGettingAddress = false;

  @override
  void didUpdateWidget(covariant LocationDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If latitude/longitude changed, fetch new address
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _fetchAddress();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    if (widget.latitude == null || widget.longitude == null) return;

    setState(() {
      _isGettingAddress = true;
      _address = null;
    });

    try {
      final address = await GeocodingService.getAddressFromCoordinates(
        widget.latitude!,
        widget.longitude!,
      );

      if (mounted) {
        setState(() {
          _address = address;
          _isGettingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'Unable to retrieve address';
          _isGettingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.locationName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              if (widget.latitude != null && widget.longitude != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Acquired",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.isLocating) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[700]!,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Getting your location...",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ] else if (widget.latitude != null && widget.longitude != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Latitude:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        widget.latitude!.toStringAsFixed(6),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Longitude:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        widget.longitude!.toStringAsFixed(6),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Show address if available
                  if (_address != null) ...[
                    Divider(height: 16, color: Colors.grey[300]),
                    Row(
                      children: [
                        Icon(Icons.place, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _address!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else if (_isGettingAddress) ...[
                    Divider(height: 16, color: Colors.grey[300]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue[700]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Getting address...",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                const SizedBox(width: 6),
                Text(
                  "Location captured successfully",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_off,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Location not available",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Unable to get your current location. Please ensure location services are enabled.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onRefresh != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: widget.onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Refresh Location",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
