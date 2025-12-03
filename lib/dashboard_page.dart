import 'package:flutter/material.dart';
import 'class_page.dart';
import 'create_group_page.dart';
import 'join_group_page.dart'; // Import JoinGroupPage

// --- Data Model Sederhana untuk Kartu Grup ---
class Group {
  final String title;
  final String members;
  final String leader;
  final Color color;
  final bool isLeader; // Menentukan apakah opsi 'Edit' muncul

  Group({
    required this.title,
    required this.members,
    required this.leader,
    required this.color,
    this.isLeader = false,
  });
}

// ---------- DASHBOARD PAGE ----------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // Untuk BottomNavigationBar

  // Data contoh untuk daftar grup
  final List<Group> _groups = [
    Group(title: 'AI 1', members: '2 Members', leader: 'Leader Name', color: Colors.blue.shade400, isLeader: true),
    Group(title: 'TDL', members: '1 Member', leader: 'Leader Name', color: Colors.purple.shade400, isLeader: true),
    Group(title: '3DD', members: '1 Member', leader: 'Leader Name', color: Colors.pink.shade400),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) { // Index 1 adalah 'Join Group'
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JoinGroupPage()),
        );
      } else if (index == 2) { // Index 2 adalah 'Create Group'
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateGroupPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background abu-abu muda
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, // Menghilangkan tombol back
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Teks Sambutan
          const Text(
            'Hi {Name}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Daftar Kartu Grup
          ..._groups.map((group) => _buildGroupCard(context, group)).toList(),
        ],
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
        selectedItemColor: const Color(0xFF1A2342), // Warna navy
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
      ),
    );
  }

  // WIDGET UNTUK KARTU GRUP (sekarang bisa diklik)
  Widget _buildGroupCard(BuildContext context, Group group) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassPage(className: group.title),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: group.color,
        elevation: 4,
        shadowColor: group.color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Tombol Menu (tiga titik)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // TODO: Aksi untuk leave/edit
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'leave',
                          child: ListTile(
                            leading: Icon(Icons.exit_to_app, color: Colors.red),
                            title: Text('Leave', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                        // Hanya tampilkan 'Edit' jika pengguna adalah leader
                        if (group.isLeader)
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit'),
                            ),
                          ),
                      ];
                    },
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(group.members, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              Text(group.leader, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
