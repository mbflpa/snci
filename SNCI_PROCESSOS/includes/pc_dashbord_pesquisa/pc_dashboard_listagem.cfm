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
    
    // Função para configurar e retornar a instância do DataTable - com tratamento de erros melhorado
    function configurarDataTable() {
        try {
            var currentDate = new Date();
            var day = currentDate.getDate();
            var month = currentDate.getMonth() + 1;
            var year = currentDate.getFullYear();
            var d = day + "-" + month + "-" + year;
            
            // Verificar se o elemento existe no DOM
            if ($('#tabelaPesquisas').length === 0) {
                console.warn("Elemento #tabelaPesquisas não encontrado no DOM");
                return null;
            }
            
            // Verificar e destruir tabela existente com tratamento de erro
            if ($.fn.DataTable.isDataTable('#tabelaPesquisas')) {
                try {
                    var existingTable = $('#tabelaPesquisas').DataTable();
                    existingTable.destroy();
                } catch (destroyError) {
                    console.error("Erro ao destruir tabela existente:", destroyError);
                    // Continue de qualquer maneira
                }
            }
            
            // Garantir que a estrutura dos cabeçalhos esteja intacta
            if ($('#tabelaPesquisas thead').length === 0) {
                $('#tabelaPesquisas').append('<thead><tr>' +
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
                    '</tr></thead>');
            }
            
            // Garantir que temos um tbody
            if ($('#tabelaPesquisas tbody').length === 0) {
                $('#tabelaPesquisas').append('<tbody></tbody>');
            }
            
            // Inicializar nova tabela com tratamento de erro
            tabelaInstance = $('#tabelaPesquisas').DataTable({
                destroy: true,
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
                    
                    // Ajustar colunas após inicialização
                    $(window).on('resize', function() {
                        if (tableInitialized && tabelaInstance) {
                            tabelaInstance.columns.adjust().draw();
                        }
                    });
                }
            });
            
            return tabelaInstance;
        } catch (e) {
            console.error("Erro ao configurar DataTable:", e);
            return null;
        }
    }
    
    // Função para carregar os dados da tabela - com tratamento de erros melhorado
    window.carregarDadosTabela = function(anoFiltro, mcuFiltro) {
        console.log("Carregando dados para tabela:", anoFiltro, mcuFiltro);
        
        try {
            // Configurar DataTable primeiro com verificação
            var tabela = configurarDataTable();
            
            if (!tabela) {
                console.warn("Não foi possível inicializar a tabela. Tentando novamente em 1 segundo.");
                setTimeout(function() {
                    window.carregarDadosTabela(anoFiltro, mcuFiltro);
                }, 1000);
                return;
            }
            
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
                        if (data && data.DATA) {
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
                            
                            // Ajustar colunas após desenhar a tabela
                            setTimeout(function() {
                                if (tabela) {
                                    tabela.columns.adjust().draw();
                                }
                            }, 200);
                        } else {
                            console.warn("Não foram encontrados dados para a tabela");
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
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Erro ao carregar dados das pesquisas:", error);
                    if (tabela) {
                        tabela.clear().draw();
                    }
                    
                    // Mostrar mensagem de erro na tabela
                    $('#tabelaPesquisas tbody').html(
                        '<tr><td colspan="13" class="text-center text-danger">' +
                        '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                        'Erro ao carregar dados: ' + error + '</td></tr>'
                    );
                }
            });
        } catch (mainError) {
            console.error("Erro geral ao processar tabela:", mainError);
            $('#tabelaPesquisas tbody').html(
                '<tr><td colspan="13" class="text-center text-danger">' +
                '<i class="fas fa-exclamation-triangle mr-2"></i>' +
                'Erro ao inicializar a tabela: ' + mainError.message + '</td></tr>'
            );
        }
    };
    
    // Inicializar a tabela quando o componente for carregado - CORRIGIDO
    // Adiado para garantir que a tabela esteja no DOM
    setTimeout(function() {
        try {
            // Obtém o ano selecionado do input
            const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
            
            // Usar a variável global do contexto principal
            let mcuFiltro = window.mcuSelecionado;
            
            // Fallback seguro se não conseguir acessar a variável global
            if (!mcuFiltro) {
                mcuFiltro = $("input[name='opcaoMcu']:checked").val() || 'Todos';
                console.log("Usando mcuFiltro do input:", mcuFiltro);
            } else {
                console.log("Usando mcuSelecionado global:", mcuFiltro);
            }
            
            window.carregarDadosTabela(anoSelecionado, mcuFiltro);
        } catch (e) {
            console.error("Erro ao inicializar componente de listagem:", e);
        }
    }, 800); // Aumentado para 800ms para garantir que o DOM esteja completamente carregado
    
    // Adicionar ouvintes para eventos de filtro
    $(document).on('filtroAlterado', function(event, dados) {
        if ($("#listagem").hasClass('active') || $("#listagem").hasClass('show')) {
            const anoSelecionado = $("input[name='opcaoAno']:checked").val() || 'Todos';
            
            // Usar a mesma lógica para obter mcuFiltro
            let mcuFiltro;
            
            try {
                if (window.parent && window.parent.mcuSelecionado) {
                    mcuFiltro = window.parent.mcuSelecionado;
                } else {
                    mcuFiltro = $("input[name='opcaoMcu']:checked").val() || 'Todos';
                }
                
                console.log("Valor de mcuFiltro no evento filtroAlterado:", mcuFiltro);
                
                if (!mcuFiltro) {
                    mcuFiltro = 'Todos';
                }
            } catch (e) {
                console.error("Erro ao obter mcuSelecionado:", e);
                mcuFiltro = 'Todos';
            }
            
            window.carregarDadosTabela(anoSelecionado, mcuFiltro);
        }
    });
});
</script>