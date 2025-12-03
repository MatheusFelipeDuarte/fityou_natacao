import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fityou_natacao/data/models/checklist.dart';
import 'package:fityou_natacao/data/models/student.dart';
import 'package:fityou_natacao/data/repositories/checklist_repository.dart';
import 'package:fityou_natacao/data/repositories/student_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StudentRepository studentRepo;
  late ChecklistRepository checklistRepo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    studentRepo = StudentRepository(firestore: firestore);
    checklistRepo = ChecklistRepository(firestore: firestore);
  });

  test('Student Creation and Level Up Flow', () async {
    // 1. Seed Templates (Blue -> Yellow)
    final blueTemplate = ChecklistTemplate(
      cap: CapLevel.azul,
      id: 'azul',
      title: 'Touca Azul → Amarela',
      items: [
        ChecklistItem(id: 'item1', title: 'Item 1', order: 1),
        ChecklistItem(id: 'item2', title: 'Item 2', order: 2),
      ],
    );
    await firestore.collection('checklist_templates').doc('azul').set(blueTemplate.toMap());

    final yellowTemplate = ChecklistTemplate(
      cap: CapLevel.amarela,
      id: 'amarela',
      title: 'Touca Amarela → Laranja',
      items: [
        ChecklistItem(id: 'itemA', title: 'Item A', order: 1),
      ],
    );
    await firestore.collection('checklist_templates').doc('amarela').set(yellowTemplate.toMap());

    // 2. Create Student
    final newStudent = Student(
      id: '', // ID will be generated or ignored by addStudent? Wait, addStudent generates ID?
      // Repository addStudent uses .add(), so ID is generated.
      // But we need the ID for next steps.
      // Let's check addStudent implementation. It returns Future<void>.
      // We can't get the ID easily unless we query or change the repo.
      // Or we can create the object with an ID and use set?
      // Repo addStudent: await _col.add(student.toMap());
      // So we can't specify ID easily.
      // Workaround: Query by CPF after adding.
      name: 'Test Student',
      phone: '123456789',
      level: CapLevel.azul,
      age: 10,
      active: true,
      studentCpf: '111.111.111-11',
      guardianCpf: '222.222.222-22',
    );
    
    await studentRepo.addStudent(newStudent);

    // Find the student to get ID
    final students = await studentRepo.streamStudents(nameQuery: '111.111.111-11').first;
    expect(students.length, 1);
    final student = students.first;
    expect(student.name, 'Test Student');
    expect(student.level, CapLevel.azul);
    final studentId = student.id;

    // 3. Initialize Checklist (Blue)
    await checklistRepo.ensureStudentChecklistInitialized(studentId, CapLevel.azul);

    // Verify checklist exists
    final checklistStream = checklistRepo.streamStudentChecklist(studentId, CapLevel.azul);
    final checklist = await checklistStream.first;
    expect(checklist, isNotNull);
    expect(checklist!.items.length, 2);
    expect(checklist.allCompleted, false);

    // 4. Complete Items
    for (var item in checklist.items) {
      final updatedItem = StudentChecklistItemProgress(
        itemId: item.itemId,
        score: 10,
        completed: true,
      );
      await checklistRepo.updateItemProgress(studentId, CapLevel.azul, updatedItem);
    }

    // Verify all completed
    final completedChecklist = await checklistRepo.streamStudentChecklist(studentId, CapLevel.azul).first;
    expect(completedChecklist!.allCompleted, true);

    // 5. Promote Student
    // Logic replicated from StudentDetailPage
    final nextLevel = nextCapLevel(student.level);
    expect(nextLevel, CapLevel.amarela);

    final promotedStudent = Student(
      id: student.id,
      name: student.name,
      phone: student.phone,
      level: nextLevel!,
      age: student.age,
      active: student.active,
      studentCpf: student.studentCpf,
      guardianCpf: student.guardianCpf,
    );

    await studentRepo.updateStudent(promotedStudent);
    await checklistRepo.ensureStudentChecklistInitialized(student.id, nextLevel);

    // 6. Verify Promotion
    // Check student level
    final updatedStudents = await studentRepo.streamStudents(nameQuery: '111.111.111-11').first;
    final updatedStudent = updatedStudents.first;
    expect(updatedStudent.level, CapLevel.amarela);

    // Check new checklist exists
    final newChecklist = await checklistRepo.streamStudentChecklist(studentId, CapLevel.amarela).first;
    expect(newChecklist, isNotNull);
    expect(newChecklist!.items.length, 1); // Yellow template has 1 item
    expect(newChecklist.cap, CapLevel.amarela);

    // Check old checklist still exists
    final oldChecklist = await checklistRepo.streamStudentChecklist(studentId, CapLevel.azul).first;
    expect(oldChecklist, isNotNull);
    expect(oldChecklist!.allCompleted, true);
  });
}
