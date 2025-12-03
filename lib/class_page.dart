import 'package:flutter/material.dart';

class ClassPage extends StatefulWidget {
  final String className;

  const ClassPage({super.key, required this.className});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Logika navigasi bisa ditambahkan di sini
      if (index == 0) {
        Navigator.popUntil(context, (route) => route.isFirst); // Kembali ke Dashboard/Home
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna
    final Color _navy = const Color(0xFF1A2342);
    final Color _background = const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: _background,
      // Menggunakan AppBar dengan warna Navy sesuai tema
      appBar: AppBar(
        backgroundColor: _navy,
        title: const Text('Class Page', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Header Class Name
          Text(
            widget.className,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _navy,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 24),

          // Kartu 1 (Standar)
          _buildTaskCard(
            title: 'Lorem Ipsum',
            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi porta felis purus',
            date: '00/00/2000',
            hasExpand: false,
            isActive: false,
          ),

          const SizedBox(height: 16),

          // Kartu 2 (Aktif / Border Biru)
          _buildTaskCard(
            title: 'Lorem Ipsum',
            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi porta felis purus, ac tristique nibh luctus sed. Proin vel ligula',
            date: '00/00/2000',
            hasExpand: true,
            isActive: true,
          ),
        ],
      ),
      
      // BOTTOM NAVIGATION BAR (Sama seperti Dashboard)
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
        selectedItemColor: _navy,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String description,
    required String date,
    bool hasExpand = false,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey.shade400,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Tombol-tombol
              Row(
                children: [
                  if (hasExpand) ...[
                    _buildButton('Expand'),
                    const SizedBox(width: 8),
                  ],
                  _buildButton('Done'),
                ],
              ),
              // Tanggal
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0).withOpacity(0.6), // Abu-abu muda transparan
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
