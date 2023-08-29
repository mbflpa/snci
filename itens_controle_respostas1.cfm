<cfprocessingdirective pageEncoding ="utf-8"/>  
<!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
<!---  <cfdump var="#url#">  --->
 
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
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email 
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>

<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>

<cfif (grpacesso neq 'GESTORES') and (grpacesso neq 'DESENVOLVEDORES') and (grpacesso neq 'GESTORMASTER') and (grpacesso neq 'ANALISTAS') and (grpacesso neq 'GOVERNANCA')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>   
</cfif>                 

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email, Usu_Coordena
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email, Usu_Coordena
</cfquery>

<cfquery name="rsSEINCI" datasource="#dsn_inspecao#">
 SELECT Pos_NCISEI FROM ParecerUnidade WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NCISEI Is Not Null ORDER BY Pos_NCISEI DESC
</cfquery>

<cfif (grpacesso eq 'GESTORES') or (grpacesso eq 'DESENVOLVEDORES') or (grpacesso eq 'GESTORMASTER') or (grpacesso eq 'ANALISTAS')>

<!---  <cftry>  --->
  <cfif isDefined("Form.acao") And (Form.acao is 'alter_valores' Or Form.acao is 'Excluir_Proc' Or Form.acao is 'Incluir_Proc' Or Form.acao is 'Excluir_Sei' Or Form.acao is 'Incluir_Causa' Or Form.acao is 'Anexar' Or Form.acao is 'Excluir_Anexo' Or Form.acao is 'Excluir_Causa')>
  <cfif isDefined("Form.abertura")><cfset Session.E01.abertura = Form.abertura><cfelse><cfset Session.E01.abertura = 'Nao'></cfif>
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
  <cfif isDefined("Form.posarea")><cfset Session.E01.posarea = Form.posarea><cfelse><cfset Session.E01.posarea = ''></cfif>

	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
