
<!---  <cfdump var="#form#">
 <cfdump var="#url#">
  <cfdump var="#session#">

<cfabort> --->

<cffunction name="Moeda" returntype="String">
  <cfargument name="Numero" type="String" required="true">

  <cfset mascara = Replace(Replace(Replace(Numberformat(Numero,'999,999,999.00'),'.',';'),',','.','all'),';',',')>

<cfreturn mascara>
</cffunction>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'INSPETORES'>

 <cftry>

<cfif isDefined("Form.acao") And (Form.acao is 'Incluir' Or Form.acao is 'Anexar' Or Form.acao is 'Excluir' Or Form.acao is 'Excluir_Causa')>
  <cfif isDefined("Form.abertura")><cfset Session.E01.abertura = Form.abertura><cfelse><cfset Session.E01.abertura = 'Nao'></cfif>
  <cfif isDefined("Form.processo")><cfset Session.E01.processo = Form.processo><cfelse><cfset Session.E01.processo = ''></cfif>
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
  <cfif isDefined("Form.obs")><cfset Session.E01.obs = Form.obs><cfelse><cfset Session.E01.obs = ''></cfif>
  <cfif isDefined("Form.observacao")><cfset Session.E01.observacao = Form.observacao><cfelse><cfset Session.E01.observacao = ''></cfif>
  <cfif isDefined("Form.recomendacao")><cfset Session.E01.recomendacao = Form.recomendacao><cfelse><cfset Session.E01.recomendacao = ''></cfif>
  <cfif isDefined("Form.reop")><cfset Session.E01.reop = Form.reop><cfelse><cfset Session.E01.reop = ''></cfif>
  <cfif isDefined("Form.unid")><cfset Session.E01.unid = Form.unid><cfelse><cfset Session.E01.unid = ''></cfif>
  <cfif isDefined("Form.modalidade")><cfset Session.E01.modalidade = Form.modalidade><cfelse><cfset Session.E01.modalidade = ''></cfif>
  <cfif isDefined("Form.valor")><cfset Session.E01.valor = Form.valor><cfelse><cfset Session.E01.valor = ''></cfif>
  <cfif isDefined("Form.SE")><cfset Session.E01.SE = Form.SE><cfelse><cfset Session.E01.SE = ''></cfif>
  <cfif isDefined("Form.VLRecuperado")><cfset Session.E01.VLRecuperado = Form.VLRecuperado><cfelse><cfset Session.E01.VLRecuperado = ''></cfif>
  <cfif isDefined("Form.cbareaCS")><cfset Session.E01.cbareaCS = Form.cbareaCS><cfelse><cfset Session.E01.cbareaCS = ''></cfif>

<!--- Incluir Causa Provavel --->


<cfif Form.acao is 'Incluir'>

