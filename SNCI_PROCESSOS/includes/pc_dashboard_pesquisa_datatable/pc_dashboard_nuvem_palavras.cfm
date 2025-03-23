<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_NuvemPalavras.css">

<!-- Card container principal -->
<div class="card dashboard-card mb-4">
  <div class="card-header">
    <h3 class="card-title">
      <i class="fas fa-cloud mr-2"></i>Nuvem de Palavras
    </h3>
    <div class="card-tools">
      <button type="button" class="btn btn-tool" data-card-widget="collapse">
        <i class="fas fa-minus"></i>
      </button>
    </div>
  </div>
  <div class="card-body">
    <!-- Conteúdo da aba Nuvem de Palavras -->
    <div class="row">
      <!-- Card explicativo -->
      <div class="col-md-4 d-flex">
        <div class="card mb-4 card-same-height w-100">
          <div class="card-header">
            <h5 class="card-title">Sobre a Nuvem de Palavras</h5>
          </div>
          <div class="card-body card-body-flex">
            <ul>
              <li style="text-align: justify;margin-bottom:0.2rem!important">A nuvem de palavras é uma representação visual das palavras mais frequentes encontradas nas observações das pesquisas;</li>
              <li style="text-align: justify;margin-bottom:0.2rem!important">Palavras maiores indicam termos que aparecem com mais frequência. Este recurso ajuda a identificar rapidamente os temas mais recorrentes nas observações;</li>
              <li style="text-align: justify;margin-bottom:0.2rem!important">Posicionando o cursor sobre uma palavra, você pode ver a frequência com que ela aparece e a relevância em relação às demais;</li>
              <li style="text-align: justify;margin-bottom:0!important">Clique em uma palavra para ver todas as observações que contêm aquele termo.</li>  
            </ul>
            <!-- Controles para ajustar a nuvem de palavras -->
            <div class="mt-auto">
              <!-- Novo: Toggle para modo de seleção múltipla -->
              <div class="form-group">
                <div class="custom-control custom-switch">
                  <input type="checkbox" class="custom-control-input" id="modoPesquisaMultiplaDT">
                  <label class="custom-control-label" for="modoPesquisaMultiplaDT">Modo de Seleção Múltipla</label>
                  <small class="form-text text-muted">Ative para selecionar várias palavras e buscar observações que contêm todas elas.</small>
                </div>
              </div>
              <!-- Novo: Área para palavras selecionadas (visível apenas quando o modo está ativo) -->
              <div id="areaSelecaoPalavrasDT" style="display:none;">
                <div class="card mb-2">
                  <div class="card-header py-2 bg-light">
                    <div class="d-flex justify-content-between align-items-center">
                      <h6 class="m-0">Palavras Selecionadas</h6>
                      <div>
                        <button id="limparSelecaoDT" class="btn btn-sm btn-outline-secondary mr-1" title="Limpar seleção" disabled>
                          <i class="fas fa-trash-alt"></i>
                        </button>
                        <button id="pesquisarPalavrasDT" class="btn btn-sm btn-primary" title="Pesquisar observações" disabled>
                          <i class="fas fa-search"></i>
                        </button>
                      </div>
                    </div>
                  </div>
                  <div class="card-body p-2">
                    <div id="palavrasSelecionadasDT" class="d-flex flex-wrap"></div>
                    <div id="semPalavrasDT" class="text-muted small">
                      <i class="fas fa-info-circle mr-1"></i> Clique nas palavras da nuvem para adicioná-las à seleção
                    </div>
                  </div>
                </div>
              </div>
              
              <div class="form-group">
                <label for="minFreqSliderDT">Frequência Mínima: <span id="minFreqValueDT">2</span></label>
                <input type="range" class="custom-range" id="minFreqSliderDT" min="1" max="10" value="2">
                <small class="form-text text-muted">Exibe apenas palavras que aparecem pelo menos esta quantidade de vezes.</small>
              </div>
              
              <div class="form-group">
                <label for="maxWordsSliderDT">Quantidade de Palavras: <span id="maxWordsValueDT">100</span></label>
                <input type="range" class="custom-range" id="maxWordsSliderDT" min="20" max="200" value="100">
                <small class="form-text text-muted">Limita o número máximo de palavras exibidas.</small>
              </div>
              
              <button id="atualizarNuvemDT" class="btn btn-primary btn-block">
                <i class="fas fa-sync-alt mr-2"></i> Atualizar Nuvem
              </button>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Nuvem de palavras - Container com ID modificado para evitar problemas -->
      <div class="col-md-8 d-flex">
        <div class="card card-same-height w-100">
          <div class="card-header">
            <h5 class="card-title">Termos Mais Frequentes nas Observações</h5>
          </div>
          <div class="card-body">
            <!-- ID alterado para ser específico deste componente -->
            <div id="nuvem-container-DT" style="height: 400px;"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Container para os resultados de palavra (inicialmente oculto) -->
    <div id="resultados-palavra-DT" class="mt-4" style="display: none;">
      <div class="card card-results">
        <div class="card-header navbar_correios_backgroundColor text-white">
          <div class="d-flex justify-content-between align-items-center">
            <h5 class="card-title m-0">
              <i class="fas fa-search mr-2"></i>Observações contendo: 
              <span id="palavra-selecionada-DT" class="badge badge-light text-primary"></span>
              <span id="contador-parenteses-DT" class="ml-2"></span>
            </h5>
            <button type="button" class="close text-white" id="fechar-resultados-DT" aria-label="Fechar resultados">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
        </div>
        <div class="card-body bg-light">
          <div id="cards-container-DT" class="row">
            <!-- Cards serão inseridos aqui via JS -->
          </div>
        </div>
        <div class="card-footer bg-white">
          <span id="contador-resultados-DT" class="text-muted"></span>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.nuvemPalavrasDTLoaded === 'undefined') {
        window.nuvemPalavrasDTLoaded = true;
        
        // Variáveis de configuração
        var minFreq = 2;
        var maxWords = 100;
        // Variável para controlar modo de seleção múltipla
        var modoPesquisaMultipla = false;
        // Array para armazenar as palavras selecionadas
        var palavrasSelecionadas = [];
        // Objeto para armazenar as cores das palavras selecionadas
        var coresPalavrasSelecionadas = {};
        // Armazenar dados da nuvem para reuso
        window.cloudDataDT = null;
        
        // Flag para controlar se a nuvem está sendo renderizada
        window.isRenderingCloudDT = false;
        
        // Armazenar opções de configuração da nuvem para reuso
        window.cloudOptionsDT = {
            width: $("#nuvem-container-DT").width(),
            height: 400,
            autoResize: true,
            delay: 5,
            delayedMode: false,
            shape: 'rectangular',
            encodeURI: false,
            removeOverflowing: true,
            colors: ["#17a2b8", "#28a745", "#ffc107", "#fd7e14", "#20c997", "#6f42c1", "#e83e8c"]
        };
        
        // Atualizar valores exibidos nos labels dos sliders
        $('#minFreqSliderDT').on('input', function() {
            minFreq = parseInt($(this).val());
            $('#minFreqValueDT').text(minFreq);
        });
        
        $('#maxWordsSliderDT').on('input', function() {
            maxWords = parseInt($(this).val());
            $('#maxWordsValueDT').text(maxWords);
        });
        
        // Toggle para o modo de seleção múltipla
        $('#modoPesquisaMultiplaDT').change(function() {
            modoPesquisaMultipla = $(this).prop('checked');
            
            if (modoPesquisaMultipla) {
                $('#areaSelecaoPalavrasDT').slideDown(200);
            } else {
                $('#areaSelecaoPalavrasDT').slideUp(200);
                // Limpar seleção ao desativar o modo
                limparPalavrasSelecionadas();
                // Garantir que o destaque visual seja removido imediatamente
                $('.jqcloud-word').removeClass('palavra-selecionada').css({
                    'box-shadow': 'none',
                    'border-radius': '0',
                    'padding': '0'
                });
                
                // Ocultar resultados ao desativar o modo de seleção múltipla
                $("#resultados-palavra-DT").hide();
                $("#cards-container-DT").empty();
                $("#palavra-selecionada-DT").text('');
                $("#contador-resultados-DT").text('');
                $("#contador-parenteses-DT").text('');
            }
        });
        
        // Função para limpar palavras selecionadas
        function limparPalavrasSelecionadas() {
            palavrasSelecionadas = [];
            coresPalavrasSelecionadas = {};
            atualizarExibicaoPalavrasSelecionadas();
            atualizarDestaquePalavras();
            
            // Ocultar também a div de resultados quando limpar a seleção
            $("#resultados-palavra-DT").hide();
            $("#cards-container-DT").empty();
            $("#palavra-selecionada-DT").text('');
            $("#contador-resultados-DT").text('');
            $("#contador-parenteses-DT").text('');
        }
        
        // Botão para limpar seleção
        $('#limparSelecaoDT').click(function() {
            limparPalavrasSelecionadas();
        });
        
        // Botão para pesquisar com as palavras selecionadas
        $('#pesquisarPalavrasDT').click(function() {
            if (palavrasSelecionadas.length > 0) {
                const anoSelecionado = window.anoSelecionado || 'Todos';
                buscarObservacoesPorPalavrasMultiplas(palavrasSelecionadas, anoSelecionado);
            }
        });
        
        // Função para atualizar a exibição das palavras selecionadas
        function atualizarExibicaoPalavrasSelecionadas() {
            var $container = $('#palavrasSelecionadasDT');
            $container.empty();
            
            if (palavrasSelecionadas.length === 0) {
                $('#semPalavrasDT').show();
                $('#limparSelecaoDT').prop('disabled', true);
                $('#pesquisarPalavrasDT').prop('disabled', true);
                return;
            }
            
            $('#semPalavrasDT').hide();
            $('#limparSelecaoDT').prop('disabled', false);
            $('#pesquisarPalavrasDT').prop('disabled', false);
            
            // Criar badges para cada palavra selecionada
            palavrasSelecionadas.forEach(function(palavra, index) {
                var corPalavra = coresPalavrasSelecionadas[palavra] || '#007bff';
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
                delete coresPalavrasSelecionadas[palavraRemovida];
                atualizarExibicaoPalavrasSelecionadas();
                atualizarDestaquePalavras();
            });
        }
        
        // Atualizar o destaque visual das palavras selecionadas
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
        
        // Botão para atualizar a nuvem
        $('#atualizarNuvemDT').click(function() {
            window.processarNuvemPalavras(minFreq, maxWords);
        });

        // Função principal para processar a nuvem de palavras com os dados do DataTable
        window.processarNuvemPalavras = function(minFreq = 2, maxWords = 100) {
            // Se já estiver renderizando, saia para evitar chamadas simultâneas
            if (window.isRenderingCloudDT) {
                return;
            }
            
            window.isRenderingCloudDT = true;
            
            // Obter a tabela
            const dataTable = $('#tabelaPesquisasDetalhada').DataTable();
            
            // Verificar se a tabela existe e está inicializada
            if (!dataTable) {
                window.isRenderingCloudDT = false;
                return;
            }
            
            // Obter os dados filtrados da tabela
            const dados = dataTable.rows({search: 'applied'}).data().toArray();
            
            // Limpar o conteúdo atual da nuvem e destruir a instância anterior
            try {
                if ($("#nuvem-container-DT").data('jqcloud')) {
                    $("#nuvem-container-DT").jQCloud('destroy');
                }
                
                // Remover o elemento canvas diretamente para garantir limpeza total
                $("#nuvem-container-DT").empty();
                $("#nuvem-container-DT").removeData('jqcloud');
                
                // Remover qualquer resíduo de estilos ou atributos
                $("#nuvem-container-DT").removeAttr('style').css({
                    'height': '400px',
                    'position': 'relative'
                });
            } catch (e) {
                console.warn("Erro ao limpar nuvem anterior:", e);
                $("#nuvem-container-DT").empty();
            }

            // Criar um ID separado para o loader, para que possamos removê-lo facilmente
            const loaderId = 'nuvem-loader-' + Math.random().toString(36).substring(2, 15);
            $("#nuvem-container-DT").html('<div id="' + loaderId + '" class="text-center p-5"><i class="fas fa-spinner fa-spin fa-3x"></i><p class="mt-3">Gerando nuvem de palavras...</p></div>');
            
            // Ocultar resultados anteriores quando atualizar a nuvem
            if (!modoPesquisaMultipla) {
                $("#resultados-palavra-DT").hide();
                limparPalavrasSelecionadas();
            }
            
            // Se não há dados, mostrar mensagem
            if (dados.length === 0) {
                $("#nuvem-container-DT").html('<div class="text-center p-5"><i class="fas fa-comment-slash fa-3x"></i><p class="mt-3">Não foram encontradas observações para gerar a nuvem de palavras.</p></div>');
                window.isRenderingCloudDT = false;
                return;
            }
            
            // Extrair todas as observações
            let textoObservacoes = dados
                .map(item => item.observacao)
                .filter(obs => obs && obs.trim() !== '')
                .join(' ');
            
            // Se não há observações, mostrar mensagem
            if (!textoObservacoes || textoObservacoes.trim() === '') {
                $("#nuvem-container-DT").html('<div class="text-center p-5"><i class="fas fa-comment-slash fa-3x"></i><p class="mt-3">Não foram encontradas observações para gerar a nuvem de palavras.</p></div>');
                window.isRenderingCloudDT = false;
                return;
            }
            
            // Processar o texto para extrair palavras e contagens
            const palavras = processarTexto(textoObservacoes);
            
            // Filtrar por frequência mínima e limite de palavras
            const palavrasFiltradas = palavras
                .filter(p => p.weight >= minFreq)
                .slice(0, maxWords);
            
            // Armazenar dados para uso posterior
            window.cloudDataDT = palavrasFiltradas;
            
            if (palavrasFiltradas.length === 0) {
                $("#nuvem-container-DT").html('<div class="text-center p-5"><i class="fas fa-comment-slash fa-3x"></i><p class="mt-3">Não foram encontradas palavras com a frequência mínima especificada. Tente diminuir o valor do filtro "Frequência Mínima".</p></div>');
                window.isRenderingCloudDT = false;
                return;
            }
            
            // Renderizar a nuvem de palavras
            try {
                // Atualizar as opções com o width atual
                window.cloudOptionsDT.width = $("#nuvem-container-DT").width();
                window.cloudOptionsDT.height = 400;
                
                // Adicionar o handler de afterCloudRender nas opções
                window.cloudOptionsDT.afterCloudRender = function() {
                    // Remover o loader explicitamente
                    $('#' + loaderId).remove();
                    
                    // Configurar popovers e click handlers em cada palavra
                    $('.jqcloud-word').each(function() {
                        const word = $(this);
                        const wordText = word.text();
                        const wordObj = palavrasFiltradas.find(item => item.text === wordText);
                        
                        if (wordObj) {
                            const frequency = wordObj.weight || 0;
                            
                            // Armazenar a cor da palavra
                            wordObj.color = $(word).css('color');
                            
                            // Se a palavra já foi selecionada, restaurar sua cor
                            if (modoPesquisaMultipla && palavrasSelecionadas.includes(wordText)) {
                                if (!coresPalavrasSelecionadas[wordText]) {
                                    coresPalavrasSelecionadas[wordText] = wordObj.color;
                                }
                            }
                            
                            // Configurar popover
                            word.attr('data-toggle', 'popover');
                            word.attr('data-placement', 'top');
                            word.attr('data-trigger', 'hover');
                            word.attr('title', wordText);
                            word.attr('data-content', 'Frequência: ' + frequency);
                            word.attr('data-html', 'true');
                            
                            // Configurar click handler
                            word.on('click', function() {
                                const palavraClicada = $(this).text();
                                const corPalavra = $(this).css('color');
                                
                                if (modoPesquisaMultipla) {
                                    // Verificar se a palavra já está selecionada
                                    const indexPalavra = palavrasSelecionadas.indexOf(palavraClicada);
                                    
                                    if (indexPalavra === -1) {
                                        // Adicionar à seleção
                                        palavrasSelecionadas.push(palavraClicada);
                                        coresPalavrasSelecionadas[palavraClicada] = corPalavra;
                                    } else {
                                        // Remover da seleção
                                        palavrasSelecionadas.splice(indexPalavra, 1);
                                        delete coresPalavrasSelecionadas[palavraClicada];
                                    }
                                    
                                    atualizarExibicaoPalavrasSelecionadas();
                                    atualizarDestaquePalavras();
                                } else {
                                    // Busca imediata de uma única palavra
                                    buscarObservacoesPorPalavra(palavraClicada, corPalavra);
                                }
                            });
                        }
                    });
                    
                    // Inicializar popovers
                    $('[data-toggle="popover"]').popover();
                    
                    // Destacar palavras já selecionadas
                    if (modoPesquisaMultipla && palavrasSelecionadas.length > 0) {
                        atualizarDestaquePalavras();
                    }
                    
                    // Finalizar o flag de renderização
                    window.isRenderingCloudDT = false;
                };
                
                // Renderizar a nuvem - remova o loader antes de chamar jQCloud
                // para evitar conflitos de conteúdo
                setTimeout(function() {
                    try {
                        // Criar um novo contêiner para a nuvem, fora do contêiner do loader
                        const $cloudWrapper = $('<div id="cloud-wrapper-dt"></div>');
                        $("#nuvem-container-DT").append($cloudWrapper);
                        
                        // Renderizar a nuvem no novo contêiner
                        $cloudWrapper.jQCloud(palavrasFiltradas, window.cloudOptionsDT);
                        
                        // Remover o loader após um curto período para garantir que a nuvem seja renderizada
                        setTimeout(function() {
                            $('#' + loaderId).remove();
                        }, 500);
                    } catch (e) {
                        console.error("Erro ao renderizar nuvem:", e);
                        $("#nuvem-container-DT").html('<div class="text-center p-5"><i class="fas fa-exclamation-triangle fa-3x text-danger"></i><p class="mt-3 text-danger">Erro ao renderizar nuvem de palavras. Tente atualizar a página.</p></div>');
                        window.isRenderingCloudDT = false;
                    }
                }, 100);
            } catch (e) {
                console.error("Erro ao configurar nuvem:", e);
                $("#nuvem-container-DT").html('<div class="text-center p-5"><i class="fas fa-exclamation-triangle fa-3x text-danger"></i><p class="mt-3 text-danger">Erro ao renderizar nuvem de palavras. Tente atualizar a página.</p></div>');
                window.isRenderingCloudDT = false;
            }
        };
        
        // Função para processar o texto e extrair palavras com suas frequências
        function processarTexto(texto) {
            // Lista de stopwords em português
            const stopwords = [
                'a', 'ao', 'aos', 'aquela', 'aquelas', 'aquele', 'aqueles', 'aquilo', 'as', 'até', 'com', 'como',
                'da', 'das', 'de', 'dela', 'delas', 'dele', 'deles', 'depois', 'do', 'dos', 'e', 'é', 'ela', 'elas',
                'ele', 'eles', 'em', 'entre', 'era', 'eram', 'éramos', 'essa', 'essas', 'esse', 'esses', 'esta',
                'estas', 'este', 'estes', 'eu', 'foi', 'fomos', 'for', 'foram', 'fui', 'há', 'isso', 'isto', 'já',
                'lhe', 'lhes', 'mais', 'mas', 'me', 'mesmo', 'meu', 'meus', 'minha', 'minhas', 'muito', 'muitos',
                'na', 'não', 'nas', 'nem', 'no', 'nos', 'nós', 'nossa', 'nossas', 'nosso', 'nossos', 'num', 'numa',
                'o', 'os', 'ou', 'para', 'pela', 'pelas', 'pelo', 'pelos', 'por', 'qual', 'quando', 'que', 'quem',
                'são', 'se', 'seja', 'sejam', 'sejamos', 'sem', 'será', 'serão', 'seu', 'seus', 'só', 'somos', 'sou',
                'sua', 'suas', 'também', 'te', 'tem', 'tém', 'temos', 'tenho', 'teu', 'teus', 'teve', 'ti', 'tive',
                'tivemos', 'todo', 'todos', 'tu', 'tua', 'tuas', 'um', 'uma', 'umas', 'uns', 'você', 'vocês', 'vos'
            ];
            
            // Converter para minúsculas
            texto = texto.toLowerCase();
            
            // Remover caracteres especiais e números
            texto = texto.replace(/[^\p{L}\s]/gu, ' ').replace(/\d+/g, '');
            
            // Dividir em palavras e remover espaços extras
            const palavrasArray = texto.split(/\s+/).filter(p => p && p.length > 2);
            
            // Contar frequência das palavras
            const contagem = {};
            
            palavrasArray.forEach(palavra => {
                // Ignorar stopwords e palavras muito curtas
                if (!stopwords.includes(palavra) && palavra.length > 2) {
                    contagem[palavra] = (contagem[palavra] || 0) + 1;
                }
            });
            
            // Converter para o formato esperado pelo jQCloud ([{text, weight}])
            const resultado = [];
            
            for (const palavra in contagem) {
                resultado.push({
                    text: palavra,
                    weight: contagem[palavra]
                });
            }
            
            // Ordenar por peso (do maior para o menor)
            return resultado.sort((a, b) => b.weight - a.weight);
        }
        
        // Função para buscar observações com uma palavra
        function buscarObservacoesPorPalavra(palavra, corPalavra) {
            // Mostrar indicador de carregamento
            var loadingIndicator = $('<div class="overlay-loading position-fixed w-100 h-100" style="top:0;left:0;background:rgba(255,255,255,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;"><div class="text-center"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Carregando observações...</p></div></div>');
            $('body').append(loadingIndicator);
            
            // Mostrar o card de resultados com indicador de carregamento
            $("#resultados-palavra-DT").show();
            $("#cards-container-DT").html('<div class="col-12 text-center p-5"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Buscando observações com a palavra "'+palavra+'"...</p></div>');
            $("#palavra-selecionada-DT").text(palavra);
            
            // Atualizar a cor do header do card de resultados para combinar com a palavra
            if (corPalavra) {
                var hexColor = rgbToHex(corPalavra);
                var darkerColor = adjustColor(hexColor, -30);
                
                $(".card-results .card-header").css('background', 'linear-gradient(135deg, ' + darkerColor + ', ' + hexColor + ')');
                
                // Aplicar cor ao badge
                $("#palavra-selecionada-DT").css({
                    'color': hexColor,
                    'background-color': '#ffffff',
                    'border': '1px solid ' + hexColor
                });
            }
            
            // Pesquisar nas observações da tabela atual
            const dataTable = $('#tabelaPesquisasDetalhada').DataTable();
            const dados = dataTable.rows({search: 'applied'}).data().toArray();
            
            // Filtrar observações que contêm a palavra
            const regex = new RegExp('\\b' + palavra + '\\b', 'i');
            const observacoesComPalavra = dados.filter(item => 
                item.observacao && regex.test(item.observacao)
            );
            
            // Remover o indicador de carregamento
            $('.overlay-loading').remove();
            
            // Exibir os resultados
            $("#cards-container-DT").empty();
            
            if (observacoesComPalavra.length > 0) {
                const textoContador = observacoesComPalavra.length + 
                    (observacoesComPalavra.length === 1 ? ' observação encontrada' : ' observações encontradas');
                
                // Atualizar contadores
                $("#contador-resultados-DT").text(textoContador);
                $("#contador-parenteses-DT").text('(' + textoContador + ')');
                
                // Criar um card para cada observação
                observacoesComPalavra.forEach(function(item, index) {
                    const observacaoComDestaque = destacarPalavra(item.observacao, palavra, corPalavra);
                    const processoId = item.processo;
                    const orgaoRespondente = item.orgao_respondente || "Não informado";
                    const orgaoOrigem = item.orgao_origem || "Não informado";
                    
                    const card = criarCardObservacao(processoId, orgaoRespondente, orgaoOrigem, 
                        observacaoComDestaque, index, corPalavra);
                    
                    $("#cards-container-DT").append(card);
                });
                
                // Inicializar tooltips
                $('[data-toggle="tooltip"]').tooltip();
            } else {
                $("#cards-container-DT").html(
                    '<div class="col-12">' +
                        '<div class="alert alert-warning">' +
                            '<i class="fas fa-exclamation-circle mr-2"></i>' +
                            'Nenhuma observação encontrada com a palavra "<strong>' + palavra + '</strong>".' +
                        '</div>' +
                    '</div>'
                );
                $("#contador-resultados-DT").text('0 observações');
                $("#contador-parenteses-DT").text('(0 observações encontradas)');
            }
            
            // Rolar até os resultados
            scrollToResultados();
        }
        
        // Função para buscar observações com múltiplas palavras
        function buscarObservacoesPorPalavrasMultiplas(palavras) {
            if (palavras.length === 0) return;
            
            // Armazenar a cor da primeira palavra para uso posterior
            var corPalavra = coresPalavrasSelecionadas[palavras[0]] || '#007bff';
            
            // Mostrar indicador de carregamento
            var loadingIndicator = $('<div class="overlay-loading position-fixed w-100 h-100" style="top:0;left:0;background:rgba(255,255,255,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;"><div class="text-center"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Carregando observações...</p></div></div>');
            $('body').append(loadingIndicator);
            
            // Mostrar o card de resultados com indicador de carregamento
            $("#resultados-palavra-DT").show();
            $("#cards-container-DT").html('<div class="col-12 text-center p-5"><div class="spinner-grow text-primary" role="status"><span class="sr-only">Carregando...</span></div><p class="mt-3">Carregando observações...</p></div>');
            
            // Exibir as palavras selecionadas no título
            var hexColor = rgbToHex(corPalavra);
            var badgesHTML = palavras.map(palavra => 
                '<span class="badge badge-palavra-selecionada" style="display:inline-block; background-color: #ffffff !important; color: ' + 
                hexColor + ' !important; border: 2px solid ' + hexColor + ' !important; font-weight: bold !important; margin: 0 2px; padding: 3px 6px !important; border-radius: 3px !important;">' + 
                palavra + '</span>'
            ).join(', ');
            
            $("#palavra-selecionada-DT").html('<span class="palavras-selecionadas-wrapper" style="color: inherit !important;">' + badgesHTML + '</span>');
            
            // Atualizar a cor do header do card de resultados
            var darkerColor = adjustColor(hexColor, -30);
            $(".card-results .card-header").css('background', 'linear-gradient(135deg, ' + darkerColor + ', ' + hexColor + ')');
            
            // Pesquisar nas observações da tabela atual
            const dataTable = $('#tabelaPesquisasDetalhada').DataTable();
            const dados = dataTable.rows({search: 'applied'}).data().toArray();
            
            // Filtrar observações que contêm todas as palavras
            const observacoesComPalavras = dados.filter(item => {
                if (!item.observacao) return false;
                
                // Verificar se todas as palavras estão presentes
                return palavras.every(palavra => {
                    const regex = new RegExp('\\b' + palavra + '\\b', 'i');
                    return regex.test(item.observacao);
                });
            });
            
            // Remover o indicador de carregamento
            $('.overlay-loading').remove();
            
            // Exibir os resultados
            $("#cards-container-DT").empty();
            
            if (observacoesComPalavras.length > 0) {
                const textoContador = observacoesComPalavras.length + 
                    (observacoesComPalavras.length === 1 ? ' observação encontrada' : ' observações encontradas');
                
                // Atualizar contadores
                $("#contador-resultados-DT").text(textoContador);
                $("#contador-parenteses-DT").text('(' + textoContador + ')');
                
                // Criar um card para cada observação
                observacoesComPalavras.forEach(function(item, index) {
                    // Destacar todas as palavras selecionadas
                    let observacaoComDestaque = item.observacao;
                    palavras.forEach(palavra => {
                        observacaoComDestaque = destacarPalavra(observacaoComDestaque, palavra, corPalavra);
                    });
                    
                    const processoId = item.processo;
                    const orgaoRespondente = item.orgao_respondente || "Não informado";
                    const orgaoOrigem = item.orgao_origem || "Não informado";
                    
                    const card = criarCardObservacao(processoId, orgaoRespondente, orgaoOrigem, 
                        observacaoComDestaque, index, corPalavra);
                    
                    $("#cards-container-DT").append(card);
                });
                
                // Inicializar tooltips
                $('[data-toggle="tooltip"]').tooltip();
            } else {
                $("#cards-container-DT").html(
                    '<div class="col-12">' +
                        '<div class="alert alert-warning">' +
                            '<i class="fas fa-exclamation-circle mr-2"></i>' +
                            'Nenhuma observação encontrada contendo todas as palavras selecionadas.' +
                        '</div>' +
                    '</div>'
                );
                $("#contador-resultados-DT").text('0 observações');
                $("#contador-parenteses-DT").text('(0 observações encontradas)');
            }
            
            // Rolar até os resultados
            scrollToResultados();
        }
        
        // Função para destacar a palavra na observação
        function destacarPalavra(texto, palavra, corPalavra) {
            if (!texto) return '';
            
            // Converter a cor para hexadecimal
            var hexColor = corPalavra ? rgbToHex(corPalavra) : '#007bff';
            
            // Escapar a palavra para uso seguro na expressão regular
            var palavraEscapada = palavra.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            
            // Criar regex para match com a palavra exata
            var regex = new RegExp('\\b(' + palavraEscapada + ')\\b', 'gi');
            
            // Aplicar a cor junto com o negrito para correspondências
            return texto.replace(regex, '<strong class="palavra-destacada" style="color:' + hexColor + ';">$1</strong>');
        }
        
        // Função para criar um card de observação
        function criarCardObservacao(processoId, orgaoRespondente, orgaoOrigem, observacao, index, corPalavra) {
            // Usar a cor da palavra para estilizar o card
            var styleHeader = '';
            var badgeClass = '';
            
            if (corPalavra) {
                var hexColor = rgbToHex(corPalavra);
                var darkerColor = adjustColor(hexColor, -30);
                
                styleHeader = 'style="background: linear-gradient(135deg, ' + darkerColor + ', ' + hexColor + '); color: #ffffff !important;"';
                badgeClass = 'style="color: ' + hexColor + ' !important; background-color: #ffffff !important; border: 1px solid ' + hexColor + ' !important;"';
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
        
        // Função para rolar até os resultados
        function scrollToResultados() {
            setTimeout(function() {
                $('html, body').animate({
                    scrollTop: $("#resultados-palavra-DT").offset().top - 70
                }, 800, function() {
                    $('.overlay-loading').remove();
                });
            }, 200);
        }
        
        // Botão para fechar resultados
        $("#fechar-resultados-DT").on('click', function() {
            $("#resultados-palavra-DT").hide();
            $("#cards-container-DT").empty();
            $("#palavra-selecionada-DT").text('');
            $("#contador-resultados-DT").text('');
            $("#contador-parenteses-DT").text('');
        });
        
        // Converter RGB para HEX
        function rgbToHex(rgb) {
            if (rgb.startsWith('#')) {
                return rgb;
            }
            
            var rgbArr = rgb.match(/\d+/g);
            if (!rgbArr || rgbArr.length !== 3) {
                return '#007bff';
            }
            
            var r = parseInt(rgbArr[0]);
            var g = parseInt(rgbArr[1]);
            var b = parseInt(rgbArr[2]);
            
            return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
        }
        
        // Ajustar a cor (torná-la mais clara ou escura)
        function adjustColor(hex, percent) {
            hex = hex.replace('#', '');
            
            var r = parseInt(hex.substring(0, 2), 16);
            var g = parseInt(hex.substring(2, 4), 16);
            var b = parseInt(hex.substring(4, 6), 16);
            
            r = Math.max(0, Math.min(255, Math.round(r * (100 + percent) / 100)));
            g = Math.max(0, Math.min(255, Math.round(g * (100 + percent) / 100)));
            b = Math.max(0, Math.min(255, Math.round(b * (100 + percent) / 100)));
            
            return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
        }
        
        // Inicializar a nuvem quando o componente for carregado
        setTimeout(function() {
            window.processarNuvemPalavras(minFreq, maxWords);
        }, 600);
        
        // Atualizar a nuvem quando a tabela for filtrada
        $(document).on('draw.dt', function(e, settings) {
            if (settings.nTable.id === 'tabelaPesquisasDetalhada') {
                window.processarNuvemPalavras(minFreq, maxWords);
            }
        });
        
        // Ajustar a nuvem quando a janela for redimensionada
        $(window).resize(function() {
            if ($("#nuvem-container-DT").data('jqcloud') && window.cloudDataDT) {
                clearTimeout(window.resizeTimeout);
                window.resizeTimeout = setTimeout(function() {
                    try {
                        if ($("#nuvem-container-DT").data('jqcloud')) {
                            $("#nuvem-container-DT").jQCloud('destroy');
                        }
                        
                        $("#nuvem-container-DT").empty();
                        window.cloudOptionsDT.width = $("#nuvem-container-DT").width();
                        $("#nuvem-container-DT").jQCloud(window.cloudDataDT, window.cloudOptionsDT);
                    } catch (e) {
                        console.error("Erro ao redimensionar nuvem:", e);
                    }
                }, 300);
            }
        });
    }
});
</script>
