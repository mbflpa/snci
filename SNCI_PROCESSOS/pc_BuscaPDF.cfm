<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Busca PDF</title>
     
    <!-- Estilos específicos para esta página -->
    <style>
        .search-result {
            margin-bottom: 20px;
            padding: 15px;
            border-radius: 8px;
            background-color: #f8f9fa;
            border-left: 4px solid #0083ca;
            box-shadow: 0 2px 4px rgba(0,0,0,.1);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .search-result:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,.15);
        }
        .search-result h5 {
            margin-bottom: 10px;
            font-weight: 600;
            color: #0083ca;
        }
        .search-result p {
            margin-bottom: 8px;
            color: #212529;
        }
        .search-result mark {
            background-color: #ffeb3b;
            padding: 2px 0;
        }
        .result-metadata {
            font-size: 0.85rem;
            color: #6c757d;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .search-options {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,.1);
        }
        .pdf-viewer-container {
            height: 600px;
            border: 1px solid #ddd;
            margin-top: 20px;
            display: none;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 8px rgba(0,0,0,.1);
        }
        #pdfViewer {
            width: 100%;
            height: 100%;
        }
        .options-toggle {
            cursor: pointer;
            user-select: none;
            font-weight: 500;
            transition: color 0.2s;
        }
        .options-toggle:hover {
            color: #0056b3;
        }
        .recent-searches {
            margin-top: 15px;
            padding: 10px 15px;
            border-radius: 8px;
            background-color: rgba(0,131,202,0.05);
        }
        .recent-searches .badge {
            margin-right: 5px;
            margin-bottom: 5px;
            padding: 6px 10px;
            cursor: pointer;
            background-color: #e9ecef;
            color: #495057;
            transition: all 0.2s;
        }
        .recent-searches .badge:hover {
            background-color: #0083ca;
            color: white;
        }
        .highlight-controls {
            position: sticky;
            top: 0;
            background: rgba(255,255,255,0.95);
            z-index: 100;
            padding: 10px 0;
            border-bottom: 1px solid #ddd;
            display: none;
        }
        .pdf-progress {
            height: 5px;
            margin-bottom: 0;
            border-radius: 5px;
        }
        .search-header {
            background: linear-gradient(135deg, #0083ca, #005b8e);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            border-radius: 0 0 15px 15px;
            box-shadow: 0 4px 10px rgba(0,0,0,.1);
        }
        .search-header h1 {
            font-weight: 700;
            margin: 0;
        }
        .search-card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,.08);
            overflow: hidden;
        }
        .search-card .card-header {
            background: #0083ca;
            color: white;
            padding: 15px 20px;
            border: none;
        }
        .search-card .card-body {
            padding: 25px;
        }
        .form-control-lg {
            border-radius: 8px 0 0 8px;
            border: 1px solid #ced4da;
        }
        .btn-search {
            border-radius: 0 8px 8px 0;
            padding-left: 20px;
            padding-right: 20px;
            transition: all 0.2s;
        }
        .btn-search:hover {
            transform: translateX(2px);
        }
        .custom-control-label {
            font-weight: 500;
            cursor: pointer;
        }
        .custom-control-input:checked ~ .custom-control-label::before {
            background-color: #0083ca;
            border-color: #0083ca;
        }
        
        /* Estilos para o texto extraído */
        .extracted-text-container {
            margin-top: 15px;
        }
        .extracted-text-content {
            font-family: 'Courier New', Courier, monospace;
            font-size: 0.9rem;
            line-height: 1.5;
            white-space: pre-wrap;
            word-break: break-word;
            background-color: #fafafa;
            border: 1px solid #eee;
            border-radius: 4px;
            padding: 15px;
        }
        .extracted-text-content mark {
            background-color: #ffeb3b;
            padding: 2px 0;
            border-radius: 2px;
        }
        .toggle-extracted-text {
            transition: all 0.3s ease;
        }
        .toggle-extracted-text:hover {
            background-color: #0083ca;
            color: white;
        }
        .copy-text {
            color: #6c757d;
            transition: all 0.2s;
        }
        .copy-text:hover {
            color: #0083ca;
            text-decoration: none;
        }
        .extracted-text-content::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        .extracted-text-content::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }
        .extracted-text-content::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 4px;
        }
        .extracted-text-content::-webkit-scrollbar-thumb:hover {
            background: #a1a1a1;
        }
    </style>
