<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>    
<cfset Session.E01.observacao = ''>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Lotacao from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfquery name="rsArea" datasource="#dsn_inspecao#">
	 SELECT Ars_Codigo, Ars_Descricao FROM Areas WHERE Ars_Codigo = '#qAcesso.Usu_Lotacao#'
</cfquery> 

<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'SUBORDINADORREGIONAL' or Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'INSPETORES'>

<!---  <cftry>   --->

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

<cfset evento = 'document.form1.observacao.focus();'>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
    
<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">

	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.Reop" default="#Form.Reop#">
	<cfparam name="diasdecor" default="#Form.diasdecor#">
	<cfparam name="URL.sfrmPosArea" default="#Form.sfrmPosArea#">
	<cfparam name="URL.sfrmPosNomeArea" default="#form.sfrmPosNomeArea#">
	<cfparam name="URL.sfrmTipoUnidade" default="#Form.sfrmTipoUnidade#">
    <cfparam name="URL.dtfim" default="#form.dtfim#">
	<cfparam name="URL.dtinic" default="#form.dtinic#"> 

	<cfparam name="URL.ckTipo" default="form.ckTipo">
<cfelse>
	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="0">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.DtInic" default="0">
	<cfparam name="URL.dtFim" default="0">
	<cfparam name="URL.Reop" default="">
	<cfparam name="URL.ckTipo" default="">
	<cfparam name="URL.SE" default="">
    <cfparam name="URL.sfrmPosArea" default="">
    <cfparam name="URL.sfrmPosNomeArea" default="">
    <cfparam name="URL.sfrmTipoUnidade" default="">
	<cfparam name="URL.dtfim" default="0">
    
</cfif>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
SELECT RIP_NumInspecao, 
RIP_Unidade, 
RIP_NumGrupo, 
RIP_NumItem, 
RIP_Comentario, 
RIP_Recomendacoes, 
INP_DtInicInspecao, 
INP_Responsavel, 
Rep_Codigo, 
Itn_Descricao, 
Itn_TipoUnidade, 
Itn_ImpactarTipos,
Itn_PTC_Seq,
Grp_Descricao,
Und_TipoUnidade,
RIP_Valor, 
RIP_Caractvlr, 
RIP_Falta, 
RIP_Sobra, 
RIP_EmRisco, 
RIP_ReincInspecao, 
RIP_ReincGrupo, 
RIP_ReincItem,
TNC_ClassifInicio, 
TNC_ClassifAtual
FROM (((Resultado_Inspecao 
INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)) 
INNER JOIN (Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop) ON INP_Unidade = Und_Codigo) 
INNER JOIN Grupos_Verificacao ON RIP_NumGrupo = Grp_Codigo) 
INNER JOIN Itens_Verificacao ON (Itn_NumItem = RIP_NumItem) AND (Grp_Codigo = Itn_NumGrupo) and Itn_Ano = Grp_Ano
AND convert(char(4),RIP_Ano) = Itn_Ano and Itn_TipoUnidade = Und_TipoUnidade AND INP_Modalidade = Itn_Modalidade
left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
WHERE RIP_NumInspecao ='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
</cfquery>
<!--- <cfoutput>qual o tipo?: #rsItem.Itn_TipoUnidade#</cfoutput> --->
<cfquery name="rsTPUnid" datasource="#dsn_inspecao#">
     SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#unid#'
</cfquery>

<cfquery name="rsPonto" datasource="#dsn_inspecao#">
	SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (6,19)
</cfquery>


<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
</cfquery>

<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
  SELECT INP_Responsavel
  FROM Inspecao
  WHERE (INP_NumInspecao = '#URL.Ninsp#')
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT Inspetor_Inspecao.IPT_MatricInspetor, Funcionarios.Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric AND
  Inspetor_Inspecao.IPT_MatricInspetor = Funcionarios.Fun_Matric
  WHERE (IPT_NumInspecao = '#URL.Ninsp#')
