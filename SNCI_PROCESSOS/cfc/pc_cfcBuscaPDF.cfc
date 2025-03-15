
<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">

    <cffunction name="extractPDFText" access="private" returntype="struct" output="false" hint="Extrai o texto de um arquivo PDF">
        <cfargument name="pdfFilePath" type="string" required="true" hint="Caminho completo do arquivo PDF">
        
        <cfset local.result = {
            success = true,
            fileName = getFileFromPath(arguments.pdfFilePath),
            text = "",
            error = ""
        }>
        
        <cftry>
            <!--- Extraindo texto do PDF usando o componente nativo do ColdFusion --->
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
        
        <!--- Mover o cfheader para antes de qualquer processamento --->
        <cfheader name="Content-Type" value="application/json; charset=utf-8">
        
        <cfset local.result = {
            success = true,
            message = "",
            results = [],
            totalFound = 0,
            searchTime = 0
        }>
        
        <cfset local.startTime = getTickCount()>
        <cfset local.termsArray = listToArray(trim(arguments.searchTerms), " ")>
        
        <cftry>
            <!--- Verificar se o diretório existe --->
            <cfif not directoryExists(application.diretorio_faqs)>
                <cfset local.result.success = false>
                <cfset local.result.message = "Diretório de FAQs não encontrado">
                <cfreturn serializeJSON(local.result)>
            </cfif>
            
            <!--- Listar todos os arquivos PDF no diretório --->
            <cfdirectory action="list" directory="#application.diretorio_faqs#" name="local.pdfFiles" filter="*.pdf" recurse="true">
            
            <!--- Processar cada arquivo PDF --->
            <cfloop query="local.pdfFiles">
                <cfset local.filePath = local.pdfFiles.directory & "\" & local.pdfFiles.name>
                <cfset local.extractResult = extractPDFText(local.filePath)>
                
                <cfif local.extractResult.success>
                    <cfset local.relevanceScore = 0>
                    <cfset local.termMatches = {}>
                    
                    <!--- Verificar cada termo de busca --->
                    <cfloop array="#local.termsArray#" index="local.term">
                        <cfset local.term = lCase(trim(local.term))>
                        <cfif len(local.term) GTE 3> <!--- Ignorar termos menores que 3 caracteres --->
                            <cfset local.occurrences = countOccurrences(local.extractResult.text, local.term)>
                            <cfif local.occurrences GT 0>
                                <cfset local.termMatches[local.term] = local.occurrences>
                                <cfset local.relevanceScore += local.occurrences>
                            </cfif>
                        </cfif>
                    </cfloop>
                    
                    <!--- Se encontrou pelo menos um termo, adiciona aos resultados --->
                    <cfif structCount(local.termMatches) GT 0>
                        <cfset local.matchResult = {
                            fileName = local.pdfFiles.name,
                            filePath = local.filePath,
                            displayPath = replaceNoCase(local.filePath, application.diretorio_faqs, ""),
                            fileSize = local.pdfFiles.size,
                            fileDate = local.pdfFiles.dateLastModified,
                            relevanceScore = local.relevanceScore,
                            termMatches = local.termMatches,
                            termsFound = structCount(local.termMatches),
                            totalTerms = arrayLen(local.termsArray)
                        }>
                        <cfset arrayAppend(local.result.results, local.matchResult)>
                    </cfif>
                </cfif>
            </cfloop>
            
            <!--- Ordenar resultados por relevância (pontuação e número de termos encontrados) --->
            <cfif arrayLen(local.result.results) GT 0>
                <cfset local.result.results = sortResultsByRelevance(local.result.results)>
                <cfset local.result.totalFound = arrayLen(local.result.results)>
                <cfset local.result.message = "Encontrados #local.result.totalFound# documentos">
            <cfelse>
                <cfset local.result.message = "Nenhum resultado encontrado para os termos de busca">
            </cfif>
            
            <cfset local.result.searchTime = (getTickCount() - local.startTime) / 1000>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.message = "Erro ao realizar a busca: #cfcatch.message#">
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

    <cffunction name="sortResultsByRelevance" access="private" returntype="array" output="false" hint="Ordena os resultados por relevância">
        <cfargument name="results" type="array" required="true">
        
        <cfscript>
            arraySort(arguments.results, function(a, b) {
                // Primeiro compara por número de termos encontrados
                if (a.termsFound > b.termsFound) return -1;
                if (a.termsFound < b.termsFound) return 1;
                
                // Se igual, compara por pontuação de relevância
                if (a.relevanceScore > b.relevanceScore) return -1;
                if (a.relevanceScore < b.relevanceScore) return 1;
                
                return 0;
            });
        </cfscript>
        
        <cfreturn arguments.results>
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
            
            <!--- Verificar se o diretório existe --->
            <cfif not directoryExists(application.diretorio_avaliacoes)>
                <cfset local.result.success = false>
                <cfset local.result.message = "Diretório de FAQs não encontrado">
                <cfreturn serializeJSON(local.result)>
            </cfif>
            
            <!--- Listar todos os arquivos PDF no diretório --->
            <cfdirectory action="list" directory="#application.diretorio_avaliacoes#" name="local.pdfFiles" filter="*.pdf" recurse="true">
            
            <!--- Processar cada arquivo PDF --->
            <cfloop query="local.pdfFiles">
                <cfset local.filePath = local.pdfFiles.directory & "\" & local.pdfFiles.name>
                <cfset local.relativePath = replaceNoCase(local.filePath, application.diretorio_avaliacoes, "")>
                
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
</cfcomponent>