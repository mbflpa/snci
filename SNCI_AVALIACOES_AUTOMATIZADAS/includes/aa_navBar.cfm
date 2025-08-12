<cfprocessingdirective pageencoding = "utf-8">

<!--- Adicionar cfparam para url.mesFiltro no início do arquivo --->
<cfparam name="url.mesFiltro" default="">

	 <cfinclude template="aa_Modal_preloader.cfm">
	 <cfinclude template="aa_modal_overlay.cfm">
 <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/animate.min.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/fontawesome-free/css/fontawesome.min.css">
    <!-- Tempusdominus Bootstrap 4 -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
    
    
    <!-- overlayScrollbars -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
    <!-- Daterange picker -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/daterangepicker/daterangepicker.css">

    <!-- SweetAlert2 -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.css">
    <!-- Toastr -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/toastr/toastr.css">
    <!-- Bootstrap4 Duallistbox -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/bootstrap4-duallistbox/bootstrap-duallistbox.css">
    <!-- Select2 -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/select2/css/select2.min.css">
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css">

    
      <!-- DataTables -->
      <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/datatables/datatables.min.css">
          
      <!-- Theme style -->
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/adminlte.min.css">
    <link rel="stylesheet" href="../SNCI_AVALIACOES_AUTOMATIZADAS/dist/css/stylesSNCI.css">
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
		  
		  /* Estilos para os botões de mês */
		  .meses-container {
			margin-top: -3px;
			display: flex;
			flex-wrap: wrap;
			gap: 3px;
			align-items: center;
		  }
		  
		  .btn-mes {
			background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
			border: 1px solid #dee2e6;
			color: #495057;
			padding: 3px 10px;
			border-radius: 20px;
			font-size: 0.75rem;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.3s ease;
			text-decoration: none;
			white-space: nowrap;
			box-shadow: 0 1px 3px rgba(0,0,0,0.1);
		  }
		  
		  .btn-mes:hover {
			background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
			color: white;
			border-color: #0056b3;
			transform: translateY(-1px);
			box-shadow: 0 2px 6px rgba(0,123,255,0.3);
			text-decoration: none;
		  }
		  
		  .btn-mes.active {
			background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);
			color: white;
			border-color: #1e7e34;
			box-shadow: 0 2px 6px rgba(40,167,69,0.3);
		  }
		  
		  .btn-mes.loading {
			background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%);
			color: #212529;
			border-color: #e0a800;
		  }
		  
		  .meses-label {
			color: var(--azul_correios);
			font-size: 0.8rem;
			font-weight: 600;
			margin-right: 8px;
		  }
		  
		  .meses-scroll {
			display: flex;
			gap: 3px;
			overflow-x: auto;
			padding: 2px;
			max-width: 100%;
		  }
		  
		  .meses-scroll::-webkit-scrollbar {
			height: 4px;
		  }
		  
		  .meses-scroll::-webkit-scrollbar-track {
			background: #f1f1f1;
			border-radius: 2px;
		  }
		  
		  .meses-scroll::-webkit-scrollbar-thumb {
			background: #c1c1c1;
			border-radius: 2px;
		  }
		  
		  .meses-scroll::-webkit-scrollbar-thumb:hover {
			background: #a1a1a1;
		  }
		  
		 
		  
		 
		  .popover .popover-body {
			text-align: justify !important;
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
					<div style="display: flex; flex-direction: column;">
						<span class="tituloPagina">
							<i id="info-icon" class="info-icon-automatizadas" style="position: relative;right:-3px;bottom: 6px;text-shadow:none!important;"
								data-toggle="popover" 
								data-trigger="hover" 
								data-placement="bottom" 
								data-html="true"
								data-content="<strong>Avaliação Automatizada:</strong> Processo de avaliação automatizada dos testes de controles internos realizados no âmbito de unidades operacionais das Superintendências Estaduais.">
							</i>
							Avaliação Automatizada - 
							<cfif structKeyExists(application, "rsUsuarioParametros") AND structKeyExists(application.rsUsuarioParametros, "Und_Descricao") AND len(trim(application.rsUsuarioParametros.Und_Descricao))>
								<cfoutput>#application.rsUsuarioParametros.Und_Descricao# - #application.rsUsuarioParametros.Dir_Sigla#<span style="font-weight:400;font-size:0.8rem;margin-left:10px">(MCU: #application.rsUsuarioParametros.Und_MCU# / STO: #application.rsUsuarioParametros.Und_Codigo#)</span></cfoutput>
							<cfelse>
								<span style="color: #e63946;">Unidade Não Localizada</span>
							</cfif>
						</span>
						
						<!-- Container dos botões de mês -->
						<div class="meses-container">
							<span class="meses-label">
							<i id="info-icon" class="info-icon-automatizadas" style="position: relative;right: -3px;bottom: 6px;"
							   data-toggle="popover" 
							   data-trigger="hover" 
							   data-placement="bottom" 
							   data-html="true"
							   data-content="<strong>Mês:</strong> Refere-se ao período contemplado no processamento da avaliação automatizada."></i>
							   Mês:
							</span>
							<div class="meses-scroll" id="mesesContainer">
								<cfif structKeyExists(application, "rsUsuarioParametros") AND structKeyExists(application.rsUsuarioParametros, "Und_Descricao") AND len(trim(application.rsUsuarioParametros.Und_Descricao))>
									<button class="btn-mes loading" id="loadingMeses">
										<i class="fas fa-spinner fa-spin"></i> Carregando...
									</button>
								<cfelse>
									<span style="color: #e63946; font-size: 0.75rem;">Unidade necessária para carregar períodos</span>
								</cfif>
							</div>
						</div>
					</div>
				</li>
			
				<li class="nav-item d-none d-sm-inline-block ml-auto" style="background-color:var(--amarelo_prisma_escuro_correios);height:56px;position:relative;overflow:hidden;">
					<!-- Elemento decorativo com ângulo -->
					<div class="navbar_correios_backgroundColor_logo">
					</div>
					<div style="display:flex;align-items:center;height:100%;margin-left:30px;margin-right: 25px;">
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
		 <!-- jQuery -->
<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/jquery/jquery.min.js"></script>
<!-- Popper.js (se Bootstrap 4) -->
<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/popper/umd/popper.min.js"></script>
<!-- Bootstrap JS -->
<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- jQuery UI -->
<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/jquery-ui/jquery-ui.min.js"></script>
<!-- Select2 -->
<script src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/select2/js/select2.full.min.js"></script>
 <!-- DataTables  & Plugins -->
<script  src="../SNCI_AVALIACOES_AUTOMATIZADAS/plugins/datatables/datatables.min.js"></script>
<script language="JavaScript">
	

	$(document).ready(function() {
		// Inicializa todos os popovers
		$('[data-toggle="popover"]').popover({
			html: true,
			trigger: 'hover'
		});
		
		// Popover com dismiss específico
		$('.popover-dismiss').popover({
			trigger: 'hover'
		});


		
		// Carregar meses disponíveis
		carregarMesesDisponiveis();
		
		// Verificar se há filtro de mês na URL e marcar botão ativo
		verificarMesSelecionadoURL();

		// Simula clique no link "Principal" do sidebar ao carregar a página
		setTimeout(function() {
			var $principalLink = $('#sidebarPrincipal');
			var isMensagemTemporaria = window.location.pathname.toLowerCase().indexOf('aa_mensagem_temporaria.cfm') !== -1;
			var isIndex = window.location.pathname.toLowerCase().indexOf('index.cfm') !== -1;
			// Só dispara se está na index e não na aa_mensagem_temporaria.cfm
			if ($principalLink.length > 0 && isIndex && !isMensagemTemporaria) {
				$principalLink[0].click();
			}
		}, 300);
	});
	
	// Função para verificar mês selecionado na URL
	function verificarMesSelecionadoURL() {
		var urlParams = new URLSearchParams(window.location.search);
		var mesFiltro = urlParams.get('mesFiltro');
		if (mesFiltro) {
			// Aguardar carregamento dos botões e depois marcar o ativo
			setTimeout(function() {
				$('.btn-mes').removeClass('active');
				$('.btn-mes[data-mes-id="' + mesFiltro + '"]').addClass('active');
				
				// Também atualizar o link ativo do sidebar
				if (typeof setActiveLink === 'function') {
					setActiveLink();
				}
				
				// Atualizar links do sidebar com filtro de mês
				if (typeof atualizarLinksComFiltroMes === 'function') {
					atualizarLinksComFiltroMes();
				}
			}, 200);
		}
	}
	
	// Função para carregar meses disponíveis
	function carregarMesesDisponiveis() {
		<cfif structKeyExists(application, "rsUsuarioParametros") AND structKeyExists(application.rsUsuarioParametros, "Und_Descricao") AND len(trim(application.rsUsuarioParametros.Und_Descricao))>
		$.ajax({
			url: '../SNCI_AVALIACOES_AUTOMATIZADAS/cfc/DeficienciasControleDados.cfc?method=obterMesesDisponiveis',
			type: 'POST',
			dataType: 'json',
			success: function(response) {
				if (response.success && response.data.length > 0) {
					renderizarBotoesMeses(response.data);
					// Após renderizar os botões, verificar URL e atualizar sidebar
					setTimeout(function() {
						verificarMesSelecionadoURL();
						if (typeof setActiveLink === 'function') {
							setActiveLink();
						}
						// Atualizar links do sidebar com filtro de mês
						if (typeof atualizarLinksComFiltroMes === 'function') {
							atualizarLinksComFiltroMes();
						}
					}, 100);
				} else {
					$('#mesesContainer').html('<span style="color: #6c757d; font-size: 0.75rem;">Nenhum período disponível</span>');
				}
			},
			error: function(xhr, status, error) {
				console.error('Erro ao carregar meses:', error);
				$('#mesesContainer').html('<span style="color: #dc3545; font-size: 0.75rem;">Erro ao carregar períodos</span>');
			}
		});
		<cfelse>
		// Não carregar meses se unidade não localizada
		console.warn('Unidade não localizada - não é possível carregar meses');
		</cfif>
	}
	
	// Função para renderizar botões dos meses
	function renderizarBotoesMeses(meses) {
		var container = $('#mesesContainer');
		container.empty();
		
		// Verificar se há filtro ativo na URL
		var urlParams = new URLSearchParams(window.location.search);
		var mesFiltroAtivo = urlParams.get('mesFiltro');
		
		meses.forEach(function(mes, index) {
			var btnClass = 'btn-mes';
			
			// Se há filtro na URL, marcar como ativo o mês correspondente
			// Se não há filtro, marcar o primeiro como ativo
			if (mesFiltroAtivo) {
				if (mes.id === mesFiltroAtivo) {
					btnClass += ' active';
				}
			} else if (index === 0) {
				btnClass += ' active';
			}
			
			var btn = $('<button>')
				.addClass(btnClass)
				.attr('data-mes-id', mes.id)
				.attr('title', mes.nome + '/' + mes.ano + ' - ' + mes.totalRegistros + ' eventos')
				.html(mes.nome)
				.click(function() {
					selecionarMes(mes.id, $(this));
				});
			
			container.append(btn);
		});
	}
	
	// Função para selecionar um mês
	function selecionarMes(mesId, btnElement) {
		console.log('selecionarMes chamado com mesId:', mesId);
		$('.btn-mes').removeClass('active');
		btnElement.addClass('active');

		var recarregouAlguma = false;
		$('.tab-pane').each(function(index) {
			var $iframe = $(this).find('iframe');
			if ($iframe.length) {
				var iframeSrc = $iframe.attr('src') || '';
				console.log('Aba', index, 'iframe src original:', iframeSrc);

				// Remove barra inicial, se existir
				if (iframeSrc.charAt(0) === '/') {
					iframeSrc = iframeSrc.substring(1);
					console.log('Aba', index, 'src sem barra inicial:', iframeSrc);
				}
				// Se não tiver o prefixo correto, adiciona
				if (!iframeSrc.toLowerCase().startsWith('snci/snci_avaliacoes_automatizadas/')) {
					iframeSrc = 'snci/SNCI_AVALIACOES_AUTOMATIZADAS/' + iframeSrc;
					console.log('Aba', index, 'src com prefixo:', iframeSrc);
				}

				var urlObj = new URL(iframeSrc, window.location.origin);
				console.log('Aba', index, 'URL antes do filtro:', urlObj.pathname + urlObj.search);

				urlObj.searchParams.set('mesFiltro', mesId);
				console.log('Aba', index, 'URL final:', urlObj.pathname + urlObj.search);

				$iframe.attr('src', urlObj.pathname + urlObj.search);
				recarregouAlguma = true;
			} else {
				console.log('Aba', index, 'não possui iframe');
			}
		});
		if (!recarregouAlguma) {
			console.log('Nenhuma aba aberta, recarregando página principal');
			var urlAtual = new URL(window.location);
			urlAtual.searchParams.set('mesFiltro', mesId);
			console.log('URL principal:', urlAtual.toString());
			window.location.href = urlAtual.toString();
		}
	}


</script>

