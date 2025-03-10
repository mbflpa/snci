<cfprocessingdirective pageencoding = "utf-8">

<cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
    SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_processos 
    WHERE 1=1
    <cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
        AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
    </cfif>
    ORDER BY ano DESC
</cfquery>

<cfquery name="rsOrgaosOrigem" datasource="#application.dsn_processos#">
    SELECT pc_org_mcu, pc_org_sigla
    FROM pc_orgaos 
    WHERE pc_org_status = 'O'
    <cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
        AND pc_org_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#'
    </cfif>
    ORDER BY pc_org_sigla
</cfquery>

<cfset mostrarFiltroOrgao = application.rsUsuarioParametros.pc_usu_perfil neq 8>
<cfif NOT mostrarFiltroOrgao AND rsOrgaosOrigem.recordCount GT 0>
    <cfset orgaoOrigemSelecionado = rsOrgaosOrigem.pc_org_mcu>
</cfif>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Favoritos</title>
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard.css">
    <!-- GridStack CSS -->
    <link rel="stylesheet" href="plugins/gridstack/gridstack.min.css" />
    <style>
        /* Estilos aprimorados para os filtros na mesma linha com melhor responsividade */
        .filtros-container {
            display: flex;
            flex-wrap: nowrap;
            align-items: center;
            gap: 15px;
            background-color: #fff;
            padding: 10px 15px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 1.5rem;
            overflow-x: auto;
            position: relative;
            z-index: 9;
        }
        
        .filtro-container.filtro-compacto {
            margin-bottom: 0;
            flex: 0 0 auto;
            white-space: nowrap;
            min-width: auto;
        }
        
        .filtro-label {
            display: inline-block;
            font-weight: 600;
            margin-right: 8px;
            font-size: 0.9rem;
        }
        
        /* Melhor comportamento responsivo para os filtros */
        @media (max-width: 992px) {
            .filtros-container {
                padding: 8px 12px;
                gap: 10px;
            }
            
            .filtro-label {
                font-size: 0.8rem;
                margin-right: 6px;
            }
            
            .filtro-compacto .btn-group-sm .btn {
                padding: 0.12rem 0.35rem;
                font-size: 0.7rem;
            }
        }
        
        /* Para telas muito pequenas, permitir que os filtros quebrem em linhas */
        @media (max-width: 576px) {
            .filtros-container {
                flex-wrap: wrap;
                gap: 6px;
            }
            
            .filtro-container.filtro-compacto {
                margin-bottom: 5px !important;
            }
        }
        
        /* Melhorar visibilidade do texto nos botões durante o hover */
        .filtro-container .btn-outline-info:hover {
            color: #fff !important; /* Texto branco quando hover */
            background-color: #17a2b8 !important; /* Azul mais escuro para melhor contraste */
        }
        
        .filtro-container .btn-outline-info.active {
            color: #fff !important; /* Garantir que texto seja branco quando ativo */
        }
        
        .filtro-container .btn-outline-primary:hover {
            color: #fff !important;
            background-color: #007bff !important;
        }
        
        .filtro-container .btn-outline-secondary:hover {
            color: #fff !important;
            background-color: #6c757d !important;
        }
        
        /* Estilos para GridStack */
        .grid-stack {
            background: #f8f9fa;
            margin-bottom: 20px;
            min-height: 500px;
            position: relative;
            z-index: 0; /* Garante que o grid não fique sobre os controles de filtro */
        }
        
        .grid-stack-item-content {
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            padding: 10px;
            overflow: hidden !important;
        }
        
        .grid-stack-item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e9ecef;
            padding-bottom: 8px;
            margin-bottom: 8px;
        }
        
        .grid-stack-item-header h5 {
            margin: 0;
            font-size: 14px;
            font-weight: 600;
        }
        
        .grid-stack-item-header .control-buttons {
            display: flex;
            gap: 5px;
        }
        
        .grid-stack-item-header .control-buttons button {
            border: none;
            background: transparent;
            font-size: 12px;
            cursor: pointer;
            color: #6c757d;
            padding: 2px 5px;
            border-radius: 3px;
        }
        
        .grid-stack-item-header .control-buttons button:hover {
            background-color: #f1f3f5;
            color: #000;
        }
        
        /* Estilo específico para o conteúdo interno dos widgets */
        .widget-content {
            height: calc(100% - 35px); /* Altura total menos a altura do cabeçalho */
            overflow: auto;
        }
        
        /* Ajuste para componentes de gráficos e tabelas dentro dos widgets */
        .widget-content canvas,
        .widget-content .table-responsive {
            max-width: 100%;
        }
    </style>
