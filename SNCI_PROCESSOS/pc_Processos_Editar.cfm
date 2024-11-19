<cfprocessingdirective pageencoding = "utf-8">



<cfquery name="rsAno" datasource="#application.dsn_processos#" timeout="120" >
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
	WHERE NOT pc_num_status IN (2,3) and right(pc_processos.pc_processo_id,4) >=2024	
	
	ORDER BY ano
</cfquery>	

<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SNCI</title>
<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">
   <style>
		fieldset{
					border: 1px solid #ced4da!important;
					border-radius: 8px!important;
					padding: 20px!important;
					margin-bottom: 10px!important;
					background: none!important;
					-webkit-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
					-moz-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
					box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
					font-weight: 400 !important;
				}

				legend {
					font-size: 0.8rem!important;
					color: #fff!important;
					background-color: var(--azul_claro_correios)!important;
					border: 1px solid #ced4da!important;
					border-radius: 5px!important;
					padding: 5px!important;
					width: auto!important;
				}

							

				.cardBodyStepper {
						border: solid 1px rgba(108, 117, 125, 0.3);
						border-radius: 0.5rem;
						box-shadow: 5px 5px 5px rgba(0, 0, 0, 0.05);
				}

				.form-group.d-flex .form-control {
					width: auto;
					flex-grow: 1;
				}

				fieldset{
					border: 1px solid #ced4da!important;
					border-radius: 8px!important;
					padding: 20px!important;
					margin-bottom: 10px!important;
					background: none!important;
					-webkit-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
					-moz-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
					box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
					font-weight: 400 !important;
				}

				legend {
					font-size: 0.8rem!important;
					color: #fff!important;
					background-color: var(--azul_claro_correios)!important;
					border: 1px solid #ced4da!important;
					border-radius: 5px!important;
					padding: 5px!important;
					width: auto!important;
				}
   </style>
      
     

</head>

