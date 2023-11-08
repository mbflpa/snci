<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfset total=0>
<cfif isDefined("ckTipo") And ckTipo eq "inspecao">
<cfquery name="rsBusc" datasource="#dsn_inspecao#">
 SELECT Inspetor_Inspecao.IPT_NumInspecao, Inspetor_Inspecao.IPT_MatricInspetor
 FROM ParecerUnidade INNER JOIN Inspetor_Inspecao ON (ParecerUnidade.Pos_Inspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (ParecerUnidade.Pos_Unidade = Inspetor_Inspecao.IPT_CodUnidade)
 WHERE Inspetor_Inspecao.IPT_NumInspecao='#txtNum_Inspecao#'   
</cfquery>
	 <cfif rsBusc.recordcount is 0>
	  <cflocation url="Mens_Erro.cfm?msg=1">
	 </cfif>
<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, INP_DtFimInspecao, Und_CodReop, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, INP_DtEncerramento, Grp_Descricao, Fun_Nome, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, Pos_Situacao_Resp
FROM ((Inspecao INNER JOIN (((Grupos_Verificacao INNER JOIN ParecerUnidade ON Grupos_Verificacao.Grp_Codigo = ParecerUnidade.Pos_NumGrupo) INNER JOIN Itens_Verificacao ON (ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo) AND (ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem)) INNER JOIN Unidades ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo) ON (Inspecao.INP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Inspecao.INP_Unidade = ParecerUnidade.Pos_Unidade)) INNER JOIN Inspetor_Inspecao ON (Unidades.Und_Codigo = Inspetor_Inspecao.IPT_CodUnidade) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade) AND (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao)) INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE (((Pos_Situacao_Resp)<>'3' And (Pos_Situacao_Resp)<>'8' And (Pos_Situacao_Resp)<>'9') AND ((Inspecao.INP_NumInspecao)='#txtNum_Inspecao#'))
GROUP BY INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, INP_DtFimInspecao, Und_CodReop, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, INP_DtEncerramento, Grp_Descricao, Fun_Nome, Pos_Situacao_Resp 
ORDER BY Quant DESC, INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop		   
</cfquery>
   <cfset dtinic = LSDateFormat(rsItem.INP_DtFimInspecao,"yyyy/mm/dd")>
   <cfset dtfim = LSDateFormat(rsItem.INP_DtFimInspecao,"yyyy/mm/dd")>
 <cfelse>
   <cfset url.dtInicio = DtInic>
   <cfset url.dtFinal = dtFim>
   <cfset url.dtInicio = CreateDate(Right(URL.dtinic,4), Mid(URL.dtinic,4,2), Left(URL.dtinic,2))>
   <cfset url.dtFinal = CreateDate(Right(URL.dtfinal,4), Mid(URL.dtfinal,4,2), Left(URL.dtfinal,2))> 
   
