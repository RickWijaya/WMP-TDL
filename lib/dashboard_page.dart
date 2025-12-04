import 'package:flutter/material.dart';
import 'class_page.dart';
import 'create_group_page.dart';
import 'join_group_page.dart';
import 'login_page.dart';

class Group {
  final String title;
  final String members;
  final String leader;
  final Color color;
  final bool isLeader;

  Group({
    required this.title,
    required this.members,
    required this.leader,
    required this.color,
    this.isLeader = false,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);

  final List<Group> _groups = [
    Group(title: 'AI 1', members: '2 Members', leader: 'Leader Name', color: Colors.blueAccent, isLeader: true),
    Group(title: 'TDL', members: '1 Member', leader: 'Leader Name', color: Colors.purpleAccent, isLeader: true),
    Group(title: '3DD', members: '1 Member', leader: 'Leader Name', color: Colors.pinkAccent),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Hi {Name}',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Log out'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          ..._groups.map((group) => _buildGroupCard(context, group)).toList(),
        ],
      ),
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
                  color: _selectedIndex == 1 ? _gold.withOpacity(0.15) : Colors.transparent,
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
                  PopupMenuButton<String>(
                    onSelected: (value) {},
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'leave',
                        child: ListTile(
                          leading: Icon(Icons.exit_to_app, color: Colors.red),
                          title: Text('Leave', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      if (group.isLeader)
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                          ),
                        ),
                    ],
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
