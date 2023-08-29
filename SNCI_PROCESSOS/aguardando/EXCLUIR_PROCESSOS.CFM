
<cfprocessingdirective pageencoding = "utf-8">	


<cfquery name = "rsposicionamentos" datasource="#dsn_processos#">
    UPDATE pc_orientacao_status
    SET pc_orientacao_status_status = 'D'
    WHERE pc_orientacao_status_id = 11
</cfquery>





