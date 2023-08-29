<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset dtInicio = form.dtinic>
<cfset dtFinal = form.dtfinal>
<cfset dtInicio = createdate(right(dtInicio,4), mid(dtInicio,4,2), left(dtInicio,2))>
<cfset dtFinal = createdate(right(dtFinal,4), mid(dtFinal,4,2), left(dtFinal,2))> 

<cfquery name="qpesquisa" datasource="#dsn_inspecao#">
SELECT Count(Pes_NumInspecao) AS Tipo, Pes_Tipo
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
GROUP BY Pes_Tipo
</cfquery>

<cfquery name="qtotalinspecao" datasource="#dsn_inspecao#">
SELECT Count(INP_NumInspecao) AS TotalInspecao
FROM Inspecao
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="qtotalpesquisa" datasource="#dsn_inspecao#">
SELECT Count(Pes_NumInspecao) AS TotalPesquisa
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="Rsmedia" datasource="#dsn_inspecao#">
SELECT AVG(Pes_Comoestamos1) AS media8, AVG(Pes_Comoestamos2) AS media9, AVG(Pes_Comoestamos3) AS media10, AVG(Pes_Comoestamos4) AS media11, AVG(Pes_Comoestamos5) AS media12, AVG(Pes_Comoestamos6) AS media13, AVG(Pes_Comoestamos7) AS media14, (AVG(Pes_Comoestamos1) + AVG(Pes_Comoestamos2) + AVG(Pes_Comoestamos3) + AVG(Pes_Comoestamos4) + AVG(Pes_Comoestamos5) + AVG(Pes_Comoestamos6) + AVG(Pes_Comoestamos7)) / 7 AS Soma
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="qfalta" datasource="#dsn_inspecao#">
SELECT INP_NumInspecao, Pes_NumInspecao, Und_Descricao FROM Inspecao LEFT JOIN Pesquisa ON INP_NumInspecao = Pes_NumInspecao INNER JOIN Unidades ON Und_Codigo = INP_Unidade  WHERE 
Pes_NumInspecao is Null AND INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="css.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {font-size: 12px}
.style2 {font-size: 12px; font-weight: bold; }
-->
</style>
<script type="text/javascript">
function troca(a,b,c){
 document.formx.txttipo.value=a;
 document.formx.dtinic.value=b;
 document.formx.dtfinal.value=c;
 document.formx.submit();
}
</script>
</head>
<body>
<cfinclude template="cabecalho.cfm">

