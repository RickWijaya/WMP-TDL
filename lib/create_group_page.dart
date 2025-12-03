import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // Untuk navigasi kembali ke Home

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  int _selectedIndex = 2; // Index 2 untuk 'Create Group'
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      } else if (index == 1) {
        // TODO: Navigasi ke Join Group Page
      }
      // Index 2 adalah halaman ini sendiri
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        toolbarHeight: 0, // Menyembunyikan AppBar standar agar sesuai desain full screen
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
                'Create Group',
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
              _buildTextField(hint: 'John'),

              const SizedBox(height: 20),

              // Form Description
              _buildLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(hint: 'Lorem Ipsum'),

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

              // Button Create
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Aksi Create Group
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Group Created!')),
                    );
                    // Kembali ke dashboard setelah create
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
            activeIcon: Icon(Icons.add_circle), // Icon aktif berbeda jika mau
            label: 'Create Group',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _gold, // Item terpilih berwarna emas (atau bisa Navy jika ingin konsisten)
        unselectedItemColor: Colors.white, // Icon tidak terpilih putih
        onTap: _onItemTapped,
        backgroundColor: _navy, // Background Navy sesuai gambar referensi (footer gelap)
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
