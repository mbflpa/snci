<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
 	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>    
</cfif>       
<cfset houveProcSN = 'N'>
<cfif not isDefined("Form.Submit")>
	<cfset numncisei = "">
<cfelse>
	<cfset numncisei = "">
	<cfoutput>	
		<cfif isDefined("Form.frmnumseinci") And (#Form.frmnumseinci# neq "")>
		  <cfset numncisei = #Form.frmnumseinci#>
		</cfif>
	</cfoutput>
</cfif>

<cfset anoinsp = right(ninsp,4)>
	
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
	  
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email
</cfquery>

<cfquery name="rsSEINCI" datasource="#dsn_inspecao#">
 SELECT Pos_NCISEI FROM ParecerUnidade WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NCISEI Is Not Null ORDER BY Pos_NCISEI DESC
</cfquery>

<cfif grpacesso eq 'GESTORES' or grpacesso eq 'DESENVOLVEDORES' or grpacesso eq 'GESTORMASTER'>
<!---  <cftry>  --->
  <cfif isDefined("Form.acao") And (Form.acao is 'alter_reincidencia' Or Form.acao is 'alter_valores' Or Form.acao is 'Anexar' Or Form.acao is 'Excluir_Anexo')>
  <cfif isDefined("Form.abertura")><cfset Session.E01.abertura = Form.abertura><cfelse><cfset Session.E01.abertura = 'Não'></cfif>
  <cfif isDefined("Form.processo")><cfset Session.E01.processo = Form.proc_se & Form.proc_num & Form.proc_ano><cfelse><cfset Session.E01.processo = ''></cfif>
  <cfif isDefined("Form.causaprovavel")><cfset Session.E01.causaprovavel = Form.causaprovavel><cfelse><cfset Session.E01.causaprovavel = ''></cfif>
  <cfif isDefined("Form.cbarea")><cfset Session.E01.cbarea = Form.cbarea><cfelse><cfset Session.E01.cbarea = ''></cfif>
  <cfif isDefined("Form.cbdata")><cfset Session.E01.cbdata = Form.cbdata><cfelse><cfset Session.E01.cbdata = ''></cfif>
  <cfif isDefined("Form.cbunid")><cfset Session.E01.cbunid = Form.cbunid><cfelse><cfset Session.E01.cbunid = ''></cfif>
  <cfif isDefined("Form.frmresp")><cfset Session.E01.frmresp = Form.frmresp><cfelse><cfset Session.E01.frmresp = ''></cfif>
  <cfif isDefined("Form.cborgao")><cfset Session.E01.cborgao = Form.cborgao><cfelse><cfset Session.E01.cborgao = ''></cfif>
  <cfif isDefined("Form.cktipo")><cfset Session.E01.cktipo = Form.cktipo><cfelse><cfset Session.E01.cktipo = ''></cfif>
  <cfif isDefined("Form.dtfinal")><cfset Session.E01.dtfinal = Form.dtfinal><cfelse><cfset Session.E01.dtfinal = ''></cfif>
  <cfif isDefined("Form.dtinicio")><cfset Session.E01.dtinicio = Form.dtinicio><cfelse><cfset Session.E01.dtinicio = ''></cfif>
  <cfif isDefined("Form.hreop")><cfset Session.E01.hreop = Form.hreop><cfelse><cfset Session.E01.hreop = ''></cfif>
  <cfif isDefined("Form.hunidade")><cfset Session.E01.hunidade = Form.hunidade><cfelse><cfset Session.E01.hunidade = ''></cfif>
  <cfif isDefined("Form.h_obs")><cfset Session.E01.h_obs = Form.h_obs><cfelse><cfset Session.E01.h_obs = ''></cfif>
  <cfif isDefined("Form.melhoria")><cfset Session.E01.melhoria = Form.melhoria><cfelse><cfset Session.E01.melhoria = ''></cfif>
  <cfif isDefined("Form.ngrup")><cfset Session.E01.ngrup = Form.ngrup><cfelse><cfset Session.E01.ngrup = ''></cfif>
  <cfif isDefined("Form.ninsp")><cfset Session.E01.ninsp = Form.ninsp><cfelse><cfset Session.E01.ninsp = ''></cfif>
  <cfif isDefined("Form.nitem")><cfset Session.E01.nitem = Form.nitem><cfelse><cfset Session.E01.nitem = ''></cfif>
  <cfif isDefined("Form.frmmotivo")><cfset Session.E01.frmmotivo = Form.frmmotivo><cfelse><cfset Session.E01.frmmotivo = ''></cfif>
  <cfif isDefined("Form.cbdata")><cfset Session.E01.cbdata = Form.cbdata><cfelse><cfset Session.E01.cbdata = ''></cfif>
  <cfif isDefined("Form.observacao")><cfset Session.E01.observacao = Form.observacao><cfelse><cfset Session.E01.observacao = ''></cfif>
  <cfif isDefined("Form.recomendacao")><cfset Session.E01.recomendacao = Form.recomendacao><cfelse><cfset Session.E01.recomendacao = ''></cfif>
  <cfif isDefined("Form.reop")><cfset Session.E01.reop = Form.reop><cfelse><cfset Session.E01.reop = ''></cfif>
  <cfif isDefined("Form.unid")><cfset Session.E01.unid = Form.unid><cfelse><cfset Session.E01.unid = ''></cfif>
  <cfif isDefined("Form.modalidade")><cfset Session.E01.modalidade = Form.modalidade><cfelse><cfset Session.E01.modalidade = ''></cfif>
  <cfif isDefined("Form.valor")><cfset Session.E01.valor = Form.valor><cfelse><cfset Session.E01.valor = ''></cfif>
  <cfif isDefined("Form.SE")><cfset Session.E01.SE = Form.SE><cfelse><cfset Session.E01.SE = ''></cfif>
  <cfif isDefined("Form.VLRecuperado")><cfset Session.E01.VLRecuperado = Form.VLRecuperado><cfelse><cfset Session.E01.VLRecuperado = ''></cfif>
  <cfif isDefined("Form.cbareaCS")><cfset Session.E01.cbareaCS = Form.cbareaCS><cfelse><cfset Session.E01.cbareaCS = ''></cfif>
  <cfif isDefined("Form.dbfrmnumsei")><cfset Session.E01.dbfrmnumsei = Form.dbfrmnumsei><cfelse><cfset Session.E01.dbfrmnumsei = ''></cfif>
	
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
<!--- Alterar Valores --->
 <cfif Form.acao is 'alter_valores'>
	
	<!--- Atualizar valor --->
	<cfset auxfrmemrisco = "0.00">
	<cfset auxfrmsobra = "0.00">
	<cfset auxfrmfalta = "0.00">
	
	<cfif UCASE(trim(form.caracvlr)) eq 'QUANTIFICADO'>
		<cfset auxfrmfalta = Replace(FORM.frmfalta,'.','','All')>
		<cfset auxfrmfalta = Replace(auxfrmfalta,',','.','All')>
		<cfset auxfrmemrisco = Replace(FORM.frmemrisco,'.','','All')>
		<cfset auxfrmemrisco = Replace(auxfrmemrisco,',','.','All')>
		<cfset auxfrmsobra = Replace(FORM.frmsobra,'.','','All')>
		<cfset auxfrmsobra = Replace(auxfrmsobra,',','.','All')>
    <cfelse>
		<cfset FORM.frmfalta = '0.00'>
		<cfset FORM.frmemrisco = '0.00'>
		<cfset FORM.frmsobra = '0.00'>    
	</cfif>
	<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao SET 			  
			, RIP_Falta=#auxfrmfalta#
			, RIP_Sobra=#auxfrmsobra#
			, RIP_EmRisco=#auxfrmemrisco#
		    , RIP_UserName = '#CGI.REMOTE_USER#'
		    , RIP_DtUltAtu = CONVERT(char, GETDATE(), 120)
			<cfif grpacesso eq 'GESTORES'>
			, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
			, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
			</cfif>			
		    WHERE RIP_Unidade='#unid#' AND RIP_NumInspecao='#ninsp#' AND RIP_NumGrupo = #ngrup# AND RIP_NumItem = #nitem#
	</cfquery>

	<cfquery name="rsSitAtual" datasource="#dsn_inspecao#">
	  SELECT Pos_Situacao_Resp, Pos_DtPosic
	  FROM ParecerUnidade
	  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
	</cfquery>
	<cfset prazo = CreateDate(year(rsSitAtual.Pos_DtPosic),month(rsSitAtual.Pos_DtPosic),day(rsSitAtual.Pos_DtPosic))>
   <cfif rsSitAtual.Pos_Situacao_Resp neq 0 and rsSitAtual.Pos_Situacao_Resp neq 11>
	<cfset aux_obs = Trim(FORM.observacao)>
	<cfset aux_obs = Replace(aux_obs,'"','','All')>
	<cfset aux_obs = Replace(aux_obs,"'","","All")>
	<cfset aux_obs = Replace(aux_obs,'*','','All')>
    <cfset aux_obs = Replace(aux_obs,'>','','All')>
	<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Alteração de Valores' & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & ' Antes(R$) - Falta: ' & #form.sfrmfalta# & '  Sobra: ' & #form.sfrmsobra# & '  Em Risco: ' & #form.sfrmemrisco# & CHR(13) & 'Atual (R$) - Falta: ' & #form.frmfalta# & '  Sobra: ' & #form.frmsobra# & '  Em Risco: ' & #form.frmemrisco# & CHR(13) & CHR(13) &  'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
 </cfif>		
</cfif>

<!--- Anexar arquivo --->

<cfif Form.acao is 'Anexar'>

	<cftry>

		<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		<!--- O arquivo anexo recebe nome indicando Numero da Inspeção, NÃºmero da unidade, NÃºmero do grupo e NÃºmero do item ao qual estão vinculado --->

		<cfset destino = cffile.serverdirectory & '\' & Form.ninsp & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '_' & Form.ngrup & '_' & Form.nitem & '.pdf'>


		<cfif FileExists(origem)>

			<cffile action="rename" source="#origem#" destination="#destino#">

			<cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
				SELECT Ane_Codigo FROM Anexos
				WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
			</cfquery>


			<cfif qVerificaAnexo.recordCount eq 0>

				<cfquery datasource="#dsn_inspecao#" name="qVerifica">
				 INSERT Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho)
				 VALUES ('#Form.ninsp#','#Form.unid#',#Form.ngrup#,#Form.nitem#,'#destino#')
				</cfquery>

		    </cfif>
         </cfif>

	   <cfcatch type="any">
			<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação, o campo Arquivo estão vazio, Selecione um arquivo no formato PDF'>
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
	 <cfif Form.acao is 'Excluir_Anexo'>
	  <!--- Verificar se anexo existe --->

		 <cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos
			WHERE Ane_Codigo = '#form.vCodigo#'
		 </cfquery>

		 <cfif qAnexos.recordCount Neq 0>

			<!--- Exluindo arquivo do diretorio de Anexos --->
			<cfif FileExists(qAnexos.Ane_Caminho)>
				<cffile action="delete" file="#qAnexos.Ane_Caminho#">
			</cfif>

			<!--- Excluindo anexo do banco de dados --->

			<cfquery datasource="#dsn_inspecao#">
			  DELETE FROM Anexos
			  WHERE  Ane_Codigo = '#form.vCodigo#'
			</cfquery>

		 </cfif>
	</cfif>
</cfif>

 <cfquery name="qUnidade" datasource="#dsn_inspecao#">
		SELECT Und_descricao FROM Unidades
		WHERE UND_codigo='#unid#'
 </cfquery>

 <cfif IsDefined("FORM.submit") AND IsDefined("FORM.acao") And Form.acao is "Salvar">
	<cfquery datasource="#dsn_inspecao#" name="qVerificaTipo">
		Select Und_TipoUnidade, Und_CodReop from Unidades WHERE Und_Codigo = #Unid#
	 </cfquery>
	 <cfquery datasource="#dsn_inspecao#" name="qVerificaArea">
		Select Rep_CodArea from Reops WHERE Rep_Codigo=#qVerificaTipo.Und_CodReop#
	</cfquery>
	  <cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao SET
	  <cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
		RIP_Comentario=
		  <cfset aux_mel = CHR(13) & Form.Melhoria>
		 
		  '#aux_mel#'
	   </cfif>
	   <cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
		 , RIP_Recomendacoes=
		  <cfset aux_recom = CHR(13) & FORM.recomendacao>
		  '#aux_recom#'
		</cfif>
		  , RIP_UserName = '#CGI.REMOTE_USER#'
		  , RIP_DtUltAtu = CONVERT(char, GETDATE(), 120)
          <cfif grpacesso eq 'GESTORES'>
            , RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
            , RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
          </cfif>		  
		  WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
	  </cfquery>
	  <cfif IsDefined("FORM.frmcbarea") AND FORM.frmcbarea EQ "">
			 <cfquery datasource="#dsn_inspecao#">
			   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 11
			   , Pos_Situacao = 'EL'
			   , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
			   , Pos_DtPrev_Solucao = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
			   , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
			   , pos_username = '#CGI.REMOTE_USER#'
			   , Pos_Sit_Resp_Antes = 0
			     <!--- Nº SEI da NCI --->
			   <cfset aux_sei_nci = "">
			   , Pos_NCISEI =
				<cfif IsDefined("FORM.nci") AND FORM.nci EQ "Sim">
				   <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instrucoes SQL --->
					  <cfset aux_sei_nci = Trim(FORM.frmnumseinci)>
					  <cfset aux_sei_nci = Replace(aux_sei_nci,'.','',"All")>
					  <cfset aux_sei_nci = Replace(aux_sei_nci,'/','','All')>
					  <cfset aux_sei_nci = Replace(aux_sei_nci,'-','','All')>
				    '#aux_sei_nci#'
				<cfelse>
				    '#aux_sei_nci#'
				</cfif> 
			   WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
			 </cfquery>
	</cfif>
	<cfif isDefined("Session.E01")>
	  <cfset StructClear(Session.E01)>
	</cfif>
</cfif>

<!--- <cfdump var="#url#"> <cfabort> --->

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
    SELECT INP_Responsavel
    FROM Inspecao
    WHERE (INP_NumInspecao = '#ninsp#')
</cfquery>
<!--- Visualizacao de anexos --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo
</cfquery>

<cfquery name="qCausa" datasource="#dsn_inspecao#">
  SELECT Cpr_Codigo, Cpr_Descricao FROM CausaProvavel WHERE Cpr_Codigo not in (select PCP_CodCausaProvavel from ParecerCausaProvavel
  WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem#)
  ORDER BY Cpr_Descricao
</cfquery>
<cfquery name="qSeiApur" datasource="#dsn_inspecao#">
	SELECT SEI_NumSEI FROM Inspecao_SEI 
	WHERE SEI_Unidade='#unid#' AND SEI_Inspecao='#ninsp#' AND SEI_Grupo=#ngrup# AND SEI_Item=#nitem#
	ORDER BY SEI_NumSEI
</cfquery>
<cfquery name="qProcSei" datasource="#dsn_inspecao#">
	SELECT PDC_ProcSEI, PDC_Processo, PDC_Modalidade FROM Inspecao_ProcDisciplinar
	WHERE PDC_Unidade='#unid#' AND PDC_Inspecao='#ninsp#' AND PDC_Grupo=#ngrup# AND PDC_Item=#nitem#
	ORDER BY PDC_ProcSEI
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">

	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.dtFinal" default="#form.dtfinal#">
	<cfparam name="URL.DtInic" default="#form.dtinicio#">
	<cfparam name="URL.dtFim" default="#form.dtfinal#">
	<cfparam name="URL.Reop" default="#Form.Reop#">
	<cfparam name="URL.ckTipo" default="#form.ckTipo#">
	<cfparam name="URL.SE" default="#Form.SE#">
	<cfparam name="URL.selstatus" default="#form.selstatus#">
	<cfparam name="URL.statusse" default="#Form.statusse#">
	<cfparam name="URL.sfrmPosArea" default="#Form.sfrmPosArea#">
	<cfparam name="URL.sfrmPosNomeArea" default="#form.sfrmPosNomeArea#">
	<cfparam name="URL.sfrmTipoUnidade" default="#Form.sfrmTipoUnidade#">
	<cfparam name="URL.VLRDEC" default="#Form.sVLRDEC#">
	<cfparam name="URL.situacao" default="#Form.situacao#">
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
	<cfparam name="URL.SE" default="">
	<cfparam name="URL.selstatus" default="">
	<cfparam name="URL.statusse" default="">
	<cfparam name="URL.sfrmPosArea" default="">
    <cfparam name="URL.sfrmPosNomeArea" default="">
    <cfparam name="URL.sfrmTipoUnidade" default="">

</cfif>


 <cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
  FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<!--- Nova consulta para verificar respostas das unidades --->

 <cfquery name="qResposta" datasource="#dsn_inspecao#">
 SELECT Pos_Area, Pos_NomeArea, Pos_Situacao_Resp, Pos_Parecer, RIP_Recomendacoes, RIP_Comentario, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_Valor, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem, Dir_Descricao, Dir_Codigo, Pos_Processo, Pos_Tipo_Processo, Pos_Abertura, Itn_Descricao, Itn_TipoUnidade, Pos_VLRecuperado, Pos_DtPrev_Solucao, Pos_DtPosic, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, Pos_SEI, Pos_Situacao_Resp, INP_DtInicInspecao, INP_TNCClassificacao, Pos_NCISEI, Grp_Descricao, INP_Modalidade, Und_TipoUnidade, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, TNC_ClassifInicio, TNC_ClassifAtual
 FROM  Inspecao 
 INNER JOIN (Diretoria 
 INNER JOIN ((Resultado_Inspecao 
 INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
 INNER JOIN (Itens_Verificacao 
 INNER JOIN Grupos_Verificacao ON Itn_Ano = Grp_Ano and Itn_NumGrupo = Grp_Codigo) ON (right(Pos_Inspecao, 4) = Grp_Ano) and (Pos_NumGrupo = Itn_NumGrupo) AND (Pos_NumItem = Itn_NumItem)) ON Dir_Codigo = RIP_CodDiretoria) ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)
 INNER JOIN Unidades ON Und_Codigo = INP_Unidade
 left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
 WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

		  
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
 SELECT IPT_MatricInspetor, Fun_Nome
 FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor =
 Fun_Matric WHERE IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

	  
<cfquery name="qAreaDaUnidade" datasource="#dsn_inspecao#">  
      SELECT Areas.Ars_Codigo, Areas.Ars_Sigla, Areas.Ars_Descricao
      FROM Unidades INNER JOIN Reops ON Unidades.Und_CodReop = Reops.Rep_Codigo INNER JOIN Areas ON Reops.Rep_CodArea = Areas.Ars_Codigo
      WHERE Areas.Ars_Status = 'A' AND Unidades.Und_Codigo=#URL.unid#
</cfquery>		
<cfset areaDaUnidade = 	'#qAreaDaUnidade.Ars_Descricao#'/>	  

<cfquery name="qArea" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '#rsMod.Dir_Codigo#')
 ORDER BY Ars_Sigla
</cfquery>	  
		  

<cfquery name="qAreaCS" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '01')
 ORDER BY Ars_Sigla
