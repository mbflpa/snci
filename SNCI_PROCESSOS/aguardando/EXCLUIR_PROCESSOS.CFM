
<cfprocessingdirective pageencoding = "utf-8"> 

<cfquery name="mcuOrgaoIndicador" datasource="#application.dsn_processos#" timeout="120">
	WITH OrgHierarchy AS (
						SELECT pc_org_mcu, pc_org_sigla, pc_org_mcu_subord_tec, pc_org_status, pc_org_orgaoAvaliado, 1 AS Level
						FROM pc_orgaos
						WHERE pc_org_mcu = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#application.rsUsuarioParametros.pc_usu_lotacao#">

						UNION ALL

						SELECT o.pc_org_mcu, o.pc_org_sigla, o.pc_org_mcu_subord_tec, o.pc_org_status, o.pc_org_orgaoAvaliado, h.Level + 1
						FROM pc_orgaos o
						INNER JOIN OrgHierarchy h ON o.pc_org_mcu = h.pc_org_mcu_subord_tec
						WHERE h.Level < 10 
					)
	SELECT pc_org_mcu  
	FROM OrgHierarchy  
	WHERE pc_org_status = 'A' AND pc_org_orgaoAvaliado = 1
</cfquery>		
<cfdump var="#mcuOrgaoIndicado#">
 



