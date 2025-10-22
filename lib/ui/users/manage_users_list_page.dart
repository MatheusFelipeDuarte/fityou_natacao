import 'package:flutter/material.dart';
import '../../data/models/user_account.dart';
import '../../data/repositories/user_repository.dart';
import 'manage_users_page.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ManageUsersListPage extends StatefulWidget {
  const ManageUsersListPage({super.key});

  @override
  State<ManageUsersListPage> createState() => _ManageUsersListPageState();
}

class _ManageUsersListPageState extends State<ManageUsersListPage> {
  final _repo = UserRepository();
  final _functions = FirebaseFunctions.instance;

  Future<void> _confirmDelete(UserAccount u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir usuário'),
        content: Text('Tem certeza que deseja excluir ${u.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      try {
  final callable = _functions.httpsCallable('deleteUser');
  await callable.call({ 'uid': u.id, 'email': u.email });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário excluído com sucesso')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const ManageUsersPage()),
              );
              if (changed == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuário salvo')),
                );
              }
            },
            icon: const Icon(Icons.person_add),
            tooltip: 'Adicionar Usuário',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: StreamBuilder<List<UserAccount>>(
        stream: _repo.streamUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                ],
              ),
            );
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum usuário cadastrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione professores e administradores',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              final isAdmin = u.roles.contains('admin');
              final isProfessor = u.roles.contains('professor');

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: isAdmin
                            ? Colors.purple.shade100
                            : Colors.blue.shade100,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.school,
                          color: isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Informações
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (u.roles.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'SEM PERMISSÕES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: u.roles.map((role) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: role == 'admin'
                                          ? Colors.purple.shade50
                                          : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: role == 'admin'
                                            ? Colors.purple.shade300
                                            : Colors.blue.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      role.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: role == 'admin'
                                            ? Colors.purple.shade700
                                            : Colors.blue.shade700,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                      // Botão deletar
                      IconButton(
                        onPressed: () => _confirmDelete(u),
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                        tooltip: 'Excluir usuário',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                 ),
               );
             },
           );
        },
        ),
      ),
    );
  }
}
