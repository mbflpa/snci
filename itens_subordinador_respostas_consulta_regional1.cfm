<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<cfset area = 'sins'>
<cfset total=0>
<cfif IsDefined("URL.Unid")>
<!---<cfset url.dtInicio = url.DtInic>--->
<cfset FORM.nu_inspecao = url.Ninsp>
<!---<cfelse>--->
<!---<cfset url.dtInicio = createdate(right(form.dtinic,4), mid(form.dtinic,4,2), left(form.dtinic,2))>--->
</cfif>
<cfquery name="qVerifica" datasource="#dsn_inspecao#">
SELECT ParecerUnidade.Pos_Inspecao
FROM ParecerUnidade
WHERE ParecerUnidade.Pos_Inspecao = '#FORM.nu_inspecao#'
</cfquery>

<!--- ISRAEL --->
<cfquery name="qVerificaData" datasource="#dsn_inspecao#">
SELECT Inspecao.INP_DtInicInspecao
FROM Inspecao
WHERE Inspecao.INP_NumInspecao = '#FORM.nu_inspecao#'
</cfquery>
<!--- / ISRAEL --->

<cfif (qVerifica.recordcount neq 0) and (qVerificaData.recordcount neq 0)> <!--- if 01 --->

<cfquery name="rsItem" datasource="#dsn_inspecao#">
  SELECT Inspecao.INP_DtInicInspecao, ParecerUnidade.Pos_Unidade, Inspecao.INP_Responsavel, Unidades.Und_Descricao, ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_NumGrupo, ParecerUnidade.Pos_NumItem, ParecerUnidade.pos_dtultatu, Itens_Verificacao.Itn_Descricao, Grupos_Verificacao.Grp_Descricao, ParecerUnidade.Pos_Situacao_Resp, Pos_Parecer
  INNER JOIN Unidades ON Pos_Unidade = Und_Codigo 
  INNER JOIN Itens_Verificacao ON Pos_NumGrupo = Itn_NumGrupo AND Pos_NumItem = Itn_NumItem 
  INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo and Grp_Ano = Itn_Ano
  INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao and Itn_TipoUnidade = Und_TipoUnidade AND (INP_Modalidade = Itn_Modalidade)
  and right(Pos_Inspecao,4)= Itn_Ano
  WHERE (ParecerUnidade.Pos_Inspecao = '#FORM.nu_inspecao#' AND (ParecerUnidade.Pos_Situacao_Resp <> 0) AND (ParecerUnidade.Pos_Situacao_Resp <> 11) AND (ParecerUnidade.Pos_Situacao_Resp <> 12) AND (ParecerUnidade.Pos_Situacao_Resp <> 13))
  ORDER BY Inspecao.INP_DtInicInspecao, Unidades.Und_Descricao, ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_NumGrupo, ParecerUnidade.Pos_NumItem
</cfquery>


<cfif rsItem.recordCount eq 0>

	<html>
	<head>
	<title>Sistema Nacional de Controle Interno</title>
	<link href="CSS.css" rel="stylesheet" type="text/css">
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	</head>
	<body>
	<cfinclude template="cabecalho.cfm">
	<table border="0">
	<tr>
	<td>
	   Não há ítens pendentes para este relatório.
	<br><br>
    <input name="" value="fechar" type="button" onClick="self.close(); ">
	</td>
	</tr>
	</table>
	</body>
	</html>
	<cfabort>
</cfif>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
  WHERE (IPT_NumInspecao = '#FORM.nu_inspecao#')
</cfquery>


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="80%" height="450" align="center">

