<cfprocessingdirective pageencoding = "utf-8">



<!-- 'A' ATIVO, 'O' ORIGEM DE PROCESSOS, 'D' DESATIVADO -->
<cfquery name="rsOrigem" datasource="#dsn_processos#">
	SELECT pc_org_mcu, pc_org_sigla
	FROM pc_orgaos
	WHERE pc_org_Status = 'O' 
	ORDER BY pc_org_sigla
</cfquery>
<cfquery name="rsOrigemGCOP" datasource="#dsn_processos#">
	SELECT pc_org_mcu, pc_org_sigla
	FROM pc_orgaos
	WHERE pc_org_Status = 'O' and pc_org_mcu = '00436698'
	ORDER BY pc_org_sigla
</cfquery>

<cfquery name="rsAvaliacaoTipo" datasource="#dsn_processos#">
	SELECT pc_aval_tipo_id, pc_aval_tipo_descricao
	FROM pc_avaliacao_tipos
	WHERE pc_aval_tipo_status = 'A'
	ORDER BY pc_aval_tipo_descricao
</cfquery> 

<cfquery name="rsClas" datasource="#dsn_processos#">
	SELECT pc_class_id, pc_class_descricao
	FROM pc_classificacoes
	WHERE pc_class_status ='A'
	ORDER BY pc_class_descricao
</cfquery>

<cfquery name="rs_OrgAvaliado" datasource="#dsn_processos#">
	SELECT pc_org_mcu, pc_org_sigla
	FROM pc_orgaos
	WHERE pc_org_controle_interno ='N' AND pc_org_Status = 'A' AND pc_org_orgaoAvaliado = 1
	ORDER BY pc_org_sigla
</cfquery>

<cfquery name="rs_OrgAvaliadoSE_usuario" datasource="#dsn_processos#">
	SELECT pc_org_mcu, pc_org_sigla
	FROM pc_orgaos
	WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') AND (pc_org_se = '#rsUsuarioParametros.pc_org_se#' OR pc_org_se = '#rsUsuarioParametros.pc_org_se_abrangencia#')
	ORDER BY pc_org_sigla
</cfquery>

<cfquery datasource="#dsn_processos#" name="rsAvaliadores">
	SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios 
	INNER JOIN pc_orgaos ON  pc_org_mcu = pc_usu_lotacao
	WHERE pc_org_controle_interno = 'S' AND pc_usu_status ='A'
	ORDER BY pc_org_se_sigla ASC,  pc_usu_nome ASC
</cfquery>

