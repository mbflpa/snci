<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	

	<cffunction name="getProcessosJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>
		
		
		<cfset var rsProcTab = "">
		<cfset var processos = []>
		<cfset var processo = {}>
		
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT  DISTINCT    pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores
						
			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
						LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
			WHERE NOT pc_num_status IN (2,3) and  right(pc_processos.pc_processo_id,4)<=2023
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#"> 
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
					<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
						AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					</cfif>
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
							OR pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
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
								pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
								
						</cfif>
						
				</cfif>
				
			</cfif>
			
		</cfquery>
		

		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
		    
			<!-- Create a struct to hold the processo data -->
			<!-- Create a structure to hold each row's data -->
			<cfset processo = {}>
			<!-- Manually assign specific columns to the 'processo' structure -->
			<cfset processo.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset processo.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset dataFimProcesso = DateFormat(#pc_data_finalizado#,'DD-MM-YYYY') >
			<cfset processo.DATA_FIM_PROCESSO = dataFimProcesso>
			<cfset processo.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset processo.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
			<cfset processo.PC_NUM_SEI = sei>
			<cfset processo.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
			<cfset processo.DATA_INICIO = dataInicio>
			<cfset dataFim = DateFormat(#pc_data_fimAvaliacao#,'DD-MM-YYYY') >
			<cfset processo.DATA_FIM = dataFim>
			<cfset processo.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset processo.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfif pc_num_avaliacao_tipo neq 2>
				<cfset processo.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_descricao>
			<cfelse>
				<cfset processo.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_nao_aplica_descricao>
			</cfif>
			<cfif #pc_Modalidade# eq 'A'>
				<cfset processo.MODALIDADE = "Acompanhamento">
			<cfelseif #pc_Modalidade# eq 'E'>
				<cfset processo.MODALIDADE = "ENTREGA DO RELATÓRIO">
			<cfelse>
				<cfset processo.MODALIDADE = "Normal">
			</cfif>
			<cfset processo.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfif #pc_tipo_demanda# eq 'P'>
				<cfset processo.TIPO_DEMANDA = "PLANEJADA">
			<cfelseif #pc_tipo_demanda# eq 'E'>
				<cfset processo.TIPO_DEMANDA = "EXTRAORDINÁRIA">
			<cfelse>
				<cfset processo.TIPO_DEMANDA = "Não informado">
			</cfif>
			<cfset processo.AVALIADORES = rsProcTab.avaliadores>
			<cfset processo.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset processo.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<!-- Append the 'processo' structure to the 'processos' array -->
			<cfset arrayAppend(processos, processo)>
		</cfloop>
		<!-- Return the 'processos' array as JSON -->
		<cfreturn processos>
	</cffunction>


	<cffunction name="getItensJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>

		<cfset var rsProcTab = "">
		<cfset var itens = []>
		<cfset var item = {}>
		<cfset var classifRisco = "">

		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >
			SELECT  DISTINCT  pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_numeracao, pc_aval_descricao, pc_aval_id 
						,pc_aval_status_descricao, pc_aval_classificacao
						,pc_aval_vaFalta,pc_aval_vaSobra,pc_aval_vaRisco   
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores

			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						LEFT JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos as pc_orgaos_2 on pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_2.pc_org_mcu
						LEFT JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
			WHERE NOT pc_num_status IN (2,3) and  right(pc_processos.pc_processo_id,4)<=2023
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
					<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
						AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					</cfif>
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
							OR pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_aval_orientacao_mcu_orgaoResp in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#application.orgaosHierarquiaList#)
								OR pc_processos.pc_num_orgao_avaliado in (#application.orgaosHierarquiaList#)
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
								pc_processos.pc_num_orgao_avaliado not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#application.orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#application.orgaosHierarquiaList#)
							)
							
					</cfif>
				
				</cfif>
			
			</cfif>
		
			
		</cfquery>		
		

		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
		    
			<!-- Create a struct to hold the item data -->
			<!-- Create a structure to hold each row's data -->
			<cfset item = {}>
			<!-- Manually assign specific columns to the 'item' structure -->
			<cfset item.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset item.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset dataFimProcesso = DateFormat(#pc_data_finalizado#,'DD-MM-YYYY') >
			<cfset item.DATA_FIM_PROCESSO = dataFimProcesso>
			<cfset item.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset item.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
			<cfset item.PC_NUM_SEI = sei>
			<cfset item.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
			<cfset item.DATA_INICIO = dataInicio>
			<cfset dataFim = DateFormat(#pc_data_fimAvaliacao#,'DD-MM-YYYY') >
			<cfset item.DATA_FIM = dataFim>
			<cfset item.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset item.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfif pc_num_avaliacao_tipo neq 2>
				<cfset item.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_descricao>
			<cfelse>
				<cfset item.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_nao_aplica_descricao>
			</cfif>
			<cfif #pc_Modalidade# eq 'A'>
				<cfset item.MODALIDADE = "Acompanhamento">
			<cfelseif #pc_Modalidade# eq 'E'>
				<cfset item.MODALIDADE = "ENTREGA DO RELATÓRIO">
			<cfelse>
				<cfset item.MODALIDADE = "Normal">
			</cfif>
			<cfset item.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfif #pc_tipo_demanda# eq 'P'>
				<cfset item.TIPO_DEMANDA = "PLANEJADA">
			<cfelseif #pc_tipo_demanda# eq 'E'>
				<cfset item.TIPO_DEMANDA = "EXTRAORDINÁRIA">
			<cfelse>
				<cfset item.TIPO_DEMANDA = "Não informado">
			</cfif>
			<cfset item.AVALIADORES = rsProcTab.avaliadores>
			<cfset item.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset item.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<cfset item.PC_AVAL_ID = rsProcTab.pc_aval_id>
			<cfset item.PC_AVAL_NUMERACAO = rsProcTab.pc_aval_numeracao>
			<cfset item.PC_AVAL_DESCRICAO = rsProcTab.pc_aval_descricao>
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
			<cfset item.CLASSIFICACAO_RISCO = classifRisco>
			<cfset vaFalta = #LSCurrencyFormat(pc_aval_vaFalta, 'local')#>
			<cfset vaSobra = #LSCurrencyFormat(pc_aval_vaSobra, 'local')#>
			<cfset vaRisco = #LSCurrencyFormat(pc_aval_vaRisco, 'local')#>
			<cfset item.VALOR_ENVOLVIDO_FALTA = vaFalta>
			<cfset item.VALOR_ENVOLVIDO_SOBRA = vaSobra>
			<cfset item.VALOR_ENVOLVIDO_RISCO = vaRisco>
			<cfset item.STATUS_ITEM = rsProcTab.pc_aval_status_descricao>
			<!-- Append the 'item' structure to the 'itens' array -->
			<cfset arrayAppend(itens, item)>
		</cfloop>
		<!-- Return the 'itens' array as JSON -->
		<cfreturn itens>
	</cffunction>
	  
    <cffunction name="getOrientacoesJSON" access="remote" returntype="any" returnformat="json" output="false">
		<cfargument name="ano" type="string" required="false" default="Não selecionado"/>

		<cfset var rsProcTab = "">
		<cfset var orientacoes = []>
		<cfset var orientacao = {}>
		<cfset var classifRisco = "">
		<cfset var vaFalta = "">
		<cfset var vaSobra = "">
		<cfset var vaRisco = "">

		<cfquery name="rsProcTab" datasource="#application.dsn_processos#" timeout="120" >

			SELECT  DISTINCT    pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao
						,pc_usuarios.pc_usu_nome  as coordRegional
						,pc_usuCoodNacional.pc_usu_nome  as coordNacional
						,pc_aval_numeracao,pc_aval_descricao , pc_aval_id, pc_aval_orientacao_id
						,pc_aval_orientacao_descricao,pc_aval_orientacao_dataPrevistaResp,pc_aval_orientacao_status
						,pc_orgaos_resp.pc_org_sigla + ' (' + pc_aval_orientacao_mcu_orgaoResp + ')' as orientacaoOrgaoResp
						,pc_orientacao_status.pc_orientacao_status_descricao, pc_aval_status_descricao,pc_aval_classificacao
						,pc_aval_orientacao_dataPrevistaResp,pc_aval_vaFalta,pc_aval_vaSobra,pc_aval_vaRisco   
						,pc_orientacao_status.pc_orientacao_status_finalizador
						,pc_aval_orientacao_status_datahora,
						CASE
							WHEN  CONVERT(VARCHAR(10), pc_aval_orientacao_dataPrevistaResp, 102)  < CONVERT(VARCHAR(10), GETDATE(), 102) AND pc_aval_orientacao_status IN (4, 5) THEN 'PENDENTE'
							ELSE pc_orientacao_status_descricao
						END AS statusDescricao
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores
			FROM        pc_processos 
						LEFT JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id 
						LEFT JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu 
						LEFT JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id 
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu 
						LEFT JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
						INNER JOIN  pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_status on pc_aval_status_id = pc_aval_status
						LEFT JOIN  pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos AS pc_orgaos_resp ON pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp = pc_orgaos_resp.pc_org_mcu 
						LEFT JOIN  pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
						LEFT JOIN  pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN  pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
					    LEFT JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
						LEFT JOIN pc_orgaos AS pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
			WHERE NOT pc_num_status IN (2,3)  and pc_aval_orientacao_id is not null and  right(pc_processos.pc_processo_id,4)<=2023
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
					<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
						AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					</cfif>
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
							pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR  pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							<cfif ListLen(application.orgaosHierarquiaList) GT 0>
								OR pc_processos.pc_num_orgao_avaliado IN (#application.orgaosHierarquiaList#)
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
		

		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
		    
			<!-- Create a struct to hold the orientacao data -->
			<!-- Create a structure to hold each row's data -->
			<cfset orientacao = {}>
			<!-- Manually assign specific columns to the 'orientacao' structure -->
			<cfset orientacao.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset orientacao.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset dataFimProcesso = DateFormat(#pc_data_finalizado#,'DD-MM-YYYY') >
			<cfset orientacao.DATA_FIM_PROCESSO = dataFimProcesso>
			<cfset orientacao.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset orientacao.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
			<cfset orientacao.PC_NUM_SEI = sei>
			<cfset orientacao.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
			<cfset orientacao.DATA_INICIO = dataInicio>
			<cfset dataFim = DateFormat(#pc_data_fimAvaliacao#,'DD-MM-YYYY') >
			<cfset orientacao.DATA_FIM = dataFim>
			<cfset orientacao.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset orientacao.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfif pc_num_avaliacao_tipo neq 2>
				<cfset orientacao.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_descricao>
			<cfelse>
				<cfset orientacao.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_nao_aplica_descricao>
			</cfif>
			<cfif #pc_Modalidade# eq 'A'>
				<cfset orientacao.MODALIDADE = "Acompanhamento">
			<cfelseif #pc_Modalidade# eq 'E'>
				<cfset orientacao.MODALIDADE = "ENTREGA DO RELATÓRIO">
			<cfelse>
				<cfset orientacao.MODALIDADE = "Normal">
			</cfif>
			<cfset orientacao.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfif #pc_tipo_demanda# eq 'P'>
				<cfset orientacao.TIPO_DEMANDA = "PLANEJADA">
			<cfelseif #pc_tipo_demanda# eq 'E'>
				<cfset orientacao.TIPO_DEMANDA = "EXTRAORDINÁRIA">
			<cfelse>
				<cfset orientacao.TIPO_DEMANDA = "Não informado">
			</cfif>
			<cfset orientacao.AVALIADORES = rsProcTab.avaliadores>
			<cfset orientacao.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset orientacao.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<cfset orientacao.PC_AVAL_ID = rsProcTab.pc_aval_id>
			<cfset orientacao.PC_AVAL_NUMERACAO = rsProcTab.pc_aval_numeracao>
			<cfset orientacao.PC_AVAL_DESCRICAO = rsProcTab.pc_aval_descricao>
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
			<cfset orientacao.CLASSIFICACAO_RISCO = classifRisco>
			<cfset vaFalta = #LSCurrencyFormat(pc_aval_vaFalta, 'local')#>
			<cfset vaSobra = #LSCurrencyFormat(pc_aval_vaSobra, 'local')#>
			<cfset vaRisco = #LSCurrencyFormat(pc_aval_vaRisco, 'local')#>
			<cfset orientacao.VALOR_ENVOLVIDO_FALTA = vaFalta>
			<cfset orientacao.VALOR_ENVOLVIDO_SOBRA = vaSobra>
			<cfset orientacao.VALOR_ENVOLVIDO_RISCO = vaRisco>
			<cfset orientacao.STATUS_ITEM = rsProcTab.pc_aval_status_descricao>
			<cfset orientacao.PC_AVAL_ORIENTACAO_ID = rsProcTab.pc_aval_orientacao_id>
			<cfset orientacao.PC_AVAL_ORIENTACAO_DESCRICAO = rsProcTab.pc_aval_orientacao_descricao>
			<cfset orientacao.ORIENTACAO_ORGAO_RESP = rsProcTab.orientacaoOrgaoResp>
			<cfset orientacao.STATUS_ORIENTACAO = rsProcTab.statusDescricao>
			<cfset dataStatusOrientacao = DateFormat(#pc_aval_orientacao_status_datahora#,'DD-MM-YYYY') >
			<cfset orientacao.DATA_STATUS_ORIENTACAO = dataStatusOrientacao>
			<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,'DD-MM-YYYY') >
			<cfif pc_aval_orientacao_status eq 4 and pc_aval_orientacao_status eq 5>
				<cfset orientacao.DATA_PREV_RESP = dataPrev>
			<cfelse>
				<cfset orientacao.DATA_PREV_RESP = "">
			</cfif>
			<cfif pc_orientacao_status_finalizador eq "S">
				<cfset orientacao.ACOMP_FINALIZADO = "Sim">
			<cfelse>
				<cfset orientacao.ACOMP_FINALIZADO = "Não">
			</cfif>
			<!-- Append the 'orientacao' structure to the 'orientacoes' array -->
			<cfset arrayAppend(orientacoes, orientacao)>
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
		<cfset var vaFalta = "">
		<cfset var vaSobra = "">
		<cfset var vaRisco = "">
		<cfset var statusMelhoria = "">
		<cfset var dataPrev = "">

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
						,pc_aval_vaFalta,pc_aval_vaSobra,pc_aval_vaRisco
						,pc_aval_id, pc_aval_melhoria_id
						,COALESCE(
							(SELECT STRING_AGG(pc_usu_nome, '; ') 
							FROM pc_avaliadores 
							INNER JOIN pc_usuarios 
							ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
							INNER JOIN pc_orgaos 
							ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
							WHERE pc_avaliador_id_processo = pc_processo_id),'NÃO DEFINIDO'
						) AS avaliadores

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
			            
			WHERE NOT pc_num_status IN (2,3) and  right(pc_processos.pc_processo_id,4)<=2023
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>	
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
					<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI) --->
					<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
						AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
					</cfif>
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
		
		<!-- Loop through the query result 'rsProcTab' -->
		<cfloop query="rsProcTab">
		    
			<!-- Create a structure to hold each row's data -->
			<cfset proposta = {}>
			<!-- Manually assign specific columns to the 'proposta' structure -->
			<cfset proposta.PC_PROCESSO_ID = rsProcTab.pc_processo_id>
			<cfset proposta.PC_STATUS_DESCRICAO = rsProcTab.pc_status_descricao>
			<cfset dataFimProcesso = DateFormat(#pc_data_finalizado#,'DD-MM-YYYY') >
			<cfset proposta.DATA_FIM_PROCESSO = dataFimProcesso>
			<cfset proposta.SE_ORGAO_AVALIADO = rsProcTab.seOrgAvaliado>
			<cfset proposta.PC_ANO_PACIN = rsProcTab.pc_ano_pacin>
			<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
			<cfset proposta.PC_NUM_SEI = sei>
			<cfset proposta.PC_NUM_REL_SEI = rsProcTab.pc_num_rel_sei>
			<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
			<cfset proposta.DATA_INICIO = dataInicio>
			<cfset dataFim = DateFormat(#pc_data_fimAvaliacao#,'DD-MM-YYYY') >
			<cfset proposta.DATA_FIM = dataFim>
			<cfset proposta.SIGLA_ORGAO_ORIGEM = rsProcTab.siglaOrgOrigem>
			<cfset proposta.SIGLA_ORGAO_AVALIADO = rsProcTab.siglaOrgAvaliado>
			<cfif pc_num_avaliacao_tipo neq 2>
				<cfset proposta.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_descricao>
			<cfelse>
				<cfset proposta.PC_AVAL_TIPO_DESCRICAO = rsProcTab.pc_aval_tipo_nao_aplica_descricao>
			</cfif>
			<cfif #pc_Modalidade# eq 'A'>
				<cfset proposta.MODALIDADE = "Acompanhamento">
			<cfelseif #pc_Modalidade# eq 'E'>
				<cfset proposta.MODALIDADE = "ENTREGA DO RELATÓRIO">
			<cfelse>
				<cfset proposta.MODALIDADE = "Normal">
			</cfif>
			<cfset proposta.PC_CLASS_DESCRICAO = rsProcTab.pc_class_descricao>
			<cfif #pc_tipo_demanda# eq 'P'>
				<cfset proposta.TIPO_DEMANDA = "PLANEJADA">
			<cfelseif #pc_tipo_demanda# eq 'E'>
				<cfset proposta.TIPO_DEMANDA = "EXTRAORDINÁRIA">
			<cfelse>
				<cfset proposta.TIPO_DEMANDA = "Não informado">
			</cfif>
			<cfset proposta.AVALIADORES = rsProcTab.avaliadores>
			<cfset proposta.COORDENADOR_REGIONAL = rsProcTab.coordRegional>
			<cfset proposta.COORDENADOR_NACIONAL = rsProcTab.coordNacional>
			<cfset proposta.PC_AVAL_ID = rsProcTab.pc_aval_id>
			<cfset proposta.PC_AVAL_NUMERACAO = rsProcTab.pc_aval_numeracao>
			<cfset proposta.PC_AVAL_DESCRICAO = rsProcTab.pc_aval_descricao>
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
			<cfset proposta.CLASSIFICACAO_RISCO = classifRisco>
			<cfset vaFalta = #LSCurrencyFormat(pc_aval_vaFalta, 'local')#>
			<cfset vaSobra = #LSCurrencyFormat(pc_aval_vaSobra, 'local')#>
			<cfset vaRisco = #LSCurrencyFormat(pc_aval_vaRisco, 'local')#>
			<cfset proposta.VALOR_ENVOLVIDO_FALTA = vaFalta>
			<cfset proposta.VALOR_ENVOLVIDO_SOBRA = vaSobra>
			<cfset proposta.VALOR_ENVOLVIDO_RISCO = vaRisco>
			<cfset proposta.STATUS_ITEM = rsProcTab.pc_aval_status_descricao>
			<cfset proposta.PC_AVAL_MELHORIA_ID = rsProcTab.pc_aval_melhoria_id>
			<cfset proposta.PC_AVAL_MELHORIA_DESCRICAO = rsProcTab.pc_aval_melhoria_descricao>
			<cfset proposta.ORGAO_RESP = rsProcTab.orgaoResp>
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
			<cfset proposta.STATUS_MELHORIA = statusMelhoria>
			<cfset dataPrev = DateFormat(#pc_aval_melhoria_dataPrev#,'DD-MM-YYYY') >
			<cfset proposta.DATA_PREV = dataPrev>
			<cfset proposta.MELHORIA_SUGERIDA = rsProcTab.pc_aval_melhoria_sugestao>
			<cfset proposta.ORGAO_RESP_SUGERIDO = rsProcTab.orgaoRespSug>
			<cfset proposta.JUSTIFICATIVA_RECUSA = rsProcTab.pc_aval_melhoria_naoAceita_justif>
			<!-- Append the 'proposta' structure to the 'propostasMelhoria' array -->
			<cfset arrayAppend(propostasMelhoria, proposta)>
		</cfloop>
		<!-- Return the 'propostasMelhoria' array as JSON -->
		<cfreturn propostasMelhoria>
	</cffunction>


</cfcomponent>