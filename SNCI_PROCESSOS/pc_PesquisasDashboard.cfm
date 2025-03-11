<cfprocessingdirective pageencoding = "utf-8">	
<!--- Removidas as consultas SQL redundantes que agora são feitas pelo componente de filtros --->

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard Pesquisas de Opinião</title>
    <link rel="stylesheet" href="plugins/jqcloud/jqcloud.min.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_PesquisasDashboard.css">
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
                        <!-- Componente de filtros reutilizável -->
                        <cfmodule template="includes/pc_filtros_componente.cfm"
                            componenteID="filtros-pesquisas"
                            exibirAno="true"
                            exibirOrgao="true"
                            exibirStatus="false">

                        <!-- Incluir o componente de cards de métricas -->
                        <cfinclude template="includes/pc_dashbord_pesquisa/pc_dashboard_cards_metricas.cfm">

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
            Chart.plugins.unregister(ChartDataLabels);
            
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
                
                // Importante: Vamos usar as variáveis globais aqui, que são definidas pelo componente de filtro
                const anoFiltro = window.anoSelecionado || "Todos";
                const mcuFiltro = window.mcuSelecionado || "Todos";
                
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
                            
                            // Inicializar o componente após o carregamento com os valores atuais dos filtros
                            atualizarComponente(componente, anoFiltro, mcuFiltro);
                        },
                        error: function() {
                            $(targetId).html('<div class="alert alert-danger">Erro ao carregar o componente. Por favor, tente novamente.</div>');
                        }
                    });
                } else {
                    // Se o componente já foi carregado, apenas atualiza os dados
                    atualizarComponente(componente, anoFiltro, mcuFiltro);
                }
            }
            
            // Função para atualizar um componente específico
            function atualizarComponente(componente, ano, mcu) {
                switch(componente) {
                    case 'avaliacoes':
                        $.ajax({
                            url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                            method: 'GET',
                            data: { 
                                ano: ano,
                                mcuOrigem: mcu 
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
                                ano: ano,
                                mcuOrigem: mcu 
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
                            window.carregarNuvemPalavras(ano, mcu);
                        }
                        break;
                    case 'listagem':
                        if (typeof window.carregarDadosTabela === 'function') {
                            window.carregarDadosTabela(ano, mcu);
                        }
                        break;
                }
            }
        
            function atualizarCards(resultado) {
                // Se o componente de métricas estiver carregado, utiliza a função do componente
                if (typeof window.atualizarCards === 'function') {
                    window.atualizarCards(resultado);
                }
                
                // Atualizar componentes ativos
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
        
            // Função principal para carregar o dashboard
            function carregarDashboard() {
                // Usar diretamente as variáveis globais definidas pelo componente de filtros
                const anoFiltro = window.anoSelecionado || "Todos";
                const mcuFiltro = window.mcuSelecionado || "Todos";
                
                console.log(`carregarDashboard executando com filtros: ano=${anoFiltro}, mcu=${mcuFiltro}`);
                
                // Mostrar modal de carregamento
                try {
                    $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                    $('#modalOverlay').modal('show');
                } catch (e) {
                    console.error("Erro ao mostrar modal:", e);
                }
                
                // Timeout de segurança para fechar o modal após 30 segundos
                var timeoutSeguranca = setTimeout(function() {
                    fecharModalComSeguranca();
                }, 30000);
                
                // Atualizar os cards principais
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
                            atualizarCards(resultado);
                        }
                        
                        // Carregar ou atualizar os componentes
                        if (!componentesCarregados['avaliacoes']) {
                            carregarComponente('avaliacoes');
                        } else {
                            atualizarComponente('avaliacoes', anoFiltro, mcuFiltro);
                        }
                        
                        if (!componentesCarregados['graficos']) {
                            carregarComponente('graficos');
                        } else {
                            atualizarComponente('graficos', anoFiltro, mcuFiltro);
                        }
                        
                        // Atualizar apenas o componente da aba ativa
                        if ($("#nuvem-palavras").hasClass('active')) {
                            console.log("Aba nuvem-palavras está ativa, atualizando com:", anoFiltro, mcuFiltro);
                            if (!componentesCarregados['nuvemPalavras']) {
                                carregarComponente('nuvemPalavras');
                            } else {
                                atualizarComponente('nuvemPalavras', anoFiltro, mcuFiltro);
                            }
                        } else if ($("#listagem").hasClass('active')) {
                            if (!componentesCarregados['listagem']) {
                                carregarComponente('listagem');
                            } else {
                                atualizarComponente('listagem', anoFiltro, mcuFiltro);
                            }
                        }
                        
                        // Limpar o timeout e fechar o modal
                        clearTimeout(timeoutSeguranca);
                        setTimeout(function() {
                            fecharModalComSeguranca();
                        }, 1000);
                    },
                    error: function(xhr, status, error) {
                        console.error("Erro ao carregar estatísticas:", error);
                        fecharModalComSeguranca();
                        
                        // Exibir mensagem de erro na interface
                        alert("Erro ao carregar dados: " + error);
                    }
                });
            }
            
            // NOVO: Escutar o evento de alteração de filtro emitido pelo componente
            document.addEventListener('filtroAlterado', function(e) {
                const { tipo, valor } = e.detail;
                console.log(`PesquisasDashboard: Filtro alterado: ${tipo} = ${valor}`);
                console.log("Estado atual dos filtros:", {
                    ano: window.anoSelecionado,
                    mcu: window.mcuSelecionado
                });
                
                // Atualizar o dashboard com os novos filtros após um pequeno delay
                // para garantir que as variáveis globais estejam corretamente atualizadas
                setTimeout(carregarDashboard, 100);
            });
            
            // Carregar dados iniciais após um pequeno delay para garantir que os filtros estejam inicializados
            setTimeout(function() {
              
                carregarDashboard();
            }, 500);

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