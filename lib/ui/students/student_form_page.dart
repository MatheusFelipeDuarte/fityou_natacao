import 'package:flutter/material.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key, this.initial});

  /// Use para edição com dados preenchidos
  const StudentFormPage.edit({super.key, required this.initial});

  final Student? initial;

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _studentCpfController = TextEditingController();
  final _guardianCpfController = TextEditingController();
  CapLevel _level = CapLevel.azul;
  bool _active = true;
  bool _busy = false;
  final _repo = StudentRepository();

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _nameController.text = s.name;
      _phoneController.text = s.phone;
      _ageController.text = s.age.toString();
      _studentCpfController.text = s.studentCpf ?? '';
      _guardianCpfController.text = s.guardianCpf;
      _level = s.level;
      _active = s.active;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _studentCpfController.dispose();
    _guardianCpfController.dispose();
    super.dispose();
  }

  String? _validateCpf(String? value, {required bool required}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Informe o CPF' : null;
    }
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    return null;
  }

  Future<String?> _validateStudentCpfUnique(String? value) async {
    // Primeiro valida o formato
    final formatError = _validateCpf(value, required: false);
    if (formatError != null) return formatError;

    // Se está vazio, não precisa verificar unicidade (é opcional)
    if (value == null || value.trim().isEmpty) return null;

    // Verifica se já existe outro aluno com este CPF
    final isInUse = await _repo.isStudentCpfInUse(
      value.trim(),
      excludeId: widget.initial?.id,
    );

    if (isInUse) {
      return 'Este CPF já está cadastrado para outro aluno';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validação assíncrona adicional do CPF do aluno
    final studentCpfValue = _studentCpfController.text.trim();
    if (studentCpfValue.isNotEmpty) {
      final cpfError = await _validateStudentCpfUnique(studentCpfValue);
      if (cpfError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cpfError),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _busy = false);
        return;
      }
    }

    setState(() => _busy = true);
    final base = Student(
      id: widget.initial?.id ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      level: _level,
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      active: _active,
      studentCpf: studentCpfValue.isEmpty ? null : studentCpfValue,
      guardianCpf: _guardianCpfController.text.trim(),
    );
    if (widget.initial == null) {
      await _repo.addStudent(base);
    } else {
      await _repo.updateStudent(base);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Novo Aluno' : 'Editar Aluno'),
        elevation: 0,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ícone/Avatar no topo
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Icon(
                          widget.initial == null ? Icons.person_add : Icons.edit,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.initial == null ? 'Adicionar Novo Aluno' : 'Editar Dados do Aluno',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha todos os campos obrigatórios',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        hintText: '(XX) XXXXX-XXXX',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        final x = (v ?? '').replaceAll(RegExp(r'\D'), '');
                        if (x.length < 10) return 'Informe DDD e número';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _studentCpfController,
                      decoration: InputDecoration(
                        labelText: 'CPF do Aluno (Opcional)',
                        hintText: 'XXX.XXX.XXX-XX',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        helperText: 'Opcional - deixe em branco se não tiver',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateCpf(v, required: false),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _guardianCpfController,
                      decoration: InputDecoration(
                        labelText: 'CPF do Responsável *',
                        hintText: 'XXX.XXX.XXX-XX',
                        prefixIcon: const Icon(Icons.supervisor_account_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        helperText: '* Campo obrigatório',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => _validateCpf(v, required: true),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: InputDecoration(
                        labelText: 'Idade',
                        prefixIcon: const Icon(Icons.cake_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Informe uma idade válida';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CapLevel>(
                      value: _level,
                      decoration: InputDecoration(
                        labelText: 'Nível (Touca)',
                        prefixIcon: const Icon(Icons.pool),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: CapLevel.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _getCapColor(e),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(e.name.toUpperCase()),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _level = v ?? CapLevel.azul),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        value: _active,
                        title: const Text(
                          'Aluno Ativo',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _active ? 'Aluno pode frequentar as aulas' : 'Aluno está inativo',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        onChanged: (v) => setState(() => _active = v),
                        activeColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _busy ? null : _submit,
                            icon: _busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(widget.initial == null ? Icons.add : Icons.save),
                            label: Text(widget.initial == null ? 'Adicionar' : 'Salvar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCapColor(CapLevel level) {
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
