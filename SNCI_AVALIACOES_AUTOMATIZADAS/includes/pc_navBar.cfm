<cfprocessingdirective pageencoding = "utf-8">
	 <cfinclude template="pc_Modal_preloader.cfm">
	 <cfinclude template="pc_modal_overlay.cfm">
	<!-- Navbar -->
		<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/animate.min.css">
		<nav class="main-header navbar navbar-expand navbar-light shadow-sm navbar_correios_backgroundColor2" style="height:56px;" >
			<!-- Left navbar links -->
			<ul class="navbar-nav " >
				<!---Retirado o botão de colapso do sidebar, pois o sidebar está sempre oculto
				<li class="nav-item" >
					<a class="nav-link " data-widget="pushmenu" data-enable-remember="true" href="#" role="button" data-auto-collapse-size="1600"><i class="fas fa-bars"  style="font-size:2rem;color:#fff"></i></a>
					<!--data-auto-collapse-size="2000" para forçar o sidebar a colapsar-->
				</li>
				--->
				 <cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
					<li class="nav-item d-none d-sm-inline-block" >
						<div style="display:flex;align-items:center;">
						    <img src="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png" class="brand-image"
						         style="height:44px;width:auto;margin-right:16px;vertical-align:middle;position:relative;top:0;left:0;">
						    <h3 class="nav-link" style="color:#000;margin:0;padding:0;">
						        SNCI - Avaliações Automatizadas
						        <span style="position:relative;margin-left:100px; font-size:11px">
						            <cfoutput>SERVIDOR: #Ucase(application.auxsite)#</cfoutput>
						        </span>
						    </h3>
						</div>
					</li>
				</cfif>
				
			</ul>
			
		</nav>
		
		<script language="JavaScript">
			// Garante que o sidebar fique sempre oculto e o navbar full width
			$(document).ready(function() {
				$('body').addClass('sidebar-collapse');
			});
		</script>
			

			
		</script>
