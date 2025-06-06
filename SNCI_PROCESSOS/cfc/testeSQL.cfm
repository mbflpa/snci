<cfprocessingdirective pageencoding="utf-8">
<cftransaction >
 

  <cfquery name="updateAvaliacoes" datasource="#application.dsn_processos#" timeout="120">
    UPDATE pc_processos
    SET pc_data_finalizado ='2025-01-30'
    WHERE pc_processo_id = '0100042025' 
  </cfquery>


</cftransaction>