<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>


<cfset area = 'sins'>
<cfset total=0>

<cfif IsDefined("URL.Ninsp")>
<!---<cfset url.dtInicio = url.DtInic>--->
<cfset FORM.nu_inspecao = url.Ninsp>
<!--- <cfelse> --->
<!---<cfset url.dtInicio = createdate(right(form.dtinic,4), mid(form.dtinic,4,2), left(form.dtinic,2))>--->
</cfif>

<cfif IsDefined("url.numero")>
<cfset FORM.nu_inspecao = url.numero>
</cfif>

<!--- <cfdump var="#FORM.nu_inspecao#">
<cfabort> --->

<cfquery name="qVerifica" datasource="#dsn_inspecao#">
SELECT ParecerUnidade.Pos_Inspecao
FROM ParecerUnidade
WHERE ParecerUnidade.Pos_Inspecao = '#FORM.nu_inspecao#'
</cfquery>

<!--- <cfdump var="#qverifica#">
<cfabort> --->

<!--- ISRAEL --->
<cfquery name="qVerificaData" datasource="#dsn_inspecao#">
SELECT Inspecao.INP_DtInicInspecao
FROM Inspecao
WHERE Inspecao.INP_NumInspecao = '#FORM.nu_inspecao#'
</cfquery>
<!--- / ISRAEL --->

<cfif (qVerifica.recordcount neq 0)>  <!--- if 01 --->

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT     Inspecao.INP_DtInicInspecao, ParecerUnidade.Pos_Relevancia, ParecerUnidade.Pos_Unidade, Inspecao.INP_Responsavel, Unidades.Und_Descricao,
                      ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_NumGrupo, ParecerUnidade.Pos_NumItem, ParecerUnidade.pos_dtultatu,
                      Itens_Verificacao.Itn_Descricao, Grupos_Verificacao.Grp_Descricao, ParecerUnidade.Pos_Situacao_Resp, Pos_Parecer
FROM         ParecerUnidade INNER JOIN
                      Unidades ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo INNER JOIN
                      Itens_Verificacao ON ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo AND
                      ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem INNER JOIN
                      Grupos_Verificacao ON ParecerUnidade.Pos_NumGrupo = Grupos_Verificacao.Grp_Codigo INNER JOIN
                      Inspecao ON ParecerUnidade.Pos_Unidade = Inspecao.INP_Unidade AND ParecerUnidade.Pos_Inspecao = Inspecao.INP_NumInspecao
WHERE ParecerUnidade.Pos_Inspecao = '#FORM.nu_inspecao#'
ORDER BY Inspecao.INP_DtInicInspecao, Unidades.Und_Descricao, ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_NumGrupo, ParecerUnidade.Pos_NumItem
</cfquery>

<!--- <cfdump var="#rsitem#">
<cfabort> --->

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
	   Não há ítens pendentes para este Relatório de Avaliação de Controle Interno.
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
SELECT     Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
FROM         Inspetor_Inspecao INNER JOIN
                      Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND
                      Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE     (IPT_NumInspecao = '#FORM.nu_inspecao#')
</cfquery>


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="90%" height="45%">

