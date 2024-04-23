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

	<cffunction name="verificaExisteDadosGerados"   access="remote" hint="verifica se os dados para o mês e ano selecionados já existem na tabela pc_indicador_dados">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
        <cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
		
		<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso WHERE pc_indPeso_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			 and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
			 and pc_indPeso_ativo = 1
		</cfquery>

		<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso WHERE pc_indPeso_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
			and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
			 and pc_indPeso_ativo = 1
		</cfquery>


		<cfif rsPRCIpeso.recordcount eq 0 or rsSLNCpeso.recordcount eq 0>
			<cfoutput>-1</cfoutput> 
		<cfelse>
		    <cfquery name="rsIndicadorDados" datasource="#application.dsn_processos#">
				SELECT pc_indDados_id FROM pc_indicadores_dados 
				WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
			</cfquery>
			<cfoutput>#rsIndicadorDados.recordcount#</cfoutput> 
		</cfif>
	</cffunction>

	<cffunction name="mesesDadosGerados"   access="remote" hint="os meses do ano que já possuem dados gerados">
		<cfargument name="ano" type="string" required="true" />
      
		
		<cfquery name="rsIndicadorDados" datasource="#application.dsn_processos#">
			SELECT 
				pc_indDados_dataRef, 
				pc_indDados_matriculaGeracao,
				MAX(pc_indDados_dataHoraGeracao) AS max_dataHoraGeracao
			FROM 
				pc_indicadores_dados
			WHERE 
				YEAR(pc_indDados_dataRef) = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
			GROUP BY 
				pc_indDados_dataRef, 
				pc_indDados_matriculaGeracao
			ORDER BY 
				pc_indDados_dataRef DESC
		</cfquery>



		<cfif #rsIndicadorDados.recordcount# neq 0 >
			<div class="card"  >
				<!-- card-body -->
				<div class="card-body" >
					<cfoutput>
						<h5 style="color:##000;text-align: center;">Dados gerados para os indicadores de <strong>#arguments.ano#</strong></h5>
						
					</cfoutput>
					<table id="tabelaDados" class="table table-bordered table-striped text-nowrap no-footer" style="user-select: none;width: 100%; margin: 0 auto;margin-bottom:200px">
						<thead>
							<tr style="text-align: center;"  >
								<th>Mês/Ano</th>
								<th>Data/Hora</th>
								<th>Usuário</th>
								<cfif application.rsUsuarioParametros.pc_usu_perfil eq 3>
									<th>Excluir</th>
								</cfif>
							</tr>
						</thead>
						<tbody>
						  
							<cfoutput query="rsIndicadorDados">
								<tr style="text-align: center;"  >
									<td>#dateFormat(pc_indDados_dataRef, 'mm/yyyy')#</td>
									<td>#DateFormat(max_dataHoraGeracao, "dd/mm/yyyy")# - #TimeFormat(max_dataHoraGeracao, "HH:mm:ss")#</td>
									<cfif pc_indDados_matriculaGeracao eq "A">
										<td>Rotina Automática</td>
									<cfelse>
										<!--retorna o nome do usuário que gerou os dados-->
										<cfquery name="rsUsuarioGerador" datasource="#application.dsn_processos#">
											SELECT pc_usu_nome FROM pc_usuarios WHERE pc_usu_matricula = <cfqueryparam value="#pc_indDados_matriculaGeracao#" cfsqltype="cf_sql_varchar">
										</cfquery>

										<td>#rsUsuarioGerador.pc_usu_nome#</td>
									</cfif>
									<cfif application.rsUsuarioParametros.pc_usu_perfil eq 3>
										<td><a id="btExcluir Dados" onclick="excluirDados(#dateFormat(pc_indDados_dataRef, 'mm')#)" ><i class="fas fa-trash-alt grow-icon delete-button"></i></a></td>
									</cfif>
								</tr>
								
							</cfoutput>
						</tbody>
						
					</table>
				</div>
			</div>
		<cfelse>
			<cfoutput><h5 style="color:##000;text-align: center;">Não existem dados gerados para o ano #arguments.ano#</h5></cfoutput>
		</cfif>
		
		<script language="JavaScript">
    
			$(document).ready(function(){
				$('#tabelaDados').DataTable({
					order: [[0, 'desc']], // Ordena a tabela pela primeira coluna (data) de forma decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false // Remove o campo de busca
					
				});
				$(".content-wrapper").css("height", "auto");
			});

			function excluirDados(mesSelecionado){
				let ano = parseInt($('input[name=ano]:checked').val());
				let mes = mesSelecionado;

				var mensagem = 'Deseja realmente excluir os dados do mês '+mes+'/'+ano+'?';
					Swal.fire({
						title: mensagem,
						showDenyButton: true,
						confirmButtonText: `Sim`,
						denyButtonText: `Não`,
					}).then((result) => {
						/* Read more about isConfirmed, isDenied below */
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show')
							setTimeout(function() {	
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcIndicadores_gerarDados.cfc",
									data:{
										method:"deletaDadosParaIndicadores",
										ano:ano,
										mes:mes
									},
									async: false,
									success: function(data){
										// Chamar a função para obter os dados quando o documento estiver pronto
										obterDados();
										$('#modalOverlay').delay(500).hide(0, function() {
											$('#modalOverlay').modal('hide');
											Swal.fire('Dados excluídos com sucesso!', '', 'success')
											$(".content-wrapper").css("height", "auto");
										});	
									},
									error: function(xhr, ajaxOptions, thrownError) {
										$('#modalOverlay').delay(500).hide(0, function() {
											$('#modalOverlay').modal('hide');
											
										});
										$('#modal-danger').modal('show')//MOSTRA O MODAL DE ERRO
										$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')//INSERE O TITULO DO MODAL
										$('#modal-danger').find('.modal-body').text(thrownError)//INSERE O CORPO DO MODAL	
											
									}
								});
							}, 500);
						} else if (result.isDenied) {
							Swal.fire('Os dados não foram excluídos.', '', 'info')
						}
					})

			}
		</script>




		
		
	</cffunction>

	<cffunction name="gerarDadosParaIndicadoresMensal"   access="remote" hint="gera os dados para os indicadores e insere na tabela pc_indicadores_dados - acompanhamento mensal">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfargument name="tipoRotina" type="string" required="false" default="A" />
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_Orientacao_prci" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliado,
				orgaoResp.pc_org_mcu as orgaoResp,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				CASE
					WHEN (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp < <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
					OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp < GETDATE()) 
					THEN 'PENDENTE'	ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus,

				CASE
					WHEN (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp < <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
					OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp < GETDATE()) 
					THEN 'FP' ELSE 'DP'
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
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				 WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (4, 5)
				AND pc_aval_posic_enviado = 1
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>

		<cfquery name="rs_Orientacao_Respondida_prci" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliado,
				orgaoResp.pc_org_mcu as orgaoResp,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_avaliacao_posicionamentos.pc_aval_posic_datahora) as dataPosicao,
				pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao as orientacao,
				pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				CASE
					WHEN pc_avaliacao_posicionamentos.pc_aval_posic_status IN (3) THEN 'RESPONDIDO'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus,
				CASE
					WHEN pc_avaliacao_posicionamentos.pc_aval_posic_dataPrevistaResp < pc_avaliacao_posicionamentos.pc_aval_posic_datahora THEN 'FP'
					ELSE 'DP'
				END AS Prazo
			FROM pc_avaliacao_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON pc_avaliacao_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE pc_avaliacao_posicionamentos.pc_aval_posic_status IN (3)
				AND pc_avaliacao_posicionamentos.pc_aval_posic_datahora 
				BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_avaliacao_posicionamentos.pc_aval_posic_enviado = 1
		</cfquery>	

		<cfquery name="rs_solucionados_slnc" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliado,
				orgaoResp.pc_org_mcu as orgaoResp,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				pc_orientacao_status.pc_orientacao_status_descricao AS OrientacaoStatus

			FROM (
				SELECT
					pc_aval_posic_id,
					pc_aval_posic_num_orientacao,
					pc_aval_posic_status,
					pc_aval_posic_num_orgaoResp,
					pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp as orgaoResponsavelMCU,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				INNER JOIN pc_avaliacao_orientacoes ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
				WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			LEFT JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.orgaoResponsavelMCU = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE
				ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (6)
				AND pc_aval_posic_enviado = 1
				AND pc_aval_posic_datahora
				BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>


		<cfquery name="rs_tratamento_slnc" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliado,
				orgaoResp.pc_org_mcu as orgaoResp,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				CASE
					WHEN ((<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> <= GETDATE() and pc_aval_posic_dataPrevistaResp < <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">) 
					OR (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date"> > GETDATE() and pc_aval_posic_dataPrevistaResp < GETDATE()))  AND pc_aval_posic_status = 5 THEN 'PENDENTE'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus

			FROM (
				SELECT
					pc_aval_posic_id,
					pc_aval_posic_num_orientacao,
					pc_aval_posic_status,
					pc_aval_posic_num_orgaoResp,
					pc_aval_posic_datahora,
					pc_aval_posic_dataPrevistaResp,
					pc_aval_posic_enviado,
					pc_aval_posic_num_orgao,
					ROW_NUMBER() OVER (PARTITION BY pc_aval_posic_num_orientacao ORDER BY pc_aval_posic_dataHora desc, pc_aval_posic_id desc) as row_num
				FROM
					pc_avaliacao_posicionamentos
				WHERE 
            		pc_aval_posic_enviado = 1
					AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
	
			) AS ranked_posicionamentos
			INNER JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
			INNER JOIN pc_orgaos as orgaoDaAcao ON ranked_posicionamentos.pc_aval_posic_num_orgao = orgaoDaAcao.pc_org_mcu
			INNER JOIN pc_avaliacao_orientacoes ON ranked_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
			INNER JOIN pc_avaliacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
			INNER JOIN pc_processos ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
			INNER JOIN pc_orgaos as orgaoAvaliado ON pc_processos.pc_num_orgao_avaliado = orgaoAvaliado.pc_org_mcu
			INNER JOIN pc_orientacao_status ON ranked_posicionamentos.pc_aval_posic_status = pc_orientacao_status.pc_orientacao_status_id
			WHERE
				ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (5)
				AND pc_aval_posic_enviado = 1
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
		</cfquery>



		<cfquery name="rs_dados_prci" dbtype="query">
			SELECT * FROM rs_Orientacao_prci
			UNION
			SELECT * FROM rs_Orientacao_Respondida_prci
		</cfquery>

		<cfquery name="rs_dados_slnc" dbtype="query">
			SELECT * FROM rs_solucionados_slnc
			UNION
			SELECT * FROM rs_tratamento_slnc
		</cfquery>
		
		
		<cfloop query="rs_dados_prci">
			<cfquery name="mcuOrgaoSubordinador" datasource="#application.dsn_processos#" timeout="120">
				WITH OrgHierarchy AS (
									SELECT pc_org_mcu, pc_org_sigla, pc_org_mcu_subord_tec, pc_org_status, pc_org_orgaoAvaliado, 1 AS Level
									FROM pc_orgaos
									WHERE pc_org_mcu = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#rs_dados_prci.orgaoResp#">

									UNION ALL

									SELECT o.pc_org_mcu, o.pc_org_sigla, o.pc_org_mcu_subord_tec, o.pc_org_status, o.pc_org_orgaoAvaliado, h.Level + 1
									FROM pc_orgaos o
									INNER JOIN OrgHierarchy h ON o.pc_org_mcu = h.pc_org_mcu_subord_tec
									WHERE h.Level < 10 
								)
				SELECT pc_org_mcu  
				FROM OrgHierarchy  
				WHERE pc_org_orgaoAvaliado = 1
			</cfquery>

		    <cfif rs_dados_prci.orgaoDaAcaoEdoControleInterno eq 'N' AND (rs_dados_prci.pc_aval_posic_status eq 4 OR rs_dados_prci.pc_aval_posic_status eq 5)>
				<cfset distribuida = 1>
			<cfelse>
				<cfset distribuida = 0>
			</cfif>
			<cfif rs_dados_prci.orgaoDaAcaoEdoControleInterno eq 'N'>
				<cfset ehControleInteno = 0>
			<cfelse>
				<cfset ehControleInteno = 1>
			</cfif>
			<cfif arguments.tipoRotina eq "A">
				<cfset matricula = "A">
			<cfelse>
				<cfset matricula = application.rsUsuarioParametros.pc_usu_matricula>
			</cfif>

			<cfif mcuOrgaoSubordinador.pc_org_mcu  neq "">
				<cfquery datasource="#application.dsn_processos#">
					INSERT INTO pc_indicadores_dados(pc_indDados_dataRef
													,pc_indDados_numIndicador
													,pc_indDados_matriculaGeracao
													,pc_indDados_mcuOrgaoSubordinador
													,pc_indDados_numPosic
													,pc_indDados_mcuOrgaoAvaliado
													,pc_indDados_mcuOrgaoResp
													,pc_indDados_numProcesso
													,pc_indDados_numItem
													,pc_indDados_numOrientacao
													,pc_indDados_dataPrevista
													,pc_indDados_dataStatus
													,pc_indDados_status
													,pc_indDados_orientacaoDistribuida
													,pc_indDados_descricaoStatus
													,pc_indDados_prazo
													,pc_indDados_mcuOrgaoPosicEcontInterno)
					VALUES (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
						,1
						,<cfqueryparam value="#matricula#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#mcuOrgaoSubordinador.pc_org_mcu#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_prci.pc_aval_posic_id#" cfsqltype="cf_sql_integer">
						,<cfqueryparam value="#rs_dados_prci.orgaoAvaliado#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_prci.orgaoResp#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_prci.numProcessoSNCI#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_prci.item#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_prci.orientacao#" cfsqltype="cf_sql_integer">
						,<cfqueryparam value="#rs_dados_prci.dataPrevista#" cfsqltype="cf_sql_date">
						,<cfqueryparam value="#rs_dados_prci.dataPosicao#" cfsqltype="cf_sql_date">
						,<cfqueryparam value="#rs_dados_prci.pc_aval_posic_status#" cfsqltype="cf_sql_integer">
						,<cfqueryparam value="#distribuida#" cfsqltype="cf_sql_bit">
						,<cfqueryparam value="#rs_dados_prci.OrientacaoStatus#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_prci.Prazo#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#ehControleInteno#" cfsqltype="cf_sql_bit">
					)
				</cfquery>
			</cfif>
		</cfloop>

		<cfloop query="rs_dados_slnc">
			<cfquery name="mcuOrgaoSubordinador" datasource="#application.dsn_processos#" timeout="120">
				WITH OrgHierarchy AS (
									SELECT pc_org_mcu, pc_org_sigla, pc_org_mcu_subord_tec, pc_org_status, pc_org_orgaoAvaliado, 1 AS Level
									FROM pc_orgaos
									WHERE pc_org_mcu = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#rs_dados_slnc.orgaoResp#">

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
		    <cfif rs_dados_slnc.orgaoDaAcaoEdoControleInterno eq 'N' AND rs_dados_slnc.pc_aval_posic_status eq 5>
				<cfset distribuida = 1>
			<cfelse>
				<cfset distribuida = 0>
			</cfif>
			<cfif rs_dados_prci.orgaoDaAcaoEdoControleInterno eq 'N'>
				<cfset ehControleInteno = 0>
			<cfelse>
				<cfset ehControleInteno = 1>
			</cfif>
			<cfif mcuOrgaoSubordinador.pc_org_mcu  neq "">
				<cfquery datasource="#application.dsn_processos#">
					INSERT INTO pc_indicadores_dados(pc_indDados_dataRef
													,pc_indDados_numIndicador
													,pc_indDados_matriculaGeracao
													,pc_indDados_mcuOrgaoSubordinador
													,pc_indDados_numPosic
													,pc_indDados_mcuOrgaoAvaliado
													,pc_indDados_mcuOrgaoResp
													,pc_indDados_numProcesso
													,pc_indDados_numItem
													,pc_indDados_numOrientacao
													,pc_indDados_dataPrevista
													,pc_indDados_dataStatus
													,pc_indDados_status
													,pc_indDados_orientacaoDistribuida
													,pc_indDados_descricaoStatus
													,pc_indDados_prazo
													,pc_indDados_mcuOrgaoPosicEcontInterno)
					VALUES (<cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
						,2
						,<cfqueryparam value="#matricula#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#mcuOrgaoSubordinador.pc_org_mcu#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_slnc.pc_aval_posic_id#" cfsqltype="cf_sql_integer">
						,<cfqueryparam value="#rs_dados_slnc.orgaoAvaliado#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_slnc.orgaoResp#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_slnc.numProcessoSNCI#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_slnc.item#" cfsqltype="cf_sql_varchar">
						,<cfqueryparam value="#rs_dados_slnc.orientacao#" cfsqltype="cf_sql_integer">
						,<cfqueryparam value="#rs_dados_slnc.dataPrevista#" cfsqltype="cf_sql_date">
						,<cfqueryparam value="#rs_dados_slnc.dataPosicao#" cfsqltype="cf_sql_date">
						,<cfqueryparam value="#rs_dados_slnc.pc_aval_posic_status#" cfsqltype="cf_sql_integer">
						,<cfqueryparam value="#distribuida#" cfsqltype="cf_sql_bit">
						,<cfqueryparam value="#rs_dados_slnc.OrientacaoStatus#" cfsqltype="cf_sql_varchar">
						,null
						,<cfqueryparam value="#ehControleInteno#" cfsqltype="cf_sql_bit">
					)
				</cfquery>
			</cfif>
		</cfloop>


	</cffunction>

	<cffunction name="gerarDadosParaIndicadoresMensalPorOrgao"   access="remote" hint="gera os dados para os indicadores e insere na tabela pc_indicador_porOrgao - acompanhamento mensal"> 
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfargument name="tipoRotina" type="string" required="false" default="A" />

		
		<cfset ano = arguments.ano>
		<cfset mes = arguments.mes>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
		<cfif arguments.tipoRotina eq "A">
			<cfset matricula = "A">
		<cfelse>
			<cfset matricula = application.rsUsuarioParametros.pc_usu_matricula>
		</cfif>

		<cfquery name="dadosAno_CI" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_orgaoSubordinador.pc_org_mcu as mcuOrgaoSubordinador
					,pc_orgaoResp.pc_org_mcu as mcuOrgaoResp
					,MONTH(pc_indDados_dataRef) AS mes
					,YEAR(pc_indDados_dataRef) AS ano
					,pc_indDados_numIndicador
					,CASE WHEN pc_indDados_prazo = 'DP' THEN 1 ELSE 0 END AS DP
					,CASE WHEN pc_indDados_status = 6 THEN 1 ELSE 0 END AS solucionado
			FROM pc_indicadores_dados		
			INNER JOIN pc_orgaos as pc_orgaoAvaliado ON pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			INNER JOIN pc_orgaos as pc_orgaoResp ON pc_orgaoResp.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaoSubordinador ON pc_orgaoSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			WHERE YEAR(pc_indDados_dataRef) = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery name="resultadoPRCIporOrgaoResp" dbtype="query">
			SELECT	ano
					,mes
					,pc_indDados_numIndicador as numIndicador
					,mcuOrgaoResp as mcuOrgao
					,mcuOrgaoSubordinador 
					,(SUM(DP)/COUNT(*))*100 AS resultadoIndicador
					,0 as paraOrgaoSubordinador
			FROM dadosAno_CI
			WHERE mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indDados_numIndicador = 1
			GROUP BY ano, mes, pc_indDados_numIndicador, mcuOrgaoResp,mcuOrgaoSubordinador 
		</cfquery>

		<cfquery name="resultadoPRCIporOrgaoSubordinador" dbtype="query">
			SELECT	ano
					,mes
					,numIndicador
					,mcuOrgaoSubordinador as mcuOrgao
					,mcuOrgaoSubordinador
					,AVG(resultadoIndicador) as resultadoIndicador
					,1 as paraOrgaoSubordinador
			FROM resultadoPRCIporOrgaoResp
			GROUP BY ano, mes, numIndicador, mcuOrgaoSubordinador
			order by mcuOrgaoSubordinador
		</cfquery>

		<cfquery name="resultadoSLNCporOrgaoResp" dbtype="query">
			SELECT	ano
					,mes
					,pc_indDados_numIndicador as numIndicador
					,mcuOrgaoResp  as mcuOrgao
					,mcuOrgaoSubordinador 
					,(SUM(solucionado)/COUNT(*))*100 AS resultadoIndicador
					,0 as paraOrgaoSubordinador
			FROM dadosAno_CI
			WHERE mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
				AND pc_indDados_numIndicador = 2
			GROUP BY ano, mes, pc_indDados_numIndicador, mcuOrgaoResp,mcuOrgaoSubordinador 
		</cfquery>

		<cfquery name="resultadoSLNCporOrgaoSubordinador" dbtype="query">
			SELECT	ano
					,mes
					,numIndicador
					,mcuOrgaoSubordinador as mcuOrgao
					,mcuOrgaoSubordinador
					,AVG(resultadoIndicador) as resultadoIndicador
					,1 as paraOrgaoSubordinador
			FROM resultadoSLNCporOrgaoResp
			GROUP BY ano, mes, numIndicador, mcuOrgaoSubordinador
			order by mcuOrgaoSubordinador
		</cfquery>


		<!-- consulta união dos resultados  -->
		<cfquery name="resultadoIndicadoresPorOrgao" dbtype="query">
			SELECT	* FROM resultadoPRCIporOrgaoSubordinador
			UNION
			SELECT	* FROM resultadoPRCIporOrgaoResp
			UNION
			SELECT	* FROM resultadoSLNCporOrgaoSubordinador
			UNION
			SELECT	* FROM resultadoSLNCporOrgaoResp
		</cfquery>

		<!--insere os dados dos indicadores da cesta (PRCI e SLNC) na tabela pc_indicadores_porOrgao-->
		<cfloop query="resultadoIndicadoresPorOrgao">

			<!-- cfquery que retorna pc_indOrgao_resultadoAcumulado do mês anterior da tabela pc_indicadores_porOrgaos -->
			<cfquery name="resultadoIndicadorAcumuladoMesAnterior" datasource="#application.dsn_processos#" timeout="120"  >
				SELECT TOP 1 pc_indOrgao_resultadoAcumulado
				FROM pc_indicadores_porOrgao
				WHERE 	pc_indOrgao_ano = <cfqueryparam value="#resultadoIndicadoresPorOrgao.ano#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_mes < <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
						AND NOT pc_indOrgao_resultadoAcumulado IS NULL
						AND pc_indOrgao_numIndicador = <cfqueryparam value="#resultadoIndicadoresPorOrgao.numIndicador#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoIndicadoresPorOrgao.mcuOrgao#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery name="rsContarMeses" datasource="#application.dsn_processos#" timeout="120"  >
				SELECT COUNT(DISTINCT pc_indOrgao_mes) as quantMeses
				FROM pc_indicadores_porOrgao
				WHERE 	pc_indOrgao_ano = <cfqueryparam value="#resultadoIndicadoresPorOrgao.ano#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_mes < <cfqueryparam value="#resultadoIndicadoresPorOrgao.mes#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_numIndicador = <cfqueryparam value="#resultadoIndicadoresPorOrgao.numIndicador#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoIndicadoresPorOrgao.mcuOrgao#" cfsqltype="cf_sql_varchar">
			</cfquery>


			<cfif resultadoIndicadorAcumuladoMesAnterior.recordCount eq 0>
				<cfset resultadoIndicadorAcumulado = resultadoIndicadoresPorOrgao.resultadoIndicador>
			<cfelse>
				<cfset resultadoIndicadorAcumulado = (resultadoIndicadorAcumuladoMesAnterior.pc_indOrgao_resultadoAcumulado + resultadoIndicadoresPorOrgao.resultadoIndicador)/(rsContarMeses.quantMeses+1)>
			</cfif>
			
			<cfquery name="insereDadosIndicadoresporOrgao" datasource="#application.dsn_processos#" timeout="120"  >
				INSERT INTO pc_indicadores_porOrgao
				(pc_indOrgao_ano, pc_indOrgao_mes, pc_indOrgao_numIndicador, pc_indOrgao_mcuOrgao, pc_indOrgao_resultadoMes, pc_indOrgao_resultadoAcumulado, pc_indOrgao_paraOrgaoSubordinador, pc_indOrgao_mcuOrgaoSubordinador)
				VALUES
				(	<cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#numIndicador#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#mcuOrgao#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#ROUND(resultadoIndicador*10)/10#" cfsqltype="cf_sql_float">
					,<cfqueryparam value="#ROUND(resultadoIndicadorAcumulado*10)/10#" cfsqltype="cf_sql_float">
					,<cfqueryparam value="#paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#mcuOrgaoSubordinador#" cfsqltype="cf_sql_varchar">
				)
			</cfquery>
			
		</cfloop>

		<cfquery name="resultadoTIDPporOrgaoResp" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	YEAR(pc_indDados_dataRef) AS ano
					,MONTH(pc_indDados_dataRef) AS mes
					,pc_indDados_mcuOrgaoResp
					,pc_indDados_mcuOrgaoSubordinador 
					,count(*) AS resultadoIndicador
					,0 as paraOrgaoSubordinador
					,4 as numIndicador
			FROM pc_indicadores_dados
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_indDados_numIndicador = 1
				AND pc_indDados_prazo = 'DP'
			GROUP BY pc_indDados_dataRef, pc_indDados_mcuOrgaoResp,pc_indDados_mcuOrgaoSubordinador 
		</cfquery>

		<cfquery name="resultadoTGIporOrgaoResp" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	YEAR(pc_indDados_dataRef) AS ano
					,MONTH(pc_indDados_dataRef) AS mes
					,pc_indDados_mcuOrgaoResp
					,pc_indDados_mcuOrgaoSubordinador 
					,count(*) AS resultadoIndicador
					,0 as paraOrgaoSubordinador
					,5 as numIndicador
			FROM pc_indicadores_dados
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_indDados_numIndicador = 1
			GROUP BY pc_indDados_dataRef, pc_indDados_mcuOrgaoResp,pc_indDados_mcuOrgaoSubordinador 
		</cfquery>

		<cfquery name="resultadoQTSLporOrgaoResp" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	YEAR(pc_indDados_dataRef) AS ano
					,MONTH(pc_indDados_dataRef) AS mes
					,pc_indDados_mcuOrgaoResp
					,pc_indDados_mcuOrgaoSubordinador 
					,count(*) AS resultadoIndicador
					,0 as paraOrgaoSubordinador
					,6 as numIndicador
			FROM pc_indicadores_dados
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_indDados_numIndicador = 2
				AND pc_indDados_status = 6
			GROUP BY pc_indDados_dataRef, pc_indDados_mcuOrgaoResp,pc_indDados_mcuOrgaoSubordinador
		</cfquery>
		
		<cfquery name="resultadoQTNCporOrgaoResp" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	YEAR(pc_indDados_dataRef) AS ano
					,MONTH(pc_indDados_dataRef) AS mes
					,pc_indDados_mcuOrgaoResp
					,pc_indDados_mcuOrgaoSubordinador 
					,count(*) AS resultadoIndicador
					,0 as paraOrgaoSubordinador
					,7 as numIndicador
			FROM pc_indicadores_dados
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_indDados_numIndicador = 2
			GROUP BY pc_indDados_dataRef, pc_indDados_mcuOrgaoResp,pc_indDados_mcuOrgaoSubordinador
		</cfquery>
					
		<!-- consulta união dos resultados  -->
		<cfquery name="resultadoIndicadoresSecundariosPorOrgao" dbtype="query">
			SELECT	* FROM resultadoTIDPporOrgaoResp
			UNION
			SELECT	* FROM resultadoTGIporOrgaoResp
			UNION
			SELECT	* FROM resultadoQTSLporOrgaoResp
			UNION
			SELECT	* FROM resultadoQTNCporOrgaoResp
		</cfquery>

		<!--insere os dados dos indicadores secundários na tabela pc_indicadores_porOrgao-->
		<cfloop query="resultadoIndicadoresSecundariosPorOrgao">
			<cfquery  datasource="#application.dsn_processos#" timeout="120"  >
				INSERT INTO pc_indicadores_porOrgao
				(pc_indOrgao_ano, pc_indOrgao_mes, pc_indOrgao_numIndicador, pc_indOrgao_mcuOrgao, pc_indOrgao_resultadoMes, pc_indOrgao_resultadoAcumulado, pc_indOrgao_paraOrgaoSubordinador, pc_indOrgao_mcuOrgaoSubordinador)
				VALUES
				(	<cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#numIndicador#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#pc_indDados_mcuOrgaoResp#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#resultadoIndicador#" cfsqltype="cf_sql_float">
					,<cfqueryparam value="0" cfsqltype="cf_sql_float">
					,<cfqueryparam value="#paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#pc_indDados_mcuOrgaoSubordinador#" cfsqltype="cf_sql_varchar">
				)
			</cfquery>
			
		</cfloop>

		<!--órgãos da tabela pc_indicadores_porOrgao-->
		<cfquery name="orgaos" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT DISTINCT pc_indOrgao_mcuOrgao as mcuOrgao ,pc_indOrgao_paraOrgaoSubordinador , pc_indOrgao_mcuOrgaoSubordinador
			FROM pc_indicadores_porOrgao
			WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
			AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE pc_indPeso_numIndicador = 1 
				and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>

		<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE pc_indPeso_numIndicador = 2 
				and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>
	

		<!--LOOP em cada órgao para inserir na tabela pc_indicadores_porOrgao o indicador 3 (DGCI) através da fórmula DGCI = PRCI*pesoPRCI + SLNC*pesoSLNC-->
		<cfloop query="orgaos">
			<cfquery name="rsPRCIporOrgao" datasource="#application.dsn_processos#" timeout="120" >
				SELECT	pc_indOrgao_resultadoMes FROM pc_indicadores_porOrgao
				WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
					AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
					AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
					AND pc_indOrgao_numIndicador = 1
					AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
			</cfquery>

			<cfquery name="rsSLNCporOrgao" datasource="#application.dsn_processos#" timeout="120" >
				SELECT	pc_indOrgao_resultadoMes FROM pc_indicadores_porOrgao
				WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
					AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
					AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
					AND pc_indOrgao_numIndicador = 2
					AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
			</cfquery>


			<cfif rsPRCIporOrgao.recordCount eq 0 or rsPRCIporOrgao.pc_indOrgao_resultadoMes eq ''>
				<cfset prciResultado = ''>
			<cfelse>
				<cfset prciResultado = rsPRCIporOrgao.pc_indOrgao_resultadoMes>
			</cfif>

			<cfif rsSLNCporOrgao.recordCount eq 0 or rsSLNCporOrgao.pc_indOrgao_resultadoMes eq ''>
				<cfset slncResultado = ''>
			<cfelse>
				<cfset slncResultado = rsSLNCporOrgao.pc_indOrgao_resultadoMes>
			</cfif>
			
			<cfif slncResultado neq '' and prciResultado neq ''>
				<cfset resultadoDGCI = (prciResultado*rsPRCIpeso.pc_indPeso_peso) + (slncResultado*rsSLNCpeso.pc_indPeso_peso)>
			<cfelseif slncResultado eq '' and prciResultado neq ''>
				<cfset resultadoDGCI = prciResultado>
			<cfelseif slncResultado neq '' and prciResultado eq ''>
				<cfset resultadoDGCI = slncResultado>
			<cfelse>
				<cfset resultadoDGCI = ''>
			</cfif>
			

			<!-- cfquery que retorna pc_indOrgao_resultadoAcumulado do mês anterior da tabela pc_indicadores_porOrgaos -->
			<cfquery name="resultadoIndicadorAcumuladoMesAnterior" datasource="#application.dsn_processos#" timeout="120"  >
				SELECT TOP 1 pc_indOrgao_resultadoAcumulado
				FROM pc_indicadores_porOrgao
				WHERE 	pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_mes < <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_numIndicador = 3
						AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
						AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
			</cfquery>

			<cfquery name="rsContarMeses" datasource="#application.dsn_processos#" timeout="120"  >
				SELECT COUNT(DISTINCT pc_indOrgao_mes) as quantMeses
				FROM pc_indicadores_porOrgao
				WHERE 	pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_mes < <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
						AND pc_indOrgao_numIndicador = 3
						AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
						AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
			</cfquery>


			<cfif resultadoIndicadorAcumuladoMesAnterior.recordCount eq 0>
				<cfset resultadoIndicadorAcumulado = resultadoDGCI>
			<cfelse>
				<cfset resultadoIndicadorAcumulado = (resultadoIndicadorAcumuladoMesAnterior.pc_indOrgao_resultadoAcumulado + resultadoDGCI)/(rsContarMeses.quantMeses+1)>
			</cfif>
			
			<cfquery name="insereDadosIndicadoresporOrgao" datasource="#application.dsn_processos#" timeout="120"  >
				INSERT INTO pc_indicadores_porOrgao
				(pc_indOrgao_ano, pc_indOrgao_mes, pc_indOrgao_numIndicador, pc_indOrgao_mcuOrgao, pc_indOrgao_resultadoMes, pc_indOrgao_resultadoAcumulado, pc_indOrgao_paraOrgaoSubordinador, pc_indOrgao_mcuOrgaoSubordinador)
				VALUES
				(	<cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="3" cfsqltype="cf_sql_integer">
					,<cfqueryparam value="#orgaos.mcuOrgao#" cfsqltype="cf_sql_varchar">
					<cfif resultadoDGCI neq ''>
						,<cfqueryparam value="#resultadoDGCI#" cfsqltype="cf_sql_float">
					<cfelse>
						,NULL
					</cfif>

					,<cfqueryparam value="#resultadoIndicadorAcumulado#" cfsqltype="cf_sql_float">
					,<cfqueryparam value="#orgaos.pc_indOrgao_paraOrgaoSubordinador#" cfsqltype="cf_sql_bit">
					,<cfqueryparam value="#orgaos.pc_indOrgao_mcuOrgaoSubordinador#" cfsqltype="cf_sql_varchar">
				)
			</cfquery>
		</cfloop>


	</cffunction>
	
	<cffunction name="gerarDadosParaIndicadores"   access="remote" hint="gera os dados para os indicadores - acompanhamento mensal">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfargument name="tipoRotina" type="string" required="false" default="A" />

		<cfset ano = arguments.ano>
		<cfset mes = arguments.mes>
		<cfset tipoRotina = arguments.tipoRotina>
        <cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>


		<cftransaction>
			<cfquery name="deleta_PC_INDICADORES_DADOS" datasource="#application.dsn_processos#">
				DELETE FROM pc_indicadores_dados WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
			</cfquery>

			<cfquery name="deleta_PC_INDICADORES_PORORGAO" datasource="#application.dsn_processos#">
				DELETE FROM pc_indicadores_porOrgao 
				WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer"> 
				AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset quantDados = gerarDadosParaIndicadoresMensal(ano,mes,tipoRotina)>
			<cfset quantDadosPorOrgao = gerarDadosParaIndicadoresMensalPorOrgao(ano,mes)>
		</cftransaction>	

		<cfquery name="PC_INDICADORES_DADOS" datasource="#application.dsn_processos#">
			SELECT pc_indDados_id FROM pc_indicadores_dados WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
		</cfquery>
		<cfquery name="PC_INDICADORES_PORORGAO" datasource="#application.dsn_processos#">
			SELECT pc_indOrgao_ano FROM pc_indicadores_porOrgao WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer"> AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfset quantDados = PC_INDICADORES_DADOS.recordCount + PC_INDICADORES_PORORGAO.recordCount>

		<cfreturn quantDados>
	</cffunction>

	<cffunction name="deletaDadosParaIndicadores"   access="remote" hint="deleta os dados para os indicadores - acompanhamento mensal">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

		<cfset ano = arguments.ano>
		<cfset mes = arguments.mes>
        <cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>


		<cftransaction>
			<cfquery name="deleta_PC_INDICADORES_DADOS" datasource="#application.dsn_processos#">
				DELETE FROM pc_indicadores_dados WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
			</cfquery>

			<cfquery name="deleta_PC_INDICADORES_PORORGAO" datasource="#application.dsn_processos#">
				DELETE FROM pc_indicadores_porOrgao 
				WHERE pc_indOrgao_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer"> 
				AND pc_indOrgao_mes = <cfqueryparam value="#mes#" cfsqltype="cf_sql_integer">
			</cfquery>

		</cftransaction>	

	</cffunction>





</cfcomponent>