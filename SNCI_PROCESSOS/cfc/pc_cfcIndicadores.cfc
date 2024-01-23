<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	


	<cfquery name="rsHerancaUnion" datasource="#application.dsn_processos#">
		SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' 

		union

		SELECT  pc_orgaos2.pc_org_mcu
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' )) 

		union

		select pc_orgaos.pc_org_mcu AS mcuHerdado
		from pc_orgaos
		LEFT JOIN pc_orgaos_heranca ON pc_orgHerancaMcuDe = pc_org_mcu
		where pc_orgaos.pc_org_mcu_subord_tec in(SELECT  pc_orgaos2.pc_org_mcu
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		LEFT JOIN pc_orgaos as pc_orgaos2 ON pc_orgaos2.pc_org_mcu_subord_tec = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and (pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' or pc_orgaos2.pc_org_mcu_subord_tec in(SELECT pc_orgaos.pc_org_mcu AS mcuHerdado
		FROM pc_orgaos_heranca
		LEFT JOIN pc_orgaos ON pc_org_mcu = pc_orgHerancaMcuDe
		WHERE pc_orgHerancaDataInicio <= CONVERT (date, GETDATE()) and pc_orgHerancaMcuPara ='#application.rsUsuarioParametros.pc_usu_lotacao#' )))
	</cfquery>

	<cfquery dbtype="query" name="rsHeranca"> 
		SELECT mcuHerdado FROM rsHerancaUnion WHERE not mcuHerdado is null
	</cfquery>

	<cfset mcusHeranca = ValueList(rsHeranca.mcuHerdado) />


	<cffunction name="tabIndicadores"   access="remote" hint="gera a consulta para página de indicadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	



		<cfquery name="rs_Orientacao_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				CASE
					WHEN pc_aval_posic_dataPrevistaResp < GETDATE() THEN 'PENDENTE'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientaçãoStatus,

				CASE
					WHEN pc_aval_posic_dataPrevistaResp < GETDATE() THEN 'FP'
					ELSE 'DP'
				END AS Prazo
			FROM (
				SELECT
					pc_aval_posic_id,
					pc_aval_posic_num_orientacao,
					pc_aval_posic_status,
					pc_aval_posic_num_orgaoResp,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				 WHERE 
            		pc_aval_posic_enviado = 1
				
			
					
			) AS ranked_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE
				ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (4, 5)
				AND pc_aval_posic_enviado = 1
				AND (
					pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_orientacao_mcu_orgaoResp IN (
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
					)
					<cfif mcusHeranca neq ''>OR pc_aval_orientacao_mcu_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
					
		</cfquery>

		<cfquery name="rs_Orientacao_Respondida" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_avaliacao_posicionamentos.pc_aval_posic_datahora) as dataPosicao,
				pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao as orientacao,
				pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp as dataPrevista,
				CASE
					WHEN pc_avaliacao_posicionamentos.pc_aval_posic_status IN (3) THEN 'RESPONDIDO'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus,
				CASE
					WHEN pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp < GETDATE() THEN 'FP'
					ELSE 'DP'
				END AS Prazo
			FROM pc_avaliacao_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON pc_avaliacao_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE pc_avaliacao_posicionamentos.pc_aval_posic_status IN (3)
				AND (
					pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_orientacao_mcu_orgaoResp IN (
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
					)
					<cfif mcusHeranca neq ''>OR pc_aval_orientacao_mcu_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				
		AND pc_avaliacao_posicionamentos.pc_aval_posic_datahora 
		BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
		AND pc_avaliacao_posicionamentos.pc_aval_posic_enviado = 1
		</cfquery>	

		<cfquery name="rs_Orientacao" dbtype="query">
			SELECT * FROM rs_Orientacao_agora
			UNION
			SELECT * FROM rs_Orientacao_Respondida
		</cfquery>

		<cfreturn #rs_Orientacao.recordcount#>

	</cffunction>





	



</cfcomponent>