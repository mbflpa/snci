<cfcomponent>
    <cfprocessingdirective pageencoding = "utf-8">	
    <cffunction name="enviaEmailNotificacaoAnalistas" access="remote" returntype="boolean" hint="Envia e-mail para analistas baseado no tipo de notificação">
		<cfargument name="numOrientacao" type="numeric" required="true">
		<cfargument name="numNotificacao" type="numeric" required="true">
		
		<cfquery name="rsOrientacao" datasource="#application.dsn_processos#">
			SELECT DISTINCT 
				pc_processos.pc_processo_id,
				pc_avaliacoes.pc_aval_numeracao,
				o.pc_aval_orientacao_id,
				orgaoResp.pc_org_sigla as siglaOrgaoResp,
				pc_processos.pc_num_orgao_origem,
				pc_processos.pc_num_orgao_avaliado,
				pc_processos.pc_num_sei,
				pc_processos.pc_num_rel_sei,
				pc_processos.pc_num_avaliacao_tipo,
				pc_processos.pc_aval_tipo_nao_aplica_descricao,
				pc_avaliacao_tipos.pc_aval_tipo_descricao,
				orgaoOrigem.pc_org_sigla as siglaOrgaoOrigem,
				orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado,
				CONCAT(
						'Macroprocesso:<strong> ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,'</strong>',
						' -> N1:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,'</strong>',
						' -> N2:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,'</strong>',
						' -> N3:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN3,'</strong>', '.'
						) as tipoProcesso
			FROM pc_processos
			INNER JOIN pc_avaliacoes on pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_avaliacao_orientacoes o ON o.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_orgaos as orgaoResp ON orgaoResp.pc_org_mcu = o.pc_aval_orientacao_mcu_orgaoResp
			INNER JOIN pc_orgaos as orgaoOrigem ON orgaoOrigem.pc_org_mcu = pc_processos.pc_num_orgao_origem
			INNER JOIN pc_orgaos as orgaoAvaliado ON orgaoAvaliado.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
			INNER JOIN pc_avaliacao_tipos ON pc_aval_tipo_id = pc_processos.pc_num_avaliacao_tipo
			WHERE o.pc_aval_orientacao_id = <cfqueryparam value="#arguments.numOrientacao#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif rsOrientacao.recordCount GT 0>
            <!--- Inicializar variável de CC --->
            <cfset emailListCC = "">

            <!--- Query para usuários principais --->
            <cfquery name="rsUsuariosNotificacao" datasource="#application.dsn_processos#">
                SELECT DISTINCT pc_usu_email
                FROM pc_usuarios
                WHERE pc_usu_status = 'A'
                AND pc_usu_email IS NOT NULL 
                AND pc_usu_email <> ''
                AND pc_usu_email LIKE '%_@_%._%'
                <cfif arguments.numNotificacao EQ 1>
                    AND pc_usu_lotacao = <cfqueryparam value="#rsOrientacao.pc_num_orgao_origem#" cfsqltype="cf_sql_integer">
                    AND pc_usu_recebeEmail_primeiraManif = 1
                <cfelse>
                    AND pc_usu_recebeEmail_segundaManif = 1
                </cfif>
            </cfquery>

            <!--- Query separada para gerentes (apenas para primeira notificação) --->
            <cfif arguments.numNotificacao EQ 1>
                <cfquery name="rsGerentesNotificacao" datasource="#application.dsn_processos#">
                    SELECT DISTINCT pc_usu_email
                    FROM pc_usuarios
                    WHERE pc_usu_status = 'A'
                    AND pc_usu_email IS NOT NULL 
                    AND pc_usu_email <> ''
                    AND pc_usu_email LIKE '%_@_%._%'
                    AND pc_usu_lotacao = <cfqueryparam value="#rsOrientacao.pc_num_orgao_origem#" cfsqltype="cf_sql_integer">
                    AND pc_usu_gerente = 1
                </cfquery>
                
                <cfif rsGerentesNotificacao.recordCount GT 0>
                    <cfset emailListCC = ValueList(rsGerentesNotificacao.pc_usu_email)>
                </cfif>
            </cfif>

            <!--- Verificar se há destinatários (principais ou gerentes) --->
            <cfif rsUsuariosNotificacao.recordCount GT 0 OR len(emailListCC)>
                <cfset emailList = ValueList(rsUsuariosNotificacao.pc_usu_email)>
                
                <cfdump var="#emailList#" label="Debug - Lista TO">
                <cfdump var="#emailListCC#" label="Debug - Lista CC">

                <cfset sei = left(#rsOrientacao.pc_num_sei#,5) & '.'& mid(#rsOrientacao.pc_num_sei#,6,6) &'/'& mid(#rsOrientacao.pc_num_sei#,12,4) &'-'&right(#rsOrientacao.pc_num_sei#,2)>
                <cfif rsOrientacao.pc_num_avaliacao_tipo neq 445 and rsOrientacao.pc_num_avaliacao_tipo neq 2>
                    <cfif rsOrientacao.pc_aval_tipo_descricao neq ''>
                        <cfset tipoProcesso = rsOrientacao.pc_aval_tipo_descricao>
                    <cfelse>
                        <cfset tipoProcesso = rsOrientacao.tipoProcesso>
                    </cfif>
                <cfelse>
					<cfset tipoProcesso = rsOrientacao.pc_aval_tipo_nao_aplica_descricao>
                </cfif>

                <cfset textoEmail = '
                    <p style="text-align: justify;">Há nova resposta para análise no SNCI Processos, conforme informações a seguir:</p>
                    <table border="1" style="border-collapse: collapse; width: 100%; margin: 20px 0;">
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Nº Processo SNCI</th>
                            <td style="padding: 8px;">#rsOrientacao.pc_processo_id#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Nº Item</th>
                            <td style="padding: 8px;">#rsOrientacao.pc_aval_numeracao#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">ID Orientação</th>
                            <td style="padding: 8px;">#rsOrientacao.pc_aval_orientacao_id#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Órgão Responsável</th>
                            <td style="padding: 8px;">#rsOrientacao.siglaOrgaoResp#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Nº SEI</th>
                            <td style="padding: 8px;">#sei#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Nº Relatório SEI</th>
                            <td style="padding: 8px;">#rsOrientacao.pc_num_rel_sei#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Tipo de Avaliação</th>
                            <td style="padding: 8px;">#tipoProcesso#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Órgão Origem</th>
                            <td style="padding: 8px;">#rsOrientacao.siglaOrgaoOrigem#</td>
                        </tr>
                        <tr>
                            <th style="padding: 8px; background-color: ##f2f2f2;white-space: nowrap;">Órgão Avaliado</th>
                            <td style="padding: 8px;">#rsOrientacao.siglaOrgaoAvaliado#</td>
                        </tr>
                    </table>
                    <p style="text-align: justify;"><strong>Obs.:</strong> Orienta-se a tratá-los em até cinco dias corridos a partir da data do recebimento. Atentar para as substituições em períodos de férias.</p>'>
                
                <cfobject component="pc_cfcPaginasApoio" name="pc_cfcPaginasApoio"/>
                <cfinvoke component="#pc_cfcPaginasApoio#" 
                          method="EnviaEmails" 
                          returnVariable="sucessoEmail"
                          para="#emailList#"
                          copiaPara="#emailListCC#" 
                          pronomeTratamento="Prezado(a) analista"
                          texto="#textoEmail#"/>
                          
                <cfreturn sucessoEmail>
            <cfelse>
                <cfreturn false>
            </cfif>
        <cfelse>
            <cfreturn false>
        </cfif>
	</cffunction>
</cfcomponent>