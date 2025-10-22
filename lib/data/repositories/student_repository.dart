import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentRepository {
  StudentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('students');

  Stream<List<Student>> streamStudents({String? nameQuery}) {
    // Consulta básica; otimização por índice pode ser feita depois
    final query = _col.orderBy('name');
    return query.snapshots().map((snap) {
      final all = snap.docs.map(Student.fromDoc).toList();
      if (nameQuery == null || nameQuery.isEmpty) return all;
      final q = nameQuery.trim().toLowerCase();
      return all.where((s) => s.name.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> addStudent(Student student) async {
    await _col.add(student.toMap());
  }

  Future<void> updateStudent(Student student) async {
    if (student.id.isEmpty) throw ArgumentError('Student id é obrigatório para atualização');
    await _col.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _col.doc(id).delete();
  }
}
