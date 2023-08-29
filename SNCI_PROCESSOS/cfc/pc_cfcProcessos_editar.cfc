<cfcomponent  >
<cfprocessingdirective pageencoding = "utf-8">	

	<!--- Diretório onde serão armazenados arquivos anexados a avaliações --->
	<cfset auxsite =  cgi.server_name>
	<cfif auxsite eq "intranetsistemaspe">
		<cfset diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_ANEXOS\'>
		<cfset diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_AVALIACOES\'>
		<cfset diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_PROCESSOS_FAQS\'>
	<cfelse>
		<cfset diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
		<cfset diretorio_avaliacoes = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
		<cfset diretorio_faqs = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
	</cfif>

	<cfset dsn_processos = 'DBSNCI'>

	<!-- iCheck -->
	<link rel="stylesheet" href="plugins/icheck-bootstrap/icheck-bootstrap.min.css">


	<cfquery name="rsUsuario" datasource="#dsn_processos#">
		SELECT pc_usuarios.*, pc_orgaos.*, pc_perfil_tipos.* FROM pc_usuarios 
		INNER JOIN pc_orgaos ON pc_org_mcu = pc_usu_lotacao
		INNER JOIN pc_perfil_tipos on pc_perfil_tipo_id = pc_usu_perfil
		WHERE pc_usu_login = '#cgi.REMOTE_USER#'
	</cfquery>


	





	
	<cffunction name="cadProc"   access="remote" returntype="any">

	    <cfargument name="pcProcessoId" type="string" required="false" default=''/>
		<cfargument name="pcNumSEI" type="string" required="true" />
		<cfargument name="pcNumRelatorio" type="string" required="true" />
		<cfargument name="pcOrigem" type="string" required="true" />
		<cfargument name="pcDataInicioAvaliacao" type="date" required="true" />
		<cfargument name="pcDataFimAvaliacao" type="any" required="false" />
		<cfargument name="pcTipoAvaliado" type="string" required="true" />
		<cfargument name="pcTipoAvalDescricao" type="string" required="false" default=''/>
		<cfargument name="pcModalidade" type="string" required="true" />
		<cfargument name="pcTipoClassif" type="string" required="true" />
		<cfargument name="pcOrgaoAvaliado" type="string" required="true" />
		<cfargument name="pcAvaliadores" type="any" required="true" />
		<cfargument name="pcCoordenador" type="string" required="false" default=''/>
		<cfargument name="pcCoordNacional" type="string" required="true"/>
        <cfargument name="pcTipoDemanda" type="string" required="true"/>
		<cfargument name="pcAnoPacin" type="string" required="true"/>
		
		<cfset ano = year(#arguments.pcDataInicioAvaliacao#)>
		<cfset login = '#cgi.REMOTE_USER#'>

		<cfquery name="rsSEorgAvaliado" datasource="#dsn_processos#">
		  SELECT pc_org_se from pc_orgaos where pc_org_mcu = #arguments.pcOrgaoAvaliado#
        </cfquery>

		<cfquery name="rsSeq" datasource="#dsn_processos#">
			SELECT Max(pc_processo_id) AS Max
			FROM pc_processos 
			WHERE pc_processo_id like '%#ano#' AND pc_processo_id like '#rsSEorgAvaliado.pc_org_se#%'
		</cfquery>

		

        <cfif rsSeq.Max eq "">
            <cfset NumID = 1>
        <cfelse>
            <cfset NumID = val(mid(rsSeq.Max,3,4) + 1)>			
        </cfif>	

        <cfswitch expression="#len(NumID)#">
            <cfcase value="1">
                <cfset NumID = '000' & NumID>
            </cfcase>
            <cfcase value="2">
                <cfset NumID = '00' & NumID>
            </cfcase>
            <cfcase value="3">
                <cfset NumID = '0' & NumID>
            </cfcase>
        </cfswitch>

        <cfset NumID = '#rsSEorgAvaliado.pc_org_se#' & NumID & ano>
        <cfset aux_sei = Trim('#arguments.pcNumSEI#')>
        <cfset aux_sei = Replace(aux_sei,'.','',"All")>
        <cfset aux_sei = Replace(aux_sei,'/','','All')>
        <cfset aux_sei = Replace(aux_sei,'-','','All')>
       

		
		<!--Se o ano da data de início da avaliação, um novo processo é cadastrado e o processo antigo é excluído-->
		<cfquery datasource="#dsn_processos#" name="qProcessoEditar">
			SELECT pc_data_inicioAvaliacao, pc_usu_matricula_cadastro, pc_num_status, pc_org_se,pc_num_orgao_avaliado  FROM pc_processos 
			INNER JOIN pc_orgaos ON pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
			WHERE pc_processo_id = '#arguments.pcProcessoId#'
		</cfquery>
		<cfset anoAntes = year(#qProcessoEditar.pc_data_inicioAvaliacao#)>
		

		<cfif anoAntes neq ano >
			<cfquery datasource="#dsn_processos#">
				INSERT pc_processos (pc_processo_id, pc_usu_matricula_cadastro, pc_datahora_cadastro, pc_num_sei, pc_num_orgao_origem, pc_num_rel_sei, pc_num_orgao_avaliado, pc_num_avaliacao_tipo, pc_aval_tipo_nao_aplica_descricao,pc_num_classificacao, pc_data_inicioAvaliacao, pc_data_fimAvaliacao, pc_num_status, pc_alteracao_datahora, pc_alteracao_login, pc_usu_matricula_coordenador,pc_usu_matricula_coordenador_nacional, pc_Modalidade,pc_tipo_demanda, pc_ano_pacin)
				VALUES ('#NumID#', '#qProcessoEditar.pc_usu_matricula_cadastro#', CONVERT(char, GETDATE(), 120), '#aux_sei#', '#arguments.pcOrigem#', '#arguments.pcNumRelatorio#', '#arguments.pcOrgaoAvaliado#', '#arguments.pcTipoAvaliado#','#arguments.pcTipoAvalDescricao#','#arguments.pcTipoClassif#', '#arguments.pcDataInicioAvaliacao#', '#arguments.pcDataFimAvaliacao#', '#qProcessoEditar.pc_num_status#', CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#', '#arguments.pcCoordenador#',  '#arguments.pcCoordNacional#', '#arguments.pcModalidade#', '#arguments.pcTipoDemanda#', '#arguments.pcAnoPacin#')
			</cfquery> 	
	
            <cftransaction>
				<!--Cadastra avaliadores -->
				<cfloop list="#arguments.pcAvaliadores#" index="i">  
					<cfset matriculaAvaliador = '#i#'>
					<cfquery datasource="#dsn_processos#">
						INSERT pc_avaliadores (pc_avaliador_matricula,  pc_avaliador_id_processo)
						VALUES ('#matriculaAvaliador#',  '#NumID#')
					</cfquery>
				</cfloop>
				<!--Fim Cadastra avaliadores -->

				<!--Edita todos os registros nas outras tabelas com o novo ID do processo-->
				<cfquery datasource="#dsn_processos#" name="EditaTabelas">
					UPDATE pc_avaliacoes
					SET pc_avaliacoes.pc_aval_processo = '#NumID#'
					WHERE pc_avaliacoes.pc_aval_processo = '#arguments.pcProcessoId#'

					UPDATE pc_anexos
					SET pc_anexos.pc_anexo_processo_id = '#NumID#'
					WHERE pc_anexos.pc_anexo_processo_id = '#arguments.pcProcessoId#'
				</cfquery>
				<!--Fim Edita todos os registros nas outras tabelas com o novo ID do processo-->

				
				<!--Exclui avaliadores antigos-->
				<cfquery datasource="#dsn_processos#" name="DeletaAvaliadores">
					DELETE FROM pc_avaliadores
					WHERE pc_avaliadores.pc_avaliador_id_processo = '#arguments.pcProcessoId#'
				</cfquery> 
				<!--Fim Exclui avaliadores antigos-->

				<!--Exclui processo antigo-->
				<cfquery datasource="#dsn_processos#" name="DeletaProcessos">
					DELETE FROM pc_processos
					WHERE pc_processos.pc_processo_id = '#arguments.pcProcessoId#'
				</cfquery>
				<!--Fim Exclui avaliadores e processo antigos-->
			</cftransaction>	
		<!--Se nem o ano de início da avaliação for alterado, editar o processo normalmente-->
		<cfelse>
			<cftransaction>
				<cfquery datasource="#dsn_processos#" >
					UPDATE pc_processos
					SET 
						pc_num_orgao_origem = '#arguments.pcOrigem#',
						pc_num_rel_sei = '#arguments.pcNumRelatorio#',
						pc_num_avaliacao_tipo = '#arguments.pcTipoAvaliado#',
						pc_aval_tipo_nao_aplica_descricao = '#arguments.pcTipoAvalDescricao#',
						pc_Modalidade = '#arguments.pcModalidade#',
						pc_num_classificacao = '#arguments.pcTipoClassif#',
						pc_data_inicioAvaliacao = '#arguments.pcDataInicioAvaliacao#',
						pc_data_fimAvaliacao = '#arguments.pcDataFimAvaliacao#',
						pc_alteracao_datahora = CONVERT(char, GETDATE(), 120),
						pc_alteracao_login = '#cgi.REMOTE_USER#',
						pc_usu_matricula_coordenador =  '#arguments.pcCoordenador#',
						pc_usu_matricula_coordenador_nacional =  '#arguments.pcCoordNacional#',
						pc_tipo_demanda = '#arguments.pcTipoDemanda#',
						pc_ano_pacin = '#arguments.pcAnoPacin#'
					WHERE pc_processo_id = '#arguments.pcProcessoId#'
				</cfquery> 	

				<cfquery datasource="#dsn_processos#" >
					DELETE FROM pc_avaliadores
					WHERE pc_avaliador_id_processo= '#arguments.pcProcessoId#'
				</cfquery> 	


				<cfloop list="#arguments.pcAvaliadores#" index="i">  
					<cfset matriculaAvaliador = '#i#'>
					<cfif '#matriculaAvaliador#' eq  "#arguments.pcCoordenador#">
						<cfset coordena ='S'>
					<cfelse>
						<cfset coordena ='N'>
					</cfif>

					<cfquery datasource="#dsn_processos#">
						INSERT pc_avaliadores (pc_avaliador_matricula, pc_avaliador_id_processo)
						VALUES ('#matriculaAvaliador#', '#arguments.pcProcessoId#')
					</cfquery>
				</cfloop>

			</cftransaction>
		</cfif>

      


		<cfreturn true />
	</cffunction>





	
	<cffunction name="cardsProcessos" returntype="any" access="remote" hint="Criar os cards dos processos e envia para a páginas pc_CadastroProcesso">
	   
		<cfargument name="ano" type="string" required="true" />

		<cfquery name="rsProcCard" datasource="#dsn_processos#">
			SELECT DISTINCT pc_processos.*,pc_orgaos.pc_org_descricao,pc_orgaos.pc_org_sigla, pc_status.*,pc_avaliacao_tipos.pc_aval_tipo_descricao
			FROM   pc_processos 
			INNER JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
			INNER JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado =pc_orgaos.pc_org_mcu
			INNER JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id
			<cfif rsUsuario.pc_usu_perfil eq 11 OR rsUsuario.pc_usu_perfil eq 3>
				WHERE not pc_status_id IN ('2') 
			</cfif>
			<cfif rsUsuario.pc_usu_perfil eq 8>
                WHERE not pc_status_id IN ('2','5') and pc_num_orgao_origem = '#rsUsuario.pc_usu_lotacao#'	
			</cfif>
			<cfif '#arguments.ano#' neq 'TODOS'>
				AND right(pc_processo_id,4) = '#arguments.ano#'
			</cfif>	
			ORDER BY pc_datahora_cadastro desc 	
		</cfquery>

		<style>
			#tabProcCards_wrapper #tabProcCards_paginate ul.pagination {
				justify-content: center!important;
			}			
		</style>

		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" style="padding:0px!important">
				<!-- /.card-header -->
				<div class="card-body" style="padding:0px!important">
					<form id="formAcomp" name="formAcomp" format="html"  style="height: auto;">
					
						<!--acordion-->
						<div id="accordionCadItemPainel" >
							<div class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i>Processos Em Acompanhamento ou Finalizados
										</a>
									</h4>
								</div>
								<div id="collapseTwo" class="" data-parent="#accordion">							
									<div class="card-body" style="border: solid 3px #ffD400;width:100%">
										
										<div class="row" style="justify-content: space-around;">
											<cfif #rsProcCard.recordcount# eq 0 >
												<h5>Selecione o ano desejado ou clique em "TODOS" para visualizar todos os processos com status "ACOMPANHAMENTO" ou "FINALIZADO".</h5>
											</cfif>
											<cfif #rsProcCard.recordcount# neq 0 >
												<div class="col-sm-12">
													
														<table id="tabProcCards" class="table  " style="background: none;border:none;width:100%">
															<thead >
																<tr style="background: none;border:none">
																	<th style="background: none;border:none"></th>
																</tr>
															</thead>
															
															<tbody class="grid-container" >
																<cfloop query="rsProcCard" >
																	<cfquery name="rsAvaliadores" datasource="#dsn_processos#">
																		SELECT pc_avaliadores.pc_avaliador_matricula FROM pc_avaliadores WHERE pc_avaliador_id_processo = '#pc_processo_id#' 
																	</cfquery>
																	<cfset avaliadores = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>
																	<tr style="width:270px;border:none;">
																		<td style="background: none;border:none;white-space:normal!important;" >	
																			<section class="content" >
																					<div id="processosAcompanhamento" class="container-fluid" >

																							<div class="row">
																								<div id="cartao" style="width:270px;" >
																								
																									<!-- small card -->
																									<div class="small-box " style="<cfoutput>#pc_status_card_style_header#</cfoutput> font-weight: normal;color:#fff">
																										<cfif #pc_modalidade# eq "A">
																											<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:10px;"><strong>A</strong></span>
																										<cfelseif #pc_modalidade# eq "E">
																											<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:5px;"><strong>E</strong></span>	
																										</cfif>
																										<div class="ribbon-wrapper ribbon-lg" >
																											<div class="ribbon " style="font-size:12px;left:8px;<cfoutput>#pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#pc_status_card_nome_ribbon#</cfoutput></div>
																										</div>
																										

																										<div class="card-header" style="height:120px;width:250px;    font-weight: normal!important;">
																											<p style="font-size:1em;margin-bottom: 0.3rem!important;"><cfoutput>Processo n°: #pc_processo_id#</cfoutput></p>
																											<p style="font-size:1em;margin-bottom: 0.3rem!important;"><cfoutput>#pc_org_sigla#</cfoutput></p>
																											<cfif pc_num_avaliacao_tipo neq 2>
																												<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_descricao#</cfoutput></p>
																											<cfelse>
																												<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_nao_aplica_descricao#</cfoutput></p>
																											</cfif>
																											
																										</div>
																										<div class="icon">
																											<i class="fas fa-search" style="opacity:0.6;left:100px;top:30px"></i>
																										</div>

																										<a href="##"  target="_self" class="small-box-footer"   >
																											<div style="display:flex;justify-content: space-around;" >
																												<input id="pcNumProcessoCard" name="pcNumProcessoCard" type="text" hidden >												
																												<i id="btEdit" class="fas fa-edit efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'"  style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoEditarCard(<cfoutput>'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#')</cfoutput>;" data-toggle="tooltip"  tilte="Editar"></i>
																												<cfif pc_num_status neq 3>
																													<i  class="fas fa-boxes-packing efeito-grow" onclick="javascript:mostraCadastroRelato(<cfoutput>'#pc_processo_id#'</cfoutput>);"  style="cursor: pointer;z-index:100;font-size:20px"    title="Mostrar próximos passos." ></i>
																												</cfif>
																											</div>
																										</a>
																											
																									</div>
																								</div>
																							</div>
																						
																					</div>
																			</section>
																		</td>
																	</tr>
																</cfloop>
															</tbody>
														</table>
													
													

												</div>
											</cfif>
										</div>
									</div>									
								</div> <!--fim collapseTwo -->
							</div><!--fim card card-success -->	
						</div><!--fim acordion -->
					</form><!-- fim formAcomp -->					
				</div><!-- fim card-body -->	

				<div id="tabAvaliacoesAcompanhamento"></div>
			</div>
		</section>


		
		



		<script language="JavaScript">
			

			$(function () {
				$("#tabProcCards").DataTable({
					"destroy": true,
					"ordering": false,
				    "stateSave": true,
					"responsive": true, 
					"lengthChange": true, 
					"autoWidth":true,
					"sScrollY": "50vh",
					"scrollCollapse": true,
					"dom": 
							"<'row'<'col-sm-12 text-right'f>>" +
							"<'row'<'col-sm-4'l><'col-sm-4'p><'col-sm-4 text-right'i>>" +
							"<'row'<'col-sm-12'tr>>" ,
					"lengthMenu": [
						[10, 25, 50, -1],
						[10, 25, 50, 'All'],
					]
				})
					
			});

			function mostraCadastroRelato(numProcesso) {

				$('#modalOverlay').modal('show')
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcProcessos_editar.cfc",
							data:{
								method:"cadProcAvaliacaoForm",
								pc_aval_processoForm: numProcesso
							},
							async: false,
							success: function(response) {
								
								$('#cadAvaliacaoForm').html(response);
								$('html, body').animate({ scrollTop: ($('#cadAvaliacaoForm').offset().top - 80)} , 1000);
								
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
		</script>
	</cffunction>




	<cffunction name="cadProcAvaliacaoForm"   access="remote"  returntype="any" hint="Insere o formulario de cadastro do título da avaliação na páginas pc_CadastroAvaliacaoPainel">


        <cfargument name="pc_aval_processoForm" type="string" required="true"/>
        
       

		<cfquery name="rsProcForm" datasource="#dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado, pc_orgaos.pc_org_mcu,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao

			FROM        pc_processos INNER JOIN
						pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
						pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
						pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
						pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
						pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
			WHERE  pc_processo_id = '#arguments.pc_aval_processoForm#'														
		</cfquery>
	

		<cfquery name="rs_OrgAvaliado" datasource="#dsn_processos#">
			SELECT pc_orgaos.*
			FROM pc_orgaos
			WHERE  (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#rsProcForm.pc_num_orgao_avaliado#' or pc_org_mcu ='#rsProcForm.pc_num_orgao_avaliado#')
			ORDER BY pc_org_sigla
		</cfquery>


		<form id="formCadItem"  class="needs-validation was-validated" name="formCadItem" format="html"  style="height: auto;padding-left:25px;padding-right:25px;">
            <div class="modal fade" id="modal-danger">
				<div class="modal-dialog">
					<div class="modal-content bg-danger">
					<div class="modal-header">
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
		<!--- 				<button type="button" class="btn btn-outline-light">Save changes</button> --->
					</div>
					</div>
					<!-- /.modal-content -->
				</div>
				<!-- /.modal-dialog -->
			</div>
			<!-- /.modal -->
			<cfset aux_sei = Trim('#rsProcForm.pc_num_sei#')>
			<cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
		
			<section class="content" id="infoProcesso">
					<div id="processosCadastrados" class="container-fluid" >
						<div class="row">
							<div id="cartao" style="width:100%;" >
								<!-- small card -->
								<cfoutput>
									<div class="small-box " style=" font-weight: bold;">
										<div class="ribbon-wrapper ribbon-lg" >
											<div class="ribbon " style="font-size:12px;left:8px;<cfoutput>#rsProcForm.pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#rsProcForm.pc_status_card_nome_ribbon#</cfoutput></div>
										</div>
										<div class="card-header" style="height:auto">
											<p style="font-size: 1.8em;">Processo SNCI n°: <strong style="color:##0692c6;margin-right:30px">#rsProcForm.pc_processo_id#</strong> Órgão Avaliado: <strong style="color:##0692c6">#rsProcForm.siglaOrgAvaliado#</strong></p>
											<p style="font-size: 1.3em;">Origem: <strong style="color:##0692c6;margin-right:30px">#rsProcForm.siglaOrgOrigem#</strong>
											<cfif #rsProcForm.pc_modalidade# eq 'A' OR #rsProcForm.pc_modalidade# eq 'E'>
												<span >Processo SEI n°: </span> <strong style="color:##0692c6">#aux_sei#</strong> 
												<span style="margin-left:20px">Relatório n°:</span> 
												<strong style="color:##0692c6">#rsProcForm.pc_num_rel_sei#</strong></p>
											</cfif>	
											<cfif rsProcForm.pc_num_avaliacao_tipo neq 2>
												<p style="font-size: 1.3em;">Tipo de Avaliação: <strong style="color:##0692c6">#rsProcForm.pc_aval_tipo_descricao#</strong></p>
											<cfelse>
												<p style="font-size: 1.3em;">Tipo de Avaliação: <strong style="color:##0692c6">#rsProcForm.pc_aval_tipo_nao_aplica_descricao#</strong></p>
											</cfif>
											
											
										
											<cfif #rsProcForm.pc_modalidade# eq 'A' OR #rsProcForm.pc_modalidade# eq 'E'>
											
												<div id="actions" class="row" >
													<div class="col-lg-12" align="center">
														<div class="btn-group w-30">
															<span id="relatorios" class="btn btn-success col fileinput-button" style="background:##0083CA">
																<i class="fas fa-upload"></i>
																<span style="margin-left:5px">Clique aqui para anexar o Relatório do Processo e Anexos I, II e III em PDF</span>
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
								</cfoutput>



							</div>
						</div>

						
					</div>

					
			

					
				
			</section>


 			
		  

			<div hidden id="accordionTitulo"  class="row" style="margin-left:0px!important">
				<div  id="cadastroItem" class="card card-primary collapsed-card"  >
					<div class="card-header" style="background-color: #0083ca;color:#fff;">
						<a class="d-block" data-toggle="collapse" href="#collapseOne" style="font-size:16px;" data-card-widget="collapse">
							<button type="button" class="btn btn-tool" data-card-widget="collapse"><i id="maisMenos" class="fas fa-plus"></i>
							</button></i><span id="cabecalhoAccordion">Clique aqui para cadastrar um item (1° Passo)</span>
						</a>
					</div>
					<div class="card-body" >
						
						<div class="tab-content" id="custom-tabs-one-tabContent" style="width: 100%!important">
							<input id="pc_aval_id" hidden>

							<div class="tab-pane fade active show" id="custom-tabs-one-1passo" role="tabpanel" aria-labelledby="custom-tabs-one-1passo-tab">
								<div class="row" style="font-size:16px">
									<div class="col-sm-2">
										<div class="form-group">
											<label for="pcNumSituacaoEncontrada" >N°:</label>
											<input id="pcNumSituacaoEncontrada"  required="" name="pcNumSituacaoEncontrada" type="text" class="form-control "  inputmode="text" >													
										</div>
									</div>
									<div class="col-sm-10">
										<div class="form-group">
											<label for="pcTituloSituacaoEncontrada" >Título da Situação Encontrada:</label>
											<input id="pcTituloSituacaoEncontrada"  required=""  name="pcTituloSituacaoEncontrada" type="text" class="form-control "  inputmode="text" placeholder="Informe o título da situação encontrada">
										</div>
									</div>
									<div class="col-sm-5">
										<div class="form-group">
											<label for="pcTipoClassif" >Classificação:</label>
											<select id="pcTipoClassif" required=""  name="pcTipoClassif" class="form-control" >
												<option selected="" disabled="" value="">Selecione a Classificação...</option>
												<option value="L">Leve</option>
												<option value="M">Mediana</option>		
												<option value="G">Grave</option>															
											</select>
										</div>
									</div>
									<div class="col-sm-5">
										<div  class="form-group">
											<label for="pcValorApuradoTipo" >Tipo do Valor Envolvido:</label>
											<select id="pcValorApuradoTipo" required=""  name="pcValorApuradoTipo" class="form-control">
												<option selected="" disabled="" value="">Selecione o tipo do Valor Envolvido...</option>
												<option value="q">Quantificado</option>
												<option value="n">Não Quantificado</option>												
											</select>	
										</div>
									</div>
									<div class="col-sm-12" id="divValores" hidden style="display:flex;gap:15px">
										<div >
											<div class="form-group" >
												<label for="pcvaFalta" >Falta:</label>
												<input id="pcvaFalta"   required="" name="pcvaFalta" type="text" class="form-control money"  inputmode="text"  >
											</div>
										</div>
										<div >
											<div class="form-group" >
												<label for="pcvaRisco" >Risco:</label>
												<input id="pcvaRisco"   required="" name="pcvaRisco" type="text" class="form-control money"  inputmode="text"  >
											</div>
										</div>
										<div >
											<div class="form-group" >
												<label for="pcvaSobra" >Sobra:</label>
												<input id="pcvaSobra"   required="" name="pcvaSobra" type="text" class="form-control money"  inputmode="text"  >
											</div>
										</div>
									</div>
								</div>	
								
								<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
									<div >
										<button id="btSalvarEdicao" class="btn btn-block btn-primary " >Salvar</button>
									</div>
									<div style="margin-left:100px">
										<button id="btCancelarEdicao"  class="btn btn-block btn-danger " >Cancelar</button>
									</div>
								</div>			
							</div>
							
							
									
						

						</div>

						

					
					</div>
				</div>
			</div>			
			
            

		</form><!-- fim formCadAvaliacao -->
		
		
		<div id="TabAvaliacao" style="margin-bottom:50px"></div>

		<div id="CadastroAvaliacaoRelato" style="padding-left:25px;padding-right:25px"></div>

		<script language="JavaScript">
			

		
			$(function () {
				$('[data-mask]').inputmask()
			})

			// prepara o input com a mascara 'R$'
			$(document).ready(function(){
				$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
				$(".money").inputmask( 'currency',{"autoUnmask": true,
						radixPoint:",",
						groupSeparator: ".",
						allowMinus: false,
						prefix: 'R$ ',            
						digits: 2,
						digitsOptional: false,
						rightAlign: true,
						unmaskAsNumber: true
				});

				mostraRelatorioPDF()

				  
				<cfoutput>
					let modalidade = '#rsProcForm.pc_modalidade#'
					let pc_processo_id = '#rsProcForm.pc_processo_id#'
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
						url: "cfc/pc_cfcProcessos_editar.cfc?method=uploadArquivos", // Set the url
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

					

					// // Update the total progress bar
					// myDropzoneRelatorio.on("totaluploadprogress", function(progress) {
					// 	document.querySelector(".progress-bar").style.width = progress + "%"
					// })

					// myDropzoneRelatorio.on("sending", function(file) {
					// 	$('#modalOverlay').modal('show')
					// })



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

				exibirTabAvaliacoes();
			});

			function mostraRelatorioPDF(){
				<cfoutput>
					let pc_processo_id = '#rsProcForm.pc_processo_id#'
				</cfoutput>
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url:"cfc/pc_cfcProcessos_editar.cfc",
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
				}, 500);
			}


			//Verifica se o tipo de valor apurado é diferente de  não quantificado. Caso afirmativo, mostra o campo valor.
			$('#pcValorApuradoTipo').on('change', function (event)  {
				$('#pcvaFalta').val('')
				$('#pcvaRisco').val('')
				$('#pcvaSobra').val('')
				if($('#pcValorApuradoTipo').val() !== 'n'){
					$("#divValores").attr("hidden",false)	
				}else{
					
					if (!$("#divValores").attr("hidden")) {
						$("#divValores").attr("hidden", true)
					} 
				}
				
			});

			$('#pcTipoClassif').on('change', function (event)  {
				if($('#pcTipoClassif').val() == 'L' ){
					alert("Atenção! Ao mudar a classificação deste item para leve, caso existam orientações e/ou propostas de melhoria cadastradas, elas serão excluídas após a alteração ser salva.")
				}
			});



			$('#btCancelarEdicao').on('click', function (event)  {
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()
				$('#pcNumSituacaoEncontrada').val('') 
				$('#pcTituloSituacaoEncontrada').val('') 
				$('#pcTipoClassif').val('')
				$('#pcValorApuradoTipo').val('')
				$('#pcvaFalta').val('')
				$('#pcvaRisco').val('')
				$('#pcvaSobra').val('')
				$('#cadastroItem').CardWidget('collapse')
				$("#accordionTitulo").attr("hidden", true)
				$('#cabecalhoAccordion').text("Clique aqui para cadastrar um item (1° Passo)");	
						
			});
			

			$('#btSalvarEdicao').on('click', function (event)  {
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()
				//retira o ponto do número da manchete (situação encontrada)
				//var numSituacaoEncontrada=$("#pcNumSituacaoEncontrada").val().replace(/([^\d])+/gim, '');
				//verifica se os campos necessários foram preenchidos
				if (
					!$("#pcNumSituacaoEncontrada").val() ||
					!$('#pcTituloSituacaoEncontrada').val() ||
					$('#pcTipoClassif').val().length == 0 ||
					$('#pcValorApuradoTipo').val().length == 0			
				)
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}

				//verifica se os campos necessários foram preenchidos
				if ($('#pcValorApuradoTipo').val() == 'q' & !$('#pcvaFalta').val() & !$('#pcvaRisco').val() & !$('#pcvaSobra').val())
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					var mens ='Você definiu o tipo de valor como Quantificado.\nPelo menos, um valor referente a A Sobra, Risco ou Falta deve ser preenchido.'
					toastr.error(mens);
					return false;
				}

				var mensagem = ""
				if($('#pc_aval_id').val() == ''){
					mensagem = "Deseja cadastrar este item?"
				}else{
					mensagem = "Deseja editar este item?"
				}
				
				var pc_processo_id = <cfoutput>#rsProcForm.pc_processo_id#</cfoutput>
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!',
					}).then((result) => {
					if (result.isConfirmed) {
						$('#modalOverlay').modal('show');
						//inicio ajax
						setTimeout(function() {	
							$.ajax({
								type: "post",
								url: "cfc/pc_cfcProcessos_editar.cfc",
								data:{
									method:"cadProcAvaliacaoTitulo",
									pc_aval_id: $('#pc_aval_id').val(),
									pc_aval_processo:pc_processo_id,
									pc_aval_numeracao:$('#pcNumSituacaoEncontrada').val(),
									pc_aval_descricao:$('#pcTituloSituacaoEncontrada').val(),
									pc_aval_classificacao:$('#pcTipoClassif').val(),
									pc_aval_vaFalta:$('#pcvaFalta').val(),
									pc_aval_vaRisco:$('#pcvaRisco').val(),
									pc_aval_vaSobra:$('#pcvaSobra').val()
								},
					
								async: false,
								success: function(result) {	
									$('#pcNumSituacaoEncontrada').val('') 
									$('#pcTituloSituacaoEncontrada').val('') 
									$('#pcTipoClassif').val('')
									$('#pcValorApuradoTipo').val('')
									$('#pcvaFalta').val('')
									$('#pcvaRisco').val('')
									$('#pcvaSobra').val('')	
									$('#pc_aval_id').val('')
									$("#accordionTitulo").attr("hidden", true)
									//mostraCadastroRelato(<cfoutput>'#arguments.pc_aval_processoForm#'</cfoutput>)
									exibirTabAvaliacoes()
									$('#CadastroAvaliacaoRelato').html("")
									//mostraCads()
									$('#cabecalhoAccordion').text("Clique aqui para cadastrar um item (1° Passo)");	
									$('#cadastroItem').CardWidget('collapse')
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});
									
										
								},
								error: function(xhr, ajaxOptions, thrownError) {									
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
													+ '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
										const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
										
										swalWithBootstrapButtons.fire(
												{...erroSistema}
										)
									});
								}
							})	
						}, 500);
					} 
				})
					
				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
					
				});
			});

			function exibirTabAvaliacoes(){
		
				<cfoutput>
					let numProcesso = '#rsProcForm.pc_processo_id#'
				</cfoutput>
				$('#modalOverlay').modal('show');
				setTimeout(function() {	
					
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "tabAvaliacoes",
							numProcesso: numProcesso
						},
						async: false,
						success: function(result) {
							$('#TabAvaliacao').html(result)
							
						},
						error: function(xhr, ajaxOptions, thrownError) {
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)
							
						}
					})	
				
				}, 500);
					

			}

		
		
		</script>

	</cffunction>



	<cffunction name="anexoRelatorio"   access="remote" hint="retorna os anexos que contem informação do processo no campo pc_anexo_processo_id indicando que é um anexo para todos os itens">
		<cfargument name="pc_anexo_processo_id" type="string" required="true"/>

		<cfquery datasource="#dsn_processos#" name="rsPc_anexos" > 
			SELECT pc_anexos.*   FROM  pc_anexos
			WHERE pc_anexo_processo_id = '#arguments.pc_anexo_processo_id#'
		</cfquery>

		<cfloop query="rsPc_anexos" >
		    <cfif FileExists(pc_anexo_caminho)>
				<cfset caminho = "#pc_anexo_caminho#">
			<cfelse>
				<cfset caminho = "Caminho  não encontrado">
			</cfif>
			
				<div class="card-body" style="padding:0px;">
					<div  id ="cardRelatorioPDF" class="card card-primary card-tabs collapsed-card" style="transition: all 0.15s ease 0s; height: inherit; width: inherit;">
						<div class="card-header" style="background-color:#00416b;">
						
							<h3 class="card-title" style="font-size:16px;position:relative;top:3px"><i class="fas fa-file-pdf" style="margin-right:10px;"></i><cfoutput> #pc_anexo_nome#</cfoutput></h3>
						    <div  class="card-tools">
								<button type="button"  id="btExcluir" class="btn btn-tool  " style="font-size:16px" onclick="javascript:excluirAnexoRelatorio(<cfoutput>#pc_anexo_id#</cfoutput>);"  ><i class="fas fa-trash-alt"></i></button>
								<button  type="button" class="btn btn-tool" data-card-widget="collapse" style="font-size:16px;margin-left:50px"><i  class="fas fa-plus"></i></button>
								<button  type="button" class="btn btn-tool" data-card-widget="maximize" style="font-size:16px;margin-left:50px"><i  class="exp fas fa-expand"></i></button>
							</div>
						</div>
						
						<div class="card-body" style="height: 100%;background-color:#00416B;padding-top: 0px;">											
							<embed id="relatoPDFdiv" type="application/pdf" src="pc_Anexos.cfm?arquivo=<cfoutput>#caminho#</cfoutput>" style="width: 100%;height:90vh;" >
						</div>			
					</div>
				</div>
			
		</cfloop>

		<script language="JavaScript">
    
			

			

			function excluirAnexoRelatorio(pc_anexo_id)  {
				
				
				let mensagem = "Deseja excluir este anexo?";
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
									type: "post",
									url: "cfc/pc_cfcProcessos_editar.cfc",
									data:{
										method: "delAnexos",
										pc_anexo_id: pc_anexo_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
						
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										mostraRelatorioPDF()
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
					    }
				    });
			};

		</script>	
		
	</cffunction>




	<cffunction name="uploadArquivos" access="remote"  returntype="boolean" output="false" hint="realiza o upload das avaliações e dos anexos">

		
		<cfset thisDir = expandPath(".")>

	

		<cfif pc_anexo_avaliacaoPDF eq 'S'>
			<cffile action="upload" filefield="file" destination="#diretorio_avaliacoes#" nameconflict="skip">
        <cfelse>
			<cffile action="upload" filefield="file" destination="#diretorio_anexos#" nameconflict="skip" >
		</cfif>


		<cfscript>
			thread = CreateObject("java","java.lang.Thread");
			thread.sleep(1000); // dalay para evitar arquivos com nome duplicado
		</cfscript>
		
		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'ss.SSSSS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		
		<cfif pc_anexo_avaliacaoPDF eq 'S'>
			<cfif arquivoParaTodosOsItens eq 'N'>
				<cfset destino = cffile.serverdirectory & '\Avaliacao_id_' & #pc_aval_id# &'PC' & '#pc_aval_processo#' & '_'  & '#rsUsuario.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>
			<cfelse>
				<cfset destino = cffile.serverdirectory & '\Relatorio_processo_'&'PC' & '#pc_aval_processo#' & '_'  & '#rsUsuario.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>
			</cfif>
		<cfelse>
			<cfset destino = cffile.serverdirectory & '\Anexo_processo_avaliacao_id_' & #pc_aval_id# &'PC' & '#pc_aval_processo#' & '_'  & '#rsUsuario.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>
		</cfif>


	    <cfobject component = "pc_cfcAvaliacoes" name = "tamanhoArquivo">
		<cfinvoke component="#tamanhoArquivo#" method="renderFileSize" returnVariable="tamanhoDoArquivo" size ='#cffile.fileSize#' type='bytes'>


		<cfset nomeDoAnexo = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#'>

		<cfif FileExists(origem)>
			<cffile action="rename" source="#origem#" destination="#destino#">
        </cfif>

		        
		<cfset mcuOrgao = "#rsUsuario.pc_org_mcu#">
		<cfif FileExists(destino)>
            <cfif arquivoParaTodosOsItens eq 'N'>
				<cfquery datasource="#dsn_processos#" >
						INSERT pc_anexos(pc_anexo_avaliacao_id, pc_anexo_login, pc_anexo_caminho, pc_anexo_nome, pc_anexo_mcu_orgao, pc_anexo_avaliacaoPDF )
						VALUES (#pc_aval_id#, '#CGI.REMOTE_USER#', '#destino#', '#nomeDoAnexo#','#mcuOrgao#', '#pc_anexo_avaliacaoPDF#')
				</cfquery>
			<cfelse>
				<cfquery datasource="#dsn_processos#" >
						INSERT pc_anexos(pc_anexo_processo_id, pc_anexo_login, pc_anexo_caminho, pc_anexo_nome, pc_anexo_mcu_orgao, pc_anexo_avaliacaoPDF )
						VALUES ('#pc_aval_processo#', '#CGI.REMOTE_USER#', '#destino#', '#nomeDoAnexo#','#mcuOrgao#', '#pc_anexo_avaliacaoPDF#')
				</cfquery>
			</cfif>
		</cfif>

	
		<cfreturn true />
    </cffunction>





	<cffunction name="delAnexos"   access="remote" returntype="boolean">
		<cfargument name="pc_anexo_id" type="numeric" required="true" default=""/>

		<cfquery datasource="#dsn_processos#" name="rsPc_anexos"> 
			SELECT pc_anexos.*   FROM  pc_anexos
			WHERE pc_anexo_id = #arguments.pc_anexo_id#
		</cfquery>

		<cfif FileExists(rsPc_anexos.pc_anexo_caminho)>
			<cffile action = "delete" File = "#rsPc_anexos.pc_anexo_caminho#">
		</cfif>

		<cfquery datasource="#dsn_processos#">
			DELETE FROM pc_anexos
			WHERE(pc_anexo_id = #arguments.pc_anexo_id#)
		</cfquery> 	


		<cfreturn true />
	</cffunction>




	<cffunction name="cadProcAvaliacaoTitulo"   access="remote"  returntype="any"> 
	
	    <cfargument name="pc_aval_id" type="string" required="false" default=''/>
		<cfargument name="pc_aval_processo" type="string" required="true"/>
		<cfargument name="pc_aval_numeracao" type="string" required="true"/><!--Numeração da Titulo. Inicialmente será manual-->
		<cfargument name="pc_aval_descricao" type="string" required="true"/><!--Manchete-->
		<cfargument name="pc_aval_classificacao" type="string" required="true"/>
		<cfargument name="pc_aval_vaFalta" type="string" required="false"/>
		<cfargument name="pc_aval_vaRisco" type="string" required="false"/>
		<cfargument name="pc_aval_vaSobra" type="string" required="false"/>
		

        <cfif '#arguments.pc_aval_id#' eq '' >
			<cftransaction>
				<cfquery datasource="#dsn_processos#" >
					INSERT INTO pc_avaliacoes
									(pc_aval_processo, pc_aval_numeracao, pc_aval_datahora, pc_aval_atualiz_datahora,pc_aval_atualiz_login,
									pc_aval_avaliador_matricula, pc_aval_descricao, pc_aval_status, pc_aval_vaFalta, pc_aval_vaRisco, pc_aval_vaSobra, pc_aval_classificacao)
					VALUES     		('#arguments.pc_aval_processo#', '#arguments.pc_aval_numeracao#', CONVERT(char, GETDATE(), 120), CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#',#rsUsuario.pc_usu_matricula#, '#arguments.pc_aval_descricao#', '1',  '#arguments.pc_aval_vaFalta#', '#arguments.pc_aval_vaRisco#','#arguments.pc_aval_vaSobra#','#arguments.pc_aval_classificacao#')
			
				</cfquery>

				<cfquery datasource="#dsn_processos#" >
					UPDATE pc_processos
					SET pc_num_status = 3
					WHERE  pc_processo_id = '#arguments.pc_aval_processo#'
				</cfquery> 	
			</cftransaction>
		<cfelse>
			<cftransaction>
				<cfquery datasource="#dsn_processos#" >
					UPDATE pc_avaliacoes
					SET pc_aval_numeracao = '#arguments.pc_aval_numeracao#',
						pc_aval_descricao =  '#arguments.pc_aval_descricao#',
						pc_aval_classificacao = '#arguments.pc_aval_classificacao#',
						pc_aval_vaFalta =  '#arguments.pc_aval_vaFalta#',
						pc_aval_vaRisco =  '#arguments.pc_aval_vaRisco#',
						pc_aval_vaSobra =  '#arguments.pc_aval_vaSobra#',
						pc_aval_atualiz_datahora = CONVERT(char, GETDATE(), 120),
						pc_aval_atualiz_login = '#cgi.REMOTE_USER#'

					WHERE  pc_aval_id = #arguments.pc_aval_id#
				</cfquery> 	
				<!--Se a classificação for modificada para Leve, todas as orientações e propostas de melhoria do item serão excluídas-->
				<cfif '#arguments.pc_aval_classificacao#' eq 'L'>
					<cfquery datasource="#dsn_processos#" >
						Delete from pc_avaliacao_orientacoes WHERE  pc_aval_orientacao_num_aval = #arguments.pc_aval_id#
						Delete from pc_avaliacao_melhorias WHERE  pc_aval_melhoria_num_aval = #arguments.pc_aval_id#
					</cfquery>
				</cfif>
			</cftransaction>
		</cfif>

		

	</cffunction>




	<cffunction name="tabAvaliacoes" returntype="any" access="remote" hint="Criar a tabela das avaliações e envia para a páginas pc_PcCadastroAvaliacaoPainel">
	
	 
		<cfargument name="numProcesso" type="string" required="true"/>


		<cfquery name="rsAvalTab" datasource="#dsn_processos#">
			SELECT      pc_avaliacoes.* 
			FROM        pc_avaliacoes 
			WHERE       pc_aval_processo = '#arguments.numProcesso#'
			Order by    pc_aval_numeracao 
                         
		</cfquery>
		
            
				<div class="row" style="padding-left:25px; padding-right:25px">
				<div id="divErroDelAvaliacao" ></div>
					<div class="col-12">
						<div class="card">
							<!-- /.card-header -->
							<div class="card-body">
								<table id="tabAvaliacoes" class="table table-bordered  table-hover table-striped">
									<thead style="background: #0083ca;color:#fff">
										<tr style="font-size:12px!important">
											<th >Controles</th>
											<th >Item N°:</th>
											<th >Título: </th>	
											<th >Classificação: </th>
											<th >Tipo Valor Envolvido: </th>
											<th hidden>Última Atualização: </th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="rsAvalTab" >

											<cfquery datasource="#dsn_processos#" name="rsAnexoAvaliacao">
												SELECT pc_anexos.pc_anexo_avaliacao_id FROM pc_anexos WHERE pc_anexo_avaliacao_id = #pc_aval_id# 
											</cfquery> 

											<cfquery datasource="#dsn_processos#" name="rsMelhorias">
												SELECT pc_avaliacao_melhorias.pc_aval_melhoria_num_aval FROM pc_avaliacao_melhorias WHERE pc_aval_melhoria_num_aval = #pc_aval_id#
											</cfquery>

											<cfquery datasource="#dsn_processos#" name="rsOrientacoes">
												SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_id FROM pc_avaliacao_orientacoes WHERE pc_aval_orientacao_num_aval = #pc_aval_id#
											</cfquery>

									
											
											<cfset classifRisco = "">
											<cfif #pc_aval_classificacao# eq 'L'>
												<cfset classifRisco = "Leve">
											</cfif>	
											<cfif #pc_aval_classificacao# eq 'M'>
												<cfset classifRisco = "Mediana">
											</cfif>	
											<cfif #pc_aval_classificacao# eq 'G'>
												<cfset classifRisco = "Grave">
											</cfif>	

											

											<cfoutput>					
												<tr style="font-size:12px" >
													<td style="vertical-align: middle;">
														<div style="display:flex;justify-content:space-around;">
															<i class="fas fa-edit efeito-grow"   style="margin-right:10px;cursor: pointer;z-index:100;font-size:20px"  onclick="javascript:editarAvaliacaoTitulo(this)"    title="Editar"></i>
															<i  class="fas fa-boxes-packing efeito-grow" onclick="javascript:mostraCadastroAvaliacaoRelato(<cfoutput>'#pc_aval_id#'</cfoutput>,this);"  style="cursor: pointer;z-index:100;font-size:20px"    title="Mostrar próximos passos." ></i>
														</div>
													</td>

													<td  align="center" style="vertical-align: middle;">#pc_aval_numeracao# </td>
													<td  ><pre >#pc_aval_descricao#</pre></td>

													<cfset vaFalta = #LSCurrencyFormat(pc_aval_vaFalta, 'local')#>
													<cfset vaRisco = #LSCurrencyFormat(pc_aval_vaRisco, 'local')#>
													<cfset vaSobra = #LSCurrencyFormat(pc_aval_vaSobra, 'local')#>
													<td>#classifRisco#</td>

													<cfif #vaFalta# eq 'R$ 0,00' and #vaRisco# eq 'R$ 0,00' and #vaSobra# eq 'R$ 0,00' >
														<td  style="vertical-align: middle;">Não Quantificado</td>
													<cfelse>
														<td  style="vertical-align: middle;">Falta: #vaFalta# / Risco: #vaRisco# / Sobra: #vaSobra#</td>
													</cfif>
													
													<cfset dataHora = DateFormat(#pc_aval_atualiz_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_aval_atualiz_datahora#,'HH:mm:ss') & ')'>
													<td hidden>#dataHora# - #pc_aval_atualiz_login#</td>
													<td hidden>#pc_aval_id#</td>
													<td hidden>#vaFalta#</td>
													<td hidden>#vaRisco#</td>
													<td hidden>#vaSobra#</td>
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
				$("#tabAvaliacoes").DataTable({
					columnDefs: [
						{ "orderable": false, "targets": 0 }//impede que a primeira coluna seja ordenada
					],
					order: [[ 1, "asc" ]],//ordena a segunda coluna como crescente
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
				}).buttons().container().appendTo('#tabAvaliacoes_wrapper .col-md-6:eq(0)');
					
			});

			
         

			function editarAvaliacaoTitulo(linha) {
				event.preventDefault()
				event.stopPropagation()
				$("#accordionTitulo").attr("hidden", false)
				$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
	    		var pcNumSituacaoEncontrada = $(linha).closest("tr").children("td:nth-child(2)").text();
				var pcTituloSituacaoEncontrada = $(linha).closest("tr").children("td:nth-child(3)").text();
				var pcTipoClassif = $(linha).closest("tr").children("td:nth-child(4)").text();
				var pc_aval_id = $(linha).closest("tr").children("td:nth-child(7)").text();
				var pc_aval_vaFalta = $(linha).closest("tr").children("td:nth-child(8)").text();
				var pc_aval_vaRisco = $(linha).closest("tr").children("td:nth-child(9)").text();
				var pc_aval_vaSobra = $(linha).closest("tr").children("td:nth-child(10)").text();
	
				var pcTipoClassifVal = "";

				switch(pcTipoClassif) {
					case "Leve":
						pcTipoClassifVal = "L"
					break;
					case "Mediana":
						pcTipoClassifVal = "M"
					break;
					case "Grave":
						pcTipoClassifVal = "G"
					break;

					default:
						pcTipoClassifVal = ""
				}  

				var pcValorApuradoTipoVal ="" 
				if(pc_aval_vaFalta == "R$ 0,00" && pc_aval_vaRisco == "R$ 0,00" && pc_aval_vaSobra == "R$ 0,00"){
					pcValorApuradoTipoVal ="n";
				}else{
					pcValorApuradoTipoVal ="q";
				}

				$('#pcvaFalta').val(pc_aval_vaFalta);
				$('#pcvaRisco').val(pc_aval_vaRisco);
				$('#pcvaSobra').val(pc_aval_vaSobra);
				$('#pcNumSituacaoEncontrada').val(pcNumSituacaoEncontrada);
				$('#pcTituloSituacaoEncontrada').val(pcTituloSituacaoEncontrada);
				$('#pcTipoClassif').val(pcTipoClassifVal);
				$('#pcValorApuradoTipo').val(pcValorApuradoTipoVal);
				$('#pc_aval_id').val(pc_aval_id);
				if($('#pcValorApuradoTipo').val() !== 'n'){
					$("#divValores").attr("hidden",false)
				}else{
					if (!$("#divValores").attr("hidden")) {
						$("#divValores").attr("hidden", true)
					} 
				}
				$('#cabecalhoAccordion').text("Editar o item:" + ' ' + pcNumSituacaoEncontrada);
					
				$('#cadastroItem').CardWidget('expand')
				$('html, body').animate({ scrollTop: ($('#cadastroItem').offset().top - 80)} , 500);
			};	

			

			function mensErro(mensagemErro){
				event.preventDefault()
				event.stopPropagation()
				let erroSistema = { html: logoSNCIsweetalert2(mensagemErro) }
				
				swalWithBootstrapButtons.fire(
					{...erroSistema}
				)
			}

			
			function excluirAvaliacao(pc_aval_id, linha)  {
				event.preventDefault()
		        event.stopPropagation()
			
				<cfoutput>var pc_aval_processo = '#arguments.numProcesso#';</cfoutput>
                var mensagem = "Deseja excluir este item?";
				
				
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!',
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							var dataEditor = $('.editor').html();
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "pc_cfcProcessos_editar.cfc",
									data:{
										method: "delAvaliacao",
										pc_aval_id: pc_aval_id,
										pc_aval_processo: pc_aval_processo
										
									},
									async: false
								})//fim ajax
								.done(function(result) {	
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});	
									exibirTabAvaliacoes()
									mostraCads()
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
									})
								})//fim fail
							},500);	
						}
					})
			}


			function mostraCadastroAvaliacaoRelato(idAvaliacao,linha) {
				event.preventDefault()
				event.stopPropagation()

				$(linha).closest("tr").children("td:nth-child(2)").click();//seleciona a linha onde o botão foi clicado
                $('#modalOverlay').modal('show')
				
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: 'cadastroAvaliacaoRelato',
							idAvaliacao:idAvaliacao
							
						},
						async: false
					})//fim ajax
					.done(function(result) {
						
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


	</cffunction>





	<cffunction name="delAvaliacao"   access="remote" hint="deleta avaliação páginas pc_Avaliacoes.cfm tabela chamada pelo metodo tabAvaliacoes">
		<cfargument name="pc_aval_id" type="numeric" required="true" />
		<cfargument name="pc_aval_processo" type="string" required="true" />

		<cfquery datasource="#dsn_processos#" name="rsAnexoAvaliacao">
			SELECT pc_anexos.pc_anexo_avaliacao_id FROM pc_anexos WHERE pc_anexo_avaliacao_id = #arguments.pc_aval_id# 
		</cfquery> 

		<cfquery datasource="#dsn_processos#" name="rsMelhorias">
			SELECT pc_avaliacao_melhorias.pc_aval_melhoria_num_aval FROM pc_avaliacao_melhorias WHERE pc_aval_melhoria_num_aval = #arguments.pc_aval_id#
		</cfquery>

		<cfquery datasource="#dsn_processos#" >
			DELETE FROM pc_validacoes_chat
			WHERE pc_validacao_chat_num_aval= '#arguments.pc_aval_id#'
		</cfquery>

   

		<cfif #rsAnexoAvaliacao.RecordCount# eq 0 && #rsMelhorias.RecordCount# eq 0>
			<cfquery datasource="#dsn_processos#" >
				DELETE FROM pc_avaliacoes
				WHERE pc_aval_id= '#arguments.pc_aval_id#'
			</cfquery> 
		</cfif>



		<cfquery datasource="#dsn_processos#" name="rsAvaliacoes">
			SELECT pc_avaliacoes.pc_aval_id FROM pc_avaliacoes WHERE pc_aval_processo = '#arguments.pc_aval_processo#'
		</cfquery>



		<cfif #rsAvaliacoes.recordCount#  eq 0>
			<cfquery datasource="#dsn_processos#" >
				UPDATE pc_processos
				SET pc_num_status = 2
				WHERE  pc_processo_id = '#arguments.pc_aval_processo#'
			</cfquery> 	
		</cfif>
	</cffunction>





	<cffunction name="cadastroAvaliacaoRelato"   access="remote" hint="valida (ou  não) a avaliação e, se foi a Última avaliação a ser validada, envia o processo para o Órgão responsável.">
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="passoapasso" type="string" required="false" default="true"/>

		<cfquery datasource="#dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = #arguments.idAvaliacao#
		</cfquery>

		<session class="content-header"  >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">


					<div id="idAvaliacao" hidden></div>

					<cfquery name="rsProcAval" datasource="#dsn_processos#">
						SELECT  pc_processos.*
						,pc_orgaos.pc_org_descricao   				AS descOrgAvaliado
						,pc_orgaos.pc_org_sigla      				AS siglaOrgAvaliado
						,pc_orgaos.pc_org_se_sigla    				AS seOrgAvaliado
						,pc_orgaos.pc_org_mcu
						,pc_orgaos_1.pc_org_descricao 				AS descOrgOrigem
						,pc_orgaos_1.pc_org_sigla     				AS siglaOrgOrigem
						,pc_avaliacao_tipos.pc_aval_tipo_descricao
						,pc_classificacoes.pc_class_descricao
						,pc_avaliacoes.*
						,pc_status.*

						FROM pc_processos
						INNER JOIN pc_avaliacoes     		ON pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo
						INNER JOIN pc_avaliacao_tipos 		ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
						INNER JOIN pc_orgaos 				ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu
						INNER JOIN pc_status 				ON pc_processos.pc_num_status = pc_status.pc_status_id
						INNER JOIN pc_orgaos AS pc_orgaos_1	ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu
						INNER JOIN pc_classificacoes 		ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id

						WHERE pc_aval_id = #arguments.idAvaliacao# 													
					</cfquery>	

					<cfquery name="rsAvalStatusTipos" datasource="#dsn_processos#">
						SELECT pc_avaliacao_status.* FROM pc_avaliacao_status 
						WHERE  pc_aval_status_id = #rsProcAval.pc_aval_status#
					</cfquery>


				
					<input id="pcProcessoId"  required="" hidden  value="#arguments.idAvaliacao#">

					<cfquery name="rs_OrgAvaliado" datasource="#dsn_processos#">
						SELECT pc_orgaos.*
						FROM pc_orgaos
						WHERE pc_org_controle_interno ='N' AND pc_org_Status = 'A'
								AND (pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#' or pc_org_mcu = '#rsProcAval.pc_num_orgao_avaliado#' 
										or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' 
																		and pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#'
																	)
									)
						ORDER BY pc_org_sigla
					</cfquery>

					<cfquery datasource="#dsn_processos#" name="rsModalidadeProcesso">
						SELECT pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_processo_id, pc_processos.pc_num_status FROM pc_processos
						Right JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						WHERE pc_avaliacoes.pc_aval_id = #arguments.idAvaliacao# 
					</cfquery>

		

					<cfquery datasource="#dsn_processos#" name="rsProcessoComOrientacoes">
						SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_id from pc_avaliacao_orientacoes
						LEFT JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
						LEFT JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
						WHERE pc_processo_id = '#rsModalidadeProcesso.pc_processo_id#'
					</cfquery>

					
					<cfquery datasource="#dsn_processos#" name="rsAvaliacoesValidadas">
						SELECT      pc_avaliacoes.pc_aval_status FROM pc_avaliacoes
						WHERE       pc_aval_processo = '#rsModalidadeProcesso.pc_processo_id#' and  pc_aval_status in (1,2,3)
					</cfquery>

				

					<!--tabs-->
				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						.tab-pane{
							min-height: 300px;
						}
					</style>
						
					<div class="card-header" style="background-color: #0083CA;border-bottom:solid 2px #fff" >
						<cfoutput>
							<p style="font-size: 1.3em;color:##fff"><strong>#rsProcAval.pc_aval_numeracao# - #rsProcAval.pc_aval_descricao#</strong></p>
						</cfoutput>	
					</div>
					<div id="tabsCadItem" class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
							
								
								<li class="nav-item" style="">
									<a  class="nav-link active" id="custom-tabs-one-2passo-tab"  data-toggle="pill" href="#custom-tabs-one-2passo" role="tab" aria-controls="custom-tabs-one-2passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">2° Passo - Relatório do Item<cfelse>Relatório do Item</cfif></a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-3passo-tab"  data-toggle="pill" href="#custom-tabs-one-3passo" role="tab" aria-controls="custom-tabs-one-3passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">3° Passo - Anexos<cfelse>Anexos</cfif></a>
								</li>
								
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-4passo-tab"  data-toggle="pill" href="#custom-tabs-one-4passo" role="tab" aria-controls="custom-tabs-one-4passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">4° Passo - Medida/Orientação para Regularização<cfelse>Medida/Orientação para Regularização</cfif></a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-5passo-tab"  data-toggle="pill" href="#custom-tabs-one-5passo" role="tab" aria-controls="custom-tabs-one-5passo" aria-selected="true"><cfif '#arguments.passoapasso#' eq "true">5° Passo - Proposta de Melhoria<cfelse>Proposta de Melhoria</cfif></a>
								</li>
								
							</ul>
							
						</div>
						<div class="card-body" style="align-items: center;">
							<div class="tab-content" id="custom-tabs-one-tabContent">
								
							
								<div disable class="tab-pane fade active show" id="custom-tabs-one-2passo"  role="tabpanel" aria-labelledby="custom-tabs-one-2passo-tab" >
									
									
										<cfif #rsProcAval.pc_modalidade# eq 'A' OR #rsProcAval.pc_modalidade# eq 'E'>
											<div class="row">
												<div class="col-md-12">
													<div class="card card-default">
														
														<div class="card-body">
															<div id="actions" class="row" >
																<div class="col-lg-12" align="center">
																	<div class="btn-group w-30">
																		<span id="avaliacoes" class="btn btn-success col fileinput-button" style="background:#0083CA">
																			<i class="fas fa-upload"></i>
																			<span style="margin-left:5px">Clique aqui para anexar o Relatório em PDF, exclusivo deste item (caso exista)</span>
																		</span>																	
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

														
													</div>
													
													</div>
													<!-- /.card -->
												</div>
											</div>
										</cfif>
								

									<div id="anexoAvaliacaoDiv"></div>


									<cfif #rsProcAval.pc_modalidade# eq 'N' >
										<div align="center">
											<div class="container">
												<textarea  id="pcSituacaoEncontrada" name="pcSituacaoEncontrada"><cfoutput>#rsProcAval.pc_aval_relato#</cfoutput></textarea>							
											</div>
											
											<div style="margin-top:10px;">
												<div id="divTabAvaliacaoVersoes"></div>
											</div>
										</div>
									</cfif>

								</div>

								<div class="tab-pane fade " id="custom-tabs-one-3passo" role="tabpanel" aria-labelledby="custom-tabs-one-3passo-tab">
									
										
										<div id="actions2" class="row" >
											<div class="col-lg-12" align="center">
												<div class="btn-group w-30">
													
														<span id="anexos" class="btn btn-success col fileinput-button" >
															<i class="fas fa-upload"></i>
															<span style="margin-left:5px">Clique aqui para anexar arquivos (PDF, EXCEL ou ZIP)</span>
														</span>
													
												</div>
											</div>
										</div>
										<div  class="row" >	
											<div class="col-lg-0 d-flex align-items-center" ><!--col-lg-0 para esconder a barra -->
												<div class="fileupload-process w-100">
													<div id="total-progress2" class="progress progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0">
														<div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress hidden></div>
													</div>
												</div>
											</div>
										</div>
										<div class="table table-striped files" id="previews2">
											<div id="template2" class="row mt-2">
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
									
									
									<div id="tabAnexosDiv" style="margin-top:20px"></div>

								</div>

								<div class="tab-pane fade " id="custom-tabs-one-4passo" role="tabpanel" aria-labelledby="custom-tabs-one-4passo-tab" style="font-size:16px">
									<input id="pcOrientacaoId" hidden>
									
									<!--Se o status do processo for ACOMPANHAMENTO, será permitida a inclusão de orientações-->	
									<div <cfif rsProcAval.pc_num_status neq 4 AND rsProcAval.pc_num_status neq 6>hidden</cfif> id="divOrientacoes"  class="row" style="font-size:16px">
										<div class="col-sm-12">
											<div class="form-group">
												<label id="labelOrientacao" for="pcOrientacao">Orientação:</label>
												<textarea class="form-control" id="pcOrientacao" rows="4" required=""  name="pcOrientacao" class="form-control"></textarea>
											</div>										
										</div>

										<div id="divPcOrgaoRespOrientacao" class="col-sm-4">
											<div class="form-group">
												<label for="pcOrgaoRespOrientacao">Órgão Responsável:</label>
												<select id="pcOrgaoRespOrientacao" required="" name="pcOrgaoRespOrientacao" class="form-control"  style="height:40px">
													<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
													<cfoutput query="rs_OrgAvaliado">
														<option value="#pc_org_mcu#">#pc_org_sigla#</option>
													</cfoutput>
												</select>
											</div>
										</div>
										
										<div style="justify-content:center; display: flex; width: 100%;">
											<div>
												<button id="btSalvarOrientacao"  class="btn btn-block  " style="background-color:#0083ca;color:#fff">Salvar</button>
											</div>
											<div style="margin-left:100px">
												<button id="btCancelarOrientacao"  class="btn btn-block btn-danger " >Cancelar</button>
											</div>
											
										</div>	
									</div>
									
									<div id="tabOrientacoesDiv" style="margin-top:20px"></div>
									

								</div>



								<div class="tab-pane fade " id="custom-tabs-one-5passo" role="tabpanel" aria-labelledby="custom-tabs-one-5passo-tab">
									<input id="pcMelhoriaId" hidden>
									
									<div  id="divMelhorias" class="row" style="font-size:16px">
										<div class="col-sm-12">
											<div class="form-group">
												<label id="labelMelhoria" for="pcMelhoria">Proposta de Melhoria:</label>
												<textarea class="form-control" id="pcMelhoria" rows="4" required=""  name="pcMelhoria" class="form-control"></textarea>
											</div>										
										</div>
										<div class="col-sm-4">
											<div class="form-group">
												<label  for="pcOrgaoRespMelhoria">Órgão Responsável:</label>
												<select id="pcOrgaoRespMelhoria" required="" name="pcOrgaoRespMelhoria" class="form-control"  style="height:40px">
													<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
													<cfoutput query="rs_OrgAvaliado">
														<option value="#pc_org_mcu#">#pc_org_sigla#</option>
													</cfoutput>
												</select>
											</div>
										</div>											
										<cfif #rsProcAval.pc_modalidade# eq 'A' OR #rsProcAval.pc_modalidade# eq 'E'>
											<div class="col-sm-4">
												<div class="form-group">
													<label  for="pcStatusMelhoria">Status:</label>
													<select id="pcStatusMelhoria" required="" name="pcStatusMelhoria" class="form-control"  style="height:40px">
														<!--Se o processo não estiver bloqueado-->
														<cfif rsProcAval.pc_num_status neq 6>
														    <option selected="" disabled="" value="">Selecione um status</option>
															<option value="P">PENDENTE</option>
															<option value="A">ACEITA</option>
															<option value="R">RECUSA</option>
															<option value="T">TROCA</option>
															<option value="N">NÃO INFORMADO</option>
														<cfelse>
															<option value="B">BLOQUEADO</option>
														</cfif>
													</select>
												</div>
											</div>

											<div id="pcDataPrevDiv" class="col-md-3" hidden>
												<div class="form-group">
													<label for="pcDataPrev">Data prevista para Implementação:</label>
													<div class="input-group date" id="reservationdate" data-target-input="nearest">
														<input  id="pcDataPrev"  name="pcDataPrev" required  type="date" class="form-control" placeholder="dd/mm/aaaa" >
													</div>
												</div>
											</div>

											<div id="pcOrgaoRespSugeridoMelhoriaDiv" class="col-sm-4" hidden>
												<div class="form-group">
													<label  for="pcOrgaoRespSugeridoMelhoria">Órgão Responsável Sugerido pelo órgão:</label>
													<select id="pcOrgaoRespSugeridoMelhoria" required="" name="pcOrgaoRespSugeridoMelhoria" class="form-control"  style="height:40px">
														<option selected="" disabled="" value="">Selecione o Órgão responsável...</option>
														<cfoutput query="rs_OrgAvaliado">
															<option value="#pc_org_mcu#">#pc_org_sigla#</option>
														</cfoutput>
													</select>
												</div>
											</div>

											<div id="pcRecusaJustMelhoriaDiv" class="col-sm-12" hidden>
												<div class="form-group">
													<label id="labelPcRecusaJustMelhoria" for="pcRecusaJustMelhoria">Informe as justificativa do órgão para Recusa:</label>
													<textarea class="form-control" id="pcRecusaJustMelhoria" rows="4" required=""  name="pcRecusaJustMelhoria" class="form-control"></textarea>
												</div>										
											</div>

											<div id="pcNovaAcaoMelhoriaDiv" class="col-sm-12" hidden>
												<div class="form-group">
													<label id="labelPcRecusaJustMelhoria" for="pcNovaAcaoMelhoria">Informe as ações que o órgão julgou necessárias:</label>
													<textarea class="form-control" id="pcNovaAcaoMelhoria" rows="4" required=""  name="pcNovaAcaoMelhoria" class="form-control"></textarea>
												</div>										
											</div>
										</cfif>




										<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
											<div >
												<button id="btSalvarMelhoria"  class="btn btn-block  " style="background-color:#0083ca;color:#fff">Salvar</button>
											</div>
											<div style="margin-left:100px">
												<button id="btCancelarMelhoria"  class="btn btn-block btn-danger " >Cancelar</button>
											</div>
										</div>	
									</div>
										
										
									<div id="tabMelhoriasDiv" style="margin-top:20px;"></div>
									


								</div>
							
								
								
							</div>

						
						</div>
						
					</div>
					
					
					

				</form><!-- fim formCadAvaliacao -->





			</session><!-- fim card-body2 -->	
					

					
		</session>
			

		<script language="JavaScript">

			function activaTab(tab){
				$('.nav-tabs a[href="#' + tab + '"]').tab('show');
			};


			<cfoutput>
				var modalidadeProcesso = '#rsProcAval.pc_modalidade#';
				
			</cfoutput>

			if(modalidadeProcesso ==='N'){
				CKEDITOR.replace( 'pcSituacaoEncontrada', {
					width: '100%',
					height: 300,
					on: {
						instanceReady: function() {
							mostraTabAvaliacaoVersoes();
						}
					}
					
				});
			}

				
			$(document).ready(function() {
				
				
				
				
				<cfoutput>
					var pc_aval_status = '#rsProcAval.pc_aval_status#';
					var pc_aval_processo = '#rsProcAval.pc_processo_id#';
					var pc_aval_id = '#arguments.idAvaliacao#';
					var statusProcesso ='#rsProcAval.pc_num_status#';
				</cfoutput>
				
			
				
				mostraRelatoPDF();
				$('#custom-tabs-one-2passo-tab').click(function(){
					$('#tabAnexosDiv').html('')
					$('#tabOrientacoesDiv').html('')
					$('#tabMelhoriasDiv').html('')
					$('#pendenciasDiv').html('')
					mostraRelatoPDF();
				});
					
				$('#custom-tabs-one-3passo-tab').click(function(){
					$('#anexoAvaliacaoDiv').html('')
					$('#tabOrientacoesDiv').html('')
					$('#tabMelhoriasDiv').html('')
					$('#pendenciasDiv').html('')
					mostraTabAnexos();
				});
				$('#custom-tabs-one-4passo-tab').click(function(){
					$('#anexoAvaliacaoDiv').html('')
					$('#tabAnexosDiv').html('')
					$('#tabMelhoriasDiv').html('')
					$('#pendenciasDiv').html('')
					mostraTabOrientacoes();
				});
				$('#custom-tabs-one-5passo-tab').click(function(){
					$('#anexoAvaliacaoDiv').html('')
					$('#tabAnexosDiv').html('')
					$('#tabOrientacoesDiv').html('')
					$('#pendenciasDiv').html('')
					mostraTabMelhorias();
				});
				
				  
				<cfoutput>
					let modalidade = '#rsProcAval.pc_modalidade#'
				</cfoutput>

				if(modalidade =='A' || modalidade =='E'){
					// DropzoneJS Demo Code Start
					Dropzone.autoDiscover = false

					// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
					var previewNode = document.querySelector("#template")
					//previewNode.id = ""
					var previewTemplate = previewNode.parentNode.innerHTML
					previewNode.parentNode.removeChild(previewNode)

					var myDropzone = new Dropzone("div#custom-tabs-one-2passo", { // Make the whole body a dropzone
						url: "cfc/pc_cfcProcessos_editar.cfc?method=uploadArquivos", // Set the url
						autoProcessQueue :true,
						maxFiles: 1,
						maxFilesize:20,
						thumbnailWidth: 80,
						thumbnailHeight: 80,
						parallelUploads: 1,
						acceptedFiles: '.pdf',
						previewTemplate: previewTemplate,
						autoQueue: true, // Make sure the files aren't queued until manually added
						previewsContainer: "#previews", // Define the container to display the previews
						clickable: "#avaliacoes", // Define the element that should be used as click trigger to select files.
						headers: { "pc_aval_id":pc_aval_id, 
								"pc_aval_processo":pc_aval_processo, 
								"pc_anexo_avaliacaoPDF":"S",
								"arquivoParaTodosOsItens":"N"},//informar "S" se o arquivo deve ser exibido em todos os itens do processo
						init: function() {
							this.on('error', function(file, errorMessage) {	
								toastr.error(errorMessage);
								return false;
							});
						}
						
					})

					

					// Update the total progress bar
					myDropzone.on("totaluploadprogress", function(progress) {
						document.querySelector(".progress-bar").style.width = progress + "%"
					})

					myDropzone.on("sending", function(file) {
						$('#modalOverlay').modal('show')
					})



					// Hide the total progress bar when nothing's uploading anymore
					myDropzone.on("queuecomplete", function(progress) {
						//toastr.success("Arquivo(s) enviado(s) com sucesso!")
						myDropzone.removeAllFiles(true);
						mostraRelatoPDF();

						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
					})

					
					// DropzoneJS 1 Demo Code End
				}


				// DropzoneJS 2 Demo Code Start
				Dropzone.autoDiscover = false

				// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
				var previewNode = document.querySelector("#template2")
				//previewNode.id = ""
				var previewTemplate = previewNode.parentNode.innerHTML
				previewNode.parentNode.removeChild(previewNode)

				var myDropzone2 = new Dropzone("div#custom-tabs-one-3passo", { // Make the whole body a dropzone
					url: "cfc/pc_cfcProcessos_editar.cfc?method=uploadArquivos", // Set the url
					autoProcessQueue :true,
					thumbnailWidth: 80,
					thumbnailHeight: 80,
					parallelUploads: 1,
					maxFilesize:4,
					acceptedFiles: '.pdf,.xls,.xlsx,.zip',
					previewTemplate: previewTemplate,
					autoQueue: true, // Make sure the files aren't queued until manually added
					previewsContainer: "#previews2", // Define the container to display the previews
					clickable: "#anexos", // Define the element that should be used as click trigger to select files.
					headers: { "pc_aval_id":pc_aval_id, 
							"pc_aval_processo":pc_aval_processo, 
							"pc_anexo_avaliacaoPDF":"N",
							"arquivoParaTodosOsItens":"N"},//informar "S" se o arquivo deve ser exibido em todos os itens do processo
					init: function() {
						this.on('error', function(file, errorMessage) {	
							toastr.error(errorMessage);
						});
					}
					
				})

				

				// Update the total progress bar
				myDropzone2.on("totaluploadprogress", function(progress) {
					document.querySelector(".progress-bar").style.width = progress + "%"
				})

				myDropzone2.on("sending", function(file) {
					$('#modalOverlay').modal('show')
				})

				// Hide the total progress bar when nothing's uploading anymore
				myDropzone2.on("queuecomplete", function(progress) {
					//toastr.success("Arquivo(s) enviado(s) com sucesso!")
					myDropzone2.removeAllFiles(true);
					//$(".start").attr("hidden", true)
					//$(".cancel").attr("hidden", true)
					mostraTabAnexos();
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
				})

				
				
			})

			$(function () {
				$('[data-mask]').inputmask()
			})


			<cfoutput>
				var pc_aval_id = '#rsProcAval.pc_aval_id#'
			</cfoutput>
			
			$('#pcStatusMelhoria').on('change', function (event)  {
				if($('#pcStatusMelhoria').val()=='A'){
					$('#pcDataPrevDiv').attr('hidden', false)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)			
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', true)	

					$('#pcRecusaJustMelhoria').val('')
					$('#pcNovaAcaoMelhoria').val('')			
					$('#pcOrgaoRespSugeridoMelhoria').val('')	
				}
				if($('#pcStatusMelhoria').val()=='R'){
					$('#pcDataPrevDiv').attr('hidden', true)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', false)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', true)		

					$('#pcDataPrev').val('')
					$('#pcNovaAcaoMelhoria').val('')
					$('#pcOrgaoRespSugeridoMelhoria').val('')
				}
				if($('#pcStatusMelhoria').val()=='T'){
					$('#pcDataPrevDiv').attr('hidden', false)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', false)
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', false)		

					$('#pcRecusaJustMelhoria').val('')
				}
				


				if($('#pcStatusMelhoria').val()==null || $('#pcStatusMelhoria').val()=='N' || $('#pcStatusMelhoria').val()=='P'){
					$('#pcDataPrevDiv').attr('hidden', true)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)
					$('#pcOrgaoRespSugeridoMelhoriaDiv').attr('hidden', true)	

					$('#pcDataPrev').val('')
					$('#pcRecusaJustMelhoria').val('')
					$('#pcNovaAcaoMelhoria').val('')
					$('#pcOrgaoRespSugeridoMelhoria').val('')	
				}
			})
			
			

			$('#btCancelarOrientacao').on('click', function (event)  {
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()

				$('#pcOrientacao').val('') 
				$('#pcOrgaoRespOrientacao').val('') 
				$('#pcOrientacaoId').val('')
				$('#labelOrientacao').html('Orientação:')
				<cfoutput>
					var statusProcesso ='#rsProcAval.pc_num_status#';
				</cfoutput>
				if(statusProcesso==4 || statusProcesso==6 ){
					$('#divOrientacoes').attr("hidden", false);
					$('#divPcOrgaoRespOrientacao').attr("hidden",false);
				}else{
					$('#divOrientacoes').attr("hidden", true);
					$('#divPcOrgaoRespOrientacao').attr("hidden",true);
				}	
				
			});

			$('#btCancelarMelhoria').on('click', function (event)  {
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()
				//$('#divMelhorias').attr("hidden", true);
				$('#pcMelhoria').val('') 
				$('#pcOrgaoRespMelhoria').val('') 
				$('#pcDataPrev').val('')
				$('#pcRecusaJustMelhoria').val('')
				$('#pcNovaAcaoMelhoria').val('')
				$('#pcOrgaoRespSugeridoMelhoria').val('')		
				$('#pcStatusMelhoria').val('')

				$('#pcMelhoriaId').val('')
				$('#labelMelhoria').html('Proposta de Melhoria:')	
			});
			



			function mostraTabAvaliacaoVersoes(){
				$('#modalOverlay').modal('show');
				$.ajax({
					type: "POST",
					url:"cfc/pc_cfcProcessos_editar.cfc",
					data:{
						method: "tabAvaliacaoVersoes",
						pc_aval_id: pc_aval_id
					},
					async: false
				})//fim ajax
				.done(function(result) {
					$('#divTabAvaliacaoVersoes').html(result)
					
					
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

			}

					


			$('#btSalvarOrientacao').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()
			    $('#divOrientacoes').attr("hidden", false);
				<cfoutput>
					var statusProcesso ='#rsProcAval.pc_num_status#';
					var modalidadeProcesso ='#rsProcAval.pc_modalidade#';
				</cfoutput>
				//verifica se os campos necessários foram preenchidos
				if ($('#pcOrientacao').val().length == 0 || ((statusProcesso==4 || statusProcesso==6) && $('#pcOrgaoRespOrientacao').val()==null))
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}

				var mensagem = ""
				if(modalidadeProcesso == 'A' && $('#pcOrientacaoId').val()==''){
					var mensagem = "Deseja cadastrar esta Medida/Orientação para regularização? <br><br> <b>ATENÇÃO:</b> Como o processo é da modalidade ACOMPANHAMENTO, a orientação receberá o status 'PENDENTE DE POSICIONAMENTO INICIAÇL."
				}else if($('#pcOrientacaoId').val()==''){
					var mensagem = "Deseja cadastrar esta Medida/Orientação para regularização?"
				}else{
					var mensagem = "Deseja editar esta Medida/Orientação para regularização?"	
				}
				
				
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
									type: "post",
									url: "cfc/pc_cfcProcessos_editar.cfc",
									data:{
										method: "cadOrientacoes",
										pc_aval_id: pc_aval_id,
										pc_aval_orientacao_id: $('#pcOrientacaoId').val(),
										pc_aval_orientacao_descricao: $('#pcOrientacao').val(),
										pc_aval_orientacao_mcu_orgaoResp:  $('#pcOrgaoRespOrientacao').val()
									},
									async: false
								})//fim ajax
								.done(function(result) {
									$('#pcOrientacaoId').val('')
									$('#pcOrientacao').val('')
									$('#pcOrgaoRespOrientacao').val('')
									//mostraPendencias()
									mostraTabOrientacoes()
									$('html, body').animate({ scrollTop: ($('#CadastroAvaliacaoRelato').offset().top)} , 500);	
									if(statusProcesso==4 || statusProcesso==6){
										$('#divOrientacoes').attr("hidden", false);
										$('#divPcOrgaoRespOrientacao').attr("hidden",false);
									}else{
										$('#divOrientacoes').attr("hidden", true);
										$('#divPcOrgaoRespOrientacao').attr("hidden",true);
									}	
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
					});
				$('#labelOrientacao').html('Orientação:')	
				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});		
			});



			$('#btSalvarMelhoria').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()
			    				
				//verifica se os campos necessários foram preenchidos
				<cfoutput>
					let modalidade = '#rsProcAval.pc_modalidade#';
				</cfoutput>
			
				if(modalidade =="A" || modalidade =="E"){
					if (
						$('#pcMelhoria').val().length == 0 || 
						$('#pcOrgaoRespMelhoria').val() == null ||
						$('#pcStatusMelhoria').val() == null ||
						($('#pcStatusMelhoria').val()=='A' && !$('#pcDataPrev').val())||
						($('#pcStatusMelhoria').val()=='R' && $('#pcRecusaJustMelhoria').val().length == 0 )||
						($('#pcStatusMelhoria').val()=='T' && (!$('#pcDataPrev').val()||$('#pcNovaAcaoMelhoria').val().length == 0 ||$('#pcOrgaoRespSugeridoMelhoria').val().length == 0))
					){   
						//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
						toastr.error('Todos os campos devem ser preenchidos!');
						return false;
					}
				}else{
					if (
						$('#pcMelhoria').val().length == 0 || 
						$('#pcOrgaoRespMelhoria').val()==null ){   
						//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
						toastr.error('Todos os campos devem ser preenchidos!');
						return false;
					}
				}


				$('#modalOverlay').modal('show')
				if(modalidade =="A" || modalidade =="E"){
					setTimeout(function() {	
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcProcessos_editar.cfc",
							data:{
								method: "cadMelhorias",
								modalidade: modalidade,
								pc_aval_id: pc_aval_id,
								pc_aval_melhoria_id: $('#pcMelhoriaId').val(),
								pc_aval_melhoria_descricao: $('#pcMelhoria').val(),
								pc_aval_melhoria_num_orgao:  $('#pcOrgaoRespMelhoria').val(),
								pc_aval_melhoria_status:$('#pcStatusMelhoria').val(),
								pc_aval_melhoria_dataPrev: $('#pcDataPrev').val(),
								pc_aval_melhoria_sugestao: $('#pcNovaAcaoMelhoria').val(),
								pc_aval_melhoria_sug_orgao_mcu:$('#pcOrgaoRespSugeridoMelhoria').val(),
								pc_aval_melhoria_naoAceita_justif:$('#pcRecusaJustMelhoria').val()
							},
							async: false
						})//fim ajax
						.done(function(result) {
							$('#pcMelhoriaId').val('')
							$('#pcMelhoria').val('') 
							$('#pcOrgaoRespMelhoria').val('') 
							$('#pcDataPrev').val('')
							$('#pcRecusaJustMelhoria').val('')
							$('#pcNovaAcaoMelhoria').val('')
							$('#pcOrgaoRespSugeridoMelhoria').val('')		
							$('#pcStatusMelhoria').val('P').trigger('change')
							//mostraPendencias()
							mostraTabMelhorias()
							$('html, body').animate({ scrollTop: ($('#CadastroAvaliacaoRelato').offset().top)} , 500);	
							//$('#divMelhorias').attr("hidden", true);
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
					$('#labelMelhoria').html('Proposta de Melhoria:')	
				}else{
					setTimeout(function() {
						$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "cadMelhorias",
							modalidade: modalidade,
							pc_aval_id: pc_aval_id,
							pc_aval_melhoria_id: $('#pcMelhoriaId').val(),
							pc_aval_melhoria_descricao: $('#pcMelhoria').val(),
							pc_aval_melhoria_num_orgao:  $('#pcOrgaoRespMelhoria').val()	
						},
						async: false
						})//fim ajax
						.done(function(result) {
							$('#pcMelhoriaId').val('')
							$('#pcMelhoria').val('') 
							$('#pcOrgaoRespMelhoria').val('') 
							
							//mostraPendencias()
							mostraTabMelhorias()
							$('html, body').animate({ scrollTop: ($('#CadastroAvaliacaoRelato').offset().top)} , 500);	
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
					$('#labelMelhoria').html('Proposta de Melhoria:')
				}			
			});


			function mostraTabAnexos(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "tabAnexos",
							pc_aval_id: pc_aval_id

						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabAnexosDiv').html(result)
						
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
				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});	

			}


			function mostraTabOrientacoes(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "tabOrientacoes",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabOrientacoesDiv').html(result)
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



			function mostraTabMelhorias(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "tabMelhorias",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabMelhoriasDiv').html(result)
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

			function mostraRelatoPDF(){
				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url:"cfc/pc_cfcProcessos_editar.cfc",
						data:{
							method: "anexoAvaliacao",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result){
						
						$('#anexoAvaliacaoDiv').html(result)
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

			

			function salvarTextoAvaliacao()  {
			
				event.preventDefault()
				event.stopPropagation()

				var dataEditor = CKEDITOR.instances.pcSituacaoEncontrada.getData();
				if(dataEditor.length <100){
					toastr.error('Insira um texto com, no mínimo, 100 caracteres.');
					return false;
				}

				$('#modalOverlay').modal('show')
				
				<cfoutput>
					var pc_aval_id = #rsProcAval.pc_aval_id#
				</cfoutput>
				
				
				
				$.ajax({
					type: "post",
					url: "cfc/pc_cfcProcessos_editar.cfc",
					data:{
						method: "cadTextoAvaliacao",
						pc_aval_id: pc_aval_id,
						pc_aval_relato: dataEditor 
					},
					async: false
				})//fim ajax
				.done(function(result) {
					//mostraCadastroAvaliacaoRelato(pc_aval_id);	
					//mostraPendencias()
					mostraTabAvaliacaoVersoes()	
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

				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});		
			};


		</script>
		
    </cffunction>

	

	<cffunction name="tabMelhorias" returntype="any" access="remote" hint="Criar a tabela de propostas de melhoria e envia para a páginas pc_CadastroRelato">

	    <cfargument name="pc_aval_id" type="numeric" required="true"/>

        <cfquery datasource="#dsn_processos#" name="rsMelhorias">
			Select pc_avaliacao_melhorias.* , pc_orgaos.pc_org_sigla, pc_orgaoSug.pc_org_sigla as siglaOrgSug
			FROM pc_avaliacao_melhorias 
			LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao
			LEFT JOIN pc_orgaos as pc_orgaoSug ON pc_orgaoSug.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
			<cfif #rsUsuario.pc_org_controle_interno# eq 'S'>
				WHERE pc_aval_melhoria_num_aval = #arguments.pc_aval_id# 
			<cfelse>
				WHERE pc_aval_melhoria_num_aval = #arguments.pc_aval_id# and pc_aval_melhoria_num_orgao = '#rsUsuario.pc_usu_lotacao#'
			</cfif>
			order By pc_aval_melhoria_id desc
			
		</cfquery>

		<cfquery datasource="#dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
		
            
				<div class="row">
					<div class="col-12">
						<div class="card">
							<!-- /.card-header -->
							<div class="card-body">
							    
								<table id="tabMelhorias" class="table table-bordered  table-hover ">
									<thead style="background: #0083ca;color:#fff">
										<tr style="font-size:14px">
											<th style="width: 10%;vertical-align:middle !important;">Controles</th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th hidden></th>
											<th style="width: 30%;vertical-align:middle !important;">Melhoria:</th>
											<th style="vertical-align:middle !important;">Órgão Responsável:</th>
											<th style="vertical-align:middle !important;">Status: </th>
											<th style="vertical-align:middle !important;">Data Prevista: </th>
											<th style="vertical-align:middle !important;">Órgão Responsável <br>(sugerido pelo órgão): </th>
											<th style="vertical-align:middle !important;">Justificativa do órgão: </th>
											<th style="vertical-align:middle !important;">Sugestão de Melhoria<br> (sugerida pelo órgão): </th>



										</tr>
									</thead>
								
									<tbody>
										<cfloop query="rsMelhorias" >
											<cfoutput>					
												<cfswitch expression="#pc_aval_melhoria_status#">
													<cfcase value="P">
														<cfset statusMelhoria = "PENDENTE">
													</cfcase>
													<cfcase value="A">
														<cfset statusMelhoria = "ACEITA">
													</cfcase>
													<cfcase value="R">
														<cfset statusMelhoria = "RECUSA">
													</cfcase>
													<cfcase value="T">
														<cfset statusMelhoria = "TROCA">
													</cfcase>
													<cfcase value="N">
														<cfset statusMelhoria = "NÃO INFORMADO">
													</cfcase>
													<cfcase value="B">
														<cfset statusMelhoria = "BLOQUEADO">
													</cfcase>
													<cfdefaultcase>
														<cfset statusMelhoria = "">	
													</cfdefaultcase>
													
												</cfswitch>
												<tr style="font-size:14px;color:##000" >
													<td style="text-align: center; vertical-align:middle !important;width:10%">	
														<div style="display:flex;justify-content:space-around;">
															<i id="btExcluirMelhoria" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px"   onClick="javascript:excluirMelhoria(#pc_aval_melhoria_id#)" title="Excluir" ></i>
															<i id="btEditarMelhoria" class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:5px" onClick="javascript:editarMelhoria(this);"   title="Editar" ></i>
														</div>
													</td>													
													<td hidden>#pc_aval_melhoria_id#</td>
													<td hidden>#pc_aval_melhoria_num_orgao#</td>
													<td hidden>#pc_aval_melhoria_sug_orgao_mcu#</td>
													<td hidden>#pc_aval_melhoria_dataPrev#</td>
													<td style="vertical-align:middle !important;"><textarea class="textareaTab" rows="3"  disabled>#pc_aval_melhoria_descricao#</textarea></td>
													<td style="vertical-align:middle !important;">#pc_org_sigla#</td>
													<td style="vertical-align:middle !important;">#statusMelhoria#</td>
													
													<cfset dataHora = DateFormat(#pc_aval_melhoria_dataPrev#,'DD-MM-YYYY')>
													<td style="vertical-align:middle !important;">#dataHora#</td>
													<td style="vertical-align:middle !important;">#siglaOrgSug#</td>
													<td style="vertical-align:middle !important;"><textarea class="textareaTab" rows="3" disabled>#pc_aval_melhoria_naoAceita_justif#</textarea></td>
													<td style="vertical-align:middle !important;"><textarea class="textareaTab" rows="3" disabled>#pc_aval_melhoria_sugestao#</textarea></td>
													
												
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
				
				$("#tabMelhorias").DataTable({
					"destroy": true,
			     	"stateSave": false,
					"responsive": true, 
					"lengthChange": false, 
					"autoWidth": false,
					"select": true
				})
	
			});

			function editarMelhoria(linha) {
				event.preventDefault()
				event.stopPropagation()
				$('#divMelhorias').attr('hidden',false);
				$(linha).closest("tr").children("td:nth-child(6)").click();//seleciona a linha onde o botão foi clicado	
				var pc_aval_melhoria_id = $(linha).closest("tr").children("td:nth-child(2)").text();
				var pc_aval_melhoria_num_orgao = $(linha).closest("tr").children("td:nth-child(3)").text();
				var pc_aval_melhoria_sug_orgao_mcu = $(linha).closest("tr").children("td:nth-child(4)").text();
				var pc_aval_melhoria_dataPrev = $(linha).closest("tr").children("td:nth-child(5)").text()
				var pc_aval_melhoria_descricao = $(linha).closest("tr").children("td:nth-child(6)").text();
				

				
				var pc_aval_melhoria_status = "";

				switch( $(linha).closest("tr").children("td:nth-child(8)").text()) {
					case "PENDENTE":
						pc_aval_melhoria_status = "P"
					break;
					case "ACEITA":
						pc_aval_melhoria_status = "A"
					break;
					case "RECUSA":
						pc_aval_melhoria_status = "R"
					break;
					case "TROCA":
						pc_aval_melhoria_status = "T"
					break;
					case "NÃO INFORMADO":
						pc_aval_melhoria_status = "N"
					break;
					case "BLOQUEADO":
						pc_aval_melhoria_status = "B"
					break;

					default:
						pc_aval_melhoria_status = ""
				}  
				
				var pc_aval_melhoria_naoAceita_justif = $(linha).closest("tr").children("td:nth-child(11)").text();
				var pc_aval_melhoria_sugestao = $(linha).closest("tr").children("td:nth-child(12)").text();

				$('#labelMelhoria').html('Editar Proposta de Melhoria:')
				$('#pcMelhoriaId').val(pc_aval_melhoria_id);
				$('#pcMelhoria').val(pc_aval_melhoria_descricao);
				$('#pcOrgaoRespMelhoria').val(pc_aval_melhoria_num_orgao);

				$('#pcStatusMelhoria').val(pc_aval_melhoria_status).trigger('change');
				$('#pcDataPrev').val(pc_aval_melhoria_dataPrev);
				$('#pcOrgaoRespSugeridoMelhoria').val(pc_aval_melhoria_sug_orgao_mcu);
				$('#pcRecusaJustMelhoria').val(pc_aval_melhoria_naoAceita_justif);
				$('#pcNovaAcaoMelhoria').val(pc_aval_melhoria_sugestao);

			};	

			function excluirMelhoria(pc_aval_melhoria_id)  {
				event.preventDefault()
		        event.stopPropagation()

				if(confirm("Deseja excluir esta proposta de melhoria?")){
					var dataEditor = $('.editor').html();
					$('#modalOverlay').modal('show')
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcProcessos_editar.cfc",
							data:{
								method: "delMelhorias",
								pc_aval_melhoria_id: pc_aval_melhoria_id
							},
							async: false
						})//fim ajax
						.done(function(result) {	
							//mostraPendencias()	
							mostraTabMelhorias();
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
								toastr.success('Operação realizada com sucesso!');
							});
						})//fim done
						.fail(function(xhr, ajaxOptions, thrownError) {
							$('#modalOverlay').delay(800).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)

						})//fim fail
					}, 500);
					
				}
				
			};

			

		</script>				
			
			
	

	</cffunction>



	<cffunction name="tabOrientacoes" returntype="any" access="remote" hint="Criar a tabela de medidas/orientações para regularização e envia para a páginas pc_CadastroRelato">

	    <cfargument name="pc_aval_id" type="numeric" required="true"/>

        <cfquery datasource="#dsn_processos#" name="rsOrientacoes">
			Select pc_avaliacao_orientacoes.* , pc_orgaos.pc_org_sigla, pc_processos.pc_num_status
			FROM pc_avaliacao_orientacoes 
			LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			<cfif #rsUsuario.pc_org_controle_interno# eq 'S'>
			    WHERE pc_aval_id = #arguments.pc_aval_id# 
			<cfelse>
                 WHERE pc_aval_id = #arguments.pc_aval_id#  and pc_aval_orientacao_mcu_orgaoResp = '#rsUsuario.pc_usu_lotacao#' and pc_aval_orientacao_status in (2,4,5) 
			</cfif>
			order By pc_aval_orientacao_id desc
		</cfquery>

		<cfquery datasource="#dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
            
				<div class="row">
					<div class="col-12">
						<div class="card">
							<!-- /.card-header -->
							<div class="card-body">
							    
								<table id="tabOrientacoes" class="table table-bordered table-hover  ">
									<thead style="background: #0083ca;color:#fff">
										<tr style="font-size:14px">
											<th>Controles</th>
											<th hidden >pc_aval_orientacao_id</th>
											<th hidden >pc_aval_orientacao_mcu_orgaoResp</th>
											<th>Orientação</th>
											<th >Órgão Responsável</th>
										</tr>
									</thead>
								
									<tbody>
										<cfloop query="rsOrientacoes" >
											<cfoutput>

												<tr style="font-size:14px;color:##000" >
													
													<td style="text-align: center; vertical-align:middle !important;width:10%">	
														<div style="display:flex;justify-content:space-around;">
															<!--<i id="btExcluirOrientacao" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px"   onClick="javascript:excluirOrientacao(#pc_aval_orientacao_id#)" title="Excluir" ></i>-->
															<i id="btEditarOrientacao" class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:5px" onClick="javascript:editarOrientacao(this);"   title="Editar" ></i>
														</div>
													</td>													
													
													<td hidden >#pc_aval_orientacao_id#</td>
													<td hidden>#pc_aval_orientacao_mcu_orgaoResp#</td>
													<td style="vertical-align:middle !important"><textarea class="textareaTab" rows="3" disabled>#pc_aval_orientacao_descricao#</textarea></td>
													<td style="vertical-align:middle !important;width:20%">#pc_org_sigla#</td>
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
				
				$("#tabOrientacoes").DataTable({
					"destroy": true,
			     	"stateSave": false,
					"responsive": true, 
					"lengthChange": false, 
					"autoWidth": false,
					"select": true
				});
					
			});

			

			function editarOrientacao(linha) {
				event.preventDefault()
				event.stopPropagation()
				$('#divOrientacoes').attr("hidden", false);
				$('#divPcOrgaoRespOrientacao').attr("hidden", true);
				$('#labelOrientacao').html('Editar Orientação:')	
				$(linha).closest("tr").children("td:nth-child(5)").click();//seleciona a linha onde o botão foi clicado	
				
				var pc_aval_orientacao_id = $(linha).closest("tr").children("td:nth-child(2)").text();
				var pc_aval_orientacao_mcu_orgaoResp = $(linha).closest("tr").children("td:nth-child(3)").text();			
				var pc_aval_orientacao_descricao = $(linha).closest("tr").children("td:nth-child(4)").text();
				var pc_org_sigla = $(linha).closest("tr").children("td:nth-child(5)").text();

				//se o órgão responsável pela orientação não fizer parte da estrutura do órgão avaliado, então esse órgão é incluído no select
				var valorExiste = $("#pcOrgaoRespOrientacao option[value='" + pc_aval_orientacao_mcu_orgaoResp + "']").length > 0;
					if (!valorExiste) {
						$('#pcOrgaoRespOrientacao').append($('<option>', {
							value: pc_aval_orientacao_mcu_orgaoResp,
							text: pc_org_sigla
						}));
					}

				$('#pcOrientacaoId').val(pc_aval_orientacao_id);
				$('#pcOrientacao').val(pc_aval_orientacao_descricao);
				$('#pcOrgaoRespOrientacao').val(pc_aval_orientacao_mcu_orgaoResp);
			};	

			
			

		</script>				
			
			
	

	</cffunction>


	<cffunction name="tabAnexos" returntype="any" access="remote" hint="Criar a tabela dos anexos e envia para a páginas pc_CadastroRelato">

	    <cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_orientacao_id" type="string" required="false" default=""/>
		

        <cfquery datasource="#dsn_processos#" name="rsAnexos">
			Select pc_anexos.*, pc_orgaos.*, pc_usu_nome FROM pc_anexos 
			Left JOIN pc_orgaos on pc_org_mcu = pc_anexo_mcu_orgao
			LEFT JOIN pc_usuarios ON pc_usu_matricula = RIGHT(pc_anexo_login,8)
			WHERE pc_anexo_avaliacaoPDF ='N' AND pc_anexo_avaliacao_id = #arguments.pc_aval_id# 

			
			order By pc_anexo_id desc
		</cfquery>

		<cfquery datasource="#dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>
			
            <cfif rsAnexos.recordcount neq 0>
				<div class="row">
					<div class="col-12">
						<div class="card">
						
							<!-- /.card-header -->
							<div class="card-body">
							   
								<table id="tabAnexos" class="table table-bordered table-striped table-hover text-nowrap">
									<thead style="background: #0083ca;color:#fff">
										<tr style="font-size:14px">
											<th>Controles:</th>
											<th style="width:25%">Arquivo: </th>
											<th>Anexado por: </th>
											<th style="width:10px">Data: </th>
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="rsAnexos" >
											<cfif FileExists(pc_anexo_caminho)>
												<cfoutput>					
													<cfset arquivo = ListLast(pc_anexo_caminho,'\')>
													<tr style="font-size:12px" >
														<td style="width:10%">	
															<div style="display:flex;justify-content:space-around;">
																<i id="btExcluir" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:18px" onclick="javascript:excluirAnexo(#pc_anexo_id#);"   title="Excluir" ></i>
																<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
																	<i id="btAbrirAnexo" class="fas fa-eye efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_blank')"   title="Excluir" ></i>
																<cfelse>
																	<i id="btAbrirAnexo" class="fas fa-download efeito-grow"   style="cursor: pointer;z-index:100;font-size:20px;margin-left:10px" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_self')"   title="Excluir" ></i>
																</cfif>
															
															</div>
														</td>

														<cfset data = DateFormat(#pc_anexo_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_anexo_datahora#,'HH:mm:ss') & ')'>
															
														<td >
															<cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
																<i class="fas fa-file-pdf " style="margin-right:10px;color:red;font-size:20px"></i>
															<cfelseif right(#pc_anexo_caminho#,3) eq 'zip'>
																<i class="fas  fa-file-zipper" style="margin-right:10px;color:blue;font-size:20px"></i>
															<cfelse>
																<i class="fas fa-file-excel" style="margin-right:10px;color:green;font-size:20px"></i>
															</cfif>												
															#pc_anexo_nome#
														</td>
														<cfif #rsUsuario.pc_org_controle_interno# eq 'S'>
															<td >#pc_org_sigla#</td>
														<cfelse>
														    <cfif #pc_org_controle_interno# eq 'S'>
																<td >Controle Interno</td> 
															<cfelse>
																<td >#pc_org_sigla#/#pc_usu_nome#</td>
															</cfif>
														</cfif>
														<td  style="width:100px">#data#</td>
													</tr>
												</cfoutput>
											</cfif>
											 
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
			<cfelse>
				<h5>Nenhum anexo foi adicionado.</h5>
			</cfif>


		<script >
			$(function () {
				$("#tabAnexos").DataTable({
					"destroy": true,
			    	"stateSave": false,
					"responsive": true, 
					"lengthChange": false, 
					"autoWidth": false
				})
					
			});

			function abrirAnexo(pc_anexo_caminho)  {
				event.preventDefault()
		        event.stopPropagation()
				return false
				window.location.href = "pc_Anexos.cfm?arquivo=" + pc_anexo_caminho;
			}

			function excluirAnexo(pc_anexo_id)  {
				event.preventDefault()
		        event.stopPropagation()
				
			
				let mensagem = "Deseja excluir este anexo?";
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							var dataEditor = $('.editor').html();
							setTimeout(function() {	
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcProcessos_editar.cfc",
									data:{
										method: "delAnexos",
										pc_anexo_id: pc_anexo_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
									mostraTabAnexos();
								
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide')
										toastr.success('Operação realizada com sucesso!')
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
									})
								})//fim fail
							}, 500);
						}
					});
				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide')
				});	
						
			};

			

		</script>				
			
			
	</cffunction>



	<cffunction name="anexoAvaliacao"   access="remote" hint="retorna os anexos que contem 'S' no campo pc_anexo_avaliacao indicando que é a avaliação e  não um anexo comum">
		<cfargument name="pc_aval_id" type="numeric" required="true" returntype="any"/>
		<cfargument name="todosOsRelatorios" type="string" required="false" default="N"/>
		
		<cfquery datasource="#dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status, pc_avaliacoes.pc_aval_processo FROM pc_avaliacoes WHERE pc_aval_id = #arguments.pc_aval_id#
		</cfquery>

		<cfquery datasource="#dsn_processos#" name="rsPc_anexos" > 
			SELECT pc_anexos.*   FROM  pc_anexos
			<cfif #arguments.todosOsRelatorios# eq "N">
				WHERE pc_anexo_avaliacao_id = #arguments.pc_aval_id# and pc_anexo_avaliacaoPDF = 'S'
			<cfelse>
				WHERE (pc_anexo_avaliacao_id = #arguments.pc_aval_id# OR pc_anexo_processo_id = '#rsStatus.pc_aval_processo#')  and pc_anexo_avaliacaoPDF = 'S'
			</cfif>
		</cfquery>


		
		<cfloop query="rsPc_anexos" >
		    <cfif FileExists(pc_anexo_caminho)>
				<cfset caminho = "#pc_anexo_caminho#">
			<cfelse>
				<cfset caminho = "Caminho  não encontrado">
			</cfif>
			
				<div class="card-body" style="padding:0px;">
					<div  id ="cardAvaliacaoPDF" class="card card-primary card-tabs collapsed-card" style="transition: all 0.15s ease 0s; height: inherit; width: inherit;">
						<div class="card-header" style="background-color:#00416b;">
						
							<h3 class="card-title" style="font-size:16px;position:relative;top:3px"><i class="fas fa-file-pdf" style="margin-right:10px;"></i><cfoutput> #pc_anexo_nome#</cfoutput></h3>
						    <div  class="card-tools">
								
								<button type="button"  id="btExcluir" class="btn btn-tool  " style="font-size:16px" onclick="javascript:excluirAnexoAvaliacao(<cfoutput>#pc_anexo_id#</cfoutput>);"  ><i class="fas fa-trash-alt"></i></button>
								<button  type="button" class="btn btn-tool" data-card-widget="collapse" style="font-size:16px;margin-left:50px"><i  class="fas fa-plus"></i></button>
								<button  type="button" class="btn btn-tool" data-card-widget="maximize" style="font-size:16px;margin-left:50px"><i  class="exp fas fa-expand"></i></button>
							</div>
						</div>
						
						<div class="card-body" style="height: 100%;background-color:#00416B;padding-top: 0px;">											
							<embed id="relatoPDFdiv" type="application/pdf" src="pc_Anexos.cfm?arquivo=<cfoutput>#caminho#</cfoutput>" style="width: 100%;height:90vh;" >
						</div>			
					</div>
				</div>
			
		</cfloop>

		<script language="JavaScript">
    
			function excluirAnexoAvaliacao(pc_anexo_id)  {
				
				
				let mensagem = "Deseja excluir este anexo?";
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
									type: "post",
									url: "cfc/pc_cfcProcessos_editar.cfc",
									data:{
										method: "delAnexos",
										pc_anexo_id: pc_anexo_id
									},
									async: false
								})//fim ajax
								.done(function(result) {	
									mostraTabAnexos();
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										mostraRelatoPDF()
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
					    }
				    });
			};

		</script>	
		
	</cffunction>



	<cffunction name="cadOrientacoes"   access="remote"  returntype="any" hint="cadastra/edita orientacao">
		
		<cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_orientacao_descricao" type="string" required="true"/>
		<cfargument name="pc_aval_orientacao_mcu_orgaoResp" type="string" required="true"/>
		<cfargument name="pc_aval_orientacao_id" type="string" required="false" default=""/>
		<!--Adiciona 30 dias úteis à data atual para gerar a data prevista para resposta que constara np texto do manifestação-->
		<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio">
		<cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias = 30 />
		<cfset dataPTBR = obterDataPrevista.Data_Prevista_Formatada>
		<cfset dataCFQUERY = "#DateFormat(obterDataPrevista.Data_Prevista,'YYYY-MM-DD')#">
		<!--Se pc_aval_orientacao_id igual a '' significa que é um cadastro de orientação-->
		<!--Se for um cadastro de orientação-->
		<cfif #arguments.pc_aval_orientacao_id# eq ''>
			<cfquery datasource="#dsn_processos#" name="rsProcesso">
				SELECT pc_num_status,pc_modalidade FROM   pc_processos
				INNER JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
				WHERE  pc_aval_id = #arguments.pc_aval_id#
			</cfquery>
				

			<!--Se o processo for da modalidade ACOMPANHAMENTO-->
			<cfif rsProcesso.pc_modalidade eq 'A' >
				<!--Se o processo estiver bloqueado-->
				<cfif rsProcesso.pc_num_status eq 6>
					<cfquery datasource="#dsn_processos#" name="qCadastraOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login)
						VALUES (14, CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#',#arguments.pc_aval_id#, '#arguments.pc_aval_orientacao_descricao#','#arguments.pc_aval_orientacao_mcu_orgaoResp#',  CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#')
						SELECT SCOPE_IDENTITY() AS NewID;
					</cfquery>
					<cfset IDdaOriencaoCadastrada = qCadastraOrientacao.NewID>
					<cfset posicaoInicial = "Processo BLOQUEADO.<br>Este relatório aguarda a finalização de análises complementares do controle interno e/ou outros órgãos da empresa para liberação ao ÓRGÃO AVALIADO. Favor aguardar.">
					<cfset orgaoResp = ''>
					<cfset posic_status = 14>
					<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					<cfquery datasource="#dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status)
						VALUES (#IDdaOriencaoCadastrada#, '#posicaoInicial#',CONVERT(char, GETDATE(), 120),'#rsUsuario.pc_usu_matricula#','#rsUsuario.pc_usu_lotacao#', '#orgaoResp#','#dataCFQUERY#',#posic_status#)
					</cfquery>
				<cfelse>
					<!--Se o processo não estiver bloqueado, a orientação ficará pendente de posicionamento inicial do controle interno-->
					<cfquery datasource="#dsn_processos#" >
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login)
						VALUES (1, CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#',#arguments.pc_aval_id#, '#arguments.pc_aval_orientacao_descricao#','#arguments.pc_aval_orientacao_mcu_orgaoResp#',  CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#')
					</cfquery>
				</cfif>
			<cfelse>
				<!--Se o processo for da modalidade ENTREGA DO RELATÓRIO-->
				<!--Se o processo estiver bloqueado-->
				<cfif rsProcesso.pc_num_status eq 6>
					<cfquery datasource="#dsn_processos#"  name="qCadastraOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login)
						VALUES (14, CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#',#arguments.pc_aval_id#, '#arguments.pc_aval_orientacao_descricao#','#arguments.pc_aval_orientacao_mcu_orgaoResp#',  CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#')
						SELECT SCOPE_IDENTITY() AS NewID;
					</cfquery>
					<cfset IDdaOriencaoCadastrada = qCadastraOrientacao.NewID>
					<cfset posicaoInicial = "Processo BLOQUEADO.<br>Este relatório aguarda a finalização de análises complementares do controle interno e/ou outros órgãos da empresa para liberação ao ÓRGÃO AVALIADO. Favor aguardar.">
					<cfset orgaoResp = ''>
					<cfset posic_status = 14>
					<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					<cfquery datasource="#dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status)
						VALUES (#IDdaOriencaoCadastrada#, '#posicaoInicial#',CONVERT(char, GETDATE(), 120),'#rsUsuario.pc_usu_matricula#','#rsUsuario.pc_usu_lotacao#', '#orgaoResp#','#dataCFQUERY#',#posic_status#)
					</cfquery>
				<cfelse>
					<cfquery datasource="#dsn_processos#"  name="qCadastraOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login,pc_aval_orientacao_dataPrevistaResp)
						VALUES (4, CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#',#arguments.pc_aval_id#, '#arguments.pc_aval_orientacao_descricao#','#arguments.pc_aval_orientacao_mcu_orgaoResp#',  CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#','#dataCFQUERY#')
						SELECT SCOPE_IDENTITY() AS NewID;
					</cfquery>
					<cfset IDdaOriencaoCadastrada = qCadastraOrientacao.NewID>
					<cfset posicaoInicial = "Para registro de sua manifestação orienta-se a atentar para as “Orientações/Medidas de Regularização” emitidas pela equipe de Controle Interno, bem como anexar no sistema SNCI as evidências de implementação das ações adotadas. Também solicita-se sua manifestação para as 'Propostas de Melhoria' conforme opções disponíveis no sistema.">
					<cfset orgaoResp = '#arguments.pc_aval_orientacao_mcu_orgaoResp#'>
					<cfset posic_status = 4>
					<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					<cfquery datasource="#dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status)
						VALUES (#IDdaOriencaoCadastrada#, '#posicaoInicial#',CONVERT(char, GETDATE(), 120),'#rsUsuario.pc_usu_matricula#','#rsUsuario.pc_usu_lotacao#', '#orgaoResp#','#dataCFQUERY#',#posic_status#)
					</cfquery>
				</cfif>
			</cfif>
		<!--Se for edição de uma orientação-->		
		<cfelse>
			<cfquery datasource="#dsn_processos#" >
				UPDATE 	pc_avaliacao_orientacoes
				SET    	pc_aval_orientacao_descricao = '#arguments.pc_aval_orientacao_descricao#',
						pc_aval_orientacao_atualiz_login = '#cgi.REMOTE_USER#'
				WHERE  	pc_aval_orientacao_id = #arguments.pc_aval_orientacao_id#	
			</cfquery>	
		</cfif>
		
		
  	</cffunction>

	
	
	
	<cffunction name="cadMelhorias"   access="remote"  returntype="any" hint="cadastra/edita as propostas de melhoria">
		
		<cfargument name="modalidade" type="string" required="true"/>
		<cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_melhoria_descricao" type="string" required="true"/>
		<cfargument name="pc_aval_melhoria_num_orgao" type="string" required="true"/>

		<cfargument name="pc_aval_melhoria_id" type="string" required="false" default=""/>

		<cfargument name="pc_aval_melhoria_dataPrev" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_sugestao" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_sug_orgao_mcu" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_naoAceita_justif" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_status" type="string"  required="false"  default=""/>
		
	
		<cfquery datasource="#dsn_processos#" >
			<cfif '#arguments.modalidade#' eq 'A' OR '#arguments.modalidade#' eq 'E'>
				<cfif #arguments.pc_aval_melhoria_id# eq ''>
					<cfif '#arguments.pc_aval_melhoria_dataPrev#' eq "">
						INSERT pc_avaliacao_melhorias (pc_aval_melhoria_num_aval,pc_aval_melhoria_descricao,pc_aval_melhoria_num_orgao, pc_aval_melhoria_datahora, pc_aval_melhoria_login, pc_aval_melhoria_sugestao, pc_aval_melhoria_sug_orgao_mcu, pc_aval_melhoria_naoAceita_justif, pc_aval_melhoria_sug_matricula, pc_aval_melhoria_status, pc_aval_melhoria_sug_datahora)
						VALUES (#arguments.pc_aval_id#,'#arguments.pc_aval_melhoria_descricao#','#arguments.pc_aval_melhoria_num_orgao#',  CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#','#arguments.pc_aval_melhoria_sugestao#', '#arguments.pc_aval_melhoria_sug_orgao_mcu#','#arguments.pc_aval_melhoria_naoAceita_justif#', '#rsUsuario.pc_usu_matricula#', '#arguments.pc_aval_melhoria_status#',CONVERT(char, GETDATE(), 120))
					<cfelse>
						INSERT pc_avaliacao_melhorias (pc_aval_melhoria_num_aval,pc_aval_melhoria_descricao,pc_aval_melhoria_num_orgao, pc_aval_melhoria_datahora, pc_aval_melhoria_login,pc_aval_melhoria_dataPrev, pc_aval_melhoria_sugestao, pc_aval_melhoria_sug_orgao_mcu, pc_aval_melhoria_naoAceita_justif, pc_aval_melhoria_sug_matricula, pc_aval_melhoria_status, pc_aval_melhoria_sug_datahora)
						VALUES (#arguments.pc_aval_id#,'#arguments.pc_aval_melhoria_descricao#','#arguments.pc_aval_melhoria_num_orgao#',  CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#','#arguments.pc_aval_melhoria_dataPrev#','#arguments.pc_aval_melhoria_sugestao#', '#arguments.pc_aval_melhoria_sug_orgao_mcu#','#arguments.pc_aval_melhoria_naoAceita_justif#', '#rsUsuario.pc_usu_matricula#', '#arguments.pc_aval_melhoria_status#',CONVERT(char, GETDATE(), 120))
					
					</cfif>
				<cfelse>
					UPDATE pc_avaliacao_melhorias
					SET    pc_aval_melhoria_descricao = '#arguments.pc_aval_melhoria_descricao#',
						pc_aval_melhoria_num_orgao = '#arguments.pc_aval_melhoria_num_orgao#',
						<cfif '#arguments.pc_aval_melhoria_dataPrev#' neq "">
							pc_aval_melhoria_dataPrev = '#arguments.pc_aval_melhoria_dataPrev#',
						<cfelse>
						    pc_aval_melhoria_dataPrev = null,
						</cfif>
						pc_aval_melhoria_sugestao = '#arguments.pc_aval_melhoria_sugestao#',
						pc_aval_melhoria_sug_orgao_mcu = '#arguments.pc_aval_melhoria_sug_orgao_mcu#',
						pc_aval_melhoria_naoAceita_justif = '#arguments.pc_aval_melhoria_naoAceita_justif#',
						pc_aval_melhoria_sug_matricula = '#rsUsuario.pc_usu_matricula#',
						pc_aval_melhoria_status = '#arguments.pc_aval_melhoria_status#',
						pc_aval_melhoria_sug_datahora = CONVERT(char, GETDATE(), 120)

					WHERE  pc_aval_melhoria_id = #arguments.pc_aval_melhoria_id#	
				</cfif>
			<cfelse>
				<cfif #arguments.pc_aval_melhoria_id# eq ''>
					INSERT pc_avaliacao_melhorias (pc_aval_melhoria_num_aval,pc_aval_melhoria_descricao,pc_aval_melhoria_num_orgao, pc_aval_melhoria_datahora, pc_aval_melhoria_login)
					VALUES (#arguments.pc_aval_id#,'#arguments.pc_aval_melhoria_descricao#','#arguments.pc_aval_melhoria_num_orgao#',  CONVERT(char, GETDATE(), 120), '#cgi.REMOTE_USER#')
				<cfelse>
					UPDATE pc_avaliacao_melhorias
					SET    pc_aval_melhoria_descricao = '#arguments.pc_aval_melhoria_descricao#',
						   pc_aval_melhoria_num_orgao = '#arguments.pc_aval_melhoria_num_orgao#'
					WHERE  pc_aval_melhoria_id = #arguments.pc_aval_melhoria_id#	
				</cfif>
			</cfif>


		</cfquery>
		
  	</cffunction>
	
	<cffunction name="delMelhorias"   access="remote" returntype="boolean" hint="exclui uma proposta de melhoria">

		<cfargument name="pc_aval_melhoria_id" type="numeric" required="true" default=""/>

		<cfquery datasource="#dsn_processos#" > 
			DELETE FROM pc_avaliacao_melhorias
			WHERE(pc_aval_melhoria_id = #arguments.pc_aval_melhoria_id#)
		</cfquery>
		<cfreturn true />
	</cffunction>







</cfcomponent>