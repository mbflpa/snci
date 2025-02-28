<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Graficos.css">

<!-- Conteúdo da aba Gráficos -->
<div class="row">
  <div class="col-md-4">
    <div class="card">
      <div class="card-header">
        <h5 class="card-title">Distribuição por Categoria</h5>
      </div>
      <div class="card-body">
        <canvas id="graficoMedia" height="300"></canvas>
      </div>
    </div>
  </div>
  <div class="col-md-8">
    <div class="card">
      <div class="card-header">
        <h5 class="card-title">Evolução das Avaliações</h5>
      </div>
      <div class="card-body">
        <canvas id="graficoEvolucao" height="300"></canvas>
      </div>
    </div>
  </div>
</div>

<script>
$(document).ready(function() {
    // Variáveis globais para os gráficos
    var graficoMedia, graficoEvolucao;
    
    // Obter cores das variáveis CSS para uso no JavaScript
    var coresCategorias = {
        comunicacao: getComputedStyle(document.documentElement).getPropertyValue('--cor-comunicacao').trim() || '#17a2b8',
        interlocucao: getComputedStyle(document.documentElement).getPropertyValue('--cor-interlocucao').trim() || '#28a745',
        reuniao: getComputedStyle(document.documentElement).getPropertyValue('--cor-reuniao').trim() || '#ffc107',
        relatorio: getComputedStyle(document.documentElement).getPropertyValue('--cor-relatorio').trim() || '#fd7e14',
        postrabalho: getComputedStyle(document.documentElement).getPropertyValue('--cor-pos-trabalho').trim() || '#20c997',
        importancia: getComputedStyle(document.documentElement).getPropertyValue('--cor-importancia').trim() || '#6f42c1'
    };
    
    // Função para renderizar o gráfico de média por categoria
    window.renderGraficoMedia = function(medias) {
        var ctx = document.getElementById('graficoMedia').getContext('2d');
        if (graficoMedia) { graficoMedia.destroy(); }
        
        // Cores definidas para cada categoria igual às do score card
        var cores = [
            coresCategorias.comunicacao, // Comunicação
            coresCategorias.interlocucao, // Interlocução
            coresCategorias.reuniao, // Reunião
            coresCategorias.relatorio, // Relatório
            coresCategorias.postrabalho,  // Pós-Trabalho
            coresCategorias.importancia  // Importância
        ];
        
        // Configuração corrigida para exibir valores acima das barras
        Chart.defaults.global.defaultFontFamily = "'Segoe UI', 'Helvetica Neue', Arial, sans-serif";
        
        graficoMedia = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Comunicação','Interlocução','Reunião','Relatório','Pós-Trabalho','Importância'],
                datasets: [{
                    label: 'Média',
                    data: medias,
                    backgroundColor: cores,
                    barPercentage: 0.6,
                    categoryPercentage: 0.8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                legend: {
                    display: false
                },
                layout: {
                    padding: {
                        left: 10,
                        right: 10,
                        top: 30, // Espaço para os rótulos acima das barras
                        bottom: 10
                    }
                },
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            max: 10,
                            stepSize: 2
                        }
                    }]
                },
                tooltips: {
                    enabled: true,
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    datalabels: {
                        display: true,
                        color: function(context) {
                            var index = context.dataIndex;
                            return cores[index]; // Usar a mesma cor da barra
                        },
                        font: {
                            weight: 'bold',
                            size: 14
                        },
                        anchor: 'end',
                        align: 'top',
                        offset: 0,
                        formatter: function(value) {
                            return parseFloat(value).toFixed(1);
                        },
                        padding: {
                            top: 4,
                            bottom: 0
                        }
                    }
                },
                animation: {
                    duration: 1000,
                    easing: 'easeOutQuart'
                }
            },
            plugins: [window.ChartDataLabels]
        });
    };
    
    // Função para renderizar o gráfico de evolução temporal
    window.renderGraficoEvolucao = function(evolucao) {
        var ctx = document.getElementById('graficoEvolucao').getContext('2d');
        if (graficoEvolucao) { 
            graficoEvolucao.destroy(); 
        }

        // Se não houver dados, criar gráfico vazio
        if (!evolucao || !Array.isArray(evolucao) || evolucao.length === 0) {
            graficoEvolucao = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [{
                        label: 'Média Mensal',
                        data: [],
                        borderColor: coresCategorias.comunicacao,
                        backgroundColor: 'rgba(23, 162, 184, 0.1)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        yAxes: [{
                            ticks: {
                                beginAtZero: true,
                                max: 10
                            }
                        }]
                    }
                }
            });
            return;
        }

        // Formata os dados para exibição
        var labels = evolucao.map(function(item) {
            var dataParts = item.mes.split('-');
            var data = new Date(dataParts[0], parseInt(dataParts[1]) - 1);
            return data.toLocaleString('pt-BR', { month: 'short', year: 'numeric' });
        });

        var dados = evolucao.map(function(item) {
            return Number(item.media) || 0;
        });

        graficoEvolucao = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Média Mensal',
                    data: dados,
                    borderColor: coresCategorias.comunicacao,
                    backgroundColor: 'rgba(23, 162, 184, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                legend: {
                    display: true,
                    position: 'top'
                },
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            max: 10,
                            stepSize: 2
                        }
                    }]
                }
            }
        });
    };
    
    // Função para atualizar os gráficos com os dados recebidos
    window.atualizarGraficos = function(resultado) {
        if (resultado.medias && Array.isArray(resultado.medias)) {
            window.renderGraficoMedia(resultado.medias);
        }
        
        if (resultado.evolucaoTemporal && Array.isArray(resultado.evolucaoTemporal)) {
            window.renderGraficoEvolucao(resultado.evolucaoTemporal);
        }
        
        // Forçar redimensionamento dos gráficos
        $(window).trigger('resize');
    };
    
    // Adicionar ajuste automático dos gráficos ao redimensionar a janela
    $(window).resize(function() {
        if (graficoMedia) graficoMedia.resize();
        if (graficoEvolucao) graficoEvolucao.resize();
    });
});
</script>
