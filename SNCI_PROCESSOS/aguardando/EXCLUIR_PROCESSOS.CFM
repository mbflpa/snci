
<cfprocessingdirective pageencoding = "utf-8"> 

<cfset ano = 2023>
<cfset mes = 12>

<cfquery name="dadosAno_CI" datasource="#application.dsn_processos#" timeout="120"  >
	SELECT	pc_oorgaoSubordinador.pc_org_mcu as mcuOrgaoSubordinador
			,pc_orgaoResp.pc_org_mcu as mcuOrgaoResp
			,MONTH(pc_indDados_dataRef) AS mes
			,YEAR(pc_indDados_dataRef) AS ano
			,pc_indDados_numIndicador
			,CASE WHEN pc_indDados_prazo = 'DP' THEN 1 ELSE 0 END AS DP
			,CASE WHEN pc_indDados_status = 6 THEN 1 ELSE 0 END AS solucionado
	FROM pc_indicadores_dados		
	INNER JOIN pc_orgaos as pc_orgaoAvaliado ON pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_numOrgaoAvaliado
	INNER JOIN pc_orgaos as pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_indicadores_dados.pc_indDados_numOrgaoResp
	INNER JOIN pc_orgaos as pc_oorgaoSubordinador ON pc_oorgaoSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_numOrgaoSubordinador
	WHERE YEAR(pc_indDados_dataRef) = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="resultadoPRCIporOrgaoSubordinador" dbtype="query">
	SELECT	ano
			,mes
			,pc_indDados_numIndicador as numIndicador
			,mcuOrgaoSubordinador as mcuOrgao
			,1 as paraOrgaoSubordinador
			,mcuOrgaoSubordinador 
			,(SUM(DP)/COUNT(*))*100 AS resultadoIndicador
	FROM dadosAno_CI
	WHERE mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		AND pc_indDados_numIndicador = 1
	GROUP BY ano, mes, pc_indDados_numIndicador, mcuOrgaoSubordinador
</cfquery>

<cfquery name="resultadoPRCIporOrgaoResp" dbtype="query">
	SELECT	ano
			,mes
			,pc_indDados_numIndicador as numIndicador
			,mcuOrgaoResp as mcuOrgao
			,0 as paraOrgaoSubordinador
			,mcuOrgaoSubordinador 
			,(SUM(DP)/COUNT(*))*100 AS resultadoIndicador
	FROM dadosAno_CI
	WHERE mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		AND pc_indDados_numIndicador = 1
	GROUP BY ano, mes, pc_indDados_numIndicador, mcuOrgaoResp,mcuOrgaoSubordinador 
</cfquery>

<cfquery name="resultadoSLNCporOrgaoSubordinador" dbtype="query">
	SELECT	ano
			,mes
			,pc_indDados_numIndicador as numIndicador
			,mcuOrgaoSubordinador as mcuOrgao
			,1 as paraOrgaoSubordinador
			,mcuOrgaoSubordinador 
			,(SUM(solucionado)/COUNT(*))*100 AS resultadoIndicador
	FROM dadosAno_CI
	WHERE mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		AND pc_indDados_numIndicador = 2
	GROUP BY ano, mes, pc_indDados_numIndicador, mcuOrgaoSubordinador
</cfquery>

<cfquery name="resultadoSLNCporOrgaoResp" dbtype="query">
	SELECT	ano
			,mes
			,pc_indDados_numIndicador as numIndicador
			,mcuOrgaoResp  as mcuOrgao
			,0 as paraOrgaoSubordinador
			,mcuOrgaoSubordinador 
			,(SUM(solucionado)/COUNT(*))*100 AS resultadoIndicador
	FROM dadosAno_CI
	WHERE mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		AND pc_indDados_numIndicador = 2
	GROUP BY ano, mes, pc_indDados_numIndicador, mcuOrgaoResp,mcuOrgaoSubordinador 
</cfquery>

<!-- consulta união dos resultados  -->
<cfquery name="resultadoIndicadoresPorOrgao" dbtype="query">
	SELECT	* FROM resultadoPRCIporOrgaoSubordinador
	UNION
	SELECT	* FROM resultadoPRCIporOrgaoResp
	UNION
	SELECT	* FROM resultadoSLNCporOrgaoSubordinador
	UNION
	SELECT	* FROM resultadoSLNCporOrgaoResp
