import 'package:cloud_firestore/cloud_firestore.dart';

enum CapLevel {
  white, // iniciante
  yellow,
  orange,
  green,
  blue,
  red,
  black, // avançado
}

class Student {
  final String id;
  final String name;
  final String email;
  final String phone; // apenas números com DDD
  final CapLevel level;
  final int age;
  final bool active;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.level,
    required this.age,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'level': level.name,
      'age': age,
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Student.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      level: CapLevel.values.firstWhere(
        (e) => e.name == data['level'],
        orElse: () => CapLevel.white,
      ),
      age: (data['age'] ?? 0) as int,
      active: (data['active'] ?? true) as bool,
    );
  }
}
