<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>
<html>
<head><title>Sistema de Acompanhamento das Respostas das Inspeções</title></head>
<body>
<cffile action="read" file="#GetDirectoryFromPath(gettemplatepath())#Dados\inspecao.xml" variable="XmlDoc">
<!---Dessa forma ja estamos lendo nosso arquivo .xml--->
<cfset xml = XmlParse(XmlDoc)>
<!---Converte o string pra XML---> 

Agora devemos fazer um loop em nosso xml para apresentar os dados: 

<!---Nossa array apresenta o tipo de arquivo + o nome da chave + o nome da chave primaria do xml---> 
<table width="100%" border="1">
<cfloop from="1" to="#ArrayLen(xml.rootelement.dados)#" index="i"> 

<cfoutput>

<tr>
<!---Da mesma forma que no loop utilizamos as chaves do arquivo e os atributos do XML--->
<td>#xml.rootelement.dados[i].RIP_Unidade.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_NumInspecao.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_NumGrupo.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_NumItem.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_CodDiretoria.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_CodReop.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_Ano.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_Resposta.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_Comentario.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_DtUltAtu.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_UserName.XmlText#</td>
<td>#xml.rootelement.dados[i].RIP_Recomendacoes.XmlText#</td>
<cfif xml.rootelement.dados[i].RIP_Situacao.XmlText is ''> 
<td>-</td>
<cfelse>
<td>#xml.rootelement.dados[i].RIP_Situacao.XmlText#</td>
</cfif>
<cfif xml.rootelement.dados[i].RIP_Observacao.XmlText is ''>
<td>-</td>
<cfelse>
<td>#xml.rootelement.dados[i].RIP_Observacao.XmlText#</td>
</cfif>
</tr>
</cfoutput>
</cfloop> 
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
<form name="form1" method="post" action="inspecao_action.cfm">
<input type="submit" value="Adicionar">
</form>

</body>
</html>