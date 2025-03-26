<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Graficos.css">

<!-- Card container principal -->
<div class="card dashboard-card mb-4">
  <div class="card-header">
    <h3 class="card-title">
      <i class="fas fa-chart-line mr-2"></i>Análise Gráfica
    </h3>
    <div class="card-tools">
      <button type="button" class="btn btn-tool" data-card-widget="collapse">
        <i class="fas fa-minus"></i>
      </button>
    </div>
  </div>
  <div class="card-body">
    <!-- Conteúdo da aba Gráficos - Layout reorganizado -->
    <div class="row" style="justify-content: space-around; margin-bottom:20px">
      <!-- Gráfico de média por categoria -->
      <div class="col-md-6">
        <div class="card h-100">
          <div class="card-header">
            <h5 class="card-title">Média por Categoria</h5>
          </div>
          <div class="card-body d-flex flex-column">
            <div class="flex-grow-1">
              <canvas id="graficoMediaDT"></canvas>
            </div>
          </div>
        </div>
      </div>

      <!-- Gráfico de rosca NPS - Layout atualizado para centralizar corretamente -->
      <div class="col-md-6">
        <div class="card h-100">
          <div class="card-header">
            <h5 class="card-title">
              Distribuição NPS
              <!-- Ícone explicativo com margin-left aumentada -->
              <span class="nps-info-icon" data-toggle="popover" data-html="true" data-placement="top" 
                    title="<span class='popover-title-custom'>Classificação do NPS</span>" 
                    data-content="
                    <div class='nps-info-content'>
                      <div class='nps-info-item'>
                        <strong>Cálculo:</strong> O NPS é baseado na média das pesquisas de opinião por órgão respondente.
                      </div>
                      <div class='nps-info-item promotores-info'>
                        <div class='color-dot'></div>
                        <strong>Órgãos Promotores:</strong> (nota 9,0 - 10,0)
                      </div>
                      <div class='nps-info-item neutros-info'>
                        <div class='color-dot'></div>
                        <strong>Órgãos Neutros:</strong> (nota 7,0 - 8,9)
                      </div>
                      <div class='nps-info-item detratores-info'>
                        <div class='color-dot'></div>
                        <strong>Órgãos Detratores:</strong> (nota 1 - 6,9)
                      </div>
                      <hr>
                      
                      <div class='nps-formula'>
                        <strong>NPS</strong> = % Promotores - % Detratores
                      </div>
                    </div>">
                <i class="fas fa-info-circle text-info"></i>
              </span>
            </h5>
          </div>
          <div class="card-body d-flex flex-column">
            <!-- Container com estrutura ajustada para centralização perfeita -->
            <div class="nps-chart-wrapper">
              <div class="nps-chart-container">
                <!-- Div com proporção fixa para garantir um círculo perfeito -->
                <div class="chart-square-container">
                  <canvas id="npsDonutChartDT"></canvas>
                  <!-- Valor do NPS no centro do gráfico -->
                  <div class="nps-chart-center">
                    <span class="nps-value" id="npsValorDisplayDT">0</span>
                    <span class="nps-label">NPS</span>
                  </div>
                </div>
              </div>
            </div>
            <!-- Legenda abaixo do gráfico -->
            <div class="nps-legenda-fixa">
              <div class="legenda-item legenda-promotores">
                <div class="legenda-cor" style="background-color: #10b981;"></div>
                <div class="legenda-texto">Promotores <span id="qtdPromotoresDT">(0)</span></div>
              </div>
              <div class="legenda-item legenda-neutros">
                <div class="legenda-cor" style="background-color: #fbbf24;"></div>
                <div class="legenda-texto">Neutros <span id="qtdNeutrosDT">(0)</span></div>
              </div>
              <div class="legenda-item legenda-detratores">
                <div class="legenda-cor" style="background-color: #ef4444;"></div>
                <div class="legenda-texto">Detratores <span id="qtdDetratoresDT">(0)</span></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Gráfico de evolução das notas -->
    <div class="row">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header">
            <h5 class="card-title">Evolução das Notas</h5>
          </div>
          <div class="card-body d-flex flex-column">
            <div class="flex-grow-1">
              <canvas id="graficoEvolucaoDT" height="300"></canvas>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.graficosDTLoaded === 'undefined') {
        window.graficosDTLoaded = true;
        
        // Variáveis para armazenar os gráficos
        let graficoMediaDT, npsChartDT, graficoEvolucaoDT;
        
        // Cores para as categorias de métricas
        const coresCategorias = {
            comunicacao: '#17a2b8',    // Azul claro
            interlocucao: '#6f42c1',   // Roxo
            reuniao: '#dc3545',        // Vermelho
            relatorio: '#007bff',      // Azul
            pos_trabalho: '#28a745',   // Verde
            importancia: '#fd7e14'     // Laranja
        };

        // Cores para o NPS
        const coresNPS = {
            promotores: '#10b981',  // Verde
            neutros: '#fbbf24',     // Âmbar
            detratores: '#ef4444'   // Vermelho
        };
        
        // Função para renderizar o gráfico de média por categoria
        function renderGraficoMediaDT(medias) {
            const ctx = document.getElementById('graficoMediaDT').getContext('2d');
            
            // Destruir o gráfico existente se houver
            if (graficoMediaDT) {
                graficoMediaDT.destroy();
            }
            
            // Dados e labels
            const labels = ['Comunicação', 'Interlocução', 'Reunião', 'Relatório', 'Pós-Trabalho', 'Importância'];
            const cores = [
                coresCategorias.comunicacao,
                coresCategorias.interlocucao,
                coresCategorias.reuniao,
                coresCategorias.relatorio,
                coresCategorias.pos_trabalho,
                coresCategorias.importancia
            ];
            
            // Criar o gráfico
            graficoMediaDT = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
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
                            top: 40, // Aumentado para acomodar os rótulos
                            right: 10,
                            bottom: 10,
                            left: 10
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
                        callbacks: {
                            label: function(tooltipItem) {
                                return 'Nota: ' + parseFloat(tooltipItem.value).toFixed(1);
                            }
                        }
                    },
                    animation: {
                        duration: 1000,
                        easing: 'easeOutQuart'
                    },
                    plugins: {
                        datalabels: {
                            display: function(context) {
                                return context.dataset.data[context.dataIndex] > 0; // Mostrar apenas para valores positivos
                            },
                            backgroundColor: function(context) {
                                return context.dataset.backgroundColor[context.dataIndex];
                            },
                            borderRadius: 4,
                            color: 'white',
                            font: {
                                weight: 'bold',
                                size: 12
                            },
                            formatter: function(value) {
                                return parseFloat(value).toFixed(1);
                            },
                            padding: 6,
                            anchor: 'end',
                            align: 'start',
                            offset: 0
                        }
                    }
                },
                plugins: [ChartDataLabels]
            });
        }
        
        // Função para renderizar o gráfico de NPS
        function renderNPSChartDT(promotores, neutros, detratores) {
            const ctx = document.getElementById('npsDonutChartDT').getContext('2d');
            
            // Destruir o gráfico existente se houver
            if (npsChartDT) {
                npsChartDT.destroy();
            }
            
            // Total de respondentes
            const total = promotores + neutros + detratores;
            
            // Se não houver respondentes, mostrar gráfico vazio
            if (total === 0) {
                // Valores dummy para gráfico vazio
                const dummyData = {
                    labels: ['Sem dados'],
                    datasets: [{
                        data: [1],
                        backgroundColor: ['#e9ecef'],
                        borderWidth: 0
                    }]
                };
                
                npsChartDT = new Chart(ctx, {
                    type: 'doughnut',
                    data: dummyData,
                    options: {
                        cutoutPercentage: 70,
                        responsive: true,
                        maintainAspectRatio: true,
                        aspectRatio: 1,
                        legend: {
                            display: false
                        },
                        tooltips: {
                            enabled: false
                        },
                        animation: {
                            duration: 0
                        }
                    }
                });
                
                // Atualizar exibição do valor NPS
                $("#npsValorDisplayDT").text('-');
                $("#qtdPromotoresDT").text('(0)');
                $("#qtdNeutrosDT").text('(0)');
                $("#qtdDetratoresDT").text('(0)');
                
                return;
            }
            
            // Calcular o valor do NPS
            const npsValor = ((promotores / total) - (detratores / total)) * 100;
            
            // Atualizar o valor do NPS e as contagens
            $("#npsValorDisplayDT").text(npsValor.toFixed(1));
            $("#qtdPromotoresDT").text(`(${promotores})`);
            $("#qtdNeutrosDT").text(`(${neutros})`);
            $("#qtdDetratoresDT").text(`(${detratores})`);
            
            // Dados para o gráfico de NPS
            const npsData = {
                labels: ['Promotores', 'Neutros', 'Detratores'],
                datasets: [{
                    data: [promotores, neutros, detratores],
                    backgroundColor: [
                        coresNPS.promotores,
                        coresNPS.neutros,
                        coresNPS.detratores
                    ],
                    borderWidth: 1
                }]
            };
            
            // Criar o gráfico
            npsChartDT = new Chart(ctx, {
                type: 'doughnut',
                data: npsData,
                options: {
                    cutoutPercentage: 70,
                    responsive: true,
                    maintainAspectRatio: true,
                    aspectRatio: 1,
                    legend: {
                        display: false
                    },
                    tooltips: {
                        callbacks: {
                            label: function(tooltipItem, data) {
                                const dataset = data.datasets[tooltipItem.datasetIndex];
                                const total = dataset.data.reduce((a, b) => a + b, 0);
                                const value = dataset.data[tooltipItem.index];
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${data.labels[tooltipItem.index]}: ${value} (${percentage}%)`;
                            }
                        }
                    },
                    plugins: {
                        datalabels: {
                            formatter: (value, ctx) => {
                                const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1); // Removido Math.round para exibir com uma casa decimal
                                return percentage > 4 ? `${percentage}%` : '';
                            },
                            color: '#fff',
                            font: {
                                weight: 'bold',
                                size: 11
                            }
                        }
                    }
                }
            });
        }
        
        // Função para renderizar o gráfico de evolução das notas
        function renderGraficoEvolucaoDT(dados) {
            const ctx = document.getElementById('graficoEvolucaoDT').getContext('2d');
            
            // Destruir o gráfico existente se houver
            if (graficoEvolucaoDT) {
                graficoEvolucaoDT.destroy();
            }
            
            // Se não houver dados, mostrar gráfico vazio
            if (dados.length === 0) {
                graficoEvolucaoDT = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: ['Sem dados'],
                        datasets: [{
                            label: 'Média',
                            data: [0],
                            backgroundColor: 'rgba(200, 200, 200, 0.2)',
                            borderColor: 'rgba(200, 200, 200, 1)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            yAxes: [{
                                ticks: {
                                    beginAtZero: true
                                }
                            }]
                        }
                    }
                });
                return;
            }
            
            // Agrupar dados por mês/ano
            const notasPorPeriodo = {};
            const mesesNomes = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
            
            // Processar os dados para obter as notas por período
            dados.forEach(item => {
                if (!item.data) return;
                
                const data = new Date(item.data);
                const mes = data.getMonth();
                const ano = data.getFullYear();
                const periodo = `${mesesNomes[mes]}/${ano}`;
                
                if (!notasPorPeriodo[periodo]) {
                    notasPorPeriodo[periodo] = {
                        comunicacao: [],
                        interlocucao: [],
                        reuniao: [],
                        relatorio: [],
                        pos_trabalho: [],
                        importancia: [],
                        timestamp: new Date(ano, mes, 1).getTime() // Para ordenação
                    };
                }
                
                if (item.comunicacao && parseFloat(item.comunicacao) > 0) 
                    notasPorPeriodo[periodo].comunicacao.push(parseFloat(item.comunicacao));
                
                if (item.interlocucao && parseFloat(item.interlocucao) > 0) 
                    notasPorPeriodo[periodo].interlocucao.push(parseFloat(item.interlocucao));
                
                if (item.reuniao && parseFloat(item.reuniao) > 0) 
                    notasPorPeriodo[periodo].reuniao.push(parseFloat(item.reuniao));
                
                if (item.relatorio && parseFloat(item.relatorio) > 0) 
                    notasPorPeriodo[periodo].relatorio.push(parseFloat(item.relatorio));
                
                if (item.pos_trabalho && parseFloat(item.pos_trabalho) > 0) 
                    notasPorPeriodo[periodo].pos_trabalho.push(parseFloat(item.pos_trabalho));
                
                if (item.importancia && parseFloat(item.importancia) > 0) 
                    notasPorPeriodo[periodo].importancia.push(parseFloat(item.importancia));
            });
            
            // Calcular média para cada período e categoria
            const calcularMedia = valores => valores.length > 0 ? 
                valores.reduce((a, b) => a + b, 0) / valores.length : null;
            
            // Converter para formato de gráfico e ordenar por timestamp
            const periodos = Object.keys(notasPorPeriodo)
                .map(periodo => ({
                    periodo,
                    timestamp: notasPorPeriodo[periodo].timestamp,
                    comunicacao: calcularMedia(notasPorPeriodo[periodo].comunicacao),
                    interlocucao: calcularMedia(notasPorPeriodo[periodo].interlocucao),
                    reuniao: calcularMedia(notasPorPeriodo[periodo].reuniao),
                    relatorio: calcularMedia(notasPorPeriodo[periodo].relatorio),
                    pos_trabalho: calcularMedia(notasPorPeriodo[periodo].pos_trabalho),
                    importancia: calcularMedia(notasPorPeriodo[periodo].importancia)
                }))
                .sort((a, b) => a.timestamp - b.timestamp);
            
            // Preparar dados para o gráfico
            const labels = periodos.map(p => p.periodo);
            
            // Criar datasets para cada categoria
            const datasets = [
                {
                    label: 'Comunicação',
                    data: periodos.map(p => p.comunicacao),
                    backgroundColor: 'rgba(23, 162, 184, 0.2)',
                    borderColor: coresCategorias.comunicacao,
                    borderWidth: 2,
                    pointRadius: 4,
                    pointBackgroundColor: coresCategorias.comunicacao
                },
                {
                    label: 'Interlocução',
                    data: periodos.map(p => p.interlocucao),
                    backgroundColor: 'rgba(111, 66, 193, 0.2)',
                    borderColor: coresCategorias.interlocucao,
                    borderWidth: 2,
                    pointRadius: 4,
                    pointBackgroundColor: coresCategorias.interlocucao
                },
                {
                    label: 'Reunião',
                    data: periodos.map(p => p.reuniao),
                    backgroundColor: 'rgba(220, 53, 69, 0.2)',
                    borderColor: coresCategorias.reuniao,
                    borderWidth: 2,
                    pointRadius: 4,
                    pointBackgroundColor: coresCategorias.reuniao
                },
                {
                    label: 'Relatório',
                    data: periodos.map(p => p.relatorio),
                    backgroundColor: 'rgba(0, 123, 255, 0.2)',
                    borderColor: coresCategorias.relatorio,
                    borderWidth: 2,
                    pointRadius: 4,
                    pointBackgroundColor: coresCategorias.relatorio
                },
                {
                    label: 'Pós-Trabalho',
                    data: periodos.map(p => p.pos_trabalho),
                    backgroundColor: 'rgba(40, 167, 69, 0.2)',
                    borderColor: coresCategorias.pos_trabalho,
                    borderWidth: 2,
                    pointRadius: 4,
                    pointBackgroundColor: coresCategorias.pos_trabalho
                },
                {
                    label: 'Importância',
                    data: periodos.map(p => p.importancia),
                    backgroundColor: 'rgba(253, 126, 20, 0.2)',
                    borderColor: coresCategorias.importancia,
                    borderWidth: 2,
                    pointRadius: 4,
                    pointBackgroundColor: coresCategorias.importancia
                }
            ];
            
            // Criar o gráfico
            graficoEvolucaoDT = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: datasets
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        position: 'top',
                        labels: {
                            boxWidth: 12,
                            padding: 10
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
                        mode: 'index',
                        intersect: false,
                        callbacks: {
                            label: function(tooltipItem, data) {
                                const dataset = data.datasets[tooltipItem.datasetIndex];
                                const value = dataset.data[tooltipItem.index];
                                return value !== null ? `${dataset.label}: ${parseFloat(value).toFixed(1)}` : `${dataset.label}: Sem dados`;
                            }
                        }
                    },
                    plugins: {
                        datalabels: {
                            display: false
                        }
                    }
                }
            });
        }
        
        // Função principal para atualizar todos os gráficos com base nos dados do datatable
        window.atualizarGraficosDatatable = function() {
            // Obter a tabela
            const dataTable = $('#tabelaPesquisasDetalhada').DataTable();
            
            // Verificar se a tabela existe e está inicializada
            if (!dataTable) return;
            
            // Obter os dados filtrados da tabela
            const dados = dataTable.rows({search: 'applied'}).data().toArray();
            
            // Se não houver dados, mostrar gráficos vazios
            if (dados.length === 0) {
                renderGraficoMediaDT([0, 0, 0, 0, 0, 0]);
                renderNPSChartDT(0, 0, 0);
                renderGraficoEvolucaoDT([]);
                return;
            }
            
            // 1. Atualizar gráfico de média por categoria
            const comunicacaoValues = dados.map(item => parseFloat(item.comunicacao) || 0).filter(n => n > 0);
            const interlocucaoValues = dados.map(item => parseFloat(item.interlocucao) || 0).filter(n => n > 0);
            const reuniaoValues = dados.map(item => parseFloat(item.reuniao) || 0).filter(n => n > 0);
            const relatorioValues = dados.map(item => parseFloat(item.relatorio) || 0).filter(n => n > 0);
            const posTrabalhoValues = dados.map(item => parseFloat(item.pos_trabalho) || 0).filter(n => n > 0);
            const importanciaValues = dados.map(item => parseFloat(item.importancia) || 0).filter(n => n > 0);
            
            // Calcular médias
            const calcularMedia = valores => valores.length > 0 ? 
                valores.reduce((a, b) => a + b, 0) / valores.length : 0;
            
            const medias = [
                calcularMedia(comunicacaoValues),
                calcularMedia(interlocucaoValues),
                calcularMedia(reuniaoValues),
                calcularMedia(relatorioValues),
                calcularMedia(posTrabalhoValues),
                calcularMedia(importanciaValues)
            ];
            
            renderGraficoMediaDT(medias);
            
            // 2. Atualizar gráfico de NPS usando as classificações já calculadas pelo servidor
            // Criar um Map para armazenar órgãos únicos e suas classificações
            const orgaosUnicos = new Map();
            
            // Preencher o mapa com os órgãos e suas classificações
            dados.forEach(item => {
                if (item.orgao_respondente && item.classificacao_nps) {
                    orgaosUnicos.set(item.orgao_respondente, item.classificacao_nps);
                }
            });
            
            // Contar órgãos em cada categoria
            let promotores = 0, neutros = 0, detratores = 0;
            
            orgaosUnicos.forEach((classificacao) => {
                if (classificacao === 'Promotor') {
                    promotores++;
                } else if (classificacao === 'Neutro') {
                    neutros++;
                } else if (classificacao === 'Detrator') {
                    detratores++;
                }
            });
            
            renderNPSChartDT(promotores, neutros, detratores);
            
            // 3. Atualizar gráfico de evolução das notas
            renderGraficoEvolucaoDT(dados);
        };
        
        // Inicializar popovers
        $('[data-toggle="popover"]').popover({
            container: 'body',
            trigger: 'hover',
            html: true
        });
        
        // Inicializar os gráficos quando a tabela estiver pronta
        $(document).on('init.dt', function(e, settings) {
            if (settings.nTable.id === 'tabelaPesquisasDetalhada') {
                // Garantir que o plugin ChartDataLabels está disponível
                if (typeof ChartDataLabels === 'undefined') {
                    // Criar referência global ao plugin se já estiver carregado mas não referenciado
                    window.ChartDataLabels = Chart.plugins.getAll().find(p => p.id === 'datalabels');
                }
                
                // Inicializar com dados vazios
                renderGraficoMediaDT([0, 0, 0, 0, 0, 0]);
                renderNPSChartDT(0, 0, 0);
                renderGraficoEvolucaoDT([]);
                
                // Atualizar com dados reais após um pequeno delay
                setTimeout(function() {
                    window.atualizarGraficosDatatable();
                }, 600);
            }
        });
        
        // Atualizar gráficos quando a tabela for filtrada
        $(document).on('draw.dt', function(e, settings) {
            if (settings.nTable.id === 'tabelaPesquisasDetalhada') {
                window.atualizarGraficosDatatable();
            }
        });
        
        // Ajustar tamanho dos gráficos quando a janela for redimensionada
        $(window).resize(function() {
            if (graficoMediaDT) graficoMediaDT.resize();
            if (npsChartDT) npsChartDT.resize();
            if (graficoEvolucaoDT) graficoEvolucaoDT.resize();
        });
    }
});
</script>
