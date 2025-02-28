<cfprocessingdirective pageencoding = "utf-8">	
<cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
    SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_pesquisas ORDER BY ano DESC
</cfquery>
<cfquery name="rsOrgaosOrigem" datasource="#application.dsn_processos#">
    SELECT pc_org_mcu, pc_org_sigla
    FROM pc_orgaos 
    WHERE pc_org_status = 'O'
    ORDER BY pc_org_sigla
</cfquery>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Pesquisas</title>
    <link rel="stylesheet" href="plugins/jqcloud/jqcloud.min.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_PesquisasDashboard.css">
    
    <style>
        #tabelaPesquisas th {
            font-size: smaller; /* Reduz o tamanho da fonte dos cabeçalhos */
        }
        
        /* Estilo para os containers de filtro lado a lado */
        .filtros-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 1.5rem;
        }
    </style>
   
    
</head>
<!-- Estrutura padrão do projeto -->
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <!-- Área que será exportada para PDF -->
            <div id="dashboard-content">
                <section class="content-header">
                    <h1>Dashboard de Pesquisas</h1>
                </section>

                <section class="content">
                    <div class="container-fluid">
                        <!-- Filtros agrupados em um container -->
                        <div class="filtros-container">
                            <!-- Filtro por ano -->
                            <div class="filtro-ano-container">
                                <div class="filtro-ano-label">Processos de:</div>
                                <div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons">
                                    <!-- Botões gerados via JS -->
                                </div>
                            </div>
                            
                            <!-- Novo filtro por órgão -->
                            <div class="filtro-ano-container">
                                <div class="filtro-ano-label">Órgão de origem:</div>
                                <div id="opcoesMcu" class="btn-group btn-group-toggle" data-toggle="buttons">
                                    <!-- Botões gerados via JS -->
                                </div>
                            </div>
                        </div>

                        <!-- Cards de métricas -->
                        <div class="row">
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-info">
                                    <div class="inner">
                                        <h3 id="totalPesquisas">0</h3>
                                        <p>Total de Pesquisas Respondidas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-file-text"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-primary">
                                    <div class="inner">
                                        <h3 id="indiceRespostas">0%</h3>
                                        <p>Índice de Respostas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-percent"></i>
                                    </div>
                                    <p class="formula-text">
                                        Fórmula: (Total Resp. / Total Proc. Acomp. ou Finaliz.) × 100<br>
                                        <span id="formulaDetalhes"></span>
                                    </p>
                                </div>
                            </div>
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-success">  
                                    <div class="inner">
                                        <h3 id="mediaGeral">0</h3>
                                        <p>Média Geral das Notas</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-calculator"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-6">
                                <div class="small-box bg-warning">
                                    <div class="inner">
                                        <h3 id="mediaGeralPontualidade">0</h3>
                                        <p>Pontualidade</p>
                                    </div>
                                    <div class="icon">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!--- Linha divisória entre os cards principais e o sistema de abas --->
                        <div class="dashboard-divider"></div>

                        <!--- Sistema de abas --->
                        <div class="tabs-container">
                          <!--- Navegação das abas (removendo os tab-indicator) --->
                          <ul class="nav nav-dashboard-tabs" id="dashboardTabs" role="tablist">
                            <li class="nav-item">
                              <a class="nav-link active" id="avaliacoes-tab" data-toggle="tab" href="#avaliacoes" role="tab" aria-controls="avaliacoes" aria-selected="true">
                                <i class="fas fa-star"></i>Avaliações
                              </a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="graficos-tab" data-toggle="tab" href="#graficos" role="tab" aria-controls="graficos" aria-selected="false">
                                <i class="fas fa-chart-line"></i>Gráficos
                              </a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="nuvem-palavras-tab" data-toggle="tab" href="#nuvem-palavras" role="tab" aria-controls="nuvem-palavras" aria-selected="false">
                                <i class="fas fa-cloud"></i>Nuvem de Palavras
                              </a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="listagem-tab" data-toggle="tab" href="#listagem" role="tab" aria-controls="listagem" aria-selected="false">
                                <i class="fas fa-list"></i>Listagem de Pesquisas
                              </a>
                            </li>
                          </ul>
                          
                          <!--- Controles de navegação para telas pequenas --->
                          <div class="tabs-controls">
                            <div class="tab-control tab-prev">
                              <i class="fas fa-chevron-left"></i>
                            </div>
                            <div class="tab-control tab-next">
                              <i class="fas fa-chevron-right"></i>
                            </div>
                          </div>
                          
                          <!--- Conteúdo das abas --->
                          <div class="tab-content dashboard-tab-content" id="dashboardTabsContent">
                            
                            <!--- Aba de Avaliações --->
                            <div class="tab-pane fade show active" id="avaliacoes" role="tabpanel" aria-labelledby="avaliacoes-tab">
                              <div class="score-cards">
                                <div class="score-card comunicacao">
                                    <h3>Comunicação <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a clareza, frequência e qualidade das interações com a equipe de Controle Interno. Considere se a equipe de Controle Interno foi acessível, transparente e eficaz ao transmitir informações sobre a condução dos trabalhos."></i></h3>
                                    <div id="comunicacao" class="metric-value">0</div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: 0%"></div>
                                    </div>
                                    <i class="fas fa-comments fa-lg card-icon"></i>
                                </div>
                                <div class="score-card interlocucao">
                                    <h3>Interlocução <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia o comportamento da equipe de Controle Interno ao longo do trabalho. Leve em conta o profissionalismo, o respeito e a atitude colaborativa demonstrados durante o processo."></i></h3>
                                    <div id="interlocucao" class="metric-value">0</div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: 0%"></div>
                                    </div>
                                    <i class="fa fa-exchange card-icon"></i>
                                </div>
                                <div class="score-card reuniao">
                                    <h3>Reunião <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a condução da reunião final da equipe de Controle Interno. Considere se a reunião foi clara, direta e se os tópicos foram abordados de maneira simples e objetiva, facilitando o fechamento do processo."></i></h3>
                                    <div id="reuniao" class="metric-value">0</div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: 0%"></div>
                                    </div>
                                    <i class="fa fa-users card-icon"></i>
                                </div>
                                <div class="score-card relatorio">
                                    <h3>Relatório <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a qualidade do relatório entregue ao final do trabalho da equipe de Controle Interno. Considere se o documento foi redigido de forma clara, com informações consistentes e objetivas, facilitando o entendimento das conclusões e recomendações."></i></h3>
                                    <div id="relatorio" class="metric-value">0</div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: 0%"></div>
                                    </div>
                                    <i class="fa fa-file-text card-icon"></i>
                                </div>
                                <div class="score-card pos-trabalho">
                                    <h3>Pós-Trabalho <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia o suporte recebido após a conclusão do trabalho da equipe de Controle Interno. Considere se houve disponibilidade para responder dúvidas, se a comunicação foi eficaz e se o atendimento foi prestativo e ágil no período pós-trabalho."></i></h3>
                                    <div id="pos_trabalho" class="metric-value">0</div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: 0%"></div>
                                    </div>
                                    <i class="fa fa-briefcase card-icon"></i>
                                </div>
                                <!-- Novo card para Importância do Processo -->
                                <div class="score-card importancia">
                                    <h3>Importância <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avalia a percepção sobre a contribuição das atividades da equipe de Controle Interno para melhorar o processo avaliado. Considere se o trabalho ajudou a identificar oportunidades de melhoria e contribuiu para o fortalecimento dos controles internos."></i></h3>
                                    <div id="importancia" class="metric-value">0</div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: 0%"></div>
                                    </div>
                                    <i class="fa fa-star card-icon"></i>
                                </div>
                              </div>
                            </div>
                            
                            <!--- Aba de Gráficos --->
                            <div class="tab-pane fade" id="graficos" role="tabpanel" aria-labelledby="graficos-tab">
                              <div class="row">
                                <!--- Invertendo a ordem e ajustando larguras --->
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
                                <!--- Mais gráficos conforme necessário --->
                              </div>
                            </div>
                            
                            <!--- Aba de Nuvem de Palavras - Adicionando indicador de carregamento --->
                            <div class="tab-pane fade" id="nuvem-palavras" role="tabpanel" aria-labelledby="nuvem-palavras-tab">
                              <!-- Card explicativo sobre a importância da nuvem de palavras -->
                              <div class="card mb-4">
                                <div class="card-body">
                                  
                                  <p>Este recurso analisa todas as observações textuais deixadas nas pesquisas de satisfação, permitindo identificar tendências, preocupações e temas comuns mencionados pelos respondentes. O tamanho de cada palavra reflete sua frequência nas observações, oferecendo uma visão rápida dos principais assuntos abordados.</p>
                                  <p class="mb-0 text-muted"><small>Clique em uma palavra para ver detalhes sobre sua frequência e relevância no contexto das avaliações.</small></p>
                                </div>
                              </div>
                              
                              <div class="card">
                                <div class="card-header">
                                  <h5 class="card-title">Palavras mais frequentes nas observações das pesquisas</h5>
                                </div>
                                <div class="card-body">
                                  <!-- Adicionar filtros da nuvem de palavras -->
                                  <div class="row mb-3">
                                    <div class="col-md-8">
                                      <div class="form-row align-items-center">
                                        <div class="col-auto">
                                          <label class="mr-2">Frequência mínima:</label>
                                          <input type="number" class="form-control form-control-sm" id="minFreq" value="2" min="1" max="100">
                                        </div>
                                        <div class="col-auto">
                                          <label class="mr-2">Máximo de palavras:</label>
                                          <input type="number" class="form-control form-control-sm" id="maxWords" value="100" min="10" max="300">
                                        </div>
                                        <div class="col-auto">
                                          <button id="atualizarNuvem" class="btn btn-primary btn-sm">
                                            <i class="fas fa-sync-alt mr-1"></i> Atualizar Nuvem
                                          </button>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="word-cloud-container position-relative">
                                    <div id="loadingCloud" style="display: none;">
                                      <i class="fas fa-spinner fa-spin mr-2"></i> Carregando...
                                    </div>
                                    <div id="wordCloud"></div>
                                  </div>
                                  <div class="palavra-info mt-3">
                                    <h5 class="palavra-selecionada"></h5>
                                    <p class="palavra-contexto"></p>
                                  </div>
                                  <!-- Área de detalhes da palavra selecionada - reformatada -->
                                  <div class="card mt-3 palavra-info" style="display: none;">
                                    <div class="card-header py-2">
                                      <h5 class="mb-0" id="palavraTitulo">Detalhes da Palavra</h5>
                                    </div>
                                    <div class="card-body py-2">
                                      <div class="row">
                                        <div class="col-md-6">
                                          <p class="mb-1"><strong>Palavra:</strong> <span id="palavraTexto"></span></p>
                                        </div>
                                        <div class="col-md-3">
                                          <p class="mb-1"><strong>Frequência:</strong> <span id="palavraFreq"></span></p>
                                        </div>
                                        <div class="col-md-3">
                                          <p class="mb-1"><strong>Relevância:</strong> <span id="palavraRelevancia"></span>%</p>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                            
                            <!--- Aba de Listagem de Pesquisas --->
                            <div class="tab-pane fade" id="listagem" role="tabpanel" aria-labelledby="listagem-tab">
                              <div class="table-responsive">
                                <table class="table table-hover" id="tabelaPesquisas">
                                  <thead>
                                    <tr>
                                      <th>ID</th>
                                      <th>Processo</th>
                                      <th>Órgão Respondente</th>
                                      <th>Órgão de Origem</th>
                                      <th>Data</th>
                                      <th>Comunicação</th>
                                      <th>Interlocução</th>
                                      <th>Reunião</th>
                                      <th>Relatório</th>
                                      <th>Pós-Trabalho</th>
                                      <th>Importância</th>
                                      <th>Pontualidade</th>
                                      <th>Média</th>
                                    </tr>
                                  </thead>
                                  <tbody>
                                    <!--- Dados da tabela serão carregados dinamicamente --->
                                  </tbody>
                                </table>
                              </div>
                            </div>
                            
                          </div>
                        </div>

                    </div>
                </section>
            </div>

        </div>
            <cfinclude template="includes/pc_footer.cfm">
    </div>
    <cfinclude template="includes/pc_sidebar.cfm">

    <script src="plugins/chart.js/Chart.min.js"></script>
    <script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
    <script src="plugins/jqcloud/jqcloud.min.js"></script>
    <script>
        $(document).ready(function() {
            // Remover esta linha que causa o erro (Chart.js v2.x usa um método diferente)
            // Chart.register(ChartDataLabels);
            
            // Inicializar tooltips com configurações avançadas
            $('[data-toggle="tooltip"]').tooltip({
                container: 'body',
                html: true,
                delay: {show: 100, hide: 100},
                template: '<div class="tooltip" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>'
            });
            
            var tabela = $('#tabelaPesquisas').DataTable();
            var graficoMedia, graficoEvolucao;
            var anos = [];
            var orgaos = [];
            var currentYear = new Date().getFullYear();
            
            // Obter cores das variáveis CSS para uso no JavaScript
            var coresCategorias = {
                comunicacao: getComputedStyle(document.documentElement).getPropertyValue('--cor-comunicacao').trim(),
                interlocucao: getComputedStyle(document.documentElement).getPropertyValue('--cor-interlocucao').trim(),
                reuniao: getComputedStyle(document.documentElement).getPropertyValue('--cor-reuniao').trim(),
                relatorio: getComputedStyle(document.documentElement).getPropertyValue('--cor-relatorio').trim(),
                postrabalho: getComputedStyle(document.documentElement).getPropertyValue('--cor-pos-trabalho').trim(),
                importancia: getComputedStyle(document.documentElement).getPropertyValue('--cor-importancia').trim()
            };
        
            // Preencher array com os anos da query rsAnoDashboard
            <cfoutput query="rsAnoDashboard">
                anos.push(parseInt("#rsAnoDashboard.ano#", 10));
            </cfoutput>
            if (anos.indexOf(currentYear) === -1) { anos.push(currentYear); }
            anos = anos.sort(function(a, b){ return a - b; }); // Modificado para ordem crescente
            
            // Preencher array com os órgãos da query rsOrgaosOrigem
            <cfoutput query="rsOrgaosOrigem">
                var sigla = "#rsOrgaosOrigem.pc_org_sigla#";
                var mcu = "#rsOrgaosOrigem.pc_org_mcu#";
                var ultimaParte = sigla.includes('/') ? sigla.split('/').pop() : sigla;
                orgaos.push({
                    mcu: mcu,
                    sigla: ultimaParte
                });
            </cfoutput>
        
            // Configuração do filtro de anos
            var radioName = "opcaoAno";
            $("#opcoesAno").empty();
            
            // Adicionar botão "Todos" antes dos anos específicos
            var btnTodos = `<label class="btn btn-outline-secondary btn-todos">
                            <input type="radio" name="${radioName}" autocomplete="off" value="Todos"/> Todos
                       </label>`;
            $("#opcoesAno").append(btnTodos);
            
            anos.forEach(function(val) {
                var isCurrent = (val === currentYear);
                var btnClass = "btn-outline-primary";
                var checked = isCurrent ? 'checked' : '';
                var btn = `<label class="btn ${btnClass}" style="margin-left:2px;">
                                <input type="radio" name="${radioName}" ${checked} autocomplete="off" value="${val}"/> ${val}
                           </label>`;
                $("#opcoesAno").append(btn);
            });

            // Ativar o botão do ano atual após a geração
            if (currentYear) {
                $(`input[name="${radioName}"][value="${currentYear}"]`).parent().addClass('active');
            }
            
            // Configuração do filtro de órgãos
            var radioMcu = "opcaoMcu";
            $("#opcoesMcu").empty();
            
            // Adicionar botão "Todos" para os órgãos
            var btnTodosMcu = `<label class="btn btn-outline-secondary btn-todos">
                            <input type="radio" name="${radioMcu}" checked autocomplete="off" value="Todos"/> Todos
                       </label>`;
            $("#opcoesMcu").append(btnTodosMcu);
            
            // Adicionar botões para cada órgão
            orgaos.forEach(function(orgao) {
                var btn = `<label class="btn btn-outline-info" style="margin-left:2px;">
                                <input type="radio" name="${radioMcu}" autocomplete="off" value="${orgao.mcu}"/> ${orgao.sigla}
                           </label>`;
                $("#opcoesMcu").append(btn);
            });
            
            // Ativar o botão "Todos" para órgãos inicialmente
            $(`input[name="${radioMcu}"][value="Todos"]`).parent().addClass('active');
        
            var anoSelecionado = currentYear;
            var mcuSelecionado = "Todos";
        
            // Garantir que novos elementos também tenham tooltips
            function reiniciarTooltips() {
                $('[data-toggle="tooltip"]').tooltip('dispose').tooltip({
                    container: 'body',
                    html: true
                });
            }
            
            function renderGraficoMedia(medias) {
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
                
                // Configuração para Chart.js v2.x com plugin datalabels
                graficoMedia = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: ['Comunicação','Interlocução','Reunião','Relatório','Pós-Trabalho','Importância'],
                        datasets: [{
                            label: 'Média',
                            data: medias,
                            backgroundColor: cores,
                            barPercentage: 0.5,
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
                                top: 30,
                                bottom: 10
                            }
                        },
                        scales: {
                            yAxes: [{
                                ticks: {
                                    beginAtZero: true,
                                    max: 10
                                }
                            }]
                        },
                        // Configuração atualizada do plugin datalabels para garantir exibição
                        plugins: {
                            datalabels: {
                                display: true,
                                color: '#000',
                                anchor: 'end',
                                align: 'top',
                                offset: -2,
                                backgroundColor: 'rgba(255, 255, 255, 0.8)',
                                borderRadius: 4,
                                borderWidth: 1,
                                borderColor: '#888',
                                padding: {
                                    top: 3,
                                    right: 5,
                                    bottom: 3,
                                    left: 5
                                },
                                font: {
                                    size: 12,
                                    weight: 'bold'
                                },
                                formatter: function(value) {
                                    return value.toFixed(1);
                                },
                                // Adicionar estas propriedades para forçar a exibição
                                clamp: true,
                                clip: false
                            }
                        },
                        // Configuração alternativa para o ChartJS v2.x
                        tooltips: {
                            enabled: true,
                            mode: 'index',
                            intersect: false
                        },
                        animation: {
                            duration: 500,
                            onComplete: function() {
                                // Garantir que os labels sejam exibidos após a animação
                                var ctx = this.chart.ctx;
                                ctx.font = Chart.helpers.fontString(12, 'bold', Chart.defaults.global.defaultFontFamily);
                                ctx.fillStyle = '#000';
                                ctx.textAlign = 'center';
                                ctx.textBaseline = 'bottom';
                                
                                this.data.datasets.forEach(function(dataset, i) {
                                    var meta = this.controller.getDatasetMeta(i);
                                    meta.data.forEach(function(bar, index) {
                                        var data = dataset.data[index];
                                        // Desenhar o valor acima de cada barra
                                        ctx.fillText(data.toFixed(1), bar._model.x, bar._model.y - 5);
                                    });
                                }, this);
                            }
                        }
                    },
                    plugins: [{
                        beforeDraw: function() {
                            // Essa função vazia ajuda a garantir que o plugin seja carregado
                        },
                        afterDraw: function(chart) {
                            // Backup para garantir a exibição dos labels no caso do plugin datalabels falhar
                            if (!window.Chart.defaults.global.plugins.datalabels) {
                                var ctx = chart.ctx;
                                chart.data.datasets.forEach(function(dataset, i) {
                                    var meta = chart.getDatasetMeta(i);
                                    if (!meta.hidden) {
                                        meta.data.forEach(function(element, index) {
                                            ctx.fillStyle = '#000';
                                            var fontSize = 12;
                                            var fontStyle = 'bold';
                                            var fontFamily = Chart.defaults.global.defaultFontFamily;
                                            ctx.font = Chart.helpers.fontString(fontSize, fontStyle, fontFamily);
                                            
                                            var dataString = dataset.data[index].toFixed(1);
                                            
                                            // Desenhar um fundo branco para o texto
                                            ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
                                            var textWidth = ctx.measureText(dataString).width;
                                            ctx.fillRect(
                                                element._model.x - textWidth/2 - 5, 
                                                element._model.y - 25, 
                                                textWidth + 10, 
                                                20
                                            );
                                            
                                            // Desenhar o texto
                                            ctx.fillStyle = '#000';
                                            ctx.textAlign = 'center';
                                            ctx.textBaseline = 'middle';
                                            ctx.fillText(dataString, element._model.x, element._model.y - 15);
                                        });
                                    }
                                });
                            }
                        }
                    }]
                });
            }
        
            function renderGraficoEvolucao(evolucao) {
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
                            legend: { 
                                display: true,
                                position: 'top'
                            },
                            scales: {
                                yAxes: [{
                                    ticks: {
                                        beginAtZero: true,
                                        max: 10
                                    }
                                }]
                            },
                            layout: {
                                padding: {
                                    left: 10,
                                    right: 10,
                                    top: 10,
                                    bottom: 10
                                }
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

                // Resto do código do gráfico
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
                        tooltip: {
                            mode: 'index',
                            intersect: false,
                            callbacks: {
                                label: function(context) {
                                    return 'Média: ' + context.parsed.y.toFixed(2);
                                }
                            }
                        },
                        scales: {
                            yAxes: [{
                                ticks: {
                                    beginAtZero: true,
                                    max: 10,
                                    stepSize: 2,
                                    callback: function(value) {
                                        return value.toFixed(1);
                                    }
                                }
                            }],
                            xAxes: [{
                                gridLines: {
                                    display: false
                                }
                            }]
                        },
                        layout: {
                            padding: {
                                left: 10,
                                right: 10,
                                top: 10,
                                bottom: 10
                            }
                        }
                    }
                });
            }
        
            function atualizarCards(resultado) {
                // Atualizar totalizadores principais
                $("#totalPesquisas").text(resultado.total || '0');
                $("#mediaGeral").text(resultado.mediaGeral || '0');
                $("#mediaGeralPontualidade").text((resultado.pontualidadePercentual || '0') + "%");
                
                // Lógica corrigida do índice de respostas
                if (parseInt(resultado.totalProcessos) === 0) {
                    // Não há processos para essa origem
                    $("#indiceRespostas").text("Processos não localizados").addClass('texto-menor');
                    $(".formula-text").hide();
                } else if (parseInt(resultado.total) === 0) {
                    // Há processos, mas não há pesquisas respondidas (0%)
                    $("#indiceRespostas").text("0%").removeClass('texto-menor');
                    $("#formulaDetalhes").text(`Cálculo: (0 / ${parseInt(resultado.totalProcessos)}) × 100 = 0%`);
                    $(".formula-text").show();
                } else {
                    // Há processos e pesquisas respondidas
                    const totalRespondidas = parseInt(resultado.total) || 0;
                    const totalProcessos = parseInt(resultado.totalProcessos) || 0;
                    const indice = ((totalRespondidas / totalProcessos) * 100).toFixed(1);
                    
                    $("#indiceRespostas").text(indice + "%").removeClass('texto-menor');
                    $("#formulaDetalhes").text(
                        `Cálculo: (${totalRespondidas} / ${totalProcessos}) × 100 = ${indice}%`
                    );
                    $(".formula-text").show();
                }

                // Atualizar cards individuais 
                const cards = [
                    {id: 'comunicacao', valor: resultado.comunicacao},
                    {id: 'interlocucao', valor: resultado.interlocucao}, 
                    {id: 'reuniao', valor: resultado.reuniao},
                    {id: 'relatorio', valor: resultado.relatorio},
                    {id: 'pos_trabalho', valor: resultado.pos_trabalho},
                    {id: 'importancia', valor: resultado.importancia},
                    {id: 'pontualidade', valor: resultado.pontualidadePercentual}
                ];

                cards.forEach(card => {
                    const valor = parseFloat(card.valor) || 0;
                    const el = $(`#${card.id}`);
                    
                    if (card.id === 'pontualidade') {
                        el.text(`${valor.toFixed(1)}%`);
                        el.closest('.score-card').find('.progress-fill').css('width', `${valor}%`);
                    } else {
                        el.text(`${valor.toFixed(1)}`);
                        el.closest('.score-card').find('.progress-fill').css('width', `${(valor * 10)}%`);
                    }
                });
            }
        
            function carregarDashboard(anoFiltro, mcuFiltro) {
                var tabela = configurarDataTable();
                // Primeiro carrega os dados das pesquisas
                $.ajax({
                    url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getPesquisas&returnformat=json',
                    method: 'GET',
                    data: { 
                        ano: anoFiltro,
                        mcuOrigem: mcuFiltro 
                    },
                    dataType: 'json',
                    success: function(data) {
                        if (data && data.DATA) {
                            tabela.clear();
                            data.DATA.forEach(function(row) {
                                var media = ((parseFloat(row[4]) + parseFloat(row[5]) + 
                                            parseFloat(row[6]) + parseFloat(row[7]) + 
                                            parseFloat(row[8]) + parseFloat(row[9])) / 6).toFixed(1);
                                
                                var pontualidade = row[10] == 1 ? "Sim" : "Não"; // Convertendo 1/0 para Sim/Não
                                
                                tabela.row.add([
                                    row[0],   // ID
                                    row[2],   // Processo
                                    row[3],   // órgao que respondeu
                                    row[13],  // órgão origem (corrigido do índice 11 para 13)
                                    row[12],  // Data/Hora
                                    row[4],   // Comunicação
                                    row[5],   // Interlocução
                                    row[6],   // Reunião
                                    row[7],   // Relatório
                                    row[8],   // Pós-Trabalho
                                    row[9],   // Importância do Processo
                                    pontualidade, // Pontualidade como Sim/Não
                                    media     // Média
                                ]);
                            });
                            tabela.draw();
                        }
                    }
                });

                // Depois carrega as estatísticas
                $.ajax({
                    url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                    method: 'GET',
                    data: { 
                        ano: anoFiltro,
                        mcuOrigem: mcuFiltro 
                    },
                    dataType: 'json',
                    success: function(resultado) {
                        if (resultado) {
                            // Atualiza totalizadores e cards
                            atualizarCards(resultado);
                            
                            // Atualiza gráfico de médias
                            if (resultado.medias && Array.isArray(resultado.medias)) {
                                renderGraficoMedia(resultado.medias);
                            }

                            // Atualiza gráfico evolução 
                            if (resultado.evolucaoTemporal && Array.isArray(resultado.evolucaoTemporal)) {
                                renderGraficoEvolucao(resultado.evolucaoTemporal);
                            }
                            
                            // Reiniciar tooltips após atualizar o conteúdo
                            setTimeout(reiniciarTooltips, 500);
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error("Erro ao carregar estatísticas:", error);
                    }
                });
            }
        
            carregarDashboard(anoSelecionado, mcuSelecionado);
            
            // Handler para mudança de ano
            $("input[name='opcaoAno']").change(function() {
                anoSelecionado = $(this).val();
                carregarDashboard(anoSelecionado, mcuSelecionado);
            });
            
            // Handler para mudança de órgão
            $("input[name='opcaoMcu']").change(function() {
                mcuSelecionado = $(this).val();
                carregarDashboard(anoSelecionado, mcuSelecionado);
            });

            // Função helper para scroll adaptado ao AdminLTE
            function scrollToElement(targetElement, offset) {
                // No AdminLTE, o .content-wrapper é o elemento que controla o scroll
                var $scrollContainer = $('.content-wrapper');
                var targetPosition = $(targetElement).offset().top;
                
                // Ajuste para posição relativa dentro do content-wrapper
                var scrollPosition = targetPosition - $scrollContainer.offset().top + $scrollContainer.scrollTop() - (offset || 70);
                
                // Animação de scroll
                $scrollContainer.animate({
                    scrollTop: scrollPosition
                }, 500);
            }

            // Script para nuvem de palavras - função corrigida
            let palavrasData;
            let maxFrequency = 0;
            
            // Função para carregar dados da nuvem de palavras
            window.carregarNuvemPalavras = function() {
                // Obter o ano e o mcu selecionados
                const ano = $("input[name='opcaoAno']:checked").val();
                const mcuOrigem = $("input[name='opcaoMcu']:checked").val();
                const minFreq = $("#minFreq").val() || 1;
                const maxWords = $("#maxWords").val() || 100;
                
                // Verificar se a aba está ativa antes de renderizar
                if (!$("#nuvem-palavras").hasClass('active') && !$("#nuvem-palavras").hasClass('show')) {
                    console.log("Aba da nuvem não está ativa, carregamento adiado");
                    return; // Não carrega se a aba não estiver visível
                }
                
                $("#wordCloud").empty();
                $("#loadingCloud").show();
                $("#palavraInfo").hide();
                
                // Verificações e chamada AJAX
                if (!ano) {
                    $("#wordCloud").html('<div class="alert alert-warning">Por favor, selecione um ano para visualizar a nuvem de palavras.</div>');
                    $("#loadingCloud").hide();
                    return;
                }
                
                // Garantir que o container tenha dimensões
                const containerWidth = $("#wordCloud").parent().width();
                if (!containerWidth) {
                    console.log("Container sem largura definida, tentando novamente em 500ms");
                    setTimeout(window.carregarNuvemPalavras, 500);
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
                            return {
                                text: item.text || "",
                                weight: weight,
                                color: getWordColor(weight),
                                html: { 
                                    title: `${item.text} (${item.weight})`,
                                    'data-weight': weight 
                                }
                            };
                        });
                        
                        // Inicializar nuvem de palavras
                        try {
                            $("#wordCloud").jQCloud('destroy');
                        } catch(e) { /* Ignora se não existir */ }
                        
                        $("#wordCloud").jQCloud(dadosFormatados, {
                            width: $("#wordCloud").parent().width(),
                            height: 400,
                            delay: 50,
                            shape: 'elliptic',
                            colors: ["#9C27B0", "#4CAF50", "#33A8FF", "#FFA500", "#FF5733"],
                            afterCloudRender: function() {
                                // Adicionar eventos de clique às palavras
                                $(".jqcloud-word").click(function() {
                                    const texto = $(this).text();
                                    const palavra = palavrasData.find(function(p) { return p.text === texto; });
                                    
                                    if (palavra) {
                                        const relevancia = ((palavra.weight / maxFrequency) * 100).toFixed(1);
                                        
                                        $("#palavraTexto").text(palavra.text);
                                        $("#palavraTitulo").text("Detalhes da Palavra: " + palavra.text);
                                        $("#palavraFreq").text(palavra.weight);
                                        $("#palavraRelevancia").text(relevancia);
                                        
                                        // Mostrar o card de detalhes da palavra e então scroll
                                        $(".card.palavra-info").fadeIn(400, function() {
                                            // Usar a função helper para scroll
                                            scrollToElement(".card.palavra-info", 100);
                                        });
                                    }
                                });
                                
                                $("#loadingCloud").hide();
                            }
                        });
                    },
                    error: function(xhr, status, error) {
                        console.error("Erro ao carregar dados da nuvem:", error);
                        console.log("Status:", status);
                        console.log("Resposta:", xhr.responseText);
                        $("#wordCloud").html(`<div class="alert alert-danger">
                            <strong>Erro ao carregar a nuvem de palavras.</strong><br>
                            Detalhes: ${error || "Sem detalhes disponíveis"}<br>
                            Por favor, verifique o console para mais informações.
                        </div>`);
                        $("#loadingCloud").hide();
                    }
                });
            };
            
            // Eventos para carregar a nuvem de palavras
            
            // Evento do botão atualizar nuvem
            $("#atualizarNuvem").click(function() {
                carregarNuvemPalavras();
            });
            
            // Evento de mudança de ano ou mcu - recarregar nuvem
            $("input[name='opcaoAno'], input[name='opcaoMcu']").change(function() {
                setTimeout(function() {
                    if ($("#nuvem-palavras").hasClass('active') || $("#nuvem-palavras").hasClass('show')) {
                        window.carregarNuvemPalavras();
                    }
                }, 500);
            });
            
            // Responsividade - redimensionar a nuvem quando a janela mudar de tamanho
            $(window).resize(function() {
                if (palavrasData && palavrasData.length > 0) {
                    try {
                        $("#wordCloud").jQCloud('destroy');
                    } catch(e) { /* Ignora se não existir */ }
                    
                    // Recalcular dados com cores ao redimensionar
                    const dadosFormatados = palavrasData.map(function(item) {
                        const weight = parseFloat(item.weight) || 1;
                        // Recalcular cor baseada no peso
                        const percentage = weight / maxFrequency;
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
                                title: `${item.text} (${item.weight})`,
                                'data-weight': weight 
                            }
                        };
                    });
                    
                    $("#wordCloud").jQCloud(dadosFormatados, {
                        width: $("#wordCloud").parent().width(),
                        height: 400,
                        colors: ["#9C27B0", "#4CAF50", "#33A8FF", "#FFA500", "#FF5733"],
                        afterCloudRender: function() {
                            // Re-adicionar eventos de clique após redimensionamento
                            $(".jqcloud-word").click(function() {
                                const texto = $(this).text();
                                const palavra = palavrasData.find(function(p) { return p.text === texto; });
                                
                                if (palavra) {
                                    const relevancia = ((palavra.weight / maxFrequency) * 100).toFixed(1);
                                    
                                    $("#palavraTexto").text(palavra.text);
                                    $("#palavraTitulo").text("Detalhes da Palavra: " + palavra.text);
                                    $("#palavraFreq").text(palavra.weight);
                                    $("#palavraRelevancia").text(relevancia);
                                    
                                    // Mostrar o card de detalhes da palavra e então scroll
                                    $(".card.palavra-info").fadeIn(400, function() {
                                        // Usar a função helper para scroll
                                        scrollToElement(".card.palavra-info", 100);
                                    });
                                }
                            });
                        }
                    });
                }
            });
        
            /**
            * Script para gerenciar as abas do Dashboard de Pesquisas
            */
            // Inicializar as abas
            $('.nav-dashboard-tabs .nav-link:first').tab('show');
            
            // Manipular clique nas abas
            $('.nav-dashboard-tabs .nav-link').on('click', function(e) {
                e.preventDefault();
                
                // Armazenar referência para o elemento atual
                var $this = $(this);
                
                // Mostrar a aba
                $this.tab('show');
                
                // Aguardar um momento para a aba ser mostrada antes de rolar
                setTimeout(function() {
                    // Usar a função helper para scroll
                    scrollToElement('.tabs-container', 70);
                    
                    // Resto do processamento para a aba específica
                    const tabId = $this.attr('href');
                    
                    // A partir daqui, o código existente processa as ações específicas para cada aba
                    if (tabId === '#graficos') {
                        // Forçar um redimensionamento para garantir que os gráficos sejam renderizados corretamente
                        setTimeout(function() {
                            $(window).trigger('resize');
                            
                            // Se houver funções específicas para atualizar os gráficos, chame-as aqui
                            if (typeof window.renderGraficoMedia === 'function' && typeof window.renderGraficoEvolucao === 'function') {
                                // Carregar os dados novamente se necessário
                                const anoSelecionado = $("input[name='opcaoAno']:checked").val();
                                const mcuSelecionado = $("input[name='opcaoMcu']:checked").val();
                                
                                $.ajax({
                                    url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
                                    method: 'GET',
                                    data: { 
                                        ano: anoSelecionado,
                                        mcuOrigem: mcuSelecionado 
                                    },
                                    dataType: 'json',
                                    success: function(resultado) {
                                        if (resultado) {
                                            // Recarregar os gráficos com os dados atualizados
                                            if (resultado.medias && Array.isArray(resultado.medias)) {
                                                window.renderGraficoMedia(resultado.medias);
                                            }
                                            if (resultado.evolucaoTemporal && Array.isArray(resultado.evolucaoTemporal)) {
                                                window.renderGraficoEvolucao(resultado.evolucaoTemporal);
                                            }
                                        }
                                    }
                                });
                            }
                        }, 200);
                    }
                    
                    // Atualizar nuvem de palavras se estiver na aba correspondente
                    if (tabId === '#nuvem-palavras') {
                        // Esconder detalhes da palavra ao mudar para a aba
                        $(".card.palavra-info").hide();
                        
                        // Esperar que a aba esteja visível antes de carregar a nuvem
                        setTimeout(function() {
                            if (typeof window.carregarNuvemPalavras === 'function') {
                                window.carregarNuvemPalavras();
                            } else {
                                console.warn("Função carregarNuvemPalavras não encontrada");
                            }
                        }, 300);
                    }
                    
                    // Atualizar tabela de listagem quando abrir a aba
                    if (tabId === '#listagem') {
                        if ($.fn.DataTable.isDataTable('#tabelaPesquisas')) {
                            $('#tabelaPesquisas').DataTable().columns.adjust().draw();
                        }
                    }
                }, 300);
            });
            
            // Verificar se a aba da nuvem já está ativa no carregamento inicial
            if ($('#nuvem-palavras-tab').hasClass('active') && typeof window.carregarNuvemPalavras === 'function') {
                setTimeout(window.carregarNuvemPalavras, 500);
            }
            
            // Controles de navegação das abas
            $('.tab-prev').on('click', function() {
                scrollTabs(-100);
            });
            
            $('.tab-next').on('click', function() {
                scrollTabs(100);
            });
            
            // Verificar se é necessário mostrar os controles de navegação
            checkTabsOverflow();
            $(window).on('resize', checkTabsOverflow);
            
            // Função para rolar as abas
            function scrollTabs(amount) {
                const $tabs = $('.nav-dashboard-tabs');
                $tabs.animate({
                    scrollLeft: $tabs.scrollLeft() + amount
                }, 300);
            }
            
            // Verificar se há overflow nas abas
            function checkTabsOverflow() {
                const $tabs = $('.nav-dashboard-tabs');
                if ($tabs.length) {
                    const tabsContainer = $tabs[0];
                    const hasOverflow = tabsContainer.scrollWidth > tabsContainer.clientWidth;
                    
                    if (hasOverflow) {
                        $('.tabs-controls').show(); // Corrigido o seletor (removido o ponto extra)
                    } else {
                        $('.tabs-controls').hide(); // Corrigido o seletor (removido o ponto extra)
                    }
                }
            }

        });

        function configurarDataTable() {
            var currentDate = new Date()
			var day = currentDate.getDate()
			var month = currentDate.getMonth() + 1
			var year = currentDate.getFullYear()
			var d = day + "-" + month + "-" + year;
            return $('#tabelaPesquisas').DataTable({
                destroy: true,
                processing: true,
                serverSide: false,
                responsive: true,
                pageLength: 5, // Alterado de 10 para 5 registros por página
                dom: 
                    "<'row d-flex align-items-center'<'col-auto'B><'col-auto'f><'col-auto'p>>" + // Removido dtsp-verticalContainer e P
                    "<'row'<'col-12'i>>" + // Informações logo abaixo dos botões
                    "<'row'<'col-12'tr>>",  // Tabela com todos os dados
                buttons: [
                    {
                        extend: 'excel',
                        text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
                        title : 'SNCI_Pesquisas_Respondidas_' + d,
                        className: 'btExcel',
                    }
                ],
                columnDefs: [
                    { className: "text-center", targets: [5, 6, 7, 8, 9, 10, 11, 12] } // Ajustado para incluir todas as colunas numéricas
                ],
                language: {
                    url: "plugins/datatables/traducao.json"
                },
                initComplete: function() {
                    tableInitialized = true;
                    
                    // Ajustar colunas após inicialização para garantir o layout correto
                    $(window).on('resize', function() {
                        if (tableInitialized) {
                            // Corrigindo a variável table para tabela
                            $('#tabelaPesquisas').DataTable().columns.adjust().draw();
                        }
                    });
                }
            });
        }
    </script>
</body>
</html>
