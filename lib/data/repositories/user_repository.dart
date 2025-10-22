import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_account.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  Stream<List<UserAccount>> streamUsers() {
    return _col.orderBy('email').snapshots().map((snap) =>
        snap.docs.map((d) => UserAccount.fromMap(d.id, d.data())).toList());
  }

  Future<void> createOrUpdate(UserAccount user) async {
    if (user.id.isEmpty) {
      throw ArgumentError('User id (uid) is required');
    }
    await _col.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
