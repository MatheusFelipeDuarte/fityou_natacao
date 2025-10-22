// filepath: lib/data/seed_checklist_templates.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/student.dart';
import 'models/checklist.dart';

/// Script para popular os templates de checklist no Firestore.
/// Execute uma vez para criar os documentos iniciais.
class ChecklistTemplateSeeder {
  final FirebaseFirestore _db;

  ChecklistTemplateSeeder({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> seedAllTemplates() async {
    print('Iniciando seed dos templates de checklist...');

    await _seedBlueToYellow();
    await _seedYellowToOrange();
    await _seedOrangeToRed();
    await _seedRedToBlack();
    await _seedBlackToWhite();

    print('Seed concluído com sucesso!');
  }

  // Azul -> Amarela
  Future<void> _seedBlueToYellow() async {
    final template = ChecklistTemplate(
      cap: CapLevel.azul,
      id: 'azul',
      title: 'Touca Azul → Amarela',
      items: [
        ChecklistItem(id: 'respiracao_boca_nariz', title: 'Respiração (boca/Nariz)', order: 1),
        ChecklistItem(id: 'pernada_crawl_espaguete', title: 'Pernada Crawl C/ Espaguete (respiração frontal)', order: 2),
        ChecklistItem(id: 'foguetinho_cachorrinho_espaguete', title: 'Foguetinho e cachorrinho (com espaguete)', order: 3),
        ChecklistItem(id: 'foguetinho_sem_auxilio', title: 'Foguetinho S/ Auxílio', order: 4),
        ChecklistItem(id: 'cachorrinho_sem_auxilio', title: 'Cachorrinho S/ Auxílio', order: 5),
        ChecklistItem(id: 'flutuacao_frente', title: 'Flutuação (frente)', order: 6),
        ChecklistItem(id: 'flutuacao_costas', title: 'Flutuação (costas)', order: 7),
        ChecklistItem(id: 'pernada_crawl_prancha_alta', title: 'Pernada Crawl C/ Prancha (Pegada Alta)', order: 8),
        ChecklistItem(id: 'pernada_crawl_prancha_baixa', title: 'Pernada Crawl C/ Prancha (Pegada baixa C/ Respiração Frontal)', order: 9),
        ChecklistItem(id: 'pernada_costas_prancha_peito', title: 'Pernada Costas C/ Prancha (No Peito)', order: 10),
        ChecklistItem(id: 'pernada_costas_prancha_joelho', title: 'Pernada costas C/ Prancha (No Joelho)', order: 11),
        ChecklistItem(id: 'submerso', title: 'Submerso', order: 12),
      ],
    );
    await _saveTemplate(template);
    print('✓ Template Azul → Amarela criado');
  }

  // Amarela -> Laranja
  Future<void> _seedYellowToOrange() async {
    final template = ChecklistTemplate(
      cap: CapLevel.amarela,
      id: 'amarela',
      title: 'Touca Amarela → Laranja',
      items: [
        ChecklistItem(id: 'streamline', title: 'Streamline (foguete desligado)', order: 1),
        ChecklistItem(id: 'foguetinho_resp_frontal', title: 'Foguetinho Respiração Frontal (sem mexer as mãos)', order: 2),
        ChecklistItem(id: 'bracada_crawl_prancha', title: 'Braçada Crawl (C/ Prancha)', order: 3),
        ChecklistItem(id: 'crawl_completo_prancha', title: 'Crawl Completo (C/ Prancha)', order: 4),
        ChecklistItem(id: 'respiracao_lateral_crawl', title: 'Respiração Lateral do Crawl C/ Auxilio e S/ Auxílio.', order: 5),
        ChecklistItem(id: 'crawl_completo', title: 'Crawl Completo.', order: 6),
        ChecklistItem(id: 'pernada_costas_braco_acima', title: 'Pernada Costas (Braço Acima).', order: 7),
        ChecklistItem(id: 'bracada_costas_prancha_joelho', title: 'Braçada Costas (Prancha Joelho).', order: 8),
        ChecklistItem(id: 'pernada_costas_braco_lateral', title: 'Pernada Costas (Braço Lateral).', order: 9),
        ChecklistItem(id: 'costas_completo', title: 'Costas Completo', order: 10),
        ChecklistItem(id: 'bracada_peito_perna_crawl', title: 'Braçada Peito C/Perna Crawl', order: 11),
        ChecklistItem(id: 'submerso', title: 'Submerso', order: 12),
      ],
    );
    await _saveTemplate(template);
    print('✓ Template Amarela → Laranja criado');
  }

  // Laranja -> Vermelha
  Future<void> _seedOrangeToRed() async {
    final template = ChecklistTemplate(
      cap: CapLevel.laranja,
      id: 'laranja',
      title: 'Touca Laranja → Vermelha',
      items: [
        ChecklistItem(id: 'crawl_aperfeicoamento', title: 'Crawl (aperfeiçoamento)', order: 1),
        ChecklistItem(id: 'costas_aperfeicoamento', title: 'Costas (aperfeiçoamento)', order: 2),
        ChecklistItem(id: 'costas_duplo', title: 'Costas (Duplo)', order: 3),
        ChecklistItem(id: 'bracada_peito_perna_crawl', title: 'Braçada Peito (Perna Crawl)', order: 4),
        ChecklistItem(id: 'pernada_peito_costas_espaguete', title: 'Pernada Peito de Costas (com espaguete)', order: 5),
        ChecklistItem(id: 'pernada_peito_prancha', title: 'Pernada de Peito (com Prancha)', order: 6),
        ChecklistItem(id: 'iniciacao_nado_peito', title: 'Inicialção nada peito', order: 7),
        ChecklistItem(id: 'rotacao_frente_costas', title: 'Rotação (frente/costas)', order: 8),
        ChecklistItem(id: 'ondulacao_braco_foguete', title: 'Ondulação Braço Foguete', order: 9),
        ChecklistItem(id: 'ondulacao_braco_lateral', title: 'Ondulação Braço Lateral', order: 10),
        ChecklistItem(id: 'saida_costas_flecha', title: 'Saída de costas (flecha)', order: 11),
        ChecklistItem(id: 'saida_costas_submerso', title: 'Saída de costas (submerso)', order: 12),
        ChecklistItem(id: 'saltos_joelho_pe', title: 'Saltos - Joelho / Em pé', order: 13),
      ],
    );
    await _saveTemplate(template);
    print('✓ Template Laranja → Vermelha criado');
  }

  // Vermelha -> Preta
  Future<void> _seedRedToBlack() async {
    final template = ChecklistTemplate(
      cap: CapLevel.vermelha,
      id: 'vermelha',
      title: 'Touca Vermelha → Preta',
      items: [
        ChecklistItem(id: 'crawl_aperfeicoamento', title: 'Crawl (aperfeiçoamento)', order: 1),
        ChecklistItem(id: 'costas_aperfeicoamento', title: 'Costas (aperfeiçoamento)', order: 2),
        ChecklistItem(id: 'peito_aperfeicoamento', title: 'Peito (aperfeiçoamento)', order: 3),
        ChecklistItem(id: 'ondulacao_aperfeicoamento', title: 'Ondulação (aperfeiçoamento)', order: 4),
        ChecklistItem(id: 'ondulacao_lateral_auxilio', title: 'Ondulação Lateral (com auxílio)', order: 5),
        ChecklistItem(id: 'ondulacao_lateral_sem_auxilio', title: 'Ondulação Lateral (sem auxílio)', order: 6),
        ChecklistItem(id: 'borboleta_iniciacao', title: 'Borboleta (iniciação)', order: 7),
        ChecklistItem(id: 'virada_simples', title: 'Virada simples (Crawl, Costas, Peito, Borbo)', order: 8),
        ChecklistItem(id: 'virada_olimpica', title: 'Viranda Olímpica (Crawl/costas)', order: 9),
        ChecklistItem(id: 'saltos_aperfeicoamento', title: 'Saltos (aperfeiçoamento)', order: 10),
        ChecklistItem(id: 'saida_filipinas', title: 'Saída Filipinas', order: 11),
        ChecklistItem(id: 'ondulacao_braco_frente_lateral', title: 'Ondulação Braço a Frente e lateral', order: 12),
        ChecklistItem(id: 'condicionamento_10min', title: 'Condicionamento (10 minutos)', order: 13),
      ],
    );
    await _saveTemplate(template);
    print('✓ Template Vermelha → Preta criado');
  }

  // Preta -> Branca
  Future<void> _seedBlackToWhite() async {
    final template = ChecklistTemplate(
      cap: CapLevel.preta,
      id: 'preta',
      title: 'Touca Preta → Branca',
      items: [
        ChecklistItem(id: 'crawl', title: 'Crawl', order: 1),
        ChecklistItem(id: 'costas', title: 'Costas', order: 2),
        ChecklistItem(id: 'peito', title: 'Peito', order: 3),
        ChecklistItem(id: 'borboleta_aperfeicoamento', title: 'Borboleta (aperfeiçoamento)', order: 4),
        ChecklistItem(id: 'saltos_aperfeicoamento', title: 'Saltos (aperfeiçoamento)', order: 5),
        ChecklistItem(id: 'viradas_aperfeicoamento', title: 'Viradas (aperfeiçoamento)', order: 6),
        ChecklistItem(id: 'viradas_saidas_medley', title: 'Viradas e saídas - Medley', order: 7),
        ChecklistItem(id: 'resistencia_30min', title: 'Resistência 30 minutos (Crawl)', order: 8),
      ],
    );
    await _saveTemplate(template);
    print('✓ Template Preta → Branca criado');
  }

  Future<void> _saveTemplate(ChecklistTemplate template) async {
    final docRef = _db.collection('checklist_templates').doc(template.id);
    await docRef.set(template.toMap());
  }
}

