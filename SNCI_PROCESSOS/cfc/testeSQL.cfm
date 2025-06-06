<cfprocessingdirective pageencoding="utf-8">
<cftransaction >
 

  <cfquery name="deleteAnexos" datasource="#application.dsn_processos#" timeout="120">
    DELETE FROM pc_anexos
    WHERE pc_anexo_processo_id = '0100212024'
  </cfquery>

  <cfquery datasource="#application.dsn_processos#" >
    UPDATE      pc_processos
    SET        
          pc_data_finalizado = pc_alteracao_datahora
    WHERE pc_num_status = 5 and pc_data_finalizado is null
  </cfquery>
</cftransaction>