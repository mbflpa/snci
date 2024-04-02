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
									url: "cfc/pc_cfcIndicadores.cfc",
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
			<cfquery name="mcuOrgaoIndicador" datasource="#application.dsn_processos#" timeout="120">
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
					,<cfqueryparam value="#mcuOrgaoIndicador.pc_org_mcu#" cfsqltype="cf_sql_varchar">
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
		</cfloop>

		<cfloop query="rs_dados_slnc">
			<cfquery name="mcuOrgaoIndicador" datasource="#application.dsn_processos#" timeout="120">
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
					,<cfqueryparam value="#mcuOrgaoIndicador.pc_org_mcu#" cfsqltype="cf_sql_varchar">
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
		</cfloop>


	</cffunction>

	<cffunction name="gerarDadosParaIndicadoresPorOrgao"   access="remote" hint="gera os dados para os indicadores e insere na tabela pc_indicador_porOrgao - acompanhamento mensal"> 
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfargument name="tipoRotina" type="string" required="false" default="A" />

		<cfset ano = arguments.ano>
		<cfset mes = arguments.mes>
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


		<!--insere os dados na tabela pc_indicadores_porOrgao-->
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

		<!--orgãso da tabela pc_indicadores_porOrgao-->
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

	

		<!--LOOP em cada órgao para inserir na tabela pc_indicadores_porOrgao o indicador 3 (DGCI) através da fórmula DGCI = PRCI*0.55 + SLNC*0.45-->
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
			<cfset quantDadosPorOrgao = gerarDadosParaIndicadoresPorOrgao(ano,mes)>
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


	<cffunction name="consultaIndicadorPRCI_diario"   access="remote" hint="gera a consulta para página de indicadores - acompanhamento diário">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_Orientacao_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
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
			WHERE
				ranked_posicionamentos.row_num = 1
				AND pc_aval_posic_status IN (4, 5)
				AND pc_aval_posic_enviado = 1
				AND (
					pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>

		<cfquery name="rs_Orientacao_Respondida" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
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
				AND (pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
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

		<cfreturn #rs_Orientacao#>

	</cffunction>



	<cffunction name="tabPRCIDetalhe_diario" access="remote" hint="acompanhamento diário">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorPRCI_diario(ano=arguments.ano, mes=arguments.mes)>

      
		<cfset totalDP = 0 /> 
		<cfset totalFP = 0 /> 
		<cfset orgaos = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset dps = {}> <!-- Define a variável dps como um objeto vazio -->
		<cfset fps = {}> <!-- Define a variável fps como um objeto vazio -->
		<cfset orgaoRespMCUs = {}><!-- Define a variável orgaoRespMCUs como um objeto vazio -->

		<cfloop query="resultado"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset totalDP++> <!-- Se a condição for verdadeira, incrementa a variável totalDP em 1 -->
			<cfelseif Prazo eq 'FP'> <!-- Verifica se o valor da coluna Prazo é igual a 'FP' -->
				<cfset totalFP++> <!-- Se a condição for verdadeira, incrementa a variável totalFP em 1 -->
			</cfif>
			<cfif not StructKeyExists(orgaos, orgaoResp)> <!-- Verifica se a chave orgaoResp não existe no objeto orgaos -->
				<cfset orgaos[orgaoResp] = 1> <!-- Se a condição for verdadeira, define a chave orgaoResp no objeto orgaos como 1 -->
				<cfset dps[orgaoResp] = 0> <!-- Define a chave orgaoResp no objeto dps como 0 -->
				<cfset fps[orgaoResp] = 0> <!-- Define a chave orgaoResp no objeto fps como 0 -->
			<cfelse>
				<cfset orgaos[orgaoResp]++> <!-- Incrementa a chave orgaoResp no objeto orgaos em 1 -->
			</cfif>
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset dps[orgaoResp]++> <!-- Se a condição for verdadeira, incrementa a chave orgaoResp no objeto dps em 1 -->
			<cfelseif Prazo eq 'FP'> <!-- Verifica se o valor da coluna Prazo é igual a 'FP' -->
				<cfset fps[orgaoResp]++> <!-- Se a condição for verdadeira, incrementa a chave orgaoResp no objeto fps em 1 -->
			</cfif>
			<cfset orgaoRespMCUs[orgaoResp] = orgaoRespMCU>
		</cfloop>

		<!-- tabela resumo -->
		<cfset totalOrgaosResp = StructCount(orgaos)> <!-- Conta a quantidade de orgaoResp -->						
		<cfif totalOrgaosResp gt 1>
			<div id="divTabResumoPRCI" class="table-responsive">
				<div style="width: 350px; margin: 0 auto;">
					<table id="tabResumoPRCI" class="table table-bordered table-striped text-nowrap " style="width:100%; cursor:pointer">
						<cfoutput>
							
							<thead class="bg-gradient-warning" style="text-align: center;">
								<tr style="font-size:14px">
									<th colspan="6" style="padding:5px">PRCI - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
								</tr>
								<tr style="font-size:14px">
									<th style="font-weight: normal!important">Órgão</th>
									<th style="font-weight: normal!important">DP</th>
									<th style="font-weight: normal!important">FP</th>
									<th >PRCI</th>
									<th >Meta</th>
									<th >Resultado</th>
								</tr>
							</thead>
							<tbody>
								<cfset prcisOrdenado = StructSort(orgaos, "text", "asc")>
								<cfset totalMetaSubord = 0> <!-- Variável para armazenar a soma total das pc_indMeta_meta -->
								<cfset countMetaSubord = 0> <!-- Contador para o número de pc_indMeta_meta -->
								<cfloop array="#prcisOrdenado#" index="orgao">

									<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
										SELECT pc_indMeta_meta FROM pc_indicadores_meta 
										WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
												AND pc_indMeta_numIndicador = 1
												AND pc_indMeta_mcuOrgao = '#orgaoRespMCUs[orgao]#'
									</cfquery>
									


									<cfif orgaos[orgao] eq 0>
										<cfset metaPRCIorgao = 0>
									<cfelse>
										<cfset metaPRCIorgao = ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10>
									</cfif>
									<cfset metaPRCIorgaoFormatado = Replace(NumberFormat(metaPRCIorgao,0.0),".",",") >

									<cfif orgaos[orgao] eq 0>
										<cfset percentualDP = 0>
									<cfelse>
										<cfset percentualDP = (dps[orgao] / orgaos[orgao]) * 100>
									</cfif>

									<cfif metaPRCIorgao neq ''>
										<cfset totalMetaSubord += metaPRCIorgao>
										<cfset countMetaSubord++>
										<cfset resultMesEmRelacaoMeta = ROUND((ROUND(percentualDP*10)/10 / metaPRCIorgao)*100*10)/10>
									<cfelse>
										<cfset resultMesEmRelacaoMeta = ROUND(0*10)/10>	
									</cfif>

									<cfset percentualDPFormatado = Replace(ROUND(percentualDP*10)/10,".",",") >


									<!--- Adiciona cada linha à tabela --->
									<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
										<td>#orgao# (#orgaoRespMCUs[orgao]#)</td>
										<td>#dps[orgao]#</td>
										<td>#fps[orgao]#</td>
										<td><strong>#percentualDPFormatado#%</strong></td>
										<cfif rsMetaPRCI.pc_indMeta_meta eq ''>
											<td>sem meta</td>
										<cfelse>	
											<td><strong>#metaPRCIorgaoFormatado#%</strong></td>
										</cfif>
										<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>

									</tr>
								</cfloop>
								<!-- Calcula a média do órgao subordinador-->
								<cfset avgMetaPRCIsubordinador = Round((totalMetaSubord/countMetaSubord)*10)/10>
							</tbody>
						</cfoutput>
					</table>
				</div>
			</div>
									


		</cfif>

		<style>
			.dataTables_wrapper {
				width: 100%; /* ou a largura desejada */
				margin: 0 auto;
			}
		</style>
	
		<cfif #resultado.recordcount# neq 0 >	
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
														
								<cfoutput><h5 style="color:##000;text-align: center;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>PRCI</strong> (Atendimento ao Prazo de Resposta): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
								<div class="table-responsive">
									<table id="tabPRCIdetalhe" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
										
										<thead class="bg-gradient-warning">
											<tr style="font-size:14px">
												<th style="width: 10px">Posic ID</th>
												<th style="width: 10px">Órgão Avaliado</th>
												<th style="width: 10px">Órgão Responsável</th>
												<th style="width: 10px">Processo SNCI</th>
												<th style="width: 10px">Item</th>
												<th style="width: 10px">Orientação</th>
												<th style="width: 10px">Data Prevista</th>
												<th style="width: 10px">Data Status</th>
												<th style="width: 10px">Status</th>
												<th style="width: 10px">Data Ref.</th>
												<th style="width: 10px">Prazo</th>

											</tr>
										</thead>
										
										<tbody>
											<cfloop query="resultado" >
											    											
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultado.pc_aval_posic_id#</td>
														<td>#resultado.orgaoAvaliado#</td>
														<td>#resultado.orgaoResp#</td>
														<td>#resultado.numProcessoSNCI#</td>
														<td >#resultado.item#</td>
														<td>#resultado.orientacao#</td>
														<cfif resultado.dataPrevista eq '1900-01-01' or resultado.dataPrevista eq ''>
															<td>NÃO INF.</td>
														<cfelse>
															<td>#dateFormat(resultado.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>
															
															<cfif orgaoDaAcaoEdoControleInterno eq 'N' AND (resultado.pc_aval_posic_status eq 4 OR resultado.pc_aval_posic_status eq 5)>
																#dateFormat(resultado.dataPosicao, 'dd/mm/yyyy')#<br><span style="color:red">(dt. distrib.)</span>
															<cfelse>
																#dateFormat(resultado.dataPosicao, 'dd/mm/yyyy')#
															</cfif>
														</td>


														<td>#resultado.OrientacaoStatus#</td>
														<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
														<td>#dateFormat(dataFinal, 'dd/mm/yyyy')#</td>
														<td>#resultado.Prazo#</td>
															
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>

										
										
										<!--- Imprime os resultados ou faça o que desejar com eles --->
										<cfoutput>
											<cfset totalGeral = resultado.recordcount />
											<!--- Calcula a porcentagem --->
											<cfset percentualDP = ROUND((totalDP / totalGeral) * 100*10)/10 />
											<!--- Formata o percentualDP com duas casas decimais --->
											<cfset percentualDPFormatado = Replace(NumberFormat(percentualDP,0.0),".",",") />
											
											
											
											<cfset metaPRCIorgaoFormatado = Replace(NumberFormat(avgMetaPRCIsubordinador,0.0),".",",") />

											<cfif avgMetaPRCIsubordinador eq 0>
												<cfset PRCIresultadoMeta = ROUND(0*10)/10 />
											<cfelse>
												<cfset PRCIresultadoMeta = ROUND((percentualDP/avgMetaPRCIsubordinador)*100*10)/10 />
											</cfif>

											<cfset PRCIresultadoMetaFormatado = Replace(NumberFormat(PRCIresultadoMeta,0.0),".",",") />
											

											<div id="divResultPRCI" class="col-md-4 col-sm-4 col-4">
												
												<cfset 	infoRodape = '<span style="font-size:14px">PRCI = TIDP/TGI</span><br>
															<span style="font-size:14px">TIDP (Posic. dentro do prazo (DP))= #totalDP#</span><br>
															<span style="font-size:14px">TGI (Total de Posicionamentos)= #totalGeral# </span><br>
															<span style="font-size:14px">Meta = #metaPRCIorgaoFormatado#%</span><br>'>			
												<cfset var criarCardIndicador = criarCardIndicador(
													tipoDeCard = 'bg-gradient-warning',
													siglaIndicador ='PRCI',
													percentualIndicadorFormatado = percentualDPFormatado,
													resultadoEmRelacaoMeta = PRCIresultadoMeta,
													resultadoEmRelacaoMetaFormatado = PRCIresultadoMetaFormatado,
													infoRodape = infoRodape

												)>

												<cfoutput>#criarCardIndicador#</cfoutput>


											</div>
											
										</cfoutput>

									</table>
								</div>

								





								
							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
        </cfif>

		<script language="JavaScript">
		   // Define a função para aplicar o estilo apenas nas células com a classe 'tdResult'
			function aplicarEstiloNasTDsComClasseTdResult() {
				// Para cada célula com a classe 'tdResult' na tabela
				$('.tdResult').each(function() {
					updateTDresultIndicadores($(this));
				});
			}
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_PRCI_detalhamento_";
				var colunasMostrar = [1,2,8,10];


				const tabPRCIdetalhamento = $('#tabPRCIdetalhe').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					dom:   "<'row'<'col-sm-4'B><'col-sm-4'p><'col-sm-4 text-right'i>>" ,

							
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]
					

				})
 
				


			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				$('#tabResumoPRCI').DataTable({
					order: [[3, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false, // Remove o campo de busca
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}
				});


				
				
				
			});
		</script>

	</cffunction>


	<cffunction name="consultaIndicadorSLNC_diario"   access="remote" hint="gera a consulta para página de indicadores - acompanhamento diário">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_solucionados_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status as status,
				pc_orientacao_status.pc_orientacao_status_descricao AS OrientacaoStatus

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
			LEFT JOIN pc_orgaos as orgaoResp ON ranked_posicionamentos.pc_aval_posic_num_orgaoResp = orgaoResp.pc_org_mcu
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
				AND (pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora
				BETWEEN <cfqueryparam value="#dataInicial#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>


		<cfquery name="rs_tratamento_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoAvaliado.pc_org_mcu as orgaoAvaliadoMCU,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoResp.pc_org_mcu as orgaoRespMCU,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status as status,
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
				AND (
					pc_aval_posic_num_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
					OR pc_aval_posic_num_orgaoResp IN (
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
					<cfif mcusHeranca neq ''>OR pc_aval_posic_num_orgaoResp IN (#mcusHeranca#)</cfif>
				) 
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
		</cfquery>

		<cfquery name="rs_solucionados_tratamento_agora" dbtype="query">
			SELECT * FROM rs_solucionados_agora
			UNION
			SELECT * FROM rs_tratamento_agora
		</cfquery>
		
		<cfreturn #rs_solucionados_tratamento_agora#>

	</cffunction>


	<cffunction name="tabSLNCDetalhe_diario" access="remote" hint="acompanhamento diário">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultadoSLNC = consultaIndicadorSLNC_diario(ano=arguments.ano, mes=arguments.mes)>

		<cfset totalSolucionado = 0 /> 
		<cfset orgaos = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset solucionados = {}> <!-- Define a variável solucionados como um objeto vazio -->
		<cfset metaSLNC = {}>
		<cfset orgaoRespMCUs = {}>
		
		<cfloop query="resultadoSLNC"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			
			<cfif status eq 6> 
				<cfset totalSolucionado++> 
			</cfif>
			
			<cfif not StructKeyExists(orgaos, orgaoResp)>
				<cfset orgaos[orgaoResp] = 1> 
				<cfset solucionados[orgaoResp] = 0> 
			<cfelse>
				<cfset orgaos[orgaoResp]++> 
			</cfif>
			<cfif status eq 6> 
				<cfset solucionados[orgaoResp]++> 
			</cfif>
			<cfset orgaoRespMCUs[orgaoResp] = orgaoRespMCU>
		
		</cfloop>

		<!-- tabela resumo -->
		<cfset totalOrgaosResp = StructCount(orgaos)> 		
		<cfif totalOrgaosResp gt 1>
			<div id="divTabResumoSLNC" class="table-responsive">
				<table id="tabResumoSLNC" class="table table-bordered table-striped text-nowrap" style="width:350px; cursor:pointer">
					<cfoutput>
						<thead class="bg-gradient-warning" style="text-align: center;">
							<tr style="font-size:14px">
								<th colspan="6" style="padding:5px">SLNC - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
							</tr>
							<tr style="font-size:14px">
								<th style="font-weight: normal!important">Órgão</th>
								<th style="font-weight: normal!important">Soluc.</th>
								<th style="font-weight: normal!important">Orient.</th>
								<th >SLNC</th>
								<th >Meta</th>
								<th >Resultado</th>
							</tr>
						</thead>
						<tbody>
							
							<cfset slncOrdenado = StructSort(orgaos, "text", "asc")>
							<cfset totalMetaSubord = 0> <!-- Variável para armazenar a soma total das pc_indMeta_meta -->
							<cfset countMetaSubord = 0> <!-- Contador para o número de pc_indMeta_meta -->
							
							<cfloop array="#slncOrdenado#" index="orgao">
								<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
									SELECT pc_indMeta_meta FROM pc_indicadores_meta 
									WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
											AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
											AND pc_indMeta_numIndicador = 2
											AND pc_indMeta_mcuOrgao = '#orgaoRespMCUs[orgao]#'
								</cfquery>
								


								<cfif orgaos[orgao] eq 0>
									<cfset metaSLNCorgao = 0>
								<cfelse>
									<cfset metaSLNCorgao = ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10>
								</cfif>
								<cfset metaSLNCorgaoFormatado = Replace(NumberFormat(metaSLNCorgao,0.0),".",",") >

								
								
								<cfset percentualSolucionado = (solucionados[orgao] / orgaos[orgao]) * 100>
								<cfset percentualSolucionadoFormatado = Replace(ROUND(percentualSolucionado*10)/10,".",",")  />

								<cfif metaSLNCorgao neq ''>
									<cfset totalMetaSubord += metaSLNCorgao>
									<cfset countMetaSubord++>
									<cfset resultMesEmRelacaoMeta = ROUND((ROUND(percentualSolucionado*10)/10 / metaSLNCorgao)*100*10)/10>
								<cfelse>
									<cfset resultMesEmRelacaoMeta = ROUND(0*10)/10>	
								</cfif>

								<!--- Adiciona cada linha à tabela --->
								<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
									<td>#orgao# (#orgaoRespMCUs[orgao]#)</td>
									<td>#solucionados[orgao]#</td>
									<td>#orgaos[orgao]#</td>
									<td><strong>#percentualSolucionadoFormatado#%</strong></td>
									<cfif rsMetaSLNC.pc_indMeta_meta eq ''>
										<td>sem meta</td>
									<cfelse>	
										<td><strong>#metaSLNCorgaoFormatado#%</strong></td>
									</cfif>
									<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
								</tr>
								<!-- calcular a média da coluna meta -->
								<cfset avgMetaSLNCsubordinador = Round((totalMetaSubord/countMetaSubord)*10)/10>

							</cfloop>
						
							</tbody>
						</tbody>
					</cfoutput>
				</table>
			</div>


		</cfif>


	
		<cfif #resultadoSLNC.recordcount# neq 0 >
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							
								<cfoutput><h5 style="color:##000;text-align: center; margin-bottom: 20px;margin-bottom: 20px;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>SLNC</strong> (Solução de Não Conformidades): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
								<div class="table-responsive">
									<table id="tabSLNCdetalhe" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
										
										<thead class="bg-gradient-warning">
											<tr style="font-size:14px">
												<th style="width: 10px">Posic ID</th>
												<th style="width: 10px">Órgão Avaliado</th>
												<th style="width: 10px">Órgão Responsável</th>
												<th style="width: 10px">Processo SNCI</th>
												<th style="width: 10px">Item</th>
												<th style="width: 10px">Orientação</th>
												<th style="width: 10px">Data Prevista</th>
												<th style="width: 10px">Data Status</th>
												<th style="width: 10px">Status</th>
												<th style="width: 10px">Data Ref.</th>
											</tr>
										</thead>
										
										<tbody>
											<cfloop query="resultadoSLNC" >
												<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
													SELECT pc_indMeta_meta FROM pc_indicadores_meta 
													WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_numIndicador = 2
															AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
												</cfquery>
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultadoSLNC.pc_aval_posic_id#</td>
														<td>#resultadoSLNC.orgaoAvaliado#</td>
														<td>#resultadoSLNC.orgaoResp#</td>
														<td>#resultadoSLNC.numProcessoSNCI#</td>
														<td >#resultadoSLNC.item#</td>
														<td>#resultadoSLNC.orientacao#</td>
														<cfif resultadoSLNC.dataPrevista eq '1900-01-01' or resultadoSLNC.dataPrevista eq ''>
															<td>---</td>
														<cfelse>
															<td>#dateFormat(resultadoSLNC.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>#dateFormat(resultadoSLNC.dataPosicao, 'dd/mm/yyyy')#</td>
														<td>#resultadoSLNC.OrientacaoStatus#</td>
														<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
														<td>#dateFormat(dataFinal, 'dd/mm/yyyy')#</td>
														
															
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
									
										<cfoutput>
											<cfset totalGeral = resultadoSLNC.recordcount />
											<cfif totalGeral eq 0>
												<cfset percentualSolucionado = ROUND(0*10)/10 />
											<cfelse>
												<cfset percentualSolucionado = ROUND((totalSolucionado / totalGeral *100)*10)/10 />
											</cfif>
											

											<cfset percentualSolucionadoFormatado = Replace(NumberFormat(percentualSolucionado,0.0),".",",")  />
											
											<cfset metaSLNCorgaoFormatado = Replace(NumberFormat(avgMetaSLNCsubordinador,0.0),".",",") />

											<cfif avgMetaSLNCsubordinador eq 0>
												<cfset SLNCresultadoMeta = ROUND(0*10)/10 />
											<cfelse>
												<cfset SLNCresultadoMeta = ROUND(NumberFormat((percentualSolucionado/avgMetaSLNCsubordinador),0.0)*100*10)/10 />
											</cfif>
											<cfset SLNCresultadoMetaFormatado = Replace(NumberFormat(SLNCresultadoMeta,0.0),".",",") />
											
											
											
											<div id="divResultSLNC" class="col-md-6 col-sm-6 col-12">
												
												<cfset 	infoRodape = '<span style="font-size:14px">SLNC = QTSL/QTNC x 100</span><br>
															<span style="font-size:14px">QTSL (Quant. Orientações Solucionadas)= #totalSolucionado#</span><br>
															<span style="font-size:14px">QTNC (Quant. Orientações Registradas )= #totalGeral#</span><br>
															<span style="font-size:14px">Meta = #metaSLNCorgaoFormatado#%</span><br>'>			
												<cfset var criarCardIndicador = criarCardIndicador(
													tipoDeCard = 'bg-gradient-warning',
													siglaIndicador ='SLNC',
													percentualIndicadorFormatado = percentualSolucionadoFormatado,
													resultadoEmRelacaoMeta = SLNCresultadoMeta,
													resultadoEmRelacaoMetaFormatado = SLNCresultadoMetaFormatado,
													infoRodape = infoRodape

												)>

												<cfoutput>#criarCardIndicador#</cfoutput>
												




											</div>
											
										</cfoutput>

									</table>
								</div>

							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
		</cfif>
		<script language="JavaScript">
		   
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_SLNC_detalhamento_";
				var colunasMostrar = [1,2,8,10];


				const tabSLNCdetalhamento = $('#tabSLNCdetalhe').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					lengthMenu: [
						[5, 10, 25, 50, -1],
						[5, 10, 25, 50, 'Todos']
					],
					dom:   "<'row'<'col-sm-4'B><'col-sm-4'p><'col-sm-4 text-right'i>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]

				})
 
			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				$('#tabResumoSLNC').DataTable({
					order: [[3, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false, // Remove o campo de busca
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}
				});

			});
		</script>

	</cffunction>





	<cffunction name="tabPRCIDetalhe_mensal" access="remote" hint="acompanhamento mensal">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>


		<cfquery name="resultadoPRCI" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indDados_numPosic
				,pc_indDados_mcuOrgaoResp as mcuOrgaoResp
				,pc_orgaos.pc_org_sigla as siglaOrgaoResp
				,pc_indDados_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,pc_indDados_mcuOrgaoAvaliado as mcuOrgaoAvaliado
				,pc_orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
				,pc_indDados_numProcesso as numProcessoSNCI
				,pc_indDados_numItem as item
				,pc_indDados_numOrientacao as orientacao
				,pc_indDados_dataPrevista as dataPrevista
				,pc_indDados_status as numStatus
				,pc_indDados_descricaoStatus as descricaoOrientacaoStatus
				,pc_indDados_dataRef as dataRef
				,pc_indDados_numIndicador as numIndicador
				,pc_indDados_mcuOrgaoPosicEcontInterno
				,CASE 
					WHEN pc_indDados_descricaoStatus = 'PENDENTE' THEN DATEADD(day, 1, pc_indDados_dataPrevista)
					ELSE pc_indDados_dataStatus
				END as dataPosicao
				,pc_indDados_prazo as prazo

			FROM pc_indicadores_dados
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			INNER JOIN pc_orgaos as pc_orgaoAvaliado on pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_indDados_numIndicador = 1
				AND pc_indDados_mcuOrgaoSubordinador = '#application.rsUsuarioParametros.pc_usu_lotacao#'
      	</cfquery>
      
		<cfset totalDP = 0 /> 
		<cfset totalFP = 0 /> 
		<cfset orgaos = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset dps = {}> <!-- Define a variável dps como um objeto vazio -->
		<cfset fps = {}> <!-- Define a variável fps como um objeto vazio -->

		<cfloop query="resultadoPRCI"> <!-- Inicia um loop que itera sobre o conjunto de dados resultadoPRCI -->
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset totalDP++> <!-- Se a condição for verdadeira, incrementa a variável totalDP em 1 -->
			<cfelseif Prazo eq 'FP'> <!-- Verifica se o valor da coluna Prazo é igual a 'FP' -->
				<cfset totalFP++> <!-- Se a condição for verdadeira, incrementa a variável totalFP em 1 -->
			</cfif>
			<cfif not StructKeyExists(orgaos, siglaOrgaoResp)> <!-- Verifica se a chave siglaOrgaoResp não existe no objeto orgaos -->
				<cfset orgaos[siglaOrgaoResp] = 1> <!-- Se a condição for verdadeira, define a chave siglaOrgaoResp no objeto orgaos como 1 -->
				<cfset dps[siglaOrgaoResp] = 0> <!-- Define a chave siglaOrgaoResp no objeto dps como 0 -->
				<cfset fps[siglaOrgaoResp] = 0> <!-- Define a chave siglaOrgaoResp no objeto fps como 0 -->
			<cfelse>
				<cfset orgaos[siglaOrgaoResp]++> <!-- Incrementa a chave siglaOrgaoResp no objeto orgaos em 1 -->
			</cfif>
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset dps[siglaOrgaoResp]++> <!-- Se a condição for verdadeira, incrementa a chave siglaOrgaoResp no objeto dps em 1 -->
			<cfelseif Prazo eq 'FP'> <!-- Verifica se o valor da coluna Prazo é igual a 'FP' -->
				<cfset fps[siglaOrgaoResp]++> <!-- Se a condição for verdadeira, incrementa a chave siglaOrgaoResp no objeto fps em 1 -->
			</cfif>
		</cfloop>

		<style>
			.dataTables_wrapper {
				width: 100%; /* ou a largura desejada */
				margin: 0 auto;
			}
		</style>
	
		<cfif #resultadoPRCI.recordcount# neq 0 >	
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
														
								<cfoutput><h5 style="color:##000;text-align: center;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>PRCI</strong> (Atendimento ao Prazo de Resposta): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
								<div class="table-responsive">
									<table id="tabPRCIdetalhe" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
										
										<thead class="bg-gradient-warning">
											<tr style="font-size:14px">
												<th style="width: 10px">Posic ID</th>
												<th style="width: 10px">Órgão Avaliado</th>
												<th style="width: 10px">Órgão Responsável</th>
												<th style="width: 10px">Processo SNCI</th>
												<th style="width: 10px">Item</th>
												<th style="width: 10px">Orientação</th>
												<th style="width: 10px">Data Prevista</th>
												<th style="width: 10px">Data Status</th>
												<th style="width: 10px">Status</th>
												<th style="width: 10px">Data Ref.</th>
												<th style="width: 10px">Prazo</th>

											</tr>
										</thead>
										
										<tbody>
											<cfloop query="resultadoPRCI" >
											    <cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
													SELECT pc_indMeta_meta FROM pc_indicadores_meta 
													WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_numIndicador = 1
															AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
												</cfquery>
											
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultadoPRCI.pc_indDados_numPosic#</td>
														<td>#resultadoPRCI.siglaOrgaoAvaliado#</td>
														<td>#resultadoPRCI.siglaOrgaoResp#</td>
														<td>#resultadoPRCI.numProcessoSNCI#</td>
														<td >#resultadoPRCI.item#</td>
														<td>#resultadoPRCI.orientacao#</td>
														<cfif resultadoPRCI.dataPrevista eq '1900-01-01' or resultadoPRCI.dataPrevista eq ''>
															<td>NÃO INF.</td>
														<cfelse>
															<td>#dateFormat(resultadoPRCI.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>
															<cfif resultadoPRCI.pc_indDados_mcuOrgaoPosicEcontInterno eq 0 AND (resultadoPRCI.numStatus eq 4 OR resultadoPRCI.numStatus eq 5)>
																#dateFormat(resultadoPRCI.dataPosicao, 'dd/mm/yyyy')#<br><span style="color:red">(dt. distrib.)</span>
															<cfelse>
																#dateFormat(resultadoPRCI.dataPosicao, 'dd/mm/yyyy')#
															</cfif>
														</td>
														<td>#resultadoPRCI.descricaoOrientacaoStatus#</td>
														<td>#dateFormat(dataFinal, 'dd/mm/yyyy')#</td>
														<td>#resultadoPRCI.Prazo#</td>
															
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
										<!--- Imprime os resultados ou faça o que desejar com eles --->
										<cfoutput>
											<cfset totalGeral = resultadoPRCI.recordcount />
											<!--- Calcula a porcentagem --->
											<cfset percentualDP = ROUND((totalDP / totalGeral) * 100*10)/10 />
											<!--- Formata o percentualDP com duas casas decimais --->
											<cfset percentualDPFormatado = Replace(percentualDP,".",",") />

											<cfif rsMetaPRCI.pc_indMeta_meta eq "">
												<cfset metaPRCIorgao = NumberFormat(0, 0.0)>
											<cfelse>
												<cfset metaPRCIorgao= ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10 />
											</cfif>

											<cfset metaPRCIorgaoFormatado = Replace(metaPRCIorgao,".",",") />

											<cfif metaPRCIorgao eq 0>
												<cfset PRCIresultadoMeta = ROUND(0*10)/10 />
											<cfelse>
												<cfset PRCIresultadoMeta = ROUND((percentualDP/metaPRCIorgao)*100*10)/10 />
											</cfif>

											<cfset PRCIresultadoMetaFormatado = Replace(PRCIresultadoMeta,".",",") />
											

											<div id="divResultPRCI" class="col-md-4 col-sm-4 col-4">
												<div class="info-box bg-gradient-warning">
													<div class="ribbon-wrapper ribbon-xl"  >
														<cfif metaPRCIorgao eq 0>
															<div class="ribbon" id="ribbon" data-value=""></div>
														<cfelse>
															<div class="ribbon" id="ribbon" data-value="#PRCIresultadoMeta#"></div>
														</cfif>
													</div>
													<span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

													<div class="info-box-content">
														<span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:22px">PRCI = #percentualDPFormatado#%</font></font></span><span style="font-size:12px;position:absolute; top:36px">Atendimento ao Prazo de Resposta</span>
														<span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong>#PRCIresultadoMetaFormatado#%</strong></font></font><span style="font-size:10px;"> em relação a meta = (PRCI / Meta) * 100</span></span>

														<div class="progress" style="width:90%">
															<div class="progress-bar" style="width: #PRCIresultadoMeta#%"></div>
														</div>
														<span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
															<span style="font-size:14px">PRCI = TIDP/TGI</span><br>
															<span style="font-size:14px">TIDP (Posic. dentro do prazo (DP))= #totalDP#</span><br>
															<span style="font-size:14px">TGI (Total de Posicionamentos)= #totalGeral# </span><br>
															<span style="font-size:14px">Meta = #metaPRCIorgaoFormatado#%</span><br>
														</font></font></span>
													</div>
													<!-- /.info-box-content -->
												</div>
												<!-- /.info-box -->
											</div>
											
										</cfoutput>

									</table>
								</div>

								<cfset totalOrgaosResp = StructCount(orgaos)> <!-- Conta a quantidade de orgaoResp -->
								
								<cfif totalOrgaosResp gt 1>
									<div id="divTabResumoPRCI" class="table-responsive">
										<div style="width: 350px; margin: 0 auto;">
											<table id="tabResumoPRCI" class="table table-bordered table-striped text-nowrap " style="width:100%; cursor:pointer">
												<cfoutput>
													<thead class="bg-gradient-warning" style="text-align: center;">
														<tr style="font-size:14px">
															<th colspan="4" style="padding:5px">PRCI - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
														</tr>
														<tr style="font-size:14px">
															<th style="font-weight: normal!important">Órgão</th>
															<th style="font-weight: normal!important">DP</th>
															<th style="font-weight: normal!important">FP</th>
															<th >PRCI</th>
														</tr>
													</thead>
													<tbody>
														<cfset prcisOrdenado = StructSort(orgaos, "text", "asc")>
														<cfloop array="#prcisOrdenado#" index="orgao">
															<cfif orgaos[orgao] eq 0>
																<cfset percentualDP = 0>
															<cfelse>
																<cfset percentualDP = (dps[orgao] / orgaos[orgao]) * 100>
															</cfif>
															<cfset percentualDPFormatado = Replace(ROUND(percentualDP*10)/10,".",",") >

															<!--- Adiciona cada linha à tabela --->
															<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
																<td>#orgao#</td>
																<td>#dps[orgao]#</td>
																<td>#fps[orgao]#</td>
																<td><strong>#percentualDPFormatado#%</strong></td>
															</tr>
														</cfloop>
													</tbody>
												</cfoutput>
											</table>
										</div>
									</div>
															
	
		
								</cfif>





								
							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
        </cfif>

		<script language="JavaScript">
		   
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_PRCI_detalhamento_";
				var colunasMostrar = [1,2,8,10];


				const tabPRCIdetalhamento = $('#tabPRCIdetalhe').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					dom:   "<'row'<'col-sm-4'B><'col-sm-4'p><'col-sm-4 text-right'i>>" ,

							
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]
					

				})
 
				


			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				$('#tabResumoPRCI').DataTable({
					order: [[3, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false // Remove o campo de busca
				});


				
				
				
			});
		</script>

	</cffunction>


	<cffunction name="tabSLNCDetalhe_mensal" access="remote" hint="acompanhamento mensal">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>


		<cfquery name="resultadoSLNC" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indDados_numPosic
				,pc_indDados_mcuOrgaoResp as mcuOrgaoResp
				,pc_orgaos.pc_org_sigla as siglaOrgaoResp
				,pc_indDados_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,pc_indDados_mcuOrgaoAvaliado as mcuOrgaoAvaliado
				,pc_orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
				,pc_indDados_numProcesso as numProcessoSNCI
				,pc_indDados_numItem as item
				,pc_indDados_numOrientacao as orientacao
				,pc_indDados_dataPrevista as dataPrevista
				,pc_indDados_status as numStatus
				,pc_indDados_descricaoStatus as descricaoOrientacaoStatus
				,pc_indDados_dataRef as dataRef
				,pc_indDados_numIndicador as numIndicador
				,CASE 
					WHEN pc_indDados_descricaoStatus = 'PENDENTE' THEN DATEADD(day, 1, pc_indDados_dataPrevista)
					ELSE pc_indDados_dataStatus
				END as dataPosicao
				,pc_indDados_prazo as prazo

			FROM pc_indicadores_dados
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			INNER JOIN pc_orgaos as pc_orgaoAvaliado on pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
				AND pc_indDados_numIndicador = 2
				AND pc_indDados_mcuOrgaoSubordinador = '#application.rsUsuarioParametros.pc_usu_lotacao#'
      	</cfquery>

		<cfset totalSolucionado = 0 /> 
		<cfset orgaos = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset solucionados = {}> <!-- Define a variável solucionados como um objeto vazio -->
		

		<cfloop query="resultadoSLNC"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			<cfif numStatus eq 6> 
				<cfset totalSolucionado++> 
			</cfif>
			<cfif not StructKeyExists(orgaos, siglaOrgaoResp)>
				<cfset orgaos[siglaOrgaoResp] = 1> 
				<cfset solucionados[siglaOrgaoResp] = 0> 
			<cfelse>
				<cfset orgaos[siglaOrgaoResp]++> 
			</cfif>
			<cfif numStatus eq 6> 
				<cfset solucionados[siglaOrgaoResp]++> 
			</cfif>
		</cfloop>

		
	
		<cfif #resultadoSLNC.recordcount# neq 0 >
			<div class="row" style="width: 100%;">
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							
								<cfoutput><h5 style="color:##000;text-align: center; margin-bottom: 20px;margin-bottom: 20px;margin-bottom: 20px;">Dados utilizados no cálculo do <strong>SLNC</strong> (Solução de Não Conformidades): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
							
								<div class="table-responsive">
									<table id="tabSLNCdetalheMensal" class="table table-bordered table-striped text-nowrap" style="width: 100%;">
										
										<thead class="bg-gradient-warning">
											<tr style="font-size:14px">
												<th style="width: 10px">Posic ID</th>
												<th style="width: 10px">Órgão Avaliado</th>
												<th style="width: 10px">Órgão Responsável</th>
												<th style="width: 10px">Processo SNCI</th>
												<th style="width: 10px">Item</th>
												<th style="width: 10px">Orientação</th>
												<th style="width: 10px">Data Prevista</th>
												<th style="width: 10px">Data Status</th>
												<th style="width: 10px">Status</th>
												<th style="width: 10px">Data Ref.</th>
											</tr>
										</thead>
										
										<tbody>
											<cfloop query="resultadoSLNC" >
												
												<cfoutput>					
													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td>#resultadoSLNC.pc_indDados_numPosic#</td>
														<td>#resultadoSLNC.siglaOrgaoAvaliado#</td>
														<td>#resultadoSLNC.siglaOrgaoResp#</td>
														<td>#resultadoSLNC.numProcessoSNCI#</td>
														<td >#resultadoSLNC.item#</td>
														<td>#resultadoSLNC.orientacao#</td>
														<cfif resultadoSLNC.dataPrevista eq '1900-01-01' or resultadoSLNC.dataPrevista eq ''>
															<td>---</td>
														<cfelse>
															<td>#dateFormat(resultadoSLNC.dataPrevista, 'dd/mm/yyyy')#</td>
														</cfif>
														<td>#dateFormat(resultadoSLNC.dataPosicao, 'dd/mm/yyyy')#</td>
														<td>#resultadoSLNC.descricaoOrientacaoStatus#</td>
														<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
														<td>#dateFormat(dataFinal, 'dd/mm/yyyy')#</td>
														
															
													</tr>
												</cfoutput>
											</cfloop>	
										</tbody>
									
										<cfoutput>
											<cfset totalGeral = resultadoSLNC.recordcount />
											<cfif totalGeral eq 0>
												<cfset percentualSolucionado = ROUND(0*10)/10 />
											<cfelse>
												<cfset percentualSolucionado = ROUND((totalSolucionado / totalGeral *100)*10)/10 />
											</cfif>
											<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
													SELECT pc_indMeta_meta FROM pc_indicadores_meta 
													WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
															AND pc_indMeta_numIndicador = 2
															AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
												</cfquery>
								
											<cfset percentualSolucionadoFormatado = Replace(percentualSolucionado,".",",")  />
											
											<cfif rsMetaSLNC.pc_indMeta_meta eq "">
												<cfset metaSLNCorgao = NumberFormat(0, 0.0)>
											<cfelse>
												<cfset metaSLNCorgao= ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10 />
											</cfif>

											<cfset metaSLNCorgaoFormatado = Replace(metaSLNCorgao,".",",") />
											<cfif metaSLNCorgao eq 0>
												<cfset SLNCresultadoMeta = ROUND(0*10)/10 />
											<cfelse>
												<cfset SLNCresultadoMeta = ROUND((percentualSolucionado/metaSLNCorgao)*100*10)/10 />
											</cfif>
											<cfset SLNCresultadoMetaFormatado = Replace(SLNCresultadoMeta,".",",") />
											
											
											
											<div id="divResultSLNC" class="col-md-6 col-sm-6 col-12">
												<div class="info-box bg-gradient-warning">
												    <div class="ribbon-wrapper ribbon-xl"  >
													    <cfif metaSLNCorgao eq 0>
															<div class="ribbon" id="ribbon" data-value=""></div>
														<cfelse>
															<div class="ribbon" id="ribbon" data-value="#SLNCresultadoMeta#"></div>
														</cfif>
													</div>
													<span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

													<div class="info-box-content">
														<span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:22px">SLNC = #percentualSolucionadoFormatado#%</font></font></span><span style="font-size:12px;position:absolute; top:36px">Solução de Não Conformidades</span>
														<span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong>#SLNCresultadoMetaFormatado#%</strong></font></font><span style="font-size:10px;"> em relação a meta = (SLNC / Meta) * 100</span></span>

														<div class="progress" style="width:90%">
														<div class="progress-bar" style="width: #percentualSolucionado#%"></div>
														</div>
														<span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
															<span style="font-size:14px">SLNC = QTSL/QTNC x 100</span><br>
															<span style="font-size:14px">QTSL (Quant. Orientações Solucionadas)= #totalSolucionado#</span><br>
															<span style="font-size:14px">QTNC (Quant. Orientações Registradas )= #totalGeral#</span><br>
															<span style="font-size:14px">Meta = #metaSLNCorgaoFormatado#%</span><br>
														</font></font></span>
													</div>
													<!-- /.info-box-content -->
												</div>
												<!-- /.info-box -->
											</div>
											
										</cfoutput>

									</table>
								</div>

								<cfset totalOrgaosResp = StructCount(orgaos)> 
								
								<cfif totalOrgaosResp gt 1>
									<div id="divTabResumoSLNC" class="table-responsive">
										<table id="tabResumoSLNCmensal" class="table table-bordered table-striped text-nowrap" style="width:350px; cursor:pointer">
											<cfoutput>
												<thead class="bg-gradient-warning" style="text-align: center;">
													<tr style="font-size:14px">
														<th colspan="4" style="padding:5px">SLNC - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
													</tr>
													<tr style="font-size:14px">
														<th style="font-weight: normal!important">Órgão</th>
														<th style="font-weight: normal!important">Solucionadas</th>
														<th style="font-weight: normal!important">Qt.Orientações</th>
														<th >SLNC</th>
													</tr>
												</thead>
												<tbody>
													
													<cfset slncOrdenado = StructSort(orgaos, "text", "asc")>
													<cfloop array="#slncOrdenado#" index="orgao">
														<cfset percentualSolucionado = (solucionados[orgao] / orgaos[orgao]) * 100>
														<cfset percentualSolucionadoFormatado = Replace(ROUND(percentualSolucionado*10)/10,".",",")  />

														<!--- Adiciona cada linha à tabela --->
														<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
															<td>#orgao#</td>
															<td>#solucionados[orgao]#</td>
															<td>#orgaos[orgao]#</td>
															<td><strong>#percentualSolucionadoFormatado#%</strong></td>
														</tr>
													</cfloop>
												</tbody>
											</cfoutput>
										</table>
									</div>

		
								</cfif>

							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
		</cfif>
		<script language="JavaScript">
		   
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_SLNC_detalhamento_";
				var colunasMostrar = [1,2,8,10];


				const tabSLNCdetalhamento = $('#tabSLNCdetalheMensal').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					lengthMenu: [
						[5, 10, 25, 50, -1],
						[5, 10, 25, 50, 'Todos']
					],
					dom:   "<'row'<'col-sm-4'B><'col-sm-4'p><'col-sm-4 text-right'i>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						}

					]

				})
 
			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				$('#tabResumoSLNCmensal').DataTable({
					order: [[3, 'desc']], // Define a ordem inicial pela coluna SLNC em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false // Remove o campo de busca
				});

			});
		</script>

	</cffunction>



	<cffunction name="resultadoDGCI_diario" access="remote" hint="acompanhamento diário">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

		<cfset var resultadoPRCI = consultaIndicadorPRCI_diario(ano=arguments.ano, mes=arguments.mes)>
    	<cfset var resultadoSLNC = consultaIndicadorSLNC_diario(ano=arguments.ano, mes=arguments.mes)>

		


		<cfset totalDPPRCI = 0 /> 
		<cfset totalFPPRCI = 0 /> 
		<cfset orgaosPRCI = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset dpsPRCI = {}> <!-- Define a variável dps como um objeto vazio -->
		<cfset fpsPRCI = {}> <!-- Define a variável fps como um objeto vazio -->

		<cfloop query="resultadoPRCI"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			<cfif Prazo eq 'DP'> <!-- Verifica se o valor da coluna Prazo é igual a 'DP' -->
				<cfset totalDPPRCI++> <!-- Se a condição for verdadeira, incrementa a variável totalDP em 1 -->
			</cfif>
		</cfloop>

		<cfset totalGeral = resultadoPRCI.recordcount />
		<!--- Calcula a porcentagem --->
		<cfif totalGeral eq 0>
			<cfset percentualDP = 0>
		<cfelse>
			<cfset percentualDP = (totalDPPRCI / totalGeral) * 100 />
		</cfif>
	 	
		


		<cfset totalSolucionadoSLNC = 0 /> 
		<cfset orgaosSLNC = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset solucionadosSLNC = {}> <!-- Define a variável solucionados como um objeto vazio -->
		
		<cfloop query="resultadoSLNC"> <!-- Inicia um loop que itera sobre o conjunto de dados resultado -->
			<cfif status eq 6> 
				<cfset totalSolucionadoSLNC++> 
			</cfif>
		</cfloop>
        <cfoutput>
			<cfset totalGeral = resultadoSLNC.recordcount />
			<cfif totalGeral eq 0>
				<cfset percentualSolucionado = 0>			
			<cfelse>				
				<cfset percentualSolucionado = (totalSolucionadoSLNC / totalGeral *100) />
			</cfif>
			<cfset percentualSolucionadoFormatado = ROUND(percentualSolucionado*10)/10 />

			

			<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#"   >
				SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
					WHERE pc_indPeso_numIndicador = 1 
					and pc_indPeso_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
					and pc_indPeso_ativo = 1
			</cfquery>

			<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#"   >
				SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
					WHERE pc_indPeso_numIndicador = 2 
					and pc_indPeso_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
					and pc_indPeso_ativo = 1
			</cfquery>

			<cfquery name="rsMetaPRCI" datasource="#application.dsn_processos#" >
				SELECT pc_indMeta_meta FROM pc_indicadores_meta 
				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 1
						AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			</cfquery>
			<cfquery name="rsMetaSLNC" datasource="#application.dsn_processos#" >
				SELECT pc_indMeta_meta  FROM pc_indicadores_meta 
				WHERE pc_indMeta_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer"> 
						AND pc_indMeta_numIndicador = 2
						AND pc_indMeta_mcuOrgao = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			</cfquery>

			<cfif rsMetaPRCI.pc_indMeta_meta neq "">
				<cfset metaPRCIorgao= ROUND(rsMetaPRCI.pc_indMeta_meta*10)/10 />
			</cfif>
			
			<cfif rsMetaSLNC.pc_indMeta_meta neq "">
				<cfset metaSLNCorgao= ROUND(rsMetaSLNC.pc_indMeta_meta*10)/10 />
			</cfif>
            
			<cfif rsMetaPRCI.pc_indMeta_meta neq "" and rsMetaSLNC.pc_indMeta_meta neq "">			
				<cfset metaDGCI = ROUND((metaPRCIorgao * rsPRCIpeso.pc_indPeso_peso) + (metaSLNCorgao * rsSLNCpeso.pc_indPeso_peso)*10)/10 />
				<cfset metaDGCIformatado = Replace(metaDGCI,".",",")  />
			<cfelseif rsMetaPRCI.pc_indMeta_meta eq "" and rsMetaSLNC.pc_indMeta_meta neq "">
				<cfset metaDGCI = ROUND((metaSLNCorgao)*10)/10 />
				<cfset metaDGCIformatado = Replace(metaDGCI,".",",")  />
			<cfelseif rsMetaPRCI.pc_indMeta_meta neq "" and rsMetaSLNC.pc_indMeta_meta eq "">
				<cfset metaDGCI = ROUND((metaPRCIorgao)*10)/10 />
				<cfset metaDGCIformatado = Replace(metaDGCI,".",",")  />
			<cfelse>
				<cfset metaDGCI = "" />
				<cfset metaDGCIformatado = "" />
			</cfif>

			



            <cfset percentualDGCI = ROUND((percentualDP * rsPRCIpeso.pc_indPeso_peso) + (percentualSolucionadoFormatado * rsSLNCpeso.pc_indPeso_peso )*10)/10 />
			<cfset percentualDGCIformatado = Replace(NumberFormat(percentualDGCI,0.0),".",",")  />
			<cfif metaDGCI eq 0>
				<cfset DGCIresultadoMeta = ROUND(0*10)/10 />
			<cfelseif metaDGCI eq ''>
				<cfset DGCIresultadoMeta = '' />	
			<cfelse>
				<cfset DGCIresultadoMeta = ROUND((percentualDGCI/metaDGCI)*100*10)/10 />
			</cfif>

			<cfset DGCIresultadoMetaFormatado = Replace(NumberFormat(DGCIresultadoMeta,0.0),".",",") />
	
			<div align="center" class="col-md-12 col-sm-12 col-12 mx-auto" style="margin-bottom:10px">
				<span class="info-box-text" style="font-size:30px">#monthAsString(arguments.mes)#/#arguments.ano#</span>
			</div>	

			<div class="row" style="width: 100%;">	
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body shadow" style="border: 2px solid ##34a2b7">
							<cfif #resultadoPRCI.recordcount# eq 0  and #resultadoSLNC.recordcount# eq 0>
								<h5 align="center">Nenhuma informação foi localizada para o cálculo do DGCI do órgão <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput>.</h5>
							<cfelse>
								<h5 style="text-align: center; margin-bottom:20px">RESULTADO GERAL DO ÓRGÃO <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput></h5>
								<div id="divResultadoDGCI" class="col-md-5 col-sm-5 col-12 mx-auto">
									<!--- Cria um card com o resultado do indicador --->
									<cfset 	infoRodape = '<span style="font-size:14px">DGCI = #percentualDGCIformatado#% (PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span><br>
											        	<span style="font-size:14px">Meta = #metaDGCIformatado#%  (Meta PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (Meta SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span><br>'>			
									<cfset var criarCardIndicador = criarCardIndicador(
										tipoDeCard = 'bg-info',
										siglaIndicador ='DGCI',
										percentualIndicadorFormatado = percentualDGCIformatado,
										resultadoEmRelacaoMeta = DGCIresultadoMeta,
										resultadoEmRelacaoMetaFormatado = DGCIresultadoMetaFormatado,
										infoRodape = infoRodape
									)>
									<cfoutput>#criarCardIndicador#</cfoutput>
									<!--- Fim do card --->								
								</div>	
								<div class="col-12">
									
									<div class="row " style="display: flex; justify-content: center;margin-top:-5px;margin-bottom:5px">
										<i class="fa-solid fa-angles-up" style="font-size:30px;"></i>
									</div>

									<div class="row " style="display: flex; justify-content: center;">
										
										<div id="divResultadoPRCI" class="col-md-5 col-sm-5 col-12 "></div>
										<div id="divResultadoSLNC" class="col-md-5 col-sm-5 col-12 "></div>
									</div>
								</div>
							</cfif>
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
				<!-- /.col -->
			</div>

			<div id ="divResultadosRow" class="row" style="width: 100%;">	
				<div class="col-12">
					<div class="card" >
						<!-- card-body -->
						<div class="card-body" >
							<h5 style="text-align: center; margin-bottom:20px">RESULTADO POR ORGÃOS</h5>
							<div id ="divResultados" class="col-12">
								<div id="divTabResumoIndicadores" >
									<div id="divTabDGCIorgaos" class="row" style="display: flex; justify-content: center;">
										<div style="width: 500px; margin: 0 auto;">
											<table id="tabDGCIorgaos" class="table table-bordered table-striped text-nowrap" style="width:100%; cursor:pointer">
												<thead style="background: ##17a2b8; color: ##fff; text-align: center; ">
													<tr style="font-size:14px;">
														<th colspan="6" style="padding:5px">DGCI - <span>#monthAsString(arguments.mes)#/#arguments.ano#</span></th>
													</tr>
													<tr style="font-size:14px">
														<th style="font-weight: normal!important">Órgão</th>
														<th class="bg-gradient-warning" style="font-weight: normal!important">PRCI</th>
														<th class="bg-gradient-warning" style="font-weight: normal!important">SLNC</th>
														<th >DGCI</th>
														<th >Meta</th>
														<th>Resultado</th>

													</tr>
												</thead>
												
												<tbody id="theadTableBody">
													<!-- Aqui serão inseridas as linhas da tabela via jQuery -->
												</tbody>
											</table>
										</div>
									</div>
									
									<div class="row " style="display: flex; justify-content: center;margin-top:10px;margin-bottom:5px">
										<i class="fa-solid fa-angles-up" style="font-size:30px;"></i>
									</div>
									<div class="row " style="display: flex; justify-content: center;">
										<div id="divTabPRCIorgaos" class="row" class="col-md-6 col-sm-6 col-12 " style="margin-right: 300px;"></div>
										<div id="divTabSLNCorgaos" class="row" class="col-md-6 col-sm-6 col-12 "></div>
									</div>
								</div>
							</div>
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
				<!-- /.col -->
			</div>

		</cfoutput>

		
		
		<script language="JavaScript">
			$(document).ready(function(){
				
				$(".content-wrapper").css("height", "auto");
				var divResultPRCI = $("#divResultPRCI");
				var divResultadoPRCI = $("#divResultadoPRCI");
				divResultadoPRCI.html(divResultPRCI.html());

				var divResultSLNC = $("#divResultSLNC");
				var divResultadoSLNC = $("#divResultadoSLNC");
				divResultadoSLNC.html(divResultSLNC.html());


				var divResumoPRCI = $("#divTabResumoPRCI");
				var divTabPRCIorgaos = $("#divTabPRCIorgaos");
				divTabPRCIorgaos.html(divResumoPRCI.html());
				
				var divResumoSLNC = $("#divTabResumoSLNC");
				var divTabSLNCorgaos = $("#divTabSLNCorgaos");
				divTabSLNCorgaos.html(divResumoSLNC.html());
				
				divResultPRCI.html("")
				divResultSLNC.html("")
				divResumoPRCI.html("")
				divResumoSLNC.html("")

				// Função para calcular o DGCI
				function calcularDGCI() {
					// Selecionar todas as linhas da tabela tabResumoPRCI
					var prciRows = $('#tabResumoPRCI tbody tr');
					// Selecionar todas as linhas da tabela tabResumoSLNC
					var slncRows = $('#tabResumoSLNC tbody tr');
					// Selecionar a thead da tabela tabDGCIorgaos
					var theadTable = $('#theadTableBody');
					var hasData = false; // Definir hasData como falso por padrão

					theadTable.empty(); // Limpar os dados da tabela tabDGCIorgaos antes de preencher

					var allOrgaos = {}; // Objeto para armazenar dados de todos os órgãos

					// Preencher allOrgaos com dados da tabela tabResumoPRCI
					prciRows.each(function() {
						var orgao = $(this).find('td:first').text().trim(); // Nome do órgão
						var prci = parseFloat($(this).find('td:eq(3)').text().replace('%', '').replace(',', '.').trim()); // Valor do PRCI
						var metaPRCI = parseFloat($(this).find('td:eq(4)').text().replace('%', '').replace(',', '.').trim()); // Valor da meta do PRCI
						allOrgaos[orgao] = { 'PRCI': prci, 'MetaPRCI': metaPRCI }; // Adicionar PRCI e meta do PRCI ao órgão
					});

					// Preencher allOrgaos com dados da tabela tabResumoSLNC
					slncRows.each(function() {
						var orgao = $(this).find('td:first').text().trim(); // Nome do órgão
						var slnc = parseFloat($(this).find('td:eq(3)').text().replace('%', '').replace(',', '.').trim()); // Valor do SLNC
						var metaSLNC = parseFloat($(this).find('td:eq(4)').text().replace('%', '').replace(',', '.').trim()); // Valor da meta do SLNC
						// Verificar se o órgão já existe em allOrgaos
						if (allOrgaos[orgao]) {
							allOrgaos[orgao]['SLNC'] = slnc; // Adicionar SLNC ao órgão existente
							allOrgaos[orgao]['MetaSLNC'] = metaSLNC; // Adicionar meta do SLNC ao órgão existente
						} else {
							allOrgaos[orgao] = { 'SLNC': slnc, 'MetaSLNC': metaSLNC }; // Adicionar SLNC e meta do SLNC ao órgão
						}
						
					});

					// Preencher a terceira tabela com os dados calculados
					<cfoutput>
						let pesoPRCI = #rsPRCIpeso.pc_indPeso_peso#;
						let pesoSLNC = #rsSLNCpeso.pc_indPeso_peso#
					</cfoutput>
					$.each(allOrgaos, function(orgao, data) {
						var prci = data['PRCI'] ; 
						var slnc = data['SLNC'] ; 
						var metaPRCI = data['MetaPRCI'] ;
						var metaSLNC = data['MetaSLNC'] ;
						
						if(isNaN(prci) && isNaN(slnc)){
							var dgci ="sem dados";
							var prci = "sem dados";
							var slnc = "sem dados";
													
						} 

						if(isNaN(prci) && !isNaN(slnc)){
							var slnc = slnc
							var prci = "sem dados";
							var dgci = slnc;
							
						}
						if(!isNaN(prci) && isNaN(slnc)){
							var slnc = "sem dados";
							var dgci = prci;
						}	
						if(!isNaN(prci) && !isNaN(slnc)){
							var dgci = (prci * pesoPRCI) + (slnc * pesoSLNC); // Calcular o DGCI
						}

						if(isNaN(metaPRCI) && isNaN(metaSLNC)){
							var dgci = "sem meta";
							var resutadoDGCI = "sem meta";
						}
						if(isNaN(metaPRCI) && !isNaN(metaSLNC)){
							var metaDGCI = metaSLNC;
							var resutadoDGCI = (slnc/metaSLNC)*100;
						}
						if(!isNaN(metaPRCI) && isNaN(metaSLNC)){
							var metaDGCI = metaPRCI;
							var resutadoDGCI = (prci/metaPRCI)*100;
						}
						if(!isNaN(metaPRCI) && !isNaN(metaSLNC)){
							var metaDGCI = (metaPRCI * pesoPRCI) + (metaSLNC * pesoSLNC); // Calcular a meta do DGCI
							var resutadoDGCI = (dgci/metaDGCI)*100; // Calcular o resultado do DGCI
						}

						var formatNumber = function(number) {
							// Verifica se o número é um número válido
							if (!isNaN(number)) {
								// Formata o número com uma casa decimal e substitui o ponto por vírgula
								return parseFloat(number).toFixed(1).replace('.', ',');
							} else {
								// Se não for um número válido, retorna o valor original
								return number;
							}
						};

						var formatPercentage = function(number) {
							// Verifica se o número é um número válido
							if (!isNaN(number)) {
								// Formata o número com uma casa decimal e substitui o ponto por vírgula
								return formatNumber(number) + '%';
							} else {
								// Se não for um número válido, retorna uma string vazia
								return number;
							}
						};

						var newRow = '<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;">' +
							'<td>' + orgao + '</td>' +
							'<td>' + formatPercentage(prci) + '</td>' +
							'<td>' + formatPercentage(slnc) + '</td>' +
							'<td><strong>' + formatPercentage(dgci) + '</strong></td>' +
							'<td>' + formatPercentage(metaDGCI) + '</td>' +
							//inserir <td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>
							'<td ><span class="tdResult statusOrientacoes" data-value="' + formatPercentage(resutadoDGCI) + '"></span></td>' +
							'</tr>';

						theadTable.append(newRow); // Adicionar nova linha à tabela tabDGCIorgaos
						hasData = true; // Atualizar hasData para verdadeiro se houver dados
					});

					// Classificar as linhas da terceira tabela por DGCI decrescente
					var rows = theadTable.find('tr').get();
					rows.sort(function(a, b) {
						var dgciA = parseFloat($(a).find('td:eq(3)').text()); // DGCI da linha A
						var dgciB = parseFloat($(b).find('td:eq(3)').text()); // DGCI da linha B
						return dgciB - dgciA; // Ordenar de forma decrescente
					});
					$.each(rows, function(index, row) {
						theadTable.append(row); // Adicionar linhas classificadas à tabela tabDGCIorgaos
					});

					// Exibir à tabela tabDGCIorgaos se houver dados, caso contrário, ocultá-la
					if (hasData) {
						$('#divResultadosRow').show();
					} else {
						$('#divResultadosRow').hide();
					}

					$('.ribbon').each(function() {
						updateRibbon($(this));
					});
				}


				calcularDGCI();

				// Inicializa a tabela para ser ordenável pelo plugin DataTables
				const tabDGCIorgaosResumo = $('#tabDGCIorgaos').DataTable({
					destroy: true, // Destruir a tabela antes de recriá-la
					order: [[3, 'desc']], // Define a ordem inicial pela coluna DGCI em ordem decrescente
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false // Remove o campo de busca
				});	



			});

		   
		</script>
	</cffunction>



	<cffunction name="formIndicadoresCI" access="remote" hint="mostra os dados dos indicadores de todos os órgãos para o controle interno">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>

		
		
		<cfquery name="rsIndicadoresPorOrgao" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indOrgao_ano
				   ,pc_indOrgao_mes
				   ,pc_indOrgao_numIndicador
				   ,pc_indOrgao_mcuOrgao
				   ,pc_orgaos.pc_org_sigla as siglaOrgao
				   ,pc_indOrgao_resultadoMes 
				   ,pc_indOrgao_resultadoAcumulado 
				   ,pc_indOrgao_paraOrgaoSubordinador
 				   ,pc_indOrgao_mcuOrgaoSubordinador
				   ,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
			FROM pc_indicadores_porOrgao
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_porOrgao.pc_indOrgao_mcuOrgaoSubordinador
			WHERE pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
		</cfquery>

        
		<cfquery name="resultadoECTmes" dbtype="query"  >
			SELECT  pc_indOrgao_mes
					,pc_indOrgao_numIndicador
					,AVG(pc_indOrgao_resultadoMes) AS media_resultadoMes
					,AVG(pc_indOrgao_resultadoAcumulado) AS media_resultadoAcumulado
			FROM rsIndicadoresPorOrgao
			WHERE pc_indOrgao_paraOrgaoSubordinador = 1
			and pc_indOrgao_mes <= <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
			GROUP BY pc_indOrgao_mes, pc_indOrgao_numIndicador
			ORDER BY pc_indOrgao_mes, pc_indOrgao_numIndicador
		</cfquery>
		
		

		<cfquery name="resultadoPorOrgao" dbtype="query" >
			SELECT *FROM rsIndicadoresPorOrgao
			WHERE pc_indOrgao_mes = <cfqueryparam value="#arguments.mes#" cfsqltype="cf_sql_integer">
		</cfquery>



		<cfquery name="resultadoDGCIporOrgaoSubordinador"   dbtype="query">
			SELECT * FROM resultadoPorOrgao	WHERE pc_indOrgao_paraOrgaoSubordinador = 1	AND pc_indOrgao_numIndicador = 3
		</cfquery>

		<cfquery name="resultadoDGCIporOrgResp"   dbtype="query">
			SELECT * FROM resultadoPorOrgao	
			WHERE pc_indOrgao_paraOrgaoSubordinador = 0	
				  AND pc_indOrgao_numIndicador = 3
				  
		</cfquery>

		<cfquery name="resultadoPRCIporOrgaoSubordinador"   dbtype="query">
			SELECT * FROM resultadoPorOrgao	WHERE pc_indOrgao_numIndicador = 1 AND pc_indOrgao_paraOrgaoSubordinador = 1
		</cfquery>

		<cfquery name="resultadoPRCIporGerencia"   dbtype="query">
			SELECT * FROM resultadoPorOrgao	WHERE pc_indOrgao_numIndicador = 1 AND pc_indOrgao_paraOrgaoSubordinador = 0 
		</cfquery>

		<cfquery name="resultadoSLNCporOrgaoSubordinador"   dbtype="query">
			SELECT * FROM resultadoPorOrgao	WHERE pc_indOrgao_numIndicador = 2 AND pc_indOrgao_paraOrgaoSubordinador = 1
		</cfquery>

		<cfquery name="resultadoSLNCporGerencia"   dbtype="query">
			SELECT * FROM resultadoPorOrgao	WHERE pc_indOrgao_numIndicador = 2 AND pc_indOrgao_paraOrgaoSubordinador = 0 AND pc_indOrgao_mcuOrgao <>pc_indOrgao_mcuOrgaoSubordinador
		</cfquery>

		
		<cfquery name="rsPRCIpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE  pc_indPeso_numIndicador = 1 
				and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>

		<cfquery name="rsSLNCpeso" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT	pc_indPeso_peso FROM pc_indicadores_peso 
				WHERE pc_indPeso_numIndicador = 2 
				and pc_indPeso_ano = <cfqueryparam value="#ano#" cfsqltype="cf_sql_integer">
				and pc_indPeso_ativo = 1
		</cfquery>


		

		<cfquery name="resultadoDetalhe" datasource="#application.dsn_processos#" timeout="120"  >
			SELECT pc_indDados_numPosic
				,pc_indDados_mcuOrgaoResp as mcuOrgaoResp
				,pc_orgaos.pc_org_sigla as siglaOrgaoResp
				,pc_indDados_mcuOrgaoSubordinador as mcuOrgaoSubordinador
				,pc_orgaosSubordinador.pc_org_sigla as siglaOrgaoSubordinador
				,pc_indDados_mcuOrgaoAvaliado as mcuOrgaoAvaliado
				,pc_orgaoAvaliado.pc_org_sigla as siglaOrgaoAvaliado
				,pc_indDados_numProcesso as numProcessoSNCI
				,pc_indDados_numItem as item
				,pc_indDados_numOrientacao as orientacao
				,pc_indDados_dataPrevista as dataPrevista
				,pc_indDados_status as numStatus
				,pc_indDados_descricaoStatus as descricaoOrientacaoStatus
				,pc_indDados_dataRef as dataRef
				,pc_indDados_numIndicador as numIndicador
				,CASE 
					WHEN pc_indDados_descricaoStatus = 'PENDENTE' THEN DATEADD(day, 1, pc_indDados_dataPrevista)
					ELSE pc_indDados_dataStatus
				END as dataPosicao
				,pc_indDados_prazo as prazo

			FROM pc_indicadores_dados
			INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoResp
			INNER JOIN pc_orgaos as pc_orgaosSubordinador on pc_orgaosSubordinador.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoSubordinador
			INNER JOIN pc_orgaos as pc_orgaoAvaliado on pc_orgaoAvaliado.pc_org_mcu = pc_indicadores_dados.pc_indDados_mcuOrgaoAvaliado
			WHERE pc_indDados_dataRef = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">

		</cfquery>

		<cfquery name="resultadoPRCIdetalhe"   dbtype="query">
			SELECT * FROM resultadoDetalhe	WHERE numIndicador = 1
		</cfquery>

		<cfquery name="resultadoSLNCdetalhe"   dbtype="query">
			SELECT * FROM resultadoDetalhe	WHERE numIndicador = 2
		</cfquery>

		
		
		<div id="divMesAno" class="row" style="width: 100%;">	
			<cfif resultadoDetalhe.recordcount eq 0>
				<h5 style="color:#0083CA;text-align: center;padding:40px">Nenhuma informação foi localizada para o mês <cfoutput>#monthAsString(arguments.mes)#</cfoutput>/<cfoutput>#arguments.ano#</cfoutput>.</h5>
			<cfelse>
				<cfoutput><h4 style="color:##0083CA;text-align: center;padding:10px">#monthAsString(arguments.mes)#/#arguments.ano# </h4></cfoutput>
			</cfif>
		</div>


		<cfif resultadoECTmes.recordcount neq 0>
			<div id="divIndicadoresMes" class="row" >
				<div class="row" style="width: 100%;">	
					<div class="col-12">
						<div class="card" >

							<div class="card-body shadow" style="border: 2px solid #34a2b7">
								<div class="table-responsive " style="width: 850px; margin: 0 auto;">
									<h4 style=" text-align: center;">DGCI ECT <cfoutput>#arguments.ano#</cfoutput> por Mês:</h4>
									<table id="tabIndicadoresMes" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
										
										<thead >
											<tr style="font-size:14px;text-align: center;">
												<th >MÊS</th>
												<th >PRCI</th>
												<th >SLNC</th>
												<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;text-align: center;">
													DGCI<br>
													<cfoutput>
														<span style="font-size: 9px">(PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span>
													</cfoutput>
												</th>
												<th >META</th>
												<th >RESULTADO</th>
												<th >Result. % em Relação<br>à Meta</th>
											</tr>
										</thead>
										<tbody>
											
										
											<cfset totalMetaDGCI = {}>
											<cfset count = {}>

											<!--- Loop pelos meses --->
											<cfloop index="month" from="1" to="#arguments.mes#">
												<!--- Inicializar total e contagem para o mês atual --->
												<cfset totalMetaDGCI[month] = 0>
												<cfset count[month] = 0>

												<cfquery name="rsOrgaosDGCI" dbtype="query" >
													SELECT pc_indOrgao_mcuOrgao FROM rsIndicadoresPorOrgao
													WHERE pc_indOrgao_mes = <cfqueryparam value="#month#" cfsqltype="cf_sql_integer">
														AND pc_indOrgao_numIndicador = 3
														AND pc_indOrgao_paraOrgaoSubordinador = 1
												</cfquery>

												<cfloop query="rsOrgaosDGCI">

													<!--- Inicializar as metas como 0 caso sejam NULL --->
													<cfset metaPRCI = 0>
													<cfset metaSLNC = 0>
													
													<cfquery name="metaPRCIporOrgao" datasource="#application.dsn_processos#">
														SELECT  COALESCE(AVG(COALESCE(meta,0)),0) AS metaMes from (
															SELECT DISTINCT pc_indOrgao_ano, pc_indMeta_mes, pc_indOrgao_mcuOrgaoSubordinador, pc_indMeta_mcuOrgao, pc_indicadores_meta.pc_indMeta_meta as meta from pc_indicadores_porOrgao
															INNER JOIN pc_indicadores_meta ON pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao = pc_indicadores_meta.pc_indMeta_mcuOrgao 
																	and pc_indicadores_porOrgao.pc_indOrgao_numIndicador = pc_indicadores_meta.pc_indMeta_numIndicador and pc_indicadores_porOrgao.pc_indOrgao_ano = pc_indicadores_meta.pc_indMeta_ano and pc_indicadores_porOrgao.pc_indOrgao_mes = pc_indicadores_meta.pc_indMeta_mes
																	WHERE pc_indOrgao_mcuOrgaoSubordinador = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indOrgao_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_mes = <cfqueryparam value="#month#" cfsqltype="cf_sql_integer">
																
														) as metaPRCI
													</cfquery>
													

													<cfif metaPRCIporOrgao.recordcount eq 0>
														<cfset metaPRCI = 0>
													<cfelse>
														<cfset metaPRCI = metaPRCIporOrgao.metaMes>
													</cfif>

													<cfquery name="metaSLNCporOrgao" datasource="#application.dsn_processos#">
														SELECT  COALESCE(AVG(COALESCE(meta,0)),0) AS metaMes from (
															SELECT DISTINCT pc_indOrgao_ano, pc_indMeta_mes, pc_indOrgao_mcuOrgaoSubordinador, pc_indMeta_mcuOrgao, pc_indicadores_meta.pc_indMeta_meta as meta from pc_indicadores_porOrgao
															INNER JOIN pc_indicadores_meta ON pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao = pc_indicadores_meta.pc_indMeta_mcuOrgao 
																	and pc_indicadores_porOrgao.pc_indOrgao_numIndicador = pc_indicadores_meta.pc_indMeta_numIndicador and pc_indicadores_porOrgao.pc_indOrgao_ano = pc_indicadores_meta.pc_indMeta_ano and pc_indicadores_porOrgao.pc_indOrgao_mes = pc_indicadores_meta.pc_indMeta_mes
															WHERE pc_indOrgao_mcuOrgaoSubordinador = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indOrgao_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_ano = <cfqueryparam value="#arguments.ano#" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_mes = <cfqueryparam value="#month#" cfsqltype="cf_sql_integer">
																
														) as metaSLNC
													</cfquery>
													<cfif metaSLNCporOrgao.recordcount eq 0>
														<cfset metaSLNC = 0>
													<cfelse>
														<cfset metaSLNC = metaSLNCporOrgao.metaMes>
													</cfif>
													
													<cfset metaDGCI = (metaPRCI * rsPRCIpeso.pc_indPeso_peso) + (metaSLNC * rsSLNCpeso.pc_indPeso_peso)>

													<!--- Adicionar ao total e incrementar contador para o mês --->
													<cfset totalMetaDGCI[month] += round(metaDGCI*10)/10>
													<cfset count[month]++>
													
												</cfloop>
											</cfloop>

											<!--- Calcular a média do DGCI para cada mês --->
											<cfset mediaMetaDGCI = {}>
											<cfloop index="month" from="1" to="#arguments.mes#">
												<cfif count[month] neq 0>
													<cfset mediaMetaDGCI[month] = ROUND(totalMetaDGCI[month]*10)/10 / count[month]>
												<cfelse>
													<cfset mediaMetaDGCI[month] = 0>
												</cfif>
												
											</cfloop>

											<cfset DGCIcount = 0>
											<cfset DGCIsoma = 0>
											<cfset DGCImetaSoma = 0>


											<cfoutput query="resultadoECTmes" group="pc_indOrgao_mes">

																							
												<tr style="font-size:12px;text-align: center;">
													
													<td>#monthAsString(pc_indOrgao_mes)#</td>
													<td>
														<cfoutput>
															#IIF(pc_indOrgao_numIndicador EQ 1, Replace(NumberFormat(ROUND(media_resultadoMes*10)/10,0.0),',','.'), "")#
														</cfoutput>
													</td>
													<td>
														<cfoutput>
															#IIF(pc_indOrgao_numIndicador EQ 2, Replace(NumberFormat(ROUND(media_resultadoMes*10)/10,0.0),',','.'), "")#
														</cfoutput>
													</td>
													<td>
														<cfoutput>
															<strong>#IIF(pc_indOrgao_numIndicador EQ 3, Replace(NumberFormat(ROUND(media_resultadoMes*10)/10,0.0),',','.'), "")#</strong>
														</cfoutput>
													</td>
													<cfset metaDGCI = mediaMetaDGCI[pc_indOrgao_mes]>
													<cfset DGCImetaSoma += metaDGCI>
													<td>#NumberFormat(ROUND(metaDGCI*10)/10,0.0)#</td>

													<cfif IIF(pc_indOrgao_numIndicador EQ 3, Replace(ROUND(media_resultadoMes*10)/10,',','.'), "") gt  metaDGCI and  metaDGCI neq 0>
														<td style="color: blue;"><span class="statusOrientacoes" style="background:##0083CA;color:##fff;">ACIMA DO ESPERADO</span></td>
													<cfelseif IIF(pc_indOrgao_numIndicador EQ 3, Replace(ROUND(media_resultadoMes*10)/10,',','.'), "") lt  metaDGCI and  metaDGCI neq 0>
														<td ><span class="statusOrientacoes" style="background:##dc3545;color:##fff;">ABAIXO DO ESPERADO</span></td>	
													<cfelseif IIF(pc_indOrgao_numIndicador EQ 3, Replace(ROUND(media_resultadoMes*10)/10,',','.'), "") eq  metaDGCI and  metaDGCI neq 0>
														<td ><span class="statusOrientacoes" style="background:green;color:##fff;">DENTRO DO ESPERADO</span></td>
													<cfelse>
														<td><span class="statusOrientacoes" style="background:##fff;color:gray;">SEM META</span></td>	
													</cfif>

													
													<cfoutput>
														<cfif metaDGCI neq 0>
															<cfset percentual = (#IIF(pc_indOrgao_numIndicador EQ 3, Replace(NumberFormat(media_resultadoMes,0.0),',','.'), 0)#/#NumberFormat(metaDGCI, '0.0')#)*100 >
																
														<cfelse>
															<cfset percentual = 0>
														</cfif>
														<cfset DGCIcount += #IIF(pc_indOrgao_numIndicador EQ 3, 1, 0)#>
														<cfset DGCIsoma += #IIF(pc_indOrgao_numIndicador EQ 3, ROUND(media_resultadoMes*10)/10, 0)#>
													</cfoutput>
													
													<cfif percentual neq 0>
														<td >#NumberFormat(ROUND(percentual*10)/10,0.0)#</td>
													<cfelse>
														<td><span class="statusOrientacoes" style="background:##fff;color:gray;">SEM META</span></td>	
													</cfif>

													

												</tr>
											</cfoutput>
										
											<cfset DGCIano = round((DGCIsoma/DGCIcount)*10)/10>
											<cfset DGCImetaAno = round((DGCImetaSoma/DGCIcount)*10)/10>

										</tbody>
									</table>
								</div>
							</div>

						</div>
						<!-- /.card -->
					</div>
					<!-- /.col -->
				</div>
			</div>
		</cfif>



		<cfif resultadoDGCIporOrgaoSubordinador.recordcount neq 0 >	
	
			<div id="divDGCIporOrgaoSubord" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							<div class="table-responsive ">
								<table id="tabDGCIporOrgaoSubord" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead >
										<tr style="font-size:14px;text-align: center;">
											<th >Órgão</th>
											<th >PRCI <br><cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th >SLNC <br><cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;text-align: center;">
												DGCI 
												<cfoutput>
													#monthAsString(arguments.mes)#<br>
													<span style="font-size: 9px">(PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span>
												</cfoutput>
											</th>
											<th >Meta</th>
											<th >Resultado <cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;text-align: center;">DGCI<br>Acumulado</th>
											<th>Resultado Acumulado</th>
											<th >Result. % em Relação<br>à Meta Mensal</th>
										</tr>
									</thead>
									
									<tbody>
									    <cfset totalPRCI = 0>
										<cfset totalSLNC = 0>
										<cfset totalDGCI = 0>
										<cfset totalMeta = 0>
										<cfset totalDGCIAcumulado = 0>
										<cfset totalPRCIAcumulado = 0>
										<cfset totalSLNCAcumulado = 0>
										<cfset count = 0>
										<cfset countPRCI = 0>
										<cfset countSLNC = 0>
										<cfloop query="resultadoDGCIporOrgaoSubordinador" >
										    <cfset count = count + 1>
											<cfoutput>	
												<cfquery name="resultadoPRCI"   dbtype="query">
													SELECT pc_indOrgao_resultadoMes as prci, pc_indOrgao_resultadoAcumulado FROM resultadoPorOrgao	
													WHERE pc_indOrgao_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoDGCIporOrgaoSubordinador.pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
													AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
												</cfquery>	
												<cfif resultadoPRCI.recordcount neq 0>
													<cfset countPRCI = countPRCI + 1>
												</cfif>

												<cfquery name="resultadoSLNC"   dbtype="query">
													SELECT pc_indOrgao_resultadoMes as slnc, pc_indOrgao_resultadoAcumulado  FROM resultadoPorOrgao	
													WHERE pc_indOrgao_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoDGCIporOrgaoSubordinador.pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
													AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
												</cfquery>
												<cfif resultadoSLNC.recordcount neq 0>
													<cfset countSLNC = countSLNC + 1>
												</cfif>

												

												<cfquery name="metaPRCIporOrgao" datasource="#application.dsn_processos#">
													SELECT  COALESCE(AVG(COALESCE(meta,0)),0) AS metaMes from (
														SELECT DISTINCT pc_indOrgao_ano, pc_indMeta_mes, pc_indOrgao_mcuOrgaoSubordinador, pc_indMeta_mcuOrgao, pc_indicadores_meta.pc_indMeta_meta as meta from pc_indicadores_porOrgao
														INNER JOIN pc_indicadores_meta ON pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao = pc_indicadores_meta.pc_indMeta_mcuOrgao 
																and pc_indicadores_porOrgao.pc_indOrgao_numIndicador = pc_indicadores_meta.pc_indMeta_numIndicador and pc_indicadores_porOrgao.pc_indOrgao_ano = pc_indicadores_meta.pc_indMeta_ano and pc_indicadores_porOrgao.pc_indOrgao_mes = pc_indicadores_meta.pc_indMeta_mes
																WHERE pc_indOrgao_mcuOrgaoSubordinador = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
															AND pc_indOrgao_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
															AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
															AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
															
													) as metaPRCI
												</cfquery>
												

												<cfif metaPRCIporOrgao.recordcount eq 0>
													<cfset metaPRCI = 0>
												<cfelse>
													<cfset metaPRCI = metaPRCIporOrgao.metaMes>
												</cfif>

												<cfquery name="metaSLNCporOrgao" datasource="#application.dsn_processos#">
													SELECT  COALESCE(AVG(COALESCE(meta,0)),0) AS metaMes from (
														SELECT DISTINCT pc_indOrgao_ano, pc_indMeta_mes, pc_indOrgao_mcuOrgaoSubordinador, pc_indMeta_mcuOrgao, pc_indicadores_meta.pc_indMeta_meta as meta from pc_indicadores_porOrgao
														INNER JOIN pc_indicadores_meta ON pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao = pc_indicadores_meta.pc_indMeta_mcuOrgao 
																and pc_indicadores_porOrgao.pc_indOrgao_numIndicador = pc_indicadores_meta.pc_indMeta_numIndicador and pc_indicadores_porOrgao.pc_indOrgao_ano = pc_indicadores_meta.pc_indMeta_ano and pc_indicadores_porOrgao.pc_indOrgao_mes = pc_indicadores_meta.pc_indMeta_mes
														WHERE pc_indOrgao_mcuOrgaoSubordinador = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
															AND pc_indOrgao_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
															AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
															AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
															
													) as metaSLNC
												</cfquery>
												<cfif metaSLNCporOrgao.recordcount eq 0>
													<cfset metaSLNC = 0>
												<cfelse>
													<cfset metaSLNC = metaSLNCporOrgao.metaMes>
												</cfif>
												
												<cfset metaDGCI = (metaPRCI * rsPRCIpeso.pc_indPeso_peso) + (metaSLNC * rsSLNCpeso.pc_indPeso_peso)>

											
											    <cfset metaMes = NumberFormat(0, '0.0')>		
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >

													<td style="text-align: left;">#siglaOrgao# (#pc_indOrgao_mcuOrgao#)</td>
													<cfif resultadoPRCI.prci neq ''>
														<td >#NumberFormat(ROUND(resultadoPRCI.prci*10)/10,0.0)#</td>
													<cfelse>
														<td style="color:red">sem dados</td>
													</cfif>
													<cfif resultadoSLNC.slnc neq ''>
														<td >#NumberFormat(ROUND(resultadoSLNC.slnc*10)/10,0.0)#</td>
													<cfelse>
														<td style="color:red">sem dados</td>
													</cfif>
													<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(pc_indOrgao_resultadoMes*10)/10,0.0)#</strong></td>
													<cfif metaDGCI eq ''>
														<td>#NumberFormat(metaMes,0.0)#</td>
													<cfelse>
														<cfset metaMes = ROUND(metaDGCI*10)/10>
														<td>#NumberFormat(metaMes,0.0)#</td>
													</cfif>

													<cfif metaMes neq 0>
														<cfset resultMesEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoMes*10)/10 / metaMes)*100*10)/10>
														<cfset resultAcumuladoEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoAcumulado*10)/10 / metaMes)*100*10)/10>
													<cfelse>
														<cfset resultMesEmRelacaoMeta = ROUND(0*10)/10>	
														<cfset resultAcumuladoEmRelacaoMeta = ROUND(0*10)/10>
													</cfif>

													<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>

													<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(pc_indOrgao_resultadoAcumulado*10)/10,0.0)#</strong></td>

													<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>

													<td>#NumberFormat(resultMesEmRelacaoMeta,0.0)#</td>


												</tr>
											</cfoutput>	
											<!-- RESUMO -->
											<cfif resultadoPRCI.prci neq ''>
												<cfset totalPRCI = totalPRCI + resultadoPRCI.prci>
											</cfif>
											<cfif  resultadoSLNC.slnc neq ''>
												<cfset totalSLNC = totalSLNC + resultadoSLNC.slnc>
											</cfif>

											<cfset totalDGCI = totalDGCI + pc_indOrgao_resultadoMes>

											<cfset totalMeta = totalMeta + metaMes>

											<cfif pc_indOrgao_resultadoAcumulado neq ''>
												<cfset totalDGCIAcumulado = totalDGCIAcumulado + pc_indOrgao_resultadoAcumulado>
											</cfif>
											<cfif resultadoPRCI.pc_indOrgao_resultadoAcumulado neq ''>
												<cfset totalPRCIAcumulado = totalPRCIAcumulado + resultadoPRCI.pc_indOrgao_resultadoAcumulado>
											</cfif>
											<cfif resultadoSLNC.pc_indOrgao_resultadoAcumulado neq ''>
												<cfset totalSLNCAcumulado = totalSLNCAcumulado + resultadoSLNC.pc_indOrgao_resultadoAcumulado>
											</cfif>

										</cfloop>	

										
									</tbody>
									<cfif count gt 0>
											<!-- Cálculo das médias -->
											<cfset mediaPRCI = Replace(ROUND(totalPRCI / countPRCI*10)/10,'.',',')>
											<cfset mediaSLNC = Replace(ROUND(totalSLNC / countSLNC*10)/10,'.',',')>
											<cfset mediaDGCI = Replace(ROUND(totalDGCI / count*10)/10,'.',',')>
											<cfset mediaMeta = Replace(ROUND(totalMeta / count*10)/10,'.',',')>

											<cfset mediaDGCISemReplace = ROUND(totalDGCI / count*10)/10>
											<cfset mediaMetaSemReplace = ROUND(totalMeta / count*10)/10>

											
											<cfif mediaMetaSemReplace eq ROUND(0*10)/10>
												<cfset resultaDGCIemRelacaoAmetaSemReplace = ROUND(0*10)/10>
												<cfset DGCIanoEmRelacaoAmetaSemReplace = ROUND(0*10)/10>
												<cfset resultaDGCIemRelacaoAmeta = ROUND(0*10)/10>
												<cfset DGCIanoEmRelacaoAmeta = ROUND(0*10)/10>
											<cfelse>
											    <cfset resultaDGCIemRelacaoAmetaSemReplace = (mediaDGCISemReplace / mediaMetaSemReplace)*100>
												<cfset DGCIanoEmRelacaoAmetaSemReplace = (DGCIano / DGCImetaAno)*100>
												<cfset resultaDGCIemRelacaoAmeta = Replace(ROUND((mediaDGCISemReplace / mediaMetaSemReplace)*100*10)/10,'.',',')>
												<cfset DGCIanoEmRelacaoAmeta = Replace(ROUND((DGCIano / DGCImetaAno)*100*10)/10,'.',',')>
											</cfif>

									</cfif>

								</table>

							</div>							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
            <div id="divCardDGCIectMes">
				<cfif count gt 0>

					<div class="row" style="width: 100%;">	
						<div class="col-12">
							<div class="card" >
								
								<cfoutput>
									<!-- card-body -->
									<div class="card-body shadow" style="border: 2px solid ##34a2b7">
									   
										<div id="divDGCI_mes_ano"><h4 style="text-align: center; margin-bottom:20px">DGCI ECT - <span style="fontsize:12px">#monthAsString(arguments.mes)#/#arguments.ano#</span></h5></div>
										<div id="divResultadoDGCI" class="col-md-8 col-sm-8 col-12 mx-auto">
											<div class="info-box bg-info">
											     <div class="ribbon-wrapper ribbon-xl"  >
													<div class="ribbon" id="ribbon" data-value="#resultaDGCIemRelacaoAmetaSemReplace#"></div>
												</div>
												<span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

												<div class="info-box-content">
													<span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:30px"><strong>DGCI = #mediaDGCI#%</strong></font></font><span style="font-size:12px;position: relative;left:-194px;top:13px">Desempenho Geral de Controle Interno</span></span>
													<span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong> #resultaDGCIemRelacaoAmeta#%</strong></font></font><span style="font-size:10px;"> em relação a meta = (DGCI / Meta) * 100 = (#mediaDGCI# / #mediaMeta#) * 100</span></span>

													<div class="progress">
														<div class="progress-bar" style="width: #resultaDGCIemRelacaoAmetaSemReplace#%"></div>
													</div>
													<span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
														<span style="font-size:14px"><strong>DGCI #monthAsString(arguments.mes)#</strong> =  <span style="font-size:16px"><strong>#mediaDGCI#%</strong></span> (média dos DGCI dos órgãos subordinadores)</span><br>
														<span style="font-size:14px"><strong>Meta</strong> = <span style="font-size:16px"><strong>#mediaMeta#%</strong></span></span><span> (média das metas do DGCI dos órgãos subordinadores)</span><br>
													</font></font></span>
												</div>
												<!-- /.info-box-content -->
											</div>
										
										
										</div>	
										<div class="col-12">
											<!--
											<div class="row " style="display: flex; justify-content: center;margin-top:-5px;margin-bottom:5px">
												<i class="fa-solid fa-angles-up" style="font-size:30px;"></i>
											</div>-->

											<div class="row " style="display: flex; justify-content: center;">
												
												<div id="divResultadoPRCI" class="col-md-5 col-sm-5 col-12 "></div>
												<div id="divResultadoSLNC" class="col-md-5 col-sm-5 col-12 "></div>
											</div>
										</div>
										
									</div>
									<!-- /.card-body -->
								</cfoutput>
							</div>
							<!-- /.card -->
						</div>
						<!-- /.col -->
					</div>									
					



				</cfif>
			</div>

			 <div id="divCardDGCIectAcumulado">
				<cfif count gt 0>

					<div class="row" style="width: 100%;">	
						<div class="col-12">
							<div class="card" >
								
								<cfoutput>
									<!-- card-body -->
									<div class="card-body shadow" style="border: 2px solid ##34a2b7">
									   
										<div id="divDGCI_mes_ano"><h4 style="text-align: center; margin-bottom:20px">DGCI ECT #arguments.ano# <span style="fontsize:12px"></span></h5></div>
										<div id="divResultadoDGCI" class="col-md-8 col-sm-8 col-12 mx-auto">
											<div class="info-box bg-info">
											     <div class="ribbon-wrapper ribbon-xl"  >
													<div class="ribbon" id="ribbon" data-value="#DGCIanoEmRelacaoAmetaSemReplace#"></div>
												</div>
												<span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

												<div class="info-box-content">
													<span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:30px"><strong>DGCI = #Replace(NumberFormat(DGCIano,0.0),'.',',')#%</strong></font></font><span style="font-size:12px;position: relative;left:-194px;top:13px">Desempenho Geral de Controle Interno</span></span>
													<span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong> #Replace(DGCIanoEmRelacaoAmeta,'.',',')#%</strong></font></font><span style="font-size:10px;"> em relação a meta = (DGCI / Meta) * 100 = (#Replace(NumberFormat(DGCIano,0.0),'.',',')# / #Replace(NumberFormat(DGCImetaAno,0.0),'.',',')#) * 100</span></span>

													<div class="progress">
														<div class="progress-bar" style="width: #DGCIanoEmRelacaoAmetaSemReplace#%"></div>
													</div>
													<span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
														<span style="font-size:14px"><strong>DGCI #arguments.ano#</strong> =  <span style="font-size:16px"><strong>#Replace(NumberFormat(DGCIano,0.0),',','.')#%</strong></span><span> (média dos resultados mensais do DGCI)</span><br>
														<span style="font-size:14px"><strong>Meta</strong> = <span style="font-size:16px"><strong>#Replace(NumberFormat(DGCImetaAno,0.0),',','.')#%</strong></span></span><span> (média das metas mensais)</span><br>
													
													</font></font></span>
												</div>
												<!-- /.info-box-content -->
											</div>
										
										
										</div>	
										<div class="col-12">
											<!--
											<div class="row " style="display: flex; justify-content: center;margin-top:-5px;margin-bottom:5px">
												<i class="fa-solid fa-angles-up" style="font-size:30px;"></i>
											</div>-->

											<div class="row " style="display: flex; justify-content: center;">
												
												<div id="divResultadoPRCI" class="col-md-5 col-sm-5 col-12 "></div>
												<div id="divResultadoSLNC" class="col-md-5 col-sm-5 col-12 "></div>
											</div>
										</div>
										
									</div>
									<!-- /.card-body -->
								</cfoutput>
							</div>
							<!-- /.card -->
						</div>
						<!-- /.col -->
					</div>									
					



				</cfif>
			</div>
									

		</cfif>

		<cfif resultadoDGCIporOrgResp.recordcount neq 0 >	
	
			<div id="divDGCIporGerencia" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							<div class="table-responsive ">
								<table id="tabDGCIporGerencia" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead >
										<tr style="font-size:14px;text-align: center;">
											
											<th >Órgão</th>
											<th >Órgão Subordinador</th>
											<th >PRCI <br><cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th >SLNC <br><cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;">
												DGCI 
												<cfoutput>
													#monthAsString(arguments.mes)#<br>
													<span style="font-size: 9px">(PRCI * #rsPRCIpeso.pc_indPeso_peso#) + (SLNC * #rsSLNCpeso.pc_indPeso_peso#)</span>
												</cfoutput>
											</th>
											<th >Meta</th>
											<th >Resultado <cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th class="bg-gradient-warning" style="text-align: center;border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;">DGCI<br>Acumulado</th>
											<th >Resultado Acumulado</th>
											<th >Result. % em Relação<br>à Meta Mensal</th>
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="resultadoDGCIporOrgResp" >
											<cfoutput>	
												<cfquery name="resultadoPRCIporGerencia"   dbtype="query">
													SELECT pc_indOrgao_resultadoMes as prci FROM resultadoPorOrgao	
													WHERE pc_indOrgao_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoDGCIporOrgResp.pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
													AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="0" cfsqltype="cf_sql_integer">
													
												</cfquery>	

												<cfquery name="resultadoSLNCporGerencia"   dbtype="query">
													SELECT pc_indOrgao_resultadoMes as slnc FROM resultadoPorOrgao	
													WHERE pc_indOrgao_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mcuOrgao = <cfqueryparam value="#resultadoDGCIporOrgResp.pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
													AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
													AND pc_indOrgao_paraOrgaoSubordinador = <cfqueryparam value="0" cfsqltype="cf_sql_integer">
													
												</cfquery>	


												<cfquery name="metaPRCIporOrgao" datasource="#application.dsn_processos#">
													SELECT pc_indMeta_meta AS metaMes FROM pc_indicadores_meta 
													WHERE pc_indMeta_mcuOrgao = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
														AND pc_indMeta_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
														AND pc_indMeta_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
														AND pc_indMeta_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
														
												</cfquery>

												<cfif metaPRCIporOrgao.recordcount eq 0 >
													<cfset metaPRCI = 0>
												<cfelse>
													<cfset metaPRCI = metaPRCIporOrgao.metaMes>
												</cfif>

												<cfquery name="metaSLNCporOrgao" datasource="#application.dsn_processos#">
													SELECT pc_indMeta_meta AS metaMes FROM pc_indicadores_meta 
													WHERE pc_indMeta_mcuOrgao = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
														AND pc_indMeta_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
														AND pc_indMeta_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
														AND pc_indMeta_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
												</cfquery>

												<cfif metaSLNCporOrgao.recordcount eq 0 >
													<cfset metaSLNC = 0>
												<cfelse>
													<cfset metaSLNC = metaSLNCporOrgao.metaMes>
												</cfif>
												

												
												<cfset metaDGCI = (metaPRCI * rsPRCIpeso.pc_indPeso_peso) + (metaSLNC * rsSLNCpeso.pc_indPeso_peso)>
												
											
											    <cfset metaMes = #NumberFormat(0, '0.0')#>	

												
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >

												    
													<td style="text-align: left;">#siglaOrgao# (#pc_indOrgao_mcuOrgao#)</td>
													<td style="text-align: left;">#siglaOrgaoSubordinador# (#pc_indOrgao_mcuOrgaoSubordinador#)</td>
													<cfif resultadoPRCIporGerencia.prci neq ''>
														<td >#NumberFormat(ROUND(resultadoPRCIporGerencia.prci*10)/10,0.0)#</td>
													<cfelse>
														<td style="color:red">sem dados</td>
													</cfif>
													<cfif resultadoSLNCporGerencia.slnc neq ''>
														<td >#NumberFormat(ROUND(resultadoSLNCporGerencia.slnc*10)/10,0.0)#</td>
													<cfelse>
														<td style="color:red">sem dados</td>
													</cfif>
													
													<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(pc_indOrgao_resultadoMes*10)/10,0.0)#</strong></td>

													<cfif metaDGCI eq ''>
														<td>#NumberFormat(metaMes,0.0)#</td>
													<cfelse>
														<cfset metaMes = ROUND(metaDGCI*10)/10>
														<td>#NumberFormat(metaMes,0.0)#</td>
													</cfif>
							
													<cfif metaMes neq 0>
														<cfset resultMesEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoMes*10)/10 / metaMes)*100*10)/10>
														<cfset resultAcumuladoEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoAcumulado*10)/10 / metaMes)*100*10)/10>
													<cfelse>
														<cfset resultMesEmRelacaoMeta = ROUND(0*10)/10>	
														<cfset resultAcumuladoEmRelacaoMeta = ROUND(0*10)/10>
													</cfif>
													
													<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>

													<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(pc_indOrgao_resultadoAcumulado*10)/10,0.0)#</strong></td>

													<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>


													<td>#NumberFormat(resultMesEmRelacaoMeta,0.0)#</td>

												</tr>
											</cfoutput>	
										</cfloop>	
									</tbody>

								</table>
							</div>							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->

		</cfif>

		<cfif resultadoPRCIporOrgaoSubordinador.recordcount neq 0 >	
			<div id="divPRCIporOrgaoSubordinador" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							<div class="table-responsive ">
								<table id="tabPRCIporOrgaoSubordinador" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead>
										<tr style="font-size:14px;text-align: center;">
											<th >Órgão</th>
											<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;">PRCI <cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th >Meta</th>
											<th >Resultado <cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;">PRCI Acumulado</th>
											<th >Resultado Acumulado</th>
											<th >Result. % em Relação<br>à Meta Mensal</th>
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="resultadoPRCIporOrgaoSubordinador" >
											<cfoutput>	
												

													<cfquery name="metaPRCIporOrgao" datasource="#application.dsn_processos#">
														SELECT  AVG(meta) AS metaMes from (
															SELECT DISTINCT pc_indOrgao_ano, pc_indMeta_mes, pc_indOrgao_mcuOrgaoSubordinador, pc_indMeta_mcuOrgao, pc_indicadores_meta.pc_indMeta_meta as meta from pc_indicadores_porOrgao
															INNER JOIN pc_indicadores_meta ON pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao = pc_indicadores_meta.pc_indMeta_mcuOrgao 
																and pc_indicadores_porOrgao.pc_indOrgao_numIndicador = pc_indicadores_meta.pc_indMeta_numIndicador and pc_indicadores_porOrgao.pc_indOrgao_ano = pc_indicadores_meta.pc_indMeta_ano and pc_indicadores_porOrgao.pc_indOrgao_mes = pc_indicadores_meta.pc_indMeta_mes
																	WHERE pc_indOrgao_mcuOrgaoSubordinador = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indOrgao_numIndicador = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
																
														) as metaPRCI
														
													</cfquery>
		
												    <cfif metaPRCIporOrgao.metaMes eq ''>
														<cfset metaMes = NumberFormat(0,0.0)>
													<cfelse>
														<cfset metaMes = ROUND(metaPRCIporOrgao.metaMes*10)/10>	
													</cfif>

													<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
														<td style="text-align: left;">#siglaOrgao# (#pc_indOrgao_mcuOrgao#)</td>
														<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(pc_indOrgao_resultadoMes*10)/10,0.0)#</strong></td>
														
														<cfif pc_indOrgao_mcuOrgao eq pc_indOrgao_mcuOrgaoSubordinador AND pc_indOrgao_paraOrgaoSubordinador eq 0>
															<cfset metaMes = 0>	
															<td>#NumberFormat(metaMes,0.0)#</td>
														<cfelse>
															<cfif metaPRCIporOrgao.metaMes eq ''>
																<td>#NumberFormat(metaMes,0.0)#</td>
															<cfelse>
																<cfset metaMes = ROUND(metaPRCIporOrgao.metaMes*10)/10>
																<td>#NumberFormat(metaMes,0.0)#</td>
															</cfif>
														</cfif>

														<cfif metaMes neq 0>
															<cfset resultMesEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoMes*10)/10 / metaMes)*100*10)/10>
															<cfset resultAcumuladoEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoAcumulado*10)/10 / metaMes)*100*10)/10>
														<cfelse>
															<cfset resultMesEmRelacaoMeta = ROUND(0*10)/10>	
															<cfset resultAcumuladoEmRelacaoMeta = ROUND(0*10)/10>
														</cfif>

														<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>

														<td style="border-left:1px solid ##000;border-right:1px solid ##000">#NumberFormat(ROUND(pc_indOrgao_resultadoAcumulado*10)/10,0.0)#</td>

														<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>


														<td>#NumberFormat(resultMesEmRelacaoMeta,0.0)#</td>

													</tr>
												
											</cfoutput>
										</cfloop>	
									</tbody>

								</table>
							</div>							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
		</cfif>

		<cfif resultadoSLNCporOrgaoSubordinador.recordcount neq 0 >	
			<div id="divSLNCporOrgaoSubordinador" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
							
							<div class="table-responsive ">
								<table id="tabSLNCporOrgaoSubordinador" class="table table-bordered table-striped text-nowrap " style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead>
										<tr style="font-size:14px;text-align: center;">
											<th >Órgão</th>
											<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;">SLNC <cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th >Meta</th>
											<th >Resultado <cfoutput>#monthAsString(arguments.mes)#</cfoutput></th>
											<th class="bg-gradient-warning" style="border-left:1px solid #000;border-right:1px solid #000;border-top:1px solid #000;text-align: center;">SLNC Acumulado</th>
											<th >Resultado Acumulado</th>
											<th >Result. % em Relação<br>à Meta Mensal</th>
										</tr>
									</thead>
									
									<tbody>
										<cfloop query="resultadoSLNCporOrgaoSubordinador" >
											<cfoutput>	
											
												<cfquery name="metaSLNCporOrgao" datasource="#application.dsn_processos#">
														SELECT  AVG(meta) AS metaMes from (
															SELECT DISTINCT pc_indOrgao_ano, pc_indMeta_mes, pc_indOrgao_mcuOrgaoSubordinador, pc_indMeta_mcuOrgao, pc_indicadores_meta.pc_indMeta_meta as meta from pc_indicadores_porOrgao
															INNER JOIN pc_indicadores_meta ON pc_indicadores_porOrgao.pc_indOrgao_mcuOrgao = pc_indicadores_meta.pc_indMeta_mcuOrgao 
																	and pc_indicadores_porOrgao.pc_indOrgao_numIndicador = pc_indicadores_meta.pc_indMeta_numIndicador and pc_indicadores_porOrgao.pc_indOrgao_ano = pc_indicadores_meta.pc_indMeta_ano and pc_indicadores_porOrgao.pc_indOrgao_mes = pc_indicadores_meta.pc_indMeta_mes
															WHERE pc_indOrgao_mcuOrgaoSubordinador = <cfqueryparam value="#pc_indOrgao_mcuOrgao#" cfsqltype="cf_sql_varchar">
																AND pc_indOrgao_numIndicador = <cfqueryparam value="2" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_ano = <cfqueryparam value="#pc_indOrgao_ano#" cfsqltype="cf_sql_integer">
																AND pc_indOrgao_mes = <cfqueryparam value="#pc_indOrgao_mes#" cfsqltype="cf_sql_integer">
														) as subConsultaMetaPRCI
												</cfquery>

												<cfif metaSLNCporOrgao.metaMes eq ''>
													<cfset metaMes = NumberFormat(0,0.0)>
												<cfelse>
											    	<cfset metaMes = ROUND(metaSLNCporOrgao.metaMes*10)/10>
												</cfif>

												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td style="text-align: left;">#siglaOrgao# (#pc_indOrgao_mcuOrgao#)</td>
													<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(pc_indOrgao_resultadoMes*10)/10,0.0)#</strong></td>

													<cfif pc_indOrgao_mcuOrgao eq pc_indOrgao_mcuOrgaoSubordinador AND pc_indOrgao_paraOrgaoSubordinador eq 0>
														<cfset metaMes = 0>	
														<td>#NumberFormat(metaMes,0.0)#</td>
													<cfelse>
														<cfif metaSLNCporOrgao.metaMes eq ''>
															<td>#NumberFormat(metaMes,0.0)#</td>
														<cfelse>
															<cfset metaMes = ROUND(metaSLNCporOrgao.metaMes*10)/10>
															<td>#NumberFormat(metaMes,0.0)#</td>
														</cfif>
													</cfif>

													<cfif metaMes neq 0>
														<cfset resultMesEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoMes*10)/10 / metaMes)*100*10)/10>
														<cfset resultAcumuladoEmRelacaoMeta = ROUND((ROUND(pc_indOrgao_resultadoAcumulado*10)/10 / metaMes)*100*10)/10>
													<cfelse>
														<cfset resultMesEmRelacaoMeta = ROUND(0*10)/10>	
														<cfset resultAcumuladoEmRelacaoMeta = ROUND(0*10)/10>
													</cfif>
													
													<td ><span class="tdResult statusOrientacoes" data-value="#resultMesEmRelacaoMeta#"></span></td>

													<td style="border-left:1px solid ##000;border-right:1px solid ##000"><strong>#NumberFormat(ROUND(pc_indOrgao_resultadoAcumulado*10)/10,0.0)#</strong></td>

													<td ><span class="tdResult statusOrientacoes" data-value="#resultAcumuladoEmRelacaoMeta#"></span></td>

													<td>#NumberFormat(resultMesEmRelacaoMeta,0.0)#</td>


												</tr>
											</cfoutput>
										</cfloop>	
									</tbody>

								</table>
							</div>							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
		</cfif>
	
		<cfif resultadoPRCIdetalhe.recordcount neq 0 >	
			<div id="divDetalhePRCI" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
						
							<div class="table-responsive">
								<table id="tabPRCIdetalhe" class="table table-bordered table-striped text-nowrap" style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead >
										<tr style="font-size:14px">
											<th style="width: 10px">Posic ID</th>
											<th style="width: 10px">SE/CS</th>
											<th style="width: 10px">Órgão Responsável</th>
											<th style="width: 10px">Processo SNCI</th>
											<th style="width: 10px">Órgão Avaliado</th>
											<th style="width: 10px">Item</th>
											<th style="width: 10px">Orientação</th>
											<th style="width: 10px">Data Prevista</th>
											<th style="width: 10px">Data Status</th>
											<th style="width: 10px">Status</th>
											<th style="width: 10px">Data Ref.</th>
											<th style="width: 10px">Prazo</th>

										</tr>
									</thead>
									
									<tbody>
										<cfloop query="resultadoPRCIdetalhe" >
										
											<cfoutput>					
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#pc_indDados_numPosic#</td>
													<td>#siglaOrgaoSubordinador# (#mcuOrgaoSubordinador#)</td>
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td>#numProcessoSNCI#</td>
													<td>#siglaOrgaoAvaliado# (#mcuOrgaoAvaliado#)</td>
													<td >#item#</td>
													<td>#orientacao#</td>
													<cfif dataPrevista eq '1900-01-01' or dataPrevista eq ''>
														<td>NÃO INF.</td>
													<cfelse>
														<td>#dateFormat(dataPrevista, 'dd/mm/yyyy')#</td>
													</cfif>
													<td>#dateFormat(dataPosicao, 'dd/mm/yyyy')#</td>
													<td>#descricaoOrientacaoStatus#</td>
													<td>#dateFormat(dataRef, 'dd/mm/yyyy')#</td>
													<td>#prazo#</td>
												</tr>
											</cfoutput>
										</cfloop>	
									</tbody>

								</table>
							</div>							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
        </cfif>

		<cfif resultadoSLNCdetalhe.recordcount neq 0 >	
			<div id="divDetalheSLNC" class="row" >
							
				<div class="col-12">
					<div class="card" >
						
						<!-- card-body -->
						<div class="card-body" >
														
						
							<div class="table-responsive">
								<table id="tabSLNCdetalhe" class="table table-bordered table-striped text-nowrap" style="border-left: 1px solid #dee2e6;border-bottom: 1px solid #dee2e6;">
									
									<thead>
										<tr style="font-size:14px">
											<th style="width: 10px">Posic ID</th>
											<th style="width: 10px">SE/CS</th>
											<th style="width: 10px">Órgão Responsável</th>
											<th style="width: 10px">Processo SNCI</th>
											<th style="width: 10px">Órgão Avaliado</th>
											<th style="width: 10px">Item</th>
											<th style="width: 10px">Orientação</th>
											<th style="width: 10px">Data Prevista</th>
											<th style="width: 10px">Data Status</th>
											<th style="width: 10px">Status</th>
											<th style="width: 10px">Data Ref.</th>

										</tr>
									</thead>
									
									<tbody>
										<cfloop query="resultadoSLNCdetalhe" >
										
											<cfoutput>					
												<tr style="font-size:12px;cursor:auto;z-index:2;text-align: center;"  >
													<td>#pc_indDados_numPosic#</td>
													<td>#siglaOrgaoSubordinador# (#mcuOrgaoSubordinador#)</td>
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td>#numProcessoSNCI#</td>
													<td>#siglaOrgaoAvaliado# (#mcuOrgaoAvaliado#)</td>
													<td >#item#</td>
													<td>#orientacao#</td>
													<cfif dataPrevista eq '1900-01-01' or dataPrevista eq ''>
														<td>NÃO INF.</td>
													<cfelse>
														<td>#dateFormat(dataPrevista, 'dd/mm/yyyy')#</td>
													</cfif>
													<td>#dateFormat(dataPosicao, 'dd/mm/yyyy')#</td>

													<td>#descricaoOrientacaoStatus#</td>

													<td>#dateFormat(dataRef, 'dd/mm/yyyy')#</td>
												</tr>
											</cfoutput>
										</cfloop>	
									</tbody>

								</table>
							</div>							
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
        </cfif>

	

		<script language="JavaScript">

		    // Define a função para aplicar o estilo apenas nas células com a classe 'tdResult'
			function aplicarEstiloNasTDsComClasseTdResult() {
				// Para cada célula com a classe 'tdResult' na tabela
				$('.tdResult').each(function() {
					updateTDresultIndicadores($(this));
				});
			}
		   
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	//data atual para nomear o arquivo excel

			$(function () {
			
				var tituloExcel_DGCIporMes ="SNCI_Consulta_DGCI_por_mes_";
				const tabIndicadoresMes = $('#tabIndicadoresMes').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					ordering: false, // Desativa a classificação
					lengthChange: false, // Desabilita a opção de seleção da quantidade de páginas
					paging: false, // Remove a paginação
					info: false, // Remove a exibição da quantidade de registros
					searching: false, // Remove o campo de busca
					dom: "<'row'<'col-sm-2'B>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_DGCIporMes + d,
							className: 'btExcel',
						}
					]
					
				})
				
				var tituloExcel_DGCIporOrgaoSubord ="SNCI_Consulta_DGCI_por_orgaoSubord_";
				const tabDGCIporOrgaoSubord = $('#tabDGCIporOrgaoSubord').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,//quantidade de registros por página
					lengthMenu: [
						[5, 10, 25, 50, -1],
						['5', '10', '25', '50', 'Todos']
					],
					dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
				    order: [[3, 'desc']],//classificar pela coluna DGCI em ordem decrescente
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_DGCIporOrgaoSubord + d,
							className: 'btExcel',
						}
					],
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}

					
				})

				var tituloExcel_DGCIporGerencia ="SNCI_Consulta_DGCI_porGerencia_";
				const tabDGCIporGerencia = $('#tabDGCIporGerencia').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,//quantidade de registros por página
					lengthMenu: [
						[5, 10, 25, 50, -1],
						['5', '10', '25', '50', 'Todos']
					],
					dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
					order: [[4, 'desc']],//classificar pela coluna DGCI em ordem decrescente
					//dom: "<'row'<'col-sm-2'B><'col-sm-4'p><'col-sm-12 text-left'i>>" ,
				
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_DGCIporGerencia + d,
							className: 'btExcel',
						}
					],
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}
				})

				var tituloExcel_PRCIporOrgaoSubordinador ="SNCI_Consulta_PRCI_porOrgaoSubordinador_";
				const tabPRCIporOrgaoSubordinador = $('#tabPRCIporOrgaoSubordinador').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,//quantidade de registros por página
					lengthMenu: [
						[5, 10, 25, 50, -1],
						['5', '10', '25', '50', 'Todos']
					],
					dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
					order: [[2, 'desc']],//classificar pela coluna PRCI em ordem decrescente
					//dom:   "<'row'<'col-sm-2'B><'col-sm-4'p><'col-sm-12 text-left'i>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_PRCIporOrgaoSubordinador + d,
							className: 'btExcel',
						}
					],
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}
				})

				var tituloExcel_SLNCporOrgaoSubordinador="SNCI_Consulta_SLNC_porOrgaoSubordinador_";
				const tabSLNCporOrgaoSubordinador= $('#tabSLNCporOrgaoSubordinador').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,//quantidade de registros por página
					lengthMenu: [
						[5, 10, 25, 50, -1],
						['5', '10', '25', '50', 'Todos']
					],
					dom: "<'row'<'col-sm-2'B><'col-sm-5 text-left' p><'col-sm-5 text-left'i>><'row'<'col-sm-2 text-left'l>>" ,
					order: [[2, 'desc']],//classificar pela coluna SLNC em ordem decrescente
					//dom:   "<'row'<'col-sm-2'B><'col-sm-4'p><'col-sm-12 text-left'i>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_SLNCporOrgaoSubordinador+ d,
							className: 'btExcel',
						}
					],
					drawCallback: function (settings) {
						aplicarEstiloNasTDsComClasseTdResult();
					}

				})

				var tituloExcel_PRCI ="SNCI_Consulta_PRCI_detalhamento_";

				const tabPRCIdetalhamento = $('#tabPRCIdetalhe').DataTable( {
				    destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					
					dom: "<'row'<'col-sm-3'B><'col-sm-4 text-center' p><'col-sm-4 text-right'i>>" ,
					order: [[1, 'asc'], [2, 'asc']], // Ordena a segunda e a terceira coluna em ordem crescente
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_PRCI + d,
							className: 'btExcel',
						}

					]
					

				})

				var tituloExcel_SLNC ="SNCI_Consulta_SLNC_detalhamento_";

				const tabSLNCdetalhamento = $('#tabSLNCdetalhe').DataTable( {
					destroy: true, // Destruir a tabela antes de recriá-la
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					
					dom: "<'row'<'col-sm-3'B><'col-sm-4 text-center' p><'col-sm-4 text-right'i>>"  ,
					order: [[1, 'asc'], [2, 'asc']], // Ordena a segunda e a terceira coluna em ordem crescente
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="padding:10px"></i>',
							title : tituloExcel_SLNC + d,
							className: 'btExcel',
						}

					]
					

				})
			
			});

			


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				
				$('.ribbon').each(function() {
					updateRibbon($(this));
				});
				

				
					
			});



		</script>

	</cffunction>


	<cffunction name="criarCardIndicador" access="public" returntype="string" hint="cria os cards com as informações dos resultados dos indicadores">
    	<cfargument name="tipoDeCard" type="string" required="no" default="bg-info">
		<cfargument name="siglaIndicador" type="string" required="yes">
        <cfargument name="percentualIndicadorFormatado" type="string" required="yes">
        <cfargument name="resultadoEmRelacaoMeta" type="numeric" required="yes">
		<cfargument name="resultadoEmRelacaoMetaFormatado" type="string" required="yes">
        <cfargument name="infoRodape" type="string" required="yes">

        <cfset var infoBox = "">
        
        <cfoutput>
            <cfsavecontent variable="infoBox">
                <div class="info-box #tipoDeCard#">
                    <div class="ribbon-wrapper ribbon-xl">
                        
                        <div class="ribbon" id="ribbon" data-value="#resultadoEmRelacaoMeta#"></div>
                       
                    </div>
                    <span class="info-box-icon"><i class="fas fa-chart-line" style="font-size:45px"></i></span>

                    <div class="info-box-content">
                        <span class="info-box-text"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;font-size:22px">#siglaIndicador# = #percentualIndicadorFormatado#%</font></font></span><span style="font-size:12px;position:absolute; top:36px">Atendimento ao Prazo de Resposta</span>
                        <span class="info-box-number"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;inherit;font-size:20px"><strong>#resultadoEmRelacaoMetaFormatado#%</strong></font></font><span style="font-size:10px;"> em relação a meta = (#siglaIndicador# / Meta) * 100</span></span>

                        <div class="progress" style="width:90%">
                            <div class="progress-bar" style="width: #resultadoEmRelacaoMeta#%"></div>
                        </div>
                        <span class="progress-description"><font style="vertical-align: inherit;"><font style="vertical-align: inherit;">
                            #infoRodape#
                        </font></font></span>
                    </div>
                </div>
            </cfsavecontent>
        </cfoutput>
        
        <cfreturn infoBox>
    </cffunction>

    





	



</cfcomponent>