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

	
	<cffunction name="consultaIndicadorPRCI_TIDP_TGI_mensal" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do PRCI">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfargument name="paraOrgaoSubordinador" type="numeric" required="false" default="0" />


		<cfquery name="consulta_PRCI_TIDP_TGI_mensal" datasource="#application.dsn_processos#" timeout="120">
			SELECT 
				pc_indOrgao_mcuOrgao as mcuOrgao,
				pc_orgaos.pc_org_sigla as siglaOrgao,
				MAX(IIF(pc_indOrgao_numIndicador = 4, pc_indOrgao_resultadoMes, 0)) as TIDP,
				MAX(IIF(pc_indOrgao_numIndicador = 5, pc_indOrgao_resultadoMes, 0)) as TGI,
				MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoMes, NULL)) as PRCI,
				MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoAcumulado, NULL)) as PRCIacumulado
			FROM 
				pc_indicadores_porOrgao
			INNER JOIN 
				pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			WHERE 
				pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador IN(1,4,5)
				AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#arguments.paraOrgaoSubordinador#" cfsqltype="cf_sql_integer">
				<cfif arguments.paraOrgaoSubordinador eq 0>
					AND pc_indOrgao_mcuOrgaoSubordinador = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>

		<cfreturn #consulta_PRCI_TIDP_TGI_mensal#>
      
		

	</cffunction>
	
    <cffunction name="consultaIndicadorSLNC_QTSL_QTNC" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do SLNC">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
        <cfargument name="paraOrgaoSubordinador" type="numeric" required="false" default="0" />


		<cfquery name="consulta_SLNC_QTSL_QTNC_mensal" datasource="#application.dsn_processos#" timeout="120">		
			SELECT 
				 pc_indOrgao_mcuOrgao as mcuOrgao
				,pc_orgaos.pc_org_sigla as siglaOrgao
				,MAX(IIF(pc_indOrgao_numIndicador = 6, pc_indOrgao_resultadoMes, 0)) as QTSL
				,MAX(IIF(pc_indOrgao_numIndicador = 7, pc_indOrgao_resultadoMes, 0)) as QTNC
				,MAX(IIF(pc_indOrgao_numIndicador = 2, pc_indOrgao_resultadoMes, NULL)) as SLNC
				,MAX(IIF(pc_indOrgao_numIndicador = 2, pc_indOrgao_resultadoAcumulado, NULL)) as SLNCacumulado
			FROM 
				pc_indicadores_porOrgao
			INNER JOIN 
				pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			WHERE 
				pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador IN(2,6,7)
				AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#arguments.paraOrgaoSubordinador#" cfsqltype="cf_sql_integer">
				<cfif arguments.paraOrgaoSubordinador eq 0>
					AND pc_indOrgao_mcuOrgaoSubordinador = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>

		<cfreturn #consulta_SLNC_QTSL_QTNC_mensal#>	

	</cffunction>

	<cffunction name="consultaIndicadorDGCI_mensal" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do DGCI">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfargument name="paraOrgaoSubordinador" type="numeric" required="false" default="0" />
		<cfargument name="paraOrgaoResponsavel" type="numeric" required="false" default="0" />

		<cfquery name="consulta_DGCI_mensal" datasource="#application.dsn_processos#" timeout="120">
			SELECT 
				pc_indOrgao_mcuOrgao as mcuOrgao
				,pc_orgaos.pc_org_sigla as siglaOrgao
				,pc_indOrgao_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaoSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoMes, null)) as PRCI
				,MAX(IIF(pc_indOrgao_numIndicador = 2, pc_indOrgao_resultadoMes, null)) as SLNC
				,MAX(IIF(pc_indOrgao_numIndicador = 3, pc_indOrgao_resultadoMes, null)) as DGCI
				,MAX(IIF(pc_indOrgao_numIndicador = 3, pc_indOrgao_resultadoAcumulado, null)) as DGCIacumulado

			FROM 
				pc_indicadores_porOrgao
			INNER JOIN 
				pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			INNER JOIN 
				pc_orgaos pc_orgaoSubordinador ON pc_orgaoSubordinador.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgaoSubordinador	
			WHERE 
				pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador in (1,2,3)
				AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#arguments.paraOrgaoSubordinador#" cfsqltype="cf_sql_integer">
				<cfif arguments.paraOrgaoSubordinador eq 0 and arguments.paraOrgaoResponsavel eq 0>
					AND pc_indOrgao_mcuOrgaoSubordinador = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla,pc_indOrgao_mcuOrgaoSubordinador,pc_orgaoSubordinador.pc_org_sigla
		</cfquery>
		<cfreturn #consulta_DGCI_mensal#>	
	
	</cffunction>


	
	<cffunction name="tabPRCIdetalhe_mensal_CI" access="remote" returntype="string" hint="cria tabela como os dados para o indicador PRCI dos órgãos para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>

		
		<cfquery name="resultadoDetalhe" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indDados_numPosic
				,pc_indDados_mcuOrgaoResp as mcuOrgaoResp
				,pc_orgaos.pc_org_sigla as siglaOrgaoResp
				,pc_indDados_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,pc_indDados_mcuOrgaoAvaliado as mcuOrgaoAvaliado
				,pc_orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
				,pc_indDados_numProcesso as numProcessoSNCI
				,pc_indDados_numItem as item
				,pc_indDados_numOrientacao as orientacao
				,pc_indDados_dataPrevista as dataPrevista
				,pc_indDados_status as numStatus
				,pc_indDados_descricaoStatus as descricaoOrientacaoStatus
				,pc_indDados_dataRef as dataRef
				,pc_indDados_numIndicador as numIndicador
				,CASE 
					WHEN pc_indDados_descricaoStatus = 'PENDENTE' THEN DATEADD(day, 1, pc_indDados_dataPrevista)
					ELSE pc_indDados_dataStatus
				END as dataPosicao
				,pc_indDados_prazo as prazo

			FROM pc_indicadores_dados
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			INNER JOIN pc_orgaos as pc_orgaoAvaliado on pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">

		</cfquery>

		<cfquery name="resultadoPRCIdetalhe"   dbtype="query">
			SELECT * FROM resultadoDetalhe	WHERE numIndicador = 1
		</cfquery>

		<cfif resultadoPRCIdetalhe.recordcount neq 0 >	
			<div id="divDetalhePRCI" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
						
							<div class="table-responsive">
								<table id="tabPRCIdetalhe" class="table table-bordered table-striped text-nowrap" style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead >
									    <tr style="font-size:14px">
											<th colspan="12" style="padding:5px"><h5 style="color:#0083ca;margin-left: 10px">Dados utilizados no cálculo do PRCI: <cfoutput><strong>#monthAsString(mes)#/#ano#</strong></cfoutput></h5></th>
										</tr>
										<tr style="font-size:14px">
											<th style="width: 10px">Posic ID</th>
											<th style="width: 10px">SE/CS</th>
											<th style="width: 10px">Órgão Responsável</th>
											<th style="width: 10px">Processo SNCI</th>
											<th style="width: 10px">Órgão Avaliado</th>
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
										<cfloop query="resultadoPRCIdetalhe" >
										
											<cfoutput>					
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#pc_indDados_numPosic#</td>
													<td>#siglaOrgaoSubordinador# (#mcuOrgaoSubordinador#)</td>
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td>#numProcessoSNCI#</td>
													<td>#siglaOrgaoAvaliado# (#mcuOrgaoAvaliado#)</td>
													<td >#item#</td>
													<td>#orientacao#</td>
													<cfif dataPrevista eq '1900-01-01' or dataPrevista eq ''>
														<td>NÃO INF.</td>
													<cfelse>
														<td>#dateFormat(dataPrevista, 'dd/mm/yyyy')#</td>
													</cfif>
													<td>#dateFormat(dataPosicao, 'dd/mm/yyyy')#</td>
													<td>#descricaoOrientacaoStatus#</td>
													<td>#dateFormat(dataRef, 'dd/mm/yyyy')#</td>
													<td>#prazo#</td>
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
        <cfelse>
			<h5>Não há dados para exibir</h5>
		</cfif>

		<script language="JavaScript">
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel
			var tituloExcel_PRCI ="SNCI_Consulta_PRCI_detalhamento_";
			$('#tabPRCIdetalhe').DataTable( {
				destroy: true, // Destruir a tabela antes de recriá-la
				stateSave: false,
				deferRender: true, // Aumentar desempenho para tabelas com muitos registros
				scrollX: true, // Permitir rolagem horizontal
				autoWidth: true,// Ajustar automaticamente o tamanho das colunas
				pageLength: 5,
				
				dom: "<'row'<'col-sm-3'B><'col-sm-4 text-center' p><'col-sm-4 text-right'i>>" ,
				order: [[1, 'asc'], [2, 'asc']], // Ordena a segunda e a terceira coluna em ordem crescente
				buttons: [
					{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
						title : tituloExcel_PRCI + d,
						className: 'btExcel',
					}

				]
				

			})
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
			});
		</script>
	</cffunction>

    <cffunction name="tabSLNCdetalhe_mensal_CI" access="remote" returntype="string" hint="cria tabela como os dados para o indicador SLNC dos órgãos para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>

		<cfquery name="resultadoDetalhe" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indDados_numPosic
				,pc_indDados_mcuOrgaoResp as mcuOrgaoResp
				,pc_orgaos.pc_org_sigla as siglaOrgaoResp
				,pc_indDados_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,pc_indDados_mcuOrgaoAvaliado as mcuOrgaoAvaliado
				,pc_orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
				,pc_indDados_numProcesso as numProcessoSNCI
				,pc_indDados_numItem as item
				,pc_indDados_numOrientacao as orientacao
				,pc_indDados_dataPrevista as dataPrevista
				,pc_indDados_status as numStatus
				,pc_indDados_descricaoStatus as descricaoOrientacaoStatus
				,pc_indDados_dataRef as dataRef
				,pc_indDados_numIndicador as numIndicador
				,CASE 
					WHEN pc_indDados_descricaoStatus = 'PENDENTE' THEN DATEADD(day, 1, pc_indDados_dataPrevista)
					ELSE pc_indDados_dataStatus
				END as dataPosicao
				,pc_indDados_prazo as prazo

			FROM pc_indicadores_dados
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			INNER JOIN pc_orgaos as pc_orgaoAvaliado on pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">

		</cfquery>

		<cfquery name="resultadoSLNCdetalhe"   dbtype="query">
			SELECT * FROM resultadoDetalhe	WHERE numIndicador = 2
		</cfquery>

		<cfif resultadoSLNCdetalhe.recordcount neq 0 >	
			<div id="divDetalheSLNC" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
														
						
							<div class="table-responsive">
								<table id="tabSLNCdetalhe" class="table table-bordered table-striped text-nowrap" style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead>
										<tr style="font-size:14px">
											<th colspan="12" style="padding:5px"><h5 style="color:#0083ca;margin-left: 10px">Dados utilizados no cálculo do SLNC: <cfoutput><strong>#monthAsString(mes)#/#ano#</strong></cfoutput></h5></th>
										</tr>
										<tr style="font-size:14px">
											<th style="width: 10px">Posic ID</th>
											<th style="width: 10px">SE/CS</th>
											<th style="width: 10px">Órgão Responsável</th>
											<th style="width: 10px">Processo SNCI</th>
											<th style="width: 10px">Órgão Avaliado</th>
											<th style="width: 10px">Item</th>
											<th style="width: 10px">Orientação</th>
											<th style="width: 10px">Data Prevista</th>
											<th style="width: 10px">Data Status</th>
											<th style="width: 10px">Status</th>
											<th style="width: 10px">Data Ref.</th>

										</tr>
									</thead>
									
									<tbody>
										<cfloop query="resultadoSLNCdetalhe" >
										
											<cfoutput>					
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#pc_indDados_numPosic#</td>
													<td>#siglaOrgaoSubordinador# (#mcuOrgaoSubordinador#)</td>
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td>#numProcessoSNCI#</td>
													<td>#siglaOrgaoAvaliado# (#mcuOrgaoAvaliado#)</td>
													<td >#item#</td>
													<td>#orientacao#</td>
													<cfif dataPrevista eq '1900-01-01' or dataPrevista eq ''>
														<td>NÃO INF.</td>
													<cfelse>
														<td>#dateFormat(dataPrevista, 'dd/mm/yyyy')#</td>
													</cfif>
													<td>#dateFormat(dataPosicao, 'dd/mm/yyyy')#</td>

													<td>#descricaoOrientacaoStatus#</td>

													<td>#dateFormat(dataRef, 'dd/mm/yyyy')#</td>
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
        <cfelse>
			<h5>Não há dados para exibir</h5>
		</cfif>

		<script language="JavaScript">

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel
			var tituloExcel_SLNC ="SNCI_Consulta_SLNC_detalhamento_";

				$('#tabSLNCdetalhe').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					
					dom: "<'row'<'col-sm-3'B><'col-sm-4 text-center' p><'col-sm-4 text-right'i>>"  ,
					order: [[1, 'asc'], [2, 'asc']], // Ordena a segunda e a terceira coluna em ordem crescente
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_SLNC + d,
							className: 'btExcel',
						}

					]
					

				})
				$(document).ready(function() {
					$(".content-wrapper").css("height", "auto");
				});
		</script>

	</cffunction>

	<cffunction name="tabPRCIdetalhe_mensalAcumulado_CI" access="remote" returntype="string" hint="cria tabela como os dados para o indicador PRCI, de todos os meses, dos órgãos para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>

		
		<cfquery name="resultadoDetalhe" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indDados_numPosic
				,pc_indDados_mcuOrgaoResp as mcuOrgaoResp
				,pc_orgaos.pc_org_sigla as siglaOrgaoResp
				,pc_indDados_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,pc_indDados_mcuOrgaoAvaliado as mcuOrgaoAvaliado
				,pc_orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
				,pc_indDados_numProcesso as numProcessoSNCI
				,pc_indDados_numItem as item
				,pc_indDados_numOrientacao as orientacao
				,pc_indDados_dataPrevista as dataPrevista
				,pc_indDados_status as numStatus
				,pc_indDados_descricaoStatus as descricaoOrientacaoStatus
				,pc_indDados_dataRef as dataRef
				,pc_indDados_numIndicador as numIndicador
				,CASE 
					WHEN pc_indDados_descricaoStatus = 'PENDENTE' THEN DATEADD(day, 1, pc_indDados_dataPrevista)
					ELSE pc_indDados_dataStatus
				END as dataPosicao
				,pc_indDados_prazo as prazo

			FROM pc_indicadores_dados
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			INNER JOIN pc_orgaos as pc_orgaoAvaliado on pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			WHERE MONTH(pc_indDados_dataRef) <= <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
			      and YEAR(pc_indDados_dataRef) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">

		</cfquery>

		<cfquery name="resultadoPRCIdetalhe"   dbtype="query">
			SELECT * FROM resultadoDetalhe	WHERE numIndicador = 1
		</cfquery>

		<cfif resultadoPRCIdetalhe.recordcount neq 0 >	
			<div id="divDetalhePRCI" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
						
							<div class="table-responsive">
								<table id="tabPRCIdetalheAcumulado" class="table table-bordered table-striped text-nowrap" style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead >
									    <tr style="font-size:14px">
											<th colspan="14" style="padding:5px"><h5 style="color:#0083ca;margin-left: 10px">Dados utilizados no cálculo do PRCI: <cfoutput><strong>Janeiro a #monthAsString(mes)#/#ano#</strong></cfoutput></h5></th>
										</tr>
										<tr style="font-size:14px">
											<th style="width: 10px">Posic ID</th>
											<th style="width: 10px">Mês</th>
											<th style="width: 10px">Ano</th>
											<th style="width: 10px">SE/CS</th>
											<th style="width: 10px">Órgão Responsável</th>
											<th style="width: 10px">Processo SNCI</th>
											<th style="width: 10px">Órgão Avaliado</th>
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
										<cfloop query="resultadoPRCIdetalhe" >
										
											<cfoutput>					
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#pc_indDados_numPosic#</td>
													<td>#dateFormat(dataRef, 'mm')#</td>
													<td>#dateFormat(dataRef, 'yyyy')#</td>
													<td>#siglaOrgaoSubordinador# (#mcuOrgaoSubordinador#)</td>
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td>#numProcessoSNCI#</td>
													<td>#siglaOrgaoAvaliado# (#mcuOrgaoAvaliado#)</td>
													<td >#item#</td>
													<td>#orientacao#</td>
													<cfif dataPrevista eq '1900-01-01' or dataPrevista eq ''>
														<td>NÃO INF.</td>
													<cfelse>
														<td>#dateFormat(dataPrevista, 'dd/mm/yyyy')#</td>
													</cfif>
													<td>#dateFormat(dataPosicao, 'dd/mm/yyyy')#</td>
													<td>#descricaoOrientacaoStatus#</td>
													<td>#dateFormat(dataRef, 'dd/mm/yyyy')#</td>
													<td>#prazo#</td>
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
        <cfelse>
			<h5>Não há dados para exibir</h5>
		</cfif>

		<script language="JavaScript">
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel
			var tituloExcel_PRCIacumulado ="SNCI_Consulta_PRCI_detalhamentoAcumulado_";
			$('#tabPRCIdetalheAcumulado').DataTable( {
				destroy: true, // Destruir a tabela antes de recriá-la
				stateSave: false,
				deferRender: true, // Aumentar desempenho para tabelas com muitos registros
				scrollX: true, // Permitir rolagem horizontal
				autoWidth: true,// Ajustar automaticamente o tamanho das colunas
				pageLength: 5,
				
				dom: "<'row'<'col-sm-3'B><'col-sm-4 text-center' p><'col-sm-4 text-right'i>>" ,
				order: [[1, 'asc'], [2, 'asc']], // Ordena a segunda e a terceira coluna em ordem crescente
				buttons: [
					{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
						title : tituloExcel_PRCIacumulado + d,
						className: 'btExcel',
					}

				]
				

			})
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
			});
		</script>
	</cffunction>

	<cffunction name="tabSLNCdetalhe_mensalAcumulado_CI" access="remote" returntype="string" hint="cria tabela como os dados para o indicador SLNC dos órgãos para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>

		<cfquery name="resultadoDetalhe" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indDados_numPosic
				,pc_indDados_mcuOrgaoResp as mcuOrgaoResp
				,pc_orgaos.pc_org_sigla as siglaOrgaoResp
				,pc_indDados_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,pc_indDados_mcuOrgaoAvaliado as mcuOrgaoAvaliado
				,pc_orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
				,pc_indDados_numProcesso as numProcessoSNCI
				,pc_indDados_numItem as item
				,pc_indDados_numOrientacao as orientacao
				,pc_indDados_dataPrevista as dataPrevista
				,pc_indDados_status as numStatus
				,pc_indDados_descricaoStatus as descricaoOrientacaoStatus
				,pc_indDados_dataRef as dataRef
				,pc_indDados_numIndicador as numIndicador
				,CASE 
					WHEN pc_indDados_descricaoStatus = 'PENDENTE' THEN DATEADD(day, 1, pc_indDados_dataPrevista)
					ELSE pc_indDados_dataStatus
				END as dataPosicao
				,pc_indDados_prazo as prazo

			FROM pc_indicadores_dados
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			INNER JOIN pc_orgaos as pc_orgaoAvaliado on pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			WHERE MONTH(pc_indDados_dataRef) <= <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
			      and YEAR(pc_indDados_dataRef) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">

		</cfquery>

		<cfquery name="resultadoSLNCdetalhe"   dbtype="query">
			SELECT * FROM resultadoDetalhe	WHERE numIndicador = 2
		</cfquery>

		<cfif resultadoSLNCdetalhe.recordcount neq 0 >	
			<div id="divDetalheSLNC" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
														
						
							<div class="table-responsive">
								<table id="tabSLNCdetalheAcumulado" class="table table-bordered table-striped text-nowrap" style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead>
										<tr style="font-size:14px">
											<th colspan="14" style="padding:5px"><h5 style="color:#0083ca;margin-left: 10px">Dados utilizados no cálculo do SLNC: <cfoutput><strong>Janeiro a #monthAsString(mes)#/#ano#</strong></cfoutput></h5></th>
										</tr>
										<tr style="font-size:14px">
											<th style="width: 10px">Posic ID</th>
											<th style="width: 10px">Mês</th>
											<th style="width: 10px">Ano</th>
											<th style="width: 10px">SE/CS</th>
											<th style="width: 10px">Órgão Responsável</th>
											<th style="width: 10px">Processo SNCI</th>
											<th style="width: 10px">Órgão Avaliado</th>
											<th style="width: 10px">Item</th>
											<th style="width: 10px">Orientação</th>
											<th style="width: 10px">Data Prevista</th>
											<th style="width: 10px">Data Status</th>
											<th style="width: 10px">Status</th>
											<th style="width: 10px">Data Ref.</th>

										</tr>
									</thead>
									
									<tbody>
										<cfloop query="resultadoSLNCdetalhe" >
										
											<cfoutput>					
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#pc_indDados_numPosic#</td>
													<td>#dateFormat(dataRef, 'mm')#</td>
													<td>#dateFormat(dataRef, 'yyyy')#</td>
													<td>#siglaOrgaoSubordinador# (#mcuOrgaoSubordinador#)</td>
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td>#numProcessoSNCI#</td>
													<td>#siglaOrgaoAvaliado# (#mcuOrgaoAvaliado#)</td>
													<td >#item#</td>
													<td>#orientacao#</td>
													<cfif dataPrevista eq '1900-01-01' or dataPrevista eq ''>
														<td>NÃO INF.</td>
													<cfelse>
														<td>#dateFormat(dataPrevista, 'dd/mm/yyyy')#</td>
													</cfif>
													<td>#dateFormat(dataPosicao, 'dd/mm/yyyy')#</td>

													<td>#descricaoOrientacaoStatus#</td>

													<td>#dateFormat(dataRef, 'dd/mm/yyyy')#</td>
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
        <cfelse>
			<h5>Não há dados para exibir</h5>
		</cfif>

		<script language="JavaScript">

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel
			var tituloExcel_SLNCacumulado ="SNCI_Consulta_SLNC_detalhamento_acumulado";

				$('#tabSLNCdetalheAcumulado').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					
					dom: "<'row'<'col-sm-3'B><'col-sm-4 text-center' p><'col-sm-4 text-right'i>>"  ,
					order: [[1, 'asc'], [2, 'asc']], // Ordena a segunda e a terceira coluna em ordem crescente
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_SLNCacumulado + d,
							className: 'btExcel',
						}

					]
					

				})
				$(document).ready(function() {
					$(".content-wrapper").css("height", "auto");
				});
		</script>

	</cffunction>

	<cffunction name="tabPRCIorgaosSubordinadores_mensal_CI" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do PRCI dos órgãos subordinadores para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorPRCI_TIDP_TGI_mensal(ano=arguments.ano, mes=arguments.mes,paraOrgaoSubordinador=1)>

		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
			<div  class="row" >
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body" >
							<div class="table-responsive ">
								<table id="tabPRCIporOrgaoSubordinador" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									<cfoutput>
										<thead  style="text-align: center;">
											<tr style="font-size:14px">
												<th colspan="7" style="padding:5px">PRCI - <span>#monthAsString(mes)#/#ano#</span></th>
											</tr>
											<tr style="font-size:14px">
												<th >Órgão</th>
												<th class="bg-gradient-warning">PRCI %</th>
												<th >Meta %</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning">PRCI<br>Acumulado %</th>
												<th>Resultado Acumulado</th>
												<th>Result. %<br>em Relação à Meta Mensal</th>
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													
													<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#">
														SELECT pc_indMeta_meta
															FROM pc_indicadores_meta
															WHERE pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indMeta_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
																AND pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_paraOrgaoSubordinador = 1
													</cfquery>
													
													<!--- Adiciona cada linha à tabela --->
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td style="text-align: left;">#siglaOrgao# (#mcuOrgao#)</td>
														<td><strong>#NumberFormat(ROUND(PRCI*10)/10,0.0)#</strong></td>
														<cfif rsMetaPRCI.pc_indMeta_meta eq ''>
															<td>sem meta</td>
															<cfset resultMesEmRelacaoMeta = "sem meta">
															<cfset resultAcumuladoEmRelacaoMeta = "sem meta">
														<cfelse>
														    <cfset metaPRCIorgao = NumberFormat(ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10,0.0)>
															<cfset resultMesEmRelacaoMeta = NumberFormat(ROUND((PRCI/metaPRCIorgao)*100*10)/10,0.0)>
															<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((PRCIacumulado/metaPRCIorgao)*100*10)/10,0.0)>	
															<td>#metaPRCIorgao#</td>
														</cfif>
														<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
														<td><strong>#NumberFormat(ROUND(PRCIacumulado*10)/10,0.0)#</strong></td>
														<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
														<td>#resultMesEmRelacaoMeta#</td>
														
														
													</tr>
												</cfloop>
											</cfoutput>
										</tbody>
										
									</cfoutput>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
		<cfelse>
			<h5>Não há dados para exibir</h5>
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
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel

			
			var tituloExcel_PRCIporOrgaoSubordinador ="SNCI_Consulta_PRCI_porOrgaoSubordinador_";
			$('#tabPRCIporOrgaoSubordinador').DataTable( {
				destroy: true, // Destruir a tabela antes de recriá-la
				stateSave: false,
				deferRender: true, // Aumentar desempenho para tabelas com muitos registros
				scrollX: true, // Permitir rolagem horizontal
				autoWidth: true,// Ajustar automaticamente o tamanho das colunas
				pageLength: 5,//quantidade de registros por página
				lengthMenu: [
					[5, 10, 25, 50, -1],
					['5', '10', '25', '50', 'Todos']
				],
				dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
				order: [[2, 'desc']],//classificar pela coluna PRCI em ordem decrescente
				//dom:   "<'row'<'col-sm-2'B><'col-sm-4'p><'col-sm-12 text-left'i>>" ,
				buttons: [
					{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
						title : tituloExcel_PRCIporOrgaoSubordinador + d,
						className: 'btExcel',
						exportOptions: {
							format: {
								body: function (data, row, column, node) {
									return $(node).data('excel') !== undefined ? $(node).data('excel') : $(node).text();
								}
							}
						},
						//código para exibir todas apáginas, exportar e voltar para a página original. Isso porque só a página atual estava sendo exportada com a formatação correta da função updateTDresultIndicadores
						action: function (e, dt, button, config) {
							// Armazenar a página atual
							var currentPage = dt.page();

							// Exibir temporariamente todas as páginas
							dt.page.len(-1).draw('page');

							// Exportar os dados
							$.fn.dataTable.ext.buttons.excelHtml5.action.call(this, e, dt, button, config);

							// Restaurar o número padrão de linhas por página e a página original
							dt.page.len(5).draw('page');
							dt.page(currentPage).draw('page');
						}
						
					}
				],
				drawCallback: function (settings) {
					aplicarEstiloNasTDsComClasseTdResult();
				}
			})
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
    

			});
		</script>




	</cffunction>

	<cffunction name="tabSLNCorgaosSubordinadores_mensal_CI" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do SLNC dos órgãos subordinadores para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfset var resultado = consultaIndicadorSLNC_QTSL_QTNC(ano=arguments.ano, mes=arguments.mes,paraOrgaoSubordinador=1)>

		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
			<div  class="row" >
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body" >
							<div class="table-responsive ">
								<table id="tabSLNCporOrgaoSubordinador" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									<cfoutput>
										<thead  style="text-align: center;">
											<tr style="font-size:14px">
												<th colspan="7" style="padding:5px">SLNC - <span>#monthAsString(mes)#/#ano#</span></th>
											</tr>
											<tr style="font-size:14px">
												<th >Órgão</th>
												<th class="bg-gradient-warning">SLNC %</th>
												<th >Meta %</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning">SLNC<br>Acumulado %</th>
												<th>Resultado Acumulado</th>
												<th>Result. %<br>em Relação à Meta Mensal</th>
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#">
														SELECT  pc_indMeta_meta 
														FROM pc_indicadores_meta
														WHERE pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
															AND pc_indMeta_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
															AND pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
															AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
															AND pc_indMeta_paraOrgaoSubordinador = 1
													</cfquery>

													<!--- Adiciona cada linha à tabela --->
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td style="text-align: left;"  >#siglaOrgao# (#mcuOrgao#)</td>
														<td><strong>#NumberFormat(ROUND(SLNC*10)/10,0.0)#</strong></td>
														
														<cfif rsMetaSLNC.pc_indMeta_meta eq ''>
															<td>sem meta</td>
															<cfset resultMesEmRelacaoMeta = "sem meta">
															<cfset resultAcumuladoEmRelacaoMeta = "sem meta">
														<cfelse>
														    <cfset metaSLNCorgao = NumberFormat(ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10,0.0)>
															<cfset resultMesEmRelacaoMeta = NumberFormat(ROUND((SLNC/metaSLNCorgao)*100*10)/10,0.0)>
															<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((SLNCacumulado/metaSLNCorgao)*100*10)/10,0.0)>	
															<td>#metaSLNCorgao#</td>
														</cfif>
														<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
														<td><strong>#NumberFormat(ROUND(SLNCacumulado*10)/10,0.0)#</strong></td>
														<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
														<td>#resultMesEmRelacaoMeta#</td>
													</tr>
												</cfloop>
											</cfoutput>
										</tbody>
										
									</cfoutput>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
		<cfelse>
			<h5>Não há dados para exibir</h5>
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
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel

			
			var tituloExcel_SLNCporOrgaoSubordinador ="SNCI_Consulta_SLNC_porOrgaoSubordinador_";
				$('#tabSLNCporOrgaoSubordinador').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
					autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,//quantidade de registros por página
					lengthMenu: [
						[5, 10, 25, 50, -1],
						['5', '10', '25', '50', 'Todos']
					],
					dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
					order: [[1, 'desc']],//classificar pela coluna SLNC em ordem decrescente
					//dom:   "<'row'<'col-sm-2'B><'col-sm-4'p><'col-sm-12 text-left'i>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_SLNCporOrgaoSubordinador + d,
							className: 'btExcel',
							exportOptions: {
									format: {
										body: function (data, row, column, node) {
											return $(node).data('excel') !== undefined ? $(node).data('excel') : $(node).text();
										}
									}
								},
							//código para exibir todas apáginas, exportar e voltar para a página original. Isso porque só a página atual estava sendo exportada com a formatação correta da função updateTDresultIndicadores
							action: function (e, dt, button, config) {
								// Armazenar a página atual
								var currentPage = dt.page();

								// Exibir temporariamente todas as páginas
								dt.page.len(-1).draw('page');

								// Exportar os dados
								$.fn.dataTable.ext.buttons.excelHtml5.action.call(this, e, dt, button, config);

								// Restaurar o número padrão de linhas por página e a página original
								dt.page.len(5).draw('page');
								dt.page(currentPage).draw('page');
							}
						}
					],
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}
				})
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
	

			});
		</script>

	</cffunction>

	<cffunction name="tabDGCIorgaosSubordinadores_mensal_CI" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do DGCI dos órgãos subordinadores para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfset var resultado = consultaIndicadorDGCI_mensal(ano=arguments.ano, mes=arguments.mes,paraOrgaoSubordinador=1)>

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

		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
			<div  class="row" >
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body" >
							<div class="table-responsive ">
								<table id="tabDGCIporOrgaoSubordinador" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									<cfoutput>
										<thead  style="text-align: center;">
											<tr style="font-size:14px">
												<th colspan="9" style="padding:5px">DGCI - <span>#monthAsString(mes)#/#ano#</span></th>
											</tr>
											<tr style="font-size:14px">
												<th >Órgão</th>
												<th>PRCI %</th>
												<th>SLNC %</th>
												<th class="bg-gradient-warning" style="border-left:1px solid ##000;border-right:1px solid ##000;border-top:1px solid ##000;text-align: center;">
													DGCI %<br>
													<span style="font-size: 9px">(PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span>
												</th>
												<th >Meta %</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning" style="border-left:1px solid ##000;border-right:1px solid ##000;border-top:1px solid ##000;text-align: center;">DGCI<br>Acumulado</th>
												<th>Resultado Acumulado</th>
												<th>Result. %<br>em Relação à Meta Mensal</th>
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#">
														SELECT pc_indMeta_meta 
															FROM pc_indicadores_meta
															WHERE pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indMeta_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
																AND pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_paraOrgaoSubordinador = 1

													</cfquery>

													<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#">
														SELECT pc_indMeta_meta 
															FROM pc_indicadores_meta
															WHERE pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indMeta_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
																AND pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_paraOrgaoSubordinador = 1
													</cfquery>

													<!--- Adiciona cada linha à tabela --->
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td style="text-align: left;"  >#siglaOrgao# (#mcuOrgao#)</td>
														<cfif PRCI neq ''>
															<td>#PRCI#</td>
														<cfelse>
															<td style="color:red">sem dados</td>
														</cfif>
														<cfif SLNC neq ''>
															<td>#SLNC#</td>											
														<cfelse>
															<td style="color:red">sem dados</td>
														</cfif>
														
														<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#DGCI#</strong></td>
														
														<cfif rsMetaPRCI.pc_indMeta_meta neq ''>
															<cfset metaPRCI = rsMetaPRCI.pc_indMeta_meta>
														<cfelse>
															<cfset metaPRCI = ''>
														</cfif>

														<cfif rsMetaSLNC.pc_indMeta_meta neq ''>
															<cfset metaSLNC = rsMetaSLNC.pc_indMeta_meta>
														<cfelse>
															<cfset metaSLNC = ''>
														</cfif>
														
														<cfif metaPRCI neq '' and metaSLNC neq ''>
															<cfset metaDGCIorgao = round((metaPRCI*rsPRCIpeso.pc_indPeso_peso)*10)/10 + round((metaSLNC*rsSLNCpeso.pc_indPeso_peso)*10)/10>
														<cfelseif metaPRCI neq '' and metaSLNC eq ''>
															<cfset metaDGCIorgao = metaPRCI>
														<cfelseif metaPRCI eq '' and metaSLNC neq ''>
															<cfset metaDGCIorgao = metaSLNC>
														<cfelse>
															<cfset metaDGCIorgao = ''>	
														</cfif>
														

														<cfif metaDGCIorgao neq ''>
															<cfset metaDGCIformatado = NumberFormat(Round(metaDGCIorgao*10)/10,0.0)>
															<td>#metaDGCIformatado#</td>
														<cfelse>
															<td style="color:red">sem meta</td>
														</cfif>

														<cfif metaDGCIorgao neq ''>
															<cfset resultMesEmRelacaoMeta = NumberFormat(ROUND((DGCI/metaDGCIformatado)*100*10)/10,0.0)>
															<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
														<cfelse>
														    <cfset resultMesEmRelacaoMeta ='sem meta'>
															<td style="color:red">sem meta</td>
														</cfif>
														<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(DGCIacumulado*10)/10,0.0)#</strong></td>
									                    <cfif metaDGCIorgao neq ''>
															<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((NumberFormat(ROUND(DGCIacumulado*10)/10,0.0)/metaDGCIformatado)*100*10)/10,0.0)>
															<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
														<cfelse>
														    <cfset resultAcumuladoEmRelacaoMeta ='sem meta'>
															<td style="color:red">sem meta</td>
														</cfif>
														<td>#resultMesEmRelacaoMeta#</td>
													</tr>
												</cfloop>
											</cfoutput>
										</tbody>
										<tfoot >
											<tr>
												<th colspan="9" style="font-weight: normal; font-size: smaller;">
												    <li>DGCI % = (PRCI x peso PRCI) + (SLNC x peso SLNC) -> Não existindo dados para o SLNC, a fórmula será DGCI % = PRCI x peso PRCI. Não existindo dados para o PRCI, a fórmula será DGCI % = SLNC x peso SLNC; </li>
													<li>META % = (meta PRCI x peso PRCI) + (meta SLNC x peso SLNC) -> Meta fixa, independente da existência de dados de algum indicador da cesta.</li>
												</th>
											</tr>
										</tfoot>
										
									</cfoutput>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
		<cfelse>
			<h5>Não há dados para exibir</h5>
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
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel

			
			var tituloExcel_DGCIporOrgaoSubordinador ="SNCI_Consulta_DGCI_porOrgaoSubordinador_";
				$('#tabDGCIporOrgaoSubordinador').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
					autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,//quantidade de registros por página
					lengthMenu: [
						[5, 10, 25, 50, -1],
						['5', '10', '25', '50', 'Todos']
					],
					dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
					order: [[3, 'desc']],//classificar pela coluna DGCI em ordem decrescente
					//dom:   "<'row'<'col-sm-2'B><'col-sm-4'p><'col-sm-12 text-left'i>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_DGCIporOrgaoSubordinador + d,
							className: 'btExcel',
							exportOptions: {
								format: {
									body: function (data, row, column, node) {
										return $(node).data('excel') !== undefined ? $(node).data('excel') : $(node).text();
									}
								}
							},
							//código para exibir todas apáginas, exportar e voltar para a página original. Isso porque só a página atual estava sendo exportada com a formatação correta da função updateTDresultIndicadores
							action: function (e, dt, button, config) {
								// Armazenar a página atual
								var currentPage = dt.page();

								// Exibir temporariamente todas as páginas
								dt.page.len(-1).draw('page');

								// Exportar os dados
								$.fn.dataTable.ext.buttons.excelHtml5.action.call(this, e, dt, button, config);

								// Restaurar o número padrão de linhas por página e a página original
								dt.page.len(5).draw('page');
								dt.page(currentPage).draw('page');
							}
						}
					],
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}
				})
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
	

			});
		</script>

	</cffunction>

	<cffunction name="tabDGCIorgaosResposaveis_mensal_CI" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do DGCI dos órgãos subordinadores para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfset var resultado = consultaIndicadorDGCI_mensal(ano=arguments.ano, mes=arguments.mes, paraOrgaoResponsavel=1)>

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

		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
			<div  class="row" >
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body" >
							<div class="table-responsive ">
								<table id="tabDGCIporOrgaoResponsavel" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									<cfoutput>
										<thead  style="text-align: center;">
											<tr style="font-size:14px">
												<th colspan="10" style="padding:5px">DGCI - <span>#monthAsString(mes)#/#ano#</span></th>
											</tr>
											<tr style="font-size:14px">
												<th >Órgão</th>
												<th>Órgão Subordinador</th>
												<th>PRCI %</th>
												<th>SLNC %</th>
												<th class="bg-gradient-warning" style="border-left:1px solid ##000;border-right:1px solid ##000;border-top:1px solid ##000;text-align: center;">
													DGCI %<br>
													<span style="font-size: 9px">(PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span>
												</th>
												<th >Meta %</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning" style="border-left:1px solid ##000;border-right:1px solid ##000;border-top:1px solid ##000;text-align: center;">DGCI<br>Acumulado</th>
												<th>Resultado Acumulado</th>
												<th>Result. %<br>em Relação à Meta Mensal</th>
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													

													<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
														SELECT pc_indMeta_meta as metaPRCI FROM pc_indicadores_meta 
														WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
																AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
																AND pc_indMeta_numIndicador = 1
																AND pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indMeta_paraOrgaoSubordinador = 0
													</cfquery>	

												

													<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
														SELECT pc_indMeta_meta as metaSLNC FROM pc_indicadores_meta 
														WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
																AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
																AND pc_indMeta_numIndicador = 2
																AND pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indMeta_paraOrgaoSubordinador = 0
													</cfquery>

													<!--- Adiciona cada linha à tabela --->
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td style="text-align: left;"  >#siglaOrgao# (#mcuOrgao#)</td>
														<td style="text-align: left;"  >#siglaOrgaoSubordinador# (#mcuOrgaoSubordinador#)</td>
														<cfif PRCI neq ''>
															<td>#NumberFormat(ROUND(PRCI*10)/10,0.0)#</td>
														<cfelse>
															<td style="color:red">sem dados</td>
														</cfif>
														<cfif SLNC neq ''>
															<td>#NumberFormat(ROUND(SLNC*10)/10,0.0)#</td>											
														<cfelse>
															<td style="color:red">sem dados</td>
														</cfif>
														
														<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(DGCI*10)/10,0.0)#</strong></td>
														
														<cfif rsMetaPRCI.metaPRCI neq ''>
															<cfset metaPRCI = NumberFormat(ROUND(rsMetaPRCI.metaPRCI*10)/10,0.0)>
														<cfelse>
															<cfset metaPRCI = ''>
														</cfif>

														<cfif rsMetaSLNC.metaSLNC neq ''>
															<cfset metaSLNC = NumberFormat(ROUND(rsMetaSLNC.metaSLNC*10)/10,0.0)>
														<cfelse>
															<cfset metaSLNC = ''>
														</cfif>
														
														<cfif metaPRCI neq '' and metaSLNC neq ''>
															<cfset metaDGCIorgao = (metaPRCI*rsPRCIpeso.pc_indPeso_peso) + (metaSLNC*rsSLNCpeso.pc_indPeso_peso)>
														<cfelseif metaPRCI neq '' and metaSLNC eq ''>
															<cfset metaDGCIorgao = metaPRCI>
														<cfelseif metaPRCI eq '' and metaSLNC neq ''>
															<cfset metaDGCIorgao = metaSLNC>
														<cfelse>
															<cfset metaDGCIorgao = NumberFormat(0,0.0)>	
														</cfif>
														
														<cfif metaDGCIorgao neq 0>
															<cfset metaDGCIformatado = NumberFormat(ROUND(metaDGCIorgao*10)/10,0.0)>
															<td>#metaDGCIformatado#</td>
														<cfelse>
															<td style="color:red">sem meta</td>
														</cfif>

														<cfif metaDGCIorgao neq 0>
															<cfset resultMesEmRelacaoMeta = NumberFormat(ROUND((DGCI/metaDGCIformatado)*100*10)/10,0.0)>
															<td >
																<span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span>
															</td>
														<cfelse>
														    <cfset resultMesEmRelacaoMeta ='sem meta'>
															<td style="color:red">sem meta</td>
														</cfif>
														<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(DGCIacumulado*10)/10,0.0)#</strong></td>
									                    <cfif metaDGCIorgao neq 0>
															<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((NumberFormat(ROUND(DGCIacumulado*10)/10,0.0)/metaDGCIformatado)*100*10)/10,0.0)>
															<td >
																<span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span>
															</td>
														<cfelse>
														    <cfset resultAcumuladoEmRelacaoMeta ='sem meta'>
															<td style="color:red">sem meta</td>
														</cfif>

														<cfif resultMesEmRelacaoMeta neq 'sem meta'>
															<td>#resultMesEmRelacaoMeta#</td>
														<cfelse>
															<td style="color:red">#resultMesEmRelacaoMeta#</td>
														</cfif>


														
													</tr>
												</cfloop>
											</cfoutput>
										</tbody>
										<tfoot >
											<tr>
												<th colspan="10" style="font-weight: normal; font-size: smaller;">
												    <li>DGCI % = (PRCI x peso PRCI) + (SLNC x peso SLNC) -> Não existindo dados para o SLNC, a formula será DGCI % = PRCI x peso PRCI. Não existindo dados para o PRCI, a formula será DGCI % = SLNC x peso SLNC; </li>
													<li>META % = (meta PRCI x peso PRCI) + (meta SLNC x peso SLNC) -> Meta fixa, independente da existência de dados de algum indicador da cesta.</li>
												</th>
											</tr>
										</tfoot>
										
									</cfoutput>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
		<cfelse>
			<h5>Não há dados para exibir</h5>
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
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel
			
			var tituloExcel_DGCIporOrgaoResponsavel ="SNCI_Consulta_DGCI_porOrgaoResponsavel_";
			$('#tabDGCIporOrgaoResponsavel').DataTable( {
				destroy: true, // Destruir a tabela antes de recriá-la
				stateSave: false,
				deferRender: true, // Aumentar desempenho para tabelas com muitos registros
				scrollX: true, // Permitir rolagem horizontal
				autoWidth: true,// Ajustar automaticamente o tamanho das colunas
				pageLength: 5,//quantidade de registros por página
				lengthMenu: [
					[5, 10, 25, 50, -1],
					['5', '10', '25', '50', 'Todos']
				],
				dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
				order: [[4, 'desc']],//classificar pela coluna DGCI em ordem decrescente
				//dom:   "<'row'<'col-sm-2'B><'col-sm-4'p><'col-sm-12 text-left'i>>" ,
				buttons: [
					{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
						title : tituloExcel_DGCIporOrgaoResponsavel + d,
						className: 'btExcel',
						exportOptions: {
							format: {
								body: function (data, row, column, node) {
									return $(node).data('excel') !== undefined ? $(node).data('excel') : $(node).text();
								}
							}
						},
						//código para exibir todas apáginas, exportar e voltar para a página original. Isso porque só a página atual estava sendo exportada com a formatação correta da função updateTDresultIndicadores
						action: function (e, dt, button, config) {
							// Armazenar a página atual
							var currentPage = dt.page();

							// Exibir temporariamente todas as páginas
							dt.page.len(-1).draw('page');

							// Exportar os dados
							$.fn.dataTable.ext.buttons.excelHtml5.action.call(this, e, dt, button, config);

							// Restaurar o número padrão de linhas por página e a página original
							dt.page.len(5).draw('page');
							dt.page(currentPage).draw('page');
						}
					}
				],
				drawCallback: function (settings) {
					aplicarEstiloNasTDsComClasseTdResult();
				}
			})
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
	

			});
		</script>

	</cffunction>

	<cffunction name="tabDGCImes_A_mes_mensal_CI" access="remote" returntype="string" hint="cria tabela com as informações dos resultados do DGCI mês a mês para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
		
		<cfquery name="rsIndicadoresPorOrgao" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indOrgao_ano
				   ,pc_indOrgao_mes
				   ,pc_indOrgao_numIndicador
				   ,pc_indOrgao_mcuOrgao
				   ,pc_orgaos.pc_org_sigla as siglaOrgao
				   ,pc_indOrgao_resultadoMes 
				   ,pc_indOrgao_resultadoAcumulado 
				   ,pc_indOrgao_paraOrgaoSubordinador
 				   ,pc_indOrgao_mcuOrgaoSubordinador
				   ,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
			FROM pc_indicadores_porOrgao
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgaoSubordinador
			WHERE pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
				and pc_indOrgao_numIndicador = <cfqueryparam value="3" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery name="resultadoECTmes" dbtype="query"  >
			SELECT  pc_indOrgao_mes
					,pc_indOrgao_numIndicador
					,AVG(pc_indOrgao_resultadoMes) AS media_resultadoMes
					,AVG(pc_indOrgao_resultadoAcumulado) AS media_resultadoAcumulado
			FROM rsIndicadoresPorOrgao
			WHERE pc_indOrgao_paraOrgaoSubordinador = 1
			and pc_indOrgao_mes <= <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
			GROUP BY pc_indOrgao_mes, pc_indOrgao_numIndicador
			ORDER BY pc_indOrgao_mes, pc_indOrgao_numIndicador
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

		<cfif resultadoECTmes.recordcount neq 0>
			<div class="card-body shadow" style="border: 2px solid #34a2b7">
				<div id="divIndicadoresMes" class="row" >
					<div class="row" style="width: 100%;">	
						<div class="col-12">

								<div class="table-responsive " style="width: 850px; margin: 0 auto;">
									<h4 style=" text-align: center;">DGCI ECT <cfoutput>#arguments.ano#</cfoutput> por Mês:</h4>
									<table id="tabIndicadorDGCI_Mes_a_Mes" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
										
										<thead >
											<tr style="font-size:14px;text-align: center;">
												<th >MÊS</th>
												<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;text-align: center;">
													DGCI
												</th>
												<th >META</th>
												<th >RESULTADO</th>
												<th >Result. % em Relação<br>à Meta</th>
											</tr>
										</thead>
										
										<tbody>
											<cfoutput query="resultadoECTmes" group="pc_indOrgao_mes">
												<cfquery name="mediaMetaDGCImes" datasource="#application.dsn_processos#" timeout="120">
													SELECT AVG(metaDGCImes) AS mediaDGCI
													FROM(SELECT pc_indOrgao_mcuOrgaoSubordinador
														,ROUND(AVG(metaPRCI),1) AS metaPRCI
														,ROUND(AVG(metaSLNC),1) AS metaSLNC
														,max(pesoPRCI) AS pesoPRCI
														,MAX(pesoSLNC) AS pesoSLNC
														,ROUND((ROUND(AVG(metaPRCI),1)*MAX(pesoPRCI)) + (ROUND(AVG(metaSLNC),1)*MAX(pesoSLNC)),1) AS metaDGCImes
													FROM(SELECT pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
														,SUM(metaPRCI) AS metaPRCI
														,SUM(metaSLNC) AS metaSLNC
														,SUM(pesoPRCI) AS pesoPRCI
														,SUM(pesoSLNC) AS pesoSLNC
														FROM(SELECT	pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
																,IIF(pc_indMeta_numIndicador =1, ROUND(pc_indMeta_meta,1),NULL) AS metaPRCI
																,IIF(pc_indMeta_numIndicador =2, ROUND(pc_indMeta_meta,1),NULL) AS metaSLNC
																,IIF(pc_indMeta_numIndicador =1, MAX(pc_indPeso_peso),0) AS pesoPRCI
																,IIF(pc_indMeta_numIndicador =2, MAX(pc_indPeso_peso),0) AS pesoSLNC
															FROM pc_indicadores_meta
															INNER JOIN pc_indicadores_peso on pc_indMeta_ano = pc_indPeso_ano and  pc_indMeta_numIndicador = pc_indPeso_numIndicador
															INNER JOIN (select  DISTINCT pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
																		from pc_indicadores_porOrgao
																		where pc_indOrgao_ano = #ano# and pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
																		) as pc_indicadores_porOrgao on pc_indOrgao_mcuOrgao = pc_indMeta_mcuOrgao 	
															WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
																AND pc_indMeta_numIndicador in (1,2)
																
															GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador,pc_indMeta_numIndicador,pc_indMeta_meta, pc_indPeso_peso
														) AS SUBCONSULTA
														GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
													) AS SUBCONSULTA2
													GROUP BY pc_indOrgao_mcuOrgaoSubordinador
													) AS SUBCONSULTA3

												</cfquery>
																							
												<tr style="font-size:12px;text-align: center;">
													<td>#monthAsString(pc_indOrgao_mes)#</td>
													
													<td><strong>#Replace(NumberFormat(ROUND(media_resultadoMes*10)/10,0.0),',','.')#</strong></td>
										
													<cfset metaDGCI = mediaMetaDGCImes.mediaDGCI>
									
													<td>#NumberFormat(ROUND(metaDGCI*10)/10,0.0)#</td>

													<cfif IIF(pc_indOrgao_numIndicador EQ 3, Replace(ROUND(media_resultadoMes*10)/10,',','.'), "") gt  metaDGCI and  metaDGCI neq 0>
														<td style="color: blue;"><span class="statusOrientacoes" style="background:##0083CA;color:##fff;">ACIMA DO ESPERADO</span></td>
													<cfelseif IIF(pc_indOrgao_numIndicador EQ 3, Replace(ROUND(media_resultadoMes*10)/10,',','.'), "") lt  metaDGCI and  metaDGCI neq 0>
														<td ><span class="statusOrientacoes" style="background:##dc3545;color:##fff;">ABAIXO DO ESPERADO</span></td>	
													<cfelseif IIF(pc_indOrgao_numIndicador EQ 3, Replace(ROUND(media_resultadoMes*10)/10,',','.'), "") eq  metaDGCI and  metaDGCI neq 0>
														<td ><span class="statusOrientacoes" style="background:green;color:##fff;">DENTRO DO ESPERADO</span></td>
													<cfelse>
														<td><span class="statusOrientacoes" style="background:##fff;color:gray;">SEM META</span></td>	
													</cfif>

													
												
													<cfif metaDGCI neq 0>
														<cfset percentual = ((ROUND(media_resultadoMes*10)/10)/(ROUND(metaDGCI*10)/10))*100 >
													<cfelse>
														<cfset percentual = 0>
													</cfif>
														
												
													
													<cfif percentual neq 0>
														<td >#NumberFormat(ROUND(percentual*10)/10,0.0)#</td>
													<cfelse>
														<td>SEM META</td>	
													</cfif>

													

												</tr>
											</cfoutput>
										
										

										</tbody>
										<tfoot >
											<tr>
												<th colspan="5" style="font-weight: normal; font-size: smaller;">
													<li>DGCI = média do DGCI dos órgãos subordinadores.</li>
													<li>META = média da META do DGCI dos órgãos subordinadores.</li>
												</th>
											</tr>
										</tfoot>
											
									</table>
										
								</div>
						
						</div>
						<!-- /.col -->
					</div>
				</div>
			</div>
		<cfelse>
			<h5>Não há dados para exibir</h5>
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
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel

			var tituloExcel_DGCI_Mes_a_Mes ="SNCI_Consulta_DGCI_Mes_a_Mes_";
			$('#tabIndicadorDGCI_Mes_a_Mes').DataTable( {
				destroy: true, // Destruir a tabela antes de recriá-la
				ordering: false, // Desativa a classificação
				lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
				paging: false, // Remove a paginação
				info: false, // Remove a exibição da quantidade de registros
				searching: false, // Remove o campo de busca
				dom: "<'row'<'col-sm-2'B>>" ,
				buttons: [
					{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
						title : tituloExcel_DGCI_Mes_a_Mes + d,
						className: 'btExcel',
						exportOptions: {
							format: {
								body: function (data, row, column, node) {
									return $(node).data('excel') !== undefined ? $(node).data('excel') : $(node).text();
								}
							}
						},
						//código para exibir todas apáginas, exportar e voltar para a página original. Isso porque só a página atual estava sendo exportada com a formatação correta da função updateTDresultIndicadores
						action: function (e, dt, button, config) {
							// Armazenar a página atual
							var currentPage = dt.page();

							// Exibir temporariamente todas as páginas
							dt.page.len(-1).draw('page');

							// Exportar os dados
							$.fn.dataTable.ext.buttons.excelHtml5.action.call(this, e, dt, button, config);

							// Restaurar o número padrão de linhas por página e a página original
							dt.page.len(5).draw('page');
							dt.page(currentPage).draw('page');
						}
					}
				]
			})

			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
			});
		</script>
		
	</cffunction>

	<cffunction name="cardDGCI_ECT_mes_mensal_CI" access="remote" returntype="string" hint="cria tabela com as informações dos resultados do DGCI mês a mês para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfquery name="resultado_DGCI_ECT_mes" datasource="#application.dsn_processos#" timeout="120">
			SELECT	AVG(pc_indOrgao_resultadoMes) AS mediaDGCI
			FROM
				pc_indicadores_porOrgao
			WHERE
				pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador =3
				AND pc_indOrgao_paraOrgaoSubordinador = 1
		</cfquery>

		<cfif resultado_DGCI_ECT_mes.mediaDGCI neq ''>
		    <cfset mediaDGCI  =NumberFormat(ROUND(resultado_DGCI_ECT_mes.mediaDGCI*10)/10,0.0)>
			<cfset mediaDGCIformatado = REPLACE(NumberFormat(ROUND(resultado_DGCI_ECT_mes.mediaDGCI*10)/10,0.0), '.', ',')>
		<cfelse>
			<cfset mediaDGCI = 'sem dados'>
			<cfset mediaDGCIformatado = 'sem dados'>
		</cfif>

		<cfquery name="mediaMetaDGCImes" datasource="#application.dsn_processos#" timeout="120">
			SELECT AVG(metaDGCImes) AS mediaMetaDGCI
			FROM(SELECT pc_indOrgao_mcuOrgaoSubordinador
				,ROUND(AVG(metaPRCI),1) AS metaPRCI
				,ROUND(AVG(metaSLNC),1) AS metaSLNC
				,max(pesoPRCI) AS pesoPRCI
				,MAX(pesoSLNC) AS pesoSLNC
				,ROUND((ROUND(AVG(metaPRCI),1)*MAX(pesoPRCI)) + (ROUND(AVG(metaSLNC),1)*MAX(pesoSLNC)),1) AS metaDGCImes
			FROM(SELECT pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
				,SUM(metaPRCI) AS metaPRCI
				,SUM(metaSLNC) AS metaSLNC
				,SUM(pesoPRCI) AS pesoPRCI
				,SUM(pesoSLNC) AS pesoSLNC
				FROM(SELECT	pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
						,IIF(pc_indMeta_numIndicador =1, ROUND(pc_indMeta_meta,1),NULL) AS metaPRCI
						,IIF(pc_indMeta_numIndicador =2, ROUND(pc_indMeta_meta,1),NULL) AS metaSLNC
						,IIF(pc_indMeta_numIndicador =1, MAX(pc_indPeso_peso),0) AS pesoPRCI
						,IIF(pc_indMeta_numIndicador =2, MAX(pc_indPeso_peso),0) AS pesoSLNC
					FROM pc_indicadores_meta
					INNER JOIN pc_indicadores_peso on pc_indMeta_ano = pc_indPeso_ano and  pc_indMeta_numIndicador = pc_indPeso_numIndicador
					INNER JOIN (select  DISTINCT pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
								from pc_indicadores_porOrgao
								where pc_indOrgao_ano = #ano# and pc_indOrgao_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
								) as pc_indicadores_porOrgao on pc_indOrgao_mcuOrgao = pc_indMeta_mcuOrgao 	
					WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
						AND pc_indMeta_numIndicador in (1,2)
					GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador,pc_indMeta_numIndicador,pc_indMeta_meta, pc_indPeso_peso
				) AS SUBCONSULTA
				GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
			) AS SUBCONSULTA2
			GROUP BY pc_indOrgao_mcuOrgaoSubordinador
			) AS SUBCONSULTA3

		</cfquery>

		<cfif mediaMetaDGCImes.mediaMetaDGCI neq ''>
			<cfset mediaMetaDGCI = NumberFormat(ROUND(mediaMetaDGCImes.mediaMetaDGCI*10)/10,0.0)>
			<cfset mediaMetaDGCIformatado = REPLACE(NumberFormat(ROUND(mediaMetaDGCImes.mediaMetaDGCI*10)/10,0.0), '.', ',')>
		<cfelse>
			<cfset mediaMetaDGCI = 'sem meta'>
			<cfset mediaMetaDGCIformatado = 'sem meta'>
		</cfif>

		<cfif mediaMetaDGCI neq 'sem meta'>
			<cfset DGCIresultadoMeta = NumberFormat(ROUND((mediaDGCI/mediaMetaDGCI)*100*10)/10,0.0)>
			<cfset DGCIresultadoMetaFormatado = replace(DGCIresultadoMeta, '.', ',')>
		<cfelse>
			<cfset DGCIresultadoMeta = 'sem meta'>
			<cfset DGCIresultadoMetaFormatado = ''>
		</cfif>

		<cfset infoRodape = '<span style="font-size:14px">DGCI = #mediaDGCIformatado#% (média dos DGCI dos órgãos subordinadores)</span><br>
					<span style="font-size:14px">Meta = #mediaMetaDGCIformatado#% (média das metas do DGCI dos órgãos subordinadores)</span><br>'>
		<cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
		<cfset var cardDGCImensal = objetoCFC.criarCardIndicador(
			tipoDeCard = 'bg-gradient-info',
			siglaIndicador ='DGCI',
			descricaoIndicador = 'Desempenho Geral do Controle Interno',
			percentualIndicadorFormatado = mediaDGCIformatado,
			resultadoEmRelacaoMeta = DGCIresultadoMeta,
			resultadoEmRelacaoMetaFormatado = DGCIresultadoMetaFormatado,
			infoRodape = infoRodape,
			icone = 'fa fa-chart-line'

		)>
		<cfoutput>
			<div class="card-body shadow col-md-8 col-sm-8 col-12 mx-auto" style="border: 2px solid ##34a2b7">
				<div id="divDGCI_mes_ano"><h4 style="text-align: center; margin-bottom:20px">DGCI ECT - <span style="fontsize:12px">#monthAsString(arguments.mes)#/#arguments.ano#</span></h5></div>
				<div>#cardDGCImensal#</div>
			</div>
		</cfoutput>

		<script language="JavaScript">
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				$('.ribbon').each(function() {
					updateRibbon($(this));
				});
			});

		</script>
	</cffunction>

	<cffunction name="cardDGCI_ECT_acumulado_mensal_CI" access="remote" returntype="string" hint="cria tabela com as informações dos resultados do DGCI acumulado para consulta do Controle Interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfquery name="resultado_DGCI_ECT_mes" datasource="#application.dsn_processos#" timeout="120">
			SELECT	pc_indOrgao_mes
			FROM
				pc_indicadores_porOrgao
			WHERE
				pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes <= <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador =3
				AND pc_indOrgao_paraOrgaoSubordinador = 1
			GROUP BY pc_indOrgao_mes
		</cfquery>

		<cfset listMes = ValueList(resultado_DGCI_ECT_mes.pc_indOrgao_mes)>

		<cfset somaMediaMetaDGCImes =0>
		<cfloop index="i" from="1" to="#listLen(listMes)#">
			<cfquery name="mediaMetaDGCImes" datasource="#application.dsn_processos#" timeout="120">
				SELECT ROUND(AVG(metaDGCImes),1) AS mediaDGCI
				FROM(SELECT pc_indOrgao_mcuOrgaoSubordinador
					,ROUND(AVG(metaPRCI),1) AS metaPRCI
					,ROUND(AVG(metaSLNC),1) AS metaSLNC
					,max(pesoPRCI) AS pesoPRCI
					,MAX(pesoSLNC) AS pesoSLNC
					,ROUND((ROUND(AVG(metaPRCI),1)*MAX(pesoPRCI)) + (ROUND(AVG(metaSLNC),1)*MAX(pesoSLNC)),1) AS metaDGCImes
				FROM(SELECT pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
					,SUM(metaPRCI) AS metaPRCI
					,SUM(metaSLNC) AS metaSLNC
					,SUM(pesoPRCI) AS pesoPRCI
					,SUM(pesoSLNC) AS pesoSLNC
					FROM(SELECT	pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
							,IIF(pc_indMeta_numIndicador =1, ROUND(pc_indMeta_meta,1),NULL) AS metaPRCI
							,IIF(pc_indMeta_numIndicador =2, ROUND(pc_indMeta_meta,1),NULL) AS metaSLNC
							,IIF(pc_indMeta_numIndicador =1, MAX(pc_indPeso_peso),0) AS pesoPRCI
							,IIF(pc_indMeta_numIndicador =2, MAX(pc_indPeso_peso),0) AS pesoSLNC
						FROM pc_indicadores_meta
						INNER JOIN pc_indicadores_peso on pc_indMeta_ano = pc_indPeso_ano and  pc_indMeta_numIndicador = pc_indPeso_numIndicador
						INNER JOIN (select  DISTINCT pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
									from pc_indicadores_porOrgao
									where pc_indOrgao_ano = #ano# and pc_indOrgao_mes = <cfqueryparam value="#i#" cfsqltype="cf_sql_integer">
									) as pc_indicadores_porOrgao on pc_indOrgao_mcuOrgao = pc_indMeta_mcuOrgao 	
						WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
							AND pc_indMeta_mes = <cfqueryparam value="#i#" cfsqltype="cf_sql_integer">
							AND pc_indMeta_numIndicador in (1,2)
							
						GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador,pc_indMeta_numIndicador,pc_indMeta_meta, pc_indPeso_peso
					) AS SUBCONSULTA
					GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
				) AS SUBCONSULTA2
				GROUP BY pc_indOrgao_mcuOrgaoSubordinador
				) AS SUBCONSULTA3

			</cfquery>
			
			<cfset somaMediaMetaDGCImes = somaMediaMetaDGCImes + mediaMetaDGCImes.mediaDGCI>

		</cfloop>


		<cfquery name="resultado_DGCI_ECT_mediaMes" datasource="#application.dsn_processos#" timeout="120">
				SELECT AVG(mediaDGCI) AS mediaDGCIano
				FROM(SELECT	pc_indOrgao_mes, ROUND(AVG(pc_indOrgao_resultadoMes),1) AS mediaDGCI
					FROM
						pc_indicadores_porOrgao
					WHERE
						pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_mes <= <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_numIndicador =3
						AND pc_indOrgao_paraOrgaoSubordinador = 1
					GROUP BY pc_indOrgao_mes
					) AS SUBCONSULTA

		</cfquery>

		<cfset mediaMetaDGCIacumulado = NumberFormat(ROUND(somaMediaMetaDGCImes/listLen(listMes)*10)/10,0.0)>
		<cfset mediaMetaDGCIacumuladoFormatado = REPLACE(mediaMetaDGCIacumulado, '.', ',')>

		<cfset mediaDGCIacumulado = NumberFormat(round(resultado_DGCI_ECT_mediaMes.mediaDGCIano*10)/10,0.0)>
		<cfset mediaDGCIacumuladoformatado =REPLACE(mediaDGCIacumulado, '.', ',')>

		
		<cfset DGCIresultadoMeta = NumberFormat(ROUND((mediaDGCIacumulado/mediaMetaDGCIacumulado)*100*10)/10,0.0)>
		<cfset DGCIresultadoMetaFormatado = REPLACE(DGCIresultadoMeta, '.', ',')>
	

		<cfset infoRodape = '<span style="font-size:14px">DGCI = #mediaDGCIacumuladoformatado#% (média dos resultados mensais do DGCI)</span><br>
					<span style="font-size:14px">Meta = #mediaMetaDGCIacumuladoFormatado#% (média das metas mensais do DGCI)</span><br>'>
		<cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
		<cfset var cardDGCImensal = objetoCFC.criarCardIndicador(
			tipoDeCard = 'bg-gradient-info',
			siglaIndicador ='DGCI',
			descricaoIndicador = 'Desempenho Geral do Controle Interno',
			percentualIndicadorFormatado = mediaDGCIacumuladoformatado,
			resultadoEmRelacaoMeta = DGCIresultadoMeta,
			resultadoEmRelacaoMetaFormatado = DGCIresultadoMetaFormatado,
			infoRodape = infoRodape,
			icone = 'fa fa-chart-line'

		)>
		<cfoutput>
			<div class="card-body shadow col-md-8 col-sm-8 col-12 mx-auto" style="border: 2px solid ##34a2b7">
				<div id="divDGCI_mes_ano"><h4 style="text-align: center; margin-bottom:20px">DGCI ECT <span style="fontsize:12px">#arguments.ano#</span></h5></div>
				<div>#cardDGCImensal#</div>
			</div>
		</cfoutput>

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