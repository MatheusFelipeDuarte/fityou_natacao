import React from "react";
import { Badge } from "@/components/ui/badge";

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

export default function NivelIndicator({ nivel, size = "md", showName = true }) {
  const config = NIVEL_CONFIG[nivel] || NIVEL_CONFIG.branca;
  
  const sizes = {
    sm: { container: "w-8 h-8", emoji: "text-lg", badge: "text-xs" },
    md: { container: "w-12 h-12", emoji: "text-2xl", badge: "text-sm" },
    lg: { container: "w-16 h-16", emoji: "text-4xl", badge: "text-base" },
    xl: { container: "w-24 h-24", emoji: "text-6xl", badge: "text-lg" }
  };

  const s = sizes[size];

  return (
    <div className="flex flex-col items-center gap-2">
      <div 
        className={`${s.container} rounded-full shadow-lg flex items-center justify-center relative`}
        style={{ backgroundColor: config.cor, border: `3px solid ${config.corBorda}` }}
      >
        <span className={s.emoji}>{config.animal}</span>
      </div>
      {showName && (
        <Badge 
          className={`${s.badge} font-medium`}
          style={{ 
            backgroundColor: `${config.cor}30`,
            color: config.corBorda,
            border: `1px solid ${config.corBorda}`
          }}
        >
          {config.nome}
        </Badge>
      )}
    </div>
  );
}

export { NIVEL_CONFIG };