import 'package:finalproject/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'create_group_page.dart';
import 'services/database_service.dart';

class JoinGroupPage extends StatefulWidget {
  final String userName;
  const JoinGroupPage({
    super.key,
    this.userName = 'User',
  });

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  int _selectedIndex = 1;
  bool _obscurePassword = true;

  final TextEditingController _groupIdController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);
  final Color _background = const Color(0xFFFFFFFF);
  final Color _inputBorder = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _groupIdController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        AppRoute.fade(const DashboardPage()),
            (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        AppRoute.fade(const CreateGroupPage()),
            (route) => false,
      );
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Hi ${widget.userName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            Text(
              'Join Group',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: _navy,
                fontFamily: 'Serif',
              ),
            ),

            const SizedBox(height: 40),

            // GROUP ID FIELD
            _label("Group ID"),
            const SizedBox(height: 8),
            _textField(
              hint: "Enter Group ID",
              controller: _groupIdController,
            ),

            const SizedBox(height: 24),

            // PASSWORD FIELD
            _label("Password"),
            const SizedBox(height: 8),
            _textField(
              hint: "........",
              controller: _passController,
              obscure: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),

            const SizedBox(height: 60),

            // JOIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_groupIdController.text.trim().isEmpty ||
                      _passController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  String? result = await DatabaseService().joinGroup(
                    _groupIdController.text.trim(), // now groupId
                    _passController.text.trim(),
                  );

                  if (!mounted) return;

                  if (result == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Joined Group Successfully!')),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      AppRoute.fade(const DashboardPage()),
                          (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Join',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _navy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: _navy,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? _gold.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  color: _selectedIndex == 1 ? _gold : Colors.white,
                ),
              ),
              label: "Join Group",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: "Create Group",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: _gold,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  // LABEL
  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: _navy,
      ),
    ),
  );

  // CUSTOM TEXTFIELD
  Widget _textField({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFDFDFD),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          borderSide: BorderSide(color: _navy, width: 1.6),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