<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">

	<div class="wrapper">

		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">
		
		<!-- Content Wrapper. Contains page content -->
		<div class="content-wrapper" >
			<!-- Content Header (Page header) -->
			<div class="content-header" style="background:  #f4f6f9;">
			
				<div class="container-fluid">
				   	<div class="row mb-2" style="margin-bottom:0px!important;">
						<div class="col-sm-6">
							<h4>Editar Processos</h4>
						</div>
					</div>

					<div class="card-body" style="display:flex;flex-direction:column;">
						<div style="display: flex;align-items: center;margin-bottom:10px">
							<span class="azul_claro_correios_textColor" style="font-size:20px;margin-right:10px">Ano:</span>
							<div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons"></div><br><br>
						</div>


						<div id="divFormCadProcesso" hidden class="card-body" ></div>

						<div id="exibirCards" style="margin-top:10px"></div>
					</div>	<!-- fim card-body -->

					
							
					<div id="cadAvaliacaoForm"></div>
					
				</div>
			</div>
			
		</div>
			
		<cfinclude template="pc_Footer.cfm">
		
	</div>
	<cfinclude template="pc_Sidebar.cfm">
	
	<!-- Select2 -->
	<script src="plugins/select2/js/select2.full.min.js"></script>
	

	


	<script language="JavaScript">
		$(document).ready(function() {
			$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline

			var radio_name="opcaoAno";
			const ano = [];
			const anoCorrente = new Date();
			const anoAtual = anoCorrente.getFullYear();
			<cfoutput query = "rsAno" >
				ano.push(#rsAno.ano#)
			</cfoutput>
			
			if( ano.length === 0 ){
				ano.push(anoAtual);
			}
			
			if( ano.length > 1 ){
				ano.push("TODOS");
			}

			const anoq = ano.length-1;
			// Percorrer o array de anos, ordenar em ordem decrescente e criar os elementos HTML para os botões de rádio
			$.each(ano.sort().reverse(), function (i, val) {
				const checkedClass =  "";
				const radioHTML = `<label style="border:none!important;border-radius:10px!important;margin-left:2px" class="efeito-grow btn bg-yellow${checkedClass}">
					<input type="radio" ${checkedClass ? 'checked=""' : ""} name="${radio_name}" id="option_b${i}" autocomplete="off" value="${val}" />${val}
				</label><br>`;
				$(radioHTML).prependTo("#opcoesAno");
			});

			radioValue = $("input[name='opcaoAno']:checked").val();
			
			exibirCards('2010')

			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
			});
			$('#texto_card-title').html('Selecione um Processo <span style="font-size:14px;color:gray!important">(filtrado por ano: <strong>'+ radioValue + '</strong>)</span>')

			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
			});
			$("input[type='radio']").click(function(){
				radioValue = $("input[name='opcaoAno']:checked").val();
				exibirCards(radioValue)
				$('#texto_card-title').html('Selecione um Processo <span style="font-size:14px;color:gray!important">(filtrado por ano: <strong>'+ radioValue + '</strong>)</span>')
			});

			

			

		});

		function exibirFormCadProcesso(){
			$('#modalOverlay').modal('show')
			setTimeout(function() {
             	$('#divFormCadProcesso').attr("hidden",true)
				$('#divFormCadProcesso').html('')
				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});
			}, 500);
		}

		function exibirCards(anoMostra){
			$('#modalOverlay').modal('show')
			$('#exibirCards').html('')
			$('#TabAvaliacao').html('')
			$('#cadAvaliacaoForm').html('');
			
			$('#divFormCadProcesso').attr("hidden",true)
			$('#divFormCadProcesso').html('')
			setTimeout(function() {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcProcessos_editar.cfc",
					data:{
						method: "cardsProcessos",
						ano:anoMostra
					},
					async: false,
					success: function(result) {
						$('#exibirCards').html(result)
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
				
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
						
					}
				})
			}, 500);	

				
		}

				
		// function processoEditarTab(linha,processoId, sei, relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin) {
		// 	event.preventDefault()
		// 	event.stopPropagation()
		// 	$('#formEditarProcessoAte2023').attr("hidden",false)
		// 	$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
		// 	var listAvaliadores = avaliadores.split(",");
		// 	$('#cabecalhoAccordion').text("Editar o Processo:" + ' ' + processoId);
		// 	$("#btSalvarDiv").attr("hidden",false)
			
			
		// 	$('#pcModalidade').val(modalidade).trigger('change');

		// 	$('#pcNumSEI').val(sei);
		// 	$('#pcProcessoId').val(processoId);			
		// 	$('#pcTipoClassificacao').val(classificacao).trigger('change');
		// 	$('#pcNumRelatorio').val(relSei);
		// 	$('#pcOrigem').val(orgaoOrigem).trigger('change');
		// 	$('#pcDataInicioAvaliacao').val(dataInicio);
		// 	$('#pcDataInicioAvaliacaoAnterior').val(dataInicio);
		// 	$('#pcDataFimAvaliacao').val(dataFim);
		// 	$('#pcTipoAvaliado').val(processoAvaliado).trigger('change');
		// 	$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');

		// 	$('#pcOrgaoAvaliado').val(orgaoAvaliado).trigger('change');
		// 	$( "#pcProcessoId" ).focus();	
		// 	//var avaliadoresList = avaliadores;
		// 	//$('#pcAvaliadores').val([avaliadoresList]).trigger('change');
		// 	$('#pcCoordenador').val(coordenador).trigger('change');
		// 	$('#pcCoordNacional').val(coordNacional).trigger('change');
	
		// 	$('#pcTipoDemanda').val(tipoDemanda).trigger('change');
		// 	if (tipoDemanda == 'E'){
		// 		anoPacin = null;
		// 	}
		// 	$('#pcAnoPacin').val(anoPacin).trigger('change');	


		// 	var selectedValues = new Array();
		// 	$.each(listAvaliadores, function(index,value){
		// 		selectedValues[index] = value;
		// 	});
			
		// 	$('#pcAvaliadores').val(selectedValues).trigger('change');
		
		// 	$('#cadastroEditar').CardWidget('expand')
		
		// 	$('body')[0].scrollIntoView(true);

		

		// }

		// function processoVisualizar(processoId,sei,relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin) {
		// 	event.preventDefault()
		// 	event.stopPropagation()
		// 		$('#formEditarProcessoAte2023').attr("hidden",false)
		// 	var listAvaliadores = avaliadores.split(",");
		// 	$('#cabecalhoAccordion').text("Visualizando o Processo:" + ' ' + processoId);
		// 	$("#btSalvarDiv").attr("hidden",true);
		// 	$('#pcDataInicioAvaliacao').removeAttr('disabled');
			
		// 	$('#pcModalidade').val(modalidade).trigger('change');

		// 	$('#pcNumSEI').val(sei);
		// 	$('#pcProcessoId').val(processoId);			
		// 	$('#pcTipoClassificacao').val(classificacao).trigger('change');
		// 	$('#pcNumRelatorio').val(relSei);
		// 	$('#pcOrigem').val(orgaoOrigem).trigger('change');
		// 	$('#pcDataInicioAvaliacao').val(dataInicio);
		// 	$('#pcDataFimAvaliacao').val(dataFim);
		// 	$('#pcTipoAvaliado').val(processoAvaliado).trigger('change');
		// 	$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');

		// 	$('#pcOrgaoAvaliado').val(orgaoAvaliado).trigger('change');
		// 	$( "#pcProcessoId" ).focus();	
		// 	//var avaliadoresList = avaliadores;
		// 	//$('#pcAvaliadores').val([avaliadoresList]).trigger('change');
		// 	$('#pcCoordenador').val(coordenador).trigger('change');
		// 	$('#pcCoordNacional').val(coordNacional).trigger('change');
		// 	$('#pcTipoDemanda').val(tipoDemanda).trigger('change');
		// 	$('#pcAnoPacin').val(anoPacin).trigger('change');	

		

		// 	var selectedValues = new Array();
		// 	$.each(listAvaliadores, function(index,value){
		// 		selectedValues[index] = value;
		// 	});
			
		// 	$('#pcAvaliadores').val(selectedValues).trigger('change');
		
		// 	$('#cadastroEditar').CardWidget('expand')
		
		// 	$('body')[0].scrollIntoView(true);


		// }


	</script>


</body>





</html>
