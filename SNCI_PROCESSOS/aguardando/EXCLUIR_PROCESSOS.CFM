
<cfprocessingdirective pageencoding = "utf-8"> 

<cfquery name="rs_Orientacao_Respondida" datasource="#application.dsn_processos#" timeout="120">
			
						SELECT pc_orgaos.pc_org_mcu
						FROM pc_orgaos
						WHERE (
							pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							OR pc_org_mcu_subord_tec IN (
								SELECT pc_orgaos.pc_org_mcu
								FROM pc_orgaos
								WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							)
						)
					
				
			
		</cfquery>		
<cfset mcu =''>
<cfoutput query="rs_Orientacao_Respondida">
    <cfset mcu = '"' & mcu & '"ou"' & rs_Orientacao_Respondida.pc_org_mcu>

    
</cfoutput>

<cfdump var="#mcu#">

