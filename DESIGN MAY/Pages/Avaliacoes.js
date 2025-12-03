import React, { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Checkbox } from "@/components/ui/checkbox";
import { ClipboardList, ChevronDown, ChevronUp } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import NivelIndicator, { NIVEL_CONFIG } from "../components/alunos/NivelIndicator";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible";

// Definição das questões por nível de touca
const QUESTOES_POR_NIVEL = {
  branca: [
    "Adaptar-se ao meio líquido",
    "Submersão do rosto",
    "Abrir os olhos dentro d'água",
    "Flutuação ventral com auxílio",
    "Flutuação dorsal com auxílio",
    "Saltar da borda",
    "Movimentar-se livremente na água rasa",
    "Segurar na borda e movimentar as pernas"
  ],
  amarela: [
    "Flutuação ventral independente (5 segundos)",
    "Flutuação dorsal independente (5 segundos)",
    "Deslizar em decúbito ventral (3 metros)",
    "Deslizar em decúbito dorsal (3 metros)",
    "Pernada de crawl com prancha",
    "Respiração lateral básica",
    "Mergulhar e pegar objeto no fundo (parte rasa)",
    "Saltar da borda e retornar",
    "Movimentos de braço alternados na borda"
  ],
  verde: [
    "Nadar crawl completo (12 metros)",
    "Nadar costas completo (12 metros)",
    "Respiração bilateral no crawl",
    "Virada simples de crawl",
    "Virada simples de costas",
    "Pernada de peito com prancha",
    "Mergulho de saída básico",
    "Treino contínuo de 25 metros",
    "Coordenação braço-perna-respiração"
  ],
  azul: [
    "Nadar crawl (25 metros técnica correta)",
    "Nadar costas (25 metros técnica correta)",
    "Nadar peito completo (25 metros)",
    "Iniciação ao nado borboleta",
    "Virada olímpica de crawl",
    "Virada olímpica de costas",
    "Mergulho de saída competitivo",
    "Treino contínuo de 50 metros",
    "Controle de ritmo e respiração",
    "Saída do bloco (básico)"
  ],
  vermelha: [
    "Nadar crawl (50 metros técnica refinada)",
    "Nadar costas (50 metros técnica refinada)",
    "Nadar peito (50 metros técnica refinada)",
    "Nadar borboleta (25 metros)",
    "Medley individual 100m (25m cada nado)",
    "Viradas em todos os estilos",
    "Saída do bloco aperfeiçoada",
    "Treino de resistência 100m",
    "Técnica de chegada",
    "Treino intervalado básico"
  ],
  preta: [
    "Nadar todos os estilos 100m cada",
    "Medley individual 200m",
    "Técnica avançada de virada",
    "Técnica avançada de saída",
    "Nadar borboleta 50m",
    "Treino de velocidade",
    "Treino de resistência 200m+",
    "Estratégia de prova",
    "Análise técnica dos nados",
    "Preparação pré-competitiva",
    "Nadar 400m medley individual"
  ]
};

