<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
 	<meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SNCI</title>
	<link rel="icon" type="image/x-icon" href="dist/img/icone_sistema_standalone_ico.png">	
	<link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">        
     

	<style>
			textarea {
				text-align: justify!important;
			}
			.card-body{
				text-align: justify!important;
			}
			.swal2-label{
				text-align:justify;
			}
	</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper" >
		<!-- Content Header (Page header) -->
		
		<section class="content-header">
			<div class="container-fluid">

				<div class="row mb-2" style="margin-top:20px;margin-bottom:0px!important;">
					<div class="col-sm-6">
						<h4>Acompanhamento <cfif #rsUsuarioParametros.pc_org_controle_interno# eq 'N'><i id="start-tour" style="color:#8cc63f" class="fas fa-question-circle grow-icon"></i></cfif></h4>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid">
				
				<div class="card card-primary card-tabs"  style="widht:100%">
					<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
						
						<ul class="nav nav-tabs" id="custom-tabs-one-tabAcomp" role="tablist" style="font-size:14px;">
							<li class="nav-item" style="">
								<a  class="nav-link  active" id="custom-tabs-one-OrientacaoAcomp-tab" onClick="javascript:ocultaInformacoes()"  data-toggle="pill" href="#custom-tabs-one-OrientacaoAcomp" role="tab" aria-controls="custom-tabs-one-OrientacaoAcomp" aria-selected="true">MEDIDAS/ORIENTAÇÕES PARA REGULARIZAÇÃO</a>
							</li>
							<cfif #rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-MelhoriaAcomp-tab" onClick="javascript:ocultaInformacoes();"  data-toggle="pill" href="#custom-tabs-one-MelhoriaAcomp" role="tab" aria-controls="custom-tabs-one-MelhoriaAcomp" aria-selected="true">PROPOSTAS DE MELHORIA</a>
								</li>
							</cfif>
						</ul>
					</div>
					<div class="card-body">
						<div class="tab-content" id="custom-tabs-one-tabContent" >
							<div disable class="tab-pane fade  active show" id="custom-tabs-one-OrientacaoAcomp"  role="tabpanel" aria-labelledby="custom-tabs-one-OrientacaoAcomp-tab" >														
								<div id="exibirTab"></div>
							</div>
							<cfif #rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
								<div disable class="tab-pane fade " id="custom-tabs-one-MelhoriaAcomp"  role="tabpanel" aria-labelledby="custom-tabs-one-MelhoriaAcomp-tab" >								
									<div id="exibirTabMelhoriasPendentes"></div>
								</div>			
							</cfif>
						</div>
					</div>
					
				</div>

				<div id="informacoesItensAcompanhamentoDiv"></div>

			</div>
		</section>
		<!-- /.content -->
	</div>
	<!-- /.content-wrapper -->
	<cfinclude template="pc_Footer.cfm">
	</div>
	<!-- ./wrapper -->
	<cfinclude template="pc_Sidebar.cfm">


	<script language="JavaScript">

	     $(document).ready(function() {	

			

            $('#start-tour').on('click', function() {
				hopscotch.endTour();
				hopscotch.configure({ i18n: customI18n1 }); // Configura as traduções personalizadas, se houver
				hopscotch.startTour(tourAcompanhamento);
			});

			var customI18n1 = {
				nextBtn: 'Próximo',
				prevBtn: 'Anterior',
				doneBtn: 'Concluir',
				skipBtn: 'Pular',
				closeTooltip: 'Fechar',
				stepNums: ['0', '1', '2', '3', '4', '5', '6', '7', '8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40'],
			};
			const tourAcompanhamento = {
				id: 'orgaoAvaliado-acompanhamento-tour',
				steps: [
					
					
					{
						title: '<p style="font-size:20px">Bem-vindo a página ACOMPANHAMENTO! </p>',
						content: 'Aqui você visualizará as Medidas/Orientações para regularização e as Propostas de Melhoria pendentes.<br><br>Clique em "Próximo" para iniciar um tour sobre as funcionalidades desta página ou no "X" para encerrar.',
						target: 'start-tour',
						placement: 'bottom',
						width: 500,
						xOffset: -15,
						onNext: function() {
							$("#custom-tabs-one-OrientacaoAcomp-tab").click();
						}
					},

					{
						title: 'MEDIDAS/ORIENTAÇÕES PARA REGULARIZAÇÃO',
						content: 'Nesta aba, são listadas todas as Medidas/Orientações para regularização cujo órgão responsável é o seu órgão de lotação.',
						target: 'custom-tabs-one-OrientacaoAcomp-tab',
						placement: 'right',  
						width: 520, 
						yOffset: -15,
						onNext: function() {
							
							if ($('#tabProcessos').length) {
								$(".fa-file-excel").addClass("grow-icon-tour");
							}else{//se não existir a tabela com as orientações, pula para a aba Propostas de Melhoria
								$("#custom-tabs-one-MelhoriaAcomp-tab").click();
							}
						},  
																		
					},
					{
						title: 'Exportar para Excel',
						content: 'Clicando neste ícone, você irá exportar o conteúdo desta tabela para o formato ".xlsx" do Excel.<br><br>Atenção! Se a tabela estiver filtrada, apenas os registros filtrados serão exportados.',
						target: '.fa-file-excel',
						placement: 'bottom',
						width: 450,
						xOffset:-20,
						onNext: function() {
							$(".fa-file-excel").removeClass("grow-icon-tour");
							$(".fa-filter").addClass("grow-icon-tour");
						},
						onPrev: function() {
								$(".fa-file-excel").removeClass("grow-icon-tour");  
						},  
						
					},
					{
						title: 'Visualizar Painéis de Filtragem',
						content: 'Clicando neste ícone, você irá visualizar todos os painéis de filtragem disponíveis. <br><br> Atenção! Caso apareça a mensagem "Sem painéis de filtragem relavantes para exibição", significa que não existe uma variedade de registros nas colunas que justifique a criação de painéis de filtragem.',
						target: '.fa-filter',
						placement: 'bottom',
						width: 450,
						xOffset:-18,
						onNext: function() {
							$(".fa-filter").removeClass("grow-icon-tour");
						},
						onPrev: function() {
							$(".fa-filter").removeClass("grow-icon-tour");  
							$(".fa-file-excel").addClass("grow-icon-tour");
						},  
						
					},
					{
						title: 'Procurar',
						content: 'Aqui, o texto ou número inserido filtrará todos os registros de todas as colunas da tabela. <br><br>Atenção! Este filtro afeta os painéis de filtragem, comentados na etapa anterior.',
						target: 'tabProcessos_filter',
						placement: 'bottom',
						width: 450,
						yOffset:-15,
						onPrev: function() {
							$(".fa-filter").addClass("grow-icon-tour");  
						},  
					},
					{
						title: 'Coluna mais informações',
						content: 'Nesta coluna, caso apareça um ícone "+", clicando nele você verá outras informações.',
						target: 'colunaMaisInfo',
						placement: 'top',
						width: 450,
						yOffset:45,  
					},

					{
						title: 'Coluna STATUS',
						content: 'Nesta coluna, são mostrados os status das medidas/orientações para regularização. Clicando sobre um status, serão disponibilizadas diversas outras informações, histórico de manifestações e o formulário para inclusão e encaminhamento de sua manifestação.',
						target: 'colunaStatus',
						placement: 'top',
						width: 450,
						yOffset:45,
						multipage: true,
						onNext: function() {
							$("#custom-tabs-one-OrientacaoAcomp-tab").click();
							$('td .statusOrientacoes').first().parent().click();
						}, 
					},

					//tab PROPOSTA DE MELHORIA
						{
							title: 'PROPOSTAS DE MELHORIA',
							content: 'Agora, vamos falar sobre a aba Propostas de Melhoria.<br>Nesta aba, são listadas todas as Propostas de Melhoria pendentes, sob responsabilidade do seu órgão de lotação.',
							target: 'custom-tabs-one-MelhoriaAcomp-tab',
							placement: 'right',  
							width: 400, 
							yOffset: -15,
							showPrevButton:false,

							onNext: function() {
								if ($('#tabMelhoriasPendentes').length) {
									
								}else{
									$('#custom-tabs-one-Orientacao-tab').click();
								}
							},
							
																		
						},
						{
							title: 'Coluna STATUS',
							content: 'Nesta coluna, são mostrados os status das Propostas de Melhoria.',
							target: 'colunaStatusProposta',
							placement: 'top',
							width: 450,	
							onNext: function() {
								$('#statusMelhorias').last().parent().click();
							}, 
										
						},
						{
							title: 'Coluna STATUS',
							content: 'Clicando sobre um status, serão disponibilizadas diversas outras informações e o formulário para aceitação, recusa ou troca da proposta de melhoria<.',
							target: 'tabMelhoriasPendentes',
							placement: 'bottom',
							width: 450,	
								
										
						},
						{
							title: '<p style="font-size:20px">Formulário Informar Status</p>',
							content: '<p>Ao clicar no status de uma Proposta de Melhoria, você visualizará as informações sobre o item ao qual essa Proposta de Melhoria pertence, além de diversas outras informações separadas por abas.</p>',
							target: 'formManifMelhorias',
							placement: 'top',
							width: 500,
							xOffset: -15,
							onNext: function() {
								$('#custom-tabs-one-Melhoria-tab').click();
							},
							
						},
						{
							title: '<p style="font-size:20px">Proposta de Melhoria p/ Manifestação</p>',
							content: '<p>Nesta aba, selecione o status da Proposta de Melhoria, preencha os demais campos que aparecerão após a seleção e clique em Enviar.</p>',
							target: 'custom-tabs-one-Melhoria-tab',
							placement: 'top',
							width: 500,
							xOffset: -15,
							onNext: function() {
								$('#custom-tabs-one-Orientacao-tab').click();
							},
							
						},
						
					
							
						//apenas para continuar tour                      
						{
							title: '',
							content: '',
							target: 'para-continuar--',
							placement: 'top',
							width: 500,
							
						},
					

				],
					showPrevButton: true,
					i18n: customI18n1, // Use as opções de i18n personalizadas definidas acima
				
					onClose: function() {
							$(".fa-file-excel").removeClass("grow-icon-tour"); 
							$(".fa-filter").removeClass("grow-icon-tour");  
						},
					
			};

            // // Função para iniciar o tour automaticamente
			// function iniciarTourAutomaticamente() {
			// 	hopscotch.configure({ i18n: customI18n1 }); // Configura as traduções personalizadas, se houver
			// 	hopscotch.startTour(tourAcompanhamento);
			// }

			// // Chame a função para iniciar o tour após a página ser carregada
			// iniciarTourAutomaticamente();  
           

        });

		$(window).on("load",function(){
           <cfoutput> var contIterno = '#rsUsuarioParametros.pc_org_controle_interno#'</cfoutput>
			if(contIterno =='N'){
				exibirTabelaMelhoriasPendentes()
			}
			
			exibirTabela();		
			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
			});	

			
				$('#custom-tabs-one-MelhoriaAcomp-tab').text = "dhfjjdksfhjds";
		});


		function exibirTabela(){
			$('#modalOverlay').modal('show')
			setTimeout(function() {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAcompanhamentos.cfc",
					data:{
						method: "tabAcompanhamento",
					},
					async: false,
					success: function(result) {
						$('#exibirTab').html(result)
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

		function exibirTabelaMelhoriasPendentes(){
			$('#modalOverlay').modal('show')
			setTimeout(function() {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAcompanhamentos.cfc",
					data:{
						method: "tabMelhoriasPendentes",
					},
					async: false,
					success: function(result) {
						$('#exibirTabMelhoriasPendentes').html(result)
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


		function ocultaInformacoes(){
			$('#informacoesItensAcompanhamentoDiv').html('')
		}

		$(window).on('beforeunload', function() {
			// Verificar se o DataTable está inicializado na tabela
			if ($.fn.DataTable.isDataTable('#tabProcessos')) {
				// Obter a referência do DataTable
				var tabela = $('#tabProcessos').DataTable();

				// Limpar o estado salvo do DataTable
				tabela.state.clear();
			}
		});

		




			
		
	</script>

</body>
</html>
