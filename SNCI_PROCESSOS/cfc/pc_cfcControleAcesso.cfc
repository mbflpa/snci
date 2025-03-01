<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	
    
    <cffunction name="cardsLinks" access="remote" hint="enviar os cards dos Controle para a páginas pc_Pefis">

		<!DOCTYPE html>
		<html lang="pt-br">
			<head>
				<style>
					/* Classes que podem ser substituídas pelo Bootstrap 4 */
					
					/*
					.card-controle - pode usar .card .shadow-sm .mb-3
					Mantida pela animação de hover personalizada
					*/
					.card-controle {
						border-radius: 8px;
						box-shadow: 0 4px 8px rgba(0,0,0,0.1);
						transition: all 0.3s ease;
						overflow: hidden;
						margin-bottom: 15px;
						background-color: #f9f9f9;
					}
					
					/* Efeito hover não tem equivalente no Bootstrap */
					.card-controle:hover {
						box-shadow: 0 8px 16px rgba(0,0,0,0.15);
						transform: translateY(-5px);
					}
					
					/* Pode usar .card-header .bg-primary .text-white .d-flex .align-items-center */
					/* Mantida pelo gradient personalizado */
					.card-header-controle {
						padding: 12px 15px;
						display: flex;
						align-items: center;
						background: linear-gradient(135deg, #2475b3, #3498db);
						color: #fff;
						border-bottom: 3px solid #1a5480;
						position: relative;
					}
					
					/* Pode usar .mr-2 e personalizar só o tamanho */
					.card-header-controle i {
						margin-right: 10px;
						font-size: 18px;
					}
					
					/* Posicionamento específico - manter personalizado */
					.card-tools {
						position: absolute;
						right: 10px;
						top: 50%;
						transform: translateY(-50%);
						display: flex;
						align-items: center;
					}
					
					/* Pode usar .d-flex .align-items-center .justify-content-center */
					.card-tools .btn-card {
						display: flex;
						align-items: center;
						justify-content: center;
						cursor: pointer;
						transition: all 0.2s;
						margin-left: 30px;
					}
					
					/* Estilização específica de ícones - manter */
					.card-tools .btn-excluir i {
						color: #fff; /* Ícone branco */
						opacity: 0.8; /* Um pouco transparente */
					}
					
					.card-tools .btn-excluir:hover i {
						color: #e74c3c; /* Fica vermelho ao passar o mouse */
						opacity: 1;
					}
					
					.card-tools .btn-editar i {
						color: #fff; /* Ícone branco conforme solicitado */
					}
					
					.card-tools .btn-editar:hover i {
						opacity: 0.9;
					}
					
					.grow-icon:hover {
						transform: scale(1.2);
					}
					
					.card-body-controle {
						padding: 20px; /* Aumentado o padding */
						position: relative;
						min-height: 100px;
						background-color: #f9f9f9; /* Fundo sutilmente diferente */
					}
					
					.card-info {
						position: relative;
						z-index: 2;
					}
					
					.card-info p {
						margin-bottom: 12px; /* Aumentado o espaço entre linhas */
						color: #444;
						padding-left: 5px;
						border-left: 3px solid #3498db; /* Borda lateral para melhor organização visual */
						padding-bottom: 3px;
					}
					
					.card-info p:last-child {
						margin-bottom: 0; /* Remover margem do último parágrafo */
					}
					
					.card-info span.destaque {
						font-weight: 600;
						color: #2475b3;
						display: inline-block; /* Para permitir padding sem quebra de linha */
						padding: 0 5px;
						background-color: rgba(52, 152, 219, 0.05); /* Fundo sutil no texto destacado */
						border-radius: 3px;
					}
					
					/* Grid layout pode usar .row e .col-* do Bootstrap */
					.grid-container {
						display: grid;
						grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
						grid-gap: 20px;
					}
					
					@media (max-width: 768px) {
						.grid-container {
							grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
						}
					}
					
					/* Campo de busca pode usar .form-control do Bootstrap */
					.search-container {
						margin-bottom: 10px;
						position: relative;
						max-width: 400px;
						margin-left: 0;
						margin-right: 0;
						padding-left: 0;
					}
					
					.search-container input {
						/* Pode usar .form-control e apenas personalizar o padding */
						width: 100%;
						padding: 8px 40px 8px 12px;
						border-radius: 20px;
						border: 1px solid #ddd;
						box-shadow: 0 2px 5px rgba(0,0,0,0.05);
						font-size: 14px;
						transition: all 0.3s;
					}
					
					.search-container input:focus {
						border-color: #3498db;
						box-shadow: 0 2px 10px rgba(52, 152, 219, 0.2);
						outline: none;
					}
					
					.search-container i {
						position: absolute;
						right: 12px;
						top: 50%;
						transform: translateY(-50%);
						color: #3498db;
						font-size: 16px;
					}
					
					.no-results {
						grid-column: 1 / -1;
						padding: 20px;
						text-align: center;
						background-color: #f8f9fa;
						border-radius: 8px;
						color: #666;
					}
				</style>
			</head>
			<body>
				<!-- Aqui poderia usar classes do Bootstrap como .container, .card, etc. -->
				<div class="card-body" style="border-radius: 8px; box-shadow: 0 0 5px rgba(255, 212, 0, 0.3); border: solid 2px #ffD400;">
						<div class="search-container">
							<input type="text" id="cardSearch" placeholder="Buscar menus, páginas..." autocomplete="off">
							<i class="fas fa-search"></i>
						</div>

						<cfquery name="rsControleCards" datasource="#application.dsn_processos#">
							SELECT pc_controle_acesso.* from pc_controle_acesso 
							<cfif #application.rsUsuarioParametros.pc_usu_matricula# neq '80859992'>
								where not pc_controle_acesso_pagina = 'pc_ApoioDeletaProcessos.cfm'
							</cfif>
						</cfquery>	
						
						<div class="grid-container" id="cardsContainer">
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
								<div class="card-controle">
									<div class="card-header-controle">
										<i class="fas #iconeMenu#"></i>
										<strong>#pc_controle_acesso_nomeMenu#</strong>
										
										<!-- Adicionado card-tools com os botões de ação -->
										<div class="card-tools">
											<div class="btn-card btn-editar" onclick="javascript:controleEditar(#pc_controle_acesso_id#,'#pc_controle_acesso_nomeMenu#','#pc_controle_acesso_pagina#','#pc_controle_acesso_perfis#','#pc_controle_acesso_grupoMenu#','#pc_controle_acesso_subgrupoMenu#','#pc_controle_acesso_grupo_icone#','#pc_controle_acesso_subgrupo_icone#','#pc_controle_acesso_menu_icone#','#pc_controle_acesso_ordem#','#pc_controle_acesso_rapido_nome#')" data-toggle="tooltip" title="Editar">
												<i class="fas fa-edit grow-icon"></i>
											</div>
											<div class="btn-card btn-excluir" onclick="javascript:controleExcluir(#pc_controle_acesso_id#)" data-toggle="tooltip" title="Excluir">
												<i class="fas fa-trash-alt grow-icon"></i>
											</div>
										</div>
									</div>
									
									<div class="card-body-controle">
										<div class="card-info">
											<p><strong>Menu:</strong> <span class="destaque">#link##pc_controle_acesso_nomeMenu#</span></p>
											<p><strong>Página:</strong> <span class="destaque">#pc_controle_acesso_pagina#</span></p>
										</div>
									</div>
									
									<!-- Footer removido pois os botões foram movidos para o header -->
								</div>
								</cfoutput>
							</cfloop>
							<div class="no-results" style="display: none;">
								<i class="fas fa-search" style="font-size: 30px; opacity: 0.5; margin-bottom: 10px;"></i>
								<h4>Nenhum resultado encontrado</h4>
								<p>Tente buscar com outros termos</p>
							</div>
						</div>
				</div>
			</body>

			<script language="JavaScript">
				$(function () {
					// Inicializar tooltips do Bootstrap
					$('[data-toggle="tooltip"]').tooltip();
					
					// Removido o código de animação de hover relacionado aos ícones internos
					
					// Configurar campo de busca - versão corrigida
					$('#cardSearch').on('input', function() {
						const searchValue = $(this).val().toLowerCase().trim();
						let hasResults = false;
						
						// Se o campo de busca estiver vazio, mostre todos os cards
						if (searchValue === '') {
							$('.card-controle').show();
							$('.no-results').hide();
							return;
						}
						
						$('.card-controle').each(function() {
							// Busca no conteúdo completo do card, não apenas nos atributos data-*
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
							$('.no-results').hide();
						} else {
							$('.no-results').show();
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