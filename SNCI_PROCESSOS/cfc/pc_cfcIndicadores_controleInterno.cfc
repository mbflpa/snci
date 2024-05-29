<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	


	<cffunction name="consultaIndicadores" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do PRCI">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfargument name="paraOrgaoSubordinador" type="numeric" required="false" default="0" />
		<cfargument name="mes_a_mes" type="numeric" required="false" default="0" />

		<cfquery name="consulta_todos" datasource="#application.dsn_processos#" timeout="120">
			SELECT * FROM pc_view_resultadoIndicadores
			
			WHERE 
				ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
                <cfif arguments.mes_a_mes eq 1>
					AND mes <= <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
				<cfelse>
					AND mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
				</cfif>

				AND paraOrgaoSubordinador = <cfqueryparam value="#arguments.paraOrgaoSubordinador#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn #consulta_todos#>
      
		

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
		 $(document).ready(function(){
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()
			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel
			
			
			let tituloExcel_PRCI ="SNCI_Consulta_PRCI_detalhamento_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
						title : tituloExcel_PRCI + '_(gerado_em: _' + d + ')',
						className: 'btExcel',
					}

				]
				

			})
		
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
			
			
			var tituloExcel_SLNC ="SNCI_Consulta_SLNC_detalhamento_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));;

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
							title : tituloExcel_SLNC + '_(gerado_em: _' + d + ')',
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
			var tituloExcel_PRCIacumulado ="SNCI_Consulta_PRCI_detalhamentoAcumulado_janeiro_a_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
						title : tituloExcel_PRCIacumulado + '_(gerado_em: _' + d + ')',
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
			var tituloExcel_SLNCacumulado ="SNCI_Consulta_SLNC_detalhamento_acumulado_janeiro_a_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));

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
							title : tituloExcel_SLNCacumulado  + '_(gerado_em: _' + d + ')',
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
		
    	<cfset var resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes,paraOrgaoSubordinador=1)>

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
												<th>Result. %<br>em Relação à Meta Mensal</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning">PRCI<br>Acumulado %</th>
												<th>Resultado Acumulado</th>
												
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													
													
													<!--- Adiciona cada linha à tabela --->
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td style="text-align: left;">#siglaOrgao# (#mcuOrgao#)</td>
														<cfif PRCI eq ''>
															<td>sem dados</td>
														<cfelse>	
															<td><strong>#NumberFormat(ROUND(PRCI*10)/10,0.0)#</strong></td>
														</cfif>
														<cfif metaPRCI eq ''>
															<td>sem meta</td>
															<cfset resultMesEmRelacaoMeta = "sem meta">
															<cfset resultAcumuladoEmRelacaoMeta = "sem meta">
														<cfelse>
														    <cfset metaPRCIorgao = NumberFormat(ROUND(metaPRCI*10)/10,0.0)>
															<cfif metaPRCIorgao neq '' or  metaPRCIorgao neq 0>
                                                                <cfif atingPRCI neq ''>
																 	<cfset resultMesEmRelacaoMeta = atingPRCI>
																</cfif>
																<cfif PRCIacumulado neq ''>
																	<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((PRCIacumulado/metaPRCIorgao)*100*10)/10,0.0)>	
																</cfif>
															</cfif>
															<td>#metaPRCIorgao#</td>
														</cfif>

														<cfif PRCI neq ''>
															<td>#resultMesEmRelacaoMeta#</td>
														<cfelse>
															<td>sem dados</td>
														</cfif>

														<cfif PRCI neq ''>
															<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
														<cfelse>
															<td>sem dados</td>
														</cfif>

														<cfif PRCIacumulado neq ''>
															<td><strong>#NumberFormat(ROUND(PRCIacumulado*10)/10,0.0)#</strong></td>
														<cfelse>
															<td>sem dados</td>
														</cfif>
														<cfif PRCIacumulado neq ''>
															<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
														<cfelse>
															<td>sem dados</td>
														</cfif>

														
														
														
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

			
			var tituloExcel_PRCIporOrgaoSubordinador ="SNCI_Consulta_PRCI_porOrgaoSubordinador_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
						title : tituloExcel_PRCIporOrgaoSubordinador + '_(gerado_em: _' + d + ')',
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
		
		<cfset var resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes,paraOrgaoSubordinador=1)>

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
												<th>Result. %<br>em Relação à Meta Mensal</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning">SLNC<br>Acumulado %</th>
												<th>Resultado Acumulado</th>
												
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													

													<!--- Adiciona cada linha à tabela --->
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td style="text-align: left;"  >#siglaOrgao# (#mcuOrgao#)</td>
														<cfif resultado.SLNC eq ''>
															<td>sem dados</td>
														<cfelse>
															<td><strong>#NumberFormat(ROUND(resultado.SLNC*10)/10,0.0)#</strong></td>
														</cfif>
														<cfif metaSLNC eq ''>
															<td>sem meta</td>
															<cfset resultMesEmRelacaoMeta = "sem meta">
															<cfset resultAcumuladoEmRelacaoMeta = "sem meta">
															<td>sem meta</td>
														<cfelse>
														    <cfset metaSLNCorgao = NumberFormat(ROUND(metaSLNC*10)/10,0.0)>
															<cfif atingSLNC neq ''>
																<cfset resultMesEmRelacaoMeta = atingSLNC>
																<cfset resultAcumuladoEmRelacaoMeta = NumberFormat(ROUND((SLNCacumulado/metaSLNCorgao)*100*10)/10,0.0)>	
															
															</cfif>
															<td>#metaSLNCorgao#</td>
															<td>#resultMesEmRelacaoMeta#</td>
														</cfif>
														<cfif resultado.SLNC eq ''>
															<td>sem dados</td>
														<cfelse>
															<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
														</cfif>

														<cfif resultado.SLNC eq ''>
															<td>sem dados</td>
															<td>sem dados</td>
														<cfelse>
															<td><strong>#NumberFormat(ROUND(SLNCacumulado*10)/10,0.0)#</strong></td>
															<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>
															
														</cfif>

														

														
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

			
			var tituloExcel_SLNCporOrgaoSubordinador ="SNCI_Consulta_SLNC_porOrgaoSubordinador_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
							title : tituloExcel_SLNCporOrgaoSubordinador + '_(gerado_em: _' + d + ')',
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
		
		<cfset var resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes,paraOrgaoSubordinador=1)>


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
													<span style="font-size: 9px">(PRCI * #resultado.pesoPRCI#) + (SLNC * #resultado.pesoSLNC#)</span>
												</th>
												<th >Meta %</th>
												<th>Result. %<br>em Relação à Meta Mensal</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning" style="border-left:1px solid ##000;border-right:1px solid ##000;border-top:1px solid ##000;text-align: center;">DGCI<br>Acumulado</th>
												<th>Resultado Acumulado</th>
												
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													

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
														
														
														<cfif metaPRCI neq '' and metaSLNC neq ''>
															<cfset metaDGCIorgao = metaDGCI>
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

														<cfif atingDGCI neq ''>
															<cfset resultMesEmRelacaoMeta = atingDGCI>
															<td>#resultMesEmRelacaoMeta#</td>
															<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
														<cfelse>
														    <cfset resultMesEmRelacaoMeta ='sem meta'>
															<td style="color:red">sem meta</td>
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
														
													</tr>
												</cfloop>
											</cfoutput>
										</tbody>
										<tfoot >
											<tr>
												<th colspan="9" style="font-weight: normal; font-size: smaller;">
												    <li>DGCI % = (PRCI x peso PRCI) + (SLNC x peso SLNC) -> Não existindo dados para o SLNC, a fórmula será DGCI % = PRCI. Não existindo dados para o PRCI, a fórmula será DGCI % = SLNC; </li>
													<li>META % = (meta PRCI x peso PRCI) + (meta SLNC x peso SLNC)</li>
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

			
			var tituloExcel_DGCIporOrgaoSubordinador ="SNCI_Consulta_DGCI_porOrgaoSubordinador_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
							title : tituloExcel_DGCIporOrgaoSubordinador + '_(gerado_em: _' + d + ')',
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
		
		<cfset var resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes)>

		

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
													<span style="font-size: 9px">(PRCI * #resultado.pesoPRCI#) + (SLNC * #resultado.pesoSLNC#)</span>
												</th>
												<th >Meta %</th>
												<th>Result. %<br>em Relação à Meta Mensal</th>
												<th >Resultado</th>
												<th class="bg-gradient-warning" style="border-left:1px solid ##000;border-right:1px solid ##000;border-top:1px solid ##000;text-align: center;">DGCI<br>Acumulado</th>
												<th>Resultado Acumulado</th>
												
											</tr>
										</thead>
										<tbody>
											<cfoutput>
												<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
													


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
														
														<cfif metaPRCI neq ''>
															<cfset metaPRCI = NumberFormat(ROUND(metaPRCI*10)/10,0.0)>
														</cfif>

														<cfif metaSLNC neq ''>
															<cfset metaSLNC = NumberFormat(ROUND(metaSLNC*10)/10,0.0)>
														</cfif>
														
														<cfif metaPRCI neq '' and metaSLNC neq ''>
															<cfset metaDGCIorgao = metaDGCI>
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

														<cfif atingDGCI neq ''>
															<cfset resultMesEmRelacaoMeta = atingDGCI>
															<td>#resultMesEmRelacaoMeta#</td>
															<td >
																<span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span>
															</td>
														<cfelse>
															<td style="color:red">sem meta</td>
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



														
													</tr>
												</cfloop>
											</cfoutput>
										</tbody>
										<tfoot >
											<tr>
												<th colspan="10" style="font-weight: normal; font-size: smaller;">
												    <li>DGCI % = (PRCI x peso PRCI) + (SLNC x peso SLNC) -> Não existindo dados para o SLNC, a formula será DGCI % = PRCI. Não existindo dados para o PRCI, a formula será DGCI % = SLNC; </li>
													<li>META % = (meta PRCI x peso PRCI) + (meta SLNC x peso SLNC)</li>
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
			
			var tituloExcel_DGCIporOrgaoResponsavel ="SNCI_Consulta_DGCI_porOrgaoResponsavel_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
						title : tituloExcel_DGCIporOrgaoResponsavel + '_(gerado_em: _' + d + ')',
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
		
		<cfset var resultado_Mes_a_Mes = consultaIndicadores(ano=arguments.ano, mes=arguments.mes, paraOrgaoSubordinador=1, mes_a_mes=1)>

		<cfquery name="resultadoECTmes" dbtype="query"  timeout="120">
			SELECT  mes
					,AVG(DGCI) AS media_resultadoMes
					,AVG(DGCIacumulado) AS media_resultadoAcumulado
			FROM resultado_Mes_a_Mes
			GROUP BY mes
			ORDER BY mes
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
											<cfoutput query="resultadoECTmes" group="mes">
											

												<cfquery name="mediaMetaDGCImes" dbtype="query"  timeout="120">
													SELECT AVG(metaDGCI) AS mediaDGCI FROM resultado_Mes_a_Mes
													WHERE mes = <cfqueryparam value="#resultadoECTmes.mes#" cfsqltype="cf_sql_integer">
													and metaDGCI IS NOT NULL
												</cfquery>	

												<tr style="font-size:12px;text-align: center;">
													<td>#monthAsString(resultadoECTmes.mes)#</td>
													
													<td><strong>#Replace(NumberFormat(ROUND(media_resultadoMes*10)/10,0.0),',','.')#</strong></td>
													<cfif mediaMetaDGCImes.recordcount neq 0>
														<cfset metaDGCI = mediaMetaDGCImes.mediaDGCI>
														<td>#NumberFormat(ROUND(metaDGCI*10)/10,0.0)#</td>
													<cfelse>
														<cfset metaDGCI = 0>
														<td>SEM META</td>
													</cfif>
									
													

													<cfif Replace(ROUND(media_resultadoMes*10)/10,',','.') gt  metaDGCI and  metaDGCI neq 0>
														<td style="color: blue;"><span class="statusOrientacoes" style="background:##0083CA;color:##fff;">ACIMA DO ESPERADO</span></td>
													<cfelseif Replace(ROUND(media_resultadoMes*10)/10,',','.') lt  metaDGCI and  metaDGCI neq 0>
														<td ><span class="statusOrientacoes" style="background:##dc3545;color:##fff;">ABAIXO DO ESPERADO</span></td>	
													<cfelseif Replace(ROUND(media_resultadoMes*10)/10,',','.') eq  metaDGCI and  metaDGCI neq 0>
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

		<cfset var resultado_Mes = consultaIndicadores(ano=arguments.ano, mes=arguments.mes, paraOrgaoSubordinador=1)>
		
		<cfquery name="resultado_DGCI_ECT_mes" dbtype="query"  timeout="120">
			SELECT	AVG(DGCI) AS mediaDGCI FROM resultado_Mes
		</cfquery>

		<cfif resultado_DGCI_ECT_mes.mediaDGCI neq ''>
		    <cfset mediaDGCI  =NumberFormat(ROUND(resultado_DGCI_ECT_mes.mediaDGCI*10)/10,0.0)>
			<cfset mediaDGCIformatado = REPLACE(NumberFormat(ROUND(resultado_DGCI_ECT_mes.mediaDGCI*10)/10,0.0), '.', ',')>
		<cfelse>
			<cfset mediaDGCI = 'sem dados'>
			<cfset mediaDGCIformatado = 'sem dados'>
		</cfif>


		<cfquery name="mediaMetaDGCImes" dbtype="query"  timeout="120">
			SELECT	AVG(metaDGCI) AS mediaMetaDGCI FROM resultado_Mes
			WHERE metaDGCI IS NOT NULL
		</cfquery>

		<cfif mediaMetaDGCImes.recordcount neq 0>
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
		
		<cfinvoke component="pc_cfcIndicadores_modeloCard" method="criarCardIndicador" returnvariable="cardDGCImensal">
			<cfinvokeargument name="tipoDeCard" value="bg-gradient-info">
			<cfinvokeargument name="siglaIndicador" value="DGCI">
			<cfinvokeargument name="descricaoIndicador" value="Desempenho Geral do Controle Interno">
			<cfinvokeargument name="percentualIndicadorFormatado" value="#mediaDGCIformatado#">
			<cfinvokeargument name="resultadoEmRelacaoMeta" value="#DGCIresultadoMeta#">
			<cfinvokeargument name="resultadoEmRelacaoMetaFormatado" value="#DGCIresultadoMetaFormatado#">
			<cfinvokeargument name="infoRodape" value="#infoRodape#">
			<cfinvokeargument name="icone" value="fa fa-chart-line">
		</cfinvoke>

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

		<cfset var resultado_Mes_a_Mes = consultaIndicadores(ano=arguments.ano, mes=arguments.mes, paraOrgaoSubordinador=1, mes_a_mes=1)>
     
	   <cfquery name="resultadoECTmes" dbtype="query"  timeout="120">
			SELECT  mes
					,AVG(DGCI) AS media_resultadoMes
				FROM resultado_Mes_a_Mes
			GROUP BY mes
			ORDER BY mes
		</cfquery>

		<cfquery name="metaECTmes" dbtype="query"  timeout="120">
			SELECT  mes
					,AVG(metaDGCI) AS mediaMetaDGCI
			FROM resultado_Mes_a_Mes
			WHERE metaDGCI IS NOT NULL
			GROUP BY mes
			ORDER BY mes
		</cfquery>

		<cfquery name="resultado_DGCI_ECT_mes" dbtype="query"  timeout="120">
			SELECT AVG(media_resultadoMes) AS mediaDGCIano
			FROM resultadoECTmes
		</cfquery>

		<cfset mediaDGCIano = ROUND(resultado_DGCI_ECT_mes.mediaDGCIano*10)/10>
        <cfset mediaDGCIanoformatado = REPLACE(NumberFormat(mediaDGCIano,0.0), '.', ',')>

		<cfif metaECTmes.recordcount neq 0>
			<cfquery name="mediaMeta_DGCI_ECT_mes" dbtype="query"  timeout="120">
				SELECT AVG(mediaMetaDGCI) AS mediaMetaDGCIano
				FROM metaECTmes
			</cfquery>
			<cfset mediaMetaDGCI = NumberFormat(ROUND(mediaMeta_DGCI_ECT_mes.mediaMetaDGCIano*10)/10,0.0)>
			<cfset mediaMetaDGCIFormatado = REPLACE(mediaMetaDGCI, '.', ',')>
			<cfset DGCIresultadoMeta = NumberFormat(ROUND((mediaDGCIano/mediaMetaDGCI)*100*10)/10,0.0)>
			<cfset DGCIresultadoMetaFormatado = REPLACE(DGCIresultadoMeta, '.', ',')>
		<cfelse>
			<cfset mediaMetaDGCI = 'sem meta'>
			<cfset mediaMetaDGCIFormatado = 'sem meta'>
			<cfset DGCIresultadoMeta = 'sem meta'>
			<cfset DGCIresultadoMetaFormatado = ''>
		</cfif>


		<cfset infoRodape = '<span style="font-size:14px">DGCI = #mediaDGCIanoformatado#% (média dos resultados mensais do DGCI)</span><br>
					<span style="font-size:14px">Meta = #mediaMetaDGCIFormatado#% (média das metas mensais do DGCI)</span><br>'>
		<!--- Chama o método criarCardIndicador do componente pc_cfcIndicadores_modeloCard --->
		<cfinvoke component="pc_cfcIndicadores_modeloCard" method="criarCardIndicador" returnvariable="cardDGCImensal">
			<cfinvokeargument name="tipoDeCard" value="bg-gradient-info">
			<cfinvokeargument name="siglaIndicador" value="DGCI">
			<cfinvokeargument name="descricaoIndicador" value="Desempenho Geral do Controle Interno">
			<cfinvokeargument name="percentualIndicadorFormatado" value="#mediaDGCIanoformatado#">
			<cfinvokeargument name="resultadoEmRelacaoMeta" value="#DGCIresultadoMeta#">
			<cfinvokeargument name="resultadoEmRelacaoMetaFormatado" value="#DGCIresultadoMetaFormatado#">
			<cfinvokeargument name="infoRodape" value="#infoRodape#">
			<cfinvokeargument name="icone" value="fa fa-chart-line">
		</cfinvoke>
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