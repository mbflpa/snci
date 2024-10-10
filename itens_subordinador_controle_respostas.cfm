<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<cfset area = 'sins'>
<cfset total=0>
<cfif IsDefined("URL.Unid")>
<!---<cfset url.dtInicio = url.DtInic>--->
<cfset FORM.nu_inspecao = url.Ninsp>
<!---<cfelse>--->
<!---<cfset url.dtInicio = createdate(right(form.dtinic,4), mid(form.dtinic,4,2), left(form.dtinic,2))>--->
</cfif>
<cfquery name="qVerifica" datasource="#dsn_inspecao#">
SELECT ParecerUnidade.Pos_Inspecao
FROM ParecerUnidade
WHERE ParecerUnidade.Pos_Inspecao = '#FORM.nu_inspecao#'
</cfquery>

<!--- ISRAEL --->
<cfquery name="qVerificaData" datasource="#dsn_inspecao#">
SELECT Inspecao.INP_DtInicInspecao
FROM Inspecao
WHERE Inspecao.INP_NumInspecao = '#FORM.nu_inspecao#'
</cfquery>
<!--- / ISRAEL --->

<cfif (qVerifica.recordcount neq 0) and (qVerificaData.recordcount neq 0)> <!--- if 01 --->

<cfquery name="rsItem" datasource="#dsn_inspecao#">
  SELECT INP_DtInicInspecao, Pos_Unidade, INP_Responsavel, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp, Pos_Parecer, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao,Pos_DtPosic,Pos_DtPrev_Solucao
  FROM ParecerUnidade 
  INNER JOIN Unidades 
  ON Pos_Unidade = Und_Codigo 
  INNER JOIN Itens_Verificacao 
  ON Pos_NumGrupo = Itn_NumGrupo AND Pos_NumItem = Itn_NumItem AND right([Pos_Inspecao], 4) = Itn_Ano 
  INNER JOIN Grupos_Verificacao 
  ON Pos_NumGrupo = Grp_Codigo AND Itn_Ano = Grp_Ano
  INNER JOIN Inspecao 
  ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao and Itn_TipoUnidade = Und_TipoUnidade AND (INP_Modalidade = Itn_Modalidade)
  INNER JOIN Situacao_Ponto 
  ON Pos_Situacao_Resp = STO_Codigo  
  WHERE (Pos_Inspecao = '#FORM.nu_inspecao#') AND (Pos_Situacao_Resp <> 0) AND (Pos_Situacao_Resp <> 11) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13)
  ORDER BY INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
</cfquery>
<cfif rsItem.recordCount eq 0>

	<html>
	<head>
	<title>Sistema Nacional de Controle Interno</title>
	<link href="CSS.css" rel="stylesheet" type="text/css">
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	</head>
	<body>
	<cfinclude template="cabecalho.cfm">
	<table border="0">
	<tr>
	<td>
	   Não há ítens pendentes para este relatório.
	<br><br>
    <!--- <input name="" value="fechar" type="button" onClick="self.close(); "> --->
	</td>
	</tr>
	 <tr>
		   <td colspan="6"><div align="center">
                  <input name="Voltar" type="button" class="botao" value="Voltar" onClick="history.back()">
            </div></td>
			</tr>
	</table>
	</body>
	</html>
	<cfabort>
</cfif> 

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT IPT_MatricInspetor, Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor =
  Fun_Matric
  WHERE (IPT_NumInspecao = '#FORM.nu_inspecao#')
</cfquery>


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <cfquery name="rsSPnt" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
 </cfquery>
 <cfoutput query="rsSPnt">
 <div id="#rsSPnt.STO_Sigla#" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
 <font size="1" face="Verdana" color="000000">#rsSPnt.STO_Conceito#</font></div>
</cfoutput>
</head>
<body>
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
<cfinclude template="cabecalho.cfm">
<table width="80%" height="450" align="center">

