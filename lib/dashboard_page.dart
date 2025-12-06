import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_group_page.dart';
import 'class_page.dart';
import 'create_group_page.dart';
import 'join_group_page.dart';
import 'login_page.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

// ---------- DASHBOARD PAGE ----------

class DashboardPage extends StatefulWidget {
  final String userName;

  const DashboardPage({
    super.key,
    this.userName = 'User',
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // Untuk BottomNavigationBar

  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService(); // Added service
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Warna utama
  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);

  final List<Color> _cardColors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.teal,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JoinGroupPage()),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateGroupPage()),
        );
      }
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background abu-abu muda
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white), // Changed from Black to White
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
          stream: _dbService.getUserGroups(),
          builder: (context, snapshot) {
            // Handling Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Prepare Data
            var docs = snapshot.data?.docs ?? [];

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: docs.length + 1,
              itemBuilder: (context, index) {

                // Header Logic
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Hi ${widget.userName}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                // Card Logic
                var doc = docs[index - 1];
                var data = doc.data() as Map<String, dynamic>;

                // Extract Data
                String title = data['groupName'] ?? 'Unnamed';
                String leaderName = data['leaderName'] ?? 'Unknown';
                String leaderId = data['leaderId'] ?? '';
                List members = data['members'] ?? [];
                String memberCount = '${members.length} Member${members.length > 1 ? 's' : ''}';

                // Determine logic
                bool isLeader = leaderId == _uid;
                Color cardColor = _cardColors[(index - 1) % _cardColors.length]; // Cycle colors

                return _buildGroupCard(
                    context,
                    title,
                    memberCount,
                    leaderName,
                    cardColor,
                    isLeader,
                    doc.id
                );
              },
            );
          }
      ),

      // BOTTOM NAVIGATION
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

  // WIDGET UNTUK KARTU GRUP
  Widget _buildGroupCard(
      BuildContext context,
      String title,
      String members,
      String leader,
      Color color,
      bool isLeader,
      String groupId // Added groupId for navigation
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Updated to pass groupId to ClassPage
            builder: (context) => ClassPage(className: title, groupId: groupId),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: color,
        elevation: 4,
        shadowColor: color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'leave') {
                        // Show confirmation dialog
                        bool confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Leave Group'),
                            content: Text('Are you sure you want to leave $title?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ) ?? false;

                        if (confirm) {
                          await _dbService.leaveGroup(groupId);
                          // UI updates automatically via StreamBuilder
                        }
                      }
                      else if (value == 'edit') {
                        // Navigate to Edit Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditGroupPage(
                                groupId: groupId,
                                groupName: title
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'leave',
                          child: ListTile(
                            leading: Icon(Icons.exit_to_app, color: Colors.red),
                            title: Text(
                              'Leave',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        if (isLeader)
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
              Text(
                members,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                leader,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}