</cfquery>
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
  <cfset strIDGestor = #URL.Unid#>
  <cfset strNomeGestor = #rsMod.Und_Descricao#>
  <cfset Gestor = '#rsMod.Und_Descricao#'>

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
		<cfoutput>
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
		</cfoutput>
	<!--- ===================== --->
	
  	<cfquery datasource="#dsn_inspecao#">
	   UPDATE ParecerUnidade SET Pos_Situacao_Resp = #FORM.frmResp#
		<cfswitch expression="#Form.frmResp#"> 
		<cfcase value=6>
          , Pos_Area = '#Form.sfrmPosArea#'
		  , Pos_NomeArea = '#Form.sfrmPosNomeArea#' 
		  , Pos_Situacao = 'RA'
		  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
		  <cfset Gestor = 'SGCIN'>
		  <cfset situacao = 'RESPOSTA DA AREA'>
		  <cfset strIDGestor = #Form.sfrmPosArea#>
          <cfset strNomeGestor = #Form.sfrmPosNomeArea#>
		</cfcase>
		
		<cfcase value=19>
          , Pos_Area = '#Form.sfrmPosArea#'
		  , Pos_NomeArea = '#Form.sfrmPosNomeArea#' 
		  , Pos_Situacao = 'TA'
		  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
		  <cfset Gestor = 'SGCIN'>
		  <cfset situacao = 'TRATAMENTO DA AREA'>
		  <cfset strIDGestor = #Form.sfrmPosArea#>
          <cfset strNomeGestor = #Form.sfrmPosNomeArea#>		  
		</cfcase>	
	  </cfswitch>
	  , Pos_DtPosic=#createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
	  , Pos_NomeResp='#CGI.REMOTE_USER#'  
	  , Pos_username = '#CGI.REMOTE_USER#'
	  , Pos_Sit_Resp_Antes = #form.scodresp#
	  <cfset Encaminhamento = 'Opinião do Subordinador Regional'>
	  <cfset aux_obs = "">
	  , Pos_Parecer=
		<cfset aux_obs = Trim(FORM.observacao)>
		<cfset aux_obs = Replace(aux_obs,'"','','All')>
		<cfset aux_obs = Replace(aux_obs,"'","","All")>
		<cfset aux_obs = Replace(aux_obs,'*','','All')>
		<cfset aux_obs = Replace(aux_obs,'>','','All')>
		<!---	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
				 <cfset aux_obs = Replace(aux_obs,'%','','All')> --->
		<cfset pos_aux = trim(Form.H_obs) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento) & CHR(13) & CHR(13) & 'À(o) ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	  '#pos_aux#'
	   WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
    </cfquery>
 <!--- Inserindo dados dados na tabela Andamento --->
	<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
	<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
	<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>
	 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento)  & CHR(13) & CHR(13) & 'À(o) ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	 <cfquery datasource="#dsn_inspecao#">
		insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Area, And_HrPosic, And_Parecer) 
		values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', '#FORM.frmResp#', '#qAcesso.Usu_Lotacao#', '#hhmmssdc#', '#and_obs#')
	 </cfquery>
	 
<!--- Condição para itens LEVE ENCERRADO --->

		<cfif form.encerrarSN eq 'S'>
<!---
		  <cfif ucase(Form.PosClassificacaoPonto) eq 'LEVE'>
			  <cfquery name="rsObserv" datasource="#dsn_inspecao#">
					  SELECT Pos_Parecer
					  FROM ParecerUnidade 
					  WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
			  </cfquery>
			<cfset pos_aux = trim(rsObserv.Pos_Parecer) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) CS/DIGOV/DCINT' & CHR(13) & CHR(13) & '   A partir da adoção de metodologia que classifica os itens avaliados como Não Conformes em GRAVE, MEDIANO ou LEVE, foi estabelecido pelo Departamento de Controle Interno (DCINT) que o acompanhamento da' & CHR(13) & 'regularização será realizado pelo Controle Interno somente para os itens de relevância GRAVE e MEDIANO.' & CHR(13) & '   Em decorrência disso, este item teve seu acompanhamento ENCERRADO após o registro da manifestação do gestor da unidade avaliada, uma vez que apresenta relevância LEVE.' & CHR(13) & CHR(13) & '   IMPORTANTE:' & CHR(13) & '   O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor da unidade avaliada de adotar ações imediatas para regularizar a Não Conformidade registrada.' & CHR(13) & '   Em caso de reincidência dessa Não Conformidade em avaliações de controles futuras, o item será considerado como MEDIANO e passará a ter acompanhamento até a sua regularização.' & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: SEC AVAL CONT INTERNO/SGCIN ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
			   <cfquery datasource="#dsn_inspecao#">
					UPDATE ParecerUnidade SET Pos_Situacao_Resp = 29
					, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
					, Pos_DtPrev_Solucao = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))# 
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
					values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', 29, '#qAcesso.Usu_Lotacao#', '#hhmmssdc#', '#and_obs#')
				 </cfquery>
		  </cfif>
