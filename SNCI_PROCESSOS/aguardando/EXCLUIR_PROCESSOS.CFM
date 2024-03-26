
<cfprocessingdirective pageencoding = "utf-8"> 

<cfset ano = 2024>
<cfset mes = 2>

<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#"  >
	SELECT	pc_indPeso_peso FROM pc_indicadores_peso WHERE pc_indPeso_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
	and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#"  >
	SELECT	pc_indPeso_peso FROM pc_indicadores_peso WHERE pc_indPeso_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
	and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
</cfquery>

<cfdump var= "#rsPRCIpeso#">
<cfdump var= "#rsSLNCpeso#">
```