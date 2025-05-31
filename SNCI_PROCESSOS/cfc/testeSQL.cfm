<cfprocessingdirective pageencoding="utf-8">

<cfquery name="rsEditarPM" datasource="#application.dsn_processos#" timeout="120">	
    UPDATE pc_avaliacao_melhorias
    SET
      pc_aval_melhoria_sugestao = ''
      ,pc_aval_melhoria_naoAceita_justif = ''
    WHERE pc_aval_melhoria_id in(5123,5124,5125,5126,5127)
</cfquery>
