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
    WHERE Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31) AND INP_NumInspecao = '#txtNum_Inspecao#'
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
    WHERE (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#' and Itn_TipoUnidade <> 99)
   </cfquery>
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

<!--- =========================== --->

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
	Pos_DtPosic, 
	Pos_Parecer, 
	Pos_NumGrupo, 
	Pos_NumItem, 
	Pos_dtultatu, 
	Grp_Descricao, 
	Dir_Codigo,
	Dir_Sigla,
	Pos_Situacao_Resp, 
	Dir_Descricao, 
	DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant, 
	DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, 
	Pos_NomeArea, 
	Pos_DtPrev_Solucao,
	Pos_ClassificacaoPonto, 
	STO_Codigo, 
	STO_Sigla, 
	STO_Cor, 
	STO_Descricao,
	Itn_Descricao, 
	Itn_ValorDeclarado
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
Where   
	<cfif ckTipo eq "inspecao">
	      <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
          (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (INP_NumInspecao = '#txtNum_Inspecao#')
		  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
		  (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (INP_NumInspecao = '#txtNum_Inspecao#')
		  <cfelse>
		  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (INP_NumInspecao = '#txtNum_Inspecao#')
          </cfif>
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria in (#UsuCoordena#))
			  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
			  (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria in (#UsuCoordena#))
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria in (#UsuCoordena#))
			  </cfif>
		<cfelse>
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria = '#url.SE#')
			  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
			  (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria = '#url.SE#')
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria = '#url.SE#')
			  </cfif>
		</cfif>		  
	<cfelse>
	      <cfif StatusSE eq "Todas">
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria  in (#UsuCoordena#))
			   <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
			   (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria  in (#UsuCoordena#))
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria  in (#UsuCoordena#))
			  </cfif>		  
		  <cfelse>
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
			  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
			  (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
			  </cfif>
		  </cfif>
	</cfif>
	ORDER BY Pos_DtPosic, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, Data
	</cfquery>

<!--- gerar planilha  Gilvan 09/05/2019 --->
<cfquery name="rsXLS" datasource="#dsn_inspecao#">
SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, RIP_Ano, RIP_Resposta, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, convert(char,Pos_PontuacaoPonto) as PosPontuacaoPonto, Pos_ClassificacaoPonto, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, trim(Pos_NomeArea) as PosNomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, DATEDIFF(dd, INP_DtFimInspecao, GETDATE()) AS Quant,
CASE WHEN Pos_OpcaoBaixa = 1 then 'Penalidade Aplicada' WHEN Pos_OpcaoBaixa = 2 then 'Defesa Acatada'  WHEN Pos_OpcaoBaixa = 3 then 'Outros' end as Pos_OpcaoBaixa, case when LTRIM(RTRIM(SEI_NumSEI)) IS NULL AND Pos_OpcaoBaixa IS NOT NULL then 'não informado' else LEFT(SEI_NumSEI,5)+'.'+SUBSTRING(SEI_NumSEI,6,6)+'/'+SUBSTRING(SEI_NumSEI,12,4) +'-'+RIGHT(SEI_NumSEI,2) end AS SEI_NumSEI 
FROM ((((Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
INNER JOIN ParecerUnidade ON (RIP_Unidade = Pos_Unidade) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumItem = Pos_NumItem)) 
INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
INNER JOIN (Grupos_Verificacao 
INNER JOIN Itens_Verificacao ON (Grp_Ano = Itn_Ano) AND (Grp_Codigo = Itn_NumGrupo) AND (Grp_Ano = Itn_Ano)) 
ON (Pos_NumGrupo = Grp_Codigo) AND (Pos_NumItem = Itn_NumItem) AND (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (convert(char(4),RIP_Ano) = Grp_Ano)
LEFT JOIN Inspecao_SEI ON  SEI_Inspecao= Pos_Inspecao AND SEI_Grupo= Pos_NumGrupo AND  SEI_Item = Pos_NumItem AND SEI_Unidade = Pos_Unidade

    Where  
	<cfif ckTipo eq "inspecao">
	      <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
          (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (INP_NumInspecao = '#txtNum_Inspecao#')
		  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
		   (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (INP_NumInspecao = '#txtNum_Inspecao#')
		  <cfelse>
		  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (INP_NumInspecao = '#txtNum_Inspecao#')
          </cfif>
	<cfelseif ckTipo eq "periodo">
		<cfif url.SE eq "Todas">
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria in (#UsuCoordena#))
		      <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>	
			  (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria in (#UsuCoordena#))		  
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria in (#UsuCoordena#))
			  </cfif>
		<cfelse>
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria = '#url.SE#')
			  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
			  (Pos_Situacao_Resp in (3,24,25,26,27,29)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria = '#url.SE#')
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29)) and (INP_DtFimInspecao BETWEEN #dtinic# AND #dtfim#) AND (Und_CodDiretoria = '#url.SE#')
			  </cfif>
		</cfif>		  
	<cfelse>
	      <cfif StatusSE eq "Todas">
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria  in (#UsuCoordena#))
			  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
			  (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria  in (#UsuCoordena#))
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria  in (#UsuCoordena#))
			  </cfif>		  
		  <cfelse>
			  <cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>
			  (Pos_Situacao_Resp in (3,9,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
			  <cfelseif Trim(qAcesso.Usu_GrupoAcesso) eq 'GOVERNANCA'>
			  (Pos_Situacao_Resp in (3,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
			  <cfelse>
			  (Pos_Situacao_Resp in (3,12,13,24,25,26,27,29,31)) and (Pos_Situacao_Resp = #selstatus#) and (Und_CodDiretoria = '#StatusSE#')
			  </cfif>
		  </cfif>
	</cfif>
	ORDER BY  Quant DESC, INP_DtInicInspecao, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop
</cfquery>
<!--- dados temporário --->
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
	ColumnList = "PosPontuacaoPonto,Pos_ClassificacaoPonto,INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,PosNomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,RIPRInsp,RIPRGp,RIPRIt,Quant,Pos_OpcaoBaixa,SEI_NumSEI",
	ColumnNames = "Pontuacao_Item,Classificacao_Item,Modalidade,Diretoria,Cod_Unidade,DescricaoUnidade,Num_Inspecao,Num_Grupo,Descricao_Grupo,Num_Item,Descricao_Item,Cod_REATE,ANO,Resposta,CaracteresVlr,Falta,Sobra,EmRisco,Data Ultima Atualiz,Nome_do_Usuario,Recomendacao,Hora_Pre_Inspecao,DT_Inic_Desloc,Hora_Desloc,DT_Fim_Desloc,DT_Inic_Inspecao,DT_Fim_Inspecao,Hora Inspecao,Situacao,DT_Encerram_Inspecao,Coordenador,Responsavel,Motivo,Status,Sigla_Status,Descricao_Status,Dt_Posicao,Dt_Previsao_Solucao,Area,Nome_Area,Parecer,Valor Recuperado,Processo,Tipo_Processo,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias,OpcaoDeBaixa,SEI_Baixa",
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
//inicio calssificar colunas
var index;      // cell index
	// var toggleBool;// sorting asc, desc
	window.onload=function(){
		//recupera a classificação das colunas
		if(sessionStorage.getItem('colClassif')===null){
			toggleBool=true;
			sorting(tbodyItens, 0);
						
		}else{	
			toggleBool=sessionStorage.getItem('colClassifAscDesc');

			sorting(tbodyItens, sessionStorage.getItem('colClassif'),toggleBool);
		}
		//FIM: recupera a classificação das colunas
	};

   //Para classificar tabelas
	
	function sorting(tbody, index){
	//alert(tbody + index);
		sessionStorage.setItem('colClassif', index, toggleBool);
		toggleBool = true;

		var pai = document.getElementById("trItens");
        // for(var i=0; i<pai.children.length; i++){retirado para não classificar a coluna item por solicitação do Adriano
		for(var i=0; i < 6; i++){
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
		for(var i = 0; i < 6; i++){
			if(document.getElementById('classifCrescente' + i)){
				var figuraCresceId = document.getElementById('classifCrescente' + i).style.visibility;
				var	figuraDecresceId = document.getElementById('classifDecrescente' + i).style.visibility;
			}

			if(pai.children[i].tagName == "TD" && (figuraCresceId=='visible' || figuraDecresceId=='visible')) {
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
	//alert(a + b);
		var aVal = a.cells[6].innerText;
		var bVal = b.cells[6].innerText;

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
		var aVal = a.cells[6].innerText;
		var bVal = b.cells[6].innerText;

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
<table width="100%" align="center" class="exibir">
<tr>
<td valign="top" align="center">
<!--- Área de conteúdo   --->
<table width="100%">
  <tr>
    <td height="20" colspan="12">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="12"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="11">&nbsp;</td>
    <td height="20"><div align="center"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
  </tr>


  <tr><td colspan="2"><!--- <div align="left" class="titulosClaro">Nº Relat: <cfoutput>#txtNum_Inspecao#</cfoutput></div> ---></td></tr>
  <cfif rsItem.recordCount neq 0>
	  <tr><td colspan="2"><div align="center" class="titulosClaro"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div></td></tr>

      <tr class="titulosClaro">
	    <td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
		<td width="2%" bgcolor="eeeeee" class="exibir"><div align="center">Modalidade</div></td>
		<td width="3%" bgcolor="eeeeee" class="exibir"><div align="center">Posi&ccedil;&atilde;o</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Previs&atilde;o</div></td>
		<td width="2%" bgcolor="eeeeee" class="exibir"><div align="center">SE Sigla</div></td>
		<td width="4%" bgcolor="eeeeee" class="exibir"><div align="center">&Oacute;rg&atilde;o Condutor</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">In&iacute;cio</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Fim</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Envio Ponto</div></td>
		<td width="10%" bgcolor="eeeeee" class="exibir"><div align="center">Nome Unidade</div></td>
		<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Relat&oacute;rio</div></td>
		<td width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
		<td width="16%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><strong>Encaminhamento</strong></td>		
	    <td width="4%" bgcolor="eeeeee" class="exibir"><div align="center">Qtd. Dias</div></td>
		<td width="8%" bgcolor="eeeeee" class="exibir"><div align="center">Classificação</div></td> 
	  </tr> 
	<!--- <tbody id="tbodyItens"> --->
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
	  	 <tr bgcolor="f7f7f7" class="exibir">			
			<td width="6%" bgcolor="#STO_Cor#"><div align="center"><a onClick="capturaPosicaoScroll()" href="itens_controle_pontosbaixados_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#rsItem.Und_CodReop#&SE=#url.SE#&selStatus=#selStatus#&StatusSE=#StatusSE#&txtNum_Inspecao=#txtNum_Inspecao#&vlrdec=#rsItem.Itn_ValorDeclarado#&situacao=#rsItem.Pos_Situacao_Resp#" class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a></div></td>
			<cfset auxsaida = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
		<td width="2%"><div align="center">#rsItem.Modal#</div></td>
		<td width="3%">#auxsaida#</td>
		<cfset auxsaida = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')>
		<td width="5%" class="red_titulo"><div align="center">#auxsaida#</div></td>
		<td width="2%"><div align="center">#rsItem.Dir_Sigla#</div></td>
		<cfset auxsaida = rsItem.Pos_NomeArea>
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
 		<cfset auxsaida = rsItem.Pos_ClassificacaoPonto>
		<td width="8%" class="exibir"><div align="center">#auxsaida#</div></td> 
		</tr>
		 </tr>  
	  </cfoutput>
	 <!---  </tbody> --->

  <cfelse>
		<tr bgcolor="f7f7f7" class="exibir">
		  <td colspan="12" align="center"><strong>Sr(a). Gestor(a), nenhuma ocorrencia foi encontrada para o filtro informados.</strong></td>
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

</body>
</html>
<!--- 
 <cfcatch>
  <cfdump var="#cfcatch#">
</cfcatch>
</cftry> --->
