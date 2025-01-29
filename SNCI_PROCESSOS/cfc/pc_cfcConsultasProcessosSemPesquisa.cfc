<cfcomponent>
  <cfprocessingdirective pageencoding = "utf-8">

  <cffunction name="obterProcessosSemPesquisa" access="remote" returntype="string" output="false">
    <cfset var result = "">

    <cftry>
      <cfquery name="qryProcessosSemPesquisa" datasource="#application.dsn_processos#">
        SELECT 
          pc_processo_id,
          pc_num_sei,
          pc_num_rel_sei,
          pc_num_orgao_avaliado
        FROM pc_processos
        WHERE pc_processo_id NOT IN (SELECT pc_processo_id FROM pc_pesquisas)
      </cfquery>

      <cfset result = serializeJSON(qryProcessosSemPesquisa)>
    <cfcatch>
      <cfset result = serializeJSON({"error": "Erro ao buscar processos: #cfcatch.message#"})>
    </cfcatch>
    </cftry>

    <cfreturn result>
  </cffunction>

</cfcomponent>
