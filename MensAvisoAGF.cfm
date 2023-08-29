<cfprocessingdirective pageEncoding ="utf-8"/>

<!--- gerar planilha  Gilvan 09/05/2019 --->
<cfquery name="rsXLSA" datasource="#dsn_inspecao#">
SELECT Und_CodDiretoria, Dir_Descricao, Und_Codigo, Und_Descricao, INP_NumInspecao, RIP_NumGrupo, Grp_Descricao, RIP_NumItem, Itn_Descricao, RIP_CodReop, RIP_Ano, RIP_Resposta, substring(RIP_Comentario,1,32500) as comentario, RIP_Valor, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, POS_UserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, INP_Coordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant FROM Itens_Verificacao INNER JOIN (Grupos_Verificacao INNER JOIN (Resultado_Inspecao INNER JOIN (Inspecao INNER JOIN (Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo) ON INP_Unidade = Und_Codigo) ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)) ON Grp_Codigo = RIP_NumGrupo) ON (Itn_NumItem = RIP_NumItem) AND (Itn_NumGrupo = Grp_Codigo) WHERE (((INP_NumInspecao) Like '%2018') AND ((RIP_NumGrupo)=10 Or (RIP_NumGrupo)=31) AND ((RIP_NumItem)=2 Or (RIP_NumItem)=3)) ORDER BY Und_CodDiretoria, Und_Descricao, RIP_NumGrupo, RIP_NumItem
</cfquery>


<cfoutput>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
</cfoutput>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>

<cfset sarquivo = 'Luciana_Sem_Status.xls'>

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
    Query = rsXLSA,
	ColumnList = "Und_CodDiretoria,Dir_Descricao,Und_Codigo,Und_Descricao,INP_NumInspecao,RIP_NumGrupo,Grp_Descricao,RIP_NumItem,Itn_Descricao,RIP_CodReop,RIP_Ano,RIP_Resposta,RIP_Valor,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POS_UserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INP_Coordenador,INP_Responsavel,motivo,Quant",
	ColumnNames = "Diretoria,Dir_Descricao,Código Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,Valor,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,HoraPréInspeção,DT_Inic Desloc,HoraDesloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,HoraInspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Qtd_Dias",
	SheetName = "SemStatus"
    ) />

<cfquery name="rsXLSB" datasource="#dsn_inspecao#">
SELECT Und_CodDiretoria, Dir_Descricao, Und_Codigo, Und_Descricao, INP_NumInspecao, RIP_NumGrupo, Grp_Descricao, RIP_NumItem, Itn_Descricao, RIP_CodReop, RIP_Ano, RIP_Resposta, substring(RIP_Comentario,1,32500) as comentario, RIP_Valor, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, POS_UserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, INP_Coordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, Pos_Situacao, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecerA, substring(Pos_Parecer,32501,32500) as parecerB, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Pos_SEI, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant FROM Situacao_Ponto INNER JOIN ((Itens_Verificacao INNER JOIN (Grupos_Verificacao INNER JOIN (Resultado_Inspecao INNER JOIN (Inspecao INNER JOIN (Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo) ON INP_Unidade = Und_Codigo) ON (RIP_Unidade = INP_Unidade) AND (RIP_NumInspecao = INP_NumInspecao)) ON Grp_Codigo = RIP_NumGrupo) ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_NumItem = RIP_NumItem)) INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) ON STO_Codigo = Pos_Situacao_Resp
WHERE (((INP_NumInspecao) Like '%2018') AND ((RIP_NumGrupo)=10 Or (RIP_NumGrupo)=31) AND ((RIP_NumItem)=2 Or (RIP_NumItem)=3))
ORDER BY Und_CodDiretoria, Und_Descricao, RIP_NumGrupo, RIP_NumItem
</cfquery>
<cfset sarquivo = 'Luciana_com_Status.xls'>
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
    Query = rsXLSB,
	ColumnList = "Und_CodDiretoria,Dir_Descricao,Und_Codigo,Und_Descricao,INP_NumInspecao,RIP_NumGrupo,Grp_Descricao,RIP_NumItem,Itn_Descricao,RIP_CodReop,RIP_Ano,RIP_Resposta,RIP_Valor,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POS_UserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INP_Coordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,Pos_Situacao,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecerA,parecerB,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,Quant",
	ColumnNames = "Diretoria,Dir_Descricao,Código Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,Valor,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,HoraPréInspeção,DT_Inic Desloc,HoraDesloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,HoraInspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,DataPrevisaoSolução,Área,Nome da Área,ParecerA,ParecerB,Valor Recuperado,Processo,Tipo_Processo,SEI,Qtd_Dias",
	SheetName = "ComStatus"
    ) />

<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>



