
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>

<cfset houveProcSN = 'N'>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email
</cfquery>

<cfif isDefined("Form.acao") And (Form.acao is 'Salvar' or Form.acao is 'alter_valores')>
	<!--- adicionado por Gilvan em 13/09/2021 --->	
	<!--- Calculo de relevancia do ponto --->
	<!--- Obter as faixas --->
	<cfquery name="rsvlrelev" datasource="#dsn_inspecao#">
		SELECT VLR_Ano, VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal 
		FROM ValorRelevancia where VLR_Ano = '#right(FORM.ninsp,4)#'
	</cfquery>
	<!---  --->
	<cfif IsDefined("FORM.caracvlr") AND #trim(FORM.caracvlr)# EQ "Quantificado">
		<cfset auxfalta = Replace(FORM.frmfalta,'.','','All')>
		<cfset auxfalta = Replace(auxfalta,',','.','All')>
	<cfelse>
		<cfset auxfalta = '1.0'>
	</cfif>
	
	<!--- Obter a pontuacao maxima --->
	<cfset RIPPONTUACAO = form.tuipontuacao>
	<cfloop query="rsvlrelev">
		<cfif (auxfalta gt rsvlrelev.VLR_FaixaInicial) and (auxfalta lte rsvlrelev.VLR_FaixaFinal)>
	 <!---  <cfoutput>linha60:Falta:#auxfalta#   finic:#rsvlrelev.VLR_FaixaInicial#   ffinal:#rsvlrelev.VLR_FaixaFinal# pontuacao:#RIPPONTUACAO#  fator:#rsvlrelev.VLR_Fator#<br></cfoutput>  --->
			<cfset RIPPONTUACAO = RIPPONTUACAO * rsvlrelev.VLR_Fator>		
		<cfelseif (rsvlrelev.VLR_FaixaFinal is '0.00') and (auxfalta gt rsvlrelev.VLR_FaixaInicial)>
			<cfset RIPPONTUACAO = RIPPONTUACAO * rsvlrelev.VLR_Fator>		
<!---  				<cfoutput>linha64:Falta:#auxfalta#   finic:#rsvlrelev.VLR_FaixaInicial#   ffinal:#rsvlrelev.VLR_FaixaFinal# pontuacao:#RIPPONTUACAO#  fator:#rsvlrelev.VLR_Fator#<br></cfoutput>  --->
		</cfif>
	</cfloop>	
</cfif>


<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'INSPETORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' or Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES'>


  <cfif isDefined("Form.acao") And (Form.acao is 'Excluir_Proc' Or Form.acao is 'Incluir_Proc' Or Form.acao is 'Excluir_Sei' Or Form.acao is 'Incluir_Causa' Or Form.acao is 'Anexar' Or Form.acao is 'Excluir_Anexo' Or Form.acao is 'Excluir_Causa')>
	
	<cfif isDefined("Form.abertura")><cfset Session.E01.abertura = Form.abertura><cfelse><cfset Session.E01.abertura = 'Não'></cfif>
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
	<cfif isDefined("Form.ngrup")><cfset Session.E01.ngrup = Form.ngrup><cfelse><cfset Session.E01.ngrup = ''></cfif>
	<cfif isDefined("Form.ninsp")><cfset Session.E01.ninsp = Form.ninsp><cfelse><cfset Session.E01.ninsp = ''></cfif>
	<cfif isDefined("Form.nitem")><cfset Session.E01.nitem = Form.nitem><cfelse><cfset Session.E01.nitem = ''></cfif>
	<cfif isDefined("Form.frmmotivo")><cfset Session.E01.frmmotivo = Form.frmmotivo><cfelse><cfset Session.E01.frmmotivo = ''></cfif>
	<cfif isDefined("Form.cbData")><cfset Session.E01.cbData = Form.cbData><cfelse><cfset Session.E01.cbData = ''></cfif>
	<cfif isDefined("Form.observacao")><cfset Session.E01.observacao = Form.observacao><cfelse><cfset Session.E01.observacao = ''></cfif>
	<cfif isDefined("Form.recomendacao")><cfset Session.E01.recomendacao = Form.recomendacao><cfelse><cfset Session.E01.recomendacao = ''></cfif>
	<cfif isDefined("Form.reop")><cfset Session.E01.reop = Form.reop><cfelse><cfset Session.E01.reop = ''></cfif>
	<cfif isDefined("Form.unid")><cfset Session.E01.unid = Form.unid><cfelse><cfset Session.E01.unid = ''></cfif>
	<cfif isDefined("Form.modalidade")><cfset Session.E01.modalidade = Form.modalidade><cfelse><cfset Session.E01.modalidade = ''></cfif>
	<cfif isDefined("Form.valor")><cfset Session.E01.valor = Form.valor><cfelse><cfset Session.E01.valor = ''></cfif>
	<cfif isDefined("Form.SE")><cfset Session.E01.SE = Form.SE><cfelse><cfset Session.E01.SE = ''></cfif>
    <cfif isDefined("Form.txtNum_Inspecao")><cfset Session.E01.txtNum_Inspecao = Form.txtNum_Inspecao><cfelse><cfset Session.E01.txtNum_Inspecao = ''></cfif>



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


          

  <!--- Anexar arquivo --->
  
<cfif Form.acao is 'Anexar' >

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
		 

	   <cfcatch type="any">
			<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação.\n\nO campo "Arquivo" não pode estar vazio.\n\nSelecione um arquivo no formato "PDF".\n\nAtenção! As informações incluídas anteriormente foram salvas!'>
			<script>
				alert('<cfoutput>#mensagem#</cfoutput>');
			</script>
	   </cfcatch>
	 </cftry>
	 <cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao SET
	  <cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
		RIP_Comentario=
		  <cfset aux_mel = CHR(13) & Form.Melhoria>
		  '#aux_mel#'
		<cfelse>
			RIP_Comentario='.'
	   </cfif>
	   <cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
		 , RIP_Recomendacoes=
		  <cfset aux_recom = CHR(13) & FORM.recomendacao>
		  '#aux_recom#'
		</cfif>
		<cfif IsDefined("FORM.caracvlr") AND #trim(FORM.caracvlr)# EQ "Quantificado">
			<cfset auxfrmfalta = Replace(FORM.frmfalta,'.','','All')>
			<cfset auxfrmfalta = Replace(auxfrmfalta,',','.','All')>
			<cfset auxfrmemrisco = Replace(FORM.frmemrisco,'.','','All')>
			<cfset auxfrmemrisco = Replace(auxfrmemrisco,',','.','All')>
			<cfset auxfrmsobra = Replace(FORM.frmsobra,'.','','All')>
			<cfset auxfrmsobra = Replace(auxfrmsobra,',','.','All')>
			, RIP_Caractvlr='#FORM.caracvlr#'
			, RIP_Falta= #auxfrmfalta#
			, RIP_Sobra=#auxfrmsobra#
			, RIP_EmRisco=#auxfrmemrisco#
		<cfelse>
			, RIP_Caractvlr='Não Quantificado'
			, RIP_Falta='0.0'
			, RIP_Sobra='0.0'
			, RIP_EmRisco='0.0'
		</cfif>
		<cfif IsDefined("FORM.frmReinccb") AND FORM.frmReinccb eq "S">
			, RIP_ReincInspecao = '#FORM.frmreincInsp#'
			, RIP_ReincGrupo = #FORM.frmreincGrup#
			, RIP_ReincItem = #FORM.frmreincItem#
		<cfelse>
			, RIP_ReincInspecao = ''
			, RIP_ReincGrupo = ''
			, RIP_ReincItem = ''
		</cfif>
		  , RIP_UserName = '#CGI.REMOTE_USER#'
		  , RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
		  , RIP_DtUltAtu = CONVERT(char, GETDATE(), 102)
		  , RIP_Resposta ='#FORM.avalItem#'
		  , RIP_PONTUACAO = #RIPPONTUACAO#
        <!--- N° SEI da NCI --->
		<cfset aux_sei_nci = "">
			   , RIP_NCISEI =
		<cfif IsDefined("FORM.nci") AND FORM.nci eq "S">
		<!--- As linhas abaixo servem para substituir o uso de aspas simples e duplas, para de evitar erros em instruções SQL --->
		  <cfset aux_sei_nci = Trim(FORM.frmnumseinci)>
		  <cfset aux_sei_nci = Replace(aux_sei_nci,'.','',"All")>
		  <cfset aux_sei_nci = Replace(aux_sei_nci,'/','','All')>
		  <cfset aux_sei_nci = Replace(aux_sei_nci,'-','','All')>
		    '#aux_sei_nci#'
		<cfelse>
		    '#aux_sei_nci#'
		</cfif> 

		  <!---Para a propagação da avalição quando FORM.propagaAval tiversido definido como sim e a avaliação for Não executa--->
		  <cfif IsDefined("FORM.propagaAval") and '#FORM.propagaAval#' eq 's' and '#FORM.avalItem#' eq 'E'>
			 WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_Resposta ='A'
		  <cfelse>
			WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
		  </cfif>
	  </cfquery>
  </cfif>

  <!--- Excluir anexo --->
	 <cfif Form.acao is 'Excluir_Anexo'>
	  <!--- Verificar se anexo existe --->

		 <cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos
			WHERE Ane_Codigo = '#form.vCodigo#'
		 </cfquery>

		 <cfif qAnexos.recordCount Neq 0>

			<!--- Exluindo arquivo do diretório de Anexos --->
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

