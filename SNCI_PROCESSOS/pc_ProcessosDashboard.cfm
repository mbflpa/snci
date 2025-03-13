<cfprocessingdirective pageencoding = "utf-8">	

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Processos</title>
    <!-- Carregamento dos estilos -->
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard.css">
    
    <!-- Carregamento do componente base -->
    <script src="dist/js/snciDashboardComponent.js"></script>
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
                    <h1>Dashboard de Processos</h1>
                </section>

                <section class="content">
                    <div class="container-fluid">
                        <!-- Novo componente de filtros -->
                        <cfmodule template="includes/pc_filtros_componente.cfm"
                            componenteID="filtros-dashboard"
                            exibirAno="true"
                            exibirOrgao="true"
                            exibirStatus="true">

                        <!-- Incluir componentes diretos sem cards adicionais -->
                        <cfinclude template="includes/pc_dashboard_processo/pc_dashboard_cards_metricas_processo.cfm">
                        <cfinclude template="includes/pc_dashboard_processo/pc_dashboard_distribuicao_status.cfm">
                        
                        <!-- Estrutura de grid para colocar tipos de processo e classificação lado a lado -->
                        <div class="row">
                            <div class="col-md-5">
                                <cfinclude template="includes/pc_dashboard_processo/pc_dashboard_tipos_processo.cfm">
                            </div>
                            
                            <div class="col-md-4">
                                <cfinclude template="includes/pc_dashboard_processo/pc_dashboard_orgaos_processo.cfm">
                            </div>

                            <div class="col-md-3">
                                <cfinclude template="includes/pc_dashboard_processo/pc_dashboard_classificacao_processo.cfm">
                            </div>
                        </div>

                        <!-- Incluir componentes de gráficos e órgãos avaliados diretamente -->
                        <cfinclude template="includes/pc_dashboard_processo/pc_dashboard_graficos_processo.cfm">

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

    <script>
        $(document).ready(function() {
            // Configurações globais para a dashboard
            const CONFIG = {
                // URL centralizada para carregamento de dados - pode ser alterada facilmente aqui
                dataUrl: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
                dataMethod: 'POST',
                defaultTimeout: 30000 // 30 segundos
            };
            
            // Inicializar o array global para armazenar callbacks de componentes (mantido para compatibilidade)
            window.atualizarDadosComponentes = [];
            
            // Inicializar tooltips e popovers com configurações avançadas
            $('[data-toggle="tooltip"]').tooltip({
                container: 'body',
                html: true,
                delay: {show: 100, hide: 100},
                template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
            });
            
            // Inicializar popovers para ícones de informação
            $('[data-toggle="popover"]').popover({
                container: 'body',
                html: true,
                trigger: 'hover',
                boundary: 'window',
                fallbackPlacement: ['left', 'right', 'bottom', 'top'],
                template: '<div class="popover" role="tooltip"><div class="arrow"></div><div class="popover-header"></div><div class="popover-body"></div></div>',
                sanitize: false
            });
            
            // Variáveis de anos iniciais/finais
            var anosDisponiveis = [];
            var anoInicial = '';
            var anoFinal = '';
            
            // Função helper para scroll adaptado ao AdminLTE
            window.scrollToElement = function(targetElement, offset) {
                var $scrollContainer = $('.content-wrapper');
                var targetPosition = $(targetElement).offset().top;
                var scrollPosition = targetPosition - $scrollContainer.offset().top + $scrollContainer.scrollTop() - (offset || 70);
                
                $scrollContainer.animate({
                    scrollTop: scrollPosition
                }, 500);
            };

            // Estrutura simplificada para armazenar dados
            window.dadosAtuais = null;
            
            // Inicializar estrutura de componentes carregados (necessária para alguns componentes)
            if (typeof window.componentesCarregados === 'undefined') {
                window.componentesCarregados = {};
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
                        if ($('#modalOverlay').is(':visible') || $('body').hasClass('modal-open')) {
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
        
            /**
             * Função simplificada para carregar dados da dashboard
             * Utiliza o DashboardComponentFactory para fazer uma solicitação AJAX genérica
             * Os dados são então distribuídos para todos os componentes registrados
             */
            function carregarDados() {
                // Mostrar modal de carregamento
                $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                $('#modalOverlay').modal('show');
                
                // Timeout de segurança para fechar o modal após 30 segundos
                var timeoutSeguranca = setTimeout(function() {
                    console.warn("Timeout de segurança acionado após 30 segundos");
                    fecharModalComSeguranca();
                }, CONFIG.defaultTimeout);
                
                // Preparar os parâmetros para a requisição
                const params = { 
                    ano: window.anoSelecionado || 'Todos',
                    mcuOrigem: window.mcuSelecionado || 'Todos',
                    statusFiltro: window.statusSelecionado || 'Todos'
                };
                
                // Utilizar o método carregarDependencia para fazer a requisição AJAX
                // Isso permite que usemos a infraestrutura já criada no DashboardComponentFactory
                if (typeof DashboardComponentFactory !== 'undefined') {
                    // Criar um componente auxiliar temporário apenas para carregar os dados
                    const loaderComponent = DashboardComponentFactory.criar({
                        nome: 'DashboardLoader',
                        dataUrl: CONFIG.dataUrl,
                        dataMethod: CONFIG.dataMethod
                    });
                    
                    loaderComponent.carregarDados(params, function(error, dados) {
                        // Limpar o timeout de segurança
                        clearTimeout(timeoutSeguranca);
                        
                        if (error) {
                            console.error("Erro ao carregar dados:", error);
                            fecharModalComSeguranca();
                            alert("Erro ao carregar dados: " + error);
                            return;
                        }
                        
                        // Armazenar dados para uso global
                        window.dadosAtuais = dados;
                        
                        // Chamar explicitamente as funções de atualização para cada componente
                        if (Array.isArray(window.atualizarDadosComponentes)) {
                            window.atualizarDadosComponentes.forEach(function(callback) {
                                if (typeof callback === 'function') {
                                    try {
                                        callback(dados);
                                    } catch(e) {
                                        console.error("Erro ao chamar função de atualização:", e);
                                    }
                                }
                            });
                        }
                        
                        // Fechar modal após um breve delay para garantir que todos os componentes foram atualizados
                        setTimeout(function() {
                            fecharModalComSeguranca();
                        }, 1000);
                    });
                } else {
                    // Fallback para o método AJAX tradicional caso o DashboardComponentFactory não esteja disponível
                    $.ajax({
                        url: CONFIG.dataUrl,
                        method: CONFIG.dataMethod,
                        data: params,
                        dataType: 'json',
                        success: function(dados) {
                            // Armazenar dados para uso global
                            window.dadosAtuais = dados;
                            
                            // Chamar explicitamente as funções de atualização para cada componente
                            if (Array.isArray(window.atualizarDadosComponentes)) {
                                window.atualizarDadosComponentes.forEach(function(callback) {
                                    if (typeof callback === 'function') {
                                        try {
                                            callback(dados);
                                        } catch(e) {
                                            console.error("Erro ao chamar função de atualização:", e);
                                        }
                                    }
                                });
                            }
                            
                            // Limpar o timeout de segurança
                            clearTimeout(timeoutSeguranca);
                            
                            // Fechar modal após um breve delay 
                            setTimeout(function() {
                                fecharModalComSeguranca();
                            }, 1000);
                        },
                        error: function(xhr, status, error) {
                            console.error("Erro ao carregar dados:", error);
                            fecharModalComSeguranca();
                            
                            // Exibir mensagem de erro na interface
                            alert("Erro ao carregar dados: " + error);
                        }
                    });
                }
            }

            // Escutar o evento do componente de filtros
            document.addEventListener('filtroAlterado', function(e) {
                const { tipo, valor } = e.detail;
                
                // Recarregar dados quando qualquer filtro mudar
                carregarDados();
            });
            
            // Carregar dados iniciais após um pequeno delay para garantir que os filtros estejam inicializados
            setTimeout(carregarDados, 300);
        });
    </script>
</body>
</html>
