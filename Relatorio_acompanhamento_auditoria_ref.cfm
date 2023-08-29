 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<html>
<head>
<br><br><br>
<title>Sistema de Acompanhamento das Respostas</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<!--- <cfinclude template="valida.cfm"> --->
<br>
<table width="606" height="450">
<tr> 
	  <td width="538" align="center"  valign="top">
<!--- Área de conteúdo   --->
	<form action="GeraRelatorio/gerador/dsp/relatorio_acompanhamento.cfm" method="Post" name="frmHtml" target="_blank">
      <table  align="center">      
      <tr>
        <td colspan="3"><div align="center"><span class="titulo1"><strong>Relat&Oacute;rio de Acompanhamento </strong></span></div></td>
      </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
	  <tr>
        <td width="57">&nbsp;</td>
        <td width="128"><div align="center"><span class="exibir"><strong>N&ordm; Relat&oacute;rio: </strong></span></div></td>
        <td width="258"><input name="id" type="text" tabindex="2" size="14" maxlength="10" vazio="false" nome="Nº Inspeção" onKeyPress="sohNumeros();" class="form">
       </td>
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