import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentRepository {
  StudentRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('students');

  Stream<List<Student>> streamStudents({
    String? nameQuery,
    bool? activeOnly,
    int? limit,
    bool cpfOnly = false,
  }) {
    var query = _col.orderBy('name');
    if (limit != null && (nameQuery == null || nameQuery.isEmpty)) {
      query = query.limit(limit);
    }
    return query.snapshots().map((snap) {
      var all = snap.docs.map(Student.fromDoc).toList();

      if (activeOnly != null) {
        all = all.where((s) => s.active == activeOnly).toList();
      }

      if (nameQuery == null || nameQuery.trim().isEmpty) return all;

      final q = _normalize(nameQuery);

      return all.where((s) {
        final normalizedName = _normalize(s.name);
        final matchName = cpfOnly ? false : normalizedName.contains(q);

        final cleanQuery = nameQuery.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanQuery.isEmpty) return matchName;

        final matchStudentCpf = s.studentCpf
                ?.replaceAll(RegExp(r'[^\d]'), '')
                .contains(cleanQuery) ??
            false;
        final matchGuardianCpf = s.guardianCpf
                ?.replaceAll(RegExp(r'[^\d]'), '')
                .contains(cleanQuery) ??
            false;
        final matchPhone = s.phone
            .replaceAll(RegExp(r'[^\d]'), '')
            .contains(cleanQuery);

        return matchName || matchStudentCpf || matchGuardianCpf || matchPhone;
      }).toList();
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getStudentsPage({
    DocumentSnapshot? startAfter,
    int limit = 20,
    bool? activeOnly,
  }) async {
    var query = _col.orderBy('name');
    if (activeOnly != null) {
      query = query.where('active', isEqualTo: activeOnly);
    }
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.limit(limit).get();
  }

  String _normalize(String str) {
    var withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    var withoutDia = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';
    String result = str.toLowerCase();
    for (int i = 0; i < withDia.length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    return result.trim();
  }

  Future<void> addStudent(Student student) async {
    await _col.add(student.toMap());
  }

  Future<void> updateStudent(Student student) async {
    if (student.id.isEmpty)
      throw ArgumentError('Student id é obrigatório para atualização');
    await _col.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(String id) async {
    await _col.doc(id).delete();
  }

  /// Verifica se já existe um aluno com o CPF informado (excluindo o aluno com excludeId se fornecido)
  Future<bool> isStudentCpfInUse(String cpf, {String? excludeId}) async {
    if (cpf.isEmpty) return false;

    final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCpf.isEmpty) return false;

    final snapshot = await _col.where('studentCpf', isEqualTo: cpf).get();

    // Se não encontrou nenhum, o CPF está disponível
    if (snapshot.docs.isEmpty) return false;

    // Se encontrou, verificar se é do mesmo aluno (no caso de edição)
    if (excludeId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeId);
    }

    return true;
  }
}
