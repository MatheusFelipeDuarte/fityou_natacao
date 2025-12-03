import React, { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { UserCircle, Save, Mail, Shield, User, Lock, Eye, EyeOff } from "lucide-react";
import { motion } from "framer-motion";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";

export default function Perfil() {
  const queryClient = useQueryClient();
  const [user, setUser] = useState(null);
  const [darkMode, setDarkMode] = useState(false);
  const [formData, setFormData] = useState({
    telefone: ""
  });
  const [senhaData, setSenhaData] = useState({
    senhaAtual: "",
    novaSenha: "",
    confirmarSenha: ""
  });
  const [showSenhaAtual, setShowSenhaAtual] = useState(false);
  const [showNovaSenha, setShowNovaSenha] = useState(false);
  const [showConfirmarSenha, setShowConfirmarSenha] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [erroSenha, setErroSenha] = useState("");

  useEffect(() => {
    const loadUser = async () => {
      const userData = await base44.auth.me();
      setUser(userData);
      setDarkMode(userData.tema_preferido === 'escuro');
      setFormData({
        telefone: userData.telefone || ""
      });
    };
    loadUser();
  }, []);

  const atualizarMutation = useMutation({
    mutationFn: (data) => base44.auth.updateMe(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user'] });
    },
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    atualizarMutation.mutate(formData);
  };

  const handleAlterarSenha = () => {
    setErroSenha("");
    
    if (senhaData.novaSenha !== senhaData.confirmarSenha) {
      setErroSenha("As senhas não coincidem");
      return;
    }

    if (senhaData.novaSenha.length < 6) {
      setErroSenha("A senha deve ter pelo menos 6 caracteres");
      return;
    }

    // Aqui você implementaria a lógica real de alteração de senha
    // Por enquanto, apenas simulamos sucesso
    alert("Funcionalidade de alteração de senha: Em produção, você integraria com o sistema de autenticação do Base44.");
    setDialogOpen(false);
    setSenhaData({ senhaAtual: "", novaSenha: "", confirmarSenha: "" });
  };

  if (!user) {
    return <div className="flex justify-center items-center h-96">
      <div className="text-6xl animate-bounce">🌊</div>
    </div>;
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className={`text-4xl font-bold flex items-center gap-3 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
          <UserCircle className="w-10 h-10" />
          Meu Perfil
        </h1>
        <p className={darkMode ? 'text-gray-400 mt-2' : 'text-[#607D8B] mt-2'}>
          Gerencie suas informações pessoais
        </p>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
      >
        <Card className={`backdrop-blur-sm border-2 shadow-2xl ${
          darkMode 
            ? 'bg-[#1a2332]/90 border-gray-700' 
            : 'bg-white/95 border-[#4FC3F7]/30'
        }`}>
          <CardHeader className="bg-gradient-to-r from-[#4FC3F7] to-[#26C6DA] text-white">
            <div className="flex items-center gap-6">
              <Avatar className="h-20 w-20 border-4 border-white shadow-lg">
                <AvatarImage src={user.foto_perfil} />
                <AvatarFallback className="bg-white text-[#01579B] text-2xl font-bold">
                  {user.full_name?.charAt(0) || 'P'}
                </AvatarFallback>
              </Avatar>
              <div>
                <CardTitle className="text-2xl">{user.full_name || 'Professor'}</CardTitle>
                <Badge 
                  className={`mt-2 ${
                    user.role === 'admin'
                      ? 'bg-[#FFD54F] text-[#01579B]'
                      : 'bg-white/20 text-white'
                  }`}
                >
                  {user.role === 'admin' ? (
                    <>
                      <Shield className="w-3 h-3 mr-1" />
                      Administrador
                    </>
                  ) : (
                    <>
                      <User className="w-3 h-3 mr-1" />
                      Professor
                    </>
                  )}
                </Badge>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-8">
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="space-y-4 pb-6 border-b border-gray-200">
                <div className={`flex items-center gap-3 ${darkMode ? 'text-gray-200' : 'text-[#263238]'}`}>
                  <Mail className={`w-5 h-5 ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`} />
                  <div>
                    <p className={`text-sm ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>Email</p>
                    <p className="font-medium">{user.email}</p>
                  </div>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="telefone" className={`font-medium ${darkMode ? 'text-gray-200' : 'text-[#01579B]'}`}>
                  Telefone
                </Label>
                <Input
                  id="telefone"
                  value={formData.telefone}
                  onChange={(e) => setFormData(prev => ({ ...prev, telefone: e.target.value }))}
                  placeholder="(11) 98765-4321"
                  className={`h-12 border-2 ${
                    darkMode 
                      ? 'bg-[#0a1929]/50 border-gray-600 text-white focus:border-[#26C6DA]' 
                      : 'border-gray-200 focus:border-[#26C6DA]'
                  }`}
                />
              </div>

              <Button
                type="submit"
                disabled={atualizarMutation.isPending}
                className="w-full h-12 bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7] hover:from-[#00ACC1] hover:to-[#039BE5] text-white shadow-lg mt-6"
              >
                {atualizarMutation.isPending ? 'Salvando...' : (
                  <>
                    <Save className="w-5 h-5 mr-2" />
                    Salvar Alterações
                  </>
                )}
              </Button>
            </form>
          </CardContent>
        </Card>
      </motion.div>

      {/* Card de Alterar Senha */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
      >
        <Card className={`backdrop-blur-sm border-2 shadow-2xl ${
          darkMode 
            ? 'bg-[#1a2332]/90 border-gray-700' 
            : 'bg-white/95 border-[#4FC3F7]/30'
        }`}>
          <CardHeader>
            <CardTitle className={`flex items-center gap-2 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
              <Lock className="w-6 h-6" />
              Segurança
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
              <DialogTrigger asChild>
                <Button 
                  variant="outline" 
                  className={`w-full h-12 ${
                    darkMode 
                      ? 'border-gray-600 text-gray-200 hover:bg-[#0a1929]' 
                      : 'border-[#26C6DA] text-[#01579B] hover:bg-[#26C6DA]/10'
                  }`}
                >
                  <Lock className="w-4 h-4 mr-2" />
                  Alterar Senha
                </Button>
              </DialogTrigger>
              <DialogContent className={darkMode ? 'bg-[#1a2332] border-gray-700' : ''}>
                <DialogHeader>
                  <DialogTitle className={darkMode ? 'text-white' : ''}>Alterar Senha</DialogTitle>
                  <DialogDescription className={darkMode ? 'text-gray-400' : ''}>
                    Digite sua senha atual e escolha uma nova senha
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label className={darkMode ? 'text-gray-200' : ''}>Senha Atual</Label>
                    <div className="relative">
                      <Input
                        type={showSenhaAtual ? "text" : "password"}
                        value={senhaData.senhaAtual}
                        onChange={(e) => setSenhaData(prev => ({ ...prev, senhaAtual: e.target.value }))}
                        className={darkMode ? 'bg-[#0a1929] border-gray-600 text-white' : ''}
                      />
                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        className="absolute right-0 top-0 h-full"
                        onClick={() => setShowSenhaAtual(!showSenhaAtual)}
                      >
                        {showSenhaAtual ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </Button>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label className={darkMode ? 'text-gray-200' : ''}>Nova Senha</Label>
                    <div className="relative">
                      <Input
                        type={showNovaSenha ? "text" : "password"}
                        value={senhaData.novaSenha}
                        onChange={(e) => setSenhaData(prev => ({ ...prev, novaSenha: e.target.value }))}
                        className={darkMode ? 'bg-[#0a1929] border-gray-600 text-white' : ''}
                      />
                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        className="absolute right-0 top-0 h-full"
                        onClick={() => setShowNovaSenha(!showNovaSenha)}
                      >
                        {showNovaSenha ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </Button>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label className={darkMode ? 'text-gray-200' : ''}>Confirmar Nova Senha</Label>
                    <div className="relative">
                      <Input
                        type={showConfirmarSenha ? "text" : "password"}
                        value={senhaData.confirmarSenha}
                        onChange={(e) => setSenhaData(prev => ({ ...prev, confirmarSenha: e.target.value }))}
                        className={darkMode ? 'bg-[#0a1929] border-gray-600 text-white' : ''}
                      />
                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        className="absolute right-0 top-0 h-full"
                        onClick={() => setShowConfirmarSenha(!showConfirmarSenha)}
                      >
                        {showConfirmarSenha ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                      </Button>
                    </div>
                  </div>
                  {erroSenha && (
                    <p className="text-red-500 text-sm">{erroSenha}</p>
                  )}
                </div>
                <DialogFooter>
                  <Button 
                    variant="outline" 
                    onClick={() => {
                      setDialogOpen(false);
                      setSenhaData({ senhaAtual: "", novaSenha: "", confirmarSenha: "" });
                      setErroSenha("");
                    }}
                    className={darkMode ? 'border-gray-600 text-gray-200' : ''}
                  >
                    Cancelar
                  </Button>
                  <Button 
                    onClick={handleAlterarSenha}
                    className="bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7]"
                  >
                    Alterar Senha
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );
}