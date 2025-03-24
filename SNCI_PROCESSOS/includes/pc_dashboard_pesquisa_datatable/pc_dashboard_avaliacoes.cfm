<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Avaliacoes.css">

<!-- Estilo para os badges -->
<style>
/* Estilo para o badge de conceito */
.conceito-badge {
  position: absolute;
  left: -45px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 10px;
  padding: 2px 5px;
  border-radius: 3px;
  font-weight: bold;
  white-space: nowrap;
  color: white;
  min-width: 40px;
  text-align: center;
  z-index: 2;
}

/* Cores para os diferentes conceitos */
.conceito-otimo {
  background-color: #28a745; /* verde */
}

.conceito-bom {
  background-color: #17a2b8; /* azul */
}

.conceito-regular {
  background-color: #ffc107; /* amarelo */
  color: #212529;
}

.conceito-ruim {
  background-color: #fd7e14; /* laranja */
}

.conceito-pessimo {
  background-color: #dc3545; /* vermelho */
}

/* Ajustar posicionamento e margens */
.donut-container {
  position: relative;
  margin-left: 25px;
}

.score-cards {
  position: relative;
  margin-left: -5px;
  padding-left: 0;
}

/* Ajustar os badges da legenda */
.legenda-badge {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 2px;
  margin-right: 3px;
}

/* Container principal para centralizar visualmente */
#avaliacoes-content {
  padding-left: 0;
}

/* Ajuste específico para os ícones de informação */
.info-icon {
  margin-left: 5px;
}

/* Estilo para a legenda inline no título */
.legenda-inline {
  display: inline-flex;
  align-items: center;
  flex-wrap: wrap;
  font-size: 12px;
  font-weight: normal;
  margin-left: 10px;
  margin-top: 5px;
}

.legenda-badge-small {
  position: static;
  transform: none;
  font-size: 9px;
  padding: 1px 3px;
  margin-right: 2px;
  margin-bottom: 2px;
  display: inline-block;
}

/* Ajuste para o header em telas pequenas */
@media (max-width: 768px) {
  .card-title {
    flex-direction: column;
    align-items: flex-start;
  }
}

/* Adicionar estilo para badges sem notas */
.conceito-sem-notas {
  background-color: #6c757d; /* cinza */
  color: white;
  font-size: 9px;
  left: -55px;
  min-width: 50px;
}

/* Estilo para o título do dashboard */
.dashboard-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 15px;
}

.dashboard-title h5 {
  margin: 0;
  color: #555;
}

.dashboard-info {
  font-size: 0.85rem;
  color: #888;
}

/* Ajuste para o card do dashboard */
.dashboard-card {
  margin-bottom: 20px;
  box-shadow: 0 4px 8px rgba(0,0,0,0.05);
  border-radius: 8px;
  border-top: 3px solid #0083CA;
}

.dashboard-card .card-body {
  padding: 15px;
}

/* Contador de pesquisas */
.pesquisas-count {
  font-size: 1rem;
  font-weight: 500;
  color: #0083CA;
  margin-left: 10px;
}
</style>

