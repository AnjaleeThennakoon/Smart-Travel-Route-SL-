import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../routers/app_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _hidePass = true;
  bool _hideConfirm = true;
  String? _selectedCountry;
  String _countryCode = '+94';
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    // API එකෙන් රටවල් ලැයිස්තුව ලබා ගැනීම
    _countries = ApiService.getCountries();
  }

  // මෙහිදී validation logic එක FormField තුළටම ගෙන ගොස් ඇත
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCountry == null) {
        _showSnackBar('Please select your country', Colors.orange);
        return;
      }

      setState(() => _isLoading = true);

      try {
        final result = await ApiService.registerUser(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          country: _selectedCountry!,
          countryCode: _countryCode,
          mobileNumber: _mobileCtrl.text.trim(),
          password: _passCtrl.text,
        );

        if (mounted) {
          setState(() => _isLoading = false);
          if (result['success'] == true) {
            _showSnackBar('Registration successful!', Colors.green);
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else {
            _showErrorDialog(result['message'] ?? 'Registration failed.');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorDialog('Connection error. Please check your internet.');
        }
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/login.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 30),
                      _buildRegistrationCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        const Text(
          'Ayubo',
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Text(
          'START YOUR JOURNEY',
          style: TextStyle(color: Colors.white.withOpacity(0.8), letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'Create Account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 20),
          
          // Name Field
          _buildTextField(
            controller: _nameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (v) => v!.length < 3 ? 'Enter at least 3 characters' : null,
          ),
          
          const SizedBox(height: 16),
          
          // Email Field
          _buildTextField(
            controller: _emailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => !v!.contains('@') ? 'Enter a valid email' : null,
          ),
          
          const SizedBox(height: 16),

          // Country Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCountry,
            decoration: _inputDecoration('Country', Icons.public),
            items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() {
              _selectedCountry = val;
              _countryCode = ApiService.getCountryCode(val!);
            }),
          ),
          
          const SizedBox(height: 16),

          // Mobile Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_countryCode, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _mobileCtrl,
                  label: 'Mobile Number',
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 9 ? 'Invalid number' : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // Password
          _buildTextField(
            controller: _passCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: _hidePass,
            suffixIcon: IconButton(
              icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _hidePass = !_hidePass),
            ),
            validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
          ),
          
          const SizedBox(height: 16),

          // Confirm Password
          _buildTextField(
            controller: _confirmCtrl,
            label: 'Confirm Password',
            icon: Icons.lock_reset,
            obscure: _hideConfirm,
            suffixIcon: IconButton(
              icon: Icon(_hideConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
            ),
            validator: (v) => v != _passCtrl.text ? 'Passwords do not match' : null,
          ),

          const SizedBox(height: 25),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          
          _buildSignInLink(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label, icon).copyWith(suffixIcon: suffixIcon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.login),
          child: const Text('Sign In', style: TextStyle(color: Color(0xFF3498DB), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Oops!'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }
}