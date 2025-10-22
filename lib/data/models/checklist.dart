// filepath: lib/data/models/checklist.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';

/// Ordem de progressão das toucas conforme solicitado pelo usuário:
/// Azul -> Amarela -> Laranja -> Vermelha -> Preta -> Branca
const List<CapLevel> capProgressionOrder = [
  CapLevel.blue,
  CapLevel.yellow,
  CapLevel.orange,
  CapLevel.red,
  CapLevel.black,
  CapLevel.white,
];

CapLevel? nextCapLevel(CapLevel current) {
  final idx = capProgressionOrder.indexOf(current);
  if (idx < 0 || idx + 1 >= capProgressionOrder.length) return null;
  return capProgressionOrder[idx + 1];
}

class ChecklistItem {
  final String id; // identificador único do item dentro do template
  final String title;
  final String? description;
  final int order; // ordem dentro do checklist
  final int maxScore; // 1..maxScore (normalmente 10)

  ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.order = 0,
    this.maxScore = 10,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        'order': order,
        'maxScore': maxScore,
      };

  factory ChecklistItem.fromMap(Map<String, dynamic> m) {
    return ChecklistItem(
      id: m['id'] as String,
      title: m['title'] as String? ?? '',
      description: m['description'] as String?,
      order: (m['order'] ?? 0) as int,
      maxScore: (m['maxScore'] ?? 10) as int,
    );
  }
}

class ChecklistTemplate {
  final CapLevel cap;
  final String id; // ex: 'blue', 'yellow', etc. (cap.name)
  final String title;
  final List<ChecklistItem> items;

  ChecklistTemplate({
    required this.cap,
    required this.id,
    required this.title,
    required this.items,
  });

  Map<String, dynamic> toMap() => {
        'cap': cap.name,
        'title': title,
        'items': items.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory ChecklistTemplate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawItems = (data['items'] as List<dynamic>?) ?? [];
    return ChecklistTemplate(
      cap: CapLevel.values.firstWhere((e) => e.name == (data['cap'] as String? ?? doc.id), orElse: () => CapLevel.blue),
      id: doc.id,
      title: data['title'] as String? ?? '',
      items: rawItems.map((e) => ChecklistItem.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }
}

class StudentChecklistItemProgress {
  final String itemId;
  final int score; // 1..10 (or 0 if not yet rated)
  final bool completed;
  final Timestamp? updatedAt;

  StudentChecklistItemProgress({
    required this.itemId,
    required this.score,
    required this.completed,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'score': score,
        'completed': completed,
        // Não usar serverTimestamp dentro de arrays - usar timestamp atual
        'updatedAt': updatedAt ?? Timestamp.now(),
      };

  factory StudentChecklistItemProgress.fromMap(Map<String, dynamic> m) {
    return StudentChecklistItemProgress(
      itemId: m['itemId'] as String,
      score: (m['score'] ?? 0) as int,
      completed: (m['completed'] ?? false) as bool,
      updatedAt: m['updatedAt'] as Timestamp?,
    );
  }
}

class StudentChecklist {
  final String studentId;
  final CapLevel cap;
  final List<StudentChecklistItemProgress> items;
  final Timestamp? updatedAt;

  StudentChecklist({
    required this.studentId,
    required this.cap,
    required this.items,
    this.updatedAt,
  });

  bool get allCompleted => items.isNotEmpty && items.every((i) => i.completed);

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'cap': cap.name,
        'items': items.map((i) => i.toMap()).toList(),
        'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      };

  factory StudentChecklist.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawItems = (data['items'] as List<dynamic>?) ?? [];
    final capName = data['cap'] as String? ?? '';
    return StudentChecklist(
      studentId: data['studentId'] as String? ?? doc.id,
      cap: CapLevel.values.firstWhere((e) => e.name == capName, orElse: () => CapLevel.blue),
      items: rawItems.map((e) => StudentChecklistItemProgress.fromMap(Map<String, dynamic>.from(e as Map))).toList(),
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }
}
