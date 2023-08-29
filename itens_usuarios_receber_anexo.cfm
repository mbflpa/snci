<cfprocessingdirective pageEncoding ="utf-8"/>

<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cftry>

<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
<!--- O arquivo anexo recebe nome indicando Numero da inspeção, número do item, número da recomendacao, data do dia e username ao qual está vinculado --->

<cfset destino = cffile.serverdirectory & '\' & Form.numero_inspecao & '_' & data & '_' & Right(CGI.REMOTE_USER,8) & '_' & Form.numero_recomendacao & '_' & 'item' & '_' & Form.vitem & '.pdf'>

<cfif FileExists(origem)>
	<cffile action="rename" source="#origem#" destination="#destino#">

     <cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
		SELECT Ane_Codigo FROM Anexos
		WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
	 </cfquery>

   <cfif qVerificaAnexo.recordCount eq 0>

        <cfquery datasource="#dsn_inspecao#" name="qVerifica">
		 INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumItem, Ane_NumItemRecom, Ane_Caminho,
		 Ane_DtUltAtu, Ane_UserName, Ane_area)
		 VALUES ('#Form.numero_inspecao#','#Form.numero_unidade#',#Form.numero_item#,
		 #Form.numero_recomendacao#, <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">,
		 convert(char, getdate(), 120), '#CGI.REMOTE_USER#', #form.numero_area#)
		</cfquery>

   </cfif>
</cfif>

<cfcatch type="database">
	<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação. Banco de dados indisponivel.'>
	<script>
		alert('<cfoutput>#mensagem#</cfoutput>');
		history.back();
	</script>
	  <cfdump var="#cfcatch#">
	<cfabort>
</cfcatch>
<cfcatch type="application">

	<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação. ' & cfcatch.Message>

	<cfset detalhe_erro = 'The MIME type of the uploaded file application/vnd.openxmlformats-officedocument.wordprocessingml.document was not accepted by the server.'>

	<cfif cfcatch.Message eq detalhe_erro>

     <cfset mensagem = 'Tipo de arquivo inválido. Apenas arquivos PDF podem ser enviados.'>

    </cfif>

	<cfif not directoryexists('\\sac0424\sistemas\followup\sarin_anexos\Fechamento\')>

     <cfset mensagem = 'Servidor indisponível, tente novamente em outro horário.'>

    </cfif>

	<script>
		alert('<cfoutput>#mensagem#</cfoutput>');
		history.back();
	</script>
	  <cfdump var="#cfcatch#">
	<cfabort>
</cfcatch>

<cfcatch type="any">

	<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação. ' & cfcatch.Message>

	<cfset detalhe_erro = 'The MIME type of the uploaded file application/vnd.openxmlformats-officedocument.wordprocessingml.document was not accepted by the server.'>

	<cfif cfcatch.Message eq detalhe_erro>

     <cfset mensagem = 'Tipo de arquivo inválido. Apenas arquivos PDF podem ser enviados.'>

    </cfif>

	<cfif not directoryexists('\\sac0424\sistemas\followup\sarin_anexos\Fechamento\')>

     <cfset mensagem = 'Servidor indisponível, tente novamente em outro horário.'>

    </cfif>

	<script>
		alert('<cfoutput>#mensagem#</cfoutput>');
		history.back();
	</script>
	  <cfdump var="#cfcatch#">
	<cfabort>
</cfcatch>

</cftry>

<cfoutput>
	<cflocation url="itens_unidades_controle_respostas1_area.cfm?ninsp=#Form.numero_inspecao#&Unid=#FORM.numero_unidade#&Nitem=#Form.numero_item#&nrecom=#Form.numero_recomendacao#&area=#Form.numero_area#&situacao=#form.situacao#">
</cfoutput>


