<cfprocessingdirective pageencoding = "utf-8">	
<!--Executar este script em homologação ou desenvolvimento e, depois da homologação, executar em produção-->
<cfquery datasource = "#application.dsn_processos#" name="rsPosicOrgaoAvaliado">
      SELECT pc_aval_posic_id, pc_aval_posic_num_orientacao,pc_aval_posic_dataHora  from pc_avaliacao_posicionamentos
      WHERE pc_aval_posic_status = 3  
      and pc_aval_posic_enviado = 1
      order by pc_aval_posic_num_orientacao
</cfquery>



<cfoutput query = "rsPosicOrgaoAvaliado">    
      <cfquery datasource = "#application.dsn_processos#" name="rsDataPrevista">
            SELECT TOP 1 pc_aval_posic_num_orientacao, pc_aval_posic_dataPrevistaResp, pc_aval_posic_num_orgaoResp FROM pc_avaliacao_posicionamentos 
            WHERE pc_aval_posic_num_orientacao = #rsPosicOrgaoAvaliado.pc_aval_posic_num_orientacao#
                  and pc_aval_posic_dataHora <  <cfqueryparam value="#rsPosicOrgaoAvaliado.pc_aval_posic_dataHora#" cfsqltype="cf_sql_timestamp">
                  and pc_aval_posic_status in (4,5) and pc_aval_posic_enviado = 1
           ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc
      </cfquery>
      <!-- Inserir a data prevista de resposta no posicionamento -->
      <cfif #rsDataPrevista.pc_aval_posic_dataPrevistaResp# neq "">
            <cfquery datasource = "#application.dsn_processos#" >
                  UPDATE pc_avaliacao_posicionamentos
                  SET    pc_aval_posic_num_orgaoResp = '#rsDataPrevista.pc_aval_posic_num_orgaoResp#'
                  WHERE pc_aval_posic_id = #rsPosicOrgaoAvaliado.pc_aval_posic_id# and pc_aval_posic_num_orgaoResp is null 

            </cfquery>

             <cfquery datasource = "#application.dsn_processos#" >
                  UPDATE pc_avaliacao_posicionamentos
                  SET   pc_aval_posic_dataPrevistaResp = <cfqueryparam value="#rsDataPrevista.pc_aval_posic_dataPrevistaResp#" cfsqltype="cf_sql_varchar">
                  WHERE pc_aval_posic_id = #rsPosicOrgaoAvaliado.pc_aval_posic_id# and pc_aval_posic_dataPrevistaResp is null
            </cfquery>
      </cfif>
</cfoutput>




