import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/models/checklist.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../theme/app_colors.dart';
import '../students/student_evaluation_page.dart';

class AllEvaluationsPage extends StatefulWidget {
  const AllEvaluationsPage({super.key});

  @override
  State<AllEvaluationsPage> createState() => _AllEvaluationsPageState();
}

class _AllEvaluationsPageState extends State<AllEvaluationsPage> {
  final _studentRepo = StudentRepository();
  final _checklistRepo = ChecklistRepository();
  final _searchController = TextEditingController();
  CapLevel? _selectedCap;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Campo de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.darkSurface,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.darkDivider,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.darkTextPrimary),
                decoration: InputDecoration(
                  labelText: 'Pesquisar aluno',
                  labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
                  hintText: 'Digite o nome do aluno...',
                  hintStyle: TextStyle(color: AppColors.darkTextSecondary.withOpacity(0.6)),
                  prefixIcon: const Icon(Icons.search, size: 22, color: AppColors.darkTextSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.darkTextSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          // Filtro por touca
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: AppColors.darkSurface,
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: AppColors.darkTextSecondary, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Touca:',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CapFilterChip(
                          label: 'Todas',
                          isSelected: _selectedCap == null,
                          color: Colors.grey,
                          onTap: () => setState(() => _selectedCap = null),
                        ),
                        ...CapLevel.values.map((cap) {
                          return _CapFilterChip(
                            label: cap.name.toUpperCase(),
                            isSelected: _selectedCap == cap,
                            color: _capColorForLevel(cap),
                            onTap: () => setState(() => _selectedCap = cap),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de alunos com seus checklists
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _studentRepo.streamStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkOrangeAccent,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                var students = snapshot.data ?? [];

                // Aplicar filtro de pesquisa por nome
                final searchQuery = _searchController.text.toLowerCase().trim();
                if (searchQuery.isNotEmpty) {
                  students = students.where((s) => s.name.toLowerCase().contains(searchQuery)).toList();
                }

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80,
                          color: AppColors.darkTextSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Nenhum aluno encontrado para "$searchQuery"'
                              : 'Nenhum aluno cadastrado',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.darkTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _StudentAllEvaluationsCard(
                      student: student,
                      checklistRepo: _checklistRepo,
                      selectedCapFilter: _selectedCap,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _capColorForLevel(CapLevel level) {
    switch (level) {
      case CapLevel.azul:
        return Colors.blue.shade600;
      case CapLevel.amarela:
        return Colors.yellow.shade600;
      case CapLevel.laranja:
        return Colors.orange.shade600;
      case CapLevel.vermelha:
        return Colors.red.shade600;
      case CapLevel.preta:
        return Colors.black87;
      case CapLevel.branca:
        return Colors.grey.shade200;
    }
  }
}

class _CapFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CapFilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.darkSurfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : AppColors.darkDivider,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (label == 'AMARELA' || label == 'BRANCA' ? Colors.black87 : Colors.white)
                  : AppColors.darkTextPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentAllEvaluationsCard extends StatelessWidget {
  final Student student;
  final ChecklistRepository checklistRepo;
  final CapLevel? selectedCapFilter;

  const _StudentAllEvaluationsCard({
    required this.student,
    required this.checklistRepo,
    this.selectedCapFilter,
  });

  Color _capColorForLevel(CapLevel level) {
    switch (level) {
      case CapLevel.azul:
        return Colors.blue.shade600;
      case CapLevel.amarela:
        return Colors.yellow.shade600;
      case CapLevel.laranja:
        return Colors.orange.shade600;
      case CapLevel.vermelha:
        return Colors.red.shade600;
      case CapLevel.preta:
        return Colors.black87;
      case CapLevel.branca:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudentChecklist>>(
      stream: checklistRepo.streamAllStudentChecklists(student.id),
      builder: (context, checklistsSnapshot) {
        if (checklistsSnapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: AppColors.darkSurface,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        var allChecklists = checklistsSnapshot.data ?? [];

        // Aplicar filtro se selecionado
        if (selectedCapFilter != null) {
          allChecklists = allChecklists.where((c) => c.cap == selectedCapFilter).toList();
        }

        // Se não tem nenhum checklist após filtro, não mostrar o card
        if (allChecklists.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AppColors.darkSurface,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com informações do aluno
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.darkOrangeAccent,
                      child: Text(
                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Touca Atual: ${student.level.name.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.darkDivider),

              // Lista de todas as avaliações
              ...allChecklists.map((checklist) {
                return _ChecklistProgressItem(
                  student: student,
                  checklist: checklist,
                  checklistRepo: checklistRepo,
                  isCurrentLevel: checklist.cap == student.level,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ChecklistProgressItem extends StatelessWidget {
  final Student student;
  final StudentChecklist checklist;
  final ChecklistRepository checklistRepo;
  final bool isCurrentLevel;

  const _ChecklistProgressItem({
    required this.student,
    required this.checklist,
    required this.checklistRepo,
    required this.isCurrentLevel,
  });

  Color _capColorForLevel(CapLevel level) {
    switch (level) {
      case CapLevel.azul:
        return Colors.blue.shade600;
      case CapLevel.amarela:
        return Colors.yellow.shade600;
      case CapLevel.laranja:
        return Colors.orange.shade600;
      case CapLevel.vermelha:
        return Colors.red.shade600;
      case CapLevel.preta:
        return Colors.black87;
      case CapLevel.branca:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChecklistTemplate?>(
      stream: checklistRepo.streamTemplate(checklist.cap),
      builder: (context, tplSnap) {
        final tpl = tplSnap.data;
        if (tpl == null) {
          return ListTile(
            leading: Icon(Icons.warning, color: AppColors.warning),
            title: Text('Touca ${checklist.cap.name.toUpperCase()}'),
            subtitle: const Text('Template não encontrado'),
          );
        }

        final completedCount = checklist.items.where((i) => i.completed).length;
        final totalCount = tpl.items.length;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StudentEvaluationPage(
                  student: student,
                  initialCap: checklist.cap,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentLevel ? AppColors.darkSurfaceVariant : Colors.transparent,
              border: Border(
                bottom: BorderSide(color: AppColors.darkDivider.withOpacity(0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _capColorForLevel(checklist.cap),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Touca ${checklist.cap.name.toUpperCase()}',
                        style: TextStyle(
                          color: checklist.cap == CapLevel.branca || checklist.cap == CapLevel.amarela
                              ? Colors.black87
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (isCurrentLevel) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkOrangeAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ATUAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (checklist.allCompleted)
                      Icon(Icons.check_circle, color: Colors.green.shade400, size: 24),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.darkTextSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppColors.darkBackground,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0 ? Colors.green.shade400 : _capColorForLevel(checklist.cap),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedCount/$totalCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% completo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
