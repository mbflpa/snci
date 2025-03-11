<cfprocessingdirective pageencoding = "utf-8">
<style>
    .chart-container {
        position: relative;
        margin-bottom: 2rem;
        padding: 0.5rem;
    }
    .chart-title {
        font-size: 1rem;
        margin-bottom: 1rem;
        font-weight: 500;
        color: #333;
        display: flex;
        align-items: center;
    }
    .chart-title i {
        margin-right: 0.5rem;
        color: #007bff;
    }
    .graficos-row {
        min-height: 350px;
    }
    .chart-card {
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        padding: 1rem;
        height: 100%;
        transition: all 0.3s ease;
    }
    .chart-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }
    .legend-item {
        display: inline-flex;
        align-items: center;
        margin-right: 1rem;
        margin-bottom: 0.5rem;
        font-size: 0.8rem;
    }
    .legend-color {
        width: 12px;
        height: 12px;
        border-radius: 2px;
        margin-right: 5px;
    }
    .chart-legend {
        display: flex;
        flex-wrap: wrap;
        margin-top: 0.5rem;
        justify-content: center;
    }
    .no-data {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 200px;
        color: #6c757d;
    }
    .no-data i {
        font-size: 3rem;
        margin-bottom: 1rem;
        opacity: 0.5;
    }
    /* Estilos adicionais para os gráficos */
    .chart-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
    }
    
    .chart-header-title {
        font-size: 1.1rem;
        font-weight: 600;
        color: #495057;
    }
    
    .chart-tooltip {
        position: absolute;
        background: rgba(0,0,0,0.8);
        color: #fff;
        padding: 10px;
        border-radius: 5px;
        pointer-events: none;
        z-index: 10;
        font-size: 14px;
        transform: translate(-50%, -100%);
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .chart-tooltip.active {
        opacity: 1;
    }
    
    /* Estilos para seleção/filtragem nos gráficos */
    .chart-filters {
        display: flex;
        gap: 0.5rem;
        margin-bottom: 1rem;
    }
    
    .chart-filter-btn {
        padding: 0.25rem 0.75rem;
        font-size: 0.8rem;
        border-radius: 20px;
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
        color: #6c757d;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    
    .chart-filter-btn:hover, 
    .chart-filter-btn.active {
        background-color: #007bff;
        border-color: #007bff;
        color: #fff;
    }
    
    /* Responsividade adicional */
    @media (max-width: 768px) {
        .graficos-row {
            min-height: auto;
        }
        
        .chart-container {
            height: 250px;
        }
    }
</style>

<!--- Card para Gráficos --->
<div class="card mb-4" id="card-graficos">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-chart-line mr-2"></i>Gráficos
        </h3>
    </div>
    <div class="card-body">
        <div id="graficos-content">
            <div class="tab-loader">
                <i class="fas fa-spinner fa-spin"></i> Carregando gráficos...
            </div>
            
            <!--- Conteúdo específico do componente de gráficos --->
            <div id="graficos-container" class="row" style="display: none;">
                <div class="col-md-12">
                    <div class="row graficos-row">
                        <div class="col-md-6">
                            <div class="chart-card">
                                <h5 class="chart-title">
                                    <i class="fas fa-chart-line"></i>Evolução Anual de Processos
                                </h5>
                                <div class="chart-container">
                                    <canvas id="evolucaoChart"></canvas>
                                </div>
                                <div id="evolucaoLegend" class="chart-legend"></div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="chart-card">
                                <h5 class="chart-title">
                                    <i class="fas fa-chart-pie"></i>Distribuição por Classificação de Processos
                                </h5>
                                <div class="chart-container">
                                    <canvas id="classificacaoChart"></canvas>
                                </div>
                                <div id="classificacaoLegend" class="chart-legend"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Script para carregar Chart.js se não estiver disponível -->
<script>
// Função para carregar scripts de forma assíncrona
function carregarScript(url, callback) {
    // Verificar se o script já está carregado
    var scripts = document.getElementsByTagName('script');
    for (var i = 0; i < scripts.length; i++) {
        if (scripts[i].src == url) {
            if (callback) callback();
            return;
        }
    }

    // Criar o elemento script
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = url;
    script.onload = callback;
    script.onerror = function() {
        console.error('Erro ao carregar: ' + url);
    };
    document.head.appendChild(script);
}

// Namespace global para o componente de gráficos
var DashboardGraficos = (function() {
    // Variáveis privadas
    var evolucaoChart = null;
    var classificacaoChart = null;
    var dadosGlobais = null;
    var componenteInicializado = false;
    var chartJsCarregado = false;
    
    // Cores para os gráficos
    var coresPadrao = [
        '#007bff', // azul
        '#6f42c1', // roxo
        '#fd7e14', // laranja
        '#20c997', // verde-água
        '#e83e8c', // rosa
        '#17a2b8', // ciano
        '#28a745', // verde
        '#ffc107', // amarelo
        '#dc3545'  // vermelho
    ];
    
    // Funções privadas
    function verificarDependencias(callback) {
        // Verificar se Chart.js está disponível
        if (typeof Chart === 'undefined') {
            console.log("Chart.js não encontrado. Carregando...");
            carregarScript('plugins/chart.js/Chart.min.js', function() {
                chartJsCarregado = true;
                if (callback) callback();
            });
        } else {
            chartJsCarregado = true;
            if (callback) callback();
        }
    }
    
    function renderEvolucaoChart(dados) {
        const ctx = document.getElementById('evolucaoChart').getContext('2d');
        
        // Se não houver dados, mostrar mensagem
        if (!dados || dados.length === 0) {
            // Limpar a canvas atual
            if (evolucaoChart) {
                evolucaoChart.destroy();
                evolucaoChart = null;
            }
            
            $(ctx.canvas).parent().html('<div class="no-data"><i class="fas fa-chart-line"></i><p>Não há dados disponíveis para mostrar</p></div>');
            return;
        }
        
        // Agrupar dados por ano para evolução anual
        const dadosPorAno = {};
        dados.forEach(d => {
            // Extrair o ano da string de período (formato dd/mm/yyyy)
            let partes = d.periodo.split('/');
            let ano = partes[2];
            
            if (!dadosPorAno[ano]) {
                dadosPorAno[ano] = 0;
            }
            dadosPorAno[ano] += parseInt(d.quantidade);
        });
        
        // Converter para arrays para o gráfico
        const labels = Object.keys(dadosPorAno).sort();
        const quantidades = labels.map(ano => dadosPorAno[ano]);
        
        // Se o gráfico já existe, atualizá-lo
        if (evolucaoChart) {
            evolucaoChart.data.labels = labels;
            evolucaoChart.data.datasets[0].data = quantidades;
            evolucaoChart.update();
            return;
        }
        
        // Criar um novo gráfico com visual melhorado
        evolucaoChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Quantidade de Processos', 
                    data: quantidades,
                    backgroundColor: function(context) {
                        const chart = context.chart;
                        const {ctx, chartArea} = chart;
                        if (!chartArea) {
                            return 'rgba(0, 123, 255, 0.7)';
                        }
                        const gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top);
                        gradient.addColorStop(0, 'rgba(0, 123, 255, 0.6)');
                        gradient.addColorStop(1, 'rgba(0, 123, 255, 0.9)');
                        return gradient;
                    },
                    borderColor: '#007bff',
                    borderWidth: 1,
                    barPercentage: 0.7,
                    categoryPercentage: 0.8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                layout: {
                    padding: {
                        top: 40,
                        right: 20,
                        bottom: 40,
                        left: 10
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)',
                            drawBorder: false
                        },
                        ticks: {
                            precision: 0,
                            font: {
                                size: 12
                            }
                        },
                        title: {
                            display: false
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            font: {
                                size: 12,
                                weight: 'bold'
                            }
                        },
                        title: {
                            display: false
                        }
                    }
                },
                // Em Chart.js v2.9.4, a legenda está no nível raiz das opções, não em plugins
                legend: {
                    display: true,
                    position: 'bottom',
                    labels: {
                        boxWidth: 15,
                        fontSize: 12,
                        padding: 15
                    }
                },
                tooltips: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleFontSize: 14,
                    titleFontStyle: 'bold',
                    bodyFontSize: 13,
                    padding: 12,
                    displayColors: false,
                    callbacks: {
                        title: function(tooltipItems) {
                            return 'Ano ' + tooltipItems[0].label;
                        },
                        label: function(context) {
                            return 'Total de Processos: ' + context.raw;
                        }
                    }
                },
                animation: {
                    duration: 1500,
                    easing: 'easeOutQuart'
                }
            },
            plugins: [{
                id: 'datalabels',
                afterDatasetsDraw: function(chart) {
                    const ctx = chart.ctx;
                    
                    chart.data.datasets.forEach(function(dataset, i) {
                        const meta = chart.getDatasetMeta(i);
                        
                        if (!meta.hidden) {
                            meta.data.forEach(function(element, index) {
                                // Configuração do texto
                                ctx.fillStyle = '#333';
                                ctx.font = 'bold 14px Arial';
                                ctx.textAlign = 'center';
                                
                                // Obter o valor para mostrar
                                const value = dataset.data[index];
                                
                                // Calcular a posição exata
                                const position = element.tooltipPosition();
                                
                                // Desenhar o valor acima da barra
                                ctx.fillText(value, position.x, position.y - 15);
                            });
                        }
                    });
                }
            }]
        });
    }
    
    function renderClassificacaoChart(dados, total) {
        const ctx = document.getElementById('classificacaoChart').getContext('2d');
        
        // Se não houver dados, mostrar mensagem
        if (!dados || dados.length === 0) {
            // Limpar a canvas atual
            if (classificacaoChart) {
                classificacaoChart.destroy();
                classificacaoChart = null;
            }
            
            $(ctx.canvas).parent().html('<div class="no-data"><i class="fas fa-chart-pie"></i><p>Não há dados disponíveis para mostrar</p></div>');
            return;
        }
        
        // Preparar dados para o gráfico
        const labels = dados.map(d => d.descricao);
        const quantidades = dados.map(d => d.quantidade);
        
        // Limitar quantidade de categorias visíveis para evitar sobrecarga
        const maxVisibleCategories = 7;
        let visibleLabels = [...labels];
        let visibleQuantidades = [...quantidades];
        let visibleCores = coresPadrao.slice(0, Math.min(labels.length, maxVisibleCategories));
        
        // Se houver mais categorias que o máximo, agrupar as menores em "Outros"
        if (labels.length > maxVisibleCategories) {
            // Ordenar dados por quantidade (decrescente)
            let dadosOrdenados = dados.slice().sort((a, b) => b.quantidade - a.quantidade);
            
            // Pegar as principais categorias
            visibleLabels = dadosOrdenados.slice(0, maxVisibleCategories - 1).map(d => d.descricao);
            visibleQuantidades = dadosOrdenados.slice(0, maxVisibleCategories - 1).map(d => d.quantidade);
            
            // Calcular "Outros"
            const outrasQuantidades = dadosOrdenados.slice(maxVisibleCategories - 1).reduce((acc, curr) => acc + curr.quantidade, 0);
            visibleLabels.push('Outros');
            visibleQuantidades.push(outrasQuantidades);
            visibleCores.push('#6c757d'); // Cor cinza para "Outros"
        }
        
        // Preparar os rótulos com quantidade e percentual
        const formattedLabels = visibleLabels.map((label, index) => {
            const percentage = ((visibleQuantidades[index] / total) * 100).toFixed(1);
            return `${label} (${visibleQuantidades[index]} - ${percentage}%)`;
        });
        
        // Se o gráfico já existe, atualizá-lo
        if (classificacaoChart) {
            classificacaoChart.data.labels = formattedLabels;
            classificacaoChart.data.datasets[0].data = visibleQuantidades;
            classificacaoChart.update();
            return;
        }
        
        // Criar um novo gráfico
        classificacaoChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: formattedLabels,
                datasets: [{
                    data: visibleQuantidades,
                    backgroundColor: visibleCores,
                    borderWidth: 1,
                    borderColor: '#fff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '60%',
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: {
                            boxWidth: 10,
                            font: {
                                size: 11
                            },
                            padding: 10
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        titleFont: {
                            size: 14,
                            weight: 'bold'
                        },
                        bodyFont: {
                            size: 13
                        },
                        padding: 12,
                        callbacks: {
                            label: function(context) {
                                return context.label;
                            }
                        }
                    }
                },
                animation: {
                    animateRotate: true,
                    animateScale: true
                }
            },
            plugins: [{
                id: 'doughnutLabels',
                afterDraw: function(chart) {
                    const ctx = chart.ctx;
                    const total = chart.data.datasets[0].data.reduce((sum, value) => sum + value, 0);
                    
                    // Cálculo do centro do gráfico
                    const width = chart.chartArea.right - chart.chartArea.left;
                    const height = chart.chartArea.bottom - chart.chartArea.top;
                    const centerX = chart.chartArea.left + width / 2;
                    const centerY = chart.chartArea.top + height / 2;
                    
                    // Configuração para texto no centro do gráfico
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    
                    // Texto para o total
                    ctx.font = 'bold 16px Arial';
                    ctx.fillStyle = '#333';
                    ctx.fillText('Total', centerX, centerY - 15);
                    
                    // Valor total
                    ctx.font = 'bold 22px Arial';
                    ctx.fillStyle = '#007bff';
                    ctx.fillText(total, centerX, centerY + 15);
                }
            }]
        });
        
        $('#classificacaoLegend').html('');
    }
    
    // API pública
    return {
        // Inicializa o componente verificando/carregando dependências
        init: function() {
            if (componenteInicializado) return;
            
            verificarDependencias(function() {
                console.log("Componente de gráficos inicializado");
                componenteInicializado = true;
                
                // Mostrar o container de gráficos e esconder o loader
                $("#graficos-content .tab-loader").hide();
                $("#graficos-container").show();
                
                // Se já temos dados, mostrar os gráficos
                if (dadosGlobais) {
                    DashboardGraficos.atualizarGraficos(dadosGlobais);
                }
                
                // Inicializar o ícone de favorito se a função existir
                if (typeof initFavoriteIcon === 'function') {
                    const cardId = 'card-graficos';
                    const componentPath = 'includes/pc_dashboard_processo/pc_dashboard_graficos_processo.cfm';
                    const componentTitle = 'Indicadores de Processos';
                    initFavoriteIcon(cardId, componentPath, componentTitle);
                }
            });
        },
        
        // Carrega dados via AJAX usando os parâmetros fornecidos
        carregarDados: function(params) {
            console.log("Carregando dados para gráficos");
            
            // Remover indicador de carregamento
            $("#graficos-content .tab-loader").show();
            $("#graficos-container").hide();
            
            // Definir parâmetros padrão se não fornecidos
            params = params || {};
            var ano = params.ano || window.anoSelecionado || "Todos";
            var mcuOrigem = params.mcuOrigem || window.mcuSelecionado || "Todos";
            var statusFiltro = params.statusFiltro || "Todos";
            
            // Fazer a chamada AJAX para buscar os dados
            $.ajax({
                url: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
                method: 'POST',
                data: { 
                    ano: ano,
                    mcuOrigem: mcuOrigem,
                    statusFiltro: statusFiltro
                },
                dataType: 'json',
                success: function(dados) {
                    console.log("Dados recebidos para gráficos:", dados);
                    
                    // Atualizar os gráficos com os dados recebidos
                    DashboardGraficos.atualizarGraficos(dados);
                },
                error: function(xhr, status, error) {
                    console.error("Erro ao carregar dados para gráficos:", error);
                    $("#graficos-content .tab-loader").hide();
                    $("#graficos-container").html('<div class="alert alert-danger">Erro ao carregar dados: ' + error + '</div>').show();
                }
            });
        },
        
        // Atualiza os gráficos com os dados fornecidos
        atualizarGraficos: function(dados) {
            // Armazenar os dados globalmente
            dadosGlobais = dados;
            
            // Se o componente ainda não foi inicializado, inicialize-o primeiro
            if (!componenteInicializado) {
                this.init();
                return;
            }
            
            if (!chartJsCarregado) {
                console.log("Chart.js ainda não carregado. Aguardando...");
                setTimeout(function() {
                    DashboardGraficos.atualizarGraficos(dados);
                }, 500);
                return;
            }
            
            // Remove indicador de carregamento
            $("#graficos-content .tab-loader").hide();
            
            // Mostra o container de gráficos
            $("#graficos-container").show();
            
            if (!dados) return;
            
            console.log("Atualizando gráficos com dados:", dados);
            
            // Renderizar ou atualizar os gráficos
            renderEvolucaoChart(dados.evolucaoMensal);
            renderClassificacaoChart(dados.distribuicaoClassificacao, dados.totalProcessos);
        }
    };
})();

