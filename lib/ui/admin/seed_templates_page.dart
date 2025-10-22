// filepath: lib/ui/admin/seed_templates_page.dart
import 'package:flutter/material.dart';
import '../../data/seed_checklist_templates.dart';

class SeedTemplatesPage extends StatefulWidget {
  const SeedTemplatesPage({super.key});

  @override
  State<SeedTemplatesPage> createState() => _SeedTemplatesPageState();
}

class _SeedTemplatesPageState extends State<SeedTemplatesPage> {
  bool _isSeeding = false;
  String _message = '';

  Future<void> _runSeed() async {
    setState(() {
      _isSeeding = true;
      _message = 'Populando templates no Firestore...';
    });

    try {
      final seeder = ChecklistTemplateSeeder();
      await seeder.seedAllTemplates();
      setState(() {
        _isSeeding = false;
        _message = '✅ Templates criados com sucesso!\n\n'
            '• Azul → Amarela (12 itens)\n'
            '• Amarela → Laranja (12 itens)\n'
            '• Laranja → Vermelha (13 itens)\n'
            '• Vermelha → Preta (13 itens)\n'
            '• Preta → Branca (8 itens)';
      });
    } catch (e) {
      setState(() {
        _isSeeding = false;
        _message = '❌ Erro ao criar templates: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular Templates de Checklist')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Esta ação vai criar os templates de checklist para todas as toucas no Firestore.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Templates a serem criados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Touca Azul → Amarela (12 itens)'),
            const Text('• Touca Amarela → Laranja (12 itens)'),
            const Text('• Touca Laranja → Vermelha (13 itens)'),
            const Text('• Touca Vermelha → Preta (13 itens)'),
            const Text('• Touca Preta → Branca (8 itens)'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSeeding ? null : _runSeed,
              child: _isSeeding
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Criando templates...'),
                      ],
                    )
                  : const Text('Popular Templates'),
            ),
            const SizedBox(height: 24),
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _message.startsWith('✅')
                      ? Colors.green.withAlpha(26)
                      : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.startsWith('✅') ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