<cfquery datasource="#dsn_inspecao#" name="qVerificaRegistroParecer">
	SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem FROM ParecerUnidade
	WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>


  <cfif qVerificaRegistroParecer.RecordCount Neq 0>

	  <cfquery datasource="#dsn_inspecao#" name="qVerificaCausa">
			 INSERT INTO ParecerCausaProvavel(PCP_Unidade, PCP_Inspecao, PCP_NumGrupo, PCP_NumItem, PCP_CodCausaProvavel)
			 VALUES ('#Form.unid#', '#Form.ninsp#', #Form.ngrup#, #Form.nitem#, #Form.causaprovavel#)
      </cfquery>

   </cfif>

</cfif>


  <!--- Anexar arquivo --->

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
		SELECT Ane_Codigo, Ane_Caminho FROM Anexos
		WHERE Ane_Codigo = '#vCodigo#'
	</cfquery>



 <cfif qAnexos.recordCount Neq 0>

	<!--- Exluindo arquivo do diretório de Anexos --->
	<cfif FileExists(qAnexos.Ane_Caminho)>
		<cffile action="delete" file="#qAnexos.Ane_Caminho#">
	</cfif>


	<!--- Excluindo anexo do banco de dados --->

	<cfquery datasource="#dsn_inspecao#">
	  DELETE FROM Anexos
	  WHERE  Ane_Codigo = '#vCodigo#'
	</cfquery>

 </cfif>

</cfif>
  <!--- Excluir Causa --->
 <cfif Form.acao is 'Excluir_Causa'>
  <!--- Verificar se Causa existe --->
	  <cfquery name="qCausaExcluir" datasource="#dsn_inspecao#">
		SELECT PCP_Unidade, PCP_Inspecao, PCP_NumGrupo, PCP_NumItem, PCP_CodCausaProvavel
		FROM ParecerCausaProvavel
		WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem# AND PCP_CodCausaProvavel=#vCausaProvavel#
	  </cfquery>

<!--- <cfdump var="#qCausaExcluir#"> --->

 <cfif qCausaExcluir.recordCount Neq 0>

	<!--- Excluindo Causa do banco de dados --->

	<cfquery datasource="#dsn_inspecao#">
	  DELETE FROM ParecerCausaProvavel
	  WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem# AND PCP_CodCausaProvavel=#vCausaProvavel#
	</cfquery>
 </cfif>
</cfif>
</cfif>

 <cfif IsDefined("FORM.submit") AND FORM.submit EQ "Salvar" And IsDefined("FORM.acao") And Form.acao is "Salvar">
 <cfquery datasource="#dsn_inspecao#">
   UPDATE Resultado_Inspecao SET
  <cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
    RIP_Comentario=
	  <cfset aux_mel = CHR(13) & Form.Melhoria>
	  <!--- <As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
	  <cfset aux_mel = Replace(aux_mel,'"','','All')>
	  <cfset aux_mel = Replace(aux_mel,"'","","All")>
	  <cfset aux_mel = Replace(aux_mel,'&','','All')>
	  <cfset aux_mel = Replace(aux_mel,'*','','All')>
	  <cfset aux_mel = Replace(aux_mel,'%','','All')>
	  '#aux_mel#'
   </cfif>
   <cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
     , RIP_Recomendacoes=
	  <cfset aux_recom = CHR(13) & FORM.recomendacao>
	  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
	  <cfset aux_recom = Replace(aux_recom,'"','','All')>
	  <cfset aux_recom = Replace(aux_recom,"'","","All")>
	  <cfset aux_recom = Replace(aux_recom,'&','','All')>
	  <cfset aux_recom = Replace(aux_recom,'*','','All')>
	  <cfset aux_recom = Replace(aux_recom,'%','','All')>
	  '#aux_recom#'
    </cfif>
	<cfif IsDefined("FORM.valor") AND FORM.valor NEQ "">
      , RIP_Valor='#FORM.valor#'
    </cfif>
	  , RIP_UserName = '#CGI.REMOTE_USER#'
	  , RIP_DtUltAtu = CONVERT(char, GETDATE(), 102)
	  WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
  </cfquery>

 <cfquery datasource="#dsn_inspecao#">
   UPDATE ParecerUnidade SET Pos_Situacao_Resp = 11, Pos_Situacao = 'EL'
   WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
 </cfquery>

 <!--- Verificar registro está na situação 11(Em Liberação) na tabela ParecerUnidade --->

 <cfquery name="qEmLiberacao" datasource="#dsn_inspecao#">
   SELECT Pos_Situacao_Resp FROM ParecerUnidade
   WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem# AND Pos_Situacao_Resp = 11
 </cfquery>

<cfif qEmLiberacao.Pos_Situacao_Resp eq 11>

 <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic)
   VALUES ('#Form.ninsp#', '#Form.unid#', #Form.ngrup#, #Form.nitem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 11, convert(char, getdate(), 108))
 </cfquery>

 </cfif>

<cfquery name="qInspecaoLiberada" datasource="#dsn_inspecao#">
  SELECT * FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 0
</cfquery>

<cfif qInspecaoLiberada.recordCount Eq 0>

 <cfquery datasource="#dsn_inspecao#">
    UPDATE ParecerUnidade SET Pos_Situacao_Resp = 14, Pos_Situacao = 'NR'
    WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#'
 </cfquery>

</cfif>

 <!--- Verificar registro está na situação 14(Não Respondido) na tabela ParecerUnidade --->

 <cfquery name="qNaoRespondido" datasource="#dsn_inspecao#">
   SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp FROM ParecerUnidade
   WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 14
 </cfquery>

<cfoutput query="qNaoRespondido">

 <cfif qNaoRespondido.Pos_Situacao_Resp eq 14>

 <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic)
   VALUES ('#qNaoRespondido.Pos_Inspecao#', '#qNaoRespondido.Pos_Unidade#', #qNaoRespondido.Pos_NumGrupo#, #Pos_NumItem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 14, '#TimeFormat(Now(),"HH:mm")#:#NumberFormat(qNaoRespondido.CurrentRow,'00')#')
 </cfquery>

</cfif>

</cfoutput>

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

<!--- Visualização de anexos --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
</cfquery>

<cfquery name="qCausa" datasource="#dsn_inspecao#">
  SELECT Cpr_Codigo, Cpr_Descricao FROM CausaProvavel WHERE Cpr_Codigo not in (select PCP_CodCausaProvavel from ParecerCausaProvavel
  WHERE PCP_Unidade='#unid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem#)
  ORDER BY Cpr_Descricao
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

</cfif>

<cfif qSituacaoResp.recordCount Neq 0>
	<cfparam name="FORM.frmResp" default="#qSituacaoResp.Pos_Situacao_Resp#">
<cfelse>
	<cfparam name="Form.frmResp" default="0">
</cfif>

<!--- <cfdump var="#qSituacaoResp#"> --->


<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
</cfquery>

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Dir_Descricao, Dir_Codigo, Dir_Sigla
  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar2">
  <cfquery datasource="#dsn_inspecao#">
  UPDATE ParecerUnidade SET
  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">
    Pos_Situacao_Resp='#FORM.frmResp#'
  </cfif>
  <cfswitch expression="#Form.frmResp#">
    <cfcase value="0">
	  <cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'RE'
	  <cfset situacao = 'REVISÃO'>
	</cfcase>
	<cfcase value="2">
	  <cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'PU'
	  , Pos_Area = '#form.unid#'
	  , Pos_NomeArea = '#rsMod.Und_Descricao#'
	  <cfset Gestor = '#rsMod.Und_Descricao#'>
	  <cfset situacao = 'PENDENTE DE UNIDADE'>
	</cfcase>
	<cfcase value="3">
	<cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'SO'
	  , Pos_Area = '#qSituacaoResp.Pos_Area#'
	  , Pos_NomeArea = '#qSituacaoResp.Pos_NomeArea#'
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset situacao = 'SOLUCIONADO'>
	</cfcase>
	<cfcase value="4">
	 <cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'PO'
	  , Pos_Area = '#form.reop#'
	  <cfset situacao = 'PENDENTE DE ÓRGÃO SUBORDINADOR'>
	  <cfquery name="qReop" datasource="#dsn_inspecao#">
		  SELECT Rep_Nome
		  FROM Reops
		  WHERE Rep_Codigo = '#form.reop#'
     </cfquery>
	     <cfset Gestor = qReop.Rep_Nome>
	   , Pos_Nomearea = '#qReop.Rep_Nome#'
	 </cfcase>
	<cfcase value="5">
	<cfset Encaminhamento = 'Opinião do Controle Interno'>
	   , Pos_Situacao = 'PA'
	   , Pos_Area = '#Form.cbArea#'
	   <cfset situacao = 'PENDENTE DE ÁREA'>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbArea#'
	  </cfquery>
	    <cfset Gestor = qArea2.Ars_Sigla>
	    , Pos_Nomearea = '#qArea2.Ars_Sigla#'
	</cfcase>
	<cfcase value="8"><cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'SE'
	  , Pos_Area = ('000000'+ '#rsMod.Und_CodDiretoria#')
	  <cfset situacao = 'CORPORATIVO SE'>
	  <cfset Gestor = rsMod.Dir_Descricao>
	  , Pos_NomeArea = '#rsMod.Dir_Descricao#'
	</cfcase>
	<cfcase value="9"><cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'CS'
	  , Pos_Area = '#Form.cbAreaCS#'
	  <cfset situacao = 'CORPORATIVO CS'>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbAreaCS#'
	   </cfquery>
	   <cfset Gestor = qArea2.Ars_Sigla>
	    , Pos_Nomearea = '#qArea2.Ars_Sigla#'
	</cfcase>
	<cfcase value="10"><cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'PS'
	  , Pos_Area = '#Form.cbArea#'
	  <cfset situacao = 'PONTO SUSPENSO'>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbArea#'
	  </cfquery>
	    <cfset Gestor = qArea2.Ars_Sigla>
	   , Pos_Nomearea = '#qArea2.Ars_Sigla#'
	</cfcase>
	<cfcase value="13"><cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'OC'
	  , Pos_Area = '#qSituacaoResp.Pos_Area#'
	  , Pos_NomeArea = '#qSituacaoResp.Pos_NomeArea#'
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset situacao = 'ORIENTAÇÃO CANCELADA'>
	</cfcase>
	<cfcase value="12"><cfset Encaminhamento = 'Opinião do Controle Interno'>
	  , Pos_Situacao = 'PI'
	  , Pos_Area = '#qSituacaoResp.Pos_Area#'
	  , Pos_NomeArea = '#qSituacaoResp.Pos_NomeArea#'
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset situacao = 'PONTO IMPROCEDENTE'>
	</cfcase>
  </cfswitch>
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
  , Pos_Parecer=
    <cfset aux_obs = Form.H_obs & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento)  & CHR(13) & CHR(13) & 'À(O)' & '  ' & Gestor & CHR(13) & CHR(13) & Trim(FORM.observacao) & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & FORM.cbData & CHR(13) & CHR(13) & 'Responsável: ' & CGI.REMOTE_USER & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------' & CHR(13) & CHR(13)>
	<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
	 <cfset aux_obs = Replace(aux_obs,'"','','All')>
	 <cfset aux_obs = Replace(aux_obs,"'","","All")>
	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
	 <cfset aux_obs = Replace(aux_obs,'*','','All')>
	 <cfset aux_obs = Replace(aux_obs,'%','','All')>
	'#aux_obs#'
    </cfif>
	<cfif IsDefined("FORM.cbData") AND FORM.cbData NEQ "">
    , Pos_DtPrev_Solucao =
    <cfset dia_data = Left(FORM.cbData,2)>
    <cfset mes_data = Mid(FORM.cbData,4,2)>
    <cfset ano_data = Right(FORM.cbData,2)>
    <cfset data = CreateDate(ano_data,mes_data,dia_data)>
    #data#
    </cfif>
	<cfif IsDefined("FORM.abertura") AND FORM.abertura NEQ "">
    , Pos_Abertura = '#FORM.abertura#'
    </cfif>
	<cfif IsDefined("FORM.VLRecuperado") AND FORM.VLRecuperado NEQ "">
	<cfset aux_vlrecuperado = Replace(FORM.VLRecuperado,',','.','All')>
      , Pos_VLRecuperado='#aux_vlrecuperado#'
    </cfif>
    <cfif IsDefined("FORM.processo") AND FORM.processo NEQ "">
	, Pos_Processo =
    <cfset InicioProc = Left(FORM.processo,2)>
	<cfset MeioProc = Mid(FORM.processo,4,5)>
	<cfset FimProc = Right(FORM.processo,2)>
    <cfset tProcesso = InicioProc & MeioProc & FimProc>
	#tProcesso#
   </cfif>
    , Pos_Tipo_Processo =
	<cfif IsDefined("FORM.modalidade") AND FORM.modalidade NEQ "">
    '#FORM.modalidade#'
      <cfelse>
	  NULL
    </cfif>
	, pos_username = '#CGI.REMOTE_USER#'
    , Pos_DtPosic = CONVERT(char, GETDATE(), 102)
	, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
      WHERE Pos_Unidade= '#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
 </cfquery>

<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar2">

  <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic)
   VALUES (
   <cfif IsDefined("form.Ninsp") AND form.Ninsp NEQ "">
   '#form.ninsp#'
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Unid") AND form.Unid NEQ "">
   '#form.unid#'
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Ngrup") AND form.Ngrup NEQ "">
   #form.Ngrup#
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Nitem") AND form.Nitem NEQ "">
   #form.Nitem#
      <cfelse>
      NULL
   </cfif>
   ,
   convert(char, getdate(), 102),
   '#CGI.REMOTE_USER#',

   <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">
   #FORM.frmResp#
      <cfelse>
      NULL
   </cfif>
   ,
  CONVERT(char, GETDATE(), 108)
  )
 </cfquery>
