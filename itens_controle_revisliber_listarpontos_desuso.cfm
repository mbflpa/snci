<cfprocessingdirective pageEncoding ="utf-8"/>
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   

<CFSET gestorMaster = TRIM('GESTORMASTER')/>
<cfquery name="qUsuarioGestorMaster" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_GrupoAcesso FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and Usu_GrupoAcesso = '#gestorMaster#'
</cfquery>

<cfif isDefined("Session.E01")>
  <cfset StructClear(Session.E01)>
</cfif>
<!--- limpar .XLS --->
<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>  

<cfdirectory name="qList" filter="*.*" sort="name asc" directory="#slocal#">
<cfoutput query="qList">
   <cfset sdtarquivo = dateformat(dateLastModified,"YYYYMMDDHH")> 
	   <cfif left(sdtatual,8) eq left(sdtarquivo,8)>
			<cfif (right(sdtatual,2) - right(sdtarquivo,2)) gte 2>
			   <cffile action="delete" file="#slocal##name#">  
			</cfif>
	  <cfelseif left(sdtatual,8) gt left(sdtarquivo,8)>
		<cffile action="delete" file="#slocal##name#">
	  </cfif>
<!--- 	 data atual: #sdtatual# -     Data do arquivo: #sdtarquivo#   nome do arquivo: #name#<br> --->
</cfoutput>

 <!--- <cftry> --->

<!---  <cfdump var="#Form#">
<cfdump var="#URL#"> --->


<cfif IsDefined("url.ninsp")>
<cfset txtNum_Inspecao = url.ninsp>
</cfif>


<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>
	
<cfif isDefined("ckTipo") And ckTipo eq "inspecao">
	<cfquery name="rsBusc" datasource="#dsn_inspecao#">
	 SELECT  Pos_Situacao_Resp FROM ParecerUnidade where Pos_Inspecao = '#txtNum_Inspecao#'
	</cfquery>
	 <cfif rsBusc.recordcount is 0>
	  <cflocation url="Mens_Erro.cfm?msg=1">
	 </cfif>
	 
	<!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->	 
	<cfquery name="rsLimite" datasource="#dsn_inspecao#">
	SELECT INP_DtFimInspecao 
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
ON (Itn_Ano = Grp_Ano) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano) and (Itn_TipoUnidade = Und_TipoUnidade) and (inp_modalidade = itn_Modalidade)) 
ON Dir_Codigo = Und_CodDiretoria) 
ON STO_Codigo = Pos_Situacao_Resp
	WHERE 
	<cfif qUsuarioGestorMaster.recordcount neq 0 >
		(Pos_Situacao_Resp not in (3,12,13,24,25,26,27,51))
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,12,13,24,25,26,27,51))
    </cfif>	
	and ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (INP_NumInspecao = '#txtNum_Inspecao#')
	AND 1 = CASE WHEN Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END 
	
   </cfquery>
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
	SELECT INP_DtFimInspecao 
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
ON (Itn_Ano = Grp_Ano) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano) and (Itn_TipoUnidade = Und_TipoUnidade) and (inp_modalidade = itn_Modalidade)) 
ON Dir_Codigo = Und_CodDiretoria) 
ON STO_Codigo = Pos_Situacao_Resp
	WHERE
	<cfif qUsuarioGestorMaster.recordcount neq 0 >
		(Pos_Situacao_Resp not in (3,12,13,24,25,26,27,51))
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,12,13,24,25,26,27,51))
    </cfif>	

	and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
	
	AND 1 = CASE WHEN Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END 
			
			
   </cfquery>
 </cfif>
 <cfif isDefined("ckTipo") And ckTipo eq "inspecao">
   <cfset dtinic = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
   <cfset dtfim = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
   <cfset url.selstatus = " ">
   <cfset url.StatusSE= " ">
 <cfelseif isDefined("ckTipo") And ckTipo eq "periodo">
   <cfset url.dtInicio = #dtinic#>
   <cfset url.dtFinal = #dtfim#>
   <cfset url.selstatus = " ">
   <cfset url.StatusSE= " ">
   <cfset txtNum_Inspecao = "">
   <cfset url.dtInicio = CreateDate(Right(dtinic,4), Mid(dtinic,4,2), Left(dtinic,2))>
   <cfset url.dtFinal = CreateDate(Right(dtfim,4), Mid(dtfim,4,2), Left(dtfim,2))>
 <cfelse>
   <cfset txtNum_Inspecao = "">
   <cfset dtinic = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
   <cfset dtfim = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
