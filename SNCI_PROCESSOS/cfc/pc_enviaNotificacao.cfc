<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">	
    <cffunction name="enviaEmailNotificacaoAnalistas" access="remote" returntype="boolean" hint="Envia e-mail para analistas baseado no tipo de notificação">
		<cfargument name="numProcesso" type="string" required="true">
		<cfargument name="numNotificacao" type="numeric" required="true">
		
		<cfquery name="rsEmailAnalistas" datasource="#application.dsn_processos#">
			SELECT DISTINCT 
				pc_processos.pc_processo_id,
				pc_processos.pc_num_orgao_origem,
				pc_processos.pc_num_orgao_avaliado,
				pc_processos.pc_num_sei,
				pc_processos.pc_num_rel_sei,
				pc_processos.pc_num_avaliacao_tipo,
				pc_avaliacao_tipos.pc_aval_tipo_descricao,
				pc_usuarios.pc_usu_email,
				orgaoOrigem.pc_org_sigla as siglaOrgaoOrigem,
				orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
			FROM pc_processos
			INNER JOIN pc_usuarios ON pc_usuarios.pc_usu_lotacao = pc_processos.pc_num_orgao_origem
			INNER JOIN pc_orgaos as orgaoOrigem ON orgaoOrigem.pc_org_mcu = pc_processos.pc_num_orgao_origem
			INNER JOIN pc_orgaos as orgaoAvaliado ON orgaoAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
			INNER JOIN pc_avaliacao_tipos ON pc_aval_tipo_id = pc_processos.pc_num_avaliacao_tipo
			WHERE pc_processo_id = <cfqueryparam value="#arguments.numProcesso#" cfsqltype="cf_sql_varchar">
			AND pc_usuarios.pc_usu_status = 'A'
			AND (
				(pc_usuarios.pc_usu_gerente = 1 AND #arguments.numNotificacao# = 1)
				OR 
				(pc_usuarios.pc_usu_recebeEmail_primeiraManif = 1 AND #arguments.numNotificacao# = 1)
				OR 
				(pc_usuarios.pc_usu_recebeEmail_segundaManif = 1 AND #arguments.numNotificacao# = 2)
			)
			AND pc_usuarios.pc_usu_email IS NOT NULL 
			AND pc_usuarios.pc_usu_email <> ''
			AND pc_usuarios.pc_usu_email LIKE '%_@_%._%'
		</cfquery>
	<cfdump var="#rsEmailAnalistas#" label="rsEmailAnalistas" abort="false">
		<cfif rsEmailAnalistas.recordCount GT 0>
			<cfset emailList = ValueList(rsEmailAnalistas.pc_usu_email)>
			
			<cfset textoEmail = '<p style="text-align: justify;">Prezado(a) analista,</p>
				<p style="text-align: justify;">Há novas respostas para análise no SNCI Processos, conforme relação a seguir:</p>
				<table border="1" style="border-collapse: collapse; width: 100%; margin: 20px 0;">
					<tr>
						<th style="padding: 8px; background-color: ##f2f2f2;">Nº Processo SNCI</th>
						<td style="padding: 8px;">#rsEmailAnalistas.pc_processo_id#</td>
					</tr>
					<tr>
						<th style="padding: 8px; background-color: ##f2f2f2;">Nº SEI</th>
						<td style="padding: 8px;">#rsEmailAnalistas.pc_num_sei#</td>
					</tr>
					<tr>
						<th style="padding: 8px; background-color: ##f2f2f2;">Nº Relatório SEI</th>
						<td style="padding: 8px;">#rsEmailAnalistas.pc_num_rel_sei#</td>
					</tr>
					<tr>
						<th style="padding: 8px; background-color: ##f2f2f2;">Tipo de Avaliação</th>
						<td style="padding: 8px;">#rsEmailAnalistas.pc_aval_tipo_descricao#</td>
					</tr>
					<tr>
						<th style="padding: 8px; background-color: ##f2f2f2;">Órgão Origem</th>
						<td style="padding: 8px;">#rsEmailAnalistas.siglaOrgaoOrigem#</td>
					</tr>
					<tr>
						<th style="padding: 8px; background-color: ##f2f2f2;">Órgão Avaliado</th>
						<td style="padding: 8px;">#rsEmailAnalistas.siglaOrgaoAvaliado#</td>
					</tr>
				</table>
				<p style="text-align: justify;"><strong>Obs.:</strong> Orienta-se a tratá-los em até cinco dias corridos a partir da data do recebimento. Atentar para as substituições em períodos de férias.</p>'>
			
			<cfobject component="pc_cfcPaginasApoio" name="pc_cfcPaginasApoio"/>
			<cfinvoke component="#pc_cfcPaginasApoio#" 
					  method="EnviaEmails" 
					  returnVariable="sucessoEmail"
					  para="#emailList#"
					  pronomeTratamento="Prezado(a) Analista"
					  texto="#textoEmail#"/>
					  
			<cfreturn sucessoEmail>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
</cfcomponent>