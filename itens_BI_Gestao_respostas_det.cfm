<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<cfinclude template="cabecalho.cfm">
<html>
<head> 
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<cfquery name="rsItem" datasource="#dsn_inspecao#">
   SELECT RIP_NumInspecao, RIP_Unidade, Und_Descricao, RIP_NumGrupo, RIP_NumItem, RIP_Comentario, RIP_Recomendacoes, INP_DtInicInspecao, INP_Responsavel, Rep_Codigo, Itn_Descricao, Grp_Descricao
   FROM Unidades 
   INNER JOIN Resultado_Inspecao 
   INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
   INNER JOIN Grupos_Verificacao ON RIP_NumGrupo = Grp_Codigo AND convert(char(4), RIP_Ano, 4) = Grp_Ano ON
   Und_Codigo = INP_Unidade 
   INNER JOIN Itens_Verificacao ON Grp_Codigo = Itn_NumGrupo AND Grp_Ano = Itn_Ano and RIP_NumItem=Itn_NumItem and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade)
   INNER JOIN Reops ON Und_CodReop = Rep_Codigo
   WHERE RIP_NumInspecao ='#frmNumInsp#' AND RIP_Unidade='#frmUnid#' AND RIP_NumGrupo= #frmGrupo# AND RIP_NumItem=#frmItem#
</cfquery>
<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
  SELECT INP_Responsavel
  FROM Inspecao
  WHERE (INP_NumInspecao = '#frmNumInsp#')
</cfquery>
<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Dir_Descricao, Dir_Codigo, Dir_Sigla
  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
  WHERE Und_Codigo = '#frmUnid#'
</cfquery>
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND
  Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
  WHERE (IPT_NumInspecao = '#frmNumInsp#')
</cfquery>

