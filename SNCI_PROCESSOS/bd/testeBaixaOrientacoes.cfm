<cfoutput>
<!DOCTYPE html>
<html>
<head>
    <title>Teste de Baixa por Valor Envolvido</title>
    <style>
        .success { color: green; }
        .error { color: red; }
        .details { margin: 10px 0; padding: 10px; background: ##f5f5f5; }
    </style>
</head>
<body>
    <h2>Teste de Baixa por Valor Envolvido</h2>

<cfset obj = new cfcSNCI.pc_cfcAvaliacoes()>

<form method="post">
    <input type="submit" name="executar" value="Executar Baixa">
    <input type="submit" name="reverter" value="Reverter Baixa">
</form>

<cfif structKeyExists(form, "executar")>
    <cfset resultado = obj.teste_baixaPorValorEnvolvido()>
    <cfif isDefined("resultado") AND arrayLen(resultado) GT 0>
        <cfset session.processosModificados = resultado>
        <cfoutput>Processos modificados: #arrayToList(resultado)#</cfoutput>
    <cfelse>
        <cfoutput>Nenhum processo foi modificado.</cfoutput>
    </cfif>
</cfif>

<cfif structKeyExists(form, "reverter") AND structKeyExists(session, "processosModificados")>
    <cfset obj.reverterBaixaPorValorEnvolvido(session.processosModificados)>
    <cfset structDelete(session, "processosModificados")>
    <cfoutput>Alterações revertidas com sucesso!</cfoutput>
</cfif>

</body>
</html>
</cfoutput>


