<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>

<html lang="en" dir="ltr" style="height: auto;">

	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
  		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>SNCI</title>
		<link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">
	</head>	

	<body id="bodyAvaliacoes" class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
		<div class="wrapper">

			<cfinclude template="pc_Modal_preloader.cfm">
			<cfinclude template="pc_NavBar.cfm">
		
			<!-- Content Wrapper. Contains page content -->
			<div class="content-wrapper" >
				<!-- Content Header (Page header) -->
				<div class="content-header" style="background:  #f4f6f9;">
					<div class="container-fluid">
						<div class="row mb-2" style="margin-top:10px;margin-bottom:0px!important;">
							<div class="col-sm-6">
								<h4>Cadastrar Avaliações do Processo</h4>
							</div>
						</div>
					
												
						<div id="cardsAvaliacao"></div>
										
						<div id="cadAvaliacaoForm"></div>
						
					</div><!--Fim container-fluid-->
					


				</div><!--Fim ontent-header-->



			</div><!--Fim content-wrapper-->
		
									
	       <cfinclude template="pc_Footer.cfm">
		</div><!--Fim wrapper-->
		
		<cfinclude template="pc_Sidebar.cfm">


		<script language="JavaScript">

			

			$(window).on("load",function(){
				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});	
				mostraCads()
			});
			
		    

			$(function () {
				$('[data-mask]').inputmask()
			})

			

			function mostraCads(){

				$.ajax({
					type: "post",
					url: "cfc/pc_cfcAvaliacoes.cfc",
					data:{
						method:"cardsAvaliacao"
					},
					async: false,
					success: function(result) {	
						$('#cardsAvaliacao').html(result);
					},
					error: function(xhr, ajaxOptions, thrownError) {
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)				
					}
				})	

			}

			//ABRE O FORM PARA UPLOAD DA AVALIAÇÃO, ANEXOS, RECOMENDAÇÕES, ETC...
			function mostraCadastroAvaliacaoRelato(idAvaliacao,linha) {
				//event.preventDefault()
				//event.stopPropagation()

				$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
                $('#modalOverlay').modal('show')
				
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: 'cadastroAvaliacaoRelato',
							idAvaliacao:idAvaliacao
							
						},
						async: false
					})//fim ajax
					.done(function(result) {
						resetFormFields();
						$('#CadastroAvaliacaoRelato').html(result)
						$('html, body').animate({ scrollTop: ($('#CadastroAvaliacaoRelato').offset().top)} , 500);
						
						$('#modalOverlay').delay(2000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});	
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});	
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
		
					});
				}, 500);
				
			}

		



		</script>
		
		

	</body>




</html>