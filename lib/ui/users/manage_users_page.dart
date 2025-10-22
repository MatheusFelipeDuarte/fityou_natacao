import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_account.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _admin = false;
  bool _professor = true;
  bool _busy = false;
  String? _status;
  final _userRepo = UserRepository();

  Future<void> _createOrUpdateUser() async {
    setState(() { _busy = true; _status = null; });
    try {
      final roles = <String>[];
      if (_admin) roles.add('admin');
      if (_professor) roles.add('professor');

      // Exemplo de callable function: setUserRoles({email, password?, roles})
      final callable = FirebaseFunctions.instance.httpsCallable('setUserRoles');
      final result = await callable.call({
        'email': _emailController.text.trim(),
        'password': _passwordController.text.isEmpty ? null : _passwordController.text,
        'roles': roles,
      });
      final data = result.data as Map;
      final uid = (data['uid'] ?? '').toString();
      // Também persiste/atualiza na coleção 'users' com uid
      final doc = UserAccount(id: uid, email: _emailController.text.trim(), roles: roles);
      await _userRepo.createOrUpdate(doc);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário/roles atualizados com sucesso')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Professores/Admins')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha (opcional se já existir)'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _admin,
                  title: const Text('Administrador'),
                  onChanged: (v) => setState(() => _admin = v),
                ),
                SwitchListTile(
                  value: _professor,
                  title: const Text('Professor'),
                  onChanged: (v) => setState(() => _professor = v),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _busy ? null : _createOrUpdateUser,
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Salvar'),
                ),
                if (_status != null) ...[
                  const SizedBox(height: 12),
                  Text(_status!),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
