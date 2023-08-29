<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
  <cfabort>
</cfif>     

 <cfif isDefined("Session.E01")>
   <cfset StructClear(Session.E01)> 
</cfif> 
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Lotacao from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="qReop" datasource="#dsn_inspecao#">
  SELECT DISTINCT(Rep_Codigo), Rep_Sigla, Rep_CodDiretoria, Rep_Nome
  FROM Reops
  WHERE Rep_Codigo = '#qAcesso.Usu_Lotacao#'
  ORDER BY Rep_Sigla ASC
</cfquery>

<cfif ckTipo eq "1">
      <cfset sigla = #qReop.Rep_Sigla#>
<cfelse>
	  <cfset sigla = 'TODAS AS UNIDADES SUBORDINADAS À(AO) #qReop.Rep_Sigla#'>
</cfif>
	
<cfset url.reop = '#qAcesso.Usu_Lotacao#'>
    
 
<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'ORGAOSUBORDINADOR'>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
	 <cfif ckTipo eq "1">
       SELECT Pos_Area, INP_DtInicInspecao, Pos_NumItem, Pos_Unidade, Pos_DtPrev_Solucao, Pos_DtPosic, DATEDIFF(dd, Pos_DtPosic, GETDATE())
	   AS Quant, Unidades.Und_Descricao, Pos_Inspecao, Pos_NumGrupo, pos_dtultatu, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS data,
	   Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp, Rep_Codigo, Rep_Nome, RIP_NumInspecao, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem, Pos_Parecer,
	   INP_DtInicInspecao, INP_DtFimInspecao, INP_DtEncerramento, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_ClassificacaoPonto
     FROM Reops 
INNER JOIN Resultado_Inspecao 
INNER JOIN Grupos_Verificacao 
INNER JOIN Unidades 
INNER JOIN ParecerUnidade 
INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
ON Und_Codigo = Pos_Unidade 
ON Grp_Codigo = Pos_NumGrupo 
ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
ON Rep_Codigo = RIP_CodReop AND rip_ano = Grp_Ano 
INNER JOIN Itens_Verificacao ON Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem AND 
convert(char(4),RIP_Ano) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
INNER JOIN Situacao_Ponto 
ON Pos_Situacao_Resp = STO_Codigo

       WHERE  (Pos_Area = '#url.reop#') and (Pos_Situacao_Resp in (4,16,21))

	<cfelse>
       SELECT Pos_Area, INP_DtInicInspecao, Pos_NumItem, Pos_Unidade, Pos_DtPrev_Solucao, Pos_DtPosic, DATEDIFF(dd, Pos_DtPosic, GETDATE())
	   AS Quant, Unidades.Und_Descricao, Pos_Inspecao, Pos_NumGrupo, pos_dtultatu, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS data,
	   Itn_Descricao, Grp_Descricao, Pos_Situacao_Resp, Rep_Codigo, Rep_Nome, RIP_NumInspecao, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem, Pos_Parecer,
	   INP_DtInicInspecao, INP_DtFimInspecao, INP_DtEncerramento, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_ClassificacaoPonto
	    FROM Reops 
