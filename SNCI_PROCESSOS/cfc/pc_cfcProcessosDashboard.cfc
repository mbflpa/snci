<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">	
    
    <cffunction name="getEstatisticasProcessos" access="remote" returntype="struct" output="false" hint="Retorna estatísticas dos processos para o dashboard">
        <cfargument name="ano" type="string" required="true" hint="Ano dos processos">
        <cfargument name="mcuOrigem" type="string" required="true" hint="MCU do órgão de origem">
        <cfargument name="statusFiltro" type="string" required="false" default="Todos" hint="Filtro de status">
        
        <cfset var retorno = structNew()>
        
        <!--- Consulta para contagem total de processos - Única consulta métrica mantida --->
        <cfquery name="qryTotalProcessos" datasource="#application.dsn_processos#">
            SELECT COUNT(*) as total_processos
            FROM pc_processos p
            INNER JOIN pc_orgaos o ON p.pc_num_orgao_origem = o.pc_org_mcu
            WHERE 1=1

            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.statusFiltro NEQ "Todos">
                AND p.pc_num_status = <cfqueryparam value="#arguments.statusFiltro#" cfsqltype="cf_sql_integer">
            </cfif>
        </cfquery>

        <!--- Montar estrutura de retorno simplificada - apenas com total de processos --->
        <cfset retorno = {
            "totalProcessos": qryTotalProcessos.total_processos
        }>

        <cfreturn retorno>
    </cffunction>

    <cffunction name="getEstatisticasDetalhadas" access="remote" returntype="struct" output="false" hint="Retorna estatísticas detalhadas dos processos para os componentes do dashboard">
        <cfargument name="ano" type="string" required="true" hint="Ano dos processos">
        <cfargument name="mcuOrigem" type="string" required="true" hint="MCU do órgão de origem">
        <cfargument name="statusFiltro" type="string" required="false" default="Todos" hint="Filtro de status">
        
        <cfset var retorno = structNew()>
        
        <!--- Consulta para contagem total de processos --->
        <cfquery name="qryTotalProcessos" datasource="#application.dsn_processos#">
            SELECT COUNT(*) as total_processos
            FROM pc_processos p
            INNER JOIN pc_orgaos o ON p.pc_num_orgao_origem = o.pc_org_mcu
            WHERE 1=1

            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.statusFiltro NEQ "Todos">
                AND p.pc_num_status = <cfqueryparam value="#arguments.statusFiltro#" cfsqltype="cf_sql_integer">
            </cfif>
        </cfquery>
        
        <!--- Consulta para distribuição por status --->
        <cfquery name="qryStatusProcessos" datasource="#application.dsn_processos#">
            SELECT 
                s.pc_status_id,
                s.pc_status_descricao,
                COUNT(p.pc_processo_id) as quantidade,
                s.pc_status_card_style_body
            FROM pc_processos p
            INNER JOIN pc_orgaos o ON p.pc_num_orgao_origem = o.pc_org_mcu
            INNER JOIN pc_status s ON p.pc_num_status = s.pc_status_id
            WHERE 1=1

            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.statusFiltro NEQ "Todos">
                AND p.pc_num_status = <cfqueryparam value="#arguments.statusFiltro#" cfsqltype="cf_sql_integer">
            </cfif>
            GROUP BY s.pc_status_id, s.pc_status_descricao, s.pc_status_card_style_body
            ORDER BY quantidade DESC
        </cfquery>

        <!--- Consulta para distribuição por tipo de avaliação --->
        <cfquery name="qryTiposProcessos" datasource="#application.dsn_processos#">
            SELECT 
                t.pc_aval_tipo_id as id,
                t.pc_aval_tipo_descricao as descricaoTipoProcesso,
                p.pc_aval_tipo_nao_aplica_descricao as descricaoTipoProcessoNA,
                t.pc_aval_tipo_macroprocessos as macroprocessos,
                t.pc_aval_tipo_processoN1 as processoN1,
                t.pc_aval_tipo_processoN2 as processoN2,
                t.pc_aval_tipo_processoN3 as processoN3,
                COUNT(p.pc_processo_id) as quantidade
            FROM pc_processos p
            INNER JOIN pc_orgaos o ON p.pc_num_orgao_origem = o.pc_org_mcu
            INNER JOIN pc_avaliacao_tipos t ON p.pc_num_avaliacao_tipo = t.pc_aval_tipo_id
            WHERE 1=1
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.statusFiltro NEQ "Todos">
                AND p.pc_num_status = <cfqueryparam value="#arguments.statusFiltro#" cfsqltype="cf_sql_integer">
            </cfif>
            GROUP BY t.pc_aval_tipo_id, t.pc_aval_tipo_descricao, t.pc_aval_tipo_macroprocessos, 
                    t.pc_aval_tipo_processoN1, t.pc_aval_tipo_processoN2, t.pc_aval_tipo_processoN3, p.pc_aval_tipo_nao_aplica_descricao
            ORDER BY quantidade DESC
        </cfquery>

        <!--- Consulta para evolução mensal --->
        <cfquery name="qryEvolucaoMensal" datasource="#application.dsn_processos#">
            SELECT 
                SUBSTRING(p.pc_processo_id, 1, 2) + '/' + 
                SUBSTRING(p.pc_processo_id, 3, 2) + '/' + 
                RIGHT(p.pc_processo_id, 4) AS mes_ano,
                COUNT(p.pc_processo_id) as quantidade
            FROM pc_processos p
            INNER JOIN pc_orgaos o ON p.pc_num_orgao_origem = o.pc_org_mcu
            WHERE 1=1
           
            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.statusFiltro NEQ "Todos">
                AND p.pc_num_status = <cfqueryparam value="#arguments.statusFiltro#" cfsqltype="cf_sql_integer">
            </cfif>
            GROUP BY SUBSTRING(p.pc_processo_id, 1, 2) + '/' + 
                    SUBSTRING(p.pc_processo_id, 3, 2) + '/' + 
                    RIGHT(p.pc_processo_id, 4)
            ORDER BY mes_ano
        </cfquery>

        <!--- Consulta para distribuição por classificação --->
        <cfquery name="qryClassificacaoProcessos" datasource="#application.dsn_processos#">
            SELECT 
                COALESCE(c.pc_class_id, 0) as class_id,
                COALESCE(c.pc_class_descricao, 'Sem classificação') as class_descricao,
                COUNT(p.pc_processo_id) as quantidade
            FROM pc_processos p
            INNER JOIN pc_orgaos o ON p.pc_num_orgao_origem = o.pc_org_mcu
            LEFT JOIN pc_classificacoes c ON p.pc_num_classificacao = c.pc_class_id
            WHERE 1=1

            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.statusFiltro NEQ "Todos">
                AND p.pc_num_status = <cfqueryparam value="#arguments.statusFiltro#" cfsqltype="cf_sql_integer">
            </cfif>
            GROUP BY COALESCE(c.pc_class_id, 0), COALESCE(c.pc_class_descricao, 'Sem classificação')
            ORDER BY quantidade DESC
        </cfquery>

        <!--- Consulta para órgãos mais avaliados - Removido o TOP 10 fixo --->
        <cfquery name="qryOrgaosMaisAvaliados" datasource="#application.dsn_processos#">
            SELECT
                <cfif arguments.ano EQ "Todos">TOP 10</cfif>
                o.pc_org_sigla,
                o.pc_org_mcu,
                COUNT(p.pc_processo_id) as quantidade
            FROM pc_processos p
            INNER JOIN pc_orgaos o ON p.pc_num_orgao_avaliado = o.pc_org_mcu
            INNER JOIN pc_orgaos o2 ON p.pc_num_orgao_origem = o2.pc_org_mcu
            WHERE o2.pc_org_status = 'O'

            <cfif arguments.ano NEQ "Todos">
                AND RIGHT(p.pc_processo_id, 4) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
            </cfif>
            <cfif arguments.mcuOrigem NEQ "Todos">
                AND p.pc_num_orgao_origem = <cfqueryparam value="#arguments.mcuOrigem#" cfsqltype="cf_sql_varchar">
            </cfif>
            <cfif arguments.statusFiltro NEQ "Todos">
                AND p.pc_num_status = <cfqueryparam value="#arguments.statusFiltro#" cfsqltype="cf_sql_integer">
            </cfif>
            GROUP BY o.pc_org_sigla, o.pc_org_mcu
            ORDER BY quantidade DESC
        </cfquery>

        <!--- Preparar arrays para o retorno --->
        <cfset var statusArray = []>
        <cfloop query="qryStatusProcessos">
            <cfset arrayAppend(statusArray, {
                "id": pc_status_id,
                "descricao": pc_status_descricao,
                "quantidade": quantidade,
                "estilo": pc_status_card_style_body
            })>
        </cfloop>

        <cfset var tiposArray = []>
        <cfloop query="qryTiposProcessos">
            <!--- Verificar se a descrição está vazia ou nula --->
            <cfif Trim(descricaoTipoProcesso) EQ "">
                <!--- Preparar valores seguros para cada campo, tratando valores nulos --->
                <cfset valorMacro = Trim(macroprocessos) >
                <cfset valorN1 = Trim(processoN1)>
                <cfset valorN2 = Trim(processoN2)>
                <cfset valorN3 = Trim(processoN3)>
                
                <!--- Construir a descrição composta com os valores reais --->
                <cfset descricaoComposta = "Macroprocesso: " & valorMacro & 
                                        " - N1: " & valorN1 & 
                                        " - N2: " & valorN2 & 
                                        " - N3: " & valorN3>
            <cfelse>
                <!--- Se a descrição não estiver vazia, usar o valor original --->
                <cfset descricaoComposta = Trim(descricaoTipoProcesso)>
            </cfif>

           <cfif id EQ 2>    
                 <cfset descricaoComposta = descricaoTipoProcessoNA>
           </cfif>
                                
                <!--- Adicionar ao array com a descrição composta correta --->
                <cfset arrayAppend(tiposArray, {
                    "id": id,
                    "descricao": descricaoComposta,
                    "quantidade": quantidade
                })>
           
        </cfloop>


        <cfset var evolucaoArray = []>
        <cfloop query="qryEvolucaoMensal">
            <cfset arrayAppend(evolucaoArray, {
                "periodo": mes_ano,
                "quantidade": quantidade
            })>
        </cfloop>

        <cfset var classificacaoArray = []>
        <cfloop query="qryClassificacaoProcessos">
            <cfset arrayAppend(classificacaoArray, {
                "id": class_id,
                "descricao": class_descricao,
                "quantidade": quantidade
            })>
        </cfloop>

        <cfset var orgaosArray = []>
        <cfloop query="qryOrgaosMaisAvaliados">
            <cfset arrayAppend(orgaosArray, {
                "sigla": pc_org_sigla,
                "mcu": pc_org_mcu,
                "quantidade": quantidade
            })>
        </cfloop>

        <!--- Montar estrutura de retorno completa --->
        <cfset retorno = {
            "totalProcessos": qryTotalProcessos.total_processos,
            "distribuicaoStatus": statusArray,
            "distribuicaoTipos": tiposArray,
            "evolucaoMensal": evolucaoArray,
            "distribuicaoClassificacao": classificacaoArray,
            "orgaosMaisAvaliados": orgaosArray
        }>

        <cfreturn retorno>
    </cffunction>

    <cffunction name="getStatusProcessos" access="remote" returntype="string" returnformat="json" hint="Retorna lista de status de processos">
        <cfquery name="qryStatus" datasource="#application.dsn_processos#">
            SELECT 
                pc_status_id,
                pc_status_descricao
            FROM pc_status
            <!--- Remover filtro que está causando problema --->
            <!--- WHERE pc_status_status = 'O' --->
            ORDER BY pc_status_descricao
        </cfquery>
        
        <cfset var resultado = []>
        <cfloop query="qryStatus">
            <cfset arrayAppend(resultado, {
                "id": pc_status_id,
                "descricao": pc_status_descricao
            })>
        </cfloop>
        
        <!--- Adicionar log para diagnóstico --->
        <cflog file="processo_dashboard" text="getStatusProcessos: Encontrados #qryStatus.recordCount# status." type="Information">
        
        <!--- Garantir que retornamos algo mesmo em caso de erro --->
        <cfif arrayLen(resultado) EQ 0>
            <cfset arrayAppend(resultado, {
                "id": 0,
                "descricao": "Status não encontrados"
            })>
        </cfif>
        
        <cfreturn serializeJSON(resultado)>
    </cffunction>

    <cffunction name="getOrgaosOrigem" access="remote" returntype="string" returnformat="json" hint="Retorna lista de órgãos de origem">
        <cfquery name="qryOrgaos" datasource="#application.dsn_processos#">
            SELECT 
                pc_org_mcu,
                pc_org_sigla
            FROM pc_orgaos
            WHERE pc_org_status = 'O'
            ORDER BY pc_org_sigla
        </cfquery>
        
        <cfset var resultado = []>
        <cfloop query="qryOrgaos">
            <cfset arrayAppend(resultado, {
                "mcu": pc_org_mcu,
                "sigla": pc_org_sigla
            })>
        </cfloop>
        
        <cfreturn serializeJSON(resultado)>
    </cffunction>

    <cffunction name="getAnosDisponiveis" access="remote" returntype="string" returnformat="json" hint="Retorna anos disponíveis para processos">
        <cfquery name="qryAnos" datasource="#application.dsn_processos#">
            SELECT DISTINCT 
                RIGHT(pc_processo_id, 4) as ano
            FROM pc_processos 
            ORDER BY ano DESC
        </cfquery>
        
        <cfset var resultado = []>
        <cfloop query="qryAnos">
            <cfset arrayAppend(resultado, ano)>
        </cfloop>
        
        <cfreturn serializeJSON(resultado)>
    </cffunction>
</cfcomponent>
