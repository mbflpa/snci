
<cfprocessingdirective pageencoding = "utf-8"> 
  


<cfset ano = 2023>
<cfset mes = 12>

<cfset dataInicial = createODBCDate(createDateTime(ano, mes, 1, 0, 0, 0))>
<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(ano, mes, 1, 0, 0, 0))))>
	
<cfquery name="resultado_DGCI_ECT_mes" datasource="#application.dsn_processos#" timeout="120">
	SELECT	pc_indOrgao_mes
	FROM
		pc_indicadores_porOrgao
	WHERE
		pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
		AND pc_indOrgao_mes <= <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
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
				WHERE pc_indMeta_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
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
		SELECT AVG(mediaDGCI) AS mediaMediaDGCI
		FROM(SELECT	pc_indOrgao_mes, ROUND(AVG(pc_indOrgao_resultadoMes),1) AS mediaDGCI
			FROM
				pc_indicadores_porOrgao
			WHERE
				pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_mes <= <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indOrgao_numIndicador =3
				AND pc_indOrgao_paraOrgaoSubordinador = 1
			GROUP BY pc_indOrgao_mes
			) AS SUBCONSULTA

</cfquery>




<cfset mediaMediaMetaDGCImes = somaMediaMetaDGCImes/listLen(listMes)>

			
<cfdump  var="#resultado_DGCI_ECT_mes#">
<cfdump  var="#mediaMediaMetaDGCImes#">
<cfdump  var="#resultado_DGCI_ECT_mediaMes#">


