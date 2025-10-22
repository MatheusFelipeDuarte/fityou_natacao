import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';
import '../../services/role_service.dart';
import 'student_form_page.dart';
import '../../data/models/checklist.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../theme/app_colors.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage({super.key, required this.student});
  final Student student;

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  final _repo = StudentRepository();
  final _roleService = const RoleService();
  Set<String> _roles = const {};
  final _checklistRepo = ChecklistRepository();

  @override
  void initState() {
    super.initState();
    _load();
    // ensure the checklist exists for the student's current cap
    _checklistRepo.ensureStudentChecklistInitialized(widget.student.id, widget.student.level).catchError((e) {
      debugPrint('Erro ao inicializar checklist: $e');
    });
  }

  Future<void> _load() async {
    final r = await _roleService.getRoles(forceRefresh: true);
    if (mounted) setState(() { _roles = r; });
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover aluno'),
        content: const Text('Tem certeza que deseja remover este aluno? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true) {
      await _repo.deleteStudent(widget.student.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _edit() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StudentFormPage.edit(initial: widget.student)),
    );
    if (changed == true && mounted) {
      // Volta para a lista; o grid é reativo ao Firestore
      Navigator.of(context).pop();
    }
  }

  Future<void> _updateItemProgress(CapLevel cap, String itemId, int score, bool completed) async {
    final updated = StudentChecklistItemProgress(itemId: itemId, score: score, completed: completed);
    await _checklistRepo.updateItemProgress(widget.student.id, cap, updated);
  }

  Future<void> _promoteToNextCap() async {
    final next = nextCapLevel(widget.student.level);
    if (next == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há próximo nível definido')));
      return;
    }
    final promoted = Student(
      id: widget.student.id,
      name: widget.student.name,
      email: widget.student.email,
      phone: widget.student.phone,
      level: next,
      age: widget.student.age,
      active: widget.student.active,
    );
    await _repo.updateStudent(promoted);
    // Initialize checklist for new cap
    await _checklistRepo.ensureStudentChecklistInitialized(widget.student.id, next);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aluno promovido para ${next.name}')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final isAdmin = _roles.contains('admin');
    final canEdit = isAdmin || _roles.contains('professor');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Aluno'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 32,
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
                                fontSize: 24,
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
                                'Touca ${s.level.name.toUpperCase()}',
                                style: TextStyle(
                                  color: s.level == CapLevel.white || s.level == CapLevel.yellow
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
                      if (!s.active)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'INATIVO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _InfoChip(icon: Icons.email, label: s.email),
                  const SizedBox(height: 8),
                  _InfoChip(icon: Icons.phone, label: s.phone),
                  const SizedBox(height: 8),
                  _InfoChip(icon: Icons.cake, label: '${s.age} anos'),
                ],
              ),
            ),

            // Botões de ação
            if (canEdit)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _edit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remover'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Checklist area
            StreamBuilder<ChecklistTemplate?>(
              stream: _checklistRepo.streamTemplate(s.level),
              builder: (context, tplSnap) {
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
                                Icon(Icons.warning_rounded, color: AppColors.warning, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Templates não encontrados',
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
                            const Text(
                              'Execute o seed dos templates:\n'
                              '1. Abra o menu lateral (☰)\n'
                              '2. Clique em "Popular Templates de Checklist"\n'
                              '3. Clique em "Popular Templates"',
                              style: TextStyle(fontSize: 14, color: AppColors.darkTextPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return StreamBuilder<StudentChecklist?>(
                  stream: _checklistRepo.streamStudentChecklist(s.id, s.level),
                  builder: (context, progSnap) {
                    if (progSnap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final prog = progSnap.data;
                    if (prog == null) {
                      _checklistRepo.ensureStudentChecklistInitialized(s.id, s.level).catchError((_) {});
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
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tpl.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
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
                        const SizedBox(height: 16),

                        // Lista de itens do checklist em blocos
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
                              onScoreChanged: (score) => _updateItemProgress(s.level, item.id, score, completed),
                              onCompletedChanged: (checked) {
                                final newScore = (currentScore == 0 && checked) ? 1 : currentScore;
                                _updateItemProgress(s.level, item.id, newScore, checked);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Botão de próximo nível
                        if (prog.allCompleted && canEdit)
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
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _capColorForLevel(CapLevel level) {
    switch (level) {
      case CapLevel.blue:
        return Colors.blue.shade600;
      case CapLevel.yellow:
        return Colors.yellow.shade600;
      case CapLevel.orange:
        return Colors.orange.shade600;
      case CapLevel.red:
        return Colors.red.shade600;
      case CapLevel.black:
        return Colors.black87;
      case CapLevel.white:
        return Colors.grey.shade200;
    }
  }
}

// Widget para exibir informações com ícone
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget para cada item do checklist em formato de card
class _ChecklistItemCard extends StatelessWidget {
  final ChecklistItem item;
  final int score;
  final bool completed;
  final Function(int) onScoreChanged;
  final Function(bool) onCompletedChanged;

  const _ChecklistItemCard({
    required this.item,
    required this.score,
    required this.completed,
    required this.onScoreChanged,
    required this.onCompletedChanged,
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

            // Nota e checkbox na parte inferior
            Row(
              children: [
                // Nota com visual de chips
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
                          return InkWell(
                            onTap: () => onScoreChanged(val),
                            borderRadius: BorderRadius.circular(8),
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
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Checkbox de conclusão
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: completed ? Colors.green.shade900.withOpacity(0.3) : AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Checkbox(
                        value: completed,
                        onChanged: (checked) => onCompletedChanged(checked ?? false),
                        activeColor: Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Concluído',
                      style: TextStyle(
                        fontSize: 11,
                        color: completed ? Colors.green.shade400 : AppColors.darkTextSecondary,
                        fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