<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, INP_DtFimInspecao, Und_CodReop, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, INP_DtEncerramento, Grp_Descricao, Pos_Situacao_Resp, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant
FROM ((Inspecao INNER JOIN (((Grupos_Verificacao INNER JOIN ParecerUnidade ON Grupos_Verificacao.Grp_Codigo = ParecerUnidade.Pos_NumGrupo) INNER JOIN Itens_Verificacao ON (ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo) AND (ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem)) INNER JOIN Unidades ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo) ON (Inspecao.INP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Inspecao.INP_Unidade = ParecerUnidade.Pos_Unidade)) INNER JOIN Inspetor_Inspecao ON (Unidades.Und_Codigo = Inspetor_Inspecao.IPT_CodUnidade) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade) AND (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao)) INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
<cfif ckTipo eq "inspecao">
WHERE     ((Pos_Situacao_Resp <> '3') AND (Pos_Situacao_Resp <> '8') AND (Pos_Situacao_Resp <> '9')) AND (Inspecao.INP_NumInspecao = '#txtNum_Inspecao#')
<cfelse>
WHERE     ((Pos_Situacao_Resp <> '3') AND (Pos_Situacao_Resp <> '8') AND (Pos_Situacao_Resp <> '9')) AND (Inspecao.INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#)
</cfif>
GROUP BY INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, INP_DtFimInspecao, Und_CodReop, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, INP_DtEncerramento, Grp_Descricao, Pos_Situacao_Resp
ORDER BY  Quant DESC, INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop 
</cfquery>
</cfif>
   
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {color: #FFFFFF}
.style2 {
	font-size: 10px;
	text-decoration: none;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-weight: bold;
	color: #333333;
}
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">

</head>
<body>
<table width="100%" height="100%">
<tr>
<td valign="top" align="center">
<!--- Área de conteúdo   --->
<table width="100%" class="exibir">
  <tr>
    <td height="60" colspan="6"><div align="center"><strong class="titulo1">Controle de Respostas </strong></div></td>
  </tr>
  <!--- <tr>
   <cfif isDefined("ckTipo") And ckTipo eq "inspecao">     
    <td height="30" colspan="6"><div align="left"><strong class="titulosClaro"> INSPETOR:&nbsp;&nbsp;<cfoutput>#rsItem.Fun_Nome#</cfoutput></strong></div></td>
   </cfif>
  </tr> --->
  <tr><td colspan="6">&nbsp;&nbsp;</td></tr>
  <cfif rsItem.recordCount neq 0>
  <tr class="exibir">
    <td height="5%"><div align="center"><cfoutput>Qt. Itens: #rsItem.recordCount# </cfoutput></div></td>
    <td width="10%" bgcolor="eeeeee"><div align="center">Dt. Término Insp. </div></td>
	<td width="10%" bgcolor="eeeeee"><div align="center">Dt. Envio Insp. </div></td>
    <td width="20%" bgcolor="eeeeee"><div align="left">Nome da Unidade</div></td>
    <td width="10%" bgcolor="eeeeee"><div align="center">N&ordm; Inspe&ccedil;&atilde;o</div></td>
    <td width="25%" bgcolor="eeeeee"><div align="left">N&ordm; Grupo</div></td>
    <td width="30%" bgcolor="eeeeee"><div align="left">N&ordm; Item </div></td>
	<td width="30%" bgcolor="eeeeee"><div align="left">Quant. de Dias</div></td>
  </tr>
 <!--- <td><input name="nseq" type="hidden" id="nseq" value="<cfoutput>#num_seq#</cfoutput>"></td> --->
  <cfoutput query="rsItem">
     <tr bgcolor="f7f7f7" class="exibir">
	    <cfif rsItem.Pos_Situacao_Resp eq 0>
    	<td width="69" height="26" bgcolor="##666666"><div align="center"><a href="itens_inspetores_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#" class="exibir"><strong>N&atilde;o Respondida </strong></a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 1>
		<td width="75" height="26" bgcolor="FF3300"><div align="center"><a href="itens_inspetores_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#" class="exibir"><strong>Resposta Unidade </strong></a></div></td> 
		<cfelseif rsItem.Pos_Situacao_Resp eq 2> 
		<td width="59" height="26" bgcolor="FF9900"><div align="center"><a href="itens_inspetores_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#" class="exibir"><strong>Pendente Unidade </strong></a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 4>
		<td width="58" height="26" bgcolor="0000FF"><div align="center"><a href="itens_inspetores_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#" class="exibir"><strong>Pendente Órgão Subordinador</strong></a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 5>
		<td width="61" height="26" bgcolor="009900"><div align="center"><a href="itens_inspetores_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#" class="exibir"><strong>Pendente &Aacute;rea </strong></a></div></td>
	    <cfelseif rsItem.Pos_Situacao_Resp eq 6>
		<td width="59" height="26" bgcolor="##339999"><div align="center"><a href="itens_inspetores_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#" class="exibir"><strong>Resposta &Aacute;rea </strong></a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 7>
		<td width="56" height="26" bgcolor="0099FF"><div align="center"><a href="itens_inspetores_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#" class="exibir"><strong>Resposta Órgão Subordinador</strong></a></div></td>
	    </cfif>				
		
      <td width="161"><div align="center">#DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')#</div></td>
	  <td width="161"><div align="center">#DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')#</div></td>
      <td width="133"><div align="left">#rsItem.Und_Descricao#</div></td>
      <td width="155"><div align="center">#rsItem.Pos_Inspecao#</div></td>
      <td width="151"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="146"><div align="left"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>	 
	  <td width="146"><div align="center"><strong>#rsItem.Quant#</strong></div></td>	   		    
	 </tr>
  </cfoutput>
  <cfelse>
    <tr bgcolor="f7f7f7" class="exibir">
      <td colspan="12" align="center"><strong>Sr. Inspetor, todos os itens desta inspe&ccedil;&atilde;o foram solucionados, portanto o processo encontra-se encerrado. </strong> </td>
    </tr>
	<tr><td colspan="12" align="center">&nbsp;</td></tr>
 </cfif>  
  	<tr><td colspan="12" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
</table>
<!--- Fim Área de conteúdo --->	  </td>
    </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>
