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

<!--- <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  --->       

<cfsetting requesttimeout="15000">
<CFSET gestorMaster = 'GESTORMASTER'>
<cfquery name="qUsuarioGestorMaster" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_GrupoAcesso FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#' and Usu_GrupoAcesso = 'GESTORMASTER'
</cfquery>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_DR, Usu_Matricula, Usu_Coordena FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfset UsuCoordena = trim(qUsuario.Usu_Coordena)>
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
	ON (Itn_Ano = Grp_Ano) AND (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano)) 
	ON Dir_Codigo = Und_CodDiretoria) 
	ON STO_Codigo = Pos_Situacao_Resp
	WHERE 
	<cfif qUsuarioGestorMaster.recordcount neq 0 >
		(Pos_Situacao_Resp not in (3,10,12,13,24,25,26,27,31,51)) 
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,10,12,13,24,25,26,27,31,51))
    </cfif>	
	 AND (INP_NumInspecao = '#txtNum_Inspecao#')
	<!--- AND 1 = CASE WHEN Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END  --->	
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
 <cfif isDefined("ckTipo") And ckTipo eq "inspecao">
 	   <cfif rsLimite.recordcount gt 0>
 		 <cfset dtinic = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))>
	     <cfset dtfim = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))>
	   <cfelse>
		<!---  <cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	     <cfset dtfim = dtinic>  --->
	   </cfif> 
   <cfset url.selstatus = " ">
   <cfset url.StatusSE= " ">
   <cfset url.SE= " ">
 <cfelseif isDefined("ckTipo") And ckTipo eq "periodo">
<!---     <cfset url.dtinic =  CreateDate(year(dtinic),month(dtinic),day(dtinic))>
   <cfset url.dtfim = CreateDate(year(dtfim),month(dtfim),day(dtfim))>   ---> 
   <cfset url.selstatus = " ">
   <cfset url.StatusSE= " ">
   <cfset txtNum_Inspecao = "">
 <cfelse>
   <cfset url.SE= " ">
   <cfset txtNum_Inspecao = "">
	   <cfif rsLimite.recordcount gt 0>
		 <cfset dtinic = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))>
	     <cfset dtfim = CreateDate(year(rsLimite.INP_DtFimInspecao),month(rsLimite.INP_DtFimInspecao),day(rsLimite.INP_DtFimInspecao))> 
<!--- 	   <cfelse>
		 <cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	     <cfset dtfim = dtinic>  --->
	   </cfif>
