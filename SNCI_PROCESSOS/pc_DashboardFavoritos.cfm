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
    
    <!-- Estilos específicos dos componentes -->
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Metricas.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Status.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Tipos.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Classificacao.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Orgaos.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Graficos.css">
    <!-- GridStack CSS -->
    <link rel="stylesheet" href="plugins/gridstack/gridstack.min.css" />
    
    <!-- IMPORTANTE: Carregue o script do componente dashboard antes de qualquer coisa -->
    <script src="dist/js/snciDashboardComponent.js"></script>
   
    <script>
        // Sobrescreve document.write para evitar que ele apague o DOM depois do carregamento
        document.write = function(content) {
            console.warn("document.write foi chamado e ignorado:", content);
        };
    </script>
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
            
            // Verificar se DashboardComponentFactory está disponível
            if (typeof DashboardComponentFactory === 'undefined') {
                console.error("DashboardComponentFactory não está disponível. Tentando carregar o script novamente.");
                $.getScript("dist/js/snciDashboardComponent.js")
                  .done(function() {
                    console.log("Script snciDashboardComponent.js carregado com sucesso.");
                    inicializarDashboard();
                  })
                  .fail(function(jqxhr, settings, exception) {
                    console.error("Erro ao carregar snciDashboardComponent.js: ", exception);
                    alert("Erro ao carregar componentes do dashboard. Por favor, recarregue a página.");
                  });
            } else {
                console.log("DashboardComponentFactory já está disponível.");
                inicializarDashboard();
            }
            
            function inicializarDashboard() {
                var anos = [];
                var orgaos = [];
                var currentYear = new Date().getFullYear();
                var grid; // ADICIONADO: declaração global da variável grid
                
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

                // Função para identificar o tipo de componente com base no path
                function identificarTipoComponente(path) {
                    if (!path) return null;
                    
                    path = path.toLowerCase();
                    console.log("Identificando tipo de componente para path:", path);
                    
                    if (path.includes('orgaos_processo')) return "orgaos";
                    if (path.includes('cards_metricas_processo')) return "metricas";
                    if (path.includes('distribuicao_status')) return "status";
                    if (path.includes('tipos_processo')) return "tipos";
                    if (path.includes('classificacao_processo')) return "classificacao";
                    if (path.includes('graficos_processo')) return "graficos"; // Adicionado caso para gráficos
                    
                    return null;
                }

                // Função para carregar dados para os componentes
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
                            console.log("Dados recebidos para", tipoComponente, ":", dados);
                            $widget.removeClass('loading-data');
                            
                            // Armazenar dados globalmente para que todos os componentes possam acessar
                            window.dadosAtuais = dados;
                            
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
                                        
                                    case "graficos":
                                        if (typeof window.atualizarGraficos === 'function') {
                                            console.log("Atualizando gráficos com dados:", dados);
                                            window.atualizarGraficos(dados);
                                        } else {
                                            console.warn("Função atualizarGraficos não encontrada, tentando injetar inicializador");
                                            
                                            // Injetar um script para tentar inicializar o componente de gráficos
                                            var scriptId = 'init-graficos-' + Date.now();
                                            var script = document.createElement('script');
                                            script.id = scriptId;
                                            script.textContent = `
                                                console.log("Tentando inicializar componente de gráficos");
                                                
                                                // Verificar se a função existe a cada 100ms por até 3 segundos
                                                var checkCount = 0;
                                                var checkInterval = setInterval(function() {
                                                    checkCount++;
                                                    if (typeof window.atualizarGraficos === 'function') {
                                                        clearInterval(checkInterval);
                                                        console.log("Função atualizarGraficos encontrada, atualizando com dados");
                                                        window.atualizarGraficos(window.dadosAtuais);
                                                    } else if (checkCount > 30) { // 30 * 100ms = 3 segundos
                                                        clearInterval(checkInterval);
                                                        console.error("Timeout esperando função atualizarGraficos");
                                                    }
                                                }, 100);
                                            `;
                                            document.body.appendChild(script);
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
                    
                    // Chamar carregarDados() para obter os dados reais
                    carregarDados();
                    
                    // Fechar o modal após um tempo seguro
                    setTimeout(function() {
                        $('#modalOverlay').modal('hide');
                    }, 2500);
                }
                
                // Alteração na função initGrid para tratamento robusto de erros
                function initGrid(items) {
                    console.log("Inicializando GridStack com items:", items);
                    
                    // Se já existe uma instância, destruir e limpar
                    if (grid) {
                        try {
                            grid.destroy(false);
                        } catch(e) {
                            console.error("Erro ao destruir grid anterior:", e);
                        }
                        $('.grid-stack').empty();
                    }
                    
                    try {
                        // Tenta iniciar o GridStack com as opções definidas
                        grid = GridStack.init({
                            column: 12,
                            cellHeight: 50,
                            animate: true,
                            resizable: { handles: 'e, se, s, sw, w' },
                            disableOneColumnMode: false,
                            float: true,
                            minRow: 1
                        }, '.grid-stack');
                        
                        console.log("GridStack inicializado com sucesso");
                        // Registrar evento de mudança para salvar automaticamente
                        grid.on('change', function() {
                            console.log("Grid alterado, salvando automaticamente");
                            saveGrid();
                        });
                        
                        loadGridItems(items);
                    } catch (error) {
                        console.error("Erro ao inicializar GridStack:", error);
                        try {
                            // Caso haja erro, remover layout salvo e reinicializar com array vazio
                            localStorage.removeItem('snci_dashboard_favoritos');
                            console.log("Layout salvo removido. Tentando iniciar com layout vazio.");
                            grid = GridStack.init({
                                column: 12,
                                cellHeight: 50,
                                animate: true,
                                resizable: { handles: 'e, se, s, sw, w' },
                                disableOneColumnMode: false,
                                float: true,
                                minRow: 1
                            }, '.grid-stack');
                            loadGridItems([]);
                        } catch (innerError) {
                            console.error("Falha total ao inicializar GridStack:", innerError);
                            alert("Não foi possível inicializar o dashboard. Por favor, recarregue a página.");
                        }
                    }
                }
                
                // Função para carregar os itens no grid (corrigida para adicionar os botões de controle)
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
                
                // Função melhorada para preencher os conteúdos dos widgets via AJAX
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
                                // Remover o loader antes de inserir o conteúdo
                                $contentWidget.find(".loader-placeholder").remove();
                                
                                // Criar um DOM temporário para processar a resposta
                                var tempDiv = document.createElement('div');
                                tempDiv.innerHTML = response;
                                
                                // 1. Extrair links CSS para aplicar ao head (NOVO)
                                var links = tempDiv.getElementsByTagName('link');
                                var linksToAdd = [];
                                
                                for (var i = links.length - 1; i >= 0; i--) {
                                    if (links[i].rel === 'stylesheet') {
                                        linksToAdd.push(links[i].href);
                                        links[i].parentNode.removeChild(links[i]);
                                    }
                                }
                                
                                // Adicionar os links CSS ao head, se ainda não existirem
                                linksToAdd.forEach(function(href) {
                                    if (!$('link[href="' + href + '"]').length) {
                                        $('head').append('<link rel="stylesheet" href="' + href + '">');
                                    }
                                });
                                
                                // 2. Inserir o HTML sem scripts
                                $contentWidget.html(tempDiv.innerHTML);
                                
                                // 3. Adicionar os botões de controle no header do widget (verificando se já existem primeiro)
                                var $widgetHeader = $('#' + item.id).find('.grid-stack-item-header .control-buttons');
                                if ($widgetHeader.length && $widgetHeader.children().length === 0) {
                                    $widgetHeader.html(`
                                        <button class="refresh-widget" title="Atualizar"><i class="fas fa-sync-alt"></i></button>
                                        <button class="remove-widget" title="Remover"><i class="fas fa-times"></i></button>
                                    `);
                                }
                                
                                // 4. Executar os scripts extraídos
                                var scripts = tempDiv.getElementsByTagName('script');
                                var scriptsContent = [];
                                
                                for (var i = scripts.length - 1; i >= 0; i--) {
                                    if (scripts[i].src) {
                                        scriptsContent.push({
                                            src: scripts[i].src
                                        });
                                    } else if (scripts[i].innerHTML) {
                                        scriptsContent.push({
                                            code: scripts[i].innerHTML
                                        });
                                    }
                                    scripts[i].parentNode.removeChild(scripts[i]);
                                }
                                
                                scriptsContent.forEach(function(scriptItem) {
                                    if (scriptItem.src) {
                                        // Verificar se o script já está carregado
                                        var scriptExists = false;
                                        $('script').each(function() {
                                            if (this.src === scriptItem.src) {
                                                scriptExists = true;
                                                return false; // break
                                            }
                                        });
                                        
                                        if (!scriptExists) {
                                            // Carregar script externo
                                            var scriptElement = document.createElement('script');
                                            scriptElement.src = scriptItem.src;
                                            document.body.appendChild(scriptElement);
                                        }
                                    } else if (scriptItem.code) {
                                        // Executar código JavaScript inline
                                        try {
                                            // Criar um elemento de script
                                            var scriptElement = document.createElement('script');
                                            scriptElement.textContent = scriptItem.code;
                                            document.body.appendChild(scriptElement);
                                        } catch (e) {
                                            console.error("Erro ao executar script:", e);
                                        }
                                    }
                                });
                                
                                // Identificar o tipo de componente pelo path e inicializar
                                var tipoComponente = identificarTipoComponente(item.path);
                                
                                if (tipoComponente) {
                                    console.log("Inicializando componente favorito:", tipoComponente);
                                    
                                    // Usar a nova função para inicializar componentes de favoritos
                                    if (typeof DashboardComponentFactory !== 'undefined' && 
                                        typeof DashboardComponentFactory.inicializarComponenteFavorito === 'function') {
                                        try {
                                            var componenteFavorito = DashboardComponentFactory.inicializarComponenteFavorito(
                                                tipoComponente, 
                                                $contentWidget.attr('id'), 
                                                item.id
                                            );
                                            
                                            // Se o componente foi inicializado com sucesso, carregar dados para ele
                                            if (componenteFavorito) {
                                                // Carregamento inicial de dados
                                                carregarDadosParaComponentes();
                                            }
                                        } catch (e) {
                                            console.error("Erro ao inicializar componente favorito:", e);
                                            $contentWidget.append('<div class="alert alert-danger">Erro ao inicializar componente: ' + e.message + '</div>');
                                        }
                                    } else {
                                        console.error("DashboardComponentFactory não está disponível ou não tem a função inicializarComponenteFavorito");
                                        $contentWidget.append('<div class="alert alert-warning">API de componentes não disponível ou desatualizada</div>');
                                    }
                                } else {
                                    console.warn("Tipo de componente não identificado para path:", item.path);
                                    $contentWidget.append('<div class="alert alert-warning">Tipo de componente não reconhecido</div>');
                                }
                            },
                            error: function(xhr, status, error) {
                                console.error("Erro ao carregar componente:", item.path, "Status:", status, "Erro:", error);
                                console.error("Resposta:", xhr.responseText);
                                $contentWidget.find(".loader-placeholder").remove();
                                $contentWidget.html('<div class="alert alert-danger">Erro ao carregar o componente: ' + error + '</div>');
                            }
                        });
                    });
                }
                
                // Função global para carregar dados para todos os componentes ativos
                function carregarDadosParaComponentes() {
                    console.log("Carregando dados para todos os componentes");
                    
                    // Mostrar indicador de carregamento
                    $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                    $('#modalOverlay').modal('show');
                    
                    // Fazer uma única chamada AJAX para obter todos os dados necessários
                    $.ajax({
                        url: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
                        method: 'POST',
                        data: { 
                            ano: window.anoSelecionado || "Todos",
                            mcuOrigem: window.mcuSelecionado || "Todos",
                            statusFiltro: "Todos" // Status fixo como "Todos" para os favoritos
                        },
                        dataType: 'json',
                        success: function(dados) {
                            console.log("Dados recebidos com sucesso para todos os componentes");
                            
                            // Armazenar dados globalmente
                            window.dadosAtuais = dados;
                            
                            // Chamar todas as funções de atualização registradas
                            if (window.atualizarDadosComponentes && Array.isArray(window.atualizarDadosComponentes)) {
                                window.atualizarDadosComponentes.forEach(function(callback) {
                                    if (typeof callback === 'function') {
                                        try {
                                            callback(dados);
                                        } catch (e) {
                                            console.error("Erro ao chamar callback de atualização:", e);
                                        }
                                    }
                                });
                            }
                            
                            // Fechar o modal após um breve delay
                            setTimeout(function() {
                                $('#modalOverlay').modal('hide');
                            }, 800);
                        },
                        error: function(xhr, status, error) {
                            console.error("Erro ao carregar dados:", error);
                            $('#modalOverlay').modal('hide');
                            alert("Erro ao carregar dados para os componentes: " + error);
                        }
                    });
                }
                
                // Função para recarregar todos os componentes quando os filtros mudam
                function recarregarTodosComponentes() {
                    console.log("Recarregando todos os componentes com filtros atualizados");
                    // Recarregar os dados para todos os componentes
                    carregarDadosParaComponentes();
                }
                
                // Função para configurar eventos dos botões em cada widget
                function setupWidgetHandlers() {
                    // Remover handlers existentes para evitar duplicação
                    $('.grid-stack').off('click', '.refresh-widget');
                    $('.grid-stack').off('click', '.remove-widget');
                    
                    // Evento para o botão de atualizar widget
                    $('.grid-stack').on('click', '.refresh-widget', function() {
                        var widget = $(this).closest('.grid-stack-item');
                        var widgetId = widget.attr('id');
                        var path = widget.data('path');
                        var $content = $('#content-' + widgetId);
                        
                        console.log("Atualizando widget:", widgetId, "com path:", path);
                        
                        // Verificar se o widget é gráficos para tratamento especial
                        var isGraficos = path && path.toLowerCase().includes('graficos_processo');
                        
                        // Remover os estilos específicos deste widget que possam estar no head
                        $('#style-' + widgetId).remove();
                        
                        // Mostrar um indicador de carregamento no widget
                        $content.html(`
                            <div class="loader-placeholder d-flex justify-content-center align-items-center" style="height: 100%">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="sr-only">Atualizando...</span>
                                </div>
                            </div>
                        `);
                        
                        // Identificar o tipo de componente
                        var tipoComponente = identificarTipoComponente(path);
                        
                        if (tipoComponente) {
                            // Reinicializar o componente usando o novo sistema
                            if (typeof DashboardComponentFactory !== 'undefined' && 
                                typeof DashboardComponentFactory.inicializarComponenteFavorito === 'function') {
                                // Carregar o conteúdo HTML do componente
                                $.ajax({
                                    url: path,
                                    method: 'GET',
                                    data: { 
                                        anoSelecionado: window.anoSelecionado || "Todos",
                                        mcuSelecionado: window.mcuSelecionado || "Todos"
                                    },
                                    dataType: 'html',
                                    success: function(response) {
                                        console.log("Conteúdo recarregado com sucesso para", widgetId);
                                        
                                        // Processar a resposta HTML mantendo os scripts
                                        var tempDiv = document.createElement('div');
                                        tempDiv.innerHTML = response;
                                        
                                        // 1. Remover os estilos (agora usamos arquivos CSS externos)
                                        var styles = tempDiv.getElementsByTagName('style');
                                        for (var i = styles.length - 1; i >= 0; i--) {
                                            styles[i].parentNode.removeChild(styles[i]);
                                        }
                                        
                                        // 2. Extrair scripts para execução posterior
                                        var scripts = tempDiv.getElementsByTagName('script');
                                        var scriptsContent = [];
                                        
                                        for (var i = scripts.length - 1; i >= 0; i--) {
                                            if (scripts[i].src) {
                                                scriptsContent.push({
                                                    src: scripts[i].src
                                                });
                                            } else if (scripts[i].innerHTML) {
                                                scriptsContent.push({
                                                    code: scripts[i].innerHTML
                                                });
                                            }
                                            scripts[i].parentNode.removeChild(scripts[i]);
                                        }
                                        
                                        // 3. Inserir o HTML limpo no conteúdo
                                        $content.html(tempDiv.innerHTML);
                                        
                                        // 4. Executar os scripts extraídos
                                        scriptsContent.forEach(function(scriptItem) {
                                            if (scriptItem.src) {
                                                // Verificar se o script já está carregado
                                                var scriptExists = false;
                                                $('script').each(function() {
                                                    if (this.src === scriptItem.src) {
                                                        scriptExists = true;
                                                        return false; // break
                                                    }
                                                });
                                                
                                                if (!scriptExists) {
                                                    var scriptElement = document.createElement('script');
                                                    scriptElement.src = scriptItem.src;
                                                    document.body.appendChild(scriptElement);
                                                }
                                            } else if (scriptItem.code) {
                                                try {
                                                    var scriptElement = document.createElement('script');
                                                    scriptElement.textContent = scriptItem.code;
                                                    document.body.appendChild(scriptElement);
                                                } catch (e) {
                                                    console.error("Erro ao executar script:", e);
                                                }
                                            }
                                        });
                                        
                                        try {
                                            // Inicializar o componente favorito
                                            var componenteFavorito = DashboardComponentFactory.inicializarComponenteFavorito(
                                                tipoComponente, 
                                                $content.attr('id'), 
                                                widgetId
                                            );
                                            
                                            // Se o componente foi inicializado com sucesso, atualizar com os dados existentes
                                            if (componenteFavorito) {
                                                if (window.dadosAtuais) {
                                                    componenteFavorito.atualizar(window.dadosAtuais);
                                                } else {
                                                    carregarDadosParaComponentes();
                                                }
                                            }
                                        } catch (e) {
                                            console.error("Erro ao inicializar componente favorito:", e);
                                            $content.append('<div class="alert alert-danger">Erro ao inicializar componente: ' + e.message + '</div>');
                                        }
                                    },
                                    error: function(xhr, status, error) {
                                        console.error("Erro ao recarregar componente:", error);
                                        $content.html('<div class="alert alert-danger">Erro ao recarregar o componente: ' + error + '</div>');
                                    }
                                });
                            } else {
                                // Fallback para método antigo se DashboardComponentFactory não estiver disponível
                                $.ajax({
                                    url: path,
                                    method: 'GET',
                                    data: { 
                                        anoSelecionado: window.anoSelecionado,
                                        mcuSelecionado: window.mcuSelecionado
                                    },
                                    dataType: 'html',
                                    success: function(response) {
                                        // Processar o HTML para extrair estilos
                                        var tempDiv = document.createElement('div');
                                        tempDiv.innerHTML = response;
                                        
                                        // Extrair os estilos
                                        var styles = tempDiv.getElementsByTagName('style');
                                        var stylesContent = '';
                                        
                                        for (var i = styles.length - 1; i >= 0; i--) {
                                            stylesContent += styles[i].innerHTML;
                                            styles[i].parentNode.removeChild(styles[i]);
                                        }
                                        
                                        // Adicionar o HTML limpo
                                        $content.html(tempDiv.innerHTML);
                                        
                                        // Adicionar os estilos de volta com escopo
                                        if (stylesContent) {
                                            var uniqueStyleId = "style-" + widgetId;
                                            $('#' + uniqueStyleId).remove();
                                            
                                            var styleElement = document.createElement('style');
                                            styleElement.id = uniqueStyleId;
                                            
                                            // Adicionar escopo ao CSS
                                            var scopedStyles = stylesContent.replace(/([^{}]+)({[^}]*})/g, function(match, selector, rules) {
                                                if (selector.trim().startsWith('@')) {
                                                    return match;
                                                }
                                                
                                                var selectors = selector.split(',');
                                                var scopedSelectors = selectors.map(function(sel) {
                                                    return '#content-' + widgetId + ' ' + sel.trim();
                                                });
                                                
                                                return scopedSelectors.join(', ') + rules;
                                            });
                                            
                                            styleElement.innerHTML = scopedStyles;
                                            document.head.appendChild(styleElement);
                                        }
                                        
                                        // Recarregar dados para o componente
                                        carregarDadosParaComponentes();
                                    },
                                    error: function(xhr, status, error) {
                                        $content.html('<div class="alert alert-danger">Erro ao atualizar: ' + error + '</div>');
                                    }
                                });
                            }
                        } else {
                            $content.html('<div class="alert alert-warning">Tipo de componente não reconhecido</div>');
                        }
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
            }
        });
    </script>
</body>
</html>
