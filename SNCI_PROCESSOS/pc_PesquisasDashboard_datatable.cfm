<cfprocessingdirective pageencoding = "utf-8">	

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">	
    <link rel="stylesheet" href="plugins/jqcloud/jqcloud.min.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">   
    <style>
			textarea {
				text-align: justify!important;
			}
			.card-body{
				text-align: justify!important;
			}
			.swal2-label{
				text-align:justify;
			}
            /* Estilo para o novo filtro "Outros" */
            .filtro-outros {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 6px 12px;
                background-color: #f8f9fa;
                border-radius: 4px;
                border: 1px solid #dee2e6;
                transition: all 0.2s ease;
                position: absolute; /* Define a posição como absoluta */
                left: 589px;
                top: 58px;
            }
            .filtro-outros:hover {
                background-color: #e9ecef;
                border-color: #ced4da;
            }
            .filtro-outros i {
                cursor: pointer;
                transition: transform 0.3s, color 0.3s;
                font-size: 1.2rem;
            }
            
            /* Estilo para a mensagem de filtro ativo */
            .filtro-ativo-mensagem {
                background-color: #e8f4fe;
                border: 1px solid #b8daff;
                color: #004085;
                padding: 8px 15px;
                border-radius: 4px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px;
                animation: slideDown 0.3s ease-in-out;
            }
            
            #btn-limpar-filtros {
                font-size: 0.9rem;
                padding: 4px 12px;
                transition: all 0.2s ease;
                white-space: nowrap;
                background-color: #dc3545;
                border-color: #dc3545;
            }
            
            #btn-limpar-filtros:hover {
                background-color: #c82333;
                border-color: #bd2130;
                transform: translateY(-1px);
            }
            
            @keyframes slideDown {
                from {
                    transform: translateY(-10px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }
            
            @media (max-width: 768px) {
               
                
                .filtro-ativo-mensagem {
                    flex-direction: column;
                    text-align: center;
                    padding: 10px;
                }
                
                #btn-limpar-filtros {
                    width: 100%;
                    margin-top: 5px;
                }
                
                .filtro-outros {
                    width: 100%;
                    justify-content: center;
                }
            }
            
            
            
             /* Estilos para as classificações dos órgãos */
            .classificacao-promotor {
                background-color: #28a745;
                color: white;
                font-weight: bold;
                padding: 3px 8px;
                border-radius: 12px;
                display: inline-block;
            }
            
            .classificacao-neutro {
                background-color: #ffc107;
                color: #343a40;
                font-weight: bold;
                padding: 3px 8px;
                border-radius: 12px;
                display: inline-block;
            }
            
            .classificacao-detrator {
                background-color: #dc3545;
                color: white;
                font-weight: bold;
                padding: 3px 8px;
                border-radius: 12px;
                display: inline-block;
            }
            /* Estilos para o popover NPS */
            .popover .nps-info-item {
                text-align: justify !important;
            }

            /* Estilos para o filtro fixo */
            #divFiltro {
                position: sticky;
                top:55px;
                z-index: 1020;
                background: none;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }
            #filtros-dashboard-pesquisas{
                gap:0!important;
            }

	</style>
</head>

