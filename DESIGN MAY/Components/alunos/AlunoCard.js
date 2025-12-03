import React from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Eye, ClipboardList } from "lucide-react";
import { useQuery } from "@tanstack/react-query";
import { base44 } from "@/api/base44Client";

const NIVEL_CONFIG = {
  branca: {
    cor: "#FFFFFF",
    corBorda: "#E0E0E0",
    animal: "🐠",
    nome: "Peixinho Dourado",
    gradient: "from-gray-100 to-gray-200"
  },
  amarela: {
    cor: "#FFD54F",
    corBorda: "#FBC02D",
    animal: "🐚",
    nome: "Cavalo-Marinho",
    gradient: "from-yellow-200 to-yellow-300"
  },
  verde: {
    cor: "#26C6DA",
    corBorda: "#00ACC1",
    animal: "🐬",
    nome: "Golfinho",
    gradient: "from-cyan-200 to-cyan-300"
  },
  azul: {
    cor: "#4FC3F7",
    corBorda: "#039BE5",
    animal: "🐢",
    nome: "Tartaruga-Marinha",
    gradient: "from-blue-200 to-blue-300"
  },
  vermelha: {
    cor: "#FF8A65",
    corBorda: "#F4511E",
    animal: "🦈",
    nome: "Tubarão",
    gradient: "from-red-200 to-red-300"
  },
  preta: {
    cor: "#263238",
    corBorda: "#000000",
    animal: "🐋",
    nome: "Orca",
    gradient: "from-gray-700 to-gray-800"
  }
};

export default function AlunoCard({ aluno, index, darkMode }) {
  const navigate = useNavigate();
  const config = NIVEL_CONFIG[aluno.nivel] || NIVEL_CONFIG.branca;

  const { data: avaliacaoAtual } = useQuery({
    queryKey: ['avaliacao-atual', aluno.id, aluno.nivel],
    queryFn: async () => {
      const avaliacoes = await base44.entities.Avaliacao.filter({ 
        aluno_id: aluno.id, 
        nivel: aluno.nivel 
      }, '-created_date');
      return avaliacoes[0] || null;
    },
  });

  const handleClickDetalhes = () => {
    navigate(createPageUrl("DetalhesAluno") + `?id=${aluno.id}`);
  };

  const handleClickAvaliacoes = (e) => {
    e.stopPropagation();
    navigate(createPageUrl("Avaliacoes") + `?aluno=${aluno.id}`);
  };

  const progresso = avaliacaoAtual?.progresso_percentual || 0;
  const questoesConcluidas = avaliacaoAtual?.questoes_concluidas || 0;
  const totalQuestoes = avaliacaoAtual?.total_questoes || 0;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      whileHover={{ scale: 1.03, y: -5 }}
      className="cursor-pointer"
      onClick={handleClickDetalhes}
    >
      <Card className={`overflow-hidden border-2 hover:shadow-2xl transition-all duration-300 ${
        darkMode ? 'bg-[#1a2332]/90 border-gray-700' : 'bg-white/95'
      } backdrop-blur-sm`} style={{ borderColor: config.corBorda }}>
        <div className={`h-2 bg-gradient-to-r ${config.gradient}`}></div>
        <CardContent className="p-6">
          <div className="flex items-center gap-4 mb-4">
            <div 
              className="w-16 h-16 rounded-full flex items-center justify-center text-4xl shadow-lg relative"
              style={{ backgroundColor: config.cor, border: `3px solid ${config.corBorda}` }}
            >
              {config.animal}
              <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-md">
                <span className="text-xs font-bold" style={{ color: config.corBorda }}>{aluno.idade}</span>
              </div>
            </div>

            <div className="flex-1 min-w-0">
              <h3 className={`font-semibold text-lg truncate ${darkMode ? 'text-white' : 'text-[#263238]'}`}>
                {aluno.nome}
              </h3>
              <p className={`text-sm mb-2 ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>
                {aluno.idade} anos
              </p>
              <Badge 
                className="text-xs font-medium"
                style={{ 
                  backgroundColor: `${config.cor}30`,
                  color: config.corBorda,
                  border: `1px solid ${config.corBorda}`
                }}
              >
                {config.nome}
              </Badge>
            </div>
          </div>

          {/* Progresso da avaliação atual */}
          <div className={`space-y-2 p-3 rounded-lg ${darkMode ? 'bg-[#0a1929]/50' : 'bg-gray-50'}`}>
            <div className="flex justify-between items-center">
              <span className={`text-sm font-medium flex items-center gap-2 ${darkMode ? 'text-gray-300' : 'text-[#263238]'}`}>
                <ClipboardList className="w-4 h-4" />
                Progresso Atual
              </span>
              <span className={`text-sm font-bold ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
                {questoesConcluidas}/{totalQuestoes}
              </span>
            </div>
            <Progress value={progresso} className="h-2" />
            <p className={`text-xs text-right ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>
              {progresso.toFixed(0)}% concluído
            </p>
          </div>

          <Button
            onClick={handleClickAvaliacoes}
            variant="outline"
            className={`w-full mt-4 gap-2 ${
              darkMode 
                ? 'border-[#4FC3F7] text-[#4FC3F7] hover:bg-[#4FC3F7]/10' 
                : 'border-[#26C6DA] text-[#01579B] hover:bg-[#26C6DA]/10'
            }`}
          >
            <Eye className="w-4 h-4" />
            Ver Avaliações
          </Button>
        </CardContent>
      </Card>
    </motion.div>
  );
}