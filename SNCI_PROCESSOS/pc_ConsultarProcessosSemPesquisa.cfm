<cfprocessingdirective pageencoding="utf-8">

<cfquery name="rsProcAno" datasource="#application.dsn_processos#" timeout="120">
	SELECT DISTINCT right(pc_processos.pc_processo_id, 4) as ano
	FROM pc_processos
	WHERE right(pc_processos.pc_processo_id, 4) >= 2024
	ORDER BY ano
</cfquery>

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
										<th>Órgão Avaliado MCU</th>
										<th>Órgão Avaliado Sigla</th>
										<th>Órgão Avaliado SE Sigla</th>
									</tr>
								</thead>
								<tbody></tbody>
							</table>
						</div>
					</session>
				</div>
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
			$("#modalOverlay").modal("show");
			const radio_name = "opcaoAno";
			const ano = [];
			const anoCorrente = new Date();
			const anoAtual = anoCorrente.getFullYear();

			<cfoutput query="rsProcAno">
				ano.push(#rsProcAno.ano#);
			</cfoutput>

			if (ano.length === 0) {
				ano.push(anoAtual);
			}

			if (ano.length > 1) {
				ano.push("TODOS");
			}

			const anoq = ano.length - 1;

			$.each(ano.sort().reverse(), function (i, val) {
				const checkedClass = i === anoq ? " active" : "";
				const radioHTML = `<label style="border:none!important; border-radius:10px!important; margin-left:2px" class="efeito-grow btn bg-yellow${checkedClass}">
					<input type="radio" ${checkedClass ? 'checked=""' : ""} name="${radio_name}" id="option_b${i}" autocomplete="off" value="${val}" />${val}
				</label><br>`;
				$(radioHTML).prependTo("#opcoesAno");
			});

			let radioValue = $("input[name='opcaoAno']:checked").val();
			$("#texto_card-title").html(`Selecione um Processo <span style="font-size:14px; color:#fff!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);
			exibirTabela(radioValue);

			$("input[type='radio']").click(function () {
				radioValue = $("input[name='opcaoAno']:checked").val();
				$("#texto_card-title").html(`Selecione um Processo <span style="font-size:14px; color:#fff!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);
				exibirTabela(radioValue);
			});
		});

		function exibirTabela(anoMostra) {
			$("#modalOverlay").modal("show");
			$('#exibirTab').hide();
			$("#exibirTab").html('');
			$("#exibirTabSpinner").html('<h1 style="margin-left:50px; color:#e83e8c"><i class="fas fa-spinner fa-spin"></i><span style="font-size:20px"> Carregando dados, aguarde...</span></h1>');
			$.ajax({
				type: "post",
				url: "cfc/pc_cfcPesquisa.cfc",
				data: {
					method: "getProcessosSemPesquisaJSON",
					ano: anoMostra
				},
				async: true,
				success: function (result) {
					try {
						const data = typeof result === "string" ? JSON.parse(result) : result;
						console.log("Dados recebidos:", data);

						if (!Array.isArray(data) || data.length === 0) {
							console.warn("Nenhum dado encontrado");
							$("#tabProcessos tbody").html("<tr><td colspan='10'>Nenhum dado disponível</td></tr>");
							return;
						}

						let tableHTML = "";
						data.forEach(processo => {
							tableHTML += `<tr>
								<td>${processo.pc_processo_id}</td>
								<td>${processo.sei}</td>
								<td>${processo.pc_num_rel_sei}</td>
								<td>${processo.pc_aval_tipo_macroprocessos}</td>
								<td>${processo.pc_aval_tipo_processoN1}</td>
								<td>${processo.pc_aval_tipo_processoN2}</td>
								<td>${processo.pc_aval_tipo_processoN3}</td>
								<td>${processo.orgao_avaliado_mcu}</td>
								<td>${processo.orgao_avaliado_sigla}</td>
								<td>${processo.orgao_avaliado_se_sigla}</td>
							</tr>`;
						});

						if ($.fn.DataTable.isDataTable("#tabProcessos")) {
							$("#tabProcessos").DataTable().clear().draw();
						}

						$("#tabProcessos tbody").html(tableHTML);

						setTimeout(() => {
							$("#tabProcessos").DataTable({
								destroy: true,
								ordering: false,
								stateSave: true,
								scrollY: "150px",
								filter: false,
								scrollX: true,
								scrollCollapse: true,
								deferRender: true,
								pageLength: 3,
								buttons: [
									{
										extend: 'excelHtml5',
										text: '<i class="fas fa-file-excel fa-2x grow-icon"></i>',
										title: 'SNCI_Processos_' + new Date().toLocaleDateString('pt-BR'),
										className: 'btExcel',
										exportOptions: {
											columns: ':visible'
										},
										customize: function (xlsx) {
											var sheet = xlsx.xl.worksheets['sheet1.xml'];
											$('row:eq(0) c', sheet).attr('s', '50');
											$('row:eq(0) c', sheet).attr('s', '2');
											$('row:eq(1) c', sheet).attr('s', '51');
											$('row:eq(1) c', sheet).attr('s', '2');
										},
										customizeData: function (data) {
											for (var i = 0; i < data.body.length; i++) {
												var rowData = data.body[i];
												for (var j = 0; j < rowData.length; j++) {
													var cellData = rowData[j];
													if (cellData.includes('&nbsp;')) {
														rowData[j] = cellData.replace(/&nbsp;/g, ' ');
													}
												}
											}
										}
									},
									{
										extend: 'colvis',
										text: 'Selecionar Colunas',
										className: 'btSelecionarColuna',
										collectionLayout: 'fixed three-column',
										colvisButton: true
									},
									{
										text: '<i class="fas fa-eye" title="Visualizar todas as colunas."></i>',
										action: function (e, dt, node, config) {
											$('#modalOverlay').modal('show');
											setTimeout(function () {
												dt.columns().visible(true);
											}, 500);
											$('#modalOverlay').delay(1000).hide(0, function () {
												$('#modalOverlay').modal('hide');
											});
										}
									},
									{
										text: '<i class="fas fa-eye-slash" title="Oculta todas as colunas."></i>',
										action: function (e, dt, node, config) {
											$('#modalOverlay').modal('show');
											setTimeout(function () {
												dt.columns().visible(false);
											}, 500);
											$('#modalOverlay').delay(1000).hide(0, function () {
												$('#modalOverlay').modal('hide');
											});
										}
									}
								],
                                
								dom: 
                                    "<'row d-flex align-items-center'<'col-auto dtsp-verticalContainer'P><'col-auto'B><'col-auto'f><'col-auto'p>>" + // Botões, filtros e paginação na mesma linha, alinhados à esquerda
                                    "<'row'<'col-12'i>>" + // Informações logo abaixo dos botões
                                    "<'row'<'col-12'tr>>",  // Tabela com todos os dados
								drawCallback: function (settings) {
									$('#exibirTabExportarDiv').show();
									$('#exibirTabExportarSpinnerDiv').html('');
								},
                                
								language: {
									url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
								}
							}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');
						}, 300);

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

		$(window).on("beforeunload", function () {
			if ($.fn.DataTable.isDataTable("#tabProcessos")) {
				const tabela = $("#tabProcessos").DataTable();
				tabela.state.clear();
			}
		});
	</script>
</body>
</html>
