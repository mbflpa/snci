<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Listagem.css">

<!-- Estilos para os detalhes da linha com FontAwesome em vez de imagens -->
<style>
    td.details-control {
        text-align: center;
        cursor: pointer;
        width: 30px;
    }
    td.details-control:before {
        content: '\f055'; /* FontAwesome ícone de mais (+) */
        font-family: 'Font Awesome 5 Free';
        font-weight: 900;
        color: #007bff;
        font-size: 1.2em;
    }
    tr.shown td.details-control:before {
        content: '\f056'; /* FontAwesome ícone de menos (-) */
        color: #dc3545;
    }
    .observacao-detalhes {
        padding: 10px;
        margin: 10px;
        background-color: #f8f9fa;
        border-left: 3px solid #007bff;
    }
    /* Estilos para o rodapé com médias */
    tfoot {
        font-weight: bold;
        background-color: #f0f0f0;
    }
    tfoot td.media-col {
        color: #007bff;
    }
</style>

<!-- Conteúdo da aba Listagem de Pesquisas -->
<div class="table-responsive">
  <table class="table table-hover" id="tabelaPesquisas">
    <thead>
      <tr>
        <th></th>
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
        <th>Observação</th>
      </tr>
    </thead>
    <tfoot>
      <tr>
        <th colspan="6" style="text-align:right">Média:</th>
        <th class="media-col text-center"></th>
        <th class="media-col text-center"></th>
        <th class="media-col text-center"></th>
        <th class="media-col text-center"></th>
        <th class="media-col text-center"></th>
        <th class="media-col text-center"></th>
        <th></th>
        <th class="media-col text-center"></th>
        <th></th>
      </tr>
    </tfoot>
    <tbody>
      <!--- Dados da tabela serão carregados dinamicamente --->
    </tbody>
  </table>
</div>

