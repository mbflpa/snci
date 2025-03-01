<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	


    <cffunction name="cardsPerfis"   access="remote" hint="enviar os cards dos perfis para a páginas pc_Pefis">
		<!DOCTYPE html>
		<html lang="pt-br">
		<head>	
			<style>
				#tabPerfisCards_wrapper #tabPerfisCards_paginate ul.pagination {
					justify-content: center!important;
				}
			</style>

		</head>
		<body>
			<div class="card-body" style="border: solid 3px #ffD400;">
					<cfquery name="rsPerfisCards" datasource="#application.dsn_processos#">
						SELECT pc_perfil_tipos.* from pc_perfil_tipos 
					</cfquery>	
					
					<table id="tabPerfisCards" class="table  " style="background: none;border:none;width:100%">
						
						<thead  class="table_thead_backgroundColor" >
							<tr style="background: none;border:none">
								<th style="background: none;border:none"></th>
							</tr>
						</thead>
						
						<tbody class="grid-container" >
														<cfloop query="rsPerfisCards">
								<tr style="width:270px; border:none">
									<td style="background: none; border:none">
										<cfquery name="rsQuantUsuariosPorPerfil" datasource="#application.dsn_processos#">
											SELECT pc_usu_perfil 
											FROM pc_usuarios 
											INNER JOIN pc_orgaos ON pc_org_mcu = pc_usu_lotacao
											WHERE pc_usu_perfil = #pc_perfil_tipo_id# AND pc_usu_status = 'A'
										</cfquery>
							
										<section class="content">
											<div id="cartaoPerfil" style="width:270px; border:none">
												<div class="small-box" style="font-weight: normal; background: <cfif '#pc_perfil_tipo_status#' eq 'A'>#0083CA<cfelse>gray</cfif>; color: #fff;">
													<div class="card-header" style="height:130px; width:250px; border-bottom:none; font-weight: normal!important">
														<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3>
															<p style="font-size:12px; margin-bottom: 0.2rem!important;">
																<strong><cfoutput>#pc_perfil_tipo_descricao#</strong> (id:#pc_perfil_tipo_id#)</cfoutput>
															</p>
														<cfelse>
															<p style="font-size:12px; margin-bottom: 0.2rem!important;">
																<strong><cfoutput>#pc_perfil_tipo_descricao#</strong></cfoutput>
															</p>
														</cfif>
														<cfif '#pc_perfil_tipo_status#' neq 'A'>
															<div align="center">
																<p style="font-size:12px; margin-bottom: 0!important;"><strong>DESATIVADO</strong></p>
															</div>
														</cfif>
														<div style="
															font-size:12px; 
															margin-bottom: 0!important; 
															text-align: justify; 
															margin-right: -18px; 
															overflow: hidden; 
															display: -webkit-box; 
															-webkit-line-clamp: 3; 
															-webkit-box-orient: vertical;">
															<cfoutput>#pc_perfil_tipo_comentario#</cfoutput>
														</div>
													</div>
													<div class="icon">
														<i class="fas fa-users" style="opacity:0.6; left:100px; top:30px; font-size:70px"></i>
													</div>
							
													<a href="##" target="_self" class="small-box-footer">
														<div style="display:flex; justify-content: space-around;">
															<input id="pcNumProcessoCard" name="pcNumProcessoCard" type="text" hidden>
															<cfoutput>
																<i  id="btEdit" 
																	class="fas fa-edit efeito-grow edit-perfil" 
																	style="cursor: pointer; z-index:100; font-size:16px"
																	data-id='#pc_perfil_tipo_id#'
																	data-descricao='#pc_perfil_tipo_descricao#'
																	data-comentario='#pc_perfil_tipo_comentario#'
																	data-status='#pc_perfil_tipo_status#'
																	data-toggle='tooltip' 
																	title='Editar'>
																</i>

																<i id="btUsuarios" class="fas fa-users efeito-grow" style="cursor: pointer; z-index:100; font-size:16px"
																	onclick="javascript:mostraTabUsuariosPerfis(<cfoutput>#pc_perfil_tipo_id#</cfoutput>);" 
																	data-toggle="tooltip" title="Usuarios"> 
																	= #rsQuantUsuariosPorPerfil.recordcount#
																</i>
															</cfoutput>
														</div>
													</a>
												</div>
											</div>
										</section>
									</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
			</div>
		</body>

				<script language="JavaScript">
					$(function () {
						$("#tabPerfisCards").DataTable({
							"destroy": true,
							"ordering": false,
							"stateSave": false,
							"responsive": true, 
							"lengthChange": true, 
							"sScrollY": "32em",
							"autoWidth":true,
							"dom": 
									"<'row'<'col-sm-12 text-right'f>>" +
									"<'row'<'col-sm-4'l><'col-sm-4'p><'col-sm-4 text-right'i>>" +
									"<'row'<'col-sm-12'tr>>" ,
							"lengthMenu": [
								[10, 25, 50, -1],
								[10, 25, 50, 'All'],
							],
							language: {url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"}
						})
							
					});

					$(document).ready(function() {
						// Captura o clique em todos os elementos com a classe 'edit-perfil'
						$(".edit-perfil").on("click", function(event) {
							event.preventDefault();
							event.stopPropagation();

							// Obtém os dados dos atributos data-*
							const perfilId = $(this).data('id');
							const perfilDescricao = $(this).data('descricao');
							const perfilComentario = $(this).data('comentario');
							const perfilStatus = $(this).data('status');

							// Chama a função perfilEditar com os dados obtidos
							perfilEditar(perfilId, perfilDescricao, perfilComentario, perfilStatus);
						});
					});

					function mostraTabUsuariosPerfis(perfilId){
				
						$('#modalOverlay').modal('show')
						setTimeout(function() {
							$.ajax({
								type: "post",
								url: "cfc/pc_cfcPaginasApoio.cfc",
								data:{
									method: "tabUsuariosPerfis",
									pc_perfil_tipo_id:perfilId
								},
								async: false
							})//fim ajax
							.done(function(result) {
								$('#tabUsuariosPerfisDiv').html(result)
								$('html, body').animate({ scrollTop: ($('#tabUsuariosPerfisDiv').offset().top - 80)} , 1000);
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
						}, 500);//fim setTimeout
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});

					}
					




				</script>
		</html>
	</cffunction>


	<cffunction name="cadPerfil"   access="remote"  returntype="any" hint="cadastra/edita as propostas de melhoria">
		<cfargument name="pc_perfil_tipo_id" type="string" required="false"/>
		<cfargument name="pc_perfil_tipo_descricao" type="string" required="true"/>
		<cfargument name="pc_perfil_tipo_comentario" type="string" required="true"/>
		<cfargument name="pc_perfil_tipo_status" type="string" required="false"  default='A'/>
		

		<cfquery datasource="#application.dsn_processos#" >
			<cfif #arguments.pc_perfil_tipo_id# eq ''>
				INSERT pc_perfil_tipos (pc_perfil_tipo_descricao, pc_perfil_tipo_comentario)
				VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_perfil_tipo_descricao#">
						,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.pc_perfil_tipo_comentario#">)
			<cfelse>
				UPDATE pc_perfil_tipos
				SET    pc_perfil_tipo_descricao =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_perfil_tipo_descricao#">,
					   pc_perfil_tipo_comentario = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.pc_perfil_tipo_comentario#">,
					   pc_perfil_tipo_status =     <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_perfil_tipo_status#">
				WHERE  pc_perfil_tipo_id =         <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_perfil_tipo_id#">	
			</cfif>
		</cfquery>
		
  	</cffunction>


	<cffunction name="tabUsuariosPerfis" returntype="any" access="remote" hint="Criar a tabela de usuarios por perfil e envia para a páginas pc_Perfis">
        
	    <cfargument name="pc_perfil_tipo_id" type="numeric" required="true"/>

		 <cfquery datasource="#application.dsn_processos#" name="rsPerfilSelecionado">
			Select pc_perfil_tipos.pc_perfil_tipo_descricao from pc_perfil_tipos
			WHERE pc_perfil_tipo_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_perfil_tipo_id#">
		</cfquery>

        <cfquery datasource="#application.dsn_processos#" name="rsUsuariosPerfis">
			Select pc_usuarios.*, pc_perfil_tipos.*, pc_orgaos.pc_org_sigla from pc_usuarios
			INNER JOIN pc_perfil_tipos on pc_perfil_tipo_id = pc_usu_perfil
			INNER JOIN pc_orgaos ON pc_org_mcu = pc_usu_lotacao
			WHERE pc_usu_perfil = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_perfil_tipo_id#">
			and pc_usu_status = 'A'
			order By pc_usu_nome  asc
		</cfquery>
		<session class="content-header"  >
			<session class="card-body" >
				<form id="formTabUsuariosPerfis" format="html"  style="height: auto;" style="margin-bottom:100px">
					<div class="row">
						<div class="col-12">
							<div class="card">
								<!-- /.card-header -->
								<div class="card-body">
									<h5 class="azul_claro_correios_textColor" >Usuários Cadastrados com o Perfil: <strong><cfoutput>#rsPerfilSelecionado.pc_perfil_tipo_descricao#</cfoutput> </strong></h5>
									<table id="tabUsuariosPerfis" class="table table-striped table-hover text-nowrap  table-responsive ">
										<thead  class="table_thead_backgroundColor">
											<tr style="font-size:14px">
												<th>Matrícula:</th>
												<th>Nome:</th>
												<th>Perfil:</th>
												<th>Lotação:</th>
											</tr>
										</thead>
									
										<tbody>
											<cfloop query="rsUsuariosPerfis" >
												<cfoutput>					
													<tr style="font-size:14px;color:##000" >
														<td style="width:10%">#pc_usu_matricula#</td>
														<td>#pc_usu_nome#</td>
														<td>#pc_perfil_tipo_descricao#</td>
														<td >#pc_org_sigla#</td>
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
				</form>
			</session>
		</session>	
		<script language="JavaScript">
			$(function () {
				
				$("#tabUsuariosPerfis").DataTable({
					"destroy": true,
					"stateSave": false,
					"responsive": true, 
					"lengthChange": true, 
					"autoWidth": false,
					"buttons": [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						className: 'btExcel',
					},],
					language: {url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"}
				}).buttons().container().appendTo('#tabUsuariosPerfis_wrapper .col-md-6:eq(0)');
					
			});

			

		</script>				
			
			
	

	</cffunction>


	<cffunction name="cadUsuario"   access="remote"  returntype="any" hint="cadastra/edita usuarios">
		<cfargument name="usuarioEditar" type="string"  required="false" />
		<cfargument name="pc_usu_matricula" type="string" required="true"/>
		<cfargument name="pc_usu_Nome" type="string" required="true"/>
		<cfargument name="pc_usu_status" type="string" required="false"  default='A'/>
		<cfargument name="pc_usu_lotacao" type="string" required="true"/>
		<cfargument name="pc_usu_perfil" type="numeric" required="true"/>
		<cfset login = 'CORREIOSNET\' & #arguments.pc_usu_matricula#>

		<cfquery datasource="#application.dsn_processos#" >
			<cfif #arguments.usuarioEditar# eq ''>
				INSERT pc_usuarios (pc_usu_matricula, pc_usu_Nome, pc_usu_login, pc_usu_lotacao, pc_usu_perfil, pc_usu_atualiz_datahora, pc_usu_atualiz_matricula)
				VALUES (
					<cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pc_usu_Nome#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#login#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pc_usu_perfil#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">
				)

			
			
			
			<cfelse>
				UPDATE pc_usuarios
				SET pc_usu_Nome = <cfqueryparam value="#arguments.pc_usu_Nome#" cfsqltype="cf_sql_varchar">,
					pc_usu_login = <cfqueryparam value="#login#" cfsqltype="cf_sql_varchar">,
					pc_usu_lotacao = <cfqueryparam value="#arguments.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
					pc_usu_perfil = <cfqueryparam value="#arguments.pc_usu_perfil#" cfsqltype="cf_sql_integer">,
					pc_usu_status = <cfqueryparam value="#arguments.pc_usu_status#" cfsqltype="cf_sql_varchar">
				WHERE pc_usu_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfquery>
		
  	</cffunction>


	<cffunction name="delUsuario" access="remote"  returntype="any" returnformat="json" hint="Exclui usuários. Disponível apenas para perfil desenvolvedores">
		
		<cfargument name="pc_usu_matricula" type="string" required="true"/>
		
		<!--- Verifica se o usuário existe nas tabelas relacionadas --->
		<cfquery name="checkUserDependencies" datasource="#application.dsn_processos#">
			SELECT 
				(SELECT COUNT(*) FROM pc_processos WHERE pc_usu_matricula_cadastro = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar"> or pc_usu_matricula_coordenador = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar"> or pc_usu_matricula_coordenador_nacional = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">) AS processo_count,
				(SELECT COUNT(*) FROM pc_avaliacoes WHERE pc_aval_avaliador_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">) AS avaliacao_count,
				(SELECT COUNT(*) FROM pc_avaliadores WHERE pc_avaliador_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">) AS avaliador_count,
				(SELECT COUNT(*) FROM pc_avaliacao_posicionamentos WHERE pc_aval_posic_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">) AS posicionamento_count,
				(SELECT COUNT(*) FROM pc_avaliacao_distribuicoes WHERE pc_aval_dist_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">) AS distribuicao_count,
				(SELECT COUNT(*) FROM pc_indicadores_dados WHERE pc_indDados_matriculaGeracao = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">) AS indicador_count
		</cfquery>
		
		<!--- Verifica se o usuário tem dependências nas tabelas relacionadas --->
		<cfif checkUserDependencies.processo_count GT 0 OR 
			checkUserDependencies.avaliacao_count GT 0 OR 
			checkUserDependencies.avaliador_count GT 0 OR 
			checkUserDependencies.posicionamento_count GT 0 OR
			checkUserDependencies.distribuicao_count GT 0 OR
			checkUserDependencies.indicador_count GT 0>
			
			<!--- Se existir dependências, retorna mensagem de erro --->
			<cfset exclusao = false>	
		<cfelse>
			<!--- Se não existir dependências, realiza a exclusão --->
			<cfquery datasource="#application.dsn_processos#">
				DELETE FROM pc_usuarios
				WHERE pc_usu_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<!--- Retorna mensagem de sucesso --->
			<cfset exclusao = true>
		</cfif>
		<cfreturn serializeJSON(exclusao)>
	</cffunction>

	<cffunction name="getUsuariosJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfquery name="rsCadUsuarios" datasource="#application.dsn_processos#">
			SELECT pc_usuarios.*, pc_orgaos.*, pc_perfil_tipos.* FROM pc_usuarios 
			left JOIN pc_orgaos ON pc_org_mcu = pc_usu_lotacao
			INNER JOIN pc_perfil_tipos on pc_perfil_tipo_id = pc_usu_perfil
			ORDER BY pc_usuarios.pc_usu_nome
		</cfquery>

		
		<cfset usuarios = []>
		
		<cfloop query="rsCadUsuarios">
			<cfset usuario = {}>
			<cfset usuario.PC_USU_MATRICULA = rsCadUsuarios.pc_usu_matricula>
			<cfset usuario.PC_USU_NOME = rsCadUsuarios.pc_usu_nome>
			<cfset usuario.PC_PERFIL_TIPO_DESCRICAO = rsCadUsuarios.pc_perfil_tipo_descricao>
			<cfset usuario.PC_ORG_SIGLA = rsCadUsuarios.pc_org_sigla>
			<cfset usuario.PC_USU_LOGIN = rsCadUsuarios.pc_usu_login>
			<cfset usuario.PC_USU_STATUS = rsCadUsuarios.pc_usu_status>
			<cfset usuario.PC_USU_MCU = rsCadUsuarios.pc_usu_lotacao>
			<cfset usuario.PC_USU_TIPO_ID = rsCadUsuarios.pc_perfil_tipo_id>
			<cfset arrayAppend(usuarios, usuario)>
		</cfloop>
		
		<cfreturn usuarios>
	</cffunction>


	<cffunction name="verificaMatricula"   access="remote"  hint="verifica se matrícula já existe no cadastro de usuários">

		<cfargument name="pc_usu_matricula" type="string" required="true"/>

		<cfquery datasource="#application.dsn_processos#" name="rsExisteMatricula">
			Select pc_usuarios.pc_usu_matricula from pc_usuarios
			WHERE pc_usu_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<div>
		<cfif #rsExisteMatricula.recordcount# eq 0>
			<input id="matriculaCadastrada" value="no" hidden>
		<cfelse>
			<input id="matriculaCadastrada" value="yes" hidden>
		</cfif>
		</div>
		
	</cffunction>



	<cffunction	 name="DataPrevistaSolucao" returntype="struct" hint="Gera data prevista para solução pelo órgão.">
		<cfargument name="Prazo" type="numeric" required="yes"/>
		<cfargument name="MostraDump" type="string"  default="no" /><!---yes ou no ou não informar--->
			
		<cfset dtatual = CreateDate(year(now()),month(now()),day(now()))>
		<cfset dtnovoprazo = DateAdd("d", '#Prazo#', #dtatual#)>
		<cfset nCont = 1>
		<cfset nDiasSomar = 0>
		<cfloop condition="nCont lt Prazo">
			<cfquery name="rsFeriado" datasource="#application.dsn_processos#">
				SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo#
			</cfquery>
			<cfdump var= '#rsFeriado#' />
			<cfif rsFeriado.recordcount gt 0>
					<cfset nDiasSomar = nDiasSomar + 1>
			<cfelse>
					<cfset vDiaSem = DayOfWeek(dtnovoprazo)>
					<cfswitch expression="#vDiaSem#">
							<cfcase value="1">
									<!--- domingo --->
									<cfset nDiasSomar = nDiasSomar + 1>
							</cfcase>
								<cfcase value="7">
									<!--- sábado --->
									<cfset nDiasSomar = nDiasSomar + 1>
								</cfcase>
					</cfswitch>
			</cfif>
			<cfset dtnovoprazo = DateAdd("d", #nCont#, #dtatual#)> 
			<!--- <cfset dtnovoprazo = DateAdd("d", 1, #dtatual#)>--->
			<cfset nCont = nCont + 1>
			
			<cfif '#nCont#' eq '#Prazo#'>
					<cfset Prazo2 = Prazo + nDiasSomar>
					<cfset dtnovoprazo2 = DateAdd("d", #Prazo2#, #dtatual#)>
					<cfquery name="rsFeriado" datasource="#application.dsn_processos#">
						SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo2#
					</cfquery>
					<cfset vDiaSem = DayOfWeek(dtnovoprazo2)>
				
					<cfif vDiaSem eq 1 || vDiaSem eq 7 || rsFeriado.recordcount neq 0>
						<cfset Prazo =Prazo + 1>
						<cfset nDiasSomar = nDiasSomar + 1>
					</cfif>
			</cfif>

		</cfloop>
		<!--- fim loop --->
		<cfset Prazo = Prazo + nDiasSomar>
		<cfset dtnovoprazo = DateAdd("d", #Prazo#, #dtatual#)>

		<cfset novaData = StructNew()/>
		<cfset novaData.Dias_somat = nDiasSomar/>  
		<cfset novaData.Prazo =Prazo/>  
		<cfset novaData.Data_Prevista =  CreateDate(Year(#dtnovoprazo#),Month(#dtnovoprazo#),Day(#dtnovoprazo#))/>		   
		<cfset novaData.Data_Prevista_Formatada = DateFormat(#dtnovoprazo#,"DD/MM/YYYY")/>   
					
		<cfset result = '#novaData#' />
		<cfif "#trim(arguments.MostraDump)#" eq 'yes'>
			<cfdump var= '#result#' />
		</cfif> 			   
					
					
		<cfreturn result />
	</cffunction>

	<cffunction name="obterDataPrevista" access="public" returntype="struct" hint="Gera data prevista para solução pelo órgão.">
		<cfargument name="qtdDias" type="numeric" required="true">
		<cfargument name="mostraDump" type="string"  default="no" /><!---yes ou no ou não informar--->
		
		<cfset dataAtual = CreateDate(year(now()),month(now()),day(now()))>
		<cfset dataFutura = dateAdd("d", 0, dataAtual)>
		<cfset diasUteis = 0>
		<cfset feriados = ''>
		<cfset sabadosEdomingos = 0>
		<cfloop condition="diasUteis lt qtdDias">
		     <cfset dataFutura = dateAdd("d", 1, dataFutura)>		
			<!--- Verifica se a data é sábado, domingo ou feriado --->
			<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio">
			<cfinvoke component="#pc_cfcPaginasApoio#" method="isFeriado" returnVariable="isFeriado" data= '#dataFutura#' />
			<cfif dayOfWeek(dataFutura) neq 1 and dayOfWeek(dataFutura) neq 7 and isFeriado neq true>
			    <cfset diasUteis = diasUteis + 1>
			</cfif>
			<cfif isFeriado eq true>
                <cfset feriados = listAppend(feriados, DateFormat(#dataFutura#,"DD/MM/YYYY"))>
			</cfif>
			<cfif dayOfWeek(dataFutura) eq 1 or dayOfWeek(dataFutura) eq 7 >
				<cfset sabadosEdomingos = sabadosEdomingos + 1>
			</cfif>
		</cfloop>
		
		<cfset novaData = StructNew()/>
		<cfset novaData.Dias_Uteis =qtdDias/>  
		<cfset novaData.Data_Prevista =  CreateDate(year(dataFutura),month(dataFutura),day(dataFutura))/>		   
		<cfset novaData.Data_Prevista_Formatada = DateFormat(#dataFutura#,"DD/MM/YYYY")/> 
		<cfset novaData.Sabados_e_Domingos = sabadosEdomingos/>
		<cfset novaData.Feriados = feriados/>

		<cfset result = '#novaData#' />
		<cfif "#trim(arguments.mostraDump)#" eq 'yes'>
			<cfdump var= '#result#' />
		</cfif> 

		<cfreturn result />

	</cffunction>
	
	<cffunction name="isFeriado" access="public" returntype="boolean">
		<cfargument name="data" type="date" required="true">
		
		<cfset isFeriado = false>
		
		<cfquery name="rsFeriado" datasource="#application.dsn_processos#">
			SELECT Fer_Data FROM FeriadoNacional WHERE Fer_Data = <cfqueryparam cfsqltype="cf_sql_date" value="#data#">
		</cfquery>
		
		<cfif rsFeriado.recordCount gt 0>
			<cfset isFeriado = true>
		</cfif>
		
		<cfreturn isFeriado>
	</cffunction>

	



	<cffunction name="rotinaDiariaOrientacoesSuspensas" access="remote"  hint="Utilizado nas rotinas manuais. Verifica os pontos suspensos vencidos e transforma em TRATAMENTO, insere um posicionamento e envia um e-mail de alerta.">
		<cfquery name="rsPontoSuspensoPrazoVencido" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_orientacoes.*, pc_avaliacoes.pc_aval_processo
			FROM pc_avaliacao_orientacoes
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			WHERE pc_aval_orientacao_status = 16 and DATEDIFF(DAY, pc_aval_orientacao_dataPrevistaResp, GETDATE()) >0
		</cfquery>


		<cfoutput query= "rsPontoSuspensoPrazoVencido" >
						
			<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio"/>
			<cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias='15' />
			<cfset posicionamento = "Prezado gestor,<br>Solicita-se atualizar as informações do andamento das ações para regularização do item apontado considerando sua última manifestação quanto as tratativas com órgão externo. Incluir no SNCI as evidências das tratativas/ações adotadas."/>						
			<cfset dataCFQUERY = "#DateFormat(obterDataPrevista.Data_Prevista,'YYYY-MM-DD')#">	
			
			<cftransaction >

				<cfquery datasource="#application.dsn_processos#">
					UPDATE pc_avaliacao_orientacoes 
					SET    
						pc_aval_orientacao_status = 5,
						pc_aval_orientacao_dataPrevistaResp =#obterDataPrevista.Data_Prevista#
					WHERE pc_aval_orientacao_id = #pc_aval_orientacao_id#
				</cfquery>

				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado)
					VALUES (
							<cfqueryparam value="#pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
							,<cfqueryparam value="#posicionamento#" cfsqltype="cf_sql_varchar">
							,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
							,'99999999'
							,'00438080'
							,'#pc_aval_orientacao_mcu_orgaoResp#'
							,'#dataCFQUERY#'
							,5
							,1
						)
				</cfquery>

				
				<!--Informações do órgão responsável-->
				<cfquery name="rsOrgaoResp" datasource="#application.dsn_processos#">
					SELECT pc_org_emaiL, pc_org_sigla FROM pc_orgaos
					WHERE pc_org_mcu = <cfqueryparam value="#pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">
				</cfquery>
				
				<cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
					<cfset to = "#application.rsUsuarioParametros.pc_usu_email#">
					
				</cfif>
					
				<cfset de="SNCI@correios.com.br">
				<cfif FindNoCase("localhost", application.auxsite)>
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>

				<cfset to = "#LTrim(RTrim(rsOrgaoResp.pc_org_email))#">
				<cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
					<cfset to = "#application.rsUsuarioParametros.pc_usu_email#">
				</cfif>

				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrgaoResp.pc_org_sigla))#">
				<cfset pronomeTrat = "Senhor(a) Gestor(a) do(a) #siglaOrgaoResponsavel#">
				
				<cfset textoEmail = '<p<cfset textoEmail =>Solicita-se atualizar as informações do andamento das ações para regularização da Orientação ID #pc_aval_orientacao_id#, no processo SNCI N° #pc_aval_processo#, considerando sua última manifestação quanto as tratativas com órgão externo. Incluir no SNCI as evidências das tratativas/ações adotadas.</p> 
										<p>Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "MEDIDAS/ORIENTAÇÕES PARA REGULARIZAÇÃO " e inserir sua resposta:</p>
										<p style="text-align:center;">
											<a href="http://intranetsistemaspe/snci/snci_processos/index.cfm" style="background-color:##00416B; color:##ffffff; padding:10px 20px; text-decoration:none; border-radius:5px; display:inline-block;">Acessar SNCI - Processos</a>
										</p>'>
							
				<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
				<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
							para = "#to#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
				/>
					

				
			</cftransaction>
			

		</cfoutput>
	</cffunction>


	<cffunction name="rotinaSemanalOrientacoesPendentesSemTab" access="remote"  hint="Verifica or órgãos responsáveis pelas orientações pendentes e encaminha e-mail de alerta.">
		
		<cfquery name="rsOrgaosComOrientacoesPendentes" datasource="#application.dsn_processos#" >
			SELECT DISTINCT pc_aval_orientacao_mcu_orgaoResp
			FROM pc_avaliacao_orientacoes
			WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) 
			and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null 
			and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
		</cfquery>

		<cfquery name="rsOrgaosComOrientacoesPendentesParaTeste" datasource="#application.dsn_processos#">
			SELECT DISTINCT TOP 5 pc_aval_orientacao_mcu_orgaoResp
			FROM pc_avaliacao_orientacoes
			WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
		</cfquery>


		<cfif FindNoCase("intranetsistemaspe", application.auxsite)>
			<cfset myQuery = "rsOrgaosComOrientacoesPendentes">
		<cfelse>
			<cfset myQuery = "rsOrgaosComOrientacoesPendentesParaTeste">
		</cfif>

		<cfloop query="#myQuery#">
            <cfif Len(Trim(pc_aval_orientacao_mcu_orgaoResp))>            
				<cfquery name="rsOrientacoesPendentes" datasource="#application.dsn_processos#" >
					SELECT  pc_avaliacao_orientacoes.pc_aval_orientacao_id 
							,pc_orientacao_status.pc_orientacao_status_descricao
							,pc_avaliacoes.pc_aval_numeracao
							,pc_processos.pc_processo_id 
							,pc_processos.pc_num_sei
							,pc_processos.pc_num_rel_sei
							,pc_processos.pc_num_avaliacao_tipo
							,pc_avaliacao_tipos.pc_aval_tipo_descricao
							,pc_processos.pc_aval_tipo_nao_aplica_descricao
							,pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp 
							,pc_avaliacao_orientacoes.pc_aval_orientacao_status 
							,orgaoAvaliado.pc_org_mcu as mcuOrgaoAvaliado
							,orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
							,orgaoAvaliado.pc_org_emaiL as emailOrgaoAvaliado
							,orgaoResp.pc_org_mcu as mcuOrgaoResp
							,orgaoResp.pc_org_sigla as siglaOrgaoResp
							,orgaoResp.pc_org_emaiL as emailOrgaoResp
					FROM pc_avaliacao_orientacoes
					LEFT JOIN pc_avaliacoes on pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval
					LEFT JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
					LEFT JOIN pc_avaliacao_tipos on pc_aval_tipo_id = pc_processos.pc_num_avaliacao_tipo
					LEFT JOIN pc_orientacao_status on pc_orientacao_status_id = pc_avaliacao_orientacoes.pc_aval_orientacao_status
					LEFT JOIN pc_orgaos as orgaoAvaliado on orgaoAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
					LEFT JOIN pc_orgaos as orgaoResp on orgaoResp.pc_org_mcu = pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp

					WHERE pc_aval_orientacao_mcu_orgaoResp = '#pc_aval_orientacao_mcu_orgaoResp#' and pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate() 
					ORDER BY pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp
				</cfquery>

				<cfquery name="rsOrientacoesOutrosStatus" datasource="#application.dsn_processos#" >
					SELECT  pc_avaliacao_orientacoes.pc_aval_orientacao_id, pc_orientacao_status.pc_orientacao_status_descricao                
					FROM pc_avaliacao_orientacoes
					right JOIN pc_orientacao_status on pc_orientacao_status_id = pc_avaliacao_orientacoes.pc_aval_orientacao_status
					WHERE pc_aval_orientacao_mcu_orgaoResp = '#pc_aval_orientacao_mcu_orgaoResp#' and (pc_avaliacao_orientacoes.pc_aval_orientacao_status in (2,16)  or (pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp >= getdate()))
				</cfquery>

				<!-- Verifica se o e-mail é válido e não está em branco -->
				<cfif IsValid("email", rsOrientacoesPendentes.emailOrgaoResp) and Len(Trim(rsOrientacoesPendentes.emailOrgaoResp))>
						<cfset to = rsOrientacoesPendentes.emailOrgaoResp>
						
						<cfif IsValid("email", rsOrientacoesPendentes.emailOrgaoAvaliado) and Len(Trim(rsOrientacoesPendentes.emailOrgaoAvaliado))>
							<cfset cc = rsOrientacoesPendentes.emailOrgaoAvaliado>
						<cfelse>
							<cfset cc = "">
						</cfif>

						<cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>

							<cfset mensagemParaTeste="Atenção, este é um e-mail de teste! No servidor de produção, este e-mail seria encaminhado para <strong>#to#</strong> pois é o e-mail do órgão responsável pelas orientações, com cópia para <strong>#cc#</strong> pois é o e-mail do órgão avaliado.">
							<cfset to = "#application.rsUsuarioParametros.pc_usu_email#">
							<cfset cc = "">
						</cfif>
							
						<cfset de="SNCI@correios.com.br">
						<cfif FindNoCase("localhost", application.auxsite)>
							<cfset de="mbflpa@yahoo.com.br">
						</cfif>
					
						
						<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrientacoesPendentes.siglaOrgaoResp))#">
						<cfset pronomeTrat = "Senhor(a) Gestor(a) do(a) #siglaOrgaoResponsavel#">
						<cfmail from="#de#" to="#to#" cc="#cc#" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
														<!DOCTYPE html>
							<html lang="pt-br">
							<head>
								<meta charset="UTF-8">
								<meta http-equiv="X-UA-Compatible" content="IE=edge">
								<meta name="viewport" content="width=device-width, initial-scale=1.0">
								<title>SNCI - Sistema Nacional de Controle Interno</title>
							</head>
							<body style="Margin:0; padding:0; background-color:##ffffff;">
								<cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
									<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#mensagemParaTeste#</pre>
								</cfif>
								<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:##ffffff;">
									<tr>
										<td align="center" style="padding: 20px 0;">
											<table width="600" cellpadding="0" cellspacing="0" border="0" style="border:1px solid ##0083CA; border-radius:5px; overflow:hidden;">
												<!-- Cabeçalho do Card com Imagem -->
												<tr>
													<td align="center" bgcolor="##00416B" style="padding:20px; background-color:##00416B;">
														<table width="100%" cellpadding="0" cellspacing="0" border="0">
															<tr>
																<td align="left" style="vertical-align: middle;text-align: center;">
																	<h2 style="margin:0; color:##ffffff; font-family: Arial, sans-serif; font-size:20px;">
																		SNCI - Sistema Nacional de Controle Interno<br>Módulo: Processos
																	</h2>
																</td>
															</tr>
														</table>
													</td>
												</tr>
												<!-- Corpo do E-mail -->
												<tr>
													<td style="padding:20px; font-family: Arial, sans-serif; color:##212529; font-size:14px; line-height:1.5;">
														<p style="margin:0 0 10px 0; text-align: justify;">#pronomeTrat#,</p>
														
														<cfif rsOrientacoesPendentes.recordcount eq 1>
															<p style="text-align: justify;">Informamos que existe #NumberFormat(rsOrientacoesPendentes.recordcount, "00")# apontamento registrado pelo Controle Interno, status <strong>PENDENTE</strong>, com prazo de resposta expirado no Sistema SNCI - Processos, ao qual solicitamos especial atenção.</p>
														<cfelseif rsOrientacoesPendentes.recordcount gt 1>
															<p style="text-align: justify;">Informamos que existem #NumberFormat(rsOrientacoesPendentes.recordcount, "00")# apontamentos registrados pelo Controle Interno, status <strong>PENDENTE</strong>, com prazo de resposta expirado no Sistema SNCI - Processos, aos quais solicitamos especial atenção.</p>
														</cfif>
									
														<p style="text-align: justify;">Para regularizar a situação, solicitamos acessar o link abaixo, tela <strong>Acompanhamento</strong>, aba <strong>Medidas / Orientações para regularização</strong> e inserir sua resposta:</p>
														
														<p style="text-align:center;">
															<a href="http://intranetsistemaspe/snci/snci_processos/index.cfm" style="background-color:##00416B; color:##ffffff; padding:10px 20px; text-decoration:none; border-radius:5px; display:inline-block;">Acessar SNCI - Processos</a>
														</p>
									
														<p style="text-align: justify;">Atentar para as ORIENTAÇÕES para Regularização citadas no Sistema para desenvolvimento de sua resposta. Ainda, orienta-se a inserir as comprovações das ações adotadas no Sistema.</p>
														<p style="text-align: justify;">Ressalta-se que a implementação do plano de ação será acompanhada pelo CONTROLE INTERNO.</p>
									
														<cfif rsOrientacoesOutrosStatus.recordcount gt 1>
															<p style="text-align: justify;">Na oportunidade informa-se que existem, ainda, #NumberFormat(rsOrientacoesOutrosStatus.recordcount, "00")# orientações de Controle Interno com outros status que estão dentro do prazo previsto. Para esses casos orienta-se a atentar para a DATA PREVISTA PARA RESPOSTA, registrada no SNCI. Essa é a data em que se encerra o prazo para registro das manifestações no sistema SNCI, com acesso pelo mesmo link acima, conforme orientações anteriores.</p>
														<cfelseif rsOrientacoesOutrosStatus.recordcount eq 1>
															<p style="text-align: justify;">Na oportunidade informa-se que existe, ainda, #NumberFormat(rsOrientacoesOutrosStatus.recordcount, "00")# orientação de Controle Interno com status "#rsOrientacoesOutrosStatus.pc_orientacao_status_descricao#" que está dentro do prazo previsto. Para esse caso orienta-se a atentar para a DATA PREVISTA PARA RESPOSTA, registrada no SNCI. Essa é a data em que se encerra o prazo para registro das manifestações no sistema SNCI, com acesso pelo mesmo link acima, conforme orientações anteriores.</p>
														</cfif>
									
														<p style="margin-top:20px; text-align: justify;">Estamos à disposição para prestar informações adicionais a respeito do assunto, caso seja necessário.</p>
									
													</td>
												</tr>
												<!-- Rodapé do Card -->
												<tr>
													<td bgcolor="##f2f2f2" style="padding:10px; text-align:center; font-family: Arial, sans-serif; font-size:12px; color:##212529;">
														<p>CS/DIGOE/SUGOV/DCINT/GACE - Gerência de Avaliações de Controles Especiais</p>
														<p>Este é um e-mail automático, por favor não responda.</p>
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</table>
							</body>
							</html>
						</cfmail>
				</cfif>		
			</cfif>		

			
		</cfloop>


	</cffunction>
	

	<cffunction name="EnviaEmails" access="public" returntype="string" hint="Cria o formado dos e-mails e envia. Utilizado nas rotinas manuais. Se não for executado em produção, o email será enviado parao usuário que executou">
            
        <cfargument name="para" type="string" required="true">
        <cfargument name="copiaPara" type="string" required="false" default="">
        <cfargument name="pronomeTratamento" type="string" required="true">
        <cfargument name="texto" type="string" required="true">

        <cfset to = "#arguments.para#">
		<cfset cc = "">
		<cfif isdefined("arguments.copiaPara") and arguments.copiaPara neq "" and (arguments.copiaPara neq arguments.para)>
			<cfset cc = "#arguments.copiaPara#">
		</cfif> 

        <cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
			<cfif #cc# neq "" >
				<cfset mensagemParaTeste="Atenção, este é um e-mail de teste! No servidor de produção, este e-mail seria encaminhado para <strong>#to#</strong>, com cópia para <strong>#cc#</strong>.">
			<cfelse>
				<cfset mensagemParaTeste="Atenção, este é um e-mail de teste! No servidor de produção, este e-mail seria encaminhado para <strong>#to#</strong>.">
			</cfif>
			<cfset to = "#application.rsUsuarioParametros.pc_usu_email#">
			<cfset cc = "">
        </cfif>

		<cftry> 
			<cfset de="SNCI@correios.com.br">
		    <cfif FindNoCase("localhost", application.auxsite)>
				<cfset de="mbflpa@yahoo.com.br">
			</cfif>
			<cfmail from="#de#" to="#to#" cc="#cc#" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
				<!DOCTYPE html>
				<html lang="pt-br">
				<head>
					<meta charset="UTF-8">
					<meta http-equiv="X-UA-Compatible" content="IE=edge">
					<meta name="viewport" content="width=device-width, initial-scale=1.0">

					<style>
						
						
						
						
						.card {
							position: relative;
							display: flex;
							flex-direction: column;
							min-width: 0;
							word-wrap: break-word;
							background: rgba(0, 65, 107, 1);
							color: rgba(255, 255, 255, 1);
							background-clip: border-box;
							border: 0 solid rgba(0, 0, 0, 0.125);
							border-radius: 0.25rem;
							box-shadow: 0px 0px 10px rgba(136, 136, 136, 1); 
							margin: 0 auto;
							float: left;
							margin-left: 10px;
							padding: 20px;
							max-width: 800px;
						}

						.card-header {
							background-color: rgba(255, 255, 255, 1); 
							color: rgba(0, 65, 107, 1); 
							border-radius: 10px;
							box-shadow: 0px 0px 10px rgba(136, 136, 136, 1); 
							text-align: center;
							font-size: 20px;
						}

						.rodape{
							background-color: rgba(255, 255, 255, 1); 
							color: rgba(0, 65, 107, 1); 
							border-radius: 10px;
							box-shadow: 0px 0px 10px rgba(136, 136, 136, 1); 
							text-align: center;
							margin-top: 20px;
							}

						
					</style>
				</head>
				<body style="Margin:0; padding:0; background-color:##ffffff;">
					<cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
						<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#mensagemParaTeste#</pre>
					</cfif>
						<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:##ffffff;">
							<tr>
								<td align="center" style="padding: 20px 0;">
									<table width="600" cellpadding="0" cellspacing="0" border="0" style="border:1px solid ##0083CA; border-radius:5px; overflow:hidden;">
										<!-- Cabeçalho do Card com Imagem -->
										<tr>
											<td align="center" bgcolor="##00416B" style="padding:20px; background-color:##00416B;">
												<table width="100%" cellpadding="0" cellspacing="0" border="0">
													<tr>
														<td align="left" style="vertical-align: middle;text-align: center;">
															<h2 style="margin:0; color:##ffffff; font-family: Arial, sans-serif; font-size:20px;">
																SNCI - Sistema Nacional de Controle Interno<br>Módulo: Processos
															</h2>
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<!-- Corpo do E-mail -->
										<tr>
											<td style="padding:20px; font-family: Arial, sans-serif; color:##212529; font-size:14px; line-height:1.5;">
												<cfoutput>
													<p style="margin:0 0 10px 0; text-align: justify;">#arguments.pronomeTratamento#,</pre>
													#texto#
												</cfoutput>
											</td>
										</tr>
										<!-- Rodapé do Card -->
										<tr>
											<td bgcolor="##f2f2f2" style="padding:10px; text-align:center; font-family: Arial, sans-serif; font-size:12px; color:##212529;">
												<p>CS/DIGOE/SUGOV/DCINT/GACE - Gerência de Avaliações de Controles Especiais</p>
												<p>Este é um e-mail automático, por favor não responda.</p>
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
				</body>
				</html>
			</cfmail>
			<cfset sucesso = true>
			<cfcatch type="any">
				<cfset sucesso = false>
			</cfcatch>

			
    	</cftry>
		<cfreturn #sucesso# />
    </cffunction>

	<cffunction name="rotinaMensalMelhoriasPendentes" access="remote"  hint="Verifica or órgãos responsáveis pelas propostas de melhoria pendentes e encaminha e-mail de alerta.">
		
		<cfquery name="rsOrgaosComMelhoriasPendentes" datasource="#application.dsn_processos#" >
			SELECT DISTINCT pc_aval_melhoria_num_orgao
			FROM pc_avaliacao_melhorias
			WHERE pc_aval_melhoria_status = 'P'	
		</cfquery>

		<cfquery name="rsOrgaosComMelhoriasPendentesParaTeste" datasource="#application.dsn_processos#" >
			SELECT DISTINCT TOP 5 pc_aval_melhoria_num_orgao
			FROM pc_avaliacao_melhorias
			WHERE pc_aval_melhoria_status = 'P'	
		</cfquery>

		
		<cfif FindNoCase('intranetsistemaspe', application.auxsite)>
			<cfset myQuery = "rsOrgaosComMelhoriasPendentes">
		<cfelse>
			<cfset myQuery = "rsOrgaosComMelhoriasPendentesParaTeste">
		</cfif>

		<cfloop query="#myQuery#">
			<cfquery name="rsMelhoriasPendentes" datasource="#application.dsn_processos#">
				SELECT 
				  pc_orgaos.pc_org_sigla as siglaOrgaoResp
				, pc_orgaos.pc_org_mcu
				, pc_orgaos.pc_org_emaiL as emailOrgaoResp
				, pc_orgaosAvaliado.pc_org_emaiL as emailOrgaoAvaliado
				FROM pc_avaliacao_melhorias
				LEFT JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_melhoria_num_orgao
				LEFT JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
				LEFT JOIN pc_processos on pc_processo_id = pc_aval_processo
				LEFT JOIN pc_orgaos as pc_orgaosAvaliado on pc_orgaosAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				WHERE pc_aval_melhoria_num_orgao = '#pc_aval_melhoria_num_orgao#' and pc_aval_melhoria_status = 'P' and pc_num_status in(4,5)
			</cfquery>

			<cftry>
				<cfset to = "#LTrim(RTrim(rsMelhoriasPendentes.emailOrgaoResp))#">
				<cfset cc = "#LTrim(RTrim(rsMelhoriasPendentes.emailOrgaoAvaliado))#">

				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsMelhoriasPendentes.siglaOrgaoResp))#">
				<cfset pronomeTrat = "Senhor(a) Gestor(a) do(a) #siglaOrgaoResponsavel#">
				<cfset textoEmail = '<p style="text-align: justify;">Informamos que existe(m) #NumberFormat(rsMelhoriasPendentes.recordcount,"00")# Proposta(s) de Melhoria registrada(s) pelo Controle Interno, no Sistema SNCI, com status “PENDENTE”, aguardando manifestação do gestor responsável.</p> 
									    <p style="text-align: justify;">Para regularizar a situação, solicitamos acessar o sistema por meio do link abaixo, tela "Acompanhamento", aba "Propostas de Melhoria" e inserir sua resposta:</p>
										<p style="text-align:center;">
											<a href="http://intranetsistemaspe/snci/snci_processos/index.cfm" style="background-color:##00416B; color:##ffffff; padding:10px 20px; text-decoration:none; border-radius:5px; display:inline-block;">Acessar SNCI - Processos</a>
										</p>
								        <p style="text-align: justify;">As Propostas de Melhoria estão cadastradas no sistema com status "PENDENTE", para que os gestores dos órgãos avaliados registrem suas manifestações, observando as opções a seguir:</p>   
										<ul>
											<li style="text-align: justify;">ACEITA: situação em que a "Proposta de Melhoria" é aceita pelo gestor. Neste caso, deverá ser informada a data prevista de implementação;</li><br>   
											<li style="text-align: justify;">RECUSA: situação em que a "Proposta de Melhoria" é recusada pelo gestor, com registro da justificativa para essa ação;</li> <br> 
											<li style="text-align: justify;">TROCA: situação em que o gestor propõe outra ação em substituição à "Proposta de Melhoria" sugerida pelo Controle Interno. Nesse caso indicar o prazo previsto de implementação.</li>  
										</ul>
										
										<p style="margin-top:20px; text-align: justify;">Estamos à disposição para prestar informações adicionais a respeito do assunto, caso seja necessário.</p>
										'>
										
				<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
				<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
							para = "#to#"
							copiaPara = "#cc#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
				/>
				<cfcatch type="any">
				<cfset de="SNCI@correios.com.br">
				<cfif FindNoCase("localhost", application.auxsite)>
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
					<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "rotinaMensalMelhoriasPendentes" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry>

		</cfloop>

	</cffunction>
	
	

	<cffunction name="executaRotinasEmailsCobranca" access="remote" returntype="any" output="false" hint="Executa as rotinas de envio de e-mails de cobrança de orientações e propostas de melhoria.">
		<cfset currentDate = Now()>
		<cfset currentDayOfWeek = DayOfWeek(currentDate)>
		<cfset currentDay = Day(currentDate)>

		<!-- Rotina Diária -->
		<cfif not rotinaJaExecutadaEmailsCobranca("rotinaDiaria", currentDate)>
			<cfinvoke component="pc_cfcPaginasApoio" method="rotinaDiariaOrientacoesSuspensas" returnVariable="rotinaDiariaOrientacoesSuspensas" />
			<cfset atualizarLogExecucao("rotinaDiaria")>
		</cfif>

		<!-- Rotina Semanal - Executar uma vez por semana em qualquer dia útil -->
		<cfif isBusinessDay(currentDate) AND not rotinaJaExecutadaEmailsCobranca("rotinaSemanal", currentDate)>
			<cfinvoke component="pc_cfcPaginasApoio" method="rotinaSemanalOrientacoesPendentesSemTab" returnVariable="rotinaSemanalOrientacoesPendentes" />
			<cfset atualizarLogExecucao("rotinaSemanal")>
		</cfif>

		<!-- Rotina Mensal - Executar em qualquer dia útil do mês, uma vez por mês -->
		<cfif isBusinessDay(currentDate) AND not rotinaJaExecutadaEmailsCobranca("rotinaMensal", currentDate)>
			<cfinvoke component="pc_cfcPaginasApoio" method="rotinaMensalMelhoriasPendentes" returnVariable="rotinaMensalMelhoriasPendentes" />
			<cfset atualizarLogExecucao("rotinaMensal")>
		</cfif>
		
	</cffunction>
	
	<cffunction name="rotinaJaExecutadaEmailsCobranca" access="private" returntype="boolean" output="false" hint="Verifica se a rotina já foi executada.">
		<cfargument name="rotinaNome" type="string" required="true">
		<cfargument name="currentDate" type="date" required="true"> <!-- Novo Argumento -->
		<cfset var resultado = false>
		<cfset var lastExecDate = "">
	
		<cfquery name="verificarExecucao" datasource="#application.dsn_processos#">
			SELECT pc_rotina_ultima_execucao 
			FROM pc_rotinas_execucao_emails_log 
			WHERE pc_rotina_nome = <cfqueryparam value="#arguments.rotinaNome#" cfsqltype="cf_sql_varchar">
		</cfquery>
	
		<cfif arguments.rotinaNome eq "rotinaMensal">
			<!-- Verificar se a rotina mensal já foi executada no mês atual -->
			<cfif verificarExecucao.recordCount EQ 1>
				<cfset lastExecDate = verificarExecucao.pc_rotina_ultima_execucao[1]>
				<cfif Year(lastExecDate) EQ Year(arguments.currentDate) AND Month(lastExecDate) EQ Month(arguments.currentDate)>
					<cfset resultado = true>
				</cfif>
			</cfif>
		<cfelseif arguments.rotinaNome eq "rotinaSemanal">
			<!-- Verificar se a rotina semanal já foi executada nesta semana -->
			<cfif verificarExecucao.recordCount EQ 1>
				<cfset lastExecDate = verificarExecucao.pc_rotina_ultima_execucao[1]>
				<cfif isSameWeek(lastExecDate, arguments.currentDate)>
					<cfset resultado = true>
				</cfif>
			</cfif>
		<cfelse>
			<!-- Verificar se a rotina já foi executada hoje -->
			<cfif verificarExecucao.recordCount EQ 1 AND DateCompare(verificarExecucao.pc_rotina_ultima_execucao, arguments.currentDate, "d") EQ 0>
				<cfset resultado = true>
			</cfif>
		</cfif>
	
		<cfreturn resultado>
	</cffunction>
	
	<cffunction name="atualizarLogExecucao" access="private" returntype="void" output="false" hint="Atualiza a data da última execução da rotina.">
		<cfargument name="rotinaNome" type="string" required="true">
	
		<!-- Verificar se a rotina já existe no log -->
		<cfquery name="verificarExistencia" datasource="#application.dsn_processos#">
			SELECT COUNT(*) AS total
			FROM pc_rotinas_execucao_emails_log
			WHERE pc_rotina_nome = <cfqueryparam value="#arguments.rotinaNome#" cfsqltype="cf_sql_varchar">
		</cfquery>
	
		<cfif verificarExistencia.total EQ 1>
			<!-- Atualizar última execução se já existe -->
			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_rotinas_execucao_emails_log 
				SET pc_rotina_ultima_execucao = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
				WHERE pc_rotina_nome = <cfqueryparam value="#arguments.rotinaNome#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<!-- Inserir nova entrada se não existe -->
			<cfquery datasource="#application.dsn_processos#">
				INSERT INTO pc_rotinas_execucao_emails_log (pc_rotina_nome, pc_rotina_ultima_execucao)
				VALUES (<cfqueryparam value="#arguments.rotinaNome#" cfsqltype="cf_sql_varchar">, <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">)
			</cfquery>
		</cfif>
	</cffunction>
	

	<cffunction name="isBusinessDay" access="private" returntype="boolean" output="false" hint="Verifica se a data é um dia útil (segunda a sexta-feira).">
		<cfargument name="currentDate" type="date" required="true">
		<cfset var dayOfWeek = DayOfWeek(arguments.currentDate)>
		<cfreturn (dayOfWeek NEQ 1 AND dayOfWeek NEQ 7)>
	</cffunction>
	

	<cffunction name="getStartOfWeek" access="private" returntype="date" output="false" hint="Retorna a data de segunda-feira da semana da data fornecida.">
		<cfargument name="someDate" type="date" required="true">
		<cfset var dayOfWeek = DayOfWeek(arguments.someDate)>
		<cfset var startOfWeek = DateAdd("d", - (dayOfWeek - 2), arguments.someDate)>
		<cfif dayOfWeek LT 2>
			<!-- Se o dia da semana for domingo (1), ajustar para a semana anterior -->
			<cfset startOfWeek = DateAdd("d", -6, arguments.someDate)>
		</cfif>
		<cfreturn startOfWeek>
	</cffunction>
	

	<cffunction name="isSameWeek" access="private" returntype="boolean" output="false" hint="Verifica se duas datas estão na mesma semana.">
		<cfargument name="date1" type="date" required="true">
		<cfargument name="date2" type="date" required="true">
		<cfset var startOfWeek1 = getStartOfWeek(arguments.date1)>
		<cfset var startOfWeek2 = getStartOfWeek(arguments.date2)>
		<cfreturn (DateFormat(startOfWeek1, "yyyy-mm-dd") EQ DateFormat(startOfWeek2, "yyyy-mm-dd"))>
	</cffunction>


		
	<cffunction name="trocaSubordTecnicaOrgao" access="remote"  hint="troca a subordinação técnica do órgão na consulta por órgão.">
	
		<cfargument name="mcuOrgao" type="string" required="true">
		<cfargument name="mcuOrgaoSubord" type="string" required="true">
        <cfargument name="tipoSubordinacao" type="string" required="true">
		<cfif "#arguments.tipoSubordinacao#" eq "subTec">
			<!--se mcuOrgao e mcuOrgaoSubordTec não for null-->
			<cfif #mcuOrgao# neq "" and #mcuOrgaoSubord# neq "">
				<cfquery name="rsTrocaSubordTecnicaOrgao" datasource="#application.dsn_processos#">
					UPDATE pc_orgaos
					SET pc_org_mcu_subord_tec = <cfqueryparam value="#mcuOrgaoSubord#" cfsqltype="cf_sql_varchar">
					WHERE pc_org_mcu = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		<cfelse>
			<!--se mcuOrgao e mcuOrgaoSubordAdm não for null-->
			<cfif #mcuOrgao# neq "" and #mcuOrgaoSubord# neq "">
				<cfquery name="rsTrocaSubordTecnicaOrgao" datasource="#application.dsn_processos#">
					UPDATE pc_orgaos
					SET pc_org_mcu_subord_adm = <cfqueryparam value="#mcuOrgaoSubord#" cfsqltype="cf_sql_varchar">
					WHERE pc_org_mcu = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		</cfif>
		
	</cffunction>

	<cffunction name="criarTreeOrgao" access="remote"  hint="cria a árvore de órgãos com base nos parametros de subordinação.">
		<cfargument name="tipoSubordinacao" type="string" required="true">

		
		<cfquery name="rsOrgaos" datasource="#application.dsn_processos#">
			SELECT pc_orgaos.*
			FROM pc_orgaos
			order by pc_org_sigla
		</cfquery>  
         
		<div style="margin-top:20px;margin-bottom:80px;">
			<ul style="border: 1px solid rgba(0,0,0,0.2); margin-left:10px;box-shadow: 0px 0px 10px rgba(0,0,0,0.2);" id="treeOrgao" class="ztree"></ul>
			<span style="margin-left:10px;color:red"><b>Obs:</b> Os órgãos em vermelho estão desativados.</span>
		</div>

		<script language="JavaScript">
			$(document).ready(function(){
				if (typeof cutNode !== 'undefined' && cutNode) {
					cutNode=null;
				}
				$.fn.zTree.init($("#treeOrgao"), setting, zNodes);
				//fuzzySearch('treeOrgao','#filter',null,true); // initialize fuzzy search function
				setEdit();
				$("#cutNodeBtn_treeOrgao_1").bind("click", cutNodeBtnClick);
				$("#pasteNodeBtn_treeOrgao_1").bind("click", pasteNodeBtnClick);
				$("#desativarNodeBtn_treeOrgao_1").bind("click", desativarNodeBtnClick);
				$("#ativarNodeBtn_treeOrgao_1").bind("click", ativarNodeBtnClick);
			});

			 

			var setting = {
				data: {
					simpleData: {
						enable: true
					}
				},
				keep: {
					leaf: true
				},
				view: {
					fontCss: getFontCss,
					dblClickExpand: false,
					nameIsHTML: true,
					addDiyDom: function(treeId, treeNode) {
						var spaceWidth = 5;
						var buttonHTML = '<i id="cutNodeBtn_' + treeNode.tId + '" title="Selecionar para transferência" class="fa fa-pencil-alt grow-icon" style="font-size: 12px;margin-left: 10px;display:none;"></i>'
										+ '<i id="pasteNodeBtn_' + treeNode.tId + '" title="Transferir Órgão" class="fa fa-paste grow-icon" style="font-size: 12px;display:none;margin-left: 10px;"></i>'
										+ '<i id="desativarNodeBtn_' + treeNode.tId + '" title="Desativar Órgão" class="fa fa-ban grow-icon" style="font-size: 12px;display:none;margin-left: 10px;"></i>'	   
										+ '<i id="ativarNodeBtn_' + treeNode.tId + '" title="Ativar Órgão" class="fa fa-eye grow-icon" style="font-size: 12px;display:none;margin-left: 10px;"></i>';
						var tId = treeNode.tId;
						var $node = $("#" + tId);
						var $span = $("#" + tId + "_span");
						if ($("#cutNodeBtn_" + tId).length > 0) return;
						var $diyBtn = $(buttonHTML).appendTo($node);
						// ajusta a posição do título do nó
						$span.css({marginLeft: spaceWidth + "px"});
						// Adicione um ouvinte de evento 'click' ao botão
            			$('#cutNodeBtn_' + treeNode.tId).click(cutNodeBtnClick);
						
            			$('#pasteNodeBtn_' + treeNode.tId).click(pasteNodeBtnClick);

						$('#desativarNodeBtn_' + treeNode.tId).click(desativarNodeBtnClick);

						$('#ativarNodeBtn_' + treeNode.tId).click(ativarNodeBtnClick);

					}
				},
				callback: {
					onClick: onClick,
					
				}
			};
			
			function getFontCss(treeId, treeNode) {
				if (treeNode.status == 'D' && treeNode.cut || treeNode.cut) {
					return {color:"gray"}; // Se o status for 'D' e o nó foi cortado, muda a cor para cinza
				} else if (treeNode.status == 'D' && treeNode.pasted || treeNode.pasted) {
					return {color:"blue"}; // Se o nó foi colado, muda a cor para azul
				} else if (treeNode.status == 'D') {
					return {color:"red"}; // Se apenas o status for 'D', muda a cor para vermelho
				} else {
					return {};
				}
			}



		

			
		
			function onClick(e,treeId, treeNode) {
				var zTree = $.fn.zTree.getZTreeObj("treeOrgao");//pega a arvore
				//zTree.expandNode(treeNode);//expande o nó
				// Oculte todos os ícones
				$('.fa-pencil-alt, .fa-paste, .fa-ban, .fa-eye').hide();
				// Verifique se um nó foi selecionado
				if (treeNode) {
					// Se um nó foi selecionado, mostre o botão
					$('#cutNodeBtn_' + treeNode.tId).show();
					if (treeNode.status == 'D') {
						$('#ativarNodeBtn_' + treeNode.tId).show();
					} else {
						$('#desativarNodeBtn_' + treeNode.tId).show();
					}
                    
					if (typeof cutNode !== 'undefined' && cutNode) {// Verifica se existe algum nó selecionado e se cutNode não é null	
						$('#pasteNodeBtn_' + treeNode.tId).show();
					}
				}
			}

			function cutNodeBtnClick() {
				
				var treeObj = $.fn.zTree.getZTreeObj("treeOrgao");
				var nodes = treeObj.getSelectedNodes();
				if (nodes.length > 0) {
					cutNode = nodes[0];

					swalWithBootstrapButtons.fire({//sweetalert2
						html: logoSNCIsweetalert2('Deseja transferir este órgão:<br><strong>' + cutNode.extraData +'</strong> ?'),
						showCancelButton: true,
						confirmButtonText: 'Sim!',
						cancelButtonText: 'Cancelar!',
						}).then((result) => {
						if (result.isConfirmed) {
							cutNode.cut = true; // Adiciona uma propriedade 'cut' ao nó
							treeObj.updateNode(cutNode); // Atualiza o nó para aplicar o novo estilo
							var nomeOrgao = cutNode.extraData;
							var mensagem = "";
							if($('input[name="subRadio"]:checked').val() == "subTec"){
								mensagem='<p style="text-align: justify;">Você selecionou o  órgão <strong>' + nomeOrgao +   '</strong> para alterar a subordinação técnica.<br><br>Clique em OK, depois selecione o órgão que será a nova subordinação técnica e clique em <i class="fa fa-paste"></i> para transferir.<br><br>Obs.: Par retirar esse órgão de qualquer estrutura, basta não selecionar nenhum outro órgão e clicar no botão <i class="fa fa-paste"></i> que aparecerá neste mesmo órgão.</p>'
							}else{
								mensagem='<p style="text-align: justify;">Você selecionou o  órgão <strong>' + nomeOrgao +   '</strong> para alterar a subordinação administrativa.<br><br>Clique em OK, depois selecione o órgão que será a nova subordinação administrativa e clique em <i class="fa fa-paste"></i> para transferir.<br><br>Obs.: Par retirar esse órgão de qualquer estrutura, basta não selecionar nenhum outro órgão e clicar no botão <i class="fa fa-paste"></i> que aparecerá neste mesmo órgão.</p>'	
							}	
							Swal.fire({
								html: logoSNCIsweetalert2(mensagem),
								title: '',
								confirmButtonText: 'OK!'
							});
												
							$('#pasteNodeBtn_' + cutNode.tId).show(); // Mostra o botão usando jQuery
						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							
							Swal.fire({
									title: 'Operação Cancelada',
									html: logoSNCIsweetalert2(''),
									icon: 'info'
								});
							
							carregaTreeOrgao();
							
						} 
					});

				}
						
			}

			function pasteNodeBtnClick() {
				var treeObj = $.fn.zTree.getZTreeObj("treeOrgao");
				var nodes = treeObj.getSelectedNodes();
				if (nodes.length > 0 && cutNode) {// Verifica se existe algum nó selecionado e se cutNode não é null
					
						treeObj.moveNode(nodes[0], cutNode, "inner");
						cutNode.pasted = true; // Adiciona uma propriedade 'pasted' ao nó
						cutNode.cut = false; // Define 'cut' como false
						treeObj.updateNode(cutNode); // Atualiza o nó para aplicar o novo estilo
						$('#pasteNodeBtn_' + cutNode.tId).hide(); // Esconde o botão usando jQuery

						//ajax para o metodo trocaSubordTecnicaOrgao do cfc pc_cfcPaginasApoio.cfc
						if (cutNode !== null) { // Verifica se cutNode não é null antes de acessar a propriedade id
							var mcuOrgao = cutNode.id;
							var nomeOrgao = cutNode.extraData;
							var mcuOrgaoSubord = nodes[0].id;
							var nomeOrgaoSubord = nodes[0].extraData;
							if($('input[name="subRadio"]:checked').val() == "subTec"){
								var perguntaInicial = '<p style="text-align: justify;">Deseja transferir o órgão <strong>' + nomeOrgao + '</strong> para a subordinação técnica do órgão <strong>' + nomeOrgaoSubord +'</strong> ?</p>';
								if(mcuOrgao === mcuOrgaoSubord){
									perguntaInicial = '<p style="text-align: justify;">Deseja retirar o órgão <strong>' + nomeOrgao + '</strong> de qualquer subordinação técnica?</p>';
								}
							}else{
								var perguntaInicial = '<p style="text-align: justify;">Deseja transferir o órgão <strong>' + nomeOrgao + '</strong> para a subordinação administrativa do órgão <strong>' + nomeOrgaoSubord +'</strong> ?</p>';
								if(mcuOrgao === mcuOrgaoSubord){
									perguntaInicial = '<p style="text-align: justify;">Deseja retirar o órgão <strong>' + nomeOrgao + '</strong> de qualquer subordinação administrativa?</p>';
								}
							}
							swalWithBootstrapButtons.fire({//sweetalert2
								html: logoSNCIsweetalert2(perguntaInicial),
								showCancelButton: true,
								confirmButtonText: 'Sim!',
								cancelButtonText: 'Cancelar!',
								}).then((result) => {
								if (result.isConfirmed) {
									$('#modalOverlay').modal('show')
									setTimeout(function() {
										$.ajax({
											type: "POST",
											url: "../SNCI_PROCESSOS/cfc/pc_cfcPaginasApoio.cfc?method=trocaSubordTecnicaOrgao",
											data: {
												"mcuOrgao": mcuOrgao,
												"mcuOrgaoSubord": mcuOrgaoSubord,
												"tipoSubordinacao": $('input[name="subRadio"]:checked').val()
											},
											success: function (data) {
												$('#modalOverlay').delay(1000).hide(0, function() {
													$('#modalOverlay').modal('hide');
													var mensagem = "";
													if(mcuOrgao === mcuOrgaoSubord){//se for retirar o orgao de qualquer estrutura
														if($('input[name="subRadio"]:checked').val() == "subTec"){//se for subord tecnica
															mensagem='<p style="text-align: justify;">Rotina executada com sucesso! <br><br>Agora o órgão <strong>' + nomeOrgao + '</strong> não está subordinado tecnicamente a nenhum órgão cadastrado no SNCI.<br><br>A consulta será atualizada.</p>'	
														}else{//se for subord adm
															mensagem='<p style="text-align: justify;">Rotina executada com sucesso! <br><br>Agora o órgão <strong>' + nomeOrgao + '</strong> não está subordinado administrativamente a nenhum órgão cadastrado no SNCI.<br><br>A consulta será atualizada.</p>'	
														}
													}else{
														if($('input[name="subRadio"]:checked').val() == "subTec"){//se for subord tecnica
															mensagem='<p style="text-align: justify;">Rotina executada com sucesso! <br><br>Agora o órgão <strong>' + nomeOrgao +   '</strong> está subordinado tecnicamente a <strong>' + nomeOrgaoSubord + '</strong>.<br><br>A consulta será atualizada.</p>'
														}else{//se for subord adm
															mensagem='<p style="text-align: justify;">Rotina executada com sucesso! <br><br>Agora o órgão <strong>' + nomeOrgao +   '</strong> está subordinado administrativamente a <strong>' + nomeOrgaoSubord + '</strong>.<br><br>A consulta será atualizada.</p>'	
														}		
													}	

													Swal.fire({
													html: logoSNCIsweetalert2(mensagem),
													title: '',
													confirmButtonText: 'OK!',
														
													}).then((result) => {
														if (result.isConfirmed) {
															carregaTreeOrgao();
														}
													});
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
								}else {
									// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
									$('#modalOverlay').modal('hide');
									Swal.fire({
											title: 'Operação Cancelada',
											html: logoSNCIsweetalert2(''),
											icon: 'info'
										});
									carregaTreeOrgao();
								} 
							});	

						}
						cutNode = null;
				}
			}


			function setEdit() {
				var zTree = $.fn.zTree.getZTreeObj("treeOrgao");
			
			}

			
			function desativarNodeBtnClick() {
				
				var treeObj = $.fn.zTree.getZTreeObj("treeOrgao");
				var nodes = treeObj.getSelectedNodes();
				if (nodes.length > 0) {
					cutNode = nodes[0];
					swalWithBootstrapButtons.fire({//sweetalert2
						html: logoSNCIsweetalert2('Deseja desativar este órgão:<br><strong>' + cutNode.extraData +'</strong> ?'),
						showCancelButton: true,
						confirmButtonText: 'Sim!',
						cancelButtonText: 'Cancelar!',
						}).then((result) => {
						if (result.isConfirmed) {

							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "POST",
									url: "../SNCI_PROCESSOS/cfc/pc_cfcPaginasApoio.cfc?method=desativaOrgao",
									data: {
										"pcOrgMcu": cutNode.id
									},
									success: function (data) {
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											var mensagem = "";
											mensagem='<p style="text-align: justify;">Rotina executada com sucesso! <br><br>O órgão <strong>' + cutNode.extraData +   '</strong> foi desativado.<br><br>A consulta será atualizada.</p>'
											Swal.fire({
											html: logoSNCIsweetalert2(mensagem),
											title: '',
											confirmButtonText: 'OK!',
												
											}).then((result) => {
												if (result.isConfirmed) {
													$('#pasteNodeBtn_' + cutNode.tId).hide(); // Mostra o botão usando jQuery
													carregaTreeOrgao();
												}
											});
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
					
						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							
							Swal.fire({
									title: 'Operação Cancelada',
									html: logoSNCIsweetalert2(''),
									icon: 'info'
								});
							
							
						}
					});
				}
						
			}

			function ativarNodeBtnClick() {
				
				var treeObj = $.fn.zTree.getZTreeObj("treeOrgao");
				var nodes = treeObj.getSelectedNodes();
				if (nodes.length > 0) {
					cutNode = nodes[0];
					swalWithBootstrapButtons.fire({//sweetalert2
						html: logoSNCIsweetalert2('Deseja ativar este órgão:<br><strong>' + cutNode.extraData +'</strong> ?'),
						showCancelButton: true,
						confirmButtonText: 'Sim!',
						cancelButtonText: 'Cancelar!',
						}).then((result) => {
						if (result.isConfirmed) {

							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "POST",
									url: "../SNCI_PROCESSOS/cfc/pc_cfcPaginasApoio.cfc?method=ativaOrgao",
									data: {
										"pcOrgMcu": cutNode.id
									},
									success: function (data) {
										$('#modalOverlay').delay(1000).hide(0, function() {
											$('#modalOverlay').modal('hide');
											var mensagem = "";
											mensagem='<p style="text-align: justify;">Rotina executada com sucesso! <br><br>O órgão <strong>' + cutNode.extraData +   '</strong> foi ativado.<br><br>A consulta será atualizada.</p>'
											Swal.fire({
											html: logoSNCIsweetalert2(mensagem),
											title: '',
											confirmButtonText: 'OK!',
												
											}).then((result) => {
												if (result.isConfirmed) {
													$('#pasteNodeBtn_' + cutNode.tId).hide(); // Mostra o botão usando jQuery
													carregaTreeOrgao();
												}
											});
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
					});
				}
			}	

			var zNodes =[
					<cfoutput query="rsOrgaos">
						<cfif "#arguments.tipoSubordinacao#" eq "subTec">
							{ 
								id: "#rsOrgaos.pc_org_mcu#", // unique ID
								pId: "#rsOrgaos.pc_org_mcu_subord_tec#", // parent ID
								name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - mcu:#rsOrgaos.pc_org_mcu# - e-mail:#rsOrgaos.pc_org_email#)", 
								open: false, // open this node on page load
								status: "#rsOrgaos.pc_org_status#", // status of the node
								extraData:"#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_mcu#)"
							},
						<cfelse>
							{
								id: "#rsOrgaos.pc_org_mcu#", // unique ID
								pId: "#rsOrgaos.pc_org_mcu_subord_adm#", // parent ID
								name: "#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_descricao# - mcu:#rsOrgaos.pc_org_mcu# - e-mail:#rsOrgaos.pc_org_email#)", 
								open: false, // open this node on page load
								status: "#rsOrgaos.pc_org_status#", // status of the node
								extraData:"#rsOrgaos.pc_org_sigla# (#rsOrgaos.pc_org_mcu#)"
							},
						</cfif>

					</cfoutput>
				];

		</script>		


	</cffunction>

	<cffunction name="desativaOrgao" access="remote"  hint="desativa órgãos na página Consultar Órgãos.">
		<cfargument name="pcOrgMcu" type="string" required="true">
		<cfquery name="rsDesativarOrgao" datasource="#application.dsn_processos#">
			UPDATE pc_orgaos
			SET pc_org_status = 'D'
			WHERE pc_org_mcu = <cfqueryparam value="#arguments.pcOrgMcu#" cfsqltype="cf_sql_varchar">		
		</cfquery>
		<cfreturn true>

	</cffunction>

	<cffunction name="ativaOrgao" access="remote"  hint="ativa órgãos na página Consultar Órgãos.">
		<cfargument name="pcOrgMcu" type="string" required="true">
		<cfquery name="rsAtivarOrgao" datasource="#application.dsn_processos#">
			UPDATE pc_orgaos
			SET pc_org_status = 'A'
			WHERE pc_org_mcu = <cfqueryparam value="#arguments.pcOrgMcu#" cfsqltype="cf_sql_varchar">		
		</cfquery>
		<cfreturn true>

	</cffunction>

	<cffunction name="dashboardMenuRapido" access="remote" hint="criar um dashboard contendo atalhos para as páginas mais importantes.">
		<cfquery name="rsMenuRapido" datasource="#application.dsn_processos#">
			SELECT "pc_controle_acesso".* FROM pc_controle_acesso 
			WHERE pc_controle_acesso_perfis LIKE '%#application.rsUsuarioParametros.pc_usu_perfil#%' 
			AND pc_controle_acesso_rapido_nome IS NOT NULL AND pc_controle_acesso_rapido_nome <> ''
			ORDER BY pc_controle_acesso_rapido_nome
		</cfquery>
     
		
				
		<div align="center" style="margin-bottom:20px;">	
			<div class="menuRapidoGrid">
				<div class="menuRapido_legendGrid ">Páginas Principais</div> 
				<cfloop query="rsMenuRapido">
					<cfoutput>
						<cfset link = "../SNCI_PROCESSOS/./" & pc_controle_acesso_pagina>
						<a href="#link#">
							<div class="menuRapido_iconGrid">
								<i class="fas #pc_controle_acesso_menu_icone#"></i>
								<span class="font-weight-light">#pc_controle_acesso_rapido_nome#</span>
							</div>
						</a>
					</cfoutput>
				</cfloop>
			</div>
		</div>
		
		
				
	</cffunction>

	
	

	



	
</cfcomponent>