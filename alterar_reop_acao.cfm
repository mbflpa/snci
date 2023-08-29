<cfquery name="qAtualiza" datasource="#dsn_inspecao#">
UPDATE Reops SET Rep_CodDiretoria = '#form.txtdr#', Rep_Nome = '#form.txtnome#', Rep_Status = '#form.Status#', Rep_DTUltAtu = convert(char, getdate(), 102), Rep_Email = '#form.Email#' 
WHERE Rep_Codigo = '#form.codigo#'
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<cfinclude template="cabecalho.cfm">
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>
<body>
<form action="alterar_reop.cfm">
<div align="center" class="style1"></div>
<br><br>
<tr><table width="90%">
<tr>
  <td align="center"><span class="red_titulo">Caro Usu&aacute;rio, sua opera&ccedil;&atilde;o de altera&ccedil;&atilde;o foi realizada com sucesso!!! </span></td>
</tr>
<tr>
  <td align="center">&nbsp;</td>
</tr>
<td align="center"><input type="submit" class="botao"  onClick="window.open('alterar_reop.cfm?','_self')" value="Voltar">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" class="botao" onClick="window.close()" value="Fechar"></td></tr>
</table>
</form>
</body>
</html>
