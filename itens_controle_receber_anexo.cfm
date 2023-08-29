<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif> 

<cftry>

<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite">


<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
<!--- O arquivo anexo recebe nome indicando Numero da inspeção, Número da unidade, Número do grupo e número do item ao qual está vinculado --->
<cfset destino = cffile.serverdirectory & '\' & Form.numero_inspecao & '_' & Form.numero_grupo & '_' & Form.numero_item & '_' & cffile.serverfile>


<cfif FileExists(origem)>

	<cffile action="rename" source="#origem#" destination="#destino#">
	
	<cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
		SELECT Ane_Codigo FROM Anexos
		WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
	</cfquery>
	
	<cfif qVerificaAnexo.recordCount eq 0>
	
		<cfquery datasource="#dsn_inspecao#" name="qVerifica">
		 INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho)
		 VALUES ('#Form.numero_inspecao#','#Form.numero_unidade#',#Form.numero_grupo#,#Form.numero_item#,'#destino#')
		</cfquery>
		
	</cfif>
</cfif>

<cfcatch type="any">
	<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação. ' & cfcatch.Message>
	<script>
		alert('<cfoutput>#mensagem#</cfoutput>');
		history.back();
	</script>
	<!--- <cfdump var="#cfcatch#">
	<cfabort> --->
</cfcatch>

</cftry>

<cfoutput>
	<cflocation url="itens_controle_respostas.cfm?ninsp=#Form.numero_inspecao#&unid=#FORM.numero_unidade#&ngrup=#Form.numero_grupo#&nitem=#Form.numero_item#&cktipo=#form.numero_cktipo#&dtfim=#form.numero_dtfim#&dtinic=#form.numero_dtinic#&reop=#form.numero_reop#">
</cfoutput>


