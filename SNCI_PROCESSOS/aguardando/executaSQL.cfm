<cfprocessingdirective pageencoding = "utf-8">	
<cfquery name="rs_ultima_posic_resp" datasource="#application.dsn_processos#" timeout="120">
  SELECT  DISTINCT pc_indOrgao_mcuOrgao
       ,pc_orgaos.pc_org_sigla
       ,pc_indOrgao_ano
       ,pc_indOrgao_mes
       ,pc_indOrgao_paraOrgaoSubordinador
       ,pc_indOrgao_mcuOrgaoSubordinador
       ,MAX(IIF(pc_indOrgao_numIndicador = 4,pc_indOrgao_resultadoMes,0))                                                       AS TIDP
       ,MAX(IIF(pc_indOrgao_numIndicador = 5,pc_indOrgao_resultadoMes,0))                                                       AS TGI
       ,MAX(IIF(pc_indOrgao_numIndicador = 1,pc_indOrgao_resultadoMes,NULL))                                                    AS PRCI
       ,MAX(IIF(pc_indMeta_numIndicador = 1,pc_indMeta_meta,NULL))                                                              AS metaPRCI
       ,MAX(IIF(pc_indOrgao_numIndicador = 1,pc_indOrgao_resultadoAcumulado,NULL))                                              AS PRCIacumulado
       ,MAX(IIF(pc_indOrgao_numIndicador = 6,pc_indOrgao_resultadoMes,0))                                                       AS QTSL
       ,MAX(IIF(pc_indOrgao_numIndicador = 7,pc_indOrgao_resultadoMes,0))                                                       AS QTNC
       ,MAX(IIF(pc_indOrgao_numIndicador = 2,pc_indOrgao_resultadoMes,NULL))                                                    AS SLNC
       ,MAX(IIF(pc_indMeta_numIndicador = 2,pc_indMeta_meta,NULL))                                                              AS metaSLNC
       ,MAX(IIF(pc_indOrgao_numIndicador = 2,pc_indOrgao_resultadoAcumulado,NULL))                                              AS SLNCacumulado
       ,MAX(IIF(pc_indPeso_numIndicador = 1,pc_indPeso_peso,NULL))                                                              AS pesoPRCI
       ,MAX(IIF(pc_indPeso_numIndicador = 2,pc_indPeso_peso,NULL))                                                              AS pesoSLNC
       ,MAX(IIF(pc_indOrgao_numIndicador = 3,pc_indOrgao_resultadoMes,NULL))                                                    AS DGCI
       ,MAX(IIF(pc_indOrgao_numIndicador = 3,pc_indOrgao_resultadoAcumulado,NULL))                                              AS DGCIacumulado
       ,MAX(IIF(pc_indMeta_numIndicador = 1,pc_indMeta_meta,NULL)) * MAX(IIF(pc_indPeso_numIndicador = 1,pc_indPeso_peso,NULL)) AS metaPonderadaPRCI
       ,MAX(IIF(pc_indMeta_numIndicador = 2,pc_indMeta_meta,NULL)) * MAX(IIF(pc_indPeso_numIndicador = 2,pc_indPeso_peso,NULL)) AS metaPonderadaSLNC
       ,Round((MAX(IIF(pc_indMeta_numIndicador = 1,pc_indMeta_meta,NULL)) * MAX(IIF(pc_indPeso_numIndicador = 1,pc_indPeso_peso,NULL))) + (MAX(IIF(pc_indMeta_numIndicador = 2,pc_indMeta_meta,NULL)) * MAX(IIF(pc_indPeso_numIndicador = 2,pc_indPeso_peso,NULL))),1) AS metaDGCI
FROM pc_indicadores_porOrgao
INNER JOIN pc_orgaos
ON pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
INNER JOIN pc_orgaos as orgaoSubordinadores
ON orgaoSubordinadores.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgaoSubordinador
LEFT JOIN pc_indicadores_meta
ON pc_indMeta_mes = pc_indOrgao_mes AND pc_indMeta_ano = pc_indOrgao_ano AND pc_indOrgao_mcuOrgao = pc_indMeta_mcuOrgao AND pc_indMeta_paraOrgaoSubordinador = pc_indOrgao_paraOrgaoSubordinador
LEFT JOIN pc_indicadores_peso
ON pc_indicadores_peso.pc_indPeso_ano = pc_indOrgao_ano
GROUP BY  pc_indOrgao_mcuOrgao
         ,pc_orgaos.pc_org_sigla
         ,pc_indOrgao_ano
         ,pc_indOrgao_mes
         ,pc_indOrgao_paraOrgaoSubordinador
         ,pc_indOrgao_mcuOrgaoSubordinador
        

</cfquery>
 
 <cfdump var="#rs_ultima_posic_resp#">
