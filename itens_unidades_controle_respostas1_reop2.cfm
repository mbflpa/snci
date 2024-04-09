<cfprocessingdirective pageEncoding ="utf-8"/> 
<!--- <cfdump var="#form#">
<cfdump var="#url#">
<cfdump var="#session#"> --->
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>  
<cfset Session.E01.observacao = ''>

<!--- ============= --->
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_GrupoAcesso, Usu_DR
 FROM Usuarios
 WHERE Usu_Login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
 GROUP BY Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_GrupoAcesso, Usu_DR
</cfquery>
<cfquery name="rsArea" datasource="#dsn_inspecao#">
	 SELECT Ars_Codigo, Ars_Descricao FROM Areas WHERE Ars_Codigo = '#qUsuario.Usu_Lotacao#'
</cfquery> 

<!--- ============= --->
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
  Itn_Descricao,
  Itn_TipoUnidade, 
  INP_DtEncerramento, 
  Grp_Descricao,
  RIP_ReincInspecao, 
  RIP_ReincGrupo, 
  RIP_ReincItem,
  TNC_ClassifInicio, 
  TNC_ClassifAtual  
  FROM Reops 
  INNER JOIN Resultado_Inspecao 
  INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
  INNER JOIN Unidades ON INP_Unidade = Und_Codigo ON Reops.Rep_Codigo = Unidades.Und_CodReop 
  INNER JOIN Grupos_Verificacao 
  INNER JOIN Itens_Verificacao 
  ON Grp_Codigo = Itn_NumGrupo and Grp_Ano = Itn_Ano 
  ON RIP_NumGrupo = Itn_NumGrupo AND RIP_NumItem = Itn_NumItem AND 
  convert(char(4),RIP_Ano) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
  left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
  WHERE RIP_NumInspecao='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
</cfquery>

<cfif Trim(qUsuario.Usu_GrupoAcesso) eq 'ORGAOSUBORDINADOR' or Trim(qUsuario.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qUsuario.Usu_GrupoAcesso) eq 'GESTORES' or Trim(qUsuario.Usu_GrupoAcesso) eq 'INSPETORES'>

<cftry>