</cfif>

   <!--- Dados no campo Recomendações --->

<!--- <cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar2">

  <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Orgao_Solucao, And_HrPosic)
   VALUES (
   <cfif IsDefined("form.Ninsp") AND form.Ninsp NEQ "">
   '#form.ninsp#'
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Unid") AND form.Unid NEQ "">
   '#form.unid#'
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Ngrup") AND form.Ngrup NEQ "">
   #form.Ngrup#
      <cfelse>
      NULL
   </cfif>
   ,
   <cfif IsDefined("form.Nitem") AND form.Nitem NEQ "">
   #form.Nitem#
      <cfelse>
      NULL
   </cfif>
   ,
   convert(char, getdate(), 102),
   '#CGI.REMOTE_USER#',

  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "">
    #FORM.frmResp#
  </cfif>
  <cfswitch expression="#Form.frmResp#">
	<cfcase value="2">
	  , '#rsMod.Und_Descricao#'
	</cfcase>
	<cfcase value="3">
	  , '#qSituacaoResp.Pos_NomeArea#'
	</cfcase>
	<cfcase value="4">
	  <cfquery name="qReop" datasource="#dsn_inspecao#">
		  SELECT Rep_Nome
		  FROM Reops
		  WHERE Rep_Codigo = '#form.reop#'
      </cfquery>
	   , '#qReop.Rep_Nome#'
	 </cfcase>
	<cfcase value="5">
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbArea#'
	  </cfquery>
	    , '#qArea2.Ars_Sigla#'
	</cfcase>
	<cfcase value="8">
	  , '#rsMod.Dir_Sigla#'
	</cfcase>
	<cfcase value="9">
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbAreaCS#'
	   </cfquery>
	    , '#qArea2.Ars_Sigla#'
	</cfcase>
	<cfcase value="10">
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbArea#'
	  </cfquery>
	   , '#qArea2.Ars_Sigla#'
	</cfcase>
	<cfcase value="13">
	  , '#qSituacaoResp.Pos_NomeArea#'
	</cfcase>
	<cfcase value="12">
	  , '#qSituacaoResp.Pos_NomeArea#'
	</cfcase>
  </cfswitch>
  , CONVERT(char, GETDATE(), 108)
  )
 </cfquery>
