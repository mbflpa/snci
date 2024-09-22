<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	


	<cffunction name="tabConsultaExportarProcessos"   access="remote" hint="gera a consulta para exportação de qualquer informação sobre os processos">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>
		
		

		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT  DISTINCT    pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim
			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
						LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
			WHERE NOT pc_num_status IN (2,3) 
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#"> 
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
				<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
					AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
				<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
				</cfif>
				<!---Se o perfil for 7 - 'GESTOR' --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
				</cfif>
			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
						AND pc_num_status not in(6,7)
				</cfif>

				<!---Se o perfil for 15 - 'DIRETORIA'--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 15 >
						AND pc_num_status not in(6,7)
						AND (
							pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_num_orgao =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_sug_orgao_mcu =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
							</cfif>
						) 
					    <!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
						<cfif ListLen(application.orgaosHierarquiaList) GT 0 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
								<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
								and NOT (
										pc_aval_orientacao_status not in (13)
										AND pc_orgaos_2.pc_org_status IN ('O')
									)
								<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
								and NOT (
										pc_aval_orientacao_status = 13
										AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
									)
								and NOT (
								pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
								
						</cfif>
						
				</cfif>
				
			</cfif>
			
		</cfquery>	

		
		<cfif #rsProcTab.recordcount# neq 0 >	
		
			<div class="row">
				<div class="col-12">
					<div class="card card-success" style="margin-top:20px;">
						<div class="card-header" id="texto_card-title" style="background-color: #367657;"><span style="color:#fff; "><strong>PROCESSOS - Ano: <cfoutput>#arguments.ano#</cfoutput></strong></span></div>
					<!-- /.card-header -->
						<div class="card-body">
							<cfif #rsProcTab.recordcount# eq 0 >
								<h5 align="center">Nenhum processo foi localizado.</h5>
							</cfif>
							<cfif #rsProcTab.recordcount# neq 0 >
								<table id="tabProcessos" class="table table-bordered table-striped  text-nowrap" >
								
									<thead style="background: #0083ca;color:#fff">
										<tr style="font-size:14px">
											<th >N°Processo SNCI</th>
											<th >Status do Processo</th>
											<th >Data Fim Processo</th>
											<th >SE/CS</th>
											<th >Ano PACIN</th>
											<th >N° SEI</th>
											<th >N° Relat. SEI</th>
											<th >Início Avaliação</th>
											<th >Fim Avaliação</th>
											<th >Órgão Origem</th>
											<th >Órgão Avaliado</th>
											<th >Tipo de Avaliação</th>
											<th >Tipo de Avaliação - N3</th>
											<th >Modalidade</th>
											<th >Classificação</th>
											<th >Tipo Demanda</th>
											<th >Avaliador(es)</th>
											<th >Coordenador Regional</th>
											<th >Coordenador Nacional</th>
											<th>Objetivos Estrategicos</th>
											<th>Riscos Estrategicos</th>
											<th>Indicadores Estrategicos</th>
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="rsProcTab" >
											<cfset status = "#pc_status_id#"> 

											<cfquery datasource="#application.dsn_processos#" name="rsObjetivosEstrategicos">
												SELECT pc_objEstrategico_descricao FROM pc_processos_objEstrategicos
												INNER JOIN pc_objetivo_estrategico on pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
												WHERE pc_processos_objEstrategicos.pc_processo_id = '#pc_processo_id#'
											</cfquery>
											<cfset objetivosEstrategicosList=ValueList(rsObjetivosEstrategicos.pc_objEstrategico_descricao,"; ")>

											<cfquery datasource="#application.dsn_processos#" name="rsRiscosEstrategicos">
												SELECT pc_riscoEstrategico_descricao FROM pc_processos_riscosEstrategicos
												INNER JOIN pc_risco_estrategico on pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
												WHERE pc_processos_riscosEstrategicos.pc_processo_id = '#pc_processo_id#'
											</cfquery>
											<cfset riscosEstrategicosList=ValueList(rsRiscosEstrategicos.pc_riscoEstrategico_descricao,"; ")>

											<cfquery datasource="#application.dsn_processos#" name="rsIndicadoresEstrategicos">
												SELECT pc_indEstrategico_descricao FROM pc_processos_indEstrategicos
												INNER JOIN pc_indicador_estrategico on pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
												WHERE pc_processos_indEstrategicos.pc_processo_id = '#pc_processo_id#'
											</cfquery>
											<cfset indicadoresEstrategicosList=ValueList(rsIndicadoresEstrategicos.pc_indEstrategico_descricao,"; ")>

											<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
												SELECT  pc_avaliadores.* ,  pc_usuarios.pc_usu_nome as avaliadores
												FROM    pc_avaliadores 
														INNER JOIN pc_usuarios ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
														INNER JOIN pc_orgaos ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
												WHERE 	pc_avaliador_id_processo = '#pc_processo_id#'
											</cfquery>	 
										
											<cfset avaliadores = ValueList(rsAvaliadores.avaliadores,'; ')>

											<cfoutput>					
												<tr style="cursor:pointer;font-size:12px" >
																	
														<td align="center"> #pc_processo_id#</td>
														<td>#pc_status_descricao#</td>
														<td>#dataFimProcesso#</td>
														<td>#seOrgAvaliado#</td>
														<td>#pc_ano_pacin#</td>
														<td>#sei#</td>
														<td>#pc_num_rel_sei#</td>
														<td>#dataInicio#</td>
														<td>#dataFim#</td>
														<td>#siglaOrgOrigem#</td>
														<td>#siglaOrgAvaliado#</td>
														<td>#AvaliacaoDescricao#</td>
														<td>#tipoProcessoN3#</td>
														<td>#ModalidadeDescricao#</td>
														<td>#pc_class_descricao#</td>
														<td>#TipoDemandaDescricao#</td>
														<td>#avaliadores#</td>
														<td>#coordRegional#</td>
														<td>#coordNacional#</td>
														<td>#objetivosEstrategicosList#</td>
														<td>#riscosEstrategicosList#</td>
														<td>#indicadoresEstrategicosList#</td>
												</tr>
											</cfoutput>
										</cfloop>	
									</tbody>
									
								
								</table>
							</cfif>
						</div>
						<!-- /.card-body -->
						
						<div style="display:flex;justify-content: space-around;margin-bottom:80px;">
							<div style="margin-top:10px;width:500px;">
								<canvas id="pieChartProcessos" style="min-height: 400px; height: 400px; max-height: 400px; max-width: 100%;"></canvas>
							</div>
							<div style="margin-top:10px;width:500px">
								<canvas id="pieChartProcessos2" style="min-height: 400px; height: 400px; max-height: 400px; max-width: 100%;"></canvas>
							</div>
						</div>
						
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
		
			
			<!--Para charmar o plugin que inclui lengenda dentro do gráfico-->		
			<script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
					
			<script language="JavaScript">
				var currentDate = new Date()
				var day = currentDate.getDate()
				var month = currentDate.getMonth() + 1
				var year = currentDate.getFullYear()

				var d = day + "-" + month + "-" + year;	

				$(function () {
					// var tabela = $('#tabProcessos').DataTable();
					// // Loop através de todas as colunas
					// tabela.columns().every(function() {
					// 	// Define a propriedade visible como false
					// 	this.visible(false);
					// });
					$('#tabProcessos').DataTable( {
						destroy: true,
						ordering: false,
						stateSave: true,
						scrollY:"150px",
						filter: false,
						scrollX:        true,
						scrollCollapse: true,
						deferRender: true, // Aumentar desempenho para tabelas com muitos registros
						pageLength: 3,
						buttons: [{
								extend: 'excelHtml5',
								text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
								title : 'SNCI_Processos_' + d,
								className: 'btExcel',
								exportOptions: {
									columns: ':visible'
								},
								customize: function(xlsx) {
									var sheet = xlsx.xl.worksheets['sheet1.xml'];
									
									$('row:eq(0) c', sheet).attr('s','50');//centraliza 1° linha (título)
									$('row:eq(0) c', sheet).attr('s','2');//1° linha em negrito
									$('row:eq(1) c', sheet).attr('s','51');//2° linha centralizada
									$('row:eq(1) c', sheet).attr('s','2');//2° linha em negrito
								
									//PARA PERCORRER TODAS AS COLUNAS E APLICAR UM STYLE
									// var twoDecPlacesCols = ['A','B','C','D','E','F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];           
									// for ( i=0; i < twoDecPlacesCols.length; i++ ) {
									// 	$('row c[r^='+twoDecPlacesCols[i]+']', sheet).attr( 's', '25' );
									// }
								},
								customizeData: function (data) {
									// Percorre os dados exportados
									for (var i = 0; i < data.body.length; i++) {
									var rowData = data.body[i];
									// Percorre as células da linha
									for (var j = 0; j < rowData.length; j++) {
										var cellData = rowData[j];
										// Verifica se o valor contém "&nbsp;"
										if (cellData.includes('&nbsp;')) {
										// Substitui todas as ocorrências de "&nbsp;" por espaços regulares
										rowData[j] = cellData.replace(/&nbsp;/g, ' ');
										}
									}
									}
								}
							},
							{
								extend: 'colvis',
								text: 'Selecionar Colunas',
								className: 'btSelecionarColuna',
								collectionLayout: 'fixed three-column',
								colvisButton: true,
								
							},
					
							{
								text: '<i class="fas fa-eye" title="Visualizar todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(true);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
							{
								text: '<i class="fas fa-eye-slash" title="Oculta todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(false);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
							
						],
						drawCallback: function(settings) {//após a tabela se renderizada
							graficoPizza ('pie','tabProcessos','CLASSIFICAÇÃO (PROCESSOS)','Classificação','pieChartProcessos')	
							graficoPizza ('pie','tabProcessos','STATUS (PROCESSOS)','Status do Processo','pieChartProcessos2')	
						}	
						
					}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');

				} );

			</script>	
		<cfelse>
			<cfreturn 'N'> 	
		</cfif>
	</cffunction>



	<cffunction name="tabConsultaExportarItens"   access="remote" hint="gera a consulta para exportação de qualquer informação sobre os processos">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>
		
		

		<cfquery name="rsProcTabInicio" datasource="#application.dsn_processos#" timeout="120" >
			SELECT  DISTINCT  pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_id 
						,pc_aval_numeracao
						,pc_aval_descricao
						,pc_aval_status_descricao
						,pc_aval_classificacao
						,pc_aval_valorEstimadoRecuperar
						,pc_aval_valorEstimadoRisco
						,pc_aval_valorEstimadoNaoPlanejado
						,pc_aval_teste
						,pc_aval_controleTestado
						,pc_aval_sintese
						,pc_aval_cosoComponente
						,pc_aval_cosoPrincipio
						,pc_aval_criterioRef_descricao
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim


			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
						LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						INNER JOIN pc_avaliacao_coso on pc_avaliacoes.pc_aval_coso_id = pc_avaliacao_coso.pc_aval_coso_id
						INNER JOIN pc_avaliacao_criterioReferencia on pc_avaliacoes.pc_aval_criterioRef_id = pc_avaliacao_criterioReferencia.pc_aval_criterioRef_id
			WHERE NOT pc_num_status IN (2,3) 
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
				<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
					AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
				<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
				</cfif>
				<!---Se o perfil for 7 - 'GESTOR' --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
				</cfif>
			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13>
					AND pc_aval_status_id not in(1,2,3,5,8)	AND pc_num_status not in(6,7)
				</cfif>

				<!---Se o perfil for 15 - 'DIRETORIA' --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 15>
					AND pc_aval_status_id not in(1,2,3,5,8)	AND pc_num_status not in(6,7)
					AND (
							pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_num_orgao =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_sug_orgao_mcu =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
							</cfif>
						) 
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif ListLen(application.orgaosHierarquiaList) GT 0 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
							and NOT (
									pc_aval_orientacao_status not in (13)
									AND pc_orgaos_2.pc_org_status IN ('O')
								)
							<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
							and NOT (
									pc_aval_orientacao_status = 13
									AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
								)
							and NOT (
								pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
							
					</cfif>
				
				</cfif>
			
			</cfif>
		
			
		</cfquery>	
		<cfquery dbtype="query" name="rsProcTab"> 
			select distinct rsProcTabInicio.* from rsProcTabInicio
		</cfquery>

		<cfif #rsProcTab.recordcount# neq 0 >
			<div class="row">
					<div class="col-12">
						<div class="card card-success" style="margin-top:20px;">
							<div class="card-header" id="texto_card-title" style="background-color: #367657;"><span style="color:#fff; "><strong>ITENS - Ano: <cfoutput>#arguments.ano#</cfoutput></strong></span></div>
						
							<!-- /.card-header -->
							<div class="card-body">
								<cfif #rsProcTab.recordcount# eq 0 >
									<h5 align="center">Nenhum item foi localizado.</h5>
								</cfif>
								<cfif #rsProcTab.recordcount# neq 0 >
									<table id="tabProcessos" class="table table-bordered table-striped  text-nowrap">
										<thead style="background: #0083ca;color:#fff">
											<tr style="font-size:14px">
												<th >N°Processo SNCI</th>
												<th >Status do Processo</th>
												<th >Data Fim Processo</th>
												<th >SE/CS</th>
												<th >Ano PACIN</th>
												<th >N° SEI</th>
												<th >N° Relat. SEI</th>
												<th >Início Avaliação</th>
												<th >Fim Avaliação</th>
												<th >Órgão Origem</th>
												<th >Órgão Avaliado</th>
												<th >Tipo de Avaliação</th>
												<th >Tipo de Avaliação - N3</th>
												<th >Modalidade</th>
												<th >Classificação</th>
												<th >Tipo Demanda</th>
												<th >Avaliador(es)</th>
												<th >Coordenador Regional</th>
												<th >Coordenador Nacional</th>
												<th>Objetivos Estrategicos</th>
												<th>Riscos Estrategicos</th>
												<th>Indicadores Estrategicos</th>
												<th >Cód. Item</th>
												<th >N° do Item</th>
												<th>Título da situação encontrada</th>
												<th>Teste (Pergunta do Plano)</th>
												<th>Controle Testado</th>	
												<th>Tipo de Controle</th>
												<th>Categoria do Controle Testado</th>
												<th>Síntese</th>
												<th>Risco Identificado</th>
												<th>Componente COSO</th>
											    <th>Princípio COSO</th>
												<th>Critérios e Referências Normativas</th>
												<th>Classificação do Item</th>
												<th>P.V.E. Recuperar</th>
												<th>P.V.E. Risco ou Valor Envolvido</th>
												<th>P.V.E. Não Planejado/Extrapolado/Sobra</th>
												<th>Status do Item</th>
											</tr>
										</thead>
										
										<tbody>
											<cfloop query="rsProcTab" >
												<cfset status = "#pc_status_id#">

												<cfquery datasource="#application.dsn_processos#" name="rsTiposControles">
													SELECT pc_aval_tipoControle_descricao FROM pc_avaliacao_tiposControles
													INNER JOIN pc_avaliacao_tipoControle on pc_avaliacao_tipoControle.pc_aval_tipoControle_id = pc_avaliacao_tiposControles.pc_aval_tipoControle_id
													WHERE pc_avaliacao_tiposControles.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset tiposControlesList=ValueList(rsTiposControles.pc_aval_tipoControle_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsCategoriasControles">
													SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_categoriasControles
													INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_categoriasControles.pc_aval_categoriaControle_id
													WHERE pc_avaliacao_categoriasControles.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset categoriasControlesList=ValueList(rsCategoriasControles.pc_aval_categoriaControle_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsRiscos">
													SELECT pc_aval_risco_descricao FROM pc_avaliacao_riscos
													INNER JOIN pc_avaliacao_risco on pc_avaliacao_risco.pc_aval_risco_id = pc_avaliacao_riscos.pc_aval_risco_id
													WHERE pc_avaliacao_riscos.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset riscosList=ValueList(rsRiscos.pc_aval_risco_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsObjetivosEstrategicos">
													SELECT pc_objEstrategico_descricao FROM pc_processos_objEstrategicos
													INNER JOIN pc_objetivo_estrategico on pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
													WHERE pc_processos_objEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset objetivosEstrategicosList=ValueList(rsObjetivosEstrategicos.pc_objEstrategico_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsRiscosEstrategicos">
													SELECT pc_riscoEstrategico_descricao FROM pc_processos_riscosEstrategicos
													INNER JOIN pc_risco_estrategico on pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
													WHERE pc_processos_riscosEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset riscosEstrategicosList=ValueList(rsRiscosEstrategicos.pc_riscoEstrategico_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsIndicadoresEstrategicos">
													SELECT pc_indEstrategico_descricao FROM pc_processos_indEstrategicos
													INNER JOIN pc_indicador_estrategico on pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
													WHERE pc_processos_indEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset indicadoresEstrategicosList=ValueList(rsIndicadoresEstrategicos.pc_indEstrategico_descricao,"; ")>
 
												<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
													SELECT  pc_avaliadores.* ,  pc_usuarios.pc_usu_nome as avaliadores
													FROM    pc_avaliadores 
															INNER JOIN pc_usuarios ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
															INNER JOIN pc_orgaos ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
													WHERE 	pc_avaliador_id_processo = '#pc_processo_id#'
												</cfquery>	 
											
												<cfset avaliadores = ValueList(rsAvaliadores.avaliadores,'; ')>
		
												<cfoutput>					
													<tr style="cursor:pointer;font-size:12px" >
																		
															<td align="center"> #pc_processo_id#</td>
															<td>#pc_status_descricao#</td>
															<td>#dataFimProcesso#</td>
															<td>#seOrgAvaliado#</td>
															<td>#pc_ano_pacin#</td>
															<td>#sei#</td>
															<td>#pc_num_rel_sei#</td>
															<td>#dataInicio#</td>
															<td>#dataFim#</td>
															<td>#siglaOrgOrigem#</td>
															<td>#siglaOrgAvaliado#</td>
															<td>#AvaliacaoDescricao#</td>
															<td>#tipoProcessoN3#</td>
															<td>#ModalidadeDescricao#</td>
															<td>#pc_class_descricao#</td>
															<td>#TipoDemandaDescricao#</td>
															<td>#avaliadores#</td>
															<td>#coordRegional#</td>
															<td>#coordNacional#</td>
															<td>#objetivosEstrategicosList#</td>
															<td>#riscosEstrategicosList#</td>
															<td>#indicadoresEstrategicosList#</td>
															<td >#pc_aval_id#</td>
															<td >#pc_aval_numeracao#</td>
															<td >#pc_aval_descricao#</td>
															<td>#pc_aval_teste#</td>
															<td>#pc_aval_controleTestado#</td>
															<td>#tiposControlesList#</td>
															<td>#categoriasControlesList#</td>
															<td>#pc_aval_sintese#</td>
															<td>#riscosList#</td>
															<td>#pc_aval_cosoComponente#</td>
															<td>#pc_aval_cosoPrincipio#</td>
															<td>#pc_aval_criterioRef_descricao#</td>

															<cfset classifRisco = "">
															<cfif #pc_aval_classificacao# eq 'L'>
																<cfset classifRisco = "Leve">
															</cfif>	
															<cfif #pc_aval_classificacao# eq 'M'>
																<cfset classifRisco = "Mediano">
															</cfif>	
															<cfif #pc_aval_classificacao# eq 'G'>
																<cfset classifRisco = "Grave">
															</cfif>	
															<cfif #pc_aval_classificacao# eq ''>
																<cfset classifRisco = "Não Classificado">
															</cfif>	

															<td>#classifRisco#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoRecuperar, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoRisco, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoNaoPlanejado, 'local')#</td>
															<td>#pc_aval_status_descricao#</td> 
															
			
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
										
									
									</table>
								</cfif>
							</div>
							<!-- /.card-body -->
						</div>
						<div style="display:flex;justify-content: space-around;">
							<div style="margin-top:10px;width:500px;margin-bottom:80px;">
								<canvas id="pieChartItens" style="min-height: 400px; height: 400px; max-height: 400px; max-width: 100%;"></canvas>
							</div>
							<div style="margin-top:10px;width:500px;margin-bottom:80px;">
								<canvas id="pieChartItens2" style="min-height: 400px; height: 400px; max-height: 400px; max-width: 100%;"></canvas>
							</div>
						</div>
						<!-- /.card -->
					</div>
				<!-- /.col -->
				</div>
				<!-- /.row -->
					
			<!--Para charmar o plugin que inclui lengenda dentro do gráfico-->		
			<script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
				
			<script language="JavaScript">
				var currentDate = new Date()
				var day = currentDate.getDate()
				var month = currentDate.getMonth() + 1
				var year = currentDate.getFullYear()

				var d = day + "-" + month + "-" + year;	
				$(function () {
					// var tabela = $('#tabProcessos').DataTable();
					// // Loop através de todas as colunas
					// tabela.columns().every(function() {
					// 	// Define a propriedade visible como false
					// 	this.visible(false);
					// });
					$('#tabProcessos').DataTable( {
						destroy: true,
						ordering: false,
						stateSave: true,
						scrollY:"150px",
						filter: false,
						scrollX:        true,
						scrollCollapse: true,
						deferRender: true, // Aumentar desempenho para tabelas com muitos registros
						pageLength: 3,
						buttons: [{
								extend: 'excelHtml5',
								text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
								title : 'SNCI_Itens_' + d,
								className: 'btExcel',
								exportOptions: {
									columns: ':visible',
									format: {
										body: function(data, row, column, node) {
											if (column === $('th:contains("N° do Item")').index()) {
												return data.replaceAll('.', ' . ');
											} else {
												return data;
											}
										}
									}
								},
								customize: function(xlsx) {
									var sheet = xlsx.xl.worksheets['sheet1.xml'];
									
									$('row:eq(0) c', sheet).attr('s','50');//centraliza 1° linha (título)
									$('row:eq(0) c', sheet).attr('s','2');//1° linha em negrito
									$('row:eq(1) c', sheet).attr('s','51');//2° linha centralizada
									$('row:eq(1) c', sheet).attr('s','2');//2° linha em negrito
								
									//PARA PERCORRER TODAS AS COLUNAS E APLICAR UM STYLE
									// var twoDecPlacesCols = ['A','B','C','D','E','F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];           
									// for ( i=0; i < twoDecPlacesCols.length; i++ ) {
									// 	$('row c[r^='+twoDecPlacesCols[i]+']', sheet).attr( 's', '25' );
									// }
								},
								customizeData: function (data) {
									// Percorre os dados exportados
									for (var i = 0; i < data.body.length; i++) {
									var rowData = data.body[i];
									// Percorre as células da linha
									for (var j = 0; j < rowData.length; j++) {
										var cellData = rowData[j];
										// Verifica se o valor contém "&nbsp;"
										if (cellData.includes('&nbsp;')) {
										// Substitui todas as ocorrências de "&nbsp;" por espaços regulares
										rowData[j] = cellData.replace(/&nbsp;/g, ' ');
										}
									}
									}
								}
							},
							{
								extend: 'colvis',
								text: 'Selecionar Colunas',
								className: 'btSelecionarColuna',
								collectionLayout: 'fixed three-column',
								colvisButton: true,
								
							},
					
							
							{
								text: '<i class="fas fa-eye" title="Visualizar todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(true);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
							{
								text: '<i class="fas fa-eye-slash" title="Oculta todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(false);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
						],
						drawCallback: function(settings) {//após a tabela se renderizada
							graficoPizza ('pie','tabProcessos','CLASSIFICAÇÃO (ITENS)','Classificação do Item','pieChartItens')	
							graficoPizza ('pie','tabProcessos','STATUS (ITENS)','Status do Item','pieChartItens2')		
						}
						
					}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');

					graficoPizza ('pie','tabProcessos','CLASSIFICAÇÃO (ITENS)','Classificação do Item','pieChartItens')	
					graficoPizza ('pie','tabProcessos','STATUS (ITENS)','Status do Item','pieChartItens2')	
						
				} );

			

			</script>	
		<cfelse>
			<cfreturn 'N'> 	
		</cfif>		

	</cffunction>





    <cffunction name="tabConsultaExportarOrientacoes"   access="remote" hint="gera a consulta para exportação de qualquer informação sobre os processos">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>
		
		<cfquery name="rsProcTabInicio" datasource="#application.dsn_processos#" timeout="120" >

			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_numeracao,pc_aval_descricao , pc_aval_id, pc_aval_orientacao_id
						,pc_aval_orientacao_descricao,pc_aval_orientacao_dataPrevistaResp,pc_aval_orientacao_status
						,pc_orgaos_resp.pc_org_sigla + ' (' + pc_aval_orientacao_mcu_orgaoResp + ')' as orientacaoOrgaoResp
						,pc_orientacao_status.pc_orientacao_status_descricao, pc_aval_status_descricao,pc_aval_classificacao
						,pc_aval_orientacao_dataPrevistaResp  
						,pc_aval_valorEstimadoRecuperar
						,pc_aval_valorEstimadoRisco
						,pc_aval_valorEstimadoNaoPlanejado 
						,pc_aval_teste
						,pc_aval_controleTestado
						,pc_aval_sintese
						,pc_aval_cosoComponente
						,pc_aval_cosoPrincipio
						,pc_aval_criterioRef_descricao
						,pc_orientacao_status.pc_orientacao_status_finalizador,
						CASE
							WHEN  CONVERT(VARCHAR(10), pc_aval_orientacao_dataPrevistaResp, 102)  < CONVERT(VARCHAR(10), GETDATE(), 102) AND pc_aval_orientacao_status IN (4, 5) THEN 'PENDENTE'
							ELSE pc_orientacao_status_descricao
						END AS statusDescricao
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim
						,pc_aval_orientacao_beneficioNaoFinanceiro
						,pc_aval_orientacao_beneficioFinanceiro
						,pc_aval_orientacao_custoFinanceiro
			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						INNER JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos AS pc_orgaos_resp ON pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_resp.pc_org_mcu 
						LEFT JOIN  pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
					    LEFT JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
						LEFT JOIN pc_orgaos AS pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
						INNER JOIN pc_avaliacao_coso on pc_avaliacoes.pc_aval_coso_id = pc_avaliacao_coso.pc_aval_coso_id
						INNER JOIN pc_avaliacao_criterioReferencia on pc_avaliacoes.pc_aval_criterioRef_id = pc_avaliacao_criterioReferencia.pc_aval_criterioRef_id
			WHERE NOT pc_num_status IN (2,3)  and pc_aval_orientacao_id is not null
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
				<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
					AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
				<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
				</cfif>
				<!---Se o perfil for 7 - 'GESTOR' --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
				</cfif>
			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
						AND  pc_aval_orientacao_status not in (0,9,12,14) and pc_num_status not in(6,7)
				<cfelse>
					<!---Não exibe orientações pendentes de posicionamento inicial do controle interno, canceladas, improcedentes e bloqueadas--->
				    AND pc_aval_orientacao_status not in (0,1,9,12,14) and pc_num_status not in(6,7)
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
									AND pc_orgaoResp.pc_org_status IN ('O')
								)
							<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
							and NOT (
									pc_aval_orientacao_status = 13
									AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
								)
					</cfif>
				</cfif>	
			</cfif>

		</cfquery>

		<cfquery dbtype="query" name="rsProcTab" timeout="120" > 
			select distinct rsProcTabInicio.* from rsProcTabInicio
		</cfquery>

		<cfif #rsProcTab.recordcount# neq 0 >
			<div class="row">
					<div class="col-12">
						<div class="card card-success" style="margin-top:20px;">
							<div class="card-header" id="texto_card-title" style="background: #367657;"><span style="color:#fff; "><strong>ORIENTAÇÕES - Ano: <cfoutput>#arguments.ano#</cfoutput></strong></span></div>
						
							<!-- /.card-header -->
							<div class="card-body " id="dataTableContainer" >
								<cfif #rsProcTab.recordcount# eq 0 >
									<h5 align="center">Nenhuma orientação foi localizada.</h5>
								</cfif>
								<cfif #rsProcTab.recordcount# neq 0 >
									<table id="tabProcessos" class="table table-bordered table-striped  text-nowrap" >
										<thead style="background: #0083ca;color:#fff">
											<tr style="font-size:14px">
												<th >N°Processo SNCI</th>
												<th >Status do Processo</th>
												<th >Data Fim Processo</th>
												<th >SE/CS</th>
												<th >Ano PACIN</th>
												<th >N° SEI</th>
												<th >N° Relat. SEI</th>
												<th >Início Avaliação</th>
												<th >Fim Avaliação</th>
												<th >Órgão Origem</th>
												<th >Órgão Avaliado</th>
												<th >Tipo de Avaliação</th>
												<th >Tipo de Avaliação - N3</th>
												<th >Modalidade</th>
												<th >Classificação</th>
												<th >Tipo Demanda</th>
												<th >Avaliador(es)</th>
												<th >Coordenador Regional</th>
												<th >Coordenador Nacional</th>
												<th>Objetivos Estrategicos</th>
												<th>Riscos Estrategicos</th>
												<th>Indicadores Estrategicos</th>
												<th >Cód. Item</th>
												<th >N° do Item</th>
												<th>Título da situação encontrada</th>
												<th>Teste (Pergunta do Plano)</th>
												<th>Controle Testado</th>	
												<th>Tipo de Controle</th>
												<th>Categoria do Controle Testado</th>
												<th>Síntese</th>
												<th>Risco Identificado</th>
												<th>Componente COSO</th>
											    <th>Princípio COSO</th>
												<th>Critérios e Referências Normativas</th>
												<th>Classificação do Item</th>
												<th>P.V.E. Recuperar</th>
												<th>P.V.E. Risco ou Valor Envolvido</th>
												<th>P.V.E. Não Planejado/Extrapolado/Sobra</th>
												<th>Status do Item</th>
												<th >Cód. Orientação</th>
												<th >Orientação</th>
												<th >Órgão Responsável</th>
												<th>Categoria do Controle Proposto</th>
												<th>Benefício Não Financeiro</th>
												<th>Benefício Financeiro</th>
												<th>Custo Financeiro</th>
												<th >Status da Orientação</th>
												<th >Data Prev. Resp.</th>
												<th >Acomp. Finalizado?</th>
											</tr>
										</thead>
										
										<tbody>
											<cfloop query="rsProcTab" >
												<cfset status = "#pc_status_id#"> 

												<cfquery datasource="#application.dsn_processos#" name="rsTiposControles">
													SELECT pc_aval_tipoControle_descricao FROM pc_avaliacao_tiposControles
													INNER JOIN pc_avaliacao_tipoControle on pc_avaliacao_tipoControle.pc_aval_tipoControle_id = pc_avaliacao_tiposControles.pc_aval_tipoControle_id
													WHERE pc_avaliacao_tiposControles.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset tiposControlesList=ValueList(rsTiposControles.pc_aval_tipoControle_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsCategoriasControles">
													SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_categoriasControles
													INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_categoriasControles.pc_aval_categoriaControle_id
													WHERE pc_avaliacao_categoriasControles.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset categoriasControlesList=ValueList(rsCategoriasControles.pc_aval_categoriaControle_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsRiscos">
													SELECT pc_aval_risco_descricao FROM pc_avaliacao_riscos
													INNER JOIN pc_avaliacao_risco on pc_avaliacao_risco.pc_aval_risco_id = pc_avaliacao_riscos.pc_aval_risco_id
													WHERE pc_avaliacao_riscos.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset riscosList=ValueList(rsRiscos.pc_aval_risco_descricao,"; ")>


												<cfquery datasource="#application.dsn_processos#" name="rsObjetivosEstrategicos">
													SELECT pc_objEstrategico_descricao FROM pc_processos_objEstrategicos
													INNER JOIN pc_objetivo_estrategico on pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
													WHERE pc_processos_objEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset objetivosEstrategicosList=ValueList(rsObjetivosEstrategicos.pc_objEstrategico_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsRiscosEstrategicos">
													SELECT pc_riscoEstrategico_descricao FROM pc_processos_riscosEstrategicos
													INNER JOIN pc_risco_estrategico on pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
													WHERE pc_processos_riscosEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset riscosEstrategicosList=ValueList(rsRiscosEstrategicos.pc_riscoEstrategico_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsIndicadoresEstrategicos">
													SELECT pc_indEstrategico_descricao FROM pc_processos_indEstrategicos
													INNER JOIN pc_indicador_estrategico on pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
													WHERE pc_processos_indEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset indicadoresEstrategicosList=ValueList(rsIndicadoresEstrategicos.pc_indEstrategico_descricao,"; ")>

												<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
													SELECT  pc_avaliadores.* ,  pc_usuarios.pc_usu_nome as avaliadores
													FROM    pc_avaliadores 
															INNER JOIN pc_usuarios ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
															INNER JOIN pc_orgaos ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
													WHERE 	pc_avaliador_id_processo = '#pc_processo_id#'
												</cfquery>	 
											
												<cfset avaliadores = ValueList(rsAvaliadores.avaliadores,'; ')>

												<cfquery datasource="#application.dsn_processos#" name="rsOrientacaoCategoriasControles">
													SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_orientacao_categoriasControles
													INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_orientacao_categoriasControles.pc_aval_categoriaControle_id
													WHERE pc_avaliacao_orientacao_categoriasControles.pc_aval_orientacao_id = '#pc_aval_orientacao_id#'
												</cfquery>
												<cfset categoriasControlesOrientacaoList=ValueList(rsOrientacaoCategoriasControles.pc_aval_categoriaControle_descricao,"; ")>
												
												<cfoutput>	

													<tr style="cursor:pointer;font-size:12px" >
																		
															<td align="center"> #pc_processo_id#</td>
															<td>#pc_status_descricao#</td>
															<td>#dataFimProcesso#</td>
															<td>#seOrgAvaliado#</td>
															<td>#pc_ano_pacin#</td>
															<td>#sei#</td>
															<td>#pc_num_rel_sei#</td>
															<td>#dataInicio#</td>
															<td>#dataFim#</td>
															<td>#siglaOrgOrigem#</td>
															<td>#siglaOrgAvaliado#</td>
															<td>#AvaliacaoDescricao#</td>
															<td>#tipoProcessoN3#</td>
															<td>#ModalidadeDescricao#</td>
															<td>#pc_class_descricao#</td>
															<td>#TipoDemandaDescricao#</td>
															<td>#avaliadores#</td>
															<td>#coordRegional#</td>
															<td>#coordNacional#</td>
															<td>#objetivosEstrategicosList#</td>
															<td>#riscosEstrategicosList#</td>
															<td>#indicadoresEstrategicosList#</td>
															<td >#pc_aval_id#</td>
															<td >#pc_aval_numeracao#</td>
															<td >#pc_aval_descricao#</td>
															<td>#pc_aval_teste#</td>
															<td>#pc_aval_controleTestado#</td>
															<td>#tiposControlesList#</td>
															<td>#categoriasControlesList#</td>
															<td>#pc_aval_sintese#</td>
															<td>#riscosList#</td>
															<td>#pc_aval_cosoComponente#</td>
															<td>#pc_aval_cosoPrincipio#</td>
															<td>#pc_aval_criterioRef_descricao#</td>

															<cfset classifRisco = "">
															<cfif #pc_aval_classificacao# eq 'L'>
																<cfset classifRisco = "Leve">
															</cfif>	
															<cfif #pc_aval_classificacao# eq 'M'>
																<cfset classifRisco = "Mediano">
															</cfif>	
															<cfif #pc_aval_classificacao# eq 'G'>
																<cfset classifRisco = "Grave">
															</cfif>	
															<cfif #pc_aval_classificacao# eq ''>
																<cfset classifRisco = "Não Classificado">
															</cfif>	
															<td>#classifRisco#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoRecuperar, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoRisco, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoNaoPlanejado, 'local')#</td>
															
															<td>#pc_aval_status_descricao#</td> 
															<td >#pc_aval_orientacao_id#</td>
															<td >#pc_aval_orientacao_descricao#</td>
															<td>#orientacaoOrgaoResp#</td>

															<td>#categoriasControlesOrientacaoList#</td>
															<td>#pc_aval_orientacao_beneficioNaoFinanceiro#</td>
															<td>#LSCurrencyFormat(pc_aval_orientacao_beneficioFinanceiro, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_orientacao_custoFinanceiro, 'local')#</td>

															<td>#statusDescricao#</td>
															<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,'DD-MM-YYYY') >
															<cfif pc_aval_orientacao_status eq 4 and pc_aval_orientacao_status eq 5>
																<td>#dataPrev#</td>
															<cfelse>
																<td></td>
															</cfif>
															
															<cfif pc_orientacao_status_finalizador eq "S">
																<td>Sim</td>
															<cfelse>
																<td>Não</td>
															</cfif>
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
										
									
									</table>

									

								</cfif>

							</div>
							<!-- /.card-body -->
							<div style = "display:flex;justify-content: space-around;margin-bottom:80px;">
								<canvas id="pieChartOrientacoes" style="max-width: 50%;margin-left:10px;"></canvas>
								<div style="margin-top:10px;width:500px">
									<canvas id="pieChartOrientacoes2" style="min-height: 400px; height: 400px; max-height: 400px; max-width: 100%;"></canvas>
								</div>
							</div>
								
						</div>
						<!-- /.card -->
					</div>
				<!-- /.col -->
				</div>
				<!-- /.row -->
					
			<!--Para charmar o plugin que inclui lengenda dentro do gráfico-->		
			<script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
					
			<script language="JavaScript">

				var currentDate = new Date()
				var day = currentDate.getDate()
				var month = currentDate.getMonth() + 1
				var year = currentDate.getFullYear()

				var d = day + "-" + month + "-" + year;	
				$(function () {
					// var tabela = $('#tabProcessos').DataTable();
					// // Loop através de todas as colunas
					// tabela.columns().every(function() {
					// 	// Define a propriedade visible como false
					// 	this.visible(false);
					// });
					$('#tabProcessos').DataTable( {
						destroy: true,
						ordering: false,
						stateSave: true,
						scrollY:"150px",
						filter: false,
						scrollX:        true,
						scrollCollapse: true,
						deferRender: true, // Aumentar desempenho para tabelas com muitos registros
						pageLength: 3,
						
						buttons: [						
							{
								extend: 'excelHtml5',
								text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
								title : 'SNCI_Orientacoes_' + d,
								className: 'btExcel',
								exportOptions: {
									columns: ':visible',
									format: {
										body: function(data, row, column, node) {
											if (column === $('th:contains("N° do Item")').index()) {
												
												return data.replaceAll('.', ' . ');
											} else {
												return data;
											}
										}
									}
								},
								customize: function(xlsx) {
									var sheet = xlsx.xl.worksheets['sheet1.xml'];
									
									$('row:eq(0) c', sheet).attr('s','50');//centraliza 1° linha (título)
									$('row:eq(0) c', sheet).attr('s','2');//1° linha em negrito
									$('row:eq(1) c', sheet).attr('s','51');//2° linha centralizada
									$('row:eq(1) c', sheet).attr('s','2');//2° linha em negrito
								
									//PARA PERCORRER TODAS AS COLUNAS E APLICAR UM STYLE
									// var twoDecPlacesCols = ['A','B','C','D','E','F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];           
									// for ( i=0; i < twoDecPlacesCols.length; i++ ) {
									// 	$('row c[r^='+twoDecPlacesCols[i]+']', sheet).attr( 's', '25' );
									// }
								},
								customizeData: function (data) {
									// Percorre os dados exportados
									for (var i = 0; i < data.body.length; i++) {
									var rowData = data.body[i];
									// Percorre as células da linha
									for (var j = 0; j < rowData.length; j++) {
										var cellData = rowData[j];
										// Verifica se o valor contém "&nbsp;"
										if (cellData.includes('&nbsp;')) {
										// Substitui todas as ocorrências de "&nbsp;" por espaços regulares
										rowData[j] = cellData.replace(/&nbsp;/g, ' ');
										}
									}
									}
								}
							},
							{
								extend: 'colvis',
								text: 'Selecionar Colunas',
								className: 'btSelecionarColuna',
								collectionLayout: 'fixed three-column',
								colvisButton: true,
								
							},				
							
							{
								text: '<i class="fas fa-eye" title="Visualizar todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(true);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
							{
								text: '<i class="fas fa-eye-slash" title="Oculta todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(false);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
								
							
							
						],
						
						drawCallback: function(settings) {//após a tabela se renderizada
							graficoBarra ('tabProcessos','STATUS (ORIENTAÇÕES)','Status da Orientação','pieChartOrientacoes')	
							graficoPizza ('pie','tabProcessos','ACOMPANHAMENTO FINALIZADO (ORIENTAÇÕES)','Acomp. Finalizado?','pieChartOrientacoes2') 
						},	
						
					}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');
					
				} );

			

			</script>		
		<cfelse>
			<cfreturn 'N'>
		</cfif>	

	</cffunction>





	<cffunction name="tabConsultaExportarMelhorias"   access="remote" hint="gera a consulta para exportação de qualquer informação sobre os processos">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>
		
		

		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_numeracao,pc_aval_descricao, pc_aval_status_descricao, pc_aval_classificacao
						,pc_aval_melhoria_descricao, pc_aval_melhoria_status, pc_aval_melhoria_dataPrev
						,pc_orgaos_melhoria.pc_org_sigla + '(' + pc_orgaos_melhoria.pc_org_mcu + ')' as orgaoResp
						,pc_orgaos_melhoria_sug.pc_org_sigla + '(' + pc_orgaos_melhoria_sug.pc_org_mcu + ')' as orgaoRespSug
						,pc_aval_melhoria_sugestao, pc_aval_melhoria_naoAceita_justif
						,pc_aval_valorEstimadoRecuperar
						,pc_aval_valorEstimadoRisco
						,pc_aval_valorEstimadoNaoPlanejado
						,pc_aval_teste
						,pc_aval_controleTestado
						,pc_aval_sintese
						,pc_aval_cosoComponente
						,pc_aval_cosoPrincipio
						,pc_aval_criterioRef_descricao
						,pc_aval_id, pc_aval_melhoria_id
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim
						,pc_aval_melhoria_beneficioNaoFinanceiro
						,pc_aval_melhoria_beneficioFinanceiro
						,pc_aval_melhoria_custoFinanceiro

			FROM        pc_processos 
						INNER JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						INNER JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						INNER JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						INNER JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						
						INNER JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						INNER JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						INNER JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						INNER JOIN pc_orgaos as  pc_orgaos_melhoria on pc_orgaos_melhoria.pc_org_mcu = pc_aval_melhoria_num_orgao
						LEFT JOIN  pc_orgaos as pc_orgaos_melhoria_sug on pc_orgaos_melhoria_sug.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
			            INNER JOIN pc_avaliacao_coso on pc_avaliacoes.pc_aval_coso_id = pc_avaliacao_coso.pc_aval_coso_id
						INNER JOIN pc_avaliacao_criterioReferencia on pc_avaliacoes.pc_aval_criterioRef_id = pc_avaliacao_criterioReferencia.pc_aval_criterioRef_id
			WHERE NOT pc_num_status IN (2,3) 
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
				<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
					AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
				<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
				</cfif>
				<!---Se o perfil for 7 - 'GESTOR' --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
					AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
				</cfif>

			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO), não mostra processos e melhorias bloqueadas--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
					AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6,7)
				<cfelse>
				    AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6,7)
					AND (
							pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR  pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_sug_orgao_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0> 
								OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
							</cfif>
						)
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							and NOT (
									pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
								)
							
					</cfif>	
				</cfif>
			
			</cfif>

			
		</cfquery>	

		
		<cfif #rsProcTab.recordcount# neq 0 >
			<div class="row">
					<div class="col-12">
						<div class="card card-success" style="margin-top:20px;">
							<div class="card-header" id="texto_card-title" style="background-color: #367657;"><span style="color:#fff; "><strong>PROP. MELHORIA - Ano: <cfoutput>#arguments.ano#</cfoutput></strong></span></div>
						
							<!-- /.card-header -->
							<div class="card-body">
								<cfif #rsProcTab.recordcount# eq 0 >
									<h5 align="center">Nenhuma proposta de melhoria foi localizada.</h5>
								</cfif>
								<cfif #rsProcTab.recordcount# neq 0 >
									<table id="tabProcessos" class="table table-bordered table-striped  text-nowrap" >
										<thead style="background: #0083ca;color:#fff">
											<tr style="font-size:14px">
												<th >N°Processo SNCI</th>
												<th >Status do Processo</th>
												<th >Data Fim Processo</th>
												<th >SE/CS</th>
												<th >Ano PACIN</th>
												<th >N° SEI</th>
												<th >N° Relat. SEI</th>
												<th >Início Avaliação</th>
												<th >Fim Avaliação</th>
												<th >Órgão Origem</th>
												<th >Órgão Avaliado</th>
												<th >Tipo de Avaliação</th>
												<th >Tipo de Avaliação - N3</th>
												<th >Modalidade</th>
												<th >Classificação</th>
												<th >Tipo Demanda</th>
												<th >Avaliador(es)</th>
												<th >Coordenador Regional</th>
												<th >Coordenador Nacional</th>
												<th>Objetivos Estrategicos</th>
												<th>Riscos Estrategicos</th>
												<th>Indicadores Estrategicos</th>
												<th >Cód. Item</th>
												<th >N° do Item</th>
												<th>Título da situação encontrada</th>
												<th>Teste (Pergunta do Plano)</th>
												<th>Controle Testado</th>	
												<th>Tipo de Controle</th>
												<th>Categoria do Controle Testado</th>
												<th>Síntese</th>
												<th>Risco Identificado</th>
												<th>Componente COSO</th>
											    <th>Princípio COSO</th>
												<th>Critérios e Referências Normativas</th>
												<th>Classificação do Item</th>
												<th>P.V.E. Recuperar</th>
												<th>P.V.E. Risco ou Valor Envolvido</th>
												<th>P.V.E. Não Planejado/Extrapolado/Sobra</th>
												<th>Status do Item</th>
												<th>Cód. Prop. Melhoria</th>
												<th>Proposta de Melhoria</th>
												<th>Órgão Responsável</th>
												<th>Categoria do Controle Proposto</th>
												<th>Benefício Não Financeiro</th>
												<th>Benefício Financeiro</th>
												<th>Custo Financeiro</th>
												<th>Status da Prop. Melhoria</th>
												<th>Data Prev.</th>
												<th>Melhoria Sugerida pelo Órgão</th>
												<th>Órgão Resp. Sugerido</th>
												<th>Justificativa da Recusa</th>
												
											</tr>
										</thead>
										
										<tbody>
											<cfloop query="rsProcTab" >
												<cfset status = "#pc_status_id#"> 

												<cfquery datasource="#application.dsn_processos#" name="rsTiposControles">
													SELECT pc_aval_tipoControle_descricao FROM pc_avaliacao_tiposControles
													INNER JOIN pc_avaliacao_tipoControle on pc_avaliacao_tipoControle.pc_aval_tipoControle_id = pc_avaliacao_tiposControles.pc_aval_tipoControle_id
													WHERE pc_avaliacao_tiposControles.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset tiposControlesList=ValueList(rsTiposControles.pc_aval_tipoControle_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsCategoriasControles">
													SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_categoriasControles
													INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_categoriasControles.pc_aval_categoriaControle_id
													WHERE pc_avaliacao_categoriasControles.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset categoriasControlesList=ValueList(rsCategoriasControles.pc_aval_categoriaControle_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsRiscos">
													SELECT pc_aval_risco_descricao FROM pc_avaliacao_riscos
													INNER JOIN pc_avaliacao_risco on pc_avaliacao_risco.pc_aval_risco_id = pc_avaliacao_riscos.pc_aval_risco_id
													WHERE pc_avaliacao_riscos.pc_aval_id = '#pc_aval_id#'
												</cfquery>
												<cfset riscosList=ValueList(rsRiscos.pc_aval_risco_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsObjetivosEstrategicos">
													SELECT pc_objEstrategico_descricao FROM pc_processos_objEstrategicos
													INNER JOIN pc_objetivo_estrategico on pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
													WHERE pc_processos_objEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset objetivosEstrategicosList=ValueList(rsObjetivosEstrategicos.pc_objEstrategico_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsRiscosEstrategicos">
													SELECT pc_riscoEstrategico_descricao FROM pc_processos_riscosEstrategicos
													INNER JOIN pc_risco_estrategico on pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
													WHERE pc_processos_riscosEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset riscosEstrategicosList=ValueList(rsRiscosEstrategicos.pc_riscoEstrategico_descricao,"; ")>

												<cfquery datasource="#application.dsn_processos#" name="rsIndicadoresEstrategicos">
													SELECT pc_indEstrategico_descricao FROM pc_processos_indEstrategicos
													INNER JOIN pc_indicador_estrategico on pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
													WHERE pc_processos_indEstrategicos.pc_processo_id = '#pc_processo_id#'
												</cfquery>
												<cfset indicadoresEstrategicosList=ValueList(rsIndicadoresEstrategicos.pc_indEstrategico_descricao,"; ")>

												<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
													SELECT  pc_avaliadores.* ,  pc_usuarios.pc_usu_nome as avaliadores
													FROM    pc_avaliadores 
															INNER JOIN pc_usuarios ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
															INNER JOIN pc_orgaos ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
													WHERE 	pc_avaliador_id_processo = '#pc_processo_id#'
												</cfquery>	 
											
												<cfset avaliadores = ValueList(rsAvaliadores.avaliadores,'; ')>

												<cfquery datasource="#application.dsn_processos#" name="rsMelhoriaCategoriasControles">
													SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_melhoria_categoriasControles
													INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_melhoria_categoriasControles.pc_aval_categoriaControle_id
													WHERE pc_avaliacao_melhoria_categoriasControles.pc_aval_Melhoria_id = '#pc_aval_melhoria_id#'
												</cfquery>
												<cfset categoriasControlesMelhoriaList=ValueList(rsMelhoriaCategoriasControles.pc_aval_categoriaControle_descricao,"; ")>
												
		
												<cfoutput>					
													<tr style="cursor:pointer;font-size:12px" >
																		
															<td align="center"> #pc_processo_id#</td>
															<td>#pc_status_descricao#</td>
															<td>#dataFimProcesso#</td>
															<td>#seOrgAvaliado#</td>
															<td>#pc_ano_pacin#</td>
															<td>#sei#</td>
															<td>#pc_num_rel_sei#</td>
															<td>#dataInicio#</td>
															<td>#dataFim#</td>
															<td>#siglaOrgOrigem#</td>
															<td>#siglaOrgAvaliado#</td>
															<td>#AvaliacaoDescricao#</td>
															<td>#tipoProcessoN3#</td>
															<td>#ModalidadeDescricao#</td>
															<td>#pc_class_descricao#</td>
															<td>#TipoDemandaDescricao#</td>
															<td>#avaliadores#</td>
															<td>#coordRegional#</td>
															<td>#coordNacional#</td>
															<td>#objetivosEstrategicosList#</td>
															<td>#riscosEstrategicosList#</td>
															<td>#indicadoresEstrategicosList#</td>
															<td >#pc_aval_id#</td>
															<td >#pc_aval_numeracao#</td>
															<td >#pc_aval_descricao#</td>
															<td>#pc_aval_teste#</td>
															<td>#pc_aval_controleTestado#</td>
															<td>#tiposControlesList#</td>
															<td>#categoriasControlesList#</td>
															<td>#pc_aval_sintese#</td>
															<td>#riscosList#</td>
															<td>#pc_aval_cosoComponente#</td>
															<td>#pc_aval_cosoPrincipio#</td>
															<td>#pc_aval_criterioRef_descricao#</td>
															<cfset classifRisco = "">
															<cfif #pc_aval_classificacao# eq 'L'>
																<cfset classifRisco = "Leve">
															</cfif>	
															<cfif #pc_aval_classificacao# eq 'M'>
																<cfset classifRisco = "Mediano">
															</cfif>	
															<cfif #pc_aval_classificacao# eq 'G'>
																<cfset classifRisco = "Grave">
															</cfif>	
															<cfif #pc_aval_classificacao# eq ''>
																<cfset classifRisco = "Não Classificado">
															</cfif>	
															<td>#classifRisco#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoRecuperar, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoRisco, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_valorEstimadoNaoPlanejado, 'local')#</td>
															
															<td>#pc_aval_status_descricao#</td> 
															<td>#pc_aval_melhoria_id#</td>
															<td>#pc_aval_melhoria_descricao#</td>
															<td>#orgaoResp#</td>
															
															<td>#categoriasControlesMelhoriaList#</td>
															<td>#pc_aval_melhoria_beneficioNaoFinanceiro#</td>
															<td>#LSCurrencyFormat(pc_aval_melhoria_beneficioFinanceiro, 'local')#</td>
															<td>#LSCurrencyFormat(pc_aval_melhoria_custoFinanceiro, 'local')#</td>

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
															<td>#statusMelhoria#</td>
															<cfset dataPrev = DateFormat(#pc_aval_melhoria_dataPrev#,'DD-MM-YYYY') >
															<td>#dataPrev#</td>
															<td>#pc_aval_melhoria_sugestao#</td>
															<td>#orgaoRespSug#</td>
															<td>#pc_aval_melhoria_naoAceita_justif#</td>
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
										
									
									</table>
								</cfif>

								
							</div>
							<!-- /.card-body -->
							<div style="float:left;margin-top:10px;margin-bottom:80px;width:500px">
								<canvas id="pieChartMelhorias" style="min-height: 400px; height: 400px; max-height: 400px; max-width: 100%;"></canvas>
							</div>
							
						</div>
						<!-- /.card -->
					</div>
				<!-- /.col -->
				</div>
				<!-- /.row -->
			
			<!--Para charmar o plugin que inclui lengenda dentro do gráfico-->		
			<script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>

			<script language="JavaScript">
				
				var currentDate = new Date()
				var day = currentDate.getDate()
				var month = currentDate.getMonth() + 1
				var year = currentDate.getFullYear()

				var d = day + "-" + month + "-" + year;	
				$(function () {
					// var tabela = $('#tabProcessos').DataTable();
					// // Loop através de todas as colunas
					// tabela.columns().every(function() {
					// 	// Define a propriedade visible como false
					// 	this.visible(false);
					// });
					$('#tabProcessos').DataTable( {
						destroy: true,
						ordering: false,
						stateSave: true,
						scrollY:"150px",
						filter: false,
						scrollX:        true,
						scrollCollapse: true,
						deferRender: true, // Aumentar desempenho para tabelas com muitos registros
						pageLength: 3,
						buttons: [{
								extend: 'excelHtml5',
								text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
								title : 'SNCI_Propostas_Melhoria_' + d,
								className: 'btExcel',
								exportOptions: {
									columns: ':visible',
									format: {
										body: function(data, row, column, node) {
											if (column === $('th:contains("N° do Item")').index()) {
												
												return data.replaceAll('.', ' . ');
											} else {
												return data;
											}
										}
									}
								},
								customize: function(xlsx) {
									var sheet = xlsx.xl.worksheets['sheet1.xml'];
									
									$('row:eq(0) c', sheet).attr('s','50');//centraliza 1° linha (título)
									$('row:eq(0) c', sheet).attr('s','2');//1° linha em negrito
									$('row:eq(1) c', sheet).attr('s','51');//2° linha centralizada
									$('row:eq(1) c', sheet).attr('s','2');//2° linha em negrito
								
									//PARA PERCORRER TODAS AS COLUNAS E APLICAR UM STYLE
									// var twoDecPlacesCols = ['A','B','C','D','E','F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P'];           
									// for ( i=0; i < twoDecPlacesCols.length; i++ ) {
									// 	$('row c[r^='+twoDecPlacesCols[i]+']', sheet).attr( 's', '25' );
									// }
								},
								customizeData: function (data) {
									// Percorre os dados exportados
									for (var i = 0; i < data.body.length; i++) {
									var rowData = data.body[i];
									// Percorre as células da linha
									for (var j = 0; j < rowData.length; j++) {
										var cellData = rowData[j];
										// Verifica se o valor contém "&nbsp;"
										if (cellData.includes('&nbsp;')) {
										// Substitui todas as ocorrências de "&nbsp;" por espaços regulares
										rowData[j] = cellData.replace(/&nbsp;/g, ' ');
										}
									}
									}
								}
							},
							{
								extend: 'colvis',
								text: 'Selecionar Colunas',
								className: 'btSelecionarColuna',
								collectionLayout: 'fixed four-column',
								colvisButton: true,
								
							},
								
							{
								text: '<i class="fas fa-eye" title="Visualizar todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(true);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
							{
								text: '<i class="fas fa-eye-slash" title="Oculta todas as colunas."></i>',
								action: function (e, dt, node, config) {
									$('#modalOverlay').modal('show');
									setTimeout(function() {
										dt.columns().visible(false);
									}, 500);
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});

								}
							},
						],
						drawCallback: function(settings) {//após a tabela se renderizada
							graficoPizza ('pie','tabProcessos','STATUS (PROPOSTAS DE MELHORIA)','Status da Prop. Melhoria','pieChartMelhorias')
						}	
						
					}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');

					
				} );

			
			</script>	
		<cfelse>
			<cfreturn 'N'>
		</cfif>		

	</cffunction>



	



</cfcomponent>