
<cfprocessingdirective pageencoding = "utf-8">	
<cfquery datasource="#application.dsn_processos#" name="rsOrientacoesFinalizadas">
	SELECT pc_aval_orientacao_id FROM pc_avaliacao_orientacoes
	INNER JOIN pc_orientacao_status ON pc_orientacao_status.pc_orientacao_status_id = pc_avaliacao_orientacoes.pc_aval_orientacao_status
	INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp
	INNER JOIN pc_avaliacoes ON pc_avaliacoes.pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval
	INNER JOIN pc_processos ON pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo
	WHERE pc_orientacao_status_finalizador = 'S' and pc_org_controle_interno='S' 
</cfquery>

<cfdump var = "#rsOrientacoesFinalizadas.recordcount#" >
	
	
<cfloop query="rsOrientacoesFinalizadas">
	<cfquery datasource="#application.dsn_processos#" name="rsUltimoOrgaoResp">
		Select TOP 1 pc_aval_posic_num_orgaoResp as ultimoOrgaoResp 
		from pc_avaliacao_posicionamentos
		INNER JOIN pc_orientacao_status ON pc_orientacao_status.pc_orientacao_status_id = pc_avaliacao_posicionamentos.pc_aval_posic_status
		INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp
	
		WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#rsOrientacoesFinalizadas.pc_aval_orientacao_id#">
				AND not pc_aval_posic_num_orgaoResp is null AND pc_org_controle_interno = 'N' 
		order by pc_aval_posic_id desc
	</cfquery>

	<cfquery datasource="#application.dsn_processos#" name="rsUltimoOrgaoEnvio">
		Select TOP 1 pc_aval_posic_num_orgaoResp as ultimoOrgaoResp 
		from pc_avaliacao_posicionamentos
		INNER JOIN pc_orientacao_status ON pc_orientacao_status.pc_orientacao_status_id = pc_avaliacao_posicionamentos.pc_aval_posic_status
		INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp
	
		WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#rsOrientacoesFinalizadas.pc_aval_orientacao_id#">
				AND not pc_aval_posic_num_orgaoResp is null AND pc_org_controle_interno = 'N' 
		order by pc_aval_posic_id desc
	</cfquery>



	<!-- update na tabela pc_avaliacao_orientacoes -->
	<!-- se rsUltimoOrgaoResp não for vazio, atualiza o campo pc_aval_orientacao_mcu_orgaoResp -->
	<cfif rsUltimoOrgaoResp.ultimoOrgaoResp neq "">
		<cfquery datasource="#application.dsn_processos#" name="rsUpdateOrientacoes">
			UPDATE pc_avaliacao_orientacoes
			SET pc_aval_orientacao_mcu_orgaoResp = '#rsUltimoOrgaoResp.ultimoOrgaoResp#'
			WHERE pc_aval_orientacao_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#pc_aval_orientacao_id#">
		</cfquery>
	</cfif>


</cfloop>

	