INNER JOIN Resultado_Inspecao 
INNER JOIN Grupos_Verificacao 
INNER JOIN Unidades 
INNER JOIN ParecerUnidade 
INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
ON Und_Codigo = Pos_Unidade 
ON Grp_Codigo = Pos_NumGrupo 
ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
ON Rep_Codigo = RIP_CodReop AND rip_ano = Grp_Ano 
INNER JOIN Itens_Verificacao ON Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem AND 
convert(char(4),RIP_Ano) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
INNER JOIN Situacao_Ponto 
ON Pos_Situacao_Resp = STO_Codigo
	
	     <cfif  '#frmResp#' neq '' >
            <cfswitch expression='#frmResp#'>
             <cfcase value="N">WHERE  ((Und_CodReop = '#qAcesso.Usu_Lotacao#' AND Pos_Area = Pos_Unidade)  or Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (2,4,5,14,15,16,19) </cfcase>
             <cfcase value="S">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND Pos_Area = Pos_Unidade AND pos_situacao_resp in (3)) a</cfcase>
             <cfcase value="A">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (24))</cfcase>
             <cfcase value="R">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade=12)</cfcase>
             <cfcase value="C">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (9))</cfcase>
			 <cfcase value="E">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (29))</cfcase>
            </cfswitch>
       </cfif>
       <cfset dataInicio = '#dtinicial#'>
       <cfset dataFim = '#dtfinal#'>
      
       <cfif dtinicial neq '' and dtfinal neq ''> 
          <cfset dataInicio = createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
          <cfset dataFim = createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>     
       </cfif>
              
       <cfif  '#dataInicio#' neq '' and '#dataFim#' neq ''> 
          AND (Pos_DtPosic BETWEEN #dataInicio# AND #dataFim#)
        </cfif>
    </cfif>
        ORDER BY Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
</cfquery>


<cfquery name="rsXLS" datasource="#dsn_inspecao#">
 <cfif ckTipo eq "1">    
  SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Unidades.Und_CodDiretoria, Pos_Unidade, Unidades.Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Unidades.Und_CodReop, RIP_Ano, RIP_Resposta, substring(RIP_Comentario,1,32500) as comentario, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, Pos_ClassificacaoPonto 
        FROM Reops 
INNER JOIN Resultado_Inspecao 
INNER JOIN Grupos_Verificacao 
INNER JOIN Unidades 
INNER JOIN ParecerUnidade 
INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
ON Und_Codigo = Pos_Unidade 
ON Grp_Codigo = Pos_NumGrupo 
ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
ON Rep_Codigo = RIP_CodReop AND rip_ano = Grp_Ano 
INNER JOIN Itens_Verificacao ON Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem AND 
convert(char(4),RIP_Ano) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
INNER JOIN Situacao_Ponto 
ON Pos_Situacao_Resp = STO_Codigo 
 WHERE  (Pos_Area = '#url.reop#') and (Pos_Situacao_Resp in (4,16,21))

	<cfelse>
       SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Unidades.Und_CodDiretoria, Pos_Unidade, Unidades.Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Unidades.Und_CodReop, RIP_Ano, RIP_Resposta, substring(RIP_Comentario,1,32500) as comentario, RIP_Valor, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, Pos_ClassificacaoPonto
FROM Reops 
INNER JOIN Resultado_Inspecao 
INNER JOIN Grupos_Verificacao 
INNER JOIN Unidades 
INNER JOIN ParecerUnidade 
INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
ON Und_Codigo = Pos_Unidade 
ON Grp_Codigo = Pos_NumGrupo 
ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
ON Rep_Codigo = RIP_CodReop AND rip_ano = Grp_Ano 
INNER JOIN Itens_Verificacao ON Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem AND 
convert(char(4),RIP_Ano) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
INNER JOIN Situacao_Ponto 
ON Pos_Situacao_Resp = STO_Codigo
	
	     <cfif  '#frmResp#' neq '' >
            <cfswitch expression='#frmResp#'>
             <cfcase value="N">WHERE  ((Und_CodReop = '#qAcesso.Usu_Lotacao#' AND Pos_Area = Pos_Unidade)  or Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (2,4,5,14,15,16,19) </cfcase>
             <cfcase value="S">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND Pos_Area = Pos_Unidade AND pos_situacao_resp in (3)) a</cfcase>
             <cfcase value="A">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (24))</cfcase>
             <cfcase value="R">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade=12)</cfcase>
             <cfcase value="C">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (9))</cfcase>
			 <cfcase value="E">WHERE  (Und_CodReop = '#qAcesso.Usu_Lotacao#' AND pos_situacao_resp in (29))</cfcase>
            </cfswitch>
       </cfif>
       <cfset dataInicio = '#dtinicial#'>
       <cfset dataFim = '#dtfinal#'>
      
       <cfif dtinicial neq '' and dtfinal neq ''> 
          <cfset dataInicio = createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
          <cfset dataFim = createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>     
       </cfif>
              
       <cfif  '#dataInicio#' neq '' and '#dataFim#' neq ''> 
          AND (Pos_DtPosic BETWEEN #dataInicio# AND #dataFim#)
        </cfif>
    </cfif>
        ORDER BY Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
</cfquery>

 <!--- <cfdump var="#rsItem#">  --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style type="text/css">
<!--
.style5 {font-size: 14; font-weight: bold; }
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
<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
</cfoutput>
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
	ColumnList = "INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,RIPRInsp,RIPRGp,RIPRIt,Quant",
	ColumnNames = "Modalidade,Diretoria,Código Unidade Inspecionada,Unidade Inspecionada,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,Hora Pré Inspeção,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,Data Previsão Solução,Código Órgão Condutor,Órgão Condutor,Parecer,Valor Recuperado,Processo,Tipo_Processo,SEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias",
	SheetName = "OrgaoSubordinador"
    ) />

<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
<!--- =========================================== --->
<!--- Fim gerar planilha --->