<!-- Estrutura padrão do projeto -->
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed"  >
    <div class="wrapper" >
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <section class="content-header">
			<div class="container-fluid">

				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-6">
						<h4>Dashboard Pesquisas de Opinião 
						</h4>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>

            <section class="content">
                <div class="container-fluid">
                    <!-- Componente de filtro de ano com posição fixa -->
                    <div id="divFiltro" >
                        <cfmodule template="includes/pc_filtros_componente.cfm" 
                            exibirAno="true" 
                            exibirOrgao="false"
                            exibirDiretoria="false"
                            exibirStatus="false" 
                            componenteID="filtros-dashboard-pesquisas"
                            customContent= '
                                <div id="filtro-ativo-mensagem" class="filtro-ativo-mensagem" style="display: none;">
                                </div>  
                                <div class="filtro-outros" id="btnToggleSearchPane"  title="Abrir painel de filtros" style="cursor: pointer;">
                                    <span>Filtros Avançados</span>
                                    <i class="fas fa-filter" ></i>
                                </div>
                            '
                            limitarAnoPesquisa="true"                     
                            >
                    </div>
                    
                    <!-- Incluir dashboard de métricas -->
                    <cfinclude template="includes/pc_dashboard_pesquisa_datatable/pc_dashboard_cards_metricas.cfm">

                    <!-- Incluir dashboard de avaliações -->
                    <cfinclude template="includes/pc_dashboard_pesquisa_datatable/pc_dashboard_avaliacoes.cfm">

                     <!-- Incluir gráficos do dashboard -->
                    <cfinclude template="includes/pc_dashboard_pesquisa_datatable/pc_dashboard_graficos.cfm">
                    
                    <!-- Incluir nuvem de palavras do dashboard -->
                    <cfinclude template="includes/pc_dashboard_pesquisa_datatable/pc_dashboard_nuvem_palavras.cfm">
                    
                    <!-- Card principal para a tabela -->
                    <div class="card card_border_correios"  style="width:100%;">
                        <div class="card-header card-header_backgroundColor" >
                            <h3 class="card-title">
                                <i class="fas fa-table mr-2"></i>Pesquisas de Opinião
                            </h3>
                            <div class="card-tools">
                                <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                    <i class="fas fa-minus"></i>
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="tab-content" id="custom-tabs-one-tabContent" >
                                <table id="tabelaPesquisasDetalhada" class="table table-striped table-hover text-nowrap table-responsive">
                                    <thead  class="table_thead_backgroundColor">
                                        <tr>
                                            <th>ID</th>
                                            <th>Processo</th>
                                            <th>Ano</th>
                                            <th>Órgão Respondente</th>
                                            <th>Classificação NPS</th>
                                            <th>Órgão de Origem</th>
                                            <th>Diretoria / CS</th>
                                            <th>Órgão Avaliado</th>
                                            <th>Tipo Demanda</th>
                                            <th>Tipo Processo</th>
                                            <th>Data</th>
                                            <th>Comunicação</th>
                                            <th>Interlocução</th>
                                            <th>Reunião</th>
                                            <th>Relatório</th>
                                            <th>Pós-Trabalho</th>
                                            <th>Importância</th>
                                            <th>Pontualidade</th>
                                            <th>Média</th>
                                            <th>Observação</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Dados serão carregados via AJAX -->
                                    </tbody>
                                </table>
                            </div>
                           

                        </div>
                    </div>
                </div>
            </section>
        </div>
        
        <cfinclude template="includes/pc_footer.cfm">
    </div>
    <cfinclude template="includes/pc_sidebar.cfm">


    <script src="plugins/chart.js/Chart.min.js"></script>
    <script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
    <script src="plugins/jqcloud/jqcloud.min.js"></script>
    <script>
        // Registrar o plugin ChartDataLabels globalmente
        Chart.plugins.register(ChartDataLabels);
        
        $(document).ready(function() {
            // Variáveis de controle
            let dataTable = null;
            
            // Função para mostrar modal de carregamento
            function mostrarModal() {
                try {
                    // Certificar-se de que o modal anterior foi fechado
                    fecharModal();
                    
                    // Exibir o modal existente diretamente no DOM
                    $('#modalOverlay').css('display', 'block');
                    $('#modalOverlay').addClass('show');
                    
                    console.log('Modal de carregamento exibido');
                } catch (e) {
                    console.error('Erro ao mostrar modal:', e);
                }
            }
            
            // Função revisada para fechar o modal
            function fecharModal() {
                try {
                    // Fechar diretamente usando jQuery
                    $('#modalOverlay').modal('hide');
                    
                    // Forçar remoção após um curto delay
                    setTimeout(function() {
                        // Remover modal e backdrop manualmente se ainda existirem
                        $('.modal-backdrop').remove();
                        $('body').removeClass('modal-open').css('padding-right', '');
                        $('#modalOverlay').removeClass('show').css('display', 'none');
                        
                      
                    }, 500);
                } catch (e) {
                    console.error('Erro ao fechar modal:', e);
                }
            }
            
            // Função para aplicar formatação de cores às notas
            function formatarNota(nota) {
                nota = parseFloat(nota);
                
                if (nota >= 9) {
                    return '<span class="nota-otima">' + nota + '</span>';
                } else if (nota >= 7) {
                    return '<span class="nota-boa">' + nota + '</span>';
                } else if (nota >= 5) {
                    return '<span class="nota-regular">' + nota + '</span>';
                } else if (nota >= 3) {
                    return '<span class="nota-ruim">' + nota + '</span>';
                } else {
                    return '<span class="nota-pessima">' + nota + '</span>';
                }
            }
            
            // Função para renderizar classificação NPS com base na string recebida do servidor
            function renderizarClassificacaoNPS(classificacao) {
                if (!classificacao) return '-';
                
                switch(classificacao) {
                    case 'Promotor':
                        return '<span class="classificacao-promotor">Promotor</span>';
                    case 'Neutro':
                        return '<span class="classificacao-neutro">Neutro</span>';
                    case 'Detrator':
                        return '<span class="classificacao-detrator">Detrator</span>';
                    default:
                        return '-';
                }
            }
            
            // Função para inicializar a tabela DataTable com SearchPanes
            function inicializarTabela(anoSelecionado) {
                mostrarModal();
                
                // Verificar se o sidebar está aberto antes de reinicializar a tabela
                const sidebarAberto = $('body').hasClass('control-sidebar-slide-open');
                
                dataTable = $('#tabelaPesquisasDetalhada').DataTable({
                    destroy: true, // Permitir reinicialização da tabela
                    stateSave: false,
        			autoWidth: true, //largura da tabela de acordo com o conteúdo
					pageLength: 5,
                    ajax: {
                        url: 'cfc/pc_cfcPesquisasDashboard_datatable.cfc?method=tabPesquisas',
                        type: 'POST',
                        data: function(d) {
                            d.ano = anoSelecionado;
                        },
                        dataSrc: function(json) {
                            fecharModal();
                            
                            let data = json;
                            if (typeof json === 'string') {
                                try {
                                    data = JSON.parse(json);
                                } catch (e) {
                                    console.error('Erro ao parsear JSON:', e);
                                    return [];
                                }
                            }
                            
                            if (data && data.data) {
                                return data.data;
                            }
                            return [];
                        },
                        error: function(xhr, error, thrown) {
                            console.error('Erro no AJAX:', error, thrown);
                            fecharModal();
                            $('#tabela-container').html(`
                                <div class="alert alert-danger">
                                    <i class="fas fa-exclamation-triangle mr-2"></i>
                                    Erro ao carregar dados: ${error}
                                </div>
                            `);
                        }
                    },
                    dom: 
                    "<'row d-flex align-items-center'<'col-auto dtsp-verticalContainer'P><'col-auto'B><'col-auto'f><'col-auto'p>>" + // Botões, filtros e paginação na mesma linha, alinhados à esquerda
                    "<'row'<'col-12'i>>" + // Informações logo abaixo dos botões
                    "<'row'<'col-12'tr>>",  // Tabela com todos os dados
                    buttons: [
                        {
                            extend: 'excel',
                            text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
                            title: 'SNCI_Pesquisas_Dashboard_' + new Date().toISOString().split('T')[0],
                            className: 'btExcel',
                            exportOptions: { columns: ':visible' }
                        },
                        {// Botão abertura do ctrol-sidebar com os filtros
                            text: '<i class="fas fa-filter fa-2x grow-icon" style="margin-right:30px" data-widget="control-sidebar"></i>',
                            className: 'btFiltro',
                        },
                    ],
                    searchPanes: {
                        cascadePanes: true,
                        columns: [3,5,6,7,8,9],
                        threshold: 1,
                        layout: 'columns-1',
                        initCollapsed: true,
                    },
                    columns: [
                        { data: "id" },
                        { data: "processo" },
                        { data: "ano" },
                        { data: "orgao_respondente" },
                        { 
                            data: "classificacao_nps",
                            title: 'Classificação NPS <span  data-toggle="popover" data-html="true" data-placement="right"  \
                                    title="<span class=\'popover-title-custom\'>Classificação do NPS</span>" \
                                    data-content="\
                                    <div class=\'nps-info-content\'>\
                                    <div class=\'nps-info-item\'>\
                                        Classificação baseada na média de todas pesquisas de opinião por órgão respondente e não apenas da média de uma única pesquisa.\
                                    </div>\
                                        <div class=\'nps-info-item promotores-info\'>\
                                            <div class=\'color-dot\'></div>\
                                            <strong>Promotores:</strong> (nota média 9,0 - 10,0)\
                                        </div>\
                                        <div class=\'nps-info-item neutros-info\'>\
                                            <div class=\'color-dot\'></div>\
                                            <strong>Neutros:</strong> (nota média 7,0 - 8,9)\
                                        </div>\
                                        <div class=\'nps-info-item detratores-info\'>\
                                            <div class=\'color-dot\'></div>\
                                            <strong>Detratores:</strong> (nota média 1 - 6,9)\
                                        </div>\
                                    </div>">\
                                    <i class="fas fa-info-circle text-info" style="color:#fff!important"></i>\
                                </span>',
                            render: function(data, type, row) {
                                return renderizarClassificacaoNPS(data);
                            }
                        },
                        { data: "orgao_origem" },
                        { data: "diretoria_cs" },
                        { data:  "orgao_avaliado" },
                        { data: "tipo_demanda" },
                        { 
                            data: "tipo_processo",
                            render: function(data) {
                                return data ? data : '-';
                            }
                        },
                        { 
                            data: "data",
                            render: function(data) {
                                if (!data) return '-';
                                return new Date(data).toLocaleDateString('pt-BR');
                            }
                        },
                        { data: "comunicacao"},  
                        { data: "interlocucao" },
                        { data: "reuniao" },
                        { data: "relatorio" },
                        { data: "pos_trabalho" },
                        { data: "importancia" },
                        { 
                            data: "pontualidade",
                            render: function(data) { 
                                // Verificar se o valor é 1 ou true
                                return (data === 1 || data === true || data === '1') ? 'Sim' : 'Não';
                            }
                        },
                        { 
                            // Usar a média já calculada no servidor
                            data: "media_pesquisa",
                            render: function(data) {
                                if (!data) return '-';
                                return formatarNota(data);
                            }
                        },
                        { data: "observacao" }
                    ],
                    language: {
                        url: "plugins/datatables/traducao.json"
                    },
                    
                    columnDefs: [
                        { 
                            className: "text-center", 
                            targets: [1,2,4,8,10,11,12,13,14,15,16,17,18] // Colunas que devem ser centralizadas
                        },
                        { 
                            targets: 19, // coluna de observações
                            className: 'observacao-coluna',
                            width: '1000px',
                            render: function(data) {
                                if (!data) return '-';
                                return '<div class="observacao-texto">' + data + '</div>';
                            }
                        }
                    ],
                    initComplete: function() {
                        setTimeout(() => {
                            if (this.api().searchPanes) {
                                this.api().searchPanes.rebuildPane();
                                
                                // Expandir todos os panes
                                this.api().searchPanes.container().find('.dtsp-collapseAll').trigger('click');
                                
                                // Colapsar todos os panes
                                setTimeout(() => {
                                    this.api().searchPanes.container().find('.dtsp-expandAll').trigger('click');
                                }, 500); // Pequeno delay para garantir que a expansão foi concluída
                            }
                            initializeSearchPanesAndSidebar(this);
                        }, 1000);
                    },
                    drawCallback: function(settings) {
                        fecharModal();
                    }
                   
                });
                

                // Detectar quando filtros do SearchPane são aplicados ou removidos
                dataTable.on('stateLoaded search.dt', function() {
                    atualizarEstadoFiltro();
                });
                
                dataTable.on('draw.dt', function() {
                    atualizarEstadoFiltro();
                });

                // Adicionar este código após a inicialização do DataTable
                dataTable.on('init.dt', function() {
                    // Inicializar popovers no cabeçalho da tabela
                    $('#tabelaPesquisasDetalhada thead [data-toggle="popover"]').popover({
                        container: 'body',
                        trigger: 'hover',
                        html: true
                    });
                });
                
                // Inicializar o estado da mensagem de filtro
                function atualizarEstadoFiltro() {
                    // Não atualizar se estiver no meio de uma operação de limpeza
                    if (window.limpandoFiltros) return;
                    
                    var filtrosAtivos = [];
                    
                    // Capturar filtros do SearchPane usando o DOM
                    $('.dtsp-searchPane').each(function() {
                        var $pane = $(this);
                        var $selectedRows = $pane.find('tr.selected');
                        
                        if ($selectedRows.length > 0) {
                            var titulo = $pane.find('.dtsp-paneInputButton').attr('placeholder');
                            var valores = [];
                            
                            $selectedRows.each(function() {
                                var valor = $(this).find('.dtsp-name').text().trim();
                                if (valor) {
                                    valores.push(valor);
                                }
                            });
                            
                            if (valores.length > 0) {
                                filtrosAtivos.push(`<b>${titulo}:</b> ${valores.join(', ')}`);
                            }
                        }
                    });
                    
                    var $mensagem = $("#filtro-ativo-mensagem");
                    
                    if (filtrosAtivos.length > 0) {
                        var mensagem = `
                            <div class="d-flex align-items-center justify-content-between w-100">
                                <div class="mr-3">
                                    <i class="fas fa-filter mr-2"></i>
                                    ${filtrosAtivos.join(' | ')}
                                </div>
                                <button id="btn-limpar-filtros" class="btn btn-sm btn-danger">
                                    <i class="fas fa-filter-circle-xmark"></i> Limpar Filtros
                                </button>
                            </div>
                        `;
                        if (!$mensagem.is(":visible")) {
                            $mensagem.html(mensagem).show();
                        } else {
                            $mensagem.html(mensagem);
                        }
                    } else if ($mensagem.is(":visible")) {
                        $mensagem.hide();
                    }
                }
                
                // Botão para limpar filtros
                $(document).on('click', '#btn-limpar-filtros', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // Definir flag para evitar atualizações durante a limpeza
                    window.limpandoFiltros = true;
                    
                    const sidebarAberto = $('#sidebarPaineis').css('display') === 'block';
                    
                    $("#filtro-ativo-mensagem").hide();
                    
                    $('#modalOverlay').css('display', 'block');
                    $('#modalOverlay').addClass('show');

                    setTimeout(function() {
                        try {
                            dataTable.search('').draw(false);
                            dataTable.searchPanes.clearSelections();
                            
                            if (!sidebarAberto) {
                                $('#sidebarPaineis').css('display', 'none');
                                $('body').removeClass('control-sidebar-slide-open');
                            }
                        } catch (error) {
                            console.error('Erro ao limpar filtros:', error);
                        } finally {
                            setTimeout(function() {
                                window.limpandoFiltros = false;
                                $('#modalOverlay').modal('hide');
                                dataTable.draw(false);
                            }, 500);
                        }
                    }, 100);
                });
                
            }
            
            // Aguardar o evento de DOM pronto + um pequeno timeout para garantir que o componente de filtro foi carregado
            setTimeout(function() {
                // Verificar se o valor do filtro de ano foi definido pelo componente de filtro
                const anoInicial = window.anoSelecionado || "Todos";
                console.log("Inicializando tabela com ano:", anoInicial);
                
                // Inicializar a tabela com o ano selecionado no filtro
                inicializarTabela(anoInicial);
            }, 100);

            // Listener de evento para alterações no filtro
            document.addEventListener('filtroAlterado', function(e) {
                console.log('Evento filtroAlterado recebido:', e.detail);
                
                // Verificar se a alteração veio do filtro de ano
                if (e.detail.tipo === 'ano') {
                    console.log('Filtro de ano alterado para:', e.detail.valor);
                    
                    // Mostrar modal de carregamento antes de atualizar a tabela
                    mostrarModal();
                    
                    // Pequeno delay para garantir que o modal está visível antes de iniciar o processamento
                    setTimeout(function() {
                        // Reinicializar a tabela com o novo valor de ano
                        inicializarTabela(e.detail.valor);
                    }, 200);
                }
            });

            // Adicionar funcionalidade para o botão de filtro "Outros" usando delegação de eventos
            $(document).on('click', '#btnToggleSearchPane', function(e) {
                e.stopPropagation(); // Impede que o evento se propague para outros elementos
                
                // Em vez de manipular diretamente, use o mecanismo do AdminLTE
                // Isto garante que o mesmo código será executado como se o botão nativo fosse clicado
                $('[data-widget="control-sidebar"]').trigger('click');
            });
            
            // Estabelecer um único listener para eventos do sidebar do AdminLTE
            $(document).ready(function() {
                // Verificar inicialmente o estado
                atualizarEstadoBotaoOutros();
                
                // Usar os eventos nativos do AdminLTE para o control-sidebar
                $(document).on('expanded.lte.controlsidebar collapsed.lte.controlsidebar', function() {
                    atualizarEstadoBotaoOutros();
                });
                
                // Polling de segurança para casos onde os eventos não são disparados
                setInterval(atualizarEstadoBotaoOutros, 500);
                
                // Função para atualizar o estado visual do botão de acordo com o estado real do sidebar
                function atualizarEstadoBotaoOutros() {
                    if ($('body').hasClass('control-sidebar-slide-open')) {
                        $('#btnToggleSearchPane').removeClass('text-dark').addClass('text-primary');
                        $('.dtsp-panesContainer').show();
                        $('.dtsp-searchPanes .dtsb-searchBuilder').show();
                    } else {
                        $('#btnToggleSearchPane').removeClass('text-primary').addClass('text-dark');
                        $('.dtsp-panesContainer').hide();
                    }
                }
            });

           
        });
      
        $(".content-wrapper").css("height", "auto");
    </script>


</body>
</html>