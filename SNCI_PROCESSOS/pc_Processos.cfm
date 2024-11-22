<cfprocessingdirective pageencoding = "utf-8">



<!DOCTYPE html>
<html lang="pt-br">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">

	<title>SNCI</title>
	<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">
   
</head>
<body id="bodyPrincipal" class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
	<div class="wrapper">

		
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
							
					<div id="formCadProcesso" class="card-body" style="display:flex;flex-direction:column;"></div>	
					
					<div class="card-body" style="display:flex;flex-direction:column;">
						<div style="justify-content:right;  width: 100%;">
							<div style="margin-right: 30px;float:right">
								<i id="btExibirTab" class=" fas fa-th" style="font-size:40px;color: #2581c8;cursor:pointer" title ="Exibir Tabela"></i>
							</div>
						</div>
						
						<div id="exibirTab" ></div>
						
							
					</div>	<!-- fim card-body -->
											
				</div>
			</div>
			
		</div>
			
		<cfinclude template="pc_Footer.cfm">
		
	</div>
	<cfinclude template="pc_Sidebar.cfm">		

	<script language="JavaScript">

		$(document).ready(function(){

			$('#modalOverlay').modal('show')
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

			exibirFormCadProcesso();

			
		});

		function exibirFormCadProcesso(){
			$('#modalOverlay').modal('show');
			setTimeout(function() {
				$.ajax({
					url: 'cfc/pc_cfcProcessos.cfc',
					data: {
						method: 'formCadProc',
					},
					async: false
				})
				.done(function(response){
					$("#formCadProcesso").html(response);
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

			},500);
		}

		
		function exibirTabela(){
			$('#modalOverlay').modal('show')
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
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
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
			});	
	
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
