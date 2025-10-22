# Sistema de Checklists por Touca

## Visão Geral

Este sistema permite que professores e administradores acompanhem o progresso dos alunos através de checklists específicos para cada nível de touca. Cada aluno mantém seu próprio histórico de checklists para todas as toucas que já passou.

## Ordem de Progressão das Toucas

1. **Azul** → Amarela (12 itens)
2. **Amarela** → Laranja (12 itens)
3. **Laranja** → Vermelha (13 itens)
4. **Vermelha** → Preta (13 itens)
5. **Preta** → Branca (8 itens)
6. **Branca** (nível final)

## Estrutura do Banco de Dados (Firestore)

### Coleção: `checklist_templates`
Contém os templates de checklist para cada touca. Cada documento representa uma touca.

**Documento ID**: `{cap.name}` (ex: `blue`, `yellow`, `orange`, `red`, `black`, `white`)

**Campos**:
- `cap`: string - nome da touca (ex: "blue")
- `title`: string - título do template (ex: "Touca Azul → Amarela")
- `items`: array de objetos:
  - `id`: string - identificador único do item
  - `title`: string - título do item
  - `description`: string (opcional) - descrição detalhada
  - `order`: number - ordem de exibição
  - `maxScore`: number - nota máxima (padrão: 10)
- `updatedAt`: timestamp

### Coleção: `student_checklists`
Contém o progresso de cada aluno para cada touca. Permite manter histórico completo.

**Documento ID**: `{studentId}_{cap.name}` (ex: `abc123_blue`)

**Campos**:
- `studentId`: string - ID do aluno
- `cap`: string - nome da touca
- `items`: array de objetos:
  - `itemId`: string - ID do item do template
  - `score`: number - nota de 1 a 10 (0 = não avaliado)
  - `completed`: boolean - se o item foi concluído
  - `updatedAt`: timestamp - última atualização
- `createdAt`: timestamp - quando o checklist foi iniciado
- `updatedAt`: timestamp - última modificação

## Como Usar

### 1. Popular os Templates (Primeira Vez)

**Acesso**: Menu lateral (drawer) → "Popular Templates de Checklist" (somente admin)

1. Faça login como administrador
2. Abra o menu lateral
3. Clique em "Popular Templates de Checklist"
4. Clique no botão "Popular Templates"
5. Aguarde a confirmação de sucesso

⚠️ **Importante**: Esta ação só precisa ser executada UMA VEZ. Ela criará todos os templates no Firestore.

### 2. Visualizar e Atualizar Checklist do Aluno

1. Acesse a lista de alunos
2. Clique em um aluno para ver seus detalhes
3. Role até a seção "Checklist"
4. Você verá o checklist da touca atual do aluno com:
   - Título de cada item
   - Dropdown para dar nota (1-10)
   - Checkbox "Concluído"

### 3. Avaliar Itens do Checklist

- **Dar nota**: Selecione um valor de 1 a 10 no dropdown
- **Marcar como concluído**: Marque a checkbox ao lado
  - Se marcar como concluído sem nota, a nota padrão será 1

### 4. Promover Aluno para Próximo Nível

Quando **todos os itens** do checklist estiverem marcados como concluídos:
- Um botão "Próximo nível" aparecerá
- Ao clicar:
  - O nível da touca do aluno será atualizado
  - Um novo checklist será inicializado para a nova touca
  - O checklist anterior ficará salvo para consulta

## Histórico de Checklists

Cada aluno mantém um documento separado para cada touca que passou. Isso permite:
- Consultar o desempenho em toucas anteriores
- Comparar progresso entre diferentes períodos
- Manter registro completo da evolução do aluno

**Exemplo**: Um aluno que está na touca vermelha terá documentos:
- `{studentId}_blue` (checklist da touca azul - completo)
- `{studentId}_yellow` (checklist da touca amarela - completo)
- `{studentId}_orange` (checklist da touca laranja - completo)
- `{studentId}_red` (checklist da touca vermelha - em andamento)

## Permissões

- **Admin e Professor**: Podem visualizar e editar checklists, promover alunos
- **Aluno**: (não implementado ainda - apenas visualização futura)

## Conteúdo dos Checklists

### Azul → Amarela (12 itens)
1. Respiração (boca/Nariz)
2. Pernada Crawl C/ Espaguete (respiração frontal)
3. Foguetinho e cachorrinho (com espaguete)
4. Foguetinho S/ Auxílio
5. Cachorrinho S/ Auxílio
6. Flutuação (frente)
7. Flutuação (costas)
8. Pernada Crawl C/ Prancha (Pegada Alta)
9. Pernada Crawl C/ Prancha (Pegada baixa C/ Respiração Frontal)
10. Pernada Costas C/ Prancha (No Peito)
11. Pernada costas C/ Prancha (No Joelho)
12. Submerso

### Amarela → Laranja (12 itens)
1. Streamline (foguete desligado)
2. Foguetinho Respiração Frontal (sem mexer as mãos)
3. Braçada Crawl (C/ Prancha)
4. Crawl Completo (C/ Prancha)
5. Respiração Lateral do Crawl C/ Auxilio e S/ Auxílio
6. Crawl Completo
7. Pernada Costas (Braço Acima)
8. Braçada Costas (Prancha Joelho)
9. Pernada Costas (Braço Lateral)
10. Costas Completo
11. Braçada Peito C/Perna Crawl
12. Submerso

### Laranja → Vermelha (13 itens)
1. Crawl (aperfeiçoamento)
2. Costas (aperfeiçoamento)
3. Costas (Duplo)
4. Braçada Peito (Perna Crawl)
5. Pernada Peito de Costas (com espaguete)
6. Pernada de Peito (com Prancha)
7. Inicialção nada peito
8. Rotação (frente/costas)
9. Ondulação Braço Foguete
10. Ondulação Braço Lateral
11. Saída de costas (flecha)
12. Saída de costas (submerso)
13. Saltos - Joelho / Em pé

### Vermelha → Preta (13 itens)
1. Crawl (aperfeiçoamento)
2. Costas (aperfeiçoamento)
3. Peito (aperfeiçoamento)
4. Ondulação (aperfeiçoamento)
5. Ondulação Lateral (com auxílio)
6. Ondulação Lateral (sem auxílio)
7. Borboleta (iniciação)
8. Virada simples (Crawl, Costas, Peito, Borbo)
9. Viranda Olímpica (Crawl/costas)
10. Saltos (aperfeiçoamento)
11. Saída Filipinas
12. Ondulação Braço a Frente e lateral
13. Condicionamento (10 minutos)

### Preta → Branca (8 itens)
1. Crawl
2. Costas
3. Peito
4. Borboleta (aperfeiçoamento)
5. Saltos (aperfeiçoamento)
6. Viradas (aperfeiçoamento)
7. Viradas e saídas - Medley
8. Resistência 30 minutos (Crawl)

## Arquivos do Sistema

- `lib/data/models/checklist.dart` - Modelos de dados
- `lib/data/repositories/checklist_repository.dart` - Operações com Firestore
- `lib/data/seed_checklist_templates.dart` - Script de seed dos templates
- `lib/ui/admin/seed_templates_page.dart` - Página para popular templates
- `lib/ui/students/student_detail_page.dart` - Visualização e edição de checklists

## Observações Técnicas

- Os checklists são reativos (StreamBuilder) - atualizações aparecem em tempo real
- As atualizações usam transactions do Firestore para evitar condições de corrida
- O sistema inicializa automaticamente o checklist quando o aluno acessa a página pela primeira vez
- Touca `green` não faz parte da progressão principal (pode ser ajustado se necessário)

