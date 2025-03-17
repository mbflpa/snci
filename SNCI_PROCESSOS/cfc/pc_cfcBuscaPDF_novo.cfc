<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">

    <!--- Função para limpar status antigos --->
    <cffunction name="cleanupSearchStatus" access="private" returntype="void" output="false">
        <cfset var expirationTime = DateAdd("h", -1, now())> <!--- Status mais velhos que 1 hora são removidos --->
        
        <cftry>
            <cflock scope="application" timeout="5" type="exclusive">
                <cfif structKeyExists(application, "searchStatus") AND NOT StructIsEmpty(application.searchStatus)>
                    <cfloop collection="#application.searchStatus#" item="jobID">
                        <cfif structKeyExists(application.searchStatus, jobID) AND 
                              structKeyExists(application.searchStatus[jobID], "lastUpdated") AND
                              application.searchStatus[jobID].lastUpdated LT expirationTime>
                            <cfset structDelete(application.searchStatus, jobID)>
                        </cfif>
                    </cfloop>
                </cfif>
            </cflock>
            <cfcatch type="any">
                <cflog file="pdfSearch" text="Erro ao limpar searchStatus antigos: #cfcatch.message#">
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="extractPDFText" access="public" returntype="struct" output="false" hint="Extrai o texto de um arquivo PDF usando ColdFusion">
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
        
        <!--- Verificar se o último cleanup foi há mais de 10 minutos --->
        <cfif NOT isDefined("application.lastStatusCleanup") OR DateDiff("n", application.lastStatusCleanup, now()) GT 10>
            <cfset cleanupSearchStatus()>
            <cfset application.lastStatusCleanup = now()>
        </cfif>
        
        <!--- Debug: Logar os parâmetros recebidos --->
        <cflog file="pdfSearch" text="Iniciando busca. Termos: #arguments.searchTerms#">
        
        <!--- Mover o cfheader para antes de qualquer processamento --->
        <cfheader name="Content-Type" value="application/json; charset=utf-8">
        
        <!--- Inicializar a variável filesRead para evitar o erro "Element FILESREAD is undefined in LOCAL" --->
        <cfset local.filesRead = 0>
        
        <cfset local.result = {
            success = true,
            message = "",
            results = [],
            totalFound = 0,
            searchTime = 0,
            filesRead = 0,
            isPartialResult = false
        }>
        
        <cfset local.startTime = getTickCount()>
        <cfset local.options = deserializeJSON(arguments.searchOptions)>
        
        <!--- Melhor tratamento e log dos termos de busca --->
        <cflog file="pdfSearch" text="Termos de busca brutos: '#arguments.searchTerms#'">
        
        <!--- Determinar o modo de busca --->
        <cfset local.searchMode = structKeyExists(local.options, "mode") ? local.options.mode : "or">
        <cflog file="pdfSearch" text="Modo de busca: #local.searchMode#">
        
        <!--- Se for modo exato, não divide em termos --->
        <cfif local.searchMode EQ "exact">
            <cfset local.searchPhrase = trim(arguments.searchTerms)>
            <cfset local.termsArray = [local.searchPhrase]>
            <cflog file="pdfSearch" text="Buscando frase exata: '#local.searchPhrase#'">
        <cfelse>
            <!--- Para modo OU ou proximidade, divide em termos --->
            <cfset local.termsArray = listToArray(trim(arguments.searchTerms), " ")>
            <cflog file="pdfSearch" text="Termos de busca separados: #arrayToList(local.termsArray, ', ')#">
        </cfif>
        
        <!--- Criar um ID único para esta busca (evita conflitos entre várias buscas com os mesmos termos) --->
        <cfset local.searchID = createUUID()>
        <cfset local.result.searchID = local.searchID> <!--- Adicionar o ID à resposta --->
        
        <!--- Salvar o status inicial da busca na Application ou Server scope --->
        <cftry>
            <cflock scope="application" timeout="3" type="exclusive">
                <cfif not structKeyExists(application, "searchStatus")>
                    <cfset application.searchStatus = {}>
                </cfif>
                <cfset application.searchStatus[local.searchID] = {
                    searchTerms = arguments.searchTerms,
                    inProgress = true,
                    progress = 0,
                    status = "Iniciando busca...",
                    resultsFound = 0,
                    recentResults = [],
                    lastUpdated = now()
                }>
                <!--- Também armazenar com o searchTerms para compatibilidade --->
                <cfset application.searchStatus[arguments.searchTerms] = application.searchStatus[local.searchID]>
            </cflock>
            <cfcatch type="any">
                <cflog file="pdfSearch" text="Aviso: Não foi possível inicializar searchStatus: #cfcatch.message#">
            </cfcatch>
        </cftry>
        
        <cftry>
            <!--- Verificar se application.diretorio_busca_pdf está definido --->
            <cfif not isDefined("application.diretorio_busca_pdf") or not directoryExists(application.diretorio_busca_pdf)>
                <!--- Tentar usar uma localização padrão se a variável de aplicação não estiver definida --->
                <cfif directoryExists("C:\ColdFusion11\cfusion\wwwroot\snci\pdf")>
                    <cfset application.diretorio_busca_pdf = "C:\ColdFusion11\cfusion\wwwroot\snci\pdf">
                <cfelse>
                    <cfset local.result.success = false>
                    <cfset local.result.message = "Diretório de PDFs não encontrado. Verifique a configuração.">
                    <cflog file="pdfSearch" text="Erro: Diretório não encontrado. application.diretorio_busca_pdf não está definido ou não existe.">
                    <cfreturn serializeJSON(local.result)>
                </cfif>
            </cfif>
            
            <cflog file="pdfSearch" text="Buscando em diretório: #application.diretorio_busca_pdf#">
            
            <!--- Listar PDFs do diretório --->
            <cfdirectory action="list" directory="#application.diretorio_busca_pdf#" name="local.pdfFiles" filter="*.pdf" recurse="true">
            
            <cflog file="pdfSearch" text="Total de arquivos encontrados: #local.pdfFiles.recordCount#">
            
            <!--- Atualizar status com total de arquivos --->
            <cflock scope="application" timeout="10" type="exclusive">
                <cfset application.searchStatus[arguments.searchTerms].status = "Encontrados #local.pdfFiles.recordCount# arquivos para processar">
                <cfset application.searchStatus[arguments.searchTerms].progress = 5>
                <cfset application.searchStatus[arguments.searchTerms].lastUpdated = now()>
            </cflock>
            
            <!--- Aplicar filtros se necessário --->
            <cfif structKeyExists(local.options, "processYear") AND len(trim(local.options.processYear))>
                <cfquery name="local.pdfFiles" dbtype="query">
                    SELECT * FROM local.pdfFiles 
                    WHERE name LIKE '%#local.options.processYear#%'
                </cfquery>
                <cflog file="pdfSearch" text="Filtro por ano aplicado: #local.options.processYear#. Restam: #local.pdfFiles.recordCount# arquivos">
            </cfif>
            
            <cfif structKeyExists(local.options, "titleSearch") AND len(trim(local.options.titleSearch))>
                <cfquery name="local.pdfFiles" dbtype="query">
                    SELECT * FROM local.pdfFiles 
                    WHERE LOWER(name) LIKE '%#lCase(local.options.titleSearch)#%'
                </cfquery>
                <cflog file="pdfSearch" text="Filtro por título aplicado: #local.options.titleSearch#. Restam: #local.pdfFiles.recordCount# arquivos">
            </cfif>
            
            <cfset local.totalFiles = local.pdfFiles.recordCount>
            <cfset local.processedCount = 0>
            <cfset local.recentResults = []>
            
            <cfloop query="local.pdfFiles">
                <cfset local.filePath = local.pdfFiles.directory & "\" & local.pdfFiles.name>
                <cfset local.processedCount++>
                <cfset local.filesRead++>
                
                <!--- Atualizar progresso a cada 5 arquivos --->
                <cfif local.processedCount MOD 5 EQ 0 OR local.processedCount EQ local.totalFiles>
                    <cfset local.progressPercent = Min(95, Int((local.processedCount / local.totalFiles) * 100))>
                    <cflock scope="application" timeout="10" type="exclusive">
                        <cfset application.searchStatus[arguments.searchTerms].progress = local.progressPercent>
                        <cfset application.searchStatus[arguments.searchTerms].status = "Processados #local.processedCount# de #local.totalFiles# arquivos (#local.progressPercent#%)">
                        <cfset application.searchStatus[arguments.searchTerms].lastUpdated = now()>
                    </cflock>
                </cfif>
                
                <!--- Extrair texto do PDF --->
                <cftry>
                    <cfpdf action="extracttext" source="#local.filePath#" name="local.extractedText">
                    <cfpdf action="getInfo" source="#local.filePath#" name="local.pdfInfo">
                    
                    <!--- Log para debug do conteúdo extraído - truncado para evitar logs gigantes --->
                    <cfset local.textPreview = Left(local.extractedText, 500)>
                    <cfif Len(local.extractedText) GT 500>
                        <cfset local.textPreview = local.textPreview & "...">
                    </cfif>
                    <cfset local.textPreview = Replace(local.textPreview, chr(10), " ", "ALL")>
                    <cfset local.textPreview = Replace(local.textPreview, chr(13), " ", "ALL")>
                    <cflog file="pdfSearch" text="Extraído texto de #local.pdfFiles.name#. Primeiros caracteres: #local.textPreview#">
                    
                    <cfset local.found = false>
                    <cfset local.snippets = []>
                    
                    <!--- Aplicar a lógica de busca baseada no modo selecionado --->
                    <cfif local.searchMode EQ "exact">
                        <!--- Modo Frase Exata: busca pela frase completa --->
                        <cfif findNoCase(local.searchPhrase, local.extractedText)>
                            <cfset local.found = true>
                            <cflog file="pdfSearch" text="Encontrada frase exata '#local.searchPhrase#' em #local.pdfFiles.name#">
                            
                            <!--- Criar trecho com contexto para destaque --->
                            <cfset local.position = findNoCase(local.searchPhrase, local.extractedText)>
                            <cfset local.start = max(1, local.position - 200)>
                            <cfset local.end = min(len(local.extractedText), local.position + len(local.searchPhrase) + 200)>
                            <cfset local.snippet = mid(local.extractedText, local.start, local.end - local.start)>
                            <cfif local.start GT 1>
                                <cfset local.snippet = "..." & local.snippet>
                            </cfif>
                            <cfif local.end LT len(local.extractedText)>
                                <cfset local.snippet = local.snippet & "...">
                            </cfif>
                            <cfset local.snippet = REReplace(local.snippet, "(?i)(#local.searchPhrase#)", "<mark>\1</mark>", "ALL")>
                            <cfset arrayAppend(local.snippets, local.snippet)>
                        </cfif>
                    <cfelseif local.searchMode EQ "proximity">
                        <!--- Modo Proximidade: todos os termos devem estar presentes próximos --->
                        <cfset local.allTermsFound = true>
                        <cfloop array="#local.termsArray#" index="term">
                            <cfif NOT findNoCase(term, local.extractedText)>
                                <cfset local.allTermsFound = false>
                                <cfbreak>
                            </cfif>
                        </cfloop>
                        
                        <cfif local.allTermsFound>
                            <cfset local.found = true>
                            <cflog file="pdfSearch" text="Encontrados termos em proximidade em #local.pdfFiles.name#">
                            
                            <cfset local.firstTerm = local.termsArray[1]>
                            <cfset local.position = findNoCase(local.firstTerm, local.extractedText)>
                            <cfset local.start = max(1, local.position - 200)>
                            <cfset local.end = min(len(local.extractedText), local.position + 400)>
                            <cfset local.snippet = mid(local.extractedText, local.start, local.end - local.start)>
                            <cfif local.start GT 1>
                                <cfset local.snippet = "..." & local.snippet>
                            </cfif>
                            <cfif local.end LT len(local.extractedText)>
                                <cfset local.snippet = local.snippet & "...">
                            </cfif>
                            <cfloop array="#local.termsArray#" index="term">
                                <cfset local.snippet = REReplace(local.snippet, "(?i)(#term#)", "<mark>\1</mark>", "ALL")>
                            </cfloop>
                            <cfset arrayAppend(local.snippets, local.snippet)>
                        </cfif>
                    <cfelse>
                        <!--- Modo "OU": busca por qualquer um dos termos --->
                        <cfloop array="#local.termsArray#" index="term">
                            <!--- Ignoramos termos vazios ou muito curtos --->
                            <cfif len(trim(term)) GTE 3>
                                <cfif findNoCase(term, local.extractedText)>
                                    <cfset local.found = true>
                                    <cflog file="pdfSearch" text="Encontrado termo '#term#' em #local.pdfFiles.name#">
                                    
                                    <!--- Criar trecho com contexto --->
                                    <cfset local.position = findNoCase(term, local.extractedText)>
                                    <cfset local.start = max(1, local.position - 100)>
                                    <cfset local.end = min(len(local.extractedText), local.position + len(term) + 200)>
                                    <cfset local.snippet = mid(local.extractedText, local.start, local.end - local.start)>
                                    
                                    <cfif local.start GT 1>
                                        <cfset local.snippet = "..." & local.snippet>
                                    </cfif>
                                    <cfif local.end LT len(local.extractedText)>
                                        <cfset local.snippet = local.snippet & "...">
                                    </cfif>
                                    
                                    <!--- Usar regex com flag case-insensitive (i) --->
                                    <cfset local.snippet = REReplace(local.snippet, "(?i)(#term#)", "<mark>\1</mark>", "ALL")>
                                    <cfset arrayAppend(local.snippets, local.snippet)>
                                    <cfbreak> <!--- Apenas um snippet por termo é suficiente --->
                                </cfif>
                            </cfif>
                        </cfloop>
                    </cfif>
                    
                    <!--- Se encontrou pelo menos um termo, adicionar aos resultados --->
                    <cfif local.found>
                        <cfset local.displayPath = replace(local.filePath, application.diretorio_busca_pdf, "")>
                        <cfset local.matchResult = {
                            fileName = local.pdfFiles.name,
                            filePath = local.filePath,
                            displayPath = local.displayPath,
                            fileSize = local.pdfFiles.size,
                            fileDate = local.pdfFiles.dateLastModified,
                            pageCount = local.pdfInfo.totalpages,
                            snippets = local.snippets,
                            text = left(local.extractedText, 10000) <!--- Truncar para não sobrecarregar --->
                        }>
                        <cfset arrayAppend(local.result.results, local.matchResult)>
                        <cfset arrayAppend(local.recentResults, local.matchResult)>
                        
                        <!--- Log para verificar a estrutura do snippet --->
                        <cfif arrayLen(local.snippets) GT 0>
                            <cflog file="pdfSearch" text="Snippet gerado para #local.pdfFiles.name#: #left(local.snippets[1], 100)#...">
                        </cfif>
                        
                        <!--- Atualizar status com os resultados recentes imediatamente para cada resultado --->
                        <cflock scope="application" timeout="10" type="exclusive">
                            <cfif structKeyExists(application.searchStatus, local.searchID)>
                                <cfset application.searchStatus[local.searchID].resultsFound += 1>
                                <cfset application.searchStatus[local.searchID].recentResults = [duplicate(local.matchResult)]>
                                <cfset application.searchStatus[local.searchID].lastUpdated = now()>
                            </cfif>
                            <cfif structKeyExists(application.searchStatus, arguments.searchTerms)>
                                <cfset application.searchStatus[arguments.searchTerms].resultsFound += 1>
                                <cfset application.searchStatus[arguments.searchTerms].recentResults = [duplicate(local.matchResult)]>
                                <cfset application.searchStatus[arguments.searchTerms].lastUpdated = now()>
                            </cfif>
                        </cflock>
                    </cfif>
                    
                    <cfcatch type="any">
                        <cflog file="pdfSearch" text="Erro ao processar arquivo #local.pdfFiles.name#: #cfcatch.message#">
                        <!--- Continuar com próximo arquivo --->
                    </cfcatch>
                </cftry>
            </cfloop>
            
            <!--- Atualizar status final --->
            <cflock scope="application" timeout="10" type="exclusive">
                <cfif structKeyExists(application.searchStatus, local.searchID)>
                    <cfset application.searchStatus[local.searchID].progress = 100>
                    <cfset application.searchStatus[local.searchID].status = "Busca concluída">
                    <cfset application.searchStatus[local.searchID].resultsFound = arrayLen(local.result.results)>
                    <cfset application.searchStatus[local.searchID].inProgress = false>
                    <cfset application.searchStatus[local.searchID].lastUpdated = now()>
                </cfif>
                <cfif structKeyExists(application.searchStatus, arguments.searchTerms)>
                    <cfset application.searchStatus[arguments.searchTerms].progress = 100>
                    <cfset application.searchStatus[arguments.searchTerms].status = "Busca concluída">
                    <cfset application.searchStatus[arguments.searchTerms].resultsFound = arrayLen(local.result.results)>
                    <cfset application.searchStatus[arguments.searchTerms].inProgress = false>
                    <cfset application.searchStatus[arguments.searchTerms].lastUpdated = now()>
                </cfif>
            </cflock>
            
            <!--- Garantir que a variável filesRead seja definida no resultado final --->
            <cfset local.result.filesRead = local.filesRead>
            <cfset local.result.totalFound = arrayLen(local.result.results)>
            <cfset local.result.searchTime = (getTickCount() - local.startTime) / 1000>
            <cfset local.result.message = "Encontrados #local.result.totalFound# documentos">
            
            <!--- Log detalhado do primeiro resultado para depuração (se houver resultados) --->
            <cfif arrayLen(local.result.results) GT 0>
                <cfset local.sampleResult = local.result.results[1]>
                <cfset local.resultKeys = structKeyList(local.sampleResult)>
                <cflog file="pdfSearch" text="Estrutura do resultado: #local.resultKeys#">
                <cflog file="pdfSearch" text="Exemplo de dados: fileName=#local.sampleResult.fileName#, pageCount=#local.sampleResult.pageCount#">
            </cfif>
            
            <cflog file="pdfSearch" text="Busca concluída. Encontrados #local.result.totalFound# documentos em #local.result.searchTime# segundos. Arquivos lidos: #local.filesRead#">
            
            <!--- Garantir que a resposta seja formatada como JSON válido --->
            <cftry>
                <cfreturn serializeJSON(local.result)>
                <cfcatch type="any">
                    <cflog file="pdfSearch" text="Erro ao serializar resultado em searchInPDFs: #cfcatch.message#">
                    <cfreturn '{"success":false,"message":"Erro ao serializar resultados da busca","results":[],"totalFound":0,"searchTime":0,"filesRead":0,"isPartialResult":false}'>
                </cfcatch>
            </cftry>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.message = "Erro ao realizar a busca: #cfcatch.message#">
                <cflog file="pdfSearch" text="Erro geral na busca: #cfcatch.message# - #cfcatch.detail#">
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getProcessingStatus" access="remote" returntype="string" returnformat="json" output="false">
        <cfargument name="jobID" type="string" required="true" hint="ID do trabalho de busca (termos da pesquisa)">
        
        <!--- Garantir retorno válido mesmo se der erro --->
        <cftry>
            <cfset local.result = {
                success = true,
                status = "Processando...",
                progress = 0,
                resultsFound = 0,
                isComplete = false,
                recentResults = []
            }>
            
            <!--- Registrar a consulta para depuração --->
            <cflog file="pdfSearch" text="getProcessingStatus chamado para jobID: #arguments.jobID#">
            
            <!--- Verificar se o status existe, sem lock --->
            <cfif structKeyExists(application, "searchStatus") AND structKeyExists(application.searchStatus, arguments.jobID)>
                <!--- Fazer uma cópia local da estrutura de status com lock de leitura (mais rápido) --->
                <cflock scope="application" timeout="5" type="readonly">
                    <cfif structKeyExists(application.searchStatus, arguments.jobID)>
                        <cfset local.statusCopy = duplicate(application.searchStatus[arguments.jobID])>
                        <cflog file="pdfSearch" text="Status encontrado para jobID: #arguments.jobID#, resultsFound: #local.statusCopy.resultsFound#, recentResults: #ArrayLen(local.statusCopy.recentResults)#">
                        
                        <!--- Verificar se temos snippets nos resultados recentes --->
                        <cfif arrayLen(local.statusCopy.recentResults) GT 0 AND 
                              structKeyExists(local.statusCopy.recentResults[1], "snippets") AND
                              arrayLen(local.statusCopy.recentResults[1].snippets) GT 0>
                            <cflog file="pdfSearch" text="Snippet no primeiro resultado recente: #left(local.statusCopy.recentResults[1].snippets[1], 100)#...">
                        </cfif>
                    </cfif>
                </cflock>
                
                <!--- Verificar novamente se temos os dados --->
                <cfif isDefined("local.statusCopy")>
                    <cfset local.result.status = local.statusCopy.status>
                    <cfset local.result.progress = local.statusCopy.progress>
                    <cfset local.result.resultsFound = local.statusCopy.resultsFound>
                    <cfset local.result.isComplete = NOT local.statusCopy.inProgress>
                    
                    <!--- Se há novos resultados, incluí-los --->
                    <cfif isDefined("local.statusCopy.recentResults") AND isArray(local.statusCopy.recentResults) AND arrayLen(local.statusCopy.recentResults) GT 0>
                        <cfset local.result.recentResults = duplicate(local.statusCopy.recentResults)>
                        
                        <!--- Agora limpamos os resultados recentes --->
                        <cftry>
                            <cflock scope="application" timeout="3" type="exclusive">
                                <cfif structKeyExists(application.searchStatus, arguments.jobID)>
                                    <cfset application.searchStatus[arguments.jobID].recentResults = []>
                                    <cflog file="pdfSearch" text="Limpados recentResults para jobID: #arguments.jobID#">
                                </cfif>
                            </cflock>
                            <cfcatch type="any">
                                <!--- Se houver timeout no lock, log o erro mas não falhe a operação --->
                                <cflog file="pdfSearch" text="Aviso: Não foi possível limpar recentResults para #arguments.jobID#: #cfcatch.message#">
                            </cfcatch>
                        </cftry>
                    </cfif>
                </cfif>
            </cfif>
            
            <cfcatch type="any">
                <cfset local.result = {
                    success = false,
                    error = "Erro ao obter status: #cfcatch.message#",
                    status = "Erro ao processar",
                    progress = 0,
                    resultsFound = 0,
                    isComplete = true,
                    recentResults = []
                }>
                <cflog file="pdfSearch" text="Erro em getProcessingStatus: #cfcatch.message# - #cfcatch.detail#">
            </cfcatch>
        </cftry>
        
        <!--- Usar try-catch para garantir que a serialização não falhe --->
        <cftry>
            <cfreturn serializeJSON(local.result)>
            <cfcatch type="any">
                <cflog file="pdfSearch" text="Erro ao serializar resultado em getProcessingStatus: #cfcatch.message#">
                <cfreturn '{"success":false,"error":"Erro ao serializar resposta","status":"Erro","progress":0,"resultsFound":0,"isComplete":true,"recentResults":[]}'>
            </cfcatch>
        </cftry>
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

    <cffunction name="highlightSearchTerm" access="private" returntype="string">
        <cfargument name="text" type="string" required="true">
        <cfargument name="term" type="string" required="true">
        
        <cfset local.regex = REReplace(arguments.term, "[.*+?^${}()|[\]\\]", "\\$1", "ALL")>
        <cfreturn ReReplaceNoCase(arguments.text, "(#local.regex#)", "<mark>\1</mark>", "ALL")>
    </cffunction>

    <cffunction name="highlightSearchPhrase" access="private" returntype="string">
        <cfargument name="text" type="string" required="true">
        <cfargument name="phrase" type="string" required="true">
        
        <cfset local.regex = REReplace(arguments.phrase, "[.*+?^${}()|[\]\\]", "\\$1", "ALL")>
        <cfreturn ReReplaceNoCase(arguments.text, "(#local.regex#)", "<mark>\1</mark>", "ALL")>
    </cffunction>

    <cffunction name="highlightAllSearchTerms" access="private" returntype="string">
        <cfargument name="text" type="string" required="true">
        <cfargument name="terms" type="array" required="true">
        
        <cfset local.highlightedText = arguments.text>
        
        <cfloop array="#arguments.terms#" index="local.term">
            <cfif Len(local.term) GTE 3>
                <cfset local.regex = REReplace(local.term, "[.*+?^${}()|[\]\\]", "\\$1", "ALL")>
                <cfset local.highlightedText = ReReplaceNoCase(
                    local.highlightedText,
                    "(#local.regex#)",
                    "<mark>\1</mark>",
                    "ALL"
                )>
            </cfif>
        </cfloop>
        
        <cfreturn local.highlightedText>
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
        
        <cfreturn serializeJSON(local.result)>
    </cffunction>

    <cffunction name="exibePdfInline" access="remote" output="true" hint="Exibe um arquivo PDF diretamente no navegador.">
        <cfargument name="arquivo" type="string" required="true" />
        <cfargument name="nome" type="string" required="false" default="documento.pdf" />

        <cflog file="pdfSearch" text="Tentando exibir PDF: #arguments.arquivo#">

        <cfif NOT FileExists(arguments.arquivo)>
            <cfoutput>Arquivo não encontrado: #arguments.arquivo#</cfoutput>
            <cflog file="pdfSearch" text="Arquivo não encontrado: #arguments.arquivo#">
            <cfabort>
        </cfif>

        <cfheader name="Content-Disposition" value="inline; filename=#arguments.nome#">
        <cfcontent type="application/pdf" file="#arguments.arquivo#" deleteFile="no">
    </cffunction>
</cfcomponent>
