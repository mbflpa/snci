import React, { useEffect, useRef } from 'react';
import { GridStack } from 'gridstack';
import 'gridstack/dist/gridstack.min.css';
import { createRoot } from 'react-dom/client';
import GridItem from './GridItem';
import type { DashboardItem } from '../types';

const Dashboard: React.FC = () => {
  const gridRef = useRef<HTMLDivElement>(null);
  const gridInstanceRef = useRef<GridStack | null>(null);

  useEffect(() => {
    // Ensure the grid element exists
    if (!gridRef.current) return;

    // Mock data to simulate localStorage content
    const mockItems = [
      { path: "includes/pc_dashboard_processo/pc_dashboard_cards_metricas_processo.cfm" },
      { path: "includes/pc_dashboard_processo/pc_dashboard_classificacao_processo.cfm" },
      { path: "includes/pc_dashboard_processo/pc_dashboard_tipos_processo.cfm" },
      { path: "includes/pc_dashboard_processo/pc_dashboard_distribuicao_status.cfm" }
    ];
    localStorage.setItem('snci_dashboard_favoritos', JSON.stringify(mockItems));

    // Wait for next tick to ensure DOM is ready
    setTimeout(() => {
      try {
        // Initialize GridStack
        gridInstanceRef.current = GridStack.init({
          column: 12,
          row: 20,
          cellHeight: 100,
          animate: true,
          draggable: true,
          resizable: true,
          float: true,
        }, gridRef.current);

        // Ensure grid was initialized successfully
        if (!gridInstanceRef.current) {
          console.error('Failed to initialize GridStack');
          return;
        }

        // Load items from localStorage
        const savedItems = localStorage.getItem('snci_dashboard_favoritos');
        if (savedItems) {
          const items: DashboardItem[] = JSON.parse(savedItems);
          
          items.forEach((item, index) => {
            // Create widget options
            const widgetOptions = {
              x: index % 2 * 6,
              y: Math.floor(index / 2) * 4,
              w: 6,
              h: 4,
              id: `grid-item-${index}`,
              content: item.path
            };

            // Add widget and make it a grid item
            const widget = gridInstanceRef.current?.addWidget(widgetOptions);
            
            if (widget) {
              // Find the content element
              const contentElement = widget.querySelector('.grid-stack-item-content');
              if (contentElement) {
                // Render React component into grid item
                const root = document.createElement('div');
                contentElement.appendChild(root);
                createRoot(root).render(<GridItem content={item.path} />);
              }
            }
          });
        }

        // Save layout on change
        gridInstanceRef.current.on('change', () => {
          const items = gridInstanceRef.current?.getGridItems().map(el => ({
            path: el.gridstackNode?.content,
            x: el.gridstackNode?.x,
            y: el.gridstackNode?.y,
            w: el.gridstackNode?.w,
            h: el.gridstackNode?.h,
          }));
          if (items) {
            localStorage.setItem('snci_dashboard_favoritos', JSON.stringify(items));
          }
        });
      } catch (error) {
        console.error('Error initializing GridStack:', error);
      }
    }, 0);

    return () => {
      // Cleanup
      if (gridInstanceRef.current) {
        gridInstanceRef.current.destroy();
        gridInstanceRef.current = null;
      }
    };
  }, []);

  return (
    <div className="min-h-screen bg-gray-100 p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Dashboard</h1>
        <p className="text-gray-600">Arraste e redimensione os componentes conforme necessário</p>
      </div>
      <div ref={gridRef} className="grid-stack bg-transparent"></div>
    </div>
  );
};

export default Dashboard;