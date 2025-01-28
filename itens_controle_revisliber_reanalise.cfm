<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>   

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, RTRIM(LTRIM(Usu_GrupoAcesso)) AS Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena, Usu_LotacaoNome
	from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>

<cfif isDefined("Form.auxajuste")> 
  <cfparam name="Form.auxajuste" default="#form.auxajuste#">
  <cfparam name="URL.pg" default="#form.pg#">
  <cfparam name="URL.Ninsp" default="#trim(Form.Ninsp)#">
  <cfparam name="URL.Ngrup" default="#trim(Form.Ngrup)#">
  <cfparam name="URL.Nitem" default="#trim(Form.Nitem)#">
  <cfparam name="URL.tpunid" default="#trim(Form.tpunid)#">
  <cfparam name="URL.modal" default="#trim(Form.modal)#">
<cfelse>
   <cfparam name="Form.auxajuste" default="">
   <cfparam name="URL.Ninsp" default="">
   <cfparam name="URL.Ngrup" default="">
   <cfparam name="URL.Nitem" default="">
   <cfparam name="URL.pg" default="">
</cfif> 

<cfquery name="qOrientacao" datasource="#dsn_inspecao#">
	SELECT RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor, RIP_Recomendacao, RIP_Resposta, INP_Modalidade 
	FROM Resultado_Inspecao
	INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
	WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
</cfquery>

<cfquery name="qItemReanalise" datasource="#dsn_inspecao#">
	SELECT * FROM Itens_Verificacao
	INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo and Grp_Ano = Itn_Ano
	WHERE Itn_Ano=RIGHT('#URL.Ninsp#',4) AND Grp_Ano=Itn_Ano and Itn_NumGrupo=#url.Ngrup# and Itn_NumItem ='#url.Nitem#' and Itn_TipoUnidade = #tpunid# and itn_modalidade = '#modal#'
</cfquery>

<cfquery name="qUltimoReavaliado" datasource="#dsn_inspecao#">
	SELECT RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor, RIP_Recomendacao FROM Resultado_Inspecao
	WHERE RIP_NumInspecao = '#URL.Ninsp#' AND RIP_Recomendacao = 'R'
</cfquery>

<cfif isDefined("Form.acao") and "#form.acao#" eq 'cancelarReanalise'>
	<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
	<cfif left(maskcgiusu,8) eq 'EXTRANET'>
		<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
	<cfelse>
		<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
	</cfif>
	<!---Veirifica se esta inspeção possui algum item em reanálise --->
	<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
		SELECT RIP_Resposta, RIP_Recomendacao, RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor 
		FROM Resultado_Inspecao 
		WHERE (RIP_Recomendacao='S' OR RIP_Recomendacao='R') and RIP_NumInspecao='#ninsp#'  
	</cfquery>

	<cfif qVerifEmReanalise.recordCount eq 0>
		<!--- Update na tabela Inspecao com sigla  NA = não avaliada, ER = em reavaliação, RA = reavaliada, CO = concluída--->
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Inspecao set INP_Situacao ='CO', INP_DtEncerramento =  CONVERT(char, GETDATE(), 102), INP_DtUltAtu =  CONVERT(char, GETDATE(), 120), INP_UserName ='#CGI.REMOTE_USER#'
			WHERE INP_NumInspecao = '#URL.Ninsp#' 
		</cfquery>
	</cfif>
	<!--- Update na tabela Resultado_Inspecao--->
	<cfset auxcancel = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Cancelar Reanálise ' & CHR(13) & #form.recomendacao# & CHR(13)  &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qAcesso.Usu_Apelido) & '\' & Trim(qAcesso.Usu_LotacaoNome) & CHR(13) &  '-----------------------------------------------------------------------------------------------------------------------' & CHR(13) & #qVerifEmReanalise.RIP_Recomendacao_Inspetor#>		
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao set 
			RIP_Recomendacao = ''
			, RIP_Recomendacao_Inspetor= '#auxcancel#'
            , RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
            , RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)  			
		WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
	</cfquery>
		
	<script>
		<cfoutput>
			var	pg = '#URL.pg#';
		</cfoutput>
		if( pg == 'pt'){
			window.opener.location.reload();
		}
		<cfoutput>	
		<!---
			<cfif qInspecaoLiberada.recordCount neq 0 or qVerifEmReanalise.recordCount neq 0>
				alert("Reanálise cancelada!");
			</cfif>
		--->
		</cfoutput>
		window.close(); 
	</script>
