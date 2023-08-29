<cfprocessingdirective pageEncoding ="utf-8"/>
<!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
<!---  <cfdump var="#url#">  --->

<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>    --->
	
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email 
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>

 <cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
<!--- <cfif (grpacesso neq 'GESTORES') and (grpacesso neq 'DESENVOLVEDORES') and (grpacesso neq 'GESTORMASTER')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>   
</cfif>     --->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>SNCI</title>
</head>

<body>
<cfinclude template="cabecalho.cfm">

<br />
<br />
<table width="590" border="1">
  <tr>
    <td colspan="3">Link: <a href="https://app.powerbi.com/reportEmbed?reportId=2c84bd6e-8587-4c00-a8a0-f3f36cc75d75&amp;autoAuth=true&amp;ctid=349047e4-8aa4-4867-b4f7-bc3cb08bbb60&amp;config=eyJjbHVzdGVyVXJsIjoiaHR0cHM6Ly93YWJpLW5vcnRoLWV1cm9wZS1oLXByaW1hcnktcmVkaXJlY3QuYW5hbHlzaXMud2luZG93cy5uZXQvIn0%3D" target="_blank" rel="noopener noreferrer" data-auth="NotApplicable" data-linkindex="2">Monitoramento 2022</a></td>
  </tr>
  <tr>
    <td colspan="3"><div align="center">Passos para a conex&atilde;o </div></td>
  </tr>
  
  <tr>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td width="16">1-</td>
    <td width="107"><div align="center">Clicar no bot&atilde;o Sign-In </div></td>
    <td width="330"><img src="Figuras/powerbi01.jpg" width="317" height="149" /></td>
  </tr>
  <tr>
    <td height="268">2-</td>
    <td><div align="center">Conta de Acesso </div></td>
    <td><img src="Figuras/powerbi02.jpg" width="327" height="149" /></td>
  </tr>
</table>
</body>
</html>