<cfinclude template="cabecalho.cfm">
<table width="100%" height="45%">
<tr>
<td valign="top">
<!--- Área de conteúdo   --->
<table width="100%" class="exibir">

  <tr>
    <td height="20%" colspan="13"><div align="center"><span class="style5"><cfoutput>#sigla#</cfoutput></span></div></td>
  </tr><br>
   <tr><td colspan="13" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
  <tr><br>
    <td height="20%" colspan="13"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
  </tr>
 
  <tr>
    <td height="20%" colspan="13" class="titulosClaro"><div align="center"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div></td>
  </tr>
    <tr>	   
     <td width="7%" align="center" bgcolor="eeeeee" class="exibir"><strong>Status</strong></td>
     <td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Posição</strong></td>
     <td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Dt. Previsão Solução Até</strong></td>
     <td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Início</strong></td>
     <td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Fim</strong></td>
     <td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Envio Ponto</strong></td>
     <td width="10%" align="center" bgcolor="eeeeee" class="exibir"><strong>Unidade Inspecionada</strong></td>
     <td width="12%" align="center" bgcolor="eeeeee" class="exibir"><strong>Órgão Condutor</strong></td>
     <td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Relatório</strong></td>
     <td width="12%" align="center" bgcolor="eeeeee" class="exibir"><strong>Grupo</strong></td>
     <td width="12%" align="center" bgcolor="eeeeee" class="exibir"><strong>Item</strong></td>
     <td width="4%" align="center" bgcolor="eeeeee" class="exibir"><strong>Encaminhamento</strong></td>
  <!---    <td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Quant. de Dias</strong></td> --->
     <td width="3%" align="center" bgcolor="eeeeee" class="exibir"></td> 
     <td width="4%" align="center" bgcolor="eeeeee" class="exibir"><strong>Classif. Item</strong></td>
   </tr>
	<!---Cria uma instância do componente Dao--->
	<cfobject component = "CFC/Dao" name = "dao">
<cfoutput query="rsItem">
	<cfset numReincInsp = ''>
	<cfif len(trim(rsItem.RIP_ReincInspecao)) gt 0>
		<cfset numReincInsp = 'item REINCIDENTE (' & Left(rsItem.RIP_ReincInspecao,2) & '.' & Mid(rsItem.RIP_ReincInspecao,3,4) & '/' & Right(rsItem.RIP_ReincInspecao,4) & ')'>
	</cfif>

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
	<cfquery name="rsStatus011" datasource="#dsn_inspecao#">
		SELECT Pos_Inspecao 
		FROM ParecerUnidade 
		WHERE (Pos_Inspecao = '#rsItem.Pos_Inspecao#') AND (Pos_Situacao_Resp = 0 Or Pos_Situacao_Resp = 11)
	  </cfquery>
	 <cfif rsStatus011.recordcount lte 0>
<!---Invoca o metodo  OrgaoCondutor para retornar a descricao do órgão condutor--->
	<cfinvoke component="#dao#" method="DescricaoPosArea" returnVariable="DescricaoPosArea" CodigoDaUnidade='#rsItem.pos_area#'>	
	
<tr bgcolor="f7f7f7">
    <cfif btnSN eq 'N'> 
      <td width="7%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_unidades_controle_respostas1_reop2.cfm?ckTipo=#URL.ckTipo#&Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#rsItem.Rep_Codigo#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a></div></td>
	<cfelse>
      <td width="7%" bgcolor="A80643"><div align="center"><a href="itens_unidades_controle_respostas1_reop2.cfm?ckTipo=#URL.ckTipo#&Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&Situacao=#rsItem.Pos_Situacao_Resp#&Reop=#rsItem.Rep_Codigo#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>PERDA PRAZO UNIDADE</strong></a></div></td>
	</cfif>  
	<!---    </cfif> --->
      <cfset auxtela = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
	  <td width="3%"><div align="center">#auxtela#</div></td>
	  <cfset auxtela = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')>
	  <td width="3%"><div align="center">#auxtela#</div></td>
	  <cfset auxtela = DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')>
      <td width="3%"><div align="center">#auxtela#</div></td>
	  <cfset auxtela = DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')>
      <td width="3%"><div align="center">#auxtela#</div></td>
	  <cfset auxtela = DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')>
	  <td width="3%"><div align="center">#auxtela#</div></td>
	  <td width="10%"><div align="center">#rsItem.Und_Descricao#</div></td>  
	  <td width="12%"><div align="center">#DescricaoPosArea#</div></td>       
	  <cfset auxtela = rsItem.Pos_Inspecao>
      <td width="3%"><div align="center">#auxtela#</div></td>
      <td width="12%"><div align="center"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="12%"><div align="justify"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>
	  <td width="4%"><div align="center">#auxEnc#</div></td>
	 <!---  <td width="3%"><div align="center"><strong>#rsItem.Quant#</strong></div></td> --->
	  <td width="12%" class="red_titulo"><div align="center"><strong>#numReincInsp#</strong></div></td>
      <cfset auxs = rsItem.Pos_ClassificacaoPonto>
	   <td width="4%"><div align="center"><div align="center">#auxs#</div></td>   
    </tr>
	 </cfif>
  </cfoutput>
 
   <tr><td colspan="13" align="center">&nbsp;</td></tr>
   <tr><td colspan="13" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
 </table>

<!--- Fim Área de conteúdo --->
    </td>
  </tr>
</table>
<cfinclude template="rodape.cfm">
</body>
</html>

<cfelse>
      <cfinclude template="permissao_negada.htm">
      <cfabort>
 </cfif>