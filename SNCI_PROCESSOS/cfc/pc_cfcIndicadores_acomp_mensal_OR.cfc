<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	
<!--Acompanhamento Mensal dos Órgãos Responsáveis (ÓRGÃOS SUBORDINADOS)-->

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

	



	<cffunction name="consultaPRCIdetalhe_mensal" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do PRCI">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>


		<cfquery name="consultaPRCImensal" datasource="#application.dsn_processos#" timeout="120"  >
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
				,pc_indDados_mcuOrgaoPosicEcontInterno
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
				AND pc_indDados_numIndicador = 1
				AND pc_indDados_mcuOrgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			
      	</cfquery>

		<cfreturn #consultaPRCImensal#>
      
		

	</cffunction>

	<cffunction name="tabPRCIDetalhe_mensal" access="remote" hint="acompanhamento mensal">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
		
		<cfset resultadoPRCI = consultaPRCIdetalhe_mensal(ano=arguments.ano, mes=arguments.mes)>	

		

		<style>
			.dataTables_wrapper {
				width: 100%; /* ou a largura desejada */
				margin: 0 auto;
			}
		</style>
	
		<cfif #resultadoPRCI.recordcount# neq 0 >	
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
														
								<cfoutput><h5 style="color:##000;text-align: center;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>PRCI</strong> (Atendimento ao Prazo de Resposta): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
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
											<cfloop query="resultadoPRCI" >
											    <cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
													SELECT pc_indMeta_meta FROM pc_indicadores_meta 
													WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_numIndicador = 1
															AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
												</cfquery>
											
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultadoPRCI.pc_indDados_numPosic#</td>
														<td>#resultadoPRCI.siglaOrgaoAvaliado#</td>
														<td>#resultadoPRCI.siglaOrgaoResp#</td>
														<td>#resultadoPRCI.numProcessoSNCI#</td>
														<td >#resultadoPRCI.item#</td>
														<td>#resultadoPRCI.orientacao#</td>
														<cfif resultadoPRCI.dataPrevista eq '1900-01-01' or resultadoPRCI.dataPrevista eq ''>
															<td>NÃO INF.</td>
														<cfelse>
															<td>#dateFormat(resultadoPRCI.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>
															<cfif resultadoPRCI.pc_indDados_mcuOrgaoPosicEcontInterno eq 0 AND (resultadoPRCI.numStatus eq 4 OR resultadoPRCI.numStatus eq 5)>
																#dateFormat(resultadoPRCI.dataPosicao, 'dd/mm/yyyy')#<br><span style="color:red">(dt. distrib.)</span>
															<cfelse>
																#dateFormat(resultadoPRCI.dataPosicao, 'dd/mm/yyyy')#
															</cfif>
														</td>
														<td>#resultadoPRCI.descricaoOrientacaoStatus#</td>
														<td>#dateFormat(dataFinal, 'dd/mm/yyyy')#</td>
														<td>#resultadoPRCI.Prazo#</td>
															
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

	<cffunction name="consultaSLNCdetalhe_mensal" access="remote" hint="acompanhamento mensal">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>


		<cfquery name="consultaSLNCmensal" datasource="#application.dsn_processos#" timeout="120"  >
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
				AND pc_indDados_numIndicador = 2
				AND pc_indDados_mcuOrgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#'
      	</cfquery>
		<cfreturn #consultaSLNCmensal#>

	</cffunction>

	<cffunction name="tabSLNCDetalhe_mensal" access="remote" hint="acompanhamento mensal">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>

		<cfset resultadoSLNC = consultaSLNCdetalhe_mensal(ano=arguments.ano, mes=arguments.mes)>	



		
	
		<cfif #resultadoSLNC.recordcount# neq 0 >
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							
								<cfoutput><h5 style="color:##000;text-align: center; margin-bottom: 20px;margin-bottom: 20px;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>SLNC</strong> (Solução de Não Conformidades): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
								<div class="table-responsive">
									<table id="tabSLNCdetalheMensal" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
										
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
												
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultadoSLNC.pc_indDados_numPosic#</td>
														<td>#resultadoSLNC.siglaOrgaoAvaliado#</td>
														<td>#resultadoSLNC.siglaOrgaoResp#</td>
														<td>#resultadoSLNC.numProcessoSNCI#</td>
														<td >#resultadoSLNC.item#</td>
														<td>#resultadoSLNC.orientacao#</td>
														<cfif resultadoSLNC.dataPrevista eq '1900-01-01' or resultadoSLNC.dataPrevista eq ''>
															<td>---</td>
														<cfelse>
															<td>#dateFormat(resultadoSLNC.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>#dateFormat(resultadoSLNC.dataPosicao, 'dd/mm/yyyy')#</td>
														<td>#resultadoSLNC.descricaoOrientacaoStatus#</td>
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


				const tabSLNCdetalhamento = $('#tabSLNCdetalheMensal').DataTable( {
				
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
				

			});
		</script>

	</cffunction>



	<cffunction name="consultaIndicadorPRCI_TIDP_TGI_mensal" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do PRCI">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

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
				AND pc_indOrgao_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>

		<cfreturn #consulta_PRCI_TIDP_TGI_mensal#>
      
		

	</cffunction>
	
	<cffunction name="tabResumoPRCIorgaosResp_mensal" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do PRCI dos órgãos responsáveis">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorPRCI_TIDP_TGI_mensal(ano=arguments.ano, mes=arguments.mes)>
       
	  	
		
		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
			<div id="divTabResumoPRCIorgaos" class="table-responsive">
				<table id="tabResumoPRCIorgaos" class="table table-bordered table-striped text-nowrap " style="width:350px; cursor:pointer">
					<cfoutput>
						
						<thead class="bg-gradient-warning" style="text-align: center;">
							<tr style="font-size:14px">
								<th colspan="8" style="padding:5px">PRCI - <span>#monthAsString(mes)#/#ano#</span></th>
							</tr>
							<tr style="font-size:14px">
								<th >Órgão</th>
								<th >TIDP</th>
								<th >TGI</th>
								<th >PRCI %</th>
								<th >Meta %</th>
								<th >Resultado</th>
								<th >PRCI<br>Acumulado %</th>
								<th>Result. %<br>em Relação à Meta</th>
							</tr>
						</thead>
						<tbody>
							<cfoutput>
								<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->

									<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
										SELECT pc_indMeta_meta FROM pc_indicadores_meta 
										WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_numIndicador = 1
												AND pc_indMeta_mcuOrgao = '#mcuOrgao#'
									</cfquery>
									
									<!--- Adiciona cada linha à tabela --->
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#siglaOrgao# (#mcuOrgao#)</td>
										<td>#NumberFormat(TIDP,0)#</td>
										<td>#NumberFormat(TGI,0)#</td>
										<td><strong>#NumberFormat(ROUND(PRCI*10)/10,0.0)#</strong></td>
										<cfset metaPRCIorgao = 0>
										<cfif rsMetaPRCI.pc_indMeta_meta neq ''>
											<cfset metaPRCIorgao = NumberFormat(ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10,0.0)>
										</cfif>
										<cfif rsMetaPRCI.pc_indMeta_meta eq ''>
											<td>sem meta</td>
										<cfelse>	
											<td><strong>#metaPRCIorgao#</strong></td>
										</cfif>
										<cfset resultMesEmRelacaoMeta = NumberFormat(ROUND((PRCI/metaPRCIorgao)*100*10)/10,0.0)>
										<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
										<td>#NumberFormat(ROUND(PRCIacumulado*10)/10,0.0)#</td>
										<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((PRCIacumulado/metaPRCIorgao)*100*10)/10,0.0)>
										<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
									</tr>
								</cfloop>
							</cfoutput>
						</tbody>
						<tfoot >
							<tr>
								<th colspan="8" style="font-weight: normal; font-size: smaller;">
									<li>TIDP = Total de orientações dentro do prazo (abrange as orientações nos status “Não respondido” + "Respondido" + “Tratamento”); </li>
									<li>TGI  = Total Geral de orientações (abrange as orientações nos status "Respondido" + “Não Respondido” + "Respondido" + “Tratamento” + “Pendente”); </li>
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

	<cffunction name="cardPRCI_AcompMensal" access="remote" returntype="string" hint="cria o card com as informações dos resultados do PRCI para acompanhamento mensal">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		

		<cfquery name="resultPRCIdados" datasource="#application.dsn_processos#" timeout="120">
			SELECT 
				pc_indOrgao_mcuOrgao as mcuOrgaoResp,
				pc_orgaos.pc_org_sigla as siglaOrgaoResp,
				MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoMes, NULL)) as PRCI,
				MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoAcumulado, NULL)) as PRCIacumulado
			FROM 
				pc_indicadores_porOrgao
			INNER JOIN 
				pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			WHERE 
				pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador = 1
				AND pc_indOrgao_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>


		
		<cfquery name="rsMetaPRCIcardMensal" datasource="#application.dsn_processos#" >
			SELECT avg(pc_indMeta_meta) mediaPRCImeta FROM pc_indicadores_meta 

			WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_numIndicador = 1
					AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		</cfquery>

		<cfset metaPRCIorgao = rsMetaPRCIcardMensal.mediaPRCImeta>
		<cfif metaPRCIorgao neq ''>
			<cfset metaPRCIorgaoFormatado = Replace(NumberFormat(metaPRCIorgao,0.0), ".", ",")>
		</cfif>
		
		<cfif resultPRCIdados.PRCI neq ''>	
			<cfset mediaPRCI = NumberFormat(ROUND(resultPRCIdados.PRCI*10)/10,0.0)>
			<cfset mediaPRCIformatado = Replace(NumberFormat(mediaPRCI,0.0), ".", ",")>

			<cfset PRCIresultadoMeta = ROUND((mediaPRCI / metaPRCIorgao)*100*10)/10>
			<cfset PRCIresultadoMetaFormatado = Replace(NumberFormat(PRCIresultadoMeta,0.0), ".", ",")>
											
			<cfset 	infoRodape = '<span style="font-size:14px">PRCI = #mediaPRCIformatado#% (média do resultado do PRCI dos órgão subordinados)</span><br>
						<span style="font-size:14px">Meta = #metaPRCIorgaoFormatado#% (média das metas do PRCI dos órgãos subordinados)</span><br>'>			
			
			<cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
			<cfset cardPRCImensal = objetoCFC.criarCardIndicador(
				tipoDeCard = 'bg-gradient-warning',
				siglaIndicador ='PRCI',
				descricaoIndicador = 'Atendimento ao Prazo de Resposta',
				percentualIndicadorFormatado = mediaPRCIformatado,
				resultadoEmRelacaoMeta = PRCIresultadoMeta,
				resultadoEmRelacaoMetaFormatado = PRCIresultadoMetaFormatado,
				infoRodape = infoRodape,
				icone = 'fa fa-shopping-basket'

			)>
			<cfoutput>#cardPRCImensal#</cfoutput>
		<cfelse>
			
			<cfoutput><h5 style="text-align:center">Sem dados para o indicador PRCI</cfoutput>
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



    <cffunction name="consultaIndicadorSLNC_QTSL_QTNC" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do SLNC">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

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
				AND pc_indOrgao_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>

		<cfreturn #consulta_SLNC_QTSL_QTNC_mensal#>	

	</cffunction>

	<cffunction name="tabResumoSLNCorgaosResp_mensal" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do SLNC dos órgãos subordinadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorSLNC_QTSL_QTNC(ano=arguments.ano, mes=arguments.mes)>
       
	  	
		
		<!-- tabela resumo -->
		<cfif resultado.recordcount neq 0>
			<div id="divTabResumoSLNCorgaos" class="table-responsive">
				<table id="tabResumoSLNCorgaos" class="table table-bordered table-striped text-nowrap " style="width:350px; cursor:pointer">
					<cfoutput>
						
						<thead class="bg-gradient-warning" style="text-align: center;">
							<tr style="font-size:14px">
								<th colspan="8" style="padding:5px">SLNC - <span>#monthAsString(mes)#/#ano#</span></th>
							</tr>
							<tr style="font-size:14px">
								<th >Órgão</th>
								<th >QTSL</th>
								<th >QTNC</th>
								<th >SLNC %</th>
								<th >Meta %</th>
								<th >Resultado</th>
								<th >SLNC<br>Acumulado %</th>
								<th>Result. %<br>em Relação à Meta</th>
							</tr>
						</thead>
						<tbody>
							<cfoutput>
								<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->

									<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
										SELECT pc_indMeta_meta FROM pc_indicadores_meta 
										WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_numIndicador = 2
												AND pc_indMeta_mcuOrgao = '#mcuOrgao#'
									</cfquery>
									
									<!--- Adiciona cada linha à tabela --->
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#siglaOrgao# (#mcuOrgao#)</td>
										<td>#NumberFormat(QTSL,0)#</td>
										<td>#NumberFormat(QTNC,0)#</td>
										<td><strong>#NumberFormat(ROUND(SLNC*10)/10,0.0)#</strong></td>
										<cfset metaSLNCorgao = 0>
										<cfif rsMetaSLNC.pc_indMeta_meta neq ''>
											<cfset metaSLNCorgao = NumberFormat(ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10,0.0)>
										</cfif>
										<cfif rsMetaSLNC.pc_indMeta_meta eq ''>
											<td>sem meta</td>
										<cfelse>	
											<td><strong>#metaSLNCorgao#</strong></td>
										</cfif>
										<cfset resultMesEmRelacaoMeta = NumberFormat(ROUND((SLNC/metaSLNCorgao)*100*10)/10,0.0)>
										<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
										<td>#NumberFormat(ROUND(SLNCacumulado*10)/10,0.0)#</td>
										<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((SLNCacumulado/metaSLNCorgao)*100*10)/10,0.0)>
										<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
									</tr>
								</cfloop>
							</cfoutput>
						</tbody>
						<tfoot >
							<tr>
								<th colspan="8" style="font-weight: normal; font-size: smaller;">
									<li>QTSL = Quantidade de orientações Solucionadas (abrange as orientações no status "Solucionado" no SNCI);</li>
									<li>QTNC = Quantidade de Orientações Registradas (abrange as orientações nos status "Pendente" + "Tratamento" + "Solucionado" no SNCI);</li>
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

	<cffunction name="cardSLNC_AcompMensal" access="remote" returntype="string" hint="cria o card com as informações dos resultados do SLNC para acompanhamento mensal">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		

		<cfquery name="resultSLNCdados" datasource="#application.dsn_processos#" timeout="120">
			SELECT 
				pc_indOrgao_mcuOrgao as mcuOrgaoResp,
				pc_orgaos.pc_org_sigla as siglaOrgaoResp,
				MAX(IIF(pc_indOrgao_numIndicador = 2, pc_indOrgao_resultadoMes, NULL)) as SLNC,
				MAX(IIF(pc_indOrgao_numIndicador = 2, pc_indOrgao_resultadoAcumulado, NULL)) as SLNCacumulado
			FROM 
				pc_indicadores_porOrgao
			INNER JOIN 
				pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			WHERE 
				pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador = 2
				AND pc_indOrgao_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>

	
		
		<cfquery name="rsMetaSLNCcardMensal" datasource="#application.dsn_processos#" >
			SELECT avg(pc_indMeta_meta) mediaSLNCmeta FROM pc_indicadores_meta 

			WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_numIndicador = 2
					AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		</cfquery>

		<cfset metaSLNCorgao = rsMetaSLNCcardMensal.mediaSLNCmeta>
		<cfif metaSLNCorgao neq ''>
			<cfset metaSLNCorgaoFormatado = Replace(NumberFormat(metaSLNCorgao,0.0), ".", ",")>
		</cfif>

		<cfif resultSLNCdados.SLNC neq ''>
			<cfset mediaSLNC = NumberFormat(ROUND(resultSLNCdados.SLNC*10)/10,0.0)>
			<cfset mediaSLNCformatado = Replace(NumberFormat(mediaSLNC,0.0), ".", ",")>

			<cfset SLNCresultadoMeta = ROUND((mediaSLNC / metaSLNCorgao)*100*10)/10>

			<cfset SLNCresultadoMetaFormatado = Replace(NumberFormat(SLNCresultadoMeta,0.0), ".", ",")>


			<cfset 	infoRodape = '<span style="font-size:14px">SLNC = #mediaSLNCformatado#% (média do resultado do SLNC dos órgão subordinados)</span><br>
						<span style="font-size:14px">Meta = #metaSLNCorgaoFormatado#% (média das metas do SLNC dos órgãos subordinados)</span><br>'>
            <cfset objetoCFC = createObject("component", "pc_cfcIndicadores_modeloCard")>
			<cfset var cardSLNCmensal = objetoCFC.criarCardIndicador(
				tipoDeCard = 'bg-gradient-warning',
				siglaIndicador ='SLNC',
				descricaoIndicador = 'Solução de Não Conformidades',
				percentualIndicadorFormatado = mediaSLNCformatado,
				resultadoEmRelacaoMeta = SLNCresultadoMeta,
				resultadoEmRelacaoMetaFormatado = SLNCresultadoMetaFormatado,
				infoRodape = infoRodape,
				icone = 'fa fa-shopping-basket'

			)>
			<cfoutput>#cardSLNCmensal#</cfoutput>
		<cfelse>
			<cfoutput><h5 style="text-align:center">Sem dados para o indicador SLNC</cfoutput>
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




	<cffunction name="consultaIndicadorDGCI_mensal" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do DGCI">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
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
				AND pc_indOrgao_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla,pc_indOrgao_mcuOrgaoSubordinador,pc_orgaoSubordinador.pc_org_sigla
		</cfquery>
		<cfreturn #consulta_DGCI_mensal#>	
	
	</cffunction>

	<cffunction name="tabResumoDGCIorgaosResp_mensal" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do DGCI dos órgãos subordinadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfset var resultado = consultaIndicadorDGCI_mensal(ano=arguments.ano, mes=arguments.mes)>
	   
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
			<div id="divTabResumoDGCIorgaos" class="table-responsive">
				<table id="tabResumoDGCIorgaos" class="table table-bordered table-striped text-nowrap " style="width:350px; cursor:pointer">
					<cfoutput>
						
						<thead class="bg-gradient-warning" style="text-align: center;">
							<tr style="font-size:14px">
								<th colspan="8" style="padding:5px">DGCI - <span id="spanMesAno">#monthAsString(mes)#/#ano#</span></th>
							</tr>
							<tr style="font-size:14px">
								<th >Órgão</th>
								<th >PRCI %</th>
								<th >SLNC %</th>
								<th >DGCI %</th>
								<th >Meta %</th>
								<th >Resultado</th>
								<th >DGCI<br>Acumulado %</th>
								<th>Result. %<br>em Relação à Meta</th>
							</tr>
						</thead>
						<tbody>
							<cfoutput>
								<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->

									<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
										SELECT pc_indMeta_meta FROM pc_indicadores_meta 
										WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_numIndicador = 1
												AND pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
									</cfquery>
									<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
										SELECT pc_indMeta_meta FROM pc_indicadores_meta 
										WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_numIndicador = 2
												AND pc_indMeta_mcuOrgao = <cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
									</cfquery>

									
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#siglaOrgao# (#mcuOrgao#)</td>
										<cfif PRCI neq ''>
											<td>#NumberFormat(ROUND(PRCI*10)/10,0.0)#</td>
										<cfelse>
											<td>sem dados</td>
										</cfif>

										<cfif SLNC neq ''>
											<td>#NumberFormat(ROUND(SLNC*10)/10,0.0)#</td>
										<cfelse>
											<td>sem dados</td>
										</cfif>

										<td><strong>#NumberFormat(ROUND(DGCI*10)/10,0.0)#</strong></td>

										<cfset metaDGCIorgao =''>
										<cfif PRCI neq '' AND SLNC neq ''>
											<cfset metaDGCIorgao = NumberFormat(ROUND((rsMetaPRCI.pc_indMeta_meta*rsPRCIpeso.pc_indPeso_peso + rsMetaSLNC.pc_indMeta_meta*rsSLNCpeso.pc_indPeso_peso)*10)/10,0.0)>
										<cfelseif PRCI neq '' and SLNC eq ''>
											<cfset metaDGCIorgao = NumberFormat(ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10,0.0)>
										<cfelseif PRCI eq '' and SLNC neq ''>
											<cfset metaDGCIorgao = NumberFormat(ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10,0.0)>
										</cfif>
											
										
										
										<cfif metaDGCIorgao eq ''>
											<td>sem meta</td>
											<td>sem meta</td>
											<td><strong>#NumberFormat(ROUND(DGCIacumulado*10)/10,0.0)#</strong></td>
											<td>sem meta</td>
										<cfelse>	
											<td><strong>#metaDGCIorgao#</strong></td>
											<cfset resultMesEmRelacaoMeta =NumberFormat(ROUND(DGCI*10)/10,0.0)/metaDGCIorgao*100>
											<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
											<td><strong>#NumberFormat(ROUND(DGCIacumulado*10)/10,0.0)#</strong></td>
											<cfset resultAcumuladoEmRelacaoMeta =NumberFormat(ROUND(DGCIacumulado*10)/10,0.0)/metaDGCIorgao*100>
											<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
										</cfif>
										
										
										
									</tr>
								</cfloop>
							</cfoutput>
						</tbody>
						<tfoot >
							<tr>
								<th colspan="8" style="font-weight: normal; font-size: smaller;">
									<cfoutput>
										<li>DGCI = Desempenho Geral do Controle Interno = (PRCI x peso do PRCI) + (SLNC x peso do SLNC) = (PRCI x #rsPRCIpeso.pc_indPeso_peso#) + (SLNC x #rsSLNCpeso.pc_indPeso_peso#)</li>
										<li>Meta = (Meta PRCI x peso do PRCI) + (Meta do SLNC x peso SLNC) = (Meta PRCI x #rsPRCIpeso.pc_indPeso_peso#) + (Meta SLNC x #rsSLNCpeso.pc_indPeso_peso#)</li>
										Obs.: Caso não existam dados para o PRCI ou SLNC, os cálculos acima serão feitos apenas com os resultados e metas do indicador disponível, sem multiplicação pelo seu peso.
									</cfoutput>
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

	<cffunction name="cardDGCI_AcompMensal" access="remote" returntype="string" hint="cria o card com as informações dos resultados do DGCI para acompanhamento mensal">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		

		<cfquery name="resultDGCIdados" datasource="#application.dsn_processos#" timeout="120">
			SELECT 
				pc_indOrgao_mcuOrgao as mcuOrgaoResp,
				pc_orgaos.pc_org_sigla as siglaOrgaoResp,
				MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoMes, null)) as PRCI,
				MAX(IIF(pc_indOrgao_numIndicador = 2, pc_indOrgao_resultadoMes, null)) as SLNC,
				MAX(IIF(pc_indOrgao_numIndicador = 3, pc_indOrgao_resultadoMes, null)) as DGCI,
				MAX(IIF(pc_indOrgao_numIndicador = 3, pc_indOrgao_resultadoAcumulado, null)) as DGCIacumulado
			FROM 
				pc_indicadores_porOrgao
			INNER JOIN 
				pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			WHERE 
				pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador in(1,2,3)
				AND pc_indOrgao_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>


		<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
			SELECT pc_indMeta_meta as mediaPRCImeta FROM pc_indicadores_meta 

			WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_numIndicador = 1
					AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		</cfquery>	

      

		<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
			SELECT pc_indMeta_meta as mediaSLNCmeta FROM pc_indicadores_meta 

			WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
					AND pc_indMeta_numIndicador = 2
					AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		</cfquery>


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


		<cfset mediaMetaPRCIorgaos =rsMetaPRCI.mediaPRCImeta>
		<cfif mediaMetaPRCIorgaos neq ''>
			<cfset mediaMetaPRCIorgaosFormatado = Replace(NumberFormat(mediaMetaPRCIorgaos,0.0), ".", ",")>
		</cfif>
		<cfset mediaMetaSLNCorgaos =rsMetaSLNC.mediaSLNCmeta>
		<cfif mediaMetaSLNCorgaos neq ''>
			<cfset mediaMetaSLNCorgaosFormatado = Replace(NumberFormat(mediaMetaSLNCorgaos,0.0), ".", ",")>
		</cfif>

		<cfset metaDGCIorgao = rsMetaPRCI.mediaPRCImeta*rsPRCIpeso.pc_indPeso_peso + rsMetaSLNC.mediaSLNCmeta*rsSLNCpeso.pc_indPeso_peso>
		<cfif metaDGCIorgao neq ''>
			<cfset metaDGCIformatado = Replace(NumberFormat(metaDGCIorgao,0.0), ".", ",")>
		</cfif>
		<cfif resultDGCIdados.DGCI neq ''>
		    <cfif resultDGCIdados.PRCI neq ''>
				<cfset mediaPRCI = NumberFormat(ROUND(resultDGCIdados.PRCI*10)/10,0.0)>
				<cfset mediaPRCIformatado = Replace(NumberFormat(mediaPRCI,0.0), ".", ",")>
			</cfif>

			<cfif resultDGCIdados.SLNC neq ''>
				<cfset mediaSLNC = NumberFormat(ROUND(resultDGCIdados.SLNC*10)/10,0.0)>
				<cfset mediaSLNCformatado = Replace(NumberFormat(mediaSLNC,0.0), ".", ",")>
			</cfif>

			<cfset mediaDGCI = NumberFormat(ROUND(resultDGCIdados.DGCI*10)/10,0.0)>
			<cfset mediaDGCIformatado = Replace(NumberFormat(mediaDGCI,0.0), ".", ",")>

			<cfset DGCIresultadoMeta = ROUND((mediaDGCI / metaDGCIorgao)*100*10)/10>
			<cfset DGCIresultadoMetaFormatado = Replace(NumberFormat(DGCIresultadoMeta,0.0), ".", ",")>

			<cfif resultDGCIdados.PRCI neq '' AND resultDGCIdados.SLNC neq ''>
				<cfset formulaDGCI = '(PRCI  x peso PRCI) + (SLNC x peso SLNC) = (#mediaPRCIformatado# x #pesoPRCIformatado#) + (#mediaSLNCformatado# x #pesoSLNCformatado#)'>
				<cfset formulaMetaDGCI = '(Meta PRCI x peso PRCI) + (Meta SLNC x peso SLNC) = (#mediaMetaPRCIorgaosFormatado# x #pesoPRCIformatado#) + (#mediaMetaSLNCorgaosFormatado# x #pesoSLNCformatado#)'>
			<cfelseif resultDGCIdados.PRCI neq '' AND resultDGCIdados.SLNC eq ''>
				<cfset formulaDGCI = '(PRCI) = (#mediaPRCIformatado#)'>
				<cfset formulaMetaDGCI = '(Meta PRCI) = (#mediaMetaPRCIorgaosFormatado#)'>
			<cfelseif resultDGCIdados.PRCI eq '' AND resultDGCIdados.SLNC neq ''>
				<cfset formulaDGCI = '(SLNC) = (#mediaSLNCformatado#)'>
				<cfset formulaMetaDGCI = '(Meta SLNC) = (#mediaMetaSLNCorgaosFormatado#)'>
			<cfelse>
				<cfset formulaDGCI = 'sem dados'>
				<cfset formulaMetaDGCI = 'sem dados'>
			</cfif>

			<cfset infoRodape = '<span style="font-size:14px">DGCI = #mediaDGCIformatado#% ->#formulaDGCI#</span><br>
						<span style="font-size:14px">Meta = #metaDGCIformatado#% ->#formulaMetaDGCI#</span><br>'>
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
			
				<div style="display: flex;justify-content: center;color:##0083ca;"><h5>#application.rsUsuarioParametros.pc_org_sigla# - #monthAsString(mes)#/#ano#</h5></div>
				<div>#cardDGCImensal#</div>

			</cfoutput>
		<cfelse>
			<cfoutput><h5 style="text-align:center">Sem dados para o indicador DGCI</cfoutput>
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