<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SNCI</title>
<link rel="icon" type="image/x-icon" href="dist/img/icone_sistema_standalone_ico.png">
   
	<!-- iCheck -->
	<link rel="stylesheet" href="plugins/icheck-bootstrap/icheck-bootstrap.min.css">
     <style>
		
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
							
					<div class="card-body" style="display:flex;flex-direction:column">

						<form  class="row g-3" id="myForm" name="myForm" format="html"  style="height: auto;">
							

							<!--acordion-->
							<div id="accordion" >
								<div id="cadastro" class="card card-primary collapsed-card" style="margin-left:8px">
									<div  class="card-header" style="background-color: #0083ca;color:#fff;">
										<a   class="d-block" data-toggle="collapse" href="#collapseOne"  data-card-widget="collapse">
											<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
											</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um novo Processo</span>
										</a>
										
									</div>
									
									<input id="pcProcessoId" hidden>

									<div class="card-body" style="border: solid 3px #0083ca">
										<div class="row" >

											<div class="col-sm-3">
												<div class="form-group">
													<label for="pcModalidade">Modalidade:</label>
													<select id="pcModalidade" required name="pcModalidade" class="form-control">
														<option selected="" disabled="" value=""></option>
														<!--Se a gerência do usuário for GINS-->
                                                        <cfif '#rsUsuarioParametros.pc_usu_lotacao#' eq '00437407' or '#rsUsuarioParametros.pc_usu_perfil#' eq 7>
															<option value="E">ENTREGA DO RELATÓRIO</option>
														<cfelse>
															<option value="A">ACOMPANHAMENTO</option>
															<option value="E">ENTREGA DO RELATÓRIO</option>
														</cfif>
															

													    <!--<option value="N">NORMAL</option>-->
													</select>
												</div>
											</div>

											<div id="pcNumSEIDiv"  class="col-sm-2" hidden>
												<div class="form-group">
													<label for="pcNumSEI" >N°SEI</label>
													<input id="pcNumSEI"  required name="pcNumSEI" type="text" class="form-control "  data-inputmask="'mask': '99999.999999/9999-99'" data-mask="99999999999999999"  placeholder="N°SEI...">
													
												</div>
											</div>

											<div  id="pcNumRelatorioDiv" class="col-sm-2" hidden>
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

														<cfif #rsUsuarioParametros.pc_usu_perfil# eq 8>
															<cfoutput><option selected value="#rsUsuarioParametros.pc_org_mcu#"> #rsUsuarioParametros.pc_org_sigla#</option></cfoutput>
														<cfelseif #rsUsuarioParametros.pc_usu_perfil# eq 7>
														    <cfoutput><option selected value="#rsOrigemGCOP.pc_org_mcu#">#rsOrigemGCOP.pc_org_sigla#</option></cfoutput>
														<cfelse>
															<cfoutput query="rsOrigem" >
																<option value="#rsOrigem.pc_org_mcu#">#rsOrigem.pc_org_sigla#</option>
															</cfoutput>
														</cfif>
													</select>
													
												</div>
											</div>

                                            <input hidden  id="pcDataInicioAvaliacaoAnterior"  name="pcDataInicioAvaliacaoAnterior" type="date" class="form-control" placeholder="dd/mm/aaaa" >
											<div class="col-md-3">
												<div class="form-group">
													<label for="pcDataInicioAvaliacao">Data Início Avaliação:</label>
													<div class="input-group date" id="reservationdate" data-target-input="nearest">
														<input  id="pcDataInicioAvaliacao"  name="pcDataInicioAvaliacao" required  type="date" class="form-control" placeholder="dd/mm/aaaa" >
													</div>
												</div>
											</div>

											<div id="pcDataFimAvaliacaoDiv"  class="col-md-3" hidden>
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
													<select id="pcTipoDemanda" required=""  name="pcTipoDemanda" class="form-control" >
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

											
											<div class="col-sm-6">
												<div class="form-group">
													<label for="pcTipoAvaliado">Tipo de Avaliação:</label>
													<select id="pcTipoAvaliado" required  name="pcTipoAvaliado" class="form-control" >
														<option selected="" disabled="" value=""></option>
														<cfoutput query="rsAvaliacaoTipo">
															<option value="#rsAvaliacaoTipo.pc_aval_tipo_id#">#trim(rsAvaliacaoTipo.pc_aval_tipo_descricao)#</option>
														</cfoutput>
													</select>
												</div>
											</div>
											<div id="TipoAvalDescricaoDiv"  class="col-sm-7" hidden>
												<div class="form-group">
													<label for="pcTipoAvalDescricao">Descrição do Tipo de Avaliação:</label>
													<div class="input-group date" id="reservationdate" data-target-input="nearest">
														<input  id="pcTipoAvalDescricao"  name="pcTipoAvalDescricao" maxlength="100" required class="form-control" placeholder="Descreva o tipo de avaliação..." >
													</div>
												</div>
											</div>

											<input hidden  id="pcOrgaoAvaliadoAnterior"  name="pcOrgaoAvaliadoAnterior">
											<div class="col-sm-3">
												<div class="form-group">
													<label for="pcOrgaoAvaliado">Órgão Avaliado:</label>
													<select id="pcOrgaoAvaliado" required name="pcOrgaoAvaliado" class="form-control">
														<option selected="" disabled="" value=""></option>
														<cfif #rsUsuarioParametros.pc_usu_perfil# eq 7>
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

											<div id ="pcTipoClassificacaoDiv" class="col-sm-3" hidden>
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

											<div class="col-sm-8 " style="box-shadow:0!important">
												<div class="form-group " >
														<label for="pcAvaliadores">Avaliadores:</label>
														<select id="pcAvaliadores" required="false" class="form-control" multiple="multiple">
															<cfoutput query="rsAvaliadores">
																<option value="#trim(pc_usu_matricula)#">#trim(pc_org_se_sigla)# - #trim(pc_usu_nome)# (#trim(pc_usu_matricula)#)</option>
															</cfoutput>
														</select>	
												</div>
											</div>
										
											<div id="pcCoordenadorDiv" class="col-sm-4 ">
												<div class="form-group">
													<label style="">Coordenador Regional:</label>
													<select id="pcCoordenador" required name="pcCoordenador" class="form-control">
														<option selected="" disabled="" value=""></option>
														<option value="0">Sem Coord. Regional</option>
														<cfoutput query="rsAvaliadores">
															<option value="#trim(pc_usu_matricula)#">#trim(pc_org_se_sigla)# - #trim(pc_usu_nome)# (#trim(pc_usu_matricula)#)</option>
														</cfoutput>
													</select>
												</div>
											</div>

											<div class="col-sm-4 " >
												<div class="form-group">
													<label style="">Coordenador Nacional:</label>
													<select id="pcCoordNacional" required name="pcCoordNacional" class="form-control">
														<option selected="" disabled="" value=""></option>
														<option value="0">Sem Coord. Nacional</option>
														<cfoutput query="rsAvaliadores">
															<option value="#trim(pc_usu_matricula)#">#trim(pc_org_se_sigla)# - #trim(pc_usu_nome)# (#trim(pc_usu_matricula)#)</option>
														</cfoutput>
													</select>
												</div>
											</div>
											<divc id="pcBloquearDiv" class="col-sm-2" hidden>
												<div class="form-group">
													<label for="pcBloquear" >Bloquear Processo:</label>
													<select id="pcBloquear" required=""  name="pcBloquear" class="form-control" >
														<option selected="" disabled="" value="">Selecione...</option>
														<option value="N">NÃO</option>
														<option value="S">SIM</option>				
													</select>
												</div>
											</divc>


											<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
												<div id="btSalvarDiv" >
													<button id="btSalvar" class="btn btn-block btn-primary " >Salvar</button>
												</div>
												<div style="margin-left:100px">	
													<button id="btCancelar"  class="btn btn-block btn-danger " >Cancelar</button>
												</div>
												
											</div>
										</div> <!-- fim row -->
									</div><!--fim card-body -->
									<!--fim collapseOne -->
								</div><!--fim card card-primary -->

							</div><!--fim acordion -->
						</form><!-- fim myForm -->

						<!--<button id="btTesteJson" class="btn btn-block btn-primary " >teste json </button>
						<div id="testeJson"></div>-->



						<div style="justify-content:right;  width: 100%;">
							<div style="margin-right: 30px;float:right">
								<i id="btExibirTab" class=" fas fa-th" style="font-size:40px;color: #2581c8;cursor:pointer" title ="Exibir Tabela"></i>
							</div>
						</div>
						
						<div id="exibirTab" style="margin-top:10px"></div>
						
							
					</div>	<!-- fim card-body -->
							
				<!--<cfquery datasource="#dsn_processos#" name="rsAvaliadoresCadastrados">
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

	
	

		//Initialize Select2 Elements
		$('select').select2({
		theme: 'bootstrap4',
		placeholder: 'Selecione...'
		});

		

		$(document).ready(function() {
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
				
			//INÍCIO DA VALIDAÇÃO DO myForm
			// Adicionar classe 'is-invalid' a todos os campos
			var currentDate = new Date();
			var maxDate = new Date(currentDate.getFullYear() + 1, 11, 31);

			$('#myForm').validate({
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
						pattern: /^\d{8}$/
					},
					pcDataInicioAvaliacao: {
						required: true,
						dateRange: true
					},
					pcDataFimAvaliacao: {
						required: true,
						dateRange: true
					}
				},
				messages: {
					pcNumSEI: {
						required: '<span style="color:red;font-size:10px">O campo N° SEI é obrigatório.</span>',
						pattern: '<span style="color:red;font-size:10px">O formato do N° SEI é inválido.</span>'
					},
					pcNumRelatorio: {
						required: '<span style="color:red;font-size:10px">O campo N° Rel. SEI é obrigatório.</span>',
						pattern: '<span style="color:red;font-size:10px">O formato do N° Rel. SEI é inválido.</span>'
					},
					pcDataInicioAvaliacao: {
						required: '<span style="color:red;font-size:10px">A data de início da avaliação é obrigatória.</span>',
						dateRange: '<span style="color:red;font-size:10px;">A data deve estar entre 01/01/2019 e '+maxDate.toLocaleDateString('pt-BR')+'.</span>'
					},
					pcDataFimAvaliacao: {
						required: '<span style="color:red;font-size:10px">A data de início da avaliação é obrigatória.</span>',
						dateRange: '<span style="color:red;font-size:10px;">Data inválida.</span>'
					}
				},

				errorClass: 'is-invalid',
				//validClass: 'is-valid',
				highlight: function(element, errorClass, validClass) {
					$(element).addClass(errorClass).removeClass(validClass);
				},
				unhighlight: function(element, errorClass, validClass) {
					$(element).removeClass(errorClass);
				},
				// errorPlacement: function(error, element) {
				// 	error.addClass('invalid-feedback');
				// 	error.insertAfter(element);
				// },
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

		$('#pcTipoAvaliado').on('change', function (event){
            if($('#pcTipoAvaliado').val() == 2){
				$('#pcTipoAvalDescricao').val(null).trigger('change')
				$('#TipoAvalDescricaoDiv').attr("hidden",false)		
			}else{
				$('#pcTipoAvalDescricao').val(null).trigger('change')
				$('#TipoAvalDescricaoDiv').attr("hidden",true)
			}
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
				$('#pcNumSEIDiv').attr("hidden",true)	

				$('#pcNumRelatorio').val(null).trigger('change')
				$('#pcNumRelatorioDiv').attr("hidden",true)	

				$('#pcDataFimAvaliacao').val(null).trigger('change')
				$('#pcDataFimAvaliacaoDiv').attr("hidden",true)

				$("#pcTipoClassificacao").val('6')
				$("#pcTipoClassificacaoDiv").attr("hidden",true)	
			}

			if($('#pcModalidade').val() == 'E'){
				$('#pcBloquearDiv').attr("hidden",false)
				$('#pcBloquear').val(null).trigger('change')
			}else{
				$('#pcBloquearDiv').attr("hidden",true)
				$('#pcBloquear').val('N').trigger('change')
			}


		});

		function cancelar(){
			$('#pcDataInicioAvaliacao').removeAttr('disabled');
            $('#pcOrgaoAvaliado').removeAttr('disabled');
			$('#pcProcessoId').val(null);
			$('#pcNumSEI').val(null);
			$('#pcNumRelatorio').val(null);
			$('#pcDataInicioAvaliacao').val(null);
			$('#pcDataInicioAvaliacaoAnterior').val(null);
			$('#pcDataFimAvaliacao').val(null);
			$('#pcOrigem').val(null).trigger('change');
			$('#pcModalidade').val(null).trigger('change');
			$('#pcTipoClassificacao').val(null).trigger('change');
			$('#pcTipoAvaliado').val(null).trigger('change');
			$('#pcTipoAvalDescricao').val(null).trigger('change');
			$('#pcOrgaoAvaliado').val(null).trigger('change');
			$('#pcOrgaoAvaliadoAnterior').val(null);
			$('#pcAvaliadores').val(null).trigger('change');
			$('#pcCoordenador').val(null).trigger('change');
			$('#pcCoordNacional').val(null).trigger('change');
			$('#pcTipoDemanda').val(null).trigger('change');
			$('#pcAnoPacin').val(null).trigger('change')
			$('#pcBloquear').val(null).trigger('change')
			$('#cadastro').CardWidget('collapse')
			$('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo Processo");
			$("#btSalvarDiv").attr("hidden",false)
		}
        
		$('#btCancelar').on('click', function (event)  {
			event.preventDefault()
			event.stopPropagation()
			cancelar()
			
		});

		


		$('#btSalvar').on('click', function (event)  {
			event.preventDefault()
			event.stopPropagation()
			var sei=$("#pcNumSEI").val().replace(/([^\d])+/gim, '');
			var seiRelatorio=$("#pcNumRelatorio").val().replace(/([^\d])+/gim, '');
			//var anoPacin = $('#pcAnoPacin').val().replace(/([^\d])+/gim, '');
			if (
				(($('#pcModalidade').val() == 'A' || $('#pcModalidade').val()=='E') && sei.length != 17) ||
  				(($('#pcModalidade').val() == 'A' || $('#pcModalidade').val()=='E') && seiRelatorio.length != 8)  ||
				!$('#pcOrgaoAvaliado').val() ||
				!$('#pcOrigem').val() ||
				!$('#pcDataInicioAvaliacao').val() ||
				(($('#pcModalidade').val() == 'A' || $('#pcModalidade').val()=='E') && !$('#pcDataFimAvaliacao').val()) ||
				!$('#pcTipoAvaliado').val() ||
				($('#pcTipoAvaliado').val() == 2 && !$('#pcTipoAvalDescricao').val()) ||
				!$('#pcModalidade').val() ||
				!$('#pcAvaliadores').val() ||
				!$('#pcTipoDemanda').val() ||
				!$('#pcCoordenador').val() ||
				!$('#pcCoordNacional').val() ||
				($('#pcTipoDemanda').val() == 'P' && !$('#pcAnoPacin').val() ) ||
				(($('#pcModalidade').val() == 'A' || $('#pcModalidade').val()=='E') &&	!$('#pcTipoClassificacao').val())||
				($('#pcModalidade').val()=='E' &&	!$('#pcBloquear').val())
			  )
			{   	
				toastr.error('Todos os campos devem ser preenchidos!');
				return false;
			}

			

			if (($('#pcModalidade').val() == 'A' || $('#pcModalidade').val()=='E') && $('#pcDataFimAvaliacao').val() < $('#pcDataInicioAvaliacao').val())
			{   	
				toastr.error('A data fim da avaliação não pode ser menor que a data de início!');
				return false;
			}
			
			var anoAtual = new Date($('#pcDataInicioAvaliacao').val()).getFullYear();
			var anoAnterior = new Date($('#pcDataInicioAvaliacaoAnterior').val()).getFullYear();
            var orgaoAvaliadoAnterior = $('#pcOrgaoAvaliadoAnterior').val();
			var orgaoAvaliado = $('#pcOrgaoAvaliado').val();
			// alert("orgaoAvaliadoAnterior = "+orgaoAvaliadoAnterior+" orgaoAvaliado = "+orgaoAvaliado)
			// return false;
			var mensagem = ""
	        if($('#pcProcessoId').val() == ''){
				var mensagem = "Deseja cadastrar este processo?"
			}else{
				if ((anoAtual !== anoAnterior && $('#pcDataInicioAvaliacaoAnterior').val()!==null) || orgaoAvaliadoAnterior !== orgaoAvaliado) {
					var mensagem = "O ano da data de início da avaliação e/ou o órgão responsável foi alterado. Isso fará com que o SNCI exclua o processo atual e crie um novo processo com uma nova numeração. Caso a alteração seja apenas do órgão responsável, sem que haja modificação de SE, o número SNCI será mantido. Deseja continuar?"
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
						var avaliadoresList = $('#pcAvaliadores').val();
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
									pcTipoAvaliado:$('#pcTipoAvaliado').val(),
									pcTipoAvalDescricao:$('#pcTipoAvalDescricao').val(),
									pcModalidade:$('#pcModalidade').val(),
									pcTipoClassificacao:$('#pcTipoClassificacao').val(),
									pcOrgaoAvaliado:$('#pcOrgaoAvaliado').val(),
									pcAvaliadores:avaliadoresList.join(','),
									pcCoordenador:$('#pcCoordenador').val(),
									pcCoordNacional:$('#pcCoordNacional').val(),
									pcTipoDemanda:$('#pcTipoDemanda').val(),
									pcAnoPacin:$('#pcAnoPacin').val(),
									pcBloquear:$('#pcBloquear').val(),
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
								$('#pcTipoAvaliado').val(null).trigger('change');
								$('#pcOrgaoAvaliado').val(null).trigger('change');
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
						}, 500);
					}else {
						// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
						$('#modalOverlay').modal('hide');
						Swal.fire('Operação Cancelada', '', 'info');
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
						Swal.fire('Operação Cancelada', '', 'info');
					}
							
				});	
		}
		


		function processoEditarCard(processoId, sei, relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin, bloquear) {
            event.preventDefault()
        	event.stopPropagation()
		  
			var listAvaliadores = avaliadores.split(",");
		    $('#cabecalhoAccordion').text("Editar o Processo:" + ' ' + processoId);
			$("#btSalvarDiv").attr("hidden",false)
			
			
			$('#pcModalidade').val(modalidade).trigger('change');

			$('#pcNumSEI').val(sei);
            $('#pcProcessoId').val(processoId);			
			$('#pcTipoClassificacao').val(classificacao).trigger('change');
			$('#pcNumRelatorio').val(relSei);
			$('#pcOrigem').val(orgaoOrigem).trigger('change');
			$('#pcDataInicioAvaliacao').val(dataInicio);
			$('#pcDataInicioAvaliacaoAnterior').val(dataInicio);
			$('#pcDataFimAvaliacao').val(dataFim);
			$('#pcTipoAvaliado').val(processoAvaliado).trigger('change');
			$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');
			

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
				


		    var selectedValues = new Array();
			$.each(listAvaliadores, function(index,value){
				selectedValues[index] = value;
			});
			
			$('#pcAvaliadores').val(selectedValues).trigger('change');

			$('#pcBloquear').val(bloquear).trigger('change');
		
			$('#cadastro').CardWidget('expand')
		
			$('body')[0].scrollIntoView(true);

		

		}

		function processoEditarTab(linha,processoId, sei, relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin,bloquear) {
            event.preventDefault()
        	event.stopPropagation()
		    $(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
			var listAvaliadores = avaliadores.split(",");
		    $('#cabecalhoAccordion').text("Editar o Processo:" + ' ' + processoId);
			$("#btSalvarDiv").attr("hidden",false)
			
			
			$('#pcModalidade').val(modalidade).trigger('change');

			$('#pcNumSEI').val(sei);
            $('#pcProcessoId').val(processoId);			
			$('#pcTipoClassificacao').val(classificacao).trigger('change');
			$('#pcNumRelatorio').val(relSei);
			$('#pcOrigem').val(orgaoOrigem).trigger('change');
			$('#pcDataInicioAvaliacao').val(dataInicio);
			$('#pcDataInicioAvaliacaoAnterior').val(dataInicio);
			$('#pcDataFimAvaliacao').val(dataFim);
			$('#pcTipoAvaliado').val(processoAvaliado).trigger('change');
			$('#pcTipoAvalDescricao').val(naoAplicaDesc).trigger('change');

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


		    var selectedValues = new Array();
			$.each(listAvaliadores, function(index,value){
				selectedValues[index] = value;
			});
			
			$('#pcAvaliadores').val(selectedValues).trigger('change');
			$('#pcBloquear').val(bloquear).trigger('change');
		
			$('#cadastro').CardWidget('expand')
		
			$('body')[0].scrollIntoView(true);

		

		}

		function processoVisualizar(processoId,sei,relSei, orgaoOrigem, dataInicio, dataFim, processoAvaliado, naoAplicaDesc, orgaoAvaliado, coordenador, coordNacional, classificacao, avaliadores, modalidade, tipoDemanda, anoPacin,bloquear) {
            event.preventDefault()
        	event.stopPropagation()
		
			var listAvaliadores = avaliadores.split(",");
		    $('#cabecalhoAccordion').text("Visualizando o Processo:" + ' ' + processoId);
			$("#btSalvarDiv").attr("hidden",true);
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
			$('#pcTipoAvaliado').val(processoAvaliado).trigger('change');
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

		

		    var selectedValues = new Array();
			$.each(listAvaliadores, function(index,value){
				selectedValues[index] = value;
			});
			
			$('#pcAvaliadores').val(selectedValues).trigger('change');
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