export default function Avaliacoes() {
  const [darkMode, setDarkMode] = useState(false);
  const [expandedAlunos, setExpandedAlunos] = useState({});
  const queryClient = useQueryClient();
  const urlParams = new URLSearchParams(window.location.search);
  const alunoIdFiltro = urlParams.get('aluno');

  useEffect(() => {
    base44.auth.me().then(user => {
      setDarkMode(user.tema_preferido === 'escuro');
    }).catch(() => {});
  }, []);

  const { data: alunos = [], isLoading: isLoadingAlunos } = useQuery({
    queryKey: ['alunos-ativos'],
    queryFn: () => base44.entities.Aluno.filter({ ativo: true }, 'nome'),
  });

  const { data: todasAvaliacoes = [], isLoading: isLoadingAvaliacoes } = useQuery({
    queryKey: ['todas-avaliacoes-agrupadas'],
    queryFn: () => base44.entities.Avaliacao.list('-created_date'),
  });

  const alunosFiltrados = alunoIdFiltro 
    ? alunos.filter(a => a.id === alunoIdFiltro)
    : alunos;

  const toggleExpanded = (alunoId) => {
    setExpandedAlunos(prev => ({
      ...prev,
      [alunoId]: !prev[alunoId]
    }));
  };

  const atualizarQuestaoMutation = useMutation({
    mutationFn: async ({ avaliacaoId, questaoKey, valor, aluno, nivel }) => {
      const avaliacoes = await base44.entities.Avaliacao.filter({ 
        aluno_id: aluno.id, 
        nivel: nivel 
      });
      
      let avaliacao = avaliacoes[0];
      const questoes = QUESTOES_POR_NIVEL[nivel];
      const totalQuestoes = questoes.length;

      if (!avaliacao) {
        const user = await base44.auth.me();
        const questoesRespondidas = { [questaoKey]: valor };
        const questoesConcluidas = valor ? 1 : 0;
        const progresso = (questoesConcluidas / totalQuestoes) * 100;

        return base44.entities.Avaliacao.create({
          aluno_id: aluno.id,
          aluno_nome: aluno.nome,
          nivel: nivel,
          data_avaliacao: new Date().toISOString().split('T')[0],
          questoes_respondidas: questoesRespondidas,
          questoes_concluidas: questoesConcluidas,
          total_questoes: totalQuestoes,
          progresso_percentual: progresso,
          concluido: progresso === 100,
          professor_nome: user.full_name || 'Professor'
        });
      } else {
        const questoesAtualizadas = {
          ...(avaliacao.questoes_respondidas || {}),
          [questaoKey]: valor
        };
        
        const questoesConcluidas = Object.values(questoesAtualizadas).filter(v => v === true).length;
        const progresso = (questoesConcluidas / totalQuestoes) * 100;

        return base44.entities.Avaliacao.update(avaliacao.id, {
          questoes_respondidas: questoesAtualizadas,
          questoes_concluidas: questoesConcluidas,
          progresso_percentual: progresso,
          concluido: progresso === 100
        });
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['todas-avaliacoes-agrupadas'] });
      queryClient.invalidateQueries({ queryKey: ['avaliacao-atual'] });
    },
  });

  const getAvaliacoesPorAluno = (alunoId) => {
    return todasAvaliacoes.filter(av => av.aluno_id === alunoId);
  };

  const getNiveisOrdenados = () => {
    return ['branca', 'amarela', 'verde', 'azul', 'vermelha', 'preta'];
  };

  if (isLoadingAlunos || isLoadingAvaliacoes) {
    return <div className="flex justify-center items-center h-96">
      <div className="text-6xl animate-bounce">🌊</div>
    </div>;
  }

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className={`text-4xl font-bold flex items-center gap-3 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
          <ClipboardList className="w-10 h-10" />
          Avaliações por Aluno
        </h1>
        <p className={darkMode ? 'text-gray-400 mt-2' : 'text-[#607D8B] mt-2'}>
          Acompanhe o progresso de cada nadador em todos os níveis
        </p>
      </motion.div>

      {alunosFiltrados.length === 0 ? (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-center py-16">
          <div className="text-8xl mb-4">📋</div>
          <h3 className={`text-2xl font-semibold mb-2 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
            Nenhum aluno encontrado
          </h3>
        </motion.div>
      ) : (
        <div className="space-y-6">
          {alunosFiltrados.map((aluno, index) => {
            const avaliacoesAluno = getAvaliacoesPorAluno(aluno.id);
            const avaliacaoAtual = avaliacoesAluno.find(av => av.nivel === aluno.nivel);
            const config = NIVEL_CONFIG[aluno.nivel];
            const isExpanded = expandedAlunos[aluno.id];

            return (
              <motion.div
                key={aluno.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
              >
                <Card className={`overflow-hidden border-2 shadow-xl ${
                  darkMode ? 'bg-[#1a2332]/90 border-gray-700' : 'bg-white/95'
                } backdrop-blur-sm`}>
                  <div className={`h-3 bg-gradient-to-r ${config.gradient}`}></div>
                  
                  {/* Header do Card */}
                  <CardHeader className="pb-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <div 
                          className="w-16 h-16 rounded-full flex items-center justify-center text-4xl shadow-lg"
                          style={{ backgroundColor: config.cor, border: `3px solid ${config.corBorda}` }}
                        >
                          {config.animal}
                        </div>
                        <div>
                          <CardTitle className={`text-2xl ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
                            {aluno.nome}
                          </CardTitle>
                          <Badge 
                            className="mt-2 text-sm font-medium"
                            style={{ 
                              backgroundColor: `${config.cor}30`,
                              color: config.corBorda,
                              border: `2px solid ${config.corBorda}`
                            }}
                          >
                            {config.nome} - {aluno.idade} anos
                          </Badge>
                        </div>
                      </div>
                    </div>
                  </CardHeader>

                  <CardContent className="space-y-4">
                    {/* Avaliação Atual (Nível Atual do Aluno) */}
                    <div className={`p-4 rounded-lg border-2 ${darkMode ? 'bg-[#0a1929]/50 border-[#4FC3F7]/30' : 'bg-[#E1F5FE] border-[#4FC3F7]'}`}>
                      <div className="flex justify-between items-center mb-3">
                        <h3 className={`font-semibold text-lg ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
                          Nível Atual: {config.nome}
                        </h3>
                        <span className={`text-sm font-bold ${darkMode ? 'text-gray-300' : 'text-[#263238]'}`}>
                          {avaliacaoAtual?.questoes_concluidas || 0}/{QUESTOES_POR_NIVEL[aluno.nivel].length}
                        </span>
                      </div>
                      <Progress 
                        value={avaliacaoAtual?.progresso_percentual || 0} 
                        className="h-3 mb-2"
                      />
                      <p className={`text-sm text-right ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>
                        {(avaliacaoAtual?.progresso_percentual || 0).toFixed(0)}% concluído
                      </p>

                      <div className="mt-4 space-y-2">
                        {QUESTOES_POR_NIVEL[aluno.nivel].map((questao, idx) => {
                          const questaoKey = `q${idx}`;
                          const isChecked = avaliacaoAtual?.questoes_respondidas?.[questaoKey] || false;

                          return (
                            <div key={questaoKey} className={`flex items-center space-x-3 p-2 rounded ${
                              darkMode ? 'hover:bg-[#1a2332]/50' : 'hover:bg-white'
                            }`}>
                              <Checkbox
                                id={`${aluno.id}-${aluno.nivel}-${questaoKey}`}
                                checked={isChecked}
                                onCheckedChange={(checked) => {
                                  atualizarQuestaoMutation.mutate({
                                    avaliacaoId: avaliacaoAtual?.id,
                                    questaoKey,
                                    valor: checked,
                                    aluno,
                                    nivel: aluno.nivel
                                  });
                                }}
                              />
                              <label
                                htmlFor={`${aluno.id}-${aluno.nivel}-${questaoKey}`}
                                className={`text-sm cursor-pointer flex-1 ${
                                  isChecked 
                                    ? `line-through ${darkMode ? 'text-gray-500' : 'text-gray-400'}` 
                                    : darkMode ? 'text-gray-200' : 'text-[#263238]'
                                }`}
                              >
                                {questao}
                              </label>
                            </div>
                          );
                        })}
                      </div>
                    </div>

                    {/* Avaliações Anteriores (Collapsible) */}
                    {getNiveisOrdenados().indexOf(aluno.nivel) > 0 && (
                      <Collapsible open={isExpanded} onOpenChange={() => toggleExpanded(aluno.id)}>
                        <CollapsibleTrigger asChild>
                          <Button 
                            variant="outline" 
                            className={`w-full ${darkMode ? 'border-gray-600 text-gray-300 hover:bg-[#1a2332]' : ''}`}
                          >
                            {isExpanded ? (
                              <>
                                <ChevronUp className="w-4 h-4 mr-2" />
                                Ocultar Níveis Anteriores
                              </>
                            ) : (
                              <>
                                <ChevronDown className="w-4 h-4 mr-2" />
                                Ver Níveis Anteriores
                              </>
                            )}
                          </Button>
                        </CollapsibleTrigger>
                        <CollapsibleContent>
                          <AnimatePresence>
                            <div className="mt-4 space-y-3">
                              {getNiveisOrdenados()
                                .slice(0, getNiveisOrdenados().indexOf(aluno.nivel))
                                .reverse()
                                .map(nivel => {
                                  const avaliacaoNivel = avaliacoesAluno.find(av => av.nivel === nivel);
                                  const configNivel = NIVEL_CONFIG[nivel];
                                  const progresso = avaliacaoNivel?.progresso_percentual || 0;
                                  const concluidas = avaliacaoNivel?.questoes_concluidas || 0;
                                  const total = QUESTOES_POR_NIVEL[nivel].length;

                                  return (
                                    <motion.div
                                      key={nivel}
                                      initial={{ opacity: 0, height: 0 }}
                                      animate={{ opacity: 1, height: 'auto' }}
                                      exit={{ opacity: 0, height: 0 }}
                                      className={`p-3 rounded-lg border ${
                                        darkMode 
                                          ? 'bg-[#0a1929]/30 border-gray-700' 
                                          : 'bg-gray-50 border-gray-200'
                                      }`}
                                    >
                                      <div className="flex items-center justify-between mb-2">
                                        <div className="flex items-center gap-2">
                                          <div 
                                            className="w-8 h-8 rounded-full flex items-center justify-center text-lg"
                                            style={{ backgroundColor: configNivel.cor, border: `2px solid ${configNivel.corBorda}` }}
                                          >
                                            {configNivel.animal}
                                          </div>
                                          <span className={`text-sm font-medium ${darkMode ? 'text-gray-300' : 'text-[#263238]'}`}>
                                            {configNivel.nome}
                                          </span>
                                        </div>
                                        <span className={`text-xs font-bold ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>
                                          {concluidas}/{total}
                                        </span>
                                      </div>
                                      <Progress value={progresso} className="h-2" />
                                      <p className={`text-xs text-right mt-1 ${darkMode ? 'text-gray-500' : 'text-[#607D8B]'}`}>
                                        {progresso.toFixed(0)}%
                                      </p>
                                    </motion.div>
                                  );
                                })}
                            </div>
                          </AnimatePresence>
                        </CollapsibleContent>
                      </Collapsible>
                    )}
                  </CardContent>
                </Card>
              </motion.div>
            );
          })}
        </div>
      )}
    </div>
  );
}