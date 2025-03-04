<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_NuvemPalavras.css">

<!-- Conteúdo da aba Nuvem de Palavras -->
<div class="row">
  <!-- Card explicativo -->
  <div class="col-md-4 d-flex">
    <div class="card mb-4 card-same-height w-100">
      <div class="card-header">
        <h5 class="card-title">Sobre a Nuvem de Palavras</h5>
      </div>
      <div class="card-body card-body-flex">
        <div class="flex-grow-1">
          <p style="text-align: justify;">A nuvem de palavras é uma representação visual das palavras mais frequentes encontradas nas observações das pesquisas.</p>
          <p style="text-align: justify;">Palavras maiores indicam termos que aparecem com mais frequência. Este recurso ajuda a identificar rapidamente os temas mais recorrentes nas observações.</p>
          <p style="text-align: justify;">Posicionando o cursor sobre uma palavra, você pode ver a frequência com que ela aparece e a relevância em relação às demais.</p>
          <p style="text-align: justify;">Clique em uma palavra para ver todas as observações que contêm aquele termo.</p>  
        </div>
        <!-- Controles para ajustar a nuvem de palavras -->
        <div class="mt-auto">
          <!-- Novo: Toggle para modo de seleção múltipla -->
          <div class="form-group">
            <div class="custom-control custom-switch">
              <input type="checkbox" class="custom-control-input" id="modoPesquisaMultipla">
              <label class="custom-control-label" for="modoPesquisaMultipla">Modo de Seleção Múltipla</label>
              <small class="form-text text-muted">Ative para selecionar várias palavras e buscar observações que contêm todas elas.</small>
            </div>
          </div>
          <!-- Novo: Área para palavras selecionadas (visível apenas quando o modo está ativo) -->
          <div id="areaSelecaoPalavras" style="display:none;">
            <div class="card mb-2">
              <div class="card-header py-2 bg-light">
                <div class="d-flex justify-content-between align-items-center">
                  <h6 class="m-0">Palavras Selecionadas</h6>
                  <div>
                    <button id="limparSelecao" class="btn btn-sm btn-outline-secondary mr-1" title="Limpar seleção" disabled>
                      <i class="fas fa-trash-alt"></i>
                    </button>
                    <button id="pesquisarPalavras" class="btn btn-sm btn-primary" title="Pesquisar observações" disabled>
                      <i class="fas fa-search"></i>
                    </button>
                  </div>
                </div>
              </div>
              <div class="card-body p-2">
                <div id="palavrasSelecionadas" class="d-flex flex-wrap"></div>
                <div id="semPalavras" class="text-muted small">
                  <i class="fas fa-info-circle mr-1"></i> Clique nas palavras da nuvem para adicioná-las à seleção
                </div>
              </div>
            </div>
          </div>
          
          <div class="form-group">
            <label for="minFreqSlider">Frequência Mínima: <span id="minFreqValue">2</span></label>
            <input type="range" class="custom-range" id="minFreqSlider" min="1" max="10" value="2">
            <small class="form-text text-muted">Exibe apenas palavras que aparecem pelo menos esta quantidade de vezes.</small>
          </div>
          
          <div class="form-group">
            <label for="maxWordsSlider">Quantidade de Palavras: <span id="maxWordsValue">100</span></label>
            <input type="range" class="custom-range" id="maxWordsSlider" min="20" max="200" value="100">
            <small class="form-text text-muted">Limita o número máximo de palavras exibidas.</small>
          </div>
          
          <button id="atualizarNuvem" class="btn btn-primary btn-block">
            <i class="fas fa-sync-alt mr-2"></i> Atualizar Nuvem
          </button>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Nuvem de palavras -->
  <div class="col-md-8 d-flex">
    <div class="card card-same-height w-100">
      <div class="card-header">
        <h5 class="card-title">Termos Mais Frequentes nas Observações</h5>
      </div>
      <div class="card-body">
        <div id="nuvem" style="height: 400px;"></div>
      </div>
     
    </div>
  </div>
</div>

<!-- Container para os resultados de palavra (inicialmente oculto) -->
<div id="resultados-palavra" class="mt-4" style="display: none;">
  <div class="card card-results">
    <div class="card-header navbar_correios_backgroundColor text-white" >
      <div class="d-flex justify-content-between align-items-center">
        <h5 class="card-title m-0">
          <i class="fas fa-search mr-2"></i>Observações contendo: 
          <span id="palavra-selecionada" class="badge badge-light text-primary"></span>
          <span id="contador-parenteses" class="ml-2"></span>
        </h5>
        <button type="button" class="close text-white" id="fechar-resultados" aria-label="Fechar resultados">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    </div>
    <div class="card-body bg-light">
      <div id="cards-container" class="row">
        <!-- Cards serão inseridos aqui via JS -->
      </div>
    </div>
    <div class="card-footer bg-white">
      <span id="contador-resultados" class="text-muted"></span>
    </div>
  </div>
</div>