<cfquery name="qGrupo" datasource="#dsn_inspecao#">
	SELECT Grp_Descricao FROM Grupos_Verificacao WHERE Grp_Codigo = #ngrup# AND Grp_Ano =Right('#ninsp#',4)
</cfquery>

<cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "INSPETORES">
    <!---AO ENTRAR NO ITEM, SE AINDA NÃO TIVER SIDO AVALIADO, SALVA NA TELA RESULTADO_INSPECAO A MATTÍCULA DO AVALIADOR. AO SAIR SEM AVALIAR, ENTRADO NA TELA ANTERIOR--->
	<cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao SET RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#' 
		where  (rtrim(ltrim(RIP_MatricAvaliador)) is null or rtrim(ltrim(RIP_MatricAvaliador)) ='') and RIP_NumInspecao='#ninsp#'  and RIP_NumGrupo = '#ngrup#' and RIP_NumItem ='#nitem#' and RIP_Resposta ='A'
	</cfquery>

	<!---Verifica se todos os itens estão sem avaliação para a rotina de alteração da data de início da inspeção--->
	<cfquery datasource="#dsn_inspecao#" name="qSemAvaliacoes">
	   Select RIP_Resposta FROM Resultado_Inspecao
       where  RIP_NumInspecao='#ninsp#'  and RIP_NumGrupo = '#ngrup#' and RIP_NumItem ='#nitem#' and RIP_Resposta <>'A'
	</cfquery>


</cfif>


