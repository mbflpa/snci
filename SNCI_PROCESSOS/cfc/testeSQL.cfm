<cfprocessingdirective pageencoding="utf-8">	
<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120">
    SELECT DISTINCT pc_processos.pc_processo_id
            FROM pc_avaliacoes
            INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
             GROUP BY pc_processos.pc_processo_id
            HAVING COUNT(*) = (
                SELECT COUNT(*)
                FROM pc_avaliacoes a2
                WHERE a2.pc_aval_processo = pc_processos.pc_processo_id
                AND a2.pc_aval_classificacao = 'L'
            )
</cfquery>
<cfdump var="#rsProcTab#" label="Processos com todas as avaliações L" format="html" />