--->
	 </cfif> 
	 <cflocation url="itens_subordinador_respostas_pendentes_subordinador_regional.cfm?ckTipo=#URL.ckTipo#&dtinicial=&dtfinal=">

</cfif>

 <!--- FIM Condição para itens LEVE ENCERRADO--->

 <cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Descricao, Und_CodReop, UND_Centraliza
  FROM Unidades
  WHERE Unidades.Und_Codigo = '#URL.Unid#'
</cfquery> 

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_Area, Pos_NomeArea, Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, 
  Pos_Situacao, Pos_Parecer, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_OpcaoBaixa, SEI_NumSEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
  FROM ParecerUnidade
  LEFT JOIN Inspecao_SEI ON SEI_Inspecao = Pos_Inspecao and SEI_Unidade = Pos_Unidade and SEI_Grupo =Pos_NumGrupo and SEI_Item = Pos_NumItem
  WHERE Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem# AND Pos_Unidade = '#unid#' AND Pos_Inspecao = '#ninsp#'
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>
<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
<cfinclude template="mm_menu.js">
//==================================
//Função que abre uma página em Popup
function popupPage() {
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_unidades_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}

//==========================
function dtprazo(x){

	 if (x == 2 || x == 20) 
	 {
	   document.form1.cbData.value = document.form1.dttratam.value;
	 } 

	if (x == 15 || x == 16 || x == 18 || x == 19  || x == 23 )

	 {
	   document.form1.cbData.value = document.form1.dttratam.value;
	  } 

	 if( x == 6 || x == 7) 
	 {
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
  var sit = document.form1.frmResp.value;  
  if (strmanifesto == '')
	  {
	   alert('Caro Usuário, falta o seu Posicionamento no campo Manifestar-se!');
	   return false;
	  }
 
   if (strmanifesto.length < 100)
	   {
	   alert('Caro Usuário, Sua manisfestação deverá conter no mínimo 100(cem) caracteres');
	   return false;
	   }
	document.form1.cbData.disabled = false;
	var dtprevdig = document.form1.cbData.value;	    
	if (dtprevdig.length != 10)
		{
		alert('Preencher campo: Data da Previsão da Solução ex. DD/MM/AAAA');
		dtprazo(sit);
		return false;
		}	
    if (sit == 'N' || sit == '')
		 {
	   alert('Caro Usuário, Selecione a Situação do seu Manifestar-se!');
	   return false;
		 }
	 <!--- formato AAAAMMDD --->
	 var dt_hoje_yyyymmdd = document.form1.dthojeyyyymmdd.value;
	 var And_dtposic_fut = document.form1.frmDT30dias_Fut.value;

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
//========================================================================================
	 if ((sit == 15 || sit == 16 || sit == 18 || sit == 19 || sit == 23) && (dtprevdig_yyyymmdd < document.form1.dtdezddtrat.value))
		 {
		  var auxdtedit = document.form1.dtdezddtrat.value;
		  auxdtedit = auxdtedit.substring(6,8) + '/' + auxdtedit.substring(4,6) + '/' + auxdtedit.substring(0,4)
		  alert("Para Tratamento a Data de Previsão está menor que os 10(dez) dias informados: " + auxdtedit)
		  //dtprazo(sit);
		 // exibe(sit);
		  return false;
		 }	
//==================================================================================		 
	 if (dtprevdig_yyyymmdd > And_dtposic_fut && sit == 19)
	 {
	alert( 'A data da Previsão da Solução informada ultrapassa ao prazo máximo permitido: ' + And_dtposic_fut.substr(6,2) + '/' + And_dtposic_fut.substr(4,2) + '/' + And_dtposic_fut.substr(0,4) + '.')
	dtprazo(sit);
	return false;
	 }  
	  	
//	  alert(sit);
	  if (sit == 2) {var auxcam = '\n\nPENDENTE DE UNIDADE\n\n- Essa opção DEVOLVE o item à unidade para registro de resposta ou complementação'};
 	  if (sit == 6) {var auxcam = '\n\nRESPOSTA DA AREA\n\n- Essa opção RESPONDE o item e o encaminha para Equipe de Controle Interno da Regional (SGCIN)'};
	  if (sit == 20) {var auxcam = '\n\nPENDENTE DE AGF\n\n- Essa opção DEVOLVE o item à unidade para registro de resposta ou complementação'};
	  if (sit == 19) {var auxcam = '\n\nTRATAMENTO DA ÁREA\n\n - Essa opção MANTÉM o item ao Subordinador Regional para desenvolvimento de ação que necessita de maior prazo da regularização ou resposta.\n Nesse caso deve indicar o prazo necessário no campo Data de Previsão da Solução.\n Até essa data sua resposta deverá ser complementada'};
	
	 if (confirm ('            Atenção! ' + auxcam))
	 {  
	  if (sit == 6 && document.form1.PosClassificacaoPonto.value == 'LEVE' && document.form1.undtipounidade.value != 12 && document.form1.undtipounidade.value != 16) {
			  var auxcam = 'O item respondido possui classificação "LEVE". Em decorrência disso está sendo encerrado o acompanhamento pelo Controle Interno.\n\nATENÇÃO: O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor de providenciar a sua regularização.\n\nEm Avaliações de Controle futuras o item é passível de ser reavaliado. Caso seja constatada nova não conformidade, será considerada REINCIDÊNCIA, sendo acompanhada a sua regularização pelo Controle Interno.'
			  alert(auxcam);
		}
		 document.form1.cbData.disabled = false;
		 return true;
		}
	else
	   {
         if (sit != 19) {document.form1.cbData.disabled = true;}
		 return false;
	   }	
	}
//return false;
}
</script>
</head>
<body onLoad="dtprazo(document.form1.frmResp.value)">
<cfset form.acao = ''>
<cfinclude template="cabecalho.cfm">
<table width="77%" height="60%" align="center">
<tr>
	  <td width="74%" valign="top">
