<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">

	

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


	<cffunction name="alertasOA"   access="remote" hint="mostra alertas para os órgão avaliados na página index.">
        <cfquery datasource="#application.dsn_processos#" name="qPosicionamentos">
			select pc_avaliacao_orientacoes.*, pc_orientacao_status.*, pc_processos.pc_num_status  from pc_avaliacao_orientacoes
			inner join pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
			inner join pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			inner join pc_processos on pc_processo_id = pc_aval_processo
			where pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar"> AND pc_aval_orientacao_status in (4,5) AND pc_num_status in(4)
		</cfquery> 

		<cfquery datasource="#application.dsn_processos#" name="qPosicionamentosSubordinados">
			select pc_avaliacao_orientacoes.*, pc_orientacao_status.*, pc_orgaos.*, pc_processos.pc_num_status from pc_avaliacao_orientacoes
			inner join pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
			inner join pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
			inner join pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			inner join pc_processos on pc_processo_id = pc_aval_processo
			where pc_aval_orientacao_status in (4,5) AND pc_aval_orientacao_mcu_orgaoResp in (#orgaosHierarquiaList#) AND pc_num_status in(4)
		</cfquery> 

		<cfquery name="qMelhoriasPendentes" datasource="#application.dsn_processos#">
			SELECT pc_avaliacao_melhorias.*, pc_processos.pc_modalidade, pc_processos.pc_processo_id, pc_processos.pc_num_sei
			,pc_avaliacoes.pc_aval_numeracao , pc_orgaos.pc_org_sigla, pc_orgaos.pc_org_se_sigla
			FROM pc_avaliacao_melhorias
			INNER JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao
			INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			INNER JOIN pc_processos on pc_processo_id = pc_aval_processo
			LEFT JOIN pc_orgaos_heranca on pc_orgHerancaMcuDe = pc_aval_melhoria_num_orgao
			WHERE pc_aval_melhoria_status = 'P' AND pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#' AND pc_processos.pc_num_status in(4,5)
			
		</cfquery>
	
		<cfif #qPosicionamentos.recordcount# neq 0 || #qPosicionamentosSubordinados.recordcount# neq 0 ||#qMelhoriasPendentes.recordcount# neq 0>     
				<div id="rowAlertaOrgaoAvaliado" class="row" style="margin-top:30px">
					<div class="col-md-12">
						<div class="card card-danger ">
							<div class="card-header">
								<h2 class="card-title"><i class="fa fa-exclamation-triangle" style="color:#fff" ></i> Atenção!</h2>
							</div>
							<!-- /.card-header -->
							<div class="card-body" >
					
								<ul>
									<cfif #qPosicionamentos.recordcount# neq 0>
										
										<cfoutput>
											<cfif #qPosicionamentos.recordcount# eq 1>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existe #qPosicionamentos.recordcount# Orientação para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											<cfelse>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existem #qPosicionamentos.recordcount# Orientações para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											</cfif>
											<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em;margin-right:10px"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>e selecione a aba "Medida/Orientação para Regularização".</span></li>
										
										</cfoutput>
									</cfif>

									<cfif #qPosicionamentosSubordinados.recordcount# neq 0>
										<cfoutput>
											<cfif #qPosicionamentosSubordinados.recordcount# eq 1>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existe #qPosicionamentosSubordinados.recordcount# Orientação para manifestação de órgão subordinado a <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											<cfelse>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existem #qPosicionamentosSubordinados.recordcount# Orientações para manifestação de órgãos subordinados a <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											</cfif>
											<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em;margin-right:10px"><i class="nav-icon fas fa-search"></i> Consultas</span>, depois em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em"><i class="nav-icon fas fa-spinner"></i> Processos Em Acomp.</span>  e escolha a opção <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em"><i class="nav-icon fas fa-spinner"></i> Por Orientação</span></span></li>
										
										</cfoutput>
									</cfif>

									<cfif #qMelhoriasPendentes.recordcount# neq 0>
										
										<cfoutput>
											<cfif #qMelhoriasPendentes.recordcount# eq 1>
												<li style="color:red;"><span  style="color:red;font-size:1.2em">Existe #qMelhoriasPendentes.recordcount# Proposta de Melhoria para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											<cfelse>
												<li style="color:red;"><span  style="color:red;font-size:1.2em">Existem #qMelhoriasPendentes.recordcount# Propostas de Melhoria para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											</cfif>
											<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em;margin-right:10px"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>e selecione a aba "Propostas de Melhoria".</span></li>
										
										</cfoutput>
									</cfif>

									
								</ul>
								
								<cfif #qPosicionamentos.recordcount# neq 0 || #qPosicionamentosSubordinados.recordcount# neq 0>
									<div style="margin-top:20px"><span style="color:red;font-size:1.2em;margin-left:25px">Obs.: Os status que necessitam de manifestação são: <strong>Não Respondido, Tratamento e Pendente</strong>.</span></div>
									
								</cfif>
								
							</div>
							<!-- /.card-body -->
						</div>
						<!-- /.card -->
					</div>
				</div>
		</cfif> 
	</cffunction>


	<cffunction name="alertasCI"   access="remote" hint="mostra alertas para o controle interno na página index.">

		<cfquery datasource="#application.dsn_processos#" name="qPosicionamentos">
			select pc_avaliacao_orientacoes.* from pc_avaliacao_orientacoes
			inner join pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			inner join pc_processos on pc_processo_id = pc_aval_processo
			inner join pc_orgaos on pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp 

			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 or "#application.rsUsuarioParametros.pc_usu_perfil#" eq ''>
				where pc_num_status =4 and pc_org_controle_interno = 'S' and pc_aval_orientacao_status =1
			<cfelse>
				where pc_num_status =4 and pc_num_orgao_origem = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar"> and pc_aval_orientacao_status =1 
			</cfif>

		</cfquery> 

		<cfquery datasource="#application.dsn_processos#" name="qOrgaosSemUsuario">
			SELECT DISTINCT 
			 pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp as mcuOrgaoResp
			,pc_orgaos.pc_org_sigla as siglaOrgaoResp
			,pc_num_orgao_origem as mcuOrigem
			,pc_orgaos2.pc_org_sigla as siglaOrigem
			FROM  pc_avaliacao_orientacoes
			inner join pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
			inner join pc_processos on pc_processo_id = pc_aval_processo
			inner join pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
			inner join pc_orgaos on pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp 
			inner join pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_num_orgao_origem
			LEFT JOIN pc_usuarios on pc_usu_lotacao = pc_aval_orientacao_mcu_orgaoResp
			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 or "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
				WHERE pc_usu_lotacao is null and pc_orientacao_status_finalizador = 'N'
			<cfelse>
				WHERE pc_usu_lotacao is null and pc_orientacao_status_finalizador = 'N' 
				and pc_num_orgao_origem = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
			</cfif>
		   
		    UNION

			SELECT DISTINCT 
			 CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_aval_melhoria_num_orgao ELSE pc_aval_melhoria_sug_orgao_mcu END as mcuOrgaoResp
			,CASE  WHEN pc_aval_melhoria_sug_orgao_mcu=''THEN pc_orgaos.pc_org_sigla ELSE pc_orgaos2.pc_org_sigla END as siglaOrgaoResp
			,pc_orgaos3.pc_org_mcu as mcuOrigem
			,pc_orgaos3.pc_org_sigla as siglaOrigem			
			FROM  pc_avaliacao_melhorias
			inner join pc_avaliacoes on pc_aval_id = pc_aval_melhoria_num_aval
			inner join pc_processos on pc_processo_id = pc_aval_processo
			LEFT JOIN pc_orgaos on pc_org_mcu = pc_aval_melhoria_num_orgao 
			LEFT JOIN pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
			LEFT JOIN pc_orgaos as pc_orgaos3 on pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
			LEFT JOIN pc_usuarios on pc_usu_lotacao = pc_aval_melhoria_num_orgao
			LEFT JOIN pc_usuarios as pc_usuarios2 on pc_usuarios2.pc_usu_lotacao = pc_aval_melhoria_sug_orgao_mcu
			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 or "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
				WHERE pc_usuarios.pc_usu_lotacao is null and pc_usuarios2.pc_usu_lotacao is null and pc_aval_melhoria_status = 'P'
			<cfelse>
				WHERE pc_usuarios.pc_usu_lotacao is null and pc_usuarios2.pc_usu_lotacao is null and pc_aval_melhoria_status = 'P' 
				and pc_orgaos3.pc_org_mcu = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
			</cfif>

			UNION

			SELECT DISTINCT pc_orgHerancaMcuPara as mcuOrgaoResp
						   ,pc_orgaos2.pc_org_sigla as siglaOrgaoResp
						   ,pc_orgaos3.pc_org_mcu as mcuOrigem
						   ,pc_orgaos3.pc_org_sigla as siglaOrigem
			FROM pc_orgaos_heranca
			LEFT JOIN pc_avaliacao_melhorias on pc_avaliacao_melhorias.pc_aval_melhoria_num_orgao = pc_orgHerancaMcuDe
			LEFT JOIN pc_avaliacao_melhorias as pc_avaliacao_melhorias2  on pc_avaliacao_melhorias2.pc_aval_melhoria_sug_orgao_mcu = pc_orgHerancaMcuDe
			inner join pc_avaliacoes on pc_aval_id = pc_avaliacao_melhorias.pc_aval_melhoria_num_aval
			inner join pc_processos on pc_processo_id = pc_aval_processo
            LEFT JOIN pc_usuarios on pc_usu_lotacao = pc_orgHerancaMcuPara
			LEFT JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_orgHerancaMcuDe
			LEFT JOIN pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_orgHerancaMcuPara
			LEFT JOIN pc_orgaos as pc_orgaos3 on pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 or "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
				WHERE pc_usuarios.pc_usu_lotacao is null and pc_avaliacao_melhorias.pc_aval_melhoria_status = 'P'
			<cfelse>
				WHERE pc_usuarios.pc_usu_lotacao is null and pc_avaliacao_melhorias.pc_aval_melhoria_status = 'P' 
				and pc_orgaos3.pc_org_mcu = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
			</cfif>
            

			UNION
			
			SELECT DISTINCT pc_orgHerancaMcuPara as mcuOrgaoResp
						   ,pc_orgaos2.pc_org_sigla as siglaOrgaoResp
						   ,pc_orgaos3.pc_org_mcu as mcuOrigem
						   ,pc_orgaos3.pc_org_sigla as siglaOrigem
			FROM pc_orgaos_heranca
			LEFT JOIN pc_avaliacao_orientacoes on pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp = pc_orgHerancaMcuDe
			inner join pc_avaliacoes on pc_aval_id = pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval
			inner join pc_processos on pc_processo_id = pc_aval_processo
			inner join pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
            LEFT JOIN pc_usuarios on pc_usu_lotacao = pc_orgHerancaMcuPara
			LEFT JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_orgHerancaMcuDe
			LEFT JOIN pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_orgHerancaMcuPara
			LEFT JOIN pc_orgaos as pc_orgaos3 on pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 or "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
				WHERE pc_usu_lotacao is null and pc_orientacao_status_finalizador = 'N'
			<cfelse>
				WHERE pc_usu_lotacao is null and pc_orientacao_status_finalizador = 'N' 
				and pc_num_orgao_origem = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
			</cfif>

            ORDER BY siglaOrgaoResp
			
		</cfquery>

		


		<cfif #qPosicionamentos.recordcount# neq 0 >     
				<div class="row" style="margin-top:30px">
					<div class="col-md-12">
						<div class="card card-danger ">
							<div class="card-header">
								<h2 class="card-title"><i class="fa fa-exclamation-triangle" style="color:#fff" ></i> Atenção!</h2>
							</div>
							<!-- /.card-header -->
							<div class="card-body" >
					
								<ul>
									<cfoutput>
										<cfif #qPosicionamentos.recordcount# eq 1>
											<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existe #qPosicionamentos.recordcount# orientação pendente de manifestação inicial do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
										<cfelse>
											<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existem #qPosicionamentos.recordcount# medidas/orientações para regularização pendentes de manifestação inicial do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
										</cfif>
										<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>.</span></li>
									
									</cfoutput>
								</ul>
								
							</div>
							<!-- /.card-body -->
						</div>
						<!-- /.card -->
					</div>
				</div>
		</cfif>

		<cfif #qOrgaosSemUsuario.recordcount# neq 0 and FindNoCase("intranetsistemaspe", application.auxsite)>
			<div class="row" style="margin-top:30px;margin-bottom:50px">
				<div class="col-md-12">	
					<div class="card card-danger ">
						<div class="card-header">
							<h2 class="card-title"><i class="fa fa-exclamation-triangle" style="color:#fff" ></i> 
							<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 or "#application.rsUsuarioParametros.pc_usu_perfil#" eq '11'>
								Atenção!<br><br>Existe(m) órgão(s) com medidas/orientações para regularização ou propostas de melhoria (não respondidos ou em tratamento ou pendentes) e sem usuários cadastrados.
							<cfelse>
								Atenção!<br><br>Existe(m) <cfoutput>#qOrgaosSemUsuario.recordcount#</cfoutput> órgão(s) com medidas/orientações para regularização ou propostas de melhoria (não respondidos ou em tratamento ou pendentes) e sem usuários cadastrados.

							</cfif>
							</h2>
						</div>
						<!-- /.card-header -->
						<div align="center" class="card-body" >
							<div  class="col-6">
								<table id="tabOrgaosSemUsuario" class="table table-bordered  table-hover ">
									<thead style="background:#dc3545;color:#fff;text-align:center;">
										<tr style="font-size:14px">
											<th>Órgãos</th>	
											<th>Origem do Processo</th>
										</tr>
									</thead>
								
									<tbody>
										<cfloop query="qOrgaosSemUsuario" >
											<cfoutput>					
												<tr style="font-size:14px;color:##000" >
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td>#siglaOrigem# (#mcuOrigem#)</td>
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
			</div>
			
		</cfif>

		<script language="JavaScript">
			$(function () {
				$("#tabOrgaosSemUsuario").DataTable({
					"destroy": true,
			     	"stateSave": false,
					"responsive": true, 
					"lengthChange": false, 
					"autoWidth": false,
					"sort": false,
					"searching":false,
					"filter": false,
					"info": false,
					"paging": false
				})
			});
		</script>
	
	</cffunction>
</cfcomponent>