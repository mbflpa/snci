<cfprocessingdirective pageencoding="utf-8">
<cfcontent type="application/json">

<cfparam name="url.tabela" default="">
<cfparam name="url.draw" default="1">
<cfparam name="url.start" default="0">
<cfparam name="url.length" default="10">
<cfparam name="url.search[value]" default="">
<cfparam name="url.order[0][column]" default="0">
<cfparam name="url.order[0][dir]" default="asc">

<cfset local.resultado = {
    "draw" = val(url.draw),
    "recordsTotal" = 0,
    "recordsFiltered" = 0,
    "data" = [],
    "error" = ""
}>

<cftry>
    <cfif len(trim(url.tabela))>
        <cfset local.objEvidencias = createObject("component", "cfc.EvidenciasManager")>
        
        <cfset local.dados = local.objEvidencias.obterDadosTabela(
            nomeTabela = trim(url.tabela),
            start = val(url.start),
            length = val(url.length),
            searchValue = trim(url["search[value]"]),
            orderColumn = val(url["order[0][column]"]),
            orderDirection = url["order[0][dir]"]
        )>
        
        <cfset local.resultado.recordsTotal = local.dados.recordsTotal>
        <cfset local.resultado.recordsFiltered = local.dados.recordsFiltered>
        <cfset local.resultado.data = local.dados.data>
    <cfelse>
        <cfset local.resultado.error = "Nome da tabela não informado">
    </cfif>
    
    <cfcatch type="any">
        <cfset local.resultado.error = "Erro ao carregar dados: " & cfcatch.message>
        <cflog file="evidencias_erro" text="Erro na API: #cfcatch.message# - #cfcatch.detail#">
    </cfcatch>
</cftry>

<cfoutput>#serializeJSON(local.resultado)#</cfoutput>
