import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/role_service.dart';
import '../students/students_page.dart';
import '../students/inactive_students_page.dart';
import '../users/manage_users_list_page.dart';
import '../profile/profile_page.dart';
import '../admin/seed_templates_page.dart';
import '../evaluations/all_evaluations_page.dart';
import '../import/import_students_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _roleService = const RoleService();
  Set<String> _roles = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await _roleService.getRoles(forceRefresh: true);
    if (mounted) setState(() => _roles = r);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = _roles.contains('admin');

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header moderno com gradiente
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
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email?.split('@').first ?? 'Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (isAdmin || _roles.contains('professor')) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Text(
                      isAdmin ? 'ADMINISTRADOR' : 'PROFESSOR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(
            icon: Icons.people,
            title: 'Alunos',
            subtitle: 'Gerenciar alunos',
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const StudentsPage()),
              );
            },
          ),
          _DrawerItem(
            icon: Icons.person_off,
            title: 'Alunos Desativados',
            subtitle: 'Ver alunos inativos',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InactiveStudentsPage()),
              );
            },
          ),
          _DrawerItem(
            icon: Icons.assignment,
            title: 'Avaliações',
            subtitle: 'Ver todas as avaliações',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AllEvaluationsPage()),
              );
            },
          ),
          if (isAdmin || _roles.contains('professor'))
            _DrawerItem(
              icon: Icons.upload_file,
              title: 'Importar Alunos',
              subtitle: 'Importar via planilha',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImportStudentsPage()),
                );
              },
            ),
          if (isAdmin)
            _DrawerItem(
              icon: Icons.admin_panel_settings,
              title: 'Professores & Admins',
              subtitle: 'Gerenciar permissões',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageUsersListPage()),
                );
              },
            ),
          if (isAdmin)
            _DrawerItem(
              icon: Icons.checklist_rtl,
              title: 'Templates de Checklist',
              subtitle: 'Configurar templates',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SeedTemplatesPage()),
                );
              },
            ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _DrawerItem(
            icon: Icons.person_outline,
            title: 'Meu Perfil',
            subtitle: 'Configurações da conta',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.logout,
            title: 'Sair',
            subtitle: 'Fazer logout',
            isDestructive: true,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Widget customizado para itens do menu
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade700 : null;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.shade50
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: color?.withOpacity(0.7) ?? Colors.grey.shade600,
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
