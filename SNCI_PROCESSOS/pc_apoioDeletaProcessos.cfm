<cfprocessingdirective pageencoding = "utf-8">


<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>SNCI</title>
<link rel="icon" type="image/x-icon" href="dist/img/icone_sistema_standalone_ico.png">

</head>

<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">


	<div class="wrapper">

		<div class="modal fade" id="modal-danger">
			<div class="modal-dialog">
				<div class="modal-content bg-danger">
				<div class="modal-header" >
					<h4 class="modal-title">Danger Modal</h4>
					<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
					</button>
				</div>
				<div class="modal-body">
					<p>One fine body&hellip;</p>
				</div>
				<div class="modal-footer justify-content-between">
					<button type="button" class="btn btn-outline-light" data-dismiss="modal">Fechar</button>
				</div>
				</div>
				<!-- /.modal-content -->
			</div>
			<!-- /.modal-dialog -->
		</div>
		<!-- /.modal -->
		

		
        <cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">
		
		<!-- Content Wrapper. Contains page content -->
		<div class="content-wrapper" >
		
			<!-- Content Header (Page header) -->
			<div class="content-header" style="background:  #f4f6f9;">
			
				<div class="container-fluid">
				<h4>Excluir Processos</h4>
				
					<div class="card-body" >

                  
						
						<div id="exibirTab"></div>

							
					</div>	<!-- fim card-body -->

					
			
					
				</div>


				
			</div>

			
			
		</div>
			
		<cfinclude template="pc_Footer.cfm">
		




		
	</div>
	<cfinclude template="pc_Sidebar.cfm">
	
	<!-- Select2 -->
	<script src="plugins/select2/js/select2.full.min.js"></script>
	<!-- Select2 -->
	<link rel="stylesheet" href="plugins/select2/css/select2.min.css">
	<link rel="stylesheet" href="plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css">

	


	<script language="JavaScript">




		$(window).on("load",function(){
	        //$('#modalOverlay').modal('show');
			exibirTabela();
			//$('#modalOverlay').modal('hide');


		});

        

		function processoDel(numProcesso) {
				
			event.preventDefault()
        	event.stopPropagation()
			
			var mensagem = "Deseja excluir o processo <strong style='color:red'>" + numProcesso + "</strong>?<br>Atenção!<br>Todos os anexos, posicionamentos, orientações e itens deste processo também serão excluídos definitivamente.<br><strong style='color:red'>Esta operação não poderá ser desfeita.</strong>"
			swalWithBootstrapButtons.fire({//sweetalert2
			html: logoSNCIsweetalert2(mensagem),
			showCancelButton: true,
			confirmButtonText: 'Sim!',
			cancelButtonText: 'Cancelar!'
			}).then((result) => {
				if (result.isConfirmed) {
					$('#modalOverlay').modal('show');
					setTimeout(function() {
						$.ajax({
							type: "GET",
							url: "cfc/pc_cfcProcessos.cfc",
							data:{
								method: "deletarTodoProcesso",
								numProc: numProcesso
							},
							async: false
							
						})//fim ajax
						.done(function(result) {
							exibirTabela()
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
								toastr.success('Operação realizada com sucesso!');
							});
							
						})//fim done
						.fail(function(xhr, ajaxOptions, thrownError) {
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)
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
			
		}
		
			

		function exibirTabela(){
		
			$.ajax({
				type: "post",
				url: "cfc/pc_cfcProcessos.cfc",
				data:{
					method: "tabProcessosTODOS",
				},
				async: false,
				success: function(result) {
					$('#exibirTab').html(result)
				},
				error: function(xhr, ajaxOptions, thrownError) {
					$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(thrownError)
				}
			})	
			
			
		}
        
        


		


	
	</script>


</body>





</html>

























