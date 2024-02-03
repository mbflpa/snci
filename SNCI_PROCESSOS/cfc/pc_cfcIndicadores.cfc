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


	<cffunction name="consultaIndicadorPRCI"   access="remote" hint="gera a consulta para página de indicadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_Orientacao_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				CASE
					WHEN pc_aval_posic_dataPrevistaResp < GETDATE() THEN 'PENDENTE'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus,

				CASE
					WHEN pc_aval_posic_dataPrevistaResp < GETDATE() THEN 'FP'
					ELSE 'DP'
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
					pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_orientacao_mcu_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_orientacao_mcu_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>

		<cfquery name="rs_Orientacao_Respondida" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
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
				AND (
					pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_orientacao_mcu_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_orientacao_mcu_orgaoResp IN (#mcusHeranca#)</cfif>
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

	<cffunction name="tabPRCIDetalhe" access="remote" hint="outra função que utiliza tabIndicadores">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorPRCI(ano=arguments.ano, mes=arguments.mes)>

      
		<cfset totalDP = 0 /> 
		<cfset totalFP = 0 /> 
		<cfset orgaos = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset dps = {}> <!-- Define a variável dps como um objeto vazio -->
		<cfset fps = {}> <!-- Define a variável fps como um objeto vazio -->

		<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset totalDP++> <!-- Se a condição for verdadeira, incrementa a variável totalDP em 1 -->
			<cfelseif Prazo eq 'FP'> <!-- Verifica se o valor da coluna Prazo é igual a 'FP' -->
				<cfset totalFP++> <!-- Se a condição for verdadeira, incrementa a variável totalFP em 1 -->
			</cfif>
			<cfif not StructKeyExists(orgaos, orgaoResp)> <!-- Verifica se a chave orgaoResp não existe no objeto orgaos -->
				<cfset orgaos[orgaoResp] = 1> <!-- Se a condição for verdadeira, define a chave orgaoResp no objeto orgaos como 1 -->
				<cfset dps[orgaoResp] = 0> <!-- Define a chave orgaoResp no objeto dps como 0 -->
				<cfset fps[orgaoResp] = 0> <!-- Define a chave orgaoResp no objeto fps como 0 -->
			<cfelse>
				<cfset orgaos[orgaoResp]++> <!-- Incrementa a chave orgaoResp no objeto orgaos em 1 -->
			</cfif>
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset dps[orgaoResp]++> <!-- Se a condição for verdadeira, incrementa a chave orgaoResp no objeto dps em 1 -->
			<cfelseif Prazo eq 'FP'> <!-- Verifica se o valor da coluna Prazo é igual a 'FP' -->
				<cfset fps[orgaoResp]++> <!-- Se a condição for verdadeira, incrementa a chave orgaoResp no objeto fps em 1 -->
			</cfif>
		</cfloop>

		<style>
.dataTables_wrapper {
    width: 100%; /* ou a largura desejada */
    margin: 0 auto;
}
		</style>
	

		<div class="row" style="width: 100%;">
						
			<div class="col-12">
				<div class="card" >
					
					<!-- card-body -->
					<div class="card-body" style="margin-bottom:80px">
						<cfif #resultado.recordcount# eq 0 >
							<h5 align="center">Nenhuma informação foi localizada para o cálculo do PRCI do órgão <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput>.</h5>
						<cfelse>
							<cfoutput><h5 style="color:##2581c8;text-align: center;">Dados utilizados no cálculo do <strong>PRCI</strong> (Atendimento ao Prazo de Resposta): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
						
						    <div class="table-responsive">
								<table id="tabPRCIdetalhe" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
									
									<thead style="background: #0083ca;color:#fff">
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
									<!--- Imprime os resultados ou faça o que desejar com eles --->
									<cfoutput>
										<cfset totalGeral = resultado.recordcount />
										<!--- Calcula a porcentagem --->
										<cfset percentualDP = (totalDP / totalGeral) * 100 />
										<!--- Formata o percentualDP com duas casas decimais --->
										<cfset percentualDPFormatado = NumberFormat(percentualDP, '0.0') />
										

										<div id="divResultPRCI" class="col-md-4 col-sm-4 col-4">
											<div class="info-box bg-gradient-warning">
												<span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

												<div class="info-box-content">
													<span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:22px">PRCI</font></font></span>
													<span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong>#percentualDPFormatado#%</strong></font></font></span>

													<div class="progress">
														<div class="progress-bar" style="width: #percentualDPFormatado#%"></div>
													</div>
													<span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
														<span style="font-size:14px">PRCI = TIDP/TGI</span><br>
														<span style="font-size:14px">TIDP (Posic. dentro do prazo (DP))= #totalDP#</span><br>
														<span style="font-size:14px">TGI (Total de Posicionamentos)= #totalGeral# </span>

													</font></font></span>
												</div>
												<!-- /.info-box-content -->
											</div>
											<!-- /.info-box -->
										</div>
										
									</cfoutput>

								</table>
							</div>

							<cfset totalOrgaosResp = StructCount(orgaos)> <!-- Conta a quantidade de orgaoResp -->
							
						    <cfif totalOrgaosResp gt 1>
								<table id="tabResumoPRCI" class="table table-bordered table-striped text-nowrap" style="width:500px; margin-top:30px;cursor:pointer">
									<cfoutput>
										<thead style="background: ##489b72;color:##fff;text-align: center;">
											<tr style="font-size:14px">
												<th colspan="4" style="padding:5px!important;">RESUMO</th>
											</tr>
											<tr style="font-size:14px">
												<th style="padding:5px!important;">Órgão</th>
												<th style="padding:5px!important;">DP</th>
												<th style="padding:5px!important;">FP</th>
												<th style="padding:5px!important;">PRCI</th>
											</tr>
										</thead>
										<tbody>
											<cfset prcisOrdenado = StructSort(orgaos, "text", "asc")>
											<cfloop array="#prcisOrdenado#" index="orgao">
												<cfif orgaos[orgao] eq 0>
													<cfset percentualDP = 0>
												<cfelse>
													<cfset percentualDP = (dps[orgao] / orgaos[orgao]) * 100>
												</cfif>
												<cfset percentualDPFormatado = NumberFormat(percentualDP, '0.0')>

												<!--- Adiciona cada linha à tabela --->
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#orgao#</td>
													<td>#dps[orgao]#</td>
													<td>#fps[orgao]#</td>
													<td>#percentualDPFormatado#%</td>
												</tr>
											</cfloop>
										</tbody>
									</cfoutput>
								</table>

														 
   
	
							</cfif>





							
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
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_PRCI_Detalamento_";
				var colunasMostrar = [1,2,8,10];


				const tabPRCIdetalhamento = $('#tabPRCIdetalhe').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					// dom: 
					// 			"<'row'<'col-sm-4 dtsp-verticalContainer'<'dtsp-verticalPanes'P><'dtsp-dataTable'Bf>><'col-sm-8 text-left'p>>" +
					// 			"<'col-sm-12 text-left'i>" +
					// 			"<'row'<'col-sm-12'tr>>" ,
					dom:   "<'row'<'col-sm-4'B><'col-sm-4'p><'col-sm-4 text-right'i>>" ,

							
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]
					

				})
 
				


			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				$('#tabResumoPRCI').DataTable({
					order: [[3, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
       				info: false, // Remove a exibição da quantidade de registros
					searching: false // Remove o campo de busca
				});

				
			});
		</script>

	</cffunction>

	<cffunction name="consultaIndicadorSLNC"   access="remote" hint="gera a consulta para página de indicadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<!--<cfquery name="rs_solucionados_tratamento_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
				pc_aval_orientacao_distribuido as distribuido,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_orientacao_status_datahora) as dataPosicao,
				pc_aval_orientacao_id as orientacao,
				pc_aval_orientacao_dataPrevistaResp as dataPrevista,
				pc_aval_orientacao_status as status,
				CASE
					WHEN pc_aval_orientacao_dataPrevistaResp < GETDATE() AND  pc_aval_orientacao_status=5 THEN 'PENDENTE'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus

			FROM pc_avaliacao_orientacoes
           
            INNER JOIN pc_orgaos as orgaoResp ON orgaoResp.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
            INNER JOIN pc_avaliacoes ON pc_avaliacoes.pc_aval_id = pc_aval_orientacao_num_aval
            INNER JOIN pc_processos ON pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo
            INNER JOIN pc_orgaos as orgaoAvaliado ON orgaoAvaliado.pc_org_mcu = pc_num_orgao_avaliado
			INNER JOIN pc_orientacao_status ON pc_orientacao_status.pc_orientacao_status_id = pc_aval_orientacao_status
            WHERE pc_aval_orientacao_status IN (5,6)
                AND (
                    pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
                    OR pc_aval_orientacao_mcu_orgaoResp IN (
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
                    <cfif mcusHeranca neq ''> OR pc_aval_orientacao_mcu_orgaoResp IN (#mcusHeranca#)</cfif>
                ) 
                 AND pc_aval_orientacao_status_datahora 
				BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">

		
					
		</cfquery>-->

		<cfquery name="rs_solucionados_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
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
					pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp as orgaoResponsavelMCU,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
				WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			LEFT JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.orgaoResponsavelMCU = orgaoResp.pc_org_mcu
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
				AND (pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_orientacao_mcu_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_orientacao_mcu_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora
				BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>


		<cfquery name="rs_tratamento_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status as status,
				CASE
					WHEN pc_aval_posic_dataPrevistaResp < GETDATE() AND pc_aval_posic_status = 5 THEN 'PENDENTE'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus

			FROM (
				SELECT
					pc_aval_posic_id,
					pc_aval_posic_num_orientacao,
					pc_aval_posic_status,
					pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp as orgaoResponsavelMCU,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
				WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.orgaoResponsavelMCU = orgaoResp.pc_org_mcu
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
					pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_orientacao_mcu_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_orientacao_mcu_orgaoResp IN (#mcusHeranca#)</cfif>
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




	

	<cffunction name="tabSLNCDetalhe" access="remote" hint="outra função que utiliza tabIndicadores">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultadoSLNC = consultaIndicadorSLNC(ano=arguments.ano, mes=arguments.mes)>

		<cfset totalSolucionado = 0 /> 
		<cfset orgaos = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset solucionados = {}> <!-- Define a variável solucionados como um objeto vazio -->
		

		<cfloop query="resultadoSLNC"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			<cfif status eq 6> 
				<cfset totalSolucionado++> 
			</cfif>
			<cfif not StructKeyExists(orgaos, orgaoResp)>
				<cfset orgaos[orgaoResp] = 1> 
				<cfset solucionados[orgaoResp] = 0> 
			<cfelse>
				<cfset orgaos[orgaoResp]++> 
			</cfif>
			<cfif status eq 6> 
				<cfset solucionados[orgaoResp]++> 
			</cfif>
		</cfloop>

		
	

		<div class="row" style="width: 100%;">
						
			<div class="col-12">
				<div class="card" >
					
					<!-- card-body -->
					<div class="card-body" style="margin-bottom:80px">
						<cfif #resultadoSLNC.recordcount# eq 0 >
							<h5 align="center">Nenhuma informação foi localizada para o cálculo do SLNC do órgão <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput>.</h5>
						<cfelse>
							<cfoutput><h5 style="color:##2581c8;text-align: center;">Dados utilizados no cálculo do <strong>SLNC</strong> (Solução de Não Conformidades): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
						
							<div class="table-responsive">
								<table id="tabSLNCdetalhe" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
									
									<thead style="background: #0083ca;color:#fff">
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
								
									<cfoutput>
										<cfset totalGeral = resultadoSLNC.recordcount />
										<cfif totalGeral eq 0>
											<cfset percentualSolucionado = 0 />
										<cfelse>
											<cfset percentualSolucionado = (totalSolucionado / totalGeral *100) />
										</cfif>
										
							
										<cfset percentualSolucionadoFormatado = NumberFormat(percentualSolucionado, '0.0') />
										
										<div id="divResultSLNC" class="col-md-6 col-sm-6 col-12">
											<div class="info-box bg-gradient-warning">
												<span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

												<div class="info-box-content">
													<span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:22px">SLNC</font></font></span>
													<span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong>#percentualSolucionadoFormatado#%</strong></font></font></span>

													<div class="progress">
													<div class="progress-bar" style="width: #percentualSolucionadoFormatado#%"></div>
													</div>
													<span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
														<span style="font-size:14px">SLNC = QTSL/QTNC x 100</span><br>
														<span style="font-size:14px">QTSL (Quant. Orientações Solucionadas)= #totalSolucionado#</span><br>
														<span style="font-size:14px">QTNC (Quant. Orientações Registradas )= #totalGeral#</span>
													</font></font></span>
												</div>
												<!-- /.info-box-content -->
											</div>
											<!-- /.info-box -->
										</div>
										
									</cfoutput>

								</table>
							</div>

							<cfset totalOrgaosResp = StructCount(orgaos)> 
							
						    <cfif totalOrgaosResp gt 1>
								<table id="tabResumoSLNC" class="table table-bordered table-striped text-nowrap" style="width:500px; margin-top:30px;cursor:pointer">
									<cfoutput>
										<thead style="background: ##489b72;color:##fff;text-align: center;">
											<tr style="font-size:14px">
												<th colspan="4" style="padding:5px!important;">RESUMO</th>
											</tr>
											<tr style="font-size:14px">
												<th style="padding:5px!important;">Órgão</th>
												<th style="padding:5px!important;">Solucionadas</th>
												<th style="padding:5px!important;">Total de Orientações</th>
												<th style="padding:5px!important;">SLNC</th>
											</tr>
										</thead>
										<tbody>
											
											<cfset slncOrdenado = StructSort(orgaos, "text", "asc")>
											<cfloop array="#slncOrdenado#" index="orgao">
												<cfset percentualSolucionado = (solucionados[orgao] / orgaos[orgao]) * 100>
												<cfset percentualSolucionadoFormatado = NumberFormat(percentualSolucionado, '0.0') />

												<!--- Adiciona cada linha à tabela --->
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#orgao#</td>
													<td>#solucionados[orgao]#</td>
													<td>#orgaos[orgao]#</td>
													<td>#percentualSolucionadoFormatado#%</td>
												</tr>
											</cfloop>
										</tbody>
									</cfoutput>
								</table>

	
							</cfif>

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
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_SLNC_Detalamento_";
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
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]

				})
 
			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");

				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				$('#tabResumoSLNC').DataTable({
					order: [[3, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
       				info: false, // Remove a exibição da quantidade de registros
					searching: false // Remove o campo de busca
				});
			});
		</script>

	</cffunction>



	<cffunction name="resultadoDGCI" access="remote" hint="outra função que utiliza tabIndicadores">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

		<cfset var resultadoPRCI = consultaIndicadorPRCI(ano=arguments.ano, mes=arguments.mes)>
    	<cfset var resultadoSLNC = consultaIndicadorSLNC(ano=arguments.ano, mes=arguments.mes)>

		


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
	 		<!--- Formata o percentualDP com duas casas decimais --->
		<cfset percentualDPFormatado = NumberFormat(percentualDP, '0.0') />
		


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
			<cfset percentualSolucionadoFormatado = NumberFormat(percentualSolucionado, '0.0') />

			<cfset percentualDGCI = (percentualDPFormatado * 0.4) + (percentualSolucionadoFormatado*0.6) />

			<div align="center" class="col-md-12 col-sm-12 col-12 mx-auto" style="margin-bottom:20px">
				<span class="info-box-text" style="font-size:40px">#monthAsString(arguments.mes)#/#arguments.ano#</span>
			</div>	
			<div id="divResultadoDGCI" class="col-md-5 col-sm-5 col-12 mx-auto">
				<div class="info-box bg-info">
					<span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

					<div class="info-box-content">
						<span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:30px"><strong>DGCI</strong></font></font></span>
						<span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong>#percentualDGCI#%</strong></font></font></span>

						<div class="progress">
							<div class="progress-bar" style="width: #percentualDGCI#%"></div>
						</div>
						<span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
							<span style="font-size:14px">DGCI = (PRCI*0,40) + (SLNC*0,60)</span><br>
						</font></font></span>
					</div>
					<!-- /.info-box-content -->
				</div>
			
			
			</div>	
			

			<div class="col-12">
				<div class="row " style="display: flex; justify-content: center;margin-bottom:10px">
					<i class="fa-solid fa-angles-up" style="font-size:40px;"></i>
					
				</div>
				<div class="row " style="display: flex; justify-content: center;">
					<div id="divResultadoPRCI" class="col-md-5 col-sm-5 col-12 "></div>
					<div id="divResultadoSLNC" class="col-md-5 col-sm-5 col-12 "></div>
				</div>
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

				divResultPRCI.html("")
				divResultSLNC.html("")


			});
		   
		</script>
	</cffunction>





	



</cfcomponent>