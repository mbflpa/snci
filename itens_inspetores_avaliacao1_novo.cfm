<cfprocessingdirective pageEncoding ="utf-8"> 
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>   

<cfset houveProcSN = 'N'>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email 
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>

<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
 
 <cfif (grpacesso neq 'GESTORES') and (grpacesso neq 'DESENVOLVEDORES') and (grpacesso neq 'GESTORMASTER') and (grpacesso neq 'INSPETORES')>
  <cfinclude template="aviso_sessao_encerrada.htm">
  <cfabort>  
</cfif>                          

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email
</cfquery>

<!--- buscar pela decisao de reincidencia --->
<cfif isDefined("Form.acao") And (#Form.acao# eq 'reincidencia')>
	<cflocation url = "itens_inspetores_reincidencia.cfm?nunid=#Form.unid#&ninsp=#Form.ninsp#&ngrup=#Form.ngrup#&nitem=#Form.nitem#&itnreincidentes=#itnreincidentes#&grpitmsql=#form.grpitmsql#"> 
</cfif>

<cfif (grpacesso eq 'INSPETORES') or (grpacesso eq 'DESENVOLVEDORES') or (grpacesso eq 'GESTORES')>

  <cfif isDefined("Form.acao") And (Form.acao is 'anexar' Or Form.acao is 'excluir_anexo')>
  	<cfif isDefined("Form.abertura")><cfset Session.E01.abertura = Form.abertura><cfelse><cfset Session.E01.abertura = 'Nao'></cfif>
	<cfif isDefined("Form.processo")><cfset Session.E01.processo = Form.proc_se & Form.proc_num & Form.proc_ano><cfelse><cfset Session.E01.processo = ''></cfif>
	<cfif isDefined("Form.causaprovavel")><cfset Session.E01.causaprovavel = Form.causaprovavel><cfelse><cfset Session.E01.causaprovavel = ''></cfif>
	<cfif isDefined("Form.cbarea")><cfset Session.E01.cbarea = Form.cbarea><cfelse><cfset Session.E01.cbarea = ''></cfif>
	<cfif isDefined("Form.cbdata")><cfset Session.E01.cbdata = Form.cbdata><cfelse><cfset Session.E01.cbdata = ''></cfif>
	<cfif isDefined("Form.cbunid")><cfset Session.E01.cbunid = Form.cbunid><cfelse><cfset Session.E01.cbunid = ''></cfif>
	<cfif isDefined("Form.frmresp")><cfset Session.E01.frmresp = Form.frmresp><cfelse><cfset Session.E01.frmresp = ''></cfif>
	<cfif isDefined("Form.cborgao")><cfset Session.E01.cborgao = Form.cborgao><cfelse><cfset Session.E01.cborgao = ''></cfif>
	<cfif isDefined("Form.avalItem")><cfset Session.E01.avalItem = Form.avalItem><cfelse><cfset Session.E01.avalItem = ''></cfif>
	<cfif isDefined("Form.dtfim")><cfset Session.E01.dtfim = Form.dtfim><cfelse><cfset Session.E01.dtfim = ''></cfif>
	<cfif isDefined("Form.dtinic")><cfset Session.E01.dtinic = Form.dtinic><cfelse><cfset Session.E01.dtinic = ''></cfif>
	<cfif isDefined("Form.hreop")><cfset Session.E01.hreop = Form.hreop><cfelse><cfset Session.E01.hreop = ''></cfif>
	<cfif isDefined("Form.hunidade")><cfset Session.E01.hunidade = Form.hunidade><cfelse><cfset Session.E01.hunidade = ''></cfif>
	<cfif isDefined("Form.h_obs")><cfset Session.E01.h_obs = Form.h_obs><cfelse><cfset Session.E01.h_obs = ''></cfif>
	<cfif isDefined("Form.melhoria")><cfset Session.E01.melhoria = Form.melhoria><cfelse><cfset Session.E01.melhoria = ''></cfif>
	<cfif isDefined("Form.recomendacao")><cfset Session.E01.recomendacao = Form.recomendacao><cfelse><cfset Session.E01.recomendacao = ''></cfif>
	<cfif isDefined("Form.ngrup")><cfset Session.E01.ngrup = Form.ngrup><cfelse><cfset Session.E01.ngrup = ''></cfif>
	<cfif isDefined("Form.ninsp")><cfset Session.E01.ninsp = Form.ninsp><cfelse><cfset Session.E01.ninsp = ''></cfif>
	<cfif isDefined("Form.nitem")><cfset Session.E01.nitem = Form.nitem><cfelse><cfset Session.E01.nitem = ''></cfif>
	<cfif isDefined("Form.frmmotivo")><cfset Session.E01.frmmotivo = Form.frmmotivo><cfelse><cfset Session.E01.frmmotivo = ''></cfif>
	<cfif isDefined("Form.cbData")><cfset Session.E01.cbData = Form.cbData><cfelse><cfset Session.E01.cbData = ''></cfif>
	<cfif isDefined("Form.reop")><cfset Session.E01.reop = Form.reop><cfelse><cfset Session.E01.reop = ''></cfif>
	<cfif isDefined("Form.unid")><cfset Session.E01.unid = Form.unid><cfelse><cfset Session.E01.unid = ''></cfif>
	<cfif isDefined("Form.modalidade")><cfset Session.E01.modalidade = Form.modalidade><cfelse><cfset Session.E01.modalidade = ''></cfif>
	<cfif isDefined("Form.valor")><cfset Session.E01.valor = Form.valor><cfelse><cfset Session.E01.valor = ''></cfif>
	<cfif isDefined("Form.SE")><cfset Session.E01.SE = Form.SE><cfelse><cfset Session.E01.SE = ''></cfif>
    <cfif isDefined("Form.txtNum_Inspecao")><cfset Session.E01.txtNum_Inspecao = Form.txtNum_Inspecao><cfelse><cfset Session.E01.txtNum_Inspecao = ''></cfif>
	<cfif isDefined("Form.modal")><cfset Session.E01.modal = Form.modal><cfelse><cfset Session.E01.modal = ''></cfif>
	    
		<cfset numncisei = "">
		<!--- <cfif not isDefined("Form.Submit")> --->
		<cfif isDefined("Form.Submit")>
			
	<!--- 	<cfelse>
			<cfset numncisei = ""> --->
			<cfoutput>	
				<cfif isDefined("Form.frmnumseinci") And (#Form.frmnumseinci# neq "")>
					<cfset numncisei = #Form.frmnumseinci#>
				</cfif>
			</cfoutput>
		</cfif> 
	</cfif>

	<cfquery name="qUnidade" datasource="#dsn_inspecao#">
		SELECT Und_descricao FROM Unidades
		WHERE UND_codigo='#unid#'
	</cfquery>
	
	<cfquery name="qGrupo" datasource="#dsn_inspecao#">
	SELECT Grp_Descricao FROM Grupos_Verificacao WHERE Grp_Codigo = #ngrup# AND Grp_Ano =Right('#ninsp#',4)
	</cfquery>

	<cfif '#grpacesso#' eq "INSPETORES">
		<!---AO ENTRAR NO ITEM, SE AINDA NÃO TIVER SIDO AVALIADO, SALVA NA TELA RESULTADO_INSPECAO A MATRÍCULA DO AVALIADOR. AO SAIR SEM AVALIAR, ENTRADO NA TELA ANTERIOR--->
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao SET RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#' 
			where  (rtrim(ltrim(RIP_MatricAvaliador)) is null or rtrim(ltrim(RIP_MatricAvaliador)) ='') and RIP_NumInspecao='#ninsp#'  and RIP_NumGrupo = '#ngrup#' and RIP_NumItem ='#nitem#' and RIP_Resposta ='A'
		</cfquery>
	
		<!---Verifica se todos os itens estão sem avaliação para a rotina de alteração da data de início da inspeção--->
		<cfquery datasource="#dsn_inspecao#" name="qSemAvaliacoes">
		   Select RIP_Resposta FROM Resultado_Inspecao
		   where  RIP_NumInspecao='#ninsp#'  and RIP_NumGrupo = '#ngrup#' and RIP_NumItem ='#nitem#' and RIP_Resposta <> 'A'
		</cfquery>
	</cfif>

<!--- <cfif IsDefined("FORM.submit") AND IsDefined("FORM.acao")> --->
<!--- <cfif IsDefined("FORM.submit")> --->

	<!--- 15/03/2023 --->	
	<!--- anexar arquivo --->
	<cfif isDefined("Form.acao") and Form.acao is 'anexar'>
		<cftry>
	
			<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">
	
			<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>
	
			<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
			<!--- O arquivo anexo recebe nome indicando Numero da inspeção, Número da unidade, Número do grupo e número do item ao qual está vinculado --->
	
			<cfset destino = cffile.serverdirectory & '\' & Form.ninsp & '_' & data & '_' & right(CGI.REMOTE_USER,8) & '_' & Form.ngrup & '_' & Form.nitem & '.pdf'>
	
	
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
			<!---  Gilvan em 11/03/2024 --->
			<cfset aux_melhoria = CHR(13) & Form.melhoria>
			<cfset aux_recomend = CHR(13) & FORM.recomendacao>	
			<cfset auxfrmfalta = '0.0'>
			<cfset auxfrmsobra = '0.0'>
			<cfset auxfrmemrisco = '0.0'>
			<cfif FORM.frmimpactofin eq 'S' and (FORM.avalItem eq 'N')>
				<cfset auxfrmfalta = Replace(FORM.frmfalta,'.','','All')>
				<cfset auxfrmfalta = Replace(auxfrmfalta,',','.','All')>
				<cfset auxfrmsobra = Replace(FORM.frmsobra,'.','','All')>
				<cfset auxfrmsobra = Replace(auxfrmsobra,',','.','All')>				
				<cfset auxfrmemrisco = Replace(FORM.frmemrisco,'.','','All')>
				<cfset auxfrmemrisco = Replace(auxfrmemrisco,',','.','All')>
			</cfif> 
			<cfset RIPReincInspecao = ''>
			<cfset RIPReincGrupo = 0>
			<cfset RIPReincItem = 0>
			<cfif FORM.avalItem eq 'N' and IsDefined("FORM.frmreincInsp") and form.frmrsIncidencia neq 0>
				<cfset RIPReincInspecao = '#FORM.frmreincInsp#'>
				<cfset RIPReincGrupo = #FORM.frmreincGrup#>
				<cfset RIPReincItem =  #FORM.frmreincItem#>
			</cfif>					
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Resultado_Inspecao SET
				RIP_Comentario = '#aux_melhoria#',
				RIP_Recomendacoes='#aux_recomend#',
				RIP_Falta= #auxfrmfalta#,
				RIP_Sobra=#auxfrmsobra#,
				RIP_EmRisco=#auxfrmemrisco#,
				RIP_ReincInspecao = '#RIPReincInspecao#',
				RIP_ReincGrupo = #RIPReincGrupo#,
				RIP_ReincItem = #RIPReincItem#,
				RIP_UserName = '#CGI.REMOTE_USER#',
				RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#',
				RIP_DtUltAtu = CONVERT(char, GETDATE(), 120),
				RIP_Resposta ='#FORM.avalItem#'									
		  		WHERE 
				RIP_Unidade='#FORM.unid#' AND 
				RIP_NumInspecao='#FORM.ninsp#' AND 
				RIP_NumGrupo=#FORM.ngrup# AND 
				RIP_NumItem=#FORM.nitem#
			</cfquery>
			<!---	==================  --->		 
	
		   <cfcatch type="any">
				<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação.\n\nO campo "Arquivo" Não pode estar vazio.\n\nSelecione um arquivo no formato "PDF".\n\nAtenção! As informações incluídas anteriormente foram salvas!'>
				<script>
					alert('<cfoutput>#mensagem#</cfoutput>');
				</script>
		   </cfcatch>
		 </cftry>
    </cfif> 
	<!--- final anexar --->
  <!--- Excluir anexo --->

  <cfif isDefined("Form.acao") and Form.acao is 'excluir_anexo'>
 
	  <!--- Verificar se anexo existe --->
		 <cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos
			WHERE Ane_Codigo = #form.vCodigo#
		 </cfquery>

		 <cfif qAnexos.recordCount Neq 0>

			<!--- Exluindo arquivo do diretório de Anexos --->
			<cfif FileExists(qAnexos.Ane_Caminho)>
				<cffile action="delete" file="#qAnexos.Ane_Caminho#">
			</cfif>

			<!--- Excluindo anexo do banco de dados --->

			<cfquery datasource="#dsn_inspecao#">
			  DELETE FROM Anexos
			  WHERE  Ane_Codigo = #form.vCodigo#
			</cfquery>
<!---  Gilvan em 11/03/2024 --->
			<cfset aux_melhoria = CHR(13) & Form.melhoria>
			<cfset aux_recomend = CHR(13) & FORM.recomendacao>	
			<cfset auxfrmfalta = '0.0'>
			<cfset auxfrmsobra = '0.0'>
			<cfset auxfrmemrisco = '0.0'>
			<cfif FORM.frmimpactofin eq 'S' and (FORM.avalItem eq 'N')>
				<cfset auxfrmfalta = Replace(FORM.frmfalta,'.','','All')>
				<cfset auxfrmfalta = Replace(auxfrmfalta,',','.','All')>
				<cfset auxfrmsobra = Replace(FORM.frmsobra,'.','','All')>
				<cfset auxfrmsobra = Replace(auxfrmsobra,',','.','All')>				
				<cfset auxfrmemrisco = Replace(FORM.frmemrisco,'.','','All')>
				<cfset auxfrmemrisco = Replace(auxfrmemrisco,',','.','All')>
			</cfif> 
			<cfset RIPReincInspecao = ''>
			<cfset RIPReincGrupo = 0>
			<cfset RIPReincItem = 0>
			<cfif FORM.avalItem eq 'N' and IsDefined("FORM.frmreincInsp") and form.frmrsIncidencia neq 0>
				<cfset RIPReincInspecao = '#FORM.frmreincInsp#'>
				<cfset RIPReincGrupo = #FORM.frmreincGrup#>
				<cfset RIPReincItem =  #FORM.frmreincItem#>
			</cfif>					
			<cfquery datasource="#dsn_inspecao#">
				UPDATE Resultado_Inspecao SET
				RIP_Comentario = '#aux_melhoria#',
				RIP_Recomendacoes='#aux_recomend#',
				RIP_Falta= #auxfrmfalta#,
				RIP_Sobra=#auxfrmsobra#,
				RIP_EmRisco=#auxfrmemrisco#,
				RIP_ReincInspecao = '#RIPReincInspecao#',
				RIP_ReincGrupo = #RIPReincGrupo#,
				RIP_ReincItem = #RIPReincItem#,
				RIP_UserName = '#CGI.REMOTE_USER#',
				RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#',
				RIP_DtUltAtu = CONVERT(char, GETDATE(), 120),
				RIP_Resposta ='#FORM.avalItem#'									
		  		WHERE 
				RIP_Unidade='#FORM.unid#' AND 
				RIP_NumInspecao='#FORM.ninsp#' AND 
				RIP_NumGrupo=#FORM.ngrup# AND 
				RIP_NumItem=#FORM.nitem#
			</cfquery>
			<!---	==================  --->				

		 </cfif>
  </cfif>  
  <!--- final excluir anexo --->
<!--- 15/03/2023 --->	
  	<cfif isDefined("Form.acao") And (#Form.acao# eq 'Salvar')>
		<!---  <cfoutput>
		FORM.frmauxvlr: #FORM.frmauxvlr#<br>
		FORM.avalItem : #FORM.avalItem#<br>
				RIP_ReincInspecao: #FORM.frmreincInsp#<br>
				RIP_ReincGrupo : #FORM.frmreincGrup#<br>
				RIP_ReincItem : #FORM.frmreincItem#	<br>
		</cfoutput>			
		<cfset gil = gil>	 ---> 
	  <cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao SET
	  <cfif IsDefined("FORM.melhoria") AND FORM.avalItem neq 'E'>
		RIP_Comentario=
		  <cfset aux_mel = CHR(13) & Form.melhoria>
		  '#aux_mel#'
		<cfelse>
			RIP_Comentario='.'
	   </cfif>
	   <cfif IsDefined("FORM.recomendacao") AND FORM.avalItem eq 'N'>
		 , RIP_Recomendacoes=
		  <cfset aux_recom = CHR(13) & FORM.recomendacao>
		  '#aux_recom#'
		 <cfelse>
		 , RIP_Recomendacoes=''		  
		</cfif>
		<cfset auxfrmfalta = '0.0'>
		<cfset auxfrmsobra = '0.0'>
		<cfset auxfrmemrisco = '0.0'>
		<cfif  FORM.frmimpactofin eq 'S' and FORM.avalItem eq 'N'>
			<cfset auxfrmfalta = Replace(FORM.frmfalta,'.','','All')>
			<cfset auxfrmfalta = Replace(auxfrmfalta,',','.','All')>
			<cfset auxfrmsobra = Replace(FORM.frmsobra,'.','','All')>
			<cfset auxfrmsobra = Replace(auxfrmsobra,',','.','All')>			
			<cfset auxfrmemrisco = Replace(FORM.frmemrisco,'.','','All')>
			<cfset auxfrmemrisco = Replace(auxfrmemrisco,',','.','All')>
		</cfif>			
		, RIP_Falta= #auxfrmfalta#
		, RIP_Sobra=#auxfrmsobra#
		, RIP_EmRisco=#auxfrmemrisco#
		
		<cfif FORM.avalItem eq 'N' and IsDefined("FORM.frmreincInsp") and form.frmrsIncidencia neq 0>
			, RIP_ReincInspecao = '#FORM.frmreincInsp#'
			, RIP_ReincGrupo = #FORM.frmreincGrup#
			, RIP_ReincItem = #FORM.frmreincItem#	
 		<cfelse>
			, RIP_ReincInspecao = ''
			, RIP_ReincGrupo = 0
			, RIP_ReincItem = 0	 
		</cfif>
			, RIP_UserName = '#CGI.REMOTE_USER#'
			, RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
			, RIP_DtUltAtu = CONVERT(char, GETDATE(), 120)
			, RIP_Resposta ='#FORM.avalItem#'
		<cfquery name="qRecomendacao" datasource="#dsn_inspecao#">
		SELECT RIP_Recomendacao, RIP_Critica_Inspetor FROM Resultado_Inspecao WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
		</cfquery>
		
		<cfif Form.acao is 'Salvar' and '#qRecomendacao.RIP_Recomendacao#' eq 'S' and '#trim(qRecomendacao.RIP_Critica_Inspetor)#' neq ''>
		, RIP_Recomendacao = 'R'
		</cfif>
		  
		<!--- N° SEI da NCI --->
		<cfset aux_sei_nci = "">
			, RIP_NCISEI =
		<cfif IsDefined("FORM.nci") AND FORM.nci EQ "S">
		<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, a fim de evitar erros em instruções SQL --->
		  <cfset aux_sei_nci = Trim(FORM.frmnumseinci)>
		  <cfset aux_sei_nci = Replace(aux_sei_nci,'.','',"All")>
		  <cfset aux_sei_nci = Replace(aux_sei_nci,'/','','All')>
		  <cfset aux_sei_nci = Replace(aux_sei_nci,'-','','All')>
		    '#aux_sei_nci#'
		<cfelse>
		    '#aux_sei_nci#'
		</cfif>
		<cfif grpacesso eq 'GESTORES'>
		, RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
		, RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
		</cfif>	  		
		  <!---Para a propagação da avalição quando FORM.propagaAval tiversido definido como sim e a avaliação for Nao executa--->
		  <cfif IsDefined("FORM.propagaAval") and '#FORM.propagaAval#' eq 's' and '#FORM.avalItem#' eq 'E'>
			 WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_Resposta ='A'
		  <cfelse>
			WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
		  </cfif>
	    </cfquery>		

		<!--- Exclusão de todos os anexos para avaliação diferente de N - Não Conforme --->
		<cfif FORM.avalItem neq 'N'>
			<cfquery datasource="#dsn_inspecao#">
			  DELETE FROM Anexos
			  WHERE  Ane_Unidade = '#form.unid#' and Ane_NumInspecao = '#FORM.ninsp#' AND Ane_NumGrupo=#FORM.ngrup# AND Ane_NumItem=#FORM.nitem#
			</cfquery>	
			<cfquery datasource="#dsn_inspecao#">
				delete from Andamento where And_NumInspecao='#FORM.Ninsp#' and And_Unidade='#FORM.unid#' and And_NumGrupo=#FORM.Ngrup# and And_NumItem=#FORM.Nitem#
			</cfquery>

			<cfquery datasource="#dsn_inspecao#">
				delete from ParecerUnidade where Pos_Inspecao='#FORM.Ninsp#' and Pos_Unidade='#FORM.unid#' and Pos_NumGrupo=#FORM.Ngrup# and Pos_NumItem=#FORM.Nitem#
			</cfquery>	
		</cfif>	
	</cfif> 
	<cfif isDefined("Form.acao") And (#Form.acao# eq 'Salvar')>
         <!---    Se nenhum item tiver sido avaliado salva a data atual no inicio da inspecao na tabela Inspecao       --->
		 <cfif qSemAvaliacoes.recordcount eq 0>
			<cfquery datasource="#dsn_inspecao#">
			  UPDATE Inspecao SET INP_DtEncerramento = CONVERT(char, GETDATE(), 102)
		      WHERE INP_Unidade = '#FORM.unid#' and INP_NumInspecao = '#FORM.ninsp#'
			</cfquery>
		 </cfif>

          <!---Ao salvar, se o inspetor Nao inseriu uma resposta ao gestor, o form de resposta é aberto          --->
	      <cfquery name="qRecomendacao" datasource="#dsn_inspecao#">
	        SELECT RIP_Recomendacao, RIP_Critica_Inspetor, Und_TipoUnidade
			FROM Resultado_Inspecao 
			INNER JOIN Unidades ON RIP_Unidade = Und_Codigo
			WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
          </cfquery>
           
		  <cfif Form.acao is 'Salvar' and '#qRecomendacao.RIP_Recomendacao#' eq 'S' and '#trim(qRecomendacao.RIP_Critica_Inspetor)#' eq ''>
		       <script>
			       function abrirPopup(url,w,h) {
						var newW = w + 100;
						var newH = h + 100;
						var left = (screen.width-newW)/2;
						var top = (screen.height-newH)/2;
						var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',scrollbars=yes');
						newwindow.resizeTo(newW, newH);
						
						//posiciona o popup no centro da tela
						newwindow.moveTo(left, top);
						newwindow.focus();
						
						return false;

					}
			      alert('Antes de salvar este item, salve uma resposta ao gestor.');
				  abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#ninsp#&unid=#FORM.unid#&ngrup=#FORM.ngrup#&nitem=#FORM.nitem#&tpunid=#qRecomendacao.Und_TipoUnidade#&modal=#modal#</cfoutput>',800,600);

			   </script>
			    
		   </cfif>
      <!--- 	Fim da rotina que abre o form de inclusão de resposta ao gestor	 --->
          
		<cfquery datasource="#dsn_inspecao#" name="rsVerificaAvaliador">
			SELECT RIP_MatricAvaliador, RIP_Resposta, RIP_Falta, RIP_Sobra, RIP_EmRisco RIP_REINCINSPECAO FROM Resultado_Inspecao 
			WHERE  (RIP_MatricAvaliador !='' or RIP_MatricAvaliador is not null) and RIP_NumInspecao='#FORM.Ninsp#' 
			And RIP_NumGrupo = '#FORM.Ngrup#' and RIP_NumItem ='#FORM.Nitem#' 
		</cfquery>

		<!--- Verifica se o item era uma reanálise e foi reanalisado--->
		<cfquery name="qRecomendacao" datasource="#dsn_inspecao#">
	        SELECT RIP_Recomendacao, RIP_Falta
			FROM Resultado_Inspecao 
			WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
        </cfquery>


		<cfif '#qRecomendacao.RIP_Recomendacao#' eq 'R' and '#Form.acao#' neq 'anexar' and '#Form.acao#' neq 'excluir_anexo'>
				<!--- 	Verifica se ainda existem itens em reanálise.	 --->
				<cfquery datasource="#dsn_inspecao#" name="rsVerifItensEmReanalise">
						SELECT RIP_Resposta, RIP_Recomendacao, INP_Modalidade
						FROM Resultado_Inspecao 
						INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade =INP_Unidade)
						WHERE  RIP_Recomendacao='S' and RIP_NumInspecao='#FORM.Ninsp#'     
				</cfquery>

				<!--- Dado default para registro no campo Pos_Area --->
					
				<!--- Obter o tipo da Unidade e sua descrição para alimentar o Pos_AreaNome --->
				<cfquery name="rsUnid" datasource="#dsn_inspecao#">
					SELECT Und_Centraliza, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#FORM.unid#'
				</cfquery>
				<!--- Dado default para registro no campo Pos_AreaNome --->
				<cfset posarea_cod = '#FORM.unid#'>
				<cfset posarea_nome = rsUnid.Und_Descricao>
				<!--- Buscar o tipo de TipoUnidade que pertence a resposta do item --->
				<cfquery name="rsItem2" datasource="#dsn_inspecao#">
					SELECT Itn_TipoUnidade, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
					FROM (Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) 
					INNER JOIN Itens_Verificacao ON (Und_TipoUnidade = Itn_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
					WHERE (Itn_Ano = right('#FORM.Ninsp#',4)) and (Itn_NumGrupo = '#FORM.Ngrup#') AND (Itn_NumItem = '#FORM.Nitem#') and (INP_NumInspecao='#FORM.Ninsp#')
				</cfquery>

					
				<!--- Verificara possibilidade de alterar os dados default para Pos_Area e Pos_AreaNome ---> 
				<cfif (len(trim(rsUnid.Und_Centraliza)) neq 0) and (rsItem2.Itn_TipoUnidade eq 9)>
				<!--- AC é Centralizada por CDD? --->
					<cfquery name="rsCDD" datasource="#dsn_inspecao#">
						SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsUnid.Und_Centraliza#'
					</cfquery>
					<cfset posarea_cod = #rsUnid.Und_Centraliza#>
					<cfset posarea_nome = #rsCDD.Und_Descricao#>
				</cfif>
				<!--- Se a valição for Nao conforme, iniciar um insert na tabela parecer unidade --->
				<cfif '#FORM.avalItem#' eq 'N'>
					<!--- inicio classificacao do ponto --->
					<cfset composic = rsItem2.Itn_PTC_Seq>	
					<cfset ItnPontuacao = rsItem2.Itn_Pontuacao>
					<cfset ClasItem_Ponto = ucase(trim(rsitem2.Itn_Classificacao))>
					<!---Início Insere ParecerUnidade --->
					<cfquery name="rsExistePaUn" datasource="#dsn_inspecao#">
						select Pos_Unidade from ParecerUnidade 
						where Pos_Unidade = '#FORM.unid#' and 
						Pos_Inspecao='#FORM.Ninsp#' and 
						Pos_NumGrupo=#FORM.Ngrup# and 
						Pos_NumItem = #FORM.Nitem#
					</cfquery>
					<cfif rsExistePaUn.recordcount lte 0>
						<cfquery datasource="#dsn_inspecao#">
							INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp,Pos_Area, Pos_NomeArea, Pos_NCISEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto) 
							VALUES ('#FORM.unid#', '#FORM.Ninsp#', #FORM.Ngrup#, #FORM.Nitem#, CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 120), '#CGI.REMOTE_USER#', NULL, 0,'#posarea_cod#','#posarea_nome#','#aux_sei_nci#',#ItnPontuacao#,'#ClasItem_Ponto#')
						</cfquery>				
					</cfif>							
					<!---Fim Insere ParecerUnidade --->
				
					<!--- Inserindo dados dados na tabela Andamento --->
					<cfset andparecer = #posarea_cod#  & " --- " & #posarea_nome#>
					<cfquery name="rsExisteAND" datasource="#dsn_inspecao#">
							select And_Unidade 
							from Andamento 
							where And_Unidade = '#FORM.unid#' and 
							And_NumInspecao='#FORM.Ninsp#' and 
							And_NumGrupo=#FORM.Ngrup# 
							and And_NumItem = #FORM.Nitem# 
							and And_Situacao_Resp = 0
					</cfquery>
					<cfif rsExisteAND.recordcount lte 0>
						<cfquery datasource="#dsn_inspecao#">
							insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) 
							values ('#FORM.Ninsp#', '#FORM.unid#', #FORM.Ngrup#, #FORM.Nitem#, #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#, '#CGI.REMOTE_USER#', 0, '000000', '#andparecer#', '#posarea_cod#')
						</cfquery>
					</cfif>
					<!---Fim Insere Andamento --->	
				<cfelse>
					<cfquery datasource="#dsn_inspecao#">
						DELETE FROM Anexos
						WHERE  Ane_Unidade = '#form.unid#' and Ane_NumInspecao = '#FORM.ninsp#' AND Ane_NumGrupo=#FORM.ngrup# AND Ane_NumItem=#FORM.nitem#
					</cfquery>				
					<cfquery datasource="#dsn_inspecao#">
						delete from Andamento where And_NumInspecao='#FORM.Ninsp#' and And_Unidade='#FORM.unid#' and And_NumGrupo=#FORM.Ngrup# and And_NumItem=#FORM.Nitem#
					</cfquery>
					<cfquery datasource="#dsn_inspecao#">
						delete from ParecerUnidade where Pos_Inspecao='#FORM.Ninsp#' and Pos_Unidade='#FORM.unid#' and Pos_NumGrupo=#FORM.Ngrup# and Pos_NumItem=#FORM.Nitem#
					</cfquery>								   
				</cfif> 
				<!---  Se o tem era uma reanálise e Nao existirem mais itens em reanálise, a finalização da verificação é realizada nesta página
				e Nao em itens_inspetores_avaliacao.cfm como acontece para as outras avaliações--->
				<cfif rsVerifItensEmReanalise.recordCount eq 0>
						<!---UPDATE em Inspecao--->
						<cfquery datasource="#dsn_inspecao#" ><!---Inspeções NA = Nao avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluída---> 
							UPDATE Inspecao SET INP_Situacao = 'RA', INP_DtEncerramento =  CONVERT(char, GETDATE(), 102), INP_DtUltAtu =  CONVERT(char, GETDATE(), 120), INP_UserName ='#CGI.REMOTE_USER#'
							WHERE INP_Unidade='#FORM.unid#' AND INP_NumInspecao='#FORM.Ninsp#' 
						</cfquery>
						<!---Fim UPDATE em Inspecao --->
						<cflocation url = "itens_inspetores_avaliacao.cfm" addToken = "no">
				</cfif>
	    </cfif>
		<!--- voltar --->
		<cflocation url = "itens_inspetores_avaliacao.cfm?numInspecao=#form.Ninsp#&Unid=#form.unid#" addToken = "no">		
	</cfif>	

	<cfif isDefined("Session.E01")>
	  <cfset StructClear(Session.E01)>
	</cfif>

<!---</cfif> 
 </cfif> --->
<!--- Visualização de anexos --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">
	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="#qGrupo.Grp_Descricao#">
	<cfparam name="URL.modal" default="#Form.modal#">
	<cfparam name="URL.tpunid" default="#Form.tpunid#">
	<cfparam name="URL.retornosn" default="#Form.retornosn#">
	<cfparam name="URL.restringirSN" default="#Form.frmrestringirsn#">
	<cfparam name="URL.auxvlr" default="#Form.frmauxvlr#">
	<cfparam name="URL.frmsituantes" default="#Form.frmsituantes#">
	<cfparam name="URL.frmdescantes" default="#Form.frmdescantes#">
	<cfparam name="URL.frminspreincidente" default="#Form.frminspreincidente#">
	<cfparam name="URL.frmgruporeincidente" default="#Form.frmgruporeincidente#">
	<cfparam name="URL.frmitemreincidente" default="#Form.frmitemreincidente#">
	<cfparam name="URL.existeanexos" default="#Form.frmexisteanexos#">
	<cfparam name="URL.acao" default="#Form.acao#">
	<cfparam name="URL.itnreincidentes" default="#Form.itnreincidentes#">
	<cfparam name="URL.grpitmsql" default="#Form.grpitmsql#">
<cfelse>
	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="#qGrupo.Grp_Descricao#">
	<cfparam name="URL.modal" default="">
	<cfparam name="URL.tpunid" default="#tpunid#">
	<cfparam name="URL.retornosn" default="">
	<cfparam name="URL.restringirSN" default="">	
	<cfparam name="URL.auxvlr" default="">	
	<cfparam name="URL.frmsituantes" default="">
	<cfparam name="URL.frmdescantes" default="">
	<cfparam name="URL.existeanexos" default=""> 
	<cfparam name="URL.acao" default=""> 
</cfif>
<!---  --->
 <cfset qtdreincidencia = 0>
 <cfset qtdfrmrsSeguir = 0>
 <cfset frmGrprsSeguir = 0>
 <cfset frmItemrsSeguir = 0>
 <cfset anolimit = (year(now()) - 2)>
<cfoutput>
<!--- <cfif tpunid neq 12 and tpunid neq 16 and grpacesso eq 'INSPETORES'> --->
<cfif grpacesso eq 'INSPETORES'>

    <cfset grp=''>
    <cfset itm=''>
    <cfset grpitmsql='Pos_Unidade is null'>
    <cfloop index="index" list="#url.itnreincidentes#">
        <cfset grpitm = Replace(index,'_',',',"All")>
        <cfset grp = left(grpitm,find(",",grpitm)-1)>
        <cfset itm = mid(grpitm,(find(",",grpitm) + 1),len(grpitm))>
        <cfif grpitmsql eq 'Pos_Unidade is null'>
            <cfset grpitmsql = "Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
        <cfelse>
            <cfset grpitmsql = #grpitmsql# & " or Pos_NumGrupo = " & #grp# & " and Pos_NumItem = " & #itm#>
        </cfif>
        <cfset grp=''>
        <cfset itm=''>
    </cfloop> 
	<cfquery name="rsIncidencia" datasource="#dsn_inspecao#">
		SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp, STO_Descricao
		FROM ParecerUnidade 
		INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
		WHERE (Pos_Unidade ='#URL.Unid#' and 
		Pos_Inspecao <> '#URL.Ninsp#' and
		Pos_Situacao_Resp in(1,6,7,17,22,2,4,5,8,20,15,16,18,19,23) AND	RIGHT(Pos_Inspecao,4) >=#anolimit# and (#grpitmsql#))
		order by Pos_Inspecao desc
	</cfquery>

	<cfif rsIncidencia.recordcount gt 0>
		<cfset qtdreincidencia = rsIncidencia.recordcount>
	<cfelse>
		<cfquery name="rsSeguir" datasource="#dsn_inspecao#">
			SELECT Pos_Inspecao, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Situacao_Resp, STO_Descricao
			FROM ParecerUnidade 
			INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
			WHERE (Pos_Unidade ='#URL.Unid#' and 
			Pos_Inspecao <> '#URL.Ninsp#' and
			Pos_Situacao_Resp in(3,25,26,27,29) AND	RIGHT(Pos_Inspecao,4) >=#anolimit# and (#grpitmsql#))
			order by Pos_Inspecao desc
		</cfquery>	
		<cfif rsSeguir.recordcount gt 0>
			<cfset qtdfrmrsSeguir = rsSeguir.Pos_Inspecao>
			<cfset frmGrprsSeguir = rsSeguir.Pos_NumGrupo>
			<cfset frmItemrsSeguir = rsSeguir.Pos_NumItem>
		</cfif>
	</cfif>
</cfif>
</cfoutput>	
<!---  ---> 

<!---Verifica se o item já foi avaliado ou está sendo avaliado--->
<cfquery datasource="#dsn_inspecao#" name="rsVerificaAvaliador">
	SELECT RIP_MatricAvaliador, RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
	WHERE  (RIP_MatricAvaliador !='' or RIP_MatricAvaliador is not null) and RIP_NumInspecao='#URL.Ninsp#' and RIP_NumGrupo = '#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
</cfquery>

<cfif rsVerificaAvaliador.recordcount neq 0 >
	<cfquery datasource="#dsn_inspecao#" name="rsNomeAvaliador">
		SELECT Fun_Matric,RTRIM(LTRIM(Fun_Nome)) AS Fun_Nome FROM Funcionarios WHERE Fun_Matric = '#rsVerificaAvaliador.RIP_MatricAvaliador#'
	</cfquery>
	<cfif rsNomeAvaliador.recordcount neq 0 and '#rsNomeAvaliador.Fun_Matric#' neq '#qAcesso.Usu_Matricula#'  and grpacesso eq 'INSPETORES'>
		<cfif '#rsVerificaAvaliador.RIP_Resposta#' eq 'A'>
		
			<script>
				var avaliador1 = 'Atenção!\n\nEste Item já está sendo avaliado por:\n\n<cfoutput>#rsNomeAvaliador.Fun_Nome# (#rsNomeAvaliador.Fun_Matric#)</cfoutput>';
				alert(avaliador1);
			</script>
		<cfelse>
			<!---Se for um item em Reavaliação--->
			<cfif '#rsVerificaAvaliador.RIP_Recomendacao#' neq 'S'>
				<script>
					var avaliador2 = 'Atenção!\n\nEste Item já foi avaliado por:\n\n<cfoutput>#rsNomeAvaliador.Fun_Nome# (#rsNomeAvaliador.Fun_Matric#)</cfoutput>';
					alert(avaliador2);
				</script>
			</cfif>
		</cfif>
	 </cfif>

</cfif>
<!---Fim da verificação se o item já foi avaliado ou está sendo avaliado--->

	<cfquery datasource="#dsn_inspecao#" name="rsVerificaStatus">
		SELECT RIP_Resposta, Und_TipoUnidade 
		FROM Resultado_Inspecao 
		INNER JOIN Unidades ON RIP_Unidade = Und_Codigo
		WHERE  RIP_NumInspecao='#Ninsp#' and RIP_NumGrupo = '#Ngrup#' and RIP_NumItem ='#Nitem#' 
	</cfquery>


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">


<script type="text/javascript">
 <cfinclude template="mm_menu.js"> 

	var habilitarEditor = true;
    // window.onload = formRecomedacao();

	//abre o form de recomendações se o item estiver em reanálise 
    function formRecomedacao(){
		<cfquery name="qRecomendacao" datasource="#dsn_inspecao#">
			SELECT rtrim(ltrim(RIP_Recomendacao)) as RIP_Recomendacao, RIP_Critica_Inspetor
			FROM Resultado_Inspecao 
			WHERE RIP_Unidade='#url.unid#' AND RIP_NumInspecao='#url.ninsp#' AND RIP_NumGrupo=#url.ngrup# AND RIP_NumItem=#url.nitem#
		</cfquery>
		var recom = <cfoutput>'#qRecomendacao.RIP_Recomendacao#'</cfoutput>
		if(recom == 'S'){
			abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#url.ninsp#&unid=#url.unid#&ngrup=#url.ngrup#&nitem=#url.nitem#&tpunid=#rsVerificaStatus.Und_TipoUnidade#&modal=#modal#</cfoutput>',800,600)
		}
   }   
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
		var opcavalItem = document.form1.avalItem.value;

		if (opcavalItem == 'A') 
		{
			document.getElementById("btnsalvar").disabled = true;			
		}
	//	alert('Tem Impacto? ' + impfin + '  Tem falta? ' + impfalta + '  Tem Sobra? ' + impsobra + '  Tem em Risco? ' + impemrisco);
		if (opcavalItem != 'N') 
		{
			document.form1.frmfalta.value='0,00';
			document.form1.frmsobra.value='0,00';
			document.form1.frmemrisco.value='0,00';
		}
		if (impfin == 'S' && opcavalItem == 'N') 
		{
			document.form1.frmfalta.value = document.form1.sfrmfalta.value;
			document.form1.frmsobra.value = document.form1.sfrmsobra.value;
			document.form1.frmemrisco.value = document.form1.sfrmemrisco.value;
			document.getElementById("btnsalvar").disabled = false;
			window.impactofin.style.visibility = 'visible';
			if (impfalta == 'F') {window.impactofalta.style.visibility = 'visible';}
			if (impsobra == 'S') {window.impactosobra.style.visibility = 'visible';}
			if (impemrisco == 'R') {window.impactoemrisco.style.visibility = 'visible';}
		} 
	}
	//simula maximização redimencionando a página para tamanho da tela.
	top.window.moveTo(0,0);
	if (document.all)
		{ top.window.resizeTo(screen.availWidth,screen.availHeight); }
	else if
		(document.layers || document.getElementById)
	{
	if
		(top.window.outerHeight < screen.availHeight || top.window.outerWidth <
		screen.availWidth)
		{ top.window.outerHeight = top.screen.availHeight;
		top.window.outerWidth = top.screen.availWidth; }
	}


	//impede o retorno pelo botão voltar do navegador (apenas os primeiros cliques)

	function removeBack(){ 
		window.location.hash="nbb";	window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";	window.location.hash=""; 
		window.location.hash="nbb";	window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";	window.location.hash=""; 
		window.location.hash="nbb";	window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";	window.location.hash=""; 
		window.location.hash="nbb";	window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";window.location.hash=""; window.location.hash="nbb";	window.location.hash=""; 
		
		window.onhashchange=function(){window.location.hash="";} 
		}
	removeBack();

	//reinicia o ckeditor para inibir o erro de retornar conteúdo vazio no textarea
	function CKupdate(){
		for ( instance in CKEDITOR.instances )
		CKEDITOR.instances[instance].updateElement();
	}

//==================================
function AlertaOnChange(){
//	if(CKEDITOR.instances.melhoria.getData() != ''){	
//		alert('Atenção! A mudança de status poderá apagar as informações do campo "Situação Encontrada".');
//	}
}

//==================================
function reincremota(z){
//alert(z);
var x='';
var k='';
var y='';
var w=document.form1.db_reincSN.value;

if (w == 'S') {
 x=document.form1.frmreincInsp.value;
 k=document.form1.frmreincGrup.value;
 y=document.form1.frmreincItem.value;
}
//alert(z + '  ' + w + '  ' + document.form1.frmreincInsp.value);
if (z == true) {
	window.reincidA.style.visibility = 'visible';
	window.reincidB.style.visibility = 'visible';
	if (w == 'N') {
		document.getElementById("frmreincInsp").readOnly = false;
		document.getElementById("frmreincGrup").readOnly = false;
		document.getElementById("frmreincItem").readOnly = false;
	}
}	
if ((z == false && w == 'N')) {
	window.reincidA.style.visibility = 'hidden';
	window.reincidB.style.visibility = 'hidden';
	document.getElementById("frmreincInsp").readOnly = true;
	document.getElementById("frmreincGrup").readOnly = true;
	document.getElementById("frmreincItem").readOnly = true;
}
}
//==================================
//---- Função é chamada no momento da abertura da tela
// passagem de parâmetro campo RIP_Resposta
// valores possíveis: A ou C ou V ou E ou N
// obs. diferente de A = reabertura de uma avaliação pelo inspetor
function AvaliacaoOnChange(a){
//alert('AvaliacaoOnChange linha 593 ' + a);
//-------------------------------------------------------
		var frm = document.forms[0];
//-------------------------------------------------------		
		window.reincidA.style.visibility = 'hidden';
		window.reincidB.style.visibility = 'hidden';
//-------------------------------------------------------		
		if (a == 'V' || a == 'E' || a == 'C' || a == 'A'){
			frm.propagaAval.value='n';
			frm.propagaAval.disabled = true;
			frm.procurar.style.display = 'none';
			frm.arquivo.style.display = 'none';
		}	
//alert('linha 599');		
//-----------------------------------
		if (a == 'V' || a == 'E' || a == 'C' || a == 'A'){
			document.getElementById("recomendacao").readOnly = true;
			frm.nci.value='N';
			frm.nci.disabled = true;
			frm.frmnumseinci.value = '';
			window.ncisei.style.visibility = 'hidden';	
			window.reincidA.style.visibility = 'hidden';
			window.reincidB.style.visibility = 'hidden';
		}	
//alert('linha 611');			
//-----------------------------------
		if (a == 'E'){
		document.getElementById("melhoria").readOnly = true;
		}	
//alert('linha 616');		
//-----------------------------------
		if (a != 'A'){
		frm.btnsalvar.disabled = false;
		}			
//alert('linha 621');	
//--------------------------------
		if (a == 'C' ){
			document.getElementById("melhoria").readOnly = false;
			CKEDITOR.instances['melhoria'].setData(frm.ripcomentario.value);
		}	
//alert('linha 627');				
//--------------------------------
		if (a == 'V' ){
			document.getElementById("melhoria").readOnly = false;
			CKEDITOR.instances['melhoria'].setData(frm.ripcomentario.value);
		}	
//alert('linha 633');				
//--------------------------------
		if (a == 'E' ){
			frm.propagaAval.disabled = false;
			frm.procurar.style.display = 'none';
			frm.arquivo.style.display = 'none';
			document.getElementById("melhoria").readOnly = false;
			CKEDITOR.instances['melhoria'].setData('.');
			document.getElementById("melhoria").readOnly = true;
			document.getElementById("recomendacao").readOnly = true;
		}	
//alert('linha 644');						
//-----------------------------------
		if (a == 'N'){
			frm.procurar.style.display = 'block';
			frm.arquivo.style.display = 'block';
			frm.propagaAval.value='n';
			frm.propagaAval.disabled = true;
			if (frm.db_reincSN.value == 'S'){
				window.reincidA.style.visibility = 'visible';
				window.reincidB.style.visibility = 'visible';
			}
			var auxmelhoria = frm.ripcomentario.value;
			var auxrecomendacao = frm.riprecomendacoes.value;
		 
			if (frm.acao.value == 'anexar' || frm.acao.value == 'excluir_anexo' || frm.frmrestringirsn.value == 'S') { 
				auxmelhoria = frm.frmanexoscomentario.value; 
				auxrecomendacao = frm.frmanexosrecomendacao.value;
			}
				
			document.getElementById("melhoria").readOnly = false;
			CKEDITOR.instances['melhoria'].setData(auxmelhoria);
			document.getElementById("recomendacao").readOnly = false;
			CKEDITOR.instances['recomendacao'].setData(auxrecomendacao);
		}
//-----------------------------------		
		<cfoutput>
			var item = '#URL.ngrup#';	
		</cfoutput>
		if((a == 'V' || a == 'E' || a == 'C' || a == 'A') && item!=500){
		//	CKEDITOR.instances['melhoria'].setData('');
		}
	
//alert('linha 674');
habarea(a);			
	}
//==================================
//==================================
// Função utilizada após abertura da tela
//Quando o inspetor faz mudança da avaliação já salva em banco.
//Valores diferente do salvo em banco e ou igual ao existentes em banco
function AvaliacaoOnChangeModelos(a){
//-------------------------------------------------------
	var frm = document.forms[0];
	var ripresposta = frm.ripresposta.value;
//-------------------------------------------------------	

	if (frm.frmrestringirsn.value == 'S') {
	//	ripresposta = frm.frmauxvlr.value;
	}
//	alert('linha 738 avaliacao: ' + a + ' ripresposta: ' + ripresposta);
//-------------------------------------------------------	
		window.reincidA.style.visibility = 'hidden';
		window.reincidB.style.visibility = 'hidden';	
		document.getElementById("btnsalvar").disabled = false;
		document.getElementById("melhoria").readOnly = false;
	    document.getElementById("recomendacao").readOnly = false;
//-------------------------------------------------------	
	if (a == 'V' || a == 'E' || a == 'C' || a == 'A'){
		frm.propagaAval.value='n';
		frm.propagaAval.disabled = true;
		frm.procurar.style.display = 'none';
		frm.arquivo.style.display = 'none';
	}		
//alert('Linha 694');	
//-------------------------------------------------------	
	if (a == 'V' || a == 'E' || a == 'C' || a == 'A'){
//	alert('linha 692');
		document.getElementById("recomendacao").readOnly = false;
		CKEDITOR.instances['recomendacao'].setData('');
	//	document.getElementById("recomendacao").readOnly = true;
		frm.recomendacao.disabled = true;
		frm.nci.value='N';
		frm.nci.disabled = true;
		frm.frmnumseinci.value = '';
		window.ncisei.style.visibility = 'hidden';	
		window.reincidA.style.visibility = 'hidden';
		window.reincidB.style.visibility = 'hidden';
		frm.nci.value='N';
		frm.nci.disabled = true;
	}
//alert('Linha 711');
//-----------------------------------
	if (a == 'E'){
	//	document.getElementById("melhoria").readOnly = true;
	}
//alert('Linha 716');			
//-----------------------------------
	if (a == 'A'){
	//alert(a);
		//frm.btnsalvar.disabled = false;
		document.getElementById("btnsalvar").disabled = true;
		CKEDITOR.instances['melhoria'].setData('');
		CKEDITOR.instances['recomendacao'].setData('');
		//return false;
	}
	
//alert('Linha 726');				
//--------------------------------
	if (a == 'C' ) {
		 //alert(frm.ripcomentariojustif.value);
		document.getElementById("melhoria").readOnly = false;	
		var oportunaprim = ''
	    if (ripresposta == a){
		    oportunaprim = frm.ripcomentario.value;
		}
		
	    if (ripresposta != a && ripresposta != 'C'){
		    oportunaprim = '';
		}	 
			
		if (ripresposta == 'C') {
		// 	oportunaprim = frm.ripcomentariojustif.value;
		}
			CKEDITOR.instances['melhoria'].setData(oportunaprim);
	}	
//alert('Linha 741');	
//--------------------------------
	if (a == 'V' ){
		document.getElementById("melhoria").readOnly = false;	
	    if (ripresposta == a){
		    var oportunaprim = frm.ripcomentario.value
		}
		
	    if (ripresposta != a){
		    var oportunaprim = ''
		}		

		CKEDITOR.instances['melhoria'].setData(oportunaprim);
	}	
//--------------------------------
	if (a == 'E' ){
		frm.propagaAval.disabled = false;
		frm.procurar.style.display = 'none';
		frm.arquivo.style.display = 'none';
		CKEDITOR.instances['melhoria'].setData('.');
	}					
//-----------------------------------
	if (a == 'N'){
		frm.procurar.style.display = 'block';
		frm.arquivo.style.display = 'block';
		frm.propagaAval.value='n';
		frm.propagaAval.disabled = true;
		frm.nci.value='N';
		frm.nci.disabled = false;
		if (frm.db_reincSN.value == 'S'){
			window.reincidA.style.visibility = 'visible';
			window.reincidB.style.visibility = 'visible';
		}
	
	    if (ripresposta == a){
		    var oportunaprim = frm.ripcomentario.value;
			var orientacao = frm.riprecomendacoes.value;
		}
	
	    if (ripresposta != a){
		    var oportunaprim = frm.itnprerelato.value;
			var orientacao = frm.itnorientacaorelato.value;
		
		}
			
		if (frm.acao.value == 'anexar' || frm.acao.value == 'excluir_anexo' || frm.frmrestringirsn.value == 'S') { 
			oportunaprim = frm.frmanexoscomentario.value; 
			orientacao = frm.frmanexosrecomendacao.value;	
		}	
		   
			document.getElementById("melhoria").readOnly = false;
			document.getElementById("recomendacao").readOnly = false; 
			
		if (frm.frmrestringirsn.value != 'S'){
			CKEDITOR.instances['melhoria'].setData(oportunaprim);
			CKEDITOR.instances['recomendacao'].setData(orientacao);
		}
}

//-----------------------------------		
habarea(a);	
	}
//======================================
function habarea(a) {
	if (a == 'A') {
	  CKEDITOR.instances['melhoria'].setReadOnly();
	  CKEDITOR.instances['recomendacao'].setReadOnly();
	}
	if (a == 'C' || a == 'V' || a == 'E' || a == 'N') {
	  CKEDITOR.instances['melhoria'].setReadOnly( false );
	  CKEDITOR.instances['recomendacao'].setReadOnly();
	}
 //-------------------------------------------------------
	 if (a == 'N') {
        document.getElementById("melhoria").readOnly = false;
	    document.getElementById("recomendacao").readOnly = false;
		CKEDITOR.instances['recomendacao'].setReadOnly( false );
	 }
}	
//--------------------------
function avisoreincidencia(a,b,c,d,e,f){
//alert(a + ' ' + b + ' ' + c + ' ' + d);
  var g = b.substring(0,2) + '.' + b.substring(2,6) + '/' + b.substring(6,10)

  if (a == 'C' && d == 'S') {var texto = 'Sr(a). Inspetor(a),\n\nCom base na informação prestada, o item avaliado será reconduzido para CONFORME, tendo em vista que a situação identificada encontra-se em fase de regularização (item ' + e + '.' + f + ' - Relatório: ' + g + ').\nAo salvar o relato as informações sobre conformidade serão automaticamente registradas.';
 // alert(texto);
 // document.form1.avalItem.selectedIndex = 1;
  AvaliacaoOnChangeModelos('C');
  }
  
 if (a == 'N' && d == 'S' && c != 'SOLUCIONADO' && c != 'ENCERRADO') {var texto = 'Sr(a). Inspetor(a),\n\nCom base nas informações prestadas, o item avaliado será mantido como NÃO CONFORME com o agravante de REINCIDÊNCIA(item ' + e + '.' + f + ' - Relatório: ' + g + ').\nAo salvar o relato da Não Conformidade identificada, as informações de Reincidência serão automaticamente registradas.';
// alert(texto);
// document.form1.avalItem.selectedIndex = 0;
 AvaliacaoOnChangeModelos('N');
 }
  alert(texto);
}

//-------------------------	
function rsseguir(a,b,c,d) 
{
//alert(a + ' ' + b  + ' ' + c  + ' ' + d);
		var frm = document.forms[0];
		if (a == 'N' && frm.frmrsSeguir.value != 0)
		{
		var e = b.substring(0,2) + '.' + b.substring(2,6) + '/' + b.substring(6,10)
			alert('Sr(a) Inspetor(a)\n\nO item avaliado será considerado REINCIDENTE em decorrência da Não Conformidade registrada para a unidade no Relatório ' + e + ' item ' + c +'.' + d);
		}
}
//-------------------------	
function reincidencia(a) 
{
//alert('linha 645 ' + a);
		var frm = document.forms[0];
		if (a == 'N' && frm.frmrsIncidencia.value > 0)
		{
			//alert(frm.frmrsIncidencia.value);
			frm.acao.value = 'reincidencia';
			frm.submit();
			//return false;
		}
}
	

//=============================================================
function validarform(){	
	var frm = document.forms[0];
	// ==== critica do botão Salvar ===
//	alert(document.form1.acao.value);
	if (frm.acao.value == 'Salvar')
	{
		document.getElementById("melhoria").readOnly = false;
		document.getElementById("recomendacao").readOnly = false;
		document.getElementById("aguarde").style.visibility = "visible";

		if (frm.acao.value == 'anexar'){
			if(document.getElementById('arquivo').value==""){
				alert('Selecione um arquivo para anexar!');
				document.getElementById('arquivo').focus();
				document.getElementById("aguarde").style.visibility = "hidden";
				return false;
			}   
		} 
	//	alert('Linha 1138');		
		//----------------------------------------------------------------
		var melhor = frm.melhoria.value;
		melhor = melhor.replace(/\s/g, '');
		
		var recomed = frm.recomendacao.value;
		recomed = recomed.replace(/\s/g, '');

		if (frm.avalItem.value =='N' && frm.nci.value == ''){
			alert('Informe se houve NCI!');
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
		}
		//alert('Linha 1153');		
		//----------------------------------------------------------	
	   if (frm.acao.value == 'Salvar' && frm.frmexisteanexos.value == 'S' && frm.avalItem.value !='N'){
			if(confirm('Inspetor(a), Para esta avaliação os arquivos anexos serão removidos automaticamente!\n\nDeseja Continuar?'))
			{
			}else{
			    document.getElementById("aguarde").style.visibility = "hidden";
				return false;
			}
		} 
		//alert('Linha 994');	
		//---------------------------------------------------------------------------------							
		if (frm.nci.value == 'S'){
			// controle de dados do N.SEI da NCI
			var nsnci = document.form1.frmnumseinci.value;
			if (nsnci.length != 20 || nsnci==''){		
				alert('N° SEI inválido:  (ex. 99999.999999/9999-99)');
				document.getElementById("aguarde").style.visibility = "hidden";
				return false;
			}
		}
		//alert('Linha 1005');			
		//---------------------------------------------------------------------------------
		if (frm.acao.value=='anexar'){
			var x=document.form1.nci.value;
			var k=document.form1.frmnumseinci.value;
			if (x == 'Sim' && (k.length != 20 || k =='')){
				alert("N° SEI da Apuração Inválido!:  (ex. 99999.999999/9999-99)");
				document.getElementById("aguarde").style.visibility = "hidden";
				document.form1.frmnumseinci.focus();
				return false;
			}else{
				document.getElementById("aguarde").style.visibility = "hidden";
				//return true;
			}
			
		}
		//alert('Linha 1021');		
		//----------------------------------------------
		var el = document.getElementById('Abrir');
		if (frm.nci.value == 'S' && el==null ){
				alert('Para pontos com Nota de Controle Interno é necessário anexar a NCI.');
				document.getElementById("aguarde").style.visibility = "hidden";
				return false;
		}
		//alert('Linha 1029');
		//----------------------------------------------------
		if (frm.avalItem.value =='A'){
			alert('Avalie o item antes de continuar.');
			document.getElementById("aguarde").style.visibility = "hidden";
			frm.avalItem.focus();
			return false;
		}
		//alert('Linha 1037');		
		//-----------------------------------------------------------			
		if ((melhor.length < 100 || recomed.length < 100 ) && frm.avalItem.value =='N')
		{
			alert('Inspetor(a), para a avaliação "NÃO CONFORME", o campo "Situação Encontrada e/ou Orientações" deve conter, no mínimo, 100 caracteres');
			document.getElementById('arquivo').value='';
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
		}
		//alert('Linha 1046');		
		//-----------------------------------------------------------				
        if ((frm.melhoria.value == '' || frm.recomendacao.value == '') && frm.avalItem.value =='N')
		{
			alert('Inspetor(a), para a avaliação "NÃO CONFORME", o campo "Situação Encontrada e/ou Orientações" deve conter, no mínimo, 100 caracteres');
			document.getElementById('arquivo').value='';
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
		}	
		//alert('Linha 1055');			
		//-------------------------------------------------------------		
		if (melhor.length < 100 && frm.avalItem.value =='C')
		{
			alert('Inspetor(a), para a avaliação "CONFORME", o campo "Situação Encontrada" deve ser preenchido com, pelo menos, 100(cem) caracteres!');
			document.getElementById("melhoria").focus();
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
		}
		//alert('Linha 1065');		
		//---------------------------------------------------------------
		<cfoutput>
			var item = '#URL.ngrup#';	
		</cfoutput>
		if (melhor.length < 100 && (frm.avalItem.value =='V') && item!=500){
			alert('Inspetor(a), para a avaliação "NÃO VERIFICADO", o campo "Situação Encontrada" deve conter a justificativa com, pelo menos, 100(cem) caracteres!');
			document.getElementById("melhoria").focus();
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
		}
		//alert('Linha 1244');		
		//====  Ponto possui impacto financeiro ==========================
		var impactofinSN = frm.frmimpactofin.value;
		var auxavaliacao = frm.avalItem.value;
	
		if (impactofinSN == 'S' && auxavaliacao == 'N')
		{
			var impactoF = frm.frmimpactofalta.value;
			var impactoS = frm.frmimpactosobra.value;
			var impactoR = frm.frmimpactoemrisco.value;
			//alert('impactoF' + impactoF + ' impactoS' + impactoS + ' impactoR' + impactoR);
			var vlrfalta = frm.frmfalta.value;
			var vlrsobra = frm.frmsobra.value;
			var vlremrisco = frm.frmemrisco.value;
			
			if (impactoF == 'F' || impactoS == 'S' || impactoR ==  'R') 
			{
				if (impactoF == 'F' && impactoS == 'S' && impactoR ==  'R') 
				{
					if (vlrfalta == '0,00' && vlrsobra == '0,00' && vlremrisco ==  '0,00') 
					{
						alert ('Sr(a) Inspetor(a), informar valores para Falta(R$) ou Sobra(R$) ou Em Risco(R$)');
						document.getElementById("aguarde").style.visibility = "hidden";
						frm.frmfalta.focus();
						return false;
					}
				}
				if (impactoF == 'F' && impactoS == 'S' && impactoR ==  'N') 
				{
					if (vlrfalta == '0,00' && vlrsobra == '0,00') 
					{
						alert ('Sr(a) Inspetor(a), informar valores para Falta(R$) ou Sobra(R$)');
						document.getElementById("aguarde").style.visibility = "hidden";
						frm.frmfalta.focus();
						return false;
					}
				}
				if (impactoF == 'F' && impactoR == 'R' && impactoS == 'N') 
				{
					if (vlrfalta == '0,00' && vlremrisco == '0,00') 
					{
						alert ('Sr(a) Inspetor(a), informar valores para Falta(R$) ou Em Risco(R$)');
						document.getElementById("aguarde").style.visibility = "hidden";
						frm.frmfalta.focus();
						return false;
					}
				}
				if (impactoS == 'S' && impactoR ==  'R' && impactoF == 'N') 
				{
					if (vlrsobra == '0,00' && vlremrisco == '0,00') 
					{
						alert ('Sr(a) Inspetor(a), informar valores para  Sobra(R$) ou Em Risco(R$)');
						document.getElementById("aguarde").style.visibility = "hidden";
						frm.frmsobra.focus();
						return false;
					}
				}
				if (impactoF == 'F' && impactoS == 'N' && impactoR ==  'N') 
				{
					if (vlrfalta == '0,00') 
					{
						alert ('Sr(a) Inspetor(a), informar valor para Falta(R$)');
						document.getElementById("aguarde").style.visibility = "hidden";
						frm.frmfalta.focus();
						return false;
					}
				}
				if (impactoS == 'S' && impactoF == 'N' && impactoR ==  'N') 
				{
					if (vlrsobra == '0,00') 
					{
						alert ('Sr(a) Inspetor(a), informar valor para Sobra(R$)');
						document.getElementById("aguarde").style.visibility = "hidden";
						frm.frmsobra.focus();
						return false;
					}
				}
				if (impactoR == 'R' && impactoS == 'N' && impactoF == 'N') 
				{
					if (vlremrisco == '0,00') 
					{
						alert ('Sr(a) Inspetor(a), informar valor para Em Risco(R$)');
						document.getElementById("aguarde").style.visibility = "hidden";
						frm.frmemrisco.focus();
						return false;
					}
				}								
			}
		}		
		//alert('Linha 1130');		
		//-------------------------------------------------------------		
		var avaliacao =  document.getElementById('avalItem').options[document.getElementById('avalItem').selectedIndex].innerText;
		var mensConf = 'Você avaliou este Item como "' + avaliacao + '"\nDeseja continuar?';
		
		if (frm.acao.value == 'anexar'){
			if(confirm('Esta ação irá salvar esta avaliação.\nDeseja Continuar?'))
			{
				document.getElementById("melhoria").readOnly = false;
				document.getElementById("recomendacao").readOnly = false;
				if (frm.avalItem.value != 'N'){ document.getElementById("recomendacao").readOnly = true;}
				if (frm.avalItem.value == 'E'){ document.getElementById("melhoria").readOnly = true;}
				if (frm.avalItem.value == 'N')
				{ 
					document.getElementById("melhoria").readOnly = false;
					document.getElementById("recomendacao").readOnly = false;	
				}
			}else{
				document.getElementById("aguarde").style.visibility = "hidden";
				return false;
			}
		}
 	}
}

	//Função que abre uma página em Popup
	function popupPage() {
	<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
	var page = "itens_inspetores_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
	</cfoutput>
	windowprops = "location=no,"
	+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
	window.open(page, "Popup", windowprops);
	}

	function abrirPopup(url,w,h) {
		
		var newW = w + 100;
		var newH = h + 100;
		var left = (screen.width-newW)/2;
		var top = (screen.height-newH)/2;
		var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',scrollbars=yes');
		newwindow.resizeTo(newW, newH);
		
		//posiciona o popup no centro da tela
		newwindow.moveTo(left, top);
		newwindow.focus();
		
		return false;

	}

	function bigImg(x) {
		x.style.height = "30px";
		x.style.width = "30px";
	}

	function normalImg(x) {
		x.style.height = "25px";
		x.style.width = "25px";
	}

	function minImg(x) {
		x.style.height = "20px";
		x.style.width = "20px";
	}

	//funcao que mostra e esconde o hint
	function Hint(objNome, action) {
		//action = 1 -> Esconder
		//action = 2 -> Mover

		if (bIsIE) {
			objHint = document.all[objNome];
		}
		if (bIsNav) {
			objHint = document.getElementById(objNome);
			event = objHint;
		}

		switch (action) {
			case 1: //Esconder
				objHint.style.visibility = "hidden";
				break;
			case 2: //Mover
				objHint.style.visibility = "visible";
				objHint.style.left = xmouse + 15;
				objHint.style.top = ymouse + 15;
				break;
		}

	}

	//===================

	function controleNCI() {
		//alert(document.form1.nci.value);
		//alert(document.form1.frmnumseinci.value);

		var x = document.form1.nci.value;
		var k = document.form1.frmnumseinci.value;
		if (x == 'S' && k.length == 20) {
			document.form1.nseincirel.value = k;
		} else {
			document.form1.nseincirel.value = '';
		}
	}
	//===================
	function mensagemNCI() {
		var x = document.form1.nci.value;
		if (x == 'S') {
			alert('Inspetor, é necessário registrar o N° SEI e anexar a NCI.');
			document.form1.frmnumseinci.focus();
		}
	}

	function hanci() {
		// alert(document.form1.nseincirel.value);
	var x = document.form1.nci.value;
		var k = document.form1.nseincirel.value;
		window.ncisei.style.visibility = 'hidden';
		if (x == 'S') {
			window.ncisei.style.visibility = 'visible';
			document.form1.frmnumseinci.value = document.form1.nseincirel.value;
			if (k.length != 20) {
				// document.form1.frmnumseinci.disabled=true;
			}
		}
	reg_melhoria();		
	AvaliacaoOnChange(document.form1.frmauxvlr.value);
 //	AvaliacaoOnChangeModelos(document.form1.frmauxvlr.value);

	}

	//=================
function reg_melhoria() {

var auxjustfa = document.form1.auxjustificativa.value;
//alert(auxjustfa);
if (auxjustfa.length > 0) 
{
  frm.melhoria.value = auxjustificativa;
  frm.melhoria.disabled = true;
}

}	

</script>
<style>
	
	.cke_top{
		<!---background:#003366; --->
	}
</style>
</style>
	<cfquery name="rsMod" datasource="#dsn_inspecao#">
	SELECT Und_TipoUnidade, Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
	FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
	WHERE Und_Codigo = '#URL.Unid#'
	</cfquery>
  
	<cfset strIDGestor = #URL.Unid#>
	<cfset strNomeGestor = #rsMod.Und_Descricao#>
	<cfset Gestor = '#rsMod.Und_Descricao#'>

   <cfquery name="rsItem" datasource="#dsn_inspecao#">
	SELECT RIP_Unidade,
		   Und_Descricao,
		   Und_TipoUnidade,
		   RIP_NumInspecao,
		   RIP_CodReop,
		   RIP_CodDiretoria,
		   Dir_Descricao,
		   RIP_Resposta,
		   RIP_NumGrupo,
		   Grp_Descricao, 
		   RIP_NumItem, 
		   NIP_DtIniPrev, 
		   Grp_Ano,
		   INP_Modalidade,
		   INP_TNCClassificacao,
		   INP_TNCPontuacao,
		   INP_NCClassificacao,
		   INP_NCPontuacao,		   
		   RIP_CARACTVLR,
		   RIP_FALTA,
		   RIP_SOBRA,
		   RIP_EMRISCO,
		   INP_DTINICINSPECAO,
		   RIP_VALOR,
		   RIP_COMENTARIO,
		   RIP_RECOMENDACOES,
		   RIP_RECOMENDACAO, 
		   RIP_REINCINSPECAO,
		   RIP_REINCGRUPO,
		   RIP_REINCITEM,
		   RIP_Caractvlr,   
		   RIP_NCISEI,
		   Itn_Amostra,
		   Itn_Norma,
		   Itn_Pontuacao,
		   Itn_Classificacao,
		   Itn_PTC_Seq,
		   Itn_PreRelato,
		   Itn_OrientacaoRelato,
		   Itn_Descricao,
		   Itn_Ano, 
		   Itn_ImpactarTipos,		   
		   Pos_ClassificacaoPonto,
		   TNC_ClassifInicio, 
 		   TNC_ClassifAtual
 		   FROM Numera_Inspecao 
			INNER JOIN (((Resultado_Inspecao 
			INNER JOIN Inspecao ON (RIP_NumInspecao =INP_NumInspecao) AND (RIP_Unidade =INP_Unidade)) 
			INNER JOIN Itens_Verificacao ON (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo) AND (convert(char(4),RIP_Ano) = Itn_Ano)) 
			INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo) ON (NIP_NumInspecao =INP_NumInspecao) AND (NIP_Unidade =INP_Unidade)  AND (INP_Modalidade =Itn_Modalidade)
			INNER JOIN Unidades ON RIP_Unidade = Und_Codigo and (Itn_TipoUnidade = Und_TipoUnidade)
			INNER JOIN Diretoria ON RIP_CodDiretoria = Dir_Codigo
			left JOIN  ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)
			left JOIN TNC_Classificacao ON (RIP_NumInspecao = TNC_Avaliacao) AND (RIP_Unidade = TNC_Unidade)
	 WHERE RIP_NumInspecao='#url.Ninsp#' AND Itn_Ano=RIGHT('#url.Ninsp#',4) AND Grp_Ano=RIGHT('#url.Ninsp#',4) and RIP_NumGrupo='#url.Ngrup#' and RIP_NumItem ='#Nitem#'
</cfquery>

 <!--- restrição da situação --->
<cfset restringirSN = 'N'>
<cfset auxvlr = ''>
<cfset auxjustificativa = ''>


<cfset auxvlr = rsItem.RIP_Resposta>
<cfif isDefined("Form.acao") And (Form.acao is 'Anexar' Or Form.acao is 'excluir_anexo')>
 <cfset auxvlr = 'N'>
 <cfset retornosn eq ''>
</cfif> 
<!--- <cfif isDefined('retornosn') And retornosn is 'S'>
    <cfset auxvlr = 'N'>
</cfif> --->

<cfif isdefined('retornosn') and (retornosn eq 'S' or retornosn eq 'N')>
		<cfif listfind('2,4,5,8,20,15,16,19,20,23,1,6,7,17,22,9,10,31,24,32','#frmsituantes#')>
			<cfif retornosn eq 'S'>		
			<cfset restringirSN = 'S'>
			<cfset auxjustificativa = 'Os fatos identificados como Não Conforme foram registrados no relatório anterior : Avaliação: ' & #frminspreincidente# & ' Grupo/Item: ' & #ngrup# & '-' & #nitem# & ' com situação atual em: ' & #frmdescantes#>  
			<cfset Form.melhoria = #auxjustificativa#>  
			<cfset Form.recomendacao = ''>
			<cfset auxvlr = 'C'>
			<cfset auxdescvlr = 'CONFORME'>
			
		</cfif>	
		<cfif retornosn eq 'N'>

			<cfset auxjustificativa = ''> 
			<cfset restringirSN = 'S'>
			<cfset auxvlr = 'N'>
			<cfset auxdescvlr = 'NÃO CONFORME'>		
			<!--- <cfset Form.melhoria = #rsItem.Itn_PreRelato# & '<strong>Ref. Normativa:</strong>' & #Trim(rsItem.Itn_Norma)# & '<p><strong>Possíveis Consequências da Situação Encontrada:</strong>'> --->	
			<cfset Form.melhoria = #rsItem.Itn_PreRelato# & '<strong>Ref. Normativa:</strong>' & #Trim(rsItem.Itn_Norma)#>	
			<cfset Form.recomendacao = #rsItem.Itn_OrientacaoRelato#>	 
		</cfif>	
		<cfelseif listfind('3,29','#frmsituantes#')>
				<cfset restringirSN = 'S'>
				<cfset auxvlr = 'N'>
				<cfset auxdescvlr = 'NÃO CONFORME'>
			<!---	<cfset Form.melhoria = #rsItem.Itn_PreRelato# & '<strong>Ref. Normativa:</strong>' & #Trim(rsItem.Itn_Norma)# & '<p><strong>Possíveis Consequências da Situação Encontrada:</strong>'> --->
				<cfset Form.melhoria = #rsItem.Itn_PreRelato# & '<strong>Ref. Normativa:</strong>' & #Trim(rsItem.Itn_Norma)#>
				<cfset Form.recomendacao = #rsItem.Itn_OrientacaoRelato#>	
			<cfif retornosn eq 'N'>
				<cfset restringirSN = 'N'>
			</cfif>				
		</cfif>	 	
</cfif>	
<!--- <cfoutput>
linha 1380   retornosn: #retornosn# <br>
restringirSN: #restringirSN# <br>
auxvlr: #auxvlr# <br>
</cfoutput> --->

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
	order by Ane_Codigo
  </cfquery>

<cfif rsItem.RIP_REINCINSPECAO neq 0>
		<cfset reincidenteSN = 'S'>
</cfif> 

</head>
	<body  onLoad="exibirvalores();
	CKEDITOR.replace('melhoria', {
		width: '1020',
		height: 200,
		removePlugins: 'scayt',
        disableNativeSpellChecker: false,
		line_height:'1px',
		disableObjectResizing:true,
<!--- 		enterMode:CKEDITOR.ENTER_DIV, ao invés de <p> coloca <div> após enter--->
<!--- 		enterMode:2,forceEnterMode:false,shiftEnterMode:1,  transforma enter em <br> shift+enter <p>--->
		toolbar: [
			[ 'Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find' ],
			['SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'],
			'/',
			['Styles','HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','-','Imagem', '-','Table','-','Maximize'  ]
		]
    });
	CKEDITOR.replace('recomendacao', {
		width: '1020',
		height: 100,
		removePlugins: 'scayt',
        disableNativeSpellChecker: false,
		line_height:'1px',
<!--- 		enterMode:CKEDITOR.ENTER_DIV, ao invés de <p> coloca <div> após enter--->
<!--- 		enterMode:2,forceEnterMode:false,shiftEnterMode:1,  transforma enter em <br> shift+enter <p>--->
		toolbar: [
			[ 'Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find' ],
			['SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize'  ]
		]
			
    });
	 	hanci(); AvaliacaoOnChange(document.form1.frmauxvlr.value); if(document.form1.houveProcSN.value != 'S') {exibe(document.form1.frmResp.value)} else {exibe(24)}; exibe(document.form1.frmResp.value); controleNCI();">
	
		<cfinclude template="cabecalho.cfm">
 <div id="aguarde" name="aguarde" align="center"  style="width:100%;height:130%;top:105px;left:10px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:10000;visibility:hidden;position:absolute;" >		
		<img src="figuras/aguarde.png" width="10%"  border="0" style="position:relative;top:45%"></img>
    </div>

<table width="68%"  align="center" bordercolor="eeeeee">
  <tr>
    <td height="20" colspan="5"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td height="10" colspan="5"><div align="center"><strong class="titulo1">AVALIAÇÃO ITEM</strong></div></td>
  </tr>
  

  <tr>
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <form name="form1" method="post" onSubmit="return validarform()" enctype="multipart/form-data" action="itens_inspetores_avaliacao1_novo.cfm">
<!--- variaveis de formulario --->
	<input type="hidden" id="acao" name="acao" value="<cfoutput>#URL.acao#</cfoutput>">
	<input type="hidden" id="emReanalise" name="emReanalise" value="">
	<input type="hidden" id="anexo" name="anexo" value="">
	<input type="hidden" id="vCausaProvavel" name="vCausaProvavel" value="">
	<input type="hidden" id="vCodigo" name="vCodigo" value="">
	<input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
	<input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
	<input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
	<input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
	<input name="tpunid" id="tpunid" type="hidden"  value="<cfoutput>#URL.tpunid#</cfoutput>">
	<input name="itnreincidentes" id="itnreincidentes" type="hidden"  value="<cfoutput>#itnreincidentes#</cfoutput>">
	<input name="grpitmsql" id="grpitmsql" type="hidden"  value="<cfoutput>#grpitmsql#</cfoutput>">
	
	
<!--- fim variaveis --->
   

 <div style="position:absolute;top:192px;right:157px">
        <a onClick="abrirPopup('itens_inspetores_avaliacao1_ajuda.cfm?<cfoutput>numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#</cfoutput>',800,600)" href="#"
		class="botaoCad" ><img   onmouseover="bigImg(this)" onMouseOut="normalImg(this)"   alt="Ajuda do Item" src="figuras/ajudaItem.png" width="25"   border="0" style="position:absolute;left:0px;top:5px"></img></a>	</div>
    <cfif '#rsItem.RIP_Recomendacao#' eq 'S'>
		<div align="right" style="position:absolute;top:192px;right:230px">
			<a id="idRecomendacoes" onClick="abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#ninsp#&unid=#unid#&ngrup=#ngrup#&nitem=#nitem#&tpunid=#rsItem.Und_TipoUnidade#&modal=#modal#</cfoutput>',800,600)" href="#"
			class="botaoCad" ><img   onmouseover="bigImg(this)" onMouseOut="normalImg(this)"   alt="Recomendações p/ Reanálise do Inspetor" src="figuras/reavaliar.png" width="25"   border="0" style="position:absolute;left:0px;top:5px"></img></a>		</div>
	</cfif>
  <cfoutput>
		
		<input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="#rsItem.Und_TipoUnidade#">
		<cfset falta = trim(Replace(NumberFormat(rsItem.RIP_Falta,999.00),'.',',','All'))> 
		<cfset sobra = trim(Replace(NumberFormat(rsItem.RIP_Sobra,999.00),'.',',','All'))> 
		<cfset emrisco = trim(Replace(NumberFormat(rsItem.RIP_EmRisco,999.00),'.',',','All'))> 

		<input type="hidden" name="sfrmfalta" id="sfrmfalta" value="#falta#">
		<input type="hidden" name="sfrmsobra" id="sfrmsobra" value="#sobra#">
		<input type="hidden" name="sfrmemrisco" id="sfrmemrisco" value="#emrisco#">
		<input type="hidden" id="modal" name="modal" value="#URL.modal#">
		<input type="hidden" id="auxjustificativa" name="auxjustificativa" value="#auxjustificativa#">
		
		<input type="hidden" name="tpunid" id="tpunid" value="#tpunid#">			
		<input type="hidden" name="frmrsIncidencia" id="frmrsIncidencia" value="#qtdreincidencia#">
		<input type="hidden" name="frmrsSeguir" id="frmrsSeguir" value="#qtdfrmrsSeguir#">
	</cfoutput>
<cfoutput>

<!--- <cfset gil = gil> --->
	<tr bgcolor="eeeeee" class="exibir">
<!--- 		<td class="exibir" style="background:transparent;font-size:14px"><STRONG>AVALIAÇÃO:</STRONG></td> --->
		<td bgcolor="eeeeee" class="titulosClaro2"><div align="center"><STRONG>AVALIAÇÃO:</STRONG></div></td>
		<!--- <td width="11"> ---> 
		<td colspan="5"> 
	<select name="avalItem" id="avalItem" class="form" onChange="exibirvalores();reincidencia(this.value);rsseguir(this.value,'#qtdfrmrsSeguir#','#frmGrprsSeguir#','#frmItemrsSeguir#');if (document.form1.acao.value != 'reincidencia') {AvaliacaoOnChangeModelos(this.value)};" style="background:white;font-size:14px"> 			
		<cfif #rsItem.RIP_NumGrupo# eq 500 and #rsItem.RIP_NumItem# eq 1>	
			<option <cfif '#auxvlr#' is "A">selected</cfif>  value="A">---</option>			
			<option <cfif '#auxvlr#' is "N">selected</cfif>  value="N">NÃO CONFORME</option>
			<option <cfif '#auxvlr#' is "V">selected</cfif>  value="V">NÃO VERIFICADO</option>
		<cfelseif restringirSN eq 'S'>
			<cfif auxvlr eq 'C'>
				<option value="C">CONFORME</option>
			</cfif>
			<cfif auxvlr eq 'N'>
				<option value="N">NÃO CONFORME</option>
			</cfif>			
		<cfelse>
			<option <cfif '#auxvlr#' is "A">selected</cfif>  value="A">---</option>				
			<option <cfif '#auxvlr#' is "C">selected</cfif>  value="C">CONFORME</option>
			<option <cfif '#auxvlr#' is "N">selected</cfif>  value="N">NÃO CONFORME</option>
			<option <cfif '#auxvlr#' is "V">selected</cfif>  value="V">NÃO VERIFICADO</option>
			<option <cfif '#auxvlr#' is "E">selected</cfif>  value="E">NÃO EXECUTA</option>
		</cfif>
	</select>	 

		<!---  --->
		<label class="exibir" style="background:transparent;font-size:14px"><STRONG>&nbsp;&nbsp;&nbsp;Para todos os Itens do mesmo Grupo?:</STRONG></label>
		<select name="propagaAval" id="propagaAval" class="form"  style="background:white;font-size:14px" >
			<option  value="n" selected>Nao</option>
			<option  value="s">Sim</option>
		</select>	
		</td>
 </tr>
 </cfoutput>
	  <tr>
	    <td bgcolor="eeeeee" class="exibir">Unidade</td>
	    <td colspan="5" bgcolor="eeeeee"><table width="100%">
          <tr>
            <td width="333"><cfoutput><strong class="exibir">#URL.Unid#</strong> - <strong class="exibir">#rsMOd.Und_Descricao#</strong></cfoutput></td>
            <td width="99"><span class="exibir">Respons&aacute;vel:</span></td>
            <td width="571"><cfoutput><strong class="exibir">#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
          </tr>
        </table></td>
      </tr>
	  
 <tr class="exibir">
   <td width="139" bgcolor="eeeeee" class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              Inspetor
              <cfelse>
              Inspetores
        </cfif>	</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="5" bgcolor="eeeeee">-&nbsp;<cfoutput query="qInspetor"><strong class="exibir">#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
      </tr>

    <tr class="exibir">
      <td bgcolor="eeeeee">Nº Relatório</td>
      <td colspan="5" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ninsp#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In&iacute;cio Inspe&ccedil;&atilde;o &nbsp;<strong class="exibir"><cfoutput>#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></strong></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="eeeeee">Grupo</td>
      <td colspan="5" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Ngrup#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#URL.DGrup#</strong></cfoutput></td>
    </tr>

    <tr class="exibir">
      <td bgcolor="eeeeee">Item</td>
      <td colspan="5" bgcolor="eeeeee"><cfoutput><strong class="exibir">#URL.Nitem#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#rsItem.Itn_Descricao#</strong></cfoutput><cfoutput></cfoutput>        <div align="right"></div>        <cfoutput></cfoutput></td>
	  </tr>
<cfoutput>
  <cfset auxclassif = rsItem.Itn_Classificacao>
  <cfif rsItem.Pos_ClassificacaoPonto neq ''>
     <cfset auxclassif = rsItem.Pos_ClassificacaoPonto>
  </cfif>
 	<tr bgcolor="eeeeee" class="exibir">
	  <td bgcolor="eeeeee">Relevância Item </td>
	  <td colspan="5" bgcolor="eeeeee">
	    <table width="100%" border="0">
          <tr>
            <td width="14%"><div align="left"><strong class="exibir">#rsItem.Itn_Pontuacao#</strong></div></td>
            <td width="9%" class="exibir"><div align="left">Classificação:</div></td>
			<td width="77%" class="exibir"><strong class="exibir">#auxclassif#</strong></td>
            </tr>
        </table>	  </td>
	</tr> 
<cfif trim(rsItem.TNC_ClassifInicio) neq ''>	
	<tr bgcolor="eeeeee" class="exibir">
	  <td>Classificação Unidade</td>
	  <td colspan="5"><table width="100%" border="0">
		<tr>
		  <td width="15%" class="exibir"><div align="center">Classificação Inicial:</div></td>
		  <td width="35%" class="exibir"><strong>#rsItem.TNC_ClassifInicio#</strong></td>
		  <td width="18%" class="exibir"><div align="center">Classificação Atual:</div></td>
		  <td width="32%" class="exibir"><div align="left"><strong>#rsItem.TNC_ClassifAtual#</strong></div></td>
		</tr>
	  </table></td>
	</tr>	
</cfif>	
</cfoutput>
    <cfoutput>
	  <cfset reincSN = "N">
	  <cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
	  <cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
	  <cfset db_reincItem = #rsItem.RIP_ReincItem#> 
	<cfif len(trim(rsItem.RIP_ReincInspecao)) gt 0>
	  	  <cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
	      <cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
	      <cfset db_reincItem = #rsItem.RIP_ReincItem#>
		  <cfset reincSN = "S">
    <cfelseif qtdfrmrsSeguir neq 0>
	  	  <cfset db_reincInsp = #qtdfrmrsSeguir#>
	      <cfset db_reincGrup = #frmGrprsSeguir#>
		   <cfset db_reincItem = #frmItemrsSeguir#>
		   <cfset reincSN = "S">
	<cfelseif isDefined("frminspreincidente") and len(trim(frminspreincidente)) gt 0 and auxdescvlr neq 'CONFORME'>
		   <cfset db_reincInsp = #trim(frminspreincidente)#>
		   <cfset db_reincGrup = #frmgruporeincidente#>
		   <cfset db_reincItem = #frmitemreincidente#>
		   <cfset reincSN = "S">
	</cfif>

	<tr class="red_titulo">
		<td bgcolor="eeeeee"><div id="reincidA">Reincidência</div></td>  
		<input type="hidden" name="db_reincSN" id="db_reincSN" value="#reincSN#">
		<td colspan="5"  bgcolor="eeeeee"><div id="reincidB">Nº Relatório:<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" style="background:white" onKeyPress="numericos()" readonly="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Grupo:<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" style="background:white" onKeyPress="numericos()" readonly="">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Item:<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" style="background:white" onKeyPress="numericos()" readonly=""></div></td>
	</tr> 	
   </cfoutput>	    
   <cfoutput>
   <!---
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
--->
	<cfset impactofin = 'N'>
	<cfset impactofalta = 'N'>
	<cfset impactosobra = 'N'>
	<cfset impactoemrisco = 'N'>
	<cfif listFind(#rsItem.Itn_ImpactarTipos#,'F')>
	  	<cfset impactofin = 'S'>
	    <cfset impactofalta = 'F'>
	</cfif>
	<cfif listFind(#rsItem.Itn_ImpactarTipos#,'S')>
	  	<cfset impactofin = 'S'>
	    <cfset impactosobra = 'S'>
	</cfif>	
	<cfif listFind(#rsItem.Itn_ImpactarTipos#,'R')>
	  	<cfset impactofin = 'S'>
	    <cfset impactoemrisco = 'R'>
	</cfif>	
<!---	<cfoutput>impactofalta: #impactofalta# impactosobra: #impactosobra# impactoemrisco: #impactoemrisco# </cfoutput> --->
<!--- composicao item: #rsItem.Itn_PTC_Seq# --->
 <tr class="exibir">
      <td bgcolor="eeeeee"><div id="impactofin">Valores</div></td>
      <td colspan="5" bgcolor="eeeeee">
		  <table width="100%" border="0" cellspacing="0" bgcolor="eeeeee">
			<tr class="exibir">
				<td width="23%" bgcolor="eeeeee"><div id="impactofalta">Falta(R$):&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)"></div></td>
				<td width="26%" bgcolor="eeeeee"><div id="impactosobra">Sobra(R$):&nbsp;<input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)"></div></td>
				<td width="27%" bgcolor="eeeeee"><div id="impactoemrisco">Em Risco(R$):&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)"></div></td>
			</tr>
		  </table>		  
	  </td>
      </tr> 
   </cfoutput>
   <cfset auxOrient = rsItem.RIP_Recomendacoes>

<cfif not isDefined("Form.acao")> 
	<cfparam name="Form.melhoria" default="#rsItem.RIP_COMENTARIO#">
	<cfparam name="form.recomendacao" default="#rsItem.RIP_RECOMENDACAO#"> 
<!--- </cfif>	
<cfif isDefined("Form.recomendacao")> --->
<cfelse>
 <!--- <cfset form.recomendacao = Session.E01.recomendacao>  --->
</cfif>
<tr>
	<td bgcolor="#eeeeee" align="center"><span class="titulos">Situação Encontrada:</span></td>
	<td colspan="5" bgcolor="eeeeee"><textarea name="melhoria" id="melhoria" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#form.melhoria#</cfoutput></textarea></td>
</tr>

<textarea  hidden name="ripcomentariojustif" id="ripcomentariojustif" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#auxjustificativa#</cfoutput></textarea>
<textarea  hidden name="ripcomentario" id="ripcomentario" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#trim(rsItem.RIP_Comentario)#</cfoutput></textarea>
<textarea  hidden name="itnprerelato" id="itnprerelato" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#trim(rsItem.Itn_PreRelato)#<strong>Ref. Normativa: </strong>#trim(rsItem.Itn_Norma)#</cfoutput></textarea>
<!---
<textarea  hidden name="itnprerelato" id="itnprerelato" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#trim(rsItem.Itn_PreRelato)#<strong>Ref. Normativa: </strong>#trim(rsItem.Itn_Norma)#<p><strong>Possíveis Consequências da Situação Encontrada:</strong></p></cfoutput></textarea>
--->
<textarea  hidden name="frmanexoscomentario" id="frmanexoscomentario" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#Form.melhoria#</cfoutput></textarea>
	 
<tr>
	<td bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
	<td colspan="5" bgcolor="eeeeee"><textarea  name="recomendacao" id="recomendacao" style="background:#fff;" cols="200" rows="7" wrap="VIRTUAL" class="form"><cfoutput>#form.recomendacao#</cfoutput></textarea></td>
</tr>
<textarea  hidden name="riprecomendacoes" id="riprecomendacoes" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea>
<textarea  hidden name="itnorientacaorelato" id="itnorientacaorelato" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#rsItem.Itn_OrientacaoRelato#</cfoutput></textarea>
<textarea  hidden name="frmanexosrecomendacao" id="frmanexosrecomendacao" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#Form.recomendacao#</cfoutput></textarea>

<cfset existeanexos = 'N'>

<tr bgcolor="eeeeee">
			<cfif trim(rsItem.RIP_NCISEI) eq "">
				<cfset auxnci = "N">
				<cfset numncisei = "">
			<cfelse>
				<cfset auxnci = "S">
				<cfset numncisei = trim(rsItem.RIP_NCISEI)>
				<cfset numncisei = left(numncisei,5) & '.' & mid(numncisei,6,6) & '/' & mid(numncisei,12,4) & '-' & right(numncisei,2)>
			</cfif>

			<input type="hidden" name="nseincirel" id="nseincirel" value="<cfoutput>#numncisei#</cfoutput>">
			<td colspan="2" valign="middle" bgcolor="white" class="exibir">Houve Nota de Controle?&nbsp;&nbsp;
				<select name="nci" id="nci" class="form"  onChange="hanci();mensagemNCI();controleNCI();">
						<option value="N"<cfif trim(rsItem.RIP_NCISEI) eq '' > selected</cfif>>Nao</option>
						<option value="S" <cfif trim(rsItem.RIP_NCISEI) neq ''> selected</cfif>>Sim</option>
				</select>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<cfif numncisei neq "">
						<script>
							document.form1.nci.selectedIndex = 1;
						</script>
			  </cfif>			</td>
			
			<td  colspan="6" bgcolor="white" class="exibir">
				<div name="ncisei" id="ncisei" style="POSITION: relative; LEFT: -280px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;N&ordm; SEI da NCI:
					<input name="frmnumseinci" id="frmnumseinci" type="text" class="form" onBlur="controleNCI()"  onKeyPress="numericos();" onKeyDown="validacao(); Mascara_SEI(this);" size="27" maxlength="20" value="<cfoutput>#numncisei#</cfoutput>">
				</div>			</td>
	  </tr>

	
	<div id="divAnexos" name="divAnexos" >

		<tr>
		<td colspan="5" class="exibir" bgcolor="eeeeee"><div align="left"><strong class="exibir">ANEXOS</strong></div></td>
		</tr>

		<tr>
			<td colspan="3" bgcolor="eeeeee" class="exibir"><strong class="exibir">Arquivo:</strong><input  id="arquivo" name="arquivo" class="botao" type="file" size="50" style="display:none"></td>
			<cfif '#grpacesso#' eq "INSPETORES">
				<td colspan="5" bgcolor="eeeeee" class="exibir"><input id="procurar"name="procurar" type="submit" style="display:none" class="botao" onClick="CKupdate();document.form1.acao.value='anexar';document.form1.recomendacao.disabled = false;<cfif "#rsItem.RIP_Recomendacao#" is 'S'>document.form1.emReanalise.value='S';</cfif>" value="anexar"></td>			
			</cfif>
		</tr>
		<tr>
			<td colspan="5">&nbsp;</td>
		</tr>

		<cfloop query= "qAnexos">
		<cfif FileExists(qAnexos.Ane_Caminho)>
		<cfset existeanexos = 'S'>
			<tr id="tdAnexoButton">
			<td colspan="3" bgcolor="#eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
			<td width="755" bgcolor="#eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
					<div align="left">
						&nbsp;
						<input name="Abrir" id="Abrir" type="button" class="botao"  value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />
			  </div></td>
			<td width="254" colspan="4" bgcolor="eeeeee"><cfoutput>
				<div align="center">
					<input id="Excluir" name="Excluir" type="submit" class="botao" onClick="document.form1.acao.value='excluir_anexo';document.form1.vCodigo.value='#qAnexos.Ane_Codigo#';<cfif "#rsItem.RIP_Recomendacao#" is 'S'>document.form1.emReanalise.value='S';</cfif>;document.form1.recomendacao.disabled = false;" value="Excluir" codigo="#qAnexos.Ane_Codigo#">
				  </div>
			</cfoutput></td>
			</tr>
		</cfif>
		</cfloop>
	</div>
	<tr>
      <td colspan="5">&nbsp;</td>
    </tr>
	    <tr>
      <td colspan="5" align="center"><cfoutput>
		<div style="position:absolute;top:145px;left:12px">
		   <input  name="button" type="button" class="botao" style="cursor:pointer;font-size:18px;background:transparent;color:##000;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=##0a366bb0,endColorstr=##053c7e);" 
		   onClick="window.open('itens_inspetores_avaliacao.cfm?numInspecao=#URL.Ninsp#&Unid=#url.Unid#','_self')" value="Voltar">
		</div> 
        <input name="button" type="button" class="botao" onClick="window.open('itens_inspetores_avaliacao.cfm?numInspecao=#URL.Ninsp#&Unid=#url.Unid#','_self')" value="Voltar">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<cfif '#grpacesso#' eq "INSPETORES"> 
            <input name="btnsalvar" id="btnsalvar" type="Submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar';<cfif "#rsItem.RIP_Recomendacao#" is 'S'>document.form1.emReanalise.value='R';</cfif>">
		</cfif>
      </cfoutput></td>
    </tr>
	
    <input type="hidden" name="frmexisteanexos" id="frmexisteanexos" value="<cfoutput>#existeanexos#</cfoutput>">
	<input type="hidden" name="frmrestringirsn" id="frmrestringirsn" value="<cfoutput>#restringirSN#</cfoutput>">
	<input type="hidden" name="frmauxvlr" id="frmauxvlr" value="<cfoutput>#trim(auxvlr)#</cfoutput>">
	<input type="hidden" name="retornosn" id="retornosn" value="<cfoutput>#URL.retornosn#</cfoutput>">
	<input type="hidden" name="frmsituantes" id="frmsituantes" value="<cfoutput>#URL.frmsituantes#</cfoutput>">
	<input type="hidden" name="frmdescantes" id="frmdescantes" value="<cfoutput>#URL.frmdescantes#</cfoutput>">
 	<input name="ripresposta" id="ripresposta" type="hidden" value="<cfoutput>#rsItem.RIP_Resposta#</cfoutput>">
	<input name="frminspreincidente" id="frminspreincidente" type="hidden" value="<cfoutput>#url.frminspreincidente#</cfoutput>">
	<input name="frmgruporeincidente" id="frmgruporeincidente" type="hidden" value="<cfoutput>#url.frmgruporeincidente#</cfoutput>">
	<input name="frmitemreincidente" id="frmitemreincidente" type="hidden" value="<cfoutput>#url.frmitemreincidente#</cfoutput>">

	<input type="hidden" name="frmimpactofin" id="frmimpactofin" value="<cfoutput>#impactofin#</cfoutput>">
	<input type="hidden" name="frmimpactofalta" id="frmimpactofalta" value="<cfoutput>#impactofalta#</cfoutput>">
	<input type="hidden" name="frmimpactosobra" id="frmimpactosobra" value="<cfoutput>#impactosobra#</cfoutput>">
	<input type="hidden" name="frmimpactoemrisco" id="frmimpactoemrisco" value="<cfoutput>#impactoemrisco#</cfoutput>">

	
<!---     <cfabort> --->
 </form>


  <!--- Fim Área de conteúdo --->
</table>
<cfif isdefined('retornosn') and (retornosn eq 'S' or retornosn eq 'N')>
		<script>
			avisoreincidencia('<cfoutput>#auxvlr#</cfoutput>','<cfoutput>#frminspreincidente#</cfoutput>','<cfoutput>#trim(frmdescantes)#</cfoutput>','<cfoutput>#restringirSN#</cfoutput>', '<cfoutput>#url.Ngrup#</cfoutput>','<cfoutput>#Nitem#</cfoutput>')
		</script>
</cfif>	

</body>

<script>
CKEDITOR.replace('melhoria', {
		width: '1020',
		height: 200,
		removePlugins: 'scayt',
        disableNativeSpellChecker: false,
		line_height:'1px',

<!--- 		enterMode:CKEDITOR.ENTER_DIV, ao invés de <p> coloca <div> após enter--->
<!--- 		enterMode:2,forceEnterMode:false,shiftEnterMode:1,  transforma enter em <br> shift+enter <p>--->
		toolbar: [
			[ 'Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find' ],
			[ 'SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			[ 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-'], 
			[ 'HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','-','Imagem', '-','Maximize','Table' ]
					
		]
    });
	CKEDITOR.replace('recomendacao', {
		width: '1020',
		height: 100,
		removePlugins: 'scayt',
        disableNativeSpellChecker: false,
		line_height:'1px',
<!--- 		enterMode:CKEDITOR.ENTER_DIV, ao invés de <p> coloca <div> após enter--->
<!--- 		enterMode:2,forceEnterMode:false,shiftEnterMode:1,  transforma enter em <br> shift+enter <p>--->
		toolbar: [
			[ 'Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat','-', 'Undo', 'Redo', '-','Find' ],
			['SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize','Table'  ]
		]
			
    });

</script>

</html>


<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>
