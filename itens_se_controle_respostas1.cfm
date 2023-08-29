<cfprocessingdirective pageEncoding ="utf-8"/> 
<!--- <cfdump var="#form#">
<cfdump var="#url#">
<cfdump var="#session#"> --->

<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>  
<cfset Session.E01.observacao = ''>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_LotacaoNome from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'SUPERINTENDENTE'>

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

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">

<cfparam name="URL.Unid" default="#Form.Unid#">
<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
<cfparam name="URL.Nitem" default="#Form.Nitem#">
<cfparam name="URL.Desc" default="">
<cfparam name="URL.DGrup" default="">
<cfparam name="URL.numpag" default="0">
<cfparam name="URL.Reop" default="#Form.Reop#">
<cfparam name="URL.ckTipo" default="form.ckTipo">
<cfparam name="URL.dtfinal" default="#form.dtfinal#">
	<cfparam name="URL.dtinic" default="#form.dtinic#"> 

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
<cfparam name="URL.ckTipo" default="">
<cfparam name="URL.DtInic" default="0">
<cfparam name="URL.dtFinal" default="0">

</cfif>
<cfquery name="rsTPUnid" datasource="#dsn_inspecao#">
     SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#URL.unid#'
</cfquery>

<!--- <cfif #left(unid,2)# eq 50 or #left(unid,2)# eq 72>
	<cfquery name="rsPonto" datasource="#dsn_inspecao#">
		  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 7  or STO_Codigo = 16 or STO_Codigo = 20)
	</cfquery>
<cfelse> --->
<!--- <cfif rsTPUnid.Und_TipoUnidade is 12>
	<cfquery name="rsPonto" datasource="#dsn_inspecao#">
		  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 7  or STO_Codigo = 16 or STO_Codigo = 20)
	</cfquery>
<cfelse> --->
    <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 22 or STO_Codigo = 23)
	</cfquery>
