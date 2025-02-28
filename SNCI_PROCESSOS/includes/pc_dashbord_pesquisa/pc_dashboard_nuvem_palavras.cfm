<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_NuvemPalavras.css">

<div class="card">
  <div class="card-header">
    <h5 class="card-title">Palavras mais frequentes nas observações das Pesquisas</h5>
  </div>
  <div class="card-body">
    <!-- Card explicativo sobre a importância da nuvem de palavras -->
    <div class="card mb-4 border-left border-primary" style="border-left-width: 4px !important; border-left-color: #4e73df !important;border-radius: 8px!important;">
      <div class="card-body">
        <p>Este recurso analisa todas as observações textuais deixadas nas pesquisas, permitindo identificar tendências, preocupações e temas comuns mencionados pelos respondentes. O tamanho de cada palavra reflete sua frequência nas observações, oferecendo uma visão rápida dos principais assuntos abordados.</p>
        <p class="mb-0 text-muted"><small>Passe o mouse sobre uma palavra para ver detalhes sobre sua frequência e relevância.</small></p>
      </div>
    </div>
    
    <!-- Filtros da nuvem de palavras - Reorganizados em linha única -->
    <div class="controls-container d-flex align-items-center flex-wrap mb-3">
      <div class="control-group d-flex align-items-center mr-2">
        <label class="mb-0 mr-2">Frequência mínima:</label>
        <input type="number" class="form-control form-control-sm" id="minFreq" value="2" min="1" max="100">
      </div>
      <div class="control-group d-flex align-items-center mr-2">
        <label class="mb-0 mr-2">Máximo de palavras:</label>
        <input type="number" class="form-control form-control-sm" id="maxWords" value="100" min="10" max="300">
      </div>
      <button id="atualizarNuvem" class="btn btn-primary btn-sm">
        <i class="fas fa-sync-alt mr-1"></i> Atualizar Nuvem
      </button>
    </div>
    
    <div class="word-cloud-container position-relative">
      <div id="loadingCloud" style="display: none;">
        <i class="fas fa-spinner fa-spin mr-2"></i> Carregando...
      </div>
      <div id="wordCloud"></div>
    </div>
    
    <!-- Removido: div palavra-info e card de detalhes da palavra -->
  </div>
</div>

