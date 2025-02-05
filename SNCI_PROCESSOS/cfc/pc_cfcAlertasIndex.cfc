<cfcomponent >
<cfprocessingdirective pageencoding = "utf-8">

	<cffunction name="getTotalOrientacoes" access="public" returntype="numeric">
	    <cfset var qPosicionamentos = 0>
		<cfquery datasource="#application.dsn_processos#" name="qPosicionamentos">
			SELECT COUNT(pc_aval_orientacao_id) AS totalOrientacoes
			FROM pc_avaliacao_orientacoes
			INNER JOIN pc_orientacao_status ON pc_orientacao_status_id = pc_aval_orientacao_status
			INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_orientacao_num_aval
			INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
			WHERE pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
			AND pc_aval_orientacao_status IN (4,5)
			AND pc_num_status IN (4)
		</cfquery>
		<cfreturn qPosicionamentos.totalOrientacoes[1]>
	</cffunction>
    
    <cffunction name="getTotalOrientacoesSubordinados" access="public" returntype="numeric">
	    <cfset var qOrientacoesSubordinados = 0>
        <cfquery datasource="#application.dsn_processos#" name="qOrientacoesSubordinados">
            SELECT count(pc_aval_orientacao_id) as totalOrientacoesSubordinados
            FROM pc_avaliacao_orientacoes
            INNER JOIN pc_orientacao_status ON pc_orientacao_status_id = pc_aval_orientacao_status
            INNER JOIN pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
            INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_orientacao_num_aval
            INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
            WHERE 
            <cfif ListLen(application.orgaosHierarquiaList) GT 0>
                pc_aval_orientacao_status IN (4,5) 
                AND pc_aval_orientacao_mcu_orgaoResp IN (#application.orgaosHierarquiaList#)
                AND pc_num_status IN (4)
            <cfelse>
                pc_num_status = 0
            </cfif>
        </cfquery>
        <cfreturn qOrientacoesSubordinados.totalOrientacoesSubordinados[1]>
    </cffunction>
    
    <cffunction name="getTotalMelhoriasPendentes" access="public" returntype="numeric">
	    <cfset var qMelhoriasPendentes = 0>
        <cfquery datasource="#application.dsn_processos#" name="qMelhoriasPendentes">
            SELECT count(pc_aval_melhoria_id) as totalMelhoriasPendentes
            FROM pc_avaliacao_melhorias
            INNER JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao
            INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_melhoria_num_aval
            INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
            WHERE pc_aval_melhoria_status = 'P' 
              AND pc_aval_melhoria_num_orgao = '#application.rsUsuarioParametros.pc_usu_lotacao#' 
              AND pc_processos.pc_num_status IN (4,5)
        </cfquery>
        <cfreturn qMelhoriasPendentes.totalMelhoriasPendentes[1]>
    </cffunction>

	<cffunction name="getTotalProcessosSemPesquisa" access="public" returntype="numeric">
		<cfquery name="qProcSemPesquisa" datasource="#application.dsn_processos#" timeout="120">
			SELECT count(pc_processo_id) as totalProcessosSemPesquisa FROM
			(
				SELECT DISTINCT pc_processos.pc_processo_id  
				FROM pc_avaliacao_orientacoes
				INNER JOIN pc_avaliacoes 
					ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
				INNER JOIN pc_processos 
					ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
				WHERE pc_aval_orientacao_mcu_orgaoResp = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
					AND RIGHT(pc_processos.pc_processo_id, 4) >= 2000
				AND pc_processos.pc_processo_id NOT IN 
				(
					SELECT pc_processo_id 
					FROM pc_pesquisas 
					WHERE pc_org_mcu = 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
				)

				UNION

				SELECT DISTINCT pc_processos.pc_processo_id  
				FROM pc_avaliacao_melhorias
				INNER JOIN pc_avaliacoes 
					ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
				INNER JOIN pc_processos 
					ON pc_avaliacoes.pc_aval_processo = pc_processos.pc_processo_id
				WHERE pc_aval_melhoria_num_orgao = <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
					AND RIGHT(pc_processos.pc_processo_id, 4) >= 2000
				AND pc_processos.pc_processo_id NOT IN 
				(
					SELECT pc_processo_id 
					FROM pc_pesquisas 
					WHERE pc_org_mcu = 
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.rsUsuarioParametros.pc_usu_lotacao#">
				)
			) AS unificado
		</cfquery>
		<cfreturn qProcSemPesquisa.totalProcessosSemPesquisa[1]>
	</cffunction>

	<cffunction name="alertasOA"   access="remote" hint="mostra alertas para os órgão avaliados na página index.">
        <cfset var totalOrientacoes = getTotalOrientacoes()>
        <cfset var qOrientacoesSubordinados = getTotalOrientacoesSubordinados()>
        <cfset var qMelhoriasPendentes = getTotalMelhoriasPendentes()>
		<cfset var qProcessosSemPesquisa = getTotalProcessosSemPesquisa()>
	
		<cfif #totalOrientacoes# neq 0 || #qOrientacoesSubordinados# neq 0 ||#qMelhoriasPendentes# neq 0 || #qProcessosSemPesquisa# neq 0>    
				<div id="rowAlertaOrgaoAvaliado" class="row" style="margin-top:30px">
					<div class="col-md-12">
						<div class="card card-danger ">
							<div class="card-header">
								<h2 class="card-title"><i class="fa fa-exclamation-triangle" style="color:#fff" ></i> Atenção!</h2>
							</div>
							<!-- /.card-header -->
							<div class="card-body" >
					
								<ul>
									<cfif #totalOrientacoes# neq 0>
										
										<cfoutput>
											<cfif #totalOrientacoes# eq 1>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existe #totalOrientacoes# Orientação para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											<cfelse>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existem #totalOrientacoes# Orientações para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											</cfif>
											<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em;margin-right:10px"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>e selecione a aba "Medida/Orientação para Regularização".</span></li>
										
										</cfoutput>
									</cfif>

									<cfif #qOrientacoesSubordinados# neq 0>
										<cfoutput>
											<cfif #qOrientacoesSubordinados# eq 1>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existe #qOrientacoesSubordinados# Orientação para manifestação de órgão subordinado a <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											<cfelse>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existem #qOrientacoesSubordinados# Orientações para manifestação de órgãos subordinados a <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											</cfif>
											<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em;margin-right:10px"><i class="nav-icon fas fa-search"></i> Consultas</span>, depois em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em"><i class="nav-icon fas fa-spinner"></i> Processos Em Acomp.</span>  e escolha a opção <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em"><i class="nav-icon fas fa-spinner"></i> Por Orientação</span></span></li>
										
										</cfoutput>
									</cfif>

									<cfif #qMelhoriasPendentes# neq 0>
										
										<cfoutput>
											<cfif #qMelhoriasPendentes# eq 1>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existe #qMelhoriasPendentes# Proposta de Melhoria para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											<cfelse>
												<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existem #qMelhoriasPendentes# Propostas de Melhoria para manifestação do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											</cfif>
											<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em;margin-right:10px"><i class="nav-icon fas fa-list"></i> Acompanhamento</span>e selecione a aba "Propostas de Melhoria".</span></li>
										
										</cfoutput>
									</cfif>

									<cfif #qProcessosSemPesquisa# neq 0>
										<cfoutput>
											<cfif #qProcessosSemPesquisa# eq 1>
												<li style="color:red;"><span  style="color:red;font-size:1.2em">Existe #qProcessosSemPesquisa# Pesquisa de Opinião não respondida pelo órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											<cfelse>
												<li style="color:red;"><span  style="color:red;font-size:1.2em">Existem #qProcessosSemPesquisa# Pesquisas de Opinião não respondidas pelo órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
											</cfif>
											<span style="color:red;font-size:1.2em">Clique no menu ao lado em <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em;margin-right:10px"><i class="nav-icon fas fa-search"></i> Consultas</span> e escolha a opção <span class="statusOrientacoes" style="color:##fff;background-color:##0e406a;padding:3px;font-size:1em"><i class="nav-icon fas fa-clipboard-list"></i> Pesquisas Não Resp.</span></span></li>
										</cfoutput>

									</cfif>

									
								</ul>
								
								<cfif #totalOrientacoes# neq 0 || #qOrientacoesSubordinados# neq 0>
									<div style="margin-top:20px"><span style="color:red;font-size:1em;margin-left:25px">Obs.: Os status que necessitam de manifestação são: <span  class="statusOrientacoes" style="background:rgb(35, 107, 142);color: rgb(255, 255, 255);" >NÃO RESPONDIDO</span> , <span  class="statusOrientacoes" style="background:rgb(128, 128, 255);color: rgb(255, 255, 255);" >TRATAMENTO</span> e <span  class="statusOrientacoes" style="background:#dc3545;color:#fff;" >PENDENTE</span>.</span></div>
								</cfif>
								
							</div>
							<!-- /.card-body -->
						</div>
						<!-- /.card -->
					</div>
				</div>
		</cfif> 
	</cffunction>

	<cffunction name="alertasOAOrientacoesNavBar"   access="remote" hint="mostra alertas para os órgão avaliados no NavBar.">
        <cfset var qOrientacoes = getTotalOrientacoes()>

		<cfif #qOrientacoes# eq 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_Acompanhamentos.cfm" >Existe <strong>01</strong> Orientação para sua manifestação.</a>

		<cfelseif #qOrientacoes# gt 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_Acompanhamentos.cfm" >Existem <cfoutput><strong>#qOrientacoes#</strong></cfoutput> Orientações para sua manifestação.</a>
			
		</cfif>	
			
	</cffunction>

	<cffunction name="alertasOAOrientacoesSubordinadosNavBar"   access="remote" hint="mostra alertas para os órgão avaliados no NavBar.">
		<cfset var qOrientacoesSubordinados = getTotalOrientacoesSubordinados()>
		
		<cfif #qOrientacoesSubordinados# eq 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_ConsultarPorOrientacao.cfm" >Existe <strong>01</strong> Orientação para manifestação de órgão subordinado.</a>
			
		<cfelseif #qOrientacoesSubordinados# gt 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_ConsultarPorOrientacao.cfm" >
				Existem <cfoutput><strong>#qOrientacoesSubordinados#</strong></cfoutput> Orientações para manifestação de órgãos subordinados.
			</a>
			
		</cfif>	
			
	</cffunction>

	<cffunction name="alertasOAPropostasMelhoriaNavBar"   access="remote" hint="mostra alertas para os órgão avaliados no NavBar.">
		<cfset var qMelhoriasPendentes = getTotalMelhoriasPendentes()>
		
		<cfif #qMelhoriasPendentes# eq 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_Acompanhamentos.cfm" >Existe <strong>01</strong> Proposta de Melhoria para sua manifestação.</a>
			
		<cfelseif #qMelhoriasPendentes# gt 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_Acompanhamentos.cfm" >Existem <cfoutput><strong>#qMelhoriasPendentes#</strong></cfoutput> Propostas de Melhoria para sua manifestação.</a>
			
		</cfif>	
			
	</cffunction>

	<cffunction name="alertasOAPesquisasNavBar"   access="remote" hint="mostra alertas para os órgão avaliados no NavBar.">
		<cfset var qProcessosSemPesquisa = getTotalProcessosSemPesquisa()>
		
		<cfif #qProcessosSemPesquisa# eq 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_ConsultarProcessosSemPesquisa.cfm" >Existe <strong>01</strong> Pesquisa de Opinião não respondida.</a>
			
		<cfelseif #qProcessosSemPesquisa# gt 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_ConsultarProcessosSemPesquisa.cfm" >Existem <cfoutput><strong>#qProcessosSemPesquisa#</strong></cfoutput> Pesquisas de Opinião não respondidas.</a>
			
		</cfif>	
			
	</cffunction>



	<cffunction name="totalAlertas" access="remote" returntype="struct" returnformat="json" hint="Retorna o total de alertas">
		<cfset var total = 0>
		<cfset var qPos = getTotalOrientacoes()>
		<cfset var qSub = getTotalOrientacoesSubordinados()>
		<cfset var qMelhorias = getTotalMelhoriasPendentes()>
		<cfset var qPesquisas = getTotalProcessosSemPesquisa()>
		
		<cfset total = qPos + qSub + qMelhorias + qPesquisas>
		
		<cfreturn { "total": total }>
	</cffunction>



	<cffunction name="getTotalPosicionamentosIniciaisCI" access="public" returntype="numeric">
		<cfset var qPosicionamentos = 0>
		<cfquery datasource="#application.dsn_processos#" name="qPosicionamentos">
			SELECT COUNT(pc_aval_orientacao_id) AS totalOrientacoes 
			FROM pc_avaliacao_orientacoes
			INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_orientacao_num_aval
			INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
			INNER JOIN pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp 
			WHERE pc_num_status = 4 AND pc_aval_orientacao_status = 1 AND NOT pc_aval_orientacao_mcu_orgaoResp IS NULL
			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 OR "#application.rsUsuarioParametros.pc_usu_perfil#" eq "">
				AND pc_org_controle_interno = 'S' 
			<cfelse>
				AND pc_num_orgao_origem = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar"> 
			</cfif>
		</cfquery>
		<cfreturn qPosicionamentos.totalOrientacoes[1]>
	</cffunction>


	<cffunction name="getOrgaosSemUsuarioCI" access="private" returntype="query">
	    <cfset var qOrgaosSemUsuario = "">
		<cfquery datasource="#application.dsn_processos#" name="qOrgaosSemUsuario">
			SELECT DISTINCT 
				pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp AS mcuOrgaoResp,
				pc_orgaos.pc_org_sigla AS siglaOrgaoResp,
				pc_num_orgao_origem AS mcuOrigem,
				pc_orgaos2.pc_org_sigla AS siglaOrigem
			FROM pc_avaliacao_orientacoes
			INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_orientacao_num_aval
			INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
			INNER JOIN pc_orientacao_status ON pc_orientacao_status_id = pc_aval_orientacao_status
			INNER JOIN pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp 
			INNER JOIN pc_orgaos AS pc_orgaos2 ON pc_orgaos2.pc_org_mcu = pc_num_orgao_origem
			LEFT JOIN pc_usuarios ON pc_usu_lotacao = pc_aval_orientacao_mcu_orgaoResp
            WHERE (pc_usuarios.pc_usu_lotacao IS NULL OR pc_usuarios.pc_usu_status ='D') AND NOT pc_aval_orientacao_mcu_orgaoResp IS NULL
			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 OR "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
				AND pc_orientacao_status_finalizador = 'N'
			<cfelse>
				 AND pc_orientacao_status_finalizador = 'N' 
				AND pc_num_orgao_origem = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
			</cfif>
			
			UNION

			SELECT DISTINCT 
				CASE  
					WHEN pc_aval_melhoria_sug_orgao_mcu = '' OR  pc_aval_melhoria_sug_orgao_mcu is null THEN pc_aval_melhoria_num_orgao 
					ELSE pc_aval_melhoria_sug_orgao_mcu 
				END AS mcuOrgaoResp,
				CASE  
					WHEN pc_aval_melhoria_sug_orgao_mcu = ''  OR  pc_aval_melhoria_sug_orgao_mcu is null THEN pc_orgaos.pc_org_sigla 
					ELSE pc_orgaos2.pc_org_sigla 
				END AS siglaOrgaoResp,
				pc_orgaos3.pc_org_mcu AS mcuOrigem,
				pc_orgaos3.pc_org_sigla AS siglaOrigem
			FROM pc_avaliacao_melhorias
			INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_melhoria_num_aval
			INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
			LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao 
			LEFT JOIN pc_orgaos AS pc_orgaos2 ON pc_orgaos2.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
			LEFT JOIN pc_orgaos AS pc_orgaos3 ON pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
			LEFT JOIN pc_usuarios ON pc_usu_lotacao = pc_aval_melhoria_num_orgao
			LEFT JOIN pc_usuarios AS pc_usuarios2 ON pc_usuarios2.pc_usu_lotacao = pc_aval_melhoria_sug_orgao_mcu
			WHERE pc_usuarios.pc_usu_lotacao IS NULL OR pc_usuarios.pc_usu_status ='D'
			<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 OR "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
				AND pc_usuarios2.pc_usu_lotacao IS NULL 
				AND pc_aval_melhoria_status = 'P'
			<cfelse>
				AND pc_usuarios2.pc_usu_lotacao IS NULL 
				AND pc_aval_melhoria_status = 'P' 
				AND pc_orgaos3.pc_org_mcu = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
			</cfif>
			ORDER BY siglaOrgaoResp
		</cfquery>
		<cfreturn qOrgaosSemUsuario>
	</cffunction>

	<cffunction name="getTotalOrgaosSemUsuarioCI" access="public" returntype="numeric">
		<cfset var qOrgaosSemUsuarioCount = 0>
		<cfquery datasource="#application.dsn_processos#" name="qOrgaosSemUsuarioCount">
			SELECT COUNT(DISTINCT mcuOrgaoResp) AS totalOrgaos
			FROM (
				SELECT 
					pc_avaliacao_orientacoes.pc_aval_orientacao_mcu_orgaoResp AS mcuOrgaoResp
				FROM pc_avaliacao_orientacoes
				INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_orientacao_num_aval
				INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
				INNER JOIN pc_orientacao_status ON pc_orientacao_status_id = pc_aval_orientacao_status
				INNER JOIN pc_orgaos ON pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp 
				INNER JOIN pc_orgaos AS pc_orgaos2 ON pc_orgaos2.pc_org_mcu = pc_num_orgao_origem
				LEFT JOIN pc_usuarios ON pc_usu_lotacao = pc_aval_orientacao_mcu_orgaoResp
				<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 OR "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
					WHERE pc_usuarios.pc_usu_lotacao IS NULL OR pc_usuarios.pc_usu_status ='D'
					AND pc_orientacao_status_finalizador = 'N'
				<cfelse>
					WHERE pc_usuarios.pc_usu_lotacao IS NULL OR pc_usuarios.pc_usu_status ='D'
					AND pc_orientacao_status_finalizador = 'N' 
					AND pc_num_orgao_origem = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
				</cfif>
				
				UNION
		
				SELECT 
					CASE  
						WHEN pc_aval_melhoria_sug_orgao_mcu = '' THEN pc_aval_melhoria_num_orgao 
						ELSE pc_aval_melhoria_sug_orgao_mcu 
					END AS mcuOrgaoResp
				FROM pc_avaliacao_melhorias
				INNER JOIN pc_avaliacoes ON pc_aval_id = pc_aval_melhoria_num_aval
				INNER JOIN pc_processos ON pc_processo_id = pc_aval_processo
				LEFT JOIN pc_orgaos ON pc_org_mcu = pc_aval_melhoria_num_orgao 
				LEFT JOIN pc_orgaos AS pc_orgaos2 ON pc_orgaos2.pc_org_mcu = pc_aval_melhoria_sug_orgao_mcu
				LEFT JOIN pc_orgaos AS pc_orgaos3 ON pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
				LEFT JOIN pc_usuarios ON pc_usu_lotacao = pc_aval_melhoria_num_orgao
				LEFT JOIN pc_usuarios AS pc_usuarios2 ON pc_usuarios2.pc_usu_lotacao = pc_aval_melhoria_sug_orgao_mcu
				<cfif "#application.rsUsuarioParametros.pc_usu_perfil#" eq 3 OR "#application.rsUsuarioParametros.pc_usu_perfil#" eq 11>
					WHERE pc_usuarios.pc_usu_lotacao IS NULL OR pc_usuarios.pc_usu_status ='D'
					AND pc_usuarios2.pc_usu_lotacao IS NULL OR pc_usuarios2.pc_usu_status ='D'
					AND pc_aval_melhoria_status = 'P'
				<cfelse>
					WHERE pc_usuarios.pc_usu_lotacao IS NULL OR pc_usuarios.pc_usu_status ='D'
					AND pc_usuarios2.pc_usu_lotacao IS NULL  OR pc_usuarios2.pc_usu_status ='D'
					AND pc_aval_melhoria_status = 'P' 
					AND pc_orgaos3.pc_org_mcu = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
				</cfif>
			) AS subquery
		</cfquery>
		<cfreturn qOrgaosSemUsuarioCount.totalOrgaos[1]>
	</cffunction>


	<cffunction name="alertasCI"   access="remote" hint="mostra alertas para o controle interno na página index.">

		<cfset var qPosicionamentos = getTotalPosicionamentosIniciaisCI()>
		<cfset var qOrgaosSemUsuario = getOrgaosSemUsuarioCI()>
		<cfset var qOrgaosSemUsuarioCount = getTotalOrgaosSemUsuarioCI()>

		


		<cfif #qPosicionamentos# neq 0 >     
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
										<cfif #qPosicionamentos# eq 1>
											<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existe #qPosicionamentos# orientação pendente de manifestação inicial do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
										<cfelse>
											<li style="margin-bottom:20px;color:red;"><span  style="color:red;font-size:1.2em">Existem #qPosicionamentos# medidas/orientações para regularização pendentes de manifestação inicial do órgão <strong>#application.rsUsuarioParametros.pc_org_sigla#</strong>.</span>
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

		<cfif #qOrgaosSemUsuarioCount# neq 0 and FindNoCase("intranetsistemaspe", application.auxsite)>
			<div class="row" style="margin-top:30px;">
				<div class="col-md-12">	
					<div class="card " style="background:transparent;box-shadow:none">
						
						<!-- /.card-header -->
						<div align="center" class="card-body" >
							<div  class="col-6">
								<table id="tabOrgaosSemUsuario" class="table  table-hover ">
									<thead style="background:#dc3545;color:#fff;text-align:center;">
									    <tr >
											<th colspan="2" style="font-size:16px;text-align:center;font-weight:normal;">
												<cfif #qOrgaosSemUsuarioCount# eq 1>
													<strong>Atenção!</strong><br>Existe 01 órgão com medidas/orientações para regularização ou propostas de melhoria (não respondidos ou em tratamento ou pendentes) e sem usuários cadastrados ou ativos:
												<cfelseif #qOrgaosSemUsuarioCount# gt 1>
													<strong>Atenção!</strong><br>Existe(m) <cfoutput>#qOrgaosSemUsuarioCount#</cfoutput> órgão(s) com medidas/orientações para regularização ou propostas de melhoria (não respondidos ou em tratamento ou pendentes) e sem usuários cadastrados ou ativos:
												</cfif>
											</th>
										</tr>
										<tr style="font-size:14px;">
											<th style="text-align:center;">Órgãos</th>	
											<th style="text-align:center;">Origem do Processo</th>
										</tr>
									</thead>
								
									<tbody>
										<cfloop query="qOrgaosSemUsuario" >
											<cfoutput>					
												<tr style="font-size:14px;color:##000" >
													<td>#siglaOrgaoResp# (#mcuOrgaoResp#)</td>
													<td style="text-align:center;">#siglaOrigem# (#mcuOrigem#)</td>
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
					"paging": false,
					language: {
						url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
					}
				})
			});
			$(document).ready(function() {
				$(".content-wrapper").css("height", "auto");
			});
		</script>
	
	</cffunction>

	<cffunction name="alertasPosicionamentosIniciaisCINavBar"   access="remote" hint="mostra alertas para o controle interno na página index.">
		<cfset var qPosicionamentos = getTotalPosicionamentosIniciaisCI()>
		
		
		<cfif #qPosicionamentos# eq 1 >     
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_Acompanhamentos.cfm" >Existe <strong>01</strong> orientação pendente de manifestação inicial.</a>
		<cfelseif #qPosicionamentos# gt 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./pc_Acompanhamentos.cfm" >Existem <cfoutput><strong>#qPosicionamentos#</strong></cfoutput> medidas/orientações pendentes de manifestação inicial.</a>
		</cfif>
		
	</cffunction>

	<cffunction name="alertasOrgaosSemUsuarioCINavBar"   access="remote" hint="mostra alertas para o controle interno na página index.">
		<cfset var qOrgaosSemUsuario = getTotalOrgaosSemUsuarioCI()>
		
		<cfif #qOrgaosSemUsuario# eq 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./index.cfm" >Existe <strong>01</strong> órgão sem usuários cadastrados ou ativos.</a>
		<cfelseif #qOrgaosSemUsuario# gt 1>
			<a class="dropdown-item" href="../SNCI_PROCESSOS/./index.cfm" >Existem <cfoutput><strong>#qOrgaosSemUsuario#</strong></cfoutput> órgãos sem usuários cadastrados ou ativos.</a>
		</cfif>
	
	</cffunction>

	
	<cffunction name="totalAlertasCI" access="remote" returntype="struct" returnformat="json" hint="Retorna o total de alertas">
		<cfset var total = 0>
		<cfset var qPos = getTotalPosicionamentosIniciaisCI()>
		<cfset var qOrgaosSemUsuario = getTotalOrgaosSemUsuarioCI()>
		
		<cfset total = qPos + qOrgaosSemUsuario>
		
		<cfreturn { "total": total }>
	</cffunction>




</cfcomponent>