<cfprocessingdirective pageencoding = "utf-8">

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

<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SNCI</title>
<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">
   
	<!-- iCheck -->
	<link rel="stylesheet" href="plugins/icheck-bootstrap/icheck-bootstrap.min.css">

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

        /*Utilizando na descrição dos tipos de processos nos cards, para não ultrapassar o conteiner*/
		.text-ellipsis {
			font-size: 10px!important;
			margin-bottom: 0!important;
			display: -webkit-box!important;
			-webkit-box-orient: vertical!important;
			overflow: hidden!important;
			text-overflow: ellipsis!important;
			-webkit-line-clamp: 6!important; /* Número de linhas que você quer exibir antes das reticências */
			line-height: 1.1;
		}


	 </style>
	 <!-- animate.css -->
    <link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/animate.min.css">
</head>

<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">

 	
	<div class="wrapper">

		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">
		
		<!-- Content Wrapper. Contains page content -->
		<div class="content-wrapper" >
			<!-- Content Header (Page header) -->
			<div class="content-header" style="background:  #f4f6f9;">
				<div class="row mb-2" style="margin-left:30px;margin-top:10px;margin-bottom:0px!important;">
					<div class="col-sm-6">
						<h4>Cadastrar Processos</h4>
					</div>
				</div>
			
				<div class="container-fluid">
							
					<div class="card-body" style="display:flex;flex-direction:column;">

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
											<div class="bs-stepper" >
												<div class="bs-stepper-header" role="tablist" >
													<!-- your steps here -->
													<div class="step" data-target="#infoInicial">
														<button type="button" class="step-trigger" role="tab" aria-controls="infoInicial" id="infoInicial-trigger">
															<span class="bs-stepper-circle">1</span>
															<span class="bs-stepper-label">Informações Iniciais</span>
														</button>
													</div>

													<div class="line"></div>

													<div class="step" data-target="#tipoAvaliacao">
														<button type="button" class="step-trigger" role="tab" aria-controls="tipoAvaliacao" id="tipoAvaliacao-trigger">
															<span class="bs-stepper-circle">2</span>
															<span class="bs-stepper-label">Tipo de avaliação</span>
														</button>
													</div>

													<div class="line"></div>

													<div class="step" data-target="#infoEstrategicas">
														<button type="button" class="step-trigger" role="tab" aria-controls="infoEstrategicas" id="infoEstrategicas-trigger">
															<span class="bs-stepper-circle">3</span>
															<span class="bs-stepper-label">Informações Estratégicas</span>
														</button>
													</div>

													<div class="line"></div>
													
													<div class="step" data-target="#equipe">
														<button type="button" class="step-trigger" role="tab" aria-controls="equipe" id="equipe-trigger">
															<span class="bs-stepper-circle">4</span>
															<span class="bs-stepper-label">Equipe</span>
														</button>
													</div>

													<div class="line"></div>
													
													<div class="step" data-target="#Finalizar">
														<button type="button" class="step-trigger" role="tab" aria-controls="Finalizar" id="Finalizar-trigger">
															<span class="bs-stepper-circle">4</span>
															<span class="bs-stepper-label">Finalizar</span>
														</button>
													</div>


												</div>


												<div class="bs-stepper-content " >
													<!-- your steps content here -->
													<form   id="formInfoInicial" name="formInfoInicial"   onsubmit="return false" novalidate>
														<div id="infoInicial" class="content " role="tabpanel" aria-labelledby="infoInicial-trigger" >
															<div class="card-body animate__animated animate__flipInX" style="border: solid 1px #0083ca">
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
																	<div id="bloqueioAlert" class="alert alert-info col-sm-12" hidden style="text-align: center;font-size:1.2em">
																		Atenção: Ao bloquear este processo, o encaminhamento ao órgão avaliado só ocorrerá após o seu desbloqueio.
																	</div>
																</div>
															</div>
															<div style="margin-top:10px;display:flex;justify-content:space-between">
																<button class="btn btn-primary" onclick="inicializarValidacaoStep1();" >Próximo</button>
																<button id="btCancelar"  class="btn  btn-danger " onclick="location.reload()">Cancelar</button>
															</div>
														</div>
													</form>
													<form   id="formTipoAvaliacao" name="formTipoAvaliacao"  onsubmit="return false" novalidate >
														<div id="tipoAvaliacao" class="content " role="tabpanel" aria-labelledby="tipoAvaliacao-trigger" >
															<div class="card-body animate__animated animate__flipInX" style="border: solid 1px #0083ca">
																<div class="row" >
																	<input id="idTipoAvaliacao" hidden></input>
																	<div class="form-group col-sm-12">
																				<div id="dados-container" class="dados-container">
																					<!-- Os selects serão adicionados aqui -->
																				</div>

																				<div id="TipoAvalDescricaoDiv" class="form-group col-sm-12" hidden style="margin-top:10px;padding-left: 0;">
																					<label for="pcTipoAvalDescricao" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Descrição do Tipo de Avaliação:</label>
																					<div class="input-group date" id="reservationdate" data-target-input="nearest">
																						<input id="pcTipoAvalDescricao" name="pcTipoAvalDescricao" required  class="form-control" placeholder="Descreva o tipo de avaliação..." style="border-radius: 4px; padding: 10px; box-sizing: border-box; width: 100%;">
																						<span id="pcTipoAvalDescricaoCharCounter" class="badge badge-secondary"></span>
																					</div>
																				</div>
																				<div id="pcProcessoN3Div" class="form-group col-sm-12" hidden style="margin-top:10px;padding-left: 0;">
																					<label for="pcProcessoN3" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Nome do Processo N3:</label>
																					<div class="input-group date" id="reservationdate" data-target-input="nearest">
																						<input id="pcProcessoN3" name="pcProcessoN3" required class="form-control" placeholder="Nome do PROCESSO N3..." style="border-radius: 4px;  padding: 10px; box-sizing: border-box; width: 100%;">
																						<span id="pcProcessoN3CharCounter" class="badge badge-secondary"></span>
																					</div>
																				</div>
																				<div id="pcProcessoN3descricaoDiv" class="form-group col-sm-12" hidden style="margin-top:10px;padding-left: 0;">
																					<label for="pcProcessoN3desc" class="font-weight-bold" style="display: block; margin-bottom: 5px;">Descrição do Processo:</label>
																					<div class="input-group date" id="reservationdate" data-target-input="nearest">
																						<input id="pcProcessoN3desc" name="pcProcessoN3desc" required class="form-control" placeholder="Descreva o PROCESSO..." style="border-radius: 4px;  padding: 10px; box-sizing: border-box; width: 100%;">
																						<span id="pcProcessoN3descCharCounter" class="badge badge-secondary"></span>
																					</div>
																					<div id="bloqueioAlert" class="alert alert-info col-sm-12" style="text-align: center;font-size:1.2em;margin-top:5px">
																						Atenção: Ao finalinalizar o cadastro, este novo grupo de tipo de avaliação também será cadastrado e disponibilizado para seleção em futuros processos.
																					</div>
																				</div>
																				
																				
																				<div id="pcProcessoDescricaoDiv" class="col-sm-12" hidden style="font-size:1.2em;text-align: justify;margin-top:40px">
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

																<button id="btCancelar"  class="btn  btn-danger " onclick="location.reload()">Cancelar</button>
															</div>
															
														</div>
													</form>
													<form   id="formInfoEstrategicas" name="formInfoEstrategicaso"  onsubmit="return false" novalidate>
														<div id="infoEstrategicas" class="content" role="tabpanel" aria-labelledby="infoEstrategicas-trigger">
															<div class="card-body animate__animated animate__flipInX" style="border: solid 1px #0083ca">
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
																<button id="btCancelar"  class="btn  btn-danger " onclick="location.reload()">Cancelar</button>
															</div>
															
														</div>
													</form>
													<form   id="formEquipe" name="formEquipe"  onsubmit="return false" novalidate>
														<div id="equipe" class="content" role="tabpanel" aria-labelledby="equipe-trigger">
															<div class="card-body animate__animated animate__flipInX" style="border: solid 1px #0083ca">
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
																<button id="btCancelar"  class="btn  btn-danger " onclick="location.reload()">Cancelar</button>
															</div>


														</div>
													</form>
													<form   id="formFinalizar" name="formFinalizar"  onsubmit="return false" novalidate>
														<div id="Finalizar" class="content" role="tabpanel" aria-labelledby="Finalizar-trigger">
															
															<div id="infoValidas" hidden class="form-card col-sm-12 animate__animated animate__zoomInDown animate__slow">
																<h3 class="fs-title text-center">Todas as Informações foram validadas com sucesso!</h3>
																<br>
																<div class="row justify-content-center col-sm-12">
																	
																	<i class="fa-solid fa-circle-check" style="color:#28a745;font-size:100px"></i>
																	
																</div>
																<br>
																<div id="mensagemSalvar" class="row justify-content-center">
																	<div class="col-7 text-center">
																		<h5>Clique no botão "Salvar" para cadastrar este processo.</h5>
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

															<div style="margin-top:10px;display:flex;justify-content:space-between">
																<button class="btn btn-secondary" onclick="stepper.previous()" >Anterior</button>
																<button id="btSalvar" class="btn  btn-success animate__animated animate__zoomInDown animate__slow" >Salvar</button>
																<button id="btCancelar"  class="btn  btn-danger " onclick="location.reload()">Cancelar</button>
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
							
					</div>	<!-- fim card-body -->

					<div class="card-body" style="display:flex;flex-direction:column;">
						<div style="justify-content:right;  width: 100%;">
							<div style="margin-right: 30px;float:right">
								<i id="btExibirTab" class=" fas fa-th" style="font-size:40px;color: #2581c8;cursor:pointer" title ="Exibir Tabela"></i>
							</div>
						</div>
						
						<div id="exibirTab" style="margin-top:10px"></div>
						
							
					</div>	<!-- fim card-body -->
							
				<!--<cfquery datasource="#application.dsn_processos#" name="rsAvaliadoresCadastrados">
					SELECT pc_avaliadores.* FROM pc_avaliadores WHERE pc_avaliador_id_processo = '0300032022'
					
				</cfquery>			
               <cfdump  var="#rsAvaliadoresCadastrados#">-->
					
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
			window.stepper = new Stepper($('.bs-stepper')[0], {
				animation: true
			});

			

			//Initialize Select2 Elements
			$('select').select2({
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
						atLeastOne: true
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
				}
			};

			window.inicializarValidacaoStep3 = function() {
				if ($("#formInfoInicial").valid() && $("#formTipoAvaliacao").valid() && $("#formInfoEstrategicas").valid()) {
					// Ir para o próximo passo
					stepper.next();
				}
			};

           
			window.inicializarValidacaoStep4 = function() {
				if ($("#formInfoInicial").valid() && $("#formTipoAvaliacao").valid() && $("#formInfoEstrategicas").valid() && $("#formEquipe").valid()) {
					// Ir para o próximo passo
					stepper.next();
 					$('#infoValidas').attr("hidden",false);
					$('#infoInvalidas').attr("hidden",true);
					
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
				} else {
					// Caso contrário, esconde o span
					$('#bloqueioAlert').attr("hidden",true)	
				}
			});
	

			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
			});
	        $('#modalOverlay').modal('show')
			
			var mostratab;

			if(localStorage.getItem('mostraTab')==null){
				localStorage.setItem('mostraTab','0');
			}
			mostraTab = localStorage.getItem('mostraTab');
			if(mostraTab == '1'){
				$('#btExibirTab').removeClass('fa-th')
				$('#btExibirTab').addClass('fa-table')
				$('#btExibirTab').prop('title', 'Exibir Cards')
				exibirTabela();
			}else{
				$('#btExibirTab').removeClass('fa-table')
				$('#btExibirTab').addClass('fa-th')
				$('#btExibirTab').prop('title', 'Exibir Tabela')
				ocultarTabela();
			}

			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
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

			$.ajax({
                url: 'cfc/pc_cfcAvaliacoes.cfc',
                data: {
                    method: 'getAvaliacaoTipos',
                },
                dataType: "json",
                async: false
            })//fim ajax
            .done(function(data) {
                // Define os níveis de dados e nomes dos labels
                let dataLevels = ['MACROPROCESSOS', 'PROCESSO_N1', 'PROCESSO_N2', 'PROCESSO_N3'];
                let labelNames = ['Macroprocesso', 'Processo N1', 'Processo N2', 'Processo N3'];
                let outrosOptions = [
                    { dataLevel:'PROCESSO_N3', text: "OUTROS", value: 0 },
                ];
                // Inicializa os selects dinâmicos
                initializeSelects(data, dataLevels, 'ID', labelNames, 'idTipoAvaliacao',outrosOptions);
                

            })//fim done
            .fail(function(xhr, ajaxOptions, thrownError) {
                $('#modalOverlay').delay(1000).hide(0, function() {
                    $('#modalOverlay').modal('hide');
                });
                $('#modal-danger').modal('show')
                $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
                $('#modal-danger').find('.modal-body').text(thrownError)

            })//fim fail


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
		  	stepper.to(0);
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
                initializeSelects(data, dataLevels, 'ID', labelNames, 'idTipoAvaliacao',outrosOptions);
 
				// Define os IDs dos selects
				let selectIDs = ['selectDinamicoMACROPROCESSOS', 'selectDinamicoPROCESSO_N1', 'selectDinamicoPROCESSO_N2', 'selectDinamicoPROCESSO_N3'];
				const exampleID = processoAvaliado; // Mude para o ID desejado
				populateSelectsFromID(data, exampleID, selectIDs, 'idTipoAvaliacao');
			})
			.fail(function(error) {
				$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(error)
			});
			//fim popula os selects dinâmicos
			
			$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');
            console.log(naoAplicaDesc)
		
			$('#cadastro').CardWidget('expand')
		
			$('body')[0].scrollIntoView(true);

		

		}

		function processoEditarTab(linha,processoId, sei, relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin,bloquear, objetivoEstrategico, riscoEstrategico, indEstrategico) {
            event.preventDefault()
        	event.stopPropagation()
			stepper.to(0);

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
                initializeSelects(data, dataLevels, 'ID', labelNames, 'idTipoAvaliacao',outrosOptions);
				// Define os IDs dos selects
				let selectIDs = ['selectDinamicoMACROPROCESSOS', 'selectDinamicoPROCESSO_N1', 'selectDinamicoPROCESSO_N2', 'selectDinamicoPROCESSO_N3'];
				const exampleID = processoAvaliado; // Mude para o ID desejado
				populateSelectsFromID(data, exampleID, selectIDs, 'idTipoAvaliacao');
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
		
			$('body')[0].scrollIntoView(true);

		

		}

		function processoVisualizar(processoId,sei,relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin,bloquear, objetivoEstrategico, riscoEstrategico, indEstrategico) {
            event.preventDefault()
        	event.stopPropagation()
			stepper.to(0);	
		
			var listAvaliadores = avaliadores.split(",");
			var listObjetivoEstrategico = objetivoEstrategico.split(",");
			var listRiscoEstrategico = riscoEstrategico.split(",");
			var listIndEstrategico = indEstrategico.split(",");

		    $('#cabecalhoAccordion').text("Visualizando o Processo:" + ' ' + processoId);
			$("#btSalvar").attr("hidden",true);
			$("#mensagemSalvar").attr("hidden",true);
			$('#pcDataInicioAvaliacao').removeAttr('disabled');
            $('#pcOrgaoAvaliado').removeAttr('disabled');
			
            $('#pcModalidade').val(modalidade).trigger('change');

			$('#pcNumSEI').val(sei);
            $('#pcProcessoId').val(processoId);			
			$('#pcTipoClassificacao').val(classificacao).trigger('change');
			$('#pcNumRelatorio').val(relSei);
			$('#pcOrigem').val(orgaoOrigem).trigger('change');
			$('#pcDataInicioAvaliacao').val(dataInicio);
			$('#pcDataFimAvaliacao').val(dataFim);
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
                initializeSelects(data, dataLevels, 'ID', labelNames, 'idTipoAvaliacao',outrosOptions);
				// Define os IDs dos selects
				let selectIDs = ['selectDinamicoMACROPROCESSOS', 'selectDinamicoPROCESSO_N1', 'selectDinamicoPROCESSO_N2', 'selectDinamicoPROCESSO_N3'];
				const exampleID = processoAvaliado; // Mude para o ID desejado
				populateSelectsFromID(data, exampleID, selectIDs, 'idTipoAvaliacao');
			})
			.fail(function(error) {
				$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(error)
			});
			//fim popula os selects dinâmicos

			$('#pcBloquear').val(bloquear).trigger('change');
		
			$('#cadastro').CardWidget('expand')
		
			$('body')[0].scrollIntoView(true);

	
		}

		function exibirTabela(){
		 //	$('#btExibirTab').html('Aguarde...');

			$.ajax({
				type: "post",
				url: "cfc/pc_cfcProcessos.cfc",
				data:{
					method: "tabProcessos",
				},
				async: false,
				success: function(result) {
					$('#exibirTab').html(result)
					$('#btExibirTab').removeClass('fa-th')
					$('#btExibirTab').addClass('fa-table')
					$('#btExibirTab').prop('title', 'Exibir Cards')
					localStorage.setItem('mostraTab', '1');
					
				},
				error: function(xhr, ajaxOptions, thrownError) {
					$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(thrownError)
				}
			})	
			
				
			

		}

		function ocultarTabela(){
			//	$('#btExibirTab').html('Aguarde...');
			
			$.ajax({
				type: "post",
				url: "cfc/pc_cfcProcessos.cfc",
				data:{
					method: "cardsProcessos",
				},
				async: false,
				success: function(result) {
					$('#exibirTab').html(result)
					$('#btExibirTab').removeClass('fa-table')
					$('#btExibirTab').addClass('fa-th')
					$('#btExibirTab').prop('title', 'Exibir Tabela')
					localStorage.setItem('mostraTab', '0');
			
				},
				error: function(xhr, ajaxOptions, thrownError) {
					
					$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(thrownError)
					
				}
			})	

				
		}
		
		$('#btExibirTab').on('click', function (event)  {
			$('#modalOverlay').modal('show')
			if($(this).hasClass('fa-th')){
				setTimeout(function() {
					exibirTabela()
				}, 500);

			}else{
				setTimeout(function() {
					ocultarTabela()
				}, 500);

			}	
			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
			});
		});

			
	</script>


</body>





</html>
