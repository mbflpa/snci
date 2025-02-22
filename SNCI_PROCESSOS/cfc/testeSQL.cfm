<cfprocessingdirective pageencoding="utf-8">	
<!--- Exemplo 1: Inspeção de Segurança Alimentar --->
<cfset htmlTeste = '
<div class="relatorio">
    <p>Verificado em todos os contratos de manutenção e abastecimento, situações semelhantes relativos à não aplicação de penalidades por descumprimento contratual. Verificar a existência de cláusulas contratuais que prevejam a aplicação de penalidades por descumprimento contratual.</p>
    <h3>Itens Verificados</h3>
    <ul>
        <li>Higiene dos equipamentos</li>
        <li>Armazenamento de alimentos</li>
        <li>Temperatura das câmaras frias</li>
    </ul>
    <table border="1">
        <thead><tr><th>Item</th><th>Status</th><th>Temperatura</th><th>Observações</th></tr></thead>
        <tbody>
            <tr><td>Câmara Fria 1</td><td>Crítico</td><td>12°C</td><td>Temperatura acima do permitido (máx. 5°C)</td></tr>
            <tr><td>Freezer</td><td>OK</td><td>-18°C</td><td>Dentro dos padrões</td></tr>
            <tr><td>Geladeira</td><td>OK</td><td>4°C</td><td>Funcionamento normal</td></tr>
        </tbody>
    </table>
    <p><strong>Observações Gerais:</strong><br>Necessária manutenção urgente na Câmara Fria 1. Risco de perda de produtos.</p>
     <img src="logo.png"  style="width: 150px;">
</div>'>

<!--- Função auxiliar para formatar a tabela como lista simples --->
<cffunction name="formatarTabela" returntype="string">
    <cfargument name="tabelaHTML" type="string" required="true">
    <cfset var resultado = "">
    <cfset var linhas = reMatch("<tr>.*?</tr>", arguments.tabelaHTML)>
    <cfset var cabecalhos = []>
    <cfset var i = 0>
    
    <cfloop array="#linhas#" index="linha">
        <cfset i = i + 1>
        <cfset var colunas = reMatch("<t[dh]>.*?</t[dh]>", linha)>
        <cfset var textoLinha = "">
        
        <cfif i eq 1 && reFind("<th", linha)>
            <cfloop array="#colunas#" index="coluna">
                <cfset arrayAppend(cabecalhos, reReplace(coluna, "<[^>]*>", "", "ALL"))>
            </cfloop>
        <cfelse>
            <cfset var valores = []>
            <cfset var detalhes = []>
            <cfloop array="#colunas#" index="coluna">
                <cfset arrayAppend(valores, reReplace(coluna, "<[^>]*>", "", "ALL"))>
            </cfloop>
            <cfloop from="1" to="#arrayLen(valores)#" index="j">
                <cfif j eq 1>
                    <cfif arrayLen(cabecalhos) gte j>
                        <cfset textoLinha = "-#cabecalhos[j]#: #valores[j]#">
                    <cfelse>
                        <cfset textoLinha = "-Item #i-1#: #valores[j]#">
                    </cfif>
                <cfelse>
                    <cfif arrayLen(cabecalhos) gte j>
                        <cfset arrayAppend(detalhes, "#cabecalhos[j]#: #valores[j]#")>
                    <cfelse>
                        <cfset arrayAppend(detalhes, "Coluna #j#: #valores[j]#")>
                    </cfif>
                </cfif>
            </cfloop>
            <cfif arrayLen(detalhes) gt 0>
                <cfset textoLinha = textoLinha & " (" & arrayToList(detalhes, ", ") & ")">
            </cfif>
            <cfset resultado = resultado & textoLinha & chr(13) & chr(10)>
        </cfif>
    </cfloop>
    
    <cfreturn trim(resultado)>
</cffunction>

