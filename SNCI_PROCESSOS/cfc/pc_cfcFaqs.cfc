<cfcomponent>
<cfprocessingdirective pageencoding = "utf-8">

	

	
	<cffunction name="FormCadFaq"   access="remote" hint="mostra form de cadastro do FAQ.">
        <cfargument name="pc_faq_id" type="numeric" required="false" default=0/>

		<!--- Novas querys para FAQ Tipos --->
        <cfquery name="rsFaqTipos" datasource="#application.dsn_processos#">
            SELECT * FROM pc_faq_tipos 
            WHERE pc_faq_tipo_status = 'A'
            ORDER BY pc_faq_tipo_id
        </cfquery>

		<cfquery name="rsPerfis" datasource="#application.dsn_processos#">
			SELECT pc_perfil_tipos.* from pc_perfil_tipos where pc_perfil_tipo_status='A' ORDER BY pc_perfil_tipo_descricao
		</cfquery>

		<cfquery name="rsFaqEdit" datasource="#application.dsn_processos#">
			SELECT pc_faqs.* FROM pc_faqs where pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<div class="content-header" style="background:  #f4f6f9;padding-top: 0;">
			<div class="container-fluid">
				<div class="card-body" style="display:flex;flex-direction:column;padding-top: 0;">

					<form  class="row g-3 needs-validation was-validated" novalidate  id="myform" name="myform" format="html"  style="height: auto;">
						
						<!--acordion-->
						<div id="accordionCadFaq" >
							<div id="cadastroFaq" class="card card-primary collapsed-card" style="margin-left: -21px;">
								<div  class="card-header azul_claro_correios_backgroundColor" style="color:#fff;">
									<a   class="d-block" data-toggle="collapse" href="#collapseCad"  data-card-widget="collapse">
										<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
										</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar</span>
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
												<label for="faqTitulo">Título:</label>
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

										
										<div class="col-sm-7" style="box-shadow:0!important">
											<div class="form-group " >
												<label for="faqPerfis">Perfis que irão visualizar:</label>
												<select id="faqPerfis" required="true" class="form-control" multiple="multiple">
													<cfoutput query="rsPerfis">
														<option value="(#pc_perfil_tipo_id#)">#pc_perfil_tipo_descricao#</option>
													</cfoutput>
												</select>
											</div>
										</div>

										<div class="col-sm-5">
											<div class="form-group">
												<label for="faqTipo">Tipo:</label>
												<div class="input-group">
													<select id="faqTipo" name="faqTipo" class="form-control" required>
														<option value="">Selecione...</option>
														<cfoutput query="rsFaqTipos">
															<option value="#pc_faq_tipo_id#" data-cor="#pc_faq_tipo_cor#" data-status="#pc_faq_tipo_status#" data-descricao="#pc_faq_tipo_descricao#" <cfif pc_faq_tipo_id eq rsFaqEdit.pc_faq_tipo>selected="selected"</cfif>>#pc_faq_tipo_nome#</option>
														</cfoutput>
													</select>
													<div class="input-group-append">
														<button class="btn btn-outline-secondary btn-sm" type="button" onclick="openModalFaqTipo();" style="margin-left: 5px;">
															<i class="fa fa-plus"></i>
														</button>
														<button class="btn btn-outline-secondary btn-sm" type="button" onclick="openModalEditFaqTipo($('#faqTipo').val());" style="margin-left: 5px;" id="btEditarFaqTipo">
															<i class="fa fa-edit"></i>
														</button>
														
													</div>
												</div>
												<!-- Novo card para descrição do tipo -->
												<div id="faqTipoDescricaoCard" class="card" style="position: absolute;margin-top: 5px; display: none; border: 1px solid #ddd;">
													<div class="card-body" style="padding: 10px; font-size: 12px;">
														<p class="mb-0" id="faqTipoDescricaoText" style="color: #666; text-align: justify;"></p>
													</div>
												</div>
											</div>
										</div>
										
										
										<div class="col-sm-12" style="margin-top: 20px;">
											<!-- Adição dos botões de opção para selecionar modo de envio -->
											<div class="form-group">
												
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" name="envioFaq" id="envioTexto" value="texto" checked>
													<label class="form-check-label" for="envioTexto" style="font-size:20px">Digite Texto</label>
												</div>
												<div class="form-check form-check-inline">
													<input class="form-check-input" type="radio" name="envioFaq" id="envioArquivo" value="arquivo">
													<label class="form-check-label" for="envioArquivo" style="font-size:20px">Anexar PDF</label>
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
											
											<cfif FileExists(rsFaqEdit.pc_faq_anexo_caminho)>
												<cfif FindNoCase("localhost", application.auxsite)>
													<cfset caminho = ListLast(rsFaqEdit.pc_faq_anexo_caminho, '\')>
												<cfelse>
													<cfset caminho = "#rsFaqEdit.pc_faq_anexo_caminho#">
												</cfif>
											<cfelse>
												<cfset caminho = "Caminho não encontrado">
											</cfif>
											<!-- Adicionado div para exibição do arquivo após upload -->
											<div  style="margin-top:15px;" hidden></div>
												<!-- Container flex para anexos -->
												<div style="padding: 0px; width: 70%; margin: 0 auto;cursor:pointer" onclick="openPdfModal(<cfoutput>#rsFaqEdit.pc_faq_id#,'#jsStringFormat(caminho)#'</cfoutput>)">
													<!-- Card com anexo -->
													<div id="arquivoFaqDiv" class="card card-primary card-tabs collapsed-card card_hover_correios" style="transition: all 0.15s ease 0s; height: inherit; width: 100%; margin: 0;">
														<div class="card-header" style="padding:10px!important;display: flex; align-items: center; width: 100%; background: linear-gradient(45deg, #b00b1e, #d4145a);">
															<h3 class="card-title" style="font-size: 16px; cursor: pointer; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; flex: 1;">
																<i class="fas fa-file-pdf"></i> <cfoutput>#rsFaqEdit.pc_faq_anexo_nome#</cfoutput>
															</h3>
															<div class="card-tools" style="margin-left: 20px;">
																<button type="button" id="btExcluir" class="btn btn-tool grow-icon" style="font-size: 16px">
																	<i class="fas fa-trash-alt"></i>
																</button>
															</div>
														</div>
													</div>
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

						</div><!--fim acordion -->
					</form><!-- fim myform -->

					<!-- Modal para cadastro de novo Tipo de FAQ -->
					<form id="formFaqTipo" >
						<div class="modal fade" id="modalFaqTipo" tabindex="-1" role="dialog" aria-labelledby="modalFaqTipoLabel" aria-hidden="true">
							<div class="modal-dialog" role="document">
								<div class="modal-content">
									<div class="modal-header">
										<h5 class="modal-title" id="modalFaqTipoLabel">Novo Tipo</h5>
										<button type="button" class="close" data-dismiss="modal" aria-label="Fechar"></button>
									</div>
									<div class="modal-body">
										<div class="form-group">
											<label for="novoFaqTipoNome">Nome:</label>
											<input type="text" class="form-control" id="novoFaqTipoNome" required>
										</div>
										<div class="col-sm-4" >
											<div class="form-group">
												<label for="novoFaqTipoCor">Cor:</label>
												<input type="color" class="form-control" id="novoFaqTipoCor" value="#007bff" required>
											</div>
										</div>
										
										<div class="form-group">
											<label for="novoFaqTipoDescricao">Descrição:</label>
											<textarea id="novoFaqTipoDescricao" class="form-control" maxlength="500" required></textarea>
										</div>
									</div>
									<div class="modal-footer">
										<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
										<button type="button" class="btn btn-primary" onclick="salvarNovoFaqTipo();">Salvar</button>
									</div>
								</div>
							</div>
						</div>
					</form>
					<!-- Nova modal para editar Tipo de FAQ -->
					<div class="modal fade" id="modalEditFaqTipo" tabindex="-1" role="dialog" aria-labelledby="modalEditFaqTipoLabel" aria-hidden="true">
						<div class="modal-dialog" role="document">
							<div class="modal-content">
								<div class="modal-header">
									<h5 class="modal-title" id="modalEditFaqTipoLabel">Editar Tipo</h5>
									<button type="button" class="close" data-dismiss="modal" aria-label="Fechar" ></button>
								</div>
								<div class="modal-body">
									<div class="form-group">
										<label for="editFaqTipoNome">Nome</label>
										<input type="text" id="editFaqTipoNome" class="form-control" required>
									</div>
									<div class="form-group">
										<label for="editFaqTipoDescricao">Descrição:</label>
										<textarea id="editFaqTipoDescricao" class="form-control" maxlength="500" required></textarea>
									</div>

									<div class="col-sm-5" >
										<div class="form-group">
											<label for="editFaqTipoCor">Cor</label>
											<input type="color" id="editFaqTipoCor" class="form-control" value="#007bff" required>
										</div>
									</div>
									<div class="col-sm-5" >
										<div class="form-group">
											<label for="editFaqTipoStatus">Status</label>
											<select id="editFaqTipoStatus" class="form-control" required>
												<option value="A">Ativo</option>
												<option value="D">Desativar</option>
											</select>
										</div>
									</div>
									
									
								</div>
								<div class="modal-footer">
									<button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
									<button type="button" class="btn btn-primary" onclick="salvarEditFaqTipo();">Salvar</button>
								</div>
							</div>
						</div>
					</div>
						
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
					$('#actions').attr("hidden", true);
					$('#previewsArquivo').attr("hidden", true);
					$('#arquivoFaqDiv').attr("hidden", true);
				}
				
				CKEDITOR.replace( 'faqTexto', {
					width: '100%',
					height: 300,
					removeButtons: 'Save'
				});

				 setArquivoFaqDiv();

				<cfoutput>
				  var ListaPerfis ="#rsFaqEdit.pc_faq_perfis#"
				</cfoutput>
				var listPerfis = ListaPerfis.split(",");
				var selectedValues = new Array();
				$.each(listPerfis, function(index,value){
					selectedValues[index] = value;
				});
				$('#faqPerfis').val(selectedValues).trigger('change');


				// Captura o template original do Dropzone na primeira carga
				if (!window.dropzoneTemplate) {
					var tempNode = document.querySelector("#templateArquivo");
					if (tempNode) {
						window.dropzoneTemplate = tempNode.parentNode.innerHTML;
					} else {
						window.dropzoneTemplate = "";
						console.error("Elemento com id 'templateArquivo' não foi encontrado na carga inicial.");
					}
				}

				$('input[name="envioFaq"]').change(function(){
					
					var anexoNome = $('#faqAnexoNome').val();
					if($(this).val() === 'arquivo'){
						
						$('#containerTexto').attr("hidden", true);
						$('#accordionCadFaq').show();
						$('#actions').removeAttr("hidden");
						$('#arquivoFaqDiv').removeAttr("hidden");
 						setArquivoFaqDiv();
						
						// Exibe o container de pré-visualizações para o Dropzone
						$('#previewsArquivo').removeAttr("hidden");

						// Se já existir uma instância do Dropzone, destrua-a
						if(window.myDropzoneFaq){
							window.myDropzoneFaq.destroy();
							delete window.myDropzoneFaq;
						}
						
						Dropzone.autoDiscover = false;
						// Verifica se o template existe, se não, reinsere-o
						var previewNode = document.querySelector("#templateArquivo");
						if(!previewNode && window.dropzoneTemplate){
							// Reinsere o template no container de pré-visualizações
							$("#previewsArquivo").html(window.dropzoneTemplate);
							previewNode = document.querySelector("#templateArquivo");
						}
						var previewTemplate = "";
						if(previewNode) {
							previewTemplate = previewNode.parentNode.innerHTML;
							previewNode.parentNode.removeChild(previewNode);
						} else {
							console.error("Elemento com id 'templateArquivo' não foi encontrado.");
						}
						
					
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
									    
                                        setArquivoFaqDiv();
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
						$('#containerTexto').removeAttr("hidden");
						$('#actions').attr("hidden", true);
						// Oculta a div de pré-visualizações quando o envio é por texto
						$('#previewsArquivo').attr("hidden", true);
						$('#arquivoFaqDiv').attr("hidden", true);
					}
				});
				
				// Removido: $('#uploadFaqButton').on('click', ...) e $('#faqFileInput').on('change', ...);

				// Lógica para exibir/ocultar o botão de editar do select faqTipo
				if ($('#faqTipo').val() == null || $('#faqTipo').val().trim() === "") {
					$('#btEditarFaqTipo').hide();
				} else {
					$('#btEditarFaqTipo').show();
				}

				$('#faqTipo').on('change', function() {
					var $selectedOption = $(this).find('option:selected');
					var descricao = $selectedOption.data('descricao');
					var cor = $selectedOption.data('cor');
					
					if (descricao && descricao.trim() !== '') {
						$('#faqTipoDescricaoText').text(descricao);
						$('#faqTipoDescricaoCard')
							.show()
							.css('border-left', '3px solid ' + (cor || '#007bff'));
					} else {
						$('#faqTipoDescricaoCard').hide();
					}
				
					// Mantém a lógica existente do botão de editar
					if ($(this).val() == null || $(this).val().trim() === "") {
						$('#btEditarFaqTipo').hide();
					} else {
						$('#btEditarFaqTipo').show();
					}
					});
				
					// Trigger a change event se já houver um valor selecionado
					if ($('#faqTipo').val()) {
						$('#faqTipo').trigger('change');
					}
			});

			

			$('#btCancelar').on('click', function (event)  {
				event.preventDefault();
				event.stopPropagation();
				// Limpa todos os campos do formulário
				$('#myform').trigger("reset");
				// try {
				// 	var editor = CKEDITOR.instances.faqTexto;
				// 	if (editor && typeof editor.setData === 'function') {
				// 		editor.setData('');
				// 	}
				// } catch (e) {
				// 	console.error("Erro ao limpar CKEditor:", e);
				// }
				$('#faqPerfis').val(null).trigger('change');
				$('#faqStatus').val(null).trigger('change');
				$('#faqTipo').val(null).trigger('change');
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
						pc_faq_tipo: $('#faqTipo').val(),
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

				// Alteração: Adicionada verificação para o select "#faqTipo"
				if (!$('#faqPerfis').val() || !$('#faqTitulo').val() || !$('#faqStatus').val() || !$('#faqTipo').val()){
					toastr.error('Todos os campos devem ser preenchidos.');
					return false;
				}
					
				var envioTipo = $('input[name="envioFaq"]:checked').val();
				var dataEditor;
				var existeArquivo = $('#faqAnexoNome').val() && $('#faqAnexoNome').val().trim() !== "";
				var existeTexto = CKEDITOR.instances.faqTexto && typeof CKEDITOR.instances.faqTexto.getData === 'function' &&
								  CKEDITOR.instances.faqTexto.getData().trim() !== "";
			
				// Validações específicas baseadas no tipo de envio
				if(envioTipo === "texto"){
					if (CKEDITOR.instances.faqTexto && typeof CKEDITOR.instances.faqTexto.getData === 'function') {
						dataEditor = CKEDITOR.instances.faqTexto.getData();
					} else {
						dataEditor = "";
					}
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
					mensagem = "Deseja cadastrar esta informação/guia/tutorial?";
				} else {
					mensagem = "Deseja editar esta informação/guia/tutorial?";
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
									pc_faq_tipo: $('#faqTipo').val(),
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
                setArquivoFaqDiv();
                mostraFormCadFaq();
                mostraTabFaq();
                $('#modalOverlay').delay(1000).hide(0, function(){
                    $('#modalOverlay').modal('hide');
                    toastr.success('Operação realizada com sucesso!');
                });
                if ($('input[name="envioFaq"]:checked').val() === "texto") {
                    CKEDITOR.instances.faqTexto.setData('');
                    $('#cadastroFaq').CardWidget('collapse');
                    $('#cabecalhoAccordion').text("Clique aqui para cadastrar");
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
							$(`[id^='pdfModal']`).modal('hide');
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
			function setArquivoFaqDiv() {
				var filePath = $('#faqAnexoCaminho').val();
				if (filePath && filePath.trim() !== "") {
					
					if (checkArquivoExists(filePath)) {
						 // Exibe a div e oculta o botão de upload se o arquivo existe
						$("#arquivoFaqDiv").removeAttr("hidden");
						$("#arquivo").hide();
					} else {
						// Oculta a div e exibe a mensagem de erro se o arquivo não existe
						$("#arquivoFaqDiv")
							.removeAttr("hidden")
							.html("<h5 style='color:red'>O arquivo foi deletado ou não é possível o seu acesso</h5>");
					}
				} else {
					// Oculta a div se não houver arquivo
					$("#arquivoFaqDiv").attr("hidden", true);
					// Função para abrir o modal de cadastro de novo Tipo de FAQ
				}
			}

			function openModalFaqTipo() {
				$('#modalFaqTipo').modal('show');
			}

			// Função para salvar o novo tipo via Ajax e atualizar o select
			function salvarNovoFaqTipo() {
				// Validação adicionada
				if (!$('#novoFaqTipoNome').val() || !$('#novoFaqTipoDescricao').val() || !$('#novoFaqTipoCor').val()){
					toastr.error('Todos os campos devem ser preenchidos.');
					return false;
				}
				
				if (window.isSavingFaqTipo) {
					return; // Impede múltiplos envios
				}
				window.isSavingFaqTipo = true;
				
				var nome = $('#novoFaqTipoNome').val().trim();
				var descricao = $('#novoFaqTipoDescricao').val().trim();
				var cor = $('#novoFaqTipoCor').val();
				
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcFaqs.cfc",
						dataType: "json",
						data: {
							method: "novoFaqTipo",
							pc_faq_tipo_nome: nome,
							pc_faq_tipo_descricao: descricao,
							pc_faq_tipo_cor: cor
							}
					})//fim ajax
					.done(function(response) {
						var novoTipo = response[0];
						// Atualiza o select: adiciona nova opção e seleciona-a
						$('#faqTipo').append('<option value="'+novoTipo.PC_FAQ_TIPO_ID+'" selected>'+novoTipo.PC_FAQ_TIPO_NOME+'</option>');
						$('#modalFaqTipo').modal('hide');
						toastr.success("Novo tipo cadastrado com sucesso!");
						$('#novoFaqTipoDescricao').val(''); // Reseta o campo
							$('#novoFaqTipoCor').val('#007bff'); // Reseta a cor para padrão
						window.isSavingFaqTipo = false;
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					})//fim done
					 .fail(function(jqXHR, textStatus, errorThrown) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(errorThrown || 'Erro desconhecido')
						window.isSavingFaqTipo = false;
					});
				}, 100);
				
				
			}

			// Função global para abrir o modal de edição do Tipo de FAQ
			function openModalEditFaqTipo(faqTipoId) {
				var $option = $("#faqTipo option[value='" + faqTipoId + "']");
				var nome = $option.text();
				var descricao = $option.data("descricao");
				var cor = $option.data("cor") || "#007bff";
				var status = $option.data("status") || "A";
				$("#editFaqTipoNome").val(nome);
				$("#editFaqTipoDescricao").val(descricao);
				$("#editFaqTipoCor").val(cor);
				$("#editFaqTipoStatus").val(status);
				$("#modalEditFaqTipo").data("faqTipoId", faqTipoId);
				$("#modalEditFaqTipo").modal("show");
			}

			// Função global para salvar a edição do Tipo de FAQ via Ajax
			function salvarEditFaqTipo() {
				// Validação adicionada
				if (!$('#editFaqTipoNome').val() || !$('#editFaqTipoDescricao').val() || !$('#editFaqTipoCor').val() || !$('#editFaqTipoStatus').val()){
					toastr.error('Todos os campos devem ser preenchidos.');
					return false;
				}

				var faqTipoId = $("#modalEditFaqTipo").data("faqTipoId");
				var nome = $("#editFaqTipoNome").val().trim();
				var descricao = $("#editFaqTipoDescricao").val();
				var cor = $("#editFaqTipoCor").val();
				var status = $("#editFaqTipoStatus").val();
				
				$("#modalOverlay").modal("show");
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcFaqs.cfc",
					dataType: "json",
					data: {
						method: "editFaqTipo",
						pc_faq_tipo_id: faqTipoId,
						pc_faq_tipo_nome: nome,
						pc_faq_tipo_descricao: descricao,
						pc_faq_tipo_cor: cor,
						pc_faq_tipo_status: status
					},
					async: false
				})
				.done(function(response){
					// Tratamento similar ao salvarNovoFaqTipo(), usando response[0]
					var resp = response[0];
					var $option = $("#faqTipo option[value='" + faqTipoId + "']");
					$option.text(resp.pc_faq_tipo_nome);
					$option.data("descricao", resp.PC_FAQ_TIPO_DESCRICAO);
					$option.data("cor", resp.PC_FAQ_TIPO_COR);
					$option.data("status", resp.PC_FAQ_TIPO_STATUS);
					 // Reinicializa o select2 para atualizar a exibição da nova descrição
					$("#faqTipo").select2('destroy');
					$("#faqTipo").select2({
						theme: 'bootstrap4',
						placeholder: 'Selecione...',
						allowClear: true
					});
					$("#faqTipo").trigger("change");
					$("#modalEditFaqTipo").modal("hide");
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
					toastr.success("Tipo atualizado com sucesso!");
					
				})
				.fail(function(jqXHR, textStatus, errorThrown){
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
					$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(errorThrown)
				});
			}

		</script>
	</cffunction>



	<cffunction name="cadFaq" access="remote" returntype="any" returnformat="json" output="false" hint="Cadastra o FAQ.">
		<cfargument name="pc_faq_id" type="any" required="false" default=0/>
		<cfargument name="pc_faq_status" type="string" required="true"/>
		<cfargument name="pc_faq_titulo" type="string" required="true" />
		<cfargument name="pc_faq_perfis" type="any" required="true" />
		<cfargument name="pc_faq_texto" type="string" required="false" default="" />
		<cfargument name="pc_faq_tipo" type="any" required="true"  />
		<cfargument name="pc_faq_anexo_caminho" type="string" required="false" default="" />
		<cfargument name="pc_faq_anexo_nome" type="string" required="false" default="" />
	
		<cfif arguments.pc_faq_id eq 0 or arguments.pc_faq_id eq "" >
			<cfquery datasource="#application.dsn_processos#" result="resultFaq">
				INSERT INTO pc_faqs
								(pc_faq_titulo, pc_faq_perfis,pc_faq_status,pc_faq_texto,pc_faq_anexo_caminho,pc_faq_anexo_nome,pc_faq_atualiz_datahora,pc_faq_matricula_atualiz, pc_faq_tipo)
				VALUES     		(<cfqueryparam value="#arguments.pc_faq_titulo#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_perfis#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_status#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_texto#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_anexo_caminho#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_anexo_nome#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								 '#application.rsUsuarioParametros.pc_usu_matricula#',
								 <cfqueryparam value="#arguments.pc_faq_tipo#" cfsqltype="cf_sql_numeric">)
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
					   pc_faq_matricula_atualiz =  <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
					   pc_faq_tipo = <cfqueryparam value="#arguments.pc_faq_tipo#" cfsqltype="cf_sql_numeric">
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
	    <!-- Adiciona o parâmetro para filtrar, default 0 -->
		<cfargument name="tipoFaq" type="numeric" required="false" default="0">

		<cfquery datasource="#application.dsn_processos#" name="rsFaqs">
			SELECT pc_faqs.*, pc_usu_nome,pc_faq_tipo_cor FROM  pc_faqs
			INNER JOIN pc_usuarios on pc_usu_matricula = pc_faq_matricula_atualiz
			INNER JOIN pc_faq_tipos on pc_faq_tipo = pc_faq_tipo_id
			where pc_faq_perfis like '%(#application.rsUsuarioParametros.pc_usu_perfil#)%' and pc_faq_status = 'A'
			<cfif arguments.tipoFaq neq 0>
				  and pc_faq_tipo_id = <cfqueryparam value="#arguments.tipoFaq#" cfsqltype="cf_sql_numeric">
			</cfif>
			order by  pc_faq_tipo_id, pc_faq_titulo
		</cfquery>
			<style>
				
				/* Ajusta altura, padding e line-height da DataTable gridFaq */
				#gridFaq tr, #gridFaq td, #gridFaq th {
					padding: 0px !important;
					line-height: 1 !important;
					height: auto !important;
				}
				.dt-info {
					margin-left: 20px!important;
				}
				
				/* Animação de pulsação com brilho vermelho */
				@keyframes pulseAndGlow {
					0% {
						transform: scale(1);
						filter: brightness(100%) drop-shadow(0 0 0px rgba(220, 53, 69, 0));
					}
					25% {
						transform: scale(1.3);
						filter: brightness(130%) drop-shadow(0 0 8px rgba(220, 53, 69, 0.8));
					}
					50% {
						transform: scale(1);
						filter: brightness(100%) drop-shadow(0 0 0px rgba(220, 53, 69, 0));
					}
					75% {
						transform: scale(1.3);
						filter: brightness(130%) drop-shadow(0 0 8px rgba(220, 53, 69, 0.8));
					}
					100% {
						transform: scale(1);
						filter: brightness(100%) drop-shadow(0 0 0px rgba(220, 53, 69, 0));
					}
				}

				.expand-icon-highlight {
					animation: pulseAndGlow 1.5s ease-in-out 2; /* 1.5s x 2 = 3 segundos total */
					color: #dc3545; /* Cor vermelha do Bootstrap */
				}
				
			</style>
			<div class="row">
				<div class="col-12">
					<!-- Novo estilo para a tabela gridFaq com altura menor nas linhas -->
					
					<table id="gridFaq" class="table ">
						<thead>
							<tr>
								<th></th>
							</tr>
						</thead>
						<tbody>
							<cfloop query="rsFaqs">
								<cfoutput>
								<tr>
									<td>
										<div class="card  card-outline" style="    border-top: 3px solid #pc_faq_tipo_cor#;">
											<a class="d-block w-100" data-toggle="collapse" href="##collapse#pc_faq_id#" role="button" aria-expanded="false">
												<div class="card-header" style="<cfif pc_faq_status eq 'D'>background-color: ##e5e5eb; color:red</cfif>; padding: .5rem 1.0rem!important;">
												<h4 class="card-title 1-300" >
													<cfif pc_faq_status eq 'D'>
														<span class="badge badge-warning navbar-badge" style="float: left; right: initial; top: 1px;">Desativado</span>
													</cfif>
													#pc_faq_titulo#
												</h4>
												<div class="card-tools">
													<!-- Alteração: botão que abre o card em outra aba -->
													<button type="button" class="btn btn-tool" onclick="openCollapseContent(#pc_faq_id#)">
														<i class="fas fa-expand" style="font-size:30px; display:block;position: relative;top: 3px;"></i>
													</button>
												</div>
											</div>
										</a>
										<div id="collapse#pc_faq_id#" class="collapse">
											<div class="card-body">
												<cfif len(trim(pc_faq_anexo_caminho)) and len(trim(pc_faq_anexo_nome))>
													<iframe src="cfc/pc_cfcFaqs.cfc?method=exibePdfInline&arquivo=#URLEncodedFormat(pc_faq_anexo_caminho)#&nome=#URLEncodedFormat(pc_faq_anexo_nome)#"
                   									 width="100%" height="400px" style="border:none;"></iframe>
												<cfelse>
													<div>#pc_faq_texto#</div>
												</cfif>
												
											</div>
										</div>
									</div>
								</td>
							</tr>
							</cfoutput>
						</cfloop>
					</tbody>
				</table>
			</div>
		</div>
		<script language="JavaScript">	
			$(function(){
				$("#gridFaq").DataTable({
					destroy: true,
					responsive: true,
					paging: false,         // Exibe todas as linhas (paginação desabilitada)
					ordering: false,
					autoWidth: false,
					lengthChange: false,   // Impede a seleção de quantidade de linhas
					dom: '<"row"<"col-sm-12 d-flex align-items-center"f i>>t',             // Modificado: Apenas exibe a tabela, remove a busca
					language: {
						url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json",
					}
					});
				// Nova regra para garantir que ao abrir um FAQ os demais sejam fechados (comportamento accordion)
				$('.collapse').on('show.bs.collapse', function(){
					// Encontra o ícone de expansão dentro do card atual
					var expandIcon = $(this).closest('.card').find('.fa-expand');
					
					// Remove classe de animação existente (se houver)
					expandIcon.removeClass('expand-icon-highlight');
					
					// Força um reflow do DOM para reiniciar a animação
					void expandIcon[0].offsetWidth;
					
					// Adiciona a classe para iniciar a animação
					expandIcon.addClass('expand-icon-highlight');
					
					// Remove a classe após a animação terminar
					setTimeout(() => {
						expandIcon.removeClass('expand-icon-highlight');
					}, 3000); // Alterado para 3000ms (3 segundos)

					// Mantém o comportamento original de fechar outros FAQs
					$('.collapse').not(this).collapse('hide');
				});
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
						$('#cabecalhoAccordion').text("Editar a informação ID " + faqId + ': ' + titulo)
						$("#btSalvarDiv").attr("hidden",false)
						$("#faqStatus").attr("hidden",false)
						
						// Nova verificação com delay: se faqTexto for vazio ou "null", ativa envio de arquivo
						if (!$('#faqTexto').val() || $('#faqTexto').val().trim() === "" || $('#faqTexto').val().trim().toLowerCase() === "null") {
							setTimeout(function(){
								$('input[name="envioFaq"][value="arquivo"]').prop("checked", true).trigger("change");
								// Exibe o nome do arquivo anexo, se disponível
								var anexoNome = $('#faqAnexoNome').val();
								if(anexoNome && anexoNome.trim() !== ""){
									
									setArquivoFaqDiv();
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

			function openCollapseContent(faqId) {
				var el = document.getElementById('collapse' + faqId);
				if (el) {
					var newWindow = window.open("", "_blank");
					var title = "FAQ " + faqId; // Defina o nome desejado para a aba
					var content = el.innerHTML.replace(/height="400px"/g, 'height="100%"');
					newWindow.document.write("<html><head><title>SNCI-Processos: Informação</title></head><body>" + content + "</body></html>");
					newWindow.document.close();
				} else {
					alert("Conteúdo não encontrado!");
				}
			}
			
		</script>
 	</cffunction>

	<cffunction name="formFaqIndex" access="remote" hint="Exibe os FAQs na página index.cfm.">
	
		<cfquery datasource="#application.dsn_processos#" name="rsFaqs">
			SELECT pc_faqs.*, pc_usu_nome,pc_faq_tipo_cor FROM  pc_faqs
			INNER JOIN pc_usuarios on pc_usu_matricula = pc_faq_matricula_atualiz
			INNER JOIN pc_faq_tipos on pc_faq_tipo = pc_faq_tipo_id
			WHERE pc_faq_perfis like '%(#application.rsUsuarioParametros.pc_usu_perfil#)%' and pc_faq_status = 'A'
			      AND pc_faq_tipo_id = 1
			ORDER BY  pc_faq_id desc, pc_faq_titulo
		</cfquery>
		
		<style>
			/* Ajusta altura, padding e line-height da DataTable gridFaq */
			#gridFaq tr, #gridFaq td, #gridFaq th {
				padding: 0px !important;
				line-height: 1 !important;
				height: auto !important;
			}

			/* Animação de pulsação com brilho vermelho */
			@keyframes pulseAndGlow {
				0% {
					transform: scale(1);
					filter: brightness(100%) drop-shadow(0 0 0px rgba(220, 53, 69, 0));
				}
				25% {
					transform: scale(1.3);
					filter: brightness(130%) drop-shadow(0 0 8px rgba(220, 53, 69, 0.8));
				}
				50% {
					transform: scale(1);
					filter: brightness(100%) drop-shadow(0 0 0px rgba(220, 53, 69, 0));
				}
				75% {
					transform: scale(1.3);
					filter: brightness(130%) drop-shadow(0 0 8px rgba(220, 53, 69, 0.8));
				}
				100% {
					transform: scale(1);
					filter: brightness(100%) drop-shadow(0 0 0px rgba(220, 53, 69, 0));
				}
			}

			.expand-icon-highlight {
				animation: pulseAndGlow 1.5s ease-in-out 2; /* 1.5s x 2 = 3 segundos total */
				color: #dc3545; /* Cor vermelha do Bootstrap */
			}

			/* Novo estilo para as badges de leitura */
			.read-status-badge {
				position: absolute;
				top: -8px;
				left: 0px;
				padding: 2px 8px;
				border-radius: 10px;
				font-size: 11px;
				z-index: 1;
				color: white;
				white-space: nowrap;
			}
			.unread {
				background-color: #dc3545;
			}
			.read {
				background-color: #28a745;
			}
		</style>
		<cfif rsFaqs.recordCount>	
			<div class="row">
				<div class="col-12">
					<!-- Encapsula a tabela em um container, se necessário -->
					<div id="accordionFaq">
						<table id="gridFaq" class="table">
							<thead>
								<tr>
									<th style="border:none!important;"><h4 style="color:#cd0001;margin-bottom:20px!important;">
										<cfif rsFaqs.recordCount eq 1>
											Informação Importante
										<cfelse>
											Informações Importantes
										</cfif>
										</h4>
									</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="rsFaqs">
									<cfoutput>
									<tr>
										<td>
											<div class="card  card-outline" style="border-top: 3px solid #pc_faq_tipo_cor#;">
												<a class="d-block w-100" data-toggle="collapse" href="##collapse#pc_faq_id#" role="button" aria-expanded="false">
													<div class="card-header" style="text-align: center;<cfif pc_faq_status eq 'D'>background-color: ##e5e5eb; color:red</cfif>; padding: .2rem 1.0rem!important;">
														<!-- Nova badge de status de leitura -->
														<span class="read-status-badge unread" id="badge_#pc_faq_id#">Não lida</span>
														<cfset dataFaq = DateFormat(pc_faq_atualiz_datahora, 'DD-MM-YYYY') & '-' & TimeFormat(pc_faq_atualiz_datahora, 'HH') & 'h' & TimeFormat(pc_faq_atualiz_datahora, 'MM') & 'min'>
														<h4 class="card-title 1-300" style="margin:8px">
															<cfif pc_faq_status eq 'D'>
																<span class="badge badge-warning navbar-badge" style="float: left; right: initial; top: 1px;">Desativado</span>
															</cfif>
															#pc_faq_titulo#
														</h4>
														<div class="card-tools">
															<!-- Alteração: botão que abre o card em outra aba -->
															<button type="button" class="btn btn-tool" onclick="openCollapseContent(#pc_faq_id#)">
																<i class="fas fa-expand" style="font-size:30px; display:block; margin:auto;margin-top: 10px;"></i>
															</button>
														</div>
														
													</div>
												</a>
												<div id="collapse#pc_faq_id#" class="collapse <cfif rsFaqs.recordCount eq 1>show</cfif>">
													<div class="card-body">
														<cfif len(trim(pc_faq_anexo_caminho)) and len(trim(pc_faq_anexo_nome))>
															<iframe src="cfc/pc_cfcFaqs.cfc?method=exibePdfInline&arquivo=#URLEncodedFormat(pc_faq_anexo_caminho)#&nome=#URLEncodedFormat(pc_faq_anexo_nome)#"
															width="100%" height="400px" style="border:none;"></iframe>
														<cfelse>
															<div>#pc_faq_texto#</div>
														</cfif>
														
													</div>
												</div>
											</div>
										</td>
									</tr>
									</cfoutput>
								</cfloop>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</cfif>
		<script language="JavaScript">	
			$(function(){
				$("#gridFaq").DataTable({
					responsive: true,
					paging: false,         // Exibe todas as linhas (paginação desabilitada)
					ordering: false,
					autoWidth: false,
					lengthChange: false,   // Impede a seleção de quantidade de linhas
					dom: 't',             // Modificado: Apenas exibe a tabela, remove a busca
					language: {
						url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json",
						info: "" // Remove a informação de registros
					}
					});
				// Nova regra para garantir que ao abrir um FAQ os demais sejam fechados (comportamento accordion)
				$('.collapse').on('show.bs.collapse', function(){
					// Encontra o ícone de expansão dentro do card atual
					var expandIcon = $(this).closest('.card').find('.fa-expand');
					
					// Remove classe de animação existente (se houver)
					expandIcon.removeClass('expand-icon-highlight');
					
					// Força um reflow do DOM para reiniciar a animação
					void expandIcon[0].offsetWidth;
					
					// Adiciona a classe para iniciar a animação
					expandIcon.addClass('expand-icon-highlight');
					
					// Remove a classe após a animação terminar
					setTimeout(() => {
						expandIcon.removeClass('expand-icon-highlight');
					}, 3000); // Alterado para 3000ms (3 segundos)

					// Mantém o comportamento original de fechar outros FAQs
					$('.collapse').not(this).collapse('hide');

					// Marcar FAQ como lido
					let faqId = $(this).attr('id').replace('collapse', '');
					markAsRead(faqId);
				});

				// Função para verificar status de leitura dos FAQs
				function checkReadStatus() {
					let readFaqs = JSON.parse(localStorage.getItem('readFaqs') || '[]');
					$('.read-status-badge').each(function() {
						let faqId = $(this).attr('id').split('_')[1];
						let card = $(this).closest('.card');
						if (readFaqs.includes(faqId)) {
							$(this)
								.removeClass('unread')
								.addClass('read')
								.text('Lida');
							card.css('border-top', '3px solid #28a745');
						} else {
							card.css('border-top', '3px solid #dc3545');
						}
					});
				}

				// Função para marcar FAQ como lido
				function markAsRead(faqId) {
					let readFaqs = JSON.parse(localStorage.getItem('readFaqs') || '[]');
					if (!readFaqs.includes(faqId)) {
						readFaqs.push(faqId);
						localStorage.setItem('readFaqs', JSON.stringify(readFaqs));
						let badge = $(`#badge_${faqId}`);
						let card = badge.closest('.card');
						badge
							.removeClass('unread')
							.addClass('read')
							.text('Lida');
						card.css('border-top', '3px solid #28a745');
					}
				}

				// Verificar status inicial
				checkReadStatus();
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
						$('#cabecalhoAccordion').text("Editar a informação ID " + faqId + ': ' + titulo)
						$("#btSalvarDiv").attr("hidden",false)
						$("#faqStatus").attr("hidden",false)
						
						// Nova verificação com delay: se faqTexto for vazio ou "null", ativa envio de arquivo
						if (!$('#faqTexto').val() || $('#faqTexto').val().trim() === "" || $('#faqTexto').val().trim().toLowerCase() === "null") {
							setTimeout(function(){
								$('input[name="envioFaq"][value="arquivo"]').prop("checked", true).trigger("change");
								// Exibe o nome do arquivo anexo, se disponível
								var anexoNome = $('#faqAnexoNome').val();
								if(anexoNome && anexoNome.trim() !== ""){
									
									setArquivoFaqDiv();
								}
							}, 100);
						}

						$('#cadastroFaq').CardWidget('expand')
						//$('html, body').animate({ scrollTop: ($('#formCadFaqDiv').offset().top-80)} , 1000);
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
			

			function openCollapseContent(faqId) {
				var el = document.getElementById('collapse' + faqId);
				if (el) {
					var newWindow = window.open("", "_blank");
					var title = "FAQ " + faqId; // Defina o nome desejado para a aba
					var content = el.innerHTML.replace(/height="400px"/g, 'height="100%"');
					newWindow.document.write("<html><head><title>SNCI-Processos: Informação</title></head><body>" + content + "</body></html>");
					newWindow.document.close();
				} else {
					alert("Conteúdo não encontrado!");
				}
			}
			
		</script>
 	</cffunction>

	<cffunction name="tabFaq" access="remote" hint="exibe os FAQs na página pc_faq.cfm.">
        <cfargument name="cadastro" type="string" required="false" default="S"/>
		
		<!--- Atualize a query para incluir a descrição do Tipo de FAQ --->
		<cfquery datasource="#application.dsn_processos#" name="rsFaqs">
			SELECT 
				f.*, 
				u.pc_usu_nome, 
				t.pc_faq_tipo_nome 
			FROM pc_faqs f
			INNER JOIN pc_usuarios u ON u.pc_usu_matricula = f.pc_faq_matricula_atualiz
			LEFT JOIN pc_faq_tipos t ON t.pc_faq_tipo_id = f.pc_faq_tipo
			<cfif ('#application.rsUsuarioParametros.pc_usu_perfil#' eq '3' or '#application.rsUsuarioParametros.pc_usu_perfil#' eq '11') and '#arguments.cadastro#' eq 'S'>
				ORDER BY f.pc_faq_status ASC, f.pc_faq_atualiz_datahora DESC
			<cfelse>
				WHERE f.pc_faq_perfis like '%(#application.rsUsuarioParametros.pc_usu_perfil#)%' and f.pc_faq_status = 'A'
				ORDER BY f.pc_faq_id DESC
			</cfif>
		</cfquery>

	
			<div class="row" >
				<div class="col-12">
					<div class="card">
						<!-- /.card-header -->
						<div class="card-body">
							<table id="tabFaq" class="table  table-hover table-striped">
								<thead  class="table_thead_backgroundColor">
									<tr style="font-size:12px!important">
										<th align="center">Controles</th>
										<th>ID</th>
										<th>Título</th>
										<th>Tipo</th>
										<th>Conteúdo</th>
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
												<td style="vertical-align: middle;">#pc_faq_tipo_nome#</td>
												<td style="vertical-align: middle;">
													<cfif len(trim(pc_faq_texto)) GT 0>
														Texto
													<cfelseif len(trim(pc_faq_anexo_nome)) GT 0>
														Arquivo
													<cfelse>
														-
													</cfif>
												</td>
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
						$('#cabecalhoAccordion').text("Editar a informação ID " + faqId + ': ' + titulo)
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

		<cfset nomeDoAnexo = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#'>

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


    <cffunction name="novoFaqTipo" access="remote" returntype="any" returnformat="json" output="false" hint="Cadastra um novo tipo de FAQ.">
        <!-- Adicionado argumento para a cor -->
		<cfargument name="pc_faq_tipo_nome" type="string" required="true" />
		<cfargument name="pc_faq_tipo_descricao" type="string" required="true" />
		<cfargument name="pc_faq_tipo_cor" type="string" required="false" default=""/>
		<cfquery datasource="#application.dsn_processos#" result="qryResult">
			INSERT INTO pc_faq_tipos (pc_faq_tipo_nome, pc_faq_tipo_descricao, pc_faq_tipo_cor, pc_faq_tipo_status)
			VALUES (
				<cfqueryparam value="#arguments.pc_faq_tipo_nome#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.pc_faq_tipo_descricao#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#arguments.pc_faq_tipo_cor#" cfsqltype="cf_sql_varchar">,
				'A'
			)
		</cfquery>
		<cfset novosTipos = []>
		<cfset novoTipo = {}>
		<cfset novoTipo.PC_FAQ_TIPO_ID = qryResult.generatedKey>
		<cfset novoTipo.PC_FAQ_TIPO_NOME = arguments.pc_faq_tipo_nome>
		<cfset novoTipo.PC_FAQ_TIPO_DESCRICAO = arguments.pc_faq_tipo_descricao>
		<cfset novoTipo.PC_FAQ_TIPO_COR = arguments.pc_faq_tipo_cor>
		<cfset arrayAppend(novosTipos, novoTipo)>
		<cfreturn novosTipos>
    </cffunction>

	<cffunction name="editFaqTipo" access="remote" returntype="any" returnformat="json" output="false" hint="Edita o Tipo de FAQ.">
		<cfargument name="pc_faq_tipo_id" type="numeric" required="true" />
		<cfargument name="pc_faq_tipo_nome" type="string" required="true" />
		<cfargument name="pc_faq_tipo_descricao" type="string" required="true" />
		<cfargument name="pc_faq_tipo_cor" type="string" required="false" default=""/>
		<cfargument name="pc_faq_tipo_status" type="string" required="true" />
		<cfquery datasource="#application.dsn_processos#">
			UPDATE pc_faq_tipos
			SET pc_faq_tipo_nome = <cfqueryparam value="#arguments.pc_faq_tipo_nome#" cfsqltype="cf_sql_varchar">,
				pc_faq_tipo_descricao = <cfqueryparam value="#arguments.pc_faq_tipo_descricao#" cfsqltype="cf_sql_varchar">,
				pc_faq_tipo_cor = <cfqueryparam value="#arguments.pc_faq_tipo_cor#" cfsqltype="cf_sql_varchar">,
				pc_faq_tipo_status = <cfqueryparam value="#arguments.pc_faq_tipo_status#" cfsqltype="cf_sql_varchar">
			WHERE pc_faq_tipo_id = <cfqueryparam value="#arguments.pc_faq_tipo_id#" cfsqltype="cf_sql_numeric">
		</cfquery>
		<cfset tiposEditados = []>
		<cfset tipoEditado = {}>
		<cfset tipoEditado.PC_FAQ_TIPO_ID = arguments.pc_faq_tipo_id>
		<cfset tipoEditado.PC_FAQ_TIPO_NOME = arguments.pc_faq_tipo_nome>
		<cfset tipoEditado.PC_FAQ_TIPO_DESCRICAO = arguments.pc_faq_tipo_descricao>
		<cfset tipoEditado.PC_FAQ_TIPO_COR = arguments.pc_faq_tipo_cor>
		<cfset tipoEditado.PC_FAQ_TIPO_STATUS = arguments.pc_faq_tipo_status>
		<cfset arrayAppend(tiposEditados, tipoEditado)>
		<cfreturn tiposEditados>
	</cffunction>

	<cffunction name="exibePdfInline" access="remote" output="true" hint="Exibe um arquivo PDF diretamente no navegador.">
        <cfargument name="arquivo" type="string" required="true" />
        <cfargument name="nome" type="string" required="false" default="documento.pdf" />

        <cfif NOT FileExists(arguments.arquivo)>
            <cfoutput>Arquivo não encontrado.</cfoutput>
            <cfabort>
        </cfif>

        <cfheader name="Content-Disposition" value="inline; filename=#arguments.nome#">
        <cfcontent type="application/pdf" file="#arguments.arquivo#" deleteFile="no">
    </cffunction>

</cfcomponent>