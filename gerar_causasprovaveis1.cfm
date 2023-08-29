<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   


<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
       SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, INP_DtInicInspecao, INP_DtFimInspecao, Right([INP_NumInspecao],4) AS AnoInsp, INP_DtFimDeslocamento, INP_DtEncerramento, Und_Descricao, Und_CodReop, Pos_Unidade, Pos_Inspecao, Pos_DtPosic, Pos_Parecer, pos_dtultatu, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea, Pos_DtPrev_Solucao, Dir_Codigo, Dir_Descricao, Grp_Descricao, Itn_Descricao, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Cpr_Codigo, Cpr_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, PCP_CodCausaProvavel
       FROM CausaProvavel 
	   INNER JOIN ((Situacao_Ponto 
	   INNER JOIN ((Grupos_Verificacao 
	   INNER JOIN (Diretoria 
	   INNER JOIN (Unidades 
	   INNER JOIN (Inspecao 
	   INNER JOIN ParecerUnidade ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) ON Und_Codigo = Pos_Unidade) ON Dir_Codigo = Und_CodDiretoria) ON Grp_Codigo = Pos_NumGrupo) 
	   INNER JOIN Itens_Verificacao ON (Pos_NumItem = Itn_NumItem) AND (Grp_Codigo = Itn_NumGrupo) AND right([Pos_Inspecao], 4) = Itn_Ano AND right([Pos_Inspecao], 4) = Grp_Ano) ON STO_Codigo = Pos_Situacao_Resp) 
	   INNER JOIN ParecerCausaProvavel ON (Pos_NumItem = PCP_NumItem) AND (Pos_NumGrupo = PCP_NumGrupo) AND (Pos_Inspecao = PCP_Inspecao) AND (Pos_Unidade = PCP_Unidade)) ON Cpr_Codigo = PCP_CodCausaProvavel
       WHERE ((Right(INP_NumInspecao,4))='#Ano#') AND ((Dir_Codigo)='#url.SE#') and (Pos_Situacao_Resp not in (10,12,13,51))
	   ORDER BY Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop
</cfquery>


<cfquery name="rsXLS" datasource="#dsn_inspecao#">
   SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, Pos_Unidade, Und_Descricao, Pos_Inspecao, convert(char, Pos_NumGrupo) as PosNumGrupo, Grp_Descricao, convert(char, Pos_NumItem) as PosNumItem, Itn_Descricao, RIP_Ano, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, RIP_Resposta, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDeslocamento, convert(char,INP_DtFimInspecao,103) as INPDtFimInspecao, convert(char,Pos_DtPosic,103) as DtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, Und_CodReop, Rep_Nome, Pos_Situacao_Resp, Pos_Situacao, Dir_Codigo, Dir_Descricao, PCP_CodCausaProvavel, Cpr_Descricao, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, substring(Pos_Parecer,1,32000) as parecera, substring(Pos_Parecer,32001,64000) as parecerb 
   FROM (Reops 
   INNER JOIN (Diretoria 
   INNER JOIN ((CausaProvavel 
   INNER JOIN ParecerCausaProvavel ON Cpr_Codigo = PCP_CodCausaProvavel) 
   INNER JOIN ((Itens_Verificacao 
   INNER JOIN (Grupos_Verificacao 
   INNER JOIN ParecerUnidade ON Grp_Codigo = Pos_NumGrupo ) ON (Itn_NumItem = Pos_NumItem) AND (Itn_NumGrupo = Grp_Codigo) AND (right([Pos_Inspecao], 4) = Itn_Ano) AND (right([Pos_Inspecao], 4) = Grp_Ano)) INNER JOIN (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade)) ON (PCP_NumItem = Pos_NumItem) AND (PCP_NumGrupo = Pos_NumGrupo) AND (PCP_Inspecao = Pos_Inspecao) AND (PCP_Unidade = Pos_Unidade)) ON Dir_Codigo = Und_CodDiretoria) ON Rep_Codigo = Und_CodReop) INNER JOIN Resultado_Inspecao ON (PCP_NumItem = RIP_NumItem) AND (PCP_NumGrupo = RIP_NumGrupo) AND (PCP_Inspecao = RIP_NumInspecao) AND (PCP_Unidade = RIP_Unidade)
   WHERE ((Right(INP_NumInspecao,4))='#Ano#') AND ((Dir_Codigo)='#url.SE#')  AND (Pos_Situacao_Resp not in (10,12,13,51)) 
   ORDER BY Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop
</cfquery> 

<cfoutput>
   <cfquery name="qUsuario" datasource="#dsn_inspecao#">
      SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
   </cfquery>
