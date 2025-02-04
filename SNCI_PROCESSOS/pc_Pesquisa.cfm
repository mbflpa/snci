<cfprocessingdirective pageencoding = "utf-8">
<!DOCTYPE html>
<html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
  		<meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>

            /* Escopo dos estilos para o modal */
            #avaliacaoModal .modal-header {
                padding: 0.5rem!important;
            }

            #avaliacaoModal .modal-title {
                color: #fff !important;
            }

            #avaliacaoModal .modal-body {
                background-color: #ffffff !important;
                overflow-y: auto !important; /* Permite rolagem vertical */
                max-height: 100vh!important; /* Limita a altura do modal */
                padding-top: 0!important;
            }

            #avaliacaoModal .modal-dialog {
                max-width: 70% !important;
                width: 100% !important;
                margin: 10px auto !important;
                padding: 15px; /* Margem interna extra */
            }

            #avaliacaoModal .modal-content {
                border-radius: 8px !important;
                max-height: 95vh !important;
                overflow-y: auto !important;
                overflow-x: hidden !important;
            }

            #avaliacaoModal .form-group {
                margin-bottom: 0 !important;
                padding-top: 2px;
                padding-bottom: 2px;
                padding-left: 10px;
                padding-right: 10px;
                display: flex !important;
                align-items: center !important;
            }

            #avaliacaoModal .form-group label {
                font-weight: bold !important;
            }

            #avaliacaoModal .description {
                font-size: 0.7rem !important;
                color: #6c757d !important;
                margin-bottom: 0 !important;
                text-align: justify!important;
            }

            #avaliacaoModal .radio-group {
                display: flex !important;
                justify-content: space-between !important;
                gap: 5px !important;
                text-align: center !important;
                max-width: 50%!important; /* Ajusta a largura do grupo de rádio */
                margin: auto!important; /* Centraliza o grupo */
            }

            #avaliacaoModal .radio-group .form-check {
                display: flex!important;
                flex-direction: column!important; /* Empilha o label acima do input */
                align-items: center!important; /* Centraliza o conteúdo */
                gap: 0.25rem!important; /* Espaçamento entre o label e o input */
            }

            #avaliacaoModal .radio-group .form-check-label {
                font-size: 0.7rem!important; /* Tamanho de texto ajustado */
                text-align: center!important; /* Centraliza o texto do label */
            }

            #avaliacaoModal .radio-group .form-check-input {
                margin: 0!important; /* Remove margens extras */
            }

            #avaliacaoModal .form-check-input {
                position: relative!important;
            }

            #avaliacaoModal .groupPontualidade {
                width: auto !important;  /* Ajusta a largura ao conteúdo */
                display: inline-flex !important; /* Faz com que o contêiner se ajuste ao conteúdo */
                margin-top: 1rem !important; /* Espaçamento superior */
                margin-bottom: 1rem !important; /* Espaçamento inferior */
            }

            #avaliacaoModal .radio-group.align-near {
                justify-content: flex-start !important; /* Alinha à esquerda próximo à pergunta */
                width: auto !important; /* Ajusta a largura do grupo de rádio ao conteúdo */
                margin: 0 !important; /* Remove centralização */
            }

            #avaliacaoModal .radio-group.align-near .form-check {
                align-items: center !important; /* Alinha os itens no centro vertical */
                gap: 0.5rem; /* Ajusta o espaçamento entre as opções */
            }

            #avaliacaoModal .modal-body table {
                text-align: center!important;
                margin-top: 5px!important;
            }

            #avaliacaoModal .modal-body th, #avaliacaoModal .modal-body td {
                padding: 8px!important;
            }

            #avaliacaoModal .modal-body th {
                background-color: #f8f9fa!important;
            }

            #avaliacaoModal .modal-body td {
                background-color: #e9ecef!important;
            }
            
            #avaliacaoModal .form-group:not(.no-zebra):nth-child(odd) {
                background-color: #ffffff !important; 
            }

            #avaliacaoModal .form-group:not(.no-zebra):nth-child(even) {
                background-color: aliceblue !important; 
            }

            .error-message {
                position: absolute!important; 
                color: red!important; 
                font-size: 0.8rem!important; 
                margin-top: -3rem!important; 
                right: 0!important; 
                margin-right: 5rem!important; 
            }
            .error-message-sim-nao{
                position: absolute!important; 
                color: red!important; 
                font-size: 0.8rem!important; 
                margin-top: -3rem!important; 
                right: 0!important; 
                margin-right: 34rem!important; 
            }

            #modalOverlay {
                z-index:1051!important;  /* Valor superior ao do avaliacaoModal */
            }

            #tabelaDadosProcesso th, #tabelaDadosProcesso td,
            #tabelaCriterios th, #tabelaCriterios td {
                padding: 1px 3px!important;  /* Reduzindo ao mínimo */
                line-height: 0.8!important;  /* Reduzindo altura da linha */
                font-size: 0.7rem!important;  /* Mantendo a legibilidade */
                height: 1px!important;  /* Forçando altura mínima */
                white-space: nowrap!important;  /* Evita quebras de linha */
            }
            
            #tabelaDadosProcesso th, #tabelaCriterios th {
                font-weight: normal!important; /* Cabeçalhos normais */
            }

            #tabelaDadosProcesso td, #tabelaCriterios td {
                font-weight: bold!important; /* Células em negrito */
            }


        </style>

    </head>

    <cfquery name="rsSiglaOrgao" datasource="#application.dsn_processos#">
        SELECT
            pc_org_mcu, pc_org_sigla FROM pc_orgaos
        WHERE
            pc_org_mcu= <cfqueryparam value="#application.rsUsuarioParametros.pc_usu_lotacao#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <body >
        <cfoutput>
            <form id="formPesquisa">   
                <div class="container">
                    <!-- Modal -->
                    <div class="modal fade" id="avaliacaoModal" tabindex="-1" role="dialog" aria-labelledby="avaliacaoModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header navbar_correios_backgroundColor">
                                    <h6 class="modal-title" id="avaliacaoModalLabel"><i class="fas fa-clipboard-list"></i> 
                                        Pesquisa de opinião em relação aos trabalhos realizados pela equipe de Controle Interno
                                    </h6>
                                    
                                </div>
                                <div class="modal-body">
                                    
                                    <div class="table-container" style="display: flex; gap: 20px;justify-content: space-between;">
                                        <table id="tabelaCriterios" class="table table-bordered first-table" style="width: 50%;">
                                            <thead>
                                                <tr>
                                                    <th colspan="5" style="font-size:0.7rem">Por favor, avalie os seguintes itens com base nos seguintes critérios, considerando a escala:</th>
                                                </tr>
                                                <tr style="font-size:0.7rem">
                                                    <th>Ótimo</th>
                                                    <th>Bom</th>
                                                    <th>Regular</th>
                                                    <th>Ruim</th>
                                                    <th>Péssimo</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr style="font-size:0.7rem">
                                                    <td>10-9</td>
                                                    <td>8-7</td>
                                                    <td>6-5</td>
                                                    <td>4-3</td>
                                                    <td>1-2</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                        <table id="tabelaDadosProcesso" class="table table-bordered" style="width: 50%;">
                                            <thead>
                                                <tr>
                                                    <th colspan="5" style="font-size:0.7rem">Detalhes do Processo para Pesquisa de Opinião do Órgão <strong>#rsSiglaOrgao.pc_org_sigla# (#rsSiglaOrgao.pc_org_mcu#)</strong></th>
                                                </tr>
                                                <tr style="font-size:0.7rem">
                                                    <th>N° SNCI</th>
                                                    <th>N° SEI</th>
                                                    <th>N° Rel. SEI</th>
                                                    <th>Tipo de Avaliação (Proc. N2)</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr style="font-size:0.7rem">
                                                    <td>#rsDadosProcessoPesquisa.pc_processo_id#</td>
                                                    <cfset sei = left(#rsDadosProcessoPesquisa.pc_num_sei#,5) & '.'& mid(#rsDadosProcessoPesquisa.pc_num_sei#,6,6) &'/'& mid(#rsDadosProcessoPesquisa.pc_num_sei#,12,4) &'-'&right(#rsDadosProcessoPesquisa.pc_num_sei#,2)>
                                                    <td>#sei#</td>
                                                    <td>#rsDadosProcessoPesquisa.pc_num_rel_sei#</td>
                                                    <td>#rsDadosProcessoPesquisa.pc_aval_tipo_processoN2#</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                

                                
                                            <div class="form-group">
                                                <div>
                                                    <label for="comunicacao">1. Comunicação </label>
                                                    <p class="description">Avalia a clareza, frequência e qualidade das interações com a equipe de Controle Interno. Considere se a equipe de Controle Interno foi acessível, transparente e eficaz ao transmitir informações sobre a condução dos trabalho.</p>
                                                </div>
                                                <div class="radio-group">
                                                    <cfloop from="1" to="10" index="i">
                                                    
                                                            <div class="form-check">
                                                                <label class="form-check-label" for="comunicacao_#i#">#i#</label>
                                                                <input class="form-check-input" type="radio" name="pc_pesq_comunicacao" id="comunicacao_#i#" value="#i#" required>
                                                            </div>
                                                    
                                                    </cfloop>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div>
                                                    <label for="interlocucao">2. Interlocução profissional </label>
                                                    <p class="description">Avalia o comportamento da equipe de Controle Interno ao longo do trabalho. Leve em conta o profissionalismo, o respeito e a atitude colaborativa demonstradas durante o processo.</p>
                                                </div>
                                                <div class="radio-group">
                                                    <cfloop from="1" to="10" index="i">
                                                        <div class="form-check">
                                                            <label class="form-check-label" for="interlocucao_#i#">#i#</label>
                                                            <input class="form-check-input" type="radio" name="pc_pesq_interlocucao" id="interlocucao_#i#" value="#i#" required>
                                                        </div>
                                                    </cfloop>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div>
                                                    <label for="reuniao">3. Reunião de encerramento e validação </label>
                                                    <p class="description">Avalia a condução da reunião final da equipe de Controle Interno. Considere se a reunião foi clara, direta e se os tópicos foram abordados de maneira simples e objetiva, facilitando o fechamento do processo.</p>
                                                </div>
                                                <div class="radio-group">
                                                    <cfloop from="1" to="10" index="i">
                                                        <div class="form-check">
                                                            <label class="form-check-label" for="reuniao_#i#">#i#</label>
                                                            <input class="form-check-input" type="radio" name="pc_pesq_reuniao_encerramento" id="reuniao_#i#" value="#i#" required>
                                                        </div>
                                                    </cfloop>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div>
                                                    <label for="relatorio">4. Relatório </label>
                                                    <p class="description">Avalia a qualidade do relatório entregue ao final do trabalho da equipe de Controle Interno. Considere se o documento foi redigido de forma clara, com informações consistentes e objetivas, facilitando o entendimento das conclusões e recomendações.</p>
                                                </div>
                                                <div class="radio-group moverScroll" >
                                                    <cfloop from="1" to="10" index="i">
                                                        <div class="form-check"  >
                                                            <label class="form-check-label" for="relatorio_#i#">#i#</label>
                                                            <input class="form-check-input" type="radio" name="pc_pesq_relatorio" id="relatorio_#i#" value="#i#" required>
                                                        </div>
                                                    </cfloop>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div>
                                                    <label for="pos_trabalho">5. Pós-trabalho </label>
                                                    <p class="description">Avalia o suporte recebido após a conclusão do trabalho da equipe de Controle Interno. Considere se houve disponibilidade para responder dúvidas, se a comunicação foi eficaz e se o atendimento foi prestativo e ágil no período pós-trabalho.</p>
                                                </div>
                                                <div class="radio-group moverScroll">
                                                    <cfloop from="1" to="10" index="i">
                                                        <div class="form-check">
                                                            <label class="form-check-label" for="pos_trabalho_#i#">#i#</label>
                                                            <input class="form-check-input" type="radio" name="pc_pesq_pos_trabalho" id="pos_trabalho_#i#" value="#i#" required>
                                                        </div>
                                                    </cfloop>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div>
                                                    <label for="importancia">6. Importância da avaliação para o aprimoramento do processo </label>
                                                    <p class="description">Avalia a percepção sobre a contribuição das atividades da equipe de Controle Interno para melhorar o processo avaliado. Considere se o trabalho ajudou a identificar oportunidades de melhoria e contribuiu para o fortalecimento dos controles internos.</p>
                                                </div>
                                                <div class="radio-group moverScroll">
                                                    <cfloop from="1" to="10" index="i">
                                                        <div class="form-check">
                                                            <label class="form-check-label" for="importancia_#i#">#i#</label>
                                                            <input class="form-check-input" type="radio" name="pc_pesq_importancia_processo" id="importancia_#i#" value="#i#" required>
                                                        </div>
                                                    </cfloop>
                                                </div>
                                            </div>


                                            <div class="form-group erro2 groupPontualidade" >
                                                <div>
                                                    <label for="pontualidade" >Pontualidade </label>
                                                    <p class="description" >Avalia se a equipe de Controle Interno cumpriu os prazos estabelecidos para a condução e entrega do trabalho.</p>
                                                </div>
                                                <div class="radio-group align-near moverScroll " >
                                                    <div class="form-check" >
                                                        <label class="form-check-label" for="pontualidade_sim">Sim</label>
                                                        <input class="form-check-input" type="radio" name="pc_pesq_pontualidade" id="pontualidade_sim" value=1 required>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="pontualidade_nao">Não</label>
                                                        <input class="form-check-input" type="radio" name="pc_pesq_pontualidade" id="pontualidade_nao" value=0 required>
                                                    </div>
                                                </div>
                                            </div>


                                            <div class="form-group no-zebra">
                                                <label for="observacao" style="margin-right:5px">Observação:</label>
                                                <textarea class="form-control" id="observacao" name="pc_pesq_observacao" rows="2"></textarea>
                                            </div>
                                            
                                    
                                </div>
                                <div class="modal-footer p-0 card-header_navbar_backgroundColor" style="justify-content: space-between;">
                                    <div class="mx-auto">
                                        <button type="button" id="btnSalvarPesquisa" class="btn btn-primary">Salvar</button>
                                    </div>
                                    <div>
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Não responder agora</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                </div>
            </form>
        </cfoutput>
       
        <script language="JavaScript">
            $(document).ready(function() {
                $('#avaliacaoModal').on('hidden.bs.modal', function () {
                    // Limpa todos os campos de texto, selects e checkboxes
                    $(this).find('input[type="text"], input[type="password"], textarea, select').val('');
                    $(this).find('input[type="checkbox"], input[type="radio"]').prop('checked', false);
                });

                $('#comunicacao').select2();
                $('#interlocucao').select2();
                $('#reuniao').select2();
                $('#relatorio').select2();
                $('#pos_trabalho').select2();
                $('#importancia').select2();
                
                // Adiciona evento de clique para rolar o modal para baixo
                $('.moverScroll').on('click', function() {
                    var modalBody = $(this).closest('.modal').find('.modal-body');
                    modalBody.animate({ scrollTop: modalBody.prop("scrollHeight") }, 2000);
                });

                // Remove mensagem de erro ao selecionar uma opção
                $('input[type="radio"]').on('change', function() {
                    var $formGroup = $(this).closest('.form-group');
                    $formGroup.find('.error-message, .error-message-sim-nao').remove();
                });
                
            });
            $('#btnSalvarPesquisa').on('click', function(e) {
                e.preventDefault();
                var isValid = true;

                // Remove mensagens de erro anteriores
                $('.error-message').remove();
                $('.error-message-sim-nao').remove();

                // Verifica se todos os campos de rádio obrigatórios estão preenchidos
                $('input[type="radio"][required]').each(function() {
                    var name = $(this).attr('name');
                    if ($('input[name="' + name + '"]:checked').length === 0) {
                        isValid = false;
                        
                        var $formGroup = $(this).closest('.form-group');
                        if ($formGroup.find('.error-message, .error-message-sim-nao').length === 0) {
                            var errorMessage;
                            if ($formGroup.hasClass('erro2')) {
                                errorMessage = $('<div class="error-message-sim-nao">Por favor, selecione uma opção abaixo.</div>');
                            } else {
                                errorMessage = $('<div class="error-message">Por favor, selecione uma opção abaixo.</div>');
                            }
                            $formGroup.find('.radio-group').before(errorMessage);
                        }
                    }
                });

                if (isValid) {
                    <cfoutput>
                        let processoPesquisa = '#rsDadosProcessoPesquisa.pc_processo_id#';
                    </cfoutput>
                     
                     $('#modalOverlay').modal('show');
                   
                    setTimeout(function() {
                        $.ajax({
                            type: 'POST',
                            url: "cfc/pc_cfcPesquisa.cfc",
                            data: {
                                method: "salvarPesquisa",
                                pc_pesq_comunicacao: $('input[name="pc_pesq_comunicacao"]:checked').val(),
                                pc_pesq_interlocucao: $('input[name="pc_pesq_interlocucao"]:checked').val(),
                                pc_pesq_reuniao_encerramento: $('input[name="pc_pesq_reuniao_encerramento"]:checked').val(),
                                pc_pesq_relatorio: $('input[name="pc_pesq_relatorio"]:checked').val(),
                                pc_pesq_pos_trabalho: $('input[name="pc_pesq_pos_trabalho"]:checked').val(),
                                pc_pesq_importancia_processo: $('input[name="pc_pesq_importancia_processo"]:checked').val(),
                                pc_pesq_pontualidade: $('input[name="pc_pesq_pontualidade"]:checked').val(),
                                pc_pesq_observacao: $('#observacao').val(),
                                pc_processo_id: processoPesquisa

                            },
                            async: false
                        })
                        .done(function(result) {
                            $('#avaliacaoModal').modal('hide');
                            toastr.info('Agradecemos a sua colaboração!');
                            toastr.success('Pesquisa enviada com sucesso!');
                        })
                        .fail(function(jqXHR, textStatus, errorThrown) {
                            $('#avaliacaoModal').modal('hide');
                            console.log(jqXHR, textStatus, errorThrown);
                            toastr.error('Erro ao salvar a pesquisa: ' + errorThrown);
                        });
                    }, 1000);
                    $('#modalOverlay').delay(1000).hide(0, function() {
                        $('#modalOverlay').modal('hide');
                    });
                }
            });

        </script>
         
    </body>
</html>