</cfif> 
        <!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
	<cfquery name="rsItem" datasource="#dsn_inspecao#">
  	SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as Modal,  
	INP_DtInicInspecao, 
	Pos_Unidade, 
	Und_Descricao, 
	Und_TipoUnidade, 
	Pos_Inspecao, 
	INP_DtFimInspecao, 
	Und_CodReop, 
	INP_DtEncerramento, 
	INP_Modalidade,
	Pos_DtPosic, 
	Pos_Parecer, 
	Pos_ClassificacaoPonto,
	Pos_NumGrupo, 
	Pos_NumItem, 
	Pos_NCISEI, 
	Pos_dtultatu, 
	Itn_Descricao, 
	Itn_ValorDeclarado, 
	Grp_Descricao, 
	Dir_Codigo,
	Dir_Sigla,
	Pos_Situacao_Resp, 
	Dir_Descricao, 
	DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, 
	DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, 
	Pos_Area, 
	Pos_NomeArea, 
	Pos_DtPrev_Solucao, 
	Pos_ClassificacaoPonto,
	Pos_PontuacaoPonto,
	STO_Codigo, 
	STO_Sigla, 
	STO_Cor, 
	STO_Descricao
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
	WHERE 
	<cfif qUsuarioGestorMaster.recordcount neq 0>
		(Pos_Situacao_Resp not in (3,12,13,24,25,26,27,29,31,51) 
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,12,13,24,25,26,27,29,31,51)
    </cfif>	
	
	<!---  AND 1 = CASE WHEN Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END    --->
	
	<cfif ckTipo eq "inspecao">
	   and INP_NumInspecao = '#txtNum_Inspecao#')
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
		  and Und_CodDiretoria in (#UsuCoordena#) and INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#)
		<cfelse>
		  and INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim# AND left(Pos_Area,2) = '#url.SE#')
		</cfif>
	<cfelse>
		<cfif StatusSE eq "Todas">
		  and Pos_Situacao_Resp = #selstatus# and Und_CodDiretoria in (#UsuCoordena#))
		<cfelse>
		  and Pos_Situacao_Resp = #selstatus# and left(Pos_Area,2) = '#StatusSE#')
		</cfif>
	</cfif>
	     ORDER BY Und_CodDiretoria, Pos_DtPosic, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, Data  
	</cfquery> 	
	
<!--- gerar planilha  Gilvan 09/05/2019 --->
    <!--- query alterada mara inibir pontos sobre ADICIONAIS DE COLET/DISTRIBUIÇÃO, ATENDIMENTO E TRATAMENTO--->
<!--- 	AND 1 = CASE WHEN Itn_TipoUnidade = 99 And Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END --->
	<cfquery name="rsXLS" datasource="#dsn_inspecao#">
	SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, 
	RIP_ReincInspecao as RIPRInsp, 
	convert(char, RIP_ReincGrupo) as RIPRGp, 
	convert(char, RIP_ReincItem) as RIPRIt, 
	Und_CodDiretoria, 
	Pos_Unidade, 
	Und_Descricao, 
	Und_TipoUnidade, 
	Pos_Inspecao, 
	Pos_NumGrupo, 
	Pos_NumItem, 
	Und_CodReop, 
	RIP_Ano, 
	RIP_Resposta, 
	RIP_Caractvlr, 
	convert(money, RIP_Falta) as RIPFalta, 
	convert(money, RIP_Sobra) as RIPSobra, 
	convert(money, RIP_EmRisco) as RIPEmRisco, 
	convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, 
	case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, 
	RIP_Recomendacao, 
	INP_HrsPreInspecao, 
	convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, 
	INP_HrsDeslocamento, 
	convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, 
	convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, 
	convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, 
	INP_HrsInspecao, 
	INP_Situacao, 
	convert(char,INP_DtEncerramento,103) as INPDtEncer, 
	concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, 
	INP_Responsavel, 
	substring(INP_Motivo,1,32500) as motivo, 
	convert(char,Pos_PontuacaoPonto) as PosPontuacaoPonto, 
	Pos_ClassificacaoPonto,
	Pos_Situacao_Resp, 
	STO_Sigla, 
	STO_Descricao, 
	convert(char,Pos_DtPosic,103) as PosDtPosic, 
	convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, 
	Pos_Area, 
	trim(Pos_NomeArea) as PosNomeArea,
	convert(char, Pos_dtultatu, 120) as ultimaAtu, 
	substring(Pos_Parecer,1,32500) as parecerA, 
	substring(Pos_Parecer,32500,65001) as parecerB, 
	substring(Pos_Parecer,65002,97502) as parecerC, 
	Pos_VLRecuperado, 
	Pos_Processo, 
	Pos_Tipo_Processo, 
	Grp_Descricao, 
	Itn_Descricao, 
	Pos_SEI, 
	Pos_NCISEI, 
	DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, 
	DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, 
	RIP_Comentario
	FROM (Situacao_Ponto 
	INNER JOIN (Diretoria 
	INNER JOIN (Grupos_Verificacao 
	INNER JOIN (Itens_Verificacao 
	INNER JOIN ((Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
	INNER JOIN ParecerUnidade ON (INP_Unidade = Pos_Unidade) AND (INP_NumInspecao = Pos_Inspecao)) 
	ON (Itn_NumItem = Pos_NumItem) AND (Itn_NumGrupo = Pos_NumGrupo)) 
	ON (Itn_Ano = Grp_Ano) and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade) AND (Grp_Codigo = Itn_NumGrupo) and (right([Pos_Inspecao], 4) = Grp_Ano)) 
	ON Dir_Codigo = Und_CodDiretoria) 
	ON STO_Codigo = Pos_Situacao_Resp) INNER JOIN Resultado_Inspecao 
	ON (Pos_NumItem = RIP_NumItem) AND (Pos_NumGrupo = RIP_NumGrupo) 
	AND (Pos_Inspecao = RIP_NumInspecao) AND (Pos_Unidade = RIP_Unidade)
	WHERE 
    <cfif qUsuarioGestorMaster.recordcount neq 0>
		(Pos_Situacao_Resp not in (3,12,13,24,25,26,27,29,31,51) 
	<cfelse>
		(Pos_Situacao_Resp not in (3,9,12,13,24,25,26,27,29,31,51) 
    </cfif>	
	
	 <!--- AND 1 = CASE WHEN Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END    --->
	
	<cfif ckTipo eq "inspecao">
	   and INP_NumInspecao = '#txtNum_Inspecao#' and left(Pos_Inspecao,2) = left(Pos_Area,2))
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
		  and Und_CodDiretoria in (#UsuCoordena#) and INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#)
		<cfelse>
		  and INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim# AND left(Pos_Area,2) = '#url.SE#')
		</cfif>
	<cfelse>
		<cfif StatusSE eq "Todas">
		  and Und_CodDiretoria in (#UsuCoordena#) and Pos_Situacao_Resp = #selstatus#)
		<cfelse>
		  and Pos_Situacao_Resp = #selstatus# and left(Pos_Area,2) = '#StatusSE#')
		</cfif>
	</cfif>
	    ORDER BY Und_CodDiretoria, Pos_DtPosic, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, Data 
<!--- 	     ORDER BY Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop --->
	</cfquery> 
<!--- 
	AND 1 = CASE WHEN Itn_TipoUnidade = 99 And Pos_Situacao_Resp IN (1,6,7,22) THEN 0 ELSE 1 END --->
<!--- dados temporário --->
 <cfif isDefined("ckTipo") And ckTipo eq "inspecao">
	<!--- <cfset dtinic = dateformat(dtinic,"dd/mm/yyyy")>
	<cfset dtfim = dateformat(dtfim,"dd/mm/yyyy")> --->
 <cfelseif isDefined("ckTipo") And ckTipo eq "periodo">
  <!---  <cfset url.dtInicio =  dateformat(dtinic,"dd/mm/yyyy")>
   <cfset url.dtFinal = dateformat(dtfim,"dd/mm/yyyy")>  --->  
 <!---    <cfset dtinic =  CreateDate(year(dtinic),month(dtinic),day(dtinic))>
   <cfset dtfim = CreateDate(year(dtfim),month(dtfim),day(dtfim))>  --->
 <cfelse>
	   <cfif rsLimite.recordcount gt 0>
<!--- 		 <cfset dtinic = dateformat(rsLimite.INP_DtFimInspecao,"dd/mm/yyyy")>
	     <cfset dtfim = dtinic>
	   <cfelse>
		 <cfset dtinic = CreateDate(year(now()),month(now()),day(now()))>
	     <cfset dtfim = dtinic> --->
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

<!--- <cfset data = now() - 1>
	 <cfset objPOI.WriteSingleExcel(
    FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
    Query = rsXLS,
	ColumnList = "PosPontuacaoPonto,Pos_ClassificacaoPonto,INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFiminsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,PosNomeArea,parecerA,parecerB,parecerC,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,Pos_NCISEI,RIPRInsp,RIPRGp,RIPRIt,Quant,ultimaAtu",
	ColumnNames = "Pontuacao_Item,Classificacao_Item,Modalidade,Diretoria,Cod_Unidade,DescricaoUnidade,Num_Inspecao,Num_Grupo,Descricao_Grupo,Num_Item,Descricao_Item,Cod_REATE,ANO,Resposta,CaracteresVlr,Falta,Sobra,EmRisco,Data Ultima Atualiz,Nome_do_Usuario,Recomendacao,Hora_Pre_Inspecao,DT_Inic_Desloc,Hora_Desloc,DT_Fim_Desloc,DT_Inic_Inspecao,DT_Fim_Inspecao,Hora Inspecao,Situacao,DT_Encerram_Inspecao,Coordenador,Responsavel,Motivo,Status,Sigla_Status,Descricao_Status,Dt_Posicao,Dt_Previsao_Solucao,Area,Nome_Area,ParecerA,ParecerB,ParecerC,Valor Recuperado,Processo,Tipo_Processo,SEI,NCISEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias,Ult_Atualiz",
	SheetName = "Controle_Manifestacoes"
    ) /> --->

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
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="css.css" rel="stylesheet" type="text/css">
 <cfquery name="rsSPnt" datasource="#dsn_inspecao#">
  SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
 </cfquery>
<cfoutput query="rsSPnt">
 <div id="#rsSPnt.STO_Sigla#" style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
 <font size="1" face="Verdana" color="000000">#rsSPnt.STO_Conceito#</font></div>
</cfoutput>
<script language="JavaScript">
   var index;      // cell index
	// var toggleBool;// sorting asc, desc
	window.onload=function(){
		//recupera a classificação das colunas
		if(sessionStorage.getItem('colClassif')===null){
			toggleBool=true;
			sorting(tbodyItens, 0);
						
		}else{	
			toggleBool=sessionStorage.getItem('colClassifAscDesc');
			// if(toggleBool=='true'){retirado para sempre classificar crescente
			// 	toggleBool = false;
			// }else{
			// 	toggleBool = true;
			// }
			sorting(tbodyItens, sessionStorage.getItem('colClassif'),toggleBool);
		}
		//FIM: recupera a classificação das colunas

		<cfif isdefined("url.Unid")>
			<cfoutput>
				<cfif rsVerificaFinalizacao.recordcount eq 0 and rsInspecaoConcluida.recordcount eq 0 and '#rsMatricCoord.INP_Coordenador#' eq '#qAcesso.Usu_Matricula#'>
					<cfif grpacesso eq "INSPETORES">
						window.setTimeout('liberar()', 100);
					</cfif>
				</cfif>
			</cfoutput>
		</cfif>
	};
	

   //Para classificar tabelas
	
	function sorting(tbody, index){
		sessionStorage.setItem('colClassif', index, toggleBool);
		toggleBool = true;

		var pai = document.getElementById("trItens");
        // for(var i=0; i<pai.children.length; i++){retirado para não classificar a coluna item por solicitação do Adriano
		for(var i=0; i<7; i++){
			var figuraCresceId = 'classifCrescente' + i;
		    var	figuraDecresceId = 'classifDecrescente' + i;
			document.getElementById(figuraCresceId).style.display='none';
			document.getElementById(figuraCresceId).style.visibility='hidden';
			document.getElementById(figuraDecresceId).style.display='none';
			document.getElementById(figuraDecresceId).style.visibility='hidden';
		}


		var frm = document.getElementById('frmopc');
		this.index = index;
		var figuraCresceId = 'classifCrescente' + index;
		var	figuraDecresceId = 'classifDecrescente' + index;
		if(toggleBool){
			toggleBool = false;
			document.getElementById(figuraCresceId).style.display='block';
			document.getElementById(figuraCresceId).style.visibility='visible';
			document.getElementById(figuraDecresceId).style.display='none';
			document.getElementById(figuraDecresceId).style.visibility='hidden';
		}else{
			toggleBool = true;
			document.getElementById(figuraCresceId).style.display='none';
			document.getElementById(figuraCresceId).style.visibility='hidden';
			document.getElementById(figuraDecresceId).style.display='block';
			document.getElementById(figuraDecresceId).style.visibility='visible';
		}

		// sessionStorage.setItem('colClassifAscDesc', toggleBool);retirado para sempre classificar crescente

		var datas= new Array();
		var tbodyLength = tbody.rows.length;
		for(var i=0; i<tbodyLength; i++){
			datas[i] = tbody.rows[i];
		}

		datas.sort(compareCellsGrupo);//obriga a classificação por grupo após escolha da coluna de classificação
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}

		datas.sort(compareCellsItem);//obriga a classificação por grupo e item após escolha da coluna de classificação
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}
		
		datas.sort(compareCells);
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}   
		
		// for(var i = 0; i < pai.children.length; i++){
		for(var i = 0; i < 8; i++){
			if(document.getElementById('classifCrescente' + i)){
				var figuraCresceId = document.getElementById('classifCrescente' + i).style.visibility;
				var	figuraDecresceId = document.getElementById('classifDecrescente' + i).style.visibility;
			}

			if(pai.children[i].tagName == "TH" && (figuraCresceId=='visible' || figuraDecresceId=='visible')) {
				pai.children[i].style.background='lavender';
			}else{
				pai.children[i].style.background='#eeeeee';
			}

		}
	}

	function compareCells(a,b) {
		var aVal = a.cells[index].innerText;
		var bVal = b.cells[index].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	function compareCellsGrupo(a,b) {
		var aVal = a.cells[7].innerText;
		var bVal = b.cells[7].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	function compareCellsItem(a,b) {
		var aVal = a.cells[7].innerText;
		var bVal = b.cells[7].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	



	//FIM: Para classificar tabelas

    //captura a posição do scroll (usado nos botões que chamam outras páginas)
    //e salva no sessionStorage
    function capturaPosicaoScroll(){
        sessionStorage.setItem('scrollpos', document.body.scrollTop);
		
    }
	//após o onload recupera a posição do scroll armazenada no sessionStorage e reposiciona-o conforme última localização
        var scrollpos = 0;
		if(sessionStorage.getItem('scrollpos')){
			scrollpos = sessionStorage.getItem('scrollpos');
		}
		setTimeout(function () {
           window.scrollTo(0, scrollpos);
		   sessionStorage.setItem('scrollpos', '0');
		
        },200);
	
	
	//ao fechar, atualiza a página que abriu esta.
    window.onbeforeunload = function() {
     //   window.opener.location.reload();
    }

	var bd = document.getElementsByTagName('body')[0];
	var time = new Date().getTime();


	bd.onmousemove = goLoad;

	function goLoad() {
	if(new Date().getTime() - time >= 500000) {
		time = new Date().getTime();
		aguarde2();
		setTimeout("window.location = document.URL;",1000);
		// window.location.reload(true);
		}else{
			time = new Date().getTime();
		}
	}

	top.window.moveTo(0,0);
	if (document.all)
	{ top.window.resizeTo(screen.availWidth,screen.availHeight); }
	else if
	(document.layers || document.getElementById)
	{
	if
	(top.window.outerHeight < screen.availHeight || top.window.outerWidth <
	screen.availWidth)
	{ top.window.outerHeight = top.screen.availHeight;
	top.window.outerWidth = top.screen.availWidth; }
	}


	function piscando(){
		img = document.getElementById("imgAguarde");
		fundo = document.getElementById("aguarde");                
		if(img.style.visibility == "hidden" & fundo.style.visibility == "visible"){                              
		img.style.visibility = "visible";                         
		}else{                   
		img.style.visibility = "hidden";                       
		}
		
	setTimeout('piscando()', 500);

	}

	function aguarde2(){
	
		if(document.getElementById("aguarde").style.visibility == "visible"){
		document.getElementById("aguarde").style.visibility = "hidden" ;
		}else{
		document.getElementById("aguarde").style.visibility = "visible";
		piscando();
		}
	}
	function aguarde(){
		document.getElementById("aguarde").style.visibility = "visible";
	}

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


	function abrirInspecao(url) {
	aguarde();
	sessionStorage.clear();
	// return false;
	var newwindow = window.open(url,'_self');

	}


	<cfset listaInspSemAval="">
	<cfset quantListaInspSemAval = 0>
	<cfset inspComAval ="">
	<!---<cfset coordLocalizListaSemAval ="">--->

//**************************************************************************

//-------------------------------------------------------------------------
	//Início do bloco de funções que controlam as linhas de uma tabela
	//remove a informação da linha clicada em uma tabela
	// sessionStorage.removeItem('idLinha'); 
	setTimeout(function () {
		if(sessionStorage.getItem('idLinha')){
			if(document.getElementById(sessionStorage.getItem('idLinha'))){
				var linha =document.getElementById(sessionStorage.getItem('idLinha'));
				linha.style.backgroundColor='#053c7e';
				linha.style.color='#fff';
			}
			
		}
	},200);
	//muda cor da linha ao passar o mouse (se a linha não tiver sido selecionada)
	function mouseOver(linha){ 
		if(linha.id !=sessionStorage.getItem('idLinha')){
			linha.style.backgroundColor='#6699CC';
			linha.style.color='#fff';
		}   
	}
	
	//restaura cor da linha ao retirar o mouse (se a linha não tiver sido selecionada)
	function mouseOut(linha){
		if(linha.id !=sessionStorage.getItem('idLinha')){
			linha.style.backgroundColor = ''; 
			linha.style.color='#053c7e';
		}else{
			linha.style.backgroundColor='#053c7e';
			linha.style.color='#fff';
		}
		
	}
	//Ao clicar grava a linha clicada, muda a cor da linha clicada e restaura a cor da linha clicada anteriormente
	function gravaOrdLinha(linha){ 
		if(sessionStorage.getItem('idLinha')){
			var linhaAnterior = sessionStorage.getItem('idLinha');
			if(document.getElementById(linhaAnterior)){
				linhaselecionadaAnterior = document.getElementById(sessionStorage.getItem('idLinha'));
				linhaselecionadaAnterior.style.backgroundColor = ''; 
				linhaselecionadaAnterior.style.color='#053c7e'; 
			}
		}
		var linhaClicada = linha.id;       
		sessionStorage.setItem('idLinha', linhaClicada);						
		linha.style.backgroundColor='#053c7e';
		linha.style.color='#fff';
	}
	//Fim do bloco de funções que controlam as linhas de uma tabela

          // JavaScript program to illustrate
            // Table sort for both columns and both directions.
            function sortTable(n) {
                var table;
                table = document.getElementById("table");
                var rows, i, x, y, count = 0;
                var switching = true;
  
                // Order is set as ascending
                var direction = "ascending";
  
                // Run loop until no switching is needed
                while (switching) {
                    switching = false;
                    var rows = table.rows;
  
                    //Loop to go through all rows
                    for (i = 1; i < (rows.length - 1); i++) {
                        var Switch = false;
  
                        // Fetch 2 elements that need to be compared
                        x = rows[i].getElementsByTagName("TD")[n];
                        y = rows[i + 1].getElementsByTagName("TD")[n];
  
                        // Check the direction of order
                        if (direction == "ascending") {
  
                            // Check if 2 rows need to be switched
                            if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase())
                                {
                                // If yes, mark Switch as needed and break loop
                                Switch = true;
                                break;
                            }
                        } else if (direction == "descending") {
  
                            // Check direction
                            if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase())
                                {
                                // If yes, mark Switch as needed and break loop
                                Switch = true;
                                break;
                            }
                        }
                    }
                    if (Switch) {
                        // Function to switch rows and mark switch as completed
                        rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                        switching = true;
  
                        // Increase count for each switch
                        count++;
                    } else {
                        // Run while loop again for descending order
                        if (count == 0 && direction == "ascending") {
                            direction = "descending";
                            switching = true;
                        }
                    }
                }
            }
</script>

<style>
#form_container
{
	background:#fff;
	margin:0 auto;
	text-align:left;
	width:720px;
}
h1
{
	background-color:#6699CC;
	margin:0;
	min-height:0;
	padding:5px;
	text-decoration:none;
	Color:#fff;
	
}

h1 a
{
	
	display:block;
	height:100%;
	min-height:40px;
	overflow:hidden;
}

.validar{
	cursor:pointer;
	font-size:20px!important;
	background:red;
	color:#fff;
	padding:8px;
	border-style: solid;
    border-width: 5px;
	border-color:#fff;
	
}

.validar:hover{
background:#6699CC;	
}


			
</style>



</head>
<body onLoad="mouseOver(0)">
	<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:200%;top:105px;left:10px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:10000;visibility:hidden;position:absolute;" >		
		<img id="imgAguarde" name="imgAguarde"src="figuras/aguarde.png" width="100px"  border="0" style="position:relative;top:20%"></img>
	</div>




<form id="frmopc" action="Gilvanteste.cfm" method="get"  enctype="multipart/form-data"  name="frmopc" >

	<table width="100%" height="50%">

	<tr>

	<!--- <input name="StatusSE" type="hidden" id="StatusSE" value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>">
	<input name="url.numInspecao" type="hidden" id="url.numInspecao" value="<cfoutput>#url.numInspecao#</cfoutput>">
	<input name="SE" type="hidden" id="SE" value="<cfoutput>#qAcesso.Usu_DR#</cfoutput>">   

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
	</cfif> --->


<td valign="top" align="center">

<cfif '#rsItem.recordCount#' neq  0>	

	<table id="tabelaItens" width="87%" class="exibir"  >
		<div align="center" class="titulosClaro"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div>
		<cfif rsItem.recordCount neq 0>
<!---  --->	
<tr id="trItens" class="titulosClaro" title="Clique para classificar.">
	    <th width="8%" bgcolor="eeeeee" class="exibir" onclick="sortTable(0)" style="cursor:pointer"><div align="center">Status</div><img id="classifCrescente0" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente0" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Modalidade</div></th>
		<td width="3%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 1)" style="cursor:pointer"><div align="center">Posi&ccedil;&atilde;o</div><img id="classifCrescente1" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente1" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></td>
		<td width="5%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 2)" style="cursor:pointer"><div align="center">Previs&atilde;o</div><img id="classifCrescente2" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente2" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></td>
		<td width="2%" bgcolor="eeeeee" class="exibir"><div align="center">SE Sigla</div></td>
		<td bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 3)" style="cursor:pointer"><div align="center">&Oacute;rg&atilde;o Condutor</div><img id="classifCrescente3" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente3" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></td>
		<td width="5%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 4)" style="cursor:pointer"><div align="center">In&iacute;cio</div><img id="classifCrescente4" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente4" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></td>
		<td width="5%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 5)" style="cursor:pointer"><div align="center">Fim</div><img id="classifCrescente5" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente5" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></td>
		<td width="5%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 6)" style="cursor:pointer"><div align="center">Envio Ponto</div><img id="classifCrescente6" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente6" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></td>
		<td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
		<td width="10%" bgcolor="eeeeee" class="exibir">Relat&oacute;rio</div></td>
		<td width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
		<td width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><strong>Encaminhamento</strong></td>		
	    <td width="4%" bgcolor="eeeeee" class="exibir"><div align="center">Qtd. Dias</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Classificação</div></td>
	  </tr>
<!---  --->	
		
 		<!--- <thead >
			<tr id="trItens" class="titulosClaro" title="Clique para classificar.">
				<!--- <th width="20%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 0)" style="cursor:pointer">Ordem Priorização Execução
			  <div><img id="classifCrescente0" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente0" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></div></th> --->
				<!--- <th width="8%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 1)" style="cursor:pointer">Status
			  <div><img id="classifCrescente1" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente1" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></div></th> --->
			<!--- 	<th width="35%" bgcolor="eeeeee" class="exibir" onClick="sorting(tbodyItens, 2)" style="cursor:pointer">Grupo<img id="classifCrescente2" src="Figuras/classifCrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"><img id="classifDecrescente2" src="Figuras/classifDecrescente.png" width="20" style="display:none;visibility:hidden;cursor:pointer;margin-left:0px;position:relative;margin-top:0px"></th> --->
				<th width="37%" bgcolor="eeeeee" class="exibir" >Item</th>
			</tr>
 		</thead> --->
 		<tbody id="tbodyItens">
			<cfoutput query="rsItem">
<!--- 
					<tr id="#rsItem.CurrentRow#" bgcolor="f7f7f7" class="exibir"
					onMouseOver="mouseOver(this);" 
					onMouseOut="mouseOut(this);"
					onclick="gravaOrdLinha(this);capturaPosicaoScroll();window.open('itens_inspetores_avaliacao1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&txtnum_Inspecao=#url.txtNum_Inspecao#&pontuacaorip=#rsItem.Pos_PontuacaoPonto#&tpunid=#rsItem.Und_TipoUnidade#&modal=#rsItem.INP_Modalidade#&frminspreincidente=''&retornosn=""frmsituantes=0&frmdescantes=""','_self')"
					style="cursor:pointer;position:relative;">	
				<td width="20%"><div align="center">''</td>
				<td width="8%" bgcolor="#STO_Cor#"><div align="center" ><a onClick="capturaPosicaoScroll()" href="itens_inspetores_avaliacao1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&reop=#rsItem.Und_CodReop#&SE=#rsItem.Dir_Codigo#&Num_Inspecao=#url.txtNum_Inspecao#&pontuacaorip=#rsItem.Pos_PontuacaoPonto#&tpunid=#rsItem.Und_TipoUnidade#&modal=#rsItem.INP_Modalidade#&frminspreincidente=''&retornosn=''&frmsituantes=0&frmdescantes=''"  class="exibir"></a></div></td>
				<td width="35%"><div align="center">#rsItem.Pos_NumGrupo# - #rsItem.Grp_Descricao#</div></td>
				<td  width="37%"><div align="left" style="padding:10px"><cfif #rsItem.Pos_NumItem# le 9>0#rsItem.Pos_NumItem#<cfelse>#rsItem.Pos_NumItem#</cfif>-&nbsp;#rsItem.Itn_Descricao#</div></td> --->
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
	  	
		 <tr bgcolor="f7f7f7" class="exibir">         

		<cfif rsItem.Pos_Situacao_Resp is 0 or rsItem.Pos_Situacao_Resp is 11>
			<cfquery name="qReanalisado" datasource="#dsn_inspecao#">
				SELECT RIP_Recomendacao FROM Resultado_Inspecao
				WHERE RIP_NumInspecao = '#rsItem.Pos_Inspecao#' and RIP_NumGrupo='#rsItem.Pos_NumGrupo#' and RIP_NumItem ='#rsItem.Pos_NumItem#'
			</cfquery>
			  <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_controle_revisliber.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#url.SE#&selStatus=#selStatus#&StatusSE=#StatusSE#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#&posarea=#rsItem.Pos_Area#&modal=#rsItem.INP_Modalidade#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong><cfif '#trim(rsItem.Pos_NCISEI)#' neq '' and '#rsItem.Pos_Situacao_Resp#' eq 0><span style="color:white"><br>com NCI</span></cfif><cfif '#qReanalisado.RIP_Recomendacao#' eq 'R' and '#rsItem.Pos_Situacao_Resp#' eq 0><div ><span style="color:white;background:darkblue;padding:2px;"><br>REANALISADO</span></div></cfif></a></div></td>
		<cfelse>
			  <td width="8%" bgcolor="#STO_Cor#"><div align="center"><a href="itens_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#url.SE#&selStatus=#selStatus#&StatusSE=#StatusSE#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#&posarea=#rsItem.Pos_Area#&modal=#rsItem.INP_Modalidade#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a><cfif '#trim(rsItem.Pos_NCISEI)#' neq '' and '#rsItem.Pos_Situacao_Resp#' eq 0><span style="color:white"><br>com NCI</span></cfif></a></div></td>
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
	</cfif>
	

	  </table>


	</cfif>
	

	</div>
	<!--- Fim Área de conteúdo --->	 
	</td>
	</tr>

</table>



<cfinclude template="rodape.cfm">

</body>
</html>
<!---
 <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->
