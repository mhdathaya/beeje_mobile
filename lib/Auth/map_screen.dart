import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPicker extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;

  const LocationPicker({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  bool _isLoading = false;
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(5.1880, 97.1411); // Lhokseumawe coordinates
  LatLng? _selectedLocation;
  String _address = '';
  String _selectedProvince = '';
  String _selectedCity = '';
  String _selectedDistrict = '';
  String _selectedPostalCode = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable location services.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied. Please enable them in settings.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      // Handle permanently denied permissions
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in settings.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _selectedLocation = _center;
        });
        _mapController.move(_center, 15);
        await _getAddressFromLatLng(_center);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedProvince = place.administrativeArea ?? '';
          _selectedCity = place.subAdministrativeArea ?? '';
          _selectedDistrict = place.locality ?? '';
          _selectedPostalCode = place.postalCode ?? '';
          _address = '${place.street}, ${place.subLocality}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Widget _buildAddressDetails() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Gunakan Lokasi Saat Ini',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: Text(_selectedProvince),
            initiallyExpanded: true,
            textColor: Colors.black87,
            iconColor: Colors.black87,
            children: [
              ListTile(title: Text(_selectedCity)),
              if (_selectedDistrict.isNotEmpty)
                ListTile(title: Text(_selectedDistrict)),
            ],
          ),
          if (_address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Alamat Lengkap: $_address'), // Changed to include 'Alamat Lengkap'
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF432E1C),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _selectedLocation != null ? () {
                widget.onLocationSelected(
                  '$_selectedProvince, $_selectedCity, $_selectedDistrict\n$_address',
                  _selectedLocation!.latitude,
                  _selectedLocation!.longitude,
                );
                Navigator.pop(context);
              } : null,
              child: const Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        backgroundColor: const Color(0xFF432E1C),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onTap: (tapPosition, point) async {
                setState(() {
                  _selectedLocation = point;
                });
                await _getAddressFromLatLng(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.beejee_mobile',
              ),
              MarkerLayer(
                markers: _selectedLocation == null ? [] : [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_address.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildAddressDetails(),
            ),
        ],
      ),
    );
  }
}