import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'group_detail_page.dart';
import 'services/database_service.dart';

class ClassPage extends StatefulWidget {
  final String className;
  final String groupId;

  const ClassPage({
    super.key,
    required this.className,
    required this.groupId
  });

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final DatabaseService _dbService = DatabaseService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  final Color _navy = const Color(0xFF1A2342);
  final Color _background = const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.className,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailPage(groupName: widget.className, groupId: widget.groupId,),
                ),
              );
            },
            child: const Text('Detail', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      // --- TASK LIST ---
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getGroupTasks(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tasks yet. Create one!"));
          }

          // Filter out tasks that THIS user has already completed
          var tasks = snapshot.data!.docs.where((doc) {
            List completedBy = doc['completedBy'] ?? [];
            return !completedBy.contains(_uid);
          }).toList();

          if (tasks.isEmpty) {
            return const Center(child: Text("All caught up! Great job!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              return _buildTaskCard(
                taskId: task.id,
                title: task['title'],
                description: task['description'],
                date: task['dueDate'],
              );
            },
          );
        },
      ),

      // --- ADD TASK BUTTON ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: _navy,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddTaskDialog(),
      ),
    );
  }

  Widget _buildTaskCard({
    required String taskId,
    required String title,
    required String description,
    required String date,
  }) {
    return _TaskCardItem(
      title: title,
      description: description,
      date: date,
      onDone: () => _showDoneConfirmation(taskId),
    );
  }

  // --- CONFIRMATION POPUP ---
  void _showDoneConfirmation(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Complete Task"),
        content: const Text("Are you sure you are done with this task? It will be removed from your list."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _navy),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _dbService.markTaskDone(widget.groupId, taskId); // Hide task
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Task Completed!")),
                );
              }
            },
            child: const Text("Yes, Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- ADD TASK POPUP ---
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "New Task",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          // Prevents overflow when keyboard appears
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Desc field
              TextField(
                controller: descController,
                maxLines: 5, // Allow up to 5 lines
                minLines: 3, // Start with height of 3 lines
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true, // Keeps label at top
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40), // Align icon to top
                    child: Icon(Icons.description),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),

              // Date picker
              TextField(
                controller: dateController,
                readOnly: true, // Prevent manual typing
                decoration: InputDecoration(
                  labelText: "Due Date",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: _navy, // Header background color
                            onPrimary: Colors.white, // Header text color
                            onSurface: _navy, // Body text color
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    // Manual formatting to DD/MM/YYYY string
                    String formattedDate =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    dateController.text = formattedDate;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty && dateController.text.isNotEmpty) {
                _dbService.addTask(
                  widget.groupId,
                  titleController.text.trim(),
                  descController.text.trim(),
                  dateController.text.trim(),
                );
                Navigator.pop(context);
              } else {
                // Show simple error if fields are empty
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a Title and Date")),
                );
              }
            },
            child: const Text("Create", style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}

// Helper Widget to handle Expand/Collapse State locally
class _TaskCardItem extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final VoidCallback onDone;

  const _TaskCardItem({
    required this.title,
    required this.description,
    required this.date,
    required this.onDone
  });

  @override
  State<_TaskCardItem> createState() => _TaskCardItemState();
}

class _TaskCardItemState extends State<_TaskCardItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Description (Show only if expanded)
          if (_isExpanded) ...[
            Text(widget.description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 16),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Expand Button
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_isExpanded ? "Collapse" : "Expand", style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Done Button
                  GestureDetector(
                    onTap: widget.onDone,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2342), // Navy for emphasis
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Done", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              Text(widget.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}