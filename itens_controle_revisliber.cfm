<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>             

<cfif isDefined("Form.acao")>
  <cfparam name="url.pg" default="#form.pg#"> 
<cfelse>
  <cfparam name="url.pg" default="">
</cfif>

<cfif isDefined("Form.acao")>

	<cfif "#url.pg#" neq 'pt'>
		<script>
			alert('Prezado Gestor, utilize o Papel de Trabalho para acessar esta página.');
		    history.go(-1);
		</script>
		
	</cfif>
<cfelse>
    <cfif isDefined("url.pg")>
		<cfif "#url.pg#" neq 'pt'>
			<script>
				alert('Prezado Gestor, utilize o Papel de Trabalho para acessar esta página.');
				history.go(-1);
			</script>
			
		</cfif>
	<cfelse>
		<script>
				alert('Prezado Gestor, utilize o Papel de Trabalho para acessar esta página.');
				history.go(-1);
		</script>
		
	</cfif>

</cfif>
<!---  --->
<cfset auxdtprev = CreateDate(year(now()),month(now()), day(now()))>
<cfif tpunid neq 12 and tpunid neq 16>
	<!--- 10 dias úteis na data de previsão --->
  <cfset nCont = 1>
  <cfloop condition="nCont lte 10">
    <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
    <cfset vDiaSem = DayOfWeek(auxdtprev)>
    <cfif vDiaSem neq 1 and vDiaSem neq 7>
      <!--- verificar se Feriado Nacional --->
      <cfquery name="rsFeriado" datasource="#dsn_inspecao#">
        SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #auxdtprev#
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
<cfelse>
  <!--- 30 dias úteis na data de previsão --->
  <cfset nCont = 1>
  <cfloop condition="nCont lte 30">
    <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
    <cfset vDiaSem = DayOfWeek(auxdtprev)>
    <cfif vDiaSem neq 1 and vDiaSem neq 7>
      <!--- verificar se Feriado Nacional --->
      <cfquery name="rsFeriado" datasource="#dsn_inspecao#">
        SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #auxdtprev#
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
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
<!---  --->
<cfif isDefined("Form.acao")>
	<cfquery datasource="#dsn_inspecao#" name="rsRevis">
		SELECT INP_RevisorLogin
		FROM Inspecao
		WHERE INP_NumInspecao='#form.ninsp#'
	</cfquery>
	<cfif trim(rsRevis.INP_RevisorLogin) lte 0 and grpacesso eq 'GESTORES'>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Inspecao SET INP_RevisorLogin = '#CGI.REMOTE_USER#', INP_RevisorDTInic = CONVERT(varchar, getdate(), 120)
			WHERE INP_Unidade = '#Unid#'and INP_NumInspecao ='#form.ninsp#'
		</cfquery>
	</cfif>
<!--- Verifica se o item ainda consta em ParecerUnidade pois pode ter sido enviado para Reanálise do Inspetor--->
    <cfquery datasource="#dsn_inspecao#" name="qVerificaParecerUnidade">
		SELECT Pos_Inspecao FROM ParecerUnidade 
		WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#Form.ngrup# AND Pos_NumItem=#Form.nitem# 
	</cfquery>
	<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
	  	SELECT RIP_Resposta,RIP_Recomendacao FROM Resultado_Inspecao 
		WHERE RIP_Recomendacao='S' and RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem# 
	</cfquery>
	<cfif qVerificaParecerUnidade.recordcount eq 0 and qVerifEmReanalise.recordcount neq 0>
	    <script>
           	alert("Este item foi enviado para Reanálise do Inspetor. Nenhuma outra ação poderá ser excutada.");
	    </script>
			<cflocation url = "GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=#form.Ninsp#" addToken = "no">
	</cfif>
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
	


<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email
</cfquery>

 <cfif (grpacesso neq 'GESTORES') and (grpacesso neq 'DESENVOLVEDORES') and (grpacesso neq 'GESTORMASTER') and (grpacesso neq 'INSPETORES')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>        

<cfquery name="rsSEINCI" datasource="#dsn_inspecao#">
 SELECT Pos_NCISEI FROM ParecerUnidade WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NCISEI Is Not Null ORDER BY Pos_NCISEI DESC
</cfquery>

<cfquery name="rsRelev" datasource="#dsn_inspecao#">
	SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
	FROM ValorRelevancia
	WHERE VLR_Ano = '#right(ninsp,4)#'
</cfquery>
<cfif (grpacesso eq 'GESTORES') or (grpacesso eq 'DESENVOLVEDORES') or (grpacesso eq 'GESTORMASTER') or (grpacesso eq 'INSPETORES')>
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
  <cfif isDefined("Form.modal")><cfset Session.E01.modal = Form.modal><cfelse><cfset Session.E01.modal = ''></cfif>
  <cfif isDefined("Form.manchete")><cfset Session.E01.manchete = Form.manchete><cfelse><cfset Session.E01.manchete = ''></cfif>