<!-- Card do Dashboard de Métricas -->
<div class="card mb-4 ">
  <div class="card-header">
    <h3 class="card-title">
      <i class="fas fa-chart-line mr-2"></i>Resumo das Avaliações
      <span class="pesquisas-count">(<span id="total-pesquisas">0</span> pesquisas)</span>
    </h3>
    <div class="card-tools">
      <button type="button" class="btn btn-tool" data-card-widget="collapse">
        <i class="fas fa-minus"></i>
      </button>
    </div>
  </div>
  <div class="card-body">  
    <!-- Score Cards -->
    <div class="score-cards">
      <div class="score-card comunicacao">
          <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a clareza, frequência e qualidade das interações com a equipe de Controle Interno."></i>
          <div class="card-header score-header" style="padding: 0 !important;">
              <i class="fas fa-comments fa-lg card-icon"></i>
              <h3>Comunicação</h3>
          </div>
          <div class="donut-container">
            <span class="conceito-badge" id="conceito-comunicacao"></span>
            <svg class="donut-chart" width="60" height="60" viewBox="0 0 42 42">
              <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#e9ecef" stroke-width="3"></circle>
              <circle class="donut-segment" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#17a2b8" stroke-width="3" stroke-dasharray="0 100" stroke-dashoffset="25"></circle>
            </svg>
            <div id="comunicacao" class="metric-value">0</div>
          </div>
      </div>
      <div class="score-card interlocucao">
          <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia o comportamento da equipe de Controle Interno ao longo do trabalho."></i>
          <div class="card-header score-header" style="padding: 0 !important;">
              <i class="fa fa-exchange fa-lg card-icon"></i>
              <h3>Interlocução</h3>
          </div>
          <div class="donut-container">
            <span class="conceito-badge" id="conceito-interlocucao"></span>
            <svg class="donut-chart" width="60" height="60" viewBox="0 0 42 42">
              <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#e9ecef" stroke-width="3"></circle>
              <circle class="donut-segment" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#6f42c1" stroke-width="3" stroke-dasharray="0 100" stroke-dashoffset="25"></circle>
            </svg>
            <div id="interlocucao" class="metric-value">0</div>
          </div>
      </div>
      <div class="score-card reuniao">
          <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a condução da reunião final da equipe de Controle Interno."></i>
          <div class="card-header score-header" style="padding: 0 !important;">
              <i class="fa fa-users fa-lg card-icon"></i>
              <h3>Reunião</h3>
          </div>
          <div class="donut-container">
            <span class="conceito-badge" id="conceito-reuniao"></span>
            <svg class="donut-chart" width="60" height="60" viewBox="0 0 42 42">
              <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#e9ecef" stroke-width="3"></circle>
              <circle class="donut-segment" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#dc3545" stroke-width="3" stroke-dasharray="0 100" stroke-dashoffset="25"></circle>
            </svg>
            <div id="reuniao" class="metric-value">0</div>
          </div>
      </div>
      <div class="score-card relatorio">
          <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a qualidade do relatório entregue ao final do trabalho da equipe de Controle Interno."></i>
          <div class="card-header score-header" style="padding: 0 !important;">
              <i class="fa fa-file-text fa-lg card-icon"></i>
              <h3>Relatório</h3>
          </div>
          <div class="donut-container">
            <span class="conceito-badge" id="conceito-relatorio"></span>
            <svg class="donut-chart" width="60" height="60" viewBox="0 0 42 42">
              <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#e9ecef" stroke-width="3"></circle>
              <circle class="donut-segment" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#007bff" stroke-width="3" stroke-dasharray="0 100" stroke-dashoffset="25"></circle>
            </svg>
            <div id="relatorio" class="metric-value">0</div>
          </div>
      </div>
      <div class="score-card pos-trabalho">
          <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia o suporte recebido após a conclusão do trabalho da equipe de Controle Interno."></i>
          <div class="card-header score-header" style="padding: 0 !important;">
              <i class="fa fa-briefcase fa-lg card-icon"></i>
              <h3>Pós-Trabalho</h3>
          </div>
          <div class="donut-container">
            <span class="conceito-badge" id="conceito-pos_trabalho"></span>
            <svg class="donut-chart" width="60" height="60" viewBox="0 0 42 42">
              <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#e9ecef" stroke-width="3"></circle>
              <circle class="donut-segment" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#28a745" stroke-width="3" stroke-dasharray="0 100" stroke-dashoffset="25"></circle>
            </svg>
            <div id="pos_trabalho" class="metric-value">0</div>
          </div>
      </div>
      <div class="score-card importancia">
          <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a percepção sobre a contribuição das atividades da equipe de Controle Interno para melhorar o processo avaliado."></i>
          <div class="card-header score-header" style="padding: 0 !important;">
              <i class="fa fa-star fa-lg card-icon"></i>
              <h3>Importância</h3>
          </div>
          <div class="donut-container">
            <span class="conceito-badge" id="conceito-importancia"></span>
            <svg class="donut-chart" width="60" height="60" viewBox="0 0 42 42">
              <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#e9ecef" stroke-width="3"></circle>
              <circle class="donut-segment" cx="21" cy="21" r="15.91549430918954" fill="transparent" stroke="#fd7e14" stroke-width="3" stroke-dasharray="0 100" stroke-dashoffset="25"></circle>
            </svg>
            <div id="importancia" class="metric-value">0</div>
          </div>
      </div>
    </div>
  </div>