<table width="90%" border="0" align="center">
	  <!--- <tr>
	  <td width="15%">&nbsp;</td>
	  <td width="15%">&nbsp;</td>
	  </tr> --->
	<br><br><br>

	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Nº Relatório</span></td>
	  <cfset Num_Insp = Left(rsItem.Pos_Inspecao,2) & '.' & Mid(rsItem.Pos_Inspecao,3,4) & '/' & Right(rsItem.Pos_Inspecao,4)>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#Num_Insp#</span></cfoutput></td>
	  <td bgcolor="#eeeeee"><span class="titulos">Inicio</span></td>
	  <td bgcolor="#f7f7f7"><cfoutput><span class="titulosClaro">#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</span></cfoutput></td>
	  <td align="center" bgcolor="#eeeeee" class="titulos">Imprimir</td>
	</tr>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Unidade</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.Und_Descricao#</span></cfoutput></td>
	  <td bgcolor="eeeeee"><span class="titulos">Responsável</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.INP_Responsavel#</span></cfoutput></td>
	  <td align="center" bgcolor="f7f7f7">
	    <form action="GeraRelatorio/gerador/dsp/relatorioHTML.cfm" name="frmHtml" method="post" target="_blank">
	      <img src="icones/relatorio.jpg" height="48" alt="Visualizar relatório em HTML" border="0" onClick="forms[0].submit()" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='pointer';">
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
	  <td colspan="4" bgcolor="f7f7f7"><strong class="titulosClaro">-&nbsp;<cfoutput query="qInspetor">#qInspetor.Fun_Nome#&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></strong></td>
	 </tr>


  <td >&nbsp;</td>

  <tr class="exibir">
    <td width="15%" bgcolor="eeeeee" class="titulos" height="16"><div align="center">Status</div></td>
    <td width="10%" bgcolor="eeeeee" class="titulos"><div align="center">Grupo</div></td>
    <td colspan="2" width="50%" bgcolor="eeeeee" class="titulos"><div align="center">Item</div></td>
  </tr>
	<!--- <td width="12%" bgcolor="eeeeee"><div align="center" class="titulos">Grau de Risco</div></td>
	<td width="8%" bgcolor="eeeeee"><div align="center" class="titulos">Comprometimento do Processo</div></td> --->

  <!--- variaveis utilizadas para grau de risco : Pedro Henrique --->
<!---   <cfset numGrav = 0>
  <cfset muitoGrav = 0>
  <cfset CP = 0>--->
<cfoutput query="rsItem">
<!--- Pegando grau de risco : Pedro Henrique --->
<!---<cfset grav = 0>
<cfquery name="qGrav" datasource="#dsn_inspecao#">
SELECT Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09 FROM Analise WHERE Ana_NumInspecao='#rsItem.Pos_Inspecao#' AND Ana_Unidade='#rsItem.Pos_Unidade#' AND Ana_NumGrupo=#rsItem.Pos_NumGrupo# AND Ana_NumItem=#rsItem.Pos_NumItem#
</cfquery>
 <cfif qGrav.Ana_Col01 is 1><cfset grav = int(10)></cfif>
 <cfif qGrav.Ana_Col02 is 1><cfset grav = val(grav) + int(5)></cfif>
 <cfif qGrav.Ana_Col03 is 1><cfset grav = val(grav) + int(7)></cfif>
 <cfif qGrav.Ana_Col04 is 1><cfset grav = val(grav) + int(10)></cfif>
 <cfif qGrav.Ana_Col05 is 1><cfset grav = val(grav) + int(5)></cfif>
 <cfif qGrav.Ana_Col06 is 1><cfset grav = val(grav) + int(2)></cfif>
 <cfif qGrav.Ana_Col07 is 1><cfset grav = val(grav) + int(7)></cfif>
 <cfif qGrav.Ana_Col08 is 1><cfset grav = val(grav) + int(5)></cfif>
 <cfif qGrav.Ana_Col09 is 1><cfset grav = val(grav) + int(10)></cfif>

 <cfif val(grav) gt 46>
   <cfset sGrav ='<span class="red_titulo">Muito Alto</span>'>
 </cfif>
 <cfif val(grav) is 0>
   <cfset sGrav ="----">
 </cfif>
 <cfif val(grav) gt 0 and val(grav) lte 15>
   <cfset sGrav ="Baixo">
 </cfif>
 <cfif val(grav) gt 15 and val(grav) lte 31>
   <cfset sGrav ="Médio">
 </cfif>
  <cfif val(grav) gt 31 and val(grav) lte 46>
   <cfset sGrav ='<span class="red_titulo">Alto</span>'>
 </cfif> --->
 <!--- Fim de grau do risco --->

 <!--- Verifica se o inspetor analisou os itens da inspeção --->
