<cfcomponent  >
<cfprocessingdirective pageencoding = "utf-8">	

	

	<cffunction name="cardsAvaliacao"   access="remote" hint="enviar os cards dos processos cadastrados e iniciados pata a páginas pc_Avaliacao">


		<!-- Cards com os processos cadastrados e iniciados-->
		
		<cfquery name="rsProcCadAvaliacao" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,CONCAT(
						'Macroprocesso:<strong> ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,'</strong>',
						'<br>N1:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,'</strong>',
						'<br>N2:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,'</strong>',
						'<br>N3:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN3,'</strong>', '.'
						) as tipoProcesso

			FROM        pc_processos INNER JOIN
						pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
						pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
						pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
						pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
						pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11> 
				WHERE  pc_status.pc_status_id IN ('2','3') 
			<cfelseif #application.rsUsuarioParametros.pc_usu_perfil# eq 8>
			    WHERE  pc_status.pc_status_id IN ('2','3')  and pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
			<cfelseif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#)>
				WHERE  pc_status.pc_status_id IN ('2','3') and pc_num_orgao_origem IN('00436698','00436697','00438080') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#))
			<cfelse>
				WHERE  pc_status.pc_status_id = 0
			</cfif>
			ORDER BY 	pc_status.pc_status_id asc 
		</cfquery>	

		<style>
			#tabProcAcompCards_wrapper #tabProcAcompCards_paginate ul.pagination {
				justify-content: center!important;
			}	
		</style>
		
		<!-- Main content -->
		<section class="content">
			<div class="container-fluid">
				<!-- /.card-header -->
				<div class="card-body" >
					<form id="formCardsAvaliacao" name="formCardsAvaliacao" format="html"  style="height: auto;">
						<!--acordion-->
						<div id="accordionCadItemPainel" style="margin-bottom:80px">
							<div class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i>Selecione um Processo
										</a>
									</h4>
								</div>
								<div id="collapseTwo" class="" data-parent="#accordion">							
									<div class="card-body" style="border: solid 3px #ffD400;width:100%">
										
										<div class="row" style="justify-content: space-around;">
											<cfif #rsProcCadAvaliacao.recordcount# eq 0 >
												<h4>Nenhum processo na fase de cadastro foi localizado</h4>
											</cfif>
											<cfif #rsProcCadAvaliacao.recordcount# neq 0 >
												<div class="col-sm-12">
													<table id="tabProcAcompCards" class="table teste" style="background: none;border:none;width:100%">
														<thead >
															<tr style="background: none;border:none">
																<th style="background: none;border:none"></th>
															</tr>
														</thead>
														
														<tbody class="grid-container" >
															<cfloop query="rsProcCadAvaliacao" >
																
																<tr style="width:270px;border:none;">
																	<td style="background: none;border:none;white-space:normal!important;" >	
																		<a  href="#" style="cursor:pointer"  onclick="javascript:mostraCadastroRelato(<cfoutput>'#pc_processo_id#'</cfoutput>);">
																			<section class="content" >
																					<div id="processosAcompanhamento" class="container-fluid" >

																							<div class="row">
																								<div id="cartao" style="width:270px;" >
																								
																									<!-- small card -->
																									<div class="small-box " style="<cfoutput>#pc_status_card_style_header#</cfoutput> font-weight: normal;">
																										<cfif #pc_iniciarBloqueado# eq "S">
																									  	  <i id="btBloquear" class="fas fa-lock grow-icon" style="position:absolute;color: red;left: 2px;top:2px;z-index:1;cursor: default" data-toggle="popover" data-trigger="hover" data-placement="top" title="Processo Bloqueado" data-content="O encaminhamento ao órgão avaliado só ocorrerá após o seu desbloqueio."></i>
																										</cfif>	
																										<cfif #pc_modalidade# eq "A">
																											<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:10px;"><strong>A</strong></span>
																										<cfelseif #pc_modalidade# eq "E">
																									     	<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:5px;"><strong>E</strong></span>
																										</cfif>
																										<div class="ribbon-wrapper ribbon-lg" >
																											<div class="ribbon " style="font-size:12px;left:8px;<cfoutput>#pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#pc_status_card_nome_ribbon#</cfoutput></div>
																										</div>
																										

																										<div class="card-header" style="height:120px;width:250px;    font-weight: normal!important;">
																											<p style="font-size:1em;margin-bottom:0rem!important;"><cfoutput>Processo n°: #pc_processo_id#</cfoutput></p>
																											<p style="font-size:1em;margin-bottom:0rem!important;"><cfoutput>#siglaOrgAvaliado#</cfoutput></p>
																											<cfif pc_num_avaliacao_tipo neq 445 and pc_num_avaliacao_tipo neq 2>
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

																										
																											
																									</div>
																								</div>
																							</div>
																						
																					</div>
																			</section>
																		</a>
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
				$("#tabProcAcompCards").DataTable({
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

			function mostraCadastroRelato(numProcesso) {
				
				$('#modalOverlay').modal('show')
				    $('#cadAvaliacaoForm').html('');
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcAvaliacoes.cfc",
							data:{
								method:"cadProcAvaliacaoForm",
								pc_aval_processoForm: numProcesso
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
					}, 1000);
				
						
			}

			$(function () {
				$('[data-toggle="popover"]').popover()
			})	
			$('.popover-dismiss').popover({
				trigger: 'hover'
			})



		</script>

	</cffunction>







		
	<cffunction name="cadProcAvaliacaoForm"   access="remote"  returntype="any" hint="Insere o formulario de cadastro do título da avaliação na páginas pc_CadastroAvaliacaoPainel">


        <cfargument name="pc_aval_processoForm" type="string" required="true"/>

       

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
			WHERE  pc_processo_id = '#arguments.pc_aval_processoForm#'														
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

			<form id="formCadItem"  class="needs-validation was-validated" name="formCadItem" format="html"  style="height: auto;padding-left:25px;padding-right:25px;">
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
																	<span style="margin-left:5px">Clique aqui para anexar o Relatório do Processo e Anexos I, II e III em PDF</span>
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

			<div id="accordion"  style="display: flex; justify-content: left;">
				<div  id="cadastro" class="card card-primary collapsed-card"   style="margin-left: 25px;">
					<div class="card-header text-left" style="background-color: #0083ca;color:#fff;">
						<a  id="btnCadastroItem" class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:16px;" data-card-widget="collapse">
							<button  type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
							</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um item (1° Passo)</span>
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
													<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroRelato(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
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
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroRelato(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
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
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroRelato(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
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
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroRelato(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
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
														<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroRelato(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
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
												<button id="btCancelar"  class="btn  btn-danger " onclick="javascript:mostraCadastroRelato(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);">Cancelar</button>
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
				
				

			
			
			
			<div id="TabAvaliacao" style="margin-bottom:50px"></div>

			<div id="CadastroAvaliacaoRelato" style="padding-left:25px;padding-right:25px"></div>

			<script language="JavaScript">
				

				
				$(document).ready(function(){

					
					$('#cadastro').on('expanded.lte.cardwidget', function() {
						//limpa o conteúdo de CadastroAvaliacaoRelato
						$('#CadastroAvaliacaoRelato').html('')
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
					$('select').not('[name="tabProcAcompCards_length"]').select2({
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

					
					
					
					// Oculta todos os elementos com a classe step-trigger, exceto aquele com o ID aval_testeControle-trigger
					//$('.step-trigger').not('#aval_testeControle-trigger').hide();

					//Início da validção dos forms do bs-stepper (etapas do cadastro de processo)
					// Adicionar classe 'is-invalid' a todos os campos

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
								$("<span class='error invalid-feedback'>Selecione, pelo menos, uma opção.</span>").insertAfter("#btn_groupValorRecuperar");
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
								$("<span class='error invalid-feedback'>Selecione, pelo menos, uma opção.</span>").insertAfter("#btn_groupValorRisco");
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
								$("<span class='error invalid-feedback'>Selecione, pelo menos, uma opção.</span>").insertAfter("#btn_groupValorNaoPlanejado");
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
								required: true,
								atLeastOneSelected: true
							},
							pcAvaliacaoCategoriaControle: {
								required: true,
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
								required: "Campo obrigatório.",
								atLeastOneSelected: "Selecione pelo menos uma opção."
							},
							pcAvaliacaoCategoriaControle: {
								required: "Campo obrigatório.",
								atLeastOneSelected: "Selecione pelo menos uma opção."
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
					
					$('#pcTeste').val('')
					$('#pcControleTestado').val('')
					$('#pcAvaliacaoTipoControle').val('').trigger('change')
					$('#pcAvaliacaoCategoriaControle').val('').trigger('change')
					$('#pcNumSituacaoEncontrada').val('')
					$('#pcTituloSituacaoEncontrada').val('')
					$('#pcSintese').val('')
					$('#idCoso').val('')
					$('#selectDinamicoCOMPONENTE').val(null).trigger('change');

					$('#pcAvaliacaoRisco').val('').trigger('change')
					$('#pcAvaliacaoRiscoOutrosDescricaoDiv').attr("hidden",true);
					$('#pcAvaliacaoRiscoOutrosDesc').val('')


					$('#pcAvaliacaoRiscoOutrosDesc').val('')
					$('#pcTipoClassificacao').val('').trigger('change')

					//ações para os controles dos valores estimados	
					$('#pcValorRecuperar').val('')
					$('#pcValorRisco').val('')
					$('#pcValorNaoPlanejado').val('')

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
					$('#cabecalhoAccordion').text("Clique aqui para cadastrar um item (1° Passo)");	
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
										//resetFormFields();	
										//exibirTabAvaliacoes()
										//$('#CadastroAvaliacaoRelato').html("")
										mostraCadastroRelato(<cfoutput>'#rsProcForm.pc_processo_id#'</cfoutput>);
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
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "tabAvaliacoes",
							numProcesso: numProcesso
						},
						async: false,
						success: function(result) {
							$('#TabAvaliacao').html(result)
							
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









	<cffunction name="cadProcAvaliacaoItem"   access="remote"  returntype="any"> 
	
	    <cfargument name="pc_aval_id" type="string" required="false" default=''/>
		<cfargument name="pc_aval_processo" type="string" required="true"/>
		<cfargument name="pc_aval_teste" type="string" required="true"/>
		<cfargument name="pc_aval_tipoControle_id" type="string" required="true"/>
		<cfargument name="pc_aval_controleTestado" type="string" required="true"/>
		<cfargument name="pc_aval_categoriaControle_id" type="string" required="true"/>
		<cfargument name="pc_aval_numeracao" type="string" required="true"/><!--Numeração da Titulo. Inicialmente será manual-->
		<cfargument name="pc_aval_descricao" type="string" required="true"/><!--Manchete-->
		<cfargument name="pc_aval_sintese" type="string" required="true"/>
		<cfargument name="pc_aval_risco_id" type="string" required="true"/>
		<cfargument name="pc_aval_risco_outros" type="string" required="false"/>
		<cfargument name="pc_aval_coso_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_classificacao" type="string" required="true"/>
		<cfargument name="pc_aval_valorEstimadoRecuperar" type="string" required="false"/>
		<cfargument name="pc_aval_valorEstimadoRisco" type="string" required="false"/>
		<cfargument name="pc_aval_valorEstimadoNaoPlanejado" type="string" required="false"/>
		<cfargument name="pc_aval_criterioRef_id" type="numeric" required="true"/>
		<cfargument name="pcCriterioRefOutrosDesc" type="string" required="false"/>
		
		
        <cfif arguments.pc_aval_id eq '' >
			<cftransaction>

				<!--cadastra critério e referências se pc_criteroRef_id for igual a zero-->
				<cfif arguments.pc_aval_criterioRef_id eq 0>
					<cfquery datasource="#application.dsn_processos#" name="rsCriterioRef">
						INSERT INTO pc_avaliacao_criterioReferencia (pc_aval_criterioRef_descricao)
						VALUES ('#arguments.pcCriterioRefOutrosDesc#')
						SELECT SCOPE_IDENTITY() AS newIDcriterioRef;
					</cfquery>
					<cfset arguments.pc_aval_criterioRef_id = rsCriterioRef.newIDcriterioRef>
				</cfif>
				<!--fim cadastro criterio e referências se pc_criteroRef_id for igual a zero-->

				<!--cadastra avaliação-->
				<cfquery datasource="#application.dsn_processos#" name="rsAvaliacao">
					INSERT INTO pc_avaliacoes
									(pc_aval_status, pc_aval_processo, pc_aval_numeracao, pc_aval_datahora, pc_aval_atualiz_datahora,pc_aval_atualiz_login,
									pc_aval_avaliador_matricula, pc_aval_teste, pc_aval_controleTestado, 
									pc_aval_descricao, pc_aval_sintese,  pc_aval_coso_id, pc_aval_classificacao,
									pc_aval_valorEstimadoRecuperar, pc_aval_valorEstimadoRisco, pc_aval_valorEstimadoNaoPlanejado, pc_aval_criterioRef_id)
					VALUES     		(1,'#arguments.pc_aval_processo#', '#arguments.pc_aval_numeracao#', <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, '#application.rsUsuarioParametros.pc_usu_login#',#application.rsUsuarioParametros.pc_usu_matricula#,
										'#arguments.pc_aval_teste#',  '#arguments.pc_aval_controleTestado#', 
										'#arguments.pc_aval_descricao#', '#arguments.pc_aval_sintese#', '#arguments.pc_aval_coso_id#', '#arguments.pc_aval_classificacao#',
										'#arguments.pc_aval_valorEstimadoRecuperar#', '#arguments.pc_aval_valorEstimadoRisco#', '#arguments.pc_aval_valorEstimadoNaoPlanejado#', '#arguments.pc_aval_criterioRef_id#')
			        SELECT SCOPE_IDENTITY() AS newIDaval;
				</cfquery>  
				<!--fim cadastro avaliação-->

				<!-- cadastra avaliacao x tipos de controles-->	
				<cfloop list="#arguments.pc_aval_tipoControle_id#" index="i"> 
					<cfquery datasource="#application.dsn_processos#" name="rsAvalTipoControle">
						INSERT INTO pc_avaliacao_tiposControles (pc_aval_id, pc_aval_tipoControle_id)
						VALUES ('#rsAvaliacao.newIDaval#', '#i#')
					</cfquery>
				</cfloop>
				<!--fim cadastro avaliacao x tipos de controles-->

				<!-- cadastra avaliacao x categorias de controles-->
				<cfloop list="#arguments.pc_aval_categoriaControle_id#" index="i"> 
					<cfquery datasource="#application.dsn_processos#" name="rsAvalCategoriaControle">
						INSERT INTO pc_avaliacao_categoriasControles (pc_aval_id, pc_aval_categoriaControle_id)
						VALUES ('#rsAvaliacao.newIDaval#', '#i#')
					</cfquery>
				</cfloop>
				<!--fim cadastro avaliacao x categorias de controles-->

				<!-- início cadastro dos riscos selecionados e outros-->
				<!-- se arguments.pc_aval_risco_id não for igual a zero-->
				<cfif arguments.pc_aval_risco_id neq 0>
					<cfset  idAvalRisco = arguments.pc_aval_risco_id>
					<cfloop list="#idAvalRisco#" index="i"> 
						<!-- se i não for zero-->
						<cfif '#i#' neq 0>
						    <!--cadastra avaliação x riscos-->
							<cfquery datasource="#application.dsn_processos#" name="rsAvalRisco">
								INSERT INTO pc_avaliacao_riscos (pc_aval_id, pc_aval_risco_id)
								VALUES ('#rsAvaliacao.newIDaval#', '#i#')
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
				<!-- se pc_aval_risco_outros não estiver vazio, ou seja, se algum texto existir-->	
				<cfif arguments.pc_aval_risco_outros neq ''>
					<!--cadastra o novo risco (pc_aval_risco_outros)-->	
					<cfquery datasource="#application.dsn_processos#" name="rsRiscoOutros">
						INSERT INTO pc_avaliacao_risco (pc_aval_risco_descricao)
						VALUES ('#arguments.pc_aval_risco_outros#')
						SELECT SCOPE_IDENTITY() AS newIDrisco;
					</cfquery>
					<cfset  idAvalRisco = rsRiscoOutros.newIDrisco>
					<!--cadastra avaliação x riscos-->
					<cfquery datasource="#application.dsn_processos#" name="rsAvalRisco">
						INSERT INTO pc_avaliacao_riscos (pc_aval_id, pc_aval_risco_id)
						VALUES ('#rsAvaliacao.newIDaval#', '#idAvalRisco#')
					</cfquery>
				</cfif>	
				<!-- fim cadastro dos riscos selecionados e outros-->

				<!--mudar o status do processo de 2-Cadastrado para 3-Iniciado-->	
				<cfquery datasource="#application.dsn_processos#" >
					UPDATE pc_processos
					SET pc_num_status = 3
					WHERE  pc_processo_id = '#arguments.pc_aval_processo#'
				</cfquery> 	
				<!--fim mudar o status do processo de 2-Cadastrado para 3-Iniciado-->
			</cftransaction>

		<cfelse><!--se for edição-->
			<cftransaction>
				<!--cadastra critério e referências se pc_criteroRef_id for igual a zero-->
				<cfif arguments.pc_aval_criterioRef_id eq 0>
					<cfquery datasource="#application.dsn_processos#" name="rsCriterioRef">
						INSERT INTO pc_avaliacao_criterioReferencia (pc_aval_criterioRef_descricao)
						VALUES ('#arguments.pcCriterioRefOutrosDesc#')
						SELECT SCOPE_IDENTITY() AS newIDcriterioRef;
					</cfquery>
					<cfset arguments.pc_aval_criterioRef_id = rsCriterioRef.newIDcriterioRef>
				</cfif>
				<!--fim cadastro criterio e referências se pc_criteroRef_id for igual a zero-->

				<!--atualiza avaliação-->
				<cfquery datasource="#application.dsn_processos#" >
					UPDATE pc_avaliacoes
					SET pc_aval_teste = '#arguments.pc_aval_teste#',
						pc_aval_controleTestado = '#arguments.pc_aval_controleTestado#',
						pc_aval_numeracao = '#arguments.pc_aval_numeracao#',
						pc_aval_descricao = '#arguments.pc_aval_descricao#',
						pc_aval_sintese = '#arguments.pc_aval_sintese#',
						pc_aval_coso_id = '#arguments.pc_aval_coso_id#',
						pc_aval_classificacao = '#arguments.pc_aval_classificacao#',
						pc_aval_valorEstimadoRecuperar = '#arguments.pc_aval_valorEstimadoRecuperar#',
						pc_aval_valorEstimadoRisco = '#arguments.pc_aval_valorEstimadoRisco#',
						pc_aval_valorEstimadoNaoPlanejado = '#arguments.pc_aval_valorEstimadoNaoPlanejado#',
						pc_aval_criterioRef_id = '#arguments.pc_aval_criterioRef_id#',
						pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#'
					WHERE  pc_aval_id = '#arguments.pc_aval_id#'
				</cfquery> 
				<!--fim atualiza avaliação-->




				<!--cadastra avaliação x tipos de controles-->
				<cfquery datasource="#application.dsn_processos#" >
					DELETE FROM pc_avaliacao_tiposControles WHERE pc_aval_id = '#arguments.pc_aval_id#'
				</cfquery>
				<cfloop list="#arguments.pc_aval_tipoControle_id#" index="i"> 
					<cfquery datasource="#application.dsn_processos#" name="rsAvalTipoControle">
						INSERT INTO pc_avaliacao_tiposControles (pc_aval_id, pc_aval_tipoControle_id)
						VALUES ('#arguments.pc_aval_id#', '#i#')
					</cfquery>
				</cfloop>
				<!--fim cadastro avaliação x tipos de controles-->

				<!--cadastra avaliação x categorias de controles-->
				<cfquery datasource="#application.dsn_processos#" >
					DELETE FROM pc_avaliacao_categoriasControles WHERE pc_aval_id = '#arguments.pc_aval_id#'
				</cfquery>
				<cfloop list="#arguments.pc_aval_categoriaControle_id#" index="i"> 
					<cfquery datasource="#application.dsn_processos#" name="rsAvalCategoriaControle">
						INSERT INTO pc_avaliacao_categoriasControles (pc_aval_id, pc_aval_categoriaControle_id)
						VALUES ('#arguments.pc_aval_id#', '#i#')
					</cfquery>
				</cfloop>

				<!--cadastra avaliação x riscos-->
				<cfquery datasource="#application.dsn_processos#" >
					DELETE FROM pc_avaliacao_riscos WHERE pc_aval_id = '#arguments.pc_aval_id#'
				</cfquery>
				<!-- início cadastro dos riscos selecionados e outros-->
				<!-- se arguments.pc_aval_risco_id não for igual a zero-->
				<cfif arguments.pc_aval_risco_id neq 0>
					<cfset  idAvalRisco = arguments.pc_aval_risco_id>
					<cfloop list="#idAvalRisco#" index="i"> 
						<!-- se i não for zero-->
						<cfif '#i#' neq 0>
						    <!--cadastra avaliação x riscos-->
							<cfquery datasource="#application.dsn_processos#" name="rsAvalRisco">
								INSERT INTO pc_avaliacao_riscos (pc_aval_id, pc_aval_risco_id)
								VALUES ('#arguments.pc_aval_id#', '#i#')
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>

				<!-- se pc_aval_risco_outros não estiver vazio, ou seja, se algum texto existir-->	
				<cfif arguments.pc_aval_risco_outros neq ''>
					<!--cadastra o novo risco (pc_aval_risco_outros)-->	
					<cfquery datasource="#application.dsn_processos#" name="rsRiscoOutros">
						INSERT INTO pc_avaliacao_risco (pc_aval_risco_descricao)
						VALUES ('#arguments.pc_aval_risco_outros#')
						SELECT SCOPE_IDENTITY() AS newIDrisco;
					</cfquery>
					<cfset  idAvalRisco = rsRiscoOutros.newIDrisco>
					<!--cadastra avaliação x riscos-->
					<cfquery datasource="#application.dsn_processos#" name="rsAvalRisco">
						INSERT INTO pc_avaliacao_riscos (pc_aval_id, pc_aval_risco_id)
						VALUES ('#arguments.pc_aval_id#', '#idAvalRisco#')
					</cfquery>
				</cfif>	
				<!-- fim cadastro dos riscos selecionados e outros-->

				


				<!--Se a classificação for modificada para Leve, todas as orientações e propostas de melhoria do item serão excluídas-->
				<cfif '#arguments.pc_aval_classificacao#' eq 'L'>
					<cfquery datasource="#application.dsn_processos#" >
						Delete from pc_avaliacao_orientacoes WHERE  pc_aval_orientacao_num_aval = #arguments.pc_aval_id#
						Delete from pc_avaliacao_melhorias WHERE  pc_aval_melhoria_num_aval = #arguments.pc_aval_id#
					</cfquery>
				</cfif>
			</cftransaction>
		</cfif>

		

	</cffunction>








	 
	<cffunction name="tabAvaliacoes" returntype="any" access="remote" hint="Criar a tabela das avaliações e envia para a páginas pc_PcCadastroAvaliacaoPainel">
	
	 
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
						<table id="tabAvaliacoes" class="table table-bordered  table-hover table-striped">
						<thead style="background: #0083ca;color:#fff">
							<tr style="font-size:12px!important">
								<th >Controles</th>
								<th >Status: </th>
								<th >Item N°:</th>
								<th >Título da Situação Encontrada: </th>	
								<th >Classificação: </th>
								<th hidden>Última Atualização: </th>
								<th hidden></th><!--7 pc_aval_id-->
								<th hidden></th><!--8 pc_aval_teste-->
								<th hidden></th><!--9 pc_aval_tiposControles-->
								<th hidden></th><!--10 pc_aval_controleTestado-->
								<th hidden></th><!--11 pc_aval_categoriaControle-->
								<th hidden></th><!--12 pc_aval_sintese-->
								<th hidden></th><!--13 pc_aval_risco-->
								<th hidden></th><!--14 pc_aval_coso_id-->
								<th hidden></th><!--15 pc_aval_valorEstimadoRecuperar-->
								<th hidden></th><!--16 pc_aval_valorEstimadoRisco-->
								<th hidden></th><!--17 pc_aval_valorEstimadoNaoPlanejado-->
								<th hidden></th><!--18 pc_aval_criterioRef_id-->
								
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
												<cfif '#pc_aval_status#' eq '1' or '#pc_aval_status#' eq '3'>
													<cfif #rsAnexoAvaliacao.RecordCount# eq 0 && #rsOrientacoes.RecordCount# eq 0 && #rsMelhorias.RecordCount# eq 0>
														<i  class="fas fa-trash-alt efeito-grow"   style="margin-right:10px;cursor: pointer;z-index:100;font-size:20px" onclick="javascript:excluirAvaliacao(<cfoutput>'#pc_aval_id#'</cfoutput>,this);"    title="Excluir" ></i>
													<cfelse>
														<i  class="fas fa-trash-alt efeito-grow"  style="margin-right:10px;pedding:3px;cursor: pointer;z-index:100;font-size:20px" onclick="javascript:mensErro('Não é possível excluir avaliações com anexos, medidas/orientações para regularização e propostas de melhoria cadastrados!<br>Exclua todos os anexos, medidas/orientações para regularização e as propostas de melhoria e tente novamente.'); "   title="Excluir" ></i>
													</cfif>
													<i class="fas fa-edit efeito-grow"   style="margin-right:10px;cursor: pointer;z-index:100;font-size:20px"  onclick="javascript:editarAvaliacaoTitulo(this)"    title="Editar"></i>
												</cfif>

												<cfif '#pc_aval_status#' eq '5' &&  (#application.rsUsuarioParametros.pc_usu_perfil# eq 3 || #application.rsUsuarioParametros.pc_usu_perfil# eq 7 || #application.rsUsuarioParametros.pc_usu_perfil# eq 8 || #application.rsUsuarioParametros.pc_usu_perfil# eq 11)>
													<i class="fas fa-redo efeito-grow"   style="margin-right:10px;cursor: pointer;z-index:100;font-size:20px"  onclick="javascript:reverterValidacao(this)"    title="Reverter Validação"></i>
												</cfif>

												<i  class="fas fa-boxes-packing efeito-grow" onclick="javascript:mostraCadastroAvaliacaoRelato(<cfoutput>'#pc_aval_id#'</cfoutput>,this);"  style="cursor: pointer;z-index:100;font-size:20px"    title="Mostrar próximos passos." ></i>

											</div>
										</td>

										<cfif '#pc_aval_status#' eq '6' >
											<td align="center"  style="vertical-align: middle;"><p class="statusOrientacoes" style="<cfoutput>#pc_aval_status_card_style_ribbon#</cfoutput> ;padding:5px;vertical-align: middle;">ENVIADA PARA ACOMPANHAMENTO</p></td>
										<cfelse>
											<td align="center"  style="vertical-align: middle;"><p class="statusOrientacoes" style="<cfoutput>#pc_aval_status_card_style_ribbon#</cfoutput> ;padding:5px;">#pc_aval_status_descricao#</p></td>
										</cfif>

										<td  align="center" style="vertical-align: middle;">#pc_aval_numeracao# </td>
										<td  ><pre >#pc_aval_descricao#</pre></td>

										<cfset vaFalta = #LSCurrencyFormat(pc_aval_vaFalta, 'local')#>
										<cfset vaRisco = #LSCurrencyFormat(pc_aval_vaRisco, 'local')#>
										<cfset vaSobra = #LSCurrencyFormat(pc_aval_vaSobra, 'local')#>
										<td>#classifRisco#</td>

																					
										<cfset dataHora = DateFormat(#pc_aval_atualiz_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_aval_atualiz_datahora#,'HH:mm:ss') & ')'>
										<td hidden>#dataHora# - #pc_aval_atualiz_login#</td>
										<td hidden>#pc_aval_id#</td>
										<td hidden>#pc_aval_teste#</td>
										<td hidden>#listaTiposControles#</td>
										<td hidden>#pc_aval_controleTestado#</td>
										<td hidden>#listaCategoriasControles#</td>
										<td hidden>#pc_aval_sintese#</td>
										<td hidden>#listaRiscos#</td>
										<td hidden>#pc_aval_coso_id#</td>
										<td hidden>#pc_aval_valorEstimadoRecuperar#</td>
										<td hidden>#pc_aval_valorEstimadoRisco#</td>
										<td hidden>#pc_aval_valorEstimadoNaoPlanejado#</td>
										<td hidden>#pc_aval_criterioRef_id#</td>

										
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
				$("#tabAvaliacoes").DataTable({
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

			

			function reverterValidacao(linha){
				event.preventDefault()
				event.stopPropagation()
				$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
				var pc_aval_id = $(linha).closest("tr").children("td:nth-child(8)").text();
                var mensagem = "Deseja reverter a validação deste item?";
				
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!',
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							//var dataEditor = $('.editor').html();
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAvaliacoes.cfc",
									data:{
										method: "reverterValidacaoItem",
										pc_aval_id: pc_aval_id
										
									},
									async: false
								})//fim ajax
								.done(function(result) {	
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});	
									exibirTabAvaliacoes()
									$('#CadastroAvaliacaoRelato').html("")
									
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
									})
								})//fim fail
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

			

			function editarAvaliacaoTitulo(linha) {
				event.preventDefault()
				event.stopPropagation()
                resetFormFields();
				$('.step-trigger').show();
				//incializa no primeiro step
				stepper.to(1);

                let pc_aval_id = $(linha).closest("tr").children("td:nth-child(7)").text();


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
							let data = JSON.parse(result);
							//return false;
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
								$('#pcAvaliacaoTipoControle').val(pc_aval_controleTestado).trigger('change');
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

								
							
												
								$('#cabecalhoAccordion').text("Editar o item N°:" + ' ' + pcNumSituacaoEncontrada);
								$('#infoTipoCadastro').text("Editando o Item N°:" + ' ' + pcNumSituacaoEncontrada);
								$('#mensagemFinalizar').html('<h5>Clique no botão "Salvar" para <span style="color: green;font-size: 1.5rem">EDITAR</span> o Item'  + ' <span style="color: green;font-size: 1.5rem"><strong>' + pcNumSituacaoEncontrada + '</strong></span></h5>');
								$("#btSalvar").attr("hidden",false);
								$("#mensagemSalvar").attr("hidden",false);

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

			
			function excluirAvaliacao(pc_aval_id, linha)  {
				event.preventDefault()
		        event.stopPropagation()
			   
				<cfoutput>var pc_aval_processo = '#arguments.numProcesso#';</cfoutput>
                var mensagem = "Deseja excluir este item?";
				
				
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!',
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							//var dataEditor = $('.editor').html();
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAvaliacoes.cfc",
									data:{
										method: "delAvaliacao",
										pc_aval_id: pc_aval_id,
										pc_aval_processo: pc_aval_processo
										
									},
									async: false
								})//fim ajax
								.done(function(result) {
									 resetFormFields();	
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});	
									exibirTabAvaliacoes()
									mostraCads()
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
									})
								})//fim fail
							}, 1000);//fim setTimeout
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
			}
		</script>				


	</cffunction>





	<cffunction name="delAvaliacao"   access="remote" hint="deleta avaliação páginas pc_Avaliacoes.cfm tabela chamada pelo metodo tabAvaliacoes">
		<cfargument name="pc_aval_id" type="numeric" required="true" />
		<cfargument name="pc_aval_processo" type="string" required="true" />

		<cftransaction>
			<cfquery datasource="#application.dsn_processos#" name="rsAnexoAvaliacao">
				SELECT pc_anexos.pc_anexo_avaliacao_id FROM pc_anexos WHERE pc_anexo_avaliacao_id = #arguments.pc_aval_id# 
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
				SELECT pc_avaliacao_melhorias.pc_aval_melhoria_num_aval FROM pc_avaliacao_melhorias WHERE pc_aval_melhoria_num_aval = #arguments.pc_aval_id#
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" >
				DELETE FROM pc_validacoes_chat
				WHERE pc_validacao_chat_num_aval= '#arguments.pc_aval_id#'
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_categoriasControles
				WHERE pc_aval_id= '#arguments.pc_aval_id#'
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_tiposControles
				WHERE pc_aval_id= '#arguments.pc_aval_id#'
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_riscos
				WHERE pc_aval_id= '#arguments.pc_aval_id#'
			</cfquery>

			<cfif #rsAnexoAvaliacao.RecordCount# eq 0 && #rsMelhorias.RecordCount# eq 0>
				<cfquery datasource="#application.dsn_processos#" >
					DELETE FROM pc_avaliacoes
					WHERE pc_aval_id= '#arguments.pc_aval_id#'
				</cfquery> 
			</cfif>

			<cfquery datasource="#application.dsn_processos#" name="rsAvaliacoes">
				SELECT pc_avaliacoes.pc_aval_id FROM pc_avaliacoes WHERE pc_aval_processo = '#arguments.pc_aval_processo#'
			</cfquery>

			<cfif #rsAvaliacoes.recordCount#  eq 0>
				<cfquery datasource="#application.dsn_processos#" >
					UPDATE pc_processos
					SET pc_num_status = 2
					WHERE  pc_processo_id = '#arguments.pc_aval_processo#'
				</cfquery> 	
			</cfif>
		</cftransaction>
	</cffunction>


 
	





	<cffunction name="validarItem"   access="remote" hint="valida (ou  não) a avaliação e, se foi a Última avaliação a ser validada, envia o processo para o Órgão responsável.">
		<cfargument name="pc_aval_id" type="numeric" required="true" />
		<cfargument name="pc_aval_processo" type="string" required="true" />
		<cfargument name="pcValidar" type="numeric" required="false" default=0/>
		<cfargument name="pc_validacao_chat_matricula_para" type="string" required="false" />
		<cfargument name="pc_validacao_chat_texto" type="string" required="false" />

		
		
		<cfif #arguments.pcValidar# eq 1><!--Se a opção seleciona foi 1 - "Validar este item"-->
			<cftransaction>
				<!--COLOCA A AVALIAÇÃO NO STATUS 5 (VALIDADA)-->
				<cfquery datasource="#application.dsn_processos#" >
					UPDATE      pc_avaliacoes
					SET         pc_aval_status = 5,
								pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
					WHERE       (pc_aval_id = #arguments.pc_aval_id#)
				</cfquery>

				<!--VERIFICA SE EXISTEM AVALIAÇÕES NÃO VALIDADAS NO PROCESSO -->
				<cfquery datasource="#application.dsn_processos#" name="rsAvaliacoesValidadas">
					SELECT      pc_avaliacoes.pc_aval_status FROM pc_avaliacoes
					WHERE       pc_aval_processo = '#arguments.pc_aval_processo#' and  pc_aval_status in (1,2,3)
				</cfquery>

				<!-- Se  não houverem avaliações sem validar-->
				<cfif #rsAvaliacoesValidadas.recordcount# eq 0>
					<!-- Lista todas as medidas/orientações para regularização do processo -->
					<cfquery datasource="#application.dsn_processos#" name="rsProcessoComOrientacoes">
						SELECT  pc_avaliacao_orientacoes.*,pc_avaliacoes.*, pc_processos.pc_modalidade, pc_processos.pc_iniciarBloqueado
						,pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_email, pc_orgao_avaliado.pc_org_email as pc_orgao_avaliado_email
						,pc_orgao_avaliado.pc_org_sigla as pc_orgao_avaliado_sigla
						FROM pc_avaliacao_orientacoes
						LEFT JOIN  pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
						INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
						INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
						INNER JOIN pc_orgaos as pc_orgao_avaliado on pc_orgao_avaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
						WHERE      pc_aval_processo = '#arguments.pc_aval_processo#' 
					</cfquery>

					<!--Insere em uma lista a relação de e-mails dos órgãos responsáveis pelas orientações do processo-->
					<cfset listaEmailsOrgaos = "">	
					<cfloop query="rsProcessoComOrientacoes">
						<cfif listFind(listaEmailsOrgaos,rsProcessoComOrientacoes.pc_org_email) eq 0 and rsProcessoComOrientacoes.pc_org_email neq rsProcessoComOrientacoes.pc_orgao_avaliado_email>
							<cfset listaEmailsOrgaos = listaEmailsOrgaos &  LTrim(RTrim(rsProcessoComOrientacoes.pc_org_email)) & ','>
						</cfif>
					</cfloop>

					<!-- Lista todos os e-mails dos órgãos com Propostas de Melhoria no processo -->
					<cfquery datasource="#application.dsn_processos#" name="rsPropostasMelhoria">
						SELECT pc_orgaos.pc_org_email from pc_avaliacao_melhorias
						INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
						INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
						INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
						WHERE pc_aval_processo = '#arguments.pc_aval_processo#'
					</cfquery>

                    <!--Insere em uma lista a relação de e-mails dos órgãos responsáveis pelas propostas de melhoria-->
					<cfloop query="rsPropostasMelhoria">
						<cfif listFind(listaEmailsOrgaos,rsPropostasMelhoria.pc_org_email) eq 0 and rsPropostasMelhoria.pc_org_email neq rsProcessoComOrientacoes.pc_orgao_avaliado_email>
							<cfset listaEmailsOrgaos = listaEmailsOrgaos &  LTrim(RTrim(rsPropostasMelhoria.pc_org_email)) & ','>
						</cfif>
					</cfloop>

                     
				   <!--SE O PROCESSO ESTIVER BLOQUEADO, COLOCA TODAS AS PROPOSTAS DE MELHORIA COM STATUS B (BLOQUEADO)-->
				    <cfif rsProcessoComOrientacoes.pc_iniciarBloqueado eq 'S'>
						<cfquery datasource="#application.dsn_processos#" >
							UPDATE pc_avaliacao_melhorias set
								pc_aval_melhoria_status = 'B',
								pc_aval_melhoria_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								pc_aval_melhoria_login = '#application.rsUsuarioParametros.pc_usu_login#'
							WHERE pc_aval_melhoria_num_aval in (select pc_aval_id from pc_avaliacoes where pc_aval_processo = '#arguments.pc_aval_processo#')
						</cfquery>
					</cfif>

					<!-- Retorna informações do processo para enviar e-mail-->			
					<cfquery datasource="#application.dsn_processos#" name="rsProcesso">
						SELECT  pc_processos.*, pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_email,pc_avaliacao_tipos.pc_aval_tipo_descricao  FROM pc_processos
						INNER JOIN pc_orgaos on pc_num_orgao_avaliado = pc_org_mcu
           				INNER JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
						WHERE pc_processo_id = '#arguments.pc_aval_processo#'
					</cfquery>

					<!--Se não hoverem medidas/orientações para regularização no processo (ou seja, só existem propostas de melhoria ou itens leves)-->
					<cfif  rsProcessoComOrientacoes.recordcount eq 0>   
						<!--Finaliza o processo-->  
						<cfquery datasource="#application.dsn_processos#" >
							UPDATE      pc_processos
							SET         pc_num_status = 5,
										pc_alteracao_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
										pc_alteracao_login = '#application.rsUsuarioParametros.pc_usu_login#',
										pc_iniciarBloqueado = 'N'
							WHERE       (pc_processo_id = '#arguments.pc_aval_processo#')
						</cfquery>
						

					<cfelse><!--CASO CONTRÁRIO, SE EXISTIR, PELO MENOS, UMA ORIENTAÇÃO NO PROCESSO-->
						<!--COLOCA O PROCESSO EM STATUS 4 - ACOMPANHAMENTO OU 6 - BLOQUEADO-->
						<cfquery datasource="#application.dsn_processos#" >
							UPDATE pc_processos
							SET         
										<cfif rsProcessoComOrientacoes.pc_iniciarBloqueado eq 'S'>
											pc_num_status = 6,
										<cfelse>
											pc_num_status = 4,
										</cfif>
										pc_alteracao_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
										pc_alteracao_login = '#application.rsUsuarioParametros.pc_usu_login#'
							WHERE       (pc_processo_id = '#arguments.pc_aval_processo#')
						</cfquery>
						

						<!--FINALIZA TODOS OS ITENS LEVES DO PROCESSO-->
						<cfquery datasource="#application.dsn_processos#" >
							UPDATE      pc_avaliacoes
							SET         pc_aval_status=7,
										pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
										pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
							WHERE       pc_aval_processo = '#arguments.pc_aval_processo#' AND pc_aval_classificacao ='L'
						</cfquery>

						
						
						<!-- LOOP EM CADA ORIENTAÇÃO DO PROCESSO-->
						<cfloop query="rsProcessoComOrientacoes">
							<!--COLOCA O ITEM DA ORIENTAÇÃO NO STATUS 6 - ACOMPANHAMENTO OU 8 - BLOQUEADO -->
							<cfquery datasource="#application.dsn_processos#" >
								UPDATE      pc_avaliacoes
								SET   
								<cfif rsProcessoComOrientacoes.pc_iniciarBloqueado eq 'S'>      
									pc_aval_status=8,
								<cfelse>
									pc_aval_status=6,
								</cfif>
											pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
											pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
								WHERE       pc_aval_id =  #pc_aval_orientacao_num_aval#
							</cfquery>


							<cfif  #rsProcessoComOrientacoes.pc_modalidade# neq 'A'>  
								<!--Adiciona 30 dias úteis à data atual para gerar a data prevista para resposta que constara np texto do manifestação-->
								<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio">
								<cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias = 30 />
								<cfset dataPTBR = obterDataPrevista.Data_Prevista_Formatada>
								<cfset dataCFQUERY = "#DateFormat(obterDataPrevista.Data_Prevista,'YYYY-MM-DD')#">	
								<!--Coloca a orientação no status 4 (NÃO RESPONDIDO) e insere prazo de 30 dias úteis como data prevista para resposta-->
								<cfquery datasource="#application.dsn_processos#" >
									UPDATE 	pc_avaliacao_orientacoes      
									SET   	
									<cfif rsProcessoComOrientacoes.pc_iniciarBloqueado eq 'S'>      
										pc_aval_orientacao_status = 14,
									<cfelse>
										pc_aval_orientacao_status = 4,
									</cfif>
											pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#',
											pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
											pc_aval_orientacao_dataPrevistaResp = '#dataCFQUERY#'
									WHERE   pc_aval_orientacao_id = #pc_aval_orientacao_id#
								</cfquery>
								
								
								<!--Texto padrão manifestação-->
								<cfif rsProcessoComOrientacoes.pc_iniciarBloqueado eq 'S'>
									<cfset posicaoInicial = "Processo BLOQUEADO.<br>Este relatório aguarda a finalização de análises complementares do controle interno e/ou outros órgãos da empresa para liberação ao ÓRGÃO AVALIADO. Favor aguardar.">
									<cfset orgaoResp = ''>
									<cfset posic_status = 14>
								<cfelse>
									<cfset posicaoInicial = "Para registro de sua manifestação orienta-se a atentar para as “Orientações/Medidas de Regularização” emitidas pela equipe de Controle Interno, bem como anexar no sistema SNCI as evidências de implementação das ações adotadas. Também solicita-se sua manifestação para as 'Propostas de Melhoria' conforme opções disponíveis no sistema.">
								    <cfset orgaoResp = '#pc_aval_orientacao_mcu_orgaoResp#'>
									<cfset posic_status = 4>
								</cfif>
								<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
								<cfquery datasource="#application.dsn_processos#">
									INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado)
									VALUES ('#pc_aval_orientacao_id#', '#posicaoInicial#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#orgaoResp#','#dataCFQUERY#',#posic_status#,1)
								</cfquery>

							<cfelse>

								<!--Se for modalidade acompanhamento, coloca a orientação no status 1 (PENDENDE DE MANIFESTAÇÃO INICIAL (CONTROLE INTERNO))-->
								<cfquery datasource="#application.dsn_processos#" >
									UPDATE 	pc_avaliacao_orientacoes      
									SET   	pc_aval_orientacao_status = 1,
											pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#',
											pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
											
									WHERE   pc_aval_orientacao_id = #pc_aval_orientacao_id#
								</cfquery>


							</cfif>
						</cfloop><!--Fim do LOOP que coloca a orientação no status 4 (NÃO RESPONDIDO) e insere prazo de 30 dias como data prevista para resposta-->

					</cfif><!--Fim do IF que verifica se o processo tem medidas/orientações para regularização -->
					
				
					<cfif  #rsProcessoComOrientacoes.pc_modalidade# neq 'A'> 
						<!--Finaliza todos os itens do processo que não estão no status 6-ACOMPANHAMENTO ou 8-BLOQUEADO ou seja, não tem medidas/orientações para regularização, pois só possuem propostas de melhoria e elas não são acompanhadas, OU SÃO ITENS LEVES-->   
						<cfquery datasource="#application.dsn_processos#" >
							UPDATE      pc_avaliacoes
							SET         pc_aval_status=7,
										pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
										pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
							WHERE       pc_aval_processo = '#arguments.pc_aval_processo#' and not pc_aval_status in(6,8)
						</cfquery>
					</cfif>

				<cftry>		
					<!-- Se o processo não estiver bloqueado e a modalidade não for ACOMPANHAMENTO, envia e-mail para o órgão avaliado, com cópia para os órgãos responsáveis pelas orientações do processo-->
					<cfif rsProcessoComOrientacoes.pc_iniciarBloqueado neq 'S' and rsProcesso.pc_modalidade neq 'A'>
							
							<cfset to = "#LTrim(RTrim(rsProcesso.pc_org_email))#">
							<cfset cc = "#listaEmailsOrgaos#">
							<cfset siglaOrgaoAvaliado = "#LTrim(RTrim(rsProcesso.pc_org_sigla))#">
							<cfset anoPacin = "#LTrim(RTrim(rsProcesso.pc_ano_pacin))#">
							
							<cfif #rsProcesso.pc_num_avaliacao_tipo# eq 2><!--Se o tipo de avaliação for "NÃO SE APLICA", pega a informação da coluna pc_aval_tipo_nao_aplica_descricao-->
								<cfset tipoAvaliacao = #LTrim(RTrim(rsProcesso.pc_aval_tipo_nao_aplica_descricao))#>
							<cfelse>
								<cfset tipoAvaliacao = #LTrim(RTrim(rsProcesso.pc_aval_tipo_descricao))#>
							</cfif>
							<!-- se sigla do órgão avaliado começar com SE/, sem espaço antes, usa o pronome de tratamento "Senhor(a) Superintendente Estadual", caso contrárioa usa "Senhor(a) Chefe de Departamento"-->
							<cfif left(LTrim(RTrim(siglaOrgaoAvaliado)),3) eq 'SE/'>
								<cfset pronomeTrat = "Senhor(a) Superintendente Estadual da #siglaOrgaoAvaliado#">
							<cfelse>
								<cfset pronomeTrat = "Senhor(a) Chefe de Departamento do #siglaOrgaoAvaliado#">
							</cfif>
							<!--Se o tipo de demanda for "P" (Plano Anual de Controle Interno - PACIN), usa o texto abaixo-->
							<cfif #rsProcesso.pc_tipo_demanda# eq "P">
								<cfset textoEmail = '<p>Em cumprimento ao Plano Anual de Controle Interno – PACIN #anoPacin#, que consolida o planejamento das ações a serem realizadas pelo Departamento de Controle Interno – DCINT, encaminhamos o Relatório - SEI e seus respectivos anexos, referentes à avaliação de controles no processo "#tipoAvaliacao#", para conhecimento e adoção de providências nos termos constantes dos aludidos documentos.</p>
													<p>Considerando os resultados das análises e ORIENTAÇÕES/PROPOSTAS DE MELHORIA apresentadas no mencionado relatório, recomenda-se a #siglaOrgaoAvaliado# a elaboração de plano de ação, com estabelecimento de prazos e responsáveis, objetivando a implementação de melhorias no processo avaliado.<br><br>O plano de ação deverá apresentar providências focadas nas "Situações Encontradas" registradas nos Anexos I, considerando as ORIENTAÇÕES para Regularização citadas no Anexo III.</p>
													<p>O prazo de resposta inicial para este Relatório é de 30 dias, a contar do recebimento deste.</p>
													<p>Ressalta-se que a implementação do plano de ação será acompanhada pelo CONTROLE INTERNO para os itens classificados como GRAVE e MEDIANO, e todas as ações implementadas deverão ser evidenciadas (documentadas) por esse gestor, com a inserção das comprovações no sistema SNCI Processos. Itens classificados como "Leve", são encaminhados para conhecimento e adoção de providências por esse gestor, porém não serão acompanhados pelo Controle Interno.</p> 
													<p>As Propostas de Melhoria estão cadastradas no sistema com status "PENDENTE", para que os gestores dos órgãos avaliados registrem suas manifestações, observando as opções a seguir:</p>   
														<ul>
															<li>ACEITA: situação em que a "Proposta de Melhoria" é aceita pelo gestor. Neste caso, deverá ser informada a data prevista de implementação;</li><br>   
															<li>RECUSA: situação em que a "Proposta de Melhoria" é recusada pelo gestor, com registro da justificativa para essa ação;</li> <br> 
															<li>TROCA: situação em que o gestor propõe outra ação em substituição à "Proposta de Melhoria" sugerida pelo Controle Interno. Nesse caso indicar o prazo previsto de implementação.</li>  
														</ul>
													<p>Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "Medidas / Orientações para regularização" e/ou "Propostas de Melhoria"  e inserir sua resposta:</p>
													<p><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>'>
							
							<cfelse>

								<cfset textoEmail = '<p>A par de cumprimentá-lo, informa-se que o Departamento de Controle Interno (DCINT), no cumprimento de suas atribuições, realiza avaliações de controles extraordinárias, de acordo com as normas internas.</p> 
													<p>Nesse sentido, em consonância com o MANORG, Módulo 04, Capítulo 08, subitem 4.10, foi realizada avaliação de controle interno no processo "#tipoAvaliacao#". </p> 
													<p>Após a finalização dos trabalhos, encaminha-se o Relatório de Avaliação de Controles Internos e seus respectivos anexos, referentes a essa avaliação de controles, para conhecimento e adoção de providências nos termos constantes dos aludidos documentos.</p>  
													<p>Considerando os resultados das análises e ORIENTAÇÕES/PROPOSTAS DE MELHORIA” apresentadas no mencionado relatório, recomenda-se a #siglaOrgaoAvaliado# a elaboração de plano de ação, com estabelecimento de prazos e responsáveis, objetivando a implementação de melhorias no processo avaliado.</p>   
													<p>O plano de ação deverá apresentar providências focadas nas “Situações Encontradas registradas nos Anexos I, considerando as ORIENTAÇÕES para Regularização citadas no Anexo III. O prazo de resposta inicial para este Relatório é de 30 dias, a contar do recebimento deste.</p>  
													<p>Ressalta-se que a implementação do plano de ação será acompanhada pelo CONTROLE INTERNO para os itens classificados como GRAVE e MEDIANO, e todas as ações implementadas deverão ser evidenciadas (documentadas) por esse gestor, com a inserção das comprovações no sistema SNCI Processos. Itens classificados como "Leve", são encaminhados para conhecimento e adoção de providências por esse gestor, porém não serão acompanhados pelo Controle Interno.</p> 
													<p>As Propostas de Melhoria estão cadastradas no sistema com status "PENDENTE", para que os gestores dos órgãos avaliados registrem suas manifestações, observando as opções a seguir:</p>   
														<ul>
															<li>ACEITA: situação em que a "Proposta de Melhoria" é aceita pelo gestor. Neste caso, deverá ser informada a data prevista de implementação;</li> <br>  
															<li>RECUSA: situação em que a "Proposta de Melhoria" é recusada pelo gestor, com registro da justificativa para essa ação;</li>   <br>  
															<li>TROCA: situação em que o gestor propõe outra ação em substituição à "Proposta de Melhoria" sugerida pelo Controle Interno. Nesse caso indicar o prazo previsto de implementação.</li> 
														</ul>
													<p>Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "Medidas / Orientações para regularização" e/ou "Propostas de Melhoria"  e inserir sua resposta:</p>
													<p><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>'>

							</cfif>


							<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio2"/>
							<cfinvoke component="#pc_cfcPaginasApoio2#" method="EnviaEmails" returnVariable="sucessoEmail" 
							para = "#to#"
							copiaPara = "#cc#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
							/>
					</cfif>
				<cfcatch type="any">
					<cfmail from="SNCI@correios.com.br" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "validarItem" de validação e encaminhamento de orientações: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry>

				</cfif><!--Fim do IF que verifica se todos os itens foram validados -->
			</cftransaction>
		</cfif><!--Fim do IF que verifica se a opção seleciona foi 1 - "Validar este item"-->

		<!--Se a opção seleciona foi "Não validar"-->
		<cfif #arguments.pcValidar# eq 2>
			<cfset matriculaPara = '#Right(arguments.pc_validacao_chat_matricula_para,8)#'>
			<cfquery datasource="#application.dsn_processos#" >
				INSERT pc_validacoes_chat(pc_validacao_chat_num_aval,pc_validacao_chat_matricula_de,pc_validacao_chat_matricula_para,pc_validacao_chat_texto,pc_validacao_chat_dataHora)
				VALUES	(#arguments.pc_aval_id#,'#application.rsUsuarioParametros.pc_usu_matricula#','#matriculaPara#','#arguments.pc_validacao_chat_texto#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" >
				UPDATE  pc_avaliacoes
				SET     pc_aval_status = 3,
						pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
				WHERE   (pc_aval_id = #arguments.pc_aval_id#)
			</cfquery>
		</cfif>

		<!--Se a opção seleciona foi 0 (defaut) significa que o chat está enviando p/ Validação.-->
		<cfif #arguments.pcValidar# eq 0>
		    <cfset matriculaPara = '#Right(arguments.pc_validacao_chat_matricula_para,8)#'>
			<cfquery datasource="#application.dsn_processos#" >
				INSERT pc_validacoes_chat(pc_validacao_chat_num_aval,pc_validacao_chat_matricula_de,pc_validacao_chat_matricula_para,pc_validacao_chat_texto,pc_validacao_chat_dataHora)
				VALUES	(#arguments.pc_aval_id#,'#application.rsUsuarioParametros.pc_usu_matricula#','#matriculaPara#','#arguments.pc_validacao_chat_texto#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">)
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" >
				UPDATE  pc_avaliacoes
				SET     pc_aval_status = 2,
						pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
				WHERE   pc_aval_id = #arguments.pc_aval_id#
			</cfquery>
			<cfset matriculaPara = '#Right(arguments.pc_validacao_chat_matricula_para,8)#'>	
		</cfif>

	</cffunction>




	<cffunction name="reverterValidacaoItem"   access="remote" hint="valida (ou  não) a avaliação e, se foi a Última avaliação a ser validada, envia o processo para o Órgão responsável.">
		<cfargument name="pc_aval_id" type="numeric" required="true" />
		<!--COLOCA A AVALIAÇÃO NO STATUS 1 (NÃO CONCLUÍDA)-->
		<cfquery datasource="#application.dsn_processos#" >
			UPDATE      pc_avaliacoes
			SET         pc_aval_status = 1,
						pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
			WHERE       (pc_aval_id = #arguments.pc_aval_id#)
		</cfquery>

	</cffunction>






	<cffunction name="cadastroAvaliacaoRelato"   access="remote" hint="valida (ou  não) a avaliação e, se foi a Última avaliação a ser validada, envia o processo para o Órgão responsável.">
		
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
							
								
								<li class="nav-item" style="">
									<a  class="nav-link active" id="custom-tabs-one-2passo-tab"  data-toggle="pill" href="#custom-tabs-one-2passo" role="tab" aria-controls="custom-tabs-one-2passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">2° Passo - Relatório do Item<cfelse>Relatório do Item</cfif></a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-3passo-tab"  data-toggle="pill" href="#custom-tabs-one-3passo" role="tab" aria-controls="custom-tabs-one-3passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">3° Passo - Anexos<cfelse>Anexos</cfif></a>
								</li>
								
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-4passo-tab"  data-toggle="pill" href="#custom-tabs-one-4passo" role="tab" aria-controls="custom-tabs-one-4passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">4° Passo - Medida/Orientação para Regularização<cfelse>Medida/Orientação para Regularização</cfif></a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-5passo-tab"  data-toggle="pill" href="#custom-tabs-one-5passo" role="tab" aria-controls="custom-tabs-one-5passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">5° Passo - Proposta de Melhoria<cfelse>Proposta de Melhoria</cfif></a>
								</li>
								
								<cfif '#arguments.passoapasso#' eq "true">
								<!--Se o status do item não for VALIDADA, o passo 6 será visível.-->
									<cfif #rsProcAval.pc_aval_status# neq 5>
										<li class="nav-item">
											<a  class="nav-link " id="custom-tabs-one-6passo-tab"  data-toggle="pill" href="#custom-tabs-one-6passo" role="tab" aria-controls="custom-tabs-one-6passo" aria-selected="true"><cfif #rsProcAval.pc_modalidade# eq 'A' or #rsProcAval.pc_modalidade# eq 'E'>6° Passo - Finalizar<cfelse>6° Passo - Enviar p/ Validação</cfif></a>
										</li>
									</cfif>

									<cfif #rsProcAval.pc_aval_status# eq 2>
										<li class="nav-item">
											<a  class="nav-link " id="custom-tabs-one-7passo-tab"  data-toggle="pill" href="#custom-tabs-one-7passo" role="tab" aria-controls="custom-tabs-one-7passo" aria-selected="true">7° Passo - Validar</a>
										</li>
									</cfif>
								</cfif>
							</ul>
							
						</div>
						<div class="card-body" style="align-items: center;">
							<div class="tab-content" id="custom-tabs-one-tabContent">
								
							
								<div disable class="tab-pane fade active show" id="custom-tabs-one-2passo"  role="tabpanel" aria-labelledby="custom-tabs-one-2passo-tab" >
									
									
										<cfif (#rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3)  && (#rsProcAval.pc_modalidade# eq 'A' or #rsProcAval.pc_modalidade# eq 'E')>
											<div class="row">
												<div class="col-md-12">
													<div class="card card-default">
														
														<div class="card-body">
															<div id="actions" class="row" >
																<div class="col-lg-12" align="center">
																	<div class="btn-group w-30">
																		<span id="avaliacoes" class="btn btn-success col fileinput-button" style="background:#0083CA">
																			<i class="fas fa-upload"></i>
																			<span style="margin-left:5px">Clique aqui para anexar o Relatório em PDF, exclusivo deste item (caso exista)</span>
																		</span>																	
																	</div>
																</div>
															</div>
															
															<div class="table table-striped files" id="previews">
															<div id="template" class="row mt-2">
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

														
													</div>
													
													</div>
													<!-- /.card -->
												</div>
											</div>
										</cfif>
								

									<div id="anexoAvaliacaoDiv"></div>


									<cfif #rsProcAval.pc_modalidade# eq 'N' >
										<div align="center">
											<div class="container">
												<textarea  id="pcSituacaoEncontrada" name="pcSituacaoEncontrada"><cfoutput>#rsProcAval.pc_aval_relato#</cfoutput></textarea>							
											</div>
											
											<div style="margin-top:10px;">
												<div id="divTabAvaliacaoVersoes"></div>
											</div>
										</div>
									</cfif>

								</div>

								<div class="tab-pane fade " id="custom-tabs-one-3passo" role="tabpanel" aria-labelledby="custom-tabs-one-3passo-tab">
									
									<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>	
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
									</cfif>
									
									<div id="tabAnexosDiv" style="margin-top:20px"></div>

								</div>

								<div class="tab-pane fade " id="custom-tabs-one-4passo" role="tabpanel" aria-labelledby="custom-tabs-one-4passo-tab" >
								   
									<cfif rsProcAval.pc_aval_classificacao neq 'L'>
										<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>
											<div id="formAvalOrientacaoCadastroDiv"></div>
										</cfif>
										<div id="tabOrientacoesDiv" style="margin-top:20px"></div>
									<cfelse>
										<div class="badge " style=" background-color:#e83e8c;color:#fff;font-size:20px;">Não se aplica para itens com classificação "LEVE".</div>
									</cfif>
								
								</div>


                                <!-- @note custom-tabs-one-5passo-->
								<div class="tab-pane fade " id="custom-tabs-one-5passo" role="tabpanel" aria-labelledby="custom-tabs-one-5passo-tab">

									<cfif rsProcAval.pc_aval_classificacao neq 'L'>
										<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>
											<div id="formAvalMelhoriaCadastroDiv"></div>
										</cfif>
										<div id="tabMelhoriasDiv" style="margin-top:20px;"></div>
									<cfelse>
										<div class="badge " style=" background-color:#e83e8c;color:#fff;font-size:20px;">Não se aplica para itens com classificação "LEVE".</div>
									</cfif>
									
								</div>

								<cfif #arguments.passoapasso# eq "true">	
									<div  class="tab-pane fade"  id="custom-tabs-one-6passo" role="tabpanel" aria-labelledby="custom-tabs-one-6passo-tab">
																			
										<div id="pendenciasDiv"></div>
										
									</div>

									<div class="tab-pane fade "  id="custom-tabs-one-7passo" role="tabpanel" aria-labelledby="custom-tabs-one-7passo-tab">
										<div  class="row">							
											<div class="col-sm-4">
												<select id="pcValidar" required="" name="pcValidar" class="form-control"  style="height:40px;background-color: #00416b;color: #fff;font-size: 20px;">
													<option selected="" disabled="" value="" >Selecione o que deseja fazer..</option>
													<option  value="1" >Validar este item</option>
													<option  value="2" >Não validar</option>
												</select>
											</div>
											<div class="col-sm-3 moveChat">
												<button id="btValidarPasso7"  class="btn btn-success" style="display: none;">Clique aqui p/ validar</button>		
											</div>
											
										</div>
										<div  class="col-sm-12" style="display:flex">
											<div  class="col-sm-6">
												<div id="divChatValidacaoForm7passo" ></div>
											</div>
											<div  class="col-sm-6 moveChat">
												<div  ></div>
											</div>
										</div>
									</div>	

									
								</cfif>
								
								
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

			if(modalidadeProcesso ==='N'){
				CKEDITOR.replace( 'pcSituacaoEncontrada', {
					width: '100%',
					height: 300,
					on: {
						instanceReady: function() {
							mostraTabAvaliacaoVersoes();
						}
					}
					
				});
			}

				
			$(document).ready(function() {
				

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

				
				

				mostraRelatoPDF();
				$('#custom-tabs-one-2passo-tab').click(function(){
					$('#tabAnexosDiv').html('')
					$('#tabOrientacoesDiv').html('')
					$('#tabMelhoriasDiv').html('')
					$('#pendenciasDiv').html('')
					mostraRelatoPDF();
				});	
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
					mostraFormAvalOrientacaoCadastro();
					mostraTabOrientacoes();
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

				if(modalidade ==='A' || modalidade ==='E'){
					// DropzoneJS Demo Code Start
					Dropzone.autoDiscover = false

					// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
					var previewNode = document.querySelector("#template")
					//previewNode.id = ""
					var previewTemplate ='';
					if (previewNode !== null) {
						var previewTemplate = previewNode.parentNode.innerHTML
						previewNode.parentNode.removeChild(previewNode)
				
						var myDropzone = new Dropzone("div#custom-tabs-one-2passo", { // Make the whole body a dropzone
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
							previewsContainer: "#previews", // Define the container to display the previews
							clickable: "#avaliacoes", // Define the element that should be used as click trigger to select files.
							headers: { "pc_aval_id":pc_aval_id, 
									"pc_aval_processo":pc_aval_processo, 
									"pc_anexo_avaliacaoPDF":"S",
									"arquivoParaTodosOsItens":"N"},//informar "S" se o arquivo deve ser exibido em todos os itens do processo
							init: function() {
								this.on('error', function(file, errorMessage) {	
									toastr.error(errorMessage);
									return false;
								});
							}
						})
					
						// Update the total progress bar
						myDropzone.on("totaluploadprogress", function(progress) {
							document.querySelector(".progress-bar").style.width = progress + "%"
						})

						myDropzone.on("sending", function(file) {
							$('#modalOverlay').modal('show')
						})



						// Hide the total progress bar when nothing's uploading anymore
						myDropzone.on("queuecomplete", function(progress) {
							//toastr.success("Arquivo(s) enviado(s) com sucesso!")
							myDropzone.removeAllFiles(true);
							mostraRelatoPDF();

							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
						})
					}
					
					// DropzoneJS 1 Demo Code End
				}


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
			


			// function mostraChatValidacaoForm(){
			// 	$('#modalOverlay').modal('show');
			// 	$.ajax({
			// 		type: "POST",
			// 		url:"cfc/pc_cfcAvaliacoes.cfc",
			// 		data:{
			// 			method: "chatValidacaoForm",
			// 			pc_aval_id: pc_aval_id
			// 		},
			// 		async: false
			// 	})//fim ajax
			// 	.done(function(result) {
			// 		$('#divChatValidacaoForm6passo').html(result)
			// 		$('#divChatValidacaoForm7passo').html(result)
					
			// 		$('#modalOverlay').delay(1000).hide(0, function() {
			// 			$('#modalOverlay').modal('hide');
			// 		});	
							
			// 	})//fim done
			// 	.fail(function(xhr, ajaxOptions, thrownError) {
			// 		$('#modalOverlay').delay(1000).hide(0, function() {
			// 			$('#modalOverlay').modal('hide');
			// 		});	
			// 		$('#modal-danger').modal('show')
			// 		$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
			// 		$('#modal-danger').find('.modal-body').text(thrownError)

			// 	})//fim fail

			// }

			function mostraTabAvaliacaoVersoes(){
				$('#modalOverlay').modal('show');
				$.ajax({
					type: "POST",
					url:"cfc/pc_cfcAvaliacoes.cfc",
					data:{
						method: "tabAvaliacaoVersoes",
						pc_aval_id: pc_aval_id
					},
					async: false
				})//fim ajax
				.done(function(result) {
					$('#divTabAvaliacaoVersoes').html(result)
					
					
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

			}

			function enviarMensagem(){
				event.preventDefault()
				event.stopPropagation()

				if ($('#textoNaoValidacao').val().length == 0){
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Insira sua mensagem!');
					return false;
				}
				<cfoutput>
					var pc_aval_id = '#rsProcAval.pc_aval_id#';
					var pc_aval_processo = '#rsProcAval.pc_aval_processo#';
					var pc_validacao_chat_matricula_para = '#rsProcAval.pc_aval_atualiz_login#';
				</cfoutput>

                var pcValidar = 0;
				if($('#pcValidar').val()){
					pcValidar =	$('#pcValidar').val();
				}
			
				if(confirm('Deseja enviar?')){	
					$.ajax({
						type: "POST",
						url:"cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "validarItem",
							pc_aval_id: pc_aval_id,
							pc_aval_processo: pc_aval_processo,
							pc_validacao_chat_matricula_para: pc_validacao_chat_matricula_para,
							pc_validacao_chat_texto: $('#textoNaoValidacao').val(),
							pcValidar:pcValidar  
						},
						async: false
					})//fim ajax
					.done(function(result) {
						exibirTabAvaliacoes()
						//mostraCadastroAvaliacaoRelato(pc_aval_id)		
						$('#CadastroAvaliacaoRelato').html("")
					
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
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
				}
			}

			


			$('#btValidarPasso7').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()

				<cfoutput>
					var pc_aval_id = '#arguments.idAvaliacao#';
					var pc_aval_processo = '#rsModalidadeProcesso.pc_processo_id#';
					var ultimoItemValidado = '#rsAvaliacoesValidadas.recordcount#';
					var quantOrientacoes = '#rsProcessoComOrientacoes.recordcount#';
				</cfoutput>

				var mensagemConfirmacao = "Deseja validar e finalizar o cadastro deste item?"
				if(ultimoItemValidado==1){
					mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado neste processo.\nEste processo será encaminhado para acompanhamento.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados.</p>'
				}
				if(ultimoItemValidado==1 && quantOrientacoes==0){
					mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado e seu processo não possue medidas/orientações para regularização.\nEste processo será FINALIZADO.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados e todas as medidas/orientações para regularização, caso existam, tiverem sido cadastradas.<p>'
				}
				

				swalWithBootstrapButtons.fire({//sweetalert2

					html: logoSNCIsweetalert2(mensagemConfirmacao), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
					if (result.isConfirmed) {
						$('#modalOverlay').modal('show');
						setTimeout(function() {
							//inicio ajax
							$.ajax({
								type: "POST",
								url:"cfc/pc_cfcAvaliacoes.cfc",
								data:{
									method: "validarItem",
									pc_aval_id: pc_aval_id,
									pc_aval_processo: pc_aval_processo,
									pcValidar:1
								},
								async: false
							})//fim ajax
							.done(function(result) {
								mostraCads()
								exibirTabAvaliacoes()
								//mostraCadastroAvaliacaoRelato(pc_aval_id)	
								$('#CadastroAvaliacaoRelato').html("")							
								$('#modalOverlay').delay(1000).hide(0, function() {
									$('#modalOverlay').modal('hide');
									toastr.success('Operação realizada com sucesso!');
								});		
										
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
			})



			function mostraTabAnexos(){
				$('#modalOverlay').modal('show')
				setTimeout(function(){ 
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "tabAnexos",
							pc_aval_id: pc_aval_id
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
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "formAvalOrientacaoCadastro",
							numOrgaoAvaliado: numOrgaoAvaliado

						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#formAvalOrientacaoCadastroDiv').html(result)
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
				}, 1000);
			}

            //@audit trabalhado mostraFormAvalMelhoriaCadastro
			function mostraFormAvalMelhoriaCadastro(){
				
				setTimeout(function(){
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "formAvalMelhoriaCadastro",
							numOrgaoAvaliado: numOrgaoAvaliado,
							modalidade: modalidadeProcesso

						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#formAvalMelhoriaCadastroDiv').html(result)
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

			function mostraTabOrientacoes(){
				$('#modalOverlay').modal('show')
				setTimeout(function(){
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
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
						url: "cfc/pc_cfcAvaliacoes.cfc",
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

			function mostraRelatoPDF(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					//mostraPendencias()
					$.ajax({
						type: "post",
						url:"cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "anexoAvaliacao",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result){
						
						$('#anexoAvaliacaoDiv').html(result)
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

			function salvarTextoAvaliacao()  {
			
				event.preventDefault()
				event.stopPropagation()

				var dataEditor = CKEDITOR.instances.pcSituacaoEncontrada.getData();
				if(dataEditor.length <100){
					toastr.error('Insira um texto com, no mínimo, 100 caracteres.');
					return false;
				}

				$('#modalOverlay').modal('show')
				
				<cfoutput>
					var pc_aval_id = #rsProcAval.pc_aval_id#
				</cfoutput>
				
				
				
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAvaliacoes.cfc",
					data:{
						method: "cadTextoAvaliacao",
						pc_aval_id: pc_aval_id,
						pc_aval_relato: dataEditor 
					},
					async: false
				})//fim ajax
				.done(function(result) {
					//mostraCadastroAvaliacaoRelato(pc_aval_id);	
					//mostraPendencias()
					mostraTabAvaliacaoVersoes()	
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
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

				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});		
			};


		</script>
		
    </cffunction>


	<cffunction name="formAvalOrientacaoCadastro" access="remote" hint="Formulário de cadastro de Orientações">
        <!-- @note finalizado formAvalOrientacaoCadastro -->
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
				$('select').not('[name="tabProcAcompCards_length"], [name="tabAvaliacoes_length"]').select2({
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
								$("<span class='error invalid-feedback' >Selecione, pelo menos, uma opção.</span>").insertAfter($group);
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
							required: "Campo obrigatório."
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
									url: "cfc/pc_cfcAvaliacoes.cfc",
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
									mostraTabOrientacoes();
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



			});

			

		</script>


	</cffunction>

	<cffunction name="formAvalMelhoriaCadastro" access="remote" hint="Formulário de cadastro das Propostas de Melhoria">
		<!-- @audit  trabalhando formAvalMelhoriaCadastro -->
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
																			
									<cfif arguments.modalidade eq "E">
										<div hidden>
											<select id="pcStatusMelhoria"  name="pcStatusMelhoria" class="form-control"  style="height:40px;" >
												<option value="P">PENDENTE</option>
											</select>
										</div>
									<cfelse>
										<div class="col-sm-4">
											<div class="form-group">
												<label  for="pcStatusMelhoria">Status:</label>
												<select id="pcStatusMelhoria"  name="pcStatusMelhoria" class="form-control"  style="height:40px">
													<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
													<option value="P">PENDENTE</option>
													<option value="A">ACEITA</option>
													<option value="R">RECUSA</option>
													<option value="T">TROCA</option>
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
									<div class="col-sm-8">
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
				$('select').not('[name="tabProcAcompCards_length"], [name="tabAvaliacoes_length"]').select2({
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
								$("<span class='error invalid-feedback' >Selecione, pelo menos, uma opção.</span>").insertAfter($group);
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
							required: "Campo obrigatório."
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
							//error.insertAfter(element); // Para outros elementos
							element.closest(".form-group").append(error);
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
										pc_aval_melhoria_status:$('#pcStatusMelhoria').val(),
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

			});


			

			

		</script>
						


	</cffunction>

	


	<cffunction name="verificaPendenciasRelato"   access="remote" hint="retorna se existem pendências no relato da avaliação método  cadastroAvaliacaoRelato, 6° Passo">
		<cfargument name="pc_aval_id" type="numeric" required="true"/>

		<cfset mensagem = ''>

		
		 

		<cfquery datasource="#application.dsn_processos#" name="rsOrientacoes">
			SELECT pc_avaliacao_orientacoes.*,pc_Avaliacoes.pc_aval_status  FROM pc_avaliacao_orientacoes 
			INNER JOIN pc_Avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			where pc_aval_orientacao_num_aval = #arguments.pc_aval_id#
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
			SELECT pc_avaliacao_melhorias.pc_aval_melhoria_num_aval FROM pc_avaliacao_melhorias WHERE pc_aval_melhoria_num_aval = #arguments.pc_aval_id#
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsModalidadeProcesso">
			SELECT pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_num_status, pc_avaliacoes.pc_aval_relato, pc_avaliacoes.pc_aval_classificacao, pc_processos.pc_iniciarBloqueado  FROM pc_processos
			Right JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
			WHERE pc_avaliacoes.pc_aval_id = #arguments.pc_aval_id# 
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsAnexoAvaliacao">
			SELECT pc_anexos.pc_anexo_avaliacao_id FROM pc_anexos 
			WHERE  pc_anexo_avaliacaoPDF = 'S' and (pc_anexo_avaliacao_id = #arguments.pc_aval_id# OR pc_anexo_processo_id = '#rsModalidadeProcesso.pc_processo_id#') 
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsProcessoComOrientacoes">
			SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_id from pc_avaliacao_orientacoes
			LEFT JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			LEFT JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
			WHERE pc_processo_id = '#rsModalidadeProcesso.pc_processo_id#'
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsProcessoComMelhorias">
			SELECT pc_aval_melhoria_id from pc_avaliacao_melhorias
			LEFT JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			LEFT JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
			WHERE pc_processo_id = '#rsModalidadeProcesso.pc_processo_id#'
		</cfquery>



		<cfif #rsModalidadeProcesso.pc_modalidade# eq 'A' OR #rsModalidadeProcesso.pc_modalidade# eq 'E'><!--Se o processo for da modalidade ACOMPANHAMENTO OU ENTREGA DO RELATÓRIO -->
			<cfif #rsAnexoAvaliacao.RecordCount# eq 0>
				<cfset mensagem = mensagem  & '<i class="fas fa-exclamation-triangle" style="color:red"></i> Sem relatório do Item ou do processo. <br>'>
			</cfif>
		<cfelse>
			<cfset quantLetrasRelato = #Len(rsModalidadeProcesso.pc_aval_relato)#>
			<cfif #rsAnexoAvaliacao.RecordCount# eq 0 && #quantLetrasRelato# lt 100>
				<cfset mensagem = mensagem  & '<i class="fas fa-exclamation-triangle" style="color:red"></i> Sem relato da avaliação ou relato com menos de 100 caracteres - (2° Passo - Avaliação)<br>' >
			</cfif>
		</cfif>
		
		<cfif #rsOrientacoes.RecordCount# eq 0 and #rsMelhorias.RecordCount# eq 0 and #rsModalidadeProcesso.pc_aval_classificacao# neq "L">
			<cfset mensagem = mensagem  & '<i class="fas fa-exclamation-triangle" style="color:red"></i> Necessário cadastrar, pelo menos, uma  Orientação e/ou uma Proposta de Melhoria- (4° e 5° Passos)<br>' >
		</cfif>


		<cfif  '#mensagem#' eq ''>
			<cfset mensagem = 'Sem pendências' >
		</cfif>
		
		
		<cfquery datasource="#application.dsn_processos#" name="rsAvaliacoesValidadas">
			SELECT      pc_avaliacoes.pc_aval_status FROM pc_avaliacoes
			WHERE       pc_aval_processo = '#rsModalidadeProcesso.pc_processo_id#' and  pc_aval_status in (1,2,3)
		</cfquery>

		<div class="row">
			<div class="col-md-12">
				<div class="card card-default">
					<div class="card-header" style="background-color:#f8f9fa">
						<h3 class="card-title">Pendências:</h3>
						<br><br>
                     	<cfif  '#mensagem#' eq 'Sem pendências' and (rsOrientacoes.pc_aval_status eq 1 or rsOrientacoes.pc_aval_status eq 3 or rsOrientacoes.recordCount eq 0) and #rsModalidadeProcesso.pc_num_status# neq 4>
							<div class="moveChat" style="display:flex;margin-bottom:30px;align-items: center;" >
								<i class="fas fa-check" style="color:green;font-size:20px"></i><h2 class="card-title" style="color:#00416b; margin-left:10px"><cfoutput>#mensagem#</cfoutput> </h1>
							</div>

							
								
							<cfif #rsModalidadeProcesso.pc_modalidade# eq 'A' OR #rsModalidadeProcesso.pc_modalidade# eq 'E'><!--Se o processo for da modalidade ACOMPANHAMENTO OU ENTREGA DO RELATÓRIO -->
								<div class="col-sm-4 moveChat">
									<cfif #rsAvaliacoesValidadas.recordcount# eq 1 ><!-- Se essa for o último item a ser validado-->
										<cfif rsProcessoComOrientacoes.recordCount neq 0><!--Se o processo tiver, pelo menos, uma orientação-->
										    <cfif rsModalidadeProcesso.pc_iniciarBloqueado eq 'S'><!--Se o processo estiver bloqueado-->
												<button id="btEnviarParaAcompanhamento"  class="btn btn-block statusOrientacoes efeito-grow" style="background-color:green;color:#fff;widht:100px"  >Este é o último item para validação, porém, o processo foi BLOQUEADO.<br>As medidas/orientações para regularização e/ou Propostas de Melhoria não serão encaminhadas para os órgãos reponsáveis e só serão visíveis pelos órgãos do controle interno em Consultas.<br>Clique aqui para manter o bloqueio e concluir o cadastro dos itens.</button>
										    <cfelse>
												<button id="btEnviarParaAcompanhamento"  class="btn btn-block statusOrientacoes efeito-grow" style="background-color:green;color:#fff;widht:100px"  >Este é o último item para validação e existem medidas/orientações para regularização para acompanhamento neste processo.<br>Clique aqui para enviar o Processo para fase de Acompanhamento.</button>
											</cfif>
										<cfelse>
											<cfif rsProcessoComMelhorias.recordCount neq 0><!--Se o processo tiver, pelo menos, uma propostas de melhoria-->
												<button id="btEnviarParaAcompanhamento"  class="btn btn-block statusOrientacoes efeito-grow" style="background-color:green;color:#fff;widht:100px"  >Este é o último item para validação e não existem medidas/orientações para regularização para acompanhamento em nenhum item deste processo.<br> Clique aqui para Finalizar Processo.</button>
											<cfelse>
												<button id="btEnviarParaAcompanhamento"  class="btn btn-block statusOrientacoes efeito-grow" style="background-color:green;color:#fff;widht:100px"  >Este é o último item para validação e não existem medidas/orientações para regularização para acompanhamento ou propostas de melhoria em nenhum item deste processo.<br> Clique aqui para Finalizar Processo.</button>
											</cfif>
										</cfif>
									<cfelse>
										<button id="btValidar"  class="btn btn-block statusOrientacoes efeito-grow" style="background-color:green;color:#fff;widht:100px"  >Validar e Finalizar o Cadastro deste item</button>
									</cfif>
								</div>
							<cfelse>

								<div  class="col-sm-12" style="display:flex">
										<div  class="col-sm-6">
											<div id="divChatValidacaoForm6passo" ></div>
										</div>
										<div  class="col-sm-6 moveChat">
											<div  ></div>
										</div>
									</div>
							</cfif>
								
							
							
						<cfelse>
						    <cfif  '#mensagem#' eq 'Sem pendências'>
								<div style="display:flex;margin-bottom:30px;align-items: center;" >
									<i class="fas fa-check" style="color:green;font-size:20px"></i><h2 class="card-title" style="color:#00416b; margin-left:10px"><cfoutput>#mensagem#</cfoutput> </h1>
								</div>
							<cfelse>
								<div style="display:flex; font-size:14px">
									<h4 class="card-title" style="color:red; margin-left:10px"><cfoutput>#mensagem#</cfoutput> </h4>
								</div>

							</cfif>
						</cfif>
					</div>
				</div>
			</div>
		</div>

		<script language="JavaScript">
			

			$(document).ready(function(){
				<cfoutput>
					var modalidadeDoProcesso = '#rsModalidadeProcesso.pc_modalidade#';
					var pc_aval_status = '#rsOrientacoes.pc_aval_status#'
				</cfoutput>

				if(modalidadeDoProcesso == 'N' &&  (pc_aval_status == 1 || pc_aval_status == 3)){
					mostraChatValidacaoForm()
					$('#chatFooter').show(500);
				}
		    });

			//início move scroll do chat para o final
            // $('#divChatValidacaoForm6passo').mouseleave(function() {
			// 		$('#chatMemsagens').animate({scrollTop: $('#chatMemsagens')[0].scrollHeight}, 1000);
			// });

			// $('.moveChat').mouseover(function() {
			// 		$('#chatMemsagens').animate({scrollTop: $('#chatMemsagens')[0].scrollHeight}, 1000);
			// });
			//fim move scroll do chat para o final


			$('#btValidar').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()

				<cfoutput>
					var pc_aval_id = '#arguments.pc_aval_id#'
					var pc_aval_processo = '#rsModalidadeProcesso.pc_processo_id#'
					var ultimoItemValidado = '#rsAvaliacoesValidadas.recordcount#'
					var quantOrientacoes = '#rsProcessoComOrientacoes.recordcount#'
				</cfoutput>

				var mensagemConfirmacao = "Deseja validar e finalizar o cadastro deste item?"
				if(ultimoItemValidado==1){
					mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado neste processo.\nEste processo será encaminhado para acompanhamento.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados.</p>'
				}
				if(ultimoItemValidado==1 && quantOrientacoes==0){
					mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado e seu processo não possue medidas/orientações para regularização.\nEste processo será FINALIZADO.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados e todas as medidas/orientações para regularização, caso existam, tiverem sido cadastradas.<p>'
				}
				

				swalWithBootstrapButtons.fire({//sweetalert2

					html: logoSNCIsweetalert2(mensagemConfirmacao), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
					if (result.isConfirmed) {
						$('#modalOverlay').modal('show');
						setTimeout(function() {
							//inicio ajax
							$.ajax({
								type: "POST",
								url:"cfc/pc_cfcAvaliacoes.cfc",
								data:{
									method: "validarItem",
									pc_aval_id: pc_aval_id,
									pc_aval_processo: pc_aval_processo,
									pcValidar:1
								},
								async: false
							})//fim ajax
							.done(function(result) {
								mostraCads()
								exibirTabAvaliacoes()
								//mostraCadastroAvaliacaoRelato(pc_aval_id)	
								$('#CadastroAvaliacaoRelato').html("")
															
								$('#modalOverlay').delay(1000).hide(0, function() {
									$('#modalOverlay').modal('hide');
									toastr.success('Operação realizada com sucesso!');
								});		
										
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
						}, 1000);
					} 
				})

			})

		
			$('#btEnviarParaAcompanhamento').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()

				<cfoutput>
					var pc_aval_id = '#arguments.pc_aval_id#';
					var pc_aval_processo = '#rsModalidadeProcesso.pc_processo_id#';
					var ultimoItemValidado = '#rsAvaliacoesValidadas.recordcount#';
					var quantOrientacoes = '#rsProcessoComOrientacoes.recordcount#';
					var processoBloqueado = '#rsModalidadeProcesso.pc_iniciarBloqueado#';
					var quantMelhorias = '#rsProcessoComMelhorias.recordcount#';
				</cfoutput>

				var mensagemConfirmacao = "Deseja validar e finalizar o cadastro deste item?"
				if(ultimoItemValidado==1){
					if(processoBloqueado=='S'){
						mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado, porém, o processo foi <strong style="color:red">BLOQUEADO</strong>.\nAs medidas/orientações para regularização e/ou Propostas de Melhoria não serão encaminhadas para os órgãos reponsáveis e só serão visíveis pelos órgãos do controle interno em Consultas.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados.</p>'
					}else{
						mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado neste processo.\nEste processo será encaminhado para acompanhamento.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados.</p>'
					}
				}
				if(ultimoItemValidado==1 && quantOrientacoes==0){
					if(quantMelhorias==0){
						mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado e seu processo não possue medidas/orientações para regularização ou Propostas de Melhoria.\nEste processo será FINALIZADO.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados.<p>'
					}else{
                        mensagemConfirmacao = '<p>Deseja validar e finalizar o cadastro deste item?</p><p>Este é o último item a ser validado e seu processo não possue medidas/orientações para regularização.\nEste processo será FINALIZADO.</p><p>Só clique em "Sim!" se todos os itens deste processo estiverem cadastrados e todas as propostas de melhoria tiverem sido cadastradas.<p>'
					}
				}
				
				swalWithBootstrapButtons.fire({//sweetalert2

					html: logoSNCIsweetalert2(mensagemConfirmacao), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
					if (result.isConfirmed) {
						$('#modalOverlay').modal('show');
						setTimeout(function() {
							//inicio ajax
							$.ajax({
								type: "POST",
								url:"cfc/pc_cfcAvaliacoes.cfc",
								data:{
									method: "validarItem",
									pc_aval_id: pc_aval_id,
									pc_aval_processo: pc_aval_processo,
									pcValidar:1
								},
								async: false
							})//fim ajax
							.done(function(result) {
								mostraCads()
								$('#cadAvaliacaoForm').html("");
								$('#TabAvaliacao').html("")
								$('#CadastroAvaliacaoRelato').html("")	
								
								$('#modalOverlay').delay(1000).hide(0, function() {
									$('#modalOverlay').modal('hide');
									toastr.success('Operação realizada com sucesso!');
								});		
										
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
						}, 1000);
					} 
				})

			})

			


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
											<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>
												<th style="width: 10%;vertical-align:middle !important;">Controles</th>
											</cfif>
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
													<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>
														<td style="text-align: center; vertical-align:middle !important;width:10%">	
															<div style="display:flex;justify-content:space-around;">
																<i id="btExcluirMelhoria" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px"   onClick="javascript:excluirMelhoria(#pc_aval_melhoria_id#)" title="Excluir" ></i>
																<i id="btEditarMelhoria" class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:5px" onClick="javascript:editarMelhoria(this);"   title="Editar" ></i>
															</div>
														</td>													
													</cfif>
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
							$("<span class='error invalid-feedback' >Selecione, pelo menos, uma opção.</span>").insertAfter($group);
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
				
				$('#labelMelhoria').html('Editar Proposta de Melhoria:')

				<cfoutput> var modalidade = '#rsStatus.pc_modalidade#'; </cfoutput>
				
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
				
				var pc_aval_melhoria_naoAceita_justif = $(linha).closest("tr").children("td:nth-child(11)").text();
				var pc_aval_melhoria_sugestao = $(linha).closest("tr").children("td:nth-child(12)").text();


                if(modalidade != 'E'){
					var pc_aval_melhoria_categoriaControle_id = $(linha).closest("tr").children("td:nth-child(13)").text();
					var pc_aval_melhoria_beneficioNaoFinanceiro = $(linha).closest("tr").children("td:nth-child(14)").text();
					var pc_aval_melhoria_beneficioFinanceiro = $(linha).closest("tr").children("td:nth-child(15)").text();
					var pc_aval_melhoria_custoFinanceiro = $(linha).closest("tr").children("td:nth-child(16)").text();
				}else{
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
				validateButtonGroupsMelhoria();	

				$('#cabecalhoAccordionCadMelhoria').text("Editar Proposta de Melhoria ID:" + ' ' + pc_aval_melhoria_id);
				$('#infoTipoCadMelhoria').text("Editando Proposta de Melhoria ID:" + ' ' + pc_aval_melhoria_id);
		        $('#cadMelhoria').CardWidget('expand')
				$('html, body').animate({ scrollTop: ($('#cadMelhoria').offset().top - 80)} , 500); 

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
									<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>
										<th>Controles</th>
									</cfif>
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

										<tr style="font-size:12px;color:##000" onClick="<cfif #rsOrientacoes.pc_num_status# eq 4>javascript:mostraTimeline(#pc_aval_orientacao_id#) </cfif>">
											<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>
												<td style="text-align: center; vertical-align:middle !important;width:10%">	
													<div style="display:flex;justify-content:space-around;">
														<i id="btExcluirOrientacao" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px"   onClick="javascript:excluirOrientacao(#pc_aval_orientacao_id#)" title="Excluir" ></i>
														<i id="btEditarOrientacao" class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:5px" onClick="javascript:editarOrientacao(this);"   title="Editar" ></i>
													</div>
												</td>													
											</cfif>
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
							$("<span class='error invalid-feedback' >Selecione, pelo menos, uma opção.</span>").insertAfter($group);
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
				$('#labelOrientacao').html('Editar Medida/Orientação para Regularização:')
				
				$(linha).closest("tr").children("td:nth-child(5)").click();//seleciona a linha onde o botão foi clicado	
				var pc_aval_orientacao_id = $(linha).closest("tr").children("td:nth-child(2)").text();
				var pc_aval_orientacao_mcu_orgaoResp = $(linha).closest("tr").children("td:nth-child(3)").text();
				var pc_aval_orientacao_categoriaControle_id = $(linha).closest("tr").children("td:nth-child(4)").text();
				var pc_aval_orientacao_beneficioNaoFinanceiro = $(linha).closest("tr").children("td:nth-child(5)").text();
				var pc_aval_orientacao_beneficioFinanceiro = $(linha).closest("tr").children("td:nth-child(6)").text();
				var pc_aval_orientacao_custoFinanceiro = $(linha).closest("tr").children("td:nth-child(7)").text();
				var pc_aval_orientacao_descricao = $(linha).closest("tr").children("td:nth-child(8)").text();

	

	
				$('#pcOrientacaoId').val(pc_aval_orientacao_id);
				$('#pcOrientacao').val(pc_aval_orientacao_descricao);
				$('#pcOrgaoRespOrientacao').val(pc_aval_orientacao_mcu_orgaoResp).trigger('change');
				// Divide a string em um array
				var valoresArray = pc_aval_orientacao_categoriaControle_id.split(',');
				// Atribue o array ao select e acione o evento 'change'
				$('#pcAvalOrientacaoCategoriaControle').val(valoresArray).trigger('change');
				
				$('#pcAvalOrientacaoBenefNaoFinanceiroDesc').val(pc_aval_orientacao_beneficioNaoFinanceiro).trigger('change');
				$('#pcValorBeneficioFinanceiro').val(formatCurrency(pc_aval_orientacao_beneficioFinanceiro)).trigger('change');
				$('#pcValorCustoFinanceiro').val(formatCurrency(pc_aval_orientacao_custoFinanceiro)).trigger('change');

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
				validateButtonGroupsOrientacao();		


				$('#cabecalhoAccordionCadOrientacao').text("Editar Medida/Orientação para Regularização ID:" + ' ' + pc_aval_orientacao_id);
				$('#infoTipoCadOrientacao').text("Editando Medida/Orientação para Regularização ID:" + ' ' + pc_aval_orientacao_id);
		        $('#cadOrientacao').CardWidget('expand')
				$('html, body').animate({ scrollTop: ($('#cadOrientacao').offset().top - 80)} , 500); 
			};	

			function excluirOrientacao(pc_aval_orientacao_id)  {
				event.preventDefault()
		        event.stopPropagation()
				var dataEditor = $('.editor').html();


					var mensagem = "Deseja excluir esta Medida/Orientação?"
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
										method: "delOrientacoes",
										pc_aval_orientacao_id: pc_aval_orientacao_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
										
									mostraTabOrientacoes();
									toastr.success('Operação realizada com sucesso!');
									mostraFormAvalOrientacaoCadastro();
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
						}
					})

			};

			function mostraTimeline(pc_aval_orientacao_id){

				event.preventDefault()
				event.stopPropagation()

				var funcCFC ='timelineViewAcompOrgaoAvaliado';
				<cfif '#application.rsUsuarioParametros.pc_org_controle_interno#' eq 'S' >
					funcCFC ='timelineViewAcomp';
				</cfif>

				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method:funcCFC,
							pc_aval_orientacao_id: pc_aval_orientacao_id
						},
						async: false,
						success: function(response) {
							
							$('#timelineViewAcompDiv').html(response);
							
							mostraTabAnexosOrientacoes();
							$('html, body').animate({ scrollTop: ($('#mostraInfoAvalDiv').offset().top - 80)} , 1000);
							
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
				}, 1000);
				
						
			}

			

		</script>				
			
			
	

	</cffunction>


	






	
	<cffunction name="cadTextoAvaliacao"   access="remote"  returntype="any" hint="cadastra o texto da avaliação">
		
		<cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_relato" type="string" required="true"/>
		<cftransaction>
			<cfquery datasource="#application.dsn_processos#" >
					UPDATE pc_avaliacoes
					SET pc_aval_relato = <cfqueryparam value="#arguments.pc_aval_relato#" cfsqltype="cf_sql_varchar">
					WHERE pc_aval_id = <cfqueryparam value="#arguments.pc_aval_id#" cfsqltype="cf_sql_numeric">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" >
					INSERT pc_avaliacao_versoes(pc_aval_versao_num_aval, pc_aval_versao_texto, pc_aval_versao_num_matricula)
					VALUES (<cfqueryparam value="#arguments.pc_aval_id#"     cfsqltype="cf_sql_numeric">,
							<cfqueryparam value="#arguments.pc_aval_relato#" cfsqltype="cf_sql_varchar">,
							<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">)
			</cfquery>
		</cftransaction>
		
  	</cffunction>







	<cffunction name="tabAvaliacaoVersoes"   access="remote"  returntype="any" hint="mostra versões das avaliações na página avaliações no 2° Passo">
	    <cfargument name="pc_aval_id" type="numeric" required="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsAvaliacaoVersoes">
			SELECT  pc_aval_versao_id, pc_aval_versao_num_aval, pc_aval_versao_num_matricula, pc_aval_versao_DataHora FROM pc_avaliacao_versoes
			WHERE pc_aval_versao_num_aval = <cfqueryparam value="#arguments.pc_aval_id#" cfsqltype="cf_sql_numeric">
			ORDER by pc_aval_versao_id desc
		</cfquery>
		<style>
			.dataTables_scrollBody{
				overflow-x: hidden!important;
			}
		</style>

		<cfif rsAvaliacaoVersoes.recordcount neq 0>
			
			<div style="width:60vh;margin-bottom:40px">
				<h6 style="margin-bottom: 0px!important;">Versões</h6>
				<table  id="tabVersoes" class="table table-bordered table-striped table-hover text-nowrap" >
					<thead style="background: #0083ca;color:#fff;text-align:center;">
						<tr style="font-size:0.9em;"  >
							<th >Data/Hora</th>
							<th>Matrícula</th>
						</tr>
					</thead>
					
					<tbody >
						<cfloop query="rsAvaliacaoVersoes" >
							<cfset dataHoraVersao = DateFormat(#pc_aval_versao_DataHora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_aval_versao_DataHora#,'HH:mm:ss') & ')'>
							<cfoutput>					
								<tr style="font-size:0.8em;cursor:pointer" onclick="javascript:mostraVersao(<cfoutput>#pc_aval_versao_id#,#pc_aval_versao_num_aval#</cfoutput>)">
									<td style="padding:3px;">#dataHoraVersao#</td>
									<td style="padding:3px;">#pc_aval_versao_num_matricula#</td>	
								</tr>
							</cfoutput>
						</cfloop>	
					</tbody>
				</table>
			</div>			
						

			<div id="divVisualizarVersao"></div>
				

		
		<cfelse>
			<h5>Nenhuma versão adicionada.</h5>
		</cfif>

			<script language="JavaScript">
				$(function () {
					$("#tabVersoes").DataTable({
						destroy: true,
						scrollX: false,
						scrollY: '10vh',
						scrollCollapse: true,
						stateSave: false,
						responsive: true, 
						lengthChange: false, 
						autoWidth: true,
						searching:false,
						select: true,
						paging: false,
						info: false,
						order: [[ 0, "desc" ]],
						columnDefs: [
							{
								targets:[0,1],
								className:'dt-body-center'
							}
						],
					});		
				});

				function mostraVersao(idVersao,idAvaliacao){
					
					$('#modalOverlay').modal('show')
					//$('#divVisualizarVersao').html('')
					$.ajax({
							type: "post",
							url: "cfc/pc_cfcAvaliacoes.cfc",
							data:{
								method: "visualizarTextoVersao",
								pc_aval_versao_id: idVersao,
								pc_aval_versao_num_aval: idAvaliacao
							},
							async: false
						})//fim ajax
						.done(function(result) {
							$('#divVisualizarVersao').html(result)
							//$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
								
							});		
							$('html, body').animate({ scrollTop: ($('#divVisualizarVersao').offset().top-80)} , 1000);
										
						})//fim done
						.fail(function(xhr, ajaxOptions, thrownError) {
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)

						})//fim fail
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});

				}

			</script>

	</cffunction>








	<cffunction name="visualizarTextoVersao"   access="remote"  returntype="any" hint="mostra o texto das versões das avaliações na página avaliações no 2° Passo">
	    <cfargument name="pc_aval_versao_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_versao_num_aval" type="numeric" required="true"/>



		<cfquery datasource="#application.dsn_processos#" name="rsVisualizaAvaliacaoVersoes">
			SELECT pc_avaliacao_versoes.* FROM pc_avaliacao_versoes
			WHERE pc_aval_versao_id = <cfqueryparam value="#arguments.pc_aval_versao_id#" cfsqltype="cf_sql_numeric">
			and pc_aval_versao_num_aval = <cfqueryparam value="#arguments.pc_aval_versao_num_aval#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfquery name="rsUsuarioVersao" datasource="#application.dsn_processos#">
			SELECT pc_usu_matricula, pc_usu_nome FROM pc_usuarios 
			WHERE pc_usu_matricula = '#rsVisualizaAvaliacaoVersoes.pc_aval_versao_num_matricula#'
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsUltimaVersao">
			SELECT MAX(pc_aval_versao_id) as ultimaVersao FROM pc_avaliacao_versoes
			WHERE pc_aval_versao_num_aval = <cfqueryparam value="#arguments.pc_aval_versao_num_aval#" cfsqltype="cf_sql_numeric">
		</cfquery>

		
		<div class="container" >
		    <cfset dataHoraVersao = DateFormat(#rsVisualizaAvaliacaoVersoes.pc_aval_versao_dataHora#,'DD-MM-YYYY') & ' (' & TimeFormat(#rsVisualizaAvaliacaoVersoes.pc_aval_versao_dataHora#,'HH:mm:ss') & ')'>				
			<div style="font-size:10px;color:#e83e8c;position:relative; top:27px">
				<cfoutput>versão data/hora: <strong>#dataHoraVersao#</strong> - por: <strong>#rsUsuarioVersao.pc_usu_nome#</strong></cfoutput>
				<cfif #rsUltimaVersao.ultimaVersao# neq #arguments.pc_aval_versao_id#>
					<i id="btAbrirAnexo" class="fas fa-file-arrow-up efeito-grow" title="Salvar como última versão."  style="cursor: pointer;z-index:100;font-size:18px;margin-left:30px" onClick="<cfoutput>javascript:salvarComoVersaoPrincipal(#arguments.pc_aval_versao_num_aval#)</cfoutput>"   title="Excluir" ></i>
				<cfelse>
					<span> - <strong>Última Versão</strong></span>
				</cfif>
			</div>
																
			<textarea  id="visualizarVersao" name="visualizarVersao"><cfoutput>#rsVisualizaAvaliacaoVersoes.pc_aval_versao_texto#</cfoutput></textarea>							
		</div>
			
			
		</div>
		<script language="JavaScript">
			CKEDITOR.replace( 'visualizarVersao', {
				width: '100%',
				height: 700,
				readOnly: true,
				toolbar: [{ name: 'document', items: [ 'Preview'] }]
			});

			function salvarComoVersaoPrincipal(pc_aval_id)  {
			
				event.preventDefault()
				event.stopPropagation()

				var dataEditor = CKEDITOR.instances.visualizarVersao.getData();
				
			
				
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAvaliacoes.cfc",
					data:{
						method: "cadTextoAvaliacao",
						pc_aval_id: pc_aval_id,
						pc_aval_relato: dataEditor 
					},
					async: false
				})//fim ajax
				.done(function(result) {
					mostraCadastroAvaliacaoRelato(pc_aval_id)
					//mostraTabAvaliacaoVersoes()	
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
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

				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
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




	



    
    <cffunction name="renderFileSize" access="public" output="false" hint="transforma a forma de apresentação do tamanho dos anexos">
		<cfargument name="size" type="numeric" required="true" hint="File size to be rendered" />
		<cfargument name="type" type="string" required="true" default="bytes" />
		
		<cfscript>
			local.newsize = ARGUMENTS.size;
			local.filetype = ARGUMENTS.type;
			do{
				local.newsize = (local.newsize / 1024);
				if(local.filetype IS 'bytes')local.filetype = 'KB';
				else if(local.filetype IS 'KB')local.filetype = 'MB';
				else if(local.filetype IS 'MB')local.filetype = 'GB';
				else if(local.filetype IS 'GB')local.filetype = 'TB';
			}while((local.newsize GT 1024) AND (local.filetype IS NOT 'TB'));
			local.filesize = REMatchNoCase('[(0-9)]{0,}(\.[(0-9)]{0,2})',local.newsize);
			if(arrayLen(local.filesize))return local.filesize[1] & ' ' & local.filetype;
			else return local.newsize & ' ' & local.filetype;
			return local;
		</cfscript>
	</cffunction>

	








   
	<cffunction name="tabAnexos" returntype="any" access="remote" hint="Criar a tabela dos anexos e envia para a páginas pc_CadastroRelato">

	    <cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_orientacao_id" type="string" required="false" default=""/>
		<cfargument name="passoapasso" type="string" required="false" default="true"/>

        <cfquery datasource="#application.dsn_processos#" name="rsAnexos">
			Select pc_anexos.*, pc_orgaos.*, pc_usu_nome  FROM pc_anexos 
			Left JOIN pc_orgaos on pc_org_mcu = pc_anexo_mcu_orgao
			LEFT JOIN pc_usuarios ON pc_usu_matricula = RIGHT(pc_anexo_login,8)
			WHERE pc_anexo_avaliacaoPDF ='N' and pc_anexo_enviado=1
			<cfif #arguments.pc_orientacao_id# eq "">
				AND pc_anexo_avaliacao_id = #arguments.pc_aval_id# 
			<cfelse>
				AND ((pc_anexo_avaliacao_id = #arguments.pc_aval_id# and pc_anexo_orientacao_id = null)
				OR (pc_anexo_orientacao_id = #arguments.pc_orientacao_id#) )
			</cfif>

			<cfif #arguments.passoapasso# eq "false">
               and CONVERT(char, pc_anexo_datahora , 103) = CONVERT(char, GETDATE() , 103) and pc_anexo_mcu_orgao = #application.rsUsuarioParametros.pc_usu_lotacao# 
			</cfif>
			order By pc_anexo_id desc
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
			<cfif directoryExists(application.diretorio_anexos)>
				<cfif rsAnexos.recordcount neq 0>
					<div class="row">
						<div class="col-12">
							<div class="card">
							
								<!-- /.card-header -->
								<div class="card-body">
									<cfif #arguments.passoapasso# eq "false">
										<h6>Arquivos anexados hoje por <cfoutput>#application.rsUsuarioParametros.pc_usu_nome#</cfoutput></h6>
									</cfif>								
									<table id="tabAnexos" class="table table-bordered table-striped table-hover text-nowrap">
										<thead style="background: #0083ca;color:#fff">
											<tr style="font-size:14px">
												<th>Controles:</th>
												<th style="width:5%">ID:</th>
												<th style="width:25%">Arquivo: </th>
												<th>Anexado por: </th>
												<th style="width:10px">Data: </th>
											</tr>
										</thead>
										
										<tbody>
											<cfloop query="rsAnexos" >
												<cfif FileExists(pc_anexo_caminho)>
													<cfoutput>					
														<cfset arquivo = ListLast(pc_anexo_caminho,'\')>
														<tr style="font-size:12px" >
															<td style="width:10%">	
																<div style="display:flex;justify-content:space-around;">
																	
																	<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3  or (#arguments.passoapasso# eq "false"	 and datediff("n",  #pc_anexo_datahora#,now()) lt 5) and #application.rsUsuarioParametros.pc_usu_lotacao# eq #pc_org_mcu#>
																		<i id="btExcluir" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:18px" onclick="javascript:excluirAnexo(#pc_anexo_id#);"   title="Excluir" ></i>
																	</cfif>
																
																	<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
																		<i id="btAbrirAnexo" class="fas fa-eye efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_blank')"   title="Visualizar" ></i>
																	<cfelse>
																		<i id="btAbrirAnexo" class="fas fa-download efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_self')"   title="Baixar" ></i>
																	</cfif>
																
																</div>
															</td>
															<td class="idColumn">#pc_anexo_id#</td>

															<cfset data = DateFormat(#pc_anexo_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_anexo_datahora#,'HH:mm:ss') & ')'>
																<td >
																<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
																	<i class="fas fa-file-pdf " style="margin-right:10px;color:red;font-size:20px"></i>
																<cfelseif right(#pc_anexo_caminho#,3) eq 'zip'>
																	<i class="fas  fa-file-zipper" style="margin-right:10px;color:blue;font-size:20px"></i>
																<cfelse>
																	<i class="fas fa-file-excel" style="margin-right:10px;color:green;font-size:20px"></i>
																</cfif>												
																#pc_anexo_nome#
															</td>
															<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
																<td >#pc_org_sigla#</td>
															<cfelse>
																<cfif #pc_org_controle_interno# eq 'S'>
																	<td >Controle Interno</td> 
																<cfelse>
																	<td >#pc_org_sigla#/#pc_usu_nome#</td>
																</cfif>
															</cfif>
															<td  style="width:100px">#data#</td>
														</tr>
													</cfoutput>
												</cfif>
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
					<cfelse>
						<h5>Nenhum anexo foi adicionado.</h5>
					</cfif>
				<cfelse>
					<h5 style="color:red">Servidor de arquivos não localizado.</h5>
				</cfif>


		<script >
			$(function () {
				$("#tabAnexos").DataTable({
					destroy: true,
			    	stateSave: false,
					responsive: true, 
					lengthChange: false, 
					autoWidth: false,
					searching: false
				})
					
			});

			function abrirAnexo(pc_anexo_caminho)  {
				event.preventDefault()
		        event.stopPropagation()
				return false
				window.location.href = "pc_Anexos.cfm?arquivo=" + pc_anexo_caminho;
			}

			function excluirAnexo(pc_anexo_id)  {
				<cfoutput>
					var passoapasso = #arguments.passoapasso#;
				</cfoutput>
				event.preventDefault()
		        event.stopPropagation()
				
			
				let mensagem = "Deseja excluir este anexo?";
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							var dataEditor = $('.editor').html();
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAvaliacoes.cfc",
									data:{
										method: "delAnexos",
										pc_anexo_id: pc_anexo_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
									mostraTabAnexos();
									if (passoapasso == false){
										mostraTabAnexosOrientacoes()
									}
									
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide')
										toastr.success('Operação realizada com sucesso!')
									});	
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
									})
								})//fim fail
							}, 500);
						}
					});
					
						
			};

			

		</script>				
			
			
	</cffunction>






	<cffunction name="tabAnexosOrientacoes" returntype="any" access="remote" hint="Criar a tabela dos anexos e envia para a página Acompanhamento">

	    
		<cfargument name="pc_orientacao_id" type="string" required="false" default=null/>
	

        <cfquery datasource="#application.dsn_processos#" name="rsAnexosEnviados">
			Select pc_anexos.*, pc_orgaos.*, pc_usu_nome FROM pc_anexos 
			Left JOIN pc_orgaos on pc_org_mcu = pc_anexo_mcu_orgao
			LEFT JOIN pc_usuarios ON pc_usu_matricula = RIGHT(pc_anexo_login,8)
			WHERE pc_anexo_orientacao_id = #arguments.pc_orientacao_id# and pc_anexo_avaliacaoPDF ='N' and pc_anexo_enviado=1
                   and CONVERT(char, pc_anexo_datahora , 103) = CONVERT(char, GETDATE() , 103) and pc_anexo_mcu_orgao = #application.rsUsuarioParametros.pc_usu_lotacao#
			order By pc_anexo_id desc
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsAnexosNaoEnviados">
			Select pc_anexos.*, pc_orgaos.*, pc_usu_nome FROM pc_anexos 
			Left JOIN pc_orgaos on pc_org_mcu = pc_anexo_mcu_orgao
			LEFT JOIN pc_usuarios ON pc_usu_matricula = RIGHT(pc_anexo_login,8)
			WHERE pc_anexo_orientacao_id = #arguments.pc_orientacao_id# and pc_anexo_avaliacaoPDF ='N' and pc_anexo_enviado=0
			order By pc_anexo_id desc
		</cfquery>

		<cfif rsAnexosEnviados.recordcount neq 0>
			<div class="row">
				<div class="col-12">
					<div class="card">
					
						<!-- /.card-header -->
						<div class="card-body">
							
							<h6>Arquivos anexados hoje por <cfoutput>#application.rsUsuarioParametros.pc_usu_nome#</cfoutput></h6>
							
							<table id="tabAnexos" class="table table-bordered table-striped table-hover text-nowrap">
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:14px">
										<th>Controles:</th>
										<th>ID:</th>
										<th style="width:25%">Arquivo: </th>
										<th>Anexado por: </th>
										<th style="width:10px">Data: </th>
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsAnexosEnviados" >
										<cfif FileExists(pc_anexo_caminho)>
											<cfoutput>					
												<cfset arquivo = ListLast(pc_anexo_caminho,'\')>
												<tr style="font-size:12px" >
													<td style="width:10%">	
														<div style="display:flex;justify-content:space-around;">
															
															<cfif datediff("n",  #pc_anexo_datahora#,now()) lt 5 and #application.rsUsuarioParametros.pc_usu_lotacao# eq #pc_org_mcu#>
																<i id="btExcluir" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:18px" onclick="javascript:excluirAnexo(#pc_anexo_id#);"   title="Excluir" ></i>
															</cfif>
														
															<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
																<i id="btAbrirAnexo" class="fas fa-eye efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_blank')"   title="Visualizar" ></i>
															<cfelse>
																<i id="btAbrirAnexo" class="fas fa-download efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_self')"   title="Baixar" ></i>
															</cfif>
														
														</div>
													</td>
													<td class="idColumn">#pc_anexo_id#</td>

													<cfset data = DateFormat(#pc_anexo_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_anexo_datahora#,'HH:mm:ss') & ')'>
														<td >
														<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
															<i class="fas fa-file-pdf " style="margin-right:10px;color:red;font-size:20px"></i>
														<cfelseif right(#pc_anexo_caminho#,3) eq 'zip'>
															<i class="fas  fa-file-zipper" style="margin-right:10px;color:blue;font-size:20px"></i>
														<cfelse>
															<i class="fas fa-file-excel" style="margin-right:10px;color:green;font-size:20px"></i>
														</cfif>												
														#pc_anexo_nome#
													</td>
													<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
														<td >#pc_org_sigla#</td>
													<cfelse>
														<cfif #pc_org_controle_interno# eq 'S'>
															<td >Controle Interno</td> 
														<cfelse>
															<td >#pc_org_sigla#/#pc_usu_nome#</td>
														</cfif>
													</cfif>
													<td  style="width:100px">#data#</td>
												</tr>
											</cfoutput>
										</cfif>
											
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
		</cfif>

		<cfif rsAnexosNaoEnviados.recordcount neq 0>
			<div class="row">
				<div class="col-12">
					<div class="card">
					
						<!-- /.card-header -->
						<div class="card-body">
							
							<h6>Arquivo(s) anexado(s) e ainda não enviado(s):</h6>
							
							<table id="tabAnexosNaoEnviados" class="table table-bordered table-striped table-hover text-nowrap">
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:14px">
										<th>Controles:</th>
										<th>ID:</th>
										<th style="width:25%">Arquivo: </th>
										<th>Anexado por: </th>
										<th style="width:10px">Data: </th>
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsAnexosNaoEnviados" >
										<cfif FileExists(pc_anexo_caminho)>
											<cfoutput>					
												<cfset arquivo = ListLast(pc_anexo_caminho,'\')>
												<tr >
													<td style="width:10%">	
														<div style="display:flex;justify-content:space-around;">

															<i id="btExcluir" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:18px" onclick="javascript:excluirAnexo(#pc_anexo_id#);"   title="Excluir" ></i>

															<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
																<i id="btAbrirAnexo" class="fas fa-eye efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_blank')"   title="Visualizar" ></i>
															<cfelse>
																<i id="btAbrirAnexo" class="fas fa-download efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_self')"   title="Baixar" ></i>
															</cfif>
														
														</div>
													</td>
													<td class="idColumn">#pc_anexo_id#</td>

													<cfset data = DateFormat(#pc_anexo_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_anexo_datahora#,'HH:mm:ss') & ')'>
													<td >
														<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
															<i class="fas fa-file-pdf " style="margin-right:10px;color:red;font-size:20px"></i>
														<cfelseif right(#pc_anexo_caminho#,3) eq 'zip'>
															<i class="fas  fa-file-zipper" style="margin-right:10px;color:blue;font-size:20px"></i>
														<cfelse>
															<i class="fas fa-file-excel" style="margin-right:10px;color:green;font-size:20px"></i>
														</cfif>												
															#pc_anexo_nome#
													</td>
													
													<td >#pc_org_sigla# (#pc_usu_nome#)</td>
														
													
													<td  style="width:100px">#data#</td>
												</tr>
											</cfoutput>
										</cfif>
											
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
		
		</cfif>


		<script >
			$(function () {
				$("#tabAnexos").DataTable({
					destroy: true,
			    	stateSave: false,
					responsive: true, 
					lengthChange: false, 
					autoWidth: false,
					searching: false
				})

				$("#tabAnexosNaoEnviados").DataTable({
					destroy: true,
			    	stateSave: false,
					responsive: true, 
					lengthChange: false, 
					autoWidth: false,
					searching: false,
					paging: false // Desativa a paginação
				})
					
			});

			function abrirAnexo(pc_anexo_caminho)  {
				event.preventDefault()
		        event.stopPropagation()
				return false
				window.location.href = "pc_Anexos.cfm?arquivo=" + pc_anexo_caminho;
			}

			function excluirAnexo(pc_anexo_id)  {
				event.preventDefault()
		        event.stopPropagation()
				
				let mensagem = "Deseja excluir este anexo?";
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							//var dataEditor = $('.editor').html();
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAvaliacoes.cfc",
									data:{
										method: "delAnexos",
										pc_anexo_id: pc_anexo_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
									mostraTabAnexos();
									mostraTabAnexosOrientacoes()
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide')
										toastr.success('Operação realizada com sucesso!')
									});	
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
									})
								})//fim fail
							}, 1000);//fim setTimeout
						}
					});
					
						
			};

			

		</script>				
			
			
	</cffunction>




	

   
	<cffunction name="anexoAvaliacao"   access="remote" hint="retorna os anexos que contem 'S' no campo pc_anexo_avaliacao indicando que é a avaliação e  não um anexo comum">
		<cfargument name="pc_aval_id" type="numeric" required="true" returntype="any"/>
		<cfargument name="todosOsRelatorios" type="string" required="false" default="N"/>
		
		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status, pc_avaliacoes.pc_aval_processo FROM pc_avaliacoes WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsPc_anexos" > 
			SELECT pc_anexos.*   FROM  pc_anexos
			<cfif #arguments.todosOsRelatorios# eq "N">
				WHERE pc_anexo_avaliacao_id = #arguments.pc_aval_id# and pc_anexo_avaliacaoPDF = 'S'
			<cfelse>
				WHERE (pc_anexo_avaliacao_id = #arguments.pc_aval_id# OR pc_anexo_processo_id = '#rsStatus.pc_aval_processo#')  and pc_anexo_avaliacaoPDF = 'S'
			</cfif>
		</cfquery>


			<cfif directoryExists(application.diretorio_avaliacoes)>
				<cfloop query="rsPc_anexos" >
					<cfif  FileExists(pc_anexo_caminho)>
						<cfset caminho = "#pc_anexo_caminho#">
					<cfelse>
						<cfset caminho = "Caminho  não encontrado">
					</cfif>
					<div class="card-body" style="padding:0px;">
						<div  id ="cardAvaliacaoPDF" class="card card-primary card-tabs collapsed-card" style="transition: all 0.15s ease 0s; height: inherit; width: inherit;">
							<div class="card-header" style="background-color:#00416b;">
							
								<h3 class="card-title" style="font-size:16px;position:relative;top:3px;cursor:pointer" data-card-widget="collapse"><i class="fas fa-file-pdf" style="margin-right:10px;"></i><cfoutput> #pc_anexo_nome#</cfoutput></h3>
								<div  class="card-tools">
									<cfif #rsStatus.pc_aval_status# eq 1 or  #rsStatus.pc_aval_status# eq 3>
										<button type="button"  id="btExcluir" class="btn btn-tool  " style="font-size:16px" onclick="javascript:excluirAnexoAvaliacao(<cfoutput>#pc_anexo_id#</cfoutput>);"  ><i class="fas fa-trash-alt"></i></button>
									</cfif>
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
			<cfelse>
				<h5 style="color:red">Servidor de arquivos não localizado.</h5>
			</cfif>	
			<cfif rsPc_anexos.recordcount eq 0>
				<h5>Nenhum anexo foi adicionado.</h5>
			</cfif>

		<script language="JavaScript">
    
			function excluirAnexoAvaliacao(pc_anexo_id)  {
				
				
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
									url: "cfc/pc_cfcAvaliacoes.cfc",
									data:{
										method: "delAnexos",
										pc_anexo_id: pc_anexo_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
									mostraTabAnexos();
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										mostraRelatoPDF()
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
									url: "cfc/pc_cfcAvaliacoes.cfc",
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









	
	<cffunction name="cadMelhorias"   access="remote"  returntype="any" hint="cadastra/edita as propostas de melhoria">
		
		<cfargument name="modalidade" type="string" required="true"/>
		<cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_melhoria_descricao" type="string" required="true"/>
		<cfargument name="pc_aval_melhoria_num_orgao" type="string" required="true"/>

		<cfargument name="pc_aval_melhoria_id" type="string" required="false" default=""/>

		<cfargument name="pc_aval_melhoria_dataPrev" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_sugestao" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_sug_orgao_mcu" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_naoAceita_justif" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_status" type="string"  required="false"  default=""/>
		
		<cfargument name="pc_aval_melhoria_categoriaControle_id" type="string" required="true"/>
		<cfargument name="pc_aval_melhoria_beneficioNaoFinanceiro" type="string" required="true"/>
		<cfargument name="pc_aval_melhoria_beneficioFinanceiro" type="string" required="true"/>
		<cfargument name="pc_aval_melhoria_custoFinanceiro" type="numeric" required="true"/>
	


		<cfquery datasource="#application.dsn_processos#" name="rsMelhoria">
			<cfif arguments.pc_aval_melhoria_id eq ''>
			
				<cfif '#arguments.pc_aval_melhoria_dataPrev#' eq "">
				
					INSERT pc_avaliacao_melhorias (pc_aval_melhoria_num_aval,pc_aval_melhoria_descricao,pc_aval_melhoria_num_orgao, pc_aval_melhoria_datahora, pc_aval_melhoria_login, pc_aval_melhoria_sugestao, pc_aval_melhoria_sug_orgao_mcu, pc_aval_melhoria_naoAceita_justif,  pc_aval_melhoria_status, pc_aval_melhoria_sug_datahora, pc_aval_melhoria_beneficioNaoFinanceiro, pc_aval_melhoria_beneficioFinanceiro, pc_aval_melhoria_custoFinanceiro)
					VALUES (#arguments.pc_aval_id#,'#arguments.pc_aval_melhoria_descricao#','#arguments.pc_aval_melhoria_num_orgao#',  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, '#application.rsUsuarioParametros.pc_usu_login#','#arguments.pc_aval_melhoria_sugestao#', '#arguments.pc_aval_melhoria_sug_orgao_mcu#','#arguments.pc_aval_melhoria_naoAceita_justif#',  '#arguments.pc_aval_melhoria_status#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, <cfqueryparam value="#arguments.pc_aval_melhoria_beneficioNaoFinanceiro#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#arguments.pc_aval_melhoria_beneficioFinanceiro#" cfsqltype="cf_sql_money">,<cfqueryparam value="#arguments.pc_aval_melhoria_custoFinanceiro#" cfsqltype="cf_sql_money">)
					SELECT SCOPE_IDENTITY() AS newIdMelhoria;
				<cfelse>
					INSERT pc_avaliacao_melhorias (pc_aval_melhoria_num_aval,pc_aval_melhoria_descricao,pc_aval_melhoria_num_orgao, pc_aval_melhoria_datahora, pc_aval_melhoria_login, pc_aval_melhoria_dataPrev, pc_aval_melhoria_sugestao, pc_aval_melhoria_sug_orgao_mcu, pc_aval_melhoria_naoAceita_justif,  pc_aval_melhoria_status, pc_aval_melhoria_sug_datahora, pc_aval_melhoria_beneficioNaoFinanceiro, pc_aval_melhoria_beneficioFinanceiro, pc_aval_melhoria_custoFinanceiro)	
					VALUES (#arguments.pc_aval_id#,'#arguments.pc_aval_melhoria_descricao#','#arguments.pc_aval_melhoria_num_orgao#',  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, '#application.rsUsuarioParametros.pc_usu_login#','#arguments.pc_aval_melhoria_dataPrev#','#arguments.pc_aval_melhoria_sugestao#', '#arguments.pc_aval_melhoria_sug_orgao_mcu#','#arguments.pc_aval_melhoria_naoAceita_justif#',  '#arguments.pc_aval_melhoria_status#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,<cfqueryparam value="#arguments.pc_aval_melhoria_beneficioNaoFinanceiro#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#arguments.pc_aval_melhoria_beneficioFinanceiro#" cfsqltype="cf_sql_money">,<cfqueryparam value="#arguments.pc_aval_melhoria_custoFinanceiro#" cfsqltype="cf_sql_money">)
					SELECT SCOPE_IDENTITY() AS newIdMelhoria;
				</cfif>

				
			<cfelse>
				UPDATE pc_avaliacao_melhorias
				SET    pc_aval_melhoria_descricao = '#arguments.pc_aval_melhoria_descricao#',
					pc_aval_melhoria_num_orgao = '#arguments.pc_aval_melhoria_num_orgao#',
					<cfif '#arguments.pc_aval_melhoria_dataPrev#' neq "">
						pc_aval_melhoria_dataPrev = '#arguments.pc_aval_melhoria_dataPrev#',
					<cfelse>
						pc_aval_melhoria_dataPrev = null,
					</cfif>
					pc_aval_melhoria_sugestao = '#arguments.pc_aval_melhoria_sugestao#',
					pc_aval_melhoria_sug_orgao_mcu = '#arguments.pc_aval_melhoria_sug_orgao_mcu#',
					pc_aval_melhoria_naoAceita_justif = '#arguments.pc_aval_melhoria_naoAceita_justif#',
					pc_aval_melhoria_sug_matricula = '#application.rsUsuarioParametros.pc_usu_matricula#',
					pc_aval_melhoria_status = '#arguments.pc_aval_melhoria_status#',
					pc_aval_melhoria_sug_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					pc_aval_melhoria_beneficioNaoFinanceiro = <cfqueryparam value="#arguments.pc_aval_melhoria_beneficioNaoFinanceiro#" cfsqltype="cf_sql_varchar">,
					pc_aval_melhoria_beneficioFinanceiro = <cfqueryparam value="#arguments.pc_aval_melhoria_beneficioFinanceiro#" cfsqltype="cf_sql_money">,
					pc_aval_melhoria_custoFinanceiro = <cfqueryparam value="#arguments.pc_aval_melhoria_custoFinanceiro#" cfsqltype="cf_sql_money">
				WHERE  pc_aval_melhoria_id = #arguments.pc_aval_melhoria_id#	
			</cfif>
		</cfquery>
		
		<cfif arguments.pc_aval_melhoria_id eq ''>
			<!-- cadastra melhoria x categorias de controles-->
			<cfloop list="#arguments.pc_aval_melhoria_categoriaControle_id#" index="i"> 
				<cfquery datasource="#application.dsn_processos#">
					INSERT INTO pc_avaliacao_melhoria_categoriasControles (pc_aval_melhoria_id, pc_aval_categoriaControle_id)
					VALUES ('#rsMelhoria.newIdMelhoria#', '#i#')
				</cfquery>
			</cfloop>
		<cfelse>
			<!-- exclui melhoria x categorias de controles-->
			<cfquery datasource="#application.dsn_processos#">
				DELETE FROM pc_avaliacao_melhoria_categoriasControles
				WHERE pc_aval_melhoria_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_melhoria_id#">
			</cfquery>
			<!-- cadastra melhoria x categorias de controles-->
			<cfloop list="#arguments.pc_aval_melhoria_categoriaControle_id#" index="i"> 
				<cfquery datasource="#application.dsn_processos#">
					INSERT INTO pc_avaliacao_melhoria_categoriasControles (pc_aval_melhoria_id, pc_aval_categoriaControle_id)
					VALUES ('#arguments.pc_aval_melhoria_id#', '#i#')
				</cfquery>
			</cfloop>	
		</cfif>

		
		
  	</cffunction>









	
	<cffunction name="delMelhorias"   access="remote" returntype="boolean" hint="exclui uma proposta de melhoria">

		<cfargument name="pc_aval_melhoria_id" type="numeric" required="true" default=""/>

		<cfquery datasource="#application.dsn_processos#" >
			DELETE FROM pc_avaliacao_melhoria_categoriasControles
			WHERE pc_aval_melhoria_id= '#arguments.pc_aval_melhoria_id#'
		</cfquery> 

		<cfquery datasource="#application.dsn_processos#" > 
			DELETE FROM pc_avaliacao_melhorias
			WHERE(pc_aval_melhoria_id = #arguments.pc_aval_melhoria_id#)
		</cfquery>
		<cfreturn true />
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

		<cftransaction>
			<cfquery datasource="#application.dsn_processos#"  name="rsOrientacao">
				<cfif #arguments.pc_aval_orientacao_id# eq ''>
					INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login, pc_aval_orientacao_beneficioNaoFinanceiro, pc_aval_orientacao_beneficioFinanceiro, pc_aval_orientacao_custoFinanceiro)
					VALUES (	0
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
					SELECT SCOPE_IDENTITY() AS newIdOrientacao;
					
				<cfelse>
					UPDATE pc_avaliacao_orientacoes
					SET    pc_aval_orientacao_descricao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_descricao#">,
						pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">,
						pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#',
						pc_aval_orientacao_beneficioNaoFinanceiro = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioNaoFinanceiro#">,
						pc_aval_orientacao_beneficioFinanceiro = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_beneficioFinanceiro#">,
						pc_aval_orientacao_custoFinanceiro = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_custoFinanceiro#">
					WHERE  pc_aval_orientacao_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
				</cfif>
			</cfquery>

			<cfif #arguments.pc_aval_orientacao_id# eq ''>
				<!-- cadastra orientacao x categorias de controles-->
				<cfloop list="#arguments.pc_aval_orientacao_categoriaControle_id#" index="i"> 
					<cfquery datasource="#application.dsn_processos#">
						INSERT INTO pc_avaliacao_orientacao_categoriasControles (pc_aval_orientacao_id, pc_aval_categoriaControle_id)
						VALUES ('#rsOrientacao.newIdOrientacao#', '#i#')
					</cfquery>
				</cfloop>
			<cfelse>
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
		</cftransaction>


		
  	</cffunction>





	
	<cffunction name="delOrientacoes"   access="remote" returntype="boolean" hint="exclui uma orientacao">

		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" default=""/>

		<cftransaction>	

            <cfquery datasource="#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_orientacao_categoriasControles
				WHERE pc_aval_orientacao_id= '#arguments.pc_aval_orientacao_id#'
			</cfquery> 
			
			<cfquery datasource="#application.dsn_processos#" > 
				DELETE FROM pc_avaliacao_orientacoes
				WHERE(pc_aval_orientacao_id = #arguments.pc_aval_orientacao_id#)
			</cfquery>

			
		</cftransaction>

		<cfreturn true />

	</cffunction>







    <cffunction name="chatValidacaoForm"   access="remote" hint="envia um chat para cadastroAvaliacaoRelato, 6° Passo e 7° Passo.">
		<cfargument name="pc_aval_id" type="numeric" required="true" />

		<cfquery datasource="#application.dsn_processos#" name="rsChat">
			SELECT pc_validacoes_chat.*
					,pc_usuario_de.pc_usu_matricula as matricula_de
					,pc_usuario_de.pc_usu_nome as nome_de
					,pc_usuario_para.pc_usu_matricula as matricula_para
					,pc_usuario_para.pc_usu_nome as nome_para
			FROM   pc_validacoes_chat
			INNER JOIN pc_usuarios as pc_usuario_de on pc_usuario_de.pc_usu_matricula = pc_validacao_chat_matricula_de
			INNER JOIN pc_usuarios as pc_usuario_para on pc_usuario_para.pc_usu_matricula = pc_validacao_chat_matricula_de
			WHERE  pc_validacao_chat_num_aval = #arguments.pc_aval_id#	
			ORDER BY pc_validacao_chat_dataHora desc
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsChatAvaliacao">
			SELECT pc_avaliacoes.pc_aval_status from pc_avaliacoes where pc_aval_id = #arguments.pc_aval_id#
		</cfquery>

		
			<div class="col-md-12" style="margin-top:50px;margin-bottom:50px;font-size:1.3em">
				<!-- DIRECT CHAT WARNING -->
				<div class="card card-warning direct-chat direct-chat-warning shadow">
				<div class="card-header">
					<h1 class="card-title" style="color:#fff;font-size:1rem!important;">CHAT</h1>

					<div class="card-tools">
				
					</div>
				</div>



				<!-- /.card-header -->
				<div class="card-body">
					<!-- Conversations are loaded here -->
					<div id="chatMemsagens" class="direct-chat-messages" style="<cfif #rsChat.recordcount# eq 0>height:50px;overflow:hidden!important;</cfif>">
						<cfif #rsChat.recordcount# eq 0><h6 style="color:#6c757d">Ainda não existem mensagens trocadas entre a equipe.</h6></cfif>	
						<cfloop query="rsChat" >

							<cfset dataHora = DateFormat(#pc_validacao_chat_dataHora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_validacao_chat_dataHora#,'HH:mm') & ')'>
													
							<cfoutput>
								<!-- Message. Default to the left -->
								<div class="direct-chat-msg <cfif #matricula_de# neq #application.rsUsuarioParametros.pc_usu_matricula# > right</cfif>" >
								
								<!-- /.direct-chat-infos -->
								<i class="fas fa-solid fa-circle-user direct-chat-img"  style="font-size:40px;color:<cfif #matricula_de# neq #application.rsUsuarioParametros.pc_usu_matricula# > ##f3ce64<cfelse> gray</cfif>"></i>
								<!-- /.direct-chat-img -->
								<div class="direct-chat-text" style="font-size:12px!important">
									<div id="#pc_validacao_chat_id#" class="direct-chat-infos clearfix" style="margin-bottom:-5px">
										<span class="direct-chat-name float-left" style="font-size:12px!important">De: #nome_de# (#matricula_de#) </span>
										<span class="direct-chat-timestamp float-right" style="font-size:12px!important">#dataHora#</span>
									</div>
									<pre>#pc_validacao_chat_texto# </pre>
								</div>
								<!-- /.direct-chat-text -->
								</div>
								<!-- /.direct-chat-msg -->
							</cfoutput>
						</cfloop>

					</div>
					<!--/.direct-chat-messages-->

					
				</div>
				<!-- /.card-body -->
				<div id="chatFooter" class="card-footer" style="display: none;">
					
					<div class="input-group">
						<textarea id="textoNaoValidacao" type="text" name="message" style="background:#fff" 
						<cfif #rsChatAvaliacao.pc_aval_status# neq 2>
							placeholder="Insira texto para encaminhamento ..." 
						<cfelse>
							placeholder="Informe o motivo da não validação aqui ..." 
						</cfif>
						
						
						class="form-control textareaTab" rows="3" ></textarea>
					</div>
					<div   class="input-group-append" style="margin-top:20px;display:flex;justify-content:center">
						<button id="btEnviaMensagem" onclick="javascript:enviarMensagem();" class="btn btn-warning">

						<cfif #rsChatAvaliacao.pc_aval_status# neq 2>
							Enviar para validação
						<cfelse>
							Enviar
						</cfif>

						</button>
					</div>
					
				</div>
				<!-- /.card-footer-->
				</div>
				<!--/.direct-chat -->
			</div>
			<!-- /.col -->								
		
		<script language="JavaScript">
			

		</script>

	</cffunction>


	<cffunction name="getAvaliacaoTipos" access="remote" returntype="any" returnformat="json" output="false">
        <cfset var result = "" />
        <cfquery name="qAvaliacaoTipos" datasource="#application.dsn_processos#">
            SELECT 
                pc_aval_tipo_id, 
                pc_aval_tipo_macroprocessos, 
                pc_aval_tipo_processoN1, 
                pc_aval_tipo_processoN2, 
                pc_aval_tipo_processoN3
            FROM 
                pc_avaliacao_tipos
            WHERE
                pc_aval_tipo_status = 'A' 
        </cfquery>
        
        <cfset var data = [] />
        <cfloop query="qAvaliacaoTipos">
            <cfset var tipos = {
                id: qAvaliacaoTipos.pc_aval_tipo_id,
                macroprocessos: qAvaliacaoTipos.pc_aval_tipo_macroprocessos,
                processo_n1: qAvaliacaoTipos.pc_aval_tipo_processoN1,
                processo_n2: qAvaliacaoTipos.pc_aval_tipo_processoN2,
                processo_n3: qAvaliacaoTipos.pc_aval_tipo_processoN3
            } />
            <cfset ArrayAppend(data, tipos) />
        </cfloop>
        
        
        
        <cfreturn data/>
    </cffunction>

    <cffunction name="getAvaliacaoCoso" access="remote" returntype="any" returnformat="json" output="false">
		<cfset var result = "" />
		<cfquery name="qAvaliacaoCoso" datasource="#application.dsn_processos#">
			SELECT 
				pc_aval_coso_id, 
				pc_aval_cosoComponente,
				pc_aval_cosoPrincipio
			FROM 
				pc_avaliacao_coso
			WHERE
				pc_aval_cosoStatus = 'A' 
		</cfquery>
		
		<cfset var data = [] />
		<cfloop query="qAvaliacaoCoso">
			<cfset var coso = {
				id: qAvaliacaoCoso.pc_aval_coso_id,
				componente: qAvaliacaoCoso.pc_aval_cosoComponente,
				principio: qAvaliacaoCoso.pc_aval_cosoPrincipio
			} />
			<cfset ArrayAppend(data, coso) />
		</cfloop>
		
		
		
		<cfreturn data/>
	</cffunction>

	<cffunction name="getAvaliacaoDadosParaEdicao" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="pc_aval_id" type="numeric" required="true" />
		<cfset var result = "" />
		<cfquery name="qAvaliacaoDados" datasource="#application.dsn_processos#">
			SELECT pc_aval_id
					,pc_aval_processo
					,pc_aval_numeracao
					,pc_aval_descricao
					,pc_aval_relato
					,pc_aval_classificacao
					,pc_aval_teste
					,pc_aval_controleTestado
					,pc_aval_sintese
					,pc_aval_coso_id
					,pc_aval_valorEstimadoRecuperar
					,pc_aval_valorEstimadoRisco
					,pc_aval_valorEstimadoNaoPlanejado
					,pc_aval_criterioRef_id
			FROM pc_avaliacoes
			WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>

		<cfquery name="rsTiposControles" datasource="#application.dsn_processos#">
			SELECT pc_aval_tipoControle_id FROM pc_avaliacao_tiposControles 
			WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
		<cfset listaTiposControles = ValueList(rsTiposControles.pc_aval_tipoControle_id,',')>

		<cfquery name="rsCategoriasControles" datasource="#application.dsn_processos#">
			SELECT pc_aval_categoriaControle_id FROM pc_avaliacao_categoriasControles 
			WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
		<cfset listaCategoriasControles = ValueList(rsCategoriasControles.pc_aval_categoriaControle_id,',')>

		<cfquery name="rsRiscos" datasource="#application.dsn_processos#">
			SELECT pc_aval_risco_id FROM pc_avaliacao_riscos 
			WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
		<cfset listaRiscos = ValueList(rsRiscos.pc_aval_risco_id,',')>

		<cfset var data = [] />
		<cfloop query="qAvaliacaoDados">
			<cfset var avaliacao = {
				pc_aval_id: qAvaliacaoDados.pc_aval_id,
				pc_aval_processo: qAvaliacaoDados.pc_aval_processo, 
				pc_aval_numeracao: qAvaliacaoDados.pc_aval_numeracao, 
				pc_aval_descricao: qAvaliacaoDados.pc_aval_descricao, 
				pc_aval_relato: qAvaliacaoDados.pc_aval_relato,
				pc_aval_classificacao: qAvaliacaoDados.pc_aval_classificacao,
				pc_aval_teste: qAvaliacaoDados.pc_aval_teste, 	 
				pc_aval_controleTestado: qAvaliacaoDados.pc_aval_controleTestado, 
				pc_aval_sintese: qAvaliacaoDados.pc_aval_sintese, 
				pc_aval_coso_id: qAvaliacaoDados.pc_aval_coso_id, 
				pc_aval_valorEstimadoRecuperar: qAvaliacaoDados.pc_aval_valorEstimadoRecuperar, 
				pc_aval_valorEstimadoRisco: qAvaliacaoDados.pc_aval_valorEstimadoRisco, 
				pc_aval_valorEstimadoNaoPlanejado: qAvaliacaoDados.pc_aval_valorEstimadoNaoPlanejado, 
				pc_aval_criterioRef_id: qAvaliacaoDados.pc_aval_criterioRef_id, 
				avaliacao_categoria_controle: listaCategoriasControles,
				avaliacao_tipo_controle: listaTiposControles,
				avaliacao_riscos: listaRiscos 
			} />
			<cfset ArrayAppend(data, avaliacao) />
		</cfloop>

		<cfreturn data/>
	</cffunction>
			
	       
				

</cfcomponent>