<cffunction name="limparHTML" returntype="string">
    <cfargument name="texto" type="string" required="true">
    <cfset var resultado = arguments.texto>
    <cfset var crlf = chr(13) & chr(10)> <!--- Constante para CRLF --->
    <cfset var quebraCabecalho = "##QUEBRACABECALHO##"> <!--- Marcador para três quebras --->
    <!--- Passo 1: Remover todas as quebras de linha do HTML original --->
    <cfset resultado = reReplace(resultado, "[\r\n]+", " ", "ALL")> <!--- Substitui quebras por espaço --->
    
    <!--- Passo 2: Tratar imagens --->
    <cfset var imagens = reMatch("<img[^>]*>", resultado)>
    <cfloop array="#imagens#" index="imgTag">
        <cfset var altText = reReplace(imgTag, ".*alt\s*=\s*['""]([^'""]*)['""].*", "\1", "ONE")>
        <cfset var substituto = len(trim(altText)) gt 0 && altText neq imgTag ? "[imagem removida: #altText#]" : "[imagem removida]">
        <cfset resultado = replace(resultado, imgTag, substituto, "ALL")>
    </cfloop>
    
    <!--- Passo 3: Tratar tabelas --->
    <cfset var tabelaMatch = reMatch("<table[^>]*>.*?</table>", resultado)>
    <cfif arrayLen(tabelaMatch) gt 0>
        <cfset var tabelaFormatada = "##QUEBRABLOCO##" & formatarTabela(tabelaMatch[1]) & "##QUEBRABLOCO##">
        <cfset resultado = replace(resultado, tabelaMatch[1], tabelaFormatada, "ALL")>
    </cfif>
    
    <!--- Passo 4: Substituir tags de bloco por quebras --->
    <cfloop from="1" to="6" index="i">
        <cfset resultado = replace(resultado, "<h#i#>", "", "ALL")>
        <cfset resultado = replace(resultado, "</h#i#>", quebraCabecalho, "ALL")> <!--- Marcador para três quebras --->
    </cfloop>
    <cfset resultado = replace(resultado, "<p>", "", "ALL")>
    <cfset resultado = replace(resultado, "</p>", "##QUEBRABLOCO##", "ALL")> <!--- Marcador para duas quebras --->
    <cfset resultado = replace(resultado, "<br>", crlf, "ALL")>
    <cfset resultado = replace(resultado, "<br/>", crlf, "ALL")>
    <cfset resultado = replace(resultado, "<ul>", crlf, "ALL")> <!--- Uma quebra antes da lista --->
    <cfset resultado = replace(resultado, "</ul>", crlf, "ALL")> <!--- Uma quebra após lista --->
    <cfset resultado = replace(resultado, "<li>", "• ", "ALL")>
    <cfset resultado = replace(resultado, "</li>", crlf, "ALL")> <!--- Uma quebra após itens da lista --->
    
    <!--- Passo 5: Remover tags restantes --->
    <cfset resultado = reReplace(resultado, "<[^>]*>", "", "ALL")>
    
    <!--- Passo 6: Normalizar espaços --->
    <cfset resultado = reReplace(resultado, "\s+", " ", "ALL")> <!--- Colapsa espaços múltiplos --->
    <cfset resultado = trim(resultado)> <!--- Remove espaços no início e fim --->
    
    <!--- Passo 7: Reaplicar quebras --->
    <cfset resultado = replace(resultado, "##QUEBRABLOCO##", crlf & crlf, "ALL")> <!--- Substitui marcador por duas quebras --->
    <cfset resultado = replace(resultado, quebraCabecalho, crlf , "ALL")> <!--- Três quebras para <h#i#> --->
    <cfset resultado = reReplace(resultado, "• ", crlf & "• ", "ALL")> <!--- Uma quebra antes de cada item da lista --->
    <cfset resultado = reReplace(resultado, "-Item:", crlf & "-Item:", "ALL")> <!--- Uma quebra antes de cada item da tabela --->
    
    <!--- Passo 8: Limpar quebras excessivas --->
    <cfset resultado = reReplace(resultado, "(#crlf#){3,}", crlf & crlf, "ALL")> <!--- Limita a 2 quebras, exceto após <h#i#> --->
    <cfset resultado = reReplace(resultado, "^#crlf#+", "", "ALL")> <!--- Remove quebras no início --->
    <cfset resultado = reReplace(resultado, "#crlf#+$", "", "ALL")> <!--- Remove quebras no fim --->
    
    <cfreturn resultado>
</cffunction>

<!--- Testar a saída na tela --->
<cfset textoProcessado = limparHTML(htmlTeste)>
<cfoutput><pre>#textoProcessado#</pre></cfoutput>
<!--- <cfabort> ---> <!--- Comentei o abort para permitir a geração do Excel --->
 
<!--- Criar planilha --->
<cfset spreadsheetObj = spreadsheetNew("Sheet1", true)>
<cfset spreadsheetSetCellValue(spreadsheetObj, textoProcessado, 1, 1)>
<cfset spreadsheetFormatCell(spreadsheetObj, {textwrap=true}, 1, 1)>
<cfset arquivo = expandPath('relatorio.xlsx')>
<cfspreadsheet action="write" filename="#arquivo#" name="spreadsheetObj" overwrite="true">

<!--- Download --->
<cfheader name="Content-Disposition" value="attachment; filename=relatorio.xlsx">
<cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#arquivo#" reset="true">