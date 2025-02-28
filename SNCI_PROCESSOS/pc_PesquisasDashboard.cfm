<cfprocessingdirective pageencoding = "utf-8">	
<cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
    SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_pesquisas ORDER BY ano DESC
</cfquery>
<cfquery name="rsOrgaosOrigem" datasource="#application.dsn_processos#">
    SELECT pc_org_mcu, pc_org_sigla
    FROM pc_orgaos 
    WHERE pc_org_status = 'O'
    ORDER BY pc_org_sigla
</cfquery>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Pesquisas</title>
    <link rel="stylesheet" href="plugins/jqcloud/jqcloud.min.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_PesquisasDashboard.css">
    
    <style>
        #tabelaPesquisas th {
            font-size: smaller; /* Reduz o tamanho da fonte dos cabeçalhos */
        }
        
        /* Estilo para os containers de filtro lado a lado */
        .filtros-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 1.5rem;
        }
        
        /* Estilo para loaders de componentes */
        .tab-loader-container {
            min-height: 200px;
            position: relative;
        }
        
        .tab-loader {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            color: #6c757d;
        }
        
        .tab-loader i {
            font-size: 2rem;
            margin-bottom: 10px;
            display: block;
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
                    <h1>Dashboard de Pesquisas</h1>
                </section>

                <section class="content">
                    <div class="container-fluid">
                        <!-- Filtros agrupados em um container -->
                        <div class="filtros-container">
                            <!-- Filtro por ano -->
                            <div class="filtro-ano-container">
                                <div class="filtro-ano-label">Ano do Processo:</div>
                                <div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons">
                                    <!-- Botões gerados via JS -->
                                </div>
                            </div>
                            
                            <!-- Novo filtro por órgão -->
                            <div class="filtro-ano-container">
                                <div class="filtro-ano-label">Órgão de origem:</div>
                                <div id="opcoesMcu" class="btn-group btn-group-toggle" data-toggle="buttons">
                                    <!-- Botões gerados via JS -->
                                </div>
                            </div>
                        </div>

                        <!-- Cards de métricas -->
                        <div class="row">
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-info">
                                    <div class="inner">
                                        <h3 id="totalPesquisas">0</h3>
                                        <p>Total de Pesquisas Respondidas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-file-text"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-primary">
                                    <div class="inner">
                                        <h3 id="indiceRespostas">0%</h3>
                                        <p>Índice de Respostas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-percent"></i>
                                    </div>
                                    <p class="formula-text">
                                        Fórmula: (Total Resp. / Total Proc. Acomp. ou Finaliz.) × 100<br>
                                        <span id="formulaDetalhes"></span>
                                    </p>
                                </div>
                            </div>
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-success">  
                                    <div class="inner">
                                        <h3 id="mediaGeral">0</h3>
                                        <p>Média Geral das Notas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-calculator"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-warning">
                                    <div class="inner">
                                        <h3 id="mediaGeralPontualidade">0</h3>
                                        <p>Pontualidade</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                </div>
                            </div>
                        </div>

                      
                        <!--- Sistema de abas --->
                        <div class="tabs-container">
                          <!--- Navegação das abas --->
                          <ul class="nav nav-dashboard-tabs" id="dashboardTabs" role="tablist">
                            <li class="nav-item">
                              <a class="nav-link active" id="avaliacoes-tab" data-toggle="tab" href="#avaliacoes" role="tab" aria-controls="avaliacoes" aria-selected="true">
                                <i class="fas fa-star"></i>Avaliações (Média das Notas por Pergunta)
                              </a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="graficos-tab" data-toggle="tab" href="#graficos" role="tab" aria-controls="graficos" aria-selected="false">
                                <i class="fas fa-chart-line"></i>Gráficos
                              </a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="nuvem-palavras-tab" data-toggle="tab" href="#nuvem-palavras" role="tab" aria-controls="nuvem-palavras" aria-selected="false">
                                <i class="fas fa-cloud"></i>Nuvem de Palavras
                              </a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="listagem-tab" data-toggle="tab" href="#listagem" role="tab" aria-controls="listagem" aria-selected="false">
                                <i class="fas fa-list"></i>Listagem de Pesquisas
                              </a>
                            </li>
                          </ul>
                          
                          <!--- Controles de navegação para telas pequenas --->
                          <div class="tabs-controls">
                            <div class="tab-control tab-prev">
                              <i class="fas fa-chevron-left"></i>
                            </div>
                            <div class="tab-control tab-next">
                              <i class="fas fa-chevron-right"></i>
                            </div>
                          </div>
                          
                          <!--- Conteúdo das abas - Modificado para carregar via AJAX --->
                          <div class="tab-content dashboard-tab-content" id="dashboardTabsContent">
                            
                            <!--- Aba de Avaliações --->
                            <div class="tab-pane fade show active" id="avaliacoes" role="tabpanel" aria-labelledby="avaliacoes-tab">
                              <div id="avaliacoes-content" class="tab-loader-container">
                                <div class="tab-loader">
                                  <i class="fas fa-spinner fa-spin"></i> Carregando avaliações...
                                </div>
                              </div>
                            </div>
                            
                            <!--- Aba de Gráficos --->
                            <div class="tab-pane fade" id="graficos" role="tabpanel" aria-labelledby="graficos-tab">
                              <div id="graficos-content" class="tab-loader-container">
                                <div class="tab-loader">
                                  <i class="fas fa-spinner fa-spin"></i> Carregando gráficos...
                                </div>
                              </div>
                            </div>
                            
                            <!--- Aba de Nuvem de Palavras --->
                            <div class="tab-pane fade" id="nuvem-palavras" role="tabpanel" aria-labelledby="nuvem-palavras-tab">
                              <div id="nuvem-palavras-content" class="tab-loader-container">
                                <div class="tab-loader">
                                  <i class="fas fa-spinner fa-spin"></i> Carregando nuvem de palavras...
                                </div>
                              </div>
                            </div>
                            
                            <!--- Aba de Listagem de Pesquisas --->
                            <div class="tab-pane fade" id="listagem" role="tabpanel" aria-labelledby="listagem-tab">
                              <div id="listagem-content" class="tab-loader-container">
                                <div class="tab-loader">
                                  <i class="fas fa-spinner fa-spin"></i> Carregando listagem...
                                </div>
                              </div>
                            </div>
                            
                          </div>
                        </div>

                    </div>
                </section>
            </div>

        </div>
        <cfinclude template="includes/pc_footer.cfm">
    </div>
    <cfinclude template="includes/pc_sidebar.cfm">

    <!-- Modal de carregamento -->
    <div class="modal fade" id="modalOverlay" tabindex="-1" role="dialog" aria-hidden="true">
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

    <script src="plugins/chart.js/Chart.min.js"></script>
    <script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
    <script src="plugins/jqcloud/jqcloud.min.js"></script>
    <script>
        $(document).ready(function() {
            // Registrar o plugin globalmente
        window.ChartDataLabels = ChartDataLabels;
        Chart.plugins.unregister(ChartDataLabels);  // Primeiro desregistramos para evitar duplicação
            // Inicializar tooltips com configurações avançadas
            $('[data-toggle="tooltip"]').tooltip({
                container: 'body',
                html: true,
                delay: {show: 100, hide: 100},
                template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
            });
            
            var anos = [];
            var orgaos = [];
            var currentYear = new Date().getFullYear();
            
            // Preencher array com os anos da query rsAnoDashboard
            <cfoutput query="rsAnoDashboard">
                anos.push(parseInt("#rsAnoDashboard.ano#", 10));
            </cfoutput>
            if (anos.indexOf(currentYear) === -1) { anos.push(currentYear); }
            anos = anos.sort(function(a, b){ return a - b; });
            
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
        
            // Configuração do filtro de anos
            var radioName = "opcaoAno";
            $("#opcoesAno").empty();
            
            // Adicionar botão "Todos" antes dos anos específicos
            var btnTodos = `<label class="btn btn-outline-secondary btn-todos">
                            <input type="radio" name="${radioName}" autocomplete="off" value="Todos"/> Todos
                       </label>`;
            $("#opcoesAno").append(btnTodos);
            
            anos.forEach(function(val) {
                var isCurrent = (val === currentYear);
                var btnClass = "btn-outline-primary";
                var checked = isCurrent ? 'checked' : '';
                var btn = `<label class="btn ${btnClass}" style="margin-left:2px;">
                                <input type="radio" name="${radioName}" ${checked} autocomplete="off" value="${val}"/> ${val}
                           </label>`;
                $("#opcoesAno").append(btn);
            });

            // Ativar o botão do ano atual após a geração
            if (currentYear) {
                $(`input[name="${radioName}"][value="${currentYear}"]`).parent().addClass('active');
            }
            
            // Configuração do filtro de órgãos
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
        
            var anoSelecionado = currentYear;
            var mcuSelecionado = "Todos";

            // Função helper para scroll adaptado ao AdminLTE
            window.scrollToElement = function(targetElement, offset) {
                var $scrollContainer = $('.content-wrapper');
                var targetPosition = $(targetElement).offset().top;
                var scrollPosition = targetPosition - $scrollContainer.offset().top + $scrollContainer.scrollTop() - (offset || 70);
                
                $scrollContainer.animate({
                    scrollTop: scrollPosition
                }, 500);
            }

            // Variável para controlar se os componentes já foram carregados
            var componentesCarregados = {
                avaliacoes: false,
                graficos: false,
                nuvemPalavras: false,
                listagem: false
            };

            // Função para carregar os componentes via AJAX
            function carregarComponente(componente) {
                var targetId, targetUrl;
                
                switch(componente) {
                    case 'avaliacoes':
                        targetId = "#avaliacoes-content";
                        targetUrl = "includes/pc_dashbord_pesquisa/pc_dashboard_avaliacoes.cfm";
                        break;
                    case 'graficos':
                        targetId = "#graficos-content";
                        targetUrl = "includes/pc_dashbord_pesquisa/pc_dashboard_graficos.cfm";
                        break;
                    case 'nuvemPalavras':
                        targetId = "#nuvem-palavras-content";
                        targetUrl = "includes/pc_dashbord_pesquisa/pc_dashboard_nuvem_palavras.cfm";
                        break;
                    case 'listagem':
                        targetId = "#listagem-content";
                        targetUrl = "includes/pc_dashbord_pesquisa/pc_dashboard_listagem.cfm";
                        break;
                    default:
                        return;
                }
                
                if (!componentesCarregados[componente]) {
                    $.ajax({
                        url: targetUrl,
                        type: "GET",
                        success: function(data) {
                            $(targetId).html(data);
                            componentesCarregados[componente] = true;
                            
                            // Inicializar o componente após o carregamento
                            switch(componente) {
                                case 'avaliacoes':
                                    // Atualiza os cards de avaliação
                                    $.ajax({
                                        url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                                        method: 'GET',
                                        data: { 
                                            ano: anoSelecionado,
                                            mcuOrigem: mcuSelecionado 
                                        },
                                        dataType: 'json',
                                        success: function(resultado) {
                                            if (resultado && window.atualizarCardsAvaliacao) {
                                                window.atualizarCardsAvaliacao(resultado);
                                            }
                                        }
                                    });
                                    break;
                                case 'graficos':
                                    // Atualiza os gráficos
                                    $.ajax({
                                        url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                                        method: 'GET',
                                        data: { 
                                            ano: anoSelecionado,
                                            mcuOrigem: mcuSelecionado 
                                        },
                                        dataType: 'json',
                                        success: function(resultado) {
                                            if (resultado && window.atualizarGraficos) {
                                                window.atualizarGraficos(resultado);
                                            }
                                        }
                                    });
                                    break;
                                case 'nuvemPalavras':
                                    // Carrega a nuvem de palavras
                                    if (typeof window.carregarNuvemPalavras === 'function') {
                                        setTimeout(function() {
                                            window.carregarNuvemPalavras();
                                        }, 300);
                                    }
                                    break;
                                case 'listagem':
                                    // Carrega a tabela de pesquisas
                                    if (typeof window.carregarDadosTabela === 'function') {
                                        window.carregarDadosTabela(anoSelecionado, mcuSelecionado);
                                    }
                                    break;
                            }
                        },
                        error: function() {
                            $(targetId).html('<div class="alert alert-danger">Erro ao carregar o componente. Por favor, tente novamente.</div>');
                        }
                    });
                } else {
                    // Se o componente já foi carregado, apenas atualiza os dados
                    switch(componente) {
                        case 'avaliacoes':
                            $.ajax({
                                url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                                method: 'GET',
                                data: { 
                                    ano: anoSelecionado,
                                    mcuOrigem: mcuSelecionado 
                                },
                                dataType: 'json',
                                success: function(resultado) {
                                    if (resultado && window.atualizarCardsAvaliacao) {
                                        window.atualizarCardsAvaliacao(resultado);
                                    }
                                }
                            });
                            break;
                        case 'graficos':
                            $.ajax({
                                url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                                method: 'GET',
                                data: { 
                                    ano: anoSelecionado,
                                    mcuOrigem: mcuSelecionado 
                                },
                                dataType: 'json',
                                success: function(resultado) {
                                    if (resultado && window.atualizarGraficos) {
                                        window.atualizarGraficos(resultado);
                                    }
                                }
                            });
                            break;
                        case 'nuvemPalavras':
                            if (typeof window.carregarNuvemPalavras === 'function') {
                                window.carregarNuvemPalavras();
                            }
                            break;
                        case 'listagem':
                            if (typeof window.carregarDadosTabela === 'function') {
                                window.carregarDadosTabela(anoSelecionado, mcuSelecionado);
                            }
                            break;
                    }
                }
            }
        
            function atualizarCards(resultado) {
                // Atualizar totalizadores principais
                $("#totalPesquisas").text(resultado.total || '0');
                $("#mediaGeral").text(resultado.mediaGeral || '0');
                $("#mediaGeralPontualidade").text((resultado.pontualidadePercentual || '0') + "%");
                
                // Lógica corrigida do índice de respostas
                if (parseInt(resultado.totalProcessos) === 0) {
                    $("#indiceRespostas").text("Processos não localizados").addClass('texto-menor');
                    $(".formula-text").hide();
                } else if (parseInt(resultado.total) === 0) {
                    $("#indiceRespostas").text("0%").removeClass('texto-menor');
                    $("#formulaDetalhes").text(`Cálculo: (0 / ${parseInt(resultado.totalProcessos)}) × 100 = 0%`);
                    $(".formula-text").show();
                } else {
                    const totalRespondidas = parseInt(resultado.total) || 0;
                    const totalProcessos = parseInt(resultado.totalProcessos) || 0;
                    const indice = ((totalRespondidas / totalProcessos) * 100).toFixed(1);
                    
                    $("#indiceRespostas").text(indice + "%").removeClass('texto-menor');
                    $("#formulaDetalhes").text(
                        `Cálculo: (${totalRespondidas} / ${totalProcessos}) × 100 = ${indice}%`
                    );
                    $(".formula-text").show();
                }
                
                // Atualizar componentes ativos
                if ($("#avaliacoes").hasClass('active') && window.atualizarCardsAvaliacao) {
                    window.atualizarCardsAvaliacao(resultado);
                }
                
                if ($("#graficos").hasClass('active') && window.atualizarGraficos) {
                    window.atualizarGraficos(resultado);
                }
            }
        
            // Função melhorada para garantir o fechamento do modal
            function fecharModalComSeguranca() {
                try {
                    // Primeiro tenta fechar o modal de maneira convencional
                    $('#modalOverlay').modal('hide');
                    
                    // Espera um pouco e então verifica se o modal realmente fechou
                    setTimeout(function() {
                        // Se o modal ainda estiver visível ou com classes modal-open
                        if ($('#modalOverlay').is(':visible') || $('body').hasClass('modal-open')) {
                          
                            // Remove manualmente as classes e elementos do modal
                            $('.modal-backdrop').remove();
                            $('body').removeClass('modal-open');
                            $('body').css('padding-right', '');
                            $('#modalOverlay').removeClass('show');
                            $('#modalOverlay').css('display', 'none');
                        }
                    }, 500);
                } catch (e) {
                    console.error("Erro ao fechar modal:", e);
                    
                    // Última tentativa para forçar o fechamento
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open');
                    $('#modalOverlay').hide();
                }
            }
        
            function carregarDashboard(anoFiltro, mcuFiltro) {
                // Mostrar modal de carregamento
                try {
                    $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                    $('#modalOverlay').modal('show');
                } catch (e) {
                    console.error("Erro ao mostrar modal:", e);
                }
                
                // Configurar um timeout de segurança para fechar o modal após 30 segundos
                var timeoutSeguranca = setTimeout(function() {
                    fecharModalComSeguranca();
                }, 30000);
                
                // Contador para controlar conclusão das requisições
                var requestsCount = 0;
                var totalRequests = 1; // Inicializa com 1 para a requisição principal
                
                // Função para verificar se todas as requisições terminaram
                function checkAllRequestsComplete() {
                    requestsCount++;
                    if (requestsCount >= totalRequests) {
                        // Todas as requisições terminaram, podemos fechar o modal
                        clearTimeout(timeoutSeguranca);
                        fecharModalComSeguranca();
                    }
                }
                
                // Carregar estatísticas para atualizar os cards principais
                $.ajax({
                    url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                    method: 'GET',
                    data: { 
                        ano: anoFiltro,
                        mcuOrigem: mcuFiltro 
                    },
                    dataType: 'json',
                    success: function(resultado) {
                        if (resultado) {
                            // Atualiza totalizadores e cards
                            atualizarCards(resultado);
                        }
                        // Marca esta requisição como concluída
                        checkAllRequestsComplete();
                    },
                    error: function(xhr, status, error) {
                        console.error("Erro ao carregar estatísticas:", error);
                        // Mesmo com erro, marca como concluída
                        checkAllRequestsComplete();
                    }
                });
                
                // Atualizar o componente atual
                if ($("#avaliacoes").hasClass('active')) {
                    carregarComponente('avaliacoes');
                } else if ($("#graficos").hasClass('active')) {
                    carregarComponente('graficos');
                } else if ($("#nuvem-palavras").hasClass('active')) {
                    carregarComponente('nuvemPalavras');
                } else if ($("#listagem").hasClass('active')) {
                    carregarComponente('listagem');
                }
            }
            
            // Carregar o componente inicial (Avaliações)
            carregarComponente('avaliacoes');
            
            // Carregar o dashboard inicial
            carregarDashboard(anoSelecionado, mcuSelecionado);
            
            // Handler para mudança de ano
            $("input[name='opcaoAno']").change(function() {
                anoSelecionado = $(this).val();
                carregarDashboard(anoSelecionado, mcuSelecionado);
                
                // Disparar evento global de mudança de filtro
                $(document).trigger('filtroAlterado', {
                    tipo: 'ano',
                    valor: anoSelecionado
                });
            });
            
            // Handler para mudança de órgão
            $("input[name='opcaoMcu']").change(function() {
                mcuSelecionado = $(this).val();
                carregarDashboard(anoSelecionado, mcuSelecionado);
                
                // Disparar evento global de mudança de filtro
                $(document).trigger('filtroAlterado', {
                    tipo: 'mcu',
                    valor: mcuSelecionado
                });
            });

            // Script para gerenciar as abas do Dashboard de Pesquisas
            $('.nav-dashboard-tabs .nav-link:first').tab('show');
            
            // Manipular clique nas abas
            $('.nav-dashboard-tabs .nav-link').on('click', function(e) {
                e.preventDefault();
                
                // Armazenar referência para o elemento atual
                var $this = $(this);
                
                // Mostrar a aba
                $this.tab('show');
                
                // Aguardar um momento para a aba ser mostrada antes de rolar
                setTimeout(function() {
                    // Usar a função helper para scroll
                    window.scrollToElement('.tabs-container', 70);
                    
                    // Obter ID da aba para carregar componente correspondente
                    const tabId = $this.attr('href');
                    
                    if (tabId === '#avaliacoes') {
                        carregarComponente('avaliacoes');
                    } else if (tabId === '#graficos') {
                        carregarComponente('graficos');
                        // Forçar redimensionamento para layout correto
                        setTimeout(function() {
                            $(window).trigger('resize');
                        }, 200);
                    } else if (tabId === '#nuvem-palavras') {
                        carregarComponente('nuvemPalavras');
                    } else if (tabId === '#listagem') {
                        carregarComponente('listagem');
                    }
                }, 300);
            });
            
            // Controles de navegação das abas
            $('.tab-prev').on('click', function() {
                scrollTabs(-100);
            });
            
            $('.tab-next').on('click', function() {
                scrollTabs(100);
            });
            
            // Verificar se é necessário mostrar os controles de navegação
            checkTabsOverflow();
            $(window).on('resize', checkTabsOverflow);
            
            // Função para rolar as abas
            function scrollTabs(amount) {
                const $tabs = $('.nav-dashboard-tabs');
                $tabs.animate({
                    scrollLeft: $tabs.scrollLeft() + amount
                }, 300);
            }
            
            // Verificar se há overflow nas abas
            function checkTabsOverflow() {
                const $tabs = $('.nav-dashboard-tabs');
                if ($tabs.length) {
                    const tabsContainer = $tabs[0];
                    const hasOverflow = tabsContainer.scrollWidth > tabsContainer.clientWidth;
                    
                    if (hasOverflow) {
                        $('.tabs-controls').show(); // Corrigido o seletor (removido o ponto extra)
                    } else {
                        $('.tabs-controls').hide(); // Corrigido o seletor (removido o ponto extra)
                    }
                }
            }

        });

    </script>
</body>
</html>
