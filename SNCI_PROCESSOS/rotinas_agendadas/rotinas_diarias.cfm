<cfprocessingdirective pageencoding = "utf-8">	


<cfquery name="rsPontoSuspensoPrazoVencido" datasource="#application.dsn_processos#">
    SELECT pc_aval_orientacao_id, pc_aval_orientacao_dataPrevistaResp, pc_aval_orientacao_status
    FROM pc_avaliacao_orientacoes
    WHERE pc_aval_orientacao_status = 16 and DATEDIFF(DAY, pc_aval_orientacao_dataPrevistaResp, GETDATE()) >0
</cfquery>
<cfdump var="#rsPontoSuspensoPrazoVencido#">

<cfoutput query= "rsPontoSuspensoPrazoVencido">
    <cfquery name="rsUltimaManifestacaoOrgao" datasource="#application.dsn_processos#">
        Select  pc_aval_posic_num_orientacao,  MAX(pc_aval_posic_id) AS maior_id, MAX(pc_aval_posic_datahora) AS datahora FROM pc_avaliacao_posicionamentos 
        WHERE pc_aval_posic_status = 3 AND pc_aval_posic_num_orientacao = <cfqueryparam value="#pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
        group by  pc_aval_posic_num_orientacao
    </cfquery>
    <cfdump var="#rsUltimaManifestacaoOrgao#">
</cfoutput>

