<cfprocessingdirective pageencoding = "utf-8">
<link rel="stylesheet" href="dist/css/stylesSNCI_Dashboard_Listagem.css">

<!-- Conteúdo da aba Listagem de Pesquisas -->
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

<script>
$(document).ready(function() {
    // Variável para controlar se a tabela já foi inicializada
    var tableInitialized = false;
    var tabelaInstance = null;
    var tabelaEmProcesso = false; // Variável para controlar se uma operação está em andamento
    
    // Função para configurar a instância do DataTable com callback
    function configurarDataTable(callback) {
        // Se já estiver processando, aguarde
        if (tabelaEmProcesso) {
            console.log("Operação de tabela já em andamento, aguardando...");
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
                        '</tr></thead><tbody></tbody>');
                }
            } catch (destroyError) {
                console.error("Erro ao destruir tabela existente:", destroyError);
                // Se houver erro ao destruir, tente recuperar o elemento
                $('#tabelaPesquisas').empty().html('<thead><tr>' +
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
                    '</tr></thead><tbody></tbody>');
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
                        }
                    ],
                    columnDefs: [
                        { className: "text-center", targets: [5, 6, 7, 8, 9, 10, 11, 12] }
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
                        
                        // Chamar o callback após a inicialização completa
                        if (callback) callback(tabelaInstance);
                    },
                    drawCallback: function() {
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
        console.log("Carregando dados para tabela:", anoFiltro, mcuFiltro);
        
        // Verificar se a aba está ativa
        if (!$("#listagem").hasClass('active') && !$("#listagem").hasClass('show')) {
            console.log("Aba de listagem não está ativa. Operação cancelada.");
            return;
        }
        
        // Se já estiver processando, evite chamadas repetidas
        if (tabelaEmProcesso) {
            console.log("Operação de tabela já em andamento, ignorando nova solicitação");
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
                        console.log("Dados recebidos:", data);
                        
                        // Verificar se a tabela ainda existe e se a aba está ativa
                        if (!$.fn.dataTable.isDataTable('#tabelaPesquisas') || 
                            (!$("#listagem").hasClass('active') && !$("#listagem").hasClass('show'))) {
                            console.log("A tabela foi destruída ou a aba não está mais ativa");
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
                                        media     // Média
                                    ]);
                                });
                                
                                tabela.draw();
                                console.log("Tabela desenhada com sucesso");
                                
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
                                '<tr><td colspan="13" class="text-center">' +
                                '<i class="fas fa-info-circle mr-2"></i>' +
                                'Nenhum dado encontrado para os filtros selecionados</td></tr>'
                            );
                        }
                    } catch (processError) {
                        console.error("Erro ao processar dados:", processError);
                        $('#tabelaPesquisas tbody').html(
                            '<tr><td colspan="13" class="text-center text-danger">' +
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
                        '<tr><td colspan="13" class="text-center text-danger">' +
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
            console.log("Aba de listagem não está ativa. Inicialização adiada.");
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
                    console.log("Operação de tabela em andamento, aguardando conclusão...");
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