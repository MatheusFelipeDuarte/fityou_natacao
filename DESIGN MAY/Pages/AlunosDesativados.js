import React, { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { RefreshCw, UserCheck, Trash2 } from "lucide-react";
import { motion } from "framer-motion";
import NivelIndicator from "../components/alunos/NivelIndicator";
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

export default function AlunosDesativados() {
  const queryClient = useQueryClient();
  const [darkMode, setDarkMode] = useState(false);
  const [alunoParaReativar, setAlunoParaReativar] = useState(null);
  const [alunoParaRemover, setAlunoParaRemover] = useState(null);

  useEffect(() => {
    base44.auth.me().then(user => {
      setDarkMode(user.tema_preferido === 'escuro');
    }).catch(() => {});
  }, []);

  const { data: alunosDesativados = [], isLoading } = useQuery({
    queryKey: ['alunos-desativados'],
    queryFn: () => base44.entities.Aluno.filter({ ativo: false }, '-updated_date'),
  });

  const reativarMutation = useMutation({
    mutationFn: (id) => base44.entities.Aluno.update(id, { ativo: true }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alunos-desativados'] });
      queryClient.invalidateQueries({ queryKey: ['alunos'] });
      setAlunoParaReativar(null);
    },
  });

  const removerMutation = useMutation({
    mutationFn: (id) => base44.entities.Aluno.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['alunos-desativados'] });
      setAlunoParaRemover(null);
    },
  });

  return (
    <div className="max-w-5xl mx-auto space-y-8">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className={`text-4xl font-bold flex items-center gap-3 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
          <UserCheck className="w-10 h-10" />
          Alunos Desativados
        </h1>
        <p className={darkMode ? 'text-gray-400 mt-2' : 'text-[#607D8B] mt-2'}>
          Reative ou remova permanentemente alunos
        </p>
      </motion.div>

      {isLoading ? (
        <div className="flex justify-center items-center h-64">
          <div className="text-6xl animate-bounce">🌊</div>
        </div>
      ) : alunosDesativados.length === 0 ? (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="text-center py-16"
        >
          <div className="text-8xl mb-4">✅</div>
          <h3 className={`text-2xl font-semibold mb-2 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
            Nenhum aluno desativado
          </h3>
          <p className={darkMode ? 'text-gray-400' : 'text-[#607D8B]'}>
            Todos os alunos estão ativos!
          </p>
        </motion.div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {alunosDesativados.map((aluno, index) => (
            <motion.div
              key={aluno.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
            >
              <Card className={`backdrop-blur-sm border-2 opacity-75 hover:opacity-100 transition-opacity ${
                darkMode 
                  ? 'bg-[#1a2332]/80 border-gray-700' 
                  : 'bg-white/80 border-gray-300'
              }`}>
                <CardContent className="p-6">
                  <div className="flex items-center gap-4 mb-4">
                    <NivelIndicator nivel={aluno.nivel} size="md" showName={false} />
                    <div className="flex-1 min-w-0">
                      <h3 className={`font-semibold text-lg truncate ${darkMode ? 'text-white' : 'text-[#263238]'}`}>
                        {aluno.nome}
                      </h3>
                      <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>
                        {aluno.idade} anos
                      </p>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Button
                      onClick={() => setAlunoParaReativar(aluno)}
                      className="w-full bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7] hover:from-[#00ACC1] hover:to-[#039BE5] text-white"
                    >
                      <RefreshCw className="w-4 h-4 mr-2" />
                      Reativar Aluno
                    </Button>
                    <Button
                      onClick={() => setAlunoParaRemover(aluno)}
                      variant="destructive"
                      className="w-full bg-[#FF8A65] hover:bg-[#F4511E]"
                    >
                      <Trash2 className="w-4 h-4 mr-2" />
                      Remover Permanentemente
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </div>
      )}

      {/* Dialog de confirmação para reativar */}
      <AlertDialog open={!!alunoParaReativar} onOpenChange={(open) => !open && setAlunoParaReativar(null)}>
        <AlertDialogContent className={darkMode ? 'bg-[#1a2332] border-gray-700' : ''}>
          <AlertDialogHeader>
            <AlertDialogTitle className={darkMode ? 'text-white' : ''}>
              Reativar aluno?
            </AlertDialogTitle>
            <AlertDialogDescription className={darkMode ? 'text-gray-400' : ''}>
              Tem certeza que deseja reativar {alunoParaReativar?.nome}? 
              O aluno voltará a aparecer na lista principal de alunos ativos.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className={darkMode ? 'border-gray-600 text-gray-200' : ''}>
              Cancelar
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={() => reativarMutation.mutate(alunoParaReativar.id)}
              className="bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7]"
            >
              Reativar
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Dialog de confirmação para remover */}
      <AlertDialog open={!!alunoParaRemover} onOpenChange={(open) => !open && setAlunoParaRemover(null)}>
        <AlertDialogContent className={darkMode ? 'bg-[#1a2332] border-gray-700' : ''}>
          <AlertDialogHeader>
            <AlertDialogTitle className={darkMode ? 'text-white' : ''}>
              Remover permanentemente?
            </AlertDialogTitle>
            <AlertDialogDescription className={darkMode ? 'text-gray-400' : ''}>
              Atenção! Esta ação não pode ser desfeita. Tem certeza que deseja remover permanentemente {alunoParaRemover?.nome}? 
              Todos os dados e avaliações deste aluno serão perdidos.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className={darkMode ? 'border-gray-600 text-gray-200' : ''}>
              Cancelar
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={() => removerMutation.mutate(alunoParaRemover.id)}
              className="bg-[#FF8A65] hover:bg-[#F4511E]"
            >
              Remover Permanentemente
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}