</cfquery>


<cfquery name="qCausaProcesso" datasource="#dsn_inspecao#">
 SELECT Cpr_Codigo, Cpr_Descricao, PCP_Unidade, PCP_CodCausaProvavel  FROM ParecerCausaProvavel INNER JOIN CausaProvavel ON PCP_CodCausaProvavel =
 Cpr_Codigo WHERE PCP_Unidade='#URL.unid#' AND PCP_Inspecao='#URL.ninsp#' AND PCP_NumGrupo=#URL.ngrup# AND PCP_NumItem=#URL.nitem#
</cfquery>
<cfset PrzVencSN = 'no'>
<cfquery name="rsTPUnid" datasource="#dsn_inspecao#">
     SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#URL.unid#'
</cfquery>

<cfif rsTPUnid.Und_TipoUnidade is 12 || rsTPUnid.Und_TipoUnidade is 16>

	<cfquery name="rs14AND" datasource="#dsn_inspecao#">
		SELECT And_DtPosic FROM Andamento
		WHERE And_Unidade='#URL.unid#' AND And_NumInspecao='#URL.ninsp#' AND And_NumGrupo=#URL.ngrup# AND And_NumItem=#URL.nitem# 
		AND And_Situacao_Resp = 14
	</cfquery>
	<cfset dtnovoprazo = CreateDate(year(rs14AND.And_DtPosic),month(rs14AND.And_DtPosic),day(rs14AND.And_DtPosic))> 
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

	
		  <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto 
		  WHERE STO_Status='A'                                                                                                   
		  <cfif dateformat(#dtnovoprazo#,"YYYYMMDD") lt dateformat(now(),"YYYYMMDD")>
			  <cfif Trim(rsUsuarioLogado.GrupoAcesso) eq 'GESTORMASTER'>
			   AND STO_Codigo in (9,12,13,21,25,26)
			  <cfelse>
			   AND STO_Codigo in (9,12,13,25,26)	  
			  </cfif>
			
		  <cfelse>
			  <cfif Trim(rsUsuarioLogado.GrupoAcesso) eq 'GESTORMASTER'>
			   AND STO_Codigo in (9,12,13,20,21,25,26) 
			  <cfelse>
               AND STO_Codigo in (9,12,13,20,25,26) 				  
			  </cfif>
	      </cfif>
		  order by STO_Descricao
		</cfquery>

		<cfif situacao eq 28>
		   <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		     SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (12,28) order by STO_Descricao
		   </cfquery>
		</cfif>
<cfelse>
	
	<cfquery name="rsPonto" datasource="#dsn_inspecao#">
		<cfif qResposta.Pos_Situacao_Resp neq 9>
	       SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo not in (1,6,7,11,14,17,18,20,22,25,26,27) 
	    <cfelse>
           SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo not in (1,6,7,9,11,14,17,18,20,22,25,26,27) 			
	    </cfif>
	    <cfif Trim(rsUsuarioLogado.GrupoAcesso) neq 'GESTORMASTER'>
				 AND STO_Codigo <> 21 
		 </cfif>
	 order by STO_Descricao	
	</cfquery>
	<cfif situacao eq 28>
		   <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		     SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (12,28) order by STO_Descricao
		   </cfquery>
		</cfif>
</cfif>


<cfset vRecom = 0>
<cfset vRecomendacao = Trim(qResposta.RIP_Recomendacoes)>

<cfif vRecomendacao is ''>
   <cfset vRecom = 1>
</cfif>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>


<script type="text/javascript">
<cfinclude template="mm_menu.js">


//reinicia o ckeditor para inibir o erro de retornar conteúdo vazio no textarea
function CKupdate(){
    for ( instance in CKEDITOR.instances )
    CKEDITOR.instances[instance].updateElement();
}
//*********************************************************************
function dtprazo(k){
 document.form1.cbdata.disabled = true;
 document.form1.cbdata.value = document.form1.frmdtprevsol.value;
 //alert('dtprazo: ' + k);
 if (k == 3 || k == 10 || k == 12 || k == 13 || k == 25 || k == 26)
 {
   document.form1.cbdata.value = document.form1.dtdehoje.value;
   document.form1.cbdata.disabled = true;
 }
 if (k == 2 || k == 4 || k == 5 || k == 8  || k == 20 )
 {
   document.form1.cbdata.value = document.form1.dtdehoje.value;
   document.form1.cbdata.disabled = true;
 }
 if (k == 15 || k == 16 || k == 18 || k == 19 || k == 21 || k == 23)
 {
  //alert('dtprazo: ' + k);
   document.form1.cbdata.disabled = false;
 }
}
// travar o combobox em um determinado valor
function travarcombo(a,b) {
//alert('travar combo Valor de A: ' + a + 'Valor de B: ' + b);
   var opt_sn = 'N';
   var comboitem = document.getElementById(b);
   comboitem.disabled=false
   for (i = 1; i < comboitem.length; i++) {
       // comparando o valor do label
//       if (comboitem.options[i].text.substring(comboitem.options[i].text.indexOf("/") + 1,comboitem.options[i].text.length) ==  a)
      if (comboitem.options[i].text ==  a)
	   {
       //     alert(i);
		  opt_sn = 'S'
          comboitem.selectedIndex = i;
          comboitem.disabled=true;
          i = comboitem.length;
         }
    }
	if (opt_sn == "N")
	{
       //    alert(i);
       comboitem.selectedIndex = 0;
       comboitem.disabled=false;
    }
}
//=======================
// travar o combobox(cbarea) em um determinado valor
function buscaopt(a) {
//alert(a);
   var opt_sn = 'N';
   var comboitem = document.getElementById("cbarea");
   for (i = 1; i < comboitem.length; i++) {
   
   // if (comboitem.options[i].text ==  a) {alert(comboitem.options[i].text);}
       // comparando o valor do label
     //  if (comboitem.options[i].text.substring(comboitem.options[i].text.indexOf("/") + 1,comboitem.options[i].text.length) ==  a)
	 if (comboitem.options[i].text ==  a)
	   {

		  opt_sn = 'S'
          comboitem.selectedIndex = i;
          comboitem.disabled=true;
          i = comboitem.length;
         }
    }
	if (opt_sn == "N")
	{
       //    alert(i);
       comboitem.selectedIndex = 0;
       comboitem.disabled=false;
    }
}
//=================
function reincidencia(a){
//alert(a);
 if (a == 'N')
  {
   document.form1.frmreincInsp.value = '';
   document.form1.frmreincGrup.value = 0;
   document.form1.frmreincItem.value = 0;
   document.form1.frmreincInsp.disabled = true;
   document.form1.frmreincGrup.disabled = true;
   document.form1.frmreincItem.disabled = true;
   document.form1.alter_reincidencia.disabled = true;
  }
  else
  {
   document.form1.frmreincInsp.disabled = false;
   document.form1.frmreincGrup.disabled = false;
   document.form1.frmreincItem.disabled = false;
   document.form1.alter_reincidencia.disabled = false;
   document.form1.frmreincInsp.value = document.form1.dbreincInsp.value;
   document.form1.frmreincGrup.value = document.form1.dbreincGrup.value;
   document.form1.frmreincItem.value = document.form1.dbreincItem.value;
   
  }
 }
 
//===================
function controleNCI(){
//alert(document.form1.nci.value);
//alert(document.form1.frmnumseinci.value);
 document.form1.pontocentlzSN.value = 'N'
var x=document.form1.nci.value;
 var k=document.form1.frmnumseinci.value;
	if (x == 'Sim' && k.length == 20)
    {
	document.form1.nseincirel.value = k;
	document.form1.pontocentlzSN.value = 'S'
	document.form1.frmcbarea.selectedIndex = 0;
	document.form1.frmcbarea.disabled=true;
	}
}
//===================
function mensagemNCI(){
  var x=document.form1.nci.value;
	if (x == 'Sim')
    {
	   alert('Gestor(a), será necessário registrar o N° SEI e anexar a NCI.');
	   document.form1.frmnumseinci.focus();
	   document.form1.frmcbarea.selectedIndex = 0;
	   document.form1.frmcbarea.disabled=true;
	}else{
		document.form1.frmcbarea.disabled=false;	
	}
}

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
//  var x = document.form1.nci.value;
 // alert(x);
  if (x != "Sim"){
		document.form1.frmcbarea.disabled=false;
  }
  else
    {
      if (document.form1.pontocentlzSN.value == "S")
        {
         document.form1.frmcbarea.disabled=true;
        }
    }
}
//============================
var ind
function exibirArea(ind){
//alert('exibirArea: ' + ind);
  
  document.form1.observacao.disabled=false;
  document.form1.cbarea.disabled=false;
  if (ind==5 || ind==10 || ind==19 || ind==21|| ind==25 || ind==26){
    window.dArea.style.visibility = 'visible';
    if(ind==21) {buscaopt('SEC AVAL CONT INTERNO/SGCIN')}
	<cfoutput>
  //  if(ind==25 || ind==26)
		if(ind==25)
	    {
		    document.form1.observacao.value = ''
            <cfset sinformes = "Encaminhamos achado de Controle interno, constatado na agência terceirizada referenciada neste Relatório, para conhecimento, análise, acompanhamento da regularização (se for o caso) e aplicação das providências de competência desse órgão, conforme previsto no instrumento contratual regente. Após a ciência,  o controle da baixa desse  item passará a ser de responsabilidade dessa área e a efetividade e regularidade das ações adotadas poderão serem avaliadas em futuros trabalhos das áreas de Controle Interno da Empresa (2° e 3° linha) ou de Órgãos Externos.">
            var area = "#trim(areaDaUnidade)#"; 
            var parecer =  "#sinformes#"; 
            travarcombo(area,'cbarea');
            document.form1.observacao.value = parecer;
            document.form1.observacao.disabled=true;
		}
		if(ind==26)
	    {
		    document.form1.observacao.value = ''
            var area = "#trim(areaDaUnidade)#"; 
            travarcombo(area,'cbarea');
            document.form1.observacao.disabled=false;
		}		
    </cfoutput>
  } else {
    window.dArea.style.visibility = 'hidden';
	document.form1.cbarea.value = '';
	//document.form1.observacao.value = '';
	
  }
}
//====================
var idx
function exibirAreaCS(idx){
//alert(idx);
//alert(document.form1.houveProcSN.value);
window.dAreaCS.style.visibility = 'visible';
  if (idx==24 || document.form1.houveProcSN.value == 'S'){
    if(document.form1.houveProcSN.value == 'S')

    {
	//alert(document.form1.houveProcSN.value);
	  if(document.form1.mensSN.value == 'S'){
		  alert('                            Atenção! \n\nGestor(a), favor informar a Situação: APURAÇÃO deste ponto.');
		  document.form1.mensSN.value = 'N';
		  }
  
	  travarcombo('APURACAO','frmResp'); travarcombo('CORREGEDORIA/PRESI','cbareaCS')
	} else { exibe('N'); travarcombo('kkk','frmResp')}
  } else if (idx == 9){}
    else {
    window.dAreaCS.style.visibility = 'hidden';
	document.form1.cbareaCS.value = '';
  }
}
//===========================
function exibirValor(vlr){
//alert('exibirValor: ' + vlr);
  //if ((vlr==3 || vlr==9) && document.form1.vlrdeclarado.value == 'S'){
  if (vlr==3 || vlr==9){
    window.dValor.style.visibility = 'visible';
   // alert('Sr. Gestor, informe o Valor Regularizado, Exemplos: 1185,40; 0,07');
	document.form1.VLRecuperado.value='0,00'
	if (document.form1.vlrdeclarado.value == 'N'){document.form1.VLRecuperado.value='0,0'}
  } else {
    document.form1.VLRecuperado.value='0,00'
    window.dValor.style.visibility = 'hidden';
  }
}
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function validarform(){
//var tamresp = document.form1.frmResp.value;
//alert('acao: ' + document.form1.acao.value + ' resposta:' + document.form1.frmResp.value + ' tamanho: ' + tamresp.length);
  
  if (document.form1.acao.value=='Anexar'){
	var x=document.form1.nci.value;
    var k=document.form1.frmnumseinci.value;
	if (x == 'Sim' && (k.length != 20 || k =='')){
		alert("Nº SEI da Apuração Inválido!:  (ex. 99999.999999/9999-99)");
		document.form1.frmnumseinci.focus();
		return false;
	}else{
		return true;
	}
	 
  }
 //=============================================================
	if (document.form1.acao.value=='alter_reincidencia'){
			var reincInsp = document.form1.frmreincInsp.value;
			var reincGrup = document.form1.frmreincGrup.value;
			var reincItem = document.form1.frmreincItem.value;

			if (document.form1.frmReinccb.value == 'S' && (reincInsp.length != 10 || reincGrup == 0 || reincItem == 0))
			{
			 alert('Para o Reincidência: Sim é preciso informar Nº Inspeção, Nº Grupo e Nº Item!');
			 //exibe(sit);
			 return false;
			} else {
			document.form1.frmreincInsp.disabled = false;
			document.form1.frmreincGrup.disabled = false;
			document.form1.frmreincItem.disabled = false;
			}
	}
  
  //==================== 
  if (document.form1.acao.value=='alter_valores'){
	 var caracter = document.form1.caracvlr.value;
	 var tela_falta = document.form1.frmfalta.value;
	 var tela_sobra = document.form1.frmsobra.value;
	 var tela_risco = document.form1.frmemrisco.value;
	 var db_falta = document.form1.sfrmfalta.value;
	 var db_sobra = document.form1.sfrmsobra.value;
	 var db_risco = document.form1.sfrmemrisco.value;
	 var sresp = document.form1.scodresp.value;
	 
	 if (caracter == 'Quantificado' && tela_falta == '0,00' && tela_sobra == '0,00' && tela_risco == '0,00')
	 {
	    alert('Para o Caracteres: Quantificado deve informar os campos Falta e ou Sobra e ou Em Risco!');
		return false;
	 }
	 
	 if (sresp != 0 && sresp != 11)
	  {
		  var strobs = document.form1.observacao.value;
		  strobs = strobs.replace(/\s/g, '');
		  if (strobs == '')
		  {
		   alert('Caro Usuário(a), favor justificar a alteração no campo: Opinião da Equipe de Controle Interno!');
		      return false;
	       }
	       if (strobs.length <= 99)
	       {
		   alert("Caro Gestor(a), Sua justificativa deverá conter no mínimo 100(cem) caracteres!");		
		   return false;
	       }
	  }
	  
	 if (tela_falta != db_falta || tela_sobra != db_sobra || tela_risco != db_risco) { 
	  if (confirm ('                       Atenção! \n\nConfirmar Alteração dos Valores deste ponto?'))
	    {
	     return true;
		}
	  else
	   {
	   return false;
	   }
	 }
	 else
	   {
	   return false;
	   }
	} 	

  // ==== critica do botao Salvar ===
     if (document.form1.acao.value == 'Salvar')
	 {
	    var melhor = document.form1.Melhoria.value;
		melhor = melhor.replace(/\s/g, '');
		
	    var recomed = document.form1.recomendacao.value;
		recomed = recomed.replace(/\s/g, '');
		
	 	if (melhor.length < 100 || recomed.length < 100)
		{
		 alert('Gestor(a), os campos: Situação Encontrada e/ou Orientações devem conter no mínimo 100(cem) caracteres!');
		 return false;
		}
	//----------------------------------------------
	
	
	if (document.form1.nci.value == 'Sim')
		{
			// controle de dados do N.SEI da NCI
		var nsnci = document.form1.frmnumseinci.value;
		if (nsnci.length != 20 || nsnci=='')
		{
			alert('Nº do SEI da NCI Inválido!:  (ex. 99999.999999/9999-99)');
			return false;
		}
	   }
		//----------------------------------------------
	var el = document.getElementById('Abrir');
	if (document.form1.nci.value == 'Sim' && el==null ){
			alert('Sr. Gestor, para pontos com Nota de Controle Interno é necessário anexar a NCI.');
			return false;
	}

	 }
}

