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
						
				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-12">
						<div style="display: flex; align-items: center;">
							<h4 style="margin-right: 10px;">Indicadores: <strong>Acompanhamento Mês/Ano Corrente</strong></h4>
						</div>
						<p style="margin-right: 10px;">Atenção: As informações a seguir são fornecidas apenas para fins de acompanhamento, com o objetivo de auxiliar a gestão na melhoria dos indicadores. O resultado final do mês deve ser verificado em Consultas - Indicadores - Resultado Mensal, disponibilizado até o quinto dia útil do mês subsequente.</p>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" >
				
				

				<div id="divIndicadorDGCI"></div>

				
				<div id="divIndicadorPRCI"></div>
					

				<div id="divIndicadorSLNC"></div>

				
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

			// Obtém o mês atual
			const currentMonth = new Date().getMonth() + 1;
			
			$('#modalOverlay').modal('show')
			setTimeout(function() {	
				
				$.ajax({//AJAX PARA CONSULTAR OS INDICADORES
					type: "post",
					url: "cfc/pc_cfcIndicadores.cfc",
					data:{
						method:"resultadoDGCI_diario",
						ano:currentYear,
						mes:currentMonth
					},
					async: false,
					success: function(result) {	
						$('#divIndicadorDGCI').html(result);//INSERE OS INDICADORES NA DIV
						
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
					url: "cfc/pc_cfcIndicadores.cfc",
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
					url: "cfc/pc_cfcIndicadores.cfc",
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

			
			
			
		});

		

		
    </script>


</body>
</html>









