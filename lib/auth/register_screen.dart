import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _hidePass = true;

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF92487A)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFFE49BA6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF92487A), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _show("Name, email & password required.");
      return;
    }

    if (pass.length < 6) {
      _show("Password must be at least 6 characters.");
      return;
    }

    setState(() => _loading = true);
    final res = await _auth.register(
      email: email,
      password: pass,
      name: name,
      phone: phone,
    );
    setState(() => _loading = false);

    if (res == null) {
      _show("Registration successful!");
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _show(res);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5EC), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF92487A)),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 5),
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92487A),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("Fill your information below", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextField(controller: _nameCtrl, decoration: _inputStyle("Name")),
              const SizedBox(height: 15),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: _inputStyle("Email")),
              const SizedBox(height: 15),
              TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: _inputStyle("Phone No.")),
              const SizedBox(height: 15),
              TextField(
                controller: _passCtrl,
                obscureText: _hidePass,
                decoration: _inputStyle("Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF92487A)),
                    onPressed: () => setState(() => _hidePass = !_hidePass),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF92487A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Next", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