</cfquery>


<!--insere os dados na tabela pc_indicadores_porOrgao-->
<cfloop query="resultadoIndicadoresPorOrgao">

	<!-- cfquery que retorna pc_indOrgao_resultadoAcumulado do mês anterior da tabela pc_indicadores_porOrgaos -->
	<cfquery name="resultadoIndicadorAcumuladoMesAnterior" datasource="#application.dsn_processos#" timeout="120"  >
		SELECT TOP 1 pc_indOrgao_resultadoAcumulado
		FROM pc_indicadores_porOrgao
		WHERE 	pc_indOrgao_ano = <cfqueryparam value="#resultadoIndicadoresPorOrgao.ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes < <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND NOT pc_indOrgao_resultadoAcumulado IS NULL
				AND pc_indOrgao_numIndicador = <cfqueryparam value="#resultadoIndicadoresPorOrgao.numIndicador#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoIndicadoresPorOrgao.mcuOrgao#" cfsqltype="cf_sql_varchar">
	</cfquery>

	<cfquery name="rsContarMeses" datasource="#application.dsn_processos#" timeout="120"  >
		SELECT COUNT(DISTINCT pc_indOrgao_mes) as quantMeses
		FROM pc_indicadores_porOrgao
		WHERE 	pc_indOrgao_ano = <cfqueryparam value="#resultadoIndicadoresPorOrgao.ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes < <cfqueryparam value="#resultadoIndicadoresPorOrgao.mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador = <cfqueryparam value="#resultadoIndicadoresPorOrgao.numIndicador#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoIndicadoresPorOrgao.mcuOrgao#" cfsqltype="cf_sql_varchar">
	</cfquery>


	<cfif resultadoIndicadorAcumuladoMesAnterior.recordCount eq 0>
		<cfset resultadoIndicadorAcumulado = resultadoIndicadoresPorOrgao.resultadoIndicador>
	<cfelse>
		<cfset resultadoIndicadorAcumulado = (resultadoIndicadorAcumuladoMesAnterior.pc_indOrgao_resultadoAcumulado + resultadoIndicadoresPorOrgao.resultadoIndicador)/(rsContarMeses.quantMeses+1)>
	</cfif>
	
	<cfquery name="insereDadosIndicadoresporOrgao" datasource="#application.dsn_processos#" timeout="120"  >
		INSERT INTO pc_indicadores_porOrgao
		(pc_indOrgao_ano, pc_indOrgao_mes, pc_indOrgao_numIndicador, pc_indOrgao_mcuOrgao, pc_indOrgao_resultadoMes, pc_indOrgao_resultadoAcumulado, pc_indOrgao_paraOrgaoSubordinador, pc_indOrgao_mcuOrgaoSubordinador)
		VALUES
		(	<cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
			,<cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
			,<cfqueryparam value="#numIndicador#" cfsqltype="cf_sql_integer">
			,<cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
			,<cfqueryparam value="#resultadoIndicador#" cfsqltype="cf_sql_float">
			,<cfqueryparam value="#resultadoIndicadorAcumulado#" cfsqltype="cf_sql_float">
			,<cfqueryparam value="#paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
			,<cfqueryparam value="#mcuOrgaoSubordinador#" cfsqltype="cf_sql_varchar">
		)
	</cfquery>
	
</cfloop>

<!--orgãso da tabela pc_indicadores_porOrgao-->
<cfquery name="orgaos" datasource="#application.dsn_processos#" timeout="120"  >
	SELECT DISTINCT pc_indOrgao_mcuOrgao as mcuOrgao ,pc_indOrgao_paraOrgaoSubordinador , pc_indOrgao_mcuOrgaoSubordinador
	FROM pc_indicadores_porOrgao
	WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
	AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
	
</cfquery>


<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#" timeout="120"  >
	SELECT	* FROM pc_indicadores WHERE pc_indicadores.pc_ind_id = 1
