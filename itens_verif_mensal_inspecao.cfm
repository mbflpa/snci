<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="css.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<cfinclude template="cabecalho.cfm">
<cfquery name="TipoN" datasource="#dsn_inspecao#">
SELECT Pos_Inspecao, Pos_Unidade, Pos_Situacao_Resp, Count(Pos_Inspecao) AS Inspecao, Und_Descricao 
FROM ParecerUnidade INNER JOIN Unidades ON Und_Codigo=Pos_Unidade 
WHERE Pos_Inspecao='#Ninsp#'
GROUP BY Pos_Inspecao, Pos_Unidade, Pos_Situacao_Resp, Und_Descricao
</cfquery>
<cfquery name="qinspecao" datasource="#dsn_inspecao#">
SELECT Pos_Inspecao, Count(Pos_Inspecao) AS Quant_Inspecao
FROM ParecerUnidade
WHERE Pos_Inspecao='#Ninsp#'
GROUP BY Pos_Inspecao
</cfquery>


<table width="80%" border="0" align="center">
  <tr class="titulos">
    <td colspan="13">&nbsp;</td>
  <tr class="titulos">
    <td colspan="13"><div align="center"><span class="titulo1">Pontos de auditoria por unidade</span></div></td>
  <tr class="titulos">
    <td colspan="13"><div align="center" class="titulo1"></div></td>
	<br><br>
  <tr class="exibir">
    <td colspan="3" bgcolor="eeeeee">&nbsp;</td>
  </tr>   
  <tr class="titulos">
    <td colspan="3" bgcolor="eeeeee"><cfoutput>#TipoN.Und_Descricao#</cfoutput></td>
  </tr>  
  <tr class="titulos">
    <td colspan="3" bgcolor="eeeeee">&nbsp;</td>
  </tr> 
  <cfoutput query="TipoN">        
    <tr class="exibir">
	<td bgcolor="f7f7f7"><div align="center"><cfswitch expression= "#TipoN.Pos_Situacao_Resp#">
    <cfcase value="0">
	  Não Respondido
	</cfcase>
	<cfcase value="1">
	  Resposta da Unidade
	</cfcase>
	<cfcase value="2">
	  Pendente da Unidade
	</cfcase>
	<cfcase value="3">
	  Solucionado
	</cfcase>
	<cfcase value="4">
	  Pendente do Órgão Subordinador
	</cfcase>
	<cfcase value="5">
	  Pendente da Área
	</cfcase>
	<cfcase value="6">
	  Resposta da Área
	</cfcase>
	<cfcase value="7">
	  Resposta do Órgão Subordinador
	</cfcase>	 
  </cfswitch>
  </div></td>
    <td bgcolor="f7f7f7"><div align="center">#TipoN.Inspecao#</div></td>
    <td bgcolor="f7f7f7"><div align="center">#NumberFormat(val((TipoN.Inspecao*100)/(qinspecao.Quant_Inspecao)),999.00)#%</div></td></tr>    
  </cfoutput> 
  <tr class="titulos">
    <td colspan="3" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr class="titulos">
    <td bgcolor="eeeeee"><cfoutput><div align="left">Total</div></cfoutput></td>
    <td  width="10%" bgcolor="eeeeee"><cfoutput><div align="center">#qinspecao.Quant_Inspecao#</div></cfoutput></td>
    <td  width="10%" bgcolor="eeeeee"><cfoutput><div align="center"></cfoutput></div></td>
  </tr>	
  <tr class="titulos">
    <td colspan="3" bgcolor="eeeeee">&nbsp;</td>
  </tr>  
</table>
<cfinclude template="rodape.cfm">
<div align="center"></div>
</body>
</html>
