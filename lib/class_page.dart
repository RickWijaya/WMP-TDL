import 'package:flutter/material.dart';
import 'group_detail_page.dart';

class ClassPage extends StatefulWidget {
  final String className;

  const ClassPage({super.key, required this.className});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  int _selectedIndex = 0; // (not used anymore but kept in case you need later)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color _navy = const Color(0xFF1A2342);
    final Color _background = const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        iconTheme: const IconThemeData(color: Colors.white),
        // Group name above (replace "Class Page")
        title: Text(
          widget.className,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // "Detail" also above, as an action
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GroupDetailPage(groupName: widget.className),
                ),
              );
            },
            child: const Text(
              'Detail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 8),

          // Card 1
          _buildTaskCard(
            title: 'Lorem Ipsum',
            description:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi porta felis purus',
            date: '00/00/2000',
            hasExpand: false,
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GroupDetailPage(groupName: widget.className),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Card 2
          _buildTaskCard(
            title: 'Lorem Ipsum',
            description:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi porta felis purus, ac tristique nibh luctus sed. Proin vel ligula',
            date: '00/00/2000',
            hasExpand: true,
            isActive: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GroupDetailPage(groupName: widget.className),
                ),
              );
            },
          ),
        ],
      ),

      // BottomNavigation removed for this page
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String description,
    required String date,
    required VoidCallback onTap,
    bool hasExpand = false,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            // Judul
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Deskripsi
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // Tombol + tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (hasExpand) _buildButton("Expand"),
                    if (hasExpand) const SizedBox(width: 8),
                    _buildButton("Done"),
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
