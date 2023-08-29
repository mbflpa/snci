<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>

<cfset total=0>
<cfif IsDefined("url.DtInic")>
<cfset url.dtInicio = url.DtInic>
<cfset url.dtFinal = url.DtFinal>
<cfelse>
<cfset url.dtInicio = right(form.dtinic,4) & "/" & mid(form.dtinic,4,2) & "/" & left(form.dtinic,2)>
<cfset url.dtFinal = right(form.dtfinal,4) & "/" & mid(form.dtfinal,4,2) & "/" & left(form.dtfinal,2)>
</cfif>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT Inspecao.INP_DtInicInspecao, Resultado_Inspecao.RIP_Unidade, Unidades.Und_Descricao, Resultado_Inspecao.RIP_NumInspecao, Resultado_Inspecao.RIP_NumGrupo, Resultado_Inspecao.RIP_NumItem, Resultado_Inspecao.RIP_DtUltAtu, Itens_Verificacao.Itn_Descricao, Grupos_Verificacao.Grp_Descricao, Areas.Ars_Codigo, Areas.Ars_Sigla
FROM Resultado_Inspecao, Itens_Verificacao, Grupos_Verificacao, Unidades, Inspecao, Areas 
RIP_Resposta = 'N' 
AND INP_DtInicInspecao between '#url.dtInicio#' and '#url.dtFinal#' and Ars_Codigo ='#url.area#' AND 
INP_NumInspecao = RIP_NumInspecao AND Und_Codigo = RIP_Unidade AND Itn_NumGrupo = RIP_NumGrupo AND 
convert(char(4),RIP_Ano) = Itn_Ano and INP_Modalidade = itn_modalidade and Itn_TipoUnidade = Und_TipoUnidade and 
Itn_NumItem = RIP_NumItem AND Grp_Codigo = RIP_NumGrupo AND Ars_Codigo = Itn_CodArea
ORDER BY Resultado_Inspecao.RIP_NumGrupo, Resultado_Inspecao.RIP_NumItem, Unidades.Und_Descricao,Resultado_Inspecao.RIP_NumInspecao, Inspecao.INP_DtInicInspecao  
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<link href="css.css" rel="stylesheet" type="text/css">

</head>
<body>
<table width="800" height="450">
<tr>
<td valign="top">
<!--- Área de conteúdo   --->
<table width="100%" class="exibir">
  <tr>
    <td height="29" colspan="6"><div align="center"><strong class="titulo1">Controle de Respostas Por Ger&ecirc;ncia </strong><br>
          <br>    
    </div></td>
  </tr>
  <tr>
    <td height="25" align="center" valign="top" colspan="10"><cfoutput>
      <div align="center"><span class="style5">#rsItem.Ars_Sigla#</span></div>
    </cfoutput></td>
  </tr>
  
  <tr class="exibir">
    <td height="16"><div align="center"></div></td>
    <td width="80" height="16" bgcolor="eeeeee"><div align="center">In&iacute;cio Insp. </div></td>
    <td width="180" bgcolor="eeeeee"><div align="left">Nome da Unidade</div></td>
    <td width="75" bgcolor="eeeeee"><div align="center">N&ordm; Inspe&ccedil;&atilde;o</div></td>
    <td width="390" bgcolor="eeeeee"><div align="left">N&ordm; Grupo</div></td>
    <td width="380" bgcolor="eeeeee"><div align="left">N&ordm; Item </div>
      <div align="left"></div></td>
  </tr>
  <cfoutput query="rsItem">
     <tr bgcolor="f7f7f7" class="exibir">
	    <cfif rsItem.RIP_Situacao eq 0>
    	<td width="80" height="26"><div align="center"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.RIP_Unidade#&Ninsp=#rsItem.RIP_NumInspecao#&Ngrup=#rsItem.RIP_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.RIP_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#url.dtInicio#&DtFinal=#url.dtFinal#" class="exibir"><strong>N&atilde;o Regularizada</strong></a></div></td>
        <cfelseif rsItem.RIP_Situacao eq 1>
		<td width="80" height="26" bgcolor="FF3300"><div align="center"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.RIP_Unidade#&Ninsp=#rsItem.RIP_NumInspecao#&Ngrup=#rsItem.RIP_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.RIP_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#url.dtInicio#&DtFinal=#url.dtFinal#" class="exibir"><strong>Respondida Area</strong></a></div></td>
        <cfelseif rsItem.RIP_Situacao eq 2> 
		<td height="26" bgcolor="FFFF00"><div align="center"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.RIP_Unidade#&Ninsp=#rsItem.RIP_NumInspecao#&Ngrup=#rsItem.RIP_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.RIP_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#url.dtInicio#" class="exibir"><strong>Pendente Agência</strong></a></div></td>
        <cfelseif rsItem.RIP_Situacao eq 4>
		<td width="80" height="26" bgcolor="0000FF"><div align="center" class="style1"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.RIP_Unidade#&Ninsp=#rsItem.RIP_NumInspecao#&Ngrup=#rsItem.RIP_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.RIP_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#url.dtInicio#&DtFinal=#url.dtFinal#" class="style2">Pendente Órgão Subordinador</a></div></td>
        <cfelseif rsItem.RIP_Situacao eq 5>
		<td width="80" height="26" bgcolor="00FF00"><div align="center"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.RIP_Unidade#&Ninsp=#rsItem.RIP_NumInspecao#&Ngrup=#rsItem.RIP_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.RIP_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#url.dtInicio#&DtFinal=#url.dtFinal#" class="exibir"><strong>Pendente &Aacute;rea </strong></a></div></td>
	    </cfif>
      <td width="80"><div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD-MM-YYYY')#</div></td>
      <td width="180"><div align="left">#rsItem.Und_Descricao#</div></td>
      <td width="75"><div align="center">#rsItem.RIP_NumInspecao#</div></td>
      <td width="390"><div align="left"><strong>#rsItem.RIP_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="380"><div align="left"><strong>#rsItem.RIP_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>
    </tr>
  </cfoutput>
</table>

<!--- Fim Área de conteúdo --->	  </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>
