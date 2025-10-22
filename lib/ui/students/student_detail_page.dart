import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';
import '../../services/role_service.dart';
import 'student_form_page.dart';
import '../../data/models/checklist.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../theme/app_colors.dart';
import 'student_evaluation_page.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage({super.key, required this.student, this.showInactiveActions = false});
  final Student student;
  final bool showInactiveActions; // true quando vindo da página de inativos

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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repo.deleteStudent(widget.student.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno removido com sucesso')),
        );
        Navigator.of(context).pop();
      }
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

  Future<void> _promoteToNextCap() async {
    final next = nextCapLevel(widget.student.level);
    if (next == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há próximo nível definido')));
      return;
    }
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
    await _repo.updateStudent(promoted);
    // Initialize checklist for new cap
    await _checklistRepo.ensureStudentChecklistInitialized(widget.student.id, next);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aluno promovido para ${next.name}')));
      Navigator.of(context).pop();
    }
  }

  void _goToEvaluation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentEvaluationPage(student: widget.student),
      ),
    );
  }

  Future<void> _toggleActiveStatus() async {
    final newStatus = !widget.student.active;
    final action = newStatus ? 'reativar' : 'desativar';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} aluno'),
        content: Text('Tem certeza que deseja $action este aluno?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );

    if (ok == true) {
      final updated = Student(
        id: widget.student.id,
        name: widget.student.name,
        phone: widget.student.phone,
        level: widget.student.level,
        age: widget.student.age,
        active: newStatus,
        studentCpf: widget.student.studentCpf,
        guardianCpf: widget.student.guardianCpf,
      );
      await _repo.updateStudent(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aluno ${newStatus ? "reativado" : "desativado"} com sucesso')),
        );
        Navigator.of(context).pop();
      }
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
                                'Touca ${s.level.displayName}',
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
                  _InfoChip(icon: Icons.phone, label: s.phone),
                  const SizedBox(height: 8),
                  _InfoChip(icon: Icons.cake, label: '${s.age} anos'),
                  if (s.studentCpf != null && s.studentCpf!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _InfoChip(icon: Icons.badge_outlined, label: 'CPF Aluno: ${s.studentCpf}'),
                  ],
                  const SizedBox(height: 8),
                  _InfoChip(icon: Icons.supervisor_account_outlined, label: 'CPF Responsável: ${s.guardianCpf}'),
                ],
              ),
            ),

            // Verificar se é touca branca - mostrar mensagem especial
            if (s.level == CapLevel.branca)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.amber.shade50,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.amber.shade300, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '🎉 PARABÉNS! 🎉',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Você chegou no nível máximo!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A touca BRANCA representa a excelência em natação. Continue praticando e inspire outros nadadores!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Botões de ação
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Botão de Avaliação - sempre visível
                  ElevatedButton.icon(
                    onPressed: _goToEvaluation,
                    icon: const Icon(Icons.assignment, size: 24),
                    label: const Text(
                      'Ver Avaliação',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.darkOrangeAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  if (canEdit) ...[
                    const SizedBox(height: 12),
                    Row(
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
                        const SizedBox(width: 12),
                        // Mostrar "Desativar" para alunos ativos, "Remover" apenas para inativos
                        if (s.active)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _toggleActiveStatus,
                              icon: const Icon(Icons.pause_circle_outline),
                              label: const Text('Desativar'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                foregroundColor: Colors.orange,
                              ),
                            ),
                          )
                        else if (widget.showInactiveActions && isAdmin)
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
                    ),
                  ],

                  // Botão de reativar para alunos inativos (na página de inativos)
                  if (!s.active && widget.showInactiveActions && canEdit) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _toggleActiveStatus,
                      icon: const Icon(Icons.restore, size: 24),
                      label: const Text(
                        'Reativar Aluno',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Card de progresso do checklist
            StreamBuilder<ChecklistTemplate?>(
              stream: _checklistRepo.streamTemplate(s.level),
              builder: (context, tplSnap) {
                if (tplSnap.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final tpl = tplSnap.data;
                if (tpl == null) return const SizedBox.shrink();

                return StreamBuilder<StudentChecklist?>(
                  stream: _checklistRepo.streamStudentChecklist(s.id, s.level),
                  builder: (context, progSnap) {
                    if (progSnap.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    final prog = progSnap.data;
                    if (prog == null) return const SizedBox.shrink();

                    final completedCount = prog.items.where((i) => i.completed).length;
                    final totalCount = tpl.items.length;
                    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Card(
                            color: AppColors.darkSurface,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Progresso da Avaliação',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkTextPrimary,
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
                                            minHeight: 10,
                                            backgroundColor: AppColors.darkSurfaceVariant,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              progress == 1.0 ? Colors.green.shade400 : AppColors.darkOrangeAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$completedCount/$totalCount',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
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
                          ),

                          // Botão de próximo nível
                          if (prog.allCompleted && canEdit) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
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
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
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
