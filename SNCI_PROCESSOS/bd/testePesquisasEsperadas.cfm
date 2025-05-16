<cfparam name="form.ano" default="">

<form method="post" action="">
    <label for="ano">Informe o ano:</label>
    <input type="number" name="ano" id="ano" value="#form.ano#" min="2000" max="2099">
    <input type="submit" value="Pesquisar">
</form>

<cfif len(form.ano)>
    <cfquery name="rsProcessosAssociados" datasource="#application.dsn_processos#" timeout="120">
        SELECT pc_processo_id, orgaoRespSigla FROM
        (
            SELECT DISTINCT pc_processos.pc_processo_id, orgaoResp.pc_org_sigla as orgaoRespSigla
            FROM pc_avaliacao_posicionamentos posic
            INNER JOIN pc_orgaos orgaoResp ON posic.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
            INNER JOIN pc_avaliacao_orientacoes o on posic.pc_aval_posic_num_orientacao = o.pc_aval_orientacao_id
            INNER JOIN pc_avaliacoes ON o.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
            INNER JOIN pc_processos  ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
            WHERE pc_processos.pc_num_status in(4,5) AND orgaoResp.pc_org_controle_interno='N'
            
                AND RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.ano#">
            
            UNION

            SELECT DISTINCT pc_processos.pc_processo_id, orgaoResp.pc_org_sigla as orgaoRespSigla
            FROM pc_avaliacao_melhorias
            INNER JOIN pc_orgaos orgaoResp on pc_avaliacao_melhorias.pc_aval_melhoria_num_orgao = orgaoResp.pc_org_mcu
            INNER JOIN pc_avaliacoes ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
            INNER JOIN pc_processos  ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
            WHERE pc_processos.pc_num_status in(4,5)

                AND RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.ano#">
            
        ) AS unificado
        order by  pc_processo_id, orgaoRespSigla
    </cfquery>
    <!-- -->
    <cfdump var="#rsProcessosAssociados#" format="html" />
</cfif>