//Funcao que abre uma pagina em Popup
function popupPage() {
<cfoutput>  //pagina chamada, seguida dos parametros numero, unidade, grupo e item
var page = "itens_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}
</script>

</head>


<body onLoad="exibevalores(); if(document.form1.houveProcSN.value != 'S') {exibe(document.form1.frmResp.value)} else {exibe(24)}; hanci(); controleNCI(); exibir_Area011(this.value)"> 
 <cfinclude template="cabecalho.cfm">
<table width="70%"  align="center" bordercolor="f7f7f7">
  <tr>
    <td height="20" colspan="5" bgcolor="eeeeee"><div align="center"><strong class="titulo2"><cfoutput>#qResposta.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="5" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <tr>
    <td height="10" colspan="5" bgcolor="eeeeee"><div align="center"><strong class="titulo1">CONTROLE DAS MANIFESTAÇÕES</strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="5" bgcolor="eeeeee">&nbsp;</td>
  </tr>
  <form name="form1" method="post" onSubmit="return validarform()" enctype="multipart/form-data" action="itens_inspetores_controle_revisliber.cfm">
  <cfoutput>
	    <input type="hidden" name="scodresp" id="scodresp" value="#qResposta.Pos_Situacao_Resp#">
		<input type="hidden" name="sfrmPosArea" id="sfrmPosArea" value="#qResposta.Pos_Area#">
		<input type="hidden" name="sfrmPosNomeArea" id="sfrmPosNomeArea" value="#qResposta.Pos_NomeArea#">
		<input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="#qResposta.Itn_TipoUnidade#">
		<cfset resp = #qResposta.Pos_Situacao_Resp#> 
		<input type="hidden" name="srespatual" id="srespatual" value="#resp#">
		<cfset caracvlr = #trim(qResposta.RIP_Caractvlr)#>
		<cfset falta = trim(Replace(NumberFormat(qResposta.RIP_Falta,999.00),'.',',','All'))> 
		<cfset sobra = trim(Replace(NumberFormat(qResposta.RIP_Sobra,999.00),'.',',','All'))> 
		<cfset emrisco = trim(Replace(NumberFormat(qResposta.RIP_EmRisco,999.00),'.',',','All'))> 
		<!--- <input type="hidden" name="tuipontuacao" id="tuipontuacao" value="#rsPto.TUI_Pontuacao#"> --->
		<input type="hidden" name="scaracvlr" id="scaracvlr" value="#caracvlr#">
		<input type="hidden" name="sfrmfalta" id="sfrmfalta" value="#falta#">
		<input type="hidden" name="sfrmsobra" id="sfrmsobra" value="#sobra#">
		<input type="hidden" name="sfrmemrisco" id="sfrmemrisco" value="#emrisco#">
		<input type="hidden" name="sVLRDEC" id="sVLRDEC" value="#url.VLRDEC#">
		<input type="hidden" name="situacao" id="situacao" value="#url.situacao#">
		
	</cfoutput>
    <tr>
      <td colspan="5" bgcolor="eeeeee"><p class="titulo1">
        <input type="hidden" id="acao" name="acao" value="">
        <input type="hidden" id="anexo" name="anexo" value="">
        <input type="hidden" id="vCausaProvavel" name="vCausaProvavel" value="">
        <input type="hidden" id="vCodigo" name="vCodigo" value="">
        <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
        <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
        <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
        <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
        <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
        <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfim#</cfoutput>">
        <input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>">
        <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
        <input type="hidden" id="hUnidade" name="hUnidade" value="<cfoutput>#rsMOd.Und_Descricao#</cfoutput>">
        <input type="hidden" id="hReop" name="hReop" value="<cfoutput>#URL.reop#</cfoutput>">
        <input type="hidden" id="SE" name="SE" value="<cfoutput>#URL.SE#</cfoutput>">
		<input type="hidden" id="selstatus" name="selstatus" value="<cfoutput>#URL.selstatus#</cfoutput>">
        <input type="hidden" id="statusse" name="statusse" value="<cfoutput>#URL.statusse#</cfoutput>">
		<input type="hidden" id="vlrdeclarado" name="vlrdeclarado" value="<cfoutput>#url.vlrdec#</cfoutput>">
		<input type="hidden" id="emailusu" name="emailusu" value="<cfoutput>#qAcesso.Usu_Email#</cfoutput>">

      </p></td>
    </tr>
	  <tr>
      <td width="73" bgcolor="eeeeee" class="exibir">Unidade</td>
      <td width="399" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Unid#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td colspan="3" bgcolor="eeeeee"><cfoutput>
        <table width="692" border="0">
          <tr>
            <td width="74"><span class="exibir">Respons&aacute;vel</span>:</td>
            <td width="303"><strong class="exibir">#qResponsavel.INP_Responsavel#</strong></td>
          </tr>
        </table>
      </cfoutput></td>
      </tr>
	  	  
   <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="4" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong class="exibir">#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Nº Avaliação</td>
      <td colspan="4" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ninsp#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In&iacute;cio 


Avalia&ccedil;&atilde;o &nbsp;<strong class="exibir"><cfoutput>#DateFormat(qResposta.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></strong></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Grupo</td>
      <td colspan="4" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ngrup#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Grp_Descricao#</strong></cfoutput></td>
    </tr>

    <tr class="exibir">
      <td bgcolor="eeeeee">Item</td>
      <td colspan="4" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Nitem#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Itn_Descricao#</strong></cfoutput></td>
    </tr>
<!---	<tr class="exibir">
 <td bgcolor="eeeeee">Valor</td>
      <td colspan="4" bgcolor="eeeeee"><cfoutput><strong>#qResposta.RIP_Valor#</strong></cfoutput></td>
    </tr> --->
<tr class="exibir">
	  <td bgcolor="eeeeee">Relevância</td>
	  <td colspan="4" bgcolor="eeeeee"><table width="100%" border="0">
        <tr bgcolor="eeeeee" class="exibir">
          <td width="70">Pontuação </td>
          <td width="237"><strong class="exibir"><cfoutput>#qResposta.Pos_PontuacaoPonto#</cfoutput></strong></td>
          <td width="169"><div align="right">Classificação do Ponto &nbsp;</div></td>
          <td width="500"><strong class="exibir"><cfoutput>#qResposta.Pos_ClassificacaoPonto#</cfoutput></strong></td>
        </tr>
      </table></td>
    </tr>
	<tr bgcolor="eeeeee" class="exibir">
	  <td>Classificação Unidade</td>
	  <td colspan="4"><table width="100%" border="0">
		<tr>
		  <td width="15%" class="exibir"><div align="center">Classificação Inicial:</div></td>
		  <td width="35%" class="exibir"><strong><cfoutput>#qResposta.TNC_ClassifInicio#</cfoutput></strong></td>
		  <td width="18%" class="exibir"><div align="center">Classificação Atual:</div></td>
		  <td width="32%" class="exibir"><div align="left"><strong><cfoutput>#qResposta.TNC_ClassifAtual#</cfoutput></strong></div></td>
		</tr>
	  </table></td>
 	 </tr>	
    <cfoutput>
	  <cfset db_reincInsp = #trim(qResposta.RIP_ReincInspecao)#>
	  <cfset db_reincGrup = #qResposta.RIP_ReincGrupo#>
	  <cfset db_reincItem = #qResposta.RIP_ReincItem#>
	  <cfif len(trim(qResposta.RIP_ReincInspecao)) gt 0>
		  
		 <tr class="red_titulo">
	  <td bgcolor="eeeeee">Reincid&ecirc;ncia</td>  
	      <input type="hidden" name="db_reincSN" id="db_reincSN" value="N">
		   <cfset reincSN = "S">
		   <input type="hidden" name="db_reincSN" id="db_reincSN" value="S">
		   <cfset db_reincInsp = #trim(qResposta.RIP_ReincInspecao)#>
		   <cfset db_reincGrup = #qResposta.RIP_ReincGrupo#>
		   <cfset db_reincItem = #qResposta.RIP_ReincItem#>
	<td  bgcolor="eeeeee" colspan="4">
N&ordm; Relat&oacute;rio:
			<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" style="background:white" readonly="">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; Grupo:
			<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" style="background:white" readonly="">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; Item:
			<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" style="background:white" readonly=""></td>
	</tr>
	</cfif>
	</cfoutput>	  
	 <cfoutput>
	<cfset caracvlrhabilSN = 'N'>
	<cfset caracvlr = 'NAO QUANTIFICADO'>
	<cfset auxriscoSN = 'N'>
	<!--- <cfif listFind(#rsItem.Itn_PTC_Seq#,10) and (ucase(trim(rsItem.RIP_CARACTVLR)) eq 'QUANTIFICADO' or trim(rsItem.RIP_CARACTVLR) eq '')> --->
	<cfif listFind(#rsItem.Itn_PTC_Seq#,10)>
	   <cfset caracvlr = 'QUANTIFICADO'>
	   <cfset caracvlrhabilSN = 'S'>
	   <cfif (Ngrup is 230 and Nitem is 1) or (Ngrup is 232 and Nitem is 1) or (Ngrup is 702 and Nitem is 2)>
	   	<cfset auxriscoSN = 'S'>
	   </cfif>
	</cfif>	

<!--- composicao item: #rsItem.Itn_PTC_Seq# --->
 <tr class="exibir">
      <td bgcolor="eeeeee">Valores</td>
	
      <td colspan="4" bgcolor="eeeeee">
		  <table width="100%" border="0" cellspacing="0" bgcolor="eeeeee" >
		  <cfif caracvlrhabilSN is 'S'>
		  <tr bgcolor="eeeeee" class="form">
			<td bgcolor="eeeeee">Potencial Valor&nbsp;
				<select name="caracvlr" id="caracvlr" class="form">
					<option  value="QUANTIFICADO">QUANTIFICADO</option>
				</select>                    
			</td>
			<td bgcolor="eeeeee">Estimado a Recuperar (R$):&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)"></td>
			<td bgcolor="eeeeee">Estimado Não Planejado/Extrapolado/Sobra (R$):&nbsp;<input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)"></td>
			<td bgcolor="eeeeee">Estimado em Risco ou Envolvido (R$):&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)"></td>  
		  </tr>
		  <cfelse>
		  		<tr class="form" bgcolor="eeeeee">
					<td bgcolor="eeeeee">Caracteres:&nbsp;
					  <select name="caracvlr" id="caracvlr" class="form" disabled="disabled">
                        <option  value="NAO QUANTIFICADO">NÃO QUANTIFICADO</option>	
                      </select>                    
					</td>
					<td bgcolor="eeeeee">Estimado a Recuperar (R$):&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" readonly="yes"></td>
					<td bgcolor="eeeeee">Estimado Não Planejado/Extrapolado/Sobra (R$):&nbsp;<input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" readonly="yes"></td>
					<td bgcolor="eeeeee">Estimado em Risco ou Envolvido (R$):&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" readonly="yes"></td>
		  		</tr>
		  </cfif>
		  </table>	  
		  </td>
      </tr> 
	<input type="hidden" name="caracvlrhabilSN" id="caracvlrhabilSN" value="#caracvlrhabilSN#">
	<input type="hidden" name="auxriscoSN" id="auxriscoSN" value="#auxriscoSN#">
   </cfoutput>
	 <cfset melhoria = '#qResposta.RIP_Comentario#'>
       <tr>
         <td bgcolor="#eeeeee" align="center"><span class="titulos">Situação Encontrada:</span></td>
        <td colspan="5" bgcolor="eeeeee"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form"><cfoutput>#melhoria#</cfoutput></textarea></td>
        </tr>
     <tr>
        <td bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
        <td colspan="5" bgcolor="eeeeee"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea></td>
    </tr> 

    <tr>
      <td colspan="5">
		  <cfif numncisei eq "">
			  <cfif trim(qResposta.Pos_NCISEI) eq "" and trim(qResposta.Pos_NCISEI) eq "">
				<cfset numncisei = "">
			  <cfelse>
				<cfif trim(qResposta.Pos_NCISEI) neq "">
					<cfset numncisei = trim(rsSEINCI.Pos_NCISEI)>
				</cfif>
				<cfset numncisei = left(numncisei,5) & '.' & mid(numncisei,6,6) & '/' & mid(numncisei,12,4) & '-' & right(numncisei,2)>
			  </cfif>
	      </cfif>
	      <input type="hidden" name="nseincirel" id="nseincirel" value="<cfoutput>#numncisei#</cfoutput>">
      
		    <input type="hidden" name="frmposarea_011" id="frmposarea_011" value="<cfoutput>#qResposta.Pos_Area#</cfoutput>">
			<input type="hidden" name="pontocentlzSN" id="pontocentlzSN" value="N">
			<table width="100%" border="0">
			   <tr bgcolor="eeeeee">
				<td colspan="5" valign="middle" bgcolor="eeeeee" class="exibir">Houve Nota de Controle?&nbsp;&nbsp;
				<select name="nci" class="form"  onChange="hanci();mensagemNCI();controleNCI(); exibir_Area011(this.value)">
				<cfif trim(qResposta.Pos_NCISEI) eq ''>
					  <option value="Não" selected>Não</option>
					  <option value="Sim">Sim</option>
				<cfelse>
					  <option value="Não">Não</option>
					  <option value="Sim" selected>Sim</option>
				</cfif>
				</select>
				<cfif numncisei neq "">
					<script>
						document.form1.nci.selectedIndex = 1;
					</script>
			    </cfif>
				</td>
				<cfset aux_ano = right(dateformat(now(),"YYYY"),2)>
				<td width="77%" bgcolor="eeeeee" class="exibir"><div id="ncisei">Nº SEI da NCI :&nbsp;&nbsp;
                   <input name="frmnumseinci" id="frmnumseinci" type="text" class="form" onBlur="controleNCI()"  onKeyPress="numericos();" onKeyDown="validacao(); Mascara_SEI(this);" size="27" maxlength="20" value="<cfoutput>#numncisei#</cfoutput>">
				  </div>
			     </td>
		      </tr>
            </table>
       </td>
    </tr>
    <tr>
      <td colspan="5" class="exibir" bgcolor="eeeeee"><div align="left"><strong class="exibir">ANEXOS</strong></div></td>
    </tr>

	<tr>
        <td bgcolor="eeeeee" class="exibir"><strong class="exibir">Arquivo:</strong></td>
        <td bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td width="1" bgcolor="eeeeee" class="exibir">&nbsp;</td>
        <td bgcolor="eeeeee" class="exibir"><input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar"></td>
        <td width="57" bgcolor="eeeeee" class="exibir">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
 <!--- <cfset resp = qResposta.Pos_Situacao_Resp> --->
    <cfloop query= "qAnexos">
      <cfif FileExists(qAnexos.Ane_Caminho)>
        <tr>
          <td colspan="3" bgcolor="#eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
          <td width="623" bgcolor="#eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                  <div align="left">
                    &nbsp;
                    <input id="Abrir" type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />
            </div></td>
		  <td bgcolor="eeeeee"><cfoutput>
              <div align="center">
				<cfif (resp neq 24)>
                   <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#">
                <cfelse>
                   <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#" disabled>
				</cfif>
		        </div>
		  </cfoutput></td>
        </tr>
      </cfif>
    </cfloop>
	<tr>
      <td colspan="5">&nbsp;</td>
    </tr>

	<tr>
	<td colspan="6" bgcolor="eeeeee" class="exibir"><div align="left">Selecione a &aacute;rea:
	      <select name="frmcbarea" id="frmcbarea" class="form">
                  <option value="">---</option>
                  <cfoutput query="qArea">
                      <option value="#Ars_Codigo#">#trim(Ars_Descricao)#</option>
                  </cfoutput>
            </select>
    </div></td>
	</tr>
<cfoutput>
 	
    <tr>
      <td colspan="5" align="center">
        <input name="button" type="button" class="botao" onClick="window.open('itens_inspetores_controle_respostas.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&SE=#url.SE#&cktipo=#url.cktipo#&selstatus=#selstatus#&StatusSE=#StatusSE#','_self')" value="Voltar">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <!--- <input name="Submit" type="Submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar';"> --->
		<cfif (resp is 0) or (resp is 11)>
		<input name="Submit" type="Submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar';">
	  <cfelse>
<input name="Submit" type="Submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar';" disabled>
      </cfif>
      
	  </td>
    </tr>
</cfoutput>  
          <script>
			   hanci();
			   controleNCI(); 
			   exibir_Area011(document.form1.nci.value);
			</script>
 </form>
</table>
</body>
<script>
	<cfoutput>
		<!---Retorna true se a data de início da inspeção for maior ou igual a 04/03/2021, data em que o editor de texto foi implantado. Isso evitará que os textos anteriores sejam desformatados--->
		<cfset CouponDate = createDate( 2021, 03, 04 ) />
		<cfif DateDiff( "d", '#qResposta.INP_DtInicInspecao#',CouponDate ) GTE 1>
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

<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>
