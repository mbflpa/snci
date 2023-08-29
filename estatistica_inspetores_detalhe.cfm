<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao, Und_Descricao, RIP_NumGrupo, Grp_Descricao, RIP_NumItem, Itn_Descricao, RIP_Comentario, RIP_Recomendacoes, RIP_Recomendacao_Inspetor, Fun_nome 
FROM (((Unidades 
INNER JOIN ((Resultado_Inspecao 
INNER JOIN Inspecao ON (Resultado_Inspecao.RIP_Unidade = Inspecao.INP_Unidade) AND (Resultado_Inspecao.RIP_NumInspecao = Inspecao.INP_NumInspecao)) 
INNER JOIN Grupos_Verificacao ON Resultado_Inspecao.RIP_NumGrupo = Grupos_Verificacao.Grp_Codigo) ON Unidades.Und_Codigo = Inspecao.INP_Unidade) 
INNER JOIN Itens_Verificacao ON (Resultado_Inspecao.RIP_NumItem = Itens_Verificacao.Itn_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = Itens_Verificacao.Itn_NumGrupo) AND right([Resultado_Inspecao.RIP_NumInspecao], 4) = Itens_Verificacao.Itn_Ano) 
INNER JOIN Inspetor_Inspecao ON (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)) 
INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE RIP_Melhoria ='1'AND (INP_DtFimInspecao BETWEEN #Data1# AND #Data2#)
AND IPT_MatricInspetor=#MAT#
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style2 {font-size: 12}
-->
</style>
</head>
<body>
<br>
<cfinclude template="cabecalho.cfm">
<br><br>
<cfif rsItem.recordcount is not 0>
<!--- Área de conteúdo   --->
<table width="100%" border="0" align="center">    
     <tr class="titulos">
       <td colspan="7" bgcolor="#eeeeee">&nbsp;</td>
     </tr>     		 
     <tr class="titulos">
	  <td bgcolor="#eeeeee">Inspetor:</td>
	  <td colspan="7" bgcolor="#eeeeee"><span class="titulos"><cfoutput>#rsItem.Fun_Nome#</cfoutput></span></td>
	 </tr>	
<cfoutput query="rsItem">	
	<tr class="titulos">
	  <td colspan="7" bgcolor="##eeeeee">&nbsp;</td>
	  </tr>
	<tr class="titulos">	
	  <td width="2%" bgcolor="##eeeeee"><span class="titulos">N&ordm; Inspe&ccedil;&atilde;o</span></td>	  
	  <td width="10%" bgcolor="##f7f7f7"><span class="titulos">Nome da Unidade</span></td>
	  <td width="13%" bgcolor="##eeeeee"><span class="titulos">Grupo</span></td>
	  <td width="13%" bgcolor="##f7f7f7"><span class="titulos">Item</span></td>
	  <td width="15%" bgcolor="##eeeeee"><span class="titulos">Irregularidade</span></td>
	  <td width="15%" bgcolor="##f7f7f7"><span class="titulos">Recomendações</span></td>
	  <td width="15%" bgcolor="##f7f7f7"><span class="titulos">Análise</span></td>
	</tr>
	<tr>
	  <td width="2%" bgcolor="##eeeeee"><span class="titulos">#RIP_NumInspecao#</span></td>	  
	  <td width="10%" bgcolor="##f7f7f7"><span class="titulos">#Und_Descricao#</span></td>
	  <td width="13%" bgcolor="##eeeeee"><span class="titulos">#Grp_Descricao#</span></td>
	  <td width="13%" bgcolor="##f7f7f7"><span class="titulos">#Itn_Descricao#</span></td>
	  <td width="15%" bgcolor="##eeeeee"><cfset coment = Replace(rsItem.RIP_Comentario,"
","<BR>" ,"All")><div align="justify"><span class="titulos">#coment#</span></div></td>
	  <td width="15%" bgcolor="##f7f7f7"><span class="titulos"><cfset recom = Replace(rsItem.RIP_Recomendacoes,"
","<BR>" ,"All")><div align="justify">#recom#</div></span></td> 
	</tr>
	<td width="15%" bgcolor="##f7f7f7"><span class="titulos"><cfset recom_inspetor = Replace(rsItem.RIP_Recomendacao_Inspetor,"
","<BR>" ,"All")><div align="justify">#recom_inspetor#</div></span></td> 
	</tr>
</cfoutput>
<cfelse><br><br><br>
     <td colspan="7" bgcolor="#eeeeee"><div align="center"><span class="titulos">Não há registros para este Inspetor</span></div></td>
</cfif>
   <tr class="titulos">
       <td colspan="7" bgcolor="#eeeeee">&nbsp;</td>
   </tr> 	
</table>
</body>
</html>