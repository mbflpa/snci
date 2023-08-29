<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<!--- <cfdump var="#url#">
<cfabort>  --->

<cfif isDefined("Session.E01")>
  <cfset StructClear(Session.E01)>
</cfif>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Lotacao from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="qArea" datasource="#dsn_inspecao#">
  SELECT DISTINCT(Ars_Codigo), Ars_Sigla
  FROM Areas
  WHERE Ars_Codigo = '#qAcesso.Usu_Lotacao#'
  ORDER BY Ars_Sigla ASC
</cfquery>

<cfset url.Area = qArea.Ars_Codigo>

<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'SUBORDINADORREGIONAL'>

<cfset total=0>

<cfif IsDefined("form.Area") or IsDefined("url.Area")>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
   SELECT INP_DtInicInspecao, Pos_NumItem, Pos_Unidade, DATEDIFF(dd, Pos_DtPosic, GETDATE())
   AS Quant, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, pos_dtultatu, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS data,
   Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp, Ars_Codigo, Ars_Sigla, Ars_Descricao, RIP_NumInspecao, Pos_Parecer,
   INP_DtInicInspecao, INP_DtFimInspecao, INP_DtEncerramento, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao
   FROM AREAS 
   INNER JOIN Resultado_Inspecao 
   INNER JOIN Grupos_Verificacao 
   INNER JOIN Unidades 
   INNER JOIN ParecerUnidade 
   INNER JOIN Inspecao 
   ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
   ON Und_Codigo = Pos_Unidade 
   ON Grp_Codigo = Pos_NumGrupo 
   ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
   ON Ars_Codigo = Pos_Area 
   INNER JOIN Itens_Verificacao 
   ON Itn_Ano = Grp_Ano and Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem and Itn_TipoUnidade = Und_TipoUnidade AND (INP_Modalidade = Itn_Modalidade)
   INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
   WHERE ((Pos_Situacao_Resp = 5 OR Pos_Situacao_Resp = 19 OR (Pos_Situacao_Resp = 6 AND DATEDIFF(dd,Pos_DtPosic,GETDATE()) <= 2))) AND (Pos_Area = '#Area#')
   ORDER BY Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, data
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
<cfquery name="rsSPnt" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
 </cfquery>
 <cfoutput query="rsSPnt">
 <div id="#rsSPnt.STO_Sigla#" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
 <font size="1" face="Verdana" color="000000">#rsSPnt.STO_Conceito#</font></div>
</cfoutput>
<script language="JavaScript">
//detectando navegador
sAgent = navigator.userAgent;
bIsIE = sAgent.indexOf("MSIE") > -1;
bIsNav = sAgent.indexOf("Mozilla") > -1 && !bIsIE;

//setando as variaveis de controle de eventos do mouse
var xmouse = 0;
var ymouse = 0;
document.onmousemove = MouseMove;

//funcoes de controle de eventos do mouse:
function MouseMove(e){
 if (e) { MousePos(e); } else { MousePos();}
}

function MousePos(e) {
 if (bIsNav){
  xmouse = e.pageX;
  ymouse = e.pageY;
 }
 if (bIsIE) {
  xmouse = document.body.scrollLeft + event.x;
  ymouse = document.body.scrollTop + event.y;
 }
}

//funcao que mostra e esconde o hint
function Hint(objNome, action){
 //action = 1 -> Esconder
 //action = 2 -> Mover

 if (bIsIE) {
  objHint = document.all[objNome];
 }
 if (bIsNav) {
  objHint = document.getElementById(objNome);
  event = objHint;
 }

 switch (action){
  case 1: //Esconder
   objHint.style.visibility = "hidden";
   break;
  case 2: //Mover
   objHint.style.visibility = "visible";
   objHint.style.left = xmouse + 15;
   objHint.style.top = ymouse + 15;
   break;
 }

}
</script>
</head>
<body>

