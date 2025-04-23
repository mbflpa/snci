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


    <!--- Cria uma instância do CFC --->
<cfset obj = createObject("component", "/snci/SNCI_PROCESSOS/cfc/pc_cfcAvaliacoes")>

<!--- Chama a função de teste --->
<cfset  resultado = obj.baixaPorValorEnvolvido('1000022019')>

</body>
</html>
</cfoutput>