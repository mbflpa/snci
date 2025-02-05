    <cfquery name="rsProcSemPesquisa" datasource="#application.dsn_processos#" timeout="120">
      SELECT count(pc_processo_id) as totalProcessosSemPesquisa FROM
      (
          SELECT DISTINCT pc_processos.pc_processo_id  
          FROM pc_avaliacao_orientacoes
          INNER JOIN pc_avaliacoes 
              ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos 
              ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
              AND RIGHT(pc_processos.pc_processo_id, 4) >= 2000
          AND pc_processos.pc_processo_id NOT IN 
          (
              SELECT pc_processo_id 
              FROM pc_pesquisas 
              WHERE pc_org_mcu = 
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
          )

          UNION

          SELECT DISTINCT pc_processos.pc_processo_id  
          FROM pc_avaliacao_melhorias
          INNER JOIN pc_avaliacoes 
              ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
          INNER JOIN pc_processos 
              ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
          WHERE pc_aval_melhoria_num_orgao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
              AND RIGHT(pc_processos.pc_processo_id, 4) >= 2000
          AND pc_processos.pc_processo_id NOT IN 
          (
              SELECT pc_processo_id 
              FROM pc_pesquisas 
              WHERE pc_org_mcu = 
                  <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
          )
      ) AS unificado
    </cfquery>

    <cfdump var="#rsProcSemPesquisa#">