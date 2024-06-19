<cfcomponent  >
<cfprocessingdirective pageencoding = "utf-8">	

	
	
	<cffunction name="cadProc"   access="remote" returntype="any">

	    <cfargument name="pcProcessoId" type="string" required="false" default=''/>
		<cfargument name="pcNumSEI" type="string" required="true" />
		<cfargument name="pcNumRelatorio" type="string" required="true" />
		<cfargument name="pcOrigem" type="string" required="true" />
		<cfargument name="pcDataInicioAvaliacao" type="date" required="true" />
		<cfargument name="pcDataFimAvaliacao" type="any" required="false" />
		<cfargument name="pcTipoAvaliado" type="string" required="true" />
		<cfargument name="pcTipoAvalDescricao" type="string" required="false" default=''/>
		<cfargument name="pcModalidade" type="string" required="true" />
		<cfargument name="pcTipoClassificacao" type="string" required="true" />
		<cfargument name="pcOrgaoAvaliado" type="string" required="true" />

		<cfargument name="pcObjEstrategico" type="string" required="true" />
		<cfargument name="pcRiscoEstrategico" type="string" required="true" />
		<cfargument name="pcMebitda" type="string" required="true" />
		<cfargument name="pcIndicadorSetorial" type="string" required="true" />

		<cfargument name="pcAvaliadores" type="any" required="true" />
		<cfargument name="pcCoordenador" type="string" required="false" default=''/>
		<cfargument name="pcCoordNacional" type="string" required="true"/>
		<cfargument name="pcNumStatus" type="string" required="false" default='2'/>
        <cfargument name="pcTipoDemanda" type="string" required="true"/>
		<cfargument name="pcAnoPacin" type="string" required="true"/>
		<cfargument name="pcBloquear" type="string" required="true"/>
		
		<cfset ano = year(#arguments.pcDataInicioAvaliacao#)> 
		<cfset login = '#application.rsUsuarioParametros.pc_usu_login#'>

		<cfquery name="rsSEorgAvaliado" datasource="#application.dsn_processos#">
		  SELECT pc_org_se from pc_orgaos where pc_org_mcu = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pcOrgaoAvaliado#">
        </cfquery>

		<cfquery name="rsSeq" datasource="#application.dsn_processos#">
			SELECT Max(pc_processo_id) AS Max
			FROM pc_processos 
			WHERE pc_processo_id like '%#ano#' AND pc_processo_id like '#rsSEorgAvaliado.pc_org_se#%'
		</cfquery>

		

        <cfif rsSeq.Max eq "">
            <cfset NumID = 1>
        <cfelse>
            <cfset NumID = val(mid(rsSeq.Max,3,4) + 1)>			
        </cfif>	

        <cfswitch expression="#len(NumID)#">
            <cfcase value="1">
                <cfset NumID = '000' & NumID>
            </cfcase>
            <cfcase value="2">
                <cfset NumID = '00' & NumID>
            </cfcase>
            <cfcase value="3">
                <cfset NumID = '0' & NumID>
            </cfcase>
        </cfswitch>

        <cfset NumID = '#rsSEorgAvaliado.pc_org_se#' & NumID & ano>
        <cfset aux_sei = Trim('#arguments.pcNumSEI#')>
        <cfset aux_sei = Replace(aux_sei,'.','',"All")>
        <cfset aux_sei = Replace(aux_sei,'/','','All')>
        <cfset aux_sei = Replace(aux_sei,'-','','All')>


        <!-- Verifica se o processo já existe -->
		<cfif '#arguments.pcProcessoId#' eq '' >
			
			<cfquery datasource="#application.dsn_processos#">
				INSERT pc_processos (pc_processo_id, pc_usu_matricula_cadastro, pc_datahora_cadastro, pc_num_sei, pc_num_orgao_origem, pc_num_rel_sei, pc_num_orgao_avaliado, pc_num_avaliacao_tipo, pc_aval_tipo_nao_aplica_descricao,pc_num_classificacao, pc_data_inicioAvaliacao, pc_data_fimAvaliacao, pc_num_status, pc_alteracao_datahora, pc_alteracao_login, pc_usu_matricula_coordenador,pc_usu_matricula_coordenador_nacional, pc_Modalidade,pc_tipo_demanda, pc_ano_pacin, pc_iniciarBloqueado, pc_indicadorSetorial)
				VALUES 
					(
					<cfqueryparam value="#NumID#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">, 
					<cfqueryparam value="#aux_sei#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcOrigem#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcNumRelatorio#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcOrgaoAvaliado#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcTipoAvaliado#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcTipoAvalDescricao#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcTipoClassificacao#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcDataInicioAvaliacao#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcDataFimAvaliacao#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcNumStatus#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">, 
					<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcCoordenador#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcCoordNacional#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcModalidade#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcTipoDemanda#" cfsqltype="cf_sql_varchar">, 
					<cfqueryparam value="#arguments.pcAnoPacin#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pcBloquear#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.pcIndicadorSetorial#" cfsqltype="cf_sql_varchar">
					)

			</cfquery> 	
	

			<!--Cadastra avaliadores -->

			<cfloop list="#arguments.pcAvaliadores#" index="i">  
				<cfset matriculaAvaliador = '#i#'>
				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_avaliadores (pc_avaliador_matricula,  pc_avaliador_id_processo)
					VALUES ('#matriculaAvaliador#',  '#NumID#')
				</cfquery>
			</cfloop>

			<!--Cadastra objetivos estratégicos -->
			<cfloop list="#arguments.pcObjEstrategico#" index="i">  
				<cfset objEstrategico = '#i#'>
				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_processos_objEstrategicos (pc_processo_id, pc_objEstrategico_id)
					VALUES ('#NumID#','#objEstrategico#')
				</cfquery>
			</cfloop>

			<!--Cadastra riscos estratégicos -->
			<cfloop list="#arguments.pcRiscoEstrategico#" index="i">  
				<cfset riscoEstrategico = '#i#'>
				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_processos_riscosEstrategicos (pc_processo_id, pc_riscoEstrategico_id)
					VALUES ('#NumID#','#riscoEstrategico#')
				</cfquery>
			</cfloop>

			<!--Cadastra mebitda -->
			<cfloop list="#arguments.pcMebitda#" index="i">  
				<cfset mebitda = '#i#'>
				<cfquery datasource="#application.dsn_processos#">
					INSERT pc_processos_mebitda (pc_processo_id, pc_mebitda_id)
					VALUES ('#NumID#','#mebitda#')
				</cfquery>
			</cfloop>

		<cfelse>
			<!--Se o processos existir mas ano da data de início da avaliação ou a SE do órgão avaliado foi alterada, um novo processo é cadastrado e o processo antigo é excluído-->
		    <cfquery datasource="#application.dsn_processos#" name="qProcessoEditar">
				SELECT pc_data_inicioAvaliacao, pc_org_se  FROM pc_processos 
				INNER JOIN pc_orgaos ON pc_orgaos.pc_org_mcu = pc_processos.pc_num_orgao_avaliado
				WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset anoAntes = year(#qProcessoEditar.pc_data_inicioAvaliacao#)>
			<cfset seAntes = '#qProcessoEditar.pc_org_se#'>
			<cfset seDepois = '#rsSEorgAvaliado.pc_org_se#'>

			<cfif anoAntes neq ano or seAntes neq seDepois>
				<cftransaction>
			
					<cfquery datasource="#application.dsn_processos#">
						INSERT pc_processos (pc_processo_id, pc_usu_matricula_cadastro, pc_datahora_cadastro, pc_num_sei, pc_num_orgao_origem, pc_num_rel_sei, pc_num_orgao_avaliado, pc_num_avaliacao_tipo, pc_aval_tipo_nao_aplica_descricao,pc_num_classificacao, pc_data_inicioAvaliacao, pc_data_fimAvaliacao, pc_num_status, pc_alteracao_datahora, pc_alteracao_login, pc_usu_matricula_coordenador,pc_usu_matricula_coordenador_nacional, pc_Modalidade,pc_tipo_demanda, pc_ano_pacin, pc_iniciarBloqueado, pc_indicadorSetorial)
						VALUES (
								<cfqueryparam value="#NumID#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_matricula#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								<cfqueryparam value="#aux_sei#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcOrigem#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcNumRelatorio#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcOrgaoAvaliado#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcTipoAvaliado#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcTipoAvalDescricao#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcTipoClassificacao#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcDataInicioAvaliacao#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcDataFimAvaliacao#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcNumStatus#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
								<cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcCoordenador#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcCoordNacional#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcModalidade#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcTipoDemanda#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcAnoPacin#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcBloquear#" cfsqltype="cf_sql_varchar">,
								<cfqueryparam value="#arguments.pcIndicadorSetorial#" cfsqltype="cf_sql_varchar">
							)

					
					
					</cfquery> 	
			

					<!--Cadastra avaliadores -->
					<cfloop list="#arguments.pcAvaliadores#" index="i">  
						<cfset matriculaAvaliador = '#i#'>
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_avaliadores (pc_avaliador_matricula,  pc_avaliador_id_processo)
							VALUES ('#matriculaAvaliador#',  '#NumID#')
						</cfquery>
					</cfloop>
					<!--Cadastra objetivos estratégicos -->
					<cfloop list="#arguments.pcObjEstrategico#" index="i">  
						<cfset objEstrategico = '#i#'>
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_processos_objEstrategicos (pc_processo_id, pc_objEstrategico_id)
							VALUES ('#NumID#','#objEstrategico#')
						</cfquery>
					</cfloop>

					<!--Cadastra riscos estratégicos -->
					<cfloop list="#arguments.pcRiscoEstrategico#" index="i">  
						<cfset riscoEstrategico = '#i#'>
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_processos_riscosEstrategicos (pc_processo_id, pc_riscoEstrategico_id)
							VALUES ('#NumID#','#riscoEstrategico#')
						</cfquery>
					</cfloop>

					<!--Cadastra mebitda -->
					<cfloop list="#arguments.pcMebitda#" index="i">  
						<cfset mebitda = '#i#'>
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_processos_mebitda (pc_processo_id, pc_mebitda_id)
							VALUES ('#NumID#','#mebitda#')
						</cfquery>
					</cfloop>

					<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliadores">
						DELETE FROM pc_avaliadores
						WHERE pc_avaliadores.pc_avaliador_id_processo = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery> 

					<cfquery datasource="#application.dsn_processos#" name="DeletaObjEstrategicos">
						DELETE FROM pc_processos_objEstrategicos
						WHERE pc_processos_objEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfquery datasource="#application.dsn_processos#" name="DeletaRiscosEstrategicos">
						DELETE FROM pc_processos_riscosEstrategicos
						WHERE pc_processos_riscosEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfquery datasource="#application.dsn_processos#" name="DeletaMebitda">
						DELETE FROM pc_processos_mebitda
						WHERE pc_processos_mebitda.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery>
				
					<cfquery datasource="#application.dsn_processos#" name="DeletaProcessos">
						DELETE FROM pc_processos
						WHERE pc_processos.pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cftransaction>	
			<!--Se nem o ano de início da avaliação e nem o órgão avaliado for alterado, editar o processo normalmente-->
			<cfelse>
				
					<cfquery datasource="#application.dsn_processos#" >
						UPDATE pc_processos
						SET pc_num_sei = <cfqueryparam value="#aux_sei#" cfsqltype="cf_sql_varchar">,
							pc_num_orgao_origem = <cfqueryparam value="#arguments.pcOrigem#" cfsqltype="cf_sql_varchar">,
							pc_num_rel_sei = <cfqueryparam value="#arguments.pcNumRelatorio#" cfsqltype="cf_sql_varchar">,
							pc_num_orgao_avaliado = <cfqueryparam value="#arguments.pcOrgaoAvaliado#" cfsqltype="cf_sql_varchar">,
							pc_num_avaliacao_tipo = <cfqueryparam value="#arguments.pcTipoAvaliado#" cfsqltype="cf_sql_varchar">,
							pc_aval_tipo_nao_aplica_descricao = <cfqueryparam value="#arguments.pcTipoAvalDescricao#" cfsqltype="cf_sql_varchar">,
							pc_Modalidade = <cfqueryparam value="#arguments.pcModalidade#" cfsqltype="cf_sql_varchar">,
							pc_num_classificacao = <cfqueryparam value="#arguments.pcTipoClassificacao#" cfsqltype="cf_sql_varchar">,
							pc_data_inicioAvaliacao = <cfqueryparam value="#arguments.pcDataInicioAvaliacao#" cfsqltype="cf_sql_varchar">,
							pc_data_fimAvaliacao = <cfqueryparam value="#arguments.pcDataFimAvaliacao#" cfsqltype="cf_sql_varchar">,
							pc_alteracao_datahora = <cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP">,
							pc_alteracao_login = <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_login#" cfsqltype="cf_sql_varchar">,
							pc_usu_matricula_coordenador = <cfqueryparam value="#arguments.pcCoordenador#" cfsqltype="cf_sql_varchar">,
							pc_usu_matricula_coordenador_nacional = <cfqueryparam value="#arguments.pcCoordNacional#" cfsqltype="cf_sql_varchar">,
							pc_tipo_demanda = <cfqueryparam value="#arguments.pcTipoDemanda#" cfsqltype="cf_sql_varchar">,
							pc_ano_pacin = <cfqueryparam value="#arguments.pcAnoPacin#" cfsqltype="cf_sql_varchar">,
							pc_iniciarBloqueado = <cfqueryparam value="#arguments.pcBloquear#" cfsqltype="cf_sql_varchar">,
							pc_indicadorSetorial = <cfqueryparam value="#arguments.pcIndicadorSetorial#" cfsqltype="cf_sql_varchar">
						WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar"> 



					</cfquery> 	

					<cfquery datasource="#application.dsn_processos#" >
						DELETE FROM pc_avaliadores
						WHERE pc_avaliador_id_processo= <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery> 	


					<cfloop list="#arguments.pcAvaliadores#" index="i">  
						<cfset matriculaAvaliador = '#i#'>
						<cfif '#matriculaAvaliador#' eq  "#arguments.pcCoordenador#">
							<cfset coordena ='S'>
						<cfelse>
							<cfset coordena ='N'>
						</cfif>

						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_avaliadores (pc_avaliador_matricula, pc_avaliador_id_processo)
							VALUES ('#matriculaAvaliador#', <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar"> )
						</cfquery>
					</cfloop>


					<cfquery datasource="#application.dsn_processos#" >
						DELETE FROM pc_processos_objEstrategicos
						WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfloop list="#arguments.pcObjEstrategico#" index="i">  
						<cfset objEstrategico = '#i#'>
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_processos_objEstrategicos (pc_processo_id, pc_objEstrategico_id)
							VALUES ('#arguments.pcProcessoId#','#objEstrategico#')
						</cfquery>
					</cfloop>

					<cfquery datasource="#application.dsn_processos#" >
						DELETE FROM pc_processos_riscosEstrategicos
						WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfloop list="#arguments.pcRiscoEstrategico#" index="i">  
						<cfset riscoEstrategico = '#i#'>
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_processos_riscosEstrategicos (pc_processo_id, pc_riscoEstrategico_id)
							VALUES ('#arguments.pcProcessoId#','#riscoEstrategico#')
						</cfquery>
					</cfloop>

					<cfquery datasource="#application.dsn_processos#" >
						DELETE FROM pc_processos_mebitda
						WHERE pc_processo_id = <cfqueryparam value="#arguments.pcProcessoId#" cfsqltype="cf_sql_varchar">
					</cfquery>

					<cfloop list="#arguments.pcMebitda#" index="i">  
						<cfset mebitda = '#i#'>
						<cfquery datasource="#application.dsn_processos#">
							INSERT pc_processos_mebitda (pc_processo_id, pc_mebitda_id)
							VALUES ('#arguments.pcProcessoId#','#mebitda#')
						</cfquery>
					</cfloop>
				
			</cfif>

        </cfif>


		<cfreturn true />
	</cffunction>











	<cffunction name="delProc"   access="remote" returntype="boolean">
		<cfargument name="numProc" type="string" required="true" />

			<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliadores">
				DELETE FROM pc_avaliadores
				WHERE pc_avaliadores.pc_avaliador_id_processo = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="DeletaObjEstrategicos">
				DELETE FROM pc_processos_objEstrategicos
				WHERE pc_processos_objEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" name="DeletaRiscosEstrategicos">
				DELETE FROM pc_processos_riscosEstrategicos
				WHERE pc_processos_riscosEstrategicos.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" name="DeletaMebitda">
				DELETE FROM pc_processos_mebitda
				WHERE pc_processos_mebitda.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery>
		
			<cfquery datasource="#application.dsn_processos#" name="DeletaProcessos">
				DELETE FROM pc_processos
				WHERE pc_processos.pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar"> and  pc_num_status = '2'
			</cfquery>

		<cfreturn true />
	</cffunction>










	<cffunction name="reativarProc"   access="remote" returntype="boolean">
		<cfargument name="numProc" type="string" required="true" default=""/>
		
			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_processos SET  pc_num_status = '2'
				, 
				pc_alteracao_login = '#application.rsUsuarioParametros.pc_usu_login#'
				, 
				pc_alteracao_datahora = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				WHERE pc_processo_id = <cfqueryparam value="#arguments.numProc#" cfsqltype="cf_sql_varchar">
			</cfquery> 	 	
			

		<cfreturn true />
	</cffunction>










	
	<cffunction name="cards" returntype="any" hint="Criar os cards dos processos (ainda não utilizado em nenhuma página)">
		<cfargument name="status" type="any" required="true"   /> <!-- -->

		<cfquery name="rsProcCards" datasource="#application.dsn_processos#">
			SELECT pc_processos.*,pc_orgaos.pc_org_descricao,pc_orgaos.pc_org_sigla, pc_status.*,pc_avaliacao_tipos.pc_aval_tipo_descricao
			FROM   pc_processos 
			INNER JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
			INNER JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado =pc_orgaos.pc_org_mcu
			INNER JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 11> 
				<cfif '#arguments.status#' eq 'todos'><cfelse>WHERE  pc_num_status='#arguments.status#'</cfif>
			<cfelse>
		    	WHERE  pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#'<cfif '#arguments.status#' eq 'todos'><cfelse> and pc_num_status='#arguments.status#'</cfif>
			</cfif>
			ORDER BY pc_datahora_cadastro desc 	
		</cfquery>

		<div class="card-body" style="border: solid 3px ##ffD400">
			<div class="row" style="justify-content: space-around;">
				<cfloop query="rsProcCards" >
					<cfset status = "#pc_status_id#"> 
					
					<section class="content" >
						
						<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
						   SELECT pc_avaliadores.pc_avaliador_matricula FROM pc_avaliadores WHERE pc_avaliador_id_processo = '#pc_processo_id#' 
						</cfquery>
						<cfset avaliadores = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>
					
						

						<div id="processosCadastrados" class="container-fluid">
							<div class="row">
								<div id="cartao" style="width:270px;" >
									<!-- small card -->
									<div class="small-box " style="<cfoutput>#pc_status_card_style_body#</cfoutput> ;font-weight: normal;">
										<div class="ribbon-wrapper ribbon-lg" >
											<div class="ribbon " style="font-size:12px;left:8px;<cfoutput>#pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#pc_status_card_nome_ribbon#</cfoutput></div>
										</div>
										<div class="card-header" style="height:120px;width:250px;border-bottom:none; font-weight: normal!important">
											<p style="font-size:16px;margin-bottom: 0.3rem!important;"><cfoutput>Processo n°: #pc_processo_id#</cfoutput></p>
											<p style="font-size:13px;margin-bottom: 0.3rem!important;"><cfoutput>#pc_org_sigla#</cfoutput></p>
											<cfif pc_num_avaliacao_tipo neq 2>
												<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_descricao#</cfoutput></p>
											<cfelse>
												<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_nao_aplica_descricao#</cfoutput></p>
											</cfif>
											
										</div>
										<div class="icon">
											<i class="fas fa-search" style="opacity:0.6;left:100px;top:30px"></i>
										</div>

										<a href="##"  target="_self" class="small-box-footer"   >
											<div style="display:flex;justify-content: space-around;" >
												<input id="pcNumProcessoCard" name="pcNumProcessoCard" type="text" hidden >												
												<i  class="fas fa-trash-alt efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'" style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoDel(<cfoutput>'#pc_processo_id#'</cfoutput>);" data-toggle="tooltip"  tilte="Excluir" ></i>
												<i id="btEdit" class="fas fa-edit efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'"  style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoEditarCard(<cfoutput>'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_iniciarBloqueado#')</cfoutput>;" data-toggle="tooltip"  tilte="Editar"></i>
												<i  class="fas fa-eye efeito-grow"   onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'" style="z-index:100;cursor: pointer;font-size:20px" onclick="javascript:processoVisualizar(<cfoutput>'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_iniciarBloqueado#')</cfoutput>;" tilte="Visualizar"></i>
											</div>
										</a>
									</div>
								</div>
							</div>
						</div>
					</section>
				</cfloop>

				<!-- Fim Cards com os processos cadastrados -->
			</div> <!-- fim row -->
		</div>




	</cffunction>
	












	
	<cffunction name="cardsProcessos" returntype="any" access="remote" hint="Criar os cards dos processos e envia para a páginas pc_CadastroProcesso">
	   

		<cfquery name="rsProcCard" datasource="#application.dsn_processos#">
			SELECT pc_processos.*,pc_orgaos.pc_org_descricao,pc_orgaos.pc_org_sigla, pc_status.*,pc_avaliacao_tipos.pc_aval_tipo_descricao
			FROM   pc_processos 
			INNER JOIN pc_avaliacao_tipos on pc_num_avaliacao_tipo = pc_aval_tipo_id
			INNER JOIN pc_orgaos ON pc_processos.pc_num_orgao_avaliado =pc_orgaos.pc_org_mcu
			INNER JOIN pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11> 
				WHERE  pc_num_status=2
			<cfelseif #application.rsUsuarioParametros.pc_usu_perfil# eq 8>
		   		WHERE  pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' and pc_num_status=2
			<cfelseif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#)>
			    WHERE  pc_num_orgao_origem IN('00436698','00436697','00438080') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)) and pc_num_status=2
			<cfelse>
				WHERE  pc_status.pc_status_id = 0
			</cfif>
			ORDER BY pc_datahora_cadastro desc 	
		</cfquery>

		<style>
			#tabProcCards_wrapper #tabProcCards_paginate ul.pagination {
				justify-content: center!important;
			}	

			
		</style>

		<!-- Main content -->
		<section class="content">
			<div class="container-fluid" style="padding:0px!important">
				<!-- /.card-header -->
				<div class="card-body" style="padding:0px!important">
					<form id="formAcomp" name="formAcomp" format="html"  style="height: auto;">
						<!--acordion-->
						<div id="accordionCadItemPainel" >
							<div class="card card-success" >
								<div class="card-header" style="background-color: #ffD400;">
									<h4 class="card-title ">
										<a class="d-block" data-toggle="collapse" href="#collapseTwo" style="font-size:20px;color:#00416b;font-weight: bold;"> 
											<i class="fas fa-file-alt" style="margin-right:10px"> </i>Processos Cadastrados
										</a>
									</h4>
								</div>
								<div id="collapseTwo" class="" data-parent="#accordion">							
									<div class="card-body" style="border: solid 3px #ffD400;width:100%">
										
										<div class="row" style="justify-content: space-around;">
											<cfif #rsProcCard.recordcount# eq 0 >
												<h4>Nenhum processo na fase de cadastro foi localizado</h4>
											</cfif>
											<cfif #rsProcCard.recordcount# neq 0 >
												<div class="col-sm-12">
													
														<table id="tabProcCards" class="table  " style="background: none;border:none;width:100%">
															<thead >
																<tr style="background: none;border:none">
																	<th style="background: none;border:none"></th>
																</tr>
															</thead>
															
															<tbody class="grid-container" >
																<cfloop query="rsProcCard" >
																	<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
																		SELECT pc_avaliadores.pc_avaliador_matricula FROM pc_avaliadores WHERE pc_avaliador_id_processo = '#pc_processo_id#' 
																	</cfquery>
																	<cfset avaliadores = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>
																	<tr style="width:270px;border:none;">
																		<td style="background: none;border:none;white-space:normal!important;" >	
																			<section class="content" >
																					<div id="processosAcompanhamento" class="container-fluid" >

																							<div class="row">
																								<div id="cartao" style="width:270px;" >
																								
																									<!-- small card -->
																									<div class="small-box " style="<cfoutput>#pc_status_card_style_header#</cfoutput> font-weight: normal;">
																										<cfif #pc_iniciarBloqueado# eq "S">
																									  	  <i id="btBloquear" class="fas fa-lock grow-icon" style="position:absolute;color: red;left: 2px;top:2px;z-index:1" title="Processo Bloqueado: após validação dos itens, não será encaminhado ao órgão avaliado e órgãos responsáveis."></i>
																										</cfif>	
																										<cfif #pc_modalidade# eq "A">
																											<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:10px;"><strong>A</strong></span>
																										<cfelseif #pc_modalidade# eq "E">
																									     	<span style="font-size:1em;color:#fff;position:relative;float:right;margin-right:5px;"><strong>E</strong></span>
																										</cfif>
																										<div class="ribbon-wrapper ribbon-lg" >
																											<div class="ribbon " style="font-size:12px;left:8px;<cfoutput>#pc_status_card_style_ribbon#</cfoutput>"><cfoutput>#pc_status_card_nome_ribbon#</cfoutput></div>
																										</div>
																										

																										<div class="card-header" style="height:120px;width:250px;    font-weight: normal!important;">
																											<p style="font-size:1em;margin-bottom: 0.3rem!important;"><cfoutput>Processo n°: #pc_processo_id#</cfoutput></p>
																											<p style="font-size:1em;margin-bottom: 0.3rem!important;"><cfoutput>#pc_org_sigla#</cfoutput></p>
																											<cfif pc_num_avaliacao_tipo neq 2>
																												<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_descricao#</cfoutput></p>
																											<cfelse>
																												<p style="font-size:12px;margin-bottom: 0!important;"><cfoutput>#pc_aval_tipo_nao_aplica_descricao#</cfoutput></p>
																											</cfif>
																											
																										</div>
																										<div class="icon">
																											<i class="fas fa-search" style="opacity:0.6;left:100px;top:30px"></i>
																										</div>

																										<a href="##"  target="_self" class="small-box-footer"   >
																											<div style="display:flex;justify-content: space-around;" >
																												<input id="pcNumProcessoCard" name="pcNumProcessoCard" type="text" hidden >												
																												<i  class="fas fa-trash-alt efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'" style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoDel(<cfoutput>'#pc_processo_id#'</cfoutput>);" data-toggle="tooltip"  tilte="Excluir" ></i>
																												<i id="btEdit" class="fas fa-edit efeito-grow"  onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'"  style="cursor: pointer;z-index:100;font-size:20px" onclick="javascript:processoEditarCard(<cfoutput>'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#pc_iniciarBloqueado#')</cfoutput>;" data-toggle="tooltip"  tilte="Editar"></i>
																												<i  class="fas fa-eye efeito-grow"   onMouseOver="this.style.color='#000'" onMouseOut="this.style.color='#ffF'" style="z-index:100;cursor: pointer;font-size:20px" onclick="javascript:processoVisualizar(<cfoutput>'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadores#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#pc_iniciarBloqueado#')</cfoutput>;" tilte="Visualizar"></i>
																											</div>
																										</a>
																											
																									</div>
																								</div>
																							</div>
																						
																					</div>
																			</section>
																		</td>
																	</tr>
																</cfloop>
															</tbody>
														</table>
													
													

												</div>
											</cfif>
										</div>
									</div>									
								</div> <!--fim collapseTwo -->
							</div><!--fim card card-success -->	
						</div><!--fim acordion -->
					</form><!-- fim formAcomp -->					
				</div><!-- fim card-body -->	

				<div id="tabAvaliacoesAcompanhamento"></div>
			</div>
		</section>


		
		



		<script language="JavaScript">
			

			$(function () {
				$("#tabProcCards").DataTable({
					"destroy": true,
					"ordering": false,
				    "stateSave": true,
					"responsive": true, 
					"lengthChange": true, 
					"autoWidth":true,
					"sScrollY": "50vh",
					"scrollCollapse": true,
					"dom": 
							"<'row'<'col-sm-12 text-right'f>>" +
							"<'row'<'col-sm-4'l><'col-sm-4'p><'col-sm-4 text-right'i>>" +
							"<'row'<'col-sm-12'tr>>" ,
					"lengthMenu": [
						[10, 25, 50, -1],
						[10, 25, 50, 'All'],
					]
				})
					
			});
		</script>
	</cffunction>








    
	<cffunction name="tabProcessos" returntype="any" access="remote" hint="Criar a tabela dos processos e envia para a páginas pc_CadastroProcesso e pc_CadastroAvaliacoesPainel">
	   
	           
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao, pc_usuarios.pc_usu_nome, pc_usuCoodNacional.pc_usu_nome as nome_coordenadorNacional
						, pc_usuCoodNacional.pc_usu_matricula as matricula_coordenadorNacional

			FROM        pc_processos  INNER JOIN
                        pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
                        pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
                        pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
                        pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
                        pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id LEFT JOIN
						pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula LEFT JOIN
						pc_usuarios as pc_usuCoodNacional ON pc_usu_matricula_coordenador_nacional = pc_usuCoodNacional.pc_usu_matricula
			<cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3 or #application.rsUsuarioParametros.pc_usu_perfil# eq 11> 
				WHERE  pc_num_status=2
			<cfelseif #application.rsUsuarioParametros.pc_usu_perfil# eq 8>
		   		WHERE  pc_num_orgao_origem = '#application.rsUsuarioParametros.pc_usu_lotacao#' and pc_num_status=2
			<cfelseif ListFind("7,14",#application.rsUsuarioParametros.pc_usu_perfil#)>
			    WHERE  pc_num_orgao_origem IN('00436698','00436697','00438080') and (pc_orgaos.pc_org_se = '#application.rsUsuarioParametros.pc_org_se#' OR pc_orgaos.pc_org_se in(#application.seAbrangencia#)) and pc_num_status=2
			<cfelse>
				WHERE  pc_status.pc_status_id = 0
			</cfif>
			ORDER BY 	pc_processos.pc_processo_id DESC	
		</cfquery>
		
		
		
		            
			<div class="row">
				<div class="col-12">
					<div class="card">
						<!-- /.card-header -->
						<div class="card-body">
							<table id="tabProcessos" class="table table-bordered table-striped table-hover text-nowrap">
							<thead style="background: #0083ca;color:#fff">
								<tr style="font-size:14px">
									<th class="sorting_disabled">Controles</th>
									<th>N°Processo SNCI:</th>
									<th >SE/CS:</th>
									<th>Ano PACIN: </th>
									<th>Data Início Avaliação: </th>
									<th>Data Fim Avaliação: </th>
									<th>Status: </th>
									<th>N°SEI: </th>
									<th>N°Relat. SEI: </th>
									<th>Órgão Origem: </th>
									<th>Órgão Avaliado: </th>
									<th>Tipo de Avaliação: </th>
									<th>Modalidade:</th>
									<th>Classificação: </th>
									<th>Coordenador Regional: </th>
									<th>Coordenador Nacional: </th>
									<th>Avaliadores: </th>
									<th>Tipo Demanda: </th>
									<th>Data Hora Cadastro: </th>
									<th>Data Hora Alteração: </th>


								</tr>
							</thead>
							
							<tbody>
								<cfloop query="rsProcTab" >
									<cfset status = "#pc_status_id#"> 
									<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
										SELECT  pc_avaliadores.* ,  pc_orgaos.pc_org_se_sigla + '-' + pc_usuarios.pc_usu_nome + '(' + pc_usuarios.pc_usu_matricula + ')' as avaliadores
										FROM    pc_avaliadores 
												INNER JOIN pc_usuarios ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
												INNER JOIN pc_orgaos ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
										WHERE 	pc_avaliador_id_processo = '#pc_processo_id#'
									</cfquery>	 
								
									<cfset avaliadores = ValueList(rsAvaliadores.avaliadores,'<br>')>
									
									<!-- para polular select multiplo-->
									<cfset avaliadoresSelect = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>

								

									<cfoutput>					
										<tr style="font-size:12px">
											<td>
												<div style="display:flex;justify-content:space-around;border:none">
													<i  class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:1;font-size:16px" onclick="javascript:processoDel(<cfoutput>'#pc_processo_id#'</cfoutput>);" data-toggle="tooltip"  tilte="Excluir" ></i>	
													<i class="fas fa-edit efeito-grow"   style="cursor: pointer;z-index:1;font-size:16px"  onclick="javascript:processoEditarTab(this,'#pc_processo_id#','#pc_num_sei#','#pc_num_rel_sei#', '#pc_num_orgao_origem#','#pc_data_inicioAvaliacao#','#pc_data_fimAvaliacao#','#pc_num_avaliacao_tipo#','#pc_aval_tipo_nao_aplica_descricao#','#pc_num_orgao_avaliado#','#pc_usu_matricula_coordenador#','#pc_usu_matricula_coordenador_nacional#','#pc_num_classificacao#','#avaliadoresSelect#','#pc_modalidade#','#pc_tipo_demanda#','#pc_ano_pacin#','#pc_iniciarBloqueado#' );" data-toggle="tooltip"  tilte="Editar"></i>
													
												</div>
											</td>
											<td>
												#pc_processo_id#
												<cfif #pc_iniciarBloqueado# eq "S">
													<i id="btBloquear" class="fas fa-lock grow-icon" style="color:##000;left: 2px;z-index:1" title="Processo Bloqueado: após validação dos itens, não será encaminhado ao órgão avaliado e órgãos responsáveis."></i>
												</cfif>
											</td>
											<td>#seOrgAvaliado#</td>
											<td>#pc_ano_pacin#</td>
											<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
											<td>#dataInicio#</td>
											<cfif #pc_Modalidade# eq 'A' or #pc_Modalidade# eq 'E'>
												<cfset dataFim = DateFormat(#pc_data_fimAvaliacao#,'DD-MM-YYYY') >
												<td>#dataFim#</td>
											<cfelse>
												<td>NÃO FINALIZADO</td>
											</cfif>
											<td>#pc_status_descricao#</td>
											<cfif #pc_Modalidade# eq 'A' or #pc_Modalidade# eq 'E'>
												<cfset sei = left(#pc_num_sei#,5) & '.'& mid(#pc_num_sei#,6,6) &'/'& mid(#pc_num_sei#,12,4) &'-'&right(#pc_num_sei#,2)>
												<td>#sei#</td>
												<td>#pc_num_rel_sei#</td>
											<cfelse>
												<td>NÃO</td>
												<td>NÃO</td>
											</cfif>
											<td>#siglaOrgOrigem#</td>
											<td>#siglaOrgAvaliado#</td>

											
											<cfif pc_num_avaliacao_tipo neq 2>
												<td>#pc_aval_tipo_descricao#</td>
											<cfelse>
												<td>#pc_aval_tipo_nao_aplica_descricao#</td>
											</cfif>

											<td>
												<cfif #pc_Modalidade# eq 'A'>
													Acompanhamento
												<cfelseif #pc_Modalidade# eq 'E'>
												    ENTREGA DO RELATÓRIO
												<cfelse>
													Normal
												</cfif>
											</td>
											<td>#pc_class_descricao#</td>
											<td>#pc_usu_nome# (#pc_usu_matricula_coordenador#)</td>
											<td>#nome_coordenadorNacional# (#matricula_coordenadorNacional#)</td>
											<td>#avaliadores#</td>
											<cfset dataHoraCadastro = DateFormat(#pc_datahora_cadastro#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_datahora_cadastro#,'HH:mm:ss') & ')'>
											<cfif #pc_tipo_demanda# eq 'P'>
												<td>PLANEJADA</td>
											<cfelseif #pc_tipo_demanda# eq 'E'>
												<td>EXTRAORDINÁRIA</td>
											<cfelse>
										    	<td>Não informado</td>
											</cfif>

											<td>#dataHoraCadastro#</td>
											<cfset dataHoraAlteracao = DateFormat(#pc_alteracao_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_alteracao_datahora#,'HH:mm:ss') & ')'>
											<td>#dataHoraAlteracao# - #pc_alteracao_login#</td>
											

										</tr>
									</cfoutput>
								</cfloop>	
							</tbody>
								
							
							</table>
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
				
				
		<script>
			var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()

			var d = day + "-" + month + "-" + year;	
		$(function () {
			$('#tabProcessos').DataTable( {
				columnDefs: [
					{ "orderable": false, "targets": [0] }//impede que a primeira coluna seja ordenada
				],
				order: [[ 1, "desc" ]],
				responsive: true, 
				lengthChange: true, 
				autoWidth: false,
				select: true,
				stateSave:true,
				buttons: [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						title : 'SNCI_Processos_cadastrados_' + d,
						className: 'btExcel',
					},],
				}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');

				
			} );

		</script>	
	

	</cffunction>









	
	<cffunction name="mudarPerfil"   access="remote" returntype="boolean" hint="Mudar o perfil do usuário na páginas pc_sedebar.cfm. Só é possível essa utilização nos servidores de desenvolvimento e homologação">
		<cfargument name="perfil" type="numeric" required="true" default=""/>
		
			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_usuarios SET pc_usu_perfil = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.perfil#">
				WHERE pc_usu_login = '#application.rsUsuarioParametros.pc_usu_login#'
			</cfquery> 	 	
			

		<cfreturn true />
	</cffunction>






	<cffunction name="mudarLotacao"   access="remote" returntype="boolean" hint="Mudar a lotação do usuário na páginas pc_sedebar.cfm. Só é possível essa utilização nos servidores de desenvolvimento e homologação">
		<cfargument name="lotacao" type="string" required="true" default=""/>
		
			<cfquery datasource="#application.dsn_processos#">
				UPDATE pc_usuarios SET pc_usu_lotacao = <cfqueryparam  cfsqltype="cf_sql_varchar" value="#arguments.lotacao#">
				WHERE pc_usu_login = '#application.rsUsuarioParametros.pc_usu_login#'
			</cfquery> 	 	
			

		<cfreturn true />
	</cffunction>






 
	

	<cffunction name="tabProcessosTODOS" returntype="any" access="remote" hint="Criar a tabela de todos processos e envia para a páginas pc_apoioDeletaProcessos.APENAS PARA DESENVOLVEDORES">
	    <cfargument name="status" type="string" required="false" default=""/> 
        <!--Só retorna os processos que não tem posicionamentos do órgão avaliado-->
		<cfquery name="rsProcTab" datasource="#application.dsn_processos#">
			SELECT      pc_processos.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
						pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
						pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
						, pc_classificacoes.pc_class_descricao, pc_usuarios.pc_usu_nome

			FROM        pc_processos  LEFT OUTER JOIN
                        pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
                        pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
                        pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
                        pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
                        pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id left JOIN
						pc_usuarios ON pc_usu_matricula_coordenador = pc_usu_matricula
			<cfif FindNoCase("intranetsistemaspe", application.auxsite)>			
				WHERE      NOT pc_processos.pc_processo_id in ( SELECT DISTINCT pc_avaliacoes.pc_aval_processo FROM pc_avaliacoes
								LEFT JOIN pc_avaliacao_orientacoes ON pc_avaliacao_orientacoes.pc_aval_orientacao_num_aval = pc_avaliacoes.pc_aval_id
								LEFT JOIN pc_avaliacao_posicionamentos ON pc_avaliacao_posicionamentos.pc_aval_posic_num_orientacao = pc_avaliacao_orientacoes.pc_aval_orientacao_id
								WHERE pc_avaliacao_posicionamentos.pc_aval_posic_status = 3
							)
			</cfif>     		
			ORDER BY 	pc_processos.pc_processo_id DESC	
		</cfquery>
		
		
		

            
			<div class="row">
				<div class="col-12">
					<div class="card">
					
						<!-- /.card-header -->
						<div class="card-body">
							<table id="tabProcessos" class="table table-bordered table-striped table-hover text-nowrap">
							<cfif FindNoCase("intranetsistemaspe", application.auxsite)>
								<h5>Só são listados processos sem posicionamentos de órgãos avaliados.</h5>
							</cfif>
							<thead style="background: #0083ca;color:#fff">
								<tr style="font-size:14px">
									<th>Controles</th>
									<th>N°Processo SNCI:</th>
									<th >SE/CS:</th>
									<th>Data Início: </th>
									<th>Status: </th>
									<th>N°SEI: </th>
									<th>N°Relat. SEI: </th>
									<th>Órgão Origem: </th>
									<th>Órgão Avaliado: </th>
									<th>Tipo de Avaliação: </th>
									<th>Classificação: </th>
									<th>Coordenador: </th>
									<th>Avaliadores: </th>
									<th>Data Hora Cadastro: </th>
									<th>Data Hora Alteração: </th>

								</tr>
							</thead>
							
							<tbody>
								<cfloop query="rsProcTab" >
									<cfset status = "#pc_status_id#"> 
									<cfquery name="rsAvaliadores" datasource="#application.dsn_processos#">
										SELECT  pc_avaliadores.* ,  pc_orgaos.pc_org_se_sigla + '-' + pc_usuarios.pc_usu_nome + '(' + pc_usuarios.pc_usu_matricula + ')' as avaliadores
										FROM    pc_avaliadores 
												INNER JOIN pc_usuarios ON pc_avaliadores.pc_avaliador_matricula = pc_usuarios.pc_usu_matricula 
												INNER JOIN pc_orgaos ON pc_usuarios.pc_usu_lotacao = pc_orgaos.pc_org_mcu
										WHERE 	pc_avaliador_id_processo = '#pc_processo_id#'
									</cfquery>	 
								
									<cfset avaliadores = ValueList(rsAvaliadores.avaliadores,'<br>')>
									
									<!-- para polular select multiplo-->
									<cfset avaliadoresSelect = ValueList(rsAvaliadores.pc_avaliador_matricula,',')>

								

									<cfoutput>					
										<tr style="font-size:12px">
											<td >
												<div style="display:flex;justify-content:space-around;">
													
													
														<i  class="fas fa-trash-alt efeito-grow"   style="cursor: pointer;z-index:100;font-size:16px" onclick="javascript:processoDel(<cfoutput>'#pc_processo_id#'</cfoutput>);" data-toggle="tooltip"  tilte="Excluir" ></i>
													
													
												</div>
											</td>
											<td>#pc_processo_id#</td>
											<td>#seOrgAvaliado#</td>
											<cfset dataInicio = DateFormat(#pc_data_inicioAvaliacao#,'DD-MM-YYYY') >
											<td>#dataInicio#</td>
											<td>#pc_status_descricao#</td>
											<td>#pc_num_sei#</td>
											<td>#pc_num_rel_sei#</td>
											<td>#siglaOrgOrigem#</td>
											<td>#siglaOrgAvaliado#</td>
											<cfif pc_num_avaliacao_tipo neq 2>
												<td>#pc_aval_tipo_descricao#</td>
											<cfelse>
												<td>#pc_aval_tipo_nao_aplica_descricao#</td>
											</cfif>
											<td>#pc_class_descricao#</td>
											<td>#pc_usu_nome#(#pc_usu_matricula_coordenador#)</td>
											<td>#avaliadores#</td>
											<cfset dataHoraCadastro = DateFormat(#pc_datahora_cadastro#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_datahora_cadastro#,'HH:mm:ss') & ')'>
											<td>#dataHoraCadastro#</td>
											<cfset dataHoraAlteracao = DateFormat(#pc_alteracao_datahora#,'DD-MM-YYYY') & ' (' & TimeFormat(#pc_alteracao_datahora#,'HH:mm:ss') & ')'>
											<td>#dataHoraAlteracao# - #pc_alteracao_login#</td>
											

										</tr>
									</cfoutput>
								</cfloop>	
							</tbody>
								
							<tfoot>
								<tr style="font-size:14px">
									<th>Controles</th>
									<th>N°Processo SNCI</th>
									<th>SE</th>
									<th>Data Início</th>
									<th>Status</th>
									<th>N°SEI</th>
									<th>N°Relat. SEI</th>
									<th>Órgão Origem</th>
									<th>Órgão Avaliado</th>
									<th>Tipo de Avaliação</th>
									<th>Classificação</th>
									<th>Coordenador</th>
									<th>Avaliadores</th>
									<th>Data Hora Cadastro</th>
									<th>Data Hora Alteração</th>
								</tr>
							</tfoot>
							</table>
						</div>
						<!-- /.card-body -->
					</div>
					<!-- /.card -->
				</div>
			<!-- /.col -->
			</div>
			<!-- /.row -->
				
				
		<script language="JavaScript">
			$(function () {
				$("#tabProcessos").DataTable({
				"destroy": true,
				"stateSave": false,
				"responsive": true, 
				"lengthChange": true, 
				"autoWidth": false,
				"buttons": [{
						extend: 'excel',
						text: '<i class="fas fa-file-excel fa-2x grow-icon" ></i>',
						className: 'btExcel',
					}],
				}).buttons().container().appendTo('#tabProcessos_wrapper .col-md-6:eq(0)');
					
			});

		</script>	
	

	</cffunction>








	<cffunction name="deletarTodoProcesso"   access="remote" returntype="boolean" hint="Deleta o processo e todos os registros associados. Utilizado apenas pelos desenvolvedores.">
		<cfargument name="numProc" type="string" required="true" default=""/>

			<cfquery datasource="#application.dsn_processos#" name="rsPc_anexos"> 
				SELECT pc_anexos.*, pc_avaliacoes.*    FROM  pc_anexos
				inner join pc_avaliacoes on pc_avaliacoes.pc_aval_id = pc_anexos.pc_anexo_avaliacao_id
				WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery>

			<cfloop query="rsPc_anexos" >

				<cfif FileExists(pc_anexo_caminho)>
					<cffile action = "delete" File = "#pc_anexo_caminho#">
				</cfif>

				<cfquery datasource="#application.dsn_processos#">
					DELETE FROM pc_anexos
					WHERE pc_anexo_id = #pc_anexo_id#
				</cfquery> 	
				
			</cfloop>

			<cfquery datasource="#application.dsn_processos#" name="rsPc_anexosRelatorios"> 
				SELECT pc_anexos.*   FROM  pc_anexos
				WHERE pc_anexo_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery>

			<cfloop query="rsPc_anexosRelatorios" >

				<cfif FileExists(pc_anexo_caminho)>
					<cffile action = "delete" File = "#pc_anexo_caminho#">
				</cfif>

				<cfquery datasource="#application.dsn_processos#">
					DELETE FROM pc_anexos
					WHERE pc_anexo_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
				</cfquery> 	
				
			</cfloop>





			<cfquery datasource="#application.dsn_processos#" name="DeletaValidacoes">
				DELETE FROM pc_validacoes_chat
				FROM pc_validacoes_chat INNER JOIN pc_avaliacoes on pc_aval_id = pc_validacao_chat_num_aval
				WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="DeletaValidacoes">
				DELETE FROM pc_avaliacao_versoes
				FROM pc_avaliacao_versoes INNER JOIN pc_avaliacoes on pc_aval_id = pc_aval_versao_num_aval
				WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery> 

			
			<cfquery datasource="#application.dsn_processos#" name="DeletaMelhorias">
				DELETE FROM pc_avaliacao_melhorias
				FROM        pc_avaliacao_melhorias 
                INNER JOIN  pc_avaliacoes ON pc_avaliacao_melhorias.pc_aval_melhoria_num_aval = pc_avaliacoes.pc_aval_id
				WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery> 	



			
			<cfquery datasource="#application.dsn_processos#" name="DeletaPosicionamentos">
				DELETE FROM  pc_avaliacao_posicionamentos
				FROM         pc_avaliacao_posicionamentos 
			    INNER JOIN   pc_avaliacao_orientacoes on pc_aval_orientacao_id = pc_aval_posic_num_orientacao
				INNER JOIN   pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
                INNER JOIN   pc_processos on pc_processo_id = pc_aval_processo         
				WHERE pc_processo_id  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="DeletaOrientacoes">
				DELETE FROM  pc_avaliacao_orientacoes
				FROM         pc_avaliacao_orientacoes
			    INNER JOIN   pc_avaliacoes on pc_aval_id = pc_aval_orientacao_num_aval
                INNER JOIN   pc_processos on pc_processo_id = pc_aval_processo         
				WHERE pc_processo_id  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliadores">
				DELETE FROM pc_avaliadores
				WHERE pc_avaliadores.pc_avaliador_id_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="DeletaObjEstrategicos">
				DELETE FROM pc_processos_objEstrategicos
				WHERE pc_processos_objEstrategicos.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" name="DeletaRiscosEstrategicos">
				DELETE FROM pc_processos_riscosEstrategicos
				WHERE pc_processos_riscosEstrategicos.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" name="DeletaMebitda">
				DELETE FROM pc_processos_mebitda
				WHERE pc_processos_mebitda.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery>

			<cfquery datasource="#application.dsn_processos#" name="DeletaAvaliacoes">
				DELETE FROM pc_avaliacoes
				WHERE pc_avaliacoes.pc_aval_processo = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery> 

			<cfquery datasource="#application.dsn_processos#" name="DeletaProcessos">
				DELETE FROM pc_processos
				WHERE pc_processos.pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.numProc#">
			</cfquery>

			
				

		<cfreturn true />
	</cffunction>




	





</cfcomponent>