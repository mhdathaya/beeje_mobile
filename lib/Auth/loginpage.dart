import 'package:beeje_mobile/Auth/register.dart';
import 'package:flutter/material.dart';
import 'package:beeje_mobile/services/auth_service.dart';
import 'package:beeje_mobile/Pages/home_page.dart'; // Import HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false; // State to manage password visibility
void _login() async {
  try {
    final response = await authService.login(
      emailController.text,
      passwordController.text,
    );

    if (response['success']) {
      final String userName = response['user']['name'];
      print('Login successful: ${response['message']}');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userName: userName),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    print('Login failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login gagal: $e'),
        backgroundColor: Colors.red,
      ),
    );
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Adjusted height for alignment
                    Image.asset(
                      'assets/images/logo.png',
                      width: constraints.maxWidth * 0.3, // Adjusted logo size
                    ),
                    const SizedBox(height: 10), // Adjusted height for alignment
                    Text(
                      "Beeje Coffee",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Adjusted font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Kita sudah bertemu!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(emailController, 'Email', Icons.email),
                    const SizedBox(height: 10),
                    _buildTextField(phoneController, 'Nomor Handphone', Icons.phone),
                    const SizedBox(height: 10),
                    _buildTextField(passwordController, 'Kata Sandi', Icons.lock, obscureText: true),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Navigate to forgot password page
                      },
                      child: const Text(
                        'Lupa Kata Sandi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Masuk'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color(0xFF6F4E37), backgroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                        // Navigate to registration page
                      },
                      child: const Text(
                        'Belum Punya Akun? Daftar',
                        style: TextStyle(color: Colors.white),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText && !_isPasswordVisible, // Toggle visibility
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14, // Adjusted font size
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: obscureText
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Color(0xFF5B3D25), // Adjusted fill color to match design
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white, // Adjusted border color
            width: 1.5, // Adjusted border width
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white, // Adjusted border color
            width: 1.5, // Adjusted border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white, // Adjusted border color
            width: 1.5, // Adjusted border width
          ),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}