// Inicializar o componente quando a página carregar
$(document).ready(function() {
    // Iniciar o componente
    DashboardGraficos.init();
    
    // Registrar o componente para receber atualizações da página hospedeira (compatibilidade)
    if (typeof window.atualizarDadosComponentes === 'undefined') {
        window.atualizarDadosComponentes = [];
    }
    
    // Adicionar a função de atualização ao array global
    if (!window.atualizarDadosComponentes.includes(DashboardGraficos.atualizarGraficos)) {
        window.atualizarDadosComponentes.push(DashboardGraficos.atualizarGraficos);
    }
    
    // Compatibilidade com o sistema de notificação de carregamento existente
    if (typeof window.componentesCarregados !== 'undefined') {
        window.componentesCarregados.graficos = true;
        
        // Chamar atualização se necessário
        if (window.componentesCarregados.orgaosView && typeof window.atualizarDados === 'function') {
            window.atualizarDados();
        }
    } else {
        // Se não existe o sistema de notificação, tentar carregar dados independentemente
        setTimeout(function() {
            // Verificar variáveis globais primeiro
            var params = {};
            if (typeof window.anoSelecionado !== 'undefined') params.ano = window.anoSelecionado;
            if (typeof window.mcuSelecionado !== 'undefined') params.mcuOrigem = window.mcuSelecionado;
            
            // Carregar dados se temos parâmetros
            if (Object.keys(params).length > 0) {
                DashboardGraficos.carregarDados(params);
            }
        }, 1000);
    }
    
    // Compatibilidade com interface antiga
    window.atualizarGraficos = DashboardGraficos.atualizarGraficos;
});
</script>
