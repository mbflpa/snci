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
            <label for="numOrientacao">Número do Processo:</label>
            <input type="number" id="numOrientacao" name="numOrientacao" value="3881" required>

            <button type="submit">Executar Teste</button>
        </form>

        <cfif structKeyExists(form, "numOrientacao") >
           
           <cfquery datasource = "#application.dsn_processos#" name="qPosic">
                SELECT count(pc_aval_posic_num_orientacao) as qposicionamentos FROM pc_avaliacao_orientacoes o
                 INNER JOIN pc_avaliacao_posicionamentos p on p.pc_aval_posic_num_orientacao = o.pc_aval_orientacao_id
                 WHERE pc_aval_posic_status=3 and pc_aval_orientacao_status = 3 
                       and o.pc_aval_orientacao_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.numOrientacao#">  
           </cfquery> 
                <cfset quantidadePosicionamentos = qPosic.qposicionamentos>
                <cfif quantidadePosicionamentos LT 2>
                    <cfset numNotificacao = 1>
                <cfelse>
                     <cfset numNotificacao = 2>
                </cfif>
             <cfset objNotificacao = createObject("component", "pc_enviaNotificacaoDasManifestacoes")>
            <cftry>
                 <!--- Converter os valores do formulário para integer --->
                <cfset numOrientacao = Val(form.numOrientacao)>
                <cfset resultado = objNotificacao.enviaEmailNotificacaoAnalistas(
                    numOrientacao = form.numOrientacao,
                    numNotificacao = numNotificacao
                )>
                
                <div class="test-result success">
                    <h3>Teste Executado</h3>
                    <p><strong>Número do Processo:</strong> <cfoutput>#form.numOrientacao#</cfoutput></p>
                    <p><strong>Tipo de Notificação:</strong> <cfoutput>#numNotificacao#</cfoutput></p>
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
