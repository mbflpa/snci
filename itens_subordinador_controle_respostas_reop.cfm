<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<cfset dtInicio = form.DtInic>
<cfset dtFinal = form.DtFinal>
<cfset dtInicio = createdate(right(dtInicio,4), mid(dtInicio,4,2), left(dtInicio,2))>
<cfset dtFinal = createdate(right(dtFinal,4), mid(dtFinal,4,2), left(dtFinal,2))>

<!--- <cfquery name="rsItem" datasource="#dsn_inspecao#">
  SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao
  FROM Reops INNER JOIN Resultado_Inspecao INNER JOIN Unidades INNER JOIN ParecerUnidade INNER JOIN
  Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao ON
  Und_Codigo = Pos_Unidade ON RIP_Unidade = Pos_Unidade AND
  RIP_NumInspecao = INP_NumInspecao ON Rep_Codigo = RIP_CodReop
  WHERE  (Und_CodReop = '#form.reop#') AND (INP_DtFimInspecao BETWEEN #dtInicio# AND #dtFinal#)
  ORDER BY Und_Descricao, Pos_Inspecao
</cfquery> --->
<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT DISTINCT Und_Codigo, Pos_Unidade, Und_Descricao, INP_DtInicInspecao, Pos_Inspecao
FROM (Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) INNER JOIN ParecerUnidade ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)
GROUP BY Und_Codigo, Und_Descricao, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Und_CodReop
HAVING (INP_DtInicInspecao Between #dtInicio# AND #dtFinal#) and (Und_CodReop = '#form.reop#')
ORDER BY Und_Descricao, INP_DtInicInspecao
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style5 {font-size: 14; font-weight: bold; }
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style6 {color: #FF0000}
-->
</style>
<script type="text/javascript">
function troca(a,b){
 document.formx.nu_inspecao.value=a;
 document.formx.DtInic.value=b;
 document.formx.submit();
}
</script>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="99%" height="450" align="center">
<tr>
<td width="1202" valign="top">
<!--- Área de conteúdo   --->
<table width="79%" align="center" class="exibir">
  <tr>
    <td height="29" colspan="4">&nbsp;</td>
  </tr>
  <tr>
    <td height="29" colspan="4"><div align="center"><span class="titulo1"><strong>Pontos de Controle Interno Por Unidade</strong></span><br>
    </div></td>
  </tr>
  <tr>
    <td height="14" align="center" valign="top" colspan="7">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td height="18" bgcolor="eeeeee" class="titulos"><div align="center"><cfoutput>Unidade</cfoutput></div></td>
    <td width="311" height="18" bgcolor="eeeeee" class="titulos">Descri&ccedil;&atilde;o</td>
    <td width="154" bgcolor="eeeeee"><div align="center" class="titulos">In&iacute;cio do Relatório</div></td>
    <td width="123" bgcolor="eeeeee">&nbsp;</td>
  </tr>

 <cfset sctrl = " ">
 <cfset strcor = "eeeeee">
<cfoutput query="rsItem">
  <form name="frm">
 <cfset sctrl = rsItem.Pos_Unidade>
<tr bgcolor="#strcor#">

    	<td width="125" height="21" bgcolor="f7f7f7"><div align="center">#rsItem.Pos_Unidade#</div></td>

        <td width="311">#rsItem.Und_Descricao#
          <input name="nu_inspecao" type="hidden" id="nu_inspecao" value="#rsItem.Pos_Inspecao#">
          <input name="DtInic" type="hidden" id="DtInic" value="#LSDateFormat(rsItem.INP_DtInicInspecao,'MM/DD/YYYY')#"></td>
        <td><div align="center">#lsDateFormat(rsItem.INP_DtInicInspecao,'DD-MM-YYYY')#</div></td>
        <td><div align="center">
         <button name="submitAlt" type="button" class="exibir" onClick="troca(nu_inspecao.value,DtInic.value);">+Detalhes</button>
        </div></td>
</tr>
  </form>

<cfif strcor eq "eeeeee">
   <cfset strcor = "f7f7f7">
<cfelse>
  <cfset strcor = "eeeeee">
</cfif>
</cfoutput>
</table>

<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
<form name="formx"  method="post" action="itens_subordinador_controle_respostas.cfm">
  <input name="nu_inspecao" type="hidden" id="nu_inspecao">
  <input name="DtInic" type="hidden" id="DtInic">
</form>
<cfinclude template="rodape.cfm">
</body>
</html>