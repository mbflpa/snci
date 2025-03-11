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
<cfquery name="rsStatusProcessos" datasource="#application.dsn_processos#">
    SELECT pc_status_id, pc_status_descricao
    FROM pc_status
    ORDER BY pc_status_descricao
</cfquery>

<cfset mostrarFiltroOrgao = application.rsUsuarioParametros.pc_usu_perfil neq 8>
<cfif NOT mostrarFiltroOrgao AND rsOrgaosOrigem.recordCount GT 0>
    <cfset orgaoOrigemSelecionado = rsOrgaosOrigem.pc_org_mcu>
</cfif>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Processos</title>
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard.css">
 
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
    </style>
    
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

                            <!-- Filtro por status - removido o style inline redundante -->
                            <div class="filtro-container filtro-compacto">
                                <div class="filtro-label">Status:</div>
                                <div id="opcoesStatus" class="btn-group btn-group-toggle btn-group-sm" data-toggle="buttons">
                                    <!-- Botões gerados via JS -->
                                </div>
                            </div>
                        </div>

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
            
            var anos = [];
            var orgaos = [];
            var statusProcessos = [];
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
            
            // Preencher array com os status da query rsStatusProcessos
            <cfset linhaStatus = 0>
            
            var statusProcessos = [];
            <cfoutput query="rsStatusProcessos">
                <cfset linhaStatus = linhaStatus + 1>
                statusProcessos.push({
                    id: "#JSStringFormat(rsStatusProcessos.pc_status_id)#",
                    descricao: "#JSStringFormat(rsStatusProcessos.pc_status_descricao)#"
                });
            </cfoutput>
            
            // Configuração do filtro de status
            var radioStatus = "opcaoStatus";
            $("#opcoesStatus").empty();
            
            // Adicionar botão "Todos" para os status
            var btnTodosStatus = `<label class="btn btn-outline-secondary btn-todos">
                            <input type="radio" name="${radioStatus}" checked autocomplete="off" value="Todos"/> Todos
                       </label>`;
            $("#opcoesStatus").append(btnTodosStatus);
            
            // Adicionar botões para cada status
            if (statusProcessos.length > 0) {
                statusProcessos.forEach(function(status) {
                    var btn = `<label class="btn btn-outline-info" style="margin-left:2px;">
                                    <input type="radio" name="${radioStatus}" autocomplete="off" value="${status.id}"/> ${status.descricao}
                               </label>`;
                    $("#opcoesStatus").append(btn);
                });
            } else {
                // Recuperar status via AJAX se necessário
                $.ajax({
                    url: 'cfc/pc_cfcProcessosDashboard.cfc?method=getStatusProcessos',
                    method: 'GET',
                    dataType: 'json',
                    success: function(response) {
                        if (response && response.length > 0) {
                            response.forEach(function(status) {
                                var btn = `<label class="btn btn-outline-info" style="margin-left:2px;">
                                    <input type="radio" name="${radioStatus}" autocomplete="off" value="${status.id}"/> ${status.descricao}
                                </label>`;
                                $("#opcoesStatus").append(btn);
                            });
                        } else {
                            $("#opcoesStatus").append('<span class="ml-2 text-danger">Erro ao carregar status</span>');
                        }
                    },
                    error: function() {
                        $("#opcoesStatus").append('<span class="ml-2 text-danger">Erro ao carregar status</span>');
                    }
                });
            }
            
            // Ativar o botão "Todos" para status inicialmente
            $(`input[name='opcaoStatus'][value='Todos']`).parent().addClass('active');
            var statusSelecionado = "Todos";
            
            // Tornar as variáveis disponíveis globalmente
            window.mcuSelecionado = mcuSelecionado;
            window.statusSelecionado = statusSelecionado;
            window.anoSelecionado = anoSelecionado; // Adicionar essa linha para tornar o ano selecionado disponível globalmente
        
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
        
            // Função simplificada para carregar dados da dashboard
            function carregarDados() {
                // Mostrar modal de carregamento
                $('#modalOverlay').modal({backdrop: 'static', keyboard: false});
                $('#modalOverlay').modal('show');
                
                // Timeout de segurança para fechar o modal após 30 segundos
                var timeoutSeguranca = setTimeout(function() {
                    console.warn("Timeout de segurança acionado após 30 segundos");
                    fecharModalComSeguranca();
                }, 30000);
                
                // Fazer uma única chamada AJAX para obter todos os dados
                $.ajax({
                    url: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
                    method: 'POST',
                    data: { 
                        ano: anoSelecionado,
                        mcuOrigem: mcuSelecionado,
                        statusFiltro: statusSelecionado
                    },
                    dataType: 'json',
                    success: function(dados) {
                        console.log("Dados recebidos com sucesso:", dados);
                        
                        // Armazenar dados para uso global
                        window.dadosAtuais = dados;
                        
                        // Garantir que o componente de órgãos seja atualizado especificamente
                        if (window.atualizarViewOrgaos && typeof window.atualizarViewOrgaos === 'function') {
                            console.log("Atualizando componente de órgãos explicitamente");
                            try {
                                window.atualizarViewOrgaos(dados);
                            } catch(e) {
                                console.error("Erro ao atualizar componente de órgãos:", e);
                            }
                        }
                        
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
                        
                        // Fechar modal após um breve delay para garantir que todos os componentes foram atualizados
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

            // Carregar dados iniciais
            carregarDados();
            
            // Handler para mudança de ano
            $("input[name='opcaoAno']").change(function() {
                anoSelecionado = $(this).val();
                window.anoSelecionado = anoSelecionado;
                carregarDados();
            });
            
            <cfif mostrarFiltroOrgao>
                // Handler para mudança de órgão (apenas se o filtro estiver visível)
                $("input[name='opcaoMcu']").change(function() {
                    mcuSelecionado = $(this).val();
                    window.mcuSelecionado = mcuSelecionado;
                    carregarDados();
                });
            </cfif>

            // Handler para mudança de status
            $("input[name='opcaoStatus']").change(function() {
                statusSelecionado = $(this).val();
                window.statusSelecionado = statusSelecionado;
                carregarDados();
            });
        });
    </script>
</body>
</html>
