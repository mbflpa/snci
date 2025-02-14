
<cfcomponent>
<cfprocessingdirective pageencoding = "utf-8">	

	<cffunction name="cardsProcessos" returntype="any" access="remote" hint="Criar os cards dos processos e envia para a páginas pc_CadastroProcesso">
	   
		<cfargument name="ano" type="string" required="true" />

		<cfquery name="rsProcCard" datasource="#application.dsn_processos#">
			SELECT DISTINCT pc_processos.*,pc_orgaos.pc_org_descricao,pc_orgaos.pc_org_sigla, pc_status.*,pc_avaliacao_tipos.pc_aval_tipo_descricao, right(pc_processo_id,4) as anoProcesso
							,CONCAT(
									'Macroprocesso:<strong> ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,'</strong>',
									'<br>N1:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,'</strong>',
									'<br>N2:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,'</strong>',
									'<br>N3:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN3,'</strong>', '.'
									) as tipoProcesso
			FROM   pc_processos 
			INNER JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
			INNER JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado =pc_orgaos.pc_org_mcu
			INNER JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id
			<cfif application.rsUsuarioParametros.pc_usu_perfil eq 11 OR application.rsUsuarioParametros.pc_usu_perfil eq 3>
				WHERE not pc_status_id IN ('2') 
			</cfif>
			<cfif application.rsUsuarioParametros.pc_usu_perfil eq 8>
                WHERE not pc_status_id IN ('2','5') and pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'	
			</cfif>
			<cfif arguments.ano neq 'TODOS'>
				AND right(pc_processo_id,4) = '#arguments.ano#'
			<cfelse>
				AND right(pc_processo_id,4) >= 2024
			</cfif>	
			ORDER BY pc_datahora_cadastro desc 	
		</cfquery>

		<style>
			#tabProcCards_wrapper #tabProcCards_paginate ul.pagination {
				justify-content: center!important;
			}			
		</style>
		
		

		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" style="padding:0px!important">
				<!-- /.card-header -->
				<div class="card-body" style="padding:0px!important">
					<form id="formAcomp" name="formAcomp" format="html"  style="height: auto;">
					
						<!--acordion-->
						<div id="accordionCadItemPainel" >
							<div id="accordionCadItemPainelCard" class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i>Processos Em Acompanhamento ou Finalizados
										</a>
									</h4>
								</div>
								<div id="collapseTwo" class="" data-parent="#accordion">							
									<div class="card-body" style="border: solid 3px #ffD400;width:100%">
										
										<div class="row" style="justify-content: space-around;">
											<cfif #rsProcCard.recordcount# eq 0 >
												<h5>Selecione o ano desejado ou clique em "TODOS" para visualizar todos os processos com status "ACOMPANHAMENTO" ou "FINALIZADO".</h5>
											</cfif>
											<cfif #rsProcCard.recordcount# neq 0 >
												<div class="col-sm-12">
													
														<table id="tabProcCards" class="table  " style="background: none;border:none;width:100%">
															<thead >
																<tr style="background: none;border:none">
																	<th style="background: none;border:none"></th>
																</tr>
															</thead>
															
															<tbody class="grid-container" >
																<cfloop query="rsProcCard" >
																	<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
																		SELECT pc_avaliadores.pc_avaliador_matricula FROM pc_avaliadores WHERE pc_avaliador_id_processo = '#pc_processo_id#' 
																	</cfquery>
																	<cfset avaliadores = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>

																	<cfquery name="rsObjetivoEstrategico" datasource="#application.dsn_processos#">
																		SELECT pc_objetivo_estrategico.pc_objEstrategico_id FROM pc_processos_objEstrategicos 
																		INNER JOIN pc_objetivo_estrategico ON pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
																		WHERE pc_processos_objEstrategicos.pc_processo_id = '#pc_processo_id#'
																	</cfquery>
																	<cfset objetivosEstrategicos = ValueList(rsObjetivoEstrategico.pc_objEstrategico_id,',')>

																	<cfquery name="rsRiscoEstrategico" datasource="#application.dsn_processos#">
																		SELECT pc_risco_estrategico.pc_riscoEstrategico_id FROM pc_processos_riscosEstrategicos 
																		INNER JOIN pc_risco_estrategico ON pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
																		WHERE pc_processos_riscosEstrategicos.pc_processo_id = '#pc_processo_id#'
																	</cfquery>
																	<cfset riscosEstrategicos = ValueList(rsRiscoEstrategico.pc_riscoEstrategico_id,',')>

																	<cfquery name="rsIndEstrategico" datasource="#application.dsn_processos#">
																		SELECT pc_indicador_estrategico.pc_indEstrategico_id FROM pc_processos_IndEstrategicos 
																		INNER JOIN pc_indicador_estrategico ON pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_IndEstrategicos.pc_indEstrategico_id
																		WHERE pc_processos_IndEstrategicos.pc_processo_id = '#pc_processo_id#'
																	</cfquery>
																	<cfset indEstrategicos = ValueList(rsIndEstrategico.pc_indEstrategico_id,',')>
																	
																	<cfset aux_sei = Trim('#rsProcCard.pc_num_sei#')>
																	<cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
																	
																	<tr style="width:270px;border:none;">
																		<td style="background: none;border:none;white-space:normal!important;" >	
																			<section class="content" >
																					<div id="processosAcompanhamento" class="container-fluid" >

																							<div class="row">
																								<div id="cartao" style="width:270px;" >
																								
																									<!-- small card -->
																									<div class="small-box " style="<cfoutput>#pc_status_card_style_header#</cfoutput> font-weight: normal;color:#fff">
																										<cfif #pc_modalidade# eq "A">
																											<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:10px;"><strong>A</strong></span>
																										<cfelseif #pc_modalidade# eq "E">
																											<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:5px;"><strong>E</strong></span>	
																										</cfif>
																										<div class="ribbon-wrapper ribbon-lg" >
																											<div class="ribbon " style="font-size:12px;left:8px;<cfoutput>#pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#pc_status_card_nome_ribbon#</cfoutput></div>
																										</div>
																										

																										<div class="card-header" style="height:130px;width:250px;font-weight: normal!important;">
																											<p style="font-size:0.8em;margin-bottom: 0rem!important;"><cfoutput>Processo SNCI n°: #pc_processo_id#</cfoutput></p>
																											<p style="font-size:0.8em;margin-bottom: 0rem!important;"><cfoutput>Processo SEI n°: #aux_sei#</cfoutput></p>
																											<p style="font-size:0.8em;margin-bottom: 0rem!important;"><cfoutput>#pc_org_sigla#</cfoutput></p>
																											<cfif pc_num_avaliacao_tipo neq 445 AND pc_num_avaliacao_tipo neq 2>
																												<cfif pc_aval_tipo_descricao neq ''>
																													<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_descricao#</cfoutput></p>
																												<cfelse>
																													<p class="text-ellipsis" ><cfoutput>#tipoProcesso#</cfoutput></p>
																												</cfif>
																											<cfelse>
																												<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_nao_aplica_descricao#</cfoutput></p>
																											</cfif>
																											
																										</div>
																										<div class="icon">
																											<i class="fas fa-search" style="opacity:0.6;left:100px;top:30px"></i>
																										</div>

																										<a href="##"  target="_self" class="small-box-footer"   >
																											<div style="display:flex;justify-content: space-around;" >
																												<input id="pcNumProcessoCard" name="pcNumProcessoCard" type="text" hidden >												
																												<i id="btEdit" class="fas fa-edit efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'"  style="cursor: pointer;z-index:100;font-size:20px" 
																												
																												onclick="javascript:processoEditarCard(<cfoutput>'#pc_num_status#','#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#pc_iniciarBloqueado#','#objetivosEstrategicos#','#riscosEstrategicos#','#indEstrategicos#')</cfoutput>;"
																												
																												data-toggle="tooltip"  tilte="Editar"></i>
																												<cfif pc_num_status neq 3>
																													<i  class="fas fa-boxes-packing efeito-grow" onclick="javascript:mostraCadastroItem(<cfoutput>'#pc_processo_id#','#anoProcesso#',</cfoutput>);"  style="cursor: pointer;z-index:100;font-size:20px"    title="Mostrar próximos passos." ></i>
																												</cfif>
																											</div>
																										</a>
																											
																									</div>
																								</div>
																							</div>
																						
																					</div>
																			</section>
																		</td>
																	</tr>
																</cfloop>
															</tbody>
														</table>
													
													

												</div>
											</cfif>
										</div>
									</div>									
								</div> <!--fim collapseTwo -->
							</div><!--fim card card-success -->	
						</div><!--fim acordion -->
					</form><!-- fim formAcomp -->					
				</div><!-- fim card-body -->	

				<div id="tabAvaliacoesAcompanhamento"></div>
			</div>
		</section>


		
		



		<script language="JavaScript">
			

			$(function () {
				$("#tabProcCards").DataTable({
					"destroy": true,
					"ordering": false,
				    "stateSave": true,
					"responsive": true, 
					"lengthChange": true, 
					"autoWidth":true,
					"sScrollY": "50vh",
					"scrollCollapse": true,
					"dom": 
							"<'row'<'col-sm-12 text-right'f>>" +
							"<'row'<'col-sm-4'l><'col-sm-4'p><'col-sm-4 text-right'i>>" +
							"<'row'<'col-sm-12'tr>>" ,
					"lengthMenu": [
						[10, 25, 50, -1],
						[10, 25, 50, 'All'],
					]
				})
					
			});

			function processoEditarCard(pc_num_status, processoId, sei, relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin, bloquear, objetivoEstrategico, riscoEstrategico, indEstrategico) {
				event.preventDefault()
				event.stopPropagation()
				$('#modalOverlay').modal('show');
				$('#formEditarProcesso').attr("hidden",true)
				$('#divFormCadProcesso').html('')
				

				$('#tabItemsDiv').html('')
				$('#cadAvaliacaoForm').html('');
				
				$.ajax({
					url: 'cfc/pc_cfcProcessos.cfc',
					data: {
						method: 'formCadProc',
					},
					async: false
				})
				.done(function(response){
					$("#divFormCadProcesso").html(response);
					$('.step-trigger').show();
				})//fim done
				.fail(function(xhr, ajaxOptions, thrownError) {
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
						var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
									+ '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
						const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
						
						swalWithBootstrapButtons.fire(
							{...erroSistema}
						)
					});
				})//fim fail

				
				setTimeout(function() {	
					
					$('#cabecalhoAccordion').text("Editar o Processo:" + ' ' + processoId);
					
					var listAvaliadores = avaliadores.split(",");
					var listObjetivoEstrategico = objetivoEstrategico.split(",");
					var listRiscoEstrategico = riscoEstrategico.split(",");
					var listIndEstrategico = indEstrategico.split(",");
					
					$('#infoTipoCadastro').html("Editando o Processo <strong>" + processoId + "</strong>");
                    $('#mensagemFinalizar').html('<h5>Clique no botão "Salvar" para <span style="color: green;font-size: 1.5rem">EDITAR</span> o processo'  + ' <span style="color: green;font-size: 1.5rem"><strong>' + processoId + '</strong></span></h5>');
					$("#btSalvar").attr("hidden",false);
					$("#mensagemSalvar").attr("hidden",false);

					
					
					$('#pcModalidade').val(modalidade).trigger('change');

					$('#pcNumSEI').val(sei).trigger('change');
					$('#pcProcessoId').val(processoId).trigger('change');			
					$('#pcTipoClassificacao').val(classificacao).trigger('change');
					$('#pcNumRelatorio').val(relSei).trigger('change');
					$('#pcOrigem').val(orgaoOrigem).trigger('change');
					$('#pcDataInicioAvaliacao').val(dataInicio).trigger('change');
					$('#pcDataInicioAvaliacaoAnterior').val(dataInicio).trigger('change');
					$('#pcDataFimAvaliacao').val(dataFim).trigger('change');

					$('#pcOrgaoAvaliado').val(orgaoAvaliado).trigger('change');
					$('#pcOrgaoAvaliadoAnterior').val(orgaoAvaliado).trigger('change');
					$( "#pcProcessoId" ).focus();	
					
					if(coordenador==''){
						$('#pcCoordenador').val(0).trigger('change');
					}else{
						$('#pcCoordenador').val(coordenador).trigger('change');
					}

					if(coordNacional==''){
						$('#pcCoordNacional').val(0).trigger('change');
					}else{
						$('#pcCoordNacional').val(coordNacional).trigger('change');
					}
					
					
					
					//$('#pcDataInicioAvaliacao').attr('disabled', 'disabled');
					//$('#pcOrgaoAvaliado').attr('disabled', 'disabled');

					$('#pcTipoDemanda').val(tipoDemanda).trigger('change');
					
					if (tipoDemanda == 'E'){
						anoPacin = null;
					}

					$('#pcAnoPacin').val(anoPacin).trigger('change');
					
					var selectedValuesAvaliadores = new Array();
					$.each(listAvaliadores, function(index,value){
						selectedValuesAvaliadores[index] = value;
					});
					
					$('#pcAvaliadores').val(selectedValuesAvaliadores).trigger('change');

					var selectedValuesObjetivoEstrategico = new Array();
					$.each(listObjetivoEstrategico, function(index,value){
						selectedValuesObjetivoEstrategico[index] = value;
					});

					$('#pcObjetivoEstrategico').val(selectedValuesObjetivoEstrategico).trigger('change');

					var selectedValuesRiscoEstrategico = new Array();
					$.each(listRiscoEstrategico, function(index,value){
						selectedValuesRiscoEstrategico[index] = value;
					});

					$('#pcRiscoEstrategico').val(selectedValuesRiscoEstrategico).trigger('change');

					var selectedValuesIndEstrategico = new Array();
					$.each(listIndEstrategico, function(index,value){
						selectedValuesIndEstrategico[index] = value;
					});

					$('#pcIndEstrategico').val(selectedValuesIndEstrategico).trigger('change');
					
					$('#cadastro').CardWidget('expand')

					$('#pcBloquear').val(bloquear).trigger('change');
					if(pc_num_status != 3){//Se o cadastro processo não for "INICIADO" = 3
						$('#pcBloquear').prop('disabled', true);// Bloqueia o campo com id pcBloquear
						$('#pcBloquearLabel').text('Processo Bloqueado no Cadastro?');// Altera o label do campo com id pcBloquearLabel
						
					}
					
					//popula os selects dinâmicos	
					$.ajax({
						url: 'cfc/pc_cfcAvaliacoes.cfc',
						data: {
							method: 'getAvaliacaoTipos',
						},
						dataType: "json",
						method: 'GET',
						async: false
					})
					.done(function(data) {
						
						// Define os níveis de dados e nomes dos labels
						let dataLevels = ['MACROPROCESSOS', 'PROCESSO_N1', 'PROCESSO_N2', 'PROCESSO_N3'];
						let labelNames = ['Macroprocesso', 'Processo N1', 'Processo N2', 'Processo N3'];
						let outrosOptions = [
							{ dataLevel:'PROCESSO_N3', text: "OUTROS", value: 0 },
						];
						// Inicializa os selects dinâmicos
						initializeSelects('#dados-container', data, dataLevels, 'ID', labelNames, 'idTipoAvaliacao',outrosOptions);
						const exampleID = processoAvaliado; // Mude para o ID desejado
						populateSelectsFromID(data, exampleID, dataLevels, 'idTipoAvaliacao');

						$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');
					
					
						$('#cadastro').CardWidget('expand')
				
						
					})
					.fail(function(error) {
						$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(error)
					});
					//fim popula os selects dinâmicos

					$('#divFormCadProcesso').attr("hidden",false)

                    $('html, body').animate({
						scrollTop: $('#cadastro').offset().top - 60
					},'slow');
				
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
				}, 500);
			}

			function mostraCadastroItem(numProcesso, anoProcesso) {
                //cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()
                let editarItemForm ='';
				
				$('#formEditarProcesso').attr("hidden",true)
				$('#divFormCadProcesso').html('')
				
			
				$('#modalOverlay').modal('show')
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcProcessos_editar.cfc",
							data:{
								method: "editarItemForm",
								numProcesso: numProcesso
							},
							async: false,
							success: function(response) {
								
								$('#cadAvaliacaoForm').html(response);
								$('html, body').animate({ scrollTop: ($('#cadAvaliacaoForm').offset().top - 80)} , 1000);
								
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
						});
					}, 500);
				
						
			}
			
		</script>
	</cffunction>



	<cffunction name="editarItemForm"   access="remote"  returntype="any" hint="Insere o formulario de cadastro do título da avaliação na páginas pc_CadastroAvaliacaoPainel">


        <cfargument name="numProcesso" type="string" required="true"/>

       

		<cfquery name="rsProcForm" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado, pc_orgaos.pc_org_mcu,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,CONCAT(
						'Macroprocesso: ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
						' -> N1: ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
						' -> N2: ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,
						' -> N3: ', pc_avaliacao_tipos.pc_aval_tipo_processoN3, '.'
						) as tipoProcesso

			FROM        pc_processos INNER JOIN
						pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
						pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
						pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
						pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
						pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
			WHERE  pc_processo_id = '#arguments.numProcesso#'														
		</cfquery>
	

		<cfquery name="rs_OrgAvaliado" datasource="#application.dsn_processos#">
			SELECT pc_orgaos.*
			FROM pc_orgaos
			WHERE  (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#rsProcForm.pc_num_orgao_avaliado#' or pc_org_mcu ='#rsProcForm.pc_num_orgao_avaliado#')
			ORDER BY pc_org_sigla
		</cfquery>

		<cfquery name="rsAvaliacaoTipoControle" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_tipoControle.*
			FROM pc_avaliacao_tipoControle
			WHERE  pc_aval_tipoControle_status = 'A'
		</cfquery>

		<cfquery name="rsAvaliacaoCategoriaControle" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_categoriaControle.*
			FROM pc_avaliacao_categoriaControle
			WHERE  pc_aval_categoriaControle_status = 'A'
		</cfquery>

		<cfquery name="rsAvaliacaoRisco" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_risco.*
			FROM pc_avaliacao_risco
			WHERE  pc_aval_risco_status = 'A'
		</cfquery>

		<cfquery name="rsCriteriosRef" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_criterioReferencia.*
			FROM pc_avaliacao_criterioReferencia
			WHERE  pc_aval_criterioRef_status = 'A'
		</cfquery>
		
		


		<!DOCTYPE html>
		<html lang="pt-br">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">

			<!-- animate.css -->
			<link rel="stylesheet" href="dist/css/animate.min.css">
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
				}

				legend {
					font-size: 0.8rem!important;
					color: #fff!important;
					background-color: #0083ca!important;
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
				}

				legend {
					font-size: 0.8rem!important;
					color: #fff!important;
					background-color: #0083ca!important;
					border: 1px solid #ced4da!important;
					border-radius: 5px!important;
					padding: 5px!important;
					width: auto!important;
				}

				/* Evita que campos de datas e textos tenham o ícone verde */
				.form-control[type="text"].is-valid {
					background-image: none !important;
					background-position:0 !important;
					background-size: 0 !important;
					padding-right: 10px !important;
				}	
				/* Evita que campos de datas e textos tenham o ícone verde */
				.form-control[type="text"].is-invalid {
					background-image: none !important;
					background-position:0 !important;
					background-size: 0 !important;
					padding-right: 10px !important;
				}

				/* Evita que campos de datas tenham o ícone verde */
				.form-control[type="date"].is-valid {
					background-image: none !important;
					background-position:0 !important;
					background-size: 0 !important;
					padding-right:0.75rem !important;
				}

				/* Evita que campos de datas tenham o ícone verde */
				.form-control[type="date"].is-invalid {
					background-image: none !important;
					background-position:0 !important;
					background-size: 0 !important;
					padding-right:0.75rem !important;
				}

				/* Evita que campos de datas e textos tenham o ícone verde */
				.form-control[type="input"].is-valid {
					background-image: none !important;
					/*background-position:0 !important;*/
					/*background-size: 0 !important;*/
					padding-right: 10px !important;
				}	

				/* Evita que campos de datas tenham o ícone verde */
				.form-control[type="input"].is-invalid {
					background-image: none !important;
					/*background-position:0 !important;*/
					/*background-size: 0 !important;*/
					padding-right:0.75rem !important;
				}

				/* Evita que campos de datas e textos tenham o ícone verde */
				.form-control[type="textarea"].is-valid {
					background-image: none !important;
					padding-right: 10px !important;
				}	
				/* Evita que campos de datas e textos tenham o ícone verde */
				.form-control[type="textarea"].is-invalid {
					background-image: none !important;
					padding-right: 10px !important;
				}
			

				.cardBodyStepper {
						border: solid 1px rgba(108, 117, 125, 0.3);
						border-radius: 0.5rem;
						box-shadow: 5px 5px 5px rgba(0, 0, 0, 0.05);
				}

				.small-input{
					width: 70px !important;
				}
				
				.btnValorNaoSeAplica{
					border-radius: 25px 0 0 25px !important;
				}

				.btnValorQuantificado{
					border-radius: 0 25px 25px 0 !important;
				}
				

				



			</style>
			
		</head>
		<body >

			<form id="formEditarItem"  class="needs-validation was-validated" name="formEditarItem" format="html"  style="height: auto;padding-left:25px;padding-right:25px;">
				<div class="modal fade" id="modal-danger">
					<div class="modal-dialog">
						<div class="modal-content bg-danger">
							<div class="modal-header">
								<h4 class="modal-title">Danger Modal</h4>
								<button type="button" class="close" data-dismiss="modal" aria-label="Close">
								<span aria-hidden="true">&times;</span>
								</button>
							</div>
							<div class="modal-body">
								<p>One fine body&hellip;</p>
							</div>
							<div class="modal-footer justify-content-between">
								<button type="button" class="btn btn-outline-light" data-dismiss="modal">Fechar</button>
							</div>
						</div>
						<!-- /.modal-content -->
					</div>
					<!-- /.modal-dialog -->
				</div>
				<!-- /.modal -->
				<cfset aux_sei = Trim('#rsProcForm.pc_num_sei#')>
				<cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
			
				<section class="content" id="infoProcesso">
					<div id="processosCadastrados" class="container-fluid" >
						<div class="row">
							<div id="cartao" style="width:100%;" >
								<!-- small card -->
								<cfoutput>
									<div class="small-box " style=" font-weight: bold;">
										<div class="ribbon-wrapper ribbon-xl" >
											<div class="ribbon " style="font-size:18px!important;left:8px;<cfoutput>#rsProcForm.pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#rsProcForm.pc_status_card_nome_ribbon#</cfoutput></div>
										</div>
										<div class="card-header" style="height:auto">
											<p style="font-size: 1.8em;">Processo SNCI n°: <span style="color:##0692c6;margin-right:30px">#rsProcForm.pc_processo_id#</span> Órgão Avaliado: <span style="color:##0692c6">#rsProcForm.siglaOrgAvaliado#</span></p>
											<p style="font-size: 1.3em;">Origem: <span style="color:##0692c6;margin-right:30px">#rsProcForm.siglaOrgOrigem#</span>
											<cfif #rsProcForm.pc_modalidade# eq 'A' or #rsProcForm.pc_modalidade# eq 'E'>
												<span >Processo SEI n°: </span> <span style="color:##0692c6">#aux_sei#</span> 
												<span style="margin-left:20px">Relatório n°:</span> 
												<span style="color:##0692c6">#rsProcForm.pc_num_rel_sei#</span></p>
											</cfif>	
											<cfif rsProcForm.pc_num_avaliacao_tipo neq 2 and rsProcForm.pc_num_avaliacao_tipo neq 445>
												<cfif rsProcForm.pc_aval_tipo_descricao neq ''>
													<p style="font-size: 1.3em;">Tipo de Avaliação: <span style="color:##0692c6">#rsProcForm.pc_aval_tipo_descricao#</span></p>
												<cfelse>
													<p style="font-size: 1.3em;margin-right:30px">Tipo de Avaliação: <span style="color:##0692c6; ">#rsProcForm.tipoProcesso#</span></p>
												</cfif>
											<cfelse>
												<p style="font-size: 1.3em;">Tipo de Avaliação: <span style="color:##0692c6">#rsProcForm.pc_aval_tipo_nao_aplica_descricao#</span></p>
											</cfif>
											
											
										
											<cfif #rsProcForm.pc_modalidade# eq 'A' or #rsProcForm.pc_modalidade# eq 'E'>
											
												<div id="actions" class="row" >
													<div class="col-lg-12" align="center">
														<div class="btn-group w-30">
															<span id="relatorios" class="btn btn-success col fileinput-button" style="background:##0083CA">
																<i class="fas fa-upload"></i>
																<span style="margin-left:5px">Clique aqui para anexar o Relatório do Processo e Anexos I, II e III em PDF (1° passo)</span>
															</span>																	
														</div>
													</div>
												</div>
												
												<div class="table table-striped files" id="previewsRelatorio">
													<div id="templateRelatorio" class="row mt-2">
														<div class="col-auto">
															<span class="preview"><img src="data:," alt="" data-dz-thumbnail /></span>
														</div>
														<div class="col d-flex align-items-center">
															<p class="mb-0">
															<span class="lead" data-dz-name></span>
															(<span data-dz-size></span>)
															</p>
															<strong class="error text-danger" data-dz-errormessage></strong>
														</div>
														<div class="col-4 d-flex align-items-center" >
															<div class="progress progress-striped active w-100" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" >
																<div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress ></div>
															</div>
														</div>
														
													</div>
												</div>

												<div id="anexoRelatorioDiv"></div>
											
											</cfif>	
										</div>									
									</div>
								</cfoutput>



							</div>
						</div>

						
					</div>
				</section>

			</form><!-- fim formCadAvaliacao -->
				
			<input id="pcProcessoId" value="<cfoutput>#rsProcForm.pc_processo_id#</cfoutput>" hidden>

			<div hidden id="accordionTitulo"  style="display: flex; justify-content: left;">
				<div  id="cadastro" class="card card-primary collapsed-card"   style="margin-left: 25px;">
					<div class="card-header text-left" style="background-color: #0083ca;color:#fff;">
						<a  id="btnCadastroItem" class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:16px;" data-card-widget="collapse">
							<button  type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
							</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um item (2° Passo)</span>
						</a>
					</div>

					<input id="pc_aval_id" hidden>
					<div class="card-body" style="border: solid 3px #0083ca;" >
					
						<div class="card card-default">
							<div class="card-body p-0">
								
								<h6  class="font-weight-light text-center" style="top:-15px;font-size:20px!important;color:#00416B;position:absolute;width:100%;left:50%;transform:translateX(-50%);">
									<span id="infoTipoCadastro" style=" background-color:#fff;border:1px solid rgb(229, 231, 235);padding-left:7px;padding-right:7px;border-radius: 5px;">Cadastrando Novo Item</span>
								</h6>
								<div class="bs-stepper" >
									<div class="bs-stepper-header" role="tablist" >
										<div class="step" data-target="#aval_testeControle">
											<button type="button" class="step-trigger animate__animated animate__bounce" role="tab" aria-controls="aval_testeControle" id="aval_testeControle-trigger">
												<span class="bs-stepper-circle">1</span>
												<span class="bs-stepper-label " id="aval_testeControleLabel"></span>
											</button>
										</div>

										<div class="line"></div>

										<div class="step" data-target="#aval_item">
											<button type="button" class="step-trigger" role="tab" aria-controls="aval_item" id="aval_item-trigger">
												<span class="bs-stepper-circle">2</span>
												<span class="bs-stepper-label" id="aval_itemLabel"></span>
											</button>
										</div>

										<div class="line"></div>

										<div class="step" data-target="#aval_riscoCoso">
											<button type="button" class="step-trigger" role="tab" aria-controls="aval_riscoCoso" id="aval_riscoCoso-trigger">
												<span class="bs-stepper-circle">3</span>
												<span class="bs-stepper-label" id="aval_riscoCosoLabel"></span>
											</button>
										</div>


										<div class="line"></div>

										<div class="step" data-target="#aval_valorEstimado">
											<button type="button" class="step-trigger" role="tab" aria-controls="aval_valorEstimado" id="aval_valorEstimado-trigger">
												<span class="bs-stepper-circle">4</span>
												<span class="bs-stepper-label" id="aval_valorEstimadoLabel"></span>
											</button>
										</div>

										<div class="line"></div>

										<div class="step" data-target="#aval_criteriosReferencias">
											<button type="button" class="step-trigger" role="tab" aria-controls="aval_criteriosReferencias" id="aval_criteriosReferencias-trigger">
												<span class="bs-stepper-circle">5</span>
												<span class="bs-stepper-label" id="aval_criteriosReferenciasLabel"></span>
											</button>
										</div>

										<div class="line"></div>

										<div class="step" data-target="#Finalizar">
											<button type="button" class="step-trigger" role="tab" aria-controls="finalizar" id="finalizar-trigger">
												<span class="bs-stepper-circle">6</span>
												<span class="bs-stepper-label" id="finalizarLabelLabel"></span>
											</button>
										</div>

										

									</div>
								
									<div class="bs-stepper-content">
										<form   id="formAval_testeControle" name="formAval_testeControle"   onsubmit="return false" novalidate>
											<div id="aval_testeControle" class="content " role="tabpanel" aria-labelledby="aval_testeControle-trigger" >
												<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
													<div class="row  " >
														<div class="col-sm-12">
															<div class="form-group">
																<label for="pcTeste" >Teste (Pergunta do Plano):</label>
																<textarea id="pcTeste" name="pcTeste" class="form-control" rows="2"  inputmode="text" placeholder="Informe o teste realizado (pergunta do plano)..."></textarea>
																<span id="pcTesteCounter" class="badge badge-secondary"></span>
															</div>
														</div>

														

														
														<div class="col-sm-12">
															<div class="form-group">
																<label for="pcControleTestado" >Controle Testado:</label>
																<textarea id="pcControleTestado" name="pcControleTestado" class="form-control" rows="2"  inputmode="text" placeholder="Informe o controle testado..."></textarea>
																<span id="pcControleTestadoCounter" class="badge badge-secondary"></span>
															</div>
														</div>	

														<div class="col-sm-6">
															<div class="form-group">
																<label for="pcAvaliacaoTipoControle" >Tipo de Controle:</label>
																<select id="pcAvaliacaoTipoControle" name="pcAvaliacaoTipoControle" class="form-control" multiple="multiple" placeholder="Selecione...">
																	<cfoutput query="rsAvaliacaoTipoControle">
																		<option value="#pc_aval_tipoControle_id#">#pc_aval_tipoControle_descricao#</option>
																	</cfoutput>
																</select>
															</div>
														</div>

														<div class="col-sm-6">
															<div class="form-group">
																<label for="pcAvaliacaoCategoriaControle" >Categoria do Controle Testado:</label>
																<select id="pcAvaliacaoCategoriaControle" name="pcAvaliacaoCategoriaControle" class="form-control" multiple="multiple">
																	<cfoutput query="rsAvaliacaoCategoriaControle">
																		<option value="#pc_aval_categoriaControle_id#">#pc_aval_categoriaControle_descricao#</option>
																	</cfoutput>
																</select>
															</div>
														</div>


													</div>
												</div>
												<div style="margin-top:10px;display:flex;justify-content:space-between">
													<button class="btn btn-primary" onclick="inicializarValidacaoStep1();" >Próximo</button>
													<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroItem(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
												</div>
											</div>
										</form>

										<form   id="formAval_item" name="formAval_item"   onsubmit="return false" novalidate>
											<div id="aval_item" class="content" role="tabpanel" aria-labelledby="aval_item-trigger">
												<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
													<div class="row  " >
														<div class="col-sm-1">
															<div class="form-group">
																<label for="pcNumSituacaoEncontrada" >N°:</label>
																<input id="pcNumSituacaoEncontrada"  name="pcNumSituacaoEncontrada" type="text" class="form-control small-input"  inputmode="text" >													
															</div>
														</div>
														
														<div class="col-sm-11">
															<div class="form-group">
																<label for="pcTituloSituacaoEncontrada" >Título da Situação Encontrada:</label>
																<textarea id="pcTituloSituacaoEncontrada" name="pcTituloSituacaoEncontrada" class="form-control" rows="1"  inputmode="text" placeholder="Informe o título da situação encontrada..."></textarea>
																<span id="pcTituloSituacaoEncontradaCounter" class="badge badge-secondary"></span>
															</div>
														</div>

														<div class="col-sm-12">
															<div class="form-group">
																<label for="pcSintese" >Síntese:</label>
																<textarea id="pcSintese" name="pcSintese" class="form-control" rows="2"  inputmode="text" placeholder="Informe a síntese do ponto (achado)..."></textarea>
																<span id="pcSinteseCounter" class="badge badge-secondary"></span>
															</div>
														</div>	

														<div class="col-sm-12">
															<div class="form-group">
																<label for="pcAvaliacaoRisco" >Risco Identificado:</label>
																<select id="pcAvaliacaoRisco" name="pcAvaliacaoRisco" class="form-control" multiple="multiple">
																	<cfoutput query="rsAvaliacaoRisco">
																		<option value="#pc_aval_risco_id#">#pc_aval_risco_descricao#</option>
																	</cfoutput>
																	<option value="0">Outros</option>
																</select>
															</div>
														</div>

														<div id="pcAvaliacaoRiscoOutrosDescricaoDiv" class="form-group col-sm-12 animate__animated animate__fadeInDown" hidden style="margin-top:10px;padding-left: 0;">
															<label for="pcAvaliacaoRiscoOutrosDesc" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Descrição do Risco:</label>
															<div class="input-group date" id="reservationdate" data-target-input="nearest">
																<input id="pcAvaliacaoRiscoOutrosDesc" name="pcAvaliacaoRiscoOutrosDesc" class="form-control" placeholder="Descreva o PROCESSO..." style="border-radius: 4px;  padding: 10px; box-sizing: border-box; width: 100%;">
																
															</div>
															<span id="pcAvaliacaoRiscoOutrosDescCharCounter" class="badge badge-secondary"></span>
															<div id="risciOutrosAlert" class="alert alert-info col-sm-12 animate__animated animate__zoomInDown animate__delay-1s" style="text-align: center;font-size:1.2em;margin-top:5px">
																Atenção: Ao finalizar o cadastro deste item, este novo risco descrito acima também será cadastrado e disponibilizado para seleção em futuros itens.
															</div>
														</div>

														<div class="col-sm-5">
															<div class="form-group">
																<label for="pcTipoClassificacao" >Classificação:</label>
																<select id="pcTipoClassificacao" name="pcTipoClassificacao" class="form-control" >
																	<option selected="" disabled="" value="">Selecione a Classificação...</option>
																	<option value="L">Leve</option>
																	<option value="M">Mediana</option>		
																	<option value="G">Grave</option>															
																</select>
															</div>
														</div>

													</div>

													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<div>	
															<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
															<button class="btn btn-primary" onclick="inicializarValidacaoStep2()">Próximo</button>
														</div>
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroItem(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
													</div>
												</div>
											</div>
										</form>

										<form  id="formAval_riscoCoso" name="formAval_riscoCoso"   onsubmit="return false" novalidate>
											<div id="aval_riscoCoso" class="content" role="tabpanel" aria-labelledby="aval_riscoCoso-trigger">
												<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
													<div class="row  " >
														<div class="col-sm-12">
															<fieldset >
																<legend >COSO 2023:</legend>
																<div class="form-group">
																	<input id="idCoso" hidden></input>
																	
																	<div id="dados-container-coso" class="dados-container">
																		
																	</div>
																	
																</div>
															</fieldset>
														</div>
													</div>
													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<div>	
															<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
															<button class="btn btn-primary" onclick="inicializarValidacaoStep3()">Próximo</button>
														</div>
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroItem(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
													</div>
												</div>
											</div>
										</form>

										<form id="formAval_valorEstimado" name="formAval_valorEstimado"   onsubmit="return false" novalidate>
											<div id="aval_valorEstimado" class="content" role="tabpanel" aria-labelledby="aval_valorEstimado-trigger">
												<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
													<div class="row  " >
													
														<div class="col-sm-12">
															<fieldset style="padding:0px!important;min-height: 90px;">
																<legend style="margin-left:20px">Potencial Valor Estimado a Recuperar:</legend>
																<div class="form-group d-flex align-items-center" style="margin-left:20px">
																	
																	<div id="btn_groupValorRecuperar" name="btn_groupValorRecuperar" class="btn-group mr-4" role="group" aria-label="Basic example">
																		<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplica" id="btn-nao-aplica-recuperar" style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
																		<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificado" id="btn-quantificado-recuperar" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Quantificado</button>
																	</div>
																	<div>
																		<input id="pcValorRecuperar" name="pcValorRecuperar" style="display: none;margin-right:10px;height: 29px;" type="text" class="form-control money" inputmode="text" placeholder="R$ 0,00">
																	</div>
																</div>
															</fieldset>
														</div>
															

														<div class="col-sm-12">	
															<fieldset style="margin-top:20px;padding:0px!important">
																<legend style="margin-left:20px">Potencial Valor Estimado em Risco ou Valor Envolvido:</legend>
																<div class="form-group d-flex align-items-center"  style="margin-left:20px">
																	<div id="btn_groupValorRisco" name="btn_groupValorRisco" class="btn-group mr-4" role="group" aria-label="Basic example">
																		<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplica" id="btn-nao-aplica-risco" style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
																		<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificado" id="btn-quantificado-risco" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Quantificado</button>
																	</div>
																	<div>
																		<input id="pcValorRisco" name="pcValorRisco" style="display: none;margin-right:10px;height: 29px;" type="text" class="form-control money" inputmode="text" placeholder="R$ 0,00">
																	</div>
																</div>
															</fieldset>
														</div>	
														<div class="col-sm-12">	
															<fieldset style="margin-top:20px;padding:0px!important">
																<legend style="margin-left:20px">Potencial Valor Estimado Não Planejado/Extrapolado/Sobra:</legend>
																<div class="form-group d-flex align-items-center"  style="margin-left:20px">
																	<div id="btn_groupValorNaoPlanejado" name="btn_groupValorNaoPlanejado" class="btn-group mr-4" role="group" aria-label="Basic example">
																		<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplica" id="btn-nao-aplica-NaoPlanejado" style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
																		<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificado" id="btn-quantificado-NaoPlanejado" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Quantificado</button>
																	</div>
																	<div>
																		<input id="pcValorNaoPlanejado" name="pcValorNaoPlanejado" style="display: none;margin-right:10px;height: 29px;" type="text" class="form-control money" inputmode="text" placeholder="R$ 0,00">
																	</div>
																</div>
															</fieldset>
															
														</div>															
														
													</div>
													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<div>	
															<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
															<button class="btn btn-primary" onclick="inicializarValidacaoStep4()">Próximo</button>
														</div>
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroItem(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
													</div>
												</div>
											</div>
										</form>		

										<form id="formAval_criteriosReferencias" name="formAval_criteriosReferencias"   onsubmit="return false" novalidate>
											<div id="aval_criteriosReferencias" class="content" role="tabpanel" aria-labelledby="aval_criteriosReferencias-trigger">
												<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
													<div class="row  " >
														<div class="col-sm-12">
															<div class="form-group">
																<label for="pcCriterioRef" >Critérios e Referências Normativas:</label>
																<select id="pcCriterioRef" name="pcCriterioRef" class="form-control" >
																	<option value="" disabled selected></option>
																	<option value="0" >Outros</option>
																	<cfoutput query="rsCriteriosRef">
																		<option value="#pc_aval_criterioRef_id#">#pc_aval_criterioRef_descricao#</option>
																	</cfoutput>
																</select>
															</div>
														</div>

														<div id="pcCriterioRefOutrosDescricaoDiv" class="form-group col-sm-12 animate__animated animate__fadeInDown" hidden style="margin-top:10px;">
															<label for="pcCriterioRefOutrosDesc" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Descrição dos Critérios e Referências Normativas:</label>
															<div class="input-group date" id="reservationdate" data-target-input="nearest">
																<textarea id="pcCriterioRefOutrosDesc" name="pcCriterioRefOutrosDesc" class="form-control" rows="3"  inputmode="text" placeholder="Informe os Critérios e Referências Normativas..."></textarea>
															</div>
															<span id="pcCriterioRefOutrosDescCharCounter" class="badge badge-secondary"></span>
															<div id="pcCriterioRefOutrosAlert" class="alert alert-info col-sm-12 animate__animated animate__zoomInDown animate__delay-1s" style="text-align: center;font-size:1.2em;margin-top:5px">
																Atenção: Ao finalizar o cadastro deste item, este novo critério/referência descrito acima também será cadastrado e disponibilizado para seleção em futuros itens.
															</div>
														</div>
													</div>
													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<div>	
															<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
															<button class="btn btn-primary" onclick="inicializarValidacaoStep5()">Próximo</button>
														</div>
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroItem(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
													</div>
												</div>
											</div>
										</form>
										
										<form   id="formFinalizar" name="formFinalizar"  onsubmit="return false" novalidate>
											<div id="Finalizar" class="content" role="tabpanel" aria-labelledby="finalizar-trigger">
											
											<div id="infoValidas" hidden class="form-card col-sm-12 animate__animated animate__zoomInDown animate__slow">
												<h3 class="fs-title text-center">Todas as Informações foram validadas com sucesso!</h3>
												<br>
												<div class="row justify-content-center col-sm-12">
													
													<i class="fa-solid fa-circle-check" style="color:#28a745;font-size:100px"></i>
													
												</div>
												<br>
												<div id="mensagemSalvar" class="row justify-content-center">
													<div class="col-7 text-center">
														<h5 id="mensagemFinalizar">Clique no botão "Salvar" para cadastrar este processo.</h5>
													</div>
												</div>
											</div>

											<div id="infoInvalidas" hidden class="form-card col-sm-12 animate__animated animate__wobble">
												<h3 class="fs-title text-center">Há campos que precisam ser corrigidos!</h3>
												<br>
												<div class="row justify-content-center col-sm-12">
													
													<i class="fa-solid fa-circle-xmark" style="color:#dc3545;font-size:100px"></i>
													
												</div>
												<br>
												<div id="mensagemSalvar" class="row justify-content-center">
													<div class="col-7 text-center">
														<h5>Corrija os campos destacados e tente novamente.</h5>
													</div>
												</div>
											</div>

											<div style="margin-top:10px;display:flex;justify-content:space-between" >
												<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
												<button id="btSalvar" class="btn  btn-success animate__animated animate__bounceIn animate__slow animate__delay-2s " >Salvar</button>
												<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroItem(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
											</div>

										</div>
										</form>																
															





									</div>
								</div>
							</div>
						</div>

					</div>
				</div>
			</div>			
				
				

			
			
			<div id="editarItemDiv" style="margin-bottom:50px"></div>
			<div id="tabItemsDiv" style="margin-bottom:50px"></div>

			<div id="cadastroItemDiv" style="padding-left:25px;padding-right:25px"></div>

			<script language="JavaScript">
				

				
				$(document).ready(function(){

					
					$('#cadastro').on('expanded.lte.cardwidget', function() {
						//limpa o conteúdo de cadastroItemDiv
						$('#cadastroItemDiv').html('')
						//obter a largura de infoProcesso
						let largura = $('#infoProcesso').width();
						$('#cadastro').css('width', largura );
						//move o cursor para o id cadastro
						$('html, body').animate({
							scrollTop: $("#cadastro").offset().top-60
						}, 1000);
					});

					$('#cadastro').on('collapsed.lte.cardwidget', function() {
						$('#cadastro').css('width', 'auto');
					});


					//Initialize Select2 Elements
					// as exceções são os selects que não devem ser inicializados com o select2 e que estão em todas as páginas que utilizam este componente.
					$('select').not('[name="tabProcCards_length"], [name="tabAvaliacoes_length"]').select2({
						
						theme: 'bootstrap4',
						placeholder: 'Selecione...',
						allowClear: true
					});

					//INICIALIZA O POPOVER NOS ÍCONES
					$(function () {
						$('[data-toggle="popover"]').popover()
					})	
					$('.popover-dismiss').popover({
						trigger: 'hover'
					})
					//FIM NICIALIZA O POPOVER NOS ÍCONES 

					$(function () {
						$('[data-mask]').inputmask()//mascara para os inputs
					})
					
					window.stepper = new Stepper($('.bs-stepper')[0], {
						animation: true
					});

					// Oculta todos os elementos com a classe step-trigger, exceto aquele com o ID infoInicial-trigger
					$('.step-trigger').not('#aval_testeControle-trigger').hide();

					

					// Adiciona o método de validação personalizado para múltipla seleção
					$.validator.addMethod("atLeastOneSelected", function(value, element) {
						return $(element).find('option:selected').length > 0;
					}, "Pelo menos uma opção deve ser selecionada.");

					// Adiciona validação aos campos option zero foi selecionado
					$.validator.addMethod("requiredIfSelectDinamicoZero", function(value, element) {
						return $('#selectDinamicoPROCESSO_N3').val() != 0 || value !== "";
					}, "Campo obrigatório se o valor do select dinâmico for Outros.");

					// Função de validação customizada
					// Função de validação customizada
					function validateButtonGroups() {
						var isValid = true;

						if ($("#btn_groupValorRecuperar .active").length === 0) {
							$("#btn_groupValorRecuperar").addClass("is-invalid").removeClass("is-valid");
							if ($("#btn_groupValorRecuperar").next("span.error").length === 0) {
								$("<span class='error invalid-feedback'>Selecione uma opção.</span>").insertAfter("#btn_groupValorRecuperar");
							}
							isValid = false;
						} else {
							$("#btn_groupValorRecuperar").removeClass("is-invalid").addClass("is-valid");
							$("#btn_groupValorRecuperar").next("span.error").remove();
							$("#pcValorRecuperar-error").remove();
						}

						if ($("#btn_groupValorRisco .active").length === 0) {
							$("#btn_groupValorRisco").addClass("is-invalid").removeClass("is-valid");
							if ($("#btn_groupValorRisco").next("span.error").length === 0) {
								$("<span class='error invalid-feedback'>Selecione uma opção.</span>").insertAfter("#btn_groupValorRisco");
							}
							isValid = false;
						} else {
							$("#btn_groupValorRisco").removeClass("is-invalid").addClass("is-valid");
							$("#btn_groupValorRisco").next("span.error").remove();
							$("#pcValorRisco-error").remove();
						}

						if ($("#btn_groupValorNaoPlanejado .active").length === 0) {
							$("#btn_groupValorNaoPlanejado").addClass("is-invalid").removeClass("is-valid");
							if ($("#btn_groupValorNaoPlanejado").next("span.error").length === 0) {
								$("<span class='error invalid-feedback'>Selecione uma opção.</span>").insertAfter("#btn_groupValorNaoPlanejado");
							}
							isValid = false;
						} else {
							$("#btn_groupValorNaoPlanejado").removeClass("is-invalid").addClass("is-valid");
							$("#btn_groupValorNaoPlanejado").next("span.error").remove();
							$("#pcValorNaoPlanejado-error").remove();
						}

						return isValid;
					}

					// Adicione métodos de validação personalizados para verificar visibilidade e valor não zero
					$.validator.addMethod("requiredIfVisibleAndNotZero", function(value, element) {
						if (!$(element).is(":visible")) {
							return true; // Se o campo não estiver visível, considere-o válido
						}
						// Converta o valor para string e verifique se não é zero
						var stringValue = String(value);
						var numericValue = parseFloat(stringValue.replace(/[^0-9,-]+/g, '').replace(',', '.'));
						return numericValue > 0;
					}, "Campo obrigatório e deve ser maior que zero.");

					// Adicione e remova a classe 'active' quando os botões forem clicados
					$("#btn_groupValorRecuperar button").on("click", function() {
						$(this).addClass("active").siblings().removeClass("active");//adiciona active no botão e remove active dos seua irmãos do mesmo grupo
						validateButtonGroups()
					});
					$("#btn_groupValorRisco button").on("click", function() {
						$(this).addClass("active").siblings().removeClass("active");//adiciona active no botão e remove active dos seua irmãos do mesmo grupo
						validateButtonGroups()
					});
					$("#btn_groupValorNaoPlanejado button").on("click", function() {
						$(this).addClass("active").siblings().removeClass("active");//adiciona active no botão e remove active dos seua irmãos do mesmo grupo
						validateButtonGroups()
					});

					
					$('#formAval_testeControle').validate({
						errorPlacement: function(error, element) {
							error.appendTo(element.closest('.form-group'));
							$(element).removeClass('is-valid').addClass('is-invalid');
						},
						rules: {
							pcTeste: {
								required: true,
								maxlength: 5000
							},
							pcControleTestado: {
								required: true,
								maxlength: 7500
							},
							pcAvaliacaoTipoControle: {
								atLeastOneSelected: true
							},
							pcAvaliacaoCategoriaControle: {
								atLeastOneSelected: true
							}
						},
						messages: {
							pcTeste: {
								required: "Campo obrigatório.",
								maxlength: "O campo deve conter no máximo 5000 caracteres."
							},
							pcControleTestado: {
								required: "Campo obrigatório.",
								maxlength: "O campo deve conter no máximo 7500 caracteres."
							},
							pcAvaliacaoTipoControle: {
								atLeastOneSelected: "Selecione, pelo menos, uma opção."
							},
							pcAvaliacaoCategoriaControle: {
								atLeastOneSelected: "Selecione, pelo menos, uma opção."
							}
						},
						errorPlacement: function(error, element) {
							error.addClass("invalid-feedback");
							element.closest(".form-group").append(error);
						},
						highlight: function(element) {
							$(element).addClass("is-invalid").removeClass("is-valid");
						},
						unhighlight: function(element) {
							$(element).addClass("is-valid").removeClass("is-invalid");
							
						}
					});

					$('#formAval_item').validate({
						errorPlacement: function(error, element) {
							error.appendTo(element.closest('.form-group'));
							$(element).removeClass('is-valid').addClass('is-invalid');
						},
						rules: {
							pcNumSituacaoEncontrada: {
								required: true
							},
							pcTituloSituacaoEncontrada: {
								required: true,
								maxlength: 500
							},
							pcSintese: {
								required: true,
								maxlength: 7500
							},
							pcAvaliacaoRisco: {
								required: true
							},
							pcAvaliacaoRiscoOutrosDesc: {
								required: true,
								maxlength: 100,
								requiredIfSelectDinamicoZero: true
							},
							pcTipoClassificacao: {
								required: true
							}
							
						},
						messages: {
							pcNumSituacaoEncontrada: {
								required: "Campo obrigatório."
							},
							pcTituloSituacaoEncontrada: {
								required: "Campo obrigatório.",
								maxlength: "O campo deve conter no máximo 500 caracteres."
							},
							pcSintese: {
								required: "Campo obrigatório.",
								maxlength: "O campo deve conter no máximo 7500 caracteres."
							},
							pcAvaliacaoRisco: {
								required: "Campo obrigatório."
							},
							pcAvaliacaoRiscoOutrosDesc: {
								required: "Campo obrigatório.",
								maxlength: "O campo deve conter no máximo 100 caracteres.",
								requiredIfSelectDinamicoZero: "Campo obrigatório."
							},
							pcTipoClassificacao: {
								required: "Campo obrigatório."
							}
						},
						errorPlacement: function(error, element) {
							error.addClass("invalid-feedback");
							element.closest(".form-group").append(error);
						},
						highlight: function(element) {
							$(element).addClass("is-invalid").removeClass("is-valid");
						},
						unhighlight: function(element) {
							$(element).addClass("is-valid").removeClass("is-invalid");
						}
					});

					$('#formAval_riscoCoso').validate({
						errorPlacement: function(error, element) {
							error.appendTo(element.closest('.form-group'));
							$(element).removeClass('is-valid').addClass('is-invalid');
						},
						rules: {
							selectDinamicoCOMPONENTE: {
								required: true
							},
							selectDinamicoPRINCIPIO: {
								required: true
							},
						},
						messages: {
							selectDinamicoCOMPONENTE: {
								required: "Campo obrigatório."
							},
							selectDinamicoPRINCIPIO: {
								required: "Campo obrigatório."
							}
						},
						errorPlacement: function(error, element) {
							error.addClass("invalid-feedback");
							element.closest(".form-group").append(error);
						},
						highlight: function(element) {
							$(element).addClass("is-invalid").removeClass("is-valid");
						},
						unhighlight: function(element) {
							$(element).addClass("is-valid").removeClass("is-invalid");
						}
					});

					// Inicializa a validação do formulário
					$('#formAval_valorEstimado').validate({
						rules: {
							pcValorRecuperar: {
								requiredIfVisibleAndNotZero: true
							},
							pcValorRisco: {
								requiredIfVisibleAndNotZero: true
							},
							pcValorNaoPlanejado: {
								requiredIfVisibleAndNotZero: true
							}
						},
						messages: {
							pcValorRecuperar: {
								requiredIfVisibleAndNotZero: "Campo obrigatório e deve ser maior que zero."
							},
							pcValorRisco: {
								requiredIfVisibleAndNotZero: "Campo obrigatório e deve ser maior que zero."
							},
							pcValorNaoPlanejado: {
								requiredIfVisibleAndNotZero: "Campo obrigatório e deve ser maior que zero."
							}
						},
						errorPlacement: function(error, element) {
							error.addClass("invalid-feedback");
							element.closest(".form-group").append(error);
						},
						highlight: function(element) {
							$(element).addClass("is-invalid").removeClass("is-valid");
						},
						unhighlight: function(element) {
							$(element).addClass("is-valid").removeClass("is-invalid");
						}
					});
				

					$('#formAval_criteriosReferencias').validate({
						errorPlacement: function(error, element) {
							error.appendTo(element.closest('.form-group'));
							$(element).removeClass('is-valid').addClass('is-invalid');
						},
						rules: {
							pcCriterioRef: {
								required: true
							},
							pcCriterioRefOutrosDesc: {
								required: true,
								maxlength: 500,
								requiredIfSelectDinamicoZero: true
							}
						},
						messages: {
							pcCriterioRef: {
								required: "Campo obrigatório."
							},
							pcCriterioRefOutrosDesc: {
								required: "Campo obrigatório.",
								maxlength: "O campo deve conter no máximo 500 caracteres.",
								requiredIfSelectDinamicoZero: "Campo obrigatório."
							}
						},
						errorPlacement: function(error, element) {
							error.addClass("invalid-feedback");
							element.closest(".form-group").append(error);
						},
						highlight: function(element) {
							$(element).addClass("is-invalid").removeClass("is-valid");
						},
						unhighlight: function(element) {
							$(element).addClass("is-valid").removeClass("is-invalid");
						}
					});
						


					// Inicializar validação ao clicar no botão Próximo do primeiro passo
					window.inicializarValidacaoStep1 = function() {
							if ($("#formAval_testeControle").valid()) {
							// Ir para o próximo passo
							stepper.next();
							$('#aval_item-trigger').show();
							// Adiciona a animação bounce ao elemento
							$('#aval_item-trigger').addClass('animate__animated animate__bounce');
						}
					};

					// Inicializar validação ao clicar no botão Próximo do segundo passo
					window.inicializarValidacaoStep2 = function() {
						if ($("#formAval_item").valid()) {
							// Ir para o próximo passo
							stepper.next();
							$('#aval_riscoCoso-trigger').show();
							// Adiciona a animação bounce ao elemento
							$('#aval_riscoCoso-trigger').addClass('animate__animated animate__bounce');
						}
					};

					// Inicializar validação ao clicar no botão Próximo do terceiro passo
					window.inicializarValidacaoStep3 = function() {
						if ($("#formAval_riscoCoso").valid()) {
							// Ir para o próximo passo
							stepper.next();
							$('#aval_valorEstimado-trigger').show();
							// Adiciona a animação bounce ao elemento
							$('#aval_valorEstimado-trigger').addClass('animate__animated animate__bounce');
						}
					};

					// Define os níveis de dados e nomes dos labels
					let dataLevels = ['COMPONENTE', 'PRINCIPIO'];
					let labelNames = ['Componente', 'Princípio'];
					initializeSelectsAjax('#dados-container-coso', dataLevels, 'ID', labelNames, 'idCoso',[],'cfc/pc_cfcAvaliacoes.cfc','getAvaliacaoCoso');

					// Inicializar validação ao clicar no botão Próximo do quarto passo
					window.inicializarValidacaoStep4 = function() {
						if ($("#formAval_valorEstimado").valid() && validateButtonGroups()) {
							// Ir para o próximo passo
							stepper.next();
							$('#aval_criteriosReferencias-trigger').show();
							// Adiciona a animação bounce ao elemento
							$('#aval_criteriosReferencias-trigger').addClass('animate__animated animate__bounce');
						}
					};

					// Inicializar validação ao clicar no botão Próximo do quinto passo
					window.inicializarValidacaoStep5 = function() {
						if ($("#formAval_criteriosReferencias").valid()) {
							// Ir para o próximo passo
							stepper.next();
							$('#finalizar-trigger').show();
							$('#finalizar-trigger').addClass('animate__animated animate__bounce');
							$('#infoValidas').attr("hidden",false);
							$('#infoInvalidas').attr("hidden",true);
							$('#btSalvar').attr("hidden",false);
						}else{
							$('#infoValidas').attr("hidden",true);
							$('#infoInvalidas').attr("hidden",false);
							$('#btSalvar').attr("hidden",true);
						}
					};


					// Adiciona manipuladores de eventos de mudança para os campos select2
					$('select').on('change.select2', function() {
						var $this = $(this);
						if ($this.val()) {
							$this.removeClass('is-invalid').addClass('is-valid');
							$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
							
						}
					});

					

					// Adiciona manipuladores de eventos para validar os campos
					$('textarea, input, select').on('change blur keyup', function() {
						var $this = $(this);
						if ($this.val()) {
							$this.removeClass('is-invalid').addClass('is-valid');
							$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
						}
					});

					
					// Aplicar validação aos selects cujo id contenha selectDinamico
					$('select[id*="selectDinamico"]').each(function() {
						$(this).rules('add', {
							required: true,
							messages: {
								required: '<span style="color:red;font-size:10px">Este campo é obrigatório.</span>'
							}
						});
					});

					// Delegação de eventos para selects dinâmicos
					$(document).on('change', 'select[id*="selectDinamico"]', function() {
						var $this = $(this);
						if ($this.val()) {
							$this.removeClass('is-invalid').addClass('is-valid');
							$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
						} else {
							$this.removeClass('is-valid').addClass('is-invalid');
							$this.closest('.form-group').find('label.is-invalid').css('display', 'block');
						}
					});


					// se for selecionado outros em pcAvaliacaoRisco, exibe o campo de descrição
					$(document).on('change', '#pcAvaliacaoRisco', function() {
						var $this = $(this);
						// Verifica se alguma das opções selecionadas tem o valor 0
						if ($this.val().includes('0')) {
							$('#pcAvaliacaoRiscoOutrosDescricaoDiv').attr("hidden",false);
						} else {
							$('#pcAvaliacaoRiscoOutrosDescricaoDiv').attr("hidden",true);
							$('#pcAvaliacaoRiscoOutrosDesc').val('');
						}
					});

					// se for seleciobnado outros em pcCriterioRef, exibe o campo de descrição
					$(document).on('change', '#pcCriterioRef', function() {
						var $this = $(this);
						// Verifica se alguma das opções selecionadas tem o valor 0
						if ($this.val() ==0) {
							$('#pcCriterioRefOutrosDescricaoDiv').attr("hidden",false);
						} else {
							$('#pcCriterioRefOutrosDescricaoDiv').attr("hidden",true);
							$('#pcCriterioRefOutrosDesc').val('');
						}
					});

												
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});


					$(".money").inputmask( 'currency',{"autoUnmask": true,
							radixPoint:",",
							groupSeparator: ".",
							allowMinus: false,
							prefix: 'R$ ',            
							digits: 2,
							digitsOptional: false,
							rightAlign: true,
							unmaskAsNumber: true
					});

					mostraRelatorioPDF()

					setupCharCounter('pcTeste', 'pcTesteCounter', 5000);
					setupCharCounter('pcControleTestado', 'pcControleTestadoCounter', 7500);
					setupCharCounter('pcSintese', 'pcSinteseCounter', 7500);
					setupCharCounter('pcTituloSituacaoEncontrada', 'pcTituloSituacaoEncontradaCounter', 500);
					setupCharCounter('pcCriterioRefOutrosDesc', 'pcCriterioRefOutrosDescCharCounter', 350);
					setupCharCounter('pcAvaliacaoRiscoOutrosDesc', 'pcAvaliacaoRiscoOutrosDescCharCounter', 100);


					
					<cfoutput>
						let modalidade = '#rsProcForm.pc_modalidade#'
						let pc_processo_id = '#rsProcForm.pc_processo_id#'
					</cfoutput>

					if(modalidade ==='A' || modalidade ==='E'){
						// DropzoneJS Demo Code Start
						Dropzone.autoDiscover = false

						// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
						var previewNode = document.querySelector("#templateRelatorio")
						//previewNode.id = ""
						var previewTemplate = previewNode.parentNode.innerHTML
						previewNode.parentNode.removeChild(previewNode)

						var myDropzoneRelatorio = new Dropzone("#processosCadastrados", { // Make the whole body a dropzone
							url: "cfc/pc_cfcAvaliacoes.cfc?method=uploadArquivos", // Set the url
							autoProcessQueue :true,
							maxFiles: 1,
							maxFilesize:20,
							thumbnailWidth: 80,
							thumbnailHeight: 80,
							parallelUploads: 1,
							acceptedFiles: '.pdf',
							previewTemplate: previewTemplate,
							autoQueue: true, // Make sure the files aren't queued until manually added
							previewsContainer: "#previewsRelatorio", // Define the container to display the previews
							clickable: "#relatorios", // Define the element that should be used as click trigger to select files.
							headers: { "pc_aval_id":"", 
									"pc_aval_processo":pc_processo_id, 
									"pc_anexo_avaliacaoPDF":"S",
									"arquivoParaTodosOsItens":"S"},//informar "S" se o arquivo deve ser exibido em todos os itens do processo
							init: function() {
								this.on('error', function(file, errorMessage) {	
									toastr.error(errorMessage);
									return false;
								});
							}
							
						})

						


						// Hide the total progress bar when nothing's uploading anymore
						myDropzoneRelatorio.on("queuecomplete", function(progress) {
							//toastr.success("Arquivo(s) enviado(s) com sucesso!")
							myDropzoneRelatorio.removeAllFiles(true);
							mostraRelatorioPDF();

							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
						})

						
						// DropzoneJS 1 Demo Code End
					}


					$('#btn_groupValorRecuperar .btn').click(function() {
						$('#btn_groupValorRecuperar .btn').removeClass('active');
						$(this).addClass('active');
						
						var selectedValue = $(this).attr('id');

						if (selectedValue === 'btn-quantificado-recuperar') {
							$('#pcValorRecuperar').show().addClass('animate__animated animate__fadeInLeft');
							$('#btn-quantificado-recuperar').removeClass('btn-light').addClass('btn-primary');
							$('#btn-nao-aplica-recuperar').removeClass('btn-dark').addClass('btn-light');
						} else if (selectedValue === 'btn-nao-aplica-recuperar') {
							$('#pcValorRecuperar').hide().removeClass('animate__animated animate__fadeInLeft');
							
							$('#btn-nao-aplica-recuperar').removeClass('btn-light').addClass('btn-dark');
							$('#btn-quantificado-recuperar').removeClass('btn-primary').addClass('btn-light');
							$('#pcValorRecuperar').val('');
						} else {
							$('#pcValorRecuperar').hide().removeClass('animate__animated animate__fadeInLeft');
							$('#pcValorRecuperar').val('');
						}
					});

					$('#btn_groupValorRisco .btn').click(function() {
						$('#btn_groupValorRisco .btn').removeClass('active');
						$(this).addClass('active');

						var selectedValue = $(this).attr('id');

						if (selectedValue === 'btn-quantificado-risco') {
							$('#pcValorRisco').show().addClass('animate__animated animate__fadeInLeft');
							$('#btn-quantificado-risco').removeClass('btn-light').addClass('btn-primary');
							$('#btn-nao-aplica-risco').removeClass('btn-dark').addClass('btn-light');
						} else if (selectedValue === 'btn-nao-aplica-risco') {
							$('#pcValorRisco').hide().removeClass('animate__animated animate__fadeInLeft');
							$('#btn-nao-aplica-risco').removeClass('btn-light').addClass('btn-dark');
							$('#btn-quantificado-risco').removeClass('btn-primary').addClass('btn-light');
							$('#pcValorRisco').val('');
						} else {
							$('#pcValorRisco').hide().removeClass('animate__animated animate__fadeInLeft');
							$('#pcValorRisco').val('');
						}
					});

					$('#btn_groupValorNaoPlanejado .btn').click(function() {
						$('#btn_groupValorNaoPlanejado .btn').removeClass('active');
						$(this).addClass('active');

						var selectedValue = $(this).attr('id');

						if (selectedValue === 'btn-quantificado-NaoPlanejado') {
							$('#pcValorNaoPlanejado').show().addClass('animate__animated animate__fadeInLeft');
							$('#btn-quantificado-NaoPlanejado').removeClass('btn-light').addClass('btn-primary');
							$('#btn-nao-aplica-NaoPlanejado').removeClass('btn-dark').addClass('btn-light');
						} else if (selectedValue === 'btn-nao-aplica-NaoPlanejado') {
							$('#pcValorNaoPlanejado').hide().removeClass('animate__animated animate__fadeInLeft');
							$('#btn-nao-aplica-NaoPlanejado').removeClass('btn-light').addClass('btn-dark');
							$('#btn-quantificado-NaoPlanejado').removeClass('btn-primary').addClass('btn-light');
							$('#pcValorNaoPlanejado').val('');
						} else {
							$('#pcValorNaoPlanejado').hide().removeClass('animate__animated animate__fadeInLeft');
							$('#pcValorNaoPlanejado').val('');
						}
					});

					$('select, textarea, input').on('change', function() {
						var $this = $(this);
						// Verifica se o valor do select é vazio ou nulo
						if ($this.val() == "" || $this.val() == null || $this.val().length === 0) {
							// Trigger the validation for the select element
							$this.valid(); // This will validate the select element based on your jQuery Validate rules
						}
					});


					exibirTabAvaliacoes();

				});

					

				function mostraRelatorioPDF(){
					<cfoutput>
						let pc_processo_id = '#rsProcForm.pc_processo_id#'
					</cfoutput>
					$('#modalOverlay').modal('show')
					setTimeout(function() {
						$.ajax({
							type: "post",
							url:"cfc/pc_cfcAvaliacoes.cfc",
							data:{
								method: "anexoRelatorio",
								pc_anexo_processo_id: pc_processo_id
							},
							async: false
						})//fim ajax
						.done(function(result){
							
							$('#anexoRelatorioDiv').html(result)
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
						})//fim done
						.fail(function(xhr, ajaxOptions, thrownError) {
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)

						})//fim fail
					}, 1000);
				}

				function resetFormFields()  {
					
					$('#pcTeste').val('').trigger('change')
					$('#pcControleTestado').val('').trigger('change')
					$('#pcAvaliacaoTipoControle').val('').trigger('change')
					$('#pcAvaliacaoCategoriaControle').val('').trigger('change')
					$('#pcNumSituacaoEncontrada').val('').trigger('change')
					$('#pcTituloSituacaoEncontrada').val('').trigger('change')
					$('#pcSintese').val('').trigger('change')
					$('#idCoso').val('').trigger('change')
					$('#selectDinamicoCOMPONENTE').val(null).trigger('change');

					$('#pcAvaliacaoRisco').val('').trigger('change')
					$('#pcAvaliacaoRiscoOutrosDescricaoDiv').attr("hidden",true);
					$('#pcAvaliacaoRiscoOutrosDesc').val('').trigger('change')


					$('#pcAvaliacaoRiscoOutrosDesc').val('').trigger('change')
					$('#pcTipoClassificacao').val('').trigger('change')

					//ações para os controles dos valores estimados	
					$('#pcValorRecuperar').val('').trigger('change')
					$('#pcValorRisco').val('').trigger('change')
					$('#pcValorNaoPlanejado').val('').trigger('change')

					$('#btn-quantificado-recuperar').removeClass('btn-primary').addClass('btn-light');
					$('#btn-nao-aplica-recuperar').removeClass('btn-dark').addClass('btn-light');
					$('#btn_groupValorRecuperar .btn').removeClass('active');
					$('#pcValorRecuperar').hide();
					

					$('#btn-quantificado-risco').removeClass('btn-primary').addClass('btn-light');
					$('#btn-nao-aplica-risco').removeClass('btn-dark').addClass('btn-light');
					$('#btn_groupValorRisco .btn').removeClass('active');
					$('#pcValorRisco').hide();

					$('#btn-quantificado-NaoPlanejado').removeClass('btn-primary').addClass('btn-light');
					$('#btn-nao-aplica-NaoPlanejado').removeClass('btn-dark').addClass('btn-light');
					$('#btn_groupValorNaoPlanejado .btn').removeClass('active');
					$('#pcValorNaoPlanejado').hide();
					//fim ações para os controles dos valores estimados

					$('#pcCriterioRef').val('')
					$('#pcCriterioRefOutrosDesc').val('')
					$('#pcCriterioRefOutrosDescricaoDiv').attr("hidden",true)

					$('#cadastro').CardWidget('collapse')
					$('#cabecalhoAccordion').text("");	
					$('#pc_aval_id').val('')
					stepper.to(1);
							
				};

				// $('#btCancelar').on('click', function (event)  {
				// 	//cancela e  não propaga o event click original no botão
				// 	event.preventDefault()
				// 	event.stopPropagation()
				// 	resetFormFields();								
				// });
				
				$('#pcTipoClassificacao').on('change', function (event)  {
					if($('#pcTipoClassificacao').val() == 'L' && !$('#pc_aval_id').val() == ''){
						alert("Atenção! Ao mudar a classificação deste item para leve, caso existam orientações e/ou propostas de melhoria cadastradas, elas serão excluídas após a alteração ser salva.")
					}
				});

				$('#btSalvar').on('click', function (event)  {
					//cancela e  não propaga o event click original no botão
					event.preventDefault()
					event.stopPropagation()
					

					var mensagem = ""
					if($('#pc_aval_id').val() == ''){
						mensagem = "Deseja cadastrar este item?"
					}else{
						mensagem = "Deseja editar este item?"
					}
					
					
					swalWithBootstrapButtons.fire({//sweetalert2
						html: logoSNCIsweetalert2(mensagem),
						showCancelButton: true,
						confirmButtonText: 'Sim!',
						cancelButtonText: 'Cancelar!',
						}).then((result) => {
						if (result.isConfirmed) {
							let pcAvaliacaoTipoControle = $('#pcAvaliacaoTipoControle').val();
							let pcAvaliacaoCategoriaControle = $('#pcAvaliacaoCategoriaControle').val();
							let pcAvaliacaoRisco = $('#pcAvaliacaoRisco').val();

							$('#modalOverlay').modal('show');
							setTimeout(function() {
								//inicio ajax
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAvaliacoes.cfc",
									data:{
										method:"cadProcAvaliacaoItem",
										pc_aval_id: $('#pc_aval_id').val(),
										pc_aval_processo:$('#pcProcessoId').val(),
										pc_aval_teste:$('#pcTeste').val(),
										pc_aval_tipoControle_id:pcAvaliacaoTipoControle.join(','),
										pc_aval_controleTestado:$('#pcControleTestado').val(),
										pc_aval_categoriaControle_id:pcAvaliacaoCategoriaControle.join(','),
										pc_aval_numeracao:$('#pcNumSituacaoEncontrada').val(),
										pc_aval_descricao:$('#pcTituloSituacaoEncontrada').val(),
										pc_aval_sintese:$('#pcSintese').val(),
										pc_aval_risco_id:pcAvaliacaoRisco.join(','),
										pc_aval_risco_outros:$('#pcAvaliacaoRiscoOutrosDesc').val(),
										pc_aval_coso_id:$('#idCoso').val(),
										pc_aval_classificacao:$('#pcTipoClassificacao').val(),
										pc_aval_valorEstimadoRecuperar:$('#pcValorRecuperar').val(),
										pc_aval_valorEstimadoRisco:$('#pcValorRisco').val(),
										pc_aval_valorEstimadoNaoPlanejado:$('#pcValorNaoPlanejado').val(),
										pc_aval_criterioRef_id:$('#pcCriterioRef').val(),
										pcCriterioRefOutrosDesc:$('#pcCriterioRefOutrosDesc').val()
										
									},
						
									async: false,
									success: function(result) {		
										mostraCadastroItem(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											toastr.success('Operação realizada com sucesso!');
										});
									},
									error: function(xhr, ajaxOptions, thrownError) {									
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
														+ '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
											const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
											
											swalWithBootstrapButtons.fire(
													{...erroSistema}
											)
										});
									}

								})
								//fim ajax
							}, 1000); 

						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
									title: 'Operação Cancelada',
									html: logoSNCIsweetalert2(''),
									icon: 'info'
								});
						} 
					})
						
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
						
					});
				});

				function exibirTabAvaliacoes(){
		
					var numProcesso = $('#pcProcessoId').val();
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "tabItens",
							numProcesso: numProcesso
						},
						async: false,
						success: function(result) {
							$('#tabItemsDiv').html(result)
							
						},
						error: function(xhr, ajaxOptions, thrownError) {
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)
							
						}
					})	
					
						

				}

				
				
			</script>
		</body>
		</html>

	</cffunction>



	<cffunction name="anexoRelatorio"   access="remote" hint="retorna os anexos que contem informação do processo no campo pc_anexo_processo_id indicando que é um anexo para todos os itens">
		<cfargument name="pc_anexo_processo_id" type="string" required="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsPc_anexos" > 
			SELECT pc_anexos.*   FROM  pc_anexos
			WHERE pc_anexo_processo_id = '#arguments.pc_anexo_processo_id#'
		</cfquery>

		<cfloop query="rsPc_anexos" >
		    <cfif FileExists(pc_anexo_caminho)>
				<cfset caminho = "#pc_anexo_caminho#">
			<cfelse>
				<cfset caminho = "Caminho  não encontrado">
			</cfif>
			
				<div class="card-body" style="padding:0px;">
					<div  id ="cardRelatorioPDF" class="card card-primary card-tabs collapsed-card" style="transition: all 0.15s ease 0s; height: inherit; width: inherit;">
						<div class="card-header" style="background-color:#00416b;">
						
							<h3 class="card-title" style="font-size:16px;position:relative;top:3px;cursor:pointer" data-card-widget="collapse"><i class="fas fa-file-pdf" style="margin-right:10px;"></i><cfoutput> #pc_anexo_nome#</cfoutput></h3>
						    <div  class="card-tools">
								<button type="button"  id="btExcluir" class="btn btn-tool  " style="font-size:16px" onclick="javascript:excluirAnexoRelatorio(<cfoutput>#pc_anexo_id#</cfoutput>);"  ><i class="fas fa-trash-alt"></i></button>
								<button  type="button" class="btn btn-tool" data-card-widget="collapse" style="font-size:16px;margin-left:50px"><i  class="fas fa-plus"></i></button>
								<button  type="button" class="btn btn-tool" data-card-widget="maximize" style="font-size:16px;margin-left:50px"><i  class="exp fas fa-expand"></i></button>
							</div>
						</div>
						
						<div class="card-body" style="height: 100%;background-color:#00416B;padding-top: 0px;">											
							<embed id="relatoPDFdiv" type="application/pdf" src="pc_Anexos.cfm?arquivo=<cfoutput>#caminho#</cfoutput>" style="width: 100%;height:90vh;" >
						</div>			
					</div>
				</div>
			
		</cfloop>

		<script language="JavaScript">
    
			

			

			function excluirAnexoRelatorio(pc_anexo_id)  {
				
				
				let mensagem = "Deseja excluir este anexo?";
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcProcessos_editar.cfc",
									data:{
										method: "delAnexos",
										pc_anexo_id: pc_anexo_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
						
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										mostraRelatorioPDF()
										toastr.success('Operação realizada com sucesso!');
									});	
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});	
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)
								})//fim fail
							}, 500);
					    }
				    });
			};

		</script>	
		
	</cffunction>




	<cffunction name="uploadArquivos" access="remote"  returntype="boolean" output="false" hint="realiza o upload das avaliações e dos anexos">

		
		<cfset thisDir = expandPath(".")>

	

		<cfif pc_anexo_avaliacaoPDF eq 'S'>
			<cffile action="upload" filefield="file" destination="#application.diretorio_avaliacoes#" nameconflict="skip">
        <cfelse>
			<cffile action="upload" filefield="file" destination="#application.diretorio_anexos#" nameconflict="skip" >
		</cfif>


		<cfscript>
			thread = CreateObject("java","java.lang.Thread");
			thread.sleep(1000); // dalay para evitar arquivos com nome duplicado
		</cfscript>
		
		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'ss.SSSSS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		
		<cfif pc_anexo_avaliacaoPDF eq 'S'>
			<cfif arquivoParaTodosOsItens eq 'N'>
				<cfset destino = cffile.serverdirectory & '\Avaliacao_id_' & #pc_aval_id# &'PC' & '#pc_aval_processo#' & '_'  & '#application.rsUsuarioParametros.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>
			<cfelse>
				<cfset destino = cffile.serverdirectory & '\Relatorio_processo_'&'PC' & '#pc_aval_processo#' & '_'  & '#application.rsUsuarioParametros.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>
			</cfif>
		<cfelse>
			<cfset destino = cffile.serverdirectory & '\Anexo_processo_avaliacao_id_' & #pc_aval_id# &'PC' & '#pc_aval_processo#' & '_'  & '#application.rsUsuarioParametros.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>
		</cfif>


	    <cfobject component = "pc_cfcAvaliacoes" name = "tamanhoArquivo">
		<cfinvoke component="#tamanhoArquivo#" method="renderFileSize" returnVariable="tamanhoDoArquivo" size ='#cffile.fileSize#' type='bytes'>


		<cfset nomeDoAnexo = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#'>

		<cfif FileExists(origem)>
			<cffile action="rename" source="#origem#" destination="#destino#">
        </cfif>

		        
		<cfset mcuOrgao = "#application.rsUsuarioParametros.pc_org_mcu#">
		<cfif FileExists(destino)>
            <cfif arquivoParaTodosOsItens eq 'N'>
				<cfquery datasource="#application.dsn_processos#" >
						INSERT pc_anexos(pc_anexo_avaliacao_id, pc_anexo_login, pc_anexo_caminho, pc_anexo_nome, pc_anexo_mcu_orgao, pc_anexo_avaliacaoPDF, pc_anexo_enviado )
						VALUES (#pc_aval_id#, '#application.rsUsuarioParametros.pc_usu_login#', '#destino#', '#nomeDoAnexo#','#mcuOrgao#', '#pc_anexo_avaliacaoPDF#', 1)
				</cfquery>
			<cfelse>
				<cfquery datasource="#application.dsn_processos#" >
						INSERT pc_anexos(pc_anexo_processo_id, pc_anexo_login, pc_anexo_caminho, pc_anexo_nome, pc_anexo_mcu_orgao, pc_anexo_avaliacaoPDF, pc_anexo_enviado )
						VALUES ('#pc_aval_processo#', '#application.rsUsuarioParametros.pc_usu_login#', '#destino#', '#nomeDoAnexo#','#mcuOrgao#', '#pc_anexo_avaliacaoPDF#', 1)
				</cfquery>
			</cfif>
		</cfif>

	
		<cfreturn true />
    </cffunction>





	<cffunction name="delAnexos"   access="remote" returntype="boolean">
		<cfargument name="pc_anexo_id" type="numeric" required="true" default=""/>

		<cfquery datasource="#application.dsn_processos#" name="rsPc_anexos"> 
			SELECT pc_anexos.*   FROM  pc_anexos
			WHERE pc_anexo_id = #arguments.pc_anexo_id#
		</cfquery>

		<cfif FileExists(rsPc_anexos.pc_anexo_caminho)>
			<cffile action = "delete" File = "#rsPc_anexos.pc_anexo_caminho#">
		</cfif>

		<cfquery datasource="#application.dsn_processos#">
			DELETE FROM pc_anexos
			WHERE(pc_anexo_id = #arguments.pc_anexo_id#)
		</cfquery> 	


		<cfreturn true />
	</cffunction>





	<cffunction name="tabItens" returntype="any" access="remote" hint="Criar a tabela das avaliações e envia para a páginas pc_PcCadastroAvaliacaoPainel">
	
	 
		<cfargument name="numProcesso" type="string" required="true"/>


		<cfquery name="rsAvalTab" datasource="#application.dsn_processos#">
			SELECT      pc_avaliacoes.* , pc_avaliacao_status.*
			FROM        pc_avaliacoes 
			INNER JOIN pc_avaliacao_status on pc_aval_status = pc_aval_status_id
			WHERE       pc_aval_processo = '#arguments.numProcesso#'
			Order by    pc_aval_numeracao 
                         
		</cfquery>
		
		<div class="row" style="padding-left:25px; padding-right:25px">
		<div id="divErroDelAvaliacao" ></div>
			<div class="col-12">
				<div class="card">
					<!-- /.card-header -->
					<div class="card-body">
						<table id="tabItens" class="table table-bordered  table-hover table-striped">
						<thead style="background: #0083ca;color:#fff">
							<tr style="font-size:12px!important">
								<th >Controles</th>
								<th >Item N°:</th>
								<th >Título da Situação Encontrada: </th>	
								<th >Classificação: </th>
							</tr>
						</thead>
						
						<tbody>
							<cfloop query="rsAvalTab" >

								<cfquery datasource="#application.dsn_processos#" name="rsAnexoAvaliacao">
									SELECT pc_anexos.pc_anexo_avaliacao_id FROM pc_anexos WHERE pc_anexo_avaliacao_id = #pc_aval_id# 
								</cfquery> 

								<cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
									SELECT pc_avaliacao_melhorias.pc_aval_melhoria_num_aval FROM pc_avaliacao_melhorias WHERE pc_aval_melhoria_num_aval = #pc_aval_id#
								</cfquery>

								<cfquery datasource="#application.dsn_processos#" name="rsOrientacoes">
									SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_id FROM pc_avaliacao_orientacoes WHERE pc_aval_orientacao_num_aval = #pc_aval_id#
								</cfquery>

								<cfquery name="rsTiposControles" datasource="#application.dsn_processos#">
									SELECT pc_aval_tipoControle_id FROM pc_avaliacao_tiposControles 
									WHERE pc_aval_id = #pc_aval_id#
								</cfquery>
								<cfset listaTiposControles = ValueList(rsTiposControles.pc_aval_tipoControle_id,',')>

								<cfquery name="rsCategoriasControles" datasource="#application.dsn_processos#">
									SELECT pc_aval_categoriaControle_id FROM pc_avaliacao_categoriasControles 
									WHERE pc_aval_id = #pc_aval_id#
								</cfquery>
								<cfset listaCategoriasControles = ValueList(rsCategoriasControles.pc_aval_categoriaControle_id,',')>

								<cfquery name="rsRiscos" datasource="#application.dsn_processos#">
									SELECT pc_aval_risco_id FROM pc_avaliacao_riscos 
									WHERE pc_aval_id = #pc_aval_id#
								</cfquery>
								<cfset listaRiscos = ValueList(rsRiscos.pc_aval_risco_id,',')>

						
								
								<cfset classifRisco = "">
								<cfif #pc_aval_classificacao# eq 'L'>
									<cfset classifRisco = "Leve">
								</cfif>	
								<cfif #pc_aval_classificacao# eq 'M'>
									<cfset classifRisco = "Mediana">
								</cfif>	
								<cfif #pc_aval_classificacao# eq 'G'>
									<cfset classifRisco = "Grave">
								</cfif>	

								

								<cfoutput>					
									<tr style="font-size:12px" >
										<td style="vertical-align: middle;">
											<div style="display:flex;justify-content:space-around;">
												<i class="fas fa-edit efeito-grow"   style="margin-right:10px;cursor: pointer;z-index:100;font-size:20px"  onclick="javascript:editarItem(<cfoutput>'#pc_aval_id#'</cfoutput>)"    title="Editar"></i>
												<i  class="fas fa-boxes-packing efeito-grow" onclick="javascript:mostraCadastroAvaliacaoRelato(<cfoutput>'#pc_aval_id#'</cfoutput>,this);"  style="cursor: pointer;z-index:100;font-size:20px"    title="Mostrar próximos passos." ></i>
											</div>
										</td>

										<td  align="center" style="vertical-align: middle;">#pc_aval_numeracao# </td>
										<td  ><pre >#pc_aval_descricao#</pre></td>

										
										<td>#classifRisco#</td>

										
									</tr>
								</cfoutput>
							</cfloop>	
						</tbody>
							
						
						</table>
					</div>

					
					<!-- /.card-body -->
				</div>
				<!-- /.card -->
			</div>
		<!-- /.col -->
		</div>
		<!-- /.row -->
		<script language="JavaScript">

		
			$(function () {
				$("#tabItens").DataTable({
					columnDefs: [
						{ "orderable": false, "targets": 0 }//impede que a primeira coluna seja ordenada
					],
					order: [[ 1, "asc" ]],//ordena a segunda coluna como crescente
					"destroy": true,
			    	"stateSave": true,
					"responsive": true, 
					"lengthChange": true, 
					"autoWidth": false,
					"select": true,
					"buttons": [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						className: 'btExcel',
					}],
				}).buttons().container().appendTo('#tabAvaliacoes_wrapper .col-md-6:eq(0)');
					
			});

			//Inicializa as dicas de controle
			// $(function () {
			// 	$('[]').tooltip()
			// })

			//ABRE O FORM PARA UPLOAD DA AVALIAÇÃO, ANEXOS, RECOMENDAÇÕES, ETC...
			function mostraCadastroAvaliacaoRelato(idAvaliacao,linha) {
				//event.preventDefault()
				//event.stopPropagation()
                $("#accordionTitulo").attr("hidden", true) 
				$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
                $('#modalOverlay').modal('show')
				
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: 'formCadastroAvaliacaoRelato',
							idAvaliacao:idAvaliacao
							
						},
						async: false
					})//fim ajax
					.done(function(result) {
						resetFormFields();
						$('#cadastroItemDiv').html(result)
						$('html, body').animate({ scrollTop: ($('#cadastroItemDiv').offset().top)} , 500);
						
						$('#modalOverlay').delay(2000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});	
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});	
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
		
					});
				}, 500);
			}

			
         
            function formatCurrency(value) {
				// Formata o valor como moeda brasileira
				let formatter = new Intl.NumberFormat('pt-BR', {
					style: 'currency',
					currency: 'BRL',
					minimumFractionDigits: 2
				});
				return formatter.format(value);
			}

			
			
            //@audit editarItem(id) 
			function editarItem(id) {
				event.preventDefault()
				event.stopPropagation()
                resetFormFields();

				
     			$('.step-trigger').show();
				//incializa no primeiro step
				stepper.to(1);

                let pc_aval_id = id;


				$('#modalOverlay').modal('show')	
				setTimeout(function() {
					 
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data: {
							method: "getAvaliacaoDadosParaEdicao",
							pc_aval_id: pc_aval_id
						},
						async: true
					})
					.done(function(result) {
							// Limpa as classes de validação
							$('#formAval_testeControle').find('.is-valid, .is-invalid').removeClass('is-valid is-invalid');
							            				
							let data = JSON.parse(result);

							// Verifique se os dados são um array e têm pelo menos um elemento
							if (Array.isArray(data) && data.length > 0) {
								let item = data[0];
								
								let pcNumSituacaoEncontrada = item.PC_AVAL_NUMERACAO;
								let pcTituloSituacaoEncontrada = item.PC_AVAL_DESCRICAO;
								let pcTipoClassificacao = item.PC_AVAL_CLASSIFICACAO;
								let pc_aval_teste = item.PC_AVAL_TESTE;
								
								// Verifique se a propriedade existe antes de chamar split
								let listTiposControles = typeof item.AVALIACAO_TIPO_CONTROLE === 'string' ? item.AVALIACAO_TIPO_CONTROLE.split(",") : [item.AVALIACAO_TIPO_CONTROLE.toString()];
								let pc_aval_controleTestado = item.PC_AVAL_CONTROLETESTADO;
								let listCategoriasControles = typeof item.AVALIACAO_CATEGORIA_CONTROLE === 'string' ? item.AVALIACAO_CATEGORIA_CONTROLE.split(",") : [item.AVALIACAO_CATEGORIA_CONTROLE.toString()];
								let pc_aval_sintese = item.PC_AVAL_SINTESE;
								let listRiscos = typeof item.AVALIACAO_RISCOS === 'string' ? item.AVALIACAO_RISCOS.split(",") : [item.AVALIACAO_RISCOS.toString()];
								let pc_aval_coso_id = item.PC_AVAL_COSO_ID;
								let pc_aval_valorEstimadoRecuperar = item.PC_AVAL_VALORESTIMADORECUPERAR;
								let pc_aval_valorEstimadoRisco = item.PC_AVAL_VALORESTIMADORISCO;
								let pc_aval_valorEstimadoNaoPlanejado = item.PC_AVAL_VALORESTIMADONAOPLANEJADO;
								let pc_aval_criterioRef_id = item.PC_AVAL_CRITERIOREF_ID;

								$('#pcNumSituacaoEncontrada').val(pcNumSituacaoEncontrada).trigger('change');
								$('#pcTituloSituacaoEncontrada').val(pcTituloSituacaoEncontrada).trigger('change');
								$('#pcTipoClassificacao').val(pcTipoClassificacao).trigger('change');
								$('#pc_aval_id').val(pc_aval_id).trigger('change');
								$('#pcTeste').val(pc_aval_teste).trigger('change');
								$('#pcControleTestado').val(pc_aval_controleTestado).trigger('change');
								$('#pcSintese').val(pc_aval_sintese).trigger('change');

								$('#pcValorRecuperar').val(formatCurrency(pc_aval_valorEstimadoRecuperar)).trigger('change');
								$('#pcValorRisco').val(formatCurrency(pc_aval_valorEstimadoRisco)).trigger('change');
								$('#pcValorNaoPlanejado').val(formatCurrency(pc_aval_valorEstimadoNaoPlanejado)).trigger('change');
								$('#pcCriterioRef').val(pc_aval_criterioRef_id).trigger('change');
								//popula o select dinâmico do COSO
								let dataLevels = ['COMPONENTE', 'PRINCIPIO'];
								let labelNames = ['Componente', 'Princípio'];
								initializeSelectsAjax('#dados-container-coso', dataLevels, 'ID', labelNames, 'idCoso',[],'cfc/pc_cfcAvaliacoes.cfc','getAvaliacaoCoso');
								populateSelectsFromIDAjax('cfc/pc_cfcAvaliacoes.cfc','getAvaliacaoCoso',pc_aval_coso_id, dataLevels,'idCoso');
								//fim popula o select dinâmico do COSO

								//popula os selects multiplos
								$('#pcAvaliacaoTipoControle').val(listTiposControles).trigger('change');
								$('#pcAvaliacaoCategoriaControle').val(listCategoriasControles).trigger('change');
								$('#pcAvaliacaoRisco').val(listRiscos).trigger('change');
								//fim popula os selects multiplos

								// Inicializa o estado dos botões com base no valor de pc_aval_valorEstimadoRecuperar
								
								if (pc_aval_valorEstimadoRecuperar == 0) {
									$('#btn-nao-aplica-recuperar').addClass('active btn-dark').removeClass('btn-light');
									$('#btn-quantificado-recuperar').removeClass('active btn-primary').addClass('btn-light');
									$('#pcValorRecuperar').hide();
								} else {
									$('#btn-quantificado-recuperar').addClass('active btn-primary').removeClass('btn-light');
									$('#btn-nao-aplica-recuperar').removeClass('active btn-dark').addClass('btn-light');
									$('#pcValorRecuperar').show();
								}

								// Inicializa o estado dos botões com base no valor de pc_aval_valorEstimadoRisco
								if (pc_aval_valorEstimadoRisco == 0) {
									$('#btn-nao-aplica-risco').addClass('active btn-dark').removeClass('btn-light');
									$('#btn-quantificado-risco').removeClass('active btn-primary').addClass('btn-light');
									$('#pcValorRisco').hide();
								} else {
									$('#btn-quantificado-risco').addClass('active btn-primary').removeClass('btn-light');
									$('#btn-nao-aplica-risco').removeClass('active btn-dark').addClass('btn-light');
									$('#pcValorRisco').show();

								}

								// Inicializa o estado dos botões com base no valor de pc_aval_valorEstimadoNaoPlanejado
								if (pc_aval_valorEstimadoNaoPlanejado == 0) {
									$('#btn-nao-aplica-NaoPlanejado').addClass('active btn-dark').removeClass('btn-light');
									$('#btn-quantificado-NaoPlanejado').removeClass('active btn-primary').addClass('btn-light');
									$('#pcValorNaoPlanejado').hide();
								} else {
									$('#btn-quantificado-NaoPlanejado').addClass('active btn-primary').removeClass('btn-light');
									$('#btn-nao-aplica-NaoPlanejado').removeClass('active btn-dark').addClass('btn-light');
									$('#pcValorNaoPlanejado').show();
								}
								
								$('select' ).each(function() {
									var $select = $(this);
									if ($select.val() == "" || $select.val() == null) { // Verifica se há pelo menos uma opção selecionada
										$select.removeClass('is-valid is-invalid');
									}
								});
								// Para textarea e input
								$('textarea, input').each(function() {
									var $textarea = $(this);
									if ($textarea.val() == "") { // Verifica se o campo está vazio
										$textarea.removeClass('is-valid is-invalid');
									}
								});

								

								$('#cabecalhoAccordion').text("Editar o item N°:" + ' ' + pcNumSituacaoEncontrada);
								$('#infoTipoCadastro').text("Editando o Item N°:" + ' ' + pcNumSituacaoEncontrada);
								$('#mensagemFinalizar').html('<h5>Clique no botão "Salvar" para <span style="color: green;font-size: 1.5rem">EDITAR</span> o Item'  + ' <span style="color: green;font-size: 1.5rem"><strong>' + pcNumSituacaoEncontrada + '</strong></span></h5>');
								$("#btSalvar").attr("hidden",false);
								$("#mensagemSalvar").attr("hidden",false);
								$("#accordionTitulo").attr("hidden", false)

								$('#cadastro').CardWidget('expand')
								$('html, body').animate({ scrollTop: ($('#cadastro').offset().top - 80)} , 500);
                               

							}
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});	
					
					})
					.fail(function(xhr, ajaxOptions, thrownError) {
						console.error("AJAX Error:", thrownError); // Adicionado para depuração
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show');
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:');
						$('#modal-danger').find('.modal-body').text(thrownError);
					});
				}, 1000);

				
								
				
			};	

			

			function mensErro(mensagemErro){
				event.preventDefault()
				event.stopPropagation()
				let erroSistema = { html: logoSNCIsweetalert2(mensagemErro) }
				
				swalWithBootstrapButtons.fire(
					{...erroSistema}
				)
			}


		</script>				


	</cffunction>


	<cffunction name="formCadastroAvaliacaoRelato"   access="remote" hint="valida (ou  não) a avaliação e, se foi a Última avaliação a ser validada, envia o processo para o Órgão responsável.">
		
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="passoapasso" type="string" required="false" default="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = #arguments.idAvaliacao#
		</cfquery>

		<session class="content-header"  >
					
			<!-- /.card-header -->
			<session class="card-body" >

					<div id="idAvaliacao" hidden></div>

					<cfquery name="rsProcAval" datasource="#application.dsn_processos#">
						SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
									pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado, pc_orgaos.pc_org_mcu,
									pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
									, pc_classificacoes.pc_class_descricao, pc_avaliacoes.*
						FROM        pc_processos INNER JOIN
									pc_avaliacoes            on pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo            INNER JOIN
									pc_avaliacao_tipos       ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
									pc_orgaos                ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu               INNER JOIN
									pc_status                ON pc_processos.pc_num_status = pc_status.pc_status_id                     INNER JOIN
									pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu               INNER JOIN
									pc_classificacoes        ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id       
									
						WHERE  pc_aval_id = #arguments.idAvaliacao#	 													
					</cfquery>	

					<cfquery name="rsAvalStatusTipos" datasource="#application.dsn_processos#">
						SELECT pc_avaliacao_status.* FROM pc_avaliacao_status 
						WHERE  pc_aval_status_id = #rsProcAval.pc_aval_status#
					</cfquery>
				
					<input id="pcProcessoId"  required="" hidden  value="#arguments.idAvaliacao#">

					<cfquery name="rs_OrgAvaliado" datasource="#application.dsn_processos#">
						SELECT pc_orgaos.*
						FROM pc_orgaos
						WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#' or pc_org_mcu = '#rsProcAval.pc_num_orgao_avaliado#' 
								or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#'))
						ORDER BY pc_org_sigla
					</cfquery>

					<cfquery datasource="#application.dsn_processos#" name="rsModalidadeProcesso">
						SELECT pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_processo_id, pc_processos.pc_num_status FROM pc_processos
						Right JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						WHERE pc_avaliacoes.pc_aval_id = #arguments.idAvaliacao# 
					</cfquery>

					
					<cfquery datasource="#application.dsn_processos#" name="rsProcessoComOrientacoes">
						SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_id from pc_avaliacao_orientacoes
						LEFT JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
						LEFT JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
						WHERE pc_processo_id = '#rsModalidadeProcesso.pc_processo_id#'
					</cfquery>

					
					<cfquery datasource="#application.dsn_processos#" name="rsAvaliacoesValidadas">
						SELECT      pc_avaliacoes.pc_aval_status FROM pc_avaliacoes
						WHERE       pc_aval_processo = '#rsModalidadeProcesso.pc_processo_id#' and  pc_aval_status in (1,2,3)
					</cfquery>

				

					<!--tabs-->
				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						.tab-pane{
							min-height: 300px;
						}
					</style>
						
					<div class="card-header" style="background-color: #0083CA;border-bottom:solid 2px #fff" >
						<cfoutput>
							<p style="font-size: 1.3em;color:##fff"><strong>#rsProcAval.pc_aval_numeracao# - #rsProcAval.pc_aval_descricao#</strong></p>
						</cfoutput>	
					</div>
					<div id="tabsCadItem" class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
							
								
								
								<li class="nav-item">
									<a  class="nav-link active" id="custom-tabs-one-3passo-tab"  data-toggle="pill" href="#custom-tabs-one-3passo" role="tab" aria-controls="custom-tabs-one-3passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">3° Passo - Anexos<cfelse>Anexos</cfif></a>
								</li>
								
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-4passo-tab"  data-toggle="pill" href="#custom-tabs-one-4passo" role="tab" aria-controls="custom-tabs-one-4passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">4° Passo - Medida/Orientação para Regularização<cfelse>Medida/Orientação para Regularização</cfif></a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-5passo-tab"  data-toggle="pill" href="#custom-tabs-one-5passo" role="tab" aria-controls="custom-tabs-one-5passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">5° Passo - Proposta de Melhoria<cfelse>Proposta de Melhoria</cfif></a>
								</li>
								
								
							</ul>
							
						</div>
						<div class="card-body" style="align-items: center;">
							<div class="tab-content" id="custom-tabs-one-tabContent">
								
							
								<div class="tab-pane fade active show" id="custom-tabs-one-3passo" role="tabpanel" aria-labelledby="custom-tabs-one-3passo-tab">
									
									
									<div id="actions2" class="row" >
										<div class="col-lg-12" align="center">
											<div class="btn-group w-30">
												
													<span id="anexos" class="btn btn-success col fileinput-button" >
														<i class="fas fa-upload"></i>
														<span style="margin-left:5px">Clique aqui para anexar arquivos (PDF, EXCEL ou ZIP)</span>
													</span>
												
											</div>
										</div>
									</div>
									<div  class="row" >	
										<div class="col-lg-0 d-flex align-items-center" ><!--col-lg-0 para esconder a barra -->
											<div class="fileupload-process w-100">
												<div id="total-progress2" class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
													<div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress hidden></div>
												</div>
											</div>
										</div>
									</div>
									<div class="table table-striped files" id="previews2">
										<div id="template2" class="row mt-2">
											<div class="col-auto">
												<span class="preview"><img src="data:," alt="" data-dz-thumbnail /></span>
											</div>
											<div class="col d-flex align-items-center">
												<p class="mb-0">
												<span class="lead" data-dz-name></span>
												(<span data-dz-size></span>)
												</p>
												<strong class="error text-danger" data-dz-errormessage></strong>
											</div>
											<div class="col-4 d-flex align-items-center" >
												<div class="progress progress-striped active w-100" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" >
													<div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress ></div>
												</div>
											</div>
										
										</div>
									</div>
									
									
									<div id="tabAnexosDiv" style="margin-top:20px"></div>

								</div>

								<div class="tab-pane fade " id="custom-tabs-one-4passo" role="tabpanel" aria-labelledby="custom-tabs-one-4passo-tab" >
								   
									<cfif rsProcAval.pc_aval_classificacao neq 'L'>
										
										<div id="formAvalOrientacaoCadastroDiv"></div>
										
										<div id="tabOrientacoesDiv" style="margin-top:20px"></div>
									<cfelse>
										<div class="badge " style=" background-color:#e83e8c;color:#fff;font-size:20px;">Não se aplica para itens com classificação "LEVE".</div>
									</cfif>
								
								</div>


								<div class="tab-pane fade " id="custom-tabs-one-5passo" role="tabpanel" aria-labelledby="custom-tabs-one-5passo-tab">

									<cfif rsProcAval.pc_aval_classificacao neq 'L'>
										
										<div id="formAvalMelhoriaCadastroDiv"></div>
										
										<div id="tabMelhoriasDiv" style="margin-top:20px;"></div>
									<cfelse>
										<div class="badge " style=" background-color:#e83e8c;color:#fff;font-size:20px;">Não se aplica para itens com classificação "LEVE".</div>
									</cfif>
									
								</div>

								
								
								
							</div>

						
						</div>
						
					</div>
					
					
					

				





			</session><!-- fim card-body2 -->	
					

					
		</session>
			

		<script language="JavaScript">

			function activaTab(tab){
				$('.nav-tabs a[href="#' + tab + '"]').tab('show');
			};


			<cfoutput>
				var modalidadeProcesso = '#rsProcAval.pc_modalidade#'
				var numOrgaoAvaliado = '#rsProcAval.pc_num_orgao_avaliado#'
			</cfoutput>

							
			$(document).ready(function() {
				$("#accordionCadMelhoria").attr("hidden", false);

				//INICIALIZA O POPOVER NOS ÍCONES
				$(function () {
					$('[data-toggle="popover"]').popover()
				})	;
				$('.popover-dismiss').popover({
					trigger: 'hover'
				});

				$(function () {
					$('[data-mask]').inputmask()//mascara para os inputs
				});

				
				
				<cfoutput>
					var pc_aval_status = '#rsProcAval.pc_aval_status#';
					var pc_aval_processo = '#rsProcAval.pc_processo_id#';
				</cfoutput>
				
			
				if(pc_aval_status==2){
					$('#chatFooter').hide(500);
					$("#custom-tabs-one-6passo-tab").addClass("disabled")
					$("#custom-tabs-one-6passo-tab").removeClass("active")
					activaTab('custom-tabs-one-7passo');
					
				}

				if(pc_aval_status==3){
					activaTab('custom-tabs-one-6passo')
				}

				
				
				mostraTabAnexos();
					
				$('#custom-tabs-one-3passo-tab').click(function(){
					$('#anexoAvaliacaoDiv').html('')
					$('#tabOrientacoesDiv').html('')
					$('#tabMelhoriasDiv').html('')
					$('#pendenciasDiv').html('')
					mostraTabAnexos();
				});
				$('#custom-tabs-one-4passo-tab').click(function(){
					$('#anexoAvaliacaoDiv').html('')
					$('#tabAnexosDiv').html('')
					$('#tabMelhoriasDiv').html('')
					$('#pendenciasDiv').html('')
					$('#formAvalOrientacaoCadastroDiv').html('')
					mostraFormAvalOrientacaoCadastro();
					mostratabOrientacoes();
					
				});
				$('#custom-tabs-one-5passo-tab').click(function(){
					$('#anexoAvaliacaoDiv').html('')
					$('#tabAnexosDiv').html('')
					$('#tabOrientacoesDiv').html('')
					$('#pendenciasDiv').html('')
					mostraFormAvalMelhoriaCadastro();
					mostraTabMelhorias();
				});
				$('#custom-tabs-one-6passo-tab').click(function(){
					$('#anexoAvaliacaoDiv').html('')
					$('#tabAnexosDiv').html('')
					$('#tabOrientacoesDiv').html('')
					$('#tabMelhoriasDiv').html('')
					mostraPendencias();	
				});
				  
				<cfoutput>
					let modalidade = '#rsProcAval.pc_modalidade#'
				</cfoutput>

				// DropzoneJS 2 Demo Code Start
				Dropzone.autoDiscover = false

				// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
				var previewNode = document.querySelector("#template2")
				//previewNode.id = ""
				var previewTemplate ='';
				if (previewNode !== null) {
					var previewTemplate = previewNode.parentNode.innerHTML
					previewNode.parentNode.removeChild(previewNode)

					var myDropzone2 = new Dropzone("div#custom-tabs-one-3passo", { // Make the whole body a dropzone
						url: "cfc/pc_cfcAvaliacoes.cfc?method=uploadArquivos", // Set the url
						autoProcessQueue :true,
						thumbnailWidth: 80,
						thumbnailHeight: 80,
						parallelUploads: 1,
						maxFilesize:4,
						acceptedFiles: '.pdf,.xls,.xlsx,.zip',
						previewTemplate: previewTemplate,
						autoQueue: true, // Make sure the files aren't queued until manually added
						previewsContainer: "#previews2", // Define the container to display the previews
						clickable: "#anexos", // Define the element that should be used as click trigger to select files.
						headers: { "pc_aval_id":pc_aval_id, 
								"pc_aval_processo":pc_aval_processo, 
								"pc_anexo_avaliacaoPDF":"N",
								"arquivoParaTodosOsItens":"N"},//informar "S" se o arquivo deve ser exibido em todos os itens do processo
						init: function() {
							this.on('error', function(file, errorMessage) {	
								toastr.error(errorMessage);
							});
						}
						
					})

					

					// Update the total progress bar
					myDropzone2.on("totaluploadprogress", function(progress) {
						document.querySelector(".progress-bar").style.width = progress + "%"
					})

					myDropzone2.on("sending", function(file) {
						$('#modalOverlay').modal('show')
					})

					// Hide the total progress bar when nothing's uploading anymore
					myDropzone2.on("queuecomplete", function(progress) {
						//toastr.success("Arquivo(s) enviado(s) com sucesso!")
						myDropzone2.removeAllFiles(true);
						//$(".start").attr("hidden", true)
						//$(".cancel").attr("hidden", true)
						mostraTabAnexos();
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					})
				}

				
				

				
						
			})

			


			<cfoutput>
				var pc_aval_id = '#rsProcAval.pc_aval_id#'
			</cfoutput>
			
			$('#pcStatusMelhoria').on('change', function (event)  {
				if($('#pcStatusMelhoria').val()=='A'){
					$('#pcDataPrevDiv').attr('hidden', false)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)			
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', true)	

					$('#pcRecusaJustMelhoria').val('')
					$('#pcNovaAcaoMelhoria').val('')			
					$('#pcOrgaoRespSugeridoMelhoria').val('')	
				}
				if($('#pcStatusMelhoria').val()=='R'){
					$('#pcDataPrevDiv').attr('hidden', true)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', false)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', true)		

					$('#pcDataPrev').val('')
					$('#pcNovaAcaoMelhoria').val('')
					$('#pcOrgaoRespSugeridoMelhoria').val('')
				}
				if($('#pcStatusMelhoria').val()=='T'){
					$('#pcDataPrevDiv').attr('hidden', false)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', false)
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', false)		

					$('#pcRecusaJustMelhoria').val('')
				}
				


				if($('#pcStatusMelhoria').val()==null || $('#pcStatusMelhoria').val()=='N' || $('#pcStatusMelhoria').val()=='P'){
					$('#pcDataPrevDiv').attr('hidden', true)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', true)	

					$('#pcDataPrev').val('')
					$('#pcRecusaJustMelhoria').val('')
					$('#pcNovaAcaoMelhoria').val('')
					$('#pcOrgaoRespSugeridoMelhoria').val('')	
				}
			})
			
			
			$('#pcValidar').on('change', function (event)  {
				if($('#pcValidar').val() == '1'){
					$('#btValidarPasso7').show(500);
					$('#chatFooter').hide(500);
					$('html, body').animate({ scrollTop: ($('#btValidarPasso7').offset().top)} , 500);
				}
				
				if($('#pcValidar').val() == '2'){
					$('#btValidarPasso7').hide(500)
					$('#chatFooter').show(500);
					$('html, body').animate({ scrollTop: ($('#chatFooter').offset().top)} , 500);
				}	
			})

			function activaTab(tab){
				$('.nav-tabs a[href="#' + tab + '"]').tab('show');
			};

			
			$('#btCancelarMelhoria').on('click', function (event)  {
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()
				$('#pcMelhoria').val('') 
				$('#pcOrgaoRespMelhoria').val('') 
				$('#pcDataPrev').val('')
				$('#pcRecusaJustMelhoria').val('')
				$('#pcNovaAcaoMelhoria').val('')
				$('#pcOrgaoRespSugeridoMelhoria').val('')		
				$('#pcStatusMelhoria').val("P").trigger('change')

				$('#pcMelhoriaId').val('')
				$('#labelMelhoria').html('Proposta de Melhoria:')	
			});
			

			


			function mostraTabAnexos(){
				$('#modalOverlay').modal('show')
				setTimeout(function(){ 
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "tabAnexos",
							pc_aval_id: pc_aval_id,
							ehEdicao: "S"
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabAnexosDiv').html(result)
						
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
			
						});	
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

						
					})//fim fail
				}, 1000);
			}



			function mostraFormAvalOrientacaoCadastro(){
				
				setTimeout(function(){
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "formAvalOrientacaoCadastro",
							numOrgaoAvaliado: numOrgaoAvaliado

						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#formAvalOrientacaoCadastroDiv').html(result)
						//$("#accordionCadOrientacao").attr("hidden", true); 
						//move o scroll ate o id tabOrientacoesDiv
						$('html, body').animate({ scrollTop: ($('#tabOrientacoesDiv').offset().top)} , 500);
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					})//fim fail
				}, 500);
			}

           
			function mostraFormAvalMelhoriaCadastro(){
				
				setTimeout(function(){
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "formAvalMelhoriaCadastro",
							numOrgaoAvaliado: numOrgaoAvaliado,
							modalidade: modalidadeProcesso

						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#formAvalMelhoriaCadastroDiv').html(result)
						//$("#accordionCadMelhoria").attr("hidden", true); 
						//move o scroll ate o id tabMelhoriasDiv
						$('html, body').animate({ scrollTop: ($('#tabMelhoriasDiv').offset().top)} , 500);
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					})//fim fail
				}, 1000);
			}

			function mostratabOrientacoes(){
				$('#modalOverlay').modal('show')
				setTimeout(function(){
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "tabOrientacoes",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabOrientacoesDiv').html(result)
						$('html, body').animate({ scrollTop: ($('#custom-tabs-one-4passo-tab').offset().top)-60} , 500);
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});

					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
					})//fim fail
				}, 1000);
			}



			function mostraTabMelhorias(){
				$('#modalOverlay').modal('show')
				setTimeout(function(){
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "tabMelhorias",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabMelhoriasDiv').html(result)
						$('html, body').animate({ scrollTop: ($('#custom-tabs-one-5passo-tab').offset().top)-60} , 500);
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					})//fim fail
				}, 1000);
			}

			
			function mostraPendencias(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "verificaPendenciasRelato",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#pendenciasDiv').html(result)
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});	
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					})//fim fail
				}, 1000);
			}

			


		</script>
		
    </cffunction>

	
	<cffunction name="tabOrientacoes" returntype="any" access="remote" hint="Criar a tabela de medidas/orientações para regularização e envia para a páginas pc_CadastroRelato">

		<cfargument name="pc_aval_id" type="numeric" required="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsOrientacoes">
			Select pc_avaliacao_orientacoes.* , pc_orgaos.pc_org_sigla, pc_processos.pc_num_status
			FROM pc_avaliacao_orientacoes 
			LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				WHERE pc_aval_id = #arguments.pc_aval_id# 
			<cfelse>
				WHERE pc_aval_id = #arguments.pc_aval_id#  and pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' and pc_aval_orientacao_status in (2,4,5) 
			</cfif>
			order By pc_aval_orientacao_id desc
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
			
		<div class="row">
			<div class="col-12">
				<div class="card">
					<!-- /.card-header -->
					<div class="card-body">
						
						<table id="tabOrientacoes" class="table table-bordered table-hover  ">
							<thead style="background: #0083ca;color:#fff">
								<tr style="font-size:14px">
									<th>Controles</th>
									<th hidden >pc_aval_orientacao_id</th>
									<th hidden >pc_aval_orientacao_mcu_orgaoResp</th>
									<th hidden >pc_aval_orientacao_categoriaControle_id</th>
									<th hidden >pc_aval_orientacao_beneficioNaoFinanceiro</th>
									<th hidden >pc_aval_orientacao_beneficioFinanceiro</th>
									<th hidden >pc_aval_orientacao_custoFinanceiro</th>
									<th>Orientação</th>
									<th >Órgão Responsável</th>
								</tr>
							</thead>
						
							<tbody>
								<cfloop query="rsOrientacoes" >
									<cfquery name="rsCategoriasControlesOrientacoes" datasource="#application.dsn_processos#">
										SELECT pc_aval_categoriaControle_id FROM pc_avaliacao_orientacao_categoriasControles 
										WHERE pc_aval_orientacao_id = #pc_aval_orientacao_id#
									</cfquery>
									<cfset listaCategoriasControlesOrientacao = ValueList(rsCategoriasControlesOrientacoes.pc_aval_categoriaControle_id,',')>
									<cfoutput>

										<tr style="font-size:12px;color:##000" >
											
											<td style="text-align: center; vertical-align:middle !important;width:10%">	
												<div style="display:flex;justify-content:space-around;">
													<i id="btEditarOrientacao" class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:5px" onClick="javascript:editarOrientacao(this);"   title="Editar" ></i>
												</div>
											</td>													
											<td hidden >#pc_aval_orientacao_id#</td>
											<td hidden>#pc_aval_orientacao_mcu_orgaoResp#</td>
											<td hidden>#listaCategoriasControlesOrientacao#</td>
											<td hidden>#pc_aval_orientacao_beneficioNaoFinanceiro#</td>
											<td hidden>#pc_aval_orientacao_beneficioFinanceiro#</td>
											<td hidden>#pc_aval_orientacao_custoFinanceiro#</td>
											<td style="vertical-align:middle !important"><textarea class="textareaTab" rows="2" disabled>#pc_aval_orientacao_descricao#</textarea></td>
											<td style="vertical-align:middle !important;width:20%">#pc_org_sigla#</td>
										</tr>
									</cfoutput>
								</cfloop>	
							</tbody>
								
							
						</table>
					</div>

					<!-- /.card-body -->
				</div>
				<!-- /.card -->
			</div>
		<!-- /.col -->
		</div>
		<!-- /.row -->
		<script language="JavaScript">
			$(function () {
				
				$("#tabOrientacoes").DataTable({
					destroy: true,
					stateSave: false,
					responsive: true, 
					lengthChange: false, 
					utoWidth: false,
					select: true,
					searching:false,
					columnDefs: [
						{ "className": "dt-center", "targets": "_all" } // Alinha todos os elementos verticalmente
					]
				});
					
			});

			function formatCurrency(value) {
				// Formata o valor como moeda brasileira
				let formatter = new Intl.NumberFormat('pt-BR', {
					style: 'currency',
					currency: 'BRL',
					minimumFractionDigits: 2
				});
				return formatter.format(value);
			}

			// Função de validação customizada
			function validateButtonGroupsOrientacao() {
				var isValid = true;

				$("#formAvalOrientacaoCadastro .btn-group").each(function() {
					var $group = $(this);
					var hasActive = $group.find(".active").length > 0;
					var $error = $group.next("span.error");

					if (!hasActive) {
						$group.addClass("is-invalid").removeClass("is-valid");
						if ($error.length === 0) {
							$("<span class='error invalid-feedback' >Selecione uma opção.</span>").insertAfter($group);
						}
						isValid = false;
					} else {
						$group.removeClass("is-invalid").addClass("is-valid");
						$error.remove();
					}
				});

				return isValid;
			}

			function editarOrientacao(linha) {
				event.preventDefault()
				event.stopPropagation()
				$('#modalOverlay').modal('show')
				//$("#accordionCadOrientacao").attr("hidden", true);
				mostraFormAvalOrientacaoCadastro()
				setTimeout(function(){ 
					$('#labelOrientacao').html('Editar Medida/Orientação para Regularização:')
					
					// Limpa as classes de validação
					//$('#formAvalOrientacaoCadastro').find('.is-valid, .is-invalid').removeClass('is-valid is-invalid');
					
					$(linha).closest("tr").children("td:nth-child(5)").click();//seleciona a linha onde o botão foi clicado	
					var pc_aval_orientacao_id = $(linha).closest("tr").children("td:nth-child(2)").text();
					var pc_aval_orientacao_mcu_orgaoResp = $(linha).closest("tr").children("td:nth-child(3)").text();
					var pc_aval_orientacao_categoriaControle_id = $(linha).closest("tr").children("td:nth-child(4)").text();
					var pc_aval_orientacao_beneficioNaoFinanceiro = $(linha).closest("tr").children("td:nth-child(5)").text();
					var pc_aval_orientacao_beneficioFinanceiro = $(linha).closest("tr").children("td:nth-child(6)").text();
					var pc_aval_orientacao_custoFinanceiro = $(linha).closest("tr").children("td:nth-child(7)").text();
					var pc_aval_orientacao_descricao = $(linha).closest("tr").children("td:nth-child(8)").text();
					
					$('#pcOrientacaoId').val(pc_aval_orientacao_id).trigger('change');
					$('#pcOrientacao').val(pc_aval_orientacao_descricao).trigger('change');
					$('#pcOrgaoRespOrientacao').val(pc_aval_orientacao_mcu_orgaoResp).trigger('change');
					// Divide a string em um array
					var valoresArray = pc_aval_orientacao_categoriaControle_id.split(',');
					// Atribue o array ao select e acione o evento 'change'
                   
					$('#pcAvalOrientacaoCategoriaControle').val(valoresArray).trigger('change');
					

					
					$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').val(pc_aval_orientacao_beneficioNaoFinanceiro).trigger('change');
					$('#pcValorBeneficioFinanceiro').val(formatCurrency(pc_aval_orientacao_beneficioFinanceiro)).trigger('change');
					$('#pcValorCustoFinanceiro').val(formatCurrency(pc_aval_orientacao_custoFinanceiro)).trigger('change');

					if($('#pcAvalOrientacaoCategoriaControle').val()!='' && $('#pcAvalOrientacaoCategoriaControle').val()!=null){
						
						// Inicializa o estado dos botões com base no valor de pcAvalOrientacaoBenefNaoFinanceiroDesc
						if ($('#pcAvalOrientacaoBenefNaoFinanceiroDesc').val() === '') {
							$('#btn-nao-aplica').addClass('active btn-dark').removeClass('btn-light');
							$('#btn-descricao').removeClass('active btn-primary').addClass('btn-light');
							$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').hide();
						} else {
							$('#btn-descricao').addClass('active btn-primary').removeClass('btn-light');
							$('#btn-nao-aplica').removeClass('active btn-dark').addClass('btn-light');
							$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').show();
						}

						// Inicializa o estado dos botões com base no valor de pcValorBeneficioFinanceiro
						if ($('#pcValorBeneficioFinanceiro').val() == 0) {
							$('#btn-nao-aplica-BeneficioFinanceiro').addClass('active btn-dark').removeClass('btn-light');
							$('#btn-quantificado-BeneficioFinanceiro').removeClass('active btn-primary').addClass('btn-light');
							$('#pcValorBeneficioFinanceiro').hide();
						} else {
							$('#btn-quantificado-BeneficioFinanceiro').addClass('active btn-primary').removeClass('btn-light');
							$('#btn-nao-aplica-BeneficioFinanceiro').removeClass('active btn-dark').addClass('btn-light');
							$('#pcValorBeneficioFinanceiro').show();
						}
		
						// Inicializa o estado dos botões com base no valor de pcValorCustoFinanceiro
						if ($('#pcValorCustoFinanceiro').val() == 0) {
							$('#btn-nao-aplica-CustoFinanceiro').addClass('active btn-dark').removeClass('btn-light');
							$('#btn-quantificado-CustoFinanceiro').removeClass('active btn-primary').addClass('btn-light');
							$('#pcValorCustoFinanceiro').hide();
						} else {
							$('#btn-quantificado-CustoFinanceiro').addClass('active btn-primary').removeClass('btn-light');
							$('#btn-nao-aplica-CustoFinanceiro').removeClass('active btn-dark').addClass('btn-light');
							$('#pcValorCustoFinanceiro').show();
						}
					}else{
						if($('#pcAvalOrientacaoCategoriaControle-error').length === 0){
							$('#pcAvalOrientacaoCategoriaControle').closest(".form-group").append('<div id="pcAvalOrientacaoCategoriaControle-error" class="error invalid-feedback">Selecione, pelo menos, uma opção.</div>');
						}
						$('#btn-nao-aplica').addClass('btn-light').removeClass('active btn-dark');
						$('#btn-descricao').removeClass('active btn-primary').addClass('btn-light');
						$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').hide();
						$('#btn-nao-aplica-BeneficioFinanceiro').addClass('btn-light').removeClass('active btn-dark');
						$('#btn-quantificado-BeneficioFinanceiro').removeClass('active btn-primary').addClass('btn-light');
						$('#pcValorBeneficioFinanceiro').hide();
						$('#btn-nao-aplica-CustoFinanceiro').addClass('btn-light').removeClass('active btn-dark');
						$('#btn-quantificado-CustoFinanceiro').removeClass('active btn-primary').addClass('btn-light');
						$('#pcValorCustoFinanceiro').hide();

					}

					validateButtonGroupsOrientacao();	

					
					//$("#accordionCadOrientacao").attr("hidden", false); 
					$('#cabecalhoAccordionCadOrientacao').text("Editar Medida/Orientação para Regularização ID:" + ' ' + pc_aval_orientacao_id);
					$('#infoTipoCadOrientacao').text("Editando Medida/Orientação para Regularização ID:" + ' ' + pc_aval_orientacao_id);

					$('#cadOrientacao').CardWidget('expand')

					$('html, body').animate({ scrollTop: ($('#cadOrientacao').offset().top - 80)} , 500); 
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
				}, 1000);
			};	


		</script>				

	</cffunction>

	

	<cffunction name="tabMelhorias" returntype="any" access="remote" hint="Criar a tabela de propostas de melhoria e envia para a páginas pc_CadastroRelato">

		<cfargument name="pc_aval_id" type="numeric" required="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
			Select pc_avaliacao_melhorias.* , pc_orgaos.pc_org_sigla, pc_orgaoSug.pc_org_sigla as siglaOrgSug
			FROM pc_avaliacao_melhorias 
			LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao
			LEFT JOIN pc_orgaos as pc_orgaoSug ON pc_orgaoSug.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				WHERE pc_aval_melhoria_num_aval = #arguments.pc_aval_id# 
			<cfelse>
				WHERE pc_aval_melhoria_num_aval = #arguments.pc_aval_id# and pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			</cfif>
			order By pc_aval_melhoria_id desc
			
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status,pc_processos.pc_modalidade  FROM pc_avaliacoes 
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>

		<div class="row">
			<div class="col-12">
				<div class="card">
					<!-- /.card-header -->
					<div class="card-body">
						
						<table id="tabMelhorias" class="table table-bordered  table-hover ">
							<thead style="background: #0083ca;color:#fff">
								<tr style="font-size:14px">
									
									<th style="width: 10%;vertical-align:middle !important;">Controles</th>
									<th hidden></th>
									<th hidden></th>
									<th hidden></th>
									<th hidden></th>
									<th style="width: <cfif #rsStatus.pc_modalidade# neq 'E'>30%<cfelse>50%</cfif>;vertical-align:middle !important;">Melhoria:</th>
									<th style="vertical-align:middle !important;">Órgão Responsável:</th>
									<th style="vertical-align:middle !important;">Status: </th>
									<cfif #rsStatus.pc_modalidade# neq 'E'>
										<th style="vertical-align:middle !important;">Data Prevista: </th>
										<th style="vertical-align:middle !important;">Órgão Responsável <br>(sugerido pelo órgão): </th>
										<th style="vertical-align:middle !important;">Justificativa do órgão: </th>
										<th style="vertical-align:middle !important;">Sugestão de Melhoria<br> (sugerida pelo órgão): </th>
									</cfif>
									<th hidden></th>
									<th hidden></th>
									<th hidden></th>
									<th hidden></th>
									



								</tr>
							</thead>
						
							<tbody>
								<cfloop query="rsMelhorias" >
									<cfquery name="rsCategoriasControlesMelhorias" datasource="#application.dsn_processos#">
										SELECT pc_aval_categoriaControle_id FROM pc_avaliacao_melhoria_categoriasControles 
										WHERE pc_aval_melhoria_id = #pc_aval_melhoria_id#
									</cfquery>
									<cfset listaCategoriasControlesMelhoria = ValueList(rsCategoriasControlesMelhorias.pc_aval_categoriaControle_id,',')>
									
									<cfoutput>					
										<cfswitch expression="#pc_aval_melhoria_status#">
											<cfcase value="P">
												<cfset statusMelhoria = "PENDENTE">
											</cfcase>
											<cfcase value="A">
												<cfset statusMelhoria = "ACEITA">
											</cfcase>
											<cfcase value="R">
												<cfset statusMelhoria = "RECUSA">
											</cfcase>
											<cfcase value="T">
												<cfset statusMelhoria = "TROCA">
											</cfcase>
											<cfcase value="N">
												<cfset statusMelhoria = "NÃO INFORMADO">
											</cfcase>
											<cfcase value="B">
												<cfset statusMelhoria = "BLOQUEADO">
											</cfcase>
											<cfdefaultcase>
												<cfset statusMelhoria = "">	
											</cfdefaultcase>
											
										</cfswitch>
										<tr style="font-size:12px;color:##000" >
											
											<td style="text-align: center; vertical-align:middle !important;width:10%">	
												<div style="display:flex;justify-content:space-around;">
													<i id="btExcluirMelhoria" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px"   onClick="javascript:excluirMelhoria(#pc_aval_melhoria_id#)" title="Excluir" ></i>
													<i id="btEditarMelhoria" class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:5px" onClick="javascript:editarMelhoria(this);"   title="Editar" ></i>
												</div>
											</td>													
											
											<td hidden>#pc_aval_melhoria_id#</td>
											<td hidden>#pc_aval_melhoria_num_orgao#</td>
											<td hidden>#pc_aval_melhoria_sug_orgao_mcu#</td>
											<td hidden>#pc_aval_melhoria_dataPrev#</td>
											<td style="vertical-align:middle !important;"><textarea class="textareaTab" rows="2"  disabled>#pc_aval_melhoria_descricao#</textarea></td>
											<td style="vertical-align:middle !important;">#pc_org_sigla#</td>
											<td style="vertical-align:middle !important;">#statusMelhoria#</td>
											<cfif #rsStatus.pc_modalidade# neq 'E'>
												<cfset dataHora = DateFormat(#pc_aval_melhoria_dataPrev#,'DD-MM-YYYY')>
												<td style="vertical-align:middle !important;">#dataHora#</td>
												<td style="vertical-align:middle !important;">#siglaOrgSug#</td>
												<td style="vertical-align:middle !important;"><textarea class="textareaTab" rows="2" disabled>#pc_aval_melhoria_naoAceita_justif#</textarea></td>
												<td style="vertical-align:middle !important;"><textarea class="textareaTab" rows="2" disabled>#pc_aval_melhoria_sugestao#</textarea></td>
											</cfif>
											<td hidden>#listaCategoriasControlesMelhoria#</td>
											<td hidden>#pc_aval_melhoria_beneficioNaoFinanceiro#</td>
											<td hidden>#pc_aval_melhoria_beneficioFinanceiro#</td>
											<td hidden>#pc_aval_melhoria_custoFinanceiro#</td>
										
										</tr>
									</cfoutput>
								</cfloop>	
							</tbody>
								
							
						</table>
					</div>

					<!-- /.card-body -->
				</div>
				<!-- /.card -->
			</div>
		<!-- /.col -->
		</div>
		<!-- /.row -->
		<script language="JavaScript">
			$(function () {
				
				$("#tabMelhorias").DataTable({
					destroy: true,
					stateSave: false,
					responsive: true, 
					lengthChange: false, 
					autoWidth: false,
					select: true,
					searching:false,
					columnDefs: [
						{ "className": "dt-center", "targets": "_all" } // Alinha todos os elementos verticalmente
					]
				})

			});

			function formatCurrency(value) {
				// Formata o valor como moeda brasileira
				let formatter = new Intl.NumberFormat('pt-BR', {
					style: 'currency',
					currency: 'BRL',
					minimumFractionDigits: 2
				});
				return formatter.format(value);
			}

			// Função de validação customizada
			function validateButtonGroupsMelhoria() {
				var isValid = true;

				$("#formAvalMelhoriaCadastro .btn-group").each(function() {
					var $group = $(this);
					var hasActive = $group.find(".active").length > 0;
					var $error = $group.next("span.error");

					if (!hasActive) {
						$group.addClass("is-invalid").removeClass("is-valid");
						if ($error.length === 0) {
							$("<span class='error invalid-feedback' >Selecione uma opção.</span>").insertAfter($group);
						}
						isValid = false;
					} else {
						$group.removeClass("is-invalid").addClass("is-valid");
						$error.remove();
					}
				});

				return isValid;
			}

			function editarMelhoria(linha) {
				event.preventDefault()
				event.stopPropagation()
				mostraFormAvalMelhoriaCadastro();
				$('#modalOverlay').modal('show')
				setTimeout(function(){ 
					$('#labelMelhoria').html('Editar Proposta de Melhoria:')

					<cfoutput> 
						var modalidade = '#rsStatus.pc_modalidade#'; 
						var dataPrevista = '#rsMelhorias.pc_aval_melhoria_dataPrev#';
						var orgaoSugerido = '#rsMelhorias.pc_aval_melhoria_sug_orgao_mcu#';
						var naoAceita_justif = '#rsMelhorias.pc_aval_melhoria_naoAceita_justif#';
						var sugestao = '#rsMelhorias.pc_aval_melhoria_sugestao#';
					</cfoutput>
					
					$(linha).closest("tr").children("td:nth-child(6)").click();//seleciona a linha onde o botão foi clicado	
					var pc_aval_melhoria_id = $(linha).closest("tr").children("td:nth-child(2)").text();
					var pc_aval_melhoria_num_orgao = $(linha).closest("tr").children("td:nth-child(3)").text();
					var pc_aval_melhoria_sug_orgao_mcu = $(linha).closest("tr").children("td:nth-child(4)").text();
					var pc_aval_melhoria_dataPrev = $(linha).closest("tr").children("td:nth-child(5)").text()
					var pc_aval_melhoria_descricao = $(linha).closest("tr").children("td:nth-child(6)").text();
					
					
					
					var pc_aval_melhoria_status = "";

					switch( $(linha).closest("tr").children("td:nth-child(8)").text()) {
						case "PENDENTE":
							pc_aval_melhoria_status = "P"
						break;
						case "ACEITA":
							pc_aval_melhoria_status = "A"
						break;
						case "RECUSA":
							pc_aval_melhoria_status = "R"
						break;
						case "TROCA":
							pc_aval_melhoria_status = "T"
						break;
						case "NÃO INFORMADO":
							pc_aval_melhoria_status = "N"
						break;
						case "BLOQUEADO":
							pc_aval_melhoria_status = "B"
						break;

						default:
							pc_aval_melhoria_status = ""
					}  
					
					


					if(modalidade != 'E'){
						var pc_aval_melhoria_dataPrev = $(linha).closest("tr").children("td:nth-child(9)").text();
						var pc_aval_melhoria_sug_orgao_mcu = $(linha).closest("tr").children("td:nth-child(10)").text();
						var pc_aval_melhoria_naoAceita_justif = $(linha).closest("tr").children("td:nth-child(11)").text();
						var pc_aval_melhoria_sugestao = $(linha).closest("tr").children("td:nth-child(12)").text();
						var pc_aval_melhoria_categoriaControle_id = $(linha).closest("tr").children("td:nth-child(13)").text();
						var pc_aval_melhoria_beneficioNaoFinanceiro = $(linha).closest("tr").children("td:nth-child(14)").text();
						var pc_aval_melhoria_beneficioFinanceiro = $(linha).closest("tr").children("td:nth-child(15)").text();
						var pc_aval_melhoria_custoFinanceiro = $(linha).closest("tr").children("td:nth-child(16)").text();
					}else{
						var pc_aval_melhoria_dataPrev = dataPrevista;
						var pc_aval_melhoria_sug_orgao_mcu = orgaoSugerido;
						var pc_aval_melhoria_naoAceita_justif =naoAceita_justif;
						var pc_aval_melhoria_sugestao = sugestao;
						var pc_aval_melhoria_categoriaControle_id = $(linha).closest("tr").children("td:nth-child(9)").text();
						var pc_aval_melhoria_beneficioNaoFinanceiro = $(linha).closest("tr").children("td:nth-child(10)").text();
						var pc_aval_melhoria_beneficioFinanceiro = $(linha).closest("tr").children("td:nth-child(11)").text();
						var pc_aval_melhoria_custoFinanceiro = $(linha).closest("tr").children("td:nth-child(12)").text();
					}
					
					$('#pcMelhoriaId').val(pc_aval_melhoria_id).trigger('change');
					$('#pcMelhoria').val(pc_aval_melhoria_descricao).trigger('change');
					$('#pcOrgaoRespMelhoria').val(pc_aval_melhoria_num_orgao).trigger('change');

					$('#pcStatusMelhoria').val(pc_aval_melhoria_status).trigger('change');
					$('#pcDataPrev').val(pc_aval_melhoria_dataPrev).trigger('change');
					$('#pcOrgaoRespSugeridoMelhoria').val(pc_aval_melhoria_sug_orgao_mcu).trigger('change');
					$('#pcRecusaJustMelhoria').val(pc_aval_melhoria_naoAceita_justif).trigger('change');
					$('#pcNovaAcaoMelhoria').val(pc_aval_melhoria_sugestao).trigger('change');

					// Divide a string em um array
					var valoresArray = pc_aval_melhoria_categoriaControle_id.split(',');
					// Atribue o array ao select e acione o evento 'change'
					$('#pcAvalMelhoriaCategoriaControle').val(valoresArray).trigger('change');
					
					$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').val(pc_aval_melhoria_beneficioNaoFinanceiro).trigger('change');
					$('#pcValorBeneficioFinanceiroMelhoria').val(formatCurrency(pc_aval_melhoria_beneficioFinanceiro)).trigger('change');
					$('#pcValorCustoFinanceiroMelhoria').val(formatCurrency(pc_aval_melhoria_custoFinanceiro)).trigger('change');
					if($('#pcAvalMelhoriaCategoriaControle').val()!='' && $('#pcAvalMelhoriaCategoriaControle').val()!=null){
						// Inicializa o estado dos botões com base no valor de pcAvalMelhoriaBenefNaoFinanceiroDesc
						if ($('#pcAvalMelhoriaBenefNaoFinanceiroDesc').val() === '') {
							$('#btn-nao-aplicaMelhoria').addClass('active btn-dark').removeClass('btn-light');
							$('#btn-descricaoMelhoria').removeClass('active btn-primary').addClass('btn-light');
							$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').hide();
						} else {
							$('#btn-descricaoMelhoria').addClass('active btn-primary').removeClass('btn-light');
							$('#btn-nao-aplicaMelhoria').removeClass('active btn-dark').addClass('btn-light');
							$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').show();
						}

						// Inicializa o estado dos botões com base no valor de pcValorBeneficioFinanceiropcValorBeneficioFinanceiro
						if ($('#pcValorBeneficioFinanceiroMelhoria').val() == 0) {
							$('#btn-nao-aplica-BeneficioFinanceiroMelhoria').addClass('active btn-dark').removeClass('btn-light');
							$('#btn-quantificado-BeneficioFinanceiroMelhoria').removeClass('active btn-primary').addClass('btn-light');
							$('#pcValorBeneficioFinanceiroMelhoria').hide();
						} else {
							$('#btn-quantificado-BeneficioFinanceiroMelhoria').addClass('active btn-primary').removeClass('btn-light');
							$('#btn-nao-aplica-BeneficioFinanceiroMelhoria').removeClass('active btn-dark').addClass('btn-light');
							$('#pcValorBeneficioFinanceiroMelhoria').show();
						}

						// Inicializa o estado dos botões com base no valor de pcValorCustoFinanceiro
						if ($('#pcValorCustoFinanceiroMelhoria').val() == 0) {
							$('#btn-nao-aplica-CustoFinanceiroMelhoria').addClass('active btn-dark').removeClass('btn-light');
							$('#btn-quantificado-CustoFinanceiroMelhoria').removeClass('active btn-primary').addClass('btn-light');
							$('#pcValorCustoFinanceiroMelhoria').hide();
						} else {
							$('#btn-quantificado-CustoFinanceiroMelhoria').addClass('active btn-primary').removeClass('btn-light');
							$('#btn-nao-aplica-CustoFinanceiroMelhoria').removeClass('active btn-dark').addClass('btn-light');
							$('#pcValorCustoFinanceiroMelhoria').show();
						}
					}else{
						if ($('#pcAvalMelhoriaCategoriaControle-error').length === 0 || $('#pcAvalMelhoriaCategoriaControle-error').length === undefined || $('#pcAvalMelhoriaCategoriaControle-error').length === null) {
							$('#pcAvalMelhoriaCategoriaControle').closest(".form-group").append('<div id="pcAvalMelhoriaCategoriaControle-error" class="error invalid-feedback">Selecione, pelo menos, uma opção.</div>');
						}

						$('#btn-nao-aplicaMelhoria').addClass('btn-light').removeClass('active btn-dark');
						$('#btn-descricaoMelhoria').removeClass('active btn-primary').addClass('btn-light');
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').hide();
						$('#btn-nao-aplica-BeneficioFinanceiroMelhoria').addClass('btn-light').removeClass('active btn-dark');
						$('#btn-quantificado-BeneficioFinanceiroMelhoria').removeClass('active btn-primary').addClass('btn-light');
						$('#pcValorBeneficioFinanceiroMelhoria').hide();
						$('#btn-nao-aplica-CustoFinanceiroMelhoria').addClass('btn-light').removeClass('active btn-dark');
						$('#btn-quantificado-CustoFinanceiroMelhoria').removeClass('active btn-primary').addClass('btn-light');
						$('#pcValorCustoFinanceiroMelhoria').hide();
					}
					validateButtonGroupsMelhoria();	
                    $("#div_pcStatusMelhoria").prop('hidden', false);
					//$("#accordionCadMelhoria").attr("hidden", false); 
					$('#cabecalhoAccordionCadMelhoria').text("Editar Proposta de Melhoria ID:" + ' ' + pc_aval_melhoria_id);
					$('#infoTipoCadMelhoria').text("Editando Proposta de Melhoria ID:" + ' ' + pc_aval_melhoria_id);
					
					$('#cadMelhoria').CardWidget('expand')
					
					$('html, body').animate({ scrollTop: ($('#cadMelhoria').offset().top - 80)} , 500); 
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
				}, 1000);
			};	

			function excluirMelhoria(pc_aval_melhoria_id)  {
				event.preventDefault()
				event.stopPropagation()

				var dataEditor = $('.editor').html();
				var mensagem = "Deseja excluir esta Proposta de Melhoria?"
				swalWithBootstrapButtons.fire({//sweetalert2
				html: logoSNCIsweetalert2(mensagem),
				showCancelButton: true,
				confirmButtonText: 'Sim!',
				cancelButtonText: 'Cancelar!'
				}).then((result) => {
					if (result.isConfirmed) {
						$('#modalOverlay').modal('show');
						setTimeout(function() {
							$.ajax({
								type: "post",
								url: "cfc/pc_cfcAvaliacoes.cfc",
								data:{
									method: "delMelhorias",
									pc_aval_melhoria_id: pc_aval_melhoria_id
								},
								async: false
							})//fim ajax
							.done(function(result) {	
								mostraTabMelhorias();
								toastr.success('Operação realizada com sucesso!');
								mostraFormAvalMelhoriaCadastro();
							})//fim done
							.fail(function(xhr, ajaxOptions, thrownError) {
								$('#modalOverlay').delay(800).hide(0, function() {
									$('#modalOverlay').modal('hide');
								});
								$('#modal-danger').modal('show')
								$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
								$('#modal-danger').find('.modal-body').text(thrownError)

							})//fim fail

						}, 500);
					}else {
						// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
						$('#modalOverlay').modal('hide');
						Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
					}
				})
				
			};

		</script>				

	</cffunction>


	<cffunction name="formAvalOrientacaoCadastro" access="remote" hint="Formulário de cadastro de Orientações">
        
		<cfargument name="numOrgaoAvaliado" type="string" required="true"/>
        
		<div id="accordionCadOrientacao"  style="display: flex; justify-content: left;">
			<div  id="cadOrientacao" class="card card-primary collapsed-card" >
				<div id="btnCadastrarOrientacao" class="card-header text-left" style="background-color: #0083ca;color:#fff;">
					<a class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:14px;" data-card-widget="collapse">
						<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
						</button></i><span id="cabecalhoAccordionCadOrientacao">Clique aqui para cadastrar uma Medida/Orientação para Regularização</span>
					</a>
				</div>
				<div class="card-body" style="border: solid 3px #0083ca;" >
					<div class="card card-default">
						<div class="card-body p-0">
							<h7  class="font-weight-light text-center" style="top:-15px;font-size:14px!important;color:#00416B;position:absolute;width:100%;left:50%;transform:translateX(-50%);">
								<span id="infoTipoCadOrientacao" style=" background-color:#fff;border:1px solid rgb(229, 231, 235);padding-left:7px;padding-right:7px;border-radius: 5px;">Cadastrando Nova Medida/Orientação para Regularização:</span>
							</h7>
							<form   id="formAvalOrientacaoCadastro" name="formAvalOrientacaoCadastro" style="padding:10px"  onsubmit="return false" novalidate>
								<style>
									label{
										font-size: 0.8rem;
									}
									.btnValorNaoSeAplica{
										border-radius: 25px 0 0 25px !important;
									}

									.btnValorQuantificado{
										border-radius: 0 25px 25px 0 !important;
									}
								</style>
								<input id="pcOrientacaoId" hidden>
								<div class="row" style="font-size:14px">
									<div class="col-sm-12">
										<div class="form-group">
											<label id="labelOrientacao" for="pcOrientacao">Orientação:</label>
											<textarea class="form-control" id="pcOrientacao" rows="2" required=""  name="pcOrientacao" class="form-control"></textarea>
										</div>										
									</div>

									<cfquery name="rs_OrgAvaliado" datasource="#application.dsn_processos#">
										SELECT pc_orgaos.*
										FROM pc_orgaos
										WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#arguments.numOrgaoAvaliado#' or pc_org_mcu = '#arguments.numOrgaoAvaliado#' 
												or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND pc_org_mcu_subord_tec = '#arguments.numOrgaoAvaliado#'))
										ORDER BY pc_org_sigla
									</cfquery>
									
									<div class="col-sm-4">
										<div class="form-group">
											<label for="pcOrgaoRespOrientacao">Órgão Responsável:</label>
											<select id="pcOrgaoRespOrientacao" required="" name="pcOrgaoRespOrientacao" class="form-control"  style="height:40px">
												<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
												<cfoutput query="rs_OrgAvaliado">
													<option value="#pc_org_mcu#">#pc_org_sigla#</option>
												</cfoutput>
											</select>
										</div>
									</div>
									<cfquery name="rsAvalOrientacaoCategoriaControle" datasource="#application.dsn_processos#">
										SELECT pc_avaliacao_categoriaControle.*
										FROM pc_avaliacao_categoriaControle
										WHERE  pc_aval_categoriaControle_status = 'A'
									</cfquery>
									<div class="col-sm-8">
										<div class="form-group">
											<label for="pcAvalOrientacaoCategoriaControle" >Categoria do Controle Proposto:</label>
											<select id="pcAvalOrientacaoCategoriaControle" required="" name="pcAvalOrientacaoCategoriaControle" class="form-control" multiple="multiple">
												<cfoutput query="rsAvalOrientacaoCategoriaControle">
													<option value="#pc_aval_categoriaControle_id#">#pc_aval_categoriaControle_descricao#</option>
												</cfoutput>
											</select>
										</div>
									</div>

									<div class="col-sm-12">
										<fieldset style="padding:0px!important">
											<legend style="margin-left:20px">Benefício Não Financeiro da Medida/Orientação para Regularização:</legend>
											<div class="form-group d-flex align-items-center" style="margin-left:20px">
												
												<div id="btn_groupAvalOrientacaoBenefNaoFinanceiro" name="btn_groupAvalOrientacaoBenefNaoFinanceiro" class="btn-group mr-4" role="group" aria-label="Basic example">
													<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplica" id="btn-nao-aplica" name="btn-nao-aplica"  style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
													<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificado" id="btn-descricao" name="btn-descricao" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Descrever</button>
												</div>
												
												<div style="width:100%;position:relative;margin-top:13px">
													<div class="form-group">
														<textarea class="form-control" id="pcAvalOrientacaoBenefNaoFinanceiroDesc" name="pcAvalOrientacaoBenefNaoFinanceiroDesc" style="display: none;margin-right:10px;width:98%" rows="3" name="pcAvalOrientacaoBenefNaoFinanceiro" class="form-control" placeholder="Informe os Benefícios não financeiros..."></textarea>
													</div>
												</div>
											</div>
										</fieldset>
									</div>
										

									<div class="col-sm-12">	
										<fieldset style="margin-top:20px;padding:0px!important">
											<legend style="margin-left:20px">Potencial Benefício Financeiro da Implementação da Medida/Orientação para Regularização:</legend>
											<div class="form-group d-flex align-items-center"  style="margin-left:20px">
												<div id="btn_groupValorBeneficioFinanceiro" name="btn_groupValorBeneficioFinanceiro" class="btn-group mr-4" role="group" aria-label="Basic example">
													<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplica" id="btn-nao-aplica-BeneficioFinanceiro" name="btn-nao-aplica-BeneficioFinanceiro" style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
													<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificado" id="btn-quantificado-BeneficioFinanceiro" name="btn-quantificado-BeneficioFinanceiro" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Quantificado</button>
												</div>
												<div style="display:flex">
													<input id="pcValorBeneficioFinanceiro" name="pcValorBeneficioFinanceiro" style="display: none;margin-right:10px;height: 29px;" type="text" class="form-control money" inputmode="text" placeholder="R$ 0,00">
												</div>
											</div>
										</fieldset>
									</div>

									<div class="col-sm-12">	
										<fieldset style="margin-top:20px;padding:0px!important">
											<legend style="margin-left:20px">Estimativa do Custo Financeiro da Medida/Orientação para Regularização:</legend>
											<div class="form-group d-flex align-items-center"  style="margin-left:20px">
												<div id="btn_groupValorCustoFinanceiro" name="btn_groupValorCustoFinanceiro" class="btn-group mr-4" role="group" aria-label="Basic example">
													<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplica" id="btn-nao-aplica-CustoFinanceiro" name="btn-nao-aplica-CustoFinanceiro" style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
													<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificado" id="btn-quantificado-CustoFinanceiro" name="btn-quantificado-CustoFinanceiro" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Quantificado</button>
												</div>
												<div style="display:flex">
													<input id="pcValorCustoFinanceiro" name="pcValorCustoFinanceiro" style="display: none;margin-right:10px;height: 29px;" type="text" class="form-control money" inputmode="text" placeholder="R$ 0,00">
												</div>
											</div>
										</fieldset>
										
									</div>

									<div style="justify-content:center; display: flex; width: 100%;">
										<div>
											<button id="btSalvarOrientacao"  class="btn btn-block  " style="background-color:#0083ca;color:#fff">Salvar</button>
										</div>
										<div style="margin-left:100px">
											<button id="btCancelarOrientacao"  class="btn btn-block btn-danger " >Cancelar</button>
										</div>
										
									</div>	
								</div>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>

		<script language="JavaScript">
			$(".money").inputmask( 'currency',{"autoUnmask": true,
				radixPoint:",",
				groupSeparator: ".",
				allowMinus: false,
				prefix: 'R$ ',            
				digits: 2,
				digitsOptional: false,
				rightAlign: true,
				unmaskAsNumber: true
			});

			$(function () {
				$('[data-mask]').inputmask()
			})

			$(document).ready(function() {

				$('#btnCadastrarOrientacao').on('expanded.lte.cardwidget', function() {
					//move o cursor para o id btnCadastrarOrientacao
					$('html, body').animate({
						scrollTop: $("#btnCadastrarOrientacao").offset().top-60
					}, 1000);
				});
				
				//Initialize Select2 Elements
				// as exceções são os selects que não devem ser inicializados com o select2 e que estão em todas as páginas que utilizam este componente.
				$('select').not('[name="tabProcAcompCards_length"], [name="tabAvaliacoes_length"], [name="tabProcCards_length"], [name="tabAvaliacoes2024_length"], [name="tabItens_length"]').select2({
					theme: 'bootstrap4',
					placeholder: 'Selecione...',
					allowClear: true
					
				});
				
				
				// Função de validação customizada
				function validateButtonGroupsOrientacao() {
					var isValid = true;
					$("#formAvalOrientacaoCadastro .btn-group").each(function() {
						var $group = $(this);
						var hasActive = $group.find(".active").length > 0;
						var $error = $group.next("span.error");

						if (!hasActive) {
							$group.addClass("is-invalid").removeClass("is-valid");
							if ($error.length === 0) {
								$("<span class='error invalid-feedback' >Selecione uma opção.</span>").insertAfter($group);
							}
							isValid = false;
						} else {
							$group.removeClass("is-invalid").addClass("is-valid");
							$error.remove();
						}
					});

					return isValid;
				}

				// Adiciona o método de validação personalizado para múltipla seleção
				$.validator.addMethod("atLeastOneSelected", function(value, element) {
					return $(element).find('option:selected').length > 0;
				}, "Pelo menos uma opção deve ser selecionada.");

				// Adicione métodos de validação personalizados para verificar visibilidade e valor não zero
				$.validator.addMethod("requiredIfVisibleAndNotZero", function(value, element) {
					if (!$(element).is(":visible")) {
						return true; // Se o campo não estiver visível, considere-o válido
					}
					// Converta o valor para string e verifique se não é zero
					var stringValue = String(value);
					var numericValue = parseFloat(stringValue.replace(/[^0-9,-]+/g, '').replace(',', '.'));
					return numericValue > 0;
				}, "Campo obrigatório e deve ser maior que zero.");

				
				$("#formAvalOrientacaoCadastro .btn-group .btn").on("click", function() {
					$(this).siblings().removeClass("active");
					$(this).addClass("active");
					validateButtonGroupsOrientacao();
				});

				// Adicione um método de validação personalizado para verificar visibilidade e valor não vazio
				$.validator.addMethod("requiredIfVisibleAndNotEmpty", function(value, element) {
					//console.log("Validando:", element, "Valor:", value, "Visível:", $(element).is(":visible"));
					if (!$(element).is(":visible")) {
						return true; // Se o campo não estiver visível, considere-o válido
					}
					return $.trim(value).length > 0; // Verifica se o valor não está vazio (após remover espaços em branco)
				}, "Este campo é obrigatório.");

				// Adiciona método de validação personalizado para verificar se um botão foi selecionado em cada grupo
				$.validator.addMethod('requiredButtonGroup', function(value, element, params) {
					let isValid = false;
					$(params.groups).each(function() {
						if ($(this).find('.btn.active').length > 0) {
							isValid = true;
						}
					});
					return isValid;
				}, 'Por favor, selecione uma opção para cada grupo.');
               

				$('#formAvalOrientacaoCadastro').validate({
					//ignore: [], // Não ignorar os elementos ocultos para que a validação funcione corretamente
					rules: {
						pcOrientacao: {
							required: true
						},
						pcOrgaoRespOrientacao: {
							required: true
						},
						pcAvalOrientacaoCategoriaControle: {
							required: true
						},
						pcAvalOrientacaoBenefNaoFinanceiroDesc: {
							requiredIfVisibleAndNotEmpty: true
						},
						pcValorBeneficioFinanceiro: {
							requiredIfVisibleAndNotZero: true
						},
						pcValorCustoFinanceiro: {
							requiredIfVisibleAndNotZero: true
						}
					},
					messages: {
						pcOrientacao: {
							required: "Campo obrigatório."
						},
						pcOrgaoRespOrientacao: {
							required: "Campo obrigatório."
						},
						pcAvalOrientacaoCategoriaControle: {
							required: "Selecione, pelo menos, uma opção."
						},
						pcAvalOrientacaoBenefNaoFinanceiroDesc: {
							requiredIfVisibleAndNotEmpty: "Campo obrigatório."
						},
						pcValorBeneficioFinanceiro: {
							requiredIfVisibleAndNotZero: "Campo obrigatório e deve ser maior que zero."
						},
						pcValorCustoFinanceiro: {
							requiredIfVisibleAndNotZero: "Campo obrigatório e deve ser maior que zero."
						}
					},

					errorElement: 'div',
					errorPlacement: function(error, element) {
						
						error.addClass('invalid-feedback');
						validateButtonGroupsOrientacao();
						error.addClass('invalid-feedback');
						// Verifica se a mensagem de erro já existe antes de adicioná-la
						var errorElementId = element.attr('name') + "-error";
						if ($('#' + errorElementId).length === 0) {
							if (element.attr('name') === 'pcAvalOrientacaoBenefNaoFinanceiroDesc') {
								error.insertAfter('#pcAvalOrientacaoBenefNaoFinanceiroDesc');
							} else if (element.attr('name') === 'pcValorBeneficioFinanceiro') {
								error.insertAfter('#pcValorBeneficioFinanceiro');
							} else if (element.attr('name') === 'pcValorCustoFinanceiro') {
								error.insertAfter('#pcValorCustoFinanceiro');
							} else {
								//error.insertAfter(element); // Para outros elementos
								element.closest(".form-group").append(error);
							}
						}
					},
					highlight: function(element, errorClass, validClass) {
						$(element).addClass('is-invalid').removeClass('is-valid');
					},
					unhighlight: function(element, errorClass, validClass) {
						$(element).addClass('is-valid').removeClass('is-invalid');
					},
					submitHandler: function(form) {
						if(validateButtonGroupsOrientacao()){		
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcProcessos_editar.cfc",
									data:{
										method: "cadOrientacoes",
										pc_aval_id: pc_aval_id,
										pc_aval_orientacao_id: $('#pcOrientacaoId').val(),
										pc_aval_orientacao_descricao: $('#pcOrientacao').val(),
										pc_aval_orientacao_mcu_orgaoResp:  $('#pcOrgaoRespOrientacao').val(),
										pc_aval_orientacao_categoriaControle_id: $('#pcAvalOrientacaoCategoriaControle').val().join(','),
										pc_aval_orientacao_beneficioNaoFinanceiro: $('#pcAvalOrientacaoBenefNaoFinanceiroDesc').val(),
										pc_aval_orientacao_beneficioFinanceiro: $('#pcValorBeneficioFinanceiro').val(),
										pc_aval_orientacao_custoFinanceiro: $('#pcValorCustoFinanceiro').val()
									},
									async: false
								})//fim ajax
								.done(function(result) {
									$.ajax({
										type: "post",
										url: "cfc/pc_cfcProcessos_editar.cfc",
										data:{
											method: "tabOrientacoes",
											pc_aval_id: pc_aval_id
										},
										async: false
									})//fim ajax
									.done(function(result) {
										$('#tabOrientacoesDiv').html(result)
										$('html, body').animate({ scrollTop: ($('#custom-tabs-one-4passo-tab').offset().top)-60} , 500);
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
										});

									})//fim done
									toastr.success('Operação realizada com sucesso!');
									mostraFormAvalOrientacaoCadastro();
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								})//fim fail
							}, 1000);
							$('#labelOrientacao').html('Orientação:')	
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});	
						}

						
					}
					
				});

				$('#btn_groupAvalOrientacaoBenefNaoFinanceiro .btn').click(function() {
					$('#btn_groupAvalOrientacaoBenefNaoFinanceiro .btn').removeClass('active');
					$(this).addClass('active');
					
					var selectedValue = $(this).attr('id');

					if (selectedValue === 'btn-descricao') {
					    $('#pcAvalOrientacaoBenefNaoFinanceiroDesc').addClass('animate__animated animate__fast animate__fadeInLeft') 
						$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').show();
						$('#btn-descricao').removeClass('btn-light').addClass('btn-primary');
						$('#btn-nao-aplica').removeClass('btn-dark').addClass('btn-light');
					} else if (selectedValue === 'btn-nao-aplica') {
					  	$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-nao-aplica').removeClass('btn-light').addClass('btn-dark');
						$('#btn-descricao').removeClass('btn-primary').addClass('btn-light');
						$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').val('');
						$('#pcAvalOrientacaoBenefNaoFinanceiroDesc-error').remove();
					} else {
						$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').val('');
					}
				});

				$('#btn_groupValorBeneficioFinanceiro .btn').click(function() {
					$('#btn_groupValorBeneficioFinanceiro .btn').removeClass('active');
					$(this).addClass('active');

					var selectedValue = $(this).attr('id');

					if (selectedValue === 'btn-quantificado-BeneficioFinanceiro') {
						$('#pcValorBeneficioFinanceiro').show().addClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-quantificado-BeneficioFinanceiro').removeClass('btn-light').addClass('btn-primary');
						$('#btn-nao-aplica-BeneficioFinanceiro').removeClass('btn-dark').addClass('btn-light');
					} else if (selectedValue === 'btn-nao-aplica-BeneficioFinanceiro') {
						$('#pcValorBeneficioFinanceiro').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-nao-aplica-BeneficioFinanceiro').removeClass('btn-light').addClass('btn-dark');
						$('#btn-quantificado-BeneficioFinanceiro').removeClass('btn-primary').addClass('btn-light');
						$('#pcValorBeneficioFinanceiro').val('');
						$('#pcValorBeneficioFinanceiro-error').remove();
					} else {
						$('#pcValorBeneficioFinanceiro').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#pcValorBeneficioFinanceiro').val('');
					}
				});

				$('#btn_groupValorCustoFinanceiro .btn').click(function() {
					$('#btn_groupValorCustoFinanceiro .btn').removeClass('active');
					$(this).addClass('active');

					var selectedValue = $(this).attr('id');

					if (selectedValue === 'btn-quantificado-CustoFinanceiro') {
						$('#pcValorCustoFinanceiro').show().addClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-quantificado-CustoFinanceiro').removeClass('btn-light').addClass('btn-primary');
						$('#btn-nao-aplica-CustoFinanceiro').removeClass('btn-dark').addClass('btn-light');
					} else if (selectedValue === 'btn-nao-aplica-CustoFinanceiro') {
						$('#pcValorCustoFinanceiro').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-nao-aplica-CustoFinanceiro').removeClass('btn-light').addClass('btn-dark');
						$('#btn-quantificado-CustoFinanceiro').removeClass('btn-primary').addClass('btn-light');
						$('#pcValorCustoFinanceiro').val('');
						$('#pcValorCustoFinanceiro-error').remove();
					} else {
						$('#pcValorCustoFinanceiro').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#pcValorCustoFinanceiro').val('');
					}
				});


				$('#pcOrgaoRespOrientacao, #pcAvalOrientacaoCategoriaControle, #pcValorBeneficioFinanceiro, #pcValorCustoFinanceiro').on('change', function() {
					$(this).trigger('input');
					 $(this).valid(); 
				});

				$('#btCancelarOrientacao').on('click', function (event)  {
					//cancela e  não propaga o event click original no botão
					event.preventDefault();
					event.stopPropagation();
					$('#modalOverlay').modal('show')
					setTimeout(function() {
						
						mostraFormAvalOrientacaoCadastro();
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					}, 1000);
					
				});

				// // Adiciona manipuladores de eventos de mudança para os campos select2
				// $('select').on('change.select2', function() {
				// 	var $this = $(this);
				// 	if ($this.val()) {
				// 		$this.removeClass('is-invalid').addClass('is-valid');
				// 		$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
						
				// 	}
				// });

				// // Adiciona manipuladores de eventos para validar os campos
				// $('textarea, input, select').on('change blur keyup', function() {
				// 	var $this = $(this);
				// 	if ($this.val()) {
				// 		$this.removeClass('is-invalid').addClass('is-valid');
				// 		$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
				// 	}
				// });

				$('select, textarea, input').on('change blur keyup', function() {
					var $this = $(this);
					// Verifica se o valor do select é vazio ou nulo
					if ($this.val() == "" || $this.val() == null || $this.val().length === 0) {
						$this.removeClass('is-valid').addClass('is-invalid');
						$this.closest('.form-group').find('div.is-invalid').css('display', 'block');
						$this.valid(); // This will validate the select element based on your jQuery Validate rules
					}else{
						$this.removeClass('is-invalid').addClass('is-valid');
						$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
						$this.valid();
					}
				});

				




			});

			

		</script>


	</cffunction>

	<cffunction name="formAvalMelhoriaCadastro" access="remote" hint="Formulário de cadastro das Propostas de Melhoria">
		
		<cfargument name="numOrgaoAvaliado" type="string" required="true"/>
		<cfargument name="modalidade" type="string" required="true"  />	

		<div id="accordionCadMelhoria"  style="display: flex; justify-content: left;">
			<div  id="cadMelhoria" class="card card-primary collapsed-card" >
				<div id="btnCadastrarMelhoria" class="card-header text-left" style="background-color: #0083ca;color:#fff;">
					<a class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:14px;" data-card-widget="collapse">
						<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
						</button></i><span id="cabecalhoAccordionCadMelhoria">Clique aqui para cadastrar uma Propostas de Melhoria</span>
					</a>
				</div>
				<div class="card-body" style="border: solid 3px #0083ca;" >
					<div class="card card-default">
						<div class="card-body p-0">
							<h6  class="font-weight-light text-center" style="top:-15px;font-size:14px!important;color:#00416B;position:absolute;width:100%;left:50%;transform:translateX(-50%);">
								<span id="infoTipoCadMelhoria" style=" background-color:#fff;border:1px solid rgb(229, 231, 235);padding-left:7px;padding-right:7px;border-radius: 5px;">Cadastrando Nova Proposta de Melhoria:</span>
							</h6>
							<form   id="formAvalMelhoriaCadastro" name="formAvalMelhoriaCadastro"  style="padding:10px"  onsubmit="return false" novalidate>
								<style>
									label{
										font-size: 0.8rem;
									}
									.btnValorNaoSeAplicaMelhoria{
										border-radius: 25px 0 0 25px !important;
									}

									.btnValorQuantificadoMelhoria{
										border-radius: 0 25px 25px 0 !important;
									}
								</style>
								<input id="pcMelhoriaId" hidden>
								<div class="row" style="font-size:14px">
									<div class="col-sm-12">
										<div class="form-group">
											<label id="labelMelhoria" for="pcMelhoria">Proposta de Melhoria:</label>
											<textarea class="form-control" id="pcMelhoria" rows="2"   name="pcMelhoria" class="form-control"></textarea>
										</div>										
									</div>
									<cfquery name="rs_OrgAvaliadoMelhoria" datasource="#application.dsn_processos#">
										SELECT pc_orgaos.*
										FROM pc_orgaos
										WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#arguments.numOrgaoAvaliado#' or pc_org_mcu = '#arguments.numOrgaoAvaliado#' 
												or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND pc_org_mcu_subord_tec = '#arguments.numOrgaoAvaliado#'))
										ORDER BY pc_org_sigla
									</cfquery>
									<div class="col-sm-4">
										<div class="form-group">
											<label  for="pcOrgaoRespMelhoria">Órgão Responsável:</label>
											<select id="pcOrgaoRespMelhoria"  name="pcOrgaoRespMelhoria" class="form-control"  style="height:40px">
												<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
												<cfoutput query="rs_OrgAvaliadoMelhoria">
													<option value="#pc_org_mcu#">#pc_org_sigla#</option>
												</cfoutput>
											</select>
										</div>
									</div>
																			
									<cfif arguments.modalidade eq "A">
										<div class="col-sm-2" >
											<div class="form-group">
												<label  for="pcStatusMelhoria">Status:</label>
												<select id="pcStatusMelhoria"  name="pcStatusMelhoria" class="form-control"  style="height:40px">
													<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
													<option value="P">PENDENTE</option>
													<option value="A">ACEITA</option>
													<option value="R">RECUSA</option>
													<option value="T">TROCA</option>
													<option value="B">BLOQUEADO</option>
													<option value="N">NÃO INFORMADO</option>
												</select>
											</div>
										</div>
									<cfelse>
										<div id="div_pcStatusMelhoria" class="col-sm-2" hidden>
											<div class="form-group">
												<label  for="pcStatusMelhoria">Status:</label>
												<select id="pcStatusMelhoria"  name="pcStatusMelhoria" class="form-control"  style="height:40px">
													<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
													<option value="P">PENDENTE</option>
													<option value="N">NÃO INFORMADO</option>
												</select>
											</div>
										</div>
									</cfif>
										
									

									<div id="pcDataPrevDiv" class="col-md-3" hidden>
										<div class="form-group">
											<label for="pcDataPrev">Data prevista para Implementação:</label>
											<div class="input-group date" id="reservationdate" data-target-input="nearest">
												<input  id="pcDataPrev"  name="pcDataPrev" required  type="date" class="form-control" placeholder="dd/mm/aaaa" >
											</div>
										</div>
									</div>

									<div id="pcOrgaoRespSugeridoMelhoriaDiv" class="col-sm-4" hidden>
										<div class="form-group">
											<label  for="pcOrgaoRespSugeridoMelhoria">Órgão Responsável Sugerido pelo órgão:</label>
											<select id="pcOrgaoRespSugeridoMelhoria"  name="pcOrgaoRespSugeridoMelhoria" class="form-control"  style="height:40px">
												<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
												<cfoutput query="rs_OrgAvaliadoMelhoria">
													<option value="#pc_org_mcu#">#pc_org_sigla#</option>
												</cfoutput>
											</select>
										</div>
									</div>

									<div id="pcRecusaJustMelhoriaDiv" class="col-sm-12" hidden>
										<div class="form-group">
											<label id="labelPcRecusaJustMelhoria" for="pcRecusaJustMelhoria">Informe as justificativa do órgão para Recusa:</label>
											<textarea class="form-control" id="pcRecusaJustMelhoria" rows="4"  name="pcRecusaJustMelhoria" class="form-control"></textarea>
										</div>										
									</div>

									<div id="pcNovaAcaoMelhoriaDiv" class="col-sm-12" hidden>
										<div class="form-group">
											<label id="labelPcRecusaJustMelhoria" for="pcNovaAcaoMelhoria">Informe as ações que o órgão julgou necessárias:</label>
											<textarea class="form-control" id="pcNovaAcaoMelhoria" rows="4"  name="pcNovaAcaoMelhoria" class="form-control"></textarea>
										</div>										
									</div>
									
									<cfquery name="rsAvalMelhoriaCategoriaControle" datasource="#application.dsn_processos#">
										SELECT pc_avaliacao_categoriaControle.*
										FROM pc_avaliacao_categoriaControle
										WHERE  pc_aval_categoriaControle_status = 'A'
									</cfquery>
									<div class="col-sm-6">
										<div class="form-group">
											<label for="pcAvalMelhoriaCategoriaControle" >Categoria do Controle Proposto:</label>
											<select id="pcAvalMelhoriaCategoriaControle" name="pcAvalMelhoriaCategoriaControle" class="form-control" multiple="multiple">
												<cfoutput query="rsAvalMelhoriaCategoriaControle">
													<option value="#pc_aval_categoriaControle_id#">#pc_aval_categoriaControle_descricao#</option>
												</cfoutput>
											</select>
										</div>
									</div>

									<div class="col-sm-12">
										<fieldset style="padding:0px!important">
											<legend style="margin-left:20px">Benefício Não Financeiro da Proposta de Melhoria:</legend>
											<div class="form-group d-flex align-items-center" style="margin-left:20px">
												
												<div id="btn_groupAvalMelhoriaBenefNaoFinanceiro" name="btn_groupAvalMelhoriaBenefNaoFinanceiro" class="btn-group mr-4" role="group" aria-label="Basic example">
													<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplicaMelhoria" id="btn-nao-aplicaMelhoria" name="btn-nao-aplicaMelhoria"  style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
													<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificadoMelhoria" id="btn-descricaoMelhoria" name="btn-descricaoMelhoria" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Descrever</button>
												</div>
												
												<div style="width:100%;position:relative;margin-top:13px">
													<div class="form-group">
														<textarea class="form-control" id="pcAvalMelhoriaBenefNaoFinanceiroDesc" name="pcAvalMelhoriaBenefNaoFinanceiroDesc" style="display: none;margin-right:10px;width:98%" rows="3" name="pcAvalMelhoriaBenefNaoFinanceiro" class="form-control" placeholder="Informe os Benefícios não financeiros..."></textarea>
													</div>
												</div>
											</div>
										</fieldset>
									</div>
										

									<div class="col-sm-12">	
										<fieldset style="margin-top:20px;padding:0px!important">
											<legend style="margin-left:20px">Potencial Benefício Financeiro da Implementação da Proposta de Melhoria:</legend>
											<div class="form-group d-flex align-items-center"  style="margin-left:20px">
												<div id="btn_groupValorBeneficioFinanceiroMelhoria" name="btn_groupValorBeneficioFinanceiro" class="btn-group mr-4" role="group" aria-label="Basic example">
													<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplicaMelhoria" id="btn-nao-aplica-BeneficioFinanceiroMelhoria" name="btn-nao-aplica-BeneficioFinanceiroMelhoria" style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
													<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificadoMelhoria" id="btn-quantificado-BeneficioFinanceiroMelhoria" name="btn-quantificado-BeneficioFinanceiroMelhoria" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Quantificado</button>
												</div>
												<div style="display:flex">
													<input id="pcValorBeneficioFinanceiroMelhoria" name="pcValorBeneficioFinanceiroMelhoria" style="display: none;margin-right:10px;height: 29px;" type="text" class="form-control money" inputmode="text" placeholder="R$ 0,00">
												</div>
											</div>
										</fieldset>
									</div>

									<div class="col-sm-12">	
										<fieldset style="margin-top:20px;padding:0px!important">
											<legend style="margin-left:20px">Estimativa do Custo Financeiro da Proposta de Melhoria:</legend>
											<div class="form-group d-flex align-items-center"  style="margin-left:20px">
												<div id="btn_groupValorCustoFinanceiroMelhoria" name="btn_groupValorCustoFinanceiroMelhoria" class="btn-group mr-4" role="group" aria-label="Basic example">
													<button type="button" class="btn btn-light btn-sm p-1 btnValorNaoSeAplicaMelhoria" id="btn-nao-aplica-CustoFinanceiroMelhoria" name="btn-nao-aplica-CustoFinanceiroMelhoria" style="font-size: 0.8rem; white-space: nowrap;">Não se aplica</button>
													<button type="button" class="btn btn-light btn-sm p-1 btnValorQuantificadoMelhoria" id="btn-quantificado-CustoFinanceiroMelhoria" name="btn-quantificado-CustoFinanceiroMelhoria" style="font-size: 0.8rem; margin-left:5px; white-space: nowrap;">Quantificado</button>
												</div>
												<div style="display:flex">
													<input id="pcValorCustoFinanceiroMelhoria" name="pcValorCustoFinanceiroMelhoria" style="display: none;margin-right:10px;height: 29px;" type="text" class="form-control money" inputmode="text" placeholder="R$ 0,00">
												</div>
											</div>
										</fieldset>
										
									</div>
									
									<div style="justify-content:center; display: flex; width: 100%;">
										<div>
											<button id="btSalvarMelhoria"  class="btn btn-block  " style="background-color:#0083ca;color:#fff">Salvar</button>
										</div>
										<div style="margin-left:100px">
											<button id="btCancelarMelhoria"  class="btn btn-block btn-danger " >Cancelar</button>
										</div>
										
									</div>	
									</div>	
								</div>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>
  	
		<script language="JavaScript">
			$(".money").inputmask( 'currency',{"autoUnmask": true,
				radixPoint:",",
				groupSeparator: ".",
				allowMinus: false,
				prefix: 'R$ ',            
				digits: 2,
				digitsOptional: false,
				rightAlign: true,
				unmaskAsNumber: true
			});

			$(function () {
				$('[data-mask]').inputmask()
			})

			$(document).ready(function() {

				$('#btnCadastrarMelhoria').on('expanded.lte.cardwidget', function() {
					//move o cursor para o id btnCadastrarMelhoria
					$('html, body').animate({
						scrollTop: $("#btnCadastrarMelhoria").offset().top-60
					}, 1000);
				});
				
				//Initialize Select2 Elements
				// as exceções são os selects que não devem ser inicializados com o select2 e que estão em todas as páginas que utilizam este componente.
				$('select').not('[name="tabProcAcompCards_length"], [name="tabAvaliacoes_length"], [name="tabProcCards_length"], [name="tabAvaliacoes2024_length"], [name="tabItens_length"]').select2({
					theme: 'bootstrap4',
					placeholder: 'Selecione...',
					allowClear: true
					
				});
				
				
				// Função de validação customizada
				function validateButtonGroupsMelhoria() {
					var isValid = true;

					$("#formAvalMelhoriaCadastro .btn-group").each(function() {
						var $group = $(this);
						var hasActive = $group.find(".active").length > 0;
						var $error = $group.next("span.error");

						if (!hasActive) {
							$group.addClass("is-invalid").removeClass("is-valid");
							if ($error.length === 0) {
								$("<span class='error invalid-feedback' >Selecione uma opção.</span>").insertAfter($group);
							}
							isValid = false;
						} else {
							$group.removeClass("is-invalid").addClass("is-valid");
							$error.remove();
						}
					});

					return isValid;
				}

				// Adicione métodos de validação personalizados para verificar visibilidade e valor não zero
				$.validator.addMethod("requiredIfVisibleAndNotZero", function(value, element) {
					if (!$(element).is(":visible")) {
						return true; // Se o campo não estiver visível, considere-o válido
					}
					// Converta o valor para string e verifique se não é zero
					var stringValue = String(value);
					var numericValue = parseFloat(stringValue.replace(/[^0-9,-]+/g, '').replace(',', '.'));
					return numericValue > 0;
				}, "Campo obrigatório e deve ser maior que zero.");

				// Adicione e remova a classe 'active' quando os botões forem clicados
				$("#formAvalMelhoriaCadastro .btn-group .btn").on("click", function() {
					$(this).siblings().removeClass("active");
					$(this).addClass("active");
					validateButtonGroupsMelhoria();
				});

				// Adicione um método de validação personalizado para verificar visibilidade e valor não vazio
				$.validator.addMethod("requiredIfVisibleAndNotEmpty", function(value, element) {
					//console.log("Validando:", element, "Valor:", value, "Visível:", $(element).is(":visible"));
					if (!$(element).is(":visible")) {
						return true; // Se o campo não estiver visível, considere-o válido
					}
					return $.trim(value).length > 0; // Verifica se o valor não está vazio (após remover espaços em branco)
				}, "Este campo é obrigatório.");

				// Adiciona método de validação personalizado para verificar se um botão foi selecionado em cada grupo
				$.validator.addMethod('requiredButtonGroup', function(value, element, params) {
					let isValid = false;
					$(params.groups).each(function() {
						if ($(this).find('.btn.active').length > 0) {
							isValid = true;
						}
					});
					return isValid;
				}, 'Por favor, selecione uma opção para cada grupo.');
               

				$('#formAvalMelhoriaCadastro').validate({
					
					//ignore: [], // Não ignorar os elementos ocultos para que a validação funcione corretamente
					rules: {
						pcMelhoria: {
							required: true
						 },
						pcOrgaoRespMelhoria: {
							required: true
						},
						pcStatusMelhoria: {
							requiredIfVisibleAndNotEmpty: true
						},
						pcAvalMelhoriaCategoriaControle: {
							required: true
						},
						pcAvalMelhoriaBenefNaoFinanceiroDesc: {
							requiredIfVisibleAndNotEmpty: true
						},
						pcValorBeneficioFinanceiroMelhoria: {
							requiredIfVisibleAndNotZero: true
						},
						pcValorCustoFinanceiroMelhoria: {
							requiredIfVisibleAndNotZero: true
						}
					},
					messages: {
						pcMelhoria: {
							required: "Campo obrigatório."
						},
						pcOrgaoRespMelhoria: {
							required: "Campo obrigatório."
						},
						pcStatusMelhoria: {
							requiredIfVisibleAndNotEmpty: "Campo obrigatório."
						},
						pcAvalMelhoriaCategoriaControle: {
							required: "Selecione, pelo menos, uma opção."
						},
						pcAvalMelhoriaBenefNaoFinanceiroDesc: {
							requiredIfVisibleAndNotEmpty: "Campo obrigatório."
						},
						pcValorBeneficioFinanceiroMelhoria: {
							requiredIfVisibleAndNotZero: "Campo obrigatório e deve ser maior que zero."
						},
						pcValorCustoFinanceiroMelhoria: {
							requiredIfVisibleAndNotZero: "Campo obrigatório e deve ser maior que zero."
						}
					},

					errorElement: 'div',
					errorPlacement: function(error, element) {
						
						error.addClass('invalid-feedback');
                         validateButtonGroupsMelhoria();
						 error.addClass('invalid-feedback');
						 
							if (element.attr('name') === 'pcAvalMelhoriaBenefNaoFinanceiroDesc') {
								error.insertAfter('#pcAvalMelhoriaBenefNaoFinanceiroDesc');
							} else if (element.attr('name') === 'pcValorBeneficioFinanceiroMelhoria') {
								error.insertAfter('#pcValorBeneficioFinanceiroMelhoria');
							} else if (element.attr('name') === 'pcValorCustoFinanceiroMelhoria') {
								error.insertAfter('#pcValorCustoFinanceiroMelhoria');
							} else {
								// Verifica se a mensagem de erro já existe antes de adicioná-la
								var errorElementId = element.attr('name') + "-error";
								if ($('#' + errorElementId).length === 0) {
									element.closest(".form-group").append(error);
								}
							}
						
						
					},
					highlight: function(element, errorClass, validClass) {
						$(element).addClass('is-invalid').removeClass('is-valid');
					},
					unhighlight: function(element, errorClass, validClass) {
						$(element).addClass('is-valid').removeClass('is-invalid');
					},
					submitHandler: function(form) {
						if(validateButtonGroupsMelhoria()){	
							
							//verifica se os campos necessários foram preenchidos
							<cfoutput>
								let modalidade = '#arguments.modalidade#';
							</cfoutput>
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								// Obtem o texto do span
								let cabecalhoTexto = $("#cabecalhoAccordionCadMelhoria").text();

								// Verifica o valor do texto
								let status = "";
								if (cabecalhoTexto === "Clique aqui para cadastrar uma Propostas de Melhoria" && modalidade === "E") {
									status = "P";
								}else{
									status = $('#pcStatusMelhoria').val();
								}
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAvaliacoes.cfc",
									data:{
										method: "cadMelhorias",
										modalidade: modalidade,
										pc_aval_id: pc_aval_id,
										pc_aval_melhoria_id: $('#pcMelhoriaId').val(),
										pc_aval_melhoria_descricao: $('#pcMelhoria').val(),
										pc_aval_melhoria_num_orgao:  $('#pcOrgaoRespMelhoria').val(),
										pc_aval_melhoria_status: status,
										pc_aval_melhoria_dataPrev: $('#pcDataPrev').val(),
										pc_aval_melhoria_sugestao: $('#pcNovaAcaoMelhoria').val(),
										pc_aval_melhoria_sug_orgao_mcu:$('#pcOrgaoRespSugeridoMelhoria').val(),
										pc_aval_melhoria_naoAceita_justif:$('#pcRecusaJustMelhoria').val(),
										pc_aval_melhoria_categoriaControle_id: $('#pcAvalMelhoriaCategoriaControle').val().join(','),
										pc_aval_melhoria_beneficioNaoFinanceiro: $('#pcAvalMelhoriaBenefNaoFinanceiroDesc').val(),
										pc_aval_melhoria_beneficioFinanceiro: $('#pcValorBeneficioFinanceiroMelhoria').val(),
										pc_aval_melhoria_custoFinanceiro: $('#pcValorCustoFinanceiroMelhoria').val()
									},
									async: false
								})//fim ajax
								.done(function(result) {
									
									mostraTabMelhorias();
									toastr.success('Operação realizada com sucesso!');
									mostraFormAvalMelhoriaCadastro();	
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								})//fim fail
								$('#labelMelhoria').html('Proposta de Melhoria:')	
								
							}, 1000);		
						}
					}
				});
			

				$('#btn_groupAvalMelhoriaBenefNaoFinanceiro .btn').click(function() {
					$('#btn_groupAvalMelhoriaBenefNaoFinanceiro .btn').removeClass('active');
					$(this).addClass('active');
					
					var selectedValue = $(this).attr('id');

					if (selectedValue === 'btn-descricaoMelhoria') {
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').addClass('animate__animated animate__fast animate__fadeInLeft') 
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').show();
						$('#btn-descricaoMelhoria').removeClass('btn-light').addClass('btn-primary');
						$('#btn-nao-aplicaMelhoria').removeClass('btn-dark').addClass('btn-light');
					} else if (selectedValue === 'btn-nao-aplicaMelhoria') {
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-nao-aplicaMelhoria').removeClass('btn-light').addClass('btn-dark');
						$('#btn-descricaoMelhoria').removeClass('btn-primary').addClass('btn-light');
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').val('');
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc-error').remove();
					} else {
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#pcAvalMelhoriaBenefNaoFinanceiroDesc').val('');
					}
				});

				$('#btn_groupValorBeneficioFinanceiroMelhoria .btn').click(function() {
					$('#btn_groupValorBeneficioFinanceiroMelhoria .btn').removeClass('active');
					$(this).addClass('active');

					var selectedValue = $(this).attr('id');

					if (selectedValue === 'btn-quantificado-BeneficioFinanceiroMelhoria') {
						$('#pcValorBeneficioFinanceiroMelhoria').show().addClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-quantificado-BeneficioFinanceiroMelhoria').removeClass('btn-light').addClass('btn-primary');
						$('#btn-nao-aplica-BeneficioFinanceiroMelhoria').removeClass('btn-dark').addClass('btn-light');
					} else if (selectedValue === 'btn-nao-aplica-BeneficioFinanceiroMelhoria') {
						$('#pcValorBeneficioFinanceiroMelhoria').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-nao-aplica-BeneficioFinanceiroMelhoria').removeClass('btn-light').addClass('btn-dark');
						$('#btn-quantificado-BeneficioFinanceiroMelhoria').removeClass('btn-primary').addClass('btn-light');
						$('#pcValorBeneficioFinanceiroMelhoria').val('');
						$('#pcValorBeneficioFinanceiroMelhoria-error').remove();
					} else {
						$('#pcValorBeneficioFinanceiroMelhoria').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#pcValorBeneficioFinanceiroMelhoria').val('');
					}
				});

				$('#btn_groupValorCustoFinanceiroMelhoria .btn').click(function() {
					$('#btn_groupValorCustoFinanceiroMelhoria .btn').removeClass('active');
					$(this).addClass('active');

					var selectedValue = $(this).attr('id');

					if (selectedValue === 'btn-quantificado-CustoFinanceiroMelhoria') {
						$('#pcValorCustoFinanceiroMelhoria').show().addClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-quantificado-CustoFinanceiroMelhoria').removeClass('btn-light').addClass('btn-primary');
						$('#btn-nao-aplica-CustoFinanceiroMelhoria').removeClass('btn-dark').addClass('btn-light');
					} else if (selectedValue === 'btn-nao-aplica-CustoFinanceiroMelhoria') {
						$('#pcValorCustoFinanceiroMelhoria').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#btn-nao-aplica-CustoFinanceiroMelhoria').removeClass('btn-light').addClass('btn-dark');
						$('#btn-quantificado-CustoFinanceiroMelhoria').removeClass('btn-primary').addClass('btn-light');
						$('#pcValorCustoFinanceiroMelhoria').val('');
						$('#pcValorCustoFinanceiroMelhoria-error').remove();
					} else {
						$('#pcValorCustoFinanceiroMelhoria').hide().removeClass('animate__animated animate__fast animate__fadeInLeft');
						$('#pcValorCustoFinanceiroMelhoria').val('');
					}
				});

				$('#pcOrgaoRespMelhoria, #pcAvalMelhoriaCategoriaControle, #pcValorBeneficioFinanceiroMelhoria, #pcValorCustoFinanceiroMelhoria').on('change', function() {
					$(this).trigger('input');
						$(this).valid(); 
				});

				$('#btCancelarMelhoria').on('click', function (event)  {
					//cancela e  não propaga o event click original no botão
					event.preventDefault();
					event.stopPropagation();
					$('#modalOverlay').modal('show')
					setTimeout(function() {
						mostraFormAvalMelhoriaCadastro();
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					}, 1000);
					
				});

				// // Adiciona manipuladores de eventos de mudança para os campos select2
				// $('select').on('change.select2', function() {
				// 	var $this = $(this);
				// 	if ($this.val()) {
				// 		$this.removeClass('is-invalid').addClass('is-valid');
				// 		$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
						
				// 	}
				// });

				// // Adiciona manipuladores de eventos para validar os campos
				// $('textarea, input, select').on('change blur keyup', function() {
				// 	var $this = $(this);
				// 	if ($this.val()) {
				// 		$this.removeClass('is-invalid').addClass('is-valid');
				// 		$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
				// 	}
				// });

				

				$('select, textarea, input').on('change blur keyup', function() {
					var $this = $(this);
					// Verifica se o valor do select é vazio ou nulo
					if ($this.val() == "" || $this.val() == null || $this.val().length === 0) {
						$this.removeClass('is-valid').addClass('is-invalid');
						$this.closest('.form-group').find('div.is-invalid').css('display', 'block');
						$this.valid(); // This will validate the select element based on your jQuery Validate rules
					}else{
						$this.removeClass('is-invalid').addClass('is-valid');
						$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
						$this.valid();
					}
				});



			});


			

			

		</script>
						


	</cffunction>







	<cffunction name="cadOrientacoes"   access="remote"  returntype="any" hint="cadastra/edita orientacao">
		
		<cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_orientacao_descricao" type="string" required="true"/>
		<cfargument name="pc_aval_orientacao_mcu_orgaoResp" type="string" required="true"/>
		<cfargument name="pc_aval_orientacao_id" type="string" required="false" default=""/>
		<cfargument name="pc_aval_orientacao_categoriaControle_id" type="string" required="true"/>
		<cfargument name="pc_aval_orientacao_beneficioNaoFinanceiro" type="string" required="true"/>
		<cfargument name="pc_aval_orientacao_beneficioFinanceiro" type="string" required="true"/>
		<cfargument name="pc_aval_orientacao_custoFinanceiro" type="string" required="true"/>
		<!--Adiciona 30 dias úteis à data atual para gerar a data prevista para resposta que constara np texto do manifestação-->
		<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio">
		<cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias = 30 />
		<cfset dataPTBR = obterDataPrevista.Data_Prevista_Formatada>
		<cfset dataCFQUERY = "#DateFormat(obterDataPrevista.Data_Prevista,'YYYY-MM-DD')#">
		<!--Se pc_aval_orientacao_id igual a '' significa que é um cadastro de orientação-->
		<!--Se for um cadastro de orientação-->
		<cfif #arguments.pc_aval_orientacao_id# eq ''>
			<cfquery datasource="#application.dsn_processos#" name="rsProcesso">
				SELECT pc_num_status,pc_modalidade FROM   pc_processos
				INNER JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
				WHERE  pc_aval_id = #arguments.pc_aval_id#
			</cfquery>
				

			<!--Se o processo for da modalidade ACOMPANHAMENTO-->
			<cfif rsProcesso.pc_modalidade eq 'A' >
				<!--Se o processo estiver bloqueado-->
				<cfif rsProcesso.pc_num_status eq 6>
					<cfquery datasource="#application.dsn_processos#" name="qCadastraOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login, pc_aval_orientacao_beneficioNaoFinanceiro, pc_aval_orientacao_beneficioFinanceiro, pc_aval_orientacao_custoFinanceiro)
						VALUES (	14
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_descricao#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioNaoFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_custoFinanceiro#">
								)
						SELECT SCOPE_IDENTITY() AS NewID;
					</cfquery>
					<cfset IDdaOriencaoCadastrada = qCadastraOrientacao.NewID>
					<cfset posicaoInicial = "Processo BLOQUEADO.<br>Este relatório aguarda a finalização de análises complementares do controle interno e/ou outros órgãos da empresa para liberação ao ÓRGÃO AVALIADO. Favor aguardar.">
					<cfset orgaoResp = ''>
					<cfset posic_status = 14>
					<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado)
						VALUES (#IDdaOriencaoCadastrada#, '#posicaoInicial#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#orgaoResp#','#dataCFQUERY#',#posic_status#, 1)
					</cfquery>
				<cfelse>
					<!--Se o processo não estiver bloqueado, a orientação ficará pendente de posicionamento inicial do controle interno-->
					<cfquery datasource="#application.dsn_processos#" >
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login, pc_aval_orientacao_beneficioNaoFinanceiro, pc_aval_orientacao_beneficioFinanceiro, pc_aval_orientacao_custoFinanceiro)
						VALUES (	1
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_descricao#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioNaoFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_custoFinanceiro#">
								)
					</cfquery>
				</cfif>
			<cfelse>
				<!--Se o processo for da modalidade ENTREGA DO RELATÓRIO-->
				<!--Se o processo estiver bloqueado-->
				<cfif rsProcesso.pc_num_status eq 6>
					<cfquery datasource="#application.dsn_processos#"  name="qCadastraOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login, pc_aval_orientacao_beneficioNaoFinanceiro, pc_aval_orientacao_beneficioFinanceiro, pc_aval_orientacao_custoFinanceiro)
						VALUES (	14
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_descricao#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioNaoFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_custoFinanceiro#">
								)
						SELECT SCOPE_IDENTITY() AS NewID;
					</cfquery>
					<cfset IDdaOriencaoCadastrada = qCadastraOrientacao.NewID>
					<cfset posicaoInicial = "Processo BLOQUEADO.<br>Este relatório aguarda a finalização de análises complementares do controle interno e/ou outros órgãos da empresa para liberação ao ÓRGÃO AVALIADO. Favor aguardar.">
					<cfset orgaoResp = ''>
					<cfset posic_status = 14>
					<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado)
						VALUES (#IDdaOriencaoCadastrada#, '#posicaoInicial#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#orgaoResp#','#dataCFQUERY#',#posic_status#, 1)
					</cfquery>
				<cfelse>
					<cfquery datasource="#application.dsn_processos#"  name="qCadastraOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login, pc_aval_orientacao_beneficioNaoFinanceiro, pc_aval_orientacao_beneficioFinanceiro, pc_aval_orientacao_custoFinanceiro,pc_aval_orientacao_dataPrevistaResp)
						VALUES (	4
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_descricao#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">
									,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
									,'#application.rsUsuarioParametros.pc_usu_login#'
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioNaoFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioFinanceiro#">
									,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_custoFinanceiro#">
									,'#dataCFQUERY#'
								)
						SELECT SCOPE_IDENTITY() AS NewID;
					</cfquery>
					<cfset IDdaOriencaoCadastrada = qCadastraOrientacao.NewID>
					<cfset posicaoInicial = "Para registro de sua manifestação orienta-se a atentar para as “Orientações/Medidas de Regularização” emitidas pela equipe de Controle Interno, bem como anexar no sistema SNCI as evidências de implementação das ações adotadas. Também solicita-se sua manifestação para as 'Propostas de Melhoria' conforme opções disponíveis no sistema.">
					<cfset orgaoResp = '#arguments.pc_aval_orientacao_mcu_orgaoResp#'>
					<cfset posic_status = 4>
					<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado)
						VALUES (#IDdaOriencaoCadastrada#, '#posicaoInicial#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#orgaoResp#','#dataCFQUERY#',#posic_status#, 1)
					</cfquery>
				</cfif>
			</cfif>
			<!-- cadastra orientacao x categorias de controles-->
			<cfloop list="#arguments.pc_aval_orientacao_categoriaControle_id#" index="i"> 
				<cfquery datasource="#application.dsn_processos#">
					INSERT INTO pc_avaliacao_orientacao_categoriasControles (pc_aval_orientacao_id, pc_aval_categoriaControle_id)
					VALUES ('#qCadastraOrientacao.NewID#', '#i#')
				</cfquery>
			</cfloop>
		<!--Se for edição de uma orientação-->		
		<cfelse>
			<cfquery datasource="#application.dsn_processos#" >
				UPDATE pc_avaliacao_orientacoes
				SET    pc_aval_orientacao_descricao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_descricao#">,
					pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">,
					pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#',
					pc_aval_orientacao_beneficioNaoFinanceiro = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioNaoFinanceiro#">,
					pc_aval_orientacao_beneficioFinanceiro = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioFinanceiro#">,
					pc_aval_orientacao_custoFinanceiro = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_custoFinanceiro#">
				WHERE  pc_aval_orientacao_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
			</cfquery>	
			<!-- exclui orientacao x categorias de controles-->
			<cfquery datasource="#application.dsn_processos#">
				DELETE FROM pc_avaliacao_orientacao_categoriasControles
				WHERE pc_aval_orientacao_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
			</cfquery>
			<!-- cadastra orientacao x categorias de controles-->
			<cfloop list="#arguments.pc_aval_orientacao_categoriaControle_id#" index="i"> 
				<cfquery datasource="#application.dsn_processos#">
					INSERT INTO pc_avaliacao_orientacao_categoriasControles (pc_aval_orientacao_id, pc_aval_categoriaControle_id)
					VALUES ('#arguments.pc_aval_orientacao_id#', '#i#')
				</cfquery>
			</cfloop>	
		</cfif>

		
  	</cffunction>

	



</cfcomponent>