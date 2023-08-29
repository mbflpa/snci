<cfprocessingdirective pageEncoding ="utf-8"/>
<cfquery name="qAtualiza" datasource="#dsn_inspecao#">
UPDATE Funcionarios SET Fun_Nome = '#uCase(form.txtNome)#', Fun_DR = '#form.dr#', Fun_Status = '#form.Status#', Fun_Lotacao = '#uCase(form.Lotacao)#', Fun_DTUltAtu = convert(char, getdate(), 120), Fun_Email = '#form.Email#'
WHERE Fun_matric = '#Replace(Replace(Form.matricula,'.','','all'),'-','','all')#'
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<body>
<form action="alterar_Funcionario.cfm">
<div align="center" class="style1"></div>
<br><br>
<tr><table width="90%">
<tr>
  <td align="center"><span class="red_titulo">Caro Usu&aacute;rio, sua opera&ccedil;&atilde;o de altera&ccedil;&atilde;o foi realizada com sucesso!!! </span></td>
</tr>
<tr>
  <td align="center">&nbsp;</td>
</tr>
<td align="center"><input type="submit" class="botao"  onClick="window.open('alterar_Funcionario.cfm?','_self')" value="Voltar">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" class="botao" onClick="window.close()" value="Fechar"></td></tr>
</table>
</form>
</body>
</html>
