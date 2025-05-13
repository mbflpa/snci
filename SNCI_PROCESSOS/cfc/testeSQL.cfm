<cfprocessingdirective pageencoding="utf-8">	
<cfquery name="rsOrientacoesSemOrgaoResp" datasource="#application.dsn_processos#" timeout="120">
    SELECT pc_aval_orientacao_id FROM pc_avaliacao_orientacoes where pc_aval_orientacao_mcu_orgaoResp =''
</cfquery>

<cfdump var="#rsOrientacoesSemOrgaoResp#" label="rsOrientacoesSemOrgaoResp" format="html" />

<cfloop query="rsOrientacoesSemOrgaoResp">
    <cfquery name="rsUltimoOrgaoRespPosic" datasource="#application.dsn_processos#" timeout="120">
        SELECT TOP 1 pc_aval_posic_id , pc_aval_posic_num_orgaoResp FROM pc_avaliacao_posicionamentos 
        where pc_aval_posic_num_orgaoResp <>'' and pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#pc_aval_orientacao_id#">
        order by pc_aval_posic_id desc
    </cfquery>

    <cfquery datasource = "#application.dsn_processos#" >
        UPDATE 	pc_avaliacao_orientacoes
        SET 
            pc_aval_orientacao_mcu_orgaoResp = '#rsUltimoOrgaoRespPosic.pc_aval_posic_num_orgaoResp#'
        WHERE 
            pc_aval_orientacao_id = '#pc_aval_orientacao_id#'
    </cfquery>

    <cfquery name="rsPosicSemOrgaoResp" datasource="#application.dsn_processos#" timeout="120">
        SELECT TOP 1 pc_aval_posic_id , pc_aval_posic_num_orgaoResp FROM pc_avaliacao_posicionamentos 
        where pc_aval_posic_num_orgaoResp = '' and pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#pc_aval_orientacao_id#">
    </cfquery>
    
    <cfquery datasource = "#application.dsn_processos#" >
        UPDATE 	pc_avaliacao_posicionamentos
        SET 
            pc_aval_posic_num_orgaoResp = '#rsUltimoOrgaoRespPosic.pc_aval_posic_num_orgaoResp#'
        WHERE 
            pc_aval_posic_id = '#rsPosicSemOrgaoResp.pc_aval_posic_id#'
    </cfquery>

</cfloop>
    