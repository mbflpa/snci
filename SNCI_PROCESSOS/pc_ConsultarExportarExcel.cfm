<cfprocessingdirective pageencoding = "utf-8">





<cfquery name="rsProcAno" datasource="#application.dsn_processos#" timeout="120" >
	SELECT distinct   right(pc_processos.pc_processo_id,4) as ano
	FROM        pc_processos INNER JOIN
				pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id LEFT JOIN
				pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu LEFT JOIN
				pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id LEFT JOIN
				pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu LEFT JOIN
				pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
				LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
				LEFT JOIN pc_avaliacao_posicionamentos on pc_aval_posic_num_orientacao = pc_aval_id
				LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
				LEFT JOIN pc_avaliadores on pc_avaliador_id_processo = pc_processo_id
				LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
				LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
	WHERE NOT pc_num_status IN (2,3) 	
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
		<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
		<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
			AND	pc_num_status not in(6)
		<cfelse>
			AND pc_num_status not in(6)
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
			.btn-secondary {
				margin-left: 10px!important;
				border-radius: 5px!important;
			}
			div.dt-button-collection.fixed.three-column {
				margin-left:-400!important;
				width: 900px!important;
				padding:10px!important;
			}
			div.dt-button-collection.fixed.four-column {
				margin-left:-400!important;
				width: 1045px!important;
				padding:10px!important;
			}
			.dropdown-item.active, .dropdown-item:active {
				color: #fff;
				text-decoration: none;
				background-color: #2581c8!important;
				border: 1px solid #fff!important;
			}
			
			
	</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper" style="background:none" >
		<!-- Content Header (Page header) -->
		
		<section class="content-header">
			<div class="container-fluid">
				
				<div class="row mb-2" style="margin-top:10px;margin-bottom:0px!important;">
					<div class="col-sm-6">
						<h4>Consulta para Exportação</h4>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" >
				<div style="display: flex;align-items: center;">
					<span style="color:#0083ca;font-size:20px;margin-right:10px">Consultar Por:</span>
					<div id="opcaoTipoConsulta" class="btn-group btn-group-toggle" data-toggle="buttons">
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio" checked="" name="opcaoTipoConsulta" id="tipoProcesso" autocomplete="off" value="p" /> PROCESSOS</label><br>
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio"  name="opcaoTipoConsulta" id="tipoItens" autocomplete="off" value="i" /> ITENS</label><br>
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio"  name="opcaoTipoConsulta" id="tipoOrientacoes" autocomplete="off" value="o" /> ORIENTAÇÕES</label><br>
						<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="btn bg-yellow active efeito-grow"><input type="radio"  name="opcaoTipoConsulta" id="tipoOrientacoes" autocomplete="off" value="m" /> PROP. MELHORIA</label><br>
					</div>
				</div>
				<div style="display: flex;align-items: center;">
					<span style="color:#0083ca;font-size:20px;margin-right:10px">Ano:</span>
					<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons" style=" margin-left: 82px;"></div><br><br>
				</div>
				
				<div id="exibirTabExportarDiv"></div>
			</div>
		</section>
		<!-- /.content -->
	</div>
	<!-- /.content-wrapper -->
	<cfinclude template="pc_Footer.cfm">
	</div>
	<!-- ./wrapper -->
	<cfinclude template="pc_Sidebar.cfm">

    <!-- Gráficos -->
    <script src="plugins/chart.js/Chart.js"></script>
    <script src="plugins/chart.js/Chart.bundle.min.js"></script>
	
	<script language="JavaScript">
		
		$(window).on("load",function(){
           
			const radio_name="opcaoAno";
			const ano = [];
			const anoCorrente = new Date();
			const anoAtual = anoCorrente.getFullYear();

			<cfoutput query = "rsProcAno" >
				ano.push(#rsProcAno.ano#)
			</cfoutput>
			
			if( ano.length === 0 ){
				ano.push(anoAtual);
			}
			if( ano.length > 1 ){
				ano.push("TODOS");
			}
			const anoq = ano.length-1;
			$.each(ano.sort().reverse(), function(i,val){
				if(i == anoq){
					$('<label style="border:none!important;border-radius:10px!important;margin-left:1px;" class="efeito-grow btn bg-blue "><input type="radio" name="opcaoAno" id="option_b'+i+'" autocomplete="off" value="'+val+'" />'+val+'</label><br>').prependTo('#opcoesAno');
				}else{
					$('<label style="border:none!important;border-radius:10px!important;margin-left:1px;" class="efeito-grow btn bg-blue"><input type="radio" name="opcaoAno" id="option_b'+i+'" autocomplete="off" value="'+val+'" />'+val+'</label><br>').prependTo('#opcoesAno');
				}
			})

			var radioValueAno = $("input[name='opcaoAno']:checked").val();
			var radioValueTipo = $("input[name='opcaoTipoConsulta']:checked").val();
				
			
			exibirTabExportarDiv(radioValueTipo,radioValueAno);		
					

			$("input[type='radio']").click(function(){
				radioValueAno = $("input[name='opcaoAno']:checked").val();
				radioValueTipo = $("input[name='opcaoTipoConsulta']:checked").val();
				exibirTabExportarDiv(radioValueTipo,radioValueAno);
			});
		});

		


		function exibirTabExportarDiv(tipo, ano){

			$('#modalOverlay').modal('show');
			let tipoConsulta = "";
			let tipoSelecao = "";
			
			if(tipo ==='p'){
				tipoConsulta ="tabConsultaExportarProcessos"; 
				if(ano === undefined){
					tipoSelecao="PROCESSOS (não selecionou o ano)";
				}else{
					tipoSelecao="PROCESSOS de " + ano;
				}
			}

			if(tipo ==='i'){
				tipoConsulta ="tabConsultaExportarItens"
				if(ano === undefined){
					tipoSelecao="ITENS (não selecionou o ano)";
				}else{
					tipoSelecao="ITENS de " + ano;
				}
			};
			if(tipo ==='o'){
				tipoConsulta ="tabConsultaExportarOrientacoes";
				if(ano === undefined){
					tipoSelecao="ORIENTAÇÕES (não selecionou o ano)";
				}else{
					tipoSelecao="ORIENTAÇÕES de " + ano;
				}
			};
			if(tipo ==='m'){
				tipoConsulta ="tabConsultaExportarMelhorias";
				if(ano === undefined){
					tipoSelecao="PROPOSTAS DE MELHORIA (não selecionou o ano)";
				}else{
					tipoSelecao="PROPOSTAS DE MELHORIA de " + ano;
				}
			};
			setTimeout(function() {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcConsultasDiversas.cfc",
					data:{
						method: tipoConsulta,
						ano: ano
					},
					async: false,
					success: function(result) {
						let comDados = "";
						try {
							xmlDoc = $.parseXML(result);
							var $xml = $(xmlDoc);
							comDados = $xml.find("string").text();
						} catch (e) {
							comDados = 'S';
						}
						if(comDados=='N'){
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
							$('#exibirTabExportarDiv').html('<h5 align="center" style="margin-top:50px">Nenhum registro foi localizado para os parâmetros informados: ' + tipoSelecao + '</h5>')
							return;
						}
						$('#exibirTabExportarDiv').html(result)	
						var table = $('#tabProcessos').DataTable();

  						if( tipoConsulta !=null && ano !=null ){
							table.on('draw.dt', function() {		
								$('#modalOverlay').delay(1000).hide(0, function() {
									$('#modalOverlay').modal('hide');
								});	  
							});
						}else{
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
						}
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
					}
				});
			}, 500);

			
			
				
			

		}


			
		
	</script>

</body>
</html>
