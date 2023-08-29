
<cfparam name="URL.dtFinal" default="0">
<cfparam name="URL.DtInic" default="0">
<cfparam name="URL.dtFim" default="0">
<cfparam name="URL.Reop" default="">
<cfparam name="URL.ckTipo" default="">

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT Resultado_Inspecao.RIP_NumInspecao, Resultado_Inspecao.RIP_Unidade, Unidades.Und_Descricao, Resultado_Inspecao.RIP_NumGrupo, Resultado_Inspecao.RIP_NumItem, Resultado_Inspecao.RIP_Comentario, Resultado_Inspecao.RIP_Recomendacoes, Inspecao.INP_DtInicInspecao, Inspecao.INP_Responsavel
FROM (Unidades INNER JOIN ((Resultado_Inspecao INNER JOIN Inspecao ON (Resultado_Inspecao.RIP_Unidade = Inspecao.INP_Unidade) AND (Resultado_Inspecao.RIP_NumInspecao = Inspecao.INP_NumInspecao)) INNER JOIN Grupos_Verificacao ON Resultado_Inspecao.RIP_NumGrupo = Grupos_Verificacao.Grp_Codigo) ON Unidades.Und_Codigo = Inspecao.INP_Unidade) INNER JOIN Itens_Verificacao ON Grupos_Verificacao.Grp_Codigo = Itens_Verificacao.Itn_NumGrupo
WHERE Resultado_Inspecao.RIP_NumInspecao='#URL.numero#' AND Resultado_Inspecao.RIP_Unidade='#URL.unidade#' AND Resultado_Inspecao.RIP_NumGrupo= #URL.numgrupo# AND Resultado_Inspecao.RIP_NumItem=#URL.numitem#
</cfquery>

<!--- Visualização de anexos --->
	  <cfquery name="qAnexos" datasource="#dsn_inspecao#">
		SELECT     Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
		FROM       Anexos
		WHERE  Ane_NumInspecao = #url.numero# AND Ane_Unidade = #url.unidade# AND Ane_NumGrupo = #url.numgrupo# AND Ane_NumItem = #url.numitem# 
		order by Ane_Codigo
	  </cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="800" height="450">
<tr>
	  <td valign="top">
	  
<!--- Área de conteúdo   --->
<table width="80%" border="0" align="center">
	<tr>
      <td colspan="4" bgcolor="#f7f7f7">&nbsp;</td>
	  </tr>
	<tr>
      <td colspan="4" bgcolor="#f7f7f7"><span class="titulo1">Situação Encontrada</span></td>
	  </tr>
	<tr>
      <td colspan="4" bgcolor="#f7f7f7">&nbsp;</td>
	  </tr>
	<tr>
	  <td bgcolor="#eeeeee"><span class="titulos">Auditoria:</span></td>
	  <cfset Num_Insp = Left(rsItem.RIP_NumInspecao,2) & '.' & Mid(rsItem.RIP_NumInspecao,3,4) & '/' & Right(rsItem.RIP_NumInspecao,4)>
	  <td bgcolor="#f7f7f7"><cfoutput><span class="titulosClaro">#Num_Insp#</span></cfoutput></td>
	  <td width="18%" bgcolor="#eeeeee"><span class="titulos">Início da Auditoria:</span></td>
	  <td width="41%" bgcolor="#f7f7f7"><cfoutput><span class="titulosClaro">#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</span></cfoutput></td>
	</tr>
	<tr>
	  <td bgcolor="#eeeeee"><span class="titulos">Unidade:</span></td>
	  <td bgcolor="#f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.Und_Descricao#</span></cfoutput></td>
	  <td bgcolor="#eeeeee"><span class="titulos">Responsável: </span></td>
	  <td bgcolor="#f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.INP_Responsavel#</span></cfoutput></td> 
	</tr>
	<tr>
	  <td colspan="4" bgcolor="#f7f7f7">&nbsp;</td>
	</tr>
	<tr>
	  <td colspan="4" bgcolor="#eeeeee"><span class="titulos">Situação Encontrada:</span></td> 
	 </tr>
	 <tr>
	 <cfset coment = Replace(rsItem.RIP_Comentario,"
","<BR>" ,"All")>
         
	 <td colspan="4" bgcolor="#f7f7f7" class="exibir"><div align="justify"><cfoutput>#coment#</cfoutput></div></td>
	 </tr>
	 <tr>
	  <td colspan="4" bgcolor="#eeeeee"><span class="titulos">Recomenda&ccedil;&otilde;es: </span></td> 
	 </tr>
	 <tr>
	  <td colspan="4" bgcolor="#f7f7f7" class="exibir">
	  <cfset recom = Replace(rsItem.RIP_Recomendacoes,"
","<BR>" ,"All")>
	  <cfif Trim(rsItem.RIP_Recomendacoes) is ''>&nbsp;
	    <div align="justify">
	      <cfelse> 
	      <cfoutput>#recom#</cfoutput>
	        </div>
	  </cfif>
	  </td> 
	 </tr>
	<tr>
	  <td colspan="4" bgcolor="#eeeeee">&nbsp;</td>
	</tr>
	<!--- <tr bgcolor="#eeeeee">
	  <td colspan="3" class="exibir"><strong>ANEXOS</strong></td>
      <td height="22" valign="top" class="exibir">&nbsp;</td>
	</tr>
	<cfloop query="qAnexos">
	  	<cfif FileExists(qAnexos.Ane_Caminho)>
		<tr>
      		<td valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
      		<td colspan="3" bgcolor="f7f7f7">
				<a target="_blank" href="<cfoutput>#qAnexos.Ane_Caminho#</cfoutput>">
				<span class="link1"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></span></a></td>
			<cfoutput>
			<td bgcolor="f7f7f7">&nbsp; </td>
			</cfoutput> 
		 </tr>
		    </cfif>		
	  </cfloop>   	
	<tr>
	  <td colspan="4" bgcolor="#eeeeee">&nbsp;</td>
	</tr> --->
	
	<tr>
	  <td colspan="4" align="center" bgcolor="#f7f7f7"><input type="button" class="botao" value="Fechar" onClick="window.close()"></td>
	</tr>
</table>

<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
</body>
</html>