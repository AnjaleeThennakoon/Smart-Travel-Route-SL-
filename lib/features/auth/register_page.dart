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

  // Field error messages
  String? _nameError;
  String? _emailError;
  String? _countryError;
  String? _mobileError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    _countries = ApiService.getCountries();
  }

  void _updateCountryCode(String? country) {
    setState(() {
      _selectedCountry = country;
      _countryError = null;
      if (country != null) {
        _countryCode = ApiService.getCountryCode(country);
      }
    });
  }

  // Real-time validation for each field
  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Please enter your full name';
      } else if (value.length < 3) {
        _nameError = 'Name must be at least 3 characters';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Please enter your email';
      } else if (!value.contains('@') || !value.contains('.')) {
        _emailError = 'Enter a valid email address';
      } else {
        _emailError = null;
      }
    });
  }

  void _validateMobile(String value) {
    setState(() {
      if (value.isEmpty) {
        _mobileError = 'Please enter mobile number';
      } else if (value.length < 9) {
        _mobileError = 'Enter valid mobile number';
      } else {
        _mobileError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Please enter password';
      } else if (value.length < 6) {
        _passwordError = 'Password must be 6+ characters';
      } else {
        _passwordError = null;
      }

      // Also validate confirm password if it has value
      if (_confirmCtrl.text.isNotEmpty) {
        if (_confirmCtrl.text != value) {
          _confirmError = 'Passwords do not match';
        } else {
          _confirmError = null;
        }
      }
    });
  }

  void _validateConfirm(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmError = 'Please confirm your password';
      } else if (value != _passCtrl.text) {
        _confirmError = 'Passwords do not match';
      } else {
        _confirmError = null;
      }
    });
  }

  // Show Success Dialog and navigate to login
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text(
                'Registration Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Your account has been created successfully.\nPlease login to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, AppRouter.login);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, AppRouter.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Show Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: const [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              SizedBox(height: 10),
              Text(
                'Registration Failed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    // Check all fields before submission
    bool isValid = true;

    if (_nameCtrl.text.isEmpty) {
      _nameError = 'Please enter your full name';
      isValid = false;
    } else if (_nameCtrl.text.length < 3) {
      _nameError = 'Name must be at least 3 characters';
      isValid = false;
    } else {
      _nameError = null;
    }

    if (_emailCtrl.text.isEmpty) {
      _emailError = 'Please enter your email';
      isValid = false;
    } else if (!_emailCtrl.text.contains('@') ||
        !_emailCtrl.text.contains('.')) {
      _emailError = 'Enter a valid email address';
      isValid = false;
    } else {
      _emailError = null;
    }

    if (_selectedCountry == null) {
      _countryError = 'Please select your country';
      isValid = false;
    } else {
      _countryError = null;
    }

    if (_mobileCtrl.text.isEmpty) {
      _mobileError = 'Please enter mobile number';
      isValid = false;
    } else if (_mobileCtrl.text.length < 9) {
      _mobileError = 'Enter valid mobile number';
      isValid = false;
    } else {
      _mobileError = null;
    }

    if (_passCtrl.text.isEmpty) {
      _passwordError = 'Please enter password';
      isValid = false;
    } else if (_passCtrl.text.length < 6) {
      _passwordError = 'Password must be 6+ characters';
      isValid = false;
    } else {
      _passwordError = null;
    }

    if (_confirmCtrl.text.isEmpty) {
      _confirmError = 'Please confirm your password';
      isValid = false;
    } else if (_confirmCtrl.text != _passCtrl.text) {
      _confirmError = 'Passwords do not match';
      isValid = false;
    } else {
      _confirmError = null;
    }

    setState(() {});

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
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
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration successful!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );

          // DIRECTLY GO TO HOME PAGE (NOT LOGIN)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRouter.home);
            }
          });
        } else {
          _showErrorDialog(
            result['message'] ?? 'Registration failed. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Something went wrong. Please try again.');
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/login.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const Text(
                                  'Ayubo',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Full Name Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(
                                      _nameCtrl,
                                      'Full Name',
                                      Icons.person,
                                      onChanged: _validateName,
                                    ),
                                    if (_nameError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 5,
                                        ),
                                        child: Text(
                                          _nameError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                // Email Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(
                                      _emailCtrl,
                                      'Email',
                                      Icons.email,
                                      isEmail: true,
                                      onChanged: _validateEmail,
                                    ),
                                    if (_emailError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 5,
                                        ),
                                        child: Text(
                                          _emailError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                // Country Dropdown
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      initialValue: _selectedCountry,
                                      hint: const Text('Select Country'),
                                      decoration: _inputDecoration(
                                        'Country',
                                        Icons.public,
                                      ),
                                      items: _countries.map((country) {
                                        return DropdownMenuItem(
                                          value: country,
                                          child: Text(
                                            '$country (${ApiService.getCountryCode(country)})',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: _updateCountryCode,
                                    ),
                                    if (_countryError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 5,
                                        ),
                                        child: Text(
                                          _countryError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                // Mobile Number
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: TextFormField(
                                            initialValue: _countryCode,
                                            enabled: false,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: _inputDecoration(
                                              'Code',
                                              Icons.code,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildField(
                                            _mobileCtrl,
                                            'Phone',
                                            Icons.phone,
                                            onChanged: _validateMobile,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_mobileError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 5,
                                        ),
                                        child: Text(
                                          _mobileError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                // Password
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(
                                      _passCtrl,
                                      'Password',
                                      Icons.lock,
                                      isPassword: true,
                                      obscure: _hidePass,
                                      toggle: () => setState(
                                        () => _hidePass = !_hidePass,
                                      ),
                                      onChanged: _validatePassword,
                                    ),
                                    if (_passwordError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 5,
                                        ),
                                        child: Text(
                                          _passwordError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 15),

                                // Confirm Password
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField(
                                      _confirmCtrl,
                                      'Confirm Password',
                                      Icons.lock,
                                      isPassword: true,
                                      obscure: _hideConfirm,
                                      toggle: () => setState(
                                        () => _hideConfirm = !_hideConfirm,
                                      ),
                                      onChanged: _validateConfirm,
                                    ),
                                    if (_confirmError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          top: 5,
                                        ),
                                        child: Text(
                                          _confirmError!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 25),

                                // Create Account Button
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C3E50),
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                ),
                                const SizedBox(height: 15),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have account?",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pushReplacementNamed(
                                            context,
                                            AppRouter.login,
                                          ),
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Color(0xFF3498DB),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isEmail = false,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggle,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      onChanged: onChanged,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: _inputDecoration(
        label,
        icon,
        suffix: toggle != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: toggle,
              )
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
