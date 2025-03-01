<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_NuvemPalavras.css">

<!-- Conteúdo da aba Nuvem de Palavras -->
<div class="row">
  <!-- Card explicativo -->
  <div class="col-md-3 d-flex">
    <div class="card mb-3 card-same-height w-100">
      <div class="card-header">
        <h5 class="card-title">Sobre a Nuvem de Palavras</h5>
      </div>
      <div class="card-body card-body-flex">
        <div class="flex-grow-1">
          <p style="text-align: justify;">A nuvem de palavras é uma representação visual das palavras mais frequentes encontradas nas observações das pesquisas.</p>
          <p style="text-align: justify;">Palavras maiores indicam termos que aparecem com mais frequência. Este recurso ajuda a identificar rapidamente os temas mais recorrentes nas observações.</p>
        </div>
        <!-- Controles para ajustar a nuvem de palavras -->
        <div class="mt-auto">
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
  <div class="col-md-9 d-flex">
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

<script>
$(document).ready(function() {
    // Variáveis de configuração
    var minFreq = 2;
    var maxWords = 100;
    
    // Atualizar valores exibidos nos labels dos sliders
    $('#minFreqSlider').on('input', function() {
        minFreq = parseInt($(this).val());
        $('#minFreqValue').text(minFreq);
    });
    
    $('#maxWordsSlider').on('input', function() {
        maxWords = parseInt($(this).val());
        $('#maxWordsValue').text(maxWords);
    });
    
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
                
                // CORRIGIDO: Limpar o conteúdo antes de renderizar a nuvem
                $("#nuvem").empty();
                
                if (data && data.length > 0) {
                    // Usar setTimeout para dar tempo ao DOM de atualizar
                    setTimeout(function() {
                        $("#nuvem").jQCloud(data, {
                            width: $("#nuvem").width(),
                            height: 400,
                            autoResize: true,
                            delay: 50,
                            shape: 'rectangular',
                            colors: ["#17a2b8", "#28a745", "#ffc107", "#fd7e14", "#20c997", "#6f42c1", "#e83e8c"],
                            // Adicionar o evento afterCloudRender para configurar popovers
                            afterCloudRender: function() {
                                // Remover popovers antigos
                                $('.jqcloud-word[data-toggle="popover"]').popover('dispose');
                                
                                // Configurar popovers em cada palavra
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
                                        
                                        word.attr('data-toggle', 'popover');
                                        word.attr('data-placement', 'top');
                                        word.attr('data-trigger', 'hover');
                                        word.attr('title', wordText);
                                        word.attr('data-content', 'Frequência: ' + frequency + '<br>Relevância: ' + relevancia);
                                        word.attr('data-html', 'true');
                                    }
                                });
                                
                                // Inicializar popovers
                                $('[data-toggle="popover"]').popover();
                            }
                        });
                    }, 100);
                } else {
                    $("#nuvem").html('<div class="text-center p-5"><i class="fas fa-comment-slash fa-3x"></i><p class="mt-3">Não foram encontradas observações para gerar a nuvem de palavras.</p></div>');
                }
            },
            error: function(xhr, status, error) {
                console.error("Erro ao carregar nuvem de palavras:", error);
                $("#nuvem").html('<div class="text-center p-5"><i class="fas fa-exclamation-triangle fa-3x text-danger"></i><p class="mt-3 text-danger">Erro ao carregar dados da nuvem de palavras.</p></div>');
            }
        });
    };
    
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
            // Verificar se o elemento nuvem existe e se tem dados jQCloud associados
            if ($("#nuvem").length && $("#nuvem").data('jqcloud')) {
                try {
                    $("#nuvem").jQCloud('update');
                    
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
        }
    });
});
</script>
