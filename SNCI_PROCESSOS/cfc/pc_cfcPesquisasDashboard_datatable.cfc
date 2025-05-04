<cfcomponent output="false" displayname="Componente para Dashboard de Pesquisas com DataTable">
    <cfprocessingdirective pageencoding = "utf-8">	
    <!--- Método para alimentar a tabela do dashboard com apenas filtro de ano --->
    <cffunction name="tabPesquisas" access="remote" returnformat="json" output="false">
        <cfargument name="ano" type="string" required="false" default="Todos">
       
        
        <!--- Consulta principal para obter os dados da tabela --->
        <cfquery name="qPesquisas" datasource="#application.dsn_processos#">
            WITH OrgHierarchy AS (
                -- Nível base: o próprio órgão
                SELECT 
                    org.pc_org_mcu,
                    org.pc_org_mcu_subord_tec,
                    org.pc_org_sigla,
                    0 AS nivel
                FROM 
                    pc_orgaos org
                
                UNION ALL
                
                -- Níveis recursivos: sobe na hierarquia
                SELECT 
                    h.pc_org_mcu,
                    parent.pc_org_mcu_subord_tec,
                    parent.pc_org_sigla,
                    h.nivel + 1
                FROM 
                    OrgHierarchy h
                JOIN 
                    pc_orgaos parent ON h.pc_org_mcu_subord_tec = parent.pc_org_mcu
                WHERE 
                    h.nivel < 10 -- Limitação para evitar loops infinitos
            )
            
            SELECT 
                p.pc_pesq_id, 
                p.pc_processo_id,
                processo.pc_processo_id,
                right(p.pc_processo_id, 4) AS ano,
                p.pc_org_mcu,
                orgResp.pc_org_sigla AS orgao_resp_sigla,
                p.pc_pesq_comunicacao,
                p.pc_pesq_interlocucao,
                p.pc_pesq_reuniao_encerramento,
                p.pc_pesq_relatorio,
                p.pc_pesq_pos_trabalho,
                p.pc_pesq_importancia_processo,
                p.pc_pesq_pontualidade,
                p.pc_pesq_observacao,
                p.pc_pesq_data_hora,
                processo.pc_num_orgao_origem,
                orgOrigem.pc_org_sigla AS orgao_origem_sigla,
                processo.pc_num_orgao_avaliado,
                orgAvaliado.pc_org_sigla AS orgao_avaliado_sigla,
                -- Coluna da diretoria vinculada ao órgão responsável ou Correios Sede se não houver diretoria
                COALESCE(
                    (
                        SELECT TOP 1 dir.pc_org_sigla
                        FROM pc_orgaos dir
                        JOIN OrgHierarchy h ON h.pc_org_mcu_subord_tec = dir.pc_org_mcu
                        WHERE h.pc_org_mcu = p.pc_org_mcu
                        AND dir.pc_org_mcu IN (#ListQualify(application.listaDiretorias, "'")#)
                        ORDER BY h.nivel ASC
                    ),
                    (
                        'cs'
                    )
                ) AS diretoria_sigla
                -- Coluna diretoriaMcu
                ,COALESCE(
                    (
                        SELECT TOP 1 dir.pc_org_mcu
                        FROM pc_orgaos dir
                        JOIN OrgHierarchy h ON h.pc_org_mcu_subord_tec = dir.pc_org_mcu
                        WHERE h.pc_org_mcu = p.pc_org_mcu
                        AND dir.pc_org_mcu IN (#ListQualify(application.listaDiretorias, "'")#)
                        ORDER BY h.nivel ASC
                    ),
                    (
                        '00425282'
                    )
                ) AS diretoriaMcu
                , CASE 
                    WHEN pc_avaliacao_tipos.pc_aval_tipo_macroprocessos IS NULL OR LTRIM(RTRIM(pc_avaliacao_tipos.pc_aval_tipo_macroprocessos)) = '' THEN NULL 
                    ELSE CONCAT(
                        'Macroprocesso:<strong> ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,'</strong>',
                        ' -> N1:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,'</strong>',
                        ' -> N2:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,'</strong>','.'
                    )
                END as tipoProcesso,
                CASE 
                    WHEN processo.pc_tipo_demanda = 'P' THEN 'Planejada'
                    WHEN processo.pc_tipo_demanda = 'E' THEN 'Extraordinária'
                    ELSE processo.pc_tipo_demanda
                END AS tipo_demanda
            FROM 
                pc_pesquisas p
            INNER JOIN 
                pc_processos processo ON p.pc_processo_id = processo.pc_processo_id
            LEFT JOIN 
                pc_orgaos orgResp ON p.pc_org_mcu = orgResp.pc_org_mcu
            LEFT JOIN 
                pc_orgaos orgOrigem ON processo.pc_num_orgao_origem = orgOrigem.pc_org_mcu
            LEFT JOIN
                pc_orgaos orgAvaliado on processo.pc_num_orgao_avaliado = orgAvaliado.pc_org_mcu
            LEFT JOIN 
                pc_avaliacao_tipos on processo.pc_num_avaliacao_tipo = pc_aval_tipo_id
            WHERE RIGHT(processo.pc_processo_id, 4) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#application.anoPesquisaOpiniao#">
                <cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 11 and #application.rsUsuarioParametros.pc_usu_perfil# neq 16>
                    AND processo.pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
                </cfif>
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(processo.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                </cfif>
        </cfquery>
        
        <!--- Calcular médias por pesquisa e NPS por órgão --->
        <cfset mediasOrgaos = structNew()>
        <cfset contadoresOrgaos = structNew()>
        <cfset arrResult = []>
        
        <!--- Primeiro loop: calcular média de cada pesquisa e agrupar por órgão --->
        <cfloop query="qPesquisas">
            <cfset mediaPesquisa = 0>
            <cfset countNotas = 0>
            <cfset somaNotas = 0>
            
            <!--- Calcular média da pesquisa atual --->
            <cfset notas = [
                val(qPesquisas.pc_pesq_comunicacao),
                val(qPesquisas.pc_pesq_interlocucao),
                val(qPesquisas.pc_pesq_reuniao_encerramento),
                val(qPesquisas.pc_pesq_relatorio),
                val(qPesquisas.pc_pesq_pos_trabalho),
                val(qPesquisas.pc_pesq_importancia_processo)
            ]>
            
            <cfloop array="#notas#" index="nota">
                <cfif nota GT 0>
                    <cfset somaNotas += nota>
                    <cfset countNotas++>
                </cfif>
            </cfloop>
            
            <cfif countNotas GT 0>
                <cfset mediaPesquisa = somaNotas / countNotas>
                
                <!--- Agrupar médias por órgão respondente --->
                <cfif len(trim(qPesquisas.orgao_resp_sigla))>
                    <cfif NOT structKeyExists(mediasOrgaos, qPesquisas.orgao_resp_sigla)>
                        <cfset mediasOrgaos[qPesquisas.orgao_resp_sigla] = 0>
                        <cfset contadoresOrgaos[qPesquisas.orgao_resp_sigla] = 0>
                    </cfif>
                    <cfset mediasOrgaos[qPesquisas.orgao_resp_sigla] += mediaPesquisa>
                    <cfset contadoresOrgaos[qPesquisas.orgao_resp_sigla]++>
                </cfif>
            </cfif>
            
            <!--- Adicionar pesquisa ao array de resultados com a média da pesquisa --->
            <cfset objPesquisa = {
                "id" = qPesquisas.pc_pesq_id,
                "processo" = qPesquisas.pc_processo_id,
                "orgao_respondente" = qPesquisas.orgao_resp_sigla,
                "orgao_respondente_mcu" = qPesquisas.pc_org_mcu,
                "ano" = qPesquisas.ano,
                "orgao_origem" = qPesquisas.orgao_origem_sigla,
                "orgao_origem_mcu" = qPesquisas.pc_num_orgao_origem,
                "diretoria_cs" = qPesquisas.diretoria_sigla,
                "diretoria_mcu" = qPesquisas.diretoriaMcu,
                "orgao_avaliado" = qPesquisas.orgao_avaliado_sigla,
                "tipo_demanda" = qPesquisas.tipo_demanda,
                "tipo_processo" = qPesquisas.tipoProcesso,
                "data" = qPesquisas.pc_pesq_data_hora,
                "comunicacao" = qPesquisas.pc_pesq_comunicacao,
                "interlocucao" = qPesquisas.pc_pesq_interlocucao,
                "reuniao" = qPesquisas.pc_pesq_reuniao_encerramento,
                "relatorio" = qPesquisas.pc_pesq_relatorio,
                "pos_trabalho" = qPesquisas.pc_pesq_pos_trabalho,
                "importancia" = qPesquisas.pc_pesq_importancia_processo,
                "pontualidade" = qPesquisas.pc_pesq_pontualidade,
                "observacao" = qPesquisas.pc_pesq_observacao,
                "media_pesquisa" = round(mediaPesquisa * 10) / 10
            }>
            <cfset arrayAppend(arrResult, objPesquisa)>
        </cfloop>
        
        <!--- Calcular média final para cada órgão e classificação NPS --->
        <cfset classificacoesNPS = structNew()>
        <cfloop collection="#mediasOrgaos#" item="orgao">
            <cfif contadoresOrgaos[orgao] GT 0>
                <cfset mediaFinalOrgao = mediasOrgaos[orgao] / contadoresOrgaos[orgao]>
                
                <cfif mediaFinalOrgao GTE 9>
                    <cfset classificacoesNPS[orgao] = "Promotor">
                <cfelseif mediaFinalOrgao GTE 7>
                    <cfset classificacoesNPS[orgao] = "Neutro">
                <cfelse>
                    <cfset classificacoesNPS[orgao] = "Detrator">
                </cfif>
            </cfif>
        </cfloop>
        
        <!--- Adicionar classificação NPS aos resultados --->
        <cfloop array="#arrResult#" index="objPesquisa">
            <cfif structKeyExists(classificacoesNPS, objPesquisa.orgao_respondente)>
                <cfset objPesquisa["classificacao_nps"] = classificacoesNPS[objPesquisa.orgao_respondente]>
            <cfelse>
                <cfset objPesquisa["classificacao_nps"] = "">
            </cfif>
        </cfloop>
        
        <cfset response = {
            "data" = arrResult
        }>
        
        <cfreturn response>
    </cffunction>

     <cffunction name="tabProcessosElegiveis" access="remote" returnformat="plain" output="false">
        <cfargument name="ano" type="string" required="false" default="Todos">
        

        <!--- Consulta principal para contar processos --->
        <cfquery name="rsProcessosAssociados" datasource="#application.dsn_processos#" timeout="120">
            SELECT DISTINCT COUNT(*) AS total_processos FROM
            (
                SELECT DISTINCT pc_processos.pc_processo_id, orgaoResp.pc_org_mcu as orgaoRespMcu
                FROM pc_avaliacao_posicionamentos posic
                INNER JOIN pc_orgaos orgaoResp ON posic.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
                INNER JOIN pc_avaliacao_orientacoes o on posic.pc_aval_posic_num_orientacao = o.pc_aval_orientacao_id
                INNER JOIN pc_avaliacoes ON o.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos  ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE pc_processos.pc_num_status in(4,5) AND orgaoResp.pc_org_controle_interno='N'
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                </cfif>
                
                UNION

                SELECT DISTINCT pc_processos.pc_processo_id, orgaoResp.pc_org_mcu as orgaoRespMcu
                FROM pc_avaliacao_melhorias
                INNER JOIN pc_orgaos orgaoResp on pc_avaliacao_melhorias.pc_aval_melhoria_num_orgao = orgaoResp.pc_org_mcu
                INNER JOIN pc_avaliacoes ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
                INNER JOIN pc_processos  ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
                WHERE pc_processos.pc_num_status in(4,5)
                <cfif arguments.ano NEQ "Todos">
                    AND RIGHT(pc_processos.pc_processo_id, 4) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ano#">
                </cfif>
                
            ) AS unificado
        </cfquery>
        
        <cfreturn val(rsProcessosAssociados.total_processos)>
     </cffunction>
    
</cfcomponent>