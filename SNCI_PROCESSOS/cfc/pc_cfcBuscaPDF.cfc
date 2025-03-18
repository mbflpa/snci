<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">

    <cffunction name="extractPDFText" access="private" returntype="struct" output="false" hint="Extrai o texto de um arquivo PDF">
        <cfargument name="pdfFilePath" type="string" required="true" hint="Caminho completo do arquivo PDF">
        
        <cfset local.result = {
            success = true,
            fileName = getFileFromPath(arguments.pdfFilePath),
            text = "",
            pageCount = 0,
            error = ""
        }>
        
        <cftry>
            <!--- Extraindo informações do PDF usando o componente nativo do ColdFusion --->
            <cfpdf action="getInfo" source="#arguments.pdfFilePath#" name="local.pdfInfo">
            <cfset local.result.pageCount = local.pdfInfo.totalpages>
            
            <!--- Extraindo texto do PDF --->
            <cfpdf action="extracttext" source="#arguments.pdfFilePath#" name="local.extractedText">
            <cfset local.result.text = local.extractedText>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.error = "Erro ao extrair texto do PDF: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfreturn local.result>
    </cffunction>

    <cffunction name="searchInPDFs" access="remote" returntype="string" returnformat="json" output="false" hint="Busca termos nos arquivos PDFs e retorna resultados em formato JSON">
        <cfargument name="searchTerms" type="string" required="true" hint="Termos de busca separados por espaço">
        <cfargument name="searchOptions" type="string" required="false" default="{}" hint="Opções de busca em formato JSON">
        
        <!--- Inicializar o componente para garantir que o cache existe --->
        <cfset init()>
        
        <!--- Mover o cfheader para antes de qualquer processamento --->
        <cfheader name="Content-Type" value="application/json; charset=utf-8">
        
        <cfset local.result = {
            success = true,
            message = "",
            results = [],
            totalFound = 0,
            searchTime = 0,
            cacheStats = {
                hits = 0,
                misses = 0,
                totalDocuments = 0
            }
        }>
        
        <cfset local.startTime = getTickCount()>
        <cfset local.options = deserializeJSON(arguments.searchOptions)>
        <cfset local.batchSize = 10> <!--- Processar 10 arquivos por lote --->
        
        <cftry>
            <!--- Verificar diretório e listar PDFs --->
            <cfif not directoryExists(application.diretorio_busca_pdf)>
                <cfset local.result.success = false>
                <cfset local.result.message = "Diretório de PDFs não encontrado">
                <cfreturn serializeJSON(local.result)>
            </cfif>
            
            <cfdirectory action="list" directory="#application.diretorio_busca_pdf#" name="local.pdfFiles" filter="*.pdf" recurse="true">
            
            <!--- Filtrar arquivos por ano ou título se necessário --->
            <cfset local.filteredFiles = []>
            
            <cfloop query="local.pdfFiles">
                <cfset local.includeFile = true>
                
                <!--- Filtrar por ano do processo, se informado --->
                <cfif structKeyExists(local.options, "processYear") AND len(local.options.processYear)>
                    <cfset local.yearMatch = reFind("_PC\d+(\d{4})_", local.pdfFiles.name, 1, true)>
                    <cfif arrayLen(local.yearMatch.pos) GTE 2>
                        <cfset local.foundYear = mid(local.pdfFiles.name, local.yearMatch.pos[2], local.yearMatch.len[2])>
                        <cfif local.foundYear NEQ local.options.processYear>
                            <cfset local.includeFile = false>
                        </cfif>
                    <cfelse>
                        <cfset local.includeFile = false>
                    </cfif>
                </cfif>
                
                <!--- Filtrar por texto no título, se informado --->
                <cfif local.includeFile AND structKeyExists(local.options, "titleSearch") AND len(local.options.titleSearch)>
                    <cfif NOT FindNoCase(local.options.titleSearch, local.pdfFiles.name)>
                        <cfset local.includeFile = false>
                    </cfif>
                </cfif>
                
                <cfif local.includeFile>
                    <cfset arrayAppend(local.filteredFiles, {
                        name = local.pdfFiles.name,
                        directory = local.pdfFiles.directory,
                        size = local.pdfFiles.size,
                        dateLastModified = local.pdfFiles.dateLastModified
                    })>
                </cfif>
            </cfloop>
            
            <cfset local.result.cacheStats.totalDocuments = arrayLen(local.filteredFiles)>
            
            <!--- Processar arquivos em lotes --->
            <cfset local.totalFiles = arrayLen(local.filteredFiles)>
            <cfset local.allResults = []>
            
            <cfloop from="1" to="#local.totalFiles#" index="i" step="#local.batchSize#">
                <cfset local.endIndex = min(i + local.batchSize - 1, local.totalFiles)>
                <cfset local.currentBatch = []>
                
                <!--- Criar o lote atual --->
                <cfloop from="#i#" to="#local.endIndex#" index="j">
                    <cfset arrayAppend(local.currentBatch, local.filteredFiles[j])>
                </cfloop>
                
                <!--- Processar o lote --->
                <cfset local.batchResults = processPDFBatch(local.currentBatch, arguments.searchTerms, local.options)>
                <cfset local.allResults = arrayConcat(local.allResults, local.batchResults)>
            </cfloop>
            
            <!--- Ordenar resultados por relevância --->
            <cfset local.result.results = sortResultsByRelevance(local.allResults)>
            <cfset local.result.totalFound = arrayLen(local.result.results)>
            <cfset local.result.searchTime = (getTickCount() - local.startTime) / 1000>
            
            <!--- Incluir estatísticas de cache --->
            <cfif structKeyExists(application, "pdfCacheStats")>
                <cfset local.result.cacheStats.hits = application.pdfCacheStats.hits>
                <cfset local.result.cacheStats.misses = application.pdfCacheStats.misses>
            </cfif>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.message = "Erro ao realizar a busca: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(local.result)>
    </cffunction>
    
    <cffunction name="sortResultsByRelevance" access="private" returntype="array" output="false" hint="Ordena os resultados por relevância">
        <cfargument name="results" type="array" required="true">
        
        <cfscript>
            arraySort(arguments.results, function(a, b) {
                // Comparar por pontuação de relevância
                if (structKeyExists(a, "relevanceScore") && structKeyExists(b, "relevanceScore")) {
                    if (a.relevanceScore > b.relevanceScore) return -1;
                    if (a.relevanceScore < b.relevanceScore) return 1;
                }
                
                // Se não tiver relevância ou for igual, comparar pelo tamanho dos snippets
                // Quanto mais snippets, provavelmente mais relevante
                if (arrayLen(a.snippets) > arrayLen(b.snippets)) return -1;
                if (arrayLen(a.snippets) < arrayLen(b.snippets)) return 1;
                
                return 0;
            });
        </cfscript>
        
        <cfreturn arguments.results>
    </cffunction>
    
    <cffunction name="getDocumentStats" access="remote" returntype="string" returnformat="json" output="false" hint="Retorna estatísticas de uso de cache e processamento">
        <cfset local.stats = {
            cacheHits = application.pdfCacheStats.hits,
            cacheMisses = application.pdfCacheStats.misses,
            cacheTotalSaved = application.pdfCacheStats.totalSaved,
            documentsInCache = structCount(application.pdfTextCache)
        }>
        
        <cfreturn serializeJSON(local.stats)>
    </cffunction>
    
    <cffunction name="clearCache" access="remote" returntype="string" returnformat="json" output="false" hint="Limpa o cache de textos extraídos">
        <cflock scope="application" timeout="10" type="exclusive">
            <cfset application.pdfTextCache = {}>
            <cfset application.pdfCacheStats.hits = 0>
            <cfset application.pdfCacheStats.misses = 0>
            <cfset application.pdfCacheStats.totalSaved = 0>
        </cflock>
        
        <cfreturn serializeJSON({success = true, message = "Cache limpo com sucesso"})>
    </cffunction>

    <!--- Implementação da distribuição inteligente de processamento --->
    <cffunction name="getPdfComplexityScore" access="remote" returntype="string" returnformat="json" output="false" hint="Analisa a complexidade do documento para determinar onde processar">
        <cfargument name="filePath" type="string" required="true" hint="Caminho para o arquivo PDF">
        
        <cfset local.result = {
            success = true,
            complexity = "unknown",
            size = 0,
            pageCount = 0,
            processingRecommendation = "client"
        }>
        
        <cftry>
            <cfset local.fileInfo = getFileInfo(arguments.filePath)>
            <cfset local.result.size = local.fileInfo.size>
            
            <!--- Obter número de páginas --->
            <cfpdf action="getInfo" source="#arguments.filePath#" name="local.pdfInfo">
            <cfset local.result.pageCount = local.pdfInfo.totalpages>
            
            <!--- Determinar complexidade baseado em tamanho e número de páginas --->
            <cfset local.sizeThreshold = 5 * 1024 * 1024> <!--- 5 MB --->
            <cfset local.pageThreshold = 20> <!--- 20 páginas --->
            
            <cfif local.result.size GT local.sizeThreshold OR local.result.pageCount GT local.pageThreshold>
                <cfset local.result.complexity = "complex">
                <cfset local.result.processingRecommendation = "server">
            <cfelse>
                <cfset local.result.complexity = "simple">
                <cfset local.result.processingRecommendation = "client">
            </cfif>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.message = "Erro ao analisar complexidade: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(local.result)>
    </cffunction>

    <!--- Função para compartilhar texto extraído de PDFs entre cliente e servidor --->
    <cffunction name="saveExtractedText" access="remote" returntype="string" returnformat="json" output="false" hint="Salva texto extraído pelo cliente no cache do servidor">
        <cfargument name="filePath" type="string" required="true" hint="Caminho do arquivo PDF">
        <cfargument name="text" type="string" required="true" hint="Texto extraído do PDF">
        <cfargument name="pageCount" type="numeric" required="true" hint="Número de páginas do PDF">
        
        <cfset local.result = {
            success = true,
            message = "Texto salvo com sucesso"
        }>
        
        <cftry>
            <cfif not structKeyExists(application, "pdfTextCache")>
                <cfset init()>
            </cfif>
            
            <cfset local.fileInfo = getFileInfo(arguments.filePath)>
            <cfset local.cacheKey = arguments.filePath>
            
            <cflock scope="application" timeout="5" type="exclusive">
                <cfset application.pdfTextCache[local.cacheKey] = {
                    text = arguments.text,
                    pageCount = arguments.pageCount,
                    lastModified = local.fileInfo.lastModified,
                    fileSize = local.fileInfo.size,
                    extractionTime = 0, <!--- Não temos esta informação quando vem do cliente --->
                    cachedDate = now(),
                    source = "client" <!--- Indica que veio do cliente --->
                }>
                
                <!--- Atualizar estatísticas de cache --->
                <cfset application.pdfCacheStats.totalSaved++>
            </cflock>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.message = "Erro ao salvar texto: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(local.result)>
    </cffunction>

    <!--- Busca em texto já extraído --->
    <cffunction name="searchInExtractedText" access="remote" returntype="string" returnformat="json" output="false" hint="Busca termos em texto já extraído">
        <cfargument name="filePath" type="string" required="true" hint="Caminho do arquivo PDF">
        <cfargument name="searchTerms" type="string" required="true" hint="Termos de busca">
        <cfargument name="searchOptions" type="string" required="false" default="{}" hint="Opções de busca em formato JSON">
        
        <cfset local.result = {
            success = true,
            fileName = getFileFromPath(arguments.filePath),
            filePath = arguments.filePath,
            found = false,
            snippets = []
        }>
        
        <cftry>
            <!--- Verificar se o texto está no cache --->
            <cfif not structKeyExists(application, "pdfTextCache") OR not structKeyExists(application.pdfTextCache, arguments.filePath)>
                <cfset local.result.success = false>
                <cfset local.result.message = "Texto não encontrado no cache">
                <cfreturn serializeJSON(local.result)>
            </cfif>
            
            <cfset local.options = deserializeJSON(arguments.searchOptions)>
            <cfset local.cachedEntry = application.pdfTextCache[arguments.filePath]>
            <cfset local.text = local.cachedEntry.text>
            
            <!--- Realizar busca otimizada no texto --->
            <cfset local.searchResult = performOptimizedSearch(
                local.text,
                arguments.searchTerms,
                local.options
            )>
            
            <cfset local.result.found = local.searchResult.found>
            <cfset local.result.snippets = local.searchResult.snippets>
            <cfset local.result.relevanceScore = local.searchResult.relevanceScore>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.message = "Erro ao buscar no texto: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cfreturn serializeJSON(local.result)>
    </cffunction>

    <cffunction name="countOccurrences" access="private" returntype="numeric" output="false" hint="Conta o número de ocorrências de um termo em um texto">
        <cfargument name="text" type="string" required="true">
        <cfargument name="term" type="string" required="true">
        
        <cfset local.text = lCase(arguments.text)>
        <cfset local.term = lCase(arguments.term)>
        <cfset local.count = 0>
        <cfset local.position = 1>
        
        <cfloop condition="true">
            <cfset local.position = findNoCase(local.term, local.text, local.position)>
            <cfif local.position EQ 0>
                <cfbreak>
            </cfif>
            <cfset local.count++>
            <cfset local.position += len(local.term)>
        </cfloop>
        
        <cfreturn local.count>
    </cffunction>

    <cffunction name="formatFileSize" access="remote" returntype="string" output="false" hint="Formata o tamanho do arquivo para exibição">
        <cfargument name="size" type="numeric" required="true" hint="Tamanho em bytes">
        
        <cfif arguments.size LT 1024>
            <cfreturn arguments.size & " bytes">
        <cfelseif arguments.size LT 1048576>
            <cfreturn numberFormat(arguments.size / 1024, "___._") & " KB">
        <cfelseif arguments.size LT 1073741824>
            <cfreturn numberFormat(arguments.size / 1048576, "___._") & " MB">
        <cfelse>
            <cfreturn numberFormat(arguments.size / 1073741824, "___._") & " GB">
        </cfif>
    </cffunction>

    <cffunction name="listPdfDocuments" access="remote" returntype="string" returnformat="json" output="false" hint="Lista todos os documentos PDF disponíveis">
        <cftry>
            <cfset local.result = {
                success = true,
                message = "",
                documents = []
            }>
            
            <!--- Voltar a usar application.diretorio_busca_pdf --->
            <cfif not directoryExists(application.diretorio_busca_pdf)>
                <cfset local.result.success = false>
                <cfset local.result.message = "Diretório de PDFs não encontrado">
                <cfreturn serializeJSON(local.result)>
            </cfif>
            
            <!--- Listar todos os arquivos PDF no diretório --->
            <cfdirectory action="list" directory="#application.diretorio_busca_pdf#" name="local.pdfFiles" filter="*.pdf" recurse="true">
            
            <!--- Processar cada arquivo PDF --->
            <cfloop query="local.pdfFiles">
                <cfset local.filePath = local.pdfFiles.directory & "\" & local.pdfFiles.name>
                <!--- Continuar usando application.diretorio_busca_pdf --->
                <cfset local.relativePath = replaceNoCase(local.filePath, application.diretorio_busca_pdf, "")>
                
                <cfset local.document = {
                    fileName = local.pdfFiles.name,
                    filePath = local.filePath,
                    directory = local.pdfFiles.directory,
                    displayPath = local.relativePath,
                    size = local.pdfFiles.size,
                    dateLastModified = local.pdfFiles.dateLastModified
                }>
                
                <cfset arrayAppend(local.result.documents, local.document)>
            </cfloop>
            
            <cfcatch type="any">
                <cfset local.result = {
                    success = false,
                    message = "Erro ao listar documentos: #cfcatch.message#",
                    documents = []
                }>
            </cfcatch>
        </cftry>
        
        <!--- Forçar o formato JSON correto --->
        <cfreturn serializeJSON(local.result)>
    </cffunction>

    <cffunction name="exibePdfInline" access="remote" output="true" hint="Exibe um arquivo PDF diretamente no navegador.">
        <cfargument name="arquivo" type="string" required="true" />
        <cfargument name="nome" type="string" required="false" default="documento.pdf" />

        <cfif NOT FileExists(arguments.arquivo)>
            <cfoutput>Arquivo não encontrado.</cfoutput>
            <cfabort>
        </cfif>

        <cfheader name="Content-Disposition" value="inline; filename=#arguments.nome#">
        <cfcontent type="application/pdf" file="#arguments.arquivo#" deleteFile="no">
    </cffunction>

    <cffunction name="countWords" access="public" returntype="numeric">
        <cfargument name="text" type="string" required="true">
        <cfset var words = ListToArray(arguments.text, " ")>
        <cfreturn ArrayLen(words)>
    </cffunction>

    <cffunction name="checkProximity" access="private" returntype="boolean">
        <cfargument name="text" type="string" required="true">
        <cfargument name="terms" type="array" required="true">
        <cfargument name="proximity" type="numeric" required="true">
        
        <!--- Se proximidade for -1, significa "Em qualquer parte" --->
        <cfif arguments.proximity EQ -1>
            <cfset local.allFound = true>
            <cfloop array="#arguments.terms#" index="local.term">
                <cfif NOT FindNoCase(local.term, arguments.text)>
                    <cfset local.allFound = false>
                    <cfbreak>
                </cfif>
            </cfloop>
            <cfreturn local.allFound>
        </cfif>
        
        <!--- Dividir o texto em palavras --->
        <cfset local.textWords = ListToArray(arguments.text, " ")>
        <cfset local.firstTerm = arguments.terms[1]>
        
        <cfloop from="1" to="#ArrayLen(local.textWords)#" index="i">
            <cfif FindNoCase(local.firstTerm, local.textWords[i])>
                <cfset local.allFound = true>
                <cfloop from="2" to="#ArrayLen(arguments.terms)#" index="j">
                    <cfset local.found = false>
                    <cfset local.term = arguments.terms[j]>
                    
                    <cfloop from="#i+1#" to="#Min(i + arguments.proximity, ArrayLen(local.textWords))#" index="k">
                        <cfif FindNoCase(local.term, local.textWords[k])>
                            <cfset local.found = true>
                            <cfbreak>
                        </cfif>
                    </cfloop>
                    
                    <cfif NOT local.found>
                        <cfset local.allFound = false>
                        <cfbreak>
                    </cfif>
                </cfloop>
                
                <cfif local.allFound>
                    <cfreturn true>
                </cfif>
            </cfif>
        </cfloop>
        
        <cfreturn false>
    </cffunction>

    <cffunction name="highlightAllSearchTerms" access="private" returntype="string">
        <cfargument name="text" type="string" required="true">
        <cfargument name="terms" type="array" required="true">
        
        <cfset local.highlightedText = arguments.text>
        
        <cfloop array="#arguments.terms#" index="local.term">
            <cfif Len(local.term) GTE 3>
                <cfset local.highlightedText = ReReplaceNoCase(
                    local.highlightedText,
                    "(#local.term#)",
                    "<mark>\1</mark>",
                    "ALL"
                )>
            </cfif>
        </cfloop>
        
        <cfreturn local.highlightedText>
    </cffunction>

</cfcomponent>