<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 	   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>   
</cfif>         
<!--- <cfoutput>#diretorio_anexos#</cfoutput> --->
 
<cfset area = 'sins'>
<cfset Encaminhamento = 'Ao SGCIN'>
<cfset nID_Resp = 1>
<cfset sSigla_Resp = "RU">
<cfset sDesc_Resp = "RESPOSTA DA UNIDADE">
<!--- selects basicos da pagina como um todo --->

 <cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_Apelido, Usu_LotacaoNome, Usu_GrupoAcesso, Usu_Lotacao, Und_Descricao, Und_TipoUnidade
  FROM Usuarios INNER JOIN Unidades ON Usu_Lotacao = Und_Codigo
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
</cfquery>
<cfset grpacesso = ucase(Trim(qUsuario.Usu_GrupoAcesso))>
<cfif (grpacesso eq "UNIDADES") and (qUsuario.Und_TipoUnidade neq 4)>
	<cfquery name="rsItem" datasource="#dsn_inspecao#">
	  SELECT RIP_NumInspecao, 
	  RIP_Unidade, 
	  Und_Descricao, 
	  Und_TipoUnidade, 
	  RIP_NumGrupo, 
	  RIP_NumItem, 
	  RIP_Comentario, 
	  RIP_Recomendacoes, 
	  INP_DtInicInspecao, 
	  INP_Responsavel, 
	  Rep_Codigo, 
	  RIP_Valor, 
	  RIP_Caractvlr, 
	  RIP_Falta, 
	  RIP_Sobra, 
	  RIP_EmRisco, 
	  RIP_ReincInspecao, 
	  RIP_ReincGrupo, 
	  RIP_ReincItem, 
	  Itn_TipoUnidade, 
	  Itn_Descricao, 
	  Itn_ImpactarTipos,
	  Itn_PTC_Seq,
	  INP_DtEncerramento,
	  INP_TNCClassificacao, 
	  Grp_Descricao,
      TNC_ClassifInicio, 
	  TNC_ClassifAtual
	  FROM Reops 
	  INNER JOIN Resultado_Inspecao 
	  INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
	  INNER JOIN Unidades ON INP_Unidade = Und_Codigo ON Rep_Codigo = Und_CodReop 
	  INNER JOIN Grupos_Verificacao 
	  INNER JOIN Itens_Verificacao ON Grp_Ano = Itn_Ano and Grp_Codigo = Itn_NumGrupo ON RIP_NumGrupo = Itn_NumGrupo 
	  AND RIP_NumItem = Itn_NumItem and convert(char,RIP_Ano) = Grp_Ano and (Itn_TipoUnidade = Und_TipoUnidade) 
	  AND (INP_Modalidade = Itn_Modalidade)
	  left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
	  WHERE RIP_NumInspecao='#ninsp#' AND (RIP_Unidade='#qUsuario.Usu_Lotacao#' or '#posarea#'='#qUsuario.Usu_Lotacao#') AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
	</cfquery>
<cfelse>
	 <cfquery name="rsItem" datasource="#dsn_inspecao#">
	  SELECT RIP_NumInspecao, 
	  RIP_Unidade, 
	  Und_Descricao, 
	  Und_TipoUnidade, 
	  RIP_NumGrupo, 
	  RIP_NumItem, 
	  RIP_Comentario, 
	  RIP_Recomendacoes, 
	  INP_DtInicInspecao, 
	  INP_Responsavel, 
	  Rep_Codigo, 
	  RIP_Valor, 
	  RIP_Caractvlr, 
	  RIP_Falta, 
	  RIP_Sobra, 
	  RIP_EmRisco, 
	  RIP_ReincInspecao, 
	  RIP_ReincGrupo, 
	  RIP_ReincItem,
	  Itn_TipoUnidade, 
	  Itn_Descricao, 
	  Itn_ImpactarTipos,
	  Itn_PTC_Seq,
	  INP_DtEncerramento,
	  INP_TNCClassificacao, 
	  Grp_Descricao
      TNC_ClassifInicio, 
	  TNC_ClassifAtual	  
	  FROM Reops 
	  INNER JOIN Resultado_Inspecao 
	  INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
	  INNER JOIN Unidades ON INP_Unidade = Und_Codigo ON Rep_Codigo = Und_CodReop 
	  INNER JOIN Grupos_Verificacao 
	  INNER JOIN Itens_Verificacao ON Grp_Ano = Itn_Ano and Grp_Codigo = Itn_NumGrupo ON RIP_NumGrupo = Itn_NumGrupo 
	  AND RIP_NumItem = Itn_NumItem and convert(char,RIP_Ano) = Grp_Ano and (Itn_TipoUnidade = Und_TipoUnidade) 
	  AND (INP_Modalidade = Itn_Modalidade)
	  left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
	  WHERE RIP_NumInspecao='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
	</cfquery>
</cfif>
<cfif rsItem.recordCount eq 0>
    <html>
	<head>
	<title>Sistema Nacional de Controle Interno</title>
	<link href="CSS.css" rel="stylesheet" type="text/css">
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	</head>
	<body>
	<cfinclude template="cabecalho.cfm">
	<table border="0">
	<tr>
	<td>
	   Não há itens pendentes para este Relatório/Unidade de Avaliação de Controle Interno.
	<br><br>

	<input name="" value="fechar" type="button" onClick="self.close(); ">
	</td>
	</tr>
	</table>
	</body>
	</html>
	<cfabort>    
</cfif>     

<!--- Nova consulta para verificar respostas das unidades --->
<cfif (grpacesso eq "UNIDADES") and (qUsuario.Und_TipoUnidade neq 4)>
	<cfquery name="qResposta" datasource="#dsn_inspecao#">
		  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto FROM ParecerUnidade WHERE  Pos_Inspecao = '#ninsp#' AND Pos_Unidade = '#qUsuario.Usu_Lotacao#' and Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem#
	</cfquery>
<cfelse>
	<cfquery name="qResposta" datasource="#dsn_inspecao#">
	  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto FROM ParecerUnidade WHERE  Pos_Inspecao = '#ninsp#' AND Pos_Unidade = '#unid#' and Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem#
	</cfquery>
</cfif>
<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
  SELECT INP_Responsavel
  FROM Inspecao
  WHERE (INP_NumInspecao = '#Ninsp#')
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT IPT_MatricInspetor, Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor = Fun_Matric
  WHERE (IPT_NumInspecao = '#Ninsp#')
</cfquery>

<cfquery name="qTipoUnid" datasource="#dsn_inspecao#">
  SELECT TUN_Codigo FROM Tipo_Unidades INNER JOIN Unidades ON TUN_Codigo = Und_TipoUnidade WHERE Und_Codigo='#unid#'
</cfquery>
<!--- fim selects --->
<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<!--- <cfif isDefined("Form.acao") And (Form.acao is 'Anexar' Or Form.acao is 'Excluir')> --->
<cfset strManifes = "">
<cfset strRecomendacao = #rsItem.RIP_Recomendacoes#>
<cfset strComentario = #rsItem.RIP_Comentario#>
<cfset dtHojeControle = DateFormat(now(),"YYYYMMDD")>

