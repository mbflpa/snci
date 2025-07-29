<cfcomponent displayname="DeficienciasControleDados" hint="Centraliza dados de deficiências de controle para múltiplos componentes">

    <cffunction name="buscarDadosCompletos" access="private" returntype="struct" hint="Busca todos os dados da base uma única vez">
        <cfargument name="sk_mcu" type="numeric" required="true" hint="Código da unidade MCU">
        
        <cfset var dadosCompletos = structNew()>
        
        <!--- Consulta principal: dados históricos gerais --->
        <cfquery name="rsDadosHistoricos" datasource="#application.dsn_avaliacoes_automatizadas#">
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
        </cfquery>

        <!--- Consulta: últimos dois meses disponíveis --->
        <cfquery name="rsUltimosMeses" datasource="#application.dsn_avaliacoes_automatizadas#">
            SELECT TOP 2 FORMAT(data_encerramento, 'yyyy-MM') AS mes_ano
            FROM fato_verificacao
            WHERE data_encerramento IS NOT NULL
              AND sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sk_mcu#">
              AND sk_grupo_item <> 12
            GROUP BY FORMAT(data_encerramento, 'yyyy-MM')
            ORDER BY mes_ano DESC
        </cfquery>

        <!--- Consulta: dados detalhados por assunto e mês --->
        <cfquery name="rsDadosDetalhados" datasource="#application.dsn_avaliacoes_automatizadas#">
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
        </cfquery>

        <!--- Armazenar dados brutos --->
        <cfset dadosCompletos.dadosHistoricos = rsDadosHistoricos>
        <cfset dadosCompletos.ultimosMeses = rsUltimosMeses>
        <cfset dadosCompletos.dadosDetalhados = rsDadosDetalhados>

        <cfreturn dadosCompletos>
    </cffunction>

    <cffunction name="obterDadosResumoGeral" access="public" returntype="struct" hint="Obtém dados para o componente de resumo geral">
        <cfargument name="sk_mcu" type="numeric" required="true" hint="Código da unidade MCU">
        
        <cfset var chaveCache = "cacheDeficiencias_" & arguments.sk_mcu>
        
        <!--- Verificar se os dados já estão em cache --->
        <cfif NOT structKeyExists(application, chaveCache) OR 
              dateDiff("n", application[chaveCache].timestamp, now()) GT 30>
            <cfset application[chaveCache] = {
                dados = buscarDadosCompletos(arguments.sk_mcu),
                timestamp = now()
            }>
        </cfif>
        
        <cfset var dadosBrutos = application[chaveCache].dados>
        <cfset var resultado = structNew()>
        
        <!--- Processar dados históricos --->
        <cfset resultado.dadosHistoricos = {
            testesEnvolvidos = dadosBrutos.dadosHistoricos.testesEnvolvidos,
            totalEventos = dadosBrutos.dadosHistoricos.totalEventos,
            testesAplicados = dadosBrutos.dadosHistoricos.testesAplicados,
            conformes = dadosBrutos.dadosHistoricos.conformes,
            deficienciasControle = dadosBrutos.dadosHistoricos.deficienciasControle,
            valorEnvolvido = dadosBrutos.dadosHistoricos.valorEnvolvido,
            reincidencia = dadosBrutos.dadosHistoricos.reincidencia
        }>

        <cfreturn resultado>
    </cffunction>

    <cffunction name="obterDadosDesempenhoAssunto" access="public" returntype="struct" hint="Obtém dados para o componente de desempenho por assunto">
        <cfargument name="sk_mcu" type="numeric" required="true" hint="Código da unidade MCU">
        
        <cfset var chaveCache = "cacheDeficiencias_" & arguments.sk_mcu>
        
        <!--- Reutilizar cache se disponível --->
        <cfif NOT structKeyExists(application, chaveCache) OR 
              dateDiff("n", application[chaveCache].timestamp, now()) GT 30>
            <cfset application[chaveCache] = {
                dados = buscarDadosCompletos(arguments.sk_mcu),
                timestamp = now()
            }>
        </cfif>
        
        <cfset var dadosBrutos = application[chaveCache].dados>
        <cfset var resultado = structNew()>
        
        <!--- Definir informações dos meses --->
        <cfif dadosBrutos.ultimosMeses.recordCount GTE 2>
            <cfset var mesAtualId = dadosBrutos.ultimosMeses.mes_ano[1]>
            <cfset var mesAnteriorId = dadosBrutos.ultimosMeses.mes_ano[2]>
            <cfset var nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
            <cfset var nomeMesAnterior = monthAsString(listLast(mesAnteriorId, "-")) & "/" & left(mesAnteriorId, 4)>
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
        <cfset resultado.dadosAssunto = dadosAssunto>

        <cfreturn resultado>
    </cffunction>

    <cffunction name="obterDadosMensagemCard" access="public" returntype="struct" hint="Obtém dados para o componente de mensagem card">
        <cfargument name="sk_mcu" type="numeric" required="true" hint="Código da unidade MCU">
        
        <cfset var chaveCache = "cacheDeficiencias_" & arguments.sk_mcu>
        
        <!--- Reutilizar cache se disponível --->
        <cfif NOT structKeyExists(application, chaveCache) OR 
              dateDiff("n", application[chaveCache].timestamp, now()) GT 30>
            <cfset application[chaveCache] = {
                dados = buscarDadosCompletos(arguments.sk_mcu),
                timestamp = now()
            }>
        </cfif>
        
        <cfset var dadosBrutos = application[chaveCache].dados>
        <cfset var resultado = structNew()>
        
        <!--- Definir informações dos meses --->
        <cfif dadosBrutos.ultimosMeses.recordCount GTE 2>
            <cfset var mesAtualId = dadosBrutos.ultimosMeses.mes_ano[1]>
            <cfset var mesAnteriorId = dadosBrutos.ultimosMeses.mes_ano[2]>
            <cfset var nomeMesAtual = monthAsString(listLast(mesAtualId, "-")) & "/" & left(mesAtualId, 4)>
            <cfset var nomeMesAnterior = monthAsString(listLast(mesAnteriorId, "-")) & "/" & left(mesAnteriorId, 4)>
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

        <cfreturn resultado>
    </cffunction>

    <!--- Função de compatibilidade para manter funcionamento existente --->
    <cffunction name="obterDadosCompletos" access="public" returntype="struct" hint="Função de compatibilidade - obtém todos os dados">
        <cfargument name="sk_mcu" type="numeric" required="true" hint="Código da unidade MCU">
        
        <cfset var resultado = structNew()>
        <cfset resultado.dadosHistoricos = obterDadosResumoGeral(arguments.sk_mcu).dadosHistoricos>
        <cfset var dadosDesempenho = obterDadosDesempenhoAssunto(arguments.sk_mcu)>
        <cfset resultado.meses = dadosDesempenho.meses>
        <cfset resultado.dadosAssunto = dadosDesempenho.dadosAssunto>
        <cfset resultado.eventosMensagem = obterDadosMensagemCard(arguments.sk_mcu).eventosMensagem>
        
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
            <cfquery name="updateLotacao" datasource="#application.dsn_avaliacoes_automatizadas#">
                UPDATE Usuarios 
                SET Usu_Lotacao = <cfqueryparam value="#arguments.codigoUnidade#" cfsqltype="cf_sql_varchar">,
                    Usu_LotacaoNome = <cfqueryparam value="#arguments.nomeUnidade#" cfsqltype="cf_sql_varchar">
                WHERE Usu_Matricula = <cfqueryparam value="#arguments.matriculaUsuario#" cfsqltype="cf_sql_varchar">
            </cfquery>
            
            <cfset result = {
                "success": true,
                "message": "Lotação atualizada com sucesso"
            }>
            
        <cfcatch>
            <cfset result = {
                "success": false,
                "message": "Erro ao atualizar lotação: " & cfcatch.message
            }>
        </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>

</cfcomponent>
