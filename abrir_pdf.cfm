<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> --->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Sistema Nacional de Controle Interno</title>

</head>

<body>
<cftry>

<!--- <cfset arquivos = '\\sac0424\SISTEMAS\SNCI\SNCI_ANEXOS\'> --->

<!--- Listando arquivos --->
<cfdirectory action="list" directory="#diretorio_anexos#" name="ListaArquivos" filter="*.pdf">

<!--- Exibindoo arquivos --->
<table border="1">
<cfoutput query="ListaArquivos">
  <tr>
    <td>#name#</td>
	<td>
	  <form action="abrir_pdf_act.cfm" method="post">
	    <input type="hidden" name="arquivo" value="#name#" />
		<input type="submit" name="Abrir" value="Abrir" />
	  </form>
	</td>
  </tr>
</cfoutput>
</table>
<cfcatch>
   <cfdump var="#cfcatch#">
 </cfcatch>
 </cftry>

</body>
</html>
