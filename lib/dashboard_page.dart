import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'edit_group_page.dart';
import 'group_page.dart';
import 'create_group_page.dart';
import 'join_group_page.dart';
import 'login_page.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'routes/app_route.dart';

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
  int _selectedIndex = 0;

  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  final Color _navy = const Color(0xFF1A2342);
  final Color _gold = const Color(0xFFE0A938);

  final List<Color> _cardColors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.teal,
  ];

  String get _displayUserName {
    if (widget.userName != 'User' && widget.userName.trim().isNotEmpty) {
      return widget.userName;
    }
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'User';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 1) {
        Navigator.pushAndRemoveUntil(
          context,
          AppRoute.fade(
            JoinGroupPage(),
          ),
              (route) => false,
        );
      } else if (index == 2) {
        Navigator.pushAndRemoveUntil(
          context,
          AppRoute.fade(
            CreateGroupPage(),
          ),
              (route) => false,
        );
      }
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      AppRoute.fade(const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Your Groups',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              var doc = docs[index - 1];
              var data = doc.data() as Map<String, dynamic>;

              String title = data['groupName'] ?? 'Unnamed';
              String leaderName = data['leaderName'] ?? 'Unknown';
              String leaderId = data['leaderId'] ?? '';
              List members = data['members'] ?? [];
              String memberCount =
                  '${members.length} Member${members.length > 1 ? 's' : ''}';

              Color cardColor;
              final String? colorHex = data['groupColor'] as String?;
              if (colorHex != null) {
                try {
                  cardColor = Color(int.parse(colorHex));
                } catch (_) {
                  cardColor =
                  _cardColors[(index - 1) % _cardColors.length];
                }
              } else {
                cardColor = _cardColors[(index - 1) % _cardColors.length];
              }

              String groupDocId = doc.id;
              String groupShareId = data['groupId'] ?? groupDocId;

              return _buildGroupCard(
                context,
                title,
                memberCount,
                leaderName,
                cardColor,
                leaderId == _uid,
                groupDocId,
                groupShareId,
              );
            },
          );
        },
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

  Widget _buildGroupCard(
      BuildContext context,
      String title,
      String members,
      String leader,
      Color color,
      bool isLeader,
      String groupDocId,
      String groupShareId,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          AppRoute.slideFromRight(
            ClassPage(className: title, groupId: groupDocId),
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
              // Top row: title + menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'leave') {
                        bool confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Leave Group'),
                            content: Text(
                                'Are you sure you want to leave $title?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text(
                                  'Leave',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ) ??
                            false;

                        if (confirm) {
                          await _dbService.leaveGroup(groupDocId);
                        }
                      } else if (value == 'share') {
                        await Clipboard.setData(
                          ClipboardData(text: groupShareId),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Group ID copied to clipboard'),
                            ),
                          );
                        }
                      } else if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditGroupPage(
                              groupId: groupDocId,
                              groupName: title,
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
                            leading:
                            Icon(Icons.exit_to_app, color: Colors.red),
                            title: Text(
                              'Leave',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'share',
                          child: ListTile(
                            leading: Icon(Icons.copy),
                            title: Text('Copy Group ID'),
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
              const SizedBox(height: 4),
              Text(
                'Leader: $leader',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Group ID: $groupShareId',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
