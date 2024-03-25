
<cfprocessingdirective pageencoding = "utf-8"> 

<cfset ano = 2024>
<cfset mes = 2>

<cfquery name="dadosAno_CI" datasource="#application.dsn_processos#" timeout="120"  >
	SELECT	pc_oorgaoSubordinador.pc_org_mcu as mcuOrgaoSubordinador
			,pc_orgaoResp.pc_org_mcu as mcuOrgaoResp
			,MONTH(pc_indDados_dataRef) AS mes
			,YEAR(pc_indDados_dataRef) AS ano
			,pc_indDados_numIndicador
			,CASE WHEN pc_indDados_prazo = 'DP' THEN 1 ELSE 0 END AS DP
			,CASE WHEN pc_indDados_status = 6 THEN 1 ELSE 0 END AS solucionado
	FROM pc_indicadores_dados		
	INNER JOIN pc_orgaos as pc_orgaoAvaliado ON pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
	INNER JOIN pc_orgaos as pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
	INNER JOIN pc_orgaos as pc_oorgaoSubordinador ON pc_oorgaoSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
	WHERE YEAR(pc_indDados_dataRef) = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
		AND pc_oorgaoSubordinador.pc_org_mcu ='00434112'
		AND pc_indDados_numIndicador = 1
		and MONTH(pc_indDados_dataRef) = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="resultadoPRCIporOrgao" dbtype="query">
	SELECT	ano
			,mes
			,pc_indDados_numIndicador as numIndicador
			,mcuOrgaoResp as mcuOrgao
			,mcuOrgaoSubordinador 
			,(SUM(DP)/COUNT(*))*100 AS resultadoIndicador
	FROM dadosAno_CI
	WHERE mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		AND pc_indDados_numIndicador = 1
	GROUP BY ano, mes, pc_indDados_numIndicador, mcuOrgaoResp, mcuOrgaoSubordinador 
	order by mcuOrgaoSubordinador
</cfquery>


<cfquery name="resultadoPRCIporOrgao2" datasource="#application.dsn_processos#" timeout="120">
	SELECT	pc_orgaoSubordinador.pc_org_mcu as mcuOrgaoSubordinador
			,pc_orgaoResp.pc_org_mcu as mcuOrgaoResp
			,MONTH(pc_indDados_dataRef) AS mes
			,YEAR(pc_indDados_dataRef) AS ano
			,pc_indDados_numIndicador as numIndicador
			,(SUM(CASE WHEN pc_indDados_prazo = 'DP' THEN 1 ELSE 0 END)/COUNT(*))*100 AS resultadoIndicador
	FROM pc_indicadores_dados		
	INNER JOIN pc_orgaos as pc_orgaoAvaliado ON pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
	INNER JOIN pc_orgaos as pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
	INNER JOIN pc_orgaos as pc_orgaoSubordinador ON pc_orgaoSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
	WHERE YEAR(pc_indDados_dataRef) = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
		AND pc_orgaoSubordinador.pc_org_mcu ='00434112'
		AND pc_indDados_numIndicador = 1
		and MONTH(pc_indDados_dataRef) = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
	GROUP BY pc_orgaoSubordinador.pc_org_mcu, pc_orgaoResp.pc_org_mcu, MONTH(pc_indDados_dataRef), YEAR(pc_indDados_dataRef), pc_indDados_numIndicador
	ORDER BY pc_orgaoSubordinador.pc_org_mcu
</cfquery>

<cfquery name="resultadoPRCIporOrgaoSubordinador" dbtype="query">
	SELECT	ano
			,mes
			,numIndicador
			,mcuOrgaoSubordinador as mcuOrgao
					,mcuOrgaoSubordinador
			,AVG(resultadoIndicador) as resultadoIndicador
			,1 as paraOrgaoSubordinador
	FROM resultadoPRCIporOrgao
	GROUP BY ano, mes, numIndicador, mcuOrgaoSubordinador
	order by mcuOrgaoSubordinador
</cfquery>
<cfquery name="resultadoPRCIporOrgaoSubordinador2" dbtype="query">
	SELECT	ano
			,mes
			,numIndicador
			,mcuOrgaoSubordinador as mcuOrgao
					,mcuOrgaoSubordinador
			,AVG(resultadoIndicador) as resultadoIndicador
			,1 as paraOrgaoSubordinador
	FROM resultadoPRCIporOrgao2
	GROUP BY ano, mes, numIndicador, mcuOrgaoSubordinador
	order by mcuOrgaoSubordinador
</cfquery>




<cfdump var="#dadosAno_CI#">
<cfdump var="#resultadoPRCIporOrgao#">
<cfdump var="#resultadoPRCIporOrgaoSubordinador#">

<cfdump var="#resultadoPRCIporOrgao2#">
```
<cfdump var="#resultadoPRCIporOrgaoSubordinador2#">