<!--- Excluir Processo --->
 <cfif Form.acao is 'Excluir_Proc'>
	<cfquery datasource="#dsn_inspecao#">
		DELETE FROM Inspecao_ProcDisciplinar WHERE (PDC_Unidade='#unid#' AND PDC_Inspecao='#ninsp#' AND PDC_Grupo=#ngrup# AND 
		PDC_Item=#nitem# AND PDC_Processo='#form.frmpdc_processo#' AND PDC_ProcSEI='#FORM.frmpdc_procsei#')
	</cfquery>
		 		  
  
    <cfset aux_sei = trim(FORM.frmpdc_procsei)>
    <cfset aux_sei = left(aux_sei,5) & '.' & mid(aux_sei,6,6) & '/' & mid(aux_sei,12,4) & '-' & right(aux_sei,2)>
	<cfset aux_proc = left(FORM.frmpdc_processo,2) & '-' & mid(frmpdc_processo,3,5)  & '-' & right(frmpdc_processo,2)>
		
	<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Registro de Processo Disciplinar(Exclusão' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do Processo: ' & #aux_proc# & CHR(13) & CHR(13) & 'Modalidade: ' & #form.frmpdc_procmodal# & CHR(13) & CHR(13) & 'N.SEI(Processo): ' & #aux_sei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
    <cfquery datasource="#dsn_inspecao#">
     UPDATE ParecerUnidade SET Pos_Parecer= '#pos_aux#' WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
    </cfquery>	
    <cfquery name="rsSitAtual" datasource="#dsn_inspecao#">
	  SELECT Pos_Situacao_Resp, Pos_DtPosic
	  FROM ParecerUnidade
	  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
	</cfquery>
	<cfset prazo = CreateDate(year(rsSitAtual.Pos_DtPosic),month(rsSitAtual.Pos_DtPosic),day(rsSitAtual.Pos_DtPosic))>

     <cfquery name="rsAnd" datasource="#dsn_inspecao#">
	  SELECT and_Parecer
	  FROM Andamento
	  WHERE And_Unidade='#unid#' AND And_NumInspecao='#ninsp#' AND And_NumGrupo=#ngrup# AND And_NumItem=#nitem# and And_DtPosic = #prazo# and And_Situacao_Resp = #rsSitAtual.Pos_Situacao_Resp#
	</cfquery>
	<cfif rsAnd.recordcount gt 0>
		<cfset and_aux = #rsAnd.and_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Registro de Processo Disciplinar(Exclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do Processo: ' & #aux_proc# & CHR(13) & CHR(13) & 'Modalidade: ' & #form.frmpdc_procmodal# & CHR(13) & CHR(13) & 'N.SEI(Processo): ' & #aux_sei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Andamento SET and_Parecer= '#and_aux#' 
			WHERE And_Unidade='#unid#' AND And_NumInspecao='#ninsp#' AND And_NumGrupo=#ngrup# AND And_NumItem=#nitem# and And_DtPosic = #prazo# and And_Situacao_Resp = #rsSitAtual.Pos_Situacao_Resp#
		</cfquery>
    </cfif>	
</cfif>

<!--- Incluir N. Processo --->

<cfif Form.acao is "Incluir_Proc">
	<cfset aux_sei = Trim(FORM.frmprocsei)>
	<cfset aux_sei = Replace(aux_sei,'.','',"All")>
	<cfset aux_sei = Replace(aux_sei,'/','','All')>
	<cfset aux_sei = Replace(aux_sei,'-','','All')>

	<cfset aux_proc = FORM.proc_se & FORM.proc_num & FORM.proc_ano>
		
	<cfif len(trim(FORM.proc_num)) eq 5>
		<cfquery datasource="#dsn_inspecao#" name="qExitesSEI">
			SELECT PDC_Unidade FROM Inspecao_ProcDisciplinar
			WHERE (PDC_Unidade='#unid#' AND PDC_Inspecao='#ninsp#' AND PDC_Grupo=#ngrup# AND PDC_Item=#nitem# AND PDC_Processo='#aux_proc#' AND PDC_ProcSEI='#aux_sei#')
		</cfquery>

		<cfif qExitesSEI.RecordCount eq 0>
			  <cfquery datasource="#dsn_inspecao#" name="qVerificaCausa">
					 INSERT Inspecao_ProcDisciplinar(PDC_Unidade, PDC_Inspecao, PDC_Grupo, PDC_Item, PDC_Processo, PDC_Modalidade, PDC_ProcSEI, PDC_dtultatu, PDC_username)
					 VALUES ('#unid#','#ninsp#', #ngrup#, #nitem#, '#aux_proc#', '#Form.Modalidade#', '#aux_sei#', convert(char, getdate(), 120), '#CGI.REMOTE_USER#')
			  </cfquery>
			  <cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Registro de Processo Disciplinar(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do Processo: ' & #FORM.proc_se# & '-' & #FORM.proc_num# & '-' & #FORM.proc_ano# & CHR(13) & CHR(13) & 'Modalidade: ' & #FORM.Modalidade# & CHR(13) & CHR(13) & 'N.SEI(Processo): ' & #FORM.frmprocsei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
			  <cfset and_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de Processo Disciplinar(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do Processo: ' & #FORM.proc_se# & '-' & #FORM.proc_num# & '-' & #FORM.proc_ano# & CHR(13) & CHR(13) & 'Modalidade: ' & #FORM.Modalidade# & CHR(13) & CHR(13) & 'N.SEI(Processo): ' & #FORM.frmprocsei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
		</cfif>	
	<cfelse>
		<cfquery datasource="#dsn_inspecao#" name="qExitesSEI">
			SELECT SEI_Inspecao FROM Inspecao_SEI
			WHERE (SEI_Unidade='#unid#' AND SEI_Inspecao='#ninsp#' AND SEI_Grupo=#ngrup# AND SEI_Item=#nitem# AND SEI_NumSEI='#aux_sei#')
		</cfquery>

		<cfif qExitesSEI.RecordCount eq 0>
			<cfquery datasource="#dsn_inspecao#" name="qVerificaCausa">
				INSERT Inspecao_SEI(SEI_Unidade, SEI_Inspecao, SEI_Grupo, SEI_Item, SEI_NumSEI, SEI_dtultatu, SEI_username)
				VALUES ('#unid#','#ninsp#', #ngrup#, #nitem#, '#aux_sei#', convert(char, getdate(), 120), '#CGI.REMOTE_USER#')
			</cfquery>    
			<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Registro de N.SEI Apuracao(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do SEI: ' & #FORM.frmprocsei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
			<cfset and_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Registro de N.SEI Apuracao(Inclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do SEI: ' & #FORM.frmprocsei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
		</cfif>
	</cfif>	
	
  	<!--- Atualizar PareceUnidade --->
    <cfquery datasource="#dsn_inspecao#">
     UPDATE ParecerUnidade SET Pos_Parecer= '#pos_aux#' WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
    </cfquery>
    
    <cfquery name="rsSitAtual" datasource="#dsn_inspecao#">
	  SELECT Pos_Situacao_Resp, Pos_DtPosic
	  FROM ParecerUnidade
	  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
	</cfquery>
	<cfset prazo = CreateDate(year(rsSitAtual.Pos_DtPosic),month(rsSitAtual.Pos_DtPosic),day(rsSitAtual.Pos_DtPosic))>
     <cfquery name="rsAnd" datasource="#dsn_inspecao#">
	  SELECT and_Parecer
	  FROM Andamento
	  WHERE And_Unidade='#unid#' AND And_NumInspecao='#ninsp#' AND And_NumGrupo=#ngrup# AND And_NumItem=#nitem# and And_DtPosic = #prazo# and And_Situacao_Resp = #rsSitAtual.Pos_Situacao_Resp#
	</cfquery>
	<cfif rsAnd.recordcount gt 0>
		<cfset and_aux = #rsAnd.and_Parecer# & CHR(13) & CHR(13) & #and_aux#>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Andamento SET and_Parecer= '#and_aux#' 
			WHERE And_Unidade='#unid#' AND And_NumInspecao='#ninsp#' AND And_NumGrupo=#ngrup# AND And_NumItem=#nitem# and And_DtPosic = #prazo# and And_Situacao_Resp = #rsSitAtual.Pos_Situacao_Resp#
		</cfquery>
    </cfif>
    	  
    <cfset houveProcSN = 'S'>

</cfif>

 <!--- Excluir N. SEI --->
 <cfif Form.acao is 'Excluir_Sei'>
	<cfquery datasource="#dsn_inspecao#">
		DELETE FROM Inspecao_SEI WHERE (SEI_Unidade='#unid#' AND SEI_Inspecao='#ninsp#' AND SEI_Grupo=#ngrup# AND SEI_Item=#nitem# AND SEI_NumSEI='#Form.dbfrmnumsei#')
	</cfquery>
	<cfset aux_sei = left(Form.dbfrmnumsei,5) & '.' & mid(Form.dbfrmnumsei,6,6) & '/' & mid(Form.dbfrmnumsei,12,4) & '-' & right(Form.dbfrmnumsei,2)>
    <cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Registro de N.SEI Apuracao(Exclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do SEI: ' & #aux_sei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
    <cfquery datasource="#dsn_inspecao#">
     UPDATE ParecerUnidade SET Pos_Parecer= '#pos_aux#' WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
    </cfquery>	
    <cfquery name="rsSitAtual" datasource="#dsn_inspecao#">
	  SELECT Pos_Situacao_Resp, Pos_DtPosic
	  FROM ParecerUnidade
	  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
	</cfquery>
	<cfset prazo = CreateDate(year(rsSitAtual.Pos_DtPosic),month(rsSitAtual.Pos_DtPosic),day(rsSitAtual.Pos_DtPosic))>
     <cfquery name="rsAnd" datasource="#dsn_inspecao#">
	  SELECT and_Parecer
	  FROM Andamento
	  WHERE And_Unidade='#unid#' AND And_NumInspecao='#ninsp#' AND And_NumGrupo=#ngrup# AND And_NumItem=#nitem# and And_DtPosic = #prazo# and And_Situacao_Resp = #rsSitAtual.Pos_Situacao_Resp#
	</cfquery>
	<cfif rsAnd.recordcount gt 0>
		<cfset and_aux = #rsAnd.and_Parecer# & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Registro de N.SEI Apuracao(Exclusão)' & CHR(13) & CHR(13) & 'Data de Atualização: ' & #DateFormat(now(),"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Número do SEI: ' & #FORM.dbfrmnumsei# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'> 
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Andamento SET and_Parecer= '#and_aux#' 
			WHERE And_Unidade='#unid#' AND And_NumInspecao='#ninsp#' AND And_NumGrupo=#ngrup# AND And_NumItem=#nitem# and And_DtPosic = #prazo# and And_Situacao_Resp = #rsSitAtual.Pos_Situacao_Resp#
		</cfquery>
    </cfif>		
</cfif>

<!--- Incluir Causa Provavel --->

<cfif Form.acao is "Incluir_Causa" and Form.causaprovavel neq "">
  	<cfquery datasource="#dsn_inspecao#" name="qVerificaRegistroParecer">
	SELECT PCP_Unidade FROM ParecerCausaProvavel
    WHERE (((PCP_Unidade)='#unid#') AND ((PCP_Inspecao)='#ninsp#') AND ((PCP_NumGrupo)=#ngrup#) AND ((PCP_NumItem)=#nitem#) AND ((PCP_CodCausaProvavel)=#Form.causaprovavel#))
	</cfquery>

    <cfif qVerificaRegistroParecer.RecordCount eq 0>
		  <cfquery datasource="#dsn_inspecao#" name="qVerificaCausa">
				 INSERT ParecerCausaProvavel(PCP_Unidade, PCP_Inspecao, PCP_NumGrupo, PCP_NumItem, PCP_CodCausaProvavel)
				 VALUES ('#unid#', '#ninsp#', #ngrup#, #nitem#, #Form.causaprovavel#)
		  </cfquery>
    </cfif>
</cfif>

<!--- Anexar arquivo --->

<cfif Form.acao is 'Anexar'>
<cftry>
<!--- <cfoutput>
  arquivo:#arquivo#<br>
  direto: #diretorio_anexos#<br>
  serverdir: #cffile.serverdirectory#<br>
  serverfile: #cffile.serverfile#<br>
  <cfset gil = gil>
  </cfoutput> --->
	

		<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		<!--- O arquivo anexo recebe nome indicando Numero da Inspecao, Numero da unidade, Numero do grupo e Numero do item ao qual estao vinculado --->

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
			<cfset mensagem = 'Ocorreu um erro ao efetuar esta operacao, o campo Arquivo estao vazio, Selecione um arquivo no formato PDF'>
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


 <cfquery name="qUnidade" datasource="#dsn_inspecao#">
		SELECT Und_descricao FROM Unidades
		WHERE UND_codigo='#unid#'
 </cfquery>

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
	<cfparam name="URL.posarea" default="#Form.posarea#">
	<cfset auxavisosn = "N">
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
	<cfparam name="URL.VLRDEC" default="">
	<cfparam name="URL.situacao" default="">		
	<cfparam name="URL.posarea" default="">
	<cfset auxavisosn = "S">
</cfif>
<cfquery name="rsTercTransfer" datasource="#dsn_inspecao#">
  SELECT Und_CodDiretoria, Und_Codigo, Und_Descricao, Und_Email
  FROM Unidades 
  WHERE Und_Status = 'A' and Und_CodDiretoria = '#left(URL.posarea,2)#' and Und_TipoUnidade in (12,16)
</cfquery>
<cfquery name="rsUnidTransfer" datasource="#dsn_inspecao#">
  SELECT Und_CodDiretoria, Und_Codigo, Und_Descricao, Und_Email
  FROM Unidades 
  WHERE Und_Status = 'A' and Und_CodDiretoria = '#left(URL.posarea,2)#' and Und_TipoUnidade not in (12,16)
</cfquery>
<cfquery name="rsReopTransfer" datasource="#dsn_inspecao#">
  SELECT Rep_Codigo, Rep_Nome, Rep_Email 
  FROM Reops 
  WHERE Rep_Status = 'A' and Rep_CodDiretoria = '#left(URL.posarea,2)#'
</cfquery>

<cfset auxtransfer = 'N'>
<cfif left(URL.Unid,2) neq left(url.posarea,2)>
 <cfset auxtransfer = 'S'>
</cfif>

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
  FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

 <cfset strIDGestor = #URL.Unid#>
 <cfset strNomeGestor = #rsMod.Und_Descricao#>
 <cfset Gestor = '#rsMod.Und_Descricao#'>

<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar2">
	<!--- INICIO EVITAR DUPLICATAS DE  --->
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
	<cfset auxposarea = #form.unid#>
	<cfif Form.frmResp is 2 or Form.frmResp is 15>
	   <cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
		   <cfquery name="rsCDD" datasource="#dsn_inspecao#">
			  SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsMod.Und_Centraliza#'
		   </cfquery>
		   <cfif rsCDD.recordcount gt 0>
			  <cfset strIDGestor = #rsCDD.Und_Codigo#>
		   </cfif>
	  </cfif>
	  <cfset auxposarea = #strIDGestor#>
	<cfelseif Form.frmResp is 3>
	  <cfset auxposarea = '#qSituacaoResp.Pos_Area#'>
	<cfelseif Form.frmResp is 4>
	  <cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
		   <!--- uma AC  => verificar se centralizada --->
		  <cfset strIDGestor = #rsMod.Und_Centraliza#>
	  </cfif>
	  <cfquery name="rsReop" datasource="#dsn_inspecao#">
		  SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
	  </cfquery>
	  <cfset auxposarea = #rsReop.Rep_Codigo#>
	<cfelseif Form.frmResp is 5 or Form.frmResp is 10 or Form.frmResp is 19 or Form.frmResp is 21 or Form.frmResp is 25 or Form.frmResp is 26>
		<cfset auxposarea = #Form.cbarea#>
	<cfelseif Form.frmResp is 4>  
		<cfset auxposarea = #rsMod.Dir_Sto#>
	<cfelseif Form.frmResp is 9 or Form.frmResp is 24 or Form.frmResp is 29>
		<cfset auxposarea = #Form.cbareaCS#>
	<cfelseif Form.frmResp is 12 or Form.frmResp is 13 or Form.frmResp is 18 or Form.frmResp is 20 or Form.frmResp is 28>
		<cfset auxposarea = #strIDGestor#>
	<cfelseif Form.frmResp is 16>
		<cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
		  <cfset strIDGestor = #rsMod.Und_Centraliza#>
		</cfif>
		<cfquery name="rsReop" datasource="#dsn_inspecao#">
		  SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
		</cfquery>
		<cfset auxposarea = #rsReop.Rep_Codigo#>
	<cfelseif Form.frmResp is 23>
		<cfset auxposarea = #rsMod.Dir_Sto#>
	<cfelseif Form.frmResp is 30>	
		<cfset auxposarea = #Form.cbscoi#>	
	</cfif>

<!---  --->
	<cfquery datasource="#dsn_inspecao#" name="rsDuplo">
		select Pos_Situacao_Resp from ParecerUnidade
		WHERE Pos_Unidade= '#FORM.unid#' AND 
		Pos_Inspecao='#FORM.ninsp#' AND 
		Pos_NumGrupo=#FORM.ngrup# AND 
		Pos_NumItem=#FORM.nitem# and
		Pos_Situacao_Resp = #FORM.frmResp# and
		Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))# and
		pos_username = '#CGI.REMOTE_USER#' and
		Pos_Area = '#auxposarea#'
	</cfquery>
	<cfset auxsalvarSN = 'S'>
	<cfif rsDuplo.recordcount gt 0>
		<cfset auxsalvarSN = 'N'>
		<script>
		   <cfoutput>
			 alert('Duplicidade de Registro!\n\nSr(a) Gestor(a), informação já foi cadastrada para o ' + '\nRelatório: #FORM.ninsp#' + ' Grupo: #FORM.ngrup#' + ' Item: #FORM.nitem#' + ' Status: #FORM.frmResp#' + ' Destinatário: #auxposarea#' + ' e \nUsuário: #maskcgiusu#');
		   </cfoutput>
		</script>
		
	</cfif>

	<!--- fim EVITAR DUPLICATAS DE  --->	

	<cfif auxsalvarSN is 'S'>	  	
       <!--- data do dia default --->
		<cfset dtnovoprazo = CreateDate(right(form.cbdata,4),mid(form.cbdata,4,2),left(form.cbdata,2))> 
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
  UPDATE ParecerUnidade SET
  <cfif IsDefined("FORM.frmResp") AND FORM.frmResp NEQ "N">
    Pos_Situacao_Resp=#FORM.frmResp#
  </cfif>
  <cfset IDArea = #form.unid#>
  <cfswitch expression="#Form.frmResp#">
	<cfcase value=2>
	    <cfif form.frmtransfer eq 'S'>
			<cfquery name="rsMod" datasource="#dsn_inspecao#">
				SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
				FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
				WHERE Und_Codigo = '#form.cbunidtransfer#'
			</cfquery>
			 <cfset strIDGestor = #form.cbunidtransfer#>
             <cfset strNomeGestor = #rsMod.Und_Descricao#>
             <cfset Gestor = '#rsMod.Und_Descricao#'>
		</cfif>			
	   <!--- Atualizar variaveis com os dados do CDD ---> 
	   <!--- Item da AC respondido por CDD quando Centralizada --->
	   <cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
	       <!--- uma AC  => verificar se centralizada --->
		   <cfquery name="rsCDD" datasource="#dsn_inspecao#">
			  SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsMod.Und_Centraliza#'
		   </cfquery>
		   <cfif rsCDD.recordcount gt 0>
			  <cfset strIDGestor = #rsCDD.Und_Codigo#>
			  <cfset strNomeGestor = #rsCDD.Und_Descricao#>
			  <cfset Gestor = '#strNomeGestor#'>
		   </cfif>
	  </cfif>
	  , Pos_Situacao = 'PU'
	  , Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	  <cfset situacao = 'PENDENTE DE UNIDADE'>
	  <cfset IDArea = #strIDGestor#>
	</cfcase>
	<cfcase value=3>
	  , Pos_Situacao = 'SO'
	  <!---, Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'--->
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset situacao = 'SOLUCIONADO'>
	  <cfset IDArea = '#qSituacaoResp.Pos_Area#'>
	</cfcase>
	<cfcase value=4>
	    <cfif form.frmtransfer eq 'S'>
			  <cfquery name="rsReop" datasource="#dsn_inspecao#">
				  SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops WHERE Rep_Codigo = '#form.cbsubordinador#'
			  </cfquery>		
		<cfelse>
			  <cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
				   <!--- uma AC  => verificar se centralizada --->
				  <cfset strIDGestor = #rsMod.Und_Centraliza#>
			  </cfif>
			  <cfquery name="rsReop" datasource="#dsn_inspecao#">
				  SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
			  </cfquery>		
		</cfif>		  
	   , Pos_Situacao = 'PO'
	   , Pos_Area = '#rsReop.Rep_Codigo#'
	   , Pos_Nomearea = '#rsReop.Rep_Nome#'
	   , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	   <cfset Gestor = '#rsReop.Rep_Nome#'>
	   <cfset situacao = 'PENDENTE DE ORGAO SUBORDINADOR'>
	   <cfset IDArea = #rsReop.Rep_Codigo#>
	   <cfset sdestina = #rsReop.Rep_Email#>
  	   <cfset nomedestino = #rsReop.Rep_Nome#>
	 </cfcase>
	<cfcase value=5>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao, Ars_Email 
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbarea#'
	  </cfquery>
	   , Pos_Situacao = 'PA'
	   , Pos_Area = '#Form.cbarea#'

	   , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	   , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	   <cfset Gestor = '#qArea2.Ars_Descricao#'>
	   <cfset situacao = 'PENDENTE DE AREA'>
	   <cfset IDArea = #Form.cbarea#>
	   <cfset sdestina = #qArea2.Ars_Email#>
  	   <cfset nomedestino = #qArea2.Ars_Descricao#>
	</cfcase>
	<cfcase value=8>
		<cfquery name="rsSE" datasource="#dsn_inspecao#">
			SELECT Dir_Sto, Dir_Codigo, Dir_Descricao, Dir_Email
			FROM  Diretoria
			WHERE Dir_Codigo = '#left(form.posarea,2)#'
		</cfquery>
	  , Pos_Situacao = 'SE'
	  , Pos_Area = '#rsSE.Dir_Sto#'
	  , Pos_NomeArea = '#rsSE.Dir_Descricao#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	  <cfset Gestor = '#rsSE.Dir_Descricao#'>
	  <cfset situacao = 'PENDENTE SUPERINTENDENCIA ESTADUAL'>
	  <cfset IDArea = #rsSE.Dir_Sto#>
	  <cfset sdestina = #rsSE.Dir_Email#>
  	  <cfset nomedestino = #rsSE.Dir_Descricao#>
	</cfcase>
	<cfcase value=9>
	   <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbareaCS#'
	   </cfquery>
	  , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	  , Pos_Situacao = 'CS'
	  , Pos_Area = '#Form.cbareaCS#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	   <cfset Gestor = '#qArea2.Ars_Descricao#'>
	   <cfset situacao = 'CORPORATIVO CS'>
	   <cfset IDArea = #Form.cbareaCS#>
	</cfcase>
	<cfcase value=10>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla,Ars_Descricao
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbarea#'
	  </cfquery>
      , Pos_Situacao = 'PS'
	  , Pos_Area = '#Form.cbarea#'
      , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
      <cfset Gestor = '#qArea2.Ars_Descricao#'>
	  <cfset situacao = 'PONTO SUSPENSO'>
	  <cfset IDArea = #Form.cbarea#>
	</cfcase>
	<cfcase value=12>
	  , Pos_Situacao = 'PI'
	  , Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset situacao = 'PONTO IMPROCEDENTE'>
	  <cfset IDArea = #strIDGestor#>
	</cfcase>
	<cfcase value=13>
	  , Pos_Situacao = 'OC'
	  , Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset situacao = 'ORIENTACAO CANCELADA'>
	  <cfset IDArea = #strIDGestor#>
	</cfcase>
	<cfcase value=15>
		<cfif form.frmtransfer eq 'S'>
			<cfquery name="rsMod" datasource="#dsn_inspecao#">
				SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
				FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
				WHERE Und_Codigo = '#form.cbunidtransfer#'
			</cfquery>
			 <cfset strIDGestor = #form.cbunidtransfer#>
             <cfset strNomeGestor = #rsMod.Und_Descricao#>
             <cfset Gestor = '#rsMod.Und_Descricao#'>
		</cfif>
	<!--- Atualizar variaveis com os dados do CDD ---> 
	   <!--- Item da AC respondido por CDD quando Centralizada --->
	   <cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
	       <!--- ao uma AC  => verificar se centralizada --->
		   <cfquery name="rsCDD" datasource="#dsn_inspecao#">
			  SELECT Und_Codigo, Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsMod.Und_Centraliza#'
		   </cfquery>
		   <cfif rsCDD.recordcount gt 0>
			  <cfset strIDGestor = #rsCDD.Und_Codigo#>
			  <cfset strNomeGestor = #rsCDD.Und_Descricao#>
			  <cfset Gestor = '#strNomeGestor#'>
		   </cfif>
	  </cfif>
	  , Pos_Situacao = 'TU'
	  , Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	<!---   <cfset Gestor = '#rsMod.Und_Descricao#'> --->
	  <cfset situacao = 'TRATAMENTO UNIDADE'>
	  <cfset IDArea = #strIDGestor#>
	  <cfset sdestina = #rsMod.Und_Email#>
  	  <cfset nomedestino = #rsMod.Und_Descricao#>
	</cfcase>
	<cfcase value=16>
        <cfif form.frmtransfer eq 'S'>
			  <cfquery name="rsReop" datasource="#dsn_inspecao#">
				  SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops WHERE Rep_Codigo = '#form.cbsubordinador#'
			  </cfquery>		
		<cfelse>
			  <cfif (trim(rsMod.Und_Centraliza) neq "") and (sfrmTipoUnidade eq 4)>
				   <!--- uma AC  => verificar se centralizada --->
				  <cfset strIDGestor = #rsMod.Und_Centraliza#>
			  </cfif>
			  <cfquery name="rsReop" datasource="#dsn_inspecao#">
				  SELECT Rep_Codigo, Rep_Nome, Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
			  </cfquery>		
		</cfif>	
	   , Pos_Situacao = 'TS'
	   , Pos_Area = '#rsReop.Rep_Codigo#'
	   , Pos_Nomearea = '#rsReop.Rep_Nome#'
	   , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	   <cfset Gestor = '#rsReop.Rep_Nome#'>
	   <cfset situacao = 'TRATAMENTO ORGAO SUBORDINADOR'>
	   <cfset IDArea = #rsReop.Rep_Codigo#>
	   <cfset sdestina = #rsReop.Rep_Email#>
  	   <cfset nomedestino = #rsReop.Rep_Nome#>
	 </cfcase>
	 <cfcase value=18>
		<cfif form.frmtransfer eq 'S'>
			<cfquery name="rsMod" datasource="#dsn_inspecao#">
			SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
			FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
			WHERE Und_Codigo = '#form.cbterctransfer#'
		    </cfquery>
			<cfset strIDGestor = #form.cbterctransfer#>
			<cfset strNomeGestor = #rsMod.Und_Descricao#>
			<cfset Gestor = '#rsMod.Und_Descricao#'>
		</cfif>
	  , Pos_Situacao = 'TF'
	  , Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	  <cfset Gestor = '#rsMod.Und_Descricao#'>
	  <cfset situacao = 'TRATAMENTO TERCEIRIZADA'>
	  <cfset IDArea = #strIDGestor#>
	  <cfset sdestina = #rsMod.Und_Email#>
  	  <cfset nomedestino = #rsMod.Und_Descricao#>
	</cfcase>
	<cfcase value=19>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao, Ars_Email FROM Areas	WHERE Ars_Codigo = '#Form.cbarea#'
	  </cfquery>
	   , Pos_Situacao = 'TA'
	   , Pos_Area = '#Form.cbarea#'
	   , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	   , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	   <cfset Gestor = '#qArea2.Ars_Descricao#'>
	   <cfset situacao = 'TRATAMENTO DA AREA'>
	   <cfset IDArea = #Form.cbarea#>
	   <cfset sdestina = #qArea2.Ars_Email#>
  	   <cfset nomedestino = #qArea2.Ars_Descricao#>
	</cfcase>
	<cfcase value=20>
		<cfif form.frmtransfer eq 'S'>
			<cfquery name="rsMod" datasource="#dsn_inspecao#">
			SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
			FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
			WHERE Und_Codigo = '#form.cbterctransfer#'
		    </cfquery>
			<cfset strIDGestor = #form.cbterctransfer#>
			<cfset strNomeGestor = #rsMod.Und_Descricao#>
			<cfset Gestor = '#rsMod.Und_Descricao#'>
		</cfif>	
	  , Pos_Situacao = 'PF'
	  , Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	  <cfset Gestor = '#rsMod.Und_Descricao#'>
	  <cfset situacao = 'PENDENTE DE TERCEIRIZADA'>
	  <cfset IDArea = #strIDGestor#>
	</cfcase>
	<cfcase value=21>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao, Ars_Email
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbscia#'
	  </cfquery>
	   , Pos_Situacao = 'RV'
	   , Pos_Area = '#Form.cbscia#'
	   , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	   , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	   <cfset Gestor = '#qArea2.Ars_Descricao#'>
	   <cfset situacao = 'REAVALIACAO'>
	   <cfset IDArea = #Form.cbscia#>
	   <cfset sdestina = #qArea2.Ars_Email#>
  	   <cfset nomedestino = #qArea2.Ars_Descricao#>
	</cfcase>
	<cfcase value=23>
	<!--- Status: Tratamento pela SE --->
		<cfquery name="rsSE" datasource="#dsn_inspecao#">
			SELECT Dir_Sto, Dir_Codigo, Dir_Descricao, Dir_Email
			FROM  Diretoria
			WHERE Dir_Codigo = '#left(form.posarea,2)#'
		</cfquery>
	  , Pos_Situacao = 'TO'
	  , Pos_Area = '#rsSE.Dir_Sto#'
	  , Pos_NomeArea = '#rsSE.Dir_Descricao#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	  <cfset Gestor = '#rsSE.Dir_Descricao#'>
	  <cfset IDArea = #rsSE.Dir_Sto#>
	  <cfset situacao = 'TRATAMENTO SUPERINTENDENCIA ESTADUAL'>
	  <cfset sdestina = #rsSE.Dir_Email#>
  	  <cfset nomedestino = #rsSE.Dir_Descricao#>
	</cfcase>
	<cfcase value=24>
	   <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbareaCS#'
	   </cfquery>
	  , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	  , Pos_Situacao = 'CS'
	  , Pos_Area = '#Form.cbareaCS#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	   <cfset Gestor = '#qArea2.Ars_Descricao#'>
	   <cfset situacao = 'APURACAO'>
	   <cfset IDArea = #Form.cbareaCS#>
	</cfcase>
	<cfcase value=25>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao, Ars_Email
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbarea#'
	  </cfquery>
	   , Pos_Situacao = 'RC'
	   , Pos_Area = '#Form.cbarea#'
	   , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	   , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	   <cfset Gestor = '#qArea2.Ars_Descricao#'>
	   <cfset situacao = 'REGULARIZADO - APLICAR O CONTRATO'>
	   <cfset IDArea = #Form.cbarea#>
	   <cfset sdestina = #qArea2.Ars_Email#>
  	   <cfset nomedestino = #qArea2.Ars_Descricao#>
	</cfcase>
	<cfcase value=26>
	  <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao, Ars_Email
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbarea#'
	  </cfquery>
	   , Pos_Situacao = 'NC'
	   , Pos_Area = '#Form.cbarea#'
	   , Pos_Nomearea = '#qArea2.Ars_Descricao#'
	   , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	   <cfset Gestor = '#qArea2.Ars_Descricao#'>
	   <cfset situacao = 'NAO REGULARIZADO - APLICAR O CONTRATO'>
	   <cfset IDArea = #Form.cbarea#>
	   <cfset sdestina = #qArea2.Ars_Email#>
  	   <cfset nomedestino = #qArea2.Ars_Descricao#>
	</cfcase>	   
    <cfcase value=28>
	  , Pos_Situacao = 'EA'
	  , Pos_Area = '#strIDGestor#'
	  , Pos_NomeArea = '#strNomeGestor#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	  <cfset situacao = 'EM ANALISE'>
	  <cfset IDArea = #strIDGestor#>
	</cfcase>	
	<cfcase value=29>
<!--- 	   <cfquery name="qArea2" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbareaCS#'
	   </cfquery> 
	  , Pos_Area = '#Form.cbareaCS#'	   
   	  , Pos_Nomearea = '#qArea2.Ars_Descricao#'--->
	  , Pos_Situacao = 'EC'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	  <cfset situacao = 'ENCERRADO'>
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset IDArea = '#qSituacaoResp.Pos_Area#'>
	</cfcase>	 
	  <cfcase value=30>
	   <cfquery name="qArea3" datasource="#dsn_inspecao#">
		SELECT Ars_Sigla, Ars_Descricao
		FROM Areas
		WHERE Ars_Codigo = '#Form.cbscoi#'
	   </cfquery>
	   
	  , Pos_Area = '#Form.cbscoi#'	   
   	  , Pos_Nomearea = '#qArea3.Ars_Descricao#'
	  , Pos_Situacao = 'TP'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(dtnovoprazo),month(dtnovoprazo),day(dtnovoprazo)))#
	  <cfset situacao = 'TRANSFERENCIA DE PONTO'>
	  <cfset Gestor = '#qArea3.Ars_Sigla#'>		  
	  <cfset IDArea = #Form.cbscoi#>
	</cfcase>
	<cfcase value=31>
	  , Pos_Situacao = 'JD'
	  , Pos_NumProcJudicial = '#Form.posnumprocjudicial#'
	  , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(now()),month(now()),day(now())))#
	   <cfset dtnovoprazo = CreateDate(year(now()),month(now()),day(now()))>
	  <cfset Gestor = '#qSituacaoResp.Pos_NomeArea#'>
	  <cfset situacao = 'JUDICIALIZADO'>
	  <cfset IDArea = '#qSituacaoResp.Pos_Area#'>
	</cfcase>	
  </cfswitch>
    
  <cfset Encaminhamento = 'Opiniao do Controle Interno'>
  <cfset aux_obs = "">  

  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
  , Pos_Parecer=
  <!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instrua§aµes SQL --->
	  <cfset aux_obs = Trim(FORM.observacao)>
	  <cfset aux_obs = Replace(aux_obs,'"','','All')>
	  <cfset aux_obs = Replace(aux_obs,"'","","All")>
	  <cfset aux_obs = Replace(aux_obs,'*','','All')>
      <cfset aux_obs = Replace(aux_obs,'>','','All')>
	<!---	 <cfset aux_obs = Replace(aux_obs,'&','','All')>
		     <cfset aux_obs = Replace(aux_obs,'%','','All')> --->
  
      <cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'A(O)' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	 <cfif "#Form.frmResp#" eq 25 || "#Form.frmResp#" eq 26 >
		<cfset pos_aux = Form.H_obs & CHR(13) & CHR(13) & DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)# & CHR(13) & CHR(13) & 'A(O)' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'> 
	 </cfif> 	 
		 
	'#pos_aux#'
    </cfif>
	<cfif IsDefined("FORM.abertura") AND FORM.abertura EQ "Sim">
    , Pos_Abertura = '#FORM.abertura#'
	, Pos_Processo =
	<cfset proc_se = FORM.proc_se>
	<cfset proc_num = FORM.proc_num>
	<cfset proc_ano = FORM.proc_ano>
    <cfset Processo = proc_se & proc_num & proc_ano>
	#Processo#
    , Pos_Tipo_Processo = '#FORM.modalidade#'
	<cfelse>
	, Pos_Abertura = ''
	, Pos_Processo = ''
    , Pos_Tipo_Processo = ''
    </cfif>

	<cfif IsDefined("FORM.VLRecuperado") AND FORM.VLRecuperado NEQ "">
	  <cfset aux_vlr = Trim(FORM.VLRecuperado)>
	  <cfset aux_vlr = Replace(aux_vlr,'.','','All')>
	  <cfset aux_vlr = Replace(aux_vlr,',','.','All')>
    , Pos_VLRecuperado='#aux_vlr#'
    </cfif>
   	, pos_username = '#CGI.REMOTE_USER#'
	, Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
	, Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
	, Pos_Sit_Resp_Antes = #form.scodresp#
	WHERE Pos_Unidade= '#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
 </cfquery> 

  <cfquery datasource="#dsn_inspecao#">
   INSERT Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area)
   VALUES (
   '#form.ninsp#'
   ,
   '#form.unid#'
   ,
   #form.Ngrup#
   ,
   #form.Nitem#
   ,
   convert(char, getdate(), 102)
   ,
   '#CGI.REMOTE_USER#'
   ,
   #FORM.frmResp#
   ,
  CONVERT(char, GETDATE(), 108)
   ,
  <cfif IsDefined("FORM.observacao") AND FORM.observacao NEQ "">
     <cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)#  & CHR(13) & CHR(13) & 'AO (À) ' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & 'Data de Previsão da Solução: ' & #DateFormat(dtnovoprazo,"DD/MM/YYYY")# & CHR(13) & CHR(13) & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	<cfif "#Form.frmResp#" eq 25 || "#Form.frmResp#" eq 26 >
		<cfset and_obs = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> ' & #Trim(Encaminhamento)#  & CHR(13) & CHR(13) & 'AO (À) ' & '  ' & #Gestor# & CHR(13) & CHR(13) & #aux_obs# & CHR(13) & CHR(13) & CHR(13) & CHR(13) & 'Situação: ' & #situacao# & CHR(13) & CHR(13) &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qUsuario.Usu_LotacaoNome) & CHR(13) & CHR(13) & '-----------------------------------------------------------------------------------------------------------------------'>
	</cfif>	 	 
  '#and_obs#'
  <cfelse>
   NULL
  </cfif>
  ,
  '#IDArea#'
  )
 </cfquery> 

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
  <!--- Envio de aviso por email para situacao = Tratamento --->
  <cfif Form.frmResp is 15 or Form.frmResp is 16 or Form.frmResp is 18 or Form.frmResp is 19 or Form.frmResp is 23>
	  <cfoutput>
	  <cfif Form.frmResp is 15 or Form.frmResp is 18>
			<!--- Participar ao Orgao subordinador --->
			 <cfquery name="rsOrgSub" datasource="#dsn_inspecao#">
				SELECT Rep_Email FROM Reops INNER JOIN Unidades ON Rep_Codigo = Und_CodReop WHERE Und_Codigo='#strIDGestor#'
			 </cfquery>
			 <cfset sdestina = #sdestina# & ';' & #rsOrgSub.Rep_Email#>
	  </cfif>

	  <cfif findoneof("@", trim(sdestina)) eq 0>
	    <cfset sdestina = "gilvanm@correios.com.br">
	  </cfif>

	<!---   <cfset sdestina = #sdestina# & ';' & #Form.emailusu#> --->
	<!---     <cfset sdestina = "gilvanm@correios.com.br">  --->
	  <cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="Relatorio Item Em Tratamento" type="HTML">
			 Mensagem autom&atilde;tica. Nao precisa responder!<br><br>
			<strong>
			   Ao Gestor do(a) #nomedestino#. <br><br><br>

	&nbsp;&nbsp;&nbsp;Para conhecimento deste Orgao.<br><br>

	&nbsp;&nbsp;&nbsp;Comunicamos que há pontos de Controle Interno "Em Tratamento" de manifestação/Solução.<br><br>

	&nbsp;&nbsp;&nbsp;Unidade: #FORM.unid# - #rsMod.Und_Descricao#, Avaliação: #form.ninsp#, Grupo: #form.Ngrup#, Item: #form.Nitem# e Data de Previsão Solução: #DateFormat(dtnovoprazo,"DD/MM/YYYY")#.<br><br>

	&nbsp;&nbsp;&nbsp;O registro da manifestação estão disponível no link: <a href="http://intranetsistemaspe/snci/rotinas_inspecao.cfm">Relatório Item Em Tratamento.</a><br><br>

	&nbsp;&nbsp;&nbsp;Desde já agradecemos a sua atenção.
	</strong>
	</cfmail>
	</cfoutput>
  </cfif>
  <cfif Form.frmResp is 3 or Form.frmResp is 12 or Form.frmResp is 13 or Form.frmResp is 25>
  <cfoutput>
     <cflocation url="Pacin_ClassificacaoUnidades.cfm?&pagretorno=itens_controle_respostas1.cfm&Unid=#Unid#&Ninsp=#Ninsp#&Ngrup=#Ngrup#&Nitem=#Nitem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#reop#&vlrdec=#vlrdec#&situacao=#Form.frmResp#&posarea=&modal=">
	 </cfoutput>
  </cfif>  
</cfif>
<!---  --->
</cfif>


<!--- Nova consulta para verificar respostas das unidades --->

 <cfquery name="qResposta" datasource="#dsn_inspecao#">
 SELECT Pos_Area, 
 Pos_NomeArea, 
 Pos_Situacao_Resp, 
 Pos_Parecer, 
 RIP_Recomendacoes, 
 RIP_Comentario, 
 RIP_Caractvlr, 
 RIP_Falta, 
 RIP_Sobra, 
 RIP_EmRisco, 
 RIP_Valor, 
 RIP_ReincInspecao, 
 RIP_ReincGrupo, 
 RIP_ReincItem, 
 Dir_Descricao, 
 Dir_Codigo, 
 Pos_Processo, 
 Pos_Tipo_Processo, 
 Pos_Abertura, 
 Itn_Descricao, 
 Itn_TipoUnidade, 
 Itn_ValorDeclarado,
 Pos_VLRecuperado, 
 Pos_DtPrev_Solucao, 
 Pos_DtPosic, 
 DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, 
 Pos_SEI, 
 Pos_Situacao_Resp, 
 INP_DtInicInspecao, 
 INP_TNCClassificacao, 
 INP_Modalidade,
 Pos_NCISEI,
 Pos_ClassificacaoPonto, 
 Pos_PontuacaoPonto,
 Grp_Descricao,
 Pos_NumProcJudicial,
 TNC_ClassifInicio, 
 TNC_ClassifAtual
FROM Diretoria 
INNER JOIN (((Unidades 
INNER JOIN ((Inspecao 
INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) 
AND (INP_Unidade = RIP_Unidade)) 
INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND 
(RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) ON Und_Codigo = INP_Unidade) 
INNER JOIN Itens_Verificacao ON (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) and (convert(char(4),RIP_Ano) = Itn_Ano)) 
INNER JOIN Grupos_Verificacao ON (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo) and (Itn_TipoUnidade = Und_TipoUnidade) and (INP_Modalidade = Itn_modalidade)) ON Dir_Codigo = Und_CodDiretoria
left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
 WHERE Pos_Unidade='#URL.unid#' AND Pos_Inspecao='#URL.ninsp#' AND Pos_NumGrupo=#URL.ngrup# AND Pos_NumItem=#URL.nitem#
</cfquery>

<cfif trim(qResposta.TNC_ClassifInicio) eq ''>
  <cfoutput>
     <cflocation url="Pacin_ClassificacaoUnidades.cfm?&pagretorno=itens_controle_respostas1.cfm&Unid=#Unid#&Ninsp=#Ninsp#&Ngrup=#Ngrup#&Nitem=#Nitem#&DtInic=#DtInic#&dtFim=#dtFim#&ckTipo=#ckTipo#&reop=#reop#&vlrdec=#vlrdec#&situacao=#situacao#&posarea=#posarea#&modal=#modal#">
	 </cfoutput>
</cfif>
	 
<cfif not isDefined("Form.acao")>
	<cfset Form.frmResp = qResposta.Pos_Situacao_Resp>
	<cfset Form.observacao = ''>
	<cfset Form.acao = ''>
<cfelse>	
	<cfif Form.acao eq 'Salvar2'>
		<cfset Form.observacao = ' '>
	</cfif>
</cfif>
		  
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

<cfquery name="qscoi" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) <> '#rsMod.Dir_Codigo#') and (Ars_Sigla Like '%/SCOI%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCOI')
 ORDER BY Ars_Sigla
</cfquery>	
<cfset auxSE = rsMod.Dir_Codigo>
<cfset scia_se = auxSE>
<cfif auxSE eq '03' or auxSE eq '16' or auxSE eq '26' or auxSE eq '06' or auxSE eq '75' or auxSE eq '28' or auxSE eq '65' or auxSE eq '05'> <!--- ACR;GO;RO;AM;TO;PA;RR;AP --->
	<cfset scia_se = '10'>	<!--- BSB --->
<cfelseif auxSE eq '08' or auxSE eq '14'>   <!--- BA; ES --->
	<cfset scia_se = '20'> <!--- MG --->
<cfelseif auxSE eq '04' or auxSE eq '12' or auxSE eq '18' or auxSE eq '30' or auxSE eq '34' or auxSE eq '60' or auxSE eq '70'> <!--- AL; CE; MA; PB; PI; RN; SE --->
	<cfset scia_se = '32'> <!--- PE --->
<cfelseif auxSE eq '68' or auxSE eq '64'> <!--- SC;RS --->
	<cfset scia_se = '36'>	<!--- PR --->
<cfelseif auxSE eq '50'>   <!--- RJ --->
	<cfset scia_se = '72'> <!--- SPM --->
<cfelseif auxSE eq '22' OR auxSE eq '24'>   <!--- MS; MT --->
	<cfset scia_se = '74'> <!--- SPI --->				 					 				 
</cfif>

<cfquery name="qscia" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '#scia_se#') and (Ars_Sigla Like '%/SCIA%' OR Ars_Sigla Like '%DCINT/GCOP/SGCIN/SCIA')
 ORDER BY Ars_Sigla
</cfquery>	

<cfquery name="qArea" datasource="#dsn_inspecao#">
 SELECT DISTINCT Ars_Codigo, Ars_Sigla, Ars_Descricao
 FROM Areas WHERE Ars_Status = 'A' AND (Left(Ars_Codigo,2) = '#left(URL.Posarea,2)#')
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
	<!---Cria uma instancia do componente Dao--->
	<cfobject component = "CFC/Dao" name = "dao">
    <!---Invoca o metodo  rsUsuarioLogado para retornar dados do Usu&atilde;rio logado (rsUsuarioLogado)--->
	<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">
<cfif rsTPUnid.Und_TipoUnidade is 12 || rsTPUnid.Und_TipoUnidade is 16>
	 <!---Invoca o metodo  VencidoPrazo_Andamento para retornar 'yes' se o prazo estiver vencido ou 'no' --->
	<cfinvoke component="#dao#" method="VencidoPrazo_Andamento" returnVariable="PrazoVencido"	  
      NumeroDaInspecao = '#URL.ninsp#'
      CodigoDaUnidade ='#URL.unid#'
      Grupo ='#URL.ngrup#'
      Item ='#URL.nitem#' 
	  ListaDeStatusContabilizados = 14,18,20 
	  Prazo = 30	
	  RetornaQuantDias = no
	  MostraDump = no
	  ApenasDiasUteis = yes
	/>	  	

	

<!---   Em 15/01/2021 por Gilvan a pedido de Adriano/Luciana	
        <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto 
		  WHERE STO_Status='A'                                                                                                   
		  <cfif #PrazoVencido# eq 'yes'>
			AND STO_Codigo in (9,12,13,25,26)
		  <cfelse>
			AND STO_Codigo in (9,12,13,20,25) 
	      </cfif>
		  order by STO_Descricao
		</cfquery>
--->
		
		  <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		  SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto 
		  WHERE STO_Status='A'                                                                                                   
		  <cfif #PrazoVencido# eq 'yes'>
			  <cfif Trim(rsUsuarioLogado.GrupoAcesso) eq 'GESTORMASTER'>
			   AND STO_Codigo in (9,12,13,21,25,26,29,30)
			  <cfelse>
			   AND STO_Codigo in (9,12,13,18,25,26,29,30)	  
			  </cfif>
			
		  <cfelse>
			  <cfif Trim(rsUsuarioLogado.GrupoAcesso) eq 'GESTORMASTER'>
			   AND STO_Codigo in (9,12,13,21,25,26,29,30) 
			  <cfelse>
               AND STO_Codigo in (9,12,13,18,25,26,29,30) 				  
			  </cfif>
	      </cfif>
		  order by STO_Descricao
		</cfquery>
        <cfset PrzVencSN = PrazoVencido>
		<cfif situacao eq 28>
<!--- 		   <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		     SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (12,28) order by STO_Descricao
		   </cfquery> --->
		</cfif>
<cfelse>
	
	<cfquery name="rsPonto" datasource="#dsn_inspecao#">
		<cfif qResposta.Pos_Situacao_Resp neq 9>
	       SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo not in (1,2,4,5,6,7,8,11,14,17,18,20,22,25,26,27) 
	    <cfelse>
           SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo not in (1,2,4,5,6,7,8,9,11,14,17,18,20,22,25,26,27) 			
	    </cfif>
	    <cfif Trim(rsUsuarioLogado.GrupoAcesso) neq 'GESTORMASTER'>
				 AND STO_Codigo <> 21 
		 </cfif>
	 order by STO_Descricao	
	</cfquery>
	<cfif situacao eq 28>
	<!--- 	   <cfquery name="rsPonto" datasource="#dsn_inspecao#">
		     SELECT STO_Codigo, STO_Descricao FROM Situacao_Ponto WHERE STO_Status='A' AND STO_Codigo in (12,28) order by STO_Descricao
		   </cfquery> --->
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
<script type="text/javascript" src="ckeditor\ckeditor.js"></script>

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

  if (k == 15 || k == 16 || k == 18 || k == 19  || k == 23 )
 {
   document.form1.cbdata.value = document.form1.dtdezdiasfut.value;
   document.form1.cbdata.disabled = false;
 }
 if (k == 21)
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
 
 //============================
 function reverter()
{
 //alert(document.form1.sfrmfalta.value);
  var caracvlr = document.form1.scaracvlr.value;
  document.form1.alter_valores.value = 'Alterar';
  caracvlr = caracvlr.toUpperCase();
  if (caracvlr == 'QUANTIFICADO')
  {
	 document.form1.caracvlr.selectedIndex = 0;
     document.form1.frmfalta.disabled = false;
     document.form1.frmsobra.disabled = false;
	 document.form1.frmemrisco.disabled = false;
	 document.form1.frmfalta.value = document.form1.sfrmfalta.value;
	 document.form1.frmsobra.value = document.form1.sfrmsobra.value;
	 document.form1.frmemrisco.value = document.form1.sfrmemrisco.value;
  }
  if (caracvlr != 'Quantificado') {
	 document.form1.caracvlr.selectedIndex = 1;
     document.form1.frmfalta.value = '0,00';
     document.form1.frmsobra.value = '0,00';
	 document.form1.frmemrisco.value = '0,00';

     document.form1.frmfalta.disabled = true;
     document.form1.frmsobra.disabled = true;
	 document.form1.frmemrisco.disabled = true;
  }
}
 //============================
 function exibevalores()
{
 //alert(document.form1.sfrmfalta.value);
  var caracvlr = document.form1.caracvlr.value;
  caracvlr = caracvlr.toUpperCase();
//  alert(caracvlr);
  if (caracvlr == 'QUANTIFICADO')
  {
	 document.form1.caracvlr.selectedIndex = 0;
     document.form1.frmfalta.disabled = false;
     document.form1.frmsobra.disabled = false;
	 document.form1.frmemrisco.disabled = false;
	 document.form1.frmfalta.value = document.form1.sfrmfalta.value;
	 document.form1.frmsobra.value = document.form1.sfrmsobra.value;
	 document.form1.frmemrisco.value = document.form1.sfrmemrisco.value;
  }
  if (caracvlr != 'QUANTIFICADO') {
	 document.form1.caracvlr.selectedIndex = 1;
     document.form1.frmfalta.value = '0,00';
     document.form1.frmsobra.value = '0,00';
	 document.form1.frmemrisco.value = '0,00';
     document.form1.frmfalta.disabled = true;
     document.form1.frmsobra.disabled = true;
	 document.form1.frmemrisco.disabled = true;
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
 exibirjudicializado(a);
 exibirArea(a);
 exibirAreaCS(a);
 exibirValor(a);
 dtprazo(a);
 exibirscoi(a);
 exibirscia(a);
 exibirunidtransfer(a);
 exibirsubortransfer(a);
 exibirterctransfer(a);
 exibirsuspenso(a);
}

//==============
var ind
function exibirjudicializado(ind){
  document.form1.posnumprocjudicial.disabled=true;
  if (ind=='31'){
		document.form1.observacao.value = '';
		var sinformes = "Item baixado para efeitos de acompanhamento no Sistema SNCI, tendo em vista a existência de Processo Judicial relacionado ao tema."
		var parecer =  sinformes; 
		document.form1.observacao.value = parecer;
		document.form1.observacao.disabled=true;
		document.form1.posnumprocjudicial.disabled=false;
  }
  }
//==============
var ind
function exibirsuspenso(ind){
  //document.getElementById("observacao").readOnly = false;
 // document.form1.observacao.value = '';
  if (ind=='10'){
		    document.form1.observacao.value = '';
            var sinformes = "Item suspenso por 90 (noventa) dias corridos para aguardar as tratativas dos Correios com o órgão externo, conforme registrado no histórico das manifestações."
            var parecer =  sinformes; 
            document.form1.observacao.value = parecer;
            document.form1.observacao.disabled=true;
			document.form1.cbdata.value = document.form1.dias90decorridos.value;
			
  }
//---------------------------------------  
  if (ind=='3'){
			
			var frmobserv = document.form1.observacao.value;
			var K = document.form1.scodresp.value;
			var auxacao = '<cfoutput>#Form.acao#</cfoutput>';
			//var auxacao = document.form1.acao.value;
//alert(ind + ' ' + K + 'auxacao: ' + auxacao);
			if ((frmobserv == '' || ind != K) && (auxacao == '' || auxacao == 'Salvar2')) {
		    document.form1.observacao.value = '';
		
          var sinformes = "Com base na manifestação registrada, considera-se o item SOLUCIONADO. \n\nÉ oportuno informar que a efetividade das ações de regularização adotadas poderá ser verificada em futuras Avaliações de Controle realizadas pelas equipes do Controle Interno. \n\nCabe destacar que, caso a unidade avaliada incorra novamente na irregularidade apontada, tal situação será passível de ser considerada como reincidência."
            var parecer =  sinformes; 
            document.form1.observacao.value = parecer;
			}
		
  }
//--------------------------------------  
 }
//==============
var ind
function exibirterctransfer(ind){
//alert('exibirterctransfer: ' + document.form1.frmtransfer.value);
  document.form1.cbterctransfer.disabled=false;
  if ((document.form1.frmtransfer.value == 'S') && (ind=='18' || ind=='20')){
		  window.idterctransfer.style.visibility = 'visible';
		  } else {
			window.idterctransfer.style.visibility = 'hidden';
			document.form1.cbterctransfer.value = '';
		  }
  }
  //==============
var ind
function exibirsubortransfer(ind){
//alert('exibirsubortransfer: ' + document.form1.frmtransfer.value);
  document.form1.cbsubordinador.disabled=false;
  if ((document.form1.frmtransfer.value == 'S') && (ind=='4' || ind=='16')){
		  window.idsubortransfer.style.visibility = 'visible';
		  } else {
			window.idsubortransfer.style.visibility = 'hidden';
			document.form1.cbsubordinador.value = '';
		  }
  }
//==============
var ind
function exibirunidtransfer(ind){
//alert('exibirunidtransfer: ' + document.form1.frmtransfer.value);
  document.form1.cbunidtransfer.disabled=false;
  if ((document.form1.frmtransfer.value == 'S') && (ind=='2' || ind=='15')){
		  window.idunidtransfer.style.visibility = 'visible';
		  } else {
			window.idunidtransfer.style.visibility = 'hidden';
			document.form1.cbunidtransfer.value = '';
		  }
  }
  
//==============
var ind
function exibirscia(ind){
//alert('exibirscia: ' + ind);
  
  document.form1.cbscia.disabled=false;
if (ind==21) {
          window.dAreascia.style.visibility = 'visible'; 
		  travarcombo('SEC ACOMP CONTR INTERNO/SGCIN','cbscia');
  
		  } else {
   		  window.dAreascia.style.visibility = 'hidden';
		  document.form1.cbscia.value = '';
	
  }
}  
//==============
var ind
function exibirscoi(ind){
//alert('exibirscoi: ' + ind);
  
  document.form1.cbscoi.disabled=false;
  if (ind==30){
    window.idSCOI.style.visibility = 'visible';
  } else {
    window.idSCOI.style.visibility = 'hidden';
	document.form1.cbscoi.value = '';
	
  }
}
//==============
var ind
function SelecArea(ind){
//alert('Area: ' + ind);

   var comboitem = document.getElementById("cbarea");
   for (i = 1; i < comboitem.length; i++) {

		if ((comboitem.options[i].text ==  'SEC AVAL CONT INTERNO/SGCIN') && (comboitem.options[i].value == ind))
		{
			//alert(comboitem.options[i].value + '   ' + ind);
			comboitem.selectedIndex = 0;
			i = comboitem.length;
		}
		
		if ((comboitem.options[i].text ==  'SEC ACOMP CONTR INTERNO/SGCIN') && (comboitem.options[i].value == ind))
		{
			//alert(comboitem.options[i].value + '   ' + ind);
			comboitem.selectedIndex = 0;
			i = comboitem.length;
		}		
    
		if ((comboitem.options[i].text ==  'SUBG CONTR INT OPER/GCOP') && (comboitem.options[i].value == ind))
		{
			//alert(comboitem.options[i].value + '   ' + ind);
			comboitem.selectedIndex = 0;
			i = comboitem.length;
		}
	}
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
//==============
var ind
function exibirArea(ind){
//alert('exibirArea: ' + ind);
  
  document.form1.observacao.disabled=false;
  document.form1.cbarea.disabled=false;
//  if (ind==5 || ind==10 || ind==19 || ind==21|| ind==25 || ind==26){
if (ind==5 || ind==10 || ind==19 || ind==25 || ind==26){
    window.dArea.style.visibility = 'visible';
 //   if(ind==21) {buscaopt('SEC AVAL CONT INTERNO/SGCIN')}
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

  }
}

//==================
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
    else if (idx==29 && document.form1.auxavisosn.value == 'S'){
  		alert('                            Atenção! \n\nGestor(a), favor justificar no campo: Opinião da Equipe de Controle Interno \n\n a Situação: ENCERRADO selecionada neste ponto.');
	   document.form1.cbareaCS.selectedIndex = 0;
       //document.form1.cbareaCS.disabled=true;
	   window.dAreaCS.style.visibility = 'hidden';
  }
    else {
    window.dAreaCS.style.visibility = 'hidden';
	//document.form1.cbareaCS.value = '';
	document.form1.cbareaCS.selectedIndex = 0;
  }
}
//=======================
function exibirValor(vlr){
//alert('exibirValor: ' + vlr);
 // document.form1.VLRecuperado.value='0,0';
  window.dValor.style.visibility = 'hidden';
  if (vlr==3 || vlr==25){
		window.dValor.style.visibility = 'visible';
	   // alert('Sr. Gestor, informe o Valor Regularizado, Exemplos: 1185,40; 0,07');
		document.form1.VLRecuperado.value='0,00'
		if (document.form1.vlrdeclarado.value == 'N') {
			 
			window.dValor.style.visibility = 'hidden';
		}   
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
		alert("N. SEI da Apuracao Inv&atilde;lido!:  (ex. 99999.999999/9999-99)");
		document.form1.frmnumseinci.focus();
		return false;
	}else{
		return true;
	}
	 
  }
  if (document.form1.acao.value=='Excluir'){
	  return true;
  }
  if (document.form1.acao.value=='Excluir_Causa'){
	  return true;
  }
  
  //=============================================================
	if (document.form1.acao.value=='alter_reincidencia'){
			var reincInsp = document.form1.frmreincInsp.value;
			var reincGrup = document.form1.frmreincGrup.value;
			var reincItem = document.form1.frmreincItem.value;

			if (document.form1.frmReinccb.value == 'S' && (reincInsp.length != 10 || reincGrup == 0 || reincItem == 0))
			{
			 alert('Para o Reincidência: Sim é preciso informar Nº Inspecao, Nº Grupo e Nº Item!');
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
	  if (confirm ('                       Atencao! \n\nConfirmar Alteração dos Valores deste ponto?'))
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
	
 //==================== 
 
  if (document.form1.acao.value=='Excluir_Proc'){
	  
	  if (confirm ('                       Atenção! \n\nConfirmar a Exclusão do Processo Disciplinar Selecionado?'))
	    {
	     return true;
		}
	else
	   {
	   return false;
	   }
	} 	
//==================== 
  if (document.form1.acao.value=='Excluir_Sei'){
	  var aux = document.form1.dbfrmnumsei.value;
	  //alert(aux);
	  if (aux.length != 17){
		  alert("Gestor(a), você deve selecionar Nº SEI a ser excluído!");
		  return false;
		  } 
	  
	  if (confirm ('                       Atenção! \n\nConfirmar a Exclusão de Nº SEI Selecionado?'))
	    {
	     return true;
		}
	else
	   {
	   return false;
	   }
	} 	
  //====================	
  
if (document.form1.acao.value=='Incluir_Proc'){
	  var auxsei = document.form1.frmprocsei.value;
	  var auxproc = document.form1.proc_num.value;
	  var auxano = document.form1.proc_ano.value;
	  var auxmodal = document.form1.modalidade.value;
	  
	 // alert(auxsei.length);
	  if (auxsei.length != 20){
		  alert("Nº SEI deve possui 20 digitos");
		  return false;
	  } 
	  if (auxproc != '' && auxproc !='00000' && auxproc.length != 5){
		  alert("Informar o Nº GPAC com 5 dígitos");
		  return false;
		  } 

	  if (auxmodal == '' && (auxproc != '' && auxproc !='00000')){
		  alert("Selecionar o tipo de Modalidade!");
		  return false;
		  } 
	 if (auxmodal != '' && (auxproc == '' || auxproc =='00000' || auxproc.length != 5)){
		  alert("Informar o Nº GPAC com 5 dígitos");
		  return false;
		  } 	
	 if (auxmodal != '' && (auxano == '' || auxano =='00' || auxano.length != 2)){
		  alert("Informar o Ano do N° GPAC com 2 dígitos");
		  return false;
		  } 
      var auxperg = 'Confirmar a Inclusao do Nº SEI?';	
      document.form1.btn_incluirProc.value = 'Incluir Nº SEI';	    
      if (auxproc.length == 5){
		 document.form1.btn_incluirProc.value = 'Incuir-Proc. Disciplinar';
         var auxperg = 'Confirmar a Inclusao do Processo Disciplinar?';
	  } 
		  	
	  if (confirm ('                      Atencao! \n\n' + auxperg))
	    {
	     return true;
		}
	else
	   {
		   document.form1.btn_incluirProc.value = 'Incuir-Proc. Disciplinar'
	   return false;
	   }
	   
	} 	
	
 
 //===============================
  // inicio cri­ticas para o botao Salvar manifestacao
  if (document.form1.acao.value == 'Salvar2')
  {
	document.form1.frmResp.disabled=false;
    document.form1.cbareaCS.disabled=false;
    document.form1.cbarea.disabled=false;
    document.form1.cbdata.disabled=false;
    document.form1.observacao.disabled=false;
    var sit = document.form1.frmResp.value;
	var pontotfsn = document.form1.frmtransfer.value;

	//----------------------------------------------
    if (sit == 'N')
		  {
			 alert('Sr. Gestor, Escolha uma das Situações para a Situação Encontrada.');
			 exibe(sit);
			 return false;
		}
	//----------------------------------------------
//	alert(sit + '   ' + document.form1.PrzVencSN.value);
	
    if (sit == 26 && document.form1.PrzVencSN.value != 'no')
		  {
	//		 alert('Sr. Gestor, Ponto ainda encontra-se no período de tratamento/regularização junto à AGF/ACC');
	//		 exibe(sit);
	//		 return false;
		}

	//----------------------------------------------
	var falta = document.form1.frmfalta.value;
	falta = falta.replace(',', '.');
	falta = Number(falta);
	
	var sobra = document.form1.frmsobra.value;
	sobra = sobra.replace(',', '.');
	sobra = Number(sobra);
	
	var VLRecuperado = document.form1.VLRecuperado.value;
	VLRecuperado = VLRecuperado.replace(',', '.');
	VLRecuperado = Number(VLRecuperado);

	var somarfaltasobra = Number(falta + sobra);

 //   if ((sit == 3 || sit == 9 || sit == 25) && somarfaltasobra > 0 && VLRecuperado == 0)
//	    {
//			 alert('Sr. Gestor, Item possui possui valor(es) para os campos Falta(R$) e/ou Sobra(R$), o campo Valor Regularizado não pode ser igual a zero');
//			 return false;
//		}
	//----------------------------------------------
	if ((sit == 3 || sit == 9 || sit == 25) && somarfaltasobra == 0 && VLRecuperado > 0)
	    {
			 alert('Sr. Gestor, Item não possui valor(es) para os campos Falta(R$) e/ou Sobra(R$), o campo Valor Regularizado não pode ser maior que zero');
			 return false;
		}		
	//----------------------------------------------
    if ((sit == 3 || sit == 9 || sit == 25) && somarfaltasobra > 0 && VLRecuperado > somarfaltasobra)
	    {
			 alert('Senhor usuário, o VALOR REGULARIZADO informado é superior a somatória dos campos Falta(R$) e/ou Sobra(R$). Favor revisar.');
			 return false;
		}		
	//----------------------------------------------	
	if (sit == 5 || sit == 10 || sit == 19) {document.form1.cbarea.disabled = false;}
	  if ((sit == 5 || sit == 10 || sit == 19) && (document.form1.cbarea.value == ''))
	  {
		   alert('Sr. Gestor, informe a Àrea para encaminhamento!');
		//   if (sit == 21) {document.form1.cbarea.disabled = true;}
		   document.form1.cbarea.disabled = true;
		   exibe(sit);
		   return false;
	  }

	  if (sit == 9)
	  {
		if (document.form1.cbareaCS.value == '')
		{
		   alert('Sr. Gestor, informe a Àrea(CS) para encaminhamento!');
		  // exibe(sit);
		   return false;
		}
	  }
// inicio de critica exclusiva para o ponto transferido de SE
      if (pontotfsn == 'S') 
	  {
		  // TRATAMENTO DE UNIDADE
		  if (sit == 15 && document.form1.cbunidtransfer.value == '') {
		   alert('Sr. Gestor, informe a Unidade(Transferido) para encaminhamento do ponto');
			   exibe(sit)
			   return false;
		  }
		  // TRATAMENTO DE franquias
		  if (sit == 18 && document.form1.cbterctransfer.value == '') {
		   alert('Sr. Gestor, informe a Terceiros(Transferido) para encaminhamento do ponto');
			   exibe(sit)
			   return false;
		  }
		  // TRATAMENTO DE orgao subordinadores
		  if (sit == 16 && document.form1.cbsubordinador.value == '') {
		   alert('Sr. Gestor, informe a Subordinador(Transferido) para encaminhamento do ponto');
			   exibe(sit)
		       return false;
		  } 		  
 
	  }
// fim de critica exclusiva para o ponto transferido de SE

	 var strmanifesto = document.form1.observacao.value;

	 if (strmanifesto == '')
	  {
		   alert('Caro Usuário, falta o seu Posicionamento no campo Manifestar-se!');
		   exibe(sit)
		   return false;
	  }

	 if (strmanifesto.length < 100)
	 {
		   alert("Sr. Gestor(a)! Sua manisfestação deverá; conter no mínimo 100(cem) caracteres");
		   exibe(sit);
		   return false;
	 }

      document.form1.cbdata.disabled = false;
	  var dtprevdig = document.form1.cbdata.value;
	  if (dtprevdig.length != 10)
	  {
		alert('Preencher campo: Data da Previsao da Solucao ex. DD/MM/AAAA');
		dtprazo(sit);
		exibe(sit);
		return false;
	  }
//-----------------------------------------------------------

	<!--- formato AAAAMMDD --->
		 var dt_hoje_yyyymmdd = document.form1.dthojeyyyymmdd.value;
		 //alert(a);
		 var vDia = dtprevdig.substr(0,2);
		 var vMes = dtprevdig.substr(3,2);
		 var vAno = dtprevdig.substr(6,10);
		 var dtprevdig_yyyymmdd = vAno + vMes + vDia

		 if (dt_hoje_yyyymmdd > dtprevdig_yyyymmdd)
		 {
		  alert("Data de Previsao da Solucao deve ser superior a data corrente(do dia)!")
		  //dtprazo(sit);
		  exibe(sit);
		  return false;
		 }

		//alert('Qual o valor da situacao? ' + sit);
		 if ((sit == 15 || sit == 16 || sit == 18 || sit == 19 || sit == 23) && (dt_hoje_yyyymmdd == dtprevdig_yyyymmdd))
		 {
		  alert("Para Tratamento a Data de Previsao da Solucao deve ser maior que a do dia!")
		  //dtprazo(sit);
		  exibe(sit);
		  return false;
		 }
		//----------------------------------------------
		var posnumprocjudicial = document.form1.posnumprocjudicial.value;
	//	alert('Valor informado' + posnumprocjudicial.value + ' tamanho:' + posnumprocjudicial.length);
    	if (sit == 31 && (posnumprocjudicial.value == '' || posnumprocjudicial.length <= 0))
		  {
			 alert('Sr. Gestor, informar Nº do Processo Judicial para Situação: JUDICIALIZADO');
			 exibe(sit);
			 return false;
		}
		
		 //----------------------------------------------
		 if ((sit == 15 || sit == 16 || sit == 18 || sit == 19 || sit == 23) && (dtprevdig_yyyymmdd > document.form1.Tratam_Teto_Data.value))
		 {
		  alert("Para Tratamento a Data de Previsao nao deve ser superior aos 365 dias!")
		  //dtprazo(sit);
		  exibe(sit);
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
	//============
	     if (sit == 15 || sit == 16 || sit == 18 || sit == 19 || sit == 23) {var auxcam = '\n\nTRATAMENTO\n\n - AVISO IMPORTANTE \n\nCaro Colaborador(a), voce informou uma nova Data de Previsao da Solucao;\n\nNos casos em que foi cedido dilatacao de prazo, requisitamos que registre em sua opiniao a motivacao da mudanca.\n\nConfirma a nova Data de Previsao?';

	 if (confirm ('            Atencao! ' + auxcam))
	    {
	     document.form1.cbdata.disabled=false;
	     return true;
		}
	else
	   {
	   if (sit != 15 && sit != 16 && sit != 18 && sit != 19 && sit != 23) {document.form1.cbdata.disabled = true;}
	   exibe(sit);
	   return false;
	   }
	   }
 // alert('ok');
         document.form1.observacao.disabled=false;
	     document.form1.cbarea.disabled=false;
	     document.form1.cbdata.disabled=false;
    //============
}
// ==== critica do botao incluir causa ===
     if (document.form1.acao.value == 'Incluir_Causa')
	 {
		   if (document.form1.causaprovavel.value == '')
		   {
		   alert('Selecione uma Causa Prov&atilde;vel a ser incluída.');
		   return false;
		   }
		   if (document.form1.causaprovavel.value != '')
		   {
		   //======================================
			   var cmbcausaprov = document.getElementById('causaprovavel');
			   for (i = 1; i < cmbcausaprov.length; i++)
			   {
					// alert(cmbcausaprov.options[i].value);
					if (cmbcausaprov.options[i].value ==  document.form1.causaprovavel.value)
					{
                             // alert(cmbcausaprov.options[i].text);
							 if (confirm ('Confirma a inclusao da Causa Prov&atilde;vel: ' + cmbcausaprov.options[i].text + ' ?'))
							   {
								}
							else
							   {
							   return false;
							   }
					    i = cmbcausaprov.length;
					 }
				}
	     }

	//return false;
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

<style type="text/css">
<!--
.style4 {color: #FF0000; font-weight: bold; }
-->
</style>
</head>

<body onLoad="exibevalores(); if(document.form1.houveProcSN.value != 'S') {exibe(document.form1.frmResp.value)} else {exibe(24)}; hanci(); controleNCI(); exibir_Area011(this.value)"> 
<cfset Form.acao = ''>
 <cfinclude template="cabecalho.cfm">
<table width="70%"  align="center" bordercolor="f7f7f7">
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
  <form name="form1" method="post" onSubmit="return validarform()" enctype="multipart/form-data" action="itens_controle_respostas1.cfm">
  <cfoutput>
	    <input type="hidden" name="scodresp" id="scodresp" value="#qResposta.Pos_Situacao_Resp#">
		<input type="hidden" name="sfrmPosArea" id="sfrmPosArea" value="#qResposta.Pos_Area#">
		<input type="hidden" name="sfrmPosNomeArea" id="sfrmPosNomeArea" value="#qResposta.Pos_NomeArea#">
		<input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="#qResposta.Itn_TipoUnidade#">
		<cfset resp = #qResposta.Pos_Situacao_Resp#> 
		<input type="hidden" name="srespatual" id="srespatual" value="#resp#">
		<cfset caracvlr = UCASE(trim(qResposta.RIP_Caractvlr))>
		<cfset falta = #mid(LSCurrencyFormat(qResposta.RIP_Falta, "local"), 4, 20)#>
		<cfset sobra = #mid(LSCurrencyFormat(qResposta.RIP_Sobra, "local"), 4, 20)#>
		<cfset emrisco = #mid(LSCurrencyFormat(qResposta.RIP_EmRisco, "local"), 4, 20)#>
		<input type="hidden" name="scaracvlr" id="scaracvlr" value="#caracvlr#">
		<input type="hidden" name="sfrmfalta" id="sfrmfalta" value="#falta#">
		<input type="hidden" name="sfrmsobra" id="sfrmsobra" value="#sobra#">
		<input type="hidden" name="sfrmemrisco" id="sfrmemrisco" value="#emrisco#">
		<input type="hidden" name="sVLRDEC" id="sVLRDEC" value="#url.VLRDEC#">
		<input type="hidden" name="situacao" id="situacao" value="#url.situacao#">
		<input type="hidden" name="posarea" id="posarea" value="#url.posarea#">
		<input type="hidden" name="dias90decorridos" id="dias90decorridos" value="#dateformat(DateAdd( "d", 90, now()),"DD/MM/YYYY")#">
	</cfoutput>
<cfset halbtgeral =''> 
<cfif resp eq 3 or grpacesso eq 'GOVERNANCA'>
<cfset halbtgeral ='disabled'>
</cfif>	
    <tr>
      <td colspan="5"><p class="titulo1">
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
		<input type="hidden" name="posarea" id="posarea" value="<cfoutput>#URL.posarea#</cfoutput>">
      </p></td>
	  <cfset habslvsn = 'S'>
	  <cfset auxtmp = left(url.PosArea,2)>
	  <cfif qUsuario.Usu_DR neq auxtmp and not listfind(trim(qUsuario.Usu_Coordena),auxtmp) and trim(ucase(qAcesso.Usu_GrupoAcesso)) neq 'GESTORMASTER'>
	    <cfset habslvsn = 'N'>
	  </cfif>
    </tr>
	  <tr bgcolor="eeeeee">
      <td width="95" class="exibir">Unidade</td>
      <td width="324"><cfoutput><strong class="exibir">#URL.Unid#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td colspan="3"><cfoutput>
        <table width="100%" border="0">
          <tr bgcolor="eeeeee">
            <td width="81"><span class="exibir">Respons&aacute;vel</span>:</td>
            <td width="237"><strong class="exibir">#qResponsavel.INP_Responsavel#</strong></td>
          </tr>
        </table>
      </cfoutput></td>
      </tr>
   <tr bgcolor="eeeeee" class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td>Inspetor</td>
              <cfelse>
              <td>Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="4">-&nbsp;<cfoutput query="qInspetor"><strong class="exibir">#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
    </tr>
<cfif qResposta.INP_Modalidade is 0>
	<cfset INPModalidade = 'PRESENCIAL'>
<cfelseif qResposta.INP_Modalidade is 1>
    <cfset INPModalidade = 'A DISTÂNCIA'>
<cfelse>
    <cfset INPModalidade = 'MISTA'>
</cfif>		
    <tr bgcolor="eeeeee" class="exibir">
      <td>N&ordm; Relat&oacute;rio</td>
      <td colspan="4">
        <table width="1030" border="0">
          <tr>
            <td width="228"><cfoutput><strong class="exibir">#URL.Ninsp#</strong></cfoutput></td>
            <td width="344"><span class="exibir">In&iacute;cio Avalia&ccedil;&atilde;o:</span> &nbsp;<strong class="exibir"><cfoutput>#DateFormat(qResposta.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></strong></td>         
            <td width="444"><span class="exibir">Modalidade:</span> <strong class="exibir"><cfoutput>#INPModalidade#</cfoutput></strong></td>
          </tr>
      </table></td>
    </tr>
    <tr bgcolor="eeeeee" class="exibir">
      <td>Grupo</td>
      <td colspan="4"><cfoutput><strong class="exibir">#URL.Ngrup#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Grp_Descricao#</strong></cfoutput></td>
    </tr>
    <tr bgcolor="eeeeee" class="exibir">
      <td>Item </td>
      <td colspan="4"><cfoutput><strong class="exibir">#URL.Nitem#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#qResposta.Itn_Descricao#</strong></cfoutput></td>
    </tr>

<tr class="exibir">
	  <td bgcolor="eeeeee">Relevância</td>
	  <td colspan="4" bgcolor="f7f7f7"><table width="100%" border="0">
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
			<tr bgcolor="eeeeee" class="exibir">
			  <td><span class="style4">Reincid&ecirc;ncia</span></td>
			  <td colspan="4"><span class="style4">N&ordm; Relat&oacute;rio:&nbsp;&nbsp;&nbsp;
				  <input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" style="background:white" readonly="">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; Grupo:
		<input name="frmreincGrup2" type="text" class="form" id="frmreincGrup2" size="8" maxlength="5" value="#db_reincGrup#" style="background:white" readonly="">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; Item:
		<input name="frmreincItem2" type="text" class="form" id="frmreincItem2" size="7" maxlength="4" value="#db_reincItem#" style="background:white" readonly=""> 
			  </span></td>
			</tr>
		</cfif>	
	</cfoutput>	
    <cfoutput>
 	 <tr bgcolor="eeeeee" class="exibir">
      <td>Valores</td>

      <td colspan="4">
		  <table width="100%" border="0" cellspacing="0" bgcolor="eeeeee" >
		  <tr bgcolor="eeeeee">
					<td><span class="exibir">Caracteres:</span>&nbsp;
					  <select name="caracvlr" id="caracvlr" class="form" onChange="exibevalores()" disabled="disabled">
                         <option <cfif UCASE(trim(caracvlr)) eq "QUANTIFICADO"> selected</cfif> value="QUANTIFICADO">QUANTIFICADO</option>
                        <option <cfif trim(caracvlr) neq "QUANTIFICADO"> selected</cfif> value="NAO QUANTIFICADO">NÃO QUANTIFICADO</option>
                      </select>                    </td>
					<td><span class="exibir">Falta(R$):</span>&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)" readonly="yes">					</td>
					<td><span class="exibir">Sobra(R$):&nbsp;</span>
				    <input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)" readonly="yes">					</td>
					<td><span class="exibir">Em Risco(R$):</span>&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)" readonly="yes">					</td>
		  </tr>
	    </table>	  </td>
      </tr>
    </cfoutput>
	 <cfset melhoria = replace('#qResposta.RIP_Comentario#','; ' ,';','all')>
		<tr bgcolor="eeeeee">
         <td align="center"><span class="titulos">Situação Encontrada:</span></td>
        <td colspan="5"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#melhoria#</cfoutput></textarea></td>
      </tr>
 
 <!---  </cfif> --->
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
	<tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    
    <tr>
      <td bgcolor="eeeeee" align="center"><span class="titulos">Orienta&ccedil;&otilde;es:</span></td>
      <td colspan="5" bgcolor="eeeeee"><textarea name="recomendacao" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.RIP_Recomendacoes#</cfoutput></textarea></td>
    </tr>

    <tr>
      <td valign="middle" bgcolor="eeeeee" align="center"><p><span class="titulos">Hist&oacute;rico:</span> <span class="titulos">Manifesta&ccedil;&otilde;es e Plano de Acao/An&aacute;lise do Controle Interno</span><span class="titulos">:</span></p>
        <p>
          <input name="extrato" type="button" class="botao" id="extrato" onClick="window.open('Exibir_Texto_Parecer.cfm?frmUnid=<cfoutput>#unid#</cfoutput>&frmNumInsp=<cfoutput>#ninsp#</cfoutput>&frmGrupo=<cfoutput>#ngrup#</cfoutput>&frmItem=<cfoutput>#nitem#</cfoutput>','_blank')" value="+ Detalhes" />
      </td>
      <td colspan="5" bgcolor="eeeeee"><textarea name="H_obs" cols="200" value="#Session.E01.h_obs#" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_parecer#</cfoutput></textarea></td>
    </tr>
    <!--- ==============INICIO PROCESSO DISCIPLINAR======================= --->
    <cfset aux_usudr = left(URL.Unid,2)>
	<cfset aux_ano = right(year(now()),2)>
    <tr bgcolor="f7f7f7">
      <td bgcolor="eeeeee" align="center" valign="top"><span class="titulos">Processo Disciplinar:</span></td>
      <td colspan="5">
		 <!--- tabela interna --->
		  <table width="100%" border="0">
        <tr>
			<td colspan="3" bgcolor="eeeeee"><span class="exibir">N&ordm; SEI:</span></td>
			<td bgcolor="eeeeee"><div align="left">
			<input name="frmprocsei" id="frmprocsei" type="text" class="form" onKeyPress="numericos()" onKeyDown="validacao(); Mascara_SEI(this)" size="27" maxlength="20" value="">			</td>
			<td bgcolor="eeeeee" class="exibir">	  
				  <span class="exibir">N&ordm; GPAC:</span>&nbsp;&nbsp;
				  <input name="proc_se" type="text" class="form" value="<cfoutput>#aux_usudr#</cfoutput>" size="3" maxlength="2" readonly>-<input name="proc_num" type="text" class="form" value="" onFocus="exibe('N'); travarcombo('kkk','frmResp')" onBlur="exibe(24)" onKeyPress="numericos()"  size="6" maxlength="5">-<input name="proc_ano" type="text" class="form" onFocus="exibe('N'); travarcombo('kkk','frmResp')" onBlur="exibe(24)" onKeyPress="numericos()" value="<cfoutput>#aux_ano#</cfoutput>" size="2" maxlength="2">
				  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				  <span class="exibir">Modalidade:&nbsp;</span>&nbsp;
				  <select name="modalidade" class="form" onFocus="exibe('N'); travarcombo('kkk','frmResp')" onBlur="exibe(24)">
					<option value="">---</option>
					<option value="TAC">TAC</option>
					<option value="Apuracao_Direta">Apuracao Direta</option>
					<option value="Sindicancia_Sumaria">Sindicância Sum&atilde;ria</option>
				  </select>			</td>
        
			<td colspan="2" bgcolor="eeeeee">
				<!--- <cfif (resp neq 24) and ('#qUsuario.Usu_DR#' eq left(url.PosArea,2))> --->
				<cfif (resp neq 24) and (habslvsn eq 'S')>
					<input name="btn_incluirProc" id="btn_incluirProc" type="submit" class="botao" onClick="document.form1.acao.value='Incluir_Proc';frmprocsei.value" value="Incluir-Proc. Disciplinar" codigo="#frmprocsei.value#"  <cfoutput>#halbtgeral#</cfoutput>>
				<cfelse>
					<input name="btn_incluirProc" id="btn_incluirProc" type="submit" class="botao" onClick="document.form1.acao.value='Incluir_Proc';frmprocsei.value" value="Incluir-Proc. Disciplinar" codigo="#frmprocsei.value#" disabled>
				</cfif>		   </td>
      </tr>
      <tr>
			<td colspan="5" bgcolor="eeeeee"></td>
	  </tr>
      <cfoutput query="qProcSei">
		  <cfset numsei = trim(PDC_ProcSEI)>
		  <cfset numsei = left(numsei,5) & '.' & mid(numsei,6,6) & '/' & mid(numsei,12,4) & '-' & right(numsei,2)>
          <cfset auxprocesso = #left(PDC_Processo,2)# & "-" & #mid(PDC_Processo,3,5)# & "-" & #right(PDC_Processo,2)#>

		  <tr bgcolor="f7f7f7">
			<td colspan="5" bgcolor="eeeeee" valign="left" class="exibir"><strong>N&ordm; SEI(Processo): #numsei#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; GPAC: #auxprocesso#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Modalidade: #PDC_Modalidade#</strong></td>
			<cfif (resp neq 24) and (habslvsn eq 'S')>
				<td bgcolor="eeeeee"><input name="btn_ExcluirProc" id="btn_ExcluirProc" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Proc';document.form1.frmpdc_procsei.value='#qProcSei.PDC_ProcSEI#';document.form1.frmpdc_procmodal.value='#qProcSei.PDC_Modalidade#';document.form1.frmpdc_processo.value='#qProcSei.PDC_Processo#'" value="Excluir-Proc. Disciplinar" codigo="#qProcSei.PDC_ProcSEI#" <cfoutput>#halbtgeral#</cfoutput>></td>
			<cfelse>
				<td bgcolor="eeeeee"><input name="btn_ExcluirProc" id="btn_ExcluirProc" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Proc';document.form1.frmpdc_procsei.value='#qProcSei.PDC_ProcSEI#';document.form1.frmpdc_procmodal.value='#qProcSei.PDC_Modalidade#';document.form1.frmpdc_processo.value='#qProcSei.PDC_Processo#'" value="Excluir-Proc. Disciplinar" codigo="#qProcSei.PDC_ProcSEI#" disabled></td>
			</cfif>
		  </tr>
	</cfoutput> 
	<cfoutput query="qSeiApur">
		   <cfset numsei = trim(SEI_NumSEI)>
		  <cfset numsei = left(numsei,5) & '.' & mid(numsei,6,6) & '/' & mid(numsei,12,4) & '-' & right(numsei,2)>
          <tr bgcolor="f7f7f7">
			<td colspan="5" bgcolor="eeeeee" valign="left" class="exibir"><strong>N.SEI: #numsei#</strong></td>
			<cfif (resp neq 24) and (qSeiApur.recordcount gt 0)>
				<td bgcolor="eeeeee"><input name="btn_ExcluirSei" id="btn_ExcluirSei" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Sei';document.form1.dbfrmnumsei.value='#qSeiApur.SEI_NumSEI#'" value="Excluir N. SEI" codigo="#qSeiApur.SEI_NumSEI#" #halbtgeral#></td>
				                     
			<cfelse>
				<td bgcolor="eeeeee"><input name="btn_ExcluirSei" id="btn_ExcluirSei" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Sei';document.form1.dbfrmnumsei.value='#qSeiApur.SEI_NumSEI#'" value="Excluir N. SEI" codigo="#qSeiApur.SEI_NumSEI#" disabled></td>
			</cfif>
		  </tr>
	</cfoutput> 
		  <input type="hidden" name="frmpdc_procsei" value="">
		  <input type="hidden" name="frmpdc_procmodal" value="">
		  <input type="hidden" name="frmpdc_processo" value="">
<!--- Direcionar ponto para APURACAO  --->
<cfif (qResposta.Pos_Situacao_Resp neq 24)>
	<cfquery name="qApura" datasource="#dsn_inspecao#">
		SELECT PDC_dtultatu 
		FROM ParecerUnidade INNER JOIN Inspecao_ProcDisciplinar ON (Pos_NumItem = PDC_Item) AND (Pos_NumGrupo = PDC_Grupo) AND (Pos_Inspecao = PDC_Inspecao) AND (Pos_Unidade = PDC_Unidade) 
		WHERE (((PDC_Unidade)='#unid#') AND ((PDC_Inspecao)='#ninsp#') AND ((PDC_Grupo)=#ngrup#) AND ((PDC_Item)=#nitem#) AND ((PDC_dtultatu)>=[Pos_DtPosic]))
	</cfquery>
	<cfif qApura.recordcount gt 0>
	    <input type="hidden" name="houveProcSN" value="S">
	    <input type="hidden" name="mensSN" value="S">
	<cfelse>
		<input type="hidden" name="houveProcSN" value="<cfoutput>#houveProcSN#</cfoutput>">
		<input type="hidden" name="mensSN" value="N">
	</cfif>
</cfif>
<!--- FIM - Direcionar ponto para APURACAO  --->		  
		     
    </tr>
          <tr>
			<td colspan="5" bgcolor="eeeeee"></td>
	  </tr>
    </table>
		 <!---  ============= --->      </td>
    </tr>
    <!--- ================ FIM PROCESSO DISCIPLINAR ===================== --->
    <tr bgcolor="f7f7f7">
      <td bgcolor="eeeeee" align="center"><span class="titulos">Causas Prov&aacute;veis:</span></td>
      <td colspan="3" valign="middle" bgcolor="eeeeee" class="exibir">
	  <select name="causaprovavel" class="form">
        <option selected="selected" value="">---</option>
        <cfoutput query="qCausa">
          <option value="#Cpr_Codigo#">#Cpr_Descricao#</option>
        </cfoutput>
      </select>      </td>
      
	  <cfset numdias = qResposta.diasOcor>
      <td bgcolor="eeeeee">
<!--- 		<cfif ((resp is 1 and numdias lte 2) or (resp is 6 and numdias lte 2) or (resp is 7 and numdias lte 2) or (resp is 17 and numdias lte 2) or (resp is 18) or (resp is 24) or (#qUsuario.Usu_DR# neq #left(url.PosArea,2)#))> --->
		<cfif (<!---(resp is 1 and numdias lte 2) or --->(resp is 6 and numdias lte 2) or (resp is 7 and numdias lte 2) or (resp is 17 and numdias lte 2) or (resp is 18) or (resp is 24) or (habslvsn neq 'S'))>		
		  <input name="btn_inc_causa" id="btn_inc_causa" type="Submit" class="botao" value="Incluir Causa" onClick="document.form1.acao.value='Incluir_Causa';" disabled>
		<cfelse>
		  <input name="btn_inc_causa" id="btn_inc_causa" type="Submit" class="botao" value="Incluir Causa" onClick="document.form1.acao.value='Incluir_Causa';" <cfoutput>#halbtgeral#</cfoutput>>
		</cfif>	  </td>
    </tr>
    <cfoutput query="qCausaProcesso">
      <tr bgcolor="f7f7f7">
        <td bgcolor="eeeeee">&nbsp;</td>
        <td colspan="3" bgcolor="eeeeee" valign="middle" class="exibir"> #Cpr_Descricao# </td>
		<cfif (resp neq 24) and (habslvsn eq 'S')>
        <td bgcolor="eeeeee"><input name="btn_ExcluirCausa" id="btn_ExcluirCausa" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Causa';document.form1.vCausaProvavel.value=#qCausaProcesso.Cpr_Codigo#" value="Excluir Causa" codigo="#qCausaProcesso.Cpr_Codigo#" #halbtgeral#></td>
		<cfelse>
		<td bgcolor="eeeeee"><input name="btn_ExcluirCausa" id="btn_ExcluirCausa" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Causa';document.form1.vCausaProvavel.value=#qCausaProcesso.Cpr_Codigo#" value="Excluir Causa" codigo="#qCausaProcesso.Cpr_Codigo#" disabled></td>
		</cfif>
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

     <!--- Se existir dados na sessao, exibir os dados armazenados --->
    <cfif isDefined("Session.E01.abertura")>
      <tr bgcolor="f7f7f7">
        <td height="22" colspan="5" valign="middle" bgcolor="eeeeee" class="exibir">Situa&ccedil;&atilde;o:
            <label><span class="style4">
            <select name="frmResp" class="form" id="frmResp" onChange="exibe(this.value)" onFocus="ordenar()">
			 <option selected="selected" value="N">---</option>
              <cfoutput query="rsPonto">
			     <cfif (STO_Codigo neq 0) and (STO_Codigo neq 1) and (STO_Codigo neq 2) and (STO_Codigo neq 4) and (STO_Codigo neq 5) and (STO_Codigo neq 8) and (STO_Codigo neq 20)>
                 <option value="#STO_Codigo#" <cfif #STO_Codigo# is #Form.frmResp#>selected</cfif>>#trim(STO_Descricao)#</option>
				</cfif>
              </cfoutput>
            </select>
          </label></td>
      </tr>
<tr bgcolor="eeeeee">
			<td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idterctransfer">Terceiros (Transferido):
					<select name="cbterctransfer" id="cbterctransfer" class="form">
								<option selected="selected" value="">---</option>
								<cfoutput query="rsTercTransfer">
								  <option value="#Und_Codigo#" <cfif #Und_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Und_Descricao)#</option>
								</cfoutput>
					</select>	      
	
			</div>			</td>
	  </tr>				
		<tr bgcolor="eeeeee">
			<td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idunidtransfer">Unidade (Transferido):
					<select name="cbunidtransfer" id="cbunidtransfer" class="form">
								<option selected="selected" value="">---</option>
								<cfoutput query="rsUnidTransfer">
								  <option value="#Und_Codigo#" <cfif #Und_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Und_Descricao)#</option>
								</cfoutput>
					</select>	      
	
			</div>			</td>
		</tr>		

		<tr bgcolor="eeeeee">
			<td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idsubortransfer">Subordinador (Transferido):
					<select name="cbsubordinador" id="cbsubordinador" class="form">
								<option selected="selected" value="">---</option>
								<cfoutput query="rsReopTransfer">

								  <option value="#Rep_Codigo#" <cfif #Rep_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Rep_Nome)#</option>
								</cfoutput>
					</select>	      
	
			</div>			</td>
		</tr>			
		<tr bgcolor="eeeeee">
        <td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idSCOI">Selecionar SCOI:
				<select name="cbscoi" id="cbscoi" class="form">
                            <option selected="selected" value="">---</option>
                            <cfoutput query="qscoi">
                              <option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Ars_Sigla)#</option>
                            </cfoutput>
                </select>	      

        </div>        </td>
</tr>	
		<tr bgcolor="eeeeee">
        <td height="22" colspan="3" bgcolor="eeeeee" class="exibir"><div id="dArea">Selecione a &Aacute;rea:

				   <select name="select" id="select" class="form" onChange="SelecArea(this.value)">
                     <option selected="selected" value="">---</option>
                     <cfoutput query="qArea">
                       <option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Ars_Descricao)#</option>
                     </cfoutput>
                   </select>
        </div></td>
       <cfif trim(qResposta.Pos_VLRecuperado) eq ''>
	      <cfset vlrrecaux = "0,00">
       <cfelse>
	     <cfset vlrrecaux = #mid(LSCurrencyFormat(qResposta.Pos_VLRecuperado, "local"), 4, 20)#>
       </cfif>
	   <td colspan="2" bgcolor="eeeeee" class="exibir"><div id="dValor">Valor Regularizado(R$):&nbsp;&nbsp;
	   <input name="VLRecuperado" type="text" class="form"  size="22" maxlength="16"  onFocus="moeda_dig(this.name)" onKeyPress="press_tecla(this.name)" onKeyUp="soltar_tecla(this.name)"  onBlur="ajuste_campo(this.name)">	  </td>
        </tr>
        <tr bgcolor="f7f7f7">
          <td colspan="5" bgcolor="eeeeee" class="exibir"><div id="dAreaCS">Selecione a &Aacute;rea:
  
                    <select name="cbareaCS" class="form">
                        <option selected="selected" value="">---</option>
                        <cfoutput query="qAreaCS">
                          <option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Ars_Descricao)#</option>
                        </cfoutput>
                    </select>
        </div>        </td>
        </tr>
<!---  --->
<tr bgcolor="eeeeee">
<td colspan="5" class="exibir"><div id="dAreaCS">Selecione a &Aacute;rea(CS):
	<select name="cbareaCS" class="form">
	  <option selected="selected" value="">---</option>
	  <cfoutput query="qAreaCS">
		<option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Ars_Descricao)#</option>
	  </cfoutput>
	</select>
</div></td>
</tr>
<tr bgcolor="eeeeee">
<td colspan="5" class="exibir"><div id="dAreascia">Selecione a &Aacute;rea(SCIA):
	<select name="cbscia" class="form">
	 <!---  <option selected="selected" value="">---</option> --->
	  <cfoutput query="qscia">
		<option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#ucase(trim(Ars_Descricao))#</option>
	  </cfoutput>
	</select>
</div></td>
</tr>
<!---  --->
<tr bgcolor="eeeeee">
  <td colspan="5" bgcolor="eeeeee" class="exibir">&nbsp;</td>
</tr>
<tr bgcolor="eeeeee">
	     <cfset npjudic = #trim(qResposta.Pos_NumProcJudicial)#>
	   <td colspan="5" bgcolor="eeeeee" class="exibir">Nº Processo Judicial:&nbsp;&nbsp;
	     <input name="posnumprocjudicial" type="text" class="form" value="<cfoutput>#npjudic#</cfoutput>"  size="40" maxlength="30">	  </td>
      </tr>
<!---  --->
<tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr bgcolor="eeeeee">
        <td align="center"><span class="titulos">Opini&atilde;o da Equipe de Controle Interno:</span></td>
        <td colspan="5"><textarea name="observacao" cols="200" rows="25" nome="observacao" vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#Session.E01.observacao#</cfoutput></textarea></td>
      </tr>
      <tr>
        <td colspan="4" class="exibir" bgcolor="eeeeee"><strong class="exibir">ANEXOS</strong></td>
        <td bgcolor="eeeeee" class="exibir"></td>
      </tr>
      <tr bgcolor="eeeeee">
        <td class="exibir"><strong class="exibir">Arquivo:</strong></td>
        <td class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td width="161" class="exibir">&nbsp;</td>
        <td class="exibir"><input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" <cfoutput>#halbtgeral#</cfoutput>></td>
        <td class="exibir">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <cfloop query= "qAnexos">
        <cfif FileExists(qAnexos.Ane_Caminho)>
		  <tr>
            <td colspan="3" bgcolor="eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td width="472" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <div align="left">
                  &nbsp;
                  <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />
                </div></td>
            <td bgcolor="eeeeee">
              <div align="center">
			<cfif (resp neq 24) and (habslvsn eq 'S')>
                <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=<cfoutput>'#qAnexos.Ane_Codigo#'</cfoutput>" value="Excluir" <cfoutput>#halbtgeral#</cfoutput>>
            <cfelse>
				<input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=<cfoutput>'#qAnexos.Ane_Codigo#'</cfoutput>" value="Excluir" disabled>
            </cfif>
              </div>            </td>
          </tr>
        </cfif>
      </cfloop>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
   <cfelse>
     <tr>
      <td colspan="5">
		  <cfif trim(qResposta.Pos_NCISEI) eq "">
		    <cfset auxnci = "Nao">
			<cfset numncisei = "">
	      <cfelse>
			<cfset auxnci = "Sim">
			<cfset numncisei = trim(rsSEINCI.Pos_NCISEI)>
			<cfset numncisei = left(numncisei,5) & '.' & mid(numncisei,6,6) & '/' & mid(numncisei,12,4) & '-' & right(numncisei,2)>
	      </cfif>
	     <input type="hidden" name="nseincirel" id="nseincirel" value="<cfoutput>#numncisei#</cfoutput>">
		<table width="100%" border="0">
			<tr bgcolor="f7f7f7">
				<td colspan="5" valign="middle" bgcolor="eeeeee" class="exibir">Houve Nota de Controle?&nbsp;&nbsp;<input name="nci" id="nci" type="text" class="form" size="4" maxlength="3" value="<cfoutput>#auxnci#</cfoutput>" readonly>				</td>
				<cfif auxnci eq "Sim">
					<td width="77%" bgcolor="eeeeee" class="exibir">N&ordm; SEI da NCI :&nbsp;&nbsp;
					   <input name="frmnumseinci" id="frmnumseinci" type="text" class="form" onKeyPress="numericos()" onKeyDown="validacao(); Mascara_SEI(this)" size="27" maxlength="20" value="<cfoutput>#numncisei#</cfoutput>" ReadOnly>					</td>
				</cfif>
			</tr>
        </table>       </td>
    </tr>

      <tr bgcolor="f7f7f7">
        <td height="22" colspan="5" valign="middle" bgcolor="eeeeee" class="exibir">Situa&ccedil;&atilde;o:
              <select name="frmResp" class="form" id="frmResp" onChange="exibe(this.value)">
			  <option selected="selected" value="N">---</option>
              <cfoutput query="rsPonto" >
                <cfif (STO_Codigo neq 0) and (STO_Codigo neq 1) and (STO_Codigo neq 2) and (STO_Codigo neq 4) and (STO_Codigo neq 5) and (STO_Codigo neq 8) and (STO_Codigo neq 20)>
                 <option value="#STO_Codigo#" <cfif #STO_Codigo# is #Form.frmResp#>selected</cfif>>#trim(STO_Descricao)#</option>
				</cfif>
              </cfoutput>
            </select>        </td>
	  <tr bgcolor="eeeeee">
			<td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idterctransfer">Terceiro (Transferido):
					<select name="cbterctransfer" id="cbterctransfer" class="form">
								<option selected="selected" value="">---</option>
								<cfoutput query="rsTercTransfer">
								  <option value="#Und_Codigo#" <cfif #Und_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Und_Descricao)#</option>
								</cfoutput>
					</select>	      
	
			</div>			</td>
	  </tr>				
		<tr bgcolor="eeeeee">
			<td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idunidtransfer">Unidade (Transferido):
					<select name="cbunidtransfer" id="cbunidtransfer" class="form">
								<option selected="selected" value="">---</option>
								<cfoutput query="rsUnidTransfer">
								  <option value="#Und_Codigo#" <cfif #Und_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Und_Descricao)#</option>
								</cfoutput>
					</select>	      
	
			</div>			</td>
		</tr>		

		<tr bgcolor="eeeeee">
			<td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idsubortransfer">Subordinador (Transferido):
					<select name="cbsubordinador" id="cbsubordinador" class="form">
								<option selected="selected" value="">---</option>
								<cfoutput query="rsReopTransfer">
								  <option value="#Rep_Codigo#" <cfif #Rep_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Rep_Nome)#</option>
								</cfoutput>
					</select>	      
	
			</div>			</td>
		</tr>					
<tr bgcolor="eeeeee">
        <td height="22" colspan="5" bgcolor="eeeeee" class="exibir"><div id="idSCOI">Selecionar SCOI:
				<select name="cbscoi" id="cbscoi" class="form">
                            <option selected="selected" value="">---</option>
                            <cfoutput query="qscoi">
                              <option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Ars_Sigla)#</option>
                            </cfoutput>
                </select>	      

        </div>        </td>
</tr>	    

<tr bgcolor="eeeeee">
        <td height="22" colspan="3" bgcolor="eeeeee" class="exibir"><div id="dArea">Selecione a &Aacute;rea:
				<select name="cbarea" id="cbarea" class="form" onChange="SelecArea(this.value)">
                            <option selected="selected" value="">---</option>
                            <cfoutput query="qArea">
                              <option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Ars_Descricao)#</option>
                            </cfoutput>
                </select>	      

        </div></td>

	<cfif trim(qResposta.Pos_VLRecuperado) eq ''>
	  <cfset vlrrecaux = "">
	<cfelse>
	     <cfset vlrrecaux = #mid(LSCurrencyFormat(qResposta.Pos_VLRecuperado, "local"), 4, 20)#>
	</cfif>
		   <td colspan="2" bgcolor="eeeeee" class="exibir"><div id="dValor">Valor Regularizado(R$):&nbsp;&nbsp;
		   <input name="VLRecuperado" type="text" class="form"  size="22" maxlength="17"  onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)"  onBlur="ajuste_campo(this.name)">		  </td>
</tr>

<tr bgcolor="eeeeee">
<td colspan="5" class="exibir"><div id="dAreaCS">Selecione a &Aacute;rea(CS):
	<select name="cbareaCS" class="form">
	  <option selected="selected" value="">---</option>
	  <cfoutput query="qAreaCS">
		<option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#trim(Ars_Descricao)#</option>
	  </cfoutput>
	</select>
</div></td>
</tr>
<tr bgcolor="eeeeee">
<td colspan="5" class="exibir"><div id="dAreascia">Selecione a &Aacute;rea(SCIA):
	<select name="cbscia" class="form">
	<!---   <option selected="selected" value="">---</option> --->
	  <cfoutput query="qscia">
		<option value="#Ars_Codigo#" <cfif #Ars_Codigo# is #qResposta.Pos_Area#>selected</cfif>>#ucase(trim(Ars_Descricao))#</option>
	  </cfoutput>
	</select>
</div></td>
</tr>

<!---  --->
<!---  --->
<tr bgcolor="eeeeee">
  <td colspan="5" bgcolor="eeeeee" class="exibir">&nbsp;</td>
</tr>
<tr bgcolor="eeeeee">
	     <cfset npjudic = #trim(qResposta.Pos_NumProcJudicial)#>
	   <td colspan="5" bgcolor="eeeeee" class="exibir">Nº Processo Judicial:&nbsp;&nbsp;
	     <input name="posnumprocjudicial" type="text" class="form" value="<cfoutput>#npjudic#</cfoutput>"  size="40" maxlength="30">	  </td>
      </tr>
<!---  --->
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr>
        <td bgcolor="eeeeee" align="center"><span class="titulos">Opini&atilde;o da Equipe de Controle Interno:</span></td>
        <td colspan="5" bgcolor="f7f7f7"><textarea name="observacao" cols="200" rows="25" nome="observacao" vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#Form.observacao#</cfoutput></textarea></td>
      </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
      <tr bgcolor="#eeeeee">
        <td colspan="5" bgcolor="eeeeee" class="exibir"><strong class="exibir">ANEXOS</strong></td>
      </tr>
      <tr>
        <td bgcolor="eeeeee" class="exibir"><strong class="exibir">Arquivo:</strong></td>
        <td colspan="2" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file" size="50"></td>
        <td bgcolor="eeeeee" class="exibir">
          <div align="left">
		<!--- <cfif (resp neq 24) and ('#qUsuario.Usu_DR#' eq left(url.PosArea,2))> --->
		<cfif (resp neq 24) and (habslvsn eq 'S')>
		  <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" <cfoutput>#halbtgeral#</cfoutput>>
		<cfelse>
		  <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'" value="Anexar" disabled>
		</cfif>
          </div></td>
        <td bgcolor="eeeeee" class="exibir">&nbsp;</td>
      </tr>
   <!---    <tr>
        <td colspan="5">&nbsp;</td>
      </tr> --->
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
            <td width="472" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <div align="left">
                  &nbsp;
                  <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />
                </div></td>
            <td bgcolor="eeeeee">
              <div align="center">
       <!---  <cfif (resp neq 24) and ('#qUsuario.Usu_DR#' eq left(url.PosArea,2))> --->
		<cfif (resp neq 24) and (habslvsn eq 'S')>		
           <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=<cfoutput>'#qAnexos.Ane_Codigo#'</cfoutput>" value="Excluir" <cfoutput>#halbtgeral#</cfoutput>>
        <cfelse>
	       <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=<cfoutput>'#qAnexos.Ane_Codigo#'</cfoutput>" value="Excluir" disabled>
        </cfif>
              </div>            </td>
          </tr>
        </cfif>
      </cfloop>
    </cfif>
	<cfif qResposta.Pos_DtPrev_Solucao EQ "" OR dateformat(qResposta.Pos_DtPrev_Solucao,"YYYYMMDD") lt dateformat(now(),"YYYYMMDD") >
	  <cfset dtprevsol = dateformat(now(),"DD/MM/YYYY")>
	<cfelse>
	  <cfset dtprevsol = dateformat(qResposta.Pos_DtPrev_Solucao,"DD/MM/YYYY")>
	</cfif>
	<input name="frmdtprevsol" type="hidden" id="frmdtprevsol" value="<cfoutput>#dtprevsol#</cfoutput>">
	<input name="frmnovoprazo" type="hidden" id="frmnovoprazo" value="N">
    <tr>
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="eeeeee">
	 <td colspan="5" class="exibir">Data de Previs&atilde;o da Solu&ccedil;&atilde;o:&nbsp;&nbsp;
	<input name="cbdata" id="cbdata" type="text" class="form" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" size="14" maxlength="10" value="<cfoutput>#dtprevsol#</cfoutput>">	</td>
   </tr>
      <tr>
        <td colspan="5">&nbsp;</td>
      </tr>
<tr>
 <td colspan="5" align="center"><div align="center">
   <cfoutput>
<!---    <input name="button" type="button" class="botao" onClick="window.open('itens_controle_respostas.cfm?ckTipo=inspecao&txtNum_Inspecao=#URL.Ninsp#&Submit2=Confirmar','_self')" value="Voltar"> --->
	   <cfset auxdtini = dateformat(dtinic,"dd/mm/yyyy")>
	   <cfset auxdtfim = dateformat(dtfim,"dd/mm/yyyy")>
<!--- 	   <cfif houveProcSN neq "S"> --->
	     <input name="button" type="button" class="botao" onClick="window.open('itens_controle_respostas.cfm?ninsp=#URL.Ninsp#&unid=#URL.Unid#&ngrup=#URL.Ngrup#&nitem=#URL.Nitem#&dtfim=#auxdtfim#&dtinic=#auxdtini#&SE=#url.SE#&cktipo=#url.cktipo#&selstatus=#url.situacao#&StatusSE=#url.StatusSE#','_self')" value="Voltar">
<!---        <cfelse>
         <input name="button" type="button" class="botao" value="Voltar" disabled>       
       </cfif> --->
      </cfoutput> &nbsp;&nbsp;&nbsp;&nbsp;

	<!---   <cfoutput>sn:#habslvsn#</cfoutput> --->
	   <cfset numdias = qResposta.diasOcor>
<!---    	  <cfif ((resp is 1 and numdias lte 2) or (resp is 6 and numdias lte 2) or (resp is 7 and numdias lte 2) or (resp is 17 and numdias lte 2) or (resp is 22 and numdias lte 2) or (resp is 18) or (resp is 24) or (habslvsn eq 'N'))>
		<input name="Salvar2" type="submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar2';" disabled>
	  <cfelse>
        <input name="Salvar2" type="submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar2'">
      </cfif> --->
	 <cfif ((resp is 3) or (resp is 24) or (resp is 31) or (habslvsn eq 'N'))> 
	 		<input name="Salvar2" type="submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar2';" disabled>
	  <cfelse>
            <input name="Salvar2" type="submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar2'" <cfoutput>#halbtgeral#</cfoutput>>
      </cfif>
      </div>	  </td>
    </tr>

     <!--- </table> --->
    <input type="hidden" name="MM_UpdateRecord" id="MM_UpdateRecord" value="form1">
    <input type="hidden" name="salvar_anexar"  id="salvar_anexar" value="">
	<input name="dtdehoje" type="hidden" id="dtdehoje" value="<cfoutput>#dateformat(now(),"DD/MM/YYYY")#</cfoutput>">
	<input name="dthojeyyyymmdd" type="hidden" id="dthojeyyyymmdd" value="<cfoutput>#DateFormat(now(),'YYYYMMDD')#</cfoutput>">
    
	<cfset dtposicfut = CreateDate(year(now()),month(now()),day(now()))> 
	
	<cfset aux_Tratam_Teto_Data = DateAdd( "d", 365, dtposicfut)>  
    <input name="Tratam_Teto_Data" type="hidden" id="Tratam_Teto_Data" value="<cfoutput>#DateFormat(aux_Tratam_Teto_Data,'YYYYMMDD')#</cfoutput>">

	 <!--- ===================== --->	
	<cfoutput>				
	<cfset nCont = 0>
	<cfloop condition="nCont lte 9">
		<cfset nCont = nCont + 1>
		<cfset dtposicfut = DateAdd( "d", 1, dtposicfut)>
		<cfset vDiaSem = DayOfWeek(dtposicfut)>
		<cfif vDiaSem neq 1 and vDiaSem neq 7>
			<!--- verificar se Feriado Nacional --->
			<cfquery name="rsFeriado" datasource="#dsn_inspecao#">
				 SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #dtposicfut#
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
	</cfoutput>
	 <cfif dateformat(qResposta.Pos_DtPrev_Solucao,'YYYYMMDD') gt DateFormat(dtposicfut,'YYYYMMDD')>
	  		<cfset dtposicfut = qResposta.Pos_DtPrev_Solucao>
    </cfif>		   
	  <!--- ===================== --->	
	<input name="frmsitatual" type="hidden" id="frmsitatual" value="<cfoutput>#qResposta.Pos_Situacao_Resp#</cfoutput>">
	<input name="dtdezdiasfut" type="hidden" id="dtdezdiasfut" value="<cfoutput>#DateFormat(dtposicfut,'DD/MM/YYYY')#</cfoutput>">
	<input type="hidden" name="auxano" id="auxano" value="<cfoutput>#right(DateFormat(now(),'YYYY'),2)#</cfoutput>">
	<input name="dtdezddtrat" type="hidden" id="dtdezddtrat" value="<cfoutput>#DateFormat(dtposicfut,'YYYYMMDD')#</cfoutput>">
	<input type="hidden" name="NumSEIAtu" id="NumSEIAtu" value="<cfoutput>#trim(qResposta.Pos_SEI)#</cfoutput>">

<!---     <input type="hidden" name="itnpontuacao" id="itnpontuacao" value="<cfoutput>#qResposta.itn_pontuacao#</cfoutput>"> --->
	<input type="hidden" name="dbreincInsp" id="dbreincInsp" value="<cfoutput>#db_reincInsp#</cfoutput>">
	<input type="hidden" name="dbreincGrup" id="dbreincGrup" value="<cfoutput>#db_reincGrup#</cfoutput>">
	<input type="hidden" name="dbreincItem" id="dbreincItem" value="<cfoutput>#db_reincItem#</cfoutput>">
    <input type="hidden" name="dbfrmnumsei" id="dbfrmnumsei" value="">
    <input type="hidden" name="PrzVencSN" id="PrzVencSN" value="<cfoutput>#PrzVencSN#</cfoutput>">
    <input type="hidden" name="auxavisosn" id="auxavisosn" value="<cfoutput>#auxavisosn#</cfoutput>">   
	<input type="hidden" name="frmtransfer" id="frmtransfer" value="<cfoutput>#auxtransfer#</cfoutput>">
 </form>
  <!--- Fim area de conteudo --->
</table>

</body>

<script>
	<cfoutput>
		<!---Retorna true se a data de início da inspecao for maior ou igual a 04/03/2021, data em que o editor de texto foi implantado. Isso evitar&atilde; que os textos anteriores sejam desformatados--->
		<cfset CouponDate = createDate( 2021, 03, 04 ) />
		<cfif DateDiff( "d", '#qResposta.INP_DtInicInspecao#',CouponDate ) GTE 1>
			<cfset usarEditor = false />
		<cfelse>
			<cfset usarEditor = true />
		</cfif>
		var usarEditor = #usarEditor#;
	</cfoutput>
	if(usarEditor == true){
		//configura&ccedil;&otilde;es diferenciadas do editor de texto.
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

<!--- <cfelse>
     <cfinclude template="permissao_negada.htm"> 
</cfif>--->