<cfquery name="rsParecer" datasource="#dsn_inspecao#">
	SELECT Pos_Parecer, Pos_DtPosic, Pos_Situacao_Resp, STO_Sigla FROM ParecerUnidade INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo 
	WHERE (Pos_Unidade = '#frmUnid#') AND (Pos_Inspecao = '#frmNumInsp#') AND (Pos_NumGrupo = #frmGrupo#) AND (Pos_NumItem = #frmItem#)
</cfquery>
<cfset auxdata = dateformat(dtposic,"YYYYMMDD")>
<cfset auxdata = CreateDate(Left(auxdata,4), Mid(auxdata,5,2), Right(auxdata,2))>
<!--- <cfquery name="rsAndamento" datasource="#dsn_inspecao#">
	SELECT And_Parecer, And_DtPosic, And_HrPosic, And_Situacao_Resp, STO_Sigla
	FROM Andamento INNER JOIN Situacao_Ponto ON And_Situacao_Resp = STO_Codigo
	WHERE (And_Unidade = '#frmUnid#') and (And_NumInspecao = '#frmNumInsp#') and (And_NumGrupo = #frmGrupo#) and (And_NumItem = #frmItem#) and (And_DtPosic >= #auxdata#)
	ORDER BY And_DtPosic asc, And_HrPosic asc 
</cfquery> --->

<body>
<table width="95%" align="center">
  <tr bgcolor="f7f7f7" class="exibir">
    <td colspan="6"><div align="center"><span class="titulo1"><strong>CONTROLE DO TEMPO DAS An&aacute;lises das MANIFESTA&Ccedil;&Otilde;ES</strong></span></div></td>
  </tr>
  <tr bgcolor="f7f7f7" class="exibir">
    <td colspan="6">&nbsp;</td>
  </tr>
  <tr class="exibir">
    <td width="7%" bgcolor="eeeeee">Unidade </td>
    <td colspan="3" bgcolor="f7f7f7"><cfoutput><strong>#rsMod.Und_Descricao#</strong></cfoutput></td>
    <td width="65%"  colspan="2" bgcolor="f7f7f7">Respons&aacute;vel<cfoutput><strong>: &nbsp;#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
  </tr>
  
    <cfif qInspetor.RecordCount lt 2>
	    <cfset auxdescinsp = "Inspetor">
    <cfelse>
	  <cfset auxdescinsp = "Inspetores">
    </cfif>
    <cfset Num_Insp = Left(frmNumInsp,2) & '.' & Mid(frmNumInsp,3,4) & '/' & Right(frmNumInsp,4)>
    <cfset auxinspetor = "">
	<cfoutput query="qInspetor">
	 <tr class="exibir">
		<td bgcolor="eeeeee">#auxdescinsp#</td>
	    <td colspan="4" bgcolor="f7f7f7"><strong>#IPT_MatricInspetor# - #Fun_Nome#</strong></td>
	 </tr>
	 <cfset auxdescinsp = "">
    </cfoutput>
	
  
 <!---  <cfoutput><strong>#auxinspetor#</strong></cfoutput> --->
  <tr class="exibir">
    <td bgcolor="eeeeee">N&ordm; Relat&oacute;rio</td>
    <cfset Num_Insp = Left(frmNumInsp,2) & '.' & Mid(frmNumInsp,3,4) & '/' & Right(frmNumInsp,4)>
    <td colspan="5" bgcolor="f7f7f7"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee">Grupo</td>
    <td colspan="6" bgcolor="f7f7f7"><cfoutput>#frmGrupo#</cfoutput> - <cfoutput><strong>#rsItem.Grp_Descricao#</strong></cfoutput><cfoutput></cfoutput></td>
  </tr>
  <tr class="exibir">
    <td bgcolor="eeeeee">Item</td>
    <td colspan="5" bgcolor="f7f7f7"><cfoutput>#frmItem#</cfoutput> &nbsp;- <cfoutput><strong>#rsItem.Itn_Descricao#</strong></cfoutput></td>
  </tr>
  <cfoutput>
 		 <cfset sdados = trim(rsParecer.Pos_Parecer)>
		 <cfset sdados = Replace(sdados,' > ',' ','All')>
		 <cfset sinicio = 1>
		 <cfset loopsn = 'S'>
		 <cfset contador = 0>
		 <cfset sfim = len(sdados)>
		 <cfset smeio= 0>

	 <cfloop condition="loopsn is 'S'">
		  <cfif findoneof(">", sdados, (sinicio + 18)) is 0>
		     <cfset loopsn = 'N'>
          <cfelse>
			  <cfset smeio = int(findoneof(">", sdados, (sinicio + 18)))>
			  <cfset smeio = int(smeio - 17)>

			  <cfset smanifesto = mid(sdados,sinicio,(smeio - sinicio))>
			  <cfif left(smanifesto,10) eq trim(dtposic) and hrposic gte mid(smanifesto,12,5)>
			   <cfset loopsn = 'N'>
			    <cfset smanifesto = mid(sdados, sinicio, sfim)>
</cfif>		  
			  <cfset contador = contador + 1>
			  <cfset sinicio = (smeio + 1)>
	      </cfif>

	</cfloop> 
</cfoutput>
  <tr class="exibir">
    <td colspan="6" bgcolor="f7f7f7"><hr></td>
  </tr>
  <tr class="exibir">
    <td colspan="6" bgcolor="f7f7f7" class="titulos">Filtros: <cfoutput>#filtro#</cfoutput></td>
  </tr>
  <tr class="exibir">
    <td colspan="6" bgcolor="f7f7f7"><hr></td>
  </tr>
  <tr class="exibir">
    <td colspan="6" bgcolor="f7f7f7"><div align="center"><span class="titulos">Hist&oacute;rico das Manifesta&ccedil;&otilde;es</span></div></td>
  </tr>
  <tr class="exibir">
    <td colspan="6" bgcolor="f7f7f7"><textarea name="textarea" cols="160" rows="30"><cfoutput>#smanifesto#</cfoutput></textarea></td>
  </tr>


  <tr>
   <td colspan="6" bgcolor="f7f7f7"><hr></td>
 </tr>
 <!---
 <tr>
   <td colspan="6" bgcolor="f7f7f7" class="titulos"><div align="center">S&iacute;ntese das Manifesta&ccedil;&otilde;es por Data e Hora (Crescentes) </div></td>
  </tr>
  <tr>
    <td colspan="6" bgcolor="f7f7f7">&nbsp;</td>
  </tr>   
    <cfoutput query="rsAndamento">
 <tr>
     <td bgcolor="f7f7f7"><div align="right"><span class="exibir">Status:</span></div></td>
     <td bgcolor="f7f7f7"><div align="left"><span class="exibir">#And_Situacao_Resp#</span> - <span class="exibir">#STO_Sigla#</span></div></td>
     <td width="102" bgcolor="f7f7f7"><div align="right"><span class="exibir">Data Posi&ccedil;&atilde;o:</span></div></td>
     <td width="280" bgcolor="f7f7f7" class="exibir">#dateformat(And_DtPosic,"dd-mm-yyyy")#</td>
     <td width="141" bgcolor="f7f7f7"><div align="right"><span class="exibir">Hora:</span></div></td>
     <td width="173" bgcolor="f7f7f7" class="exibir">#trim(And_HrPosic)#</td>
     </tr>
   <cfif len(trim(rsAndamento.And_Parecer)) gt 0>
     <tr class="exibir">
    <td colspan="6" bgcolor="f7f7f7"><textarea name="textarea" cols="160" rows="10">#rsAndamento.And_Parecer#</textarea></td>
  </tr>
   
   <cfelse>
  
   <tr>
	 <td colspan="6" bgcolor="f7f7f7"><hr></td>
   </tr>
   </cfif>
</cfoutput>  --->
  <tr class="exibir">
    <td colspan="6" bgcolor="f7f7f7">&nbsp;</td>
  </tr>
</table>
</body>
</html>