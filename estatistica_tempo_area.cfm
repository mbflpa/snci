
<cfset dtInicio = '01/01/2008'>
<cfset dtFinal = '31/12/2008'>
<cfset dtInicio = CreateDate(Right(dtInicio,4), Mid(dtInicio,4,2), Left(dtInicio,2))>
<cfset dtFinal = CreateDate(Right(dtFinal,4), Mid(dtFinal,4,2), Left(dtFinal,2))>


<cfquery name="qAgrupa"  datasource="#dsn_inspecao#">
SELECT Ars_Sigla, Count(And_NumInspecao) AS Itens
FROM Andamento INNER JOIN Areas ON Andamento.And_Orgao_Solucao = Areas.Ars_Codigo
WHERE And_DtPosic BETWEEN #dtInicio# And #dtFinal# AND And_Situacao_Resp='3'
GROUP BY Ars_Sigla
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
<table width="85%" height="50%" border="0" align="center">
  <br><br><br> 
  <tr class="titulos">
    <td bgcolor="eeeeee" colspan="24"><div align="center"><span class="titulo1"><strong>Quantitativo de pontos por atividade</strong></span></div></td>
  </tr>
  <tr class="titulos">
    <td bgcolor="eeeeee" colspan="24">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td bgcolor="eeeeee" colspan="24"><div align="center"><span class="Style1">&nbsp;PER&Iacute;ODO: &nbsp;&nbsp;&nbsp; <cfoutput>#lsdateformat(dtinicio,"dd/mm/yyyy")# a #lsdateformat(dtfinal,"dd/mm/yyyy")#</cfoutput></span></div></td>
  </tr>
  <tr>
    <td bgcolor="eeeeee" colspan="24">&nbsp;</td>
  </tr>
   

 <cfquery name="qSolucionados" datasource="#dsn_inspecao#">
     SELECT And_Situacao_Resp, And_NumInspecao, And_NumGrupo, And_DtPosic, And_NumItem
     FROM Andamento INNER JOIN Inspecao ON (Andamento.And_NumInspecao = Inspecao.INP_NumInspecao) AND (Andamento.And_Unidade = Inspecao.INP_Unidade)
     WHERE INP_DtFimInspecao BETWEEN #dtInicio# And #dtFinal#
     GROUP BY Andamento.And_Situacao_Resp, Andamento.And_NumInspecao, Andamento.And_NumGrupo, Andamento.And_DtPosic, Andamento.And_NumItem, Andamento.And_Situacao_Resp
     HAVING And_Situacao_Resp='3' Or And_Situacao_Resp='5' Or And_Situacao_Resp='6'
     ORDER BY And_NumInspecao, And_NumGrupo, And_NumItem, And_DtPosic, And_Situacao_Resp
 </cfquery>
 
 
 
 
 <cfloop query="qsolucionados">
     <cfif And_Situacao_Resp eq '3'>
	     <cfif And_Situacao_Resp eq '5'>		        
            <cfoutput>#And_Situacao_Resp#</cfoutput>
		 </cfif>
	 </cfif>  
 
 </cfloop>

  
  
 
	  

</body>
</html>
