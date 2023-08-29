<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
   select Usu_GrupoAcesso, Usu_Lotacao, Usu_DR from usuarios where Usu_login = '#cgi.REMOTE_USER#'
 </cfquery>
 
<cfset total=0>

<cfparam  name = "reop"  default="">
<cfoutput>

		<cfquery name="rsItem" datasource="#dsn_inspecao#">
 <cfif ckTipo eq "1">		
SELECT DISTINCT
ParecerUnidade.Pos_NumItem, Inspecao.INP_DtInicInspecao, ParecerUnidade.Pos_Unidade, 
Unidades.Und_Descricao, ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_NumGrupo, ParecerUnidade.pos_dtultatu, Itens_Verificacao.Itn_Descricao, Grupos_Verificacao.Grp_Descricao, ParecerUnidade.Pos_Situacao_Resp, Reops.Rep_Codigo, Reops.Rep_Nome, Resultado_Inspecao.RIP_NumInspecao, STO_Cor
FROM        Reops 
INNER JOIN Resultado_Inspecao 
INNER JOIN Grupos_Verificacao 
INNER JOIN Unidades 
INNER JOIN ParecerUnidade 
INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao
ON Unidades.Und_Codigo = ParecerUnidade.Pos_Unidade 
ON Grp_Codigo = Pos_NumGrupo 
ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao 
ON Rep_Codigo = RIP_CodReop 
INNER JOIN Itens_Verificacao ON
Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem 
AND convert(char(4),RIP_Ano) = Itn_Ano and Grp_Ano = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
WHERE ParecerUnidade.Pos_Situacao_Resp='4' AND Reops.Rep_Codigo='#reop#'
		
<cfelse>
	
		SELECT DISTINCT ParecerUnidade.Pos_NumItem, INP_DtInicInspecao, ParecerUnidade.Pos_Unidade, 
					Unidades.Und_Descricao, ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_NumGrupo, ParecerUnidade.pos_dtultatu, Itens_Verificacao.Itn_Descricao, Grupos_Verificacao.Grp_Descricao, ParecerUnidade.Pos_Situacao_Resp, Reops.Rep_Codigo, Reops.Rep_Nome, Resultado_Inspecao.RIP_NumInspecao, STO_Cor
		FROM        Reops 
INNER JOIN Resultado_Inspecao 
INNER JOIN Grupos_Verificacao 
INNER JOIN Unidades 
INNER JOIN ParecerUnidade 
INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao
ON Unidades.Und_Codigo = ParecerUnidade.Pos_Unidade 
ON Grp_Codigo = Pos_NumGrupo 
ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao 
ON Rep_Codigo = RIP_CodReop 
INNER JOIN Itens_Verificacao ON
Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem 
AND convert(char(4),RIP_Ano) = Itn_Ano and Grp_Ano = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
		  <cfif '#frmResp#' neq ''> 
            <cfswitch expression='#frmResp#'>
              <cfcase value="N">WHERE  ((Und_CodReop = '#qAcesso.Usu_Lotacao#' AND Pos_Area = Pos_Unidade)  or Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (2,4,5,14,15,16,19) and Itn_TipoUnidade <> 99</cfcase>
             <cfcase value="S">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND Pos_Area = Pos_Unidade AND pos_situacao_resp in (3))</cfcase>
             <cfcase value="A">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (24))</cfcase>
             <cfcase value="R">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade=12)</cfcase>
             <cfcase value="C">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (9))</cfcase>
             <cfcase value="E">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (29))</cfcase>			 
            </cfswitch>
          </cfif>
		  <cfset dataInicio='#dtinicial#'>
          <cfset dataFim='#dtfinal#'>

          <cfif dtinicial neq '' and dtfinal neq ''>
            <cfset dataInicio=createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
            <cfset dataFim=createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>
          </cfif>
          <cfif '#dataInicio#' neq '' and '#dataFim#' neq ''>
            AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#)
          </cfif>
        </cfif>
			ORDER BY Unidades.Und_Descricao, ParecerUnidade.Pos_NumGrupo, ParecerUnidade.Pos_NumItem, ParecerUnidade.Pos_Inspecao
       </cfquery>		  
