import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Create Group
  Future<void> createGroup(
      String groupName,
      String description,
      String password,
      String themeColorHex,
      ) async {
    User? user = FirebaseAuth.instance.currentUser;
    String myName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'Leader';

    // Generate unique Firestore document and use its ID as groupId
    DocumentReference docRef = _db.collection('groups').doc();
    String groupId = docRef.id;

    await docRef.set({
      'groupName': groupName,
      'description': description,
      'password': password,
      'leaderId': uid,
      'leaderName': myName, // Store leader name
      'members': [uid],
      'memberNames': {uid: myName},
      'createdAt': FieldValue.serverTimestamp(),
      'groupId': groupId, // immutable, random, used for joining
      'groupColor': themeColorHex, // theme hex string
    });
  }

  // Join Group (NOW BY groupId, not groupName)
  Future<String?> joinGroup(String groupId, String password) async {
    try {
      QuerySnapshot query = await _db
          .collection('groups')
          .where('groupId', isEqualTo: groupId)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        String docId = query.docs.first.id;

        // Check if already a member
        List members = query.docs.first.get('members');
        if (members.contains(uid)) {
          return "You are already in this group.";
        }

        // Get my name/email to save
        User? user = FirebaseAuth.instance.currentUser;
        String myName =
            user?.displayName ?? user?.email?.split('@')[0] ?? 'Member';

        await _db.collection('groups').doc(docId).update({
          'members': FieldValue.arrayUnion([uid]),
          'memberNames.$uid': myName // Add my name to the map
        });
        return null; // Success
      } else {
        return "Group not found or wrong password.";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Get User's Groups
  Stream<QuerySnapshot> getUserGroups() {
    return _db
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  // Kick Member
  Future<void> kickMember(String groupId, String memberId) async {
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([memberId]),
      'memberNames.$memberId': FieldValue.delete(), // Remove name from map
    });
  }

  // Get Tasks
  Stream<QuerySnapshot> getGroupTasks(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add Task
  Future<void> addTask(
      String groupId, String title, String desc, String date) async {
    await _db.collection('groups').doc(groupId).collection('tasks').add({
      'title': title,
      'description': desc,
      'dueDate': date,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'completedBy': [],
    });
  }

  // Mark Task as done
  Future<void> markTaskDone(String groupId, String taskId) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'completedBy': FieldValue.arrayUnion([uid]),
    });
  }

  // Mark Task as UN-done
  Future<void> unmarkTaskDone(String groupId, String taskId) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'completedBy': FieldValue.arrayRemove([uid]),
    });
  }

  // Get Group Details for Edit Page
  Future<DocumentSnapshot> getGroupDetails(String groupId) async {
    return await _db.collection('groups').doc(groupId).get();
  }

  // Update Group (NOW ALSO UPDATES groupColor)
  Future<void> updateGroup(
      String groupId,
      String name,
      String desc,
      String password,
      String themeColorHex,
      ) async {
    Map<String, dynamic> data = {
      'groupName': name,
      'description': desc,
      'groupColor': themeColorHex,
      // groupId is intentionally NOT touched (immutable)
    };

    if (password.isNotEmpty) data['password'] = password;

    await _db.collection('groups').doc(groupId).update(data);
  }

  // Leave Group
  Future<void> leaveGroup(String groupId) async {
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([uid]),
      'memberNames.$uid': FieldValue.delete(), // Remove my name
    });
  }
}