</head>
<body class="hold-transition sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed" data-panel-auto-height-mode="height">
    <div class="wrapper">
        <!-- Cabeçalho e Sidebar -->
        <cfinclude template="includes/pc_navBar.cfm">
        
        <!-- Conteúdo principal -->
        <div class="content-wrapper">
            <!-- Cabeçalho estilizado -->
            <div class="search-header text-center">
                <div class="container-fluid">
                    <h1><i class="fas fa-search mr-3"></i>BUSCA AVANÇADA EM DOCUMENTOS</h1>
                    <p class="mt-2">Pesquise em todos os documentos PDF da base de conhecimento</p>
                </div>
            </div>
            
            <!-- Main content -->
            <section class="content">
                <div class="container-fluid">
                    <!-- Card de busca -->
                    <div class="card search-card">
                        <div class="card-header">
                            <h3 class="card-title"><i class="fas fa-file-search mr-2"></i>Digite os termos para pesquisar</h3>
                        </div>
                        <div class="card-body">
                            <!-- Formulário de busca -->
                            <form id="searchFaqForm">
                                <div class="input-group input-group-lg mb-3">
                                    <input type="text" class="form-control" id="searchTerms" name="searchTerms" 
                                           placeholder="Ex.: contrato de trabalho, atestado médico..." required>
                                    <div class="input-group-append">
                                        <button type="submit" class="btn btn-primary btn-search">
                                            <i class="fas fa-search mr-1"></i> Buscar
                                        </button>
                                    </div>
                                </div>
                                <!-- NOVO CAMPO: Ano do processo -->
                                <div class="form-group">
                                    <select class="form-control" id="searchYear" name="searchYear" style="max-width: 200px;">
                                        <option value="">Selecione o ano do processo</option>
                                        <cfset currentYear = year(now())>
                                        <cfoutput>
                                          <cfloop from="2019" to="#currentYear#" index="yr">
                                            <option value="#yr#">#yr#</option>
                                          </cfloop>
                                        </cfoutput>
                                    </select>
                                </div>
                                
                                <!-- Opções avançadas de busca (colapsáveis) -->
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <small class="text-muted">
                                        <i class="far fa-lightbulb mr-1"></i> Separe múltiplas palavras-chave com espaço
                                    </small>
                                    <a class="options-toggle text-primary" data-toggle="collapse" href="#advancedOptions">
                                        <i class="fas fa-cog mr-1"></i> Opções avançadas <i class="fas fa-chevron-down ml-1"></i>
                                    </a>
                                </div>
                                
                                <div class="collapse" id="advancedOptions">
                                    <div class="search-options">
                                        <div class="row">
                                            <div class="col-md-7">
                                                <div class="form-group">
                                                    <label class="font-weight-bold text-primary mb-2">Modo de busca</label>
                                                    <div class="custom-control custom-radio mb-2">
                                                        <input type="radio" id="searchModeOr" name="searchMode" value="or" class="custom-control-input" checked>
                                                        <label class="custom-control-label" for="searchModeOr">Qualquer palavra (OU)</label>
                                                        <small class="form-text text-muted">Retorna documentos que contenham qualquer uma das palavras pesquisadas</small>
                                                    </div>
                                                    <div class="custom-control custom-radio mb-2">
                                                        <input type="radio" id="searchModeExact" name="searchMode" value="exact" class="custom-control-input">
                                                        <label class="custom-control-label" for="searchModeExact">Frase exata</label>
                                                        <small class="form-text text-muted">Busca pela sequência exata de palavras</small>
                                                    </div>
                                                    <div class="custom-control custom-radio">
                                                        <input type="radio" id="searchModeProximity" name="searchMode" value="proximity" class="custom-control-input">
                                                        <label class="custom-control-label" for="searchModeProximity">Palavras próximas</label>
                                                        <small class="form-text text-muted">Todas as palavras devem estar presentes e próximas</small>
                                                    </div>
                                                </div>
                                                <div class="form-group" id="proximityOptionsGroup" style="display: none;">
                                                    <label for="proximityDistance">Distância máxima entre palavras</label>
                                                    <select id="proximityDistance" class="form-control">
                                                        <option value="10">10 palavras</option>
                                                        <option value="20" selected>20 palavras</option>
                                                        <option value="50">50 palavras</option>
                                                        <option value="100">100 palavras</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-md-5">
                                                <div class="form-group">
                                                    <label class="font-weight-bold text-primary mb-2">Tipo de busca</label>
                                                    <div class="custom-control custom-radio mb-2">
                                                        <input type="radio" id="searchTypeExact" name="searchType" value="exact" class="custom-control-input" checked>
                                                        <label class="custom-control-label" for="searchTypeExact">Busca exata</label>
                                                        <small class="form-text text-muted">Busca por correspondência exata dos termos</small>
                                                    </div>
                                                    <div class="custom-control custom-radio">
                                                        <input type="radio" id="searchTypeFuzzy" name="searchType" value="fuzzy" class="custom-control-input">
                                                        <label class="custom-control-label" for="searchTypeFuzzy">Busca aproximada</label>
                                                        <small class="form-text text-muted">Encontra termos com grafia similar (útil para erros de digitação)</small>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label for="fuzzyThreshold">Nível de aproximação</label>
                                                    <select id="fuzzyThreshold" class="form-control" disabled>
                                                        <option value="0.0">Muito alta</option>
                                                        <option value="0.2" selected>Alta</option>
                                                        <option value="0.4">Média</option>
                                                        <option value="0.6">Baixa</option>
                                                    </select>
                                                    <small class="form-text text-muted">Somente para busca aproximada</small>
                                                </div>
                                                <div class="form-group">
                                                    <div class="custom-control custom-checkbox">
                                                        <input type="checkbox" id="searchCaseSensitive" class="custom-control-input">
                                                        <label class="custom-control-label" for="searchCaseSensitive">Diferenciar maiúsculas/minúsculas</label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Área para mostrar buscas recentes -->
                                <div id="recentSearchesContainer" class="recent-searches"></div>
                            </form>
                        </div>
                    </div>
                    
                    <!-- Card de resultados -->
                    <div class="card search-card" id="resultsCard" style="display:none;">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h3 class="card-title mb-0"><i class="fas fa-list-alt mr-2"></i>Resultados da Busca</h3>
                            <span id="searchStats" class="badge badge-light badge-pill py-2 px-3" style="font-size: 0.9rem;"></span>
                        </div>
                        <div class="card-body">
                            <!-- Indicador de carregamento -->
                            <div class="text-center py-5" id="searchLoading" style="display:none;">
                                <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status">
                                    <span class="sr-only">Buscando...</span>
                                </div>
                                <p class="mt-3 lead">Procurando nos documentos. Isso pode levar alguns instantes...</p>
                                <div class="progress pdf-progress mx-auto" style="width:70%; height: 8px;">
                                    <div class="progress-bar bg-primary progress-bar-striped progress-bar-animated" id="processingProgress" role="progressbar" style="width: 0%"></div>
                                </div>
                                <small id="processingStatus" class="form-text text-muted mt-2">Preparando busca...</small>
                            </div>
                            
                            <!-- Alerta quando não há resultados -->
                            <div id="noResultsAlert" class="alert alert-warning" style="display:none;">
                                <div class="d-flex align-items-center">
                                    <i class="icon fas fa-exclamation-triangle fa-2x mr-3"></i>
                                    <div>
                                        <h5 class="mb-1">Nenhum resultado encontrado</h5>
                                        <p class="mb-0">Tente usar termos diferentes ou mais genéricos para sua busca.</p>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Alerta de erro -->
                            <div id="errorAlert" class="alert alert-danger" style="display:none;">
                                <div class="d-flex align-items-center">
                                    <i class="icon fas fa-ban fa-2x mr-3"></i>
                                    <div>
                                        <h5 class="mb-1">Ocorreu um erro na busca</h5>
                                        <p id="errorMessage" class="mb-0"></p>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Controles de navegação nos resultados -->
                            <div class="highlight-controls" id="highlightControls">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <div>
                                        <span class="badge badge-info py-2 px-3" id="highlightStatus">0 de 0 ocorrências</span>
                                    </div>
                                    <div class="btn-group">
                                        <button type="button" class="btn btn-outline-primary" id="prevHighlight">
                                            <i class="fas fa-chevron-up mr-1"></i> Anterior
                                        </button>
                                        <button type="button" class="btn btn-outline-primary" id="nextHighlight">
                                            Próximo <i class="fas fa-chevron-down ml-1"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Lista de resultados -->
                            <div class="search-results" id="searchResults"></div>
                            
                        </div>
                    </div>
                </div>
            </section>
            <cfinclude template="includes/pc_footer.cfm">
        </div>
        
    </div>

    <!-- Modal de carregamento -->
    <div class="modal fade" id="modalOverlay" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content">
                <div class="modal-body text-center">
                    <div class="spinner-border text-primary mb-2" role="status">
                        <span class="sr-only">Carregando...</span>
                    </div>
                    <p>Aguarde...</p>
                </div>
            </div>
        </div>
    </div>
