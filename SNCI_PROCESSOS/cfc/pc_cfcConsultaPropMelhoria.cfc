<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">	



    <cffunction name="tabMelhoriasConsulta" access="remote" hint="Criar a tabela das propostas de melhoria e envia para a página pc_ConsultarMelhorias.cfm">
		<cfset var rsMelhorias = "">
		<cfset var statusMelhoria = "">
		<cfset var corStatusMelhoria = "">
		<cfset var sei = "">
		<cfset var dataHora = "">
		<cfset var dataFormatada = "">

		<cfquery name="rsMelhorias" datasource="#application.dsn_processos#" timeout="120">
			SELECT pc_avaliacao_melhorias.*
					,pc_processos.*
					,pc_avaliacoes.pc_aval_numeracao 
					,pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla
					,pc_orgaos.pc_org_mcu
					,pc_avaliacoes.pc_aval_id
					,pc_orgaos_origem.pc_org_sigla as orgaoOrigemSigla
					,pc_orgaos_origem.pc_org_mcu as orgaoOrigemMcu
					,pc_orgaos_avaliado.pc_org_sigla as orgaoAvaliadoSigla
					,pc_orgaos_avaliado.pc_org_mcu as orgaoAvaliadoMcu

			FROM pc_avaliacao_melhorias
			LEFT JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
			LEFT JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			LEFT JOIN pc_processos on pc_processo_id = pc_aval_processo
			LEFT JOIN pc_orgaos AS pc_orgaos_origem ON pc_orgaos_origem.pc_org_mcu = pc_num_orgao_origem
			LEFT JOIN pc_orgaos AS pc_orgaos_avaliado ON pc_orgaos_avaliado.pc_org_mcu = pc_num_orgao_avaliado
			
			WHERE NOT pc_num_status IN (2,3) 
			
			<cfif '#arguments.ano#' neq 'TODOS'>
					AND pc_processo_ano = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ano#">
			</cfif>
			
			
			<cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
				<!---Se o perfil for 16 - 'CI - CONSULTAS', mostra todas as orientações--->
				<cfif ListFind("16",#application.rsUsuarioParametros.pc_usu_perfil#) >
					AND pc_processo_id IS NOT NULL 
				<cfelse>
										
					<!---Se o perfil for 4 - 'CI - AVALIADOR (EXECUÇÃO)') --->
					<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 4 >
						AND pc_avaliador_matricula = #application.rsUsuarioParametros.pc_usu_matricula#	or pc_usu_matricula_coordenador = #application.rsUsuarioParametros.pc_usu_matricula# or pc_usu_matricula_coordenador_nacional = #application.rsUsuarioParametros.pc_usu_matricula#
					</cfif>

					<!---Se o perfil for 7 - 'CI - REGIONAL (Gestor Nível 1)'  ou 14 -'CI - REGIONAL - SCIA - Acompanhamento'--->
					<cfif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#) >
						AND pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)
					</cfif>
				</cfif>

			<cfelse>
				AND pc_aval_melhoria_status not in('B') AND  pc_num_status not in(6)
				<!---Se o perfil do usuário não for 13 - GOVERNANÇA --->
				<cfif #application.rsUsuarioParametros.pc_usu_perfil# neq 13 >
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
			
			ORDER BY 	pc_processo_id, pc_aval_numeracao
		</cfquery>

		<div class="row" >
		   
			<div class="col-12">
				<div class="card"  style="margin-bottom:50px;">
				    
					<!-- /.card-header -->
					<div class="card-body" >

						<cfif #rsMelhorias.recordcount# eq 0 >
							<h5 align="center">Nenhuma Proposta de Melhoria foi localizada para <cfoutput>#application.rsUsuarioParametros.pc_org_sigla# e perfil: #application.rsUsuarioParametros.pc_perfil_tipo_descricao#</cfoutput>.</h5>
						<cfelse>
						    <div id="filtroSpan" style="display: none;text-align:right;font-size:18px;position:absolute;top:-54px;right:24px;"><span class="statusOrientacoes" style="background:#008000;color:#fff;">Atenção! Um filtro foi aplicado.</span><br><i class="fa fa-2x fa-hand-point-down" style="color:#008000;position:relative;top:8px;right:117px"></i></div>
			
							<table id="tabMelhorias" class="table table-striped table-hover text-nowrap table-responsive">
								
								<thead  class="table_thead_backgroundColor">
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
										    <cfset statusMelhoria = "">
											<cfset corStatusMelhoria = "">		
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
													<cfset statusMelhoria = "NÃO INFORMADO">
													<cfset corStatusMelhoria = "background:##000;color:##fff;">
												</cfdefaultcase>
												
											</cfswitch>
											<tr style="font-size:12px;cursor:pointer;z-index:2;"  onclick="javascript:mostraInfMelhoriaAcomp('#pc_processo_id#',#pc_aval_id#,#pc_aval_melhoria_id#)">
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
												    <cfset dataHora = pc_aval_melhoria_dataPrev>
													<cfset dataFormatada = DateFormat(dataHora, "dd/mm/yyyy")>
													<td data-order="#DateFormat(dataHora, 'yyyy-mm-dd')#">#dataFormatada#</td>
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
	       			autoWidth: true,// Ajustar automaticamente o tamanho das colunas
					pageLength: 5,
					dom: 
						"<'row d-flex align-items-center'<'col-auto dtsp-verticalContainer'P><'col-auto'B><'col-auto'f><'col-auto'p>>" + // Botões, filtros e paginação na mesma linha, alinhados à esquerda
						"<'row'<'col-12'i>>" + // Informações logo abaixo dos botões
						"<'row'<'col-12'tr>>",  // Tabela com todos os dados
							
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
					
					searchPanes: {
						cascadePanes: true, // Exibir apenas opções que combinam com os filtros anteriores
						columns: colunasMostrar,// Colunas que terão filtro
						threshold: 1,// Número mínimo de registros para exibir Painéis de Pesquisa
						layout: 'columns-1', //layout do filtro com uma coluna
						initCollapsed: true, // Colapsar Painéis de Pesquisa
					},
					initComplete: function () {// Função executada ao finalizar a inicialização do DataTable
						initializeSearchPanesAndSidebar(this)//inicializa o searchPanes dentro do controlSidebar
						$('#exibirTab').show();
						$('#exibirTabSpinner').html('');
					},
					language: {
						url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
					}

				})
			
			});

			
			function mostraInfMelhoriaAcomp(idProcesso,idAvaliacao,idMelhoria){
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
							idMelhoria: idMelhoria,
							idAvaliacao: idAvaliacao,
							idProcesso: idProcesso
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
		<cfargument name="idAvaliacao" type="numeric" required="true" />
		<cfargument name="idMelhoria" type="numeric" required="true" />
		<cfargument name="idProcesso" type="string" required="true" />

		<cfset var rsMelhoria = "">
		<cfset var categoriaControleList = "">
		<cfset var rsCategoriaControle = "">
		<cfset var rsItemNum = "">

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
					background-color: var(--azul_claro_correios)!important;
					border: 1px solid #ced4da!important;
					border-radius: 5px!important;
					padding: 5px!important;
					width: auto!important;
				}
			
			</style>
				
			
			<div class="card card-primary card-tabs card_border_correios"  style="width:100%">
				<div class="card-header p-0 pt-1 card-header_backgroundColor" >
					
					<ul class="nav nav-tabs" id="custom-tabs-one-tab" role="tablist" style="font-size:14px;">
						<li class="nav-item" >
							<a  class="nav-link  active" id="custom-tabs-one-Melhoria-tab"  data-toggle="pill" href="#custom-tabs-one-Melhoria" role="tab" aria-controls="custom-tabs-one-Melhoria" aria-selected="true"> Proposta de Melhoria: ID <cfoutput><strong>#rsMelhoria.pc_aval_melhoria_id#</strong> - #rsMelhoria.siglaOrgResp# (#rsMelhoria.mcuOrgResp#)</cfoutput></a>
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
							<a  class="nav-link " id="custom-tabs-one-Anexos-tab"  data-toggle="pill" href="#custom-tabs-one-Anexos" role="tab" aria-controls="custom-tabs-one-Anexos" aria-selected="true">Anexos do Item <cfoutput>#rsItemNum.pc_aval_numeracao#</cfoutput></a>
						</li>
						
					</ul>
					
				</div>
				<div class="card-body ">
					<div class="tab-content" id="custom-tabs-one-tabContent">
						<div disable class="tab-pane fade  active show" id="custom-tabs-one-Melhoria"  role="tabpanel" aria-labelledby="custom-tabs-one-Melhoria-tab" >														
							<div class="col-md-12">
								<cfoutput>
									<cfif rsMelhoria.pc_aval_melhoria_distribuido eq 1>
										<div style=" display: inline;background-color: ##e83e8c;color:##fff;padding: 3px;">Proposta de melhoria distribuída pelo órgão subordinador:</div>
									</cfif>
								</cfoutput>
								<div  style="" >
									<cfoutput>
										<fieldset style="padding:0px!important;min-height: 90px;">
											<legend style="margin-left:20px">Proposta de Melhoria Sugerida pelo Controle Interno:</legend>                                         
											<pre class="font-weight-light azul_claro_correios_textColor" style="font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsMelhoria.pc_aval_melhoria_descricao#</pre>
										</fieldset>
										<cfif rsMelhoria.pc_aval_melhoria_status eq 'T'>
											<fieldset style="padding:0px!important;min-height: 90px;">
												<legend style="margin-left:20px">Proposta de Melhoria Sugerida pelo Órgão Responsável:</legend>                                         
												<pre class="font-weight-light azul_claro_correios_textColor" style="font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsMelhoria.pc_aval_melhoria_sugestao#</pre>
											</fieldset>
										<cfelseif rsMelhoria.pc_aval_melhoria_status eq 'R'>
											<fieldset style="padding:0px!important;min-height: 90px;">
												<legend style="margin-left:20px">Justificativa do órgão para Recusa:</legend> 
												<cfif rsMelhoria.pc_aval_melhoria_naoAceita_justif neq ''>                                        
													<pre class="font-weight-light azul_claro_correios_textColor" style="font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsMelhoria.pc_aval_melhoria_naoAceita_justif#</pre>
												<cfelse>
													<pre class="font-weight-light azul_claro_correios_textColor" style="font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">Não Informado</pre>
												</cfif>
											</fieldset>
										<cfelse>
											
										</cfif>

										<cfset anoProcesso = RIGHT(#arguments.idProcesso#,4)>
										<cfif #anoProcesso# gte 2024 and rsCategoriaControle.recordcount gt 0> 
											<cfif rsMelhoria.pc_aval_melhoria_beneficioNaoFinanceiro neq ''>
												<fieldset style="padding:0px!important;min-height: 90px;">
													<legend style="margin-left:20px">Benefício Não Financeiro da Proposta de Melhoria:</legend>                                         
													<pre class="font-weight-light azul_claro_correios_textColor" style="font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsMelhoria.pc_aval_melhoria_beneficioNaoFinanceiro#</pre>
												</fieldset>
											<cfelse>
												<fieldset style="padding:0px!important;min-height: 90px;">
													<legend style="margin-left:20px">Benefício Não Financeiro da Proposta de Melhoria:</legend>                                         
													<pre class="font-weight-light azul_claro_correios_textColor" style="font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">Não se aplica</pre>
												</fieldset>
											</cfif>
											<div style="margin-bottom:20px">
												<li >Categoria(s) do Controle Proposto: <span style="color:##0692c6;">#categoriaControleList#.</span></li>

												<cfif rsMelhoria.pc_aval_melhoria_beneficioFinanceiro gt 0>
													<cfset beneficioFinanceiro = #LSCurrencyFormat(rsMelhoria.pc_aval_melhoria_beneficioFinanceiro, 'local')#>
													<li >Potencial Benefício Financeiro da Implementação da Proposta de Melhoria: <span style="color:##0692c6;">#beneficioFinanceiro#.</span></li>
												<cfelse>
													<li >Potencial Benefício Financeiro da Implementação da Proposta de Melhoria: <span style="color:##0692c6;">Não se aplica.</span></li>
												</cfif>

												<cfif rsMelhoria.pc_aval_melhoria_custoFinanceiro gt 0>
													<cfset custoEstimado = #LSCurrencyFormat(rsMelhoria.pc_aval_melhoria_custoFinanceiro, 'local')#>
													<li >Estimativa do Custo Financeiro da Proposta de Melhoria: <span style="color:##0692c6;">#custoEstimado#.</span></li>
												<cfelse>
													<li >Estimativa do Custo Financeiro da Proposta de Melhoria: <span style="color:##0692c6;">Não se aplica.</span></li>
												</cfif>
											</div>
										</cfif>

									</cfoutput>


								</div>
								<cfif rsMelhoria.pc_aval_melhoria_status eq 'P'>
									<div class="alert alert-warning d-inline-flex  align-items-center" >
										<cfif application.rsOrgaoSubordinados.recordcount eq 0>	
											<p style="line-height:1.7;font-size:1.3em">A implementação das propostas de melhoria não são acompanhadas pelo SNCI.
												Caso o status seja 'PENDENTE', o órgão responsável necessita selecionar um status (Aceita / Troca / Recusa), em 
												<span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>, aba "Propostas de Melhoria".
											</p>
										<cfelse>
											<p style="line-height:1.7;font-size:1.3em">A implementação das propostas de melhoria não são acompanhadas pelo SNCI.
												Caso o status seja 'PENDENTE', o órgão responsável, se for um órgão subordinador, necessita selecionar a aba "Propostas de Melhoria" em 
												<span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span> e
												selecionar umas das abas: "Responder" (e selecionar um status: Aceita / Troca / Recusa) ou "Distribuir". Caso o órgão responsável não seja um órgão subordinador, o mesmo necessita selecionar um status (Aceita / Troca / Recusa), em <span class="statusOrientacoes" style="color:#fff;background-color:#0e406a;padding:3px;font-size:1em;margin-right:10px;"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>, aba "Propostas de Melhoria".</p>
											</p>
										</cfif>
									</div>
								</cfif>
								
								
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
	

        
		<script language="JavaScript">
	
			<cfoutput>
				var pc_aval_id = '#arguments.idAvaliacao#';
				var pc_aval_Melhoria_id = '#arguments.idMelhoria#';
				var pc_processo_id = '#arguments.idProcesso#';
			</cfoutput>

			

			$(document).ready(function() {
				<cfoutput>
					var idMelhoria = #arguments.idMelhoria#;
				</cfoutput>	
				
				$("#custom-tabs-one-Melhoria-tab").click(function() {
					$('html, body').animate({
						scrollTop: ($('#custom-tabs-one-Melhoria-tab').offset().top) - 60
					}, 1000);
				});
		
				$('#custom-tabs-one-InfProcesso-tab').click(function() {
					mostraInfoProcesso('infoProcessoDiv',pc_processo_id, 'custom-tabs-one-InfProcesso-tab');
				});
				$('#custom-tabs-one-InfItem-tab').click(function() {
					mostraInfoItem('infoItemDiv',pc_processo_id,pc_aval_id, 'custom-tabs-one-InfItem-tab');
				});
				$('#custom-tabs-one-Avaliacao-tab').click(function() {
					mostraRelatoPDF('anexoAvaliacaoDiv',pc_aval_id,'S', 'custom-tabs-one-Avaliacao-tab');
				});
				$('#custom-tabs-one-Anexos-tab').click(function() {
					//se ir da orientação for '', a função retorna apenas os anexos dos itens
					mostraTabAnexosJS('tabAnexosDiv',pc_aval_id,'', 'custom-tabs-one-Anexos-tab');
				});

			})

		


		</script>

    </cffunction>

	
</cfcomponent>