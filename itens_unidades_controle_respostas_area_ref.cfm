<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<cfquery name="rsPermissaoArea" datasource="#dsn_inspecao#">
	SELECT Usu_Login, Usu_Lotacao, Usu_GrupoAcesso
	FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and Usu_GrupoAcesso = 'GERENTES'
	ORDER BY Usu_Lotacao ASC
</cfquery>


<script language="javascript">
//Validação de campos vazios em formulário
function valida_form(form) {
 var frm = document.forms[form];
 var quant = frm.elements.length;
 for (var i=0; i<quant; i++) {
   var elemento = document.forms[form].elements[i];
   if (elemento.getAttribute('vazio') == 'false') {
	 if (elemento.value == '') {
	   var nome = elemento.getAttribute('nome');
	   alert('Informe o campo ' + nome + '!');
	   elemento.focus();
	   return false;
	   break;
	 }
   }
 }
}
</script>

<cfquery name="rsArea" datasource="#dsn_inspecao#">
SELECT DISTINCT Ars_Codigo, Ars_Sigla
FROM Areas
WHERE Ars_Status = 'A'
ORDER BY Ars_Sigla ASC
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body onLoad="document.frmObjeto.dtinic.focus();">

<cfinclude template="cabecalho.cfm">
<table width="800" height="450">
<tr>
<td valign="top" width="13%" class="link1">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr align="left" valign="top">
        <td width="95%" height="4" background="../../menu/fundo.gif">

        </td>
      </tr>
</table>
      <table width="93%" border="0" cellpadding="0" cellspacing="0">
        <tr align="left" valign="top">
          <td width="5%" height="10">&nbsp;</td>
          <td width="95%" height="4">&nbsp;</td>
        </tr>
      </table>
    </td>
	  <td width="87%" valign="top">
<!--- Área de conteúdo--->
<form action="Itens_unidades_controle_respostas_area.cfm" method="Post" name="frmObjeto">
      <table width="557">
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3"><p align="center" class="titulo1">Pontos  de Auditoria por &Aacute;rea </p>
            <p class="exibir"></td>
      </tr>
      <tr>
        <td width="56" height="31">&nbsp;</td>
        <td width="122"><span class="exibir"><strong>Ger&ecirc;ncia:</strong></span></td>
        <td width="363">
		<select name="area" class="form">
            <cfoutput query="rsArea">
			<cfif Trim(UCASE(Ars_Codigo)) is Trim(UCASE(rsPermissaoArea.Usu_Lotacao))>
            <option value="#Ars_Codigo#">#Ars_Sigla#</option>
			</cfif>
            </cfoutput>
        </select></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="30">&nbsp;</td>
      <td>&nbsp;
      </td>
      <td><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr>
      </table>
</form>

<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>

<script>
	document.forms[0].submit();
</script>