</cfif> --->


  <!--- Encerramento do processo --->
  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp EQ "3">
    <cfquery name="qVerificaEncerramento" datasource="#dsn_inspecao#">
      SELECT COUNT(Pos_Inspecao) AS vTotal
      FROM ParecerUnidade
      WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_Situacao_Resp <> '3'
    </cfquery>
    <cfif qVerificaEncerramento.vTotal is 0>
      <cfquery datasource="#dsn_inspecao#">
        UPDATE ProcessoParecerUnidade SET Pro_Situacao = 'EN', Pro_DtEncerr = CONVERT(char, GETDATE(), 102)
        WHERE Pro_Unidade='#FORM.unid#' AND Pro_Inspecao='#FORM.ninsp#'
      </cfquery>
    </cfif>
  </cfif>

</cfif>


<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
 SELECT Pos_Situacao_Resp, Pos_Parecer, RIP_Recomendacoes, RIP_Comentario, RIP_Valor, Dir_Descricao, Dir_Codigo, Pos_Area, Pos_Processo, Pos_Tipo_Processo, Pos_Abertura,
 Itn_Descricao, Pos_VLRecuperado FROM  Resultado_Inspecao INNER JOIN ParecerUnidade ON Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade AND
 Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao AND Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo AND Resultado_Inspecao.RIP_NumItem =
 ParecerUnidade.Pos_NumItem INNER JOIN Itens_Verificacao ON ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo AND ParecerUnidade.Pos_NumItem =
 Itens_Verificacao.Itn_NumItem INNER JOIN Grupos_Verificacao ON ParecerUnidade.Pos_NumGrupo = Grupos_Verificacao.Grp_Codigo INNER JOIN Diretoria ON
 Resultado_Inspecao.RIP_CodDiretoria = Diretoria.Dir_Codigo
 WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
 SELECT Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
 FROM Inspetor_Inspecao INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND Inspetor_Inspecao.IPT_MatricInspetor =
 Funcionarios.Fun_Matric WHERE IPT_NumInspecao = '#URL.Ninsp#'
</cfquery>

<cfquery name="qArea" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '#rsMod.Dir_Codigo#')
 ORDER BY Ars_Sigla
</cfquery>

<cfquery name="qAreaCS" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '01')
 ORDER BY Ars_Sigla
</cfquery>


<cfquery name="qCausaProcesso" datasource="#dsn_inspecao#">
 SELECT Cpr_Descricao, PCP_Unidade, PCP_CodCausaProvavel FROM ParecerCausaProvavel INNER JOIN CausaProvavel ON ParecerCausaProvavel.PCP_CodCausaProvavel =
 CausaProvavel.Cpr_Codigo WHERE PCP_Unidade='#URL.unid#' AND PCP_Inspecao='#URL.ninsp#' AND PCP_NumGrupo=#URL.ngrup# AND PCP_NumItem=#URL.nitem#
</cfquery>

<cfset vRecom = 0>
<cfset vRecomendacao = Trim(qResposta.RIP_Recomendacoes)>

<cfif vRecomendacao is ''>
   <cfset vRecom = 1>
