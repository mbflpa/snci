<cfcomponent >
    <cfprocessingdirective pageencoding = "utf-8">


    <cffunction name="infoProcesso"   access="remote" hint="">
        <cfargument name="pc_aval_processoForm" type="string" required="true"/>
    '   <cfargument name="btIncluirProcesso" type="string" required="false" default ="S"/>
       

		<cfquery name="rsInfoProcesso" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado, pc_orgaos.pc_org_mcu,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,CONCAT(
						'Macroprocesso: ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
						' -> N1: ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
						' -> N2: ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,
						' -> N3: ', pc_avaliacao_tipos.pc_aval_tipo_processoN3, '.'
						) as tipoProcesso

			FROM        pc_processos INNER JOIN
						pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
						pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
						pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
						pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
						pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
			WHERE  pc_processo_id = '#arguments.pc_aval_processoForm#'														
		</cfquery>
        <section class="content" id="infoProcesso">
            <cfoutput query="rsInfoProcesso">
                <div id="accordionCadItemPainel" style="margin-bottom:80px">
                    <div class="card card-success" >
                        <div class="card-header card-header_backgroundColor" >
                            <div class="card-title ">
                                <span class="d-block" data-toggle="collapse" href="##collapseTwo" style="color:##fff;font-size:16px;"> 
                                    Processo SNCI n°: <strong>#pc_processo_id#</strong> -> Órgão Avaliado: <strong>#siglaOrgAvaliado#</strong>
                                </span>
                            </div>
                        </div>
                        							
                        <div class="card-body card_border_correios" style="width:100%">
                            <div id="processosCadastrados" class="container-fluid" >
                                <div class="row">
                                    <div class="col-md-12">
                                        <cfset aux_sei = Trim('#pc_num_sei#')>
                                        <cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
                
                                        <cfif #pc_modalidade# eq 'A' or #pc_modalidade# eq 'E'>
                                            <span >Origem: <span style="color:##0692c6">#siglaOrgOrigem#</span><br>
                                            <span >Processo SEI n°: </span> <span style="color:##0692c6;margin-right:20px">#aux_sei#</span> 
                                            <span >Relatório n°:</span> <span style="color:##0692c6">#pc_num_rel_sei#</span></br>
                                        </cfif>	
                                        <cfif pc_num_avaliacao_tipo neq 2 and pc_num_avaliacao_tipo neq 445>
                                            <cfif pc_aval_tipo_descricao neq ''>
                                                <span>Tipo de Avaliação: <span style="color:##0692c6">#pc_aval_tipo_descricao#</span></span>
                                            <cfelse>
                                                <span>Tipo de Avaliação: <span style="color:##0692c6; ">#tipoProcesso#</span></span>
                                            </cfif>
                                        <cfelse>
                                                <span>Tipo de Avaliação: <span style="color:##0692c6">#pc_aval_tipo_nao_aplica_descricao#</span></span>
                                        </cfif>

                                        <cfif #pc_modalidade# eq 'A' or #pc_modalidade# eq 'E'>
                                        
                                            <div id="actions" class="row" style="margin-top:20px">
                                                <div class="col-lg-12" align="center">
                                                    <div class="btn-group w-30">
                                                        <span id="relatorios" class="btn btn-success col fileinput-button azul_claro_correios_backgroundColor" >
                                                            <i class="fas fa-upload"></i>
                                                            <span style="margin-left:5px">Clique aqui para anexar o Relatório do Processo e Anexos I, II e III em PDF (1° Passo)</span>
                                                        </span>																	
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <div class="table table-striped files" id="previewsRelatorio">
                                                <div id="templateRelatorio" class="row mt-2">
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

                                            <div id="anexoRelatorioDiv"></div>
                                        
                                        </cfif>	
                                    </div>
                                </div>

                                
                            </div>
                        </div>
                        
                    </div>
                </div>
            </cfoutput>
        </section>

        <script language="JavaScript">
            $(document).ready(function(){
                <cfoutput>
						let modalidade = '#rsInfoProcesso.pc_modalidade#'
						let pc_processo_id = '#rsInfoProcesso.pc_processo_id#'
					</cfoutput>

					if(modalidade ==='A' || modalidade ==='E'){
						// DropzoneJS Demo Code Start
						Dropzone.autoDiscover = false

						// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
						var previewNode = document.querySelector("#templateRelatorio")
						//previewNode.id = ""
						var previewTemplate = previewNode.parentNode.innerHTML
						previewNode.parentNode.removeChild(previewNode)

						var myDropzoneRelatorio = new Dropzone("#processosCadastrados", { // Make the whole body a dropzone
							url: "cfc/pc_cfcAvaliacoes.cfc?method=uploadArquivos", // Set the url
							autoProcessQueue :true,
							maxFiles: 1,
							maxFilesize:20,
							thumbnailWidth: 80,
							thumbnailHeight: 80,
							parallelUploads: 1,
							acceptedFiles: '.pdf',
							previewTemplate: previewTemplate,
							autoQueue: true, // Make sure the files aren't queued until manually added
							previewsContainer: "#previewsRelatorio", // Define the container to display the previews
							clickable: "#relatorios", // Define the element that should be used as click trigger to select files.
							headers: { "pc_aval_id":"", 
									"pc_aval_processo":pc_processo_id, 
									"pc_anexo_avaliacaoPDF":"S",
									"arquivoParaTodosOsItens":"S"},//informar "S" se o arquivo deve ser exibido em todos os itens do processo
							init: function() {
								this.on('error', function(file, errorMessage) {	
									toastr.error(errorMessage);
									return false;
								});
							}
							
						})

						


						// Hide the total progress bar when nothing's uploading anymore
						myDropzoneRelatorio.on("queuecomplete", function(progress) {
							//toastr.success("Arquivo(s) enviado(s) com sucesso!")
							myDropzoneRelatorio.removeAllFiles(true);
							mostraRelatorioPDF();

							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
						})

						
						// DropzoneJS 1 Demo Code End
					}

                    mostraRelatorioPDF()
            });
            function mostraRelatorioPDF(){
					<cfoutput>
						let pc_processo_id = '#rsInfoProcesso.pc_processo_id#'
					</cfoutput>
					$('#modalOverlay').modal('show')
					setTimeout(function() {
						$.ajax({
							type: "post",
							url:"cfc/pc_cfcAvaliacoes.cfc",
							data:{
								method: "anexoRelatorio",
								pc_anexo_processo_id: pc_processo_id
							},
							async: false
						})//fim ajax
						.done(function(result){
							
							$('#anexoRelatorioDiv').html(result)
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

						})//fim fail
					}, 1000);
				}
        </script>
    </cffunction>

</cfcomponent>