</cfquery>

<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#" timeout="120"  >
	SELECT	* FROM pc_indicadores WHERE pc_indicadores.pc_ind_id = 2
</cfquery>

<!--LOOP em cada órgao para inserir na tabela pc_indicadores_porOrgao o indicador 3 (DGCI) através da fórmula DGCI = PRCI*0.55 + SLNC*0.45-->
<cfloop query="orgaos">
	<cfquery name="rsPRCIporOrgao" datasource="#application.dsn_processos#" timeout="120" >
		SELECT	pc_indOrgao_resultadoMes FROM pc_indicadores_porOrgao
		WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
			AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
			AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
			AND pc_indOrgao_numIndicador = 1
			AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
	</cfquery>

	<cfquery name="rsSLNCporOrgao" datasource="#application.dsn_processos#" timeout="120" >
		SELECT	pc_indOrgao_resultadoMes FROM pc_indicadores_porOrgao
		WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
			AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
			AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
			AND pc_indOrgao_numIndicador = 2
			AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
	</cfquery>

	<cfif rsPRCIporOrgao.recordCount eq 0 >
		<cfset prciResultado = 0>
	<cfelse>
		<cfset prciResultado = rsPRCIporOrgao.pc_indOrgao_resultadoMes>
	</cfif>

	<cfif rsSLNCporOrgao.recordCount eq 0 >
		<cfset slncResultado = 0>
	<cfelse>
		<cfset slncResultado = rsSLNCporOrgao.pc_indOrgao_resultadoMes>
	</cfif>
	
	<cfset resultadoDGCI = (prciResultado*rsPRCIpeso.pc_ind_peso) + (slncResultado*rsSLNCpeso.pc_ind_peso)>

	<!-- cfquery que retorna pc_indOrgao_resultadoAcumulado do mês anterior da tabela pc_indicadores_porOrgaos -->
	<cfquery name="resultadoIndicadorAcumuladoMesAnterior" datasource="#application.dsn_processos#" timeout="120"  >
		SELECT TOP 1 pc_indOrgao_resultadoAcumulado
		FROM pc_indicadores_porOrgao
		WHERE 	pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes < <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador = 3
				AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
				AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
	</cfquery>

	<cfquery name="rsContarMeses" datasource="#application.dsn_processos#" timeout="120"  >
		SELECT COUNT(DISTINCT pc_indOrgao_mes) as quantMeses
		FROM pc_indicadores_porOrgao
		WHERE 	pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes < <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador = 3
				AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
				AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
	</cfquery>


	<cfif resultadoIndicadorAcumuladoMesAnterior.recordCount eq 0>
		<cfset resultadoIndicadorAcumulado = resultadoDGCI>
	<cfelse>
		<cfset resultadoIndicadorAcumulado = (resultadoIndicadorAcumuladoMesAnterior.pc_indOrgao_resultadoAcumulado + resultadoDGCI)/(rsContarMeses.quantMeses+1)>
	</cfif>
	
	<cfquery name="insereDadosIndicadoresporOrgao" datasource="#application.dsn_processos#" timeout="120"  >
		INSERT INTO pc_indicadores_porOrgao
		(pc_indOrgao_ano, pc_indOrgao_mes, pc_indOrgao_numIndicador, pc_indOrgao_mcuOrgao, pc_indOrgao_resultadoMes, pc_indOrgao_resultadoAcumulado, pc_indOrgao_paraOrgaoSubordinador, pc_indOrgao_mcuOrgaoSubordinador)
		VALUES
		(	<cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
			,<cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
			,<cfqueryparam value="3" cfsqltype="cf_sql_integer">
			,<cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
			,<cfqueryparam value="#resultadoDGCI#" cfsqltype="cf_sql_float">
			,<cfqueryparam value="#resultadoIndicadorAcumulado#" cfsqltype="cf_sql_float">
			,<cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
			,<cfqueryparam value="#orgaos.pc_indOrgao_mcuOrgaoSubordinador#" cfsqltype="cf_sql_varchar">
		)
	</cfquery>
</cfloop>

	



<cfdump var="#resultadoIndicadoresPorOrgao#">