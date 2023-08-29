<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   

<script language="javascript">
//==========================
function validarform(){
//8.505.107-1
	var auxmatric = document.frmFuncionario.txtmatricula.value;
	if (auxmatric.length != 11)
	{
		alert('Informar a matrícula com 8 dígitos ex. X.XXX.XXX-X');
		return false;
	}
	var auxnome = document.frmFuncionario.txtNome.value;
	if (auxnome.length <= 10)
	{
		alert('Informar o nome completo');
		return false;
	}
	
	if (document.frmFuncionario.txtDR.value == '')
	{
		alert('Informar a SE');
		return false;
	}
	
	if (document.frmFuncionario.txtLotacao.value == '')
	{
		alert('Informar a Lotação');
		return false;
	}	
	
	if (document.frmFuncionario.txtEmail.value == '')
	{
		alert('Informar o e-mail');
		return false;
	}		
}
// ==============================
function Mascara_Matricula(Matricula)
{
	switch (Matricula.value.length)
	{
		case 1:
			Matricula.value += ".";
			break;
		case 5:
			Matricula.value += ".";
			break;
		case 9:
			Matricula.value += "-";
			break;
	}
}
</script>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfquery name="qdr" datasource ="#dsn_inspecao#">
  SELECT Dir_Codigo, Dir_Descricao FROM Diretoria WHERE Dir_Status = 'A' and Dir_Codigo = '#qUsuario.Usu_DR#'
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style1 {
	font-size: 12px;
	font-weight: bold;
}
-->
</style>
</head>
<body>

<form name="frmFuncionario" method="post" onSubmit="return validarform()" action="Adicionar_funcionario_acao.cfm">

<table width="826" border="0" class="exibir" align="center"><br>
  <tr>
    <td colspan="6" class="titulo1"><div align="center">Funcion&Aacute;rio</div></td>
    </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2"><div align="center"><strong class="titulosClaro style1">Dados Funcion&aacute;rios </strong></div></td>
    <td colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Funcion&aacute;rio:</td>
    <td width="60"><input type="text" name="txtmatricula" size="14" maxlength="11" class="form" onKeyPress="Mascara_Matricula(this)"></td>
    <td width="176"><input type="text" name="txtNome" size="52" maxlength="50" class="form"></td>
    <td colspan="2">&nbsp;</td>
    </tr>
  <tr>
    <td width="32">&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td width="99" class="titulos">SE:</td>
    <td colspan="4"><select name="txtDR" class="form">
                        <option selected="selected" value="">---</option>
                      <cfoutput query="qDr">
                        <option value="#Dir_Codigo#">#Dir_Descricao#</option>
                      </cfoutput>
                    </select></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Lota&ccedil;&atilde;o:</td>
    <td colspan="4"><input type="text" name="txtLotacao" size="32" maxlength="30" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Email: </td>
    <td colspan="4"><input type="text" name="txtEmail" size="50" maxlength="50" class="form"></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td class="titulos">Situa&ccedil;&atilde;o:</td>
    <td colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td height="84" colspan="2" rowspan="4">&nbsp;</td>
    <td colspan="3"><input name="situacao" type="radio" value="A" checked class="form">
      <span class="titulos">Ativo</span>      </td>
    <td rowspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="3"><input name="situacao" type="radio" value="D" class="form"> <span class="titulos">Desligado</span> </td>
  </tr>
  <tr>
    <td colspan="3"><span class="titulos">
      <input name="situacao" type="radio" value="P" class="form">
Aposentado    </span></td>
  </tr>
  <tr>
    <td colspan="3"><span class="titulos">
      <input name="situacao" type="radio" value="F" class="form">
Afastado    </span></td>
  </tr>
  <tr>
    <td colspan="6">&nbsp;</td>
    </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
    <td>
        <div align="right">
          <input type="button" class="botao"  onClick="history.back()" value="Voltar">
        </div></td>
    <td colspan="2"><input type="submit" name="Adicionar" value="Adicionar" class="botao"></td>
    <td width="312">&nbsp;</td>
  </tr>
</table>
</form>

</body>
</html>