<cfif IsDefined("FORM.submit") AND IsDefined("FORM.acao") >

	<cfif Form.acao is 'Salvar' OR Form.acao is 'Excluir_Anexo' >
	  <cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao SET
	  <cfif IsDefined("FORM.Melhoria") AND FORM.Melhoria NEQ "">
		RIP_Comentario=
		  <cfset aux_mel = CHR(13) & Form.Melhoria>
		  '#aux_mel#'
		<cfelse>
			RIP_Comentario='.'
	   </cfif>
	   <cfif IsDefined("FORM.recomendacao") AND FORM.recomendacao NEQ "">
		 , RIP_Recomendacoes=
		  <cfset aux_recom = CHR(13) & FORM.recomendacao>
		  '#aux_recom#'
		</cfif>
		<cfif IsDefined("FORM.caracvlr") AND #trim(FORM.caracvlr)# EQ "Quantificado">
			<cfset auxfrmfalta = Replace(FORM.frmfalta,'.','','All')>
			<cfset auxfrmfalta = Replace(auxfrmfalta,',','.','All')>
			<cfset auxfrmemrisco = Replace(FORM.frmemrisco,'.','','All')>
			<cfset auxfrmemrisco = Replace(auxfrmemrisco,',','.','All')>
			<cfset auxfrmsobra = Replace(FORM.frmsobra,'.','','All')>
			<cfset auxfrmsobra = Replace(auxfrmsobra,',','.','All')>
			, RIP_Caractvlr='#FORM.caracvlr#'
			, RIP_Falta= #auxfrmfalta#
			, RIP_Sobra=#auxfrmsobra#
			, RIP_EmRisco=#auxfrmemrisco#
		<cfelse>
			, RIP_Caractvlr='Não Quantificado'
			, RIP_Falta='0.0'
			, RIP_Sobra='0.0'
			, RIP_EmRisco='0.0'
		</cfif>
		<cfif IsDefined("FORM.frmReinccb") AND FORM.frmReinccb eq "S">
			, RIP_ReincInspecao = '#FORM.frmreincInsp#'
			, RIP_ReincGrupo = #FORM.frmreincGrup#
			, RIP_ReincItem = #FORM.frmreincItem#
		<cfelse>
			, RIP_ReincInspecao = ''
			, RIP_ReincGrupo = ''
			, RIP_ReincItem = ''
		</cfif>
		  , RIP_UserName = '#CGI.REMOTE_USER#'
		  , RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
		  , RIP_DtUltAtu = CONVERT(char, GETDATE(), 102)
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
		  <!---Para a propagação da avalição quando FORM.propagaAval tiversido definido como sim e a avaliação for Não executa--->
		  <cfif IsDefined("FORM.propagaAval") and '#FORM.propagaAval#' eq 's' and '#FORM.avalItem#' eq 'E'>
			 WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_Resposta ='A'
		  <cfelse>
			WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
		  </cfif>
	    </cfquery>


		
        <cfif Form.acao is "Salvar" > 
         <!---    Se nenhum item tiver sido avaliado salva a data atual no inicio da inspecao na tabela Inspecao       --->
		 <cfif qSemAvaliacoes.recordcount eq 0>
			<cfquery datasource="#dsn_inspecao#">
			  UPDATE Inspecao SET INP_DtInicInspecao = CONVERT(char, GETDATE(), 102), INP_DtFimInspecao = CONVERT(char, GETDATE(), 102), INP_DtEncerramento = CONVERT(char, GETDATE(), 102)
		      WHERE INP_Unidade = '#FORM.unid#' and INP_NumInspecao = '#FORM.ninsp#'
			</cfquery>
           
		 </cfif>



          <!---Ao salvar, se o inspetor não inseriru uma resposta ao gestor, o form de resposta é aberto          --->
	      <cfquery name="qRecomendacao" datasource="#dsn_inspecao#">
	        SELECT RIP_Recomendacao, RIP_Critica_Inspetor FROM Resultado_Inspecao WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
          </cfquery>
           
		  <cfif Form.acao is 'Salvar' and '#qRecomendacao.RIP_Recomendacao#' eq 'S' and '#trim(qRecomendacao.RIP_Critica_Inspetor)#' eq ''>
		       <script>
			       function abrirPopup(url,w,h) {
						var newW = w + 100;
						var newH = h + 100;
						var left = (screen.width-newW)/2;
						var top = (screen.height-newH)/2;
						var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',scrollbars=no');
						newwindow.resizeTo(newW, newH);
						
						//posiciona o popup no centro da tela
						newwindow.moveTo(left, top);
						newwindow.focus();
						
						return false;

					}
			      alert('Antes de salvar este item, salve uma resposta ao gestor.');
				  abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#ninsp#&unid=#FORM.unid#&ngrup=#FORM.ngrup#&nitem=#FORM.nitem#</cfoutput>',700,380);

			   </script>
			   <cfset form.acao = ''>
			    
		   </cfif>
        </cfif>
      <!--- 	Fim da rotina que abre o form de inclusão de resposta ao gestor	 --->

 	
	<cfif Form.acao is "Salvar" > 
                   
		<cfquery datasource="#dsn_inspecao#" name="rsVerificaAvaliador">
			SELECT RIP_MatricAvaliador, RIP_Resposta FROM Resultado_Inspecao 
			WHERE  (RIP_MatricAvaliador !='' or RIP_MatricAvaliador is not null) and RIP_NumInspecao='#FORM.Ninsp#' 
			And RIP_NumGrupo = '#FORM.Ngrup#' and RIP_NumItem ='#FORM.Nitem#' 
		</cfquery>

		<!--- Verifica se o item era uma reanálise e foi reanalisado--->
		<cfquery name="qRecomendacao" datasource="#dsn_inspecao#">
	        SELECT RIP_Recomendacao FROM Resultado_Inspecao 
			WHERE RIP_Unidade='#FORM.unid#' AND RIP_NumInspecao='#FORM.ninsp#' AND RIP_NumGrupo=#FORM.ngrup# AND RIP_NumItem=#FORM.nitem#
        </cfquery>

		<cfif '#qRecomendacao.RIP_Recomendacao#' eq 'R' and '#Form.acao#' neq 'Anexar' and '#Form.acao#' neq 'Excluir_Anexo'>
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
							SELECT Itn_TipoUnidade 
							FROM Itens_Verificacao 
							WHERE (Itn_Ano = right('#FORM.Ninsp#',4)) and (Itn_NumGrupo = '#FORM.Ngrup#') AND (Itn_NumItem = '#FORM.Nitem#')
						</cfquery>
						<!--- Verificara possibilidade de alterar os dados default para Pos_Area e Pos_AreaNome ---> 
						<cfif (trim(rsUnid.Und_Centraliza) neq "") and (rsItem2.Itn_TipoUnidade eq 4)>
						<!--- AC é Centralizada por CDD? --->
							<cfquery name="rsCDD" datasource="#dsn_inspecao#">
								SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rsUnid.Und_Centraliza#'
							</cfquery>
							<cfset posarea_cod = #rsUnid.Und_Centraliza#>
							<cfset posarea_nome = #rsCDD.Und_Descricao#>
						</cfif>
						<!--- Se a valição for não conforme, iniciar um insert na tabela parecer unidade --->
						<cfif '#FORM.avalItem#' eq 'N'>
							<cfquery datasource="#dsn_inspecao#" name="rsPto">
								SELECT TUI_Pontuacao, TUI_Classificacao 
								FROM TipoUnidade_ItemVerificacao 
								WHERE TUI_Modalidade = '#qResponsavel.INP_Modalidade#' 
								AND TUI_Ano = right(#FORM.Ninsp#,4) 
								AND TUI_TipoUnid = #rsUnid.Und_TipoUnidade#  
								AND TUI_GrupoItem = #FORM.Ngrup# 
								AND TUI_ItemVerif = #FORM.Nitem# 
							</cfquery>						
							<!---Início Insere ParecerUnidade --->
							<cfquery datasource="#dsn_inspecao#">
								INSERT INTO ParecerUnidade (Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Pos_DtPosic, Pos_NomeResp, Pos_Situacao, Pos_Parecer, Pos_co_ci, Pos_dtultatu, Pos_username, Pos_aval_dinsp, Pos_Situacao_Resp, Pos_Area, Pos_NomeArea,Pos_NCISEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto) 
								VALUES ('#FORM.unid#', '#FORM.Ninsp#', #FORM.Ngrup#, #FORM.Nitem#, 
										CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', 'RE', '', 'INTRANET', CONVERT(char, GETDATE(), 102), '#CGI.REMOTE_USER#', NULL, 0,
										'#posarea_cod#','#posarea_nome#','#aux_sei_nci#', #rsPto.TUI_Pontuacao#, '#rsPto.TUI_Classificacao#')
							</cfquery>
							<!---Fim Insere ParecerUnidade --->
						
							<!--- Inserindo dados dados na tabela Andamento --->
							<cfset andparecer = #posarea_cod#  & " --- " & #posarea_nome#>
							<cfquery datasource="#dsn_inspecao#">
								insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area) 
								values ('#FORM.Ninsp#', '#FORM.unid#', #FORM.Ngrup#, #FORM.Nitem#, convert(char, getdate(), 102), '#CGI.REMOTE_USER#', 0, CONVERT(char, GETDATE(), 108), '#andparecer#', '#posarea_cod#')
							</cfquery>
							<!---Fim Insere Andamento --->
						</cfif> 
						<!---  Se o tem era uma reanálise e não existirem mais itens em reanálise, a finalização da verificação é realizada nesta página
						e não em itens_inspetores_avaliacao.cfm como acontece para as outras avaliações--->
						<cfif rsVerifItensEmReanalise.recordCount eq 0>
								<!---UPDATE em Inspecao--->
								<cfquery datasource="#dsn_inspecao#" ><!---Inspeções NA = não avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluída---> 
									UPDATE Inspecao SET INP_Situacao = 'RA', INP_DtEncerramento =  CONVERT(char, GETDATE(), 102), INP_DtUltAtu =  CONVERT(DATETIME, GETDATE(), 103), INP_UserName ='#qAcesso.Usu_Matricula#'
									WHERE INP_Unidade='#FORM.unid#' AND INP_NumInspecao='#FORM.Ninsp#' 
								</cfquery>
								<!---Fim UPDATE em Inspecao --->
								<cflocation url = "itens_inspetores_avaliacao.cfm" addToken = "no">
						</cfif>
		
	    </cfif>


	
      <cflocation url = "itens_inspetores_avaliacao.cfm?numInspecao=#form.Ninsp#&Unid=#form.unid#" addToken = "no">

	</cfif>	
<cfif isDefined("Form.acao") And (Form.acao is 'Salvar' or Form.acao is 'alter_valores')>
		<!--- Obter a classificacao da Unidade TNC --->
		<!---Obtem soma do campo RIP_Pontuacao da tabela Resultado_Inspecao dos NC --->
		<cfquery name="rsTNC" datasource="#dsn_inspecao#">
			SELECT Sum(RIP_Pontuacao) AS SomaTNC FROM Resultado_Inspecao WHERE RIP_NumInspecao='#Form.ninsp#' and RIP_Resposta='N'
		</cfquery>
		
		<!--- Obter valores em   --->
		<cfquery name="rsClassif" datasource="#dsn_inspecao#">
			SELECT TNC_Ano, TNC_Inicial, TNC_Final, TNC_Descricao 
			FROM TNC_Classificacao 
			WHERE TNC_Ano = '#right(Form.ninsp,4)#' 
			ORDER BY TNC_Inicial, TNC_Final
		</cfquery>
		
		<!--- Obter TNCClassificacao --->
		<cfloop query="rsClassif">
			<cfif (rsClassif.TNC_Inicial is '0.00') and (rsTNC.SomaTNC lte rsClassif.TNC_Final)>
				<cfset TNCClassif = rsClassif.TNC_Descricao>		
			<cfelseif (rsTNC.SomaTNC gt rsClassif.TNC_Inicial) and (rsClassif.TNC_Final is '0.00')>
				<cfset TNCClassif = rsClassif.TNC_Descricao>	
			<cfelseif (rsTNC.SomaTNC gt rsClassif.TNC_Inicial) and (rsTNC.SomaTNC lte rsClassif.TNC_Final)>
				<cfset TNCClassif = rsClassif.TNC_Descricao>
			</cfif>
		</cfloop>	

		<!--- Obter NCclassificacao --->
		<cfif rsTNC.SomaTNC gt 251.75>
			<cfset NCClassif = "Controle ineficaz">
		<cfelseif (rsTNC.SomaTNC gt 100.7) and (rsTNC.SomaTNC lte 251.75)>
			<cfset NCClassif = "Controle pouco eficaz">
		<cfelseif (rsTNC.SomaTNC gt 50.35) and (rsTNC.SomaTNC lte 100.7)>
			<cfset NCClassif = "Controle de eficácia eficaz">
		<cfelseif (rsTNC.SomaTNC gt 25.175) and (rsTNC.SomaTNC lte 50.35)>
			<cfset NCClassif = "Controle eficaz">
		<cfelseif (rsTNC.SomaTNC lte 25.175)>
			<cfset NCClassif = "Controle plenamente eficaz">
		</cfif>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE inspecao SET INP_TNCClassificacao =   '#TNCClassif#',
								INP_NCClassificacao =    '#NCClassif#' 
			WHERE INP_NumInspecao = '#Form.ninsp#' 
		</cfquery>
<!---  --->
</cfif>
	

	<cfif isDefined("Session.E01")>
	  <cfset StructClear(Session.E01)>
	</cfif>

</cfif>
</cfif>
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

<cfelse>

	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="#qGrupo.Grp_Descricao#">
	

</cfif>

<!---Verifica se o item já foi avaliado ou está sendo avaliado--->
<cfquery datasource="#dsn_inspecao#" name="rsVerificaAvaliador">
	SELECT RIP_MatricAvaliador, RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
	WHERE  (RIP_MatricAvaliador !='' or RIP_MatricAvaliador is not null) and RIP_NumInspecao='#URL.Ninsp#' and RIP_NumGrupo = '#url.Ngrup#' and RIP_NumItem ='#url.Nitem#'
</cfquery>

<cfif rsVerificaAvaliador.recordcount neq 0 >
	<cfquery datasource="#dsn_inspecao#" name="rsNomeAvaliador">
		SELECT Fun_Matric,RTRIM(LTRIM(Fun_Nome)) AS Fun_Nome FROM Funcionarios WHERE Fun_Matric = '#rsVerificaAvaliador.RIP_MatricAvaliador#'
	</cfquery>
	<cfif rsNomeAvaliador.recordcount neq 0 and '#rsNomeAvaliador.Fun_Matric#' neq '#qAcesso.Usu_Matricula#'  and Trim(qAcesso.Usu_GrupoAcesso) eq 'INSPETORES'>
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
			SELECT RIP_Resposta FROM Resultado_Inspecao 
			WHERE  RIP_NumInspecao='#Ninsp#' and RIP_NumGrupo = '#Ngrup#' and RIP_NumItem ='#Nitem#' 
</cfquery>


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">


<script type="text/javascript">
 <cfinclude template="mm_menu.js">

	var habilitarEditor = true;
     window.onload = formRecomedacao();

	//abre o form de recomendações se o item estiver em reanálise 
    function formRecomedacao(){
		<cfquery name="qRecomendacao" datasource="#dsn_inspecao#">
			SELECT rtrim(ltrim(RIP_Recomendacao)) as RIP_Recomendacao, RIP_Critica_Inspetor FROM Resultado_Inspecao 
			WHERE RIP_Unidade='#url.unid#' AND RIP_NumInspecao='#url.ninsp#' AND RIP_NumGrupo=#url.ngrup# AND RIP_NumItem=#url.nitem#
		</cfquery>
		var recom = <cfoutput>'#qRecomendacao.RIP_Recomendacao#'</cfoutput>
		if(recom == 'S'){
			abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#url.ninsp#&unid=#url.unid#&ngrup=#url.ngrup#&nitem=#url.nitem#</cfoutput>',700,380)
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
		
		window.onhashchange=function(){alert('teste');window.location.hash="";} 
		}
	removeBack();

	//reinicia o ckeditor para inibir o erro de retornar conteúdo vazio no textarea
	function CKupdate(){
		for ( instance in CKEDITOR.instances )
		CKEDITOR.instances[instance].updateElement();
	}


	function AlertaOnChange(){
		if(CKEDITOR.instances.Melhoria.getData() != ''){	
			alert('Atenção! A mudança de status poderá apagar as informações do campo "Oportunidade de Aprimoramento".');
		}
	}

    function AvaliacaoOnChangeModelos(a){
		var frm = document.forms[0];
		
        <cfoutput>
			var item = '#URL.ngrup#';	
		</cfoutput>
		var justifItem500 = "Não foram identificadas não-conformidades para este item.";
		if(a == 'V' && item =='500'){
			CKEDITOR.instances['Melhoria'].setData(justifItem500);
		}

		if(a == 'N'){
			var prerelato = frm.preRelato.value;
			CKEDITOR.instances['Melhoria'].setData(prerelato);

			if(frm.orientacao.value!=''){
				var orientacao = frm.orientacao.value;
				CKEDITOR.instances['recomendacao'].setData(orientacao);
			}else{
				var orientacaoPadrao ="Doravante, atentar para os procedimentos previstos nos normativos referenciados neste apontamento. Informar, em sua manifestação, a justificativa para ocorrência da falha detectada (Causa). Apresentar Plano de Ação com indicação de prazo para regularização da situação apontada. Anexar os comprovantes de regularização no sistema SNCI (em PDF), quando couber.";
				CKEDITOR.instances['recomendacao'].setData(orientacaoPadrao);
			}			
		}
	}

	function AvaliacaoOnChange(a){
		var frm = document.forms[0];

		<cfoutput>
			<cfif '#rsVerificaStatus.RIP_Resposta#' eq 'A'>
				frm.Melhoria.value ='';
				frm.recomendacao.value ='';
				frm.frmreincInsp.value = '';
				frm.frmreincGrup.value = '';
				frm.frmreincItem.value = '';
				frm.frmfalta.value = '0,00';
				frm.frmsobra.value = '0,00';
				frm.frmemrisco.value = '0,00';
				frm.frmReinccb.value ='N';
				frm.caracvlr.value ='Não Quantificado';
				frm.frmreincInsp.disabled = true;
				frm.frmreincGrup.disabled = true;
				frm.frmreincItem.disabled = true;
				frm.frmfalta.disabled = true;
				frm.frmsobra.disabled = true;
				frm.frmemrisco.disabled = true;
				frm.nci.value = 'N';
				frm.frmnumseinci.value = '';
				window.ncisei.style.visibility = 'hidden';
			</cfif>
		</cfoutput>

		frm.Melhoria.disabled = false;

		if(a == 'N' || a=='A'){
			frm.procurar.style.display = 'block';
			frm.arquivo.style.display = 'block';
			frm.propagaAval.value='n';
			frm.propagaAval.disabled = true;
			
		}

		if(a == 'V' || a == 'C' ){
			frm.procurar.style.display = 'none';
			frm.arquivo.style.display = 'none';
			frm.propagaAval.value='n';
			frm.propagaAval.disabled = true;
			
		}

		if(a == 'V' || a == 'E' || a == 'C' || a=='A'){
			CKEDITOR.instances['recomendacao'].setData('');
			frm.frmreincInsp.value = '';
			frm.frmreincGrup.value = '';
			frm.frmreincItem.value = '';
			frm.frmfalta.value = '0,00';
			frm.frmsobra.value = '0,00';
			frm.frmemrisco.value = '0,00';
			frm.frmReinccb.value ='N';
			frm.caracvlr.value ='Não Quantificado';
			frm.frmreincInsp.disabled = true;
			frm.frmreincGrup.disabled = true;
			frm.frmreincItem.disabled = true;
			frm.frmfalta.disabled = true;
			frm.frmsobra.disabled = true;
			frm.frmemrisco.disabled = true;
			frm.frmReinccb.disabled = true;
			frm.nci.value='N';
			frm.nci.disabled = true;
			frm.frmnumseinci.value = '';
			window.ncisei.style.visibility = 'hidden';	
		}

		if(a == 'N'){

			frm.caracvlr.disabled = false;
			frm.frmReinccb.disabled = false;
			frm.nci.disabled = false;
			window.ncisei.style.visibility = 'visible';
			
		}else{
			frm.caracvlr.disabled = true;
			frm.frmReinccb.disabled = true;
			frm.nci.disabled = true;
			frm.frmnumseinci.value = '';
			window.ncisei.style.visibility = 'hidden';
		}
		if(a == 'A'){
			frm.propagaAval.value='n';
			frm.propagaAval.disabled = true;
			frm.procurar.style.display = 'none';
			frm.arquivo.style.display = 'none';
		}else{
			// frm.Melhoria.disabled = false;
		
		}

		if(a == 'E' ){
			frm.propagaAval.disabled = false;
			frm.procurar.style.display = 'none';
			frm.arquivo.style.display = 'none';
			
            CKEDITOR.instances['Melhoria'].setReadOnly();
			CKEDITOR.instances['recomendacao'].setReadOnly();

		}else{
			if (a == 'C'|| a=='V'){
				CKEDITOR.instances['Melhoria'].setReadOnly( false );
			}else{
			CKEDITOR.instances['Melhoria'].setReadOnly( false );
			CKEDITOR.instances['recomendacao'].setReadOnly( false );
			}
			
			frm.propagaAval.value='n';
			frm.propagaAval.disabled = true;
		}

		if(frm.Melhoria.value == "" && (a == 'E')){
			frm.Melhoria.value = ".";
		}

		

		<cfoutput>
			var item = '#URL.ngrup#';	
		</cfoutput>
		if((a == 'V' || a == 'E' || a == 'C' || a=='A') && item!=500){
			CKEDITOR.instances['Melhoria'].setData('');
		}

		if (a == 'C'){
			CKEDITOR.instances['recomendacao'].setReadOnly();
		}

	}

		function reincidencia(a){
		//alert(a);
		// var frm = document.forms[0];
		// if (frm.avalItem.value =='N'){
		if (a == 'N')
		{
			document.form1.frmreincInsp.value = '';
			document.form1.frmreincGrup.value = 0;
			document.form1.frmreincItem.value = 0;
			document.form1.frmreincInsp.disabled = true;
			document.form1.frmreincGrup.disabled = true;
			document.form1.frmreincItem.disabled = true;
		}
		else
		{
			document.form1.frmreincInsp.disabled = false;
			document.form1.frmreincGrup.disabled = false;
			document.form1.frmreincItem.disabled = false;
			document.form1.frmreincInsp.value = document.form1.dbreincInsp.value;
			document.form1.frmreincGrup.value = document.form1.dbreincGrup.value;
			document.form1.frmreincItem.value = document.form1.dbreincItem.value;
		}
		
		

		}
		
		//=================
		function exibevalores(a){	
			var frm = document.forms[0];
			if (a == 'Quantificado'){
				frm.frmfalta.disabled = false;
				frm.frmsobra.disabled = false;
				frm.frmemrisco.disabled = false;
				frm.frmfalta.value = document.form1.sfrmfalta.value;
				frm.frmsobra.value = document.form1.sfrmsobra.value;
				frm.frmemrisco.value = document.form1.sfrmemrisco.value;
			}else{
				frm.frmfalta.value = '0,00';
				frm.frmsobra.value = '0,00';
				frm.frmemrisco.value = '0,00';
				frm.frmfalta.disabled = true;
				frm.frmsobra.disabled = true;
				frm.frmemrisco.disabled = true;
			}
		}



		//=============================================================
		function validarform(){

		// ==== critica do botão Salvar ===
			if (document.form1.acao.value == 'Salvar' || document.form1.acao.value == 'Anexar'){
				document.getElementById("aguarde").style.visibility = "visible";
				if (document.form1.acao.value == 'Anexar'){
						if(document.getElementById('arquivo').value==""){
								alert('Selecione um arquivo para anexar!');
								document.getElementById('arquivo').focus();
								document.getElementById("aguarde").style.visibility = "hidden";
								return false;
						}   
				} 

				var frm = document.forms[0];
				var melhor = frm.Melhoria.value;
				var recomed = frm.recomendacao.value;

				if (frm.avalItem.value =='N' && frm.nci.value == ''){
					alert('Informe se houve NCI!');
					document.getElementById("aguarde").style.visibility = "hidden";
					return false;
				}
				
				if (frm.nci.value == 'S'){
					// controle de dados do N.SEI da NCI
				var nsnci = document.form1.frmnumseinci.value;
					if (nsnci.length != 20 || nsnci==''){		
						alert('N° SEI inválido:  (ex. 99999.999999/9999-99)');
						document.getElementById("aguarde").style.visibility = "hidden";
						return false;
					}
			}

			if (document.form1.acao.value=='Anexar'){
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


		//----------------------------------------------
			var el = document.getElementById('Abrir');
			if (document.form1.nci.value == 'S' && el==null ){
					alert('Para pontos com Nota de Controle Interno é necessário anexar a NCI.');
					document.getElementById("aguarde").style.visibility = "hidden";
					return false;
			}


			if (frm.avalItem.value =='A'){
				alert('Avalie o item antes de continuar.');
				frm.avalItem.focus();
				document.getElementById("aguarde").style.visibility = "hidden";
			return false;
			}
			
			
			if (melhor.length < 100 && frm.avalItem.value =='N')
			{
			alert('Inspetor(a), para a avaliação "NÃO CONFORME", o campo "Oportunidade de Aprimoramento" deve conter, no mínimo, 100 caracteres');
			document.getElementById('arquivo').value='';
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
			}

			if (melhor.length < 100 && (frm.avalItem.value =='C'))
			{
				alert('Inspetor(a), para a avaliação "CONFORME", o campo "Oportunidade de Aprimoramento" deve ser preenchido com, pelo menos, 100(cem) caracteres!');
				document.getElementById("Melhoria").focus();
				document.getElementById("aguarde").style.visibility = "hidden";
				return false;
			}

			<cfoutput>
				var item = '#URL.ngrup#';	
			</cfoutput>
			if (melhor.length < 100 && (frm.avalItem.value =='V') && item!=500){
				alert('Inspetor(a), para a avaliação "NÃO VERIFICADO", o campo "Oportunidade de Aprimoramento" deve conter a justificativa com, pelo menos, 100(cem) caracteres!');
				document.getElementById("Melhoria").focus();
				document.getElementById("aguarde").style.visibility = "hidden";
				return false;
			}

			
			if (recomed.length < 100 && frm.avalItem.value =='N')
			{
			alert('Inspetor(a), o campo Orientações deve conter no mínimo 100(cem) caracteres!');
			document.form1.recomendacao.focus();
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
			}

			var caracvlr = document.form1.caracvlr.value;
			var falta = document.form1.frmfalta.value;
			var sobra = document.form1.frmsobra.value;
			var emrisco = document.form1.frmemrisco.value;

			if (caracvlr == 'Quantificado' && (falta == '' || falta == '0,00') && (sobra == '' || sobra == '0,00') && (emrisco == '' || emrisco == '0,00'))
			{
			alert('Para o Tipo "Quantificado" informe os campos Falta e ou Sobra e ou Em Risco!');
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
			}
			var reincInsp = document.form1.frmreincInsp.value;
			var reincGrup = document.form1.frmreincGrup.value;
			var reincItem = document.form1.frmreincItem.value;

			if (document.form1.frmReinccb.value == 'S' && (reincInsp.length != 10 || reincGrup == 0 || reincItem == 0))
			{
			alert('Para a informação de Reincidência "Sim" é preciso informar Nro Inspeção, Nro Grupo e Nro Item!');
			document.getElementById("aguarde").style.visibility = "hidden";
			return false;
			} else {
			document.form1.frmreincInsp.disabled = false;
			document.form1.frmreincGrup.disabled = false;
			document.form1.frmreincItem.disabled = false;
			}
			var frm = document.forms[0];
			var avaliacao =  document.getElementById('avalItem').options[document.getElementById('avalItem').selectedIndex].innerText;
			var mensConf = 'Você avaliou este Item como "' + avaliacao + '"\nDeseja continuar?';
			
			if (document.form1.acao.value == 'Anexar'){
				if(confirm('Esta ação irá salvar esta avaliação.\nDeseja Continuar?')){
				}else{
				document.getElementById("aguarde").style.visibility = "hidden";
					return false;
				}
			}
			


			if (document.form1.acao.value != 'Anexar'){
				if(confirm(mensConf)){
				frm.frmReinccb.disabled = false;
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
		var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',scrollbars=no');
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
	}

	//=================
	

</script>
<style>
	.cke_button__table_icon{
		visibility:hidden;
	}
	
	.cke_top{
		<!---background:#003366; --->
	}

</style>
</style>
<cfquery name="rsMod" datasource="#dsn_inspecao#">
	SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
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
		   Itn_Descricao, 
		   NIP_DtIniPrev, 
		   Itn_Ano, 
		   Grp_Ano,
		   INP_Modalidade,
		   RIP_CARACTVLR,
		   RIP_FALTA,
		   RIP_SOBRA,
		   RIP_EMRISCO,
		   INP_DTINICINSPECAO,
		   RIP_VALOR,
		   RIP_REINCINSPECAO,
		   RIP_COMENTARIO,
		   RIP_RECOMENDACOES,
		   RIP_RECOMENDACAO, 
		   RIP_REINCGRUPO,
		   RIP_REINCITEM,
		   RIP_Caractvlr,   
		   RIP_NCISEI,
		   Itn_Amostra,
		   Itn_Norma,
		   Itn_PreRelato,
		   Itn_OrientacaoRelato    
	  FROM Numera_Inspecao 
INNER JOIN (((Resultado_Inspecao 
INNER JOIN Inspecao 
		ON (RIP_NumInspecao =INP_NumInspecao) 
		   AND (RIP_Unidade =INP_Unidade)) 
INNER JOIN Itens_Verificacao 
		ON (RIP_NumItem = Itn_NumItem) 
		   AND (RIP_NumGrupo = Itn_NumGrupo)) 
INNER JOIN Grupos_Verificacao 
		ON Itn_NumGrupo = Grp_Codigo) 
		ON (NIP_NumInspecao =INP_NumInspecao) 
		   AND (NIP_Unidade =INP_Unidade) 
INNER JOIN Unidades ON RIP_Unidade = Und_Codigo
INNER JOIN Diretoria ON RIP_CodDiretoria = Dir_Codigo
	 WHERE RIP_NumInspecao='#url.Ninsp#' AND Itn_Ano=RIGHT('#url.Ninsp#',4) AND Grp_Ano=RIGHT('#url.Ninsp#',4) and RIP_NumGrupo='#url.Ngrup#' and RIP_NumItem ='#Nitem#'
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsPto">
	SELECT TUI_Pontuacao, TUI_Classificacao 
	FROM TipoUnidade_ItemVerificacao 
	WHERE TUI_Modalidade = '#rsItem.INP_Modalidade#' AND TUI_Ano = year('#rsItem.INP_DtInicInspecao#') AND TUI_TipoUnid = #rsItem.Und_TipoUnidade#  AND TUI_GrupoItem = #URL.ngrup# AND TUI_ItemVerif = #nitem# 
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

  <cfquery name="qResponsavel" datasource="#dsn_inspecao#">
	  SELECT INP_Responsavel, INP_Modalidade
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


</head>
	<body  onLoad="
	CKEDITOR.replace('Melhoria', {
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
			['SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize','Table'  ]
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
			['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize','Table'  ]
		]
			
    });
	exibevalores(<cfoutput>'#rsItem.RIP_Caractvlr#'</cfoutput>);hanci();AvaliacaoOnChange(<cfoutput>'#rsItem.RIP_Resposta#'</cfoutput>); if(document.form1.houveProcSN.value != 'S') {exibe(document.form1.frmResp.value)} else {exibe(24)}; exibe(document.form1.frmResp.value); reincidencia(document.form1.frmReinccb.value); hanci(); controleNCI();">


		<cfinclude template="cabecalho.cfm">
 <div id="aguarde" name="aguarde" align="center"  style="width:100%;height:130%;top:105px;left:10px; background:transparent;filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);z-index:10000;visibility:hidden;position:absolute;" >		
		<img src="figuras/aguarde.png" width="10%"  border="0" style="position:relative;top:45%"></img>
	 </div>

<table width="85%"  align="center" bordercolor="f7f7f7">
  <tr>
    <td height="20" colspan="5"><div align="center"><strong class="titulo2"><cfoutput>#rsItem.Dir_Descricao#</cfoutput></strong></div></td>
  </tr>
  <tr>
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td height="10" colspan="5"><div align="center"><strong class="titulo1">AVALIAÇÃO DO ITEM</strong></div></td>
  </tr>
  

  <tr>
    <td height="20" colspan="5">&nbsp;</td>
  </tr>
  <form name="form1" method="post" onSubmit="return validarform()" enctype="multipart/form-data" action="itens_inspetores_avaliacao1.cfm">
 <div style="position:absolute;top:192px;right:157px">
        <a   onClick="abrirPopup('itens_inspetores_avaliacao1_ajuda.cfm?<cfoutput>numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#</cfoutput>',800,360)" href="#"
		class="botaoCad" ><img   onmouseover="bigImg(this)" onMouseOut="normalImg(this)"   alt="Ajuda do Item" src="figuras/ajudaItem.png" width="25"   border="0" style="position:absolute;left:0px;top:5px"></img></a>	
	</div>
    <cfif '#rsItem.RIP_Recomendacao#' eq 'S'>
		<div align="right" style="position:absolute;top:192px;right:230px">
			<a id="idRecomendacoes" onClick="abrirPopup('itens_controle_revisliber_reanalise.cfm?<cfoutput>ninsp=#ninsp#&unid=#unid#&ngrup=#ngrup#&nitem=#nitem#</cfoutput>',700,380)" href="#"
			class="botaoCad" ><img   onmouseover="bigImg(this)" onMouseOut="normalImg(this)"   alt="Recomendações p/ Reanálise do Inspetor" src="figuras/reavaliar.png" width="25"   border="0" style="position:absolute;left:0px;top:5px"></img></a>	
		</div>
	</cfif>
  <cfoutput>
		
		<input type="hidden" name="sfrmTipoUnidade" id="sfrmTipoUnidade" value="#rsItem.Und_TipoUnidade#">
		<cfset caracvlr = #trim(rsItem.RIP_Caractvlr)#>
		<cfset falta = #mid(LSCurrencyFormat(rsItem.RIP_Falta, "local"), 4, 20)#>
		<cfset sobra = #mid(LSCurrencyFormat(rsItem.RIP_Sobra, "local"), 4, 20)#>
		<cfset emrisco = #mid(LSCurrencyFormat(rsItem.RIP_EmRisco, "local"), 4, 20)#>
		<input type="hidden" name="sfrmfalta" id="sfrmfalta" value="#falta#">
		<input type="hidden" name="sfrmsobra" id="sfrmsobra" value="#sobra#">
		<input type="hidden" name="sfrmemrisco" id="sfrmemrisco" value="#emrisco#">

	</cfoutput>
    <tr>
      <td colspan="5"><p class="titulo1">
        <input type="hidden" id="acao" name="acao" value="">
		<input type="hidden" id="emReanalise" name="emReanalise" value="">
        <input type="hidden" id="anexo" name="anexo" value="">
        <input type="hidden" id="vCausaProvavel" name="vCausaProvavel" value="">
        <input type="hidden" id="vCodigo" name="vCodigo" value="">
        <input name="unid" type="hidden" id="unid" value="<cfoutput>#URL.Unid#</cfoutput>">
        <input name="ninsp" type="hidden" id="ninsp" value="<cfoutput>#URL.Ninsp#</cfoutput>">
        <input name="ngrup" type="hidden" id="ngrup" value="<cfoutput>#URL.Ngrup#</cfoutput>">
        <input name="nitem" type="hidden" id="nitem" value="<cfoutput>#URL.Nitem#</cfoutput>">
        
		
      </p></td>
    </tr>

	<tr class="exibir">
		<td bgcolor="f7f7f7" class="exibir" style="background:transparent;font-size:14px"><STRONG>AVALIAÇÃO:</STRONG></td>
		<td colSpan="3" >
		
		<select name="avalItem" id="avalItem" class="form" onFocus="AlertaOnChange();" onChange="AvaliacaoOnChange(this.value);AvaliacaoOnChangeModelos(this.value)" style="background:white;font-size:14px">
			<cfif #rsItem.RIP_NumGrupo# eq 500 and #rsItem.RIP_NumItem# eq 1>				
				<option <cfif '#rsItem.RIP_Resposta#' is "N">selected</cfif>  value="N">NÃO CONFORME</option>
				<option <cfif '#rsItem.RIP_Resposta#' is "V">selected</cfif>  value="V">NÃO VERIFICADO</option>
				<option <cfif '#rsItem.RIP_Resposta#' is "A">selected</cfif>  value="A"></option>
			<cfelse>
				<option <cfif '#rsItem.RIP_Resposta#' is "C">selected</cfif>  value="C">CONFORME</option>
				<option <cfif '#rsItem.RIP_Resposta#' is "N">selected</cfif>  value="N">NÃO CONFORME</option>
				<option <cfif '#rsItem.RIP_Resposta#' is "V">selected</cfif>  value="V">NÃO VERIFICADO</option>
				<option <cfif '#rsItem.RIP_Resposta#' is "E">selected</cfif>  value="E">NÃO EXECUTA</option>
				<option <cfif '#rsItem.RIP_Resposta#' is "A">selected</cfif>  value="A"></option>
			</cfif>
				
		</select>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

		<label class="exibir" style="background:transparent;font-size:14px"><STRONG>Para todos os Itens do mesmo Grupo?:</STRONG></label>
		<select name="propagaAval" id="propagaAval" class="form"  style="background:white;font-size:14px" >
			<option  value="n" selected>Não</option>
			<option  value="s">Sim</option>
		</select>	
	</td>
	
 </tr>
 
	  <tr>
      <td width="95" bgcolor="f7f7f7" class="exibir">Unidade</td>
      <td width="324" bgcolor="f7f7f7"><cfoutput><strong class="exibir">#URL.Unid#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#rsMOd.Und_Descricao#</strong></cfoutput></td>
      <td width="450" colspan="3" bgcolor="f7f7f7"><span class="exibir">Responsável: </span><cfoutput><strong class="exibir">#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
      </tr>
      <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="4" bgcolor="f7f7f7">-&nbsp;<cfoutput query="qInspetor"><strong class="exibir">#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br>-&nbsp;</cfif></cfoutput></td>
      </tr>

    <tr class="exibir">
      <td bgcolor="f7f7f7">Nº Relatório</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput><strong class="exibir">#URL.Ninsp#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;In&iacute;cio Inspe&ccedil;&atilde;o &nbsp;<strong class="exibir"><cfoutput>#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</cfoutput></strong></td>
      </tr>
    <tr class="exibir">
      <td bgcolor="f7f7f7">Grupo</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput><strong class="exibir">#URL.Ngrup#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#URL.DGrup#</strong></cfoutput></td>
    </tr>

    <tr class="exibir">
      <td bgcolor="f7f7f7">Item</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput><strong class="exibir">#URL.Nitem#</strong></cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfoutput><strong class="exibir">#rsItem.Itn_Descricao#</strong></cfoutput></td>
    </tr>
	<tr class="exibir">
<td bgcolor="f7f7f7">Valor</td>
      <td colspan="4" bgcolor="f7f7f7"><cfoutput><strong>#rsItem.RIP_Valor#</strong></cfoutput></td>
    </tr>
    <cfoutput>

	<tr class="exibir">
	  <td bgcolor="f7f7f7">Reincidência</td>
	  <cfif trim(rsItem.RIP_ReincInspecao) eq "" || trim(rsItem.RIP_ReincInspecao) eq "0"><!---Foi colocado zero pois o xml gerado pelo SGI está colocando 0(zero) por padrão--->
		   <input type="hidden" name="db_reincSN" id="db_reincSN" value="N" onChange="reincidencia('N')">
		   <cfset reincSN = "N">
		   <cfset db_reincInsp = "">
		   <cfset db_reincGrup = 0>
		   <cfset db_reincItem = 0>
		 <cfelse>
		   <cfset reincSN = "S">
		   <input type="hidden" name="db_reincSN" id="db_reincSN" value="S" onChange="reincidencia('S')">
		   <cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
		   <cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
		   <cfset db_reincItem = #rsItem.RIP_ReincItem#>
	  </cfif>
		  <td colspan="4" bgcolor="f7f7f7">
			<select name="frmReinccb" class="form" id="frmReinccb" onChange="reincidencia(this.value)" style="background:White" >
			  <option value="N" <cfif #reincSN# is "N" || #reincSN# eq ''>selected</cfif>>Não</option>
			  <option value="S" <cfif #reincSN# is "S">selected</cfif>>Sim</option>
			</select>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Relatório:
			<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" onKeyPress="numericos(this.value)" style="background:white">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Grupo:
			<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" onKeyPress="numericos(this.value)" style="background:white">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Item:
			<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" onKeyPress="numericos(this.value)" style="background:white">
			</strong>
		  </td>
	</tr>

	</cfoutput>
    <cfoutput>
 	<!--- <cfif (trim(caracvlr) eq "Quantificado")> --->
	  <tr class="exibir">
      <td bgcolor="f7f7f7">Valores</td>
      <td colspan="4" bgcolor="f7f7f7">Tipo:
        <select name="caracvlr" id="caracvlr" class="form" onChange="exibevalores(this.value)" style="background:white">
		<!---	<option <cfif trim(caracvlr) eq "---"> selected</cfif> value="---">---</option> --->
          <option <cfif trim(caracvlr) eq "Quantificado"> selected</cfif> value="Quantificado">Quantificado</option>
          <option <cfif trim(caracvlr) eq "Não Quantificado" || trim(caracvlr) eq ""> selected</cfif> value="Não Quantificado">Não Quantificado</option>
        </select>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Falta(R$):
        <input style="background:white" name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sobra(R$):
        <input style="background:white" name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Em Risco(R$):
        <input style="background:white" name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" onFocus="moeda_dig(this.name)" onKeyPress="moeda_dig(this.name)" onKeyUp="moeda_edit(this.name)" onBlur="ajuste_campo(this.name)">
	  </td>
      </tr>
   </cfoutput>
  

       <tr>
         <td bgcolor="#eeeeee" align="center"><span class="titulos">Oportunidade de Aprimoramento:</span></td>
         <td colspan="5" bgcolor="f7f7f7"><textarea  name="Melhoria" id="Melhoria" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#rsItem.RIP_Comentario#</cfoutput></textarea></td>
		
		<textarea  hidden name="preRelato" id="preRelato" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#rsItem.Itn_PreRelato#<strong>Ref. Normativa: </strong>#Trim(rsItem.Itn_Norma)#<strong>Possíveis Consequências da Situação Encontrada:<strong></cfoutput></textarea>
		
	   </tr>
		<tr>
			<td bgcolor="eeeeee" align="center"><span class="titulos">Orientações:</span></td>
			<td colspan="5" bgcolor="f7f7f7"><textarea  name="recomendacao" id="recomendacao" style="background:#fff;" cols="200" rows="7" wrap="VIRTUAL" class="form"><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea></td>
			<textarea  hidden name="orientacao" id="orientacao" style="background:#fff;display:none!important;" cols="200" rows="25" wrap="VIRTUAL" class="form"><cfoutput>#rsItem.Itn_OrientacaoRelato#</cfoutput></textarea>
		</tr>

		<tr bgcolor="f7f7f7">
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
						<option value="N"<cfif trim(rsItem.RIP_NCISEI) eq '' > selected</cfif>>Não</option>
						<option value="S" <cfif trim(rsItem.RIP_NCISEI) neq ''> selected</cfif>>Sim</option>
				</select>
				<cfif numncisei neq "">
						<script>
							document.form1.nci.selectedIndex = 1;
						</script>
				</cfif>
			</td>
			
			<td  colspan="3" bgcolor="white" class="exibir">
				<div name="ncisei" id="ncisei" style="POSITION: relative; LEFT: -280px;">N° SEI da NCI:
					<input name="frmnumseinci" id="frmnumseinci" type="text" class="form" onBlur="controleNCI()"  onKeyPress="numericos();" onKeyDown="validacao(); Mascara_SEI(this);" size="27" maxlength="20" value="<cfoutput>#numncisei#</cfoutput>">
				</div>
			</td>
		</tr>
	
	<div id="divAnexos" name="divAnexos" >

		<tr>
		<td colspan="5" class="exibir" bgcolor="eeeeee"><div align="left"><strong class="exibir">ANEXOS</strong></div></td>
		</tr>

		<tr>
			<td bgcolor="eeeeee" class="exibir"><strong class="exibir">Arquivo:</strong></td>
			<td bgcolor="eeeeee" class="exibir"><input  id="arquivo" name="arquivo" class="botao" type="file" size="50" style="display:none"></td>
			<td bgcolor="eeeeee" class="exibir">&nbsp;</td> 
			<cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "INSPETORES">
			<td bgcolor="eeeeee" class="exibir"><input id="procurar"name="procurar" type="submit" style="display:none" class="botao" onClick="CKupdate();document.form1.acao.value='Anexar';<cfif "#rsItem.RIP_Recomendacao#" is 'S'>document.form1.emReanalise.value='S';</cfif>" value="Anexar"></td>
			</cfif>
		<td width="51" bgcolor="eeeeee" class="exibir">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="5">&nbsp;</td>
		</tr>

		<cfloop query= "qAnexos">
		<cfif FileExists(qAnexos.Ane_Caminho)>
			<tr id="tdAnexoButton">
			<td colspan="3" bgcolor="#eeeeee" class="form"><cfoutput>#ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
			<td width="472" bgcolor="#eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
					<div align="left">
						&nbsp;
						<input id="Abrir" type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />
					</div></td>
			<td bgcolor="eeeeee"><cfoutput>
				<div align="center">
					<input id="Abrir" name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir_Anexo';document.form1.vCodigo.value=this.codigo;<cfif "#rsItem.RIP_Recomendacao#" is 'S'>document.form1.emReanalise.value='S';</cfif>" value="Excluir" codigo="#qAnexos.Ane_Codigo#">
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
		<cfif '#trim(qAcesso.Usu_GrupoAcesso)#' eq "INSPETORES">
            <input name="Submit" type="Submit" class="botao" value="Salvar" onClick="CKupdate();document.form1.acao.value='Salvar';<cfif "#rsItem.RIP_Recomendacao#" is 'S'>document.form1.emReanalise.value='R';</cfif>">
		</cfif>
      </cfoutput></td>
    </tr>
            <script>
			   reincidencia(document.form1.frmReinccb.value);
			   
			</script>
    <cfabort>
  
    <input type="hidden" name="tuipontuacao" id="tuipontuacao" value="#rsPto.rsPto_pontuacao#">
	<input type="hidden" name="nseincirel" id="nseincirel" value="<cfoutput>#numncisei#</cfoutput>">
	<input type="hidden" name="dbreincInsp" id="dbreincInsp" value="<cfoutput>#db_reincInsp#</cfoutput>">
	<input type="hidden" name="dbreincGrup" id="dbreincGrup" value="<cfoutput>#db_reincGrup#</cfoutput>">
	<input type="hidden" name="dbreincItem" id="dbreincItem" value="<cfoutput>#db_reincItem#</cfoutput>">
	<input type="hidden" name="dbfrmnumsei" id="dbfrmnumsei" value="">
	
 </form>


  <!--- Fim Área de conteúdo --->

</table>


</body>

<script>
CKEDITOR.replace('Melhoria', {
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
			['SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize','Table'  ]
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