<!--- </cfif>  --->

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Dir_Descricao, Dir_Codigo, Dir_Sigla
  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
 SELECT Pos_Situacao_Resp, 
 Pos_Parecer, 
 RIP_Recomendacoes, 
 RIP_Comentario, 
 RIP_Caractvlr, 
 RIP_Falta, 
 RIP_Sobra, 
 RIP_EmRisco, 
 RIP_Valor, 
 Dir_Descricao, 
 Dir_Codigo, 
 Pos_Area,
 Pos_NomeArea, 
 Pos_Processo, 
 Pos_Tipo_Processo, 
 Pos_Abertura, 
 Itn_Descricao, 
 Pos_VLRecuperado, 
 Pos_DtPrev_Solucao, 
 Pos_DtPosic, 
 DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, 
 Pos_SEI, 
 INP_DtInicInspecao, 
 Grp_Descricao, 
 Und_TipoUnidade,
 Pos_PontuacaoPonto,
 Pos_ClassificacaoPonto,
 RIP_ReincInspecao,
 RIP_ReincGrupo,
 RIP_ReincItem,
 TNC_ClassifInicio, 
 TNC_ClassifAtual 
 FROM  Inspecao 
 INNER JOIN (Diretoria 
 INNER JOIN ((Resultado_Inspecao 
 INNER JOIN ParecerUnidade 
 ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
 INNER JOIN Unidades 
 ON (Und_Codigo = Pos_Unidade) 
 INNER JOIN (Itens_Verificacao 
 INNER JOIN Grupos_Verificacao 
 ON Itn_NumGrupo = Grp_Codigo) 
 ON (Pos_NumGrupo = Itn_NumGrupo) AND (Pos_NumItem = Itn_NumItem)) 
 ON Dir_Codigo = RIP_CodDiretoria) 
 ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade) AND right([Pos_Inspecao], 4) = Itn_Ano 
 AND Itn_Ano = Grp_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
 left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
 WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
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
		<!--- Status: Resposta da SE --->
		 <cfcase value=22>
		  , Pos_Situacao = 'RO' 
		  , Pos_Area = '#rsItem.Pos_Area#' 
		  , Pos_NomeArea = '#rsItem.Pos_NomeArea#' 
		  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
		  , Pos_Sit_Resp_Antes = #form.scodresp#
		  <!--- <cfif Not rsCVCO.recordcount> --->
				<cfset Gestor = 'SGCIN'>
		  <!--- <cfelse>
		  		<cfset Gestor = '#rsCVCO.Ars_Sigla#'>
		  </cfif> --->
		  <cfset situacao = 'RESPOSTA DA SUPERINTENDÊNCIA ESTADUAL'>
		</cfcase> 
		<!--- Status: Tratamento pela SE --->
		<cfcase value=23>
		  , Pos_Area = '#rsItem.Pos_Area#' 
		  , Pos_NomeArea = '#rsItem.Pos_NomeArea#'
		  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
		  <cfset Gestor = '#qUsuario.Usu_LotacaoNome#'>
		  <cfset situacao = 'TRATAMENTO PELA SUPERINTENDÊNCIA ESTADUAL'>
		</cfcase>
	  </cfswitch>
	  , Pos_DtPosic = convert(char, getdate(), 102)
	  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
	  , Pos_NomeResp='#CGI.REMOTE_USER#'
	  , Pos_username = '#CGI.REMOTE_USER#'
	  <!--- <cfset Encaminhamento = ''> --->
	  <cfset aux_obs = "">
	  , Pos_Parecer=
		<cfset aux_obs = Trim(FORM.observacao)>
		<cfset aux_obs = Replace(aux_obs,'"','','All')>
		<cfset aux_obs = Replace(aux_obs,"'","","All")>
		<cfset aux_obs = Replace(aux_obs,'*','','All')>
		<cfset aux_obs = Replace(aux_obs,'>','','All')>
		<!---	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
				 <cfset aux_obs = Replace(aux_obs,'%','','All')> --->
		<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> '  <!--- & Trim(Encaminhamento) & CHR(13) & CHR(13) ---> & 'À(o)  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	  '#pos_aux#'
	   WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
    </cfquery>
 <!--- Inserindo dados dados na tabela Andamento --->
		 <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & Trim(Encaminhamento)  & CHR(13) & CHR(13) & 'À(o)  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & situacao & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_Apelido) & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	<cfquery datasource="#dsn_inspecao#">
			insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Area, And_HrPosic, And_Parecer) values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', convert(char, getdate(), 102), '#CGI.REMOTE_USER#', '#FORM.frmResp#', <!--- '#url.reop#' ---> '#qUsuario.Usu_Lotacao#', convert(char, getdate(), 108), '#and_obs#')
	</cfquery>

		<!--- Condição para itens LEVE ENCERRADO --->

	 <cfif (Form.frmResp eq 22 and rsItem.Und_TipoUnidade neq 12 and rsItem.Und_TipoUnidade neq 16)>
			
		<cfif ucase(Form.PosClassificacaoPonto) eq 'LEVE'>

			<!---<cfset situacao = 'RESPOSTA DA AREA'>---->
			<cfquery name="rsObserv" datasource="#dsn_inspecao#">
					SELECT Pos_Parecer
					FROM ParecerUnidade 
					WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
			</cfquery>
			<cfset pos_aux = trim(rsObserv.Pos_Parecer) & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) CS/DIGOV/DCINT' & CHR(13) & CHR(13) & '   A partir da adoção de metodologia que classifica os itens avaliados como Não Conformes em GRAVE, MEDIANO ou LEVE, foi estabelecido pelo Departamento de Controle Interno (DCINT) que o acompanhamento da' & CHR(13) & 'regularização será realizado pelo Controle Interno somente para os itens de relevância GRAVE e MEDIANO.' & CHR(13) & '   Em decorrência disso, este item teve seu acompanhamento ENCERRADO após o registro da manifestação do gestor da unidade avaliada, uma vez que apresenta relevância LEVE.' & CHR(13) & CHR(13) & '   IMPORTANTE:' & CHR(13) & '   O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor da unidade avaliada de adotar ações imediatas para regularizar a Não Conformidade registrada.' & CHR(13) & '   Em caso de reincidência dessa Não Conformidade em avaliações de controles futuras, o item será considerado como MEDIANO e passará a ter acompanhamento até a sua regularização.' & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: SEC AVAL CONT INTERNO/SGCIN ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
			 <cfquery datasource="#dsn_inspecao#">
				UPDATE ParecerUnidade SET Pos_Situacao_Resp = 29
				, Pos_DtPosic = convert(char, getdate(), 102)
				, Pos_DtPrev_Solucao = convert(char, getdate(), 102) 
	  			, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
	  			, Pos_NomeResp='#CGI.REMOTE_USER#'
	  			, Pos_username = '#CGI.REMOTE_USER#'
				, Pos_Situacao = 'EC'
				, Pos_Parecer = '#pos_aux#'
				, Pos_Sit_Resp_Antes = #form.scodresp#
				WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
			</cfquery> 
  <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Opinião do Controle Interno' & CHR(13) & CHR(13) & 'À(O) CS/DIGOV/DCINT' & CHR(13) & CHR(13) & '   A partir da adoção de metodologia que classifica os itens avaliados como Não Conformes em GRAVE, MEDIANO ou LEVE, foi estabelecido pelo Departamento de Controle Interno (DCINT) que o acompanhamento da' & CHR(13) & 'regularização será realizado pelo Controle Interno somente para os itens de relevância GRAVE e MEDIANO.' & CHR(13) & '   Em decorrência disso, este item teve seu acompanhamento ENCERRADO após o registro da manifestação do gestor da unidade avaliada, uma vez que apresenta relevância LEVE.' & CHR(13) & CHR(13) & '   IMPORTANTE:' & CHR(13) & '   O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor da unidade avaliada de adotar ações imediatas para regularizar a Não Conformidade registrada.' & CHR(13) & '   Em caso de reincidência dessa Não Conformidade em avaliações de controles futuras, o item será considerado como MEDIANO e passará a ter acompanhamento até a sua regularização.' & CHR(13) & CHR(13) & 'Situação: ENCERRADO' & CHR(13) & CHR(13) &  'Responsável: SEC AVAL CONT INTERNO/SGCIN ' & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
				
			 <cfquery datasource="#dsn_inspecao#">
				insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_Area, And_HrPosic, And_Parecer) values ('#FORM.ninsp#', '#FORM.unid#', '#FORM.ngrup#', '#FORM.nitem#', convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 29, '#qUsuario.Usu_Lotacao#','#TimeFormat(Now(),'HH:MM:SS')#.9', '#and_obs#')
			</cfquery> 
		</cfif>
	</cfif> 
	<!---  --->
	<cfset form.acao = "">
    <cflocation url="itens_se_controle_respostas.cfm?ckTipo=1"> 
