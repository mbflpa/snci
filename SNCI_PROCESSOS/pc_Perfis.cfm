
<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
 	<meta charset="UTF-8">
  	<meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>SNCI</title>
		      
        <!-- Font Awesome -->
        <link rel="stylesheet" href="plugins/fontawesome-free/css/all.min.css">
        <!-- Tempusdominus Bootstrap 4 -->
        <link rel="stylesheet" href="plugins/tempusdominus-bootstrap-4/css/tempusdominus-bootstrap-4.min.css">
        <!-- iCheck -->
        <link rel="stylesheet" href="plugins/icheck-bootstrap/icheck-bootstrap.min.css">
             <!-- Theme style -->
        <link rel="stylesheet" href="dist/css/adminlte.css">
        <!-- overlayScrollbars -->
        <link rel="stylesheet" href="plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
        <!-- Daterange picker -->
        <link rel="stylesheet" href="plugins/daterangepicker/daterangepicker.css">
   
		<!-- SweetAlert2 -->
		<link rel="stylesheet" href="plugins/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
		<!-- Toastr -->
		<link rel="stylesheet" href="plugins/toastr/toastr.css">

		<!-- Select2 -->
		<link rel="stylesheet" href="plugins/select2/css/select2.min.css">
		<link rel="stylesheet" href="plugins/select2-bootstrap4-theme/select2-bootstrap4.min.css"> 
		 

		
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
	<!-- Site wrapper -->
	<div class="wrapper">
	
		
		<cfinclude template="pc_Modal_preloader.cfm">
		<cfinclude template="pc_NavBar.cfm">

	<!-- Content Wrapper. Contains page content -->
	<div class="content-wrapper" style="height:auto">
		<!-- Content Header (Page header) -->
		
		

		<!-- Main content -->
		<section id = "content" class="content">
			<div class="container-fluid">
				
			
				<!-- /.card-header -->
				<div class="card-body" >
				
					<form id="formCadFerfis" name="formCadFerfis" class="row g-3 needs-validation was-validated" novalidate format="html"  style="height: auto;">
						<div id="cadastroPerfis" class="card card-primary collapsed-card" >
							<div  class="card-header" style="background-color: #0083ca;color:#fff;">
								<a   class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:16px;" data-card-widget="collapse">
									<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
									</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um novo Perfil</span>
								</a>
								
							</div>
							
							<input id="perfilId" hidden>

							<div class="card-body" style="border: solid 3px #0083ca">
								<div class="row" style="font-size:14px">

									<div class="col-sm-9">
										<div class="form-group">
											<label for="perfilDescricao" >Nome do Perfil:</label>
											<input id="perfilDescricao"  required=""  name="perfilDescricao" type="text" class="form-control "  inputmode="text" placeholder="Informe o nome do perfil...">
										</div>
									</div>
									<div id="perfilStatusDiv" class="col-sm-3" hidden>
										<div class="form-group">
											<label for="perfilStatus">Status:</label>
											<select id="perfilStatus" required="" name="perfilStatus" class="form-control"  style="height:40px;">
											    <option selected="" disabled="" value=""></option>
												<option  value="A" >Ativo</option>
												<option  value="D" >Desativado</option>
											</select>
										</div>
									</div>
									<br>
									<div class="col-sm-12">
										<div class="form-group">
											<label for="perfilComentario">Comentário:</label>
											<textarea class="form-control" id="perfilComentario" rows="3" required="" style=""  name="perfilComentario" class="form-control" placeholder="Informe o significado do perfil..."></textarea>
										</div>										
									</div>
									



									<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
										<div id="btSalvarDiv" >
											<button id="btSalvar" class="btn btn-block btn-primary " >Salvar</button>
											
										
										</div>
										<div style="margin-left:100px">
											
											<button id="btCancelar"  class="btn btn-block btn-danger " >Cancelar</button>
										</div>
										
									</div>
								</div> <!-- fim row -->
							</div><!--fim card-body -->
							<!--fim collapseOne -->
						</div><!--fim card card-primary -->
					</form><!-- fim formCadFerfis -->

					<form id="formFerfis" name="formFerfis" format="html"  >
						<!--acordion-->
						<div id="accordionPerfis" >
						
							<!--xxxxxxxxxxxxxxx ACCORDION CADASTRADOS XXXXXXXX-->
							<div class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:16px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i>Perfis
										</a>
									</h4>
								</div>
								<div id="collapseTwo" class="" data-parent="#accordion" >							
									<div id="cardsPerfis"></div>
								</div> <!--fim collapseTwo -->

							</div><!--fim card card-success -->
							<!--xxxxxxxxxxxxxxx fim ACCORDION CADASTRADOS XXXXXXXX-->

						</div><!--fim acordion -->
						<div id="tabUsuariosPerfisDiv" >
					</form><!-- fim formFerfis -->	
						
				</div><!-- fim card-body -->	
				
			</div>
			<!-- /.container-fluid-->
				
		</section>
		<!-- /.content -->
		
	</div>
	<!-- /.content-wrapper -->
	<cfinclude template="pc_Footer.cfm">
	</div>
	<!-- ./wrapper -->
	<cfinclude template="pc_Sidebar.cfm">



	<script language="JavaScript">
			
		$(window).on("load",function(){
			$('#modalOverlay').delay(1000).hide(0, function() {
				$('#modalOverlay').modal('hide');
			});	
		});
          
		
		$(document).ready(function(){
			mostraCads()
			
		});	


		function mostraCads(){
			$('#modalOverlay').modal('show');
			setTimeout(function() {
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcPaginasApoio.cfc",
					data:{
						method:"cardsPerfis"
					},
					async: false,
					success: function(result) {	
						$('#cardsPerfis').html(result);
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
		
		$("#btSalvar").on('click', function (event)  {
			event.preventDefault()
			event.stopPropagation()

			if (!$('#perfilDescricao').val() || !$('#perfilComentario').val()){
				//mostra mensagem de erro, se algum campo necessário nesta fase não estiver preenchido	
				toastr.error('Todos os campos devem ser preenchidos!');
				return false;
			}

			var mensagem = ""
	        if($('#perfilId').val() == ''){
				var mensagem = "Deseja cadastrar este perfil?"
			}else{
				var mensagem = "Deseja editar este perfil?"
			}

			if(confirm(mensagem)){	
				$('#modalOverlay').modal('show');
				setTimeout(function() {
					$.ajax({
						type: "POST",
						url:"cfc/pc_cfcPaginasApoio.cfc",
						data:{
							method: "cadPerfil",
							pc_perfil_tipo_id: $('#perfilId').val(),
							pc_perfil_tipo_descricao: $('#perfilDescricao').val(),
							pc_perfil_tipo_comentario:  $('#perfilComentario').val(),
							pc_perfil_tipo_status: $('#perfilStatus').val()
						},
						async: false
					})//fim ajax
					.done(function(result) {
						mostraCads()	
						$('#perfilDescricao').val('')
						$('#perfilComentario').val('')
						$("#perfilStatusDiv").attr("hidden",true)
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
							toastr.success('Operação realizada com sucesso!');
						});	
						$('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo Perfil");
						$('#cadastroPerfis').CardWidget('collapse')
								
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
				

		})
		
		$("#btCancelar").on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()
				$('#perfilDescricao').val('')
				$('#perfilComentario').val('')
				$('#perfilStatus').val('')
				$("#perfilStatusDiv").attr("hidden",true)
				$('#cadastroPerfis').CardWidget('collapse')
				$('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo Perfil");
		})

		function perfilEditar(perfilId, perfilDescricao,perfilComentario,perfilStatus)  {
			event.preventDefault()
			event.stopPropagation()
			$('#cabecalhoAccordion').text("Editar o perfil:" + ' ' + perfilDescricao);
 			$('#perfilId').val(perfilId);	
			$('#perfilDescricao').val(perfilDescricao)
			$('#perfilComentario').val(perfilComentario)
			$('#perfilStatus').val(perfilStatus).trigger('change')
			$("#perfilStatusDiv").attr("hidden",false)
			$('#cadastroPerfis').CardWidget('expand')
			$('html, body').animate({ scrollTop: ($('#content').offset().top)} , 1000);

		}

	


		
		
		
			
		
	</script>

</body>
</html>
