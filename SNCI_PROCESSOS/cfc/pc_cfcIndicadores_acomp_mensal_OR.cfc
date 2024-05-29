<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	
	<!--Acompanhamento Mensal dos Órgãos Responsáveis (ÓRGÃOS SUBORDINADOS)-->

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
		
		<cfset resultado = consultaPRCIdetalhe_mensal(ano=arguments.ano, mes=arguments.mes)>	

		

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
											<cfloop query="resultado" >
											    <cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
													SELECT pc_indMeta_meta FROM pc_indicadores_meta 
													WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_numIndicador = 1
															AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
												</cfquery>
											
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultado.pc_indDados_numPosic#</td>
														<td>#resultado.siglaOrgaoAvaliado#</td>
														<td>#resultado.siglaOrgaoResp#</td>
														<td>#resultado.numProcessoSNCI#</td>
														<td >#resultado.item#</td>
														<td>#resultado.orientacao#</td>
														<cfif resultado.dataPrevista eq '1900-01-01' or resultado.dataPrevista eq ''>
															<td>NÃO INF.</td>
														<cfelse>
															<td>#dateFormat(resultado.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>
															<cfif resultado.pc_indDados_mcuOrgaoPosicEcontInterno eq 0 AND (resultado.numStatus eq 4 OR resultado.numStatus eq 5)>
																#dateFormat(resultado.dataPosicao, 'dd/mm/yyyy')#<br><span style="color:red">(dt. distrib.)</span>
															<cfelse>
																#dateFormat(resultado.dataPosicao, 'dd/mm/yyyy')#
															</cfif>
														</td>
														<td>#resultado.descricaoOrientacaoStatus#</td>
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
        <cfelse>
			<h5>Não há dados para exibir</h5>
		</cfif>

		<script language="JavaScript">
		   
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_PRCI_detalhamento_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
							title : tituloExcel + '_(gerado_em: _' + d + ')',
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
		<cfelse>
			<h5>Não há dados para exibir</h5>
		</cfif>
		<script language="JavaScript">
		   
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_SLNC_detalhamento_"+ periodoPorExtenso(parseInt($('input[name=mes]:checked').val()),parseInt($('input[name=ano]:checked').val()));
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
							title : tituloExcel + '_(gerado_em: _' + d + ')',
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




	<cffunction name="consultaIndicadores" access="remote" hint="gera a consulta para ser utilizadas nas cffunctions do PRCI">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
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

				AND mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		</cfquery>

		<cfreturn #consulta_todos#>
      
		

	</cffunction>
	


	<cffunction name="tabResumoPRCIorgaosResp_mensal" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do PRCI dos órgãos responsáveis">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes)>
       
	  	
		
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

								
									
									<!--- Adiciona cada linha à tabela --->
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#siglaOrgao# (#mcuOrgao#)</td>
										<td>#NumberFormat(TIDP,0)#</td>
										<td>#NumberFormat(TGI,0)#</td>
										<td><strong>#NumberFormat(ROUND(PRCI*10)/10,0.0)#</strong></td>
									
										<cfif metaPRCI eq ''>
											<td>sem meta</td>
										<cfelse>	
											<cfset metaPRCIorgao = NumberFormat(ROUND(metaPRCI*10)/10,0.0)>
											<td><strong>#metaPRCIorgao#</strong></td>
										</cfif>
										<cfif metaPRCI eq ''>
											<td>sem meta</td>
										<cfelseif PRCI eq ''>
											<td>sem dados</td>
										<cfelse>
											<cfset resultMesEmRelacaoMeta = atingPRCI>
											<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
										</cfif>

										<td>#NumberFormat(ROUND(PRCIacumulado*10)/10,0.0)#</td>
										
										<cfif metaPRCI eq ''>
											<td>sem meta</td>
										<cfelseif PRCI eq ''>
											<td>sem dados</td>
										<cfelse>
											<td >#resultMesEmRelacaoMeta#</span></td>
										</cfif>
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
		

		<cfset var resultPRCIdados = consultaIndicadores(ano=arguments.ano, mes=arguments.mes)>

		<cfif resultPRCIdados.recordcount neq 0>
			
			<cfset totalPRCI = NumberFormat(ROUND(resultPRCIdados.PRCI*10)/10,0.0)>
			<cfset totalPRCIformatado = Replace(NumberFormat(totalPRCI,0.0), ".", ",")>

			<cfset totalTIDP = ROUND(resultPRCIdados.TIDP)>
			<cfset totalTGI = ROUND(resultPRCIdados.TGI)>
			
			<cfset metaPRCIorgao = resultPRCIdados.metaPRCI>
			<cfif metaPRCIorgao neq ''>
				<cfset metaPRCIorgaoFormatado = Replace(NumberFormat(metaPRCIorgao,0.0), ".", ",")>
				<cfset PRCIresultadoMeta = resultPRCIdados.atingPRCI>
				<cfset PRCIresultadoMetaFormatado = Replace(NumberFormat(PRCIresultadoMeta,0.0), ".", ",")>
			<cfelse>
				<cfset PRCIresultadoMeta = ''>
				<cfset metaPRCIorgaoFormatado =0>
				<cfset PRCIresultadoMetaFormatado = 0>
			</cfif>
			

			<cfif metaPRCIorgaoFormatado neq 0>													
				<cfset 	infoRodape = '<span style="font-size:14px">PRCI = #totalPRCIformatado#% -> (TIDP÷TGI)x100 = (#totalTIDP#÷#totalTGI#)x100</span><br>
						<span style="font-size:14px">Meta = #metaPRCIorgaoFormatado#% </span><br>'>	
			<cfelse>
				<cfset 	infoRodape = '<span style="font-size:14px">PRCI = #totalPRCIformatado#% -> (TIDP÷TGI)x100 = (#totalTIDP#÷#totalTGI#)x100</span><br>
						<span style="font-size:14px">Meta = sem meta</span><br>'>
			</cfif>		
			
			<cfinvoke component="pc_cfcIndicadores_modeloCard" method="criarCardIndicador" returnvariable="cardPRCImensal">
				<cfinvokeargument name="tipoDeCard" value="bg-gradient-warning">
				<cfinvokeargument name="siglaIndicador" value="PRCI">
				<cfinvokeargument name="descricaoIndicador" value="Atendimento ao Prazo de Resposta">
				<cfinvokeargument name="percentualIndicadorFormatado" value="#totalPRCIformatado#">
				<cfinvokeargument name="resultadoEmRelacaoMeta" value="#PRCIresultadoMeta#">
				<cfinvokeargument name="resultadoEmRelacaoMetaFormatado" value="#PRCIresultadoMetaFormatado#">
				<cfinvokeargument name="infoRodape" value="#infoRodape#">
				<cfinvokeargument name="icone" value="fa fa-shopping-basket">
			</cfinvoke>


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


	<cffunction name="tabResumoSLNCorgaosResp_mensal" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do SLNC dos órgãos subordinadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes)>
       
	  	
		
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

									
									<!--- Adiciona cada linha à tabela --->
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#siglaOrgao# (#mcuOrgao#)</td>
										<td>#NumberFormat(QTSL,0)#</td>
										<td>#NumberFormat(QTNC,0)#</td>
										<td><strong>#NumberFormat(ROUND(SLNC*10)/10,0.0)#</strong></td>
										<cfset metaSLNCorgao = 0>
										<cfset resultMesEmRelacaoMeta =0>
										<cfset resultAcumuladoEmRelacaoMeta =0>
										<cfif metaSLNC eq ''>
											<td>sem meta</td>
										<cfelseif SLNC eq ''>
											<td>sem dados</td>
										<cfelse>
											<cfset resultMesEmRelacaoMeta = atingSLNC>
											<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
										</cfif>

										<td>#NumberFormat(ROUND(SLNCacumulado*10)/10,0.0)#</td>
										
										<cfif metaSLNC eq ''>
											<td>sem meta</td>
										<cfelseif SLNC eq ''>
											<td>sem dados</td>
										<cfelse>
											<td >#resultMesEmRelacaoMeta#</span></td>
										</cfif>
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
		
		<cfset var resultSLNCdados = consultaIndicadores(ano=arguments.ano, mes=arguments.mes)>

		<cfif resultSLNCdados.recordcount neq 0>
			
            <cfset totalSLNC = NumberFormat(ROUND(resultSLNCdados.SLNC*10)/10,0.0)>
			<cfset totalSLNCformatado = Replace(NumberFormat(totalSLNC,0.0), ".", ",")>

			<cfset totalQTSL = ROUND(resultSLNCdados.QTSL)>
			<cfset totalQTNC = ROUND(resultSLNCdados.QTNC)>

			<cfset metaSLNCorgao = resultSLNCdados.metaSLNC>
			<cfif metaSLNCorgao neq ''>
				<cfset metaSLNCorgaoFormatado = Replace(NumberFormat(metaSLNCorgao,0.0), ".", ",")>
				<cfset SLNCresultadoMeta = resultSLNCdados.atingSLNC>
				<cfset SLNCresultadoMetaFormatado = Replace(NumberFormat(SLNCresultadoMeta,0.0), ".", ",")>
			<cfelse>
			    <cfset metaSLNCorgaoFormatado =0>
				<cfset SLNCresultadoMeta = ''>
				<cfset SLNCresultadoMetaFormatado = 0>
			</cfif>

			
			

			<cfif metaSLNCorgaoFormatado neq 0>
				<cfset 	infoRodape = '<span style="font-size:14px">SLNC = #totalSLNCformatado#% -> (QTSL÷QTNC)x100 = (#totalQTSL#÷#totalQTNC#)x100</span><br>
						<span style="font-size:14px">Meta = #metaSLNCorgaoFormatado#% </span><br>'>
			<cfelse>
				<cfset 	infoRodape = '<span style="font-size:14px">SLNC = #totalSLNCformatado#% -> (QTSL÷QTNC)x100 = (#totalQTSL#÷#totalQTNC#)x100</span><br>
						<span style="font-size:14px">Meta = sem meta</span><br>'>
			</cfif>
			
			<cfinvoke component="pc_cfcIndicadores_modeloCard" method="criarCardIndicador" returnvariable="cardSLNCmensal">
				<cfinvokeargument name="tipoDeCard" value="bg-gradient-warning">
				<cfinvokeargument name="siglaIndicador" value="SLNC">
				<cfinvokeargument name="descricaoIndicador" value="Solução de Não Conformidades">
				<cfinvokeargument name="percentualIndicadorFormatado" value="#totalSLNCformatado#">
				<cfinvokeargument name="resultadoEmRelacaoMeta" value="#SLNCresultadoMeta#">
				<cfinvokeargument name="resultadoEmRelacaoMetaFormatado" value="#SLNCresultadoMetaFormatado#">
				<cfinvokeargument name="infoRodape" value="#infoRodape#">
				<cfinvokeargument name="icone" value="fa fa-shopping-basket">
			</cfinvoke>

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



	<cffunction name="tabResumoDGCIorgaosResp_mensal" access="remote" returntype="string" hint="cria tabela resumo com as informações dos resultados do DGCI dos órgãos subordinadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
		<cfset var resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes)>
	   
		
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

										<cfif metaPRCI neq '' AND metaSLNC neq ''>
											<cfif PRCI neq '' AND SLNC neq ''>
												<cfset metaDGCIorgao = NumberFormat(ROUND((metaPRCI*pesoPRCI + metaSLNC*pesoSLNC)*10)/10,0.0)>
											<cfelseif PRCI neq '' and SLNC eq ''>
												<cfset metaDGCIorgao = NumberFormat(ROUND(metaPRCI*10)/10,0.0)>
											<cfelseif PRCI eq '' and SLNC neq ''>
												<cfset metaDGCIorgao = NumberFormat(ROUND(metaSLNC*10)/10,0.0)>
											</cfif>
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
										<li>DGCI = Desempenho Geral do Controle Interno = (PRCI x peso do PRCI) + (SLNC x peso do SLNC) = (PRCI x #resultado.pesoPRCI#) + (SLNC x #resultado.pesoSLNC#)</li>
										<li>Meta = (Meta PRCI x peso do PRCI) + (Meta do SLNC x peso SLNC) = (Meta PRCI x #resultado.pesoPRCI#) + (Meta SLNC x #resultado.pesoSLNC#)</li>
										Obs.: Caso não existam dados para o PRCI ou SLNC, os cálculos acima serão feitos apenas com os resultados e metas do indicador disponível, sem multiplicação pelo seu peso.
									</cfoutput>
								</th>
							</tr>
						</tfoot>
					</cfoutput>
				</table>
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
		
		<cfset resultado = consultaIndicadores(ano=arguments.ano, mes=arguments.mes)>

		<cfif resultado.recordcount neq 0>	

		
			<cfset pesoPRCI = 0>
			<cfset pesoSLNC = 0>
			<cfif resultado.pesoPRCI neq ''>
				<cfset pesoPRCI = resultado.pesoPRCI>
				<cfset pesoPRCIformatado = Replace(pesoPRCI, ".", ",")>
			</cfif>
			<cfif resultado.pesoSLNC neq ''>
				<cfset pesoSLNC = resultado.pesoSLNC>
				<cfset pesoSLNCformatado = Replace(pesoSLNC, ".", ",")>
			</cfif>


			<cfset metaPRCIorgao =resultado.metaPRCI>
			<cfif metaPRCIorgao neq ''>
				<cfset metaPRCIorgaoFormatado = Replace(NumberFormat(metaPRCIorgao,0.0), ".", ",")>
			<cfelse>
				<cfset metaPRCIorgaoFormatado = 0>
			</cfif>
			<cfset metaSLNCorgao =resultado.metaSLNC>
			<cfif metaSLNCorgao neq ''>
				<cfset metaSLNCorgaoFormatado = Replace(NumberFormat(metaSLNCorgao,0.0), ".", ",")>
			<cfelse>
				<cfset metaSLNCorgaoFormatado = 0>
			</cfif>

			<cfset resultadoPRCI =''>
			<cfset resultadoPRCIformatado =''>
			<cfset resultadoSLNC =''>
			<cfset resultadoSLNCformatado =''>
			
			<cfif resultado.PRCI neq ''>
				<cfset resultadoPRCI = NumberFormat(ROUND(resultado.PRCI*10)/10,0.0)>
				<cfset resultadoPRCIformatado = Replace(NumberFormat(resultadoPRCI,0.0), ".", ",")>
			</cfif>

			<cfif resultado.SLNC neq ''>
				<cfset resultadoSLNC = NumberFormat(ROUND(resultado.SLNC*10)/10,0.0)>
				<cfset resultadoSLNCformatado = Replace(NumberFormat(resultadoSLNC,0.0), ".", ",")>
			</cfif>

			<cfset resultadoDGCI = NumberFormat(ROUND(resultado.DGCI*10)/10,0.0)>
			<cfset resultadoDGCIformatado = Replace(NumberFormat(resultadoDGCI,0.0), ".", ",")>

			<cfif metaPRCIorgao neq '' and  metaSLNCorgao neq ''>
				<cfset metaDGCIorgao = metaPRCIorgao*pesoPRCI + metaSLNCorgao*pesoSLNC>
				<cfset metaDGCIformatado = Replace(NumberFormat(metaDGCIorgao,0.0), ".", ",")>
				<cfset DGCIresultadoMeta = ROUND((resultadoDGCI / metaDGCIorgao)*100*10)/10>
				<cfset DGCIresultadoMetaFormatado = Replace(NumberFormat(DGCIresultadoMeta,0.0), ".", ",")>
			<cfelse>
				<cfset metaDGCIorgao = 0>
				<cfset metaDGCIformatado = 0>
				<cfset DGCIresultadoMeta = ''>
				<cfset DGCIresultadoMetaFormatado = 0>
			</cfif>

			
			<cfset infoRodapeResultado = ''>
			<cfset infoRodapeMeta = ''>

			<cfif resultadoPRCIformatado neq '' and resultadoSLNCformatado neq ''>
				<cfset infoRodapeResultado = '<span style="font-size:14px">DGCI = #resultadoDGCIformatado#% -> (PRCI  x peso PRCI) + (SLNC x peso SLNC) = (#resultadoPRCIformatado# x #pesoPRCIformatado#) + (#resultadoSLNCformatado# x #pesoSLNCformatado#)</span><br>'>
			<cfelseif resultadoPRCIformatado neq '' and resultadoSLNCformatado eq ''>
				<cfset infoRodapeResultado = '<span style="font-size:14px">DGCI = #resultadoDGCIformatado#% = PRCI</span><br>'>
			<cfelseif resultadoPRCIformatado eq '' and resultadoSLNCformatado neq ''>
				<cfset infoRodapeResultado = '<span style="font-size:14px">DGCI = #resultadoDGCIformatado#% = SLNC</span><br>'>
			<cfelse>
				<cfset infoRodapeResultado = '<span style="font-size:14px">DGCI = Sem dados para PRCI e SLNC</span><br>'>
			</cfif>


			<cfif metaPRCIorgaoFormatado neq 0 and metaSLNCorgaoFormatado neq 0>
					<cfset infoRodapeMeta = '<span style="font-size:14px">Meta = #metaDGCIformatado#% -> (Meta PRCI x peso PRCI) + (Meta SLNC x peso SLNC)= (#metaPRCIorgaoFormatado# x #pesoPRCIformatado#) + (#metaSLNCorgaoFormatado# x #pesoSLNCformatado#)</span><br>'>
			<cfelseif metaPRCIorgaoFormatado neq 0 and metaSLNCorgaoFormatado eq 0>
				<cfset infoRodapeMeta = '<span style="font-size:14px">Meta = #metaDGCIformatado#% = Meta PRCI</span><br>'>
			<cfelseif metaPRCIorgaoFormatado eq 0 and metaSLNCorgaoFormatado neq 0>
				<cfset infoRodapeMeta = '<span style="font-size:14px">Meta = #metaDGCIformatado#% = Meta SLNC</span><br>'>
			<cfelse>
				<cfset infoRodapeMeta = '<span style="font-size:14px">Meta = sem meta </span><br>'>
			</cfif>

			<cfset infoRodape = infoRodapeResultado & infoRodapeMeta>








			<cfinvoke component="pc_cfcIndicadores_modeloCard" method="criarCardIndicador" returnvariable="cardDGCImensal">
				<cfinvokeargument name="tipoDeCard" value="bg-gradient-info">
				<cfinvokeargument name="siglaIndicador" value="DGCI">
				<cfinvokeargument name="descricaoIndicador" value="Desempenho Geral do Controle Interno">
				<cfinvokeargument name="percentualIndicadorFormatado" value="#resultadoDGCIformatado#">
				<cfinvokeargument name="resultadoEmRelacaoMeta" value="#DGCIresultadoMeta#">
				<cfinvokeargument name="resultadoEmRelacaoMetaFormatado" value="#DGCIresultadoMetaFormatado#">
				<cfinvokeargument name="infoRodape" value="#infoRodape#">
				<cfinvokeargument name="icone" value="fa fa-chart-line">
			</cfinvoke>

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