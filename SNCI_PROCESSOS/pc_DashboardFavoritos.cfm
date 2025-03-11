<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dashboard de Favoritos</title>
    
    <!-- Adicionar os arquivos CSS do Bootstrap -->
    <link rel="stylesheet" href="plugins/bootstrap/css/bootstrap.min.css">
    <link rel="stylesheet" href="plugins/fontawesome-free/css/all.min.css">
    <link rel="stylesheet" href="dist/css/adminlte.min.css">
    <link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard.css">
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <div class="container-fluid">
                <section class="content-header">
                    <h1>Dashboard de Favoritos</h1>
                </section>
                
                <section class="content">
                    <!-- Componente de filtros simplificado - agora busca seus próprios dados -->
                    <cfmodule template="includes/pc_filtros_componente.cfm"
                        componenteID="filtros-favoritos"
                        exibirAno="true"
                        exibirOrgao="true"
                        exibirStatus="false">
                    
                    <!-- Área para testar o filtro -->
                    <div id="resultado-filtro" class="card mt-4 mb-4">
                        <div class="card-header">
                            <h3 class="card-title">Resultados do Filtro</h3>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info">
                                <h5><i class="icon fas fa-info"></i> Filtros Aplicados:</h5>
                                <p id="filtro-info">Selecione filtros para ver os resultados aqui.</p>
                            </div>
                            <div id="processos-favoritos" class="row">
                                <div class="col-12">
                                    <div class="alert alert-secondary">
                                        Seus processos favoritos filtrados aparecerão aqui.
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

    <!-- Adicionar os scripts JavaScript necessários -->
    <script src="plugins/jquery/jquery.min.js"></script>
    <script src="plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
    <script src="dist/js/adminlte.min.js"></script>

    <script>
        $(document).ready(function() {
            // Inicializar tooltips e popovers do Bootstrap
            if ($.fn.tooltip) {
                $('[data-toggle="tooltip"]').tooltip();
            }
            
            if ($.fn.popover) {
                $('[data-toggle="popover"]').popover();
            }
            
            // Código para testar o filtro
            document.addEventListener('filtroAlterado', function(e) {
                const { tipo, valor, componenteID } = e.detail;
                
                // Atualizar a informação de filtros aplicados
                const anoTexto = window.anoSelecionado && window.anoSelecionado !== 'Todos' ? 
                    `Ano: ${window.anoSelecionado}` : 'Ano: Todos';
                    
                const orgaoTexto = window.mcuSelecionado && window.mcuSelecionado !== 'Todos' ? 
                    `Órgão: ${$('input[name="opcaoMcufiltros-favoritos"][value="' + window.mcuSelecionado + '"]').parent().text().trim()}` : 
                    'Órgão: Todos';
                    
                const statusTexto = window.statusSelecionado && window.statusSelecionado !== 'Todos' ?
                    `Status: ${$('input[name="opcaoStatusfiltros-favoritos"][value="' + window.statusSelecionado + '"]').parent().text().trim()}` :
                    'Status: Todos';
                
                $('#filtro-info').html(`${anoTexto} | ${orgaoTexto} | ${statusTexto}`);
                
                // Simulação de busca de processos favoritos
                console.log(`Filtro alterado: ${tipo} = ${valor}`);
                buscarProcessosFavoritos();
            });
            
            // Função para simular busca de processos favoritos
            function buscarProcessosFavoritos() {
                const ano = window.anoSelecionado || 'Todos';
                const mcu = window.mcuSelecionado || 'Todos';
                const status = window.statusSelecionado || 'Todos';
                
                // Mostrar loading
                $('#processos-favoritos').html('<div class="col-12 text-center"><div class="spinner-border text-primary" role="status"><span class="sr-only">Carregando...</span></div></div>');
                
                // Simular tempo de carregamento
                setTimeout(function() {
                    // Gerar itens de exemplo com base nos filtros aplicados
                    let html = '';
                    
                    if (ano === 'Todos' && mcu === 'Todos' && status === 'Todos') {
                        html = `
                            <div class="col-12">
                                <div class="alert alert-warning">
                                    <i class="fas fa-exclamation-triangle"></i> Para melhor desempenho, aplique pelo menos um filtro específico.
                                </div>
                            </div>`;
                    } else {
                        // Criar exemplos baseados nos filtros
                        const numeroProcessos = Math.floor(Math.random() * 5) + 1;
                        for (let i = 1; i <= numeroProcessos; i++) {
                            const anoProcesso = ano === 'Todos' ? (2020 + Math.floor(Math.random() * 4)) : ano;
                            const orgao = mcu === 'Todos' ? 'CORREGEDORIA' : $('input[name="opcaoMcufiltros-favoritos"][value="' + mcu + '"]').parent().text().trim();
                            const statusProcesso = status === 'Todos' ? ['Em andamento', 'Concluído', 'Planejamento'][Math.floor(Math.random() * 3)] : 
                                                $('input[name="opcaoStatusfiltros-favoritos"][value="' + status + '"]').parent().text().trim();
                            
                            html += `
                                <div class="col-md-6">
                                    <div class="card card-processo">
                                        <div class="card-header bg-primary">
                                            <h3 class="card-title">Processo ${anoProcesso}/${i.toString().padStart(4, '0')}</h3>
                                        </div>
                                        <div class="card-body">
                                            <p><strong>Órgão:</strong> ${orgao}</p>
                                            <p><strong>Status:</strong> ${statusProcesso}</p>
                                            <p><strong>Data:</strong> ${('01/' + Math.ceil(Math.random() * 12) + '/' + anoProcesso)}</p>
                                            <button class="btn btn-sm btn-info">Ver detalhes</button>
                                        </div>
                                    </div>
                                </div>`;
                        }
                    }
                    
                    $('#processos-favoritos').html(html);
                }, 700);
            }
        });
    </script>
</body>
</html>
