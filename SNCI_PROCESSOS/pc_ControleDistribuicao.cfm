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
			.swal2-label{
				text-align:justify;
			}
	</style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height" >
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		
		<cfinclude template="includes/pc_navBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper" >
		<!-- Content Header (Page header) -->
		<section class="content-header">
			<div class="container-fluid">

				<div class="row mb-2" style="margin-bottom:0px!important;">
					<div class="col-sm-6">
						<h4>Controle das Distribuições
						<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
							<!--<i id="start-tour" style="color:#8cc63f" class="fas fa-question-circle grow-icon"></i>-->
						</cfif>
						</h4>
					</div>
				</div>
			</div><!-- /.container-fluid -->
		</section>


		<!-- Main content -->
		<section class="content">
			<div class="container-fluid">
				
				<div class="card card-primary card-tabs card_border_correios"  style="width:100%">
					<div class="card-header p-0 pt-1 card-header_backgroundColor" >
						
						<ul class="nav nav-tabs" id="custom-tabs-one-tabAcomp" role="tablist" style="font-size:14px;">
							<li class="nav-item">
								<a  class="nav-link  active" id="custom-tabs-one-OrientacaoAcomp-tab" onClick="javascript:ocultaInformacoes()"  data-toggle="pill" href="#custom-tabs-one-OrientacaoAcomp" role="tab" aria-controls="custom-tabs-one-OrientacaoAcomp" aria-selected="true">MEDIDAS/ORIENTAÇÕES PARA REGULARIZAÇÃO</a>
							</li>
							<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-MelhoriaAcomp-tab" onClick="javascript:ocultaInformacoes();"  data-toggle="pill" href="#custom-tabs-one-MelhoriaAcomp" role="tab" aria-controls="custom-tabs-one-MelhoriaAcomp" aria-selected="true">PROPOSTAS DE MELHORIA</a>
								</li>
							</cfif>
						</ul>
					</div>
					<div class="card-body ">
						<div class="tab-content" id="custom-tabs-one-tabContent" >
							<div disable class="tab-pane fade  active show" id="custom-tabs-one-OrientacaoAcomp"  role="tabpanel" aria-labelledby="custom-tabs-one-OrientacaoAcomp-tab" >														
								<div id="exibirTab"></div>
								
							</div>
							<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
								<div disable class="tab-pane fade " id="custom-tabs-one-MelhoriaAcomp"  role="tabpanel" aria-labelledby="custom-tabs-one-MelhoriaAcomp-tab" >								
									<div id="exibirTabMelhoriasPendentes"></div>

								</div>			
							</cfif>
						</div>
					</div>
					
				</div>

				<div id="infItensOrientacoesDistribuidasDiv"></div>

			</div>
		</section>
		<!-- /.content -->
	</div>
	<!-- /.content-wrapper -->
	<cfinclude template="includes/pc_footer.cfm">
	</div>
	<!-- ./wrapper -->
	<cfinclude template="includes/pc_sidebar.cfm">


	<script language="JavaScript">


		$(window).on("load",function(){
           <cfoutput> var contIterno = '#application.rsUsuarioParametros.pc_org_controle_interno#'</cfoutput>
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
					url: "cfc/pc_cfcControleDistribuicao.cfc",
					data:{
						method: "tabOrientacoesDistribuidas",
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
					url: "cfc/pc_cfcControleDistribuicao.cfc",
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
			$('#infItensOrientacoesDistribuidasDiv').html('')
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
