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
								
								<thead >
									<tr style="background: none;border:none">
										<th style="background: none;border:none"></th>
									</tr>
								</thead>
								
								<tbody class="grid-container" >
									<cfloop query="rsPerfisCards" >
									
										<tr style="width:270px;border:none">

											<td style="background: none;border:none">

												<cfquery name="rsQuantUsuariosPorPerfil" datasource="#application.dsn_processos#">
													SELECT pc_usuarios.pc_usu_perfil from pc_usuarios 
													INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
													where pc_usu_perfil = #pc_perfil_tipo_id# and pc_usu_status = 'A'
												</cfquery>

												<section class="content" >
													<div id="cartaoPerfil" style="width:270px;border:none" >
														<!-- small card -->
														<div class="small-box " style="font-weight: normal;background: <cfif '#pc_perfil_tipo_status#' eq 'A'>#0083CA<cfelse>gray</cfif>;color: #fff;font-weight: normal;">
															
															<div class="card-header" style="height:130px;width:250px;border-bottom:none; font-weight: normal!important">
																<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3>
																	<p style="font-size:14px;margin-bottom: 0.3rem!important;"><strong><cfoutput>#pc_perfil_tipo_descricao#</strong> (id:#pc_perfil_tipo_id#)</cfoutput></p>
																<cfelse>
																	<p style="font-size:14px;margin-bottom: 0.3rem!important;"><strong><cfoutput>#pc_perfil_tipo_descricao#</strong></cfoutput></p>
																</cfif>
																<cfif '#pc_perfil_tipo_status#' neq 'A'>
																	<div align="center">
																		<p style="font-size:12px;margin-bottom: 0!important;"><strong>DESATIVADO</strong></p>
																	</div>
																</cfif>
																<div style="font-size:12px;margin-bottom: 0!important;text-align: justify;margin-right: -18px;"><cfoutput>#pc_perfil_tipo_comentario#</cfoutput></div>
																
																
																
															</div>
															<div class="icon">
																<i class="fas fa-users" style="opacity:0.6;left:100px;top:30px;font-size:70px"></i>
															</div>

															<a href="##"  target="_self" class="small-box-footer"   >
																<div style="display:flex;justify-content: space-around;" >
																	<input id="pcNumProcessoCard" name="pcNumProcessoCard" type="text" hidden >
																	<i id="btEdit" class="fas fa-edit efeito-grow"    style="cursor: pointer;z-index:100;font-size:16px" onclick="javascript:perfilEditar(<cfoutput>#pc_perfil_tipo_id#, '#pc_perfil_tipo_descricao#' ,'#pc_perfil_tipo_comentario#','#pc_perfil_tipo_status#'</cfoutput>)" data-toggle="tooltip"  tilte="Editar"></i>
																	<i id="btUsuarios" class="fas fa-users efeito-grow"    style="cursor: pointer;z-index:100;font-size:16px" onclick="javascript:mostraTabUsuariosPerfis(<cfoutput>#pc_perfil_tipo_id#</cfoutput>);" data-toggle="tooltip"  tilte="Usuarios"> = <cfoutput>#rsQuantUsuariosPorPerfil.recordcount#</cfoutput></i>
															
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
							]
						})
							
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
									<h5 style="color:#0083ca">Usuários Cadastrados com o Perfil: <strong><cfoutput>#rsPerfilSelecionado.pc_perfil_tipo_descricao#</cfoutput> </strong></h5>
									<table id="tabUsuariosPerfis" class="table table-bordered table-striped table-hover text-nowrap ">
										<thead style="background: #0083ca;color:#fff">
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







	<cffunction name="delUsuario"   access="remote"  returntype="any" hint="exclui usuários. Disponível apenas para perfil desenvolvedores">
		
		<cfargument name="pc_usu_matricula" type="string" required="true"/>

		<cfquery datasource="#application.dsn_processos#" >
			DELETE FROM pc_usuarios
			WHERE pc_usu_matricula = <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
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






    <cffunction name="cardsLinks"   access="remote" hint="enviar os cards dos Controle para a páginas pc_Pefis">

		<!DOCTYPE html>
		<html lang="pt-br">
			<head>
				<style>
					#tabControleCards_wrapper #tabControleCards_paginate ul.pagination {
						justify-content: center!important;
					}
				</style>
			</head>
			<body>
				<div class="card-body" style="border: solid 3px #ffD400;">
						<cfquery name="rsControleCards" datasource="#application.dsn_processos#">
							SELECT pc_controle_acesso.* from pc_controle_acesso 
							<cfif #application.rsUsuarioParametros.pc_usu_matricula# neq '80859992'>
								where not pc_controle_acesso_pagina = 'pc_ApoioDeletaProcessos.cfm'
							</cfif>
						</cfquery>	
						
						<table id="tabControleCards" class="table  " style="background: none;border:none;width:100%">
							<thead >
								<tr style="background: none;border:none">
									<th style="background: none;border:none"></th>
								</tr>
							</thead>
							
							<tbody class="grid-container" >
								<cfloop query="rsControleCards" >
								
									<tr style="width:270px;border:none" draggable="true" >

										<td id="cartaoPerfilTD" style="background: none;border:none">

											<section class="content" >
												<div id="cartaoPerfil" style="width:270px;border:none" >
													<!-- small card -->
													<div class="small-box " style="font-weight: normal;background:#0083CA;color: #fff;font-weight: normal;">
														<cfset grupo= ''>
														<cfset subgrupo= ''>
														<cfif #pc_controle_acesso_grupoMenu# neq ''>
															<cfset grupo = '#pc_controle_acesso_grupoMenu# > '>
														</cfif>
														<cfif #pc_controle_acesso_subgrupoMenu# neq ''>
															<cfset subgrupo = '#pc_controle_acesso_subgrupoMenu# > '>
														</cfif>
														<cfset link = '#grupo##subgrupo#'>
														
														<div  class="small-box" style="background:#2475b3;margin-bottom:-7px!important;height:24px;border-radius:0!important;display:flex;justify-content:center" >
															<span style="font-size:14px;color:#fff;"><strong><cfoutput><i class="right fas #pc_controle_acesso_menu_icone#"></i> <strong style="font-size:16px">#pc_controle_acesso_nomeMenu#</strong></cfoutput></p>
														</div>
														<div class="card-header" style="height:100px;width:250px;border-bottom:none; font-weight: normal!important">
															<p style="font-size:14px;margin-bottom: 0.3rem!important;">Menu: <cfoutput>#link##pc_controle_acesso_nomeMenu#</cfoutput></p>
															<div style="font-size:12px;margin-bottom: 0!important;text-align: justify;margin-right: -18px;"><cfoutput>Página: <span style="font-size:14px">#pc_controle_acesso_pagina#</span></cfoutput></div>
														</div>
														<div class="icon">
															<i class="fas <cfoutput>#pc_controle_acesso_menu_icone#</cfoutput> fa-5x" style="opacity:0.6;left:100px;top:30px;"></i>
														</div>

														<a href="##"  target="_self" class="small-box-footer"   >
															<div style="display:flex;justify-content: space-around;padding:5px;background:#3498db;" >
																<input id="pcNumProcessoCard" name="pcNumProcessoCard" type="text" hidden >
																
																<i id="btExcluir" class="fas fa-trash-alt efeito-grow"    style="cursor: pointer;z-index:100;font-size:16px;color:#fff" 
																onclick="javascript:controleExcluir(<cfoutput>#pc_controle_acesso_id#</cfoutput>)" data-toggle="tooltip"  tilte="Excluir"></i>
																
																<i id="btEdit" class="fas fa-edit efeito-grow"    style="cursor: pointer;z-index:100;font-size:16px;color:#fff" 
																onclick="javascript:controleEditar(<cfoutput>#pc_controle_acesso_id#,'#pc_controle_acesso_nomeMenu#','#pc_controle_acesso_pagina#','#pc_controle_acesso_perfis#','#pc_controle_acesso_grupoMenu#','#pc_controle_acesso_subgrupoMenu#','#pc_controle_acesso_grupo_icone#','#pc_controle_acesso_subgrupo_icone#','#pc_controle_acesso_menu_icone#','#pc_controle_acesso_ordem#'</cfoutput>)" data-toggle="tooltip"  tilte="Editar"></i>
																
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
					$("#tabControleCards").DataTable({
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
						]
						
					})

					
						
				});

				

				

			</script>
		</html>
	</cffunction>





	<cffunction name="cadLink"   access="remote"  returntype="any" hint="cadastra/edita links do menu">
		<cfargument name="pc_controle_acesso_id" type="string" required="false"/>

		<cfargument name="pc_controle_acesso_nomeMenu" type="string" required="true"/>
		<cfargument name="pc_controle_acesso_pagina" type="string" required="true"/>
		<cfargument name="pc_controle_acesso_Controle" type="any" required="true" default=''/>

		<cfargument name="pc_controle_acesso_grupoMenu" type="string" required="false" default=''/>
		<cfargument name="pc_controle_acesso_subgrupoMenu" type="string" required="false"  default=''/>

		<cfargument name="pc_controle_acesso_grupo_icone" type="string" required="false"  default=''/>
		<cfargument name="pc_controle_acesso_subgrupo_icone" type="string" required="false"  default=''/>
		<cfargument name="pc_controle_acesso_menu_icone" type="string" required="false"  default=''/>
		<cfargument name="pc_controle_acesso_ordem" type="numeric" required="false"  default=1/>

		<cfquery datasource="#application.dsn_processos#" >
			<cfif #arguments.pc_controle_acesso_id# eq ''>
				INSERT pc_controle_acesso (pc_controle_acesso_nomeMenu,pc_controle_acesso_pagina,pc_controle_acesso_perfis,pc_controle_acesso_grupoMenu
				        ,pc_controle_acesso_subgrupoMenu,pc_controle_acesso_grupo_icone,pc_controle_acesso_subgrupo_icone
						,pc_controle_acesso_menu_icone,pc_controle_acesso_ordem)
				VALUES (
						<cfqueryparam value="#arguments.pc_controle_acesso_nomeMenu#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_pagina#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_perfis#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_grupoMenu#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_subgrupoMenu#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_grupo_icone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_subgrupo_icone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_menu_icone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_ordem#" cfsqltype="cf_sql_integer">
						)



			<cfelse>
				UPDATE  pc_controle_acesso
				SET pc_controle_acesso_nomeMenu = <cfqueryparam value="#arguments.pc_controle_acesso_nomeMenu#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_pagina = <cfqueryparam value="#arguments.pc_controle_acesso_pagina#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_perfis = <cfqueryparam value="#arguments.pc_controle_acesso_perfis#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_grupoMenu = <cfqueryparam value="#arguments.pc_controle_acesso_grupoMenu#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_subgrupoMenu = <cfqueryparam value="#arguments.pc_controle_acesso_subgrupoMenu#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_grupo_icone = <cfqueryparam value="#arguments.pc_controle_acesso_grupo_icone#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_subgrupo_icone = <cfqueryparam value="#arguments.pc_controle_acesso_subgrupo_icone#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_menu_icone  = <cfqueryparam value="#arguments.pc_controle_acesso_menu_icone#" cfsqltype="cf_sql_varchar">,
					pc_controle_acesso_ordem = <cfqueryparam value="#arguments.pc_controle_acesso_ordem#" cfsqltype="cf_sql_integer">
				WHERE pc_controle_acesso_id = <cfqueryparam value="#arguments.pc_controle_acesso_id#" cfsqltype="cf_sql_integer">

			</cfif>
		</cfquery>
		
  	</cffunction>








	<cffunction name="delLink"   access="remote"  returntype="any" hint="exclui links do menu">
		<cfargument name="pc_controle_acesso_id" type="string" required="false"/>

		<cfquery datasource="#application.dsn_processos#" >
			DELETE FROM pc_controle_acesso
			WHERE pc_controle_acesso_id = <cfqueryparam value="#arguments.pc_controle_acesso_id#" cfsqltype="cf_sql_integer">
		</cfquery>
		
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
		

</cfcomponent>