</head>
<!-- Estrutura padrão do projeto -->
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <!-- Área que será exportada para PDF -->
            <div id="dashboard-content">
                <section class="content-header">
                    <h1>Dashboard de Favoritos</h1>
                </section>

                <section class="content">
                    <div class="container-fluid">
                        <!-- Filtros agrupados em um container -->
                        <div class="filtros-container">
                            <!-- Filtro por ano -->
                            <div class="filtro-container filtro-compacto">
                                <div class="filtro-label">Ano:</div>
                                <div id="opcoesAno" class="btn-group btn-group-toggle btn-group-sm" data-toggle="buttons">
                                    <!-- Botões gerados via JS -->
                                </div>
                            </div>
                            
                            <!-- Filtro por órgão - exibido conforme perfil do usuário -->
                            <cfif mostrarFiltroOrgao>
                                <div class="filtro-container filtro-compacto">
                                    <div class="filtro-label">Órgão:</div>
                                    <div id="opcoesMcu" class="btn-group btn-group-toggle btn-group-sm" data-toggle="buttons">
                                        <!-- Botões gerados via JS -->
                                    </div>
                                </div>
                            </cfif>
                        </div>

                        <!-- Botões de controle do GridStack -->
                        <div class="d-flex justify-content-end mb-3">
                            <button class="btn btn-sm btn-outline-primary mr-2" id="btn-salvar-layout">
                                <i class="fas fa-save"></i> Salvar Layout
                            </button>
                            <button class="btn btn-sm btn-outline-secondary mr-2" id="btn-restaurar-layout">
                                <i class="fas fa-undo"></i> Restaurar Layout
                            </button>
                            <button class="btn btn-sm btn-outline-danger" id="btn-resetar-layout">
                                <i class="fas fa-trash-alt"></i> Resetar Layout
                            </button>
                        </div>

                        <!-- Container do GridStack -->
                        <div class="grid-stack"></div>
                        
                    </div>
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

    <!-- GridStack JS -->
    <script src="plugins/gridstack/gridstack-all.js"></script>


    <script>
        $(document).ready(function() {
            console.log("Inicializando dashboard de favoritos");
            
            var anos = [];
            var orgaos = [];
            var currentYear = new Date().getFullYear();
            
            var anosDisponiveis = [];
            var anoInicial = '';
            var anoFinal = '';
            
            // Preencher array com os anos da query rsAnoDashboard
            <cfoutput query="rsAnoDashboard">
                anos.push(parseInt("#rsAnoDashboard.ano#", 10));
                anosDisponiveis.push(parseInt("#rsAnoDashboard.ano#", 10));
            </cfoutput>
            
            // Ordena os anos em ordem crescente para encontrar o primeiro e o último
            anosDisponiveis = anosDisponiveis.sort(function(a, b){ return a - b; });
            anoInicial = anosDisponiveis.length > 0 ? anosDisponiveis[0] : '';
            anoFinal = anosDisponiveis.length > 0 ? anosDisponiveis[anosDisponiveis.length - 1] : '';
            
            // Disponibilizar os anos inicial e final globalmente
            window.anoInicial = anoInicial;
            window.anoFinal = anoFinal;
            
            // Ordena os anos em ordem crescente
            anos = anos.sort(function(a, b){ return a - b; });
            
            console.log("Anos disponíveis:", anos);
            
            // Configuração do filtro de anos
            var radioName = "opcaoAno";
            $("#opcoesAno").empty();
            
            // Adicionar botão "Todos" antes dos anos específicos
            var btnTodos = `<label class="btn btn-outline-secondary btn-todos">
                            <input type="radio" name="${radioName}" autocomplete="off" value="Todos"/> Todos
                       </label>`;
            $("#opcoesAno").append(btnTodos);
            
            // Defina o ano selecionado como o último ano (mais recente) da consulta
            var anoSelecionado = anos.length > 0 ? anos[anos.length - 1] : (currentYear - 1);
            
            anos.forEach(function(val) {
                var btnClass = "btn-outline-primary";
                var checked = (val === anoSelecionado) ? 'checked' : '';
                var btn = `<label class="btn ${btnClass}" style="margin-left:2px;">
                                <input type="radio" name="${radioName}" ${checked} autocomplete="off" value="${val}"/> ${val}
                           </label>`;
                $("#opcoesAno").append(btn);
            });

            // Ativar o botão do ano selecionado
            $(`input[name="${radioName}"][value="${anoSelecionado}"]`).parent().addClass('active');
            
            // Preencher array com os órgãos da query rsOrgaosOrigem
            <cfoutput query="rsOrgaosOrigem">
                var sigla = "#rsOrgaosOrigem.pc_org_sigla#";
                var mcu = "#rsOrgaosOrigem.pc_org_mcu#";
                var ultimaParte = sigla.includes('/') ? sigla.split('/').pop() : sigla;
                orgaos.push({
                    mcu: mcu,
                    sigla: ultimaParte
                });
            </cfoutput>
            
            console.log("Órgãos disponíveis:", orgaos);
        
            // Configuração do filtro de órgãos - somente se o perfil permitir
            <cfif mostrarFiltroOrgao>
                var radioMcu = "opcaoMcu";
                $("#opcoesMcu").empty();
                
                // Adicionar botão "Todos" para os órgãos
                var btnTodosMcu = `<label class="btn btn-outline-secondary btn-todos">
                                <input type="radio" name="${radioMcu}" checked autocomplete="off" value="Todos"/> Todos
                           </label>`;
                $("#opcoesMcu").append(btnTodosMcu);
                
                // Adicionar botões para cada órgão
                orgaos.forEach(function(orgao) {
                    var btn = `<label class="btn btn-outline-info" style="margin-left:2px;">
                                    <input type="radio" name="${radioMcu}" autocomplete="off" value="${orgao.mcu}"/> ${orgao.sigla}
                               </label>`;
                    $("#opcoesMcu").append(btn);
                });
                
                // Ativar o botão "Todos" para órgãos inicialmente
                $(`input[name='opcaoMcu'][value='Todos']`).parent().addClass('active');
                
                var mcuSelecionado = "Todos";
            <cfelse>
                // Se o usuário tem perfil 8, define o MCU diretamente
                var mcuSelecionado = "<cfoutput>#orgaoOrigemSelecionado#</cfoutput>";
            </cfif>
            
            // Tornar as variáveis disponíveis globalmente
            window.mcuSelecionado = mcuSelecionado;
            window.anoSelecionado = anoSelecionado;
            
            console.log("Configuração inicial dos filtros:", {
                anoSelecionado: anoSelecionado,
                mcuSelecionado: mcuSelecionado
            });
        
            // Handler para mudança de ano
            $("input[name='opcaoAno']").change(function() {
                anoSelecionado = $(this).val();
                window.anoSelecionado = anoSelecionado; // Atualizar a variável global
                console.log("Filtro de ano alterado:", anoSelecionado);
                // Recarregar todos os componentes no dashboard com os novos filtros
                recarregarTodosComponentes();
            });
            
            <cfif mostrarFiltroOrgao>
                // Handler para mudança de órgão (apenas se o filtro estiver visível)
                $("input[name='opcaoMcu']").change(function() {
                    mcuSelecionado = $(this).val();
                    window.mcuSelecionado = mcuSelecionado;
                    console.log("Filtro de órgão alterado:", mcuSelecionado);
                    // Recarregar todos os componentes no dashboard com os novos filtros
                    recarregarTodosComponentes();
                });
            </cfif>

            // Nova função para recarregar todos os componentes quando os filtros mudam
            function recarregarTodosComponentes() {
                console.log("Recarregando todos os componentes com filtros atualizados");
                $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                $('#modalOverlay').modal('show');
                
                // Obter todos os widgets ativos no grid
                var widgets = $('.grid-stack-item').toArray();
                if (widgets.length === 0) {
                    console.log("Não há widgets para recarregar");
                    $('#modalOverlay').modal('hide');
                    return;
                }
                
                console.log("Recarregando " + widgets.length + " widgets");
                
                // Para cada widget, recarregar seu conteúdo com os novos filtros
                widgets.forEach(function(widget) {
                    var $widget = $(widget);
                    var widgetId = $widget.attr('id');
                    var path = $widget.data('path');
                    var $content = $('#content-' + widgetId);
                    
                    console.log("Recarregando widget:", widgetId, "com path:", path);
                    
                    // Adicionar um loader temporário enquanto recarrega
                    $content.html(`
                        <div class="loader-placeholder d-flex justify-content-center align-items-center" style="height: 100%">
                            <div class="spinner-border text-primary" role="status">
                                <span class="sr-only">Atualizando...</span>
                            </div>
                        </div>
                    `);
                    
                    // Recarregar o conteúdo AJAX
                    $.ajax({
                        url: path,
                        method: 'GET',
                        data: { 
                            anoSelecionado: window.anoSelecionado,
                            mcuSelecionado: window.mcuSelecionado
                        },
                        dataType: 'html',
                        success: function(response) {
                            console.log("Componente recarregado com sucesso:", path);
                            $content.html(response);
                            
                            // Recarregar os dados específicos para este widget
                            var tipoComponente = identificarTipoComponente(path);
                            if (tipoComponente) {
                                carregarDadosParaComponente($content, tipoComponente);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error("Erro ao recarregar componente:", path, error);
                            $content.html('<div class="alert alert-danger">Erro ao recarregar: ' + error + '</div>');
                        }
                    });
                });
                
                // Fechar o modal após um timeout seguro
                setTimeout(function() {
                    $('#modalOverlay').modal('hide');
                }, 2500);
            }

            // Função para identificar o tipo de componente com base no path - REMOVIDO caso para gráficos
            function identificarTipoComponente(path) {
                if (!path) return null;
                
                path = path.toLowerCase();
                console.log("Identificando tipo de componente para path:", path);
                
                if (path.includes('orgaos_processo')) return "orgaos";
                if (path.includes('cards_metricas_processo')) return "metricas";
                if (path.includes('distribuicao_status')) return "status";
                if (path.includes('tipos_processo')) return "tipos";
                if (path.includes('classificacao_processo')) return "classificacao";
                
                return null;
            }

            // Função para carregar dados para os componentes - REMOVIDO caso para gráficos
            function carregarDadosParaComponente($widget, tipoComponente) {
                console.log("Carregando dados para o componente:", tipoComponente, "com filtros:", {
                    ano: window.anoSelecionado,
                    mcuOrigem: window.mcuSelecionado
                });
                
                // Adicionar uma classe para indicar carregamento
                $widget.addClass('loading-data');
                
                // Chamada AJAX para buscar os dados do dashboard
                $.ajax({
                    url: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
                    method: 'POST',
                    data: { 
                        ano: window.anoSelecionado,
                        mcuOrigem: window.mcuSelecionado,
                        statusFiltro: "Todos" // Status fixo como "Todos" para simplificar
                    },
                    dataType: 'json',
                    success: function(dados) {
                        console.log("Dados recebidos com sucesso para componente", tipoComponente);
                        $widget.removeClass('loading-data');
                        
                        // Verificar se temos dados válidos antes de tentar atualizar o componente
                        if (!dados) {
                            console.error("Dados inválidos recebidos para", tipoComponente);
                            $widget.append('<div class="alert alert-warning mt-3">Dados inválidos recebidos do servidor</div>');
                            return;
                        }
                        
                        // Chamar a função de atualização específica para este tipo de componente
                        try {
                            switch(tipoComponente) {
                                case "orgaos":
                                    if (typeof window.atualizarViewOrgaos === 'function') {
                                        window.atualizarViewOrgaos(dados);
                                    }
                                    break;
                                    
                                case "metricas":
                                    if (typeof window.atualizarCardsProcMet === 'function') {
                                        window.atualizarCardsProcMet(dados);
                                    }
                                    break;
                                    
                                case "status":
                                    if (typeof window.atualizarDistribuicaoStatus === 'function' && dados.distribuicaoStatus) {
                                        window.atualizarDistribuicaoStatus(dados.distribuicaoStatus);
                                    }
                                    break;
                                    
                                case "tipos":
                                    if (typeof window.atualizarTiposProcesso === 'function' && dados.distribuicaoTipos) {
                                        window.atualizarTiposProcesso(dados.distribuicaoTipos, dados.totalProcessos);
                                    }
                                    break;
                                    
                                case "classificacao":
                                    if (typeof window.atualizarClassificacaoProcesso === 'function' && dados.distribuicaoClassificacao) {
                                        console.log("Chamando atualizarClassificacaoProcesso com dados:", {
                                            qtdClassificacoes: dados.distribuicaoClassificacao ? dados.distribuicaoClassificacao.length : 0,
                                            totalProcessos: dados.totalProcessos || 0
                                        });
                                        window.atualizarClassificacaoProcesso(dados.distribuicaoClassificacao, dados.totalProcessos);
                                    } else {
                                        console.error("Função atualizarClassificacaoProcesso não disponível ou dados.distribuicaoClassificacao ausente");
                                        $widget.append('<div class="alert alert-warning mt-3">Não foi possível processar os dados de classificação</div>');
                                    }
                                    break;
                            }
                        } catch (err) {
                            console.error("Erro ao atualizar componente", tipoComponente, err);
                            $widget.append('<div class="alert alert-warning mt-3">Erro ao processar dados: ' + err.message + '</div>');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error("Erro na chamada AJAX para componente", tipoComponente, ":", {
                            status: status,
                            error: error,
                            responseText: xhr.responseText
                        });
                        $widget.removeClass('loading-data');
                        $widget.append('<div class="alert alert-warning mt-3">Erro ao carregar dados: ' + error + '</div>');
                    }
                });
            }

            function carregarDashboard() {
                console.log("Carregando dashboard com os filtros:", {
                    anoSelecionado: anoSelecionado,
                    mcuSelecionado: mcuSelecionado
                });
                
                $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                $('#modalOverlay').modal('show');
                
                // Simulando carregamento dos dados para os componentes
                setTimeout(function() {
                    // Aqui você chamaria as funções de atualização para cada componente
                    // Por exemplo:
                    if (typeof window.atualizarCardsProcMet === 'function') {
                        // Dados simulados
                        var dadosSimulados = {
                            totalProcessos: 150,
                            processosPlanejados: 50,
                            processosEmAndamento: 30,
                            processosConcluidos: 70
                        };
                        window.atualizarCardsProcMet(dadosSimulados);
                    }
                    
                    if (typeof window.atualizarDistribuicaoStatus === 'function') {
                        // Dados simulados
                        var dadosStatus = [
                            {status: 'Planejado', quantidade: 50, cor: '#3498db'},
                            {status: 'Em Andamento', quantidade: 30, cor: '#f39c12'},
                            {status: 'Concluído', quantidade: 70, cor: '#2ecc71'}
                        ];
                        window.atualizarDistribuicaoStatus(dadosStatus);
                    }
                    
                    if (typeof window.atualizarTiposProcesso === 'function') {
                        // Dados simulados
                        var dadosTipos = [
                            {tipo: 'Auditoria', quantidade: 40},
                            {tipo: 'Conformidade', quantidade: 60},
                            {tipo: 'Consultoria', quantidade: 30},
                            {tipo: 'Investigação', quantidade: 20}
                        ];
                        window.atualizarTiposProcesso(dadosTipos, 150);
                    }
                    
                    $('#modalOverlay').modal('hide');
                    console.log("Dashboard carregado com sucesso");
                }, 1500);
            }
            
            // Carregar o dashboard inicial
            carregarDashboard();

            // Configuração do GridStack
            var grid;
           
            
            // Função para inicializar o GridStack
            function initGrid(items) {
                console.log("Inicializando GridStack com items:", items);
                
                // Se já existe uma instância, destrua primeiro
                if (grid) {
                    grid.destroy(false);
                    $('.grid-stack').empty();
                }
                
                try {
                    // Inicializa o GridStack com opções
                    grid = GridStack.init({
                        column: 12,
                        cellHeight: 50,
                        animate: true,
                        resizable: {
                            handles: 'e, se, s, sw, w'
                        },
                        disableOneColumnMode: false,
                        float: true,
                        minRow: 1
                    }, '.grid-stack');
                    
                    console.log("GridStack inicializado com sucesso");
                    
                    // Adicionar um evento de alteração para salvar automaticamente
                    grid.on('change', function() {
                        console.log("Grid alterado, salvando automaticamente");
                        saveGrid();
                    });
                    
                    // Carrega os itens
                    loadGridItems(items);
                } catch (error) {
                    console.error("Erro ao inicializar GridStack:", error);
                    alert("Erro ao inicializar o dashboard. Consulte o console para mais detalhes.");
                }
            }
            
            // Função para carregar os itens no grid (Corrigida para não usar defaultItems)
            function loadGridItems(items) {
                try {
                    console.log("Carregando", items ? items.length : 0, "itens no GridStack");
                    
                    // Garantir que temos itens para adicionar
                    if (!items || items.length === 0) {
                        console.warn("Nenhum item para adicionar ao grid, usando array vazio");
                        items = []; // Usar array vazio em vez de defaultItems
                    }
                    
                    // Limpar grid primeiro
                    grid.removeAll();
                    
                    // Se ainda não há items, retornar sem adicionar nada
                    if (items.length === 0) {
                        console.log("Grid inicializado vazio, aguardando adição de componentes pelo usuário");
                        return;
                    }
                    
                    // Adicionar cada widget com seu conteúdo
                    items.forEach(function(item) {
                        // Criar a estrutura básica do widget
                        var widget = document.createElement('div');
                        widget.className = 'grid-stack-item';
                        widget.id = item.id; // Atribui o id para seleção via jQuery
                        widget.setAttribute('gs-id', item.id);
                        widget.setAttribute('gs-x', item.x);
                        widget.setAttribute('gs-y', item.y);
                        widget.setAttribute('gs-w', item.w);
                        widget.setAttribute('gs-h', item.h);
                        $(widget).data('componentId', item.componentId); // Armazena o ID do componente original
                        // Armazena o caminho (path) para o AJAX
                        $(widget).data('path', item.path);
                        widget.innerHTML = `
                            <div class="grid-stack-item-content">
                                <div class="grid-stack-item-header">
                                    <h5>${item.title ? item.title : 'Widget'}</h5>
                                    <div class="control-buttons">
                                        <button class="refresh-widget" title="Atualizar"><i class="fas fa-sync-alt"></i></button>
                                        <button class="remove-widget" title="Remover"><i class="fas fa-times"></i></button>
                                    </div>
                                </div>
                                <div class="widget-content" id="content-${item.id}">
                                    <div class="loader-placeholder d-flex justify-content-center align-items-center" style="height: 100%">
                                        <div class="spinner-border text-primary" role="status">
                                            <span class="sr-only">Carregando...</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        `;
                        
                        // Utilize makeWidget para adicionar o widget
                        grid.makeWidget(widget);
                        console.log(`Widget ${item.id} adicionado ao grid com path ${item.path}`);
                    });
                    
                    console.log("Todos os widgets foram adicionados ao grid");
                    
                    // Configurar os handlers dos botões após adicionar todos os widgets
                    setupWidgetHandlers();
                    
                    // Preencher os conteúdos dos widgets após um breve atraso
                    setTimeout(function() {
                        fillWidgetContents(items);
                    }, 500);
                } catch (error) {
                    console.error("Erro ao carregar items no GridStack:", error);
                    // Em caso de erro, tente uma recuperação com o layout padrão
                    try {
                        console.log("Tentando recuperar com array vazio");
                        grid.removeAll();
                        // Não tentar recarregar com defaultItems
                    } catch (innerError) {
                        console.error("Falha na recuperação:", innerError);
                        alert("Erro ao carregar o dashboard. Por favor, recarregue a página.");
                    }
                }
            }
            
            // Função para preencher os conteúdos dos widgets via AJAX - adicionado log detalhado
            function fillWidgetContents(items) {
                console.log("Preenchendo conteúdos dos widgets via AJAX para", items.length, "itens");
                items.forEach(function(item) {
                    console.log("Carregando conteúdo para o widget:", item.id, "com path:", item.path);
                    
                    // Garantir que os parâmetros sejam passados corretamente
                    var parametros = { 
                        anoSelecionado: window.anoSelecionado || "Todos",
                        mcuSelecionado: window.mcuSelecionado || "Todos"
                    };
                    
                    console.log("Parâmetros enviados:", parametros);
                    
                    // Obter o seletor do conteúdo do widget
                    var $contentWidget = $("#content-" + item.id);
                    
                    // Para cada widget, faça uma chamada AJAX usando o item.path e os filtros disponíveis
                    $.ajax({
                        url: item.path,
                        method: 'GET',
                        data: parametros,
                        dataType: 'html',
                        success: function(response) {
                            console.log("Componente carregado com sucesso:", item.path);
                            // Remover explicitamente o loader antes de inserir o conteúdo
                            $contentWidget.find(".loader-placeholder").remove();
                            $contentWidget.html(response);
                            
                            // Depois de carregar o componente, verificar se é o componente de classificação e carregar os dados para ele
                            var tipoComponente = identificarTipoComponente(item.path);
                            console.log("Tipo de componente identificado para", item.path, ":", tipoComponente);
                            if (tipoComponente) {
                                carregarDadosParaComponente($contentWidget, tipoComponente);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error("Erro ao carregar componente:", item.path, "Status:", status, "Erro:", error);
                            // Registrar o conteúdo da resposta para diagnóstico
                            console.error("Resposta:", xhr.responseText);
                            // Remover loader e mostrar mensagem de erro
                            $contentWidget.find(".loader-placeholder").remove();
                            $contentWidget.html('<div class="alert alert-danger">Erro ao carregar o componente: ' + error + '</div>');
                        }
                    });
                });
                
                // Verificar se os componentes foram carregados após um tempo
                setTimeout(function() {
                    $('.grid-stack-item').each(function() {
                        var $content = $(this).find('.widget-content');
                        // Se o loader ainda existir, provavelmente houve um problema
                        if ($content.find('.loader-placeholder').length > 0) {
                            console.warn("Loader ainda presente em " + $(this).attr('id') + ". Removendo.");
                            $content.find('.loader-placeholder').remove();
                            $content.append('<div class="alert alert-warning">O componente não foi carregado completamente.</div>');
                        }
                    });
                }, 10000); // 10 segundos de timeout
            }
            
            // Função para carregar dados para os componentes
            function carregarDadosParaComponente($widget, tipoComponente) {
                console.log("Carregando dados para o componente:", tipoComponente);
                
                // Chamada AJAX para buscar os dados do dashboard
                $.ajax({
                    url: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
                    method: 'POST',
                    data: { 
                        ano: window.anoSelecionado,
                        mcuOrigem: window.mcuSelecionado,
                        statusFiltro: "Todos" // Status fixo como "Todos" para simplificar
                    },
                    dataType: 'json',
                    success: function(dados) {
                        console.log("Dados recebidos para", tipoComponente, ":", dados);
                        
                        switch(tipoComponente) {
                            case "orgaos":
                                if (typeof window.atualizarViewOrgaos === 'function') {
                                    console.log("Atualizando visualização de órgãos com dados:", dados);
                                    window.atualizarViewOrgaos(dados);
                                }
                                break;
                                
                            case "metricas":
                                if (typeof window.atualizarCardsProcMet === 'function') {
                                    console.log("Atualizando métricas com dados:", dados);
                                    window.atualizarCardsProcMet(dados);
                                }
                                break;
                                
                            case "status":
                                if (typeof window.atualizarDistribuicaoStatus === 'function') {
                                    console.log("Atualizando distribuição de status com dados:", dados.distribuicaoStatus);
                                    window.atualizarDistribuicaoStatus(dados.distribuicaoStatus);
                                }
                                break;
                                
                            case "tipos":
                                if (typeof window.atualizarTiposProcesso === 'function') {
                                    console.log("Atualizando tipos de processo com dados:", dados.distribuicaoTipos, dados.totalProcessos);
                                    window.atualizarTiposProcesso(dados.distribuicaoTipos, dados.totalProcessos);
                                }
                                break;
                                
                            case "classificacao":
                                if (typeof window.atualizarClassificacaoProcesso === 'function') {
                                    console.log("Atualizando classificação de processos com dados:", dados);
                                    window.atualizarClassificacaoProcesso(dados.distribuicaoClassificacao, dados.totalProcessos);
                                }
                                break;
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error("Erro ao carregar dados para o componente", tipoComponente, ":", error);
                        $widget.append('<div class="alert alert-warning mt-3">Erro ao carregar dados: ' + error + '</div>');
                    }
                });
            }
            
            // Função para atualizar componentes - CORRIGIDA
            function updateWidgetComponents() {
                console.log("Não há funções nativas para atualizar os componentes, pois estes são carregados via AJAX.");
                $('#modalOverlay').modal('hide');
            }
            
            // Função para configurar eventos dos botões em cada widget - Corrigido o comportamento do refresh
            function setupWidgetHandlers() {
                // Remover handlers existentes para evitar duplicação
                $('.grid-stack').off('click', '.refresh-widget');
                $('.grid-stack').off('click', '.remove-widget');
                
                // Evento para o botão de atualizar widget - CORRIGIDO
                $('.grid-stack').on('click', '.refresh-widget', function() {
                    var widget = $(this).closest('.grid-stack-item');
                    var widgetId = widget.attr('id');
                    var path = widget.data('path');
                    var $content = $('#content-' + widgetId);
                    
                    console.log("Atualizando widget:", widgetId, "com path:", path);
                    
                    // Mostrar um indicador de carregamento no widget
                    $content.html(`
                        <div class="loader-placeholder d-flex justify-content-center align-items-center" style="height: 100%">
                            <div class="spinner-border text-primary" role="status">
                                <span class="sr-only">Atualizando...</span>
                            </div>
                        </div>
                    `);
                    
                    // Recarregar apenas este componente via AJAX
                    $.ajax({
                        url: path,
                        method: 'GET',
                        data: { 
                            anoSelecionado: window.anoSelecionado,
                            mcuSelecionado: window.mcuSelecionado
                        },
                        dataType: 'html',
                        success: function(response) {
                            console.log("Componente atualizado com sucesso:", path);
                            $content.html(response);
                            
                            // Depois de recarregar o HTML, carregar os dados para este componente específico
                            var tipoComponente = identificarTipoComponente(path);
                            if (tipoComponente) {
                                carregarDadosParaComponente($content, tipoComponente);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error("Erro ao atualizar componente:", path, error);
                            $content.html('<div class="alert alert-danger">Erro ao atualizar: ' + error + '</div>');
                        }
                    });
                });
                
                // Evento para o botão de remover widget
                $('.grid-stack').on('click', '.remove-widget', function() {
                    var widget = $(this).closest('.grid-stack-item');
                    console.log("Removendo widget:", widget.attr('id'));
                    
                    // Confirmar antes de remover
                    if (confirm("Deseja realmente remover este widget do dashboard?")) {
                        grid.removeWidget(widget[0]);
                        saveGrid();
                    }
                });
            }
            
            // Função para salvar o estado atual do grid no localStorage - corrigida para usar API do GridStack
            function saveGrid() {
                var items = [];
                
                try {
                    // Usar a API do GridStack para obter os itens serializados
                    if (grid) {
                        // Pega os dados do grid de forma segura
                        var gridItems = grid.save();
                        console.log("GridStack items capturados:", gridItems);
                        
                        // Para cada item, manter os dados adicionais importantes
                        gridItems.forEach(function(node) {
                            // Encontrar o elemento DOM correspondente para pegar os dados adicionais
                            var $el = $('#' + node.id);
                            
                            items.push({
                                x: node.x,
                                y: node.y,
                                w: node.w,
                                h: node.h,
                                id: node.id,
                                path: $el.data('path') || node.path, // Caminho do componente
                                componentId: $el.data('componentId') || node.componentId,
                                title: $el.find('.grid-stack-item-header h5').text() || node.title // Obter o título atual do header
                            });
                        });
                    } else {
                        console.error("Grid não está inicializado");
                    }
                } catch (error) {
                    console.error("Erro ao salvar o grid:", error);
                }
                
                // Verificar se temos dados para salvar
                if (items.length > 0) {
                    // Salvar no localStorage na chave correta
                    localStorage.setItem('snci_dashboard_favoritos', JSON.stringify(items));
                    console.log('Layout salvo com sucesso:', items);
                } else {
                    console.warn('Nenhum item para salvar no layout');
                }
                
                return items;
            }
            
            // Função para restaurar o grid do localStorage
            function loadGrid() {
                var items = [];
                try {
                    var savedData = localStorage.getItem('snci_dashboard_favoritos');
                    console.log("Verificando dados salvos:", savedData ? "Dados encontrados (" + savedData.length + " bytes)" : "Nenhum dado encontrado");
                    
                    if (savedData) {
                        try {
                            items = JSON.parse(savedData);
                            console.log("Dados parseados com sucesso:", items.length, "itens");
                            
                            if (!Array.isArray(items) || items.length === 0) {
                                console.warn("Formato inválido ou array vazio");
                                items = [];
                            } else {
                                items = items.map(function(item, index) {
                                    // Garantir que todos os campos necessários existam
                                    return {
                                        x: typeof item.x !== 'undefined' ? item.x : (index % 2) * 6,
                                        y: typeof item.y !== 'undefined' ? item.y : Math.floor(index / 2) * 6,
                                        w: item.w || 6,
                                        h: item.h || 6,
                                        id: item.id || ('widget-' + Date.now() + '-' + index),
                                        path: item.path,
                                        componentId: item.componentId,
                                        title: item.title || 'Widget'
                                    };
                                });
                            }
                        } catch (parseError) {
                            console.error("Erro ao fazer parse dos dados:", parseError);
                            items = [];
                        }
                    } else {
                        console.log("Nenhum layout salvo encontrado");
                        items = [];
                    }
                } catch (e) {
                    console.error("Erro ao acessar localStorage:", e);
                    items = [];
                }
                
                initGrid(items);
                return items;
            }
            
            // Função para resetar o grid para o padrão
            function resetGrid() {
                if (confirm("Deseja realmente resetar o layout para o padrão? Todas as suas personalizações serão perdidas.")) {
                    try {
                        localStorage.removeItem('snci_dashboard_favoritos');
                        console.log("Layout resetado para o padrão");
                        initGrid([]);
                    } catch (e) {
                        console.error("Erro ao resetar layout:", e);
                    }
                }
            }
            
            // Botões de controle do grid - adicionar logs de debug
            $('#btn-salvar-layout').click(function() {
                console.log("Tentando salvar layout. Grid está inicializado:", !!grid);
                
                if (grid) {
                    console.log("Itens do grid:", grid.engine.nodes.length ? "Encontrados" : "Vazio");
                }
                
                var items = saveGrid();
                if (items && items.length > 0) {
                    alert("Layout salvo com sucesso! " + items.length + " componentes salvos.");
                } else {
                    alert("Não foi possível salvar o layout. Nenhum componente encontrado.");
                }
            });
            
            $('#btn-restaurar-layout').click(function() {
                loadGrid();
                alert("Layout restaurado!");
            });
            
            $('#btn-resetar-layout').click(function() {
                resetGrid();
            });
            
            // Garantir que o GridStack seja carregado após os scripts
            setTimeout(function() {
                // Iniciar o GridStack
                try {
                    console.log("Iniciando GridStack");
                    // IMPORTANTE: Remover esta linha que limpa o localStorage
                    // localStorage.removeItem('snci_dashboard_favoritos'); 
                    
                    var items = loadGrid();
                    console.log("GridStack iniciado com sucesso");
                    
                    // Registrar evento de mudança no grid para salvar automaticamente
                    if (grid) {
                        grid.on('change', function(event, items) {
                            console.log('GridStack mudou, salvando automaticamente...');
                            saveGrid();
                        });
                    }
                } catch (e) {
                    console.error("Erro ao inicializar GridStack:", e);
                    
                    // Tentar iniciar com layout padrão em caso de erro
                    try {
                        console.log("Tentando iniciar com layout padrão após erro");
                        initGrid([]); // Passar um array vazio
                    } catch (innerError) {
                        console.error("Falha total ao inicializar GridStack:", innerError);
                        alert("Não foi possível inicializar o dashboard. Por favor, recarregue a página.");
                    }
                }
            }, 1000); // Aumento do timeout para permitir que tudo carregue corretamente
        });
    </script>
</body>
</html>
