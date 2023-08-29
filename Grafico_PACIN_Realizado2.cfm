<cfinclude template="cabecalho.cfm">
   <cfquery name="rsPlanRealiz" datasource="#dsn_inspecao#">
   SELECT Plan_DTPrevVerif, Plan_DTInicio, Plan_DTFinal, Plan_CodUnid, Plan_TipoUnid, Plan_NomeUnid, INP_NumInspecao, INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_DtFimDeslocamento, INP_HrsDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao 
   FROM Planejamento INNER JOIN Inspecao ON Plan_CodUnid = INP_Unidade 
    <cfif #mes# is 'Todos'>
     WHERE (((Year([INP_DtFimInspecao]))=#ano#) AND ((Left([Plan_CodUnid],2))=#se#)) ORDER BY Plan_DTInicio, Plan_CodUnid, Plan_TipoUnid
	<cfelse>
	WHERE (((Year([INP_DtFimInspecao]))=#ano#) AND ((Left([Plan_CodUnid],2))=#se#)) and (Month(INP_DtFimInspecao) = #mes#)  ORDER BY Plan_DTInicio, Plan_CodUnid, Plan_TipoUnid
	</cfif>
	</cfquery>
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
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
  <script type="text/javascript">
    document.write("<table width='" + largura() + "' height='" + altura() + "' border='0'>");
  </script>
    <tr height="5%">
<!--- 	  <td align="center"><div id="menu" align="center"><cfinclude template="cabecalho.cfm"> --->
    </tr>
	<tr height="3%">
	  <!--- <td align="center" valign="top" class="titulo">Identifica&ccedil;&atilde;o no sistema</td> --->
	</tr>
<tr height="90%"><td valign="middle" align="center">&nbsp;</td>
</tr>
   <table width="85%" border="1" align="center">
  <tr>
    <td colspan="14" class="titulo2"><div align="center"><span class="titulo"> anal&iacute;tico  PLANEJAMENTO PACIN <cfoutput>#ano#</cfoutput> (Planejado / Executado na se/<cfoutput>#se#</cfoutput>) </span></div></td>
    </tr>
  <tr class="Tabela">
    <td colspan="6" bgcolor="#FFFF99" class="titulos"><div align="center">Planejado</div></td>
    <td colspan="7" bgcolor="#00EC00" class="titulos"><div align="center">Executado</div></td>
    </tr>
  <tr class="Tabela">
    <td rowspan="2"><p align="center">Unidade </p>
    </td>
    <td rowspan="2"><div align="center">Tipo</div></td>
    <td rowspan="2"><div align="center">Nome Unidade </div></td>
    <td rowspan="2"><div align="center">Pre_Verific</div></td>
    <td rowspan="2"><div align="center">In&iacute;cio</div></td>
    <td rowspan="2"><div align="center">Fim</div></td>
    <td rowspan="2"><div align="center">N&ordm; Relat&oacute;rio</div></td>
    <td colspan="2"><div align="center">Deslocamento</div></td>
    <td colspan="3"><div align="center">Inspe&ccedil;&atilde;o</div>      <div align="center"></div>      <div align="center"></div>      <div align="center"></div></td>
    <td><div align="center">Dias</div></td>
  </tr>
  <tr class="Tabela">
    <td><div align="center">In&iacute;cio</div></td>
    <td width="78"><div align="center">Final</div></td>
    <td><div align="center">In&iacute;cio</div></td>
    <td><div align="center">Final</div></td>
    <td width="55"><div align="center">Horas</div></td>
    <td><div align="center">Plan / Exec </div></td>
  </tr>
	<cfoutput query="rsPlanRealiz">
	 <cfset dtprevplan = dateformat(Plan_DTPrevVerif,"DD/MM/YYYY")>
	 <cfset dtiniplan = dateformat(Plan_DTInicio,"DD/MM/YYYY")>
	 <cfset dtfimplan = dateformat(Plan_DTFinal,"DD/MM/YYYY")>
	 <cfset dtinidesinp = dateformat(INP_DtInicDeslocamento,"DD/MM/YYYY")>
	 <cfset dtfimdesinp = dateformat(INP_DtFimDeslocamento,"DD/MM/YYYY")>
	 <cfset dtiniinp = dateformat(INP_DtInicInspecao,"DD/MM/YYYY")>
	 <cfset dtfiminp = dateformat(INP_DtFimInspecao,"DD/MM/YYYY")>
	 <cfset numRelat = INP_NumInspecao>
	 <cfset hrsinp = INP_HrsPreInspecao>
	 <cfset tpund = Plan_TipoUnid>	 
	 <cfset auxnumdias = DateDiff("d", Plan_DTFinal, INP_DtFimInspecao)>
  <tr class="exibir"> 
    <td width="89">#Plan_CodUnid#</td>
    <td width="44">#tpund#</td>
    <td width="208">#Plan_NomeUnid#</td>
    <td width="75"><div align="center">#dtprevplan#</div></td>
    <td width="64"><div align="center">#dtiniplan#</div></td>
    <td width="72" bgcolor="##FFFF99"><div align="center">#dtfimplan#</div></td>
    <td width="79"><div align="center">#numRelat#</div></td>
    <td width="73">#dtinidesinp#</td>
    <td>#dtfimdesinp#</td>
    <td width="65">#dtiniinp#</td>
    <td width="66" bgcolor="##00EC00">#dtfiminp#</td>
    <td><div align="center">#hrsinp#</div></td>
    <td width="81"><div align="center">#auxnumdias#</div></td>
  </tr>
	</cfoutput>
</table>
</body>
</html>