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


	<cffunction name="consultaIndicadorPRCI"   access="remote" hint="gera a consulta para página de indicadores">
		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />

	
		<cfset dataInicial = createODBCDate(createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))>
		<cfset dataFinal = createODBCDate(dateAdd('s', -1, dateAdd('m', 1, createDateTime(arguments.ano, arguments.mes, 1, 0, 0, 0))))>
	

		<cfquery name="rs_Orientacao_agora" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
				orgaoDaAcao.pc_org_controle_interno as orgaoDaAcaoEdoControleInterno,
				pc_processos.pc_processo_id as numProcessoSNCI,
				pc_avaliacoes.pc_aval_numeracao as item,
				CONVERT(DATE, pc_aval_posic_datahora) as dataPosicao,
				pc_aval_posic_num_orientacao as orientacao,
				pc_aval_posic_dataPrevistaResp as dataPrevista,
				pc_aval_posic_status,
				CASE
					WHEN pc_aval_posic_dataPrevistaResp < GETDATE() THEN 'PENDENTE'
					ELSE pc_orientacao_status.pc_orientacao_status_descricao
				END AS OrientacaoStatus,

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
				AND pc_aval_posic_datahora < = <cfqueryparam value="#dataFinal#" cfsqltype="cf_sql_date">
					
		</cfquery>

		<cfquery name="rs_Orientacao_Respondida" datasource="#application.dsn_processos#" timeout="120">
			SELECT
				pc_aval_posic_id,
				orgaoAvaliado.pc_org_sigla as orgaoAvaliado,
				orgaoResp.pc_org_sigla as orgaoResp,
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

		<cfreturn #rs_Orientacao#>

	</cffunction>

	<cffunction name="tabPRCIDetalhe" access="remote" hint="outra função que utiliza tabIndicadores">
   		<cfargument name="ano" type="string" required="true" />
		<cfargument name="mes" type="string" required="true" />
		
    	<cfset var resultado = consultaIndicadorPRCI(ano=arguments.ano, mes=arguments.mes)>

      
		<cfset totalDP = 0 /> 
		<cfset totalFP = 0 /> 
		<cfset orgaos = {}> <!-- Define a variável orgaos como um objeto vazio -->
		<cfset dps = {}> <!-- Define a variável dps como um objeto vazio -->
		<cfset fps = {}> <!-- Define a variável fps como um objeto vazio -->

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
		</cfloop>

		
	

		<div class="row">
			<div id="filtroSpan" style="display: none;text-align:right;font-size:18px;position:absolute;top:123px;right:24px;"><span class="statusOrientacoes" style="background:#2581c8;color:#fff;">Atenção! Um filtro foi aplicado.</span><br><i class="fa fa-2x fa-hand-point-down" style="color:#2581c8;position:relative;top:8px;right:117px"></i></div>
						
			<div class="col-12">
				<div class="card" >
					
					<!-- card-body -->
					<div class="card-body" style="margin-bottom:80px">
						<cfif #resultado.recordcount# eq 0 >
							<h5 align="center">Nenhuma informação foi localizada para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
						<cfelse>
							<cfoutput><h5 style="color:##2581c8;text-align: center;">Cálculo do <strong>PRCI</strong> (Atendimento ao Prazo de Resposta): #monthAsString(arguments.mes)#/#arguments.ano# </h5></cfoutput>
						
						
							<table id="tabPRCIdetalhe" class="table table-bordered table-striped table-hover text-nowrap" >
								
								<thead style="background: #0083ca;color:#fff">
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
											<tr style="font-size:12px;cursor:pointer;z-index:2;text-align: center;"  >
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
									<cfset percentualDP = (totalDP / totalGeral) * 100 />
									<!--- Formata o percentualDP com duas casas decimais --->
    								<cfset percentualDPFormatado = NumberFormat(percentualDP, '0.0') />
									<div>
										<h4  style="color:##2581c8;"><strong>PRCI</strong>: #percentualDPFormatado#% <span style="font-size:14px">(PRCI = TIDP/TGI)</span></h4>
										<h6><strong>TIDP</strong> (Posicionamento dentro do prazo (DP))= #totalDP#</h6>
										<h6><strong>TGI</strong> (Total de Posicionamentos)= #totalGeral# <span style="font-size:12px">(Dentro do Prazo(DP) = #totalDP# + Fora do Prazo(FP) = #totalFP#)</span></h6>


										
									</div>
									
								</cfoutput>

							</table>

							<cfset totalOrgaosResp = StructCount(orgaos)> <!-- Conta a quantidade de orgaoResp -->
							
						    <cfif totalOrgaosResp gt 1>
								<table id="tabResumoPRCI" class="table table-bordered table-striped table-hover text-nowrap" style="width:500px; margin-top:30px">
									<cfoutput>
										<thead style="background: ##489b72;color:##fff;text-align: center;">
											<tr style="font-size:14px">
												<th colspan="4" style="padding:5px!important;">RESUMO (Classif. por Órgão mais ofensor)</th>
											</tr>
											<tr style="font-size:14px">
												<th style="padding:5px!important;">Órgão</th>
												<th style="padding:5px!important;">DP</th>
												<th style="padding:5px!important;">FP</th>
												<th style="padding:5px!important;">PRCI</th>
											</tr>
										</thead>
										<tbody>
											<!--- Ordena a estrutura dps por seus valores em ordem decrescente --->
											<cfset prcisOrdenado = StructSort(fps, "numeric", "desc")>
											<cfloop array="#prcisOrdenado#" index="orgao">
												<cfset percentualDP = (dps[orgao] / orgaos[orgao]) * 100>
												<cfset percentualDPFormatado = NumberFormat(percentualDP, '0.0')>

												<!--- Adiciona cada linha à tabela --->
												<tr style="font-size:12px;cursor:pointer;z-index:2;text-align: center;"  >
													<td>#orgao#</td>
													<td>#dps[orgao]#</td>
													<td>#fps[orgao]#</td>
													<td>#percentualDPFormatado#%</td>
												</tr>
											</cfloop>
										</tbody>
									</cfoutput>
								</table>
							</cfif>





							
						</cfif>
					</div>
					<!-- /.card-body -->
				</div>
				<!-- /.card -->
			</div>
		<!-- /.col -->
		</div>
		<!-- /.row -->

		<script language="JavaScript">
		   
				

			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	

			$(function () {
				// Ajustar a altura do elemento ".content-wrapper" para se estender até o final do timeline
			
				
				var tituloExcel ="SNCI_Consulta_PRCI_Detalamento_";
				var colunasMostrar = [1,2,8,10];


				const tabPRCIdetalhamento = $('#tabPRCIdetalhe').DataTable( {
				
					stateSave: false,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Permitir rolagem horizontal
        			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					dom: 
								"<'row'<'col-sm-4 dtsp-verticalContainer'<'dtsp-verticalPanes'P><'dtsp-dataTable'Bf>><'col-sm-8 text-left'p>>" +
								"<'col-sm-12 text-left'i>" +
								"<'row'<'col-sm-12'tr>>" ,
							
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
							title : tituloExcel + d,
							className: 'btExcel',
						},
						{// Botão abertura do ctrol-sidebar com os filtros
							text: '<i class="fas fa-filter fa-2x grow-icon" style="margin-right:30px" data-widget="control-sidebar"></i>',
							className: 'btFiltro',
						},

					],
					language: {
						searchPanes: {
							clearMessage: 'Retirar filtro',
							loadMessage: 'Carregando Painéis de Pesquisa...',
							showMessage: 'Mostrar painéis',
							collapseMessage: 'Recolher painéis',
							title: 'Filtros Ativos - %d',
							emptyMessage: '<em>Sem dados</em>',
               				emptyPanes: 'Sem painéis de filtragem relevantes para exibição',
							
						}
					},
					searchPanes: {
						cascadePanes: true, // Exibir apenas opções que combinam com os filtros anteriores
						columns: colunasMostrar,// Colunas que terão filtro
						threshold: 1,// Número mínimo de registros para exibir Painéis de Pesquisa
						layout: 'columns-1', //layout do filtro com uma coluna
						initCollapsed: true, // Colapsar Painéis de Pesquisa
					},
					initComplete: function () {// Função executada ao finalizar a inicialização do DataTable
						initializeSearchPanesAndSidebar(this)//inicializa o searchPanes dentro do controlSidebar
					}

				})


			
			});


			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
				
			});


	</cffunction>





	



</cfcomponent>