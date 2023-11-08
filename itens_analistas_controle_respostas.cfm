<cfprocessingdirective pageEncoding ="utf-8"/> 

<cfif isDefined("dtinic") And dtinic neq "">
  <cfset dtinic =  dateformat(dtinic,"DD/MM/YYYY")>
  <cfset dtfim = dateformat(dtfim,"DD/MM/YYYY")> 
  <cfset dtinic =  CREATEDATE(YEAR(dtinic),MONTH(dtinic),DAY(dtinic))>
  <cfset dtfim = CREATEDATE(YEAR(dtfim),MONTH(dtfim),DAY(dtfim))> 
<cfelse>
	<cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtfim = CreateDate(year(now()),month(now()),day(now()))>  
</cfif> 

<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>       

<cfif isDefined("Session.E01")>
  <cfset StructClear(Session.E01)>
</cfif>

<cfif isDefined("url.SE") >
	<cfset SE = #url.SE#>
<cfelse>
	<cfset SE = ''>
</cfif>    
<cfset txtNum_Inspecao = "">
<cfif IsDefined("url.ninsp")>
    <cfset txtNum_Inspecao = url.ninsp>
<cfelseif IsDefined("url.txtNum_Inspecao")>
	<cfset txtNum_Inspecao = url.txtNum_Inspecao>	
<cfelse>
	<cfset txtNum_Inspecao = "">
</cfif>
<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula, Usu_Coordena FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfset UsuCoordena = trim(qUsuario.Usu_Coordena)>
</cfoutput>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

<cfif isDefined("ckTipo") And ckTipo eq "inspecao">
	<cfquery name="rsBusc" datasource="#dsn_inspecao#">
	 SELECT  Pos_Situacao_Resp FROM ParecerUnidade where Pos_Inspecao = '#txtNum_Inspecao#'
	</cfquery>
	 <cfif rsBusc.recordcount is 0>
	  <cflocation url="Mens_Erro.cfm?msg=1">
	 </cfif>
		
<!---Modificado por: Marcelo em 29/07/2020 - Rotina: FLUXO DE TRATAMENTO - AGF - Retirado  Pos_Situacao_Resp <> 17 - RESPOSTA DA AGF--->	
	 <!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
	<cfquery name="rsLimite" datasource="#dsn_inspecao#">
	SELECT INP_DtFimInspecao, POS_SITUACAO_RESP  
		FROM Situacao_Ponto 
INNER JOIN (Diretoria 
INNER JOIN (Grupos_Verificacao 
INNER JOIN (Itens_Verificacao 
INNER JOIN ((Inspecao 
INNER JOIN Unidades 
ON INP_Unidade = Und_Codigo) 
INNER JOIN ParecerUnidade 
ON (INP_Unidade = Pos_Unidade) AND (INP_NumInspecao = Pos_Inspecao)) 
ON (Itn_NumItem = Pos_NumItem) AND (Itn_NumGrupo = Pos_NumGrupo)) 
ON (Itn_Ano = Grp_Ano) and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano))  
ON Dir_Codigo = Und_CodDiretoria) 
ON STO_Codigo = Pos_Situacao_Resp	
	WHERE Pos_Situacao_Resp in (1,6,7,17,22,28) AND (INP_NumInspecao = '#txtNum_Inspecao#')
   </cfquery>
    <!--- and (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2 and (Pos_Situacao_Resp in (1,6,7)))
 ---><!---Fim - Marcelo--->
 </cfif>
 <cfif isDefined("ckTipo") And ckTipo eq "status">
	<cfquery name="rsBusc" datasource="#dsn_inspecao#">
	 SELECT  Pos_Situacao_Resp FROM ParecerUnidade where Pos_Situacao_Resp = #selstatus#
	</cfquery>
	 <cfif rsBusc.recordcount is 0>
	  <cflocation url="Mens_Erro.cfm?msg=1">
	 </cfif>
	<!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->	  
	<cfquery name="rsLimite" datasource="#dsn_inspecao#">
	SELECT INP_DtFimInspecao, INP_DtEncerramento, POS_SITUACAO_RESP 
		FROM Situacao_Ponto 
