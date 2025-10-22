import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';
import '../../shared/responsive.dart';
import '../../services/role_service.dart';
import '../widgets/app_drawer.dart';
import 'student_detail_page.dart';
import '../../theme/app_colors.dart';

class InactiveStudentsPage extends StatefulWidget {
  const InactiveStudentsPage({super.key});

  @override
  State<InactiveStudentsPage> createState() => _InactiveStudentsPageState();
}

class _InactiveStudentsPageState extends State<InactiveStudentsPage> {
  final _repo = StudentRepository();
  final _searchController = TextEditingController();
  final _roleService = const RoleService();
  Set<String> _roles = const {};

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final roles = await _roleService.getRoles(forceRefresh: true);
    if (mounted) setState(() { _roles = roles; });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final padding = EdgeInsets.all(Responsive.responsivePadding(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos Desativados'),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        color: AppColors.darkBackground,
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Banner informativo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade900.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade700, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alunos desativados não aparecem na lista principal',
                        style: TextStyle(
                          color: Colors.orange.shade200,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Barra de pesquisa moderna
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.darkDivider,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.darkTextPrimary),
                  decoration: InputDecoration(
                    labelText: 'Pesquisar alunos desativados',
                    labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
                    hintText: 'Digite o nome do aluno...',
                    hintStyle: TextStyle(color: AppColors.darkTextSecondary.withValues(alpha: 0.6)),
                    prefixIcon: const Icon(Icons.search, size: 24, color: AppColors.darkTextSecondary),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Cálculo responsivo das colunas e proporção
                    final width = constraints.maxWidth;
                    final spacing = isTablet ? 16.0 : 12.0;
                    final targetTileWidth = isTablet ? 360.0 : 300.0;
                    int crossAxisCount = (width / (targetTileWidth)).floor().clamp(1, 6);
                    // Ajuste fino se sobrar muito espaço
                    if (crossAxisCount == 1 && width > targetTileWidth * 1.4) crossAxisCount = 2;
                    final totalSpacing = spacing * (crossAxisCount - 1);
                    final tileWidth = (width - totalSpacing) / crossAxisCount;
                    // Altura desejada ajustada para evitar overflow do conteúdo interno
                    final desiredHeight = isTablet ? 240.0 : 260.0;
                    final aspectRatio = tileWidth / desiredHeight;

                    return StreamBuilder<List<Student>>(
                      stream: _repo.streamStudents(nameQuery: _searchController.text, activeOnly: false),
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
                        final students = snapshot.data ?? [];
                        if (students.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 80,
                                  color: Colors.green.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum aluno desativado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Todos os alunos estão ativos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final s = students[index];
                            return _InactiveStudentCard(student: s, isAdmin: _roles.contains('admin'));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InactiveStudentCard extends StatelessWidget {
  const _InactiveStudentCard({required this.student, required this.isAdmin});
  final Student student;
  final bool isAdmin;

  Color _capColor(CapLevel level, BuildContext context) {
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
    void _openDetails() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StudentDetailPage(student: student, showInactiveActions: true)),
      );
    }
    final color = _capColor(student.level, context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      color: AppColors.darkSurface.withOpacity(0.7),
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.red.shade900,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openDetails,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.red.withOpacity(0.1),
        highlightColor: Colors.red.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header com avatar e status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: color.withValues(alpha: 0.5),
                        child: Text(
                          student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: student.level == CapLevel.branca || student.level == CapLevel.amarela
                                ? Colors.black87
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.pause, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Text(
                            student.level.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'INATIVO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: AppColors.darkDivider),
              const SizedBox(height: 10),
              // Informações de contato
              _InfoRow(icon: Icons.phone_outlined, text: student.phone),
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.cake_outlined, text: '${student.age} anos'),
              const SizedBox(height: 8),
              // Botão de ver detalhes
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _openDetails,
                  icon: Icon(Icons.arrow_forward, size: 16, color: Colors.red.shade400),
                  label: Text('Ver Detalhes', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.red.shade900.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para linhas de informação
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.darkTextSecondary.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
