<cfif isDefined("form.sacao") and form.sacao neq ''>
	<cfquery datasource="#dsn_inspecao#">
 	 UPDATE Usuarios 
	 SET Usu_GrupoAcesso = '#form.sacao#', Usu_DR = '#form.se#'
	 WHERE Usu_Matricula = '#form.matricula#'
	</cfquery> 
<!--- 	<cfoutput>
UPDATE Usuarios 
	 SET Usu_GrupoAcesso = '#form.sacao#', Usu_DR = '#form.se#'
	 WHERE Usu_Matricula = '#form.matricula#'	
	</cfoutput> --->
</cfif>


<cfquery name="qAcesso" datasource="#dsn_inspecao#">
SELECT Usu_GrupoAcesso, Usu_DR, Usu_Matricula 
FROM Usuarios 
WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset habgestormaster =''>
<cfset habgestores =''>
<cfif trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
  <cfset habgestores ='disabled'>
</cfif>
<cfif trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORMASTER'>
<cfset habgestormaster ='disabled'>
</cfif>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<link href="css.css" rel="stylesheet" type="text/css">
</head>

<body>
<cfoutput>
<form name="form1" method="post" action="MudarGrupoAcesso_testes.cfm">
<table width="38%" border="0">
  <tr class="titulos">
    <th colspan="3" scope="row">Trocar Grupo de Acesso </th>
  </tr>
  <tr>
    <th colspan="3" class="exibir" scope="row">&nbsp;</th>
    </tr>
  <tr>
    <th width="45%" class="exibir" scope="row"><div align="left"><strong>Grupo de acesso Atual: </strong></div></th>
    <td colspan="2" class="exibir"><strong>#qAcesso.Usu_GrupoAcesso#</strong></td>
    </tr>
  <tr>
    <th scope="row">&nbsp;</th>
    <td colspan="2">&nbsp;</td>
    </tr>
  <tr>
    <th class="exibir" scope="row"><div align="left"><strong>Trocar para o Grupo de Acesso: </strong></div></th>
    <td width="23%"><button name="submitAlt" type="submit" class="botao" onClick="document.form1.sacao.value='GESTORES';document.form1.se.value='32'" #habgestores#>
						  <div align="center">GESTORES</div>
	  </button></td>
    <td width="32%"><button name="submitAlt" type="submit" class="botao" onClick="document.form1.sacao.value='GESTORMASTER';document.form1.se.value='01'" #habgestormaster#>
						  <div align="center">GESTORMASTER</div>
						</button></td>
  </tr>
  <tr>
    <th scope="row">&nbsp;</th>
    <td colspan="2">&nbsp;</td>
    </tr>
</table>
<input name="sacao" type="hidden" id="sacao">
<input name="se" type="hidden" id="se">
<input name="matricula" type="hidden" id="matricula" value="#qAcesso.Usu_Matricula#">
</form>
</cfoutput>
</body>
</html>
