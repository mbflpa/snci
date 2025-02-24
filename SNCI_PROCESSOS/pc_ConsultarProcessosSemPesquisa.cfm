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
		/* Adicionar estilo para centralizar colunas específicas */
		#tabProcessos td:nth-child(1),
		#tabProcessos td:nth-child(2),
		#tabProcessos td:nth-child(3) {
			text-align: center;
		}
		/* Estilo dos cartões de processo */
		.process-card {
			background: #f8f9fa;
			border: 1px solid #dee2e6;
			border-radius: 10px;
			padding: 5px;
			box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
			width: 260px;
			height: 100px;
			display: flex;
			flex-direction: column;
			justify-content: center;
			position: relative;
			border-left: 4px solid var(--azul_claro_correios);
			cursor: pointer;
		}

		.process-card .fa-file-alt {
			transition: transform 0.3s linear;
		}

		.process-card:hover .fa-file-alt {
			transform: scale(1.3);
		}

		.process-card-desativado {
			background-color: #f8d7da;
			border-left: 4px solid #dc3545;
		}

		.process-card-cell {
			padding: 0;
		}

		.process-icon {
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			font-size: 70px;
			opacity: 0.1;
			color: rgba(0, 0, 0, 62%);
		}

		.card-icons {
			display: flex;
			justify-content: space-between;
			align-items: center;
			gap: 25px;
		}

		.card-icons i {
			font-size: 15px;
			cursor: pointer;
		}

		.process-info {
			font-size: 12px;
			color: #0e406a;
			line-height: 1.2; /* Ajustar a altura da linha para melhor visibilidade */
		}

		.process-info p {
			margin-bottom: 0.2rem; /* Diminuir a distância entre os parágrafos */
			white-space: nowrap;
			overflow: hidden;
			text-overflow: ellipsis;
		}

		.grid-container {
			display: flex!important;
			flex-wrap: wrap!important;
			grid-row-gap: 10px !important;
			grid-column-gap: 35px !important;
			
			max-height: 350px!important;
			overflow-y: auto!important;
			overflow-x: hidden !important;
			justify-items: center!important;
			background: transparent!important;
		}

		.process-card:hover {
			background-color:#fcfced;
			color:#000;
			border-left: 4px solid green;
		}

		.process-card .overlay {
			display: none;
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			background: rgba(255, 255, 255, 0.9);
			border-radius: 10px;
			z-index: 1000;
		}

		.process-card .overlay-content {
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			text-align: center;
		}

		.process-card .overlay i {
			font-size: 24px;
			color: var(--azul_claro_correios);
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
							<div >
								<cfoutput>
									<h4 style="margin-right: 10px;">Processos com Pesquisas de Opinião não respondidas pelo órgão #application.rsUsuarioParametros.pc_org_sigla#</h4>
									<h5 style="margin-right: 10px;">Obs.: aplicada em processos a partir de #application.anoPesquisaOpiniao#</h5>
								</cfoutput>
							</div>
						</div>
					</div>
				</div>
			</section>
			<section class="content">
				<div class="container-fluid">
					
					<session class="card-body">
						<div class="card-header card-header_backgroundColor">
							<h4 class="card-title">
								<div class="d-block" style="font-size:20px; color:#fff; font-weight: bold;">
									<i class="fas fa-file-alt" style="margin-top:4px;"></i><span id="texto_card-title" style="margin-left:10px; font-size:16px;">Selecione um Processo para exibir o formulário de pesquisa</span>
								</div>
							</h4>
						</div>
						<div id="card-body-tabela" class="card-body card_border_correios">
							<div class="grid-container" id="tabProcessos"></div>
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
			let colunasMostrar = [3,4,5,6,7,8];
			var currentDate = new Date();
			var day = currentDate.getDate();
			var month = currentDate.getMonth() + 1;
			var year = currentDate.getFullYear();

			var d = day + "-" + month + "-" + year;	
			
			$('#exibirTab').hide();
			$("#exibirTab").html('');
			$("#exibirTabSpinner").html('<h1 style="margin-left:50px; color:#e83e8c"><i class="fas fa-spinner fa-spin"></i><span style="font-size:20px"> Carregando dados, aguarde...</span></h1>');
			$("#modalOverlay").modal("show");
			setTimeout(function() {
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
								$("#card-body-tabela").html("<tr><td colspan='10'><h5>Nenhuma pesquisa de opinião pendente de resposta foi localizada.</h5></td></tr>");
								$("#modalOverlay").delay(1000).hide(0, function () {
									$("#modalOverlay").modal("hide");
								});
								return;
							}

							let tableHTML = "";
							data.forEach(processo => {
								tableHTML += `
									<div class="process-card" data-processo-id="${processo.PC_PROCESSO_ID}">
										<div class="process-icon"><i class="fas fa-file-alt"></i></div>
										<div class="process-info">
											<p><strong>ID do Processo:</strong> ${processo.PC_PROCESSO_ID || 'N/A'}</p>
											<p><strong>Número SEI:</strong> ${processo.SEI || 'N/A'}</p>
											<p><strong>Número Relatório SEI:</strong> ${processo.PC_NUM_REL_SEI || 'N/A'}</p>
											<p><strong>Processo N2:</strong> ${processo.PC_AVAL_TIPO_PROCESSON2 || 'N/A'}</p>
										</div>
									</div>
								`;
							});
						
							$("#tabProcessos").html(tableHTML);

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
			}, 1000);
		}

		// Adicione um evento de clique para os cartões de processo
		$(document).on("click", ".process-card", function () {
			const $card = $(this);
			const processoId = $card.data("processo-id");
			
			// Mostra o loading no card
			$card.find('.overlay').remove(); // Remove overlay anterior se existir
			$card.append(`
				<div class="overlay">
					<div class="overlay-content">
						<i class="fas fa-2x fa-sync-alt fa-spin"></i>
						<div class="text-bold pt-2">Carregando...</div>
					</div>
				</div>
			`);
			$card.find('.overlay').fadeIn();

			// Remove a classe 'clicked' de todos os cards e adiciona ao atual
			$(".process-card").removeClass("clicked");
			$card.addClass("clicked");

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
						$('.modal-backdrop').remove();
						$('body').removeClass('modal-open');
					});
					// Remove o loading quando o modal é mostrado
					$card.find('.overlay').fadeOut(function() {
						$(this).remove();
					});
				},
				error: function (xhr, ajaxOptions, thrownError) {
					// Remove o loading em caso de erro
					$card.find('.overlay').fadeOut(function() {
						$(this).remove();
					});
					$("#modal-danger").modal("show");
					$("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação. Informe o erro abaixo ao administrador do sistema:");
					$("#modal-danger").find(".modal-body").text(thrownError);
				}
			});
		});
		
	</script>
</body>
</html>
