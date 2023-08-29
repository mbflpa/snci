<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfset total=0>
<cfif IsDefined("url.area")>
<cfset url.area = url.area>
<cfelse>
<cfset url.area = form.area>
</cfif> 

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtUltAtu, 
Itn_Descricao, Grupos_Verificacao.Grp_Descricao, Areas.Ars_Codigo, Areas.Ars_Sigla, Pos_Situacao_Resp, 
Pos_Parecer
FROM (Inspecao INNER JOIN (Unidades INNER JOIN (ParecerUnidade INNER JOIN (Itens_Verificacao 
INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) ON 
(Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (Und_Codigo = Pos_Unidade)) ON (INP_Modalidade = Itn_Modalidade) AND (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
INNER JOIN Areas ON Pos_Area = Ars_Codigo
WHERE Pos_Situacao_Resp = '5' AND Pos_Area ='#url.area#' AND INP_NumInspecao = Pos_Inspecao
AND Und_Codigo = Pos_Unidade AND Itn_NumGrupo = Pos_NumGrupo 
AND Itn_NumItem = Pos_NumItem 
AND Grp_Codigo = Pos_NumGrupo AND Pos_Area = Ars_Codigo 
ORDER BY Pos_NumGrupo, Pos_NumItem, Und_Descricao,Pos_Inspecao, INP_DtInicInspecao
</cfquery>
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Auditorias</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {color: #FF0000}
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="800" height="450">
 <tr>
    <td valign="top">
<table width="90%" class="exibir">
  <tr class="exibir">
    <td height="16" colspan="7"><cfoutput>
      <div align="center"><span class="style5">#rsItem.Ars_Sigla#</span></div>
    </cfoutput></td>	
  </tr><br>
  <tr class="exibir">
    <td height="16" colspan="6">&nbsp;</td>
    </tr>
  <tr class="exibir">    
    <td width="9%" height="16"><div align="center"><cfoutput>Qt. Itens: #rsItem.recordCount# </cfoutput></div></td>
    <td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">In&iacute;cio Insp.</div></td>
    <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
    <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">N&ordm; Inspe&ccedil;&atilde;o</div></td>
    <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">N&ordm; Grupo </div></td>
    <td width="12%" bgcolor="eeeeee" class="exibir"><div align="center">N&ordm; Item </div></td>
    <td width="8%" bgcolor="eeeeee"><div align="center" class="exibir">Gravidade</div></td> 
  </tr>    
  <cfoutput query="rsItem">
   <cfset grav = 0>
<cfquery name="qGrav" datasource="#dsn_inspecao#">
SELECT Ana_Col01, Ana_Col02, Ana_Col03, Ana_Col04, Ana_Col05, Ana_Col06, Ana_Col07, Ana_Col08, Ana_Col09 FROM Analise WHERE Ana_NumInspecao='#rsItem.Pos_Inspecao#' AND Ana_Unidade='#rsItem.Pos_Unidade#' AND Ana_NumGrupo=#rsItem.Pos_NumGrupo# AND Ana_NumItem=#rsItem.Pos_NumItem#
</cfquery>
 <cfif qGrav.Ana_Col01 is 1><cfset grav = int(10)></cfif>
 <cfif qGrav.Ana_Col02 is 1><cfset grav = val(grav) + int(5)></cfif>
 <cfif qGrav.Ana_Col03 is 1><cfset grav = val(grav) + int(7)></cfif>
 <cfif qGrav.Ana_Col04 is 1><cfset grav = val(grav) + int(10)></cfif>
 <cfif qGrav.Ana_Col05 is 1><cfset grav = val(grav) + int(2)></cfif>
 <cfif qGrav.Ana_Col06 is 1><cfset grav = val(grav) + int(5)></cfif>
 <cfif qGrav.Ana_Col07 is 1><cfset grav = val(grav) + int(7)></cfif>
 <cfif qGrav.Ana_Col08 is 1><cfset grav = val(grav) + int(4)></cfif>
 <cfif qGrav.Ana_Col09 is 1><cfset grav = val(grav) + int(2)></cfif>
 
 <cfif val(grav) gte 10>
   <cfset sGrav ='<span class="red_titulo">Alto</span>'>  
 </cfif>
 <cfif val(grav) is 0>
   <cfset sGrav ="----">
 </cfif>
 <cfif val(grav) gte 1 and val(grav) lte 4>
   <cfset sGrav ="Baixo">
 </cfif>
 <cfif val(grav) gte 5 and val(grav) lte 9>
   <cfset sGrav ="Médio">
 </cfif> 
     <tr bgcolor="f7f7f7" class="exibir">
	 <cfif rsItem.Pos_Situacao_Resp eq 0>
    	<td height="26" bgcolor="##999999"><div align="center"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Responder </strong></a></div></td>
	 <cfelseif rsItem.Pos_Situacao_Resp eq 2> 
		<td height="26" bgcolor="FF3300"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Respondido</strong></a></div></td>
     <cfelseif rsItem.Pos_Situacao_Resp eq 4> 
		<td height="26" bgcolor="0000FF"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Órgão Subordinador</strong></a></div></td>        	
     <cfelseif rsItem.Pos_Situacao_Resp eq 5>
	   <cfif rsItem.Pos_Parecer is ''>
	      <td height="15%" bgcolor="FF9900"><div align="center"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&area=#url.area#" class="exibir"><strong>Não Respondido</strong></a></div></td> 
	   <cfelse>  
          <td height="26" bgcolor="009900"><div align="center"><a href="itens_controle_respostas1_area.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&area=#url.area#" class="exibir"><strong>Pendente Área</strong></a></div></td>
	   </cfif>	
	 <cfelseif rsItem.Pos_Situacao_Resp eq 2> 
		<td height="26" bgcolor="FFFF00"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir"><strong>Pendente Agência</strong></a></div></td>
	 </cfif>
      <td width="12%"><div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD-MM-YYYY')#</div></td>
      <td width="15%"><div align="left">#rsItem.Und_Descricao#</div></td>
      <td width="35"><div align="center">#rsItem.Pos_Inspecao#</div></td>
      <td width="28%"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="34%"><div align="left"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>
      <td width="36"><div align="center">#sGrav#</div></td> 
	</tr>	
  </cfoutput>
  <tr><td>&nbsp;</td></tr>
   <tr class="exibir">
       <td height="26" colspan="7" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar"></td>
   </tr>
</table>

<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
</body>
</html>