</cfif>
        <!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
	<cfquery name="rsItem" datasource="#dsn_inspecao#">
	SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as Modal,  INP_Modalidade as INPModalidade, INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Und_TipoUnidade, Pos_Inspecao, INP_DtFimInspecao, Und_CodReop, INP_DtEncerramento, Pos_DtPosic, Pos_Parecer, Pos_NumGrupo, Pos_NumItem,Pos_NCISEI, pos_dtultatu, Itn_Descricao, Itn_ValorDeclarado, Grp_Descricao, Dir_Codigo,
	Pos_Situacao_Resp, Dir_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, Pos_NomeArea, Pos_DtPrev_Solucao, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao
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
ON (Itn_Ano = Grp_Ano) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano) and (Itn_TipoUnidade = Und_TipoUnidade) and (inp_modalidade = itn_Modalidade)) 
ON Dir_Codigo = Und_CodDiretoria) 
ON STO_Codigo = Pos_Situacao_Resp
	WHERE (Pos_Situacao_Resp in (0,11))
	
	<cfif ckTipo eq "inspecao">
	   and (INP_NumInspecao = '#txtNum_Inspecao#')
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
		  and (INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#)
		<cfelse>
		  and (INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#) AND (Und_CodDiretoria = '#url.SE#')
		</cfif>
	<cfelse>
		<cfif StatusSE eq "Todas">
		  and (Pos_Situacao_Resp = #selstatus#)
		<cfelse>
		  and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
		</cfif>
	</cfif>
	     ORDER BY Pos_DtPosic, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, Data
	</cfquery> 
<!--- gerar planilha  Gilvan 09/05/2019 --->
    <!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
<!--- 	AND 1 = CASE WHEN Itn_TipoUnidade = 99 And Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END --->
	<cfquery name="rsXLS" datasource="#dsn_inspecao#">
	SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade, Und_Descricao, Und_TipoUnidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, RIP_Ano, RIP_Resposta, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, Pos_NCISEI, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant 
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
ON (Itn_Ano = Grp_Ano) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano) and (Itn_TipoUnidade = Und_TipoUnidade) and (inp_modalidade = itn_Modalidade)) 
ON Dir_Codigo = Und_CodDiretoria) 
ON STO_Codigo = Pos_Situacao_Resp
WHERE (Pos_Situacao_Resp in (0,11))
	
	<cfif ckTipo eq "inspecao">
	  and (INP_NumInspecao = '#txtNum_Inspecao#')
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
		  and (INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#)
		<cfelse>
		  and (INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#) AND (Und_CodDiretoria = '#url.SE#')
		</cfif>
	<cfelse>
		<cfif StatusSE eq "Todas">
		  and (Pos_Situacao_Resp = #selstatus#)
		<cfelse>
		  and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
		</cfif>
	</cfif>
	     ORDER BY Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop
	</cfquery> 
<!--- 
	AND 1 = CASE WHEN Itn_TipoUnidade = 99 And Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END --->
<!--- dados temporário --->

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
	ColumnList = "INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,Pos_NCISEI,RIPRInsp,RIPRGp,RIPRIt,Quant",
	ColumnNames = "Modalidade,Diretoria,Código Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,Hora Pré Inspeção,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,Data Previsão Solução,Área,Nome da Área,Parecer,Valor Recuperado,Processo,Tipo_Processo,SEI,NCISEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias",
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
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="css.css" rel="stylesheet" type="text/css">
 <cfquery name="rsSPnt" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
 </cfquery>
 <style type="text/css">
<!--
.style1 {
	color: #009900;
	font-weight: bold;
}
-->
 </style>
<cfoutput query="rsSPnt">
 <div id="#rsSPnt.STO_Sigla#" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
 <font size="1" face="Verdana" color="000000">#rsSPnt.STO_Conceito#</font></div>
</cfoutput>
</head>
<body>
 <cfif isDefined("ckTipo") And ckTipo eq "inspecao">
		<!---Veirifcao se esta inspeção possui algum item em reanálise --->
		<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
			SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
			WHERE RIP_Recomendacao='S' and RIP_NumInspecao='#txtNum_Inspecao#'
		</cfquery>
		<cfif qVerifEmReanalise.recordcount neq 0 > 
		<div align="center">
			<div align="center" style="position:RELATIVE; top:3px;background:red;color:#fff;width:640px;padding:3px;font-family:Verdana, Arial, Helvetica, sans-serif">				
			  <div style="float: left;">
			    <img id="imgAtencao" name="imgAtencao"src="figuras/atencao.png" width="40px"  border="0" ></img>
			  </div>
			  <div style="float: left;">
				<cfif qVerifEmReanalise.recordcount eq 1 >
					<span style="font-size:10px;position:relative;top:5px"><strong>Sr. Gestor, existe 01 item pendente de REANÁLISE pelo Inspetor. Esta Verificação poderá ser liberada somente quando os ajustes forem realizados pelo Inspetor!</strong></span> 
				<cfelse>
					<span style="font-size:10px;position:relative;top:5px"><strong>Sr. Gestor, existem <cfoutput>#qVerifEmReanalise.recordcount#</cfoutput> itens pendentes de REANÁLISE pelo Inspetor. Esta Verificação poderá ser liberada somente quando os ajustes forem realizados pelo Inspetor!</strong></span> 
				</cfif>
			  </div>
			</div>
		</div>
		</cfif>
</cfif>
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
    <td height="20" colspan="16">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="16"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="16">&nbsp;</td>
  </tr>

  <tr>
    <td height="10" colspan="14"><div align="center"><strong class="titulo1">CONTROLE DAS MANIFESTAÇÕES</strong></div></td>
      <td height="10" colspan="2"><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
  </tr>

  <tr><!---<td colspan="2"> <div align="left" class="titulosClaro">Nº Relat: <cfoutput>#txtNum_Inspecao#</cfoutput></div> ---></td></tr>
  <cfif rsItem.recordCount neq 0>
	  <tr class="titulosClaro">
	    <td colspan="16" bgcolor="eeeeee" class="exibir"><cfoutput>Qt. Itens: #rsItem.recordCount#</cfoutput></td>
    </tr>
	  <tr class="titulosClaro">
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
		<td width="2%" bgcolor="eeeeee" class="exibir"><div align="center">Modalidade</div></td>
		<td width="3%" bgcolor="eeeeee" class="exibir">Posição</td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Previsão</div></td>
		<td width="4%" bgcolor="eeeeee" class="exibir"><div align="center">Acompanhamento (dias &uacute;teis)</div></td>
		<td width="4%" bgcolor="eeeeee" class="exibir">Órgão Condutor</td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Início</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Fim</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Envio Ponto</div></td>
		<td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Relatório</div></td>
		<td width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
		<td width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><strong>Encaminhamento</strong></td>		
	    <td width="4%" bgcolor="eeeeee" class="exibir"><div align="center">Qtd. de Dias</div></td>
	  </tr>
	<cfoutput query="rsItem">
	  <cfset auxEnc = "MANUAL">
      <cfset btnSN = 'N'>
	  <cfif Pos_Situacao_Resp eq 4 or Pos_Situacao_Resp eq 16>
			<cfquery name="rsAnd" datasource="#dsn_inspecao#">
			SELECT Pos_Unidade 
			FROM Andamento 
			INNER JOIN ParecerUnidade ON (Pos_Situacao_Resp = And_Situacao_Resp) AND (Pos_DtPosic = And_DtPosic) AND (Pos_NumItem = And_NumItem) AND (Pos_NumGrupo = And_NumGrupo) AND (Pos_Inspecao = And_NumInspecao) AND (And_Unidade = Pos_Unidade) 
			WHERE (((Pos_Situacao_Resp)=#Pos_Situacao_Resp#) AND ((And_username) Like 'rotina%')) AND (And_Unidade = '#Pos_Unidade#') and (And_NumInspecao = '#Pos_Inspecao#') and (And_NumGrupo = #Pos_NumGrupo#) and (And_NumItem = #Pos_NumItem#)
			</cfquery>	
			<cfif rsAnd.recordcount gt 0>
			   <cfset auxEnc = "AUTOMÁTICO"> 
			   <cfset btnSN = 'S'>
			</cfif>
	  </cfif>
	   <!---  --->
		<cfset dtposic = CreateDate(year(rsItem.Pos_DtPosic),month(rsItem.Pos_DtPosic),day(rsItem.Pos_DtPosic))>
		<cfset nCont = 1>
		<cfloop condition="nCont lte 15">
			<cfset dtposic = DateAdd( "d", 1, dtposic)>
			<cfset vDiaSem = DayOfWeek(dtposic)>
			<cfif vDiaSem neq 1 and vDiaSem neq 7>
				<!--- verificar se Feriado Nacional --->
				<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
					 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtposic#
				</cfquery>
				<cfif rsFeriado.recordcount gt 0>
				   <cfset nCont = nCont - 1>
				</cfif>
			</cfif>
			<!--- Verifica se final de semana  --->
			<cfif vDiaSem eq 1 or vDiaSem eq 7>
				<cfset nCont = nCont - 1>
			</cfif>	
			<cfset nCont = nCont + 1>
		</cfloop>		
		    
		   <cfset dtFUP = DateFormat(dtposic,'DD/MM/YYYY')>
		   <!---  --->
		 <tr bgcolor="f7f7f7" class="exibir">
<!--- 		 <cfif btnSN eq 'N'> --->
         
<!--- 	<cfelse>
         <td width="8%" bgcolor="A80643"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>PERDA PRAZO UNIDADE</strong></a></div></td>
	</cfif>  --->
	<cfif rsItem.Pos_Situacao_Resp is 0 or rsItem.Pos_Situacao_Resp is 11>
	    <cfquery name="qReanalisado" datasource="#dsn_inspecao#">
			SELECT RIP_Recomendacao FROM Resultado_Inspecao
			WHERE RIP_NumInspecao = '#rsItem.Pos_Inspecao#' and RIP_NumGrupo='#rsItem.Pos_NumGrupo#' and RIP_NumItem ='#rsItem.Pos_NumItem#'
		</cfquery>
		  <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_controle_revisliber.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#&modal=#rsItem.INPModalidade#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong><cfif '#trim(rsItem.Pos_NCISEI)#' neq '' and '#rsItem.Pos_Situacao_Resp#' eq 0><span style="color:white"><br>com NCI</span></cfif><cfif '#qReanalisado.RIP_Recomendacao#' eq 'R' and '#rsItem.Pos_Situacao_Resp#' eq 0><div ><span style="color:white;background:darkblue;padding:2px;"><br>REANALISADO</span></div></cfif></a></div></td>
  <cfelse>
         <!---  <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a><cfif '#trim(rsItem.Pos_NCISEI)#' neq '' and '#rsItem.Pos_Situacao_Resp#' eq 0><span style="color:white"><br>com NCI</span></cfif></a></div></td> --->
  </cfif>		  
		  <cfset auxsaida = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
		  <td width="2%"><div align="center">#rsItem.Modal#</div></td>
		  <td width="3%">#auxsaida#</td>
		  <cfset auxsaida = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')>
		  <td width="5%" class="red_titulo"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = rsItem.Pos_NomeArea>
		  <td width="4%"><div align="center" class="style1">#dtFUP#</div></td>
		  <td width="4%">#auxsaida#</td>
		  <cfset auxsaida = DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = rsItem.Und_Descricao>
		  <td width="10%"><div align="center">#auxsaida#</div></td>
		  <cfset auxsaida = rsItem.Pos_Inspecao>
		  <td width="5%"><div align="center">#auxsaida#</div></td>
		  <td width="16%"><div align="center">#rsItem.Pos_NumGrupo# - #rsItem.Grp_Descricao#</div></td>
		  <td><div align="center">#rsItem.Pos_NumItem# -&nbsp;#rsItem.Itn_Descricao#</div></td>
		  <td><div align="center">#auxEnc#</div></td>
		  <cfset dias = rsItem.Quant>
		    <td width="4%"><div align="center">#dias#</div></td>
		 </tr>
    </cfoutput>
  <cfelse>
     <cfif qVerifEmReanalise.recordcount eq 0 >
		<tr bgcolor="f7f7f7" class="exibir">
		  <td colspan="16" align="center"><strong>Sr. Inspetor, todos os itens deste relatório foram solucionados, portanto a inspeção encontra-se encerrada.</strong></td>
		</tr>
		<tr><td colspan="16" align="center">&nbsp;</td></tr>
     </cfif>
 </cfif>
		<tr><td colspan="16" align="center">&nbsp;</td></tr>
		<tr><td colspan="16" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
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