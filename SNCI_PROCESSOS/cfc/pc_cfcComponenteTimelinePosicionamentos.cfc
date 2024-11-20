<cfcomponent>
<cfprocessingdirective pageencoding = "utf-8">	

    <cffunction name="timelineViewPosicionamentos"   access="remote" hint="componente timeline dos posicionamentos">
        <cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
        <cfargument name="paraControleInterno" type="string" required="true" />

        <cfset var rsProcessos = "" />
        <cfset var rsPosicionamentos = "" />
        <cfset var data = "" />
        <cfset var icone = "" />
        <cfset var cor = "" />
        <cfset var hora = "" />
        <cfset var arquivo = "" />
        <cfset var dataPrev = "" />
        <cfset var rsAnexosPosic = "" />
        
        

        <cfquery name="rsProcessos" datasource="#application.dsn_processos#">

			SELECT      pc_processos.*, pc_avaliacoes.*, pc_orgaos.pc_org_descricao as descOrgAvaliado, pc_orgaos.pc_org_mcu as mcuAvaliado, pc_orgaos.pc_org_sigla as siglaOrgAvaliado, pc_status.*, 
								pc_avaliacao_tipos.pc_aval_tipo_descricao, pc_orgaos.pc_org_se_sigla as seOrgAvaliado,
								pc_orgaos_1.pc_org_descricao AS descOrgOrigem, pc_orgaos_1.pc_org_sigla AS siglaOrgOrigem
								, pc_classificacoes.pc_class_descricao,  pc_orgaos.pc_org_se_sigla,  pc_orgaos.pc_org_mcu, pc_avaliacao_orientacoes.*,
								pc_orgao_OrientacaoResp.pc_org_sigla as orgaoRespOrientacao, pc_orgao_OrientacaoResp.pc_org_mcu as mcuOrgaoRespOrientacao
								, pc_orientacao_status.pc_orientacao_status_finalizador

			FROM        pc_processos INNER JOIN
								pc_avaliacoes on pc_processo_id =  pc_aval_processo INNER JOIN
								pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id INNER JOIN
								pc_orgaos ON pc_processos.pc_num_orgao_avaliado = pc_orgaos.pc_org_mcu INNER JOIN
								pc_status ON pc_processos.pc_num_status = pc_status.pc_status_id INNER JOIN
								pc_orgaos AS pc_orgaos_1 ON pc_processos.pc_num_orgao_origem = pc_orgaos_1.pc_org_mcu INNER JOIN
								pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id right JOIN
								pc_avaliacao_orientacoes on pc_aval_orientacao_num_aval = pc_aval_id INNER JOIN
								pc_orgaos as pc_orgao_OrientacaoResp on pc_orgao_OrientacaoResp.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
								INNER JOIN pc_orientacao_status on pc_orientacao_status_id = pc_aval_orientacao_status
			WHERE pc_aval_orientacao_id  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#"> 	 

		</cfquery>	

        <cfquery name="rsPosicionamentos" datasource="#application.dsn_processos#">
            SELECT pc_avaliacao_posicionamentos.*
                , pc_orgaos.* 
                , pc_usuarios.*
                , pc_orgaos2.pc_org_sigla AS orgaoResp
                , pc_orgaos2.pc_org_mcu AS mcuOrgaoResp
                , CONVERT(CHAR, pc_aval_posic_datahora, 103) AS dataPosic
                , pc_orientacao_status.pc_orientacao_status_finalizador AS eHstatusFinalizador
                , pc_orientacao_status.pc_orientacao_status_card_style_header
                , CASE 
                    WHEN pc_aval_posic_status IN (4, 5) THEN 
                        CASE 
                            WHEN CAST(pc_aval_posic_dataPrevistaResp AS DATE) < (
                                SELECT TOP 1 CAST(subquery.pc_aval_posic_datahora AS DATE)
                                FROM pc_avaliacao_posicionamentos AS subquery
                                WHERE subquery.pc_aval_posic_num_orientacao =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
                                AND subquery.pc_aval_posic_id > pc_avaliacao_posicionamentos.pc_aval_posic_id
                                
                                ORDER BY subquery.pc_aval_posic_id ASC
                            ) THEN 'PENDENTE'
                            ELSE pc_orientacao_status.pc_orientacao_status_descricao
                        END
                    ELSE pc_orientacao_status.pc_orientacao_status_descricao
                END AS statusDescricao
               
                , CASE 
                    WHEN pc_aval_posic_id = (
                        SELECT MAX(pc_aval_posic_id)
                        FROM pc_avaliacao_posicionamentos AS subquery
                        WHERE subquery.pc_aval_posic_num_orientacao =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
                            AND subquery.pc_aval_posic_enviado = 1
                    ) THEN 1
                    ELSE 0
                END AS ehMaiorId
            FROM pc_avaliacao_posicionamentos
            INNER JOIN pc_orgaos ON pc_org_mcu = pc_aval_posic_num_orgao
            LEFT JOIN pc_orgaos AS pc_orgaos2 ON pc_orgaos2.pc_org_mcu = pc_aval_posic_num_orgaoResp
            INNER JOIN pc_usuarios ON pc_usu_matricula = pc_aval_posic_matricula
            INNER JOIN pc_orientacao_status ON pc_orientacao_status_id = pc_aval_posic_status
            WHERE pc_aval_posic_num_orientacao = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
            AND pc_aval_posic_enviado = 1
            <cfif arguments.paraControleInterno EQ 'N'>  
                AND NOT pc_aval_posic_status IN (13, 14, 17)
            </cfif>
            ORDER BY pc_aval_posic_dataHora DESC, pc_aval_posic_id DESC
        </cfquery>

        
        <!--timeline -->
        <div id="accordionCadItemPainel" style="margin-bottom:100px">
                <div class="card-header card-header_backgroundColor" >
                    <h4 class="card-title ">	
                        <div  class="d-block" style="font-size:20px;color:#fff;font-weight: bold;"> 
                            <i class="fas fa-comments" style="margin-top:4px;"></i><span style="margin-left:10px;font-size:16px;">
                            <span id="tituloParaPDF">
                                MANIFESTAÇÕES: <cfoutput>Orientação (ID: #rsProcessos.pc_aval_orientacao_id#) para #rsProcessos.orgaoRespOrientacao# (item: #rsProcessos.pc_aval_numeracao# - Processo: #rsProcessos.pc_processo_id#)</cfoutput></span>
                            </span>
                        </div>
                    </h4>
                    <div class="card-tools" align="center">
                        <i id="exportarTimelinePDF"  class="fas fa-file-pdf fa-2x grow-icon" style="color:#ad0001;cursor:pointer;margin-right:20px" title="Exportar o Histórico para PDF" ></i>	
                        <i id="btRecolherPosic"  class="fas fa-eye-slash fa-2x grow-icon" style="color:color:#fff;cursor:pointer;margin-right:20px" title="Recolher todas as manifestações" ></i>	
                    </div>
                </div>
                
                <div id="collapseTwo" class="" data-parent="#accordion" style="max-height:400px;">
                    <div class="card-body card_border_correios" >

                        <!-- Timelime -->
                        <div class="row" style="max-height:400px;overflow: auto">
                            <div class="timeline" >
                                <cfoutput query = "rsPosicionamentos" group="dataPosic">
                                    <!-- timeline time label -->
                                    <div class="time-label">
                                        <cfset data = DateFormat(#pc_aval_posic_dataHora#,'DD-MM-YYYY') >
                                        <span class="bg-blue">#data#</span>
                                    </div>
                                    <!-- /.timeline-label -->
                                    <cfoutput>
                                        <!-- timeline item -->
                                        <cfif #pc_org_controle_interno# eq 'S' >
                                            <div>
                                                <cfif #pc_aval_posic_status# eq 13 OR #pc_aval_posic_status# eq 17>
                                                    <cfset icone = "fa-gear">
                                                <cfelseif #pc_aval_posic_status# eq 14>
                                                    <cfset icone = "fa-lock">
                                                <cfelseif #pc_aval_posic_status# eq 16>
                                                    <cfset icone = "fa-clock">
                                                <cfelse>
                                                        <cfset icone = "fa-user">
                                                </cfif>

                                                <cfif ListFind("13,14,16,17", #pc_aval_posic_status#)>
                                                    <cfset cor = "##dc3545 ">
                                                     <i class="fas #icone# bg-red"  style="margin-top:6px;color:##fff"></i>
                                                <cfelse>
                                                    <cfif arguments.paraControleInterno eq 'S'>     
                                                        <cfset cor = "##ececec">
                                                         <i class="fas #icone# #cor#"  style="margin-top:6px;color:##fff"></i>  
                                                    <cfelse>
                                                        <cfset cor = "##28a745">
                                                        <i class="fas #icone# bg-green"  style="margin-top:6px;color:##fff"></i>
                                                    </cfif>  
                                                         
                                                </cfif>
                                               
                                               
                                               
                                                <div class="timeline-item">
                                                    <cfset hora = TimeFormat(#pc_aval_posic_dataHora#,'HH:mm') >
                                                    
                                                    <span class="time" style="padding:4px;font-size:9px"><i class="fas fa-calendar"></i> #data#<br><i class="fas fa-clock"></i> #hora#<br><i class="fas fa-key"></i> #pc_aval_posic_id#</span>
                                                    
                                                    <div class="card card-primary collapsed-card posicContInterno" >
                                                        <div class="card-header" style="background-color:#cor#">
                                                            <a class="d-block" data-toggle="collapse" href="##collapseOne" style="font-size:14px;color:<cfif #cor# neq "##ececec">##fff<cfelse>##00416b</cfif>" data-card-widget="collapse">
                                                                <button type="button" class="btn btn-tool" data-card-widget="collapse"><i class="fas fa-plus" style="color:<cfif #cor# neq "##ececec">##fff<cfelse>gray</cfif>"></i>
                                                                </button></i>
                                                                                    
                                                                    <cfif arguments.paraControleInterno eq 'S'>     
                                                                        <cfif pc_aval_posic_status eq 13 OR pc_aval_posic_status eq 17 or pc_aval_posic_status eq 14  or eHstatusFinalizador eq 'S'>
                                                                            De: #pc_org_sigla# (#pc_usu_nome#) 
                                                                        <cfelse>
                                                                            De: #pc_org_sigla# (#pc_usu_nome#) -> Para: #orgaoResp# (#mcuOrgaoResp#)
                                                                        </cfif>
                                                                    <cfelse>
                                                                        <cfif eHstatusFinalizador eq 'N'>
                                                                            De: Controle Interno -> Para: #orgaoResp# (#mcuOrgaoResp#)  
                                                                        <cfelse>
                                                                            De: Controle Interno
                                                                        </cfif>

                                                                    </cfif>
                                                                
                                                                <cfif #statusDescricao# eq 'PENDENTE' OR (#ehMaiorId# EQ 1   AND #pc_aval_posic_dataPrevistaResp# neq '' and DATEFORMAT(#pc_aval_posic_dataPrevistaResp#,"yyyy-mm-dd")  lt DATEFORMAT(Now(),"yyyy-mm-dd") and (#pc_aval_posic_status# eq 4 or #pc_aval_posic_status# eq 5))>
                                                                    <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
                                                                        <td align="center"><span class="statusOrientacoes" style="background:##FFA500;color:##fff;font-size: 10px;float: right;margin-left:20px" >PENDENTE</span></td>
                                                                    <cfelse>
                                                                        <td align="center"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;font-size: 10px;float: right;margin-left:20px" >PENDENTE</span></td>
                                                                    </cfif>
                                                                <cfelseif #pc_aval_posic_status# eq 3>
                                                                    <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
                                                                        <span  class="statusOrientacoes" style="background:##FFA500;color:##fff;font-size: 10px;float: right;margin-left:20px" >#statusDescricao#</span>
                                                                    <cfelse>
                                                                        <span  class="statusOrientacoes" style="background:##dc3545;color:##fff;font-size: 10px;float: right;margin-left:20px" >#statusDescricao#</span>
                                                                    </cfif>
                                                                <cfelse>
                                                                    <span class="statusOrientacoes" style="#pc_orientacao_status_card_style_header#;font-size: 10px;float: right;margin-left:20px"  >#statusDescricao#</span>
                                                                </cfif>
                                                            </a>
                                                        
                                                        </div>
                                                        <div class="card-body" >
                                                            <cfif ListFind("4,5,16", #pc_aval_posic_status#) and pc_aval_posic_dataPrevistaResp neq ''>
                                                                <cfset dataPrev = DateFormat(#pc_aval_posic_dataPrevistaResp#,'DD-MM-YYYY') >
                                                                <pre>#pc_aval_posic_texto#<br><br><p><span>Prazo para resposta: <strong>#dataPrev#</strong></p></pre>
                                                            <cfelse>	
                                                                <pre>
                                                                    #pc_aval_posic_texto#
                                                                    <cfif pc_aval_posic_status eq 15 and pc_aval_posic_numProcJudicial neq ''>
                                                                        <br><p><span>N° Processo Judicial: <strong>#pc_aval_posic_numProcJudicial#</strong></p></span></pre>
                                                                    </cfif>
                                                                </pre>
                                                            </cfif>
                                                            
                                        <cfelse>
                                            <!-- timeline item -->
                                            <div>

                                                <cfif arguments.paraControleInterno eq 'S'> 
                                                    <cfif pc_aval_posic_status eq 3 ><!--se for uma resposta-->
                                                        <i class="fas fa-user bg-green"  style="margin-top:6px;color:##fff"></i>
                                                    <cfelse><!--se não for uma resposta é uma distribuição do órgão avaliado ao órgão subordinador-->
                                                        <i class="fas fa-user ##ececec"  style="margin-top:6px;color:##fff"></i>
                                                    </cfif>
                                                <cfelse>
                                                    <cfif pc_aval_posic_status eq 3 >
                                                        <i class="fas fa-user ##ececec"  style="margin-top:6px;color:##fff"></i>
                                                    <cfelseif mcuOrgaoResp eq '#application.rsUsuarioParametros.pc_usu_lotacao#'>
                                                        <i class="fas fa-user bg-green"  style="margin-top:6px;color:##fff"></i>
                                                    <cfelse>
                                                        <i class="fas fa-user ##ececec"  style="margin-top:6px;color:##fff"></i>
                                                    </cfif>
                                                </cfif>


                                                <div class="timeline-item">
                                                    <cfset hora = TimeFormat(#pc_aval_posic_dataHora#,'HH:mm') >
                                                    
                                                    
                                                    <span class="time" style="padding:4px;font-size:9px"><i class="fas fa-calendar"></i> #data#<br><i class="fas fa-clock"></i> #hora#<br><i class="fas fa-key"></i> #pc_aval_posic_id#</span>
                                                    
                                                    <div class="card card-primary collapsed-card posicOrgAvaliado" >

                                                        <cfif arguments.paraControleInterno eq 'S'>
                                                            <cfif pc_aval_posic_status eq 3 ><!--se for uma resposta-->
                                                                <div class="card-header" style="background-color:##28a745;">
                                                            <cfelse><!--se não for uma resposta é uma distribuição do órgão avaliado ao órgão subordinador-->
                                                                <div class="card-header" style="background-color:##ececec;">
                                                            </cfif>
                                                                <a class="d-block" data-toggle="collapse" href="##collapseOne" style="font-size:16px;<cfif pc_aval_posic_status neq 3 >color:gray</cfif>" data-card-widget="collapse">
                                                                    <button type="button" class="btn btn-tool" data-card-widget="collapse"><i class="fas fa-plus" style="<cfif pc_aval_posic_status neq 3 >color:gray</cfif>"></i>
                                                                    </button></i>
                                                                    
                                                                        <cfif pc_aval_posic_status eq 3 ><!--se for uma resposta-->
                                                                            De: #pc_org_sigla# (#pc_usu_nome#) -> Para: Controle Interno
                                                                        <cfelse><!--se não for uma resposta é uma distribuição do órgão avaliado ao órgão subordinador-->
                                                                            De: #pc_org_sigla# (#pc_usu_nome#) -> Para: #orgaoResp# (#mcuOrgaoResp#) 
                                                                        </cfif>
                                                                        
                                                                        <cfif #statusDescricao# eq 'PENDENTE' OR (#ehMaiorId# EQ 1   AND #pc_aval_posic_dataPrevistaResp# neq '' and DATEFORMAT(#pc_aval_posic_dataPrevistaResp#,"yyyy-mm-dd")  lt DATEFORMAT(Now(),"yyyy-mm-dd") and (#pc_aval_posic_status# eq 4 or #pc_aval_posic_status# eq 5))>
                                                                            <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
                                                                                <td align="center"><span class="statusOrientacoes" style="background:##FFA500;color:##fff;font-size: 10px;float: right;margin-left:20px" >PENDENTE</span></td>
                                                                            <cfelse>
                                                                                <td align="center"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;font-size: 10px;float: right;margin-left:20px" >PENDENTE</span></td>
                                                                            </cfif>
                                                                        <cfelseif #pc_aval_posic_status# eq 3>
                                                                            <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
                                                                                <span  class="statusOrientacoes" style="background:##FFA500;color:##fff;font-size: 10px;float: right;margin-left:20px" >#statusDescricao#</span>
                                                                            <cfelse>
                                                                                <span  class="statusOrientacoes" style="background:##dc3545;color:##fff;font-size: 10px;float: right;margin-left:20px" >#statusDescricao#</span>
                                                                            </cfif>
                                                                        <cfelse>
                                                                            <span class="statusOrientacoes" style="#pc_orientacao_status_card_style_header#;font-size: 10px;float: right;margin-left:20px"  >#statusDescricao#</span>
                                                                        </cfif>       
                                                                </a>
                                                            </div>
                                                        <cfelse>
                                                            <cfif pc_aval_posic_status eq 3 >
                                                                <div class="card-header" style="background-color: ##ececec;">
                                                                <a class="d-block" data-toggle="collapse" href="##collapseOne" style="font-size:16px;color:##00416b" data-card-widget="collapse">
                                                                
                                                                <button type="button" class="btn btn-tool" data-card-widget="collapse"><i class="fas fa-plus" style="color:gray"></i>
                                                                </button></i>
                                                            <cfelseif mcuOrgaoResp eq '#application.rsUsuarioParametros.pc_usu_lotacao#'>
                                                                <div class="card-header" style="background-color: ##28a745;"> 
                                                                <a class="d-block" data-toggle="collapse" href="##collapseOne" style="font-size:16px;color:##fff" data-card-widget="collapse">
                                                                
                                                                <button type="button" class="btn btn-tool" data-card-widget="collapse"><i class="fas fa-plus" style="color:##ececec;"></i>
                                                                </button></i>
                                                            <cfelse>
                                                                <div class="card-header" style="background-color: ##ececec;">
                                                                <a class="d-block" data-toggle="collapse" href="##collapseOne" style="font-size:16px;color:##00416b" data-card-widget="collapse">
                                                                
                                                                <button type="button" class="btn btn-tool" data-card-widget="collapse"><i class="fas fa-plus" style="color:gray"></i>
                                                                </button></i>
                                                            </cfif>
                                                            <cfif pc_aval_posic_status eq 3>
                                                                De: #pc_org_sigla# (#pc_usu_nome#) -> Para: Controle Interno
                                                            <cfelse>
                                                                De: #pc_org_sigla# (#pc_usu_nome#) -> Para: #orgaoResp# (#mcuOrgaoResp#) 
                                                            </cfif>
                                                                    <cfif #statusDescricao# eq 'PENDENTE' OR (#ehMaiorId# EQ 1   AND #pc_aval_posic_dataPrevistaResp# neq '' and DATEFORMAT(#pc_aval_posic_dataPrevistaResp#,"yyyy-mm-dd")  lt DATEFORMAT(Now(),"yyyy-mm-dd") and (#pc_aval_posic_status# eq 4 or #pc_aval_posic_status# eq 5))>
                                                                        <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S'>
                                                                            <td align="center"><span class="statusOrientacoes" style="background:##FFA500;color:##fff;font-size: 10px;float: right;margin-left:20px" >PENDENTE</span></td>
                                                                        <cfelse>
                                                                            <td align="center"><span  class="statusOrientacoes" style="background:##dc3545;color:##fff;font-size: 10px;float: right;margin-left:20px" >PENDENTE</span></td>
                                                                        </cfif>
                                                                    <cfelseif #pc_aval_posic_status# eq 3>
                                                                        <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'N'>
                                                                            <span  class="statusOrientacoes" style="background:##FFA500;color:##fff;font-size: 10px;float: right;margin-left:20px" >#statusDescricao#</span>
                                                                        <cfelse>
                                                                            <span  class="statusOrientacoes" style="background:##dc3545;color:##fff;font-size: 10px;float: right;margin-left:20px" >#statusDescricao#</span>
                                                                        </cfif>
                                                                    <cfelse>
                                                                        <span class="statusOrientacoes" style="#pc_orientacao_status_card_style_header#;font-size: 10px;float: right;margin-left:20px"  >#statusDescricao#</span>
                                                                    </cfif>
                                                                </a>
                                                            
                                                            </div>
                                                        </cfif>
                                                        


                                                        <div class="card-body" >
                                                            <cfif ListFind("4,5,16", #pc_aval_posic_status#) and pc_aval_posic_dataPrevistaResp neq ''>
                                                                <cfset dataPrev = DateFormat(#pc_aval_posic_dataPrevistaResp#,'DD-MM-YYYY') >
                                                                <pre >#pc_aval_posic_texto#<br><br><p><span>Prazo para resposta: <strong>#dataPrev#</strong></p></pre>
                                                            <cfelse>	
                                                                <pre >
                                                                    #pc_aval_posic_texto#
                                                                    <cfif pc_aval_posic_status eq 15 and pc_aval_posic_numProcJudicial neq ''>
                                                                        <br><p><span>N° Processo Judicial: <strong>#pc_aval_posic_numProcJudicial#</strong></p></span></pre>
                                                                    </cfif>
                                                                </pre>
                                                            </cfif>
                                                           
                                        </cfif>
                                                        <!--Inicio TabAnexosPosic-->
                                                        <div id="tabAnexosPosicDiv" style="margin-left: 0.75rem;">
                                                            <cfquery datasource="#application.dsn_processos#" name="rsAnexosPosic">
                                                                Select pc_anexo_nome,pc_anexo_caminho,pc_anexo_aval_posic  FROM pc_anexos 
                                                                WHERE pc_anexo_aval_posic = #pc_aval_posic_id# 
                                                                order By pc_anexo_id desc
                                                            </cfquery>
                                                            <cfif rsAnexosPosic.recordcount neq 0 >
                                                               
                                                                <table id="tabAnexosPosic_#rsAnexosPosic.pc_anexo_aval_posic#" class="table table-striped table-hover text-nowrap  table-responsive">

                                                                    <thead>
                                                                        <tr>
                                                                            <th>Anexos do posicicionamento:</th>
                                                                        </tr>
                                                                    </thead>
                                                                    <tbody>
                                                                        <cfloop query="rsAnexosPosic" >
                                                                            <cfif FileExists(pc_anexo_caminho)>	
                                                                                    <cfset arquivo = ListLast(pc_anexo_caminho,'\')>
                                                                                    <tr style="font-size:12px" >
                                                                                        <td >	
                                                                                            <div style="display:flex;align-items: center;">
                                                                                                <div>														
                                                                                                    <cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
                                                                                                        <i id="btAbrirAnexo" class="fas fa-eye efeito-grow"   style="cursor: pointer;z-index:100;" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_blank')"   title="Visualizar" ></i>
                                                                                                    <cfelse>
                                                                                                        <i id="btAbrirAnexo" class="fas fa-download efeito-grow"   style="cursor: pointer;z-index:100;" onClick="window.open('pc_Anexos.cfm?arquivo=#arquivo#&nome=#pc_anexo_nome#','_self')"   title="Baixar" ></i>
                                                                                                    </cfif>
                                                                                                </div>
                                                                                                <div style="margin-left:20px">
                                                                                                    <cfif right(#pc_anexo_caminho#,3) eq 'pdf'>
                                                                                                        <i class="fas fa-file-pdf " style="color:red;"></i>
                                                                                                    <cfelseif right(#pc_anexo_caminho#,3) eq 'zip'>
                                                                                                        <i class="fas  fa-file-zipper" style="color:blue;"></i>
                                                                                                    <cfelse>
                                                                                                        <i class="fas fa-file-excel" style="color:green;"></i>
                                                                                                    </cfif>	
                                                                                                #pc_anexo_nome#</div>
                                                                                            </div>
                                                                                        </td>
                                                                                    </tr>
                                                                            </cfif>
                                                                        </cfloop>	
                                                                    </tbody>
                                                                </table>
                                                                    
                                                            </cfif>
                                                        </div>
                                                        <!--Fim TabAnexosPosic-->
                                                    </div>
                                                </div>

                                            </div>
                                        </div>
                                        <!-- END timeline item -->
                                    </cfoutput>	
                                        
                                </cfoutput>
                                
                            <div >
                                <i class="fas fa-clock bg-gray"></i>
                                <div class="timeline-item"></div>
                            </div>
                            
                            
                        </div>
                    </div>
                </div>
           
        
        </div>

        <script language="JavaScript">
			
          
                
           

			
			$(document).ready(function() {

				$('.posicContInterno').CardWidget('expand')
				$('.posicOrgAvaliado').CardWidget('expand')
				$('#btRecolherPosic').removeClass('fa-eye')
				$('#btRecolherPosic').addClass('fa-eye-slash')
				$('#exportarTimelinePDF').on('click', function() {
					exportarTimelineParaPDF()
				});

                // Seleciona todas as tabelas com o ID 'tabAnexosPosic'
                // Seleciona todas as tabelas que contêm "tabAnexosPosic" no ID
                 var tables = $("[id*='tabAnexosPosic']");

                // Aplica a configuração DataTables a cada tabela
                tables.each(function() {
                    // Verifica se o elemento é realmente uma tabela
                    if (this.tagName.toLowerCase() === 'table' && !$.fn.DataTable.isDataTable(this)) {
                        $(this).DataTable({
                            "destroy": true,
                            "stateSave": false,
                            "responsive": true,
                            "lengthChange": false,
                            "autoWidth": false,
                            "searching": false,
                            "pageLength": 5,
                            language: {
                                url: "../SNCI_PROCESSOS/plugins/datatables/traducao.json"
                            }
                        });
                    }
                });
			});
			
		    $('#btRecolherPosic').on('click', function (event)  {

				if($('#btRecolherPosic').hasClass('fa-eye-slash')){
					$('.posicContInterno').CardWidget('collapse')
					$('.posicOrgAvaliado').CardWidget('collapse')
					$('#btRecolherPosic').removeClass('fa-eye-slash')
					$('#btRecolherPosic').addClass('fa-eye')
					$('#btRecolherPosic').attr('title','Expandir todas as manifestações')
				}else{
					$('.posicContInterno').CardWidget('expand')
					$('.posicOrgAvaliado').CardWidget('expand')
					$('#btRecolherPosic').removeClass('fa-eye')
					$('#btRecolherPosic').addClass('fa-eye-slash')
					$('#btRecolherPosic').attr('title','Recolher todas as manifestações')

				}
		    });

			
		 

		
			
				
			
		</script>


    </cffunction>



</cfcomponent>