</cfif>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script>
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
			data.value += "/";
			break;
		case 5:
			data.value += "/";
			break;
	}
}
var ind;
function exibirArea(ind){
  if (ind==5 || ind==10){
    window.dArea.style.visibility = 'visible';
  } else {
    window.dArea.style.visibility = 'hidden';
	document.form1.cbArea.value = '';
  }
}
var idx;
function exibirAreaCS(idx){
  if (idx==9){
    window.dAreaCS.style.visibility = 'visible';
  } else {
    window.dAreaCS.style.visibility = 'hidden';
	document.form1.cbAreaCS.value = '';
  }
}
var dat;
function exibirData(dat){
  if (dat==2 || dat==4 || dat==5 || dat==8){
    window.dData.style.visibility = 'visible';
  } else {
    window.dData.style.visibility = 'hidden';
	document.form1.cbData.value = '';
  }
}
var vlr;
function exibirValor(vlr){
  if (vlr==3){
    window.dValor.style.visibility = 'visible';
    alert('Sr. Inspetor, informe o valor recuperado');
  } else {
    window.dValor.style.visibility = 'hidden';
	document.form1.VLRecuperado.value = '';
  }
}
function validaForm(){
    if (document.form1.acao.value=='Incluir'){
    if (document.form1.causaprovavel.value == ''){
	  alert('Sr. Inspetor, selecione uma causa provável');
	  return false;
	}else{
	  return true;
	}
  }
  if (document.form1.acao.value=='Anexar'){
	  return true;
  }
  if (document.form1.acao.value=='Excluir'){
	  return true;
  }
  if (document.form1.acao.value=='Excluir_Causa'){
	  return true;
  }
  if ((document.form1.frmResp[2].checked) || (document.form1.frmResp[6].checked)){
    if(document.form1.cbArea.value == ''){
       alert('Sr. Inspetor, informe a Área para encaminhamento!');
	   return false;
	}
  }
  if (document.form1.frmResp[4].checked){
    if(document.form1.cbAreaCS.value == ''){
       alert('Sr. Inspetor, informe a Área para encaminhamento!');
	   return false;
	}
  }
if((document.form1.frmResp[0].checked==0) && (document.form1.frmResp[1].checked==0) && (document.form1.frmResp[2].checked==0) && (document.form1.frmResp[3].checked==0) && (document.form1.frmResp[4].checked==0) && (document.form1.frmResp[5].checked==0) && (document.form1.frmResp[6].checked==0) && (document.form1.frmResp[7].checked==0) && (document.form1.frmResp[8].checked==0)){
		     alert('Sr. Inspetor, Escolha uma das Situações para a Oportunidade de Aprimoramento.');
		     return false;
	     }
	  if (document.form1.observacao.value == ''){
		 alert('Sr. Inspetor, está faltando sua Análise no campo Opinião da Equipe de Controle Interno!');
		 return false;
	    }
}
function Mascara_Processo(Processo)
{
	switch (Processo.value.length)
	{
		case 2:
			Processo.value += ".";
			break;
		case 8:
			Processo.value += "/";
			break;
	}
}

//Função que abre uma página em Popup
function popupPage() {
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_controle_respostas1_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}

</script>

</head>
<body onLoad="exibirData(0);exibirArea(0);exibirAreaCS(0);exibirValor(0)">

