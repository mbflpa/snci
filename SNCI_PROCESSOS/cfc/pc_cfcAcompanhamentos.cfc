<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	
	
   	<cffunction name="tabAcompanhamento" returntype="any" access="remote" hint="Criar a tabela das orientacoes pendentes e envia para a página pcAcompanhamento.cfm">
		
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_descricao as descOrgAvaliado
						, pc_usuarios.pc_usu_nome
						, pc_usuCoodNacional.pc_usu_nome as nome_coordenadorNacional
						, pc_usuCoodNacional.pc_usu_matricula as matricula_coordenadorNacional, pc_avaliacoes.*, pc_avaliacao_orientacoes.*
						, pc_orgaos_2.pc_org_se_sigla as seOrgResp, pc_orgaos_2.pc_org_sigla as siglaOrgResp , pc_orgaos_2.pc_org_mcu as mcuOrgResp 
						, pc_orientacao_status.*
						, pc_processos.pc_num_orgao_origem as orgaoOrigem
						, pc_orgaos_4.pc_org_sigla as orgaoAvaliado
						, pc_orgaos_5.pc_org_sigla as orgaoOrigemSigla
						, CONCAT(
						'Macroprocesso:<strong> ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,'</strong>',
						' -> N1:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,'</strong>',
						' -> N2:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,'</strong>',
						' -> N3:<strong> ', pc_avaliacao_tipos.pc_aval_tipo_processoN3,'</strong>', '.'
						) as tipoProcesso


			FROM        pc_processos 
						LEFT JOIN pc_orgaos ON  pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
						LEFT JOIN pc_orgaos AS pc_orgaos_1 ON pc_orgaos_1.pc_org_mcu = pc_processos.pc_num_orgao_origem
						LEFT JOIN pc_avaliacoes on pc_aval_processo = pc_processo_id
						LEFT JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id
						LEFT JOIN pc_orgaos AS pc_orgaos_2 ON pc_orgaos_2.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
						LEFT JOIN pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
						LEFT JOIN pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
						LEFT JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
						LEFT JOIN pc_orgaos AS pc_orgaos_4 ON pc_orgaos_4.pc_org_mcu = pc_num_orgao_avaliado
						LEFT JOIN pc_orgaos AS pc_orgaos_5 ON pc_orgaos_5.pc_org_mcu = pc_num_orgao_origem
						LEFT JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id

			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
			        <!---Processos em acompanhamento ou bloqueados--->
					WHERE pc_num_status in(4,6)

					<!---Se o perfil do usuário não for 11 - CI - MASTER ACOMPANHAMENTO (Gestor Nível 4) ou 3 -DESENVOLVEDOR--->
					<cfif application.rsUsuarioParametros.pc_usu_perfil neq 11 and application.rsUsuarioParametros.pc_usu_perfil neq 3>
						and (pc_aval_orientacao_status in (1,14) or (pc_aval_orientacao_status = 3 and pc_aval_orientacao_id in (
							SELECT 	pc_aval_posic_num_orientacao FROM pc_avaliacao_posicionamentos
							INNER JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_id = pc_aval_posic_num_orientacao
							WHERE pc_aval_posic_status=3 and pc_aval_orientacao_status = 3
							GROUP BY pc_aval_posic_num_orientacao
							HAVING Count(pc_aval_posic_status)<2)) and pc_modalidade <> 'A')  
					<cfelse>
						and (pc_aval_orientacao_status = 3 and (pc_aval_orientacao_id in (
							SELECT 	pc_aval_posic_num_orientacao FROM pc_avaliacao_posicionamentos
							INNER JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_id = pc_aval_posic_num_orientacao
							WHERE pc_aval_posic_status=3 and pc_aval_orientacao_status = 3
							GROUP BY pc_aval_posic_num_orientacao
							HAVING Count(pc_aval_posic_status)>=2) OR pc_modalidade = 'A'))  
					</cfif>
					<!---Se o perfil do usuário  for 8 - CI - GESTOR MASTER (EXECUÇÃO) e o órgão de lotação não for origem do processo, não aparecerá nenhum processo para acompanhamento--->
					<cfif application.rsUsuarioParametros.pc_usu_perfil eq 8  and '#application.rsUsuarioParametros.pc_org_status#' neq 'O'>
						and pc_num_status = 0	
					</cfif>

					<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (Gestor Nível 4) --->
					<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
						and pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' OR (pc_aval_orientacao_status in (13) and pc_orgaos_2.pc_org_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#')
					</cfif>
					<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil for 11 - CI - MASTER ACOMPANHAMENTO (Gestor Nível 4)--->
					<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and ListFind("11",#application.rsUsuarioParametros.pc_usu_perfil#) >
							OR (pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' and pc_aval_orientacao_status in (1,3,14)) OR (pc_aval_orientacao_status in (13) and pc_orgaos_2.pc_org_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#')
					</cfif>
					<!---Se a lotação do usuario não for um orgao origem de processos e não estiver desativado(status 'AD) e o perfil for 4 - 'AVALIADOR') --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 and '#application.rsUsuarioParametros.pc_org_status#' neq 'D'>
						and pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
					</cfif>
					<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1) - Execução' ou 14 - 'CI - REGIONAL - SCIA - Acompanhamento', com origem na GCOP--->
					<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) and '#application.rsUsuarioParametros.pc_org_status#' neq 'D'>
							and (pc_orgaos.pc_org_se = 	'#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)) and pc_processos.pc_num_orgao_origem IN('00436698','00436697','00438080')
					</cfif>
					
					


				
			<cfelse>
				WHERE pc_aval_orientacao_status in (2,4,5,16) and pc_aval_orientacao_mcu_orgaoResp = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
			</cfif>
				
			ORDER BY 	pc_processo_id, pc_aval_numeracao
		</cfquery>	

		<div class="row">
			
			<div class="col-12">
				<div class="card"  style="margin-bottom:50px">
				    
					<!-- /.card-header -->
					<div class="card-body" >
						<cfif #rsProcTab.recordcount# eq 0 >
							<h5 align="center">Nenhuma Orientação para acompanhamento foi localizada para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
						<cfelse>
						
							<div id="filtroSpan" style="display: none;text-align:right;font-size:18px;position:absolute;top:-54px;right:24px;"><span class="statusOrientacoes" style="background:#008000;color:#fff;">Atenção! Um filtro foi aplicado.</span><br><i class="fa fa-2x fa-hand-point-down" style="color:#008000;position:relative;top:8px;right:117px"></i></div>
			
							<table id="tabProcessos" class="table table-bordered table-striped table-hover text-nowrap">
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:14px">
									   
									    <cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11>
											<th id="colunaEmAnalise" style="text-align: center!important;width: 20px!important;">Colocar<br>em análise</th>
										</cfif>
										<th id="colunaStatus" style="width: 30px!important;">Status:</th>
										<th style="text-align: center!important;width: 20px!important;">N° Processo<br>SNCI</th>
										<th >N° Item:</th>
										<th style="text-align: center!important;width: 20px!important;">ID da<br>Orientação</th>
										<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N' >
											<th style="text-align: center!important;width: 20px!important;">Data Prevista<br>p/ Resposta</th>
										</cfif>
										<th>Órgão Responsável: </th>
										<th >SE/CS:</th>
										<th >N° SEI: </th>
										<th style="text-align: center!important;width: 20px!important;">N° Relatório<br>SEI</th>
										<th >Tipo de Avaliação:</th>	
										<th >Data Hora Status: </th>
										<th >Órgão Origem: </th>
										<th >Órgão Avaliado: </th>

										<th style="display:none;">ID</th>
										<th style="display:none;">ID Orientação</th>
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsProcTab" >
										<cfoutput>					
											<tr style="font-size:12px;cursor:pointer;z-index:2;"  >
											        
													<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11>
														<td align="center" >
															<cfif #pc_aval_orientacao_status# eq 2 or #pc_aval_orientacao_status# eq 3 or #pc_aval_orientacao_status# eq 4 or #pc_aval_orientacao_status# eq 5 or (#pc_aval_orientacao_status# eq 13 && '#orgaoOrigem#' neq '#mcuOrgResp#')>
																<i onclick="javascript:colocarEmAnalise('#pc_processo_id#',#pc_aval_id#,#pc_aval_orientacao_id#,'#orgaoOrigem#','#orgaoOrigemSigla#','#mcuOrgResp#',#pc_aval_orientacao_status#)"class="fas fa-file-medical-alt grow-icon clickable-icon" style="color:##0083ca;font-size:20px;margin-right:10px;z-index:10000"> </i>
															</cfif>
														</td>
													</cfif>
													<cfif #pc_aval_orientacao_dataPrevistaResp# neq '' and DATEFORMAT(#pc_aval_orientacao_dataPrevistaResp#,"yyyy-mm-dd")  lt DATEFORMAT(Now(),"yyyy-mm-dd") and (#pc_aval_orientacao_status# eq 4 or #pc_aval_orientacao_status# eq 5)>
														<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
															<td align="center"><span class="statusOrientacoes" style="background:##FFA500;color:##fff;" >PENDENTE</span></td>
														<cfelse>
															<td align="center"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;" >PENDENTE</span></td>
														</cfif>
													<cfelseif #pc_aval_orientacao_status# eq 3>
														<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
															<td align="center"><span  class="statusOrientacoes" style="background:##FFA500;color:##fff;" >#pc_orientacao_status_descricao#</span></td>
														<cfelse>
															<td align="center"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;" >#pc_orientacao_status_descricao#</span></td>
														</cfif>
											
													<cfelse>
														<td  align="center"><span class="statusOrientacoes" style="#pc_orientacao_status_card_style_header#;"  >#pc_orientacao_status_descricao#</span></td>
													</cfif>
													<td align="center">#pc_processo_id#</td>
													<td align="center">#pc_aval_numeracao#</td>	
													<td align="center">#pc_aval_orientacao_id#</td>	
													
													<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N' >
														<cfif ListFind("4,5,16", #pc_aval_orientacao_status#)>
															<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,'DD-MM-YYYY') >
															<td align="center">#dataPrev#</td>
														<cfelse>
															<td></td>
														</cfif>
													</cfif>
													
													
													<cfif pc_aval_orientacao_distribuido eq 1>
														<td>#siglaOrgResp# (#mcuOrgResp#)</td>
													<cfelse>
														<td>#siglaOrgResp# (#mcuOrgResp#)</td>
													</cfif>
													<td>#seOrgResp#</td>
													

													<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
													<td align="center">#sei#</td>
													<td align="center">#pc_num_rel_sei#</td>
													
													<cfif pc_num_avaliacao_tipo neq 445 and pc_num_avaliacao_tipo neq 2>
													    <cfif pc_aval_tipo_descricao neq ''>
															<td>#pc_aval_tipo_descricao#</td>
														<cfelse>
														    <td>#tipoProcesso#</td>
														</cfif>
													<cfelse>
														<td>#pc_aval_tipo_nao_aplica_descricao#</td>
													</cfif>
													<td>#DateFormat(pc_aval_orientacao_status_datahora,"dd/mm/yyyy")# - #TimeFormat(pc_aval_orientacao_status_datahora,"HH:mm")#</td>	
													
													<td class="group">#orgaoOrigemSigla#</td>	
													<td class="group">#orgaoAvaliado#</td>	
													
													<td id="pcAvalId" style="display:none;">#pc_aval_id#</td>
													<td id="pcAvalOrientacaoId" style="display:none;">#pc_aval_orientacao_id#</td>
											</tr>
										</cfoutput>
									</cfloop>	
								</tbody>
								
							
							</table>
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
				<cfoutput>	
					 var controleInterno = '#application.rsUsuarioParametros.pc_org_controle_interno#';
				</cfoutput>

				if ($('#colunaEmAnalise').is(':visible')) {
				  var colunasMostrar = [1,5,6,9,11,12];
				} else {
				  if(controleInterno == 'S'){
				 	var colunasMostrar = [0,4,5,8,10,11];	
				  }else{
					var colunasMostrar = [0,5,6,9,11,12];	
				  }
				 
				}
				//initialize datatable
				const tabOrientacoesAcomp = $('#tabProcessos').DataTable( {
					stateSave: true,
					deferRender: true, // Aumentar desempenho para tabelas com muitos registros
					scrollX: true, // Habilitar rolagem horizontal
        			autoWidth: true, //largura da tabela de acordo com o conteúdo
					pageLength: 5,
					dom: 
								"<'row'<'col-sm-4 dtsp-verticalContainer'<'dtsp-verticalPanes'P><'dtsp-dataTable'Bf>><'col-sm-8 text-left'p>>" +
								"<'col-sm-12 text-left'i>" +
								"<'row'<'col-sm-12'tr>>" ,
					buttons: [
						{
							extend: 'excel',
							text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
							title : 'SNCI_Orientacoes_Pendentes_Acompanhamento_' + d,
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

			} );
           

			$(document).ready(function() {
				// Verificar se há um valor armazenado em sessionStorage e seleciona a orientação que acabou de ser colocada em análise
				var idOrientacao = sessionStorage.getItem('emAnalise');
				if (idOrientacao) {
					// Selecionar a linha correspondente ao idOrientacao
					var table = $('#tabProcessos').DataTable(); 
					var row = table.rows().eq(0).filter(function (rowIdx) {
					return table.cell(rowIdx, 5).data() == idOrientacao; // Substitua '1' pelo índice da coluna 'ID DA ORIENTAÇÃO'
					});
					if (row.length > 0) {
					// Adicionar a classe de seleção à linha encontrada
					table.row(row).select();
					}
					sessionStorage.removeItem('emAnalise');
				}

				// Adicionar evento de clique às linhas da tabela para selecionar
				$('#tabProcessos tbody').on('click', 'tr', function() {
					// Remove a classe 'selected' de todas as linhas
					$('#tabProcessos tr').removeClass('selected');
					
					// Adiciona a classe 'selected' à linha clicada
					$(this).addClass('selected');
				});

				// Adicionar evento de clique às linhas da tabela para selecionar
				$('#tabProcessos tbody').on('click', 'tr', function(event) {
					// Verifica se o clique foi em um botão
					if ($(event.target).hasClass('clickable-icon')) {
						return; // Ignora a ação da TR se o clique foi em um botão
					}
					
					// Remove a classe 'selected' de todas as linhas
					$('#tabProcessos tr').removeClass('selected');
					
					// Adiciona a classe 'selected' à linha clicada
					$(this).addClass('selected');

					// Pega a linha (tr) em que a célula foi clicada
					var $row = $(this);
					
					// Obtém os valores das células ocultas
					var pcAvalId = $row.find('#pcAvalId').text();
					var pcAvalOrientacaoId = $row.find('#pcAvalOrientacaoId').text();

					// Chama a função mostraInformacoesItensAcompanhamento com os valores
					mostraInformacoesItensAcompanhamento(pcAvalId, pcAvalOrientacaoId);
				});
			});

			
			function mostraInformacoesItensAcompanhamento(idAvaliacao, idOrientacao){
				
				$('#modalOverlay').modal('show')
				
				$('#informacoesItensAcompanhamentoDiv').html('');
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "informacoesItensAcompanhamento",
							idAvaliacao: idAvaliacao,
							idOrientacao: idOrientacao
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#informacoesItensAcompanhamentoDiv').html(result)
						$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('html, body').animate({ scrollTop: ($('#informacoesItensAcompanhamentoDiv').offset().top-80)} , 1000);
							$('#modalOverlay').modal('hide');
							
						});	
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					});//fim fail
				}, 500);	


			}

			function colocarEmAnalise(idProcesso, idAvaliacao, idOrientacao, orgaoOrigem, orgaoOrigemSigla, orgaoResp, statusOrientacao){
				<cfoutput>	
					 var lotacaoUsuario = '#application.rsUsuarioParametros.pc_usu_lotacao#';
					 var lotacaoUsuarioSigla = '#application.rsUsuarioParametros.pc_org_sigla#';
				</cfoutput>

				// Dividir a sequência usando a barra (/) como delimitador epegar a última
				lotacaoUsuarioSigla = lotacaoUsuarioSigla.split("/").pop();
				orgaoOrigemSigla = orgaoOrigemSigla.split("/").pop();


				$('#tabProcessos tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabProcessos tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
				sessionStorage.setItem('emAnalise',idOrientacao);
                

				if(orgaoResp==lotacaoUsuario && statusOrientacao==13){
					if(orgaoOrigem==lotacaoUsuario){
						var mensagem = '<p style="text-align: justify;">Deseja colocar esta orientação ID <strong style="color:red">' + idOrientacao + '</strong> "EM ANÁLISE" sob responsabilidade da (<strong>'+orgaoOrigemSigla+'</strong>)?</p>';
					}else{
						var mensagem = '<p style="text-align: justify;">Deseja colocar esta orientação ID <strong style="color:red">' + idOrientacao + '</strong> "EM ANÁLISE" sob responsabilidade do órgão de origem do processo (<strong>'+orgaoOrigemSigla+'</strong>)?</p>';
					
					}
					Swal.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
									data:{
										method: "colocarEmAnalise",
										idProcesso: idProcesso,
										idAvaliacao: idAvaliacao,
										idOrientacao: idOrientacao,
										orgaoOrigem: orgaoOrigem,
										analiseOrgaoOrigem: 1
									},
									async: false
								})//fim ajax
								.done(function(result) {
									
									exibirTabela();
									$('#informacoesItensAcompanhamentoDiv').html('')	
									var mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">'+idOrientacao+'</span> foi enviada para análise da <span style="color:#00416B">'+orgaoOrigemSigla+'</span> com sucesso!<br><br><span style="color:#00416B;font-size:0.8em;"><strong>Atenção:</strong> Como a gerência que analisará esta orientação não é a sua gerência de lotação, você não poderá visualizar esta orientação em "Acompanhamento", apenas em "Consulta por Orientação", portanto, orientamos anotar o ID da orientação, informado acima, e realizar uma consulta para verificar se essa rotina realmente foi executada com sucesso.</span></p>';
									$('#modalOverlay').delay(1000).hide(0, function() {
										Swal.fire({
											title: mensagemSucessos,
											html: logoSNCIsweetalert2(''),
											icon: 'success'
										});
										$('#modalOverlay').modal('hide');
									});	
													
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								})//fim fail
							}, 500);

						} else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
						
					})
				
				}else{
					var mensagem = '<p style="text-align: justify;">Deseja colocar esta orientação ID <strong style="color:red">'+idOrientacao+'</strong> "EM ANÁLISE"?</p>';
					Swal.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem),
					input: 'checkbox',
					inputValue: 0,
					inputPlaceholder:
						'<span class="font-weight-light" style="text-align: justify;font-size:14px">Assinale ao lado, para enviar essa orientação para análise do órgão de origem do processo (<strong>'+orgaoOrigemSigla+'</strong>) ou deixe em branco para encaminhar para análise da <strong>'+lotacaoUsuarioSigla+'</strong>.</span>',
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							var enviaOrgaoOrigem=result.value;
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcConsultasPorOrientacao.cfc",
									data:{
										method: "colocarEmAnalise",
										idProcesso: idProcesso,
										idAvaliacao: idAvaliacao,
										idOrientacao: idOrientacao,
										orgaoOrigem: orgaoOrigem,
										analiseOrgaoOrigem: enviaOrgaoOrigem
									},
									async: false
								})//fim ajax
								.done(function(result) {
									
									exibirTabela();
									$('#informacoesItensAcompanhamentoDiv').html('')	
									var mensagemSucessos ='';
									if(!enviaOrgaoOrigem){
										mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">' + idOrientacao + '</span> foi enviada para análise da <span style="color:#00416B">'+lotacaoUsuarioSigla+'</span> com sucesso!</p>';
									}else{
										mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">' + idOrientacao + '</span> foi enviada para análise da <span style="color:#00416B">'+orgaoOrigemSigla +'</span> com sucesso!<br><br><span style="color:#00416B;font-size:0.8em;"><strong>Atenção:</strong> Como a gerência que analisará esta orientação não é a sua gerência de lotação, você não poderá visualizar esta orientação em "Acompanhamento", apenas em "Consulta por Orientação", portanto, orientamos anotar o ID da orientação, informado acima, e realizar uma consulta para verificar se essa rotina realmente foi executada com sucesso.</span></p>';
									}
									$('#modalOverlay').delay(1000).hide(0, function() {
										Swal.fire({
											title: mensagemSucessos,
											html: logoSNCIsweetalert2(''),
											icon: 'success'
										});
										$('#modalOverlay').modal('hide');
										
									});	
													
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								})//fim fail
							}, 500);

						} else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					
					})
				}

				$('#modalOverlay').delay(1000).hide(0, function() {
					$('#modalOverlay').modal('hide');
				});
			}

			

		</script>	

		
	

	</cffunction>









	<cffunction name="informacoesItensAcompanhamento"   access="remote" hint="envia para a página acomanhamento.cfm tabs com informações do item.">
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="idOrientacao" type="numeric" required="true" />

		

		<session class="content-header"  >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">


					<div id="idAvaliacao" hidden></div>

					<cfquery name="rsProcAval" datasource="#application.dsn_processos#">
						SELECT      pc_processos.*, pc_avaliacoes.*,pc_avaliacao_orientacoes.*,pc_aval_orientacao_mcu_orgaoResp as mcuOrgaoResp
									,pc_aval_orientacao_mcu_orgaoResp as mcuOrgResp, pc_orgaos.pc_org_sigla as siglaOrgResp
									,pc_num_orgao_avaliado as mcuOrgAvaliado,  pc_orgaos2.pc_org_sigla as siglaOrgAvaliado
									,pc_num_orgao_origem as mcuOrgOrigem,  pc_orgaos3.pc_org_sigla as siglaOrgOrigem
									,pc_avaliacao_tipos.*, pc_classificacoes.*
						            ,pc_status_card_style_ribbon, pc_status_card_nome_ribbon
									,CONCAT(
									'Macroprocesso: ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
									' -> N1: ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
									' -> N2: ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,
									' -> N3: ', pc_avaliacao_tipos.pc_aval_tipo_processoN3, '.'
									) as tipoProcesso
						FROM        pc_processos 
									INNER JOIN pc_avaliacoes on pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo 
									INNER JOIN pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval =  pc_aval_id
									INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
									INNER JOIN pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_num_orgao_avaliado
									INNER JOIN pc_orgaos as pc_orgaos3 on pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
									INNER JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
									INNER JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
									LEFT JOIN pc_status on pc_status.pc_status_id = pc_processos.pc_num_status
						WHERE  pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#"> 
						and pc_aval_orientacao_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idOrientacao#">	 													
					</cfquery>	

					<cfquery name="rs_OrgAvaliado" datasource="#application.dsn_processos#">
						SELECT pc_orgaos.*FROM pc_orgaos
						WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#'  
								or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND pc_org_mcu_subord_tec = '#rsProcAval.pc_num_orgao_avaliado#'))
						ORDER BY pc_org_sigla
					</cfquery>


				
					<input id="pcProcessoId"  required="" hidden  value="#arguments.idAvaliacao#">
			
				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						.card-header p {
							margin-bottom: 5px;
						}
						fieldset{
							border: 1px solid #ced4da!important;
							border-radius: 8px!important;
							padding: 20px!important;
							margin-bottom: 10px!important;
							background: none!important;
							-webkit-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							-moz-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
						}

						legend {
							font-size: 0.8rem!important;
							color: #fff!important;
							background-color: #0083ca!important;
							border: 1px solid #ced4da!important;
							border-radius: 5px!important;
							padding: 5px!important;
							width: auto!important;
						}

						.borderTexto{
							border: 1px solid #ced4da!important;
							border-radius: 8px!important;
							padding: 10px!important;
							background: none!important;
							-webkit-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							-moz-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);

						}
					
					</style>
						
					<div class="card-header" style="background-color: #0083CA;border-bottom:solid 2px #fff" >
						<cfoutput>
							<p id="descricaoItem" style="font-size: 1em;color:##fff"><strong>Item: #rsProcAval.pc_aval_numeracao# - #rsProcAval.pc_aval_descricao#</strong>
							<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
							<!--<i id="start-tour2" style="color:##8cc63f;margin-left:20px;font-size: 1.3em;" class="fas fa-question-circle grow-icon"></i>-->
							</cfif>
							</p>
						</cfoutput>	
					</div>
					<div class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
								<li class="nav-item" style="">
									<a  class="nav-link  active" id="custom-tabs-one-Orientacao-tab"  data-toggle="pill" href="#custom-tabs-one-Orientacao" role="tab" aria-controls="custom-tabs-one-Orientacao" aria-selected="true">
									<cfoutput>
										
										Orientação p/ regularização: ID <strong>#rsProcAval.pc_aval_orientacao_id#</strong> - #rsProcAval.siglaOrgResp# (#rsProcAval.mcuOrgResp#)
										
									</cfoutput>
									</a>
								</li>
								

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfProcesso-tab"  data-toggle="pill" href="#custom-tabs-one-InfProcesso" role="tab" aria-controls="custom-tabs-one-InfProcesso" aria-selected="true">Inf. Processo</a>
								</li>

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfItem-tab"  data-toggle="pill" href="#custom-tabs-one-InfItem" role="tab" aria-controls="custom-tabs-one-InfItem" aria-selected="true">Inf. Item</a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link  " id="custom-tabs-one-Avaliacao-tab"  data-toggle="pill" href="#custom-tabs-one-Avaliacao" role="tab" aria-controls="custom-tabs-one-Avaliacao" aria-selected="true">Relatório</a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos</a>
								</li>
								
							</ul>
							
						</div>
						<div class="card-body">
							<div class="tab-content" id="custom-tabs-one-tabContent">
								<div disable class="borderTexto tab-pane fade  active show " id="custom-tabs-one-Orientacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Orientacao-tab" style="max-height: 200px; overflow-y: auto;">	
									
									<cfif rsProcAval.pc_aval_orientacao_distribuido eq 1>
										<div style=" display: inline;background-color: #e83e8c;color:#fff;padding: 3px;margin-left: 10px;">Orientação distribuída pelo órgão subordinador:</div>
									</cfif>
																						
									<pre style="color:#0083ca!important"><cfoutput><strong>#rsProcAval.pc_aval_orientacao_descricao#</strong></cfoutput></pre>
								</div>


								<div disable class="tab-pane fade" id="custom-tabs-one-InfProcesso"  role="tabpanel" aria-labelledby="custom-tabs-one-InfProcesso-tab" >								
									<div id="infoProcessoDiv" ></div>
								</div>

								<div disable class="tab-pane fade" id="custom-tabs-one-InfItem"  role="tabpanel" aria-labelledby="custom-tabs-one-InfItem-tab" >								
									<div id="infoItemDiv" ></div>
								</div>
								
								<div disable class="tab-pane fade" id="custom-tabs-one-Avaliacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Avaliacao-tab" >								
									<div id="anexoAvaliacaoDiv"></div>
								</div>

								<div class="tab-pane fade " id="custom-tabs-one-Anexos" role="tabpanel" aria-labelledby="custom-tabs-one-Anexos-tab">	
									<div id="tabAnexosDiv" style="margin-top:20px"></div>
								</div>

							</div>

						
						</div>
						
					</div>
				
				</form><!-- fim formCadAvaliacao -->
					
				<!--Inseri as tab de acompanhamento e distribuição se o a lotação do usuário for um órgão-->	
				<cfif application.rsUsuarioParametros.pc_org_controle_interno eq 'S'>
					<cfset timelineViewAcomp(arguments.idOrientacao)>
				<cfelse>
					<cfif application.rsOrgaoSubordinados.recordcount neq 0>
						<cfset timelineViewAcompOrgaoAvaliado(arguments.idOrientacao)>
						<div class="row" style="margin-bottom:50px">
							<div class="col-md-12">
							    
								<div class="card card-primary card-tabs" style="widht:100%">
									
									<div class="card-header p-0 pt-1" style="">
									    <div class="col-md-12"  style="border-bottom: 1px solid; padding: 10px;">
											<p>Senhor(a) gestor(a),</p>
											<li>Escolha a seguir entre as opções: <strong><i class="fas fa-user-pen"></i> Manifestação</strong> ou <strong><i class="fas fa-sitemap"></i> Distribuição</strong>;</li>
											<li>A opção "MANIFESTAÇÃO" possibilita o registro da resposta diretamente por esse gestor para envio ao Controle Interno;</li>
											<li>A opção de “DISTRIBUIÇÃO” possibilita o encaminhamento da ORIENTAÇÃO/MEDIDA DE REGULARIZAÇÃO e/ou PROPOSTA DE MELHORIA para 
												manifestação das áreas subordinadas a essa SE/Departamento. Essa distribuição poderá ser feita para até quatro áreas se a situação
												envolver órgãos distintos. Nesse caso o acompanhamento será desdobrado conforme encaminhamento realizado. Não havendo a necessidade 
												de distribuição, escolher a opção MANIFESTAÇÃO.</li>
											
										</div>
										<ul class="nav nav-tabs">
											<li class="nav-item">
												<a class="nav-link" id="tab-manifestacao" data-toggle="tab" href="#content-manifestacao" style="font-size:20px;"><i class="fas fa-user-pen" style="margin-top:4px;font-size: 20px;"></i><span style="margin-left:5px">Manifestação</span></a>
											</li>
											<li class="nav-item">
												<a class="nav-link" id="tab-distribuicao" data-toggle="tab" href="#content-distribuicao" style="font-size:20px;"><i class="fas fa-sitemap" style="margin-top:4px;font-size: 20px;"></i><span style="margin-left:5px">Distribuição</span></a>
											</li>
										</ul>
									</div>
									<div class="card-body">
										<div class="tab-content">
											<div class="tab-pane fade " id="content-manifestacao">
												<cfset formPosicionamentoOrgaoAvaliado(arguments.idOrientacao)>
											</div>
											<div class="tab-pane fade" id="content-distribuicao">
												<div id="pcOrgaoRespDistribuicaoDiv" class="col-sm-8" >
													<div class="form-group">
														<label    for="pcOrgaoRespDistribuicao">
															<div class="alertaDivMagenta" >Senhor(a) gestor(a), <br>
																Selecione, a seguir, as áreas para as quais pretende distribuir esse item para 
																manifestação. Antes da distribuição orientamos a ler atentamente a situação encontrada 
																de modo a melhor identificar a área responsável para tratamento do item. Se necessário, 
																o mesmo pode ser direcionado, simultaneamente, para até 04 áreas.<br>
																Informe, também, suas orientações para resposta da(s) área(s) subordinada(s).<br>
															</div>
																<i style="font-weight: normal;">Dica: Para selecionar mais de uma área, mantenha a tecla "Ctrl" pressionada enquanto seleciona.</i>
														</label>
														<select id="pcOrgaoRespDistribuicao" required="" name="pcOrgaoRespDistribuicao" class="form-control" multiple="multiple"  >
															<cfoutput query="application.rsOrgaoSubordinados">
																<option value="#pc_org_mcu#">#pc_org_sigla#</option>
															</cfoutput>
														</select>
													</div>
												</div>
												<div  class="col-sm-12" >
													<div class="form-group">
														<label   for="pcOrientacaoResposta">Orientações para resposta:</label>
														<textarea class="form-control" id="pcOrientacaoResposta" rows="4" required=""  name="pcOrientacaoResposta" class="form-control" placeholder="Digite aqui sua orientação para a(s) área(s) subordinada(s) selecionada(s) acima..."></textarea>
													</div>										
												</div>
												<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
													<div >
														<button id="btEnviarDistribuicao"  class="btn btn-block  " style="background-color:#0083ca;color:#fff">Distribuir</button>
													</div>
												</div>	
											</div>
										</div>
									</div>
							</div>
						</div>
					<cfelse>
						<cfset timelineViewAcompOrgaoAvaliado(arguments.idOrientacao)>
						<cfset formPosicionamentoOrgaoAvaliado(arguments.idOrientacao)>
					</cfif>


					
				</cfif>
			</session><!-- fim card-body2 -->	
					
		</session>

        
		<script language="JavaScript">
		

			$(document).ready(function() {	
				//Initialize Select2 Elements
				$('select').select2({
					theme: 'bootstrap4',
					placeholder: 'Selecione...'
				});
				$('#pcOrgaoRespDistribuicao').select2({
					theme: 'bootstrap4',
					placeholder: 'Selecione as áreas para distribuição da orientação...',
					allowClear: true // Opcional - permite desmarcar a seleção
				});
				// Monitora o select de distribuição para permitir a seleção de até 4 órgãos
				// Monitora o evento de mudança no elemento com id "pcOrgaoRespDistribuicao"
				$('#pcOrgaoRespDistribuicao').on('change', function(e) {
					var selectedOptions = $(this).val();
					var maxAllowedOptions = 4;

					if ((!e.ctrlKey && selectedOptions.length > maxAllowedOptions) || (e.ctrlKey && selectedOptions.length >= maxAllowedOptions)) {
						// Desabilita as opções não selecionadas se exceder o limite
						$(this).find('option:not(:selected)').prop('disabled', true);

						// Verifica se excedeu o limite após o change
						if (selectedOptions.length > maxAllowedOptions) {
							// Remove a última opção selecionada
							var lastSelectedOption = selectedOptions[selectedOptions.length - 1];
							$(this).find('option[value="' + lastSelectedOption + '"]').prop('selected', false);

							// Exibe um alerta
							Swal.fire({
								title: 'Você não pode selecionar mais do que ' + maxAllowedOptions + ' áreas.',
								html: logoSNCIsweetalert2(''),
								icon: 'error'
							});
						}
					} else {
						// Ativa todas as opções
						$(this).find('option').prop('disabled', false);
					}

					$(this).trigger('change.select2');
				});

				<cfoutput>
					var pc_aval_status = '#rsProcAval.pc_aval_status#'
					var pc_aval_id = '#rsProcAval.pc_aval_id#';
					var pc_orientacao_id = '#rsProcAval.pc_aval_orientacao_id#';
					var pc_processo_id = '#rsProcAval.pc_processo_id#';
				</cfoutput>
				mostraRelatoPDF();
				mostraTabAnexos();
				

				
				$('#tab-manifestacao').click(function() {
					$('html, body').animate({ scrollTop: ($('#tab-manifestacao').offset().top)-60} , 1000);
				});


				$('#tab-distribuicao').click(function() {
					$('html, body').animate({ scrollTop: ($('#tab-distribuicao').offset().top)-60} , 1000);
				});

				$('#custom-tabs-one-InfProcesso-tab').on('click', function (event){
					mostraInfoProcesso('infoProcessoDiv',pc_processo_id);
				});

				$('#custom-tabs-one-InfItem-tab').on('click', function (event){
					mostraInfoItem('infoItemDiv',pc_processo_id,pc_aval_id);
				});	
				
				
			})

			
			<cfoutput>
				var pc_aval_id = '#rsProcAval.pc_aval_id#';
				var pc_orientacao_id = '#rsProcAval.pc_aval_orientacao_id#';
			</cfoutput>

			

			$('#btEnviarDistribuicao').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()
                
				if ($('#pcOrgaoRespDistribuicao').val().length == 0){
					Swal.fire({
								title: 'Informe, pelo menos, uma área para distribuição.',
								html: logoSNCIsweetalert2(''),
								icon: 'error'
							});
					return false;
				}

				if ($('#pcOrientacaoResposta').val().length == 0){
					Swal.fire({
								title: 'Informe uma orientação para a resposta da(s) área(s).',
								html: logoSNCIsweetalert2(''),
								icon: 'error'
							});
					return false;
				}
				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2("Deseja distribuir essa Medida/Orientação para Regularização às áreas selecionadas?"),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!',
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show');
							setTimeout(function() {
								//inicio ajax
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method: "distribuirOrientacoes",
										pc_aval_orientacao_id: pc_orientacao_id,
										pcAreasDistribuir: $('#pcOrgaoRespDistribuicao').val().join(','),
										pcOrientacaoResposta: $('#pcOrientacaoResposta').val()
									},
									async: false
								})//fim ajax
								.done(function(result) {
									
									$('#modalOverlay').delay(1000).hide(0, function() {
										toastr.success('Distribuição realizada com sucesso!');
										ocultaInformacoes()
										exibirTabela();
										$('#modalOverlay').modal('hide');
										//location.reload();
										

									});
									
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								})//fim fail
							}, 1000);		
						} else if (result.dismiss === Swal.DismissReason.cancel) {
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					})//fim sweetalert2		

			});

			function mostraTabAnexos(){
				$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "tabAnexos",
							pc_aval_id: pc_aval_id,
							pc_orientacao_id: pc_orientacao_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabAnexosDiv').html(result)
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					})//fim fail

			}

			function mostraRelatoPDF(){
				
				$.ajax({
					type: "post",
					url:"cfc/pc_cfcAvaliacoes.cfc",
					data:{
						method: "anexoAvaliacao",
						pc_aval_id: pc_aval_id,
						todosOsRelatorios: "S"
					},
					async: false
				})//fim ajax
				.done(function(result){
					
					$('#anexoAvaliacaoDiv').html(result)
					
				})//fim done
				.fail(function(xhr, ajaxOptions, thrownError) {
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
					$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(thrownError)

				})//fim fail
			
			}


		</script>

    </cffunction>

	<cffunction name="distribuirMelhoria" returntype="any" access="remote" hint="Distribui as Propostas de Melhoria para áreas selecionadas pelo órgão avaliado.">
		<cfargument name="pc_aval_melhoria_id" type="string" required="true" />
		<cfargument name="pcAreasDistribuir" type="any" required="true" />

		<cfquery name="rsMelhoria" datasource="#application.dsn_processos#">
			SELECT * FROM pc_avaliacao_melhorias
			WHERE pc_aval_melhoria_id = <cfqueryparam value="#arguments.pc_aval_melhoria_id#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cftransaction>
			<cfloop list="#arguments.pcAreasDistribuir#" index="i">
				<cfquery  datasource="#application.dsn_processos#">
					INSERT pc_avaliacao_melhorias(pc_aval_melhoria_num_aval, pc_aval_melhoria_descricao,pc_aval_melhoria_num_orgao,pc_aval_melhoria_datahora,pc_aval_melhoria_login, pc_aval_melhoria_status, pc_aval_melhoria_distribuido )
                    VALUES (
							<cfqueryparam value="#rsMelhoria.pc_aval_melhoria_num_aval#" cfsqltype="cf_sql_numeric">, 
							<cfqueryparam value="#rsMelhoria.pc_aval_melhoria_descricao#" cfsqltype="cf_sql_varchar">, 
							<cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">, 
							<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">, 
							'#application.rsUsuarioParametros.pc_usu_login#', 
							'P', 
							1
						)
				</cfquery>

			<cftry>
				<!--Informações do órgão responsável-->
				<cfquery name="rsOrgaoResp" datasource="#application.dsn_processos#">
					SELECT pc_org_emaiL, pc_org_sigla FROM pc_orgaos
					WHERE pc_org_mcu = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfset to = "#LTrim(RTrim(rsOrgaoResp.pc_org_email))#">
				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrgaoResp.pc_org_sigla))#">
			    <cfset pronomeTrat = "Senhor(a) Gestor da #siglaOrgaoResponsavel#">
				
				<cfset textoEmail = 'Seu órgão subordinador distribuiu novas Propostas de Melhoria para conhecimento e providências. Favor atentar para o prazo de resposta. 

Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "Propostas de Melhoria" e inserir sua resposta:

<a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a>'>
							
				<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
				<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
							para = "#to#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
				/>
				<cfcatch type="any">
				<cfset de="SNCI@correios.com.br">
				<cfif FindNoCase("localhost", application.auxsite)>
					<cfset de="mbflpa@yahoo.com.br">
				</cfif>
					<cfmail from="#de#" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "distribuirMelhoria" de distribuição de propostas de melhoria: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry>

			</cfloop>

			<cfquery datasource="#application.dsn_processos#">
				DELETE FROM pc_avaliacao_melhorias
				WHERE pc_aval_melhoria_id = <cfqueryparam value="#arguments.pc_aval_melhoria_id#" cfsqltype="cf_sql_numeric">
			</cfquery>

		</cftransaction>

	</cffunction>





	<cffunction name="distribuirOrientacoes" returntype="any" access="remote" hint="Distribui as oreintações para áreas selecionadas pelo órgão avaliado.">
		<cfargument name="pc_aval_orientacao_id" type="string" required="true" />
		<cfargument name="pcAreasDistribuir" type="any" required="true" />
		<cfargument name="pcOrientacaoResposta" type="string" required="true" />

		<cfquery name="rsOrientacao" datasource="#application.dsn_processos#">
			SELECT * FROM pc_avaliacao_orientacoes
			WHERE pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfquery name="rsPosicionamentosParaReplicacao" datasource="#application.dsn_processos#">
			SELECT * FROM pc_avaliacao_posicionamentos
			WHERE pc_aval_posic_num_orientacao = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
			      and pc_aval_posic_enviado = 1
		</cfquery>

		<cftransaction>
			<!-- Exclui o posicionamento salvo (se existir) -->
			<cfquery datasource="#application.dsn_processos#">
				DELETE pc_avaliacao_posicionamentos
				WHERE pc_aval_posic_num_orientacao = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
			      and pc_aval_posic_enviado = 0
			</cfquery>
					

			<cfset firstItem = ListFirst(arguments.pcAreasDistribuir)><!-- Primeiro elemento da lista -->
			<cfset dataPrevista = rsOrientacao.pc_aval_orientacao_dataPrevistaResp>
			<cfset posic_status = rsOrientacao.pc_aval_orientacao_status>

			<cfloop list="#arguments.pcAreasDistribuir#" index="i">
			    <cfset orgaoResp = i>
				<!-- Atualização para o primeiro elemento -->
				<cfif i eq firstItem>
					<!-- Atualização para a priemira área selecionada -->
					<cfquery datasource="#application.dsn_processos#">
						UPDATE pc_avaliacao_orientacoes
						SET
							pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">,
							pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#',
							pc_aval_orientacao_distribuido = 1
						WHERE pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
					</cfquery>
					
					<!--Insere a manifestação inicial do controle interno para a orientação com a mesma data prevista e status da orientação original do órgão avaliado -->
				
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado)
						VALUES (<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">, <cfqueryparam value="#pcOrientacaoResposta#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#orgaoResp#','#dataPrevista#',#posic_status#,1)
					</cfquery>

				
				<cfelse>
					<!-- Inserção para as outras áreas selecionadas -->
					<cfquery datasource="#application.dsn_processos#" name="rsInserirOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_dataPrevistaResp, pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login, pc_aval_orientacao_distribuido)
						VALUES ('#dataPrevista#', #posic_status#, <cfqueryparam value="#rsOrientacao.pc_aval_orientacao_status_datahora#" cfsqltype="cf_sql_timestamp">, '#application.rsUsuarioParametros.pc_usu_login#',#rsOrientacao.pc_aval_orientacao_num_aval#, '#rsOrientacao.pc_aval_orientacao_descricao#','#i#',  <cfqueryparam value="#rsOrientacao.pc_aval_orientacao_datahora#" cfsqltype="cf_sql_timestamp">, '#application.rsUsuarioParametros.pc_usu_login#', 1)
						SELECT SCOPE_IDENTITY() AS idOrientacao;
					</cfquery>
					 <cfset insertedIdOrientacao = rsInserirOrientacao.idOrientacao> <!-- Obtém o ID gerado -->

					<!--Insere a manifestação do órgão avaliado interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado)
						VALUES (#insertedIdOrientacao#, <cfqueryparam value="#pcOrientacaoResposta#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#orgaoResp#','#dataPrevista#', #posic_status#,1)
					</cfquery>
					<!-- Replica as manifestações da orientação original para as orientações distribuídas -->
					<cfoutput query = "rsPosicionamentosParaReplicacao">
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_avaliacao_posicionamentos (pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado)
							VALUES (#insertedIdOrientacao#, '#pc_aval_posic_texto#', <cfqueryparam value="#pc_aval_posic_datahora#" cfsqltype="cf_sql_timestamp">, '#pc_aval_posic_matricula#', '#pc_aval_posic_num_orgao#', '#pc_aval_posic_num_orgaoResp#', '#pc_aval_posic_dataPrevistaResp#', #pc_aval_posic_status#, 1)
						</cfquery>
					</cfoutput>
						
					
				</cfif>

			<cftry>
				<!--Informações do órgão responsável-->
				<cfquery name="rsOrgaoResp" datasource="#application.dsn_processos#">
					SELECT pc_org_emaiL, pc_org_sigla FROM pc_orgaos
					WHERE pc_org_mcu = <cfqueryparam value="#orgaoResp#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfset to = "#LTrim(RTrim(rsOrgaoResp.pc_org_email))#">
				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrgaoResp.pc_org_sigla))#">
			    <cfset pronomeTrat = "Senhor(a) Gestor da #siglaOrgaoResponsavel#">
				
				<cfset textoEmail = 'Seu órgão subordinador distribuiu novas orientações para conhecimento e providências. Favor atentar para o prazo de resposta. 

Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "Medidas / Orientações para regularização" e inserir sua resposta:

<a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a>'>
							
				<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
				<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
							para = "#to#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
				/>
				<cfcatch type="any">
					<cfmail from="SNCI@correios.com.br" to="#application.rsUsuarioParametros.pc_usu_email#"  subject=" ERRO -SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
						<cfoutput>Erro rotina "distribuirOrientacoes" de distribuição de orientações: #cfcatch.message#</cfoutput>
					</cfmail>
				</cfcatch>
			</cftry>

			</cfloop>

		</cftransaction>


	</cffunction>

	<cffunction name="distribuirOrientacoesTeste" returntype="any" access="remote" hint="Distribui as oreintações para áreas selecionadas pelo órgão avaliado.">
		<cfargument name="pc_aval_orientacao_id" type="string" required="true" />
		<cfargument name="pcAreasDistribuir" type="any" required="true" />
		<cfargument name="pcOrientacaoResposta" type="string" required="true" />


			<cfloop list="#arguments.pcAreasDistribuir#" index="i">
			<cftry>
			    <cfset orgaoResp = "#i#">
				

				<!--Informações do órgão responsável-->
				<cfquery name="rsOrgaoResp" datasource="#application.dsn_processos#">
					SELECT * FROM pc_orgaos
					WHERE pc_org_mcu = <cfqueryparam value="#orgaoResp#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfset to = "#LTrim(RTrim(rsOrgaoResp.pc_org_email))#">
				<cfset siglaOrgaoResponsavel = "#LTrim(RTrim(rsOrgaoResp.pc_org_sigla))#">
			    <cfset pronomeTrat = "Senhor(a) Gestor da #siglaOrgaoResponsavel#">
				
				<cfset textoEmail = 'Seu órgão subordinador distribuiu novas orientações e/ou Propostas de Melhoria para conhecimento e providências. Favor atentar para o prazo de resposta. 

Orientamos a acessar o link abaixo, tela "Acompanhamento", aba "Medidas / Orientações para regularização" e/ou "Propostas de Melhoria"  e inserir sua resposta:

<a style="color:##fff" href="http://intranetsistemaspe/snci/snci_processos/index.cfm">http://intranetsistemaspe/snci/snci_processos/index.cfm</a>'>
							
				<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoioDist"/>
				<cfinvoke component="#pc_cfcPaginasApoioDist#" method="EnviaEmails" returnVariable="sucessoEmail" 
							para = "#to#"
							pronomeTratamento = "#pronomeTrat#"
							texto="#textoEmail#"
				/>
				 <cfcatch type="any">
       <cfmail from="SNCI@correios.com.br" to="marceloferreira@correios.com.br" subject="SNCI - SISTEMA NACIONAL DE CONTROLE INTERNO" type="html">
	   			<cfoutput>#cfcatch.message# <cfdump var ="#rsOrgaoResp#"></cfoutput>
	   </cfmail>
	   
     
    </cfcatch>
</cftry>
			</cfloop>

	


	</cffunction>








	<cffunction name="tabMelhoriasPendentes" access="remote" hint="Criar a tabela das propostas de melhoria e envia para a página pcAcompanhamento.cfm">
		
		<cfquery name="rsMelhoriasPendentes" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_melhorias.*, pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_num_sei
			,pc_avaliacoes.pc_aval_numeracao , pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla,  pc_orgaos.pc_org_mcu
			FROM pc_avaliacao_melhorias
			INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			WHERE pc_aval_melhoria_status = 'P' and pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#' and pc_num_status in(4,5)
		</cfquery>
		
		<div class="row" >
			<div class="col-12">
				<div class="card"  >
				    
					<!-- /.card-header -->
					<div class="card-body" >

						<cfif #rsMelhoriasPendentes.recordcount# eq 0 >
							<h5 align="center">Nenhuma Proposta de Melhoria pendente foi localizada para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
						<cfelse>
							<table id="tabMelhoriasPendentes" class="table table-bordered table-striped table-hover text-nowrap">
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:14px">
									    <th id="colunaStatusProposta">Status:</th>
										<th >ID:</th>
										<th >N° Processo SNCI:</th>
										<th >N° Item:</th>	
										<th>Órgão Responsável: </th>
										<th >SE/CS:</th>
										<cfif #rsMelhoriasPendentes.pc_modalidade# eq 'A' or #rsMelhoriasPendentes.pc_modalidade# eq 'E'>
											<th >N° SEI: </th>
										</cfif>
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsMelhoriasPendentes" >
										<cfoutput>					
											<tr style="font-size:12px;cursor:pointer;z-index:2;"  onclick="javascript:mostraInfMelhoriaAcomp(#pc_aval_melhoria_id#)">
												<td id="statusMelhorias"align="center" ><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;">PENDENTE</span></td>
												<td align="center">#pc_aval_melhoria_id#</td>	
												<td align="center">#pc_processo_id#</td>
												<td align="center">#pc_aval_numeracao#</td>
												
												<cfif rsMelhoriasPendentes.pc_aval_melhoria_distribuido eq 1>
													<td align="center">#pc_org_sigla# (#pc_org_mcu#)</td>
												<cfelse>
													<td align="center">#pc_org_sigla# (#pc_org_mcu#)</td>
												</cfif>
												<td align="center">#pc_org_se_sigla#</td>
												

												<cfif #rsMelhoriasPendentes.pc_modalidade# eq 'A' or #rsMelhoriasPendentes.pc_modalidade# eq 'E'>
													<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
													<td align="center">#sei#</td>
												</cfif>
											</tr>
										</cfoutput>
									</cfloop>	
								</tbody>
								
							
							</table>
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

			function activaTab(tab){
				$('.nav-tabs a[href="#' + tab + '"]').tab('show');
			};

			function quantMelhorias(){
				<cfoutput>
					var quantMelhorias = #rsMelhoriasPendentes.recordcount#;
				</cfoutput>
				if(quantMelhorias>0){
					var textoAbaMelhorias = 'PROPOSTAS DE MELHORIA <span class="badge badge-warning" style="font-size: 100%!important;">'+quantMelhorias+'</span>';
					$('#custom-tabs-one-MelhoriaAcomp-tab').html(textoAbaMelhorias);
				}
			}

			$(document).ready(function(){

				quantMelhorias()

			});

			


			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;
		

			$(function () {
				$('#tabMelhoriasPendentes').DataTable( {
					stateSave: false,
					responsive: true, 
					lengthChange: true, 
					autoWidth: false,
					lengthMenu: [
						[5,10, 25, 50, -1],
						[5,10, 25, 50, 'Todos'],
					],
					
					});


			} );

			function mostraInfMelhoriaAcomp(idMelhoria){
				$('#tabMelhoriasPendentes tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabMelhoriasPendentes tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
				$('#modalOverlay').modal('show')
				
				$('#informacoesItensAcompanhamentoDiv').html('');
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "informacoesItensAcompanhamentoMelhoria",
							idMelhoria: idMelhoria
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#informacoesItensAcompanhamentoDiv').html(result)
						$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('html, body').animate({ scrollTop: ($('#formCadItem').offset().top-80)} , 1000);
							$('#modalOverlay').modal('hide');
						});	
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					});
				}, 500);
					


			}

			</script>




	</cffunction>

	






	<cffunction name="formMelhoriaPosic"   access="remote" hint="envia para a página acomanhamento.cfm o form de melhorias para manifestação">

		<cfargument name="idMelhoria" type="numeric" required="true" />

		<cfquery name="rsMelhoriaPosic" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_melhorias.*, pc_processos.*,pc_avaliacoes.pc_aval_numeracao,pc_avaliacoes.pc_aval_descricao 
			, pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla
			FROM pc_avaliacao_melhorias
			INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			WHERE pc_aval_melhoria_id = <cfqueryparam value="#arguments.idMelhoria#" cfsqltype="cf_sql_numeric">
		</cfquery>

		<cfquery name="rs_OrgAvaliado" datasource="#application.dsn_processos#">
			SELECT pc_orgaos.*FROM pc_orgaos
			WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') and (pc_org_mcu_subord_tec = '#rsMelhoriaPosic.pc_num_orgao_avaliado#' or pc_org_mcu = '#rsMelhoriaPosic.pc_num_orgao_avaliado#' 
					or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND pc_org_mcu_subord_tec = '#rsMelhoriaPosic.pc_num_orgao_avaliado#'))
			ORDER BY pc_org_sigla
		</cfquery>

	
		

		<div class="card-header" style="background-color:#ececec;" >
			<div class="row" style="font-size: 1em;">

				<div class="col-sm-2">
					<div class="form-group">
						<label  for="pcStatusMelhoria">Status:</label>
						<select id="pcStatusMelhoria" required="" name="pcStatusMelhoria" class="form-control"  >
							<option selected="" disabled="" value="">Selecione um status</option>
							<option value="A">ACEITA</option>
							<option value="R">RECUSA</option>
							<option value="T">TROCA</option>
						</select>
					</div>
				</div>

				<div id="pcDataPrevDiv" class="col-md-3" hidden>
					<div class="form-group">
						<label  for="pcDataPrev">Data prevista para Implementação:</label>
						<div class="input-group date" id="reservationdate" data-target-input="nearest">
							<input  id="pcDataPrev"  name="pcDataPrev" required  type="date" class="form-control" placeholder="dd/mm/aaaa" >
						</div>
					</div>
				</div>
				<br>
				

				<div id="pcRecusaJustMelhoriaDiv" class="col-sm-12" hidden>
					<div class="form-group">
						<label   id="labelPcRecusaJustMelhoria" for="pcRecusaJustMelhoria">Informe as justificativa do órgão para Recusa:</label>
						<textarea class="form-control" id="pcRecusaJustMelhoria" rows="4" required=""  name="pcRecusaJustMelhoria" class="form-control"></textarea>
					</div>										
				</div>

				<div id="pcNovaAcaoMelhoriaDiv" class="col-sm-12" hidden>
					<div class="form-group">
					   
						<label   id="labelPcRecusaJustMelhoria" for="pcNovaAcaoMelhoria">Informe as ações que o órgão julga necessárias:</label>
						
						<textarea class="form-control" id="pcNovaAcaoMelhoria" rows="4" required=""  name="pcNovaAcaoMelhoria" class="form-control"></textarea>
					</div>										
				</div>

				<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
					<div >
						<button id="btSalvarMelhoriaPosic"  class="btn btn-block  " style="background-color:#0083ca;color:#fff">Enviar</button>
					</div>
				</div>	
				
			</div>
		</div>

		<script language="JavaScript">


			$('#pcStatusMelhoria').on('change', function (event)  {

				<cfoutput>
					var orgAvaliado = '#rsMelhoriaPosic.pc_num_orgao_avaliado#'
					var orgResp = '#rsMelhoriaPosic.pc_aval_melhoria_num_orgao#'
				</cfoutput>
				if($('#pcStatusMelhoria').val()=='A'){
					$('#pcDataPrevDiv').attr('hidden', false)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)			
					

					$('#pcRecusaJustMelhoria').val('')
					$('#pcNovaAcaoMelhoria').val('')			
				
				}
				if($('#pcStatusMelhoria').val()=='R'){
					$('#pcDataPrevDiv').attr('hidden', true)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', false)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)
						

					$('#pcDataPrev').val('')
					$('#pcNovaAcaoMelhoria').val('')
				
				}
				if($('#pcStatusMelhoria').val()=='T'){
					$('#pcDataPrevDiv').attr('hidden', false)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', false)
					
					$('#pcRecusaJustMelhoria').val('')
					
				}
				


				if($('#pcStatusMelhoria').val()==null || $('#pcStatusMelhoria').val()=='N' || $('#pcStatusMelhoria').val()=='P'){
					$('#pcDataPrevDiv').attr('hidden', true)
					$('#pcRecusaJustMelhoriaDiv').attr('hidden', true)
					$('#pcNovaAcaoMelhoriaDiv').attr('hidden', true)
				

					$('#pcDataPrev').val('')
					$('#pcRecusaJustMelhoria').val('')
					$('#pcNovaAcaoMelhoria').val('')
						
				}

				$('html, body').animate({ scrollTop: ($('#pcStatusMelhoria').offset().top)} , 500);
			})

			
			$('#btSalvarMelhoriaPosic').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()

				<cfoutput>
					var pc_aval_id = '#rsMelhoriaPosic.pc_aval_melhoria_num_aval#';
                    var idMelhoria = '#arguments.idMelhoria#';
					var orgAvaliado = '#rsMelhoriaPosic.pc_num_orgao_avaliado#'
					var orgResp = '#rsMelhoriaPosic.pc_aval_melhoria_num_orgao#'
				</cfoutput>

				//verifica se os campos necessários foram preenchidos
				if (
					$('#pcStatusMelhoria').val() == null ||
					($('#pcStatusMelhoria').val()=='A' && !$('#pcDataPrev').val())||
					($('#pcStatusMelhoria').val()=='R' && $('#pcRecusaJustMelhoria').val().length == 0 )||
					($('#pcStatusMelhoria').val()=='T' && (!$('#pcDataPrev').val()||$('#pcNovaAcaoMelhoria').val().length == 0))
				){   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}
				

				$('#modalOverlay').modal('show')
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "cadMelhoriasPosic",
							pc_aval_id: pc_aval_id,
							pc_aval_melhoria_id: idMelhoria,
							pc_aval_melhoria_status:$('#pcStatusMelhoria').val(),
							pc_aval_melhoria_dataPrev: $('#pcDataPrev').val(),
							pc_aval_melhoria_sugestao: $('#pcNovaAcaoMelhoria').val(),
							pc_aval_melhoria_naoAceita_justif:$('#pcRecusaJustMelhoria').val()
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#pcDataPrev').val('')
						$('#pcRecusaJustMelhoria').val('')
						$('#pcNovaAcaoMelhoria').val('')
						$('#pcStatusMelhoria').val('').trigger('change')
						$('#informacoesItensAcompanhamentoDiv').html('')
						exibirTabelaMelhoriasPendentes()
						$('#custom-tabs-one-MelhoriaAcomp-tab').html("PROPOSTAS DE MELHORIA");
						$('html, body').animate({ scrollTop: ($('#custom-tabs-one-tabAcomp').offset().top)} , 500);	
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});	
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					});
				}, 500);
	
						
			});


		</script>




	</cffunction>









	<cffunction name="informacoesItensAcompanhamentoMelhoria"   access="remote" hint="envia para a página acomanhamento.cfm tabs com informações do item.">
		<cfargument name="idMelhoria" type="numeric" required="true" />


		<session class="content-header"  >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">



					<cfquery name="rsProcAval" datasource="#application.dsn_processos#">
						SELECT      pc_processos.*, pc_avaliacoes.*,pc_avaliacao_melhorias.*
									,pc_orgaos.pc_org_mcu as mcuOrgResp,pc_orgaos.pc_org_sigla as siglaOrgResp
									,pc_orgaos1.pc_org_mcu as mcuOrgRespSugerido, pc_orgaos1.pc_org_sigla as siglaOrgRespSugerido
									,pc_num_orgao_avaliado as mcuOrgAvaliado,  pc_orgaos2.pc_org_sigla as siglaOrgAvaliado
									,pc_num_orgao_origem as mcuOrgOrigem,  pc_orgaos3.pc_org_sigla as siglaOrgOrigem
									,pc_avaliacao_tipos.*, pc_classificacoes.* ,pc_status_card_style_ribbon, pc_status_card_nome_ribbon
						FROM        pc_processos 
									INNER JOIN pc_avaliacoes on pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo 
									INNER JOIN pc_avaliacao_melhorias on pc_aval_melhoria_num_aval = pc_aval_id
									INNER JOIN pc_orgaos as pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_melhoria_num_orgao
									LEFT JOIN pc_orgaos as pc_orgaos1 on pc_orgaos1.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
									INNER JOIN pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_num_orgao_avaliado
									INNER JOIN pc_orgaos as pc_orgaos3 on pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
									INNER JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
									INNER JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
									LEFT JOIN pc_status on pc_status.pc_status_id = pc_processos.pc_num_status
						WHERE  pc_aval_melhoria_id = <cfqueryparam value="#arguments.idMelhoria#" cfsqltype="cf_sql_numeric">	 													
					</cfquery>	



				
					<style>
						.nav-tabs {
							border-bottom: none!important;
						}
						fieldset{
							border: 1px solid #ced4da!important;
							border-radius: 8px!important;
							padding: 20px!important;
							margin-bottom: 10px!important;
							background: none!important;
							-webkit-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							-moz-box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
							box-shadow: 7px 7px 9px 0px rgba(217,217,217,0.69);
						}

						legend {
							font-size: 0.8rem!important;
							color: #fff!important;
							background-color: #0083ca!important;
							border: 1px solid #ced4da!important;
							border-radius: 5px!important;
							padding: 5px!important;
							width: auto!important;
						}
					
					</style>
						
					<div class="card-header" style="background-color: #0083CA;border-bottom:solid 2px #fff" >
						<cfoutput>
							<p id="formManifMelhorias" style="font-size: 1.3em;color:##fff"><strong>Item: #rsProcAval.pc_aval_numeracao# - #rsProcAval.pc_aval_descricao#</strong></p>
						</cfoutput>	
					</div>
					<div class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
								<li class="nav-item" style="">
									<a  class="nav-link  active" id="custom-tabs-one-Melhoria-tab"  data-toggle="pill" href="#custom-tabs-one-Melhoria" role="tab" aria-controls="custom-tabs-one-Melhoria" aria-selected="true"> Proposta de Melhoria p/ Manifestação: ID <cfoutput><strong>#rsProcAval.pc_aval_melhoria_id#</strong> - #rsProcAval.siglaOrgResp# (#rsProcAval.mcuOrgResp#)</cfoutput></a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfProcesso-tab"  data-toggle="pill" href="#custom-tabs-one-InfProcesso" role="tab" aria-controls="custom-tabs-one-InfProcesso" aria-selected="true">Inf. Processo</a>
								</li>

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfItem-tab"  data-toggle="pill" href="#custom-tabs-one-InfItem" role="tab" aria-controls="custom-tabs-one-InfItem" aria-selected="true">Inf. Item</a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link  " id="custom-tabs-one-Avaliacao-tab"  data-toggle="pill" href="#custom-tabs-one-Avaliacao" role="tab" aria-controls="custom-tabs-one-Avaliacao" aria-selected="true">Relatório</a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos do Item <cfoutput>#rsProcAval.pc_aval_numeracao#</cfoutput></a>
								</li>
								
							</ul>
							
						</div>
						<div class="card-body">
							<div class="tab-content" id="custom-tabs-one-tabContent">
								<div disable class="tab-pane fade  active show" id="custom-tabs-one-Melhoria"  role="tabpanel" aria-labelledby="custom-tabs-one-Melhoria-tab" >														
									<div class="col-md-12">
										<cfoutput>
											<cfif rsProcAval.pc_aval_melhoria_distribuido eq 1>
												<div style=" display: inline;background-color: ##e83e8c;color:##fff;padding: 3px;">Proposta de melhoria distribuída pelo seu órgão subordinador:</div>
											</cfif>
										</cfoutput>
							            <div class="small-box" style="" >
											<cfoutput>
												<pre style="font-size: 1em;">#rsProcAval.pc_aval_melhoria_descricao#</pre>
											</cfoutput>
										</div>
										<cfif application.rsOrgaoSubordinados.recordcount gt 0>
											<div class="card card-primary card-tabs" style="widht:100%">
												
												<div class="card-header p-0 pt-1" style="">
													
													<ul class="nav nav-tabs">
														<li class="nav-item">
															<a class="nav-link" id="tab-responder" data-toggle="tab" href="#content-responder" style="font-size:20px;"><i class="fas fa-user-pen" style="margin-top:4px;font-size: 20px;"></i><span style="margin-left:5px">Responder</span></a>
														</li>
														
														<li class="nav-item">
															<a class="nav-link" id="tab-distribuicao" data-toggle="tab" href="#content-distribuicao" style="font-size:20px;"><i class="fas fa-sitemap" style="margin-top:4px;font-size: 20px;"></i><span style="margin-left:5px">Distribuir</span></a>
														</li>

													</ul>
												</div>
												<div class="card-body">
													<div class="tab-content">
														<div class="tab-pane fade " id="content-responder">
															<div id="informacoesMelhoriasDiv"></div>
														</div>

														<div class="tab-pane fade" id="content-distribuicao">
															<div id="pcOrgaoRespDistribuicaoDiv" class="col-sm-8" >
																<div class="form-group">
																	<label    for="pcOrgaoRespDistribuicao">
																		<div class="alertaDivMagenta" >Senhor(a) gestor(a), <br>
																			Selecione, a seguir, as áreas para as quais pretende distribuir essa Proposta de Melhoria. Antes da distribuição orientamos a ler atentamente a situação encontrada 
																			de modo a melhor identificar a área para direcionamento. Se necessário, a mesma pode ser direcionada, simultaneamente, para até 04 áreas.
																		</div>
																			<i style="font-weight: normal;">Dica: Para selecionar mais de uma área, mantenha a tecla "Ctrl" pressionada enquanto seleciona.</i>
																	</label>
																	<select id="pcOrgaoRespDistribuicao" required="" name="pcOrgaoRespDistribuicao" class="form-control" multiple="multiple"  >
																		<cfoutput query="application.rsOrgaoSubordinados">
																			<option value="#pc_org_mcu#">#pc_org_sigla#</option>
																		</cfoutput>
																	</select>
																</div>
															</div>
															
															<div style="justify-content:center; display: flex; width: 100%;margin-top:20px">
																<div >
																	<button id="btEnviarDistribuicaoMelhoria"  class="btn btn-block  " style="background-color:#0083ca;color:#fff">Distribuir</button>
																</div>
															</div>	
														</div>
													</div>
												</div>

											</div>	
										<cfelse>
											<div id="informacoesMelhoriasDiv"></div>
										</cfif>
									</div>

								</div>

								<div disable class="tab-pane fade" id="custom-tabs-one-InfProcesso"  role="tabpanel" aria-labelledby="custom-tabs-one-InfProcesso-tab" >								
									<cfset aux_sei = Trim('#rsProcAval.pc_num_sei#')>
									<cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
		
									<section class="content" >
										<div id="processosCadastrados" class="container-fluid" >
											<div class="row">
												<div id="cartao" style="width:100%;" >
													<!-- small card -->
													<cfoutput>
														<div class="small-box " style=" font-weight: bold;">
															<div class="ribbon-wrapper ribbon-xl" >
																<div class="ribbon" style="font-size:18px!important;left:8px;<cfoutput>#rsProcAval.pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#rsProcAval.pc_status_card_nome_ribbon#</cfoutput></div>
															</div>
															<div class="card-header" style="height:auto">
																<p style="font-size: 1.5em;">Processo SNCI n°: <strong style="color:##0692c6;margin-right:30px">#rsProcAval.pc_processo_id#</strong> Órgão Avaliado: <strong style="color:##0692c6">#rsProcAval.siglaOrgAvaliado#</strong></p>
																
																<p style="font-size: 1em;">Origem: <strong style="color:##0692c6;margin-right:30px">#rsProcAval.siglaOrgOrigem#</strong>
																
																<cfif #rsProcAval.pc_modalidade# eq 'A' or #rsProcAval.pc_modalidade# eq 'E'>
																	<span >Processo SEI n°: </span> <strong style="color:##0692c6">#aux_sei#</strong> <span style="margin-left:20px">Relatório n°:</span> <strong style="color:##0692c6">#rsProcAval.pc_num_rel_sei#</strong>
																</cfif></p>
																
																<p style="font-size: 1em;">Tipo de Avaliação: 
																<cfif rsProcAval.pc_num_avaliacao_tipo neq 2>
																	<strong style="color:##0692c6">#rsProcAval.pc_aval_tipo_descricao#</strong></p>
																<cfelse>
																	<strong style="color:##0692c6">#rsProcAval.pc_aval_tipo_nao_aplica_descricao#</strong></p>
																</cfif>
																
																
																<p style="font-size: 1em;">
																	Classificação: <strong style="color:##0692c6;margin-right:50px">#rsProcAval.pc_class_descricao#</strong>
																	<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S' >	
																		Modalidade: 
																		<cfif #rsProcAval.pc_modalidade# eq 'N'>
																			<strong style="color:##0692c6">Normal</strong>
																		</cfif>
																		<cfif #rsProcAval.pc_modalidade# eq 'A'>
																			<strong style="color:##0692c6">ACOMPANHAMENTO</strong>
																		</cfif>
																		<cfif #rsProcAval.pc_modalidade# eq 'E'>
																			<strong style="color:##0692c6">ENTREGA DO RELATÓRIO</strong>
																		</cfif>

																	</cfif>
																</p>

																<p style="font-size: 1em;">

																</p>

																<cfquery datasource="#application.dsn_processos#" name="rsCoordenadorRegional">
																	SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios
																	INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
																	WHERE pc_usu_matricula = '#rsProcAval.pc_usu_matricula_coordenador#'
																</cfquery>
																<cfquery datasource="#application.dsn_processos#" name="rsCoordenadorNacional">
																	SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios
																	INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
																	WHERE pc_usu_matricula = '#rsProcAval.pc_usu_matricula_coordenador_nacional#'
																</cfquery>

																<cfquery datasource="#application.dsn_processos#" name="rsAvaliadores">
																	SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_avaliadores
																	INNER JOIN pc_usuarios on pc_usu_matricula = pc_avaliador_matricula
																	INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
																	WHERE pc_avaliador_id_processo = '#rsProcAval.pc_processo_id#'
																</cfquery>

																<fieldset style="padding:0px!important;min-height: 90px;">
																	<legend style="margin-left:20px">Equipe:</legend>
																	<p style="font-size: 1em;">
																		<cfif rsCoordenadorRegional.recordcount neq 0>
																			Coordenador Regional: <strong style="color:##0692c6;margin-right:50px">#rsCoordenadorRegional.pc_usu_nome# (#rsCoordenadorRegional.pc_org_se_sigla#)</strong>
																		</cfif>
																		<cfif rsCoordenadorNacional.recordcount neq 0>	
																			Coordenador Nacional: <strong style="color:##0692c6;margin-right:50px">#rsCoordenadorNacional.pc_usu_nome# (#rsCoordenadorNacional.pc_org_se_sigla#)</strong>
																		</cfif>
																	</p>

																	<cfif rsAvaliadores.recordcount neq 0>
																		<p style="font-size: 1em;">
																			Avaliadores:<br> 
																			<cfloop query="rsAvaliadores">
																				<strong style="color:##0692c6;margin-right:50px">#pc_usu_nome# (#pc_org_se_sigla#)</strong><br>
																			</cfloop>
																		</p>
																	</cfif>
																</fieldset>

															</div>
														</div>
													</cfoutput>
												</div>
											</div>
										</div>
										
									</section>
								</div>

								<div disable class="tab-pane fade" id="custom-tabs-one-InfItem"  role="tabpanel" aria-labelledby="custom-tabs-one-InfItem-tab" >								
									<cfset classifRisco = "">
									<cfif #rsProcAval.pc_aval_classificacao# eq 'L'>
										<cfset classifRisco = "Leve">
									</cfif>	
									<cfif #rsProcAval.pc_aval_classificacao# eq 'M'>
										<cfset classifRisco = "Mediana">
									</cfif>	
									<cfif #rsProcAval.pc_aval_classificacao# eq 'G'>
										<cfset classifRisco = "Grave">
									</cfif>	
									<section class="content" >
										<div id="processosCadastrados" class="container-fluid" >
											<div class="row">
												<div id="cartao" style="width:100%;" >
													<!-- small card -->
													<cfoutput>
														<div class="small-box " style=" font-weight: bold;">
															
															<div class="card-header" style="height:auto">
															
																<p style="font-size: 1.3em;">Item: <span style="color:##0692c6;">#rsProcAval.pc_aval_numeracao# - #rsProcAval.pc_aval_descricao#</span></p>
																<p style="font-size: 1.3em;">Classificação: <span style="color:##0692c6;">#classifRisco#</span></p>
																
																<cfset ano = RIGHT(#rsProcAval.pc_processo_id#,4)>
																<cfif #ano# lte 2023>
																	<cfif #rsProcAval.pc_aval_vaFalta# gt 0 or  #rsProcAval.pc_aval_vaSobra# gt 0 or  #rsProcAval.pc_aval_vaRisco# gt 0 >
																 		<p style="font-size: 1.3em;">Valor Envolvido: 
																			<cfif #rsProcAval.pc_aval_vaFalta# gt 0>
																				<cfset valorApurado = #LSCurrencyFormat( rsProcAval.pc_aval_vaFalta, 'local')#>
																				<span style="color:##0692c6;">Falta =  #valorApurado#; </span>
																			</cfif>
																			<cfif #rsProcAval.pc_aval_vaSobra# gt 0>
																				<cfset valorApurado = #LSCurrencyFormat( rsProcAval.pc_aval_vaSobra, 'local')#>
																				<span style="color:##0692c6;">Sobra =  #valorApurado#; </span>
																			</cfif>
																			<cfif #rsProcAval.pc_aval_vaRisco# gt 0>
																				<cfset valorApurado = #LSCurrencyFormat( rsProcAval.pc_aval_vaRisco, 'local')#>
																				<span style="color:##0692c6;">Risco =  #valorApurado#; </span>
																			</cfif>
																		</p>
																	<cfelse>
																		<p style="font-size: 1.3em;">Valor Envolvido: <span style="color:##0692c6;">Não quantificado</span></p>
																	</cfif>
																<cfelse>
																	<cfif rsProcAval.pc_aval_valorEstimadoRecuperar gt 0>
																		<p style="font-size: 1.3em;">Potencial Valor Estimado a Recuperar: <span style="color:##0692c6;">#LSCurrencyFormat(rsProcAval.pc_aval_valorEstimadoRecuperar, 'local')#</span></p>
																	</cfif>
																	<cfif rsProcAval.pc_aval_valorEstimadoRisco gt 0>
																		<p style="font-size: 1.3em;">Potencial Valor Estimado em Risco ou Valor Envolvido: <span style="color:##0692c6;">#LSCurrencyFormat(rsProcAval.pc_aval_valorEstimadoRisco, 'local')#</span></p>
																	</cfif>
																	<cfif rsProcAval.pc_aval_valorEstimadoRisco gt 0>
																		<p style="font-size: 1.3em;">Potencial Valor Estimado Não Planejado/Extrapolado/Sobra: <span style="color:##0692c6;">#LSCurrencyFormat(rsProcAval.pc_aval_valorEstimadoNaoPlanejado, 'local')#</span></p>
																	</cfif>
																</cfif>	
																
																
						
															</div>
														</div>
													</cfoutput>
												</div>
											</div>
										</div>
										
									</section>
								</div>
								
								<div disable class="tab-pane fade" id="custom-tabs-one-Avaliacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Avaliacao-tab" >								
									<div id="anexoAvaliacaoDiv"></div>
								</div>

								<div class="tab-pane fade " id="custom-tabs-one-Anexos" role="tabpanel" aria-labelledby="custom-tabs-one-Anexos-tab">	
									
									<div id="tabAnexosDiv" style="margin-top:20px"></div>
								</div>

							</div>

						
						</div>
						
					</div>
				
				</form><!-- fim formCadAvaliacao -->
			</session><!-- fim card-body2 -->	
					
			

					
		</session>

        
		<script language="JavaScript">
	
			<cfoutput>
				var pc_aval_id = '#rsProcAval.pc_aval_id#'
			</cfoutput>

			function mostraTabAnexos(){
				$.ajax({
						type: "post",
						url: "cfc/pc_cfcAvaliacoes.cfc",
						data:{
							method: "tabAnexos",
							pc_aval_id: pc_aval_id
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#tabAnexosDiv').html(result)
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					})//fim fail

			}

			function mostraRelatoPDF(){
				
				$.ajax({
					type: "post",
					url:"cfc/pc_cfcAvaliacoes.cfc",
					data:{
						method: "anexoAvaliacao",
						pc_aval_id: pc_aval_id,
						todosOsRelatorios: "S"
					},
					async: false
				})//fim ajax
				.done(function(result){
					
					$('#anexoAvaliacaoDiv').html(result)
					
				})//fim done
				.fail(function(xhr, ajaxOptions, thrownError) {
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
					$('#modal-danger').modal('show')
					$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
					$('#modal-danger').find('.modal-body').text(thrownError)

				})//fim fail
			
			}

			function mostraInformacoesMelhoria(idMelhoria){
				
				$('#modalOverlay').modal('show')
				
				$('#informacoesMelhoriasDiv').html('');
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "formMelhoriaPosic",
							idMelhoria: idMelhoria
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#informacoesMelhoriasDiv').html(result)
						$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
						$('#modalOverlay').delay(1000).hide(0, function() {
							//$('html, body').animate({ scrollTop: ($('#informacoesMelhoriasDiv').offset().top-80)} , 1000);
							$('#modalOverlay').modal('hide');
							
						});	
						

						
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					});
				}, 500);
					


			}

			$(document).ready(function() {
				<cfoutput>
					var idMelhoria = #arguments.idMelhoria#;
				</cfoutput>	
				
				mostraRelatoPDF();
				mostraTabAnexos();
				mostraInformacoesMelhoria(idMelhoria)

				$('#pcOrgaoRespDistribuicao').select2({
					theme: 'bootstrap4',
					placeholder: 'Selecione as áreas para distribuição da orientação...',
					allowClear: true // Opcional - permite desmarcar a seleção
				});

				// Monitora o select de distribuição para permitir a seleção de até 4 órgãos
				// Monitora o evento de mudança no elemento com id "pcOrgaoRespDistribuicao"
				$('#pcOrgaoRespDistribuicao').on('change', function(e) {
					var selectedOptions = $(this).val();
					var maxAllowedOptions = 4;

					if ((!e.ctrlKey && selectedOptions.length > maxAllowedOptions) || (e.ctrlKey && selectedOptions.length >= maxAllowedOptions)) {
						// Desabilita as opções não selecionadas se exceder o limite
						$(this).find('option:not(:selected)').prop('disabled', true);

						// Verifica se excedeu o limite após o change
						if (selectedOptions.length > maxAllowedOptions) {
							// Remove a última opção selecionada
							var lastSelectedOption = selectedOptions[selectedOptions.length - 1];
							$(this).find('option[value="' + lastSelectedOption + '"]').prop('selected', false);

							// Exibe um alerta
							Swal.fire({
								title: 'Você não pode selecionar mais do que ' + maxAllowedOptions + ' áreas.',
								html: logoSNCIsweetalert2(''),
								icon: 'error'
							});
						}
					} else {
						// Ativa todas as opções
						$(this).find('option').prop('disabled', false);
					}

					$(this).trigger('change.select2');
				});

				

				$('#custom-tabs-one-InfProcesso-tab').click(function() {
					$('html, body').animate({ scrollTop: ($('#custom-tabs-one-InfProcesso-tab').offset().top)-60} , 1000);
				});
				$('#custom-tabs-one-InfItem-tab').click(function() {
					$('html, body').animate({ scrollTop: ($('#custom-tabs-one-InfItem-tab').offset().top)-60} , 1000);
				});
				$('#custom-tabs-one-Avaliacao-tab').click(function() {
					$('html, body').animate({ scrollTop: ($('#custom-tabs-one-Avaliacao-tab').offset().top)-60} , 1000);
				});
				$('#custom-tabs-one-Anexos-tab').click(function() {
					$('html, body').animate({ scrollTop: ($('#custom-tabs-one-Anexos-tab').offset().top)-60} , 1000);
				});

			
				$('#tab-responder').click(function() {
					$('html, body').animate({ scrollTop: ($('#tab-responder').offset().top)-60} , 1000);
				});

				$('#tab-distribuicao').click(function() {
					$('html, body').animate({ scrollTop: ($('#tab-distribuicao').offset().top)-60} , 1000);
				});
				
			})

			$('#btEnviarDistribuicaoMelhoria').on('click', function (event)  {
				event.preventDefault()
				event.stopPropagation()
				<cfoutput>
					var idMelhoria = #arguments.idMelhoria#;
				</cfoutput>	
                
				if ($('#pcOrgaoRespDistribuicao').val().length == 0){
					Swal.fire({
								title: 'Informe, pelo menos, uma área para distribuição.',
								html: logoSNCIsweetalert2(''),
								icon: 'error'
							});
					return false;
				}

				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2("Deseja distribuir a Proposta de Melhoria para as áreas selecionadas?"),
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!',
					}).then((result) => {
						if (result.isConfirmed) {
							$('#modalOverlay').modal('show');
							setTimeout(function() {
								//inicio ajax
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method: "distribuirMelhoria",
										pc_aval_melhoria_id: idMelhoria,
										pcAreasDistribuir: $('#pcOrgaoRespDistribuicao').val().join(',')
									},
									async: false
								})//fim ajax
								.done(function(result) {
									
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#informacoesItensAcompanhamentoDiv').html('')
										exibirTabelaMelhoriasPendentes()
										$('#custom-tabs-one-MelhoriaAcomp-tab').html("PROPOSTAS DE MELHORIA");
										$('html, body').animate({ scrollTop: ($('#custom-tabs-one-tabAcomp').offset().top)} , 500);	
										toastr.success('Distribuição realizada com sucesso!');
									});
									
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								})//fim fail
							}, 1000);		
						} else if (result.dismiss === Swal.DismissReason.cancel) {
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					})//fim sweetalert2		

			});


		</script>

    </cffunction>







	<cffunction name="cadMelhoriasPosic"   access="remote"  returntype="any" hint="cadastra os posicionamentos dos órgãos sobre as propostas de melhoria">
		
		<cfargument name="pc_aval_id" type="numeric" required="true"/>
		<cfargument name="pc_aval_melhoria_id" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_dataPrev" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_sugestao" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_naoAceita_justif" type="string" required="false" default=""/>
		<cfargument name="pc_aval_melhoria_status" type="string"  required="false"  default=""/>
		

		<cfquery datasource="#application.dsn_processos#" >
			UPDATE pc_avaliacao_melhorias
			SET 				
				pc_aval_melhoria_sugestao = <cfqueryparam value="#arguments.pc_aval_melhoria_sugestao#" cfsqltype="cf_sql_varchar">,
				pc_aval_melhoria_naoAceita_justif = <cfqueryparam value="#arguments.pc_aval_melhoria_naoAceita_justif#" cfsqltype="cf_sql_varchar">,
				pc_aval_melhoria_sug_matricula = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
				pc_aval_melhoria_status = <cfqueryparam value="#arguments.pc_aval_melhoria_status#" cfsqltype="cf_sql_varchar">,
				pc_aval_melhoria_sug_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
				<cfif '#arguments.pc_aval_melhoria_dataPrev#' neq "">
					pc_aval_melhoria_dataPrev = <cfqueryparam value="#arguments.pc_aval_melhoria_dataPrev#" cfsqltype="cf_sql_date">
				<cfelse>
					pc_aval_melhoria_dataPrev = null
				</cfif>
			WHERE  pc_aval_melhoria_id = <cfqueryparam value="#arguments.pc_aval_melhoria_id#" cfsqltype="cf_sql_numeric">	
		</cfquery>

					
  	</cffunction>




	<cffunction name="timelineViewAcomp"   access="remote" hint="enviar o componente timeline dos processos em acompanhamento para a páginas pc_Acompanhamento chama pela função tabAvaliacoesAcompanhamento">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />

		<cfquery name="rsProc" datasource="#application.dsn_processos#">

			SELECT  pc_processos.*
			,pc_avaliacoes.*
			,pc_orgaos.pc_org_descricao           AS descOrgAvaliado
			,pc_orgaos.pc_org_mcu                 AS mcuAvaliado
			,pc_orgaos.pc_org_sigla               AS siglaOrgAvaliado
			,pc_orgaos.pc_org_se_sigla            AS seOrgAvaliado
			,pc_orgaos_1.pc_org_descricao         AS descOrgOrigem
			,pc_orgaos_1.pc_org_sigla             AS siglaOrgOrigem
			,pc_orgao_OrientacaoResp.pc_org_sigla AS orgaoRespOrientacao
			,pc_orgao_OrientacaoResp.pc_org_mcu   AS mcuOrgaoRespOrientacao
			,pc_avaliacao_tipos.pc_aval_tipo_descricao
			,pc_aval_orientacao_status
			,pc_classificacoes.pc_class_descricao
			,pc_avaliacao_orientacoes.*
			,pc_status.*
			,pc_orientacao_status.pc_orientacao_status_finalizador AS statusFinalizador	
			FROM pc_processos
			INNER JOIN pc_avaliacoes						ON pc_processo_id = pc_aval_processo
			INNER JOIN pc_avaliacao_tipos 					ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
			INNER JOIN pc_orgaos 							ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu
			INNER JOIN pc_status 							ON pc_processos.pc_num_status = pc_status.pc_status_id
			INNER JOIN pc_orgaos AS pc_orgaos_1 			ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu
			INNER JOIN pc_classificacoes 					ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
			RIGHT JOIN pc_avaliacao_orientacoes         	ON pc_aval_orientacao_num_aval = pc_aval_id
			INNER JOIN pc_orgaos AS pc_orgao_OrientacaoResp	ON pc_orgao_OrientacaoResp.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
			INNER JOIN pc_orientacao_status 				ON pc_aval_orientacao_status = pc_orientacao_status.pc_orientacao_status_id
			
			WHERE pc_aval_orientacao_id  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">

		</cfquery>		

		<cfquery name="rsSe_Area" datasource="#application.dsn_processos#">
			SELECT pc_orgaos.pc_org_mcu, pc_orgaos.pc_org_sigla
			FROM pc_orgaos
			WHERE pc_org_controle_interno ='N' AND (pc_org_Status = 'A') 
				  AND (pc_org_mcu_subord_tec = '#rsProc.mcuAvaliado#' or pc_org_mcu = '#rsProc.mcuAvaliado#' or pc_org_mcu_subord_tec in 
						(SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_controle_interno ='N' AND pc_org_mcu_subord_tec = '#rsProc.mcuAvaliado#')
					  )
			ORDER BY pc_org_sigla
		</cfquery>

		<cfset areasDaSE= valueList(rsSe_Area.pc_org_mcu) >

		<cfquery name="rsAreasTodas" datasource="#application.dsn_processos#">
			SELECT pc_orgaos.pc_org_mcu, pc_orgaos.pc_org_sigla
			FROM pc_orgaos
			WHERE pc_org_controle_interno ='N' AND pc_org_Status = 'A' and not pc_org_mcu in (<cfqueryparam cfsqltype="cf_sql_string" value="#areasDaSE#" list="true">)
			ORDER BY pc_org_sigla
		</cfquery>

		<cfquery name="rsAreasUnion"  dbtype="query">
			Select rsSe_Area.* from rsSe_Area union all select rsAreasTodas.* from rsAreasTodas
		</cfquery>

		<!--- Chama o componente timelineViewPosicionamentos em pc_cfcComponenteTimelinePosicionamentos.cfc --->
		<cfinvoke component="pc_cfcComponenteTimelinePosicionamentos" method="timelineViewPosicionamentos" returnvariable="timelineCI">
			<cfinvokeargument name="pc_aval_orientacao_id" value="#arguments.pc_aval_orientacao_id#">
			<cfinvokeargument name="paraControleInterno" value="S">
		</cfinvoke>

			
			
		<div id="accordionCadItemPainel" style="margin-top:30px;hright:100vh">
			<div class="card card-success" style="margin-bottom:10px">
				<div class="card-header" style="background-color:#ececec;">
					<h4 class="card-title ">
						<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:16px;color:gray;font-weight: bold;"> 
							<i class="fas fa-user-pen" style="margin-top:4px;font-size: 20px;"></i><span style="margin-left:5px">INSERIR MANIFESTAÇÃO DO CONTROLE INTERNO</span>
						</a>
					</h4>
				</div>
				<div id="collapseTwo" class="" data-parent="#accordion">
					<div class="card-body" >
					<div class="tab-content" id="custom-tabs-one-tabContent">
						<!--Editor-->
						
						<!--Fim Editor-->
					</div> 
				</div>
				<cfquery datasource="#application.dsn_processos#" name="rsManifestacaoSalva">
					Select pc_avaliacao_posicionamentos.*, pc_orgaos.pc_org_sigla, pc_usuarios.pc_usu_nome FROM pc_avaliacao_posicionamentos 
					INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_posic_num_orgao
					INNER JOIN pc_usuarios on pc_usu_matricula = pc_aval_posic_matricula
					WHERE pc_aval_posic_num_orientacao = #rsProc.pc_aval_orientacao_id# and pc_aval_posic_enviado = 0
				</cfquery>
				<div class="row" style="margin-left:8px;margin-right:8px;margin-top:-30px;font-size:16px">
					<div class="col-sm-12">
						<div class="form-group">
							<cfif rsProc.pc_num_status neq 6>
								<div id="divTextoPosicSalvo"></div>
								<textarea class="form-control" id="pcPosicAcomp" rows="3" required="" style=""  name="pcPosicAcomp" class="form-control" placeholder="Digite aqui a manifestação do Controle Interno..." ><cfoutput>#rsManifestacaoSalva.pc_aval_posic_texto#</cfoutput></textarea>
							<cfelse>
								<h6 style="color:red;">ORIENTAÇÃO BLOQUEADA. NÃO É PERMITIDO MANIFESTAÇÃO.</h6>
							</cfif>
						</div>										
					</div>
					<cfquery datasource="#application.dsn_processos#" name="rsOrientacaoStatus">
						SELECT pc_orientacao_status.pc_orientacao_status_id,pc_orientacao_status.pc_orientacao_status_descricao  
						FROM pc_orientacao_status 
						WHERE (pc_orientacao_status_id in(5,16) OR pc_orientacao_status_finalizador = 'S' ) and pc_orientacao_status_status = 'A'
						order by pc_orientacao_status_id  asc
					</cfquery>

					<cfquery datasource="#application.dsn_processos#" name="rsUltimaDataPrevistaResp">
						Select TOP 1 pc_aval_posic_dataPrevistaResp as ultimaDataPrevistaResp, pc_aval_posic_status 
						from pc_avaliacao_posicionamentos
						WHERE pc_aval_posic_num_orientacao = #rsProc.pc_aval_orientacao_id# 
								AND pc_aval_posic_status in (2,4,5) and pc_aval_posic_num_orgaoResp = '#rsProc.mcuOrgaoRespOrientacao#'
						order by pc_aval_posic_id desc
					</cfquery>
					<cfif rsProc.pc_num_status neq 6>
						<div class="col-sm-3" >
							<div class="form-group">
								<label for="pcOrientacaoStatus">Status</label>
								<select id="pcOrientacaoStatus" required="" name="pcOrientacaoStatus" class="form-control" style="height:35px">
									<option selected=""  value="">Selecione o status...</option>
									<!--<cfif #rsUltimaDataPrevistaResp.ultimaDataPrevistaResp# lt DATEFORMAT(Now(),"yyyy-mm-dd") and #rsUltimaDataPrevistaResp.pc_aval_posic_status# neq 4>
										<option value="5" selected>PENDENTE</option>		
									</cfif>-->
									<cfoutput query="rsOrientacaoStatus">
										<cfif rsManifestacaoSalva.recordcount eq 0>
											<option value="#pc_orientacao_status_id#" <cfif pc_orientacao_status_id eq 5>selected</cfif>>#pc_orientacao_status_descricao#</option>
										<cfelse>
											<option value="#pc_orientacao_status_id#" <cfif pc_orientacao_status_id eq rsManifestacaoSalva.pc_aval_posic_status>selected</cfif>>#pc_orientacao_status_descricao#</option>
										</cfif>
									</cfoutput>
								</select>
							</div>
						</div>
						<!--Ultimo órgão responsálvel da tabela pc_avaliacao_posicionamentos-->
						<cfquery datasource="#application.dsn_processos#" name="rsUltimoOrgaoResp">
							Select TOP 1 pc_aval_posic_num_orgaoResp as ultimoOrgaoResp 
							from pc_avaliacao_posicionamentos
							INNER JOIN pc_orientacao_status ON pc_orientacao_status.pc_orientacao_status_id = pc_avaliacao_posicionamentos.pc_aval_posic_status
							INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_avaliacao_posicionamentos.pc_aval_posic_num_orgaoResp
						
							WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
									AND not pc_aval_posic_num_orgaoResp is null AND pc_org_controle_interno = 'N' 
							
							order by pc_aval_posic_id desc
						</cfquery>

						<div id ="pcOrgaoRespAcompDiv" class="col-sm-4" hidden>
							<div class="form-group">
								
								<label for="pcOrgaoRespAcomp">Órgão:</label>
								<select id="pcOrgaoRespAcomp" required="" name="pcOrgaoRespAcomp" class="form-control" style="height:35px">
									<option selected=""  value="">Selecione o Órgão p/ envio...</option>
									
									<cfoutput query="rsAreasUnion">
										<cfif rsManifestacaoSalva.recordcount eq 0>
											<option <cfif '#pc_org_mcu#' eq '#rsproc.mcuOrgaoRespOrientacao#'>selected</cfif> value="#pc_org_mcu#">#pc_org_sigla# (#pc_org_mcu#)</option>
										<cfelse>
											<option <cfif '#pc_org_mcu#' eq rsManifestacaoSalva.pc_aval_posic_num_orgaoResp>selected</cfif> value="#pc_org_mcu#">#pc_org_sigla# (#pc_org_mcu#)</option>
										</cfif>
										<!-- Se o status da orientação for "EM ANÁLISE" ou se o status for finalizador, mostra o último órgão responsável pela última manifestação.-->
										<cfif rsProc.pc_aval_orientacao_status eq 13 or rsProc.statusFinalizador eq 'S'>
											<option <cfif '#pc_org_mcu#' eq '#rsUltimoOrgaoResp.ultimoOrgaoResp#'>selected</cfif> value="#pc_org_mcu#">#pc_org_sigla# (#pc_org_mcu#)</option>
										</cfif>
											
									</cfoutput>


								</select>
							</div>
						</div>
						<div id ="pcDataPrevRespAcompDiv" class="col-md-2" hidden>
							<div class="form-group">
								<label for="pcDataPrevRespAcomp">Prazo Resposta:</label>
								<div class="input-group date" id="reservationdate" data-target-input="nearest">
									<input id="pcDataPrevRespAcomp"  name="pcDataPrevRespAcomp" required=""  type="date" class="form-control" placeholder="dd/mm/aaaa" style="height:35px"> 
								</div>
							</div>
							<span id="dataPrevistaCalculada" style='font-size:11px;color:blue'></span>
						</div>
						<div id ="pcNumProcJudicialDiv" class="col-md-3" hidden>
							<div class="form-group">
								<label for="pcNumProcJudicial">N° Processo Judicial:</label>
								<input id="pcNumProcJudicial"  name="pcNumProcJudicial" required="" class="form-control" style="height:35px">
							</div>
						</div>
						
					</div>
				
					<!--ANEXOS -->
					<div class="row">
						<div class="col-md-12">
							<div class="card card-default">
								
								<div class="card-body">
									<div id="actions" class="row" >
										<div class="col-lg-12" align="left">
											<div class="btn-group w-30">
													<cfif directoryExists(application.diretorio_anexos)>
														<span id="anexosAcomp" class="btn btn-success col fileinput-button" style="background:#0083CA">
															<i class="fas fa-upload"></i>
															<span style="margin-left:5px">Clique aqui para anexar um documento (PDF, EXCEL ou ZIP)</span>
														</span>
													</cfif>
												
											</div>
										</div>
									</div>
									
									<div class="table table-striped files" id="previewsAcomp">
									<div id="templateAcomp" class="row mt-2">
										<div class="col-auto">
											<span class="preview"><img src="data:," alt="" data-dz-thumbnail /></span>
										</div>
										<div class="col d-flex align-items-center">
											<p class="mb-0">
											<span class="lead" data-dz-name></span>
											(<span data-dz-size></span>)
											</p>
											<strong class="error text-danger" data-dz-errormessage></strong>
										</div>
										<div class="col-4 d-flex align-items-center" >
											<div class="progress progress-striped active w-100" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" >
												<div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress ></div>
											</div>
										</div>
										
									</div>
								</div>
								
									<div id="tabAnexosAcompDiv" style="margin-top:30px;margin-bottom:50px"></div>
								
								
							</div>
							
							</div>
							<!-- /.card -->
						</div>
						
					</div>
					<!--FIM ANEXOS-->
				
				
					<div id = "divBtSalvarEnviar"style="justify-content:center; display: flex; width: 100%;margin-bottom:50px;border-top:1px solid #ced4da; padding:20px">
						<div class="form-group" style="margin-right:150px;">
							<button id="btSalvar" class="btn btn-block btn-primary " style="background-color: #28a745;"> <i class="fas fa-floppy-disk" style="margin-right:5px"></i>Salvar manifestação p/ envio posterior</button>
						</div>
						<div class="form-group">
							<button id="btEnviar" class="btn btn-block btn-primary " > <i class="fas fa-share-from-square" style="margin-right:5px"></i>Enviar manifestação agora</button>
						</div>
					</div>

				</cfif>
			</div>

			
		</div>
			


		<script language="JavaScript">
		   
				
			 //Initialize Select2 Elements
			 // Seleciona os elementos <select> pelos IDs desejados e aplica o Select2
			$('#pcOrientacaoStatus, #pcOrgaoRespAcomp').select2({
				theme: 'bootstrap4',
				placeholder: 'Selecione...'
			});
			
		
		   


			$(document).ready(function() {
				

				var dataPrev = '';
				var dataPrevista='';
				var dataPrevistaFormatada ='';
				if($('#pcOrientacaoStatus').val() == 5){
					<cfoutput>
						<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio"/>
						<cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias='15' />
						dataPrev = new Date('#dateFormat(obterDataPrevista.Data_Prevista, "yyyy-mm-dd")#');
						dataPrevista = dataPrev.toISOString().split('T')[0];
						dataPrevistaFormatada = '#obterDataPrevista.Data_Prevista_Formatada#';
					</cfoutput>
				} 
				
				if($('#pcOrientacaoStatus').val() == 16){
					    dataPrevista  = new Date();
						dataPrevista.setDate(dataPrevista .getDate() + 90);
						// Obter o ano, mês e dia
						var ano = dataPrevista.getFullYear();
						var mes = (dataPrevista.getMonth() + 1).toString().padStart(2, '0'); // +1 porque o mês é baseado em zero
						var dia = dataPrevista.getDate().toString().padStart(2, '0');
						// Criar a string no formato yyyy-mm-dd
						dataPrevista = ano + '-' + mes + '-' + dia;
						dataPrevistaFormatada = dia + '/' + mes + '/' + ano;
				}	
				
				<cfoutput>
                    var manifestacaoSalva = '#rsManifestacaoSalva.recordcount#';
					var numProcJudicial = '#rsManifestacaoSalva.pc_aval_posic_numProcJudicial#';
				</cfoutput>

				if(manifestacaoSalva === '0'){
					$('#pcOrientacaoStatus').val(5)
					$("#pcOrgaoRespAcompDiv").attr("hidden",false)
					$("#pcDataPrevRespAcompDiv").attr("hidden",false)	
					$("#pcDataPrevRespAcomp").val(dataPrevista)
					$("#dataPrevistaCalculada").html("Prazo de 15 dias úteis: " + dataPrevistaFormatada + "</br>");

				}else{
					if ($('#pcOrientacaoStatus').val() == 5){
						$("#pcOrgaoRespAcompDiv").attr("hidden",false)	
						$("#pcDataPrevRespAcompDiv").attr("hidden",false)
						$("#pcNumProcJudicialDiv").attr("hidden",true)
						$("#pcDataPrevRespAcomp").val(dataPrevista)
						$("#pcNumProcJudicial").val(null)
						$("#dataPrevistaCalculada").html("Prazo de 15 dias úteis: " + dataPrevistaFormatada + "</br>");
					}else if ($('#pcOrientacaoStatus').val() == 15){
						$("#pcNumProcJudicialDiv").attr("hidden",false)
						$("#pcDataPrevRespAcompDiv").attr("hidden",true)
						$("#pcOrgaoRespAcompDiv").attr("hidden",true)
						$("#pcDataPrevRespAcomp").val(null)	
						$("#pcNumProcJudicial").val(numProcJudicial)
						//$("#pcPosicAcomp").prop("disabled", true);
					}else if ($('#pcOrientacaoStatus').val() == 16){
						$("#pcOrgaoRespAcompDiv").attr("hidden",false)	
						$("#pcDataPrevRespAcompDiv").attr("hidden",false)
						$("#pcNumProcJudicialDiv").attr("hidden",true)
						$("#pcDataPrevRespAcomp").val(dataPrevista)
						$("#pcNumProcJudicial").val(null)
						$("#dataPrevistaCalculada").html("Prazo de 90 dias corridos: " + dataPrevistaFormatada + "</br>");
						$("#pcPosicAcomp").prop("disabled", true);
					}else{
						$("#pcDataPrevRespAcompDiv").attr("hidden",true)
						$("#pcOrgaoRespAcompDiv").attr("hidden",true)
						$("#pcNumProcJudicialDiv").attr("hidden",true)
						$("#pcDataPrevRespAcomp").val(null)	
						$("#pcNumProcJudicial").val(null)	
					}

				}
					
					
					

				

				mostraTabAnexosOrientacoes();

				<cfoutput>
					var pc_anexo_avaliacao_id = '#rsProc.pc_aval_id#';
					var pc_anexo_orientacao_id = '#rsProc.pc_aval_orientacao_id#';
					var pc_aval_processo = '#rsProc.pc_processo_id#';
				</cfoutput>
				mostraDataHoraPosicSalvo(pc_anexo_orientacao_id)
				
				// DropzoneJS 2 Demo Code Start
				Dropzone.autoDiscover = false

				// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
				var previewNode = document.querySelector("#templateAcomp")
				previewNode.id = ""
				var previewTemplate = previewNode.parentNode.innerHTML
				previewNode.parentNode.removeChild(previewNode)

				var myDropzoneAcomp = new Dropzone("div#tabAnexosAcompDiv", { // Make the whole body a dropzone
					url: "cfc/pc_cfcAcompanhamentos.cfc?method=uploadArquivosOrientacao", // Set the url
					autoProcessQueue :true,
					thumbnailWidth: 80,
					thumbnailHeight: 80,
					parallelUploads: 1,
					maxFilesize:4,
					acceptedFiles: '.pdf,.xls,.xlsx,.zip',
					previewTemplate: previewTemplate,
					autoQueue: true, // Make sure the files aren't queued until manually added
					previewsContainer: "#previewsAcomp", // Define the container to display the previews
					clickable: "#anexosAcomp", // Define the element that should be used as click trigger to select files.
					headers: {"pc_anexo_orientacao_id":pc_anexo_orientacao_id,
							  "pc_anexo_avaliacao_id":pc_anexo_avaliacao_id,
							  "pc_aval_processo":pc_aval_processo} , 							
					init: function() {
						this.on('error', function(file, errorMessage) {	
							toastr.error(errorMessage);
						});
					}
					
				})

				

				// Update the total progress bar
				// myDropzoneAcomp.on("totaluploadprogress", function(progress) {
				// 	document.querySelector(".progress-bar").style.width = progress + "%"
				// })

				myDropzoneAcomp.on("sending", function(file) {
					$('#modalOverlay').modal('show')
				})

				// Hide the total progress bar when nothing's uploading anymore
				myDropzoneAcomp.on("queuecomplete", function(progress) {
					mostraTabAnexosOrientacoes();
					mostraTabAnexos();
					
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
					});
					myDropzoneAcomp.removeAllFiles(true);
					
				})

			

				
				
				// DropzoneJS Demo Code End

		})


			

			$('#pcOrientacaoStatus').on('change', function (event)  {
				
				var dataPrev = '';
				var dataPrevista='';
				var dataPrevistaFormatada ='';
				if($('#pcOrientacaoStatus').val() == 5){
					<cfoutput>
						<cfobject component = "pc_cfcPaginasApoio" name = "pc_cfcPaginasApoio"/>
						<cfinvoke component="#pc_cfcPaginasApoio#" method="obterDataPrevista" returnVariable="obterDataPrevista" qtdDias='15' />
						dataPrev = new Date('#dateFormat(obterDataPrevista.Data_Prevista, "yyyy-mm-dd")#');
						dataPrevista = dataPrev.toISOString().split('T')[0];
						dataPrevistaFormatada = '#obterDataPrevista.Data_Prevista_Formatada#';
					</cfoutput>
				} 
				if($('#pcOrientacaoStatus').val() == 16){
					    dataPrevista  = new Date();
						dataPrevista.setDate(dataPrevista .getDate() + 90);
						// Obter o ano, mês e dia
						var ano = dataPrevista.getFullYear();
						var mes = (dataPrevista.getMonth() + 1).toString().padStart(2, '0'); // +1 porque o mês é baseado em zero
						var dia = dataPrevista.getDate().toString().padStart(2, '0');
						// Criar a string no formato yyyy-mm-dd
						dataPrevista = ano + '-' + mes + '-' + dia;
						dataPrevistaFormatada = dia + '/' + mes + '/' + ano;
				}	
				 
				
				
                
				if ($('#pcOrientacaoStatus').val() == 5){
					$("#pcOrgaoRespAcompDiv").attr("hidden",false)	
					$("#pcDataPrevRespAcompDiv").attr("hidden",false)
					$("#pcNumProcJudicialDiv").attr("hidden",true)
					$("#pcDataPrevRespAcomp").val(dataPrevista)
					$("#dataPrevistaCalculada").html("Prazo de 15 dias corridos: " + dataPrevistaFormatada + "</br>");
					$("#pcNumProcJudicial").val(null)
						
				}else if ($('#pcOrientacaoStatus').val() == 15){
					$("#pcNumProcJudicialDiv").attr("hidden",false)
					$("#pcDataPrevRespAcompDiv").attr("hidden",true)
					$("#pcOrgaoRespAcompDiv").attr("hidden",true)
					$("#pcDataPrevRespAcomp").val(null)	
					$("#pcPosicAcomp").val('Orientação baixada para efeitos de acompanhamento no Sistema SNCI – Módulo Acompanhamento de Processos, tendo em vista a existência de Processo Judicial relacionado ao tema. Caso sejam identificados mais de um processo judicial relacionado ao tema, registrar os números nesta manifestação e indicar no campo "N° Processo Judicial" a mensagem: "Diversos (números registrados na manifestação)".')
					//$("#pcPosicAcomp").prop("disabled", true);
												
				}else if ($('#pcOrientacaoStatus').val() == 16){
					$("#pcOrgaoRespAcompDiv").attr("hidden",false)	
					$("#pcDataPrevRespAcompDiv").attr("hidden",false)
					$("#pcNumProcJudicialDiv").attr("hidden",true)
					$("#pcDataPrevRespAcomp").val(dataPrevista)
					$("#dataPrevistaCalculada").html("Prazo de 90 dias corridos: " + dataPrevistaFormatada + "</br>");
					$("#pcNumProcJudicial").val(null)	
					$("#pcPosicAcomp").val('Orientação suspensa por 90 (noventa) dias corridos para aguardar as tratativas dos Correios com o órgão externo, conforme registrado no histórico das manifestações. O Módulo de Acompanhamento de Processos - SNCI permite ao órgão responsável inserir manifestação antes do prazo, é só acessar a tela "Acompanhamento", localizar a orientação desejada e inserir a manifestação normalmente.')
					$("#pcPosicAcomp").prop("disabled", true);

				}else{
					$("#pcDataPrevRespAcompDiv").attr("hidden",true)
					$("#pcOrgaoRespAcompDiv").attr("hidden",true)
					$("#pcNumProcJudicialDiv").attr("hidden",true)
					$("#pcDataPrevRespAcomp").val(null)	
					$("#pcNumProcJudicial").val(null)
						
				}

				if($('#pcOrientacaoStatus').val() != 15 && $('#pcOrientacaoStatus').val() != 16){
					if ($("#pcPosicAcomp").prop("disabled") === true) {
						$("#pcPosicAcomp").val(null);
					}
					$("#pcPosicAcomp").prop("disabled", false);
				}

				

			})

			$('#btSalvar').on('click', function (event)  {
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()

				const idAnexos = []; // Array para armazenar os valores da coluna ID da tabela anexos
				if ($(".idColumn").length > 0) {
					// Iterar sobre cada elemento da coluna ID
					$(".idColumn").each(function() {
						var idValue = $(this).text();
						idAnexos.push(idValue);
					});
				}
				var idAnexosString = idAnexos.join(","); // Converta o array para uma string de IDs separados por vírgula
				
				//verifica se os campos necessários foram preenchidos
				if (
					!$('#pcPosicAcomp').val() 
				)
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Informe o texto da manifestação.');
					return false;
				}

				
				<cfoutput>let dataRespValidacao = '#rsUltimaDataPrevistaResp.ultimaDataPrevistaResp#';</cfoutput>
				

				var mensagem = "Deseja salvar esta manifestação?"
				
							
				<cfoutput>
					var pc_aval_orientacao_id = '#arguments.pc_aval_orientacao_id#'; 
				</cfoutput>

				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem), 


					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {	
							setTimeout(function() {	
								$('#modalOverlay').modal('show');
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method:"salvarPosic",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:$('#pcOrientacaoStatus').val(),
										pc_aval_posic_num_orgaoResp: $('#pcOrgaoRespAcomp').val(),
										pc_aval_posic_numProcJudicial: $('#pcNumProcJudicial').val(),
										idAnexos: idAnexosString
									},
						
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#modalOverlay').delay(1000).hide(0, function() {
										mostraDataHoraPosicSalvo(pc_aval_orientacao_id)
										$('#modalOverlay').modal('hide');
										toastr.success('Manifestação e anexo(s) salvos com sucesso!');
									});			

								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});	
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								});//fim fail
							}, 500);
						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					})

			});		

			$('#btEnviar').on('click', function (event)  {
				
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()

				const idAnexos = []; // Array para armazenar os valores da coluna ID da tabela anexos
				if ($(".idColumn").length > 0) {
					// Iterar sobre cada elemento da coluna ID
					$(".idColumn").each(function() {
						var idValue = $(this).text();
						idAnexos.push(idValue);
					});
				}
				var idAnexosString = idAnexos.join(","); // Converta o array para uma string de IDs separados por vírgula


				//verifica se os campos necessários foram preenchidos
				if (
					!$('#pcPosicAcomp').val() ||
					!$('#pcOrientacaoStatus').val()
				)
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}

				if (
					$('#pcOrientacaoStatus').val() == 5 && $('#pcOrientacaoStatus option:selected').text() =='TRATAMENTO' &&
					(!$('#pcDataPrevRespAcomp').val()||
					!$('#pcOrgaoRespAcomp').val())
				){   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}
				



				<cfoutput>let dataRespValidacao = '#rsUltimaDataPrevistaResp.ultimaDataPrevistaResp#';</cfoutput>
				if (
					
					$('#pcOrientacaoStatus').val() == 5 && $('#pcOrientacaoStatus option:selected').text() =='PENDENTE' & dataRespValidacao == '' &&
					(!$('#pcDataPrevRespAcomp').val() ||	!$('#pcOrgaoRespAcomp').val())
					){   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}

				if ($('#pcOrientacaoStatus').val() == 15 && !$('#pcNumProcJudicial').val()){
					toastr.error('Informe o N° do Processo Judicial!');
					return false;	
				}

				if ($('#pcOrientacaoStatus').val() == 16 && (!$('#pcDataPrevRespAcomp').val() || $('#pcOrgaoRespAcomp').val().length==0)){	//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}

				
				var mensagem = "Deseja enviar esta manifestação?"
				
							
				<cfoutput>
					var pc_aval_id = '#rsProc.pc_aval_id#';
					var pc_aval_orientacao_id = '#arguments.pc_aval_orientacao_id#'; 
					var numProcesso = "#rsProc.pc_processo_id#";
				</cfoutput>
				
				if ($('#pcOrientacaoStatus').val() == 5 || $('#pcOrientacaoStatus').val() == 16){//se a o status escolhido for tratamento ou Ponto Suspenso
					var dataResp = $('#pcDataPrevRespAcomp').val();
					swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'  
					}).then((result) => {
						if (result.isConfirmed) {	
							setTimeout(function() {	
								$('#modalOverlay').modal('show');	
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method:"cadPosicControleInterno",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:$('#pcOrientacaoStatus').val(),
										pc_aval_orientacao_mcu_orgaoResp: $('#pcOrgaoRespAcomp').val(),
										pc_aval_orientacao_dataPrevistaResp: dataResp,
										idAnexos: idAnexosString
									},
						
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#pcPosicAcomp').val('')
									$('#pcOrgaoRespAcomp').val(''),
									$('#pcDataPrevRespAcomp').val('')
									
								
									exibirTabela()
									$('#informacoesItensAcompanhamentoDiv').html('')
									$('#timelineViewAcompDiv').html('')

									
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});			

								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});	
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								});//fim fail
							}, 500);
						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					})
				}else{
					swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {
							setTimeout(function() {	
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method:"cadPosicControleInterno",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:$('#pcOrientacaoStatus').val(),
										pc_aval_orientacao_mcu_orgaoResp: $('#pcOrgaoRespAcomp').val(),
										pc_aval_orientacao_numProcJudicial: $('#pcNumProcJudicial').val(),
										idAnexos: idAnexosString
									},
						
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#pcPosicAcomp').val('')
									$('#pcOrgaoRespAcomp').val(''),
									$('#pcDataPrevRespAcomp').val('')
									
									exibirTabela()
									$('#informacoesItensAcompanhamentoDiv').html('')
									$('#timelineViewAcompDiv').html('')

									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});			

								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});	
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								});//fim fail
							}, 500);	
						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					})
				}	

			});

			function mostraTabAnexosOrientacoes(){
				
				<cfoutput>
					var  pc_orientacao_id = '#rsProc.pc_aval_orientacao_id#';
				</cfoutput>
				setTimeout(function() {
					$.ajax({
							type: "post",
							url: "cfc/pc_cfcAvaliacoes.cfc",
							data:{
								method: "tabAnexosOrientacoes",
								pc_orientacao_id: pc_orientacao_id
							},
							async: false
						})//fim ajax
						.done(function(result) {
							
							$('#tabAnexosAcompDiv').html(result)
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
				
							});	
						})//fim done
						.fail(function(xhr, ajaxOptions, thrownError) {
							$('#modalOverlay').delay(1000).hide(0, function() {
								$('#modalOverlay').modal('hide');
							});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)

						});//fim fail
					}, 500);

			}
			

			function exibirTabela(){
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "tabAcompanhamento",
						},
						async: false,
						success: function(result) {
							$('#exibirTab').html(result)
							
						},
						error: function(xhr, ajaxOptions, thrownError) {
							//$('#modalOverlay').delay(1000).hide(0, function() {
								//$('#modalOverlay').modal('hide');
							//});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)
						}
					});
				}, 500);
				
					
				

			}

			function mostraDataHoraPosicSalvo(pc_aval_orientacao_id){
								
				$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "dataHoraPosicSalvo",
							pc_aval_orientacao_id: pc_aval_orientacao_id
						},
						async: true
					})//fim ajax
					.done(function(result) {
						$('#divTextoPosicSalvo').html(result)
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					});//fim fail
					

			}

		
			
				
			
		</script>





	</cffunction>





	<cffunction name="timelineViewAcompOrgaoAvaliado"   access="remote" hint="enviar o componente timeline dos processos em acompanhamento para a páginas pc_Acompanhamento chama pela função tabAvaliacoesAcompanhamento">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />

		<!--- Chama o componente timelineViewPosicionamentos em pc_cfcComponenteTimelinePosicionamentos.cfc --->
		<cfinvoke component="pc_cfcComponenteTimelinePosicionamentos" method="timelineViewPosicionamentos" returnvariable="timelineOA">
			<cfinvokeargument name="pc_aval_orientacao_id" value="#arguments.pc_aval_orientacao_id#">
			<cfinvokeargument name="paraControleInterno" value="N">
		</cfinvoke>

	</cffunction>



	<cffunction name="formPosicionamentoOrgaoAvaliado"   access="remote" hint="enviar o componente para a páginas pc_Acompanhamento chama pela função tabAvaliacoesAcompanhamento">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />

		
		<cfquery name="rsProc" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_avaliacoes.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_mcu as mcuAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
								pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
								pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
								, pc_classificacoes.pc_class_descricao,  pc_orgaos.pc_org_se_sigla,  pc_orgaos.pc_org_mcu, pc_avaliacao_orientacoes.*,
								pc_orgao_OrientacaoResp.pc_org_sigla as orgaoRespOrientacao, pc_orgao_OrientacaoResp.pc_org_mcu as mcuOrgaoRespOrientacao
								
						

			FROM        pc_processos INNER JOIN
								pc_avaliacoes on pc_processo_id =  pc_aval_processo INNER JOIN
								pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
								pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
								pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
								pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
								pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id right JOIN
								pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id INNER JOIN
								pc_orgaos as pc_orgao_OrientacaoResp on pc_orgao_OrientacaoResp.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
								

			WHERE pc_aval_orientacao_id  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">


		</cfquery>		

			
				<div id="accordionCadItemPainel" style="margin-top:0px;hright:100vh">
					<cfif application.rsOrgaoSubordinados.recordcount neq 0>
						<div  style="margin-bottom:10px">
					<cfelse>
						<div class="card card-success" style="margin-bottom:10px">
							<div class="card-header" style="background-color:#0083CA;">
								<h4 class="card-title ">
									<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:16px;color:#fff;font-weight: bold;"> 
										<i class="fas fa-user-pen" style="margin-top:4px;font-size: 20px;"></i><span style="margin-left:5px">INSERIR MANIFESTAÇÃO DO ÓRGÃO: <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput></span>
									</a>
								</h4>
							</div>	
					</cfif>	
					    <cfquery datasource="#application.dsn_processos#" name="rsManifestacaoSalva">
							Select pc_avaliacao_posicionamentos.*, pc_orgaos.pc_org_sigla, pc_usuarios.pc_usu_nome FROM pc_avaliacao_posicionamentos 
							INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_posic_num_orgao
							INNER JOIN pc_usuarios on pc_usu_matricula = pc_aval_posic_matricula
							WHERE pc_aval_posic_num_orientacao = #rsProc.pc_aval_orientacao_id# and pc_aval_posic_enviado = 0
						</cfquery>
						<div class="row" style="margin-top:20px;margin:8px;font-size:16px">
							<div class="col-sm-12">
								<div class="form-group">
									<div id="divTextoPosicSalvo" ></div>
								    <textarea class="form-control" id="pcPosicAcomp" rows="3" required="" style=""  name="pcPosicAcomp" class="form-control" placeholder="Digite aqui sua manifestação..." ><cfoutput>#rsManifestacaoSalva.pc_aval_posic_texto#</cfoutput></textarea>
								</div>										
							</div>
						</div>

						<!--ANEXOS -->
						<div class="row">
							<div class="col-md-12">
								<div >
									
									<div class="card-body">
										<div id="actions" class="row" >
											<div class="col-lg-12" align="left">
												<div class="btn-group w-30">
												    <cfif directoryExists(application.diretorio_anexos)>
														<span id="anexosAcomp" class="btn btn-success col fileinput-button" style="background:#0083CA">
															<i class="fas fa-upload"></i>
															<span style="margin-left:5px">Clique aqui para anexar um documento (PDF, EXCEL ou ZIP)</span>
														</span>
													</cfif>
												</div>
											</div>
										</div>
										
										<div class="table table-striped files" id="previewsAcomp">
										<div id="templateAcomp" class="row mt-2">
											<div class="col-auto">
												<span class="preview"><img src="data:," alt="" data-dz-thumbnail /></span>
											</div>
											<div class="col d-flex align-items-center">
												<p class="mb-0">
												<span class="lead" data-dz-name></span>
												(<span data-dz-size></span>)
												</p>
												<strong class="error text-danger" data-dz-errormessage></strong>
											</div>
											<div class="col-4 d-flex align-items-center" >
												<div class="progress progress-striped active w-100" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" >
													<div class="progress-bar progress-bar-success" style="width:0%;" data-dz-uploadprogress ></div>
												</div>
											</div>
											
										</div>
									</div>

									
										<div id="tabAnexosAcompDiv" style="margin-top:30px;margin-bottom:50px"></div>
									
									
								</div>
								
								</div>
								<!-- /.card -->
							</div>
							
						</div>
					
						<!--FIM ANEXOS-->
						

						<div style="justify-content:center; display: flex; width: 100%;margin-bottom:50px;border-top:1px solid #ced4da;padding:20px">
							<div class="form-group" style="margin-right:150px;">
								<button id="btSalvar" class="btn btn-block btn-primary " style="background-color: #28a745;"> <i class="fas fa-floppy-disk" style="margin-right:5px"></i>Salvar manifestação p/ envio posterior</button>
							</div>
							<div class="form-group">
								<button id="btEnviar" class="btn btn-block btn-primary " > <i class="fas fa-share-from-square" style="margin-right:5px"></i>Enviar manifestação agora</button>
							</div>
						</div>
					
					</div>

					
				</div>
			

		<script language="JavaScript">

			$(function () {
					// Verifique se a tabela com o ID 'tabAnexosPosic' existe no DOM
				if (document.getElementById('tabAnexosPosic')) {
					$("#tabAnexosPosic").DataTable({
						"destroy": true,
						"stateSave": false,
						"responsive": true, 
						"lengthChange": false, 
						"autoWidth": false,
						"searching": false
					})
				}	
			});
			

			

			$('#pcOrientacaoStatus').on('change', function (event)  {
				if ($('#pcOrientacaoStatus').val() == 5 ){
					$("#pcDataPrevRespAcompDiv").attr("hidden",false)
				}else{
					$("#pcDataPrevRespAcompDiv").attr("hidden",true)	
				}
			})


			$(document).ready(function() {

			
				mostraTabAnexosOrientacoes();
				<cfoutput>
					var pc_anexo_avaliacao_id = '#rsProc.pc_aval_id#';
					var pc_anexo_orientacao_id = '#rsProc.pc_aval_orientacao_id#';
					var pc_aval_processo = '#rsProc.pc_processo_id#';
				</cfoutput>
				mostraDataHoraPosicSalvo(pc_anexo_orientacao_id)
				
				// DropzoneJS 2 Demo Code Start
				Dropzone.autoDiscover = false

				// Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
				var previewNode = document.querySelector("#templateAcomp")
				previewNode.id = ""
				var previewTemplate = previewNode.parentNode.innerHTML
				previewNode.parentNode.removeChild(previewNode)

				var myDropzoneAcomp = new Dropzone("div#tabAnexosAcompDiv", { // Make the whole body a dropzone
					url: "cfc/pc_cfcAcompanhamentos.cfc?method=uploadArquivosOrientacao", // Set the url
					autoProcessQueue :true,
					thumbnailWidth: 80,
					thumbnailHeight: 80,
					parallelUploads: 1,
					maxFilesize:4,
					acceptedFiles: '.pdf,.xls,.xlsx,.zip',
					previewTemplate: previewTemplate,
					autoQueue: true, // Make sure the files aren't queued until manually added
					previewsContainer: "#previewsAcomp", // Define the container to display the previews
					clickable: "#anexosAcomp", // Define the element that should be used as click trigger to select files.
					headers: {"pc_anexo_orientacao_id":pc_anexo_orientacao_id,
							  "pc_anexo_avaliacao_id":pc_anexo_avaliacao_id,
							  "pc_aval_processo":pc_aval_processo} ,
					init: function() {
						this.on('error', function(file, errorMessage) {	
							toastr.error(errorMessage);
						});
					}
					
				})

				

				// Update the total progress bar
				// myDropzoneAcomp.on("totaluploadprogress", function(progress) {
				// 	document.querySelector(".progress-bar").style.width = progress + "%"
				// })

				myDropzoneAcomp.on("sending", function(file) {
					$('#modalOverlay').modal('show')
				})

				// Hide the total progress bar when nothing's uploading anymore
				myDropzoneAcomp.on("queuecomplete", function(progress) {
					mostraTabAnexosOrientacoes();
					mostraTabAnexos();
					
					$('#modalOverlay').delay(1000).hide(0, function() {
						$('#modalOverlay').modal('hide');
						toastr.success("Arquivo(s) enviado(s) com sucesso!")
					});
					myDropzoneAcomp.removeAllFiles(true);
				})

				
				
				// DropzoneJS Demo Code End


			})

			$('#btSalvar').on('click', function (event)  {
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()

				const idAnexos = []; // Array para armazenar os valores da coluna ID da tabela anexos
				if ($(".idColumn").length > 0) {
					// Iterar sobre cada elemento da coluna ID
					$(".idColumn").each(function() {
						var idValue = $(this).text();
						idAnexos.push(idValue);
					});
				}
				var idAnexosString = idAnexos.join(","); // Converta o array para uma string de IDs separados por vírgula
				
				//verifica se os campos necessários foram preenchidos
				if (
					!$('#pcPosicAcomp').val() 
				)
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Informe o texto da manifestação.');
					return false;
				}


				var mensagem = "Deseja salvar esta manifestação?"
				
							
				<cfoutput>
					var pc_aval_orientacao_id = '#arguments.pc_aval_orientacao_id#'; 
				</cfoutput>

				var statusOrientacao = 3; //staus RESPOSTA DO ÓRGÃO SUBORDINADOR
				if($('#pcOrientacaoStatus').val()){
					statusOrientacao = 	$('#pcOrientacaoStatus').val()
				}

				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem), 


					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {	
							setTimeout(function() {	
								$('#modalOverlay').modal('show');
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method:"salvarPosic",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:statusOrientacao,
										idAnexos: idAnexosString
									},
						
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#modalOverlay').delay(1000).hide(0, function() {
										mostraDataHoraPosicSalvo(pc_aval_orientacao_id)
										$('#modalOverlay').modal('hide');
										toastr.success('Manifestação e anexo(s) salvos com sucesso!');
									});			

								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});	
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								});//fim fail
							}, 500);
						}else {
							// Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});
						}
					})

			});

			$('#btEnviar').on('click', function (event)  {
				
				//cancela e  não propaga o event click original no botão
				event.preventDefault()
				event.stopPropagation()

				const idAnexos = []; // Array para armazenar os valores da coluna ID da tabela anexos
				if ($(".idColumn").length > 0) {
					// Iterar sobre cada elemento da coluna ID
					$(".idColumn").each(function() {
						var idValue = $(this).text();
						idAnexos.push(idValue);
					});
				}
				var idAnexosString = idAnexos.join(","); // Converta o array para uma string de IDs separados por vírgula

				//verifica se os campos necessários foram preenchidos
				if (
					!$('#pcPosicAcomp').val() 
				)
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}

				if ($('#pcOrientacaoStatus').val() == 5 && !$('#pcDataPrevRespAcomp').val())
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}
					
			
				var mensagem = "Deseja enviar esta manifestação?"
				

				<cfoutput>
					var   pc_aval_id = '#rsProc.pc_aval_id#';
					var   pc_aval_orientacao_mcu_orgaoResp = '#rsProc.pc_aval_orientacao_mcu_orgaoResp#';
					var   pc_aval_orientacao_id = '#arguments.pc_aval_orientacao_id#'; 
					var numProcesso = "#rsProc.pc_processo_id#";
				</cfoutput>
				var statusOrientacao = 3; //staus RESPOSTA DO ÓRGÃO SUBORDINADOR
				if($('#pcOrientacaoStatus').val()){
					statusOrientacao = 	$('#pcOrientacaoStatus').val()
				}
				if ($('#pcOrientacaoStatus').val() == 5){//se a o status escolhido for tratamento
					swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {	
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method:"cadPosicOrgaoAvaliado",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:statusOrientacao,
										pc_aval_orientacao_dataPrevistaResp: $('#pcDataPrevRespAcomp').val(),
										pc_aval_orientacao_mcu_orgaoResp: pc_aval_orientacao_mcu_orgaoResp,
										idAnexos: idAnexosString
										
									},
						
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#pcPosicAcomp').val('')
									
									exibirTabela()
									$('#informacoesItensAcompanhamentoDiv').html('')
									$('#timelineViewAcompDiv').html('')

									$('#modalOverlay').delay(1000).hide(0, function() {
										//$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});			

								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										//$('#modalOverlay').modal('hide');
									});	
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								})//fim fail	
							}, 500);
						}
					})
				}else{
					swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2(mensagem), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {	
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method:"cadPosicOrgaoAvaliado",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:statusOrientacao,
										pc_aval_orientacao_mcu_orgaoResp: pc_aval_orientacao_mcu_orgaoResp,
										idAnexos: idAnexosString
									},
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#pcPosicAcomp').val('')
									exibirTabela()
									$('#informacoesItensAcompanhamentoDiv').html('')
									$('#timelineViewAcompDiv').html('')
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});			
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
									});	
									$('#modal-danger').modal('show')
									$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
									$('#modal-danger').find('.modal-body').text(thrownError)

								});//fim fail
							}, 500);
						}
					})
				}

				
			});

			function mostraTabAnexosOrientacoes(){
				////$('#modalOverlay').modal('show')
				<cfoutput>
					var  pc_orientacao_id = '#rsProc.pc_aval_orientacao_id#';
				</cfoutput>
					setTimeout(function() {	
						$.ajax({
							type: "post",
							url: "cfc/pc_cfcAvaliacoes.cfc",
							data:{
								method: "tabAnexosOrientacoes",
								pc_orientacao_id: pc_orientacao_id
							},
							async: false
						})//fim ajax
						.done(function(result) {
							
							$('#tabAnexosAcompDiv').html(result)
							//$('#modalOverlay').delay(1000).hide(0, function() {
								////$('#modalOverlay').modal('hide');
				
							//});	
						})//fim done
						.fail(function(xhr, ajaxOptions, thrownError) {
							//$('#modalOverlay').delay(1000).hide(0, function() {
								//$('#modalOverlay').modal('hide');
							//});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)

						});
					}, 500);

			}

			function exibirTabela(){
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "tabAcompanhamento",
						},
						async: false,
						success: function(result) {
							$('#exibirTab').html(result)
							
						},
						error: function(xhr, ajaxOptions, thrownError) {
							//$('#modalOverlay').delay(1000).hide(0, function() {
								//$('#modalOverlay').modal('hide');
							//});
							$('#modal-danger').modal('show')
							$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
							$('#modal-danger').find('.modal-body').text(thrownError)
						}
					});
				}, 500);	
				

			}

			function mostraDataHoraPosicSalvo(pc_aval_orientacao_id){
								
				$.ajax({
						type: "post",
						url: "cfc/pc_cfcAcompanhamentos.cfc",
						data:{
							method: "dataHoraPosicSalvo",
							pc_aval_orientacao_id: pc_aval_orientacao_id
						},
						async: true
					})//fim ajax
					.done(function(result) {
						$('#divTextoPosicSalvo').html(result)
					})//fim done
					.fail(function(xhr, ajaxOptions, thrownError) {
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('#modalOverlay').modal('hide');
						});
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)

					});//fim fail
					

			}

		

			
				
			
		</script>





	</cffunction>


	

	<cffunction name="cadPosicControleInterno"   access="remote" hint="cadastra a manifestação do avaliador do controle interno">
	   
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
		<cfargument name="pc_aval_posic_texto" type="string" required="true" />
		<cfargument name="pc_aval_orientacao_mcu_orgaoResp" type="string" required="true" />
		<cfargument name="pc_aval_orientacao_dataPrevistaResp" type="string" required="false"  default=null/>
		<cfargument name="pc_aval_orientacao_status" type="numeric" required="true" />
		<cfargument name="pc_aval_orientacao_numProcJudicial" type="string" required="false" default=''/>
		<cfargument name="idAnexos" type="string" required="true">
		
    	<cftransaction>

			<cfquery datasource = "#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_posicionamentos 
				WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> and pc_aval_posic_enviado = 0
			</cfquery>

			<cfquery datasource = "#application.dsn_processos#" name="rsOrgao">
				SELECT 	pc_orgaos.* FROM pc_orgaos WHERE pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">
			</cfquery>
			<cfif #arguments.pc_aval_orientacao_status# eq 5 OR #arguments.pc_aval_orientacao_status# eq 16>
				<cfset data="#DateFormat(arguments.pc_aval_orientacao_dataPrevistaResp,'DD-MM-YYYY')#">
				<cfset textoPosic = "#arguments.pc_aval_posic_texto#">
				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado, pc_aval_posic_numProcJudicial)
				
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_dataPrevistaResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_numProcJudicial#" cfsqltype="cf_sql_varchar">
					)
					SELECT SCOPE_IDENTITY() AS idPosic;
				</cfquery>

				<cfquery datasource = "#application.dsn_processos#" >
					UPDATE 	pc_avaliacao_orientacoes
					SET 
						pc_aval_orientacao_status = <cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_orientacao_atualiz_login = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">,
						pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam value="#arguments.pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">,
						pc_aval_orientacao_dataPrevistaResp = <cfqueryparam value="#arguments.pc_aval_orientacao_dataPrevistaResp#" cfsqltype="cf_sql_varchar">,
					    pc_aval_orientacao_numProcJudicial = <cfqueryparam value="#arguments.pc_aval_orientacao_numProcJudicial#" cfsqltype="cf_sql_varchar">
					WHERE 
						pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">

				</cfquery>


			<cfelse>

				<cfset textoPosic = "#arguments.pc_aval_posic_texto#">

				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_status, pc_aval_posic_enviado, pc_aval_posic_num_orgaoResp, pc_aval_posic_numProcJudicial)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_numProcJudicial#" cfsqltype="cf_sql_varchar">
					)
					SELECT SCOPE_IDENTITY() AS idPosic;
				
				</cfquery>

				<cfquery datasource = "#application.dsn_processos#" >
					UPDATE 	pc_avaliacao_orientacoes
					SET 
						pc_aval_orientacao_status = <cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_orientacao_atualiz_login = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">,
						pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam value="#arguments.pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">,
						pc_aval_orientacao_numProcJudicial = <cfqueryparam value="#arguments.pc_aval_orientacao_numProcJudicial#" cfsqltype="cf_sql_varchar">
					WHERE 
						pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">
				</cfquery>


			</cfif>
			<!--- Verifica se ainda existem no item orientação com status que não é finalizador--->
			<cfquery datasource = "#application.dsn_processos#" name="rsItem" >
				SELECT pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval FROM  pc_avaliacao_orientacoes WHERE pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfquery datasource = "#application.dsn_processos#" name="rsProcesso" >
				SELECT pc_avaliacoes.pc_aval_processo FROM pc_avaliacoes where pc_aval_id = #rsItem.pc_aval_orientacao_num_aval#
			</cfquery>

			<cfquery datasource = "#application.dsn_processos#" name="quantStatusNaoFinalizItem" >
				SELECT pc_processos.pc_processo_id, pc_avaliacao_orientacoes.pc_aval_orientacao_id
				FROM    pc_processos LEFT JOIN
						pc_avaliacoes ON pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo LEFT JOIN
						pc_avaliacao_orientacoes ON pc_avaliacoes.pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval LEFT JOIN
						pc_orientacao_status ON pc_avaliacao_orientacoes.pc_aval_orientacao_status = pc_orientacao_status.pc_orientacao_status_id
				where   pc_orientacao_status_finalizador = 'N' and pc_aval_id = #rsItem.pc_aval_orientacao_num_aval#
			</cfquery>
			
			<cfif quantStatusNaoFinalizItem.recordcount eq 0>
				<cfquery datasource = "#application.dsn_processos#" >
					UPDATE 	pc_avaliacoes
					SET    	pc_aval_status = '7'
					WHERE 	pc_aval_id = #rsItem.pc_aval_orientacao_num_aval#
				</cfquery>
			</cfif>

			<cfquery datasource = "#application.dsn_processos#" name="quantStatusNaoFinalizProcesso" >
				SELECT pc_processos.pc_processo_id, pc_avaliacao_orientacoes.pc_aval_orientacao_id
				FROM    pc_processos LEFT JOIN
						pc_avaliacoes ON pc_processos.pc_processo_id = pc_avaliacoes.pc_aval_processo LEFT JOIN
						pc_avaliacao_orientacoes ON pc_avaliacoes.pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval LEFT JOIN
						pc_orientacao_status ON pc_avaliacao_orientacoes.pc_aval_orientacao_status = pc_orientacao_status.pc_orientacao_status_id
				where   PC_ORIENTACAO_STATUS_FINALIZADOR = 'N' and pc_processo_id = '#rsProcesso.pc_aval_processo#'
			</cfquery>

			<cfif quantStatusNaoFinalizProcesso.recordcount eq 0>
				<cfquery datasource = "#application.dsn_processos#" >
					UPDATE 	pc_processos
					SET    	pc_num_status = '5',
							pc_data_finalizado = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
					WHERE 	pc_processo_id = '#rsProcesso.pc_aval_processo#'
				</cfquery>
			</cfif>
			
			<!--Insere nos anexos o ID do posicionamento para exibir os anexos no respectivo posicionamento no timeline -->
			<cfset idPosicCadastrado = rsCadPosic.idPosic>
			<cfset idArray = ListToArray(arguments.idAnexos)>
			<cfif IsArray(#idArray#) AND ArrayLen(#idArray#) gt 0>
				<cfloop array="#idArray#" index="id">
					<cfquery datasource = "#application.dsn_processos#" >
						UPDATE 	pc_anexos set
								pc_anexo_aval_posic = #idPosicCadastrado#,
								pc_anexo_enviado = 1
						where pc_anexo_id = #id# and pc_anexo_aval_posic is null
					</cfquery>
				</cfloop>
			</cfif>
		</cftransaction>			
		

	</cffunction>



	<cffunction name="salvarPosic"   access="remote" hint="salva a manifestação de qualquer usuário">
	   
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
		<cfargument name="pc_aval_posic_texto" type="string" required="true" />
		<cfargument name="pc_aval_orientacao_status" type="numeric" required="true" />
		<cfargument name="pc_aval_posic_num_orgaoResp" type="string" required="false" default=''/>
		<cfargument name="pc_aval_posic_numProcJudicial" type="string" required="false" default=''/>
		<cfargument name="idAnexos" type="string" required="true">

		<cfquery datasource = "#application.dsn_processos#" name="rsPosicNaoEnviada">
			SELECT pc_aval_posic_id, pc_aval_posic_enviado FROM pc_avaliacao_posicionamentos 
			WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> and pc_aval_posic_enviado = 0
		</cfquery>
		
    	<cftransaction>
			<cfset textoPosic = "#arguments.pc_aval_posic_texto#">

			<cfif rsPosicNaoEnviada.recordcount eq 0>
				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_status, pc_aval_posic_num_orgaoResp, pc_aval_posic_numProcJudicial)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_posic_num_orgaoResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_posic_numProcJudicial#" cfsqltype="cf_sql_varchar">
					)
					SELECT SCOPE_IDENTITY() AS idPosic;
				
				</cfquery>
		
			<cfelse>
				<cfquery datasource = "#application.dsn_processos#" >
					UPDATE 	pc_avaliacao_posicionamentos
					SET 
						pc_aval_posic_texto = <cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						pc_aval_posic_dataHora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_posic_matricula = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						pc_aval_posic_num_orgao = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						pc_aval_posic_status = <cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
					    pc_aval_posic_num_orgaoResp = <cfqueryparam value="#arguments.pc_aval_posic_num_orgaoResp#" cfsqltype="cf_sql_varchar">,
						pc_aval_posic_numProcJudicial = <cfqueryparam value="#arguments.pc_aval_posic_numProcJudicial#" cfsqltype="cf_sql_varchar">
					WHERE 
						pc_aval_posic_num_orientacao = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">
						and pc_aval_posic_enviado = 0
				</cfquery>

				

			</cfif>
			
		</cftransaction>			
		

	</cffunction>




	<cffunction name="cadPosicOrgaoAvaliado"   access="remote" hint="cadastra a manifestação do avaliador do controle interno">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
		<cfargument name="pc_aval_posic_texto" type="string" required="true" />
		<cfargument name="pc_aval_orientacao_status" type="numeric" required="false" default="3" />
		<cfargument name="pc_aval_orientacao_dataPrevistaResp" type="string" required="false" default=''/>
		<cfargument name="pc_aval_orientacao_mcu_orgaoResp" type="string" required="true" />
		<cfargument name="idAnexos" type="string" required="true">

		<cfset textoPosic = "#arguments.pc_aval_posic_texto#">
		<cftransaction>
			<cfquery datasource = "#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_posicionamentos 
				WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> and pc_aval_posic_enviado = 0
			</cfquery>
			<cfif '#arguments.pc_aval_orientacao_dataPrevistaResp#' neq ''>
				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado, pc_aval_posic_num_orgaoResp)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_dataPrevistaResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">
					)
					SELECT SCOPE_IDENTITY() AS idPosic;
				</cfquery>
			<cfelse>
			<!-- se o parametro pc_aval_orientacao_dataPrevistaResp vier "", obtem a data prevista calculada no último posicionamento de status  4 -“Não respondido” ou 5 - “Tratamento”-->
				<cfquery datasource = "#application.dsn_processos#" name="rsDataPrevista">
					SELECT TOP 1 pc_aval_posic_dataPrevistaResp FROM pc_avaliacao_posicionamentos 
					WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> 
							and pc_aval_posic_status in (4,5) and pc_aval_posic_enviado = 1
					ORDER BY pc_aval_posic_id DESC
				</cfquery>
				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado, pc_aval_posic_num_orgaoResp)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#rsDataPrevista.pc_aval_posic_dataPrevistaResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">
					)
					SELECT SCOPE_IDENTITY() AS idPosic;
				
				</cfquery>

			</cfif>
			
			<cfquery datasource = "#application.dsn_processos#" >
				UPDATE 	pc_avaliacao_orientacoes
				SET pc_aval_orientacao_status = <cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
					pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					pc_aval_orientacao_atualiz_login = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">
				WHERE pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">

			</cfquery>
			<!--Insere nos anexos o ID do posicionamento para exibir os anexos no respectivo posicionamento no timeline -->
			<cfset idPosicCadastrado = rsCadPosic.idPosic>
			<cfset idArray = ListToArray(arguments.idAnexos)>
			<cfif IsArray(#idArray#) AND ArrayLen(#idArray#) gt 0>
				<cfloop array="#idArray#" index="id">
					<cfquery datasource = "#application.dsn_processos#" >
						UPDATE 	pc_anexos set
								pc_anexo_aval_posic = #idPosicCadastrado#,
								pc_anexo_enviado = 1
						where pc_anexo_id = #id# and pc_anexo_aval_posic is null
					</cfquery>
				</cfloop>
			</cfif>
		</cftransaction>


	</cffunction>







	<cffunction name="uploadArquivosOrientacao" access="remote"  returntype="boolean" output="false" hint="realiza o upload dos anexos das orientacoes">

		
		<cfset thisDir = expandPath(".")>

		<cffile action="upload" filefield="file" destination="#application.diretorio_anexos#" nameconflict="skip" >
	
		<cfscript>
			thread = CreateObject("java","java.lang.Thread");
			thread.sleep(1000); // dalay para evitar arquivos com nome duplicado
		</cfscript>
		
		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'ss.SSSSS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
				
		<cfset destino = cffile.serverdirectory & '\Anexo_processo_orientacao_id_' & #pc_anexo_orientacao_id# & '_AVAL_' & #pc_anexo_avaliacao_id# &'_PC_' & '#pc_aval_processo#' & '_'  & '#application.rsUsuarioParametros.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>

	    <cfobject component = "pc_cfcAvaliacoes" name = "tamanhoArquivo">
		<cfinvoke component="#tamanhoArquivo#" method="renderFileSize" returnVariable="tamanhoDoArquivo" size ='#cffile.fileSize#' type='bytes'>

		<cfset nomeDoAnexo = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#'>

		<cfif FileExists(origem)>
			<cffile action="rename" source="#origem#" destination="#destino#">
        </cfif>
		        
		<cfset mcuOrgao = "#application.rsUsuarioParametros.pc_org_mcu#">
		<cfif FileExists(destino)>
            
		<cfquery datasource="#application.dsn_processos#" >
				INSERT pc_anexos(pc_anexo_avaliacao_id,pc_anexo_orientacao_id, pc_anexo_login, pc_anexo_caminho, pc_anexo_nome, pc_anexo_mcu_orgao, pc_anexo_avaliacaoPDF )
				VALUES (#pc_anexo_avaliacao_id#,#pc_anexo_orientacao_id#, '#application.rsUsuarioParametros.pc_usu_login#', '#destino#', '#nomeDoAnexo#','#mcuOrgao#', 'N')
		</cfquery>
			
		</cfif>
	
		<cfreturn true />
    </cffunction>


	<cffunction name="dataHoraPosicSalvo" access="remote"  hint="Mostra a data/hora e nome do usuário que salvou o posicionamento">
		<cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
        <!-- Verifica se existe manifestação salva -->
		<cfquery datasource="#application.dsn_processos#" name="rsManifestacaoSalva">
			Select pc_avaliacao_posicionamentos.*, pc_orgaos.pc_org_sigla, pc_usuarios.pc_usu_nome FROM pc_avaliacao_posicionamentos 
			INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_posic_num_orgao
			INNER JOIN pc_usuarios on pc_usu_matricula = pc_aval_posic_matricula
			WHERE pc_aval_posic_num_orientacao = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">
					and pc_aval_posic_enviado = 0
		</cfquery>
		
		<cfif rsManifestacaoSalva.recordcount neq 0>
			<cfset data = DateFormat(#rsManifestacaoSalva.pc_aval_posic_datahora#,'DD-MM-YYYY') >
			<cfset hora = TimeFormat(#rsManifestacaoSalva.pc_aval_posic_datahora#,'HH:mm') >
			<span style = "font-size:11px; color:#e83e8c"><cfoutput>Manifestação salva em <strong>#data# às #hora#h</strong> por <strong>#rsManifestacaoSalva.pc_usu_nome# (#rsManifestacaoSalva.pc_org_sigla#)</strong></cfoutput>
				<i id="btExcluirManifestacao" class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:15px;margin-left:10px;margin-bottom:2px" ></i>
 			</span>
		</cfif>

		<script>
			//ao clicar no botão btExcluirManifestacao exclui a manifestação salva utlizando ajax
            $('#btExcluirManifestacao').click(function(){
				<cfoutput>		
					var pc_aval_posic_id = '#rsManifestacaoSalva.pc_aval_posic_id#';
				</cfoutput>

				swalWithBootstrapButtons.fire({//sweetalert2
					html: logoSNCIsweetalert2('Deseja excluir a manifestação salva?'), 
					showCancelButton: true,
					confirmButtonText: 'Sim!',
					cancelButtonText: 'Cancelar!'
					}).then((result) => {
						if (result.isConfirmed) {	
							$('#modalOverlay').modal('show')
							setTimeout(function() {
								$.ajax({
									type: "post",
									url: "cfc/pc_cfcAcompanhamentos.cfc",
									data:{
										method:"excluirManifestacaoSalva",
										pc_aval_posic_id: pc_aval_posic_id
									},
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#pcPosicAcomp').val('')
									$('#divTextoPosicSalvo').html('')
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										toastr.success('Operação realizada com sucesso!');
									});			
								})//fim done
								.fail(function(xhr, ajaxOptions, thrownError) {
									$('#modalOverlay').delay(1000).hide(0, function() {
										$('#modalOverlay').modal('hide');
										var mensagem = '<p style="color:red">Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:<p>'
													+ '<div style="background:#000;width:100%;padding:5px;color:#fff">' + thrownError + '</div>';
										const erroSistema = { html: logoSNCIsweetalert2(mensagem) }
										swalWithBootstrapButtons.fire(
											{...erroSistema}
										)
									})
								})//fim fail
							}, 500);
						}else{
							$('#modalOverlay').modal('hide');
							Swal.fire({
								title: 'Operação Cancelada',
								html: logoSNCIsweetalert2(''),
								icon: 'info'
							});			
						}

					})
			});


			

		</script>

 	</cffunction>

	<cffunction name="excluirManifestacaoSalva" access="remote"  hint="Exclui a manifestação salvar.">
		<cfargument name="pc_aval_posic_id" type="numeric" required="true" />

		<cftransaction>
			<cfquery datasource="#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_posicionamentos 
				WHERE pc_aval_posic_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_posic_id#">
			</cfquery>
		</cftransaction>
		
	</cffunction>
</cfcomponent>