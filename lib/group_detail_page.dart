import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_page.dart';
import 'services/database_service.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const GroupDetailPage({
    super.key,
    required this.groupName,
    required this.groupId,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final DatabaseService _dbService = DatabaseService();
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;

  final Color _navy = const Color(0xFF1A2342);
  final Color _background = const Color(0xFFF5F5F5);

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
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('groups').doc(widget.groupId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Group not found"));
            }

            var groupData = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> members = groupData['members'] ?? [];
            Map<String, dynamic> memberNames = groupData['memberNames'] ?? {};

            String leaderId = groupData['leaderId'] ?? '';
            bool amILeader = leaderId == _currentUid;

            return SingleChildScrollView(
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
                          groupData['groupName'] ?? widget.groupName,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _navy,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Members : ${members.length}',
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
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: members.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              String memberId = members[index];
                              String name = memberNames[memberId] ?? "Member";
                              if (memberId == _currentUid) name += " (Me)";

                              bool isMemberLeader = memberId == leaderId;

                              return _buildMemberItem(
                                name,
                                isLeader: isMemberLeader,
                                canKick: amILeader && !isMemberLeader,
                                onKick: () => _showKickDialog(memberId),
                              );
                            },
                          ),

                          // ACTION BUTTONS (Leave & Delete)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextButton(
                                  onPressed: () => _showLeaveDialog(amILeader),
                                  child: const Text(
                                    'Leave Group',
                                    style: TextStyle(
                                      color: Colors.red, 
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                if (amILeader) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => _showDeleteDialog(),
                                    child: const Text(
                                      'Delete Group',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildMemberItem(String displayName, {bool isLeader = false, bool canKick = false, VoidCallback? onKick}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          if (isLeader)
            const Text(
              'Admin',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            )
          else if (canKick)
            TextButton(
              onPressed: onKick,
              child: const Text('Kick', style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  void _showLeaveDialog(bool amILeader) {
    String content = 'Are you sure you want to leave ${widget.groupName}?';
    if (amILeader) {
      content += '\n\nSince you are the Admin, a new Admin will be randomly assigned to another member.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.leaveGroup(widget.groupId);
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                      (route) => false
              );
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group permanently? All tasks and members will be removed. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              
              await _dbService.deleteGroup(widget.groupId);

              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group deleted successfully')),
              );

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                      (route) => false
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showKickDialog(String memberId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kick User'),
        content: const Text('Are you sure you want to kick this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.kickMember(widget.groupId, memberId);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User kicked')));
            },
            child: const Text('Kick', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