<table width="80%" border="0" align="center">
	<!--- <tr>
	  <td width="15%">&nbsp;</td>
	  <td width="31%">&nbsp;</td>
	</tr> --->
	<tr><td colspan="7">&nbsp;</td></tr>
	<tr><td colspan="7">&nbsp;</td></tr>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Relatório</span></td>
	  <cfset Num_Insp = Left(rsItem.Pos_Inspecao,2) & '.' & Mid(rsItem.Pos_Inspecao,3,4) & '/' & Right(rsItem.Pos_Inspecao,4)>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#Num_Insp#</span></cfoutput></td>
	  <td bgcolor="eeeeee" width="5%"><span class="titulos">Inicio do Relatório</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</span></cfoutput></td>
	  <td align="center" bgcolor="eeeeee" class="titulos">Imprimir</td>
	</tr>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Unidade</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.Und_Descricao#</span></cfoutput></td>
	  <td bgcolor="eeeeee"><span class="titulos">Responsável</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.INP_Responsavel#</span></cfoutput></td>
	  <td align="center" bgcolor="f7f7f7">
	   <form action="GeraRelatorio/gerador/dsp/relatorioHTML.cfm" name="frmHtml" method="post" target="_blank">
	      <img src="icones/relatorio.jpg" height="48" alt="Visualizar relatório em HTML" border="0" onClick="forms[0].submit()" onMouseOver="this.style.cursor='hand';" onMouseOut="this.style.cursor='pointer';">
		  <input type="hidden" name="id" value="<cfoutput>#FORM.nu_inspecao#</cfoutput>">
	    </form>
	  </td>
	 </tr>
	<tr>
	  <cfif qInspetor.RecordCount lt 2>
	    <td bgcolor="eeeeee"><span class="titulos">Inspetor</span></td>
	  <cfelse>
	    <td bgcolor="eeeeee"><span class="titulos">Inspetores</span></td>
	  </cfif>
	  <td colspan="7" bgcolor="f7f7f7"><strong class="titulosClaro">-&nbsp;<cfoutput query="qInspetor">#qInspetor.Fun_Nome#&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></strong></td>
	</tr>
	 <tr><td colspan="7">&nbsp;</td></tr>
 </table>

<table width="80%" class="exibir" align="center">
  <tr class="exibir">
    <td width="5%" bgcolor="eeeeee" class="titulos" height="16"><div align="center">Status</div></td>
    <td width="25%" colspan="2" bgcolor="eeeeee" class="titulos"><div align="center">Grupo</div></td>
    <td width="49%" bgcolor="eeeeee" class="titulos"><div align="center">Item</div></td>
  </tr>
<cfoutput query="rsItem">
<tr bgcolor="FF0000" class="exibir">

     <tr bgcolor="f7f7f7" class="exibir">

	 <cfif rsItem.Pos_Situacao_Resp eq 0>
    	<td width="69" height="26" bgcolor="666666"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Em Revisão</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 1>
		<td width="75" height="26" bgcolor="FF3300"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Respondido</strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 4>
		<td width="58" height="26" bgcolor="0000FF"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Órgão Subordinador</strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 5>
        <td width="61" height="26" bgcolor="009900"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Área</strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 2>
	    <td width="59" height="26" bgcolor="FFA500"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Unidade</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 6>
		<td width="59" height="26" bgcolor="339999"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Resposta &Aacute;rea </strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 7>
		<td width="56" height="26" bgcolor="0099FF"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Resposta Órgão Subordinador</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 3>
		<td width="59" height="26" bgcolor="333333"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Solucionado</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 8>
		<td width="56" height="26" bgcolor="FFCC99"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Corporativo SE</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 9>
		<td width="59" height="26" bgcolor="CD853F"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Corporativo CS</strong></a></div></td>
	  <cfelseif rsItem.Pos_Situacao_Resp eq 10>
		<td width="56" height="26" bgcolor="800080"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Ponto Suspenso</strong></a></div></td>
	  <cfelseif rsItem.Pos_Situacao_Resp eq 11>
		<td width="59" height="26" bgcolor="000000"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Em Liberação</strong></a></div></td>
	  <cfelseif rsItem.Pos_Situacao_Resp eq 14>
		<td width="59" height="26" bgcolor="236B8E"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Não Respondido</strong></a></div></td>
	 </cfif>
	<!---  </cfif> --->
      <td colspan="2"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="49%"><div align="justify"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div>
     <!---  <td><div align="center"><a href="Mod_CRRItem.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"></a></div></td> --->
    </tr>
</cfoutput>
	<tr><td colspan="7">&nbsp;</td></tr>
	<tr>
		<td colspan="7" class="titulos" align="center"><cfoutput>Quantidade de pontos do relatório com Situação Encontrada: <font class="red_titulo">#rsItem.recordCount#</font> </cfoutput></td>
	</tr>

   <tr class="exibir">
       <td height="26" colspan="7" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar"></td>
   </tr>
</table>
<!--- Fim Área de conteúdo --->
	  </td>
  <!--- </tr> --->
</table>

</body>
</htm


><cfelse> <!--- else do if 01 --->
<html>
  <body onLoad="alert('Número do Relatório Incorreto!');history.back();">
</body>
</html>
</cfif> <!--- fim if 01 --->

