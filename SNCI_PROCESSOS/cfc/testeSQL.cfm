<cfprocessingdirective pageencoding = "utf-8">	
<cffunction name="stripHtml" returntype="string" access="public" output="false" hint="Converte HTML em texto plano formatado para Excel">
    <cfargument name="htmlContent" type="string" required="true" hint="Conteúdo HTML a ser convertido">
    
    <!--- Tratar conteúdo nulo ou vazio --->
    <cfif not len(trim(arguments.htmlContent))>
        <cfreturn "">
    </cfif>

    <!--- Usar variável local para manipulação --->
    <cfset var text = arguments.htmlContent>
    
    <!--- Tratar listas com quebras de linha do Excel --->
    <cfset text = rereplace(text, "<ul[^>]*>", chr(13) & chr(10), "all")>
    <cfset text = rereplace(text, "</ul>", chr(13) & chr(10), "all")>
    <cfset text = rereplace(text, "<li[^>]*>", "* ", "all")>
    <cfset text = rereplace(text, "</li>", chr(13) & chr(10), "all")>
    
    <!--- Tratar cabeçalhos --->
    <cfset text = rereplace(text, "<h[1-6][^>]*>", chr(13) & chr(10), "all")>
    <cfset text = rereplace(text, "</h[1-6]>", chr(13) & chr(10), "all")>
    
    <!--- Melhorar tratamento de tabelas para Excel --->
    <cfset text = rereplace(text, "<thead[^>]*>|</thead>|<tbody[^>]*>|</tbody>", "", "all")>
    <cfset text = rereplace(text, "<tr[^>]*>", "", "all")>
    <cfset text = rereplace(text, "</tr>", chr(13) & chr(10), "all")>
    <cfset text = rereplace(text, "<th[^>]*>", "", "all")>
    <cfset text = rereplace(text, "</th>", chr(9), "all")>
    <cfset text = rereplace(text, "<td[^>]*>", "", "all")>
    <cfset text = rereplace(text, "</td>", chr(9), "all")>
    
    <!--- Tratar quebras de linha e parágrafos --->
    <cfset text = rereplace(text, "<br\s*/?>", chr(13) & chr(10), "all")>
    <cfset text = rereplace(text, "<p[^>]*>", "", "all")>
    <cfset text = rereplace(text, "</p>", chr(13) & chr(10), "all")>
    
    <!--- Remover todas as outras tags HTML --->
    <cfset text = rereplace(text, "<[^>]+>", "", "all")>

    <!--- Tratar entidades HTML comuns --->
    <cfset text = replace(text, "&nbsp;", " ", "all")>
    <cfset text = replace(text, "&lt;", "<", "all")>
    <cfset text = replace(text, "&gt;", ">", "all")>
    <cfset text = replace(text, "&amp;", "&", "all")>
    <cfset text = replace(text, "&quot;", """", "all")>
    <cfset text = replace(text, "&apos;", "'", "all")>
    <cfset text = replace(text, "&ccedil;", "ç", "all")>
    
    <!--- Remover múltiplas quebras de linha e espaços --->
    <cfset text = rereplace(text, "(\r?\n){3,}", chr(13) & chr(10) & chr(13) & chr(10), "all")>
    <cfset text = rereplace(text, "\s{2,}", " ", "all")>
    
    <cfreturn trim(text)>
</cffunction>

<cfset htmlTeste = '
<div class="relatorio">
    <h1>Relatório de Inspeção</h1>
    <p>Data: 21/02/2025</p>
    <h2>Detalhes da Inspeção</h2>
    <p>Inspeção realizada com sucesso.<br>Local: Setor Industrial<br>Responsável: João Silva</p>
    <h3>Lista de Verificação</h3>
    <ul>
        <li>Equipamentos de proteção</li>
        <li>Sinalização de segurança</li>
        <li>Condições do ambiente</li>
    </ul>
    <table border="1">
        <thead><tr><th>Item Verificado</th><th>Status</th><th>Observações</th></tr></thead>
        <tbody>
            <tr><td>Extintores</td><td>OK</td><td>Dentro do prazo de validade</td></tr>
            <tr><td>Iluminação</td><td>Pendente</td><td>Necessita troca de lâmpadas</td></tr>
            <tr><td>Saídas de emergência</td><td>OK</td><td>Desobstruídas</td></tr>
        </tbody>
    </table>
    <p><strong>Observações Gerais:</strong><br>Necessário agendar manutenção preventiva para o próximo mês.</p>
</div>'>



<!--- Função auxiliar para formatar a tabela como lista simples --->
<cffunction name="formatarTabela" returntype="string">
    <cfargument name="tabelaHTML" type="string" required="true">
    <cfset var resultado = "">
    <cfset var linhas = reMatch("<tr>.*?</tr>", arguments.tabelaHTML)>
    <cfset var cabecalhos = []>
    <cfset var i = 0>
    
    <!--- Processar cada linha da tabela --->
    <cfloop array="#linhas#" index="linha">
        <cfset i = i + 1>
        <cfset var colunas = reMatch("<t[dh]>.*?</t[dh]>", linha)>
        <cfset var textoLinha = "">
        
        <!--- Primeira linha é o cabeçalho --->
        <cfif i eq 1>
            <cfloop array="#colunas#" index="coluna">
                <cfset arrayAppend(cabecalhos, reReplace(coluna, "<[^>]*>", "", "ALL"))>
            </cfloop>
        <cfelse>
            <!--- Linhas de dados --->
            <cfset var valores = []>
            <cfset var detalhes = []>
            <cfloop array="#colunas#" index="coluna">
                <cfset arrayAppend(valores, reReplace(coluna, "<[^>]*>", "", "ALL"))>
            </cfloop>
            <!--- Construir o texto da linha --->
            <cfloop from="1" to="#arrayLen(valores)#" index="j">
                <cfif j eq 1>
                    <cfset textoLinha = "- #cabecalhos[j]#: #valores[j]#">
                <cfelse>
                    <cfset arrayAppend(detalhes, "#cabecalhos[j]#: #valores[j]#")>
                </cfif>
            </cfloop>
            <cfif arrayLen(detalhes) gt 0>
                <cfset textoLinha = textoLinha & " (" & arrayToList(detalhes, ", ") & ")">
            </cfif>
            <cfset resultado = resultado & textoLinha & chr(13) & chr(10)>
        </cfif>
    </cfloop>
    
    <cfreturn resultado>
</cffunction>

<!--- Função principal para limpar o HTML --->
<cffunction name="limparHTML" returntype="string">
    <cfargument name="texto" type="string" required="true">
    <cfset var resultado = arguments.texto>
    
    <!--- Separar e processar a tabela --->
    <cfset var tabelaMatch = reMatch("<table[^>]*>.*?</table>", resultado)>
    <cfif arrayLen(tabelaMatch) gt 0>
        <cfset var tabelaFormatada = formatarTabela(tabelaMatch[1])>
        <cfset resultado = replace(resultado, tabelaMatch[1], tabelaFormatada, "ALL")>
    </cfif>
    
    <!--- Substituir quebras de linha HTML por CRLF --->
    <cfset resultado = replace(resultado, "<br>", chr(13) & chr(10), "ALL")>
    <cfset resultado = replace(resultado, "<br/>", chr(13) & chr(10), "ALL")>
    <!--- Tratar parágrafos como quebras duplas --->
    <cfset resultado = reReplace(resultado, "</p>\s*<p>", chr(13) & chr(10) & chr(13) & chr(10), "ALL")>
    <cfset resultado = reReplace(resultado, "<p[^>]*>", "", "ALL")>
    <cfset resultado = replace(resultado, "</p>", "", "ALL")>
    <!--- Converter listas em texto com marcadores, uma linha por item --->
    <cfset resultado = reReplace(resultado, "<li[^>]*>", "• ", "ALL")>
    <cfset resultado = replace(resultado, "</li>", chr(13) & chr(10), "ALL")>
    <cfset resultado = reReplace(resultado, "</?ul[^>]*>", "", "ALL")>
    <cfset resultado = reReplace(resultado, "</?ol[^>]*>", "", "ALL")>
    <!--- Remover strong sem adicionar [NEGRITO] --->
    <cfset resultado = replace(resultado, "<strong>", "", "ALL")>
    <cfset resultado = replace(resultado, "</strong>", "", "ALL")>
    <!--- Remover outras tags --->
    <cfset resultado = reReplace(resultado, "<[^>]*>", "", "ALL")>
    <!--- Preservar espaçamento básico --->
    <cfset resultado = trim(resultado)>
    <cfreturn resultado>
</cffunction>

<!--- Processar o HTML --->
<cfset textoProcessado = limparHTML(htmlTeste)>

<!--- Criar uma query com uma única célula --->
<cfset excelQuery = queryNew("Conteudo", "varchar")>
<cfset queryAddRow(excelQuery)>
<cfset querySetCell(excelQuery, "Conteudo", textoProcessado)>

<!--- Exportar para Excel --->
<cfspreadsheet action="write" filename="#expandPath('relatorio.xlsx')#" query="excelQuery" overwrite="true">

<!--- Fazer o download --->
<cfheader name="Content-Disposition" value="attachment; filename=relatorio.xlsx">
<cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#expandPath('relatorio.xlsx')#">

<cfoutput>#htmlTeste#</cfoutput>