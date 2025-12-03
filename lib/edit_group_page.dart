import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'create_group_page.dart';
import 'join_group_page.dart';

class EditGroupPage extends StatefulWidget {
  final String groupName; // Menerima nama grup untuk judul

  const EditGroupPage({super.key, required this.groupName});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  int _selectedIndex = 0; // Default ke Home karena tidak ada tab khusus 'Edit'
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controller untuk form
  late TextEditingController _nameController;
  late TextEditingController _descController;

  // Definisi Warna
  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);
  final Color _background = const Color(0xFFF5F5F5);
  final Color _inputBorder = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    // Pre-fill data (Simulasi)
    _nameController = TextEditingController(text: widget.groupName);
    _descController = TextEditingController(text: "Lorem Ipsum");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Judul Halaman (Nama Grup)
              Text(
                widget.groupName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _navy,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 40),

              // Form Group Name
              _buildLabel('Group Name'),
              const SizedBox(height: 8),
              _buildTextField(controller: _nameController, hint: 'Enter Group Name'),

              const SizedBox(height: 20),

              // Form Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(controller: _descController, hint: 'Enter Description'),

              const SizedBox(height: 20),

              // Form Password (Kosongkan untuk edit, atau isi jika ingin ubah)
              _buildLabel('Password'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: '........',
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Form Confirm Password
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              _buildTextField(
                hint: '........',
                obscure: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Button Save/Create
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Aksi Update Group
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Group Updated!')),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardPage()),
                      (route) => false,
                    );
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
                    'Save Changes', // Menggunakan Save Changes agar lebih logis
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
      
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload_outlined),
            label: 'Join Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create Group',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _navy, // Default navy karena tidak sedang di tab spesifik
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: Color(0xFF1A2342), width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
