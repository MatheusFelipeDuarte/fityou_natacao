import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fityou_natacao/data/models/checklist.dart';
import 'package:fityou_natacao/data/models/student.dart';
import 'package:fityou_natacao/data/repositories/checklist_repository.dart';
import 'package:fityou_natacao/data/repositories/student_repository.dart';
import 'package:fityou_natacao/ui/students/student_search_page.dart';
import 'package:fityou_natacao/ui/students/student_detail_page.dart';

import 'package:fityou_natacao/services/role_service.dart';

class FakeRoleService extends RoleService {
  @override
  Future<Set<String>> getRoles({bool forceRefresh = false}) async {
    return {'admin', 'professor'};
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late StudentRepository studentRepo;
  late ChecklistRepository checklistRepo;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    studentRepo = StudentRepository(firestore: firestore);
    checklistRepo = ChecklistRepository(firestore: firestore);
    RoleService.mockInstance = FakeRoleService();

    // Seed Templates
    final blueTemplate = ChecklistTemplate(
      cap: CapLevel.azul,
      id: 'azul',
      title: 'Touca Azul → Amarela',
      items: [
        ChecklistItem(id: 'item1', title: 'Respiração', order: 1),
        ChecklistItem(id: 'item2', title: 'Pernada', order: 2),
      ],
    );
    await firestore.collection('checklist_templates').doc('azul').set(blueTemplate.toMap());

    final yellowTemplate = ChecklistTemplate(
      cap: CapLevel.amarela,
      id: 'amarela',
      title: 'Touca Amarela → Laranja',
      items: [
        ChecklistItem(id: 'itemA', title: 'Streamline', order: 1),
      ],
    );
    await firestore.collection('checklist_templates').doc('amarela').set(yellowTemplate.toMap());
  });

  tearDown(() {
    RoleService.mockInstance = null;
  });

  testWidgets('Busca de aluno por CPF', (WidgetTester tester) async {
    // 1. Criar Aluno
    final newStudent = Student(
      id: 'aluno123',
      name: 'Aluno Teste',
      phone: '11999999999',
      level: CapLevel.azul,
      age: 10,
      active: true,
      studentCpf: '111.111.111-11',
      guardianCpf: '222.222.222-22',
    );
    await firestore.collection('students').doc(newStudent.id).set(newStudent.toMap());

    // 2. Carregar Tela
    await tester.pumpWidget(MaterialApp(
      home: StudentSearchPage(studentRepository: studentRepo),
    ));

    // 3. Buscar
    final cpfField = find.byType(TextField);
    await tester.enterText(cpfField, '11111111111');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 4. Verificar Resultado
    expect(find.text('Aluno Teste'), findsOneWidget);
    expect(find.text('Touca AZUL'), findsOneWidget);
    
    // Wait for the 5s timer in StudentSearchPage to complete
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Fluxo de Avaliação e Promoção (Detalhes -> Avaliação -> Promoção)', (WidgetTester tester) async {
    // Set a large screen size to avoid scrolling issues
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Criar Aluno
    final student = Student(
      id: 'aluno123',
      name: 'Aluno Teste',
      phone: '11999999999',
      level: CapLevel.azul,
      age: 10,
      active: true,
      studentCpf: '111.111.111-11',
      guardianCpf: '222.222.222-22',
    );
    // Use set() directly to ensure the ID matches what we pass to the page
    await firestore.collection('students').doc(student.id).set(student.toMap());

    // 2. Carregar Tela de Detalhes
    await tester.pumpWidget(MaterialApp(
      home: StudentDetailPage(
        student: student,
        studentRepository: studentRepo,
        checklistRepository: checklistRepo,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do Aluno'), findsOneWidget);
    expect(find.text('Touca Azul'), findsOneWidget);

    // 3. Ir para Avaliação
    await tester.tap(find.text('Ver Avaliação'));
    await tester.pumpAndSettle();

    expect(find.text('Avaliação - Aluno Teste'), findsOneWidget);
    
    // 4. Completar Itens
    // Item 1: Respiração
    final item1Card = find.widgetWithText(Card, 'Respiração');
    final score10Item1 = find.descendant(of: item1Card, matching: find.text('10'));
    await tester.ensureVisible(score10Item1); // Ensure visible
    await tester.tap(score10Item1);
    await tester.pumpAndSettle();

    // Item 2: Pernada
    final item2Card = find.widgetWithText(Card, 'Pernada');
    final score10Item2 = find.descendant(of: item2Card, matching: find.text('10'));
    await tester.ensureVisible(score10Item2); // Ensure visible
    await tester.tap(score10Item2);
    await tester.pumpAndSettle();

    // 5. Promover
    final promoteBtn = find.text('Promover para Próximo Nível');
    expect(promoteBtn, findsOneWidget);
    await tester.ensureVisible(promoteBtn); // Scroll to button
    await tester.tap(promoteBtn);
    await tester.pumpAndSettle();

    // Confirmar
    expect(find.text('Promover Aluno'), findsOneWidget);
    await tester.tap(find.text('Promover'));
    await tester.pumpAndSettle();

    // Check if student was updated
    final students = await studentRepo.streamStudents().first;
    final updatedStudent = students.firstWhere((s) => s.id == 'aluno123');

    // 6. Verificar Resultado na Tela de Detalhes
    expect(find.text('Detalhes do Aluno'), findsOneWidget);
    
    // OBS: O widget StudentDetailPage usa o objeto student passado no construtor,
    // então ele não atualiza visualmente após o pop da tela de avaliação,
    // a menos que a tela seja reconstruída ou use um StreamBuilder.
    // Por isso, visualmente ainda estará "Touca Azul", mas verificamos no banco que mudou.
    expect(find.text('Touca Azul'), findsOneWidget);
    
    // Verificação extra de que o banco foi atualizado
    expect(updatedStudent.level, CapLevel.amarela);
  });
}
