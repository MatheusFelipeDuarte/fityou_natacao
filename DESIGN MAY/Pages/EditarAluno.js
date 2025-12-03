import React, { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { ArrowLeft, Save } from "lucide-react";
import { motion } from "framer-motion";
import NivelIndicator from "../components/alunos/NivelIndicator";

export default function EditarAluno() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const urlParams = new URLSearchParams(window.location.search);
  const alunoId = urlParams.get('id');
  const [formData, setFormData] = useState(null);

  const { data: aluno, isLoading } = useQuery({
    queryKey: ['aluno', alunoId],
    queryFn: async () => {
      const lista = await base44.entities.Aluno.filter({ id: alunoId });
      return lista[0];
    },
    enabled: !!alunoId,
  });

  useEffect(() => {
    if (aluno) {
      setFormData(aluno);
    }
  }, [aluno]);

  const atualizarMutation = useMutation({
    mutationFn: (data) => base44.entities.Aluno.update(alunoId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['aluno', alunoId] });
      queryClient.invalidateQueries({ queryKey: ['alunos'] });
      navigate(createPageUrl("DetalhesAluno") + `?id=${alunoId}`);
    },
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    atualizarMutation.mutate({
      ...formData,
      idade: parseInt(formData.idade)
    });
  };

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const formatCPF = (value) => {
    const numbers = value.replace(/\D/g, '');
    if (numbers.length <= 11) {
      return numbers
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d)/, '$1.$2')
        .replace(/(\d{3})(\d{1,2})$/, '$1-$2');
    }
    return value;
  };

  const handleCPFChange = (field, value) => {
    const formatted = formatCPF(value);
    setFormData(prev => ({ ...prev, [field]: formatted }));
  };

  if (isLoading || !formData) {
    return <div className="flex justify-center items-center h-96">
      <div className="text-6xl animate-bounce">🌊</div>
    </div>;
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex items-center justify-between"
      >
        <Button
          variant="ghost"
          onClick={() => navigate(createPageUrl("DetalhesAluno") + `?id=${alunoId}`)}
          className="gap-2 text-[#01579B] hover:bg-[#4FC3F7]/20"
        >
          <ArrowLeft className="w-5 h-5" />
          Voltar
        </Button>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
      >
        <Card className="bg-white/95 backdrop-blur-sm border-2 border-[#4FC3F7]/30 shadow-2xl">
          <CardHeader className="bg-gradient-to-r from-[#01579B] to-[#0277BD] text-white">
            <CardTitle className="text-2xl">Editar Aluno</CardTitle>
          </CardHeader>
          <CardContent className="p-8">
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Dados do Aluno */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-[#01579B] border-b pb-2">Dados do Aluno</h3>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="md:col-span-2 space-y-2">
                    <Label htmlFor="nome" className="text-[#01579B] font-medium">Nome Completo *</Label>
                    <Input
                      id="nome"
                      value={formData.nome}
                      onChange={(e) => handleChange('nome', e.target.value)}
                      required
                      className="h-12 border-2 border-gray-200 focus:border-[#26C6DA]"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="cpf_aluno" className="text-[#01579B] font-medium">CPF do Aluno</Label>
                    <Input
                      id="cpf_aluno"
                      value={formData.cpf_aluno || ''}
                      onChange={(e) => handleCPFChange('cpf_aluno', e.target.value)}
                      placeholder="000.000.000-00"
                      maxLength={14}
                      className="h-12 border-2 border-gray-200 focus:border-[#26C6DA]"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="idade" className="text-[#01579B] font-medium">Idade *</Label>
                    <Input
                      id="idade"
                      type="number"
                      min="1"
                      max="18"
                      value={formData.idade}
                      onChange={(e) => handleChange('idade', e.target.value)}
                      required
                      className="h-12 border-2 border-gray-200 focus:border-[#26C6DA]"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="nivel" className="text-[#01579B] font-medium">Nível (Cor da Touca) *</Label>
                  <Select value={formData.nivel} onValueChange={(value) => handleChange('nivel', value)}>
                    <SelectTrigger className="h-12 border-2 border-gray-200">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="branca">🐠 Branca - Peixinho Dourado</SelectItem>
                      <SelectItem value="amarela">🐚 Amarela - Cavalo-Marinho</SelectItem>
                      <SelectItem value="verde">🐬 Verde - Golfinho</SelectItem>
                      <SelectItem value="azul">🐢 Azul - Tartaruga-Marinha</SelectItem>
                      <SelectItem value="vermelha">🦈 Vermelha - Tubarão</SelectItem>
                      <SelectItem value="preta">🐋 Preta - Orca</SelectItem>
                    </SelectContent>
                  </Select>
                  <div className="mt-4 flex justify-center">
                    <NivelIndicator nivel={formData.nivel} size="lg" showName={true} />
                  </div>
                </div>
              </div>

              {/* Dados do Responsável */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold text-[#01579B] border-b pb-2">Dados do Responsável</h3>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="md:col-span-2 space-y-2">
                    <Label htmlFor="responsavel_nome" className="text-[#01579B] font-medium">Nome do Responsável</Label>
                    <Input
                      id="responsavel_nome"
                      value={formData.responsavel_nome || ''}
                      onChange={(e) => handleChange('responsavel_nome', e.target.value)}
                      className="h-12 border-2 border-gray-200 focus:border-[#26C6DA]"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="responsavel_cpf" className="text-[#01579B] font-medium">CPF do Responsável</Label>
                    <Input
                      id="responsavel_cpf"
                      value={formData.responsavel_cpf || ''}
                      onChange={(e) => handleCPFChange('responsavel_cpf', e.target.value)}
                      placeholder="000.000.000-00"
                      maxLength={14}
                      className="h-12 border-2 border-gray-200 focus:border-[#26C6DA]"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="responsavel_telefone" className="text-[#01579B] font-medium">Telefone</Label>
                    <Input
                      id="responsavel_telefone"
                      value={formData.responsavel_telefone || ''}
                      onChange={(e) => handleChange('responsavel_telefone', e.target.value)}
                      className="h-12 border-2 border-gray-200 focus:border-[#26C6DA]"
                    />
                  </div>
                </div>
              </div>

              {/* Observações */}
              <div className="space-y-2">
                <Label htmlFor="observacoes" className="text-[#01579B] font-medium">Observações</Label>
                <Textarea
                  id="observacoes"
                  value={formData.observacoes || ''}
                  onChange={(e) => handleChange('observacoes', e.target.value)}
                  className="min-h-24 border-2 border-gray-200 focus:border-[#26C6DA]"
                />
              </div>

              <div className="flex gap-4 pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate(createPageUrl("DetalhesAluno") + `?id=${alunoId}`)}
                  className="flex-1 h-12 border-2 border-gray-200"
                >
                  Cancelar
                </Button>
                <Button
                  type="submit"
                  disabled={atualizarMutation.isPending}
                  className="flex-1 h-12 bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7] hover:from-[#00ACC1] hover:to-[#039BE5] text-white"
                >
                  {atualizarMutation.isPending ? 'Salvando...' : (
                    <>
                      <Save className="w-5 h-5 mr-2" />
                      Salvar Alterações
                    </>
                  )}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );
}