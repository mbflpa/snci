<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = form.dtinic>
<cfset dtFinal = form.dtfinal>
<cfset dtInicio = createdate(right(dtInicio,4), mid(dtInicio,4,2), left(dtInicio,2))>
<cfset dtFinal = createdate(right(dtFinal,4), mid(dtFinal,4,2), left(dtFinal,2))> 

<cfquery name="qitensreop" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS ItensReop, Rep_Nome
FROM Reops INNER JOIN ParecerUnidade INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao AND Pos_Unidade = INP_Unidade INNER JOIN Unidades ON Pos_Unidade = Und_Codigo ON Rep_Codigo = Und_CodReop
WHERE Pos_Situacao_Resp='4' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
GROUP BY Rep_Nome
ORDER BY Count(Pos_Inspecao) DESC
</cfquery>

<cfquery name="qtotalitensreop" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS TotalItensReop
FROM ParecerUnidade INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao
WHERE Pos_Situacao_Resp='4' AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
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
    <td colspan="14">&nbsp;</td>
  <tr class="titulos">
    <td colspan="14"><div align="center"><span class="titulo1"><strong>Pontos PENDENTES - &Oacute;RG&Atilde;O SUBORDINADOR </strong></span></div></td>
  <tr class="titulos">
    <td colspan="14">&nbsp;</td>
  <tr class="titulos">
    <td colspan="14">&nbsp;</td>
  <tr class="titulos">
    <td colspan="14"><div align="center" class="titulo1"></div></td>
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
    <td width="60%" bgcolor="eeeeee"><div align="center"><span class="style2">ÓRGÃO SUBORDINADOR</span></div></td>
    <td width="16%" bgcolor="eeeeee"><div align="center" class="style2">QUANTIDADE</div></td>
    <td width="18%" bgcolor="eeeeee" class="style1"><div align="center" class="style2">%</div></td>
  </tr>
  <cfoutput query="qitensreop">
  <tr class="exibir">
    <td bgcolor="f7f7f7"><div align="center"><span class="style1">#Rep_Nome#</span></div></td>
    <td bgcolor="f7f7f7"><div align="center"><span class="style1">#ItensReop#</span></div></td>
    <td bgcolor="f7f7f7"><div align="center" class="style1">#NumberFormat(val((qitensreop.ItensReop*100)/(qtotalitensreop.TotalItensReop)),999.00)#%</div></td>
  </tr>
  </cfoutput>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee" class="style1">Total de pontos pendentes </td>
    <td colspan="2" bgcolor="eeeeee"><div align="center"><span class="style1"><cfoutput>#qtotalitensreop.TotalItensReop#</cfoutput></span></div></td>
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
