<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Avaliacoes.css">

<!-- Conteúdo do card de Avaliações -->
<div class="score-cards">
  <div class="score-card comunicacao">
      <h3>Comunicação <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a clareza, frequência e qualidade das interações com a equipe de Controle Interno. Considere se a equipe de Controle Interno foi acessível, transparente e eficaz ao transmitir informações sobre a condução dos trabalhos."></i></h3>
      <div class="value-icon-container">
          <div id="comunicacao" class="metric-value">0</div>
          <i class="fas fa-comments fa-lg card-icon"></i>
      </div>
      <div class="progress-bar">
          <div class="progress-fill" style="width: 0%"></div>
      </div>
  </div>
  <div class="score-card interlocucao">
      <h3>Interlocução <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia o comportamento da equipe de Controle Interno ao longo do trabalho. Leve em conta o profissionalismo, o respeito e a atitude colaborativa demonstrados durante o processo."></i></h3>
      <div class="value-icon-container">
          <div id="interlocucao" class="metric-value">0</div>
          <i class="fa fa-exchange card-icon"></i>
      </div>
      <div class="progress-bar">
          <div class="progress-fill" style="width: 0%"></div>
      </div>
  </div>
  <div class="score-card reuniao">
      <h3>Reunião <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a condução da reunião final da equipe de Controle Interno. Considere se a reunião foi clara, direta e se os tópicos foram abordados de maneira simples e objetiva, facilitando o fechamento do processo."></i></h3>
      <div class="value-icon-container">
          <div id="reuniao" class="metric-value">0</div>
          <i class="fa fa-users card-icon"></i>
      </div>
      <div class="progress-bar">
          <div class="progress-fill" style="width: 0%"></div>
      </div>
  </div>
  <div class="score-card relatorio">
      <h3>Relatório <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a qualidade do relatório entregue ao final do trabalho da equipe de Controle Interno. Considere se o documento foi redigido de forma clara, com informações consistentes e objetivas, facilitando o entendimento das conclusões e recomendações."></i></h3>
      <div class="value-icon-container">
          <div id="relatorio" class="metric-value">0</div>
          <i class="fa fa-file-text card-icon"></i>
      </div>
      <div class="progress-bar">
          <div class="progress-fill" style="width: 0%"></div>
      </div>
  </div>
  <div class="score-card pos-trabalho">
      <h3>Pós-Trabalho <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia o suporte recebido após a conclusão do trabalho da equipe de Controle Interno. Considere se houve disponibilidade para responder dúvidas, se a comunicação foi eficaz e se o atendimento foi prestativo e ágil no período pós-trabalho."></i></h3>
      <div class="value-icon-container">
          <div id="pos_trabalho" class="metric-value">0</div>
          <i class="fa fa-briefcase card-icon"></i>
      </div>
      <div class="progress-bar">
          <div class="progress-fill" style="width: 0%"></div>
      </div>
  </div>
  <!-- Card para Importância do Processo -->
  <div class="score-card importancia">
      <h3>Importância <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a percepção sobre a contribuição das atividades da equipe de Controle Interno para melhorar o processo avaliado. Considere se o trabalho ajudou a identificar oportunidades de melhoria e contribuiu para o fortalecimento dos controles internos."></i></h3>
      <div class="value-icon-container">
          <div id="importancia" class="metric-value">0</div>
          <i class="fa fa-star card-icon"></i>
      </div>
      <div class="progress-bar">
          <div class="progress-fill" style="width: 0%"></div>
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
            const el = $(`#${card.id}`);
            
            el.text(`${valor.toFixed(1)}`);
            el.closest('.score-card').find('.progress-fill').css('width', `${(valor * 10)}%`);
        });
    };
});
</script>
