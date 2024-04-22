
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


<cfset ano = 2023>
<cfset mes = 12>

<cfset dataInicial = createODBCDate(createDateTime(ano, mes, 1, 0, 0, 0))>
<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(ano, mes, 1, 0, 0, 0))))>
	
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

<cfquery name="orgaos_media_metas_ECT_mes" datasource="#application.dsn_processos#" timeout="120">
	SELECT pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
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
				where pc_indOrgao_ano = #ano# and pc_indOrgao_mes = #mes#) as pc_indicadores_porOrgao on pc_indOrgao_mcuOrgao = pc_indMeta_mcuOrgao 	
	WHERE pc_indMeta_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
		AND pc_indMeta_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		AND pc_indMeta_numIndicador in (1,2)
	GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador,pc_indMeta_numIndicador,pc_indMeta_meta, pc_indPeso_peso
	) AS SUBCONSULTA
	GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
</cfquery>

<cfquery name="orgaos_media_metas_ECT_mes2" datasource="#application.dsn_processos#" timeout="120">
	SELECT pc_org_sigla
	,pc_indOrgao_mcuOrgaoSubordinador
	       ,ROUND(AVG(metaPRCI),1) AS metaPRCI
		   ,ROUND(AVG(metaSLNC),1) AS metaSLNC
		   ,max(pesoPRCI) AS pesoPRCI
		   ,MAX(pesoSLNC) AS pesoSLNC
		   ,ROUND(ROUND(ROUND(AVG(metaPRCI),1)*MAX(pesoPRCI),1) + ROUND(ROUND(AVG(metaSLNC),1)*MAX(pesoSLNC),1),1) AS metaDGCImes
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
						where pc_indOrgao_ano = #ano# and pc_indOrgao_mes = #mes#) as pc_indicadores_porOrgao on pc_indOrgao_mcuOrgao = pc_indMeta_mcuOrgao 	
			WHERE pc_indMeta_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indMeta_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indMeta_numIndicador in (1,2)
			GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador,pc_indMeta_numIndicador,pc_indMeta_meta, pc_indPeso_peso
		) AS SUBCONSULTA
		GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
	) AS SUBCONSULTA2
	INNER JOIN pc_orgaos ON pc_indOrgao_mcuOrgaoSubordinador = pc_orgaos.pc_org_mcu
	GROUP BY pc_org_sigla,pc_indOrgao_mcuOrgaoSubordinador
	ORDER BY  pc_org_sigla

</cfquery>
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
						where pc_indOrgao_ano = #ano# and pc_indOrgao_mes = #mes#) as pc_indicadores_porOrgao on pc_indOrgao_mcuOrgao = pc_indMeta_mcuOrgao 	
			WHERE pc_indMeta_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indMeta_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indMeta_numIndicador in (1,2)
			GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador,pc_indMeta_numIndicador,pc_indMeta_meta, pc_indPeso_peso
		) AS SUBCONSULTA
		GROUP BY pc_indOrgao_mcuOrgao, pc_indOrgao_mcuOrgaoSubordinador
	) AS SUBCONSULTA2
	GROUP BY pc_indOrgao_mcuOrgaoSubordinador
	) AS SUBCONSULTA3

</cfquery>



			
<cfdump  var="#resultado_DGCI_ECT_mes#">
<cfdump  var="#orgaos_media_metas_ECT_mes#">
<cfdump  var="#orgaos_media_metas_ECT_mes2#">
<cfdump  var="#mediaMetaDGCImes#">

