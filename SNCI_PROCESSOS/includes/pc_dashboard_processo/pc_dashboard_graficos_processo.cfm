<cfprocessingdirective pageencoding = "utf-8">
<!-- Carregamento direto do CSS específico do componente -->
<link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Graficos.css">

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
            <div id="graficos-container" class="row">
                <div class="col-md-6">
                    <div class="chart-card">
                        <h5 class="chart-title">
                            <i class="fas fa-chart-line"></i>Evolução Anual de Processos
                        </h5>
                        <div class="chart-container">
                            <!-- O canvas será criado dinamicamente aqui -->
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
                            <!-- O canvas será criado dinamicamente aqui -->
                        </div>
                        <div id="classificacaoLegend" class="chart-legend"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Carregar o componente base se ainda não foi carregado
if (typeof DashboardComponentFactory === 'undefined') {
    document.write('<script src="dist/js/snciDashboardComponent.js"><\/script>');
}

// Definir o componente de gráficos usando a fábrica
document.addEventListener("DOMContentLoaded", function() {
    // Esperar pelo carregamento da biblioteca de componentes
    var checkComponentLibrary = setInterval(function() {
        if (typeof DashboardComponentFactory !== 'undefined') {
            clearInterval(checkComponentLibrary);
            initGraficosComponent();
        }
    }, 100);

    // Inicializar o componente de gráficos
    function initGraficosComponent() {
        // Variáveis privadas
        var evolucaoChart = null;
        var classificacaoChart = null;
        
        // Gerar IDs únicos para este componente para evitar conflitos
        var componentId = 'graficos-' + Date.now();
        var evolucaoChartId = 'evolucaoChart-' + componentId;
        var classificacaoChartId = 'classificacaoChart-' + componentId;
        
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
        
        // Criar a instância do componente
        var DashboardGraficos = DashboardComponentFactory.criar({
            nome: 'GraficosProcessos',
            dependencias: ['plugins/chart.js/Chart.min.js'],
            containerId: 'graficos-container',
            cardId: 'card-graficos',
            path: 'includes/pc_dashboard_processo/pc_dashboard_graficos_processo.cfm',
            titulo: 'Indicadores de Processos',
            notificationKey: 'graficos',
            notificationCheck: 'window.componentesCarregados && window.componentesCarregados.orgaosView',
            debug: true
        });
        
        // Verificar e configurar os elementos canvas com IDs únicos
        function prepararElementosGrafico() {
            // Primeiro, verificar se os containers existem
            var chartContainers = document.querySelectorAll('#graficos-container .chart-container');
            
            if (!chartContainers || chartContainers.length < 2) {
                console.error("Containers dos gráficos não encontrados. Total encontrado: " + 
                    (chartContainers ? chartContainers.length : 0));
                
                // Forçar a exibição do container para debugar
                if ($("#graficos-container").length) {
                                        
                    // Forçar exibição para que possamos acessar elementos filhos
                    $("#graficos-container").show();
                } else {
                    console.error("O container principal #graficos-container não existe no DOM");
                }
                
                return false;
            }
            
            // Obter os containers corretos usando índices
            var evolucaoContainer = chartContainers[0];
            var classificacaoContainer = chartContainers[1];
            
            // Verificar se os canvas existem, senão criar novos com IDs únicos
            var evolucaoCanvas = evolucaoContainer.querySelector('canvas');
            var classificacaoCanvas = classificacaoContainer.querySelector('canvas');
            
            if (evolucaoCanvas) {
                evolucaoCanvas.id = evolucaoChartId;
            } else {
                evolucaoCanvas = document.createElement('canvas');
                evolucaoCanvas.id = evolucaoChartId;
                evolucaoContainer.appendChild(evolucaoCanvas);
            }
            
            if (classificacaoCanvas) {
                classificacaoCanvas.id = classificacaoChartId;
            } else {
                classificacaoCanvas = document.createElement('canvas');
                classificacaoCanvas.id = classificacaoChartId;
                classificacaoContainer.appendChild(classificacaoCanvas);
            }
            
            // Atualizar os IDs dos containers de legendas também
            var evolucaoLegend = document.getElementById('evolucaoLegend');
            var classificacaoLegend = document.getElementById('classificacaoLegend');
            
            if (evolucaoLegend) evolucaoLegend.id = 'evolucaoLegend-' + componentId;
            if (classificacaoLegend) classificacaoLegend.id = 'classificacaoLegend-' + componentId;
            
            return true;
        }
        
        // Funções privadas para renderização dos gráficos
        function renderEvolucaoChart(dados) {
            var canvas = document.getElementById(evolucaoChartId);
            if (!canvas) {
                console.error("Canvas para gráfico de evolução não encontrado");
                return;
            }
            
            const ctx = canvas.getContext('2d');
            
            // Se não houver dados, mostrar mensagem
            if (!dados || dados.length === 0) {
                // Limpar a canvas atual
                if (evolucaoChart) {
                    evolucaoChart.destroy();
                    evolucaoChart = null;
                }
                
                $(canvas).parent().html('<div class="no-data"><i class="fas fa-chart-line"></i><p>Não há dados disponíveis para mostrar</p></div>');
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
            var canvas = document.getElementById(classificacaoChartId);
            if (!canvas) {
                console.error("Canvas para gráfico de classificação não encontrado");
                return;
            }
            
            const ctx = canvas.getContext('2d');
            
            // Se não houver dados, mostrar mensagem
            if (!dados || dados.length === 0) {
                // Limpar a canvas atual
                if (classificacaoChart) {
                    classificacaoChart.destroy();
                    classificacaoChart = null;
                }
                
                $(canvas).parent().html('<div class="no-data"><i class="fas fa-chart-pie"></i><p>Não há dados disponíveis para mostrar</p></div>');
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
            
            // Limpar qualquer conteúdo de legenda existente
            var legendContainer = document.getElementById('classificacaoLegend-' + componentId);
            if (legendContainer) {
                $(legendContainer).html('');
            }
        }
        
        // Sobrescrever método de atualização com a função específica deste componente
        DashboardGraficos.atualizar = function(dados) {
            if (!dados) return DashboardGraficos;
            
            // Remove indicador de carregamento
            $("#graficos-content .tab-loader").hide();
            
            // Mostra o container de gráficos
            $("#graficos-container").show();
            
          
            
            // Pequeno delay para garantir que o DOM tenha sido renderizado
            setTimeout(function() {
                // Configurar os elementos dos gráficos antes de renderizar
                if (!prepararElementosGrafico()) {
                    console.error("Não foi possível preparar os elementos para os gráficos");
                    return;
                }
                
                // Renderizar ou atualizar os gráficos
                if (dados.evolucaoMensal) {
                    renderEvolucaoChart(dados.evolucaoMensal);
                }
                
                if (dados.distribuicaoClassificacao) {
                    renderClassificacaoChart(dados.distribuicaoClassificacao, dados.totalProcessos);
                }
            }, 50);
            
            return DashboardGraficos;
        };
        
        // Inicializar e registrar o componente
        DashboardGraficos.init().registrar();
        
        // Compatibilidade com interface antiga
        window.DashboardGraficos = DashboardGraficos;
        window.atualizarGraficos = DashboardGraficos.atualizar;
        
        // Carregar dados depois de um tempo, se não estiverem disponíveis
        setTimeout(function() {
            // Verificar variáveis globais primeiro
            var params = {};
            if (typeof window.anoSelecionado !== 'undefined') params.ano = window.anoSelecionado;
            if (typeof window.mcuSelecionado !== 'undefined') params.mcuOrigem = window.mcuSelecionado;
            
            // Carregar dados se temos parâmetros e não foram atualizados ainda
            if (Object.keys(params).length > 0 && !$('#graficos-container').is(':visible')) {
                DashboardGraficos.carregarDados(params);
            } else if (window.dadosAtuais) {
                // Se já temos dados globais, usar eles
                DashboardGraficos.atualizar(window.dadosAtuais);
            }
        }, 1000);
    }
});
</script>