<cfif Form.acao is 'Anexar'>
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
		<!--- O arquivo anexo recebe nome indicando Numero da Inspeção, Número da unidade, Número do grupo e Número do item ao qual estão vinculado --->

		<cfset destino = cffile.serverdirectory & '\' & Form.ninsp & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '_' & Form.ngrup & '_' & Form.nitem & seq & '.pdf'>


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
	 <cfif Form.acao is 'Excluir_Anexo'>
	  <!--- Verificar se anexo existe --->
 <cfoutput>
  form.vCodigo: #form.vCodigo#
 </cfoutput>

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
    <!---Se for um item reanalisado, ao salvar, faz o update na tabela Resultado_Inspecao validando a reanálise--->
    <cfquery  datasource="#dsn_inspecao#" name="qVerificaReanalise">
	  Select RIP_Recomendacao FROM Resultado_Inspecao
	  WHERE RIP_Recomendacao = 'R' and RIP_NumInspecao = '#form.ninsp#' and RIP_NumGrupo ='#form.ngrup#' and RIP_NumItem ='#form.nitem#'
	</cfquery>
	<cfif '#qVerificaReanalise.recordcount#' neq 0>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao set RIP_Recomendacao = 'V',RIP_UserName_Revisor = '#CGI.REMOTE_USER#', RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
			WHERE RIP_NumInspecao = '#form.ninsp#' and RIP_NumGrupo =#form.ngrup# and RIP_NumItem =#form.nitem#
		</cfquery>
    </cfif>
    <!---Fim do update na tabela Resultado_Inspecao para itens reanalisados --->

	<cfquery datasource="#dsn_inspecao#" name="qVerificaTipo">
		Select Und_TipoUnidade, Und_CodReop from Unidades WHERE Und_Codigo = #Unid#
	 </cfquery>
	 <cfquery datasource="#dsn_inspecao#" name="qVerificaArea">
		Select Rep_CodArea from Reops WHERE Rep_Codigo=#qVerificaTipo.Und_CodReop#
	</cfquery>
	<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao SET 
			  RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
			, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
		<cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
			<cfset aux_mel = CHR(13) & Form.Melhoria>
			<cfset tammel = len(trim(aux_mel))>
			, RIP_Comentario='#aux_mel#'
		</cfif>
		<cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
			<cfset aux_recom = CHR(13) & FORM.recomendacao>		
			<cfset tamrec = len(trim(aux_recom))>
			, RIP_Recomendacoes='#aux_recom#'
		</cfif>
			<cfset taman = len(trim(form.manchete))>
			, RIP_Manchete='#form.manchete#'
		<cfif (tammel neq form.tamMelho) or (tamrec neq form.tamrecom) or (taman neq form.tamanchete)>
			, RIP_Correcao_Revisor = '1'
		</cfif>
		WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
	</cfquery>
	<cfif IsDefined("FORM.frmcbarea") AND FORM.frmcbarea EQ "">
		<cfquery datasource="#dsn_inspecao#">
			UPDATE ParecerUnidade SET Pos_Situacao_Resp = 11
			, Pos_Situacao = 'EL'
			, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
			, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(auxdtprev),month(auxdtprev),day(auxdtprev)))#
			, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
			, pos_username = '#CGI.REMOTE_USER#'
			, Pos_Sit_Resp_Antes = #form.scodresp#
				<!--- N° SEI da NCI --->
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
		<cfset andparecer = "Ação: Revisar (GESTORES)">
		<cfquery name="rsExiste" datasource="#dsn_inspecao#">
		    select And_NumInspecao 
			from Andamento 
			where And_NumInspecao='#Form.ninsp#' and 
			And_Unidade='#Form.unid#' and 
			And_NumGrupo=#Form.ngrup# and 
			And_NumItem=#Form.nitem# and
			And_Situacao_Resp=11 and
			And_HrPosic='000011'
		</cfquery>
		<cfif rsExiste.recordcount lte 0>
			<cfquery datasource="#dsn_inspecao#">
				INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area,and_Parecer)
				VALUES ('#Form.ninsp#', '#Form.unid#', #Form.ngrup#, #Form.nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', 11, '000011','#Form.unid#','#andparecer#')
			</cfquery>
		<cfelse>
			<cfquery datasource="#dsn_inspecao#">
				update Andamento set And_DtPosic=#createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
				, And_username='#CGI.REMOTE_USER#'
				, And_Area = '#Form.unid#'
				, and_Parecer= '#andparecer#'
				where And_NumInspecao='#Form.ninsp#' and 
				And_Unidade='#Form.unid#' and 
				And_NumGrupo=#Form.ngrup# and 
				And_NumItem=#Form.nitem# and
				And_Situacao_Resp=11 and
				And_HrPosic='000011'
			</cfquery>
		</cfif>

	    <!--- Verificar registro estão na Situação 11(Em Liberacao Inspecao) na tabela ParecerUnidade 		
		<cfquery name="qEmLiberacao" datasource="#dsn_inspecao#">
			SELECT Pos_Situacao_Resp FROM ParecerUnidade
			WHERE Pos_Unidade='#unid#' AND 
			Pos_Inspecao='#ninsp#' AND 
			Pos_Situacao_Resp = 11
		</cfquery>
		<cfquery name="rs11SN" datasource="#dsn_inspecao#">
				SELECT And_NumInspecao FROM Andamento
				WHERE And_Unidade='#Form.unid#' AND And_NumInspecao='#Form.ninsp#' AND And_NumGrupo=#Form.ngrup# AND And_NumItem=#Form.nitem# 
				AND And_Situacao_Resp = 11
		</cfquery> 			 

		<cfif qEmLiberacao.Pos_Situacao_Resp eq 11>
			<cfif rs11SN.recordcount lte 0>
				<cfif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and qVerificaTipo.Und_TipoUnidade neq 12 and qVerificaTipo.Und_TipoUnidade neq 16>
					<cfquery datasource="#dsn_inspecao#">
						INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
						VALUES ('#Form.ninsp#', '#Form.unid#', #Form.ngrup#, #Form.nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', 11, '000011','#qVerificaTipo.Und_CodReop#')
					</cfquery>
				<cfelseif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and (qVerificaTipo.Und_TipoUnidade eq 12 or qVerificaTipo.Und_TipoUnidade eq 16)>
					<cfquery datasource="#dsn_inspecao#">
						INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
						VALUES ('#Form.ninsp#', '#Form.unid#', #Form.ngrup#, #Form.nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', 11, '000011','#qVerificaArea.Rep_CodArea#')
					</cfquery>
				<cfelse>
					<cfquery datasource="#dsn_inspecao#">
						INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Area)
						VALUES ('#Form.ninsp#', '#Form.unid#', #Form.ngrup#, #Form.nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', 11, '000011','#qVerificaTipo.Und_CodReop#')
					</cfquery>
				</cfif>
			</cfif>
		</cfif>
		--->
    <cfelse>
		<!--- trabalhar com os possiveis intencoes de passar do Status = 0-RE ou 11-EL para 19-TA ou 16-TS --->
		<cfset auxsitresp = 19>
		<cfset auxsigla = 'TA'>
		<cfset situacao = 'TRATAMENTO DA AREA'>

		<cfquery datasource="#dsn_inspecao#" name="qVerificaTipo">
			Select Und_TipoUnidade, Und_CodReop from Unidades WHERE Und_Codigo = #Unid#
		</cfquery>
				
		<cfif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and qVerificaTipo.Und_TipoUnidade neq 12 and qVerificaTipo.Und_TipoUnidade neq 16>
			<cfset auxsitresp = 16>
			<cfset auxsigla = 'TS'>
			<cfset situacao = 'TRATAMENTO ORGAO SUBORDINADOR'>
		</cfif>

		<cfif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and (qVerificaTipo.Und_TipoUnidade eq 12 || qVerificaTipo.Und_TipoUnidade eq 16)>
			<cfset auxsitresp = 26>
			<cfset auxsigla = 'NC'>
			<cfset situacao = 'NAO REGULARIZADO - APLICAR O CONTRATO'>
		</cfif>
				
		<cfquery datasource="#dsn_inspecao#">
			UPDATE ParecerUnidade SET Pos_Situacao_Resp =
				<cfif auxsitresp eq 19>
						#auxsitresp#
						<cfquery name="rsArea" datasource="#dsn_inspecao#">
						SELECT Ars_Sigla, Ars_Descricao, Ars_Email
						FROM Areas
						WHERE Ars_Codigo = '#Form.frmcbarea#'
						</cfquery>
						<cfset andarea = #Form.frmcbarea#>
					, Pos_Situacao = 'TA'
					, Pos_Area = '#Form.frmcbarea#'
					, Pos_Nomearea = '#rsArea.Ars_Descricao#'
					, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
					, pos_username = '#CGI.REMOTE_USER#'
					, Pos_Sit_Resp_Antes = #form.scodresp#
						<cfset Gestor = 'Ao (à)  ' & trim(rsArea.Ars_Descricao)>
						<cfset auxsigla = #trim(rsArea.Ars_Descricao)#>
						<cfset auxemail = trim(rsArea.Ars_Email)>
				<cfelseif auxsitresp eq 26>
					#auxsitresp#
					<cfquery name="rsArea" datasource="#dsn_inspecao#">
					SELECT Ars_Sigla, Ars_Descricao, Ars_Email
					FROM Areas
					WHERE Ars_Codigo = '#qVerificaArea.Rep_CodArea#'
					</cfquery>
					<cfset andarea = #qVerificaArea.Rep_CodArea#>
					, Pos_Situacao = 'NC'
					, Pos_Area = '#qVerificaArea.Rep_CodArea#'
					, Pos_Nomearea = '#rsArea.Ars_Descricao#'
					<cfset Gestor = 'Ao (à)  ' & trim(rsArea.Ars_Descricao)>
					<cfset auxsigla = #trim(rsArea.Ars_Descricao)#>
					<cfset auxemail = trim(rsArea.Ars_Email)>
				<cfelse>
					#auxsitresp#
					<cfquery name="rsOrgSub011" datasource="#dsn_inspecao#">
						SELECT Rep_Codigo, Rep_Sigla, Rep_Nome, Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop 
						WHERE Und_Codigo = '#Form.frmposarea_011#'
					</cfquery>
					<cfset andarea = #rsOrgSub011.Rep_Codigo#>
					, Pos_Situacao = 'TS'
					, Pos_Area = '#rsOrgSub011.Rep_Codigo#'
					, Pos_Nomearea = '#rsOrgSub011.Rep_Nome#'
					<cfset Gestor = 'Ao (à) ' & trim(rsOrgSub011.Rep_Nome)>
					<cfset auxsigla = trim(rsOrgSub011.Rep_Nome)>
					<cfset auxemail = trim(rsOrgSub011.Rep_Email)>
					<cfset Form.frmcbarea = rsOrgSub011.Rep_Codigo>
				</cfif>
					<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
					<cfif left(maskcgiusu,8) eq 'EXTRANET'>
						<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
					<cfelse>
						<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
					</cfif>
					<cfset Encaminhamento = 'Opinião do Controle Interno'>
					<cfif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and (qVerificaTipo.Und_TipoUnidade eq 12 || qVerificaTipo.Und_TipoUnidade eq 16)>
						<cfset aux_obs = "Encaminhamos achado de Controle interno, constatado na agência terceirizada referenciada neste Relatório, para conhecimento, análise, acompanhamento da regularização (se for o caso) e aplicação das providências de competência desse órgão, conforme previsto no instrumento contratual regente. Após a ciência,  o controle da baixa desse  item passará ser de responsabilidade dessa área e a efetividade e regularidade das açães adotadas poderão ser avaliadas em futuros trabalhos das áreas de Controle Interno da Empresa (2° e 3° linha) ou de órgãos Externos.">
					<cfelse>
						<cfset aux_obs = "Senhor gestor, Encaminhamos para conhecimento e manifestação a presente Situação Encontrada identificada durante a execução das atividades de controles internos em unidades operacionais, por tratar-se de atividade cuja gestão pertence a essa área">
					</cfif>
					<cfquery name="rsPar" datasource="#dsn_inspecao#">
						SELECT Pos_Parecer FROM ParecerUnidade WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
					</cfquery>
					<cfif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and (qVerificaTipo.Und_TipoUnidade eq 12 || qVerificaTipo.Und_TipoUnidade eq 16)>
							<cfset pos_aux = #rsPar.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)#  & CHR(13) & CHR(13) & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
							, Pos_Parecer='#pos_aux#'
					<cfelse>
							<cfset pos_aux = #rsPar.Pos_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)#  & CHR(13) & CHR(13) & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(auxdtprev,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
							, Pos_Parecer='#pos_aux#'
					</cfif>
					, pos_username = '#CGI.REMOTE_USER#'
					, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
					<cfif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and (qVerificaTipo.Und_TipoUnidade eq 12 || qVerificaTipo.Und_TipoUnidade eq 16)>
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(auxdtprev),month(auxdtprev),day(auxdtprev)))#
					<cfelse>
						, Pos_DtPrev_Solucao = #createodbcdate(createdate(year(auxdtprev),month(auxdtprev),day(auxdtprev)))#
					</cfif>
					, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
					<cfset aux_sei_nci = "">
					, Pos_NCISEI =
					<cfif IsDefined("FORM.nci") AND FORM.nci EQ "Sim">
						<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
						<cfset aux_sei_nci = Trim(FORM.frmnumseinci)>
						<cfset aux_sei_nci = Replace(aux_sei_nci,'.','',"All")>
						<cfset aux_sei_nci = Replace(aux_sei_nci,'/','','All')>
						<cfset aux_sei_nci = Replace(aux_sei_nci,'-','','All')>
							'#aux_sei_nci#'
					<cfelse>
						'#aux_sei_nci#'
					</cfif>
					WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
				</cfquery>
			
				<!---Atualiza a tabela Resultado_Inspecao e Inspecao para liberação do relatório--->
				<cfquery datasource="#dsn_inspecao#">
					UPDATE Resultado_Inspecao set 
					RIP_Recomendacao = 'V'
					, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
					, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
					WHERE RIP_NumInspecao = '#form.ninsp#' and RIP_NumGrupo =#form.ngrup# and RIP_NumItem =#form.nitem#
				</cfquery>

				<cfset and_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)#  & CHR(13) & CHR(13) & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(auxdtprev,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) & 'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
				<cfset hhmmssdc = timeFormat(now(), "HH:MM:ssl")>
				<cfset hhmmssdc = Replace(hhmmssdc,':','',"All")>
				<cfset hhmmssdc = Replace(hhmmssdc,'.','',"All")>	
				<cfif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and qVerificaTipo.Und_TipoUnidade neq 12 and qVerificaTipo.Und_TipoUnidade neq 16>
						<cfquery datasource="#dsn_inspecao#">
							INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area)
							VALUES ('#FORM.ninsp#', '#FORM.unid#', #FORM.ngrup#, #FORM.nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', #auxsitresp#, '#hhmmssdc#', '#and_aux#', '#qVerificaTipo.Und_CodReop#')
						</cfquery>
				<cfelseif form.pontocentlzSN eq 'S' and FORM.nci eq 'Sim' and (qVerificaTipo.Und_TipoUnidade eq 12 or qVerificaTipo.Und_TipoUnidade eq 16)>
						<cfquery datasource="#dsn_inspecao#">
							INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area)
							VALUES ('#FORM.ninsp#', '#FORM.unid#', #FORM.ngrup#, #FORM.nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', #auxsitresp#, '#hhmmssdc#', '#and_aux#', '#qVerificaArea.Rep_CodArea#')
						</cfquery>
				<cfelse>
						<cfquery datasource="#dsn_inspecao#">
							INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, And_Parecer, And_Area)
							VALUES ('#FORM.ninsp#', '#FORM.unid#', #FORM.ngrup#, #FORM.nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', #auxsitresp#, '#hhmmssdc#', '#and_aux#', '#unid#')
						</cfquery>
				</cfif>
				<!--- envio de e-mail para area --->
				<cfif findoneof("@", trim(auxemail)) eq 0>
					<cfset sdestina = "gilvanm@correios.com.br">
				<cfelse>
					<cfset sdestina = #auxemail#>
				</cfif>

		        <!---   <cfset sdestina = "gilvanm@correios.com.br">  --->
<cfoutput>
				<cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="Relatório de Avaliação de Controle Interno" type="HTML">
					Mensagem automática. Não precisa responder!<br><br>
					Ao Gestor do(a) #Ucase(auxsigla)#. <br><br><br>
					&nbsp;&nbsp;&nbsp;Comunicamos que há pontos  de Controle Interno  "#situacao#" para  manifestação desse órgão.<br><br>
					&nbsp;&nbsp;&nbsp;Assim, solicitamos registrar, por  meio do preenchimento do campo "Manifestar-se" no Sistema SNCI, as suas manifestações acerca das inconsistências registradas.<br><br>
					&nbsp;&nbsp;&nbsp;Para registro de suas manifestações acesse o SNCI clicando no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório de Controle Interno.</a>Relatório N° #FORM.ninsp#, Grupo: #FORM.ngrup#  e Item: #FORM.nitem#.<br><br>
				</cfmail>
</cfoutput>				
				<!--- Fim da Intencao de passar a area ---> 
	</cfif>
	<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
	</cfif>

	<script>
		<cfoutput>
		var	pg = '#form.pg#'; 
		var insp = '#form.Ninsp#';
		</cfoutput>
		var url = 'GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.id=' + insp;
		if( pg == 'pt'){
			window.open(url, '_self');
		}
		
	</script>
</cfif>

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
	<cfparam name="URL.modal" default="#Form.modal#">
	<cfparam name="URL.tpunid" default="#Form.tpunid#">
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
	<cfparam name="URL.modal" default="">
</cfif>

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
  FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
	SELECT Pos_Abertura, Pos_VLRecuperado, Pos_DtPrev_Solucao, Pos_DtPosic, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, Pos_SEI, Pos_Situacao_Resp, Pos_Processo, Pos_Tipo_Processo, Pos_Area, Pos_NomeArea, Pos_Situacao_Resp, Pos_Parecer, Pos_PontuacaoPonto, Pos_ClassificacaoPonto, RIP_Recomendacoes, RIP_Recomendacao, RIP_Comentario, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_Valor, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem, RIP_Manchete, Dir_Descricao, Dir_Codigo, INP_DtInicInspecao, Pos_NCISEI, Grp_Descricao, Und_TipoUnidade, INP_Modalidade, Itn_Descricao, Itn_TipoUnidade, Itn_PTC_Seq, Itn_ImpactarTipos, TNC_ClassifInicio, TNC_ClassifAtual
	FROM  Inspecao 
	INNER JOIN (Diretoria 
	INNER JOIN ((Resultado_Inspecao 
	INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
	INNER JOIN (Itens_Verificacao 
	INNER JOIN Grupos_Verificacao ON Itn_Ano = Grp_Ano and Itn_NumGrupo = Grp_Codigo) ON (convert(char(4),RIP_Ano) = Grp_Ano) and (Pos_NumGrupo = Itn_NumGrupo) AND (Pos_NumItem = Itn_NumItem)) 
	ON Dir_Codigo = RIP_CodDiretoria) ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade) and (inp_modalidade=itn_modalidade)
	INNER JOIN Unidades ON Und_Codigo = INP_Unidade and (Itn_TipoUnidade = Und_TipoUnidade)
    left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
	WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>
<cfparam name="form.manchete" default="#qResposta.RIP_Manchete#">		  
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
	<cfquery name="rsPonto" datasource="#dsn_inspecao#">
		SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto 
		WHERE STO_Status='A'                                                                                                   
		<cfif dateformat(#auxdtprev#,"YYYYMMDD") lt dateformat(now(),"YYYYMMDD")>
			<cfif grpacesso eq 'GESTORMASTER'>
				AND STO_Codigo in (9,12,13,21,25,26)
			<cfelse>
				AND STO_Codigo in (9,12,13,25,26)	  
			</cfif>
		<cfelse>
			<cfif grpacesso eq 'GESTORMASTER'>
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
	    <cfif grpacesso neq 'GESTORMASTER'>
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


<script type="text/javascript">
<cfinclude template="mm_menu.js">

//reinicia o ckeditor para inibir o erro de retornar conteúdo vazio no textarea
// function CKupdate(){
//     for ( instance in CKEDITOR.instances )
//     CKEDITOR.instances[instance].updateElement();
// }
//*********************************************************************
	//==================================
	function exibirvalores() {
		window.impactofalta.style.visibility = 'hidden';
		window.impactosobra.style.visibility = 'hidden';
		window.impactoemrisco.style.visibility = 'hidden';
		window.impactofin.style.visibility = 'hidden';	

		var impfin = document.form1.frmimpactofin.value;
		var impfalta=document.form1.frmimpactofalta.value;
		var impsobra=document.form1.frmimpactosobra.value;
		var impemrisco=document.form1.frmimpactoemrisco.value;

	//	alert('Tem Impacto? ' + impfin + '  Tem falta? ' + impfalta + '  Tem Sobra? ' + impsobra + '  Tem em Risco? ' + impemrisco);
		if (impfin == 'S') 
		{
			document.form1.frmfalta.value = document.form1.sfrmfalta.value;
			document.form1.frmsobra.value = document.form1.sfrmsobra.value;
			document.form1.frmemrisco.value = document.form1.sfrmemrisco.value;
			window.impactofin.style.visibility = 'visible';
			if (impfalta == 'F') {window.impactofalta.style.visibility = 'visible';}
			if (impsobra == 'S') {window.impactosobra.style.visibility = 'visible';}
			if (impemrisco == 'R') {window.impactoemrisco.style.visibility = 'visible';}
		} 
	}
//=========================================
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
function controleNCI()
{
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
//===================
function hanci()
{
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
function exibe(a)
{
//  alert('exibe: ' + a);
  exibirArea(a);
 exibirAreaCS(a);
  exibirValor(a);
 dtprazo(a);
}
//==============
function exibir_Area011(x)
{
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
function exibirArea(ind)
{
  //alert('exibirArea: ' + ind);
  document.form1.observacao.disabled=false;
  document.form1.cbarea.disabled=false;
  if (ind==5 || ind==10 || ind==19 || ind==21|| ind==25 || ind==26)
  {
    window.dArea.style.visibility = 'visible';
    if(ind==21) {buscaopt('SEC AVAL CONT INTERNO/SGCIN')}
	<cfoutput>
		if(ind==25)
	    {
		    document.form1.observacao.value = ''
            <cfset sinformes = "Encaminhamos achado de Controle interno, constatado na agência terceirizada referenciada nesta Avaliação, para conhecimento, análise, acompanhamento da regularização (se for o caso) e aplicação das providências de competência desse órgão, conforme previsto no instrumento contratual regente. Após a ciência,  o controle da baixa desse  item passará a ser de responsabilidade dessa área e a efetividade e regularidade das ações adotadas poderão serem avaliadas em futuros trabalhos das áreas de Controle Interno da Empresa (2° e 3° linha) ou de Órgãos Externos.">
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
  }
}
//====================
var idx
function exibirAreaCS(idx){
	//alert(idx);
	//alert(document.form1.houveProcSN.value);
	window.dAreaCS.style.visibility = 'visible';
  if (idx==24 || document.form1.houveProcSN.value == 'S')
    {
		if(document.form1.houveProcSN.value == 'S')
		{
			//alert(document.form1.houveProcSN.value);
			if(document.form1.mensSN.value == 'S')
			{
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
function validarform()
{
	if (document.form1.acao.value=='Anexar')
	{
		var x=document.form1.nci.value;
		var k=document.form1.frmnumseinci.value;
		if (x == 'Sim' && (k.length != 20 || k =='')){
			alert("N° SEI da Apuração Inválido!:  (ex. 99999.999999/9999-99)");
			document.form1.frmnumseinci.focus();
			return false;
		}else{
		 return true;
		}
	}

 //=============================================================
	if (document.form1.acao.value=='alter_reincidencia')
	{
		var reincInsp = document.form1.frmreincInsp.value;
		var reincGrup = document.form1.frmreincGrup.value;
		var reincItem = document.form1.frmreincItem.value;

		if (document.form1.frmReinccb.value == 'S' && (reincInsp.length != 10 || reincGrup == 0 || reincItem == 0))
		{
			alert('Para o Reincidência: Sim ? preciso informar N° Avaliação, N° Grupo e N° Item!');
			//exibe(sit);
			return false;
		} else {
		document.form1.frmreincInsp.disabled = false;
		document.form1.frmreincGrup.disabled = false;
		document.form1.frmreincItem.disabled = false;
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
		if (document.form1.manchete.value ==''){
			alert('Informar o campo Manchete');
			return false;
		}
		if (document.form1.nci.value == 'Sim')
		{
			// controle de dados do N.SEI da NCI
			var nsnci = document.form1.frmnumseinci.value;
			if (nsnci.length != 20 || nsnci=='')
			{
				alert('N° do SEI da NCI Inválido!:  (ex. 99999.999999/9999-99)');
				return false;
			}
		}
		//----------------------------------------------
		var el = document.getElementById('Abrir');
		if (document.form1.nci.value == 'Sim' && el==null )
		{
			alert('Sr. Gestor, para pontos com Nota de Controle Interno? necessário anexar a NCI.');
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

function abrirPopup(url,w,h) 
{
	var newW = w + 100;
	var newH = h + 100;
	var left = (screen.width-newW)/2;
	var top = (screen.height-newH)/2;
	var newwindow = window.open(url, 'blank', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',scrollbars=no');
	newwindow.resizeTo(newW, newH);
	//posiciona o popup no centro da tela
	newwindow.moveTo(left, top);
	newwindow.focus();
	return false;
}

</script>

</head>

<body onLoad="exibirvalores();if(document.form1.houveProcSN.value != 'S') {exibe(document.form1.frmResp.value)} else {exibe(24)}; hanci(); controleNCI(); exibir_Area011(this.value);"> 
 <cfinclude template="cabecalho.cfm">
    <cfif '#qResposta.RIP_Recomendacao#' eq 'R'>
		<div align="right" style="position:absolute;top:163px;right:160px">
			<a  onClick="abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#ninsp#&unid=#unid#&ngrup=#ngrup#&nitem=#nitem#&tpuni=#rsTPUnid.Und_TipoUnidade#</cfoutput>',800,600)" href="#"
			class="botaoCad" ><img   onmouseover="bigImg(this)" onMouseOut="normalImg(this)"   alt="Orientações p/ Reanálise do Inspetor" src="figuras/reavaliar.png" width="25"   border="0" style="position:absolute;left:0px;top:5px"></img></a>	
		</div>
	</cfif>
							
<table width="70%"  align="center" bordercolor="f7f7f7">
  <tr>
    <td height="20" colspan="5" bgcolor="eeeeee"><div align="center"><strong class="titulo2"><cfoutput>#qResposta.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr bgcolor="eeeeee">
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <tr bgcolor="eeeeee">
    <td height="10" colspan="5"><div align="center"><strong class="titulo1">CONTROLE DAS MANIFESTAÇÕES</strong></div></td>
  </tr>
  <tr bgcolor="eeeeee">
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <form name="form1" method="post" onSubmit="return validarform()" enctype="multipart/form-data" action="itens_controle_revisliber.cfm">
  <cfoutput>
	    <input type="hidden" name="scodresp" id="scodresp" value="#qResposta.Pos_Situacao_Resp#">
		<input type="hidden" name="sfrmPosArea" id="sfrmPosArea" value="#qResposta.Pos_Area#">
		<input type="hidden" name="sfrmPosNomeArea" id="sfrmPosNomeArea" value="#qResposta.Pos_NomeArea#">
		<input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="#qResposta.Itn_TipoUnidade#">
		<cfset resp = #qResposta.Pos_Situacao_Resp#> 
		<input type="hidden" name="srespatual" id="srespatual" value="#resp#">
		<cfset falta = lscurrencyformat(qResposta.RIP_Falta,'Local')>
		<cfset sobra = lscurrencyformat(qResposta.RIP_Sobra,'Local')>
		<cfset emrisco = lscurrencyformat(qResposta.RIP_EmRisco,'Local')>
		<input type="hidden" name="sfrmfalta" id="sfrmfalta" value="#falta#">
		<input type="hidden" name="sfrmsobra" id="sfrmsobra" value="#sobra#">
		<input type="hidden" name="sfrmemrisco" id="sfrmemrisco" value="#emrisco#">
		<input type="hidden" name="sVLRDEC" id="sVLRDEC" value="#url.VLRDEC#">
		<input type="hidden" name="situacao" id="situacao" value="#url.situacao#">
	</cfoutput>
    <tr bgcolor="eeeeee">
      <td colspan="5"><p class="titulo1">
	    <input type="hidden" id="pg" name="pg" value="<cfoutput>#URL.pg#</cfoutput>"> 
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
		<input type="hidden" id="modal" name="modal" value="<cfoutput>#URL.modal#</cfoutput>">
		<input type="hidden" id="tpunid" name="tpunid" value="<cfoutput>#URL.tpunid#</cfoutput>">
      </p></td>
    </tr>
	  <tr>
      <td width="95" bgcolor="eeeeee" class="exibir">Unidade</td>
      <td width="324" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Unid#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td colspan="3" bgcolor="eeeeee"><span class="exibir">Respons&aacute;vel</span>&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
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
      <td bgcolor="eeeeee">N° Relatório</td>
      <td colspan="4" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ninsp#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In&iacute;cio Inspe&ccedil;&atilde;o &nbsp;<strong class="exibir"><cfoutput>#DateFormat(qResposta.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></strong></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Grupo</td>
      <td colspan="4" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ngrup#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Grp_Descricao#</strong></cfoutput></td>
    </tr>

    <tr class="exibir">
      <td bgcolor="eeeeee">Item</td>
      <td colspan="4" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Nitem#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Itn_Descricao#</strong></cfoutput></td>
    </tr>
	
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
		<td>Manchete</td>
		<td colspan="4"><cfoutput><strong class="exibir">#qResposta.RIP_Manchete#</strong></cfoutput></td>
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
	  </table>
	  </td>
 	 </tr>	
    <cfoutput>
	  <cfset db_reincInsp = #trim(qResposta.RIP_ReincInspecao)#>
	  <cfset db_reincGrup = #qResposta.RIP_ReincGrupo#>
	  <cfset db_reincItem = #qResposta.RIP_ReincItem#>
	  <cfif len(trim(qResposta.RIP_ReincInspecao)) gt 0>
		  
	<tr class="red_titulo">
	  <td bgcolor="eeeeee">Reincidência</td>  
	      <input type="hidden" name="db_reincSN" id="db_reincSN" value="N">
		   <cfset reincSN = "S">
		   <input type="hidden" name="db_reincSN" id="db_reincSN" value="S">
		   <cfset db_reincInsp = #trim(qResposta.RIP_ReincInspecao)#>
		   <cfset db_reincGrup = #qResposta.RIP_ReincGrupo#>
		   <cfset db_reincItem = #qResposta.RIP_ReincItem#>
	<td  bgcolor="eeeeee" colspan="4">Nº Avaliação:<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" style="background:white" readonly="">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Grupo:<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" style="background:white" readonly="">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Item:<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" style="background:white" readonly=""></td>
	</tr>
	</cfif>
	</cfoutput>	
	<cfoutput>
	<cfset tipoimpacto = 'NÃO QUANTIFICADO'>
	<cfif listFind(#qResposta.Itn_PTC_Seq#,'10')>
		<cfset tipoimpacto = 'QUANTIFICADO'>
	</cfif>
	<cfset impactofin = 'N'>
	<cfset impactofalta = 'N'>
	<cfset impactosobra = 'N'>
	<cfset impactoemrisco = 'N'>
	<cfif listFind(#qResposta.Itn_ImpactarTipos#,'F')>
	  	<cfset impactofin = 'S'>
	    <cfset impactofalta = 'F'>
	</cfif>
	<cfif listFind(#qResposta.Itn_ImpactarTipos#,'S')>
	  	<cfset impactofin = 'S'>
	    <cfset impactosobra = 'S'>
	</cfif>	
	<cfif listFind(#qResposta.Itn_ImpactarTipos#,'R')>
	  	<cfset impactofin = 'S'>
	    <cfset impactoemrisco = 'R'>
	</cfif>	
	<cfif tipoimpacto eq 'QUANTIFICADO'>
 	<tr class="exibir">
      <td bgcolor="eeeeee"><div id="impactofin">IMPACTO FINANCEIRO</div></td>
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
</cfif>	
<tr>
	<td bgcolor="eeeeee" align="center"><span class="titulos">Manchete:</span></td>
	<td colspan="6" bgcolor="eeeeee"><textarea  name="manchete" id="manchete" cols="168" rows="3" wrap="VIRTUAL" class="form"><cfoutput>#form.manchete#</cfoutput></textarea></td>
</tr>		
	 </cfoutput>

	<tr>
		<td bgcolor="#eeeeee" align="center"><span class="titulos">Situação Encontrada:</span></td>
		<td colspan="5" bgcolor="eeeeee"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Comentario#</cfoutput></textarea></td>
	</tr>
	<tr>
		<td bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
		<td colspan="5" bgcolor="eeeeee"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form"><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea></td>
	</tr> 
	<input type="hidden" name="tamMelho" id="tamMelho" value="<cfoutput>#len(trim(qResposta.RIP_Comentario))#</cfoutput>">
	<input type="hidden" name="tamrecom" id="tamrecom" value="<cfoutput>#len(trim(qResposta.RIP_Recomendacoes))#</cfoutput>">
	<input type="hidden" name="tamanchete" id="tamanchete" value="<cfoutput>#len(trim(form.manchete))#</cfoutput>">

    <tr bgcolor="eeeeee">
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
			    </cfif>				</td>
				<cfset aux_ano = right(dateformat(now(),"YYYY"),2)>
				<td width="77%" bgcolor="eeeeee" class="exibir"><div id="ncisei">N° SEI da NCI :&nbsp;&nbsp;
                   <input name="frmnumseinci" id="frmnumseinci" type="text" class="form" onBlur="controleNCI()"  onKeyPress="numericos();" onKeyDown="validacao(); Mascara_SEI(this);" size="27" maxlength="20" value="<cfoutput>#numncisei#</cfoutput>">
				  </div>				  </td>
		      </tr>
        </table>       </td>
    </tr>
    <tr>
      <td colspan="5" class="exibir" bgcolor="eeeeee"><div align="left"><strong class="exibir">ANEXOS</strong></div></td>
    </tr>

	<tr>
        <td bgcolor="eeeeee" class="exibir"><strong class="exibir">Arquivo:</strong></td>
        <td bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td bgcolor="eeeeee" class="exibir">&nbsp;</td>
        <td bgcolor="eeeeee" class="exibir"><input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar"></td>
        <td width="51" bgcolor="eeeeee" class="exibir">&nbsp;</td>
      </tr>
      <tr bgcolor="eeeeee">
        <td colspan="5">&nbsp;</td>
      </tr>
 <!--- <cfset resp = qResposta.Pos_Situacao_Resp> --->
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
          <td colspan="3" bgcolor="#eeeeee" class="form"><cfoutput>#cl# - #ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
          <td width="472" bgcolor="#eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                  <div align="left">
                    &nbsp;
                    <input id="Abrir" type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />
                </div></td>
		  <td bgcolor="eeeeee"><cfoutput>
              <div align="center">
				<cfif (resp neq 24 and cla eq qAnexos.recordcount)>
                   <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value='#qAnexos.Ane_Codigo#'" value="Excluir" codigo="#qAnexos.Ane_Codigo#">		   
                <cfelse>
                   <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value='#qAnexos.Ane_Codigo#'" value="Excluir" codigo="#qAnexos.Ane_Codigo#" disabled>
				</cfif>
		        </div>
		  </cfoutput></td>
        </tr>
      </cfif>
    </cfloop>
	<tr bgcolor="eeeeee">
      <td colspan="5">&nbsp;</td>
    </tr>

	<tr>
	<td colspan="6" bgcolor="eeeeee" class="exibir"><div align="left">Selecione a Área:
	      <select name="frmcbarea" id="frmcbarea" class="form">
                  <option value="">---</option>
                  <cfoutput query="qArea">
                      <option value="#Ars_Codigo#">#trim(Ars_Descricao)#</option>
                  </cfoutput>
            </select>
    </div></td>
	</tr>
<cfoutput>
 	
	<tr bgcolor="eeeeee">
		<td colspan="5" align="center">
			<input name="button" type="button" class="botao" onClick="history.back();" value="Voltar">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<cfif (resp is 0) or (resp is 11)>
				<input name="Submit" type="Submit" class="botao" value="Salvar" onClick="document.form1.frmcbarea.disabled=false; document.form1.acao.value='Salvar';">
			<cfelse>
				<input name="Submit" type="Submit" class="botao" value="Salvar" onClick="document.form1.frmcbarea.disabled=false; document.form1.acao.value='Salvar';" disabled>
			</cfif>	  
		</td>
	</tr>
	</cfoutput>  
	<script>
		hanci();
		controleNCI(); 
		exibir_Area011(document.form1.nci.value);
		document.form1.frmcbarea.disabled=true;
	</script>
		<input type="hidden" name="frmimpactofin" id="frmimpactofin" value="<cfoutput>#impactofin#</cfoutput>">
		<input type="hidden" name="frmimpactofalta" id="frmimpactofalta" value="<cfoutput>#impactofalta#</cfoutput>">
		<input type="hidden" name="frmimpactosobra" id="frmimpactosobra" value="<cfoutput>#impactosobra#</cfoutput>">
		<input type="hidden" name="frmimpactoemrisco" id="frmimpactoemrisco" value="<cfoutput>#impactoemrisco#</cfoutput>">
	</form>
</table>
	<style>
        .cke_top{
            <!---background:#003366; --->
        }
    </style>
<script>
	
		CKEDITOR.replace('Melhoria', {
			width: '1020',
			height: 200,
			removePlugins: 'scayt',
			disableNativeSpellChecker: false,
			line_height:'1px',
			disableObjectResizing:true,
			toolbar: [
				['Preview', 'Print', '-' ],
				[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat','-', 'Undo', 'Redo', '-','Find' ],
				['SelectAll', '-'],
				[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
				[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
				['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
				'/',
				['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','-','Imagem','-','Maximize','Table'  ]
			]
		});

		CKEDITOR.replace('recomendacao', {
			width: '1020',
			height: 200,
			removePlugins: 'scayt',
			disableNativeSpellChecker: false,
			toolbar: [
				['Preview', 'Print', '-' ],
				[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat','-', 'Undo', 'Redo', '-','Find' ],
				['SelectAll', '-'],
				[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
				[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
				['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
				['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize','Table'  ]
			]
		});
	
</script>

</body>
</html>

<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>
