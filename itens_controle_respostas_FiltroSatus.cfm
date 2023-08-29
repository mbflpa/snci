<cfprocessingdirective pageEncoding ="utf-8"/>

<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<cfif isDefined("Session.E01")>
  <cfset StructClear(Session.E01)>
</cfif>

<!--- <cfdump var="#url#"> --->

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
	<cfquery name="rsLimite" datasource="#dsn_inspecao#">
	SELECT INP_DtFimInspecao 
	FROM ParecerUnidade 
	INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao 
	INNER JOIN Unidades ON Pos_Unidade = Und_Codigo 
	INNER JOIN Itens_Verificacao ON (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) and Pos_NumGrupo = Itn_NumGrupo AND Pos_NumItem = Itn_NumItem AND right([Pos_Inspecao], 4) = Itn_Ano
	INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo AND right([Pos_Inspecao], 4) = Grp_Ano
	INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo 
	WHERE ((Pos_Situacao_Resp <> 51) and (Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 17) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (INP_NumInspecao = '#txtNum_Inspecao#'))
   </cfquery>	
 </cfif>
 <cfif isDefined("ckTipo") And ckTipo eq "status">
	<cfquery name="rsBusc" datasource="#dsn_inspecao#">
	 SELECT  Pos_Situacao_Resp FROM ParecerUnidade where Pos_Situacao_Resp = #selstatus#
	</cfquery>
	 <cfif rsBusc.recordcount is 0>
	  <cflocation url="Mens_Erro.cfm?msg=1">
	 </cfif>
	 	<cfquery name="rsLimite" datasource="#dsn_inspecao#">
	SELECT INP_DtFimInspecao 
	FROM ParecerUnidade 
	INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao 
	INNER JOIN Unidades ON Pos_Unidade = Und_Codigo 
	INNER JOIN Itens_Verificacao ON (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) and Pos_NumGrupo = Itn_NumGrupo AND Pos_NumItem = Itn_NumItem AND right([Pos_Inspecao], 4) = Itn_Ano
	INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo AND right([Pos_Inspecao], 4) = Grp_Ano
	INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo  
	WHERE ((Pos_Situacao_Resp <> 51) and (Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 17) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#'))
   </cfquery>
 </cfif>
 <cfif #ckTipo# eq "inspecao">
    <cfset dtinic = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
   <cfset dtfim = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
   <cfset url.selstatus = "">
   <cfset url.StatusSE= "">
 <cfelseif ckTipo eq "periodo">
   <cfset url.dtInicio = #dtinic#>
   <cfset url.dtFinal = #dtfim#>
   <cfset url.selstatus = "">
   <cfset url.StatusSE= "">
   <cfset txtNum_Inspecao = "">
   <cfset url.dtInicio = CreateDate(Right(dtinic,4), Mid(dtinic,4,2), Left(dtinic,2))>
   <cfset url.dtFinal = CreateDate(Right(dtfim,4), Mid(dtfim,4,2), Left(dtfim,2))> ]
 <cfelse>
   <cfset dtinic = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
   <cfset dtfim = DateFormat(rsLimite.INP_DtFimInspecao,"yyyy/mm/dd")>
