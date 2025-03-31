<h1>Teste de Consultas de Processos</h1>

<!--- Consulta para contar processos sem pesquisa --->
<cfquery name="rsProcessosAssociados" datasource="#application.dsn_processos#" timeout="120">
            SELECT DISTINCT *  FROM
            (
                SELECT DISTINCT pc_processos.pc_processo_id
                FROM pc_avaliacao_orientacoes
                INNER JOIN pc_avaliacoes 
                    ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos 
                    ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE pc_processos.pc_num_status in(4,5)
               
                    AND RIGHT(pc_processos.pc_processo_id, 4) = 2024

                UNION

                SELECT DISTINCT pc_processos.pc_processo_id
                FROM pc_avaliacao_melhorias
                INNER JOIN pc_avaliacoes 
                    ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos 
                    ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE pc_processos.pc_num_status in(4,5)
               
                    AND RIGHT(pc_processos.pc_processo_id, 4) = 2024
               
                
            ) AS unificado
        </cfquery>>



<h2>Total de Processos Sem Pesquisa</h2>
<cfdump var="#rsProcessosAssociados#">
