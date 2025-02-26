<cfcomponent>
    <cffunction name="getPesquisas" access="remote" returntype="string" returnformat="json">
        <cfargument name="ano" type="string" required="true">
        
        <cfquery name="qPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                pc_pesq_id,
                pc_usu_matricula,
                pc_processo_id,
                pc_org_mcu,
                pc_pesq_comunicacao,
                pc_pesq_interlocucao,
                pc_pesq_reuniao_encerramento,
                pc_pesq_relatorio,
                pc_pesq_pos_trabalho,
                pc_pesq_importancia_processo,
                pc_pesq_pontualidade,
                pc_pesq_observacao,
                pc_pesq_data_hora
            FROM pc_pesquisas
            WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
            ORDER BY pc_pesq_data_hora DESC
        </cfquery>
        
        <cfreturn serializeJSON(qPesquisas)>
    </cffunction>

    <cffunction name="getEstatisticas" access="remote" returntype="struct" output="false">
        <cfargument name="ano" type="string" required="true">
        
        <cfset var retorno = structNew()>
        <cfset var qryPesquisas = "">
        <cfset var qryEvolucao = "">
        
        <cfquery name="qryPesquisas" datasource="#application.dsn_processos#">
            SELECT 
                COUNT(*) as total_pesquisas,
                COALESCE(CAST(AVG(CAST(pc_pesq_comunicacao AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_comunicacao,
                COALESCE(CAST(AVG(CAST(pc_pesq_interlocucao AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_interlocucao,
                COALESCE(CAST(AVG(CAST(pc_pesq_reuniao_encerramento AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_reuniao,
                COALESCE(CAST(AVG(CAST(pc_pesq_relatorio AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_relatorio,
                COALESCE(CAST(AVG(CAST(pc_pesq_pos_trabalho AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_pos_trabalho,
                COALESCE(CAST(AVG(CAST(pc_pesq_pontualidade AS DECIMAL(10,2))) AS DECIMAL(10,2)), 0) as media_pontualidade
            FROM pc_pesquisas 
            WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
        </cfquery>
    
        <cfquery name="qryEvolucao" datasource="#application.dsn_processos#">
            SELECT 
                FORMAT(pc_pesq_data_hora, 'yyyy-MM') as mes,
                AVG((pc_pesq_comunicacao + pc_pesq_interlocucao + pc_pesq_reuniao_encerramento + 
                     pc_pesq_relatorio + pc_pesq_pos_trabalho) / 5.0) as media_geral
            FROM pc_pesquisas 
            WHERE RIGHT(pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            GROUP BY FORMAT(pc_pesq_data_hora, 'yyyy-MM')
            ORDER BY mes
        </cfquery>
    
        <cfset mediaGeral = (
            val(qryPesquisas.media_comunicacao) +
            val(qryPesquisas.media_interlocucao) +
            val(qryPesquisas.media_reuniao) +
            val(qryPesquisas.media_relatorio) +
            val(qryPesquisas.media_pos_trabalho)
        ) / 5>
    
        <cfset var evolucaoArray = []>
        <cfloop query="qryEvolucao">
            <cfset arrayAppend(evolucaoArray, {
                "mes": mes,
                "media": NumberFormat(media_geral, "999.99")
            })>
        </cfloop>
    
        <cfquery name="rsQtdRespondidas" datasource="#application.dsn_processos#">
            SELECT COUNT(*) as total_respondidas
            FROM pc_pesquisas
            WHERE pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
        </cfquery>
        
        <!--- Calcula o índice de respostas --->
        <cfset var qtdSemPesquisa = getQuantidadeProcessosSemPesquisa(arguments.ano)>
        <cfset var totalProcessos = qtdSemPesquisa + rsQtdRespondidas.total_respondidas>
        <cfset var indiceRespostas = (totalProcessos GT 0) ? (rsQtdRespondidas.total_respondidas / totalProcessos) * 100 : 0>
    
        <cfset retorno = {
            "total": qryPesquisas.total_pesquisas,
            "comunicacao": NumberFormat(qryPesquisas.media_comunicacao, "999.99"),
            "interlocucao": NumberFormat(qryPesquisas.media_interlocucao, "999.99"),
            "reuniao": NumberFormat(qryPesquisas.media_reuniao, "999.99"), 
            "relatorio": NumberFormat(qryPesquisas.media_relatorio, "999.99"),
            "pos_trabalho": NumberFormat(qryPesquisas.media_pos_trabalho, "999.99"),
            "pontualidadePercentual": NumberFormat(qryPesquisas.media_pontualidade * 100, "999.99"),
            "mediaGeral": NumberFormat(mediaGeral, "999.99"),
            "medias": [
                val(qryPesquisas.media_comunicacao),
                val(qryPesquisas.media_interlocucao),
                val(qryPesquisas.media_reuniao),
                val(qryPesquisas.media_relatorio),
                val(qryPesquisas.media_pos_trabalho)
            ],
            "evolucaoTemporal": evolucaoArray,
            "indiceRespostas": NumberFormat(indiceRespostas, "99.99")
        }>
    
        <cfreturn retorno>
    </cffunction>

    <cffunction name="getQuantidadeProcessosSemPesquisa" access="remote" returntype="numeric" output="false">
        <cfargument name="ano" type="string" required="true">
        <cfquery name="rsProcSemPesquisa" datasource="#application.dsn_processos#" timeout="120">
            SELECT COUNT(DISTINCT processos_id) as total_sem_pesquisa 
            FROM (
                SELECT DISTINCT pc_processos.pc_processo_id as processos_id
                FROM pc_avaliacao_orientacoes
                INNER JOIN pc_avaliacoes 
                    ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos 
                    ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                AND pc_processos.pc_processo_id NOT IN 
                (
                    SELECT pc_processo_id 
                    FROM pc_pesquisas    
                )

                UNION

                SELECT DISTINCT pc_processos.pc_processo_id
                FROM pc_avaliacao_melhorias
                INNER JOIN pc_avaliacoes 
                    ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos 
                    ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                AND pc_processos.pc_processo_id NOT IN 
                (
                    SELECT pc_processo_id 
                    FROM pc_pesquisas 
                )
            ) AS unificado
        </cfquery>

        <cfreturn rsProcSemPesquisa.total_sem_pesquisa>
    </cffunction>

</cfcomponent>
