import 'package:beeje_mobile/Auth/loginpage.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService authService = AuthService();
  User? userProfile;
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() => isLoading = true);
      final profileData = await authService.getUserProfile();
      
      if (profileData != null) {
        setState(() {
          userProfile = User.fromJson(profileData);
          nameController.text = userProfile?.name ?? '';
          emailController.text = userProfile?.email ?? '';
          phoneController.text = userProfile?.phone ?? '';
          isLoading = false;
        });
      } else {
        throw Exception('Profile data is null');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoading = false;
        userProfile = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveUserProfile() async {
    try {
      final updatedProfile = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };
      await authService.updateUserProfile(updatedProfile);

      // Update state after successful update
      setState(() {
        userProfile = User(
          id: userProfile!.id,
          name: nameController.text,
          email: emailController.text,
          role: userProfile!.role,
          phone: phoneController.text,
          createdAt: userProfile!.createdAt,
          updatedAt: DateTime.now(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          isDense: true,
        ),
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.isEmpty || phone.length < 4) return phone;
    return phone.replaceRange(3, phone.length - 2, '*' * (phone.length - 5));
  }

  Future<void> _openWhatsApp() async {
    if (userProfile?.phone == null || userProfile!.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor telepon tidak tersedia')),
      );
      return;
    }

    // Format nomor telepon (pastikan dimulai dengan kode negara)
    String phone = userProfile!.phone!;
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (!phone.startsWith('62')) {
      phone = '6288016873238';
    }

    // Buat URL WhatsApp
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phone');

    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userProfile == null) {
      return const Center(child: Text('Failed to load profile'));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
           
              const SizedBox(height: 10),
              const Text(
                'Profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile!.name ?? 'Nama Tidak Diketahui',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          _maskPhone(userProfile!.phone ?? ''),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildTextField("Nama", nameController),
              _buildTextField("Email", emailController),
              _buildTextField("Nomor Handphone", phoneController),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _saveUserProfile,
                child: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  textStyle: const TextStyle(fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('Chat via WhatsApp', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  textStyle: const TextStyle(fontSize: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  bool shouldLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Keluar'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Keluar'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout) {
                    try {
                      await authService.logout();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal logout')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Keluar', style: TextStyle(fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
