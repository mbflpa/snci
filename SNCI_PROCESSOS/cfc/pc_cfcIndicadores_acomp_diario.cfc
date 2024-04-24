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

	

	<cffunction name="consultaIndicadorPRCI_diario"   access="remote" hint="gera a consulta para página de indicadores - acompanhamento diário">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_Orientacao_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				CASE
					WHEN (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp < <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
					OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp < GETDATE()) 
					THEN 'PENDENTE'	ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus,

				CASE
					WHEN (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp < <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
					OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp < GETDATE()) 
					THEN 'FP' ELSE 'DP'
				END AS Prazo
			FROM (
				SELECT
					pc_aval_posic_id,
					pc_aval_posic_num_orientacao,
					pc_aval_posic_status,
					pc_aval_posic_num_orgaoResp,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				 WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE
				ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (4, 5)
				AND pc_aval_posic_enviado = 1
				AND (
					pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
						SELECT pc_orgaos.pc_org_mcu
						FROM pc_orgaos
						WHERE (
							pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							OR pc_org_mcu_subord_tec IN (
								SELECT pc_orgaos.pc_org_mcu
								FROM pc_orgaos
								WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							)
						)
					)
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>

		<cfquery name="rs_Orientacao_Respondida" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_avaliacao_posicionamentos.pc_aval_posic_datahora) as dataPosicao,
				pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao as orientacao,
				pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				CASE
					WHEN pc_avaliacao_posicionamentos.pc_aval_posic_status IN (3) THEN 'RESPONDIDO'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus,
				CASE
					WHEN pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp < pc_avaliacao_posicionamentos.pc_aval_posic_datahora THEN 'FP'
					ELSE 'DP'
				END AS Prazo
			FROM pc_avaliacao_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON pc_avaliacao_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE pc_avaliacao_posicionamentos.pc_aval_posic_status IN (3)
				AND (pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
						SELECT pc_orgaos.pc_org_mcu
						FROM pc_orgaos
						WHERE (
							pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							OR pc_org_mcu_subord_tec IN (
								SELECT pc_orgaos.pc_org_mcu
								FROM pc_orgaos
								WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							)
						)
					)
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				
				AND pc_avaliacao_posicionamentos.pc_aval_posic_datahora 
				BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_avaliacao_posicionamentos.pc_aval_posic_enviado = 1
		</cfquery>	

		<cfquery name="rs_Orientacao" dbtype="query">
			SELECT * FROM rs_Orientacao_agora
			UNION
			SELECT * FROM rs_Orientacao_Respondida
		</cfquery>

		<cfreturn #rs_Orientacao#>

	</cffunction>

	<cffunction name="tabPRCIDetalhe_diario" access="remote" hint="acompanhamento diário">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorPRCI_diario(ano=arguments.ano, mes=arguments.mes)>

		<style>
			.dataTables_wrapper {
				width: 100%; /* ou a largura desejada */
				margin: 0 auto;
			}
		</style>
	
		<cfif #resultado.recordcount# neq 0 >	
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
														
								<cfoutput><h5 style="color:##0083ca;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>PRCI</strong> (Atendimento ao Prazo de Resposta): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
								<div class="table-responsive">
									<table id="tabPRCIdetalhe" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
										
										<thead class="bg-gradient-warning">
											<tr style="font-size:14px">
												<th style="width: 10px">Posic ID</th>
												<th style="width: 10px">Órgão Avaliado</th>
												<th style="width: 10px">Órgão Responsável</th>
												<th style="width: 10px">Processo SNCI</th>
												<th style="width: 10px">Item</th>
												<th style="width: 10px">Orientação</th>
												<th style="width: 10px">Data Prevista</th>
												<th style="width: 10px">Data Status</th>
												<th style="width: 10px">Status</th>
												<th style="width: 10px">Data Ref.</th>
												<th style="width: 10px">Prazo</th>

											</tr>
										</thead>
										
										<tbody>
											<cfloop query="resultado" >
											    											
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultado.pc_aval_posic_id#</td>
														<td>#resultado.orgaoAvaliado#</td>
														<td>#resultado.orgaoResp#</td>
														<td>#resultado.numProcessoSNCI#</td>
														<td >#resultado.item#</td>
														<td>#resultado.orientacao#</td>
														<cfif resultado.dataPrevista eq '1900-01-01' or resultado.dataPrevista eq ''>
															<td>NÃO INF.</td>
														<cfelse>
															<td>#dateFormat(resultado.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>
															
															<cfif orgaoDaAcaoEdoControleInterno eq 'N' AND (resultado.pc_aval_posic_status eq 4 OR resultado.pc_aval_posic_status eq 5)>
																#dateFormat(resultado.dataPosicao, 'dd/mm/yyyy')#<br><span style="color:red">(dt. distrib.)</span>
															<cfelse>
																#dateFormat(resultado.dataPosicao, 'dd/mm/yyyy')#
															</cfif>
														</td>


														<td>#resultado.OrientacaoStatus#</td>
														<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
														<td>#dateFormat(dataFinal, 'dd/mm/yyyy')#</td>
														<td>#resultado.Prazo#</td>
															
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>

									</table>
								</div>

								





								
							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
        </cfif>

		<script language="JavaScript">
		   // Define a função para aplicar o estilo apenas nas células com a classe 'tdResult'
			function aplicarEstiloNasTDsComClasseTdResult() {
				// Para cada célula com a classe 'tdResult' na tabela
				$('.tdResult').each(function() {
					updateTDresultIndicadores($(this));
				});
			}
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_PRCI_detalhamento_";
				var colunasMostrar = [1,2,8,10];


				const tabPRCIdetalhamento = $('#tabPRCIdetalhe').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					dom:   "<'row'<'col-sm-4'B><'col-sm-4'p><'col-sm-4 text-right'i>>" ,

							
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]
					

				})
 
				


			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				
				
			});
		</script>

	</cffunction>

	<cffunction name="consultaIndicadorSLNC_diario"   access="remote" hint="gera a consulta para página de indicadores - acompanhamento diário">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_solucionados_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status as status,
				pc_orientacao_status.pc_orientacao_status_descricao AS OrientacaoStatus

			FROM (
				SELECT
					pc_aval_posic_id,
					pc_aval_posic_num_orientacao,
					pc_aval_posic_status,
					pc_aval_posic_num_orgaoResp,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			LEFT JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE
				ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (6)
				AND pc_aval_posic_enviado = 1
				AND (pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
						SELECT pc_orgaos.pc_org_mcu
						FROM pc_orgaos
						WHERE (
							pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							OR pc_org_mcu_subord_tec IN (
								SELECT pc_orgaos.pc_org_mcu
								FROM pc_orgaos
								WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							)
						)
					)
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora
				BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>


		<cfquery name="rs_tratamento_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status as status,
				CASE
					WHEN ((<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp < <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
					OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp < GETDATE()))  AND pc_aval_posic_status = 5 THEN 'PENDENTE'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus

			FROM (
				SELECT
					pc_aval_posic_id,
					pc_aval_posic_num_orientacao,
					pc_aval_posic_status,
					pc_aval_posic_num_orgaoResp,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE
				ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (5)
				AND pc_aval_posic_enviado = 1
				AND (
					pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
						SELECT pc_orgaos.pc_org_mcu
						FROM pc_orgaos
						WHERE (
							pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							OR pc_org_mcu_subord_tec IN (
								SELECT pc_orgaos.pc_org_mcu
								FROM pc_orgaos
								WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							)
						)
					)
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
		</cfquery>

		<cfquery name="rs_solucionados_tratamento_agora" dbtype="query">
			SELECT * FROM rs_solucionados_agora
			UNION
			SELECT * FROM rs_tratamento_agora
		</cfquery>
		
		<cfreturn #rs_solucionados_tratamento_agora#>

	</cffunction>

	<cffunction name="tabSLNCDetalhe_diario" access="remote" hint="acompanhamento diário">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultadoSLNC = consultaIndicadorSLNC_diario(ano=arguments.ano, mes=arguments.mes)>

			
		<cfif #resultadoSLNC.recordcount# neq 0 >
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							
								<cfoutput><h5 style="color:##0083ca; margin-bottom: 20px;margin-bottom: 20px;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>SLNC</strong> (Solução de Não Conformidades): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
								<div class="table-responsive">
									<table id="tabSLNCdetalhe" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
										
										<thead class="bg-gradient-warning">
											<tr style="font-size:14px">
												<th style="width: 10px">Posic ID</th>
												<th style="width: 10px">Órgão Avaliado</th>
												<th style="width: 10px">Órgão Responsável</th>
												<th style="width: 10px">Processo SNCI</th>
												<th style="width: 10px">Item</th>
												<th style="width: 10px">Orientação</th>
												<th style="width: 10px">Data Prevista</th>
												<th style="width: 10px">Data Status</th>
												<th style="width: 10px">Status</th>
												<th style="width: 10px">Data Ref.</th>
											</tr>
										</thead>
										
										<tbody>
											<cfloop query="resultadoSLNC" >
												<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
													SELECT pc_indMeta_meta FROM pc_indicadores_meta 
													WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_numIndicador = 2
															AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
												</cfquery>
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultadoSLNC.pc_aval_posic_id#</td>
														<td>#resultadoSLNC.orgaoAvaliado#</td>
														<td>#resultadoSLNC.orgaoResp#</td>
														<td>#resultadoSLNC.numProcessoSNCI#</td>
														<td >#resultadoSLNC.item#</td>
														<td>#resultadoSLNC.orientacao#</td>
														<cfif resultadoSLNC.dataPrevista eq '1900-01-01' or resultadoSLNC.dataPrevista eq ''>
															<td>---</td>
														<cfelse>
															<td>#dateFormat(resultadoSLNC.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>#dateFormat(resultadoSLNC.dataPosicao, 'dd/mm/yyyy')#</td>
														<td>#resultadoSLNC.OrientacaoStatus#</td>
														<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
														<td>#dateFormat(dataFinal, 'dd/mm/yyyy')#</td>
														
															
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
									

									</table>
								</div>

							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
		</cfif>
		<script language="JavaScript">
		   
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_SLNC_detalhamento_";
				var colunasMostrar = [1,2,8,10];


				const tabSLNCdetalhamento = $('#tabSLNCdetalhe').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					lengthMenu: [
						[5, 10, 25, 50, -1],
						[5, 10, 25, 50, 'Todos']
					],
					dom:   "<'row'<'col-sm-4'B><'col-sm-4'p><'col-sm-4 text-right'i>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]

				})
 
			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				
			});
		</script>

	</cffunction>

	<cffunction name="resultadoDGCI_diario" access="remote" hint="acompanhamento diário">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

		<cfset var resultadoPRCI = consultaIndicadorPRCI_diario(ano=arguments.ano, mes=arguments.mes)>
    	<cfset var resultadoSLNC = consultaIndicadorSLNC_diario(ano=arguments.ano, mes=arguments.mes)>

		


		<cfset totalDPPRCI = 0 /> 
		<cfset totalFPPRCI = 0 /> 
		<cfset orgaosPRCI = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset dpsPRCI = {}> <!-- Define a variável dps como um objeto vazio -->
		<cfset fpsPRCI = {}> <!-- Define a variável fps como um objeto vazio -->

		<cfloop query="resultadoPRCI"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset totalDPPRCI++> <!-- Se a condição for verdadeira, incrementa a variável totalDP em 1 -->
			</cfif>
		</cfloop>

		<cfset totalGeral = resultadoPRCI.recordcount />
		<!--- Calcula a porcentagem --->
		<cfif totalGeral eq 0>
			<cfset percentualDP = 0>
		<cfelse>
			<cfset percentualDP = (totalDPPRCI / totalGeral) * 100 />
		</cfif>
	 	
		


		<cfset totalSolucionadoSLNC = 0 /> 
		<cfset orgaosSLNC = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset solucionadosSLNC = {}> <!-- Define a variável solucionados como um objeto vazio -->
		
		<cfloop query="resultadoSLNC"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			<cfif status eq 6> 
				<cfset totalSolucionadoSLNC++> 
			</cfif>
		</cfloop>
        <cfoutput>
			<cfset totalGeral = resultadoSLNC.recordcount />
			<cfif totalGeral eq 0>
				<cfset percentualSolucionado = 0>			
			<cfelse>				
				<cfset percentualSolucionado = (totalSolucionadoSLNC / totalGeral *100) />
			</cfif>
			<cfset percentualSolucionadoFormatado = ROUND(percentualSolucionado*10)/10 />

			

			<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#"   >
				SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
					WHERE pc_indPeso_numIndicador = 1 
					and pc_indPeso_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
					and pc_indPeso_ativo = 1
			</cfquery>

			<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#"   >
				SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
					WHERE pc_indPeso_numIndicador = 2 
					and pc_indPeso_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
					and pc_indPeso_ativo = 1
			</cfquery>

			<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
				SELECT pc_indMeta_meta FROM pc_indicadores_meta 
				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 1
						AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			</cfquery>
			<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
				SELECT pc_indMeta_meta  FROM pc_indicadores_meta 
				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 2
						AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			</cfquery>

			<cfif rsMetaPRCI.pc_indMeta_meta neq "">
				<cfset metaPRCIorgao= ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10 />
			</cfif>
			
			<cfif rsMetaSLNC.pc_indMeta_meta neq "">
				<cfset metaSLNCorgao= ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10 />
			</cfif>
            
			<cfif rsMetaPRCI.pc_indMeta_meta neq "" and rsMetaSLNC.pc_indMeta_meta neq "">			
				<cfset metaDGCI = ROUND((metaPRCIorgao * rsPRCIpeso.pc_indPeso_peso) + (metaSLNCorgao * rsSLNCpeso.pc_indPeso_peso)*10)/10 />
				<cfset metaDGCIformatado = Replace(metaDGCI,".",",")  />
			<cfelseif rsMetaPRCI.pc_indMeta_meta eq "" and rsMetaSLNC.pc_indMeta_meta neq "">
				<cfset metaDGCI = ROUND((metaSLNCorgao)*10)/10 />
				<cfset metaDGCIformatado = Replace(metaDGCI,".",",")  />
			<cfelseif rsMetaPRCI.pc_indMeta_meta neq "" and rsMetaSLNC.pc_indMeta_meta eq "">
				<cfset metaDGCI = ROUND((metaPRCIorgao)*10)/10 />
				<cfset metaDGCIformatado = Replace(metaDGCI,".",",")  />
			<cfelse>
				<cfset metaDGCI = "" />
				<cfset metaDGCIformatado = "" />
			</cfif>

			



            <cfset percentualDGCI = ROUND((percentualDP * rsPRCIpeso.pc_indPeso_peso) + (percentualSolucionadoFormatado * rsSLNCpeso.pc_indPeso_peso )*10)/10 />
			<cfset percentualDGCIformatado = Replace(NumberFormat(percentualDGCI,0.0),".",",")  />
			<cfif metaDGCI eq 0>
				<cfset DGCIresultadoMeta = ROUND(0*10)/10 />
			<cfelseif metaDGCI eq ''>
				<cfset DGCIresultadoMeta = '' />	
			<cfelse>
				<cfset DGCIresultadoMeta = ROUND((percentualDGCI/metaDGCI)*100*10)/10 />
			</cfif>

			<cfset DGCIresultadoMetaFormatado = Replace(NumberFormat(DGCIresultadoMeta,0.0),".",",") />
	
			<div align="center" class="col-md-12 col-sm-12 col-12 mx-auto" style="margin-bottom:10px">
				<span class="info-box-text" style="font-size:30px">#monthAsString(arguments.mes)#/#arguments.ano#</span>
			</div>	

			<div class="row" style="width: 100%;">	
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body shadow" style="border: 2px solid ##34a2b7">
							<cfif #resultadoPRCI.recordcount# eq 0  and #resultadoSLNC.recordcount# eq 0>
								<h5 align="center">Nenhuma informação foi localizada para o cálculo do DGCI do órgão <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput>.</h5>
							<cfelse>
								<h5 style="text-align: center; margin-bottom:20px">RESULTADO GERAL DO ÓRGÃO <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput></h5>
								<div id="divResultadoDGCI" class="col-md-5 col-sm-5 col-12 mx-auto">
									<!--- Cria um card com o resultado do indicador --->
									<cfset 	infoRodape = '<span style="font-size:14px">DGCI = #percentualDGCIformatado#% (PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span><br>
											        	<span style="font-size:14px">Meta = #metaDGCIformatado#%  (Meta PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (Meta SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span><br>'>			
									<cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
									<cfset var criarCardIndicadorDGCI = objetoCFC.criarCardIndicador(
										tipoDeCard = 'bg-info',
										siglaIndicador ='DGCI',
										percentualIndicadorFormatado = percentualDGCIformatado,
										resultadoEmRelacaoMeta = DGCIresultadoMeta,
										resultadoEmRelacaoMetaFormatado = DGCIresultadoMetaFormatado,
										infoRodape = infoRodape,
										icone = 'fa fa-chart-line',
										descricaoIndicador = 'Desempenho Geral do Controle Interno'
									)>
									<cfoutput>#criarCardIndicadorDGCI#</cfoutput>
									<!--- Fim do card --->								
								</div>	
								<div class="col-12">
									
									<div class="row " style="display: flex; justify-content: center;margin-top:-5px;margin-bottom:5px">
										<i class="fa-solid fa-angles-up" style="font-size:30px;"></i>
									</div>

									<div class="row " style="display: flex; justify-content: center;">
										
										<div id="divResultadoPRCI" class="col-md-5 col-sm-5 col-12 "></div>
										<div id="divResultadoSLNC" class="col-md-5 col-sm-5 col-12 "></div>
									</div>
								</div>
							</cfif>
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
				<!-- /.col -->
			</div>

			<div id ="divResultadosRow" class="row" style="width: 100%;">	
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body" >
							<h5 style="text-align: center; margin-bottom:20px">RESULTADO POR ORGÃOS</h5>
							<div id ="divResultados" class="col-12">
								<div id="divTabResumoIndicadores" >
									<div id="divTabDGCIorgaos" class="row" style="display: flex; justify-content: center;">
										<div style="width: 500px; margin: 0 auto;">
											<table id="tabDGCIorgaos" class="table table-bordered table-striped text-nowrap" style="width:100%; cursor:pointer">
												<thead style="background: ##17a2b8; color: ##fff; text-align: center; ">
													<tr style="font-size:14px;">
														<th colspan="6" style="padding:5px">DGCI - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
													</tr>
													<tr style="font-size:14px">
														<th style="font-weight: normal!important">Órgão</th>
														<th class="bg-gradient-warning" style="font-weight: normal!important">PRCI</th>
														<th class="bg-gradient-warning" style="font-weight: normal!important">SLNC</th>
														<th >DGCI</th>
														<th >Meta</th>
														<th>Resultado</th>

													</tr>
												</thead>
												
												<tbody id="theadTableBody">
													<!-- Aqui serão inseridas as linhas da tabela via jQuery -->
												</tbody>
											</table>
										</div>
									</div>
									
									<div class="row " style="display: flex; justify-content: center;margin-top:10px;margin-bottom:5px">
										<i class="fa-solid fa-angles-up" style="font-size:30px;"></i>
									</div>
									<div class="row " style="display: flex; justify-content: center;">
										<div id="divTabPRCIorgaos" class="row" class="col-md-6 col-sm-6 col-12 " style="margin-right: 300px;"></div>
										<div id="divTabSLNCorgaos" class="row" class="col-md-6 col-sm-6 col-12 "></div>
									</div>
								</div>
							</div>
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
				<!-- /.col -->
			</div>

		</cfoutput>

		
		
		<script language="JavaScript">
			$(document).ready(function(){
				
				$(".content-wrapper").css("height", "auto");
				var divResultPRCI = $("#divResultPRCI");
				var divResultadoPRCI = $("#divResultadoPRCI");
				divResultadoPRCI.html(divResultPRCI.html());

				var divResultSLNC = $("#divResultSLNC");
				var divResultadoSLNC = $("#divResultadoSLNC");
				divResultadoSLNC.html(divResultSLNC.html());


				var divResumoPRCI = $("#divTabResumoPRCI");
				var divTabPRCIorgaos = $("#divTabPRCIorgaos");
				divTabPRCIorgaos.html(divResumoPRCI.html());
				
				var divResumoSLNC = $("#divTabResumoSLNC");
				var divTabSLNCorgaos = $("#divTabSLNCorgaos");
				divTabSLNCorgaos.html(divResumoSLNC.html());
				
				divResultPRCI.html("")
				divResultSLNC.html("")
				divResumoPRCI.html("")
				divResumoSLNC.html("")

				// Função para calcular o DGCI
				function calcularDGCI() {
					// Selecionar todas as linhas da tabela tabResumoPRCI
					var prciRows = $('#tabResumoPRCI tbody tr');
					// Selecionar todas as linhas da tabela tabResumoSLNC
					var slncRows = $('#tabResumoSLNC tbody tr');
					// Selecionar a thead da tabela tabDGCIorgaos
					var theadTable = $('#theadTableBody');
					var hasData = false; // Definir hasData como falso por padrão

					theadTable.empty(); // Limpar os dados da tabela tabDGCIorgaos antes de preencher

					var allOrgaos = {}; // Objeto para armazenar dados de todos os órgãos

					// Preencher allOrgaos com dados da tabela tabResumoPRCI
					prciRows.each(function() {
						var orgao = $(this).find('td:first').text().trim(); // Nome do órgão
						var prci = parseFloat($(this).find('td:eq(3)').text().replace('%', '').replace(',', '.').trim()); // Valor do PRCI
						var metaPRCI = parseFloat($(this).find('td:eq(4)').text().replace('%', '').replace(',', '.').trim()); // Valor da meta do PRCI
						allOrgaos[orgao] = { 'PRCI': prci, 'MetaPRCI': metaPRCI }; // Adicionar PRCI e meta do PRCI ao órgão
					});

					// Preencher allOrgaos com dados da tabela tabResumoSLNC
					slncRows.each(function() {
						var orgao = $(this).find('td:first').text().trim(); // Nome do órgão
						var slnc = parseFloat($(this).find('td:eq(3)').text().replace('%', '').replace(',', '.').trim()); // Valor do SLNC
						var metaSLNC = parseFloat($(this).find('td:eq(4)').text().replace('%', '').replace(',', '.').trim()); // Valor da meta do SLNC
						// Verificar se o órgão já existe em allOrgaos
						if (allOrgaos[orgao]) {
							allOrgaos[orgao]['SLNC'] = slnc; // Adicionar SLNC ao órgão existente
							allOrgaos[orgao]['MetaSLNC'] = metaSLNC; // Adicionar meta do SLNC ao órgão existente
						} else {
							allOrgaos[orgao] = { 'SLNC': slnc, 'MetaSLNC': metaSLNC }; // Adicionar SLNC e meta do SLNC ao órgão
						}
						
					});

					// Preencher a terceira tabela com os dados calculados
					<cfoutput>
						let pesoPRCI = #rsPRCIpeso.pc_indPeso_peso#;
						let pesoSLNC = #rsSLNCpeso.pc_indPeso_peso#
					</cfoutput>
					$.each(allOrgaos, function(orgao, data) {
						var prci = data['PRCI'] ; 
						var slnc = data['SLNC'] ; 
						var metaPRCI = data['MetaPRCI'] ;
						var metaSLNC = data['MetaSLNC'] ;
						
						if(isNaN(prci) && isNaN(slnc)){
							var dgci ="sem dados";
							var prci = "sem dados";
							var slnc = "sem dados";
													
						} 

						if(isNaN(prci) && !isNaN(slnc)){
							var slnc = slnc
							var prci = "sem dados";
							var dgci = slnc;
							
						}
						if(!isNaN(prci) && isNaN(slnc)){
							var slnc = "sem dados";
							var dgci = prci;
						}	
						if(!isNaN(prci) && !isNaN(slnc)){
							var dgci = (prci * pesoPRCI) + (slnc * pesoSLNC); // Calcular o DGCI
						}

						if(isNaN(metaPRCI) && isNaN(metaSLNC)){
							var dgci = "sem meta";
							var resutadoDGCI = "sem meta";
						}
						if(isNaN(metaPRCI) && !isNaN(metaSLNC)){
							var metaDGCI = metaSLNC;
							var resutadoDGCI = (slnc/metaSLNC)*100;
						}
						if(!isNaN(metaPRCI) && isNaN(metaSLNC)){
							var metaDGCI = metaPRCI;
							var resutadoDGCI = (prci/metaPRCI)*100;
						}
						if(!isNaN(metaPRCI) && !isNaN(metaSLNC)){
							var metaDGCI = (metaPRCI * pesoPRCI) + (metaSLNC * pesoSLNC); // Calcular a meta do DGCI
							var resutadoDGCI = (dgci/metaDGCI)*100; // Calcular o resultado do DGCI
						}

						var formatNumber = function(number) {
							// Verifica se o número é um número válido
							if (!isNaN(number)) {
								// Formata o número com uma casa decimal e substitui o ponto por vírgula
								return parseFloat(number).toFixed(1).replace('.', ',');
							} else {
								// Se não for um número válido, retorna o valor original
								return number;
							}
						};

						var formatPercentage = function(number) {
							// Verifica se o número é um número válido
							if (!isNaN(number)) {
								// Formata o número com uma casa decimal e substitui o ponto por vírgula
								return formatNumber(number) + '%';
							} else {
								// Se não for um número válido, retorna uma string vazia
								return number;
							}
						};

						var newRow = '<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;">' +
							'<td>' + orgao + '</td>' +
							'<td>' + formatPercentage(prci) + '</td>' +
							'<td>' + formatPercentage(slnc) + '</td>' +
							'<td><strong>' + formatPercentage(dgci) + '</strong></td>' +
							'<td>' + formatPercentage(metaDGCI) + '</td>' +
							//inserir <td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
							'<td ><span class="tdResult statusOrientacoes" data-value="' + formatPercentage(resutadoDGCI) + '"></span></td>' +
							'</tr>';

						theadTable.append(newRow); // Adicionar nova linha à tabela tabDGCIorgaos
						hasData = true; // Atualizar hasData para verdadeiro se houver dados
					});

					// Classificar as linhas da terceira tabela por DGCI decrescente
					var rows = theadTable.find('tr').get();
					rows.sort(function(a, b) {
						var dgciA = parseFloat($(a).find('td:eq(3)').text()); // DGCI da linha A
						var dgciB = parseFloat($(b).find('td:eq(3)').text()); // DGCI da linha B
						return dgciB - dgciA; // Ordenar de forma decrescente
					});
					$.each(rows, function(index, row) {
						theadTable.append(row); // Adicionar linhas classificadas à tabela tabDGCIorgaos
					});

					// Exibir à tabela tabDGCIorgaos se houver dados, caso contrário, ocultá-la
					if (hasData) {
						$('#divResultadosRow').show();
					} else {
						$('#divResultadosRow').hide();
					}

					$('.ribbon').each(function() {
						updateRibbon($(this));
					});
				}


				calcularDGCI();

				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				const tabDGCIorgaosResumo = $('#tabDGCIorgaos').DataTable({
					destroy: true, // Destruir a tabela antes de recriá-la
					order: [[3, 'desc']], // Define a ordem inicial pela coluna DGCI em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false // Remove o campo de busca
				});	



			});

		   
		</script>
	</cffunction>

	<cffunction name="consultaIndicadorPRCI_diario_paraTbResumo"   access="remote" hint="gera a consulta para página de indicadores - acompanhamento diário para a tabela de resumo com os órgaos responsáveis subordinados ao órgão avaliado.">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_PRCIorgaosResp" datasource="#application.dsn_processos#" timeout="120">
			WITH rs_OrientacaoUniao AS (	
				SELECT
					orgaoResp.pc_org_sigla as orgaoResp,
					orgaoResp.pc_org_mcu as orgaoRespMCU,
					SUM(CASE
						WHEN (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp < <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
						OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp < GETDATE()) 
						THEN 1 ELSE 0
					END) AS FP,
					SUM(CASE
						WHEN (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp >= <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
						OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp >= GETDATE()) 
						THEN 1 ELSE 0
					END) AS DP
				FROM (
					SELECT
						pc_aval_posic_id,
						pc_aval_posic_num_orientacao,
						pc_aval_posic_status,
						pc_aval_posic_num_orgaoResp,
						pc_aval_posic_datahora,
						pc_aval_posic_dataPrevistaResp,
						pc_aval_posic_enviado,
						pc_aval_posic_num_orgao,
						ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
					FROM
						pc_avaliacao_posicionamentos
					WHERE 
						pc_aval_posic_enviado = 1
						AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
		
				) AS ranked_posicionamentos
				INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
				INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
				INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
				INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
				INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
				INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
				INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
				WHERE
					ranked_posicionamentos.row_num = 1
					AND pc_aval_posic_status IN (4, 5)
					AND pc_aval_posic_enviado = 1
					AND (
						pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
						OR pc_aval_posic_num_orgaoResp IN (
							SELECT pc_orgaos.pc_org_mcu
							FROM pc_orgaos
							WHERE (
								pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								OR pc_org_mcu_subord_tec IN (
									SELECT pc_orgaos.pc_org_mcu
									FROM pc_orgaos
									WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								)
							)
						)
						<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
					) 
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				GROUP BY orgaoResp.pc_org_sigla, orgaoResp.pc_org_mcu
		

				UNION 
		
				SELECT
					orgaoResp.pc_org_sigla as orgaoResp,
					orgaoResp.pc_org_mcu as orgaoRespMCU,
					SUM(CASE
						WHEN pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp < pc_avaliacao_posicionamentos.pc_aval_posic_datahora
						THEN 1 ELSE 0
					END) AS FP,
					SUM(CASE
						WHEN pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp >= pc_avaliacao_posicionamentos.pc_aval_posic_datahora
						THEN 1 ELSE 0
					END) AS DP
				FROM pc_avaliacao_posicionamentos
				INNER JOIN pc_orgaos as orgaoResp ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
				INNER JOIN pc_orgaos as orgaoDaAcao ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
				INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
				INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
				INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
				INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
				INNER JOIN pc_orientacao_status ON pc_avaliacao_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
				WHERE pc_avaliacao_posicionamentos.pc_aval_posic_status IN (3)
					AND (pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
						OR pc_aval_posic_num_orgaoResp IN (
							SELECT pc_orgaos.pc_org_mcu
							FROM pc_orgaos
							WHERE (
								pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								OR pc_org_mcu_subord_tec IN (
									SELECT pc_orgaos.pc_org_mcu
									FROM pc_orgaos
									WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								)
							)
						)
						<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
					) 
					
					AND pc_avaliacao_posicionamentos.pc_aval_posic_datahora 
					BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					AND pc_avaliacao_posicionamentos.pc_aval_posic_enviado = 1
					GROUP BY orgaoResp.pc_org_sigla, orgaoResp.pc_org_mcu

			)
			SELECT orgaoResp, orgaoRespMCU, SUM(FP) as totalFP, SUM(DP) as totalDP
			FROM rs_OrientacaoUniao
			GROUP BY orgaoResp, orgaoRespMCU
			ORDER BY orgaoResp
			
		</cfquery>

		<cfreturn #rs_PRCIorgaosResp#>

	</cffunction>

	<cffunction name="consultaIndicadorSLNC_diario_paraTbResumo"   access="remote" hint="gera a consulta para página de indicadores - acompanhamento diário">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>

		<cfquery name="rs_SLNC_orgaosResp" datasource="#application.dsn_processos#" timeout="120">
			WITH slnc_subconsulta AS (	
				SELECT
					orgaoResp.pc_org_sigla as orgaoResp,
					orgaoResp.pc_org_mcu as orgaoRespMCU,
					Count(pc_aval_posic_id) as totalSolucionados,
					0 as totalTratamento
				FROM (
					SELECT
						pc_aval_posic_id,
						pc_aval_posic_num_orientacao,
						pc_aval_posic_status,
						pc_aval_posic_num_orgaoResp,
						pc_aval_posic_datahora,
						pc_aval_posic_dataPrevistaResp,
						pc_aval_posic_enviado,
						pc_aval_posic_num_orgao,
						ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
					FROM
						pc_avaliacao_posicionamentos
					WHERE 
						pc_aval_posic_enviado = 1
						AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">

				) AS ranked_posicionamentos
				LEFT JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
				INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
				INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
				INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
				INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
				INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
				INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
				WHERE
					ranked_posicionamentos.row_num = 1
					AND pc_aval_posic_status IN (6)
					AND pc_aval_posic_enviado = 1
					AND (pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
						OR pc_aval_posic_num_orgaoResp IN (
							SELECT pc_orgaos.pc_org_mcu
							FROM pc_orgaos
							WHERE (
								pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								OR pc_org_mcu_subord_tec IN (
									SELECT pc_orgaos.pc_org_mcu
									FROM pc_orgaos
									WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								)
							)
						)
						<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
					) 
					AND pc_aval_posic_datahora
					BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					GROUP BY orgaoResp.pc_org_sigla, orgaoResp.pc_org_mcu	
				UNION

				SELECT
					orgaoResp.pc_org_sigla as orgaoResp,
					orgaoResp.pc_org_mcu as orgaoRespMCU,
					0 as totalSolucionados,
					Count(pc_aval_posic_id) as totalTratamento
				FROM (
					SELECT
						pc_aval_posic_id,
						pc_aval_posic_num_orientacao,
						pc_aval_posic_status,
						pc_aval_posic_num_orgaoResp,
						pc_aval_posic_datahora,
						pc_aval_posic_dataPrevistaResp,
						pc_aval_posic_enviado,
						pc_aval_posic_num_orgao,
						ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
					FROM
						pc_avaliacao_posicionamentos
					WHERE 
						pc_aval_posic_enviado = 1
						AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">

				) AS ranked_posicionamentos
				INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
				INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
				INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
				INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
				INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
				INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
				INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
				WHERE
					ranked_posicionamentos.row_num = 1
					AND pc_aval_posic_status IN (5)
					AND pc_aval_posic_enviado = 1
					AND (
						pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
						OR pc_aval_posic_num_orgaoResp IN (
							SELECT pc_orgaos.pc_org_mcu
							FROM pc_orgaos
							WHERE (
								pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								OR pc_org_mcu_subord_tec IN (
									SELECT pc_orgaos.pc_org_mcu
									FROM pc_orgaos
									WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
								)
							)
						)
						<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
					) 
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				GROUP BY orgaoResp.pc_org_sigla, orgaoResp.pc_org_mcu
			)
			SELECT
				orgaoResp,
				orgaoRespMCU,
				SUM(totalSolucionados) as totalSolucionados,
				SUM(totalTratamento) as totalTratamento
			FROM
				slnc_subconsulta
			GROUP BY orgaoResp, orgaoRespMCU
					
		</cfquery>
		
		<cfreturn #rs_SLNC_orgaosResp#>

	</cffunction>

	<cffunction name="tabResumoPRCIorgaosResp_AcompDiario" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do PRCI dos órgãos subordinadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorPRCI_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>
       
		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
			<div id="divTabResumoPRCIorgaos" class="table-responsive">
				<table id="tabResumoPRCIorgaos" class="table table-bordered table-striped text-nowrap " style="width:350px; cursor:pointer">
					<cfoutput>
						
						<thead class="bg-gradient-warning" style="text-align: center;">
							<tr style="font-size:14px">
								<th colspan="6" style="padding:5px">PRCI - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
							</tr>
							<tr style="font-size:14px">
								<th >Órgão</th>
								<th >TIDP</th>
								<th >TGI</th>
								<th >PRCI</th>
								<th >Meta</th>
								<th >Resultado</th>
							</tr>
						</thead>
						<tbody>
							
							<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->

								<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
									SELECT pc_indMeta_meta FROM pc_indicadores_meta 
									WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
											AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
											AND pc_indMeta_numIndicador = 1
											AND pc_indMeta_mcuOrgao = '#orgaoRespMCU#'
								</cfquery>
								
								<!--- Adiciona cada linha à tabela --->
								<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
									<td>#orgaoResp# (#orgaoRespMCU#)</td>
									<td>#totalDP#</td>
									<td>#(totalDP + totalFP)#</td>
									<cfset percentualDP = NumberFormat(Round((totalDP / (totalDP + totalFP)) * 100*10)/10,0.0)>
									<td><strong>#percentualDP#%</strong></td>
									<cfset metaPRCIorgao = 0>
									<cfif rsMetaPRCI.pc_indMeta_meta neq ''>
										<cfset metaPRCIorgao = NumberFormat(ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10,0.0)>
									</cfif>
									<cfif rsMetaPRCI.pc_indMeta_meta eq ''>
										<td>sem meta</td>
									<cfelse>	
										<td><strong>#metaPRCIorgao#%</strong></td>
									</cfif>
									<cfset resultMesEmRelacaoMeta = ROUND((ROUND(percentualDP*10)/10 / metaPRCIorgao)*100*10)/10>
									<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>

								</tr>
							</cfloop>
						</tbody>
						<tfoot >
							<tr>
								<th colspan="6" style="font-weight: normal; font-size: smaller;">
									<li>TIDP = Total de orientações dentro do prazo (status “Não respondido” e “Tratamento”); </li>
									<li>TGI  = Total Geral de orientações (status "Respondido", “Não Respondido”, “Tratamento” e “Pendente”); </li>
									<li>PRCI = Atendimento ao Prazo de Resposta = (TIDP/TGI)x100.</li>
									Obs.: Se uma determinada gerência não estiver representada na tabela, isso indica que não houve orientações com o status necessário para a computação do indicador em questão.
								</th>
							</tr>
						</tfoot>
					</cfoutput>
				</table>
			</div>
									


		</cfif>
		<script language="JavaScript">

		    // Define a função para aplicar o estilo apenas nas células com a classe 'tdResult'
			function aplicarEstiloNasTDsComClasseTdResult() {
				// Para cada célula com a classe 'tdResult' na tabela
				$('.tdResult').each(function() {
					updateTDresultIndicadores($(this));
				});
			}

			// Inicializa a tabela para ser ordenável pelo plugin DataTables
			// Inicializa a tabela para ser ordenável pelo plugin DataTables
			$('#tabResumoPRCIorgaos').DataTable({
				order: [[3, 'desc'], [4, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
				lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
				paging: false, // Remove a paginação
				info: false, // Remove a exibição da quantidade de registros
				searching: false, // Remove o campo de busca
				drawCallback: function (settings) {
					aplicarEstiloNasTDsComClasseTdResult();
				}
			});
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
    

			});
		</script>




	</cffunction>

	<cffunction name="tabResumoSLNCorgaosResp_AcompDiario" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do SLNC dos órgãos subordinadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorSLNC_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>
       
		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
				<div id="divTabResumoSLNCorgaos" class="table-responsive">
					<table id="tabResumoSLNCorgaos" class="table table-bordered table-striped text-nowrap" style="width:350px; cursor:pointer">
						<cfoutput>
							<thead class="bg-gradient-warning" style="text-align: center;">
								<tr style="font-size:14px">
									<th colspan="6" style="padding:5px">SLNC - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
								</tr>
								<tr style="font-size:14px">
									<th>Órgão</th>
									<th>QTSL</th>
									<th>QTNC</th>
									<th>SLNC</th>
									<th>Meta</th>
									<th>Resultado</th>
								</tr>
							</thead>
							<tbody>
								
								<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->	
									<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
										SELECT pc_indMeta_meta FROM pc_indicadores_meta 
										WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_numIndicador = 2
												AND pc_indMeta_mcuOrgao = '#orgaoRespMCU#'
									</cfquery>
									
									<!--- Adiciona cada linha à tabela --->
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#orgaoResp# (#orgaoRespMCU#)</td>
										<td>#totalSolucionados#</td>
										<cfset totalOrientacoes = totalSolucionados + totalTratamento>
										<td>#totalOrientacoes#</td>
										<cfset percentualSolucionado = NumberFormat(Round((totalSolucionados / totalOrientacoes) * 100*10)/10,0.0)>
										<td><strong>#percentualSolucionado#%</strong></td>
										<cfset metaSLNCorgao = 0>
										<cfif rsMetaSLNC.pc_indMeta_meta neq ''>
											<cfset metaSLNCorgao = NumberFormat(ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10,0.0)>
										</cfif>
								
										<cfif rsMetaSLNC.pc_indMeta_meta eq ''>
											<td>sem meta</td>
										<cfelse>	
											<td><strong>#metaSLNCorgao#%</strong></td>
										</cfif>
										<cfset resultMesEmRelacaoMeta = ROUND((ROUND(percentualSolucionado*10)/10 / metaSLNCorgao)*100*10)/10>
										<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
									</tr>

								</cfloop>
								
							</tbody>
							<tfoot >
							   <tr>
								    <th colspan="6" style="font-weight: normal; font-size: smaller;">
										<li>QTSL = Quantidade de orientações Solucionadas (somente com status Solucionado no SNCI);</li>
										<li>QTNC = Quantidade de Orientações Registradas (abrange as orientações nos status Pendente + Tratamento + Solucionado no SNCI);</li>
										<li>SLNC = Solução de Não Conformidades = (QTSL/QTNC)x100.</li>
										Obs.: Se uma determinada gerência não estiver representada na tabela, isso indica que não houve orientações com o status necessário para a computação do indicador em questão.
									</th>
									
								</tr>
							</tfoot>
						</cfoutput>
					</table>
				</div>

		</cfif>
		<script language="JavaScript">

		    // Define a função para aplicar o estilo apenas nas células com a classe 'tdResult'
			function aplicarEstiloNasTDsComClasseTdResult() {
				// Para cada célula com a classe 'tdResult' na tabela
				$('.tdResult').each(function() {
					updateTDresultIndicadores($(this));
				});
			}

			// Inicializa a tabela para ser ordenável pelo plugin DataTables
			// Inicializa a tabela para ser ordenável pelo plugin DataTables
			$('#tabResumoSLNCorgaos').DataTable({
				order: [[3, 'desc'], [4, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
				lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
				paging: false, // Remove a paginação
				info: false, // Remove a exibição da quantidade de registros
				searching: false, // Remove o campo de busca
				drawCallback: function (settings) {
					aplicarEstiloNasTDsComClasseTdResult();
				}
			});
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
    

			});
		</script>




	</cffunction>

	<cffunction name="tabResumoDGCIorgaosResp_AcompDiario" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do DGCI dos órgãos subordinadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset var resultadoPRCI = consultaIndicadorPRCI_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>
    	<cfset var resultadoSLNC = consultaIndicadorSLNC_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>

		<cfquery dbtype="query" name="rs_Orgaos" >
			SELECT orgaoResp, orgaoRespMCU FROM resultadoPRCI
			UNION
			SELECT orgaoResp, orgaoRespMCU FROM resultadoSLNC
		</cfquery>

		<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE  pc_indPeso_numIndicador = 1 
				and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>

		<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE pc_indPeso_numIndicador = 2 
				and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>

		<!-- tabela resumo -->
		<cfif rs_Orgaos.recordCount neq 0>
			<div id="divTabResumoIndicadores" class="table-responsive">
				<div id="divTabDGCIorgaos" class="table table-bordered table-striped text-nowrap" style="width:350px; cursor:pointer">
					<div style="width: 500px; margin: 0 auto;">
						<table id="tabResumoDGCIorgaos" class="table table-bordered table-striped text-nowrap" style="width:100%; cursor:pointer">
							<cfoutput>
								<thead class="bg-gradient-info" style="text-align: center;">
									<tr style="font-size:14px;">
										<th colspan="6" style="padding:5px">DGCI - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
									</tr>
									<tr style="font-size:14px">
									
										<th >Órgão</th>
										<th >PRCI</th>
										<th >SLNC</th>
										<th >DGCI</th>
										<th >Meta</th>
										<th >Resultado</th>
										
									</tr>
								</thead>
								
								<tbody >
									<cfloop query="rs_Orgaos"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->	
										<cfquery name="rsResultadoPRCI" dbtype="query">
											SELECT * FROM resultadoPRCI WHERE orgaoRespMCU = '#orgaoRespMCU#'
										</cfquery>

										<cfquery name="rsResultadoSLNC" dbtype="query">
											SELECT * FROM resultadoSLNC WHERE orgaoRespMCU = '#orgaoRespMCU#'
										</cfquery>

										<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
											SELECT pc_indMeta_meta FROM pc_indicadores_meta 
											WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
													AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
													AND pc_indMeta_numIndicador = 1
													AND pc_indMeta_mcuOrgao = '#orgaoRespMCU#'
										</cfquery>
									
										<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
											SELECT pc_indMeta_meta FROM pc_indicadores_meta 
											WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
													AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
													AND pc_indMeta_numIndicador = 2
													AND pc_indMeta_mcuOrgao = '#orgaoRespMCU#'
										</cfquery>

										
											<!--- Adiciona cada linha à tabela --->
											<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
												<td>#orgaoResp# (#orgaoRespMCU#)</td>
												<cfset percentualPRCI = "sem dados">
												<cfif rsResultadoPRCI.recordcount neq 0>
													<cfset percentualPRCI = NumberFormat(Round((rsResultadoPRCI.totalDP / (rsResultadoPRCI.totalDP + rsResultadoPRCI.totalFP)) * 100*10)/10,0.0)>
													<td><strong>#percentualPRCI#%</strong></td>
												<cfelse>
													<td>sem dados</td>
												</cfif>
												<cfif rsResultadoSLNC.recordcount neq 0>
													<cfset percentualSLNC = NumberFormat(Round((rsResultadoSLNC.totalSolucionados / (rsResultadoSLNC.totalSolucionados + rsResultadoSLNC.totalTratamento)) * 100*10)/10,0.0)>
													<td><strong>#percentualSLNC#%</strong></td>
												<cfelse>
													<td>sem dados</td>
												</cfif>
												<cfset pesoPRCI = 0>
												<cfset pesoSLNC = 0>
												<cfif rsPRCIpeso.recordcount neq 0>
													<cfset pesoPRCI = rsPRCIpeso.pc_indPeso_peso>
												</cfif>
												<cfif rsSLNCpeso.recordcount neq 0>
													<cfset pesoSLNC = rsSLNCpeso.pc_indPeso_peso>
												</cfif>
												<cfset percentualDGCI = 0>
												<cfif rsResultadoPRCI.recordcount neq 0 and rsResultadoSLNC.recordcount neq 0>
													<cfset percentualDGCI = NumberFormat(Round(((percentualPRCI * pesoPRCI) + (percentualSLNC * pesoSLNC))*10)/10,0.0)>
													<td><strong>#percentualDGCI#%</strong></td>
												<cfelseif rsResultadoPRCI.recordcount neq 0 and rsResultadoSLNC.recordcount eq 0>
													<cfset percentualDGCI = percentualPRCI>
													<td><strong>#percentualDGCI#%</strong></td>
												<cfelseif rsResultadoPRCI.recordcount eq 0 and rsResultadoSLNC.recordcount neq 0>
													<cfset percentualDGCI = percentualSLNC>
													<td><strong>#percentualDGCI#%</strong></td>
												<cfelse>
													<td>sem dados</td>
												</cfif>

												<cfset metaPRCIorgao = 0>
												<cfif rsMetaPRCI.pc_indMeta_meta neq ''>
													<cfset metaPRCIorgao = NumberFormat(ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10,0.0)>
												</cfif>
												<cfset metaSLNCorgao = 0>
												<cfif rsMetaSLNC.pc_indMeta_meta neq ''>
													<cfset metaSLNCorgao = NumberFormat(ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10,0.0)>	
												</cfif>
												<cfif rsResultadoPRCI.recordcount neq 0 and rsResultadoSLNC.recordcount neq 0> 
													<cfset metaDGCIorgao = NumberFormat(ROUND(((metaPRCIorgao * pesoPRCI) + (metaSLNCorgao * pesoSLNC))*10)/10,0.0)>
												<cfelseif rsResultadoPRCI.recordcount neq 0 and rsResultadoSLNC.recordcount eq 0>
													<cfset metaDGCIorgao = metaPRCIorgao >
												<cfelseif rsResultadoPRCI.recordcount eq 0 and rsResultadoSLNC.recordcount neq 0>
													<cfset metaDGCIorgao = metaSLNCorgao >
												<cfelse>
													<cfset metaDGCIorgao = NumberFormat(0,0.0) >
												</cfif>
												<td ><strong>#metaDGCIorgao#%</strong></td>
												


												
												<cfif metaDGCIorgao eq 0>
													<cfset resultMesEmRelacaoMeta = 0>
													<td>sem meta</td>
												<cfelse>
													<cfset resultMesEmRelacaoMeta = ROUND((ROUND(percentualDGCI*10)/10 / metaDGCIorgao)*100*10)/10>
													<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
												</cfif>
											</tr>
										
									</cfloop>
								</tbody>
								<tfoot >
								<tr>
										<th colspan="6" style="font-weight: normal; font-size: smaller;">
											<li>DGCI = Desempenho Geral do Controle Interno = (PRCI x peso do PRCI) + (SLNC x peso do SLNC) = (PRCI x #pesoPRCI#) + (SLNC x #pesoSLNC#)</li>
										    <li>Meta = (Meta PRCI x peso do PRCI) + (Meta do SLNC x peso SLNC) = (Meta PRCI x #pesoPRCI#) + (Meta SLNC x #pesoSLNC#)</li>
											Obs.: Caso não existam dados para o PRCI ou SLNC, os cálculos acima serão feitos apenas com os resultados e metas do indicador disponível, sem multiplicação pelo seu peso.
										</th>
										
									</tr>
								</tfoot>
                            </cfoutput>
						</table>
					</div>
				</div>
				
				
			</div>
		</cfif>

		<script language="JavaScript">

		    // Define a função para aplicar o estilo apenas nas células com a classe 'tdResult'
			function aplicarEstiloNasTDsComClasseTdResult() {
				// Para cada célula com a classe 'tdResult' na tabela
				$('.tdResult').each(function() {
					updateTDresultIndicadores($(this));
				});
			}

			// Inicializa a tabela para ser ordenável pelo plugin DataTables
			// Inicializa a tabela para ser ordenável pelo plugin DataTables
			$('#tabResumoDGCIorgaos').DataTable({
				order: [[3, 'desc'], [4, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
				lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
				paging: false, // Remove a paginação
				info: false, // Remove a exibição da quantidade de registros
				searching: false, // Remove o campo de busca
				drawCallback: function (settings) {
					aplicarEstiloNasTDsComClasseTdResult();
				}
			});
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
    

			});
		</script>

	</cffunction>

	<cffunction name="cardPRCI_AcompDiario" access="remote" returntype="string" hint="cria o card com as informações dos resultados do PRCI para acompanhamento diário">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset var resultPRCIdados = consultaIndicadorPRCI_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>

		<cfset totalDP = 0>
		<cfset totalFP = 0>
		<cfset totalGeral = 0>
		<cfset metaPRCIorgao = 0>
		<cfset PRCIresultadoMeta = 0>
		<cfset PRCIresultadoMetaFormatado = 0>
		<cfset mediaPRCI = 0>
		<cfset mediaPRCIformatado = 0>
		<cfset metaPRCIorgaoFormatado = 0>

		<cfset orgaosMCUList = ValueList(resultPRCIdados.orgaoRespMCU)>
		
		<cfif resultPRCIdados.recordcount neq 0>
			<cfquery name="rsMetaPRCIcardDiario" datasource="#application.dsn_processos#" >
				SELECT avg(pc_indMeta_meta) mediaPRCImeta FROM pc_indicadores_meta 

				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 1
						AND pc_indMeta_mcuOrgao in(#orgaosMCUList#)
			</cfquery>
			
			<cfset metaPRCIorgao = rsMetaPRCIcardDiario.mediaPRCImeta>
			<cfif metaPRCIorgao neq ''>
				<cfset metaPRCIorgaoFormatado = Replace(NumberFormat(metaPRCIorgao,0.0), ".", ",")>
			</cfif>
			

		
			<cfquery name="rsmediaPRCIcardDiario" dbtype="query">
					SELECT totalDP / (totalDP + totalFP) as prciOrgao FROM resultPRCIdados
			</cfquery>

			<cfset totalPRCI = 0>
			<cfloop query="rsmediaPRCIcardDiario">
				<cfset totalPRCI = totalPRCI + prciOrgao>
			</cfloop>

			<cfset mediaPRCI = Round((totalPRCI*100 / rsmediaPRCIcardDiario.recordCount)*10)/10>
			<cfset mediaPRCIformatado = Replace(NumberFormat(mediaPRCI,0.0), ".", ",")>

			<cfset PRCIresultadoMeta = ROUND((mediaPRCI / metaPRCIorgao)*100*10)/10>
			<cfset PRCIresultadoMetaFormatado = Replace(NumberFormat(PRCIresultadoMeta,0.0), ".", ",")>

																
			<cfset 	infoRodape = '<span style="font-size:14px">PRCI = #mediaPRCIformatado#% (média do resultado do PRCI dos órgão subordinados)</span><br>
						<span style="font-size:14px">Meta = #metaPRCIorgaoFormatado#% (média das metas do PRCI dos órgãos subordinados)</span><br>'>			
			
			<cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
			<cfset var cardPRCIdiario = objetoCFC.criarCardIndicador(
				tipoDeCard = 'bg-gradient-warning',
				siglaIndicador ='PRCI',
				descricaoIndicador = 'Atendimento ao Prazo de Resposta',
				percentualIndicadorFormatado = mediaPRCIformatado,
				resultadoEmRelacaoMeta = PRCIresultadoMeta,
				resultadoEmRelacaoMetaFormatado = PRCIresultadoMetaFormatado,
				infoRodape = infoRodape,
				icone = 'fa fa-shopping-basket'

			)>

			<cfoutput>#cardPRCIdiario#</cfoutput>
		<cfelse>
			<cfoutput><h5 style="text-align:center">Não há dados disponíveis para o PRCI</h5></cfoutput>
		</cfif>

		<script language="JavaScript">
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				$('.ribbon').each(function() {
					updateRibbon($(this));
				});
			});
			
		</script>
		

	</cffunction>

	<cffunction name="cardSLNC_AcompDiario" access="remote" returntype="string" hint="cria o card com as informações dos resultados do SLNC para acompanhamento diário">
	 				<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset var resultSLNCdados = consultaIndicadorSLNC_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>

		<cfset totalSolucionados = 0>
		<cfset totalTratamento = 0>
		<cfset totalGeral = 0>
		<cfset metaSLNCorgao = 0>
		<cfset SLNCresultadoMeta = 0>
		<cfset SLNCresultadoMetaFormatado = 0>
		<cfset mediaSLNC = 0>
		<cfset mediaSLNCformatado = 0>
		<cfset metaSLNCorgaoFormatado = 0>

		<cfset orgaosMCUList = ValueList(resultSLNCdados.orgaoRespMCU)>
		
		<cfif resultSLNCdados.recordcount neq 0>
			<cfquery name="rsMetaSLNCcardDiario" datasource="#application.dsn_processos#" >
				SELECT avg(pc_indMeta_meta) mediaSLNCmeta FROM pc_indicadores_meta 

				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 2
						AND pc_indMeta_mcuOrgao in(#orgaosMCUList#)
			</cfquery>
			<cfset metaSLNCorgao = rsMetaSLNCcardDiario.mediaSLNCmeta>
			<cfif metaSLNCorgao neq ''>
				<cfset metaSLNCorgaoFormatado = Replace(NumberFormat(metaSLNCorgao,0.0), ".", ",")>
			</cfif>
			

		
			<cfquery name="rsmediaSLNCcardDiario" dbtype="query">
					SELECT totalSolucionados / (totalSolucionados + totalTratamento) as slncOrgao FROM resultSLNCdados
			</cfquery>

			<cfset totalSLNC = 0>
			<cfloop query="rsmediaSLNCcardDiario">
				<cfset totalSLNC = totalSLNC + slncOrgao>	
			</cfloop>	
			<cfset mediaSLNC = Round((totalSLNC*100 / rsmediaSLNCcardDiario.recordCount)*10)/10>
			<cfset mediaSLNCformatado = Replace(NumberFormat(mediaSLNC,0.0), ".", ",")>

			<cfset SLNCresultadoMeta = ROUND((mediaSLNC / metaSLNCorgao)*100*10)/10>
			<cfset SLNCresultadoMetaFormatado = Replace(NumberFormat(SLNCresultadoMeta,0.0), ".", ",")>

			<cfset infoRodape = '<span style="font-size:14px">SLNC = #mediaSLNCformatado#% (média do resultado do SLNC dos órgão subordinados)</span><br>
						<span style="font-size:14px">Meta = #metaSLNCorgaoFormatado#% (média das metas do SLNC dos órgãos subordinados)</span><br>'>
			
            <cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
			<cfset var cardSLNCdiario = objetoCFC.criarCardIndicador(
				tipoDeCard = 'bg-gradient-warning',
				siglaIndicador ='SLNC',
				descricaoIndicador = 'Solução de Não Conformidades',
				percentualIndicadorFormatado = mediaSLNCformatado,
				resultadoEmRelacaoMeta = SLNCresultadoMeta,
				resultadoEmRelacaoMetaFormatado = SLNCresultadoMetaFormatado,
				infoRodape = infoRodape,
				icone = 'fa fa-shopping-basket'

			)>

			<cfoutput>#cardSLNCdiario#</cfoutput>
		<cfelse>
			<cfoutput><h5 style="text-align:center">Não há dados disponíveis para o SLNC</h5></cfoutput>
		</cfif>

		<script language="JavaScript">
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				$('.ribbon').each(function() {
					updateRibbon($(this));
				});
			});
		</script>
	</cffunction>


    <cffunction name="cardDGCI_AcompDiario" access="remote" returntype="string" hint="cria o card com as informações dos resultados do GDCI para acompanhamento diário">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset var resultPRCIdadosParaDGCI = consultaIndicadorPRCI_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>
		<cfset var resultSLNCdadosParaDGCI = consultaIndicadorSLNC_diario_paraTbResumo(ano=arguments.ano, mes=arguments.mes)>
		<cfset orgaosMCUListPRCI = ValueList(resultPRCIdadosParaDGCI.orgaoRespMCU)>
		<cfset orgaosMCUListSLNC = ValueList(resultSLNCdadosParaDGCI.orgaoRespMCU)>


		<cfset totalDP = 0>
		<cfset totalFP = 0>
		<cfset totalGeral = 0>
		<cfset mediaMetaPRCIorgaos = 0>
		<cfset PRCIresultadoMeta = 0>
		<cfset PRCIresultadoMetaFormatado = 0>
		<cfset mediaPRCI = 0>
		<cfset mediaPRCIformatado = 0>
		<cfset mediaMetaPRCIorgaosFormatado = 0>
		<cfset totalSolucionados = 0>
		<cfset totalTratamento = 0>
		<cfset mediaMetaSLNCorgaos = 0>
		<cfset SLNCresultadoMeta = 0>
		<cfset SLNCresultadoMetaFormatado = 0>
		<cfset mediaSLNC = 0>
		<cfset mediaSLNCformatado = 0>
		<cfset mediaMetaSLNCorgaosFormatado = 0>
		<cfset pesoPRCI = 0>
		<cfset pesoSLNC = 0>
		<cfset percentualDGCI = 0>
		<cfset metaDGCIorgao = 0>
		<cfset metaDGCIorgaoFormatado = 0>
		<cfset DGCIresultadoMetaFormatado = 0>
		


		<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE  pc_indPeso_numIndicador = 1 
				and pc_indPeso_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>
		<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE pc_indPeso_numIndicador = 2 
				and pc_indPeso_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>




		<cfif resultPRCIdadosParaDGCI.recordcount neq 0>
			<cfquery name="rsMetaPRCIcardDiario" datasource="#application.dsn_processos#" >
				SELECT avg(pc_indMeta_meta) mediaPRCImeta FROM pc_indicadores_meta 
				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 1
						AND pc_indMeta_mcuOrgao in(#orgaosMCUListPRCI#)
			</cfquery>


			<cfset mediaMetaPRCIorgaos = NumberFormat(round(rsMetaPRCIcardDiario.mediaPRCImeta*10)/10,0.0)>
			<cfif mediaMetaPRCIorgaos neq ''>
				<cfset mediaMetaPRCIorgaosFormatado = Replace(mediaMetaPRCIorgaos, ".", ",")>
			</cfif>
		<cfelse>
			<cfset mediaMetaPRCIorgaosFormatado = 0>
		</cfif>


		<cfif resultSLNCdadosParaDGCI.recordcount neq 0>
			<cfquery name="rsMetaSLNCcardDiario" datasource="#application.dsn_processos#" >
				SELECT avg(pc_indMeta_meta) mediaSLNCmeta FROM pc_indicadores_meta 
				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 2
						AND pc_indMeta_mcuOrgao in(#orgaosMCUListSLNC#)
			</cfquery>
			<cfset mediaMetaSLNCorgaos = NumberFormat(round(rsMetaSLNCcardDiario.mediaSLNCmeta*10)/10,0.0)>
			<cfif mediaMetaSLNCorgaos neq ''>
				<cfset mediaMetaSLNCorgaosFormatado = Replace(mediaMetaSLNCorgaos, ".", ",")>
			</cfif>
		<cfelse>
			<cfset mediaMetaSLNCorgaosFormatado = 0>
		</cfif>
		

		<cfquery name="rsmediaPRCIcardDiario" dbtype="query">
				SELECT totalDP / (totalDP + totalFP) as prciOrgao FROM resultPRCIdadosParaDGCI
		</cfquery>
		<cfset totalPRCI = 0>
		<cfloop query="rsmediaPRCIcardDiario">
			<cfset totalPRCI = totalPRCI + prciOrgao>
		</cfloop>

		<cfif rsmediaPRCIcardDiario.recordcount neq 0>
			<cfset mediaPRCI = Round((totalPRCI*100 / rsmediaPRCIcardDiario.recordCount)*10)/10>
			<cfset mediaPRCIformatado = Replace(NumberFormat(mediaPRCI,0.0), ".", ",")>
		</cfif>

		<cfif mediaMetaPRCIorgaos neq 0>
			<cfset PRCIresultadoMeta = ROUND((mediaPRCI / mediaMetaPRCIorgaos)*100*10)/10>
		</cfif>

		<cfset PRCIresultadoMetaFormatado = Replace(NumberFormat(PRCIresultadoMeta,0.0), ".", ",")>

		<cfquery name="rsmediaSLNCcardDiario" dbtype="query">
				SELECT totalSolucionados / (totalSolucionados + totalTratamento) as slncOrgao FROM resultSLNCdadosParaDGCI
		</cfquery>
		<cfset totalSLNC = 0>
		<cfloop query="rsmediaSLNCcardDiario">
			<cfset totalSLNC = totalSLNC + slncOrgao>
		</cfloop>

		<cfif rsmediaSLNCcardDiario.recordcount neq 0>
			<cfset mediaSLNC = Round((totalSLNC*100 / rsmediaSLNCcardDiario.recordCount)*10)/10>
			<cfset mediaSLNCformatado = Replace(NumberFormat(mediaSLNC,0.0), ".", ",")>
		</cfif>

        <cfif mediaMetaSLNCorgaos neq 0>
			<cfset SLNCresultadoMeta = ROUND((mediaSLNC / mediaMetaSLNCorgaos)*100*10)/10>
		</cfif>
		

		<cfset SLNCresultadoMetaFormatado = Replace(NumberFormat(SLNCresultadoMeta,0.0), ".", ",")>
		<cfset pesoPRCI = 0>
		<cfset pesoSLNC = 0>
		<cfif rsPRCIpeso.recordcount neq 0>
			<cfset pesoPRCI = rsPRCIpeso.pc_indPeso_peso>
			<cfset pesoPRCIformatado = Replace(pesoPRCI, ".", ",")>
		</cfif>
		<cfif rsSLNCpeso.recordcount neq 0>
			<cfset pesoSLNC = rsSLNCpeso.pc_indPeso_peso>
			<cfset pesoSLNCformatado = Replace(pesoSLNC, ".", ",")>
		</cfif>
		<cfset percentualDGCI = ''>
		<cfif rsmediaPRCIcardDiario.recordcount neq 0 and rsmediaSLNCcardDiario.recordcount neq 0>
			<cfset percentualDGCI = NumberFormat(Round(((mediaPRCI * pesoPRCI) + (mediaSLNC * pesoSLNC))*10)/10,0.0)>
		<cfelseif rsmediaPRCIcardDiario.recordcount neq 0 and rsmediaSLNCcardDiario.recordcount eq 0>
			<cfset percentualDGCI = mediaPRCI>
		<cfelseif rsmediaPRCIcardDiario.recordcount eq 0 and rsmediaSLNCcardDiario.recordcount neq 0>
			<cfset percentualDGCI = mediaSLNC>
		<cfelse>
			<cfset percentualDGCI = ''>
		</cfif>

		<cfset percentualDGCIformatado = Replace(percentualDGCI, ".", ",")>

		<cfif mediaMetaPRCIorgaos neq 0 and mediaMetaSLNCorgaos neq 0>
			<cfset metaDGCIorgao = NumberFormat(ROUND(((mediaMetaPRCIorgaos * pesoPRCI) + (mediaMetaSLNCorgaos * pesoSLNC))*10)/10,0.0)>
		<cfelseif mediaMetaPRCIorgaos neq 0 and mediaMetaSLNCorgaos eq 0>
			<cfset metaDGCIorgao = mediaMetaPRCIorgaos >
		<cfelseif mediaMetaPRCIorgaos eq 0 and mediaMetaSLNCorgaos neq 0>
			<cfset metaDGCIorgao = mediaMetaSLNCorgaos >
		<cfelse>
			<cfset metaDGCIorgao = NumberFormat(0,0.0) >
		</cfif>

		<cfif metaDGCIorgao neq ''>
			<cfset metaDGCIorgaoFormatado = Replace(NumberFormat(metaDGCIorgao,0.0), ".", ",")>
		</cfif>

		<cfif metaDGCIorgao neq 0>
			<cfset DGCIresultadoMeta = ROUND((ROUND(percentualDGCI*10)/10 / metaDGCIorgao)*100*10)/10>
			<cfset DGCIresultadoMetaFormatado = Replace(NumberFormat(DGCIresultadoMeta,0.0), ".", ",")>
		</cfif>

		<cfif percentualDGCI neq ''>
			<cfif rsmediaPRCIcardDiario.recordcount neq 0 AND rsmediaSLNCcardDiario.recordcount neq 0>
				<cfset formulaDGCI = '(PRCI  x peso PRCI) + (SLNC x peso SLNC) = (#mediaPRCIformatado# x #pesoPRCIformatado#) + (#mediaSLNCformatado# x #pesoSLNCformatado#)'>
			<cfelseif rsmediaPRCIcardDiario.recordcount neq 0 AND rsmediaSLNCcardDiario.recordcount eq 0>
				<cfset formulaDGCI = '(PRCI) = (#mediaPRCIformatado#)'>
			<cfelseif rsmediaPRCIcardDiario.recordcount eq 0 AND rsmediaSLNCcardDiario.recordcount neq 0>
				<cfset formulaDGCI = '(SLNC) = (#mediaSLNCformatado#)'>
			<cfelse>
				<cfset formulaDGCI = ''>
			</cfif>

						

			<cfset infoRodape = '<span style="font-size:14px">DGCI = #percentualDGCIformatado#% -> #formulaDGCI#</span><br>
						<span style="font-size:14px">Meta = #metaDGCIorgaoFormatado#% -> (Meta PRCI x peso PRCI) + (Meta SLNC x peso SLNC)= (#mediaMetaPRCIorgaosFormatado# x #pesoPRCIformatado#) + (#mediaMetaSLNCorgaosFormatado# x #pesoSLNCformatado#)</span><br>'>
			<cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
			<cfset var cardDGCI = objetoCFC.criarCardIndicador(
				tipoDeCard = 'bg-gradient-info',
				siglaIndicador ='DGCI',
				descricaoIndicador = 'Desempenho Geral do Controle Interno',
				percentualIndicadorFormatado = percentualDGCIformatado,
				resultadoEmRelacaoMeta =  DGCIresultadoMeta,
				resultadoEmRelacaoMetaFormatado = DGCIresultadoMetaFormatado,
				infoRodape = infoRodape

			)>
			<cfoutput>#cardDGCI#</cfoutput>
		<cfelse>
			<cfoutput><h5 style="text-align:center">Não há dados disponíveis para o DGCI</h5></cfoutput>
		</cfif>

		<script language="JavaScript">
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				$('.ribbon').each(function() {
					updateRibbon($(this));
				});
			});
		</script>
	</cffunction>












</cfcomponent>