<!--- <cfinclude template="cabecalho.cfm"> --->
<table width="85%"  align="center">
  <tr>
    <td height="20" colspan="5"><div align="center"><strong class="titulo2"><cfoutput>#qResposta.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td height="10" colspan="5"><div align="center"><strong class="titulo1">Controle das MANIFESTA&Ccedil;&Otilde;ES</strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <form name="form1" method="post" onSubmit="return validaForm()" enctype="multipart/form-data" action="itens_controle_respostas1.cfm">
    <!--- <form name="frm1" action="itens_controle_receber_anexo.cfm" enctype="multipart/form-data" method="post"> --->
    <tr>
      <td colspan="5"><p class="titulo1">
        <input type="hidden" name="acao" value="">
        <input type="hidden" name="anexo" value="">
        <input type="hidden" name="vCausaProvavel" value="">
        <input type="hidden" name="vCodigo" value="">
        <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
        <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
        <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
        <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
        <input name="dtinicio" type="hidden" id="dtinicio" value="<cfoutput>#URL.DtInic#</cfoutput>">
        <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfim#</cfoutput>">
        <input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>">
        <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
        <input type="hidden" name="hUnidade" value="<cfoutput>#rsMOd.Und_Descricao#</cfoutput>">
        <input type="hidden" name="hReop" value="<cfoutput>#URL.reop#</cfoutput>">
        <input type="hidden" name="SE" value="<cfoutput>#URL.SE#</cfoutput>">
      </p></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Unidade</td>
      <td bgcolor="f7f7f7"><cfoutput>#URL.Unid#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td colspan="2" bgcolor="eeeeee">Respons&aacute;vel</td>
      <td bgcolor="f7f7f7"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
    </tr>
    <tr class="exibir">
      <cfif qInspetor.RecordCount lt 2>
        <td bgcolor="eeeeee">Inspetor</td>
        <cfelse>
        <td bgcolor="eeeeee">Inspetores</td>
      </cfif>
      <td colspan="5" bgcolor="f7f7f7">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;
              <cfif qInspetor.currentrow neq qInspetor.recordcount>
                <br>
                -&nbsp;
              </cfif>
      </cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Nº Relatório</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput>#URL.Ninsp#</cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Grupo</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong>#URL.DGrup#</strong></cfoutput></td>
    </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Item</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong>#qResposta.Itn_Descricao#</strong></cfoutput></td>
    </tr>
    <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
      <tr class="exibir">
        <td bgcolor="eeeeee">Valor</td>
        <td colspan="4" bgcolor="f7f7f7"><input name="valor" class="form" type="text" size="50" value="<cfoutput>#qResposta.RIP_Valor#</cfoutput>"></td>
      </tr>
      <cfelse>
      <tr class="exibir">
        <td bgcolor="eeeeee">Valor</td>
        <td colspan="4" bgcolor="f7f7f7"><cfoutput>#qResposta.RIP_Valor#</cfoutput></td>
      </tr>
    </cfif>
    <tr>
      <td bgcolor="#eeeeee" align="center"><span class="titulos">Oportunidade de Aprimoramento:</span></td>
      <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
        <td colspan="5" bgcolor="f7f7f7"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td>
        <cfelse>
        <td colspan="4" bgcolor="f7f7f7"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td>
      </cfif>
    </tr>
    <tr>
      <cfif (qResposta.Pos_Situacao_Resp is 0) or (qResposta.Pos_Situacao_Resp is 11)>
        <td bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
        <td colspan="4" bgcolor="f7f7f7"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea></td>
    </tr>
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="5" class="exibir" bgcolor="#eeeeee"><div align="center"><strong>ANEXOS</strong></div></td>
    </tr>
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <cfloop query= "qAnexos">
      <cfif FileExists(qAnexos.Ane_Caminho)>
        <tr>
          <td colspan="4" bgcolor="#eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
          <td width="153" bgcolor="#eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
              <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
        </tr>
      </cfif>
    </cfloop>
    <tr>
      <td colspan="5" align="center"><cfoutput>
        <input name="button" type="button" class="botao" onClick="window.open('itens_controle_respostas.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&SE=#url.SE#&cktipo=#url.cktipo#','_self')" value="Voltar">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input name="Submit" type="Submit" class="botao" value="Salvar" onClick="document.form1.acao.value='Salvar';">
      </cfoutput></td>
    </tr>
    <cfabort>
  <cfelse>
    <tr>
      <td bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
      <td colspan="4" bgcolor="f7f7f7"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea></td>
    </tr></cfif>
    <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>">
    <tr>
      <td valign="middle" bgcolor="eeeeee" align="center"><span class="titulos">Hist&oacute;rico:</span> <span class="titulos">Manifestação e Plano de Ação/An&aacute;lise do Controle Interno</span><span class="titulos">:</span></td>
      <td colspan="5" bgcolor="f7f7f7"><textarea name="H_obs" cols="200" value="#Session.E01.h_obs#" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_parecer#</cfoutput></textarea></td>
    </tr>
    <tr bgcolor="f7f7f7">
      <td bgcolor="eeeeee" align="center"><span class="titulos">Causas Prováveis:</span></td>
      <td colspan="3" valign="middle" class="exibir"><select name="causaprovavel" class="form">
        <option selected="selected" value="">---</option>
        <cfoutput query="qCausa">
          <option value="#Cpr_Codigo#">#Cpr_Descricao#</option>
        </cfoutput>
      </select></td>
      <td><input name="Submit" type="Submit" class="botao" value="Incluir" onClick="document.form1.acao.value='Incluir';"></td>
    </tr>
    <cfoutput query="qCausaProcesso">
      <tr bgcolor="f7f7f7">
        <td bgcolor="eeeeee">&nbsp;</td>
        <td colspan="3" bgcolor="f7f7f7" valign="middle" class="exibir"> #Cpr_Descricao# </td>
        <td bgcolor="eeeeee"><input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Causa';document.form1.vCausaProvavel.value=this.codigo" value="Excluir" codigo="#qCausaProcesso.PCP_CodCausaProvavel#"></td>
      </tr>
    </cfoutput>
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <!--- Se existir dados na sessão, exibir os dados armazenados --->
    <cfif isDefined("Session.E01.abertura")>
      <tr bgcolor="f7f7f7">
        <td colspan="5" valign="middle" class="exibir">Foi aberto processo disciplinar?&nbsp;&nbsp;
            <select name="abertura" class="form">
              <option value="Nao" <cfif Session.E01.abertura is 'Nao'>selected</cfif>>Não</option>
              <option value="Sim" <cfif Session.E01.abertura is 'Sim'>selected</cfif>>Sim</option>
            </select>
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Processo:&nbsp;&nbsp;
          <cfset proc = qResposta.Pos_Processo>
          <cfset processo = Left(proc,2) & '.' & Mid(proc,3,5) & '/' & Right(proc,2)>
          <input name="processo" class="form" type="text" size="11" value="<cfoutput>#Session.E01.processo#</cfoutput>" maxlength="11" onKeyPress="Mascara_Processo(this)">
          &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          Modalidade:&nbsp;&nbsp;
          <select name="modalidade" class="form">
            <option value="">---</option>
            <option value="Apuracao_Direta" <cfif Session.E01.modalidade is 'Apuracao_Direta'>selected</cfif>>Apuração Direta</option>
            <option value="Sindicancia_Sumaria" <cfif Session.E01.modalidade is 'Sindicancia_Sumaria'>selected</cfif>>Sindicância Sumária</option>
          </select></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr bgcolor="f7f7f7">
        <td colspan="5" height="22" valign="middle" class="exibir">Situa&ccedil;&atilde;o:&nbsp;&nbsp;
            <label><span class="style4">
            <input name="frmResp" type="radio" value="2" <cfif Session.E01.frmResp is '2'>checked</cfif> onClick="exibirData(this.value)">
              Pendente Unidade</span></label>
            <label><span class="style4">
            <input name="frmResp" type="radio" value="4" <cfif Session.E01.frmResp is '4'>checked</cfif> onClick="exibirData(this.value)">
              Pendente de Órgão Subordinador</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="5" <cfif Session.E01.frmResp is '5'>checked</cfif> onClick="exibirArea(this.value);exibirData(this.value)">
              Pendente de Área</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="8" <cfif Session.E01.frmResp is '8'>checked</cfif> onClick="exibirData(this.value)">
              Corporativo SE</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="9" <cfif Session.E01.frmResp is '9'>checked</cfif> onClick="exibirAreaCS(this.value)">
              Corporativo CS</span></label></td>
      </tr>
      <tr bgcolor="f7f7f7">
        <td colspan="5" height="22" valign="middle" class="exibir">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <label><span class="style4">
            <input type="radio" name="frmResp" value="3" <cfif session.e01.frmresp is '3'>checked</cfif>onclick="exibirValor(this.value)">
              Solucionado</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="10" <cfif Session.E01.frmResp is '10'>checked</cfif> onClick="exibirArea(this.value)">
              Ponto Suspenso</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="13" <cfif Session.E01.frmResp is '13'>checked</cfif>>
              Orientação Cancelada</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="12" <cfif Session.E01.frmResp is '12'>checked</cfif>>
              Ponto Improcedente</span></label></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr bgcolor="f7f7f7">
        <td rowspan="2" class="exibir"><div id="dData">Data de Previs&atilde;o da Solu&ccedil;&atilde;o:&nbsp;&nbsp;
                <input name="cbData" value="<cfoutput>#Session.E01.cbdata#</cfoutput>" class="form" type="text" size="12" onKeyDown="Mascara_Data(this)">
        </div></td>
        <td colspan="2" valign="middle" class="exibir"><div id="dArea">Selecione a &aacute;rea:
          <select name="cbArea" class="form">
                  <option value="">---</option>
                  <cfoutput query="qArea">
                    <option value="#Ars_Codigo#" <cfif Session.E01.modalidade is Ars_Codigo>selected</cfif>>#Ars_Sigla#</option>
                  </cfoutput>
                </select>
        </div></td>
        <cfoutput>
          <td rowspan="2" class="exibir">Valor Recuperado:&nbsp;&nbsp;
              <input name="VLRecuperado" value="#trim(Session.E01.VLRecuperado)#" class="form" type="text" size="20"></td>
        </cfoutput> </tr>
      <tr bgcolor="f7f7f7">
        <td colspan="2" valign="middle" class="exibir"><div id="dAreaCS">Selecione a &aacute;rea:
          <select name="cbAreaCS" class="form">
            <option value="">---</option>
            <cfoutput query="qAreaCS">
              <option value="#Ars_Codigo#" <cfif Session.E01.modalidade is Ars_Codigo>selected</cfif>>#Ars_Sigla#</option>
            </cfoutput>
          </select></div></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td bgcolor="eeeeee" align="center"><span class="titulos">Opini&atilde;o da Equipe de Controle Interno:</span></td>
        <td colspan="4" bgcolor="f7f7f7"><textarea name="observacao" cols="200" rows="25" nome="Observacao" vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#Session.E01.observacao#</cfoutput></textarea></td>
      </tr>
      <tr>
        <td colspan="3" class="exibir" bgcolor="#eeeeee"><strong>ANEXOS</strong></td>
        <td colspan="2" bgcolor="#eeeeee" class="exibir"></td>
      </tr>
      <tr>
        <td bgcolor="#eeeeee" class="exibir"><strong>Arquivo:</strong></td>
        <td bgcolor="#eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td bgcolor="#eeeeee" class="exibir"><input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar"></td>
        <td colspan="2" bgcolor="#eeeeee" class="exibir">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <cfloop query= "qAnexos">
        <cfif FileExists(qAnexos.Ane_Caminho)>
          <tr>
            <td colspan="3" bgcolor="eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td width="73" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
            <td bgcolor="eeeeee"><cfoutput>
              <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#">
            </cfoutput></td>
          </tr>
        </cfif>
      </cfloop>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <cfelse>
      <!--- Caso não existir dados na sessão, exibir campos vazios --->
      <tr bgcolor="f7f7f7">
        <td colspan="5" valign="middle" class="exibir">Foi aberto processo disciplinar?&nbsp;&nbsp;
            <select name="abertura" class="form">
              <option <cfif trim(qResposta.Pos_Abertura) eq "Nao"> selected</cfif> value="Nao">Não</option>
              <option <cfif trim(qResposta.Pos_Abertura) eq "Sim"> selected</cfif> value="Sim">Sim</option>
            </select>
            <cfif qResposta.Pos_Processo eq ''>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Processo:&nbsp;&nbsp;
              <input name="processo" class="form" type="text" size="11" onKeyPress="Mascara_Processo(this)" maxlength="11">
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              Modalidade:&nbsp;&nbsp;
              <select name="modalidade" class="form">
                <option value="">---</option>
                <option value="Apuracao_Direta">Apuração Direta</option>
                <option value="Sindicancia_Sumaria">Sindicância Sumária</option>
              </select>
              &nbsp;
              <cfelse>
              <cfset proc = qResposta.Pos_Processo>
              <cfset processo = Left(proc,2) & '.' & Mid(proc,3,5) & '/' & Right(proc,2)>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Processo:&nbsp;&nbsp;
              <input name="processo" class="form" type="text" size="11" value="<cfoutput>#processo#</cfoutput>" maxlength="11" onKeyPress="Mascara_Processo(this)">
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              Modalidade:&nbsp;&nbsp;
              <select name="modalidade" class="form">
                <option <cfif trim(qResposta.Pos_Tipo_Processo) eq ""> selected</cfif> value="">---</option>
                <option <cfif trim(qResposta.Pos_Tipo_Processo) eq "Apuracao_Direta"> selected</cfif> value="Apuracao_Direta">Apuração Direta</option>
                <option <cfif trim(qResposta.Pos_Tipo_Processo) eq "Sindicancia_Sumaria"> selected</cfif> value="Sindicancia_Sumaria">Sindicância Sumária</option>
              </select>
            </cfif>        </td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr bgcolor="f7f7f7">
        <td colspan="5" height="22" valign="middle" class="exibir">Situa&ccedil;&atilde;o:&nbsp;&nbsp;
            <label><span class="style4">
            <input name="frmResp" type="radio" value="2" onClick="exibirData(this.value)">
              Pendente Unidade</span></label>
            <label><span class="style4">
            <input name="frmResp" type="radio" value="4" onClick="exibirData(this.value)">
              Pendente de Órgão Subordinador</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="5" onClick="exibirArea(this.value);exibirData(this.value)">
              Pendente de Área</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="8" onClick="exibirData(this.value)">
              Corporativo SE</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="9" onClick="exibirAreaCS(this.value)">
              Corporativo CS</span></label></td>
      </tr>
      <tr bgcolor="f7f7f7">
        <td colspan="5" height="22" valign="middle" class="exibir">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <!--- <label><span class="style4">
            <input type="radio" name="frmResp" value="3" onClick="exibirValor(this.value)">
              Solucionado</span></label> --->
            <label><span class="style4">
            <input type="radio" name="frmResp" value="10" onClick="exibirArea(this.value)">
              Ponto Suspenso</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="13">
              Orientação Cancelada</span></label>
            <label><span class="style4">
            <input type="radio" name="frmResp" value="12">
              Ponto Improcedente</span></label></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr bgcolor="f7f7f7">
        <td colspan="2" rowspan="2" class="exibir"><div id="dData">Data de Previs&atilde;o da Solu&ccedil;&atilde;o:&nbsp;&nbsp;
                <input name="cbData" class="form" type="text" size="12" onKeyDown="Mascara_Data(this)">
        </div></td>
        <td  valign="middle" class="exibir"><div id="dArea">Selecione a &aacute;rea:
          <select name="cbArea" class="form">
                  <option selected="selected" value="">---</option>
                  <cfoutput query="qArea">
                    <option value="#Ars_Codigo#">#Ars_Sigla#</option>
                  </cfoutput>
                </select>
        </div></td>
        <!--- <cfif qResposta.Pos_VLRecuperado eq ''>
          <td colspan="2" rowspan="2" class="exibir"><div id="dValor">Valor Recuperado:&nbsp;&nbsp;
                  <input name="VLRecuperado" class="form" type="text" size="20">
          </div></td>
          <cfelse>
          <cfoutput>
            <td colspan="2" rowspan="2" class="exibir">Valor Recuperado:&nbsp;&nbsp;
                <input name="VLRecuperado" value="#trim(moeda(qResposta.Pos_VLRecuperado))#" class="form" type="text" size="20"></td>
          </cfoutput>
        </cfif> --->
      </tr>
      <tr bgcolor="f7f7f7">
        <td  valign="middle" class="exibir"><div id="dAreaCS">Selecione a &aacute;rea:
          <select name="cbAreaCS" class="form">
            <option selected="selected" value="">---</option>
            <cfoutput query="qAreaCS">
              <option value="#Ars_Codigo#">#Ars_Sigla#</option>
            </cfoutput>
          </select></div></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td bgcolor="eeeeee" align="center"><span class="titulos">Opini&atilde;o da Equipe de Controle Interno:</span></td>
        <td colspan="4" bgcolor="f7f7f7"><textarea name="observacao" cols="200" rows="25" nome="Observação" vazio="false" wrap="VIRTUAL" class="form" id="observacao"></textarea></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="3" class="exibir" bgcolor="#eeeeee"><strong>ANEXOS</strong></td>
        <td colspan="2" bgcolor="#eeeeee" class="exibir"></td>
      </tr>
      <tr>
        <td bgcolor="eeeeee" class="exibir"><strong>Arquivo:</strong></td>
        <td colspan="3" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td bgcolor="eeeeee" class="exibir"><input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar"></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <cfloop query= "qAnexos">
        <cfif FileExists(qAnexos.Ane_Caminho)>
          <tr>
            <td colspan="3" bgcolor="eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td width="73" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
            <td bgcolor="eeeeee"><cfoutput>
              <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.anexo.value='#qAnexos.Ane_Codigo#'" value="Excluir">
            </cfoutput></td>
          </tr>
        </cfif>
      </cfloop>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
    </cfif>
    <tr>
      <td colspan="5" align="center" bgcolor="eeeeee"><div align="center"><cfoutput>
        <input name="button" type="button" class="botao" onClick="window.open('itens_controle_respostas.cfm?ninsp=#url.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&SE=#url.SE#&cktipo=#url.cktipo#','_self')" value="Voltar">
      </cfoutput> &nbsp;&nbsp;&nbsp;&nbsp;
        <input name="Submit" type="submit" class="botao" value="Salvar" onClick="document.form1.acao.value='Salvar2';">
      </div></td>
    </tr>
    <tr>
      <td colspan="5" bgcolor="eeeeee">&nbsp;</td>
    </tr>
    <!--- </table> --->
    <input type="hidden" name="MM_UpdateRecord" value="form1">
    <input type="hidden" name="salvar_anexar" value="">
  </form>
  <!--- Fim Área de conteúdo --->
  <!---   </tr> --->
</table>
</body>
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