<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	
    
    <cffunction name="cardsLinks" access="remote" hint="enviar os cards dos Controle para a páginas pc_Pefis">

		<!DOCTYPE html>
		<html lang="pt-br">
			<head>
				<style>
					/* Mantendo apenas os estilos personalizados que não existem no Bootstrap */
					
					/* Efeito de elevação no hover - não existe no Bootstrap */
					.card-hover {
						transition: all 0.3s ease;
					}
					
					.card-hover:hover {
						box-shadow: 0 8px 16px rgba(0,0,0,0.15) !important;
						transform: translateY(-5px);
					}
					
					/* Gradiente personalizado para o cabeçalho */
					.bg-gradient-primary {
						background: linear-gradient(135deg, #2475b3, #3498db);
						border-bottom: 3px solid #1a5480;
					}
					
					/* Estilo para ícones nos botões de ação */
					.btn-icon {
						cursor: pointer;
						transition: all 0.2s;
					}
					
					.btn-icon-excluir {
						color: #fff;
						opacity: 0.8;
					}
					
					.btn-icon-excluir:hover {
						color: #e74c3c;
						opacity: 1;
					}
					
					.btn-icon-editar {
						color: #fff;
					}
					
					.btn-icon-editar:hover {
						opacity: 0.9;
					}
					
					.grow-icon:hover {
						transform: scale(1.2);
					}
					
					/* Estilo para os textos destacados */
					.destaque {
						font-weight: 600;
						color: #2475b3;
						display: inline-block;
						padding: 0 5px;
						background-color: rgba(52, 152, 219, 0.05);
						border-radius: 3px;
					}
					
					/* Campo de busca personalizado - borda arredondada */
					.search-rounded {
						border-radius: 20px !important;
						padding-right: 40px !important;
					}
					
					/* Posicionamento do ícone de pesquisa */
					.search-icon-position {
						position: absolute;
						right: 12px;
						top: 50%;
						transform: translateY(-50%);
						color: #3498db;
						font-size: 16px;
					}
					
					/* Borda lateral nos itens da lista */
					.border-left-info {
						border-left: 3px solid #3498db;
						padding-left: 5px;
					}
				</style>
			</head>
			<body>
				<div class="card shadow-sm" style="border-radius: 8px; border: solid 2px #ffD400;">
						<div class="position-relative mb-3" style="max-width: 400px;margin-left: 7px;margin-top: 7px;">
							<input type="text" id="cardSearch" class="form-control search-rounded" placeholder="Buscar menus, páginas..." autocomplete="off">
							<i class="fas fa-search search-icon-position"></i>
						</div>

						<cfquery name="rsControleCards" datasource="#application.dsn_processos#">
							SELECT pc_controle_acesso.* from pc_controle_acesso 
							<cfif #application.rsUsuarioParametros.pc_usu_matricula# neq '80859992'>
								where not pc_controle_acesso_pagina = 'pc_ApoioDeletaProcessos.cfm'
							</cfif>
						</cfquery>	
						
						<div class="row mx-0" id="cardsContainer">
							<cfloop query="rsControleCards">
								<cfset grupo= ''>
								<cfset subgrupo= ''>
								<cfif #pc_controle_acesso_grupoMenu# neq ''>
									<cfset grupo = '#pc_controle_acesso_grupoMenu# > '>
								</cfif>
								<cfif #pc_controle_acesso_subgrupoMenu# neq ''>
									<cfset subgrupo = '#pc_controle_acesso_subgrupoMenu# > '>
								</cfif>
								<cfset link = '#grupo##subgrupo#'>
								
								<!--- Verifica se tem ícone, caso contrário usa um padrão --->
								<cfset iconeMenu = "fa-cog">
								<cfif #pc_controle_acesso_menu_icone# neq '' AND #pc_controle_acesso_menu_icone# neq '0'>
									<cfset iconeMenu = "#pc_controle_acesso_menu_icone#">
								</cfif>
								
								<cfoutput>
								<div class="col-sm-6 col-md-4 col-lg-3 mb-3 card-filterable">
									<div class="card shadow-sm card-hover bg-light h-100">
										<div class="card-header azul_claro_correios_backgroundColor text-white d-flex align-items-center position-relative" style="padding: 0.5rem 1rem;">
											<i class="fas #iconeMenu# mr-2"></i>
											<strong>#pc_controle_acesso_nomeMenu#</strong>
											
											<div class="position-absolute" style="right:10px; top:50%; transform:translateY(-50%); display:flex;">
												<div class="btn-icon btn-icon-editar ml-3" onclick="javascript:controleEditar(#pc_controle_acesso_id#,'#pc_controle_acesso_nomeMenu#','#pc_controle_acesso_pagina#','#pc_controle_acesso_perfis#','#pc_controle_acesso_grupoMenu#','#pc_controle_acesso_subgrupoMenu#','#pc_controle_acesso_grupo_icone#','#pc_controle_acesso_subgrupo_icone#','#pc_controle_acesso_menu_icone#','#pc_controle_acesso_ordem#','#pc_controle_acesso_rapido_nome#')" data-toggle="tooltip" title="Editar">
													<i class="fas fa-edit grow-icon"></i>
												</div>
												<div class="btn-icon btn-icon-excluir ml-3" onclick="javascript:controleExcluir(#pc_controle_acesso_id#)" data-toggle="tooltip" title="Excluir">
													<i class="fas fa-trash-alt grow-icon"></i>
												</div>
											</div>
										</div>
										
										<div class="card-body">
											<p class="border-left-info mb-2"><strong>Menu:</strong> <span class="destaque">#link##pc_controle_acesso_nomeMenu#</span></p>
											<p class="border-left-info mb-0"><strong>Página:</strong> <span class="destaque">#pc_controle_acesso_pagina#</span></p>
										</div>
									</div>
								</div>
								</cfoutput>
							</cfloop>
							<div class="col-12 d-none" id="no-results">
								<div class="text-center p-4 bg-light rounded">
									<i class="fas fa-search mb-2" style="font-size: 30px; opacity: 0.5;"></i>
									<h4>Nenhum resultado encontrado</h4>
									<p>Tente buscar com outros termos</p>
								</div>
							</div>
						</div>
				</div>
			</body>

			<script language="JavaScript">
				$(function () {
					// Inicializar tooltips do Bootstrap
					$('[data-toggle="tooltip"]').tooltip();
					
					// Configurar campo de busca - versão corrigida e com escopo limitado
					$('#cardSearch').on('input', function() {
						const searchValue = $(this).val().toLowerCase().trim();
						let hasResults = false;
						
						// Se o campo de busca estiver vazio, mostre todos os cards
						if (searchValue === '') {
							$('#cardsContainer .card-filterable').show();
							$('#no-results').addClass('d-none');
							return;
						}
						
						$('#cardsContainer .card-filterable').each(function() {
							// Busca no conteúdo completo do card
							const cardText = $(this).text().toLowerCase();
							
							if (cardText.indexOf(searchValue) > -1) {
								$(this).show();
								hasResults = true;
							} else {
								$(this).hide();
							}
						});
						
						// Mostrar mensagem se não houver resultados
						if (hasResults) {
							$('#no-results').addClass('d-none');
						} else {
							$('#no-results').removeClass('d-none');
						}
					});
					
					// Datatable foi substituído por grid CSS, mas vamos manter o código
					// para compatibilidade, se necessário
					if ($.fn.DataTable) {
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
								[10, 25, 50, 'Todos'],
							],
							language: {url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"}
						});
					}
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