</cfoutput>
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
-->
</style>
</head>
<body>
<cfinclude template="cabecalho.cfm">
<table width="99%" height="450">
<tr>
<td width="1202" valign="top">
<!--- Área de conteúdo   --->
<table width="99%" class="exibir">
  <tr>
    <td height="29" colspan="6"><div align="center"><strong class="titulo1">Controle de Respostas Por Órgão Subordinador</strong><br>
          <br>    
    </div></td>
  </tr>
  <tr>
    <td height="25" align="center" valign="top" colspan="10"><cfoutput>
      <div align="center"><span class="style5">#rsItem.Rep_Nome#</span></div>
    </cfoutput></td>
  </tr>
  <tr class="exibir">
    <td height="23"><div align="center"><cfoutput>Qt. Itens: #rsItem.recordCount# </cfoutput></div></td>
    <td width="102" height="16" bgcolor="eeeeee"><div align="center" class="titulos">In&iacute;cio Insp. </div></td>
    <td width="58" bgcolor="eeeeee"><div align="left" class="titulos">Nome da Unidade</div></td>
    <td width="58" bgcolor="eeeeee"><div align="center" class="titulos">N&ordm; Inspe&ccedil;&atilde;o</div></td>
    <td width="68" bgcolor="eeeeee"><div align="left" class="titulos">N&ordm; Grupo</div></td>
    <td width="161" bgcolor="eeeeee"><div align="left" class="titulos">N&ordm; Item </div></td>
    <td width="133" bgcolor="eeeeee"><div align="left" class="titulos">Gravidade</div></td> 
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
 
<tr bgcolor="f7f7f7">
	    <cfif rsItem.Pos_Situacao_Resp eq 0>
    	<td width="94" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir">N&atilde;oRegularizada</a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 1>
		<td width="102" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>RespostaAg&ecirc;ncia </strong></a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 2> 
		<td height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_NumInspecao#&Ngrup=#rsItem.Pos_Grupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Pendente Agência</strong></a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 3>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Solucionado</strong></a></div></td>
		<cfelseif rsItem.Pos_Situacao_Resp eq 4>
		<cfset dtInicio = rsItem.INP_DtInicInspecao>
		<cfset dtFinal = rsItem.INP_DtInicInspecao>
		<td width="58" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtIni=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Pendente Órgão Subordinador</strong></a></div></td>
        <cfelseif rsItem.Pos_Situacao_Resp eq 5>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Pendente de Área</strong></a></div></td>
		<cfelseif rsItem.Pos_Situacao_Resp eq 9>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Corporativo Correios Sede</strong></a></div></td>
<cfelseif rsItem.Pos_Situacao_Resp eq 14>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Não Respondido</strong></a></div></td>				
<cfelseif rsItem.Pos_Situacao_Resp eq 15>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Tratamento Unidade</strong></a></div></td>	
<cfelseif rsItem.Pos_Situacao_Resp eq 16>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Tratamento Órgão Subordinador</strong></a></div></td>	
<cfelseif rsItem.Pos_Situacao_Resp eq 19>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Tratamento da Área</strong></a></div></td>	
<cfelseif rsItem.Pos_Situacao_Resp eq 24>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Apuração</strong></a></div></td>				  <cfelseif rsItem.Pos_Situacao_Resp eq 29>
		<td width="68" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#dtinicial#&DtFinal=#dtFinal#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#reop#" class="exibir"><strong>Encerrado</strong></a></div></td>	 
	    </cfif>	  	
      <td width="161"><div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD-MM-YYYY')#</div></td>
      <td width="180"><div align="left">#rsItem.Und_Descricao#</div></td>
      <td width="145"><div align="center">#rsItem.Pos_Inspecao#</div></td>
      <td width="146"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="141"><div align="left"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>
	  <td width="36"><div align="center">#sGrav#</div></td> 
    </tr>

  </cfoutput>
</table>

<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>