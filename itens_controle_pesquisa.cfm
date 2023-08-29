<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> --->

<cfset dtInicio = form.dtinic>
<cfset dtFinal = form.dtfinal>
<cfset dtInicio = createdate(right(dtInicio,4), mid(dtInicio,4,2), left(dtInicio,2))>
<cfset dtFinal = createdate(right(dtFinal,4), mid(dtFinal,4,2), left(dtFinal,2))> 

<cfquery name="rsPesquisa" datasource="#dsn_inspecao#">
SELECT Pes_NumInspecao, Pes_Lotacao, Pes_Tipo, INP_DtFimInspecao
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE Pes_Tipo='0' AND INP_DtFimInspecao BETWEEN #dtInicio# AND #dtFinal#
ORDER BY Pes_Lotacao, Pes_NumInspecao, INP_DtFimInspecao 
</cfquery>
 
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
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
.style1 {font-size: 12px}
-->
</style>
<script type="text/javascript">
function troca(a,b,c){
 document.formx.nu_inspecao.value=a;
 document.formx.dtinic.value=b;
 document.formx.dtfinal.value=c;
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
    <td height="29" colspan="4"><div align="center"><strong class="titulo1">An&Aacute;lise das pesquisas </strong><br>
          <br>    
    </div></td>
  </tr>
  <tr>
    <td height="25" bgcolor="eeeeee" class="titulos"  align="center" colspan="8"><cfoutput><span class="style1">Per&iacute;odo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;a&nbsp;&nbsp;&nbsp;#DateFormat(dtFinal,"dd/mm/yyyy")#</span></cfoutput></td>
  </tr>
  <tr>
    <td height="25" bgcolor="eeeeee" class="titulos align="center" valign="top" colspan="8">
      <div align="center"><span class="style5"></span></div>    </td>
  </tr>
  <tr class="exibir">
    <td height="23" bgcolor="eeeeee" class="titulos"><div align="center"><cfoutput>Descri&ccedil;&atilde;o</cfoutput></div></td>
    <td width="311" height="16" bgcolor="eeeeee" class="titulos"><div align="center">N&ordm; Inspe&ccedil;&atilde;o </div></td>
    <td bgcolor="eeeeee"><div align="center" class="titulos">Dt.Envio</div></td>
    
    <td bgcolor="eeeeee">&nbsp;</td>
  </tr>

 
  <cfoutput query="rsPesquisa"> 
<form name="frm"> 
<tr bgcolor="f7f7f7">   	
         	
        <td width="40%">#rsPesquisa.Pes_Lotacao#
		  <input name="nu_inspecao" type="hidden" id="numero_inspecao" value="#rsPesquisa.Pes_NumInspecao#">
          <input name="dtinic" type="hidden" id="dtinic" value="#form.dtinic#">
          <input name="dtfinal" type="hidden" id="dtfinal" value="#form.dtfinal#"></td>
        <td><div align="center">#rsPesquisa.Pes_NumInspecao#</div></td>
        <td width="25%"><div align="center">#LSDateFormat(rsPesquisa.INP_DtFimInspecao,'DD-MM-YYYY')#</div></td>
        <td width="15%"><button name="submitAlt" type="button" class="exibir" onClick="troca(nu_inspecao.value,dtinic.value,dtfinal.value);">+Detalhes</button></td>
</tr>
</form>
  </cfoutput>
</table>

<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
<form name="formx"  method="post" action="consulta_inspecao.cfm">
  <input name="nu_inspecao" type="hidden" id="nu_inspecao">
  <input name="dtinic" type="hidden" id="#form.dtinic#">
  <input name="dtfinal" type="hidden" id="#form.dtfinal#">
</form>
<cfinclude template="rodape.cfm">
</body>
</html>