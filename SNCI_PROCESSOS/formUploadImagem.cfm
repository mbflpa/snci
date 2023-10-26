<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="pt-br">
     <head>
          <meta charset="UTF-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>SNCI</title>
          <link rel="icon" type="image/x-icon" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">	
                    
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
          <!-- Bootstrap4 Duallistbox -->
          <link rel="stylesheet" href="plugins/bootstrap4-duallistbox/bootstrap-duallistbox.css">
          <!-- dropzonejs -->
          <link rel="stylesheet" href="plugins/dropzone/min/dropzone.min.css">

               <!-- DataTables -->
          <link rel="stylesheet" href="plugins/datatables-bs4/css/dataTables.bootstrap4.min.css">
          <link rel="stylesheet" href="plugins/datatables-responsive/css/responsive.bootstrap4.min.css">
          <link rel="stylesheet" href="plugins/datatables-buttons/css/buttons.bootstrap4.min.css">
          <link rel="stylesheet" href="plugins/datatables-select/css/select.bootstrap4.min.css">
          <link rel="stylesheet" href="plugins/datatables-scroller/css/scroller.bootstrap4.min.css">
     </head>
     <body class="hold-transition " data-panel-auto-height-mode="height" >
      <cfinclude template="pc_Modal_preloader.cfm">
          <!-- Site wrapper -->
          <div class="wrapper">
               <!-- Content Wrapper. Contains page content -->
               <div class="content-wrapper" style="margin-left:10px!important;margin-right:10px!important;">

                          <!-- /.row -->
                         <div class="row">
                              <div class="col-md-12">
                              <div class="card card-default">
                             
                              <div class="card-body">
                                   <div id="actions" class="row">
                                        <div class="col-lg-6">
                                             <div class="btn-group w-100">
                                                  <span class="btn btn-success col fileinput-button">
                                                       <i class="fas fa-plus"></i>
                                                       <span>Clique aqui para selecionar uma imagem:</span>
                                                  </span>
                                             </div>
                                        </div>
                                        <div class="col-lg-6 d-flex align-items-center" hidden>
                                             <div class="fileupload-process w-100" hidden>
                                                  <div  hidden id="total-progress" class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
                                                       <div hidden class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress></div>
                                                  </div>
                                             </div>
                                        </div>
                                   </div>
                                   <div class="table table-striped files" id="previews">
                                        <div id="template" class="row mt-2">
                                             <div class="col-auto">
                                                  <span class="preview"><img src="data:," alt="" data-dz-thumbnail /></span>
                                             </div>
                                             <div class="col d-flex align-items-center">
                                             <p class="mb-0">
                                                       <span class="lead" data-dz-name style="font-size:12px!important"></span>
                                                       (<span data-dz-size></span>)
                                                  </p>
                                                  <strong class="error text-danger" data-dz-errormessage></strong>
                                             </div>
                                             <div class="col-2 d-flex align-items-center">
                                                  <div class="progress progress-striped active w-100" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
                                                       <div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress></div>
                                                  </div>
                                             </div>
                                             <div class="col-auto d-flex align-items-center">
                                                  <div class="btn-group">
                                                       <button class="btn btn-primary start">
                                                            <i class="fas fa-upload"></i>
                                                            <span>Enviar</span>
                                                       </button>
                                                       <button data-dz-remove class="btn btn-warning cancel">
                                                            <i class="fas fa-times-circle"></i>
                                                            <span>Cancelar</span>
                                                       </button>
                                             
                                                  </div>
                                             </div>
                                        </div>
                                   </div>
                              </div>
                              <!-- /.card-body -->
                             
                              </div>
                              <!-- /.card -->
                              </div>
                         </div>
                         <form id="formBrowserImagens" name="formFerfis" format="html"  >
						<!--acordion-->
						<div id="accordionPerfis" >
						
							<!--xxxxxxxxxxxxxxx ACCORDION BrowserImagens XXXXXXXX-->
							<div class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:16px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-images fa-2x" style="margin-right:10px"> </i>Imagens Salvas no Servidor
										</a>
									</h4>
								</div>
								<div id="collapseTwo" class="" data-parent="#accordion" >							
									 <div id="browserDiv"></div>
								</div> <!--fim collapseTwo -->

							</div><!--fim card card-success -->
							<!--xxxxxxxxxxxxxxx fim ACCORDION BrowserImagens XXXXXXXX-->

						</div><!--fim acordion -->
					</form><!-- fim formFerfis -->	
                        
      
               </div>
               <!-- /.content-wrapper -->
          </div>
          <!-- ./wrapper -->
          <script src="plugins/jquery/jquery.min.js"></script>
		<!-- Bootstrap 4 -->
		<script src="plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
		<!-- jQuery UI 1.11.4 -->
		<script src="plugins/jquery-ui/jquery-ui.min.js"></script>
		<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
		<script language="JavaScript">
	  	$.widget.bridge('uibutton', $.ui.button)
		</script>

		<!-- overlayScrollbars -->
		<script src="plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
	

		<!-- dropzonejs -->
		<script src="plugins/dropzone/min/dropzone.min.js"></script>
        <!-- AdminLTE App -->
		<script src="dist/js/adminlte.js"></script>
	

    <!-- Toastr -->
    <script src="plugins/toastr/toastr.min.js"></script>



          <script language="JavaScript">
               $(window).on("load",function(){	
                    $('#modalOverlay').delay(1000).hide(0, function() {
                         $('#modalOverlay').modal('hide');
                    });	
                   mostraBrowser()
               });
               $(document).ready(function() {
				
				// DropzoneJS Demo Code Start
				Dropzone.autoDiscover = false

				// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
				var previewNode = document.querySelector("#template")
				previewNode.id = ""
				var previewTemplate = previewNode.parentNode.innerHTML
				previewNode.parentNode.removeChild(previewNode)

				var myDropzone = new Dropzone(document.body, { // Make the whole body a dropzone
					url: "cfc/pc_cfcUploadImagensEditor.cfc?method=uploadImagensFaq", // Set the url
					autoProcessQueue :true,
					maxFiles: 1,
					maxFilesize:2,
					thumbnailWidth: 200,
					parallelUploads: 1,
					acceptedFiles: '.png,.gif,.jpg,.jpeg',
					previewTemplate: previewTemplate,
					autoQueue: false, // Make sure the files aren't queued until manually added
					previewsContainer: "#previews", // Define the container to display the previews
					clickable: ".fileinput-button", // Define the element that should be used as click trigger to select files.
					
                         headers: {"CKEditor":<cfoutput>'url.CKEditor'</cfoutput>,
                                   "pc_imagem_tipo_id":2},
                         
                         //PARA SER UTLIZADO NOS RELATOS:
                         // headers: {"pc_aval_id":1, 
					// 		   "pc_aval_processo":1,
                         //           "CKEditor":<cfoutput>'url.CKEditor'</cfoutput>},


					init: function() {
						this.on('error', function(file, errorMessage) {	
							toastr.error(errorMessage);
						});
					}
					
				})

                    myDropzone.on("addedfile", function(file) {
                    // Hookup the start button
                    file.previewElement.querySelector(".start").onclick = function() { myDropzone.enqueueFile(file) }
                    })

                    // Update the total progress bar
                    myDropzone.on("totaluploadprogress", function(progress) {
                    document.querySelector("#total-progress .progress-bar").style.width = progress + "%"
                    })

                    myDropzone.on("sending", function(file) {
                         $('#modalOverlay').modal('show')
                    // Show the total progress bar when upload starts
                    document.querySelector("#total-progress").style.opacity = "1"
                    // And disable the start button
                    file.previewElement.querySelector(".start").setAttribute("disabled", "disabled")
                    })

                    // Hide the total progress bar when nothing's uploading anymore
                    myDropzone.on("queuecomplete", function(progress) {
                    document.querySelector("#total-progress").style.opacity = "0"
                    mostraBrowser();
                    $('#modalOverlay').delay(1000).hide(0, function() {
                         $('#modalOverlay').modal('hide');
                          myDropzone.removeAllFiles(true);
                    });

                    })

                    // Setup the buttons for all transfers
                    // The "add files" button doesn't need to be setup because the config
                    // `clickable` has already been specified.
                    document.querySelector("#actions .start").onclick = function() {
                    myDropzone.enqueueFiles(myDropzone.getFilesWithStatus(Dropzone.ADDED))
                    }
                    document.querySelector("#actions .cancel").onclick = function() {
                    myDropzone.removeAllFiles(true)
                    }
                    // DropzoneJS Demo Code End
		
			})

               


               function mostraBrowser(){

				$.ajax({
					type: "post",
					url: "cfc/pc_cfcUploadImagensEditor.cfc",
					data:{
						method:"browserImagensEditorFaq",
                              pc_imagem_tipo_id:2
					},
					async: false,
					success: function(result) {	
						$('#browserDiv').html(result);
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

               function excluirImagem(pc_imagem_id)  {
				event.preventDefault()
		        event.stopPropagation()
				if(confirm("Deseja excluir esta Imagem?\nSe ela já foi inserida em algum documento, não irá mais aparecer.")){
					$('#modalOverlay').modal('show')
					var dataEditor = $('.editor').html();
                         setTimeout(function() {	
                              $.ajax({
                                   type: "post",
                                   url: "cfc/pc_cfcUploadImagensEditor.cfc",
                                   data:{
                                        method: "delImagem",
                                        pc_imagem_id: pc_imagem_id
                                   },
                                   async: false
                              })//fim ajax
                              .done(function(result) {	
                                   mostraBrowser()
                                   $('#modalOverlay').delay(1000).hide(0, function() {
                                        $('#modalOverlay').modal('hide');
                                        toastr.success('Imagem excluída com sucesso!');
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

			};

			function InsereImagem(img,largura){
				<cfoutput>
					var edt = '#url.CKEditor#';
				</cfoutput>
				var editor = window.opener.CKEDITOR.instances[edt];
                    
				if(largura >'500'){
					largura = '500';
				}
				
				var imagemHtml = '<div style="background:#fff"><p style="text-align:center"><img alt=' + img + ' style="text-align:center;background:#fff;border:0px" src=' + img + ' width="'+ largura + '"  style="cursor:pointer;display: block;margin-left: auto;margin-right: auto"></img></p></div>';

				editor.insertHtml(imagemHtml);
				//editor.showNotification( 'Imagem inserida com sucesso!' );
                    
				window.close();
			}
              


          </script>
     </body>
</html>
