<cfcomponent >
    <cfprocessingdirective pageencoding = "utf-8">


    <cffunction name="infoOrientacao"   access="remote" hint="">
        <cfargument name="pc_aval_orientacao_id" type="numeric" required="true" />
        <cfargument name="pc_processo_id" type="string" required="true" />

        <cfquery name="rsAvalOrentacao" datasource="#application.dsn_processos#">
            SELECT      pc_avaliacao_orientacoes.*
                        ,pc_aval_orientacao_mcu_orgaoResp as mcuOrgaoResp
                        ,pc_aval_orientacao_mcu_orgaoResp as mcuOrgResp
                        ,pc_orgaos.pc_org_sigla as siglaOrgResp
            FROM        pc_avaliacao_orientacoes
                        INNER JOIN pc_orgaos on pc_orgaos.pc_org_mcu = pc_aval_orientacao_mcu_orgaoResp
            WHERE pc_aval_orientacao_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">	 													
        </cfquery>

        <cfquery name="rsCategoriaControle" datasource="#application.dsn_processos#">
            SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_orientacao_categoriasControles	
            INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_orientacao_categoriasControles.pc_aval_categoriaControle_id
            WHERE pc_avaliacao_orientacao_categoriasControles.pc_aval_orientacao_id =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_orientacao_id#">
        </cfquery>
        <cfset categoriaControleList = ValueList(rsCategoriaControle.pc_aval_categoriaControle_descricao, ', ')>


        <cfif rsAvalOrentacao.pc_aval_orientacao_distribuido eq 1>
            <div class="badge" style="background-color: #e83e8c;color:#fff;margin-left:23px;margin-bottom:10px;font-weight: 400!important;font-size: 0.8rem;">Orientação distribuída pelo órgão subordinador</div>
        </cfif>
        <cfoutput> 
              
             
                <fieldset style="padding:0px!important;min-height: 90px;">
                    <legend style="margin-left:20px">Medida/Orientação p/ regularização: ID <strong>#rsAvalOrentacao.pc_aval_orientacao_id#</strong> - #rsAvalOrentacao.siglaOrgResp# (#rsAvalOrentacao.mcuOrgResp#):</legend>                                         
                    <pre class="font-weight-light " style="color:##0083ca!important;font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsAvalOrentacao.pc_aval_orientacao_descricao#</pre>
                </fieldset>
         
            <cfset ano = RIGHT(#arguments.pc_processo_id#,4)>
            <cfif #ano# gte 2024 and rsCategoriaControle.recordcount gt 0> 
                
                    <fieldset style="padding:0px!important;min-height: 90px;">
                        <legend style="margin-left:20px">Benefício Não Financeiro da Medida/Orientação para Regularização:</legend>   
                        <cfif rsAvalOrentacao.pc_aval_orientacao_beneficioNaoFinanceiro neq ''>                                      
                            <pre class="font-weight-light " style="color:##0083ca!important;font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">#rsAvalOrentacao.pc_aval_orientacao_beneficioNaoFinanceiro#</pre>
                        <cfelse>
                            <pre class="font-weight-light " style="color:##0083ca!important;font-style: italic;max-height: 100px; overflow-y: auto;margin-bottom:10px">Não se aplica</pre>
                        </cfif>
                    </fieldset>
                

                <li >Categoria(s) do Controle Proposto: <span style="color:##0692c6;">#categoriaControleList#.</span></li>

                <cfif rsAvalOrentacao.pc_aval_orientacao_beneficioFinanceiro gt 0>
                    <cfset beneficioFinanceiro = #LSCurrencyFormat(rsAvalOrentacao.pc_aval_orientacao_beneficioFinanceiro, 'local')#>
                     <li >Potencial Benefício Financeiro da Implementação da Medida/Orientação p/ Regularização: <span style="color:##0692c6;">#beneficioFinanceiro#.</span></li>
                <cfelse>
                    <li >Potencial Benefício Financeiro da Implementação da Medida/Orientação p/ Regularização: <span style="color:##0692c6;">Não se aplica.</span></li>     
                </cfif>

                <cfif rsAvalOrentacao.pc_aval_orientacao_custoFinanceiro gt 0>
                    <cfset custoEstimado = #LSCurrencyFormat(rsAvalOrentacao.pc_aval_orientacao_custoFinanceiro, 'local')#>
                    <li >Estimativa do Custo Financeiro da Medida/Orientação para Regularização: <span style="color:##0692c6;">#custoEstimado#.</span></li>
                <cfelse>
                    <li >Estimativa do Custo Financeiro da Medida/Orientação para Regularização: <span style="color:##0692c6;">Não se aplica.</span></li>
                </cfif>
            </cfif>
        </cfoutput>


    </cffunction>

    <cffunction name="infoProcesso"   access="remote"  hint="">
        <cfargument name="pc_processo_id" type="string" required="true" /> 

        <cfquery name="rsInfoProcesso" datasource="#application.dsn_processos#">
            SELECT      pc_processos.*
                        ,pc_num_orgao_avaliado as mcuOrgAvaliado
                        ,pc_orgaos2.pc_org_sigla as siglaOrgAvaliado
                        ,pc_num_orgao_origem as mcuOrgOrigem
                        ,pc_orgaos3.pc_org_sigla as siglaOrgOrigem
                        ,pc_avaliacao_tipos.*
                        ,pc_classificacoes.*
                        ,CONCAT(
                        'Macroprocesso: ',pc_avaliacao_tipos.pc_aval_tipo_macroprocessos,
                        ' -> N1: ', pc_avaliacao_tipos.pc_aval_tipo_processoN1,
                        ' -> N2: ', pc_avaliacao_tipos.pc_aval_tipo_processoN2,
                        ' -> N3: ', pc_avaliacao_tipos.pc_aval_tipo_processoN3, '.'
                        ) as tipoProcesso
            FROM        pc_processos 
                        INNER JOIN pc_orgaos as pc_orgaos2 on pc_orgaos2.pc_org_mcu = pc_num_orgao_avaliado
                        INNER JOIN pc_orgaos as pc_orgaos3 on pc_orgaos3.pc_org_mcu = pc_num_orgao_origem
                        INNER JOIN pc_avaliacao_tipos ON pc_processos.pc_num_avaliacao_tipo = pc_avaliacao_tipos.pc_aval_tipo_id
                        INNER JOIN pc_classificacoes ON pc_processos.pc_num_classificacao = pc_classificacoes.pc_class_id
                        LEFT JOIN pc_status on pc_status.pc_status_id = pc_processos.pc_num_status
            WHERE  pc_processo_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.pc_processo_id#"> 
           											
        </cfquery>	

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

            p {
                font-size: 1em!important;
                font-weight: 400 !important;
            }
        
        </style>


        <cfset aux_sei = Trim('#rsInfoProcesso.pc_num_sei#')>
        <cfset aux_sei = Left(aux_sei,"5") & "." & Mid(aux_sei,"6","6") & "/" &  Mid(aux_sei,"12","4")& "-" & Right(aux_sei,"2")>
        <cfset ano = RIGHT(#arguments.pc_processo_id#,4)>
        <section class="content" >
            <div id="processosCadastrados" class="container-fluid" >
                <div class="row">
                    <div id="cartao" style="width:100%;" >
                        <!-- small card -->
                        <cfoutput>
                            <div class="small-box " style=" font-weight: bold;color:##696969!important;">
                               
                                <div class="card-header" style="height:auto">
                                    <fieldset style="padding:0px!important;min-height: 90px;">
                                        <legend style="margin-left:20px">Informações Principais:</legend>

                                        <p style="font-size: 1.5em!important;margin-left:20px;">Processo SNCI n°: <strong id="numSNCI" style="color:##0692c6;margin-right:30px">#rsInfoProcesso.pc_processo_id#
                                            
                                            </strong> Órgão Avaliado: <strong style="color:##0692c6">#rsInfoProcesso.siglaOrgAvaliado#</strong></p>
                                            
                                        <p style="margin-left:20px;">Origem: <strong style="color:##0692c6;margin-right:30px">#rsInfoProcesso.siglaOrgOrigem#</strong>
                                        
                                        <cfif #rsInfoProcesso.pc_modalidade# eq 'A' OR  #rsInfoProcesso.pc_modalidade# eq 'E'>
                                            <span >Processo SEI n°: </span> <strong  id="numSEI" style="color:##0692c6">#aux_sei#</strong> <span style="margin-left:20px">Relatório n°:</span> <strong  style="color:##0692c6">#rsInfoProcesso.pc_num_rel_sei#</strong>
                                        </cfif></p>
                                         
                                        <p style="margin-left:20px;">Data de Início da Avaliação: <strong style="color:##0692c6;margin-right:30px">#DateFormat(rsInfoProcesso.pc_data_inicioAvaliacao, "dd/mm/yyyy")#</strong>
                                             Data de Conclusão da Avaliação: <strong style="color:##0692c6">#DateFormat(rsInfoProcesso.pc_data_fimAvaliacao, "dd/mm/yyyy")#</strong></p>   
                                       
                                        <cfif rsInfoProcesso.pc_num_avaliacao_tipo neq 445 and rsInfoProcesso.pc_num_avaliacao_tipo neq 2>
                                            <cfif rsInfoProcesso.pc_aval_tipo_descricao neq ''>
                                                <p style="margin-left:20px;">Tipo de Avaliação: <span style="color:##0692c6">#rsInfoProcesso.pc_aval_tipo_descricao#</span></p>
                                            <cfelse>
                                                <p style="margin-left:20px;">Tipo de Avaliação: <span style="color:##0692c6" >#rsInfoProcesso.tipoProcesso#</span></p>
                                            </cfif>
                                        <cfelse>
                                            <p style="margin-left:20px;">Tipo de Avaliação: <span style="color:##0692c6">#rsInfoProcesso.pc_aval_tipo_nao_aplica_descricao#</span></p>
                                        </cfif>
                                        
                                        
                                        <p style="margin-left:20px;">
                                            Classificação: <span style="color:##0692c6;margin-right:50px">#rsInfoProcesso.pc_class_descricao#</span>
                                            <cfif #application.rsUsuarioParametros.pc_org_controle_interno# eq 'S' >	
                                                Modalidade: 
                                                <cfif #rsInfoProcesso.pc_modalidade# eq 'N'>
                                                    <span style="color:##0692c6">Normal</span>
                                                </cfif>
                                                <cfif #rsInfoProcesso.pc_modalidade# eq 'A'>
                                                    <span style="color:##0692c6">ACOMPANHAMENTO</span>
                                                </cfif>
                                                <cfif #rsInfoProcesso.pc_modalidade# eq 'E'>
                                                    <span style="color:##0692c6">ENTREGA DE RELATÓRIO</span>
                                                </cfif>
                                            </cfif>
                                        </p>
                                    </fieldset>
                                    
                                    <cfif #ano# gte 2024>
                                        <cfquery datasource="#application.dsn_processos#" name="rsObjetivosEstrategicos">
                                            SELECT pc_objEstrategico_descricao FROM pc_processos_objEstrategicos
                                            INNER JOIN pc_objetivo_estrategico on pc_objetivo_estrategico.pc_objEstrategico_id = pc_processos_objEstrategicos.pc_objEstrategico_id
                                            WHERE pc_processos_objEstrategicos.pc_processo_id = '#rsInfoProcesso.pc_processo_id#'
                                        </cfquery>
                                        <cfset objetivosEstrategicosList=ValueList(rsObjetivosEstrategicos.pc_objEstrategico_descricao,", ")>

                                        <cfquery datasource="#application.dsn_processos#" name="rsRiscosEstrategicos">
                                            SELECT pc_riscoEstrategico_descricao FROM pc_processos_riscosEstrategicos
                                            INNER JOIN pc_risco_estrategico on pc_risco_estrategico.pc_riscoEstrategico_id = pc_processos_riscosEstrategicos.pc_riscoEstrategico_id
                                            WHERE pc_processos_riscosEstrategicos.pc_processo_id = '#rsInfoProcesso.pc_processo_id#'
                                        </cfquery>
                                        <cfset riscosEstrategicosList=ValueList(rsRiscosEstrategicos.pc_riscoEstrategico_descricao,", ")>

                                        <cfquery datasource="#application.dsn_processos#" name="rsIndicadoresEstrategicos">
                                            SELECT pc_indEstrategico_descricao FROM pc_processos_indEstrategicos
                                            INNER JOIN pc_indicador_estrategico on pc_indicador_estrategico.pc_indEstrategico_id = pc_processos_indEstrategicos.pc_indEstrategico_id
                                            WHERE pc_processos_indEstrategicos.pc_processo_id = '#rsInfoProcesso.pc_processo_id#'
                                        </cfquery>
                                        <cfset indicadoresEstrategicosList=ValueList(rsIndicadoresEstrategicos.pc_indEstrategico_descricao,", ")>

                                        <cfif rsObjetivosEstrategicos.recordcount neq 0 or rsRiscosEstrategicos.recordcount neq 0 or rsIndicadoresEstrategicos.recordcount neq 0>
                                            <fieldset style="padding:0px!important;min-height: 90px;">
                                                <legend style="margin-left:20px">Informações Estratégicas:</legend>
                                                <p style="font-size: 1em;margin-left:20px;">Objetivo(s) Estratégico(s): <span style="color:##0692c6;margin-right:50px">#objetivosEstrategicosList#.</span></p>
                                                <p style="font-size: 1em;margin-left:20px;">Risco(s) Estratégico(s): <span style="color:##0692c6;margin-right:50px">#riscosEstrategicosList#.</span></p>
                                                <p style="font-size: 1em;margin-left:20px;">Indicador(es) Estratégico(s): <span style="color:##0692c6;margin-right:50px">#indicadoresEstrategicosList#.</span></p>	
                                            </fieldset>
                                        </cfif>

                                    </cfif>

                                    <cfquery datasource="#application.dsn_processos#" name="rsCoordenadorRegional">
                                        SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios
                                        INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
                                        WHERE pc_usu_matricula = '#rsInfoProcesso.pc_usu_matricula_coordenador#'
                                    </cfquery>
                                    <cfquery datasource="#application.dsn_processos#" name="rsCoordenadorNacional">
                                        SELECT pc_usu_matricula, pc_usu_nome, pc_org_se_sigla FROM pc_usuarios
                                        INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
                                        WHERE pc_usu_matricula = '#rsInfoProcesso.pc_usu_matricula_coordenador_nacional#'
                                    </cfquery>

                                    <cfquery datasource="#application.dsn_processos#" name="rsAvaliadores">
                                        SELECT CONCAT(pc_usu_nome, ' (', pc_org_se_sigla, ')') AS avaliadores FROM pc_avaliadores
                                        INNER JOIN pc_usuarios on pc_usu_matricula = pc_avaliador_matricula
                                        INNER JOIN pc_orgaos on pc_org_mcu = pc_usu_lotacao
                                        WHERE pc_avaliador_id_processo = '#rsInfoProcesso.pc_processo_id#'
                                    </cfquery>
                                    <cfset avaliadoresList = ValueList(rsAvaliadores.avaliadores,";<br>")>
                                    
                                    <fieldset style="padding:0px!important;min-height: 90px;">
                                        <legend style="margin-left:20px">Equipe:</legend>				
                                        <p style="font-size: 1em;margin-left:20px;">
                                            <cfif rsCoordenadorRegional.recordcount neq 0>
                                                Coordenador Regional: <span style="color:##0692c6;margin-right:50px">#rsCoordenadorRegional.pc_usu_nome# (#rsCoordenadorRegional.pc_org_se_sigla#)</span>
                                            </cfif>
                                            <cfif rsCoordenadorNacional.recordcount neq 0>	
                                                Coordenador Nacional: <span style="color:##0692c6;margin-right:50px">#rsCoordenadorNacional.pc_usu_nome# (#rsCoordenadorNacional.pc_org_se_sigla#)</span>
                                            </cfif>
                                        </p>

                                        <cfif rsAvaliadores.recordcount neq 0>
                                            <p style="font-size: 1em;margin-left:20px;">
                                                Avaliadores:<br> 
                                                <span style="color:##0692c6;margin-right:50px">#avaliadoresList#.</span><br>
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



    </cffunction>

    <cffunction name="infoItem"   access="remote" hint="">
        <cfargument name="pc_aval_id" type="numeric" required="true" />
        <cfargument name="pc_processo_id" type="string" required="true" />

        <cfquery name="rsInfoItem" datasource="#application.dsn_processos#">
            SELECT      pc_avaliacoes.*  FROM pc_avaliacoes WHERE  pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#"> 										
        </cfquery>	

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
            p {
                font-size: 1em!important;
                font-weight: 400 !important;
            }

            
        
        </style>

        <cfset classifRisco = "">
        <cfif #rsInfoItem.pc_aval_classificacao# eq 'L'>
            <cfset classifRisco = "Leve">
        </cfif>	
        <cfif #rsInfoItem.pc_aval_classificacao# eq 'M'>
            <cfset classifRisco = "Mediana">
        </cfif>	
        <cfif #rsInfoItem.pc_aval_classificacao# eq 'G'>
            <cfset classifRisco = "Grave">
        </cfif>	
        <section class="content" >
            <div id="processosCadastrados" class="container-fluid" >
                <div class="row">
                    <div id="cartao" style="width:100%;" >
                        <!-- small card -->
                        <cfoutput>
                            <div class="small-box " style=" font-weight: bold;color:##696969!important;">
                                
                                <div class="card-header" style="height:auto;font-weight: 400 !important;">
                                    <cfset ano = RIGHT(#arguments.pc_processo_id#,4)>
                                    <cfif #ano# lte 2023 or rsInfoItem.pc_aval_sintese eq ''>
                                        <p style="">Item: <span style="color:##0692c6;">#rsInfoItem.pc_aval_numeracao# - #rsInfoItem.pc_aval_descricao#</span></p>
                                        <p style="">Classificação: <span style="color:##0692c6;">#classifRisco#</span></p>
                                        
                                        <cfif #rsInfoItem.pc_aval_vaFalta# gt 0 or  #rsInfoItem.pc_aval_vaSobra# gt 0 or  #rsInfoItem.pc_aval_vaRisco# gt 0 >
                                            <p style="">Valor Envolvido: 
                                                <cfif #rsInfoItem.pc_aval_vaFalta# gt 0>
                                                    <cfset valorApurado = #LSCurrencyFormat( rsInfoItem.pc_aval_vaFalta, 'local')#>
                                                    <span style="color:##0692c6;">Falta =  #valorApurado#; </span>
                                                </cfif>
                                                <cfif #rsInfoItem.pc_aval_vaSobra# gt 0>
                                                    <cfset valorApurado = #LSCurrencyFormat( rsInfoItem.pc_aval_vaSobra, 'local')#>
                                                    <span style="color:##0692c6;">Sobra =  #valorApurado#; </span>
                                                </cfif>
                                                <cfif #rsInfoItem.pc_aval_vaRisco# gt 0>
                                                    <cfset valorApurado = #LSCurrencyFormat( rsInfoItem.pc_aval_vaRisco, 'local')#>
                                                    <span style="color:##0692c6;">Risco =  #valorApurado#; </span>
                                                </cfif>
                                            </p>
                                        <cfelse>
                                            <p style="">Valor Envolvido: <span style="color:##0692c6;">Não quantificado</span></p>
                                        </cfif>
                                    <cfelse>
                                        <div class="card card-primary card-tabs"  style="widht:100%">
                                            <div class="card-header p-0 pt-1" style="background-color:##0e406a;">
                                                <ul class="nav nav-tabs" id="custom-tabs-infoItem" role="tablist" style="font-size:14px;font-weight: 400 !important;">
                                                    <li class="nav-item " style="">
                                                        <a  class="nav-link  active" id="custom-tabs-infoItem-titulo-tab"  data-toggle="pill" href="##custom-tabs-infoItem-titulo" role="tab" aria-controls="custom-tabs-infoItem-titulo" aria-selected="true">Título da Situação Encontrada</a>
                                                    </li>

                                                    <li class="nav-item" style="">
                                                        <a  class="nav-link " id="custom-tabs-infoItem-InfItem-sintese-tab"  data-toggle="pill" href="##custom-tabs-infoItem-sintese" role="tab" aria-controls="custom-tabs-infoItem-sintese" aria-selected="true">Síntese</a>
                                                    </li>

                                                    <li class="nav-item" style="">
                                                        <a  class="nav-link " id="custom-tabs-infoItem-InfItem-teste-tab"  data-toggle="pill" href="##custom-tabs-infoItem-teste" role="tab" aria-controls="custom-tabs-infoItem-teste" aria-selected="true">Teste (Pergunta do plano)</a>
                                                    </li>

                                                    <li class="nav-item" style="">
                                                        <a  class="nav-link " id="custom-tabs-infoItem-InfItem-controleTestado-tab"  data-toggle="pill" href="##custom-tabs-infoItem-controleTestado" role="tab" aria-controls="custom-tabs-infoItem-controleTestado" aria-selected="true">Controle Testado</a>
                                                    </li>

                                                    <li class="nav-item" style="">
                                                        <a  class="nav-link " id="custom-tabs-infoItem-InfItem-riscoClassif-tab"  data-toggle="pill" href="##custom-tabs-infoItem-riscoClassif" role="tab" aria-controls="custom-tabs-infoItem-riscoClassif" aria-selected="true">COSO / Classificação / Risco</a>
                                                    </li>

                                                    <li class="nav-item" style="">
                                                        <a  class="nav-link " id="custom-tabs-infoItem-InfItem-valorEstimado-tab"  data-toggle="pill" href="##custom-tabs-infoItem-valorEstimado" role="tab" aria-controls="custom-tabs-infoItem-valorEstimado" aria-selected="true">Potencial Valor Estimado</a>
                                                    </li>	


                                                </ul>
                                            </div>
                                            <!-- @audit item-->
                                            <div class="card-body">
                                                <div class="tab-content" id="custom-tabs-infoItem-tabContent" >
                                                    <div disable class="borderTexto tab-pane fade  active show" id="custom-tabs-infoItem-titulo"  role="tabpanel" aria-labelledby="custom-tabs-infoItem-titulo-tab" style="">	
                                                        
                                                        <span class="font-weight-light" style="color:##0083ca!important;font-size: 1em;margin-left:10px"><cfoutput>N° ITEM: #rsInfoItem.pc_aval_numeracao# </cfoutput></span><pre class="font-weight-light" style="color:##0083ca!important;font-size: 1em;font-style: italic"><cfoutput>#rsInfoItem.pc_aval_descricao#</cfoutput></pre>
                                                    </div>
                                                    <div disable class="borderTexto tab-pane fade" id="custom-tabs-infoItem-sintese" role="tabpanel" aria-labelledby="custom-tabs-infoItem-sintese-tab" style="max-height: 200px; overflow-y: auto;">
                                                        <pre class="font-weight-light" style="color:##0083ca!important;font-size: 1em;font-style: italic"><cfoutput>#rsInfoItem.pc_aval_sintese#</cfoutput></pre>
                                                    </div>
                                                    <div disable class="borderTexto tab-pane fade" id="custom-tabs-infoItem-teste"  role="tabpanel" aria-labelledby="custom-tabs-infoItem-teste-tab" style="max-height: 200px; overflow-y: auto;">	
                                                        <pre class="font-weight-light" style="color:##0083ca!important;font-size: 1em;font-style: italic"><cfoutput>#rsInfoItem.pc_aval_teste#</cfoutput></pre>
                                                    </div>
                                                    <div disable class="tab-pane fade" id="custom-tabs-infoItem-controleTestado"  role="tabpanel" aria-labelledby="custom-tabs-infoItem-controleTestado-tab" >	
                                                        <cfquery name="rsAvaliacaoTiposControles" datasource="#application.dsn_processos#">
                                                            SELECT pc_aval_tipoControle_descricao FROM pc_avaliacao_tiposControles 
                                                            INNER JOIN pc_avaliacao_tipoControle on pc_avaliacao_tipoControle.pc_aval_tipoControle_id = pc_avaliacao_tiposControles.pc_aval_tipoControle_id
                                                            WHERE pc_avaliacao_tiposControles.pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#"> 
                                                        </cfquery>
                                                        <cfset tiposControlesList = ValueList(rsAvaliacaoTiposControles.pc_aval_tipoControle_descricao, ', ')>
                                                        
                                                        <cfquery name="rsAvaliacaoCategoriasControles" datasource="#application.dsn_processos#">
                                                            SELECT pc_aval_categoriaControle_descricao FROM pc_avaliacao_categoriasControles	
                                                            INNER JOIN pc_avaliacao_categoriaControle on pc_avaliacao_categoriaControle.pc_aval_categoriaControle_id = pc_avaliacao_categoriasControles.pc_aval_categoriaControle_id
                                                            WHERE pc_avaliacao_categoriasControles.pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
                                                        </cfquery>
                                                        <cfset categoriasControlesList = ValueList(rsAvaliacaoCategoriasControles.pc_aval_categoriaControle_descricao, ', ')>

                                                        <fieldset style="padding:0px!important;min-height: 90px;">
                                                            <legend style="margin-left:20px">Controle Testado:</legend>
                                                            <pre  class="font-weight-light" class="font-weight-light" style="font-size: 1em;color:##0083ca!important;margin-left:10px;font-style: italic"><cfoutput>#rsInfoItem.pc_aval_controleTestado#</cfoutput></pre>
                                                        </fieldset>
                                                        <fieldset style="padding:0px!important;min-height: 90px;">
                                                            <legend style="margin-left:20px">Tipo / Categoria:</legend>
                                                            <p style="margin-left:20px;">Tipo(s) de Controle: <span style="color:##0692c6;">#tiposControlesList#.</span></p>
                                                            <p style="margin-left:20px;">Categoria(s) do Controle Testado: <span style="color:##0692c6;">#categoriasControlesList#.</span></p>
                                                        </fieldset>
                                                    </div>
                                                    <div disable class="tab-pane fade" id="custom-tabs-infoItem-riscoClassif"  role="tabpanel" aria-labelledby="custom-tabs-infoItem-riscoClassif-tab" >	
                                                        <cfquery name="rsAvaliacaoRiscos" datasource="#application.dsn_processos#">
                                                            SELECT pc_aval_risco_descricao FROM pc_avaliacao_riscos
                                                            INNER JOIN pc_avaliacao_risco on pc_avaliacao_risco.pc_aval_risco_id = pc_avaliacao_riscos.pc_aval_risco_id
                                                            WHERE pc_avaliacao_riscos.pc_aval_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pc_aval_id#">
                                                        </cfquery>
                                                        <cfset riscosList = ValueList(rsAvaliacaoRiscos.pc_aval_risco_descricao, ', ')>
                                                        
                                                        

                                                        <cfquery name="rsAvaliacaoCoso" datasource="#application.dsn_processos#">	
                                                            SELECT pc_aval_cosoComponente, pc_aval_cosoPrincipio FROM pc_avaliacao_coso
                                                            <cfif rsInfoItem.pc_aval_coso_id neq ''>
                                                                WHERE pc_aval_coso_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#rsInfoItem.pc_aval_coso_id#">
                                                            <cfelse>
                                                                WHERE pc_aval_coso_id = 0
                                                            </cfif>

                                                        </cfquery>		
                                                        <fieldset style="padding:0px!important;min-height: 90px;">
                                                            <legend style="margin-left:20px">COSO 2003:</legend>
                                                            <p style="margin-left:20px">Componente: <span style="color:##0692c6;">#rsAvaliacaoCoso.pc_aval_cosoComponente#</span></p>
                                                            <p style="margin-left:20px">Princípio: <span style="color:##0692c6;">#rsAvaliacaoCoso.pc_aval_cosoPrincipio#</span></p>
                                                        </fieldset>
                                                        <fieldset style="padding:0px!important;min-height: 90px;">
                                                            <legend style="margin-left:20px">Classificação / Risco:</legend>
                                                            <p style="margin-left:20px">Classificação: <span style="color:##0692c6;">#classifRisco#.</span></p>
                                                            <p style="margin-left:20px">Risco(s) Identificado: <span style="color:##0692c6;">#riscosList#.</span></p>
                                                        </fieldset>
                                                        
                                                    </div>
                                                    <div disable class="tab-pane fade" id="custom-tabs-infoItem-valorEstimado"  role="tabpanel" aria-labelledby="custom-tabs-infoItem-valorEstimado-tab" >	
                                                        <cfif rsInfoItem.pc_aval_valorEstimadoRecuperar gt 0>
                                                            <li >A Recuperar: <span style="color:##0692c6;">#LSCurrencyFormat(rsInfoItem.pc_aval_valorEstimadoRecuperar, 'local')#.</span></li>
                                                        <cfelse>
                                                            <li >A Recuperar: <span style="color:##0692c6;">Não se aplica.</span></li>
                                                        </cfif>
                                                        <cfif rsInfoItem.pc_aval_valorEstimadoRisco gt 0>
                                                            <li >Em Risco ou Valor Envolvido: <span style="color:##0692c6;">#LSCurrencyFormat(rsInfoItem.pc_aval_valorEstimadoRisco, 'local')#.</span></li>
                                                        <cfelse>
                                                            <li >Em Risco ou Valor Envolvido: <span style="color:##0692c6;">Não se aplica.</span></li>
                                                        </cfif>
                                                        <cfif rsInfoItem.pc_aval_valorEstimadoNaoPlanejado gt 0>
                                                            <li >Não Planejado/Extrapolado/Sobra: <span style="color:##0692c6;">#LSCurrencyFormat(rsInfoItem.pc_aval_valorEstimadoNaoPlanejado, 'local')#.</span></li>
                                                        <cfelse>
                                                            <li >Não Planejado/Extrapolado/Sobra: <span style="color:##0692c6;">Não se aplica.</span></li>
                                                        </cfif>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </cfif>
                                    

                                </div>
                            </div>
                        </cfoutput>
                    </div>
                </div>
            </div>
            
        </section>

    </cffunction>

</cfcomponent>