<cfquery name="qVerificaAnaliseInspecao" datasource="#dsn_inspecao#">
SELECT     CAST(Ana_Col01 AS Integer) + CAST(Ana_Col02 AS Integer) + CAST(Ana_Col03 AS Integer) + CAST(Ana_Col04 AS Integer) + CAST(Ana_Col05 AS Integer)
                      + CAST(Ana_Col06 AS Integer) + CAST(Ana_Col07 AS Integer) + CAST(Ana_Col08 AS Integer) + CAST(Ana_Col09 AS Integer) AS Analise_Inspecao,
                      Ana_NumInspecao, Ana_Unidade, Ana_NumGrupo, Ana_NumItem
FROM Analise
WHERE     (Ana_NumInspecao = '#rsItem.Pos_Inspecao#') AND (Ana_Unidade = '#rsItem.Pos_Unidade#') AND (Ana_NumGrupo = #rsItem.Pos_NumGrupo#) AND (Ana_NumItem = #rsItem.Pos_NumItem#) AND RIGHT(Ana_NumInspecao,4) >= 2010
</cfquery>

<!--- <cfdump var="#qVerificaAnaliseInspecao#">
SELECT     CAST(Ana_Col01 AS Integer) + CAST(Ana_Col02 AS Integer) + CAST(Ana_Col03 AS Integer) + CAST(Ana_Col04 AS Integer) + CAST(Ana_Col05 AS Integer)
                      + CAST(Ana_Col06 AS Integer) + CAST(Ana_Col07 AS Integer) + CAST(Ana_Col08 AS Integer) + CAST(Ana_Col09 AS Integer) AS Analise_Inspecao,
                      Ana_NumInspecao, Ana_Unidade, Ana_NumGrupo, Ana_NumItem
FROM         Analise
WHERE     (Ana_NumInspecao = '#rsItem.Pos_Inspecao#') AND (Ana_Unidade = '#rsItem.Pos_Unidade#') AND (Ana_NumGrupo = #rsItem.Pos_NumGrupo#) AND (Ana_NumItem = #rsItem.Pos_NumItem#)
	AND RIGHT(Ana_NumInspecao,4) >= 2010  --->

<!--- Verificando se o item foi analisado --->
<!--- <cfif qVerificaAnaliseInspecao.Analise_Inspecao is 0>
<tr bgcolor="FF0000" class="exibir">
<td width="59" height="26"><div align="center"><strong>Não Analisado</strong></div></td>

<cfelse> --->
     <tr bgcolor="f7f7f7" class="exibir" align="center">

	 <cfif rsItem.Pos_Situacao_Resp eq 0>
    	<td width="69" height="26" bgcolor="FF9900"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Responder</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 1>
		<td width="75" height="26" bgcolor="FF3300"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Respondido</strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 4>
		<td width="58" height="26" bgcolor="0000FF"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Órgão Subordinador</strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 5>
        <td width="61" height="26" bgcolor="00FF00"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Área</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 2>
	   <cfif rsItem.Pos_Parecer is ''>
	     <td width="59" height="26" bgcolor="666666"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Sem Manifestação</strong></a></div></td>
	   <cfelse>
		 <td width="59" height="26" bgcolor="FFFF00"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Unidade</strong></a></div></td>
       </cfif>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 6>
	 <!--- &DtFinal=#url.dtFinal# --->
		<td width="59" height="26" bgcolor="FF00FF"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Resposta &Aacute;rea </strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 7>
		<td width="56" height="26" bgcolor="9900FF"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Resposta Órgão Subordinador</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 3>
		<td width="59" height="26" bgcolor="333333"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Solucionado</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 8>
		<td width="56" height="26" bgcolor="FFCC99"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Corporativo DR</strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 9>
		<td width="59" height="26" bgcolor="00FF99"><div align="center"><a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Corporativo AC</strong></a></div></td>
	 </cfif>
<!--- </cfif> --->
      <td width="35%"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td colspan="3" width="45%"><div align="left"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div><td>

	  <!--- <td width="15%"><div align="center">#sGrav#</div></td> --->
	  <!--- <cfif Pos_Relevancia eq 1>
	  <td width="10%"><div align="center"><span class="red_titulo">X</span></div></td>
	  <cfelse>
	  <td width="10%"><div align="center">&nbsp;</div></td>
	  </cfif> --->
      <div align="center"><a href="Mod_CRRItem.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"></a></div>
    </tr>

	<!--- Fim da verificação do item --->

	<!--- Verificando Classificação : Pedro Henrique --->
	<!--- <cfif Pos_Relevancia eq 1>
		<cfset CP = CP + 1>
	</cfif>
	<cfif sGrav eq 'Médio' or sGrav eq '<span class="red_titulo">Alto</span>'>
		<cfset numGrav = 1>
	</cfif>
	<cfif sGrav eq '<span class="red_titulo">Muito Alto</span>'>
		<cfset muitoGrav = 1>
	</cfif> --->
</cfoutput>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td colspan="5" class="titulos" align="center"><cfoutput>Quantidade de pontos do Relatório de Avaliação de Controle Interno com oportunidade de aprimoramento: <font class="red_titulo">#rsItem.recordCount#</font> </cfoutput></td>
	</tr>
	<!---<tr><td colspan="5">&nbsp;</td></tr>
	<cfif numGrav eq 1 and CP eq 0>
	<tr><td colspan="6"><font class="titulosClaro">Considerando as classificações de cada oportunidade de aprimoramento, que se baseiam no seu grau de risco conclui-se que a unidade ou processo auditado encontra-se com &nbsp;</font><font class="red_titulo">Atividade sob controle, mas necessitando de ajustes.</font></td></tr>
	<cfelseif muitoGrav eq 1 and CP gt 1>
	<tr><td colspan="6"><font class="titulosClaro">Considerando as classificações de cada oportunidade de aprimoramento, que se baseiam no seu grau de risco conclui-se que a unidade ou processo auditado encontra-se com &nbsp;</font><font class="red_titulo">Atividade sem controle.</font></td></tr>
	<cfelseif numGrav eq 1 and CP gte 1>
	<tr><td colspan="6"><font class="titulosClaro">Considerando as classificações de cada oportunidade de aprimoramento, que se baseiam no seu grau de risco conclui-se que a unidade ou processo auditado encontra-se com &nbsp;</font><font class="red_titulo">Atividade com controle deficientes.</font></td></tr>
	<cfelseif muitoGrav eq 1 and CP eq 0>
	<tr><td colspan="6"><font class="titulosClaro">Considerando as classificações de cada oportunidade de aprimoramento, que se baseiam no seu grau de risco conclui-se que a unidade ou processo auditado encontra-se com &nbsp;</font><font class="red_titulo"></font></td></tr>
	<cfelseif muitoGrav eq 1 and CP eq 1>
	<tr><td colspan="6"><font class="titulosClaro">Considerando as classificações de cada oportunidade de aprimoramento, que se baseiam no seu grau de risco conclui-se que a unidade ou processo auditado encontra-se com &nbsp;</font><font class="red_titulo"></font></td></tr>
	<cfelse>
	<tr><td colspan="6"><font class="titulosClaro">Considerando as classificações de cada oportunidade de aprimoramento, que se baseiam no seu grau de risco conclui-se que a unidade ou processo auditado encontra-se com &nbsp;</font><font class="red_titulo">Atividade sob controle.</font></td></tr>
	</cfif>--->
	<!--- Fim da Classificação --->
  <tr><td>&nbsp;</td></tr>
   <tr class="exibir">
       <td height="26" colspan="5" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar"></td>
   </tr>
</table>

<!--- Fim Área de conteúdo --->
	  </td>
  </tr>
</table>
<!--- <cfoutput>
qVerificaData.recordCount: #qVerificaData.recordCount# <br> qVerifica.recordCount: #qVerifica.recordCount#
</cfoutput>
<br><br>
<cfoutput query="qVerificaData">
data inspecao #INP_DtInicInspecao# - form numero: #FORM.nu_inspecao#
<br>
achou3: #achou3#
</cfoutput> --->


</body>
</html>

<cfelse>  <!--- else do if 01 --->
<html>
<body onLoad="alert('Número de Relatório!');history.back();">
</body>
</html>
</cfif> <!--- fim if 01 --->

