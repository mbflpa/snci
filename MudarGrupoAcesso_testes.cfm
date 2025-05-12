<cfprocessingdirective pageEncoding ="utf-8"/>  
<cfif isDefined("form.sacao") and form.sacao neq ''>
	<cfquery datasource="#dsn_inspecao#">
 	 UPDATE Usuarios 
	 SET Usu_GrupoAcesso = '#form.sacao#'
	 WHERE Usu_Matricula = '#form.matricula#'
	</cfquery> 
<!--- 	<cfoutput>
UPDATE Usuarios 
	 SET Usu_GrupoAcesso = '#form.sacao#', Usu_DR = '#form.se#'
	 WHERE Usu_Matricula = '#form.matricula#'	
	</cfoutput> --->
</cfif>
<cfquery name="rsGpacesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso
  FROM Usuarios
  GROUP BY Usu_GrupoAcesso
</cfquery>

<cfquery name="rsSE" datasource="#dsn_inspecao#">
  SELECT Dir_Codigo, Dir_Sigla
  FROM Diretoria 
  where Dir_Codigo <> '01'
</cfquery>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso, Usu_DR, Usu_Matricula 
  FROM Usuarios 
  WHERE Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset habgestormaster =''>
<cfset habgestores =''>
<cfset habinspetores =''>
<cfif trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
  <cfset habgestores ='disabled'>
</cfif>
<cfif trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORMASTER'>
<cfset habgestormaster ='disabled'>
</cfif>
<cfif trim(qAcesso.Usu_GrupoAcesso) eq 'INSPETORES'>
  <cfset habinspetores ='disabled'>
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
    <td width="23%"><button name="submitAlt" type="submit" class="botao" onClick="document.form1.sacao.value='GESTORES';" #habgestores#>
						  <div align="center">GESTORES</div>
	  </button>
    </td>
    <td width="32%"><button name="submitAlt" type="submit" class="botao" onClick="document.form1.sacao.value='GESTORMASTER';" #habgestormaster#>
						  <div align="center">GESTORMASTER</div>
						</button>
    </td>
    <td width="32%"><button name="submitAlt" type="submit" class="botao" onClick="document.form1.sacao.value='INSPETORES';" #habinspetores#>
      <div align="center">INSPETORES</div>
    </button>
</td>
  </tr>
  <tr>
    <th scope="row">&nbsp;</th>
    <td colspan="2">&nbsp;</td>
    </tr>
    <tr valign="baseline">
      <td colspan="3"><span class="titulos">Grupo de Acesso:</span></td>
  </tr>
  <tr valign="baseline"> 
      <td colspan="3">
        <select name="grupoacesso" id="grupoacesso" class="form">
          <cfloop query="rsGpacesso"> 
              <option value="#UCase(rsGpacesso.Usu_GrupoAcesso)#" <cfif rsGpacesso.Usu_GrupoAcesso eq qAcesso.Usu_GrupoAcesso>selected</cfif>>#UCase(rsGpacesso.Usu_GrupoAcesso)#</option>
          </cfloop>
        </select>
      </td>
  </tr>
  <tr valign="baseline">
    <td colspan="3"><span class="titulos">Superintendência:</span></td>
</tr>
 <tr valign="baseline">
   <td colspan="3">
    <select name="se" id="se" class="form">
      <option selected="selected" value="---">---</option>
      <cfloop query="rsSE">
            <option value="#rsSE.Dir_Codigo#" <cfif rsSE.Dir_Codigo eq qAcesso.Usu_DR>selected</cfif>>#Ucase(trim(rsSE.Dir_Sigla))#</option>
      </cfloop>
    </select>
  </td>
 </tr>
 <tr valign="baseline">
  <td colspan="6"><span class="titulos">Matr&iacute;cula/CPF:</span></td>
</tr>
<tr valign="baseline">
  <td colspan="6"><input type="text" name="matr_usu" id="matr_usu" class="form" maxlength="14" onBlur="validacao('matr_usu')" onKeyPress="if(dominio.value == 'CORREIOSNET'){Mascara_Matricula(this)}else if (dominio.value == 'EXTRANET'){Mascara_cpf(this)} else {dominio.focus()}; numericos()">
</tr>
 <tr valign="baseline">
       <td colspan="3">&nbsp;</td>
   </tr>  
  <tr valign="baseline" align="center">
      <td><button type="button" class="botao" onClick="trocar(dr.value,area_usu.value);">Confirmar Permuta</button></td>
  </tr>
</table>
<input name="sacao" type="hidden" id="sacao">
<input name="se" type="hidden" id="se">
<input name="matricula" type="hidden" id="matricula" value="#qAcesso.Usu_Matricula#">
</form>
</cfoutput>
</body>
</html>
