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

	<cffunction name="EnviaEmails" access="public" returntype="string" hint="Cria o formado dos e-mails e envia.">
            
        <cfargument name="para" type="string" required="true">
        <cfargument name="copiaPara" type="string" required="false" default="">
        <cfargument name="pronomeTratamento" type="string" required="true">
        <cfargument name="texto" type="string" required="true">

        <cfset to = "#arguments.para#">
		<cfset cc = "">
		<cfif isdefined("arguments.copiaPara") and arguments.copiaPara neq "" and (arguments.copiaPara neq arguments.para)>
			<cfset cc = "#arguments.copiaPara#">
		</cfif> 

        <cfif application.auxsite neq "intranetsistemaspe">
			<cfif #cc# neq "" >
				<cfset mensagemParaTeste="Atenção, este é um e-mail de teste! No servidor de produção, este e-mail seria encaminhado para <strong>#to#</strong>, com cópia para <strong>#cc#</strong>.">
			<cfelse>
				<cfset mensagemParaTeste="Atenção, este é um e-mail de teste! No servidor de produção, este e-mail seria encaminhado para <strong>#to#</strong>.">
			</cfif>
			<cfset to = "marceloferreira@correios.com.br">
			<cfset cc = "">
        </cfif>

		<cftry> 
			<cfset de="SNCI@correios.com.br">
		    <cfif application.auxsite eq "localhost">
				<cfset de="mbflpa@yahoo.com.br">
			</cfif>
			<cfmail from="#de#" to="#to#" cc="#cc#" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
			    <cfif application.auxsite neq "intranetsistemaspe">
					<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#mensagemParaTeste#</pre>
				</cfif>
				<div style="background-color: ##00416B; color:##fff; border-radius: 10px; padding: 20px; box-shadow: 0px 0px 10px ##888888; max-width: 700px; margin: 0 auto; float: left;">
					<div style="background-color:##fff ; color:##00416B; border-radius: 10px; padding-top: 2px;padding-bottom: 2px;padding-left: 15px;padding-right: 10px; box-shadow: 0px 0px 10px ##888888;text-align: center;">
						<p style="font-size:20px">SNCI - Sistema Nacional de Controle Interno - Módulo: Processos</p> 
					</div> 
					<cfoutput>
						<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#arguments.pronomeTratamento#,</pre>
						<div style="text-align: justify;font-family: inherit;font-weight: 500;line-height: 1.2;">#texto#</div>
						<div style="background-color:##fff ; color:##00416B; border-radius: 10px; padding-top: 2px;padding-bottom: 2px;padding-left: 15px;padding-right: 10px; box-shadow: 0px 0px 10px ##888888;">
							<p>Estamos à disposição para prestar informações adicionais a respeito do 
							assunto, caso seja necessário.</p>
						
							<p><strong>CS/DIGOE/SUGOV/DCINT/GPCI - Gerência de Planejamento de Controle Interno</strong></p>
							
							<p><strong>Obs:</strong> Este é um e-mail automático, por favor não responda.</p>
						</div>
					</cfoutput>
				</div>
			</cfmail>
			<cfset sucesso = true>
			<cfcatch type="any">
				<cfset sucesso = false>
			</cfcatch>

			
    	</cftry>
		<cfreturn #sucesso# />
    </cffunction>

	<cffunction name="EnviaEmailsTeste" access="public" returntype="string" hint="Cria o formado dos e-mails e envia.">
            
        <cfargument name="para" type="string" required="true">
        <cfargument name="copiaPara" type="string" required="false" default="">
        <cfargument name="pronomeTratamento" type="string" required="true">
        <cfargument name="texto" type="string" required="true">

        <cfset to = "#arguments.para#">
		<cfset cc = "">
		<cfif isdefined("arguments.copiaPara") and arguments.copiaPara neq "" and (arguments.copiaPara neq arguments.para)>
			<cfset cc = "#arguments.copiaPara#">
		</cfif> 

        <cfif application.auxsite neq "intranetsistemaspe">
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
		    <cfif application.auxsite eq "localhost">
				<cfset de="mbflpa@yahoo.com.br">
			</cfif>
			<cfmail from="#de#" to="#to#" cc="#cc#" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
			    <cfif application.auxsite neq "intranetsistemaspe">
					<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#mensagemParaTeste#</pre>
				</cfif>
				<div style="background-color: ##00416B; color:##fff; border-radius: 10px; padding: 20px; box-shadow: 0px 0px 10px ##888888; max-width: 700px; margin: 0 auto; float: left;">
					<div style="background-color:##fff ; color:##00416B; border-radius: 10px; padding-top: 2px;padding-bottom: 2px;padding-left: 15px;padding-right: 10px; box-shadow: 0px 0px 10px ##888888;text-align: center;">
						<p style="font-size:20px">SNCI - Sistema Nacional de Controle Interno - Módulo: Processos</p> 
					</div> 
					<cfoutput>
						<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#arguments.pronomeTratamento#,</pre>
						<div style="text-align: justify;font-family: inherit;font-weight: 500;line-height: 1.2;">#texto#</div>
						<div style="background-color:##fff ; color:##00416B; border-radius: 10px; padding-top: 2px;padding-bottom: 2px;padding-left: 15px;padding-right: 10px; box-shadow: 0px 0px 10px ##888888;">
							<p>Estamos à disposição para prestar informações adicionais a respeito do 
							assunto, caso seja necessário.</p>
						
							<p><strong>CS/DIGOE/SUGOV/DCINT/GPCI - Gerência de Planejamento de Controle Interno</strong></p>
							
							<p><strong>Obs:</strong> Este é um e-mail automático, por favor não responda.</p>
						</div>
					</cfoutput>
				</div>
			</cfmail>
			<cfset sucesso = true>
			<cfcatch type="any">
				<cfset sucesso = false>
			</cfcatch>

			
    	</cftry>
		<cfreturn #sucesso# />
    </cffunction>




	<cffunction name="rotinaDiariaOrientacoesSuspensas" access="remote"  hint="Verifica os pontos suspensos vencidos e transforma em TRATAMENTO, insere um posicionamento e envia um e-mail de alerta.">
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
							,'00436699'
							,'#pc_aval_orientacao_mcu_orgaoResp#'
							,'#dataCFQUERY#'
							,5
							,1
						)
				</cfquery>

				<cftry>
					<!--Informações do órgão responsável-->
					<cfquery name="rsOrgaoResp" datasource="#application.dsn_processos#">
						SELECT pc_org_emaiL, pc_org_sigla FROM pc_orgaos
						WHERE pc_org_mcu = <cfqueryparam value="#pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfset to = "#LTrim(RTrim(rsOrgaoResp.pc_org_email))#">
					<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrgaoResp.pc_org_sigla))#">
					<cfset pronomeTrat = "Senhor(a) Gestor(a) da #siglaOrgaoResponsavel#">
					
					<cfset textoEmail = '<p>Solicita-se atualizar as informações do andamento das ações para regularização da Orientação ID #pc_aval_orientacao_id#, no processo SNCI N° #pc_aval_processo#, considerando sua última manifestação quanto as tratativas com órgão externo. Incluir no SNCI as evidências das tratativas/ações adotadas.</p> 
										 <p>Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "MEDIDAS/ORIENTAÇÕES PARA REGULARIZAÇÃO " e inserir sua resposta:</p>
										 <p><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>'>
								
					<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
					<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
								para = "#to#"
								pronomeTratamento = "#pronomeTrat#"
								texto="#textoEmail#"
					/>
					<cfcatch type="any">
					<cfset de="SNCI@correios.com.br">
					<cfif application.auxsite eq "localhost">
						<cfset de="mbflpa@yahoo.com.br">
					</cfif>
						<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
							<cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
						</cfmail>
					</cfcatch>
				</cftry>

				
			</cftransaction>
			

		</cfoutput>
	</cffunction>

	<cffunction name="rotinaDiariaOrientacoesSuspensasTeste" access="remote"  hint="Verifica os pontos suspensos vencidos e transforma em TRATAMENTO, insere um posicionamento e envia um e-mail de alerta.">
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
							,'00436699'
							,'#pc_aval_orientacao_mcu_orgaoResp#'
							,'#dataCFQUERY#'
							,5
							,1
						)
				</cfquery>

				<cftry>
					<!--Informações do órgão responsável-->
					<cfquery name="rsOrgaoResp" datasource="#application.dsn_processos#">
						SELECT pc_org_emaiL, pc_org_sigla FROM pc_orgaos
						WHERE pc_org_mcu = <cfqueryparam value="#pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfset to = "#LTrim(RTrim(rsOrgaoResp.pc_org_email))#">
					<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrgaoResp.pc_org_sigla))#">
					<cfset pronomeTrat = "Senhor(a) Gestor(a) da #siglaOrgaoResponsavel#">
					
					<cfset textoEmail = '<p>Solicita-se atualizar as informações do andamento das ações para regularização da Orientação ID #pc_aval_orientacao_id#, no processo SNCI N° #pc_aval_processo#, considerando sua última manifestação quanto as tratativas com órgão externo. Incluir no SNCI as evidências das tratativas/ações adotadas.</p> 
										 <p>Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "MEDIDAS/ORIENTAÇÕES PARA REGULARIZAÇÃO " e inserir sua resposta:</p>
										 <p><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>'>
								
					<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
					<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmailsTeste" returnVariable="sucessoEmail" 
								para = "#to#"
								pronomeTratamento = "#pronomeTrat#"
								texto="#textoEmail#"
					/>
					<cfcatch type="any">
					<cfset de="SNCI@correios.com.br">
					<cfif application.auxsite eq "localhost">
						<cfset de="mbflpa@yahoo.com.br">
					</cfif>
						<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
							<cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
						</cfmail>
					</cfcatch>
				</cftry>

				
			</cftransaction>
			

		</cfoutput>
	</cffunction>



	<cffunction name="rotinaSemanalOrientacoesPendentes" access="remote"  hint="Verifica or órgãos responsáveis pelas orientações pendentes e encaminha e-mail de alerta.">
		<cfsetting RequestTimeout = "0"> 
		<cfquery name="rsOrgaosComOrientacoesPendentes" datasource="#application.dsn_processos#" >
			SELECT DISTINCT pc_aval_orientacao_mcu_orgaoResp
			FROM pc_avaliacao_orientacoes
			WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
		</cfquery>

		<cfquery name="rsOrgaosComOrientacoesPendentesParaTeste" datasource="#application.dsn_processos#">
			SELECT DISTINCT TOP 5 pc_aval_orientacao_mcu_orgaoResp
			FROM pc_avaliacao_orientacoes
			WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
		</cfquery>


		<cfif application.auxsite neq 'intranetsistemaspe'>
			<cfset myQuery = "rsOrgaosComOrientacoesPendentesParaTeste">
		<cfelse>
			<cfset myQuery = "rsOrgaosComOrientacoesPendentes">
		</cfif>

		<cfloop query="#myQuery#">
                        
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
				right JOIN pc_avaliacoes on pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval
				right JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
				right JOIN pc_avaliacao_tipos on pc_aval_tipo_id = pc_processos.pc_num_avaliacao_tipo
				right JOIN pc_orientacao_status on pc_orientacao_status_id = pc_avaliacao_orientacoes.pc_aval_orientacao_status
				right JOIN pc_orgaos as orgaoAvaliado on orgaoAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				right JOIN pc_orgaos as orgaoResp on orgaoResp.pc_org_mcu = pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp

				WHERE pc_aval_orientacao_mcu_orgaoResp = '#pc_aval_orientacao_mcu_orgaoResp#' and pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate() 
				ORDER BY pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp
			</cfquery>

			<cfquery name="rsOrientacoesOutrosStatus" datasource="#application.dsn_processos#" >
				SELECT  pc_avaliacao_orientacoes.pc_aval_orientacao_id, pc_orientacao_status.pc_orientacao_status_descricao                
				FROM pc_avaliacao_orientacoes
				right JOIN pc_orientacao_status on pc_orientacao_status_id = pc_avaliacao_orientacoes.pc_aval_orientacao_status
				WHERE pc_aval_orientacao_mcu_orgaoResp = '#pc_aval_orientacao_mcu_orgaoResp#' and (pc_avaliacao_orientacoes.pc_aval_orientacao_status in (2,16)  or (pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp >= getdate()))
			</cfquery>

			
			<cftry>
				<cfset to = "#LTrim(RTrim(rsOrientacoesPendentes.emailOrgaoResp))#">
				<cfset cc = "#LTrim(RTrim(rsOrientacoesPendentes.emailOrgaoAvaliado))#">

				<cfif application.auxsite neq "intranetsistemaspe">
					<cfset mensagemParaTeste="Atenção, este é um e-mail de teste! No servidor de produção, este e-mail seria encaminhado para <strong>#to#</strong> pois é o e-mail do órgão responsável pelas orientações, com cópia para <strong>#cc#</strong> pois é o e-mail do órgão avaliado.">
					<cfset to = "marceloferreira@correios.com.br">
					<cfset cc = "">
				</cfif>
					
				<cfset de="SNCI@correios.com.br">
				<cfif application.auxsite eq "localhost">
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
			
				
				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrientacoesPendentes.siglaOrgaoResp))#">
				<cfset pronomeTrat = "Senhor(a) Gestor do(a) #siglaOrgaoResponsavel#">
				<cfmail from="#de#" to="#to#" cc="#cc#" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
					<!DOCTYPE html>
					<html lang="pt-br">
					<head>
						<meta charset="UTF-8">
						<meta http-equiv="X-UA-Compatible" content="IE=edge">
						<meta name="viewport" content="width=device-width, initial-scale=1.0">

						<style>
			
							.table-striped tbody tr:nth-of-type(odd) {
								background-color: rgba(0,0,0,.05);
							}

							.text-nowrap {
								white-space: nowrap !important;
							}
							.table-bordered {
								border: 1px solid ##dee2e6;
							}
						
						
							*, *::before, *::after {
								box-sizing: border-box;
							}

							table {
								width: 100%;
								margin-bottom: 1rem;
								color: ##212529;
								background-color: transparent;
								display: table;
								border-collapse: separate;
								box-sizing: border-box;
								text-indent: initial;
								border-spacing: 2px;
								border-color: gray;
							}

							table tr{
								color: ##fff;
							}
							.card-body {
								text-align: justify!important;
							}
							.card {
								position: relative;
								display: -ms-flexbox;
								display: flex;
								-ms-flex-direction: column;
								flex-direction: column;
								min-width: 0;
								word-wrap: break-word;
								background-color: ##fff;
								background-clip: border-box;
								border: 0 solid rgba(0, 0, 0, 0.125);
								border-radius: 0.25rem;
							}
							.card {
								position: relative;
								display: -ms-flexbox;
								display: flex;
								-ms-flex-direction: column;
								flex-direction: column;
								min-width: 0;
								word-wrap: break-word;
								background-color: ##fff;
								background-clip: border-box;
								border: 0 solid rgba(0, 0, 0, 0.125);
								border-radius: 0.25rem;
							}
							body {
							
								font-family: "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
								font-size: 0.8rem;
								font-weight: 400;
								line-height: 1.5;
								color: ##212529;
								text-align: left;
								background-color: ##fff;
							}
							th {
								text-align: center;
								padding-left: 0.75rem;
								padding-right: 0.75rem;

							}


						
						</style>
					</head>
					<body>

						<cfif application.auxsite neq "intranetsistemaspe">
							<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#mensagemParaTeste#</pre>
						</cfif>
						<div style="background-color: ##00416B; color:##fff; border-radius: 15px; padding: 5px; box-shadow: 0px 0px 10px ##888888; margin: 0 auto; float: left;">
							<div style="background-color:##fff ; color:##00416B; border-radius: 10px;box-shadow: 0px 0px 10px ##888888;text-align: center;">
								<span style="font-size:20px">SNCI - Sistema Nacional de Controle Interno - Módulo: Processos</span> 
							</div> 
							<cfoutput>
								<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#pronomeTrat#,</pre>
								<cfif rsOrientacoesPendentes.recordcount eq 1>
									<p style="text-align: justify;font-family: inherit;font-weight: 500;line-height: 1.2;">Informamos que existe #NumberFormat(rsOrientacoesPendentes.recordcount,"00")# apontamento registrado pelo Controle Interno, status “PENDENTE”, com prazo de resposta expirado no Sistema SNCI, ao qual solicitamos especial atenção, conforme segue: </p>
								<cfelseif rsOrientacoesPendentes.recordcount gt 1>
									<p style="text-align: justify;font-family: inherit;font-weight: 500;line-height: 1.2;">Informamos que existem #NumberFormat(rsOrientacoesPendentes.recordcount,"00")# apontamentos registrados pelo Controle Interno, status “PENDENTE”, com prazo de resposta expirado no Sistema SNCI, aos quais solicitamos especial atenção, conforme relação a seguir: </p>
								</cfif>
								<table id="tabOrientacoes" class="table-hover table-striped">
									<thead style="background: ##0083ca;color:##fff">
										<tr style="font-size:14px">
											<th >ID da Orientação</th>
											<th >N° Processo SNCI</th>
											<th >N° Item</th>
											<th >Data Prevista p/ Resposta</th>
											<th >N° SEI</th>
											<th >N° Relatório SEI</th>
											<th >Tipo de Avaliação:</th>	
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="#rsOrientacoesPendentes#" >
											<cfoutput>					
												<tr style="font-size:12px;cursor:pointer;z-index:2;"  >
													<td align="center" >#pc_aval_orientacao_id#</td>
													<td align="center" >#pc_processo_id#</td>
													<td align="center" >#pc_aval_numeracao#</td>	
													<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,"DD-MM-YYYY") >
													<td align="center" >#dataPrev#</td>
													<cfset sei = left(#pc_num_sei#,5) & "."& mid(#pc_num_sei#,6,6) &"/"& mid(#pc_num_sei#,12,4) &"-"&right(#pc_num_sei#,2)>
													<td align="center" >#sei#</td>
													<td align="center" >#pc_num_rel_sei#</td>
													<cfif pc_num_avaliacao_tipo neq 2>
														<td >#pc_aval_tipo_descricao#</td>
													<cfelse>
														<td >#pc_aval_tipo_nao_aplica_descricao#</td>
													</cfif>
												</tr>
											</cfoutput>
										</cfloop>	
									</tbody>
								</table>
								<p>Para regularizar a situação, solicitamos a acessar o link abaixo, tela "Acompanhamento", aba “Medidas / Orientações para regularização” e inserir sua resposta:<br><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>
								<cfif rsOrientacoesOutrosStatus.recordcount gt 1>    
									<p>Na oportunidade informa-se que existem, ainda, #NumberFormat(rsOrientacoesOutrosStatus.recordcount,"00")# orientações de Controle Interno com outros status que estão dentro do prazo previsto. Para esses casos orienta-se a atentar para a DATA PREVISTA PARA RESPOSTA, registrada no SNCI. Essa é a data em que se encerra o prazo para registro das manifestações no sistema SNCI, com acesso pelo mesmo link acima, conforme orientações anteriores.</p> 
								<cfelseif rsOrientacoesOutrosStatus.recordcount eq 1>
									<p>Na oportunidade informa-se que existe, ainda, #NumberFormat(rsOrientacoesOutrosStatus.recordcount,"00")# orientação de Controle Interno com status "#rsOrientacoesOutrosStatus.pc_orientacao_status_descricao#" que está dentro do prazo previsto. Para esse caso orienta-se a atentar para a DATA PREVISTA PARA RESPOSTA, registrada no SNCI. Essa é a data em que se encerra o prazo para registro das manifestações no sistema SNCI, com acesso pelo mesmo link acima, conforme orientações anteriores.</p> 
								</cfif> 
								<div style="background-color:##fff ; color:##00416B; border-radius: 10px; padding-top: 2px;padding-bottom: 2px;padding-left: 15px;padding-right: 10px; box-shadow: 0px 0px 10px ##888888;width:600px">
									<p>Estamos à disposição para prestar informações adicionais a respeito do assunto, caso seja necessário.</p>
									<p><strong>CS/DIGOE/SUGOV/DCINT/GPCI - Gerência de Planejamento de Controle Interno</strong></p>
									<p><strong>Obs:</strong> Este é um e-mail automático, por favor não responda.</p>
								</div>
							</cfoutput>
						</div>

					</body>
					</html> 
				</cfmail>            
				<cfcatch type="any">
				<cfset de="SNCI@correios.com.br">
				<cfif application.auxsite eq "localhost">
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
					<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry> 

			
		</cfloop>


	</cffunction>

	<cffunction name="rotinaSemanalOrientacoesPendentesTeste" access="remote"  hint="Verifica or órgãos responsáveis pelas orientações pendentes e encaminha e-mail de alerta.">
		<cfsetting RequestTimeout = "0"> 
		<cfquery name="rsOrgaosComOrientacoesPendentes" datasource="#application.dsn_processos#" >
			SELECT DISTINCT pc_aval_orientacao_mcu_orgaoResp
			FROM pc_avaliacao_orientacoes
			WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
		</cfquery>

		<cfquery name="rsOrgaosComOrientacoesPendentesParaTeste" datasource="#application.dsn_processos#">
			SELECT DISTINCT TOP 30 pc_aval_orientacao_mcu_orgaoResp
			FROM pc_avaliacao_orientacoes
			WHERE pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate()
		</cfquery>


		<cfif application.auxsite neq 'intranetsistemaspe'>
			<cfset myQuery = "rsOrgaosComOrientacoesPendentesParaTeste">
		<cfelse>
			<cfset myQuery = "rsOrgaosComOrientacoesPendentes">
		</cfif>

		<cfloop query="#myQuery#">
                        
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
				right JOIN pc_avaliacoes on pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval
				right JOIN pc_processos on pc_processo_id = pc_avaliacoes.pc_aval_processo
				right JOIN pc_avaliacao_tipos on pc_aval_tipo_id = pc_processos.pc_num_avaliacao_tipo
				right JOIN pc_orientacao_status on pc_orientacao_status_id = pc_avaliacao_orientacoes.pc_aval_orientacao_status
				right JOIN pc_orgaos as orgaoAvaliado on orgaoAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				right JOIN pc_orgaos as orgaoResp on orgaoResp.pc_org_mcu = pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp

				WHERE pc_aval_orientacao_mcu_orgaoResp = '#pc_aval_orientacao_mcu_orgaoResp#' and pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp is not null and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp < getdate() 
				ORDER BY pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp
			</cfquery>

			<cfquery name="rsOrientacoesOutrosStatus" datasource="#application.dsn_processos#" >
				SELECT  pc_avaliacao_orientacoes.pc_aval_orientacao_id, pc_orientacao_status.pc_orientacao_status_descricao                
				FROM pc_avaliacao_orientacoes
				right JOIN pc_orientacao_status on pc_orientacao_status_id = pc_avaliacao_orientacoes.pc_aval_orientacao_status
				WHERE pc_aval_orientacao_mcu_orgaoResp = '#pc_aval_orientacao_mcu_orgaoResp#' and (pc_avaliacao_orientacoes.pc_aval_orientacao_status in (2,16)  or (pc_avaliacao_orientacoes.pc_aval_orientacao_status in (4,5) and pc_avaliacao_orientacoes.pc_aval_orientacao_dataPrevistaResp >= getdate()))
			</cfquery>

			
			<cftry>
				<cfset to = "#LTrim(RTrim(rsOrientacoesPendentes.emailOrgaoResp))#">
				<cfset cc = "#LTrim(RTrim(rsOrientacoesPendentes.emailOrgaoAvaliado))#">

				<cfif application.auxsite neq "intranetsistemaspe">
					<cfset mensagemParaTeste="Atenção, este é um e-mail de teste! No servidor de produção, este e-mail seria encaminhado para <strong>#to#</strong> pois é o e-mail do órgão responsável pelas orientações, com cópia para <strong>#cc#</strong> pois é o e-mail do órgão avaliado.">
					<cfset to = "#application.rsUsuarioParametros.pc_usu_email#">
					<cfset cc = "">
				</cfif>
					
				<cfset de="SNCI@correios.com.br">
				<cfif application.auxsite eq "localhost">
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
			
				
				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrientacoesPendentes.siglaOrgaoResp))#">
				<cfset pronomeTrat = "Senhor(a) Gestor do(a) #siglaOrgaoResponsavel#">
				<cfmail from="#de#" to="#to#" cc="#cc#" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
					<!DOCTYPE html>
					<html lang="pt-br">
					<head>
						<meta charset="UTF-8">
						<meta http-equiv="X-UA-Compatible" content="IE=edge">
						<meta name="viewport" content="width=device-width, initial-scale=1.0">

						<style>
			
							.table-striped tbody tr:nth-of-type(odd) {
								background-color: rgba(0,0,0,.05);
							}

							.text-nowrap {
								white-space: nowrap !important;
							}
							.table-bordered {
								border: 1px solid ##dee2e6;
							}
						
						
							*, *::before, *::after {
								box-sizing: border-box;
							}

							table {
								width: 100%;
								margin-bottom: 1rem;
								color: ##212529;
								background-color: transparent;
								display: table;
								border-collapse: separate;
								box-sizing: border-box;
								text-indent: initial;
								border-spacing: 2px;
								border-color: gray;
							}

							table tr{
								color: ##fff;
							}
							.card-body {
								text-align: justify!important;
							}
							.card {
								position: relative;
								display: -ms-flexbox;
								display: flex;
								-ms-flex-direction: column;
								flex-direction: column;
								min-width: 0;
								word-wrap: break-word;
								background-color: ##fff;
								background-clip: border-box;
								border: 0 solid rgba(0, 0, 0, 0.125);
								border-radius: 0.25rem;
							}
							.card {
								position: relative;
								display: -ms-flexbox;
								display: flex;
								-ms-flex-direction: column;
								flex-direction: column;
								min-width: 0;
								word-wrap: break-word;
								background-color: ##fff;
								background-clip: border-box;
								border: 0 solid rgba(0, 0, 0, 0.125);
								border-radius: 0.25rem;
							}
							body {
							
								font-family: "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
								font-size: 0.8rem;
								font-weight: 400;
								line-height: 1.5;
								color: ##212529;
								text-align: left;
								background-color: ##fff;
							}
							th {
								text-align: center;
								padding-left: 0.75rem;
								padding-right: 0.75rem;

							}


						
						</style>
					</head>
					<body>

						<cfif application.auxsite neq "intranetsistemaspe">
							<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#mensagemParaTeste#</pre>
						</cfif>
						<div style="background-color: ##00416B; color:##fff; border-radius: 15px; padding: 5px; box-shadow: 0px 0px 10px ##888888; margin: 0 auto; float: left;">
							<div style="background-color:##fff ; color:##00416B; border-radius: 10px;box-shadow: 0px 0px 10px ##888888;text-align: center;">
								<span style="font-size:20px">SNCI - Sistema Nacional de Controle Interno - Módulo: Processos</span> 
							</div> 
							<cfoutput>
								<pre style="font-family: inherit;font-weight: 500;line-height: 1.2;">#pronomeTrat#,</pre>
								<cfif rsOrientacoesPendentes.recordcount eq 1>
									<p style="text-align: justify;font-family: inherit;font-weight: 500;line-height: 1.2;">Informamos que existe #NumberFormat(rsOrientacoesPendentes.recordcount,"00")# apontamento registrado pelo Controle Interno, status “PENDENTE”, com prazo de resposta expirado no Sistema SNCI, ao qual solicitamos especial atenção, conforme segue: </p>
								<cfelseif rsOrientacoesPendentes.recordcount gt 1>
									<p style="text-align: justify;font-family: inherit;font-weight: 500;line-height: 1.2;">Informamos que existem #NumberFormat(rsOrientacoesPendentes.recordcount,"00")# apontamentos registrados pelo Controle Interno, status “PENDENTE”, com prazo de resposta expirado no Sistema SNCI, aos quais solicitamos especial atenção, conforme relação a seguir: </p>
								</cfif>
								<table id="tabOrientacoes" class="table-hover table-striped">
									<thead style="background: ##0083ca;color:##fff">
										<tr style="font-size:14px">
											<th >ID da Orientação</th>
											<th >N° Processo SNCI</th>
											<th >N° Item</th>
											<th >Data Prevista p/ Resposta</th>
											<th >N° SEI</th>
											<th >N° Relatório SEI</th>
											<th >Tipo de Avaliação:</th>	
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="#rsOrientacoesPendentes#" >
											<cfoutput>					
												<tr style="font-size:12px;cursor:pointer;z-index:2;"  >
													<td align="center" >#pc_aval_orientacao_id#</td>
													<td align="center" >#pc_processo_id#</td>
													<td align="center" >#pc_aval_numeracao#</td>	
													<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,"DD-MM-YYYY") >
													<td align="center" >#dataPrev#</td>
													<cfset sei = left(#pc_num_sei#,5) & "."& mid(#pc_num_sei#,6,6) &"/"& mid(#pc_num_sei#,12,4) &"-"&right(#pc_num_sei#,2)>
													<td align="center" >#sei#</td>
													<td align="center" >#pc_num_rel_sei#</td>
													<cfif pc_num_avaliacao_tipo neq 2>
														<td >#pc_aval_tipo_descricao#</td>
													<cfelse>
														<td >#pc_aval_tipo_nao_aplica_descricao#</td>
													</cfif>
												</tr>
											</cfoutput>
										</cfloop>	
									</tbody>
								</table>
								<p>Para regularizar a situação, solicitamos a acessar o link abaixo, tela "Acompanhamento", aba “Medidas / Orientações para regularização” e inserir sua resposta:<br><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>
								<cfif rsOrientacoesOutrosStatus.recordcount gt 1>    
									<p>Na oportunidade informa-se que existem, ainda, #NumberFormat(rsOrientacoesOutrosStatus.recordcount,"00")# orientações de Controle Interno com outros status que estão dentro do prazo previsto. Para esses casos orienta-se a atentar para a DATA PREVISTA PARA RESPOSTA, registrada no SNCI. Essa é a data em que se encerra o prazo para registro das manifestações no sistema SNCI, com acesso pelo mesmo link acima, conforme orientações anteriores.</p> 
								<cfelseif rsOrientacoesOutrosStatus.recordcount eq 1>
									<p>Na oportunidade informa-se que existe, ainda, #NumberFormat(rsOrientacoesOutrosStatus.recordcount,"00")# orientação de Controle Interno com status "#rsOrientacoesOutrosStatus.pc_orientacao_status_descricao#" que está dentro do prazo previsto. Para esse caso orienta-se a atentar para a DATA PREVISTA PARA RESPOSTA, registrada no SNCI. Essa é a data em que se encerra o prazo para registro das manifestações no sistema SNCI, com acesso pelo mesmo link acima, conforme orientações anteriores.</p> 
								</cfif> 
								<div style="background-color:##fff ; color:##00416B; border-radius: 10px; padding-top: 2px;padding-bottom: 2px;padding-left: 15px;padding-right: 10px; box-shadow: 0px 0px 10px ##888888;width:600px">
									<p>Estamos à disposição para prestar informações adicionais a respeito do assunto, caso seja necessário.</p>
									<p><strong>CS/DIGOE/SUGOV/DCINT/GPCI - Gerência de Planejamento de Controle Interno</strong></p>
									<p><strong>Obs:</strong> Este é um e-mail automático, por favor não responda.</p>
								</div>
							</cfoutput>
						</div>

					</body>
					</html> 
				</cfmail>            
				<cfcatch type="any">
				<cfset de="SNCI@correios.com.br">
				<cfif application.auxsite eq "localhost">
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
					<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry> 

			
		</cfloop>


	</cffunction>

	

	<cffunction name="rotinaMensalMelhoriasPendentes" access="remote"  hint="Verifica or órgãos responsáveis pelas propostas de melhoria pendentes e encaminha e-mail de alerta.">
		<cfsetting RequestTimeout = "0"> 
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

		<cfif application.auxsite neq 'intranetsistemaspe'>
			<cfset myQuery = "rsOrgaosComMelhoriasPendentesParaTeste">
		<cfelse>
			<cfset myQuery = "rsOrgaosComMelhoriasPendentes">
		</cfif>

		<cfloop query="#myQuery#">
			<cfquery name="rsMelhoriasPendentes" datasource="#application.dsn_processos#">
				SELECT pc_avaliacao_melhorias.*, pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_num_sei
				,pc_avaliacoes.pc_aval_numeracao , pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla as siglaOrgaoResp,  pc_orgaos.pc_org_mcu
				,pc_orgaos.pc_org_emaiL as emailOrgaoResp, pc_orgaosAvaliado.pc_org_emaiL as emailOrgaoAvaliado
				FROM pc_avaliacao_melhorias
				INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_melhoria_num_orgao
				INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
				INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
				INNER JOIN pc_orgaos as pc_orgaosAvaliado on pc_orgaosAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				WHERE pc_aval_melhoria_num_orgao = '#pc_aval_melhoria_num_orgao#' and pc_aval_melhoria_status = 'P' and pc_num_status in(4,5)
			</cfquery>

			<cftry>
				<cfset to = "#LTrim(RTrim(rsMelhoriasPendentes.emailOrgaoResp))#">
				<cfset cc = "#LTrim(RTrim(rsMelhoriasPendentes.emailOrgaoAvaliado))#">

				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsMelhoriasPendentes.siglaOrgaoResp))#">
				<cfset pronomeTrat = "Prezado Gestor">
				<cfset textoEmail = '<p>Informamos que existe(m) #NumberFormat(rsMelhoriasPendentes.recordcount,"00")# Proposta(s) de Melhoria registrada(s) pelo Controle Interno, no Sistema SNCI, com status “PENDENTE”, aguardando manifestação do gestor responsável.</p> 
									    <p>Para regularizar a situação, solicitamos acessar o sistema por meio do link abaixo, tela "Acompanhamento", aba "Propostas de Melhoria" e inserir sua resposta:</p>
										<p><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>
								        <p>As Propostas de Melhoria estão cadastradas no sistema com status "PENDENTE", para que os gestores dos órgãos avaliados registrem suas manifestações, observando as opções a seguir:</p>   
										<ul>
											<li>ACEITA: situação em que a "Proposta de Melhoria" é aceita pelo gestor. Neste caso, deverá ser informada a data prevista de implementação;</li><br>   
											<li>RECUSA: situação em que a "Proposta de Melhoria" é recusada pelo gestor, com registro da justificativa para essa ação;</li> <br> 
											<li>TROCA: situação em que o gestor propõe outra ação em substituição à "Proposta de Melhoria" sugerida pelo Controle Interno. Nesse caso indicar o prazo previsto de implementação.</li>  
										</ul>'>
										
				<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
				<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
							para = "#to#"
							copiaPara = "#cc#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
				/>
				<cfcatch type="any">
				<cfset de="SNCI@correios.com.br">
				<cfif application.auxsite eq "localhost">
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
					<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry>

		</cfloop>

	</cffunction>

	<cffunction name="rotinaMensalMelhoriasPendentesTeste" access="remote"  hint="Verifica or órgãos responsáveis pelas propostas de melhoria pendentes e encaminha e-mail de alerta.">
		<cfsetting RequestTimeout = "0"> 
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

		<cfif application.auxsite neq 'intranetsistemaspe'>
			<cfset myQuery = "rsOrgaosComMelhoriasPendentesParaTeste">
		<cfelse>
			<cfset myQuery = "rsOrgaosComMelhoriasPendentes">
		</cfif>

		<cfloop query="#myQuery#">
			<cfquery name="rsMelhoriasPendentes" datasource="#application.dsn_processos#">
				SELECT pc_avaliacao_melhorias.*, pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_num_sei
				,pc_avaliacoes.pc_aval_numeracao , pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla as siglaOrgaoResp,  pc_orgaos.pc_org_mcu
				,pc_orgaos.pc_org_emaiL as emailOrgaoResp, pc_orgaosAvaliado.pc_org_emaiL as emailOrgaoAvaliado
				FROM pc_avaliacao_melhorias
				INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_melhoria_num_orgao
				INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
				INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
				INNER JOIN pc_orgaos as pc_orgaosAvaliado on pc_orgaosAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				WHERE pc_aval_melhoria_num_orgao = '#pc_aval_melhoria_num_orgao#' and pc_aval_melhoria_status = 'P' and pc_num_status in(4,5)
			</cfquery>

			<cftry>
				<cfset to = "#LTrim(RTrim(rsMelhoriasPendentes.emailOrgaoResp))#">
				<cfset cc = "#LTrim(RTrim(rsMelhoriasPendentes.emailOrgaoAvaliado))#">

				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsMelhoriasPendentes.siglaOrgaoResp))#">
				<cfset pronomeTrat = "Prezado Gestor">
				<cfset textoEmail = '<p>Informamos que existe(m) #NumberFormat(rsMelhoriasPendentes.recordcount,"00")# Proposta(s) de Melhoria registrada(s) pelo Controle Interno, no Sistema SNCI, com status “PENDENTE”, aguardando manifestação do gestor responsável.</p> 
									    <p>Para regularizar a situação, solicitamos acessar o sistema por meio do link abaixo, tela "Acompanhamento", aba "Propostas de Melhoria" e inserir sua resposta:</p>
										<p><a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a></p>
								        <p>As Propostas de Melhoria estão cadastradas no sistema com status "PENDENTE", para que os gestores dos órgãos avaliados registrem suas manifestações, observando as opções a seguir:</p>   
										<ul>
											<li>ACEITA: situação em que a "Proposta de Melhoria" é aceita pelo gestor. Neste caso, deverá ser informada a data prevista de implementação;</li><br>   
											<li>RECUSA: situação em que a "Proposta de Melhoria" é recusada pelo gestor, com registro da justificativa para essa ação;</li> <br> 
											<li>TROCA: situação em que o gestor propõe outra ação em substituição à "Proposta de Melhoria" sugerida pelo Controle Interno. Nesse caso indicar o prazo previsto de implementação.</li>  
										</ul>'>
										
				<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
				<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmailsTeste" returnVariable="sucessoEmail" 
							para = "#to#"
							copiaPara = "#cc#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
				/>
				<cfcatch type="any">
				<cfset de="SNCI@correios.com.br">
				<cfif application.auxsite eq "localhost">
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
					<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry>

		</cfloop>

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

					if (typeof cutNode !== 'undefined' && cutNode==="true") {// Verifica se existe algum nó selecionado e se cutNode não é null	
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
							cutNode.cut = false; // cancela seleção
							$('#pasteNodeBtn_' + cutNode.tId).hide(); // Mostra o botão usando jQuery
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
									cutNode.cut = false; // cancela seleção
									$('#pasteNodeBtn_' + cutNode.tId).hide(); // Mostra o botão usando jQuery
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
	


	
</cfcomponent>