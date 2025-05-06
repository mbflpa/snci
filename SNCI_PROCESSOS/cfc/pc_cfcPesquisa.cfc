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
      <cfargument name="pc_processo_id" type="string" required="true" >

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
              pc_processo_id,
              pc_usu_matricula,
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
              <cfqueryparam value="#arguments.pc_processo_id#" cfsqltype="cf_sql_varchar" maxlength="10">,
              <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar" maxlength="50">,
              <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar" maxlength="8">
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

  <!-- Função para obter os processos sem pesquisa cadastrada em formato JSON -->
  <cffunction name="getProcessosSemPesquisaJSON" access="remote" returntype="any" returnformat="json" output="false">

    <cfset var rsProcTab = ''>
    <cfset var processos = []>
    <cfset var processo = {}>

    

    <cfquery name="rsProcSemPesquisa" datasource="#application.dsn_processos#" timeout="120">
      
      SELECT pc_processo_id FROM
      (
          SELECT DISTINCT pc_processos.pc_processo_id  
          FROM pc_avaliacao_posicionamentos 
          INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
          INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos  ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE pc_avaliacao_posicionamentos.pc_aval_posic_enviado = 1
                AND pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
                AND RIGHT(pc_processos.pc_processo_id, 4) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.anoPesquisaOpiniao#">
                AND NOT EXISTS (
                                    SELECT 1 
                                    FROM pc_pesquisas 
                                    WHERE pc_pesquisas.pc_processo_id = pc_processos.pc_processo_id
                                    AND pc_pesquisas.pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
                                )

          UNION

          SELECT DISTINCT pc_processos.pc_processo_id  
          FROM pc_avaliacao_melhorias
          INNER JOIN pc_avaliacoes ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos  ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE pc_aval_melhoria_num_orgao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
              AND RIGHT(pc_processos.pc_processo_id, 4) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.anoPesquisaOpiniao#">
              AND NOT EXISTS (
                                SELECT 1 
                                FROM pc_pesquisas 
                                WHERE pc_pesquisas.pc_processo_id = pc_processos.pc_processo_id
                                AND pc_pesquisas.pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
                            )
          UNION

          SELECT DISTINCT pc_processos.pc_processo_id
          FROM pc_avaliacoes
          INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE pc_num_orgao_avaliado = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
          GROUP BY pc_processos.pc_processo_id
          HAVING COUNT(*) = (
              SELECT COUNT(*)
              FROM pc_avaliacoes a2
              WHERE a2.pc_aval_processo = pc_processos.pc_processo_id
              AND a2.pc_aval_classificacao = 'L'
          )
      ) AS unificado
     
    </cfquery>


    <!--- Construção da lista de IDs para utilizar na cláusula IN --->
    <cfset var idList = ValueList(rsProcSemPesquisa.pc_processo_id)>


    <!--- Consulta para obter os dados dos processos utilizando a lista construída --->
    <cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120">
      SELECT DISTINCT pc_processos.pc_processo_id,
            LEFT(pc_processos.pc_num_sei, 5) + '.' + SUBSTRING(pc_processos.pc_num_sei, 6, 6) + '/' + SUBSTRING(pc_processos.pc_num_sei, 12, 4) + '-' + RIGHT(pc_processos.pc_num_sei, 2) AS sei,
            pc_processos.pc_num_rel_sei,
            pc_processos.pc_num_avaliacao_tipo,
            pc_orgaos.pc_org_mcu AS orgao_avaliado_mcu,
            pc_orgaos.pc_org_sigla AS orgao_avaliado_sigla,
            pc_orgaos.pc_org_se_sigla AS orgao_avaliado_se_sigla,
            pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
            pc_avaliacao_tipos.pc_aval_tipo_processoN1,
            pc_avaliacao_tipos.pc_aval_tipo_processoN2,
            pc_avaliacao_tipos.pc_aval_tipo_processoN3,
            RIGHT(pc_processos.pc_processo_id, 4) as ano
      FROM pc_processos
      LEFT JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
      LEFT JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu
      WHERE pc_processos.pc_processo_id in (<cfqueryparam value="#idList#" cfsqltype="cf_sql_varchar" list="true">)
      ORDER BY ano, pc_processos.pc_processo_id
    </cfquery>

    <cfloop query="rsProcTab">
      <cfset processo = {
        pc_processo_id: rsProcTab.pc_processo_id,
        sei: rsProcTab.sei,
        pc_num_rel_sei: rsProcTab.pc_num_rel_sei,
        pc_num_avaliacao_tipo: rsProcTab.pc_num_avaliacao_tipo,
        orgao_avaliado_mcu: rsProcTab.orgao_avaliado_mcu,
        orgao_avaliado_sigla: rsProcTab.orgao_avaliado_sigla,
        orgao_avaliado_se_sigla: rsProcTab.orgao_avaliado_se_sigla,
        pc_aval_tipo_macroprocessos: rsProcTab.pc_aval_tipo_macroprocessos,
        pc_aval_tipo_processoN1: rsProcTab.pc_aval_tipo_processoN1,
        pc_aval_tipo_processoN2: rsProcTab.pc_aval_tipo_processoN2,
        pc_aval_tipo_processoN3: rsProcTab.pc_aval_tipo_processoN3
        
      }>
      <cfset arrayAppend(processos, processo)>
    </cfloop>

    <cfreturn processos>
  </cffunction>



  <cffunction name="abreFormPesquisa"   access="remote" hint="abre o modal avaliacaoModal da página includes/pc_Pesquisa.cfm" >

    <cfargument name="pc_processo_id" type="string" required="true" >
    <cfquery name="rsDadosProcessoPesquisa" datasource="#application.dsn_processos#">
      SELECT pc_processo_id, pc_num_sei, pc_num_rel_sei, pc_aval_tipo_processoN2
      FROM pc_processos
      INNER JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
      WHERE pc_processo_id = <cfqueryparam value="#arguments.pc_processo_id#" cfsqltype="cf_sql_varchar">
    </cfquery>

    
    <cfinclude template="../includes/pc_Pesquisa.cfm">
   
  </cffunction>

</cfcomponent>