<!--- Área de conteúdo   --->
    <cfoutput>
	<form name="form1" method="post" onSubmit="return validaForm()" enctype="multipart/form-data" action="itens_subordinador_respostas_pendentes_subordinador_regional1.cfm?ckTipo=#URL.ckTipo#">
    </cfoutput>
        <div align="right"><table width="74%" align="center">
          <tr>
              <td colspan="9"><p align="center" class="titulo1"><strong> PONTO DE CONTROLE INTERNO</strong>
                      <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
                      <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
                      <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
                      <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
                      <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
					  <input name="diasdecor" type="hidden" id="diasdecor" value="<cfoutput>#diasdecor#</cfoutput>">
					  <input name="Situacao" type="hidden" id="Situacao" value="<cfoutput>#Situacao#</cfoutput>">
					  <input type="hidden" name="acao" value="">
                      <input type="hidden" name="anexo" value="">
					  <input type="hidden" name="vCodigo" value="">
					  <input type="hidden" name="sfrmPosArea" id="sfrmPosArea" value="<cfoutput>#qResposta.Pos_Area#</cfoutput>">
					  <input type="hidden" name="sfrmPosNomeArea" id="sfrmPosNomeArea" value="<cfoutput>#qResposta.Pos_NomeArea#</cfoutput>">
					  <input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="<cfoutput>#rsItem.Itn_TipoUnidade#</cfoutput>">
				      <input name="dtinic" type="hidden" id="dtinic" value="<cfoutput>#dtinic#</cfoutput>">
                      <input name="dtfim" type="hidden" id="dtfim" value="<cfoutput>#dtfim#</cfoutput>">
				      <input name="cktipo" type="hidden" id="cktipo" value="<cfoutput>#ckTipo#</cfoutput>">  
              </p></td>
          </tr>
            
          <cfif ckTipo eq 4>  
              <tr class="exibir">
                <td colspan="9">&nbsp;</td>
              </tr>
              <tr><td colspan="9" align="center"> <button onClick="window.close()" class="botao">Fechar</button></td></tr>
          </cfif>  
            
		  <tr class="exibir">
            <td colspan="9">&nbsp;</td>
          </tr>

          <tr class="exibir">
            <td width="128" bgcolor="eeeeee">Unidade </td>
            <td colspan="3" bgcolor="eeeeee"><cfoutput><strong>#rsMod.Und_Descricao#</strong></cfoutput></td>
            <td colspan="2" bgcolor="eeeeee">Respons&aacute;vel</td>
            <td width="288" colspan="3" bgcolor="eeeeee"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td width="217" bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="7" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>- </cfif></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Nº Relatório</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="8" bgcolor="eeeeee"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Grupo</td>
            <td width="217" bgcolor="eeeeee"><cfoutput>#URL.Ngrup#</cfoutput></td>
            <td colspan="6" bgcolor="eeeeee"><cfoutput><strong>#rsItem.Grp_Descricao#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td bgcolor="eeeeee"><cfoutput>#URL.Nitem#</cfoutput></td>
            <td colspan="7" bgcolor="eeeeee"><cfoutput><strong>#rsItem.Itn_Descricao#</strong></cfoutput></td>
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
			<td colspan="7" bgcolor="eeeeee">Nº Avaliação:
				<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Grupo:
			<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Item:
			<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" onKeyPress="numericos(this.value)">
			</strong>		  
			</td>
	</tr>
	</cfif> 
	<cfset tipoimpacto = 'NÃO QUANTIFICADO'>
	<cfset encerrarSN = 'N'>
	<cfset impactofin = 'N'>
	<cfif listFind(#rsItem.Itn_PTC_Seq#,'10')>
	  	<cfset impactofin = 'S'>
		<cfset tipoimpacto = 'QUANTIFICADO'>
	</cfif>		
	<cfset falta = lscurrencyformat(rsItem.RIP_Falta,'Local')>
	<cfset sobra = lscurrencyformat(rsItem.RIP_Sobra,'Local')>
	<cfset emrisco = lscurrencyformat(rsItem.RIP_EmRisco,'Local')>
	<cfset fator = 0>
	<cfset somafaltasobrarisco = (rsItem.RIP_Falta + rsItem.RIP_Sobra + rsItem.RIP_EmRisco)>	   
	<cfset encerrarSN = 'N'>
	<cfif reincSN neq 'S' and rsItem.Und_TipoUnidade neq 12 and rsItem.Und_TipoUnidade neq 16>
		<cfif impactofin eq 'N'>
			<!--- Não tem impacto financeiro --->
			<cfset encerrarSN = 'S'>
		<cfelse>
			<cfset somafaltasobrarisco = numberformat(#somafaltasobrarisco#,9999999999.99)>
			<!--- Tem impacto financeiro --->
			<cfquery name="rsRelev" datasource="#dsn_inspecao#">
				SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
				FROM ValorRelevancia
				WHERE VLR_Ano = '#right(ninsp,4)#'
			</cfquery>
			<cfloop query="rsRelev">
				<cfset fxini = numberformat(rsRelev.VLR_FaixaInicial,9999999999.99)>
				<cfset fxfim = numberformat(rsRelev.VLR_FaixaFinal,9999999999.99)>
				<cfif fxini eq 0.01 and somafaltasobrarisco lte fxfim and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator>
				</cfif>
				<cfif (fxini neq 0.01 and fxfim neq 0.00) and (somafaltasobrarisco gt fxini and somafaltasobrarisco lte fxfim) and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator>
				</cfif>					
				<cfif fxfim eq 0.00 and somafaltasobrarisco gte fxini and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator> 
				</cfif>
			</cfloop>				
			<cfif fator eq 1>
				<cfset encerrarSN = 'S'>
			</cfif>
		</cfif>
	</cfif>		
 	<tr class="exibir">
		<td bgcolor="eeeeee">Potencial Valor</td>
		<td colspan="5" bgcolor="eeeeee">
			<table width="100%" border="0" cellspacing="0" bgcolor="eeeeee">
			  <tr class="exibir"><strong>
				  <td width="30%" bgcolor="eeeeee"><strong>Estimado a Recuperar (R$):&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" readonly></strong></td>
				  <td width="35%" bgcolor="eeeeee"><strong>Estimado Não Planejado/Extrapolado/Sobra (R$):&nbsp;<input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" readonly></strong></td>
				  <td width="35%" bgcolor="eeeeee"><strong>Estimado em Risco ou Envolvido (R$):&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" readonly></strong></td>
			  </tr>
			</table>		  
		</td>
    </tr>
	</cfoutput>

          <tr class="exibir">
            <td colspan="8" bgcolor="eeeeee"></td>
          </tr>
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir">
			<span class="titulos">Situação Encontrada:</span>
			</td>
			<cfset melhoria = replace('#rsItem.RIP_Comentario#','; ' ,';','all')>	
            <td colspan="8" bgcolor="eeeeee"><span class="exibir">
            <textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#melhoria#</cfoutput></textarea></span></td>
		  </tr>
		 <tr>
            <td align="center" valign="middle" bgcolor="eeeeee"><span class="exibir">
			<span class="titulos">Orientações:</span></span>
			</td>
			<cfset RIPRecomendacoes = replace('#rsItem.RIP_Recomendacoes#','; ' ,';','all')>	
            <td colspan="8" bgcolor="eeeeee"><span class="exibir">
              <textarea name="H_recom" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#RIPRecomendacoes#</cfoutput></textarea></span></td>
		  </tr>

          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Histórico:</span> <span class="titulos">Manifestação/Análise do Controle Interno</span><span class="titulos">:</span></td>
            <td colspan="8" bgcolor="eeeeee"><textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" value="#Session.E01.h_obs#" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></td>
          </tr>
         <cfif ckTipo neq 4>
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee"><span class="exibir"><span class="titulos">Manifestar-se:</span></span></td>
            <td colspan="8"><span class="exibir"><textarea name="observacao" cols="200" rows="25" nome="Observação" vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#Session.E01.observacao#</cfoutput></textarea>
            </span></td>
          </tr>
        </cfif>

		<cfif IsDefined('url.Situacao') and '#url.situacao#' eq '27'>
    
          	<cfif '#trim(qResposta.Pos_OpcaoBaixa)#' neq "">
              <tr >	
			    <td colspan="1" bgcolor="eeeeee"></td>
			    <cfset opcao =''>
			    <cfif '#trim(qResposta.Pos_OpcaoBaixa)#' eq '1'><cfset opcao = 'Penalidade Aplicada'></cfif>
                <cfif '#trim(qResposta.Pos_OpcaoBaixa)#' eq '2'><cfset opcao = 'Defesa Acatada'></cfif>
				<cfif '#trim(qResposta.Pos_OpcaoBaixa)#' eq '3'><cfset opcao = 'Outros'></cfif>
				 
				<td width="400" align="left" valign="middle" bgcolor="white">
				<span class="titulos"  style="font-size:12px;color:gray;">Opção de Baixa: </span>
				<span class="titulos"  style="font-size:14px;"><CFOUTPUT>#opcao#</CFOUTPUT></span>          	    </td>  
                <cfif '#trim(qResposta.SEI_NumSEI)#' neq "" >
					<cfset numSei='#trim(qResposta.SEI_NumSEI)#'>
					<cfset numSei=left(numSei,5) & '.' & mid(numSei,6,6) & '/' & mid(numSei,12,4) & '-' & right(numSei,2)>
				<cfelse>
			    	<cfset numSei='Não Informado'>
				</cfif>	
				<td width="400" align="left" bgcolor="white">
					<span class="titulos"  style="font-size:12px;color:gray;">N° SEI: </span>
					<span class="titulos" style="font-size:14px"><CFOUTPUT>#numSei#</CFOUTPUT></span>				</td>
			  </tr>	  
            </cfif>
    

           <tr class="exibir">
            <td colspan="9" bgcolor="eeeeee"></td>
          </tr>
      </cfif>


		 <tr>
			<td align="center" valign="middle" bgcolor="#eeeeee" class="exibir"><strong>ANEXOS</strong></td>
			<td colspan="7" bgcolor="#eeeeee" class="exibir">&nbsp;</td>
        </tr>
      <cfif ckTipo neq 4>   
	  
	  <cfset resp = #qResposta.Pos_Situacao_Resp#>
       
        <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><strong>Arquivo:</strong></td>
        <td colspan="4" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td colspan="4" bgcolor="eeeeee" class="exibir">
		<cfif (resp neq 21)>
		  <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar">
		<cfelse>
		  <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" disabled>
		</cfif>		</td>
      </tr>
	  <cfoutput>
		<cfset posdtprevsolucao = CreateDate(year(now()),month(now()),day(now()))>
		<cfset posdtprevsolucao = dateformat(qResposta.Pos_DtPrev_Solucao,"YYYYMMDD")>
		<cfset dtbase = CreateDate(year(now()),month(now()),day(now()))>
		<cfset dtrespos = CreateDate(year(now()),month(now()),day(now()))>
		<cfset dttratam = CreateDate(year(now()),month(now()),day(now()))>
		<cfset dt30diasuteis = CreateDate(year(now()),month(now()),day(now()))>
		<cfobject component = "CFC/Dao" name = "dao">
		<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="VencidoPrazo_Andamento" NumeroDaInspecao="#ninsp#" 
			CodigoDaUnidade="#unid#" Grupo="#ngrup#" Item="#nitem#" MostraDump="no" RetornaQuantDias="yes" ApenasDiasUteis="yes" ListaDeStatusContabilizados="5,19">
			
<!---  --->	
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
			<cfif dtbase lte dateformat(now(),"YYYYMMDD") or encerrarSN eq 'S'>
			<!--- somente direito a responder --->
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 6)
				</cfquery>
			<cfelse>
				<!--- possui direitode tratamento e de resposta --->	
				<!--- Contar os possiveis dez dias uteis para tratamento --->	
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (6,19)
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
	
		<!---  --->
	  <tr>
	    <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
	    </tr>
	  <tr>
	    <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><strong>Situa&ccedil;&atilde;o:</strong></td>
	  <td colspan="8" bgcolor="eeeeee" class="exibir"><div align="left">
			  <select name="frmResp" class="exibir" id="frmResp" onChange="dtprazo(this.value)">
	            <cfif rsPonto.recordcount gt 0>
					<option value="" selected>---</option>
	                </cfif>
				<cfoutput query="rsPonto">
				  <option value="#STO_Codigo#">#trim(STO_Descricao)#</option>
				</cfoutput>
              </select>
                </div>			  </td>	 
         </tr>
		 <tr>
	    <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
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
            <td colspan="6" bgcolor="eeeeee" class="form"><cfoutput>#cl# - #ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td colspan="2" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
          </tr>
        </cfif>
      </cfloop>
         
         <tr>
            <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
         </tr><br><br>
 
		<!--- <cfif (qResposta.Pos_Situacao_Resp eq 4) or (qResposta.Pos_Situacao_Resp eq 7)> --->
  <cfoutput>
		
		<!--- <cfoutput>#dateformat(dtposicfut,"YYYYMMDD")#</cfoutput> --->
	<cfif qResposta.Pos_DtPrev_Solucao EQ "" OR dateformat(qResposta.Pos_DtPrev_Solucao,"YYYYMMDD") lt dateformat(now(),"YYYYMMDD")>
	  <cfset dtprevsol = dateformat(now(),"DD/MM/YYYY")>
	<cfelse>
	  <cfset dtprevsol = dateformat(qResposta.Pos_DtPrev_Solucao,"DD/MM/YYYY")>	  
	</cfif>
	   <cfset nCont = 1>
	   <cfset ContarSN = 'S'>
	   <cfset dezdiasfutrat = CreateDate(year(now()),month(now()),day(now()))>
	   <cfloop condition="nCont lte 9">
	   <cfset nCont = nCont + 1>
	   <cfset dezdiasfutrat = DateAdd( "d", 1, dezdiasfutrat)>
	   <cfset vDiaSem = DayOfWeek(dezdiasfutrat)>
	   <cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dezdiasfutrat#
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
	  <!--- fim --->
	  <!--- ===================== --->	
		</cfoutput>
         <tr>
            <td colspan="8" bgcolor="eeeeee" class="exibir"><div id="dData" class="titulos"><strong>Data de Previs&atilde;o da Solu&ccedil;&atilde;o:</strong>&nbsp;&nbsp;
	<input name="cbData" id="cbData" type="text" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" value="<cfoutput>#dateformat(now(),"dd/mm/yyyy")#</cfoutput>" readonly="yes">			</td>
         </tr>
</cfif>
        <br><br>
 <!---   </cfif> --->



<cfif ckTipo neq 4>    
          <tr bgcolor="eeeeee">
            <td colspan="4">
			  <div align="center">

  
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
   
              
        <cfoutput>
           <input name="button" type="button" class="botao" onClick="window.open('itens_subordinador_respostas_pendentes_subordinador_regional.cfm?ckTipo=#URL.ckTipo#&dtinicial=&dtfinal=','_self')" value="Voltar">
        </cfoutput>		</div></td>
	<cfset resp = qResposta.Pos_Situacao_Resp>
  
       <td colspan="4">
	     <div align="center">
	       <cfif (resp is 1 or resp is 6 or resp is 7 or resp is 17 or resp is 22 or resp is 18 or resp is 21 or resp is 3 or resp is 24 or resp is 9 or resp is 25 or resp is 26 or resp is 27 or resp is 28 or resp is 29 or resp is 30)>
	         <input name="Submit" type="submit" class="botao" value="Salvar" onClick="document.form1.acao.value='Salvar'" disabled>
	            <cfelse>
	         <input name="Submit" type="submit" class="botao" value="Salvar" onClick="document.form1.acao.value='Salvar'">
	          </cfif>
	         </div></td>
          </tr>  
   <cfelse>
        <tr><td colspan="9" align="center"><button onClick="window.close()" class="botao">Fechar</button></td></tr>
   </cfif>
        </table>
<cfoutput>		
	<input type="hidden" name="MM_UpdateRecord" value="form1">
	<input type="hidden" name="salvar_anexar" value="">
	<input name="exigedata" type="hidden" id="exigedata" value="N">
	<input type="hidden" name="frmSitResp_Banco" id="frmSitResp_Banco" value="#qResposta.Pos_Situacao_Resp#">
	<cfset SitResp = qResposta.Pos_Situacao_Resp>
	<input type="hidden" name="vPSitResp" id="vPSitResp" value="#qResposta.Pos_Situacao_Resp#">
	<input type="hidden" name="PosClassificacaoPonto" id="PosClassificacaoPonto" value="#trim(qResposta.Pos_ClassificacaoPonto)#"> 
	<input type="hidden" name="undtipounidade" id="undtipounidade" value="#trim(rsItem.Und_TipoUnidade)#">
	<input type="hidden" name="scodresp" id="scodresp" value="#qResposta.Pos_Situacao_Resp#">
	<input type="hidden" name="encerrarSN" id="encerrarSN" value="#encerrarSN#">
	<input name="somafaltasobrarisco" type="hidden" id="somafaltasobrarisco" value="#somafaltasobrarisco#">
	<input name="reincideSN" type="hidden" id="reincideSN" value="#reincSN#">	
</cfoutput>		 
	</form>
<!--- Fim Área de conteúdo --->
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
		width: 1200,
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
		width: 1200,
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
