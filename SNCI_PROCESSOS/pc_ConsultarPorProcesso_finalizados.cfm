<cfprocessingdirective pageencoding = "utf-8">

	<cfquery name="rsHerancaUnion" datasource="#application.dsn_processos#">
		SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' 

		union

		SELECT  pc_orgaos2.pc_org_mcu
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
																		FROM pc_orgaos_heranca
																		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
																		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' )) 

		union

		select pc_orgaos.pc_org_mcu AS mcuHerdado
		from pc_orgaos
		LEFT JOIN pc_orgaos_heranca ON pc_orgHerancaMcuDe = pc_org_mcu
		where pc_orgaos.pc_org_mcu_subord_tec in(SELECT  pc_orgaos2.pc_org_mcu
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in(SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
																		FROM pc_orgaos_heranca
																		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
																		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' )))
	</cfquery>

	<cfquery dbtype="query" name="rsHeranca"> 
		SELECT mcuHerdado FROM rsHerancaUnion WHERE not mcuHerdado is null
	</cfquery>

	<cfset mcusHeranca = ValueList(rsHeranca.mcuHerdado) />

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
	WHERE NOT pc_num_status IN (2,3) AND pc_num_status in (5)	
	<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
		<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
		<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
			AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		</cfif>
		<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
		<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
			AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
		</cfif>
		<!---Se o perfil for 7 - 'GESTOR' --->
		<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
			AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
		</cfif>
	<cfelse>
	    <cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
			AND not pc_aval_orientacao_status in (9,12)
		<cfelse>
			AND (pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
			or pc_aval_orientacao_mcu_orgaoResp in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE (pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			or pc_org_mcu_subord_tec in( SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#')))
			<cfif #mcusHeranca# neq ''>or pc_aval_orientacao_mcu_orgaoResp in (#mcusHeranca#)</cfif>)  
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
	
		
		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper">
		<!-- Content Header (Page header) -->
		
		<section class="content-header">
			<div class="container-fluid">
						
				<div class="row mb-2" style="margin-top:20px;margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Consulta por Processos Finalizados</h4>
							<i id="info-icon" class="fas fa-circle-info " style="color: #0083ca;cursor: pointer;font-size: 17px;position: relative;bottom: 13px;" 
							title="Consulta por Processos Finalizados" data-toggle="popover" data-trigger="hover" 
							data-placement="right" data-content="Nessa tela é possível consultar Processos avaliados pelo Controle Interno em que todos os itens/Orientações estão com os acompanhamentos finalizados"></i>
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
							<span style="color:#0083ca;font-size:20px;margin-right:10px">Ano:</span>
							<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
						</div>

						
						<!--acordion-->
						<div id="accordionCadItemPainel" >
							<div class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i><span id="texto_card-title">Selecione um Processo</span>
										</a>
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
	<cfinclude template="pc_Footer.cfm">
	</div>
	<!-- ./wrapper -->
	<cfinclude template="pc_Sidebar.cfm">

	<script language="JavaScript">
		//inicializa o popover (bloquear/desbloquear processo)
		$(function () {
			$('[data-toggle="popover"]').popover()
		})	
		$('.popover-dismiss').popover({
			trigger: 'hover'
		})
		
		$(document).ready(function () {
			$("#modalOverlay").modal("show");
			// Ajustar a altura da div content-wrapper para o background cinza estender até o final do timeline
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
				const radioHTML = `<label style="border:none!important;border-radius:0!important;" class="btn bg-olive${checkedClass}">
					<input type="radio" ${checkedClass ? 'checked=""' : ""} name="${radio_name}" id="option_b${i}" autocomplete="off" value="${val}" />${val}
				</label><br>`;
				$(radioHTML).prependTo("#opcoesAno");
			});

			// Obter o valor selecionado inicialmente
			let radioValue = $("input[name='opcaoAno']:checked").val();

			// Atualizar o título do card com o valor selecionado inicialmente
			$("#texto_card-title").html(`Selecione um Processo <span style="font-size:14px;color:gray!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);

			// Esconder o overlay após 1 segundo
			// $("#modalOverlay").delay(1000).hide(0, function () {
			// 	$("#modalOverlay").modal("hide");
			// });

			// Verificar e configurar o modo de exibição (tabela ou cards) com base no valor armazenado no localStorage
			let mostraTab = localStorage.getItem("mostraTab");
			if (mostraTab === null) {
				localStorage.setItem("mostraTab", "0");
				mostraTab = "0";
			}

			if (mostraTab === "1") {
				$("#btExibirTab").removeClass("fa-th");
				$("#btExibirTab").addClass("fa-table");
				$("#btExibirTab").prop("title", "Exibir Cards");
				exibirTabela(radioValue);
			} else {
				$("#btExibirTab").removeClass("fa-table");
				$("#btExibirTab").addClass("fa-th");
				$("#btExibirTab").prop("title", "Exibir Tabela");
				ocultarTabela(radioValue);
			}

			// Lidar com a mudança de seleção dos botões de rádio
			$("input[type='radio']").click(function () {
				$("#exibirTab").html('<h1 style="margin-left:50px">Carregando...</h1>');
				radioValue = $("input[name='opcaoAno']:checked").val();
				$("#modalOverlay").modal("show");
				mostraTab = localStorage.getItem("mostraTab");
				if (mostraTab === "1") {
					exibirTabela(radioValue);
				} else {
					ocultarTabela(radioValue);
				}
				// $("#modalOverlay").delay(1000).hide(0, function () {
				// 	$("#modalOverlay").modal("hide");
				// });
				$("#texto_card-title").html(`Selecione um Processo <span style="font-size:14px;color:gray!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);
			});

			

			// Lidar com o clique no botão de alternar a exibição entre tabela e cards
			$("#btExibirTab").on("click", function (event) {
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

			// Limpar o estado salvo do DataTable antes de sair da página
			$(window).on("beforeunload", function () {
				if ($.fn.DataTable.isDataTable("#tabProcessos")) {
					const tabela = $("#tabProcessos").DataTable();
					tabela.state.clear();
				}

				if ($.fn.DataTable.isDataTable("#tabProcConsultaCards")) {
					const tabela = $("#tabProcConsultaCards").DataTable();
					tabela.state.clear();
				}
			});
		});

		// Função para exibir a tabela com base no ano selecionado
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
						processoEmAcompanhamento: false,
					},
					async: false,
					success: function (result) {
						$("#exibirTab").html(result);
						$("#btExibirTab").removeClass("fa-th");
						$("#btExibirTab").addClass("fa-table");
						$("#btExibirTab").prop("title", "Exibir Cards");
						localStorage.setItem("mostraTab", "1");
						$("#tabAvaliacoesConsulta").html("");
					},
					error: function (xhr, ajaxOptions, thrownError) {
						$("#modal-danger").modal("show");
						$("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação. Informe o erro abaixo ao administrador do sistema:");
						$("#modal-danger").find(".modal-body").text(thrownError);
					},
				});
			}, 500);
		}

		// Função para ocultar a tabela e exibir os cards com base no ano selecionado
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
						processoEmAcompanhamento: false,
					},
					async: false,
					success: function (result) {
						$("#exibirTab").html(result);
						$("#btExibirTab").removeClass("fa-table");
						$("#btExibirTab").addClass("fa-th");
						$("#btExibirTab").prop("title", "Exibir Tabela");
						localStorage.setItem("mostraTab", "0");
						$("#tabAvaliacoesConsulta").html("");
					},
					error: function (xhr, ajaxOptions, thrownError) {
						$("#modal-danger").modal("show");
						$("#modal-danger").find(".modal-title").text("Não foi possível executar sua solicitação. Informe o erro abaixo ao administrador do sistema:");
						$("#modal-danger").find(".modal-body").text(thrownError);
					},
				});
			}, 500);
		}
	</script>


</body>
</html>
