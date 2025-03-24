<cfcomponent output="false" displayname="Componente para Dashboard de Pesquisas com DataTable">
    <cfprocessingdirective pageencoding = "utf-8">	
    <!--- Método para alimentar a tabela do dashboard com apenas filtro de ano --->
    <cffunction name="tabPesquisas" access="remote" returnformat="json" output="false">
        <cfargument name="ano" type="string" required="false" default="Todos">
        <cfargument name="limite" type="numeric" required="false" default="1000">
        
        
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
            
            SELECT TOP #arguments.limite#
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
                -- Coluna da diretoria vinculada ao órgão responsável ou sua subordinação técnica se não houver diretoria
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
                        SELECT subord.pc_org_sigla
                        FROM pc_orgaos subord
                        WHERE subord.pc_org_mcu = orgResp.pc_org_mcu_subord_tec
                    )
                ) AS diretoria_sigla
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
            WHERE 
                <cfif arguments.ano NEQ "Todos">
                    right(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
                <cfelse>
                    1=1
                </cfif>
        </cfquery>
        
        <!--- Converter para array de objetos --->
        <cfset arrResult = []>
        <cfloop query="qPesquisas">
            <cfset objPesquisa = {
                "id" = qPesquisas.pc_pesq_id,
                "processo" = qPesquisas.pc_processo_id,
                "orgao_respondente" = qPesquisas.orgao_resp_sigla,
                "ano" = qPesquisas.ano,
                "orgao_origem" = qPesquisas.orgao_origem_sigla,
                "diretoria_cs" = qPesquisas.diretoria_sigla,
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
                "observacao" = qPesquisas.pc_pesq_observacao
            }>
            <cfset arrayAppend(arrResult, objPesquisa)>
        </cfloop>
        
        <cfset response = {
            "data" = arrResult
        }>
        
        <cfreturn response>
    </cffunction>
    
</cfcomponent> 