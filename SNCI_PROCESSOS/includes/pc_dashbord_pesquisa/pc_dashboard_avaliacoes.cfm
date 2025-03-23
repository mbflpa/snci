<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Avaliacoes.css">

<!-- Primeiro, adicionar o estilo para os badges -->
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
  z-index: 2; /* Garantir que fique em cima de outros elementos */
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
  margin-left: 25px; /* Aumentado para criar mais espaço entre o badge e o donut */
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

/* Para os badges na legenda */
.text-muted.small.px-2.py-1 {
  /* left: -13px !important; */ /* Remover esta linha */
}

/* Container principal para centralizar visualmente */
#avaliacoes-content {
  padding-left: 0;
}

/* Ajuste específico para os ícones de informação */
.info-icon {
  margin-left: 5px;
}

/* Novo estilo para a legenda inline no título */
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
  font-size: 9px; /* Reduzindo um pouco para caber melhor */
  left: -55px; /* Mais afastado para não sobrepor o donut */
  min-width: 50px; /* Garantir espaço para o texto */
}
</style>

<!-- Conteúdo do card de Avaliações -->
<div class="score-cards">
  <div class="score-card comunicacao">
      <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a clareza, frequência e qualidade das interações com a equipe de Controle Interno. Considere se a equipe de Controle Interno foi acessível, transparente e eficaz ao transmitir informações sobre a condução dos trabalhos."></i>
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
      <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia o comportamento da equipe de Controle Interno ao longo do trabalho. Leve em conta o profissionalismo, o respeito e a atitude colaborativa demonstrados durante o processo."></i>
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
      <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a condução da reunião final da equipe de Controle Interno. Considere se a reunião foi clara, direta e se os tópicos foram abordados de maneira simples e objetiva, facilitando o fechamento do processo."></i>
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
      <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a qualidade do relatório entregue ao final do trabalho da equipe de Controle Interno. Considere se o documento foi redigido de forma clara, com informações consistentes e objetivas, facilitando o entendimento das conclusões e recomendações."></i>
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
      <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia o suporte recebido após a conclusão do trabalho da equipe de Controle Interno. Considere se houve disponibilidade para responder dúvidas, se a comunicação foi eficaz e se o atendimento foi prestativo e ágil no período pós-trabalho."></i>
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
      <i class="fas fa-info-circle info-icon" data-toggle="tooltip" data-placement="top" title="Avalia a percepção sobre a contribuição das atividades da equipe de Controle Interno para melhorar o processo avaliado. Considere se o trabalho ajudou a identificar oportunidades de melhoria e contribuiu para o fortalecimento dos controles internos."></i>
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

<script>
$(document).ready(function() {
    // Inicializar tooltips
    $('[data-toggle="tooltip"]').tooltip({
        container: 'body',
        html: true,
        delay: {show: 100, hide: 100},
        template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
    });
    
    // Função para animação dos números
    function animateNumberValue(el, start, end, duration) {
        let startTimestamp = null;
        const step = (timestamp) => {
            if (!startTimestamp) startTimestamp = timestamp;
            const progress = Math.min((timestamp - startTimestamp) / duration, 1);
            const currentValue = start + progress * (end - start);
            el.textContent = parseFloat(currentValue.toFixed(1));
            
            if (progress < 1) {
                window.requestAnimationFrame(step);
            }
        };
        window.requestAnimationFrame(step);
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
    
    // Função para atualizar o badge de conceito - MODIFICADA
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
    
    // Função para atualizar os cards de avaliação
    window.atualizarCardsAvaliacao = function(dados) {
        // Atualizar cards individuais 
        const cards = [
            {id: 'comunicacao', valor: dados.comunicacao},
            {id: 'interlocucao', valor: dados.interlocucao}, 
            {id: 'reuniao', valor: dados.reuniao},
            {id: 'relatorio', valor: dados.relatorio},
            {id: 'pos_trabalho', valor: dados.pos_trabalho},
            {id: 'importancia', valor: dados.importancia}
        ];

        cards.forEach(card => {
            const valor = parseFloat(card.valor) || 0;
            const el = document.getElementById(card.id);
            const previousValue = window.previousValues[card.id];
            
            // Animar o número
            animateNumberValue(el, previousValue, valor, 1000); // 1000ms = 1 segundo de animação
            
            // Animar o donut
            const donutSegment = $(el).closest('.score-card').find('.donut-segment')[0];
            animateDonut(donutSegment, previousValue, valor, 1000);
            
            // Atualizar o badge de conceito com o novo valor
            atualizarConceitoBadge(card.id, valor);
            
            // Atualizar o valor anterior para a próxima animação
            window.previousValues[card.id] = valor;
        });
        
        // Se existir uma área de descrição de filtros, atualizar para incluir diretoria
        if ($("#descricao-filtros-avaliacao").length) {
            let descricao = "Filtros aplicados: ";
            descricao += "Ano: " + (window.anoSelecionado === "Todos" ? "Todos os anos" : window.anoSelecionado);
            descricao += ", Órgão: " + (window.mcuSelecionado === "Todos" ? "Todos os órgãos" : getNomeOrgao(window.mcuSelecionado));
            descricao += ", Diretoria: " + (window.diretoriaSelecionada === "Todos" ? "Todas as diretorias" : getNomeDiretoria(window.diretoriaSelecionada));
            
            $("#descricao-filtros-avaliacao").text(descricao);
        }
    };
});
</script>
