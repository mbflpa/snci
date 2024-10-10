<cfcomponent >
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
								<div  class="card-header" style="background-color: #0083ca;color:#fff;">
									<a   class="d-block" data-toggle="collapse" href="#collapseCad"  data-card-widget="collapse">
										<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
										</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um novo FAQ</span>
									</a>
									
								</div>
								
								<input id="faqId" value="<cfoutput>#rsFaqEdit.pc_faq_id#</cfoutput>" hidden>

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
									
											<div align="center">
												<div class="container">
													<textarea  id="faqTexto" name="faqTexto"><cfoutput>#rsFaqEdit.pc_faq_texto#</cfoutput></textarea>							
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

					
						
				</div>	<!-- fim card-body -->
			</div>
		</div>
		<script language="JavaScript">

			//Initialize Select2 Elements
			$('select').select2({
				theme: 'bootstrap4',
				placeholder: 'Selecione...'
			});

			$(document).ready(function() {	
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

			});


			$('#btCancelar').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()
				mostraFormCadFaq()
			});



			$('#btSalvar').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()

				if (!$('#faqPerfis').val() || !$('#faqTitulo').val() || !$('#faqStatus').val()){
					//mostra mensagem de erro, se algum campo necessário nesta fase não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos.');
					return false;
				}

				var dataEditor = CKEDITOR.instances.faqTexto.getData();
				if(dataEditor.length <100){
					toastr.error('Insira um texto com, no mínimo, 100 caracteres.');
					return false;
				}
					
				var mensagem = ""
				if($('#faqId').val() == ''){
					var mensagem = "Deseja cadastrar este FAQ?"
				}else{
					var mensagem = "Deseja editar este FAQ?"
				}
				
				
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							var perfisList = $('#faqPerfis').val();
						
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcFaqs.cfc",
									data:{
										method: "cadFaq",
										pc_faq_id: $('#faqId').val(),
										pc_faq_perfis:perfisList.join(','),
										pc_faq_titulo:$('#faqTitulo').val(),
										pc_faq_status: $('#faqStatus').val(),
										pc_faq_texto: dataEditor	
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

									CKEDITOR.instances.faqTexto.setData('');
									$('#cadastroFaq').CardWidget('collapse')
									$('#cabecalhoAccordion').text("Clique aqui para cadastrar um novo FAQ");
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
							}, 500);
						}
						
					})

					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
					
				
			});


			


		</script>
	</cffunction>



	<cffunction name="cadFaq"   access="remote" hint="Cadastra o FAQ.">
		<cfargument name="pc_faq_id" type="any" required="false" default=0/>
		<cfargument name="pc_faq_status" type="string" required="true"/>
		<cfargument name="pc_faq_titulo" type="string" required="true" />
		<cfargument name="pc_faq_perfis" type="any" required="true" />
		<cfargument name="pc_faq_texto" type="string" required="true"/>

		<cfif '#arguments.pc_faq_id#' eq 0 or '#arguments.pc_faq_id#' eq '' >
			<cfquery datasource="#application.dsn_processos#" >
				INSERT INTO pc_faqs
								(pc_faq_titulo, pc_faq_perfis,pc_faq_status,pc_faq_texto,pc_faq_atualiz_datahora,pc_faq_matricula_atualiz)
				VALUES     		(<cfqueryparam value="#arguments.pc_faq_titulo#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_perfis#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_status#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#arguments.pc_faq_texto#" cfsqltype="cf_sql_varchar">,
								 <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								 '#application.rsUsuarioParametros.pc_usu_matricula#')
			</cfquery>
		<cfelse>
		    <cfquery datasource="#application.dsn_processos#" >
				UPDATE pc_faqs
				SET    pc_faq_titulo = <cfqueryparam value="#arguments.pc_faq_titulo#" cfsqltype="cf_sql_varchar">,
				       pc_faq_perfis = <cfqueryparam value="#arguments.pc_faq_perfis#" cfsqltype="cf_sql_varchar">,
					   pc_faq_status = <cfqueryparam value="#arguments.pc_faq_status#" cfsqltype="cf_sql_varchar">,
					   pc_faq_texto  = <cfqueryparam value="#arguments.pc_faq_texto#" cfsqltype="cf_sql_varchar">,
				       pc_faq_atualiz_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					   pc_faq_matricula_atualiz =  <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">
				WHERE  pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">

			</cfquery>
		</cfif>
    </cffunction>



	<cffunction name="formFaq"   access="remote" hint="exibe os FAQs na página pc_faq.cfm.">
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
			</style>
			<div class="col-12" id="accordion">
				<cfloop query = "rsFaqs"  >
					<cfoutput>
						<div class="card <cfif #pc_faq_status# eq 'D'>card-danger<cfelse>card-primary</cfif> card-outline">
							
							<a class="d-block w-100 " data-toggle="collapse" href="##collapse#pc_faq_id#">
								<div class="card-header" style="<cfif #pc_faq_status# eq 'D'>background-color: ##e5e5eb;color:red</cfif>">
									<cfset dataFaq = DateFormat(#pc_faq_atualiz_datahora#,'DD-MM-YYYY') & '-' & TimeFormat(#pc_faq_atualiz_datahora#,'HH') & 'h' & TimeFormat(#pc_faq_atualiz_datahora#,'MM') & 'min' >
									<h4 class="card-title 1-300" style="margin-bottom:5px">
										<cfif #pc_faq_status# eq 'D'><span class="badge badge-warning navbar-badge" style="float: left;right: initial;top: 1px;">Desativado</span></cfif>
										#pc_faq_titulo#
									</h4>

									<div  class="card-tools">
										<cfif (#application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11) and '#arguments.cadastro#' eq 'S'>
										    <cfset titulo_codificado = urlEncodedFormat(pc_faq_titulo)>
											<button type="button"  id="btEditar" class="btn btn-tool  " style="font-size:20px" onclick="javascript:mostraFormEditFaq(<cfoutput>#pc_faq_id#,'#titulo_codificado#'</cfoutput>);"  ><i class="fas fa-edit"></i></button>
											<button type="button"  id="btExcluir" class="btn btn-tool  " style="font-size:20px" onclick="javascript:excluirFaq(<cfoutput>#pc_faq_id#</cfoutput>);"  ><i class="fas fa-trash-alt"></i></button>
										</cfif>
										<button  type="button" class="btn btn-tool" data-card-widget="maximize" style="font-size:34px;"><i class="exp fas fa-expand"></i></button>
									</div>	
								</div>
							</a>
							<div id="collapse#pc_faq_id#" class="collapse" data-parent="##accordion">
								<div class="card-body">
									
									<div>#pc_faq_texto#</div>
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
							<table id="tabFaq" class="table table-bordered  table-hover table-striped">
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:12px!important">
										<th align="center">Controles</th>
										<th >ID</th>
										<th >Título</th>
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsFaqs" > 
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
					"destroy": true,
			    	"stateSave": true,
					"responsive": true, 
					"lengthChange": true, 
					"autoWidth": false,
					"select": true,
					"buttons": [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						className: 'btExcel',
					}],
				}).buttons().container().appendTo('#tabFaq_wrapper .col-md-6:eq(0)');
					
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

		<cfquery datasource="#application.dsn_processos#" >
			DELETE FROM pc_faqs
			WHERE pc_faq_id = <cfqueryparam value="#arguments.pc_faq_id#" cfsqltype="cf_sql_numeric">
		</cfquery> 
	
		<cfreturn true />
	</cffunction>







	<cffunction name="uploadArquivosFaqs" access="remote"  returntype="boolean" output="false" hint="AINDA NÃO FINALIZADO - realiza o upload dos FAQs em pdf">

		
		<cfset thisDir = expandPath(".")>

		
		<cffile action="upload" filefield="file" destination="#application.diretorio_faqs#" nameconflict="skip" accept="application/pdf">
		


		<cfscript>
			thread = CreateObject("java","java.lang.Thread");
			thread.sleep(1000); // dalay para evitar arquivos com nome duplicado
		</cfscript>
		
		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'ss.SSSSS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		
		
		<cfset destino = cffile.serverdirectory & '\Anexo_faq_id_' & '_'  & '#application.rsUsuarioParametros.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>
		


	    <cfobject component = "pc_cfcAvaliacoes" name = "tamanhoArquivo">
		<cfinvoke component="#tamanhoArquivo#" method="renderFileSize" returnVariable="tamanhoDoArquivo" size ='#cffile.fileSize#' type='bytes'>


		<cfset nomeDoAnexo = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#' & ' (' & '#tamanhoDoArquivo#' & ')'>

		<cfif FileExists(origem)>
			<cffile action="rename" source="#origem#" destination="#destino#">
        </cfif>

		        
		<cfset mcuOrgao = "#application.rsUsuarioParametros.pc_org_mcu#">
		<cfif FileExists(destino)>
			<cfquery datasource="#application.dsn_processos#" >
					INSERT pc_anexos(pc_anexo_avaliacao_id, pc_anexo_login, pc_anexo_caminho, pc_anexo_nome, pc_anexo_mcu_orgao, pc_anexo_avaliacaoPDF, pc_anexo_enviado )
					VALUES (#pc_aval_id#, '#application.rsUsuarioParametros.pc_usu_login#', '#destino#', '#nomeDoAnexo#','#mcuOrgao#', '#pc_anexo_avaliacaoPDF#', 1)
			</cfquery>
		</cfif>

	
		<cfreturn true />
    </cffunction>


</cfcomponent>