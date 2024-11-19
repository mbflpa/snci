<cfprocessingdirective pageencoding = "utf-8">



<cfquery name="rsProcAno" datasource="#application.dsn_processos#" timeout="120" >
	SELECT   distinct   right(pc_processos.pc_processo_id,4) as ano

	FROM        pc_processos 
				LEFT JOIN pc_orgaos ON  pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				INNER JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
				LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
				LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_orgaos_1.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
				LEFT JOIN pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
				LEFT JOIN pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
				LEFT JOIN pc_avaliadores on pc_avaliador_id_processo = pc_processo_id
				INNER JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
	WHERE  not pc_aval_orientacao_status in (0,1) 
	<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
	    AND pc_num_status in(4,6)
		<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
		<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
			AND pc_processo_id IS NOT NULL 
		<cfelse>
			<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
			<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
				and pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			</cfif>
			<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'CI - AVALIADOR (EXECUÇÃO)') --->
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
				and pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
			</cfif>
			<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1) - Execução' ou 14 - 'CI - REGIONAL - SCIA - Acompanhamento', com origem na GCOP---> --->
			<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
				and pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)
			</cfif>
		</cfif>
		
	<cfelse>
	    AND pc_num_status in(4) AND not pc_aval_orientacao_status in (9,12,14)
		<!---Se o perfil não for 13 - 'CONSULTA' (AUDIT e RISCO)--->
		<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 13 >
			AND (
					pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					<cfif ListLen(application.orgaosHierarquiaList) GT 0>
						OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
						OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
					</cfif>
				)
			<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
			<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
					<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
					and NOT (
							pc_aval_orientacao_status not in (13)
							AND pc_orgaos_1.pc_org_status IN ('O')
						)
					<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
					and NOT (
							pc_aval_orientacao_status = 13
							AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
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
        <link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">
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
			.swal2-label{
				text-align:justify;
			}
		</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper" >
		<!-- Content Header (Page header) -->
		
		<section class="content-header">
			<div class="container-fluid">
						
				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Consulta por Orientação (Processos Em Acompanhamento)</h4>
							<i id="info-icon" class="fas fa-circle-info azul_claro_correios_textColor" style="cursor: pointer;font-size: 17px;position: relative;bottom: 13px;" 
							title="Consulta por Orientação (Processos em Acompanhamento)" data-toggle="popover" data-trigger="hover" 
							data-placement="right" data-content="Nessa tela é possível consultar Processos avaliados pelo Controle Interno em que exista ao menos um Item/Orientação com acompanhamento que ainda não foi finalizado."></i>
						</div>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" >
				<div style="display: flex;align-items: center;">
					<span class="azul_claro_correios_textColor" style="font-size:20px;margin-right:10px">Ano:</span>
					<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
				</div>
				<!-- /.card-header -->
				<session class="card-body" >
					<div class="card-header card-header_backgroundColor">
							
						<h4 class="card-title ">	
							<div  class="d-block" style="font-size:20px;color:#fff;font-weight: bold;"> 
								<i class="fas fa-file-alt" style="margin-top:4px;"></i><span id="texto_card-title" style="margin-left:10px;font-size:16px;">Selecione um Processo</span>
							</div>
						</h4>
					</div>
					<div class="card-body card_border_correios" >
						<div id="exibirTabSpinner"></div>
						<div id="exibirTab"></div>
					</div>
				</session>
				<div id="informacoesItensConsultaDiv"></div>
				<div id="timelineViewConsultaDiv"></div>
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
			$("#texto_card-title").html(`Selecione uma Orientação <span style="font-size:14px;color:#fff!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);

			// Esconder o overlay após 1 segundo
			// $("#modalOverlay").delay(1000).hide(0, function () {
			// 	$("#modalOverlay").modal("hide");
			// });

			// Exibir a tabela com base no valor selecionado inicialmente
			exibirTabela(radioValue);

			// Lidar com a mudança de seleção dos botões de rádio
			$("input[type='radio']").click(function () {
				radioValue = $("input[name='opcaoAno']:checked").val();
				$("#texto_card-title").html(`Selecione uma Orientação <span style="font-size:14px;color:#fff!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);
				exibirTabela(radioValue);
			});
		});

		// Função para exibir a tabela com base no ano selecionado
		function exibirTabela(anoMostra) {
			$("#modalOverlay").modal("show");
			$('#exibirTab').hide();
			$("#exibirTab").html('');
			$("#exibirTabSpinner").html('<h1 style="margin-left:50px;color:#e83e8c"><i class="fas fa-spinner fa-spin"></i><span style="font-size:20px"> Carregando dados, aguarde...</span></h1>');
			setTimeout(function () {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
					data: {
						method: "tabConsulta",
						ano: anoMostra,
						processoEmAcompanhamento: true,
					},
					async: false,
					success: function (result) {
						// Esconde a tabela inicialmente
						$("#exibirTab").html(result);
						$("#informacoesItensConsultaDiv").html("");
						$("#timelineViewConsultaDiv").html("");
						$("#exibirTabSpinner").html("");
						$("#modalOverlay").delay(1000).hide(0, function () {
							$("#modalOverlay").modal("hide");
						});
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
			}, 500);
		}

		// Limpar o estado salvo do DataTable antes de sair da página
		$(window).on("beforeunload", function () {
			// Verificar se o DataTable está inicializado na tabela
			if ($.fn.DataTable.isDataTable("#tabProcessos")) {
				const tabela = $("#tabProcessos").DataTable();
				tabela.state.clear();
			}
		});
	</script>


</body>
</html>
