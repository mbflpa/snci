<!--- Teste para a consulta em teste.cfm --->
<cfparam name="URL.ano" default="Todos" type="string">
<cfparam name="URL.limite" default="50" type="integer">
<cfparam name="URL.format" default="json" type="string">

<!--- Estrutura para simular arguments --->
<cfset arguments = {}>
<cfset arguments.ano = URL.ano>

<cfif URL.format EQ "html">
    <!--- Execução da consulta --->
    <cfoutput>
    <h1>Teste de Consulta SQL</h1>
    <p>Testando consulta para ano: <strong>#arguments.ano#</strong></p>
    <p>
        <a href="teste_query.cfm?ano=Todos&format=html">Todos</a> | 
        <a href="teste_query.cfm?ano=2023&format=html">2023</a> | 
        <a href="teste_query.cfm?ano=2022&format=html">2022</a> | 
        <a href="teste_query.cfm?ano=2021&format=html">2021</a> |
        <a href="teste_query.cfm?ano=#arguments.ano#&format=json">Ver JSON</a>
    </p>
    </cfoutput>
</cfif>

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
    
    SELECT TOP #URL.limite#
        p.pc_pesq_id, 
        p.pc_processo_id,
        processo.pc_processo_id,
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

<cfif URL.format EQ "json">
    <!--- Configurar o tipo de conteúdo para JSON --->
    <cfheader name="Content-Type" value="application/json; charset=UTF-8">
    
    <!--- Converter a query para uma estrutura mais amigável para JSON --->
    <cfset resultArray = []>
    <cfloop query="qPesquisas">
        <cfset queryRow = {}>
        <cfloop list="#qPesquisas.columnList#" index="column">
            <cfset queryRow[column] = qPesquisas[column][qPesquisas.currentRow]>
        </cfloop>
        <cfset arrayAppend(resultArray, queryRow)>
    </cfloop>
    
    <cfset jsonResult = {
        "totalResults": qPesquisas.recordCount,
        "ano": arguments.ano,
        "data": resultArray
    }>
    
    <!--- Saída do JSON --->
    <cfoutput>#serializeJSON(jsonResult)#</cfoutput>
    <cfabort>
<cfelse>
    <!--- Exibição dos resultados em HTML --->
    <cfif qPesquisas.RecordCount GT 0>
        <table border="1" cellpadding="4" cellspacing="0">
            <tr>
                <th>ID</th>
                <th>Processo ID</th>
                <th>Órgão Resp.</th>
                <th>Diretoria</th>
                <th>Órgão Origem</th>
                <th>Órgão Avaliado</th>
                <th>Tipo Demanda</th>
                <th>Data</th>
                <th>Macroprocesso</th>
            </tr>
            <cfoutput query="qPesquisas">
                <tr>
                    <td>#pc_pesq_id#</td>
                    <td>#pc_processo_id#</td>
                    <td>#orgao_resp_sigla#</td>
                    <td>#diretoria_sigla#</td>
                    <td>#orgao_origem_sigla#</td>
                    <td>#orgao_avaliado_sigla#</td>
                    <td>#tipo_demanda#</td>
                    <td>#DateFormat(pc_pesq_data_hora, "dd/mm/yyyy")#</td>
                    <td>#tipoProcesso#</td>
                </tr>
            </cfoutput>
        </table>
    <cfelse>
        <p>Nenhum resultado encontrado para o ano selecionado.</p>
    </cfif>

    <h2>Detalhes da Consulta (Debug)</h2>
    <cfdump var="#qPesquisas#" label="Resultados da consulta" top="5">
    <cfdump var="#arguments#" label="Argumentos usados">
    <cfdump var="#application.listaDiretorias#" label="Lista de Diretorias">
    
    <h2>JSON Output</h2>
    <textarea rows="5" cols="100"><cfoutput>#serializeJSON(qPesquisas)#</cfoutput></textarea>
</cfif>