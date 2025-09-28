import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  CapLevel _level = CapLevel.white;
  bool _active = true;
  bool _busy = false;
  final _repo = StudentRepository();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final student = Student(
      id: '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      level: _level,
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      active: _active,
    );
    await _repo.addStudent(student);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo aluno')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o e-mail' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefone (DDD+Número)'),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      final x = (v ?? '').replaceAll(RegExp(r'\D'), '');
                      if (x.length < 10) return 'Informe DDD e número';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Idade'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Informe uma idade válida';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CapLevel>(
                    value: _level,
                    decoration: const InputDecoration(labelText: 'Nível (cor da touca)'),
                    items: CapLevel.values
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _level = v ?? CapLevel.white),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _active,
                    title: const Text('Ativo'),
                    onChanged: (v) => setState(() => _active = v),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
