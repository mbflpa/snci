<cfprocessingdirective pageencoding = "utf-8">
<!--Utilizado para exibir um arquivo PDF diretamente no navegador, sem a necessidade de baixá-lo. Utilizado no cfc pc_cfcFaqs, método formFaq-->
<cfparam name="url.arquivo" default="">
<cfparam name="url.nome" default="documento.pdf">
  
<cfif NOT FileExists(url.arquivo)>
    <cfoutput>Arquivo não encontrado.</cfoutput>
    <cfabort>
</cfif>

<cfheader name="Content-Disposition" value="inline; filename=#url.nome#">
<cfcontent type="application/pdf" file="#url.arquivo#" deleteFile="no">
