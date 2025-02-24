<cfprocessingdirective pageencoding="utf-8">

<!DOCTYPE html>

<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Notas de Versão</title>
    
    <style>
        .novidadesColor {
            background: #A8E6CF !important; /* Verde pastel */
            color: #000 !important;
            padding: 10px!important;
            position: relative!important;
        }

        .novidadesColor h5::before {
            content: "\f0a1"!important; /* Unicode do ícone de megafone (fa-bullhorn) */
            font-family: "Font Awesome 5 Free"!important; /* Fonte do Font Awesome */
            font-weight: 900!important; /* Necessário para ícones sólidos */
            margin-right: 8px!important;
        }

        .melhoriasColor {
            background:  #BBDEFB !important; /* Azul pastel */
            color: #000!important;
            padding: 10px!important;
            position: relative!important;
        }

        .melhoriasColor h5::before {
            content: "\f0ad"!important; /* Unicode do ícone de chave inglesa (fa-wrench) */
            font-family: "Font Awesome 5 Free"!important;
            font-weight: 900!important;
            margin-right: 8px!important;
        }

        .correcoesColor {
            background:  #FFABAB !important; /* Vermelho pastel */
            color: #000!important;
            padding: 10px!important;
            position: relative!important;
        }

        .correcoesColor h5::before {
            content: "\f00c"!important; /* Unicode do ícone de verificação (fa-check) */
            font-family: "Font Awesome 5 Free"!important;
            font-weight: 900!important;
            margin-right: 8px!important;
        }

        .versaoAtual h4::before {
            content: "\f126"!important; 
            font-family: "Font Awesome 5 Free"!important;
            font-weight: 900!important;
            margin-right: 8px!important;
        }
        .versaoAnterior h4::before {
            content: "\f1da"!important; 
            font-family: "Font Awesome 5 Free"!important;
            font-weight: 900!important;
            margin-right: 8px!important;
           
        }
        .versaoAnterior h4{
            color: gray !important;
        }

        .observacoesColor {
            background: #f9f3e1 !important;
            color: #000!important;
            padding: 10px!important;
            position: relative!important;
        }
        .observacoesColor h5::before {
            content: "\f05a"!important; /* Unicode do ícone de olho (fa-eye) */
            font-family: "Font Awesome 5 Free"!important;
            font-weight: 900!important;
            margin-right: 8px!important;
        }
        .content-wrapper {
            height: auto;
        }
    </style>
