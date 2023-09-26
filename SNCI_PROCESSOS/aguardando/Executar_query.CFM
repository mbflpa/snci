
<cfprocessingdirective pageencoding = "utf-8">	
<cfquery datasource="#application.dsn_processos#">
	ALTER TABLE pc_anexos ADD pc_anexo_enviado bit NOT NULL DEFAULT 0
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	UPDATE pc_anexos SET pc_anexo_enviado = 1
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	ALTER TABLE pc_avaliacao_posicionamentos ADD pc_aval_posic_enviado bit NOT NULL DEFAULT 0
</cfquery>

<cfquery datasource="#application.dsn_processos#">
	UPDATE pc_avaliacao_posicionamentos SET pc_aval_posic_enviado = 1
</cfquery>

