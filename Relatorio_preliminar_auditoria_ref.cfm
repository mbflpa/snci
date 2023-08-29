<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<cfinclude template="valida.cfm">

<br><br><br>
<table width="500" height="450">
<tr>
	  <td  valign="top" align="center">
<!--- Área de conteúdo   --->
	<form action="GeraRelatorio/gerador/dsp/relatorio_preliminar.cfm" method="Post" name="frmHtml" target="_blank">
      <table  align="center">
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3"><p align="center" class="titulo1">Relat&Oacute;rio Preliminar </p>
            </td>
      </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
	  <tr>
        <td width="56">&nbsp;</td>
        <td width="151"><div align="center"><span class="exibir"><strong>N&ordm; Auditoria: </strong></span></div></td>
        <td width="194"><input name="id" type="text" tabindex="2" size="12" maxlength="10" vazio="false" nome="Nº Inspeção" onKeyPress="sohNumeros();" class="form">
       </td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
      <td>&nbsp;
      </td>
      <td><input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr>

      </table>
    </form>

<!--- Fim Área de conteúdo --->	  </td>
  </tr>
</table>
</body>
</html>