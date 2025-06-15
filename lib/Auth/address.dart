import 'package:beeje_mobile/Auth/loginpage.dart';
import 'package:beeje_mobile/Auth/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddressInput extends StatefulWidget {
  final String name;
  const AddressInput({super.key, required this.name});

  @override
  State<AddressInput> createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
  final _nameController = TextEditingController();
  final _provinceController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  
  // Add map-related fields
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(5.1880, 97.1411);
  LatLng? _selectedLocation;
  String _address = '';
  String _selectedProvince = '';
  String _selectedCity = '';
  String _selectedDistrict = '';
  String _selectedPostalCode = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
  
  }

  @override
  void dispose() {
    _nameController.dispose();
    _provinceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC67C4E)),
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provinsi,Kota,Kecamatan,Kode Pos',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'SoraSemiBold',
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPicker(
                  onLocationSelected: (address, lat, lng) {
                    setState(() {
                      // Assuming the address is returned as a formatted string
                      List<String> addressParts = address.split(',');
                      _provinceController.text = addressParts.length > 0 ? addressParts[0].trim() : '';
                      _selectedCity = addressParts.length > 1 ? addressParts[1].trim() : '';
                      _selectedDistrict = addressParts.length > 2 ? addressParts[2].trim() : '';
                      _selectedPostalCode = addressParts.length > 3 ? addressParts[3].trim() : '';
                    });
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _provinceController.text.isEmpty
                        ? 'Pilih Lokasi di Peta'
                        : '${_provinceController.text}, $_selectedCity, $_selectedDistrict, $_selectedPostalCode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty ||
        _provinceController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Here you can add your API call or data processing
      await Future.delayed(const Duration(seconds: 1)); // Simulated API call

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF432E1C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hampir Sampai!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'SoraSemiBold',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lengkapi detail Anda dan verifikasi email Anda',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'SoraRegular',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'ALAMAT',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'SoraSemiBold',
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('NAMA LENGKAP', Icons.person_outline, _nameController),
              const SizedBox(height: 16),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildTextField('Alamat Lengkap', Icons.home, _addressController), // Editable field
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF432E1C)),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Lanjut',
                              style: TextStyle(
                                color: Color(0xFF432E1C),
                                fontSize: 16,
                                fontFamily: 'SoraSemiBold',
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF432E1C),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}