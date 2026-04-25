import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';
import '../../shared/responsive.dart';
import 'student_form_page.dart';
import '../../services/role_service.dart';
import '../widgets/app_drawer.dart';
import 'student_detail_page.dart';
import '../../theme/app_colors.dart';
import '../widgets/app_background.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final _repo = StudentRepository();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _roleService = const RoleService();
  Set<String> _roles = const {};
  bool _loadingRoles = true;
  String _currentQuery = '';
  late Stream<List<Student>> _studentsStream;
  int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    _updateStream();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_currentQuery.isEmpty) {
        _loadMore();
      }
    }
  }

  void _loadMore() {
    setState(() {
      _limit += 20;
      _updateStream();
    });
  }

  void _resetSearch() {
    setState(() {
      _searchController.clear();
      _currentQuery = '';
      _limit = 20;
      _updateStream();
    });
  }

  void _updateStream() {
    _studentsStream = _repo.streamStudents(
      nameQuery: _currentQuery,
      activeOnly: null,
      limit: _limit,
    );
  }

  Future<void> _loadRoles() async {
    final roles = await _roleService.getRoles(forceRefresh: true);
    if (mounted)
      setState(() {
        _roles = roles;
        _loadingRoles = false;
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final padding = EdgeInsets.all(Responsive.responsivePadding(context));

    final canCreateStudent =
        _roles.contains('admin') || _roles.contains('professor');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunos'),
        elevation: 0,
        actions: [
          if (!_loadingRoles && canCreateStudent)
            IconButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentFormPage()),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Adicionar Aluno',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Barra de pesquisa moderna
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightDivider, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.lightTextPrimary),
                  decoration: InputDecoration(
                    labelText: 'Pesquisar alunos',
                    labelStyle: const TextStyle(
                      color: AppColors.lightTextSecondary,
                    ),
                    hintText: 'Digite o nome do aluno...',
                    hintStyle: TextStyle(
                      color: AppColors.lightTextSecondary.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 24,
                      color: AppColors.lightTextSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.lightTextSecondary,
                            ),
                            onPressed: _resetSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentQuery = value;
                      _limit = 20;
                      _updateStream();
                    });
                  },
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
                    int crossAxisCount = (width / (targetTileWidth))
                        .floor()
                        .clamp(1, 6);
                    // Ajuste fino se sobrar muito espaço
                    if (crossAxisCount == 1 && width > targetTileWidth * 1.4)
                      crossAxisCount = 2;
                    final totalSpacing = spacing * (crossAxisCount - 1);
                    final tileWidth = (width - totalSpacing) / crossAxisCount;

                    return StreamBuilder<List<Student>>(
                      stream: _studentsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
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
                                  Icons.person_search,
                                  size: 80,
                                  color: AppColors.lightTextSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum aluno encontrado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.lightTextPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_searchController.text.isEmpty &&
                                    canCreateStudent) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Adicione o primeiro aluno',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing,
                            vertical: spacing,
                          ),
                          itemCount:
                              students.length +
                              (students.length >= _limit ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == students.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            final s = students[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _StudentCard(
                                student: s,
                                query: _currentQuery,
                              ),
                            );
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

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student, required this.query});
  final Student student;
  final String query;

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
      print('DEBUG: _openDetails called for ${student.name}');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StudentDetailPage(student: student)),
      );
    }

    final color = _capColor(student.level, context);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      color: Colors.white,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightDivider, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openDetails,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color:
                            student.level == CapLevel.branca ||
                                student.level == CapLevel.amarela
                            ? Colors.black87
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Text(
                            student.level.displayName,
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
                  if (!student.active)
                    Icon(
                      Icons.pause_circle,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                ],
              ),
              if (query.isNotEmpty) _buildMatchBadge(context),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.lightDivider),
              const SizedBox(height: 8),
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
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Ver Detalhes',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBadge(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();

    final cleanQuery = query.replaceAll(RegExp(r'[^\d]'), '');
    final matchStudentCpf =
        student.studentCpf
            ?.replaceAll(RegExp(r'[^\d]'), '')
            .contains(cleanQuery) ??
        false;
    final matchGuardianCpf =
        student.guardianCpf
            ?.replaceAll(RegExp(r'[^\d]'), '')
            .contains(cleanQuery) ??
        false;
    final matchPhone = student.phone
        .replaceAll(RegExp(r'[^\d]'), '')
        .contains(cleanQuery);

    String? label;
    IconData? icon;

    if (cleanQuery.isNotEmpty) {
      if (matchStudentCpf) {
        label = 'Match: CPF Aluno';
        icon = Icons.badge_outlined;
      } else if (matchGuardianCpf) {
        label = 'Match: CPF Responsável';
        icon = Icons.family_restroom_outlined;
      } else if (matchPhone) {
        label = 'Match: Telefone';
        icon = Icons.phone_android_outlined;
      }
    }

    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
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
        Icon(icon, size: 16, color: AppColors.lightTextSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
