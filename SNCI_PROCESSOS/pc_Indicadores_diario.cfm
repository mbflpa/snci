<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="pt-br">
<head>
 	<meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SNCI</title>
		<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">	
        <link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">
		<style>
			textarea {
				text-align: justify!important;
			}
			.card-body{
				text-align: justify!important;
			}	
			.popover-body {
				text-align: justify!important;
			}
			.swal2-label{
				text-align:justify;
			}
			
			hr{
				display: block;
				margin-top: 5em!important;
				margin-bottom: 5em!important;
				margin-left: auto!important;
				margin-right: auto!important;
				border-style: inset!important;
				border-top: 3px solid rgba(0, 0, 0, 0.1)!important;
			}

			.nav-pills-abasIndicadoresDiario .nav-link-abasIndicadoresDiario {
				color: #3f4449!important;
				background-color: #ececec!important;
				border: 2px solid #f2f4f7 !important;
				border-radius: 10px!important;
				margin-right: 5px!important;
			}
			.nav-pills-abasIndicadoresDiario .nav-link-abasIndicadoresDiario.active, .nav-pills-abasIndicadoresDiario .show > .nav-link-abasIndicadoresDiario {
				color: #fff!important;
				background-color: #2581c8!important;
				border-color: #2581c8!important;
			}

			

			.nav-link-abasIndicadoresDiario:hover {
				border-color: #fbc32f7d!important;
				background-color: #fbc32f7d!important;
			}

		</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		
		<cfinclude template="pc_NavBar.cfm">

		<!-- Content Wrapper. Contains page content -->
		<div class="content-wrapper" >
			<!-- Content Header (Page header) -->
			
			<section class="content-header">
				<div class="container-fluid">
							
					<div class="row mb-2" style="margin-bottom:0px!important;">
						<div class="col-sm-12">
							<div style="display: flex; align-items: center;">
								<h4 style="margin-right: 10px;">Indicadores: <strong>Acompanhamento Mês/Ano Corrente</strong></h4>
							</div>
							<h6>Observações:</h6>
                            <ul >
                                <li>As informações a seguir são fornecidas apenas para fins de acompanhamento, com o objetivo de auxiliar a gestão na melhoria dos indicadores. O resultado final do mês deve ser verificado em Consultas - Indicadores - Resultado Mensal, disponibilizado até o quinto dia útil do mês subsequente;</li>
                                <li style="color:#dc3545">No momento, os resultados do indicador DGCI - Processos, demonstrados neste módulo, não são considerados no resultado do DGCI - Unidades, que consta no Plano de Trabalho das SE.</li>
                            </ul>
							
							<cfset mes = month(now())>
							<cfset mes = monthAsString(mes)>
							<cfset ano = year(now())>
							<cfoutput><h5 class="azul_claro_correios_textColor" >Resultado dos Indicadores do órgão #application.rsUsuarioParametros.pc_org_sigla#: <strong>#mes#/#ano#</strong></h5></cfoutput>
						
						
						</div>
					</div>
				</div><!-- /.container-fluid -->
			</section>
			<section class="content">
				<div class="container-fluid">
					<div id="divTabsIndicadores" >
						<div class="card-header p-0 pt-1" >
							<cfset orgaoAvaliado = application.rsUsuarioParametros.pc_org_orgaoAvaliado>
							<ul class="nav nav-pills nav-pills-abasIndicadoresDiario" id="myTabs" role="tablist" style="font-size:14px;">
								<li class="nav-item " style="text-align: center;">
									<a class="nav-link active  btn   nav-link-abasIndicadoresDiario " id="tabCardDGCIacompDiario" data-toggle="tab" href="#divCardDGCIacompDiarioContent" role="tab" aria-controls="divCardDGCIacompDiarioContent" aria-selected="true" ><i class="fa fa-chart-line"></i> DGCI<br>Resultado</a>
								</li>
								<cfif orgaoAvaliado eq 1>
									<li class="nav-item " style="text-align: center;">
										<a class="nav-link btn  nav-link-abasIndicadoresDiario " id="tabTabResumoDGCIorgaos" data-toggle="tab" href="#divTabResumoDGCIorgaosContent" role="tab" aria-controls="divTabResumoDGCIorgaosContent" aria-selected="false"><i class="fa fa-chart-line"></i> DGCI<br>órgãos subordinados</a>
									</li>
								</cfif>
								<cfif orgaoAvaliado eq 1>
									<li class="nav-item " style="text-align: center;">
										<a class="nav-link btn   nav-link-abasIndicadoresDiario" id="tabTabResumoPRCIorgaos" data-toggle="tab" href="#divTabResumoPRCIorgaosContent" role="tab" aria-controls="divTabResumoPRCIorgaosContent" aria-selected="false"><i class="fa fa-shopping-basket"></i> PRCI<br>órgãos subordinados</a>
									</li>
									<li class="nav-item " style="text-align: center;">
										<a class="nav-link btn   nav-link-abasIndicadoresDiario" id="tabTabResumoSLNCorgaos" data-toggle="tab" href="#divTabResumoSLNCorgaosContent" role="tab" aria-controls="divTabResumoSLNCorgaosContent" aria-selected="false"><i class="fa fa-shopping-basket"></i> SLNC<br>órgãos subordinados</a>
									</li>
								</cfif>
								<li class="nav-item " style="text-align: center;">
									<a class="nav-link btn   nav-link-abasIndicadoresDiario" id="tabIndicadorPRCI" data-toggle="tab" href="#divIndicadorPRCIContent" role="tab" aria-controls="divIndicadorPRCIContent" aria-selected="false"><i class="fa fa-database"></i> PRCI<br>detalhes</a>
								</li>
								<li class="nav-item " style="text-align: center;">
									<a class="nav-link btn   nav-link-abasIndicadoresDiario" id="tabIndicadorSLNC" data-toggle="tab" href="#divIndicadorSLNCContent" role="tab" aria-controls="divIndicadorSLNCContent" aria-selected="false"><i class="fa fa-database"></i> SLNC<br>detalhes</a>
								</li>
							</ul>
						
						</div>
						<div class="card-body">
							<div class="tab-content" id="myTabsContent" >
								<div class="tab-pane fade show active" id="divCardDGCIacompDiarioContent" role="tabpanel" aria-labelledby="tabCardDGCIacompDiario">
									<div style="display: flex; flex-direction: column; justify-content: center; align-items: center;width:800px">
										<div id="divCardDGCIacompDiario" style="width:800px;"></div>
										<div id="divCesta" style="width:740px;border: 1px solid #9f9b9b; border-radius:30px; padding-left: 20px;padding-right: 20px;padding-bottom:5px; margin-top:10px; display: none; flex-direction: column; justify-content: center; align-items: center;">
											<!-- Ícone de seta da Font Awesome -->
											<div style="position: relative; top: -19px;">
												<i class="fa fa-arrow-up" style="font-size:20px;color:#9f9b9b"></i>
											</div>
											
											<div id="divCardPRCIacompDiario" style="width:700px"></div>
											<div id="divCardSLNCacompDiario" style="width:700px"></div>
											
										</div>
									</div>
								</div>
								<cfif orgaoAvaliado eq 1>
									<div class="tab-pane fade" id="divTabResumoDGCIorgaosContent" role="tabpanel" aria-labelledby="tabTabResumoDGCIorgaos" >
										<h5 class="azul_claro_correios_textColor" >DGCI por órgão responsável:</h5>
										<div id="divTabResumoDGCIorgaos"></div>
									</div>
								</cfif>
								<cfif orgaoAvaliado eq 1>
									<div class="tab-pane fade" id="divTabResumoPRCIorgaosContent" role="tabpanel" aria-labelledby="tabTabResumoPRCIorgaos" >
										<h5 class="azul_claro_correios_textColor" >PRCI por órgão responsável:</h5>
										<div id="divTabResumoPRCIorgaos"></div>
									</div>
									<div class="tab-pane fade" id="divTabResumoSLNCorgaosContent" role="tabpanel" aria-labelledby="tabTabResumoSLNCorgaos" >
										<h5 class="azul_claro_correios_textColor" >SLNC por órgão responsável:</h5>
										<div id="divTabResumoSLNCorgaos"></div>
									</div>
								</cfif>
								<div class="tab-pane fade" id="divIndicadorPRCIContent" role="tabpanel" aria-labelledby="tabIndicadorPRCI" >
								
									<div id="divIndicadorPRCI"></div>
								</div>
								<div class="tab-pane fade" id="divIndicadorSLNCContent" role="tabpanel" aria-labelledby="tabIndicadorSLNC" >
									<div id="divIndicadorSLNC"></div>
								</div>
							</div>
						</div>

					</div>
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
    
        $(document).ready(function(){
			$(".content-wrapper").css("height", "auto");

			// Obtém o ano atual
			const currentYear = new Date().getFullYear();
			//const currentYear = 2023;
			// Obtém o mês atual
			const currentMonth = new Date().getMonth() + 1;
			//const currentMonth = 12;
			$('#modalOverlay').modal('show')
			setTimeout(function() {	
				
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"cardDGCI_AcompDiario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divCardDGCIacompDiario').html(result);//INSERE OS INDICADORES NA DIV
						
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"cardPRCI_AcompDiario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divCardPRCIacompDiario').html(result);//INSERE OS INDICADORES NA DIV
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"cardSLNC_AcompDiario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divCardSLNCacompDiario').html(result);//INSERE OS INDICADORES NA DIV
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
				
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"tabResumoPRCIorgaosResp_AcompDiario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divTabResumoPRCIorgaos').html(result);//INSERE OS INDICADORES NA DIV
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"tabResumoSLNCorgaosResp_AcompDiario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divTabResumoSLNCorgaos').html(result);//INSERE OS INDICADORES NA DIV
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"tabResumoDGCIorgaosResp_AcompDiario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divTabResumoDGCIorgaos').html(result);//INSERE OS INDICADORES NA DIV
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
				
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"tabPRCIDetalhe_diario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorPRCI').html(result);//INSERE OS INDICADORES NA DIV
						
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores_acomp_diario.cfc",
					data:{
						method:"tabSLNCDetalhe_diario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorSLNC').html(result);//INSERE OS INDICADORES NA DIV
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
						$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
							
					}
				})
	
			}, 1000);

			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
				//divCesta display flex
				$('#divCesta').css('display', 'flex');
			});
			
			
			
		});

		

		
    </script>


</body>
</html>









