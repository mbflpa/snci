<cfprocessingdirective pageencoding = "utf-8">	
<cfquery datasource="#application.dsn_processos#" name="rsOrgaos">
	SELECT * FROM pc_orgaos WHERE not pc_org_se_abrangencia =''
</cfquery>

<cfdump var = "#rsOrgaos#" >