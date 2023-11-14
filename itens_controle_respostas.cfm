<cfif (not isDefined("snci.permitir")) OR (snci.permitir eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	<cfabort> 
</cfif> 
<!--- Limpara variáveis globais --->
<cfset snci.gesavaliacao=''>
<cfset snci.gesunidade=''>
<cfset snci.gesgrupo=''>
<cfset snci.gesitem=''>

<cfprocessingdirective pageEncoding ="utf-8"/> 

<cfset snci.filtrotipo=#ckTipo#>
<cfset snci.filtronumaval=''>
<cfset snci.filtrodtinic = year(now()) & '-' & month(now()) & '-' & day(now())>
<cfset snci.filtrodtfim = year(now()) & '-' & month(now()) & '-' & day(now())>
<cfset snci.filtrocodse=''>
<cfset snci.filtrostatus=''>

<cfif snci.filtrotipo eq 'periodo'>
	<cfset snci.filtrodtinic = #lsdateformat(dtinic,"YYYY-MM-DD")#>
	<cfset snci.filtrodtfim = #lsdateformat(dtfim,"YYYY-MM-DD")#>
	<cfset snci.filtrocodse=#SE#>
</cfif>
<cfif snci.filtrotipo eq 'inspecao'>
	<cfset snci.filtronumaval=#numavaliacao#>
</cfif>
<cfif snci.filtrotipo eq 'status'>
	<cfset snci.filtrostatus=#selStatus#>
	<cfset snci.filtrocodse=#statusse#>
</cfif>
<!---
<cfoutput>
  Tipo: #snci.filtrotipo#<br>
  snci.filtronumaval: #snci.filtronumaval# <br>
  snci.filtrodtinic: #snci.filtrodtinic# <br>
  snci.filtrodtfim: #snci.filtrodtfim# <br>
  snci.filtrocodse: #snci.filtrocodse#<br>
  snci.filtrostatus: #snci.filtrostatus#<br>
</cfoutput>
--->     
  
<cfsetting requesttimeout="15000">
<CFSET gestorMaster = 'GESTORMASTER'>
<cfquery name="qUsuarioGestorMaster" datasource="#snci.dsn#">
  SELECT DISTINCT Usu_GrupoAcesso FROM Usuarios WHERE Usu_Login = '#snci.login#' and Usu_GrupoAcesso = 'GESTORMASTER'
</cfquery>

<!--- limpar .XLS --->
<cfset sdtatual = dateformat(now(),"YYYYMMDDHH")>
<cfset sdtarquivo = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>  

<cfdirectory name="qList" filter="*.*" sort="name asc" directory="#slocal#">
<cfoutput query="qList">
   <cfset sdtarquivo = dateformat(dateLastModified,"YYYYMMDDHH")> 
	   <cfif left(sdtatual,8) eq left(sdtarquivo,8)>
			<cfif (right(sdtatual,2) - right(sdtarquivo,2)) gte 4>
			     <cffile action="delete" file="#slocal##name#">    
			</cfif>
	  <cfelseif left(sdtatual,8) neq left(sdtarquivo,8)>
		  <cffile action="delete" file="#slocal##name#"> 
	  </cfif>
<!--- 	 data atual: #sdtatual# -     Data do arquivo: #sdtarquivo#   nome do arquivo: #name#<br> --->
</cfoutput>

 <!--- <cftry> --->

<!---  <cfdump var="#Form#">
<cfdump var="#URL#"> --->

<!--- 
<cfif IsDefined("url.ninsp")>
	<cfset numavaliacao = url.ninsp>
</cfif>
--->
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfset total=0>

 <cfif isDefined("snci.filtrotipo") And snci.filtrotipo eq "inspecao">
	<cfquery name="rsBusc" datasource="#snci.dsn#">
	 	SELECT  Pos_Situacao_Resp FROM ParecerUnidade where Pos_Inspecao = '#snci.filtronumaval#'
	</cfquery>
	<cfif rsBusc.recordcount is 0>
		<cflocation url="Mens_Erro.cfm?msg=1">
	</cfif>
	 
	<!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->	 
	<cfquery name="rsLimite" datasource="#snci.dsn#">
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
	ON (Itn_Ano = Grp_Ano) AND (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano)) 
	ON Dir_Codigo = Und_CodDiretoria) 
	ON STO_Codigo = Pos_Situacao_Resp
	WHERE 
	<cfif qUsuarioGestorMaster.recordcount neq 0 >
		(Pos_Situacao_Resp not in (3,10,12,13,24,25,26,27,31,51)) 
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,10,12,13,24,25,26,27,31,51))
    </cfif>	
	 AND (INP_NumInspecao = '#snci.filtronumaval#')
	<!--- AND 1 = CASE WHEN Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END  --->	
   </cfquery>
 </cfif> 
 <cfif isDefined("snci.filtrotipo") And snci.filtrotipo eq "status">
	<cfquery name="rsBusc" datasource="#snci.dsn#">
		SELECT  Pos_Situacao_Resp FROM ParecerUnidade where Pos_Situacao_Resp = #snci.filtrostatus#
	</cfquery>
	<cfif rsBusc.recordcount is 0>
		<cflocation url="Mens_Erro.cfm?msg=1">
	</cfif>
	<!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
	<cfquery name="rsLimite" datasource="#snci.dsn#">
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
	ON (Itn_Ano = Grp_Ano) AND (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano)) 
	ON Dir_Codigo = Und_CodDiretoria) 
	ON STO_Codigo = Pos_Situacao_Resp
	WHERE
	<cfif qUsuarioGestorMaster.recordcount neq 0 >
		(Pos_Situacao_Resp not in (3,12,13,24,25,26,27,31,51)) 
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,12,13,24,25,26,27,31,51)) 
    </cfif>	
   </cfquery>
 </cfif>  
  
    <!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
	<cfquery name="rsItem" datasource="#snci.dsn#">
  	SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as Modal,  
    DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant,
	INP_Modalidade,
    INP_HrsPreInspecao, 
	INP_DtInicDeslocamento,
	INP_HrsDeslocamento, 
	INP_DtFimDeslocamento,
	INP_DtInicInspecao,
	INP_DtFimInspecao,
	INP_HrsInspecao, 
	INP_Situacao, 
	INP_DtEncerramento,
	INP_Coordenador,
	INP_Responsavel, 
	INP_Motivo,  
    Pos_Unidade, 
    Pos_Inspecao,
    Pos_NumGrupo, 
	Pos_NumItem, 
	Pos_DtPosic,
	DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data,
	Pos_DtPrev_Solucao, 
	Pos_Situacao_Resp,
	Pos_Situacao,
    Pos_Area, 
	Pos_NomeArea, 
    Pos_DtUltAtu,
	substring(Pos_Parecer,1,32500) as parecerA, 
	substring(Pos_Parecer,32500,65001) as parecerB, 
	substring(Pos_Parecer,65002,97502) as parecerC,
	Pos_PontuacaoPonto,
	Pos_ClassificacaoPonto,
    Pos_NCISEI, 
    Pos_SEI,
	POS_UserName,
	Pos_VLRecuperado, 
	Pos_Processo, 
	Pos_Tipo_Processo,    
    Grp_Descricao,
    Und_CodReop,
	Und_Descricao, 
	Und_TipoUnidade, 
    Und_CodDiretoria,
	Itn_Descricao, 
	Itn_ValorDeclarado, 
	Dir_Codigo,
	Dir_Sigla,
	Dir_Descricao, 
	STO_Codigo, 
	STO_Sigla, 
	STO_Cor, 
	STO_Descricao,
    RIP_Ano, 
	RIP_Resposta, 
	RIP_Caractvlr,
    RIP_Falta, 
    RIP_Sobra, 
    RIP_EmRisco, 
    RIP_Recomendacao,
	RIP_ReincInspecao, 
	RIP_ReincGrupo, 
	RIP_ReincItem, 
    RIP_Comentario,
	REP_Nome
	FROM Situacao_Ponto 
	INNER JOIN ((Unidades 
	INNER JOIN ((((Inspecao 
	INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
	INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
	INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo and convert(char,RIP_Ano)=Grp_Ano) 
	INNER JOIN Itens_Verificacao ON (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade) AND (Grp_Ano = Itn_Ano) AND (Grp_Codigo = Itn_NumGrupo)) ON (Und_Codigo = Pos_Unidade) AND (Und_TipoUnidade = Itn_TipoUnidade)) 
	INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo) ON STO_Codigo = Pos_Situacao_Resp
	INNER JOIN Reops ON Und_CodReop = Rep_Codigo
	WHERE 
	<cfif qUsuarioGestorMaster.recordcount neq 0>
		(Pos_Situacao_Resp not in (3,12,13,24,25,26,27,29,31,51) 
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,12,13,24,25,26,27,29,31,51)
    </cfif>	
	
	<!---  AND 1 = CASE WHEN Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END    --->
	
	<cfif snci.filtrotipo eq "inspecao">
	   and INP_NumInspecao = '#snci.filtronumaval#')
	<cfelseif snci.filtrotipo eq "periodo">
		<cfif snci.filtrocodse eq "Todas">
		  and Und_CodDiretoria in (#snci.coordenacodse#) and INP_DtFimInspecao BETWEEN '#snci.filtrodtinic#' AND '#snci.filtrodtfim#')
		<cfelse>
		  and INP_DtFimInspecao BETWEEN '#snci.filtrodtinic#' AND '#snci.filtrodtfim#' AND left(Pos_Area,2) = '#snci.filtrocodse#')
		</cfif>
	<cfelse>
		<cfif statusse eq "Todas">
		  and Pos_Situacao_Resp = #snci.filtrostatus# and Und_CodDiretoria in (#snci.coordenacodse#))
		<cfelse>
		  and Pos_Situacao_Resp = #snci.filtrostatus# and left(Pos_Area,2) = '#snci.filtrocodse#')
		</cfif>
	</cfif>
	     ORDER BY Und_CodDiretoria, Pos_DtPosic, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, Data  
	</cfquery> 	

 <cfquery dbtype="query" name="rsxls">
  Select Modal as Tipo_Avaliação,
		RIP_Ano as Ano,
		Dir_Codigo as Cod_SE,
		Dir_Sigla as Sigla_SE,
		Pos_Unidade as Cod_Unidade,
		Und_Descricao as Nome_Unidade,
		Und_CodReop as Cod_REATE,
		REP_Nome as Nome_REATE,
		Pos_Inspecao as Cod_Avalição,
		Pos_NumGrupo as Cod_Grupo,
		Grp_Descricao as Descrição_Grupo,
		Pos_NumItem, 
		Itn_Descricao as Descrição_Item,
		Pos_DtPosic as Data_Posição, 
		Pos_DtPrev_Solucao as Data_Previsão_Solução, 
		Pos_Situacao_Resp as Status_Ponto,
		Pos_Situacao as Sigla_Status,
		STO_Descricao as Descrição_Status,
		Pos_Area as Responsável_Ponto,
		Pos_NomeArea as Nome_Responsável_Ponto, 
		parecerA as Parecer, 
		parecerB as Parecer_ComplementoA,
		parecerC as Parecer_ComplementoB,
		Pos_PontuacaoPonto as Pontuação_Ponto,
		Pos_ClassificacaoPonto as Classificação_Ponto,
		Pos_NCISEI as Num_NCISEI, 
		Pos_SEI as Num_SEI,
		POS_UserName as Último_Fazer_Gestão,
		Pos_VLRecuperado as Valor_Recuperado, 
		Pos_Processo as Processo, 
		Pos_Tipo_Processo as Tipo_Processo,
		RIP_Resposta, 
		RIP_Caractvlr,
		RIP_Falta as Valor_Falta, 
		RIP_Sobra as Vlaor_Sobra, 
		RIP_EmRisco as Valor_EmRisco, 
		RIP_Recomendacao as Recomendação,
		RIP_ReincInspecao as Cod_Avaliação_Reincidente, 
		RIP_ReincGrupo as Cod_Grupo_Reincidente, 
		RIP_ReincItem as Cod_Item_Reincidente, 
		RIP_Comentario as Comentário,
		INP_DtInicInspecao as Data_Inic_Avaliação,	
		INP_DtFimInspecao as Data_Fim_Avaliação, 
		INP_DtEncerramento as Data_Encerramento_Avaliação, 
		INP_HrsPreInspecao as Hora_Pre_Avaliação, 
		INP_DtInicDeslocamento as Data_Inic_Deslocamento,
		INP_DtFimDeslocamento as Data_Fim_Deslocamento,
		INP_HrsDeslocamento as Horas_Deslocamento, 
		INP_HrsInspecao as Horas_Avaliação, 
		INP_Situacao as Situação, 
		INP_DtEncerramento as Data_Encerramento,
		INP_Coordenador as Coordenador_Avaliação,
		INP_Responsavel as Gestor_Unidade_Avaliada, 
		INP_Motivo as Motivo, 
		Pos_DtUltAtu as Última_Atualização,
		Quant as Qtd_Dias
from rsItem
</cfquery>
<cfoutput>
<!--- Excluir arquivos anteriores ao dia atual --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>

<cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #snci.matricula# & '.xls'>
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
<cfoutput>

<cfspreadsheet 
action = "write" 
filename="./Fechamento/#sarquivo#" 
query="rsxls" 
overwrite="true">
</cfoutput>


<!DOCTYPE HTML>
<cfinclude template="cabecalho.cfm">
<html lang="pt-br">
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="css.css" rel="stylesheet" type="text/css">
 <cfquery name="rsSPnt" datasource="#snci.dsn#">
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

 <cfif isDefined("snci.filtrotipo") And snci.filtrotipo eq "inspecao">
		<!---Verifica se esta inspecao possui algum item em reanalise --->
		<cfquery datasource="#snci.dsn#" name="qVerifEmReanalise">
			SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
			WHERE RIP_Recomendacao='S' and RIP_NumInspecao='#snci.filtronumaval#'
		</cfquery>
		<cfif qVerifEmReanalise.recordcount neq 0 > 
		<div align="center">
			<div align="center" style="position:RELATIVE; top:3px;background:red;color:#fff;width:640px;padding:3px;font-family:Verdana, Arial, Helvetica, sans-serif">				
			  <div style="float: left;">
			    <img id="imgAtencao" name="imgAtencao"src="figuras/atencao.png" width="40px" border="0" ></img>
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
<thead >
  <tr>
    <th height="20" colspan="17">&nbsp;</th>
  </tr>
<!---   <tr>
    <th height="20" colspan="17"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></th>
  </tr> --->
  <tr>
    <th height="20" colspan="17">&nbsp;</th>
  </tr>

  <tr>
    <th height="10" colspan="15"><div align="center"><strong class="titulo1">CONTROLE DAS MANIFESTAÇÕES</strong></div></th>
      <th height="10" colspan="2"><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></th>
  </tr>

  <tr><!---<th colspan="2"> <div align="left" class="titulosClaro">Nº Relat: <cfoutput>#snci.filtronumaval#</cfoutput></div> ---></th></tr>
  <cfif rsItem.recordCount neq 0>
	  <tr class="titulosClaro">
	    <th colspan="17" bgcolor="eeeeee" class="exibir"><cfoutput>Qt. Itens: #rsItem.recordCount#</cfoutput></th>
      </tr>
	  <tr class="titulosClaro">
	    <th width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></th>
		<th width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Modalidade</div></th>
		<th width="3%" bgcolor="eeeeee" class="exibir"><div align="center">Posição</div></th>
		<th width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Previsão</div></th>
		<!--- <th width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Acompanhamento (dias úteis)</div></th> --->
		<th width="2%" bgcolor="eeeeee" class="exibir"><div align="center">SE Sigla</div></th>
		<th bgcolor="eeeeee" class="exibir"><div align="center">Órgão Condutor</div></th>
		<th width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Início</div></th>
		<th width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Fim</div></th>
		<th width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Envio Ponto</div></th>
		<th width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></th>
		<th width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Relatório</div></th>
		<th width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></th>
		<th width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></th>
		<th width="8%" bgcolor="eeeeee" class="exibir"><strong>Encaminhamento</strong></th>		
	    <th width="4%" bgcolor="eeeeee" class="exibir"><div align="center">Qtd.Dias</div></th>
		<th width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Classificação</div></th>
	  </tr>
	</thead >
	<tbody>
	  <cfoutput query="rsItem">
		  <cfset auxEnc = "MANUAL">
		  <cfset btnSN = 'N'>
		  <cfif Pos_Situacao_Resp eq 4 or Pos_Situacao_Resp eq 16>
				<cfquery name="rsAnd" datasource="#snci.dsn#">
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
	  	
		 <tr bgcolor="f7f7f7" class="exibir">         
		<cfif rsItem.Pos_Situacao_Resp is 0 or rsItem.Pos_Situacao_Resp is 11>
			<cfquery name="qReanalisado" datasource="#snci.dsn#">
				SELECT RIP_Recomendacao FROM Resultado_Inspecao
				WHERE RIP_NumInspecao = '#rsItem.Pos_Inspecao#' and RIP_NumGrupo='#rsItem.Pos_NumGrupo#' and RIP_NumItem ='#rsItem.Pos_NumItem#'
			</cfquery>
			  <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_controle_revisliber.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#snci.filtrodtinic#&dtFim=#snci.filtrodtfim#&snci.filtrotipo=#snci.filtrotipo#&reop=#rsItem.Und_CodReop#&SE=#snci.filtrocodse#&selStatus=#snci.filtrostatus#&statusse=#snci.filtrocodse#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#&posarea=#rsItem.Pos_Area#&modal=#rsItem.INP_Modalidade#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong><cfif '#trim(rsItem.Pos_NCISEI)#' neq '' and '#rsItem.Pos_Situacao_Resp#' eq 0><span style="color:white"><br>com NCI</span></cfif><cfif '#qReanalisado.RIP_Recomendacao#' eq 'R' and '#rsItem.Pos_Situacao_Resp#' eq 0><div ><span style="color:white;background:darkblue;padding:2px;"><br>REANALISADO</span></div></cfif></a></div></td>
		<cfelse>
			  <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#snci.filtrodtinic#&dtFim=#snci.filtrodtfim#&snci.filtrotipo=#snci.filtrotipo#&reop=#rsItem.Und_CodReop#&SE=#snci.filtrocodse#&selStatus=#snci.filtrostatus#&statusse=#snci.filtrocodse#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#&posarea=#rsItem.Pos_Area#&modal=#rsItem.INP_Modalidade#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a><cfif '#trim(rsItem.Pos_NCISEI)#' neq '' and '#rsItem.Pos_Situacao_Resp#' eq 0><span style="color:white"><br>com NCI</span></cfif></a></div></td>
		</cfif>		  
		<cfset auxsaida = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
		<td width="3%"><div align="center">#rsItem.Modal#</div></td>
		<td width="5%">#auxsaida#</td>
		<cfset auxsaida = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')>
		<td width="5%" class="red_titulo"><div align="center">#auxsaida#</div></td>
	<!--- 	<td width="2%"><div align="center" class="style1">#dtFUP#</div></td> --->
		<td width="2%"><div align="center">#rsItem.Dir_Sigla#</div></td>
		<cfset auxsaida = rsItem.Pos_NomeArea>
		<td width="5%">#auxsaida#</td>
		<cfset auxsaida = DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')>
		<td width="5%"><div align="center">#auxsaida#</div></td>
		<cfset auxsaida = DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')>
		<td width="5%"><div align="center">#auxsaida#</div></td>
		<cfset auxsaida = DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')>
		<td width="10%"><div align="center">#auxsaida#</div></td>
		<cfset auxsaida = rsItem.Und_Descricao>
		<td width="10%"><div align="center">#auxsaida#</div></td>
		<cfset auxsaida = rsItem.Pos_Inspecao>
		<td width="16%"><div align="center">#auxsaida#</div></td>
		<td width="16%"><div align="center">#rsItem.Pos_NumGrupo# - #rsItem.Grp_Descricao#</div></td>
		<td><div align="center">#rsItem.Pos_NumItem# -&nbsp;#rsItem.Itn_Descricao#</div></td>
		<td><div align="center">#auxEnc#</div></td>
		<cfset dias = rsItem.Quant>
		<td width="8%"><div align="center">#dias#</div></td>
		<cfset auxsaida = rsItem.Pos_ClassificacaoPonto>		
		<td width="8%" class="exibir"><div align="center">#auxsaida#</div></td> 
		</tr>
		</cfoutput>
	</tbody>			
  <cfelse>
		 <cfif isDefined("snci.filtrotipo") And snci.filtrotipo eq "inspecao">
			 <cfif qVerifEmReanalise.recordcount eq 0 >
				<tr bgcolor="f7f7f7" class="exibir">
				  <td colspan="17" align="center"><strong>Sr. Inspetor, todos os itens deste relatório foram solucionados, portanto a Avaliação encontra-se encerrada.</strong></td>
				</tr>
				<tr><td colspan="17" align="center">&nbsp;</td></tr>
			 </cfif>
		 </cfif>
  </cfif>
		<tr><td colspan="17" align="center">&nbsp;</td></tr>
		<tr><td colspan="17" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
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
