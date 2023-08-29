<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset total=0>

<cfset DataI = CreateDate(right(form.dtinic,4), mid(form.dtinic,4,2), left(form.dtinic,2))>
<cfset DataF = CreateDate(right(form.dtfinal,4), mid(form.dtfinal,4,2), left(form.dtfinal,2))>

<cfquery name="rsTipoC" datasource="#dsn_inspecao#">
SELECT     Inspecao.INP_DtInicInspecao, Resultado_Inspecao.RIP_NumInspecao, Inspecao.INP_Unidade, COUNT(Inspecao.INP_Unidade) AS TotalC, 
                      Unidades.Und_Descricao
FROM         Inspecao INNER JOIN
                      Unidades ON Inspecao.INP_Unidade = Unidades.Und_Codigo RIGHT OUTER JOIN
                      Resultado_Inspecao ON Inspecao.INP_Unidade = Resultado_Inspecao.RIP_Unidade AND 
                      Inspecao.INP_NumInspecao = Resultado_Inspecao.RIP_NumInspecao LEFT OUTER JOIN
                      ParecerUnidade ON Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade AND 
                      Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao AND 
                      Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo AND 
                      Resultado_Inspecao.RIP_NumItem = ParecerUnidade.Pos_NumItem
WHERE     (Inspecao.INP_DtInicInspecao BETWEEN #DataI# AND #DataF#) AND (Resultado_Inspecao.RIP_Resposta = 'C')  
GROUP BY Inspecao.INP_DtInicInspecao, Resultado_Inspecao.RIP_NumInspecao, Inspecao.INP_Unidade, Unidades.Und_Descricao
ORDER BY Unidades.Und_Descricao
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="css.css" rel="stylesheet" type="text/css">

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style8 {font-size: 12px; font-style: normal; color: #ffffff; text-decoration: underline; text-transform: uppercase; font-family: Verdana, Arial, Helvetica, sans-serif;}
a:link {
	color: #003399;
}
a:hover {
	color: #CC3300;
}
a:visited {
	color: #003399;
}
a:active {
	color: #003399;
}
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="800" height="450" align="center">
<tr>
<td valign="top">
<!--- Área de conteúdo   --->
<cfif rsTipoC.RecordCount GT 0>
  <table width="100%" cellspacing="1">
    <tr class="titulos">
      <td colspan="13"><p align="center" class="titulo1"><strong>Quantitativo de pontos por per&Iacute;odo </strong></p>        </td>
    </tr>
    <tr class="exibir">
      <td width="80" bgcolor="eeeeee"><div align="center">Dt. de In&iacute;cio </div></td>
      <td width="200" bgcolor="eeeeee"><div align="left">Unidade</div></td>
      <td width="80" bgcolor="eeeeee"><div align="center">Auditoria</div>      
        <div align="center"></div></td>
      <td colspan="2" bgcolor="eeeeee"> <div align="center"><strong>C</strong></div>        <div align="center"></div></td>
      <td colspan="3" bgcolor="eeeeee"> <div align="center"><strong>N</strong></div>        </td>
      <td colspan="2" bgcolor="eeeeee"><div align="center"><strong>V</strong></div>        <div align="center"></div></td>
      <td colspan="2" bgcolor="eeeeee"><div align="center"><strong>E</strong></div>        <div align="center"></div></td>
      <td width="40" bgcolor="eeeeee"><div align="center"><strong>Total</strong></div></td>
    </tr>
    <cfoutput query="rsTipoC">
      <cfset dtInic = rsTipoC.INP_DtInicInspecao>
      <cfset unid = rsTipoC.INP_Unidade>
      <cfquery name="rsTipoE" datasource="#dsn_inspecao#">
 SELECT count(*) as TotalE
      FROM Resultado_Inspecao
      WHERE Resultado_Inspecao.RIP_Unidade = '#unid#' and Resultado_Inspecao.RIP_Resposta = 'E' and Resultado_Inspecao.RIP_NumInspecao = '#rsTipoC.RIP_NumInspecao#' </cfquery>


      <cfquery name="rsTipoN" datasource="#dsn_inspecao#">
      SELECT     COUNT(*) AS TotalN
	  FROM         ParecerUnidade
      WHERE     (Pos_Unidade = '#unid#') AND (Pos_Inspecao = '#rsTipoC.RIP_NumInspecao#') 
	  </cfquery>

  <cfquery name="rsTipoV" datasource="#dsn_inspecao#">
   SELECT count(*) as TotalV
      FROM Resultado_Inspecao
      WHERE Resultado_Inspecao.RIP_Unidade = '#unid#' and Resultado_Inspecao.RIP_Resposta = 'V' and Resultado_Inspecao.RIP_NumInspecao = '#rsTipoC.RIP_NumInspecao#'
    </cfquery>

  <cfset TotC = rsTipoC.TotalC>
      <cfif TotC eq "">
        <cfset TotC =0>
      </cfif>

  <cfset TotN = rsTipoN.TotalN>
      <cfif TotN eq "">
        <cfset TotN =0>
      </cfif>

  <cfset TotE = rsTipoE.TotalE>
      <cfif TotE eq "">
        <cfset TotE =0>
      </cfif>

  <cfset TotV = rsTipoV.TotalV>
      <cfif TotV eq "">
        <cfset TotV =0>
      </cfif>

    <tr class="form">
        <td width="80"><div align="center">#DateFormat(rsTipoC.INP_DtInicInspecao,'DD-MM-YYYY')#</div></td>
        <td width="240"><div align="left">#rsTipoC.Und_Descricao#</div></td>
        <td width="80"><div align="center">#rsTipoC.RIP_NumInspecao#</div>        <div align="center"></div></td>
		 <cfset NF = val((TotC*100)/(TotC + TotN))>
		<cfif NF GTE 80>
		  <cfset corFundo = "eeeeee">
 		 <cfelse>
		  <cfset corFundo = "eeeeee">		
		</cfif>
        <td width="19"><div align="center">#TotC#</div></td>		
		<td width="19"><div align="right">#NumberFormat(val((TotC*100)/(TotC + TotN)),999.00)#%</div></td>		                                                                 
        <td width="19"><div align="center">#TotN#</div></td>
		<td width="9"><div align="right">#NumberFormat(val((TotN*100)/(TotC + TotN)),999.00)#%</div></td>		
        <td width="9"><div align="center"><a href="itens_verif_mensal_inspecao.cfm?Ninsp=#rsTipoC.RIP_NumInspecao#" class="titulos">Detalhe</a></div></td>  
	    <td width="19"><div align="center">#TotV#</div></td>
        <td width="19"><div align="right">#NumberFormat(val((TotV*100)/(TotC + TotN + TotV + TotE)),999.00)#%</div></td>
        <td width="19"><div align="center">#TotE#</div></td>
        <td width="19"><div align="right">#NumberFormat(val((TotE*100)/(TotE + TotC + TotN + TotV)),999.00)#%</div></td>
        <!--td width="40"><div align="center">#val(TotC + TotE + TotN + TotV)#</div></td-->
        <td width="40"><div align="center">#val(TotC + TotN + TotV + TotE)#</div></td>
      </tr>
    </cfoutput>
  </table>

  <table width="699">
    <tr>
      <td width="707" bgcolor="f7f7f7"><span class="exibir"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C</strong> - Conforme <strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N</strong> - N&atilde;o Conforme <strong> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;V</strong> - N&atilde;o Verificado<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;E</strong> - N&atilde;o Executou Tarefa </span></td>
    </tr>
  </table>
  <p><strong> </strong>
</cfif>
<div align="center" class="exibir">
  <div align="center">
    <cfif rsTipoC.RecordCount EQ 0>
      <strong class="exibir">Não existe informação para o período informado</strong>
  </cfif> </div>
</div>

<!--- Fim Área de conteúdo --->	  </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>