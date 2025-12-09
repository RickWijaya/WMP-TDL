import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_to_do_list/routes/app_route.dart';
import 'dashboard_page.dart';
import 'join_group_page.dart';
import 'services/database_service.dart';

class CreateGroupPage extends StatefulWidget {
  final String userName;

  const CreateGroupPage({
    super.key,
    this.userName = 'User',
  });

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  String get _displayUserName {
    if (widget.userName != 'User' && widget.userName.trim().isNotEmpty) {
      return widget.userName;
    }
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'User';
  }

  int _selectedIndex = 2;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Theme list (8 themes)
  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Navy',
      'color': const Color(0xFF1A2342),
      'hex': '0xFF1A2342',
    },
    {
      'name': 'Gold',
      'color': const Color(0xFFE0A938),
      'hex': '0xFFE0A938',
    },
    {
      'name': 'Emerald',
      'color': const Color(0xFF16A34A),
      'hex': '0xFF16A34A',
    },
    {
      'name': 'Indigo',
      'color': const Color(0xFF4F46E5),
      'hex': '0xFF4F46E5',
    },
    {
      'name': 'Crimson',
      'color': const Color(0xFFB91C1C),
      'hex': '0xFFB91C1C',
    },
    {
      'name': 'Teal',
      'color': const Color(0xFF0F766E),
      'hex': '0xFF0F766E',
    },
    {
      'name': 'Orange',
      'color': const Color(0xFFF97316),
      'hex': '0xFFF97316',
    },
    {
      'name': 'Slate',
      'color': const Color(0xFF1E293B),
      'hex': '0xFF1E293B',
    },
  ];

  int _selectedThemeIndex = 0;

  // Colors
  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);
  final Color _background = const Color(0xFFF5F5F5);
  final Color _inputBorder = const Color(0xFFE0E0E0);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        // Home → Dashboard (fade, bawa nama)
        Navigator.pushAndRemoveUntil(
          context,
          AppRoute.fade(
            DashboardPage(userName: widget.userName),
          ),
              (route) => false,
        );
      } else if (index == 1) {
        // Go to Join Group (slide from right)
        Navigator.pushAndRemoveUntil(
          context,
          AppRoute.fade(
            JoinGroupPage(userName: widget.userName),
          ),
              (route) => false,
        );
      }
      // index 2 = this page
    });
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
          'Hi $_displayUserName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Create Group',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _navy,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 40),

              // Group Name
              _buildLabel('Group Name'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Project Alpha',
                controller: _nameController,
              ),

              const SizedBox(height: 20),

              // Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Short description...',
                controller: _descController,
              ),

              const SizedBox(height: 20),

              // Group Theme
              _buildLabel('Group Theme'),
              const SizedBox(height: 8),
              _buildThemeDropdown(),

              const SizedBox(height: 20),

              // Password
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: '........',
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

              const SizedBox(height: 20),

              // Confirm Password
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: '........',
                controller: _confirmPassController,
                obscure: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Button Create
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty ||
                        _passController.text.trim().isEmpty ||
                        _confirmPassController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all required fields'),
                        ),
                      );
                      return;
                    }

                    if (_passController.text !=
                        _confirmPassController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Passwords do not match')),
                      );
                      return;
                    }

                    final selectedTheme = _themes[_selectedThemeIndex];
                    final themeHex = selectedTheme['hex'] as String;

                    try {
                      await DatabaseService().createGroup(
                        _nameController.text.trim(),
                        _descController.text.trim(),
                        _passController.text.trim(),
                        themeHex,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Group Created!')),
                      );

                      // Selesai create → balik ke Dashboard (fade, dengan nama user)
                      Navigator.pushAndRemoveUntil(
                        context,
                        AppRoute.fade(
                          DashboardPage(userName: widget.userName),
                        ),
                            (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: _navy.withOpacity(0.4),
                  ),
                  child: Text(
                    'Create',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
              label: 'Home',
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
              label: 'Join Group',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Create Group',
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

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _navy,
        ),
      ),
    );
  }

  Widget _buildTextField({
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

  Widget _buildThemeDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedThemeIndex,
      items: List.generate(_themes.length, (index) {
        final theme = _themes[index];
        return DropdownMenuItem<int>(
          value: index,
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: theme['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                theme['name'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: _navy,
                ),
              ),
            ],
          ),
        );
      }),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedThemeIndex = value);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      ),
      dropdownColor: Colors.white,
    );
  }
}
