import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class StudentRepository {
  StudentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('students');

  Stream<List<Student>> streamStudents({String? nameQuery, bool? activeOnly}) {
    // Consulta básica; otimização por índice pode ser feita depois
    final query = _col.orderBy('name');
    return query.snapshots().map((snap) {
      var all = snap.docs.map(Student.fromDoc).toList();

      // Filtrar por status ativo/inativo
      if (activeOnly != null) {
        all = all.where((s) => s.active == activeOnly).toList();
      }

      if (nameQuery == null || nameQuery.isEmpty) return all;
      final q = nameQuery.trim().toLowerCase();
      // Busca por nome, CPF do aluno ou CPF do responsável
      return all.where((s) {
        final matchName = s.name.toLowerCase().contains(q);
        final matchStudentCpf = s.studentCpf?.replaceAll(RegExp(r'[^\d]'), '').contains(q.replaceAll(RegExp(r'[^\d]'), '')) ?? false;
        final matchGuardianCpf = s.guardianCpf.replaceAll(RegExp(r'[^\d]'), '').contains(q.replaceAll(RegExp(r'[^\d]'), ''));
        return matchName || matchStudentCpf || matchGuardianCpf;
      }).toList();
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
