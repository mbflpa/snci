<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Teste de Envio de E-mail para Analistas</title>
    <style>
        .test-container {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .test-result {
            margin: 10px 0;
            padding: 10px;
            border-radius: 4px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .test-form {
            margin-bottom: 20px;
        }
        .test-form label {
            display: block;
            margin: 10px 0 5px;
        }
        .test-form input {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
        }
        .test-form button {
            background-color: #0083ca;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .test-form button:hover {
            background-color: #006699;
        }
    </style>
</head>
<body>
    <div class="test-container">
        <h2>Teste de Envio de E-mail para Analistas</h2>
        
        <form class="test-form" method="post">
            <label for="numProcesso">Número do Processo:</label>
            <input type="text" id="numProcesso" name="numProcesso" value="0100012023" required>
            
            <label for="numNotificacao">Número da Notificação (1 ou 2):</label>
            <input type="number" id="numNotificacao" name="numNotificacao" min="1" max="2" value="1" required>
            
            <button type="submit">Executar Teste</button>
        </form>

        <cfif structKeyExists(form, "numProcesso") AND structKeyExists(form, "numNotificacao")>
            <cfset objNotificacao = createObject("component", "pc_enviaNotificacao")>
            
            <cftry>
                <cfset resultado = objNotificacao.enviaEmailNotificacaoAnalistas(
                    numProcesso = form.numProcesso,
                    numNotificacao = form.numNotificacao
                )>
                
                <div class="test-result success">
                    <h3>Teste Executado</h3>
                    <p><strong>Número do Processo:</strong> <cfoutput>#form.numProcesso#</cfoutput></p>
                    <p><strong>Tipo de Notificação:</strong> <cfoutput>#form.numNotificacao#</cfoutput></p>
                    <p><strong>Resultado:</strong> <cfoutput>#resultado#</cfoutput></p>
                </div>
                
                <cfcatch type="any">
                    <div class="test-result error">
                        <h3>Erro no Teste</h3>
                        <p><strong>Mensagem:</strong> <cfoutput>#cfcatch.message#</cfoutput></p>
                        <p><strong>Detalhe:</strong> <cfoutput>#cfcatch.detail#</cfoutput></p>
                    </div>
                </cfcatch>
            </cftry>
        </cfif>
    </div>
</body>
</html>
