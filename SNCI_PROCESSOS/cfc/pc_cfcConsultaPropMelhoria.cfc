<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	



    <cffunction name="tabMelhoriasConsulta" access="remote" hint="Criar a tabela das propostas de melhoria e envia para a página pc_ConsultarMelhorias.cfm">
		<cfquery name="getOrgHierarchy" datasource="#application.dsn_processos#" timeout="120">
			WITH OrgHierarchy AS (
				SELECT pc_org_mcu, pc_org_mcu_subord_tec
				FROM pc_orgaos
				WHERE pc_org_mcu_subord_tec = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
				UNION ALL
				SELECT o.pc_org_mcu, o.pc_org_mcu_subord_tec
				FROM pc_orgaos o
				INNER JOIN OrgHierarchy oh ON o.pc_org_mcu_subord_tec = oh.pc_org_mcu
			)
			SELECT pc_org_mcu
			FROM OrgHierarchy
		</cfquery>

		<cfset orgaosHierarquiaList = ValueList(getOrgHierarchy.pc_org_mcu)>

		<cfquery name="rsMelhorias" datasource="#application.dsn_processos#" timeout="120">
			SELECT pc_avaliacao_melhorias.*
            , pc_processos.*
			,pc_avaliacoes.pc_aval_numeracao , pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla,  pc_orgaos.pc_org_mcu
			, pc_orgaos_origem.pc_org_sigla as orgaoOrigemSigla
			, pc_orgaos_origem.pc_org_mcu as orgaoOrigemMcu
			, pc_orgaos_avaliado.pc_org_sigla as orgaoAvaliadoSigla
			, pc_orgaos_avaliado.pc_org_mcu as orgaoAvaliadoMcu

			FROM pc_avaliacao_melhorias
			INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			INNER JOIN pc_orgaos AS pc_orgaos_origem ON pc_orgaos_origem.pc_org_mcu = pc_num_orgao_origem
			INNER JOIN pc_orgaos AS pc_orgaos_avaliado ON pc_orgaos_avaliado.pc_org_mcu = pc_num_orgao_avaliado
			
			WHERE NOT pc_num_status IN (2,3) 
			
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND right(pc_processo_id,4) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>
			
			
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se a lotação do usuario for um orgao origem de processos (status 'O' -> letra 'o' de Origem) e o perfil não for 11 - CI - MASTER ACOMPANHAMENTO (DA GPCI)--->
				<cfif '#application.rsUsuarioParametros.pc_org_status#' eq 'O' and #application.rsUsuarioParametros.pc_usu_perfil# neq 11>
					AND pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'
				</cfif>
				
				<!---Se o perfil for 4 - 'CI - AVALIADOR (EXECUÇÃO)') --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 >
					AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
				</cfif>

				<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1)'  ou 14 -'CI - REGIONAL - SCIA - Acompanhamento'--->
				<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_num_orgao_origem IN('00436698','00436697','00438080') AND (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#))
				</cfif>

			<cfelse>
				AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6)
				<!---Se o perfil do usuário não for 13 - GOVERNANÇA --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 13 >
					AND (
							pc_processos.pc_num_orgao_avaliado = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR  pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
							OR pc_aval_melhoria_sug_orgao_mcu = '#application.rsUsuarioParametros.pc_usu_lotacao#'
							<cfif getOrgHierarchy.recordCount gt 0> 
								OR pc_processos.pc_num_orgao_avaliado in (#orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao in (#orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu in (#orgaosHierarquiaList#)
							</cfif>
						)
					<!---Se o perfil for 15 - 'DIRETORIA') e se o órgão do usuário tiver órgãos hierarquicamente inferiores e se a diretoria for a DIGOE --->
					<cfif getOrgHierarchy.recordCount gt 0 and 	application.rsUsuarioParametros.pc_usu_perfil eq 15 and application.rsUsuarioParametros.pc_usu_lotacao eq '00436685' >
							
							and NOT (
									pc_processos.pc_num_orgao_avaliado not in (#orgaosHierarquiaList#)
								OR pc_aval_melhoria_num_orgao not in (#orgaosHierarquiaList#)
								OR pc_aval_melhoria_sug_orgao_mcu  not in (#orgaosHierarquiaList#)
								)
							
					</cfif>	
				</cfif>
			</cfif>
			
			ORDER BY 	pc_processo_id, pc_aval_numeracao
		</cfquery>
		
		<div class="row" >
		    <div id="filtroSpan" style="display: none;text-align:right;font-size:18px;position:absolute;top:123px;right:24px;"><span class="statusOrientacoes" style="background:#2581c8;color:#fff;">Atenção! Um filtro foi aplicado.</span><br><i class="fa fa-2x fa-hand-point-down" style="color:#2581c8;position:relative;top:8px;right:117px"></i></div>
			
			<div class="col-12">
				<div class="card"  >
				    
					<!-- /.card-header -->
					<div class="card-body" >

						<cfif #rsMelhorias.recordcount# eq 0 >
							<h5 align="center">Nenhuma Proposta de Melhoria foi localizada para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
						<cfelse>
							<table id="tabMelhorias" style="width:100%;overflow: hidden;" class="table table-bordered table-striped table-hover text-nowrap">
								<thead style="background: #0083ca;color:#fff">
									<tr style="font-size:14px">
									    <th id="colunaStatusProposta">Status:</th>
										<th >ID</th>
										<th >N° Processo SNCI</th>
										<th >N° Item</th>	
										<th>Órgão Responsável</th>
										<th >SE/CS</th>
										<th >N° SEI</th>
										<th >Data Prev.</th>
										<th >Órgão Origem</th>
										<th >Órgão Avaliado</th>
										
									</tr>
								</thead>
								
								<tbody>
									<cfloop query="rsMelhorias" >
										<cfoutput>					
										    <cfswitch expression="#pc_aval_melhoria_status#">
												<cfcase value="P">
													<cfset statusMelhoria = "PENDENTE">
													<cfset corStatusMelhoria = "background:##dc3545;color:##fff;">
												</cfcase>
												<cfcase value="A">
													<cfset statusMelhoria = "ACEITA">
													<cfset corStatusMelhoria = "background:green;color:##fff;">
												</cfcase>
												<cfcase value="R">
													<cfset statusMelhoria = "RECUSA">
													<cfset corStatusMelhoria = "background:##000;color:##fff;">
												</cfcase>
												<cfcase value="T">
													<cfset statusMelhoria = "TROCA">
													<cfset corStatusMelhoria = "background:##fbc32f;color:##000;">
												</cfcase>
												<cfcase value="N">
													<cfset statusMelhoria = "NÃO INFORMADO">
													<cfset corStatusMelhoria = "background:##000;color:##fff;">
												</cfcase>
												<cfcase value="B">
													<cfset statusMelhoria = "BLOQUEADO">
													<cfset corStatusMelhoria = "background:##dc3545;color:##fff;">
												</cfcase>
												<cfdefaultcase>
													<cfset statusMelhoria = "">	
												</cfdefaultcase>
												
											</cfswitch>
											<tr style="font-size:12px;cursor:pointer;z-index:2;"  onclick="javascript:mostraInfMelhoriaAcomp(#pc_aval_melhoria_id#)">
												<td id="statusMelhorias"align="center" >
													<span  class="statusOrientacoes" style="#corStatusMelhoria#">#statusMelhoria#</span>
												</td>
												<td align="center">#pc_aval_melhoria_id#</td>	
												<td align="center">#pc_processo_id#</td>
												<td align="center">#pc_aval_numeracao#</td>
												
												<td align="center">#pc_org_sigla# (#pc_org_mcu#)</td>
												<td align="center">#pc_org_se_sigla#</td>
												

												<cfif #rsMelhorias.pc_modalidade# eq 'A' or #rsMelhorias.pc_modalidade# eq 'E'>
													<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
													<td align="center">#sei#</td>
												<cfelse>
													<td align="center"></td>
												</cfif>
												<cfif pc_aval_melhoria_dataPrev neq ''>
													<cfset dataPrev = DateFormat(#pc_aval_melhoria_dataPrev#,'DD-MM-YYYY')>
													<td>#dataPrev#</td>
												<cfelse>
													<td>Não Informado</td>	
												</cfif>
												<td>#orgaoOrigemSigla#</td>	
												<td>#orgaoAvaliadoSigla#</td>

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
				
				var tituloExcel = "SNCI_Consulta_Propostas_Melhoria_";
				var colunasMostrar = [0,4,5];
				

				const tabMelhoriasConsulta = $('#tabMelhorias').DataTable( {
				
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

			function mostraInfMelhoriaAcomp(idMelhoria){
				$('#tabMelhorias tr').each(function () {
					$(this).removeClass('selected');
				}); 
				$('#tabMelhorias tbody').on('click', 'tr', function () {
					$(this).addClass('selected');
				});
				$('#modalOverlay').modal('show')
				
				$('#informacoesMelhoriasConsultaDiv').html('');
				setTimeout(function() {
					$.ajax({
						type: "post",
						url: "cfc/pc_cfcConsultaPropMelhoria.cfc",
						data:{
							method: "informacoesItensMelhoriaConsulta",
							idMelhoria: idMelhoria
						},
						async: false
					})//fim ajax
					.done(function(result) {
						$('#informacoesMelhoriasConsultaDiv').html(result)
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

	<cffunction name="informacoesItensMelhoriaConsulta"   access="remote" hint="envia para a página acomanhamento.cfm tabs com informações do item.">
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
									<a  class="nav-link  active" id="custom-tabs-one-Melhoria-tab"  data-toggle="pill" href="#custom-tabs-one-Melhoria" role="tab" aria-controls="custom-tabs-one-Melhoria" aria-selected="true"> Proposta de Melhoria: ID <cfoutput><strong>#rsProcAval.pc_aval_melhoria_id#</strong> - #rsProcAval.siglaOrgResp# (#rsProcAval.mcuOrgResp#)</cfoutput></a>
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
												<div style=" display: inline;background-color: ##e83e8c;color:##fff;padding: 3px;">Proposta de melhoria distribuída pelo órgão subordinador:</div>
											</cfif>
										</cfoutput>
							            <div  style="" >
											<cfoutput>
												
												<cfif rsProcAval.pc_aval_melhoria_status eq 'T'>
												    <div style="">Proposta de Melhoria Sugerida pelo Controle Interno:</div>
													<pre style="font-size: 1.3em;">#rsProcAval.pc_aval_melhoria_descricao#</pre>
													<div style="">Proposta de Melhoria Sugerida pelo Órgão Responsável:</div>
													<pre style="font-size: 1.3em;">#rsProcAval.pc_aval_melhoria_sugestao#</pre>
												<cfelseif rsProcAval.pc_aval_melhoria_status eq 'R'>
													<div style="">Proposta de Melhoria Sugerida pelo Controle Interno:</div>
													<pre style="font-size: 1.3em;">#rsProcAval.pc_aval_melhoria_descricao#</pre>
													<div style="">Justificativa do órgão para Recusa:</div>
													<cfif rsProcAval.pc_aval_melhoria_naoAceita_justif neq ''>
														<pre style="font-size: 1.3em;">#rsProcAval.pc_aval_melhoria_naoAceita_justif#</pre>
													<cfelse>
														<pre style="font-size: 1.3em;">Não Informado</pre>
													</cfif>
												<cfelse>
													<pre style="font-size: 1.3em;">#rsProcAval.pc_aval_melhoria_descricao#</pre>
												</cfif>
											</cfoutput>


										</div>
										<cfif rsProcAval.pc_aval_melhoria_status eq 'P'>
											<cfif application.rsOrgaoSubordinados.recordcount eq 0>	
												<h6 style="color:#ff0080;padding:10px;line-height:1.7;">Obs.: A implementação das propostas de melhoria não são acompanhadas pelo SNCI.
												Caso o status seja 'PENDENTE', o órgão responsável necessita selecionar um status (Aceita / Troca / Recusa), em <span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>, aba "Propostas de Melhoria".</h6>
											<cfelse>
												<h6 style="color:#ff0080;padding:10px;line-height:1.7;">Obs.: A implementação das propostas de melhoria não são acompanhadas pelo SNCI.
												Caso o status seja 'PENDENTE', o órgão responsável, se for um órgão subordinador, necessita selecionar a aba "Propostas de Melhoria" em <span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span> e
												selecionar umas das abas: "Responder" (e selecionar um status: Aceita / Troca / Recusa) ou "Distribuir". Caso o órgão responsável não seja um órgão subordinador, o mesmo necessita selecionar um status (Aceita / Troca / Recusa), em <span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>, aba "Propostas de Melhoria".</h6>
												
												</h6>
											</cfif>
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
																
																<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S' >	
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

			

			$(document).ready(function() {
				<cfoutput>
					var idMelhoria = #arguments.idMelhoria#;
				</cfoutput>	
				
				mostraRelatoPDF();
				mostraTabAnexos();
		
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

		


		</script>

    </cffunction>

	
</cfcomponent>