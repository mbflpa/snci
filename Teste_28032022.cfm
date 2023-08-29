<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Untitled Document</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
</head>

<cfquery datasource="#dsn_inspecao#" name="rsPontuacao">
SELECT TUI_Ano, TUI_Pontuacao, TUI_Classificacao
FROM TipoUnidade_ItemVerificacao
GROUP BY TUI_Ano, TUI_Pontuacao, TUI_Classificacao
ORDER BY TUI_Ano, TUI_Pontuacao
</cfquery>

<body>
<table width="883" border="0">
  <tr class="titulos">
    <td width="73">Ano</td>
    <td width="105">Pontuação</td>
    <td width="129">Classificação</td>
    <td colspan="2"><div align="center">Formula atual </div></td>
    <td colspan="2"><div align="center">Formula de corre&ccedil;&atilde;o </div></td>
  </tr>
<cfoutput query="rsPontuacao">
	<cfset ripontoa = val(TUI_Pontuacao)>
	<cfset auxpera = int((ripontoa * 72)/100)>
	<cfif auxpera gt 40>
		<cfset auxclassa = 'Grave'>
	<cfelseif auxpera gt 10 and auxpera lte 40>
		<cfset auxclassa = 'Mediana'>
	<cfelse>
		<cfset auxclassa = 'Leve'> 
	</cfif>
<!---  --->		
    <cfset auxperb = val(TUI_Pontuacao)>
	<cfset auxperb = NumberFormat(((auxperb * 72)/100),999.0)>
	<cfif auxperb gt 40>
		<cfset auxclassifb = 'Grave'>
	<cfelseif auxperb gt 10 and auxperb lte 40>
		<cfset auxclassifb = 'Mediana'>
	<cfelse>
		<cfset auxclassifb = 'Leve'> 
	</cfif>
  <tr class="exibir">
    <td><div align="left"><strong>#TUI_Ano#</strong></div></td>
    <td><div align="left"><strong>#TUI_Pontuacao#</strong></div></td>
    <td><div align="left"><strong>#TUI_Classificacao#</strong></div></td>
    <td width="116"><div align="center"><strong>#auxpera#</strong></div></td>
    <td width="97"><div align="center"><strong>#auxclassa#</strong></div></td>
    <td width="118"><div align="center"><strong>#auxperb#</strong></div></td>
	<td width="215"><div align="center"><strong>#auxclassifb#</strong></div></td>
  </tr>
</cfoutput>  
</table>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
</body>
</html>