<cfif isDefined("Form.acao") And (Form.acao is 'Anexar' Or Form.acao is 'Excluir')>

	<cfif isDefined("Form.obs")><cfset Session.E01.obs = Form.obs><cfelse><cfset Session.E01.obs = ''></cfif>
	<cfif isDefined("Form.observacao")><cfset Session.E01.observacao = Form.observacao><cfelse><cfset Session.E01.observacao = ''></cfif>
	<cfif isDefined("Form.h_obs")><cfset Session.E01.h_obs = Form.h_obs><cfelse><cfset Session.E01.h_obs = ''></cfif>

	 <cfif Form.acao is 'Anexar'>
		<cftry>

		<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		<!--- O arquivo anexo recebe nome indicando Numero da inspeção, Número da unidade, Número do grupo e número do item ao qual está vinculado --->

		<cfset destino = cffile.serverdirectory & '\' & Form.ninsp & '_' & data & '_' & Right(CGI.REMOTE_USER,8) & '_' & Form.ngrup & '_' & Form.nitem & '.pdf'>


		<cfif FileExists(origem)>

			<cffile action="rename" source="#origem#" destination="#destino#">

			<cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
				SELECT Ane_Codigo FROM Anexos
				WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
			</cfquery>


			<cfif qVerificaAnexo.recordCount eq 0>

				<cfquery datasource="#dsn_inspecao#" name="qVerifica">
				 INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho)
				 VALUES ('#Form.ninsp#','#Form.unid#',#Form.ngrup#,#Form.nitem#,'#destino#')
				</cfquery>

			</cfif>
		</cfif>

		<cfcatch type="any">
			<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação, o campo Arquivo está vazio, Selecione um arquivo no formato PDF'>
			<script>
				alert('<cfoutput>#mensagem#</cfoutput>');
				history.back();
			</script>
			<cfif isDefined("Session.E01")>
			 <cfset StructClear(Session.E01)>
			</cfif>
			<!--- <cfdump var="#cfcatch#">
			<cfabort> --->
		</cfcatch>

		</cftry>

  </cfif>


	  <!--- Excluir anexo --->
	 <cfif Form.acao is 'Excluir'>
	  <!--- Verificar se anexo existe --->

		<cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos WHERE Ane_Codigo = '#vCodigo#'
		</cfquery>


	  <cfif qAnexos.recordCount Neq 0>

		<!--- Exluindo arquivo do diretório de Anexos --->
		<cfif FileExists(qAnexos.Ane_Caminho)>
			<cffile action="delete" file="#qAnexos.Ane_Caminho#">
		</cfif>


	<!--- Excluindo anexo do banco de dados --->

		<cfquery datasource="#dsn_inspecao#">
		  DELETE FROM Anexos WHERE Ane_Codigo = '#vCodigo#'
		</cfquery>

      </cfif>
   </cfif>
</cfif>

<!--- <cfset area = 'sins'> --->
<cfset Encaminhamento = 'À SGCIN'>

<cfset evento = 'document.form1.observacao.focus();'>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfset dtHojeControle = DateFormat(now(),"YYYYMMDD")>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">
	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.Reop" default="#Form.Reop#">
	<cfparam name="URL.sfrmPosArea" default="#Form.sfrmPosArea#">
    <cfparam name="URL.sfrmPosNomeArea" default="#form.sfrmPosNomeArea#">
    <cfparam name="URL.sfrmTipoUnidade" default="#Form.sfrmTipoUnidade#">
	<cfparam name="URL.ckTipo" default="form.ckTipo">
<cfelse>
	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="0">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.DtInic" default="">
	<cfparam name="URL.dtFim" default="">
	<cfparam name="URL.Reop" default="">
	<cfparam name="URL.ckTipo" default="">
	<cfparam name="URL.SE" default="">
	<cfparam name="URL.sfrmPosArea" default="">
    <cfparam name="URL.sfrmPosNomeArea" default="">
    <cfparam name="URL.sfrmTipoUnidade" default="">
	<cfparam name="URL.dtFinal" default="">

</cfif>
<cfquery name="rsTPUnid" datasource="#dsn_inspecao#">
     SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#URL.unid#'
</cfquery>
<cfif rsTPUnid.Und_TipoUnidade is 12>
    <cfif Situacao is 5>
	    <cfquery name="rsPonto" datasource="#dsn_inspecao#">
			  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (6,19)
		</cfquery>
	<cfelse>
		<cfquery name="rsPonto" datasource="#dsn_inspecao#">
			  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (7,16)
		</cfquery>
	</cfif>
<cfelse>
    <cfif Situacao is 5>
		<cfquery name="rsPonto" datasource="#dsn_inspecao#">
			  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (6,19)
		</cfquery>
	<cfelse>
		<cfquery name="rsPonto" datasource="#dsn_inspecao#">
			  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (7,16)
		</cfquery>
	</cfif>
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
SELECT Pos_Area, Pos_NomeArea, Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Parecer, Pos_DtPosic, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, Pos_DtPrev_Solucao, Itn_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
FROM  Inspecao 
 INNER JOIN (Diretoria 
 INNER JOIN ((Resultado_Inspecao 
 INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) 
 AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
 INNER JOIN Unidades ON (Pos_Unidade = Und_Codigo)
 INNER JOIN (Itens_Verificacao 
 INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo and Itn_Ano = Grp_Ano) 
 ON (Pos_NumGrupo = Itn_NumGrupo) AND (Pos_NumItem = Itn_NumItem)) ON Dir_Codigo = RIP_CodDiretoria) ON (INP_NumInspecao = RIP_NumInspecao) 
 AND convert(char(4),RIP_Ano) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
 WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>

<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>
<cfquery name="rsMod" datasource="#dsn_inspecao#">
	SELECT Und_Descricao, Und_CodReop, Und_Codigo, Und_Centraliza, Und_CodDiretoria, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
	FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
	WHERE Und_Codigo = '#url.unid#'
</cfquery>
<cfset strIDGestor = #URL.Unid#>
 <cfset strNomeGestor = #rsMod.Und_Descricao#>
 <cfset Gestor = '#rsMod.Und_Descricao#'>
<!---  <cfoutput>centralizador: #rsMod.Und_Centraliza#  ponto: #rsItem.Itn_TipoUnidade#</cfoutput> --->

<!--- ============= --->
<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar">
		 <cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
		<cfif left(maskcgiusu,8) eq 'EXTRANET'>
			<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
		<cfelse>
			<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
		</cfif>
		<cfset dia_data = Left(FORM.cbData,2)>
		<cfset mes_data = Mid(FORM.cbData,4,2)>
		<cfset ano_data = Right(FORM.cbData,2)>
		<cfset dtnovoprazo = CreateDate(ano_data,mes_data,dia_data)>
	

		<!--- inicio loop --->
	  <cfset nCont = 1>
	  <cfloop condition="nCont lte 1">
		<cfset nCont = nCont + 1>
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
	  </cfloop>	
	  <!--- ===================== --->
		 <cfquery datasource="#dsn_inspecao#">
			UPDATE ParecerUnidade SET Pos_Situacao_Resp = #FORM.frmResp#    
			<cfswitch expression="#Form.frmResp#">
				<cfcase value=6>
					, Pos_Area = '#qResposta.Pos_Area#' 
					, Pos_NomeArea = '#qResposta.Pos_NomeArea#' 
					, Pos_Situacao = 'RA'
					, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
					<cfset Gestor = 'SGCIN'>
					<cfset situacao = 'RESPOSTA DA AREA'>
					<cfset strIDGestor = #qResposta.Pos_Area#>
					<cfset strNomeGestor = #qResposta.Pos_NomeArea#>
				</cfcase>		
				<cfcase value=7>
					, Pos_Situacao = 'RS'
					, Pos_Area = '#qResposta.Pos_Area#' 
					, Pos_NomeArea = '#qResposta.Pos_NomeArea#' 
					, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
					<cfset Gestor = 'SGCIN'>
					<cfset situacao = 'RESPOSTA DO ORGAO SUBORDINADOR'>
					<cfset strIDGestor = #qResposta.Pos_Area#>
					<cfset strNomeGestor = #qResposta.Pos_NomeArea#>         
				</cfcase>              
				<cfcase value=16>
					, Pos_Situacao = 'TS'
					, Pos_Area = '#qResposta.Pos_Area#' 
					, Pos_NomeArea = '#qResposta.Pos_NomeArea#' 
					, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
					<cfset Gestor = 'SGCIN'>
					<!--- <cfset Gestor = '#rsReop.Rep_Nome#'> --->
					<cfset situacao = 'TRATAMENTO ORGAO SUBORDINADOR'>
					<cfset strIDGestor = #qResposta.Pos_Area#>
					<cfset strNomeGestor = #qResposta.Pos_NomeArea#>
				</cfcase>		
				<cfcase value=19>
					, Pos_Area = '#qResposta.Pos_Area#' 
					, Pos_NomeArea = '#qResposta.Pos_NomeArea#' 
					, Pos_Situacao = 'TA'		  
					, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
					<cfset Gestor = 'SGCIN'>
					<cfset situacao = 'TRATAMENTO DA AREA'>
					<cfset strIDGestor = #qResposta.Pos_Area#>
					<cfset strNomeGestor = #qResposta.Pos_NomeArea#>
				</cfcase>		
	
			</cfswitch>	  
			, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
			, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
			, Pos_NomeResp='#CGI.REMOTE_USER#'
			, Pos_username='#CGI.REMOTE_USER#'
			, Pos_Sit_Resp_Antes = #form.scodresp#
			<cfset Encaminhamento = 'Opinião do Orgao Subordinador'>
			<cfset aux_obs = "">
			, Pos_Parecer=
			<cfset aux_obs = Trim(FORM.observacao)>
			<cfset aux_obs = Replace(aux_obs,'"','','All')>
			<cfset aux_obs = Replace(aux_obs,"'","","All")>
			<cfset aux_obs = Replace(aux_obs,'*','','All')>
			<cfset aux_obs = Replace(aux_obs,'>','','All')>

			<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & CHR(13) & CHR(13) & 'À ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
			'#pos_aux#'
			WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
		</cfquery>
 		<!--- Inserindo dados dados na tabela Andamento --->
		<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento)  & CHR(13) & CHR(13) & 'À ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
		<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
		<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
		<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>		
		<cfquery datasource="#dsn_inspecao#">
			insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Area, And_HrPosic, And_Parecer) 
			values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', convert(char, getdate(), 102), '#CGI.REMOTE_USER#', '#FORM.frmResp#', '#strIDGestor#', '#hhmmssdc#', '#and_obs#')
	 	</cfquery> 
 		<!----Condição para classificação do Item para ENCERRADO------------>
		
		<cfif (Form.frmResp eq 6 or Form.frmResp eq 7) and (rsItem.Und_TipoUnidade neq 12 and rsItem.Und_TipoUnidade neq 16)>

			<cfif ucase(Form.PosClassificacaoPonto) eq 'LEVE'>

				<cfquery name="rsObserv" datasource="#dsn_inspecao#">
					SELECT Pos_Parecer
					FROM ParecerUnidade 
					WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
				</cfquery>
