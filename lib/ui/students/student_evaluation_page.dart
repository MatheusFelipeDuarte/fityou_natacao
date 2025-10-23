import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/models/checklist.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../theme/app_colors.dart';
import '../../services/role_service.dart';

class StudentEvaluationPage extends StatefulWidget {
  const StudentEvaluationPage({
    super.key,
    required this.student,
    this.initialCap,
  });

  final Student student;
  final CapLevel? initialCap;

  @override
  State<StudentEvaluationPage> createState() => _StudentEvaluationPageState();
}

class _StudentEvaluationPageState extends State<StudentEvaluationPage> {
  final _checklistRepo = ChecklistRepository();
  final _studentRepo = StudentRepository();
  final _roleService = const RoleService();
  Set<String> _roles = const {};
  late CapLevel _selectedCap;

  @override
  void initState() {
    super.initState();
    _selectedCap = widget.initialCap ?? widget.student.level;
    _load();
    _checklistRepo.ensureStudentChecklistInitialized(widget.student.id, _selectedCap).catchError((e) {
      debugPrint('Erro ao inicializar checklist: $e');
    });
  }

  Future<void> _load() async {
    final r = await _roleService.getRoles(forceRefresh: true);
    if (mounted) setState(() { _roles = r; });
  }

  Future<void> _updateItemProgress(CapLevel cap, String itemId, int score, bool completed) async {
    // Só marca como completo se a nota for 10
    final shouldComplete = score == 10;
    final updated = StudentChecklistItemProgress(
      itemId: itemId,
      score: score,
      completed: shouldComplete
    );
    await _checklistRepo.updateItemProgress(widget.student.id, cap, updated);
  }