<script>
$(document).ready(function() {
    // Variável para controlar se a tabela já foi inicializada
    var tableInitialized = false;
    var tabelaInstance = null;
    var tabelaEmProcesso = false; // Variável para controlar se uma operação está em andamento
    
    // Função para formatar os detalhes da linha
    function formatarDetalhes(d) {
        // d é o objeto de dados para esta linha
        // O índice 14 contém a observação
        var observacao = d[14] || 'Nenhuma observação disponível';
        
        return '<div class="observacao-detalhes">' +
               '<strong>Observação:</strong><br>' + observacao +
               '</div>';
    }
    
    // Função para calcular as médias das colunas
    function calcularMediasColunas(tabela) {
        if (!tabela) return;
        
        var numRows = tabela.rows().count();
        if (numRows === 0) return;
        
        // Colunas numéricas que queremos calcular médias (índices)
        var colunasNumericas = [6, 7, 8, 9, 10, 11, 13]; // Comunicação até Importância e Média
        
        colunasNumericas.forEach(function(colIndex) {
            var total = 0;
            var contador = 0;
            
            // Somar todos os valores da coluna
            tabela.column(colIndex).data().each(function(valor) {
                if (valor !== null && valor !== "" && !isNaN(parseFloat(valor))) {
                    total += parseFloat(valor);
                    contador++;
                }
            });
            
            // Calcular média
            var media = contador > 0 ? (total / contador).toFixed(1) : "N/A";
            
            // Atualizar o rodapé
            $(tabela.column(colIndex).footer()).html(media);
        });
        
        // Tratamento especial para a coluna Pontualidade (índice 12)
        // Calcular porcentagem de "Sim"
        var totalRegistros = numRows;
        var totalSim = 0;
        
        tabela.column(12).data().each(function(valor) {
            if (valor === "Sim") {
                totalSim++;
            }
        });
        
        // Calcular percentual
        var percentualSim = totalRegistros > 0 ? ((totalSim / totalRegistros) * 100).toFixed(1) : 0;
        
        // Atualizar o rodapé da coluna Pontualidade
        $(tabela.column(12).footer()).html(percentualSim + "%");
    }
    
    // Função para configurar a instância do DataTable com callback
    function configurarDataTable(callback) {
        // Se já estiver processando, aguarde
        if (tabelaEmProcesso) {

            if (callback) callback(null);
            return;
        }
        
        tabelaEmProcesso = true;
        
        try {
            var currentDate = new Date();
            var day = currentDate.getDate();
            var month = currentDate.getMonth() + 1;
            var year = currentDate.getFullYear();
            var d = day + "-" + month + "-" + year;
            
            // Verificar se o elemento existe no DOM
            if ($('#tabelaPesquisas').length === 0) {
                console.warn("Elemento #tabelaPesquisas não encontrado no DOM");
                tabelaEmProcesso = false;
                if (callback) callback(null);
                return;
            }
            
            // Abordagem mais segura para destruir qualquer instância existente
            try {
                // Verificar se já existe uma instância usando a API do DataTables
                if ($.fn.dataTable.isDataTable('#tabelaPesquisas')) {
                    // Obter a instância corretamente e destruí-la
                    $('#tabelaPesquisas').DataTable().destroy();
                    
                    // Limpar também o cache interno do DataTables
                    $('#tabelaPesquisas').empty();
                    
                    // Recriar a estrutura da tabela para evitar problemas de DOM
                    $('#tabelaPesquisas').html('<thead><tr>' +
                        '<th></th>' +
                        '<th>ID</th>' +
                        '<th>Processo</th>' +
                        '<th>Órgão Respondente</th>' +
                        '<th>Órgão de Origem</th>' +
                        '<th>Data</th>' +
                        '<th>Comunicação</th>' +
                        '<th>Interlocução</th>' +
                        '<th>Reunião</th>' +
                        '<th>Relatório</th>' +
                        '<th>Pós-Trabalho</th>' +
                        '<th>Importância</th>' +
                        '<th>Pontualidade</th>' +
                        '<th>Média</th>' +
                        '<th>Observação</th>' +
                        '</tr></thead><tfoot><tr>' +
                        '<th colspan="6" style="text-align:right">Média:</th>' +
                        '<th class="media-col text-center"></th>' +
                        '<th class="media-col text-center"></th>' +
                        '<th class="media-col text-center"></th>' +
                        '<th class="media-col text-center"></th>' +
                        '<th class="media-col text-center"></th>' +
                        '<th class="media-col text-center"></th>' +
                        '<th></th>' +
                        '<th class="media-col text-center"></th>' +
                        '<th></th>' +
                        '</tr></tfoot><tbody></tbody>');
                }
            } catch (destroyError) {
                console.error("Erro ao destruir tabela existente:", destroyError);
                // Se houver erro ao destruir, tente recuperar o elemento
                $('#tabelaPesquisas').empty().html('<thead><tr>' +
                    '<th></th>' +
                    '<th>ID</th>' +
                    '<th>Processo</th>' +
                    '<th>Órgão Respondente</th>' +
                    '<th>Órgão de Origem</th>' +
                    '<th>Data</th>' +
                    '<th>Comunicação</th>' +
                    '<th>Interlocução</th>' +
                    '<th>Reunião</th>' +
                    '<th>Relatório</th>' +
                    '<th>Pós-Trabalho</th>' +
                    '<th>Importância</th>' +
                    '<th>Pontualidade</th>' +
                    '<th>Média</th>' +
                    '<th>Observação</th>' +
                    '</tr></thead><tfoot><tr>' +
                    '<th colspan="6" style="text-align:right">Média:</th>' +
                    '<th class="media-col text-center"></th>' +
                    '<th class="media-col text-center"></th>' +
                    '<th class="media-col text-center"></th>' +
                    '<th class="media-col text-center"></th>' +
                    '<th class="media-col text-center"></th>' +
                    '<th class="media-col text-center"></th>' +
                    '<th></th>' +
                    '<th class="media-col text-center"></th>' +
                    '<th></th>' +
                    '</tr></tfoot><tbody></tbody>');
            }
            
            // Inicializar nova tabela diretamente (sem setTimeout)
            try {
                tabelaInstance = $('#tabelaPesquisas').DataTable({
                    processing: true,
                    serverSide: false,
                    responsive: true,
                    pageLength: 5,
                    dom: 
                        "<'row d-flex align-items-center'<'col-auto'B><'col-auto'f><'col-auto'p>>" +
                        "<'row'<'col-12'i>>" +
                        "<'row'<'col-12'tr>>",
                    buttons: [
                        {
                            extend: 'excel',
                            text: '<i class="fas fa-file-excel fa-2x grow-icon" style="margin-right:30px"></i>',
                            title: 'SNCI_Pesquisas_Respondidas_' + d,
                            className: 'btExcel',
                            exportOptions: {
                                columns: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
                            },
                            customize: function(xlsx) {
                                var sheet = xlsx.xl.worksheets['sheet1.xml'];
                                // Garantir que o cabeçalho da coluna Observação esteja correto
                                $('row:first c:eq(13)', sheet).attr('t', 'inlineStr')
                                    .find('is t').text('Observação');
                                    
                                // Adicionar linha de médias na exportação
                                var lastRow = $('row:last', sheet);
                                var rowIndex = lastRow.attr('r');
                                
                                // Criar uma nova linha para médias na exportação
                                // Implementação simplificada - apenas para exemplo
                            }
                        }
                    ],
                    columnDefs: [
                        { 
                            targets: 0,
                            className: 'details-control',
                            orderable: false,
                            data: null,
                            defaultContent: ''
                        },
                        // Definir a coluna de observação como invisível na tabela, mas disponível para exportação
                        { 
                            targets: 14, 
                            visible: false,
                            searchable: false,
                            name: 'Observação'
                        },
                        { className: "text-center", targets: [6, 7, 8, 9, 10, 11, 12, 13] }
                    ],
                    language: {
                        url: "plugins/datatables/traducao.json"
                    },
                    initComplete: function() {
                        tableInitialized = true;
                        tabelaEmProcesso = false;
                        
                        // Ajustar colunas após inicialização
                        $(window).on('resize', function() {
                            if (tableInitialized && tabelaInstance) {
                                try {
                                    tabelaInstance.columns.adjust().draw();
                                } catch(e) {
                                    console.warn("Erro ao ajustar colunas:", e);
                                }
                            }
                        });
                        
                        // Adicionar evento de clique para mostrar/esconder detalhes
                        $('#tabelaPesquisas tbody').on('click', 'td.details-control', function () {
                            var tr = $(this).closest('tr');
                            var row = tabelaInstance.row(tr);
                            
                            if (row.child.isShown()) {
                                // Já está aberto - feche
                                row.child.hide();
                                tr.removeClass('shown');
                            } else {
                                // Abrir esta linha
                                row.child(formatarDetalhes(row.data())).show();
                                tr.addClass('shown');
                            }
                        });
                        
                        // Calcular médias após inicialização
                        calcularMediasColunas(tabelaInstance);
                        
                        // Chamar o callback após a inicialização completa
                        if (callback) callback(tabelaInstance);
                    },
                    drawCallback: function() {
                        // Calcular médias cada vez que a tabela é redesenhada
                        calcularMediasColunas(tabelaInstance);
                        
                        // Se o callback ainda não foi chamado, garantir que é chamado
                        if (tabelaEmProcesso && callback) {
                            tabelaEmProcesso = false;
                            callback(tabelaInstance);
                        }
                    }
                });
            } catch (initError) {
                console.error("Erro ao inicializar DataTable:", initError);
                tabelaEmProcesso = false;
                if (callback) callback(null);
            }
        } catch (e) {
            console.error("Erro ao configurar DataTable:", e);
            tabelaEmProcesso = false;
            if (callback) callback(null);
        }
    }
    
    // Função para carregar os dados da tabela - com callback para garantir a inicialização
    window.carregarDadosTabela = function(anoFiltro, mcuFiltro) {

        
        // Verificar se a aba está ativa
        if (!$("#listagem").hasClass('active') && !$("#listagem").hasClass('show')) {

            return;
        }
        
        // Se já estiver processando, evite chamadas repetidas
        if (tabelaEmProcesso) {

            return;
        }
        
        // Configurar e carregar a tabela usando callback
        configurarDataTable(function(tabela) {
            if (!tabela) {
                console.warn("Não foi possível inicializar a tabela. Tentando novamente em 1 segundo.");
                setTimeout(function() {
                    if (!tabelaEmProcesso) {  // Verificar novamente para evitar chamadas simultâneas
                        window.carregarDadosTabela(anoFiltro, mcuFiltro);
                    }
                }, 1000);
                return;
            }
            
            // A tabela foi inicializada com sucesso, agora podemos carregar os dados
            $.ajax({
                url: 'cfc/pc_cfcPesquisasDashboard.cfc?method=getPesquisas&returnformat=json',
                method: 'GET',
                data: { 
                    ano: anoFiltro,
                    mcuOrigem: mcuFiltro 
                },
                dataType: 'json',
                success: function(data) {
                    try {

                        
                        // Verificar se a tabela ainda existe e se a aba está ativa
                        if (!$.fn.dataTable.isDataTable('#tabelaPesquisas') || 
                            (!$("#listagem").hasClass('active') && !$("#listagem").hasClass('show'))) {

                            tabelaEmProcesso = false;
                            return;
                        }
                        
                        if (data && data.DATA && data.DATA.length > 0) {
                            try {
                                // Limpar apenas os dados, preservando a estrutura
                                tabela.clear();
                                
                                data.DATA.forEach(function(row) {
                                    var media = ((parseFloat(row[4]) + parseFloat(row[5]) + 
                                               parseFloat(row[6]) + parseFloat(row[7]) + 
                                               parseFloat(row[8]) + parseFloat(row[9])) / 6).toFixed(1);
                                    
                                    var pontualidade = row[10] == 1 ? "Sim" : "Não";
                                    
                                    tabela.row.add([
                                        "",       // Coluna de controle para expandir/contrair
                                        row[0],   // ID
                                        row[2],   // Processo
                                        row[3],   // órgao que respondeu
                                        row[13],  // órgão origem
                                        row[12],  // Data/Hora
                                        row[4],   // Comunicação
                                        row[5],   // Interlocução
                                        row[6],   // Reunião
                                        row[7],   // Relatório
                                        row[8],   // Pós-Trabalho
                                        row[9],   // Importância do Processo
                                        pontualidade, // Pontualidade como Sim/Não
                                        media,     // Média
                                        row[11]    // Observação (não exibida na tabela, apenas nos detalhes)
                                    ]);
                                });
                                
                                tabela.draw();

                                
                                // Calcular médias após carregar os dados
                                calcularMediasColunas(tabela);
                                
                                // Ajustar colunas após desenhar a tabela
                                setTimeout(function() {
                                    if (tabela && $.fn.dataTable.isDataTable('#tabelaPesquisas')) {
                                        try {
                                            tabela.columns.adjust();
                                        } catch(e) {
                                            console.warn("Erro ao ajustar colunas após carregar dados:", e);
                                        }
                                    }
                                }, 200);
                            } catch (drawError) {
                                console.error("Erro ao desenhar tabela:", drawError);
                            }
                        } else {
                            tabela.clear().draw();
                            // Aqui apenas atualiza o conteúdo do tbody, preservando o thead
                            $('#tabelaPesquisas tbody').html(
                                '<tr><td colspan="14" class="text-center">' +
                                '<i class="fas fa-info-circle mr-2"></i>' +
                                'Nenhum dado encontrado para os filtros selecionados</td></tr>'
                            );
                        }
                    } catch (processError) {
                        console.error("Erro ao processar dados:", processError);
                        $('#tabelaPesquisas tbody').html(
                            '<tr><td colspan="14" class="text-center text-danger">' +
                            '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                            'Erro ao processar dados: ' + processError.message + '</td></tr>'
                        );
                    } finally {
                        // Sempre marcar como concluído
                        tabelaEmProcesso = false;
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Erro ao carregar dados das pesquisas:", error);
                    if (tabela && $.fn.dataTable.isDataTable('#tabelaPesquisas')) {
                        tabela.clear().draw();
                    }
                    
                    // Mostrar mensagem de erro na tabela
                    $('#tabelaPesquisas tbody').html(
                        '<tr><td colspan="14" class="text-center text-danger">' +
                        '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                        'Erro ao carregar dados: ' + error + '</td></tr>'
                    );
                    tabelaEmProcesso = false;
                }
            });
        });
    };
    
    // Inicializar a tabela quando o componente for carregado
    // Verificar primeiro se a aba está ativa
    setTimeout(function() {
        if ($("#listagem").hasClass('active') || $("#listagem").hasClass('show')) {
            try {
                // Obtém o ano selecionado do input
                const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
                
                // Usar a variável global do contexto principal
                let mcuFiltro = window.mcuSelecionado;
                
                // Fallback seguro se não conseguir acessar a variável global
                if (!mcuFiltro) {
                    mcuFiltro = $("input[name='opcaoMcu']:checked").val() || 'Todos';
                } 
                
                window.carregarDadosTabela(anoSelecionado, mcuFiltro);
            } catch (e) {
                console.error("Erro ao inicializar componente de listagem:", e);
                tabelaEmProcesso = false;
            }
        } else {

        }
    }, 800); // Aumentado para 800ms para garantir que o DOM esteja completamente carregado
    
    // Adicionar ouvintes para eventos de filtro com debounce para evitar múltiplas chamadas
    var filtroTimeout = null;
    
    $(document).on('filtroAlterado', function(event, dados) {
        // Limpar timeout anterior se existir
        if (filtroTimeout) {
            clearTimeout(filtroTimeout);
        }
        
        // Definir um novo timeout para evitar múltiplas chamadas rápidas
        filtroTimeout = setTimeout(function() {
            if ($("#listagem").hasClass('active') || $("#listagem").hasClass('show')) {
                const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
                
                // Usar a mesma lógica para obter mcuFiltro
                let mcuFiltro;
                
                try {
                    if (window.mcuSelecionado) {
                        mcuFiltro = window.mcuSelecionado;
                    } else if (window.parent && window.parent.mcuSelecionado) {
                        mcuFiltro = window.parent.mcuSelecionado;
                    } else {
                        mcuFiltro = $("input[name='opcaoMcu']:checked").val() || 'Todos';
                    }
                    
                    if (!mcuFiltro) {
                        mcuFiltro = 'Todos';
                    }
                } catch (e) {
                    console.error("Erro ao obter mcuSelecionado:", e);
                    mcuFiltro = 'Todos';
                }
                
                // Verificar se a operação anterior já foi concluída
                if (!tabelaEmProcesso) {
                    window.carregarDadosTabela(anoSelecionado, mcuFiltro);
                } else {

                }
            }
        }, 250); // Espera 250ms para evitar múltiplas chamadas
    });
    
    // Adicionar listener para quando a aba for ativada
    $(document).on('shown.bs.tab', 'a[data-toggle="tab"][href="#listagem"]', function (e) {
        // Verificar se a tabela já está inicializada
        if (!tableInitialized && !tabelaEmProcesso) {
            const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
            let mcuFiltro = window.mcuSelecionado || $("input[name='opcaoMcu']:checked").val() || 'Todos';
            window.carregarDadosTabela(anoSelecionado, mcuFiltro);
        }
    });
});
</script>