import React from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export default function ProgressChart({ habilidades }) {
  const items = [
    { key: "flutuacao", label: "Flutuação", icon: "🏊" },
    { key: "respiracao", label: "Respiração", icon: "💨" },
    { key: "pernada", label: "Pernada", icon: "🦵" },
    { key: "bracada", label: "Braçada", icon: "💪" },
    { key: "coordenacao", label: "Coordenação", icon: "⚡" }
  ];

  return (
    <Card className="bg-white/95 backdrop-blur-sm border-2 border-[#26C6DA]/30">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-[#01579B]">
          <span className="text-2xl">📊</span>
          Habilidades Avaliadas
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {items.map((item) => {
            const valor = habilidades?.[item.key] || 0;
            const porcentagem = (valor / 10) * 100;
            
            return (
              <div key={item.key} className="space-y-2">
                <div className="flex justify-between items-center">
                  <span className="text-sm font-medium text-[#263238] flex items-center gap-2">
                    <span className="text-lg">{item.icon}</span>
                    {item.label}
                  </span>
                  <span className="text-sm font-bold text-[#01579B]">{valor}/10</span>
                </div>
                <div className="h-3 bg-gray-200 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-[#26C6DA] to-[#FFD54F] transition-all duration-500 rounded-full"
                    style={{ width: `${porcentagem}%` }}
                  ></div>
                </div>
              </div>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
}