  Future<void> _promoteToNextCap() async {
    final next = nextCapLevel(widget.student.level);
    if (next == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há próximo nível definido')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promover Aluno'),
        content: Text('Deseja promover ${widget.student.name} para a touca ${next.name.toUpperCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promover'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final promoted = Student(
      id: widget.student.id,
      name: widget.student.name,
      phone: widget.student.phone,
      level: next,
      age: widget.student.age,
      active: widget.student.active,
      studentCpf: widget.student.studentCpf,
      guardianCpf: widget.student.guardianCpf,
    );
    await _studentRepo.updateStudent(promoted);
    // Initialize checklist for new cap
    await _checklistRepo.ensureStudentChecklistInitialized(widget.student.id, next);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.student.name} foi promovido(a) para ${next.name.toUpperCase()}!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final isAdmin = _roles.contains('admin');
    final canEdit = isAdmin || _roles.contains('professor');
    final isCurrentLevel = _selectedCap == s.level;

    return Scaffold(
      appBar: AppBar(
        title: Text('Avaliação - ${s.name}'),
        elevation: 0,
      ),
      body: StreamBuilder<List<StudentChecklist>>(
        stream: _checklistRepo.streamAllStudentChecklists(s.id),
        builder: (context, allChecklistsSnap) {
          final allChecklists = allChecklistsSnap.data ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header com informações do aluno
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Text(
                              s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkOrangeAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _capColorForLevel(s.level),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Touca Atual: ${s.level.name.toUpperCase()}',
                                    style: TextStyle(
                                      color: s.level == CapLevel.branca || s.level == CapLevel.amarela
                                          ? Colors.black87
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Seletor de nível (se houver histórico)
                      if (allChecklists.length > 1) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Histórico de Avaliações:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: allChecklists.map((checklist) {
                              final isSelected = checklist.cap == _selectedCap;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() => _selectedCap = checklist.cap);
                                    _checklistRepo.ensureStudentChecklistInitialized(s.id, checklist.cap).catchError((_) {});
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? _capColorForLevel(checklist.cap) : Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          checklist.cap.name.toUpperCase(),
                                          style: TextStyle(
                                            color: isSelected
                                                ? (checklist.cap == CapLevel.branca || checklist.cap == CapLevel.amarela ? Colors.black87 : Colors.white)
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (checklist.allCompleted) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Checklist area
                StreamBuilder<ChecklistTemplate?>(
                  stream: _checklistRepo.streamTemplate(_selectedCap),
                  builder: (context, tplSnap) {
                    // Se for touca branca, mostrar mensagem especial ao invés do checklist
                    if (_selectedCap == CapLevel.branca) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          color: Colors.amber.shade50,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.amber.shade300, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 100,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  '🎉 PARABÉNS! 🎉',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Você chegou no nível máximo!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'A touca BRANCA representa a excelência em natação. Continue praticando e inspire outros nadadores!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.shade200, width: 2),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star, color: Colors.amber.shade700, size: 28),
                                      const SizedBox(width: 12),
                                      Text(
                                        'NÍVEL MÁXIMO',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.star, color: Colors.amber.shade700, size: 28),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (tplSnap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final tpl = tplSnap.data;
                    if (tpl == null) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          color: AppColors.darkSurfaceVariant,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.warning, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        canEdit ? 'Templates não encontrados' : 'Avaliação não disponível',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  canEdit
                                    ? 'Execute o seed dos templates no menu lateral.'
                                    : 'Os templates de avaliação ainda não foram configurados. Entre em contato com o administrador.',
                                  style: const TextStyle(fontSize: 14, color: AppColors.darkTextPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return StreamBuilder<StudentChecklist?>(
                      stream: _checklistRepo.streamStudentChecklist(s.id, _selectedCap),
                      builder: (context, progSnap) {
                        if (progSnap.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final prog = progSnap.data;
                        if (prog == null) {
                          _checklistRepo.ensureStudentChecklistInitialized(s.id, _selectedCap).catchError((_) {});
                          return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.darkOrangeAccent,
                              ),
                            ),
                          );
                        }

                        final progressMap = { for (var p in prog.items) p.itemId : p };
                        final completedCount = prog.items.where((i) => i.completed).length;
                        final totalCount = tpl.items.length;
                        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header do checklist com progresso
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tpl.title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                      if (!isCurrentLevel)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'HISTÓRICO',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
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
                                            backgroundColor: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$completedCount/$totalCount',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Lista de itens do checklist
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: tpl.items.length,
                              itemBuilder: (context, index) {
                                final item = tpl.items[index];
                                final ip = progressMap[item.id];
                                final currentScore = ip?.score ?? 0;
                                final completed = ip?.completed ?? false;

                                return _ChecklistItemCard(
                                  item: item,
                                  score: currentScore,
                                  completed: completed,
                                  canEdit: canEdit && isCurrentLevel,
                                  onScoreChanged: (score) => _updateItemProgress(_selectedCap, item.id, score, completed),
                                );
                              },
                            ),

                            // Botão de promoção (só aparece se for o nível atual e estiver completo)
                            if (isCurrentLevel && prog.allCompleted && canEdit) ...[
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ElevatedButton.icon(
                                  onPressed: _promoteToNextCap,
                                  icon: const Icon(Icons.arrow_upward, size: 24),
                                  label: const Text(
                                    'Promover para Próximo Nível',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    minimumSize: const Size(double.infinity, 50),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
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

class _ChecklistItemCard extends StatelessWidget {
  final ChecklistItem item;
  final int score;
  final bool completed;
  final bool canEdit;
  final Function(int) onScoreChanged;

  const _ChecklistItemCard({
    required this.item,
    required this.score,
    required this.completed,
    required this.canEdit,
    required this.onScoreChanged,
  });

  Color _getScoreColor(int score) {
    if (score == 0) return Colors.grey.shade300;
    if (score <= 3) return Colors.red.shade400;
    if (score <= 6) return Colors.orange.shade400;
    if (score <= 8) return Colors.blue.shade400;
    return Colors.green.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: completed ? 2 : 1,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: completed
            ? BorderSide(color: Colors.green.shade400, width: 2)
            : BorderSide(color: AppColors.darkDivider, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do item em destaque
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: completed ? Colors.green.shade400 : AppColors.darkTextPrimary,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (completed)
                  Icon(Icons.check_circle, color: Colors.green.shade400, size: 24),
              ],
            ),

            if (item.description != null && item.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.darkDivider),
            const SizedBox(height: 12),

            // Nota com visual de chips
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nota',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(10, (i) {
                          final val = i + 1;
                          final isSelected = score == val;
                          return GestureDetector(
                            onTap: canEdit ? () => onScoreChanged(val) : null,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected ? _getScoreColor(val) : AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? _getScoreColor(val) : AppColors.darkDivider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$val',
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : AppColors.darkTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      if (score == 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: Colors.green.shade400),
                              const SizedBox(width: 4),
                              Text(
                                'Item concluído automaticamente',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green.shade400,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
