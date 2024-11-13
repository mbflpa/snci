<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	



	


    <cffunction name="cardsConsulta"   access="remote" hint="enviar os cards dos processos  para a página pc_Consultar.cfm">
			<cfargument name="ano" type="string" required="true" />
			<cfargument name="processoEmAcompanhamento" type="boolean" required="true" />

			<!DOCTYPE html>
			<html lang="pt-br">
			<head>
				
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<style>
					#tabProcConsultaCards_wrapper #tabProcConsultaCards_paginate ul.pagination{
						justify-content: center!important;
					}

					/*style para o popover Desbloquear*/	
					.desbloquear {
						font-size: 12px;
						left: 12px;
						background: red;
						color: #fff;
						text-align:center;
					}
					.bloquear {
						font-size: 12px;
						left: 12px;
						color: #fff;
						text-align:center;
					}
				</style>
			</head>
			<body>

				<div class="card-body" style="border: solid 3px #ffD400;width:100%">
				    <div id="filtroSpan" style="display: none;text-align:right;font-size:18px;position:absolute;top:0px;right:24px;"><span class="statusOrientacoes" style="background:#008000;color:#fff;">Atenção! Um filtro foi aplicado.</span><br><i class="fa fa-2x fa-hand-point-down" style="color:#008000;position:relative;top:8px;right:117px"></i></div>
			
					<div class="row" style="justify-content: space-around;">

						<cfquery name="rsProcCard" datasource="#application.dsn_processos#" timeout="120" >
							SELECT DISTINCT pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
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
										LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
										LEFT JOIN pc_avaliacao_posicionamentos on pc_aval_posic_num_orientacao = pc_aval_id
										LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
										LEFT JOIN pc_avaliadores on pc_avaliador_id_processo = pc_processo_id
										LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
										LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
							WHERE pc_processo_id is not null 
								<cfif '#arguments.ano#' neq 'TODOS'>
									AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
								</cfif>		
								<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
									<!---Se  processoEmAcompanhamento igual a true só mostra orientações de processos em acompanhamento e bloqueados, caso contrário, mostra processos finalizados--->
									<cfif '#arguments.processoEmAcompanhamento#' eq true>
											AND pc_num_status in(4,6)
									<cfelse>
											AND pc_num_status in(5)
									</cfif>
									<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI)--->
									<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
										AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
									</cfif>
									<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
									<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
										AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
									</cfif>
									<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1)' - o órgão de origem será sempre GCOP--->
									<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
										AND pc_num_orgao_origem IN('00436698','00436697','00438080') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#))
									</cfif>
								<cfelse>
							        <!---Se  processoEmAcompanhamento igual a true só mostra orientações de processos em acompanhamento, caso contrário, mostra processos finalizados--->
									<cfif '#arguments.processoEmAcompanhamento#' eq true>
											AND pc_num_status in(4)
									<cfelse>
											AND pc_num_status in(5)
									</cfif>	
									<!---Se o perfil não for 13 - 'CONSULTA' (AUDIT e RISCO)--->
									<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 13 >
										AND (
												pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
												
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
						</cfquery>	

							
						
						
						<cfif #rsProcCard.recordcount# eq 0 >
							<h5>Nenhum processo para acompanhamento foi localizado para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
						</cfif>
						<cfif #rsProcCard.recordcount# neq 0 >
							<div class="col-sm-12">
								
									<table id="tabProcConsultaCards" class="table  " style="background: none;border:none;width:100%;">
									
										<thead >
											<tr style="background: none;border:none">
												<th style="background: none;border:none"></th>
											</tr>
										</thead>
										
										<tbody class="grid-container" >
											<cfloop query="rsProcCard" >

												<tr style="width:270px;border:none;">
													<td style="background: none;border:none;white-space:normal!important;" >	
														<section class="content" >
														
															<a  href="#"  onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcCard.pc_processo_id#'</cfoutput>)">
																<div id="processosConsulta" class="container-fluid" >

																		<div class="row">
																			<div id="cartao" style="width:270px;" >
																			
																				<!-- small card -->
																				<div class="small-box " style="<cfoutput>#pc_status_card_style_header#</cfoutput> font-weight: normal;color:#fff">
																					<cfif #pc_modalidade# eq "A">
																						<span style="font-size:1em;margin-bottom: 0rem!important;color:#fff;position:relative;float:right;margin-right:10px;z-index:11" data-toggle="popover" data-trigger="hover" data-placement="top" title="Processo da modalidade ACOMPANHAMENTO." data-content="Nesta modalidade, o acompanhamento é iniciado no sistema SEI!."><strong>A</strong></span>
																					<cfelseif  #pc_modalidade# eq "E">
																						<span style="font-size:1em;margin-bottom: 0rem!important;color:#fff;position:relative;float:right;margin-right:5px;z-index:11" data-toggle="popover" data-trigger="hover" data-placement="top" title="Processo da modalidade ENTREGA DO RELATÓRIO" data-content="Nesta modalidade, o acompanhamento é iniciado no SNCI - Processos."><strong>E</strong></span>
																					</cfif>
																					<div class="ribbon-wrapper ribbon-lg" >
																						<div class="ribbon " style="font-size:12px;left:8px;<cfoutput>#pc_status_card_style_ribbon#</cfoutput>" ><cfoutput>#pc_status_card_nome_ribbon#</cfoutput></div>
																					</div>
																					

																					<div class="card-header" style="height:140px;width:250px;font-weight:normal!important;">
																						<p style="font-size:1em;margin-bottom: 0rem!important;"><cfoutput>Processo n°: #pc_processo_id#</cfoutput></p>
																						<cfif #pc_num_sei# neq ''>
																							<cfset aux_sei = Trim('#pc_num_sei#')>
																							<cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
																							<p style="font-size:1em;margin-bottom: 0rem!important;"><cfoutput>SEI: #aux_sei#</cfoutput></p>
																						</cfif>
																						<p style="font-size:1em;margin-bottom: 0rem!important;"><cfoutput>#siglaOrgAvaliado#</cfoutput></p>
																						
																						<cfif pc_num_avaliacao_tipo neq 445 and pc_num_avaliacao_tipo neq 2>
																							<cfif pc_aval_tipo_descricao neq ''>
																								<p style="font-size:12px;margin-bottom: 0rem!important;"><cfoutput>#pc_aval_tipo_descricao#</cfoutput></p>
																							<cfelse>
																								<p class="text-ellipsis"><cfoutput>#tipoProcesso#</cfoutput></p>
																							</cfif>
																						<cfelse>
																							<p style="font-size:12px;margin-bottom: 0rem!important;"><cfoutput>#pc_aval_tipo_nao_aplica_descricao#</cfoutput></p>
																						</cfif>
																						
																					</div>
																					<div class="icon">
																						<i class="fas fa-search" style="opacity:0.6;left:100px;top:30px"></i>
																					</div>
																					
																					

																					
																				</div>
																			</div>

																			
																		</div>
																	
																</div>
															</a>
															<!--Verifica se existem posicionamentos de órgãos avaliados-->
															<cfquery name="rsProcComPosicOrgAvaliado" datasource="#application.dsn_processos#" timeout="120">
																SELECT pc_aval_posic_status from pc_avaliacao_posicionamentos
																INNER JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_id = pc_aval_posic_num_orientacao
																INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
																INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
																WHERE pc_processo_id = '#pc_processo_id#' and pc_aval_posic_status = 3 
															</cfquery>

															<!--Verifica se existem orientações-->
															<cfquery name="rsProcComOrientações" datasource="#application.dsn_processos#" timeout="120">
																SELECT pc_aval_orientacao_id from pc_avaliacao_orientacoes
																INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
																INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
																WHERE pc_processo_id = '#pc_processo_id#' 
															</cfquery>

															<!--Verifica se existem Propostas de Melhoria com status diferente de P - PENDENTE-->
															<cfquery name="rsProcComPropMelhoriaAvaliada" datasource="#application.dsn_processos#" timeout="120">
																SELECT pc_aval_melhoria_id FROM pc_avaliacao_melhorias
																INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
																WHERE pc_aval_processo = '#pc_processo_id#' AND pc_aval_melhoria_status not in('P')
															</cfquery>

															
																<div style="position: relative;display: inline-block;">
																	<div style="position: absolute;bottom:22px;left: 0;z-index: 1">
																		<cfif #pc_num_status# eq 6 and #application.rsUsuarioParametros.pc_usu_perfil# neq 13>
																			<i id="btDesbloquear" onclick="<cfoutput>javascript:desbloquearProcesso('#pc_processo_id#','#siglaOrgAvaliado#');</cfoutput>" class="fas fa-unlock grow-icon" style="color: #fff; cursor:pointer; margin-left: 2px;margin-bottom:14px" title="Desbloquear Processo" data-toggle="popover" data-trigger="hover" data-placement="bottom" data-content="Desbloquear o Processo Nº <cfoutput>#pc_processo_id#</cfoutput>."></i>
																		<cfelse>
																		<!--O botão bloquear só será visível para os processos com orientações, orientações sem posicionamento do órgão avaliado e propostas de melhoria sem o status Pendente-->
																			<cfif pc_num_status eq 4 AND pc_modalidade eq "E" AND rsProcComOrientações.recordcount neq 0 AND rsProcComPosicOrgAvaliado.recordcount eq 0 AND rsProcComPropMelhoriaAvaliada.recordcount eq 0  and #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S' and #application.rsUsuarioParametros.pc_usu_perfil# neq 13>
																				<i id="btBloquear" onclick="<cfoutput>javascript:bloquearProcesso('#pc_processo_id#','#siglaOrgAvaliado#');</cfoutput>" class="fas fa-lock grow-icon" style="color: #cd0316; cursor:pointer; margin-left: 2px;margin-bottom:14px" title="Bloquear Processo" data-toggle="popover" data-trigger="hover" data-placement="bottom" data-content="Bloquear o Processo Nº <cfoutput>#pc_processo_id#</cfoutput>."></i>
																			</cfif>
																		</cfif>
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

					</div> <!-- fim row -->
					
				</div>


			<script language="JavaScript">
				
                //inicializa o popover (bloquear/desbloquear processo)
				$(function () {
					$('[data-toggle="popover"]').popover()
				})	
				$('.popover-dismiss').popover({
					trigger: 'hover'
				})
				// Personalize os estilos dos títulos
				$('#btDesbloquear').on('shown.bs.popover', function () {
					$('.popover-title').addClass('desbloquear'); // Por exemplo, adicione a classe "red-title"
				});

				$('#btBloquear').on('shown.bs.popover', function () {
					$('.popover-title').addClass('bloquear'); // Por exemplo, adicione a classe "blue-title"
				});
				
				$(function () {
					$("#tabProcConsultaCards").DataTable({
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
				$(document).ready(function() {
					var table = $('#tabProcConsultaCards').DataTable();
					var filtroSpan = $('#filtroSpan');
					var contadorPisca = 0;
					
					function piscaTexto() {
						filtroSpan.fadeOut(500, function() {
							filtroSpan.fadeIn(500, function() {
								contadorPisca++;
								
								if (contadorPisca < 2) {
									piscaTexto();
								}
							});
						});
					}
					// Verificar se o DataTable está filtrado e exibir o span correspondente
					if (table.search() !== '' && $('#table:visible').length) {
						filtroSpan.show();
						piscaTexto();
					} else {
						filtroSpan.hide();
					}

					// Atualizar o span quando houver filtragem
					table.on('search.dt', function() {
						if (table.search() !== '') {
							// Mostra a div e inicia a animação de piscar
							filtroSpan.show();
							piscaTexto();
						} else {
							filtroSpan.hide();
						}
					});

				});
				

				function exibirTabelaAvaliacoes(numProcesso){
                    $('#tabAvaliacoesConsulta').html('');	
					$('#modalOverlay').modal('show')	
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcConsultasPorProcesso.cfc",
							data:{
								method: "tabAvaliacoesConsulta",
								numProcesso: numProcesso
							},
							async: false,
							success: function(result) {
								$('#tabAvaliacoesConsulta').html(result)
								$('html, body').animate({ scrollTop: ($('#tabAvaliacoesConsulta').offset().top - 80)} , 1000);
								$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
								
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
                
				
				// function ocultarTabela(anoOculta){
			
				// 	$('#modalOverlay').delay(1000).hide(0, function() {
				// 		$('#modalOverlay').modal('hide');
				// 	});
				// 	setTimeout(function() {
				// 		$.ajax({
				// 			type: "post",
				// 			url: "cfc/pc_cfcConsultasPorProcesso.cfc",
				// 			data:{
				// 				method: "cardsConsulta",
				// 				ano: anoOculta,
								
				// 			},
				// 			async: false,
				// 			success: function(result) {
				// 				$('#exibirTab').html(result)
				// 				$('#btExibirTab').removeClass('fa-table')
				// 				$('#btExibirTab').addClass('fa-th')
				// 				$('#btExibirTab').prop('title', 'Exibir Tabela')
				// 				localStorage.setItem('mostraTab', '0');
				// 				$('#tabAvaliacoesConsulta').html('')
						
				// 			},
				// 			error: function(xhr, ajaxOptions, thrownError) {
								
				// 				$('#modal-danger').modal('show')
				// 				$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
				// 				$('#modal-danger').find('.modal-body').text(thrownError)
								
				// 			}
				// 		});
				// 	}, 500);	
					
						
				// }

				function bloquearProcesso(numProcesso, siglaOrgaoAvaliado){
					var mensagem = "Deseja <strong style='color:green'>BLOQUEAR</strong> o processo <strong style='color:green'>" + numProcesso + "</strong> do órgão avaliado <strong style='color:green'>" + siglaOrgaoAvaliado + "</strong>?<br><div style='background-color:#dc3545;color:#fff;text-align:justify;border-radius:0.8rem;padding:15px;'><span style='display: block;font-weight: bold;font-size: 20px;text-align: center;'>ATENÇÃO!</span>Este Processo, todos os seu Itens, Medidas/Orientações para regularização e Propostas de Melhoria receberão o status 'BLOQUEADO' e só poderão ser visualizados pelos órgãos do Controle Interno.</div>"
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
									url: "cfc/pc_cfcConsultasPorProcesso.cfc",
									data:{
										method: "bloquearProcesso",
										numProcesso: numProcesso
									},
									async: false,
									success: function(result) {
										var anoMostra = $("input[name='opcaoAno']:checked").val();
										ocultarTabela(anoMostra)
										
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											toastr.success('Processo BLOQUEADO com sucesso!');
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
						} else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Bloqueio <span style="color:red">cancelado</span> pelo usuário.',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
							
						}
					})
					
				}

				function desbloquearProcesso(numProcesso, siglaOrgaoAvaliado){
					var mensagem = "Deseja <strong style='color:green'>DESBLOQUEAR</strong> o processo <strong style='color:green'>" + numProcesso + "</strong> do órgão avaliado <strong style='color:green'>" + siglaOrgaoAvaliado + "</strong>?<div style='background-color:#dc3545;color:#fff;text-align:justify;border-radius: 0.8rem;padding-right:15px;'><ol style:'list-style-type: decimal'><span style='display: block;font-weight: bold;font-size: 20px;text-align: center;margin-left:-34px'>ATENÇÃO!</span><li>Esse Processo e seus Itens receberão o status 'ACOMPANHAMENTO';</li><li> Suas Medidas/Orientações para regularização receberão o status 'NÃO RESPONDIDO' e serão disponibilizadas aos respectivos órgãos responsáveis;</li><li>Suas Propostas de Melhoria receberão o status 'PENDENTE' e serão disponibilizadas aos respectivos órgãos responsáveis.</li></div>"
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
									url: "cfc/pc_cfcConsultasPorProcesso.cfc",
									data:{
										method: "desbloquearProcesso",
										numProcesso: numProcesso
									},
									async: false,
									success: function(result) {
										var anoMostra = $("input[name='opcaoAno']:checked").val();
										ocultarTabela(anoMostra)
										
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											toastr.success('Processo DESBLOQUEADO com sucesso!');
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
						} else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Desbloqueio <span style="color:red">cancelado</span> pelo usuário.',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					})
					
				}

				


			</script>

			</body>
			</html>

	</cffunction>


	<cffunction name="tabConsulta" returntype="any" access="remote" hint="Criar a tabela dos processos e envia para a página pcAcompanhamento.cfm">
	   	<cfargument name="ano" type="string" required="true"/>
		<cfargument name="processoEmAcompanhamento" type="boolean" required="true"  />

		

		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT DISTINCT pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						, CONCAT(
						'Macroprocesso:<strong> ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,'</strong>',
						' -> N1:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,'</strong>',
						' -> N2:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,'</strong>',
						' -> N3:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN3,'</strong>', '.'
						) as tipoProcesso

			FROM        pc_processos INNER JOIN
						pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
						pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
						pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
						pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
						pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						LEFT JOIN pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
			WHERE pc_processo_id is not null
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se  processoEmAcompanhamento igual a true só mostra orientações de processos em acompanhamento e bloqueados, caso contrário, mostra processos finalizados--->
				<cfif '#arguments.processoEmAcompanhamento#' eq true>
						AND pc_num_status in(4,6)
				<cfelse>
						AND pc_num_status in(5)
				</cfif>
				<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI)--->
				<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
					AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
				<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_avaliador_matricula = '#application.rsUsuarioParametros.pc_usu_matricula#'	or pc_usu_matricula_coordenador = '#application.rsUsuarioParametros.pc_usu_matricula#' or pc_usu_matricula_coordenador_nacional = '#application.rsUsuarioParametros.pc_usu_matricula#'
				</cfif>
				<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1)' ou 14 -'CI - REGIONAL - SCIA - Acompanhamento' - o órgão de origem será sempre GCOP--->
				<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_num_orgao_origem IN('00436698','00436697','00438080') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#))
				</cfif>
			<cfelse>
			    <!---Se  processoEmAcompanhamento igual a true só mostra orientações de processos em acompanhamento, caso contrário, mostra processos finalizados--->
				<cfif '#arguments.processoEmAcompanhamento#' eq true>
						AND pc_num_status in(4)
				<cfelse>
						AND pc_num_status in(5)
				</cfif>
				<!---Se o perfil não for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 13 >
					AND not pc_processos.pc_num_status in(6) AND ((pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					or pc_aval_orientacao_mcu_orgaoResp in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE (pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					or pc_org_mcu_subord_tec in( SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#')))
					)

					or not pc_aval_melhoria_sug_orgao_mcu = null and (pc_aval_melhoria_num_orgao =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					or pc_aval_melhoria_num_orgao in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE (pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					or pc_org_mcu_subord_tec in( SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#')))
					)

					or (pc_aval_melhoria_sug_orgao_mcu =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					or pc_aval_melhoria_sug_orgao_mcu in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE (pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					or pc_org_mcu_subord_tec in( SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#')))
					)
					
					OR pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#')
				</cfif>
			</cfif>
			
		</cfquery>	
		
	
		            
			<div class="row">
				<div class="col-12">
					<div class="card">
						<!-- /.card-header -->
						<div class="card-body">
						    <div id="filtroSpan" style="display: none;text-align:right;font-size:18px;position:absolute;top:-55px;right:24px;"><span class="statusOrientacoes" style="background:#008000;color:#fff;">Atenção! Um filtro foi aplicado.</span><br><i class="fa fa-2x fa-hand-point-down" style="color:#008000;position:relative;top:8px;right:117px"></i></div>

							<cfif #rsProcTab.recordcount# eq 0 >
								<h5 align="center">Nenhum processo para acompanhamento foi localizado para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
							</cfif>
							<cfif #rsProcTab.recordcount# neq 0 >
								<table id="tabProcessos" class="table table-bordered table-striped table-hover text-nowrap">
									<thead style="background: #0083ca;color:#fff">
										<tr style="font-size:14px">
											
											<th>N°Processo SNCI:</th>
											<th>Status do Processo: </th>
											<th >SE/CS:</th>
											<th>Ano PACIN: </th>
											<th>N°SEI: </th>
											<th>N°Relat. SEI: </th>
											<th>Órgão Origem: </th>
											<th>Órgão Avaliado: </th>
											<th>Tipo de Avaliação: </th>
											<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
												<th>Modalidade:</th>
											</cfif>
											<th>Classificação: </th>
											<th>Tipo Demanda: </th>

										</tr>
									</thead>
									
									<tbody>
										<cfloop query="rsProcTab" >
											<cfset status = "#pc_status_id#"> 
											<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
												SELECT  pc_avaliadores.* ,  pc_orgaos.pc_org_se_sigla + '-' + pc_usuarios.pc_usu_nome + '(' + pc_usuarios.pc_usu_matricula + ')' as avaliadores
												FROM    pc_avaliadores 
														INNER JOIN pc_usuarios ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
														INNER JOIN pc_orgaos ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
												WHERE 	pc_avaliador_id_processo = '#pc_processo_id#'
											</cfquery>	 
										
											<cfset avaliadores = ValueList(rsAvaliadores.avaliadores,'<br>')>
											

										

										

											<cfoutput>					
												<tr style="cursor:pointer;font-size:12px" >
																	
														
														<td align="center" onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcTab.pc_processo_id#'</cfoutput>,this)">#pc_processo_id#</td>
														<td onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcTab.pc_processo_id#'</cfoutput>,this)">#pc_status_descricao#</td>
													
														<td onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcTab.pc_processo_id#'</cfoutput>,this)">#seOrgAvaliado#</td>
														<td onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcTab.pc_processo_id#'</cfoutput>,this)">#pc_ano_pacin#</td>
														
														<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
														<td onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcTab.pc_processo_id#'</cfoutput>,this)">#sei#</td>
														<td onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcTab.pc_processo_id#'</cfoutput>,this)">#pc_num_rel_sei#</td>
														<td onclick="javascript:exibirTabelaAvaliacoes(<cfoutput>'#rsProcTab.pc_processo_id#'</cfoutput>,this)">#siglaOrgOrigem#</td>
														<td>#siglaOrgAvaliado#</td>

														
														<cfif pc_num_avaliacao_tipo neq 445 and pc_num_avaliacao_tipo neq 2>
															<cfif pc_aval_tipo_descricao neq ''>
																<td>#pc_aval_tipo_descricao#</td>
															<cfelse>
																<td>#tipoProcesso#</td>
															</cfif>
														<cfelse>
															<td>#pc_aval_tipo_nao_aplica_descricao#</td>
														</cfif>

														<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
															<td>
																<cfif #pc_Modalidade# eq 'A'>
																	Acompanhamento
																<cfelseif #pc_Modalidade# eq 'E'>
																	ENTREGA DO RELATÓRIO
																<cfelse>
																	Normal
																</cfif>
															</td>
														</cfif>
														<td>#pc_class_descricao#</td>
														<cfif #pc_tipo_demanda# eq 'P'>
															<td>PLANEJADA</td>
														<cfelseif #pc_tipo_demanda# eq 'E'>
															<td>EXTRAORDINÁRIA</td>
														<cfelse>
															<td>Não informado</td>
														</cfif>
		
												</tr>
											</cfoutput>
										</cfloop>	
									</tbody>
									
								
								</table>
							</cfif>
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
				
				
		<script language="JavaScript">
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	
		$(function () {
			<cfoutput>
				var emAcomp='#arguments.processoEmAcompanhamento#';
			</cfoutput>
			var tituloExcel ="";
			if(emAcomp==='true'){
				tituloExcel = "SNCI_Consulta_Processos_Acomp_";
			}else{
				tituloExcel = "SNCI_Consulta_Processos_Finalizados_";
			}
			$('#tabProcessos').DataTable( {
				stateSave: true,
				scrollX: true, // Habilitar rolagem horizontal
				autoWidth: false,
				lengthMenu: [
						[5,10, 25, 50, -1],
						[5,10, 25, 50, 'Todos'],
					],
				buttons: [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						title : tituloExcel + d,
						className: 'btExcel',
					},],
				

				}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');

				
				
		} );

		$(document).ready(function() {
			

		});
				



		function exibirTabelaAvaliacoes(numProcesso,linha){
			//cancela e  não propaga o event click original no botão
			// event.preventDefault()
			// event.stopPropagation()	
			// $(linha).closest("tr").children("td:nth-child(1)").click();//seleciona a linha onde o botão foi clicado
			
			$('#tabProcessos tr').each(function () {
				$(this).removeClass('selected');
			}); 
			$('#tabProcessos tbody').on('click', 'tr', function () {
				$(this).addClass('selected');
			});
			
			$('#modalOverlay').modal('show')	
			setTimeout(function() {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcConsultasPorProcesso.cfc",
					data:{
						method: "tabAvaliacoesConsulta",
						numProcesso: numProcesso
					},
					async: false,
					success: function(result) {
						$('#tabAvaliacoesConsulta').html(result)
						$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
						$('html, body').animate({ scrollTop: ($('#tabAvaliacoesConsulta').offset().top - 80)} , 1000);
						
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



		

		</script>	

		
	

	</cffunction>


	<cffunction name="informacoesItensConsulta"   access="remote" hint="envia para a página pc_consultar.cfm tabs com informações do item.">
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="passoapasso" type="string" required="false" default="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">
		</cfquery>

		<session class="content-header"  >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">


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
									
						WHERE  pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">													
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
								or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#'))
						ORDER BY pc_org_sigla
					</cfquery>

					

					<cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
						Select  pc_avaliacao_melhorias.*
								, CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_aval_melhoria_num_orgao ELSE pc_aval_melhoria_sug_orgao_mcu END as mcuOrgaoResp
								, CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_orgaos.pc_org_sigla ELSE pc_orgaoSug.pc_org_sigla END as siglaOrgaoResp
								, pc_orgaos.pc_org_sigla
								, pc_orgaoSug.pc_org_sigla as siglaOrgSug
						FROM pc_avaliacao_melhorias 
						LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao
						LEFT JOIN pc_orgaos as pc_orgaoSug ON pc_orgaoSug.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
						LEFT JOIN pc_avaliacoes ON pc_aval_id = pc_aval_melhoria_num_aval
						LEFT JOIN pc_processos ON pc_processo_id = pc_avaliacoes.pc_aval_processo
						
						WHERE pc_aval_melhoria_num_aval = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">
						
						<cfif #application.rsUsuarioParametros.pc_org_controle_interno# neq 'S'and #application.rsUsuarioParametros.pc_usu_perfil# neq 13>
							AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6)
							AND (
								pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
								or  pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								OR pc_aval_melhoria_sug_orgao_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
								<cfif ListLen(application.orgaosHierarquiaList) GT 0>
									or pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
									or pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
									or pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								</cfif>
							)

							<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
							<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
									
									and NOT (
											pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
										OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
										OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
										)
									
							</cfif>	
							
						</cfif>
						order By pc_aval_melhoria_id 
						
					</cfquery>

				

					<!--tabs-->
				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						
					</style>
						
					
					<div class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
							    <li class="nav-item  ">
									<a  class="nav-link active" id="custom-tabs-one-Item-tab"  data-toggle="pill" href="#custom-tabs-one-Item" role="tab" aria-controls="custom-tabs-one-Item" aria-selected="true">Item</a>
								</li>
								<li class="nav-item  ">
									<a  class="nav-link " id="custom-tabs-one-Orientacoes-tab"  data-toggle="pill" href="#custom-tabs-one-Orientacoes" role="tab" aria-controls="custom-tabs-one-Orientacoes" aria-selected="true">Medida/Orientação para Regularização</a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link" id="custom-tabs-one-Avaliacao-tab"  data-toggle="pill" href="#custom-tabs-one-Avaliacao" role="tab" aria-controls="custom-tabs-one-Avaliacao" aria-selected="true">Relatório</a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos</a>
								</li>
								
								<cfif rsMelhorias.recordcount neq 0>
									<li class="nav-item">
										<a  class="nav-link " id="custom-tabs-one-Melhorias-tab"  data-toggle="pill" href="#custom-tabs-one-Melhorias" role="tab" aria-controls="custom-tabs-one-Melhorias" aria-selected="true">Propostas de Melhoria</a>
									</li>
								</cfif>
							</ul>
							
						</div>
						<div class="card-body">
							<div class="tab-content" id="custom-tabs-one-tabContent">
							   <div class="tab-pane fade  active show" id="custom-tabs-one-Item" role="tabpanel" aria-labelledby="custom-tabs-one-Item-tab" style="font-size:16px">									
									<cfinvoke component="pc_cfcInfoProcessosItens" method="infoItem" returnvariable="infoinfoItem">
										<cfinvokeargument name="pc_aval_id" value="#arguments.idAvaliacao#">
										<cfinvokeargument name="pc_processo_id" value="#rsProcAval.pc_processo_id#">
									</cfinvoke>
								</div>

								<div class="tab-pane fade " id="custom-tabs-one-Orientacoes" role="tabpanel" aria-labelledby="custom-tabs-one-Orientacoes-tab" style="font-size:16px">									
									<div id="tabOrientacoesDiv" style="margin-top:20px"></div>
								</div>
								<div disable class="tab-pane fade" id="custom-tabs-one-Avaliacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Avaliacao-tab" >								
									<div id="anexoAvaliacaoDiv"></div>
								</div>

								<div class="tab-pane fade " id="custom-tabs-one-Anexos" role="tabpanel" aria-labelledby="custom-tabs-one-Anexos-tab">	
									<div id="tabAnexosDiv" style="margin-top:20px"></div>
								</div>

								<cfif rsMelhorias.recordcount neq 0>
									<div class="tab-pane fade " id="custom-tabs-one-Melhorias" role="tabpanel" aria-labelledby="custom-tabs-one-Melhorias-tab">									
										<div id="tabMelhoriasDiv" style="margin-top:20px"></div>														
									</div>
								</cfif>
								
							</div>

						
						</div>
						
					</div>
					
					
					

				</form><!-- fim formCadAvaliacao -->





			</session><!-- fim card-body2 -->	
					

					
		</session>
			

		<script language="JavaScript">
		

			$(document).ready(function() {	
				<cfoutput>
					var pc_aval_status = '#rsProcAval.pc_aval_status#'
				</cfoutput>
				mostraRelatoPDF();
				mostraTabAnexos();
				mostraTabOrientacoes();
				mostraTabMelhorias();
				$('#timelineViewAcompDiv').html('');
				$('#infoOrientacaoCardDiv').attr("hidden",true);
				$('#infoOrientacaoDiv').html('');
			})

			$(function () {
				$('[data-mask]').inputmask()
			})


			<cfoutput>
				var pc_aval_id = '#rsProcAval.pc_aval_id#'
			</cfoutput>


			function mostraTabAnexos(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
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
				}, 500);
			}


			function mostraTabOrientacoes(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcConsultasPorProcesso.cfc",
						data:{
							method: "tabOrientacoesConsulta",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabOrientacoesDiv').html(result)
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
				}, 500);
			}



			function mostraTabMelhorias(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {	
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcConsultasPorProcesso.cfc",
						data:{
							method: "tabMelhorias",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabMelhoriasDiv').html(result)
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
				}, 500);
			}

			function mostraRelatoPDF(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url:"cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "anexoAvaliacao",
							pc_aval_id: pc_aval_id,
							todosOsRelatorios: "S"
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
				}, 500);
			
			}



		</script>

    </cffunction>






	<cffunction name="informacoesItensConsultaOrgaoAvaliado"   access="remote" hint="envia para a página acomanhamento.cfm tabs com informações do item.">
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="passoapasso" type="string" required="false" default="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">
		</cfquery>

		<session class="content-header"  >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">


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
									
						WHERE  pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">													
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
								or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#'))
						ORDER BY pc_org_sigla
					</cfquery>

					

					<cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
						Select  pc_avaliacao_melhorias.*
								, CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_aval_melhoria_num_orgao ELSE pc_aval_melhoria_sug_orgao_mcu END as mcuOrgaoResp
								, CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_orgaos.pc_org_sigla ELSE pc_orgaoSug.pc_org_sigla END as siglaOrgaoResp
								, pc_orgaos.pc_org_sigla
								, pc_orgaoSug.pc_org_sigla as siglaOrgSug
						FROM pc_avaliacao_melhorias 
						LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao
						LEFT JOIN pc_orgaos as pc_orgaoSug ON pc_orgaoSug.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
						LEFT JOIN pc_avaliacoes ON pc_aval_id = pc_aval_melhoria_num_aval
						LEFT JOIN pc_processos ON pc_processo_id = pc_avaliacoes.pc_aval_processo
						
						WHERE pc_aval_melhoria_num_aval = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">
						
						<cfif #application.rsUsuarioParametros.pc_org_controle_interno# neq 'S'and #application.rsUsuarioParametros.pc_usu_perfil# neq 13>
							AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6)
							AND (
								pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
								or  pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								OR pc_aval_melhoria_sug_orgao_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
								<cfif ListLen(application.orgaosHierarquiaList) GT 0>
									or pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
									or pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
									or pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								</cfif>
							)

							<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
							<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
									
									and NOT (
											pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
										OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
										OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
										)
									
							</cfif>	
							
						</cfif>
						order By pc_aval_melhoria_id 
						
					</cfquery>

				

					<!--tabs-->
				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						
					</style>
						
					
					<div class="card card-primary card-tabs"  style="width:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
								<li class="nav-item  ">
									<a  class="nav-link active" id="custom-tabs-one-Item-tab"  data-toggle="pill" href="#custom-tabs-one-Item" role="tab" aria-controls="custom-tabs-one-Item" aria-selected="true">Item</a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-Orientacoes-tab"  data-toggle="pill" href="#custom-tabs-one-Orientacoes" role="tab" aria-controls="custom-tabs-one-Orientacoes" aria-selected="true">Medida/Orientação para Regularização</a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-Avaliacao-tab"  data-toggle="pill" href="#custom-tabs-one-Avaliacao" role="tab" aria-controls="custom-tabs-one-Avaliacao" aria-selected="true">Relatório</a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos</a>
								</li>
								
								<cfif rsMelhorias.recordcount neq 0>
									<li class="nav-item">
										<a  class="nav-link " id="custom-tabs-one-Melhorias-tab"  data-toggle="pill" href="#custom-tabs-one-Melhorias" role="tab" aria-controls="custom-tabs-one-Melhorias" aria-selected="true">Propostas de Melhoria</a>
									</li>
								</cfif>
							</ul>
							
						</div>
						<div class="card-body">
							<div class="tab-content" id="custom-tabs-one-tabContent">

								<div class="tab-pane fade  active show" id="custom-tabs-one-Item" role="tabpanel" aria-labelledby="custom-tabs-one-Item-tab" style="font-size:16px">									
									<cfinvoke component="pc_cfcInfoProcessosItens" method="infoItem" returnvariable="infoinfoItem">
										<cfinvokeargument name="pc_aval_id" value="#arguments.idAvaliacao#">
										<cfinvokeargument name="pc_processo_id" value="#rsProcAval.pc_processo_id#">
									</cfinvoke>
								</div>
								<div class="tab-pane fade" id="custom-tabs-one-Orientacoes" role="tabpanel" aria-labelledby="custom-tabs-one-Orientacoes-tab" style="font-size:16px">									
									<div id="tabOrientacoesDiv" style="margin-top:20px"></div>
								</div>

								<div disable class="tab-pane fade " id="custom-tabs-one-Avaliacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Avaliacao-tab" >								
									<div id="anexoAvaliacaoDiv"></div>
								</div>

								<div class="tab-pane fade " id="custom-tabs-one-Anexos" role="tabpanel" aria-labelledby="custom-tabs-one-Anexos-tab">	
									<div id="tabAnexosDiv" style="margin-top:20px"></div>
								</div>

								
								<cfif rsMelhorias.recordcount neq 0>
									<div class="tab-pane fade " id="custom-tabs-one-Melhorias" role="tabpanel" aria-labelledby="custom-tabs-one-Melhorias-tab">									
										<div id="tabMelhoriasDiv" style="margin-top:20px"></div>														
									</div>
								</cfif>
								
							</div>

						
						</div>
						
					</div>
					
					
					

				</form><!-- fim formCadAvaliacao -->





			</session><!-- fim card-body2 -->	
					

					
		</session>
			

		<script language="JavaScript">
		

			$(document).ready(function() {	
				<cfoutput>
					var pc_aval_status = '#rsProcAval.pc_aval_status#'
				</cfoutput>
				mostraRelatoPDF();
				mostraTabAnexos();
				mostraTabOrientacoes();
				mostraTabMelhorias();
			})

			$(function () {
				$('[data-mask]').inputmask()
			})


			<cfoutput>
				var pc_aval_id = '#rsProcAval.pc_aval_id#'
			</cfoutput>


			function mostraTabAnexos(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
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
				}, 500);
			}


			function mostraTabOrientacoes(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcConsultasPorProcesso.cfc",
						data:{
							method: "tabOrientacoesConsulta",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabOrientacoesDiv').html(result)
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
				}, 500);
			}



			function mostraTabMelhorias(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcConsultasPorProcesso.cfc",
						data:{
							method: "tabMelhorias",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabMelhoriasDiv').html(result)
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
				}, 500);
			}

			function mostraRelatoPDF(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url:"cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "anexoAvaliacao",
							pc_aval_id: pc_aval_id,
							todosOsRelatorios: "S"
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
				}, 500);
			}



		</script>

    </cffunction>





	<cffunction name="tabOrientacoesConsulta" returntype="any" access="remote" hint="Criar a tabela de medidas/orientações para regularização e envia para a páginas pc_CadastroRelato">

	    <cfargument name="pc_aval_id" type="numeric" required="true"/>

	    
        <cfquery datasource="#application.dsn_processos#" name="rsOrientacoes">
			Select pc_avaliacao_orientacoes.* , pc_orgaos.pc_org_sigla, pc_processos.pc_num_status,pc_processos.pc_processo_id, pc_orientacao_status.*
			

			FROM pc_avaliacao_orientacoes 
			LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			INNER JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
			
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
			    WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
			<cfelseif  #application.rsUsuarioParametros.pc_usu_perfil# eq 13 ><!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
			    WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#"> AND  pc_aval_orientacao_status not in (9,12,14)
			<cfelse>
                WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#"> AND  pc_aval_orientacao_status not in (9,12,14)
				AND (
						pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' OR pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
						<cfif ListLen(application.orgaosHierarquiaList) GT 0> 
							OR pc_processos.pc_num_orgao_avaliado IN (#application.orgaosHierarquiaList#)
							OR pc_aval_orientacao_mcu_orgaoResp IN (#application.orgaosHierarquiaList#)
						</cfif>
					)
			</cfif>
			order By pc_aval_orientacao_id 
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status, pc_aval_classificacao FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsEmAnalise">
			SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_id FROM  pc_avaliacao_orientacoes
			WHERE pc_aval_orientacao_num_aval = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
				  AND pc_aval_orientacao_status = 13
		</cfquery>
            
				<div class="row">
					<div class="col-8">
						<div class="card">
							<!-- /.card-header -->
							<div class="card-body">
							    <cfif #rsOrientacoes.recordcount# neq 0>
									<h6 style="color:#0083ca">Clique em uma linha para visualizar a Medida/Orientação para regularização e o Histórico das Manifestações:</h6>
									<table id="tabOrientacoes" class="table table-bordered table-striped table-hover text-nowrap">
										<thead style="background: #0083ca;color:#fff">
											<tr align="center"  style="font-size:14px">
												<th>ID</th>
												<th>Status</th>
												<th>Órgão Responsável</th>
												<th style="width:50px">Data Prevista Resp.</th>
												
											</tr>
										</thead>
									
										<tbody>
											<cfloop query="rsOrientacoes" >
												<cfoutput>

													<tr  style="font-size:14px;cursor:pointer;<cfif #pc_aval_orientacao_dataPrevistaResp# lt DATEFORMAT(Now(),"yyyy-mm-dd") and #pc_aval_orientacao_status# eq 5>color:red</cfif>" onClick="javascript:mostraInfoOrientacao(#pc_aval_orientacao_id#,'#pc_processo_id#')">
														
														<td align="center" style="vertical-align:middle!important;width:5%!important;">#pc_aval_orientacao_id#</td>
														

														<cfif #pc_aval_orientacao_dataPrevistaResp# lt DATEFORMAT(Now(),"yyyy-mm-dd") and (#pc_aval_orientacao_status# eq 4 or #pc_aval_orientacao_status# eq 5)>
															<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
																<td align="center" ><span class="statusOrientacoes" style="background:##FFA500;color:##fff;">PENDENTE</span></td>
															<cfelse>
																<td align="center" ><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;">PENDENTE</span></td>
															</cfif>
														<cfelseif #pc_aval_orientacao_status# eq 3>
															<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
																<td align="center" ><span  class="statusOrientacoes" style="background:##FFA500;color:##fff;">#pc_orientacao_status_descricao#</span></td>
															<cfelse>
																<td align="center" ><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;">#pc_orientacao_status_descricao#</span></td>
															</cfif>
														<cfelse>
															<td  align="center" ><span class="statusOrientacoes" style="#pc_orientacao_status_card_style_header#;" >#pc_orientacao_status_descricao#</span></td>
														</cfif>

														
														<cfif pc_aval_orientacao_distribuido eq 1>
															<td style="vertical-align:middle !important;white-space: pre-wrap;">#pc_org_sigla#</td>
														<cfelse>
															<td style="vertical-align:middle !important;white-space: pre-wrap;">#pc_org_sigla#</td>
														</cfif>
														

														<cfif ListFind("4,5,16", #pc_aval_orientacao_status#) >
															<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,'DD-MM-YYYY') >
															<td align="center">#dataPrev#</td>
														<cfelse>
															<td align="center"></td>
														</cfif>
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
											
										
									</table>
									<cfif rsEmAnalise.recordcount neq 0 and #application.rsUsuarioParametros.pc_org_controle_interno# neq 'S' and #application.rsUsuarioParametros.pc_usu_perfil# neq 13>
										<br><h7 style="color:#ff0080"><i>Prezado gestor,<br>Informamos que existem Medidas/Orientações para Regularização e Manifestações vinculados a este item que estão sob análise da equipe de controle interno. Assim que essa análise for finalizada, as Medidas/Orientações para Regularização e Manifestações retornarão para o processo de acompanhamento e ficarão disponíveis para manifestação e consulta no Sistema SNCI por parte desse gestor.</i></h6>
									</cfif>
								<cfelse>
                                    <cfif rsStatus.pc_aval_classificacao neq 'L'>
										<h6 style="color:#ff0080">Não existem medidas/orientações para regularização para este item. Verifique a aba "Propostas de Melhoria".</h6>
										<cfif rsEmAnalise.recordcount neq 0 and #application.rsUsuarioParametros.pc_org_controle_interno# neq 'S' and #application.rsUsuarioParametros.pc_usu_perfil# neq 13>
											<br><h7 style="color:#ff0080"><i>Prezado gestor,<br>Informamos que existem Medidas/Orientações para Regularização e Manifestações vinculados a este item que estão sob análise da equipe de controle interno. Assim que essa análise for finalizada, as Medidas/Orientações para Regularização e Manifestações retornarão para o processo de acompanhamento e ficarão disponíveis para manifestação e consulta no Sistema SNCI por parte desse gestor.</i></h6>
										</cfif>
									<cfelse>
										<h6 style="color:#ff0080">Conhecer a situação encontrada e adotar providências de regularização, conforme normativos mencionados para este item no Relatório e Anexos. Por esta situação estar classificada como LEVE, não haverá acompanhamento da regularização por parte da equipe Controle Interno, porém, a ocorrência de reincidência em futuros trabalhos acarretará sua reclassificação para nível mais elevado de criticidade (Mediano/Grave), com consequente acompanhamento das ações de regularização por parte do Controle Interno.</h6>
									</cfif>
								</cfif>
							</div>

							<!-- /.card-body -->
						</div>
						<!-- /.card -->
					</div>
				<!-- /.col -->
				</div>
				<!-- /.row -->
		<script language="JavaScript">
				
		
			
			$(document).ready(function() {
				$('#tabOrientacoes').DataTable( {
					destroy: true,
				    stateSave: false,
					responsive: true, 
					lengthChange: false, 
					autoWidth: false,
					sort: false,
					searching:false,
					filter: false,
					info: false,
					paging: false
				})

				select: {
					style: 'single'
				}

				
				
			} );
			
			function mostraInfoOrientacao(pc_aval_orientacao_id,pc_processo_id){

				$('#tabOrientacoes tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabOrientacoes tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
			
					
				$('#infoOrientacaoDiv').html('');
				$('#timelineViewAcompDiv').html('');

				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcInfoProcessosItens.cfc",
						data:{
							method:"infoOrientacao",
							pc_aval_orientacao_id: pc_aval_orientacao_id,
							pc_processo_id: pc_processo_id
						},
						async: false,
						success: function(response) {
							$('#infoOrientacaoCardDiv').attr("hidden",false);
							$('#infoOrientacaoDiv').html(response);
							$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
							
                                mostraTimeline(pc_aval_orientacao_id);    
								
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

			function mostraTimeline(pc_aval_orientacao_id){
				var paraControleInterno ='N';
				<cfif '#application.rsUsuarioParametros.pc_org_controle_interno#' eq 'S' >
					paraControleInterno = 'S';
				</cfif>
				$('#modalOverlay').modal('show')
				
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcConsultasPorProcesso.cfc",
					data:{
						method:"timelineViewAcomp",
						pc_aval_orientacao_id: pc_aval_orientacao_id,
						paraControleInterno: paraControleInterno
					},
					async: false,
					success: function(response) {
						$('#timelineViewAcompDiv').html(response);
						$('#modalOverlay').delay(1000).hide(0, function() {
							$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
							$('html, body').animate({ scrollTop: ($('#infoOrientacaoCardDiv').offset().top-80)} , 1000);
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
		
			}

			

			

		</script>				
			
			
	

	</cffunction>

	





	<cffunction name="tabMelhorias" returntype="any" access="remote" hint="Criar a tabela de propostas de melhoria e envia para a páginas pc_CadastroRelato">

	    <cfargument name="pc_aval_id" type="numeric" required="true"/>

		

        <cfquery datasource="#application.dsn_processos#" name="rsMelhorias">
			Select  pc_avaliacao_melhorias.*
					, CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_aval_melhoria_num_orgao ELSE pc_aval_melhoria_sug_orgao_mcu END as mcuOrgaoResp
					, CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_orgaos.pc_org_sigla ELSE pc_orgaoSug.pc_org_sigla END as siglaOrgaoResp
					, pc_orgaos.pc_org_sigla
					, pc_orgaoSug.pc_org_sigla as siglaOrgSug
					,pc_avaliacoes.pc_aval_processo
			FROM pc_avaliacao_melhorias 
			LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao
			LEFT JOIN pc_orgaos as pc_orgaoSug ON pc_orgaoSug.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
			LEFT JOIN pc_avaliacoes ON pc_aval_id = pc_aval_melhoria_num_aval
			LEFT JOIN pc_processos ON pc_processo_id = pc_avaliacoes.pc_aval_processo
			
			WHERE pc_aval_melhoria_num_aval = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
			
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# neq 'S'and #application.rsUsuarioParametros.pc_usu_perfil# neq 13>
				AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6)
				AND (
					pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' or  pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					<cfif ListLen(application.orgaosHierarquiaList) GT 0>
						or pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
						or pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
					</cfif>
				)

				<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
				<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
						
						and NOT (
								pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
							OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
							OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
						
				</cfif>	
				
			</cfif>
			order By pc_aval_melhoria_id 
			
		</cfquery>

		

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
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
					thead input {
						width: 100%;
					}
					td {
						word-wrap: break-word;
					}
				</style>
            </head>
			<body>

				<div class="row">
					<div class="col-5">
						<div class="card">
							<!-- /.card-header -->
							<div class="card-body">
							   <h5  style="color: #0083ca;">Clique em uma linha para mais informações:</h5>
								<table id="tabMelhorias" class="table table-bordered  table-hover ">
									<thead style="background: #0083ca;color:#fff">
										<tr align="center" style="font-size:14px">
										
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th>ID</th>
											<th>Órgão Responsável</th>
											<th>Status</th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>

										</tr>
									</thead>
								
									<tbody>
										<cfloop query="rsMelhorias" >
											<cfoutput>			
											    <cfquery datasource="#application.dsn_processos#" name="rsMelhoriaCategoriasControles">
												SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_melhoria_categoriasControles
												INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_melhoria_categoriasControles.pc_aval_categoriaControle_id
												WHERE pc_avaliacao_melhoria_categoriasControles.pc_aval_Melhoria_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#pc_aval_melhoria_id#">
											</cfquery>
											<cfset categoriasControlesMelhoriaList=ValueList(rsMelhoriaCategoriasControles.pc_aval_categoriaControle_descricao,"; ")>
											<cfif categoriasControlesMelhoriaList EQ "">
												<cfset categoriasControlesMelhoriaList = "NÃO DEFINIDO">
											</cfif>	
											<!-- Extrair os quatro últimos caracteres e converter para inteiro -->
											<cfset anoProcesso = right(rsMelhorias.pc_aval_processo, 4)>
											<cfset anoProcesso = int(anoProcesso)>


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
														<cfset statusMelhoria = "NÃO INFORMADO">
													</cfdefaultcase>
												</cfswitch>
												<tr style="font-size:14px;color:##000;cursor:pointer" onClick="javascript:visualizarMelhoria(this);">
													<td hidden>#pc_aval_melhoria_descricao#</td>
													<td hidden>#pc_aval_melhoria_sugestao#</td>
													<td hidden>#pc_org_sigla#</td>
													<td hidden >#siglaOrgSug#</td>
													<cfset dataPrev = DateFormat(#pc_aval_melhoria_dataPrev#,'DD-MM-YYYY')>
													<td hidden >#dataPrev#</td>
													<td hidden >#pc_aval_melhoria_naoAceita_justif#</td>
													<td align="center" style="vertical-align:middle !important;white-space: pre-wrap;">#pc_aval_melhoria_id#</td>
													<td style="vertical-align:middle !important;white-space: pre-wrap;">#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td align="center" style="vertical-align:middle !important;white-space: pre-wrap;">#statusMelhoria#</td>
													<td hidden >#pc_aval_melhoria_distribuido#</td>
													
													
													<td hidden >#categoriasControlesMelhoriaList#</td>
													<cfif pc_aval_melhoria_beneficioNaoFinanceiro eq ''>
														<cfset pc_aval_melhoria_beneficioNaoFinanceiro = 'NÃO SE APLICA'>
													<cfelse>
														<cfset pc_aval_melhoria_beneficioNaoFinanceiro = pc_aval_melhoria_beneficioNaoFinanceiro>
													</cfif>
													<cfif pc_aval_melhoria_beneficioFinanceiro gt 0>
														<cfset pc_aval_melhoria_beneficioFinanceiro = pc_aval_melhoria_beneficioFinanceiro>	
													<cfelse>
														<cfset pc_aval_melhoria_beneficioFinanceiro = 'NÃO SE APLICA'>
													</cfif>
													<cfif pc_aval_melhoria_custoFinanceiro gt 0>
														<cfset pc_aval_melhoria_custoFinanceiro = pc_aval_melhoria_custoFinanceiro>
													<cfelse>
														<cfset pc_aval_melhoria_custoFinanceiro = 'NÃO SE APLICA'>
													</cfif>
													
													<td hidden >#pc_aval_melhoria_beneficioNaoFinanceiro#</td>
													<td hidden >#pc_aval_melhoria_beneficioFinanceiro#</td>
													<td hidden >#pc_aval_melhoria_custoFinanceiro#</td>
													<td hidden >#anoProcesso#</td>
													
												
												</tr>
											</cfoutput>
											
										</cfloop>	
									</tbody>
										
									
								</table>
							</div>

							<!-- /.card-body -->
							<cfif application.rsOrgaoSubordinados.recordcount eq 0>	
								<h6 style="color:#ff0080;padding:10px;line-height:1.7;">Obs.: A implementação das propostas de melhoria não são acompanhadas pelo SNCI.
								Caso o status seja 'PENDENTE', o órgão responsável necessita selecionar um status (Aceita / Troca / Recusa), em <span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>, aba "Propostas de Melhoria".</h6>
							<cfelse>
								<h6 style="color:#ff0080;padding:10px;line-height:1.7;">Obs.: A implementação das propostas de melhoria não são acompanhadas pelo SNCI.
								Caso o status seja 'PENDENTE', o órgão responsável, se for um órgão subordinador, necessita selecionar a aba "Propostas de Melhoria" em <span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span> e
								selecionar umas das abas: "Responder" (e selecionar um status: Aceita / Troca / Recusa) ou "Distribuir". Caso o órgão responsável não seja um órgão subordinador, o mesmo necessita selecionar um status (Aceita / Troca / Recusa), em <span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>, aba "Propostas de Melhoria".</h6>
								
								</h6>
							</cfif>
						</div>
						<!-- /.card -->
					</div>
					<div id = "detalhesDiv" class="col-7" hidden>
						<div class="col-sm-12">
							<div class="form-group" style="margin-bottom:0.2rem">	
								<label id="labelMelhoria" for="pcMelhoria"></label>
								<textarea class="form-control" id="pcMelhoria" rows="6" required=""  name="pcMelhoria" class="form-control"></textarea>
							</div>										
						</div>

						<div id="pcNovaAcaoMelhoriaDiv" class="col-sm-12" hidden >
							<div class="form-group" style="margin-bottom:0.2rem">
								<label id="labelPcRecusaJustMelhoria" for="pcNovaAcaoMelhoria">Proposta de Melhoria Sugerida pelo Órgão Responsável:</label>
								<textarea id="pcNovaAcaoMelhoria" class="form-control" rows="6" required=""  name="pcNovaAcaoMelhoria" class="form-control"></textarea>
							</div>										
						</div>
															
					
						<div id="pcDataPrevDiv" class="col-md-6" >
							<div class="form-group" style="margin-bottom:0.2rem">
								<label for="pcDataPrev">Data Prevista p/ Implementação:</label>
								<span id="pcDataPrev"></span>		
							</div>
						</div>
					
						<div id="pcRecusaJustMelhoriaDiv" class="col-sm-12" hidden>
							<div class="form-group" style="margin-bottom:0.2rem">
								<label id="labelPcRecusaJustMelhoria" for="pcRecusaJustMelhoria">Justificativa do órgão para Recusa:</label>
								<textarea id="pcRecusaJustMelhoria" class="form-control"  rows="4" required=""  name="pcRecusaJustMelhoria" class="form-control"></textarea>
							</div>										
						</div>

						<div id="categoriasControlesMelhoriaDiv" class="col-sm-12" hidden>
							<div class="form-group" style="margin-bottom:0.2rem">
								<label for="categoriasControlesMelhoria">Categorias de Controles Internos: </label>
								<span id ="categoriasControlesMelhoria"></span>
							</div>
						</div>
						
						<div id="pcBeneficioNaoFinanceiroDiv" class="col-sm-12" hidden>
							<div class="form-group" style="margin-bottom:0.2rem">
								<label for="pcBeneficioNaoFinanceiro">Benefício Não Financeiro:</label>
								<textarea id="pcBeneficioNaoFinanceiro" class="form-control"  rows="4" required=""  name="pcBeneficioNaoFinanceiro" class="form-control"></textarea>
							</div>
						</div>

						<div id="pcBeneficioFinanceiroDiv" class="col-sm-12" hidden>
							<div class="form-group" style="margin-bottom:0.2rem">
								<label for="pcBeneficioFinanceiro">Benefício Financeiro:</label>
								<span id="pcBeneficioFinanceiro"></span>
							</div>
						</div>

						<div id="pcCustoFinanceiroDiv" class="col-sm-12" hidden>
							<div class="form-group" style="margin-bottom:0.2rem">
								<label for="pcCustoFinanceiro">Custo Financeiro:</label>
								<span id="pcCustoFinanceiro"></span>
							</div>
						</div>


						 
				<!-- /.col -->
				</div>
				<!-- /.row -->
				<script language="JavaScript">
					
					$(document).ready(function() {
						$('#tabMelhorias').DataTable( {
							destroy: true,
							stateSave: false,
							responsive: true, 
							lengthChange: false, 
							autoWidth: false,
							sort: false,
							searching:false,
							filter: false,
							info: false,
							paging: false
						})

						select: {
							style: 'single'
						}
			
					} );

					function visualizarMelhoria(linha) {
						$('#tabMelhorias tr').each(function () {
							$(this).removeClass('selected');
						}); 
						$('#tabMelhorias tbody').on('click', 'tr', function () {
							$(this).addClass('selected');
						});
						$('#detalhesDiv').attr('hidden', false);
						$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true);
						$('#pcRecusaJustMelhoriaDiv').attr('hidden',true);
						$('#pcDataPrevDiv').attr('hidden',false);
						var pc_aval_melhoria_descricao = $(linha).closest("tr").children("td:nth-child(1)").text();
						var pc_aval_melhoria_sugestao = $(linha).closest("tr").children("td:nth-child(2)").text();
						if($(linha).closest("tr").children("td:nth-child(5)").text()!=''){
							var pc_aval_melhoria_dataPrev = $(linha).closest("tr").children("td:nth-child(5)").text();
						}else{
							var pc_aval_melhoria_dataPrev = 'NÃO INFORMADO';
						}
						
						
						var pc_aval_melhoria_naoAceita_justif = $(linha).closest("tr").children("td:nth-child(6)").text();
						var pc_aval_melhoria_status = $(linha).closest("tr").children("td:nth-child(8)").text();
						var pc_aval_melhoria_distribuido = $(linha).closest("tr").children("td:nth-child(10)").text();
						var categoriasControlesMelhoriaList = $(linha).closest("tr").children("td:nth-child(11)").text();
						if(categoriasControlesMelhoriaList == ''){
							categoriasControlesMelhoriaList = 'NÃO DEFINIDO';
						}
						var pc_aval_melhoria_beneficioNaoFinanceiro = $(linha).closest("tr").children("td:nth-child(12)").text();
						if(pc_aval_melhoria_beneficioNaoFinanceiro == ''){
							pc_aval_melhoria_beneficioNaoFinanceiro = 'NÃO SE APLICA';
						}
						//pc_aval_melhoria_beneficioFinanceiro currencyFormat
						var pc_aval_melhoria_beneficioFinanceiro = $(linha).closest("tr").children("td:nth-child(13)").text();
						pc_aval_melhoria_beneficioFinanceiro = parseFloat(pc_aval_melhoria_beneficioFinanceiro.replace(/[^0-9.-]+/g,""));
						pc_aval_melhoria_beneficioFinanceiro = pc_aval_melhoria_beneficioFinanceiro.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
						if($(linha).closest("tr").children("td:nth-child(13)").text() == 0){
							pc_aval_melhoria_beneficioFinanceiro = 'NÃO SE APLICA';
						}
						
						var pc_aval_melhoria_custoFinanceiro = $(linha).closest("tr").children("td:nth-child(14)").text();
						pc_aval_melhoria_custoFinanceiro = parseFloat(pc_aval_melhoria_custoFinanceiro.replace(/[^0-9.-]+/g,""));
						pc_aval_melhoria_custoFinanceiro = pc_aval_melhoria_custoFinanceiro.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
						if($(linha).closest("tr").children("td:nth-child(14)").text()==0){
							pc_aval_melhoria_custoFinanceiro = 'NÃO SE APLICA';
						}

						var anoProcesso = $(linha).closest("tr").children("td:nth-child(15)").text();
						//transforma anoProcesso em inteiro
						anoProcesso = parseInt(anoProcesso);

						if(!pc_aval_melhoria_sugestao == '' ){
							$('#pcNovaAcaoMelhoriaDiv').attr('hidden', false);
							$('#pcDataPrevDiv').attr('hidden', false);
						}
						if(!pc_aval_melhoria_naoAceita_justif == ''){
							$('#pcRecusaJustMelhoriaDiv').attr('hidden',false);
							$('#pcDataPrevDiv').attr('hidden', true);
						}

						

						pc_aval_melhoria_descricao = 'Órgão Responsável: ' +  $(linha).closest("tr").children("td:nth-child(3)").text() + '\n\n' + pc_aval_melhoria_descricao;
						pc_aval_melhoria_sugestao = 'Órgão Responsável: ' +  $(linha).closest("tr").children("td:nth-child(3)").text() + '\n\n' + pc_aval_melhoria_sugestao;
						$('#pcMelhoria').val(pc_aval_melhoria_descricao);
						$('#pcDataPrev').html(pc_aval_melhoria_dataPrev);
						$('#pcRecusaJustMelhoria').val(pc_aval_melhoria_naoAceita_justif);
						$('#pcNovaAcaoMelhoria').val(pc_aval_melhoria_sugestao);

						//colocar um texto no label labelMelhoria conforme valor da coluna pc_aval_melhoria_distribuido
						if(pc_aval_melhoria_distribuido == 1){
							$('#labelMelhoria').html('Proposta de Melhoria Sugerida pelo Controle Interno <span style="color:#e83e8c">(distribuída pelo Órgão Subordinador)</span>:');
						}else{	
							$('#labelMelhoria').html('Proposta de Melhoria Sugerida pelo Controle Interno:');
						}
						$('#categoriasControlesMelhoria').html(categoriasControlesMelhoriaList + '.');
						$('#pcBeneficioNaoFinanceiro').val(pc_aval_melhoria_beneficioNaoFinanceiro);
						$('#pcBeneficioFinanceiro').html(pc_aval_melhoria_beneficioFinanceiro);
						$('#pcCustoFinanceiro').html(pc_aval_melhoria_custoFinanceiro);
						console.log(anoProcesso);
						if(anoProcesso < 2024){
							$('#categoriasControlesMelhoriaDiv').attr('hidden',true);
							$('#pcBeneficioNaoFinanceiroDiv').attr('hidden',true);
							$('#pcBeneficioFinanceiroDiv').attr('hidden',true);
							$('#pcCustoFinanceiroDiv').attr('hidden',true);
						}else{
							$('#categoriasControlesMelhoriaDiv').attr('hidden',false);
							$('#pcBeneficioNaoFinanceiroDiv').attr('hidden',false);
							$('#pcBeneficioFinanceiroDiv').attr('hidden',false);
							$('#pcCustoFinanceiroDiv').attr('hidden',false);
						}

						//mover o scroll para custom-tabs-one-Melhorias-tab
						$('html, body').animate({ scrollTop: ($('#custom-tabs-one-Melhorias-tab').offset().top-80)} , 1000);


					};	

				
					

				</script>				
			</body>
		</html>
			
	

	</cffunction>


	



	<cffunction name="tabAvaliacoesConsulta" returntype="any" access="remote" hint="Criar a tabela das avaliações e envia para a páginas pc_Acompanhamento">
	
	 
		<cfargument name="numProcesso" type="string" required="true"/>
		
		<section class="content" style="padding:10px">
			<div class="container-fluid">
				<div id="accordionCadItemPainel col-sm-12" style="margin-bottom:30px" >
					<div class="card card-success" >
						<div class="card-header" style="background-color: #ffD400;">
							<h4 class="card-title ">
								<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:#00416b;font-weight: bold;"> 
									<i class="fas fa-file-alt" style="margin-right:10px"> </i><span id="texto_card-title">Informações do Processo</span>
								</a>
							</h4>
						</div>
						<div class="card-body">
							<!--- Chama o componente timelineViewPosicionamentos em pc_cfcComponenteTimelinePosicionamentos.cfc --->
							<cfinvoke component="pc_cfcInfoProcessosItens" method="infoProcesso" returnvariable="processoId">
								<cfinvokeargument name="pc_processo_id" value="#arguments.numProcesso#">
							</cfinvoke>
						</div>
					</div><!--fim card card-success -->	
				</div><!--fim acordion -->
			</div><!--fim container-fluid -->
		</section><!--fim section content -->
			
		<cfquery name="rsAvalTab" datasource="#application.dsn_processos#">
			SELECT pc_processos.pc_processo_id, pc_avaliacoes.* FROM pc_processos
			INNER JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
			WHERE  pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProcesso#">
			
			 order by  pc_avaliacoes.pc_aval_numeracao        
		</cfquery>

		<section class="content" id="itensContent">
			<div class="container-fluid">
				<div class="col-12" style="margin-bottom:30px;">
					<div class="card">
						<!-- /.card-header -->
						<div class="card-header" style="background-color:#ffD400;">
							<h4 class="card-title ">
								<a class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:20px;color:#00416b;font-weight: bold;"> 
									<i class="fas fa-file-alt" style="margin-right:10px"> </i><span id="texto_card-title">Itens</span>
								</a>
							</h4>
						</div>
						<div class="card-body">
							<h6 style="color:#0083ca">Clique em um dos itens abaixo para mais informações:</h6>
							<table id="tabAvalConsulta" class="table table-bordered table-striped table-hover text-nowrap" style="margin-bottom:50px">
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:14px">
										<th align="center">Item N°:</th>
										<th>Situação Encontrada </th>
										<th>Classificação: </th>
										
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsAvalTab" >
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

										<cfset vaFalta = #LSCurrencyFormat(pc_aval_vaFalta, 'local')#>
										<cfset vaRisco = #LSCurrencyFormat(pc_aval_vaRisco, 'local')#>
										<cfset vaSobra = #LSCurrencyFormat(pc_aval_vaSobra, 'local')#>

										<cfoutput>	
											<cfset controleInterno = 'N'>
											<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
												<cfset controleInterno = 'S'>
											</cfif>				
											<tr onclick="javascript:mostraInfoAval(#pc_aval_id#,'#controleInterno#')" style="font-size:16px;cursor: pointer;">
												<td>#pc_aval_numeracao# </td>
												<td>#pc_aval_descricao#</td>
												<td>#classifRisco#</td>
											</tr>
										</cfoutput>
									</cfloop>	
								</tbody>
							</table>

							<div id="mostraInfoAvalDiv"  style="margin-top:30px; "></div>
							<div id="infoOrientacaoCardDiv" class="card" hidden>
								<div class="card-header" style="background-color:#ececec;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:gray;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i><span id="texto_card-title">Informações da Medida/Orientação para regularização</span>
										</a>
									</h4>
								</div>
								<div class="card-body">
									<div id="infoOrientacaoDiv" style=""></div>
								</div>
							</div>
								
							<div id="timelineViewAcompDiv" ></div>
							



						</div>

					
						<!-- /.card-body -->
					</div>
					<!-- /.card -->

					

				</div>
			</div>
			<!-- /.container-fluid -->
		</section>
		<!-- /.content -->
			

		<script language="JavaScript">
			
			$(document).ready(function() {
				$('#tabAvalConsulta').DataTable( {
					destroy: true,
					stateSave: false,
					responsive: true, 
					lengthChange: false, 
					autoWidth: false,
					sort: false,
					searching:false,
					filter: false,
					info: false,
					paging: false,
					columnDefs: [
						{
							targets: 1, // substitua pelo índice da coluna desejada
							render: function (data, type, row) {
							if (type === 'display' && data.length > 100) {
								return data.substr(0, 100) + '...';
							}
							return data;
							}
						}
					]
				})

				select: {
					style: 'single'
				}
	
			} );

			

			//ABRE O FORM PARA UPLOAD DA AVALIAÇÃO, ANEXOS, RECOMENDAÇÕES, ETC...
			function mostraInfoAval(idAvaliacao, controleInterno) {
				
				$('#timelineViewAcompDiv').html('');
				$('#tabAvalConsulta tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabAvalConsulta tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
			

				var informacoes = 'informacoesItensConsulta';
				if(controleInterno =='N'){
				informacoes = 'informacoesItensConsultaOrgaoAvaliado';	
				}


				$('#modalOverlay').modal('show')
				
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcConsultasPorProcesso.cfc",
						data:{
							method: informacoes,
							idAvaliacao:idAvaliacao,
							passoapasso:"false"
							
						},
						async: false
					})//fim ajax
					.done(function(result) {				
						$('#mostraInfoAvalDiv').html(result)
						$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
							
						$('html, body').animate({ scrollTop: ($('#mostraInfoAvalDiv').offset().top - 80)} , 1000);
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
		
					})//fim fail
				}, 500);	
				
			}

		


		
		</script>				
			

	</cffunction>

	


	<cffunction name="timelineViewAcomp"   access="remote" hint="enviar o componente timeline dos processos em acompanhamento para a páginas pc_Consulta chama pela função tabAvaliacoesConsulta">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
		<cfargument name="paraControleInterno" type="string" required="true" />

		<!--- Chama o componente timelineViewPosicionamentos em pc_cfcComponenteTimelinePosicionamentos.cfc --->
		<cfinvoke component="pc_cfcComponenteTimelinePosicionamentos" method="timelineViewPosicionamentos" returnvariable="timelineCI">
			<cfinvokeargument name="pc_aval_orientacao_id" value="#arguments.pc_aval_orientacao_id#">
			<cfinvokeargument name="paraControleInterno" value="#arguments.paraControleInterno#">
		</cfinvoke>

	</cffunction>




	<cffunction name="bloquearProcesso"   access="remote" hint="bloqueia o processo, seus itens, orientações e propostas de melhoria">
		<cfargument name="numProcesso" type="string" required="true"/>

		<cftransaction>

			<!--Coloca todas a propostas de melhoria do processo com status B (BLOQUEADA)-->
			<cfquery datasource="#application.dsn_processos#" >
				UPDATE pc_avaliacao_melhorias set 
					pc_aval_melhoria_status = 'B',
					pc_aval_melhoria_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					pc_aval_melhoria_login = '#application.rsUsuarioParametros.pc_usu_login#'
				WHERE pc_aval_melhoria_num_aval in (select pc_aval_id from pc_avaliacoes where pc_aval_processo = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar">)
			</cfquery>
			
			<!--fim Coloca todas a propostas de melhoria do processo com status B (BLOQUEADA)-->

			<!--COLOCA O PROCESSO EM STATUS 6 - BLOQUEADO-->
			<cfquery datasource="#application.dsn_processos#" >
				UPDATE 		pc_processos
				SET         pc_num_status = 6,
							pc_alteracao_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
							pc_alteracao_login = '#application.rsUsuarioParametros.pc_usu_login#'
				WHERE       pc_processo_id = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--fim COLOCA O PROCESSO EM STATUS 6 - BLOQUEADO-->

			<!--COLOCA TODOS OS ITENS DO PROCESSO COM STATUS 8 - BLOQUEADO, EXCETO OS ITENS COM STATUS 7 - FINALIZADO (POIS A FINALIZAÇÃO DO ITEM JÁ FOI TRATADA NA FINALIZAÇÃO DO CADASTRO DO PROCESSO - 6° PASSO)-->
			<cfquery datasource="#application.dsn_processos#" >
				UPDATE 	pc_avaliacoes
				SET 	pc_aval_status=8,
						pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
				WHERE 	pc_aval_processo = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar"> AND pc_aval_status not in (7)
			</cfquery>
			<!--fim COLOCA TODOS OS ITENS DO PROCESSO COM STATUS 8 - BLOQUEADO, EXCETO OS ITENS COM STATUS 7 - FINALIZADO (POIS A FINALIZAÇÃO DO ITEM JÁ FOI TRATADA NA FINALIZAÇÃO DO CADASTRO DO PROCESSO - 6° PASSO)-->

			
			<!--LISTA TODAS AS ORIENTAÇÕES DO PROCESSO-->
			<cfquery datasource="#application.dsn_processos#" name="rsOrientacoes">
				SELECT pc_aval_orientacao_id, pc_aval_orientacao_num_aval, pc_aval_orientacao_status FROM pc_avaliacao_orientacoes
				WHERE pc_aval_orientacao_num_aval in (select pc_aval_id from pc_avaliacoes where pc_aval_processo = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar">)
			</cfquery>
			<!--fim LISTA TODAS AS ORIENTAÇÕES DO PROCESSO-->

			<!--COLOCA AS ORIENTAÇÕES COM STATUS 14 - BLOQUEADA-->
			<!-- LOOP EM CADA ORIENTAÇÃO DO PROCESSO-->
			<cfloop query="rsOrientacoes">
				<cfquery datasource="#application.dsn_processos#" >
					UPDATE	pc_avaliacao_orientacoes 
					SET 	pc_aval_orientacao_status = 14,
							pc_aval_orientacao_dataPrevistaResp = '',
							pc_aval_orientacao_status_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
							pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#'
					WHERE 	pc_aval_orientacao_id = #pc_aval_orientacao_id#
				</cfquery>
				<!--fim COLOCA AS ORIENTAÇÕES COM STATUS 14 - BLOQUEADA-->

				<!--Texto padrão manifestação-->
				<cfset posicaoInicial = "Processo BLOQUEADO.<br>Este relatório aguarda a finalização de análises complementares do controle interno e/ou outros órgãos da empresa para liberação ao ÓRGÃO AVALIADO. Favor aguardar.">
				<!--Insere a manifestação inicial do controle interno para a orientação bloqueada-->
				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado)
					VALUES ('#pc_aval_orientacao_id#', '#posicaoInicial#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', null,'',14, 1)
				</cfquery>
			</cfloop>
			<!--fim LOOP EM CADA ORIENTAÇÃO DO PROCESSO-->


		</cftransaction>



		
	</cffunction>

	<cffunction name="desbloquearProcesso"   access="remote" hint="desbloqueia o processo, seus itens, orientações e propostas de melhoria">
		<cfargument name="numProcesso" type="string" required="true"/>

		<cftransaction>

			<!--Coloca todas a propostas de melhoria do processo com status P (PENDENTE)-->
			<cfquery datasource="#application.dsn_processos#" >
				UPDATE pc_avaliacao_melhorias set 
					pc_aval_melhoria_status = 'P',
					pc_aval_melhoria_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					pc_aval_melhoria_login = '#application.rsUsuarioParametros.pc_usu_login#'
				WHERE pc_aval_melhoria_num_aval in (select pc_aval_id from pc_avaliacoes where pc_aval_processo = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar">)
			</cfquery>
			
			<!--fim Coloca todas a propostas de melhoria do processo com status P (PENDENTE)-->

			<!--COLOCA O PROCESSO EM STATUS 4 - ACOMPANHAMENTO-->
			<cfquery datasource="#application.dsn_processos#" >
				UPDATE 		pc_processos
				SET         pc_num_status = 4,
							pc_alteracao_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
							pc_alteracao_login = '#application.rsUsuarioParametros.pc_usu_login#'
				WHERE       pc_processo_id = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--fim COLOCA O PROCESSO EM STATUS 4 - ACOMPANHAMENTO-->

			<!--COLOCA TODOS OS ITENS DO PROCESSO COM STATUS 6 - ACOMPANHAMENTO, EXCETO OS ITENS COM STATUS 7 - FINALIZADO (POIS A FINALIZAÇÃO DO ITEM JÁ FOI TRATADA NA FINALIZAÇÃO DO CADASTRO DO PROCESSO - 6° PASSO)-->
			<cfquery datasource="#application.dsn_processos#" >
				UPDATE 	pc_avaliacoes
				SET 	pc_aval_status=6,
						pc_aval_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#' 
				WHERE 	pc_aval_processo = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar"> AND pc_aval_status not in (7)
			</cfquery>
			<!--fim COLOCA TODOS OS ITENS DO PROCESSO COM STATUS 6 -  ACOMPANHAMENTO, EXCETO OS ITENS COM STATUS 7 - FINALIZADO (POIS A FINALIZAÇÃO DO ITEM JÁ FOI TRATADA NA FINALIZAÇÃO DO CADASTRO DO PROCESSO - 6° PASSO)-->

			
		
			<!-- Lista todas as medidas/orientações para regularização do processo -->
					<cfquery datasource="#application.dsn_processos#" name="rsOrientacoes">
						SELECT  pc_avaliacao_orientacoes.*,pc_avaliacoes.*, pc_processos.pc_modalidade, pc_processos.pc_iniciarBloqueado
						,pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_email, pc_orgao_avaliado.pc_org_email as pc_orgao_avaliado_email
						,pc_orgao_avaliado.pc_org_sigla as pc_orgao_avaliado_sigla
						FROM pc_avaliacao_orientacoes
						LEFT JOIN  pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
						INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
						INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
						INNER JOIN pc_orgaos as pc_orgao_avaliado on pc_orgao_avaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
						WHERE      pc_aval_processo = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar"> 
					</cfquery>
			<!--fim LISTA TODAS AS ORIENTAÇÕES DO PROCESSO-->

			<!--Insere em uma lista a relação de e-mails dos órgãos responsáveis pelas orientações do processo-->
			<cfset listaEmailsOrgaos = "">	
			<cfloop query="rsOrientacoes">
				<cfif listFind(listaEmailsOrgaos,rsOrientacoes.pc_org_email) eq 0 and rsOrientacoes.pc_org_email neq rsOrientacoes.pc_orgao_avaliado_email>
					<cfset listaEmailsOrgaos = listaEmailsOrgaos &  LTrim(RTrim(rsOrientacoes.pc_org_email)) & ','>
				</cfif>
			</cfloop>

			<!-- Lista todos os e-mails dos órgãos com Propostas de Melhoria no processo -->
			<cfquery datasource="#application.dsn_processos#" name="rsPropostasMelhoria">
				SELECT pc_orgaos.pc_org_email from pc_avaliacao_melhorias
				INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
				INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
				INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
				WHERE pc_aval_processo = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar"> 
			</cfquery>

			<!--Insere em uma lista a relação de e-mails dos órgãos responsáveis pelas propostas de melhoria-->
			<cfloop query="rsPropostasMelhoria">
				<cfif listFind(listaEmailsOrgaos,rsPropostasMelhoria.pc_org_email) eq 0 and rsPropostasMelhoria.pc_org_email neq rsOrientacoes.pc_orgao_avaliado_email>
					<cfset listaEmailsOrgaos = listaEmailsOrgaos &  LTrim(RTrim(rsPropostasMelhoria.pc_org_email)) & ','>
				</cfif>
			</cfloop>

			<!--COLOCA AS ORIENTAÇÕES COM STATUS 4 - NÃO RESPONDIDO-->
			<!-- LOOP EM CADA ORIENTAÇÃO DO PROCESSO-->
			<!--Adiciona 30 dias úteis à data atual para gerar a data prevista para resposta que constara np texto do manifestação-->
			<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio">
			<cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias = 30 />
			<cfset dataPTBR = obterDataPrevista.Data_Prevista_Formatada>
			<cfset dataCFQUERY = "#DateFormat(obterDataPrevista.Data_Prevista,'YYYY-MM-DD')#">	
			<cfloop query="rsOrientacoes">
				<cfquery datasource="#application.dsn_processos#" >
					UPDATE	pc_avaliacao_orientacoes 
					SET 	pc_aval_orientacao_status = 4,
							pc_aval_orientacao_dataPrevistaResp = '#dataCFQUERY#',
							pc_aval_orientacao_status_datahora =  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
							pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#'
					WHERE 	pc_aval_orientacao_id = #pc_aval_orientacao_id#
				</cfquery>
				<!--fim COLOCA AS ORIENTAÇÕES COM STATUS 4 - NÃO RESPONDIDO-->

				<!--Texto padrão manifestação-->
				<cfset posicaoInicial = "Para registro de sua manifestação orienta-se a atentar para as “Orientações/Medidas de Regularização” emitidas pela equipe de Controle Interno, bem como anexar no sistema SNCI as evidências de implementação das ações adotadas. Também solicita-se sua manifestação para as 'Propostas de Melhoria' conforme opções disponíveis no sistema.">
				
				
				<!--Insere a manifestação inicial do controle interno para a orientação bloqueada-->
				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado)
					VALUES ('#pc_aval_orientacao_id#', '#posicaoInicial#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#pc_aval_orientacao_mcu_orgaoResp#','#dataCFQUERY#',4,1)
				</cfquery>
			</cfloop>
			<!--fim LOOP EM CADA ORIENTAÇÃO DO PROCESSO-->

			<!-- Retorna informações do processo para enviar e-mail-->			
			<cfquery datasource="#application.dsn_processos#" name="rsProcesso">
				SELECT  pc_processos.*, pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_email,pc_avaliacao_tipos.pc_aval_tipo_descricao  FROM pc_processos
				INNER JOIN pc_orgaos on pc_num_orgao_avaliado = pc_org_mcu
				INNER JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
				WHERE pc_processo_id = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar"> 
			</cfquery>

			<cfset to = "#LTrim(RTrim(rsProcesso.pc_org_email))#">
			<cfset cc = "#listaEmailsOrgaos#">
			<cfset siglaOrgaoAvaliado = #LTrim(RTrim(rsProcesso.pc_org_sigla))#>
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


		</cftransaction>



		
	</cffunction>


</cfcomponent>