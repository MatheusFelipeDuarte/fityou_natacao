import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../data/models/student.dart';
import '../../data/repositories/student_repository.dart';

class ImportStudentsPage extends StatefulWidget {
  const ImportStudentsPage({super.key});

  @override
  State<ImportStudentsPage> createState() => _ImportStudentsPageState();
}

class _ImportStudentsPageState extends State<ImportStudentsPage> {
  final _repo = StudentRepository();
  bool _isImporting = false;

  void _copyTemplateToClipboard(BuildContext context) {
    // Conteúdo CSV para copiar
    final csvContent = '''name,age,phone,level,studentCpf,guardianCpf
João Silva,10,(11) 98765-4321,azul,12345678901,98765432100
Maria Santos,12,(21) 91234-5678,amarela,,11122233344
Pedro Oliveira,8,(31) 99999-8888,blue,55544433322,66677788899''';

    Clipboard.setData(ClipboardData(text: csvContent));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Conteúdo copiado! Cole em um editor de texto e salve como .csv'),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _importCSV() async {
    setState(() => _isImporting = true);

    try {
      // Selecionar arquivo
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withData: true, // Garante que os bytes sejam carregados
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isImporting = false);
        return;
      }

      final file = result.files.first;
      String csvString;

      // Tentar ler de diferentes formas dependendo da plataforma
      if (file.bytes != null) {
        // Web e algumas plataformas - usa bytes
        csvString = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        // Mobile - usa path
        final ioFile = File(file.path!);
        csvString = await ioFile.readAsString();
      } else {
        throw Exception('Não foi possível ler o arquivo');
      }

      // Decodificar CSV
      // Normalizar quebras de linha antes de processar
      csvString = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      final List<List<dynamic>> csvData = const CsvToListConverter().convert(
        csvString,
        eol: '\n',
        shouldParseNumbers: false, // Manter como string para melhor controle
      );

      if (csvData.isEmpty) {
        throw Exception('Arquivo CSV vazio');
      }

      // Debug: imprimir o CSV lido
      print('CSV Data (${csvData.length} linhas): $csvData');

      // Validar cabeçalho
      final headers = csvData.first.map((e) => e.toString().trim().toLowerCase()).toList();
      print('Headers encontrados (${headers.length} colunas): $headers');

      final expectedHeaders = ['name', 'age', 'phone', 'level', 'studentcpf', 'guardiancpf'];

      // Validação mais flexível do cabeçalho
      bool hasAllHeaders = true;
      for (final expected in expectedHeaders) {
        final found = headers.any((h) => h.contains(expected.toLowerCase()));
        if (!found) {
          hasAllHeaders = false;
          print('Cabeçalho não encontrado: $expected');
        }
      }

      if (!hasAllHeaders) {
        throw Exception('Cabeçalho inválido. Esperado: name,age,phone,level,studentCpf,guardianCpf\nEncontrado: ${headers.join(",")}');
      }

      // Processar linhas
      final students = <Student>[];
      final errors = <String>[];

      print('Total de linhas no CSV: ${csvData.length}');

      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        print('Processando linha ${i + 1}: $row (${row.length} colunas)');

        if (row.isEmpty || row.every((e) => e.toString().trim().isEmpty)) {
          print('Linha ${i + 1} está vazia, pulando...');
          continue; // Pular linhas vazias
        }

