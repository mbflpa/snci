import React from 'react';
import { LayoutDashboard, BarChart2, FileText, PieChart, Activity } from 'lucide-react';

interface GridItemProps {
  content: string;
}

const GridItem: React.FC<GridItemProps> = ({ content }) => {
  // Determine which mock component to render based on the path
  const renderMockComponent = () => {
    if (content.includes('cards_metricas_processo')) {
      return (
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <h4 className="font-semibold text-blue-700">Processos Ativos</h4>
              <p className="text-2xl font-bold text-blue-800">247</p>
            </div>
            <div className="bg-green-50 p-4 rounded-lg">
              <h4 className="font-semibold text-green-700">Concluídos</h4>
              <p className="text-2xl font-bold text-green-800">183</p>
            </div>
          </div>
          <Activity className="w-full h-16 text-gray-400" />
        </div>
      );
    }
    
    if (content.includes('classificacao_processo')) {
      return (
        <div className="space-y-4">
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span>Urgente</span>
              <span className="text-red-600 font-semibold">35%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div className="bg-red-600 h-2 rounded-full" style={{ width: '35%' }}></div>
            </div>
            <div className="flex justify-between items-center">
              <span>Normal</span>
              <span className="text-blue-600 font-semibold">65%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div className="bg-blue-600 h-2 rounded-full" style={{ width: '65%' }}></div>
            </div>
          </div>
          <BarChart2 className="w-full h-16 text-gray-400" />
        </div>
      );
    }
    
    if (content.includes('tipos_processo')) {
      return (
        <div className="space-y-4">
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span>Administrativo</span>
              <span className="font-semibold">45</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Financeiro</span>
              <span className="font-semibold">32</span>
            </div>
            <div className="flex justify-between items-center">
              <span>Recursos Humanos</span>
              <span className="font-semibold">28</span>
            </div>
          </div>
          <FileText className="w-full h-16 text-gray-400" />
        </div>
      );
    }
    
    if (content.includes('distribuicao_status')) {
      return (
        <div className="space-y-4">
          <div className="grid grid-cols-2 gap-4 text-center">
            <div className="p-2 bg-yellow-50 rounded">
              <div className="text-yellow-700">Em Andamento</div>
              <div className="font-bold text-xl text-yellow-800">64</div>
            </div>
            <div className="p-2 bg-green-50 rounded">
              <div className="text-green-700">Concluído</div>
              <div className="font-bold text-xl text-green-800">183</div>
            </div>
            <div className="p-2 bg-red-50 rounded">
              <div className="text-red-700">Atrasado</div>
              <div className="font-bold text-xl text-red-800">12</div>
            </div>
            <div className="p-2 bg-blue-50 rounded">
              <div className="text-blue-700">Aguardando</div>
              <div className="font-bold text-xl text-blue-800">38</div>
            </div>
          </div>
          <PieChart className="w-full h-16 text-gray-400" />
        </div>
      );
    }
  };

  const getIcon = () => {
    if (content.includes('cards_metricas_processo')) return <Activity className="w-5 h-5 text-blue-600" />;
    if (content.includes('classificacao_processo')) return <BarChart2 className="w-5 h-5 text-blue-600" />;
    if (content.includes('tipos_processo')) return <FileText className="w-5 h-5 text-blue-600" />;
    if (content.includes('distribuicao_status')) return <PieChart className="w-5 h-5 text-blue-600" />;
    return <LayoutDashboard className="w-5 h-5 text-blue-600" />;
  };

  const getTitle = () => {
    if (content.includes('cards_metricas_processo')) return "Métricas de Processos";
    if (content.includes('classificacao_processo')) return "Classificação de Processos";
    if (content.includes('tipos_processo')) return "Tipos de Processos";
    if (content.includes('distribuicao_status')) return "Distribuição por Status";
    return "Componente do Dashboard";
  };

  return (
    <div className="h-full w-full bg-white rounded-lg shadow-lg p-4">
      <div className="flex items-center gap-2 mb-4">
        {getIcon()}
        <h3 className="text-lg font-semibold text-gray-800">{getTitle()}</h3>
      </div>
      <div className="text-gray-600">
        {renderMockComponent()}
      </div>
    </div>
  );
};

export default GridItem;