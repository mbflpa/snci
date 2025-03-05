<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Graficos.css">

<!-- Conteúdo da aba Gráficos - Layout reorganizado com altura igual -->
<div class="row mb-12" style="justify-content: space-around;margin-bottom:20px">
  <!-- Gráfico de média por categoria -->
  <div class="col-md-4">
    <div class="card h-100">
      <div class="card-header">
        <h5 class="card-title">Média por Categoria</h5>
      </div>
      <div class="card-body d-flex flex-column">
        <div class="flex-grow-1">
          <canvas id="graficoMedia"></canvas>
        </div>
      </div>
    </div>
  </div>

  <!-- Gráfico de rosca NPS - Layout atualizado para centralizar corretamente -->
  <div class="col-md-3">
    <div class="card h-100">
      <div class="card-header">
        <h5 class="card-title">
          Distribuição NPS
          <!-- Ícone explicativo com margin-left aumentada -->
          <span class="nps-info-icon" data-toggle="popover" data-html="true" data-placement="top" 
                title="<span class='popover-title-custom'>Classificação do NPS</span>" 
                data-content="
                <div class='nps-info-content'>
                  <div class='nps-info-item promotores-info'>
                    <div class='color-dot'></div>
                    <strong>Promotores:</strong> Notas 9-10
                  </div>
                  <div class='nps-info-item neutros-info'>
                    <div class='color-dot'></div>
                    <strong>Neutros:</strong> Notas 7-8
                  </div>
                  <div class='nps-info-item detratores-info'>
                    <div class='color-dot'></div>
                    <strong>Detratores:</strong> Notas 1-6
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
              <canvas id="npsDonutChart"></canvas>
              <!-- Valor do NPS no centro do gráfico -->
              <div class="nps-chart-center">
                <span class="nps-value" id="npsValorDisplay">0</span>
                <span class="nps-label">NPS</span>
              </div>
            </div>
          </div>
        </div>
        <!-- Legenda abaixo do gráfico -->
        <div class="nps-legenda-fixa">
          <div class="legenda-item legenda-promotores">
            <div class="legenda-cor" style="background-color: #10b981;"></div>
            <div class="legenda-texto">Promotores <span id="qtdPromotores">(0)</span></div>
          </div>
          <div class="legenda-item legenda-neutros">
            <div class="legenda-cor" style="background-color: #fbbf24;"></div>
            <div class="legenda-texto">Neutros <span id="qtdNeutros">(0)</span></div>
          </div>
          <div class="legenda-item legenda-detratores">
            <div class="legenda-cor" style="background-color: #ef4444;"></div>
            <div class="legenda-texto">Detratores <span id="qtdDetratores">(0)</span></div>
          </div>
        </div>
      </div>
    </div>
  </div>
   <!-- Gráfico de evolução ocupando toda a largura -->
  <div class="col-5">
    <div class="card h-100">
      <div class="card-header">
        <h5 class="card-title">Evolução das Notas</h5>
      </div>
      <div class="card-body d-flex flex-column">
        <div class="flex-grow-1">
          <canvas id="graficoEvolucao"></canvas>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="row">
 
</div>

