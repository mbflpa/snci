<cfcomponent displayname="EvidenciasManager" hint="Gerencia dados de tabelas de evidências">

    <cffunction name="listarTabelasEvidencias" access="public" returntype="array" hint="Lista todas as tabelas que contêm 'evidencias_' no nome">
        <cfset var local = {}>
        <cfset local.tabelas = arrayNew(1)>
        
        <cflog file="evidencias_debug" text="=== INICIANDO listarTabelasEvidencias ===">
        
        <cftry>
            <cfquery name="local.qryTabelas" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT 
                    TABLE_NAME,
                    TABLE_SCHEMA
                FROM INFORMATION_SCHEMA.TABLES 
                WHERE TABLE_TYPE = 'BASE TABLE'
                    AND LOWER(TABLE_NAME) LIKE 'evidencias_%'
                    AND TABLE_SCHEMA = 'dbo'
                ORDER BY TABLE_NAME
            </cfquery>
            
            <cflog file="evidencias_debug" text="Query executada. Tabelas encontradas: #local.qryTabelas.recordCount#">
            
            <cfloop query="local.qryTabelas">
                <cfset local.tabela = {
                    "nome" = TABLE_NAME,
                    "schema" = TABLE_SCHEMA,
                    "codigo" = extrairCodigoAssunto(TABLE_NAME),
                    "titulo" = "Evidências " & extrairCodigoAssunto(TABLE_NAME)
                }>
                <cfset arrayAppend(local.tabelas, local.tabela)>
                <cflog file="evidencias_debug" text="Tabela adicionada: #TABLE_NAME# -> código: #local.tabela.codigo#">
            </cfloop>
            
            <cflog file="evidencias_debug" text="Total de tabelas processadas: #arrayLen(local.tabelas)#">
            
            <cfcatch type="any">
                <cflog file="evidencias_erro" text="Erro ao listar tabelas: #cfcatch.message# - #cfcatch.detail#">
                <cflog file="evidencias_debug" text="ERRO em listarTabelasEvidencias: #cfcatch.message#">
                <!--- Retornar array vazio em caso de erro --->
                <cfset local.tabelas = arrayNew(1)>
            </cfcatch>
        </cftry>
        
        <cflog file="evidencias_debug" text="=== FIM listarTabelasEvidencias - retornando #arrayLen(local.tabelas)# tabelas ===">
        
        <cfreturn local.tabelas>
    </cffunction>

    <cffunction name="extrairCodigoAssunto" access="private" returntype="string" hint="Extrai o código do assunto do nome da tabela">
        <cfargument name="nomeTabela" type="string" required="true">
        
        <cfset var codigo = "">
        
        <cftry>
            <!--- Remove o prefixo "evidencias_" e converte underscores para pontos --->
            <cfif lcase(arguments.nomeTabela) CONTAINS "evidencias_">
                <cfset codigo = replace(lcase(arguments.nomeTabela), "evidencias_", "", "one")>
                <cfset codigo = replace(codigo, "_", ".", "all")>
            </cfif>
            
            <cfcatch type="any">
                <cfset codigo = arguments.nomeTabela>
            </cfcatch>
        </cftry>
        
        <cfreturn codigo>
    </cffunction>

    <cffunction name="gerarNomeTabela" access="public" returntype="string" hint="Gera nome da tabela baseado no código do assunto">
        <cfargument name="codigoAssunto" type="string" required="true">
        
        <cfset var nomeTabela = "">
        
        <cftry>
            <!--- Converte pontos e hífens para underscores e adiciona o prefixo --->
            <cfset var codigoLimpo = replace(replace(trim(arguments.codigoAssunto), ".", "_", "all"), "-", "_", "all")>
            <cfset nomeTabela = "evidencias_" & lcase(codigoLimpo)>
            
            <cfcatch type="any">
                <cfset nomeTabela = "evidencias_" & lcase(arguments.codigoAssunto)>
            </cfcatch>
        </cftry>
        
        <cfreturn nomeTabela>
    </cffunction>

    <cffunction name="buscarTabelaPorCodigo" access="public" returntype="string" hint="Busca tabela por código do teste">
        <cfargument name="codigoTeste" type="string" required="true">
        <cfargument name="tabelasDisponiveis" type="array" required="true">
        
        <cfset var nomeEncontrado = "">
        
        <cftry>
            <cflog file="evidencias_debug" text="Buscando tabela para código: '#arguments.codigoTeste#'">
            <cflog file="evidencias_debug" text="Total de tabelas disponíveis: #arrayLen(arguments.tabelasDisponiveis)#">
            
            <!--- Primeiro: tentar match direto --->
            <cfset var nomeEsperado = gerarNomeTabela(arguments.codigoTeste)>
            <cflog file="evidencias_debug" text="Nome esperado gerado: '#nomeEsperado#'">
            
            <cfloop array="#arguments.tabelasDisponiveis#" index="tabela">
                <cflog file="evidencias_debug" text="Comparando com tabela: '#tabela.nome#' (código: '#tabela.codigo#')">
                <cfif lcase(tabela.nome) EQ lcase(nomeEsperado)>
                    <cfset nomeEncontrado = tabela.nome>
                    <cflog file="evidencias_debug" text="MATCH DIRETO encontrado: '#nomeEncontrado#'">
                    <cfbreak>
                </cfif>
            </cfloop>
            
            <!--- Segundo: tentar match por código extraído --->
            <cfif len(trim(nomeEncontrado)) EQ 0>
                <cflog file="evidencias_debug" text="Tentando match por código extraído...">
                <cfloop array="#arguments.tabelasDisponiveis#" index="tabela">
                    <cfif len(trim(tabela.codigo)) AND (
                          lcase(tabela.codigo) EQ lcase(arguments.codigoTeste) OR
                          findNoCase(arguments.codigoTeste, tabela.codigo) OR
                          findNoCase(tabela.codigo, arguments.codigoTeste)
                        )>
                        <cfset nomeEncontrado = tabela.nome>
                        <cflog file="evidencias_debug" text="MATCH POR CÓDIGO encontrado: '#nomeEncontrado#' (código: '#tabela.codigo#')">
                        <cfbreak>
                    </cfif>
                </cfloop>
            </cfif>
            
            <!--- Terceiro: tentar match parcial (sem pontos/hífens) --->
            <cfif len(trim(nomeEncontrado)) EQ 0>
                <cflog file="evidencias_debug" text="Tentando match parcial...">
                <cfset var codigoLimpo = replace(replace(arguments.codigoTeste, ".", "", "all"), "-", "", "all")>
                <cflog file="evidencias_debug" text="Código teste limpo: '#codigoLimpo#'">
                
                <cfloop array="#arguments.tabelasDisponiveis#" index="tabela">
                    <cfset var codigoTabelaLimpo = replace(replace(tabela.codigo, ".", "", "all"), "-", "", "all")>
                    <cflog file="evidencias_debug" text="Código tabela limpo: '#codigoTabelaLimpo#'">
                    
                    <cfif len(trim(codigoTabelaLimpo)) AND (
                          lcase(codigoTabelaLimpo) EQ lcase(codigoLimpo) OR
                          findNoCase(codigoLimpo, codigoTabelaLimpo) OR
                          findNoCase(codigoTabelaLimpo, codigoLimpo)
                        )>
                        <cfset nomeEncontrado = tabela.nome>
                        <cflog file="evidencias_debug" text="MATCH PARCIAL encontrado: '#nomeEncontrado#'">
                        <cfbreak>
                    </cfif>
                </cfloop>
            </cfif>
            
            <!--- Quarto: tentar match mais flexível (contém) --->
            <cfif len(trim(nomeEncontrado)) EQ 0>
                <cflog file="evidencias_debug" text="Tentando match flexível...">
                <cfloop array="#arguments.tabelasDisponiveis#" index="tabela">
                    <!--- Verificar se alguma parte do código está no nome da tabela --->
                    <cfif findNoCase(arguments.codigoTeste, tabela.nome) OR 
                          findNoCase(replace(arguments.codigoTeste, "-", "_", "all"), tabela.nome) OR
                          findNoCase(replace(arguments.codigoTeste, ".", "_", "all"), tabela.nome)>
                        <cfset nomeEncontrado = tabela.nome>
                        <cflog file="evidencias_debug" text="MATCH FLEXÍVEL encontrado: '#nomeEncontrado#'">
                        <cfbreak>
                    </cfif>
                </cfloop>
            </cfif>
            
            <cfif len(trim(nomeEncontrado)) EQ 0>
                <cflog file="evidencias_debug" text="NENHUM MATCH encontrado para código: '#arguments.codigoTeste#'">
            </cfif>
            
            <cfcatch type="any">
                <cflog file="evidencias_erro" text="Erro na busca por código #arguments.codigoTeste#: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfreturn nomeEncontrado>
    </cffunction>

    <cffunction name="validarNomeTabela" access="private" returntype="boolean" hint="Valida se o nome da tabela é seguro e existe">
        <cfargument name="nomeTabela" type="string" required="true">
        
        <cfset var local = {}>
        
        <cftry>
            <cfquery name="local.qryValidacao" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT TABLE_NAME
                FROM INFORMATION_SCHEMA.TABLES 
                WHERE TABLE_TYPE = 'BASE TABLE'
                    AND LOWER(TABLE_NAME) = <cfqueryparam value="#lcase(arguments.nomeTabela)#" cfsqltype="cf_sql_varchar">
                    AND TABLE_SCHEMA = 'dbo'
            </cfquery>
            
            <cfreturn local.qryValidacao.recordCount GT 0>
            
            <cfcatch type="any">
                <cflog file="evidencias_erro" text="Erro na validação da tabela #arguments.nomeTabela#: #cfcatch.message#">
                <cfreturn false>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="obterEstruturasTabela" access="remote" returnformat="json" returntype="array" hint="Obtém as colunas de uma tabela">
        <cfargument name="nomeTabela" type="string" required="true">
        
        <cfset var local = {}>
        <cfset local.colunas = arrayNew(1)>
        
        <cflog file="evidencias_debug" text="Iniciando obterEstruturasTabela para: #arguments.nomeTabela#">
        
        <cfif NOT validarNomeTabela(arguments.nomeTabela)>
            <cflog file="evidencias_debug" text="Tabela não válida: #arguments.nomeTabela#">
            <cfreturn local.colunas>
        </cfif>
        
        <cftry>
            <cflog file="evidencias_debug" text="Consultando colunas da tabela: #arguments.nomeTabela#">
            
            <cfquery name="local.qryColunas" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT 
                    COLUMN_NAME,
                    DATA_TYPE,
                    IS_NULLABLE,
                    COLUMN_DEFAULT,
                    CHARACTER_MAXIMUM_LENGTH,
                    ORDINAL_POSITION
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = <cfqueryparam value="#arguments.nomeTabela#" cfsqltype="cf_sql_varchar">
                    AND TABLE_SCHEMA = 'dbo'
                ORDER BY ORDINAL_POSITION
            </cfquery>
            
            <cflog file="evidencias_debug" text="Query executada. Registros encontrados: #local.qryColunas.recordCount#">
            
            <cfloop query="local.qryColunas">
                <cfset arrayAppend(local.colunas, {
                    "nome" = COLUMN_NAME,
                    "tipo" = DATA_TYPE,
                    "nulavel" = IS_NULLABLE,
                    "tamanho" = CHARACTER_MAXIMUM_LENGTH,
                    "posicao" = ORDINAL_POSITION
                })>
                <cflog file="evidencias_debug" text="Coluna adicionada: #COLUMN_NAME# (#DATA_TYPE#)">
            </cfloop>
            
            <cflog file="evidencias_debug" text="Total de colunas processadas: #arrayLen(local.colunas)#">
            
            <cfcatch type="any">
                <cflog file="evidencias_erro" text="Erro ao obter estrutura da tabela #arguments.nomeTabela#: #cfcatch.message# - #cfcatch.detail#">
            </cfcatch>
        </cftry>
        
        <cfreturn local.colunas>
    </cffunction>

    <cffunction name="obterDadosTabela" access="remote" returnformat="json" returntype="struct" hint="Obtém dados paginados de uma tabela">
        <cfargument name="nomeTabela" type="string" required="true">
        <cfargument name="start" type="numeric" required="false" default="0">
        <cfargument name="length" type="numeric" required="false" default="10">
        <cfargument name="searchValue" type="string" required="false" default="">
        <cfargument name="orderColumn" type="numeric" required="false" default="0">
        <cfargument name="orderDirection" type="string" required="false" default="asc">
        <cfargument name="exportAll" type="boolean" required="false" default="false">
        
        <cfset var local = {}>
        <cfset local.resultado = {
            "data" = arrayNew(1),
            "recordsTotal" = 0,
            "recordsFiltered" = 0,
            "columns" = arrayNew(1),
            "draw" = val(url.draw ?: 1)
        }>
        
        <cflog file="evidencias_debug" text="obterDadosTabela chamado para: #arguments.nomeTabela#">
        
        <!--- Verificar se a tabela existe e é válida --->
        <cfif NOT validarNomeTabela(arguments.nomeTabela)>
            <cflog file="evidencias_debug" text="Tabela não encontrada: #arguments.nomeTabela#">
            <cfset local.resultado.error = "Tabela não encontrada ou não válida: " & arguments.nomeTabela>
            <cfreturn local.resultado>
        </cfif>
        
        <cftry>
            <!--- Obter estrutura das colunas --->
            <cflog file="evidencias_debug" text="Obtendo estrutura da tabela: #arguments.nomeTabela#">
            <cfset local.colunas = obterEstruturasTabela(arguments.nomeTabela)>
            <cfset local.resultado.columns = local.colunas>
            
            <cflog file="evidencias_debug" text="Colunas obtidas: #arrayLen(local.colunas)#">
            
            <cfif arrayLen(local.colunas) EQ 0>
                <cfset local.resultado.error = "Nenhuma coluna encontrada para a tabela: " & arguments.nomeTabela>
                <cflog file="evidencias_debug" text="Nenhuma coluna encontrada para: #arguments.nomeTabela#">
                <cfreturn local.resultado>
            </cfif>
            
            <!--- Obter MCU da sessão/application --->
            <cfset local.sk_mcu = 0>
            <cfif structKeyExists(application, "rsUsuarioParametros") AND structKeyExists(application.rsUsuarioParametros, "Und_MCU")>
                <cfset local.sk_mcu = val(application.rsUsuarioParametros.Und_MCU)>
            </cfif>
            <cflog file="evidencias_debug" text="MCU da unidade: #local.sk_mcu#">
            
            <!--- Construir WHERE clause para filtro por MCU --->
            <cfset local.mcuClause = "">
            <cfif local.sk_mcu GT 0>
                <!--- Verificar se a tabela tem coluna sk_mcu --->
                <cfset local.temColunaMCU = false>
                <cfloop array="#local.colunas#" index="coluna">
                    <cfif lcase(coluna.nome) EQ "sk_mcu">
                        <cfset local.temColunaMCU = true>
                        <cfbreak>
                    </cfif>
                </cfloop>
                
                <cfif local.temColunaMCU>
                    <cfset local.mcuClause = " WHERE sk_mcu = #local.sk_mcu#">
                    <cflog file="evidencias_debug" text="Aplicando filtro MCU: #local.sk_mcu#">
                <cfelse>
                    <cflog file="evidencias_debug" text="Tabela não possui coluna sk_mcu - sem filtro">
                </cfif>
            </cfif>
            
            <!--- Contar total de registros --->
            <cfquery name="local.qryTotal" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT COUNT(*) as total
                FROM [#arguments.nomeTabela#]
                #PreserveSingleQuotes(local.mcuClause)#
            </cfquery>
            <cfset local.resultado.recordsTotal = local.qryTotal.total>
            
            <cflog file="evidencias_debug" text="Total de registros na tabela: #local.qryTotal.total#">
            
            <!--- Se não há registros, retornar resultado vazio mas válido --->
            <cfif local.qryTotal.total EQ 0>
                <cfset local.resultado.recordsFiltered = 0>
                <cflog file="evidencias_debug" text="Tabela vazia - retornando resultado válido sem dados">
                <cfreturn local.resultado>
            </cfif>
            
            <!--- Construir query principal --->
            <cfset local.sqlSelect = "SELECT ">
            <cfloop from="1" to="#arrayLen(local.colunas)#" index="i">
                <cfif i GT 1><cfset local.sqlSelect &= ", "></cfif>
                <cfset local.sqlSelect &= "[#local.colunas[i].nome#]">
            </cfloop>
            <cfset local.sqlSelect &= " FROM [#arguments.nomeTabela#]">
            
            <!--- Construir filtro de busca combinado com MCU --->
            <cfset local.whereClause = "">
            <cfif len(trim(arguments.searchValue))>
                <cfif len(trim(local.mcuClause))>
                    <cfset local.whereClause = local.mcuClause & " AND (">
                <cfelse>
                    <cfset local.whereClause = " WHERE (">
                </cfif>
                
                <cfloop from="1" to="#arrayLen(local.colunas)#" index="i">
                    <cfif i GT 1><cfset local.whereClause &= " OR "></cfif>
                    <cfset local.whereClause &= "CAST([#local.colunas[i].nome#] AS NVARCHAR(MAX)) LIKE '%#replace(arguments.searchValue, "'", "''", "all")#%'">
                </cfloop>
                <cfset local.whereClause &= ")">
            <cfelse>
                <cfset local.whereClause = local.mcuClause>
            </cfif>
            
            <!--- Contar registros filtrados --->
            <cfquery name="local.qryFiltered" datasource="#application.dsn_avaliacoes_automatizadas#">
                SELECT COUNT(*) as total
                FROM [#arguments.nomeTabela#]
                <cfif len(trim(local.whereClause))>
                    #PreserveSingleQuotes(local.whereClause)#
                </cfif>
            </cfquery>
            <cfset local.resultado.recordsFiltered = local.qryFiltered.total>
            
            <!--- Adicionar ordenação --->
            <cfset local.orderClause = "">
            <cfif arguments.orderColumn GTE 0 AND arguments.orderColumn LT arrayLen(local.colunas)>
                <cfset local.nomeColuna = local.colunas[arguments.orderColumn + 1].nome>
                <cfset local.direction = (arguments.orderDirection EQ "desc" ? "DESC" : "ASC")>
                <cfset local.orderClause = " ORDER BY [#local.nomeColuna#] #local.direction#">
            <cfelse>
                <cfset local.orderClause = " ORDER BY [#local.colunas[1].nome#] ASC">
            </cfif>
            
            <!--- Query final com paginação apenas se há registros filtrados --->
            <cfif local.qryFiltered.total GT 0>
                <cfquery name="local.qryDados" datasource="#application.dsn_avaliacoes_automatizadas#">
                    #PreserveSingleQuotes(local.sqlSelect)#
                    <cfif len(trim(local.whereClause))>
                        #PreserveSingleQuotes(local.whereClause)#
                    </cfif>
                    #PreserveSingleQuotes(local.orderClause)#
                    <cfif NOT arguments.exportAll>
                        OFFSET #arguments.start# ROWS
                        FETCH NEXT #arguments.length# ROWS ONLY
                    </cfif>
                </cfquery>
                
                <cflog file="evidencias_debug" text="Query de dados executada. Registros retornados: #local.qryDados.recordCount#">
                
                <!--- Converter dados para array --->
                <cfloop query="local.qryDados">
                    <cfset local.linha = arrayNew(1)>
                    <cfloop from="1" to="#arrayLen(local.colunas)#" index="i">
                        <cfset local.nomeColuna = local.colunas[i].nome>
                        
                        <!--- Acessar o valor correto da coluna --->
                        <cftry>
                            <cfset local.valor = evaluate("local.qryDados.#local.nomeColuna#")>
                            
                            <!--- Formatação especial para tipos de dados --->
                            <cfif isDate(local.valor)>
                                <cfset local.valor = dateFormat(local.valor, "dd/mm/yyyy") & " " & timeFormat(local.valor, "HH:mm:ss")>
                            <cfelseif isNumeric(local.valor) AND local.colunas[i].tipo EQ "money">
                                <cfset local.valor = "R$ " & numberFormat(local.valor, "999,999,999.00")>
                            <cfelseif isNumeric(local.valor) AND listFind("decimal,numeric,float,real", local.colunas[i].tipo)>
                                <cfset local.valor = numberFormat(local.valor, "999,999,999.00")>
                            <cfelseif isNull(local.valor) OR local.valor EQ "">
                                <cfset local.valor = "">
                            <cfelse>
                                <cfset local.valor = toString(local.valor)>
                            </cfif>
                            
                            <cfcatch type="any">
                                <cflog file="evidencias_erro" text="Erro ao acessar coluna #local.nomeColuna#: #cfcatch.message#">
                                <cfset local.valor = "Erro">
                            </cfcatch>
                        </cftry>
                        
                        <cfset arrayAppend(local.linha, local.valor)>
                    </cfloop>
                    <cfset arrayAppend(local.resultado.data, local.linha)>
                </cfloop>
            </cfif>
            
            <cflog file="evidencias_debug" text="Processamento concluído. Linhas de dados: #arrayLen(local.resultado.data)#">
            
            <cfcatch type="any">
                <cflog file="evidencias_erro" text="Erro ao obter dados da tabela #arguments.nomeTabela#: #cfcatch.message# - #cfcatch.detail#">
                <cfset local.resultado.error = "Erro ao consultar dados: " & cfcatch.message>
            </cfcatch>
        </cftry>
        
        <cfreturn local.resultado>
    </cffunction>

</cfcomponent>