        try {
          final student = _parseStudentFromRow(row, i + 1);
          students.add(student);
          print('Aluno adicionado com sucesso: ${student.name}');
        } catch (e) {
          print('Erro na linha ${i + 1}: $e');
          errors.add('Linha ${i + 1}: $e');
        }
      }

      print('Total de alunos processados: ${students.length}');
      print('Total de erros: ${errors.length}');

      if (students.isEmpty) {
        throw Exception('Nenhum aluno válido encontrado no arquivo.\nErros: ${errors.join(", ")}');
      }

      // Mostrar diálogo de confirmação
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Importação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${students.length} aluno(s) serão importados.'),
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${errors.length} erro(s) encontrado(s):',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...errors.take(5).map((e) => Text('• $e', style: const TextStyle(fontSize: 12))),
                if (errors.length > 5)
                  Text('... e mais ${errors.length - 5} erro(s)', style: const TextStyle(fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        setState(() => _isImporting = false);
        return;
      }

      // Importar alunos
      int successCount = 0;
      int failCount = 0;

      for (final student in students) {
        try {
          await _repo.addStudent(student);
          successCount++;
        } catch (e) {
          failCount++;
        }
      }

      if (!mounted) return;
      setState(() => _isImporting = false);

      // Mostrar resultado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ $successCount aluno(s) importado(s) com sucesso!' +
            (failCount > 0 ? '\n✗ $failCount falha(s)' : ''),
          ),
          backgroundColor: failCount > 0 ? Colors.orange : Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );

      // Voltar para a página de alunos
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      setState(() => _isImporting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao importar: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  bool _validateHeaders(List<String> headers, List<String> expected) {
    if (headers.length < expected.length) return false;
    for (int i = 0; i < expected.length; i++) {
      if (!headers[i].contains(expected[i].replaceAll('cpf', ''))) {
        return false;
      }
    }
    return true;
  }

  Student _parseStudentFromRow(List<dynamic> row, int lineNumber) {
    if (row.length < 6) {
      throw Exception('Número insuficiente de colunas');
    }

    final name = row[0].toString().trim();
    final ageStr = row[1].toString().trim();
    final phone = row[2].toString().trim();
    final levelStr = row[3].toString().trim().toLowerCase();
    final studentCpf = row[4].toString().trim();
    final guardianCpf = row[5].toString().trim();

    // Validações
    if (name.isEmpty) throw Exception('Nome é obrigatório');
    if (guardianCpf.isEmpty) throw Exception('CPF do responsável é obrigatório');

    final age = int.tryParse(ageStr);
    if (age == null || age < 0 || age > 120) {
      throw Exception('Idade inválida');
    }

    if (phone.isEmpty) throw Exception('Telefone é obrigatório');

    // Parse level (aceita português e inglês)
    final level = _parseLevel(levelStr);
    if (level == null) {
      throw Exception('Nível inválido: $levelStr');
    }

    // Validar CPFs
    final cleanGuardianCpf = guardianCpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanGuardianCpf.length != 11) {
      throw Exception('CPF do responsável deve ter 11 dígitos');
    }

    String? cleanStudentCpf;
    if (studentCpf.isNotEmpty) {
      cleanStudentCpf = studentCpf.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanStudentCpf.length != 11) {
        throw Exception('CPF do aluno deve ter 11 dígitos');
      }
    }

    return Student(
      id: '', // Será gerado pelo Firestore
      name: name,
      phone: phone,
      level: level,
      age: age,
      active: true,
      studentCpf: cleanStudentCpf,
      guardianCpf: cleanGuardianCpf,
    );
  }

  CapLevel? _parseLevel(String level) {
    final levelMap = {
      'azul': CapLevel.azul,
      'blue': CapLevel.azul,
      'amarela': CapLevel.amarela,
      'amarelo': CapLevel.amarela,
      'yellow': CapLevel.amarela,
      'laranja': CapLevel.laranja,
      'orange': CapLevel.laranja,
      'vermelha': CapLevel.vermelha,
      'vermelho': CapLevel.vermelha,
      'red': CapLevel.vermelha,
      'preta': CapLevel.preta,
      'preto': CapLevel.preta,
      'black': CapLevel.preta,
      'branca': CapLevel.branca,
      'branco': CapLevel.branca,
      'white': CapLevel.branca,
    };

    return levelMap[level.toLowerCase()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Alunos'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Card(
                  color: AppColors.darkOrangeAccent.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 80,
                          color: AppColors.darkOrangeAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Importação de Alunos via Planilha',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Importe múltiplos alunos de uma vez usando uma planilha CSV',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.darkTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Instruções
                Card(
                  color: AppColors.darkSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade400),
                            const SizedBox(width: 12),
                            const Text(
                              'Como preparar sua planilha',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _InstructionStep(
                          number: '1',
                          title: 'Copie o modelo',
                          description: 'Clique no botão abaixo para copiar o conteúdo do exemplo',
                        ),
                        const SizedBox(height: 12),
                        _InstructionStep(
                          number: '2',
                          title: 'Crie o arquivo CSV',
                          description: 'Cole em um editor de texto e salve como "alunos.csv"',
                        ),
                        const SizedBox(height: 12),
                        _InstructionStep(
                          number: '3',
                          title: 'Preencha os dados',
                          description: 'Edite o arquivo CSV com os dados dos seus alunos',
                        ),
                        const SizedBox(height: 12),
                        _InstructionStep(
                          number: '4',
                          title: 'Importe o arquivo',
                          description: 'Volte aqui e faça o upload do arquivo preenchido',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Formato da planilha
                Card(
                  color: AppColors.darkSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.table_chart, color: Colors.green.shade400),
                            const SizedBox(width: 12),
                            const Text(
                              'Formato da Planilha',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'A planilha deve conter as seguintes colunas (com cabeçalho):',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FieldDescription(
                          field: 'name',
                          description: 'Nome completo do aluno',
                          required: true,
                          example: 'João Silva',
                        ),
                        _FieldDescription(
                          field: 'age',
                          description: 'Idade do aluno',
                          required: true,
                          example: '10',
                        ),
                        _FieldDescription(
                          field: 'phone',
                          description: 'Telefone com DDD',
                          required: true,
                          example: '(11) 98765-4321',
                        ),
                        _FieldDescription(
                          field: 'level',
                          description: 'Nível da touca (em português ou inglês)',
                          required: true,
                          example: 'azul, amarela, laranja, vermelha, preta, branca OU blue, yellow, orange, red, black, white',
                        ),
                        _FieldDescription(
                          field: 'studentCpf',
                          description: 'CPF do aluno (apenas números)',
                          required: false,
                          example: '12345678901',
                        ),
                        _FieldDescription(
                          field: 'guardianCpf',
                          description: 'CPF do responsável (apenas números)',
                          required: true,
                          example: '98765432100',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Exemplo visual
                Card(
                  color: AppColors.darkSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.purple.shade400),
                            const SizedBox(width: 12),
                            const Text(
                              'Exemplo Visual',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.darkDivider),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SelectableText(
                              'name,age,phone,level,studentCpf,guardianCpf\n'
                              'João Silva,10,(11) 98765-4321,azul,12345678901,98765432100\n'
                              'Maria Santos,12,(21) 91234-5678,amarela,,11122233344\n'
                              'Pedro Oliveira,8,(31) 99999-8888,blue,55544433322,66677788899',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.green.shade300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '💡 Dica: Se o aluno não tiver CPF, deixe a coluna studentCpf vazia (mas mantenha a vírgula)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botão de copiar (substituindo o download)
                ElevatedButton.icon(
                  onPressed: () => _copyTemplateToClipboard(context),
                  icon: const Icon(Icons.content_copy, size: 24),
                  label: const Text(
                    'Copiar Modelo da Planilha',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: AppColors.darkOrangeAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Botão de upload (AGORA FUNCIONAL!)
                ElevatedButton.icon(
                  onPressed: _isImporting ? null : _importCSV,
                  icon: _isImporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.upload, size: 24),
                  label: Text(
                    _isImporting ? 'Importando...' : 'Importar Planilha',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _InstructionStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.darkOrangeAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldDescription extends StatelessWidget {
  final String field;
  final String description;
  final bool required;
  final String example;

  const _FieldDescription({
    required this.field,
    required this.description,
    required this.required,
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkOrangeAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  field,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkOrangeAccent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: required ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  required ? 'OBRIGATÓRIO' : 'OPCIONAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: required ? Colors.red.shade300 : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Exemplo: $example',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade300,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
