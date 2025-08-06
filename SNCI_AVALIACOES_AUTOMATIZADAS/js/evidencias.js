(function() {
    'use strict';
    
    let tabelaEvidencias = null;
    
    // Função para abrir modal de evidências
    window.abrirModalEvidencias = function(nomeTabela, titulo) {
        console.log('abrirModalEvidencias chamada:', nomeTabela, titulo);
        
        if (!nomeTabela) {
            console.error('Nome da tabela não informado');
            return;
        }
        
        // Verificar se o modal existe
        if ($('#modalEvidencias').length === 0) {
            console.error('Modal de evidências não encontrado');
            alert('Modal de evidências não encontrado. Verifique se o arquivo modal_evidencias.cfm foi incluído.');
            return;
        }
        
        // Atualizar título do modal
        $('#modalEvidenciasLabel').html('<i class="fas fa-table mr-2"></i>' + (titulo || 'Evidências'));
        
        // Abrir modal
        $('#modalEvidencias').modal('show');
        
        // Carregar dados
        carregarEvidencias(nomeTabela);
    };
    
    // Função para carregar evidências
    function carregarEvidencias(nomeTabela) {
        console.log('carregarEvidencias chamada para:', nomeTabela);
        
        // Mostrar loading
        $('#evidenciasLoading').show();
        $('#evidenciasContent').hide();
        $('#evidenciasError').hide();
        
        // Destruir DataTable existente se houver
        if (tabelaEvidencias) {
            tabelaEvidencias.destroy();
            tabelaEvidencias = null;
        }
        
        // Limpar tabela
        $('#tabelaEvidencias thead').empty();
        $('#tabelaEvidencias tbody').empty();
        
        // Primeiro, obter estrutura da tabela para criar cabeçalhos
        $.ajax({
            url: 'cfc/EvidenciasManager.cfc?method=obterEstruturasTabela',
            type: 'GET',
            data: { nomeTabela: nomeTabela },
            dataType: 'json',
            success: function(colunas) {
                console.log('Estrutura recebida:', colunas);
                if (colunas && colunas.length > 0) {
                    criarCabecalhos(colunas);
                    inicializarDataTable(nomeTabela, colunas);
                } else {
                    mostrarErro('Nenhuma coluna encontrada para esta tabela.');
                }
            },
            error: function(xhr, status, error) {
                console.error('Erro ao obter estrutura:', error, xhr.responseText);
                mostrarErro('Erro ao carregar estrutura da tabela: ' + error);
            }
        });
    }
    
    // Função para criar cabeçalhos da tabela
    function criarCabecalhos(colunas) {
        let headerRow = '<tr>';
        colunas.forEach(function(coluna) {
            headerRow += '<th>' + coluna.nome + '</th>';
        });
        headerRow += '</tr>';
        
        $('#tabelaEvidencias thead').html(headerRow);
    }
    
    // Função para inicializar DataTable
    function inicializarDataTable(nomeTabela, colunas) {
        try {
            // Configurar colunas para DataTables
            const columnDefs = colunas.map(function(coluna, index) {
                let config = {
                    targets: index,
                    title: coluna.nome,
                    className: 'text-center'
                };
                
                // Configurações específicas por tipo de dados
                if (coluna.tipo === 'datetime' || coluna.tipo === 'date') {
                    config.className = 'text-center';
                } else if (coluna.tipo === 'money' || coluna.tipo === 'decimal' || coluna.tipo === 'numeric') {
                    config.className = 'text-right';
                } else if (coluna.tipo === 'bit') {
                    config.className = 'text-center';
                }
                
                return config;
            });
            
            // Inicializar DataTable
            tabelaEvidencias = $('#tabelaEvidencias').DataTable({
                processing: true,
                serverSide: true,
                ajax: {
                    url: 'includes/componentes_deficiencias_controle/evidencias_data.cfm',
                    type: 'GET',
                    data: function(d) {
                        d.tabela = nomeTabela;
                    },
                    error: function(xhr, error, thrown) {
                        console.error('Erro AJAX:', error, thrown);
                        mostrarErro('Erro ao carregar dados: ' + error);
                    }
                },
                columns: colunas.map(function(coluna) {
                    return { data: null };
                }),
                columnDefs: columnDefs,
                language: {
                    url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/pt-BR.json'
                },
                pageLength: 25,
                lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "Todos"]],
                responsive: true,
                scrollX: true,
                order: [[0, 'asc']],
                drawCallback: function(settings) {
                    // Esconder loading e mostrar conteúdo quando dados carregarem
                    $('#evidenciasLoading').hide();
                    $('#evidenciasContent').show();
                    
                    // Atualizar informações no footer
                    const info = this.api().page.info();
                    $('#evidenciasInfo').text(
                        `Tabela: ${nomeTabela} | ` +
                        `Registros: ${info.recordsTotal.toLocaleString('pt-BR')} | ` +
                        `Colunas: ${colunas.length}`
                    );
                },
                initComplete: function(settings, json) {
                    if (json.error) {
                        mostrarErro(json.error);
                    }
                }
            });
            
        } catch (error) {
            console.error('Erro ao inicializar DataTable:', error);
            mostrarErro('Erro ao inicializar tabela: ' + error.message);
        }
    }
    
    // Função para mostrar erro
    function mostrarErro(mensagem) {
        $('#evidenciasLoading').hide();
        $('#evidenciasContent').hide();
        $('#evidenciasErrorMessage').text(mensagem);
        $('#evidenciasError').show();
    }
    
    // Event listeners
    $(document).ready(function() {
        console.log('evidencias.js carregado');
        
        // Limpar modal quando fechar
        $('#modalEvidencias').on('hidden.bs.modal', function() {
            if (tabelaEvidencias) {
                tabelaEvidencias.destroy();
                tabelaEvidencias = null;
            }
            $('#tabelaEvidencias thead').empty();
            $('#tabelaEvidencias tbody').empty();
            $('#evidenciasInfo').empty();
        });
        
        // Exemplo de como criar links para abrir evidências
        // Este código deve ser adaptado conforme sua necessidade
        $(document).on('click', '.link-evidencias', function(e) {
            e.preventDefault();
            const nomeTabela = $(this).data('tabela');
            const titulo = $(this).data('titulo') || $(this).text();
            abrirModalEvidencias(nomeTabela, titulo);
        });
    });
    
})();
