import React, { useState, useEffect } from "react";
import { Link, useLocation } from "react-router-dom";
import { createPageUrl } from "@/utils";
import { base44 } from "@/api/base44Client";
import {
  Menu,
  Users,
  ClipboardList,
  UserCog,
  UserCircle,
  LogOut,
  Waves,
  UserX,
  Moon,
  Sun
} from "lucide-react";
import {
  Sheet,
  SheetContent,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

export default function Layout({ children, currentPageName }) {
  const location = useLocation();
  const [isOpen, setIsOpen] = useState(false);
  const [user, setUser] = useState(null);
  const [darkMode, setDarkMode] = useState(false);

  useEffect(() => {
    const loadUser = async () => {
      try {
        const userData = await base44.auth.me();
        setUser(userData);
        setDarkMode(userData.tema_preferido === 'escuro');
      } catch (error) {
        console.log("Usuário não autenticado");
      }
    };
    loadUser();
  }, []);

  const toggleTheme = async () => {
    const novoTema = darkMode ? 'claro' : 'escuro';
    setDarkMode(!darkMode);
    if (user) {
      await base44.auth.updateMe({ tema_preferido: novoTema });
    }
  };

  const navigationItems = [
    {
      title: "Alunos",
      url: createPageUrl("Dashboard"),
      icon: Users,
    },
    {
      title: "Avaliações",
      url: createPageUrl("Avaliacoes"),
      icon: ClipboardList,
    },
    {
      title: "Alunos Desativados",
      url: createPageUrl("AlunosDesativados"),
      icon: UserX,
    },
    {
      title: "Professores",
      url: createPageUrl("Professores"),
      icon: UserCog,
    },
    {
      title: "Perfil",
      url: createPageUrl("Perfil"),
      icon: UserCircle,
    },
  ];

  const handleLogout = () => {
    base44.auth.logout();
  };

  return (
    <div className={`min-h-screen relative overflow-hidden transition-colors duration-300 ${
      darkMode 
        ? 'bg-gradient-to-br from-[#0a1929] via-[#1a2332] to-[#0f1b2d]' 
        : 'bg-gradient-to-br from-[#E1F5FE] via-[#B3E5FC] to-[#81D4FA]'
    }`}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');
        
        * {
          font-family: 'Poppins', sans-serif;
        }

        .bubble {
          position: absolute;
          border-radius: 50%;
          background: ${darkMode ? 'rgba(79, 195, 247, 0.05)' : 'rgba(255, 255, 255, 0.1)'};
          animation: float-up 15s infinite ease-in-out;
        }

        .bubble:nth-child(1) { width: 80px; height: 80px; left: 10%; animation-delay: 0s; }
        .bubble:nth-child(2) { width: 60px; height: 60px; left: 20%; animation-delay: 2s; }
        .bubble:nth-child(3) { width: 100px; height: 100px; left: 35%; animation-delay: 4s; }
        .bubble:nth-child(4) { width: 70px; height: 70px; left: 50%; animation-delay: 1s; }
        .bubble:nth-child(5) { width: 90px; height: 90px; left: 70%; animation-delay: 3s; }
        .bubble:nth-child(6) { width: 75px; height: 75px; left: 85%; animation-delay: 5s; }

        @keyframes float-up {
          0% {
            bottom: -100px;
            opacity: 0;
            transform: translateX(0) rotate(0deg);
          }
          10% {
            opacity: 0.3;
          }
          90% {
            opacity: 0.3;
          }
          100% {
            bottom: 100%;
            opacity: 0;
            transform: translateX(100px) rotate(360deg);
          }
        }

        .wave {
          position: absolute;
          bottom: 0;
          left: 0;
          width: 100%;
          height: 100px;
          background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 120'%3E%3Cpath d='M0,0 C150,100 350,0 600,50 C850,100 1050,0 1200,50 L1200,120 L0,120 Z' fill='${darkMode ? 'rgba(79,195,247,0.05)' : 'rgba(1,87,155,0.1)'}' /%3E%3C/svg%3E");
          background-size: cover;
          animation: wave-motion 10s ease-in-out infinite;
        }

        @keyframes wave-motion {
          0%, 100% { transform: translateX(0); }
          50% { transform: translateX(-50px); }
        }
      `}</style>

      <div className="bubble"></div>
      <div className="bubble"></div>
      <div className="bubble"></div>
      <div className="bubble"></div>
      <div className="bubble"></div>
      <div className="bubble"></div>
      <div className="wave"></div>

      <header className={`backdrop-blur-md border-b shadow-lg sticky top-0 z-50 transition-colors ${
        darkMode 
          ? 'bg-[#0a1929]/90 border-[#4FC3F7]/20' 
          : 'bg-white/90 border-[#01579B]/20'
      }`}>
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Sheet open={isOpen} onOpenChange={setIsOpen}>
              <SheetTrigger asChild>
                <Button 
                  variant="ghost" 
                  size="icon"
                  className={`hover:bg-[#4FC3F7]/20 transition-colors ${darkMode ? 'text-white' : 'text-[#01579B]'}`}
                >
                  <Menu className="h-6 w-6" />
                </Button>
              </SheetTrigger>
              <SheetContent side="left" className={`w-[280px] border-none ${
                darkMode 
                  ? 'bg-gradient-to-b from-[#0a1929] to-[#1a2332] text-white' 
                  : 'bg-gradient-to-b from-[#01579B] to-[#0277BD] text-white'
              }`}>
                <div className="flex flex-col h-full">
                  <div className="mb-8 mt-4">
                    <div className="flex items-center gap-3">
                      <div className="w-12 h-12 bg-[#26C6DA] rounded-full flex items-center justify-center shadow-lg">
                        <Waves className="w-7 h-7 text-white" />
                      </div>
                      <div>
                        <h2 className="font-bold text-xl">AquaNível</h2>
                        <p className="text-xs text-[#B3E5FC]">Evoluir na água é mergulhar em confiança</p>
                      </div>
                    </div>
                  </div>

                  {user && (
                    <div className="mb-6 p-4 bg-white/10 rounded-xl backdrop-blur-sm">
                      <div className="flex items-center gap-3">
                        <Avatar className="h-12 w-12 border-2 border-white">
                          <AvatarImage src={user.foto_perfil} />
                          <AvatarFallback className="bg-[#FFD54F] text-[#01579B] font-semibold">
                            {user.full_name?.charAt(0) || 'P'}
                          </AvatarFallback>
                        </Avatar>
                        <div className="flex-1 min-w-0">
                          <p className="font-semibold text-sm truncate">{user.full_name || 'Professor'}</p>
                          <p className="text-xs text-[#B3E5FC] truncate">{user.email}</p>
                        </div>
                      </div>
                    </div>
                  )}

                  <nav className="flex-1 space-y-2">
                    {navigationItems.map((item) => (
                      <Link
                        key={item.title}
                        to={item.url}
                        onClick={() => setIsOpen(false)}
                        className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 ${
                          location.pathname === item.url
                            ? `${darkMode ? 'bg-[#4FC3F7] text-white' : 'bg-white text-[#01579B]'} shadow-lg`
                            : 'hover:bg-white/10 text-white'
                        }`}
                      >
                        <item.icon className="h-5 w-5" />
                        <span className="font-medium">{item.title}</span>
                      </Link>
                    ))}
                  </nav>

                  {user && (
                    <Button
                      onClick={handleLogout}
                      variant="ghost"
                      className="w-full justify-start gap-3 text-white hover:bg-white/10 mt-4"
                    >
                      <LogOut className="h-5 w-5" />
                      <span className="font-medium">Sair</span>
                    </Button>
                  )}
                </div>
              </SheetContent>
            </Sheet>

            <Link to={createPageUrl("Dashboard")} className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-[#26C6DA] to-[#4FC3F7] rounded-full flex items-center justify-center shadow-lg">
                <Waves className="w-6 h-6 text-white" />
              </div>
              <div className="hidden md:block">
                <h1 className={`font-bold text-xl ${darkMode ? 'text-white' : 'text-[#01579B]'}`}>AquaNível</h1>
                <p className={`text-xs ${darkMode ? 'text-gray-400' : 'text-[#607D8B]'}`}>Natação Infantil</p>
              </div>
            </Link>
          </div>

          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              onClick={toggleTheme}
              className={`hover:bg-[#4FC3F7]/20 transition-colors ${darkMode ? 'text-white' : 'text-[#01579B]'}`}
            >
              {darkMode ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
            </Button>

            {user && (
              <Link to={createPageUrl("Perfil")}>
                <Avatar className="h-10 w-10 border-2 border-[#26C6DA] hover:border-[#FFD54F] transition-colors cursor-pointer">
                  <AvatarImage src={user.foto_perfil} />
                  <AvatarFallback className="bg-[#4FC3F7] text-white font-semibold">
                    {user.full_name?.charAt(0) || 'P'}
                  </AvatarFallback>
                </Avatar>
              </Link>
            )}
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8 relative z-10">
        {children}
      </main>
    </div>
  );
}