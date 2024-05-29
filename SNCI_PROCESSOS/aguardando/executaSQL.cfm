<cfprocessingdirective pageencoding = "utf-8">	
<cfquery  datasource="#application.dsn_processos#" timeout="120">
    DELETE FROM pc_indicadores_meta
</cfquery>
 