import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';
import '../../shared/responsive.dart';
import 'student_form_page.dart';
import '../../services/role_service.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final _repo = StudentRepository();
  final _searchController = TextEditingController();
  final _roleService = const RoleService();
  Set<String> _roles = const {};
  bool _loadingRoles = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final roles = await _roleService.getRoles(forceRefresh: true);
    if (mounted) setState(() { _roles = roles; _loadingRoles = false; });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isTablet ? 3 : 2;
    final padding = EdgeInsets.all(Responsive.responsivePadding(context));

    final canCreateStudent = _roles.contains('admin') || _roles.contains('professor');
    return Scaffold(
      appBar: AppBar(title: const Text('Alunos')),
      body: Padding(
        padding: padding,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar por nome',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Student>>(
                stream: _repo.streamStudents(nameQuery: _searchController.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  final students = snapshot.data ?? [];
                  if (students.isEmpty) {
                    return const Center(child: Text('Nenhum aluno encontrado'));
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isTablet ? 1.9 : 1.6,
                    ),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return _StudentCard(student: s);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (!_loadingRoles && canCreateStudent)
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentFormPage()),
                );
                setState(() {});
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});
  final Student student;

  Color _capColor(CapLevel level, BuildContext context) {
    switch (level) {
      case CapLevel.white:
        return Colors.grey.shade200;
      case CapLevel.yellow:
        return Colors.yellow.shade600;
      case CapLevel.orange:
        return Colors.orange.shade600;
      case CapLevel.green:
        return Colors.green.shade600;
      case CapLevel.blue:
        return Colors.blue.shade600;
      case CapLevel.red:
        return Colors.red.shade600;
      case CapLevel.black:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _capColor(student.level, context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(student.name, style: Theme.of(context).textTheme.titleLarge),
                ),
                if (!student.active)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Inativo', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.red)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(student.email, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text('Telefone: ${student.phone}', style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
