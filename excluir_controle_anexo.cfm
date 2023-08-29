
<!--- Verificar se anexo existe --->
	  <cfquery name="qAnexos" datasource="#dsn_inspecao#">
		SELECT     Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
		FROM       Anexos
		WHERE  Ane_Codigo = #url.Ane_codigo#
	  </cfquery>

<cfif qAnexos.recordCount Neq 0>
	
	<!--- Exluindo arquivo do diretório de Anexos --->
	<cfif FileExists(qAnexos.Ane_Caminho)>
		<cffile action="delete" file="#qAnexos.Ane_Caminho#">
	</cfif>
	
	
	<!--- Excluindo anexo do banco de dados --->
	
	<cfquery datasource="#dsn_inspecao#">
	DELETE FROM Anexos
	WHERE  Ane_Codigo = #url.Ane_codigo#
	</cfquery>
	
	<cfoutput>
	<cflocation url="itens_controle_respostas.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#&cktipo=#url.cktipo#&dtfim=#url.dtfim#&dtinic=#url.dtinic#&reop=#url.reop#">
	</cfoutput>
	
</cfif>