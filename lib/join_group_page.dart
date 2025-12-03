import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // Untuk navigasi kembali ke Dashboard
import 'create_group_page.dart'; // Untuk navigasi ke Create Group

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  int _selectedIndex = 1; // Index 1 untuk 'Join Group'
  bool _obscurePassword = true;

  // Definisi Warna
  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);
  final Color _background = const Color(0xFFF5F5F5);
  final Color _inputBorder = const Color(0xFFE0E0E0);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        // Kembali ke Dashboard/Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
          (route) => false,
        );
      } else if (index == 2) {
        // Navigasi ke Create Group Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateGroupPage()),
        );
      }
      // Index 1 adalah halaman ini sendiri
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        toolbarHeight: 0, // Menyembunyikan AppBar standar
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Judul Halaman
              Text(
                'Join Group',
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
              _buildTextField(hint: 'Enter Group Name'),

              const SizedBox(height: 20),

              // Form Password
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

              const SizedBox(height: 40),

              // Button Join
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Aksi Join Group
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Joined Group Successfully!')),
                    );
                    // Kembali ke dashboard setelah join
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
                    'Join',
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
            activeIcon: Icon(Icons.file_upload), // Icon aktif
            label: 'Join Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create Group',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _gold, 
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: _navy,
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
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F5), // Warna background input
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
