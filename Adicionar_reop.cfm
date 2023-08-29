<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	font-size: 14px;
	font-weight: bold;
}
-->
</style>
</head>
<body>

<form name="frmArea" method="post" action="Adicionar_reop_acao.cfm">

<table width="702" border="0" class="exibir" align="center"><br><br><br>
  <tr>
    <td colspan="5" class="titulo1"><div align="center">&Oacute;RG&Atilde;O SUBORDINADOR </div></td>
    </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Diretoria:</td>
    <td colspan="3"><input type="text" name="txtDiretoria" size="8" maxlength="2" class="form"></td>
  </tr>
  <tr>
    <td width="43">&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td width="155" class="titulos">C&oacute;digo:</td>
    <td colspan="3"><input type="text" name="txtCodigo" size="8" maxlength="2" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Descri&ccedil;&atilde;o:</td>
    <td colspan="3"><input type="text" name="txtNome" size="40" maxlength="40" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Email &Oacute;rg&atilde;o Subordinador: </td>
    <td colspan="3"><input type="text" name="txtEmail" size="50" maxlength="50" class="form"></td>
  </tr>  
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Situa&ccedil;&atilde;o:</td>
    <td colspan="3">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td width="75"><input name="situacao" type="radio" value="A" checked class="form">
      <span class="titulos">Ativado</span></td>
    <td colspan="2"><input name="situacao" type="radio" value="D" class="form">
      <span class="titulos">Desativado</span></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="2"><div align="right">
      <input type="button" class="botao"  onClick="history.back()" value="Voltar">
    </div></td>&nbsp;&nbsp;&nbsp;
    <td width="410"><input type="submit" name="Adicionar" value="Adicionar" class="botao"></td>
  </tr>
</table>
</form>

</body>
</html>
