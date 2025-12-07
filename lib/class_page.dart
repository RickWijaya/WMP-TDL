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
    required this.groupId,
  });

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final DatabaseService _dbService = DatabaseService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  final Color _navy = const Color(0xFF1A2342);
  final Color _background = const Color(0xFFF5F5F5);

  bool _isLeader = false;
  @override
  void initState() {
    super.initState();
    _loadLeaderStatus();
  }

  Future<void> _loadLeaderStatus() async {
    try {
      final doc = await _dbService.getGroupDetails(widget.groupId);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final String leaderId = data['leaderId'] as String? ?? '';
        if (mounted) {
          setState(() {
            _isLeader = leaderId == _uid;
          });
        }
      }
    } catch (e) {
      print("Error loading leader status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.className,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupDetailPage(
                    groupName: widget.className,
                    groupId: widget.groupId,
                  ),
                ),
              );
            },
            child: const Text(
              'Detail',
              style: TextStyle(color: Colors.white),
            ),
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

          var tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];

              // 🔥 GLOBAL completion flag – everyone sees the same
              final data = task.data() as Map<String, dynamic>;
              bool isCompleted = data['isCompleted'] ?? false;

              return _buildTaskCard(
                taskId: task.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                date: data['dueDate'] ?? '',
                isCompleted: isCompleted,
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
    required bool isCompleted,
  }) {
    return _TaskCardItem(
      title: title,
      description: description,
      date: date,
      isCompleted: isCompleted,
      isLeader: _isLeader, // 🔥 tell the card if this user is leader
      onCheckboxChanged: (bool value) {
        if (value && !isCompleted) {
          // going from UN-done → done (for everyone)
          _showDoneConfirmation(taskId);
        } else if (!value && isCompleted) {
          // going from done → UN-done (for everyone)
          _showUndoConfirmation(taskId);
        }
      },
      onDelete: _isLeader
          ? () => _showDeleteConfirmation(taskId, title)
          : null, // only leader can delete
    );
  }

  // --- CONFIRMATION POPUP: mark as DONE ---
  void _showDoneConfirmation(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Complete Task"),
        content: const Text(
          "Are you sure you are done with this task?\n\n"
              "It will be marked as completed for everyone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _navy),
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.markTaskDone(widget.groupId, taskId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Task marked as completed!")),
                );
              }
            },
            child: const Text(
              "Yes, I'm Done",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONFIRMATION POPUP: mark as UN-DONE ---
  void _showUndoConfirmation(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mark as Not Done"),
        content: const Text(
          "Do you want to mark this task as not finished yet for everyone?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _navy),
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.unmarkTaskDone(widget.groupId, taskId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Task marked as not done.")),
                );
              }
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONFIRMATION POPUP: DELETE TASK (ADMIN ONLY) ---
  void _showDeleteConfirmation(String taskId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: Text(
          'Are you sure you want to permanently delete the task:\n\n"$title"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _dbService.deleteTask(widget.groupId, taskId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Task deleted."),
                  ),
                );
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Due Date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                            primary: _navy,
                            onPrimary: Colors.white,
                            onSurface: _navy,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
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
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  dateController.text.isNotEmpty) {
                _dbService.addTask(
                  widget.groupId,
                  titleController.text.trim(),
                  descController.text.trim(),
                  dateController.text.trim(),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a Title and Date"),
                  ),
                );
              }
            },
            child: const Text(
              "Create",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

// --- TASK CARD WIDGET ---
class _TaskCardItem extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final bool isCompleted;
  final bool isLeader;                    // 🔥 admin info
  final ValueChanged<bool> onCheckboxChanged;
  final VoidCallback? onDelete;           // 🔥 delete callback for admin

  const _TaskCardItem({
    required this.title,
    required this.description,
    required this.date,
    required this.isCompleted,
    required this.isLeader,
    required this.onCheckboxChanged,
    this.onDelete,
  });

  @override
  State<_TaskCardItem> createState() => _TaskCardItemState();
}

class _TaskCardItemState extends State<_TaskCardItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool completed = widget.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: completed
            ? Border.all(color: Colors.green.shade400, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: completed ? Colors.green.shade900 : Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          if (_isExpanded) ...[
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Expand button
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isExpanded = !_isExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isExpanded ? "Collapse" : "Expand",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Checkbox Done / Undone
                  Row(
                    children: [
                      Checkbox(
                        value: completed,
                        onChanged: (val) {
                          if (val == null) return;
                          widget.onCheckboxChanged(val);
                        },
                        activeColor: const Color(0xFF1A2342),
                      ),
                      const Text(
                        "Done",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              // Right side: date + delete (if leader)
              Row(
                children: [
                  Text(
                    widget.date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (widget.isLeader && widget.onDelete != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete Task',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
