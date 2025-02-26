<cfquery name="rsAnoDashboard" datasource="#application.dsn_processos#">
    SELECT DISTINCT RIGHT(pc_processo_id, 4) AS ano FROM pc_pesquisas ORDER BY ano DESC
</cfquery>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Pesquisas</title>
    <link rel="stylesheet" href="dist/css/stylesSNCI_PaineisFiltro.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_PesquisasDashboard">
    
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
            
            // Obter cores das variáveis CSS para uso no JavaScript
            var coresCategorias = {
                comunicacao: getComputedStyle(document.documentElement).getPropertyValue('--cor-comunicacao').trim(),
                interlocucao: getComputedStyle(document.documentElement).getPropertyValue('--cor-interlocucao').trim(),
                reuniao: getComputedStyle(document.documentElement).getPropertyValue('--cor-reuniao').trim(),
                relatorio: getComputedStyle(document.documentElement).getPropertyValue('--cor-relatorio').trim(),
                postrabalho: getComputedStyle(document.documentElement).getPropertyValue('--cor-pos-trabalho').trim()
            };
        
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
                
                // Cores definidas para cada categoria igual às do score card
                var cores = [
                    coresCategorias.comunicacao, // Comunicação
                    coresCategorias.interlocucao, // Interlocução
                    coresCategorias.reuniao, // Reunião
                    coresCategorias.relatorio, // Relatório
                    coresCategorias.postrabalho  // Pós-Trabalho
                ];
                
                graficoMedia = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: ['Comunicação','Interlocução','Reunião','Relatório','Pós-Trabalho'],
                        datasets: [{
                            label: 'Média',
                            data: medias,
                            backgroundColor: cores,
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
                        },
                        plugins: {
                            datalabels: {
                                anchor: 'end',
                                align: 'top',
                                formatter: function(value) {
                                    return value.toFixed(1);
                                },
                                font: {
                                    weight: 'bold'
                                },
                                color: function(context) {
                                    return context.dataset.backgroundColor;
                                }
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
                    url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getPesquisas&returnformat=json',
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
                    url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getEstatisticas&returnformat=json',
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
                pageLength: 10,
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
