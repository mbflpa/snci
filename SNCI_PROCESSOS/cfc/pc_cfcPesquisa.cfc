<cfcomponent>
  <cfprocessingdirective pageencoding = "utf-8">	
  
  <cffunction name="salvarPesquisa" access="remote" returntype="string" output="false">
      <cfargument name="pc_pesq_comunicacao" type="numeric" required="true">
      <cfargument name="pc_pesq_interlocucao" type="numeric" required="true">
      <cfargument name="pc_pesq_reuniao_encerramento" type="numeric" required="true">
      <cfargument name="pc_pesq_relatorio" type="numeric" required="true">
      <cfargument name="pc_pesq_pos_trabalho" type="numeric" required="true">
      <cfargument name="pc_pesq_importancia_processo" type="numeric" required="true">
      <cfargument name="pc_pesq_pontualidade" type="numeric" required="true">
      <cfargument name="pc_pesq_observacao" type="string" required="false" default="">
      <cfargument name="pc_usu_matricula" type="string" required="false" default="88888888">
      <cfargument name="pc_processo_id" type="string" required="false" default="0100042024">
      <cfargument name="pc_org_mcu" type="string" required="false" default="00436967">

      <!-- Tentativa de salvar os dados -->
      <cfquery datasource="#application.dsn_processos#">
          INSERT INTO pc_pesquisas (
              pc_pesq_comunicacao,
              pc_pesq_interlocucao,
              pc_pesq_reuniao_encerramento,
              pc_pesq_relatorio,
              pc_pesq_pos_trabalho,
              pc_pesq_importancia_processo,
              pc_pesq_pontualidade,
              pc_pesq_observacao,
              pc_usu_matricula,
              pc_processo_id,
              pc_org_mcu
          )
          VALUES (
              <cfqueryparam value="#arguments.pc_pesq_comunicacao#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#arguments.pc_pesq_interlocucao#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#arguments.pc_pesq_reuniao_encerramento#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#arguments.pc_pesq_relatorio#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#arguments.pc_pesq_pos_trabalho#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#arguments.pc_pesq_importancia_processo#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#arguments.pc_pesq_pontualidade#" cfsqltype="cf_sql_integer">,
              <cfqueryparam value="#arguments.pc_pesq_observacao#" cfsqltype="cf_sql_varchar" maxlength="255">,
              <cfqueryparam value="#arguments.pc_usu_matricula#" cfsqltype="cf_sql_varchar" maxlength="50">,
              <cfqueryparam value="#arguments.pc_processo_id#" cfsqltype="cf_sql_varchar" maxlength="10">,
              <cfqueryparam value="#arguments.pc_org_mcu#" cfsqltype="cf_sql_varchar" maxlength="8">
          )
      </cfquery>
     
  </cffunction>
  
  <!-- Função para obter os dados das pesquisas em formato JSON -->
  <cffunction name="obterPesquisas" access="remote" returntype="string" output="false">
    <cfset var result = "">

    <cftry>
      <cfquery name="qryPesquisas" datasource="#application.dsn_processos#">
        SELECT 
          pc_pesq_comunicacao,
          pc_pesq_interlocucao,
          pc_pesq_reuniao_encerramento,
          pc_pesq_relatorio,
          pc_pesq_pos_trabalho,
          pc_pesq_importancia_processo,
          pc_pesq_pontualidade,
          pc_pesq_observacao,
          pc_usu_matricula,
          pc_processo_id,
          pc_org_mcu,
          pc_pesq_dataResposta
        FROM pc_pesquisas
      </cfquery>

      <cfset result = serializeJSON(qryPesquisas)>
    <cfcatch>
      <cfset result = serializeJSON({"error": "Erro ao buscar pesquisas: #cfcatch.message#"})>
    </cfcatch>
    </cftry>

    <cfreturn result>
  </cffunction>

</cfcomponent>