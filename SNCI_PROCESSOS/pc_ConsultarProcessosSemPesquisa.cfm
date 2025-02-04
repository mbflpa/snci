<cfprocessingdirective pageencoding="utf-8">


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
		.card-body {
			text-align: justify!important;
		}
		.popover-body {
			text-align: justify!important;
		}
		.swal2-label {
			text-align: justify;
		}
	</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
	<div class="wrapper">
		<cfinclude template="pc_NavBar.cfm">
		
		<div class="content-wrapper">
			<section class="content-header">
				<div class="container-fluid">
					<div class="row mb-2" style="margin-bottom:0px!important;">
						<div class="col-sm-12">
							<div style="display: flex; align-items: center;">
								<h4 style="margin-right: 10px;">Consultar Processos Sem Pesquisa</h4>
							</div>
						</div>
					</div>
				</div>
			</section>
			<section class="content">
				<div class="container-fluid">
					<div style="display: flex; align-items: center;">
						<span class="azul_claro_correios_textColor" style="font-size:20px; margin-right:10px">Ano:</span>
						<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
					</div>
					<session class="card-body">
						<div class="card-header card-header_backgroundColor">
							<h4 class="card-title">
								<div class="d-block" style="font-size:20px; color:#fff; font-weight: bold;">
									<i class="fas fa-file-alt" style="margin-top:4px;"></i><span id="texto_card-title" style="margin-left:10px; font-size:16px;">Selecione um Processo</span>
								</div>
							</h4>
						</div>
						<div class="card-body card_border_correios">
							<table id="tabProcessos" class="table table-striped table-hover text-nowrap table-responsive">
								<thead class="table_thead_backgroundColor">
									<tr style="font-size:14px">
										<th>ID do Processo</th>
										<th>Número SEI</th>
										<th>Número Relatório SEI</th>
										<th>Macroprocessos</th>
										<th>Processo N1</th>
										<th>Processo N2</th>
										<th>Processo N3</th>

										
									</tr>
								</thead>
								<tbody></tbody>
							</table>
						</div>
					</session>
				</div>
				<div id="exibirPesquisa"></div>
			</section>
		</div>
		<cfinclude template="pc_Footer.cfm">
	</div>
	<cfinclude template="pc_Sidebar.cfm">

	<script language="JavaScript">
		$(function () {
			$('[data-toggle="popover"]').popover()
		})
		$('.popover-dismiss').popover({
			trigger: 'hover'
		})

		$(document).ready(function () {
			
         exibirTabela();
            
		});



		function exibirTabela() {
            let colunasMostrar = [3,4, 5, 6, 7, 8];
            var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	
			$("#modalOverlay").modal("show");
			$('#exibirTab').hide();
			$("#exibirTab").html('');
			$("#exibirTabSpinner").html('<h1 style="margin-left:50px; color:#e83e8c"><i class="fas fa-spinner fa-spin"></i><span style="font-size:20px"> Carregando dados, aguarde...</span></h1>');
			$.ajax({
				type: "post",
				url: "cfc/pc_cfcPesquisa.cfc",
				data: {
					method: "getProcessosSemPesquisaJSON",
				},
				async: true,
				success: function (result) {
					try {
						const data = typeof result === "string" ? JSON.parse(result) : result;

						if (!Array.isArray(data) || data.length === 0) {
							console.warn("Nenhum dado encontrado");
							$("#tabProcessos tbody").html("<tr><td colspan='10'>Nenhum dado disponível</td></tr>");
							return;
						}

						let tableHTML = "";
						data.forEach(processo => {
                            tableHTML += `<tr>
                                <td>${processo.PC_PROCESSO_ID || 'N/A'}</td>
                                <td>${processo.SEI || 'N/A'}</td>
                                <td>${processo.PC_NUM_REL_SEI || 'N/A'}</td>
                                  <td>${processo.PC_AVAL_TIPO_MACROPROCESSOS || 'N/A'}</td>
                                <td>${processo.PC_AVAL_TIPO_PROCESSON1 || 'N/A'}</td>
                                <td>${processo.PC_AVAL_TIPO_PROCESSON2 || 'N/A'}</td>
                                <td>${processo.PC_AVAL_TIPO_PROCESSON3 || 'N/A'}</td>
                                
                            </tr>`;
                        });
                       
						if ($.fn.DataTable.isDataTable("#tabProcessos")) {
							$("#tabProcessos").DataTable().clear().draw();
						}

						$("#tabProcessos tbody").html(tableHTML);

						setTimeout(() => {
							$("#tabProcessos").DataTable({
                                destroy: true,
								stateSave: false,
                                autoWidth: true,// Ajustar automaticamente o tamanho das colunas
                                pageLength: 5,
                                dom: 
                                    "<'row d-flex align-items-center'<'col-auto dtsp-verticalContainer'P><'col-auto'B><'col-auto'f><'col-auto'p>>" + // Botões, filtros e paginação na mesma linha, alinhados à esquerda
                                    "<'row'<'col-12'i>>" + // Informações logo abaixo dos botões
                                    "<'row'<'col-12'tr>>",  // Tabela com todos os dados
                                        
                                buttons: [
                                    {
                                        extend: 'excel',
                                        text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
                                        title : "Processos_sem_pesquisas_" + d,
                                        className: 'btExcel',
                                    },
                                    {// Botão abertura do ctrol-sidebar com os filtros
                                        text: '<i class="fas fa-filter fa-2x grow-icon" style="margin-right:30px" data-widget="control-sidebar"></i>',
                                        className: 'btFiltro',
                                    },

                                ],
                                customizeData: function (data) {
									// Percorre os dados exportados
									for (var i = 0; i < data.body.length; i++) {
										var rowData = data.body[i];
										// Percorre as células da linha
										for (var j = 0; j < rowData.length; j++) {
											var cellData = rowData[j];
											// Verifica se cellData é uma string e contém "&nbsp;"
											if (typeof cellData === 'string' && cellData.includes('&nbsp;')) {
												// Substitui todas as ocorrências de "&nbsp;" por espaços regulares
												rowData[j] = cellData.replace(/&nbsp;/g, ' ');
											}
										}
									}
								},
                                
                                searchPanes: {
                                    cascadePanes: true, // Exibir apenas opções que combinam com os filtros anteriores
                                    columns: colunasMostrar,// Colunas que terão filtro
                                    threshold: 1,// Número mínimo de registros para exibir Painéis de Pesquisa
                                    layout: 'columns-1', //layout do filtro com uma coluna
                                    initCollapsed: true, // Colapsar Painéis de Pesquisa
                                },
								drawCallback: function (settings) {
								
								},
                                initComplete: function () {// Função executada ao finalizar a inicialização do DataTable
                                    initializeSearchPanesAndSidebar(this)//inicializa o searchPanes dentro do controlSidebar
                                    $('#exibirTabExportarDiv').show();
									$('#exibirTabExportarSpinnerDiv').html('');
                                },
                                
								language: {
									url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
								}
							})
						}, 1000);

						$("#modalOverlay").delay(1000).hide(0, function () {
							$("#modalOverlay").modal("hide");
						});
					} catch (error) {
						console.error("Erro ao processar JSON:", error, result);
					}
				},
				error: function (xhr, ajaxOptions, thrownError) {
					$("#modalOverlay").delay(1000).hide(0, function () {
						$("#modalOverlay").modal("hide");
					});
					$("#modal-danger").modal("show");
					$("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação. Informe o erro abaixo ao administrador do sistema:");
					$("#modal-danger").find(".modal-body").text(thrownError);
				},
			});
		}

		//ao clicar na linha da tabela
		$("#tabProcessos tbody").on("click", "tr", function () {
			var table = $("#tabProcessos").DataTable();
			var data = table.row(this).data();
			var processoId = data[1];
			$.ajax({
				type: "post",
				url: "cfc/pc_cfcPesquisa.cfc",
				data: {
					method: "abreFormPesquisa",
					pc_processo_id: processoId
				},
				async: true,
				success: function (result) {
					$("#exibirPesquisa").html(result);

					$("#avaliacaoModal").modal("show").on("hidden.bs.modal", function () {
						$("#exibirPesquisa").html("");
						exibirTabela();
					});
				},
				error: function (xhr, ajaxOptions, thrownError) {
					$("#modal-danger").modal("show");
					$("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação. Informe o erro abaixo ao administrador do sistema:");
					$("#modal-danger").find(".modal-body").text(thrownError);
				},
			});
			
		});

		$(window).on("beforeunload", function () {
			if ($.fn.DataTable.isDataTable("#tabProcessos")) {
				const tabela = $("#tabProcessos").DataTable();
				tabela.state.clear();
			}
		});
	</script>
</body>
</html>
