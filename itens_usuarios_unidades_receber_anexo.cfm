<!---
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>
 --->

<cftry>


<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>

<!--- O arquivo anexo recebe nome indicando Numero da inspeção, data, Número do grupo e número do item ao qual está vinculado --->
<cfset destino = cffile.serverdirectory & '\' & Form.numero_inspecao & '_' & data & '_' & Right(CGI.REMOTE_USER,8) & '_' & Form.numero_grupo & '_' & Form.numero_item & '.pdf'>


<cfif FileExists(origem)>


	<cffile action="rename" source="#origem#" destination="#destino#">

     <cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
		SELECT Ane_Codigo FROM Anexos
		WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
	 </cfquery>


   <cfif qVerificaAnexo.recordCount eq 0>

      <cfquery datasource="#dsn_inspecao#" name="qVerifica">
        INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho)
        VALUES ('#Form.numero_inspecao#', '#Form.numero_unidade#', #Form.numero_grupo#, #Form.numero_item#, '#destino#')
      </cfquery>

   </cfif>
</cfif>

<cfcatch type="any">

	<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação. ' & cfcatch.Message>
	<script>
		alert('<cfoutput>#mensagem#</cfoutput>');
		history.back();
	</script>
	<cfabort>
</cfcatch>

</cftry>

<cfoutput>
	<cflocation url="itens_unidades_controle_respostas.cfm?numero=#form.numero_inspecao#&unidade='#FORM.numero_unidade#'&numgrupo=#Form.numero_grupo#&numitem=#Form.numero_item#">
</cfoutput>


