<cfcomponent  >
<cfprocessingdirective pageencoding = "utf-8">	


	<cffunction name="formCadProc"   access="remote" returntype="any">
		<!-- 'A' ATIVO, 'O' ORIGEM DE PROCESSOS, 'D' DESATIVADO -->
		<cfquery name="rsOrigem" datasource="#application.dsn_processos#">
			SELECT pc_org_mcu, pc_org_sigla
			FROM pc_orgaos
			WHERE pc_org_Status = 'O' 
			ORDER BY pc_org_sigla
		</cfquery>
		<cfquery name="rsOrigemGCOP_GCIA_GACE" datasource="#application.dsn_processos#">
			SELECT pc_org_mcu, pc_org_sigla
			FROM pc_orgaos
			WHERE pc_org_Status = 'O' and pc_org_mcu IN('00436698','00436697','00438080')
			ORDER BY pc_org_sigla
		</cfquery>

		<cfquery name="rsAvaliacaoTipo" datasource="#application.dsn_processos#">
			SELECT pc_aval_tipo_id, pc_aval_tipo_descricao
			FROM pc_avaliacao_tipos
			WHERE pc_aval_tipo_status = 'A'
			ORDER BY pc_aval_tipo_descricao
		</cfquery> 

		<cfquery name="rsClas" datasource="#application.dsn_processos#">
			SELECT pc_class_id, pc_class_descricao
			FROM pc_classificacoes
			WHERE pc_class_status ='A'
			ORDER BY pc_class_descricao
		</cfquery>

		<cfquery name="rs_OrgAvaliado" datasource="#application.dsn_processos#">
			SELECT pc_org_mcu, pc_org_sigla
			FROM pc_orgaos
			WHERE pc_org_controle_interno ='N' AND pc_org_Status = 'A' AND pc_org_orgaoAvaliado = 1
			ORDER BY pc_org_sigla
		</cfquery>

		<cfquery name="rs_OrgAvaliadoSE_usuario" datasource="#application.dsn_processos#">
			SELECT pc_org_mcu, pc_org_sigla
			FROM pc_orgaos
			WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') AND (pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_org_se in(#application.seAbrangencia#))
			ORDER BY pc_org_sigla
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsAvaliadores">
			SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios 
			INNER JOIN pc_orgaos ON  pc_org_mcu = pc_usu_lotacao
			WHERE pc_org_controle_interno = 'S' AND pc_usu_status ='A'
			ORDER BY pc_org_se_sigla ASC,  pc_usu_nome ASC
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsObjetivoEstrategico">
			SELECT * FROM pc_objetivo_estrategico
			WHERE pc_objEstrategico_status = 'A'
			ORDER BY pc_objEstrategico_descricao
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsRiscoEstrategico">
			SELECT * FROM pc_risco_estrategico
			WHERE pc_riscoEstrategico_status = 'A'
			ORDER BY pc_riscoEstrategico_descricao
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsIndEstrategico">
			SELECT * FROM pc_indicador_estrategico
			WHERE pc_indEstrategico_status = 'A'
			ORDER BY pc_indEstrategico_descricao
		</cfquery>

		<cfset rsUsuarioParametros = application.rsUsuarioParametros>
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

					/* Evita que campos de datas e textos tenham o ícone verde */
					.form-control[type="text"].is-valid {
						background-image: none !important;
						background-position:0 !important;
						background-size: 0 !important;
						padding-right:0 !important;
					}	
					/* Evita que campos de datas e textos tenham o ícone verde */
					.form-control[type="text"].is-invalid {
						background-image: none !important;
						background-position:0 !important;
						background-size: 0 !important;
						padding-right:0 !important;
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
						padding-right:0 !important;
					}	

					/* Evita que campos de datas tenham o ícone verde */
					.form-control[type="input"].is-invalid {
						background-image: none !important;
						/*background-position:0 !important;*/
						/*background-size: 0 !important;*/
						padding-right:0.75rem !important;
					}

					.was-validated .form-control:invalid, .form-control.is-invalid, .form-control:valid, .form-control.is-valid {
						background-image: none !important;
					}

					

					.cardBodyStepper {
							border: solid 1px rgba(108, 117, 125, 0.3);
							border-radius: 0.5rem;
							box-shadow: 5px 5px 5px rgba(0, 0, 0, 0.05);
					}





				</style>
				
			</head>
			<body >
				<!--acordion-->
				<div id="accordion">
				
			
					<div id="cadastro" class="card card-primary collapsed-card " style="margin-left:8px;">
						<div  class="card-header" style="background-color: #0083ca;color:#fff;">
							<a   class="d-block" data-toggle="collapse" href="#collapseOne"  data-card-widget="collapse">
								<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
								</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um novo Processo</span>
							</a>
							
						</div>
						
						<input id="pcProcessoId" hidden>
						
						<div class="card-body" style="border: solid 3px #0083ca;" >
						    
							<div class="card card-default">
								<div class="card-body p-0">
								    
									<h6  class="font-weight-light text-center" style="top:-15px;font-size:20px!important;color:#00416B;position:absolute;width:100%;left:50%;transform:translateX(-50%);">
										<span id="infoTipoCadastro" style=" background-color:#fff;border:1px solid rgb(229, 231, 235);padding-left:7px;padding-right:7px;border-radius: 5px;">Cadastrando Novo Processo</span>
									</h6>
									<div class="bs-stepper" >
										<div class="bs-stepper-header" role="tablist" >
											<!-- your steps here -->
											<div class="step" data-target="#infoInicial">
												<button type="button" class="step-trigger animate__animated animate__bounce" role="tab" aria-controls="infoInicial" id="infoInicial-trigger">
													<span class="bs-stepper-circle">1</span>
													<span class="bs-stepper-label " id="infoInicialLabel">Informações Iniciais</span>
												</button>
											</div>

											<div class="line"></div>

											<div class="step" data-target="#tipoAvaliacao">
												<button type="button" class="step-trigger" role="tab" aria-controls="tipoAvaliacao" id="tipoAvaliacao-trigger">
													<span class="bs-stepper-circle">2</span>
													<span class="bs-stepper-label" id="tipoAvaliacaoLabel">Tipo de avaliação</span>
												</button>
											</div>

											<div class="line"></div>

											<div class="step" data-target="#infoEstrategicas">
												<button type="button" class="step-trigger" role="tab" aria-controls="infoEstrategicas" id="infoEstrategicas-trigger">
													<span class="bs-stepper-circle">3</span>
													<span class="bs-stepper-label" id="infoEstrategicasLabel">Informações Estratégicas</span>
												</button>
											</div>

											<div class="line"></div>
											
											<div class="step" data-target="#equipe">
												<button type="button" class="step-trigger" role="tab" aria-controls="equipe" id="equipe-trigger">
													<span class="bs-stepper-circle">4</span>
													<span class="bs-stepper-label" id="equipeLabel">Equipe</span>
												</button>
											</div>

											<div class="line"></div>
											
											<div class="step" data-target="#Finalizar">
												<button type="button" class="step-trigger" role="tab" aria-controls="Finalizar" id="finalizar-trigger">
													<span class="bs-stepper-circle">5</span>
													<span class="bs-stepper-label" id="finalizarLabel">Finalizar</span>
												</button>
											</div>


										</div>


										<div class="bs-stepper-content " >
											<!-- your steps content here -->
											<form   id="formInfoInicial" name="formInfoInicial"   onsubmit="return false" novalidate>
												<div id="infoInicial" class="content " role="tabpanel" aria-labelledby="infoInicial-trigger" >
													<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
														<div class="row  " >
															<div class="col-sm-3">
																<div class="form-group">
																	<label for="pcModalidade">Modalidade:</label>
																	<select id="pcModalidade" required name="pcModalidade" class="form-control">
																		<option selected="" disabled="" value=""></option>
																		<!--Se a gerência do usuário for GINS-->
																		<cfif '#application.rsUsuarioParametros.pc_usu_lotacao#' eq '00437407' or '#application.rsUsuarioParametros.pc_usu_perfil#' eq 7>
																			<option value="E">ENTREGA DO RELATÓRIO</option>
																		<cfelse>
																			<option value="A">ACOMPANHAMENTO</option>
																			<option value="E">ENTREGA DO RELATÓRIO</option>
																		</cfif>
																			

																		<!--<option value="N">NORMAL</option>-->
																	</select>
																</div>
															</div>

															<div id="pcNumSEIDiv"  class="col-sm-2" >
																<div class="form-group">
																	<label for="pcNumSEI" >N°SEI</label>
																	<input id="pcNumSEI"  name="pcNumSEI" type="text" class="form-control "  data-inputmask="'mask': '99999.999999/9999-99'" data-mask="99999999999999999"  placeholder="N°SEI...">
																	
																</div>
															</div>

															<div  id="pcNumRelatorioDiv" class="col-sm-2" >
																<div class="form-group">
																	<label for="pcNumRelatorio">N°Rel. SEI</label>
																	<input  id="pcNumRelatorio" required  name="pcNumRelatorio" type="text" class="form-control "  data-inputmask="'mask': '99999999'" data-mask="99999999" placeholder="N°Relatório SEI...">
																</div>
															</div>
															
															<div class="col-sm-5">
																<div class="form-group">
																	<label for="pcOrigem">Origem:</label>
															
																	<select id="pcOrigem" required  name="pcOrigem" class="form-control" >
																		<option selected="" disabled="" value=""></option>

																		<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 8>
																			<cfoutput><option selected value="#application.rsUsuarioParametros.pc_org_mcu#"> #application.rsUsuarioParametros.pc_org_sigla#</option></cfoutput>
																		<cfelseif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#)>
																			<cfoutput query="rsOrigemGCOP_GCIA_GACE">
																				<option value="#rsOrigemGCOP_GCIA_GACE.pc_org_mcu#">#rsOrigemGCOP_GCIA_GACE.pc_org_sigla#</option>
																			</cfoutput>
																		<cfelse>
																			<cfoutput query="rsOrigem" >
																				<option value="#rsOrigem.pc_org_mcu#">#rsOrigem.pc_org_sigla#</option>
																			</cfoutput>
																		</cfif>
																	</select>
																	
																</div>
															</div>
															
															<input hidden  id="pcDataInicioAvaliacaoAnterior"  name="pcDataInicioAvaliacaoAnterior" type="date" class="form-control" placeholder="dd/mm/aaaa" >
															<div class="col-md-2">
																<div class="form-group">
																	<label for="pcDataInicioAvaliacao">Data Início Avaliação:</label>
																	<div class="input-group date" id="reservationdate" data-target-input="nearest">
																		<input  id="pcDataInicioAvaliacao"  name="pcDataInicioAvaliacao" required  type="date" class="form-control" placeholder="dd/mm/aaaa" >
																	</div>
																</div>
															</div>

															<div id="pcDataFimAvaliacaoDiv"  class="col-md-2" >
																<div class="form-group">
																	<label for="pcDataFimAvaliacao">Data Fim Avaliação:</label>
																	<div class="input-group date" id="reservationdate" data-target-input="nearest">
																		<input  id="pcDataFimAvaliacao" min="" name="pcDataFimAvaliacao" required  type="date" class="form-control" placeholder="dd/mm/aaaa" >
																	</div>
																</div>
															</div>

															<div class="col-sm-2">
																<div class="form-group">
																	<label for="pcTipoDemanda" >Tipo de Demanda:</label>
																	<select id="pcTipoDemanda" required  name="pcTipoDemanda" class="form-control" >
																		<option selected="" disabled="" value="">Selecione o tipo de demanda...</option>
																		<option value="P">PLANEJADA</option>
																		<option value="E">EXTRAORDINÁRIA</option>				
																	</select>
																</div>
															</div>

															<div id="pcAnoPacinDiv"  class="col-sm-2" hidden>
																<div class="form-group">
																	<label for="pcAnoPacin">Ano PACIN:</label>
																	<select id="pcAnoPacin" required name="pcAnoPacin" class="form-control" style="font-size: 14px!important"></select>															
																</div>
															</div>


															<div id ="pcTipoClassificacaoDiv" class="col-sm-3">
																<div class="form-group">
																	<label for="pcTipoClassificacao">Classificação:</label>
																	<select id="pcTipoClassificacao" required name="pcTipoClassificacao" class="form-control">
																		<option selected="" disabled="" value=""></option>
																		<cfoutput query="rsClas">
																			<option value="#pc_class_id#">#pc_class_descricao#</option>
																		</cfoutput>
																	</select>
																</div>
															</div>

															<input hidden  id="pcOrgaoAvaliadoAnterior"  name="pcOrgaoAvaliadoAnterior">
															<div class="col-sm-3">
																<div class="form-group">
																	<label for="pcOrgaoAvaliado">Órgão Avaliado:</label>
																	<select id="pcOrgaoAvaliado" required name="pcOrgaoAvaliado" class="form-control">
																		<option selected="" disabled="" value=""></option>
																		<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#)>
																			<cfoutput query="rs_OrgAvaliadoSE_usuario">
																				<option value="#pc_org_mcu#">#pc_org_sigla# (#pc_org_mcu#)</option>
																			</cfoutput>
																		<cfelse>
																			<cfoutput query="rs_OrgAvaliado">
																				<option value="#pc_org_mcu#">#pc_org_sigla# (#pc_org_mcu#)</option>
																			</cfoutput>
																		</cfif>
																	</select>
																</div>
															</div>
															
															
															<div id="pcBloquearDiv" class="col-sm-2" hidden>
																<div class="form-group">
																	<label for="pcBloquear" >Bloquear Processo:</label>
																	<select id="pcBloquear" required  name="pcBloquear" class="form-control" >
																		<option selected="" disabled="" value="">Selecione...</option>
																		<option value="N">NÃO</option>
																		<option value="S">SIM</option>				
																	</select>
																</div>
																
															</div>
															<br>
															<div id="bloqueioAlert" class="alert alert-info col-sm-12 " hidden style="text-align: center;font-size:1.2em">
																Atenção: Ao bloquear este processo, o encaminhamento ao órgão avaliado só ocorrerá após o seu desbloqueio.
															</div>
														</div>
													</div>
													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<button class="btn btn-primary" onclick="inicializarValidacaoStep1();" >Próximo</button>
														<button id="btCancelar"  class="btn  btn-danger " onclick="exibirFormCadProcesso();">Cancelar</button>
													</div>
												</div>
											</form>
											<form   id="formTipoAvaliacao" name="formTipoAvaliacao"  onsubmit="return false" novalidate >
												<div id="tipoAvaliacao" class="content " role="tabpanel" aria-labelledby="tipoAvaliacao-trigger" >
													<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
														<div class="row" >
															<input id="idTipoAvaliacao" hidden></input>
															<div class="form-group col-sm-12">
																		<div id="dados-container" >
																			<!-- Os selects serão adicionados aqui -->
																		</div>

																		<div id="TipoAvalDescricaoDiv" class="form-group col-sm-12 animate__animated animate__fadeInDown" hidden style="margin-top:10px;padding-left: 0;">
																			<label for="pcTipoAvalDescricao" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Descrição do Tipo de Avaliação:</label>
																			<div class="input-group date" id="reservationdate" data-target-input="nearest">
																				<input id="pcTipoAvalDescricao" name="pcTipoAvalDescricao" required  class="form-control" placeholder="Descreva o tipo de avaliação..." style="border-radius: 4px; padding: 10px; box-sizing: border-box; width: 100%;">
																				<span id="pcTipoAvalDescricaoCharCounter" class="badge badge-secondary"></span>
																			</div>
																		</div>
																		<div id="pcProcessoN3Div" class="form-group col-sm-12 animate__animated animate__fadeInDown" hidden style="margin-top:10px;padding-left: 0;">
																			<label for="pcProcessoN3" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Nome do Processo N3:</label>
																			<div class="input-group date" id="reservationdate" data-target-input="nearest">
																				<input id="pcProcessoN3" name="pcProcessoN3" required class="form-control" placeholder="Nome do PROCESSO N3..." style="border-radius: 4px;  padding: 10px; box-sizing: border-box; width: 100%;">
																				<span id="pcProcessoN3CharCounter" class="badge badge-secondary"></span>
																			</div>
																		</div>
																		<div id="pcProcessoN3descricaoDiv" class="form-group col-sm-12 animate__animated animate__fadeInDown" hidden style="margin-top:10px;padding-left: 0;">
																			<label for="pcProcessoN3desc" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Descrição do Processo:</label>
																			<div class="input-group date" id="reservationdate" data-target-input="nearest">
																				<input id="pcProcessoN3desc" name="pcProcessoN3desc" required class="form-control" placeholder="Descreva o PROCESSO..." style="border-radius: 4px;  padding: 10px; box-sizing: border-box; width: 100%;">
																				<span id="pcProcessoN3descCharCounter" class="badge badge-secondary"></span>
																			</div>
																			<div id="bloqueioAlert" class="alert alert-info col-sm-12 animate__animated animate__zoomInDown animate__delay-1s" style="text-align: center;font-size:1.2em;margin-top:5px">
																				Atenção: Ao finalizar o cadastro, este novo grupo de tipo de avaliação também será cadastrado e disponibilizado para seleção em futuros processos.
																			</div>
																		</div>
																		
																		
																		<div id="pcProcessoDescricaoDiv" class="col-sm-12 animate__animated animate__zoomInDown" hidden style="font-size:1.2em;text-align: justify;margin-top:40px">
																			<fieldset >
																				<legend style="margin-bottom:-10px">Descrição do Processo:</legend>
																				<span id="pcProcessoDescricao" ></span>
																			</fieldset>
																		</div>
																	
															
															</div>
														</div>
													</div>
													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<div>	
															<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
															<button class="btn btn-primary" onclick="inicializarValidacaoStep2()">Próximo</button>
														</div>

														<button id="btCancelar"  class="btn  btn-danger " onclick="exibirFormCadProcesso();">Cancelar</button>
													</div>
													
												</div>
											</form>
											<form   id="formInfoEstrategicas" name="formInfoEstrategicaso"  onsubmit="return false" novalidate>
												<div id="infoEstrategicas" class="content" role="tabpanel" aria-labelledby="infoEstrategicas-trigger">
													<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
														<div class="row" style="display:flex; justify-content: space-between;">
															<div class="col-sm-6">
																<div class="form-group " >
																		<label for="pcObjetivoEstrategico">Objetivo Estratégico:</label>
																		<select id="pcObjetivoEstrategico" name="pcObjetivoEstrategico"  class="form-control" multiple="multiple">
																			<cfoutput query="rsObjetivoEstrategico">
																				<option value="#pc_objEstrategico_id#">#trim(pc_objEstrategico_descricao)#</option>
																			</cfoutput>
																		</select>	
																</div>
															</div>

															<div class="col-sm-6">
																<div class="form-group " >
																		<label for="pcRiscoEstrategico">Risco Estratégico:</label>
																		<select id="pcRiscoEstrategico" name="pcRiscoEstrategico" class="form-control" multiple="multiple">
																			<cfoutput query="rsRiscoEstrategico">
																				<option value="#pc_riscoEstrategico_id#">#trim(pc_riscoEstrategico_descricao)#</option>
																			</cfoutput>
																		</select>	
																</div>
															</div>

															<div class="col-sm-6">
																<div class="form-group " >
																		<label for="pcIndEstrategico">Indicador Estratégico:</label>
																		<select id="pcIndEstrategico" name="pcIndEstrategico" class="form-control" multiple="multiple">
																			<cfoutput query="rsIndEstrategico">
																				<option value="#pc_indEstrategico_id#">#trim(pc_indEstrategico_descricao)#</option>
																			</cfoutput>
																		</select>	
																</div>
															</div>
														</div>
													</div>
													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<div>	
															<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
															<button class="btn btn-primary" onclick="inicializarValidacaoStep3()">Próximo</button>
														</div>
														<button id="btCancelar"  class="btn  btn-danger " onclick="exibirFormCadProcesso();">Cancelar</button>
													</div>
													
												</div>
											</form>
											<form   id="formEquipe" name="formEquipe"  onsubmit="return false" novalidate>
												<div id="equipe" class="content" role="tabpanel" aria-labelledby="equipe-trigger">
													<div class="card-body cardBodyStepper animate__animated animate__zoomInDown" >
														<div class="row">
															<div class="col-sm-12">
																<div class="form-group " >
																		<label for="pcAvaliadores">Avaliadores:</label>
																		<select id="pcAvaliadores" name="pcAvaliadores" class="form-control" multiple="multiple">
																			<cfoutput query="rsAvaliadores">
																				<option value="#trim(pc_usu_matricula)#">#trim(pc_org_se_sigla)# - #trim(pc_usu_nome)# (#trim(pc_usu_matricula)#)</option>
																			</cfoutput>
																		</select>	
																</div>
															</div>

															<div id="pcCoordenadorDiv" class="col-sm-4">
																<div class="form-group">
																	<label style="" for="pcCoordenado">Coordenador Regional:</label>
																	<select id="pcCoordenador" required name="pcCoordenador" class="form-control">
																		<option selected="" disabled="" value=""></option>
																		<option value="0">Sem Coord. Regional</option>
																		<cfoutput query="rsAvaliadores">
																			<option value="#trim(pc_usu_matricula)#">#trim(pc_org_se_sigla)# - #trim(pc_usu_nome)# (#trim(pc_usu_matricula)#)</option>
																		</cfoutput>
																	</select>
																</div>
															</div>

															<div class="col-sm-4">
																<div class="form-group">
																	<label style="" for="pcCoordNacional">Coordenador Nacional:</label>
																	<select id="pcCoordNacional" required name="pcCoordNacional" class="form-control">
																		<option selected="" disabled="" value=""></option>
																		<option value="0">Sem Coord. Nacional</option>
																		<cfoutput query="rsAvaliadores">
																			<option value="#trim(pc_usu_matricula)#">#trim(pc_org_se_sigla)# - #trim(pc_usu_nome)# (#trim(pc_usu_matricula)#)</option>
																		</cfoutput>
																	</select>
																</div>
															</div>
														</div>
													</div>
													<div style="margin-top:10px;display:flex;justify-content:space-between">
														<div>	
															<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
															<button class="btn btn-primary" onclick="inicializarValidacaoStep4()">Próximo</button>
														</div>
														<button id="btCancelar"  class="btn  btn-danger " onclick="exibirFormCadProcesso();">Cancelar</button>
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
														<button id="btCancelar"  class="btn  btn-danger " onclick="exibirFormCadProcesso();">Cancelar</button>
													</div>

												</div>
											</form>
											
															
										</div>
									</div>
								
								</div>
								<!-- /.card -->
							</div>
						</div><!--fim card-body -->
						<!--fim collapseOne -->
					</div><!--fim card card-primary -->

				</div><!--fim acordion -->
			
				<script language="JavaScript">
				
					$(document).ready(function() {
						window.stepper = new Stepper($('.bs-stepper')[0], {
							animation: true
						});

						// Oculta todos os elementos com a classe step-trigger, exceto aquele com o ID infoInicial-trigger
						$('.step-trigger').not('#infoInicial-trigger').hide();

						//Initialize Select2 Elements
						$('select').not('[name="tabProcessos_length"], [name="tabProcCards_length"]').select2({
							theme: 'bootstrap4',
							placeholder: 'Selecione...',
							allowClear: true
						});
								
						//Início da validção dos forms do bs-stepper (etapas do cadastro de processo)
						// Adicionar classe 'is-invalid' a todos os campos
						var currentDate = new Date();
						var maxDate = new Date(currentDate.getFullYear() + 1, 11, 31);

						// Adiciona o método de validação personalizado para múltipla seleção
						$.validator.addMethod("atLeastOneSelected", function(value, element) {
							return $(element).find('option:selected').length > 0;
						}, "Pelo menos uma opção deve ser selecionada.");

						$.validator.addMethod("dateRange", function(value, element) {
							var date = new Date(value);
							var startDate = new Date(2019, 0, 1);
							return date >= startDate && date <= maxDate;
						}, "Data fora do intervalo permitido");
						

						$.validator.addMethod("validRelatorioLength", function(value, element) {
							var pcModalidade = $('#pcModalidade').val();
							return !(pcModalidade == 'A' || pcModalidade == 'E') || value.length == 8;
						}, "O N° Rel. SEI deve ter 8 caracteres.");

						$.validator.addMethod("requiredIfType445", function(value, element) {
							return $('#selectDinamicoMACROPROCESSOS').val() != 445 || value !== "";
						}, "Campo obrigatório se o tipo avaliado for Outros.");

						$.validator.addMethod("requiredIfSelectDinamicoZero", function(value, element) {
							return $('#selectDinamicoPROCESSO_N3').val() != 0 || value !== "";
						}, "Campo obrigatório se o valor do select dinâmico for 0.");
						
						// Adiciona método customizado para validar campos de seleção múltipla
						$.validator.addMethod("atLeastOne", function(value, element) {
							return $(element).find('option:selected').length > 0;
						}, "Por favor, selecione pelo menos uma opção.");

						$('#formInfoInicial').validate({
							errorPlacement: function(error, element) {
								error.appendTo(element.closest('.form-group'));
								$(element).removeClass('is-valid').addClass('is-invalid');
							},
							rules: {
								pcNumSEI: {
									required: true,
									pattern: /^\d{5}\.\d{6}\/\d{4}-\d{2}$/					
								},
								pcNumRelatorio: {
									required: true,
									pattern: /^\d{8}$/,
									validRelatorioLength: true
								},
								pcDataInicioAvaliacao: {
									required: true,
									dateRange: true
								},
								pcDataFimAvaliacao: {
									required: true,
									dateRange: true
								},
								pcOrgaoAvaliado: {
									required: true
								},
								pcOrigem: {
									required: true
								},
								
								pcModalidade: {
									required: true
								},
								
								pcTipoDemanda: {
									required: true
								},
								
								pcAnoPacin: {
									required: function(element) {
										return $('#pcTipoDemanda').val() == 'P';
									}
								},
								pcTipoClassificacao: {
									required: true

								},
								pcBloquear: {
									required: function(element) {
										return $('#pcModalidade').val() == 'E';
									}
								}
								
								
							},
							messages: {
								pcNumSEI: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
									pattern: '<span style="color:red;font-size:10px">O N° SEI deve ter 17 números.</span>'
								},
								pcNumRelatorio: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
									pattern: '<span style="color:red;font-size:10px">O N° Rel. SEI deve ter 8 números.</span>'
								},
								pcDataInicioAvaliacao: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
									dateRange: '<span style="color:red;font-size:10px;">A data deve estar entre 01/01/2019 e ' + maxDate.toLocaleDateString('pt-BR') + '.</span>'
								},
								pcDataFimAvaliacao: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
									dateRange: '<span style="color:red;font-size:10px;">Data fora do intervalo permitido.</span>',
									
								},
								pcOrgaoAvaliado: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								pcOrigem: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								
								
								pcModalidade: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								
								pcTipoDemanda: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								
								pcAnoPacin: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória para demanda Planejada.</span>'
								},
								pcTipoClassificacao: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
								},
								pcBloquear: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória para a modalidade Entrega de Relatório.</span>'
								},
								
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

						$('#formTipoAvaliacao').validate({
							errorPlacement: function(error, element) {
								error.appendTo(element.closest('.form-group'));
								$(element).removeClass('is-valid').addClass('is-invalid');
							},
							rules: {
								selectDinamicoMACROPROCESSOS: {
									required: true
								},
								pcTipoAvalDescricao: {
									required: true,
									requiredIfType445: true
								},
								

								pcProcessoN3: {
									required: true,
									requiredIfSelectDinamicoZero: true
								},
								pcProcessoN3desc: {
									required: true
								}
								
								
							},
							messages: {
								selectDinamicoMACROPROCESSOS: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								pcTipoAvalDescricao: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
									requiredIfType445: '<span style="color:red;font-size:10px">Campo obrigatório se o tipo avaliado for Não se aplica.</span>'
								},
								
								pcProcessoN3: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
									requiredIfSelectDinamicoZero: '<span style="color:red;font-size:10px">Campo obrigatório se o valor do select dinâmico for Outros.</span>'
								},
								pcProcessoN3desc: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>',
									requiredIfSelectDinamicoZero: '<span style="color:red;font-size:10px">Campo obrigatório se o valor do select dinâmico for Outros.</span>'
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
							// submitHandler: function(form) {
							// 	//toastr.success('Todos os campos foram preenchidos corretamente!');
							// 	stepper.next();
							// },
							// invalidHandler: function(event, validator) {
							// 	toastr.error('Existem erros no formulário. Por favor, corrija-os e tente novamente.');
							// 	//stepper.previous();
							// 	//stepper.to(1);
							// }
							
						});
						
						$("#formInfoEstrategicas").validate({
							rules: {
								pcObjetivoEstrategico: {
									atLeastOne: true // Adiciona regra de validação customizada
								},
								pcRiscoEstrategico: {
									atLeastOne: true
								},
								pcIndEstrategico: {
									atLeastOne: true
								}
							},
							messages: {
								pcObjetivoEstrategico: {
									atLeastOne: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								pcRiscoEstrategico: {
									atLeastOne: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								pcIndEstrategico: {
									atLeastOne: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
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

						$('#formEquipe').validate({
							rules: {
								pcAvaliadores: {
									required: true
								},
								pcCoordenador: {
									required: true
								},
								pcCoordNacional: {
									required: true
								}
							},
							messages: {
								pcAvaliadores: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								pcCoordenador: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
								},
								pcCoordNacional: {
									required: '<span style="color:red;font-size:10px">Informação obrigatória.</span>'
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

						$('#dados-container').on('change', '#selectDinamicoMACROPROCESSOS', function() {
							
							var selectedText = $(this).find('option:selected').text();
							if(selectedText == 'Não se aplica'){
								//$('#pcTipoAvalDescricao').val(null).trigger('change')
								$('#pcProcessoN3').val(null).trigger('change')
								$('#pcProcessoN3desc').val(null).trigger('change')
								$('#TipoAvalDescricaoDiv').attr("hidden",false)	
								$('#pcProcessoN3Div').attr("hidden",true);
								$('#pcProcessoN3descricaoDiv').attr("hidden",true);
								setupCharCounter('pcTipoAvalDescricao', 'pcTipoAvalDescricaoCharCounter', 250);	
							}else{
								$('#pcTipoAvalDescricao').val(null).trigger('change')
								$('#TipoAvalDescricaoDiv').attr("hidden",true)
								
							}
						});

						// Adiciona manipuladores de eventos de mudança para os campos select2 com o objetivo de esconder a descrição do processo
						$(document).on('change', '#selectDinamicoMACROPROCESSOS, #selectDinamicoPROCESSO_N1, #selectDinamicoPROCESSO_N2', function() {
							$('#pcProcessoDescricaoDiv').attr("hidden",true);
							$('#pcProcessoDescricao').text('');
							$('#pcProcessoN3Div').attr("hidden",true);
							$('#pcProcessoN3descricaoDiv').attr("hidden",true);
							$('#pcProcessoN3').val(null).trigger('change')
							$('#pcProcessoN3desc').val(null).trigger('change')
						});



						// Adiciona manipuladores de eventos de mudança para os campos select2 mudado o estado de válido para inválido quando o campo não tiver nenhuma opção selecionada
						$(document).on('change', 'select[id*="selectDinamico"],#pcTipoAvalDescricao, #pcProcessoN3, #pcProcessoN3desc, #pcObjetivoEstrategico, #pcRiscoEstrategico, #pcIndEstrategico, #pcAvaliadores', function(e) {
							var $this = $(this);
							var selectedValues = $this.val();

							if (selectedValues && selectedValues.length > 0) {
								
								$this.removeClass('is-invalid').addClass('is-valid');
								$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
							} else {
								
								$this.removeClass('is-valid').addClass('is-invalid');
								$this.closest('.form-group').find('label.is-invalid').css('display', 'block');
							}
						});
						
									
						// Inicializar validação ao clicar no botão Próximo
						window.inicializarValidacaoStep1 = function() {
							
							if ($("#formInfoInicial").valid()) {
								// Ir para o próximo passo
								stepper.next();
								$('#tipoAvaliacao-trigger').show();
								// Adiciona a animação bounce ao elemento
								$('#tipoAvaliacao-trigger').addClass('animate__animated animate__bounce');
							}
						};

						window.inicializarValidacaoStep2 = function() {
							// Adiciona manipuladores de eventos de mudança para os campos select2
							$('select').on('change.select2', function() {
								var $this = $(this);
								if ($this.val()) {
									$this.removeClass('is-invalid').addClass('is-valid');
									$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
									
								}
							});
							
							// Aplicar validação aos selects cujo id contenha selectDinamico
							$('select[id*="selectDinamico"]').each(function() {
								// Adiciona manipuladores de eventos de mudança para os campos select2
								$('select').on('change.select2', function() {
									var $this = $(this);
									if ($this.val()) {
										$this.removeClass('is-invalid').addClass('is-valid');
										$this.closest('.form-group').find('label.is-invalid').css('display', 'none');
										
									}
								});

								$(this).rules('add', {
									required: true,
									messages: {
										required: '<span style="color:red;font-size:10px">Este campo é obrigatório.</span>'
									}
								});
							});
							if ($("#formInfoInicial").valid() && $("#formTipoAvaliacao").valid()) {
								// Ir para o próximo passo
								stepper.next();
								$('#infoEstrategicas-trigger').show();
								// Adiciona a animação bounce ao elemento
								$('#infoEstrategicas-trigger').addClass('animate__animated animate__bounce');
							}
						};

						window.inicializarValidacaoStep3 = function() {
							if ($("#formInfoInicial").valid() && $("#formTipoAvaliacao").valid() && $("#formInfoEstrategicas").valid()) {
								// Ir para o próximo passo
								stepper.next();
								$('#equipe-trigger').show();
								$('#equipe-trigger').addClass('animate__animated animate__bounce');
							}
						};

					
						window.inicializarValidacaoStep4 = function() {
							if ($("#formInfoInicial").valid() && $("#formTipoAvaliacao").valid() && $("#formInfoEstrategicas").valid() && $("#formEquipe").valid()) {
								// Ir para o próximo passo
								stepper.next();
								$('#finalizar-trigger').show();
								$('#finalizar-trigger').addClass('animate__animated animate__bounce');
								$('#infoValidas').attr("hidden",false);
								$('#infoInvalidas').attr("hidden",true);
								//se infoTipoCadastro não iniciar o texto com visualizando
								if($('#infoTipoCadastro').text().indexOf('Visualizando') == -1){
									$('#btSalvar').attr("hidden",false);
								}
							}else{
								$('#infoValidas').attr("hidden",true);
								$('#infoInvalidas').attr("hidden",false);
								$('#btSalvar').attr("hidden",true);
							}
						};

						

						// Quando o campo #pcBloquear mudar de valor
						$('#pcBloquear').change(function() {
							// Verifica se o valor selecionado é 'S' (SIM)
							if ($(this).val() === 'S') {
								// Mostra o span em azul alertando sobre o bloqueio dos processos
								$('#bloqueioAlert').attr("hidden",false)
								$('#bloqueioAlert').removeClass('animate__animated animate__zoomOut');
								$('#bloqueioAlert').addClass('animate__animated animate__zoomInDown');
							} else {
								// Caso contrário, esconde o span
								
								// Verifica se o elemento possui a classe desejada
								if ($('#bloqueioAlert').hasClass('animate__animated animate__zoomInDown')) {
									$('#bloqueioAlert').removeClass('animate__animated animate__zoomInDown');
									// Adiciona a classe de animação
									$('#bloqueioAlert').addClass('animate__animated animate__zoomOut');

									// Espera 1000 milissegundos antes de ocultar o elemento
									setTimeout(function() {
										// Verifica novamente se a classe ainda está presente (pode ter sido removida durante a animação)
										if ($('#bloqueioAlert').hasClass('animate__animated animate__zoomOut')) {
											// Define o atributo hidden para true
											$('#bloqueioAlert').attr('hidden', true);
										}
									}, 500); // Aguarda 1 segundo antes de ocultar o elemento
								}
							}
						});
				

						// Fim código validação dos inputs: pcNumSEI e pcNumRelatorio

						// Adicionar método de validação personalizado para verificar a data
						$.validator.addMethod('dateRange', function(value, element) {
							var currentDate = new Date();
							var selectedDate = new Date(value);
							var minDate = new Date('2019-01-01');
							var maxDate = new Date(currentDate.getFullYear() + 1, 11, 31); // Ano atual mais um

							return selectedDate >= minDate && selectedDate <= maxDate;
						}, '');

						//FIM VALIDAÇÃO DO myForm

						//INÍCIO GERAÇÃO ANOS PARA PCANOPACIN
						var currentYear = new Date().getFullYear();
						var startYear = 2019;
						var selectOptions = '<option selected="" disabled="" value=""></option>';

						for (var year = startYear; year <= currentYear + 1; year++) {
							selectOptions += '<option value="' + year + '">' + year + '</option>';
						}
						$('#pcAnoPacin').html(selectOptions);
						//FIM GERAÇÃO ANOS PARA PCANOPACIN

						

						// Define os níveis de dados e nomes dos labels
						let dataLevels = ['MACROPROCESSOS', 'PROCESSO_N1', 'PROCESSO_N2', 'PROCESSO_N3'];
						let labelNames = ['Macroprocesso', 'Processo N1', 'Processo N2', 'Processo N3'];
						let outrosOptions = [
							{ dataLevel:'PROCESSO_N3', text: "OUTROS", value: 0 },
						];
						// Inicializa os selects dinâmicos
						initializeSelectsAjax('#dados-container', dataLevels, 'ID', labelNames, 'idTipoAvaliacao',outrosOptions,'cfc/pc_cfcAvaliacoes.cfc','getAvaliacaoTipos');


						$('#dados-container').on('change', '#selectDinamicoPROCESSO_N3', function() {
						
							var selectedText = $(this).find('option:selected').text();
							if(selectedText == 'OUTROS'){
								$('#pcProcessoN3').val(null).trigger('change')
								$('#pcProcessoN3desc').val(null).trigger('change')
								$('#pcProcessoN3Div').attr("hidden",false)
								$('#pcProcessoN3descricaoDiv').attr("hidden",false)
								setupCharCounter('pcProcessoN3', 'pcProcessoN3CharCounter', 250);
								setupCharCounter('pcProcessoN3desc', 'pcProcessoN3descCharCounter', 250);
								$('#pcProcessoDescricaoDiv').attr("hidden",true);
								$('#pcProcessoDescricao').text('');
							}else{
								$('#pcProcessoN3').val(null).trigger('change')
								$('#pcProcessoN3desc').val(null).trigger('change')
								$('#pcProcessoN3Div').attr("hidden",true);
								$('#pcProcessoN3descricaoDiv').attr("hidden",true);
								
								//obtem o valor do idTipoAvaliacao
								var idTipoProcesso = $('#idTipoAvaliacao').val();
							
								//chama a cffunction obterDescricaoDoTipoDeProcesso e insere no span id pcProcessoDescricao
								$.ajax({
									url: 'cfc/pc_cfcProcessos.cfc',
									type: 'POST',
									data: {
										method: 'obterDescricaoDoTipoDeProcesso',
										idTipoProcesso: idTipoProcesso
									},
									async: false,
								}).done(function(result) {
									// Extrai o texto entre as tags <string> e </string> usando regex
									var regex = /<string>([\s\S]*?)<\/string>/;
									var match = regex.exec(result);

									// Verifica se houve um match e extrai o texto capturado
									var descricao = match ? match[1] : "";

									// Remove as aspas inicial e final, se presentes
									descricao = descricao.replace(/^"(.*)"$/, '$1');

									// Atualiza o conteúdo no elemento HTML
									if (descricao.trim() !== "") {
										$('#pcProcessoDescricao').text(descricao);
										$('#pcProcessoDescricaoDiv').removeAttr("hidden");
									}else{
										$('#pcProcessoDescricao').text('');
										$('#pcProcessoDescricaoDiv').attr("hidden",true);
									}
								});

							}
				
						});
						$("#btSalvar").attr("hidden",false);

					
					});

					$(function () {
						$('[data-mask]').inputmask()
					});

					
					
					$('#pcTipoDemanda').on('change', function (event)  {
						if( $('#pcTipoDemanda').val()=='P'){//se o tipo de demanda for PLANEJADA, visualizar o campo Ano PACIN para preenchimento
							$('#pcAnoPacinDiv').attr("hidden",false)	
						}else{
							$('#pcAnoPacin').val(null).trigger('change') 
							$('#pcAnoPacinDiv').attr("hidden",true)	
							
						}
					});

					$('#pcDataInicioAvaliacao').on('change', function (event) {
						$('#pcDataFimAvaliacao').attr("min",$('#pcDataInicioAvaliacao').val())	
					});

					
					

					
				
					$('#pcModalidade').on('change', function (event){
						if($('#pcModalidade').val() == 'A' || $('#pcModalidade').val() == 'E'){
							//$('#pcNumSEI').val(null).trigger('change')
							$('#pcNumSEIDiv').attr("hidden",false)	

							//$('#pcNumRelatorio').val(null).trigger('change')
							$('#pcNumRelatorioDiv').attr("hidden",false)	

							//$('#pcDataFimAvaliacao').val(null).trigger('change')
							$('#pcDataFimAvaliacaoDiv').attr("hidden",false)

							//$('#pcTipoClassificacao').val(null).trigger('change')
							$("#pcTipoClassificacaoDiv").attr("hidden",false);	
						}else{
							$('#pcNumSEI').val(null).trigger('change')
							//$('#pcNumSEIDiv').attr("hidden",true)	

							$('#pcNumRelatorio').val(null).trigger('change')
							//$('#pcNumRelatorioDiv').attr("hidden",true)	

							$('#pcDataFimAvaliacao').val(null).trigger('change')
							//$('#pcDataFimAvaliacaoDiv').attr("hidden",true)

							$("#pcTipoClassificacao").val('6')
							//$("#pcTipoClassificacaoDiv").attr("hidden",true)	
						}

						if($('#pcModalidade').val() == 'E'){
							$('#pcBloquearDiv').attr("hidden",false)
							$('#pcBloquear').val(null).trigger('change')
						}else{
							$('#pcBloquearDiv').attr("hidden",true)
							$('#pcBloquear').val('N').trigger('change')
						}


					});

					

						
					
					$('#btSalvar').on('click', function (event)  {
						
						
						event.preventDefault()
						event.stopPropagation()
						var sei=$("#pcNumSEI").val().replace(/([^\d])+/gim, '');
						var seiRelatorio=$("#pcNumRelatorio").val().replace(/([^\d])+/gim, '');
						

						

						if (($('#pcModalidade').val() == 'A' || $('#pcModalidade').val()=='E') && $('#pcDataFimAvaliacao').val() < $('#pcDataInicioAvaliacao').val())
						{   	
							toastr.error('A data fim da avaliação não pode ser menor que a data de início!');
							return false;
						}
						
						var anoAtual = new Date($('#pcDataInicioAvaliacao').val()).getFullYear();
						var anoAnterior = new Date($('#pcDataInicioAvaliacaoAnterior').val()).getFullYear();
						var orgaoAvaliadoAnterior = $('#pcOrgaoAvaliadoAnterior').val();
						var orgaoAvaliado = $('#pcOrgaoAvaliado').val();
						


						var mensagem = ""
						if($('#pcProcessoId').val() == ''){
							var mensagem = "Deseja cadastrar este processo?"
						}else{
							if ((anoAtual !== anoAnterior && $('#pcDataInicioAvaliacaoAnterior').val()!==null) || orgaoAvaliadoAnterior !== orgaoAvaliado) {
								var mensagem = "O ano da data de início da avaliação e/ou o órgão avaliado foi alterado. Isso fará com que o SNCI exclua o processo atual e crie um novo processo com uma nova numeração. Caso a alteração seja apenas do órgão responsável, sem que haja modificação de SE, o número SNCI será mantido. Deseja continuar?"
							}else{
								var mensagem = "Deseja editar este processo?"
							}
						}

						if($('#pcCoordenador').val()==0){
							$('#pcCoordenador').val(null)
						}

						if($('#pcCoordNacional').val()==0){
							$('#pcCoordNacional').val(null)
						}
						
						
						swalWithBootstrapButtons.fire({//sweetalert2
							html: logoSNCIsweetalert2(mensagem),
							showCancelButton: true,
							confirmButtonText: 'Sim!',
							cancelButtonText: 'Cancelar!'
							}).then((result) => {
								if (result.isConfirmed) {
									let avaliadoresList = $('#pcAvaliadores').val();
									let objetivoEstrategicoList = $('#pcObjetivoEstrategico').val();
									let riscoEstrategicoList = $('#pcRiscoEstrategico').val();
									let indEstrategicoList = $('#pcIndEstrategico').val();

									$('#modalOverlay').modal('show')
									setTimeout(function() {
										$.ajax({
											type: "post",
											url: "cfc/pc_cfcProcessos.cfc",
											data:{
												method: "cadProc",
												pcProcessoId:$('#pcProcessoId').val(),
												pcNumSEI:$('#pcNumSEI').val(),
												pcNumRelatorio:$('#pcNumRelatorio').val(),
												pcOrigem:$('#pcOrigem').val(),
												pcDataInicioAvaliacao:$('#pcDataInicioAvaliacao').val(),
												pcDataFimAvaliacao:$('#pcDataFimAvaliacao').val(),
												idTipoAvaliacao:$('#idTipoAvaliacao').val(),
												pcTipoAvalDescricao:$('#pcTipoAvalDescricao').val(),
												pcModalidade:$('#pcModalidade').val(),
												pcTipoClassificacao:$('#pcTipoClassificacao').val(),
												pcOrgaoAvaliado:$('#pcOrgaoAvaliado').val(),
												pcObjetivoEstrategico:objetivoEstrategicoList.join(','),
												pcRiscoEstrategico:riscoEstrategicoList.join(','),
												pcIndEstrategico:indEstrategicoList.join(','),
												pcAvaliadores:avaliadoresList.join(','),
												pcCoordenador:$('#pcCoordenador').val(),
												pcCoordNacional:$('#pcCoordNacional').val(),
												pcTipoDemanda:$('#pcTipoDemanda').val(),
												pcAnoPacin:$('#pcAnoPacin').val(),
												pcBloquear:$('#pcBloquear').val(),
												textoSelectDinamicoMACROPROCESSOS:$('#selectDinamicoMACROPROCESSOS option:selected').text(),
												textoSelectDinamicoPROCESSOSN1:$('#selectDinamicoPROCESSO_N1 option:selected').text(),
												textoSelectDinamicoPROCESSOSN2:$('#selectDinamicoPROCESSO_N2 option:selected').text(),
												textoProcessoN3:$('#pcProcessoN3').val(),
												textoComentarioProcessoN3:$('#pcProcessoN3desc').val()
											},
											async: false
										})//fim ajax
										.done(function(result) {
												
											$('#modalOverlay').delay(1000).hide(0, function() {
												$('#modalOverlay').modal('hide');
												toastr.success('Operação realizada com sucesso!');
												// // Oculta todos os elementos com a classe step-trigger, exceto aquele com o ID infoInicial-trigger
												// $('.step-trigger').not('#infoInicial-trigger').hide();
												// stepper.to(0);
												// // Após o cadastro, resetar o estado de validação de todos os formulários
												// $("#formInfoInicial").validate().resetForm();
												// $("#formTipoAvaliacao").validate().resetForm();
												// $("#formInfoEstrategicas").validate().resetForm();
												// $("#formEquipe").validate().resetForm();
												// // Remover classes .is-valid e .is-invalid de todos os elementos da página
												// $('*').removeClass('is-valid is-invalid');
												exibirFormCadProcesso();//function que consta na página pc_Processos.cfm
												

											});

											if(localStorage.getItem('mostraTab')){
												mostraTab = localStorage.getItem('mostraTab');
											}
											
											$('#pcOrgaoAvaliado').removeAttr('disabled');
											$('#pcProcessoId').val(null);
											$('#pcNumSEI').val(null);
											$('#pcNumRelatorio').val(null);
											$('#pcDataInicioAvaliacao').val(null);
											$('#pcDataFimAvaliacao').val(null);
											$('#pcOrigem').val(null).trigger('change');
											$('#pcModalidade').val(null).trigger('change');
											$('#pcTipoClassificacao').val(null).trigger('change');
											$('#selectDinamicoMACROPROCESSOS').val(null).trigger('change');
											$('#pcOrgaoAvaliado').val(null).trigger('change');
											$('#pcObjetivoEstrategico').val(null).trigger('change');
											$('#pcRiscoEstrategico').val(null).trigger('change');
											$('#pcIndEstrategico').val(null).trigger('change');
											$('#pcAvaliadores').val(null).trigger('change');
											$('#pcCoordenador').val(null).trigger('change');
											$('#pcCoordNacional').val(null).trigger('change');
											$('#pcTipoDemanda').val(null).trigger('change');
											$('#pcAnoPacin').val(null).trigger('change'); 

											if(mostraTab == '1'){
												$('#btExibirTab').removeClass('fa-th')
												$('#btExibirTab').addClass('fa-table')
												exibirTabela();
											}else{
												$('#btExibirTab').removeClass('fa-table')
												$('#btExibirTab').addClass('fa-th')
												ocultarTabela();
											}

											$('#cadastro').CardWidget('collapse')
											
											$('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo Processo");

											$('#modalOverlay').delay(1000).hide(0, function() {
												$('#modalOverlay').modal('hide');
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
							
						
					});

					

						
				</script>
			</body>
		</html>
	</cffunction>
	
	
	<cffunction name="cadProc"   access="remote" returntype="any">

	    <cfargument name="pcProcessoId" type="string" required="false" default=''/>
		<cfargument name="pcNumSEI" type="string" required="true" />
		<cfargument name="pcNumRelatorio" type="string" required="true" />
		<cfargument name="pcOrigem" type="string" required="true" />
		<cfargument name="pcDataInicioAvaliacao" type="date" required="true" />
		<cfargument name="pcDataFimAvaliacao" type="any" required="false" />
		<cfargument name="idTipoAvaliacao" type="string" required="true" />
		<cfargument name="pcTipoAvalDescricao" type="string" required="false" default=''/>
		<cfargument name="pcModalidade" type="string" required="true" />
		<cfargument name="pcTipoClassificacao" type="string" required="true" />
		<cfargument name="pcOrgaoAvaliado" type="string" required="true" />

		<cfargument name="pcObjetivoEstrategico" type="string" required="true" />
		<cfargument name="pcRiscoEstrategico" type="string" required="true" />
		<cfargument name="pcIndEstrategico" type="string" required="true" />


		<cfargument name="pcAvaliadores" type="any" required="true" />
		<cfargument name="pcCoordenador" type="string" required="false" default=''/>
		<cfargument name="pcCoordNacional" type="string" required="true"/>
		<cfargument name="pcNumStatus" type="string" required="false" default='2'/>
        <cfargument name="pcTipoDemanda" type="string" required="true"/>
		<cfargument name="pcAnoPacin" type="string" required="true"/>
		<cfargument name="pcBloquear" type="string" required="true"/>

		<cfargument name="textoSelectDinamicoMACROPROCESSOS" type="string" required="false" default=''/>
		<cfargument name="textoSelectDinamicoPROCESSOSN1" type="string" required="false" default=''/>
		<cfargument name="textoSelectDinamicoPROCESSOSN2" type="string" required="false" default=''/>
		<cfargument name="textoProcessoN3" type="string" required="false" default=''/>
		<cfargument name="textoComentarioProcessoN3" type="string" required="false" default=''/>
		
		<cfset ano = year(#arguments.pcDataInicioAvaliacao#)> 
		<cfset login = '#application.rsUsuarioParametros.pc_usu_login#'>

		<cfquery name="rsSEorgAvaliado" datasource="#application.dsn_processos#">
		  SELECT pc_org_se from pc_orgaos where pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pcOrgaoAvaliado#">
        </cfquery>

		<cfquery name="rsSeq" datasource="#application.dsn_processos#">
			SELECT Max(pc_processo_id) AS Max
			FROM pc_processos 
			WHERE pc_processo_id like '%#ano#' AND pc_processo_id like '#rsSEorgAvaliado.pc_org_se#%'
		</cfquery>

		

        <cfif rsSeq.Max eq "">
            <cfset NumID = 1>
        <cfelse>
            <cfset NumID = val(mid(rsSeq.Max,3,4) + 1)>			
        </cfif>	

        <cfswitch expression="#len(NumID)#">
            <cfcase value="1">
                <cfset NumID = '000' & NumID>
            </cfcase>
            <cfcase value="2">
                <cfset NumID = '00' & NumID>
            </cfcase>
            <cfcase value="3">
                <cfset NumID = '0' & NumID>
            </cfcase>
        </cfswitch>

        <cfset NumID = '#rsSEorgAvaliado.pc_org_se#' & NumID & ano>
        <cfset aux_sei = Trim('#arguments.pcNumSEI#')>
        <cfset aux_sei = Replace(aux_sei,'.','',"All")>
        <cfset aux_sei = Replace(aux_sei,'/','','All')>
        <cfset aux_sei = Replace(aux_sei,'-','','All')>


        <!-- Verifica se o processo já existe -->
		<cfif '#arguments.pcProcessoId#' eq '' ><!--Se o processo não existir, cadastra um novo-->
			<cftransaction>
				<cfif '#arguments.idTipoAvaliacao#' neq 0>
					<cfset idDoTipoAvaliacao = '#arguments.idTipoAvaliacao#'>
				<cfelse>
					<!--cadastrar novo tipo de avaliação na tabela pc_avaliacao_tipos-->
					<cfquery datasource="#application.dsn_processos#" name="rsCadastraTipoAvaliacao">
						INSERT pc_avaliacao_tipos (pc_aval_tipo_status, pc_aval_tipo_macroprocessos,pc_aval_tipo_processoN1,pc_aval_tipo_processoN2,pc_aval_tipo_processoN3,pc_aval_tipo_comentario)
						VALUES ('A','#arguments.textoSelectDinamicoMACROPROCESSOS#','#arguments.textoSelectDinamicoPROCESSOSN1#','#arguments.textoSelectDinamicoPROCESSOSN2#','#arguments.textoProcessoN3#','#arguments.textoComentarioProcessoN3#')
						SELECT SCOPE_IDENTITY() AS newID;
					</cfquery>
					<cfset idDoTipoAvaliacao = '#rsCadastraTipoAvaliacao.newID#'>
				</cfif>
				
				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_processos (pc_processo_id, pc_usu_matricula_cadastro, pc_datahora_cadastro, pc_num_sei, pc_num_orgao_origem, pc_num_rel_sei, pc_num_orgao_avaliado, pc_num_avaliacao_tipo, pc_aval_tipo_nao_aplica_descricao,pc_num_classificacao, pc_data_inicioAvaliacao, pc_data_fimAvaliacao, pc_num_status, pc_alteracao_datahora, pc_alteracao_login, pc_usu_matricula_coordenador,pc_usu_matricula_coordenador_nacional, pc_Modalidade,pc_tipo_demanda, pc_ano_pacin, pc_iniciarBloqueado)
					VALUES 
						(
						<cfqueryparam value="#NumID#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">, 
						<cfqueryparam value="#aux_sei#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcOrigem#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcNumRelatorio#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcOrgaoAvaliado#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#idDoTipoAvaliacao#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcTipoAvalDescricao#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcTipoClassificacao#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcDataInicioAvaliacao#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcDataFimAvaliacao#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcNumStatus#" cfsqltype="cf_sql_integer">, 
						<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">, 
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcCoordenador#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcCoordNacional#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcModalidade#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcTipoDemanda#" cfsqltype="cf_sql_varchar">, 
						<cfqueryparam value="#arguments.pcAnoPacin#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pcBloquear#" cfsqltype="cf_sql_varchar">
						)

				</cfquery> 	
		

				<!--Cadastra avaliadores -->

				<cfloop list="#arguments.pcAvaliadores#" index="i">  
					<cfset matriculaAvaliador = '#i#'>
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_avaliadores (pc_avaliador_matricula,  pc_avaliador_id_processo)
						VALUES ('#matriculaAvaliador#',  '#NumID#')
					</cfquery>
				</cfloop>

				<!--Cadastra objetivos estratégicos -->
				<cfloop list="#arguments.pcObjetivoEstrategico#" index="i">  
					<cfset objEstrategico = '#i#'>
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_processos_objEstrategicos (pc_processo_id, pc_objEstrategico_id)
						VALUES ('#NumID#','#objEstrategico#')
					</cfquery>
				</cfloop>

				<!--Cadastra riscos estratégicos -->
				<cfloop list="#arguments.pcRiscoEstrategico#" index="i">  
					<cfset riscoEstrategico = '#i#'>
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_processos_riscosEstrategicos (pc_processo_id, pc_riscoEstrategico_id)
						VALUES ('#NumID#','#riscoEstrategico#')
					</cfquery>
				</cfloop>

				<!--Cadastra IndEstrategico -->
				<cfloop list="#arguments.pcIndEstrategico#" index="i">  
					<cfset indEstrategico = '#i#'>
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_processos_IndEstrategicos (pc_processo_id, pc_indEstrategico_id)
						VALUES ('#NumID#','#indEstrategico#')
					</cfquery>
				</cfloop>
			</cftransaction>
		<cfelse><!--Se o processo existir, edita o processo-->
			<cftransaction>	
			    <cfif '#arguments.idTipoAvaliacao#' neq 0>
					<cfset idDoTipoAvaliacao = '#arguments.idTipoAvaliacao#'>
				<cfelse>
					<!--cadastrar novo tipo de avaliação na tabela pc_avaliacao_tipos-->
					<cfquery datasource="#application.dsn_processos#" name="rsCadastraTipoAvaliacao">
						INSERT pc_avaliacao_tipos (pc_aval_tipo_status, pc_aval_tipo_macroprocessos,pc_aval_tipo_processoN1,pc_aval_tipo_processoN2,pc_aval_tipo_processoN3,pc_aval_tipo_comentario)
						VALUES ('A','#arguments.textoSelectDinamicoMACROPROCESSOS#','#arguments.textoSelectDinamicoPROCESSOSN1#','#arguments.textoSelectDinamicoPROCESSOSN2#','#arguments.textoProcessoN3#','#arguments.textoComentarioProcessoN3#')
						SELECT SCOPE_IDENTITY() AS newID;
					</cfquery>
					<cfset idDoTipoAvaliacao = '#rsCadastraTipoAvaliacao.newID#'>
				</cfif>
				<!--Se o processos existir mas ano da data de início da avaliação ou a SE do órgão avaliado foi alterada, um novo processo é cadastrado e o processo antigo é excluído-->
				<cfquery datasource="#application.dsn_processos#" name="qProcessoEditar">
					SELECT pc_data_inicioAvaliacao, pc_org_se  FROM pc_processos 
					INNER JOIN pc_orgaos ON pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
					WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset anoAntes = year(#qProcessoEditar.pc_data_inicioAvaliacao#)>
				<cfset seAntes = '#qProcessoEditar.pc_org_se#'>
				<cfset seDepois = '#rsSEorgAvaliado.pc_org_se#'>

				<cfif anoAntes neq ano or seAntes neq seDepois>
					<cftransaction>
				
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_processos (pc_processo_id, pc_usu_matricula_cadastro, pc_datahora_cadastro, pc_num_sei, pc_num_orgao_origem, pc_num_rel_sei, pc_num_orgao_avaliado, pc_num_avaliacao_tipo, pc_aval_tipo_nao_aplica_descricao,pc_num_classificacao, pc_data_inicioAvaliacao, pc_data_fimAvaliacao, pc_num_status, pc_alteracao_datahora, pc_alteracao_login, pc_usu_matricula_coordenador,pc_usu_matricula_coordenador_nacional, pc_Modalidade,pc_tipo_demanda, pc_ano_pacin, pc_iniciarBloqueado)
							VALUES (
									<cfqueryparam value="#NumID#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
									<cfqueryparam value="#aux_sei#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcOrigem#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcNumRelatorio#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcOrgaoAvaliado#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#idDoTipoAvaliacao#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcTipoAvalDescricao#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcTipoClassificacao#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcDataInicioAvaliacao#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcDataFimAvaliacao#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcNumStatus#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
									<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcCoordenador#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcCoordNacional#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcModalidade#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcTipoDemanda#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcAnoPacin#" cfsqltype="cf_sql_varchar">,
									<cfqueryparam value="#arguments.pcBloquear#" cfsqltype="cf_sql_varchar">
								)

						
						
						</cfquery> 	
				

						<!--Cadastra avaliadores -->
						<cfloop list="#arguments.pcAvaliadores#" index="i">  
							<cfset matriculaAvaliador = '#i#'>
							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_avaliadores (pc_avaliador_matricula,  pc_avaliador_id_processo)
								VALUES ('#matriculaAvaliador#',  '#NumID#')
							</cfquery>
						</cfloop>
						<!--Cadastra objetivos estratégicos -->
						<cfloop list="#arguments.pcObjetivoEstrategico#" index="i">  
							<cfset objEstrategico = '#i#'>
							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_processos_objEstrategicos (pc_processo_id, pc_objEstrategico_id)
								VALUES ('#NumID#','#objEstrategico#')
							</cfquery>
						</cfloop>

						<!--Cadastra riscos estratégicos -->
						<cfloop list="#arguments.pcRiscoEstrategico#" index="i">  
							<cfset riscoEstrategico = '#i#'>
							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_processos_riscosEstrategicos (pc_processo_id, pc_riscoEstrategico_id)
								VALUES ('#NumID#','#riscoEstrategico#')
							</cfquery>
						</cfloop>

						<!--Cadastra IndEstrategico -->
						<cfloop list="#arguments.pcIndEstrategico#" index="i">  
							<cfset indEstrategico = '#i#'>
							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_processos_IndEstrategicos (pc_processo_id, pc_indEstrategico_id)
								VALUES ('#NumID#','#indEstrategico#')
							</cfquery>
						</cfloop>

						<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliadores">
							DELETE FROM pc_avaliadores
							WHERE pc_avaliadores.pc_avaliador_id_processo = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery> 

						<cfquery datasource="#application.dsn_processos#" name="DeletaObjEstrategicos">
							DELETE FROM pc_processos_objEstrategicos
							WHERE pc_processos_objEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery>

						<cfquery datasource="#application.dsn_processos#" name="DeletaRiscosEstrategicos">
							DELETE FROM pc_processos_riscosEstrategicos
							WHERE pc_processos_riscosEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery>

						<cfquery datasource="#application.dsn_processos#" name="DeletaindEstrategicos">
							DELETE FROM pc_processos_indEstrategicos
							WHERE pc_processos_indEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery>
					
						<cfquery datasource="#application.dsn_processos#" name="DeletaProcessos">
							DELETE FROM pc_processos
							WHERE pc_processos.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery>
					</cftransaction>	
				<!--Se nem o ano de início da avaliação e nem o órgão avaliado for alterado, editar o processo normalmente-->
				<cfelse>
					
						<cfquery datasource="#application.dsn_processos#" >
							UPDATE pc_processos
							SET pc_num_sei = <cfqueryparam value="#aux_sei#" cfsqltype="cf_sql_varchar">,
								pc_num_orgao_origem = <cfqueryparam value="#arguments.pcOrigem#" cfsqltype="cf_sql_varchar">,
								pc_num_rel_sei = <cfqueryparam value="#arguments.pcNumRelatorio#" cfsqltype="cf_sql_varchar">,
								pc_num_orgao_avaliado = <cfqueryparam value="#arguments.pcOrgaoAvaliado#" cfsqltype="cf_sql_varchar">,
								pc_num_avaliacao_tipo = <cfqueryparam value="#idDoTipoAvaliacao#" cfsqltype="cf_sql_varchar">,
								pc_aval_tipo_nao_aplica_descricao = <cfqueryparam value="#arguments.pcTipoAvalDescricao#" cfsqltype="cf_sql_varchar">,
								pc_Modalidade = <cfqueryparam value="#arguments.pcModalidade#" cfsqltype="cf_sql_varchar">,
								pc_num_classificacao = <cfqueryparam value="#arguments.pcTipoClassificacao#" cfsqltype="cf_sql_varchar">,
								pc_data_inicioAvaliacao = <cfqueryparam value="#arguments.pcDataInicioAvaliacao#" cfsqltype="cf_sql_varchar">,
								pc_data_fimAvaliacao = <cfqueryparam value="#arguments.pcDataFimAvaliacao#" cfsqltype="cf_sql_varchar">,
								pc_alteracao_datahora = <cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP">,
								pc_alteracao_login = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">,
								pc_usu_matricula_coordenador = <cfqueryparam value="#arguments.pcCoordenador#" cfsqltype="cf_sql_varchar">,
								pc_usu_matricula_coordenador_nacional = <cfqueryparam value="#arguments.pcCoordNacional#" cfsqltype="cf_sql_varchar">,
								pc_tipo_demanda = <cfqueryparam value="#arguments.pcTipoDemanda#" cfsqltype="cf_sql_varchar">,
								pc_ano_pacin = <cfqueryparam value="#arguments.pcAnoPacin#" cfsqltype="cf_sql_varchar">,
								pc_iniciarBloqueado = <cfqueryparam value="#arguments.pcBloquear#" cfsqltype="cf_sql_varchar">
							WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar"> 



						</cfquery> 	

						<cfquery datasource="#application.dsn_processos#" >
							DELETE FROM pc_avaliadores
							WHERE pc_avaliador_id_processo= <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery> 	


						<cfloop list="#arguments.pcAvaliadores#" index="i">  
							<cfset matriculaAvaliador = '#i#'>
							<cfif '#matriculaAvaliador#' eq  "#arguments.pcCoordenador#">
								<cfset coordena ='S'>
							<cfelse>
								<cfset coordena ='N'>
							</cfif>

							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_avaliadores (pc_avaliador_matricula, pc_avaliador_id_processo)
								VALUES ('#matriculaAvaliador#', <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar"> )
							</cfquery>
						</cfloop>


						<cfquery datasource="#application.dsn_processos#" >
							DELETE FROM pc_processos_objEstrategicos
							WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery>

						<cfloop list="#arguments.pcObjetivoEstrategico#" index="i">  
							<cfset objEstrategico = '#i#'>
							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_processos_objEstrategicos (pc_processo_id, pc_objEstrategico_id)
								VALUES ('#arguments.pcProcessoId#','#objEstrategico#')
							</cfquery>
						</cfloop>

						<cfquery datasource="#application.dsn_processos#" >
							DELETE FROM pc_processos_riscosEstrategicos
							WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery>

						<cfloop list="#arguments.pcRiscoEstrategico#" index="i">  
							<cfset riscoEstrategico = '#i#'>
							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_processos_riscosEstrategicos (pc_processo_id, pc_riscoEstrategico_id)
								VALUES ('#arguments.pcProcessoId#','#riscoEstrategico#')
							</cfquery>
						</cfloop>

						<cfquery datasource="#application.dsn_processos#" >
							DELETE FROM pc_processos_indEstrategicos
							WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
						</cfquery>

						<!--Cadastra IndEstrategico -->
						<cfloop list="#arguments.pcIndEstrategico#" index="i">  
							<cfset indEstrategico = '#i#'>
							<cfquery datasource="#application.dsn_processos#">
								INSERT pc_processos_IndEstrategicos (pc_processo_id, pc_indEstrategico_id)
								VALUES ('#arguments.pcProcessoId#','#indEstrategico#')
							</cfquery>
						</cfloop>
					
				</cfif>
			</cftransaction>
        </cfif>


		<cfreturn true />
	</cffunction>











	<cffunction name="delProc"   access="remote" returntype="boolean">
		<cfargument name="numProc" type="string" required="true" />

			<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliadores">
				DELETE FROM pc_avaliadores
				WHERE pc_avaliadores.pc_avaliador_id_processo = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="DeletaObjEstrategicos">
				DELETE FROM pc_processos_objEstrategicos
				WHERE pc_processos_objEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" name="DeletaRiscosEstrategicos">
				DELETE FROM pc_processos_riscosEstrategicos
				WHERE pc_processos_riscosEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" name="DeletaIndEstrategico">
				DELETE FROM pc_processos_IndEstrategicos
				WHERE pc_processos_IndEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery>
				
		
			<cfquery datasource="#application.dsn_processos#" name="DeletaProcessos">
				DELETE FROM pc_processos
				WHERE pc_processos.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar"> and  pc_num_status = '2'
			</cfquery>

		<cfreturn true />
	</cffunction>










	<cffunction name="reativarProc"   access="remote" returntype="boolean">
		<cfargument name="numProc" type="string" required="true" default=""/>
		
			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_processos SET  pc_num_status = '2'
				, 
				pc_alteracao_login = '#application.rsUsuarioParametros.pc_usu_login#'
				, 
				pc_alteracao_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				WHERE pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery> 	 	
			

		<cfreturn true />
	</cffunction>






	
	<cffunction name="cardsProcessos" returntype="any" access="remote" hint="Criar os cards dos processos e envia para a páginas pc_CadastroProcesso">
	   

		<cfquery name="rsProcCard" datasource="#application.dsn_processos#">
			SELECT pc_processos.*,pc_orgaos.pc_org_descricao,pc_orgaos.pc_org_sigla, pc_status.*,pc_avaliacao_tipos.pc_aval_tipo_descricao
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
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11> 
				WHERE  pc_num_status=2
			<cfelseif #application.rsUsuarioParametros.pc_usu_perfil# eq 8>
		   		WHERE  pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' and pc_num_status=2
			<cfelseif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#)>
			    WHERE  pc_num_orgao_origem IN('00436698','00436697','00438080') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)) and pc_num_status=2
			<cfelse>
				WHERE  pc_status.pc_status_id = 0
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
							<div class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i>Processos Cadastrados
										</a>
									</h4>
								</div>
								<div id="collapseTwo" class="" data-parent="#accordion">							
									<div class="card-body" style="border: solid 3px #ffD400;width:100%">
										
										<div class="row" style="justify-content: space-around;">
											<cfif #rsProcCard.recordcount# eq 0 >
												<h4>Nenhum processo na fase de cadastro foi localizado</h4>
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

																	<tr style="width:270px;border:none;">
																		<td style="background: none;border:none;white-space:normal!important;" >	
																			<section class="content" >
																					<div id="processosAcompanhamento" class="container-fluid" >

																							<div class="row">
																								<div id="cartao" style="width:270px;" >
																								
																									<!-- small card -->
																									<div class="small-box " style="<cfoutput>#pc_status_card_style_header#</cfoutput> font-weight: normal;">
																										<cfif #pc_iniciarBloqueado# eq "S">
																									  	  <i id="btBloquear" class="fas fa-lock grow-icon" style="position:absolute;color: red;left: 2px;top:2px;z-index:1" data-toggle="popover" data-trigger="hover" data-placement="top" title="Processo Bloqueado" data-content="O encaminhamento ao órgão avaliado só ocorrerá após o seu desbloqueio."></i>
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
																											<p style="font-size:1em;margin-bottom: 0rem!important;"><cfoutput>Processo n°: #pc_processo_id#</cfoutput></p>
																											<p style="font-size:1em;margin-bottom: 0rem!important;"><cfoutput>#pc_org_sigla#</cfoutput></p>
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
																												<i  class="fas fa-trash-alt efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'" style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoDel(<cfoutput>'#pc_processo_id#'</cfoutput>);" data-toggle="popover" data-trigger="hover" 	data-placement="bottom" data-content="Excluir" ></i>
																												<i id="btEdit" class="fas fa-edit efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'"  style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoEditarCard(<cfoutput>'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#pc_iniciarBloqueado#','#objetivosEstrategicos#','#riscosEstrategicos#','#indEstrategicos#')</cfoutput>;" data-toggle="popover" data-trigger="hover" 	data-placement="bottom" data-content="Editar"></i>
																												<i  class="fas fa-eye efeito-grow"   onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'" style="z-index:100;cursor: pointer;font-size:20px" onclick="javascript:processoVisualizar(<cfoutput>'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#pc_iniciarBloqueado#','#objetivosEstrategicos#','#riscosEstrategicos#','#indEstrategicos#')</cfoutput>;" data-toggle="popover" data-trigger="hover" 	data-placement="bottom" data-content="Visualizar"></i>
																												<i id="btCopia" class="fas fa-copy efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'"  style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoCopiarCard(<cfoutput>'#pc_processo_id#','#pc_num_orgao_origem#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#objetivosEstrategicos#','#riscosEstrategicos#','#indEstrategicos#')</cfoutput>;" data-toggle="popover" data-trigger="hover" 	data-placement="bottom" data-content="Copiar"></i>
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
				$('[data-toggle="popover"]').popover()
			})	
			$('.popover-dismiss').popover({
				trigger: 'hover'
			})

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

			function processoDel(numProcesso) {
							
					event.preventDefault()
					event.stopPropagation()
					
					
					var mensagem = "Deseja excluir este processo?";
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
										type: "GET",
										url: "cfc/pc_cfcProcessos.cfc",
										data:{
											method: "delProc",
											numProc: numProcesso
										},
									async: false

									})//fim ajax
									.done(function(result) {
										
										if(localStorage.getItem('mostraTab') =='1'){
											exibirTabela()	
										}else{
											ocultarTabela()	
										}	

										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											toastr.success('Operação realizada com sucesso!');
										});
										exibirFormCadProcesso();//function que consta na página pc_Processos.cfm	
										$('html, body').animate({
											scrollTop: $('#bodyPrincipal').offset().top - 80
										},'slow');
										
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
									
						});	
			}
			
			function processoEditarCard(processoId, sei, relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin, bloquear, objetivoEstrategico, riscoEstrategico, indEstrategico) {
				event.preventDefault()
				event.stopPropagation()
				
				exibirFormCadProcesso();//function que consta na página pc_Processos.cfm	
				$('.step-trigger').show();
				
				setTimeout(function() {	
					var listAvaliadores = avaliadores.split(",");
					var listObjetivoEstrategico = objetivoEstrategico.split(",");
					var listRiscoEstrategico = riscoEstrategico.split(",");
					var listIndEstrategico = indEstrategico.split(",");
					$('#cabecalhoAccordion').text("Editar o Processo:" + ' ' + processoId);
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
					

					$('#pcBloquear').val(bloquear).trigger('change');
					
					//popula os selects dinâmicos	
					$.ajax({
						url: 'cfc/pc_cfcAvaliacoes.cfc',
						data: {
							method: 'getAvaliacaoTipos',
						},
						dataType: "json",
						method: 'GET'
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
				
						$('html, body').animate({
							scrollTop: $('#cadastro').offset().top - 80
						},'slow');
					})
					.fail(function(error) {
						$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(error)
					});
					//fim popula os selects dinâmicos
				
					
				}, 1000);
			}


			function processoVisualizar(processoId,sei,relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin,bloquear, objetivoEstrategico, riscoEstrategico, indEstrategico) {
				event.preventDefault()
				event.stopPropagation()
				exibirFormCadProcesso();//function que consta na página pc_Processos.cfm	
				$('.step-trigger').show();
				setTimeout(function() {		
					var listAvaliadores = avaliadores.split(",");
					var listObjetivoEstrategico = objetivoEstrategico.split(",");
					var listRiscoEstrategico = riscoEstrategico.split(",");
					var listIndEstrategico = indEstrategico.split(",");

					$('#cabecalhoAccordion').text("Visualizando o Processo:" + ' ' + processoId);
					$('#infoTipoCadastro').html("Visualizando o Processo <strong>" + processoId + "</strong>");
					$("#btSalvar").attr("hidden",true);
					$("#mensagemSalvar").attr("hidden",true);
					$('#pcDataInicioAvaliacao').removeAttr('disabled');
					$('#pcOrgaoAvaliado').removeAttr('disabled');
					
					$('#pcModalidade').val(modalidade).trigger('change');

					$('#pcNumSEI').val(sei).trigger('change');
					$('#pcProcessoId').val(processoId).trigger('change');			
					$('#pcTipoClassificacao').val(classificacao).trigger('change');
					$('#pcNumRelatorio').val(relSei).trigger('change');
					$('#pcOrigem').val(orgaoOrigem).trigger('change');
					$('#pcDataInicioAvaliacao').val(dataInicio).trigger('change');
					$('#pcDataFimAvaliacao').val(dataFim).trigger('change');
					$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');

					$('#pcOrgaoAvaliado').val(orgaoAvaliado).trigger('change');
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
					$('#pcTipoDemanda').val(tipoDemanda).trigger('change');
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

					//popula os selects dinâmicos	
					$.ajax({
						url: 'cfc/pc_cfcAvaliacoes.cfc',
						data: {
							method: 'getAvaliacaoTipos',
						},
						dataType: "json",
						method: 'GET'
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
					})
					.fail(function(error) {
						$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(error)
					});
					//fim popula os selects dinâmicos

					$('#pcBloquear').val(bloquear).trigger('change');
				
					$('#cadastro').CardWidget('expand')
				
					$('html, body').animate({
						scrollTop: $('#cadastro').offset().top - 80
					});

				}, 1000);
		
			}

			function processoCopiarCard(processoId, orgaoOrigem, processoAvaliado, naoAplicaDesc, modalidade, tipoDemanda, anoPacin, objetivoEstrategico, riscoEstrategico, indEstrategico) {
				event.preventDefault()
				event.stopPropagation()
				
				exibirFormCadProcesso();//function que consta na página pc_Processos.cfm	
				$('.step-trigger').show();
				
				setTimeout(function() {	
                    $('#infoTipoCadastro').html("Cadastrando Novo Processo (copiadas algumas informações do Processo <strong>" + processoId + "</strong>)");
					var listObjetivoEstrategico = objetivoEstrategico.split(",");
					var listRiscoEstrategico = riscoEstrategico.split(",");
					var listIndEstrategico = indEstrategico.split(",");

					$("#btSalvar").attr("hidden",false);

					$("#mensagemSalvar").attr("hidden",false);
					
					$('#pcModalidade').val(modalidade).trigger('change');

					$('#pcOrigem').val(orgaoOrigem).trigger('change');
				
					$('#pcTipoDemanda').val(tipoDemanda).trigger('change');
					
					if (tipoDemanda == 'E'){
						anoPacin = null;
					}
					$('#pcAnoPacin').val(anoPacin).trigger('change');
						


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
					
					
					//popula os selects dinâmicos	
					$.ajax({
						url: 'cfc/pc_cfcAvaliacoes.cfc',
						data: {
							method: 'getAvaliacaoTipos',
						},
						dataType: "json",
						method: 'GET'
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
				
						$('html, body').animate({
							scrollTop: $('#cadastro').offset().top - 80
						},'slow');
					})
					.fail(function(error) {
						$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(error)
					});
					//fim popula os selects dinâmicos
				
				}, 1000);
             
			}
		</script>
	</cffunction>








    
	<cffunction name="tabProcessos" returntype="any" access="remote" hint="Criar a tabela dos processos e envia para a páginas pc_CadastroProcesso e pc_CadastroAvaliacoesPainel">
	   
	           
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao, pc_usuarios.pc_usu_nome, pc_usuCoodNacional.pc_usu_nome as nome_coordenadorNacional
						, pc_usuCoodNacional.pc_usu_matricula as matricula_coordenadorNacional

			FROM        pc_processos  INNER JOIN
                        pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
                        pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
                        pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
                        pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
                        pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id LEFT JOIN
						pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula LEFT JOIN
						pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11> 
				WHERE  pc_num_status=2
			<cfelseif #application.rsUsuarioParametros.pc_usu_perfil# eq 8>
		   		WHERE  pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' and pc_num_status=2
			<cfelseif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#)>
			    WHERE  pc_num_orgao_origem IN('00436698','00436697','00438080') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)) and pc_num_status=2
			<cfelse>
				WHERE  pc_status.pc_status_id = 0
			</cfif>
			ORDER BY 	pc_processos.pc_processo_id DESC	
		</cfquery>
		
		
		
		            
			<div class="row">
				<div class="col-12">
					<div class="card">
						<!-- /.card-header -->
						<div class="card-body">
							<table id="tabProcessos" class="table table-bordered table-striped table-hover text-nowrap">
							<thead style="background: #0083ca;color:#fff">
								<tr style="font-size:14px">
									<th class="sorting_disabled">Controles</th>
									<th>N°Processo SNCI:</th>
									<th >SE/CS:</th>
									<th>Ano PACIN: </th>
									<th>Data Início Avaliação: </th>
									<th>Data Fim Avaliação: </th>
									<th>Status: </th>
									<th>N°SEI: </th>
									<th>N°Relat. SEI: </th>
									<th>Órgão Origem: </th>
									<th>Órgão Avaliado: </th>
									<th>Tipo de Avaliação: </th>
									<th>Modalidade:</th>
									<th>Classificação: </th>
									<th>Coordenador Regional: </th>
									<th>Coordenador Nacional: </th>
									<th>Avaliadores: </th>
									<th>Tipo Demanda: </th>
									<th>Data Hora Cadastro: </th>
									<th>Data Hora Alteração: </th>


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


									
									<!-- para polular select multiplo-->
									<cfset avaliadoresSelect = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>

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



								

									<cfoutput>					
										<tr style="font-size:12px">
											<td>
												<div style="display:flex;justify-content:space-around;border:none">
													<i  class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:1;font-size:16px" onclick="javascript:processoDel(<cfoutput>'#pc_processo_id#'</cfoutput>);" data-toggle="tooltip"  tilte="Excluir" ></i>	
													<i class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:1;font-size:16px"  onclick="javascript:processoEditarTab(this,'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadoresSelect#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#pc_iniciarBloqueado#','#objetivosEstrategicos#','#riscosEstrategicos#','#indEstrategicos#')" data-toggle="tooltip"  tilte="Editar"></i>
													
												</div>
											</td>
											<td>
												#pc_processo_id#
												<cfif #pc_iniciarBloqueado# eq "S">
													<i id="btBloquear" class="fas fa-lock grow-icon" style="color:##000;left: 2px;z-index:1" data-toggle="popover" data-trigger="hover" data-placement="bottom" title="Processo Bloqueado" data-content="O encaminhamento ao órgão avaliado só ocorrerá após o seu desbloqueio."></i>
												</cfif>
											</td>
											<td>#seOrgAvaliado#</td>
											<td>#pc_ano_pacin#</td>
											<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
											<td>#dataInicio#</td>
											<cfif #pc_Modalidade# eq 'A' or #pc_Modalidade# eq 'E'>
												<cfset dataFim = DateFormat(#pc_data_fimAvaliacao#,'DD-MM-YYYY') >
												<td>#dataFim#</td>
											<cfelse>
												<td>NÃO FINALIZADO</td>
											</cfif>
											<td>#pc_status_descricao#</td>
											<cfif #pc_Modalidade# eq 'A' or #pc_Modalidade# eq 'E'>
												<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
												<td>#sei#</td>
												<td>#pc_num_rel_sei#</td>
											<cfelse>
												<td>NÃO</td>
												<td>NÃO</td>
											</cfif>
											<td>#siglaOrgOrigem#</td>
											<td>#siglaOrgAvaliado#</td>

											
											<cfif pc_num_avaliacao_tipo neq 2>
												<td>#pc_aval_tipo_descricao#</td>
											<cfelse>
												<td>#pc_aval_tipo_nao_aplica_descricao#</td>
											</cfif>

											<td>
												<cfif #pc_Modalidade# eq 'A'>
													Acompanhamento
												<cfelseif #pc_Modalidade# eq 'E'>
												    ENTREGA DO RELATÓRIO
												<cfelse>
													Normal
												</cfif>
											</td>
											<td>#pc_class_descricao#</td>
											<td>#pc_usu_nome# (#pc_usu_matricula_coordenador#)</td>
											<td>#nome_coordenadorNacional# (#matricula_coordenadorNacional#)</td>
											<td>#avaliadores#</td>
											<cfset dataHoraCadastro = DateFormat(#pc_datahora_cadastro#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_datahora_cadastro#,'HH:mm:ss') & ')'>
											<cfif #pc_tipo_demanda# eq 'P'>
												<td>PLANEJADA</td>
											<cfelseif #pc_tipo_demanda# eq 'E'>
												<td>EXTRAORDINÁRIA</td>
											<cfelse>
										    	<td>Não informado</td>
											</cfif>

											<td>#dataHoraCadastro#</td>
											<cfset dataHoraAlteracao = DateFormat(#pc_alteracao_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_alteracao_datahora#,'HH:mm:ss') & ')'>
											<td>#dataHoraAlteracao# - #pc_alteracao_login#</td>
											

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
				$('[data-toggle="popover"]').popover()
			})	
			$('.popover-dismiss').popover({
				trigger: 'hover'
			})
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	
			$(function () {
				$('#tabProcessos').DataTable( {
					columnDefs: [
						{ "orderable": false, "targets": [0] }//impede que a primeira coluna seja ordenada
					],
					order: [[ 1, "desc" ]],
					responsive: true, 
					lengthChange: true, 
					autoWidth: false,
					select: true,
					stateSave:true,
					buttons: [{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
							title : 'SNCI_Processos_cadastrados_' + d,
							className: 'btExcel',
						},],
				}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');

				
			} );

			function processoDel(numProcesso) {
							
					event.preventDefault()
					event.stopPropagation()
					
					
					var mensagem = "Deseja excluir este processo?";
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
										type: "GET",
										url: "cfc/pc_cfcProcessos.cfc",
										data:{
											method: "delProc",
											numProc: numProcesso
										},
									async: false

									})//fim ajax
									.done(function(result) {
										
										if(localStorage.getItem('mostraTab') =='1'){
											exibirTabela()	
										}else{
											ocultarTabela()	
										}	

										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											toastr.success('Operação realizada com sucesso!');
										});
										exibirFormCadProcesso();//function que consta na página pc_Processos.cfm
										
										
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
									
						});	
			}
			
			function processoEditarTab(linha,processoId, sei, relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin,bloquear, objetivoEstrategico, riscoEstrategico, indEstrategico) {
				event.preventDefault()
				event.stopPropagation()
				exibirFormCadProcesso();//function que consta na página pc_Processos.cfm
				$('.step-trigger').show();
				setTimeout(function() {	
					$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
					var listAvaliadores = avaliadores.split(",");
					var listObjetivoEstrategico = objetivoEstrategico.split(",");
					var listRiscoEstrategico = riscoEstrategico.split(",");
					var listIndEstrategico = indEstrategico.split(",");
					$('#cabecalhoAccordion').text("Editar o Processo:" + ' ' + processoId);
					$("#btSalvar").attr("hidden",false);
					$("#mensagemSalvar").attr("hidden",false);
					
					$('#pcModalidade').val(modalidade).trigger('change');

					$('#pcNumSEI').val(sei);
					$('#pcProcessoId').val(processoId);			
					$('#pcTipoClassificacao').val(classificacao).trigger('change');
					$('#pcNumRelatorio').val(relSei);
					$('#pcOrigem').val(orgaoOrigem).trigger('change');
					$('#pcDataInicioAvaliacao').val(dataInicio);
					$('#pcDataInicioAvaliacaoAnterior').val(dataInicio);
					$('#pcDataFimAvaliacao').val(dataFim);
					
					

					$('#pcOrgaoAvaliado').val(orgaoAvaliado).trigger('change');
					$('#pcOrgaoAvaliadoAnterior').val(orgaoAvaliado);
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

					//popula os selects dinâmicos	
					$.ajax({
						url: 'cfc/pc_cfcAvaliacoes.cfc',
						data: {
							method: 'getAvaliacaoTipos',
						},
						dataType: "json",
						method: 'GET'
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
						// Define os IDs dos selects
						
						const exampleID = processoAvaliado; // Mude para o ID desejado
						populateSelectsFromID(data, exampleID, dataLevels, 'idTipoAvaliacao');
					})
					.fail(function(error) {
						$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(error)
					});
					//fim popula os selects dinâmicos
					
					$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');
					
					$('#pcBloquear').val(bloquear).trigger('change');
				
					$('#cadastro').CardWidget('expand')

					$('html, body').animate({scrollTop: $('#cadastro').offset().top - 80});

				}, 1000);

			}


		</script>	
	

	</cffunction>









	
	<cffunction name="mudarPerfil"   access="remote" returntype="boolean" hint="Mudar o perfil do usuário na páginas pc_sedebar.cfm. Só é possível essa utilização nos servidores de desenvolvimento e homologação">
		<cfargument name="perfil" type="numeric" required="true" default=""/>
		
			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_usuarios SET pc_usu_perfil = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.perfil#">
				WHERE pc_usu_login = '#application.rsUsuarioParametros.pc_usu_login#'
			</cfquery> 	 	
			

		<cfreturn true />
	</cffunction>






	<cffunction name="mudarLotacao"   access="remote" returntype="boolean" hint="Mudar a lotação do usuário na páginas pc_sedebar.cfm. Só é possível essa utilização nos servidores de desenvolvimento e homologação">
		<cfargument name="lotacao" type="string" required="true" default=""/>
		
			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_usuarios SET pc_usu_lotacao = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#arguments.lotacao#">
				WHERE pc_usu_login = '#application.rsUsuarioParametros.pc_usu_login#'
			</cfquery> 	 	
			

		<cfreturn true />
	</cffunction>






 
	

	<cffunction name="tabProcessosTODOS" returntype="any" access="remote" hint="Criar a tabela de todos processos e envia para a páginas pc_apoioDeletaProcessos.APENAS PARA DESENVOLVEDORES">
	    <cfargument name="status" type="string" required="false" default=""/> 
        <!--Só retorna os processos que não tem posicionamentos do órgão avaliado-->
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao, pc_usuarios.pc_usu_nome

			FROM        pc_processos  LEFT OUTER JOIN
                        pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
                        pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
                        pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
                        pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
                        pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id left JOIN
						pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
			<cfif FindNoCase("intranetsistemaspe", application.auxsite)>			
				WHERE      NOT pc_processos.pc_processo_id in ( SELECT DISTINCT pc_avaliacoes.pc_aval_processo FROM pc_avaliacoes
								LEFT JOIN pc_avaliacao_orientacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
								LEFT JOIN pc_avaliacao_posicionamentos ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
								WHERE pc_avaliacao_posicionamentos.pc_aval_posic_status = 3
							)
			</cfif>     		
			ORDER BY 	pc_processos.pc_processo_id DESC	
		</cfquery>
		
		
		

            
			<div class="row">
				<div class="col-12">
					<div class="card">
					
						<!-- /.card-header -->
						<div class="card-body">
							<table id="tabProcessos" class="table table-bordered table-striped table-hover text-nowrap">
							<cfif FindNoCase("intranetsistemaspe", application.auxsite)>
								<h5>Só são listados processos sem posicionamentos de órgãos avaliados.</h5>
							</cfif>
							<thead style="background: #0083ca;color:#fff">
								<tr style="font-size:14px">
									<th>Controles</th>
									<th>N°Processo SNCI:</th>
									<th >SE/CS:</th>
									<th>Data Início: </th>
									<th>Status: </th>
									<th>N°SEI: </th>
									<th>N°Relat. SEI: </th>
									<th>Órgão Origem: </th>
									<th>Órgão Avaliado: </th>
									<th>Tipo de Avaliação: </th>
									<th>Classificação: </th>
									<th>Coordenador: </th>
									<th>Avaliadores: </th>
									<th>Data Hora Cadastro: </th>
									<th>Data Hora Alteração: </th>

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
									
									<!-- para polular select multiplo-->
									<cfset avaliadoresSelect = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>

								

									<cfoutput>					
										<tr style="font-size:12px">
											<td >
												<div style="display:flex;justify-content:space-around;">
													
													
														<i  class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:16px" onclick="javascript:processoDel(<cfoutput>'#pc_processo_id#'</cfoutput>);" data-toggle="tooltip"  tilte="Excluir" ></i>
													
													
												</div>
											</td>
											<td>#pc_processo_id#</td>
											<td>#seOrgAvaliado#</td>
											<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
											<td>#dataInicio#</td>
											<td>#pc_status_descricao#</td>
											<td>#pc_num_sei#</td>
											<td>#pc_num_rel_sei#</td>
											<td>#siglaOrgOrigem#</td>
											<td>#siglaOrgAvaliado#</td>
											<cfif pc_num_avaliacao_tipo neq 2>
												<td>#pc_aval_tipo_descricao#</td>
											<cfelse>
												<td>#pc_aval_tipo_nao_aplica_descricao#</td>
											</cfif>
											<td>#pc_class_descricao#</td>
											<td>#pc_usu_nome#(#pc_usu_matricula_coordenador#)</td>
											<td>#avaliadores#</td>
											<cfset dataHoraCadastro = DateFormat(#pc_datahora_cadastro#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_datahora_cadastro#,'HH:mm:ss') & ')'>
											<td>#dataHoraCadastro#</td>
											<cfset dataHoraAlteracao = DateFormat(#pc_alteracao_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_alteracao_datahora#,'HH:mm:ss') & ')'>
											<td>#dataHoraAlteracao# - #pc_alteracao_login#</td>
											

										</tr>
									</cfoutput>
								</cfloop>	
							</tbody>
								
							<tfoot>
								<tr style="font-size:14px">
									<th>Controles</th>
									<th>N°Processo SNCI</th>
									<th>SE</th>
									<th>Data Início</th>
									<th>Status</th>
									<th>N°SEI</th>
									<th>N°Relat. SEI</th>
									<th>Órgão Origem</th>
									<th>Órgão Avaliado</th>
									<th>Tipo de Avaliação</th>
									<th>Classificação</th>
									<th>Coordenador</th>
									<th>Avaliadores</th>
									<th>Data Hora Cadastro</th>
									<th>Data Hora Alteração</th>
								</tr>
							</tfoot>
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
				$("#tabProcessos").DataTable({
				"destroy": true,
				"stateSave": false,
				"responsive": true, 
				"lengthChange": true, 
				"autoWidth": false,
				"buttons": [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						className: 'btExcel',
					}],
				}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');
					
			});

		</script>	
	

	</cffunction>








	<cffunction name="deletarTodoProcesso"   access="remote" returntype="boolean" hint="Deleta o processo e todos os registros associados. Utilizado apenas pelos desenvolvedores.">
		<cfargument name="numProc" type="string" required="true" default=""/>
			<cftransaction>
				<cfquery datasource="#application.dsn_processos#" name="rsPc_anexos"> 
					SELECT pc_anexos.*, pc_avaliacoes.*    FROM  pc_anexos
					inner join pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_anexos.pc_anexo_avaliacao_id
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfloop query="rsPc_anexos" >

					<cfif FileExists(pc_anexo_caminho)>
						<cffile action = "delete" File = "#pc_anexo_caminho#">
					</cfif>

					<cfquery datasource="#application.dsn_processos#">
						DELETE FROM pc_anexos
						WHERE pc_anexo_id = #pc_anexo_id#
					</cfquery> 	
					
				</cfloop>

				<cfquery datasource="#application.dsn_processos#" name="rsPc_anexosRelatorios"> 
					SELECT pc_anexos.*   FROM  pc_anexos
					WHERE pc_anexo_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfloop query="rsPc_anexosRelatorios" >

					<cfif FileExists(pc_anexo_caminho)>
						<cffile action = "delete" File = "#pc_anexo_caminho#">
					</cfif>

					<cfquery datasource="#application.dsn_processos#">
						DELETE FROM pc_anexos
						WHERE pc_anexo_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
					</cfquery> 	
					
				</cfloop>



				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_categoriasControles">
					DELETE FROM pc_avaliacao_categoriasControles
					FROM pc_avaliacao_categoriasControles
					INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_categoriasControles.pc_aval_id
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_melhoria_categoriasControles">
					DELETE FROM pc_avaliacao_melhoria_categoriasControles 
					FROM pc_avaliacao_melhoria_categoriasControles 
					INNER JOIN pc_avaliacao_melhorias on pc_avaliacao_melhorias.pc_aval_melhoria_id = pc_avaliacao_melhoria_categoriasControles .pc_aval_melhoria_id
					INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_melhorias.pc_aval_melhoria_num_aval
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_orientacao_categoriasControles">
					DELETE FROM pc_avaliacao_orientacao_categoriasControles 
					FROM pc_avaliacao_orientacao_categoriasControles 
					INNER JOIN pc_avaliacao_orientacoes on pc_avaliacao_orientacoes.pc_aval_orientacao_id = pc_avaliacao_orientacao_categoriasControles.pc_aval_orientacao_id
					INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_riscos">
					DELETE FROM pc_avaliacao_riscos
					FROM pc_avaliacao_riscos
					INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_riscos.pc_aval_id
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_avaliacao_tiposControles">
					DELETE FROM pc_avaliacao_tiposControles
					FROM pc_avaliacao_tiposControles
					INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_avaliacao_tiposControles.pc_aval_id
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_processos_indEstrategicos">
					DELETE FROM pc_processos_indEstrategicos
					WHERE pc_processos_indEstrategicos.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_processos_objEstrategicos">
					DELETE FROM pc_processos_objEstrategicos
					WHERE pc_processos_objEstrategicos.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>

				<cfquery datasource="#application.dsn_processos#" name="Deleta_pc_processos_riscosEstrategicos">
					DELETE FROM pc_processos_riscosEstrategicos
					WHERE pc_processos_riscosEstrategicos.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>






				<cfquery datasource="#application.dsn_processos#" name="DeletaValidacoes">
					DELETE FROM pc_validacoes_chat
					FROM pc_validacoes_chat INNER JOIN pc_avaliacoes on pc_aval_id = pc_validacao_chat_num_aval
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 

				<cfquery datasource="#application.dsn_processos#" name="DeletaValidacoes">
					DELETE FROM pc_avaliacao_versoes
					FROM pc_avaliacao_versoes INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_versao_num_aval
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 

				
				<cfquery datasource="#application.dsn_processos#" name="DeletaMelhorias">
					DELETE FROM pc_avaliacao_melhorias
					FROM        pc_avaliacao_melhorias 
					INNER JOIN  pc_avaliacoes ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 	

			
				<cfquery datasource="#application.dsn_processos#" name="DeletaPosicionamentos">
					DELETE FROM  pc_avaliacao_posicionamentos
					FROM         pc_avaliacao_posicionamentos 
					INNER JOIN   pc_avaliacao_orientacoes on pc_aval_orientacao_id = pc_aval_posic_num_orientacao
					INNER JOIN   pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
					INNER JOIN   pc_processos on pc_processo_id = pc_aval_processo         
					WHERE pc_processo_id  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 

				<cfquery datasource="#application.dsn_processos#" name="DeletaOrientacoes">
					DELETE FROM  pc_avaliacao_orientacoes
					FROM         pc_avaliacao_orientacoes
					INNER JOIN   pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
					INNER JOIN   pc_processos on pc_processo_id = pc_aval_processo         
					WHERE pc_processo_id  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 

				<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliadores">
					DELETE FROM pc_avaliadores
					WHERE pc_avaliadores.pc_avaliador_id_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 

				

				<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliacoes">
					DELETE FROM pc_avaliacoes
					WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 

				<cfquery datasource="#application.dsn_processos#" name="DeletaProcessos">
					DELETE FROM pc_processos
					WHERE pc_processos.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery>
			</cftransaction>
			
				

		<cfreturn true />
	</cffunction>



    <cffunction name="obterDescricaoDoTipoDeProcesso" access="remote" returntype="string" hint="Obter a descrição do tipo de processo">
		<cfargument name="idTipoProcesso" type="numeric" required="true" default=""/>

		<cfquery name="rsTipoProcesso" datasource="#application.dsn_processos#">
			SELECT pc_aval_tipo_comentario
			FROM pc_avaliacao_tipos
			WHERE pc_aval_tipo_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idTipoProcesso#">
		</cfquery>

		<cfset var descricao = "" />

		<cfif rsTipoProcesso.recordCount gt 0>
			<cfset descricao = rsTipoProcesso.pc_aval_tipo_comentario />
		</cfif>

		<!--- Serializa o resultado manualmente em JSON ou texto simples --->
		<cfreturn serializeJSON(descricao) />
	</cffunction>






</cfcomponent>