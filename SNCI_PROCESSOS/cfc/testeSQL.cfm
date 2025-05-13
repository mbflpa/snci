<cfprocessingdirective pageencoding="utf-8">	
<cfprocessingdirective pageencoding="utf-8">	

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Download de Anexos de Avaliação</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            color: #00416b;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #00416b;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .btn-download {
            background-color: #4CAF50;
            color: white;
            padding: 5px 10px;
            text-decoration: none;
            border-radius: 4px;
            display: inline-block;
        }
        .status {
            margin-top: 20px;
            padding: 10px;
            border: 1px solid #ddd;
            background-color: #f9f9f9;
        }
    </style>
</head>

<body>
    <h1>Download de Anexos de Avaliação</h1>
    
    <cftry>
        <!--- Consulta para buscar anexos com pc_anexo_avaliacaoPDF = 'S' --->
        <cfquery name="rsAnexosAvaliacao" datasource="#application.dsn_processos#">
            SELECT 
                pc_anexo_id,
                pc_anexo_nome,
                pc_anexo_caminho
            FROM 
                pc_anexos
            WHERE 
                pc_anexo_avaliacaoPDF = 'S'
         
        </cfquery>
        
        <!--- Diretório para salvar os arquivos baixados --->
        <cfset diretorioDownload = ExpandPath("./downloads")>
        
        <!--- Criar o diretório se não existir --->
        <cfif NOT DirectoryExists(diretorioDownload)>
            <cfdirectory action="create" directory="#diretorioDownload#">
        </cfif>
        
        <!--- Exibir tabela com os anexos encontrados --->
        <cfoutput>
            <p>Total de anexos encontrados: <strong>#rsAnexosAvaliacao.recordCount#</strong></p>
            
            <cfif rsAnexosAvaliacao.recordCount GT 0>
                <table>
                    <tr>
                        <th>ID</th>
                        <th>Nome do Arquivo</th>
                        <th>Caminho</th>
                    </tr>
                    
                    <cfloop query="rsAnexosAvaliacao">
                        <tr>
                            <td>#pc_anexo_id#</td>
                            <td>#pc_anexo_nome#</td>
                            <td>#pc_anexo_caminho#</td>
                            <td>
                                <a href="../pc_Anexos.cfm?arquivo=#URLEncodedFormat(pc_anexo_caminho)#&nome=#URLEncodedFormat(pc_anexo_nome)#" 
                                   class="btn-download" target="_blank">
                                   Visualizar/Baixar
                                </a>
                            </td>
                            <td>
                                <cfset caminhoCompleto = "">
                                <cfif ucase(left(trim(pc_anexo_caminho),24)) is "\\SAC0424\SISTEMAS\SNCI\">
                                    <cfset caminhoCompleto = pc_anexo_caminho>
                                <cfelse>
                                    <cfset caminhoCompleto = application.diretorio_anexos & pc_anexo_caminho>
                                </cfif>
                                
                                <cfif FileExists(caminhoCompleto)>
                                    <span style="color: green;">Arquivo existe</span>
                                <cfelse>
                                    <span style="color: red;">Arquivo não encontrado</span>
                                </cfif>
                            </td>
                        </tr>
                    </cfloop>
                </table>
                
                <!--- Botão para baixar todos os arquivos --->
                <div style="margin-top: 20px;">
                    <form method="post">
                        <input type="submit" name="downloadTodos" value="Baixar Todos os Arquivos" style="padding: 10px; background-color: ##00416b; color: white; border: none; cursor: pointer;">
                    </form>
                </div>
                
                <!--- Processar o download de todos os arquivos --->
                <cfif StructKeyExists(form, "downloadTodos")>
                    <div class="status">
                        <h3>Status do Download:</h3>
                        <cfset totalSucesso = 0>
                        <cfset totalFalha = 0>
                        
                        <cfloop query="rsAnexosAvaliacao">
                            <cfset caminhoCompleto = "">
                            <cfif ucase(left(trim(pc_anexo_caminho),24)) is "\\SAC0424\SISTEMAS\SNCI\">
                                <cfset caminhoCompleto = pc_anexo_caminho>
                            <cfelse>
                                <cfset caminhoCompleto = application.diretorio_anexos & pc_anexo_caminho>
                            </cfif>
                            
                            <cfset nomeArquivoDestino = pc_anexo_nome>
                            <cfset caminhoDestino = diretorioDownload & "\" & nomeArquivoDestino>
                            
                            <cfif FileExists(caminhoCompleto)>
                                <cftry>
                                    <cffile action="copy" source="#caminhoCompleto#" destination="#caminhoDestino#" nameconflict="overwrite">
                                    <p style="color: green;">✓ Arquivo "#pc_anexo_nome#" baixado com sucesso para "#caminhoDestino#"</p>
                                    <cfset totalSucesso = totalSucesso + 1>
                                    <cfcatch>
                                        <p style="color: red;">✗ Erro ao baixar "#pc_anexo_nome#": #cfcatch.message#</p>
                                        <cfset totalFalha = totalFalha + 1>
                                    </cfcatch>
                                </cftry>
                            <cfelse>
                                <p style="color: red;">✗ Arquivo "#pc_anexo_nome#" não encontrado no caminho "#caminhoCompleto#"</p>
                                <cfset totalFalha = totalFalha + 1>
                            </cfif>
                        </cfloop>
                        
                        <h4>Resumo:</h4>
                        <p>Total de arquivos: #rsAnexosAvaliacao.recordCount#</p>
                        <p style="color: green;">Arquivos baixados com sucesso: #totalSucesso#</p>
                        <p style="color: red;">Arquivos com falha: #totalFalha#</p>
                        <p>Diretório de download: #diretorioDownload#</p>
                    </div>
                </cfif>
            <cfelse>
                <p>Nenhum anexo encontrado com pc_anexo_avaliacaoPDF = 'S'.</p>
            </cfif>
        </cfoutput>
        
        <cfcatch>
            <h2>Erro ao processar a solicitação:</h2>
            <cfdump var="#cfcatch#">
        </cfcatch>
    </cftry>
</body>
</html>
