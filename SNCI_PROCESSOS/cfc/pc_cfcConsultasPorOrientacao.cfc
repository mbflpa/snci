<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	


	<cfquery name="rsHerancaUnion" datasource="#application.dsn_processos#">
		SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' 

		union

		SELECT  pc_orgaos2.pc_org_mcu
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' )) 

		union

		select pc_orgaos.pc_org_mcu AS mcuHerdado
		from pc_orgaos
		LEFT JOIN pc_orgaos_heranca ON pc_orgHerancaMcuDe = pc_org_mcu
		where pc_orgaos.pc_org_mcu_subord_tec in(SELECT  pc_orgaos2.pc_org_mcu
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in(SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' )))
	</cfquery>

	<cfquery dbtype="query" name="rsHeranca"> 
		SELECT mcuHerdado FROM rsHerancaUnion WHERE not mcuHerdado is null
	</cfquery>

	<cfset mcusHeranca = ValueList(rsHeranca.mcuHerdado) />

    



   	<cffunction name="tabConsulta" returntype="any" access="remote" hint="Criar a tabela dos processos e envia para a página pcConsulta.cfm">
	   	
	   	<cfargument name="ano" type="string" required="true"  />
	  	<cfargument name="processoEmAcompanhamento" type="boolean" required="false" default="true" />


		<cfquery name="getOrgHierarchy" datasource="#application.dsn_processos#" timeout="120">
			WITH OrgHierarchy AS (
				SELECT pc_org_mcu, pc_org_mcu_subord_tec
				FROM pc_orgaos
				WHERE pc_org_mcu_subord_tec = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
				UNION ALL
				SELECT o.pc_org_mcu, o.pc_org_mcu_subord_tec
				FROM pc_orgaos o
				INNER JOIN OrgHierarchy oh ON o.pc_org_mcu_subord_tec = oh.pc_org_mcu
			)
			SELECT pc_org_mcu
			FROM OrgHierarchy
		</cfquery>

		<cfset orgaosHierarquiaList = ValueList(getOrgHierarchy.pc_org_mcu)>
	
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT      pc_processos.*,
						pc_avaliacao_tipos.pc_aval_tipo_descricao,
						pc_orgaos.pc_org_descricao AS descOrgAvaliado,
						pc_usuarios.pc_usu_nome,
						pc_usuCoodNacional.pc_usu_nome AS nome_coordenadorNacional,
						pc_usuCoodNacional.pc_usu_matricula AS matricula_coordenadorNacional,
						pc_avaliacoes.*,
						pc_avaliacao_orientacoes.*,
						pc_orgaos_1.pc_org_se_sigla AS seOrgResp,
						pc_orgaos_1.pc_org_sigla AS siglaOrgResp,
						pc_orgaos_1.pc_org_mcu AS mcuOrgResp,
						pc_orientacao_status.*,
						pc_orgaos_heranca.*,
						pc_orgaos_2.pc_org_sigla AS siglaOrgRespHerdeiro,
						pc_orgaos_2.pc_org_se_sigla AS seOrgRespHerdeiro,
						pc_processos.pc_num_orgao_origem AS orgaoOrigem,
						pc_orgaos_3.pc_org_sigla AS orgaoAvaliado,
						pc_orgaos_4.pc_org_sigla AS orgaoOrigemSigla

			FROM        pc_processos 
						LEFT JOIN pc_orgaos ON  pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
						INNER JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_orgaos_1.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
						LEFT JOIN pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_orgaos_heranca on pc_orgHerancaMcuDe = pc_aval_orientacao_mcu_orgaoResp
						LEFT JOIN pc_orgaos AS pc_orgaos_2 ON pc_orgaos_2.pc_org_mcu = pc_orgHerancaMcuPara
						LEFT JOIN pc_orgaos AS pc_orgaos_3 ON pc_orgaos_3.pc_org_mcu = pc_num_orgao_avaliado
						LEFT JOIN pc_orgaos AS pc_orgaos_4 ON pc_orgaos_4.pc_org_mcu = pc_num_orgao_origem
						INNER JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
						LEFT JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
			WHERE 	 pc_processo_id IS NOT NULL  
			
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>
			
			
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se  processoEmAcompanhamento igual a true só mostra orientações de processos em acompanhamento e bloqueados, caso contrário, mostra processos finalizados--->
				<cfif '#arguments.processoEmAcompanhamento#' eq true >
					AND pc_num_status in(4,6)
				<cfelse>
					AND pc_num_status in(5)
				</cfif>	
				<!---Se o perfil não for 3 - DESENVOLVEDOR ou 8 - GESTOR MASTER OU 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) oculta o status 13 - EM ANÁLISE--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 3 and #application.rsUsuarioParametros.pc_usu_perfil# neq 8 and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
						AND not pc_aval_orientacao_status in (13)	
				</cfif>
				<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI)--->
				<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
					AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
				
				<!---Se o perfil for 4 - 'CI - AVALIADOR (EXECUÇÃO)') --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 >
					AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
				</cfif>

				<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1)'  ou 14 -'CI - REGIONAL - SCIA - Acompanhamento'--->
				<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_num_orgao_origem IN('00436698','00436697','00438080') AND (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#))
				</cfif>

			<cfelse>
			    
				<!---Se  processoEmAcompanhamento igual a true só mostra orientações de processos em acompanhamento, caso contrário, mostra processos finalizados--->
				<cfif '#arguments.processoEmAcompanhamento#' eq true>
						AND pc_num_status in(4)
				<cfelse>
						AND pc_num_status in(5)
				</cfif>	
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
						AND  pc_aval_orientacao_status not in (0,9,12,14)
				<cfelse>
					<!---Não exibe orientações pendentes de posicionamento inicial do controle interno, canceladas, improcedentes e bloqueadas--->
				    AND pc_aval_orientacao_status not in (0,1,9,12,14)
					AND (
							pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR  pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							<cfif getOrgHierarchy.recordCount gt 0>
								OR pc_processos.pc_num_orgao_avaliado IN (#orgaosHierarquiaList#)
								OR pc_aval_orientacao_mcu_orgaoResp IN (#orgaosHierarquiaList#)
							</cfif>
						)
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif getOrgHierarchy.recordCount gt 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
							and NOT (
									pc_aval_orientacao_status not in (13)
									AND pc_orgaos_1.pc_org_status IN ('O')
								)
							<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
							and NOT (
									pc_aval_orientacao_status = 13
									AND pc_num_orgao_avaliado NOT IN (#orgaosHierarquiaList#)
								)
					</cfif>
				</cfif>	
			</cfif>
			
			ORDER BY 	pc_processo_id, pc_aval_numeracao
		</cfquery>

		<div class="row">
			<div id="filtroSpan" style="display: none;text-align:right;font-size:18px;position:absolute;top:123px;right:24px;"><span class="statusOrientacoes" style="background:#2581c8;color:#fff;">Atenção! Um filtro foi aplicado.</span><br><i class="fa fa-2x fa-hand-point-down" style="color:#2581c8;position:relative;top:8px;right:117px"></i></div>
						
			<div class="col-12">
				<div class="card"  style="margin-bottom:80px">
					
					<!-- card-body -->
					<div class="card-body" >
						<cfif #rsProcTab.recordcount# eq 0 >
							<h5 align="center">Nenhuma Orientação para acompanhamento foi localizada para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
						</cfif>
						<cfif #rsProcTab.recordcount# neq 0 >
						
							<table id="tabProcessos" class="table table-bordered table-striped table-hover text-nowrap" >
								
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:14px">
										
										<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11>
											<th id="colunaEmAnalise"style="text-align: center!important;">Colocar<br>em análise</th>
										</cfif>
										<th style="width:50px">Status:</th>
										<th style="text-align: center!important;">N° Processo SNCI</th>
										<th >N° Item:</th>
										<th style="text-align: center!important;">ID da<br>Orientação</th>
										<th style="text-align: center!important;">Data Prevista<br>p/ Resposta</th>
										<th >Órgão Responsável: </th>
										<th >SE/CS:</th>
										<th >N° SEI: </th>
										<th style="text-align: center!important;">N° Relatório<br>SEI</th>
										<th >Tipo de Avaliação:</th>	
										<th >Data Hora Status: </th>
										<th >Órgão Origem: </th>
										<th >Órgão Avaliado: </th>
										<th style="display:none"></th>
										<th style="display:none"></th>	
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsProcTab" >
										<cfoutput>					
											<tr style="font-size:12px;cursor:pointer;z-index:2;"  >
													
													<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11>
														<td align="center">
															<cfif (#pc_aval_orientacao_status# neq 13 and #pc_aval_orientacao_status# neq 14) or (#pc_aval_orientacao_status# eq 13 and mcuOrgResp eq '#application.rsUsuarioParametros.pc_usu_lotacao#' and orgaoOrigem neq '#application.rsUsuarioParametros.pc_usu_lotacao#') or (#pc_aval_orientacao_status# eq 13 and (mcuOrgResp neq '#application.rsUsuarioParametros.pc_usu_lotacao#' or orgaoOrigem neq '#application.rsUsuarioParametros.pc_usu_lotacao#'))>
																<i onclick="javascript:colocarEmAnalise('#pc_processo_id#',#pc_aval_id#,#pc_aval_orientacao_id#,'#rsProcTab.orgaoOrigem#','#rsProcTab.orgaoOrigemSigla#','#rsProcTab.mcuOrgResp#',#rsProcTab.pc_aval_orientacao_status#)"class="fas fa-file-medical-alt grow-icon clickable-icon" style="color:##0083ca;font-size:20px;margin-right:10px;z-index:10000"> </i>
															</cfif>
														</td>
													</cfif>
													<cfif #pc_aval_orientacao_dataPrevistaResp# neq '' and DATEFORMAT(#pc_aval_orientacao_dataPrevistaResp#,"yyyy-mm-dd")  lt DATEFORMAT(Now(),"yyyy-mm-dd") and (#pc_aval_orientacao_status# eq 4 or #pc_aval_orientacao_status# eq 5)>
														<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
															<td align="center"><span class="statusOrientacoes" style="background:##FFA500;color:##fff;" >PENDENTE</span></td>
														<cfelse>
															<td align="center"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;" >PENDENTE</span></td>
														</cfif>
													<cfelseif #pc_aval_orientacao_status# eq 3>
														<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
															<td align="center"><span  class="statusOrientacoes" style="background:##FFA500;color:##fff;" >#pc_orientacao_status_descricao#</span></td>
														<cfelse>
															<td align="center"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;" >#pc_orientacao_status_descricao#</span></td>
														</cfif>
													<cfelse>
														<td align="center"><span class="statusOrientacoes" style="#pc_orientacao_status_card_style_header#;" >#pc_orientacao_status_descricao#</span></td>
													</cfif>
													<td align="center">#pc_processo_id#</td>
													<td align="center">#pc_aval_numeracao#</td>	
													<td align="center">#pc_aval_orientacao_id#</td>
													

													<cfif ListFind("4,5,16", #pc_aval_orientacao_status#) >
														<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,'DD-MM-YYYY') >
														<td align="center">#dataPrev#</td>
													<cfelse>
														<td align="center"></td>
													</cfif>
													<cfif #pc_orgHerancaMcuPara# neq '' and (#pc_orientacao_status_finalizador# neq 'S' or DateFormat(pc_aval_orientacao_status_datahora,"dd/mm/yyyy ") gte DateFormat(pc_orgHerancaDataInicio,"dd/mm/yyyy"))>
														<cfif pc_aval_orientacao_distribuido eq 1>
															<td>#siglaOrgRespHerdeiro# (#pc_orgHerancaMcuPara#) <span style="font-size:10px;">transf. de: #siglaOrgResp# (#mcuOrgResp#)</span></td>
														<cfelse>
															<td>#siglaOrgRespHerdeiro# (#pc_orgHerancaMcuPara#) <span style="font-size:10px;">transf. de: #siglaOrgResp# (#mcuOrgResp#)</span></td>
														</cfif>
														<td>#seOrgRespHerdeiro#</td>
													<cfelse>
														<cfif pc_aval_orientacao_distribuido eq 1>
															<td>#siglaOrgResp# (#mcuOrgResp#)</td>
														<cfelse>
															<td>#siglaOrgResp# (#mcuOrgResp#)</td>
														</cfif>
														<td>#seOrgResp#</td>
													</cfif>
													
													<cfif #rsProcTab.pc_modalidade# eq 'A' OR #rsProcTab.pc_modalidade# eq 'E'>
														<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
														<td align="center">#sei#</td>
														<td align="center">#pc_num_rel_sei#</td>
													<cfelse>
														<td align="center">Não possui</td>
														<td align="center">Não possui</td>
													</cfif>
													<cfif pc_num_avaliacao_tipo neq 2>
														<td onclick="javascript:mostraInformacoesItensAcompanhamento(#pc_aval_id#, #pc_aval_orientacao_id#)">#pc_aval_tipo_descricao#</td>
													<cfelse>
														<td onclick="javascript:mostraInformacoesItensAcompanhamento(#pc_aval_id#, #pc_aval_orientacao_id#)">#pc_aval_tipo_nao_aplica_descricao#</td>
													</cfif>
													<td>#DateFormat(pc_aval_orientacao_status_datahora,"dd/mm/yyyy")# - #TimeFormat(pc_aval_orientacao_status_datahora,"HH:mm")#</td>	
													
													<td>#orgaoOrigemSigla#</td>
													<td>#orgaoAvaliado#</td>
													<td id="pcAvalId" style="display:none">#pc_aval_id#</td>
													<td id="pcAvalOrientacaoId" style="display:none">#pc_aval_orientacao_id#</td>
											</tr>
										</cfoutput>
									</cfloop>	
								</tbody>
								
							
							</table>
						</cfif>
					</div>
					<!-- /.card-body -->
				</div>
				<!-- /.card -->
			</div>
		<!-- /.col -->
		</div>
		<!-- /.row -->
		
		<script language="JavaScript">

			
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	
			    
				
			$(function () {
				<cfoutput>
					var emAcomp='#arguments.processoEmAcompanhamento#';
				</cfoutput>
				var tituloExcel ="";
				if(emAcomp==='true'){
					tituloExcel = "SNCI_Consulta_Orientacoes_(Processos_em_Acomp)_";
				}else{
					tituloExcel = "SNCI_Consulta_Orientacoes_(Processos_Finalizados)_";
				}

				if ($('#colunaEmAnalise').is(':visible')) {
				 var colunasMostrar = [1,6,7,10,12,13];
				} else {
				 var colunasMostrar = [0,5,6,9,11,12];
				}

				const tabOrientacoesProcessosAcomp = $('#tabProcessos').DataTable( {
				
					stateSave: true,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					dom: 
								"<'row'<'col-sm-4 dtsp-verticalContainer'<'dtsp-verticalPanes'P><'dtsp-dataTable'Bf>><'col-sm-8 text-left'p>>" +
								"<'col-sm-12 text-left'i>" +
								"<'row'<'col-sm-12'tr>>" ,
							
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						},
						{// Botão abertura do ctrol-sidebar com os filtros
							text: '<i class="fas fa-filter fa-2x grow-icon" style="margin-right:30px" data-widget="control-sidebar"></i>',
							className: 'btFiltro',
						},

					],
					language: {
						searchPanes: {
							clearMessage: 'Retirar filtro',
							loadMessage: 'Carregando Painéis de Pesquisa...',
							showMessage: 'Mostrar painéis',
							collapseMessage: 'Recolher painéis',
							title: 'Filtros Ativos - %d',
							emptyMessage: '<em>Sem dados</em>',
               				emptyPanes: 'Sem painéis de filtragem relevantes para exibição',
							
						}
					},
					searchPanes: {
						cascadePanes: true, // Exibir apenas opções que combinam com os filtros anteriores
						columns: colunasMostrar,// Colunas que terão filtro
						threshold: 1,// Número mínimo de registros para exibir Painéis de Pesquisa
						layout: 'columns-1', //layout do filtro com uma coluna
						initCollapsed: true, // Colapsar Painéis de Pesquisa
					},
					initComplete: function () {// Função executada ao finalizar a inicialização do DataTable
						initializeSearchPanesAndSidebar(this)//inicializa o searchPanes dentro do controlSidebar
					}

				})
			
			});

			$(document).ready(function() {
				// Verificar se há um valor armazenado em sessionStorage e seleciona a orientação que acabou de ser colocada em análise
				var idOrientacao = sessionStorage.getItem('emAnalise');
				if (idOrientacao) {
					// Selecionar a linha correspondente ao idOrientacao
					var table = $('#tabProcessos').DataTable(); 
					var row = table.rows().eq(0).filter(function (rowIdx) {
					return table.cell(rowIdx, 5).data() == idOrientacao; // Substitua '1' pelo índice da coluna 'ID DA ORIENTAÇÃO'
					});
					if (row.length > 0) {
					// Adicionar a classe de seleção à linha encontrada
					table.row(row).select();
					}
					sessionStorage.removeItem('emAnalise');
				}

				// Adicionar evento de clique às linhas da tabela para selecionar
				$('#tabProcessos tbody').on('click', 'tr', function() {
					// Remove a classe 'selected' de todas as linhas
					$('#tabProcessos tr').removeClass('selected');
					
					// Adiciona a classe 'selected' à linha clicada
					$(this).addClass('selected');
				});

				// Adicionar evento de clique às linhas da tabela para selecionar
				$('#tabProcessos tbody').on('click', 'tr', function(event) {
					// Verifica se o clique foi em um botão
					if ($(event.target).hasClass('clickable-icon')) {
						return; // Ignora a ação da TR se o clique foi em um botão
					}
					
					// Remove a classe 'selected' de todas as linhas
					$('#tabProcessos tr').removeClass('selected');
					
					// Adiciona a classe 'selected' à linha clicada
					$(this).addClass('selected');

					// Pega a linha (tr) em que a célula foi clicada
					var $row = $(this);
					
					// Obtém os valores das células ocultas
					var pcAvalId = $row.find('#pcAvalId').text();
					var pcAvalOrientacaoId = $row.find('#pcAvalOrientacaoId').text();

					// Chama a função mostraInformacoesItensConsulta com os valores
					mostraInformacoesItensConsulta(pcAvalId, pcAvalOrientacaoId);
				});



			});

			

			function mostraInformacoesItensConsulta(idAvaliacao, idOrientacao){
				

				$('#modalOverlay').modal('show')
				
				$('#informacoesItensConsultaDiv').html('')
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
							data:{
								method: "informacoesItensConsulta",
								idAvaliacao: idAvaliacao,
								idOrientacao: idOrientacao
							},
							async: false
						})//fim ajax
						.done(function(result) {
							$('#informacoesItensConsultaDiv').html(result)
							$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
								$('html, body').animate({ scrollTop: ($('#informacoesItensConsultaDiv').offset().top-80)} , 1000);
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

			function colocarEmAnalise(idProcesso, idAvaliacao, idOrientacao, orgaoOrigem, orgaoOrigemSigla, orgaoResp, statusOrientacao){
				<cfoutput>	
					 var lotacaoUsuario = '#application.rsUsuarioParametros.pc_usu_lotacao#';
					 var lotacaoUsuarioSigla = '#application.rsUsuarioParametros.pc_org_sigla#';
				</cfoutput>

				// Dividir a sequência usando a barra (/) como delimitador epegar a última
				lotacaoUsuarioSigla = lotacaoUsuarioSigla.split("/").pop();
				orgaoOrigemSigla = orgaoOrigemSigla.split("/").pop();

				$('#tabProcessos tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabProcessos tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
				sessionStorage.setItem('emAnalise',idOrientacao);
                
                
				if(((orgaoResp===lotacaoUsuario || orgaoResp === orgaoOrigem) && statusOrientacao===13) || (orgaoOrigem === lotacaoUsuario )){
					var enviaOrgao = 0;
					if(orgaoOrigem===lotacaoUsuario ){
						var mensagem = '<p style="text-align: justify;">Deseja colocar esta orientação ID <strong style="color:red">' + idOrientacao + '</strong> "EM ANÁLISE" sob responsabilidade da (<strong>'+orgaoOrigemSigla+'</strong>)?</p>';
					    enviaOrgao = 1;
					}else if (orgaoResp === orgaoOrigem ){
						var mensagem = '<p style="text-align: justify;">Deseja colocar esta orientação ID <strong style="color:red">' + idOrientacao + '</strong> "EM ANÁLISE" sob responsabilidade da (<strong>'+lotacaoUsuarioSigla+'</strong>)?</p>';
						enviaOrgao = 0;
					}else{
						var mensagem = '<p style="text-align: justify;">Deseja colocar esta orientação ID <strong style="color:red">' + idOrientacao + '</strong> "EM ANÁLISE" sob responsabilidade do órgão de origem do processo (<strong>'+orgaoOrigemSigla +'</strong>)?</p>';
						enviaOrgao = 1;
					}
					<cfoutput>
						var processoEmAcompanhamento =  "#arguments.processoEmAcompanhamento#";
					</cfoutput>
					if(processoEmAcompanhamento !=='true'){
						mensagem = mensagem + '<p style="text-align: justify;color:red">Atenção! Ao colocar esta orientação em análise, o processo voltará para o status <strong>"EM ACOMPANHAMENTO"</strong>.</p>';
					}


					Swal.fire({//sweetalert2
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
									url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
									data:{
										method: "colocarEmAnalise",
										idProcesso: idProcesso,
										idAvaliacao: idAvaliacao,
										idOrientacao: idOrientacao,
										orgaoOrigem: orgaoOrigem,
										analiseOrgaoOrigem: enviaOrgao
									},
									async: false
								})//fim ajax
								.done(function(result) {
									var valorRadio = $('input[name="opcaoAno"]:checked').val();
									exibirTabela(valorRadio)
									$('#informacoesItensAcompanhamentoDiv').html('')
									if(orgaoOrigem===lotacaoUsuario ){	
										var mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">'+idOrientacao+'</span> foi enviada para análise da <span style="color:#00416B">'+orgaoOrigemSigla+'</span> com sucesso!</p>';
									}else if (orgaoResp === orgaoOrigem ){
										var mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">'+idOrientacao+'</span> foi enviada para análise da <span style="color:#00416B">'+lotacaoUsuarioSigla+'</span> com sucesso!</p>';
									}else{
										var mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">'+idOrientacao+'</span> foi enviada para análise da <span style="color:#00416B">'+orgaoOrigemSigla+'</span> com sucesso!</p>';
									}
									$('#modalOverlay').delay(1000).hide(0, function() {
										Swal.fire({
											title: mensagemSucessos,
											html: logoSNCIsweetalert2(''),
											icon: 'success'
										});
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

						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
						
					})
				
				}else{
					var mensagem = '<p style="text-align: justify;">Deseja colocar esta orientação ID <strong style="color:red">'+idOrientacao+'</strong> "EM ANÁLISE"?</p>';
					<cfoutput>
						var processoEmAcompanhamento =  "#arguments.processoEmAcompanhamento#";
					</cfoutput>
					if(processoEmAcompanhamento !=='true'){
						mensagem = mensagem + '<p style="text-align: justify;color:red">Atenção! Ao colocar esta orientação em análise, o processo voltará para o status <strong>"EM ACOMPANHAMENTO"</strong>.</p>';
					}
					Swal.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					input: 'checkbox',
					inputValue: 0,
					inputPlaceholder:
						'<span class="font-weight-light" style="text-align: justify;font-size:14px">Assinale ao lado, para enviar essa orientação para análise do órgão de origem do processo (<strong>'+orgaoOrigemSigla+'</strong>) ou deixe em branco para encaminhar para análise da <strong>'+lotacaoUsuarioSigla+'</strong>.</span>',
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							var enviaOrgaoOrigem=result.value;
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
									data:{
										method: "colocarEmAnalise",
										idProcesso: idProcesso,
										idAvaliacao: idAvaliacao,
										idOrientacao: idOrientacao,
										orgaoOrigem: orgaoOrigem,
										analiseOrgaoOrigem: enviaOrgaoOrigem
									},
									async: false
								})//fim ajax
								.done(function(result) {
									var valorRadio = $('input[name="opcaoAno"]:checked').val();
									exibirTabela(valorRadio)
									$('#informacoesItensAcompanhamentoDiv').html('')	
									var mensagemSucessos ='';
									if(!enviaOrgaoOrigem){
										mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">' + idOrientacao + '</span> foi enviada para análise da <span style="color:#00416B">'+lotacaoUsuarioSigla+'</span> com sucesso!</p>';
									}else{
										mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">' + idOrientacao + '</span> foi enviada para análise da <span style="color:#00416B">'+orgaoOrigemSigla +'</span> com sucesso!</p>';
									}
									$('#modalOverlay').delay(1000).hide(0, function() {
										Swal.fire({
								title: mensagemSucessos,
								html: logoSNCIsweetalert2(''),
								icon: 'success'
							});
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

						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					
					})
				}

				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});
			}

			// // Função para exibir a tabela com base no ano selecionado
			// function exibirTabela(anoMostra) {
			// 	// Mostrar overlay para indicar carregamento
			// 	$("#modalOverlay").modal("show");

			// 	// Realizar uma requisição AJAX para obter os dados da tabela
			// 	setTimeout(function () {
			// 		$.ajax({
			// 			type: "post",
			// 			url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
			// 			data: {
			// 				method: "tabConsulta",
			// 				ano: anoMostra,
			// 				processoEmAcompanhamento: true,
			// 			},
			// 			async: false,
			// 			success: function (result) {
			// 				// Atualizar o conteúdo da tabela e outros elementos relacionados
			// 				$("#exibirTab").html(result);
			// 				$("#informacoesItensConsultaDiv").html("");
			// 				$("#timelineViewConsultaDiv").html("");

			// 				// Esconder o overlay após 1 segundo
			// 				$("#modalOverlay").delay(1000).hide(0, function () {
			// 					$("#modalOverlay").modal("hide");
			// 				});
			// 			},
			// 			error: function (xhr, ajaxOptions, thrownError) {
			// 				// Em caso de erro, mostrar modal de erro
			// 				$("#modalOverlay").delay(1000).hide(0, function () {
			// 					$("#modalOverlay").modal("hide");
			// 				});
			// 				$("#modal-danger").modal("show");
			// 				$("#modal-danger")
			// 					.find(".modal-title")
			// 					.text("Não foi possível executar sua solicitação. Informe o erro abaixo ao administrador do sistema:");
			// 				$("#modal-danger").find(".modal-body").text(thrownError);
			// 			},
			// 		});
			// 	}, 500);
			// }


		</script>	

		
	

	</cffunction>

    <cffunction name="colocarEmAnalise"   access="remote" hint="coloca a orientação com status EM ANALISE">
		<cfargument name="idProcesso" type="string" required="true" />
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="idOrientacao" type="numeric" required="true" />
		<cfargument name="orgaoOrigem" type="string" required="true" />-->
		<cfargument name="analiseOrgaoOrigem" type="numeric" required="true" />
		<!--Se for marcado checkbox, o órgão responsável será o órgão de origem do processo, caso contrário será o órgão de lotação do usuário--> 
		<cfif arguments.analiseOrgaoOrigem eq 0>
			<cfset orgaoRespOrientacao = "#application.rsUsuarioParametros.pc_usu_lotacao#">
		<cfelse>
			<cfset orgaoRespOrientacao = "#arguments.orgaoOrigem#">
		</cfif>

		<cfset textoPosic = "Orientação recolhida pelo Controle Interno. Após as devidas análises retornará ao fluxo habitual do processo de acompanhamento.">
		<cftransaction> 
			<cfquery datasource = "#application.dsn_processos#" >
				INSERT pc_avaliacao_posicionamentos	
				(	pc_aval_posic_num_orientacao
					, pc_aval_posic_texto
					, pc_aval_posic_dataHora
					, pc_aval_posic_matricula
					, pc_aval_posic_num_orgao
					, pc_aval_posic_num_orgaoResp
					, pc_aval_posic_status
					, pc_aval_posic_enviado
				)
			
				VALUES (
					<cfqueryparam value="#arguments.idOrientacao#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#orgaoRespOrientacao#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="13" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="1" cfsqltype="cf_sql_integer">
				)

			</cfquery>

			<cfquery datasource = "#application.dsn_processos#" >
				UPDATE 	pc_avaliacao_orientacoes
				SET 
					pc_aval_orientacao_status = <cfqueryparam value="13" cfsqltype="cf_sql_integer">,
					pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					pc_aval_orientacao_atualiz_login = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">,
					pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam value="#orgaoRespOrientacao#" cfsqltype="cf_sql_varchar">
				WHERE pc_aval_orientacao_id = <cfqueryparam value="#arguments.idOrientacao#" cfsqltype="cf_sql_integer">

			</cfquery>
			<!--Coloca o item em acompanhamento, se já não estiver-->
			<cfquery datasource = "#application.dsn_processos#" >
				UPDATE 	pc_avaliacoes  
				SET 
					pc_aval_status = 6
					
				WHERE pc_aval_id = <cfqueryparam value="#arguments.idAvaliacao#" cfsqltype="cf_sql_integer">
			</cfquery>
            <!--Coloca o processo em acompanhamento, se já não estiver-->
			<cfquery datasource = "#application.dsn_processos#" >
				UPDATE 	pc_processos  
				SET 
					pc_num_status = 4,
					pc_data_finalizado = NULL
				WHERE pc_processo_id = <cfqueryparam value="#arguments.idProcesso#" cfsqltype="cf_sql_varchar">
			</cfquery>

		</cftransaction>

	</cffunction>



	<cffunction name="informacoesItensConsulta"   access="remote" hint="envia para a página acomanhamento.cfm tabs com informações do item.">
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="idOrientacao" type="numeric" required="true" />

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam value="#arguments.idAvaliacao#" cfsqltype="cf_sql_integer">
		</cfquery>

		<session class="content-header" >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">


					<div id="idAvaliacao" hidden></div>

					<cfquery name="rsProcAval" datasource="#application.dsn_processos#">
						SELECT      pc_processos.*, pc_avaliacoes.*,pc_avaliacao_orientacoes.*,pc_aval_orientacao_mcu_orgaoResp as mcuOrgaoResp
									,pc_aval_orientacao_mcu_orgaoResp as mcuOrgResp, pc_orgaos.pc_org_sigla as siglaOrgResp
									,pc_num_orgao_avaliado as mcuOrgAvaliado,  pc_orgaos2.pc_org_sigla as siglaOrgAvaliado
									,pc_num_orgao_origem as mcuOrgOrigem,  pc_orgaos3.pc_org_sigla as siglaOrgOrigem
									,pc_avaliacao_tipos.*, pc_classificacoes.*
									,pc_orgaos_heranca.pc_orgHerancaMcuDe,pc_orgaos_heranca.pc_orgHerancaMcuPara,pc_orgaos_heranca.pc_orgHerancaDataInicio, pc_orgaos_4.pc_org_sigla as siglaOrgRespHerdeiro, pc_orgaos_4.pc_org_se_sigla as seOrgRespHerdeiro
									,pc_orgaos_heranca2.pc_orgHerancaMcuDe as pc_orgHerancaMcuDeAvaliado,pc_orgaos_heranca2.pc_orgHerancaMcuPara as pc_orgHerancaMcuParaAvaliado,pc_orgaos_heranca2.pc_orgHerancaDataInicio as pc_orgHerancaDataInicioAvaliado
									, pc_orgaos_5.pc_org_sigla as siglaOrgAvaliadoHerdeiro	,pc_status_card_style_ribbon, pc_status_card_nome_ribbon
						FROM        pc_processos 
									INNER JOIN pc_avaliacoes on pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo 
									INNER JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval =  pc_aval_id
									INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
									INNER JOIN pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_num_orgao_avaliado
									INNER JOIN pc_orgaos as pc_orgaos3 on pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
									INNER JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
									INNER JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
									LEFT JOIN pc_orgaos_heranca on pc_orgHerancaMcuDe = pc_aval_orientacao_mcu_orgaoResp
									LEFT JOIN pc_orgaos AS pc_orgaos_4 ON pc_orgaos_4.pc_org_mcu = pc_orgHerancaMcuPara
									LEFT JOIN pc_orgaos_heranca as  pc_orgaos_heranca2 on  pc_orgaos_heranca2.pc_orgHerancaMcuDe = pc_num_orgao_avaliado
									LEFT JOIN pc_orgaos AS pc_orgaos_5 ON pc_orgaos_5.pc_org_mcu =  pc_orgaos_heranca2.pc_orgHerancaMcuPara
									LEFT JOIN pc_status on pc_status.pc_status_id = pc_processos.pc_num_status
						WHERE  pc_aval_id = <cfqueryparam value="#arguments.idAvaliacao#" cfsqltype="cf_sql_integer"> 	 
						and pc_aval_orientacao_id = <cfqueryparam value="#arguments.idOrientacao#" cfsqltype="cf_sql_integer"> 	 													
					</cfquery>	

					


				
					<input id="pcProcessoId"  required="" hidden  value="#arguments.idAvaliacao#">
			
						

				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						
					</style>
						
					<div class="card-header" style="background-color: #0083CA;border-bottom:solid 2px #fff" >
						<cfoutput>
							<p style="font-size: 1.3em;color:##fff"><strong>Item: #rsProcAval.pc_aval_numeracao# - #rsProcAval.pc_aval_descricao#</strong></p>
						</cfoutput>	
					</div>
					<div class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
								<li class="nav-item" style="">
									<a  class="nav-link  active" id="custom-tabs-one-Orientacao-tab"  data-toggle="pill" href="#custom-tabs-one-Orientacao" role="tab" aria-controls="custom-tabs-one-Orientacao" aria-selected="true">
									<cfoutput>
										<cfif #rsProcAval.pc_orgHerancaMcuPara# neq '' and (DateFormat(Now(),"dd/mm/yyyy ") gte DateFormat(rsProcAval.pc_orgHerancaDataInicio,"dd/mm/yyyy"))>
											ORIENTAÇÃO: ID <strong>#rsProcAval.pc_aval_orientacao_id#</strong> - #rsProcAval.siglaOrgRespHerdeiro# (#rsProcAval.pc_orgHerancaMcuPara#)
										<cfelse>
											ORIENTAÇÃO: ID <strong>#rsProcAval.pc_aval_orientacao_id#</strong> - #rsProcAval.siglaOrgAvaliado# (#rsProcAval.mcuOrgResp#)
										</cfif>
									</cfoutput>
									</a>
								</li>
								

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfProcesso-tab"  data-toggle="pill" href="#custom-tabs-one-InfProcesso" role="tab" aria-controls="custom-tabs-one-InfProcesso" aria-selected="true">Inf. Processo</a>
								</li>

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfItem-tab"  data-toggle="pill" href="#custom-tabs-one-InfItem" role="tab" aria-controls="custom-tabs-one-InfItem" aria-selected="true">Inf. Item</a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link  " id="custom-tabs-one-Avaliacao-tab"  data-toggle="pill" href="#custom-tabs-one-Avaliacao" role="tab" aria-controls="custom-tabs-one-Avaliacao" aria-selected="true">Relatório</a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos</a>
								</li>
								
							</ul>
							
						</div>
						<div class="card-body">
							<div class="tab-content" id="custom-tabs-one-tabContent">
								<div disable class="tab-pane fade  active show" id="custom-tabs-one-Orientacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Orientacao-tab" >		
										<cfif rsProcAval.pc_aval_orientacao_distribuido eq 1>
											<div style=" display: inline;background-color: #e83e8c;color:#fff;padding: 3px;margin-left: 10px;">Orientação distribuída pelo órgão subordinador:</div>
										</cfif>						
										<pre style="color:#0083ca!important"><cfoutput><strong>#rsProcAval.pc_aval_orientacao_descricao#</strong></cfoutput></pre>
								</div>

                               

								

								<div disable class="tab-pane fade" id="custom-tabs-one-InfProcesso"  role="tabpanel" aria-labelledby="custom-tabs-one-InfProcesso-tab" >								
									<cfset aux_sei = Trim('#rsProcAval.pc_num_sei#')>
									<cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
		
									<section class="content" >
										<div id="processosCadastrados" class="container-fluid" >
											<div class="row">
												<div id="cartao" style="width:100%;" >
													<!-- small card -->
													<cfoutput>
														<div class="small-box " style=" font-weight: bold;">
															<div class="ribbon-wrapper ribbon-xl" >
																<div class="ribbon" style="font-size:18px!important;left:8px;<cfoutput>#rsProcAval.pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#rsProcAval.pc_status_card_nome_ribbon#</cfoutput></div>
															</div>
															<div class="card-header" style="height:auto">
																<p style="font-size: 1.5em;">Processo SNCI n°: <strong style="color:##0692c6;margin-right:30px">#rsProcAval.pc_processo_id#</strong> 
																<cfif #rsProcAval.pc_orgHerancaMcuParaAvaliado# neq '' and (DateFormat(rsProcAval.pc_aval_orientacao_status_datahora,"dd/mm/yyyy ") gte DateFormat(rsProcAval.pc_orgHerancaDataInicioAvaliado,"dd/mm/yyyy"))>
																	</strong> Órgão Avaliado: <strong style="color:##0692c6">#rsProcAval.siglaOrgAvaliadoHerdeiro#</strong><span style="font-size:10px;color:red"> (transf. de: #rsProcAval.siglaOrgAvaliado#)</span></p>
																<cfelse>	
																	</strong> Órgão Avaliado: <strong style="color:##0692c6">#rsProcAval.siglaOrgAvaliado#</strong></p>
																</cfif>
																
																<p style="font-size: 1em;">Origem: <strong style="color:##0692c6;margin-right:30px">#rsProcAval.siglaOrgOrigem#</strong>
																
																<cfif #rsProcAval.pc_modalidade# eq 'A' OR #rsProcAval.pc_modalidade# eq 'E'>
																	<span >Processo SEI n°: </span> <strong style="color:##0692c6">#aux_sei#</strong> <span style="margin-left:20px">Relatório n°:</span> <strong style="color:##0692c6">#rsProcAval.pc_num_rel_sei#</strong>
																</cfif></p>
																
																
																<cfif rsProcAval.pc_num_avaliacao_tipo neq 2>
																	<p style="font-size: 1em;">Tipo de Avaliação: <strong style="color:##0692c6">#rsProcAval.pc_aval_tipo_descricao#</strong></p>
																<cfelse>
																	<p style="font-size: 1em;">Tipo de Avaliação: <strong style="color:##0692c6">#rsProcAval.pc_aval_tipo_nao_aplica_descricao#</strong></p>
																</cfif>




																<p style="font-size: 1em;">
																	Classificação: <strong style="color:##0692c6;margin-right:50px">#rsProcAval.pc_class_descricao#</strong>
																	<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S' >	
																		Modalidade: 
																		<cfif #rsProcAval.pc_modalidade# eq 'N'>
																			<strong style="color:##0692c6;margin-right:50px">Normal</strong>
																		</cfif>
																		<cfif #rsProcAval.pc_modalidade# eq 'A'>
																			<strong style="color:##0692c6;margin-right:50px">ACOMPANHAMENTO</strong>
																		</cfif>
																		<cfif #rsProcAval.pc_modalidade# eq 'E'>
																			<strong style="color:##0692c6;margin-right:50px">ENTREGA DO RELATÓRIO</strong>
																		</cfif>
																	</cfif>
																	Tipo de Demanda: 
																	<cfif #rsProcAval.pc_tipo_demanda# eq 'P'>
																		<strong style="color:##0692c6;margin-right:50px">PLANEJADA</strong>
																	<cfelseif #rsProcAval.pc_tipo_demanda# eq 'E'>
																		<strong style="color:##0692c6">EXTRAORDINÁRIA</strong>
																	<cfelse>
																		<strong style="color:##0692c6">Não informado</strong>
																	</cfif>

																	<cfif #rsProcAval.pc_tipo_demanda# eq 'P' >
																		Ano PACIN: <strong style="color:##0692c6;margin-right:50px">#rsProcAval.pc_ano_pacin#</strong>
																	</cfif>
																</p>

																<cfquery datasource="#application.dsn_processos#" name="rsCoordenadorRegional">
																	SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios
																	INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
																	WHERE pc_usu_matricula = '#rsProcAval.pc_usu_matricula_coordenador#'
																</cfquery>
																<cfquery datasource="#application.dsn_processos#" name="rsCoordenadorNacional">
																	SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios
																	INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
																	WHERE pc_usu_matricula = '#rsProcAval.pc_usu_matricula_coordenador_nacional#'
																</cfquery>

																<cfquery datasource="#application.dsn_processos#" name="rsAvaliadores">
																	SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_avaliadores
																	INNER JOIN pc_usuarios on pc_usu_matricula = pc_avaliador_matricula
																	INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
																	WHERE pc_avaliador_id_processo = '#rsProcAval.pc_processo_id#'
																</cfquery>


																<p style="font-size: 1em;">
																	<cfif rsCoordenadorRegional.recordcount neq 0>
																		Coordenador Regional: <strong style="color:##0692c6;margin-right:50px">#rsCoordenadorRegional.pc_usu_nome# (#rsCoordenadorRegional.pc_org_se_sigla#)</strong>
																	</cfif>
																	<cfif rsCoordenadorNacional.recordcount neq 0>	
																		Coordenador Nacional: <strong style="color:##0692c6;margin-right:50px">#rsCoordenadorNacional.pc_usu_nome# (#rsCoordenadorNacional.pc_org_se_sigla#)</strong>
																	</cfif>
																</p>

																<cfif rsAvaliadores.recordcount neq 0>
																	<p style="font-size: 1em;">
																		Avaliadores:<br> 
																		<cfloop query="rsAvaliadores">
																			<strong style="color:##0692c6;margin-right:50px">#pc_usu_nome# (#pc_org_se_sigla#)</strong><br>
																		</cfloop>
																	</p>
																</cfif>


																
																

															</div>
														</div>
													</cfoutput>
												</div>
											</div>
										</div>
										
									</section>
								</div>

								<div disable class="tab-pane fade" id="custom-tabs-one-InfItem"  role="tabpanel" aria-labelledby="custom-tabs-one-InfItem-tab" >								
									<cfset classifRisco = "">
									<cfif #rsProcAval.pc_aval_classificacao# eq 'L'>
										<cfset classifRisco = "Leve">
									</cfif>	
									<cfif #rsProcAval.pc_aval_classificacao# eq 'M'>
										<cfset classifRisco = "Mediana">
									</cfif>	
									<cfif #rsProcAval.pc_aval_classificacao# eq 'G'>
										<cfset classifRisco = "Grave">
									</cfif>	
									<section class="content" >
										<div id="processosCadastrados" class="container-fluid" >
											<div class="row">
												<div id="cartao" style="width:100%;" >
													<!-- small card -->
													<cfoutput>
														<div class="small-box " style=" font-weight: bold;">
															
															<div class="card-header" style="height:auto">
																<p style="font-size: 1.3em;">Item: <span style="color:##0692c6;">#rsProcAval.pc_aval_numeracao# - #rsProcAval.pc_aval_descricao#</span></p>
																<p style="font-size: 1.3em;">Classificação: <span style="color:##0692c6;">#classifRisco#</span></p>
																
																<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S' >
																	<cfif #rsProcAval.pc_aval_vaFalta# gt 0 or  #rsProcAval.pc_aval_vaSobra# gt 0 or  #rsProcAval.pc_aval_vaRisco# gt 0 >
																 		<p style="font-size: 1.3em;">Valor Envolvido: 
																			<cfif #rsProcAval.pc_aval_vaFalta# gt 0>
																				<cfset valorApurado = #LSCurrencyFormat( rsProcAval.pc_aval_vaFalta, 'local')#>
																				<span style="color:##0692c6;">Falta =  #valorApurado#; </span>
																			</cfif>
																			<cfif #rsProcAval.pc_aval_vaSobra# gt 0>
																				<cfset valorApurado = #LSCurrencyFormat( rsProcAval.pc_aval_vaSobra, 'local')#>
																				<span style="color:##0692c6;">Sobra =  #valorApurado#; </span>
																			</cfif>
																			<cfif #rsProcAval.pc_aval_vaRisco# gt 0>
																				<cfset valorApurado = #LSCurrencyFormat( rsProcAval.pc_aval_vaRisco, 'local')#>
																				<span style="color:##0692c6;">Risco =  #valorApurado#; </span>
																			</cfif>
																		</p>
																	<cfelse>
																		<p style="font-size: 1.3em;">Valor Envolvido: <span style="color:##0692c6;">Não quantificado</span></p>
																	</cfif>
																</cfif>
															</div>
														</div>
													</cfoutput>
												</div>
											</div>
										</div>
										
									</section>
								</div>
								
								<div disable class="tab-pane fade" id="custom-tabs-one-Avaliacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Avaliacao-tab" >								
									<div id="anexoAvaliacaoDiv"></div>
								</div>

								<div class="tab-pane fade " id="custom-tabs-one-Anexos" role="tabpanel" aria-labelledby="custom-tabs-one-Anexos-tab">	
									<div id="tabAnexosDiv" style="margin-top:20px"></div>
								</div>

							</div>

						
						</div>
						
					</div>
				
				</form><!-- fim formCadAvaliacao -->
			</session><!-- fim card-body2 -->	
					
			<cfobject component = "pc_cfcConsultasPorOrientacao" name = "timeline">
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<cfinvoke component="#timeline#" method="timelineViewAcomp" returnVariable="timeline" pc_aval_orientacao_id = "#arguments.idOrientacao#" >
			<cfelse>
				<cfinvoke component="#timeline#" method="timelineViewAcompOrgaoAvaliado" returnVariable="timeline" pc_aval_orientacao_id = "#arguments.idOrientacao#">
			</cfif>

					
		</session>

        
		<script language="JavaScript">
		

			$(document).ready(function() {	
				<cfoutput>
					var pc_aval_status = '#rsProcAval.pc_aval_status#'
					
				</cfoutput>
				mostraRelatoPDF();
				mostraTabAnexos();
				//mostraTabOrientacoes();
				//mostraTabMelhorias();
			})

			$(function () {
				$('[data-mask]').inputmask()
			})


			<cfoutput>
				var pc_aval_id = '#arguments.idAvaliacao#';
				var pc_orientacao_id = '#arguments.idOrientacao#';
			</cfoutput>

			function mostraTabAnexos(){
				
				$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "tabAnexos",
							pc_aval_id: pc_aval_id,
							pc_orientacao_id: pc_orientacao_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabAnexosDiv').html(result)
						
						
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

			function mostraRelatoPDF(){
				
				$.ajax({
					type: "post",
					url:"cfc/pc_cfcAvaliacoes.cfc",
					data:{
						method: "anexoAvaliacao",
						pc_aval_id: pc_aval_id,
						todosOsRelatorios:'S'
					},
					async: false
				})//fim ajax
				.done(function(result){
					
					$('#anexoAvaliacaoDiv').html(result)
					
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



		</script>

    </cffunction>




	<cffunction name="timelineViewAcomp"   access="remote" hint="enviar o componente timeline dos processos em acompanhamento para a páginas pc_Consulta chama pela função tabAvaliacoesConsulta">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />

	
		<!--- Chama o componente timelineViewPosicionamentos em pc_cfcComponenteTimelinePosicionamentos.cfc --->
		<cfinvoke component="pc_cfcComponenteTimelinePosicionamentos" method="timelineViewPosicionamentos" returnvariable="timelineCI">
			<cfinvokeargument name="pc_aval_orientacao_id" value="#arguments.pc_aval_orientacao_id#">
			<cfinvokeargument name="paraControleInterno" value="S">
		</cfinvoke>

			


	</cffunction>





	<cffunction name="timelineViewAcompOrgaoAvaliado"   access="remote" hint="enviar o componente timeline dos processos em acompanhamento para a páginas pc_Consulta chama pela função tabAvaliacoesConsulta">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
        <!--- Chama o componente timelineViewPosicionamentos em pc_cfcComponenteTimelinePosicionamentos.cfc --->
		<cfinvoke component="pc_cfcComponenteTimelinePosicionamentos" method="timelineViewPosicionamentos" returnvariable="timelineOA">
			<cfinvokeargument name="pc_aval_orientacao_id" value="#arguments.pc_aval_orientacao_id#">
			<cfinvokeargument name="paraControleInterno" value="N">
		</cfinvoke>
	</cffunction>









</cfcomponent>