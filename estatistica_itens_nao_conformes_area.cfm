<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = form.dtinic>
<cfset dtFinal = form.dtfinal>
<cfset dtInicio = createdate(right(dtInicio,4), mid(dtInicio,4,2), left(dtInicio,2))>
<cfset dtFinal = createdate(right(dtFinal,4), mid(dtFinal,4,2), left(dtFinal,2))> 

<cfquery name="qitensarea" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS ItensArea, Ars_Sigla
FROM ParecerUnidade INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao INNER JOIN Areas ON Pos_Area = Ars_Codigo
WHERE Pos_Situacao_Resp='5' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
GROUP BY Ars_Sigla
ORDER BY Count(Pos_Inspecao) DESC
</cfquery>

<cfquery name="qtotalitensarea" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS TotalItensArea
FROM ParecerUnidade INNER JOIN Inspecao ON  Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao INNER JOIN Areas ON Pos_Area = Ars_Codigo
WHERE Pos_Situacao_Resp='5' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
ORDER BY Count(Pos_Inspecao)
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="css.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {font-size: 12px}
.style2 {font-size: 12px; font-weight: bold; }
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">

<table width="80%" border="0" align="center">
  <tr class="titulos">
    <td colspan="10">&nbsp;</td>
  <tr class="titulos">
    <td colspan="10"><div align="center"><span class="titulo1"><strong>Pontos PENDENTES - &Aacute;REAs</strong></span></div></td>
  <tr class="titulos">
    <td colspan="10">&nbsp;</td>
  <tr class="titulos">
    <td colspan="10">&nbsp;</td>
  <tr class="titulos">
    <td colspan="10"><div align="center" class="titulo1"></div></td>
    <br>
    <br>
    <br>
  <tr class="exibir">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos"> <cfoutput>
      <td  colspan="4" bgcolor="eeeeee"><div align="center" class="style1"><span class="style1">Per&iacute;odo</span>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;a&nbsp;&nbsp;&nbsp;<span class="style1">#DateFormat(dtFinal,"dd/mm/yyyy")#</span> </div></td>
  </cfoutput> </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>  
  <tr class="titulos">
    <td width="60%" bgcolor="eeeeee"><div align="center">&Aacute;REAS</div></td>
    <td width="16%" bgcolor="eeeeee"><div align="center" class="style2">QUANTIDADE</div></td>
    <td width="18%" bgcolor="eeeeee" class="style1"><div align="center" class="style2">%</div></td>
  </tr>
  <cfoutput query="qitensarea">
  <tr class="exibir">
    <td bgcolor="f7f7f7"><div align="center"><span class="style1">#Ars_Sigla#</span></div></td>
    <td bgcolor="f7f7f7"><div align="center"><span class="style1">#ItensArea#</span></div></td>
    <td bgcolor="f7f7f7"><div align="center" class="style1">#NumberFormat(val((qitensarea.ItensArea*100)/(qtotalitensarea.TotalItensArea)),999.00)#%</div></td>
  </tr>
  </cfoutput>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee" class="style1">Total de pontos pendentes </td>
    <td colspan="2" bgcolor="eeeeee"><div align="center"><span class="style1"><cfoutput>#qtotalitensarea.TotalItensArea#</cfoutput></span></div></td>
  </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;
        <div align="center"></div></td>
  </tr>  
</table>
<cfinclude template="rodape.cfm">
<div align="center"></div>
</body>
</html>
