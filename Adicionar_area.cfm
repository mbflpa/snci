<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
    font-size: 14px;
	font-weight: bold;

-->
</style>
</head>
<body>

<form name="frmArea" method="post" action="Adicionar_area_acao.cfm">

<table width="702" border="0" class="exibir" align="center"><br><br><br>
  <tr>
    <td colspan="4" class="titulo1"><div align="center"></div></td>
    </tr>
  <tr>
    <td colspan="4"><div align="center" class="titulo1">&Aacute;reas</div></td>
    </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td width="60">&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td width="118" class="titulos">C&oacute;digo:</td>
    <td colspan="2"><input type="text" name="txtCodigo" size="15" maxlength="8" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Sigla:</td>
    <td colspan="2"><input type="text" name="txtSigla" size="15" maxlength="10" class="form"></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Descri&ccedil;&atilde;o:</td>
    <td colspan="2"><input type="text" name="txtDescricao" size="60" maxlength="80" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Email &Aacute;rea: </td>
    <td colspan="2"><input type="text" name="txtEmailArea" size="80" maxlength="50" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Email Coordenador:</td>
    <td colspan="2"><input type="text" name="txtEmailCoordenador" size="60" maxlength="50" class="form">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Situa&ccedil;&atilde;o:</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td width="75"><input name="situacao" type="radio" value="A" checked class="form">
      <span class="titulos">Ativado</span></td>
    <td width="431"><input name="situacao" type="radio" value="D" class="form">
      <span class="titulos">Desativado</span></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td><input type="button" class="botao"  onClick="history.back()" value="Voltar"></div></td>
    <td><input type="submit" name="Adicionar" value="Adicionar" class="botao"></td>
    </tr>
</table>
</form>

</body>
</html>
