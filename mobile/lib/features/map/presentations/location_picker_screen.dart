import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selected;
  final _mapController = MapController();
  bool _gettingLocation = false;

  static const _defaultCenter = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  Future<void> _useMyLocation() async {
    setState(() => _gettingLocation = true);
    final pos = await _tryGetLocation();
    if (!mounted) return;
    if (pos != null) {
      final ll = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = ll);
      _mapController.move(ll, 17);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengakses lokasi. Pastikan GPS aktif.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() => _gettingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Toko',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selected != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: const Text(
                'Konfirmasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selected ?? _defaultCenter,
              initialZoom: _selected != null ? 16.0 : 13.0,
              onTap: (_, ll) => setState(() => _selected = ll),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arudocare.app',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 48,
                      height: 56,
                      child: const Column(
                        children: [
                          Icon(Icons.location_pin, color: kPrimaryColor, size: 44),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.touch_app_outlined, size: 18, color: kPrimaryColor),
                  SizedBox(width: 8),
                  Text('Tap di peta untuk menentukan lokasi toko',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: _selected != null ? 100 : 24,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'gps_btn',
              onPressed: _gettingLocation ? null : _useMyLocation,
              backgroundColor: Colors.white,
              elevation: 4,
              child: _gettingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kPrimaryColor),
                    )
                  : const Icon(Icons.my_location, color: kPrimaryColor),
            ),
          ),

          if (_selected != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context, _selected),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'Konfirmasi Lokasi  (${_selected!.latitude.toStringAsFixed(5)}, ${_selected!.longitude.toStringAsFixed(5)})',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<Position?> _tryGetLocation() async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  } catch (_) {
    return null;
  }
}
