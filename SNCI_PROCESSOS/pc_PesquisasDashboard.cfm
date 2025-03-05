<cfprocessingdirective pageencoding = "utf-8">	
<cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
    SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_processos 
    WHERE pc_num_status IN(4,5) and RIGHT(pc_processo_id, 4) >= '#application.anoPesquisaOpiniao#'
    <cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
        AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
    </cfif>
    ORDER BY ano 
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
    <title>Dashboard Pesquisas de Opinião</title>
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
        
        /* Novos estilos para expansão correta do conteúdo das abas */
        .dashboard-tab-content {
            min-height: 300px;
            height: auto !important;
            overflow: visible !important;
            width: 100%;
        }
        
        .dashboard-tab-content .tab-pane {
            height: auto !important;
            overflow: visible !important;
            display: none;
        }
        
        .dashboard-tab-content .tab-pane.active {
            display: block;
        }
        
        .tab-content > .tab-pane {
            padding: 15px 0;
        }
        
        /* Garantir que o contêiner principal não restrinja a altura */
        .tabs-container {
            height: auto !important;
            overflow: visible !important;
        }
        
        .tab-loader-container {
            min-height: 200px;
            height: auto !important;
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
                    <h1>Dashboard Pesquisas de Opinião</h1>
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
                            
                            <!-- Filtro por órgão - exibido conforme perfil do usuário -->
                            <cfif mostrarFiltroOrgao>
                                <div class="filtro-ano-container">
                                    <div class="filtro-ano-label">Órgão de origem:</div>
                                    <div id="opcoesMcu" class="btn-group btn-group-toggle" data-toggle="buttons">
                                        <!-- Botões gerados via JS -->
                                    </div>
                                </div>
                            </cfif>
                        </div>

                        <!-- Cards de métricas - Todos na mesma linha com 5 cards -->
                        <div class="row">
                            <div class="col-lg col-md-6 col-12">
                                <div class="small-box bg-info">
                                    <div class="inner">
                                        <h3 id="totalPesquisas">0</h3>
                                        <p>Pesquisas Respondidas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-file-text"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg col-md-6 col-12">
                                <div class="small-box bg-primary">
                                    <div class="inner">
                                        <h3 id="indiceRespostas">0%</h3>
                                        <p>Índice de Respostas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-percent"></i>
                                    </div>
                                    <p class="formula-text">
                                        (Total Resp. / Total Proc.) × 100<br>
                                        <span id="formulaDetalhes"></span>
                                    </p>
                                </div>
                            </div>
                            <div class="col-lg col-md-6 col-12">
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
                            <div class="col-lg col-md-6 col-12">
                                <!-- Card do NPS com estrutura melhorada -->
                                <div class="small-box bg-azul-navy">  
                                    <div class="inner">
                                        <div class="nps-value-container">
                                            <h3 id="npsValorContainer">0</h3>
                                            <div id="npsClassificacao" class="nps-classification-badge">(-)</div>
                                        </div>
                                        <p style="top: 10px;position: relative;">
                                            NPS
                                            <i class="fas fa-info-circle ml-1 nps-info-icon" 
                                               data-toggle="popover" 
                                               data-placement="auto" 
                                               data-trigger="hover" 
                                               title="<i class='fas fa-chart-line mr-2'></i>O que é o NPS?" 
                                               data-content="<div class='text-justify'><p>O <strong>Net Promoter Score (NPS)</strong> mede a satisfação e lealdade dos clientes em uma escala de -100 a +100.</p><p><strong>Cálculo:</strong> (% Promotores - % Detratores)</p><p><strong>Classificação dos clientes:</strong><br>• <span class='badge badge-success'>Promotores</span>: notas 9-10<br>• <span class='badge badge-warning'>Neutros</span>: notas 7-8<br>• <span class='badge badge-danger'>Detratores</span>: notas 0-6</p><p><strong>Interpretação:</strong><br>• <span class='text-danger'>Ruim</span>: menor que 0<br>• <span class='text-warning'>Regular</span>: 0 a 50<br>• <span class='text-info'>Bom</span>: 50 a 70<br>• <span class='text-success'>Excelente</span>: acima de 70</p></div>"></i>
                                        </p>
                                        <p id="npsDetalhes" class="formula-text" style="left:0px;top:6px;position: relative;">
                                            Promotores: 0 | Neutros: 0 | Detratores: 0
                                        </p>
                                    </div>
                                    <div class="icon" id="npsIcon">
                                        <i class="fas fa-meh"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg col-md-6 col-12">
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

                        <!-- Removi a div row do card de Pontualidade pois agora está integrado acima -->
                        
                        <!--- Card novo para Média das Notas por Categoria --->
                        <div class="card mb-4" id="card-avaliacoes">
                            <div class="card-header">
                                <h3 class="card-title">
                                    <i class="fas fa-star mr-2"></i>Média das Notas por Categoria
                                </h3>
                            </div>
                            <div class="card-body">
                                <div id="avaliacoes-content" class="tab-loader-container">
                                    <div class="tab-loader">
                                      <i class="fas fa-spinner fa-spin"></i> Carregando avaliações...
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!--- Card para Gráficos --->
                        <div class="card mb-4" id="card-graficos">
                            <div class="card-header">
                                <h3 class="card-title">
                                    <i class="fas fa-chart-line mr-2"></i>Gráficos
                                </h3>
                            </div>
                            <div class="card-body">
                                <div id="graficos-content" class="tab-loader-container">
                                    <div class="tab-loader">
                                      <i class="fas fa-spinner fa-spin"></i> Carregando gráficos...
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!--- Sistema de abas --->
                        <div class="tabs-container">
                          <!--- Navegação das abas --->
                          <ul class="nav nav-dashboard-tabs" id="dashboardTabs" role="tablist">
                            <!--- Removida a aba de gráficos também --->
                            <li class="nav-item">
                              <a class="nav-link active" id="nuvem-palavras-tab" data-toggle="tab" href="#nuvem-palavras" role="tab" aria-controls="nuvem-palavras" aria-selected="true">
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
                            
                            <!--- Aba de Nuvem de Palavras (agora é a primeira aba) --->
                            <div class="tab-pane fade show active" id="nuvem-palavras" role="tabpanel" aria-labelledby="nuvem-palavras-tab">
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

    <!-- Modal de carregamento - Corrigido para acessibilidade -->
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

    <script src="plugins/chart.js/Chart.min.js"></script>
    <script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
    <script src="plugins/jqcloud/jqcloud.min.js"></script>
    <script>
        $(document).ready(function() {
            // Registrar o plugin globalmente
            window.ChartDataLabels = ChartDataLabels;
            Chart.plugins.unregister(ChartDataLabels);  // Primeiro desregistramos para evitar duplicação
            
            // Inicializar tooltips e popovers com configurações avançadas
            $('[data-toggle="tooltip"]').tooltip({
                container: 'body',
                html: true,
                delay: {show: 100, hide: 100},
                template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
            });
            
            // Inicializar popovers para ícones de informação com configurações aprimoradas para funcionar com zoom
            $('[data-toggle="popover"]').popover({
                container: 'body',
                html: true,
                trigger: 'hover',
                boundary: 'window',
                fallbackPlacement: ['left', 'right', 'bottom', 'top'],
                template: '<div class="popover" role="tooltip"><div class="arrow"></div><div class="popover-header"></div><div class="popover-body"></div></div>',
                sanitize: false
            });
            
            // Função para classificar o NPS baseado no valor atualizado com nova escala
            function classificarNPS(valor) {
                // Converter para número para garantir comparação correta
                const nps = parseFloat(valor);
                
                if (nps > 70) {
                    return {
                        texto: "Excelente",
                        classe: "nps-excelente"
                    };
                } else if (nps >= 50) {
                    return {
                        texto: "Bom",
                        classe: "nps-bom"
                    };
                } else if (nps >= 0) {
                    return {
                        texto: "Regular",
                        classe: "nps-regular"
                    };
                } else {
                    return {
                        texto: "Ruim",
                        classe: "nps-ruim"
                    };
                }
            }
            
            var anos = [];
            var orgaos = [];
            var currentYear = new Date().getFullYear();
            
            // Preencher array com os anos da query rsAnoDashboard
            <cfoutput query="rsAnoDashboard">
                anos.push(parseInt("#rsAnoDashboard.ano#", 10));
            </cfoutput>
            
            // Ordena os anos em ordem crescente
            anos = anos.sort(function(a, b){ return a - b; }); // Ordem crescente
            
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
            
            // Tornar a variável mcuSelecionado disponível globalmente
            window.mcuSelecionado = mcuSelecionado;
        
            // Função helper para scroll adaptado ao AdminLTE
            window.scrollToElement = function(targetElement, offset) {
                var $scrollContainer = $('.content-wrapper');
                var targetPosition = $(targetElement).offset().top;
                var scrollPosition = targetPosition - $scrollContainer.offset().top + $scrollContainer.scrollTop() - (offset || 70);
                
                $scrollContainer.animate({
                    scrollTop: scrollPosition
                }, 500);
            };

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
                                            window.carregarNuvemPalavras(anoSelecionado, mcuSelecionado);
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
                                window.carregarNuvemPalavras(anoSelecionado, mcuSelecionado);
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
                    $("#formulaDetalhes").text(`(0 / ${parseInt(resultado.totalProcessos)}) × 100 = 0%`);
                    $(".formula-text").show();
                } else {
                    const totalRespondidas = parseInt(resultado.total) || 0;
                    const totalProcessos = parseInt(resultado.totalProcessos) || 0;
                    const indice = ((totalRespondidas / totalProcessos) * 100).toFixed(1);
                    
                    $("#indiceRespostas").text(indice + "%").removeClass('texto-menor');
                    $("#formulaDetalhes").text(
                        `(${totalRespondidas} / ${totalProcessos}) × 100 = ${indice}%`
                    );
                    $(".formula-text").show();
                }
                
                // Atualizar o NPS se disponível
                if (resultado.nps !== undefined) {
                    const npsValor = resultado.nps;
                    
                    // Classificar o NPS
                    const classificacao = classificarNPS(npsValor);
                    
                    // Atualiza o valor do NPS
                    $("#npsValorContainer").text(npsValor);
                    
                    // Atualiza a classificação com o novo elemento badge, aplicando estilos inline
                    $("#npsClassificacao")
                        .text(classificacao.texto)
                        .removeClass()
                        .addClass('nps-classification-badge')
                        .css({
                            'display': 'inline-block',
                            'padding': '3px 10px',
                            'border-radius': '12px',
                            'font-weight': '600',
                            'font-size': '14px'
                        });
                        
                    // Aplicar cores baseadas na classificação
                    if (classificacao.classe === "nps-excelente") {
                        $("#npsClassificacao").css('background-color', '#28a745').css('color', 'white');
                        // Atualiza o ícone para um sorriso amplo
                        $("#npsIcon i").removeClass().addClass('fas fa-grin-stars');
                    } else if (classificacao.classe === "nps-bom") {
                        $("#npsClassificacao").css('background-color', '#17a2b8').css('color', 'white');
                        // Atualiza o ícone para um sorriso
                        $("#npsIcon i").removeClass().addClass('fas fa-smile');
                    } else if (classificacao.classe === "nps-regular") {
                        $("#npsClassificacao").css('background-color', '#ffc107').css('color', '#343a40');
                        // Atualiza o ícone para um rosto neutro
                        $("#npsIcon i").removeClass().addClass('fas fa-meh');
                    } else {
                        $("#npsClassificacao").css('background-color', '#dc3545').css('color', 'white');
                        // Atualiza o ícone para um rosto triste
                        $("#npsIcon i").removeClass().addClass('fas fa-frown');
                    }
                    
                    // Atualizar detalhes do NPS com formato simplificado
                    if (resultado.npsDetalhes) {
                        const { promotores, neutros, detratores } = resultado.npsDetalhes;
                        $("#npsDetalhes").text(`Promotores: ${promotores} | Neutros: ${neutros} | Detratores: ${detratores}`);
                    }
                }
                
                // Atualizar componentes ativos
                // Sempre atualiza o componente de avaliações e gráficos pois agora são cards fixos
                if (window.atualizarCardsAvaliacao) {
                    window.atualizarCardsAvaliacao(resultado);
                }
                
                if (window.atualizarGraficos) {
                    window.atualizarGraficos(resultado);
                }
            }
        
            // Função melhorada para garantir o fechamento do modal
            function fecharModalComSeguranca() {
                try {
                    // Mover o foco para um elemento externo para evitar o problema de acessibilidade
                    document.querySelector('.content-header h1').focus();
                    
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
                            
                            // Remover aria-hidden explicitamente para evitar o problema de acessibilidade
                            $('#modalOverlay').removeAttr('aria-hidden');
                        }
                    }, 500);
                } catch (e) {
                    console.error("Erro ao fechar modal:", e);
                    
                    // Última tentativa para forçar o fechamento
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open');
                    $('#modalOverlay').hide();
                    $('#modalOverlay').removeAttr('aria-hidden');
                    
                    // Garantir que o foco vá para um elemento acessível
                    document.querySelector('.content-header h1').focus();
                }
            }
        
            function carregarDashboard(anoFiltro, mcuFiltro) {
                // Certificar que mcuFiltro não é undefined ou null
                if (mcuFiltro === undefined || mcuFiltro === null) {
                    console.warn("mcuFiltro não definido em carregarDashboard, usando valor padrão", mcuSelecionado);
                    mcuFiltro = mcuSelecionado;
                }

                              
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
                // Sempre carrega o componente de avaliações
                if (!componentesCarregados['avaliacoes']) {
                    carregarComponente('avaliacoes');
                }
                
                if (!componentesCarregados['graficos']) {
                    carregarComponente('graficos');
                }
                
                if ($("#nuvem-palavras").hasClass('active')) {
                    carregarComponente('nuvemPalavras');
                } else if ($("#listagem").hasClass('active')) {
                    carregarComponente('listagem');
                }
                
                // Atualizar a variável global
                window.mcuSelecionado = mcuFiltro;
            }
            
            // Carregar o card de avaliações diretamente (fora do sistema de abas)
            carregarComponente('avaliacoes');
            
            // Também carregar o card de gráficos diretamente
            carregarComponente('graficos');
            
            // Carregar o dashboard inicial com o card de avaliações
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
            
            <cfif mostrarFiltroOrgao>
                // Handler para mudança de órgão (apenas se o filtro estiver visível)
                $("input[name='opcaoMcu']").change(function() {
                    mcuSelecionado = $(this).val();
                    carregarDashboard(anoSelecionado, mcuSelecionado);
                    
                    // Disparar evento global de mudança de filtro
                    $(document).trigger('filtroAlterado', {
                        tipo: 'mcu',
                        valor: mcuSelecionado
                    });
                });
            </cfif>

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
                    
                    if (tabId === '#nuvem-palavras') {
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
                        $('.tabs-controls').show();
                    } else {
                        $('.tabs-controls').hide();
                    }
                }
            }
        });
    </script>
    
    <!-- Script para o botão de voltar ao topo -->
    <script>
        $(document).ready(function() {
            // Controle do botão de voltar ao topo
            var $scrollTopBtn = $('#scrollTopBtn');
            var $contentWrapper = $('.content-wrapper');
            
            // Inicialmente esconde o botão
            $scrollTopBtn.hide();
            
            // Mostra/esconde o botão baseado na posição de rolagem
            $contentWrapper.scroll(function() {
                if ($contentWrapper.scrollTop() > 300) {
                    $scrollTopBtn.fadeIn();
                } else {
                    $scrollTopBtn.fadeOut();
                }
            });
            
            // Ação de clique para rolar para o topo
            $scrollTopBtn.click(function() {
                $contentWrapper.animate({
                    scrollTop: 0
                }, 800);
                return false;
            });
        });
    </script>
</body>
</html>
