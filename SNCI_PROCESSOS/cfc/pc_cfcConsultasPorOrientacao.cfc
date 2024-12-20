<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	

   	<cffunction name="tabConsulta" returntype="any" access="remote" hint="Criar a tabela dos processos e envia para a página pcConsulta.cfm">
	   	<cfargument name="ano" type="string" required="true"  />
	  	<cfargument name="processoEmAcompanhamento" type="boolean" required="false" default="true" />

		<cfset var rsProcTab = "">
		<cfset var colunaEmAnalise = 0>
		<cfset var dataPrev = "">
		<cfset var sei = "">
		<cfset var dataHora = "">
		<cfset var dataFormatada = "">

	
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
						pc_processos.pc_num_orgao_origem AS orgaoOrigem,
						pc_orgaos_3.pc_org_sigla AS orgaoAvaliado,
						pc_orgaos_4.pc_org_sigla AS orgaoOrigemSigla,
						CONCAT(
						'Macroprocesso:<strong> ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,'</strong>',
						' -> N1:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,'</strong>',
						' -> N2:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,'</strong>',
						' -> N3:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN3,'</strong>', '.'
						) as tipoProcesso,
						CASE WHEN pc_orientacao_status.pc_orientacao_status_finalizador = 'S' THEN 'SIM' ELSE 'NÃO' END AS statusFinalizador



			FROM        pc_processos 
						LEFT JOIN pc_orgaos ON  pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
						INNER JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_orgaos_1.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
						LEFT JOIN pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_orgaos AS pc_orgaos_3 ON pc_orgaos_3.pc_org_mcu = pc_num_orgao_avaliado
						LEFT JOIN pc_orgaos AS pc_orgaos_4 ON pc_orgaos_4.pc_org_mcu = pc_num_orgao_origem
						INNER JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
						LEFT JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
			WHERE 	 pc_processo_id IS NOT NULL  AND not pc_aval_orientacao_status in (0)
			
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
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
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
						AND pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)
					</cfif>
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
						AND  pc_aval_orientacao_status not in (9,12,14)
				<cfelse>
					<!---Não exibe orientações pendentes de posicionamento inicial do controle interno, canceladas, improcedentes e bloqueadas--->
				    AND pc_aval_orientacao_status not in (1,9,12,14)
					AND (
							pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR  pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_processos.pc_num_orgao_avaliado IN (#application.orgaosHierarquiaList#)
								OR pc_aval_orientacao_mcu_orgaoResp IN (#application.orgaosHierarquiaList#)
							</cfif>
						)
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
							and NOT (
									pc_aval_orientacao_status not in (13)
									AND pc_orgaos_1.pc_org_status IN ('O')
								)
							<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
							and NOT (
									pc_aval_orientacao_status = 13
									AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
								)
					</cfif>
				</cfif>	
			</cfif>
			
			ORDER BY 	pc_processo_id, pc_aval_numeracao
		</cfquery>

		<div class="row">
				 
			<div class="col-12">
				<div class="card"  >
					
					<!-- card-body -->
					<div class="card-body" >
					
						    
						<table id="tabProcessos" class="table table-striped table-hover text-nowrap  table-responsive table-responsive" >
							
							<thead  class="table_thead_backgroundColor">
								<tr style="font-size:14px">
									
									<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11>
										<cfset colunaEmAnalise = 1>
										<th class="fixar-coluna" id="colunaEmAnalise" style="text-align: center!important;">Colocar<br>em análise</th>
									</cfif>
									<th style="width:50px">Status:</th>
									<th >Status Finalizador?</th>
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
													<td class="fixar-coluna fixar-coluna-fundo-branco" align="center">
														<cfif #pc_aval_orientacao_status# neq 14>
															<i onclick="colocarEmAnalise('#pc_processo_id#',#pc_aval_id#,#pc_aval_orientacao_id#,'#rsProcTab.orgaoOrigem#','#rsProcTab.orgaoOrigemSigla#','#rsProcTab.mcuOrgResp#',#rsProcTab.pc_aval_orientacao_status#,'#application.rsUsuarioParametros.pc_usu_lotacao#','#application.rsUsuarioParametros.pc_org_sigla#')"class="fas fa-file-medical-alt grow-icon clickable-icon azul_claro_correios_textColor" style="font-size:20px;margin-right:10px;z-index:10000"> </i>
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
												<td align="center">#statusFinalizador#</td>
												<td id="pcProcId" align="center">#pc_processo_id#</td>
												<td align="center">#pc_aval_numeracao#</td>	
												<td align="center">#pc_aval_orientacao_id#</td>
												

												<cfif ListFind("4,5,16", #pc_aval_orientacao_status#) >
													<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,'DD-MM-YYYY') >
													<td align="center">#dataPrev#</td>
												<cfelse>
													<td align="center"></td>
												</cfif>
												
												<cfif pc_aval_orientacao_distribuido eq 1>
													<td>#siglaOrgResp# (#mcuOrgResp#)</td>
												<cfelse>
													<td>#siglaOrgResp# (#mcuOrgResp#)</td>
												</cfif>
												<td>#seOrgResp#</td>
												
												
												<cfif #rsProcTab.pc_modalidade# eq 'A' OR #rsProcTab.pc_modalidade# eq 'E'>
													<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
													<td align="center">#sei#</td>
													<td align="center">#pc_num_rel_sei#</td>
												<cfelse>
													<td align="center">Não possui</td>
													<td align="center">Não possui</td>
												</cfif>
												<cfif pc_num_avaliacao_tipo neq 445 and pc_num_avaliacao_tipo neq 2>
													<cfif pc_aval_tipo_descricao neq ''>
														<td onclick="javascript:mostraInformacoesItensAcompanhamento(#pc_aval_id#, #pc_aval_orientacao_id#)">#pc_aval_tipo_descricao#</td>
													<cfelse>
														<td onclick="javascript:mostraInformacoesItensAcompanhamento(#pc_aval_id#, #pc_aval_orientacao_id#)">#tipoProcesso#</td>
													</cfif>
												<cfelse>
													<td onclick="javascript:mostraInformacoesItensAcompanhamento(#pc_aval_id#, #pc_aval_orientacao_id#)">#pc_aval_tipo_nao_aplica_descricao#</td>
												</cfif>
												<cfset dataHora = pc_aval_orientacao_status_datahora>
												<cfset dataFormatada = DateFormat(dataHora, "dd/mm/yyyy") & " - " & TimeFormat(dataHora, "HH:mm")>
												<td data-order="#DateFormat(dataHora, 'yyyy-mm-dd')# #TimeFormat(dataHora, 'HH:mm:ss')#">#dataFormatada#</td>
												
												<td>#orgaoOrigemSigla#</td>
												<td>#orgaoAvaliado#</td>
												<td id="pcAvalId" style="display:none">#pc_aval_id#</td>
												<td id="pcAvalOrientacaoId" style="display:none">#pc_aval_orientacao_id#</td>
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

			
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	
			    
				
			$(function () {
				<cfoutput>
					var emAcomp='#arguments.processoEmAcompanhamento#';
					var colunaEmAnalise = '#colunaEmAnalise#';
				</cfoutput>
		
				var tituloExcel ="";
				if(emAcomp==='true'){
					tituloExcel = "SNCI_Consulta_Orientacoes_(Processos_em_Acomp)_";
				}else{
					tituloExcel = "SNCI_Consulta_Orientacoes_(Processos_Finalizados)_";
				}

				if (colunaEmAnalise ==1) {
				 var colunasMostrar = [1,2,7,8,11,13,14];
				} else {
				 var colunasMostrar = [0,1,6,7,10,12,13];
				}

				const tabOrientacoesProcessosAcomp = $('#tabProcessos').DataTable( {
				
					stateSave: true,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					dom: 
						"<'row d-flex align-items-center'<'col-auto dtsp-verticalContainer'P><'col-auto'B><'col-auto'f><'col-auto'p>>" + // Botões, filtros e paginação na mesma linha, alinhados à esquerda
						"<'row'<'col-12'i><'col-auto'<'remove-filter-btn'>>>" + // Informações logo abaixo dos botões
						"<'row'<'col-12'tr>>",  // Tabela com todos os dados
							
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
						$('#exibirTab').show();
						$('#exibirTabSpinner').html('');
					},
					language: {
						url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
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
				$('#tabProcessos tbody').on('click', 'tr', function(event) {
					
					// Verifica se o clique foi em uma célula da colunaEmAnalise
					var colunaStatusIndex = $('#tabProcessos th#colunaEmAnalise').index();
					var tdIndex = $(event.target).closest('td').index();

					// Se o clique foi na colunaStatus, sai da função
					if (tdIndex === colunaStatusIndex) {
						return;
					}
					
					// Remove a classe 'selected' de todas as linhas
					$('#tabProcessos tr').removeClass('selected');
					
					// Adiciona a classe 'selected' à linha clicada
					$(this).addClass('selected');

					// Pega a linha (tr) em que a célula foi clicada
					var $row = $(this);
					
					// Obtém os valores das células ocultas
					var pcProcID = $row.find('#pcProcId').text();
					var pcAvalId = $row.find('#pcAvalId').text();
					var pcAvalOrientacaoId = $row.find('#pcAvalOrientacaoId').text();

					// Chama a função mostraInformacoesItensConsulta com os valores
					mostraInformacoesItensConsulta(pcProcID, pcAvalId, pcAvalOrientacaoId);
				});



			});

			

			function mostraInformacoesItensConsulta(idProcesso,idAvaliacao, idOrientacao){	
				$('#modalOverlay').modal('show')
					setTimeout(function() {
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
							data:{
								method: "informacoesItensConsulta",
								idAvaliacao: idAvaliacao,
								idOrientacao: idOrientacao,
								idProcesso: idProcesso
							},
							async: false
						})//fim ajax
						.done(function(result) {
							$('#informacoesItensConsultaDiv').html(result)
							$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
								$('html, body').animate({ scrollTop: ($('#informacoesItensConsultaDiv').offset().top-60)} , 1000);
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

			

		</script>	

		
	

	</cffunction>

    <cffunction name="colocarEmAnalise"   access="remote" hint="coloca a orientação com status EM ANALISE">
		<cfargument name="idProcesso" type="string" required="true" />
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="idOrientacao" type="numeric" required="true" />
		<cfargument name="orgaoOrigem" type="string" required="true" />-->
		<cfargument name="analiseOrgaoOrigem" type="numeric" required="true" />

		<cfset var orgaoRespOrientacao = "">
		<cfset var statusOrientacao = "">
		<cfset var textoPosic = "">


		<!--Se for marcado checkbox, o órgão responsável será o órgão de origem do processo, caso contrário será o órgão de lotação do usuário--> 
		<cfif arguments.analiseOrgaoOrigem eq 0>
			<cfset orgaoRespOrientacao = "#application.rsUsuarioParametros.pc_usu_lotacao#">
			<cfset statusOrientacao = 17>
		<cfelse>
			<cfset orgaoRespOrientacao = "#arguments.orgaoOrigem#">
			<cfset statusOrientacao = 13>
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
					<cfqueryparam value="#statusOrientacao#" cfsqltype="cf_sql_integer">,
					<cfqueryparam value="1" cfsqltype="cf_sql_integer">
				)

			</cfquery>

			<cfquery datasource = "#application.dsn_processos#" >
				UPDATE 	pc_avaliacao_orientacoes
				SET 
					pc_aval_orientacao_status = <cfqueryparam value="#statusOrientacao#" cfsqltype="cf_sql_integer">,
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
		<cfargument name="idProcesso" type="string" required="true" />

		<cfset var rsStatus = "">
		
		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam value="#arguments.idAvaliacao#" cfsqltype="cf_sql_integer">
		</cfquery>

		<session class="content-header" >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">


					<div id="idAvaliacao" hidden></div>

					<cfquery name="rsItemNum" datasource="#application.dsn_processos#">
						SELECT pc_aval_numeracao FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">
					</cfquery>

					


				
					<input id="pcProcessoId"  required="" hidden  value="#arguments.idAvaliacao#">
			
						

				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						.card-header p {
							margin-bottom: 5px;
						}
						fieldset{
							border: 1px solid #ced4da!important;
							border-radius: 8px!important;
							padding: 20px!important;
							margin-bottom: 10px!important;
							background: none!important;
							-webkit-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							-moz-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							font-weight: 400 !important;
						}

						legend {
							font-size: 0.8rem!important;
							color: #fff!important;
							background-color: var(--azul_claro_correios)!important;
							border: 1px solid #ced4da!important;
							border-radius: 5px!important;
							padding: 5px!important;
							width: auto!important;
						}

						.borderTexto{
							border: 1px solid #ced4da!important;
							border-radius: 8px!important;
							padding: 10px!important;
							background: none!important;
							-webkit-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							-moz-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);

						}
					</style>

					<div class="card card-primary card-tabs card_border_correios"  style="width:100%">
						<div class="card-header card-header_backgroundColor" style="padding:10px!important">
							<h4 class="card-title ">	
								<div  class="d-block" style="font-size:20px;color:#fff;font-weight: bold;"> 
									<i class="fas fa-file-alt" style="margin-top:4px;"></i><span id="texto_card-title" style="margin-left:10px;font-size:16px;">Medida/Orientação p/ regularização</span>
								</div>
							</h4>
						</div>
						<div class="card-body">	
							<div class="card card-primary card_border_correios2"  style="width:100%">
								<div class="card-header p-0 pt-1 card-header_navbar_backgroundColor " >
									
									<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
									<li class="nav-item">
											<a  class="nav-link  active" id="custom-tabs-one-Orientacao-tab"  data-toggle="pill" href="#custom-tabs-one-Orientacao" role="tab" aria-controls="custom-tabs-one-Orientacao" aria-selected="true">
											Medida/Orientação ID (<strong><cfoutput>#arguments.idOrientacao#</cfoutput></strong>)</a>
										</li>
										

										<li class="nav-item" style="">
											<a  class="nav-link " id="custom-tabs-one-InfProcesso-tab"  data-toggle="pill" href="#custom-tabs-one-InfProcesso" role="tab" aria-controls="custom-tabs-one-InfProcesso" aria-selected="true">Inf. Processo</a>
										</li>

										<li class="nav-item" style="">
											<a  class="nav-link " id="custom-tabs-one-InfItem-tab"  data-toggle="pill" href="#custom-tabs-one-InfItem" role="tab" aria-controls="custom-tabs-one-InfItem" aria-selected="true">
											<cfoutput>Inf. Item ( N° <strong>#rsItemNum.pc_aval_numeracao#</strong> - ID <strong>#arguments.idAvaliacao#</strong> )</cfoutput></a>
										</li>
										
										<li class="nav-item" style="">
											<a  class="nav-link  " id="custom-tabs-one-Avaliacao-tab"  data-toggle="pill" href="#custom-tabs-one-Avaliacao" role="tab" aria-controls="custom-tabs-one-Avaliacao" aria-selected="true">Relatório</a>
										</li>
										<li class="nav-item">
											<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos da Medida/Orientação ID (<strong><cfoutput>#arguments.idOrientacao#</cfoutput></strong>)</a>
										</li>
										
									</ul>
									
								</div>
								<div class="card-body ">
									<div class="tab-content" id="custom-tabs-one-tabContent">
										<div disable class="tab-pane fade  active show " id="custom-tabs-one-Orientacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Orientacao-tab" >	
											<div id="infoOrientacaoDiv" ></div>
										</div>


										<div disable class="tab-pane fade" id="custom-tabs-one-InfProcesso"  role="tabpanel" aria-labelledby="custom-tabs-one-InfProcesso-tab" >								
											<div id="infoProcessoDiv" ></div>
										</div>

										<div disable class="tab-pane fade" id="custom-tabs-one-InfItem"  role="tabpanel" aria-labelledby="custom-tabs-one-InfItem-tab" >								
											<div id="infoItemDiv" ></div>
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
					var pc_aval_id = '#arguments.idAvaliacao#';
					var pc_aval_orientacao_id = '#arguments.idOrientacao#';
					var pc_processo_id = '#arguments.idProcesso#';
				</cfoutput>
				$('#custom-tabs-one-Orientacao-tab').on('click', function (event){
					mostraInfoOrientacao('infoOrientacaoDiv',pc_processo_id,pc_aval_orientacao_id);
				});

				$('#custom-tabs-one-InfProcesso-tab').on('click', function (event){
					mostraInfoProcesso('infoProcessoDiv',pc_processo_id);
				});

				$('#custom-tabs-one-InfItem-tab').on('click', function (event){
					mostraInfoItem('infoItemDiv',pc_processo_id,pc_aval_id);
				});	

				$('#custom-tabs-one-Avaliacao-tab').on('click', function (event){
					mostraRelatoPDF('anexoAvaliacaoDiv',pc_aval_id,'S');
				});

				$('#custom-tabs-one-Anexos-tab').on('click', function (event){
					mostraTabAnexosJS('tabAnexosDiv',pc_aval_id,pc_aval_orientacao_id);
				});
				
				mostraInfoOrientacao('infoOrientacaoDiv',pc_processo_id,pc_aval_orientacao_id,'');
			})

			$(function () {
				$('[data-mask]').inputmask()
			})


			

			



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