<cfset pos_aux = trim(rsObserv.Pos_Parecer) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) CS/DIGOV/DCINT' & CHR(13) & CHR(13) & '   A partir da adoção de metodologia que classifica os itens avaliados como Não Conformes em GRAVE, MEDIANO ou LEVE, foi estabelecido pelo Departamento de Controle Interno (DCINT) que o acompanhamento da' & CHR(13) & 'regularização será realizado pelo Controle Interno somente para os itens de relevância GRAVE e MEDIANO.' & CHR(13) & '   Em decorrência disso, este item teve seu acompanhamento ENCERRADO após o registro da manifestação do gestor da unidade avaliada, uma vez que apresenta relevância LEVE.' & CHR(13) & CHR(13) & '   IMPORTANTE:' & CHR(13) & '   O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor da unidade avaliada de adotar ações imediatas para regularizar a Não Conformidade registrada.' & CHR(13) & '   Em caso de reincidência dessa Não Conformidade em avaliações de controles futuras, o item será considerado como MEDIANO e passará a ter acompanhamento até a sua regularização.' & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: SEC AVAL CONT INTERNO/SGCIN ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
				 <cfquery datasource="#dsn_inspecao#">
					UPDATE ParecerUnidade SET Pos_Situacao_Resp = 29
					, Pos_DtPosic = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
					, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))# 
					, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
					, Pos_NomeResp='#CGI.REMOTE_USER#'
					, Pos_username = '#CGI.REMOTE_USER#'
					, Pos_Situacao = 'EC'
					, Pos_Parecer = '#pos_aux#'
					, Pos_Sit_Resp_Antes = #form.scodresp#
					WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
				</cfquery> 
				<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) CS/DIGOV/DCINT' & CHR(13) & CHR(13) & '   A partir da adoção de metodologia que classifica os itens avaliados como Não Conformes em GRAVE, MEDIANO ou LEVE, foi estabelecido pelo Departamento de Controle Interno (DCINT) que o acompanhamento da' & CHR(13) & 'regularização será realizado pelo Controle Interno somente para os itens de relevância GRAVE e MEDIANO.' & CHR(13) & '   Em decorrência disso, este item teve seu acompanhamento ENCERRADO após o registro da manifestação do gestor da unidade avaliada, uma vez que apresenta relevância LEVE.' & CHR(13) & CHR(13) & '   IMPORTANTE:' & CHR(13) & '   O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor da unidade avaliada de adotar ações imediatas para regularizar a Não Conformidade registrada.' & CHR(13) & '   Em caso de reincidência dessa Não Conformidade em avaliações de controles futuras, o item será considerado como MEDIANO e passará a ter acompanhamento até a sua regularização.' & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: SEC AVAL CONT INTERNO/SGCIN ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>		
				<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
				<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
				<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>				
				<cfquery datasource="#dsn_inspecao#">
					insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Area, And_HrPosic, And_Parecer) 
					values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', #createodbcdate(createdate(year(now()),month(now()),day(now())))#, '#CGI.REMOTE_USER#', 29, '#strIDGestor#', '#hhmmssdc#', '#and_obs#')
				</cfquery> 
		    </cfif>
		</cfif> 
	
		<cflocation url="itens_unidades_controle_respostas_reop.cfm?ckTipo=#URL.ckTipo#">		

