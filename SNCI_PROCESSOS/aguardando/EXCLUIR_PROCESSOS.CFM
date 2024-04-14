
<cfprocessingdirective pageencoding = "utf-8"> 
<cfset ano = 2024>
<cfset mes = 1>

<cfset dataInicial = createODBCDate(createDateTime(ano, mes, 1, 0, 0, 0))>
<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(ano, mes, 1, 0, 0, 0))))>
	
<cfquery name="consulta_PRCI_TIDP_TGI_mensal" datasource="#application.dsn_processos#" timeout="120">
    SELECT 
        pc_indOrgao_mcuOrgao as mcuOrgaoResp,
        pc_orgaos.pc_org_sigla as siglaOrgaoResp,
        MAX(IIF(pc_indOrgao_numIndicador = 4, pc_indOrgao_resultadoMes, 0)) as TIDP,
        MAX(IIF(pc_indOrgao_numIndicador = 5, pc_indOrgao_resultadoMes, 0)) as TGI,
        MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoMes, 0)) as PRCI
    FROM 
        pc_indicadores_porOrgao
    INNER JOIN 
        pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
    WHERE 
        pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
        AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
        AND pc_indOrgao_numIndicador IN(1,4,5)
        AND pc_indOrgao_mcuOrgaoSubordinador = '#application.rsUsuarioParametros.pc_usu_lotacao#'
		AND pc_indOrgao_paraOrgaoSubordinador = 0
    GROUP BY 
        pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
</cfquery>
					

	<!-- tabela resumo -->
		<cfif consulta_PRCI_TIDP_TGI_mensal.RECORDCOUNT neq 0>
			<div id="divTabResumoPRCIorgaos" class="table-responsive">
				<table id="tabResumoPRCIorgaos" class="table table-bordered table-striped text-nowrap " style="width:350px; cursor:pointer">
					<cfoutput>
						
						<thead class="bg-gradient-warning" style="text-align: center;">
							<tr style="font-size:14px">
								<th colspan="6" style="padding:5px">PRCI - <span>#monthAsString(mes)#/#ano#</span></th>
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
							<cfoutput>
								<cfloop query="consulta_PRCI_TIDP_TGI_mensal"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->

									<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
										SELECT pc_indMeta_meta FROM pc_indicadores_meta 
										WHERE pc_indMeta_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_numIndicador = 1
												AND pc_indMeta_mcuOrgao = '#mcuOrgaoResp#'
									</cfquery>
									
									<!--- Adiciona cada linha à tabela --->
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
										<td>#NumberFormat(TIDP,0)#</td>
										<td>#NumberFormat(TGI,0)#</td>
										<td><strong>#NumberFormat(ROUND(PRCI*10)/10,0.0)#%</strong></td>
										<cfset metaPRCIorgao = 0>
										<cfif rsMetaPRCI.pc_indMeta_meta neq ''>
											<cfset metaPRCIorgao = NumberFormat(ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10,0.0)>
										</cfif>
										<cfif rsMetaPRCI.pc_indMeta_meta eq ''>
											<td>sem meta</td>
										<cfelse>	
											<td><strong>#metaPRCIorgao#%</strong></td>
										</cfif>
										<cfset resultMesEmRelacaoMeta = 0>
										<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
									</tr>
								</cfloop>
							</cfoutput>
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



