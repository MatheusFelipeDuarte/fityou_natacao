import React, { useState } from "react";
import { base44 } from "@/api/base44Client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { 
  ArrowLeft, 
  Edit, 
  UserX, 
  Phone, 
  User, 
  Calendar,
  Trophy,
  TrendingUp,
  CreditCard
} from "lucide-react";
import { motion } from "framer-motion";
import { format } from "date-fns";
import { ptBR } from "date-fns/locale";
import NivelIndicator, { NIVEL_CONFIG } from "../components/alunos/NivelIndicator";
import ProgressChart from "../components/avaliacoes/ProgressChart";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";

export default function DetalhesAluno() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const urlParams = new URLSearchParams(window.location.search);
  const alunoId = urlParams.get('id');
  const [showDesativar, setShowDesativar] = useState(false);

  const { data: aluno, isLoading } = useQuery({
    queryKey: ['aluno', alunoId],
    queryFn: async () => {
      const lista = await base44.entities.Aluno.filter({ id: alunoId });
      return lista[0];
    },
    enabled: !!alunoId,
  });

  const { data: avaliacoes = [] } = useQuery({
    queryKey: ['avaliacoes', alunoId],
    queryFn: () => base44.entities.Avaliacao.filter({ aluno_id: alunoId }, '-created_date'),
    enabled: !!alunoId,
  });

  const desativarMutation = useMutation({
    mutationFn: () => base44.entities.Aluno.update(alunoId, { ativo: false }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alunos'] });
      navigate(createPageUrl("Dashboard"));
    },
  });

  if (isLoading || !aluno) {
    return <div className="flex justify-center items-center h-96">
      <div className="text-6xl animate-bounce">🌊</div>
    </div>;
  }

  const config = NIVEL_CONFIG[aluno.nivel];
  const avaliacaoAtual = avaliacoes.find(a => a.nivel === aluno.nivel);

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex items-center justify-between"
      >
        <Button
          variant="ghost"
          onClick={() => navigate(createPageUrl("Dashboard"))}
          className="gap-2 text-[#01579B] hover:bg-[#4FC3F7]/20"
        >
          <ArrowLeft className="w-5 h-5" />
          Voltar
        </Button>
        <div className="flex gap-3">
          <Button
            variant="outline"
            onClick={() => navigate(createPageUrl("EditarAluno") + `?id=${alunoId}`)}
            className="gap-2 border-[#26C6DA] text-[#01579B] hover:bg-[#26C6DA]/10"
          >
            <Edit className="w-4 h-4" />
            Editar
          </Button>
          <Button
            variant="destructive"
            onClick={() => setShowDesativar(true)}
            className="gap-2 bg-[#FF8A65] hover:bg-[#F4511E]"
          >
            <UserX className="w-4 h-4" />
            Desativar
          </Button>
        </div>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
      >
        <Card className="bg-white/95 backdrop-blur-sm border-2 shadow-2xl" style={{ borderColor: config.corBorda }}>
          <div className={`h-3 bg-gradient-to-r ${config.gradient}`}></div>
          <CardContent className="p-8">
            <div className="flex flex-col md:flex-row gap-8">
              <div className="flex-1 space-y-6">
                <div className="flex items-center gap-6">
                  <div 
                    className="w-24 h-24 rounded-full flex items-center justify-center text-6xl shadow-xl relative"
                    style={{ backgroundColor: config.cor, border: `4px solid ${config.corBorda}` }}
                  >
                    {config.animal}
                    <div className="absolute -bottom-2 -right-2 w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-lg">
                      <span className="text-lg font-bold" style={{ color: config.corBorda }}>{aluno.idade}</span>
                    </div>
                  </div>
                  <div>
                    <h1 className="text-3xl font-bold text-[#01579B]">{aluno.nome}</h1>
                    <p className="text-[#607D8B] mt-1 flex items-center gap-2">
                      <Calendar className="w-4 h-4" />
                      {aluno.idade} anos
                    </p>
                    <Badge 
                      className="mt-3 text-sm font-medium px-4 py-1"
                      style={{ 
                        backgroundColor: `${config.cor}30`,
                        color: config.corBorda,
                        border: `2px solid ${config.corBorda}`
                      }}
                    >
                      {config.nome}
                    </Badge>
                  </div>
                </div>

                <div className="space-y-3 pt-4 border-t border-gray-200">
                  {aluno.cpf_aluno && (
                    <div className="flex items-center gap-3 text-[#263238]">
                      <CreditCard className="w-5 h-5 text-[#607D8B]" />
                      <div>
                        <p className="text-sm text-[#607D8B]">CPF do Aluno</p>
                        <p className="font-medium">{aluno.cpf_aluno}</p>
                      </div>
                    </div>
                  )}
                  {aluno.responsavel_nome && (
                    <div className="flex items-center gap-3 text-[#263238]">
                      <User className="w-5 h-5 text-[#607D8B]" />
                      <div>
                        <p className="text-sm text-[#607D8B]">Responsável</p>
                        <p className="font-medium">{aluno.responsavel_nome}</p>
                      </div>
                    </div>
                  )}
                  {aluno.responsavel_cpf && (
                    <div className="flex items-center gap-3 text-[#263238]">
                      <CreditCard className="w-5 h-5 text-[#607D8B]" />
                      <div>
                        <p className="text-sm text-[#607D8B]">CPF do Responsável</p>
                        <p className="font-medium">{aluno.responsavel_cpf}</p>
                      </div>
                    </div>
                  )}
                  {aluno.responsavel_telefone && (
                    <div className="flex items-center gap-3 text-[#263238]">
                      <Phone className="w-5 h-5 text-[#607D8B]" />
                      <div>
                        <p className="text-sm text-[#607D8B]">Telefone</p>
                        <p className="font-medium">{aluno.responsavel_telefone}</p>
                      </div>
                    </div>
                  )}
                  {aluno.observacoes && (
                    <div className="pt-3">
                      <p className="text-sm text-[#607D8B] mb-1">Observações</p>
                      <p className="text-[#263238] bg-gray-50 p-3 rounded-lg">{aluno.observacoes}</p>
                    </div>
                  )}
                </div>
              </div>

              <div className="flex-1 space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <Card className="bg-gradient-to-br from-[#FFD54F] to-[#FFA726] text-white border-none">
                    <CardContent className="p-4">
                      <Trophy className="w-8 h-8 mb-2 opacity-80" />
                      <p className="text-2xl font-bold">{avaliacoes.length}</p>
                      <p className="text-sm opacity-90">Avaliações</p>
                    </CardContent>
                  </Card>
                  <Card className="bg-gradient-to-br from-[#26C6DA] to-[#00897B] text-white border-none">
                    <CardContent className="p-4">
                      <TrendingUp className="w-8 h-8 mb-2 opacity-80" />
                      <p className="text-2xl font-bold">{avaliacaoAtual?.progresso_percentual?.toFixed(0) || 0}%</p>
                      <p className="text-sm opacity-90">Progresso</p>
                    </CardContent>
                  </Card>
                </div>

                <Card className="bg-gradient-to-br from-gray-50 to-white border-2 border-gray-200">
                  <CardContent className="p-6 text-center">
                    <p className="text-sm text-[#607D8B] mb-3">Nível Atual</p>
                    <NivelIndicator nivel={aluno.nivel} size="xl" showName={true} />
                  </CardContent>
                </Card>
              </div>
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {avaliacoes.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Card className="bg-white/95 backdrop-blur-sm border-2 border-[#26C6DA]/30 shadow-lg">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-[#01579B]">
                <span className="text-2xl">📚</span>
                Histórico de Avaliações
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {avaliacoes.map((avaliacao) => {
                  const configNivel = NIVEL_CONFIG[avaliacao.nivel];
                  return (
                    <div
                      key={avaliacao.id}
                      className="flex items-center justify-between p-4 bg-white rounded-lg border-2 border-gray-100 hover:border-[#4FC3F7] transition-colors"
                    >
                      <div className="flex items-center gap-4">
                        <div 
                          className="w-12 h-12 rounded-full flex items-center justify-center text-2xl"
                          style={{ backgroundColor: configNivel.cor, border: `2px solid ${configNivel.corBorda}` }}
                        >
                          {configNivel.animal}
                        </div>
                        <div>
                          <p className="font-medium text-[#263238]">
                            {configNivel.nome}
                          </p>
                          <p className="text-sm text-[#607D8B]">
                            {format(new Date(avaliacao.created_date), "dd/MM/yyyy", { locale: ptBR })}
                          </p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-bold text-[#01579B]">
                          {avaliacao.questoes_concluidas}/{avaliacao.total_questoes}
                        </p>
                        <p className="text-sm text-[#607D8B]">
                          {avaliacao.progresso_percentual?.toFixed(0)}%
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      )}

      <AlertDialog open={showDesativar} onOpenChange={setShowDesativar}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Desativar aluno?</AlertDialogTitle>
            <AlertDialogDescription>
              Tem certeza que deseja desativar {aluno.nome}? O aluno não aparecerá mais na lista principal, 
              mas poderá ser reativado depois na seção "Alunos Desativados".
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancelar</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => desativarMutation.mutate()}
              className="bg-[#FF8A65] hover:bg-[#F4511E]"
            >
              Desativar
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}