<cfinclude template="cabecalho.cfm">
<table width="100%" height="45%">
<tr>
<td valign="top">
<!--- Área de conteúdo   --->
<table width="100%" class="exibir">
 <br>
  <tr>
    <td height="20%" colspan="9"><div align="center"><span class="style5"><cfoutput>#rsItem.Ars_Descricao#</cfoutput></span></div></td>
  </tr><br><br>
  <tr>
    <td height="20%" colspan="9">&nbsp;</td>
  </tr>
 <tr>
    <td height="20%" colspan="9">&nbsp;</td>
 </tr>
  <tr>
    <td height="20%" colspan="9" class="titulosClaro"><div align="center"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div></td>
  </tr>
  <tr class="titulosClaro">
    <td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
	<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Início</div></td>
    <td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Fim</div></td>
	<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Envio Ponto </div></td>
    <td width="12%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
    <td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Relatório</div></td>
    <td width="17%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
    <td width="20%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
	<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Quant. de Dias</div></td>
  </tr>

<cfoutput query="rsItem">
   	<cfquery name="rsStatus011" datasource="#dsn_inspecao#">
		SELECT Pos_Inspecao 
		FROM ParecerUnidade 
		WHERE (Pos_Inspecao = '#rsItem.Pos_Inspecao#') AND (Pos_Situacao_Resp = 0 Or Pos_Situacao_Resp = 11)
	  </cfquery>
	 <cfif rsStatus011.recordcount lte 0>
<tr bgcolor="f7f7f7">
      <cfif rsItem.Pos_Situacao_Resp eq 5 and rsItem.Pos_Parecer is ''>
        <td width="5%" bgcolor="000000"><div align="center"><a href="itens_subordinador_respostas_pendentes_regional1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&Area=#rsItem.Ars_Codigo#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>SEM MANIFESTACOES</strong></a></div></td>
     <cfelse>
	 <td width="5%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_subordinador_respostas_pendentes_regional1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&Area=#rsItem.Ars_Codigo#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a></div></td>
	 </cfif>

   <!---      <cfelseif rsItem.Pos_Situacao_Resp eq 5>
		<cfif rsItem.Pos_Parecer is ''>
		    <td height="20" bgcolor="666666"><div align="center"><a href="itens_subordinador_respostas_pendentes_regional1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&Area=#rsItem.Ars_Codigo#" class="exibir"><strong>Sem Manifestação</strong></a></div></td>
		<cfelse>
		    <cfset dtInicio = rsItem.INP_DtInicInspecao>
		    <cfset dtFinal = rsItem.INP_DtInicInspecao>
		<td height="20" bgcolor="009900"><div align="center"><a href="itens_subordinador_respostas_pendentes_regional1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&Area=#rsItem.Ars_Codigo#" class="exibir"><strong>Pendente Área</a></div></td>
        </cfif>
		<cfelseif rsItem.Pos_Situacao_Resp eq 6 and rsItem.data LTE 2>
		   <td height="20" bgcolor="339999"><div align="center"><a href="itens_subordinador_respostas_pendentes_regional1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&Area=#rsItem.Ars_Codigo#" class="exibir"><strong>Respondido Area</strong></a></div></td>
		<cfelseif rsItem.Pos_Situacao_Resp eq 3>
		<td height="20" bgcolor="333333"><div align="center"><a href="itens_subordinador_respostas_pendentes_regional1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&Area=#rsItem.Ars_Codigo#" class="exibir"><strong>Solucionado</strong></a></div></td>
		<cfelseif rsItem.Pos_Situacao_Resp eq 19>
		<td height="20" bgcolor="009966"><div align="center"><a href="itens_subordinador_respostas_pendentes_regional1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&Area=#rsItem.Ars_Codigo#" class="exibir"><strong>Em Tratamento da Area</strong></a></div></td>
	    </cfif> --->
      <td width="5%"><div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')#</div></td>
      <td width="5%"><div align="center">#DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')#</div></td>
	  <td width="5%"><div align="center">#DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')#</div></td>
      <td width="12%"><div align="center">#rsItem.Und_Descricao#</div></td>
      <td width="5%"><div align="center">#rsItem.Pos_Inspecao#</div></td>
      <td width="17%"><div align="center"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="20%"><div align="justify"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>
	  <td width="5%"><div align="center"><strong>#rsItem.Quant#</strong></div></td>
	 </tr>
	 </cfif>
  </cfoutput>
   <tr><td colspan="9" align="center">&nbsp;</td></tr>
   <tr><td colspan="9" align="center">&nbsp;&nbsp;&nbsp;&nbsp;<button onClick="window.close()" class="botao">Fechar</button></td></tr>
 </table>
<cfelse>
    <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>
</cfif>
<cfelse>
      <cfinclude template="permissao_negada.htm">
      <cfabort>
 </cfif>