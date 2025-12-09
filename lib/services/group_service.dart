import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan ID User saat ini
  String? get currentUserId => _auth.currentUser?.uid;

  /// Menghapus Grup sepenuhnya (Hanya untuk Admin)
  Future<void> deleteGroup(String groupId) async {
    try {
      await _db.collection('groups').doc(groupId).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  /// Keluar dari grup
  /// Jika Admin keluar, sistem akan menunjuk Admin baru secara acak
  Future<void> leaveGroup(String groupId) async {
    final String uid = currentUserId!;
    final DocumentReference groupRef = _db.collection('groups').doc(groupId);

    // Kita gunakan Transaction agar data aman (tidak balapan dengan user lain)
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(groupRef);

      if (!snapshot.exists) {
        throw Exception("Group does not exist!");
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final String currentAdminId = data['adminId'];
      List<dynamic> members = List.from(data['members'] ?? []);

      // 1. Hapus user dari daftar members
      members.remove(uid);

      // 2. Cek apakah grup jadi kosong?
      if (members.isEmpty) {
        // Jika tidak ada member tersisa, hapus grup
        transaction.delete(groupRef);
      } else {
        // 3. Jika masih ada member, update daftar member
        Map<String, dynamic> updates = {
          'members': members,
        };

        // 4. LOGIKA PENTING: Jika yang keluar adalah ADMIN
        if (uid == currentAdminId) {
          // Pilih random member untuk jadi admin baru
          final random = Random();
          String newAdminId = members[random.nextInt(members.length)];
          
          updates['adminId'] = newAdminId; // Set admin baru
        }

        transaction.update(groupRef, updates);
      }
    });
  }

  /// Mendapatkan Stream data grup (untuk update UI realtime)
  Stream<DocumentSnapshot> getGroupStream(String groupId) {
    return _db.collection('groups').doc(groupId).snapshots();
  }
}
