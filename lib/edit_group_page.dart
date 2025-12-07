import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'create_group_page.dart';
import 'join_group_page.dart';
import 'services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditGroupPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const EditGroupPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  int _selectedIndex = 0;
  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = true;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Colors
  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);
  final Color _background = const Color(0xFFF5F5F5);
  final Color _inputBorder = const Color(0xFFE0E0E0);

  // Theme list (8–10 themes is fine)
  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Navy & Gold',
      'color': const Color(0xFF1A2342),
      'hex': '0xFF1A2342',
    },
    {
      'name': 'Ocean Blue',
      'color': const Color(0xFF1565C0),
      'hex': '0xFF1565C0',
    },
    {
      'name': 'Forest Green',
      'color': const Color(0xFF2E7D32),
      'hex': '0xFF2E7D32',
    },
    {
      'name': 'Sunset Orange',
      'color': const Color(0xFFF57C00),
      'hex': '0xFFF57C00',
    },
    {
      'name': 'Royal Purple',
      'color': const Color(0xFF6A1B9A),
      'hex': '0xFF6A1B9A',
    },
    {
      'name': 'Soft Pink',
      'color': const Color(0xFFD81B60),
      'hex': '0xFFD81B60',
    },
    {
      'name': 'Teal Breeze',
      'color': const Color(0xFF00897B),
      'hex': '0xFF00897B',
    },
    {
      'name': 'Grey Neutral',
      'color': const Color(0xFF455A64),
      'hex': '0xFF455A64',
    },
  ];

  int _selectedThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.groupName);
    _descController = TextEditingController(text: "");
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    try {
      DocumentSnapshot doc =
      await DatabaseService().getGroupDetails(widget.groupId);

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        // Description
        _descController.text = (data['description'] ?? '') as String;

        // Current password (for admin view)
        _currentPassController.text = (data['password'] ?? '') as String;

        // 🔥 THEME MATCHING FIX
        final String? colorHex = data['groupColor'] as String?;
        if (colorHex != null) {
          final index = _themes.indexWhere(
                (theme) => theme['hex'] == colorHex,
          );

          if (index != -1) {
            setState(() {
              _selectedThemeIndex = index;
            });
          }
        }

        // New password fields always empty
        _passController.clear();
        _confirmPassController.clear();
      }
    } catch (e) {
      print("Error fetching group details: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _currentPassController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
              (route) => false,
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const JoinGroupPage()),
        );
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateGroupPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Edit ${widget.groupName}',
                textAlign: TextAlign.center,
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
                hint: 'Enter Group Name',
                controller: _nameController,
              ),

              const SizedBox(height: 20),

              // Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Enter Description',
                controller: _descController,
              ),

              const SizedBox(height: 20),

              // Current Password (read-only, just for admin to see)
              _buildLabel('Current Password (Read Only)'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Current group password',
                controller: _currentPassController,
                obscure: _obscureCurrentPassword,
                readOnly: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() =>
                    _obscureCurrentPassword = !_obscureCurrentPassword);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // New Password
              _buildLabel('New Password (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: 'Leave empty to keep current',
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
                hint: 'Repeat new password',
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
                    setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Group Theme dropdown
              _buildLabel('Group Theme'),
              const SizedBox(height: 8),
              _buildThemeDropdown(),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Group name cannot be empty'),
                        ),
                      );
                      return;
                    }

                    if (_passController.text.isNotEmpty &&
                        _passController.text !=
                            _confirmPassController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                        ),
                      );
                      return;
                    }

                    try {
                      final String selectedThemeHex =
                      _themes[_selectedThemeIndex]['hex'] as String;

                      await DatabaseService().updateGroup(
                        widget.groupId,
                        _nameController.text.trim(),
                        _descController.text.trim(),
                        _passController.text.trim(), // empty = keep old
                        selectedThemeHex,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Group Updated!')),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const DashboardPage()),
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
                    'Save Changes',
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
    String? hint,
    TextEditingController? controller,
    bool obscure = false,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
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