<!--- Script para gerar e configurar o gráfico NPS - Atualizado para melhor centralização --->
<script>
window.updateNPSChart = function(npsData) {
    console.log('Atualizando gráfico NPS com dados:', npsData);
    
    if (!npsData || !npsData.npsDetalhes) {
        console.error('Dados NPS inválidos ou incompletos');
        return;
    }
    
    const { promotores, neutros, detratores, total } = npsData.npsDetalhes;
    const npsValor = npsData.nps;
    
    // Atualizar o valor do NPS no centro
    document.getElementById('npsValorDisplay').textContent = npsValor;
    
    // Atualizar as quantidades nas legendas
    document.getElementById('qtdPromotores').textContent = `(${promotores})`;
    document.getElementById('qtdNeutros').textContent = `(${neutros})`;
    document.getElementById('qtdDetratores').textContent = `(${detratores})`;
    
    // Configurar cores modernas como no exemplo fornecido
    const chartColors = {
        promotores: '#10b981', // Verde moderno
        neutros: '#fbbf24',    // Âmbar moderno
        detratores: '#ef4444'  // Vermelho moderno
    };
    
    // Garantir que temos dados para mostrar no gráfico
    const hasData = total > 0;
    
    // Filtrar valores zero antes de criar o gráfico
    const valores = [promotores, neutros, detratores];
    const labels = ['Promotores', 'Neutros', 'Detratores'];
    const bgColors = [chartColors.promotores, chartColors.neutros, chartColors.detratores];
    const borderColors = ['#ffffff', '#ffffff', '#ffffff']; // Bordas brancas como no exemplo
    
    // Arrays filtrados sem valores zero
    const valoresFiltrados = [];
    const labelsFiltrados = [];
    const bgColorsFiltrados = [];
    const borderColorsFiltrados = [];
    
    // Se não há dados, usar valores dummy para o gráfico vazio
    if (!hasData) {
        valoresFiltrados.push(1, 1, 1); // valores dummy
        labelsFiltrados.push('Promotores', 'Neutros', 'Detratores');
        bgColorsFiltrados.push(...bgColors);
        borderColorsFiltrados.push(...borderColors);
        
        // Também limpar as quantidades nas legendas quando não há dados
        document.getElementById('qtdPromotores').textContent = '(0)';
        document.getElementById('qtdNeutros').textContent = '(0)';
        document.getElementById('qtdDetratores').textContent = '(0)';
    } else {
        // Filtrar os valores zero
        for (let i = 0; i < valores.length; i++) {
            if (valores[i] > 0) {
                valoresFiltrados.push(valores[i]);
                labelsFiltrados.push(labels[i]);
                bgColorsFiltrados.push(bgColors[i]);
                borderColorsFiltrados.push(borderColors[i]);
            }
        }
        
        // Se todos os valores forem zero, mostrar gráfico vazio
        if (valoresFiltrados.length === 0) {
            valoresFiltrados.push(1, 1, 1); // valores dummy
            labelsFiltrados.push('Promotores', 'Neutros', 'Detratores');
            bgColorsFiltrados.push(...bgColors);
            borderColorsFiltrados.push(...borderColors);
        }
    }
    
    // Calcular porcentagens para mostrar nas legendas COM UMA CASA DECIMAL
    const percentPromotores = total > 0 ? ((promotores / total) * 100).toFixed(1) : 0;
    const percentNeutros = total > 0 ? ((neutros / total) * 100).toFixed(1) : 0;
    const percentDetratores = total > 0 ? ((detratores / total) * 100).toFixed(1) : 0;
    
    // Configurar os dados para o gráfico com valores filtrados
    const data = {
        labels: labelsFiltrados,
        datasets: [{
            data: valoresFiltrados,
            backgroundColor: bgColorsFiltrados,
            borderColor: borderColorsFiltrados,
            borderWidth: 1
        }]
    };
    
    // CORREÇÃO 1: GARANTIR QUE PLUGINS ANTERIORES SEJAM DESREGISTRADOS
    // Se houver plugins registrados anteriormente, vamos desregistrá-los
    if (Chart.pluginService && Chart.pluginService._plugins && Chart.pluginService._plugins.length > 0) {
        // Verificar se há um plugin 'doughnutLabels' e removê-lo
        for (let i = Chart.pluginService._plugins.length - 1; i >= 0; i--) {
            if (Chart.pluginService._plugins[i].id === 'doughnutLabels') {
                Chart.pluginService._plugins.splice(i, 1);
                console.log('Plugin doughnutLabels removido para evitar duplicação');
            }
        }
    }
    
    // Plugin personalizado para adicionar rótulos dentro do gráfico - simplificado para estilo moderno
    const doughnutLabelsPlugin = {
        id: 'doughnutLabels',
        afterDraw: function(chart) {
            // Ignorar se não é tipo donut/doughnut
            if (chart.config.type !== 'doughnut') return;
            
            const ctx = chart.ctx;
            const chartArea = chart.chartArea;
            const centerX = (chartArea.left + chartArea.right) / 2;
            const centerY = (chartArea.top + chartArea.bottom) / 2;
            
            // Configuração para desenhar textos - apenas o percentual como no exemplo
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.font = '12px Arial'; // Fonte menor como no exemplo
            ctx.fillStyle = '#000'; // Texto branco como no exemplo
            
            // Para cada segmento do donut
            chart.data.datasets.forEach((dataset, datasetIndex) => {
                const meta = chart.getDatasetMeta(datasetIndex);
                
                meta.data.forEach((element, index) => {
                    // Obter posição do elemento (meio do arco)
                    const model = element._model || element;
                    const rotation = model.startAngle + (model.endAngle - model.startAngle) / 2;
                    
                    // Posicionar como no exemplo (mais ao meio da seção)
                    const radius = model.innerRadius + (model.outerRadius - model.innerRadius) * 0.4;
                    const x = centerX + Math.cos(rotation) * radius;
                    const y = centerY + Math.sin(rotation) * radius;
                    
                    // Pular a visualização de valores dummy (usado quando não tem dados)
                    if (!hasData) return;
                    
                    // Obter a label correspondente ao índice
                    const label = chart.data.labels[index];
                    
                    // Determinar qual porcentagem mostrar (apenas o % como no exemplo)
                    let percent;
                    
                    if (label === 'Promotores') {
                        percent = percentPromotores;
                    } else if (label === 'Neutros') {
                        percent = percentNeutros;
                    } else {
                        percent = percentDetratores;
                    }
                    
                    // Desenhar apenas o percentual como no exemplo
                    ctx.fillText(`${percent}%`, x, y);
                });
            });
        }
    };
    
    // CONFIGURAÇÃO para layout
    const options = {
        responsive: true,
        maintainAspectRatio: true,
        aspectRatio: 1, // Mantém o gráfico circular
        cutoutPercentage: 70,  // Tamanho do buraco no meio
        legend: {
            display: false 
        },
        tooltips: {
            enabled: true,
            callbacks: {
                label: function(tooltipItem, data) {
                    const label = data.labels[tooltipItem.index];
                    const value = data.datasets[0].data[tooltipItem.index];
                    const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                    return `${label}: ${value} (${percentage}%)`;
                }
            }
        },
        animation: {
            animateRotate: true,
            duration: 800
        }
    };
    
    // Remover canvas antigo e criar um novo
    const container = document.querySelector('.chart-square-container');
    const oldCanvas = document.getElementById('npsDonutChart');
    const newCanvas = document.createElement('canvas');
    newCanvas.id = 'npsDonutChart';
    newCanvas.style.position = 'absolute';
    newCanvas.style.top = '0';
    newCanvas.style.left = '0';
    newCanvas.style.width = '100%';
    newCanvas.style.height = '100%';
    
    if (oldCanvas && oldCanvas.parentNode) {
        oldCanvas.parentNode.replaceChild(newCanvas, oldCanvas);
    } else if (container) {
        container.appendChild(newCanvas);
    }
    
    // Criar o gráfico usando as configurações atualizadas
    const ctx = newCanvas.getContext('2d');
    
    // Registrar plugin para Chart.js
    if (Chart.pluginService && typeof Chart.pluginService.register === 'function') {
        Chart.pluginService.register(doughnutLabelsPlugin);
    }
    
    // Criar o gráfico
    window.npsChart = new Chart(ctx, {
        type: 'doughnut',
        data: data,
        options: options
    });
    
    // Adicionar classe específica ao valor do NPS com base no resultado
    const npsValueElement = document.getElementById('npsValorDisplay');
    npsValueElement.className = 'nps-value';
    if (npsValor >= 50) {
        npsValueElement.classList.add('text-success');
    } else if (npsValor >= 0) {
        npsValueElement.classList.add('text-warning');
    } else {
        npsValueElement.classList.add('text-danger');
    }
    
    // Se não há dados, mostrar uma mensagem
    if (!hasData) {
        npsValueElement.textContent = '-';
    }
};
</script>

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
        
        // Atualizar o gráfico NPS se os dados estiverem disponíveis
        if (resultado.nps !== undefined && resultado.npsDetalhes) {
            try {
                // Adicionar checagem extra para certificar que a função existe
                if (typeof window.updateNPSChart === 'function') {
                    window.updateNPSChart(resultado);
                    console.log("Dados NPS processados com sucesso");
                } else {
                    console.error("Função updateNPSChart não disponível. Definindo dados para inicialização posterior.");
                    // Armazenar dados para tentativa futura
                    window._pendingNPSData = resultado;
                    
                    // Tentar novamente em 500ms
                    setTimeout(function() {
                        if (typeof window.updateNPSChart === 'function' && window._pendingNPSData) {
                            window.updateNPSChart(window._pendingNPSData);
                            window._pendingNPSData = null;
                        }
                    }, 500);
                }
            } catch (e) {
                console.error("Erro ao atualizar gráfico NPS:", e);
            }
        } else {
            console.warn("Dados NPS não disponíveis ou incompletos");
        }
        
        // Forçar redimensionamento dos gráficos
        $(window).trigger('resize');
    };
    
    // Adicionar ajuste automático dos gráficos ao redimensionar a janela
    $(window).resize(function() {
        if (graficoMedia) graficoMedia.resize();
        if (graficoEvolucao) graficoEvolucao.resize();
        if (window.npsChart && typeof window.npsChart.resize === 'function') {
            // Adicionar um pequeno atraso para garantir o redimensionamento correto
            setTimeout(function() {
                window.npsChart.resize();
                
                // Verificar se os elementos centrais estão bem posicionados após o resize
                const centerElement = document.querySelector('.nps-chart-center');
                if (centerElement) {
                    centerElement.style.top = '50%';
                    centerElement.style.left = '50%';
                }
            }, 100);
        }
    });
    
    // Inicializar tooltips do Bootstrap quando o documento estiver pronto
    $('[data-toggle="tooltip"]').tooltip();
    
    // Inicializar popovers do Bootstrap quando o documento estiver pronto
    $('[data-toggle="popover"]').popover({
        trigger: 'hover focus',
        container: 'body',
        template: '<div class="popover nps-popover" role="tooltip"><div class="arrow"></div><h3 class="popover-header"></h3><div class="popover-body"></div></div>'
    });
    
    // Verificar se Chart.js está disponível e configurar exemplo
    if (typeof Chart !== 'undefined') {
        // Tentar inicializar com dados dummy para testar renderização
        console.log('Tentando inicializar gráfico NPS com dados de exemplo');
        try {
            setTimeout(() => {
                // Verificar se o gráfico já foi inicializado por dados reais
                if (!window.npsChart) {
                    const dadosExemplo = {
                        nps: 30,
                        npsDetalhes: {
                            promotores: 50,
                            neutros: 30,
                            detratores: 20,
                            total: 100
                        }
                    };
                    window.updateNPSChart(dadosExemplo);
                }
            }, 1000);
        } catch (e) {
            console.error('Erro ao inicializar gráfico de exemplo:', e);
        }
    } else {
        console.error('Chart.js não foi carregado. Os gráficos não serão renderizados.');
    }
    
    // Adicionar listener para ajustar o gráfico NPS quando a aba for ativada
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        if (window.npsChart && typeof window.npsChart.resize === 'function') {
            window.npsChart.resize();
        }
    });
});
</script>
