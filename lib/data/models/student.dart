import 'package:cloud_firestore/cloud_firestore.dart';

enum CapLevel {
  blue,   // iniciante - Touca Azul
  yellow,
  orange,
  red,
  black, // avançado
  white, // mais avançado - Touca Branca
}

class Student {
  final String id;
  final String name;
  final String phone; // apenas números com DDD
  final CapLevel level;
  final int age;
  final bool active;
  final String? studentCpf; // CPF do aluno (opcional)
  final String guardianCpf; // CPF do responsável (obrigatório)

  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.level,
    required this.age,
    required this.active,
    this.studentCpf,
    required this.guardianCpf,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'level': level.name,
      'age': age,
      'active': active,
      if (studentCpf != null) 'studentCpf': studentCpf,
      'guardianCpf': guardianCpf,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Student.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      level: CapLevel.values.firstWhere(
        (e) => e.name == data['level'],
        orElse: () => CapLevel.blue,
      ),
      age: (data['age'] ?? 0) as int,
      active: (data['active'] ?? true) as bool,
      studentCpf: data['studentCpf'] as String?,
      guardianCpf: (data['guardianCpf'] ?? '') as String,
    );
  }
}
