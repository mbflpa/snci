<cfcomponent>
<cfprocessingdirective pageencoding = "utf-8">

	

	
	<cffunction name="FormCadFaq"   access="remote" hint="mostra form de cadastro do FAQ.">
        <cfargument name="pc_faq_id" type="numeric" required="false" default=0/>

		<cfquery name="rsPerfis" datasource="#application.dsn_processos#">
			SELECT pc_perfil_tipos.* from pc_perfil_tipos where pc_perfil_tipo_status='A' ORDER BY pc_perfil_tipo_descricao
		</cfquery>

		<cfquery name="rsFaqEdit" datasource="#application.dsn_processos#">
			SELECT pc_faqs.* FROM pc_faqs where pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<div class="content-header" style="background:  #f4f6f9;">
			<div class="container-fluid">
				<div class="card-body" style="display:flex;flex-direction:column">

					<form  class="row g-3 needs-validation was-validated" novalidate  id="myform" name="myform" format="html"  style="height: auto;">
						

						<!--acordion-->
						<div id="accordionCadFaq" >
							<div id="cadastroFaq" class="card card-primary collapsed-card" style="margin-left: -21px;">
								<div  class="card-header azul_claro_correios_backgroundColor" style="color:#fff;">
									<a   class="d-block" data-toggle="collapse" href="#collapseCad"  data-card-widget="collapse">
										<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
										</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um novo FAQ</span>
									</a>
									
								</div>
								<cfoutput>
									<input id="faqId" value="#rsFaqEdit.pc_faq_id#" hidden>
									<!-- Novos campos ocultos para armazenar anexo -->
									<input id="faqAnexoCaminho" value="#rsFaqEdit.pc_faq_anexo_caminho#" hidden>
									<input id="faqAnexoNome" value="#rsFaqEdit.pc_faq_anexo_nome#" hidden>
								</cfoutput>
								<div class="card-body" style="border: solid 3px #0083ca">
									<div class="row" >
										<div class="col-sm-10" >
											<div class="form-group " >
												<label for="faqTitulo">Pergunta:</label>
											<input id="faqTitulo" style="height:39px"   required=""  name="faqTitulo" type="text" class="form-control "  inputmode="text" placeholder="Insira uma pergunta...">

											</div>
										</div>

										<div id="faqStatusDiv" class="col-sm-2">
											<div class="form-group">
												<label for="faqStatus">Status:</label>
												<select id="faqStatus" required name="faqStatus" class="form-control"  style="height:40px;">
													<option selected="" disabled="" value=""></option>
													<option  <cfif #rsFaqEdit.pc_faq_status# eq 'A'>selected</cfif> value="A" >Ativo</option>
													<option  <cfif #rsFaqEdit.pc_faq_status# eq 'D'>selected</cfif> value="D" >Desativado</option>
												</select>
											</div>
										</div>

										<div class="col-sm-12" style="box-shadow:0!important">
											<div class="form-group " >
												<label for="faqPerfis">Perfis que irão visualizar este FAQ:</label>
												<select id="faqPerfis" required="true" class="form-control" multiple="multiple">
													<cfoutput query="rsPerfis">
														<option value="(#pc_perfil_tipo_id#)">#pc_perfil_tipo_descricao#</option>
													</cfoutput>
												</select>	
											</div>
										</div>
										
										<div class="col-sm-12" >
											<!-- Adição dos botões de opção para selecionar modo de envio -->
											<div class="form-group">
												<label>Selecione o tipo de envio:</label>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" name="envioFaq" id="envioTexto" value="texto" checked>
													<label class="form-check-label" for="envioTexto">Digite Texto</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" name="envioFaq" id="envioArquivo" value="arquivo">
													<label class="form-check-label" for="envioArquivo">Anexar PDF</label>
												</div>
											</div>

											<!-- Container para textarea -->
											<div id="containerTexto">
												<div align="center">
													<div class="container">
														<textarea  id="faqTexto" name="faqTexto"><cfoutput>#rsFaqEdit.pc_faq_texto#</cfoutput></textarea>							
													</div>
												</div>
											</div>

											<!-- Container para upload de PDF via botão (oculto por padrão) -->
											<div id="actions" class="row" style="margin-top:20px">
                                                <div class="col-lg-12" align="center">
                                                    <div class="btn-group w-30">
                                                        <span id="arquivo" class="btn btn-success col fileinput-button azul_claro_correios_backgroundColor" >
															<i class="fas fa-upload"></i> Clique aqui para anexar o arquivo PDF
														</span>
													</div>
												</div>
											</div>
											<div class="table table-striped files" id="previewsArquivo">
                                                <div id="templateArquivo" class="row mt-2">
                                                    <div class="col-auto">
                                                        <span class="preview"><img src="data:," alt="" data-dz-thumbnail /></span>
                                                    </div>
                                                    <div class="col d-flex align-items-center">
                                                        <p class="mb-0">
                                                        <span class="lead" data-dz-name></span>
                                                        (<span data-dz-size></span>)
                                                        </p>
                                                        <strong class="error text-danger" data-dz-errormessage></strong>
                                                    </div>
                                                    <div class="col-4 d-flex align-items-center" >
                                                        <div class="progress progress-striped active w-100" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" >
                                                            <div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress ></div>
                                                        </div>
                                                    </div>
                                                    
                                                </div>
                                            </div>

											<!-- Adicionado div para exibição do arquivo após upload -->
											<div id="arquivoFaqDiv" style="margin-top:15px;"></div>
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

						</div><!--fim acordion -->
					</form><!-- fim myform -->

					
						
				</div>	<!-- fim card-body -->
			</div>
		</div>
		<script language="JavaScript">


			$(document).ready(function() {	
				//Initialize Select2 Elements
				$('select').not('[name="tabFaq_length"]').select2({
					theme: 'bootstrap4',
					placeholder: 'Selecione...',
					allowClear: true
				});
				// Inicialmente, se "texto" estiver selecionado, oculta as divs de ações e de pré-visualizações
				if ($('input[name="envioFaq"]:checked').val() === 'texto') {
					$('#actions').hide();
					$('#previewsArquivo').hide();
					$('#arquivoFaqDiv').hide(); // Adicionada esta linha
				}
				
				CKEDITOR.replace( 'faqTexto', {
					width: '100%',
					height: 300,
					removeButtons: 'Save'
				});

				<cfoutput>
				  var ListaPerfis ="#rsFaqEdit.pc_faq_perfis#"
				</cfoutput>
				var listPerfis = ListaPerfis.split(",");
				var selectedValues = new Array();
				$.each(listPerfis, function(index,value){
					selectedValues[index] = value;
				});
				$('#faqPerfis').val(selectedValues).trigger('change');

				$('input[name="envioFaq"]').change(function(){
					var anexoNome = $('#faqAnexoNome').val();
					if($(this).val() === 'arquivo'){
						
						$('#containerTexto').hide();
						$('#accordionCadFaq').show();
						$('#actions').show();
						$('#arquivoFaqDiv').show(); // Adicionada esta linha

						// Nova verificação: se arquivo existe, oculta o botão #arquivo
						var filePath = $('#faqAnexoCaminho').val();
						if (filePath && filePath.trim() !== "") {
        					if (checkArquivoExists(filePath)) {
								$('#arquivo').hide();
							} else {
								$('#arquivo').show();

							}
						}

						if (
							$('#faqAnexoNome').val() && $('#faqAnexoNome').val().trim() !== "" &&
							$('#faqAnexoCaminho').val() && $('#faqAnexoCaminho').val().trim() !== ""
						) {
						    var cardHtml = `
							<!-- Container flex para anexos -->
							<div style="padding: 0px; width: 70%; margin: 0 auto;cursor:pointer" onclick="openPdfModal($('#faqAnexoCaminho').val(), $('#faqAnexoNome').val())">
								<!-- Card com anexo -->
								<div class="card card-primary card-tabs collapsed-card card_hover_correios" style="transition: all 0.15s ease 0s; height: inherit; width: 100%; margin: 0;">
									<div class="card-header" style="padding:10px!important;display: flex; align-items: center; width: 100%; background: linear-gradient(45deg, #b00b1e, #d4145a);">
										<h3 class="card-title" style="font-size: 16px; cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;">
											<i class="fas fa-file-pdf"></i> ` + $('#faqAnexoNome').val() + `
										</h3>
										<div class="card-tools" style="margin-left: 20px;">
											<button type="button" id="btExcluir" class="btn btn-tool grow-icon" style="font-size: 16px">
												<i class="fas fa-trash-alt"></i>
											</button>
										</div>
									</div>
								</div>
							</div>`;
                            setArquivoFaqDiv(cardHtml);
						}
						// Exibe o container de pré-visualizações para o Dropzone
						$('#previewsArquivo').show();
						Dropzone.autoDiscover = false;
						var previewNode = document.querySelector("#templateArquivo")
						var previewTemplate = previewNode.parentNode.innerHTML
						previewNode.parentNode.removeChild(previewNode)
						
					
						var myDropzoneFaq = new Dropzone("#accordionCadFaq", {
							url: "cfc/pc_cfcFaqs.cfc?method=uploadArquivosFaqs",
							autoProcessQueue: false, // Alterado: upload somente quando solicitado
							maxFiles: 1,
							maxFilesize:20,
							thumbnailWidth: 80,
							thumbnailHeight: 80,
							parallelUploads: 1,
							acceptedFiles: '.pdf',
							previewTemplate: previewTemplate,
							previewsContainer: "#previewsArquivo",
							clickable: "#arquivo",
							init: function(){
								var dzInstance = this;
								// Adicionado: botão de exclusão para remover o arquivo selecionado
								this.on("addedfile", function(file) {
									var removeButton = Dropzone.createElement('<button class="btn btn-sm btn-danger remove-btn" style="margin-top:10px;">Excluir arquivo</button>');
									file.previewElement.appendChild(removeButton);
									removeButton.addEventListener("click", function(e) {
										e.preventDefault();
										e.stopPropagation();
										dzInstance.removeFile(file);
									});
								});
								this.on("error", function(file, errorMessage){
									toastr.error(errorMessage);
									return false;
								});
								
								
								this.on("success", function(file, response){
									if (typeof response === 'string') {
										response = JSON.parse(response);
									}
									
									var data = response[0];
									// Atualiza os campos ocultos com o nome e caminho final do arquivo
									$('#faqAnexoCaminho').val(data.CAMINHO_ANEXO);
									$('#faqAnexoNome').val(data.NOME_ANEXO);
									
								});
								this.on("queuecomplete", function(){
									toastr.success("Upload realizado com sucesso!");
									// Atualiza a div do anexo se necessário
									if (
										$('#faqAnexoNome').val() && $('#faqAnexoNome').val().trim() !== "" &&
										$('#faqAnexoCaminho').val() && $('#faqAnexoCaminho').val().trim() !== ""
									) {
									    var cardHtml = `
											<!-- Container flex para anexos -->
											<div style="padding: 0; width: 70%; margin: 0 auto;cursor:pointer" onclick="openPdfModal($('#faqAnexoCaminho').val(), $('#faqAnexoNome').val())">
												<!-- Card com anexo -->
												<div class="card card-primary card-tabs collapsed-card card_hover_correios" style="transition: all 0.15s ease; height: inherit; width: 100%; margin: 0;">
													<div class="card-header" style="padding:10px!important;display: flex; align-items: center; width: 100%; background: linear-gradient(45deg, #b00b1e, #d4145a);">
														<h3 class="card-title" style="font-size: 16px; cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;">
															<i class="fas fa-file-pdf"></i> ` + $('#faqAnexoNome').val() + `
														</h3>
														<div class="card-tools" style="margin-left: 20px;">
															<button type="button" id="btExcluir" class="btn btn-tool grow-icon" style="font-size: 16px">
																<i class="fas fa-trash-alt"></i>
															</button>
														</div>
													</div>
												</div>
											</div>`;
                                        setArquivoFaqDiv(cardHtml);
									}
									// Envia os dados após o upload
									submitFaq();
									// Limpa os arquivos e a pré-visualização
									this.removeAllFiles(true);
									$("#previewsArquivo").empty();
								});
							}
						});
						// Armazena a instância no elemento para acesso posterior (global)
						window.myDropzoneFaq = myDropzoneFaq;
					} else {
						//$('#accordionCadFaq').hide();
						$('#containerTexto').show();
						$('#actions').hide();
						// Oculta a div de pré-visualizações quando o envio é por texto
						$('#previewsArquivo').hide();
						$('#arquivoFaqDiv').hide(); // Adicionada esta linha
					}
				});
				
				// Removido: $('#uploadFaqButton').on('click', ...) e $('#faqFileInput').on('change', ...);
			});

			

			$('#btCancelar').on('click', function (event)  {
				event.preventDefault();
				event.stopPropagation();
				// Limpa todos os campos do formulário
				$('#myform').trigger("reset");
				if (CKEDITOR.instances.faqTexto) {
					CKEDITOR.instances.faqTexto.setData('');
				}
				$('#faqPerfis').val(null).trigger('change');
				$('#faqStatus').val(null).trigger('change');
				$('#faqId, #faqAnexoCaminho, #faqAnexoNome').val('');
				$('#previewsArquivo').empty();
				mostraFormCadFaq();
			});

			// função para enviar os dados após upload (ou direto se texto)
			function submitFaq() {
				var perfisList = $('#faqPerfis').val();
				$('#modalOverlay').modal('show');
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcFaqs.cfc",
					dataType: "json",
					data:{
						method: "cadFaq",
						pc_faq_id: $('#faqId').val(),
						pc_faq_perfis: perfisList.join(','),
						pc_faq_titulo: $('#faqTitulo').val(),
						pc_faq_status: $('#faqStatus').val(),
						pc_faq_anexo_caminho: $('#faqAnexoCaminho').val(),
						pc_faq_anexo_nome: $('#faqAnexoNome').val()
					},
					async: false
				})
				.done(function(result) {
					finalizeSubmission();
				});
			}

			$('#btSalvar').on('click', function (event)  {
				event.preventDefault();
				event.stopPropagation();

				if (!$('#faqPerfis').val() || !$('#faqTitulo').val() || !$('#faqStatus').val()){
					toastr.error('Todos os campos devem ser preenchidos.');
					return false;
				}
					
				var envioTipo = $('input[name="envioFaq"]:checked').val();
				var dataEditor;
				var existeArquivo = $('#faqAnexoNome').val() && $('#faqAnexoNome').val().trim() !== "";
				var existeTexto = CKEDITOR.instances.faqTexto.getData().trim() !== "";
			
				// Validações específicas baseadas no tipo de envio
				if(envioTipo === "texto"){
					dataEditor = CKEDITOR.instances.faqTexto.getData();
					if(dataEditor.length < 100){
						toastr.error('Insira um texto com, no mínimo, 100 caracteres.');
						return false;
					}
					// Se existe arquivo cadastrado, alerta o usuário
					if(existeArquivo){
						swalWithBootstrapButtons.fire({
							html: logoSNCIsweetalert2('Ao salvar o texto, o arquivo PDF anteriormente cadastrado será excluído. Deseja continuar?'),
							showCancelButton: true,
							confirmButtonText: 'Sim!',
							cancelButtonText: 'Cancelar!'
						}).then((result) => {
							if (result.isConfirmed) {
								// Se confirmou, exclui o arquivo e limpa os campos
								if($('#faqAnexoCaminho').val()){
									$.ajax({
										type: "post",
										url: "cfc/pc_cfcFaqs.cfc",
										dataType: "json",
										data: {
											method: "delArquivoFaq",
											pc_faq_anexo_caminho: $('#faqAnexoCaminho').val()
										}
									}).done(function(){
										$('#faqAnexoNome').val('');
										$('#faqAnexoCaminho').val('');
										$('#arquivoFaqDiv').empty();
										proceedWithSave(dataEditor);
									});
								} else {
									proceedWithSave(dataEditor);
								}
							}
						});
						return false;
					}
				} else {
					if(!(window.myDropzoneFaq && window.myDropzoneFaq.getQueuedFiles().length > 0) && !existeArquivo){
						toastr.error('É necessário anexar um arquivo PDF.');
						return false;
					}
					// Se existe texto cadastrado, alerta o usuário
					if(existeTexto){
						swalWithBootstrapButtons.fire({
							html: logoSNCIsweetalert2('Ao salvar o arquivo, o texto anteriormente cadastrado será excluído. Deseja continuar?'),
							showCancelButton: true,
							confirmButtonText: 'Sim!',
							cancelButtonText: 'Cancelar!'
						}).then((result) => {
							if (result.isConfirmed) {
								dataEditor = ""; // Alterado de "null" para ""
								proceedWithSave(dataEditor);
							}
						});
						return false;
					}
					dataEditor = ""; // Alterado de "null" para ""
				}
				
				proceedWithSave(dataEditor);
			});
				
			// Nova função auxiliar para centralizar o processo de salvamento
			function proceedWithSave(dataEditor) {
				var mensagem = "";
				if($('#faqId').val() == ''){
					mensagem = "Deseja cadastrar este FAQ?";
				} else {
					mensagem = "Deseja editar este FAQ?";
				}
				
				swalWithBootstrapButtons.fire({
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
				}).then((result) => {
					if (result.isConfirmed) {
						var perfisList = $('#faqPerfis').val();
						$('#modalOverlay').modal('show');
						setTimeout(function() {
							$.ajax({
								type: "post",
								url: "cfc/pc_cfcFaqs.cfc",
								dataType: "json",
								data:{
									method: "cadFaq",
									pc_faq_id: $('#faqId').val(),
									pc_faq_perfis: perfisList.join(','),
									pc_faq_titulo: $('#faqTitulo').val(),
									pc_faq_status: $('#faqStatus').val(),
									pc_faq_texto: dataEditor,
									pc_faq_anexo_caminho: $('#faqAnexoCaminho').val(),
									pc_faq_anexo_nome: $('#faqAnexoNome').val()
								},
								async: false
							})
							.done(function(result) {
								$('#faqId').val(result[0].FAQ_ID);
								
								var envioTipo = $('input[name="envioFaq"]:checked').val();
								if(envioTipo === "arquivo" && window.myDropzoneFaq && window.myDropzoneFaq.getQueuedFiles().length > 0){
									window.myDropzoneFaq.options.params = { pc_faq_id: result[0].FAQ_ID };
									window.myDropzoneFaq.processQueue();
								} else {
									finalizeSubmission();
								}
							});
						}, 500);
					}
				});
			}

			// Função a ser chamada após o upload ou quando não há envio de anexo
            function finalizeSubmission(){
                // Novo trecho para atualizar o container do anexo, caso exista
                if ($('#faqAnexoNome').val() && $('#faqAnexoNome').val().trim() !== "" && $('#faqAnexoCaminho').val() && $('#faqAnexoCaminho').val().trim() !== "") {
                    var cardHtml = 
                        '<div style="padding: 0; width: 70%; margin: 0 auto;cursor:pointer" onclick="openPdfModal($(\'#faqAnexoCaminho\').val(), $(\'#faqAnexoNome\').val())">'+
                            '<div class="card card-primary card-tabs collapsed-card card_hover_correios" style="transition: all 0.15s ease; height: inherit; width: 100%; margin: 0;">'+
                                '<div class="card-header" style="padding:10px!important;display: flex; align-items: center; width: 100%; background: linear-gradient(45deg, #b00b1e, #d4145a);">'+
                                    '<h3 class="card-title" style="font-size: 16px; cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;">'+
                                        '<i class="fas fa-file-pdf"></i> ' + $('#faqAnexoNome').val() +
                                    '</h3>'+
                                    '<div class="card-tools" style="margin-left: 20px;">'+
                                        '<button type="button" id="btExcluir" class="btn btn-tool grow-icon" style="font-size: 16px">'+
                                            '<i class="fas fa-trash-alt"></i>'+
                                        '</button>'+
                                    '</div>'+
                                '</div>'+
                            '</div>'+
                        '</div>';
                    setArquivoFaqDiv(cardHtml);
                }
                mostraFormCadFaq();
                mostraTabFaq();
                $('#modalOverlay').delay(1000).hide(0, function(){
                    $('#modalOverlay').modal('hide');
                    toastr.success('Operação realizada com sucesso!');
                });
                if ($('input[name="envioFaq"]:checked').val() === "texto") {
                    CKEDITOR.instances.faqTexto.setData('');
                    $('#cadastroFaq').CardWidget('collapse');
                    $('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo FAQ");
                }
            }

			// Função para excluir o arquivo do FAQ (usando delegação para elementos dinâmicos)
			$(document).on('click', '#btExcluir', function(event) {
				event.preventDefault();
				event.stopPropagation();
				var anexoCaminho = $('#faqAnexoCaminho').val();
				if (anexoCaminho && anexoCaminho.trim() !== "") {
					var mensagem = "Deseja excluir este arquivo PDF?";
					swalWithBootstrapButtons.fire({
						html: logoSNCIsweetalert2(mensagem),
						showCancelButton: true,
						confirmButtonText: 'Sim!',
						cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show');
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcFaqs.cfc",
									dataType: "json",
									data: {
										method: "delArquivoFaq",
										pc_faq_anexo_caminho: anexoCaminho
									},
									async: false
								})
								.done(function(result) {
									if(result) {
										$('#arquivoFaqDiv').empty();
										$('#faqAnexoNome').val('');
										$('#faqAnexoCaminho').val('');
										$('#arquivo').show();
										$('#modalOverlay').modal('hide');
										toastr.success("Arquivo excluído com sucesso!");
									}
								})
								.fail(function() {
									toastr.error("Erro ao excluir arquivo.");
								});
							}, 500);
						}
					});
				}
			});

			// Função auxiliar para verificar se o arquivo existe
			function checkArquivoExists(filePath) {
				var fileExists = false;
				$.ajax({
					url: "cfc/pc_cfcFaqs.cfc",
					type: "GET",
					dataType: "json",
					data: {
						method: "checkArquivoExists",
						filePath: filePath
					},
					async: false, // Importante para aguardar o resultado
					success: function(response) {
						fileExists = response;
					},
					error: function() {
						fileExists = false; // Em caso de erro, considera que o arquivo não existe
					}
				});
				return fileExists;
			}

			// Função auxiliar para atualizar a div
			function setArquivoFaqDiv(cardHtml) {
				var filePath = $('#faqAnexoCaminho').val();
				if (filePath && filePath.trim() !== "") {
					if (checkArquivoExists(filePath)) {
						$("#arquivoFaqDiv").html(cardHtml);
					} else {
						$("#arquivoFaqDiv").html("<h5 style='color:red'>O arquivo foi deletado ou não é possível o seu acesso</h5>");
				
					}
				}
			}

			

		</script>
	</cffunction>



	<cffunction name="cadFaq" access="remote" returntype="any" returnformat="json" output="false" hint="Cadastra o FAQ.">
		<cfargument name="pc_faq_id" type="any" required="false" default=0/>
		<cfargument name="pc_faq_status" type="string" required="true"/>
		<cfargument name="pc_faq_titulo" type="string" required="true" />
		<cfargument name="pc_faq_perfis" type="any" required="true" />
		<cfargument name="pc_faq_texto" type="string" required="false" default="" />
		<cfargument name="pc_faq_anexo_caminho" type="string" required="false" default="" />
		<cfargument name="pc_faq_anexo_nome" type="string" required="false" default="" />
	
		<cfif arguments.pc_faq_id eq 0 or arguments.pc_faq_id eq "" >
			<cfquery datasource="#application.dsn_processos#" result="resultFaq">
				INSERT INTO pc_faqs
								(pc_faq_titulo, pc_faq_perfis,pc_faq_status,pc_faq_texto,pc_faq_anexo_caminho,pc_faq_anexo_nome,pc_faq_atualiz_datahora,pc_faq_matricula_atualiz)
				VALUES     		(<cfqueryparam value="#arguments.pc_faq_titulo#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_perfis#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_status#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_texto#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_anexo_caminho#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_anexo_nome#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								 '#application.rsUsuarioParametros.pc_usu_matricula#')
			</cfquery>
			<!-- Retorna o ID gerado (assumindo que o datasource suporte generatedKey) -->
            <cfset faqId = resultFaq.generatedKey>
		<cfelse>
		    <cfquery datasource="#application.dsn_processos#" >
				UPDATE pc_faqs
				SET    pc_faq_titulo = <cfqueryparam value="#arguments.pc_faq_titulo#" cfsqltype="cf_sql_varchar">,
				       pc_faq_perfis = <cfqueryparam value="#arguments.pc_faq_perfis#" cfsqltype="cf_sql_varchar">,
					   pc_faq_status = <cfqueryparam value="#arguments.pc_faq_status#" cfsqltype="cf_sql_varchar">,
					   pc_faq_texto  = <cfqueryparam value="#arguments.pc_faq_texto#" cfsqltype="cf_sql_varchar">,
 					   pc_faq_anexo_caminho = <cfqueryparam value="#arguments.pc_faq_anexo_caminho#" cfsqltype="cf_sql_varchar">,
					   pc_faq_anexo_nome = <cfqueryparam value="#arguments.pc_faq_anexo_nome#" cfsqltype="cf_sql_varchar">,
				       pc_faq_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					   pc_faq_matricula_atualiz =  <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">
				WHERE  pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">

			</cfquery>
			<cfset faqId = arguments.pc_faq_id>
		</cfif>
		
		<cfset dadosFaq = []>
		<cfset faqRet = {}>
		<cfset faqRet.FAQ_ID = faqId>
		<cfset arrayAppend(dadosFaq, faqRet)>
		<cfreturn dadosFaq>
    </cffunction>



	<cffunction name="formFaq" access="remote" hint="Exibe os FAQs na página pc_faq.cfm.">
        <cfargument name="cadastro" type="string" required="false" default="S"/>
		
		<cfquery datasource="#application.dsn_processos#" name="rsFaqs">
			SELECT pc_faqs.*, pc_usu_nome FROM  pc_faqs
			INNER JOIN pc_usuarios on pc_usu_matricula = pc_faq_matricula_atualiz
			<cfif ('#application.rsUsuarioParametros.pc_usu_perfil#' eq '3' or '#application.rsUsuarioParametros.pc_usu_perfil#' eq '11') and '#arguments.cadastro#' eq 'S'>
				order by  pc_faq_status asc, pc_faq_atualiz_datahora desc
			<cfelse>
				where pc_faq_perfis like '%(#application.rsUsuarioParametros.pc_usu_perfil#)%' and pc_faq_status = 'A'
				order by  pc_faq_titulo
			</cfif>
		</cfquery>

	
		<div class="row">
			<style>
				.maximized-card{
					overflow-y: auto!important;
				}
				.card-header {
					padding: .0rem 1rem!important;
			    -}
			</style>
			<div class="col-12" id="accordion">
				<cfloop query="rsFaqs">
					<cfoutput>
						<div class="card <cfif #pc_faq_status# eq 'D'>card-danger<cfelse>card-primary</cfif> card-outline" >
							
							<a class="d-block w-100 " data-toggle="collapse" href="##collapse#pc_faq_id#">
								<div class="card-header" style="<cfif #pc_faq_status# eq 'D'>background-color: ##e5e5eb;color:red</cfif>,padding: .0rem 1.0rem!important;">
									<cfset dataFaq = DateFormat(#pc_faq_atualiz_datahora#,'DD-MM-YYYY') & '-' & TimeFormat(#pc_faq_atualiz_datahora#,'HH') & 'h' & TimeFormat(#pc_faq_atualiz_datahora#,'MM') & 'min' >
									<h4 class="card-title 1-300" style="margin-top:5px">
										<cfif #pc_faq_status# eq 'D'><span class="badge badge-warning navbar-badge" style="float: left;right: initial;top: 1px;">Desativado</span></cfif>
										#pc_faq_titulo#
									</h4>

									<div  class="card-tools">
										<button  type="button" class="btn btn-tool" data-card-widget="maximize" style="font-size:34px;"><i class="exp fas fa-expand"></i></button>
									</div>	
								</div>
							</a>
							<div id="collapse#pc_faq_id#" class="collapse" data-parent="##accordion">
								<div class="card-body">
									<cfif len(trim(pc_faq_anexo_caminho)) and len(trim(pc_faq_anexo_nome))>
										<iframe src="/snci/SNCI_PROCESSOS/pc_exibePdfInline.cfm?arquivo=#URLEncodedFormat(pc_faq_anexo_caminho)#&amp;nome=#URLEncodedFormat(pc_faq_anexo_nome)#" 
											width="100%" height="600px" style="border:none;"></iframe>
									<cfelse>
										<div>#pc_faq_texto#</div>
									</cfif>
									<cfif (#application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11) and '#arguments.cadastro#' eq 'S'>
										<div align="center" style="margin-top:30px;font-size:10px"><div>Última atualização: #pc_faq_matricula_atualiz# - #pc_usu_nome# (#dataFaq#)</div></div>
									</cfif>
								</div>
							</div>

							
						</div>
					</cfoutput>
				</cfloop>
			</div>
		</div>
		<script language="JavaScript">	
			
						
			function mostraFormEditFaq(faqId,tit){
				event.preventDefault()
				event.stopPropagation()
				var titulo =decodeURIComponent(tit);

				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcFaqs.cfc",
						data:{
							method: "formCadFaq",
							pc_faq_id:faqId
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#formCadFaqDiv').html(result)
						$('#faqTitulo').val(titulo)
						$('#cabecalhoAccordion').text("Editar o FAQ ID " + faqId + ': ' + titulo)
						$("#btSalvarDiv").attr("hidden",false)
						$("#faqStatus").attr("hidden",false)
						
						// Nova verificação com delay: se faqTexto for vazio ou "null", ativa envio de arquivo
						if (!$('#faqTexto').val() || $('#faqTexto').val().trim() === "" || $('#faqTexto').val().trim().toLowerCase() === "null") {
							setTimeout(function(){
								$('input[name="envioFaq"][value="arquivo"]').prop("checked", true).trigger("change");
								// Exibe o nome do arquivo anexo, se disponível
								var anexoNome = $('#faqAnexoNome').val();
								if(anexoNome && anexoNome.trim() !== ""){
									var cardHtml = 
										'<div style="padding: 0; width: 70%; margin: 0 auto;cursor:pointer" onclick="openPdfModal($(\'#faqAnexoCaminho\').val(), $(\'#faqAnexoNome\').val())">'+
											'<div class="card card-primary card-tabs collapsed-card card_hover_correios" style="transition: all 0.15s ease; height: inherit; width: 100%; margin: 0;">'+
												'<div class="card-header" style="padding:10px!important;display: flex; align-items: center; width: 100%; background: linear-gradient(45deg, #b00b1e, #d4145a);">'+
													'<h3 class="card-title" style="font-size: 16px; cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;">'+
														'<i class="fas fa-file-pdf"></i> ' + anexoNome +
													'</h3>'+
													'<div class="card-tools" style="margin-left: 20px;">'+
														'<button type="button" id="btExcluir" class="btn btn-tool grow-icon" style="font-size: 16px">'+
															'<i class="fas fa-trash-alt"></i>'+
														'</button>'+
													'</div>'+
												'</div>'+
											'</div>'+
										'</div>';
									setArquivoFaqDiv(cardHtml);
								}
							}, 100);
						}

						$('#cadastroFaq').CardWidget('expand')
						$('html, body').animate({ scrollTop: ($('#formCadFaqDiv').offset().top-80)} , 1000);
						$('#modalOverlay').delay(1000).hide(0, function() {
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

					});//fim fail
				}, 500);
       		}

			function excluirFaq(faqId) {				
				event.preventDefault()
				event.stopPropagation()
				var mensagem = "Deseja excluir este FAQ?";
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
					if (result.isConfirmed) {
						$('#modalOverlay').modal('show')
						setTimeout(function() {
							$.ajax({
								type: "GET",
								url: "cfc/pc_cfcFaqs.cfc",
								data:{
									method: "delFaq",
									pc_faq_id: faqId
								},
							async: false

							})//fim ajax
							.done(function(result) {
								mostraFormCadFaq()
								mostraFormFaq()	
								$('#modalOverlay').delay(1000).hide(0, function() {
									$('#modalOverlay').modal('hide');
									toastr.success('Operação realizada com sucesso!');
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
						}, 500);
					}		
				});	
			}
			
		</script>
 	</cffunction>

	<cffunction name="tabFaq"   access="remote" hint="exibe os FAQs na página pc_faq.cfm.">
        <cfargument name="cadastro" type="string" required="false" default="S"/>
		
		<cfquery datasource="#application.dsn_processos#" name="rsFaqs">
			SELECT pc_faqs.*, pc_usu_nome FROM  pc_faqs
			INNER JOIN pc_usuarios on pc_usu_matricula = pc_faq_matricula_atualiz
			<cfif ('#application.rsUsuarioParametros.pc_usu_perfil#' eq '3' or '#application.rsUsuarioParametros.pc_usu_perfil#' eq '11') and '#arguments.cadastro#' eq 'S'>
				order by  pc_faq_status asc, pc_faq_atualiz_datahora desc
			<cfelse>
				where pc_faq_perfis like '%(#application.rsUsuarioParametros.pc_usu_perfil#)%' and pc_faq_status = 'A'
				order by pc_faq_id desc
			</cfif>
		</cfquery>

	
			<div class="row" style="padding-left:25px; padding-right:25px">
				<div class="col-12">
					<div class="card">
						<!-- /.card-header -->
						<div class="card-body">
							<table id="tabFaq" class="table  table-hover table-striped">
								<thead  class="table_thead_backgroundColor">
									<tr style="font-size:12px!important">
										<th align="center">Controles</th>
										<th >ID</th>
										<th >Título</th>
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsFaqs"> 
										<cfset titulo_codificado = urlEncodedFormat(pc_faq_titulo)>
										<cfoutput>
											<tr style="font-size:12px;<cfif #pc_faq_status# eq 'D'>color:red</cfif>" >
												<td style="vertical-align: middle;">
													<div style="display:flex;justify-content:space-around;">
														<i  class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;font-size:20px" onclick="javascript:excluirFaq(<cfoutput>#pc_faq_id#</cfoutput>);"    title="Excluir" ></i>
														<i class="fas fa-edit efeito-grow"   style="cursor: pointer;font-size:20px"  onclick="javascript:mostraFormEditFaq(<cfoutput>#pc_faq_id#,'#titulo_codificado#'</cfoutput>);"    title="Editar"></i>									
													</div>
												</td>
												<td style="vertical-align: middle;width:30px">#pc_faq_id#</td>
												<td style="vertical-align: middle;">#pc_faq_titulo#</td>
											</tr>
										</cfoutput>
									</cfloop>	
								</tbody>
							</table>
						</div>

						
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
				<!-- /.col -->
			</div>
			<!-- /.row -->
		<script language="JavaScript">	

			$(function () {
				$("#tabFaq").DataTable({
					columnDefs: [
						{ "orderable": false, "targets": 0 }//impede que a primeira coluna seja ordenada
					],
					order: [[ 1, "desc" ]],//ordena a segunda coluna como crescente
					destroy: true,
					ordering: false,
					stateSave: false,
					filter: false,
					autoWidth: true,
					pageLength: 5,
					lengthMenu: [
						[5, 10, 25, 50, -1],
						[5, 10, 25, 50, 'Todos']
					],
					buttons: [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						className: 'btExcel',
					}],
					language: {
						url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
					}
				})
					
			});
			
			function mostraFormEditFaq(faqId,tit){
				event.preventDefault()
				event.stopPropagation()
				var titulo =decodeURIComponent(tit);

				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcFaqs.cfc",
						data:{
							method: "formCadFaq",
							pc_faq_id:faqId
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#formCadFaqDiv').html(result)
						$('#faqTitulo').val(titulo)
						$('#cabecalhoAccordion').text("Editar o FAQ ID " + faqId + ': ' + titulo)
						$("#btSalvarDiv").attr("hidden",false)
						$("#faqStatus").attr("hidden",false)
						
						// Nova verificação com delay: se faqTexto for vazio ou "null", ativa envio de arquivo
						if (!$('#faqTexto').val() || $('#faqTexto').val().trim() === "" || $('#faqTexto').val().trim().toLowerCase() === "null") {
							setTimeout(function(){
								$('input[name="envioFaq"][value="arquivo"]').prop("checked", true).trigger("change");
							}, 100);
						}

						$('#cadastroFaq').CardWidget('expand')
						$('html, body').animate({ scrollTop: ($('#formCadFaqDiv').offset().top-80)} , 1000);
						$('#modalOverlay').delay(1000).hide(0, function() {
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

					});//fim fail
				}, 500);
       		}

			function excluirFaq(faqId) {				
				event.preventDefault()
				event.stopPropagation()
				var mensagem = "Deseja excluir este FAQ?";
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
					if (result.isConfirmed) {
						$('#modalOverlay').modal('show')
						setTimeout(function() {
							$.ajax({
								type: "GET",
								url: "cfc/pc_cfcFaqs.cfc",
								data:{
									method: "delFaq",
									pc_faq_id: faqId
								},
							async: false

							})//fim ajax
							.done(function(result) {
								mostraFormCadFaq()
								mostraTabFaq()	
								$('#modalOverlay').delay(1000).hide(0, function() {
									$('#modalOverlay').modal('hide');
									toastr.success('Operação realizada com sucesso!');
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
						}, 500);
					}		
				});	
			}
			
		</script>
 	</cffunction>


	<cffunction name="delFaq"   access="remote" returntype="boolean">
		<cfargument name="pc_faq_id" type="numeric" required="true" />
		<cftransaction>
			<!-- Exclui registros residuais com pc_anexo_faq_id igual a pc_faq_id-->
			<cfquery datasource="#application.dsn_processos#" name="rsFaq_anexo"> 
				SELECT pc_faq_anexo_caminho   FROM  pc_faqs
				WHERE pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">
			</cfquery>
			<cfif FileExists(rsFaq_anexo.pc_faq_anexo_caminho)>
				<cffile action = "delete" File = "#rsFaq_anexo.pc_faq_anexo_caminho#">
			</cfif>
			<cfquery datasource="#application.dsn_processos#" >
				DELETE FROM pc_faqs
				WHERE pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">
			</cfquery> 
		</cftransaction>
		<cfreturn true />
	</cffunction>

	<cffunction name="delArquivoFaq" access="remote" returntype="boolean" returnformat="json">
		<cfargument name="pc_faq_anexo_caminho" type="string" required="true" />
		<cfif FileExists(arguments.pc_faq_anexo_caminho)>
			<cffile action = "delete" File = "#arguments.pc_faq_anexo_caminho#">
		</cfif>
		<cfreturn true />
	</cffunction>

	<cffunction name="uploadArquivosFaqs" access="remote" returntype="any" returnformat="json" output="false">
    	<!-- Adicionado argumento para receber o ID do FAQ -->
        <cfargument name="pc_faq_id" type="numeric" required="true">
		<cfset thisDir = expandPath(".")>
		
		<cffile action="upload" filefield="file" destination="#application.diretorio_faqs#" nameconflict="skip" accept="application/pdf">
 		<cfquery datasource="#application.dsn_processos#" name="rsFaq_anexo"> 
			SELECT pc_faq_anexo_caminho FROM pc_faqs
			WHERE pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<cfif FileExists(rsFaq_anexo.pc_faq_anexo_caminho)>
			<cffile action="delete" file="#rsFaq_anexo.pc_faq_anexo_caminho#">
		</cfif>

		<cffile action="upload" filefield="file" destination="#application.diretorio_faqs#" nameconflict="skip" accept="application/pdf">

		<cfscript>
			thread = CreateObject("java","java.lang.Thread");
			thread.sleep(1000); // dalay para evitar arquivos com nome duplicado
		</cfscript>
		
		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'ss.SSSSS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		
		<!-- Destino contendo o ID do FAQ -->
        <cfset destino = cffile.serverdirectory & '\Arquivo_faq_id_' & arguments.pc_faq_id & '_' & data & '.' & '#cffile.clientFileExt#'>

	    <cfobject component = "pc_cfcAvaliacoes" name = "tamanhoArquivo">
		<cfinvoke component="#tamanhoArquivo#" method="renderFileSize" returnVariable="tamanhoDoArquivo" size ='#cffile.fileSize#' type='bytes'>

		<cfset nomeDoAnexo = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#' & ' (' & '#tamanhoDoArquivo#' & ')'>

		<cfif FileExists(origem)>
			<cffile action="rename" source="#origem#" destination="#destino#">
        </cfif>

		<cfset dadosArquivo = []>
		<cfset arquivo={}>
		<cfset arquivo.CAMINHO_ANEXO = destino>
		<cfset arquivo.NOME_ANEXO = nomeDoAnexo>
		<cfset arrayAppend(dadosArquivo, arquivo)>

		<cfreturn dadosArquivo>
    </cffunction>


    <cffunction name="checkArquivoExists" access="remote" returntype="boolean" returnformat="json" hint="Verifica se o arquivo existe no servidor">
        <cfargument name="filePath" type="string" required="true" />
        <cfreturn FileExists(arguments.filePath)>
    </cffunction>

</cfcomponent>