</cfif>

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Unidades.Und_Descricao, Unidades.Und_CodReop
  FROM Unidades
  WHERE Unidades.Und_Codigo = '#URL.Unid#'
</cfquery>

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, Pos_DtPosic, Pos_DtPrev_Solucao, Pos_ClassificacaoPonto
  FROM ParecerUnidade
  WHERE Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem# AND Pos_Unidade = '#unid#' AND Pos_Inspecao = '#ninsp#'
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link href="css.css" rel="stylesheet" type="text/css">

<script type="text/javascript">

//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {

	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}
//================
function Mascara_Data(data)
{
	switch (data.value.length)
	{
		case 2:
		   if (data.value < 1 || data.value > 31) {
		      alert('Valor para o dia inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
		case 5:
			if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
		      alert('Valor para o Mês inválido!');
			  data.value = '';
		      event.returnValue = false;
			  break;
		    } else {
			  data.value += "/";
				break;
			}
	}
}
//======================
function dtprazo(x){
//alert('aqui');
if (x == 23) {
   document.form1.cbData.value = document.form1.dttratam.value;
 } 
 
 if (x == 22) {
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
//alert(document.form1.acao.value);

	if (document.form1.acao.value == 'Salvar'){

	    var strmanifesto = document.form1.observacao.value;
		strmanifesto = strmanifesto.replace(/\s/g, '');
		
	    var sit = document.form1.frmResp.value;
		
		if (sit == '')
			  {
			   alert('Caro Usuário, você deve selecionar o valor do campo Situação!');
			   return false;
			  }
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
	//return false;
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
	 
		 if ((sit == 15 || sit == 16 || sit == 18 || sit == 19 || sit == 23) && (dtprevdig_yyyymmdd < document.form1.dtdezddtrat.value))
		 {
		  var auxdtedit = document.form1.dtdezddtrat.value;
		  auxdtedit = auxdtedit.substring(6,8) + '/' + auxdtedit.substring(4,6) + '/' + auxdtedit.substring(0,4)
		  alert('Para Tratamento a Data de Previsão está menor que os 10(dez) dias úteis ou Data Previsão concedida para: ' + auxdtedit)
		  //dtprazo(sit);
		  exibe(sit);
		 return false;
		 }				 

		 if ((sit == 23) && (dt_hoje_yyyymmdd == dtprevdig_yyyymmdd))
		 {
		  alert("Para Tratamento a Data de Previsão da Solução deve ser maior que a do dia!")
		  //dtprazo(sit);
		  dtprazo(sit);
		  return false;
		 }

		 if (sit == 22) {
		 var auxcam = " \n\nRESPOSTA SUPERINTENDÊNCIA ESTADUAL\n\n - Essa opção RESPONDE o item e o encaminha para Equipe de Controle Interno da Regional (SGCIN)";
		 }
		 if (sit == 23) {
		 var auxcam = " \n\nTRATAMENTO SUPERINTENDÊNCIA ESTADUAL\n\n - Essa opção MANTÉM o item na Superintendência Estadual para desenvolvimento de ação que necessita de maior prazo da regularização ou resposta.\n Nesse caso deve indicar o prazo necessário no campo Data de Previsão da Solução.\n Até essa data sua resposta deverá ser complementada";
		 }

		 if (confirm ('            Atenção!' + auxcam))
		 {
			 
			 if (sit == 22 && document.form1.PosClassificacaoPonto.value == 'LEVE' && document.form1.undtipounidade.value != 12 && document.form1.undtipounidade.value != 16) {
			  var auxcam = 'O item respondido possui classificação "LEVE". Em decorrência disso está sendo encerrado o acompanhamento pelo Controle Interno.\n\nATENÇÃO: O não acompanhamento da regularização do item pelo Controle Interno não exime o gestor de providenciar a sua regularização.\n\nEm Avaliações de Controle futuras o item é passível de ser reavaliado. Caso seja constatada nova não conformidade, será considerada REINCIDÊNCIA, sendo acompanhada a sua regularização pelo Controle Interno.'
			  alert(auxcam);
			  }
			 document.form1.cbData.disabled = false;
			 return true;
		}
		else
		   {
			 if (sit != 23) {document.form1.cbData.disabled = true};
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

function carregaPendencias() {
	window.location.href=('itens_consulta_pendentes_se.cfm?tpConsulta=1<cfif isDefined('Form.Ninsp') and len(trim('Form.Ninsp'))>&alterado=1</cfif>');
}
</script>
</head>


<body onLoad="dtprazo(document.form1.frmResp.value); document.form1.acao.value=''">
<cfinclude template="cabecalho.cfm">
<table width="77%" height="60%" align="center">
<tr>
	  <td width="74%" valign="top">
<!--- Área de conteúdo   --->
	<form name="form1" method="post" onSubmit="return validaForm()" enctype="multipart/form-data" action="itens_se_controle_respostas1.cfm">
      <div align="right"><table width="74%" align="center">
          <tr><br>
              <td colspan="8"><p align="center" class="titulo1"><strong> PONTO DE controle interno por Superintendência</strong>
                      <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
                      <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
                      <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
                      <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
                      <input name="reop" type="hidden" id="reop" value="<cfoutput>#URL.reop#</cfoutput>">
					  <input type="hidden" name="acao" id="acao" value="">
                      <input type="hidden" name="anexo" id="anexo" value="">
					  <input type="hidden" name="vCodigo" id="vCodigo" value="">
					  <input name="ckTipo" type="hidden" id="ckTipo" value="<cfoutput>#URL.ckTipo#</cfoutput>">
					  <input name="dtinic" type="hidden" id="dtinic" value="<cfoutput>#URL.dtinic#</cfoutput>">
                    <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfinal#</cfoutput>">
              </p></td>
		  </tr>
		  <cfif cktipo eq 2>
			<tr><td colspan="9" align="center"> <button onClick="window.close()" class="botao">Fechar</button></td></tr>
	   </cfif>
		  <tr bgcolor="FFFFFF" class="exibir">
            <td colspan="8">&nbsp;</td>
          </tr>
          <tr bgcolor="FFFFFF" class="exibir">
            <td colspan="8">&nbsp;</td>
          </tr>
          <tr class="exibir">
            <td width="128" bgcolor="eeeeee">Unidade </td>
            <td colspan="3" bgcolor="eeeeee"><cfoutput><strong>#rsMod.Und_Descricao#</strong></cfoutput></td>
            <td colspan="2" bgcolor="eeeeee">Respons&aacute;vel</td>
            <td width="644" colspan="2" bgcolor="eeeeee"><cfoutput><strong>#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
           </tr>
          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td width="73" bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="9" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>- </cfif></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Nº Relatório</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="8" bgcolor="eeeeee"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Grupo</td>
            <td width="73" bgcolor="eeeeee"><cfoutput>#URL.Ngrup#</cfoutput></td>
            <td colspan="6" bgcolor="eeeeee"><cfoutput><strong>#rsItem.Grp_Descricao#</strong></cfoutput></td>
            </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td bgcolor="eeeeee"><cfoutput>#URL.Nitem#</cfoutput></td>
            <td colspan="7" bgcolor="eeeeee"><cfoutput><strong>#rsItem.Itn_Descricao#</strong></cfoutput></td>

			<tr class="exibir">
			  <td bgcolor="eeeeee">Relevância</td>
			  <td colspan="7" bgcolor="eeeeee">
			  <table width="100%" border="0">
				<tr class="exibir">
				  <td width="70">Pontuação </td>
				  <td width="50"><strong class="exibir"><cfoutput>#rsItem.Pos_PontuacaoPonto#</cfoutput></strong></td>
				  <td width="169"><div align="right">Classificação do Ponto &nbsp;</div></td>
				  <td width="538"><strong class="exibir"><cfoutput>#rsItem.Pos_ClassificacaoPonto#</cfoutput></strong></td>
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
            <td colspan="3" bgcolor="eeeeee">&nbsp;</td>
            <td width="287" bgcolor="eeeeee">&nbsp;</td>
            <td colspan="5" bgcolor="eeeeee">&nbsp;</td>
          </tr>
          <tr class="exibir">
            <td colspan="9" bgcolor="eeeeee"></td>
           </tr>
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Situação Encontrada:</span></td>
            <td colspan="8" bgcolor="eeeeee"><span class="exibir">
				<cfset melhoria = replace('#rsItem.RIP_Comentario#','; ' ,';','all')>
              <textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#melhoria#</cfoutput></textarea>
            </span></td>
		  </tr>
		 <tr>
            <td align="center" valign="middle" bgcolor="eeeeee"><span class="exibir"><span class="titulos">Orientações:</span></span></td>
            <td colspan="8"><span class="exibir">
              <textarea name="H_recom" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea>
            </span></td>
		  </tr>

           <!---  <input type="hidden" name="frmResp" value="7"> --->
			<!--- <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>"> --->
		
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Hist&oacute;rico:</span> <span class="titulos">Manifesta&ccedil;&atilde;o/An&aacute;lise do Controle Interno</span><span class="titulos">:</span></td>
            <td colspan="8" bgcolor="eeeeee"><textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" value="#Session.E01.h_obs#" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea></td>
		  </tr>
	  <cfif ckTipo neq 2> 
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee"><span class="exibir"><span class="titulos">Manifestar-se:</span></span></td>
            <td colspan="8"><span class="exibir"><textarea name="observacao" cols="200" rows="25" nome="Observação" vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#Session.E01.observacao#</cfoutput></textarea>
            </span></td>
          </tr>
		  <tr>
        <td align="center" valign="middle" bgcolor="#eeeeee" class="exibir"><strong>ANEXOS</strong></td>
        <td colspan="8" bgcolor="#eeeeee" class="exibir">&nbsp;</td>
        </tr>
	  <tr>
	
	  <cfset resp = qResposta.Pos_Situacao_Resp>
        <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><strong>Arquivo:</strong></td>
        <td colspan="6" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td bgcolor="eeeeee" class="exibir">
		<cfif (resp neq 21)>
		  <input name="submit" id="Submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar">
		<cfelse>
		  <input name="submit" id="Submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" disabled>
		</cfif></td>
      </tr>

	  <tr>
	    <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
	  </tr>
		<!---  --->
  <cfoutput>
    <cfset posdtprevsolucao = CreateDate(year(now()),month(now()),day(now()))>
	<cfset posdtprevsolucao = dateformat(qResposta.Pos_DtPrev_Solucao,"YYYYMMDD")>
	<cfset dtbase = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dtrespos = CreateDate(year(now()),month(now()),day(now()))>
	<cfset dttratam = CreateDate(year(now()),month(now()),day(now()))>
    <cfset dt30diasuteis = CreateDate(year(now()),month(now()),day(now()))>
	<cfobject component = "CFC/Dao" name = "dao">
	<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="VencidoPrazo_Andamento" NumeroDaInspecao="#ninsp#" 
		CodigoDaUnidade="#unid#" Grupo="#ngrup#" Item="#nitem#" MostraDump="no" RetornaQuantDias="yes" ApenasDiasUteis="yes" ListaDeStatusContabilizados="8,23">
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

			<cfif dt30diasuteis gte posdtprevsolucao>
				<cfset dtbase = dt30diasuteis>
			<cfelse>
				<cfset dtbase = posdtprevsolucao>	
				<cfset auxQtdDias = DateDiff("d", dt30diasuteis,posdtprevsolucao)>
			</cfif>
			<cfif dtbase lte dateformat(now(),"YYYYMMDD")>
			<!--- somente direito a responder --->
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND (STO_Codigo = 22)
				</cfquery>
			<cfelse>
				<!--- possui direitode tratamento e de resposta --->	
				<!--- Contar os possiveis dez dias uteis para tratamento --->	
				<cfquery name="rsPonto" datasource="#dsn_inspecao#">
					SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (22,23)
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
           <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="exibir"><strong>Situa&ccedil;&atilde;o</strong></span><strong>:&nbsp;</strong>&nbsp;		   </td>
           <td colspan="7" bgcolor="eeeeee"><div align="left">
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
            <td colspan="7" bgcolor="eeeeee" class="form"><cfoutput>#cl# - #ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td width="644" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" /></td>
         <!---   <cfoutput>
			<cfif (resp neq 21)>
				<input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#">
		    <cfelse>
		        <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#" disabled>
		    </cfif>
           </cfoutput> --->
          </tr>
        </cfif>
      </cfloop>

         <tr>
            <td colspan="8" bgcolor="eeeeee">&nbsp;</td>
         </tr><br>
         <tr>
            <td colspan="10" bgcolor="eeeeee" class="exibir"><div id="dData" class="titulos">Data de Previs&atilde;o da Solu&ccedil;&atilde;o:&nbsp;&nbsp;
	<input name="cbData" id="cbData" type="text" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" value="<cfoutput>#dateformat(now(),"dd/mm/yyyy")#</cfoutput>" readonly="yes">
			</td>
         </tr>
		<tr>
	       <td colspan="8">&nbsp;</td>
	    </tr>
 <!---   </cfif> --->
          <tr>
            <td colspan="6"><div align="right">
  <input name="Voltar" type="button" class="botao" value="Voltar" onClick="window.open('itens_se_controle_respostas.cfm?ckTipo=1','_self')">
&nbsp;&nbsp;</div></td>
            <td>
			<div align="left">&nbsp;&nbsp;
		  <cfif resp neq 21 and resp neq 22 and resp neq 29>
              <input name="Submit" type="submit" class="botao" value="Salvar" onClick="document.form1.acao.value='Salvar'">
            <cfelse>
             <input name="Submit" type="submit" value="Salvar" class="botao" onClick="document.form1.acao.value='Salvar'" disabled> 
		</cfif>
	<cfelse>
		<tr>
			<td colspan="9" align="center"> <button onClick="window.close()"
				class="botao">Fechar</button></td>
		  </tr>
	</cfif>
		</div>
		 </td>
          </tr>
        </table>
        <input type="hidden" name="MM_UpdateRecord" value="form1">
		<input type="hidden" name="salvar_anexar" value="">
		<input name="exigedata" type="hidden" id="exigedata" value="N">
		<input type="hidden" name="frmSitResp_Banco" id="frmSitResp_Banco" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
		<cfset SitResp = qResposta.Pos_Situacao_Resp>
		<input type="hidden" name="vPSitResp" id="vPSitResp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
		<input type="hidden" name="PosClassificacaoPonto" id="PosClassificacaoPonto" value="<cfoutput>#trim(qResposta.Pos_ClassificacaoPonto)#</cfoutput>">
		<input type="hidden" name="undtipounidade" id="undtipounidade" value="<cfoutput>#trim(rsItem.Und_TipoUnidade)#</cfoutput>">
		<input type="hidden" name="scodresp" id="scodresp" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
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
