// filepath: lib/data/repositories/checklist_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/checklist.dart';
import '../models/student.dart';

class ChecklistRepository {
  ChecklistRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _templatesCol => _db.collection('checklist_templates');
  CollectionReference<Map<String, dynamic>> get _studentCol => _db.collection('student_checklists');

  /// Stream template for a cap level. Document id is expected to be cap.name (e.g. "blue").
  Stream<ChecklistTemplate?> streamTemplate(CapLevel cap) {
    final doc = _templatesCol.doc(cap.name);
    return doc.snapshots().map((snap) {
      if (!snap.exists) {
        debugPrint('⚠️ Template não encontrado para touca: ${cap.name}. Execute o seed dos templates!');
      }
      return snap.exists ? ChecklistTemplate.fromDoc(snap) : null;
    });
  }

  /// Stream student checklist for given student and cap.
  Stream<StudentChecklist?> streamStudentChecklist(String studentId, CapLevel cap) {
    final docId = _docIdFor(studentId, cap);
    final doc = _studentCol.doc(docId);
    return doc.snapshots().map((snap) => snap.exists ? StudentChecklist.fromDoc(snap) : null);
  }

  String _docIdFor(String studentId, CapLevel cap) => '${studentId}_\u007f${cap.name}';

  /// Ensure a student checklist exists for the given cap by copying the template items.
  Future<void> ensureStudentChecklistInitialized(String studentId, CapLevel cap) async {
    debugPrint('🔄 Inicializando checklist para aluno $studentId, touca: ${cap.name}');
    final docId = _docIdFor(studentId, cap);
    final docRef = _studentCol.doc(docId);
    final doc = await docRef.get();
    if (doc.exists) {
      debugPrint('✅ Checklist já existe para $studentId (${cap.name})');
      return;
    }

    final templateDoc = await _templatesCol.doc(cap.name).get();
    if (!templateDoc.exists) {
      debugPrint('❌ Template não encontrado para ${cap.name}. Execute o seed primeiro!');
      return; // no template available
    }

    final template = ChecklistTemplate.fromDoc(templateDoc);
    final items = template.items.map((i) => StudentChecklistItemProgress(itemId: i.id, score: 0, completed: false)).toList();

    await docRef.set({
      'studentId': studentId,
      'cap': cap.name,
      'items': items.map((i) => i.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Checklist criado para $studentId (${cap.name}) com ${items.length} itens');
  }

  /// Update the progress for a single item. This reads-modifies-writes the document atomically using a transaction.
  Future<void> updateItemProgress(String studentId, CapLevel cap, StudentChecklistItemProgress updated) async {
    final docId = _docIdFor(studentId, cap);
    final docRef = _studentCol.doc(docId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('Student checklist does not exist');
      }
      final data = snap.data()!;
      final rawItems = (data['items'] as List<dynamic>?) ?? [];
      final items = rawItems.map((e) => StudentChecklistItemProgress.fromMap(Map<String, dynamic>.from(e as Map))).toList();
      final idx = items.indexWhere((it) => it.itemId == updated.itemId);
      if (idx < 0) {
        // if item not found, append
        items.add(updated);
      } else {
        items[idx] = updated;
      }
      tx.update(docRef, {
        'items': items.map((i) => i.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Stream all checklists for a student across all cap levels
  Stream<List<StudentChecklist>> streamAllStudentChecklists(String studentId) {
    return _studentCol
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentChecklist.fromDoc(doc))
            .toList()
          ..sort((a, b) {
            // Sort by cap level progression order
            final aIndex = capProgressionOrder.indexOf(a.cap);
            final bIndex = capProgressionOrder.indexOf(b.cap);
            return aIndex.compareTo(bIndex);
          }));
  }
}
