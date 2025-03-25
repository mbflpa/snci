<h1>Teste de Consultas de Processos</h1>

<!--- Consulta para contar processos sem pesquisa --->
<cfquery name="rsProcessosAssociados" datasource="#application.dsn_processos#" timeout="120">
      SELECT DISTINCT * from
      (
          SELECT DISTINCT pc_processos.pc_processo_id as processo, pc_aval_orientacao_mcu_orgaoResp as orgaoResp  
          FROM pc_avaliacao_orientacoes
          INNER JOIN pc_avaliacoes 
              ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos 
              ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE RIGHT(pc_processos.pc_processo_id, 4) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.anoPesquisaOpiniao#">

          UNION


          SELECT DISTINCT pc_processos.pc_processo_id as processo, pc_aval_melhoria_num_orgao as orgaoResp  
          FROM pc_avaliacao_melhorias
          INNER JOIN pc_avaliacoes 
              ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos 
              ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE RIGHT(pc_processos.pc_processo_id, 4) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.anoPesquisaOpiniao#">
          
      ) AS unificado
      order by processo 
</cfquery>



<h2>Total de Processos Sem Pesquisa</h2>
<cfdump var="#rsProcessosAssociados#">
