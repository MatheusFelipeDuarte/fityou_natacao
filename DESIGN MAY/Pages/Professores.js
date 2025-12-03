import React, { useState, useEffect } from "react";
import { base44 } from "@/api/base44Client";
import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { UserCog, Mail, Shield, User, Plus } from "lucide-react";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";

export default function Professores() {
  const [darkMode, setDarkMode] = useState(false);

  useEffect(() => {
    base44.auth.me().then(user => {
      setDarkMode(user.tema_preferido === 'escuro');
    }).catch(() => {});
  }, []);

  const { data: usuarios = [], isLoading } = useQuery({
    queryKey: ['usuarios'],
    queryFn: () => base44.entities.User.list('full_name'),
  });

  return (
    <div className="max-w-5xl mx-auto space-y-8">
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
      >
        <h1 className={`text-4xl font-bold flex items-center gap-3 ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
          <UserCog className="w-10 h-10" />
          Professores e Administradores
        </h1>
        <p className={darkMode ? 'text-gray-400 mt-2' : 'text-[#607D8B] mt-2'}>
          Equipe do AquaNível
        </p>
      </motion.div>

      {isLoading ? (
        <div className="flex justify-center items-center h-64">
          <div className="text-6xl animate-bounce">🌊</div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {usuarios.map((usuario, index) => (
            <motion.div
              key={usuario.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
            >
              <Card className={`backdrop-blur-sm border-2 hover:shadow-xl transition-all ${
                darkMode 
                  ? 'bg-[#1a2332]/90 border-gray-700' 
                  : 'bg-white/95 border-[#4FC3F7]/30'
              }`}>
                <CardHeader className="pb-3">
                  <div className="flex items-center gap-4">
                    <Avatar className="h-16 w-16 border-4 border-[#26C6DA]">
                      <AvatarImage src={usuario.foto_perfil} />
                      <AvatarFallback className="bg-gradient-to-br from-[#4FC3F7] to-[#26C6DA] text-white text-xl font-bold">
                        {usuario.full_name?.charAt(0) || 'P'}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex-1">
                      <CardTitle className={`text-xl ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>
                        {usuario.full_name || 'Sem Nome'}
                      </CardTitle>
                      <Badge 
                        className={`mt-2 ${
                          usuario.role === 'admin'
                            ? 'bg-[#FFD54F] text-[#01579B] border-[#FBC02D]'
                            : 'bg-[#4FC3F7] text-white border-[#039BE5]'
                        }`}
                      >
                        {usuario.role === 'admin' ? (
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
                <CardContent className="space-y-3">
                  <div className={`flex items-center gap-2 ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>
                    <Mail className="w-4 h-4" />
                    <span className="text-sm">{usuario.email}</span>
                  </div>
                  {usuario.telefone && (
                    <div className={`flex items-center gap-2 ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>
                      <span className="text-sm">📱 {usuario.telefone}</span>
                    </div>
                  )}
                </CardContent>
              </Card>
            </motion.div>
          ))}
        </div>
      )}

      {/* FAB - Floating Action Button */}
      <motion.div
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ delay: 0.5, type: "spring" }}
        className="fixed bottom-8 right-8 z-50"
      >
        <Button
          size="lg"
          onClick={() => alert('Para adicionar professores, use o painel de administração do Base44 (Dashboard > Usuários > Convidar Usuário)')}
          className="w-16 h-16 rounded-full shadow-2xl bg-gradient-to-r from-[#26C6DA] to-[#4FC3F7] hover:from-[#00ACC1] hover:to-[#039BE5] text-white hover:scale-110 transition-transform"
        >
          <Plus className="w-8 h-8" />
        </Button>
      </motion.div>
    </div>
  );
}