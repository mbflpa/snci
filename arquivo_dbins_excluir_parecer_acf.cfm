<cfset arquivo = servidor_ftp & '\' & URL.nome>
<cfif FileExists(arquivo)>
  <cffile action="delete" file="#arquivo#">

<html>
<head><title>Sistema de Acompanhamento das Respostas das Inspe��es</title></head>
<body onLoad="alert('Arquivo exclu�do com Sucesso!');document.frmExclusao.submit()">
<form name="frmExclusao" method="post" action="arquivo_dbins_visualizar_parecer_acf.cfm">
</form>
</body>
</html>

<cfelse>
<html>
<head><title>Sistema de Acompanhamento das Respostas das Inspe��es</title></head>
<body onLoad="alert('O arquivo n�o foi localizado para exclus�o!');document.frmExclusao.submit()">
<form name="frmExclusao" method="post" action="arquivo_dbins_visualizar_parecer_acf.cfm">
</form>
</body>
</html>
</cfif>