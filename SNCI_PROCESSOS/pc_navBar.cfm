	<cfprocessingdirective pageencoding = "utf-8">
	
	<!-- Navbar -->
		<link rel="stylesheet" href="../SNCI_PROCESSOS/dist/css/animate.min.css">
		<nav class="main-header navbar navbar-expand navbar-light shadow-sm navbar_correios_backgroundColor" style="height:56px;" >
			<!-- Left navbar links -->
			<ul class="navbar-nav " >
				<li class="nav-item" >
					<a class="nav-link " data-widget="pushmenu" data-enable-remember="true" href="#" role="button" data-auto-collapse-size="1600"><i class="fas fa-bars"  style="font-size:2rem;color:#fff"></i></a>
					<!--data-auto-collapse-size="2000" para forçar o sidebar a colapsar-->
				</li>

				 <cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
					<li class="nav-item d-none d-sm-inline-block" >
						<div>
							<h3 class="nav-link" style="color:#fff"><cfoutput>SERVIDOR: #Ucase(application.auxsite)#</cfoutput></h3>
						</div>
					</li>
				</cfif>
				
			</ul>
			
				
			<ul class="navbar-nav ml-auto ">
				<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>

					<li class="nav-item dropdown " id="alertasDropdown">
						<a class="nav-link grow-icon  " style="animation-iteration-count:2" data-toggle="dropdown" href="#" >
							<i class="fas fa-bell fa-2x loaderAlert" style="color:#00416B"></i>
							<span id="badgeAlertaOA" class="badge badge-danger navbar-badge " style="font-size:12px;top: 2px;"></span>
						</a>
						<div class="dropdown-menu dropdown-menu-lg dropdown-menu-right alertaNavBar" style="margin-top: 5px;">
							<!-- Message Start -->
							<div class="mensagemAlertaNavBar" id="alertasOAOrientacoesNavBarDiv" ></div>
							<div class="mensagemAlertaNavBar" id="alertasOAOrientacoesSubordinadosNavBarDiv" ></div>
							<div class="mensagemAlertaNavBar" id="alertasOAPropostasMelhoriaNavBarDiv" ></div>
							<!-- Message End -->
							<div class="dropdown-arrow_navbar"></div>
						</div>
					</li>
				<cfelse>
					<li class="nav-item dropdown " id="alertasDropdownCI">
						<a class="nav-link grow-icon animate__animated animate__heartBeat animate__delay-2s animate__fast" style="animation-iteration-count:2" data-toggle="dropdown" href="#" >
							<i class="fas fa-bell fa-2x " style="color:#00416B"></i>
							<span id="badgeAlertaCI" class="badge badge-danger navbar-badge" style="font-size:12px;top: 2px;"></span>
						</a>
						<div class="dropdown-menu dropdown-menu-lg dropdown-menu-right alertaNavBar" style="margin-top: 5px;">
							<!-- Message Start -->
							<div class="mensagemAlertaNavBar" id="alertasPosicionamentosIniciaisCINavBarDiv" ></div>
							<div class="mensagemAlertaNavBar" id="alertasOrgaosSemUsuarioCINavBarDiv" ></div>
							<!-- Message End -->
							<div class="dropdown-arrow_navbar"></div>
						</div>
					</li>

				</cfif>

                <cfif listLast(cgi.script_name, "/") neq "pc_Navegacao_por_abas.cfm">
					<li class="nav-item" style="margin-left:10px" >
						<a class="nav-link grow-icon"  href="../SNCI_PROCESSOS/./pc_Navegacao_por_abas.cfm" role="button" data-toggle="tooltip" data-placement="top" title="Ativar Navegação por Abas">
							<i class="fas fa-ellipsis-h fa-2x" style="color:#00416B"></i>
						</a>
					</li>
				<cfelse>
					<!--Recarregar a página-->
					<li class="nav-item" style="margin-left:10px">
						<a class="nav-link grow-icon" onclick="window.top.location.href='../SNCI_PROCESSOS/index.cfm';" role="button" data-toggle="tooltip" data-placement="top" title="Desativar Navegação por Abas">
							<i class="fas fa-house fa-2x" style="color:#00416B"></i>
							
						</a>
					</li>
				</cfif>

				<li class="nav-item" style="margin-left:10px;margin-right:10px">
					<a class="nav-link grow-icon"  data-widget="fullscreen" href="#" role="button" data-toggle="tooltip" data-placement="top" title="Tela Cheia">
						<i class="fas fa-expand-arrows-alt fa-2x" style="color:#00416B"></i>
					</a>
				</li>
			</ul>
		</nav>
		
		<script language="JavaScript">

			// Espera até que o documento esteja totalmente carregado
			$(document).ready(function() {
				$('[data-toggle="tooltip"]').tooltip(); 
				// Chama a função que mostra os alertas

				<cfoutput>
				    let ehControleInterno = '#application.rsUsuarioParametros.pc_org_controle_interno#';	
					// Verifica se o usuário é do controle interno
					if(ehControleInterno === 'N'){
						// Chama a função que mostra os alertas
						mostraalertasOAOrientacoes();
						mostraAlertasOAOrientacoesSubordinados();
						mostraAlertasOAPropostasMelhoria();
						atualizaBadgeAlertas();
					} else {
						mostraAlertasPosicionamentosIniciaisCI();
						mostraAlertasOrgaosSemUsuarioCI();
						atualizaBadgeAlertasCI();
					}
				</cfoutput>
			});
			
			function mostraalertasOAOrientacoes(){
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAlertasIndex.cfc",
					data:{
						method: "alertasOAOrientacoesNavBar"
					},
					async: false
				})//fim ajax
				.done(function(result) {
					$('#alertasOAOrientacoesNavBarDiv').html(result)
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
			}

			function mostraAlertasOAOrientacoesSubordinados(){
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAlertasIndex.cfc",
					data:{
						method: "alertasOAOrientacoesSubordinadosNavBar"
					},
					async: false
				})//fim ajax
				.done(function(result) {
					$('#alertasOAOrientacoesSubordinadosNavBarDiv').html(result)
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
			}

			function mostraAlertasOAPropostasMelhoria(){
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAlertasIndex.cfc",
					data:{
						method: "alertasOAPropostasMelhoriaNavBar"
					},
					async: false
				})//fim ajax
				.done(function(result) {
					$('#alertasOAPropostasMelhoriaNavBarDiv').html(result)
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
			}

			function atualizaBadgeAlertas(){
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAlertasIndex.cfc",
					data:{
						method: "totalAlertas"
					},
					dataType: 'json',
					async: false
				})
				.done(function(result) {
					if(result.total === 0){
						$('#badgeAlertaOA').remove();
					} else {
						$('.navbar-badge').text(result.total);
					}
				})
				.fail(function(xhr, ajaxOptions, thrownError) {
					console.error('Erro ao obter total de alertas:', thrownError);
				});
			}

			function mostraAlertasPosicionamentosIniciaisCI(){
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAlertasIndex.cfc",
					data:{
						method: "alertasPosicionamentosIniciaisCINavBar"
					},
					async: false
				})//fim ajax
				.done(function(result) {
					$('#alertasPosicionamentosIniciaisCINavBarDiv').html(result)
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
			}

			function mostraAlertasOrgaosSemUsuarioCI(){
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAlertasIndex.cfc",
					data:{
						method: "alertasOrgaosSemUsuarioCINavBar"
					},
					async: false
				})//fim ajax
				.done(function(result) {
					$('#alertasOrgaosSemUsuarioCINavBarDiv').html(result)
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
			}

			function atualizaBadgeAlertasCI(){
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAlertasIndex.cfc",
					data:{
						method: "totalAlertasCI"
					},
					dataType: 'json',
					async: false
				})
				.done(function(result) {
					if(result.total === 0){
						$('#alertasDropdownCI').remove();
					} else {
						$('#badgeAlertaCI').text(result.total);
					}
				})
				.fail(function(xhr, ajaxOptions, thrownError) {
					console.error('Erro ao obter total de alertas:', thrownError);
				});
			}

			

			
		</script>
