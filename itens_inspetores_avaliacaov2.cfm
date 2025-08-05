<cfprocessingdirective pageEncoding ="utf-8">	
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>  
 
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_email,Usu_GrupoAcesso,trim(Usu_Matricula) as Usu_Matricula from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(trim(qAcesso.Usu_GrupoAcesso))>
 <cfif (grpacesso neq 'INSPETORES')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	<cfabort>  
</cfif>  
<cfparam name="formgrp" default="0">
<cfparam name="formitm" default="0">
<cfoutput>
<cfparam name="URL.numInspecao" default="0">
<cfif isDefined("form.acao") and form.acao neq ''>
	<!---
		<cfdump var="#form#">
		<cfset gil = gil>
	--->
	<cfset formgrp = #form.grpsel#>
	<cfset formitm = #form.itmsel#>
	<cfset URL.numInspecao = #form.numinspecao#>
	<cfif form.acao eq 'anexar'>
		<cfquery name="rsSeq" datasource="#dsn_inspecao#">
			SELECT Ane_Codigo FROM Anexos
			where Ane_NumInspecao='#form.numinspecao#' and 
			Ane_Unidade='#form.codunidade#' and 
			Ane_NumGrupo=#form.grpsel# and 
			Ane_NumItem=#form.itmsel#
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
		<!--- O arquivo anexo recebe nome indicando Numero da inspeção, Número da unidade, Número do grupo e número do item ao qual está vinculado --->

		<cfset destino = cffile.serverdirectory & '\' & form.numinspecao & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '_' & form.grpsel & '_' & form.itmsel & seq & '.pdf'>

		<cfif FileExists(origem)>

			<cffile action="rename" source="#origem#" destination="#destino#">

			<cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
				SELECT Ane_Codigo FROM Anexos
				WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
			</cfquery>

			<cfif qVerificaAnexo.recordCount eq 0>
				<cfquery datasource="#dsn_inspecao#" name="qVerifica">
					INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho)
					VALUES ('#form.numinspecao#','#form.codunidade#',#form.grpsel#,#form.itmsel#,'#destino#')
				</cfquery>
			</cfif>
		</cfif>		
		<!--- forçar a salvar dos demais campos --->
		<cfset form.acao = 'salvargrpitm'>	
	</cfif>	
	<cfif form.acao eq 'excluiranexo'>
		<!--- Verificar se anexo existe --->
		 <cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos
			WHERE Ane_Codigo = #form.numanexoexcluir#
		 </cfquery>

		 <cfif qAnexos.recordCount Neq 0>
			<!--- Exluindo arquivo do diretório de Anexos --->
			<cfif FileExists(qAnexos.Ane_Caminho)>
				<cffile action="delete" file="#qAnexos.Ane_Caminho#">
			</cfif>

			<!--- Excluindo anexo do banco de dados --->
			<cfquery datasource="#dsn_inspecao#">
			  DELETE FROM Anexos
			  WHERE Ane_Codigo = #form.numanexoexcluir#
			</cfquery>
			<!--- forçar a salvar dos demais campos --->
			<cfset form.acao = 'salvargrpitm'>
		</cfif>
	</cfif>		
	<cfparam name="URL.numInspecao" default="#form.numinspecao#">
	<cfif form.acao eq 'concluiravaliacao'>	
		<!--- Rotina de finalização da avaliação--->
		<!---Insert na tabela ProcessoParecerUnidade --->
		<cfquery datasource="#dsn_inspecao#" name="rsPRPAUN">
			SELECT Pro_Unidade FROM ProcessoParecerUnidade 
			WHERE Pro_Inspecao = '#form.numinspecao#' and Pro_Unidade = '#form.codunidade#'
		</cfquery>	
		<cfif rsPRPAUN.recordcount lte 0>
			<cfquery datasource="#dsn_inspecao#">
				INSERT INTO ProcessoParecerUnidade 
				(Pro_Unidade, Pro_Inspecao, Pro_Situacao, Pro_username, Pro_dtultatu) 
				VALUES 
				('#form.codunidade#', '#form.numinspecao#', 'AB', '#qAcesso.Usu_Matricula#', CONVERT(char, GETDATE(), 120))
			</cfquery> 							
		</cfif>
		<!---Seleciona os itens não conformes da tabela Resultado_Inspecao--->
		<cfquery name="rsInspecaoFinalizarNC" datasource="#dsn_inspecao#">
			SELECT RIP_NumInspecao,RIP_Unidade,RIP_Ano,RIP_NumGrupo,RIP_NumItem,Inp_Modalidade,RIP_NCISEI
			FROM Resultado_Inspecao 
			INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao 
			WHERE RIP_NumInspecao='#form.numinspecao#' and RIP_Resposta='N'
		</cfquery>

		<!--- Se ocorrerem erros em uma das query a seguir, será feitoum rollback dos registros--->
		<cftransaction> 
			<!--- --->
			<!--- exclui os inspetores de Inspetor_Inspecao que estão na lista e somar as horas de pre-inspeção e inspeção da tabela inspetor_inspecao e faz um update na tabela inspecao com a nova soma --->
			<cfif len(#form.qtdlistainspsemaval#) gte 1>
				<cfquery  datasource="#dsn_inspecao#">
				  DELETE FROM Inspetor_Inspecao 
				  WHERE IPT_NumInspecao = '#form.numinspecao#' and 
				  IPT_MatricInspetor in(#form.qtdlistainspsemaval#)
				</cfquery>
			</cfif>	
		
			<cfif rsInspecaoFinalizarNC.recordcount neq 0>		
				<!--- Realizar um loop cadastrando os itens não conformes nas tabelas ParecerUnidade e Andamento --->
                <!--- <cfloop query="rsInspecaoFinal"> --->
				<cfloop query="rsInspecaoFinalizarNC">	
					<!--- Dado default para registro no campo Pos_Area --->
					<!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
					<cfquery name="rsUnid" datasource="#dsn_inspecao#">
						SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#form.codunidade#'
					</cfquery>
					<!--- Dado default para registro no campo Pos_AreaNome --->
					<cfset posarea_cod = #form.codunidade#>
					<cfset posarea_nome = rsUnid.Und_Descricao>
					<!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->
					<cfquery name="rsItem2" datasource="#dsn_inspecao#">
						SELECT Itn_TipoUnidade, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
						FROM Itens_Verificacao 
						WHERE (Itn_Ano = '#rsInspecaoFinalizarNC.RIP_Ano#') and 
						(Itn_NumGrupo = '#rsInspecaoFinalizarNC.RIP_NumGrupo#') AND 
						(Itn_NumItem = '#rsInspecaoFinalizarNC.RIP_NumItem#') and 
						(Itn_TipoUnidade = #rsUnid.Und_TipoUnidade#) and 
						(Itn_Modalidade = '#rsInspecaoFinalizarNC.Inp_Modalidade#')
					</cfquery>
					<!--- Verificar a possibilidade de alterar os dados default para Pos_Area e Pos_AreaNome ---> 
					<cfif (trim(rsUnid.Und_Centraliza) neq "") and (rsItem2.Itn_TipoUnidade eq 4)>
					<!--- AC é Centralizada por CDD? --->
						<cfquery name="rsCDD" datasource="#dsn_inspecao#">
							SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsUnid.Und_Centraliza#'
						</cfquery>
						<cfset posarea_cod = #rsUnid.Und_Centraliza#>
						<cfset posarea_nome = #rsCDD.Und_Descricao#>
					</cfif>
					<!--- inicio classificacao do ponto --->
					<cfset ItnPontuacao = rsItem2.Itn_Pontuacao>
					<cfset ClasItem_Ponto = ucase(trim(rsitem2.Itn_Classificacao))>
					<cfquery name="rsExistePaUn" datasource="#dsn_inspecao#">
						select Pos_Unidade from ParecerUnidade 
						where Pos_Unidade = '#form.codunidade#' and 
						Pos_Inspecao='#form.numInspecao#' and 
						Pos_NumGrupo=#rsInspecaoFinalizarNC.RIP_NumGrupo# and 
						Pos_NumItem = #rsInspecaoFinalizarNC.RIP_NumItem#
					</cfquery>	
					<cfif rsExistePaUn.recordcount lte 0>
						<cfquery datasource="#dsn_inspecao#">
							INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea, Pos_NCISEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto) 
							VALUES ('#form.codunidade#', '#form.numInspecao#', #rsInspecaoFinalizarNC.RIP_NumGrupo#, #rsInspecaoFinalizarNC.RIP_NumItem#,CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 120), '#CGI.REMOTE_USER#', NULL, 0,'#posarea_cod#','#posarea_nome#','#RIP_NCISEI#',#ItnPontuacao#,'#ClasItem_Ponto#')
						</cfquery>
					<cfelse>							
						<cfquery datasource="#dsn_inspecao#">
							update ParecerUnidade set Pos_DtPosic=CONVERT(char, GETDATE(), 102), Pos_NomeResp='#CGI.REMOTE_USER#', Pos_Situacao='RE', Pos_Parecer='', Pos_co_ci='INTRANET', Pos_dtultatu=CONVERT(char, GETDATE(), 120), Pos_username='#CGI.REMOTE_USER#', Pos_aval_dinsp=NULL, Pos_Situacao_Resp=0, Pos_Area='#posarea_cod#', Pos_NomeArea='#posarea_nome#', Pos_NCISEI='#RIP_NCISEI#', Pos_PontuacaoPonto=#ItnPontuacao#, Pos_ClassificacaoPonto='#ClasItem_Ponto#'
							where Pos_Unidade='#form.codunidade#' and Pos_Inspecao='#form.numInspecao#' and Pos_NumGrupo=#rsInspecaoFinalizarNC.RIP_NumGrupo# and Pos_NumItem=#rsInspecaoFinalizarNC.RIP_NumItem#
						</cfquery>					
					</cfif>					
					<!---Fim Insere ParecerUnidade --->
					<!--- Inserindo dados dados na tabela Andamento --->
					<cfset andparecer = "Ação: Concluir Avaliacao (INSPETORES)">
					<cfquery name="rsExisteSN" datasource="#dsn_inspecao#">
						select And_Unidade from Andamento 
						where And_Unidade = '#form.codunidade#' and 
						And_NumInspecao='#form.numInspecao#' and 
						And_NumGrupo=#rsInspecaoFinalizarNC.RIP_NumGrupo# and 
						And_NumItem = #rsInspecaoFinalizarNC.RIP_NumItem# and 
						And_HrPosic = '000000' and 
						And_Situacao_Resp = 0
					</cfquery>
					<cfif rsExisteSN.recordcount lte 0>	
						<cfquery datasource="#dsn_inspecao#">
							insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area, And_NomeArea) 
							values ('#form.numInspecao#', '#form.codunidade#', #rsInspecaoFinalizarNC.RIP_NumGrupo#, #rsInspecaoFinalizarNC.RIP_NumItem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', 0, '000000', '#andparecer#', '#rsInspecaoFinalizarNC.RIP_Unidade#','#posarea_nome#')
						</cfquery>
					<cfelse>
						<cfquery datasource="#dsn_inspecao#">
							update Andamento set And_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
							, And_username='#CGI.REMOTE_USER#'
							, And_Area = '#form.codunidade#'
							, And_NomeArea = '#posarea_nome#'
							, and_Parecer= '#andparecer#'
							where And_Unidade = '#form.codunidade#' and 
							And_NumInspecao='#form.numInspecao#' and 
							And_NumGrupo=#rsInspecaoFinalizarNC.RIP_NumGrupo# and 
							And_NumItem = #rsInspecaoFinalizarNC.RIP_NumItem# and
							And_HrPosic = '000000' and 
							And_Situacao_Resp = 0
						</cfquery>				
					</cfif>	 
					<!---Fim Insere Andamento --->					
					<!---UPDATE em Inspecao--->
					<!---Verifica se existem itens com status NÃO VERIFICADO ou NÃO EXECUTA (com Itn_ValidacaoObrigatoria = 1)--->
					<cfquery datasource="#dsn_inspecao#" name="rsVerifValidados">
						SELECT RIP_Resposta, RIP_Recomendacao,Itn_ValidacaoObrigatoria 
						FROM Resultado_Inspecao 
						INNER JOIN Inspecao on RIP_NumInspecao = INP_NumInspecao and RIP_Unidade = INP_Unidade
						INNER JOIN Itens_Verificacao ON Itn_Ano = convert(char(4),RIP_Ano) AND Itn_NumGrupo = RIP_NumGrupo AND Itn_NumItem = RIP_NumItem and inp_Modalidade = itn_modalidade
						INNER JOIN Unidades ON Und_Codigo = RIP_Unidade and (Itn_TipoUnidade = Und_TipoUnidade)
						WHERE ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria = 1) OR RTRIM(RIP_Resposta)= 'V') AND RTRIM(RIP_Recomendacao) IS NULL 
						AND RIP_NumInspecao='#form.numInspecao#' and RIP_Unidade='#form.codunidade#' 
					</cfquery>											
				</cfloop>
			    <!---Fim do loop--->
			</cfif>

			<cfquery datasource="#dsn_inspecao#" >
				UPDATE Inspecao SET INP_Situacao = 'CO'
				, INP_DtEncerramento =  CONVERT(char, GETDATE(), 102)
				, INP_DtUltAtu =  CONVERT(char, GETDATE(), 120)
				, INP_UserName = '#CGI.REMOTE_USER#'
				, INP_DTConcluirAvaliacao = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
				WHERE INP_Unidade='#form.codunidade#' AND INP_NumInspecao='#form.numinspecao#' 
			</cfquery> 			
			<!---Fim UPDATE em Inspecao --->
		</cftransaction> 
			<cfset form.acao = ''>
			<script>    
				alert('Ação: Concluir e Liberar Avaliação para Revisão, Realizada com sucesso!')
				var url = window.location.href;    
				window.location.href = url;
				//Provocar para surgir memsagem em tela
				<cfset erro = erro>
			</script>
	</cfif>
	<cfif form.acao eq 'revisaosemreanalise'>
		<cflocation url="itens_inspetores_avaliacaov2.cfm">
	</cfif> 
  	<cfif (#form.acao# eq 'salvargrpitm')>
	  	<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao 
			SET
			<cfif form.avalitem neq 'E'>
				<cfset aux_mel = form.melhoria>
				RIP_Comentario='#aux_mel#'
			<cfelse>
				RIP_Comentario='.'			
			</cfif>
	   		<cfif form.avalitem eq 'N'>
				<cfset aux_recom = form.recomendacoes>
		 		, RIP_Recomendacoes='#aux_recom#'
				, RIP_Manchete = '#form.manchete#' 
				<!--- N° SEI da NCI --->
				<cfif form.nci neq ''>
					<cfset aux_sei_nci = Trim(form.frmnumseinci)>
					<cfset aux_sei_nci = Replace(aux_sei_nci,'.','',"All")>
					<cfset aux_sei_nci = Replace(aux_sei_nci,'/','','All')>
					<cfset aux_sei_nci = Replace(aux_sei_nci,'-','','All')>
					, RIP_NCISEI = '#aux_sei_nci#'
				</cfif>
				<!--- potencial valor --->
				<cfset auxfrmfalta = '0.00'>
				<cfset auxfrmsobra = '0.00'>			
				<cfset auxfrmemrisco = '0.00'>
				<cfif form.potencvlr eq 'S'>
					<cfif form.impactarfalta eq 'F'>
						<cfset auxfrmfalta = Replace(form.frmfalta,'.','','All')>
						<cfset auxfrmfalta = Replace(auxfrmfalta,',','.','All')>
					</cfif>	
					<cfif form.impactarsobra eq 'S' and form.cdfrmsobrasn eq 'S'>
						<cfset auxfrmsobra = Replace(form.frmsobra,'.','','All')>
						<cfset auxfrmsobra = Replace(auxfrmsobra,',','.','All')>
					</cfif>				
					<cfif form.impactarrisco eq 'R' and form.cdfrmemriscosn eq 'S'>
						<cfset auxfrmemrisco = Replace(form.frmemrisco,'.','','All')>
						<cfset auxfrmemrisco = Replace(auxfrmemrisco,',','.','All')>
					</cfif>
				</cfif>
				, RIP_Falta=#auxfrmfalta#
				, RIP_Sobra=#auxfrmsobra#
				, RIP_EmRisco=#auxfrmemrisco#	
				<!--- reincidencia --->	
				, RIP_ReincInspecao = '#form.frmreincInsp#'
				, RIP_ReincGrupo = #form.frmreincGrup#
				, RIP_ReincItem = #form.frmreincItem#		
		 	<cfelse>
		 		, RIP_Recomendacoes=''		
				, RIP_Manchete=''	  
				, RIP_NCISEI=''	
				, RIP_Falta='0.0'
				, RIP_Sobra='0.0'
				, RIP_EmRisco='0.0'
				, RIP_ReincInspecao = ''
				, RIP_ReincGrupo = 0
				, RIP_ReincItem = 0	 
			</cfif>
				, RIP_UserName = '#CGI.REMOTE_USER#'	
				, RIP_DtUltAtu = CONVERT(char, GETDATE(), 120)				
				, RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
				, RIP_Data_Avaliador = CONVERT(char, GETDATE(), 120)	
				, RIP_Resposta ='#form.avalitem#'
			<cfif #form.riprecomendacaoInspetor# gt 0>
				, RIP_Matricula_Reanalise = '#qAcesso.Usu_Matricula#'
			</cfif>				
			<cfif grpacesso eq 'GESTORES'>
				, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
				, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
			</cfif>			
			<!---Para a propagação da avalição quando FORM.propagaAval tiversido definido como sim e a avaliação for Nao executa--->
			<cfif IsDefined("form.propagaval") and form.propagaval eq 'S' and form.avalitem eq 'E'>
				WHERE RIP_NumInspecao='#form.numinspecao#' AND RIP_NumGrupo=#form.grpsel# AND RIP_Resposta = 'A'
			<cfelse>
				WHERE RIP_NumInspecao='#form.numinspecao#' AND RIP_NumGrupo=#form.grpsel# AND RIP_NumItem=#form.itmsel#
			</cfif>
	    </cfquery>	

		<!--- Confirmar atuação do inspetor na avaliação --->
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Inspecao SET INP_AvaliacaoAtiva = 'S'
			WHERE INP_NumInspecao='#form.numinspecao#'
		</cfquery>		
		<!--- Exclusão de todos os anexos para avaliação diferente de N - Não Conforme --->
		<cfif form.avalitem neq 'N'>
			<!--- Verificar se anexo existe --->
			<cfquery datasource="#dsn_inspecao#" name="rsAnexos">
				SELECT Ane_Codigo, Ane_Caminho FROM Anexos
				WHERE Ane_NumInspecao = '#form.numinspecao#' and
				Ane_NumGrupo=#form.grpsel# and 
				Ane_NumItem=#form.itmsel#
			</cfquery>
		 	<cfif rsAnexos.recordCount gt 0>
				<!--- Exluindo arquivo do diretório de Anexos --->
				<cfif FileExists(rsAnexos.Ane_Caminho)>
					<cffile action="delete" file="#rsAnexos.Ane_Caminho#">
				</cfif>
			</cfif>				
			<!--- Excluindo anexo do banco de dados --->
			<cfquery datasource="#dsn_inspecao#">
			  DELETE FROM Anexos
			  WHERE  Ane_Unidade='#form.codunidade#' and 
			  Ane_NumInspecao='#form.numinspecao#' AND 
			  Ane_NumGrupo=#form.grpsel# AND 
			  Ane_NumItem=#form.itmsel#
			</cfquery>	
			<cfquery datasource="#dsn_inspecao#">
				delete from Andamento 
				where And_NumInspecao='#form.numinspecao#' and 
				And_NumGrupo=#form.grpsel# and 
				And_NumItem=#form.itmsel#
			</cfquery>
			<cfquery datasource="#dsn_inspecao#">
				delete from ParecerUnidade 
				where Pos_Inspecao='#form.numinspecao#' and 
				Pos_NumGrupo=#form.grpsel# and 
				Pos_NumItem=#form.itmsel#
			</cfquery>	
		</cfif>	
	</cfif> 
	<!---		
	<cfset gil = gil>	
	--->
	<cflocation url="itens_inspetores_avaliacaov2.cfm?numInspecao=#form.numinspecao#&Unid=#form.codunidade#&formgrp=#form.grpsel#&formitm=#form.itmsel#">		
	<!--- ======================== --->		
</cfif> 
</cfoutput>
<cfquery name="rsItemEmRevisao" datasource="#dsn_inspecao#">
	SELECT RIP_Resposta,RIP_Recomendacao FROM Resultado_Inspecao 
	INNER JOIN Inspetor_Inspecao ON RIP_Unidade =IPT_CodUnidade AND RIP_NumInspecao =IPT_NumInspecao
	WHERE RIP_Recomendacao='S' AND RIP_NumInspecao='#url.numInspecao#'
</cfquery>

<cfquery name="qInspetor" datasource="#dsn_inspecao#">
	SELECT IPT_MatricInspetor, Fun_Nome
	FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor =
	Fun_Matric WHERE IPT_NumInspecao = '#URL.numInspecao#'
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsResult">
	SELECT 
	    NIP_DtIniPrev, 
		RIP_Unidade,
		RIP_NumGrupo,
		RIP_NumItem,
		RIP_NumInspecao,
		RIP_CodReop,
		RIP_CodDiretoria,
		RIP_Resposta,
		RIP_Recomendacao,
		RIP_Manchete,
		RIP_COMENTARIO,
		RIP_Recomendacoes,
		RIP_NumGrupo,
		RIP_MatricAvaliador,
		RIP_NCISEI,
		RIP_Recomendacao_Inspetor,
		RIP_NumItem, 
		RIP_Falta,
		RIP_ReincInspecao,
		RIP_ReincGrupo,
		RIP_ReincItem,
		Und_Descricao,
		Und_TipoUnidade,
		TUI_Classificacao,
		TUI_Pontuacao,
		Itn_Descricao, 
		Itn_Pontuacao,
		Itn_Classificacao,
		Itn_Reincidentes,
		Itn_Ano, 
		Itn_PTC_Seq,
		Itn_ImpactarTipos,
		Grp_Ano,
		Grp_Descricao, 
		INP_Modalidade,
		INP_DTConcluirAvaliacao,
		INP_Situacao,
		INP_Responsavel,
		INP_Coordenador,
		INP_HrsPreInspecao,
		INP_DtInicDeslocamento,
		INP_DtFimDeslocamento,
		INP_HrsDeslocamento,
		INP_DtInicInspecao,
		INP_DtFimInspecao, 
		INP_HrsInspecao,
		trim(Fun_Nome) as funome,
		DENSE_RANK() OVER (ORDER BY TUI_Pontuacao DESC) AS RankByPontuacao
	FROM ((((Numera_Inspecao 
	INNER JOIN Inspecao ON (NIP_NumInspecao = INP_NumInspecao) AND (NIP_Unidade = INP_Unidade)) 
	INNER JOIN Unidades ON NIP_Unidade = Und_Codigo) INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
	INNER JOIN Inspetor_Inspecao ON (RIP_NumInspecao = IPT_NumInspecao) AND (RIP_Unidade = IPT_CodUnidade)) 
	INNER JOIN (Itens_Verificacao 
	INNER JOIN TipoUnidade_ItemVerificacao ON (Itn_NumItem = TUI_ItemVerif) AND (Itn_NumGrupo = TUI_GrupoItem) AND (Itn_Ano = TUI_Ano) AND (Itn_TipoUnidade = TUI_TipoUnid) AND (Itn_Modalidade = TUI_Modalidade)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade) AND (convert(char(4),RIP_Ano) = Itn_Ano) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo)
	INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)
	left JOIN Funcionarios on RIP_MatricAvaliador=Fun_Matric
    WHERE RIP_NumInspecao='#url.numInspecao#' 
			AND Itn_Ano=RIGHT('#url.numInspecao#',4) 
        <cfif '#grpacesso#' eq "INSPETORES">
			AND IPT_MatricInspetor ='#qAcesso.Usu_Matricula#'
        </cfif>
		<cfif grpacesso eq "GESTORES" or grpacesso eq "DESENVOLVEDORES">
			AND IPT_MatricInspetor = INP_Coordenador
        </cfif>
		<cfif rsItemEmRevisao.recordcount neq 0>
		    AND  RIP_Recomendacao='S'
		</cfif>		
		 ORDER BY RankByPontuacao, Itn_NumGrupo, Itn_NumItem
</cfquery>

<cfparam name="form.melhoria" default="#rsResult.RIP_COMENTARIO#">
<cfparam name="form.manchete" default="#rsResult.RIP_Manchete#">
<cfparam name="form.recomendacoes" default="#rsResult.RIP_Recomendacoes#">

<!---
<cfif isDefined("url.numInspecao") And (#url.numInspecao# neq '')>

<cfelse>

</cfif>
--->
<!--- Área de conteúdo   --->
	<cfif '#grpacesso#' eq "INSPETORES">   
		<!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliada--->		
		<cfquery datasource="#dsn_inspecao#" name="rsInspecoes">
			SELECT * 
			FROM (Numera_Inspecao 
			INNER JOIN Inspecao ON (NIP_Unidade = INP_Unidade) AND (NIP_NumInspecao = INP_NumInspecao) 
			INNER JOIN Inspetor_Inspecao ON (INP_Unidade = IPT_CodUnidade) AND (INP_NumInspecao = IPT_NumInspecao))
			WHERE INP_Situacao in ('NA','ER') and NIP_Situacao = 'A' and IPT_MatricInspetor ='#qAcesso.Usu_Matricula#' 
			ORDER BY INP_DtInicInspecao
		</cfquery>
	</cfif> 
	<cfif '#grpacesso#' eq "GESTORES" OR '#grpacesso#' eq "DESENVOLVEDORES">  
		<!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliada--->  
		<cfquery datasource="#dsn_inspecao#" name="rsInspecoes">
			SELECT *  
			FROM Numera_Inspecao 
			INNER JOIN Inspecao ON (NIP_Unidade = INP_Unidade) AND (NIP_NumInspecao = INP_NumInspecao)
			INNER JOIN Inspetor_Inspecao ON (INP_Unidade = IPT_CodUnidade) AND (INP_NumInspecao = IPT_NumInspecao)
			WHERE INP_Situacao in ('NA','ER') and NIP_Situacao = 'A' and left(INP_NumInspecao,2) in(#se#)
			ORDER BY INP_NumInspecao,INP_AvaliacaoAtiva,INP_DtInicInspecao
		</cfquery>
	</cfif>

	<cfif isDefined("url.numInspecao") And (#url.numInspecao# neq '')>
		<cfquery name="rsConcluiraval" dbtype = "query">
			SELECT RIP_Resposta,RIP_Recomendacao,INP_DTConcluirAvaliacao
			from rsResult
			where RIP_NumInspecao = '#url.numInspecao#' and 
			RIP_Resposta = 'A' or RIP_Recomendacao in('S','R') or INP_DTConcluirAvaliacao is not null
		</cfquery>
		<!--- <br>rsConcluiraval: <cfoutput>#rsConcluiraval.INP_DTConcluirAvaliacao#</cfoutput>			 --->
		<cfset concluiravalasn = 'N'>
		<cfquery name="rsRIPResposta" dbtype = "query">
			SELECT RIP_Resposta
			from rsConcluiraval
			where RIP_Resposta = 'A'
		</cfquery>
		<cfquery name="rsRecomendacao" dbtype = "query">
			SELECT RIP_Recomendacao
			from rsConcluiraval
			where RIP_Recomendacao in('S','R')
		</cfquery>
		<cfquery name="rsINPDTConcluirAvaliacao" dbtype = "query">
			SELECT INP_DTConcluirAvaliacao
			from rsConcluiraval
			where INP_DTConcluirAvaliacao is not null
		</cfquery>	
		<!---		
			<cfoutput>
				#rsRIPResposta.recordcount# and #rsRecomendacao.recordcount# and #rsINPDTConcluirAvaliacao.recordcount#
			</cfoutput>
		--->
		<cfif rsRIPResposta.recordcount eq 0 and rsRecomendacao.recordcount eq 0 and rsINPDTConcluirAvaliacao.recordcount eq 0>
			<cfset concluiravalasn = 'S'>
		</cfif>
		<cfquery name="rsNA" dbtype = "query">
			SELECT RIP_Resposta,RIP_MatricAvaliador,RIP_NumGrupo,RIP_NumItem,Grp_Descricao,Itn_Descricao,funome,Und_Descricao,Itn_Pontuacao,Itn_Classificacao,Itn_PTC_Seq,Itn_ImpactarTipos,RIP_NCISEI,RIP_Recomendacao,Itn_Reincidentes
			from rsResult
			where RIP_Resposta = 'A'
			order by RIP_NumGrupo,RIP_NumItem
		</cfquery>
		<cfquery name="rsC" dbtype = "query">
			SELECT RIP_Resposta,RIP_MatricAvaliador,RIP_NumGrupo,RIP_NumItem,Grp_Descricao,Itn_Descricao,funome,Und_Descricao,Itn_Pontuacao,Itn_Classificacao,Itn_PTC_Seq,Itn_ImpactarTipos,RIP_NCISEI,RIP_Recomendacao,Itn_Reincidentes
			from rsResult
			where RIP_Resposta = 'C'
			order by RIP_NumGrupo,RIP_NumItem
		</cfquery>
		<cfquery name="rsNV" dbtype = "query">
			SELECT RIP_Resposta,RIP_MatricAvaliador,RIP_NumGrupo,RIP_NumItem,Grp_Descricao,Itn_Descricao,funome,Und_Descricao,Itn_Pontuacao,Itn_Classificacao,Itn_PTC_Seq,Itn_ImpactarTipos,RIP_NCISEI,RIP_Recomendacao,Itn_Reincidentes
			from rsResult
			where RIP_Resposta = 'V'
			order by RIP_NumGrupo,RIP_NumItem
		</cfquery>
		<cfquery name="rsNE" dbtype = "query">
			SELECT RIP_Resposta,RIP_MatricAvaliador,RIP_NumGrupo,RIP_NumItem,Grp_Descricao,Itn_Descricao,funome,Und_Descricao,Itn_Pontuacao,Itn_Classificacao,Itn_PTC_Seq,Itn_ImpactarTipos,RIP_NCISEI,RIP_Recomendacao,Itn_Reincidentes
			from rsResult
			where RIP_Resposta = 'E'
			order by RIP_NumGrupo,RIP_NumItem
		</cfquery>
		<cfquery name="rsNC" dbtype = "query">
			SELECT RIP_Resposta,RIP_MatricAvaliador,RIP_NumGrupo,RIP_NumItem,Grp_Descricao,Itn_Descricao,funome,Und_Descricao,Itn_Pontuacao,Itn_Classificacao,Itn_PTC_Seq,Itn_ImpactarTipos,RIP_NCISEI,RIP_Recomendacao,Itn_Reincidentes
			from rsResult
			where RIP_Resposta = 'N'
			order by RIP_NumGrupo,RIP_NumItem
		</cfquery>
		<cfquery datasource="#dsn_inspecao#" name="rslistaInspSemAvaliacao">
			SELECT IPT_MatricInspetor FROM Inspetor_Inspecao 
			LEFT JOIN Resultado_Inspecao ON (IPT_NumInspecao = RIP_NumInspecao) AND (IPT_MatricInspetor = RIP_MatricAvaliador)
			where RIP_MatricAvaliador Is Null AND IPT_NumInspecao=convert(varchar,'#url.numInspecao#')
		</cfquery>		
	</cfif>

<!doctype html>
<html lang="pt-br">
<head>
<meta charset="utf-8">
<title>SISTEMA NACIONAL DE CONTROLE INTERNO - SNCI</title>
<meta name="description" content="Teste ">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script type="text/javascript" src="ckeditor/ckeditor.js"></script>
<link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
<style>
html, body, div, span, h1, h2, h3, h4, h5, h6, p, blockquote, 
a, ul, li, article, aside, footer, header, nav, section {
	margin: 0;
	padding: 0;
	border: 0;
	font-size: 100%;
	font: inherit;
	vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, footer, header, nav, section {
	display: block;
}
ul {
	list-style: none;
}
/* Fim Eric Meyer reset */
/* utilidades */
*, *:before, *:after {
  -moz-box-sizing: border-box; 
  -webkit-box-sizing: border-box;
   box-sizing: border-box;
}
.cf:before,
.cf:after {
    content: " "; 
    display: table;
}
.cf:after {
    clear: both;
}
.cf {
    *zoom: 1;
}
/* Fim utilidades */
body {
	font: 100%/1.4 sans-serif;
}

h1, h2 {
	font-weight: bold;
}
h1 { font-size: 140%; }
h2 { font-size: 100%; }
p { margin: 0.6em 0; }
p:last-child { 
	margin-bottom:0; 
	padding-bottom: 0.6em
}
.topo { 
	background: #070ab2;
	color: #fff; 
	font-size: 70%;
	line-height: 2.5em;
	text-align: center;
	white-space: nowrap;
	overflow: hidden;
}
.principal { background: rgb(255, 255, 0);}
.principal header, .auxiliar h1 { text-align: center; color: #14169c;}
.bloco, .auxiliar article {
	border-bottom: 1px solid #171996;
	padding: 0.8em 0;
	}
.bloco h2 {
	font-weight: bold;
	font-size: 140%;
}
.bloco h3 {
	font-weight: bold;
	font-size: 130%;
}
h5 {
	font-weight: bold;
	font-size: 80%;
}
h6 {
	color: #034c6d; 
	font-weight: bold;
	font-size: 70%;
}
.auxiliar { background: #fff; }
.auxiliar p { margin-top: 0; }

.rodape { 
	background: #1417d6;
	color: #fff;
	text-align: center;
	}
a, a:active {
	text-decoration: none;
	color: blue;
}
a:hover {
	text-decoration: underline;
	color: #333;
}
/* navegação mobile */
.navegacao ul {
	margin:  0;
	padding: 0;
}
.navegacao li {
	list-style: none;
	font-size: 110%; 
	border-bottom: 1px solid #fff; 
}
.menu-icon {
	padding-top: .5em;
	font-size: 120%; 
	color: #fff; 
}
.navegacao a {
	display: block;
	padding: 0.25em 1em 0.25em 1em;
	text-decoration: none;
}
.navegacao li a {
	color: #fff;
}
.navegacao li a:hover, .navegacao li a:focus, .navegacao li a:active {
	color: #3e4095;
}
.navegacao {
	font: bold 90%/1.4 sans-serif; 
	background: #00a85a0b;
	height: 2.8em; 
/*	overflow: hidden;
		webkit-transition: height 2s;
		-moz-transition: height 2s; 
		-o-transition: height 2s; 
		-ms-transition: height 2s; 
		transition: height 2s;
		*/
}
.navegacao:hover, .navegacao:focus, .navegacao:active {
	/*
	height: 60em; 
		-webkit-transition: height 2s; 
		-moz-transition: height 2s; 
		-o-transition: height 2s; 
		-ms-transition: height 2s; 
		transition: height 2s;
	*/
}
/* Fim navegação mobile */
@media all and (min-width:30em) {
	body {	
		background-image: url(imagens/bg1000x80cap3.jpg);
		background-repeat: no-repeat;
		background-position: left top;
	}
	.topo { background: transparent; }
	.topo h1 { 
		color: #00a859; 
		font-size: 250%;
		margin: 0.6em 0;
		text-shadow: 3px 3px 2px #666;
	}
	.main-page { background: #00a859; }
	.principal {
		width: 75%;
		padding: 0.5em;
		float: right;
	}
	.auxiliar {
		width: 60%;
		float: right;
	}
	.navegacao {
		float:left;
		width: 30%;
		height: 46em;
	}
	.navegacao li:first-child { border-top: 1px solid #fff; }
	.menu-icon {
		text-indent: -1000em; 
		height: 0;	
		line-hight: 0;
	}
}
@media all and (min-width:62.5em) {
	body {	
		background-image: url(imagens/bg1200x1200cap3.jpg);
		background-size: cover;
	}
	.topo h1 { 
		font-size: 480%;
		margin: 0.8em 0;
	}
	.main-page {background: none;}
	.principal {
		width: 58%;
		float: left;
		background: transparent;
	}
	.principal header {
		background: #1114bc;
		color:#fff;
		margin-bottom: 0.3em;
	}		
	.bloco {
		padding: 0 .5em;
		background: rgba(255, 255, 0, 0.046);
	}
	.auxiliar {
		width: 20%;
		padding: 0 0.4em;
	}
	.navegacao {
		width: 21%;
	}
}

.box{
	margin-top: 0.3em;
	padding: 0.1em 0.1em;
	display: inline-block;
	/*definimos a largura do box*/
	width:90px;
	/* definimos a altura do box */
	height:37px;
	/* definimos a cor de fundo do box */
	background-color:#6494ed12;
	/* definimos o quão arredondado irá ficar nosso box */
	border-radius: 10px 20px;
	cursor: pointer;
	}

.btnsalvar{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:330px;
	height:25px;
	background-color:#0c5adf;
	border-radius: 10px 20px;
	cursor: pointer;
	}
.btnenviocomreanalise{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:330px;
	height:25px;
	background-color:#0c5adf;
	border-radius: 10px 20px;
	cursor: pointer;
	}

.btnconcluiraval{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:330px;
	height:25px;
	background-color:#f02f0c;
	border-radius: 10px 20px;
	cursor: pointer;
	}		
	
.btnenviosemreanalise{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:330px;
	height:25px;
	background-color: #a0750f8e;
	border-radius: 10px 20px;
	cursor: pointer;
	}		
.btnsalvarreinc{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:170px;
	height:25px;
	background-color:#b47f03;
	border-radius: 10px 20px;
	cursor: pointer;
	}		
.btnsim{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:70px;
	height:25px;
	background-color:#068733ea;
	border-radius: 10px 20px;
	cursor: pointer;
	}

.btnnao{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:70px;
	height:25px;
	background-color:#f21826b7;
	border-radius: 10px 20px;
	cursor: pointer;
	}
.btndisabled {
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:70px;
	height:25px;
	background-color:lightgray;
	border-radius: 10px 20px;
	cursor: pointer;
}
	
.btnfecharreanalise{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:170px;
	height:25px;
	background-color:#e30505f1;
	border-radius: 10px 20px;
	cursor: pointer;
	}			
.btnfechar{
	margin-top: 0.3em;
	padding: 0.2em;
	color: #fff;
	display: inline-block;
	width:170px;
	height:25px;
	background-color:#e30505f1;
	border-radius: 10px 20px;
	cursor: pointer;
	}	
.botaobuscar{
	margin-top: 0.3em;
	padding: 0.2em;
	display: inline-block;
	/*definimos a largura do box*/
	width:170px;
	/* definimos a altura do box */
	height:25px;
	/* definimos a cor de fundo do box */
	background-color:#babac772;
	/* definimos o quão arredondado irá ficar nosso box */
	border-radius: 10px 20px;
	cursor: pointer;
	}	
.botaorevereinc{
	margin-top: 0.3em;
	padding: 0.2em;
	display: inline-block;
	/*definimos a largura do box*/
	width:170px;
	/* definimos a altura do box */
	height:25px;
	/* definimos a cor de fundo do box */
	background-color: #f9b4128e;
	/* definimos o quão arredondado irá ficar nosso box */
	border-radius: 10px 20px;
	cursor: pointer;
	}	
.botaomostrareinc{
	margin-top: 0.3em;
	padding: 0.2em;
	display: inline-block;
	/*definimos a largura do box*/
	width:170px;
	/* definimos a altura do box */
	height:25px;
	/* definimos a cor de fundo do box */
	background-color: #f9b4128e;
	/* definimos o quão arredondado irá ficar nosso box */
	border-radius: 10px 20px;
	cursor: pointer;
	}	

.C {
	background-color:#23c541;
}	
.N {
	background-color:#f8485ae6; 
}

.V {
	background-color:#70b4f3;
}
.E {
	background-color:#518ef8;
}
.A {
	background-color:#4e505548;
}

#blocotmp {
	padding: 0.25em 1em 0.25em 1em;
	background-color:#F0F8FF;
	border: 1px solid #666;
	border-radius: 10px 20px;
	box-shadow: 5px 5px 3px lightblue;
}
#blocotmpantes, blocoreincidentes {
	padding: 0.25em 1em 0.25em 1em;
	background-color:#6d6e8472;
	border: 1px solid #666;
	border-radius: 10px 20px;
	box-shadow: 5px 5px 3px lightblue;
}

.selecionar {
	background-color:#8adbe748;
}
table {

	border-radius: 5px;
	border: 1px solid black;

}
td, th, label {

	height: 30px;
	border: 1px solid #666;
	border-radius: 15px;

}

.lblbtn {
	padding: 0.25em 1em 0.25em 1em;
	background-color: #e6a50d;
	height: 20px;
	border: 1px solid #666;
	border-radius: 5px;
	font: bold 75%/1.4 sans-serif; 
	vertical-align: middle;
  	text-align: center;
}
label {
	padding: 0.25em 1em 0.25em 1em;
	background-color:#DCDCDC;
	height: 20px;
	border: 1px solid #666;
	border-radius: 10px;
	font: bold 75%/1.4 sans-serif; 
	vertical-align: middle;
  	text-align: center;
}
 .tableanexo {
  width: 100%;
  border-collapse: collapse;
  }
</style>
</head>
<body id="home">
<div class="tudo">
	<header class="topo">	
    	<cfinclude template="cabecalho.cfm">
	</header>
	<nav class="navegacao" aria-haspopup="true">
		<cfif rsNC.recordcount gt 0><div>&nbsp;</div><div><label>Não Conforme (<cfoutput>#rsNC.recordcount#</cfoutput>)</label></div></cfif>
		<cfoutput query="rsNC">
			<cfset potencvlr = 'N'>
			<cfif listfind('#Itn_PTC_Seq#','10')>
                <cfset potencvlr = 'S'>
            </cfif>	 
			<div class="box #RIP_Resposta#" align="center" title="Não Conforme" grp="#RIP_NumGrupo#" grpdesc="#Grp_Descricao#" itm="#RIP_NumItem#" itmdesc="#Itn_Descricao#" matrinsp="#RIP_MatricAvaliador#" nomeinsp="#funome#" pontuacao="#Itn_Pontuacao#" classificacao="#Itn_Classificacao#" resposta="#RIP_Resposta#" potencvlr="#potencvlr#" ripncisei = "#trim(RIP_NCISEI)#" riprecomendacao	= "#ucase(trim(RIP_Recomendacao))#" intimpactartipos="#ucase(trim(Itn_ImpactarTipos))#" Itnreincidentes="#ucase(trim(Itn_Reincidentes))#">
				<h5>#RIP_NumGrupo#.#RIP_NumItem#<h5>#RIP_MatricAvaliador#</h5>
			</div>
		</cfoutput>	
		<cfif rsC.recordcount gt 0><div>&nbsp;</div><div><label>Conforme (<cfoutput>#rsC.recordcount#</cfoutput>)</label></div></cfif>
		<cfoutput query="rsC">
			<cfset potencvlr = 'N'>
			<cfif listfind('#Itn_PTC_Seq#','10')>
                <cfset potencvlr = 'S'>
            </cfif>	 
			<div class="box #RIP_Resposta#" align="center" title="Conforme" grp="#RIP_NumGrupo#" grpdesc="#Grp_Descricao#" itm="#RIP_NumItem#" itmdesc="#Itn_Descricao#" matrinsp="#RIP_MatricAvaliador#" nomeinsp="#funome#" pontuacao="#Itn_Pontuacao#" classificacao="#Itn_Classificacao#" resposta="#RIP_Resposta#" potencvlr="#potencvlr#" ripncisei = "#trim(RIP_NCISEI)#" riprecomendacao	= "#ucase(trim(RIP_Recomendacao))#" intimpactartipos="#ucase(trim(Itn_ImpactarTipos))#" Itnreincidentes="#ucase(trim(Itn_Reincidentes))#">
				<h5>#RIP_NumGrupo#.#RIP_NumItem#<h5>#RIP_MatricAvaliador#</h5>
			</div>
		</cfoutput>
		<cfif rsNV.recordcount gt 0><div>&nbsp;</div><div><label>Não Verificado (<cfoutput>#rsNV.recordcount#</cfoutput>)</label></div></cfif>
		<cfoutput query="rsNV">
			<cfset potencvlr = 'N'>
			<cfif listfind('#Itn_PTC_Seq#','10')>
                <cfset potencvlr = 'S'>
            </cfif>				
			<div class="box #RIP_Resposta#" align="center" title="Não Verificado" grp="#RIP_NumGrupo#" grpdesc="#Grp_Descricao#" itm="#RIP_NumItem#" itmdesc="#Itn_Descricao#" matrinsp="#RIP_MatricAvaliador#" nomeinsp="#funome#" pontuacao="#Itn_Pontuacao#" classificacao="#Itn_Classificacao#" resposta="#RIP_Resposta#" potencvlr="#potencvlr#" ripncisei = "#trim(RIP_NCISEI)#" riprecomendacao = "#ucase(trim(RIP_Recomendacao))#" intimpactartipos="#ucase(trim(Itn_ImpactarTipos))#" Itnreincidentes="#ucase(trim(Itn_Reincidentes))#">
				<h5>#RIP_NumGrupo#.#RIP_NumItem#<h5>#RIP_MatricAvaliador#</h5>
			</div>
		</cfoutput>
		<cfif rsNE.recordcount gt 0><div>&nbsp;</div><div><label>Não Executa (<cfoutput>#rsNE.recordcount#</cfoutput>)</label></div></cfif>
		<cfoutput query="rsNE">
			<div class="box #RIP_Resposta#" align="center" title="Não Executa" grp="#RIP_NumGrupo#" grpdesc="#Grp_Descricao#" itm="#RIP_NumItem#" itmdesc="#Itn_Descricao#" matrinsp="#RIP_MatricAvaliador#" nomeinsp="#funome#" pontuacao="#Itn_Pontuacao#" classificacao="#Itn_Classificacao#" resposta="#RIP_Resposta#" potencvlr="#potencvlr#" ripncisei = "#trim(RIP_NCISEI)#" riprecomendacao = "#ucase(trim(RIP_Recomendacao))#" intimpactartipos="#ucase(trim(Itn_ImpactarTipos))#" Itnreincidentes="#ucase(trim(Itn_Reincidentes))#">
				<h5>#RIP_NumGrupo#.#RIP_NumItem#<h5>#RIP_MatricAvaliador#</h5>
			</div>
		</cfoutput>
		<cfif rsNA.recordcount gt 0><div>&nbsp;</div><div><label>Não Avaliado (<cfoutput>#rsNA.recordcount#</cfoutput>)</label></div></cfif>
		<cfoutput query="rsNA">
			<cfset potencvlr = 'N'>
			<cfif listfind('#Itn_PTC_Seq#','10')>
                <cfset potencvlr = 'S'>
            </cfif>				
			<div class="box #RIP_Resposta#" align="center" title="Não Avaliado" grp="#RIP_NumGrupo#" grpdesc="#Grp_Descricao#" itm="#RIP_NumItem#" itmdesc="#Itn_Descricao#" matrinsp="" nomeinsp="" pontuacao="#Itn_Pontuacao#" classificacao="#Itn_Classificacao#" resposta="#RIP_Resposta#" potencvlr="#potencvlr#" ripncisei = "#trim(RIP_NCISEI)#" riprecomendacao	= "#ucase(trim(RIP_Recomendacao))#" intimpactartipos="#ucase(trim(Itn_ImpactarTipos))#" Itnreincidentes="#ucase(trim(Itn_Reincidentes))#">
				<h5>#RIP_NumGrupo#.#RIP_NumItem#<h5>#RIP_MatricAvaliador#</h5>
			</div>
		</cfoutput>
	</nav>
	<main class="main-page cf">
	<section class="principal">
		<form name="formx" id="formx" action="itens_inspetores_avaliacaov2.cfm" method="post" enctype="multipart/form-data">
			<header>
				<hgroup>  
					<div align="center" class="card-title"><h2>AVALIAÇÃO DOS ITENS DE CONTROLE INTERNO</h2></div>	
				</hgroup>    	
			</header>
			<div class="bloco selecionar" align="center">
				<div align="left">
					<label><h4>SELECIONAR AVALIAÇÃO:</h4></label> 
					<select name="selInspecoes" id="selInspecoes" class="form-control-sm">
						<option selected="selected" value="">---</option>
						<cfoutput query="rsInspecoes">
							<cfquery datasource="#dsn_inspecao#" name="rsInspecao">
								SELECT * FROM Inspecao 
								WHERE (INP_Situacao = 'NA' or INP_Situacao = 'ER')  and INP_NumInspecao='#rsInspecoes.INP_NumInspecao#'  
							</cfquery>
							<cfquery datasource="#dsn_inspecao#" name="rsCoordenador" >
								select Usu_Matricula, Usu_Apelido from usuarios where Usu_Matricula = Convert(varchar,#rsInspecao.INP_Coordenador#)
							</cfquery>
							<cfquery datasource="#dsn_inspecao#" name="rsUnidades">
								SELECT Und_Codigo, Und_Descricao, Und_NomeGerente FROM Unidades WHERE Und_Status='A' and Und_Codigo = '#rsInspecao.INP_Unidade#'
							</cfquery>
							<cfquery name="rsVerifComItemEmRevisao" datasource="#dsn_inspecao#">
								SELECT RIP_Resposta FROM Resultado_Inspecao 
								WHERE RIP_Recomendacao='S' AND RIP_NumInspecao='#rsInspecao.INP_NumInspecao#'
							</cfquery>															
							<!--- <cfparam name="coordenador" default="#rsCoordenador.Usu_Matricula#"> --->
							<cfset coordenador = #rsCoordenador.Usu_Matricula#>
							<cfset avalinicsn = 'Não'>
							<cfif INP_AvaliacaoAtiva eq 'S'>
								<cfset avalinicsn = 'Sim'>
							</cfif>	
						<!---	  <option value="itens_inspetores_avaliacaov2.cfm?numInspecao=#INP_NumInspecao#&Unid=#rsUnidades.Und_Codigo#" style="<cfif rsVerifComItemEmRevisao.recordcount neq 0 >color:red</cfif>">#rsInspecao.INP_NumInspecao# - #trim(rsUnidades.Und_Descricao)# (#rsUnidades.Und_Codigo#)-(Coordena:#coordenador#)-(Aval. Iniciada? #avalinicsn#)<cfif rsVerifComItemEmRevisao.recordcount neq 0 > - Reanálise: #rsVerifComItemEmRevisao.recordcount#<cfif #rsVerifComItemEmRevisao.recordcount# gt 1>itens<cfelse>item</cfif></cfif></option> --->
						  <option value="itens_inspetores_avaliacaov2.cfm?numInspecao=#INP_NumInspecao#&Unid=#rsUnidades.Und_Codigo#" style="<cfif rsVerifComItemEmRevisao.recordcount neq 0 >color:red</cfif>" <cfif rsInspecao.INP_NumInspecao eq url.numInspecao>selected</cfif>>#rsInspecao.INP_NumInspecao# - #trim(rsUnidades.Und_Descricao)# (#rsUnidades.Und_Codigo#)-(Coordena:#coordenador#)-(Aval. Iniciada? #avalinicsn#)<cfif rsVerifComItemEmRevisao.recordcount neq 0 > - Reanálise: #rsVerifComItemEmRevisao.recordcount#<cfif #rsVerifComItemEmRevisao.recordcount# gt 1> itens<cfelse> item</cfif></cfif></option>
						</cfoutput>		
					</select>	
				</div>	
				<br>			
			</div>
			<div id='divconcluiraval' align="center">
				<br>
				<div><img  alt="Liberar" src="figuras/liberada.png" width="80" border="0"></div>
				<div class="btnconcluiraval" align="center" title="concluir e liberar avaliação para revisão"><h5>Concluir e Liberar Avaliação para Revisão</h5></div>  
			</div>	
			<div id="reanalisegeral">
				<div id="reanalise">
					<div id="numavalreanalz"></div>
					<div id="itemavalreanalz"></div>
					<div id="statusavalreanalz"></div>
					<div align="center"><label>Revisor(a) - Histórico das Recomendações</label></div>	
					<div><textarea name="historirecominspetor" id="historirecominspetor" cols="172" rows="10" wrap="VIRTUAL" readonly style="background:transparent;font-size:12px"></textarea></div>	
					<div align="center"><label>Inspetor(a) - Histórico das Respostas</label></div>		
					<div><textarea name="historirespinspetor" id="historirespinspetor" cols="172" rows="10" wrap="VIRTUAL" readonly style="background:transparent;font-size:12px"></textarea></div>	
					<div align="center"><label>Inspetor(a) - Responder para Revisor(a)</label></div>	
					<div><textarea name="respondereanalise" id="respondereanalise" cols="172" rows="10" wrap="VIRTUAL" style="background:transparent;font-size:12px"></textarea></div>		
					<div><hr></div>		
					<br>
				</div>	
				<div align="center">
					<div class="btnfecharreanalise" align="center">
							<h5>Fechar</h5>
					</div>
					<div class="btnenviocomreanalise" align="center">
							<h5>Enviar resposta para o Revisor(a) com Reanálise</h5>
					</div>
					<div class="btnenviosemreanalise" align="center">
							<h5>Enviar resposta para o Revisor(a) sem Reanálise</h5>
					</div>
				</div>	
			</div>				
			<div id="reincidenciasgeral">
				<div id="reincidencias01">
					<div id="numavalreinc01"></div>
					<div id="itemavalreinc01"></div>
					<div id="statusavalreinc01"></div>
					<div id="melhoriavalreinc01"><textarea name="melhoriareinc01" id="melhoriareinc01" cols="130" rows="15" wrap="VIRTUAL"></textarea></div>	
					<div><hr></div>	
					<div id="informe01reinc01" align="center"></div>	
					<div id="informe02reinc01" align="center"></div>
					<div><hr></div>	
					<div align="center">
						<div class="btnsim btnsn" align="center" id="sim01" selecaosn="N">
								<h5>Sim</h5>
						</div>
						<div class="btnnao btnsn" align="center" id="nao01" selecaosn="N">
								<h5>Não</h5>
						</div>
					</div>			
					<div><hr></div>		
					<br>
				</div>	
				<div id="reincidencias02">
					<div id="numavalreinc02"></div>
					<div id="itemavalreinc02"></div>
					<div id="statusavalreinc02"></div>
					<div id="melhoriavalreinc02"><textarea name="melhoriareinc02" id="melhoriareinc02" cols="130" rows="15" wrap="VIRTUAL"></textarea></div>	
					<div><hr></div>	
					<div id="informe01reinc02" align="center"></div>	
					<div id="informe02reinc02" align="center"></div>
					<div><hr></div>	
					<div align="center">
						<div class="btnsim btnsn" align="center" id="sim02" selecaosn="N">
								<h5>Sim</h5>
						</div>
						<div class="btnnao btnsn" align="center" id="nao02" selecaosn="N">
								<h5>Não</h5>
						</div>
					</div>
				</div>	
				<div><hr></div>	
				<div align="center">
					<div class="btnfechar" align="center">
							<h5>Voltar</h5>
					</div>
					<div class="btnsalvarreinc" align="center">
							<h5>Confirmar (reincidência)</h5>
					</div>
				</div>	
			</div>				
			<div class="corpoavaliacao">
				<div id="blocoreincidentes">
					<div id="numinspreinc"></div>
					<div id="gruporeinc"></div>
					<div id="itemreinc"></div>
					<div id="itemdescreinc"></div> 
					<div id="ptoclassifreinc"></div>
					<div id="statusreinc"></div>
					<div id="pontuacaoreinc"></div>
					<div id="statusparecer"></div>
					<div id="nomeinspreinc"></div>
					<div id="melhoriasreinc"><textarea name="ripmelhoriareinc" id="ripmelhoriareinc" cols="130" rows="10" wrap="VIRTUAL"></textarea></div>
					<div id="recomendacoesreinc"><textarea name="riprecomendacaoreinc" id="riprecomendacaoreinc" cols="130" rows="10" wrap="VIRTUAL"></textarea></div>
					<div><h5>Histórico das manifestações</h5></div>
					<div id="parecereinc"><textarea name="posparecereinc" id="posparecereinc" cols="172" rows="25" wrap="VIRTUAL" style="background:transparent;font-size:12px"></textarea></div>
					<br>
				</div>			
				<div id="blocotmpantes">
					<div id="numinsptmpantes"></div>
					<div id="grupotmpantes"></div>
					<div id="grupodesctmpantes"></div>
					<div id="itemtmpantes"></div>
					<div id="itemdesctmpantes"></div> 
					<div id="ptoclassiftmpantes"></div>
					<div id="statustmpantes"></div>
					<div id="pontuacaotmpantes"></div>
					<div id="nomeinsptmpantes"></div>
					<div id="melhoriatmpantes"><textarea name="melhoriantes" id="melhoriantes" cols="130" rows="10" wrap="VIRTUAL"></textarea></div>
					<div id="recomendacoestmpantes"><textarea name="recomendacoesantes" id="recomendacoesantes" cols="130" rows="10" wrap="VIRTUAL"></textarea></div>
					<br>
				</div>						
				<div id="blocotmp">
					<div id="grupotmp"></div>
					<div id="grupodesctmp"></div>
					<div id="itemtmp"></div>
					<div id="itemdesctmp"></div> 
					<div id="ptoclassiftmp"></div>
					<div id="statustmp"></div>
					<div id="pontuacaotmp"></div>
					<div id="nomeinsptmp"></div>
				</div>	
				<div id="corpomanifestacao">
					<br>
					<div class="bloco row">
						<div class="col" align="left"><label id="nomeavalitem">AVALIAR PARA:</label>
							<select class="form-control-sm" name="avalitem" id="avalitem"> 			
								<option value="A">---</option>				
								<option value="C">CONFORME</option>
								<option value="N">NÃO CONFORME</option>
								<option value="V">NÃO VERIFICADO</option>
								<option value="E">NÃO EXECUTA</option>
							</select>	 
						</div>
						<div class="col" id="paratodos"><label>Aplicar à todos do Grupo(não avaliados)?:</label>
							<select name="propagaval" id="propagaval" class="form-control-sm">
								<option value="N" selected>Não</option>
								<option value="S">Sim</option>
							</select>
						</div>						
					</div>
					
					<div id="reincidente">
						<table width="90%" align="center" class="table table-bordered table-hover">
							<tr>
								<td colspan="3" align="center"><div id="impactofin"><label>Reincidência</label></div></td>
							</tr>
							<tr>
								<td><label>Nº Avaliação</label>
								<td><label>Nº Grupo</label>
								<td><label>Nº Item</label>
							</tr> 	
							<tr>
								<td><input name="frmreincInsp" type="text" class="form-control-sm" id="frmreincInsp" size="16" maxlength="10" value="0" readonly=""></td>
								<td><input name="frmreincGrup" type="text" class="form-control-sm" id="frmreincGrup" size="8" maxlength="5" value="0"  readonly=""></td>
								<td><input name="frmreincItem" type="text" class="form-control-sm" id="frmreincItem" size="7" maxlength="4" value="0" readonly=""></td>
							</tr> 	
						</table>					
					</div>
					<div id="pontencialvalor">
						<table width="90%" align="center" class="table table-bordered table-hover">
							<tr>
								<td colspan="5" align="center"><div id="impactofin"><label>Potencial Valor</label></div></td>
							</tr>
							<tr>
								<td><div><label>Estimado a Recuperar(R$)</label></div></td>
								<td colspan="2"><div><label>Estimado Não Planejado/Extrapolado/Sobra(R$)</label></div></td>
								<td colspan="2"><div><label>Estimado em Risco ou Envolvido(R$)</label></div></td>
							</tr> 
							<tr>
								<td><div><input name="frmfalta" id="frmfalta" type="text" class="form-control-sm" value="" size="22" maxlength="18" onKeyPress="numericos()" onKeyUp="moedadig(this.name)"></div></td>
								<td><div><input name="frmsobra" id="frmsobra" type="text" class="form-control-sm" value="" size="22" maxlength="18"  onKeyPress="numericos()" onKeyUp="moedadig(this.name)"></div></td>
								<td><div><input type="checkbox" id="cdfrmsobra" name="cdfrmsobra" title="inativo">&nbsp;<label>Não se Aplica</label></div></td>
								<td><div><input name="frmemrisco" id="frmemrisco" type="text" class="form-control-sm" value="" size="22" maxlength="18" onKeyPress="numericos()" onKeyUp="moedadig(this.name)"></div></td>
								<td><div><input type="checkbox" id="cdfrmemrisco" name="cdfrmemrisco" title="inativo">&nbsp;<label>Não se Aplica</label></div></td>
							</tr>  						
						</table>
					</div>
					<br>
					<div id="mostrarmanchete">
						<div align="left"><label>Manchete</label></div>
						<div align="left"><textarea  name="manchete" id="manchete" cols="133" rows="2" wrap="VIRTUAL"><cfoutput>#form.manchete#</cfoutput></textarea></div>
					</div>
					<br>
					<div id="mostrartextarea">
						<div align="left"><label>Situação Encontrada</label></div>
						<div align="left"><textarea name="melhoria" id="melhoria" cols="145" rows="15" wrap="VIRTUAL"><cfoutput>#Form.melhoria#</cfoutput></textarea></div>
						<br>
						<div id="mostrarrecomendacoes">
							<div align="left"><label>Orientações</label></div>
							<div align="left"><textarea name="recomendacoes" id="recomendacoes" cols="133" rows="5" wrap="VIRTUAL"><cfoutput>#Form.recomendacoes#</cfoutput></textarea></div>
							<br>
						</div>
					</div>
					<div id="notacontrole">				
						<table width="100%" align="center" class="table table-bordered table-hover">
							<tr>
								<td align="center" colspan="2"><label>Nota de Controle?</label></td>
							</tr>	
							<tr>			
								<td> 
									<div class="col" align="left">
										<select name="nci" id="nci" class="form-select">
											<option value="" selected>Não</option>
											<option value="S">Sim</option>
										</select>
									</div>
								</td>						
								<td align="Center">	
									<div class="row">				
										<div class="col" align="right"><label>Nº SEI da NCI</label></div>
										<div class="col"><input class="form-control" name="frmnumseinci" id="frmnumseinci" type="text" onKeyPress="numericos();" onKeyUp="Mascara_SEI(this.value);" size="27" maxlength="20" value="" readonly></div>
									</div>
								</td>
							</tr>
						</table>
					</div>
					<input type="hidden" name="grpacesso" id="grpacesso" value="<cfoutput>#grpacesso#</cfoutput>">
					<input type="hidden" name="numinspecao" id="numinspecao" value="<cfoutput>#url.numinspecao#</cfoutput>">
					<input type="hidden" name="ano" id="ano" value="<cfoutput>#right(url.numinspecao,4)#</cfoutput>">
					<input type="hidden" name="codunidade" id="codunidade" value="<cfoutput>#trim(rsResult.RIP_Unidade)#</cfoutput>">
					<input type="hidden" name="unidade" id="unidade" value="<cfoutput>#trim(rsResult.Und_Descricao)#</cfoutput>">
					<input type="hidden" name="inpresponsavel" id="inpresponsavel" value="<cfoutput>#trim(rsResult.INP_Responsavel)#</cfoutput>">
					<input type="hidden" name="matrusuario" id="matrusuario" value="<cfoutput>#qAcesso.Usu_Matricula#</cfoutput>">
					<input type="hidden" name="grpsel" id="grpsel" value="">
					<input type="hidden" name="itmsel" id="itmsel" value="">
					<input type="hidden" name="resp" id="resp" value="">
					<input type="hidden" name="potencvlr" id="potencvlr" value="">
					<input type="hidden" name="intimpactartipos" id="intimpactartipos" value="">
					<input type="hidden" name="Itnreincidentes" id="Itnreincidentes" value="">
					<input type="hidden" name="ripncisei" id="ripncisei" value="">
					<input type="hidden" name="dbfrmfalta" id="dbfrmfalta" value="0,00">
					<input type="hidden" name="dbfrmsobra" id="dbfrmsobra" value="0,00">
					<input type="hidden" name="dbfrmemrisco" id="dbfrmemrisco" value="0,00">
					<input type="hidden" name="qtdreincidente" id="qtdreincidente" value="0">
					<input type="hidden" name="avalreincidente" id="avalreincidente" value="">
					<input type="hidden" name="gruporeincidente" id="gruporeincidente" value="">
					<input type="hidden" name="itemreincidente" id="itemreincidente" value="">
					<input type="hidden" name="stodescreincidente" id="stodescreincidente" value="">
					<input type="hidden" name="botaoanteriorsn" id="botaoanteriorsn" value="N">
					<input type="hidden" name="botaoreincidesn" id="botaoreincidesn" value="N">
					<input type="hidden" name="botaomostrareincidesn" id="botaomostrareincidesn" value="N">
					<input type="hidden" name="riprecomendacaoInspetor" id="riprecomendacaoInspetor" value="<cfoutput>#len(trim(rsResult.RIP_Recomendacao_Inspetor))#</cfoutput>">
					<input type="hidden" name="riprecomendacao" id="riprecomendacao" value="">
					<input type="hidden" name="concluirevisaosn" id="concluirevisaosn" value="<cfoutput>#concluiravalasn#</cfoutput>">
					<input type="hidden" name="impactarfalta" id="impactarfalta" value="N">
					<input type="hidden" name="impactarsobra" id="impactarsobra" value="N">
					<input type="hidden" name="cdfrmsobrasn" id="cdfrmsobrasn" value="N">
					<input type="hidden" name="impactarrisco" id="impactarrisco" value="N">
					<input type="hidden" name="cdfrmemriscosn" id="cdfrmemriscosn" value="N">
					<input type="hidden" name="qtdlistainspsemaval" id="qtdlistainspsemaval" value="">
					<input type="hidden" name="numanexoexcluir" id="numanexoexcluir" value="">
					<input type="hidden" name="formgrp" id="formgrp" value="<cfoutput>#formgrp#</cfoutput>">
					<input type="hidden" name="formitm" id="formitm" value="<cfoutput>#formitm#</cfoutput>">				
					<input type="hidden" name="acao" id="acao" value="">
					<div id='mostraranexos'>
						<table width="100%" align="center" class="table table-bordered table-hover">
							<tr>
								<td colspan="2"><div align="center"><label>Anexos</label></div></td>
							</tr>
								<tr>
									<td colspan="1"><input type="file" id="arquivo" name="arquivo" class="form-control" size="50"></td>
									<td colspan="1" align="center"><div id='anexar' class="form-control"><label class="lblbtn">Anexar</label></div>
								</tr>
							<tr>
								<td colspan="4">
									<div id='tableanexo'></div>							
								</td>
							</tr>					
						</table>			
					</div>
			</form>					
				<div id='divbtnsalvar'>
					<table width="100%" align="center" class="table table-hover">
					<tr>
						<td align="center">
							<div class="btnsalvar" align="center" title="Salvar Avaliação do Grupo/Item"><h5>Salvar Avaliação do Grupo/Item selecionado</h5></div>  
						</td>   
					</tr>
					</table>
				</div>			
	</section> 

		<aside class="auxiliar">
				<article id="buscas">
					<header>
						<div class="botaobuscar" align="center" title="Clique para ver avaliação anterior"><h5>Avaliação anterior</h5></div>
						<div class="botaorevereinc" align="center" title="Refazer Reincidência"><h5>Refazer reincidência(s)</h5></div>
						<div class="botaomostrareinc" align="center" title="Refazer Reincidência"><h5>Mostrar reincidência</h5></div>
					</header>
				</article>
				<br>
				<article>
					<header>
						<div id="grupo"></div>
					</header>
						<div id="grupodesc"></div>
				</article>
				<article>
					<header>
						<div id="item"></div>
					</header>
						<div id="itemdesc"></div> 
				</article>
				<article>
					<header>
						<div id="ptoclassif"></div>
					</header>
				</article>			
				<article>
					<header>
						<div id="status"></div>
					</header>
				</article>

				<article>
					<header>
						<div id="nomeinsp"></div>
					</header>
				</article>
				<article>
					<header>
						<div id="unid"></div>
					</header>
				</article>
				<article>
					<header>
						<div id="avaliacao"><h5>Inspetores</h5>
							<div>
								<cfoutput query="qInspetor">
									<cfset coord = ''>
									<cfif rsResult.INP_Coordenador eq IPT_MatricInspetor>
										<cfset coord = '<strong>(Coordena)</strong>'>
									</cfif>
									-&nbsp;<small>#qInspetor.Fun_Nome##coord#</small><br>
								</cfoutput>
							</div>
						</div>
					</header>
				</article>
				<article id="articledatas">
					<cfoutput>
						<header>
							<div id="datasaval"><h5>Datas</h5></div>
						</header>
						<div>				
							<table width="100%" align="center" class="table table-bordered table-hover">	
								<tr><td colspan="4"><small>Deslocamento</small></td></tr>			
								<tr>
									<td align="center">
										<small>Pré</small>
									</td>
									<td align="center">
										<small>Início</small>
									</td>
									<td align="center">
										<small>Final</small>
									</td>
									<td align="center">
										<small>Horas</small>
									</td>
								</tr>
								<tr>
									<td align="center">
										<small>#rsResult.INP_HrsPreInspecao#h</small>
									</td>
									<td align="center">
										<small>#dateformat(rsResult.INP_DtInicDeslocamento,"dd-mm-yyyy")#</small>
									</td>
									<td align="center">
										<small>#dateformat(rsResult.INP_DtFimDeslocamento,"dd-mm-yyyy")#</small>
									</td>
									<td align="center">
										<small>#rsResult.INP_HrsDeslocamento#h</small>
									</td>
								</tr>
								<tr><td colspan="4"><small>Avaliação</small></td></tr>
								<tr>
									<td align="center">
										<small>Início</small>
									</td>
									<td align="center">
										<small>Final</small>
									</td>
									<td align="center" colspan="2">
										<small>Horas</small>
									</td>
								</tr>
								<tr>
									<td align="center">
										<small>#dateformat(rsResult.INP_DtInicInspecao,"dd-mm-yyyy")#</small>
									</td>
									<td align="center">
										<small>#dateformat(rsResult.INP_DtFimInspecao,"dd-mm-yyyy")#</small>
									</td>
									<td align="center" colspan="2">
										<small>#rsResult.INP_HrsInspecao#h</small>
									</td>
								</tr>		
							</table>	
						</div>		
					</cfoutput>								
				</article>
		</aside>
	</main>
	<footer class="rodape">
	<!---
		<small>Guia Portal da Copa do Mundo Brasil © Copyright 2014 Todos os direitos reservados</small>
		--->
	</footer>
</div> <!-- /.tudo -->
</body>
<script src="public/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="public/axios.min.js"></script>
<script>
	$(function(e){
		function CKupdate(){
			for ( instance in CKEDITOR.instances )
			CKEDITOR.instances[instance].updateElement()
        }
		let aval = $('#selInspecoes').val()
		if (aval == '') {
			$('#divconcluiraval').hide()
			$(".auxiliar").hide()
			$(".navegacao").hide()
			$(".corpoavaliacao").hide()
			$(".rodape").hide()
		}  
		$('.botaomostrareinc').hide()
		$(".auxiliar").hide()
		$("#grupodesc").hide()
        $("#itemdesc").hide()
		$("#blocotmp").hide()
		$("#blocoreincidentes").hide()
		$("#blocotmpantes").hide()
		$("#reincidenciasgeral").hide()
		$("#reanalisegeral").hide()
		$("#reincidencias02").hide()
		$("#avaliacao").hide()
		$("#articledatas").hide()
		$("#buscas").hide()
		$("#pontencialvalor").hide()
		$("#corpomanifestacao").hide()
		let concluirevisaosn = $("#concluirevisaosn").val()
		if(concluirevisaosn == 'N'){$('#divconcluiraval').hide()}
		let formgrp = $('#formgrp').val()
		let formitm = $('#formitm').val()
		//alert(formgrp + ' '+formitm)
		$('.box').each(function(index) {
			let grp = $(this).attr("grp")
			let itm = $(this).attr("itm")
			//alert('formgrp: '+formgrp+' formitm: '+formitm)
			//if(grp==formgrp && itm ==formitm){$(this).trigger('click')}
			if(grp==formgrp && itm==formitm){ $(this).css('box-shadow', '8px 8px 5px #888')}
		})	
	})
	//================
	$('#nci').change(function(){ 
		let ncisn = $('#nci').val()
		//alert(ncisn)
		$("#frmnumseinci").prop('readonly', false)
		if(ncisn == 'S') {
			let nci = $(this).val()
			alert('Inspetor, é necessário registrar o N° SEI e anexar a NCI.')
			let ripncisei = $("#ripncisei").val()
			if(ripncisei != ''){
				let ripnciseiedit = ripncisei.substring(0,5)+'.'+ripncisei.substring(5,11)+'/'+ripncisei.substring(11,15)+'-'+ripncisei.substring(15,17)
				$('#frmnumseinci').val(ripnciseiedit)
			}
			$("#frmnumseinci").focus()
		}else{
			$('#frmnumseinci').val('')
			$("#frmnumseinci").prop('readonly', true)
			}
	})

	function Mascara_SEI(x)
		{
			//alert(x)
			let tam = x.length
			switch (tam)
			{
				case 5:
				$('#frmnumseinci').val(x+'.')
				break;
				case 12:
				$('#frmnumseinci').val(x+'/')
				break;
				case 17:
				$('#frmnumseinci').val(x+'-')
				break;
			}
	}	
	function numericos() {
		var tecla = window.event.keyCode;
		//alert(tecla)
		//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)	
			if (((tecla < 48) || (tecla > 57))) {
			//alert(tecla);
			event.returnValue = false;
		}
	}

	function moedadig(a){
		var valorinfo = $('#'+a).val()
		valorinfo = valorinfo.replaceAll(".", "")
		valorinfo = valorinfo.replace(",", "")
		let tam = valorinfo.length
		let inteiro = valorinfo.substring(0,tam-2)
		let strinteiro = inteiro.toString()
		inteiro=(eval(inteiro))
		let decimal = valorinfo.substring(tam-2,tam)
		//alert('tam: '+tam+' inteiro: '+inteiro+' decimal: '+decimal)
		//if (decimal.length == 1) {decimal = decimal + '0'}
		if(tam == 0){$('#'+a).val('0,00')}
		if(tam == 1 && inteiro == undefined){$('#'+a).val('0,0'+valorinfo)}
		if(tam == 2 && inteiro == undefined){$('#'+a).val('0,'+decimal)}
		if(tam == 3 && inteiro == 0 && decimal == '00'){$('#'+a).val('0,00')}
		if(tam == 3 && inteiro > 0){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 4 && inteiro == 0){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 4 && inteiro > 0){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 5){$('#'+a).val(inteiro+','+decimal)}
		if(tam == 6){
			let milhar = strinteiro.substring(0,1)
			let centena = strinteiro.substring(1,strinteiro.length)
			$('#'+a).val(milhar+'.'+centena+','+decimal)
		}
		if(tam == 7){
			let milhar = strinteiro.substring(0,2)
			let centena = strinteiro.substring(2,strinteiro.length)
			$('#'+a).val(milhar+'.'+centena+','+decimal)
		}
		if(tam == 8){
			let milhar = strinteiro.substring(0,3)
			let centena = strinteiro.substring(3,strinteiro.length)
			$('#'+a).val(milhar+'.'+centena+','+decimal)
		}
		if(tam == 9){
			let milhao = strinteiro.substring(0,1)
			let milhar = strinteiro.substring(1,4)
			let centena = strinteiro.substring(4,strinteiro.length)
			$('#'+a).val(milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 10){
			let milhao = strinteiro.substring(0,2)
			let milhar = strinteiro.substring(2,5)
			let centena = strinteiro.substring(5,strinteiro.length)
			$('#'+a).val(milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 11){
			let milhao = strinteiro.substring(0,3)
			let milhar = strinteiro.substring(3,6)
			let centena = strinteiro.substring(6,strinteiro.length)
			$('#'+a).val(milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 12){
			let bilhao = strinteiro.substring(0,1)
			let milhao = strinteiro.substring(1,4)
			let milhar = strinteiro.substring(4,7)
			let centena = strinteiro.substring(7,strinteiro.length)
			$('#'+a).val(bilhao+'.'+milhao+'.'+milhar+'.'+centena+','+decimal)
		}
		if(tam == 13){
			let bilhao = strinteiro.substring(0,2)
			let milhao = strinteiro.substring(2,5)
			let milhar = strinteiro.substring(5,8)
			let centena = strinteiro.substring(8,strinteiro.length)
			$('#'+a).val(bilhao+'.'+milhao+'.'+milhar+'.'+centena+','+decimal)
		}	
		if(tam == 14){
			let bilhao = strinteiro.substring(0,3)
			let milhao = strinteiro.substring(3,6)
			let milhar = strinteiro.substring(6,9)
			let centena = strinteiro.substring(9,strinteiro.length)
			$('#'+a).val(bilhao+'.'+milhao+'.'+milhar+'.'+centena+','+decimal)
		}				
		//var f2 = valorinfo.toLocaleString('pt-br', {minimumFractionDigits: 2});
	}
	function excluiranexo(numexc){
		//alert('numexc: '+numexc)
		if(confirm('Inspetor(a), Confirmar a exclusão do anexo selecionado!\n\nDeseja Continuar?')){}else{return false}
		$('#numanexoexcluir').val(numexc)
		$('#acao').val('excluiranexo')
		$('#formx').submit()		
	}	
	$('#anexar').click(function(){ 
		arquivo = $('#arquivo').val()
		if (arquivo == ''){
			alert('Selecione um arquivo no formato (.PDF)')
			$( '#arquivo' ).trigger( "focus" )
			return false
		}	
		$('#acao').val('anexar')
		$('#formx').submit()	
	})

	$('.botaomostrareinc').click(function(){  
		let botaomostrareincidesn = $("#botaomostrareincidesn").val()
		//alert('linha 1813 botaomostrareinc')
		if (botaomostrareincidesn == 'A'){
			return false
		}
		$('.botaobuscar').css('box-shadow', '5px 5px 3px #fff') 
		$('.botaobuscar').html('<h5>Avaliação anterior</h5>')
		//$('.botaobuscar').hide()
		$('.botaorevereinc').css('box-shadow', '5px 5px 3px #fff') 
		$('.botaorevereinc').html('<h5>Refazer reincidência(s)</h5>')
		//$('.botaorevereinc').hide()
		$("#botaoanteriorsn").val('N')
		$("#botaoreincidesn").val('N')
		if (botaomostrareincidesn == 'S'){
			$("#botaomostrareincidesn").val('N')
			$('#blocotmp').hide()
			$('#blocotmpantes').hide()
			$("#blocoreincidentes").hide() 
			$('.botaomostrareinc').html('<h5>Mostrar reincidência</h5>')
			$(this).css('box-shadow', '5px 5px 3px #fff')		
			return false
		}	
		$("#botaomostrareincidesn").val('S')	
		$('.botaomostrareinc').html('<h5>Fechar reincidência</h5>')
		$(this).css('box-shadow', '5px 5px 3px #ccc')
		let numinspecao = $('#numinspecao').val()
		let codunid = $("#codunidade").val()
		let Itnreincidentes = $('#Itnreincidentes').val()
		//let grp	= $("#grpsel").val()
		//let itm = $("#itmsel").val()
		var contreg = 0
		let posavaledit = ''
		let numinspecaoedit = numinspecao.substring(0,2)+'.'+numinspecao.substring(2,6)+'/'+numinspecao.substring(6,10)
		let posnuminspedit = ''
		//pesquisar por reincidência em aberto
		let posinsp = $('#frmreincInsp').val()	
		let grp = $("#frmreincGrup").val()
		let itm = $("#frmreincItem").val()
		let ripnuminsp = ''
		let grpdescricao = ''
		let itndescricao = ''
		let itnpontuacao = ''
		let Itnclassific = ''
		let ripresposta  = ''
		let funome       = ''
		let posituacaoresp = ''
		let stodescricao = ''
		//busca através do cfc	
		axios.get("CFC/avaliargrupoitem.cfc",{
			params: {
			method: "reincidenciafechadoaval",
			posinsp: posinsp,
			grupo: grp,
			item: itm
			}
		})
		.then(data =>{
			var vlr_ini = data.data.indexOf("COLUMNS");
			var vlr_fin = data.data.length
			vlr_ini = (vlr_ini - 2);
			// console.log('valor inicial: ' + vlr_fin);
			const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
			// Itn_Descricao,Grp_Descricao,Itn_Pontuacao,Itn_Classificacao,RIP_Resposta,Fun_Nome,RIP_NumInspecao,RIP_COMENTARIO,RIP_Recomendacoes,Pos_Situacao_Resp,STO_Descricao,Pos_Parecer
			//         0           1              2               3              4         5           6                7               8                 9                10         11 
			const dados = json.DATA
			$("#ripmelhoriareinc").val('')
			$("#riprecomendacaoreinc").val('')
			$("#posparecereinc").val('')
			dados.map((ret) => {
				itndescricao = ret[0]
				grpdescricao = ret[1]
				itnpontuacao = ret[2]
				Itnclassific = ret[3]
				ripresposta  = ret[4]
				funome       = ret[5]
				ripnuminsp   = ret[6]
				$("#ripmelhoriareinc").val(ret[7])
				$("#riprecomendacaoreinc").val(ret[8])	
				posituacaoresp = ret[9]
				stodescricao = ret[10]
				$("#posparecereinc").val(ret[11])	
			})
			if(ripresposta == "C"){status = 'CONFORME'}
			if(ripresposta == "N"){status = 'NÃO CONFORME'}
			if(ripresposta == "V"){status = 'NÃO VERIFICADO'}
			if(ripresposta == "E"){status = 'NÃO EXECUTA'}
			$('#numinspreinc').html('<h5>Nº Avaliação (reincidente): '+ripnuminsp+'</h5>')
			$('#gruporeinc').html('<h5>Grupo: '+grp+' - '+grpdescricao+'</h5>')
			$('#itemreinc').html('<h5>Item: '+itm+'</h5>')
			$('#itemdescreinc').html('<small>'+itndescricao+'</small>')
			$('#pontuacaoreinc').html('<h5>Pontuação/Classificação : <small>'+itnpontuacao+' - '+Itnclassific+'</small></h5>')
			$('#statusreinc').html('<h5>Status (fase avaliação): <small>'+status+'</small></h5>')
			$('#statusparecer').html('<h5>Resposta (manifestação): <small>'+posituacaoresp+' - '+stodescricao+'</small></h5>')
			$('#nomeinspreinc').html('<h5>Avaliado por : <small>'+funome+'</small></h5>')
			CKEDITOR.instances['ripmelhoriareinc'].setData(ripmelhoriareinc)
			CKEDITOR.instances['riprecomendacaoreinc'].setData(riprecomendacaoreinc)
			//CKEDITOR.instances['posparecereinc'].setData(posparecereinc)
			$('#blocotmp').hide()
			$('#blocotmpantes').hide()
			$("#blocoreincidentes").show(500)   
			ripnuminsp = ripnuminsp.substring(0,2)+'.'+ripnuminsp.substring(2,6)+'/'+ripnuminsp.substring(6,10)
			//alert('Sr(a) Inspetor(a)\n\nO item avaliado será considerado REINCIDENTE em decorrência da Não Conformidade registrada para a unidade no Relatório ' + ripnuminsp + ' item ' + grp +'.' + itm);
		})  
	})		
	$('.botaorevereinc').click(function(){  
		let botaoreincidesn = $("#botaoreincidesn").val()
		if (botaoreincidesn == 'A'){
			return false
		}
		$('.botaobuscar').css('box-shadow', '5px 5px 3px #fff') 
		$('.botaobuscar').html('<h5>Avaliação anterior</h5>')
		//$('#botaobuscar').hide()
		$("#botaoanteriorsn").val('N')
		if (botaoreincidesn == 'S'){
			$("#botaoreincidesn").val('N')
			$('#blocotmp').hide()
			$('#blocotmpantes').hide()
			$("#blocoreincidentes").hide() 
			$('.botaorevereinc').html('<h5>Refazer reincidência(s)</h5>')
			$(this).css('box-shadow', '5px 5px 3px #fff')		
			return false
		}	
		$("#botaoreincidesn").val('S')	
		$('.botaorevereinc').html('<h5>Fechar reincidência(s)</h5>')
		$(this).css('box-shadow', '5px 5px 3px #ccc')
		let numinspecao = $('#numinspecao').val()
		let codunid = $("#codunidade").val()
		let Itnreincidentes = $('#Itnreincidentes').val()
		//let grp	= $("#grpsel").val()
		//let itm = $("#itmsel").val()
		var contreg = 0
		let posavaledit = ''
		let numinspecaoedit = numinspecao.substring(0,2)+'.'+numinspecao.substring(2,6)+'/'+numinspecao.substring(6,10)
		let posnuminspedit = ''
		//pesquisar por reincidência em aberto
		axios.get("CFC/avaliargrupoitem.cfc",{
			params: {
			method: "reincidenciaemaberto",
			numinspecao: numinspecao,
			codunid : codunid,
			Itnreincidentes: Itnreincidentes
			}
		})
		.then(data =>{
			var vlr_ini = data.data.indexOf("COLUMNS");
			var vlr_fin = data.data.length
			vlr_ini = (vlr_ini - 2);
			// console.log('valor inicial: ' + vlr_fin);
			const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
			//console.log(json)
			//SELECT top 2 Pos_Inspecao, Grp_Descricao, Itn_Descricao, Pos_DtPosic, Pos_DtPrev_Solucao, STO_Descricao, RIP_Comentario, Pos_NumGrupo, Pos_NumItem
			//                    0            1              2              3             4                5                6               7            8
			const dados = json.DATA
			$("#melhoriareinc01").val('')
			$("#melhoriareinc02").val('')
			dados.map((ret) => {
				contreg++
				posnuminsp   = ret[0]
				grpdescricao = ret[1]
				itndescricao = ret[2]
				posdtposic   = ret[3]
				posdtprev    = ret[4]
				stodesc      = ret[5]
				posnumgrupo  = ret[7]
				posnumitem   = ret[8]
				if(contreg == 1){
					$("#reincidenciasgeral").show(300)
					$("#reincidencias01").show(500)
					$('#numavalreinc01').html('<h6>Nº Avaliação: '+posnuminsp+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Grupo: '+posnumgrupo+' - '+grpdescricao+'</h6>')
					$('#avalreincidente').val(posnuminsp)
					$('#gruporeincidente').val(posnumgrupo)
					$('#itemreincidente').val(posnumitem)
					$('#stodescreincidente').val(stodesc)
					$('#itemavalreinc01').html('<h6>Item: '+posnumitem+' - '+itndescricao+'</h6>')
					$('#statusavalreinc01').html('<h6>Status atual: '+posnumitem+' - '+stodesc+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Posição: '+posdtposic+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Previsão Solução: '+posdtprev+'</h6>')
					$("#melhoriareinc01").val(ret[6])
					CKEDITOR.instances['melhoriareinc01'].setData(melhoriareinc01)
					posnuminspedit = posnuminsp.substring(0,2)+'.'+posnuminsp.substring(2,6)+'/'+posnuminsp.substring(6,10)
					posavaledit = posnuminspedit
					$('#informe01reinc01').html('<h6>O período/amostra considerados para realização das avaliações são idênticos? (Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+posnuminspedit+' e Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+numinspecaoedit+')</h6>')
					let url = 'href=abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\Orientar_Reg_Reincidencia.pdf'
					$('#informe02reinc01').html('<h6>Atenção: Antes da confirmação de uma das opções (Sim) ou (Não), ler atentamente as orientações disponibilizadas <a class="alert-link" '+url+' target="_blank">Aqui.</a></h6>')
					$('.corpoavaliacao').hide()	
					$('#qtdreincidente').val(contreg)	
					$('#sim01').css('box-shadow', '5px 5px 3px #fff')
					$('#nao01').css('box-shadow', '5px 5px 3px #fff')	
					$('#sim01').attr('class','btnsim btnsn')
					$('#nao01').attr('class','btnnao btnsn')			
				}else{
					$("#reincidencias02").show(500)
					$('#numavalreinc02').html('<h6>Nº Avaliação: '+posnuminsp+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Grupo: '+posnumgrupo+' - '+grpdescricao+'</h6>')
					$('#itemavalreinc02').html('<h6>Item: '+posnumitem+' - '+itndescricao+'</h6>')
					$('#statusavalreinc02').html('<h6>Status atual: '+posnumitem+' - '+stodesc+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Posição: '+posdtposic+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Previsão Solução: '+posdtprev+'</h6>')
					$("#melhoriareinc02").val(ret[6])
					CKEDITOR.instances['melhoriareinc02'].setData(melhoriareinc02)
					posnuminspedit = posnuminsp.substring(0,2)+'.'+posnuminsp.substring(2,6)+'/'+posnuminsp.substring(6,10)
					posavaledit = posavaledit + ' e '+posnuminspedit
					$('#informe01reinc02').html('<h6>O período/amostra considerados para realização das avaliações são idênticos? (Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+posnuminspedit+' e Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+numinspecaoedit+')</h6>')
					let url = 'href=abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\Orientar_Reg_Reincidencia.pdf'
					$('#informe02reinc02').html('<h6>Atenção: Antes da confirmação de uma das opções (Sim) ou (Não), ler atentamente as orientações disponibilizadas <a class="alert-link" '+url+' target="_blank">Aqui.</a></h6>')							
					$('#qtdreincidente').val(contreg)	
					$('#sim02').css('box-shadow', '5px 5px 3px #fff')
					$('#nao02').css('box-shadow', '5px 5px 3px #fff')	
					$('#sim02').attr('class','btnsim btnsn')
					$('#nao02').attr('class','btnnao btnsn')	
				}				
			})
			if(dados.length > 0){
				$('.botaobuscar').hide()
				$('.botaorevereinc').hide()
				$('.botaomostrareinc').hide()
				$('.botaorevereinc').html('<h5>Refazer reincidência(s)</h5>')
				$("#botaoreincidesn").val('A')
				var texto = 'Senhor(a) Inspetor(a)\n\nO Grupo/item em avaliação foi registrado como Não Conforme na(s) Avaliação(ões) '+posavaledit+'.\n\nPara cada uma das Não Conformidades apresentadas em tela, informar se o período/amostra considerados para a realização da avaliação dos itens são idênticos.';
				alert(texto)
				$('.botaorevereinc').hide() 
			}
			if(dados.length == 0){
				let posinsp = $('#frmreincInsp').val()	
				let grp = $("#frmreincGrup").val()
				let itm = $("#frmreincItem").val()
				let ripnuminsp = ''
				let grpdescricao = ''
				let itndescricao = ''
				let itnpontuacao = ''
				let Itnclassific = ''
				let ripresposta  = ''
				let funome       = ''
				let posituacaoresp = ''
				let stodescricao = ''
				//busca através do cfc	
				axios.get("CFC/avaliargrupoitem.cfc",{
					params: {
					method: "reincidenciafechadoaval",
					posinsp: posinsp,
					grupo: grp,
					item: itm
					}
				})
				.then(data =>{
					var vlr_ini = data.data.indexOf("COLUMNS");
					var vlr_fin = data.data.length
					vlr_ini = (vlr_ini - 2);
					// console.log('valor inicial: ' + vlr_fin);
					const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
					// Itn_Descricao,Grp_Descricao,Itn_Pontuacao,Itn_Classificacao,RIP_Resposta,Fun_Nome,RIP_NumInspecao,RIP_COMENTARIO,RIP_Recomendacoes,Pos_Situacao_Resp,STO_Descricao,Pos_Parecer
					//         0           1              2               3              4         5           6                7               8                 9                10         11 
					const dados = json.DATA
					$("#ripmelhoriareinc").val('')
					$("#riprecomendacaoreinc").val('')
					$("#posparecereinc").val('')
					dados.map((ret) => {
						itndescricao = ret[0]
						grpdescricao = ret[1]
						itnpontuacao = ret[2]
						Itnclassific = ret[3]
						ripresposta  = ret[4]
						funome       = ret[5]
						ripnuminsp   = ret[6]
						$("#ripmelhoriareinc").val(ret[7])
						$("#riprecomendacaoreinc").val(ret[8])	
						posituacaoresp = ret[9]
				        stodescricao = ret[10]
						$("#posparecereinc").val(ret[11])	
					})
					if(ripresposta == "C"){status = 'CONFORME'}
					if(ripresposta == "N"){status = 'NÃO CONFORME'}
					if(ripresposta == "V"){status = 'NÃO VERIFICADO'}
					if(ripresposta == "E"){status = 'NÃO EXECUTA'}
					$('#numinspreinc').html('<h5>Nº Avaliação (reincidente): '+ripnuminsp+'</h5>')
					$('#gruporeinc').html('<h5>Grupo: '+grp+' - '+grpdescricao+'</h5>')
					$('#itemreinc').html('<h5>Item: '+itm+'</h5>')
					$('#itemdescreinc').html('<small>'+itndescricao+'</small>')
					$('#pontuacaoreinc').html('<h5>Pontuação/Classificação : <small>'+itnpontuacao+' - '+Itnclassific+'</small></h5>')
					$('#statusreinc').html('<h5>Status (fase avaliação): <small>'+status+'</small></h5>')
					$('#statusparecer').html('<h5>Resposta (manifestação): <small>'+posituacaoresp+' - '+stodescricao+'</small></h5>')
					$('#nomeinspreinc').html('<h5>Avaliado por : <small>'+funome+'</small></h5>')
					CKEDITOR.instances['ripmelhoriareinc'].setData(ripmelhoriareinc)
					CKEDITOR.instances['riprecomendacaoreinc'].setData(riprecomendacaoreinc)
					//CKEDITOR.instances['posparecereinc'].setData(posparecereinc)
					$('#blocotmp').hide()
					$('#blocotmpantes').hide()
					//$("#blocoreincidentes").show(500)   
					ripnuminsp = ripnuminsp.substring(0,2)+'.'+ripnuminsp.substring(2,6)+'/'+ripnuminsp.substring(6,10)
					alert('Sr(a) Inspetor(a)\n\nO item avaliado será considerado REINCIDENTE em decorrência da Não Conformidade registrada para a unidade no Relatório ' + ripnuminsp + ' item ' + grp +'.' + itm);
				}) 
			}
		})  
	})	
	$('.botaobuscar').click(function(){  
		$("#blocotmpantes").hide() 
		let botaoanteriorsn = $("#botaoanteriorsn").val()
		$("#botaoreincidesn").val('N')
		$('.botaorevereinc').css('box-shadow', '5px 5px 3px #fff') 
		$('.botaorevereinc').html('<h5>Refazer reincidência(s)</h5>')
		$("#blocotmpantes").hide()
		$(this).css('box-shadow', '5px 5px 3px #ccc')
		//var title = $(this).attr('title');
			
		if (botaoanteriorsn == 'S'){		
			$("#botaoanteriorsn").val('N')
			$('#blocotmp').hide()
			$('#blocotmpantes').hide()
			$("#blocoreincidentes").hide() 	
			$('.botaobuscar').html('<h5>Avaliação anterior</h5>')
			$(this).css('box-shadow', '5px 5px 3px #fff')
			return false
		}	
		$("#botaoanteriorsn").val('S')
		$('.botaobuscar').html('<h5>Fechar avaliação anterior</h5>')
		$("#blocotmp").hide()
		//$("#blocotmpantes").hide()
		let ano = $("#ano").val()
		let grp = $("#grpsel").val()
		let itm = $("#itmsel").val()
		let codunid = $('#codunidade').val();	
		let ripnuminsp = ''
		let grpdescricao = ''
		let itndescricao = ''
		let itnpontuacao = ''
		let Itnclassific = ''
		let ripresposta  = ''
		let funome       = ''
		//busca através do cfc
		axios.get("CFC/avaliargrupoitem.cfc",{
			params: {
			method: "avaliacaogrupoitmantes",
			ano: ano,
			codunid: codunid,
			grupo: grp,
			item: itm
			}
		})
		.then(data =>{
			var vlr_ini = data.data.indexOf("COLUMNS");
			var vlr_fin = data.data.length
			vlr_ini = (vlr_ini - 2);
			// console.log('valor inicial: ' + vlr_fin);
			const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
			//Itn_Descricao,Grp_Descricao,Itn_Pontuacao,Itn_Classificacao,RIP_Resposta,Fun_Nome,RIP_NumInspecao,RIP_COMENTARIO,RIP_Recomendacoes
			//       0           1              2               3              4         5           6                 7              8
			const dados = json.DATA
			$("#melhoriantes").val('')
			$("#recomendacoesantes").val('')
			dados.map((ret) => {
				itndescricao = ret[0]
				grpdescricao = ret[1]
				itnpontuacao = ret[2]
				Itnclassific = ret[3]
				ripresposta  = ret[4]
				funome       = ret[5]
				ripnuminsp   = ret[6]
				$("#melhoriantes").val(ret[7])
				$("#recomendacoesantes").val(ret[8])		
			})
			if(ripresposta == "C"){status = 'CONFORME'}
			if(ripresposta == "N"){status = 'NÃO CONFORME'}
			if(ripresposta == "V"){status = 'NÃO VERIFICADO'}
			if(ripresposta == "E"){status = 'NÃO EXECUTA'}
			$('#numinsptmpantes').html('<h5>Nº Avaliação (anterior): '+ripnuminsp+'</h5>')
			$('#grupotmpantes').html('<h5>Grupo: '+grp+'</h5>')
			$('#grupodesctmpantes').html('<small>'+grpdescricao+'</small>')
			$('#itemtmpantes').html('<h5>Item: '+itm+'</h5>')
			$('#itemdesctmpantes').html('<small>'+itndescricao+'</small>')
			$('#ptoclassiftmpantes').html('<h5>Pontuação/Classificação</h5><small>'+itnpontuacao+' - </small><small>'+Itnclassific+'</small>')
			$('#statustmpantes').html('<h5>Status:</h5><small>'+status+'</small>')
			$('#nomeinsptmpantes').html('<h5>Avaliado por :</h5><small>'+funome+'</small>')
			CKEDITOR.instances['melhoriantes'].setData(melhoriantes)
			CKEDITOR.instances['recomendacoesantes'].setData(recomendacoesantes)
			$('#blocotmp').hide()
			$('#blocoreincidentes').hide()
			if(dados.length == 0){
				alert('Não existe avaliação anterior para a unidade/grupo e item selecionados!')
				$("#botaoanteriorsn").val('N')
				$('.botaobuscar').html('<h5>Avaliação anterior</h5>')
				$(this).css('box-shadow', '5px 5px 3px #fff')
			}else{
				$("#blocotmpantes").show(500) 
			}
			  
		})  // final busca avaliação anterior	
	})
	$('#cdfrmemrisco').click(function(){  
		//alert('$("#dbfrmemrisco").val(): '+$("#dbfrmemrisco").val())
		let title = $(this).attr('title')
		if(title == 'inativo'){
			$('#cdfrmemrisco').attr('title','ativo')
			$('#frmemrisco').val('0,00')
			$("#frmemrisco").attr('disabled', true)
			$("#cdfrmemrisco").val('off')
			$("#cdfrmemriscosn").val('N')
		}else{
			$('#cdfrmemrisco').attr('title','inativo')
			$('#frmemrisco').val($("#dbfrmemrisco").val())
			$("#frmemrisco").attr('disabled', false)
			$("#cdfrmemrisco").val('on')
			$("#cdfrmemriscosn").val('S')
		}
	})	
	$('#cdfrmsobra').click(function(){  
		//alert('$("#dbfrmsobra").val(): '+$("#dbfrmsobra").val())
		//alert('$("#cdfrmsobrasn").val(): '+$("#cdfrmsobrasn").val())
		
		let title = $(this).attr('title')
		if(title == 'inativo'){
			$('#cdfrmsobra').attr('title','ativo')
			$('#frmsobra').val('0,00')
			$("#frmsobra").attr('disabled', true);	
			$("#cdfrmsobra").val('off')
			$("#cdfrmsobrasn").val('N')
		}else{
			$('#cdfrmsobra').attr('title','inativo')
			$('#frmsobra').val($("#dbfrmsobra").val())
			$("#frmsobra").attr('disabled', false)
			$("#cdfrmsobra").val('on')
			$("#cdfrmsobrasn").val('S')
		}
	})	
	//====================================	
	$('#avalitem').change(function(){   
		let respsel = $(this).val()
		let respdb = $("#resp").val()
		let insp = $('#numinspecao').val()
		let codunid = $("#codunidade").val()
		let grp	= $("#grpsel").val()
		let itm = $("#itmsel").val()
		ajustarbotoes()
		adaptartelas(respdb,respsel)
		if(respsel != 'A'){
			//alert('respdb: '+respdb+ ' respsel: '+respsel)
			if(respsel == respdb){dbresultadoinspecao(insp,grp,itm,respdb,codunid)}
			if((respsel != respdb) || (respdb == 'A')){dbitemverificacao(insp,grp,itm,respsel,codunid)}
		}
	})	
	function adaptartelas(respdb,respsel){
		//alert('respdb: '+respdb + ' respsel: '+respsel)
		$("#blocoreincidentes").hide()
		$('#blocotmp').hide()
		$('#blocotmpantes').hide()
		$('#notacontrole').hide()
		$('#mostraranexos').hide()
		$('#mostrarmanchete').hide()
		$("#mostrartextarea").hide()
		$('#mostrarrecomendacoes').hide()
		$('#paratodos').hide()
		$("#pontencialvalor").hide()
		$('#reincidente').hide()
		$("#tableanexo").hide() 
		$('#divbtnsalvar').show()
		$(".auxiliar").show(500)
		$("#buscas").show(500)
		$("#grupodesc").show(500)
        $("#itemdesc").show(500)
		$("#avaliacao").show(500)
		$("#articledatas").show(500)
		$("#corpomanifestacao").show(500) 
		$('.botaobuscar').css('box-shadow', '5px 5px 3px #fff')
		$('.botaobuscar').html('<h5>Avaliação anterior</h5>')
		$('.botaorevereinc').css('box-shadow', '5px 5px 3px #fff')
		$('.botaorevereinc').hide() 
		// ajustes de valores de tela principal
		$("#frmreincInsp").val('')
		$("#frmreincGrup").val(0)
		$("#frmreincItem").val(0)	
		$('#frmfalta').val('0,00')
		$('#frmemrisco').val('0,00')
		$('#frmsobra').val('0,00')

		$('#cdfrmsobra').attr('title','inativo')
		$("#cdfrmsobra").prop("checked", false)
		$('#frmsobra').val($("#dbfrmsobra").val())
		$("#frmsobra").attr('disabled', false)
		
		$('#cdfrmemrisco').attr('title','inativo')
		$("#cdfrmemrisco").prop("checked", false)
		$('#frmemrisco').val($("#dbfrmemrisco").val())
		$("#frmemrisco").attr('disabled', false)


		if(respdb == 'A' || respsel == 'A') {
			$('#divbtnsalvar').hide()	
		}
		//Novo grupo/item foi clicado e já possui uma avaliação do inspetor
		if(respdb == respsel){
			if(respdb == 'C' || respdb == "V") {
				$('#mostrartextarea').show(500)
				$('#divbtnsalvar').show()
			}
			if(respdb == 'N') {
				$('#mostrarmanchete').show(500)
				$('#mostrartextarea').show(500)
				$('#notacontrole').show(500)
				$('#mostrarrecomendacoes').show(500)				
				$('#mostraranexos').show(500)
				$('#divbtnsalvar').show()
				let potencvlr = $("#potencvlr").val()
				let intimpactartipos = $("#intimpactartipos").val()
				//alert('intimpactartipos: '+intimpactartipos)
				if(potencvlr == 'S'){
					$("#pontencialvalor").show(500)
					var arr = intimpactartipos.split(',')
					$.each( arr, function( i, val ) {
						if(i == 0){
							$("#impactarfalta").val(val)
							if(val == 'F'){$("#frmfalta").attr('disabled', false)}else{$("#frmfalta").attr('disabled', true)}
						}
						if(i == 1){
							$("#impactarsobra").val(val)
							if(val == 'S'){$("#frmsobra").attr('disabled', false);$("#cdfrmsobra").attr('disabled', false);$("#cdfrmsobrasn").val('S')}else{$("#frmsobra").attr('disabled', true);$("#cdfrmsobra").attr('disabled', true);$("#cdfrmsobrasn").val('N')}
						}
						if(i == 2){
							$("#impactarrisco").val(val)
							if(val == 'R'){$("#frmemrisco").attr('disabled', false);$("#cdfrmemrisco").attr('disabled', false);$("#cdfrmemriscosn").val('S')}else{$("#frmemrisco").attr('disabled', true);$("#cdfrmemrisco").attr('disabled', true);$("#cdfrmemriscosn").val('N')}
						}
					})
				}  
				let ripncisei = $("#ripncisei").val()
				if(ripncisei != ''){
					$('#nci').prop('selectedIndex', 1)
					let ripnciseiedit = ripncisei.substring(0,5)+'.'+ripncisei.substring(5,11)+'/'+ripncisei.substring(11,15)+'-'+ripncisei.substring(15,17)
					$("#frmnumseinci").prop('readonly', false)
					$('#frmnumseinci').val(ripnciseiedit)
				}else{
					$('#nci').prop('selectedIndex', 0)
					$("#frmnumseinci").prop('readonly', true)
					$('#frmnumseinci').val('')
				} 
				exibiranexos()
			}
			if(respdb == 'E') {
				$("#paratodos").show(500)
				$('#divbtnsalvar').show(500)
			}
		}
		//Mudança de resposta da avaliação
		if(respdb != respsel){
			if(respsel == "E"){
				$("#paratodos").show(500)
				$('#divbtnsalvar').show()
			}
			if(respsel == "C" || respsel == "V"){
				$("#mostrartextarea").show(500)
				$('#divbtnsalvar').show()
			}
			if(respsel == "N"){
				let numinspecao = $('#numinspecao').val()
				let grp = $("#grpsel").val()
				let itm = $("#itmsel").val()
				$('#mostrarmanchete').show(500)
				$("#mostrartextarea").show(500)
				CKEDITOR.instances['melhoria'].setData(melhoria)
				$('#notacontrole').show(500)
				$('#mostrarrecomendacoes').show(500)	
				$('#mostraranexos').show(500)
				$('#divbtnsalvar').show()
				//$("#corpomanifestacao").show(500)
				let potencvlr = $("#potencvlr").val()
				let intimpactartipos = $("#intimpactartipos").val()
				//alert('potencvlr: '+potencvlr)
				if(potencvlr == 'S'){
					$("#pontencialvalor").show(500)
					var arr = intimpactartipos.split(',')
					$.each( arr, function( i, val ) {
						if(i == 0){
							$("#impactarfalta").val(val)
							if(val == 'F'){$("#frmfalta").attr('disabled', false)}else{$("#frmfalta").attr('disabled', true)}
						}
						if(i == 1){
							$("#impactarsobra").val(val)
							if(val == 'S'){$("#frmsobra").attr('disabled', false);$("#cdfrmsobra").attr('disabled', false);$("#cdfrmsobrasn").val('S')}else{$("#frmsobra").attr('disabled', true);$("#cdfrmsobra").attr('disabled', true);$("#cdfrmsobrasn").val('N')}
						}
						if(i == 2){
							$("#impactarrisco").val(val)
							if(val == 'R'){$("#frmemrisco").attr('disabled', false);$("#cdfrmemrisco").attr('disabled', false);$("#cdfrmemriscosn").val('S')}else{$("#frmemrisco").attr('disabled', true);$("#cdfrmemrisco").attr('disabled', true);$("#cdfrmemriscosn").val('N')}
						}
					})
				}  
				exibiranexos()
				  
			}
		}
		let riprecomendacao = $("#riprecomendacao").val()
		let concluirevisaosn = $("#concluirevisaosn").val()
		if(riprecomendacao=='S' && concluirevisaosn == 'N'){
			$('#reanalisegeral').show(500)
			reanaliseajustar()
		}							
	}
//=====================================
	// realizar as buscas a partir do clicar do botão Avaliar Grupo/Item
	function reanaliseajustar(){
		$('.corpoavaliacao').hide()	
		$('.botaobuscar').hide()		
		$('.botaorevereinc').hide() 
		let numinspecao = $('#numinspecao').val()
		let grp = $("#grpsel").val()
		let itm = $("#itmsel").val()
		//pesquisar por reanálise 
		axios.get("CFC/avaliargrupoitem.cfc",{
			params: {
			method: "respostareanalise",
			numinspecao: numinspecao,
			grupo: grp,
			item: itm
			}
		})
		.then(data =>{
			var vlr_ini = data.data.indexOf("COLUMNS");
			var vlr_fin = data.data.length
			vlr_ini = (vlr_ini - 2);
			// console.log('valor inicial: ' + vlr_fin);
			const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
			//console.log(json)
			//RIP_Recomendacao_Inspetor, RIP_Critica_Inspetor
			//             0                        1       
			const dados = json.DATA
			$("#historirecominspetor").val('')
			$("#historirespinspetor").val('')
			//$("#respondereanalise").val('')
			dados.map((ret) => {
				$("#historirecominspetor").val(ret[0])
				$("#historirespinspetor").val(ret[1])
				CKEDITOR.instances['historirecominspetor'].setData(historirecominspetor)
				CKEDITOR.instances['historirespinspetor'].setData(historirespinspetor)
				//CKEDITOR.instances['respondereanalise'].setData(respondereanalise)					
			})
		}) 
	}
//=====================================
	$('.btnsalvarreinc').click(function(){
		if($('#qtdreincidente').val() == 1){
			if($('#sim01').attr('selecaosn') == 'N' && $('#nao01').attr('selecaosn') == 'N'){
				alert('Responder a pergunta acerca da amostra considerada na avaliação do item!');
		  		return false;
			}
		}
		if($('#qtdreincidente').val() == 2){
			if($('#sim01').attr('selecaosn') == 'N' && $('#nao01').attr('selecaosn') == 'N' && $('#sim02').attr('selecaosn') == 'N' && $('#nao02').attr('selecaosn') == 'N'){
				alert('Responder todas as perguntas acerca das amostras consideradas na avaliação dos itens!');
				return false;
			}
			if($('#nao01').attr('selecaosn') == 'S' && $('#nao02').attr('selecaosn') == 'N'){
				alert('Responder todas as perguntas acerca das amostras consideradas na avaliação dos itens!');
				return false;
			}
			if($('#nao01').attr('selecaosn') == 'N' && $('#nao02').attr('selecaosn') == 'S'){
				alert('Responder todas as perguntas acerca das amostras consideradas na avaliação dos itens!');
				return false;
			}							
		}
		ajustarbotoes()
		$('.botaobuscar').show(500)
		$("#reincidenciasgeral").hide()
		$("#qtdreincidente").val(0)
		let respdb = $("#resp").val()
		let insp = $('#numinspecao').val()
		let grp	= $("#grpsel").val()
		let itm = $("#itmsel").val()
		let codunid = $("#codunidade").val()
		$('.corpoavaliacao').show(500)	
		if($('#sim01').attr('selecaosn') == 'S' || $('#sim02').attr('selecaosn') == 'S'){
			//congelar opção para 'Conforme' e não mostrar reincidente
			//alert('linha 1460 sim01: '+$('#sim01').attr('selecaosn'))
			adaptartelas(respdb,'C')
			let prots = '<option value="C">Conforme</option>'
			$("#avalitem").html(prots) 
			let posnuminsp  = $('#avalreincidente').val()
			let stodesc = $('#stodescreincidente').val()
			posnuminspedit = posnuminsp.substring(0,2)+'.'+posnuminsp.substring(2,6)+'/'+posnuminsp.substring(6,10)
			let posnumgrupo = $('#gruporeincidente').val()
			let posnumitem  = $('#itemreincidente').val()
			$("#melhoria").val('Os fatos identificados como Não Conforme foram registrados no relatório anterior : Avaliação: '+posnuminspedit+' Grupo/Item: '+posnumgrupo+'-'+posnumitem+' com situação atual em: '+stodesc)
			CKEDITOR.instances['melhoria'].setData(melhoria)
			//if('C' == respdb){dbresultadoinspecao(insp,grp,itm,respdb,codunid)}
			//if('C' != respdb){dbitemverificacao(insp,grp,itm,respsel,codunid)}
		}
		if($('#nao01').attr('selecaosn') == 'S' || $('#nao02').attr('selecaosn') == 'S'){
			//congelar opção para 'Não Conforme' e mostrar reincidente em tela para ser salvo em banco
			$('.botaorevereinc').show(500)
			$('.botaomostrareinc').show(500)
			adaptartelas(respdb,'N')
			let prots = '<option value="N">Não Conforme</option>'
 			$("#avalitem").html(prots)  
			$("#frmreincInsp").val($('#avalreincidente').val())
			$("#frmreincGrup").val($('#gruporeincidente').val())
			$("#frmreincItem").val($('#itemreincidente').val())
			$("#reincidente").show(500)
			if('N' != respdb){dbitemverificacao(insp,grp,itm,respsel,codunid)}
		}	
		$("#botaoreincidesn").val('N')
		$('.botaorevereinc').css('box-shadow', '5px 5px 3px #fff') 	
	})
	$('.btnsn').click(function(){ 
		let classe = $(this).attr("class")
		if(classe == 'btndisabled'){
			return false
		}
		$(this).css('box-shadow', '8px 8px 5px #888')
		id = $(this).attr("id")
		if(id == 'sim01'){
			$('#sim01').attr('selecaosn','S')
			$('#nao01').attr('selecaosn','N')
			$('#sim02').attr('selecaosn','N')
			$('#nao02').attr('selecaosn','N')
			$('#sim02').attr('class','btndisabled')
			$('#nao02').attr('class','btndisabled')
			$('#nao01').css('box-shadow', '5px 5px 3px #fff')
			$('#nao02').css('box-shadow', '5px 5px 3px #fff')
		}
		if(id == 'nao01'){
			$('#sim01').attr('selecaosn','N')
			$('#sim02').attr('selecaosn','N')
			$('#nao01').attr('selecaosn','S')
			$('#sim02').attr('class','btnsim btnsn')
			$('#nao02').attr('class','btnnao btnsn')
			$('#sim01').css('box-shadow', '5px 5px 3px #fff')
		}		
		if(id == 'sim02'){
			$('#sim02').attr('selecaosn','S')
			$('#nao02').attr('selecaosn','N')
			$('#sim01').attr('selecaosn','N')
			$('#nao01').attr('selecaosn','N')
			$('#sim01').attr('class','btndisabled')
			$('#nao01').attr('class','btndisabled')
			$('#nao01').css('box-shadow', '5px 5px 3px #fff')
			$('#nao02').css('box-shadow', '5px 5px 3px #fff')
		}
		if(id == 'nao02'){
			$('#sim01').attr('selecaosn','N')
			$('#sim02').attr('selecaosn','N')
			$('#nao02').attr('selecaosn','S')
			$('#sim01').attr('class','btnsim btnsn')
			$('#nao01').attr('class','btnnao btnsn')
			$('#sim02').css('box-shadow', '5px 5px 3px #fff')
		}	
		//alert("selecaosn: sim01:"+$('#sim01').attr('selecaosn')+" Nao01: "+$('#nao01').attr('selecaosn')+" sim02: "+$('#sim02').attr('selecaosn')+" nao02: "+$('#nao02').attr('selecaosn'))
	})

	$('.btnconcluiraval').click(function(){
		let numinspecao = $('#numinspecao').val()
		let qtdinspaval = 0
		let matrinspaval = ''
		 var auxcam = " \n\nInspetor(a), esta opção finaliza a ação de Avaliação do relatório: "+numinspecao+".\n\nConfirma em Concluir e Liberar Avaliação para Revisão?";
	 	 if (confirm ('            Atenção!' + auxcam))
		 {
			axios.get("CFC/avaliargrupoitem.cfc",{
				params: {
				method: "contaravaliador",
				numinspecao: numinspecao
				}
			})
			.then(data =>{
				var vlr_ini = data.data.indexOf("COLUMNS");
				var vlr_fin = data.data.length
				vlr_ini = (vlr_ini - 2);
				// console.log('valor inicial: ' + vlr_fin);
				const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
				//console.log(json)
				//SELECT top 1 Pos_Inspecao
				//                  0            
				const dados = json.DATA
				dados.map((ret) => {
					if(ret[1] == null) {
						if(matrinspaval == '') {matrinspaval = ret[0]}else{matrinspaval += ','+ret[0]}
					}else{qtdinspaval++}
					
				}) 	
				//alert('qtdinspaval: '+qtdinspaval)		
				//alert('matrinspaval: '+matrinspaval)
				if(qtdinspaval <= 1){
					var m = "Todos os itens foram avaliados por apenas 1(um) Inspetor(a).\n\nA liberação desta avaliação está condicionada à avaliação dos itens por pelo menos 2 (dois) Inspetores(as).\n\nInspetores(as) sem avaliar item " + matrinspaval
					alert(m)
					return false
				}else{
					$('#qtdlistainspsemaval').val(matrinspaval)	
					$('#acao').val('concluiravaliacao')	
					$('#formx').submit()
				}
			})

		 }
	})
	$('.btnfecharreanalise').click(function(){
		$("#reanalisegeral").hide()
		$('.corpoavaliacao').show(500)	
		$('.botaobuscar').show(500)		
		$('.botaorevereinc').show(500) 
		$('.botaomostrareinc').show(500)
	})
	$('.btnenviocomreanalise').click(function(){
		let grpacesso = $('#grpacesso').val()
		let numinspecao = $('#numinspecao').val()
		let grp = $("#grpsel").val()
		let itm = $("#itmsel").val()
		let respondereanalise = $("#respondereanalise").val()
		if(respondereanalise == ''){
		alert('O campo "Inspetor(a) - Responder para Revisor(a), não pode ser vazio')
			$("#respondereanalise").focus()
			return false			
		}		
		axios.get("CFC/avaliargrupoitem.cfc",{
			params: {
			method: "grupoitemreanalise",
			grpacesso: grpacesso,
			numinspecao: numinspecao,
			grp: grp,
			itm: itm,
			respondereanalise: respondereanalise,
			textoinicial : 'Resposta do Inspetor(a) (COM REANÁLISE DO PONTO)'
			}
		})
		.then(data =>{
			var vlr_ini = data.data.indexOf("COLUMNS");
			var vlr_fin = data.data.length
			vlr_ini = (vlr_ini - 2);
			// console.log('valor inicial: ' + vlr_fin);
			const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
			//console.log(json)
			//SELECT top 1 Pos_Inspecao
			//                  0            
			const dados = json.DATA
			dados.map((ret) => {
				alert(ret[0])
			}) 						
		})
		$("#reanalisegeral").hide()
		$('.corpoavaliacao').show(500)	
		$('.botaobuscar').show(500)		
		$('.botaorevereinc').show(500) 
		$('.botaomostrareinc').show(500)
	})
	$('.btnenviosemreanalise').click(function(){
		let grpacesso = $('#grpacesso').val()
		let numinspecao = $('#numinspecao').val()
		let grp = $("#grpsel").val()
		let itm = $("#itmsel").val()
		let respondereanalise = $("#respondereanalise").val()
		if(respondereanalise == ''){
		alert('O campo "Inspetor(a) - Responder para Revisor(a), não pode ser vazio')
			$("#respondereanalise").focus()
			return false			
		}
		axios.get("CFC/avaliargrupoitem.cfc",{
			params: {
			method: "grupoitemreanalise",
			grpacesso: grpacesso,
			numinspecao: numinspecao,
			grp: grp,
			itm: itm,
			respondereanalise: respondereanalise,
			textoinicial : 'Resposta do Inspetor(a) (SEM ALTERAÇÃO DO PONTO)'
			}
		})
		.then(data =>{
			var vlr_ini = data.data.indexOf("COLUMNS");
			var vlr_fin = data.data.length
			vlr_ini = (vlr_ini - 2);
			// console.log('valor inicial: ' + vlr_fin);
			const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
			//console.log(json)
			//SELECT top 1 Pos_Inspecao
			//                  0            
			const dados = json.DATA
			dados.map((ret) => {
				alert(ret[0])
			}) 						
		})
		$('#acao').val('revisaosemreanalise')	
		$('#formx').submit()	
	})
	$('.btnfechar').click(function(){
		ajustarbotoes()
		$('.botaobuscar').show(500)
		$("#botaoreincidesn").val('N')
		$('.botaorevereinc').css('box-shadow', '5px 5px 3px #fff') 
		$("#qtdreincidente").val(0)
		$("#reincidenciasgeral").hide()
		$('.corpoavaliacao').show(500)	
		let numinspecao = $('#numinspecao').val()
		let grp = $("#grpsel").val()
		let itm = $("#itmsel").val()
		let resp = $("#resp").val()
		let codunid = $("#codunidade").val()
		let prots = ''
		if(resp == "A"){selecionar = 'selected'}else{selecionar = ''}
		prots = '<option value="A"'+selecionar+'>---</option>'
		if(resp == "C"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="C"'+selecionar+'>CONFORME</option>'
		if(resp == "N"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="N"'+selecionar+'>NÃO CONFORME</option>'
		if(resp == "V"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="V"'+selecionar+'>NÃO VERIFICADO</option>'
		if(resp == "E"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="E"'+selecionar+'>NÃO EXECUTA</option>'
 		$("#avalitem").html(prots) 
		adaptartelas(resp,resp)
		dbresultadoinspecao(numinspecao,grp,itm,resp,codunid)
	})
	function ajustarbotoes(){
		$("#blocotmp").hide()
		let resp = $("#resp").val()
		//alert('resp: '+resp)
		$('.botaobuscar').css('box-shadow', '5px 5px 3px #fff') 
		$('.botaobuscar').html('<h5>Avaliação anterior</h5>')
		$("#botaoanteriorsn").val('N')
		$('.botaorevereinc').css('box-shadow', '5px 5px 3px #fff') 
		$('.botaorevereinc').html('<h5>Refazer reincidência(s)</h5>')
		$("#botaoreincidesn").val('N')
		$('.botaomostrareinc').html('<h5>Mostrar reincidência</h5>')
		$('.botaomostrareinc').css('box-shadow', '5px 5px 3px #fff')
		$("#botaomostrareincidesn").val('N') 
		if(resp != 'N'){$('.botaorevereinc').hide();$('.botaomostrareinc').hide()}
		//$('.botaobuscar').show(500)
	}	
    $('.box').click(function(){   
		$("#blocotmp").hide()
		ajustarbotoes()
		$(this).css('box-shadow', '5px 5px 3px #fff')
		$('.botaomostrareinc').hide()
		if($("#qtdreincidente").val() != 0){return false}
        $( '.box' ).each(function( index ) {
           $(this).css('box-shadow', '5px 5px 3px #fff')
        })	
		let grpselatual = $("#grpsel").val()
		let itmselatual = $("#itmsel").val()
		grp = $(this).attr("grp")
		itm = $(this).attr("itm")
		if (grpselatual == grp && itmselatual == itm){
			$("#grpsel").val('')
			$(".auxiliar").hide()
			$("#grupodesc").hide()
			$("#itemdesc").hide()
			$("#blocotmp").hide()
			$("#blocoreincidentes").hide()
			$("#blocotmpantes").hide()
			$("#reincidenciasgeral").hide()
			$("#reanalisegeral").hide()
			$("#reincidencias02").hide()
			$("#avaliacao").hide()
			$("#articledatas").hide()
			$("#buscas").hide()
			$("#pontencialvalor").hide()
			$("#corpomanifestacao").hide()			
			return false
		}
		$("#grp").val(grp)
		grpdesc = $(this).attr("grpdesc")
		$("#grpsel").val(grp)
		$("#itmsel").val(itm)
		$("#itm").val(itm)
		itmdesc = $(this).attr("itmdesc")
		let resp = $(this).attr("resposta")
		$("#resp").val(resp)
		let potencvlr = $(this).attr("potencvlr")
		$("#potencvlr").val(potencvlr)
		let intimpactartipos = $(this).attr("intimpactartipos")
		$("#intimpactartipos").val(intimpactartipos)
		let Itnreincidentes = $(this).attr("Itnreincidentes")
		$("#Itnreincidentes").val(Itnreincidentes)
		//alert('Itnreincidentes linha 2283: '+Itnreincidentes)
		let ripncisei = $(this).attr("ripncisei")
		$("#ripncisei").val(ripncisei)
		let riprecomendacao = $(this).attr("riprecomendacao")
		$("#riprecomendacao").val(riprecomendacao)
		title = $(this).attr("title")
		let matrinsp = $(this).attr("matrinsp")
		let nomeinsp = $(this).attr("nomeinsp")
		let matrusuario = $("#matrusuario").val() 
		//alert('matrinsp: '+matrinsp+ ' nomeinsp: '+nomeinsp+' matrusuario: '+matrusuario)
		if(matrinsp !='' && matrinsp != matrusuario){
			let avaliador2 = '       Atenção!\n\nEste Item já foi avaliado por:\n\n'+nomeinsp+' ('+matrinsp+')'
			alert(avaliador2)
		}
		
		let codunid = $("#codunidade").val()
		let nomeunidade = $("#unidade").val()
		let inpresponsavel= $("#inpresponsavel").val()
		let pontuacao = $(this).attr("pontuacao")
		let classificacao = $(this).attr("classificacao")
		$('#grupo').html('<h5>Grupo: '+grp+'</h5>')
		$('#item').html('<h5>Item: '+itm+'</h5>')
		$('#status').html('<h5>Status:</h5><label>'+title+'</label>')
		$('#ptoclassif').html('<h5>Pontuação/Classificação</h5><small>'+pontuacao+' - </small><small>'+classificacao+'</small>')
		$('#nomeinsp').html('<h5>Avaliado por : </h5><small>'+nomeinsp+'</small>')
		$('#unid').html('<h5>Unidade: </h5><small>'+codunid+' - '+nomeunidade+'</small>'+'<br><small>'+inpresponsavel+'</small>')
        $(this).css('box-shadow', '8px 8px 5px #888')
		$('#grupodesc').html('<small>'+grpdesc+'</small>')
		$('#itemdesc').html('<small>'+itmdesc+'</small>')
		$('#nomeavalitem').html('Avaliar Grupo_Item (<strong>'+grp+'_'+itm +'</strong>) para:')
		adaptartelas(resp,resp)
		let selecionar = ''
		if(resp == "A"){selecionar = 'selected'}else{selecionar = ''}
		prots = '<option value="A"'+selecionar+'>---</option>'
		if(resp == "C"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="C"'+selecionar+'>CONFORME</option>'
		if(resp == "N"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="N"'+selecionar+'>NÃO CONFORME</option>'
		if(resp == "V"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="V"'+selecionar+'>NÃO VERIFICADO</option>'
		if(resp == "E"){selecionar = 'selected'}else{selecionar = ''}
		prots += '<option value="E"'+selecionar+'>NÃO EXECUTA</option>'
 		$("#avalitem").html(prots)   
		let numinspecao = $('#numinspecao').val()
		//alert('resp: '+resp)
		if(resp != 'A'){
		   dbresultadoinspecao(numinspecao,grp,itm,resp,codunid)
		}				
    })
	// realizar as buscas a partir do clicar do botão Avaliar Grupo/Item
	function dbitemverificacao(numinspecao,grp,itm,respsel,codunid){
			//alert('resp linha 1616 '+respsel)
			if(respsel == 'N'){
				var contreg = 0
				let posavaledit = ''
				let numinspecaoedit = numinspecao.substring(0,2)+'.'+numinspecao.substring(2,6)+'/'+numinspecao.substring(6,10)
				let posnuminspedit = ''
				let Itnreincidentes = $('#Itnreincidentes').val()
				//pesquisar por reincidência em aberto
				axios.get("CFC/avaliargrupoitem.cfc",{
					params: {
					method: "reincidenciaemaberto",
					numinspecao: numinspecao,
					codunid : codunid,
					Itnreincidentes: Itnreincidentes
					}
				})
				.then(data =>{
					var vlr_ini = data.data.indexOf("COLUMNS");
					var vlr_fin = data.data.length
					vlr_ini = (vlr_ini - 2);
					// console.log('valor inicial: ' + vlr_fin);
					const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
					//console.log(json)
					//SELECT top 2 Pos_Inspecao, Grp_Descricao, Itn_Descricao, Pos_DtPosic, Pos_DtPrev_Solucao, STO_Descricao, RIP_Comentario, Pos_NumGrupo, Pos_NumItem
					//                    0            1              2              3             4                5                6               7           8       
					const dados = json.DATA
					$("#melhoriareinc01").val('')
					$("#melhoriareinc02").val('')
					dados.map((ret) => {
						contreg++
						posnuminsp   = ret[0]
						grpdescricao = ret[1]
						itndescricao = ret[2]
						posdtposic   = ret[3]
						posdtprev    = ret[4]
						stodesc      = ret[5]
						posnumgrupo  = ret[7]
						posnumitem   = ret[8]
						if(contreg == 1){
							$("#reincidenciasgeral").show(300)
							$("#reincidencias01").show(500)
							$('#numavalreinc01').html('<h6>Nº Avaliação: '+posnuminsp+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Grupo: '+posnumgrupo+' - '+grpdescricao+'</h6>')
							$('#avalreincidente').val(posnuminsp)
							$('#gruporeincidente').val(posnumgrupo)
							$('#itemreincidente').val(posnumitem)
							$('#stodescreincidente').val(stodesc)
							$('#itemavalreinc01').html('<h6>Item: '+posnumitem+' - '+itndescricao+'</h6>')
							$('#statusavalreinc01').html('<h6>Status atual: '+posnumitem+' - '+stodesc+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Posição: '+posdtposic+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Previsão Solução: '+posdtprev+'</h6>')
							$("#melhoriareinc01").val(ret[6])
							CKEDITOR.instances['melhoriareinc01'].setData(melhoriareinc01)
							posnuminspedit = posnuminsp.substring(0,2)+'.'+posnuminsp.substring(2,6)+'/'+posnuminsp.substring(6,10)
							posavaledit = posnuminspedit
							$('#informe01reinc01').html('<h6>O período/amostra considerados para realização das avaliações são idênticos? (Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+posnuminspedit+' e Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+numinspecaoedit+')</h6>')
							let url = 'href=abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\Orientar_Reg_Reincidencia.pdf'
							$('#informe02reinc01').html('<h6>Atenção:Antes da confirmação de uma das opções (Sim) ou (Não), ler atentamente as orientações disponibilizadas <a class="alert-link" '+url+' target="_blank">Aqui.</a></h6>')
							$('.corpoavaliacao').hide()	
							$('#qtdreincidente').val(contreg)	
							$('#sim01').css('box-shadow', '5px 5px 3px #fff')
							$('#nao01').css('box-shadow', '5px 5px 3px #fff')	
							$('#sim01').attr('class','btnsim btnsn')
							$('#nao01').attr('class','btnnao btnsn')			
						}else{
							$("#reincidencias02").show(500)
							$('#numavalreinc02').html('<h6>Nº Avaliação: '+posnuminsp+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Grupo: '+posnumgrupo+' - '+grpdescricao+'</h6>')
							$('#itemavalreinc02').html('<h6>Item: '+posnumitem+' - '+itndescricao+'</h6>')
							$('#statusavalreinc02').html('<h6>Status atual: '+posnumitem+' - '+stodesc+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Posição: '+posdtposic+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Previsão Solução: '+posdtprev+'</h6>')
							$("#melhoriareinc02").val(ret[6])
							CKEDITOR.instances['melhoriareinc02'].setData(melhoriareinc02)
							posnuminspedit = posnuminsp.substring(0,2)+'.'+posnuminsp.substring(2,6)+'/'+posnuminsp.substring(6,10)
							posavaledit = posavaledit + ' e '+posnuminspedit
							$('#informe01reinc02').html('<h6>O período/amostra considerados para realização das avaliações são idênticos? (Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+posnuminspedit+' e Item '+posnumgrupo+'.'+posnumitem+' Avaliação '+numinspecaoedit+')</h6>')
							let url = 'href=abrir_pdf_act.cfm?arquivo=\\\\sac0424\\SISTEMAS\\SNCI\\GUIAS\\Orientar_Reg_Reincidencia.pdf'
							$('#informe02reinc02').html('<h6>Atenção:Antes da confirmação de uma das opções (Sim) ou (Não), ler atentamente as orientações disponibilizadas <a class="alert-link" '+url+' target="_blank">Aqui.</a></h6>')							
							$('#qtdreincidente').val(contreg)	
							$('#sim02').css('box-shadow', '5px 5px 3px #fff')
							$('#nao02').css('box-shadow', '5px 5px 3px #fff')	
							$('#sim02').attr('class','btnsim btnsn')
							$('#nao02').attr('class','btnnao btnsn')	
						}				
					})
					if(dados.length > 0){
						$('.botaobuscar').hide()
						$('.botaorevereinc').hide()
						$('.botaomostrareinc').hide()
						var texto = 'Senhor(a) Inspetor(a)\n\nO Grupo/item em avaliação foi registrado como Não Conforme na(s) Avaliação(ões) '+posavaledit+'.\n\nPara cada uma das Não Conformidades apresentadas em tela, informar se o período/amostra considerados para a realização da avaliação dos itens são idênticos.';
						alert(texto)
					}
					if(dados.length == 0){
						//pesquisar por reincidência em fechado
						axios.get("CFC/avaliargrupoitem.cfc",{
							params: {
							method: "reincidenciafechado",
							numinspecao: numinspecao,
							codunid : codunid,
							Itnreincidentes: Itnreincidentes
							}
						})
						.then(data =>{
							var vlr_ini = data.data.indexOf("COLUMNS");
							var vlr_fin = data.data.length
							vlr_ini = (vlr_ini - 2);
							// console.log('valor inicial: ' + vlr_fin);
							const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
							//console.log(json)
							//SELECT top 1 Pos_Inspecao,Pos_NumGrupo,Pos_NumItem
							//                  0            1             2
							const dados = json.DATA
							dados.map((ret) => {
								let posnuminsp = ret[0]
								let grp        = ret[1]
								let itm        = ret[2]
								$("#frmreincInsp").val(ret[0])
								$("#frmreincGrup").val(ret[1])
								$("#frmreincItem").val(ret[2])
								$("#reincidente").show(500)
								$('.botaomostrareinc').show(500)		
								posnuminsp = posnuminsp.substring(0,2)+'.'+posnuminsp.substring(2,6)+'/'+posnuminsp.substring(6,10)
								alert('Sr(a) Inspetor(a)\n\nO item avaliado será considerado REINCIDENTE em decorrência da Não Conformidade registrada para a unidade no Relatório '+posnuminsp+' item '+grp+'.'+itm)	
							}) 						
						}) 
					}
				})  
				//Pesquisar possíveis valores reincidentes para carregar e exibir na tela 
				//criar novo método.
			}
			//busca através do cfc
			axios.get("CFC/avaliargrupoitem.cfc",{
				params: {
				method: "dbgrpitmitemverificacao",
				numinspecao: numinspecao,
				grupo: grp,
				item: itm
				}
			})
			.then(data =>{
				var vlr_ini = data.data.indexOf("COLUMNS");
				var vlr_fin = data.data.length
				vlr_ini = (vlr_ini - 2);
				// console.log('valor inicial: ' + vlr_fin);
				const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
				//console.log(json)
				//	SELECT RIP_Falta,RIP_Sobra,RIP_EmRisco,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Manchete,RIP_ReincInspecao,RIP_ReincGrupo,RIP_ReincItem,Itn_Norma
				//             0         1          2            3                4                 5                6                 7            8         9
				const dados = json.DATA
				dados.map((ret) => {
					//alert('itnprerelato : '+ret[2])
					$('#frmreincGrup').val(0)
					$("#frmfalta").val(ret[0].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#frmsobra").val(ret[1].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#frmemrisco").val(ret[2].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#dbfrmfalta").val(ret[0].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#dbfrmsobra").val(ret[1].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#dbfrmemrisco").val(ret[2].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					//alert('prerelato: '+ret[3])
					if(respsel != 'N')
					{
						$("#melhoria").val('Descrever a Situação Encontrada...');
						CKEDITOR.instances['melhoria'].setData(melhoria)
					}else{
						let melhoria = ret[3] + '<strong>Ref. Normativa:</strong>'+ret[9]
						$("#melhoria").val(melhoria)
						CKEDITOR.instances['melhoria'].setData(melhoria)
					}
					$("#recomendacoes").val(ret[4])
					CKEDITOR.instances['recomendacoes'].setData(recomendacoes)
					$("#manchete").val(ret[5])
					CKEDITOR.instances['manchete'].setData(manchete)
					ret[6] = ret[6].replace("          ","")
					//alert('tamanho: '+ret[6].length)
					$("#frmreincInsp").val(ret[6])
					$("#frmreincGrup").val(ret[7])
					$("#frmreincItem").val(ret[8])
					if(ret[6].length == 10 && respdb == 'N'){$("#reincidente").show(500)}                                                                                                    
					//CKEDITOR.instances['melhoria'].setData(melhoria)		
				})

			})  
			CKEDITOR.instances['melhoria'].setData(melhoria)
			CKEDITOR.instances['recomendacoes'].setData(recomendacoes)
			CKEDITOR.instances['manchete'].setData(manchete)				            
			// final realizar as buscas apartir do clicar do botão grupo/item
			// exibir os anexos		
	}	
	// realizar as buscas a partir do clicar do botão grupo/item
	function dbresultadoinspecao(numinspecao,grp,itm,respdb,codunid){
			//alert('resp linha 1806 function dbresultadoinspecao ==> numinspecao: '+numinspecao+'Grupo: '+grp+' item: '+itm+' respdb: '+respdb+' codunid:'+codunid)		
			//busca através do cfc
			axios.get("CFC/avaliargrupoitem.cfc",{
				params: {
				method: "dbgrpitmresultadoinspecao",
				numinspecao: numinspecao,
				grupo: grp,
				item: itm
				}
			})
			.then(data =>{
				var vlr_ini = data.data.indexOf("COLUMNS");
				var vlr_fin = data.data.length
				vlr_ini = (vlr_ini - 2);
				// console.log('valor inicial: ' + vlr_fin);
				const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
				//console.log(json);
				//	SELECT RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_Comentario, RIP_Recomendacoes, RIP_Manchete, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem
				//      	   0         1            2            3                4                 5                6                  7               8    
				const dados = json.DATA
				//$("#reincidente").hide()
				dados.map((ret) => {
					//alert('itnprerelato : '+ret[2])
					//alert('linha 1828  ret[7]: '+ret[7])
					$('#frmreincGrup').val(0)
					$("#frmfalta").val(ret[0].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#frmsobra").val(ret[1].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#frmemrisco").val(ret[2].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#dbfrmfalta").val(ret[0].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#dbfrmsobra").val(ret[1].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					$("#dbfrmemrisco").val(ret[2].toLocaleString('pt-br', {minimumFractionDigits: 2}))
					//alert('prerelato: '+ret[3])
					$("#melhoria").val(ret[3])
					$("#recomendacoes").val(ret[4])
					$("#manchete").val(ret[5])			
					//alert('tamanho: '+ret[6].length)
					$("#frmreincInsp").val(ret[6])
					$("#frmreincGrup").val(ret[7])
					$("#frmreincItem").val(ret[8])
					let riprecomendacao = $("#riprecomendacao").val()
					if(ret[7] != 0 && respdb == 'N' && riprecomendacao != 'S'){
						$("#reincidente").show(500)
						$('.botaorevereinc').show(500) 
						$('.botaomostrareinc').show(500)
					}	
					CKEDITOR.instances['melhoria'].setData(melhoria)	
					CKEDITOR.instances['recomendacoes'].setData(recomendacoes)	
					CKEDITOR.instances['manchete'].setData(manchete)									
				})
			})  
			CKEDITOR.instances['melhoria'].setData(melhoria)
			CKEDITOR.instances['recomendacoes'].setData(recomendacoes)
			CKEDITOR.instances['manchete'].setData(manchete)				            
			// final realizar as buscas apartir do clicar do botão grupo/item
			// exibir os anexos				
	}
	//==============================	
	function exibiranexos(){
		// Inicial busca por anexos
		$("#tableanexo").hide() 
		let nomeanexo = ''
		codunid = $("#codunidade").val()
		let numinspecao = $('#numinspecao').val()
		let grp = $("#grpsel").val()
		let itm = $("#itmsel").val()
		axios.get("CFC/avaliargrupoitem.cfc",{
			params: {
			method: "anexos",
			numaval: numinspecao,
			codunid: codunid,
			grupo: grp,
			item: itm
			}
		})
		.then(data =>{
			let ordem = 0
			let numreg = 0
			let seletor = ''
			let urlabr = ''
			let urlexc = ''
			let nomearq = ''
			let posicao = 0
			let tab = '<table class="table table-bordered table-hover">'
			tab += '<thead>'
			tab += '<tr>'
			tab +=  '<th scope="col"><h5>Ordem</h5></th>'
			tab +=  '<th scope="col"><h5>Nome</h5></th>'
			tab +=  '<th scope="col" colspan="2"><h5>Opções</h5></th>'
			tab += '</tr>'
			tab += '</thead>'
			tab += '<tbody>'
			var vlr_ini = data.data.indexOf("COLUMNS")
			var vlr_fin = data.data.length
			vlr_ini = (vlr_ini - 2);
			const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
			const dados = json.DATA;
			//Ane_Caminho,Ane_Codigo
			numreg = dados.length
			dados.map((ret) => {
				ordem++
				seletor = 'disabled'
				url = 'href=abrir_pdf_act.cfm?arquivo='+ret[0]
				posicao = ret[0].lastIndexOf('\\')
				posicao++
				nomearq = ret[0].substring(posicao, url.length)
				tab += '<tr>'
					tab += '<td align="center"><label>'+ordem+'º</label></td>'
					tab += '<td><label>'+nomearq+'</label></td>'
					tab += '<td align="center"><a '+url+' target="_blank"><label class="lblbtn">Abrir</label></td></a>'
					url = 'href=itens_inspetores_avaliacaov2.cfm?acao=excluiranexo&anecodigo='+ret[1]+'&numinspecao='+numinspecao+'&unid='+codunid+'&grp='+grp+'&itm='+itm
					let anecodigo = ret[1]
					if (ordem == numreg){
						tab += '<td align="center"'+seletor+'><div onclick="excluiranexo('+anecodigo+')"><label class="lblbtn" id="excluiranexo">Excluir</label></div></td>'
						} else {tab += '<td align="center"><label></label></td>'}
					/*						
					if (ordem == numreg){
						tab += '<td align="center"'+seletor+'><a '+url+' target="_self"><label class="lblbtn" id="excluiranexo">Excluir</label></td></a>'
						} else {tab += '<td align="center"><label></label></td>'}	
					*/		                                
				tab += '</tr>'
			})

			tab += '</tbody>'
			tab += '</table>'    
			if(ordem != 0){
				$("#tableanexo").html(tab)
				$("#tableanexo").show(500)
			}          
		}) 
		// Final busca por anexos		
	}

	$('.box').on( "mouseenter", function() {	 
		let grpsel = $("#grpsel").val()
		if (grpsel != ''){return false}
		$("#blocoreincidentes").hide()
		$("#blocotmpantes").hide()
		grp = $(this).attr("grp")
		grpdesc = $(this).attr("grpdesc")
		itm = $(this).attr("itm")
		itmdesc = $(this).attr("itmdesc")
		title = $(this).attr("title")
		nomeinsp = $(this).attr("nomeinsp")
		pontuacao = $(this).attr("pontuacao")
		classificacao = $(this).attr("classificacao")
		$('#grupotmp').html('<h5>Grupo: '+grp+'</h5>')
		$('#itemtmp').html('<h5>Item: '+itm+'</h5>')
		$('#ptoclassiftmp').html('<h5>Pontuação/Classificação</h5><small>'+pontuacao+' - </small><small>'+classificacao+'</small>')
		$('#statustmp').html('<h5>Status:</h5><small>'+title+'</small>')
		$('#nomeinsptmp').html('<h5>Avaliado por :</h5><small>'+nomeinsp+'</small>')
		$('#grupodesctmp').html('<small>'+grpdesc+'</small>')
		$('#itemdesctmp').html('<small>'+itmdesc+'</small>')
		$("#blocotmp").show(500)
    })	

	$('.box' ).on('mouseleave', function() {
		//$("#blocotmpantes").hide()
		$("#blocotmp").hide()
	})

	$('#selInspecoes').change(function(){   
		//aguarde()
		var url = $(this).val()
		//alert('url: '+url)
		if (url != '') { 
			window.open(url, '_Self')
		}else{
			$(".auxiliar").hide()
			$(".navegacao").hide()
			$(".corpoavaliacao").hide()
			$(".rodape").hide()
		}
    })	
	
	//***************************************************
	// Inicial   Salvar o grupo/item
	//***************************************************
	$('.btnsalvar').click(function(){
		let tipoavaliacao = $('#avalitem').val()
		//controle - 01 não salvar avaliação tipo = A
		if (tipoavaliacao == 'A'){
			alert('Inspetor(a), selecione o tipo de avaliação para o grupo/item')
			$('#avalitem').focus()
			return false
		}

		let melhoria = CKEDITOR.instances.melhoria.getData()
		melhoria = melhoria.replace(/\s/g, '')

		var recomedar = CKEDITOR.instances.recomendacoes.getData() 
		recomedar = recomedar.replace(/\s/g, '')

		let codunid = $("#codunidade").val()
		let numinsp = $('#numinspecao').val()
		let grp = $("#grpsel").val()
		let itm = $("#itmsel").val()
		if (melhoria.length < 100 && tipoavaliacao == 'C')
		{
			alert('Inspetor(a), para avaliação "CONFORME", o campo "Situação Encontrada" deve ser preenchido com, pelo menos, 100(cem) caracteres!')
			$('#melhoria').focus()
			return false
		}

		if (melhoria.length < 100 && tipoavaliacao == 'V' && grp != 500 ) 
		{
			alert('Inspetor(a), para avaliação "NÃO VERIFICADO", o campo "Situação Encontrada" deve conter a justificativa com, no mínimo, 100(cem) caracteres!')
			$('#melhoria').focus()
			return false
		}	

		if (tipoavaliacao == 'N'){
			if ($('#manchete').val() =='')
			{
				alert('Inspetor(a), informar o campo Manchete')
				$('#manchete').focus()
				return false
			}

			if (melhoria.length < 100 || recomedar.length < 100)
			{
				alert('Inspetor(a), para avaliação "NÃO CONFORME", o campo "Situação Encontrada e/ou Orientações" deve conter, no mínimo, 100 caracteres')
				$('#melhoria').focus()
				return false
			}
			let potencvlr = $("#potencvlr").val()
			if(potencvlr == 'S'){
				let impactarfalta = 'N'
				let impactarsobra = 'N'
				let impactarrisco = 'N'
				let intimpactartipos = $("#intimpactartipos").val()	
				var arr = intimpactartipos.split(',')
				$.each( arr, function( i, val ) {
					if(i == 0){
						impactarfalta = val
					}
					if(i == 1){
						impactarsobra = val
					}
					if(i == 2){
						impactarrisco = val
					}
				})

				if(impactarfalta == 'F'){
					let vlrfalta = $("#frmfalta").val()
					$("#impactarfalta").val('F')
					if(vlrfalta == '0,00'){
						alert('Inspetor(a), informar valor no campo Estimado a Recuperar(R$)')
						$('#frmfalta').focus()
						return false
					}
				}
				if(impactarsobra == 'S'){
					let vlrsobra = $("#frmsobra").val()
					$("#impactarsobra").val('S')
					let cdfrmsobra = $("#cdfrmsobra").val()
					//$("#cdfrmsobrasn").val('N')
					if(vlrsobra == '0,00' && cdfrmsobra == 'on'){
						$("#cdfrmsobrasn").val('S')
						alert('Inspetor(a), informar valor no campo Estimado Não Planejado/Extrapolado/Sobra:(R$)')
						$('#frmsobra').focus()
						return false
					}
				}
				if(impactarrisco == 'R'){
					let vlrrisco = $("#frmemrisco").val()
					$("#impactarrisco").val('R')
					let cdfrmemrisco = $("#cdfrmemrisco").val()
					//$("#cdfrmemriscosn").val('N')
					if(vlrrisco == '0,00' && cdfrmemrisco == 'on'){
						$("#cdfrmemriscosn").val('S')
						alert('Inspetor(a), informar valor no campo Estimado em Risco ou Envolvido(R$)')
						$('#frmemrisco').focus()
						return false
					}
				}				
			}
		}

		if ($('#nci').val() == 'S'){
			// controle de dados do N.SEI da NCI
			var nsnci = $('#frmnumseinci').val() 
			if (nsnci.length != 20 || nsnci ==''){		
				alert('Inspetor(a), N° SEI inválido:  (ex. 99999.999999/9999-99)');
				$('#frmnumseinci').focus()
				return false;
			}
		}
		$('#acao').val('salvargrpitm')	
		$('#formx').submit()	
	})
			

	CKEDITOR.replace('melhoria', {
      // Define the toolbar groups as it is a more accessible solution.
	  width: '1085',
		height: 350,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
		]
      // Remove the redundant buttons from toolbar groups defined above.
      //removeButtons: 'Strike,Subscript,Superscript,Specialchar,PasteFromWord'
    });
	CKEDITOR.replace('recomendacoes', {
		width: '1085',
		height: 100,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
		]
    });	
	CKEDITOR.replace('ripmelhoriareinc', {
		width: '1050',
		height: 350,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			/*
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
			*/
		]
		
    });	
	
	CKEDITOR.replace('riprecomendacaoreinc', {
		width: '1050',
		height: 100,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			/*
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
			*/
		]
    });
	CKEDITOR.replace('melhoriantes', {
		width: '1050',
		height: 350,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			/*
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
			*/
		]
		
    });	
	CKEDITOR.replace('recomendacoesantes', {
		width: '1050',
		height: 100,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			/*
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
			*/
		]
    });	
	CKEDITOR.replace('melhoriareinc01', {
		width: '1050',
		height: 120,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			/*
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
			*/
		]
    });	
	CKEDITOR.replace('melhoriareinc02', {
		width: '1050',
		height: 120,
		removePlugins: 'scayt',
		disableNativeSpellChecker: false,
		toolbar: [
			/*
			['Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
			*/
		]
    });	
		
</script>
</html>