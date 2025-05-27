<cfprocessingdirective pageencoding="utf-8">	

 <cfquery name="rsDelete" datasource="#application.dsn_processos#" timeout="120">
    WITH UltimosRegistros AS (
        SELECT 
            pc_aval_posic_id,
            pc_aval_posic_num_orientacao,
            pc_aval_posic_status,
            ROW_NUMBER() OVER (
                PARTITION BY pc_aval_posic_num_orientacao 
                ORDER BY pc_aval_posic_id DESC
            ) AS rn
        FROM pc_avaliacao_posicionamentos
        WHERE pc_aval_posic_num_orientacao IN (
            705, 855, 856, 857, 859, 2543, 2762, 566, 627, 629, 
            802, 970, 972, 974, 2542, 2768
        )
    )
    DELETE FROM pc_avaliacao_posicionamentos
    WHERE pc_aval_posic_id IN (
        SELECT pc_aval_posic_id
        FROM UltimosRegistros
        WHERE rn = 1
    ) AND pc_aval_posic_status = 10;
</cfquery>



<cfquery name="rsUpdate" datasource="#application.dsn_processos#" timeout="120">
    WITH UltimosRegistros AS (
        SELECT 
            pc_aval_posic_id,
            pc_aval_posic_num_orientacao,
            pc_aval_posic_status,
            ROW_NUMBER() OVER (
                PARTITION BY pc_aval_posic_num_orientacao 
                ORDER BY pc_aval_posic_id DESC
            ) AS rn
        FROM pc_avaliacao_posicionamentos
        WHERE pc_aval_posic_num_orientacao IN (
            705, 855, 856, 857, 859, 2543, 2762, 566, 627, 629, 
            802, 970, 972, 974, 2542, 2768
        )
    )
    UPDATE o
    SET o.pc_aval_orientacao_status = u.pc_aval_posic_status
    FROM pc_avaliacao_orientacoes o
    JOIN UltimosRegistros u 
        ON o.pc_aval_orientacao_id = u.pc_aval_posic_num_orientacao
    WHERE u.rn = 1;
</cfquery>


<!--- Primeiro UPDATE --->
<cfquery name="atualizaAvaliacoes" datasource="#application.dsn_processos#" timeout="120">
    WITH UltimosRegistros AS (
        SELECT 
            pc_aval_posic_id,
            pc_aval_posic_num_orientacao,
            pc_aval_posic_status,
            ROW_NUMBER() OVER (
                PARTITION BY pc_aval_posic_num_orientacao 
                ORDER BY pc_aval_posic_id DESC
            ) AS rn
        FROM pc_avaliacao_posicionamentos
        WHERE pc_aval_posic_num_orientacao IN (
            705, 855, 856, 857, 859, 2543, 2762, 566, 627, 629, 
            802, 970, 972, 974, 2542, 2768
        )
    ),
    Itens AS (
        SELECT 
            o.pc_aval_orientacao_num_aval,
            o.pc_aval_orientacao_status
        FROM pc_avaliacao_orientacoes o
        WHERE o.pc_aval_orientacao_id IN (
            SELECT pc_aval_posic_num_orientacao 
            FROM UltimosRegistros
            WHERE rn = 1
        )
    )
    UPDATE i
    SET i.pc_aval_status = 6
    FROM pc_avaliacoes i
    WHERE i.pc_aval_id IN (
        SELECT pc_aval_orientacao_num_aval FROM Itens
    );
</cfquery>

<!--- Segundo UPDATE --->
<cfquery name="atualizaProcessos" datasource="#application.dsn_processos#" timeout="120">
    WITH UltimosRegistros AS (
        SELECT 
            pc_aval_posic_id,
            pc_aval_posic_num_orientacao,
            pc_aval_posic_status,
            ROW_NUMBER() OVER (
                PARTITION BY pc_aval_posic_num_orientacao 
                ORDER BY pc_aval_posic_id DESC
            ) AS rn
        FROM pc_avaliacao_posicionamentos
        WHERE pc_aval_posic_num_orientacao IN (
            705, 855, 856, 857, 859, 2543, 2762, 566, 627, 629, 
            802, 970, 972, 974, 2542, 2768
        )
    ),
    Itens AS (
        SELECT 
            o.pc_aval_orientacao_num_aval,
            o.pc_aval_orientacao_status
        FROM pc_avaliacao_orientacoes o
        WHERE o.pc_aval_orientacao_id IN (
            SELECT pc_aval_posic_num_orientacao 
            FROM UltimosRegistros
            WHERE rn = 1
        )
    ),
    Processos AS (
        SELECT pc_aval_processo 
        FROM pc_avaliacoes
        WHERE pc_aval_id IN (
            SELECT pc_aval_orientacao_num_aval FROM Itens
        )
    )
    UPDATE pc_processos
    SET pc_processos.pc_num_status = 4
    WHERE pc_processo_id IN (
        SELECT pc_aval_processo FROM Processos
    );
</cfquery>
