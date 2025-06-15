import 'package:beeje_mobile/Auth/address.dart';
import 'package:flutter/material.dart';
import 'package:beeje_mobile/services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService authService = AuthService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Tambahkan variabel untuk menampilkan error
  String? _errorMessage;

  void _register() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
    });
    
    // Validasi input
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Semua field harus diisi';
      });
      return;
    }
    
    // Validasi format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text)) {
      setState(() {
        _errorMessage = 'Format email tidak valid';
      });
      return;
    }
    
    // Validasi nomor telepon (minimal 10 digit)
    if (phoneController.text.length < 10) {
      setState(() {
        _errorMessage = 'Nomor telepon minimal 10 digit';
      });
      return;
    }
    
    // Validasi password (minimal 6 karakter)
    if (passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password minimal 6 karakter';
      });
      return;
    }
    
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password dan konfirmasi password tidak sama';
      });
      return;
    }
    
    try {
      final response = await authService.register(
        nameController.text,
        emailController.text,
        passwordController.text,
        phoneController.text,
      );
      
      // Handle successful registration
      print('Registration successful: ${response['message']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressInput(name: nameController.text),
        ),
      );
    } catch (e) {
      // Handle registration error
      print('Registration failed: $e');
      setState(() {
        _errorMessage = e.toString().contains('Exception:') 
            ? e.toString().split('Exception:')[1].trim() 
            : 'Registrasi gagal: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5B3D25), // Brown background color
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = constraints.maxWidth * 0.1; // Responsive padding
          return SingleChildScrollView( // Wrap with SingleChildScrollView
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Align content to start
                  children: [
                    const SizedBox(height: 40), // Increased height to lower content
                    Image.asset(
                      'assets/images/logo.png',
                      width: constraints.maxWidth * 0.3,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Beeje Coffee",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Mari kami buatkan akun untuk Anda.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(nameController, 'Nama Lengkap', Icons.person),
                    const SizedBox(height: 10),
                    _buildTextField(emailController, 'Email', Icons.email),
                    const SizedBox(height: 10),
                    _buildTextField(phoneController, 'Nomor Handphone', Icons.phone), // New phone field
                    const SizedBox(height: 10),
                    _buildTextField(
                      passwordController,
                      'Kata Sandi',
                      Icons.lock,
                      obscureText: true,
                      isPasswordField: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      confirmPasswordController,
                      'Ulang Kata Sandi',
                      Icons.lock,
                      obscureText: true,
                      isPasswordField: true,
                    ),
                    const SizedBox(height: 80),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF6F4E37),
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Center(
                            child: Text('Kirim'),
                          ), // Teks tetap di tengah
                          const Positioned(
                            right: 0,
                            child: Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF6F4E37),
                            ), // Icon di kanan
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    bool isPasswordField = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText && !(isPasswordField ? _isPasswordVisible : _isConfirmPasswordVisible),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                  isPasswordField
                      ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                      : (_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (isPasswordField) {
                      _isPasswordVisible = !_isPasswordVisible;
                    } else {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    }
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Color(0xFF5B3D25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
