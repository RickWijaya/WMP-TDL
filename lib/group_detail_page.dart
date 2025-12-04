import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'create_group_page.dart';
import 'join_group_page.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;
  final int memberCount;

  const GroupDetailPage({
    super.key,
    required this.groupName,
    this.memberCount = 2, // Default value
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  int _selectedIndex = 0;

  // Definisi Warna
  final Color _navy = const Color(0xFF1A2342);
  final Color _background = const Color(0xFFF5F5F5);

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              color: _background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Member : ${widget.memberCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // MEMBER LIST CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Daftar Anggota
                    _buildMemberItem('Name', isAdmin: true),
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildMemberItem('Title'), // Contoh nama anggota lain
                    const Divider(
                      height: 1,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                    ),

                    // Tombol Leave
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextButton(
                        onPressed: () {
                          _showLeaveDialog();
                        },
                        child: const Text(
                          'Leave',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

       );
  }

  Widget _buildMemberItem(String name, {bool isAdmin = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          // Admin label or Kick button
          if (isAdmin)
            const Text(
              'Admin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            )
          else
            TextButton(
              onPressed: () {
                _showKickDialog(name);
              },
              child: const Text(
                'Kick',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave ${widget.groupName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman sebelumnya
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You left the group')),
              );
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showKickDialog(String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kick User'),
        content: Text('Are you sure you want to kick $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User kicked')),
              );
            },
            child: const Text(
              'Kick',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
