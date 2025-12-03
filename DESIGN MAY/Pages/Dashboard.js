import React, { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Link } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { Plus, Search, Waves, TrendingUp } from "lucide-react";
import { motion } from "framer-motion";
import AlunoCard from "../components/alunos/AlunoCard";
import { Skeleton } from "@/components/ui/skeleton";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function Dashboard() {
  const [searchTerm, setSearchTerm] = useState("");
  const [darkMode, setDarkMode] = useState(false);

  useEffect(() => {
    base44.auth.me().then(user => {
      setDarkMode(user.tema_preferido === 'escuro');
    }).catch(() => {});
  }, []);

  const { data: alunos = [], isLoading } = useQuery({
    queryKey: ['alunos'],
    queryFn: () => base44.entities.Aluno.filter({ ativo: true }, '-created_date'),
  });

  const { data: avaliacoes = [] } = useQuery({
    queryKey: ['avaliacoes-recentes'],
    queryFn: () => base44.entities.Avaliacao.list('-created_date', 5),
  });

  const filteredAlunos = alunos.filter(aluno =>
    aluno.nome.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const estatisticas = {
    total: alunos.length,
    novas: avaliacoes.filter(a => {
      const dataAvaliacao = new Date(a.created_date);
      const hoje = new Date();
      const diffDias = (hoje - dataAvaliacao) / (1000 * 60 * 60 * 24);
      return diffDias <= 7;
    }).length
  };

  return (
    <div className="max-w-7xl mx-auto space-y-8">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4"
      >
        <div>
          <h1 className={`text-4xl font-bold flex items-center gap-3 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
            <Waves className="w-10 h-10" />
            Meus Alunos
          </h1>
          <p className={darkMode ? 'text-gray-400 mt-2' : 'text-[#607D8B] mt-2'}>
            Acompanhe o progresso de cada nadador
          </p>
        </div>
      </motion.div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.1 }}>
          <Card className={`border-none shadow-xl ${darkMode ? 'bg-gradient-to-br from-[#0277BD] to-[#01579B]' : 'bg-gradient-to-br from-[#4FC3F7] to-[#039BE5]'} text-white`}>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg font-medium opacity-90">Total de Alunos</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-5xl font-bold">{estatisticas.total}</p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.2 }}>
          <Card className={`border-none shadow-xl ${darkMode ? 'bg-gradient-to-br from-[#F57C00] to-[#E65100]' : 'bg-gradient-to-br from-[#FFD54F] to-[#FFA726]'} text-white`}>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg font-medium opacity-90">Avaliações (7 dias)</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-end gap-2">
                <p className="text-5xl font-bold">{estatisticas.novas}</p>
                <TrendingUp className="w-6 h-6 mb-2" />
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.3 }}>
          <Card className={`border-none shadow-xl ${darkMode ? 'bg-gradient-to-br from-[#00897B] to-[#00695C]' : 'bg-gradient-to-br from-[#26C6DA] to-[#00897B]'} text-white`}>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg font-medium opacity-90">Média de Idade</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-5xl font-bold">
                {alunos.length > 0 ? Math.round(alunos.reduce((sum, a) => sum + a.idade, 0) / alunos.length) : 0}
              </p>
              <p className="text-sm opacity-75 mt-1">anos</p>
            </CardContent>
          </Card>
        </motion.div>
      </div>

      <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.4 }} className="relative">
        <Search className={`absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`} />
        <Input
          type="text"
          placeholder="Buscar aluno pelo nome..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className={`pl-12 h-14 text-lg backdrop-blur-sm border-2 transition-colors shadow-md ${
            darkMode 
              ? 'bg-[#1a2332]/50 border-[#4FC3F7]/30 focus:border-[#26C6DA] text-white placeholder:text-gray-500' 
              : 'bg-white/90 border-[#4FC3F7]/30 focus:border-[#26C6DA]'
          }`}
        />
      </motion.div>

      {isLoading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array(6).fill(0).map((_, i) => (
            <Skeleton key={i} className="h-48 rounded-xl" />
          ))}
        </div>
      ) : filteredAlunos.length === 0 ? (
        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-center py-16">
          <div className="text-8xl mb-4">🏊</div>
          <h3 className={`text-2xl font-semibold mb-2 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
            {searchTerm ? "Nenhum aluno encontrado" : "Nenhum aluno cadastrado"}
          </h3>
          <p className={darkMode ? 'text-gray-400 mb-6' : 'text-[#607D8B] mb-6'}>
            {searchTerm ? "Tente buscar por outro nome" : "Comece cadastrando seu primeiro aluno!"}
          </p>
        </motion.div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredAlunos.map((aluno, index) => (
            <AlunoCard key={aluno.id} aluno={aluno} index={index} darkMode={darkMode} />
          ))}
        </div>
      )}

      {/* FAB - Floating Action Button */}
      <Link to={createPageUrl("NovoAluno")}>
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: 0.5, type: "spring" }}
          className="fixed bottom-8 right-8 z-50"
        >
          <Button
            size="lg"
            className="w-16 h-16 rounded-full shadow-2xl bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7] hover:from-[#00ACC1] hover:to-[#039BE5] text-white hover:scale-110 transition-transform"
          >
            <Plus className="w-8 h-8" />
          </Button>
        </motion.div>
      </Link>
    </div>
  );
}