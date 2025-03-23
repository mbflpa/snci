<cfprocessingdirective pageencoding = "utf-8">	

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SNCI</title>
    <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">	
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
                    <!-- Componente de filtros reutilizável - apenas com ano -->
                    <cfmodule template="includes/pc_filtros_componente.cfm"
                        componenteID="filtros-pesquisas-datatable"
                        exibirAno="true"
                        exibirOrgao="false"
                        exibirDiretoria="false"
                        exibirStatus="false">
                    
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
                                            <th>Órgão Respondente</th>
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


   
    <script>
        $(document).ready(function() {
            // Variáveis de controle
            let dataTable = null;
            
            // Função para mostrar modal de carregamento
            function mostrarModal() {
                // Certificar-se de que o modal não está aberto antes
                fecharModal();

                // Atrasar um pouco antes de abrir para garantir que fechamento anterior foi concluído
                setTimeout(function() {
                    $('#modalOverlay').modal('show');
                }, 100);
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
                        
                        console.log('Modal overlay removido');
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
            
           
            
            // Função para inicializar a tabela DataTable com SearchPanes
            function inicializarTabela(anoSelecionado) {
                mostrarModal();
                
              
                
                dataTable = $('#tabelaPesquisasDetalhada').DataTable({
                    destroy: true, // Permitir reinicialização da tabela
                    stateSave: true,
        			autoWidth: true, //largura da tabela de acordo com o conteúdo
					pageLength: 5,
                    ajax: {
                        url: 'cfc/pc_cfcPesquisasDashboard_datatable.cfc?method=tabPesquisas',
                        type: 'POST',
                        data: function(d) {
                            d.ano = anoSelecionado;
                        },
                        dataSrc: function(json) {
                            console.log('Dados recebidos, fechando modal...');
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
                        columns: [2,3,4,5,6,7],
                        threshold: 1,
                        layout: 'columns-1',
                        initCollapsed: true,
                    },
                    columns: [
                        { data: "id" },
                        { data: "processo" },
                        { data: "orgao_respondente" },
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
                            // Média calculada dinamicamente
                            data: null,
                            render: function(data, type, row) {
                                const notas = [
                                    parseFloat(row.comunicacao) || 0,
                                    parseFloat(row.interlocucao) || 0,
                                    parseFloat(row.reuniao) || 0,
                                    parseFloat(row.relatorio) || 0,
                                    parseFloat(row.pos_trabalho) || 0,
                                    parseFloat(row.importancia) || 0
                                ];
                                
                                const notasValidas = notas.filter(nota => nota > 0);
                                if (notasValidas.length === 0) return '-';
                                
                                const media = notasValidas.reduce((a, b) => a + b, 0) / notasValidas.length;
                                return formatarNota(media.toFixed(1));
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
                            targets: [6, 7, 8, 9, 10, 11, 12, 13]
                        },
                        { 
                            targets: 14, // coluna de observações
                            className: 'observacao-coluna',
                            width: '1000px',
                            render: function(data) {
                                if (!data) return '-';
                                return '<div class="observacao-texto">' + data + '</div>';
                            }
                        },
                        {
                            // Configurar coluna de pontualidade
                            targets: 12,
                            render: function(data, type, row) {
                                if (type === 'display') {
                                    return (data === 1 || data === true || data === '1') ? 'Sim' : 'Não';
                                }
                                return data;
                            }
                        }
                    ],
                    initComplete: function() {
                        initializeSearchPanesAndSidebar(this);
                        $('#tabela-container').show();
                    },
                    drawCallback: function(settings) {
                        fecharModal();
                    }
                   
                });
                

                
            }
            
            // Escutar evento de alteração de filtro
            document.addEventListener('filtroAlterado', function(e) {
                const { tipo, valor } = e.detail;
                
                if (tipo === 'ano') {
                    inicializarTabela(valor);
                }
            });
            
            // Carregar dados iniciais após um pequeno delay para garantir que os filtros estejam inicializados
            setTimeout(function() {
                const anoInicial = window.anoSelecionado || "Todos";
                inicializarTabela(anoInicial);
            }, 500);

            
        });
      
		$(".content-wrapper").css("height", "auto");



    </script>


</body>
</html> 