</head>
<body>

    <section class="content " style="margin-bottom:20px;position:relative;">
        <section class="content-header">
            <div class="container-fluid">
                <div class="row mb-2" style="position:relative; left:-15px;padding-bottom:0">
                    <div class="col-sm-6">
                        <h4 style="color:#2675fb; margin-bottom: 0">Notas de Versão</h4>
                    </div>
                    <cfif #application.rsUsuarioParametros.pc_usu_perfil# eq 3>
                        <div class="col-sm-6 text-right">
                        
                            <!-- Botão para abrir o modal de cadastro -->
                            <button type="button" class="btn btn-success" data-toggle="modal" data-target="#modalCadastrarNota">
                                <i class="fas fa-plus"></i> Cadastrar Nota
                            </button>
                        </div>
                    </cfif>
                </div>
            </div><!-- /.container-fluid -->
        </section>
        
        <div class="row">
            <div class="col-12" id="accordion">
            
            </div>
        </div>
    </section>

    <!-- Modal para Cadastrar Nota de Versão -->
    <div class="modal fade" id="modalCadastrarNota" tabindex="-1" role="dialog" aria-labelledby="modalCadastrarNotaLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Cadastrar Nota de Versão</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Fechar">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <form id="formCadastrarNota">
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="pc_notasVersao_versao">Versão</label>
                            <input type="text" class="form-control" id="pc_notasVersao_versao" name="pc_notasVersao_versao" placeholder="Exemplo: 2.1.0" required>
                        </div>
                        <div class="form-group">
                            <label for="pc_notasVersao_data_lancamento">Data de Lançamento</label>
                            <input type="date" class="form-control" id="pc_notasVersao_data_lancamento" name="pc_notasVersao_data_lancamento" required>
                        </div>
                        <div class="form-group">
                            <label for="pc_notasVersao_novidades">Novidades</label>
                            <textarea class="form-control" id="pc_notasVersao_novidades" name="pc_notasVersao_novidades" rows="3" placeholder="Descreva as novidades"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="pc_notasVersao_melhorias">Melhorias</label>
                            <textarea class="form-control" id="pc_notasVersao_melhorias" name="pc_notasVersao_melhorias" rows="3" placeholder="Descreva as melhorias"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="pc_notasVersao_correcoes">Correções</label>
                            <textarea class="form-control" id="pc_notasVersao_correcoes" name="pc_notasVersao_correcoes" rows="3" placeholder="Descreva as correções"></textarea>
                        </div>
                        <div class="form-group">
                            <label for="pc_notasVersao_observacoes">Outras Alterações</label>
                            <textarea class="form-control" id="pc_notasVersao_observacoes" name="pc_notasVersao_observacoes" rows="3" placeholder="Descreva outras alterações"></textarea>
                        </div>
                        <div id="mensagemResposta" class="mt-2"></div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
                        <button type="submit" class="btn btn-primary">Cadastrar Nota</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal para Editar Nota de Versão -->
    <div class="modal fade" id="modalEditarNota" tabindex="-1" role="dialog" aria-labelledby="modalEditarNotaLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
            <form id="formEditarNota">
                <div class="modal-header">
                <h5 class="modal-title" id="modalEditarNotaLabel">Editar Nota de Versão</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Fechar">
                    <span aria-hidden="true">&times;</span>
                </button>
                </div>
                
                <div class="modal-body">
                <input type="hidden" id="editarNotaId" name="id">

                <div class="form-group">
                    <label for="editarVersao">Versão</label>
                    <input type="text" class="form-control" id="editarVersao" name="versao" required>
                </div>
                <div class="form-group">
                    <label for="editarDataLancamento">Data de Lançamento</label>
                    <input type="date" class="form-control" id="editarDataLancamento" name="dataLancamento" required>
                </div>
                <div class="form-group">
                    <label for="editarNovidades">Novidades</label>
                    <textarea class="form-control" id="editarNovidades" name="novidades" rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label for="editarMelhorias">Melhorias</label>
                    <textarea class="form-control" id="editarMelhorias" name="melhorias" rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label for="editarCorrecoes">Correções</label>
                    <textarea class="form-control" id="editarCorrecoes" name="correcoes" rows="3"></textarea>
                </div>
                <div class="form-group">
                    <label for="editarOutrasAlteracoes">Outras Alterações</label>
                    <textarea class="form-control" id="editarOutrasAlteracoes" name="outrasAlteracoes" rows="3"></textarea>
                </div>
                </div>
                
                <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
                <button type="submit" class="btn btn-primary">Salvar Alterações</button>
                </div>
            </form>
            </div>
        </div>
    </div>

    <script>
       
    $(document).ready(function(){

        // Função para abrir o modal de edição e preencher os campos
        $(document).on('click', '.editarNota', function(){
            var notaId = $(this).data('id');
            // Recuperar os dados da nota via AJAX
            $.ajax({
                url: 'cfc/pc_cfcNotasDeVersao.cfc?method=listarNotaPorId',
                method: 'POST',
                data: { id: notaId },
                dataType: 'json',
                success: function(response){
                    
                        // Preencher os campos do modal com os dados da nota
                        $('#editarNotaId').val(response.dados.PC_NOTASVERSAO_ID);
                        $('#editarVersao').val(response.dados.PC_NOTASVERSAO_VERSAO);
                        $('#editarDataLancamento').val(response.dados.PC_NOTASVERSAO_DATA_LANCAMENTO);
                        $('#editarNovidades').val(response.dados.PC_NOTASVERSAO_NOVIDADES);
                        $('#editarMelhorias').val(response.dados.PC_NOTASVERSAO_MELHORIAS);
                        $('#editarCorrecoes').val(response.dados.PC_NOTASVERSAO_CORRECOES);
                        $('#editarOutrasAlteracoes').val(response.dados.PC_NOTASVERSAO_OBSERVACOES);
                        
                        // Abrir o modal
                        $('#modalEditarNota').modal('show');
                   
                },
                error: function(xhr, ajaxOptions, thrownError) {
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
					}
            });
        });
        // Função para cadastrar uma nova nota
        $('#formEditarNota').on('submit', function(event){
            event.preventDefault(); // Evita o envio padrão do formulário
            // Coleta os dados do formulário de edição
            var dadosFormularioEditar = {
                id: $('#editarNotaId').val(),
                versao: $('#editarVersao').val().trim(),
                dataLancamento: $('#editarDataLancamento').val(),
                novidades: $('#editarNovidades').val().trim(),
                melhorias: $('#editarMelhorias').val().trim(),
                correcoes: $('#editarCorrecoes').val().trim(),
                outrasAlteracoes: $('#editarOutrasAlteracoes').val().trim()
            };

            // Validação adicional (opcional)
            var versaoRegex = /^\d+\.\d+\.\d+$/;
            if(!versaoRegex.test(dadosFormularioEditar.versao)){
                $('#mensagemRespostaEditar').html('<div class="alert alert-danger">Formato da versão inválido. Utilize o padrão X.Y.Z (ex.: 2.1.0).</div>');
                return;
            }

            // Envia os dados via Ajax para o CFC para editar
            $.ajax({
                url: 'cfc/pc_cfcNotasDeVersao.cfc?method=atualizarNota',
                method: 'POST',
                data: dadosFormularioEditar,
                success: function(response){
                   
                    toastr.success('Nota de versão atualizada com sucesso!');
                    // Atualiza a lista de notas de versão sem recarregar a página
                    carregarNotas();
                    // Fecha o modal de edição
                    $('#modalEditarNota').modal('hide');
                    // Remove manualmente o backdrop caso necessário
                    $('.modal-backdrop').remove();
                    
                },
                error: function(xhr, ajaxOptions, thrownError) {
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
					}
            });
        });
        // Função para cadastrar uma nova nota
        $('#formCadastrarNota').on('submit', function(event){
            event.preventDefault(); // Evita o envio padrão do formulário
    
            // Coleta os dados do formulário
            var dadosFormulario = {
                versao: $('#pc_notasVersao_versao').val().trim(), // Remover espaços
                dataLancamento: $('#pc_notasVersao_data_lancamento').val(),
                novidades: $('#pc_notasVersao_novidades').val().trim(),
                melhorias: $('#pc_notasVersao_melhorias').val().trim(),
                correcoes: $('#pc_notasVersao_correcoes').val().trim(),
                outrasAlteracoes: $('#pc_notasVersao_observacoes').val().trim()
            };
    
            // // Validação adicional (opcional)
            var versaoRegex = /^\d+\.\d+\.\d+$/;
            if(!versaoRegex.test(dadosFormulario.versao)){
                $('#mensagemResposta').html('<div class="alert alert-danger">Formato da versão inválido. Utilize o padrão X.Y.Z (ex.: 2.1.0).</div>');
                return;
            }
    
            // Envia os dados via Ajax para o CFC
            $.ajax({
                url: 'cfc/pc_cfcNotasDeVersao.cfc?method=cadastrarNota',
                method: 'POST',
                data: dadosFormulario,
                success: function(response){
                    toastr.success('Distribuição realizada com sucesso!');
                    $('#formCadastrarNota')[0].reset(); // Reseta o formulário
                    // Atualiza a lista de notas de versão sem recarregar a página
                    carregarNotas();
                    // Fecha o modal imediatamente
                    $('#modalCadastrarNota').modal('hide');
                    // Remove manualmente o backdrop caso necessário
                    $('.modal-backdrop').remove();
                },
                error: function(xhr, ajaxOptions, thrownError) {
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
					}
            });
        });

        // Função para excluir uma nota de versão
        $(document).on('click', '.excluirNota', function(){
            var notaId = $(this).data('id');
            swalWithBootstrapButtons.fire({ // sweetalert2
                html: logoSNCIsweetalert2('Deseja realmente excluir a nota de versão?'),
                showCancelButton: true,
                confirmButtonText: 'Sim!',
                cancelButtonText: 'Cancelar!'
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        url: 'cfc/pc_cfcNotasDeVersao.cfc?method=deletarNota',
                        method: 'POST',
                        data: { id: notaId },
                        success: function(response){
                            carregarNotas(); // Função para recarregar as notas
                            toastr.success('Nota de versão excluída com sucesso!');
                        },
                        error: function(xhr, ajaxOptions, thrownError) {				
                            $('#modal-danger').modal('show');
                            $('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:');
                            $('#modal-danger').find('.modal-body').text(thrownError);
                        }
                    });
                } else {
                    // Lidar com o cancelamento: fechar o modal de carregamento, exibir mensagem, etc.
                    $('#modalOverlay').modal('hide');
                    Swal.fire({
                        title: 'Operação Cancelada',
                        html: logoSNCIsweetalert2(''),
                        icon: 'info'
                    });
                }
            });
        });
    
        // Função para carregar as notas de versão
        function carregarNotas(){
            $.ajax({
                url: 'cfc/pc_cfcNotasDeVersao.cfc?method=listarNotas',
                method: 'POST',
                dataType: 'json',
                success: function(response){
                    var accordion = $('#accordion');
                    accordion.empty(); // Limpa o conteúdo existente
    
                    // Verifica se existe um erro na resposta
                    if(response.length == 1 && response[0].error){
                        accordion.append('<div class="alert alert-danger">' + response[0].message + '</div>');
                        return;
                    }
    
                    // Itera sobre cada nota de versão e cria os cards
                    $.each(response, function(index, nota){
                        // Verifica se a propriedade existe
                        if(!nota.PC_NOTASVERSAO_VERSAO){
                            console.error("Propriedade PC_NOTASVERSAO_VERSAO está indefinida para a nota:", nota);
                            return true; // Continua para a próxima iteração
                        }
    
                        var collapseId = "collapse" + sanitizeId(nota.PC_NOTASVERSAO_VERSAO);
    
                     
                        var card = `
                            <div class="card  ${parseInt(index) === 0 ? 'card-primary' : 'card-secondary'} card-outline">
                                <a class="d-block w-100" data-toggle="collapse" href="#${collapseId}" >
                                    <div class="card-header ${parseInt(index) === 0 ? 'versaoAtual' : 'versaoAnterior'}">
                                        <h4 class="card-title w-100">
                                            Versão ${nota.PC_NOTASVERSAO_VERSAO} - ${nota.PC_NOTASVERSAO_DATA_LANCAMENTO}
                                        </h4>
                                    </div>
                                </a>
                                <div id="${collapseId}" class="collapse" data-parent="#accordion">
                                    <div class="card-body">
                                        <div class="card novidadesColor">
                                            <h5>Novidades:</h5>
                                            <ul>
                                                ${formatList(nota.PC_NOTASVERSAO_NOVIDADES)}
                                            </ul>
                                        </div>
                        
                                        <div class="card melhoriasColor">
                                            <h5>Melhorias:</h5>
                                            <ul>
                                                ${formatList(nota.PC_NOTASVERSAO_MELHORIAS)}
                                            </ul>
                                        </div>
                        
                                        <div class="card correcoesColor">
                                            <h5>Correções:</h5>
                                            <ul>
                                                ${formatList(nota.PC_NOTASVERSAO_CORRECOES)}
                                            </ul>
                                        </div>
                        
                                        ${nota.PC_NOTASVERSAO_OBSERVACOES ? `
                                        <div class="card observacoesColor">
                                            <h5>Observações:</h5>
                                            <ul>
                                                ${formatList(nota.PC_NOTASVERSAO_OBSERVACOES)}
                                            </ul>
                                        </div>
                                        ` : ''}
                                        <cfif application.rsUsuarioParametros.pc_usu_perfil EQ 3>
                                            <div class="acoesNota" style="margin-top: 15px;">
                                                <button class="btn btn-sm btn-primary editarNota" data-id="${nota.PC_NOTASVERSAO_ID}">Editar</button>
                                                <button class="btn btn-sm btn-danger excluirNota" data-id="${nota.PC_NOTASVERSAO_ID}">Excluir</button>
                                            </div>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                        `;
                        accordion.append(card);
                        // Define a altura da classe '.content-wrapper' como 'auto'
                        $(".content-wrapper").css("height", "auto");
                        
                    });
                },
                error: function(xhr, ajaxOptions, thrownError) {
						$('#modal-danger').modal('show')
						$('#modal-danger').find('.modal-title').text('Não foi possível executar sua solicitação.\nInforme o erro abaixo ao administrador do sistema:')
						$('#modal-danger').find('.modal-body').text(thrownError)
					}
            });
        }
        // Função para remover acentos e substituir espaços
        function sanitizeId(str) {
            // Remove acentos
            var strSanitized = str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
            // Remove espaços e pontos
            strSanitized = strSanitized.replace(/\s+/g, '').replace(/\./g, '');
            return strSanitized;
        }
                // Função para formatar strings com quebras de linha em listas, mantendo os ';' exceto no último item
        function formatList(text) {
            if(text) {
                // Dividir o texto por ';' e filtrar itens vazios
                var items = text.split(';').filter(function(item) {
                    return item.trim() !== '';
                });
                // Mapear cada item para um <li>, adicionando ';' no final, exceto no último
                return items.map(function(item, index) {
                    var suffix = (index === items.length - 1) ? '' : ';';
                    return '<li>' + item.trim() + suffix + '</li>';
                }).join('');
            } else {
                return '<li>Sem informações.</li>';
            }
        }
        
    
        // Carrega as notas de versão ao carregar a página
        carregarNotas();
      
        // Anexando o evento ao link que envolve o header
        $(document).on('click', '.versaoAtual, .versaoAnterior' , function(event){
            // Scroll para o elemento
            $('html, body').animate({
                scrollTop: $(this).offset().top - 120
            }, 1000);
        });


    });
    
    </script>
</body>
</html>