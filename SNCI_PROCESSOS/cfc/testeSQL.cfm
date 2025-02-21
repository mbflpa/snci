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

<!--- Exemplo de uso com HTML complexo --->
<cfset htmlTeste = '
<div class="relatorio">
    <h1>Relatório de Inspeção</h1>
    <p>Data: 21/02/2025</p>
    
    <h2>Detalhes da Inspeção</h2>
    <p>Inspeção realizada com sucesso.<br>
    Local: Setor Industrial<br>
    Responsável: João Silva</p>
    
    <h3>Lista de Verificação</h3>
    <ul>
        <li>Equipamentos de proteção</li>
        <li>Sinalização de segurança</li>
        <li>Condições do ambiente</li>
    </ul>
    
    <table border="1">
        <thead>
            <tr>
                <th>Item Verificado</th>
                <th>Status</th>
                <th>Observações</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Extintores</td>
                <td>OK</td>
                <td>Dentro do prazo de validade</td>
            </tr>
            <tr>
                <td>Iluminação</td>
                <td>Pendente</td>
                <td>Necessita troca de lâmpadas</td>
            </tr>
            <tr>
                <td>Saídas de emergência</td>
                <td>OK</td>
                <td>Desobstruídas</td>
            </tr>
        </tbody>
    </table>
    
    <p><strong>Observações Gerais:</strong><br>
    Necessário agendar manutenção preventiva para o próximo mês.</p>
</div>'>

<!--- Teste com visualização na página --->
<cfset textoFinal = stripHtml(htmlTeste)>
<cfoutput>
    <h2>HTML Original:</h2>
    #htmlTeste#
    <hr>
    <h2>Texto Convertido:</h2>
    <pre>#textoFinal#</pre>
</cfoutput>

<!--- Teste com download direto para Excel --->

<!--- Modificar a parte do download para Excel --->
<cfheader name="Content-Type" value="application/vnd.ms-excel; charset=utf-8">
<cfheader name="Content-Disposition" value="attachment; filename=relatorio.xls">
<cfprocessingdirective pageencoding="utf-8">
<cfcontent type="application/vnd.ms-excel" reset="true"><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
 <Worksheet ss:Name="Relatorio">
  <Table>
   <Row>
    <Cell><Data ss:Type="String">#textoFinal#</Data></Cell>
   </Row>
  </Table>
 </Worksheet>
</Workbook></cfoutput>
