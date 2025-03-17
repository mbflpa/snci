<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">

    <cffunction name="listPdfDocuments" access="remote" returntype="string" returnformat="json" output="false" hint="Lista todos os documentos PDF disponíveis">
        <cftry>
            <cfset local.result = {
                success = true,
                message = "",
                documents = []
            }>
            
            <!--- Usar o diretório de busca definido na aplicação --->
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
        
        <!--- Garantir que o retorno seja em formato JSON --->
        <cfheader name="Content-Type" value="application/json; charset=utf-8">
        <cfreturn serializeJSON(local.result)>
    </cffunction>

    <cffunction name="exibePdfInline" access="remote" output="true" hint="Exibe um arquivo PDF diretamente no navegador">
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
