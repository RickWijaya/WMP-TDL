import 'dart:math';
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

    DocumentReference docRef = _db.collection('groups').doc();
    String groupId = docRef.id;

    await docRef.set({
      'groupName': groupName,
      'description': description,
      'password': password,
      'leaderId': uid,
      'leaderName': myName,
      'members': [uid],
      'memberNames': {uid: myName},
      'createdAt': FieldValue.serverTimestamp(),
      'groupId': groupId,
      'groupColor': themeColorHex,
    });
  }

  // Join Group
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

  Stream<QuerySnapshot> searchUserGroups(String search) {
    final String q = search.trim();

    // If empty → just return all groups the user joined
    if (q.isEmpty) {
      return getUserGroups();
    }

    // Firestore prefix search on groupName (requires index)
    return _db
        .collection('groups')
        .where('members', arrayContains: uid)
        .orderBy('groupName')
        .startAt([q])
        .endAt([q + '\uf8ff'])
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
  Future<void> addTask(String groupId, String title, String desc, String date) async {
    await _db.collection('groups').doc(groupId).collection('tasks').add({
      'title': title,
      'description': desc,
      'dueDate': date,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'isCompleted': false,
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
      'isCompleted': true,
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
      'isCompleted': false,
    });
  }


  // Get Group Details for Edit Page
  Future<DocumentSnapshot> getGroupDetails(String groupId) async {
    return await _db.collection('groups').doc(groupId).get();
  }

  // Update Group
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
  // Delete Task
  Future<void> deleteTask(String groupId, String taskId) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Delete Group (Leader Only)
  Future<void> deleteGroup(String groupId) async {
    await _db.collection('groups').doc(groupId).delete();
  }

  // Leave Group with Random Admin Logic
  Future<void> leaveGroup(String groupId) async {
    DocumentReference groupRef = _db.collection('groups').doc(groupId);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(groupRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> members = List.from(data['members'] ?? []);
      Map<String, dynamic> memberNames = Map.from(data['memberNames'] ?? {});
      String currentLeaderId = data['leaderId'];

      // 1. Remove myself
      members.remove(uid);
      memberNames.remove(uid);

      if (members.isEmpty) {
        // 2. If no one left, delete group
        transaction.delete(groupRef);
      } else {
        Map<String, dynamic> updates = {
          'members': members,
          'memberNames': memberNames,
        };

        // 3. If I was the leader, pick a random new leader
        if (uid == currentLeaderId) {
          final random = Random();
          String newLeaderId = members[random.nextInt(members.length)];
          updates['leaderId'] = newLeaderId;
          updates['leaderName'] = memberNames[newLeaderId] ?? 'Leader';
        }

        transaction.update(groupRef, updates);
      }
    });
  }
}
