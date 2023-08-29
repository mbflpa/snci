 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Sistema Nacional de Controle Interno</title>

</head>

<body>

<cftry>

<cfif isDefined("url.arquivo")>
<!--- <cfoutput>#url.arquivo#</cfoutput> --->
<!---  <cfset vArquivo = '\\sac0424\SISTEMAS\SNCI\#diretorio_anexos#\' & url.arquivo> --->
<cfset vArquivo = url.arquivo> 

<cffile file="#vArquivo#" action="readbinary" variable="estat">
<cfcontent variable="#estat#" type="application/pdf" reset="yes">
</cfif>

<cfcatch>
   <cfdump var="#cfcatch#">
 </cfcatch>
 </cftry>

</body>
</html>