<script>
$(document).ready(function() {
    let palavrasData;
    let maxFrequency = 0;
    let carregandoNuvem = false; // Flag para evitar chamadas simultâneas
    
    // Função melhorada para fechar o modal de forma segura
    function fecharModalComSeguranca() {
        try {
            $('#modalOverlay').modal('hide');
            
            setTimeout(function() {
                if ($('#modalOverlay').is(':visible') || $('body').hasClass('modal-open')) {
                    $('.modal-backdrop').remove();
                    $('body').removeClass('modal-open');
                    $('body').css('padding-right', '');
                    $('#modalOverlay').removeClass('show');
                    $('#modalOverlay').css('display', 'none');
                }
            }, 500);
        } catch (e) {
            console.error("Erro ao fechar modal:", e);
            $('.modal-backdrop').remove();
            $('body').removeClass('modal-open');
            $('#modalOverlay').hide();
        }
    }
    
    // Função para carregar dados da nuvem de palavras
    window.carregarNuvemPalavras = function() {
        // Evitar múltiplas chamadas simultâneas
        if (carregandoNuvem) {
            return;
        }
        
        carregandoNuvem = true;
        
        // Obter o ano e o mcu selecionados
        const ano = $("input[name='opcaoAno']:checked").val();
        const mcuOrigem = $("input[name='opcaoMcu']:checked").val();
        const minFreq = $("#minFreq").val() || 1;
        const maxWords = $("#maxWords").val() || 100;
        
          
        // Verificar se a aba está ativa
        if (!$("#nuvem-palavras").hasClass('active') && !$("#nuvem-palavras").hasClass('show')) {
            carregandoNuvem = false;
            return;
        }
        
        $("#wordCloud").empty();
        $("#loadingCloud").show();
        
        // Verificações
        if (!ano) {
            $("#wordCloud").html('<div class="alert alert-warning">Por favor, selecione um ano para visualizar a nuvem de palavras.</div>');
            $("#loadingCloud").hide();
            carregandoNuvem = false;
            return;
        }
        
        // Garantir que o container tenha dimensões
        const containerWidth = $("#wordCloud").parent().width();
        if (!containerWidth) {
            setTimeout(function() {
                carregandoNuvem = false;
                window.carregarNuvemPalavras();
            }, 500);
            return;
        }
        
        $.ajax({
            url: "cfc/pc_cfcPesquisasDashboard.cfc?method=getWordCloud&returnformat=json",
            type: "GET",
            dataType: "json",
            data: {
                ano: ano,
                mcuOrigem: mcuOrigem,
                minFreq: minFreq,
                maxWords: maxWords
            },
            success: function(response) {
                carregandoNuvem = false;

                // Verificar se a resposta é válida
                if (!response || typeof response !== 'object') {
                    $("#wordCloud").html('<div class="alert alert-warning">Resposta inválida do servidor.</div>');
                    $("#loadingCloud").hide();
                    return;
                }
                
                palavrasData = response;
                
                if (!Array.isArray(palavrasData) || palavrasData.length === 0) {
                    $("#wordCloud").html('<div class="alert alert-info">Nenhuma palavra encontrada para os critérios selecionados.</div>');
                    $("#loadingCloud").hide();
                    return;
                }
                
                // Encontrar a maior frequência para cálculos de relevância
                maxFrequency = Math.max(...palavrasData.map(p => p.weight || 0));
                
                // Definir esquema de cores baseado no peso das palavras
                const getWordColor = function(weight) {
                    // Calcular percentual em relação ao peso máximo
                    const percentage = weight / maxFrequency;
                    
                    // Esquema de cores do mais frequente para o menos frequente
                    if (percentage > 0.8) return "#FF5733"; // Vermelho para palavras muito frequentes
                    if (percentage > 0.6) return "#FFA500"; // Laranja
                    if (percentage > 0.4) return "#33A8FF"; // Azul
                    if (percentage > 0.2) return "#4CAF50"; // Verde
                    return "#9C27B0";                       // Roxo para palavras menos frequentes
                };
                
                // Garantir que os dados estejam no formato esperado pelo jQCloud
                const dadosFormatados = palavrasData.map(function(item) {
                    const weight = parseFloat(item.weight) || 1;
                    const relevancia = ((weight / maxFrequency) * 100).toFixed(1);
                    
                    return {
                        text: item.text || "",
                        weight: weight,
                        color: getWordColor(weight),
                        html: { 
                            'data-toggle': 'popover',
                            'data-content': `Frequência: ${weight} | Relevância: ${relevancia}%`,
                            'data-placement': 'top',
                            'data-trigger': 'hover',
                            'data-container': 'body'
                        }
                    };
                });
                
                // Inicializar nuvem de palavras
                try {
                    $("#wordCloud").jQCloud('destroy');
                } catch(e) { /* Ignora se não existir */ }
                
                $("#wordCloud").jQCloud(dadosFormatados, {
                    width: $("#wordCloud").parent().width(),
                    height: 300,
                    delay: 50,
                    shape: 'elliptic',
                    colors: ["#9C27B0", "#4CAF50", "#33A8FF", "#FFA500", "#FF5733"],
                    afterCloudRender: function() {
                        // Inicializar popovers para todas as palavras
                        $(".jqcloud-word").popover({
                            html: true,
                            container: 'body'
                        });
                        
                        $("#loadingCloud").hide();
                    }
                });
            },
            error: function(xhr, status, error) {
                carregandoNuvem = false;
                
                console.error("Erro ao carregar dados da nuvem:", error);
                $("#wordCloud").html(`<div class="alert alert-danger">
                    <strong>Erro ao carregar a nuvem de palavras.</strong><br>
                    Detalhes: ${error || "Sem detalhes disponíveis"}<br>
                    Por favor, verifique o console para mais informações.
                </div>`);
                $("#loadingCloud").hide();
            }
        });
    };
    
    // Evento do botão atualizar nuvem
    $("#atualizarNuvem").click(function() {
        carregarNuvemPalavras();
    });
    
    // Adicionar ouvintes globais para atualizações nos filtros
    $(document).on('change', "input[name='opcaoAno'], input[name='opcaoMcu']", function() {
        // Verificar se a aba da nuvem está visível antes de atualizar
        if ($("#nuvem-palavras").hasClass('active') || $("#nuvem-palavras").hasClass('show')) {
            setTimeout(function() {
                carregarNuvemPalavras(false);
            }, 100);
        }
    });
    
    // Inicializar a nuvem quando o componente for carregado
    setTimeout(function() {
        if ($("#nuvem-palavras").hasClass('active') || $("#nuvem-palavras").hasClass('show')) {
            carregarNuvemPalavras(false);
        }
    }, 500);
    
    // Responsividade - redimensionar a nuvem quando a janela mudar de tamanho
    $(window).resize(function() {
        if (palavrasData && palavrasData.length > 0) {
            try {
                $("#wordCloud").jQCloud('destroy');
            } catch(e) { /* Ignora se não existir */ }
            
            // Recalcular dados com cores
            const dadosFormatados = palavrasData.map(function(item) {
                const weight = parseFloat(item.weight) || 1;
                const percentage = weight / maxFrequency;
                const relevancia = (percentage * 100).toFixed(1);
                let color = "#9C27B0";
                
                if (percentage > 0.8) color = "#FF5733";
                else if (percentage > 0.6) color = "#FFA500";
                else if (percentage > 0.4) color = "#33A8FF";
                else if (percentage > 0.2) color = "#4CAF50";
                
                return {
                    text: item.text || "",
                    weight: weight,
                    color: color,
                    html: { 
                        'data-toggle': 'popover',
                        'data-content': `Frequência: ${weight} | Relevância: ${relevancia}%`,
                        'data-placement': 'top',
                        'data-trigger': 'hover',
                        'data-container': 'body'
                    }
                };
            });
            
            $("#wordCloud").jQCloud(dadosFormatados, {
                width: $("#wordCloud").parent().width(),
                height: 300,
                colors: ["#9C27B0", "#4CAF50", "#33A8FF", "#FFA500", "#FF5733"],
                afterCloudRender: function() {
                    // Inicializar popovers
                    $(".jqcloud-word").popover({
                        html: true,
                        container: 'body'
                    });
                }
            });
        }
    });
});
</script>
