<cfprocessingdirective pageencoding = "utf-8">

<cfquery name="rsHerancaUnion" datasource="#dsn_processos#">
	SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
	FROM pc_orgaos_heranca
	LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
	WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#rsUsuarioParametros.pc_usu_lotacao#' 

	union

	SELECT  pc_orgaos2.pc_org_mcu
	FROM pc_orgaos_heranca
	LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
	LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
	WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
	FROM pc_orgaos_heranca
	LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
	WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#rsUsuarioParametros.pc_usu_lotacao#' )) 

	union

	select pc_orgaos.pc_org_mcu AS mcuHerdado
	from pc_orgaos
	LEFT JOIN pc_orgaos_heranca ON pc_orgHerancaMcuDe = pc_org_mcu
	where pc_orgaos.pc_org_mcu_subord_tec in(SELECT  pc_orgaos2.pc_org_mcu
	FROM pc_orgaos_heranca
	LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
	LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
	WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in(SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
	FROM pc_orgaos_heranca
	LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
	WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#rsUsuarioParametros.pc_usu_lotacao#' )))
</cfquery>

<cfquery dbtype="query" name="rsHeranca"> 
	SELECT mcuHerdado FROM rsHerancaUnion WHERE not mcuHerdado is null
</cfquery>

<cfset mcusHeranca = ValueList(rsHeranca.mcuHerdado) />

<cfquery name="rsProcAno" datasource="#dsn_processos#" timeout="120" >
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
	WHERE NOT pc_num_status IN (2,3) 	
	<cfif #rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
		<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
		<cfif '#rsUsuarioParametros.pc_org_status#' eq 'O' and #rsUsuarioParametros.pc_usu_perfil# neq 11>
			AND pc_num_orgao_origem = '#rsUsuarioParametros.pc_usu_lotacao#'
		</cfif>
		<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
		<cfif #rsUsuarioParametros.pc_usu_perfil# eq 4 and '#rsUsuarioParametros.pc_org_status#' eq 'A'>
			AND pc_avaliador_matricula = #rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #rsUsuarioParametros.pc_usu_matricula#
		</cfif>
		<!---Se o perfil for 7 - 'GESTOR' --->
		<cfif #rsUsuarioParametros.pc_usu_perfil# eq 7 and '#rsUsuarioParametros.pc_org_status#' neq 'O'  and '#rsUsuarioParametros.pc_org_status#' eq 'A'>
			AND pc_orgaos.pc_org_se = 	#rsUsuarioParametros.pc_org_se#
		</cfif>
	<cfelse>
		<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
		<cfif #rsUsuarioParametros.pc_usu_perfil# eq 13 >
				AND  pc_aval_orientacao_status not in (9,12,14) and pc_num_status not in(6)
		<cfelse>
			AND (pc_aval_orientacao_mcu_orgaoResp = '#rsUsuarioParametros.pc_usu_lotacao#' 
			or pc_aval_orientacao_mcu_orgaoResp in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE (pc_org_mcu_subord_tec = '#rsUsuarioParametros.pc_usu_lotacao#'
			or pc_org_mcu_subord_tec in( SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_mcu_subord_tec = '#rsUsuarioParametros.pc_usu_lotacao#')))
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
		<link rel="icon" type="image/x-icon" href="dist/img/icone_sistema_standalone_ico.png">	
           
		

		

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
						<label style="border:none!important;border-radius:0!important;" class="btn bg-olive active"><input type="radio" checked="" name="opcaoTipoConsulta" id="tipoProcesso" autocomplete="off" value="p" /> PROCESSOS</label><br>
						<label style="border:none!important;border-radius:0!important;" class="btn bg-olive active"><input type="radio"  name="opcaoTipoConsulta" id="tipoItens" autocomplete="off" value="i" /> ITENS</label><br>
						<label style="border:none!important;border-radius:0!important;" class="btn bg-olive active"><input type="radio"  name="opcaoTipoConsulta" id="tipoOrientacoes" autocomplete="off" value="o" /> ORIENTAÇÕES</label><br>
						<label style="border:none!important;border-radius:0!important;" class="btn bg-olive active"><input type="radio"  name="opcaoTipoConsulta" id="tipoOrientacoes" autocomplete="off" value="m" /> PROP. MELHORIA</label><br>
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
					$('<label style="border:none!important;border-radius:0!important;" class="btn bg-olive "><input type="radio" name="opcaoAno" id="option_b'+i+'" autocomplete="off" value="'+val+'" />'+val+'</label><br>').prependTo('#opcoesAno');
				}else{
					$('<label style="border:none!important;border-radius:0!important;" class="btn bg-olive"><input type="radio" name="opcaoAno" id="option_b'+i+'" autocomplete="off" value="'+val+'" />'+val+'</label><br>').prependTo('#opcoesAno');
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
			if(tipo ==='p'){tipoConsulta ="tabConsultaExportarProcessos"};
			if(tipo ==='i'){tipoConsulta ="tabConsultaExportarItens"};
			if(tipo ==='o'){tipoConsulta ="tabConsultaExportarOrientacoes"};
			if(tipo ==='m'){tipoConsulta ="tabConsultaExportarMelhorias"};
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