</cfif>
	<cfquery name="rsItem" datasource="#dsn_inspecao#">
	SELECT INP_DtInicInspecao, Pos_Unidade, Und_Descricao, Pos_Inspecao, INP_DtFimInspecao, Und_CodReop, INP_DtEncerramento, Pos_DtPosic,
	Pos_Parecer, Pos_NumGrupo, Pos_NumItem, pos_dtultatu, Itn_Descricao, Grp_Descricao, Dir_Codigo,
	Pos_Situacao_Resp, Dir_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, Pos_NomeArea, Pos_DtPrev_Solucao
	FROM ParecerUnidade 
	INNER JOIN Inspecao ON Pos_Inspecao = INP_NumInspecao 
	INNER JOIN Unidades ON Pos_Unidade = Und_Codigo 
	INNER JOIN Itens_Verificacao ON (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) and Pos_NumGrupo = Itn_NumGrupo AND Pos_NumItem = Itn_NumItem AND right([Pos_Inspecao], 4) = Itn_Ano
	INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo AND right([Pos_Inspecao], 4) = Grp_Ano
	INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo 
	<cfif ckTipo eq "inspecao">
	WHERE ((Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND (Pos_Situacao_Resp <> 16) AND (Pos_Situacao_Resp <> 17) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (INP_NumInspecao = '#txtNum_Inspecao#'))
	<cfelseif ckTipo eq "inspecao" and isDefined("form.selFiltro") And form.selFiltro neq "">
	WHERE ((Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND (Pos_Situacao_Resp <> 16) AND (Pos_Situacao_Resp <> 17) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (INP_NumInspecao = '#txtNum_Inspecao#') and Pos_Situacao_Resp = #selFiltro#)
	<cfelseif ckTipo eq "periodo">
	WHERE ((Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND (Pos_Situacao_Resp <> 16) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#) AND (Und_CodDiretoria = '#url.SE#'))
	<cfelse>
	 WHERE ((Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND (Pos_Situacao_Resp <> 16) AND (Pos_Situacao_Resp <> 17) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#'))
	</cfif>
	ORDER BY  Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, data
	</cfquery>

<!--- gerar planilha  Gilvan 09/05/2019 --->
<cfquery name="rsXLS" datasource="#dsn_inspecao#">
SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, RIP_Ano, RIP_Resposta, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, Pos_NCISEI, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant 
FROM ParecerUnidade 
INNER JOIN Unidades ON Und_Codigo = Pos_Unidade 
INNER JOIN Resultado_Inspecao ON (Pos_NumItem = RIP_NumItem) AND (Pos_NumGrupo = RIP_NumGrupo) AND 
(Pos_Inspecao = RIP_NumInspecao) AND (Pos_Unidade = RIP_Unidade) 
INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade) 
INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo 
INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo AND 
right(Pos_Inspecao, 4) = Grp_Ano 
INNER JOIN Itens_Verificacao ON (Und_TipoUnidade = Itn_TipoUnidade) and (INP_Modalidade = Itn_Modalidade) 
and (Pos_NumItem = Itn_NumItem) AND right(RIP_NumInspecao, 4) = Itn_Ano AND (Grp_Codigo = Itn_NumGrupo)  AND (Grp_Ano = Itn_Ano)
<cfif #ckTipo# eq "inspecao">
	WHERE (INP_NumInspecao = '#txtNum_Inspecao#')
<cfelseif ckTipo eq "periodo">
	WHERE (INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#) AND (Und_CodDiretoria = '#url.SE#')
<cfelse>
    WHERE ((Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND (Pos_Situacao_Resp <> 16) AND (Pos_Situacao_Resp <> 17) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#'))
</cfif>
	ORDER BY Und_CodDiretoria, Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop
</cfquery>
<!--- =========================================== --->

<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' 
</cfquery>
</cfoutput>
<cfquery name="rsStatus" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Descricao
  FROM Situacao_Ponto where (STO_Status = 'A') and ((STO_Codigo = 1) or (STO_Codigo=2) or (STO_Codigo=4) or (STO_Codigo=5) or (STO_Codigo=6) or (STO_Codigo=7) or (STO_Codigo=8) or (STO_Codigo=9) or (STO_Codigo=14)) order by Sto_Sigla
</cfquery>
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
	ColumnList = "INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,RIPRInsp,RIPRGp,RIPRIt,Quant",
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
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
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

</head>
<body>
<form name="form1" method="get" action="itens_controle_respostas_FiltroSatus.cfm">
<table width="100%" height="50%">
<tr>
<td valign="top" align="center">
<!--- Área de conteúdo   --->
<table width="100%" class="exibir">
  <tr>
    <td height="20" colspan="12">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="12"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="12">      
        <select name="selFiltro" class="form" id="selFiltro">
          <option selected="selected" value="">---</option>
          <cfoutput query="rsStatus">
            <option value="#STO_Codigo#">#trim(STO_Sigla)# - #trim(STO_Descricao)#</option>
          </cfoutput>
        </select>
        <input name="Submit" type="submit" class="botao" value="Filtrar">
      </td>
  </tr>
 
  <tr>
    <td height="10" colspan="11"><div align="center"><strong class="titulo1">Controle das MANIFESTA&Ccedil;&Otilde;ES</strong></div></td>
      <td height="20" colspan="12"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></td>
   </tr>
   <tr>
    <td height="10" colspan="11"></td>
      <td height="20" colspan="12"></td>
   </tr>
  <tr><td colspan="2"><!--- <div align="left" class="titulosClaro">Nº Relat: <cfoutput>#txtNum_Inspecao#</cfoutput></div> ---></td></tr>
  <cfif rsItem.recordCount neq 0>
	  <tr><td colspan="2"><div align="center" class="titulosClaro"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div></td></tr>

	  <tr class="titulosClaro">
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Posição</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Previsão</div></td>
		<td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Órgão Condutor</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Início</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Fim</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Envio Ponto</div></td>
		<td width="12%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Relatório</div></td>
		<td width="17%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
		<td width="20%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Quant. de Dias</div></td>
	  </tr>
	<cfoutput query="rsItem">
		 <tr bgcolor="f7f7f7" class="exibir">
		 <cfif (((rsItem.Pos_Situacao_Resp eq 2) or (rsItem.Pos_Situacao_Resp eq 4) or (rsItem.Pos_Situacao_Resp eq 5)) and (rsItem.Pos_Parecer is ''))>
			<td height="20" bgcolor="666666"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Sem Manifestação</strong></a></div></td>
		 <cfelse>
			<cfif rsItem.Pos_Situacao_Resp eq 0>
			<td height="20" bgcolor="666666"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Em Revisão</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 1>
			<td height="20" bgcolor="FF3300"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Resposta Unidade</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 2>
			<td height="20" bgcolor="FFA500"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Pendente Unidade</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 4>
			<td height="20" bgcolor="0000FF"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Pendente Órgão Subordinador</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 5>
			<td height="20" bgcolor="009900"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Pendente &Aacute;rea</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 6>
			<td height="20" bgcolor="339999"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Resposta &Aacute;rea</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 7>
			<td height="20" bgcolor="0099FF"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Resposta Órgão Subordinador</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 8>
			<td height="20" bgcolor="FFCC99"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Corporativo SE</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 9>
			<td height="20" bgcolor="CD853F"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Corporativo CS</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 10>
			<td height="20" bgcolor="800080"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Ponto Suspenso</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 11>
			<td height="20" bgcolor="000000"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Em Liberação</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 14>
			<td height="20" bgcolor="236B8E"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Não Respondido</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 15>
			<td height="20" bgcolor="8080FF"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Em Tratamento na Unidade</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 17>
			<td height="20" bgcolor="##669900"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Resposta da AGF</strong></a></div></td>
			<cfelseif rsItem.Pos_Situacao_Resp eq 18>
			<td height="20" bgcolor="##CC33CC"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&selStatus=#selStatus#&StatusSE=#StatusSE#" class="exibir"><strong>Em Tratamento da AGF</strong></a></div></td>
			</cfif>
			
		  </cfif>
		  <td width="5%"><div align="center">#DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')#</div></td>
		  <td width="5%" class="red_titulo"><div align="center">#DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')#</div></td>
		  <td width="10%"><div align="center">#rsItem.Pos_NomeArea#</div></td>
		  <td width="5%"><div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')#</div></td>
		  <td width="5%"><div align="center">#DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')#</div></td>
		  <td width="5%"><div align="center">#DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')#</div></td>
		  <td width="12%"><div align="center">#rsItem.Und_Descricao#</div></td>
		  <td width="5%"><div align="center">#rsItem.Pos_Inspecao#</div></td>
		  <td width="17%"><div align="center">#rsItem.Pos_NumGrupo# - #rsItem.Grp_Descricao#</div></td>
		  <td width="20%"><div align="justify">#rsItem.Pos_NumItem# - &nbsp;#rsItem.Itn_Descricao#</div></td>
		  <td width="5%"><div align="center">#rsItem.Quant#</div></td>
		 </tr>
    </cfoutput>
  <cfelse>
		<tr bgcolor="f7f7f7" class="exibir">
		  <td colspan="12" align="center"><strong>Sr. Inspetor, todos os itens deste relatório foram solucionados, portanto a inspeção encontra-se encerrada.</strong></td>
		</tr>
		<tr><td colspan="12" align="center">&nbsp;</td></tr>
 </cfif>
		<tr><td colspan="12" align="center">&nbsp;</td></tr>
		<tr><td colspan="12" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
	</table>
<!--- Fim Área de conteúdo --->	  </td>
    </tr>
</table>
<cfinclude template="rodape.cfm">
<input name="ckTipo" type="hidden" id="ckTipo" value="#ckTipo#">
<input name="dtinic" type="hidden" id="dtinic">
<input name="dtfim" type="hidden" id="dtfim">
<input name="txtNum_Inspecao" type="hidden" id="txtNum_Inspecao" value="#txtNum_Inspecao#">
</form>
</body>
</html>

<!--- <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->