INNER JOIN (Diretoria 
INNER JOIN (Grupos_Verificacao 
INNER JOIN (Itens_Verificacao 
INNER JOIN ((Inspecao 
INNER JOIN Unidades 
ON INP_Unidade = Und_Codigo) 
INNER JOIN ParecerUnidade 
ON (INP_Unidade = Pos_Unidade) AND (INP_NumInspecao = Pos_Inspecao)) 
ON (Itn_NumItem = Pos_NumItem) AND (Itn_NumGrupo = Pos_NumGrupo)) 
ON (Itn_Ano = Grp_Ano) and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano)) 
ON Dir_Codigo = Und_CodDiretoria) 
ON STO_Codigo = Pos_Situacao_Resp	
	WHERE Pos_Situacao_Resp in (1,6,7,17,22)
   </cfquery>
   <!--- and (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2 and (Pos_Situacao_Resp in (1,6,7))) --->
 </cfif>
	<cfif isDefined("ckTipo") And ckTipo eq "inspecao">
	   <cfif rsLimite.recordcount gt 0>
		 <cfset dtinic = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))>
	     <cfset dtfim = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))>
	   <cfelse>
		 <cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	     <cfset dtfim = dtinic>
	   </cfif> 
	   <cfset url.selstatus = " ">
	   <cfset url.StatusSE= " ">
	   <cfset url.SE= " ">
	 <cfelseif isDefined("ckTipo") And ckTipo eq "periodo">
	   <cfset url.dtInicio =  CreateDate(year(dtinic),month(dtinic),day(dtinic))>
	   <cfset url.dtFinal = CreateDate(year(dtfim),month(dtfim),day(dtfim))>   
	   <cfset url.selstatus = " ">
	   <cfset url.StatusSE= " ">
	   <cfset txtNum_Inspecao = " ">
	 <cfelse>
	   <cfset txtNum_Inspecao = "">
	   <cfset url.SE= " ">
	   <cfif rsLimite.recordcount gt 0>
		 <cfset dtinic = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))>
	     <cfset dtfim = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))>
	   <cfelse>
		 <cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	     <cfset dtfim = dtinic>
	   </cfif>
	</cfif>

<!---Modificado por: Marcelo em 29/07/2020 - Rotina: FLUXO DE TRATAMENTO - AGF - Retirado Und_TipoUnidade <> 12 - AGF--->
	<!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
	<cfquery name="rsItem" datasource="#dsn_inspecao#">
	SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as Modal, INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Und_TipoUnidade, Pos_Inspecao, INP_DtFimInspecao, Und_CodReop, INP_DtEncerramento, Pos_DtPosic,
	Pos_Parecer, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Itn_VALORDECLARADO, Grp_Descricao, Dir_Codigo, Dir_Sigla,
	Pos_Situacao_Resp, Dir_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, Pos_NomeArea, Pos_DtPrev_Solucao, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
	FROM Situacao_Ponto 
