<cfquery name="qConsulta" datasource="DBINS_TESTE">
SELECT RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_CodDiretoria, RIP_CodReop, RIP_Ano, RIP_Resposta, RIP_Comentario, RIP_DtUltAtu, RIP_UserName, RIP_Recomendacoes, RIP_Situacao, RIP_Observacao
FROM Resultado_Inspecao
</cfquery>

<html>
<head><title>Untitled Document</title></head>
<body>
<table width="100%" border="1">
<cfoutput query="qConsulta">

<tr>
<td>#RIP_Unidade#</td>
<td>#RIP_NumInspecao#</td>
<td>#RIP_NumGrupo#</td>
<td>#RIP_NumItem#</td>
<td>#RIP_CodDiretoria#</td>
<td>#RIP_CodReop#</td>
<td>#RIP_Ano#</td>
<td>#RIP_Resposta#</td>
<td>#RIP_Comentario#</td>
<td>#RIP_DtUltAtu#</td>
<td>#RIP_UserName#</td>
<td>#RIP_Recomendacoes#</td>
<td>#RIP_Situacao#</td>
<td>#RIP_Observacao#</td>
</tr>
</cfoutput>
<tr>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
  <td>&nbsp;</td>
</tr>
</table>

</body>
</html>