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

<cfquery name="getOrgHierarchy" datasource="#application.dsn_processos#" timeout="120">
	WITH OrgHierarchy AS (
		SELECT pc_org_mcu, pc_org_mcu_subord_tec
		FROM pc_orgaos
		WHERE pc_org_mcu_subord_tec = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
		UNION ALL
		SELECT o.pc_org_mcu, o.pc_org_mcu_subord_tec
		FROM pc_orgaos o
		INNER JOIN OrgHierarchy oh ON o.pc_org_mcu_subord_tec = oh.pc_org_mcu
	)
	SELECT pc_org_mcu
	FROM OrgHierarchy
</cfquery>

<cfset orgaosHierarquiaList = ValueList(getOrgHierarchy.pc_org_mcu)>

<cfquery name="rsProcAno" datasource="#application.dsn_processos#" timeout="120" >
	SELECT   distinct   right(pc_processos.pc_processo_id,4) as ano

	FROM        pc_processos 
				INNER JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
				INNER JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
				LEFT JOIN pc_orgaos ON  pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_orgaos_1.pc_org_mcu = pc_aval_melhoria_num_orgao
				LEFT JOIN pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
				LEFT JOIN pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
				LEFT JOIN pc_avaliadores on pc_avaliador_id_processo = pc_processo_id
	WHERE NOT pc_num_status IN (2,3) 
	<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>

		<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI)--->
		<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
			AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		</cfif>
		
		<!---Se o perfil for 4 - 'CI - AVALIADOR (EXECUÇÃO)') --->
		<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 >
			AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
		</cfif>

		<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1)'  ou 14 -'CI - REGIONAL - SCIA - Acompanhamento'--->
		<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) >
			AND pc_num_orgao_origem IN('00436698','00436697','00438080') AND (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#))
		</cfif>

	<cfelse>
	    AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6)
		<!---Se o perfil do usuário não for 13 - GOVERNANÇA --->
		<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 13 >
			AND (
					pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					or  pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					OR pc_aval_melhoria_sug_orgao_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					<cfif getOrgHierarchy.recordCount gt 0>
						or pc_processos.pc_num_orgao_avaliado in (#orgaosHierarquiaList#)
						or pc_aval_melhoria_num_orgao in (#orgaosHierarquiaList#)
						or pc_aval_melhoria_sug_orgao_mcu in (#orgaosHierarquiaList#)
					</cfif>
				)

			<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
			<cfif getOrgHierarchy.recordCount gt 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
					
					and NOT (
							pc_processos.pc_num_orgao_avaliado not in (#orgaosHierarquiaList#)
						OR pc_aval_melhoria_num_orgao not in (#orgaosHierarquiaList#)
						OR pc_aval_melhoria_sug_orgao_mcu  not in (#orgaosHierarquiaList#)
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
				margin-bottom:50px;
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
						
				<div class="row mb-2" style="margin-top:20px;margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Consultar Propostas de Melhoria</h4>
							
						</div>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" >
				<div style="display: flex;align-items: center;">
					<span style="color:#0083ca;font-size:20px;margin-right:10px">Ano:</span>
					<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
				</div>
				<h5 style="color:#0083ca"><i class="fas fa-file-alt" style="margin-right:10px"> </i><span id="texto_card-title" >Selecione um Processo</span></h5>
				<div id="exibirTab" ></div>
				<div id="informacoesMelhoriasConsultaDiv" ></div>
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
			$("#texto_card-title").html(`Selecione uma Proposta de Melhoria <span style="font-size:14px;color:gray!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);

			// Esconder o overlay após 1 segundo
			// $("#modalOverlay").delay(1000).hide(0, function () {
			// 	$("#modalOverlay").modal("hide");
			// });

			// Exibir a tabela com base no valor selecionado inicialmente
			exibirTabela(radioValue);

			// Lidar com a mudança de seleção dos botões de rádio
			$("input[type='radio']").click(function () {
				$('#informacoesMelhoriasConsultaDiv').html('');
				radioValue = $("input[name='opcaoAno']:checked").val();
				$("#texto_card-title").html(`Selecione uma Proposta de Melhoria <span style="font-size:14px;color:gray!important">(filtrado por ano: <strong>${radioValue}</strong>)</span>`);
				exibirTabela(radioValue);
			});
		});

		// Função para exibir a tabela com base no ano selecionado
		function exibirTabela(anoMostra) {
			$("#modalOverlay").modal("show");
			$("#exibirTab").html('<h3 style="margin-left:50px">Carregando...</h3>');
			setTimeout(function () {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcConsultaPropMelhoria.cfc",
					data: {
						method: "tabMelhoriasConsulta",
						ano: anoMostra
					},
					async: false,
					success: function (result) {
						$("#exibirTab").html(result);
						
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
			if ($.fn.DataTable.isDataTable("#tabMelhoriasPendentes")) {
				const tabela = $("#tabMelhoriasPendentes").DataTable();
				tabela.state.clear();
			}
		});
	</script>


</body>
</html>