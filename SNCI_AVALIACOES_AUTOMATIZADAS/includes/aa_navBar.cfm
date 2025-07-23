<cfprocessingdirective pageencoding = "utf-8">
	 <cfinclude template="aa_Modal_preloader.cfm">
	 <cfinclude template="aa_modal_overlay.cfm">

	 <style>
		.tituloPagina{
            color: var(--azul_correios);
            margin: 0;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
			display:block; 
			text-align:left;
			font-size:1.1rem;
			font-weight:600;
			color:var(--azul_correios);
          }
		  .nomeModulo{
			color: var(--azul_correios);
            margin: 0;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
			display:block; 
			text-align:left;
			font-size:1rem;
			font-weight:600;
			color:var(--azul_correios);
		  }
	 </style>
	<!-- Navbar -->
		<link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/animate.min.css">
		<nav class="main-header navbar navbar-expand navbar-light shadow-sm " style="height:56px;padding-right: 0;">
			<ul class="navbar-nav w-100 d-flex justify-content-start align-items-center" style="width:100%;margin:0;padding:0;">
				<li class="nav-item">
					<a class="nav-link" data-widget="pushmenu" data-enable-remember="true" href="#" role="button" data-auto-collapse-size="1600" style="display:flex;align-items:center;height:56px;">
						<i class="fas fa-bars" style="font-size:2rem;color:gray"></i>
					</a>
				</li>
				<li class="nav-item d-none d-sm-inline-block " style="overflow:hidden;">
					<span class="tituloPagina">Análise das Não Conformidades - <cfoutput>#application.rsUsuarioParametros.Und_Descricao#</cfoutput></span>
				</li>
			
				<li class="nav-item d-none d-sm-inline-block ml-auto" style="background-color:var(--amarelo_prisma_escuro_correios);height:56px;position:relative;overflow:hidden;">
					<!-- Elemento decorativo com ângulo -->
					<div class="navbar_correios_backgroundColor_logo">
					</div>
					<div style="display:flex;align-items:center;height:100%;margin-left:32px;margin-right: 25px;">
						<img src="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png" class="brand-image"
							style="height:44px;width:auto;margin-right:5px;vertical-align:middle;">
						<div style="display:flex;flex-direction:column;line-height:1.1;position:relative;">
							<span class="nomeModulo">SNCI - Avaliações Automatizadas</span>
							<span style="font-size:9px;color:red;position:absolute;top:22px;left:0;">
								<cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
									<cfoutput>SERVIDOR: #Ucase(application.auxsite)#</cfoutput>
								<cfelse>
									SERVIDOR: PRODUÇÃO
								</cfif>
							</span>
						</div>
					</div>
				</li>
			</ul>
		</nav>
		
		<script language="JavaScript">
			// Garante que o sidebar fique sempre oculto e o navbar full width
			$(document).ready(function() {
				//$('body').addClass('sidebar-collapse');
			});
	
		</script>

