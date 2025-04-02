<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	



	<cffunction name="getProcessosJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>

		<cfset var rsProcTab = ''>
		<cfset var processos = []>
		<cfset var processo = {}>
		
		<!-- Query to fetch data -->
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT  DISTINCT     pc_processos.*
						,pc_orgaos.pc_org_descricao as descOrgAvaliado
						,pc_orgaos.pc_org_sigla as siglaOrgAvaliado
						,pc_status.* 
						,pc_avaliacao_tipos.pc_aval_tipo_descricao
						,pc_orgaos.pc_org_se_sigla as seOrgAvaliado
						,pc_orgaos_1.pc_org_descricao AS descOrgOrigem
						,pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						,pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim
						,COALESCE(
							(SELECT DISTINCT STRING_AGG(pc_objEstrategico_descricao, '; ') 
							FROM pc_processos_objEstrategicos
							INNER JOIN pc_objetivo_estrategico 
							ON pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
							WHERE pc_processos_objEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS objetivosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_riscoEstrategico_descricao, '; ') 
							FROM pc_processos_riscosEstrategicos
							INNER JOIN pc_risco_estrategico 
							ON pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
							WHERE pc_processos_riscosEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS riscosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_indEstrategico_descricao, '; ') 
							FROM pc_processos_indEstrategicos
							INNER JOIN pc_indicador_estrategico 
							ON pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
							WHERE pc_processos_indEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS indicadoresEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores

			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
						LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id

			WHERE NOT pc_num_status IN (2,3) and  right(pc_processo_id,4)>=2024
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#"> 
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					
					<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
					</cfif>
					<!---Se o perfil for 7 - 'GESTOR' --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
					</cfif>
				</cfif>
			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
						AND pc_num_status not in(6,7)
				</cfif>

				<!---Se o perfil for 15 - 'DIRETORIA'--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 15 >
						AND pc_num_status not in(6,7)
						AND (
							pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_num_orgao =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_sug_orgao_mcu =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								OR pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
							</cfif>
						) 
					    <!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
						<cfif ListLen(application.orgaosHierarquiaList) GT 0 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
								<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
								and NOT (
										pc_aval_orientacao_status not in (13)
										AND pc_orgaos_2.pc_org_status IN ('O')
									)
								<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
								and NOT (
										pc_aval_orientacao_status = 13
										AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
									)
								and NOT (
								pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
								
						</cfif>
						
				</cfif>
				
			</cfif>
			
		</cfquery>
		<!-- Create an empty array to hold the processos data -->
		<cfset processos = []>

		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
			<!-- Create a structure to hold each row's data -->
			<cfset processo = {}>

			<!-- Manually assign specific columns to the 'processo' structure -->
			<cfset processo.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset processo.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset processo.DATA_FIM_PROCESSO = rsProcTab.dataFimProcesso>
			<cfset processo.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset processo.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset processo.PC_NUM_SEI = rsProcTab.sei>
			<cfset processo.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset processo.DATA_INICIO = rsProcTab.dataInicio>
			<cfset processo.DATA_FIM = rsProcTab.dataFim>
			<cfset processo.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset processo.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfset processo.PC_AVAL_TIPO_DESCRICAO = rsProcTab.AvaliacaoDescricao>
			<cfset processo.TIPOPROCESSON3 = rsProcTab.tipoProcessoN3>
			<cfset processo.MODALIDADE = rsProcTab.ModalidadeDescricao>
			<cfset processo.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfset processo.TIPO_DEMANDA = rsProcTab.TipoDemandaDescricao>
			<cfset processo.AVALIADORES = rsProcTab.avaliadores>
			<cfset processo.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset processo.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<cfset processo.OBJETIVOSESTRATEGICOSLIST = rsProcTab.objetivosEstrategicosList>
			<cfset processo.RISCOSESTRATEGICOSLIST = rsProcTab.riscosEstrategicosList>
			<cfset processo.INDICADORESESTRATEGICOSLIST = rsProcTab.indicadoresEstrategicosList>
			
			<!-- Append the 'processo' structure to the 'processos' array -->
			<cfset arrayAppend(processos, processo)>
		</cfloop>

		<!-- Return the 'processos' array as JSON -->
		<cfreturn processos>

	</cffunction>

	<cffunction name="getItensJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>

		<cfset var rsProcTab = "" />
		<cfset var itens = [] />
		<cfset var item = {} />
		<cfset var classifRisco = "" />

		
		<!-- Query to fetch data -->
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT  DISTINCT  pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_id 
						,pc_aval_numeracao
						,pc_aval_descricao
						,pc_aval_status_descricao
						,pc_aval_classificacao
						,pc_aval_valorEstimadoRecuperar
						,pc_aval_valorEstimadoRisco
						,pc_aval_valorEstimadoNaoPlanejado
						,pc_aval_teste
						,pc_aval_controleTestado
						,pc_aval_sintese
						,pc_aval_cosoComponente
						,pc_aval_cosoPrincipio
						,pc_aval_criterioRef_descricao
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim
						,COALESCE(
							(SELECT STRING_AGG(pc_objEstrategico_descricao, '; ') 
							FROM pc_processos_objEstrategicos
							INNER JOIN pc_objetivo_estrategico 
							ON pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
							WHERE pc_processos_objEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS objetivosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_riscoEstrategico_descricao, '; ') 
							FROM pc_processos_riscosEstrategicos
							INNER JOIN pc_risco_estrategico 
							ON pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
							WHERE pc_processos_riscosEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS riscosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_indEstrategico_descricao, '; ') 
							FROM pc_processos_indEstrategicos
							INNER JOIN pc_indicador_estrategico 
							ON pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
							WHERE pc_processos_indEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS indicadoresEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_tipoControle_descricao, '; ') 
							FROM pc_avaliacao_tiposControles 
							INNER JOIN pc_avaliacao_tipoControle 
							ON pc_avaliacao_tipoControle.pc_aval_tipoControle_id = pc_avaliacao_tiposControles.pc_aval_tipoControle_id 
							WHERE pc_avaliacao_tiposControles.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS tiposControlesList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_categoriaControle_descricao, '; ') 
							FROM pc_avaliacao_categoriasControles 
							INNER JOIN pc_avaliacao_categoriaControle 
							ON pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_categoriasControles.pc_aval_categoriaControle_id 
							WHERE pc_avaliacao_categoriasControles.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS categoriasControlesList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_risco_descricao, '; ') 
							FROM pc_avaliacao_riscos 
							INNER JOIN pc_avaliacao_risco 
							ON pc_avaliacao_risco.pc_aval_risco_id = pc_avaliacao_riscos.pc_aval_risco_id 
							WHERE pc_avaliacao_riscos.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS riscosList
			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
						LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						INNER JOIN pc_avaliacao_coso on pc_avaliacoes.pc_aval_coso_id = pc_avaliacao_coso.pc_aval_coso_id
						INNER JOIN pc_avaliacao_criterioReferencia on pc_avaliacoes.pc_aval_criterioRef_id = pc_avaliacao_criterioReferencia.pc_aval_criterioRef_id
			WHERE NOT pc_num_status IN (2,3) and  right(pc_processo_id,4)>=2024
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					
					<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
					</cfif>
					<!---Se o perfil for 7 - 'GESTOR' --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
					</cfif>
				</cfif>
			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13>
					AND pc_aval_status_id not in(1,2,3,5,8)	AND pc_num_status not in(6,7)
				</cfif>

				<!---Se o perfil for 15 - 'DIRETORIA' --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 15>
					AND pc_aval_status_id not in(1,2,3,5,8)	AND pc_num_status not in(6,7)
					AND (
							pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_num_orgao =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_sug_orgao_mcu =  '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								OR pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
							</cfif>
						) 
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif ListLen(application.orgaosHierarquiaList) GT 0 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
							and NOT (
									pc_aval_orientacao_status not in (13)
									AND pc_orgaos_2.pc_org_status IN ('O')
								)
							<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
							and NOT (
									pc_aval_orientacao_status = 13
									AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
								)
							and NOT (
								pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
							
					</cfif>
				
				</cfif>
			
			</cfif>
		
			
		</cfquery>	
		
		<!-- Create an empty array to hold the itens data -->
		<cfset itens = []>

		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
			<!-- Create a structure to hold each row's data -->
			<cfset item = {}>

			<!-- Manually assign specific columns to the 'item' structure -->
			<cfset item.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset item.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset item.DATA_FIM_PROCESSO = rsProcTab.dataFimProcesso>
			<cfset item.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset item.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset item.PC_NUM_SEI = rsProcTab.sei>
			<cfset item.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset item.DATA_INICIO = rsProcTab.dataInicio>
			<cfset item.DATA_FIM = rsProcTab.dataFim>
			<cfset item.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset item.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfset item.PC_AVAL_TIPO_DESCRICAO = rsProcTab.AvaliacaoDescricao>
			<cfset item.TIPOPROCESSON3 = rsProcTab.tipoProcessoN3>
			<cfset item.MODALIDADE = rsProcTab.ModalidadeDescricao>
			<cfset item.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfset item.TIPO_DEMANDA = rsProcTab.TipoDemandaDescricao>
			<cfset item.AVALIADORES = rsProcTab.avaliadores>
			<cfset item.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset item.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<cfset item.OBJETIVOSESTRATEGICOSLIST = rsProcTab.objetivosEstrategicosList>
			<cfset item.RISCOSESTRATEGICOSLIST = rsProcTab.riscosEstrategicosList>
			<cfset item.INDICADORESESTRATEGICOSLIST = rsProcTab.indicadoresEstrategicosList>
			<cfset item.PC_AVAL_ID = rsProcTab.pc_aval_id>
			<cfset item.PC_AVAL_NUMERACAO = rsProcTab.pc_aval_numeracao>
			<cfset item.PC_AVAL_DESCRICAO = rsProcTab.pc_aval_descricao>
			<cfset item.PC_AVAL_TESTE = rsProcTab.pc_aval_teste>
			<cfset item.PC_AVAL_CONTROLETESTADO = rsProcTab.pc_aval_controleTestado>
			<cfset item.TIPOSCONTROLESLIST = rsProcTab.tiposControlesList>
			<cfset item.CATEGORIASCONTROLESLIST = rsProcTab.categoriasControlesList>
			<cfset item.PC_AVAL_SINTESE = rsProcTab.pc_aval_sintese>
			<cfset item.RISCOSLIST = rsProcTab.riscosList>
			<cfset item.PC_AVAL_COSOCOMPONENTE = rsProcTab.pc_aval_cosoComponente>
			<cfset item.PC_AVAL_COSOPRINCIPIO = rsProcTab.pc_aval_cosoPrincipio>
			<cfset item.PC_AVAL_CRITERIOREF_DESCRICAO = rsProcTab.pc_aval_criterioRef_descricao>
			<cfset classifRisco = "">
			<cfif #pc_aval_classificacao# eq 'L'>
				<cfset classifRisco = "Leve">
			</cfif>
			<cfif #pc_aval_classificacao# eq 'M'>
				<cfset classifRisco = "Mediano">
			</cfif>
			<cfif #pc_aval_classificacao# eq 'G'>
				<cfset classifRisco = "Grave">
			</cfif>
			<cfif #pc_aval_classificacao# eq ''>
				<cfset classifRisco = "Não Classificado">
			</cfif>
			<cfset item.CLASSIFRISCO = classifRisco>
			<cfset item.PC_AVAL_VALORESTIMADORECUPERAR = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoRecuperar, 'local')>
			<cfset item.PC_AVAL_VALORESTIMADORISCO = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoRisco, 'local')>
			<cfset item.PC_AVAL_VALORESTIMADONAO_PLANEJADO = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoNaoPlanejado, 'local')>
			<cfset item.PC_AVAL_STATUS_DESCRICAO = rsProcTab.pc_aval_status_descricao>
			<!-- Append the 'item' structure to the 'itens' array -->
			<cfset arrayAppend(itens, item)>
		</cfloop>

		<!-- Return the 'itens' array as JSON -->
		<cfreturn itens>

	</cffunction>


	<cffunction name="getOrientacoesJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>
		
		<cfset var rsProcTab = "" />
		<cfset var orientacoes = []>
		<cfset var orientacao = {}>
		<cfset var classifRisco = "">

		<!-- Query to fetch data -->
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >

			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_numeracao,pc_aval_descricao , pc_aval_id, pc_aval_orientacao_id
						,pc_aval_orientacao_descricao,pc_aval_orientacao_dataPrevistaResp,pc_aval_orientacao_status,pc_aval_orientacao_status_datahora
						,pc_orgaos_resp.pc_org_sigla + ' (' + pc_aval_orientacao_mcu_orgaoResp + ')' as orientacaoOrgaoResp
						,pc_orientacao_status.pc_orientacao_status_descricao, pc_aval_status_descricao,pc_aval_classificacao
						,pc_aval_orientacao_dataPrevistaResp  
						,pc_aval_valorEstimadoRecuperar
						,pc_aval_valorEstimadoRisco
						,pc_aval_valorEstimadoNaoPlanejado 
						,pc_aval_teste
						,pc_aval_controleTestado
						,pc_aval_sintese
						,pc_aval_cosoComponente
						,pc_aval_cosoPrincipio
						,pc_aval_criterioRef_descricao
						,pc_orientacao_status.pc_orientacao_status_finalizador,
						CASE
							WHEN  CONVERT(VARCHAR(10), pc_aval_orientacao_dataPrevistaResp, 102)  < CONVERT(VARCHAR(10), GETDATE(), 102) AND pc_aval_orientacao_status IN (4, 5) THEN 'PENDENTE'
							ELSE pc_orientacao_status_descricao
						END AS statusDescricao
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim
						,pc_aval_orientacao_beneficioNaoFinanceiro
						,pc_aval_orientacao_beneficioFinanceiro
						,pc_aval_orientacao_custoFinanceiro
						,COALESCE(
							(SELECT STRING_AGG(pc_objEstrategico_descricao, '; ') 
							FROM pc_processos_objEstrategicos
							INNER JOIN pc_objetivo_estrategico 
							ON pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
							WHERE pc_processos_objEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS objetivosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_riscoEstrategico_descricao, '; ') 
							FROM pc_processos_riscosEstrategicos
							INNER JOIN pc_risco_estrategico 
							ON pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
							WHERE pc_processos_riscosEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS riscosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_indEstrategico_descricao, '; ') 
							FROM pc_processos_indEstrategicos
							INNER JOIN pc_indicador_estrategico 
							ON pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
							WHERE pc_processos_indEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS indicadoresEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_tipoControle_descricao, '; ') 
							FROM pc_avaliacao_tiposControles 
							INNER JOIN pc_avaliacao_tipoControle 
							ON pc_avaliacao_tipoControle.pc_aval_tipoControle_id = pc_avaliacao_tiposControles.pc_aval_tipoControle_id 
							WHERE pc_avaliacao_tiposControles.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS tiposControlesList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_categoriaControle_descricao, '; ') 
							FROM pc_avaliacao_categoriasControles 
							INNER JOIN pc_avaliacao_categoriaControle 
							ON pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_categoriasControles.pc_aval_categoriaControle_id 
							WHERE pc_avaliacao_categoriasControles.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS categoriasControlesList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_risco_descricao, '; ') 
							FROM pc_avaliacao_riscos 
							INNER JOIN pc_avaliacao_risco 
							ON pc_avaliacao_risco.pc_aval_risco_id = pc_avaliacao_riscos.pc_aval_risco_id 
							WHERE pc_avaliacao_riscos.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS riscosList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_categoriaControle_descricao, '; ') 
							FROM pc_avaliacao_orientacao_categoriasControles
							INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_orientacao_categoriasControles.pc_aval_categoriaControle_id
							WHERE pc_avaliacao_orientacao_categoriasControles.pc_aval_orientacao_id = pc_avaliacao_orientacoes.pc_aval_orientacao_id), 'NÃO DEFINIDO'
						) AS categoriasControlesOrientacaoList
			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_num_classificacao = pc_classificacoes.pc_class_id
						INNER JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos AS pc_orgaos_resp ON pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_resp.pc_org_mcu 
						LEFT JOIN  pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
					    LEFT JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
						LEFT JOIN pc_orgaos AS pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
						INNER JOIN pc_avaliacao_coso on pc_avaliacoes.pc_aval_coso_id = pc_avaliacao_coso.pc_aval_coso_id
						INNER JOIN pc_avaliacao_criterioReferencia on pc_avaliacoes.pc_aval_criterioRef_id = pc_avaliacao_criterioReferencia.pc_aval_criterioRef_id
			WHERE NOT pc_num_status IN (2,3)  and pc_aval_orientacao_id is not null and  right(pc_processo_id,4)>=2024
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					
					<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
					</cfif>
					<!---Se o perfil for 7 - 'GESTOR' --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
					</cfif>
				</cfif>
			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO)--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
						AND  pc_aval_orientacao_status not in (0,9,12,14) and pc_num_status not in(6,7)
				<cfelse>
					<!---Não exibe orientações pendentes de posicionamento inicial do controle interno, canceladas, improcedentes e bloqueadas--->
				    AND pc_aval_orientacao_status not in (0,1,9,12,14) and pc_num_status not in(6,7)
					AND (
							pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR  pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_num_orgao_avaliado IN (#application.orgaosHierarquiaList#)
								OR pc_aval_orientacao_mcu_orgaoResp IN (#application.orgaosHierarquiaList#)
							</cfif>
						)
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							<!--- Não mostrará as orientações que não estão em análise e que tem os órgãos origem de processos como responsáveis--->
							and NOT (
									pc_aval_orientacao_status not in (13)
									AND pc_orgaoResp.pc_org_status IN ('O')
								)
							<!--- Não mostrará as orientações em análise que não são de processos cujo órgão avaliado esta abaixo da hierarquia desta diretoria--->
							and NOT (
									pc_aval_orientacao_status = 13
									AND pc_num_orgao_avaliado NOT IN (#application.orgaosHierarquiaList#)
								)
					</cfif>
				</cfif>	
			</cfif>

		</cfquery>
		<!-- Create an empty array to hold the orientacoes data -->
		<cfset orientacoes = []>

		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
			<!-- Create a structure to hold each row's data -->
			<cfset orientacao = {}>

			<!-- Manually assign specific columns to the 'orientacao' structure -->
			<cfset orientacao.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset orientacao.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset orientacao.DATA_FIM_PROCESSO = rsProcTab.dataFimProcesso>
			<cfset orientacao.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset orientacao.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset orientacao.PC_NUM_SEI = rsProcTab.sei>
			<cfset orientacao.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset orientacao.DATA_INICIO = rsProcTab.dataInicio>
			<cfset orientacao.DATA_FIM = rsProcTab.dataFim>
			<cfset orientacao.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset orientacao.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfset orientacao.PC_AVAL_TIPO_DESCRICAO = rsProcTab.AvaliacaoDescricao>
			<cfset orientacao.TIPOPROCESSON3 = rsProcTab.tipoProcessoN3>
			<cfset orientacao.MODALIDADE = rsProcTab.ModalidadeDescricao>
			<cfset orientacao.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfset orientacao.TIPO_DEMANDA = rsProcTab.TipoDemandaDescricao>
			<cfset orientacao.AVALIADORES = rsProcTab.avaliadores>
			<cfset orientacao.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset orientacao.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<cfset orientacao.OBJETIVOSESTRATEGICOSLIST = rsProcTab.objetivosEstrategicosList>
			<cfset orientacao.RISCOSESTRATEGICOSLIST = rsProcTab.riscosEstrategicosList>
			<cfset orientacao.INDICADORESESTRATEGICOSLIST = rsProcTab.indicadoresEstrategicosList>
			<cfset orientacao.PC_AVAL_ID = rsProcTab.pc_aval_id>
			<cfset orientacao.PC_AVAL_NUMERACAO = rsProcTab.pc_aval_numeracao>
			<cfset orientacao.PC_AVAL_DESCRICAO = rsProcTab.pc_aval_descricao>
			<cfset orientacao.PC_AVAL_TESTE = rsProcTab.pc_aval_teste>
			<cfset orientacao.PC_AVAL_CONTROLETESTADO = rsProcTab.pc_aval_controleTestado>
			<cfset orientacao.TIPOSCONTROLESLIST = rsProcTab.tiposControlesList>
			<cfset orientacao.CATEGORIASCONTROLESLIST = rsProcTab.categoriasControlesList>
			<cfset orientacao.PC_AVAL_SINTESE = rsProcTab.pc_aval_sintese>
			<cfset orientacao.RISCOSLIST = rsProcTab.riscosList>
			<cfset orientacao.PC_AVAL_COSOCOMPONENTE = rsProcTab.pc_aval_cosoComponente>
			<cfset orientacao.PC_AVAL_COSOPRINCIPIO = rsProcTab.pc_aval_cosoPrincipio>
			<cfset orientacao.PC_AVAL_CRITERIOREF_DESCRICAO = rsProcTab.pc_aval_criterioRef_descricao>
			<cfset classifRisco = "">
			<cfif #pc_aval_classificacao# eq 'L'>
				<cfset classifRisco = "Leve">
			</cfif>
			<cfif #pc_aval_classificacao# eq 'M'>
				<cfset classifRisco = "Mediano">
			</cfif>
			<cfif #pc_aval_classificacao# eq 'G'>
				<cfset classifRisco = "Grave">
			</cfif>
			<cfif #pc_aval_classificacao# eq ''>
				<cfset classifRisco = "Não Classificado">
			</cfif>
			<cfset orientacao.CLASSIFRISCO = classifRisco>
			<cfset orientacao.PC_AVAL_VALORESTIMADORECUPERAR = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoRecuperar, 'local')>
			<cfset orientacao.PC_AVAL_VALORESTIMADORISCO = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoRisco, 'local')>
			<cfset orientacao.PC_AVAL_VALORESTIMADONAO_PLANEJADO = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoNaoPlanejado, 'local')>
			<cfset orientacao.PC_AVAL_STATUS_DESCRICAO = rsProcTab.pc_aval_status_descricao>
			<cfset orientacao.PC_AVAL_ORIENTACAO_ID = rsProcTab.pc_aval_orientacao_id>
			<cfset orientacao.PC_AVAL_ORIENTACAO_DESCRICAO = rsProcTab.pc_aval_orientacao_descricao>
			<cfset orientacao.ORIENTACAO_ORGAO_RESP = rsProcTab.orientacaoOrgaoResp>
			<cfset orientacao.CATEGORIASCONTROLESORIENTACAOLIST = rsProcTab.categoriasControlesOrientacaoList>
			<cfset orientacao.PC_AVAL_ORIENTACAO_BENEFICIO_NAO_FINANCEIRO = rsProcTab.pc_aval_orientacao_beneficioNaoFinanceiro>
			<cfset orientacao.PC_AVAL_ORIENTACAO_BENEFICIOFINANCEIRO = LSCurrencyFormat(rsProcTab.pc_aval_orientacao_beneficioFinanceiro, 'local')>
			<cfset orientacao.PC_AVAL_ORIENTACAO_CUSTOFINANCEIRO = LSCurrencyFormat(rsProcTab.pc_aval_orientacao_custoFinanceiro, 'local')>
			<cfset orientacao.PC_AVAL_ORIENTACAO_STATUS_DESCRICAO = rsProcTab.statusDescricao>
			<cfset dataStatusOrientacao = DateFormat(#pc_aval_orientacao_status_datahora#,'DD-MM-YYYY') >
			<cfset orientacao.PC_AVAL_ORIENTACAO_STATUS_DATA = dataStatusOrientacao>
			<cfset orientacao.PC_AVAL_ORIENTACAO_DATA_PREVISTA_RESP = DateFormat(rsProcTab.pc_aval_orientacao_dataPrevistaResp,'DD-MM-YYYY')>
			<cfif rsProcTab.pc_orientacao_status_finalizador eq "S">
				<cfset orientacao.PC_ORIENTACAO_STATUS_FINALIZADOR = "Sim">
			<cfelse>
				<cfset orientacao.PC_ORIENTACAO_STATUS_FINALIZADOR = "Não">
			</cfif>
			<!-- Append the 'orientacao' structure to the 'orientacoes' array -->
			<cfset ArrayAppend(orientacoes, orientacao)>
		</cfloop>

		<!-- Return the 'orientacoes' array as JSON -->
		<cfreturn orientacoes>
	</cffunction>


	<cffunction name="getPropostasMelhoriaJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>

		<cfset var rsProcTab = "">
		<cfset var propostasMelhoria = []>
		<cfset var proposta = {}>
		<cfset var classifRisco = "">
		<cfset var statusMelhoria = "">
		
		
		<!-- Query to fetch data -->
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_numeracao,pc_aval_descricao, pc_aval_status_descricao, pc_aval_classificacao
						,pc_aval_melhoria_descricao, pc_aval_melhoria_status, pc_aval_melhoria_dataPrev
						,pc_orgaos_melhoria.pc_org_sigla + '(' + pc_orgaos_melhoria.pc_org_mcu + ')' as orgaoResp
						,pc_orgaos_melhoria_sug.pc_org_sigla + '(' + pc_orgaos_melhoria_sug.pc_org_mcu + ')' as orgaoRespSug
						,pc_aval_melhoria_sugestao, pc_aval_melhoria_naoAceita_justif
						,pc_aval_valorEstimadoRecuperar
						,pc_aval_valorEstimadoRisco
						,pc_aval_valorEstimadoNaoPlanejado
						,pc_aval_teste
						,pc_aval_controleTestado
						,pc_aval_sintese
						,pc_aval_cosoComponente
						,pc_aval_cosoPrincipio
						,pc_aval_criterioRef_descricao
						,pc_aval_id, pc_aval_melhoria_id
						,CASE 
							WHEN pc_num_avaliacao_tipo <> 445 AND pc_num_avaliacao_tipo <> 2 
								THEN CASE 
										WHEN pc_aval_tipo_descricao <> '' 
										THEN pc_aval_tipo_descricao 
										ELSE CONCAT(
												'MP - ', pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
												' - N1 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
												' - N2 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN2
											)
									END
							ELSE pc_aval_tipo_nao_aplica_descricao
						END AS AvaliacaoDescricao
						,CASE 
							WHEN pc_avaliacao_tipos.pc_aval_tipo_processoN3 IS NOT NULL AND pc_avaliacao_tipos.pc_aval_tipo_processoN3 <> '' 
							THEN CONCAT('N3 - ', pc_avaliacao_tipos.pc_aval_tipo_processoN3)
							ELSE 'NÃO DEFINIDO'
						END AS tipoProcessoN3
						,CASE 
							WHEN pc_Modalidade = 'A' THEN 'Acompanhamento'
							WHEN pc_Modalidade = 'E' THEN 'ENTREGA DO RELATÓRIO'
							ELSE 'Normal'
						END AS ModalidadeDescricao
						,CASE 
							WHEN pc_tipo_demanda = 'P' THEN 'PLANEJADA'
							WHEN pc_tipo_demanda = 'E' THEN 'EXTRAORDINÁRIA'
							ELSE 'Não informado'
						END AS TipoDemandaDescricao
						,FORMAT(pc_data_finalizado, 'dd-MM-yyyy') AS dataFimProcesso
						,LEFT(pc_num_sei, 5) + '.' + 
							SUBSTRING(pc_num_sei, 6, 6) + '/' + 
							SUBSTRING(pc_num_sei, 12, 4) + '-' + 
							RIGHT(pc_num_sei, 2) AS sei
						,FORMAT(pc_data_inicioAvaliacao, 'dd-MM-yyyy') AS dataInicio
						,FORMAT(pc_data_fimAvaliacao, 'dd-MM-yyyy') AS dataFim
						,pc_aval_melhoria_beneficioNaoFinanceiro
						,pc_aval_melhoria_beneficioFinanceiro
						,pc_aval_melhoria_custoFinanceiro
						,COALESCE(
							(SELECT STRING_AGG(pc_objEstrategico_descricao, '; ') 
							FROM pc_processos_objEstrategicos
							INNER JOIN pc_objetivo_estrategico 
							ON pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
							WHERE pc_processos_objEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS objetivosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_riscoEstrategico_descricao, '; ') 
							FROM pc_processos_riscosEstrategicos
							INNER JOIN pc_risco_estrategico 
							ON pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
							WHERE pc_processos_riscosEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS riscosEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_indEstrategico_descricao, '; ') 
							FROM pc_processos_indEstrategicos
							INNER JOIN pc_indicador_estrategico 
							ON pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
							WHERE pc_processos_indEstrategicos.pc_processo_id = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS indicadoresEstrategicosList
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processos.pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_tipoControle_descricao, '; ') 
							FROM pc_avaliacao_tiposControles 
							INNER JOIN pc_avaliacao_tipoControle 
							ON pc_avaliacao_tipoControle.pc_aval_tipoControle_id = pc_avaliacao_tiposControles.pc_aval_tipoControle_id 
							WHERE pc_avaliacao_tiposControles.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS tiposControlesList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_categoriaControle_descricao, '; ') 
							FROM pc_avaliacao_categoriasControles 
							INNER JOIN pc_avaliacao_categoriaControle 
							ON pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_categoriasControles.pc_aval_categoriaControle_id 
							WHERE pc_avaliacao_categoriasControles.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS categoriasControlesList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_risco_descricao, '; ') 
							FROM pc_avaliacao_riscos 
							INNER JOIN pc_avaliacao_risco 
							ON pc_avaliacao_risco.pc_aval_risco_id = pc_avaliacao_riscos.pc_aval_risco_id 
							WHERE pc_avaliacao_riscos.pc_aval_id = pc_avaliacoes.pc_aval_id), 'NÃO DEFINIDO'
						) AS riscosList
						,COALESCE(
							(SELECT STRING_AGG(pc_aval_categoriaControle_descricao, '; ') 
							FROM pc_avaliacao_melhoria_categoriasControles
							INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_melhoria_categoriasControles.pc_aval_categoriaControle_id
							WHERE pc_avaliacao_melhoria_categoriasControles.pc_aval_Melhoria_id = pc_avaliacao_melhorias.pc_aval_melhoria_id), 'NÃO DEFINIDO'
						) AS categoriasControlesMelhoriaList
						
			FROM        pc_processos 
						INNER JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						INNER JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						INNER JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						INNER JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						INNER JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						INNER JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						INNER JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						INNER JOIN pc_orgaos as  pc_orgaos_melhoria on pc_orgaos_melhoria.pc_org_mcu = pc_aval_melhoria_num_orgao
						LEFT JOIN  pc_orgaos as pc_orgaos_melhoria_sug on pc_orgaos_melhoria_sug.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
			            INNER JOIN pc_avaliacao_coso on pc_avaliacoes.pc_aval_coso_id = pc_avaliacao_coso.pc_aval_coso_id
						INNER JOIN pc_avaliacao_criterioReferencia on pc_avaliacoes.pc_aval_criterioRef_id = pc_avaliacao_criterioReferencia.pc_aval_criterioRef_id
			WHERE NOT pc_num_status IN (2,3) and  right(pc_processos.pc_processo_id,4)>=2024
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					
					<!---Se a lotação do usuario não for um orgao origem de processos(status 'A') e o perfil for 4 - 'AVALIADOR') --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
					</cfif>
					<!---Se o perfil for 7 - 'GESTOR' --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 7 and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'  and '#application.rsUsuarioParametros.pc_org_status#' eq 'A'>
						AND pc_orgaos.pc_org_se = 	#application.rsUsuarioParametros.pc_org_se#
					</cfif>
				</cfif>
			<cfelse>
				<!---Se o perfil for 13 - 'CONSULTA' (AUDIT e RISCO), não mostra processos e melhorias bloqueadas--->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 13 >
					AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6,7)
				<cfelse>
				    AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6,7)
					AND (
							pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR  pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_sug_orgao_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0> 
								OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
							</cfif>
						)
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif ListLen(application.orgaosHierarquiaList) GT 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							and NOT (
									pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
								)
							
					</cfif>	
				</cfif>
			
			</cfif>

			
		</cfquery>

		<!-- Create an empty array to hold the propostasMelhoria data -->
		<cfset propostasMelhoria = []>

		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
			<!-- Create a structure to hold each row's data -->
			<cfset proposta = {}>

			<!-- Manually assign specific columns to the 'proposta' structure -->
			<cfset proposta.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset proposta.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset proposta.DATA_FIM_PROCESSO = rsProcTab.dataFimProcesso>
			<cfset proposta.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset proposta.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset proposta.PC_NUM_SEI = rsProcTab.sei>
			<cfset proposta.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset proposta.DATA_INICIO = rsProcTab.dataInicio>
			<cfset proposta.DATA_FIM = rsProcTab.dataFim>
			<cfset proposta.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset proposta.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfset proposta.PC_AVAL_TIPO_DESCRICAO = rsProcTab.AvaliacaoDescricao>
			<cfset proposta.TIPOPROCESSON3 = rsProcTab.tipoProcessoN3>
			<cfset proposta.MODALIDADE = rsProcTab.ModalidadeDescricao>
			<cfset proposta.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfset proposta.TIPO_DEMANDA = rsProcTab.TipoDemandaDescricao>
			<cfset proposta.AVALIADORES = rsProcTab.avaliadores>
			<cfset proposta.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset proposta.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<cfset proposta.OBJETIVOSESTRATEGICOSLIST = rsProcTab.objetivosEstrategicosList>
			<cfset proposta.RISCOSESTRATEGICOSLIST = rsProcTab.riscosEstrategicosList>
			<cfset proposta.INDICADORESESTRATEGICOSLIST = rsProcTab.indicadoresEstrategicosList>
			<cfset proposta.PC_AVAL_ID = rsProcTab.pc_aval_id>
			<cfset proposta.PC_AVAL_NUMERACAO = rsProcTab.pc_aval_numeracao>
			<cfset proposta.PC_AVAL_DESCRICAO = rsProcTab.pc_aval_descricao>
			<cfset proposta.PC_AVAL_TESTE = rsProcTab.pc_aval_teste>
			<cfset proposta.PC_AVAL_CONTROLETESTADO = rsProcTab.pc_aval_controleTestado>
			<cfset proposta.TIPOSCONTROLESLIST = rsProcTab.tiposControlesList>
			<cfset proposta.CATEGORIASCONTROLESLIST = rsProcTab.categoriasControlesList>
			<cfset proposta.PC_AVAL_SINTESE = rsProcTab.pc_aval_sintese>
			<cfset proposta.RISCOSLIST = rsProcTab.riscosList>
			<cfset proposta.PC_AVAL_COSOCOMPONENTE = rsProcTab.pc_aval_cosoComponente>
			<cfset proposta.PC_AVAL_COSOPRINCIPIO = rsProcTab.pc_aval_cosoPrincipio>
			<cfset proposta.PC_AVAL_CRITERIOREF_DESCRICAO = rsProcTab.pc_aval_criterioRef_descricao>
			<cfset classifRisco = "">
			<cfif #pc_aval_classificacao# eq 'L'>
				<cfset classifRisco = "Leve">
			</cfif>
			<cfif #pc_aval_classificacao# eq 'M'>
				<cfset classifRisco = "Mediano">
			</cfif>
			<cfif #pc_aval_classificacao# eq 'G'>
				<cfset classifRisco = "Grave">
			</cfif>
			<cfif #pc_aval_classificacao# eq ''>
				<cfset classifRisco = "Não Classificado">
			</cfif>
			<cfset proposta.CLASSIFRISCO = classifRisco>
			<cfset proposta.PC_AVAL_VALORESTIMADORECUPERAR = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoRecuperar, 'local')>
			<cfset proposta.PC_AVAL_VALORESTIMADORISCO = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoRisco, 'local')>
			<cfset proposta.PC_AVAL_VALORESTIMADONAO_PLANEJADO = LSCurrencyFormat(rsProcTab.pc_aval_valorEstimadoNaoPlanejado, 'local')>
			<cfset proposta.PC_AVAL_STATUS_DESCRICAO = rsProcTab.pc_aval_status_descricao>
			<cfset proposta.PC_AVAL_MELHORIA_ID = rsProcTab.pc_aval_melhoria_id>
			<cfset proposta.PC_AVAL_MELHORIA_DESCRICAO = rsProcTab.pc_aval_melhoria_descricao>
			<cfset proposta.ORGAORESP = rsProcTab.orgaoResp>
			<cfset proposta.CATEGORIASCONTROLESMELHORIALIST = rsProcTab.categoriasControlesMelhoriaList>
			<cfset proposta.PC_AVAL_MELHORIA_BENEFICIO_NAO_FINANCEIRO = rsProcTab.pc_aval_melhoria_beneficioNaoFinanceiro>
			<cfset proposta.PC_AVAL_MELHORIA_BENEFICIOFINANCEIRO = LSCurrencyFormat(rsProcTab.pc_aval_melhoria_beneficioFinanceiro, 'local')>
			<cfset proposta.PC_AVAL_MELHORIA_CUSTOFINANCEIRO = LSCurrencyFormat(rsProcTab.pc_aval_melhoria_custoFinanceiro, 'local')>
			<cfswitch expression="#pc_aval_melhoria_status#">
				<cfcase value="P">
					<cfset statusMelhoria = "PENDENTE">
				</cfcase>
				<cfcase value="A">
					<cfset statusMelhoria = "ACEITA">
				</cfcase>
				<cfcase value="R">
					<cfset statusMelhoria = "RECUSA">
				</cfcase>
				<cfcase value="T">
					<cfset statusMelhoria = "TROCA">
				</cfcase>
				<cfcase value="N">
					<cfset statusMelhoria = "NÃO INFORMADO">
				</cfcase>
				<cfcase value="B">
					<cfset statusMelhoria = "BLOQUEADO">
				</cfcase>
				<cfdefaultcase>
					<cfset statusMelhoria = "">    
				</cfdefaultcase>
			</cfswitch>
			<cfset proposta.STATUSMELHORIA = statusMelhoria>
			<cfset dataPrev = DateFormat(#pc_aval_melhoria_dataPrev#,'DD-MM-YYYY')>
			<cfset proposta.DATAPREV = dataPrev>
			<cfset proposta.PC_AVAL_MELHORIA_SUGESTAO = rsProcTab.pc_aval_melhoria_sugestao>
			<cfset proposta.ORGAORESPSUG = rsProcTab.orgaoRespSug>
			<cfset proposta.PC_AVAL_MELHORIA_NAOACEITA_JUSTIF = rsProcTab.pc_aval_melhoria_naoAceita_justif>




			<!-- Append the structure to the array -->
			<cfset arrayAppend(propostasMelhoria, proposta)>
		</cfloop>

		<!-- Return the array of propostasMelhoria -->
		<cfreturn propostasMelhoria>

	</cffunction>
	



</cfcomponent>