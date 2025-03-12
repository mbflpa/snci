<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Favoritos</title>
     
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard.css">
    <link rel="stylesheet" href="plugins/gridstack/gridstack.min.css">
    
    <!-- CSS adicional para o dashboard de favoritos -->
    <style>
        .grid-stack {
            background: #f8f9fa;
            margin: 15px 0;
            border-radius: 4px;
            min-height: 500px;
        }
        .grid-stack-item-content {
            background: #fff;
            border-radius: 4px;
            box-shadow: 0 0 5px rgba(0,0,0,.1);
            overflow: hidden !important;
        }
        .widget-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
            padding: 8px 15px;
            background: #f8f9fa;
            font-weight: 600;
        }
        .widget-header .widget-title {
            display: flex;
            align-items: center;
        }
        .widget-header .widget-title i {
            margin-right: 8px;
        }
        .widget-controls a {
            margin-left: 8px;
            color: #6c757d;
        }
        .widget-controls a:hover {
            color: #dc3545;
        }
        .widget-content {
            padding: 15px;
            overflow: auto;
            height: calc(100% - 42px);
        }
        .empty-message {
            text-align: center;
            padding: 40px 20px;
            font-size: 16px;
            color: #6c757d;
        }
        /* Remover estilos do botão flutuante que não será mais usado */
        /*.add-widget-button {
            position: fixed;
            bottom: 25px;
            right: 25px;
            z-index: 1000;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: #007bff;
            color: #fff;
            text-align: center;
            line-height: 60px;
            font-size: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,.3);
            cursor: pointer;
            transition: all .2s;
        }
        .add-widget-button:hover {
            background: #0069d9;
            transform: scale(1.05);
        }*/
        
        /* Estilos para o menu de widgets - ajustados para nova posição */
        .widget-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 4px;
            box-shadow: 0 2px 15px rgba(0,0,0,.2);
            padding: 15px;
            display: none;
            width: 280px;
            z-index: 999;
            margin-top: 5px;
        }
        .widget-menu.active {
            display: block;
        }
        .widget-menu-item {
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 8px;
            cursor: pointer;
            transition: all .2s;
            display: flex;
            align-items: center;
        }
        .widget-menu-item:hover {
            background: #f8f9fa;
        }
        .widget-menu-item i {
            margin-right: 10px;
            font-size: 18px;
            width: 24px;
            text-align: center;
        }
        .widget-placeholder {
            border: 1px dashed #999;
            background: rgba(0,0,0,.03);
        }
        .dashboard-tools {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .dashboard-actions button {
            margin-left: 10px;
        }
        /* Estilos para botões na barra de ferramentas */
        .dashboard-actions {
            display: flex;
            gap: 10px;
        }
        
        /* Ajuste do botão de edição */
        #btnToggleEditMode.active {
            background-color: #28a745;
            border-color: #28a745;
            color: white;
        }
        
        #btnToggleEditMode:not(.active) {
            background-color: #6c757d;
            border-color: #6c757d;
            color: white;
        }
        
        /* Posição relativa para o container de ações para posicionar o menu */
        .dashboard-actions {
            position: relative;
        }
        
        /* Remover estilos do botão flutuante e melhorar a dropdown do menu de widgets */
        .widget-menu-dropdown {
            width: 280px;
            max-height: 400px;
            overflow-y: auto;
        }
        
        #btnToggleEditMode.active {
            background-color: #28a745;
            border-color: #28a745;
            color: white;
        }
        
        #btnToggleEditMode:not(.active) {
            background-color: #6c757d;
            border-color: #6c757d;
            color: white;
        }
        
        /* Estilo para os itens do menu de widgets */
        .widget-menu-items .widget-menu-item {
            padding: 8px 12px;
            border-radius: 4px;
            margin-bottom: 6px;
            cursor: pointer;
            transition: all .2s;
            display: flex;
            align-items: center;
        }
        
        .widget-menu-items .widget-menu-item:hover {
            background-color: #f8f9fa;
        }
        
        .widget-menu-items .widget-menu-item i {
            margin-right: 10px;
            width: 16px;
            text-align: center;
        }
        
        /* Para dispositivos móveis */
        @media (max-width: 576px) {
            .dropdown-menu.widget-menu-dropdown {
                width: 100%;
                position: fixed !important;
                top: auto !important;
                bottom: 0 !important;
                left: 0 !important;
                right: 0 !important;
                transform: none !important;
                max-height: 50vh;
                border-radius: 12px 12px 0 0;
                box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
            }
            
            .widget-menu-header {
                text-align: center;
                padding: 12px !important;
            }
        }
        
        /* Garantir que as cores do botão sejam corretas e não sobrescritas */
        #btnToggleEditMode.btn-success {
            background-color: #28a745 !important;
            border-color: #28a745 !important;
            color: white !important;
        }
        
        #btnToggleEditMode.btn-secondary {
            background-color: #6c757d !important;
            border-color: #6c757d !important;
            color: white !important;
        }
    </style>
    
    <!-- Carregamento do componente base -->
    <script src="dist/js/snciDashboardComponent.js"></script>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <div class="container-fluid">
                <section class="content-header">
                    <h1>Dashboard de Favoritos</h1>
                    <small class="text-muted">Organize seus widgets preferidos e personalize seu dashboard</small>
                </section>
                
                <section class="content">
                    <!-- Componente de filtros simplificado -->
                    <cfmodule template="includes/pc_filtros_componente.cfm" 
                        componenteID="filtros-favoritos" 
                        exibirAno="true" 
                        exibirOrgao="true" 
                        exibirStatus="false">
                    
                    <!-- Barra de ferramentas do dashboard -->
                    <div class="dashboard-tools">
                        <div class="dashboard-info">
                            <span class="badge badge-info"><i class="fas fa-info-circle"></i> Arraste os widgets para reorganizar ou redimensione-os pelos cantos</span>
                        </div>
                        <div class="dashboard-actions">
                            <button id="btnToggleEditMode" class="btn btn-sm btn-secondary" title="Ativar/Desativar edição do layout">
                                <i class="fas fa-lock"></i> Edição Bloqueada
                            </button>
                            <!-- Botão de Adicionar Widget removido -->
                        </div>
                    </div>
                
                    <!-- Container principal do GridStack -->
                    <div class="grid-stack"></div>
                    
                    <!-- Botão flutuante removido -->
                    <!-- <div class="add-widget-button" id="addWidgetButton">
                        <i class="fas fa-plus"></i>
                    </div> -->
                    
                    <!-- Menu de widgets movido para a barra de ferramentas acima -->
                </section>
            </div>
        </div>
        <cfinclude template="includes/pc_footer.cfm">
    </div>
    <cfinclude template="includes/pc_sidebar.cfm">

    <!-- Modal de carregamento -->
    <div class="modal fade" id="modalOverlay" tabindex="-1" role="dialog" aria-hidden="true" aria-labelledby="modalOverlayLabel">
      <div class="modal-dialog modal-dialog-centered modal-sm" role="document">
        <div class="modal-content">
          <div class="modal-body text-center p-4">
            <div class="spinner-border text-primary mb-3" role="status">
              <span class="sr-only">Carregando...</span>
            </div>
            <p class="mb-0">Carregando dados do dashboard...</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Script do GridStack -->
    <script src="../SNCI_PROCESSOS/plugins/gridstack/gridstack-all.js"></script>
    <script>
        $(document).ready(function() {
            // Inicializar variáveis globais
            window.dadosAtuais = null;
            window.componentesCarregados = {};
            // Inicializar o GridStack
            // Configurações do GridStack
            const gridOptions = {
                column: 12,
                cellHeight: 50,
                animate: true,
                disableDrag: false,
                disableResize: false,
                float: false,  // Alterado para false para evitar que os widgets "flutuem" para posições acima
                margin: 10,
                minRow: 1,
                acceptWidgets: true,
                // Configurações para permitir redimensionamento por todos os lados
                resizable: {
                    handles: 'e, se, s, sw, w, nw, n, ne'
                },
                // Limitar o crescimento vertical do container
                disableOneColumnMode: true,  // Impede a mudança para modo de coluna única
                staticGrid: false,  // Grid não é estático, permite movimentação
                maxRow: 0,  // 0 = sem limite específico, mas o GridStack calcula o necessário
                draggable: {
                    scroll: false,  // Não rolar a página durante o arrasto
                    appendTo: 'parent',  // Manter os elementos arrastados dentro do pai
                    containment: 'parent',  // Limitar o arrasto ao container pai
                    handle: '.card-header'  // Opcional: permitir arrastar apenas pelo cabeçalho
                },
                // Eventos adicionais para garantir comportamento correto
                addNodeCallback: function(node, widget) {
                    // Garantir posicionamento adequado ao adicionar novo widget
                    grid.batchUpdate();
                    grid.compact(); // Organiza o layout de forma otimizada
                    grid._updateContainerHeight(); // Atualiza a altura do container conforme necessário
                    grid.commit();
                }
            };
            const grid = GridStack.init(gridOptions);

            // Obter componentes favoritos do localStorage - FONTE ÚNICA DA VERDADE
            function obterComponentesFavoritos() {
                try {
                    const favoritosJson = localStorage.getItem('snci_dashboard_favoritos');
                    if (favoritosJson) {
                        const favoritos = JSON.parse(favoritosJson);
                        if (Array.isArray(favoritos) && favoritos.length > 0) {
                            return favoritos;
                        }
                    }
                } catch (e) {
                    console.error("Erro ao obter componentes favoritos:", e);
                }
                return [];
            }

            // Mapear caminho do componente para obter o tipo (para integração com o DashboardComponentFactory)
            function mapearTipoWidget(path) {
                if (path.includes('cards_metricas_processo')) {
                    return 'metricas';
                } else if (path.includes('distribuicao_status')) {
                    return 'status';
                } else if (path.includes('tipos_processo')) {
                    return 'tipos';
                } else if (path.includes('orgaos_processo')) {
                    return 'orgaos';
                } else if (path.includes('classificacao_processo')) {
                    return 'classificacao';
                } else if (path.includes('graficos_processo')) {
                    return 'graficos';
                }
                // Componente desconhecido
                return null;
            }

            // Obter configuração para widget com base no componente
            function getWidgetConfig(componente) {
                let config = {
                    title: componente.title || 'Widget',
                    component: componente.path,
                    id: componente.id,
                    w: 4,
                    h: 4,
                    minW: 2,
                    minH: 2,
                    icon: 'fas fa-puzzle-piece'
                };

                // Configurações específicas baseadas no tipo de componente
                const tipoWidget = mapearTipoWidget(componente.path);
                if (tipoWidget) {
                    switch (tipoWidget) {
                        case 'metricas':
                            config.icon = 'fas fa-tachometer-alt';
                            config.w = 3;
                            config.h = 2;
                            config.minW = 2;
                            config.minH = 2;
                            break;
                        case 'status':
                            config.icon = 'fas fa-tasks';
                            config.w = 3;
                            config.h = 4;
                            config.minW = 2;
                            config.minH = 3;
                            break;
                        case 'tipos':
                            config.icon = 'fas fa-project-diagram';
                            config.w = 5;
                            config.h = 6;
                            config.minW = 3;
                            config.minH = 4;
                            break;
                        case 'orgaos':
                            config.icon = 'fas fa-building';
                            config.w = 4;
                            config.h = 6;
                            config.minW = 3;
                            config.minH = 4;
                            break;
                        case 'classificacao':
                            config.icon = 'fas fa-list-ol';
                            config.w = 4;
                            config.h = 6;
                            config.minW = 3;
                            config.minH = 4;
                            break;
                        case 'graficos':
                            config.icon = 'fas fa-chart-line';
                            config.w = 7;
                            config.h = 5;
                            config.minW = 4;
                            config.minH = 4;
                            break;
                    }
                }
                return config;
            }

            // Atualizar os favoritos com as informações de layout
            function atualizarFavoritosComLayout() {
                try {
                    const favoritos = obterComponentesFavoritos();
                    
                    // MODIFICAÇÃO CRUCIAL: NÃO limpar informações de layout anteriores
                    // REMOVIDA a linha: favoritos.forEach(function(favorito) { delete favorito.layout; });
                    
                    // Array para controlar quais favoritos foram atualizados neste ciclo
                    const favoritosAtualizados = [];

                    // Obter informações atuais de layout
                    grid.engine.nodes.forEach(function(node) {
                        if (node.el) {
                            const widgetContent = $(node.el).find('.widget-content');
                            const componentPath = widgetContent.data('component-path');
                            if (componentPath) {
                                // Encontrar favorito correspondente
                                const favorito = favoritos.find(f => f.path === componentPath);
                                if (favorito) {
                                    // Adicionar informações de layout ou atualizar as existentes
                                    favorito.layout = {
                                        x: node.x,
                                        y: node.y,
                                        w: node.w,
                                        h: node.h
                                    };
                                    // Marcar este favorito como atualizado
                                    favoritosAtualizados.push(componentPath);
                                }
                            }
                        }
                    });
                    
                    // MELHORIA: Preservar layouts de componentes que não estão atualmente no grid
                    // mas que têm informações de layout válidas (importante para o refresh)
                    
                    // Salvar de volta no localStorage
                    localStorage.setItem('snci_dashboard_favoritos', JSON.stringify(favoritos));
                    
                    // DEBUG: Registrar quando o layout é salvo
                    console.log("Layout salvo com sucesso:", new Date().toLocaleTimeString());
                    
                    return true;
                } catch (e) {
                    console.error("Erro ao atualizar favoritos com layout:", e);
                    return false;
                }
            }

            // Salvar o layout atual (agora diretamente nos favoritos)
            function salvarLayout() {
                try {
                    // Salvar layout diretamente nos favoritos
                    if (atualizarFavoritosComLayout()) {
                        // Feedback visual
                        const btnSalvar = $('#btnSalvarLayout');
                        const textoOriginal = btnSalvar.html();
                        btnSalvar.html('<i class="fas fa-check"></i> Salvo!');
                        setTimeout(function() {
                            btnSalvar.html(textoOriginal);
                        }, 2000);
                    } else {
                        throw new Error("Falha ao atualizar favoritos com layout");
                    }
                } catch (error) {
                    console.error('Erro ao salvar layout:', error);
                    alert('Não foi possível salvar o layout: ' + error.message);
                }
            }

            // Carregar layout salvo ou criar um padrão
            function carregarLayout() {
                try {
                    // Limpar grid
                    grid.removeAll();

                    // Obter favoritos disponíveis
                    const favoritos = obterComponentesFavoritos();
                    if (favoritos.length === 0) {
                        // Não há favoritos, mostrar mensagem
                        criarLayoutVazio();
                        return;
                    }

                    // Verificar se há informações de layout nos favoritos
                    const favoritosComLayout = favoritos.filter(f => f.layout);
                        
                    if (favoritosComLayout.length > 0) {
                        // Criar layout baseado nas informações gravadas nos favoritos
                        const layout = favoritosComLayout.map(f => ({
                            x: f.layout.x,
                            y: f.layout.y,
                            w: f.layout.w,
                            h: f.layout.h,
                            componentPath: f.path,
                            title: f.title
                        }));
                        grid.load(layout);
                        
                        // Carregar conteúdo de cada widget
                        layout.forEach(function(item) {
                            const widgetElement = grid.engine.nodes.find(n => n.x === item.x && n.y === item.y);
                            if (widgetElement && widgetElement.el && item.componentPath) {
                                const favorito = favoritos.find(f => f.path === item.componentPath);
                                if (favorito) {
                                    loadWidgetContent(widgetElement.el, favorito);
                                }
                            }
                        });
                    } else {
                        // Criar layout automático se não houver informações de layout
                        criarLayoutPadrao();
                    }
                    // Atualizar menu de favoritos disponíveis
                    atualizarMenuFavoritos();
                } catch (error) {
                    console.error('Erro ao carregar layout:', error);
                    // Fallback para layout padrão
                    criarLayoutPadrao();
                    atualizarMenuFavoritos();
                }
            }

            // Criar layout padrão baseado nos favoritos
            function criarLayoutPadrao() {
                // Obter favoritos
                const favoritos = obterComponentesFavoritos();
                if (favoritos.length === 0) {
                    // Não há favoritos, mostrar mensagem
                    criarLayoutVazio();
                    return;
                }
                
                // Distribuir favoritos em um layout automático
                const layout = [];
                let gridX = 0;
                let gridY = 0;
                favoritos.forEach(function(favorito, index) {
                    // Obter configuração do widget
                    const widgetConfig = getWidgetConfig(favorito);
                    // Calcular posição no grid
                    let posX = gridX;
                    let posY = gridY;
                    // Verificar se cabe na linha atual
                    if (gridX + widgetConfig.w > 12) {
                        // Nova linha
                        posX = 0;
                        posY = gridY + 6; // altura aproximada
                        gridX = widgetConfig.w;
                        gridY = posY;
                    } else {
                        gridX += widgetConfig.w;
                    }
                    // Adicionar ao layout
                    layout.push({
                        x: posX,
                        y: posY,
                        w: widgetConfig.w,
                        h: widgetConfig.h,
                        componentPath: favorito.path,
                        title: favorito.title
                    });
                    // Atualizar informação de layout no objeto de favorito
                    favorito.layout = {
                        x: posX,
                        y: posY,
                        w: widgetConfig.w,
                        h: widgetConfig.h
                    };
                });
                // Carregar layout
                grid.load(layout);
                // Salvar favoritos atualizados com layout
                localStorage.setItem('snci_dashboard_favoritos', JSON.stringify(favoritos));
            }

            // Criar layout vazio com mensagem quando não há favoritos
            function criarLayoutVazio() {
                // Limpar grid
                grid.removeAll();
                
                // Criar widget de mensagem
                const widgetElement = grid.addWidget({
                    x: 0,
                    y: 0,
                    w: 12,
                    h: 4
                });
                const widgetContent = $('<div>').addClass('widget-structure');
                const widgetHeader = $('<div>').addClass('widget-header');
                const widgetTitle = $('<div>').addClass('widget-title')
                    .append($('<i>').addClass('fas fa-info-circle'))
                    .append('Dashboard de Favoritos');
                widgetHeader.append(widgetTitle);
                
                const widgetContentArea = $('<div>').addClass('widget-content')
                    .html(`
                        <div class="d-flex flex-column justify-content-center align-items-center h-100">
                            <div class="text-center mb-3">
                                <i class="fas fa-star text-warning" style="font-size: 3rem;"></i>
                            </div>
                            <h4>Nenhum componente favorito encontrado</h4>
                            <p class="text-muted">Para adicionar componentes a este dashboard, marque-os como favoritos em outros dashboards.</p>
                        </div>
                    `);
                widgetContent.append(widgetHeader).append(widgetContentArea);
                $(widgetElement.querySelector('.grid-stack-item-content')).append(widgetContent);
            }

            // Atualizar menu de widgets para mostrar apenas os favoritos disponíveis
            function atualizarMenuFavoritos() {
                // Obter favoritos do localStorage
                const favoritos = obterComponentesFavoritos();
                // Limpar menu de widgets
                const menuContainer = $('#widgetMenuItems');
                menuContainer.empty();

                // Verificar se há favoritos disponíveis
                if (favoritos.length === 0) {
                    menuContainer.html('<div class="text-muted py-2">Nenhum componente favorito disponível. Adicione favoritos em outros dashboards.</div>');
                    return;
                }

                // Capturar componentes já adicionados para não exibi-los novamente no menu
                const widgetsAdicionados = [];
                grid.engine.nodes.forEach(function(node) {
                    if (node.el) {
                        const widgetContent = $(node.el).find('.widget-content');
                        const widgetPath = widgetContent.data('component-path');
                        if (widgetPath) {
                            widgetsAdicionados.push(widgetPath);
                        }
                    }
                });

                // Adicionar apenas favoritos que ainda não estão no grid
                let itemsAdicionados = 0;
                favoritos.forEach(function(favorito) {
                    // Verificar se já foi adicionado
                    if (!widgetsAdicionados.includes(favorito.path)) {
                        const tipoWidget = mapearTipoWidget(favorito.path) || 'custom';
                        let icone = 'fas fa-puzzle-piece';
                        // Determinar ícone com base no tipo (se reconhecido)
                        
                        // Criar item de menu
                        const menuItem = `
                        <div class="widget-menu-item" data-widget-path="${favorito.path}" data-widget-title="${favorito.title || ''}" data-widget-id="${favorito.id || ''}">
                            <i class="${icone}"></i> ${favorito.title || favorito.path.split('/').pop() || 'Widget'}
                        </div>`;
                        menuContainer.append(menuItem);
                        itemsAdicionados++;
                    }
                });

                // Se todos já foram adicionados, mostrar mensagem
                if (itemsAdicionados === 0) {
                    menuContainer.html('<div class="text-muted py-2">Todos os componentes favoritos já foram adicionados ao dashboard.</div>');
                    return;
                }

                // Configurar handlers para os itens do menu
                $('.widget-menu-item').off('click').on('click', function() {
                    const widgetPath = $(this).data('widget-path');
                    const widgetTitle = $(this).data('widget-title');
                    const widgetId = $(this).data('widget-id');
                    // Encontrar o item favorito correspondente
                    const favorito = favoritos.find(f => f.path === widgetPath);
                    if (favorito) {
                        // Obter configuração do widget
                        const widgetConfig = getWidgetConfig(favorito);
                        // Adicionar widget ao grid
                        const widget = grid.addWidget({
                            w: widgetConfig.w,
                            h: widgetConfig.h,
                            minW: widgetConfig.minW,
                            minH: widgetConfig.minH,
                            autoPosition: true
                        });
                        // Obter posição atual após adicionado ao grid
                        const node = grid.engine.nodes.find(n => n.el === widget);
                        if (node) {
                            // Atualizar layout no objeto de favorito
                            favorito.layout = {
                                x: node.x,
                                y: node.y,
                                w: node.w,
                                h: node.h
                            };
                            
                            // Salvar imediatamente nos favoritos
                            atualizarFavoritosComLayout();
                        }
                        // Carregar o conteúdo do favorito no widget
                        loadWidgetContent(widget, favorito);
                        
                        // Fechar o menu
                        $('#widgetMenu').removeClass('active');
                        
                        // Atualizar menu para refletir o widget adicionado
                        atualizarMenuFavoritos();
                    }
                });
            }

            // Carregar conteúdo do widget a partir do componente favoritado
            function loadWidgetContent(widgetElement, favorito) {
                // Obter configurações para o widget
                const widgetConfig = getWidgetConfig(favorito);
                
                // Gerar ID único para este widget
                const widgetId = 'widget-' + Math.random().toString(36).substr(2, 9);
                
                // Criar a estrutura do widget (sem o cabeçalho padrão)
                const widgetContent = $('<div>').addClass('widget-structure');
                
                // Criar área de conteúdo com dados do componente
                const widgetContentArea = $('<div>')
                    .addClass('widget-content')
                    .attr('id', widgetId)
                    .data('component-path', favorito.path)
                    .data('component-id', favorito.id);
                
                widgetContent.append(widgetContentArea);
                $(widgetElement.querySelector('.grid-stack-item-content')).append(widgetContent);
                
                // Mostrar indicador de carregamento
                widgetContentArea.html('<div class="d-flex justify-content-center align-items-center h-100"><i class="fas fa-spinner fa-spin mr-2"></i> Carregando componente...</div>');
                
                // Verificar se o componente existe antes de carregá-lo
                $.ajax({
                    url: favorito.path,
                    type: 'HEAD',
                    error: function() {
                        // Componente não encontrado - mostrar erro
                        widgetContentArea.html(`
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle"></i>
                                O componente favorito não foi encontrado: ${favorito.path}
                            </div>
                            <div class="text-center mt-3">
                                <button class="btn btn-sm btn-outline-danger widget-remove-error">Remover Widget</button>
                            </div>
                        `);
                        // Handler para remover widget com erro
                        widgetContentArea.find('.widget-remove-error').on('click', function() {
                            grid.removeWidget(widgetElement);
                            atualizarMenuFavoritos();
                            salvarLayout();
                        });
                    },
                    success: function() {
                        // Componente encontrado - carregar conteúdo
                        $.ajax({
                            url: favorito.path,
                            dataType: 'html',
                            success: function(data) {
                                try {
                                    // Processar o HTML retornado para extrair CSS e conteúdo
                                    const htmlParser = new DOMParser();
                                    const parsedHtml = htmlParser.parseFromString(data, 'text/html');
                                    
                                    // Processar estilos e links CSS
                                    let styles = '';
                                    
                                    // Extrair tags <style>
                                    const styleTags = parsedHtml.querySelectorAll('style');
                                    styleTags.forEach(function(styleTag) {
                                        const styleId = 'widget-style-' + Math.random().toString(36).substr(2, 9);
                                        styles += `<style id="${styleId}">${styleTag.textContent}</style>`;
                                        styleTag.remove();
                                    });
                                    // Extrair links CSS
                                    const linkTags = parsedHtml.querySelectorAll('link[rel="stylesheet"]');
                                    linkTags.forEach(function(linkTag) {
                                        const href = linkTag.getAttribute('href');
                                        if (href) {
                                            const cssId = 'widget-css-' + href.replace(/[^a-z0-9]/gi, '-');
                                            if (!$('#' + cssId).length) {
                                                styles += `<link id="${cssId}" rel="stylesheet" href="${href}">`;
                                            }
                                        }
                                        linkTag.remove();
                                    });
                                    // MODIFICAÇÃO: Preservar o card completo, incluindo cabeçalho
                                    let bodyContent = parsedHtml.body.innerHTML;;
                                    
                                    // Verificar se o componente tem um card principal
                                    const cardElement = parsedHtml.querySelector('.card');
                                    if (cardElement) {
                                        // Preservar o card completo com cabeçalho e conteúdo
                                        bodyContent = cardElement.outerHTML;
                                        
                                        // Adicionar botão para remover o widget no header do card
                                        setTimeout(function() {
                                            const cardHeader = $(widgetContentArea).find('.card-header');
                                            if (cardHeader.length) {
                                                // Adicionar botão de remoção se não existir
                                                if (cardHeader.find('.widget-remove').length === 0) {
                                                    cardHeader.append(
                                                        $('<div>').addClass('float-right ml-2')
                                                            .append($('<a>').attr('href', '#').addClass('widget-remove text-danger')
                                                                .append($('<i>').addClass('fas fa-times')))
                                                    );
                                                    
                                                    // Evento para remover widget
                                                    cardHeader.find('.widget-remove').on('click', function(e) {
                                                        e.preventDefault();
                                                        grid.removeWidget(widgetElement);
                                                        atualizarMenuFavoritos();
                                                        salvarLayout();
                                                    });
                                                }
                                            }
                                            
                                            
                                        }, 250);
                                    } else {
                                        // Fallback para o conteúdo completo
                                        bodyContent = parsedHtml.body.innerHTML;
                                    }
                                    
                                    // Adicionar estilos ao cabeçalho
                                    if (styles) {
                                        $('head').append(styles);
                                    }
                                    
                                    // Injetar HTML no widget
                                    widgetContentArea.html(bodyContent);
                                    
                                    // Inicializar componente
                                    setTimeout(function() {
                                        try {
                                            // Tentar inicializar usando fábrica de componentes se o tipo for reconhecido
                                            const tipoComponente = mapearTipoWidget(favorito.path);
                                            if (tipoComponente && typeof DashboardComponentFactory !== 'undefined') {
                                                DashboardComponentFactory.inicializarComponenteFavorito(
                                                    tipoComponente,
                                                    widgetId,
                                                    widgetId
                                                );
                                            }
                                            
                                            // Executar scripts inline do componente
                                            const scripts = widgetContentArea.find('script');
                                            scripts.each(function() {
                                                const scriptContent = $(this).html();
                                                if (scriptContent && scriptContent.trim() !== '') {
                                                    try {
                                                        eval(scriptContent);
                                                    } catch(e) {
                                                        console.error("Erro ao executar script do componente:", e);
                                                    }
                                                }
                                            });
                                            
                                            // Atualizar com dados se disponíveis
                                            if (window.dadosAtuais) {
                                                setTimeout(function() {
                                                    atualizarWidgets(window.dadosAtuais);
                                                }, 500);
                                            }
                                        } catch (e) {
                                            console.error("Erro ao inicializar componente:", e);
                                        }
                                    }, 200);
                                } catch (error) {
                                    console.error("Erro ao processar conteúdo:", error);
                                    widgetContentArea.html('<div class="alert alert-danger">Erro ao processar componente: ' + error.message + '</div>');
                                }
                            },
                            error: function() {
                                widgetContentArea.html('<div class="alert alert-danger">Erro ao carregar o componente</div>');
                            }
                        });
                    }
                });
            }

            // Atualizar todos os widgets quando os filtros mudarem
            function atualizarWidgets(dados) {
                window.dadosAtuais = dados;

                // Se houver funções de atualização de componentes registradas, chamá-las
                if (Array.isArray(window.atualizarDadosComponentes)) {
                    window.atualizarDadosComponentes.forEach(function(callback) {
                        if (typeof callback === 'function') {
                            try {
                                callback(dados);
                            } catch(e) {
                                console.error("Erro ao atualizar componente:", e);
                            }
                        }
                    });
                }
            }

            // Função para carregar dados do dashboard
            function carregarDados() {
                // Mostrar modal de carregamento
                $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                $('#modalOverlay').modal('show');
                
                // Timeout de segurança
                var timeoutSeguranca = setTimeout(function() {
                    fecharModalComSeguranca();
                }, 30000);
                
                // Fazer chamada AJAX para obter dados
                $.ajax({
                    url: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
                    method: 'POST',
                    data: {
                        ano: window.anoSelecionado || 'Todos',
                        mcuOrigem: window.mcuSelecionado || 'Todos',
                        statusFiltro: window.statusSelecionado || 'Todos'
                    },
                    dataType: 'json',
                    success: function(dados) {
                        // Armazenar dados globais
                        window.dadosAtuais = dados;
                        // Atualizar widgets com os novos dados
                        atualizarWidgets(dados);
                        // Limpar timeout
                        clearTimeout(timeoutSeguranca);
                        // Fechar modal
                        setTimeout(function() {
                            fecharModalComSeguranca();
                        }, 500);
                    },
                    error: function(xhr, status, error) {
                        console.error("Erro ao carregar dados:", error);
                        fecharModalComSeguranca();
                        alert("Erro ao carregar dados: " + error);
                    }
                });
            }

            // Função melhorada para garantir o fechamento do modal
            function fecharModalComSeguranca() {
                setTimeout(function() {
                    if ($('#modalOverlay').is(':visible') || $('body').hasClass('modal-open')) {
                        $('#modalOverlay').modal('hide');
                        $('#modalOverlay').css('display', 'none');
                        $('#modalOverlay').removeClass('show');
                        $('body').css('padding-right', '');
                        $('body').removeClass('modal-open');
                        $('.modal-backdrop').remove();
                    }
                }, 500);
            }

            // Escutar eventos do grid
            grid.on('added removed change', function(e, items) {
                // Não salvar durante o carregamento inicial
                if (!grid.isInitializing) {
                    atualizarFavoritosComLayout();
                }
            });

            // Botões de ação
            /*
            $('#btnSalvarLayout').on('click', function() {
                salvarLayout();
            });
            
            $('#btnRestaurarLayout').on('click', function() {
                if (confirm('Tem certeza que deseja restaurar o layout padrão? Esta ação não pode ser desfeita.')) {
                    criarLayoutPadrao();
                }
            });
            */
            
            // Escutar evento de alteração de filtros
            document.addEventListener('filtroAlterado', function(e) {
                carregarDados();
            });
            
            // Botão para adicionar widgets (substituindo o botão flutuante)
            $('#btnAddWidget').on('click', function(e) {
                e.stopPropagation();
                $('#widgetMenu').toggleClass('active');
            });
            
            // Fechar menu quando clica fora
            $(document).on('click', function(e) {
                if (!$(e.target).closest('#widgetMenu').length && !$(e.target).closest('#btnAddWidget').length) {
                    $('#widgetMenu').removeClass('active');
                }
            });
            
            // Remover qualquer layout salvo no formato antigo
            localStorage.removeItem('dashboardFavoritosLayout');
            
            // Limpar o menu de widgets hardcodados e preparar para geração dinâmica
            $('#widgetMenuItems').empty();
            
            // Carregar layout inicial
            carregarLayout();
            
            // Atualizar menu de favoritos
            atualizarMenuFavoritos();
            
            // Carregar dados iniciais
            setTimeout(carregarDados, 500);

            // Removido o setInterval desnecessário que salvava o layout automaticamente a cada 10 segundos
            
            // NOVO: Salvar o layout automaticamente antes de recarregar a página
            window.addEventListener('beforeunload', function() {
                atualizarFavoritosComLayout();
            });
            
            // NOVO: Salvar imediatamente após o carregamento da página
            setTimeout(function() {
                if (!grid.isInitializing) {
                    atualizarFavoritosComLayout();
                }
            }, 2000);
            
            // Escutar eventos do grid - MELHORADO para usar menos chamadas
            let layoutUpdateTimeout;
            grid.on('added removed change', function(e, items) {
                // Não salvar durante o carregamento inicial
                if (!grid.isInitializing) {
                    // Usar debounce para evitar múltiplas chamadas em sequência
                    clearTimeout(layoutUpdateTimeout);
                    layoutUpdateTimeout = setTimeout(function() {
                        atualizarFavoritosComLayout();
                    }, 500);
                }
            });

            // Adicionar uma função de compactação do grid após mudanças
            // que reorganiza os widgets de forma otimizada
            function otimizarLayout() {
                grid.batchUpdate();
                grid.compact();
                grid._updateContainerHeight();
                grid.commit();
            }

            // Chamar otimização de layout após carregar conteúdo e depois de um tempo
            // para garantir que os widgets foram posicionados corretamente
            setTimeout(otimizarLayout, 1500);

            // Melhorar o evento de alteração do grid
            grid.on('added removed change', function(e, items) {
                // Não salvar durante o carregamento inicial
                if (!grid.isInitializing) {
                    // Reorganizar o layout de forma otimizada após mudanças
                    setTimeout(function() {
                        otimizarLayout();
                        
                        // Usar debounce para evitar múltiplas chamadas em sequência
                        clearTimeout(layoutUpdateTimeout);
                        layoutUpdateTimeout = setTimeout(function() {
                            atualizarFavoritosComLayout();
                        }, 500);
                    }, 100);
                }
            });

            // Variável para controlar o estado de edição - inicialmente DESABILITADA
            let editModeEnabled = false;
            
            // Função para alternar o modo de edição
            function toggleEditMode() {
                editModeEnabled = !editModeEnabled;
                
                // Atualizar o grid
                grid.enableMove(editModeEnabled);
                grid.enableResize(editModeEnabled);
                
                // Atualizar visual do botão
                const $btn = $('#btnToggleEditMode');
                if (editModeEnabled) {
                    $btn.removeClass('btn-secondary').addClass('btn-success active');
                    $btn.html('<i class="fas fa-edit"></i> Modo Edição Ativo');
                    $('.grid-stack-item').css('cursor', 'move');
                } else {
                    $btn.removeClass('btn-success active').addClass('btn-secondary');
                    $btn.html('<i class="fas fa-lock"></i> Edição Bloqueada');
                    $('.grid-stack-item').css('cursor', 'default');
                }
                
                // Salvar o layout atual
                atualizarFavoritosComLayout();
            }
            
            // Associar evento de clique ao botão de toggle de edição
            $('#btnToggleEditMode').on('click', function() {
                toggleEditMode();
            });
            
            // Configurar botão de adicionar widget usando dropdown do Bootstrap
            // (não precisa de evento de clique separado pois o dropdown é gerenciado pelo Bootstrap)
            $('.dropdown-toggle').dropdown();
            
            // Fechar menu dropdown quando clica fora
            $(document).on('click', function(e) {
                if (!$(e.target).closest('.dropdown-menu').length && 
                    !$(e.target).closest('#btnAddWidget').length) {
                    $('.dropdown-menu').removeClass('show');
                }
            });

            // Após inicializar o grid, desabilitar edição imediatamente
            grid.enableMove(false);
            grid.enableResize(false);
            
            // NOVO: Definir cursor padrão para os items do grid
            $('.grid-stack-item').css('cursor', 'default');
            
            // Garantir que o botão reflita o estado inicial corretamente
            $('#btnToggleEditMode').removeClass('active btn-success').addClass('btn-secondary');
            $('#btnToggleEditMode').html('<i class="fas fa-lock"></i> Edição Bloqueada');
            $('.grid-stack-item').css('cursor', 'default');
        });
    </script>
</body>
</html>