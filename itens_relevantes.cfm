<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInic,4), Mid(dtInic,4,2), Left(dtInic,2))>
<cfset dtFinal = CreateDate(Right(dtFim,4), Mid(dtFim,4,2), Left(dtFim,2))>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao, Und_Descricao, RIP_NumGrupo, Grp_Descricao, RIP_NumItem,Itn_Descricao, RIP_Comentario, RIP_Recomendacoes, Pos_Relevancia
FROM ((Unidades INNER JOIN ((Resultado_Inspecao INNER JOIN Inspecao ON (Resultado_Inspecao.RIP_Unidade = Inspecao.INP_Unidade) AND (Resultado_Inspecao.RIP_NumInspecao = Inspecao.INP_NumInspecao)) INNER JOIN Grupos_Verificacao ON Resultado_Inspecao.RIP_NumGrupo = Grupos_Verificacao.Grp_Codigo) ON Unidades.Und_Codigo = Inspecao.INP_Unidade) INNER JOIN Itens_Verificacao ON (Resultado_Inspecao.RIP_NumItem = Itens_Verificacao.Itn_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = Itens_Verificacao.Itn_NumGrupo)) INNER JOIN ParecerUnidade ON (Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade) AND (Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND (Resultado_Inspecao.RIP_NumItem = ParecerUnidade.Pos_NumItem)
WHERE Pos_Relevancia='1' AND (INP_DtFimInspecao BETWEEN #dtInicio# AND #dtFinal#)
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
<table width="94%" border="0" align="center">
<!---<form name="form" method="post" action="">--->
     <tr class="titulos">
       <td colspan="6" bgcolor="#eeeeee">&nbsp;</td>
     </tr>
	 <tr class="titulos"> 
      <td  colspan="6" bgcolor="eeeeee"><div align="center" class="style1"><span class="style1">Per&iacute;odo</span>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput>#DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;a&nbsp;&nbsp;&nbsp;<span class="style1">#DateFormat(dtFinal,"dd/mm/yyyy")#</cfoutput></span> </div></td>
     </tr>       
     
<cfoutput query="rsItem"><tr class="titulos">
  <td width="4%" bgcolor="##eeeeee"><span class="titulos"> Auditoria </span></td>	  
	  <td width="10%" bgcolor="##f7f7f7"><span class="titulos">Nome da Unidade</span></td>
	  <td width="13%" bgcolor="##eeeeee"><span class="titulos">Objetivo</span></td>
	  <td width="13%" bgcolor="##f7f7f7"><span class="titulos">Item</span></td>
	  <td width="25%" bgcolor="##eeeeee"><span class="titulos">Situação Encontrada</span></td>
	  <td width="25%" bgcolor="##f7f7f7"><span class="titulos">Recomendações</span></td>
	</tr>
	<tr>
	  <td width="4%" bgcolor="##eeeeee"><span class="titulos">#RIP_NumInspecao#</span></td>	  
	  <td width="10%" bgcolor="##f7f7f7"><span class="titulos">#Und_Descricao#</span></td>
	  <td width="13%" bgcolor="##eeeeee"><span class="titulos">#Grp_Descricao#</span></td>
	  <td width="13%" bgcolor="##f7f7f7"><span class="titulos">#Itn_Descricao#</span></td>
	  <td width="25%" bgcolor="##eeeeee"><cfset coment = Replace(rsItem.RIP_Comentario,"
","<BR>" ,"All")><div align="justify"><span class="titulos">#coment#</span></div></td>
	  <td width="25%" bgcolor="##f7f7f7"><span class="titulos"><cfset recom = Replace(rsItem.RIP_Recomendacoes,"
","<BR>" ,"All")><div align="justify">#recom#</div></span></td> 
	</tr>
</cfoutput>
<cfelse><br><br><br>
     <td colspan="5" bgcolor="#eeeeee"><div align="center"><span class="titulos">Não há registros para este Período</span></div></td>
</cfif>	  
<!--- </form>--->	
</table>
</body>
</html>