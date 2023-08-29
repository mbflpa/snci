<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<br><br>
<cfset dtInicio = dtInic>
<cfset dtFinal = dtFim>
<cfset dtInicio = CreateDate(Right(dtInic,4), Mid(dtInic,4,2), Left(dtInic,2))>
<cfset dtFinal = CreateDate(Right(dtFim,4), Mid(dtFim,4,2), Left(dtFim,2))>

<cfquery name="qFuncionarios" datasource="#dsn_inspecao#">
SELECT Fun_Matric, Fun_Nome
FROM Funcionarios
WHERE Fun_Matric=#Inspetor#
ORDER BY Fun_Nome
</cfquery>


<cfquery name="qInspecao_inspetor" datasource="#dsn_inspecao#">
SELECT Count(INP_NumInspecao) AS QuantInspecao
FROM (Inspecao INNER JOIN Inspetor_Inspecao ON (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade) AND (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao)) INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE (IPT_MatricInspetor=#Inspetor#) AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>

<cfquery name="qTotal_Inspecao" datasource="#dsn_inspecao#">
SELECT Count(INP_NumInspecao) AS TotalQuantInspecao
FROM Inspecao
WHERE (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>

<cfquery name="qItens_inspetor" datasource="#dsn_inspecao#">
SELECT Count(Pos_NumItem) AS QuantItens
FROM ((Inspecao INNER JOIN Inspetor_Inspecao ON (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)) INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric) INNER JOIN ParecerUnidade ON (Inspecao.INP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Inspecao.INP_Unidade = ParecerUnidade.Pos_Unidade)
WHERE (IPT_MatricInspetor=#Inspetor#) AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>

<cfquery name="qTotal_Itens" datasource="#dsn_inspecao#">
SELECT Count(Pos_Inspecao) AS TotalQuantItens
FROM ParecerUnidade INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao
WHERE INP_DtFimInspecao Between #dtInicio# And #dtFinal#
</cfquery>


<cfquery name="qPrazo_dez_dias_zero" datasource="#dsn_inspecao#">
SELECT A.IPT_MatricInspetor, A.Data1, B.Data2, A.INP_DtFimInspecao
FROM (SELECT IPT_MatricInspetor, MIN(And_DtPosic) AS Data1, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao
FROM (Inspecao INNER JOIN Inspetor_Inspecao ON (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)) INNER JOIN Andamento ON (Inspetor_Inspecao.IPT_NumInspecao =Andamento.And_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Andamento.And_Unidade)
WHERE And_Situacao_Resp = '0'
GROUP BY IPT_MatricInspetor, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao) AS A INNER JOIN (SELECT IPT_MatricInspetor, MIN(And_DtPosic) AS Data2, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao
FROM (Inspecao INNER JOIN Inspetor_Inspecao ON (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)) INNER JOIN Andamento ON (Inspetor_Inspecao.IPT_NumInspecao =Andamento.And_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Andamento.And_Unidade)
WHERE And_Situacao_Resp = '1'
GROUP BY IPT_MatricInspetor, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao) AS B ON (A.INP_DtFimInspecao = B.INP_DtFimInspecao) AND (A.And_Unidade = B.And_Unidade) AND (A.And_NumItem = B.And_NumItem) AND (A.And_NumGrupo = B.And_NumGrupo) AND (A.IPT_NumInspecao = B.IPT_NumInspecao) AND (A.IPT_MatricInspetor = B.IPT_MatricInspetor)
WHERE (((A.IPT_MatricInspetor)=#Inspetor#) AND ((A.INP_DtFimInspecao) Between #dtInicio# And #dtFinal#))
</cfquery>

<cfquery name="qTotalPrazo_dez_dias_zero" datasource="#dsn_inspecao#">
SELECT A.IPT_MatricInspetor, A.Data1, B.Data2, A.INP_DtFimInspecao
FROM (SELECT IPT_MatricInspetor, MIN(And_DtPosic) AS Data1, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao
FROM (Inspecao INNER JOIN Inspetor_Inspecao ON (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)) INNER JOIN Andamento ON (Inspetor_Inspecao.IPT_NumInspecao =Andamento.And_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Andamento.And_Unidade)
WHERE And_Situacao_Resp = '0'
GROUP BY IPT_MatricInspetor, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao) AS A INNER JOIN (SELECT IPT_MatricInspetor, MIN(And_DtPosic) AS Data2, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao
FROM (Inspecao INNER JOIN Inspetor_Inspecao ON (Inspecao.INP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Inspecao.INP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)) INNER JOIN Andamento ON (Inspetor_Inspecao.IPT_NumInspecao =Andamento.And_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Andamento.And_Unidade)
WHERE And_Situacao_Resp = '1'
GROUP BY IPT_MatricInspetor, IPT_NumInspecao, And_NumGrupo, And_NumItem, And_Unidade, INP_DtFimInspecao) AS B ON (A.IPT_MatricInspetor=B.IPT_MatricInspetor) AND (A.IPT_NumInspecao=B.IPT_NumInspecao) AND (A.And_NumGrupo=B.And_NumGrupo) AND (A.And_NumItem=B.And_NumItem) AND (A.And_Unidade=B.And_Unidade) AND (A.INP_DtFimInspecao=B.INP_DtFimInspecao)
WHERE (A.INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>


<cfquery name="qPesquisa_inspetor" datasource="#dsn_inspecao#">
SELECT Count(Pes_NumInspecao) AS QuantPesquisa
FROM (Inspetor_Inspecao INNER JOIN Pesquisa ON Inspetor_Inspecao.IPT_NumInspecao = Pesquisa.Pes_NumInspecao) INNER JOIN Inspecao ON (Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade) AND (Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao)
WHERE (IPT_MatricInspetor=#Inspetor#) AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>

<cfquery name="qtotalpesquisa_retorno" datasource="#dsn_inspecao#">
SELECT Count(Pes_NumInspecao) AS TotalPesquisa
FROM Pesquisa INNER JOIN Inspecao ON Pesquisa.Pes_NumInspecao = Inspecao.INP_NumInspecao
WHERE (Inspecao.INP_DtFimInspecao) Between #dtInicio# And #dtFinal#
</cfquery>

<cfquery name="qMedia_Pesquisa" datasource="#dsn_inspecao#">
SELECT Avg((Pes_Comoestamos1 + Pes_Comoestamos2 + Pes_Comoestamos3 + Pes_Comoestamos4 + Pes_Comoestamos5 + Pes_Comoestamos6 + Pes_Comoestamos7)/7) AS Media_Total
FROM (Inspetor_Inspecao INNER JOIN Pesquisa ON Inspetor_Inspecao.IPT_NumInspecao = Pesquisa.Pes_NumInspecao) INNER JOIN Inspecao ON (Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade)
WHERE (IPT_MatricInspetor=#Inspetor#) AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>

<cfquery name="Rsmedia" datasource="#dsn_inspecao#">
SELECT AVG(Pes_Comoestamos1) AS media8, AVG(Pes_Comoestamos2) AS media9, AVG(Pes_Comoestamos3) AS media10, AVG(Pes_Comoestamos4) AS media11, AVG(Pes_Comoestamos5) AS media12, AVG(Pes_Comoestamos6) AS media13, AVG(Pes_Comoestamos7) AS media14, (AVG(Pes_Comoestamos1) + AVG(Pes_Comoestamos2) + AVG(Pes_Comoestamos3) + AVG(Pes_Comoestamos4) + AVG(Pes_Comoestamos5) + AVG(Pes_Comoestamos6) + AVG(Pes_Comoestamos7)) / 7 AS Soma
FROM Pesquisa INNER JOIN Inspecao ON Pes_NumInspecao = INP_NumInspecao
WHERE INP_DtFimInspecao between #dtInicio# And #dtFinal#
</cfquery>


<cfquery name="qMedia_Transmissao" datasource="#dsn_inspecao#">
SELECT Avg(DateDiff(dd, INP_DtFimInspecao, INP_DtEncerramento)) AS Dias
FROM (Inspetor_Inspecao INNER JOIN Inspecao ON (Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade)) INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE (IPT_MatricInspetor=#Inspetor#) AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>

<cfquery name="qMediaTotal_Transmissao" datasource="#dsn_inspecao#">
SELECT Avg(DateDiff(dd, INP_DtFimInspecao, INP_DtEncerramento)) AS TotalDias
FROM (Inspetor_Inspecao INNER JOIN Inspecao ON (Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade)) INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
WHERE (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>



<cfquery name="qItens_analisados" datasource="#dsn_inspecao#">
SELECT And_username, Count(And_NumInspecao) AS ItensAnalisados
FROM (Usuarios INNER JOIN Andamento ON Usuarios.Usu_Login = Andamento.And_username) INNER JOIN Inspecao ON (Andamento.And_Unidade = Inspecao.INP_Unidade) AND (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao)
WHERE (Usuarios.Usu_Matricula)=#Inspetor# AND (Andamento.And_Situacao_Resp)<>'0' And ((Andamento.And_Situacao_Resp)<>'1' And (Andamento.And_Situacao_Resp)<>'6' And (Andamento.And_Situacao_Resp)<>'7') AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
GROUP BY And_username
</cfquery>

<cfquery name="qTotalItens_Analisados" datasource="#dsn_inspecao#">
SELECT Count(And_NumInspecao) AS TotalItensAnalisados
FROM Andamento INNER JOIN Inspecao ON (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao) AND (Andamento.And_Unidade = Inspecao.INP_Unidade)
WHERE ((Andamento.And_Situacao_Resp)<>'0' And (Andamento.And_Situacao_Resp)<>'1' And (Andamento.And_Situacao_Resp)<>'6' And (Andamento.And_Situacao_Resp)<>'7') AND ((Inspecao.INP_DtFimInspecao) Between #dtInicio# And #dtFinal#)
</cfquery>

<cfquery name="qMelhoria" datasource="#dsn_inspecao#">
SELECT Count(RIP_NumItem) AS ItensMelhoria
FROM Resultado_Inspecao INNER JOIN (Inspetor_Inspecao INNER JOIN Inspecao ON (Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade)) ON (Resultado_Inspecao.RIP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Resultado_Inspecao.RIP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)
WHERE (IPT_MatricInspetor=#Inspetor#) AND RIP_Melhoria='1' AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)

</cfquery>

<cfquery name="qTotalMelhoria" datasource="#dsn_inspecao#">
SELECT  Count(DISTINCT RIP_NumItem) AS TotalItensMelhoria
FROM Resultado_Inspecao INNER JOIN (Inspetor_Inspecao INNER JOIN Inspecao ON (Inspetor_Inspecao.IPT_NumInspecao = Inspecao.INP_NumInspecao) AND (Inspetor_Inspecao.IPT_CodUnidade = Inspecao.INP_Unidade)) ON (Resultado_Inspecao.RIP_NumInspecao = Inspetor_Inspecao.IPT_NumInspecao) AND (Resultado_Inspecao.RIP_Unidade = Inspetor_Inspecao.IPT_CodUnidade)
WHERE RIP_Melhoria='1' AND (INP_DtFimInspecao Between #dtInicio# And #dtFinal#)
</cfquery>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="javascript">
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	if ((tecla < 48) || (tecla > 57)) {
	//  if () {
		event.returnValue = false;
	 // }
	}
}
}
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
			data.value += "/";
			break;
		case 5:
			data.value += "/";
			break;
	}
}
</script>

<cfset conta = 0>
<cfset conta1 = 0>
<cfset data1 = DateFormat(qPrazo_dez_dias_zero.Data1,"dd/mm/yyyy")>
<cfset data2 = DateFormat(qPrazo_dez_dias_zero.Data2,"dd/mm/yyyy")>

<cfloop query="qPrazo_dez_dias_zero">
 <cfif Data2 gt data1 + 10>    
    <cfset conta = conta + 1>	
 <cfelse>   
 </cfif> 
</cfloop>

<cfloop query="qTotalPrazo_dez_dias_zero">
 <cfif Data2 gt data1 + 10>  
    <cfset conta1 = conta1 + 1>	
 <cfelse>   
 </cfif> 
</cfloop>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="css.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {font-size: 12px}
.style2 {font-size: 12px; font-weight: bold; }
.style4 {color: #053C7E}
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">

<table width="80%" border="0" align="center">
  <tr class="titulos">
    <td colspan="10">&nbsp;</td>
  <tr class="titulos">
    <td colspan="10"><div align="center"><span class="titulo1"><strong>Relat&Oacute;rio estat&Iacute;stico por Inspetor</strong></span></div></td>
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
  <tr class="titulos"> 
      <td  colspan="4" bgcolor="eeeeee"><div align="center" class="style1"><span class="style1">Per&iacute;odo</span>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput>#DateFormat(dtInicio, "dd/mm/yyyy")#&nbsp;&nbsp;&nbsp;a&nbsp;&nbsp;&nbsp;<span class="style1">#DateFormat(dtFinal,"dd/mm/yyyy")#</cfoutput></span> </div></td>
   </tr>
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>  
  <tr class="titulos">
    <td height="19" colspan="2" bgcolor="eeeeee"><span class="style1">Nome:&nbsp;<cfoutput>#qFuncionarios.Fun_Nome#</cfoutput></span></td>
    <td height="19" bgcolor="eeeeee"><span class="style1">Matr&iacute;cula:&nbsp;<cfoutput>#qFuncionarios.Fun_Matric#</cfoutput></span></td>
  </tr>
  <tr class="titulos">
    <td height="19" colspan="3" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td height="19" bgcolor="eeeeee"><div align="center"></div>      <div align="center" class="style2"></div>      <div align="center" class="style2"></div></td>
    <td height="19" bgcolor="eeeeee"><div align="center"><span class="style1">Por Inspetor </span></div></td>
    <td height="19" bgcolor="eeeeee"><div align="center"><span class="style1">Total</span></div></td>
  </tr>  
  <tr class="exibir">
    <td width="42%" bgcolor="f7f7f7"><div align="left"><span class="style1">Quantidade de inspe&ccedil;&otilde;es </span></div></td>
    <td width="27%" bgcolor="f7f7f7"><div align="center"><cfoutput>#qInspecao_Inspetor.QuantInspecao#</cfoutput></div></td>
    <td width="31%" bgcolor="f7f7f7"><div align="center"><cfoutput>#qTotal_Inspecao.TotalQuantInspecao#</cfoutput></div></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="f7f7f7"><span class="style1">Quantidade de itens produzidos</span></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qItens_Inspetor.QuantItens#</cfoutput> </div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qTotal_Itens.TotalQuantItens#</cfoutput> </div></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="f7f7f7"><span class="style1">Quantidade de itens analisados</span></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qItens_analisados.ItensAnalisados#</cfoutput></div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qTotalItens_Analisados.TotalItensAnalisados#</cfoutput></div></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="f7f7f7"><span class="style1">Quantidade de pesquisas retornadas</span></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qpesquisa_inspetor.QuantPesquisa#</cfoutput></div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qtotalpesquisa_retorno.TotalPesquisa#</cfoutput></div></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="f7f7f7"><span class="style1">Quantidade de itens que ultrapassaram 10 dias </span></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#conta#</cfoutput></div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#conta1#</cfoutput></div></td>
  </tr>
  <tr class="exibir">   
    <td bgcolor="f7f7f7"><div align="left" class="style1"><a href="estatistica_inspetores_detalhe.cfm?Data1=<cfoutput>#dtInicio#&Data2=#dtFinal#&mat=#Inspetor#"></cfoutput><span class="style1 style4">Quantidade de itens Oportunidade de Melhoria</span></a></div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qMelhoria.ItensMelhoria#</cfoutput></div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#qTotalMelhoria.TotalItensMelhoria#</cfoutput></div></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee">&nbsp;</td>
    <td bgcolor="eeeeee">&nbsp;</td>
    <td bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td bgcolor="f7f7f7"><span class="style1">M&eacute;dia das pesquisas</span></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#LSNumberFormat(qMedia_pesquisa.Media_Total,"__.__")#</cfoutput>%</div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#LSNumberFormat(RSMedia.Soma,"__.__")#</cfoutput>%</div></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="f7f7f7"><div align="left"><span class="style1">M&eacute;dia do tempo de Incorpora&ccedil;&atilde;o</span></div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#LSNumberFormat(qMedia_Transmissao.Dias)#&nbsp;dia(s</cfoutput>)</div></td>
    <td bgcolor="f7f7f7"><div align="center"><cfoutput>#LSNumberFormat(qMediaTotal_Transmissao.TotalDias)#&nbsp;dia(s)</cfoutput></div></td>
  </tr>
 
  <tr class="titulos">
    <td colspan="4" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td colspan="3" bgcolor="eeeeee" class="style1">&nbsp;<div align="center"></div></td>
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