<table width="80%" border="0" align="center">
  <tr class="titulos">
    <td colspan="14">&nbsp;</td>
  <tr class="titulos">
    <td colspan="14"><div align="center"><span class="titulo1"><strong>Relat&Oacute;rio estat&Iacute;stico das pesquisas </strong></span></div></td>
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
      <td  colspan="4" bgcolor="eeeeee"><div align="center" class="style1">Per&iacute;odo:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;a&nbsp;&nbsp;&nbsp;#DateFormat(dtFinal,"dd/mm/yyyy")# </div></td>
  </cfoutput> </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  
      <tr class="exibir">
        <td bgcolor="f7f7f7"><div align="center" class="style2">Motivo</div></td>
        <td bgcolor="f7f7f7"><div align="center" class="style2">Quantidade</div></td>
        <td bgcolor="f7f7f7"><div align="center" class="style2">%</div></td>
        <td bgcolor="f7f7f7">&nbsp;</td>
      </tr>
	<cfoutput query="qpesquisa">
     <form name="frm">
      <tr class="exibir">
        <td width="60%" bgcolor="f7f7f7"><div align="center" class="style1">
            <cfswitch expression= "#qpesquisa.Pes_Tipo#">
              <cfcase value= "0">
              Falta Análise
              </cfcase>
              <cfcase value="cri">
              Críticas
              </cfcase>
              <cfcase value="elo">
              Elogios
              </cfcase>
              <cfcase value="sug">
              Sugestões
              </cfcase>
              <cfcase value="out">
              Outros
              </cfcase>
            </cfswitch>
        </div></td>
        <td width="16%" bgcolor="f7f7f7"><div align="center" class="style1">#qpesquisa.Tipo#
                <input name="txttipo" type="hidden" id="txttipo" value="#qpesquisa.Pes_Tipo#">
                <input name="dtinic" type="hidden" id="dtinic" value="#form.dtinic#">
                <input name="dtfinal" type="hidden" id="dtfinal" value="#form.dtfinal#">
        </div></td>
        <td width="30%" bgcolor="f7f7f7"><div align="center"><span class="style1">#NumberFormat(val((qpesquisa.Tipo*100)/(qtotalpesquisa.totalpesquisa)),999.00)#</span>%</div></td>
        <td width="18%" bgcolor="f7f7f7"><button name="submitAlt" type="button" class="exibir" onClick="troca(txttipo.value,dtinic.value, dtfinal.value);">+Detalhes</button></td>
      </tr>
    </form>
  </cfoutput>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee"><cfoutput>
        <div align="left" class="style1">Total de inspeções </div>
    </cfoutput></td>
    <td colspan="3" bgcolor="eeeeee"><div align="center"><cfoutput>
          <div align="center" class="style1"></div>
    </cfoutput><cfoutput><span class="style1">#qtotalinspecao.totalinspecao#</span></cfoutput></div></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee" class="style1">Total de pesquisas</td>
    <td colspan="3" bgcolor="eeeeee"><cfoutput>
        <div align="center"><span class="style1">#qtotalpesquisa.totalpesquisa#</span></div>
    </cfoutput></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee" class="style1">&Iacute;ndice de retorno das pesquisas</td>
    <td colspan="3" bgcolor="eeeeee" class="style1"><cfoutput>
        <div align="center">#NumberFormat(val((qtotalpesquisa.totalpesquisa*100)/(qtotalinspecao.totalinspecao)),999.00)#%</div>
    </cfoutput> 
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee" class="style1"><cfoutput>&Iacute;ndice de satisfa&ccedil;&atilde;o(M&eacute;dia) </cfoutput></td>
    <td colspan="3" bgcolor="eeeeee" class="style1"><cfoutput>
        <div align="center">#NumberFormat(Rsmedia.Soma,99.00)#</div>
        <div align="center"></div>
    </cfoutput></td>
  </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td colspan="4" class="titulo1">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;
        <div align="center"><span class="titulo1"></span></div></td>
  </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee"><div align="center"><span class="titulo1"><strong>pesquisas n&Atilde;o Enviadas no Per&Iacute;odo de refer&Ecirc;ncia </strong></span></div></td>
  </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td colspan="2" bgcolor="eeeeee"><span class="style1"><strong>Nome da Unidade</strong></span></td>
    <td colspan="2" bgcolor="eeeeee"><span class="style1"><strong>N&ordm; da Inspe&ccedil;&atilde;o</strong></span><span class="style1"></span></td>
  </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <cfoutput query="qfalta">
    <tr class="exibir">
      <td  width="60%" colspan="2" bgcolor="f7f7f7"><div align="center" class="style1">
        <div align="left">#qfalta.UND_Descricao#</div>
      </div></td>
      <td  width="30%" colspan="2" bgcolor="f7f7f7"><div align="center" class="style1">#qfalta.INP_NumInspecao#</div></td>
    </tr>
  </cfoutput>
</table>
<form name="formx"  method="post" action="estatistica_pesquisa1.cfm">
  <input name="txttipo" type="hidden" id="txttipo">
  <input name="dtinic" type="hidden" id="#form.dtinic#">
  <input name="dtfinal" type="hidden" id="#form.dtfinal#">
</form>
<cfinclude template="rodape.cfm">
<div align="center"></div>
</body>
</html>
