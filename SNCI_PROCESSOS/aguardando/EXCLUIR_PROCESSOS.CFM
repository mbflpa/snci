
<cfprocessingdirective pageencoding = "utf-8"> 
<cfset ano = 2024>
<cfset mes = 2>

<cfset dataInicial = createODBCDate(createDateTime(ano, mes, 1, 0, 0, 0))>
<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(ano, mes, 1, 0, 0, 0))))>
	
<cfquery name="consulta_SLNC_QTSL_QTNC_mensal" datasource="#application.dsn_processos#" timeout="120">
    SELECT 
        pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao as mcuOrgaoResp,
        pc_orgaos.pc_org_sigla as siglaOrgaoResp,
        MAX(IIF(pc_indicadores_porOrgao.pc_indOrgao_numIndicador = 6, pc_indicadores_porOrgao.pc_indOrgao_resultadoMes, NULL)) as QTSL,
        MAX(IIF(pc_indicadores_porOrgao.pc_indOrgao_numIndicador = 7, pc_indicadores_porOrgao.pc_indOrgao_resultadoMes, NULL)) as QTNC,
        MAX(IIF(pc_indicadores_porOrgao.pc_indOrgao_numIndicador = 2, pc_indicadores_porOrgao.pc_indOrgao_resultadoMes, NULL)) as SLNC,
        MAX(IIF(pc_indicadores_porOrgao.pc_indOrgao_numIndicador = 2, pc_indicadores_porOrgao.pc_indOrgao_resultadoAcumulado, NULL)) as SLNCacumulado,
        (SELECT TOP 1 pc_indMeta_meta 
         FROM pc_indicadores_meta 
         WHERE pc_indicadores_meta.pc_indMeta_ano = pc_indicadores_porOrgao.pc_indOrgao_ano 
           AND pc_indicadores_meta.pc_indMeta_mes = pc_indicadores_porOrgao.pc_indOrgao_mes 
           AND pc_indicadores_meta.pc_indMeta_numIndicador = 2 
           AND (pc_indicadores_meta.pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
                OR pc_indicadores_meta.pc_indMeta_mcuOrgao IN (
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
					)) ) as metaSLNC
      
    FROM 
        pc_indicadores_porOrgao
    INNER JOIN 
        pc_orgaos ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
    WHERE 
        pc_indicadores_porOrgao.pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
        AND pc_indicadores_porOrgao.pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
        AND pc_indicadores_porOrgao.pc_indOrgao_numIndicador IN(2,6,7)
        AND pc_indicadores_porOrgao.pc_indOrgao_mcuOrgaoSubordinador = '#application.rsUsuarioParametros.pc_usu_lotacao#'
        AND pc_indicadores_porOrgao.pc_indOrgao_paraOrgaoSubordinador = 0
    GROUP BY 
        pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao, pc_orgaos.pc_org_sigla,pc_indicadores_porOrgao.pc_indOrgao_ano, pc_indicadores_porOrgao.pc_indOrgao_mes
</cfquery>


					
<cfdump  var="#consulta_SLNC_QTSL_QTNC_mensal#">
