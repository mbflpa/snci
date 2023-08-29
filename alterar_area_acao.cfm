<cfquery name="qAtualiza" datasource="#dsn_inspecao#">
UPDATE Areas SET Ars_Sigla = '#form.sigla#', Ars_Descricao = '#form.Descricao#', Ars_Status = '#form.Status#', Ars_DTUltAtu = convert(char, getdate(), 102), Ars_UserName = '#CGI.REMOTE_USER#', Ars_Email = '#form.Email#', Ars_EmailCoordenador = '#form.EmailCoordenador#' 
WHERE Ars_Codigo = '#form.codigo#'
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
<form action="alterar_area.cfm">
<div align="center" class="style1"></div>
<br><br>
<tr><table width="90%">
<tr>
  <td align="center"><span class="red_titulo">Caro Usu&aacute;rio, sua opera&ccedil;&atilde;o de altera&ccedil;&atilde;o foi realizada com sucesso!!! </span></td>
</tr>
<tr>
  <td align="center">&nbsp;</td>
</tr>
<td align="center"><input type="submit" class="botao"  onClick="window.open('alterar_area.cfm?','_self')" value="Voltar">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" class="botao" onClick="window.close()" value="Fechar"></td></tr>
</table>
</form>
</body>
</html>