INNER JOIN (Diretoria 
INNER JOIN (Grupos_Verificacao 
INNER JOIN (Itens_Verificacao 
INNER JOIN ((Inspecao 
INNER JOIN Unidades 
ON INP_Unidade = Und_Codigo) 
INNER JOIN ParecerUnidade 
ON (INP_Unidade = Pos_Unidade) AND (INP_NumInspecao = Pos_Inspecao)) 
ON (Itn_NumItem = Pos_NumItem) AND (Itn_NumGrupo = Pos_NumGrupo)) 
ON (Itn_Ano = Grp_Ano) and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano))  
ON Dir_Codigo = Und_CodDiretoria) 
ON STO_Codigo = Pos_Situacao_Resp
where Pos_Situacao_Resp not in (0,3,10,11,12,13,14,24,27,29,30,51) and
		
    <cfif ckTipo eq "inspecao">
	       INP_NumInspecao = '#txtNum_Inspecao#'
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
		   Und_CodDiretoria in (#UsuCoordena#) and INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#
		<cfelse>
		   INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim# AND left(Pos_Area,2) = '#url.SE#'
		</cfif>
	<cfelse>
		<cfif StatusSE eq "Todas">
		   Pos_Situacao_Resp = #selstatus# and Und_CodDiretoria in (#UsuCoordena#)
		<cfelse>
		   Pos_Situacao_Resp = #selstatus# and left(Pos_Area,2) = '#StatusSE#'
		</cfif>
	</cfif>
	ORDER BY  Pos_DtPosic, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
	</cfquery>

<!---Fim - Marcelo--->
<!--- and (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2 and (Pos_Situacao_Resp in (1,6,7)))  --->
<cfquery name="rsXLS" datasource="#dsn_inspecao#">
SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade, Und_Descricao, Und_TipoUnidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, RIP_Ano, RIP_Resposta, RIP_Valor, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, POS_UserName, RIP_Recomendacao, Pos_ClassificacaoPonto, convert(char, Pos_PontuacaoPonto) as PosPontuacaoPonto, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, INP_Coordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, convert(char,INP_TNCPontuacao) as INPTNCPontuacao, INP_TNCClassificacao, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, trim(Pos_NomeArea) as PosNomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, Pos_NCISEI, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant
	FROM (((((Unidades INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) 
	INNER JOIN Resultado_Inspecao ON (Pos_NumItem = RIP_NumItem) AND (Pos_NumGrupo = RIP_NumGrupo) AND (Pos_Inspecao = RIP_NumInspecao) AND (Pos_Unidade = RIP_Unidade)) 
	INNER JOIN Inspecao ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade)) 
	INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
	INNER JOIN Grupos_Verificacao ON convert(char(4), RIP_Ano) = Grp_Ano and Pos_NumGrupo = Grp_Codigo) 
	INNER JOIN Itens_Verificacao ON Grp_Ano = Itn_Ano and Pos_NumItem = Itn_NumItem AND Grp_Codigo = Itn_NumGrupo AND Grp_Codigo = Itn_NumGrupo AND Grp_Codigo = Itn_NumGrupo AND Grp_Codigo = Itn_NumGrupo AND (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade)
    WHERE Pos_Situacao_Resp not in (0,3,10,11,12,13,14,24,27,29,30,31,51) and
    <cfif ckTipo eq "inspecao">
	       INP_NumInspecao = '#txtNum_Inspecao#'
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
		   Und_CodDiretoria in (#UsuCoordena#) and INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#
		<cfelse>
		   INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim# AND left(Pos_Area,2) = '#url.SE#'
		</cfif>
	<cfelse>
		<cfif StatusSE eq "Todas">
		   Pos_Situacao_Resp = #selstatus# and Und_CodDiretoria in (#UsuCoordena#)
		<cfelse>
		   Pos_Situacao_Resp = #selstatus# and left(Pos_Area,2) = '#StatusSE#'
		</cfif>
	</cfif>
	     ORDER BY Und_CodDiretoria, Pos_DtPosic, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop	
</cfquery>
 <cfif isDefined("ckTipo") And ckTipo eq "inspecao">
	<cfset dtinic = dateformat(dtinic,"dd/mm/yyyy")>
	<cfset dtfim = dateformat(dtfim,"dd/mm/yyyy")>
 <cfelseif isDefined("ckTipo") And ckTipo eq "periodo">
   <cfset url.dtInicio =  dateformat(dtinic,"dd/mm/yyyy")>
   <cfset url.dtFinal = dateformat(dtfim,"dd/mm/yyyy")>   
 <cfelse>
	   <cfif rsLimite.recordcount gt 0>
		 <cfset dtinic = dateformat(rsLimite.INP_DtFimInspecao,"dd/mm/yyyy")>
	     <cfset dtfim = dtinic>
	   <cfelse>
		 <cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	     <cfset dtfim = dtinic>
	   </cfif>
 </cfif>

<!--- Excluir arquivos anteriores ao dia atual --->
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
<!--- fim exclusão --->

<cftry>

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
	ColumnList = "Pos_ClassificacaoPonto,PosPontuacaoPonto,INPTNCPontuacao,INP_TNCClassificacao,INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,RIP_Valor,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POS_UserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INP_Coordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,PosNomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,RIPRInsp,RIPRGp,RIPRIt,Quant",
	ColumnNames = "Classif_Ponto,Pontuacao_Ponto,Pontuacao_Relatorio,Classificacao_Relatorio,Modalidade,Diretoria,Código Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,Valor,CaracteresVlr,Falta,Sobra,EmRisco,Data Ultima Atualização,Nome do Usuário,Recomendação,Hora Pré Inspeção,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,Data Posição,Data Previsão Solução,Área,Nome da Área,Parecer,Valor Recuperado,Processo,Tipo_Processo,SEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias",
	SheetName = "Controle_Manifestacoes"
    ) />

<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
<!--- =========================================== --->
<!--- Fim gerar planilha --->

<cfinclude template="cabecalho.cfm">
<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<cfquery name="rsSPnt" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
</cfquery>
 <style type="text/css">
<!--
.style1 {color: #009900}
-->
 </style>
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

function submeter(){
 document.getElementById('avisoAguarde').style.visibility = 'visible';	
 document.getElementById("frmopc").submit();
}

</script>

</head>
<body>


<cfoutput>	
<form action="itens_analistas_controle_respostas1.cfm" method="get"  enctype="multipart/form-data"  name="frmopc" id="frmopc">
</cfoutput>
	<table width="100%" height="50%">
<tr>
	<cfif isDefined("url.dtInicio")>
			<input name="dtinic" type="hidden" id="dtinic" value="<cfoutput>#url.dtInic#</cfoutput>">
			<input name="dtfim" type="hidden" id="dtfim" value="<cfoutput>#url.dtfim#</cfoutput>">
	<cfelse>
		    <input name="dtinic" type="hidden" id="dtinic" value="<cfoutput>#dtinic#</cfoutput>">
			<input name="dtfim" type="hidden" id="dtfim" value="<cfoutput>#dtfim#</cfoutput>">
	</cfif>


	<input name="ckTipo" type="hidden" id="ckTipo" value="<cfoutput>#ckTipo#</cfoutput>">
	<input name="selStatus" type="hidden" id="selStatus" value="<cfoutput>#selStatus#</cfoutput>">
	<input name="StatusSE" type="hidden" id="StatusSE" value="<cfoutput>#StatusSE#</cfoutput>">
	<input name="txtNum_Inspecao" type="hidden" id="txtNum_Inspecao" value="<cfoutput>#txtNum_Inspecao#</cfoutput>">
	<input name="SE" type="hidden" id="SE" value="<cfoutput>#SE#</cfoutput>">   

		

	<cfif isDefined("Submit1")>
	   <input name="Submit1" type="hidden" id="Submit1" value="<cfoutput>#Submit1#</cfoutput>">
	<cfelse>
		<cfset  Submit1 = ''>  
	</cfif>
	<cfif isDefined("Submit2")>
		<input name="Submit2" type="hidden" id="Submit2" value="<cfoutput>#Submit2#</cfoutput>">
	<cfelse>
		<cfset  Submit2 = ''>  
	</cfif>
	<cfif isDefined("Submit3")>
		<input name="Submit3" type="hidden" id="Submit3" value="<cfoutput>#Submit3#</cfoutput>">
	<cfelse>
		<cfset  Submit3 = ''>  
	</cfif>

	

<td valign="top" align="center">

	
<!--- Área de conteúdo   --->



<table width="100%" class="exibir">
  
  <tr>
    <td height="20" colspan="13"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
 
    
  <tr>
    <td height="20" colspan="13">&nbsp;</td>
  </tr>

  <tr>
    <td height="10" colspan="13"><div align="center"><strong class="titulo1">Controle das MANIFESTA&Ccedil;&Otilde;ES</strong></div></td>
   <cfif trim(qAcesso.Usu_GrupoAcesso) eq 'ANALISTAS'>
	<td height="10" colspan="2"><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
  </cfif>
   </tr>
  <tr >
	
	<td colspan="3" >
		
	  <tr><td colspan="3"><div align="center" class="titulosClaro"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div></td></tr>
	<cfif rsItem.recordCount neq 0>

	<tr class="titulosClaro">
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
		<td width="4%" bgcolor="eeeeee" class="exibir"><div align="center">Modalidade</div></td>
		<td width="4%" bgcolor="eeeeee" class="exibir"><div align="center">Posi&ccedil;&atilde;o</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Previs&atilde;o</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Acompanhamento (dias &uacute;teis) </div></td> 
		<td width="2%" bgcolor="eeeeee" class="exibir"><div align="center">SE Sigla</div></td>
		<td width="9%" bgcolor="eeeeee" class="exibir"><div align="center">&Oacute;rg&atilde;o Condutor</div></td>
		<td width="6%" bgcolor="eeeeee" class="exibir"><div align="center">In&iacute;cio</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Fim</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Envio Ponto</div></td>
		<td width="6%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Relat&oacute;rio</div></td>
		<td width="12%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
		<td width="11%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><strong>Encaminhamento</strong></td>		
		<td width="6%" bgcolor="eeeeee" class="exibir"><div align="center">Qtd. Dias</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Classificação</div></td>  
	</tr>
	<cfoutput query="rsItem">
	  <cfset auxEnc = "MANUAL">
      <cfset btnSN = 'N'>
	  <cfif Pos_Situacao_Resp eq 4 or Pos_Situacao_Resp eq 16>
			<cfquery name="rsAnd" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade 
			FROM Andamento INNER JOIN ParecerUnidade ON (Pos_Situacao_Resp = And_Situacao_Resp) AND (Pos_DtPosic = And_DtPosic) AND (Pos_NumItem = And_NumItem) AND (Pos_NumGrupo = And_NumGrupo) AND (Pos_Inspecao = And_NumInspecao) AND (And_Unidade = Pos_Unidade) 
			WHERE (((Pos_Situacao_Resp)=#Pos_Situacao_Resp#) AND ((And_username) Like 'rotina%')) AND (And_Unidade = '#Pos_Unidade#') and (And_NumInspecao = '#Pos_Inspecao#') and (And_NumGrupo = #Pos_NumGrupo#) and (And_NumItem = #Pos_NumItem#)
			</cfquery>	
			<cfif rsAnd.recordcount gt 0>
			   <cfset auxEnc = "AUTOMÁTICO">
			   <cfset btnSN = 'S'>
			</cfif>
	  </cfif>
	  	   <!---  --->
		 <cfset dtFUP = "">
         <cfset dtposic = CreateDate(year(rsItem.Pos_DtPosic),month(rsItem.Pos_DtPosic),day(rsItem.Pos_DtPosic))>
		 <cfset nCont = 1>
		 <cfset nFinal = 15>
		    <cfloop condition="nCont lte nFinal">
			  <cfset dtposic = DateAdd("d", 1, #dtposic#)>
			  <cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtposic#
			  </cfquery>
			  <cfif rsFeriado.recordcount gt 0>
					<cfset nFinal = nFinal + 1>
			  <cfelse>
				  <cfset vDiaSem = DayOfWeek(dtposic)>
				  <cfswitch expression="#vDiaSem#">
						   <cfcase value="1">
								<!--- domingo --->
								<cfset nFinal = nFinal + 1>
						   </cfcase>
							<cfcase value="7">
								<cfset nFinal = nFinal + 1>
							</cfcase>
			    </cfswitch>
			  </cfif>
			  <cfset nCont = nCont + 1>
		   </cfloop>
		   <cfset dtFUP = DateFormat(dtposic,'DD/MM/YYYY')> 
		   <!---  --->
		 <tr bgcolor="f7f7f7" class="exibir">
            <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_analistas_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#url.SE#&selStatus=#selStatus#&StatusSE=#StatusSE#&txtNum_Inspecao=#txtNum_Inspecao#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a></div></td>
		  
		  <cfset auxsaida = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
		  <td><div align="center">#rsItem.Modal#</div></td>
		  <td>#auxsaida#</td>
		  <cfset auxsaida = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')>
		  <td width="8%" class="red_titulo"><div align="center" class="red_titulo">#auxsaida#</div></td>
		  <td width="5%" bgcolor="f7f7f7" class="exibir"><div align="center" class="titulos style1">#dtFUP#</div></td> 
		  <td width="2%"><div align="center">#rsItem.Dir_Sigla#</div></td>
		  <cfset auxsaida = rsItem.Pos_NomeArea>
		  <td width="9%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')>
		  <td width="6%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = rsItem.Und_Descricao>
		  <td width="6%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = rsItem.Pos_Inspecao>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <td width="12%"><div align="center">#rsItem.Pos_NumGrupo# - #rsItem.Grp_Descricao#</div></td>
		  <td><div align="center">#rsItem.Pos_NumItem# -&nbsp;#rsItem.Itn_Descricao#</div></td>
		  <td><div align="center">#auxEnc#</div></td>
		  <cfset dias = rsItem.Quant>
		  <td width="6%"><div align="center">#dias#</div></td>
		  <cfset auxsaida = rsItem.Pos_ClassificacaoPonto>
		  <td width="8%" class="exibir"><div align="center">#auxsaida#</div></td>
		 </tr>
		
    </cfoutput>
  <cfelse>
		<tr bgcolor="f7f7f7" class="exibir">
          <cfif isDefined("ckTipo") and #ckTipo# eq 'inspecao'>
		     <td colspan="14" align="center"><strong>Sr. Analista, todos os itens deste relatório foram solucionados, portanto, a inspeção encontra-se encerrada.</strong></td>
		  <cfelse>
			<td colspan="12" align="center"><strong>Sr. Analista, não foram localizados itens para os parâmentos informados.</strong></td>
		 </cfif>


		</tr>
		<tr><td colspan="14" align="center">&nbsp;</td></tr>
  </cfif>
  
		<tr><td colspan="14" align="center">&nbsp;</td></tr>
		<tr><td colspan="14" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
	</table>
</div>
<!--- Fim Área de conteúdo --->	 
   </td>
  </tr>

</table>
<input name="acao" type="hidden">
</form>
<cfinclude template="rodape.cfm">

</body>
</html>
<!---
 <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->