<cfif isDefined("Form.acao")>
	<cfif Form.acao is 'Anexar' and Form.Arquivo neq "">
		<cftry>
			<cfquery name="rsSeq" datasource="#dsn_inspecao#">
				SELECT Ane_Codigo FROM Anexos
				where Ane_NumInspecao='#Form.ninsp#' and 
				Ane_Unidade='#Form.unid#' and 
				Ane_NumGrupo=#Form.ngrup# and 
				Ane_NumItem=#Form.nitem#
			</cfquery>
			<cfif rsSeq.recordcount lte 0>
				<cfset seq = 1>
			<cfelse>
				<cfset seq = val(rsSeq.recordcount + 1)>			
			</cfif>	
			<cfset seq = '_Seq' & seq>	

			<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

			<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

			<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>

			<!--- O arquivo anexo recebe nome indicando Numero da inspeção, data, N?mero do grupo e n?mero do item ao qual est? vinculado --->
			<cfset sconta = trim(CGI.REMOTE_USER)>

			<cfif left(sconta,1) is 'C'>
			<cfset sconta = Right(sconta,8)>
			<cfelse>
			<cfset sconta = Right(sconta,11)>
			</cfif>
			<cfset destino = cffile.serverdirectory & '\' & Form.ninsp & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '_' & Form.ngrup & '_' & Form.nitem & seq & '.pdf'>

			<cfif FileExists(origem)>

				<cffile action="rename" source="#origem#" destination="#destino#">

				<cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
					SELECT Ane_Codigo FROM Anexos WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
				</cfquery>

			<cfif qVerificaAnexo.recordCount eq 0>
				<cfquery datasource="#dsn_inspecao#" name="qVerifica">
					INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho) VALUES ('#Form.Ninsp#', '#Form.Unid#', #Form.Ngrup#, #Form.Nitem#, '#destino#')
				</cfquery>
			</cfif>
			</cfif>
			<cfset strManifes = FORM.observacao>
			<cfcatch type="any">
				<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação. ' & cfcatch.Message>
				<script>
					alert('<cfoutput>#mensagem#</cfoutput>');
					history.back();
				</script>
				<cfabort>
			</cfcatch>
		</cftry>
	</cfif>
	<!--- ============================= --->
	<cfif Form.acao is "Incluir_Causa" and Form.causaprovavel neq "">
		<!--- Incluir Causa Provavel --->
		<cfquery datasource="#dsn_inspecao#" name="qVerificaRegistroParecer">
		SELECT PCP_Unidade FROM ParecerCausaProvavel
		WHERE (((PCP_Unidade)='#unid#') AND ((PCP_Inspecao)='#ninsp#') AND ((PCP_NumGrupo)=#ngrup#) AND ((PCP_NumItem)=#nitem#) AND ((PCP_CodCausaProvavel)=#Form.causaprovavel#))
		</cfquery>

		<cfif qVerificaRegistroParecer.RecordCount eq 0>
			<cfquery datasource="#dsn_inspecao#" name="qVerificaCausa">
					INSERT INTO ParecerCausaProvavel(PCP_Unidade, PCP_Inspecao, PCP_NumGrupo, PCP_NumItem, PCP_CodCausaProvavel)
					VALUES ('#unid#', '#ninsp#', #ngrup#, #nitem#, #Form.causaprovavel#)
			</cfquery>
		</cfif>
		<cfset strManifes = FORM.observacao>
	</cfif>
	<!--- Excluir Causa --->
	<cfif Form.acao is 'Excluir_Causa'>
		<!--- Verificar se Causa existe --->
		<cfquery name="qCausaExcluir" datasource="#dsn_inspecao#">
			SELECT PCP_Unidade, PCP_Inspecao, PCP_NumGrupo, PCP_NumItem, PCP_CodCausaProvavel
			FROM ParecerCausaProvavel
			WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem# AND PCP_CodCausaProvavel=#vCausaProvavel#
		</cfquery>
		<cfif qCausaExcluir.recordCount Neq 0>
			<!--- Excluindo Causa do banco de dados --->
			<cfquery datasource="#dsn_inspecao#">
				DELETE FROM ParecerCausaProvavel
				WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem# AND PCP_CodCausaProvavel=#vCausaProvavel#
			</cfquery>
		</cfif>
		<cfset strManifes = FORM.observacao>
	</cfif>	
	<cfif Form.acao is 'Excluir_Anexo'>
	<!--- Verificar se anexo existe --->
		<cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos
			WHERE Ane_Codigo = #vCodigo#
		</cfquery>
		<cfset strManifes = FORM.observacao>
		<cfif qAnexos.recordCount Neq 0>
			<!--- Exluindo arquivo do diret?rio de Anexos --->
			<cfif FileExists(qAnexos.Ane_Caminho)>
				<cffile action="delete" file="#qAnexos.Ane_Caminho#">
			</cfif>
			<!--- Excluindo anexo do banco de dados --->
			<cfquery datasource="#dsn_inspecao#">
				DELETE FROM Anexos WHERE  Ane_Codigo = #vCodigo#
			</cfquery>
		</cfif>
	</cfif>	
	<cfif IsDefined("FORM.acao") And Form.acao is "Salvar2">
		<cfif isDefined("Session.E01")>
			<cfset StructClear(Session.E01)>
		</cfif>

		<cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
			<cfset strComentario = FORM.Melhoria>
		</cfif>
		<cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
			<cfset strRecomendacao = FORM.recomendacao>
		</cfif>
		<cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
			<cfset strManifes = FORM.observacao>
		</cfif>

		<cfif Form.acao is 'volta'>
			<script>
				document.frmvolta.submit();
				//return true;
			</script>
		</cfif>

</cfif>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">
	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.dtFinal" default="">
	<cfparam name="URL.DtInic" default="">
	<cfparam name="URL.dtFim" default="">
	<cfparam name="URL.Reop" default="">
	<cfparam name="URL.ckTipo" default="">
	<cfparam name="URL.posarea" default="#Form.posarea#">
<cfelse>
	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="0">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.dtFinal" default="0">
	<cfparam name="URL.DtInic" default="0">
	<cfparam name="URL.dtFim" default="0">
	<cfparam name="URL.Reop" default="">
	<cfparam name="URL.ckTipo" default="">
	<cfparam name="URL.posarea" default="">
</cfif>

<!--- ============= --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo 
</cfquery>

<!--- ============= --->
<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
  SELECT INP_Responsavel
  FROM Inspecao
  WHERE (INP_NumInspecao = '#URL.Ninsp#')
</cfquery>
<!--- ============= --->
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT IPT_MatricInspetor, Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor = Fun_Matric
  WHERE (IPT_NumInspecao = '#URL.Ninsp#')
</cfquery>
<!--- ============= --->
<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
  FROM ParecerUnidade WHERE  Pos_Inspecao = '#ninsp#' AND Pos_Unidade = '#unid#' and Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem#
</cfquery>
<!--- ============= --->
 <cfif left(ninsp,2) eq left(trim(qUsuario.Usu_Lotacao),2)>
	<cfquery name="rsMod" datasource="#dsn_inspecao#">
	  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_TipoUnidade, Dir_Descricao, Dir_Codigo, Dir_Sigla
	  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
	  WHERE Und_Codigo = '#URL.Unid#'
	</cfquery>
	<cfset auxposarea = rsMod.Und_Codigo>
	<cfset auxnomearea = rsMod.Und_Descricao>
<cfelse> 
	<cfquery name="rsMod" datasource="#dsn_inspecao#">
	  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_TipoUnidade, Dir_Descricao, Dir_Codigo, Dir_Sigla
	  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
	  WHERE Und_Codigo = '#URL.posarea#'
	</cfquery>
	<cfset auxposarea = rsMod.Und_Codigo>
	<cfset auxnomearea = rsMod.Und_Descricao>	
</cfif> 

<!--- ============= --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>

<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar">
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
		<cfset strManifes = "">
		

	<cfif (trim(rsMod.Und_Centraliza) neq "") and (rsItem.Itn_TipoUnidade eq 4)>
			<!--- AC ? Centralizada por CDD? --->
		<cfquery name="rsCDD" datasource="#dsn_inspecao#">
			SELECT Und_Codigo, Und_Descricao, Und_Email
			FROM Unidades 
			WHERE Und_Codigo = '#rsMod.Und_Centraliza#'
		</cfquery>
		<cfif rsCDD.recordcount gt 0>
			<cfset auxposarea = rsMod.Und_Centraliza>
			<cfset auxnomearea = rsCDD.Und_Descricao>
		</cfif>
	</cfif>
	<cfset Gestor = auxnomearea>

	<cfif rsMod.Und_TipoUnidade neq 12 and rsMod.Und_TipoUnidade neq 16>
		<cfset dtnovoprazo = CreateDate(right(form.cbdata,4),mid(form.cbdata,4,2),left(form.cbdata,2))> 
		<cfoutput>
			<cfset nCont = 1>
			<cfloop condition="nCont lte 1">
				<cfset vDiaSem = DayOfWeek(dtnovoprazo)>
				<cfif vDiaSem neq 1 and vDiaSem neq 7>
					<!--- verificar se Feriado Nacional --->
					<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
						SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo#
					</cfquery>
					<cfif rsFeriado.recordcount gt 0>
					<cfset nCont = nCont - 1>
					<cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
					</cfif>
				</cfif>
				<!--- Verifica se final de semana  --->
				<cfif vDiaSem eq 1 or vDiaSem eq 7>
					<cfset nCont = nCont - 1>
					<cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
				</cfif>	
				<cfset nCont = nCont + 1>
			</cfloop>	
		</cfoutput>
	<cfelse>
		<cfoutput>
			<!--- contar 30 dias úteis para AGF e ACC --->			
			<cfquery name="rs14SN" datasource="#dsn_inspecao#">
				SELECT And_DtPosic FROM Andamento
				WHERE And_Unidade='#FORM.unid#' AND 
				And_NumInspecao='#FORM.ninsp#' AND 
				And_NumGrupo=#FORM.ngrup# AND 
				And_NumItem=#FORM.nitem# AND 
				And_Situacao_Resp in(0,11,14)
				order by And_DtPosic desc
			</cfquery>
			<cfset dtnovoprazo = CreateDate(year(rs14SN.And_DtPosic),month(rs14SN.And_DtPosic),day(rs14SN.And_DtPosic))> 
			<cfset nCont = 1>
			<cfloop condition="nCont lte 30">
				<cfset dtnovoprazo = DateAdd( "d", 1, dtnovoprazo)>
				<cfset vDiaSem = DayOfWeek(dtnovoprazo)>
				<cfif vDiaSem neq 1 and vDiaSem neq 7>
					<!--- verificar se Feriado Nacional --->
					<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
						SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtnovoprazo#
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
		</cfoutput>		
	</cfif>	  

	 <cfquery datasource="#dsn_inspecao#">
	   UPDATE ParecerUnidade SET Pos_Situacao_Resp = #FORM.frmResp#
   			  , Pos_Area = '#auxposarea#'
			  , Pos_NomeArea = '#auxnomearea#'
		<cfswitch expression="#Form.frmResp#">
			<cfcase value=1>
			  , Pos_Situacao = 'RU'
			  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
			  <cfset Encaminhamento = 'Ao SGCIN'>
			  <cfset situacao = 'RESPOSTA DA UNIDADE'>
			</cfcase>
			<cfcase value=15>
			  , Pos_Situacao = 'TU'
			  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
			  <cfset Encaminhamento = 'A UNIDADE'>
			  <cfset situacao = 'TRATAMENTO UNIDADE'>
			</cfcase>
			<cfcase value=17>
			  , Pos_Situacao = 'RF'
			  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))# 
  			  <cfset Encaminhamento = 'Ao SGCIN'>
			  <cfset situacao = 'RESPOSTA DA TERCEIRIZADA'>
			</cfcase>
			<cfcase value=18>
			  , Pos_Situacao = 'TF'
			  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))# 
			  <cfset Encaminhamento = 'A UNIDADE TERCEIRIZADA'>
			  <cfset situacao = 'TRATAMENTO DE TERCEIRIZADA'>
			</cfcase>
	  </cfswitch>
	  , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
	  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
	  , Pos_NomeResp='#CGI.REMOTE_USER#'
	  , Pos_username='#CGI.REMOTE_USER#'
	  , Pos_Sit_Resp_Antes = #form.frmSituResp#
	 <!---  <cfset Encaminhamento = 'Opinião do Orgao Subordinador'> --->
	  <cfset aux_obs = "">
	  , Pos_Parecer=
		<cfset aux_obs = Trim(FORM.observacao)>
		<cfset aux_obs = Replace(aux_obs,'"','','All')>
		<cfset aux_obs = Replace(aux_obs,"'","","All")>
		<cfset aux_obs = Replace(aux_obs,'*','','All')>
		<cfset aux_obs = Replace(aux_obs,'>','','All')>
		<cfset pos_aux = trim(Form.H_obs) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & CHR(13) & CHR(13) & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	  '#pos_aux#'
	   WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
    </cfquery>

 <!--- Inserindo dados dados na tabela Andamento --->
	<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento)  & CHR(13) & CHR(13) & 'A(o) ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	<cfset hhmhss = timeFormat(now(), "HH:MM:ss")>
	<cfset hhmhss = Replace(hhmhss,':','',"All")>
	<cfset hhmhss = Replace(hhmhss,'.','',"All")> 
	<cfquery datasource="#dsn_inspecao#">
		insert into Andamento (And_NumInspecao,And_Unidade,And_NumGrupo,And_NumItem,And_DtPosic,And_username,And_Situacao_Resp,And_Area,And_NomeArea,And_HrPosic,And_Parecer) 
		values ('#FORM.ninsp#','#FORM.unid#','#FORM.ngrup#','#FORM.nitem#',#createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#,'#CGI.REMOTE_USER#','#FORM.frmResp#','#auxposarea#','#auxnomearea#','#hhmhss#','#and_obs#')
	</cfquery>
 
	<cfif form.encerrarSN eq 'S'>
		<cfquery name="rsObserv" datasource="#dsn_inspecao#">
			SELECT Pos_Parecer, Pos_Situacao_Resp
			FROM ParecerUnidade 
			WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
		</cfquery>
		<cfset msg = 'Conforme novos critérios definidos por meio da Nota Técnica N.º 51741855/2024, SEI 53180.028789/2022-72, encerra-se o acompanhamento da regularização da não conformidade registrada nesse item de avaliação.' & CHR(13) & CHR(13) & 'Tal decisão não exime os órgãos responsáveis da adoção de ações para regularização da situação registrada pelo Controle Interno, inclusive quanto ao recolhimento aos cofres da Empresa dos valores devidos, se for o caso.'>
		<cfset pos_aux = trim(rsObserv.Pos_Parecer) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM')  & '> ' & 'Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) ' & #rsItem.Und_Descricao# & CHR(13) & CHR(13) & msg & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: DCINT/SUGOV/DIGOE ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	
		<cfquery datasource="#dsn_inspecao#">
			UPDATE ParecerUnidade SET Pos_Situacao_Resp = 29
			, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
			, Pos_DtPrev_Solucao = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))# 
			, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
			, Pos_NomeResp='#CGI.REMOTE_USER#'
			, Pos_username = '#CGI.REMOTE_USER#'
			, Pos_Situacao = 'EC'
			, Pos_Parecer = '#pos_aux#'
			, Pos_Sit_Resp_Antes = #rsObserv.Pos_Situacao_Resp#
			WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
		</cfquery> 
		<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM')  & '> ' & 'Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) ' & #rsItem.Und_Descricao# & CHR(13) & CHR(13) & msg & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: DCINT/SUGOV/DIGOE ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
		<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
		<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
		<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")> 
		<cfif len(hhmmssdc) lt 9>
			<cfset hhmmssdc = hhmmssdc & '0'>
		</cfif>
		<cfquery datasource="#dsn_inspecao#">
			insert into Andamento (And_NumInspecao,And_Unidade,And_NumGrupo,And_NumItem,And_DtPosic,And_username,And_Situacao_Resp,And_Area,And_NomeArea,And_HrPosic,And_Parecer) 
			values ('#FORM.ninsp#','#FORM.unid#','#FORM.ngrup#','#FORM.nitem#',#createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#,'#CGI.REMOTE_USER#',29,'#auxposarea#','#auxnomearea#','#hhmmssdc#','#and_obs#')
		</cfquery> 
	</cfif>
	<!--- Salvar e direcionar para Pesquisa de Avaliacao --->
	<cfif form.frmSituResp is 14>
		<cfquery name="rsfim14nr" datasource="#dsn_inspecao#">
				SELECT Pos_Situacao_Resp
				FROM ParecerUnidade 
				WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_Situacao_Resp= 14
		</cfquery>
		<cfif rsfim14nr.recordcount lte 0>
			<cfquery datasource="#dsn_inspecao#" name="rsExiste">
				select Pes_Inspecao from Pesquisa_Pos_Avaliacao  where Pes_Inspecao ='#form.ninsp#'
			</cfquery>
			<cfif rsExiste.recordcount lte 0>
				<cfquery datasource="#dsn_inspecao#">
				INSERT INTO Pesquisa_Pos_Avaliacao (Pes_Inspecao)
				VALUES ('#form.ninsp#')
				</cfquery>	
			</cfif>		  
			<cflocation url="pesquisa.cfm?ninsp=#form.ninsp#&consulta=N">
		</cfif>
	</cfif>
	 
 </cfif>
  </cfif>
 
<!--- ============= --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>
<!--- ============= --->
<cfif left(ninsp,2) eq left(trim(qUsuario.Usu_Lotacao),2)>
	<cfquery name="rsMod" datasource="#dsn_inspecao#">
	  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_TipoUnidade, Dir_Descricao, Dir_Codigo, Dir_Sigla
	  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
	  WHERE Und_Codigo = '#URL.Unid#'
	</cfquery>
<cfelse>
	<cfquery name="rsMod" datasource="#dsn_inspecao#">
	  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_TipoUnidade, Dir_Descricao, Dir_Codigo, Dir_Sigla
	  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
	  WHERE Und_Codigo = '#URL.posarea#'
	</cfquery>
</cfif>

<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo 
</cfquery>


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
<cfinclude template="mm_menu.js">

//===================
function avisonci(){
//alert(document.form1.nci.value);
//alert(document.form1.frmnumseinci.value);
var x=document.form1.nci.value;
 var k=document.form1.frmnumseinci.value;
	if (x == 'Sim' && k.length == 20)
    {
	document.form1.nseincirel.value = k;
	alert('Gestor(a), Para essa informação é necessário registrar um anexo');
	}
}
//===================
function hanci(){
// alert(document.form1.nseincirel.value);
 var x=document.form1.nci.value;
 var k=document.form1.nseincirel.value;
 window.ncisei.style.visibility = 'hidden';
  if (x=='Sim'){
    window.ncisei.style.visibility = 'visible';
    document.form1.frmnumseinci.value = document.form1.nseincirel.value;
    if (k.length != 20)
    {
	 // document.form1.frmnumseinci.disabled=true;
	}
  }
}

//=================
function proc_disc(){
 var x=document.form1.abertura.value;
 window.dproc.style.visibility = 'hidden';
  if (x=='Sim'){
    window.dproc.style.visibility = 'visible';
  }
}

//=================
function exibe(a){
//  alert('exibe: ' + a);
  exibirArea(a);
  exibirAreaCS(a);
  exibirValor(a);
  dtprazo(a);
}
//==============
function exibir_Area011(x){
  document.form1.frmcbarea.selectedIndex = 0;       
  if (x != "Sim"){
		//window.area011.style.visibility = 'visible';
		document.form1.frmcbarea.disabled=false;
  } 
  else 
    {
      if (document.form1.pontocentlzSN.value == "S")
        {
     //    window.area011.style.visibility = 'hidden';  
         document.form1.frmcbarea.disabled=true; 
        }
    }
}

function dtprazo(x){
	 if(x == 1 || x == 17)
	 {
		document.form1.cbData.value = document.form1.dtrespos.value;
	 }
	 if (x == 15 || x == 18)
	 {
	   document.form1.cbData.value = document.form1.dttratam.value;
	 }	 
}
var ind
function exibirArea(ind){
//alert('exibirArea: ' + ind);
  document.form1.cbArea.disabled=false;
  if (ind==5 || ind==10 || ind==19 || ind==21){
    window.dArea.style.visibility = 'visible';
    if(ind==21) {buscaopt('SEC AVAL CONT INTERNO/SGCIN')} 
  } else {
    window.dArea.style.visibility = 'hidden';
	document.form1.cbArea.value = '';
  }
}
//====================
var idx
function exibirAreaCS(idx){
//alert(document.form1.frmnumsei.value.length);
window.dAreaCS.style.visibility = 'visible';
  if (idx==24){
    var aux_se_num_ano =  document.form1.proc_se.value + document.form1.proc_num.value + document.form1.proc_ano.value
 //  alert(aux_se_num_ano)
    if(aux_se_num_ano.length == 9 && document.form1.modalidade.value != '' && document.form1.abertura.value == 'Sim')
    {
	  travarcombo('APURACAO','frmResp'); travarcombo('CS/PRESI/CORR','cbAreaCS')
	} else { exibe('N'); travarcombo('kkk','frmResp')}
  } else if (idx == 9){}
    else {
    window.dAreaCS.style.visibility = 'hidden';
	document.form1.cbAreaCS.value = '';
  }
}
//==================================
function exibirValor(vlr){
//alert('exibirValor: ' + vlr);
  //if ((vlr==3 || vlr==9) && document.form1.vlrdeclarado.value == 'S'){
  if (vlr==3 || vlr==9){
    window.dValor.style.visibility = 'visible';
   // alert('Sr(a). Gestor, informe o Valor Regularizado, Exemplos: 1185,40; 0,07');
	document.form1.VLRecuperado.value='0,00'
	if (document.form1.vlrdeclarado.value == 'N'){document.form1.VLRecuperado.value='0,0'}
  } else {
    document.form1.VLRecuperado.value='0,00'
    window.dValor.style.visibility = 'hidden';
  }
}

//Validar de campos vazios em formulário
function validaForm() {
//=====================================
 // ==== critica do botão Salvar2 (Perfil INSPETORES) apenas ===
   if (document.form1.acao.value == 'Salvar2')
	 {
		//=================================
		if (document.form1.arquivo.value == '')
		{
			alert('Você deve informar o caminho do arquivo a ser anexado!');
			document.form1.arquivo.focus();
			return false;

		}
	 }

//=====================================
if (document.form1.acao.value == 'Salvar'){
   document.form1.cbData.disabled = false;
   var scausaprovaveis = document.form1.causasprovSN.value;
   if(scausaprovaveis == 'N')
  {
   alert('Sr(a). Colaborador(a), selecione e Inclua uma causa Provável');
   return false;
  }
  
  var strmanifesto = document.form1.observacao.value;
  strmanifesto = strmanifesto.replace(/\s/g, '');
  if(strmanifesto == '')
	  {
	   alert('Sr(a). Falta o seu Posicionamento no campo Manifestar-se!');
       return false;
	  }

  if(strmanifesto.length < 100)
   {
   alert('Sr(a). Sua manisfestação deverá conter no mínimo 100(cem) caracteres');
   return false;
   }
   
   var sit = document.form1.frmResp.value;
   if(sit == '')
	  {
	   alert('Sr(a). Selecione a Situação do seu Manifestar-se!');
	   return false;
	  }

	function adicionarDiasData(dias){
		var hoje        = new Date();
		var dataVenc    = new Date(hoje.getTime() + (dias * 24 * 60 * 60 * 1000));
		return dataVenc;
	}
	
	  
    //document.form1.cbData.disabled = false;
	var dtprevdig = document.form1.cbData.value;

	if (dtprevdig.length != 10){
		alert('Preencher campo: Data da Previsão da Solução ex. DD/MM/AAAA');
		return false;
	}
	//=============================================
    // Sem adendo no campo Pos_DtPrev_Solucao concedido pelo SGCIN
	if ((dtprevdig_yyyymmdd > And_dtposic_fut) && (And_dtposic_fut >= pos_dtPrevSoluc_atual) && (dt_hoje_yyyymmdd != dtprevdig_yyyymmdd))
	{
	<cfoutput>	
		<cfif rsItem.Und_TipoUnidade is 12 || rsItem.Und_TipoUnidade is 16>
          alert('Sr(a). Usuário. Data de Previsão da Solução deve ser preenchido com uma data igual ou inferior a data: ' + And_dtposic_fut.substr(6,2) + '/' + And_dtposic_fut.substr(4,2) + '/' + And_dtposic_fut.substr(0,4) + ' limite máximo dos 30 (trinta) dias corridos.')
          dtprazo(sit);
        <cfelse>
          alert('Sr(a). Usuário. Data de Previsão da Solução deve ser preenchido com uma data igual ou inferior a data: ' + And_dtposic_fut.substr(6,2) + '/' + And_dtposic_fut.substr(4,2) + '/' + And_dtposic_fut.substr(0,4) + ' limite máximo dos 30(trinta) dias corridos.')
          dtprazo(sit);
       </cfif> 
	</cfoutput>	
	 return false;	
	}
	//alert('dt digitada: ' + dtprevdig_yyyymmdd + ' data futuro: ' + And_dtposic_fut + ' data de hoje: ' + dt_hoje_yyyymmdd + ' Data de Precisao no banco: ' + pos_dtPrevSoluc_atual);
    // Com adendo no campo Pos_DtPrev_Solucao concedido pelo SGCIN
	if ((dtprevdig_yyyymmdd > pos_dtPrevSoluc_atual) && (pos_dtPrevSoluc_atual > And_dtposic_fut) && (dt_hoje_yyyymmdd != dtprevdig_yyyymmdd))
	{
     alert('Sr(a). Usuário. Data de Previsão da Solução deve ser preenchido com uma data igual ou inferior a data: ' + pos_dtPrevSoluc_atual.substr(6,2) + '/' + pos_dtPrevSoluc_atual.substr(4,2) + '/' + pos_dtPrevSoluc_atual.substr(0,4) + ' limite máximo já concedido por pedido ao SGCIN')
	dtprazo(sit);
	return false;
	}
	// var sit = document.form1.frmResp.value;
	  if (sit == 1) {var auxcam = '\n\nRESPOSTA DA UNIDADE\n\n - Essa opção RESPONDE o item e o encaminha para Equipe de Controle Interno da Regional (SGCIN)'};
	  if (sit == 17) {var auxcam = '\n\nRESPOSTA DA TERCEIRIZADA\n\n - Essa opção RESPONDE o item e o encaminha para Equipe de Controle Interno da Regional (SGCIN)'};
	  if (sit == 15) {var auxcam = '\n\nTRATAMENTO UNIDADE\n\n - Essa opção mantém o item a Unidade para desenvolvimento de ação que necessita de maior prazo da regularização ou resposta.\n Nesse caso deve indicar o prazo necessário no campo Data de Previsão da Solução.\n até essa data sua resposta devera ser complementada'};
	  if (sit == 18) {var auxcam = '\n\nTRATAMENTO TERCEIRIZADA\n\n - Essa opção mantém o item a Unidade para desenvolvimento de ação que necessita de maior prazo da regularização ou resposta.\n Nesse caso deve indicar o prazo necessário no campo Data de Previsão da Solução.\n até essa data sua resposta devera ser complementada'};

	 if (confirm ('            ATENÇÃO! ' + auxcam))
	    {
	  	if (sit == 1 && document.form1.PosClassificacaoPonto.value == 'LEVE' && document.form1.undtipounidade.value != 12 && document.form1.undtipounidade.value != 16) {
			  var auxcam = 'O item respondido possui classificação "LEVE". Em decorrência disso está sendo encerrado o acompanhamento pelo Controle Interno.\n\nATENÇÃO: O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor de providenciar a sua regularização.\n\nEm Avaliações de Controle futuras o item é passível de ser reavaliado. Caso seja constatada nova não conformidade, será considerada REINCIDÊNCIA, sendo acompanhada a sua regularização pelo Controle Interno.'
			  alert(auxcam);
		}		
	 //    document.form1.cbData.disabled = false;
		 return true;
		}
	else
	   {
	   if (sit != 15 || sit != 18) {document.form1.cbData.disabled = true;}
	   return false;
	   }
   }

  //==============================
   if (document.form1.acao.value == 'Incluir_Causa'){
       if (document.form1.causaprovavel.value == '') {
	   alert('Selecione uma Causa Provável a ser incluída.');
	   return false;
	   }
	   if (document.form1.causaprovavel.value != '') {
	   //======================================
			   var cmbcausaprov = document.getElementById("causaprovavel");
			   for (i = 1; i < cmbcausaprov.length; i++) {
					// alert(cmbcausaprov.options[i].value);
					if (cmbcausaprov.options[i].value ==  document.form1.causaprovavel.value){
                             // alert(cmbcausaprov.options[i].text);
							 if (confirm ('Confirma a inclusão da Causa Provável: ' + cmbcausaprov.options[i].text + ' ?'))
							   {
								}
							else
							   {
							   return false;
							   }
					    i = cmbcausaprov.length;
					 }
				}
	   //======================================
	    }
   }
  //==============================

//return false;
}
//=============================
function Trim(str)
{
while (str.charAt(0) == ' ')
str = str.substr(1,str.length -1);

while (str.charAt(str.length-1) == ' ')
str = str.substr(0,str.length-1);

return str;
}

//Função que abre uma p?gina em Popup
function popupPage() {
<cfoutput>  //p?gina chamada, seguida dos par?metros n?mero, unidade, grupo e item
var page = "itens_unidades_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}

function mensagem(){
	alert('Sr(a). Inspetor, se necessário ajuste os campos Situação Encontrada e/ou Orientação');
	}
</script>
</head>
<!--- select para atualizar o historico --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS Data, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_PontuacaoPonto, Pos_ClassificacaoPonto 
  FROM ParecerUnidade WHERE  Pos_Inspecao = '#ninsp#' AND Pos_Unidade = '#unid#' and Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem#
</cfquery>
<!--- fim atualizar Historico --->
<cfquery name="qVerificaRevisao" datasource="#dsn_inspecao#">
  SELECT ParecerUnidade.Pos_Inspecao, ParecerUnidade.Pos_Situacao_Resp
  FROM ParecerUnidade
  WHERE ParecerUnidade.Pos_NumGrupo = #ngrup# AND ParecerUnidade.Pos_NumItem = #nitem# AND ParecerUnidade.Pos_Unidade = '#unid#' AND ParecerUnidade.Pos_Inspecao = '#ninsp#' AND ((ParecerUnidade.Pos_Situacao_Resp = 0) OR (ParecerUnidade.Pos_Situacao_Resp = 13))
</cfquery>
<cfquery name="qCausa" datasource="#dsn_inspecao#">
  SELECT Cpr_Codigo, Cpr_Descricao FROM CausaProvavel WHERE Cpr_Codigo not in (select PCP_CodCausaProvavel from ParecerCausaProvavel
  WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem#)
  ORDER BY Cpr_Descricao
</cfquery>
<cfquery name="qCausaProcesso" datasource="#dsn_inspecao#">
 SELECT Cpr_Codigo, Cpr_Descricao, PCP_Unidade, PCP_CodCausaProvavel  FROM ParecerCausaProvavel INNER JOIN CausaProvavel ON PCP_CodCausaProvavel =
 Cpr_Codigo WHERE PCP_Unidade='#URL.unid#' AND PCP_Inspecao='#URL.ninsp#' AND PCP_NumGrupo=#URL.ngrup# AND PCP_NumItem=#URL.nitem#
</cfquery>
<cfquery name="rsItem" datasource="#dsn_inspecao#">
  SELECT RIP_NumInspecao, 
  RIP_Unidade, 
  Und_Descricao, 
  Und_TipoUnidade,
  RIP_NumGrupo, 
  RIP_NumItem,
  RIP_Comentario, 
  RIP_Recomendacoes, 
  INP_DtInicInspecao, 
  INP_Responsavel, 
  Rep_Codigo, 
  RIP_Valor, 
  RIP_Caractvlr, 
  RIP_Falta, 
  RIP_Sobra, 
  RIP_EmRisco, 
  RIP_ReincInspecao, 
  RIP_ReincGrupo, 
  RIP_ReincItem, 
  Itn_Descricao, 
  Itn_ImpactarTipos,  
  Itn_PTC_Seq,  
  INP_DtEncerramento, 
  Grp_Descricao,
  INP_TNCCLASSIFICACAO,
  INP_DtInicInspecao,
  TNC_ClassifInicio, 
  TNC_ClassifAtual
  FROM Reops 
  INNER JOIN Resultado_Inspecao 
  INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
  INNER JOIN Unidades ON INP_Unidade = Und_Codigo ON Rep_Codigo = Und_CodReop 
  INNER JOIN Grupos_Verificacao 
  INNER JOIN Itens_Verificacao ON Grp_Ano = Itn_Ano and Grp_Codigo = Itn_NumGrupo ON RIP_NumGrupo = Itn_NumGrupo 
  AND RIP_NumItem = Itn_NumItem and right(RIP_NumInspecao, 4) = Grp_Ano and (Itn_TipoUnidade = Und_TipoUnidade) 
  AND (INP_Modalidade = Itn_Modalidade)
  left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
  WHERE RIP_NumInspecao='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
</cfquery>
<cfset DataDia = DateFormat(now(),'DD/MM/YYYY')>

<cfset DtEncerramento = DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')>

<cfset reincSN = "N">
<cfset aux_reincSN = "Nao">
<cfset db_reincInsp = "">
<cfset db_reincGrup = 0>
<cfset db_reincItem = 0>
<cfif rsItem.RIP_ReincGrupo neq 0>
	<cfset reincSN = "S">
	<cfset aux_reincSN = "Sim">
	<cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
	<cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
	<cfset db_reincItem = #rsItem.RIP_ReincItem#>
</cfif>	

<!--- <body onLoad="dtprazo(document.form1.frmResp.value); reincidencia(document.form1.frmReinccb.value); hanci()"> --->
<body onLoad="dtprazo(document.form1.frmResp.value); hanci(); ">
 
<cfset form.acao = ''>
 <cfinclude template="cabecalho.cfm">

       <!--- area de conteudo   --->

<table width="99%" height="60" align="center">
<tr>
 <td width="74%" valign="top">
<form name="form1" method="post" onSubmit="return validaForm()" enctype="multipart/form-data" action="itens_unidades_controle_respostas1.cfm?perdaprzsn=<cfoutput>#url.perdaprzsn#</cfoutput>&posarea=<cfoutput>#url.posarea#</cfoutput>">
        <table width="70%" align="center" bordercolor="f7f7f7">
         <tr>
		    <br>
              <td colspan="5"><p align="center" class="titulo1"><strong>PONTO DE AVALIAÇÃO DE CONTROLE INTERNO</strong></p></td>
          </tr>
          
          <tr bgcolor="FFFFFF" class="exibir">
            <td colspan="4">
                      <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
                      <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
                      <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
                      <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
					  <input name="posarea" type="hidden" id="posarea" value="<cfoutput>#URL.posarea#</cfoutput>">
					  <cfif isDefined("Form.acao")>
					   <input type="hidden" name="acao" id="acao" value="<cfoutput>#Form.acao#</cfoutput>">
					  <cfelse>
					   <input type="hidden" name="acao" id="acao" value="">
					  </cfif>

                      <input type="hidden" name="anexo" id="anexo" value="">
					  <input type="hidden" name="vCodigo" id="vCodigo" value="">
					  <input name="idtpunid" type="hidden" id="idtpunid" value="<cfoutput>#trim(qTipoUnid.TUN_Codigo)#</cfoutput>">
					  <input type="hidden" id="vCausaProvavel" name="vCausaProvavel" value="">
		    </td>
          </tr>
    </tr>
	  <tr>
      <td width="95" bgcolor="eeeeee" class="exibir">Unidade</td>
      <td colspan="4" bgcolor="eeeeee">
	  <cfoutput><strong class="exibir">#URL.Unid#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput>
	  <strong class="exibir">#rsMod.Und_Descricao#</strong></cfoutput>
	  <cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;<span class="exibir">Responsável</span>:&nbsp; <strong class="exibir">#rsItem.INP_Responsavel#</strong>    
      </cfoutput>
	  </td>
      </tr>

          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td width="672" bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="4" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-</cfif></cfoutput></td>
          </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Nº Avaliação</td>
      <td colspan="4" bgcolor="eeeeee">
        <table width="1090" border="0">
          <tr>
            <td width="229"><cfoutput><strong class="exibir">#URL.Ninsp#</strong></cfoutput></td>
            <td width="834"><span class="exibir">Início Avaliação</span> &nbsp;<strong class="exibir"><cfoutput>#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></strong><span class="exibir">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Previsão Solução:</span> <strong class="exibir"><cfoutput>#DateFormat(qResposta.Pos_DtPrev_Solucao,"dd/mm/yyyy")#</cfoutput></strong></td>
          </tr>
        </table></td>
      </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Grupo</td>
            <td colspan="4" bgcolor="eeeeee"><cfoutput>#URL.Ngrup#</cfoutput> - <cfoutput><strong>#rsItem.Grp_Descricao#</strong></cfoutput></td>
          </tr>
		  <tr bgcolor="FFFFFF" class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td colspan="4" bgcolor="eeeeee"><cfoutput>#URL.Nitem#</cfoutput> - <cfoutput><strong>#rsItem.Itn_Descricao#</strong></cfoutput></td>
          </tr>
		  
           <tr class="exibir">
			  <td bgcolor="eeeeee">Relevância</td>
			  <td colspan="4" bgcolor="eeeeee">
			  <table width="100%" border="0">
				<tr class="exibir">
				  <td width="62">Pontuação</td>
				  <td width="201"><strong class="exibir"><cfoutput>#qResposta.Pos_PontuacaoPonto#</cfoutput></strong></td>
				  <td width="150"><div align="right">Classificação do Ponto</div></td>
				  <td width="315"><strong class="exibir"><cfoutput>#qResposta.Pos_ClassificacaoPonto#</cfoutput></strong></td>
				</tr>
			  </table></td>
		  </tr>
	<tr bgcolor="eeeeee" class="exibir">
	  <td>Classificação Unidade</td>
	  <td colspan="4"><table width="100%" border="0">
		<tr>
		  <td width="15%" class="exibir"><div align="center">Classificação Inicial:</div></td>
		  <td width="35%" class="exibir"><strong><cfoutput>#rsItem.TNC_ClassifInicio#</cfoutput></strong></td>
		  <td width="18%" class="exibir"><div align="center">Classificação Atual:</div></td>
		  <td width="32%" class="exibir"><div align="left"><strong><cfoutput>#rsItem.TNC_ClassifAtual#</cfoutput></strong></div></td>
		</tr>
	  </table></td>
 	 </tr>		  
<cfoutput>		
<cfset reincSN = "N">
<cfset aux_reincSN = "Nao">
<cfset db_reincInsp = "">
<cfset db_reincGrup = 0>
<cfset db_reincItem = 0>
<cfif rsItem.RIP_ReincGrupo neq 0>
	<cfset reincSN = "S">
	<cfset aux_reincSN = "Sim">
	<cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
	<cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
	<cfset db_reincItem = #rsItem.RIP_ReincItem#>
</cfif>	   
	<cfif reincSN eq 'S'>
		<tr class="red_titulo">
			<td bgcolor="eeeeee">Reincidência</td>
			<td colspan="4" bgcolor="eeeeee">Nº Avaliação:
				<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Grupo:
			<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Item:
			<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" onKeyPress="numericos(this.value)">
			</strong>		  
			</td>
	</tr>
	</cfif> 
	<cfset impactofin = 'N'>
	<cfset tipoimpacto = 'NÃO QUANTIFICADO'>
	<cfif listFind(#rsItem.Itn_PTC_Seq#,'10')>
	  	<cfset impactofin = 'S'>
		<cfset tipoimpacto = 'QUANTIFICADO'>
	</cfif>
	<cfset falta = lscurrencyformat(rsItem.RIP_Falta,'Local')>
	<cfset sobra = lscurrencyformat(rsItem.RIP_Sobra,'Local')>
	<cfset emrisco = lscurrencyformat(rsItem.RIP_EmRisco,'Local')>
	<cfset fator = 0>
	<cfset somafalta = (rsItem.RIP_Falta)>	 
	<cfset somafalta = numberformat(#somafalta#,9999999999.99)>  
	<cfset encerrarSN = 'N'>
	<cfif rsItem.Und_TipoUnidade neq 12>
		<cfif trim(ucase(qResposta.Pos_ClassificacaoPonto)) eq 'LEVE'>
			<cfset encerrarSN = 'S'>
		<cfelseif trim(ucase(qResposta.Pos_ClassificacaoPonto)) eq 'MEDIANO' and somafalta lte 1000>
			<cfset encerrarSN = 'S'>
		</cfif> 
	</cfif>
	
	<!---
	<cfif reincSN neq 'S' and rsItem.Und_TipoUnidade neq 12>
		<cfif impactofin eq 'N'>
			<!--- Não tem impacto financeiro --->
			<!--- <cfset encerrarSN = 'S'> --->
		<cfelse>
			<cfset somafalta = numberformat(#somafalta#,9999999999.99)>
			<!--- Tem impacto financeiro --->
			<!---
			<cfquery name="rsRelev" datasource="#dsn_inspecao#">
				SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
				FROM ValorRelevancia
				WHERE VLR_Ano = '#right(ninsp,4)#'
			</cfquery>
			<cfloop query="rsRelev">
				<cfset fxini = numberformat(rsRelev.VLR_FaixaInicial,9999999999.99)>
				<cfset fxfim = numberformat(rsRelev.VLR_FaixaFinal,9999999999.99)>
				<cfif fxini eq 0.00 and somafalta lte fxfim and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator>
				</cfif>
				<cfif (fxini neq 0.00 and fxfim neq 0.00) and (somafalta gt fxini and somafalta lte fxfim) and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator>
				</cfif>					
				<cfif fxfim eq 0.00 and somafalta gte fxini and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator> 
				</cfif>
			</cfloop>				
			<cfif fator eq 1>
				<cfset encerrarSN = 'S'>
			</cfif>
			--->
		</cfif>
	</cfif>	
--->
		
 	<tr class="exibir">
      <td bgcolor="eeeeee"><div id="impactofin">IMPACTO FINANCEIRO (Valor)</div></td>
      <td colspan="5" bgcolor="eeeeee">
		  <table width="100%" border="0" cellspacing="0" bgcolor="eeeeee">
			<tr class="exibir"><strong>
				<td width="40%" bgcolor="eeeeee"><strong>&nbsp;#tipoimpacto#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Falta(R$):&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" readonly></strong></td>
				<td width="30%" bgcolor="eeeeee"><strong>Sobra(R$):&nbsp;<input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" readonly></strong></td>
				<td width="30%" bgcolor="eeeeee"><strong>Em Risco(R$):&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" readonly></strong></td>
			</tr>
		  </table>		  
	  </td>
    </tr>	  
	</cfoutput>
	<tr class="exibir">
		<td colspan="4" bgcolor="eeeeee"></td>
	</tr>

    <tr>
	 <td height="38" bgcolor="eeeeee" align="center"><span class="titulos">Oportunidade<br>de<br>Aprimoramento:</span></td>
	 <td colspan="4" bgcolor="eeeeee">
	  <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
		 <cfset melhoria = '#strComentario#'>
	     <textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#melhoria#</cfoutput></textarea>
	  <cfelse>
		 <cfset melhoria ='#rsItem.RIP_Comentario#'>
	     <textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Comentario#</cfoutput></textarea>
      </cfif>	  </td>
	 </tr>
       <!--- <input type="hidden" name="recom" value="<cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput>"> --->
    <tr>
       <td height="38"  bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
	   <td colspan="4" bgcolor="eeeeee">
       <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
       <textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#strRecomendacao#</cfoutput></textarea>
   <cfelse>
       <textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea>
   </cfif>
   </td>
   <cfset resp = #qResposta.Pos_Situacao_Resp#>
   <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
	  <tr>
	    <td align="center" valign="middle"  bgcolor="eeeeee"><div align="left"><span class="titulos">ANEXOS</span></div></td>
		 <td colspan="4" align="center"  bgcolor="eeeeee">&nbsp;</td>
	  </tr>
	  <tr>
		<td align="center" bgcolor="eeeeee" class="titulos">Arquivo:</td>
		<td colspan="2" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
		<td colspan="2" bgcolor="eeeeee" class="exibir">
		 <cfif (resp neq 21)>
		  <input name="submit" id="Submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar">
		<cfelse> 
		  <input name="submit" id="Submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" disabled>
		 </cfif>      </td>
      </tr>
	  <tr>
          <td colspan="5">&nbsp;</td>
	  </tr>
	<cfset cla = 0>
	<cfloop query= "qAnexos">
		
       <cfif FileExists(qAnexos.Ane_Caminho)>
		 <cfset cla = cla + 1>
		<cfif cla lt 10>
			<cfset cl = '0' & cla & 'º'>
		<cfelse>
			<cfset cl = cla & 'º'>
		</cfif>	   
        <tr>
         <td colspan="3" bgcolor="eeeeee" class="form"><cfoutput>#cl# - #ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
	   <cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
         <td width="338" bgcolor="eeeeee"><input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
         <td width="90" bgcolor="eeeeee">
		 <cfoutput>
		<!--- 	<cfif (resp neq 21)>
				<input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#">
		    <cfelse> --->
		        <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#" disabled>
		    <!--- </cfif> --->
           </cfoutput>          </td>
        </tr>
       </cfif>
     </cfloop>
	  <tr>
		<td colspan="5">&nbsp;</td>
	  </tr>
	  <tr align="center">
	  <input type="hidden" name="rdCentraliz" id="rdCentraliz" value="N">
         <td colspan="4" align="right"><div align="center">
		 <cfoutput><input type="button" class="botao" value="Voltar" onClick="window.open('itens_unidades_controle_respostas.cfm?ninsp=#URL.Ninsp#&form.rdCentraliz=#rdCentraliz#&flush=true','_self')"></cfoutput>
         </div></td>
		 <td align="left"><div align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		 <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
			  <cfif (grpacesso eq "GESTORES" or grpacesso eq "INSPETORES")>
					<input type="Submit" name="Submit" value="Salvar" class="botao" onClick="document.form1.acao.value='Salvar2'">
			  <cfelse>
					<input type="Submit" name="Submit" value="Salvar" class="botao" onClick="document.form1.acao.value='Salvar2'" disabled>
			 </cfif>
		 <cfelse>
		     <input type="Submit" name="Submit" value="Salvar" class="botao" onClick="document.form1.acao.value='Salvar2'">
		 </cfif>
		 </div> </td>
     <cfabort>
   </cfif>

		    <input type="hidden" name="frmSituResp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
			<input type="hidden" name="frmDescSituResp" value="<cfoutput>#qResposta.Pos_Situacao#</cfoutput>">
           <!---  <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
          <tr>
            <td height="38" align="center" bgcolor="eeeeee" class="exibir"><strong>Histórico das<br>Manifestações e<br>Plano de<br>Ação/Análise do<br>Controle Interno</strong></td>

			<td colspan="4" bgcolor="eeeeee">
			<!--- <cfif Not IsDefined("FORM.MM_UpdateRecord") And Trim(qResposta.Pos_Parecer) neq ''>
              <textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></cfif> --->
			  <textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea>			</td>
          </tr><br>
		  <cfset habIncCausa = ''>
		  <cfif qCausaProcesso.recordcount gte 3>
		  	<cfset habIncCausa = 'disabled'>
		  </cfif>
		  <cfset resp = qResposta.Pos_Situacao_Resp>
		  <cfif resp eq 3 or resp eq 28 or resp eq 29>
			<cfset habIncCausa = 'disabled'>
		  </cfif>
		  <tr bgcolor="eeeeee">
      <td bgcolor="eeeeee" align="center"><span class="titulos">Causas Prováveis:</span></td>
      <td colspan="3" valign="middle" bgcolor="eeeeee" class="exibir">
	  <select name="causaprovavel" id="causaprovavel" class="form">
        <option selected="selected" value="">---</option>
        <cfoutput query="qCausa">
          <option value="#Cpr_Codigo#">#Cpr_Descricao#</option>
        </cfoutput>
      </select></td>
      <td><input name="btn_inc_causa" id="btn_inc_causa" type="Submit" class="botao" value="Incluir Causa" onClick="document.form1.acao.value='Incluir_Causa';" <cfoutput>#habIncCausa#</cfoutput>></td>
	</tr>
	<cfset resp = qResposta.Pos_Situacao_Resp>
	<cfoutput query="qCausaProcesso">
		<tr bgcolor="eeeeee">
		  <td bgcolor="eeeeee">&nbsp;</td>
		  <td colspan="3" bgcolor="eeeeee" valign="middle" class="exibir"> #Cpr_Descricao# </td>
		     <td bgcolor="eeeeee"><input name="btn_ExcluirCausa" id="btn_ExcluirCausa" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Causa';document.form1.vCausaProvavel.value=#qCausaProcesso.Cpr_Codigo#" value="Excluir Causa" codigo="#qCausaProcesso.Cpr_Codigo#" disabled></td>
		</tr>
	 </cfoutput>
	<cfif qCausaProcesso.recordcount gt 0>
	 <cfset aux_causa = "S">
	<cfelse>
	 <cfset aux_causa = "N">
	</cfif>
	<input type="hidden" name="causasprovSN" id="causasprovSN" value="<cfoutput>#aux_causa#</cfoutput>">
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
		<cfset resp = qResposta.Pos_Situacao_Resp>
          <cfif (resp eq 1 or resp eq 2 or resp eq 14 or resp eq 15 or resp eq 17 or resp eq 18 or resp eq 20 or resp eq 28) or (resp eq 4 and url.perdaprzsn eq 'S') or (resp eq 16 and url.perdaprzsn eq 'S')>
          <tr>
            <td bgcolor="eeeeee" align="center"><span class="titulos">Manifestar-se:</span></td>
            <td colspan="4" bgcolor="eeeeee"><span class="exibir">
              <textarea name="observacao" cols="200" rows="20" nome="observacao" vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#strManifes#</cfoutput></textarea>
            </span></td>
          </tr>
		</cfif>

		  <tr>
		    <td bgcolor="eeeeee" class="titulos"><div align="center">ANEXOS</div></td>
	        <td colspan="4" align="left" valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
          </tr>
		  <cfset resp = qResposta.Pos_Situacao_Resp>
		  <cfif (qResposta.Pos_Situacao_Resp eq 1 or qResposta.Pos_Situacao_Resp eq 2 or qResposta.Pos_Situacao_Resp eq 14 or qResposta.Pos_Situacao_Resp eq 15 or qResposta.Pos_Situacao_Resp eq 17 or qResposta.Pos_Situacao_Resp eq 18 or qResposta.Pos_Situacao_Resp eq 20 or qResposta.Pos_Situacao_Resp eq 28)
		     or (qResposta.Pos_Situacao_Resp eq 4 and url.perdaprzsn eq 'S') or (qResposta.Pos_Situacao_Resp eq 16 and url.perdaprzsn eq 'S')>

		  <tr><td bgcolor="eeeeee" class="titulos"><div align="center">Arquivo:</div></td>
	        <td bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="120"></td>
	        <td colspan="3" bgcolor="eeeeee" class="exibir">            
		      <div align="center">
			      <cfif (resp neq 21)>
		          <input name="submit" id="Submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" #habIncCausa#>
		          <cfelse>
		          <input name="submit" id="Submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" disabled>
                </cfif>
              </div></td>
         </tr>
	        <cfelse>

	      </tr>
		  </cfif>
	 <cfset cla = 0>		  
	 <cfloop query= "qAnexos">
		
       <cfif FileExists(qAnexos.Ane_Caminho)>
		 <cfset cla = cla + 1>
		<cfif cla lt 10>
			<cfset cl = '0' & cla & 'º'>
		<cfelse>
			<cfset cl = cla & 'º'>
		</cfif>	   
	      <cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
          <tr>
            <td colspan="5" bgcolor="eeeeee" class="form"><table width="100%" border="0" cellspacing="0" bgcolor="eeeeee">
              <tr class="form">
                <td width="72%"><cfoutput>#cl# - #ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
                <td width="28%">
                  <div align="right">
  <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <cfoutput>
			              <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#" disabled>
		        </cfoutput></div></td>
              </tr>
            </table></td>
          </tr>
          <tr>
         <td bgcolor="eeeeee" class="form"></td>  
        </tr>
      </cfif>
    </cfloop>
<!---  --->  	
<cfoutput>
    <cfset posdtprevsolucao = CreateDate(year(now()),month(now()),day(now()))>
	<cfset posdtprevsolucao = dateformat(qResposta.Pos_DtPrev_Solucao,"YYYYMMDD")>
	<cfset dtbase = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtrespos = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dttratam = CreateDate(year(now()),month(now()),day(now()))>
	<!--- <cfset dttratam = dateformat(dttratam,"YYYYMMDD")> --->
	<cfset dt30diasuteis = CreateDate(year(now()),month(now()),day(now()))>
	
	<cfif (rsItem.Und_TipoUnidade eq 12) or (rsItem.Und_TipoUnidade eq 16)>
		<cfquery name="rsPonto" datasource="#dsn_inspecao#">
			SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 17)
		</cfquery>
	</cfif>
	<cfif (rsItem.Und_TipoUnidade neq 12) and (rsItem.Und_TipoUnidade neq 16)>
        <!--- unidades proprias --->   
		<!--- identificar a data do 30 trinta dias úteis a partir do status 2;14 e 15 pelo component CFC/Dao --->
		<cfobject component = "CFC/Dao" name = "dao">
		<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="VencidoPrazo_Andamento" NumeroDaInspecao="#ninsp#" 
		CodigoDaUnidade="#unid#" Grupo="#ngrup#" Item="#nitem#" MostraDump="no" RetornaQuantDias="yes" ApenasDiasUteis="yes" ListaDeStatusContabilizados="2,14,15">			
		
		<cfset auxQtdDias = VencidoPrazo_Andamento> 
		<cfif VencidoPrazo_Andamento lte 0>	
			<cfset auxQtdDias = 30>	
		<cfelseif VencidoPrazo_Andamento lte 30>
		    <cfset auxQtdDias = (30 - VencidoPrazo_Andamento)>	
		<cfelse>
		  <cfset auxQtdDias = 0>
		</cfif>
			
		<!--- <cfif auxQtdDias gt 0> --->
		    <!--- identificar a data útil da qtd de dias que ainda restam para completar 30 dias úteis --->
			<cfset nCont = 1>
			<cfloop condition="nCont lte #auxQtdDias#">
				<cfset dt30diasuteis = DateAdd( "d", 1, dt30diasuteis)>
				<cfset vDiaSem = DayOfWeek(dt30diasuteis)>
				<cfif vDiaSem neq 1 and vDiaSem neq 7>
					<!--- verificar se Feriado Nacional --->
					<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
						 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dt30diasuteis#
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
			<cfset dt30diasuteis = dateformat(dt30diasuteis,"YYYYMMDD")>
			<cfif dt30diasuteis gte posdtprevsolucao>
				<cfset dtbase = dt30diasuteis>
			<cfelse>
				<cfset dtbase = posdtprevsolucao>	
				<cfset auxQtdDias = DateDiff("d", dt30diasuteis,posdtprevsolucao)>
			</cfif>
			<cfif dtbase lte dateformat(now(),"YYYYMMDD") or encerrarSN eq 'S'>
				<!--- somente direito a responder --->
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 1)
				</cfquery> 
			<cfelse>
				<!--- possui direitode tratamento e de resposta --->	
				<!--- Contar os possiveis dez dias uteis para tratamento --->	
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (1,15)
				</cfquery>  

				<!--- inicio 10 (dez) dias uteis para tratamento --->
				<!--- <cfset auxdtprev = CreateDate(year(now()),month(now()),day(now()))> --->
				<cfset nCont = 1>
				<!--- <cfloop condition="(nCont lte #auxQtdDias# and #dtbase# lte #dateformat(dttratam,'YYYYMMDD')#)"> --->
				<cfloop condition="(nCont lte 10 and #dtbase# gt #dateformat(dttratam,'YYYYMMDD')#)">
					<cfset dttratam = DateAdd( "d", 1, dttratam)>
					<cfset vDiaSem = DayOfWeek(dttratam)>
					<cfif vDiaSem neq 1 and vDiaSem neq 7>
						<!--- verificar se Feriado Nacional --->
						<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
							SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dttratam#
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
			</cfif>	
	</cfif>								
</cfoutput>

	<input name="dttratam" type="hidden" id="dttratam" value="<cfoutput>#dateformat(dttratam,"DD/MM/YYYY")#</cfoutput>">
	<input name="dtrespos" type="hidden" id="dtrespos" value="<cfoutput>#dateformat(dtrespos,"DD/MM/YYYY")#</cfoutput>">
	<input name="frmnovoprazo" type="hidden" id="frmnovoprazo" value="N">

<!---  --->
<!--- </cfoutput> --->
    <tr>
      <td colspan="5" class="titulos">&nbsp;</td>
      </tr>
    <tr>
            <td align="center" bgcolor="eeeeee" class="titulos">Situação:</td>
				<td colspan="5" bgcolor="eeeeee" class="exibir">
				<div align="left">
			  <select name="frmResp" class="exibir" id="frmResp" onChange="dtprazo(this.value)">
	            <cfif rsPonto.recordcount gt 0>
					<option value="" selected>---</option>
                </cfif> 
				<cfoutput query="rsPonto">
				  <option value="#STO_Codigo#">#trim(STO_Descricao)#</option>
				</cfoutput>
              </select>
                </div>				
			 </td>
		  </tr>
       <input type="hidden" name="frmSitResp_Banco" id="frmSitResp_Banco" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
	   <!--- <input name="pos_posic_ymd" type="hidden" id="pos_posic_ymd" value="<cfoutput>#dateformat(qResposta.Pos_DtPosic,"YYYYMMDD")#</cfoutput>"> --->

	  <cfoutput>
		<cfset SitResp = #qResposta.Pos_Situacao_Resp#>

		<input type="hidden" name="vPSitResp" id="vPSitResp" value="#qResposta.Pos_Situacao_Resp#">
		<cfquery name="qStatus14" datasource="#dsn_inspecao#">
		 select And_DtPosic from andamento where And_Situacao_Resp = 14 and And_Unidade = '#unid#' and And_NumInspecao = '#ninsp#' and And_NumGrupo = #ngrup# and And_NumItem = #nitem# order by And_DtPosic, And_HrPosic
		</cfquery>
		  <tr>
		    <td colspan="5">&nbsp;</td>
	      </tr>
	
		  <tr>
			 <td colspan="5" bgcolor="eeeeee" class="exibir"><div id="dData" class="titulos">Data de Previsão da Solução:
			   <input name="cbData" type="text" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" value="#dateformat(now(),"dd/mm/yyyy")#" readonly="yes">
			</div>			</td>
		  </tr>
		   <cfset resp = qResposta.Pos_Situacao_Resp>
		  <cfset diasdec = qResposta.Data>

		  <tr align="center" valign="middle">
		    <td colspan="5" class="exibir"><table width="200" border="0">
              <tr>
                <td><input type="button" class="botao" value="Voltar" onClick="window.open('itens_unidades_controle_respostas.cfm?ninsp=#URL.Ninsp#&form.rdCentraliz=#rdCentraliz#&flush=true','_self')"></td>
                <td>
           <cfset habbtnSN='disabled'>
		   <cfif grpacesso is 'UNIDADES'>
			<cfset habbtnSN=''>
		   </cfif>
			<cfif (resp eq 2 or resp eq 14 or resp eq 15 or resp eq 18 or resp eq 20) or (resp eq 4 and url.perdaprzsn eq 'S') or (resp eq 16 and url.perdaprzsn eq 'S')>
              <input name="Submit" type="submit" value="Salvar" class="botao" onClick="document.form1.acao.value='Salvar';document.form1.exigedata.value='S'" #habbtnSN#>
            <cfelse>
             <input name="Submit" type="submit" value="Salvar" class="botao" onClick="document.form1.acao.value='Salvar';document.form1.exigedata.value='S'" disabled> 
		    </cfif>				</td>
              </tr>
            </table></td>
	    </tr>
	  </cfoutput>
  </table>
<cfoutput>
	<input name="exigedata" type="hidden" id="exigedata" value="N">
	<input type="hidden" name="MM_UpdateRecord" value="form1">
	<input type="hidden" name="rdCentraliz" id="rdCentraliz" value="#rdCentraliz#">	
	<input type="hidden" name="PosClassificacaoPonto" id="PosClassificacaoPonto" value="#trim(qResposta.Pos_ClassificacaoPonto)#">
	<input type="hidden" name="undtipounidade" id="undtipounidade" value="#trim(rsItem.Und_TipoUnidade)#">
	<input type="hidden" name="encerrarSN" id="encerrarSN" value="#encerrarSN#">
	<!--- encerrarSN: #encerrarSN# somafalta: #somafalta# --->
	<input name="somafalta" type="hidden" id="somafalta" value="#somafalta#">
	<input name="reincideSN" type="hidden" id="reincideSN" value="#reincSN#">
</cfoutput>

      </div>
</form>
</td>
  </tr>
</table>
</body>

<script>
	<cfoutput>
		<!---Retorna true se a data de in?cio da inspeção for maior ou igual a 04/03/2021, data em que o editor de texto foi implantado. Isso evitar? que os textos anteriores sejam desformatados--->
		<cfset CouponDate = createDate( 2021, 03, 04 ) />
		<cfif DateDiff( "d", '#rsItem.INP_DtInicInspecao#',CouponDate ) GTE 1>
			<cfset usarEditor = false />
		<cfelse>
			<cfset usarEditor = true />
		</cfif>
		var usarEditor = #usarEditor#;
	</cfoutput>
	if(usarEditor == true){
		//configurações diferenciadas do editor de texto.
		CKEDITOR.replace('Melhoria', {
		width: 1020,
		height: 200,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});

		CKEDITOR.replace('recomendacao', {
		width: 1020,
		height: 100,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});
	}
            
</script>
</html>