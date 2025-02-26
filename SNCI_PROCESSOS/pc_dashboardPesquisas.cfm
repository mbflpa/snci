<cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
    SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_pesquisas ORDER BY ano DESC
</cfquery>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Pesquisas</title>
    <link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">
   
    <style>
        /* Estilos básicos inspirados no dashboard-export.html */
        body { background-color: #f7f7f7; }
        .header { background-color: #fff; box-shadow: 0 1px 2px rgba(0,0,0,0.05); padding: 1rem; }
        .header h1 { font-size: 1.5rem; color: #111827; text-align: center; }
        .content-wrapper { padding: 20px; overflow-y: auto; max-height: calc(100vh - 130px); }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit,minmax(250px,1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .metric-card { background: #fff; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .metric-label { font-size: 0.875rem; color: #6b7280; }
        .metric-value { font-size: 1.875rem; font-weight: 600; color: #111827; }

        /* Novos estilos modernos para os score cards */
        .score-cards {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin-bottom: 2rem;
        }
        
        .score-card {
            position: relative;
            padding: 1.25rem 1rem;
            border-radius: 12px;
            background: #fff;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.05), 0 4px 6px -2px rgba(0,0,0,0.03);
            margin-bottom: 0.5rem;
            min-height: 110px;
            border: none;
            transition: all 0.3s ease;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        
        .score-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
        }
        
        .score-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 6px;
            height: 100%;
            border-radius: 6px 0 0 6px;
        }
        
        .score-card .heading-container {
            position: relative;
            display: flex;
            align-items: center;
            margin-bottom: 0.3rem;
        }
        
        .score-card h3 {
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 0;
            color: #2d3748;
            display: flex;
            align-items: center;
        }
        
        /* Remover os ícones originais que ficam na frente dos títulos */
        .score-card h3 i.fas,
        .score-card h3 i.fa {
            display: none;
        }
        
        /* Mantém visível apenas o ícone de tooltip */
        .score-card h3 i.tooltip-icon {
            display: inline-block !important;
        }
        
        /* Estilo para o ícone de tooltip */
        .tooltip-icon {
            margin-left: 5px;
            font-size: 0.8rem;
            color: rgba(0, 0, 0, 0.5);
            cursor: help;
            opacity: 0.8;
            transition: opacity 0.3s ease;
        }
        
        .tooltip-icon:hover {
            opacity: 1;
        }
        
        /* Adicionando ajuste específico para ícones nos score cards */
        .score-card h3 .tooltip-icon {
            color: inherit;
            opacity: 0.6;
        }
        
        .score-card h3 .tooltip-icon:hover {
            opacity: 1;
        }
        
        /* Novo estilo para os ícones grandes do lado direito */
        .score-card .card-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 2.5rem;
            opacity: 0.6;
            text-shadow: 0 1px 3px rgba(0,0,0,0.2);
            transition: all 0.3s ease;
        }
        
        /* Cores dos ícones correspondentes às cores das barras de progresso */
        .comunicacao .card-icon {
            color: #17a2b8;
        }
        
        .interlocucao .card-icon {
            color: #6f42c1;
        }
        
        .reuniao .card-icon {
            color: #dc3545;
        }
        
        .relatorio .card-icon {
            color: #007bff;
        }
        
        .pos-trabalho .card-icon {
            color: #28a745;
        }
        
        .pontualidade .card-icon {
            color: #ffc107;
        }
        
        .score-card:hover .card-icon {
            font-size: 2.7rem;
            opacity: 0.8;
        }
        
        .score-card .icon-container {
            position: absolute;
            top: 0.75rem;
            right: 0.75rem;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            color: white;
            display: none; /* Ocultando o contêiner original do ícone */
        }
        
        .score-card .metric-value {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0.15rem 0 0.5rem;
            color: #1a202c;
        }
        
        .progress-container {
            position: relative;
            width: 100%;
            margin-top: auto;
        }
        
        .progress-bar {
            height: 5px;
            background: rgba(203, 213, 224, 0.3)!important;
            border-radius: 9999px;
            overflow: hidden;
            position: relative;
        }
        
        .progress-fill {
            height: 100%;
            transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
            position: absolute;
            top: 0;
            left: 0;
            border-radius: 9999px;
        }
        
        .progress-label {
            display: flex;
            justify-content: space-between;
            font-size: 0.65rem;
            color: #718096;
            margin-top: 0.2rem;
        }
        
        /* Estilos específicos para cada tipo de score card */
        .comunicacao::before { background: #17a2b8; }
        .comunicacao .icon-container { background: linear-gradient(135deg, #17a2b8, #138496); }
        .comunicacao .progress-fill { background: linear-gradient(90deg, #17a2b8, #138496); }
        
        .interlocucao::before { background: #6f42c1; }
        .interlocucao .icon-container { background: linear-gradient(135deg, #6f42c1, #5e35b1); }
        .interlocucao .progress-fill { background: linear-gradient(90deg, #6f42c1, #5e35b1); }
        
        .reuniao::before { background: #dc3545; }
        .reuniao .icon-container { background: linear-gradient(135deg, #dc3545, #c82333); }
        .reuniao .progress-fill { background: linear-gradient(90deg, #dc3545, #c82333); }
        
        .relatorio::before { background: #007bff; }
        .relatorio .icon-container { background: linear-gradient(135deg, #007bff, #0069d9); }
        .relatorio .progress-fill { background: linear-gradient(90deg, #007bff, #0069d9); }
        
        .pos-trabalho::before { background: #28a745; }
        .pos-trabalho .icon-container { background: linear-gradient(135deg, #28a745, #218838); }
        .pos-trabalho .progress-fill { background: linear-gradient(90deg, #28a745, #218838); }
        
        .pontualidade::before { background: #ffc107; }
        .pontualidade .icon-container { background: linear-gradient(135deg, #ffc107, #e0a800); }
        .pontualidade .progress-fill { background: linear-gradient(90deg, #ffc107, #e0a800); }

        /* Adicionando animação para o valor */
        @keyframes countUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .score-card .metric-value {
            animation: countUp 0.8s ease-out forwards;
        }

        /* Filtro de anos com rótulo */
        .filtro-ano-container {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .filtro-ano-label {
            font-size: 1rem;
            font-weight: 500;
            margin-right: 1rem;
            color: #495057;
            white-space: nowrap;
        }
        
        .btn-group .btn.active {
            background-color: #007bff !important;
            border-color: #0056b3 !important;
            color: white !important;
        }

        /* Estilos para a tabela */
        .table-container { background: #fff; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; margin-top:2rem; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 1rem 1.5rem; border-bottom: 1px solid #e5e7eb; }

        .table-responsive {
            margin: 2rem 0;
            background: #fff;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.08);
        }
        
        .table thead th {
            background: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
            color: #495057;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.85rem;
            padding: 1rem;
            vertical-align: middle;
        }
        
        .table tbody td {
            padding: 0.75rem 1rem;
            vertical-align: middle;
            border-bottom: 1px solid #edf2f7;
            color: #4a5568;
            font-size: 0.9rem;
        }

        .table-hover tbody tr:hover {
            background-color: #f8fafc;
        }

        .dataTables_wrapper .dataTables_length,
        .dataTables_wrapper .dataTables_filter {
            margin-bottom: 1rem;
        }

        .dataTables_wrapper .dataTables_info {
            padding-top: 1rem;
            color: #718096;
        }

        .dataTables_wrapper .dataTables_paginate {
            padding-top: 1rem;
        }

        /* Estilo para o botão de exportação */
        .export-pdf-btn {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 1000;
            padding: 10px 15px;
            border-radius: 4px;
            background-color: #28a745;
            color: white;
            border: none;
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .export-pdf-btn:hover {
            background-color: #218838;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        
        @media print {
            .export-pdf-btn {
                display: none;
            }
        }

        /* Ajuste para manter altura consistente do card */
        .small-box .inner {
            min-height: 120px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        
        .small-box .inner h3 {
            min-height: 40px;
            display: flex;
            align-items: center;
        }

        /* Novo estilo para o texto de 'não há pesquisas' */
        .small-box .inner h3.texto-menor {
            font-size: 1.2rem;
        }

        .formula-text {
            font-size: 0.6rem!important;
            color: rgba(255,255,255,0.7);
            position: absolute;
            bottom: 5px;
            left: 10px;
            right: 10px;
            margin: 0;
            line-height: 1.1;
            display: none;
        }

        .small-box {
            position: relative;
            overflow: visible;
            margin-bottom: 20px;
        }

        /* Adicionando estilo para os containers dos gráficos */
        .card-body canvas {
            min-height: 400px;
        }
    </style>
</head>
<!-- Estrutura padrão do projeto -->
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        <cfinclude template="includes/pc_sidebar.cfm">
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <!-- Área que será exportada para PDF -->
            <div id="dashboard-content">
                <section class="content-header">
                    <div class="container-fluid">
                        <div class="row mb-2">
                            <div class="col-sm-6">
                                <h1>Dashboard de Pesquisas</h1>
                            </div>
                            
                        </div>
                    </div>
                </section>

                <section class="content">
                    <div class="container-fluid">
                        <!-- Filtro por ano com texto descritivo -->
                        <div class="row mb-4">
                            <div class="col-md-12">
                                <div class="filtro-ano-container">
                                    <div class="filtro-ano-label">Processos de:</div>
                                    <div id="opcoesAno" class="btn-group btn-group-toggle" data-toggle="buttons">
                                        <!-- Botões gerados via JS -->
                                    </div>
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
                                        <i class="fas fa-chart-line"></i>
                                    </div>
                                    <p class="formula-text">
                                        Fórmula: (Total Respondidas / Total Processos) × 100<br>
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
                                        <i class="fas fa-star"></i>
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

                        <!-- Score Cards com design moderno -->
                        <div class="row">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h3 class="card-title">Avaliações</h3>
                                    </div>
                                    <div class="card-body">
                                        <div class="score-cards">
                                            <div class="score-card comunicacao">
                                                <h3>Comunicação <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avaliação da comunicação durante o processo"></i></h3>
                                                <div id="comunicacao" class="metric-value">0</div>
                                                <div class="progress-bar">
                                                    <div class="progress-fill" style="width: 0%"></div>
                                                </div>
                                                <i class="fas fa-comments fa-lg card-icon"></i>
                                            </div>
                                            <div class="score-card interlocucao">
                                                <h3>Interlocução <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avaliação da interlocução durante o processo"></i></h3>
                                                <div id="interlocucao" class="metric-value">0</div>
                                                <div class="progress-bar">
                                                    <div class="progress-fill" style="width: 0%"></div>
                                                </div>
                                                <i class="fa fa-exchange card-icon"></i>
                                            </div>
                                            <div class="score-card reuniao">
                                                <h3>Reunião <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avaliação das reuniões realizadas"></i></h3>
                                                <div id="reuniao" class="metric-value">0</div>
                                                <div class="progress-bar">
                                                    <div class="progress-fill" style="width: 0%"></div>
                                                </div>
                                                <i class="fa fa-users card-icon"></i>
                                            </div>
                                            <div class="score-card relatorio">
                                                <h3>Relatório <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avaliação dos relatórios entregues"></i></h3>
                                                <div id="relatorio" class="metric-value">0</div>
                                                <div class="progress-bar">
                                                    <div class="progress-fill" style="width: 0%"></div>
                                                </div>
                                                <i class="fa fa-file-text card-icon"></i>
                                            </div>
                                            <div class="score-card pos-trabalho">
                                                <h3>Pós-Trabalho <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avaliação do trabalho pós-processo"></i></h3>
                                                <div id="pos_trabalho" class="metric-value">0</div>
                                                <div class="progress-bar">
                                                    <div class="progress-fill" style="width: 0%"></div>
                                                </div>
                                                <i class="fa fa-briefcase card-icon"></i>
                                            </div>
                                            <!-- Card adicional para Pontualidade -->
                                            <div class="score-card pontualidade">
                                                <h3>Pontualidade <i class="fas fa-info-circle tooltip-icon" data-toggle="tooltip" data-placement="top" title="Avaliação da pontualidade"></i></h3>
                                                <div id="pontualidade" class="metric-value">0%</div>
                                                <div class="progress-bar">
                                                    <div class="progress-fill" style="width: 0%"></div>
                                                </div>
                                                <i class="fa fa-clock card-icon"></i>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Gráficos -->
                        <div class="row" style="margin-top:2rem;">
                            <div class="col-md-4">
                                <div class="card">
                                    <div class="card-header">
                                        <h3 class="card-title">Médias por Categoria</h3>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="graficoMedia"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8">
                                <div class="card">
                                    <div class="card-header">
                                        <h3 class="card-title">Evolução Temporal</h3>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="graficoEvolucao"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </div>

            <!-- Tabela separada do conteúdo do PDF -->
            <section class="content">
                <div class="container-fluid">
                    <div class="card">
                        <div class="card-header">
                            <h3 class="card-title">Listagem de Pesquisas</h3>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table id="tabelaPesquisas" class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Matrícula</th>
                                            <th>Processo</th>
                                            <th>MCU</th>
                                            <th>Data Resp.</th>
                                            <th>Comunicação</th>
                                            <th>Interlocução</th>
                                            <th>Reunião</th>
                                            <th>Relatório</th>
                                            <th>Pós-Trabalho</th>
                                            <th>Pontualidade</th>
                                            <th>Média</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Conteúdo gerado via JS -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
        


        <!-- Rodapé -->
        <footer class="main-footer text-center">
            <cfinclude template="includes/pc_footer.cfm">
        </footer>
    </div>

    <script src="plugins/chart.js/Chart.min.js"></script>
    <script src="plugins/chart.js/chartjs-plugin-datalabels.min.js"></script>
    <script>
        $(document).ready(function() {
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
            var currentYear = new Date().getFullYear();
        
            // Preencher array com os anos da query rsAnoDashboard
            <cfoutput query="rsAnoDashboard">
                anos.push(parseInt("#rsAnoDashboard.ano#", 10));
            </cfoutput>
            if (anos.indexOf(currentYear) === -1) { anos.push(currentYear); }
            anos = anos.sort(function(a, b){ return a - b; }); // Modificado para ordem crescente
        
            var radioName = "opcaoAno";
            $("#opcoesAno").empty();
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
        
            var anoSelecionado = currentYear;
        
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
                graficoMedia = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: ['Comunicação','Interlocução','Reunião','Relatório','Pós-Trabalho'],
                        datasets: [{
                            label: 'Média',
                            data: medias,
                            backgroundColor: 'rgba(54, 162, 235, 0.6)',
                            barPercentage: 0.5,
                            categoryPercentage: 0.8
                        }]
                    },
                    options: {
                        maintainAspectRatio: false,
                        responsive: true,
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 10
                            }
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
                                borderColor: '#17a2b8',
                                backgroundColor: 'rgba(23, 162, 184, 0.1)',
                                borderWidth: 2,
                                fill: true,
                                tension: 0.4
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { display: true, position: 'top' }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    max: 10
                                }
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
                            borderColor: '#17a2b8',
                            backgroundColor: 'rgba(23, 162, 184, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
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
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 10,
                                ticks: {
                                    stepSize: 2,
                                    callback: function(value) {
                                        return value.toFixed(1);
                                    }
                                }
                            },
                            x: {
                                grid: {
                                    display: false
                                }
                            }
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
                
                // Modificar lógica do índice de respostas
                if (parseInt(resultado.total) === 0 || parseInt(resultado.totalProcessos) === 0) {
                    $("#indiceRespostas").text("Não há pesquisas respondidas").addClass('texto-menor');
                    $(".formula-text").hide();
                } else {
                    const totalRespondidas = parseInt(resultado.total) || 0;
                    const totalProcessos = parseInt(resultado.totalProcessos) || 0;
                    const indice = ((totalRespondidas / totalProcessos) * 100).toFixed(2);
                    
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
        
            function carregarDashboard(anoFiltro) {
                var tabela = configurarDataTable();
                // Primeiro carrega os dados das pesquisas
                $.ajax({
                    url: 'cfc/pc_cfcDashboardPesquisas.cfc?method=getPesquisas&returnformat=json',
                    method: 'GET',
                    data: { ano: anoFiltro },
                    dataType: 'json',
                    success: function(data) {
                        if (data && data.DATA) {
                            tabela.clear();
                            data.DATA.forEach(function(row) {
                                var media = ((parseFloat(row[4]) + parseFloat(row[5]) + 
                                            parseFloat(row[6]) + parseFloat(row[7]) + 
                                            parseFloat(row[8])) / 5).toFixed(2);
                                
                                var pontualidade = row[9] == 1 ? "Sim" : "Não"; // Convertendo 1/0 para Sim/Não
                                
                                tabela.row.add([
                                    row[0],   // ID
                                    row[1],   // Matrícula
                                    row[2],   // Processo
                                    row[3],   // MCU
                                    row[12],  // Data/Hora
                                    row[4],   // Comunicação
                                    row[5],   // Interlocução
                                    row[6],   // Reunião
                                    row[7],   // Relatório
                                    row[8],   // Pós-Trabalho
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
                    url: 'cfc/pc_cfcDashboardPesquisas.cfc?method=getEstatisticas&returnformat=json',
                    method: 'GET',
                    data: { ano: anoFiltro },
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
        
            carregarDashboard(anoSelecionado);
            $("input[name='opcaoAno']").change(function() {
                var novoAno = $(this).val();
                carregarDashboard(novoAno);
            });
        });

        // Configuração do DataTable similar ao pc_Usuarios.cfm
        function configurarDataTable() {
            return $('#tabelaPesquisas').DataTable({
                destroy: true,
                processing: true,
                serverSide: false,
                responsive: true,
                pageLength: 10,
                dom: "<'row'<'col-sm-4'<'dtsp-dataTable'Bf>><'col-sm-8 text-left'p>>" + 
                     "<'col-sm-12 text-left'i>" + 
                     "<'row'<'col-sm-12'tr>>",
                buttons: [
                    {
                        extend: 'excel',
                        text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
                        className: 'btExcel',
                        title: 'SNCI_Pesquisas_' + new Date().toLocaleDateString(),
                        exportOptions: {
                            columns: ':visible'
                        }
                    },
                    {
                        extend: 'colvis',
                        text: 'Selecionar Colunas',
                        className: 'btSelecionarColuna',
                        collectionLayout: 'fixed three-column',
                    },
                    {
                        text: '<i class="fas fa-eye" title="Visualizar todas as colunas."></i>',
                        action: function (e, dt, node, config) {
                            dt.columns().visible(true);
                        },
                    },
                    {
                        text: '<i class="fas fa-eye-slash" title="Oculta todas as colunas."></i>',
                        action: function (e, dt, node, config) {
                            dt.columns().visible(false);
                        },
                    }
                ],
                columnDefs: [
                    {
                        // Colunas numéricas (notas e média)
                        targets: [5,6,7,8,9,11],
                        className: 'text-center',
                        render: function(data, type, row) {
                            return parseFloat(data).toFixed(2);
                        }
                    },
                    {
                        // Coluna de pontualidade
                        targets: [10],
                        className: 'text-center',
                        render: function(data, type, row) {
                            return data;
                        }
                    },
                    {
                        // Coluna de data - Corrigido o formato da data
                        targets: [4],
                        render: function(data, type, row) {
                            if (type === 'display') {
                                // Verificar se a data está em um formato válido antes de processar
                                if (data && data !== "") {
                                    try {
                                        // Tentar converter para um formato ISO primeiro
                                        var dataParts = data.split(' ')[0].split('/');
                                        if (dataParts.length === 3) {
                                            // Formato dd/mm/yyyy para yyyy-mm-dd
                                            var isoDate = dataParts[2] + '-' + dataParts[1] + '-' + dataParts[0];
                                            return moment(isoDate, "YYYY-MM-DD").format('DD/MM/YYYY');
                                        }
                                        else if (data.includes('-')) {
                                            // Já está em formato ISO yyyy-mm-dd
                                            return moment(data.split(' ')[0], "YYYY-MM-DD").format('DD/MM/YYYY');
                                        }
                                        else {
                                            // Caso seja uma data em formato timestamp
                                            return moment.unix(data/1000).format('DD/MM/YYYY');
                                        }
                                    } catch (e) {
                                        console.warn("Erro ao formatar data:", e);
                                        return data; // Retorna o dado original em caso de erro
                                    }
                                }
                                return data;
                            }
                            return data;
                        }
                    }
                ],
                language: {
                    url: "plugins/datatables/traducao.json"
                }
            });
        }
    </script>
</body>
</html>
