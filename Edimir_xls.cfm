<cfquery name="rsDir" datasource="#dsn_inspecao#">
SELECT Dir_Codigo, Dir_Sigla FROM Diretoria ORDER BY Dir_Codigo
</cfquery>
<cfloop query="rsDir">
<!--- gerar planilha  Gilvan 09/05/2019 --->
<cfquery name="rsXLS" datasource="#dsn_inspecao#">
SELECT Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, RIP_Ano, RIP_Resposta, substring(RIP_Comentario,1,32500) as comentario, RIP_Valor, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, convert(char,RIP_DtUltAtu,103) as RIPDtUltAtu, RIP_UserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, INP_Coordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant FROM (((((Unidades INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) INNER JOIN Resultado_Inspecao ON (Pos_NumItem = RIP_NumItem) AND (Pos_NumGrupo = RIP_NumGrupo) AND (Pos_Inspecao = RIP_NumInspecao) AND (Pos_Unidade = RIP_Unidade)) INNER JOIN Inspecao ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade)) INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) INNER JOIN Grupos_Verificacao ON Pos_NumGrupo = Grp_Codigo) INNER JOIN Itens_Verificacao ON (Pos_NumItem = Itn_NumItem) AND (Grp_Codigo = Itn_NumGrupo) AND (Grp_Codigo = Itn_NumGrupo) AND (Grp_Codigo = Itn_NumGrupo) AND (Grp_Codigo = Itn_NumGrupo) WHERE RIP_Ano = 2019 and Und_CodDiretoria = '#rsDir.Dir_Codigo#' ORDER BY Und_CodDiretoria, Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop
</cfquery>

<!--- Excluir arquivos anteriores ao dia atual --->
<cfset sdata = dateformat(now(),"YYYYMMDDHH")>
<cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
<cfset slocal = #diretorio# & 'Fechamento\'>

<cfset sarquivo = 'Edimir_' & #rsDir.Dir_Codigo# & '_' & #rsDir.Dir_Sigla# & '.xls'>

<cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
  	<cfoutput query="qList">
		   <cfif len(name) eq 23>
				<cfif (left(name,8) lt left(sdata,8)) or (int(mid(sdata,9,2) - mid(name,9,2)) gte 2)>
				  <cffile action="delete" file="#slocal##name#">
				</cfif>
		  </cfif>
	</cfoutput>

<cfset objPOI = CreateObject(
    "component",
    "Excel"
    ).Init()
    />

<cfset data = now() - 1>
   	 <cfset objPOI.WriteSingleExcel(
    FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
    Query = rsXLS,
	ColumnList = "Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,comentario,RIP_Valor,RIP_Caractvlr,RIP_Falta,RIP_Sobra,RIP_EmRisco,RIPDtUltAtu,RIP_UserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INP_Coordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Quant",
	ColumnNames = "Diretoria,Código Unidade,Descrição da Unidade,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,Comentário,Valor,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,Hora Pré Inspeção,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,Data Previsão Solução,Área,Nome da Área,Parecer,Valor Recuperado,Processo,Tipo_Processo,Qtd_Dias",
	SheetName = "Controle_Manifestacoes"
    ) />
</cfloop>
