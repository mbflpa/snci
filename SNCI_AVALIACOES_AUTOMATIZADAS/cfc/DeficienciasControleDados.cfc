<cfcomponent displayname="DeficienciasControleDados" hint="Centraliza dados de deficiências de controle para múltiplos componentes">

    <cffunction name="buscarDadosCompletos" access="private" returntype="struct" hint="Busca todos os dados da base uma única vez">
        <cfargument name="sk_mcu" type="numeric" required="true" hint="Código da unidade MCU">
        <cfargument name="mesAnoFiltro" type="string" required="false" default="" hint="Filtro por mês no formato yyyy-MM">
        
        <cfset var chaveCache = "cacheAADeficiencias_" & arguments.sk_mcu & "_" & arguments.mesAnoFiltro>
        
        <!--- Verificar se os dados já estão em cache nativo --->
        <cfset var dadosCompletos = cacheGet(chaveCache)>
        <cfif NOT isDefined("dadosCompletos") OR isNull(dadosCompletos)>
            
            <cfset dadosCompletos = structNew()>
            
            <!--- Calcular intervalo de datas se há filtro --->
            <cfif len(trim(arguments.mesAnoFiltro))>
                <cfset var anoFiltro = listFirst(arguments.mesAnoFiltro, "-")>
                <cfset var mesFiltro = listLast(arguments.mesAnoFiltro, "-")>
                <cfset var inicioMes = createDateTime(anoFiltro, mesFiltro, 1, 0, 0, 0)>
                <cfset var fimMes = dateAdd("d", -1, dateAdd("m", 1, inicioMes))>
            </cfif>
            
            <!--- Consulta principal: dados históricos gerais --->
            <cfquery name="rsDadosHistoricos" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT   COUNT(DISTINCT CASE WHEN suspenso = 0 AND sk_grupo_item <> 12 THEN sk_grupo_item END) AS testesEnvolvidos
                        ,SUM(CASE WHEN sigla_apontamento = 'N' THEN NC_Eventos ELSE 0 END) AS totalEventos
                        ,COUNT(CASE WHEN sigla_apontamento in('C','N') THEN sigla_apontamento END) AS testesAplicados
                        ,COUNT(CASE WHEN sigla_apontamento = 'C' THEN sigla_apontamento END) AS conformes
                        ,COUNT(CASE WHEN sigla_apontamento = 'N' THEN sigla_apontamento END) AS deficienciasControle
                        ,SUM(
                                COALESCE(valor_falta, 0) + 
                                COALESCE(valor_sobra, 0) + 
                                CASE 
                                    WHEN nm_teste <> '239-4' THEN COALESCE(valor_risco, 0)
                                    ELSE 0
                                END
                            ) AS valorEnvolvido
                        ,SUM(nr_reincidente) AS reincidencia
                FROM fato_verificacao f
                WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
                <cfif len(trim(arguments.mesAnoFiltro))>
                  AND f.data_encerramento BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#inicioMes#">
                                               AND <cfqueryparam cfsqltype="cf_sql_date" value="#fimMes#">
                </cfif>
            </cfquery>

            <!--- Consulta: últimos dois meses disponíveis (ou mês específico se filtrado) --->
            <cfquery name="rsUltimosMeses" datasource="#application.dsn_avaliacoes_automatizadas#">
                <cfif len(trim(arguments.mesAnoFiltro))>
                    SELECT '<cfoutput>#arguments.mesAnoFiltro#</cfoutput>' AS mes_ano
                <cfelse>
                    SELECT TOP 2 FORMAT(data_encerramento, 'yyyy-MM') AS mes_ano
                    FROM fato_verificacao
                    WHERE data_encerramento IS NOT NULL
                      AND sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
                      AND sk_grupo_item <> 12
                    GROUP BY FORMAT(data_encerramento, 'yyyy-MM')
                    ORDER BY mes_ano DESC
                </cfif>
            </cfquery>

            <!--- Consulta: dados detalhados por assunto e mês --->
            <cfquery name="rsDadosDetalhados" datasource="#application.dsn_avaliacoes_automatizadas#">
                <cfif len(trim(arguments.mesAnoFiltro))>
                    SELECT 
                        p.MANCHETE,
                        p.sk_grupo_item,
                        FORMAT(f.data_encerramento, 'yyyy-MM') AS mes_ano,
                        SUM(f.NC_Eventos) AS total_eventos
                    FROM fato_verificacao f
                    INNER JOIN dim_teste_processos p ON f.sk_grupo_item = p.sk_grupo_item
                    WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
                      AND f.sk_grupo_item <> 12
                      AND f.suspenso = 0
                      AND f.data_encerramento BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#inicioMes#">
                                                   AND <cfqueryparam cfsqltype="cf_sql_date" value="#fimMes#">
                    GROUP BY p.MANCHETE, p.sk_grupo_item, FORMAT(f.data_encerramento, 'yyyy-MM')
                    ORDER BY p.MANCHETE
                <cfelse>
                    WITH UltimosMeses AS (
                        SELECT TOP 2 FORMAT(data_encerramento, 'yyyy-MM') AS mes_ano
                        FROM fato_verificacao
                        WHERE data_encerramento IS NOT NULL
                          AND sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
                          AND sk_grupo_item <> 12
                        GROUP BY FORMAT(data_encerramento, 'yyyy-MM')
                        ORDER BY mes_ano DESC
                    )
                    SELECT 
                        p.MANCHETE,
                        p.sk_grupo_item,
                        FORMAT(f.data_encerramento, 'yyyy-MM') AS mes_ano,
                        SUM(f.NC_Eventos) AS total_eventos
                    FROM fato_verificacao f
                    INNER JOIN dim_teste_processos p ON f.sk_grupo_item = p.sk_grupo_item
                    WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
                      AND f.sk_grupo_item <> 12
                      AND f.suspenso = 0
                      AND FORMAT(f.data_encerramento, 'yyyy-MM') IN (SELECT mes_ano FROM UltimosMeses)
                    GROUP BY p.MANCHETE, p.sk_grupo_item, FORMAT(f.data_encerramento, 'yyyy-MM')
                    ORDER BY mes_ano DESC, p.MANCHETE
                </cfif>
            </cfquery>

            <!--- Armazenar dados brutos --->
            <cfset dadosCompletos.dadosHistoricos = rsDadosHistoricos>
            <cfset dadosCompletos.ultimosMeses = rsUltimosMeses>
            <cfset dadosCompletos.dadosDetalhados = rsDadosDetalhados>

            <!--- Armazenar no cache nativo com expiração de 30 minutos --->
            <cfset cachePut(chaveCache, dadosCompletos, createTimeSpan(0,0,30,0))>
        </cfif>

        <cfreturn dadosCompletos>
    </cffunction>

    <cffunction name="obterDadosResumoGeral" access="public" returntype="struct" hint="Obtém dados para o componente de resumo geral">
        <cfargument name="sk_mcu" type="any" required="true" hint="Código da unidade MCU">
        <cfargument name="mesAnoFiltro" type="string" required="false" default="" hint="Filtro por mês no formato yyyy-MM">
        
        <!--- Validar e converter sk_mcu para numérico --->
        <cfif NOT isNumeric(arguments.sk_mcu)>
            <cfset arguments.sk_mcu = 0>
        <cfelse>
            <cfset arguments.sk_mcu = val(arguments.sk_mcu)>
        </cfif>
        
        <!--- Para resumo geral, sempre buscar dados históricos acumulados --->
        <cfif len(trim(arguments.mesAnoFiltro))>
            <!--- Calcular intervalo de datas --->
            <cfset var anoFiltro = listFirst(arguments.mesAnoFiltro, "-")>
            <cfset var mesFiltro = listLast(arguments.mesAnoFiltro, "-")>
            <cfset var fimMes = dateAdd("d", -1, dateAdd("m", 1, createDateTime(anoFiltro, mesFiltro, 1, 0, 0, 0)))>
            
            <!--- Buscar dados históricos até o mês selecionado --->
            <cfquery name="rsDadosHistoricosAcumulados" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT   COUNT(DISTINCT CASE WHEN suspenso = 0 AND sk_grupo_item <> 12 THEN sk_grupo_item END) AS testesEnvolvidos
                        ,SUM(NC_Eventos) AS totalEventos
                        ,COUNT(CASE WHEN sigla_apontamento in('C','N') THEN sigla_apontamento END) AS testesAplicados
                        ,COUNT(CASE WHEN sigla_apontamento = 'C' THEN sigla_apontamento END) AS conformes
                        ,COUNT(CASE WHEN sigla_apontamento = 'N' THEN sigla_apontamento END) AS deficienciasControle
                        ,SUM(
                                COALESCE(valor_falta, 0) + 
                                COALESCE(valor_sobra, 0) + 
                                CASE 
                                    WHEN nm_teste <> '239-4' THEN COALESCE(valor_risco, 0)
                                    ELSE 0
                                END
                            ) AS valorEnvolvido
                        ,SUM(nr_reincidente) AS reincidencia
                FROM fato_verificacao f
                WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
                  AND f.data_encerramento <= <cfqueryparam cfsqltype="cf_sql_date" value="#fimMes#">
            </cfquery>
            
            <cfset var resultado = structNew()>
            <cfset resultado.dadosHistoricos = {
                testesEnvolvidos = rsDadosHistoricosAcumulados.testesEnvolvidos,
                totalEventos = rsDadosHistoricosAcumulados.totalEventos,
                testesAplicados = rsDadosHistoricosAcumulados.testesAplicados,
                conformes = rsDadosHistoricosAcumulados.conformes,
                deficienciasControle = rsDadosHistoricosAcumulados.deficienciasControle,
                valorEnvolvido = rsDadosHistoricosAcumulados.valorEnvolvido,
                reincidencia = rsDadosHistoricosAcumulados.reincidencia
            }>
        <cfelse>
            <!--- Usar lógica original sem filtro --->
            <cfset var dadosBrutos = buscarDadosCompletos(arguments.sk_mcu, arguments.mesAnoFiltro)>
            <cfset var resultado = structNew()>
            
            <cfset resultado.dadosHistoricos = {
                testesEnvolvidos = dadosBrutos.dadosHistoricos.testesEnvolvidos,
                totalEventos = dadosBrutos.dadosHistoricos.totalEventos,
                testesAplicados = dadosBrutos.dadosHistoricos.testesAplicados,
                conformes = dadosBrutos.dadosHistoricos.conformes,
                deficienciasControle = dadosBrutos.dadosHistoricos.deficienciasControle,
                valorEnvolvido = dadosBrutos.dadosHistoricos.valorEnvolvido,
                reincidencia = dadosBrutos.dadosHistoricos.reincidencia
            }>
        </cfif>

        <cfreturn resultado>
    </cffunction>

    <cffunction name="obterDadosDesempenhoAssunto" access="public" returntype="struct" hint="Obtém dados para o componente de desempenho por assunto">
        <cfargument name="sk_mcu" type="any" required="true" hint="Código da unidade MCU">
        <cfargument name="mesAnoFiltro" type="string" required="false" default="" hint="Filtro por mês no formato yyyy-MM">
        
        <!--- Validar e converter sk_mcu para numérico --->
        <cfif NOT isNumeric(arguments.sk_mcu)>
            <cfset arguments.sk_mcu = 0>
        <cfelse>
            <cfset arguments.sk_mcu = val(arguments.sk_mcu)>
        </cfif>
        
        <!--- Se há filtro específico, buscar dados do mês filtrado e do mês anterior para comparação --->
        <cfif len(trim(arguments.mesAnoFiltro))>
            <!--- Calcular intervalos de datas --->
            <cfset var anoFiltro = listFirst(arguments.mesAnoFiltro, "-")>
            <cfset var mesFiltro = listLast(arguments.mesAnoFiltro, "-")>
            <cfset var dataFiltro = createDate(anoFiltro, mesFiltro, 1)>
            <cfset var dataAnterior = dateAdd("m", -1, dataFiltro)>
            <cfset var mesAnteriorCalculado = dateFormat(dataAnterior, "yyyy-mm")>
            
            <cfset var inicioMesAtual = createDateTime(anoFiltro, mesFiltro, 1, 0, 0, 0)>
            <cfset var fimMesAtual = dateAdd("d", -1, dateAdd("m", 1, inicioMesAtual))>
            <cfset var inicioMesAnterior = createDateTime(year(dataAnterior), month(dataAnterior), 1, 0, 0, 0)>
            <cfset var fimMesAnterior = dateAdd("d", -1, dateAdd("m", 1, inicioMesAnterior))>
            
            <!--- Buscar dados comparativos específicos --->
            <cfquery name="rsDadosComparativos" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT 
                    p.MANCHETE,
                    p.sk_grupo_item,
                    FORMAT(f.data_encerramento, 'yyyy-MM') AS mes_ano,
                    SUM(f.NC_Eventos) AS total_eventos
                FROM fato_verificacao f
                INNER JOIN dim_teste_processos p ON f.sk_grupo_item = p.sk_grupo_item
                WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
                  AND f.sk_grupo_item <> 12
                  AND f.suspenso = 0
                  AND (
                    (f.data_encerramento BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#inicioMesAtual#">
                                              AND <cfqueryparam cfsqltype="cf_sql_date" value="#fimMesAtual#">)
                    OR
                    (f.data_encerramento BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#inicioMesAnterior#">
                                              AND <cfqueryparam cfsqltype="cf_sql_date" value="#fimMesAnterior#">)
                  )
                GROUP BY p.MANCHETE, p.sk_grupo_item, FORMAT(f.data_encerramento, 'yyyy-MM')
                ORDER BY mes_ano DESC, p.MANCHETE
            </cfquery>
            
            <!--- Definir informações dos meses para comparação --->
            <cfset var mesAtualId = arguments.mesAnoFiltro>
            <cfset var mesAnteriorId = mesAnteriorCalculado>
            <cfset var nomeMesAtual = monthAsString(val(mesFiltro)) & "/" & anoFiltro>
            <cfset var nomeMesAnterior = monthAsString(month(dataAnterior)) & "/" & year(dataAnterior)>
            
            <!--- Processar dados por assunto --->
            <cfset var dadosAssunto = {}>
            <cfloop query="rsDadosComparativos">
                <cfset var chave = rereplace(MANCHETE, "[^A-Za-z0-9]", "", "all")>
                <cfif NOT structKeyExists(dadosAssunto, chave)>
                    <cfset dadosAssunto[chave] = { titulo = MANCHETE, anterior = 0, atual = 0 }>
                </cfif>
                <cfif mes_ano EQ mesAnteriorId>
                    <cfset dadosAssunto[chave].anterior = total_eventos>
                <cfelseif mes_ano EQ mesAtualId>
                    <cfset dadosAssunto[chave].atual = total_eventos>
                </cfif>
            </cfloop>
            
        <cfelse>
            <!--- Usar a lógica original para sem filtro --->
            <cfset var dadosBrutos = buscarDadosCompletos(arguments.sk_mcu, arguments.mesAnoFiltro)>
            
            <!--- Definir informações dos meses --->
            <cfif dadosBrutos.ultimosMeses.recordCount GTE 2>
                <cfset var mesAtualId = dadosBrutos.ultimosMeses.mes_ano[1]>
                <cfset var mesAnteriorId = dadosBrutos.ultimosMeses.mes_ano[2]>
                <cfset var nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
                <cfset var nomeMesAnterior = monthAsString(listLast(mesAnteriorId, "-")) & "/" & left(mesAnteriorId, 4)>
            <cfelseif dadosBrutos.ultimosMeses.recordCount EQ 1>
                <cfset var mesAtualId = dadosBrutos.ultimosMeses.mes_ano[1]>
                <cfset var mesAnteriorId = "">
                <cfset var nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
                <cfset var nomeMesAnterior = "Mês Anterior">
            <cfelse>
                <cfset var mesAtualId = "">
                <cfset var mesAnteriorId = "">
                <cfset var nomeMesAtual = "Mês Atual">
                <cfset var nomeMesAnterior = "Mês Anterior">
            </cfif>

            <!--- Processar dados por assunto --->
            <cfset var dadosAssunto = {}>
            <cfloop query="dadosBrutos.dadosDetalhados">
                <cfset var chave = rereplace(MANCHETE, "[^A-Za-z0-9]", "", "all")>
                <cfif NOT structKeyExists(dadosAssunto, chave)>
                    <cfset dadosAssunto[chave] = { titulo = MANCHETE, anterior = 0, atual = 0 }>
                </cfif>
                <cfif mes_ano EQ mesAnteriorId>
                    <cfset dadosAssunto[chave].anterior = total_eventos>
                <cfelseif mes_ano EQ mesAtualId>
                    <cfset dadosAssunto[chave].atual = total_eventos>
                </cfif>
            </cfloop>
        </cfif>

        <cfset var resultado = structNew()>
        <cfset resultado.meses = {
            mesAtualId = mesAtualId,
            mesAnteriorId = mesAnteriorId,
            nomeMesAtual = nomeMesAtual,
            nomeMesAnterior = nomeMesAnterior
        }>
        <cfset resultado.dadosAssunto = dadosAssunto>

        <cfreturn resultado>
    </cffunction>

    <cffunction name="obterDadosMensagemCard" access="public" returntype="struct" hint="Obtém dados para o componente de mensagem card">
        <cfargument name="sk_mcu" type="any" required="true" hint="Código da unidade MCU">
        <cfargument name="mesAnoFiltro" type="string" required="false" default="" hint="Filtro por mês no formato yyyy-MM">
        
        <!--- Validar e converter sk_mcu para numérico --->
        <cfif NOT isNumeric(arguments.sk_mcu)>
            <cfset arguments.sk_mcu = 0>
        <cfelse>
            <cfset arguments.sk_mcu = val(arguments.sk_mcu)>
        </cfif>
        
        <!--- Se há filtro específico, usar a mesma lógica do desempenho por assunto --->
        <cfif len(trim(arguments.mesAnoFiltro))>
            <cfset var dadosDesempenho = obterDadosDesempenhoAssunto(arguments.sk_mcu, arguments.mesAnoFiltro)>
            <cfset var dadosMeses = dadosDesempenho.meses>
            <cfset var dadosAssunto = dadosDesempenho.dadosAssunto>
            
            <!--- Calcular eventos agregados --->
            <cfset var eventosAtual = 0>
            <cfset var eventosAnterior = 0>
            <cfloop collection="#dadosAssunto#" item="chave">
                <cfset var item = dadosAssunto[chave]>
                <cfset eventosAtual = eventosAtual + item.atual>
                <cfset eventosAnterior = eventosAnterior + item.anterior>
            </cfloop>
            
            <cfset var resultado = structNew()>
            <cfset resultado.meses = dadosMeses>
            <cfset resultado.eventosMensagem = {
                eventosAtual = eventosAtual,
                eventosAnterior = eventosAnterior
            }>
            
        <cfelse>
            <!--- Usar lógica original --->
            <cfset var dadosBrutos = buscarDadosCompletos(arguments.sk_mcu, arguments.mesAnoFiltro)>
            <cfset var resultado = structNew()>
            
            <!--- Definir informações dos meses --->
            <cfif dadosBrutos.ultimosMeses.recordCount GTE 2>
                <cfset var mesAtualId = dadosBrutos.ultimosMeses.mes_ano[1]>
                <cfset var mesAnteriorId = dadosBrutos.ultimosMeses.mes_ano[2]>
                <cfset var nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
                <cfset var nomeMesAnterior = monthAsString(listLast(mesAnteriorId, "-")) & "/" & left(mesAnteriorId, 4)>
            <cfelseif dadosBrutos.ultimosMeses.recordCount EQ 1>
                <cfset var mesAtualId = dadosBrutos.ultimosMeses.mes_ano[1]>
                <cfset var mesAnteriorId = "">
                <cfset var nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
                <cfset var nomeMesAnterior = "Mês Anterior">
            <cfelse>
                <cfset var mesAtualId = "">
                <cfset var mesAnteriorId = "">
                <cfset var nomeMesAtual = "Mês Atual">
                <cfset var nomeMesAnterior = "Mês Anterior">
            </cfif>

            <cfset resultado.meses = {
                mesAtualId = mesAtualId,
                mesAnteriorId = mesAnteriorId,
                nomeMesAtual = nomeMesAtual,
                nomeMesAnterior = nomeMesAnterior
            }>

            <!--- Calcular eventos agregados por mês --->
            <cfset var eventosAtual = 0>
            <cfset var eventosAnterior = 0>
            <cfloop query="dadosBrutos.dadosDetalhados">
                <cfif mes_ano EQ mesAtualId>
                    <cfset eventosAtual = eventosAtual + total_eventos>
                <cfelseif mes_ano EQ mesAnteriorId>
                    <cfset eventosAnterior = eventosAnterior + total_eventos>
                </cfif>
            </cfloop>
            
            <cfset resultado.eventosMensagem = {
                eventosAtual = eventosAtual,
                eventosAnterior = eventosAnterior
            }>
        </cfif>

        <cfreturn resultado>
    </cffunction>

    <cffunction name="getUnidadesPorSE" access="remote" returnformat="json" returntype="any">
        <cfargument name="codDiretoria" type="string" required="true">
        
        <cfset var result = {}>
        <cfset var unidades = []>
        
        <cftry>
        <cfquery name="rsUnidades" datasource="#application.dsn_avaliacoes_automatizadas#">
            SELECT Und_Codigo, Und_Descricao 
            FROM Unidades 
            WHERE Und_Status = 'A' 
            AND Und_CodDiretoria = <cfqueryparam value="#arguments.codDiretoria#" cfsqltype="cf_sql_varchar">
            ORDER BY Und_Descricao
        </cfquery>
        
        <cfloop query="rsUnidades">
            <cfset arrayAppend(unidades, {
            "codigo": Und_Codigo,
            "nome": Und_Descricao
            })>
        </cfloop>
        
        <cfset result = {
            "success": true,
            "data": unidades
        }>
        
        <cfcatch>
            <cfset result = {
            "success": false,
            "message": "Erro ao buscar unidades: " & cfcatch.message
            }>
        </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>

    <cffunction name="atualizarLotacaoUsuario" access="remote" returnformat="json" returntype="any">
        <cfargument name="codigoUnidade" type="string" required="true">
        <cfargument name="nomeUnidade" type="string" required="true">
        <cfargument name="matriculaUsuario" type="string" required="true">
        
        <cfset var result = {}>
        
        <cftry>
            <!--- Primeiro, verificar se a unidade de destino existe --->
            <cfquery name="verificaUnidadeDestino" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT COUNT(*) as total, Und_Descricao
                FROM Unidades 
                WHERE Und_Codigo = <cfqueryparam value="#arguments.codigoUnidade#" cfsqltype="cf_sql_varchar">
                AND Und_Status = 'A'
                GROUP BY Und_Descricao
            </cfquery>
            
            <cfif verificaUnidadeDestino.recordCount EQ 0 OR verificaUnidadeDestino.total EQ 0>
                <cfset result = {
                    "success": false,
                    "message": "Unidade de destino '#arguments.codigoUnidade#' não encontrada ou inativa"
                }>
            <cfelse>
                <!--- Verificar dados atuais do usuário --->
                <cfquery name="verificaUsuario" datasource="#application.dsn_avaliacoes_automatizadas#">
                    SELECT Usu_Lotacao, Usu_LotacaoNome
                    FROM Usuarios 
                    WHERE Usu_Login = 
                       <cfif (FindNoCase("localhost", application.auxsite))>
                           'CORREIOSNET\80859992'
                       <cfelse>     
                           <cfqueryparam value="#application.loginCGI#" cfsqltype="cf_sql_varchar">
                       </cfif>
                </cfquery>
                
                <cfif verificaUsuario.recordCount EQ 0>
                    <cfset result = {
                        "success": false,
                        "message": "Usuário com matrícula '#arguments.matriculaUsuario#' não encontrado"
                    }>
                <cfelse>
                    <!--- Verificar se a lotação atual do usuário existe na tabela Unidades --->
                    <cfset var lotacaoAtualUsuario = verificaUsuario.Usu_Lotacao>
                    <cfquery name="verificaLotacaoAtual" datasource="#application.dsn_avaliacoes_automatizadas#">
                        SELECT COUNT(*) as total
                        FROM Unidades 
                        WHERE Und_Codigo = <cfqueryparam value="#lotacaoAtualUsuario#" cfsqltype="cf_sql_varchar">
                    </cfquery>
                    
                    <!--- Se a lotação atual não existe, usar UPDATE mais permissivo --->
                    <cfif verificaLotacaoAtual.total EQ 0>
                        <!--- Temporariamente, definir lotação como NULL ou usar MERGE --->
                        <cfquery name="updateLotacaoComProblema" datasource="#application.dsn_avaliacoes_automatizadas#" result="updateResult">
                            UPDATE Usuarios 
                            SET Usu_Lotacao = <cfqueryparam value="#arguments.codigoUnidade#" cfsqltype="cf_sql_varchar">,
                                Usu_LotacaoNome = <cfqueryparam value="#verificaUnidadeDestino.Und_Descricao#" cfsqltype="cf_sql_varchar">
                           WHERE Usu_Login = 
                                <cfif (FindNoCase("localhost", application.auxsite))>
                                    'CORREIOSNET\80859992'
                                <cfelse>     
                                    <cfqueryparam value="#application.loginCGI#" cfsqltype="cf_sql_varchar">
                                </cfif>
                            AND NOT EXISTS (
                                SELECT 1 FROM Unidades u 
                                WHERE u.Und_Codigo = Usuarios.Usu_Lotacao
                            )
                        </cfquery>
                        
                        <cfset result = {
                            "success": true,
                            "message": "Lotação atualizada (corrigida lotação inválida anterior: '#lotacaoAtualUsuario#')",
                            "lotacaoAnterior": lotacaoAtualUsuario,
                            "lotacaoNova": arguments.codigoUnidade,
                            "observacao": "Usuário tinha lotação inexistente"
                        }>
                    <cfelse>
                        <!--- Fazer UPDATE normal --->
                        <cfquery name="updateLotacao" datasource="#application.dsn_avaliacoes_automatizadas#" result="updateResult">
                            UPDATE Usuarios 
                            SET Usu_Lotacao = <cfqueryparam value="#arguments.codigoUnidade#" cfsqltype="cf_sql_varchar">,
                                Usu_LotacaoNome = <cfqueryparam value="#verificaUnidadeDestino.Und_Descricao#" cfsqltype="cf_sql_varchar">
                            WHERE Usu_Login = 
                                <cfif (FindNoCase("localhost", application.auxsite))>
                                    'CORREIOSNET\80859992'
                                <cfelse>     
                                    <cfqueryparam value="#application.loginCGI#" cfsqltype="cf_sql_varchar">
                                </cfif>
                        </cfquery>
                        
                        <cfset result = {
                            "success": true,
                            "message": "Lotação atualizada com sucesso",
                            "lotacaoAnterior": lotacaoAtualUsuario,
                            "lotacaoNova": arguments.codigoUnidade
                        }>
                    </cfif>
                </cfif>
            </cfif>
            
        <cfcatch>
            <cfset result = {
                "success": false,
                "message": "Erro ao atualizar lotação: " & cfcatch.message,
                "detail": cfcatch.detail
            }>
        </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>

    <cffunction name="obterNomeMesAbreviado" access="private" returntype="string" hint="Retorna nome abreviado do mês">
        <cfargument name="numeroMes" type="numeric" required="true">
        
        <cfset var mesesAbreviados = {
            1 = "Jan", 2 = "Fev", 3 = "Mar", 4 = "Abr",
            5 = "Mai", 6 = "Jun", 7 = "Jul", 8 = "Ago",
            9 = "Set", 10 = "Out", 11 = "Nov", 12 = "Dez"
        }>
        
        <cfreturn mesesAbreviados[arguments.numeroMes]>
    </cffunction>

    <cffunction name="obterMesesDisponiveis" access="remote" returnformat="json" returntype="any" hint="Obtém lista de meses disponíveis na base utilizando cache">
        
        <cfset var result = {}>
        <cfset var mesesList = []>
        <cfset var chaveCache = "cacheAAMesesDisponiveis">
        
        <!--- Verificar se os dados já estão em cache nativo --->
        <cfset var dadosCache = cacheGet(chaveCache)>
        <cfif isDefined("dadosCache") AND NOT isNull(dadosCache)>
            <cfreturn dadosCache>
        </cfif>
        
        <cftry>
            <!--- Buscar apenas o registro mais recente para otimizar performance --->
            <cfquery name="rsDataMaisRecente" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT TOP 1 
                    YEAR(data_encerramento) AS ano_mais_recente,
                    MONTH(data_encerramento) AS mes_mais_recente
                FROM fato_verificacao
                WHERE data_encerramento IS NOT NULL             
                  AND sk_grupo_item <> 12
                ORDER BY data_encerramento DESC
            </cfquery>
            
            <!--- Se encontrou dados, gerar lista de meses --->
            <cfif rsDataMaisRecente.recordCount GT 0>
                <cfset var anoAtual = rsDataMaisRecente.ano_mais_recente>
                <cfset var mesAtual = rsDataMaisRecente.mes_mais_recente>
                
                <!--- Gerar meses do ano atual (do mês mais recente até janeiro) --->
                <cfloop from="#mesAtual#" to="1" step="-1" index="mes">
                    <cfset var mesFormatado = numberFormat(mes, "00")>
                    <cfset var mesAnoId = anoAtual & "-" & mesFormatado>
                    
                    <cfset arrayAppend(mesesList, {
                        "id": mesAnoId,
                        "nome": obterNomeMesAbreviado(mes),
                        "ano": anoAtual,
                        "mes": mes,
                        "totalRegistros": 0
                    })>
                </cfloop>
                
            </cfif>
            
            <cfset result = {
                "success": true,
                "data": mesesList
            }>
            
            <!--- Armazenar no cache nativo com expiração de 1 hora --->
            <cfset cachePut(chaveCache, result, createTimeSpan(0,1,0,0))>
            
        <cfcatch>
            <cfset result = {
                "success": false,
                "message": "Erro ao buscar meses disponíveis: " & cfcatch.message,
                "data": []
            }>
        </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>

    <cffunction name="limparCaches" access="remote" returnformat="json" returntype="any" hint="Limpa todos os caches utilizados pelo componente">
        
        <cfset var result = {}>
        <cfset var cachesLimpas = 0>
        
        <cftry>
            <!--- Obter todas as chaves de cache do sistema --->
            <cfset var todasChaves = cacheGetAllIds()>
            
            <!--- Remover apenas caches que começam com "cacheAA" --->
            <cfloop array="#todasChaves#" index="chave">
                <cfif left(chave, 7) EQ "cacheAA">
                    <cfset cacheRemove(chave)>
                    <cfset cachesLimpas = cachesLimpas + 1>
                </cfif>
            </cfloop>
            
            <cfset result = {
                "success": true,
                "message": "Caches limpos com sucesso! Total removido: " & cachesLimpas,
                "cachesRemovidos": cachesLimpas
            }>
            
        <cfcatch>
            <cfset result = {
                "success": false,
                "message": "Erro ao limpar caches: " & cfcatch.message,
                "cachesRemovidos": cachesLimpas
            }>
        </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>

</cfcomponent>