</cfif>
<!--- ============= --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>
<!--- ============= --->

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT UND_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Dir_Descricao, Dir_Codigo, Dir_Sigla
  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<script type="text/javascript">
  <cfinclude template="mm_menu.js">

//======================
function dtprazo(x){
//alert('aqui');
if (x == 16) {
   document.form1.cbData.value = document.form1.dttratam.value;
 } 
 
 if (x == 7) {
     document.form1.cbData.value = document.form1.dtrespos.value;
    } 
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

//Validação de campos vazios em formulário
function validaForm() {
if (document.form1.acao.value == 'Salvar'){
  

  var strmanifesto = document.form1.observacao.value;
  strmanifesto = strmanifesto.replace(/\s/g, '');
  if(strmanifesto == '')
	  {
	   alert('Caro Usuário, falta o seu Posicionamento no campo Manifestar-se!');
	   return false;
	  }

  if(strmanifesto.length < 100)
   {
   alert('Caro Usuário, Sua manisfestação deverá conter no mínimo 100(cem) caracteres');
   return false;
   }
   
   var sit = document.form1.frmResp.value;
   if(sit == 'N' || sit == '')
	  {
	   alert('Caro Usuário, Selecione a Situação do seu Manifestar-se!');
	   return false;
	  }
	  
   document.form1.cbData.disabled = false;
	var dtprevdig = document.form1.cbData.value;
	if (dtprevdig.length != 10){
		alert("Preencher campo: Data da Previsão da Solução ex. DD/MM/AAAA");
		return false;
	}

	 <!--- formato AAAAMMDD --->
	 var dt_hoje_yyyymmdd = document.form1.dthojeyyyymmdd.value;
     var pos_dtPrevSoluc_atual = document.form1.frmdtprev_atual.value;
	 var And_dtposic_fut = document.form1.frmDT30dias_Fut.value;
	<!---  var pos_dtposic_amd_atual = document.form1.pos_posic_ymd.value; --->

	 var vDia = dtprevdig.substr(0,2);
	 var vMes = dtprevdig.substr(3,2);
	 var vAno = dtprevdig.substr(6,10);
	 var dtprevdig_yyyymmdd = vAno + vMes + vDia

	 if (dt_hoje_yyyymmdd > dtprevdig_yyyymmdd)
	 {
	  alert('Data de Previsão da Solução é inferior a data de hoje!')
	  dtprazo(sit);
	  return false;
	 }
     if ((sit == 15 || sit == 16 || sit == 18 || sit == 19 || sit == 23) && dt_hoje_yyyymmdd == dtprevdig_yyyymmdd)
		 {
		  alert("Para Situação de Tratamento a Data de Previsão da Solução deve ser superior a data corrente(do dia)!")
		  //dtprazo(sit);
		  return false;
		 }
	 // so informar da dta de hoje()
	
	 if ((And_dtposic_fut < dt_hoje_yyyymmdd) && (pos_dtPrevSoluc_atual < dt_hoje_yyyymmdd) && (dtprevdig_yyyymmdd > dt_hoje_yyyymmdd) && (sit != 6 ) && (sit != 7))
	{
    alert('Sr. Usuário. O prazo de 30(trinta) dias está vencido, favor Responder apenas.')
	dtprazo(sit);
	return false;
	}
	
    // considerar possivel adendo de prazo ao campo Pos_DtPRevSoluc
	if (pos_dtPrevSoluc_atual > And_dtposic_fut && dtprevdig_yyyymmdd > pos_dtPrevSoluc_atual && (sit == 16))
	{
    alert('Sr. Usuário, você deve informar no campo "Data de Previsão da Solução" uma data igual ou inferior a ' + pos_dtPrevSoluc_atual.substr(6,2) + '/' + pos_dtPrevSoluc_atual.substr(4,2) + '/' + pos_dtPrevSoluc_atual.substr(0,4) + '.')
	dtprazo(sit);
	return false;
	} 
	/*
	 // Neste status considerar o prazo máximo contado a partir da andamento.and_DtPosic
	if ((dtprevdig_yyyymmdd > And_dtposic_fut) && (dt_hoje_yyyymmdd != dtprevdig_yyyymmdd) && (And_dtposic_fut > pos_dtPrevSoluc_atual))
	{
	// Aguardar Edimir
    alert('Sr. Usuário, você deve informar no campo "Data de Previsão da Solução" uma data igual ou inferior a ' + And_dtposic_fut.substr(6,2) + '/' + And_dtposic_fut.substr(4,2) + '/' + And_dtposic_fut.substr(0,4) + '.')
	dtprazo(sit);
	return false;
	} 
	*/
	 if ((sit == 15 || sit == 16 || sit == 18 || sit == 19 || sit == 23) && (dtprevdig_yyyymmdd < document.form1.dtdezddtrat.value))
	 {
	  var auxdtedit = document.form1.dtdezddtrat.value;
	  auxdtedit = auxdtedit.substring(6,8) + '/' + auxdtedit.substring(4,6) + '/' + auxdtedit.substring(0,4)
	  alert('Para Tratamento a Data de Previsão está menor que os 10(dez) dias úteis ou Data Previsão concedida para: ' + auxdtedit)
	  dtprazo(sit);
	 // exibe(sit);
	  return false;
	 }	
	  if (sit == 2) {var auxcam = '\n\nPENDENTE DE UNIDADE\n\n- Essa opção DEVOLVE o item à unidade para registro de resposta ou complementação'};
  	  if (sit == 20) {var auxcam = '\n\nPENDENTE DE AGF\n\n- Essa opção DEVOLVE o item à unidade para registro de resposta ou complementação'};
	  if (sit == 6) {var auxcam = '\n\nRESPOSTA DA ÁREA\n\n - Essa opção RESPONDE o item e o encaminha para Equipe de Controle Interno da Regional (SGCIN)'};
  	  if (sit == 7) {var auxcam = '\n\nRESPOSTA ÓRGÃO SUBORDINADOR\n\n - Essa opção RESPONDE o item e o encaminha para Equipe de Controle Interno da Regional (SGCIN)'};
	  if (sit == 16) {var auxcam = '\n\nTRATAMENTO ÓRGÃO SUBORDINADOR\n\n - Essa opção MANTÉM o item ao Órgão Subordinador para desenvolvimento de ação que necessita de maior prazo da regularização ou resposta.\n Nesse caso deve indicar o prazo necessário no campo Data de Previsão da Solução.\n Até essa data sua resposta deverá ser complementada'};
	  if (sit == 19) {var auxcam = '\n\nTRATAMENTO DA ÁREA\n\n - Essa opção MANTÉM o item à Área para desenvolvimento de ação que necessita de maior prazo da regularização ou resposta.\n Nesse caso deve indicar o prazo necessário no campo Data de Previsão da Solução.\n Até essa data sua resposta deverá ser complementada'};

	 if (confirm ('            Atenção! ' + auxcam))
	    {
	  if ((sit == 6 || sit == 7) && document.form1.PosClassificacaoPonto.value == 'LEVE' && document.form1.undtipounidade.value != 12 && document.form1.undtipounidade.value != 16) {
			  var auxcam = 'O item respondido possui classificação "LEVE". Em decorrência disso está sendo encerrado o acompanhamento pelo Controle Interno.\n\nATENÇÃO: O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor de providenciar a sua regularização.\n\nEm Avaliações de Controle futuras o item é passível de ser reavaliado. Caso seja constatada nova não conformidade, será considerada REINCIDÊNCIA, sendo acompanhada a sua regularização pelo Controle Interno.'
			  alert(auxcam);
		}		
	     document.form1.cbData.disabled = false;
		 return true;
		}
	else
	   {
	   if (sit != 16 || sit != 19) {document.form1.cbData.disabled = false;}
	   return false;
	   }
   }
//return false;
}
//Função que abre uma página em Popup
function popupPage() {
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_unidades_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}
</script>
</head>
  <cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_Area, Pos_NomeArea, Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Pos_DtPosic, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, Pos_DtPrev_Solucao FROM ParecerUnidade
  WHERE Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem# AND Pos_Unidade = '#unid#' AND Pos_Inspecao = '#ninsp#'
</cfquery>



<body onLoad="dtprazo(document.form1.frmResp.value)">
<cfset form.acao = ''>
<cfinclude template="cabecalho.cfm">
<table width="99%" height="60%" align="center">
<tr>
	  <td width="74%" valign="top">
<!--- Área de conteúdo   --->
    <form name="form1" method="post" onSubmit="return validaForm()" enctype="multipart/form-data" action="itens_unidades_controle_respostas1_reop2.cfm?ckTipo=1">
      <div align="right">
        <table width="70%" align="center">

	  <tr class="exibir">
            <td colspan="7" bgcolor="eeeeee"><div align="center"><cfoutput><span class="titulo1"><strong>PONTO DE controle interno</strong>
                    <input name="unid" type="hidden" id="unid" value="#URL.Unid#">
                    <input name="ninsp" type="hidden" id="ninsp" value="#URL.Ninsp#">
                    <input name="ngrup" type="hidden" id="ngrup" value="#URL.Ngrup#">
                    <input name="nitem" type="hidden" id="nitem" value="#URL.Nitem#">
                    <input name="reop" type="hidden" id="reop" value="#URL.reop#">
					<input name="Situacao" type="hidden" id="Situacao" value="#Situacao#">
                    <input type="hidden" name="acao" value="">
                    <input type="hidden" name="anexo" value="">
                    <input type="hidden" name="vCodigo" value="">
					<input type="hidden" name="sfrmPosArea" id="sfrmPosArea" value="#qResposta.Pos_Area#">
					<input type="hidden" name="sfrmPosNomeArea" id="sfrmPosNomeArea" value="#qResposta.Pos_NomeArea#">
					<input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="#rsItem.Itn_TipoUnidade#">
				     <input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>">   
            </span></cfoutput></div></td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
        </tr>
          
          <cfif ckTipo eq 3>  
              <tr class="exibir">
                <td colspan="9">&nbsp;</td>
              </tr>
              <tr><td colspan="9" align="center"> <button onClick="window.close()" class="botao">Fechar</button></td></tr>
          </cfif>  
          
		<tr class="exibir">
	    <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
	    </tr>
           <tr class="exibir">
	    <td width="11%" bgcolor="eeeeee">Unidade</td>
	    <td colspan="3" bgcolor="eeeeee"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
	    <td colspan="4" bgcolor="eeeeee">Respons&aacute;vel<cfoutput><strong>&nbsp;&nbsp;#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
	    </tr>
          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td width="6%" bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="7" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>- </cfif></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Nº Relatório</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="7" bgcolor="eeeeee"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Grupo</td>
            <td colspan="7" bgcolor="eeeeee"><cfoutput>#URL.Ngrup#</cfoutput><cfoutput><strong> - #rsItem.Grp_Descricao#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td colspan="7" bgcolor="eeeeee"><cfoutput>#URL.Nitem#</cfoutput><cfoutput><strong> - #rsItem.Itn_Descricao#</strong></cfoutput></td>
          </tr>
           <tr class="exibir">
			  <td bgcolor="eeeeee">Relevância</td>
			  <td colspan="7" bgcolor="eeeeee">
			  <table width="100%" border="0">
				<tr class="exibir">
				  <td width="70">Pontuação </td>
				  <td width="50"><strong class="exibir"><cfoutput>#qResposta.Pos_PontuacaoPonto#</cfoutput></strong></td>
				  <td width="169"><div align="right">Classificação do Ponto &nbsp;</div></td>
				  <td width="538"><strong class="exibir"><cfoutput>#qResposta.Pos_ClassificacaoPonto#</cfoutput></strong></td>
				</tr>
			  </table></td>
			  </tr>
			<tr bgcolor="eeeeee" class="exibir">
				<td>Classificação Unidade</td>
				<td colspan="7">
				<table width="100%" border="0">
					<tr>
						<td width="15%" class="exibir"><div align="center">Classificação Inicial:</div></td>
						<td width="35%" class="exibir"><strong><cfoutput>#rsItem.TNC_ClassifInicio#</cfoutput></strong></td>
						<td width="18%" class="exibir"><div align="center">Classificação Atual:</div></td>
						<td width="32%" class="exibir"><div align="left"><strong><cfoutput>#rsItem.TNC_ClassifAtual#</cfoutput></strong></div></td>
					</tr>
				</table>
				</td>
			</tr>	
<cfoutput>
   <cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
   <cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
   <cfset db_reincItem = #rsItem.RIP_ReincItem#>	 
	  <cfif len(trim(rsItem.RIP_ReincInspecao)) gt 0><!---Foi colocado zero pois o xml gerado pelo SGI est&atilde; colocando 0(zero) por padrao--->
		  
		 <tr class="red_titulo">
	  <td bgcolor="eeeeee">Reincid&ecirc;ncia</td>  
	      <input type="hidden" name="db_reincSN" id="db_reincSN" value="N">
		   <cfset reincSN = "S">
		   <input type="hidden" name="db_reincSN" id="db_reincSN" value="S">

	<td  colspan="7" bgcolor="eeeeee">
N&ordm; Relat&oacute;rio:
			<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" style="background:white" readonly="">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; Grupo:
			<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" style="background:white" readonly="">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; Item:
			<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" style="background:white" readonly=""></td>
	</tr>
	</cfif>
</cfoutput>
          <tr class="exibir">
            <td colspan="5" bgcolor="eeeeee"></td>
          </tr>
          <tr>
			<cfset melhoria = replace('#rsItem.RIP_Comentario#','; ' ,';','all')>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Situação Encontrada:</span></td>
            <td colspan="7" bgcolor="eeeeee"><span class="exibir">
              <textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#melhoria#</cfoutput></textarea>
            </span></td>
		  </tr>
		 <tr>
            <td align="center" valign="middle" bgcolor="eeeeee"><span class="titulos">Orientações:</span></td>
            <td colspan="7" bgcolor="eeeeee"><textarea name="H_recom" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea></td>
		  </tr>

           <!---  <input type="hidden" name="frmResp" value="7"> --->
            <!--- <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Hist&oacute;rico:</span> <span class="titulos">Manifesta&ccedil;&atilde;o/An&aacute;lise do Controle Interno</span><span class="titulos">:</span></td>
            <td colspan="7" bgcolor="eeeeee">
			<textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea>
			</td>
          </tr>
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee"><span class="exibir"><span class="titulos">Manifestar-se:</span></span></td>
            <td colspan="7" bgcolor="eeeeee"><textarea name="observacao" cols="200" rows="25" nome="Observação" vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#Session.E01.observacao#</cfoutput></textarea></td>
          </tr>
		  <tr>
		  <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><strong>ANEXOS:</strong></td>
	        <td colspan="7" align="center" valign="middle" bgcolor="eeeeee" class="exibir"><div align="left"><strong></strong></div></td>
          </tr>
  <cfif ckTipo neq 3>  
          <tr>
        <cfset resp = #qResposta.Pos_Situacao_Resp#>
        
        <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><strong>Arquivo:</strong></td>
        <td colspan="4" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
		<td colspan="3" bgcolor="eeeeee" class="exibir">
		<cfif (resp neq 21)>
		  <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar">
		<cfelse>
		  <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" disabled>
		</cfif>
		</td>
          </tr>

	      <tr>
	        <td colspan="8" align="center" valign="middle" class="exibir">&nbsp;</td>
          </tr>
    </cfif>
		  <!--- teste --->
<cfoutput>
    <cfset posdtprevsolucao = CreateDate(year(now()),month(now()),day(now()))>
	<cfset posdtprevsolucao = dateformat(qResposta.Pos_DtPrev_Solucao,"YYYYMMDD")>
	<cfset dtbase = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtrespos = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dttratam = CreateDate(year(now()),month(now()),day(now()))>
    <cfset dt30diasuteis = CreateDate(year(now()),month(now()),day(now()))>
	
	<cfobject component = "CFC/Dao" name = "dao">
	<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="VencidoPrazo_Andamento" NumeroDaInspecao="#ninsp#" 
		CodigoDaUnidade="#unid#" Grupo="#ngrup#" Item="#nitem#" MostraDump="no" RetornaQuantDias="yes" ApenasDiasUteis="yes" ListaDeStatusContabilizados="4,16">
			
	 <cfset auxQtdDias = VencidoPrazo_Andamento> 
		<cfif VencidoPrazo_Andamento lte 0>	
			<cfset auxQtdDias = 30>	
		<cfelseif VencidoPrazo_Andamento lte 30>
		    <cfset auxQtdDias = (30 - VencidoPrazo_Andamento)>	
		<cfelse>
		  <cfset auxQtdDias = 0>
		</cfif>

	    <!--- identificar a data útil da qtd de dias que ainda restam para completar 30 dias úteis --->
		<cfset nCont = 1>
		<cfloop condition="nCont lte #auxQtdDias#">
			<cfset dt30diasuteis = DateAdd( "d", 1, dt30diasuteis)>
			<cfset vDiaSem = DayOfWeek(dt30diasuteis)>
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
			<cfset dt30diasuteis = dateformat(dt30diasuteis,"YYYYMMDD")>
	<!--- 	</cfif> --->
			<cfif dt30diasuteis gte posdtprevsolucao>
				<cfset dtbase = dt30diasuteis>
			<cfelse>
				<cfset dtbase = posdtprevsolucao>	
				<cfset auxQtdDias = DateDiff("d", dt30diasuteis,posdtprevsolucao)>
			</cfif>
			<cfif dtbase lte dateformat(now(),"YYYYMMDD")>
			<!--- somente direito a responder --->
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 7)
				</cfquery>
			<cfelse>
				<!--- possui direitode tratamento e de resposta --->	
				<!--- Contar os possiveis dez dias uteis para tratamento --->	
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (7,16)
				</cfquery> 

				<!--- inicio 10 (dez) dias uteis para tratamento --->
				<!--- <cfset auxdtprev = CreateDate(year(now()),month(now()),day(now()))> --->
				<cfset nCont = 0>
				<!--- <cfloop condition="(nCont lte #auxQtdDias# and #dtbase# lte #dateformat(dttratam,'YYYYMMDD')#)"> --->
				<cfloop condition="(nCont lte 9 and #dtbase# gt #dateformat(dttratam,'YYYYMMDD')#)">
					<cfset nCont = nCont + 1>
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
			</cfloop>	
		</cfif>
