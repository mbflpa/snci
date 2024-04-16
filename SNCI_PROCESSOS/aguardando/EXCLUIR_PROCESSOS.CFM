
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


<cfset ano = 2024>
<cfset mes = 2>

<cfset dataInicial = createODBCDate(createDateTime(ano, mes, 1, 0, 0, 0))>
<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(ano, mes, 1, 0, 0, 0))))>
	
<cfquery name="consulta_PRCI_TIDP_TGI_mensal" datasource="#application.dsn_processos#" timeout="120">
			SELECT 
				pc_indOrgao_mcuOrgao as mcuOrgaoResp,
				pc_orgaos.pc_org_sigla as siglaOrgaoResp,
				MAX(IIF(pc_indOrgao_numIndicador = 4, pc_indOrgao_resultadoMes, NULL)) as TIDP,
				MAX(IIF(pc_indOrgao_numIndicador = 5, pc_indOrgao_resultadoMes, NULL)) as TGI,
				MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoMes, NULL)) as PRCI,
				MAX(IIF(pc_indOrgao_numIndicador = 1, pc_indOrgao_resultadoAcumulado, NULL)) as PRCIacumulado
			FROM 
				pc_indicadores_porOrgao
			INNER JOIN 
				pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			WHERE 
				pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador IN(1,4,5)
				AND pc_indOrgao_paraOrgaoSubordinador = 0
               
			GROUP BY 
				pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla
		</cfquery>

					
<cfdump  var="#consulta_PRCI_TIDP_TGI_mensal#">