</div>

<script>
$(document).ready(function() {
    // Inicializar tooltips
    $('[data-toggle="tooltip"]').tooltip({
        container: 'body',
        html: true,
        delay: {show: 100, hide: 100},
        template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
    });
    
    // Função para animação dos números - melhorada para transição mais suave
    function animateNumberValue(el, start, end, duration) {
        // Se a diferença for mínima, apenas atualize diretamente
        if (Math.abs(end - start) < 0.1) {
            el.textContent = parseFloat(end.toFixed(1));
            return;
        }
        
        // Cancelar qualquer animação anterior
        if (el._animationFrameId) {
            cancelAnimationFrame(el._animationFrameId);
        }
        
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            
            // Usar uma função de easing para uma transição mais suave
            // Esta é uma função de easing "easeOutQuad"
            const easing = 1 - Math.pow(1 - progress, 2);
            const currentValue = start + (end - start) * easing;
            
            el.textContent = parseFloat(currentValue.toFixed(1));
            
            if (progress < 1) {
                el._animationFrameId = window.requestAnimationFrame(step);
            } else {
                // Garantir que o valor final seja exato
                el.textContent = parseFloat(end.toFixed(1));
            }
        };
        el._animationFrameId = window.requestAnimationFrame(step);
    }
    
    // Função para animar os donuts
    function animateDonut(el, start, end, duration) {
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            const currentValue = start + progress * (end - start);
            
            // Atualiza o valor percentual do donut (0-100)
            const percentage = currentValue * 10; // Converte nota 0-10 para porcentagem 0-100
            const dashArray = `${percentage} ${100 - percentage}`;
            el.setAttribute('stroke-dasharray', dashArray);
            
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
    }
    
    // Função para atualizar o badge de conceito
    function atualizarConceitoBadge(id, valor) {
        let conceito = '';
        let classeConceito = '';
        
        // Verificar se o valor é zero ou indefinido
        if (valor === 0 || valor === null || valor === undefined || isNaN(valor)) {
            conceito = 'Sem notas';
            classeConceito = 'conceito-sem-notas';
        } else if (valor >= 9) {
            conceito = 'Ótimo';
            classeConceito = 'conceito-otimo';
        } else if (valor >= 7) {
            conceito = 'Bom';
            classeConceito = 'conceito-bom';
        } else if (valor >= 5) {
            conceito = 'Regular';
            classeConceito = 'conceito-regular';
        } else if (valor >= 3) {
            conceito = 'Ruim';
            classeConceito = 'conceito-ruim';
        } else {
            conceito = 'Péssimo';
            classeConceito = 'conceito-pessimo';
        }
        
        // Selecionar o badge correspondente
        const $badge = $('#conceito-' + id);
        
        // Remover classes anteriores
        $badge.removeClass('conceito-otimo conceito-bom conceito-regular conceito-ruim conceito-pessimo conceito-sem-notas');
        
        // Adicionar a nova classe e texto
        $badge.addClass(classeConceito).text(conceito);
    }
    
    // Armazenar valores anteriores para permitir animação
    window.previousValues = {
        comunicacao: 0,
        interlocucao: 0,
        reuniao: 0,
        relatorio: 0,
        pos_trabalho: 0,
        importancia: 0
    };
    
    // Função para calcular a média dos valores
    function calcularMedia(valores) {
        const valoresValidos = valores.filter(val => !isNaN(parseFloat(val)) && parseFloat(val) > 0);
        if (valoresValidos.length === 0) return 0;
        
        const soma = valoresValidos.reduce((acc, val) => acc + parseFloat(val), 0);
        return soma / valoresValidos.length;
    }
    
    // Função para atualizar os indicadores com base nos dados da tabela
    window.atualizarDashboardPesquisas = function() {
        // Obter a tabela
        const dataTable = $('#tabelaPesquisasDetalhada').DataTable();
        
        // Verificar se a tabela existe e está inicializada
        if (!dataTable) return;
        
        // Obter os dados filtrados da tabela
        const dados = dataTable.rows({search: 'applied'}).data().toArray();
        
        // Atualizar o contador de pesquisas
        $('#total-pesquisas').text(dados.length);
        
        // Se não houver dados, zerar os indicadores
        if (dados.length === 0) {
            const metrics = ['comunicacao', 'interlocucao', 'reuniao', 'relatorio', 'pos_trabalho', 'importancia'];
            metrics.forEach(metric => {
                const el = document.getElementById(metric);
                const donutSegment = $(el).closest('.score-card').find('.donut-segment')[0];
                
                // Atualizar com valor zero
                animateNumberValue(el, window.previousValues[metric], 0, 500);
                animateDonut(donutSegment, window.previousValues[metric], 0, 500);
                atualizarConceitoBadge(metric, 0);
                
                // Atualizar o valor anterior
                window.previousValues[metric] = 0;
            });
            return;
        }
        
        // Calcular as médias para cada categoria
        const comunicacaoValues = dados.map(item => item.comunicacao || 0);
        const interlocucaoValues = dados.map(item => item.interlocucao || 0);
        const reuniaoValues = dados.map(item => item.reuniao || 0);
        const relatorioValues = dados.map(item => item.relatorio || 0);
        const posTrabalhoValues = dados.map(item => item.pos_trabalho || 0);
        const importanciaValues = dados.map(item => item.importancia || 0);
        
        // Calcular médias
        const comunicacaoMedia = calcularMedia(comunicacaoValues);
        const interlocucaoMedia = calcularMedia(interlocucaoValues);
        const reuniaoMedia = calcularMedia(reuniaoValues);
        const relatorioMedia = calcularMedia(relatorioValues);
        const posTrabalhoMedia = calcularMedia(posTrabalhoValues);
        const importanciaMedia = calcularMedia(importanciaValues);
        
        // Atualizar os indicadores
        const metricas = [
            {id: 'comunicacao', valor: comunicacaoMedia},
            {id: 'interlocucao', valor: interlocucaoMedia},
            {id: 'reuniao', valor: reuniaoMedia},
            {id: 'relatorio', valor: relatorioMedia},
            {id: 'pos_trabalho', valor: posTrabalhoMedia},
            {id: 'importancia', valor: importanciaMedia}
        ];
        
        metricas.forEach(metrica => {
            const valorAtual = parseFloat(metrica.valor.toFixed(1));
            const valorAnterior = window.previousValues[metrica.id];
            const el = document.getElementById(metrica.id);
            const donutSegment = $(el).closest('.score-card').find('.donut-segment')[0];
            
            // Animar o número e o donut
            animateNumberValue(el, valorAnterior, valorAtual, 1000);
            animateDonut(donutSegment, valorAnterior, valorAtual, 1000);
            
            // Atualizar o badge de conceito
            atualizarConceitoBadge(metrica.id, valorAtual);
            
            // Atualizar o valor anterior para a próxima animação
            window.previousValues[metrica.id] = valorAtual;
        });
    };
    
    // Inicializar o dashboard assim que a tabela estiver pronta
    $(document).on('init.dt', function(e, settings) {
        if (settings.nTable.id === 'tabelaPesquisasDetalhada') {
            // Inicializar com os dados iniciais após um pequeno delay
            setTimeout(function() {
                window.atualizarDashboardPesquisas();
            }, 500);
        }
    });
    
    // Atualizar o dashboard quando a tabela for filtrada ou redesenhada
    $(document).on('draw.dt', function(e, settings) {
        if (settings.nTable.id === 'tabelaPesquisasDetalhada') {
            window.atualizarDashboardPesquisas();
        }
    });
});
</script>
