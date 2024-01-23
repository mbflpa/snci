<cfprocessingdirective pageencoding = "utf-8">	
<cfquery name="rs_ultima_posic_resp" datasource="#application.dsn_processos#" timeout="120">
    SELECT
        pc_aval_posic_num_orientacao as orientacao
        
    FROM (
        SELECT
            pc_aval_posic_id,
            pc_aval_posic_num_orientacao,
            pc_aval_posic_status,
            pc_aval_posic_num_orgaoResp,
            pc_aval_posic_dataPrevistaResp,
            ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
        FROM
            pc_avaliacao_posicionamentos
      
             
    ) AS ranked_posicionamentos
    INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
    INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
    INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
    INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
    INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
    INNER JOIN pc_orgaos as orgaoOrigem ON pc_processos.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
    INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
    WHERE
        ranked_posicionamentos.row_num = 1
        AND pc_aval_posic_status IN (3)
        
</cfquery>
 <table border="1">
 <tr>
    <th>Orientação ID</th>
    <th>Origem</th>
    <th>Orgão Resp</th>
  </tr>
<cfloop query="rs_ultima_posic_resp">

      <cfquery name="rs_ultima_posic_resp" datasource="#application.dsn_processos#" timeout="120">
            SELECT  pc_aval_orientacao_id as orientacaoID, orgaoOrigem.pc_org_sigla as origem, orgaoResp.pc_org_sigla as orgaoResp
            from pc_avaliacao_orientacoes
            INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
            INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
            INNER JOIN pc_orgaos as orgaoOrigem ON pc_processos.pc_num_orgao_origem = orgaoOrigem.pc_org_mcu
            INNER JOIN pc_orientacao_status ON pc_avaliacao_orientacoes.pc_aval_orientacao_status = pc_orientacao_status.pc_orientacao_status_id
            INNER JOIN pc_orgaos as orgaoResp ON pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp = orgaoResp.pc_org_mcu
            WHERE pc_aval_orientacao_id= #orientacao# and pc_aval_orientacao_status <> 3 and pc_num_status =4 and pc_orientacao_status_finalizador='N'
      </cfquery>

     
 

  <cfloop query="rs_ultima_posic_resp">
      <cfoutput>
            <tr>
                  <td>#rs_ultima_posic_resp.orientacaoID#</td>
                  <td>#rs_ultima_posic_resp.origem#</td>
                  <td>#rs_ultima_posic_resp.orgaoResp#</td>
            </tr>
     </cfoutput>
  </cfloop>

</cfloop>

</table>