</cfif>

<cfif isDefined("Form.acao") and "#form.acao#" eq 'validar'>

	<cfquery datasource="#dsn_inspecao#" name="rsVerificaItem">
		SELECT  RIP_Resposta, RIP_Unidade, RIP_NCISEI FROM Resultado_Inspecao 
		WHERE RIP_NumInspecao='#FORM.Ninsp#' And RIP_NumGrupo = '#FORM.Ngrup#' and RIP_NumItem ='#FORM.Nitem#' 
	</cfquery>
	<cfparam name="FORM.unid" default="#rsVerificaItem.RIP_Unidade#">
	<!--- Update na tabela Resultado_Inspecao--->
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao set 
		RIP_Recomendacao = 'V'
		, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
		, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)			
		WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
	</cfquery>

	<!---Verifica se esta inspeção possui algum item em reanálise --->
	<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
		SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
		WHERE (RIP_Recomendacao='S' OR RIP_Recomendacao='R') and RIP_NumInspecao='#ninsp#'  
	</cfquery>
	<cfif qVerifEmReanalise.recordCount eq 0>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Inspecao SET INP_Situacao ='CO', INP_DtEncerramento =  CONVERT(char, GETDATE(), 102), INP_DtUltAtu =  CONVERT(char, GETDATE(), 120), INP_UserName ='#CGI.REMOTE_USER#' 
			WHERE INP_NumInspecao ='#ninsp#'
		</cfquery>
	</cfif>    

	<!---Início do processo de liberação da avaliação--->
	<!---Veirifica se esta inspeção possui algum item Em Revisão --->	
	<cfquery name="qInspecaoLiberada" datasource="#dsn_inspecao#">
		SELECT * FROM ParecerUnidade 
		WHERE Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 0
	</cfquery>
		
	<!---Verifica se esta inspeção possui algum item não avaliado (todos os NÃO VERIFICADO e os NÂO EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1) --->
	<cfquery datasource="#dsn_inspecao#" name="qVerifValidados">
		SELECT RIP_Resposta, RIP_Recomendacao 
		FROM Resultado_Inspecao 
	INNER JOIN Inspecao on RIP_NumInspecao = INP_NumInspecao and RIP_Unidade = INP_Unidade
	INNER JOIN Itens_Verificacao ON Itn_Ano = convert(char(4),RIP_Ano) AND Itn_NumGrupo = RIP_NumGrupo AND Itn_NumItem = RIP_NumItem and inp_Modalidade = itn_modalidade
	INNER JOIN Unidades ON Und_Codigo = RIP_Unidade and (Itn_TipoUnidade = Und_TipoUnidade)
			WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') AND RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#ninsp#' and RIP_Unidade='#unid#' 
	</cfquery>

	<script>
		<cfoutput>
			var	pg = '#URL.pg#';
			
		</cfoutput>
			if( pg == 'pt'){
			window.opener.location.reload();
		}
		<cfoutput>	
			<cfif qInspecaoLiberada.recordCount neq 0 or qVerifEmReanalise.recordCount neq 0>
				alert("Reanálise validada!");
			</cfif>
		</cfoutput>
		window.close(); 
	</script>
</cfif>