<script>
$(document).ready(function() {
    // Variáveis de configuração
    var minFreq = 2;
    var maxWords = 100;
    // Novo: Variável para controlar modo de seleção múltipla
    var modoPesquisaMultipla = false;
    // Novo: Array para armazenar as palavras selecionadas
    var palavrasSelecionadas = [];
    // Novo: Objeto para armazenar as cores das palavras selecionadas
    var coresPalavrasSelecionadas = {};
    // Armazenar dados da nuvem para reuso
    window.cloudData = null;
    // Armazenar opções de configuração da nuvem para reuso
    window.cloudOptions = {
        width: $("#nuvem").width(),
        height: 400,
        autoResize: true,
        delay: 50,
        shape: 'rectangular',
        colors: ["#17a2b8", "#28a745", "#ffc107", "#fd7e14", "#20c997", "#6f42c1", "#e83e8c"]
    };
    
    // Atualizar valores exibidos nos labels dos sliders
    $('#minFreqSlider').on('input', function() {
        minFreq = parseInt($(this).val());
        $('#minFreqValue').text(minFreq);
    });
    
    $('#maxWordsSlider').on('input', function() {
        maxWords = parseInt($(this).val());
        $('#maxWordsValue').text(maxWords);
    });
    
    // Novo: Toggle para o modo de seleção múltipla
    $('#modoPesquisaMultipla').change(function() {
        modoPesquisaMultipla = $(this).prop('checked');
        
        if (modoPesquisaMultipla) {
            $('#areaSelecaoPalavras').slideDown(200);
        } else {
            $('#areaSelecaoPalavras').slideUp(200);
            // Limpar seleção ao desativar o modo
            limparPalavrasSelecionadas();
            // Garantir que o destaque visual seja removido imediatamente
            $('.jqcloud-word').removeClass('palavra-selecionada').css({
                'box-shadow': 'none',
                'border-radius': '0',
                'padding': '0'
            });
            
            // Ocultar resultados ao desativar o modo de seleção múltipla
            $("#resultados-palavra").hide();
            $("#cards-container").empty();
            $("#palavra-selecionada").text('');
            $("#contador-resultados").text('');
            $("#contador-parenteses").text('');
        }
    });
    
    // Novo: Função para limpar palavras selecionadas
    function limparPalavrasSelecionadas() {
        palavrasSelecionadas = [];
        coresPalavrasSelecionadas = {}; // Limpar também as cores armazenadas
        atualizarExibicaoPalavrasSelecionadas();
        atualizarDestaquePalavras(); // Adicionar chamada para atualizar destaque visual
        
        // Ocultar também a div de resultados quando limpar a seleção
        $("#resultados-palavra").hide();
        $("#cards-container").empty();
        $("#palavra-selecionada").text('');
        $("#contador-resultados").text('');
        $("#contador-parenteses").text('');
    }
    
    // Novo: Botão para limpar seleção
    $('#limparSelecao').click(function() {
        limparPalavrasSelecionadas();
    });
    
    // Novo: Botão para pesquisar com as palavras selecionadas
    $('#pesquisarPalavras').click(function() {
        if (palavrasSelecionadas.length > 0) {
            const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
            buscarObservacoesPorPalavrasMultiplas(palavrasSelecionadas, anoSelecionado, window.mcuSelecionado);
        }
    });
    
    // Novo: Função para atualizar a exibição das palavras selecionadas
    function atualizarExibicaoPalavrasSelecionadas() {
        var $container = $('#palavrasSelecionadas');
        $container.empty();
        
        if (palavrasSelecionadas.length === 0) {
            $('#semPalavras').show();
            $('#limparSelecao').prop('disabled', true);
            $('#pesquisarPalavras').prop('disabled', true);
            return;
        }
        
        $('#semPalavras').hide();
        $('#limparSelecao').prop('disabled', false);
        $('#pesquisarPalavras').prop('disabled', false);
        
        // Criar badges para cada palavra selecionada
        palavrasSelecionadas.forEach(function(palavra, index) {
            var corPalavra = coresPalavrasSelecionadas[palavra] || '#007bff'; // Usar cor armazenada ou padrão
            
            var hexColor = rgbToHex(corPalavra);
            
            var $badge = $('<span class="badge mr-2 mb-1" style="background-color: ' + hexColor + '; color: #fff; padding: 0.4em 0.6em;">' + 
                palavra + 
                '<button type="button" class="close ml-1" data-index="' + index + '" style="text-shadow: none; color: #fff; font-size: 0.8rem; opacity: 0.7;">' +
                '<span aria-hidden="true">&times;</span>' +
                '</button>' +
                '</span>');
            
            $container.append($badge);
        });
        
        // Adicionar handler para remover palavras
        $container.find('.close').click(function(e) {
            e.stopPropagation();
            var index = $(this).data('index');
            var palavraRemovida = palavrasSelecionadas[index];
            palavrasSelecionadas.splice(index, 1);
            delete coresPalavrasSelecionadas[palavraRemovida]; // Remover a cor armazenada
            atualizarExibicaoPalavrasSelecionadas();
            atualizarDestaquePalavras(); // Atualizar destaque visual após remoção
        });
    }
    
    // Botão para atualizar a nuvem
    $('#atualizarNuvem').click(function() {
        const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
        window.carregarNuvemPalavras(anoSelecionado, window.mcuSelecionado, minFreq, maxWords);
    });

    // Função para carregar e renderizar a nuvem de palavras
    window.carregarNuvemPalavras = function(anoFiltro, mcuFiltro, minFreq = 2, maxWords = 100) {
        // Se não recebeu os parâmetros, tenta obtê-los
        if (!anoFiltro) {
            anoFiltro = $("input[name='opcaoAno']:checked").val() || 'Todos';
        }
        
        // CORRIGIDO: Obter mcuFiltro de maneira robusta
        if (!mcuFiltro) {
            try {
                // Usar a variável global do arquivo principal
                mcuFiltro = window.mcuSelecionado;
                
                // Se não estiver disponível globalmente, tenta obter do input
                if (!mcuFiltro) {
                    mcuFiltro = $("input[name='opcaoMcu']:checked").val() || 'Todos';
                }
                
                // Última verificação
                if (!mcuFiltro) {
                    mcuFiltro = 'Todos';
                    console.warn("mcuFiltro não definido em carregarNuvemPalavras, usando 'Todos'");
                }
            } catch (e) {
                console.error("Erro ao obter mcuSelecionado em nuvem de palavras:", e);
                mcuFiltro = 'Todos';
            }
        }
        
         // CORRIGIDO: Limpar qualquer instância anterior de jQCloud
        if ($("#nuvem").data('jqcloud')) {
            $("#nuvem").jQCloud('destroy');
        }

        // Mostrar loader enquanto carrega
        $("#nuvem").html('<div class="text-center p-5"><i class="fas fa-spinner fa-spin fa-3x"></i><p class="mt-3">Gerando nuvem de palavras...</p></div>');
        
        // Ocultar resultados anteriores quando atualizar a nuvem
        $("#resultados-palavra").hide();
        
        // CORREÇÃO: Só limpar palavras selecionadas quando NÃO estiver no modo de seleção múltipla
        if (!modoPesquisaMultipla) {
            limparPalavrasSelecionadas();
        }
        
        // CORREÇÃO PRINCIPAL: Usar o método getWordCloud em vez de getNuvemPalavras
        $.ajax({
            url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getWordCloud&returnformat=json',
            method: 'GET',
            data: { 
                ano: anoFiltro,
                mcuOrigem: mcuFiltro,
                minFreq: minFreq,
                maxWords: maxWords
            },
            dataType: 'json',
            success: function(data) {
                // Armazenar dados globalmente para uso no resize
                window.cloudData = data;
                
                // CORRIGIDO: Limpar o conteúdo antes de renderizar a nuvem
                $("#nuvem").empty();
                
                if (data && data.length > 0) {
                    // Usar setTimeout para dar tempo ao DOM de atualizar
                    setTimeout(function() {
                        // Atualizar as opções com o width atual (pode ter mudado)
                        window.cloudOptions.width = $("#nuvem").width();
                        
                        // Adicionar o handler de afterCloudRender nas opções
                        window.cloudOptions.afterCloudRender = function() {
                            // Remover popovers antigos
                            $('.jqcloud-word[data-toggle="popover"]').popover('dispose');
                            
                            // Configurar popovers e click handlers em cada palavra
                            $('.jqcloud-word').each(function() {
                                var word = $(this);
                                var wordText = word.text();
                                var wordObj = data.find(function(item) {
                                    return item.text === wordText;
                                });
                                
                                if (wordObj) {
                                    var frequency = wordObj.weight || 0;
                                    
                                    // Verificar diferentes possíveis propriedades para relevância
                                    var relevancia = wordObj.relevancia || 
                                                    wordObj.RELEVANCIA || 
                                                    wordObj.relevance || 
                                                    wordObj.RELEVANCE || 
                                                    wordObj.tfidf || 
                                                    wordObj.TFIDF || '';
                                    
                                    // Se nenhuma propriedade de relevância for encontrada, calcular com base no peso normalizado
                                    if (!relevancia) {
                                        // Encontrar peso máximo para normalização
                                        var maxWeight = Math.max.apply(Math, data.map(function(item) { return item.weight; }));
                                        // Calcular relevância como porcentagem do peso máximo, com 2 casas decimais
                                        relevancia = ((wordObj.weight / maxWeight) * 100).toFixed(2) + '%';
                                    }
                                    
                                    // Armazenar a cor da palavra no objeto para uso posterior
                                    wordObj.color = $(word).css('color');
                                    
                                    // CORREÇÃO: Se a palavra já foi selecionada anteriormente, restaurar sua cor armazenada
                                    if (modoPesquisaMultipla && palavrasSelecionadas.includes(wordText) && coresPalavrasSelecionadas[wordText]) {
                                        // Não substituir a cor armazenada
                                    } else {
                                        // Armazenar a nova cor se essa palavra estiver selecionada
                                        if (palavrasSelecionadas.includes(wordText)) {
                                            coresPalavrasSelecionadas[wordText] = wordObj.color;
                                        }
                                    }
                                    
                                    word.attr('data-toggle', 'popover');
                                    word.attr('data-placement', 'top');
                                    word.attr('data-trigger', 'hover');
                                    word.attr('title', wordText);
                                    word.attr('data-content', 'Frequência: ' + frequency + '<br>Relevância: ' + relevancia);
                                    word.attr('data-html', 'true');
                                    
                                    // Novo: Modificar comportamento de clique conforme modo selecionado
                                    word.on('click', function() {
                                        var palavraClicada = $(this).text();
                                        var corPalavra = $(this).css('color');
                                        
                                        if (modoPesquisaMultipla) {
                                            // Verificar se a palavra já está selecionada
                                            var indexPalavra = palavrasSelecionadas.indexOf(palavraClicada);
                                            
                                            if (indexPalavra === -1) {
                                                // Adicionar à seleção
                                                palavrasSelecionadas.push(palavraClicada);
                                                // CORREÇÃO: Armazenar também a cor
                                                coresPalavrasSelecionadas[palavraClicada] = corPalavra;
                                            } else {
                                                // Remover da seleção
                                                palavrasSelecionadas.splice(indexPalavra, 1);
                                                // CORREÇÃO: Remover também a cor armazenada
                                                delete coresPalavrasSelecionadas[palavraClicada];
                                            }
                                            
                                            atualizarExibicaoPalavrasSelecionadas();
                                            
                                            // Destacar visualmente as palavras selecionadas
                                            atualizarDestaquePalavras();
                                        } else {
                                            // Comportamento original - busca imediata
                                            buscarObservacoesPorPalavra(palavraClicada, anoFiltro, mcuFiltro, corPalavra);
                                        }
                                    });
                                }
                            });
                            
                            // Inicializar popovers
                            $('[data-toggle="popover"]').popover();
                            
                            // Destacar palavras já selecionadas (após mudança de filtro)
                            if (modoPesquisaMultipla && palavrasSelecionadas.length > 0) {
                                atualizarDestaquePalavras();
                            }
                        };
                        
                        $("#nuvem").jQCloud(data, window.cloudOptions);
                    }, 100);
                } else {
                    window.cloudData = null;
                    $("#nuvem").html('<div class="text-center p-5"><i class="fas fa-comment-slash fa-3x"></i><p class="mt-3">Não foram encontradas observações para gerar a nuvem de palavras ou não aparece devido a <strong>Frequência Mínima</strong> (diminua a Frequência Mínima, ao lado, e clique em "Atualizar Nuvem").</p></div>');
                }
            },
            error: function(xhr, status, error) {
                console.error("Erro ao carregar nuvem de palavras:", error);
                window.cloudData = null;
                $("#nuvem").html('<div class="text-center p-5"><i class="fas fa-exclamation-triangle fa-3x text-danger"></i><p class="mt-3 text-danger">Erro ao carregar dados da nuvem de palavras.</p></div>');
            }
        });
    };
    
    // Novo: Função para atualizar o destaque visual das palavras selecionadas
    function atualizarDestaquePalavras() {
        // Remover destaque de todas as palavras
        $('.jqcloud-word').removeClass('palavra-selecionada').css('box-shadow', 'none');
        
        // Adicionar destaque às palavras selecionadas
        if (palavrasSelecionadas.length > 0) {
            $('.jqcloud-word').each(function() {
                var wordText = $(this).text();
                if (palavrasSelecionadas.includes(wordText)) {
                    var cor = coresPalavrasSelecionadas[wordText] || $(this).css('color');
                    var hexColor = rgbToHex(cor);
                    
                    $(this).addClass('palavra-selecionada').css({
                        'box-shadow': '0 0 5px ' + hexColor,
                        'border-radius': '3px',
                        'padding': '2px'
                    });
                }
            });
        }
    }
    
    // Novo: Função para buscar observações com múltiplas palavras
    function buscarObservacoesPorPalavrasMultiplas(palavras, ano, mcu) {
        if (!palavras || palavras.length === 0) return;
        
        // Armazenar a cor da primeira palavra para uso posterior
        var corPalavra = '';
        var palavraObj = window.cloudData && window.cloudData.find(function(item) {
            return item.text === palavras[0];
        });
        
        if (palavraObj && palavraObj.color) {
            corPalavra = palavraObj.color;
            window.ultimaCorPalavra = corPalavra;
        } else if (coresPalavrasSelecionadas[palavras[0]]) {
            // CORREÇÃO: Tentar usar a cor armazenada se disponível
            corPalavra = coresPalavrasSelecionadas[palavras[0]];
            window.ultimaCorPalavra = corPalavra;
        }
        
        // Mostrar indicador de carregamento
        var loadingIndicator = $('<div class="overlay-loading position-fixed w-100 h-100" style="top:0;left:0;background:rgba(255,255,255,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;"><div class="text-center"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Carregando observações...</p></div></div>');
        $('body').append(loadingIndicator);
        
        // Mostrar o card de resultados com indicador de carregamento
        $("#resultados-palavra").show();
        $("#cards-container").html('<div class="col-12 text-center p-5"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Carregando observações...</p></div>');
        
        // CORRIGIDO: Exibir as palavras selecionadas no título do card de resultados com contraste adequado
        var hexColor = corPalavra ? rgbToHex(corPalavra) : '#007bff';
        var badgesHTML = '';
        
        // Criar um badge para cada palavra com estilo inline forte
        palavras.forEach(function(palavra, index) {
            if (index > 0) {
                badgesHTML += ', ';
            }
            badgesHTML += '<span class="badge badge-palavra-selecionada" style="display:inline-block; background-color: #ffffff !important; color: ' + hexColor + ' !important; border: 2px solid ' + hexColor + ' !important; font-weight: bold !important; margin: 0 2px; padding: 3px 6px !important; border-radius: 3px !important;">' + palavra + '</span>';
        });
        
        // Usar classe wrapper para maior isolamento
        $("#palavra-selecionada").html('<span class="palavras-selecionadas-wrapper" style="color: inherit !important;">' + badgesHTML + '</span>');
        
        // Atualizar a cor do header do card de resultados principal
        if (corPalavra) {
            var hexColor = rgbToHex(corPalavra);
            var darkerColor = adjustColor(hexColor, -30);
            
            $(".card-results .card-header").css('background', 'linear-gradient(135deg, ' + darkerColor + ', ' + hexColor + ')');
        }
        
        // Chamar API para buscar observações com múltiplas palavras
        $.ajax({
            url: 'cfc/pc_cfcPesquisasDashboard.cfc',
            method: 'GET',
            data: {
                method: 'getObservacoesByMultiPalavras',
                palavras: JSON.stringify(palavras),
                ano: ano,
                mcuOrigem: mcu,
                returnformat: 'json'
            },
            success: function(response) {
                try {
                    var data = JSON.parse(response);
                    
                    // Verificar se há erro
                    var erro = data.find(function(item) { return item && item.tipo === "erro"; });
                    
                    if (erro) {
                        console.error("Erro na API:", erro);
                        $("#cards-container").html(
                            '<div class="col-12">' +
                                '<div class="alert alert-danger">' +
                                    '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                                    'Erro ao buscar observações: ' + erro.mensagem +
                                    '<br><small>' + erro.detalhe + '</small>' +
                                '</div>' +
                            '</div>'
                        );
                        $("#contador-resultados").text('Ocorreu um erro na consulta');
                        $("#contador-parenteses").text('');
                        
                        // Rolar até os resultados mesmo com erro
                        scrollToResultados();
                        return;
                    }
                    
                    $("#cards-container").empty();
                    
                    if (data && data.length > 0) {
                        // Texto para o contador
                        var textoContador = data.length + (data.length === 1 ? ' observação encontrada' : ' observações encontradas');
                        
                        // Atualizar contadores
                        $("#contador-resultados").text(textoContador);
                        $("#contador-parenteses").text('(' + textoContador + ')');
                        
                        // Criar um card para cada observação
                        data.forEach(function(item, index) {
                            // Destacar todas as palavras selecionadas no texto
                            var observacaoComDestaque = item.observacao;
                            palavras.forEach(function(palavra) {
                                observacaoComDestaque = destacarPalavra(observacaoComDestaque, palavra, corPalavra);
                            });
                            
                            var processoId = item.processo_id;
                            var orgaoRespondente = item.orgao_respondente;
                            var orgaoOrigem = item.orgao_origem || "Não informado";
                            
                            var card = criarCardObservacao(processoId, orgaoRespondente, orgaoOrigem, observacaoComDestaque, index, corPalavra);
                            $("#cards-container").append(card);
                        });
                        
                        // Inicializar os tooltips
                        $('[data-toggle="tooltip"]').tooltip();
                    } else {
                        $("#cards-container").html(
                            '<div class="col-12">' +
                                '<div class="alert alert-warning">' +
                                    '<i class="fas fa-exclamation-circle mr-2"></i>' +
                                    'Nenhuma observação encontrada contendo todas as palavras selecionadas.' +
                                '</div>' +
                            '</div>'
                        );
                        $("#contador-resultados").text('0 observações');
                        $("#contador-parenteses").text('(0 observações encontradas)');
                    }
                    
                    // ALTERADO: Mover a rolagem para fora do bloco condicional para sempre rolar
                    scrollToResultados();
                    
                } catch (e) {
                    console.error("Erro ao processar resposta:", e);
                    $("#cards-container").html(
                        '<div class="col-12">' +
                            '<div class="alert alert-danger">' +
                                '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                                'Erro ao processar a resposta. Detalhes: ' + e.message +
                            '</div>' +
                        '</div>'
                    );
                    $('.overlay-loading').remove();
                    
                    // Rolar até os resultados mesmo com erro
                    scrollToResultados();
                }
            },
            error: function(xhr, status, error) {
                console.error("Erro ao buscar observações:", error);
                $("#cards-container").html('<div class="col-12"><div class="alert alert-danger"><i class="fas fa-exclamation-triangle mr-2"></i>Erro ao buscar observações: ' + error + '</div></div>');
                $("#contador-resultados").text('Ocorreu um erro na consulta');
                $("#contador-parenteses").text('');
                $('.overlay-loading').remove();
                
                // Rolar até os resultados mesmo com erro
                scrollToResultados();
            }
        });
    }
    
    // Função para buscar observações que contêm a palavra clicada
    function buscarObservacoesPorPalavra(palavra, ano, mcu, corPalavra) {
        // Armazenar a cor da palavra para uso posterior
        window.ultimaCorPalavra = corPalavra;
        
        // Mostrar indicador de carregamento sem usar modal
        var loadingIndicator = $('<div class="overlay-loading position-fixed w-100 h-100" style="top:0;left:0;background:rgba(255,255,255,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;"><div class="text-center"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Carregando observações...</p></div></div>');
        $('body').append(loadingIndicator);
        
        // Mostrar o card de resultados com indicador de carregamento
        $("#resultados-palavra").show();
        $("#cards-container").html('<div class="col-12 text-center p-5"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Carregando observações...</p></div>');
        $("#palavra-selecionada").text(palavra);
        
        // Atualizar a cor do header do card de resultados principal para combinar com a palavra
        if (corPalavra) {
            // Converter a cor RGB para hexadecimal para usar como valor do gradiente
            var hexColor = rgbToHex(corPalavra);
            var darkerColor = adjustColor(hexColor, -30); // Versão mais escura da cor
            
            // Invertido o gradiente para que a cor mais forte fique à esquerda
            $(".card-results .card-header").css('background', 'linear-gradient(135deg, ' + darkerColor + ', ' + hexColor + ')');
            
            // SOLUÇÃO ROBUSTA: Aplicar a cor ao texto do badge usando todas as técnicas disponíveis
            
            // 1. Remover qualquer classe existente que possa interferir
            $("#palavra-selecionada").removeClass("text-primary").removeClass("badge-light");
            
            // 2. Aplicar estilos inline usando elemento DOM diretamente
            document.getElementById("palavra-selecionada").style.color = hexColor;
            document.getElementById("palavra-selecionada").style.backgroundColor = "#ffffff";
            document.getElementById("palavra-selecionada").style.border = "1px solid " + hexColor;
            
            // 3. Adicionar !important via jQuery attr para maior especificidade
            $("#palavra-selecionada").attr('style', 'color: ' + hexColor + ' !important; background-color: #ffffff !important; border: 1px solid ' + hexColor + ' !important;');
            
            // 4. Adicionar classe customizada e definir variável CSS
            $("<style>")
                .prop("type", "text/css")
                .html("#palavra-selecionada.custom-badge-" + Date.now() + " { color: " + hexColor + " !important; background-color: #ffffff !important; border: 1px solid " + hexColor + " !important; }")
                .appendTo("head");
                
            $("#palavra-selecionada").addClass("custom-badge-" + Date.now());
            
            console.log("Cor aplicada ao badge:", hexColor);
        }
        
        // MODIFICAÇÃO AQUI - Usar getObservacoesByPalavraExata em vez de getObservacoesByPalavra
        $.ajax({
            url: 'cfc/pc_cfcPesquisasDashboard.cfc',
            method: 'GET',
            data: {
                method: 'getObservacoesByPalavraExata', // Nova função
                palavra: palavra,
                ano: ano,
                mcuOrigem: mcu,
                returnformat: 'json'
            },
            success: function(response) {
                try {
                    var data = JSON.parse(response);
                    
                    // Novo formato de verificação de erro - procura por um item com tipo = "erro"
                    var erro = data.find(function(item) { return item && item.tipo === "erro"; });
                    
                    if (erro) {
                        console.error("Erro na API:", erro);
                        $("#cards-container").html(
                            '<div class="col-12">' +
                                '<div class="alert alert-danger">' +
                                    '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                                    'Erro ao buscar observações: ' + erro.mensagem +
                                    '<br><small>' + erro.detalhe + '</small>' +
                                '</div>' +
                            '</div>'
                        );
                        $("#contador-resultados").text('Ocorreu um erro na consulta');
                        $("#contador-parenteses").text('');
                        // Remover o indicador de carregamento
                        $('.overlay-loading').remove();
                        
                        // Rolar até os resultados mesmo com erro
                        scrollToResultados();
                        return;
                    }
                    
                    $("#cards-container").empty();
                    
                    if (data && data.length > 0) {
                        // Texto para o contador (singular ou plural)
                        var textoContador = data.length + (data.length === 1 ? ' observação encontrada' : ' observações encontradas');
                        
                        // Atualizar contadores
                        $("#contador-resultados").text(textoContador);
                        $("#contador-parenteses").text('(' + textoContador + ')');
                        
                        // Criar um card para cada observação
                        data.forEach(function(item, index) {
                            // Passa a cor da palavra para destacarPalavra
                            var observacaoComDestaque = destacarPalavra(item.observacao, palavra, corPalavra);
                            var processoId = item.processo_id;
                            var orgaoRespondente = item.orgao_respondente;
                            var orgaoOrigem = item.orgao_origem || "Não informado";
                            
                            var card = criarCardObservacao(processoId, orgaoRespondente, orgaoOrigem, observacaoComDestaque, index, corPalavra);
                            $("#cards-container").append(card);
                        });
                        
                        // Inicializar os tooltips para os novos elementos
                        $('[data-toggle="tooltip"]').tooltip();
                    } else {
                        $("#cards-container").html(
                            '<div class="col-12">' +
                                '<div class="alert alert-warning">' +
                                    '<i class="fas fa-exclamation-circle mr-2"></i>' +
                                    'Nenhuma observação encontrada com a palavra "<strong>' + palavra + '</strong>".' +
                                '</div>' +
                            '</div>'
                        );
                        $("#contador-resultados").text('0 observações');
                        $("#contador-parenteses").text('(0 observações encontradas)');
                        // Remover o indicador de carregamento
                        $('.overlay-loading').remove();
                    }
                    
                    // ALTERADO: Mover a rolagem para fora do bloco condicional para sempre rolar
                    scrollToResultados();
                    
                } catch (e) {
                    console.error("Erro ao processar resposta:", e);
                    $("#cards-container").html(
                        '<div class="col-12">' +
                            '<div class="alert alert-danger">' +
                                '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                                'Erro ao processar a resposta. Detalhes: ' + e.message +
                            '</div>' +
                        '</div>'
                    );
                    // Remover o indicador de carregamento
                    $('.overlay-loading').remove();
                    
                    // Rolar até os resultados mesmo com erro
                    scrollToResultados();
                }
            },
            error: function(xhr, status, error) {
                console.error("Erro ao buscar observações:", error);
                $("#cards-container").html('<div class="col-12"><div class="alert alert-danger"><i class="fas fa-exclamation-triangle mr-2"></i>Erro ao buscar observações: ' + error + '</div></div>');
                $("#contador-resultados").text('Ocorreu um erro na consulta');
                $("#contador-parenteses").text('');
                // Remover o indicador de carregamento
                $('.overlay-loading').remove();
                
                // Rolar até os resultados mesmo com erro
                scrollToResultados();
            }
        });
    }
    
    // Função para destacar a palavra na observação
    function destacarPalavra(texto, palavra, corPalavra) {
        if (!texto) return '';
        
        // Converter a cor para hexadecimal se for fornecida
        var hexColor = corPalavra ? rgbToHex(corPalavra) : '#007bff';
        
        // Escapar a palavra para uso seguro na expressão regular
        var palavraEscapada = escapeRegExp(palavra);
        
        // Criar regex que faz match somente com a palavra exata, sem incluir espaços
        // Usa limites de palavra (\b) para garantir palavras completas
        var regex = new RegExp('\\b(' + palavraEscapada + ')\\b', 'gi');
        
        // Aplicar a cor junto com o negrito para correspondências
        return texto.replace(regex, '<strong class="palavra-destacada" style="color:' + hexColor + ';">$1</strong>');
    }
    
    // Função auxiliar para escapar caracteres especiais em regex
    function escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }
    
    // Função para criar um card de observação com design aprimorado usando a cor da palavra
    function criarCardObservacao(processoId, orgaoRespondente, orgaoOrigem, observacao, index, corPalavra) {
        // Usar a cor da palavra ou escolher cores alternadas se não for fornecida
        var styleHeader = '';
        var badgeClass = '';
        
        if (corPalavra) {
            // Converter a cor RGB para hexadecimal para usar como valor do gradiente
            var hexColor = rgbToHex(corPalavra);
            var darkerColor = adjustColor(hexColor, -30); // Versão mais escura da cor
            
            // Adicionar cor branca explicitamente no estilo inline para o texto
            styleHeader = 'style="background: linear-gradient(135deg, ' + darkerColor + ', ' + hexColor + '); color: #ffffff !important;"';
            
            // SOLUÇÃO ROBUSTA: Garantir que o badge do número sequencial mantenha a cor
            badgeClass = 'class="badge-numero-sequencial-' + index + '" style="color: ' + hexColor + ' !important; background-color: #ffffff !important; border: 1px solid ' + hexColor + ' !important;"';
            
            // Adicionar um estilo CSS dinâmico para o badge com alta especificidade
            var styleId = "style-badge-" + Date.now() + "-" + index;
            $("<style id='" + styleId + "'>")
                .prop("type", "text/css")
                .html(".badge-numero-sequencial-" + index + " { color: " + hexColor + " !important; background-color: #ffffff !important; border: 1px solid " + hexColor + " !important; }")
                .appendTo("head");
        } else {
            // Fallback para as cores pré-definidas se não tiver a cor da palavra
            var headerClasses = ['bg-primary', 'bg-success', 'bg-info', 'bg-warning', 'bg-danger', 'bg-secondary'];
            var currentClass = headerClasses[index % headerClasses.length];
            styleHeader = 'class="' + currentClass + '" style="color: #ffffff !important;"';
            
            // Usar a classe do Bootstrap correspondente com estilo adicional inline para garantir
            var colorClass = "text-" + currentClass.replace('bg-', '');
            badgeClass = 'class="badge-light ' + colorClass + '" style="color: inherit !important; font-weight: bold !important;"';
        }
        
        return $('<div class="col-md-6 mb-4">' +
            '<div class="card card-observacao h-100 shadow-sm">' +
                '<div class="card-header text-white py-2" ' + styleHeader + '>' +
                    '<div class="d-flex justify-content-between align-items-center" style="color: #ffffff !important;">' +
                        '<h5 class="card-title mb-0" style="color: #ffffff !important;">' +
                            '<i class="fas fa-file-alt mr-2" style="color: #ffffff !important;"></i>Processo: ' + processoId +
                        '</h5>' +
                        '<span class="badge badge-light" ' + badgeClass + ' data-toggle="tooltip" title="Número sequencial">#' + (index+1) + '</span>' +
                    '</div>' +
                '</div>' +
                '<div class="card-body bg-white" style="padding:0.5rem">' +
                    '<div class="row mb-3" style="margin-bottom:0!important;">' +
                        '<div class="col-md-6">' +
                            '<div class="d-flex align-items-center mb-2">' +
                                '<i class="fas fa-building text-muted mr-2"></i>' +
                                '<div>' +
                                    '<span class="d-block">Órgão Respondente:</span>' +
                                    '<span class="text-primary">' + orgaoRespondente + '</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<div class="d-flex align-items-center">' +
                                '<i class="fas fa-map-marker-alt text-muted mr-2"></i>' +
                                '<div>' +
                                    '<span class="d-block">Órgão de Origem:</span>' +
                                    '<span class="text-primary">' + orgaoOrigem + '</span>' +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<hr class="my-2">' +
                    '<div class="observacao-texto card-scrollable-content p-2" style="padding:2px !important; text-align: justify !important;">' + observacao + '</div>' +
                '</div>' +
            '</div>' +
        '</div>');
    }
    
    // Função auxiliar para converter RGB para HEX
    function rgbToHex(rgb) {
        // Se já for hex, retornar
        if (rgb.startsWith('#')) {
            return rgb;
        }
        
        // Extrair valores R, G, B da string "rgb(r, g, b)"
        var rgbArr = rgb.match(/\d+/g);
        if (!rgbArr || rgbArr.length !== 3) {
            return '#007bff'; // Fallback para cor padrão
        }
        
        var r = parseInt(rgbArr[0]);
        var g = parseInt(rgbArr[1]);
        var b = parseInt(rgbArr[2]);
        
        return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    }
    
    // Função para ajustar a cor (torná-la mais clara ou escura)
    function adjustColor(hex, percent) {
        // Remove o # se presente
        hex = hex.replace('#', '');
        
        // Converte para RGB
        var r = parseInt(hex.substring(0, 2), 16);
        var g = parseInt(hex.substring(2, 4), 16);
        var b = parseInt(hex.substring(4, 6), 16);
        
        // Ajusta os valores (limita entre 0 e 255)
        r = Math.max(0, Math.min(255, Math.round(r * (100 + percent) / 100)));
        g = Math.max(0, Math.min(255, Math.round(g * (100 + percent) / 100)));
        b = Math.max(0, Math.min(255, Math.round(b * (100 + percent) / 100)));
        
        // Converte de volta para hex
        return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
    }
    
    // Manipulador de evento para o botão fechar resultados
    $("#fechar-resultados").on('click', function() {
        $("#resultados-palavra").hide();
        $("#cards-container").empty();
        $("#palavra-selecionada").text('');
        $("#contador-resultados").text('');
        $("#contador-parenteses").text('');
    });
    
    // Inicializar a nuvem quando o componente for carregado
    setTimeout(function() {
        window.carregarNuvemPalavras(null, null, minFreq, maxWords);
    }, 500);
    
    // Adicionar ouvintes para eventos de filtro
    $(document).on('filtroAlterado', function(event, dados) {
        if ($("#nuvem-palavras").hasClass('active') || $("#nuvem-palavras").hasClass('show')) {
            const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
            // Usar a variável global diretamente quando possível
            window.carregarNuvemPalavras(anoSelecionado, window.mcuSelecionado, minFreq, maxWords);
        }
    });
    
    // Ajustar tamanho da nuvem quando a janela for redimensionada - CORRIGIDO
    $(window).on('resize', function() {
        // Verificar se a aba de nuvem de palavras está ativa/visível
        if ($("#nuvem-palavras").hasClass('active') || $("#nuvem-palavras").hasClass('show')) {
            if ($("#nuvem").length && window.cloudData && window.cloudData.length > 0) {
                try {
                    // Destruir a instância atual
                    if ($("#nuvem").data('jqcloud')) {
                        $("#nuvem").jQCloud('destroy');
                    }
                    
                    // Atualizar a largura nas opções
                    window.cloudOptions.width = $("#nuvem").width();
                    
                    // Recriar a nuvem com os dados armazenados
                    $("#nuvem").jQCloud(window.cloudData, window.cloudOptions);
                    
                    // Reativar popovers após atualização da nuvem
                    setTimeout(function() {
                        $('[data-toggle="popover"]').popover();
                    }, 200);
                } catch (e) {
                    console.error("Erro ao atualizar nuvem de palavras:", e);
                }
            }
        }
    });
    
    // Desregistrar a atualização da nuvem quando a aba for fechada
    $('#dashboardTabs a[data-toggle="tab"]').on('hide.bs.tab', function(e) {
        if ($(e.target).attr('href') === '#nuvem-palavras') {
            // Se estamos saindo da aba de nuvem de palavras
            $(window).off('resize.nuvemPalavras');
        }
    });
    
    // Registrar novo listener específico quando a aba for aberta
    $('#dashboardTabs a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        if ($(e.target).attr('href') === '#nuvem-palavras') {
            // Se estamos entrando na aba de nuvem de palavras
            $(window).on('resize.nuvemPalavras', function() {
                if ($("#nuvem").length && $("#nuvem").data('jqcloud')) {
                    try {
                        $("#nuvem").jQCloud('update');
                    } catch (e) {
                        console.error("Erro ao atualizar nuvem de palavras:", e);
                    }
                }
            });
            
            // Restaurar cores e estilos quando voltar para a aba
            // Forçar a cor do texto para branco no card-header principal
            $(".card-results .card-header").addClass("text-white");
            $(".card-results .card-header, .card-results .card-header *, .card-results .card-header h5, .card-results .card-header i, .card-results .card-header .card-title, .card-results .card-header span").css("color", "#ffffff !important");
            
            // Reforçar estilo inline para o botão de fechar
            $("#fechar-resultados").css("color", "#ffffff !important");
            
            // Se houver uma palavra selecionada anteriormente e ainda estiver visível, restaurar a formatação
            if ($("#resultados-palavra").is(":visible") && $("#palavra-selecionada").text().trim() !== '') {
                var palavraSelecionada = $("#palavra-selecionada").text();
                
                // Restaurar a cor do header se tivermos a última cor usada
                if (window.ultimaCorPalavra) {
                    var hexColor = rgbToHex(window.ultimaCorPalavra);
                    var darkerColor = adjustColor(hexColor, -30);
                    
                    // Aplicar o gradiente novamente
                    $(".card-results .card-header").css('background', 'linear-gradient(135deg, ' + darkerColor + ', ' + hexColor + ')');
                    
                    // SOLUÇÃO ROBUSTA: Aplicar a mesma abordagem para restaurar a formatação
                    
                    // 1. Remover qualquer classe existente que possa interferir
                    $("#palavra-selecionada").removeClass("text-primary").removeClass("badge-light");
                    
                    // 2. Aplicar estilos inline usando elemento DOM diretamente
                    document.getElementById("palavra-selecionada").style.color = hexColor;
                    document.getElementById("palavra-selecionada").style.backgroundColor = "#ffffff";
                    document.getElementById("palavra-selecionada").style.border = "1px solid " + hexColor;
                    
                    // 3. Adicionar !important via jQuery attr para maior especificidade
                    $("#palavra-selecionada").attr('style', 'color: ' + hexColor + ' !important; background-color: #ffffff !important; border: 1px solid ' + hexColor + ' !important;');
                    
                    // 4. Adicionar classe customizada e definir variável CSS
                    $("<style>")
                        .prop("type", "text/css")
                        .html("#palavra-selecionada.custom-badge-" + Date.now() + " { color: " + hexColor + " !important; background-color: #ffffff !important; border: 1px solid " + hexColor + " !important; }")
                        .appendTo("head");
                        
                    $("#palavra-selecionada").addClass("custom-badge-" + Date.now());
                }
            }
        }
    });
});

// NOVO: Função auxiliar para rolar até os resultados
function scrollToResultados() {
    // Usar a função global específica do site se disponível
    if (typeof window.scrollToElement === 'function') {
        setTimeout(function() {
            window.scrollToElement('#resultados-palavra', 70);
            // Remover o indicador de carregamento após o scroll
            setTimeout(function() {
                $('.overlay-loading').remove();
            }, 300);
        }, 200);
    } else {
        // Fallback para scroll normal se a função global não existir
        setTimeout(function() {
            $('.content-wrapper').animate({
                scrollTop: $('.content-wrapper').scrollTop() + $("#resultados-palavra").position().top - 70
            }, 800, function() {
                // Remover o indicador de carregamento quando a animação terminar
                $('.overlay-loading').remove();
            });
        }, 200);
    }
}
</script>
