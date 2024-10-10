<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	
	
   	<cffunction name="tabOrientacoesDistribuidas" returntype="any" access="remote" hint="Criar a tabela das orientacoes pendentes e envia para a página pcAcompanhamento.cfm">
		
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

			<!---Só mostra orientações distribuídas --->
			WHERE pc_aval_orientacao_status in (2,4,5) AND pc_aval_orientacao_distribuido = 1
			<!---Não exibe processos bloqueados--->
			AND not pc_processos.pc_num_status in(6) and (pc_aval_orientacao_mcu_orgaoResp in (SELECT pc_orgaos.pc_org_mcu	FROM pc_orgaos WHERE (pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			or pc_org_mcu_subord_tec in( SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'))))
	
			ORDER BY 	pc_processo_id, pc_aval_numeracao
		</cfquery>	

		<div class="row">
			
			<div class="col-12">
				<div class="card"  >
				    
					<!-- /.card-header -->
					<div class="card-body" >
						<cfif #rsProcTab.recordcount# eq 0 >
							<h5 align="center">Nenhuma Orientação Distribuída pelo órgão <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput> foi localizada.</h5>
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
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsProcTab" >
										<cfoutput>					
											<tr style="font-size:12px;cursor:pointer;z-index:2;"  >
											        
													<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11>
														<td align="center">
															<cfif #pc_aval_orientacao_status# eq 2 or #pc_aval_orientacao_status# eq 3 or #pc_aval_orientacao_status# eq 4 or #pc_aval_orientacao_status# eq 5 or (#pc_aval_orientacao_status# eq 13 && '#orgaoOrigem#' neq '#mcuOrgResp#')>
																<i onclick="javascript:colocarEmAnalise('#pc_processo_id#',#pc_aval_id#,#pc_aval_orientacao_id#,'#orgaoOrigem#','#orgaoOrigemSigla#','#mcuOrgResp#',#pc_aval_orientacao_status#)"class="fas fa-file-medical-alt grow-icon clickable-icon" style="color:##0083ca;font-size:20px;margin-right:10px;z-index:10000"> </i>
															</cfif>
														</td>
													</cfif>
													<cfif #pc_aval_orientacao_dataPrevistaResp# neq '' and DATEFORMAT(#pc_aval_orientacao_dataPrevistaResp#,"yyyy-mm-dd")  lt DATEFORMAT(Now(),"yyyy-mm-dd") and (#pc_aval_orientacao_status# eq 4 or #pc_aval_orientacao_status# eq 5)>
														<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
															<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')"><span class="statusOrientacoes" style="background:##FFA500;color:##fff;" >PENDENTE</span></td>
														<cfelse>
															<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;" >PENDENTE</span></td>
														</cfif>
													<cfelseif #pc_aval_orientacao_status# eq 3>
														<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
															<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')"><span  class="statusOrientacoes" style="background:##FFA500;color:##fff;" >#pc_orientacao_status_descricao#</span></td>
														<cfelse>
															<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;" >#pc_orientacao_status_descricao#</span></td>
														</cfif>
											
													<cfelse>
														<td  align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')"><span class="statusOrientacoes" style="#pc_orientacao_status_card_style_header#;"  >#pc_orientacao_status_descricao#</span></td>
													</cfif>
													<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#pc_processo_id#</td>
													<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#pc_aval_numeracao#</td>	
													<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#pc_aval_orientacao_id#</td>	
													
													<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N' >
														<cfif #pc_aval_orientacao_status# eq 4 or #pc_aval_orientacao_status# eq 5>
															<cfset dataPrev = DateFormat(#pc_aval_orientacao_dataPrevistaResp#,'DD-MM-YYYY') >
															<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#dataPrev#</td>
														<cfelse>
															<td></td>
														</cfif>
													</cfif>
													
													
													<cfif pc_aval_orientacao_distribuido eq 1>
														<td onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#siglaOrgResp# (#mcuOrgResp#)</td>
													<cfelse>
														<td onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#siglaOrgResp# (#mcuOrgResp#)</td>
													</cfif>
													<td onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#seOrgResp#</td>
													

													<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
													<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#sei#</td>
													<td align="center" onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#pc_num_rel_sei#</td>
													
													<cfif pc_num_avaliacao_tipo neq 2>
														<td onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#pc_aval_tipo_descricao#</td>
													<cfelse>
														<td onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#pc_aval_tipo_nao_aplica_descricao#</td>
													</cfif>
													<td onclick="javascript:mostrainfItensOrientacoesDistribuidas(#pc_aval_id#, #pc_aval_orientacao_id#, '#pc_processo_id#')">#DateFormat(pc_aval_orientacao_status_datahora,"dd/mm/yyyy")# - #TimeFormat(pc_aval_orientacao_status_datahora,"HH:mm")#</td>	
													
													<td>#orgaoOrigemSigla#</td>	
													<td>#orgaoAvaliado#</td>	
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
				 //var colunasMostrar = [0,1,3,4,5,9,11];
				  var colunasMostrar = [1,5,6,9,11,12];
				} else {
				  if(controleInterno == 'S'){
					//var colunasMostrar = [0,2,3,4,8,10];
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
							title : 'SNCI_Orientacoes_Distribuidas_' + d,
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
			});

			
			function mostrainfItensOrientacoesDistribuidas(idAvaliacao, idOrientacao,idProcesso){
				$('#tabProcessos tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabProcessos tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
				$('#modalOverlay').modal('show')
				
				$('#infItensOrientacoesDistribuidasDiv').html('');
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcControleDistribuicao.cfc",
						data:{
							method: "infItensOrientacoesDistribuidas",
							idAvaliacao: idAvaliacao,
							idOrientacao: idOrientacao,
							idProcesso: idProcesso
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#infItensOrientacoesDistribuidasDiv').html(result)
						$(".content-wrapper").css("height","auto");//para o background cinza da div content-wrapper se estender até o final do timeline
						$('#modalOverlay').delay(1000).hide(0, function() {
							$('html, body').animate({ scrollTop: ($('#infItensOrientacoesDistribuidasDiv').offset().top-80)} , 1000);
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
									$('#infItensOrientacoesDistribuidasDiv').html('')	
									var mensagemSucessos = '<br><p class="font-weight-light" style="color:#28a745;text-align: justify;">A Orientação ID <span style="color:#00416B">'+idOrientacao+'</span> foi enviada para análise da <span style="color:#00416B">'+orgaoOrigemSigla+'</span> com sucesso!<br><br><span style="color:#00416B;font-size:0.8em;"><strong>Atenção:</strong> Como a gerência que analisará esta orientação não é a sua gerência de lotação, você não poderá visualizar esta orientação em "Acompanhamento", apenas em "Consulta por Orientação", portanto, orientamos anotar o ID da orientação, informado acima, e realizar uma consulta para verificar se essa rotina realmente foi executada com sucesso.</span></p>';
									$('#modalOverlay').delay(1000).hide(0, function() {
										toastr.success('Operação realizada com sucesso!');
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
									$('#infItensOrientacoesDistribuidasDiv').html('')	
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









	<cffunction name="infItensOrientacoesDistribuidas"   access="remote" hint="envia para a página acomanhamento.cfm tabs com informações do item.">
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="idOrientacao" type="numeric" required="true" />
		<cfargument name="idProcesso" type="string" required="true" />

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam value="#arguments.idAvaliacao#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery datasource="#application.dsn_processos#" name="rsStatus">
			SELECT pc_avaliacoes.pc_aval_status FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#"> 
		</cfquery>
		

		<session class="content-header" >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">


					<div id="idAvaliacao" hidden></div>

					<cfquery name="rsItemNum" datasource="#application.dsn_processos#">
						SELECT pc_aval_numeracao FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">
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
							font-weight: 400 !important;
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
						
					
					<div class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
								<li class="nav-item" style="">
									<a  class="nav-link  active" id="custom-tabs-one-Orientacao-tab"  data-toggle="pill" href="#custom-tabs-one-Orientacao" role="tab" aria-controls="custom-tabs-one-Orientacao" aria-selected="true">
									Medida/Orientação ID (<strong><cfoutput>#arguments.idOrientacao#</cfoutput></strong>)</a>
								</li>
								

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfProcesso-tab"  data-toggle="pill" href="#custom-tabs-one-InfProcesso" role="tab" aria-controls="custom-tabs-one-InfProcesso" aria-selected="true">Inf. Processo</a>
								</li>

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfItem-tab"  data-toggle="pill" href="#custom-tabs-one-InfItem" role="tab" aria-controls="custom-tabs-one-InfItem" aria-selected="true">
									<cfoutput>Inf. Item ( N° <strong>#rsItemNum.pc_aval_numeracao#</strong> - ID <strong>#arguments.idAvaliacao#</strong> )</cfoutput></a>
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
								<div disable class="tab-pane fade  active show " id="custom-tabs-one-Orientacao"  role="tabpanel" aria-labelledby="custom-tabs-one-Orientacao-tab" >	
									<div id="infoOrientacaoDiv" ></div>
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
			</session><!-- fim card-body2 -->	
					
			
			<cfset timelineViewAcompOrgaoAvaliado(arguments.idOrientacao)>
			<cfset formPosicionamentoOrgaoAvaliado(arguments.idOrientacao)>
				
					
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
					var pc_aval_id = '#arguments.idAvaliacao#';
					var pc_aval_orientacao_id = '#arguments.idOrientacao#';
					var pc_processo_id = '#arguments.idProcesso#';
				</cfoutput>
								
				$('#tab-manifestacao').click(function() {
					$('html, body').animate({ scrollTop: ($('#tab-manifestacao').offset().top)-60} , 1000);
				});


				$('#tab-distribuicao').click(function() {
					$('html, body').animate({ scrollTop: ($('#tab-distribuicao').offset().top)-60} , 1000);
				});

				$('#custom-tabs-one-Orientacao-tab').on('click', function (event){
					mostraInfoOrientacao('infoOrientacaoDiv',pc_processo_id,pc_aval_orientacao_id);
				});

				$('#custom-tabs-one-InfProcesso-tab').on('click', function (event){
					mostraInfoProcesso('infoProcessoDiv',pc_processo_id);
				});

				$('#custom-tabs-one-InfItem-tab').on('click', function (event){
					mostraInfoItem('infoItemDiv',pc_processo_id,pc_aval_id);
				});	

				$('#custom-tabs-one-Avaliacao-tab').on('click', function (event){
					mostraRelatoPDF('anexoAvaliacaoDiv',pc_aval_id,'S');
				});

				$('#custom-tabs-one-Anexos-tab').on('click', function (event){
					mostraTabAnexosJS('tabAnexosDiv',pc_aval_id,pc_aval_orientacao_id);
				});
				
				mostraInfoOrientacao('infoOrientacaoDiv',pc_processo_id,pc_aval_orientacao_id,'custom-tabs-one-Orientacao-tab');
				
			})



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
		</cfquery>

		<cftransaction>

			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_avaliacao_orientacoes
				SET pc_aval_orientacao_distribuido = 1
				WHERE pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
			</cfquery>


			

			<cfset firstItem = ListFirst(arguments.pcAreasDistribuir)><!-- Primeiro elemento da lista -->
			<cfset dataPrevista = rsOrientacao.pc_aval_orientacao_dataPrevistaResp>
			<cfset posic_status = rsOrientacao.pc_aval_orientacao_status>
			<cfloop list="#arguments.pcAreasDistribuir#" index="i">
				<!-- Atualização para o primeiro elemento -->
				<cfif i eq firstItem>
					<!-- Atualização para a priemira área selecionada -->
					<cfquery datasource="#application.dsn_processos#">
						UPDATE pc_avaliacao_orientacoes
						SET
							pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam value="#i#" cfsqltype="cf_sql_varchar">,
							pc_aval_orientacao_atualiz_login = '#application.rsUsuarioParametros.pc_usu_login#',
							pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
							pc_aval_orientacao_distribuido = 1
						WHERE pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">
					</cfquery>
					
					<!--Insere a manifestação inicial do controle interno para a orientação com a mesma data prevista e status da orientação original do órgão avaliado -->
					<cfset orgaoResp = '#i#'>
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_avaliacao_posicionamentos(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_datahora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado)
						VALUES (<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_numeric">, <cfqueryparam value="#pcOrientacaoResposta#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,'#application.rsUsuarioParametros.pc_usu_matricula#','#application.rsUsuarioParametros.pc_usu_lotacao#', '#orgaoResp#','#dataPrevista#',#posic_status#,1)
					</cfquery>

				
				<cfelse>
					<!-- Inserção para as outras áreas selecionadas -->
					<cfquery datasource="#application.dsn_processos#" name="rsInserirOrientacao">
						INSERT pc_avaliacao_orientacoes(pc_aval_orientacao_dataPrevistaResp, pc_aval_orientacao_status, pc_aval_orientacao_status_datahora,pc_aval_orientacao_atualiz_login,pc_aval_orientacao_num_aval, pc_aval_orientacao_descricao, pc_aval_orientacao_mcu_orgaoResp, pc_aval_orientacao_datahora, pc_aval_orientacao_login, pc_aval_orientacao_distribuido)
						VALUES ('#dataPrevista#', #posic_status#, <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, '#application.rsUsuarioParametros.pc_usu_login#',#rsOrientacao.pc_aval_orientacao_num_aval#, '#rsOrientacao.pc_aval_orientacao_descricao#','#i#',  <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">, '#application.rsUsuarioParametros.pc_usu_login#', 1)
						SELECT SCOPE_IDENTITY() AS idOrientacao;
					</cfquery>
					 <cfset insertedIdOrientacao = rsInserirOrientacao.idOrientacao> <!-- Obtém o ID gerado -->

					<!--Insere a manifestação inicial do controle interno para a orientação com prazo de 30 dias como data prevista para resposta -->
					<cfset orgaoResp = '#i#'>
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

			</cfloop>

		</cftransaction>


	</cffunction>


	<cffunction name="tabMelhoriasPendentes" access="remote" hint="Criar a tabela das propostas de melhoria e envia para a página pcAcompanhamento.cfm">
		
		<cfquery name="rsMelhoriasPendentes" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_melhorias.*, pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_num_sei
			,pc_avaliacoes.pc_aval_numeracao , pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla,  pc_orgaos.pc_org_mcu
			,pc_aval_id
			FROM pc_avaliacao_melhorias
			INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			
			WHERE pc_aval_melhoria_status = 'P' and pc_num_status in(4,5) and pc_aval_melhoria_distribuido = 1
			      and pc_aval_melhoria_num_orgao in (SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE (pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#'
			or pc_org_mcu_subord_tec in (SELECT pc_orgaos.pc_org_mcu FROM pc_orgaos WHERE pc_org_mcu_subord_tec = '#application.rsUsuarioParametros.pc_usu_lotacao#')))
		</cfquery>
		
		<div class="row" >
			<div class="col-12">
				<div class="card"  >
				    
					<!-- /.card-header -->
					<div class="card-body" >

						<cfif #rsMelhoriasPendentes.recordcount# eq 0 >
							<h5 align="center">Nenhuma Proposta de Melhoria Distribuída pelo órgão <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>, com status PENDENTE, foi localizada.</h5>
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
											<tr style="font-size:12px;cursor:pointer;z-index:2;"  onclick="javascript:mostraInfMelhoriaAcomp('#pc_processo_id#',#pc_aval_id#,#pc_aval_melhoria_id#)">
												<td id="statusMelhorias"align="center" ><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;">PENDENTE</span></td>
												<td align="center">#pc_aval_melhoria_id#</td>	
												<td align="center">#pc_processo_id#</td>
												<td align="center">#pc_aval_numeracao#</td>
												<td align="center">#pc_org_sigla# (#pc_org_mcu#)</td>
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

			function mostraInfMelhoriaAcomp(idProcesso,idAvaliacao,idMelhoria){
				$('#tabMelhoriasPendentes tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabMelhoriasPendentes tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
				$('#modalOverlay').modal('show')
				
				$('#infItensOrientacoesDistribuidasDiv').html('');
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcControleDistribuicao.cfc",
						data:{
							method: "infItensMelhoriasDistribuidas",
							idMelhoria: idMelhoria,
							idAvaliacao: idAvaliacao,
							idProcesso: idProcesso
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#infItensOrientacoesDistribuidasDiv').html(result)
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
						url: "cfc/pc_cfcControleDistribuicao.cfc",
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
						$('#infItensOrientacoesDistribuidasDiv').html('')
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









	<cffunction name="infItensMelhoriasDistribuidas"   access="remote" hint="envia para a página acomanhamento.cfm tabs com informações do item.">
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="idMelhoria" type="numeric" required="true" />
		<cfargument name="idProcesso" type="string" required="true" />


		<session class="content-header"  >
					
			<!-- /.card-header -->
			<session class="card-body" >
				<form id="formCadItem" name="formCadItem" format="html"  style="height: auto;" style="margin-bottom:100px">

					<cfquery name="rsMelhoria" datasource="#application.dsn_processos#">
						SELECT      pc_avaliacao_melhorias.*
									,pc_orgaos.pc_org_mcu as mcuOrgResp,pc_orgaos.pc_org_sigla as siglaOrgResp
									,pc_orgaos1.pc_org_mcu as mcuOrgRespSugerido, pc_orgaos1.pc_org_sigla as siglaOrgRespSugerido
						FROM        pc_avaliacao_melhorias 
									
									INNER JOIN pc_orgaos as pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_melhoria_num_orgao
									LEFT JOIN pc_orgaos as pc_orgaos1 on pc_orgaos1.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
									
						WHERE  pc_aval_melhoria_id = <cfqueryparam value="#arguments.idMelhoria#" cfsqltype="cf_sql_numeric">	 													
					</cfquery>	

					<cfquery name="rsCategoriaControle" datasource="#application.dsn_processos#">
						SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_melhoria_categoriasControles	
						INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_melhoria_categoriasControles.pc_aval_categoriaControle_id
						WHERE pc_avaliacao_melhoria_categoriasControles.pc_aval_melhoria_id =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idMelhoria#">
					</cfquery>
					<cfset categoriaControleList = ValueList(rsCategoriaControle.pc_aval_categoriaControle_descricao, ', ')>

					<cfquery name="rsItemNum" datasource="#application.dsn_processos#">
						SELECT pc_aval_numeracao FROM pc_avaliacoes WHERE pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.idAvaliacao#">
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
							font-weight: 400 !important;
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
						
					
					<div class="card card-primary card-tabs"  style="widht:100%">
						<div class="card-header p-0 pt-1" style="background-color: #0083CA;">
							
							<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
								<li class="nav-item" style="">
									<a  class="nav-link  active" id="custom-tabs-one-Melhoria-tab"  data-toggle="pill" href="#custom-tabs-one-Melhoria" role="tab" aria-controls="custom-tabs-one-Melhoria" aria-selected="true"> Proposta de Melhoria p/ Manifestação: ID <cfoutput><strong>#rsMelhoria.pc_aval_melhoria_id#</strong> - #rsMelhoria.siglaOrgResp# (#rsMelhoria.mcuOrgResp#)</cfoutput></a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfProcesso-tab"  data-toggle="pill" href="#custom-tabs-one-InfProcesso" role="tab" aria-controls="custom-tabs-one-InfProcesso" aria-selected="true">Inf. Processo
									<cfoutput>Inf. Item ( N° <strong>#rsItemNum.pc_aval_numeracao#</strong> - ID <strong>#arguments.idAvaliacao#</strong> )</cfoutput></a>
								</li>

								<li class="nav-item" style="">
									<a  class="nav-link " id="custom-tabs-one-InfItem-tab"  data-toggle="pill" href="#custom-tabs-one-InfItem" role="tab" aria-controls="custom-tabs-one-InfItem" aria-selected="true">Inf. Item</a>
								</li>
								
								<li class="nav-item" style="">
									<a  class="nav-link  " id="custom-tabs-one-Avaliacao-tab"  data-toggle="pill" href="#custom-tabs-one-Avaliacao" role="tab" aria-controls="custom-tabs-one-Avaliacao" aria-selected="true">Relatório</a>
								</li>
								<li class="nav-item">
									<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos do Item <cfoutput>#rsItemNum.pc_aval_numeracao#</cfoutput></a>
								</li>
								
							</ul>
							
						</div>
						<div class="card-body">
							<div class="tab-content" id="custom-tabs-one-tabContent">
								<div disable class="tab-pane fade  active show" id="custom-tabs-one-Melhoria"  role="tabpanel" aria-labelledby="custom-tabs-one-Melhoria-tab" >														
									<div class="col-md-12">
										<cfoutput>
											<cfif rsMelhoria.pc_aval_melhoria_distribuido eq 1>
												<div style=" display: inline;background-color: ##e83e8c;color:##fff;padding: 3px;margin-bottom:20px">Proposta de melhoria distribuída pelo seu órgão subordinador:</div><br>
											</cfif>
										</cfoutput>

										<cfoutput>
							           		
											<fieldset style="padding:0px!important;min-height: 90px;margin-top:10px">
												<legend style="margin-left:20px">Proposta de Melhoria:</legend> 
												<pre class="font-weight-light " style="color:##0083ca!important;font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsMelhoria.pc_aval_melhoria_descricao#</pre>									
											</fieldset>
											<cfset ano = RIGHT('#arguments.idProcesso#',4)>
											<cfif #ano# gte 2024 and rsCategoriaControle.recordcount gt 0> 
												<cfif rsMelhoria.pc_aval_melhoria_beneficioNaoFinanceiro neq ''>
													<fieldset style="padding:0px!important;min-height: 90px;">
														<legend style="margin-left:20px">Benefício Não Financeiro da Proposta de Melhoria:</legend>                                         
														<pre class="font-weight-light " style="color:##0083ca!important;font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsMelhoria.pc_aval_melhoria_beneficioNaoFinanceiro#</pre>
													</fieldset>
												</cfif>
												<div style="margin-bottom:20px">
													<li >Categoria(s) do Controle Proposto: <span style="color:##0692c6;">#categoriaControleList#.</span></li>

													<cfif rsMelhoria.pc_aval_melhoria_beneficioFinanceiro gt 0>
														<cfset beneficioFinanceiro = #LSCurrencyFormat(rsMelhoria.pc_aval_melhoria_beneficioFinanceiro, 'local')#>
														<li >Potencial Benefício Financeiro da Implementação da Proposta de Melhoria: <span style="color:##0692c6;">#beneficioFinanceiro#.</span></li>
													</cfif>

													<cfif rsMelhoria.pc_aval_melhoria_custoFinanceiro gt 0>
														<cfset custoEstimado = #LSCurrencyFormat(rsMelhoria.pc_aval_melhoria_custoFinanceiro, 'local')#>
														<li >Estimativa do Custo Financeiro da Proposta de Melhoria: <span style="color:##0692c6;">#custoEstimado#.</span></li>
													</cfif>
												</div>
											</cfif>

										</cfoutput>
										
										
									</div>

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
			</session><!-- fim card-body2 -->	
					
			

					
		</session>

        
		<script language="JavaScript">
	
			<cfoutput>
				var pc_aval_id = '#arguments.idAvaliacao#';
				var pc_aval_Melhoria_id = '#arguments.idMelhoria#';
				var pc_processo_id = '#arguments.idProcesso#';
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

			
			function mostraInformacoesMelhoria(idMelhoria){
				
				$('#modalOverlay').modal('show')
				
				$('#informacoesMelhoriasDiv').html('');
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcControleDistribuicao.cfc",
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
				$("#custom-tabs-one-Melhoria-tab").click(function() {
					$('html, body').animate({
						scrollTop: ($('#custom-tabs-one-Melhoria-tab').offset().top) - 60
					}, 1000);
				});

				$('#custom-tabs-one-InfProcesso-tab').click(function() {
					mostraInfoProcesso('infoProcessoDiv',pc_processo_id,'custom-tabs-one-InfProcesso-tab');
				});
				$('#custom-tabs-one-InfItem-tab').click(function() {
					mostraInfoItem('infoItemDiv',pc_processo_id,pc_aval_id,'custom-tabs-one-InfItem-tab');
				});
				$('#custom-tabs-one-Avaliacao-tab').click(function() {
					mostraRelatoPDF('anexoAvaliacaoDiv',pc_aval_id,'S','custom-tabs-one-Avaliacao-tab');
				});
				$('#custom-tabs-one-Anexos-tab').click(function() {
					//se ir da orientação for '', a função retorna apenas os anexos dos itens
					mostraTabAnexosJS('tabAnexosDiv',pc_aval_id,'','custom-tabs-one-Anexos-tab');
				});
				
				
				mostraInformacoesMelhoria(pc_aval_Melhoria_id)

				$('#pcOrgaoRespDistribuicao').select2({
					theme: 'bootstrap4',
					placeholder: 'Selecione as áreas para distribuição da orientação...',
					allowClear: true // Opcional - permite desmarcar a seleção
				});

				$('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
					var target = $(e.target).attr("href") // activated tab
					if (target == '#content-responder') {
						$('html, body').animate({
							scrollTop: $("#btSalvarMelhoriaPosic").offset().top
						}, 1000);
					}
				});

				$('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
					var target = $(e.target).attr("href") // activated tab
					if (target == '#content-distribuicao') {
						$('html, body').animate({
							scrollTop: $("#btEnviarDistribuicaoMelhoria").offset().top
						}, 1000);
					}
				});
				
			})

			

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
					
					<div class="card card-success" style="margin-bottom:10px">
						<div class="card-header" style="background-color:#0083CA;">
							<h4 class="card-title ">
								<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:16px;color:#fff;font-weight: bold;"> 
									<i class="fas fa-user-pen" style="margin-top:4px;font-size: 20px;"></i><span style="margin-left:5px">INSERIR MANIFESTAÇÃO DO ÓRGÃO: <cfoutput>#application.rsUsuarioParametros.pc_org_sigla#</cfoutput></span>
								</a>
							</h4>
						</div>	
					
					    <cfquery datasource="#application.dsn_processos#" name="rsManifestacaoSalva">
							Select pc_avaliacao_posicionamentos.*, pc_orgaos.pc_org_sigla, pc_usuarios.pc_usu_nome FROM pc_avaliacao_posicionamentos 
							INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_posic_num_orgao
							INNER JOIN pc_usuarios on pc_usu_matricula = pc_aval_posic_matricula
							WHERE pc_aval_posic_num_orientacao = #arguments.pc_aval_orientacao_id# and pc_aval_posic_enviado = 0
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
					url: "cfc/pc_cfcControleDistribuicao.cfc?method=uploadArquivosOrientacao", // Set the url
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
					mostraTabAnexosJS('tabAnexosDiv',pc_anexo_avaliacao_id,'','');
					
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
									url: "cfc/pc_cfcControleDistribuicao.cfc",
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

				if ($('#pcOrientacaoStatus').val() == 5 & !$('#pcDataPrevRespAcomp').val())
				{   
					//mostra mensagem de erro, se algum campo necessário nesta fase  não estiver preenchido	
					toastr.error('Todos os campos devem ser preenchidos!');
					return false;
				}
					
			
				var mensagem = "Deseja enviar esta manifestação?"
				

				<cfoutput>
					var   pc_aval_id = '#rsProc.pc_aval_id#';
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
									url: "cfc/pc_cfcControleDistribuicao.cfc",
									data:{
										method:"cadPosicOrgaoAvaliado",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:statusOrientacao,
										pc_aval_orientacao_dataPrevistaResp: $('#pcDataPrevRespAcomp').val(),
										idAnexos: idAnexosString
										
									},
						
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#pcPosicAcomp').val('')
									
									exibirTabela()
									$('#infItensOrientacoesDistribuidasDiv').html('')
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
									url: "cfc/pc_cfcControleDistribuicao.cfc",
									data:{
										method:"cadPosicOrgaoAvaliado",
										pc_aval_orientacao_id: pc_aval_orientacao_id,
										pc_aval_posic_texto: $('#pcPosicAcomp').val(),
										pc_aval_orientacao_status:statusOrientacao,
										idAnexos: idAnexosString
									},
									async: false
									
								})//fim ajax
								.done(function(result) {	
									$('#pcPosicAcomp').val('')
									exibirTabela()
									$('#infItensOrientacoesDistribuidasDiv').html('')
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
						url: "cfc/pc_cfcControleDistribuicao.cfc",
						data:{
							method: "tabOrientacoesDistribuidas",
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
		<cfargument name="pc_aval_orientacao_mcu_orgaoResp" type="string" required="false" default=''/>
		<cfargument name="pc_aval_orientacao_dataPrevistaResp" type="string" required="false"  default=null/>
		<cfargument name="pc_aval_orientacao_status" type="numeric" required="true" />
		<cfargument name="idAnexos" type="string" required="true">
		
    	<cftransaction>

			<cfquery datasource = "#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_posicionamentos 
				WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> and pc_aval_posic_enviado = 0
			</cfquery>

			<cfquery datasource = "#application.dsn_processos#" name="rsOrgao">
				SELECT 	pc_orgaos.* FROM pc_orgaos WHERE pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_aval_orientacao_mcu_orgaoResp#">
			</cfquery>
			<cfif '#arguments.pc_aval_orientacao_mcu_orgaoResp#' neq ''>
				<cfset data="#DateFormat(arguments.pc_aval_orientacao_dataPrevistaResp,'DD-MM-YYYY')#">
				<cfset textoPosic = "#arguments.pc_aval_posic_texto#">
				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_num_orgaoResp, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status, pc_aval_posic_enviado)
				
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_mcu_orgaoResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_dataPrevistaResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">
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
						pc_aval_orientacao_dataPrevistaResp = <cfqueryparam value="#arguments.pc_aval_orientacao_dataPrevistaResp#" cfsqltype="cf_sql_varchar">
					WHERE 
						pc_aval_orientacao_id = <cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">

				</cfquery>


			<cfelse>

				<cfset textoPosic = "#arguments.pc_aval_posic_texto#">

				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_status, pc_aval_posic_enviado)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">
					)
					SELECT SCOPE_IDENTITY() AS idPosic;
				
				</cfquery>

				<cfquery datasource = "#application.dsn_processos#" >
					UPDATE 	pc_avaliacao_orientacoes
					SET 
						pc_aval_orientacao_status = <cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">,
						pc_aval_orientacao_status_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						pc_aval_orientacao_atualiz_login = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">
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
		<cfargument name="idAnexos" type="string" required="true">

		<cfquery datasource = "#application.dsn_processos#" name="rsPosicNaoEnviada">
			SELECT pc_aval_posic_id, pc_aval_posic_enviado FROM pc_avaliacao_posicionamentos 
			WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> and pc_aval_posic_enviado = 0
		</cfquery>
		
    	<cftransaction>
			<cfset textoPosic = "#arguments.pc_aval_posic_texto#">

			<cfif rsPosicNaoEnviada.recordcount eq 0>
				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_status)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">
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
						pc_aval_posic_status = <cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_varchar">
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
		<cfargument name="idAnexos" type="string" required="true">

		<cfset textoPosic = "#arguments.pc_aval_posic_texto#">
		<cftransaction>
			<cfquery datasource = "#application.dsn_processos#" >
				DELETE FROM pc_avaliacao_posicionamentos 
				WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> and pc_aval_posic_enviado = 0
			</cfquery>
			<cfif '#arguments.pc_aval_orientacao_dataPrevistaResp#' neq ''>
				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_dataPrevistaResp, pc_aval_posic_status,  pc_aval_posic_enviado)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_dataPrevistaResp#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">
					)
					SELECT SCOPE_IDENTITY() AS idPosic;
				</cfquery>
			<cfelse>

				<cfquery datasource = "#application.dsn_processos#" name="rsCadPosic">
					INSERT pc_avaliacao_posicionamentos	(pc_aval_posic_num_orientacao, pc_aval_posic_texto, pc_aval_posic_dataHora, pc_aval_posic_matricula, pc_aval_posic_num_orgao, pc_aval_posic_status,  pc_aval_posic_enviado)
					VALUES (
						<cfqueryparam value="#arguments.pc_aval_orientacao_id#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#textoPosic#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.pc_aval_orientacao_status#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="1" cfsqltype="cf_sql_integer">
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








</cfcomponent>