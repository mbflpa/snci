<cfquery name="qPesquisaPrincipal"  datasource="#dsn_inspecao#">
			          SELECT Inspecao.INP_Unidade, Inspecao.INP_NumInspecao, Inspecao.INP_DtEmissao, Resultado_Inspecao.RIP_Manchete, Resultado_Inspecao.RIP_NumItem,
                      ParecerUnidade.Pos_NumItemRecom, Resultado_Inspecao.RIP_VLEnvolvido, Resultado_Inspecao.RIP_Valor, Resultado_Inspecao.RIP_Comentario,
                      Risco.RSC_Sigla, Resultado_Inspecao.RIP_ManifestInicial, Resultado_Inspecao.RIP_Item, Inspecao.INP_AnoRelatorio, Resultado_Inspecao.RIP_Reincidencia,
                      Recomendacao.Rec_NumItem, Inspecao.INP_NumRelatorio, Recomendacao.Rec_NumItemRecom, Recomendacao.Rec_Recomendacao, ParecerUnidade.Pos_Area,
                      ParecerUnidade.Pos_Parecer, Inspecao.INP_NumProcesso, ParecerUnidade.Pos_Situacao_Resp, ParecerUnidade.Pos_Situacao, Areas.Ars_Sigla, Unidades.Und_Descricao,
                      Tipo_Auditoria.TAU_Sigla, Grupos_Verificacao.Grp_Descricao, Situacao_Ponto.STO_Sigla, Atividades.Atv_Sigla,
                      (SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = Pos_Area) AS Gestor, (SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = Rec_AreaFuncional) AS GestorCorporativo, DATEDIFF(dd,
	 				  Inspecao.INP_DtEmissao, GETDATE()) AS Quant
					  FROM Areas INNER JOIN
                      Grupos_Verificacao INNER JOIN
                      Situacao_Ponto INNER JOIN
                      Risco INNER JOIN
                      Resultado_Inspecao INNER JOIN
                      Tipo_Auditoria INNER JOIN
                      Unidades INNER JOIN
                      Inspecao ON Unidades.Und_Codigo = Inspecao.INP_Unidade ON Tipo_Auditoria.TAU_Codigo = Inspecao.INP_TipoAud ON
                      Resultado_Inspecao.RIP_NumInspecao = Inspecao.INP_NumInspecao AND Resultado_Inspecao.RIP_Unidade = Inspecao.INP_Unidade ON
                      Risco.RSC_Codigo = Resultado_Inspecao.RIP_Risco INNER JOIN
                      Recomendacao ON Resultado_Inspecao.RIP_NumItem = Recomendacao.Rec_NumItem AND
                      Resultado_Inspecao.RIP_NumInspecao = Recomendacao.Rec_Inspecao AND Resultado_Inspecao.RIP_Unidade = Recomendacao.Rec_Unidade INNER JOIN
                      ParecerUnidade ON Recomendacao.Rec_NumItemRecom = ParecerUnidade.Pos_NumItemRecom AND
                      Recomendacao.Rec_NumItem = ParecerUnidade.Pos_NumItem AND Recomendacao.Rec_Inspecao = ParecerUnidade.Pos_Inspecao AND
                      Recomendacao.Rec_Unidade = ParecerUnidade.Pos_Unidade ON Situacao_Ponto.STO_Codigo = ParecerUnidade.Pos_Situacao_Resp ON
                      Grupos_Verificacao.Grp_Codigo = Resultado_Inspecao.RIP_Grupo ON Areas.Ars_Codigo = ParecerUnidade.Pos_Area INNER JOIN
                      Atividades ON Recomendacao.Rec_CodAtividade = Atividades.Atv_Codigo
					  WHERE (((0=1)
                      <cfif isDefined("form.pesquisa") and listfind(form.pesquisa,'M')>
				        OR (Resultado_Inspecao.RIP_Manchete like '%#form.palavra#%')
					  </cfif>

		              <cfif isDefined("form.pesquisa") and listfind(form.pesquisa,'C')>
				        OR (Resultado_Inspecao.RIP_Comentario like '%#form.palavra#%')
				      </cfif>

				      <cfif isDefined("form.pesquisa") and listfind(form.pesquisa,'P')>
				        OR (Resultado_Inspecao.RIP_ManifestInicial like '%#form.palavra#%')
		              </cfif>
		               <cfif isDefined("form.pesquisa") and listfind(form.pesquisa,'R')>
				        OR (Recomendacao.REC_Recomendacao like '%#form.palavra#%')
		              </cfif>
		              <cfif isDefined("form.pesquisa") and listfind(form.pesquisa,'A')>
				        OR (ParecerUnidade.Pos_Parecer like '%#form.palavra#%')
		              </cfif>
		              <cfif isDefined("form.ano")>) and (Inspecao.INP_AnoRelatorio IN (#form.ano#))
		              <cfelse>
                      )
					  </cfif>
					  <cfif isDefined("form.status")>) and (ParecerUnidade.Pos_Situacao_Resp IN (#form.status#))
		              <cfelse>
                      )
					  </cfif>
   			          ORDER BY INP_NumInspecao, RIP_item, Recomendacao.Rec_NumItemRecom

</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento-Follow-up</title>
<!--- <link href="CSS.css" rel="stylesheet" type="text/css"> --->
<link href="../../../css.css" rel="stylesheet" type="text/css" />
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

<!--- <form> --->

<body>
<cftry>
<cfdocument filename="\\sac0424\sistemas\FOLLOWUP\SARIN_ANEXOS\Relatorio_palavra_chave.pdf" format="pdf" orientation="landscape" name="estat" overwrite="yes" pagetype="legal" marginbottom="0.5" margintop="1.5" marginleft="1.0" marginright="0.5" mimetype="text/html">

<cfdocumentitem type="header">
 <table align="left" width="60%">
  <tr><td align="left"><font size="5"><strong>Empresa Brasileira de Correios e Telégrafos</strong></font></td></tr>
  <tr><td align="left"><font size="5"><strong>Sistema de Follow-up - Auditoria</strong></font></td></tr>
  <tr><td align="left"><font size="5"><strong>Relatório de Acompanhamento</strong></font></td></tr>
 </table>
</cfdocumentitem>

<cfloop query="qpesquisaPrincipal">

<cfquery name="qpesquisa" datasource="#dsn_inspecao#">
SELECT     Analise.ANA_NumInspecao, Analise.ANA_Unidade, Analise.ANA_NumItem, Analise.ANA_NumItemRecom, Analise.ANA_DtUltAtu, Analise.ANA_Area,
                      Analise.ANA_Situacao_Resp, Analise.ANA_DtPosic, Analise.ANA_Analise, Analise.ANA_UserName, Situacao_Ponto.STO_Sigla, Situacao_Ponto.STO_Descricao, Resultado_Inspecao.RIP_Item,
					  (SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = ANA_Area) As Emissor, (SELECT STO_Sigla FROM Situacao_Ponto WHERE STO_Codigo = ANA_Situacao_Resp) As Situacao, (SELECT STO_Descricao FROM Situacao_Ponto WHERE STO_Codigo = ANA_Situacao_Resp) As Situacao1
FROM                  Resultado_Inspecao INNER JOIN Recomendacao ON Resultado_Inspecao.RIP_Unidade = Recomendacao.Rec_Unidade AND
                      Resultado_Inspecao.RIP_NumInspecao = Recomendacao.Rec_Inspecao AND Resultado_Inspecao.RIP_NumItem = Recomendacao.Rec_NumItem INNER JOIN
                      Analise ON Recomendacao.Rec_Unidade = Analise.ANA_Unidade AND Recomendacao.Rec_Inspecao = Analise.ANA_NumInspecao AND
                      Recomendacao.Rec_NumItem = Analise.ANA_NumItem AND Recomendacao.Rec_NumItemRecom = Analise.ANA_NumItemRecom INNER JOIN
                      Situacao_Ponto ON Analise.ANA_Situacao_Resp = Situacao_Ponto.STO_Codigo INNER JOIN
                      Areas ON Recomendacao.Rec_AreaFuncional = Areas.Ars_Codigo AND Recomendacao.Rec_AreaFuncional = Areas.Ars_Codigo
WHERE     (Analise.ANA_NumInspecao = '#qpesquisaPrincipal.INP_NumInspecao#') AND (Analise.ANA_unidade = '#qpesquisaPrincipal.INP_Unidade#') AND (Analise.ANA_NumItem = #qpesquisaPrincipal.RIP_NumItem#) AND (Analise.ANA_NumItemRecom = #qpesquisaPrincipal.REC_NumItemRecom#)
AND ((Analise.ANA_Analise IS NOT NULL) OR (Analise.ANA_Situacao_Resp <> 1))

UNION ALL
SELECT     Posicionamento.PSC_NumInspecao, Posicionamento.PSC_Unidade, Posicionamento.PSC_NumItem, Posicionamento.PSC_NumItemRecom,
                      Posicionamento.PSC_DtUltAtu, Posicionamento.PSC_Area, Posicionamento.PSC_Situacao_Resp, Posicionamento.PSC_DtPosic,
                      Posicionamento.PSC_Posicionamento, Posicionamento.PSC_UserName, Situacao_Ponto.STO_Sigla, Situacao_Ponto.STO_Descricao, Resultado_Inspecao.RIP_Item,
					  (SELECT Ars_Sigla FROM Areas WHERE Ars_Codigo = PSC_Area) As Emissor, (SELECT STO_Sigla FROM Situacao_Ponto WHERE STO_Codigo = PSC_Situacao_Resp) As Situacao, (SELECT STO_Descricao FROM Situacao_Ponto WHERE STO_Codigo = PSC_Situacao_Resp) As Situacao1
FROM         Resultado_Inspecao INNER JOIN
                      Recomendacao ON Resultado_Inspecao.RIP_Unidade = Recomendacao.Rec_Unidade AND
                      Resultado_Inspecao.RIP_NumInspecao = Recomendacao.Rec_Inspecao AND Resultado_Inspecao.RIP_NumItem = Recomendacao.Rec_NumItem INNER JOIN
                      Areas ON Recomendacao.Rec_AreaFuncional = Areas.Ars_Codigo AND Recomendacao.Rec_AreaFuncional = Areas.Ars_Codigo INNER JOIN
                      Posicionamento ON Recomendacao.Rec_Unidade = Posicionamento.PSC_Unidade AND Recomendacao.Rec_Inspecao = Posicionamento.PSC_NumInspecao AND
                      Recomendacao.Rec_NumItem = Posicionamento.PSC_NumItem AND Recomendacao.Rec_NumItemRecom = Posicionamento.PSC_NumItemRecom INNER JOIN
                      Situacao_Ponto ON Posicionamento.PSC_Situacao_Resp = Situacao_Ponto.STO_Codigo
WHERE  (Posicionamento.PSC_NumInspecao = '#qpesquisaPrincipal.INP_NumInspecao#') AND (Posicionamento.PSC_unidade = '#qpesquisaPrincipal.INP_Unidade#') AND (Posicionamento.PSC_NumItem = #qpesquisaPrincipal.RIP_NumItem#) AND (Posicionamento.PSC_NumItemRecom = #qpesquisaPrincipal.REC_NumItemRecom#)
AND (Posicionamento.PSC_Situacao_Resp = 9)
ORDER BY ANA_DtPosic, ANA_NumInspecao, RIP_item, Analise.ANA_NumItemRecom, Analise.ANA_DtUltAtu
</cfquery>

<cfdocumentsection>
<cfoutput>
<cfdocumentitem type="footer">
	     <table align="right" width="50%">
	       <tr><td align="right">Página #cfdocument.currentPageNumber# de #cfdocument.totalPageCount#</td></tr>
	     </table>
	      <table align="left" width="50%">
	         <tr><td align="left">#LSdateformat(now(),"dddd, dd mmmmm, yyyy")#<td></tr>
	      </table>
</cfdocumentitem>

<cfset Num_Auditoria = Left(qpesquisaPrincipal.INP_NumInspecao,2) & '.' & Mid(qpesquisaPrincipal.INP_NumInspecao,3,6) & '/' & Right(qpesquisaPrincipal.INP_NumInspecao,2)>

<table align="center" width="100%">
<tr>
  <th align="left">Auditor</th><th align="center">Processo</th><th align="center">Relatório</th><th align="center">Auditoria</th><th align="center">Item</th><th align="center">Recomendação</th><th align="center">Emissão</th><th align="center">Risco</th><th align="center">Gestor</th><th align="center">Corporativo</th><th align="center">Área</th><th align="center">Dias</th><th align="center">Status</th>
</tr>
<tr>
	<td align="left">#qpesquisaPrincipal.TAU_Sigla#</td><td align="center">#qpesquisaPrincipal.INP_NumProcesso#</td><td align="center">#qpesquisaPrincipal.INP_NumRelatorio#</td><td align="center">#Num_Auditoria#</td><td align="center">#qpesquisaPrincipal.RIP_Item#</td><td align="center">#qpesquisaPrincipal.REC_NumItemRecom#</td><td align="center">#DateFormat(qpesquisaPrincipal.INP_DtEmissao,'DD/MM/YYYY')#</td>
    <td align="center">#qpesquisaPrincipal.RSC_Sigla#</td><td align="center">#qpesquisaPrincipal.Gestor#</td><td align="center">#qpesquisaPrincipal.GestorCorporativo#</td><td align="center">#qpesquisaPrincipal.Atv_Sigla#</td><td align="center">#qpesquisaPrincipal.Quant#</td><td align="center">#qpesquisaPrincipal.Pos_Situacao#</td>
</tr>
</table>
<table align="center" width="100%">
<tr>
  <td colsapan="13" bordercolor="999999" align="left"><strong>Processo Auditado:</strong>&nbsp;#Trim(UND_Descricao)#</td>
</tr>
<tr>
 <td>&nbsp;</td>
</tr>
 <tr>
	<td colsapan="13" bordercolor="999999" align="left"><strong>Manchete:</strong>&nbsp;#Trim(RIP_Manchete)#</td>
 </tr>
<tr>
 <td colspan="13">&nbsp;</td>
</tr>
 <cfset Const = Replace(RIP_Comentario,"
","<BR>" ,"All")>

 <tr>
   <th colspan="13" bordercolor="999999" align="left">Constatação:</th>
 </tr>
 <tr>
  <td colspan="13">&nbsp;</td>
 </tr>
 <tr>
   <td bordercolor="999999" colspan="13"><div align="justify">#Trim(Const)#</div></td>
 </tr>
<tr>
 <td colspan="13">&nbsp;</td>
</tr>
 <cfset Manif = Replace(RIP_ManifestInicial,"
","<BR>" ,"All")>

 <tr>
   <th colspan="13" bordercolor="999999" align="left">Manifestação:</th>
 </tr>
 <tr>
  <td colspan="13">&nbsp;</td>
 </tr>
 <tr>
   <td bordercolor="999999" colspan="13"><div align="justify">#Trim(Manif)#</div></td>
 </tr>
<tr>
 <td colspan="13">&nbsp;</td>
</tr>
	<cfset recom = Replace(REC_Recomendacao,"
","<BR>" ,"All")>
         <cfset recom = Replace(recom,"-----------------------------------------------------------------------------------------------------------------------","<BR>-----------------------------------------------------------------------------------------------------------------------<BR>" ,"All")>
<tr>
  <th bordercolor="999999" colspan="13" align="left">Recomendação:</th>
</tr>
<tr>
 <td colspan="13">&nbsp;</td>
</tr>
<tr>
   <td bordercolor="999999" colspan="13"><div align="justify">#Trim(recom)#</div></td>
</tr>
<tr>
 <td colspan="13">&nbsp;</td>
</tr>
<tr>
  <td bordercolor="999999" colspan="13"><div align="left"><strong>Valor Envolvido:</strong>&nbsp;&nbsp;#LSCurrencyFormat(RIP_Valor,"local")#</div></td>
</tr>
<tr>
 <td colspan="13">&nbsp;</td>
</tr><br>
<tr>
 <td bordercolor="999999" colspan="13" align="left">ACOMPANHAMENTO:</td>
</tr>

<cfloop query="qpesquisa">

<cfif ANA_Situacao_Resp eq 9>
	 <cfset Posicionamento = Replace(ANA_Analise,"
   ","<BR>" ,"All")>
		 <cfset Posicionamento = Replace(Posicionamento,"Responsável:","<BR><BR>Responsável:" ,"All")>
		 <cfset Posicionamento = Replace(Posicionamento,"-----------------------------------------------------------------------------------------------------------------------","<BR><BR>-----------------------------------------------------------------------------------------------------------------------<BR>" ,"All")>
       <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
	   <tr>
        <td bordercolor="999999"><div align="left" colspan="13"><strong>Manifestação do gestor:<strong></div></td>
	  </tr>
	  <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
	  <tr>
        <td bordercolor="999999" colspan="13"><div align="justify">#Trim(Posicionamento)#</div></td>
      </tr>
	  <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
	  <tr>
        <td bordercolor="999999" colspan="13"><div align="left"><strong>Emissor:</strong>&nbsp;#Trim(emissor)#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Data:</strong>&nbsp;#DateFormat(ANA_DtPosic,'DD/MM/YYYY')#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Situação:</strong>&nbsp;#Trim(Situacao1)#</div></td>
	  </tr>
	  <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
</cfif>

<cfif ANA_Situacao_Resp neq 9>
 <cfset Analise = Replace(ANA_Analise,"
   ","<BR>" ,"All")>
		 <cfset Analise = Replace(Analise,"Responsável:","<BR><BR>Responsável:" ,"All")>
		 <cfset Analise = Replace(Analise,"-----------------------------------------------------------------------------------------------------------------------","<BR><BR>-----------------------------------------------------------------------------------------------------------------------<BR>" ,"All")>
  	  <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
	  <tr>
        <td bordercolor="999999"><div align="left" colspan="13"><strong>Opinião da auditoria:</strong></div></td>
	  </tr>
	  <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
	  <tr>
       <td bordercolor="999999" colspan="13"><div align="justify">#Trim(Analise)#</div></td>
      </tr>
	  <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
	   <tr>
        <td bordercolor="999999" colspan="13"><div align="left"><strong>Analisado:</strong>&nbsp;#ANA_UserName#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Data:</strong>&nbsp;#DateFormat(ANA_DtPosic,'DD/MM/YYYY')#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Situação:</strong>&nbsp;#Trim(Situacao1)#</div></td>
	   </tr>
	  <tr>
        <td colspan="13">&nbsp;</td>
      </tr>
</cfif>
</table>
</cfloop>
</cfoutput>
</cfdocumentsection>
</cfloop>
</cfdocument>

<cfcatch type="any">
	 <cflocation url="mensagem_relatorio_acompanhamento.cfm">
	  <cfdump var="#cfcatch#">
	<cfabort>
</cfcatch>
</cftry>
<cfset vArquivo = '\\sac0424\sistemas\followup\sarin_anexos\Relatorio_palavra_chave.pdf'>
<cffile action="readbinary" file="#vArquivo#" variable="estat">
<cfcontent variable="#estat#" type="application/pdf" reset="yes">
</body>
</html>