import React, { useState } from "react";
import { base44 } from "@/api/base44Client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Slider } from "@/components/ui/slider";
import { useNavigate } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { ArrowLeft, Save, Star } from "lucide-react";
import { motion } from "framer-motion";
import { Checkbox } from "@/components/ui/checkbox";

export default function NovaAvaliacao() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [user, setUser] = useState(null);
  const [formData, setFormData] = useState({
    aluno_id: "",
    data_avaliacao: new Date().toISOString().split('T')[0],
    habilidades: {
      flutuacao: 5,
      respiracao: 5,
      pernada: 5,
      bracada: 5,
      coordenacao: 5
    },
    feedback: "",
    avancar_nivel: false
  });

  React.useEffect(() => {
    base44.auth.me().then(setUser).catch(() => {});
  }, []);

  const { data: alunos = [] } = useQuery({
    queryKey: ['alunos-ativos'],
    queryFn: () => base44.entities.Aluno.filter({ ativo: true }, 'nome'),
  });

  const [alunoSelecionado, setAlunoSelecionado] = useState(null);

  React.useEffect(() => {
    if (formData.aluno_id && alunos.length > 0) {
      const aluno = alunos.find(a => a.id === formData.aluno_id);
      setAlunoSelecionado(aluno);
    }
  }, [formData.aluno_id, alunos]);

  const criarMutation = useMutation({
    mutationFn: (data) => base44.entities.Avaliacao.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['avaliacoes'] });
      navigate(createPageUrl("Avaliacoes"));
    },
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    const notaGeral = Object.values(formData.habilidades).reduce((a, b) => a + b, 0) / 5;
    
    criarMutation.mutate({
      ...formData,
      aluno_nome: alunoSelecionado.nome,
      nivel_atual: alunoSelecionado.nivel,
      nota_geral: notaGeral,
      professor_nome: user?.full_name || 'Professor'
    });
  };

  const handleHabilidadeChange = (habilidade, valor) => {
    setFormData(prev => ({
      ...prev,
      habilidades: {
        ...prev.habilidades,
        [habilidade]: valor[0]
      }
    }));
  };

  const habilidadesList = [
    { key: "flutuacao", label: "Flutuação", icon: "🏊", cor: "#4FC3F7" },
    { key: "respiracao", label: "Respiração", icon: "💨", cor: "#26C6DA" },
    { key: "pernada", label: "Pernada", icon: "🦵", cor: "#FFD54F" },
    { key: "bracada", label: "Braçada", icon: "💪", cor: "#FF8A65" },
    { key: "coordenacao", label: "Coordenação", icon: "⚡", cor: "#81C784" }
  ];

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <motion.div
        
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        
        className="flex items-center justify-between"
      >
        <Button
          variant="ghost"
          onClick={() => navigate(createPageUrl("Avaliacoes"))}
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
          <CardHeader className="bg-gradient-to-r from-[#4FC3F7] to-[#26C6DA] text-white">
            <CardTitle className="flex items-center gap-3 text-2xl">
              <Star className="w-7 h-7" />
              Nova Avaliação
            </CardTitle>
            <p className="text-sm opacity-90 mt-2">Registre o progresso do aluno</p>
          </CardHeader>
          <CardContent className="p-8">
            <form onSubmit={handleSubmit} className="space-y-8">
              {/* Seleção de Aluno */}
              <div className="space-y-2">
                <Label className="text-[#01579B] font-medium text-lg">Selecionar Aluno *</Label>
                <Select
                  value={formData.aluno_id}
                  onValueChange={(value) => setFormData(prev => ({ ...prev, aluno_id: value }))}
                  required
                >
                  <SelectTrigger className="h-14 border-2 border-gray-200 text-lg">
                    <SelectValue placeholder="Escolha um aluno..." />
                  </SelectTrigger>
                  <SelectContent>
                    {alunos.map((aluno) => (
                      <SelectItem key={aluno.id} value={aluno.id} className="text-base">
                        {aluno.nome} - {aluno.idade} anos ({aluno.nivel})
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Habilidades */}
              <div className="space-y-6">
                <h3 className="text-[#01579B] font-semibold text-xl border-b-2 border-[#26C6DA] pb-2">
                  Avaliar Habilidades
                </h3>
                {habilidadesList.map((hab) => (
                  <div key={hab.key} className="space-y-3">
                    <div className="flex justify-between items-center">
                      <Label className="text-base font-medium flex items-center gap-2">
                        <span className="text-2xl">{hab.icon}</span>
                        {hab.label}
                      </Label>
                      <span
                        className="text-xl font-bold px-4 py-1 rounded-full text-white"
                        style={{ backgroundColor: hab.cor }}
                      >
                        {formData.habilidades[hab.key]}/10
                      </span>
                    </div>
                    <Slider
                      value={[formData.habilidades[hab.key]]}
                      onValueChange={(value) => handleHabilidadeChange(hab.key, value)}
                      min={0}
                      max={10}
                      step={1}
                      className="cursor-pointer"
                    />
                    <div className="flex justify-between text-xs text-[#607D8B] px-1">
                      <span>0 - Precisa Melhorar</span>
                      <span>10 - Excelente</span>
                    </div>
                  </div>
                ))}
              </div>

              {/* Média */}
              <Card className="bg-gradient-to-br from-[#FFD54F] to-[#FFA726] text-white border-none">
                <CardContent className="p-6 text-center">
                  <p className="text-sm opacity-90 mb-1">Média Geral</p>
                  <p className="text-5xl font-bold">
                    {(Object.values(formData.habilidades).reduce((a, b) => a + b, 0) / 5).toFixed(1)}
                  </p>
                  <p className="text-sm opacity-75 mt-1">de 10</p>
                </CardContent>
              </Card>

              {/* Feedback */}
              <div className="space-y-2">
                <Label htmlFor="feedback" className="text-[#01579B] font-medium text-lg">
                  Feedback para o Aluno
                </Label>
                <Textarea
                  id="feedback"
                  value={formData.feedback}
                  onChange={(e) => setFormData(prev => ({ ...prev, feedback: e.target.value }))}
                  placeholder="Ex: Parabéns! Você melhorou muito na coordenação. Continue praticando a respiração..."
                  className="min-h-32 border-2 border-gray-200 focus:border-[#26C6DA] text-base"
                />
              </div>

              {/* Checkbox Avançar */}
              <div className="flex items-center space-x-3 p-4 bg-[#E1F5FE] rounded-lg border-2 border-[#4FC3F7]">
                <Checkbox
                  id="avancar"
                  checked={formData.avancar_nivel}
                  onCheckedChange={(checked) => setFormData(prev => ({ ...prev, avancar_nivel: checked }))}
                />
                <label
                  htmlFor="avancar"
                  className="text-base font-medium text-[#01579B] cursor-pointer"
                >
                  🏆 O aluno está pronto para avançar de nível!
                </label>
              </div>

              {/* Botões */}
              <div className="flex gap-4 pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate(createPageUrl("Avaliacoes"))}
                  className="flex-1 h-12 border-2 border-gray-200"
                >
                  Cancelar
                </Button>
                <Button
                  type="submit"
                  disabled={criarMutation.isPending || !formData.aluno_id}
                  className="flex-1 h-12 bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7] hover:from-[#00ACC1] hover:to-[#039BE5] text-white shadow-lg"
                >
                  {criarMutation.isPending ? 'Salvando...' : (
                    <>
                      <Save className="w-5 h-5 mr-2" />
                      Salvar Avaliação
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