</cfoutput>
	<input name="dttratam" type="hidden" id="dttratam" value="<cfoutput>#dateformat(dttratam,"DD/MM/YYYY")#</cfoutput>">
	<input name="dtrespos" type="hidden" id="dtrespos" value="<cfoutput>#dateformat(dtrespos,"DD/MM/YYYY")#</cfoutput>">
  <cfif ckTipo neq 3>
		  <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="titulos">Situa&ccedil;&atilde;o:</td>
			<td colspan="7" bgcolor="eeeeee" class="exibir"><div align="left">
			
			   <select name="frmResp" class="exibir" id="frmResp" onChange="dtprazo(this.value)">
	            <cfif rsPonto.recordcount gt 0>
					<option value="" selected>---</option>
                </cfif>
				<cfoutput query="rsPonto">
				  <option value="#STO_Codigo#" <cfif (isDefined("STO_Codigo") AND STO_Codigo  EQ #resp#)>selected</cfif>>#trim(STO_Descricao)#</option>
				</cfoutput>
               </select>
                </div>
				</td>			
			</tr>
</cfif>
	      <tr>
	        <td colspan="7" bgcolor="eeeeee" align="center" valign="middle" class="exibir">&nbsp;</td>
          </tr>
<cfset cla = 0>		  
<cfif ckTipo neq 3>
      <cfloop query= "qAnexos">
        <cfif FileExists(qAnexos.Ane_Caminho)>
		 <cfset cla = cla + 1>
		<cfif cla lt 10>
			<cfset cl = '0' & cla & 'º'>
		<cfelse>
			<cfset cl = cla & 'º'>
		</cfif>		
          <tr>
            <td colspan="6" bgcolor="eeeeee" class="form"><cfoutput>#cl# - #ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td width="4%" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />                <div align="left"><cfoutput>
            </cfoutput></div></td>
            <td width="5%" align="center" bgcolor="eeeeee"><cfoutput>

		        <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#" disabled>
           </cfoutput></td>

            </tr>
        </cfif>
      </cfloop>
     <tr>
	   <td colspan="8" align="center" valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
     </tr>
    
</cfif>
	<input name="frmnovoprazo" type="hidden" id="frmnovoprazo" value="N">
<cfif ckTipo neq 3>
		<tr>
		 <td colspan="8" bgcolor="eeeeee" class="exibir">Data de Previs&atilde;o da Solu&ccedil;&atilde;o:&nbsp;&nbsp;
	  <input name="cbData" id="cbData" type="text" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" value="<cfoutput>#dateformat(now(),"dd/mm/yyyy")#</cfoutput>" readonly="yes">
		</td>
	   </tr>
</cfif>
	<!--- <cfset resp = qResposta.Pos_Situacao_Resp> --->
	<cfset numdias = qResposta.diasOcor>
<cfif ckTipo neq 3> 
  <tr>
	 <td colspan="4" bgcolor="eeeeee" class="exibir"><div align="right"><cfoutput>
	             <input name="button" type="button" class="botao" onClick="window.open('itens_unidades_controle_respostas_reop.cfm?ckTipo=#URL.ckTipo#','_self')" value="Voltar">
             </cfoutput>
	         </div></td><cfset resp = qResposta.Pos_Situacao_Resp>
  
       <td colspan="4">
	     <div align="center">
	       <cfif (resp is 1 or resp is 6 or resp is 7 or resp is 17 or resp is 18 or resp is 21 or resp is 3 or resp is 24 or resp is 9 or resp is 25 or resp is 26 or resp is 27 or resp is 29)>
               <input name="Submit" type="submit" class="botao" value="Salvar" onClick="document.form1.acao.value='Salvar'" disabled>
	           <cfelse>
               <input name="Submit" type="submit" class="botao" value="Salvar" onClick="document.form1.acao.value='Salvar'">
	         </cfif>
	       </div></td>
  
          </tr>  
   <cfelse>
        <tr><td colspan="9" align="center"> <button onClick="window.close()" class="botao">Fechar</button></td></tr>
   </cfif>
        </table>
		<input type="hidden" name="MM_UpdateRecord" value="form1">
		<input type="hidden" name="salvar_anexar" value="">

	<input type="hidden" name="PosClassificacaoPonto" id="PosClassificacaoPonto" value="<cfoutput>#trim(qResposta.Pos_ClassificacaoPonto)#</cfoutput>"> 
	<input type="hidden" name="undtipounidade" id="undtipounidade" value="<cfoutput>#trim(rsItem.Und_TipoUnidade)#</cfoutput>">
	<input type="hidden" name="scodresp" id="scodresp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">

	</form>
<!--- Fim Área de conteúdo --->
</td>
  </tr>
</table>
</body>
 <script>
	<cfoutput>
		<!---Retorna true se a data de início da inspeção for maior ou igual a 04/03/2021, data em que o editor de texto foi implantado. Isso evitará que os textos anteriores sejam desformatados--->
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

		CKEDITOR.replace('H_recom', {
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

<cfcatch>
  <cfdump var="#cfcatch#">
  	<cfif isDefined("Session.E01")>
	   <cfset StructClear(Session.E01)>
	</cfif>
</cfcatch>
</cftry>

<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>
