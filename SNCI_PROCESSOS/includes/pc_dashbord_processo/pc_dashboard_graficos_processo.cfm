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
</style>

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

<script>
$(document).ready(function() {
    // Variáveis para armazenar as instâncias dos gráficos
    var evolucaoChart = null;
    var classificacaoChart = null;
    
    // Cores para os gráficos
    const coresPadrao = [
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
    
    // Função para criar ou atualizar o gráfico de evolução anual com visual melhorado
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
                    label: 'Processos por Ano',
                    data: quantidades,
                    backgroundColor: 'rgba(0, 123, 255, 0.7)',
                    borderColor: '#007bff',
                    borderWidth: 1,
                    barPercentage: 0.7,
                    categoryPercentage: 0.8,
                    // Adicionar gradiente
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
                    // Adicionar sombra
                    shadowColor: 'rgba(0, 0, 0, 0.1)',
                    shadowBlur: 10,
                    shadowOffsetX: 0,
                    shadowOffsetY: 5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                layout: {
                    padding: {
                        top: 20,
                        right: 20,
                        bottom: 10,
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
                            display: true,
                            text: 'Quantidade de Processos',
                            font: {
                                size: 14,
                                weight: 'bold'
                            },
                            padding: {top: 10, bottom: 10}
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
                            display: true,
                            text: 'Ano',
                            font: {
                                size: 14,
                                weight: 'bold'
                            },
                            padding: {top: 10, bottom: 10}
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
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
                        displayColors: false,
                        callbacks: {
                            title: function(tooltipItems) {
                                return 'Ano ' + tooltipItems[0].label;
                            },
                            label: function(context) {
                                return 'Total de Processos: ' + context.raw;
                            }
                        }
                    }
                },
                animation: {
                    duration: 1500,
                    easing: 'easeOutQuart'
                }
            },
            plugins: [{
                // Adicionar labels com valores acima das barras
                id: 'chartLabels',
                afterDatasetsDraw(chart) {
                    const {ctx, data, scales} = chart;
                    chart.data.datasets.forEach((dataset, datasetIndex) => {
                        const meta = chart.getDatasetMeta(datasetIndex);
                        if (!meta.hidden) {
                            meta.data.forEach((element, index) => {
                                const value = dataset.data[index];
                                ctx.fillStyle = '#333333';
                                ctx.font = 'bold 12px Arial';
                                ctx.textAlign = 'center';
                                ctx.fillText(value, element.x, element.y - 10);
                            });
                        }
                    });
                }
            }]
        });
        
        // Adicionar legenda manual
        $('#evolucaoLegend').html(`
            <div class="legend-item">
                <div class="legend-color" style="background-color: #007bff"></div>
                <span>Total de Processos por Ano</span>
            </div>
        `);
    }
    
    // Função para criar ou atualizar o gráfico de classificações
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
        
        // Se o gráfico já existe, atualizá-lo
        if (classificacaoChart) {
            classificacaoChart.data.labels = visibleLabels;
            classificacaoChart.data.datasets[0].data = visibleQuantidades;
            classificacaoChart.update();
            return;
        }
        
        // Criar um novo gráfico
        classificacaoChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: visibleLabels,
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
                        display: false
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
                                const value = context.raw;
                                const percentage = ((value / total) * 100).toFixed(1);
                                return context.label + ': ' + value + ' (' + percentage + '%)';
                            }
                        }
                    }
                },
                animation: {
                    animateRotate: true,
                    animateScale: true
                }
            }
        });
        
        // Adicionar legenda manual
        let legendaHtml = '';
        visibleLabels.forEach((label, index) => {
            legendaHtml += `
                <div class="legend-item">
                    <div class="legend-color" style="background-color: ${visibleCores[index]}"></div>
                    <span>${label} (${visibleQuantidades[index]})</span>
                </div>
            `;
        });
        
        $('#classificacaoLegend').html(legendaHtml);
    }
    
    // Função principal para atualizar os gráficos com novos dados
    window.atualizarGraficos = function(dados) {
        if (!dados) return;
        
        // Renderizar ou atualizar os gráficos
        renderEvolucaoChart(dados.evolucaoMensal);
        renderClassificacaoChart(dados.distribuicaoClassificacao, dados.totalProcessos);
    };
});
</script>
