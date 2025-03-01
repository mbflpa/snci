<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	
    
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
							<thead  class="table_thead_backgroundColor" >
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
													<div class="small-box azul_claro_correios_backgroundColor" style="font-weight: normal;color: #fff;font-weight: normal;">
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
																onclick="javascript:controleEditar(<cfoutput>#pc_controle_acesso_id#,'#pc_controle_acesso_nomeMenu#','#pc_controle_acesso_pagina#','#pc_controle_acesso_perfis#','#pc_controle_acesso_grupoMenu#','#pc_controle_acesso_subgrupoMenu#','#pc_controle_acesso_grupo_icone#','#pc_controle_acesso_subgrupo_icone#','#pc_controle_acesso_menu_icone#','#pc_controle_acesso_ordem#','#pc_controle_acesso_rapido_nome#'</cfoutput>)" data-toggle="tooltip"  tilte="Editar"></i>
																
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
						],
						language: {url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"}
						
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
		<cfargument name="pc_controle_acesso_rapido_nome" type="string" required="true"/>

		

		<cfquery datasource="#application.dsn_processos#" >
			<cfif #arguments.pc_controle_acesso_id# eq ''>
				INSERT pc_controle_acesso (pc_controle_acesso_nomeMenu,pc_controle_acesso_pagina,pc_controle_acesso_perfis,pc_controle_acesso_grupoMenu
				        ,pc_controle_acesso_subgrupoMenu,pc_controle_acesso_grupo_icone,pc_controle_acesso_subgrupo_icone
						,pc_controle_acesso_menu_icone,pc_controle_acesso_ordem,pc_controle_acesso_rapido_nome)
				VALUES (
						<cfqueryparam value="#arguments.pc_controle_acesso_nomeMenu#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_pagina#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_perfis#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_grupoMenu#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_subgrupoMenu#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_grupo_icone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_subgrupo_icone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_menu_icone#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_controle_acesso_ordem#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.pc_controle_acesso_rapido_nome#" cfsqltype="cf_sql_varchar">
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
					pc_controle_acesso_ordem = <cfqueryparam value="#arguments.pc_controle_acesso_ordem#" cfsqltype="cf_sql_integer">,
					pc_controle_acesso_rapido_nome = <cfqueryparam value="#arguments.pc_controle_acesso_rapido_nome#" cfsqltype="cf_sql_varchar">
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

</cfcomponent>