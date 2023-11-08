<!--- Windows Example  --->
<!--- Check to see if the Form variable exists. ---> 

<cfif isDefined("Form.envio") > 
   <cfoutput>
   Nome do arquivo de upload: #form.arquivo# <br>
   Caminho destinado: #form.dir#
   </cfoutput>
<!--- If TRUE, upload the file.  --->

	<cffile action = "upload" 
	fileField = "form.arquivo" 
	<!--- destination = "\\sac3162\PERNAMBUCO\SNCI\Dados\"  --->
	destination = "#form.dir#"
	accept = "text/html,application/pdf" 
	nameConflict = "MakeUnique"> 
	
</cfif> 
<!--- If FALSE, show the Form. ---> 
<!doctype html>
<html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <title>Envio de arquivo coldfusion desenvolvimento</title>
		<style>
            html, body, h1, h2, h3, h4, p {
                margin:0;
                padding:0;
            }

            html {
                background:rgb(255,255,255);
            }

            article, aside, section, header, footer, nav {
                display:block;
            }

            main {
                width:960px;
                background-color:rgb(255,255,255);
                font-family:Arial, Helvetica, sans-serif;
                font-size:14px;
                box-shadow: 0 0 10px #666;
                margin:10px auto;
                padding:10px;
            }

            header {
                padding:25px;
                background-color:rgb(255,102,51);
                text-align:center;
                margin-bottom:20px;
            }

            header h1 {
                font-size:1.3em;
                color:rgb(255,255,255);
            }

            .janela1 {
                background-color:rgb(153,204,51);
                height:500px;
            }

            .janela2 {
                background-color:rgb(255,204,51);
                height:500px;
            }

            select, input {
                padding:5px;
                background-color:rgb(204,153,51);
                text-align:center;
				font-size:1.3em;
                color:rgb(255,255,255);
            }
        </style>
    </head>

    <body>
	<main>
<br>
	<div>
		<form method="post" action="Gilvan_teste.cfm" name="form1" enctype="multipart/form-data"> 
		<label for="Tipo"><h4>Escolher formato (PDF)</h4></label><br>
		<input name="arquivo" type="file" accept = "application/pdf"> 
		<br>
		<br> 
		<label for="Local"><h4>(Local de Destino pasta SNCI_TESTE NO SAC0424)</h4></label><br>
		<select id="dir" name="dir"> 
			<option value="\\sac0424\SISTEMAS$\SNCI\SNCI_TESTE\">"Com simbolo $ \\sac0424\SISTEMAS$\SNCI\SNCI_TESTE\"</option>
			<option value="\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\">"Sem simbolo $ \\sac0424\SISTEMAS\SNCI\SNCI_TESTE\"</option>
        </select>
		<br><br><br><br>
		<input name="envio" type="submit" value="Salvar Arquivo - Clique Aqui"> 
	</div>
	</main>
</form> 
</body>
</html>


<!--- 
<cfoutput>
<!--- Obter o a data util para 10(dez) dias --->
<cfset dtdezdiasuteis = CreateDate(2023,11,10)>
<cfset nCont = 0>
data inicial: #dtdezdiasuteis#  contador: #ncont#<br>
<cfloop condition="nCont lt 32">
	<cfset nCont = nCont + 1>
	<cfset dtdezdiasuteis = DateAdd( "d", 1, dtdezdiasuteis)>
	<cfset vDiaSem = DayOfWeek(dtdezdiasuteis)>
	<cfif vDiaSem neq 1 and vDiaSem neq 7>
		<!--- verificar se Feriado Nacional --->
		<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtdezdiasuteis#
		</cfquery>
		<cfif rsFeriado.recordcount gt 0>
			<cfset nCont = nCont - 1>
			feriado nacional : #dtdezdiasuteis#   contador: #ncont# <br>
		<cfelse>
		    dia valido ====================================================: #dtdezdiasuteis#   contador: #ncont# <br>
		</cfif>
	</cfif>
	<!--- Verifica se final de semana  --->
	<cfif vDiaSem eq 1 or vDiaSem eq 7>
		<cfset nCont = nCont - 1>
		final de semana: #dtdezdiasuteis#   contador: #ncont#<br>
	</cfif>	
</cfloop>


dtdezdiasuteis: #dtdezdiasuteis#
</cfoutput>
--->