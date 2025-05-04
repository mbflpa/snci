<cfprocessingdirective pageencoding = "utf-8">





<cfquery name="rsProcAno" datasource="#application.dsn_processos#" timeout="120" >
	SELECT distinct   right(pc_processos.pc_processo_id,4) as ano

	FROM        pc_processos INNER JOIN
				pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
				pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
				pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
				pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
				pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
				LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
				LEFT JOIN pc_avaliacao_posicionamentos on pc_aval_posic_num_orientacao = pc_aval_id
				LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
				LEFT JOIN pc_avaliadores on pc_avaliador_id_processo = pc_processo_id
				LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
				LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
	WHERE pc_num_status IN (4,6)	
	<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>	   	
		<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
		<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
			AND pc_processo_id IS NOT NULL 
		<cfelse>
			
			<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
				AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
			</cfif>
			<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1) - Execução' ou 14 - 'CI - REGIONAL - SCIA - Acompanhamento', com origem na GCOP---> --->
			<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
				and pc_num_orgao_origem IN('00436698') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#))
			</cfif>
		</cfif>
	<cfelse>
		AND NOT pc_num_status IN (6)	
		<!---Se o perfil não for 13 - 'CONSULTA' (AUDIT e RISCO)--->
		<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 13 >
			AND (
					pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_melhoria_num_orgao =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_melhoria_sug_orgao_mcu =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					<cfif ListLen(application.orgaosHierarquiaList) GT 0>
						OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
						OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
						OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
						OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
					</cfif>
				)
			<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
			<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
					<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
					and NOT (
							pc_aval_orientacao_status not in (13)
							AND pc_orgaos_2.pc_org_status IN ('O')
						)
					<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
					and NOT (
							pc_aval_orientacao_status = 13
							AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
						)
					and NOT (
								pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
			</cfif>
		</cfif>
	</cfif>	
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
                      

	<style>
			textarea {
				text-align: justify!important;
			}
			.card-body{
				text-align: justify!important;
			}
			.popover-body {
				text-align: justify!important;
			}
	</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		
		<cfinclude template="includes/pc_navBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper">
		<!-- Content Header (Page header) -->
		
		<section class="content-header">
			<div class="container-fluid">
						
				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Consulta por Processo (Em Acompanhamento)</h4>
							<i id="info-icon" class="fas fa-circle-info azul_claro_correios_textColor" style="cursor: pointer;font-size: 17px;position: relative;bottom: 13px;" 
							title="Consulta por Processo (Em Acompanhamento)" 
							data-placement="right" data-content="Nessa tela é possível consultar Processos avaliados pelo Controle Interno em que exista ao menos um Item/Orientação com acompanhamento que ainda não foi finalizado."></i>
						</div>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>

		<div style="justify-content:right;  width: 100%;">
			<div style="margin-right: 50px;float:right">
				<i id="btExibirTab" class=" fas fa-th" style="font-size:40px;color: #2581c8;cursor:pointer" title ="Exibir Tabela"></i>
			</div>
		</div>

		<!-- Main content -->
		<section class="content">
			<div class="container-fluid">
				<!-- /.card-header -->
				<div class="card-body" >
					<form id="formAcomp" name="formAcomp" format="html"  style="height: auto;">
						<div style="display: flex;align-items: center;margin-bottom:10px">
							<span class="azul_claro_correios_textColor" style="font-size:20px;margin-right:10px">Ano:</span>
							<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
						</div>

						
						<!--acordion-->
						<div id="accordionCadItemPainel" style="margin-bottom:80px">
							<div class="card card-success card_border_correios" >
								<div class="card-header card-header_backgroundColor">
									<h4 class="card-title ">
										<span class="d-block" data-toggle="collapse" href="#collapseTwo" style="color:#fff;font-size:20px;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i><span id="texto_card-title">Selecione um Processo</span>
										</span>
									</h4>
								</div>
																
								<div id="collapseTwo" class=""  data-parent="#accordion">																
									<div id="exibirTab"></div>
								</div> <!--fim collapseTwo -->
							</div><!--fim card card-success -->	
						</div><!--fim acordion -->
					</form><!-- fim formAcomp -->					
				</div><!-- fim card-body -->	

				<div id="tabAvaliacoesConsulta"></div>
			</div>
		</section>
		<!-- /.content -->
	</div>
	<!-- /.content-wrapper -->
	<cfinclude template="includes/pc_footer.cfm">
	</div>
	<!-- ./wrapper -->
	<cfinclude template="includes/pc_sidebar.cfm">


	<script language="JavaScript">
		//inicializa o popover (bloquear/desbloquear processo)
		// $(function () {
		// 	$('[data-toggle="popover"]').popover()
		// })	
		// $('.popover-dismiss').popover({
		// 	trigger: 'hover'
		// })
		$(document).ready(function () {
			$("#modalOverlay").modal("show");
			// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			$(".content-wrapper").css("height", "auto");

			// Constante para o nome do grupo de rádio
			const radio_name = "opcaoAno";

			// Array para armazenar os anos disponíveis
			const ano = [];

			// Obter o ano corrente
			const anoCorrente = new Date();
			const anoAtual = anoCorrente.getFullYear();

			// Preencher o array de anos com os valores do resultado da consulta "rsProcAno"
			<cfoutput query="rsProcAno">
				ano.push(#rsProcAno.ano#);
			</cfoutput>

			// Se não houver anos disponíveis, adicionamos o ano atual
			if (ano.length === 0) {
				ano.push(anoAtual);
			}

			// Se houver mais de um ano disponível, adicionamos a opção "TODOS" no array
			if (ano.length > 1) {
				ano.push("TODOS");
			}

			// Pegar o índice do último ano no array para destaque posterior
			const anoq = ano.length - 1;

			// Percorrer o array de anos, ordenar em ordem decrescente e criar os elementos HTML para os botões de rádio
			$.each(ano.sort().reverse(), function (i, val) {
				const checkedClass = i === anoq ? " active" : "";
				const radioHTML = `<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="efeito-grow btn bg-yellow${checkedClass}">
					<input type="radio" ${checkedClass ? 'checked=""' : ""} name="${radio_name}" id="option_b${i}" autocomplete="off" value="${val}" />${val}
				</label><br>`;
				$(radioHTML).prependTo("#opcoesAno");
			});

			// Obter o valor selecionado inicialmente
			let radioValue = $("input[name='opcaoAno']:checked").val();

			// Atualizar o título do card com o valor selecionado inicialmente
			$("#texto_card-title").html(`Selecione um Processo <span style="font-size:14px;color:#fff!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);

			// Esconder o overlay após 1 segundo
			// $("#modalOverlay").delay(1000).hide(0, function () {
			// 	$("#modalOverlay").modal("hide");
			// });

			// Verificar se há valor armazenado na chave 'mostraTab' no Local Storage
			let mostraTab = localStorage.getItem("mostraTab");
			if (mostraTab === null) {
				// Se não houver, definimos 'mostraTab' como '0' e armazenamos no Local Storage
				mostraTab = "0";
				localStorage.setItem("mostraTab", mostraTab);
			}

			// Atualizar a aparência e exibir a tabela ou os cards com base no valor armazenado em 'mostraTab'
			const $btExibirTab = $("#btExibirTab");
			if (mostraTab === "1") {
				$btExibirTab.removeClass("fa-th").addClass("fa-table").prop("title", "Exibir Cards");
				exibirTabela(radioValue);
			} else {
				$btExibirTab.removeClass("fa-table").addClass("fa-th").prop("title", "Exibir Tabela");
				ocultarTabela(radioValue);
			}

			// Esconder o overlay após 1 segundo
			// $("#modalOverlay").delay(1000).hide(0, function () {
			// 	$("#modalOverlay").modal("hide");
			// });

			// Lidar com a mudança de seleção dos botões de rádio
			$("input[type='radio']").click(function () {
				$("#exibirTab").html('<h3 style="margin-left:50px">Carregando...</h3>');
				radioValue = $("input[name='opcaoAno']:checked").val();
				$("#modalOverlay").modal("show");
				mostraTab = localStorage.getItem("mostraTab");
				if (mostraTab === "1") {
					exibirTabela(radioValue);
				} else {
					ocultarTabela(radioValue);
				}
				$("#modalOverlay").delay(1000).hide(0, function () {
					$("#modalOverlay").modal("hide");
				});
				$("#texto_card-title").html(`Selecione um Processo <span style="font-size:14px;color:#fff!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);
			});

			// Lidar com o clique do botão de exibir tabela/cards
			$btExibirTab.on("click", function (event) {
				radioValue = $("input[name='opcaoAno']:checked").val();
				$("#modalOverlay").modal("show");
				if ($(this).hasClass("fa-th")) {
					exibirTabela(radioValue);
				} else {
					ocultarTabela(radioValue);
				}
				$("#modalOverlay").delay(1000).hide(0, function () {
					$("#modalOverlay").modal("hide");
				});
			});

			$(window).on("beforeunload", function () {
				// Verificar se o DataTable está inicializado na tabela "#tabProcessos" e limpar o estado salvo do DataTable
				if ($.fn.DataTable.isDataTable("#tabProcessos")) {
					$("#tabProcessos").DataTable().state.clear();
				}

				// Verificar se o DataTable está inicializado na tabela "#tabProcConsultaCards" e limpar o estado salvo do DataTable
				if ($.fn.DataTable.isDataTable("#tabProcConsultaCards")) {
					$("#tabProcConsultaCards").DataTable().state.clear();
				}
			});
		});

		function exibirTabela(anoMostra) {
			$("#modalOverlay").delay(1000).hide(0, function () {
				$("#modalOverlay").modal("hide");
			});
			
			setTimeout(function () {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcConsultasPorProcesso.cfc",
					data: {
						method: "tabConsulta",
						ano: anoMostra,
						processoEmAcompanhamento: true,
					},
					async: false,
					success: function (result) {
						$("#exibirTab").html(result);
						$("#btExibirTab").removeClass("fa-th").addClass("fa-table").prop("title", "Exibir Cards");
						localStorage.setItem("mostraTab", "1");
						$("#tabAvaliacoesConsulta").html("");
					},
					error: function (xhr, ajaxOptions, thrownError) {
						$("#modal-danger").modal("show");
						$("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:");
						$("#modal-danger").find(".modal-body").text(thrownError);
					},
				});
			}, 500);
		}

		function ocultarTabela(anoOculta) {
			$("#modalOverlay").delay(1000).hide(0, function () {
				$("#modalOverlay").modal("hide");
			});
			setTimeout(function () {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcConsultasPorProcesso.cfc",
					data: {
						method: "cardsConsulta",
						ano: anoOculta,
						processoEmAcompanhamento: true,
					},
					async: false,
					success: function (result) {
						$("#exibirTab").html(result);
						$("#btExibirTab").removeClass("fa-table").addClass("fa-th").prop("title", "Exibir Tabela");
						localStorage.setItem("mostraTab", "0");
						$("#tabAvaliacoesConsulta").html("");
					},
					error: function (xhr, ajaxOptions, thrownError) {
						$("#modal-danger").modal("show");
						$("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:");
						$("#modal-danger").find(".modal-body").text(thrownError);
					},
				});
			}, 500);
		}
	</script>


</body>
</html>
