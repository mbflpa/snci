 <cfprocessingdirective pageEncoding ="utf-8"/>

 <cfset slocal = '\\sac1887\sistemas$\GMAT01\Pernambuco\SNCI\Fechamento\'> 
<!---<cfset slocal = '\\sac0424\sistemas\snci\'>--->

<!--- <cfoutput>ckTipo:#form.ckTipo# dtinic:#form.dtinic# dtfim: #form.dtfim# SE: #form.SE# NumInsp: #form.NumInsp#</cfoutput> --->
<cfif #form.ckTipo# neq "inspecao">
   <cfset url.dtInicio = #form.dtinic#>
   <cfset url.dtFinal = #form.dtfim#>
   <cfset url.dtInicio = CreateDate(Right(form.dtinic,4), Mid(form.dtinic,4,2), Left(form.dtinic,2))>
   <cfset url.dtFinal = CreateDate(Right(form.dtfim,4), Mid(form.dtfim,4,2), Left(form.dtfim,2))> 
</cfif>

<cfoutput>

<cfquery name="rsXLS" datasource="#dsn_inspecao#">
SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, RIP_Ano, RIP_Resposta, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, INP_HrsPreInspecao, INP_DtInicDeslocamento, INP_HrsDeslocamento, INP_DtFimDeslocamento, INP_DtInicInspecao, INP_DtFimInspecao, INP_HrsInspecao, INP_Situacao, INP_DtEncerramento, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, IPT_MatricInspetor, IPT_NumHrsPreInsp, IPT_NumHrsDesloc, IPT_NumHrsInsp, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_Area, Pos_NomeArea, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, Pos_NCISEI, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant 
FROM Itens_Verificacao 
INNER JOIN (Grupos_Verificacao 
INNER JOIN (Situacao_Ponto 
INNER JOIN ((((Unidades 
INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) 
INNER JOIN Resultado_Inspecao ON (Pos_NumItem = RIP_NumItem) AND (Pos_NumGrupo = RIP_NumGrupo) AND (Pos_Inspecao = RIP_NumInspecao) AND (Pos_Unidade = RIP_Unidade)) 
INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)) 
INNER JOIN Inspetor_Inspecao ON (INP_NumInspecao = IPT_NumInspecao) AND (INP_Unidade = IPT_CodUnidade)) 
ON STO_Codigo = Pos_Situacao_Resp) ON (Grp_Codigo = Pos_NumGrupo) AND (Grp_Codigo = Pos_NumGrupo) and right([Pos_Inspecao], 4) = Grp_Ano) ON (Itn_NumItem = Pos_NumItem) AND (Itn_NumGrupo = Pos_NumGrupo) and Grp_Ano = Itn_Ano and (Und_TipoUnidade = Itn_TipoUnidade) and (INP_Modalidade = Itn_Modalidade)
<cfif #form.ckTipo# eq "inspecao">
	WHERE ((Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (INP_NumInspecao = '#form.NumInsp#'))
<cfelse>
	WHERE ((Pos_Situacao_Resp <> 3) AND (Pos_Situacao_Resp <> 12) AND (Pos_Situacao_Resp <> 13) AND ((Pos_Situacao_Resp <> 1) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 7) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND ((Pos_Situacao_Resp <> 6) OR (DATEDIFF(dd,Pos_DtPosic,GETDATE()) > 2)) AND (INP_DtFimInspecao BETWEEN #url.dtInicio# AND #url.dtFinal#) AND (Und_CodDiretoria = '#form.SE#'))
</cfif>
	ORDER BY Und_CodDiretoria, Quant DESC, INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop
</cfquery>
</cfoutput>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' 
</cfquery>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>

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
	ColumnList = "INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POSUserName,RIP_EmRisco,RIPRInsp,RIPRGp,RIPRIt",
	ColumnNames = "Modalidade,Diretoria,Código Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,SEI,NCISEI,ReInc_Relat,ReInc_Grupo,ReInc_Item",
	SheetName = "Itens_Controle"
    ) />	

<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>



