<cfinclude template="includes/pc_sidebar.cfm">
    <!-- Carregar PDF.js como script regular (não como módulo ES6) -->
    <script src="plugins/pdf.js/pdf.min.js"></script>
    <script>
        // Configurar o worker do PDF.js
        if (typeof pdfjsLib !== 'undefined') {
            // Definir a fonte do worker manualmente
            pdfjsLib.GlobalWorkerOptions.workerSrc = 'plugins/pdf.js/pdf.worker.min.js';
            console.log("PDF.js carregado com sucesso.");
        } else {
            console.error("PDF.js não foi carregado corretamente.");
        }
    </script>
    
    <script src="plugins/fuse/fuse.min.js"></script>
    <script src="dist/js/snciProcessos_buscaPDF.js"></script>
    
    <script>
        $(document).ready(function() {
            // Toggle para exibir/ocultar opções avançadas com animação do ícone
            $('.options-toggle').on('click', function() {
                $(this).find('.fa-chevron-down, .fa-chevron-up').toggleClass('fa-chevron-down fa-chevron-up');
            });
            
            // Mostrar/ocultar opções de proximidade quando o modo de busca for alterado
            $('input[name="searchMode"]').on('change', function() {
                if ($(this).val() === 'proximity') {
                    $('#proximityOptionsGroup').slideDown(200);
                } else {
                    $('#proximityOptionsGroup').slideUp(200);
                }
                
                // Quando "Frase Exata" for selecionado, desabilitar a opção de busca aproximada
                if ($(this).val() === 'exact') {
                    $('#searchTypeFuzzy').prop('disabled', true);
                    $('#searchTypeExact').prop('checked', true);
                    $('#fuzzyThreshold').prop('disabled', true);
                } else {
                    $('#searchTypeFuzzy').prop('disabled', false);
                }
            });
            
            // Adicionar efeito hover aos badges de busca recente
            $(document).on('mouseenter', '.recent-searches .badge', function() {
                $(this).addClass('shadow-sm');
            }).on('mouseleave', '.recent-searches .badge', function() {
                $(this).removeClass('shadow-sm');
            });
            
            // Configuração básica do PDF.js para ser usado somente para extração de texto
            if (typeof pdfjsLib !== "undefined") {
                console.log("PDF.js detectado e pronto para uso.");
            } else {
                console.warn("PDF.js não foi carregado corretamente");
            }
            
          
        });
    </script>
</body>
</html>