<cfif isDefined("Form.acao") and "#form.acao#" eq 'respostacomreanalise'>
		<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
		<cfif left(maskcgiusu,8) eq 'EXTRANET'>
			<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
		<cfelse>
			<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
		</cfif>
	
		<cftransaction>
			<!--- Update na tabela Resultado_Inspecao--->
			<cfquery name="rsRecomCrit" datasource="#dsn_inspecao#">
				select RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor from Resultado_Inspecao 
				WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
			</cfquery>
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Resultado_Inspecao set 
				<cfif #grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES'>
					<cfset auxrec = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Recomendação ao Inspetor(es) ' & CHR(13) & #form.recomendacao# & CHR(13)  &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qAcesso.Usu_Apelido) & '\' & Trim(qAcesso.Usu_LotacaoNome) & CHR(13) &  '-----------------------------------------------------------------------------------------------------------------------' & CHR(13) & #rsRecomCrit.RIP_Recomendacao_Inspetor#>
					RIP_Recomendacao = 'S', RIP_Recomendacao_Inspetor = '#auxrec#'
				<cfelse>
					<cfset auxcrit = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Crítica do Inspetor (COM REANÁLISE DO PONTO)' & CHR(13) & #form.respInsp# & CHR(13)  &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qAcesso.Usu_Apelido) & '\' & Trim(qAcesso.Usu_LotacaoNome) & CHR(13) &  '-----------------------------------------------------------------------------------------------------------------------' & CHR(13) & #rsRecomCrit.RIP_Critica_Inspetor#>				
					RIP_Critica_Inspetor='#auxcrit#'
				</cfif>
				<cfif grpacesso eq 'GESTORES'>
					, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
					, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
				</cfif>	  				
				WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo ='#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
			</cfquery>
			<cfif #grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES'>
				<!--- Update na tabela Inspecao com sigla  NA = não avaliada, ER = em reavaliação, RA = reavaliada, CO = concluída--->
			<cfquery datasource="#dsn_inspecao#">
					UPDATE Inspecao set INP_Situacao ='ER',INP_DtEncerramento =  CONVERT(char, GETDATE(), 102), INP_DtUltAtu =  CONVERT(char, GETDATE(), 120), INP_UserName ='#CGI.REMOTE_USER#'
					WHERE INP_NumInspecao = '#URL.Ninsp#' 
				</cfquery>

				<cfquery name="rsEmail" datasource="#dsn_inspecao#">
					SELECT RIP_NumGrupo, RIP_NumItem, RIP_NumInspecao, RIP_MatricAvaliador, Usu_Matricula, Usu_Apelido, Und_Codigo, LTRIM(RTRIM(Und_Descricao)) as Und_Descricao, LTRIM(RTRIM(Usu_Email)) as Usu_Email ,
					       CASE WHEN LTRIM(RTRIM(RIP_MatricAvaliador))=LTRIM(RTRIM(Usu_Matricula)) THEN 1 ELSE 0 END AS Avaliador 
					FROM Resultado_Inspecao
					INNER JOIN Inspetor_Inspecao ON IPT_NumInspecao = RIP_NumInspecao
					INNER JOIN Usuarios ON Usu_Matricula = IPT_MatricInspetor
					INNER JOIN Unidades ON Und_Codigo = RIP_Unidade
					WHERE  RIP_NumInspecao = '#URL.Ninsp#' AND RIP_NumGrupo ='#url.Ngrup#' AND RIP_NumItem ='#url.Nitem#'
				</cfquery>	
				<cfquery name="rsAvaliador" dbType="query">
					SELECT Usu_Matricula, Usu_Apelido FROM rsEmail WHERE Avaliador = 1
				</cfquery>

				<cfset Num_Insp = Left(rsEmail.RIP_NumInspecao,2) & '.' & Mid(rsEmail.RIP_NumInspecao,3,4) & '/' & Right(rsEmail.RIP_NumInspecao,4)>
                <cfset Num_Matricula =Left(rsAvaliador.Usu_Matricula,'1') & '.' & Mid(rsAvaliador.Usu_Matricula,2,3) & '.' & Mid(rsAvaliador.Usu_Matricula,5,3) & '-' & Right(rsAvaliador.Usu_Matricula,1)>

				<cfset sdestina =''>
				<cfloop query="rsEmail">
					<cfset sdestina = rsEmail.Usu_Email & ';' & sdestina>
				</cfloop>						
				<cfset myImgPath = expandPath('./')>
				<cfset assunto = 'SNCI - AVALIACAO Nº ' & '#Num_Insp#' & ' - ' & '#trim(rsEmail.Und_Descricao)#'>
				<cfset auxdr = left(URL.Ninsp,2)>
				<cfif auxdr eq '04' or auxdr eq '12' or auxdr eq '18' or auxdr eq '30' or auxdr eq '32' or auxdr eq '34' or auxdr eq '60' or auxdr eq '70'>
					<cfset sdestina = sdestina & ';' & 'EDIMIR@correios.com.br'>
				</cfif>
			<cfoutput>
  			 <cfmail from="SNCI@correios.com.br" to="#sdestina#" subject="#assunto#" type="HTML">
					<div>
						<p><strong>Atenção! E-mail automático, não responder.</strong></p>
						<p>Prezados inspetores,</p>
						<p>Informa-se que existem itens no SNCI pendentes de REANÁLISE. Favor acessar a opção "Avaliação e Reanálise de Itens" na tela inicial do sistema e realizar os ajustes solicitados pelo revisor.</p> 
						<p>Avaliação: <span style="color:blue"><strong>#trim(Num_Insp)#</strong></span></p>
						<p>Item: <span style="color:blue"><strong>#rsEmail.RIP_NumGrupo#.#rsEmail.RIP_NumItem#</strong></span></p>
						<p>Unidade: <span style="color:blue"><strong>#trim(rsEmail.Und_Descricao)#</strong></span></p>
						<p>Item avaliado por: <span style="color:blue"><strong>#Num_Matricula# - #trim(rsAvaliador.Usu_Apelido)#</strong></span></p>
						<cfmailparam disposition="inline" contentid="topoginsp" file="#myImgPath#topoginsp.jpg">
						<p><a href="http://intranetsistemaspe/SNCI/rotinas_inspecao.cfm"><img src="cid:topoginsp.jpg" width="50%" align=middle >Acesse o SNCI endereço: 'http://intranetsistemaspe/snci/rotinas_inspecao.cfm'</a></p>
					</div>
			</cfmail> 
		</cfoutput>					
			 </cfif> 
		</cftransaction>
		<script>	
				
                <cfoutput>
					var	pg = '#url.pg#';
				</cfoutput>
				if( pg == 'pt'){
					window.opener.location.reload();
				}	
				<cfif ('#grpacesso#' eq 'GESTORES' or '#grpacesso#' eq 'DESENVOLVEDORES')>
					alert("Item enviado para Reanálise do Inspetor.\n\nObs.: Foi encaminhado um e-mail de aviso para a caixa postal do inspetor.");
				<cfelse>
					alert("Resposta salva!");
				</cfif>
				
			 	window.close(); 
		</script>

	<!--- </cfif> --->
