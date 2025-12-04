import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  // Colors
  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);
  final Color _white = Colors.white;
  final Color _inputBorder = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Padding(
            padding:
            const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create new account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // CONTENT CARD
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EMAIL
                    _label("Email Address"),
                    const SizedBox(height: 8),
                    _textField(
                      hint: "you@example.com",
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    _label("Password"),
                    const SizedBox(height: 8),
                    _textField(
                      hint: "••••••••",
                      controller: _password,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CONFIRM PASSWORD
                    _label("Confirm Password"),
                    const SizedBox(height: 8),
                    _textField(
                      hint: "••••••••",
                      controller: _confirm,
                      obscure: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // SIGN UP BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    const SizedBox(height: 20),

                    // FOOTER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: _gold, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: _navy,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FORM LOGIC
  Future<void> _handleSignup() async {
    final auth = AuthService();

    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final error = await auth.signUp(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account created successfully!")),
    );

    Navigator.pop(context); // kembali ke login
  }

  // LABEL
  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _navy,
      ),
    );
  }

  // TEXT FIELD
  Widget _textField({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _navy, width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