</cfoutput>

	<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
	<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
	<cfset slocal = #diretorio# & 'Fechamento\'>

	<cfoutput>
	<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'>
	</cfoutput>

	<cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
  	<cfoutput query="qList">
		   <cfif len(name) eq 23>
				<cfif (left(name,8) lt left(sdata,8)) or (int(mid(sdata,9,2) - mid(name,9,2)) gte 2)>
				  <cffile action="delete" file="#slocal##name#">
				</cfif>
		  </cfif>
	</cfoutput>

	<cfif Month(Now()) eq 1>
	  <cfset vANO = Year(Now()) - 1>
	<cfelse>
	  <cfset vANO = Year(Now())>
	</cfif>

 <cfset objPOI = CreateObject(
		"component",
		"Excel"
		).Init()
		/>

	<cfset data = now() - 1>
     <cfset objPOI.WriteSingleExcel(
    FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
    Query = rsXLS,
	ColumnList = "INPModal,Pos_Unidade,Und_Descricao,Pos_Inspecao,PosNumGrupo,Grp_Descricao,PosNumItem,Itn_Descricao,RIP_Ano,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,RIP_Resposta,INPDtInicDeslocamento,INPDtFimInspecao,DtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,Und_CodReop,Rep_Nome,Pos_Situacao_Resp,Pos_Situacao,Dir_Codigo,Dir_Descricao,PCP_CodCausaProvavel,Cpr_Descricao,RIPRInsp,RIPRGp,RIPRIt,Quant,parecera,parecerb",
	ColumnNames = "Modalidade,CodUnidade,DescriçãoUnidade,Inspeção,Grupo,Descrição,Item,DescriçãoItem,Ano,CaractVlr,Falta,Sobra,EmRisco,Resposta,DtInicDesloc,DtFimInspeção,DtPosição,DtPrevisãoSoluc,Area,DescriçãoArea,CodReop,NomeReop,CodSituação,SiglaSit,CodSE,Sigla,CodCausaProvável,DescriçãoCausaProvável,ReInc_Relat,ReInc_Grupo,ReInc_Item,QtDias,Parecer,Parecer(compl)",
	SheetName = "Causas_Provaveis"
    ) /> 
<!--- Fim gerar planilha --->

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.style1 {color: #FFFFFF}
.style2 {
	font-size: 10px;
	text-decoration: none;
	font-family: Verdana, Arial, Helvetica, sans-serif;
	font-weight: bold;
	color: #333333;
}
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">
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
<!--- <table width="100%" align="center">
<tr>
<td valign="top" align="center"> --->
<!--- Área de conteúdo   --->
<table width="100%" height="10%" align="center" border="0">
  <tr>
    <td height="20" colspan="13">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="13"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="13">&nbsp;</td>
  </tr>

  <tr>
    <td height="10" colspan="11"><div align="right"><strong class="titulo1"><strong>Gerar causas prov&Aacute;veis</strong></strong></div></td>
	<td height="10">&nbsp;</td>
    <td height="10"><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
  </tr>
<!---     --->

  <tr><td colspan="2"><!--- <div align="left" class="titulosClaro">Nº Relat: <cfoutput>#txtNum_Inspecao#</cfoutput></div> ---></td></tr>
  <cfif rsItem.recordCount neq 0>
	  <tr class="titulosClaro">
	    <td colspan="13" bgcolor="eeeeee" class="exibir"><cfoutput>Qt. Itens: #rsItem.recordCount#</cfoutput></td>
    </tr>
	  <tr class="titulosClaro">
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
		<td colspan="2" bgcolor="eeeeee" class="exibir"><div align="left">Causa Prov&aacute;vel</div></td>
		<td colspan="7" bgcolor="eeeeee" class="exibir"><div align="left">Nome da Unidade</div></td>
		<td width="6%" bgcolor="eeeeee" class="exibir"><div align="center">Relatório</div></td>
		<td width="25%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
		<td width="23%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
	  </tr>
	<cfoutput query="rsItem">
		 <tr bgcolor="f7f7f7" class="exibir">
<!--- 		 <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="gerar_causasprovaveis11.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&Ano=#rsItem.AnoInsp#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a></div></td> --->
		 <td width="8%" bgcolor="#STO_Cor#" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><div align="center" class="branco"><strong>#trim(STO_Descricao)#</strong>
	        </div>
		   </div></td>
		   <cfset auxsaida = rsItem.PCP_CodCausaProvavel>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = rsItem.Cpr_Descricao>		  
		  <td width="14%">#auxsaida#</td>
		   <cfset auxsaida = rsItem.Und_Descricao>
		  <td colspan="7"><div align="left">#auxsaida#</div></td>
		  <cfset auxsaida = rsItem.Pos_Inspecao>
		  <td width="6%"><div align="center">#auxsaida#</div></td>
		  <td width="25%"><div align="left">#rsItem.Pos_NumGrupo# - #rsItem.Grp_Descricao#</div></td>
		  <td width="23%"><div align="justify">#rsItem.Pos_NumItem# -&nbsp;#rsItem.Itn_Descricao#</div></td>
		 </tr>
    </cfoutput>

  <cfelse>
		<tr bgcolor="f7f7f7" class="exibir">
		  <td colspan="13" align="center"><strong>Caro Usuário, nenhuma ocorrência para os dados passado como filtro de pesquisa.</strong></td>
		</tr>
		<tr><td colspan="13" align="center">&nbsp;</td></tr>
 </cfif>
		<tr><td colspan="13" align="center">&nbsp;</td></tr>
		<tr><td colspan="13" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
</table>
<!--- Fim Área de conteúdo --->	<!---   </td>
  </tr>
</table> --->
<cfinclude template="rodape.cfm">

</body>
</html>
<!---
 <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->