<table width="80%" border="0" align="center">
	<tr><td colspan="7">&nbsp;</td></tr>
	<tr><td colspan="7">&nbsp;</td></tr>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Avaliação</span></td>
	  <cfset Num_Insp = Left(rsItem.Pos_Inspecao,2) & '.' & Mid(rsItem.Pos_Inspecao,3,4) & '/' & Right(rsItem.Pos_Inspecao,4)>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#Num_Insp#</span></cfoutput></td>
	  <td bgcolor="eeeeee" width="5%"><span class="titulos">Inicio</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</span></cfoutput></td>
	  <td align="center" bgcolor="eeeeee" class="titulos">Imprimir</td>
	</tr>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Unidade</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.Und_Descricao#</span></cfoutput></td>
	  <td bgcolor="eeeeee"><span class="titulos">Responsável</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.INP_Responsavel#</span></cfoutput></td>
	  <td align="center" bgcolor="f7f7f7">
	   <form action="GeraRelatorio/gerador/dsp/relatorioHTML.cfm" name="frmHtml" method="post" target="_blank">
	      <img src="icones/relatorio.jpg" height="48" alt="Visualizar Avaliação em HTML" border="0" onClick="forms[0].submit()" onMouseOver="this.style.cursor='hand';" onMouseOut="this.style.cursor='pointer';">
		  <input type="hidden" name="id" value="<cfoutput>#FORM.nu_inspecao#</cfoutput>">
	    </form>
	  </td>
	 </tr>
	<tr>
	  <cfif qInspetor.RecordCount lt 2>
	    <td bgcolor="eeeeee"><span class="titulos">Inspetor</span></td>
	  <cfelse>
	    <td bgcolor="eeeeee"><span class="titulos">Inspetores</span></td>
	  </cfif>
	  <td colspan="7" bgcolor="f7f7f7"><strong class="titulosClaro">-&nbsp;<cfoutput query="qInspetor">#qInspetor.Fun_Nome#&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></strong></td>
	</tr>
	 <tr><td colspan="7">&nbsp;</td></tr>
 </table>

<table width="80%" class="exibir" align="center">
  <tr class="exibir">
    <td width="5%" bgcolor="eeeeee" class="titulos" height="16"><div align="center">Status</div></td>
    <td width="25%" colspan="2" bgcolor="eeeeee" class="titulos"><div align="center">Grupo</div></td>
    <td width="45%" bgcolor="eeeeee" class="titulos"><div align="center">Item</div></td>
	<td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Posição</strong></td>
    <td width="4%" align="center" bgcolor="eeeeee" class="exibir"><strong>Prev_Solução</strong></td>
	<td width="15%" bgcolor="eeeeee" class="titulos"></td>
  </tr>
<cfoutput query="rsItem">
	<cfquery name="rsRIP" datasource="#dsn_inspecao#">
		SELECT RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem
		FROM Resultado_Inspecao
		WHERE RIP_NumInspecao = '#Pos_Inspecao#' AND RIP_NumGrupo =  #Pos_NumGrupo# AND RIP_NumItem = '#Pos_NumItem#'
	</cfquery>
    <cfset numReincInsp = ''>
	<cfif len(trim(rsRIP.RIP_ReincInspecao)) gt 0>
		<cfset numReincInsp = 'item REINCIDENTE (' & Left(rsRIP.RIP_ReincInspecao,2) & '.' & Mid(rsRIP.RIP_ReincInspecao,3,4) & '/' & Right(rsRIP.RIP_ReincInspecao,4) & ')'>
	</cfif>	
     <tr bgcolor="f7f7f7" class="exibir">
      <td width="69" height="26" bgcolor="#STO_Cor#"><div align="center"><a href="itens_subordinador_controle_respostas1_reop.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a></div></td>
	  <td colspan="2"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="45%"><div align="justify"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>
	  <cfset auxtela = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
	  <td width="3%"><div align="center">#auxtela#</div></td>
	  <cfset auxtelaprev = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')>
	  <td width="3%"><div align="center">#auxtelaprev#</div></td>
	  <td width="15%" class="red_titulo">#numReincInsp#</td>

    </tr>
</cfoutput>
	<tr><td colspan="7">&nbsp;</td></tr>
	<tr>
		<td colspan="7" class="titulos" align="center"><cfoutput>Quantidade de pontos do relatório com Situação Encontrada: <font class="red_titulo">#rsItem.recordCount#</font> </cfoutput></td>
	</tr>

   <tr class="exibir">
       <td height="26" colspan="7" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar"></td>
   </tr>
</table>
<!--- Fim area de conte�do --->
	  </td>
  <!--- </tr> --->
</table>

</body>
</htm


><cfelse> <!--- else do if 01 --->
 <html>
  <body onLoad="alert('Nº do Relatório Incorreto!');history.back();">
</body>
</html> 
</cfif> <!--- fim if 01 --->

