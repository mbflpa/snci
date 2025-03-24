<cfquery name="rsProcSemPesquisa" datasource="#application.dsn_processos#" timeout="120">
      SELECT pc_processo_id FROM
      (
          SELECT DISTINCT pc_processos.pc_processo_id  
          FROM pc_avaliacao_orientacoes
          INNER JOIN pc_avaliacoes 
              ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos 
              ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
              AND RIGHT(pc_processos.pc_processo_id, 4) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.anoPesquisaOpiniao#">

          UNION

          SELECT DISTINCT pc_processos.pc_processo_id  
          FROM pc_avaliacao_melhorias
          INNER JOIN pc_avaliacoes 
              ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos 
              ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE pc_aval_melhoria_num_orgao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
              AND RIGHT(pc_processos.pc_processo_id, 4) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.anoPesquisaOpiniao#">
          
      ) AS unificado
    </cfquery>