</cfif>

<cfif isDefined("Form.acao") and "#form.acao#" eq 'respSemAlteracao'>	

		<cfset maskcgiusu = ucase(trim(CGI.REMOTE_USER))>
		<cfif left(maskcgiusu,8) eq 'EXTRANET'>
			<cfset maskcgiusu = left(maskcgiusu,9) & '***' &  mid(maskcgiusu,13,8)>
		<cfelse>
			<cfset maskcgiusu = left(maskcgiusu,12) & mid(maskcgiusu,13,4) & '***' & right(maskcgiusu,1)>	
		</cfif>			
		<!--- Update na tabela Resultado_Inspecao--->
		<cfquery name="rsRecomCrit" datasource="#dsn_inspecao#">
			select RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor, RIP_Falta, RIP_Sobra, RIP_EmRisco
			from Resultado_Inspecao 
			WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo =#url.Ngrup# and RIP_NumItem =#url.Nitem#
		</cfquery>
		<cfset auxcrit = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '>Crítica do Inspetor (SEM ALTERAÇÃO DO PONTO) ' & CHR(13) & #form.respInsp# & CHR(13)  &  'Responsável: ' & #maskcgiusu# & '\' & Trim(qAcesso.Usu_Apelido) & '\' & Trim(qAcesso.Usu_LotacaoNome) & CHR(13) &  '-----------------------------------------------------------------------------------------------------------------------' & CHR(13) & #rsRecomCrit.RIP_Critica_Inspetor#>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao set 
			RIP_Recomendacao = 'R'
			, RIP_Critica_Inspetor='#auxcrit#'
			<cfif grpacesso eq 'GESTORES'>
				, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
				, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
			</cfif>	  			
			WHERE RIP_NumInspecao = '#URL.Ninsp#' and RIP_NumGrupo =#url.Ngrup# and RIP_NumItem =#url.Nitem#
		</cfquery>
		
		<cfquery datasource="#dsn_inspecao#" name="rsVerificaItem">
			SELECT  RIP_Resposta, RIP_Unidade, RIP_NCISEI, RIP_Falta, RIP_REINCINSPECAO, INP_Modalidade
			FROM Resultado_Inspecao INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)
			WHERE RIP_NumInspecao='#FORM.Ninsp#' And RIP_NumGrupo = #FORM.Ngrup# and RIP_NumItem =#FORM.Nitem# 
		</cfquery>

		<cfparam name="FORM.unid" default="#rsVerificaItem.RIP_Unidade#">
		<!--- 	Verifica se ainda existem itens em reanálise.	 --->
		<cfquery datasource="#dsn_inspecao#" name="rsVerifItensEmReanalise">
				SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
				WHERE  RIP_Recomendacao='S' and RIP_NumInspecao='#FORM.Ninsp#'     
		</cfquery>
		
		<!--- Dado default para registro no campo Pos_Area --->
		<cfset posarea_cod = '#FORM.unid#'>	
		<!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
		<cfquery name="rsUnid" datasource="#dsn_inspecao#">
			SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#FORM.unid#'
		</cfquery>
		<!--- Dado default para registro no campo Pos_AreaNome --->
		<cfset posarea_nome = rsUnid.Und_Descricao>
		<!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->
		<cfquery name="rsItem2" datasource="#dsn_inspecao#">
			SELECT Itn_TipoUnidade, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
			FROM Unidades 
			INNER JOIN Inspecao ON Und_Codigo = INP_Unidade 
			INNER JOIN Itens_Verificacao ON (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
			WHERE (Itn_Ano = right('#FORM.Ninsp#',4)) and (Itn_NumGrupo = #FORM.Ngrup#) AND (Itn_NumItem = #FORM.Nitem#) and (INP_NumInspecao=#FORM.Ninsp#)
		</cfquery>

		<!--- Verificara possibilidade de alterar os dados default para Pos_Area e Pos_AreaNome ---> 
		<cfif trim(rsUnid.Und_Centraliza) neq "" and rsItem2.Itn_TipoUnidade eq 4>
			<!--- AC é Centralizada por CDD? --->
			<cfquery name="rsCDD" datasource="#dsn_inspecao#">
				SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsUnid.Und_Centraliza#'
			</cfquery>
			<cfset posarea_cod = #rsUnid.Und_Centraliza#>
			<cfset posarea_nome = #rsCDD.Und_Descricao#>
		</cfif>
		
     	<!---  Se o tem era uma reanálise e não existirem mais itens em reanálise, a finalização da verificação é realizada nesta página
		e não em itens_inspetores_avaliacao.cfm como acontece para as outras avaliações--->
		<cfif rsVerifItensEmReanalise.recordCount eq 0>
				<!---UPDATE em Inspecao--->
				<cfquery datasource="#dsn_inspecao#" ><!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluída---> 
					UPDATE Inspecao SET INP_Situacao = 'RA', INP_DtEncerramento =  CONVERT(char, GETDATE(), 102), INP_DtUltAtu =  CONVERT(char, GETDATE(), 120), INP_UserName ='#CGI.REMOTE_USER#'
					WHERE INP_Unidade='#FORM.unid#' AND INP_NumInspecao='#FORM.Ninsp#' 
				</cfquery>
				<!---Fim UPDATE em Inspecao
				<cflocation url = "itens_inspetores_avaliacao.cfm" addToken = "no"> --->
				<script>
					<cfoutput>
						window.opener.location.href="itens_inspetores_avaliacao.cfm";
					</cfoutput>
				</script>
		<cfelse>
				<script>
					<cfoutput>
						window.opener.location.href="itens_inspetores_avaliacao.cfm?numInspecao=#form.Ninsp#&Unid=#form.unid#";
					</cfoutput>
				</script>
		</cfif>		
		 				
		<script>
			window.close();
		</script>
</cfif>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">  
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title><cfif #grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES'>SNCI - ENVIA O ITEM PARA REANÁLISE PELO INSPETOR<CFELSE>SNCI - RECOMENDAÇÕES AO INSPETOR</CFIF></title>
<link rel="stylesheet" type="text/css" href="view.css" media="all">


<script type="text/javascript">
	function atualizaPT() {
		<cfoutput>
			var	pg = '#url.pg#';
		</cfoutput>
				if( pg == 'pt'){
					window.opener.location.reload();
				}				
	}

	function validarform(){
	var frm = document.forms.form1;
	<cfoutput>
	<cfif ('#grpacesso#' eq 'GESTORES' or '#grpacesso#' eq 'DESENVOLVEDORES')>
		if(frm.recomendacao.value == ''){
			alert('O campo "RECOMENDAÇÕES AO INSPETOR" não pode estar vazio.');
			frm.recomendacao.focus();
			return false;
		}

	<cfelse>
		if(frm.respInsp.value == ''){
			alert('O campo "RESPOSTA DO INSPETOR" não pode estar vazio.');
			frm.respInsp.focus();
			return false;
		}
	</cfif>	
	</cfoutput>
	//document.form1.acao.value='resp';
	return true;
	}

	function validarformSemReavaliar(){
		var frm = document.forms.form1;

		if(frm.respInsp.value == ''){
			alert('O campo "RESPOSTA DO INSPETOR" não pode estar vazio.');
			frm.respInsp.focus();
			return false;
		}

		if(confirm('Deseja salvar a sua resposta e devolver o item ao Gestor sem alterações?')){
			document.form1.acao.value='respSemAlteracao';
			return true;
		}else{
			return false;
		}
	}

</script>

</head>

<!---Veirifica se esta inspeção possui algum item Em Revisão --->	
<cfquery name="qInspecaoLiberada" datasource="#dsn_inspecao#">
	SELECT * FROM ParecerUnidade 
	WHERE Pos_Inspecao='#ninsp#' AND Pos_Situacao_Resp = 0
</cfquery>
<!---Veirifica se esta inspeção possui algum item em reanálise --->
<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
	SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
	WHERE (RIP_Recomendacao='S' or RIP_Recomendacao='R') and RIP_NumInspecao='#ninsp#'  
</cfquery>
	<!---Verifica se esta inspeção possui algum item não avaliado (todos os NÃO VERIFICADO e os NÂO EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1) --->
<cfquery datasource="#dsn_inspecao#" name="rsVerifValidados">
	SELECT RIP_Resposta, RIP_Recomendacao,Itn_ValidacaoObrigatoria 
	FROM Resultado_Inspecao 
	INNER JOIN Inspecao on RIP_NumInspecao = INP_NumInspecao and RIP_Unidade = INP_Unidade
	INNER JOIN Itens_Verificacao ON Itn_Ano = convert(char(4),RIP_Ano) AND Itn_NumGrupo = RIP_NumGrupo AND Itn_NumItem = RIP_NumItem and inp_Modalidade = itn_modalidade
	INNER JOIN Unidades ON Und_Codigo = RIP_Unidade and (Itn_TipoUnidade = Und_TipoUnidade)
	WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') AND   RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#ninsp#'  
</cfquery>

  <body id="main_body"  >
   <form id="form1" name="form1" onSubmit="" method="post" action="itens_controle_revisliber_reanalise.cfm">
        <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
        <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
        <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
		<input name="pg" type="hidden" id="pg" value="<cfoutput>#URL.pg#</cfoutput>">
		<input name="tpunid" type="hidden" id="tpunid" value="<cfoutput>#URL.tpunid#</cfoutput>">
		<input name="modal" type="hidden" id="modal" value="<cfoutput>#URL.modal#</cfoutput>">
		<input name="auxajuste" type="hidden" id="auxajuste" value="<cfoutput>#qOrientacao.RIP_Recomendacao_Inspetor#</cfoutput>">
		<input name="acao" type="hidden" id="acao" value="">

		<img alt="Ajuda do Item" src="figuras/reavaliar.png" width="45"  border="0" style="position:absolute;left:2px;top:5px"></img>
		<div align="center" style="margin-left:25px;width:700px;margin-top:15px">	
			<div>
				<p style="color:white;text-align:justify;font-size: 14px">Grupo: <cfoutput><strong>#qItemReanalise.Itn_NumGrupo# - #trim(qItemReanalise.Grp_Descricao)#</strong></cfoutput></p>
			
				<p style="color:white;text-align:justify;position:relative;top:-10px;font-size: 12px">Item: <cfoutput><strong>#qItemReanalise.Itn_NumItem# - #trim(qItemReanalise.Itn_Descricao)#</strong></cfoutput></p>
			</div>

            <div  style="background:#0a3865;border:1px solid #fff;font-family:Verdana, Arial, Helvetica, sans-serif">
		    	<label style="color:white"><strong>Histórico das Recomendações ao Inspetor:</strong></label>
				<textarea  <cfif #grpacesso# eq "inspetores">readonly</cfif> id="auxrecomendacao" name="auxrecomendacao" 
				style="background:#fff;color:black;text-align:justify;" cols="90" 
				rows="8" 
				wrap="VIRTUAL" class="form" disabled><cfoutput>#qOrientacao.RIP_Recomendacao_Inspetor#</cfoutput></textarea>
			</div>
			<cfif #grpacesso# eq 'GESTORES'> 
				<div  style="background:#0a3865;border:1px solid #fff;font-family:Verdana, Arial, Helvetica, sans-serif">
					<label style="color:white"><strong>Recomendações ao Inspetor:</strong></label>
					<textarea  <cfif #grpacesso# eq "INSPETORES">readonly</cfif> id="recomendacao" name="recomendacao" 
					style="background:#fff;color:black;text-align:justify;" cols="90" 
					rows="<cfif '#trim(qOrientacao.RIP_Recomendacao_Inspetor)#' neq ''>4<cfelse>6</cfif>" 
					wrap="VIRTUAL" class="form"></textarea>
				</div>
			</cfif> 
	<!--- 		<cfif '#trim(qOrientacao.RIP_Recomendacao_Inspetor)#' neq ''> --->
				<div  style="margin-top:20px;background:#0a3865;border:1px solid #fff;font-family:Verdana, Arial, Helvetica, sans-serif">
					<label style="color:white;margin-top:40px"><strong>Histórico das Respostas do Inspetor:</strong></label>
					<textarea  <cfif (#grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES')>readonly</cfif> id="auxrespInsp" name="auxrespInsp" 
					style="background:#fff;color:black;text-align:justify;" cols="90" rows="8" wrap="VIRTUAL" class="form" disabled><cfoutput>#qOrientacao.RIP_Critica_Inspetor#</cfoutput></textarea>
				</div>
          <!---   </cfif> --->
            <cfif #grpacesso# eq "INSPETORES">
				<div  style="margin-top:20px;background:#0a3865;border:1px solid #fff;font-family:Verdana, Arial, Helvetica, sans-serif">
					<label style="color:white;margin-top:40px"><strong>Resposta do Inspetor:</strong></label>
					<textarea  <cfif (#grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES')>readonly</cfif> id="respInsp" name="respInsp" 
					style="background:#fff;color:black;text-align:justify;" cols="90" rows="6" wrap="VIRTUAL" class="form"><cfoutput></cfoutput></textarea>
				</div>
            </cfif>

			<cfif (#grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES') and '#qOrientacao.RIP_Recomendacao#' eq 'R'>
				<cfif qInspecaoLiberada.recordCount eq 0 and rsVerifValidados.recordCount eq 0 and qVerifEmReanalise.recordCount eq 1 >
					<input type="submit" class="botao" 
					onclick="if(window.confirm('Atenção! Após a validação desta reanálise, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME. NÃO EXECUTA e NÃO VERIFICADO já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){document.form1.acao.value='validar'}" style="background-color:blue;color:#fff;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
			        value="Validar Reanálise">	
				<cfelse>
					<input type="submit" class="botao" onClick="document.form1.acao.value='validar'" style="background-color:blue;color:#fff;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
			        value="Validar Reanálise">	
				</cfif>
            </cfif>

            <cfif (#grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES') and not isDefined('url.cancelar')>
		        	<input type="submit" class="botao" onClick="document.form1.acao.value='respostacomreanalise'; return validarform();" style="background:red;color:#fff;margin-left:40px;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
			         value="Enviar para Reanálise do Inspetor"></input>	
			</cfif>
			
			<cfif (#grpacesso# eq 'GESTORES' or #grpacesso# eq 'DESENVOLVEDORES') and isDefined('url.cancelar') and '#url.cancelar#' eq 's'>
					<cfif qInspecaoLiberada.recordCount eq 0 and rsVerifValidados.recordCount eq 0 and qVerifEmReanalise.recordCount eq 1 and '#trim(qOrientacao.RIP_Resposta)#' neq 'N'>
						<input type="submit" class="botao"	onclick="if(window.confirm('Atenção! Após o cancelamento desta reanálise, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME. NÃO EXECUTA e NÃO VERIFICADO já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){document.form1.acao.value='cancelarReanalise';return validarform()}else{window.close();}" style="background:red;color:#fff;margin-left:40px;padding:2px;text-align:center;margin-top:10px;cursor:pointer"  
						value="Cancelar Reanálise">	
					<cfelse>
						<input type="submit" class="botao" onClick="document.form1.acao.value='cancelarReanalise';return validarform()" style="background:red;color:#fff;margin-left:40px;padding:2px;text-align:center;margin-top:10px;cursor:pointer" 
						value="Cancelar Reanálise">
					</cfif>
			</cfif>
			
	
			<cfif #grpacesso# eq 'INSPETORES'>	

			    	<button type="submit" class="btn btn-primary" onClick="document.form1.acao.value='respostacomreanalise';return validarform();" 
				 	style="white-space:normal;width:220px;height:90px;padding:2px;text-align:center;margin-top:10px;cursor:pointer;background-color:blue;color:#fff" >
			        Salvar Resposta para o Gestor <br>e iniciar a Reanálise</button>

					<button type="submit" class="btn btn-danger" onClick="document.form1.acao.value='respSemAlteracao';return validarformSemReavaliar();" 
				 	style="margin-left:40px;white-space:normal;width:220px;height:90px;padding:2px;text-align:center;margin-top:10px;cursor:pointer;background-color:red;color:#fff" >
			        Salvar Resposta para o Gestor <br>sem realizar alterações no item</button>	
			</cfif>

			   <input type="button" class="btn btn-info" style="padding:2px;text-align:center;margin-left:40px;cursor:pointer" value="Fechar" onclick="window.close();"
		


		</div>
	 </form>
 
	</body>
</html>