<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Busca PDF</title>
    <link rel="icon" type="image/png" href="../SNCI_PROCESSOS/dist/img/icone_sistema_standalone_ico.png">
     
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
            padding-top: 5px!important;
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
        
        /* Estilos para o carrossel de documentos */
        .document-scanner-container {
            width: 100%;
            height: 100px;
            margin: 0!important;
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden;
            position: relative;
            opacity: 0; /* Começa invisível */
            animation: fadeInContainer 0.8s ease-in-out 0.3s forwards; /* Animação de fade in */
        }
        
        /* Animação de surgimento apenas com fade in */
        @keyframes fadeInContainer {
            from { 
                opacity: 0;
            }
            to { 
                opacity: 1;
            }
        }
        
        .document-scanner-svg {
            width: 100%;
            max-width: 490px;
            height: auto;
        }
        
        .pdf-icon-path {
            fill: #f40f02;
        }
        
        .scanner-area {
            fill: rgba(0, 131, 202, 0.1);
            stroke: #0083ca;
        }
        
        .scan-line {
            fill: #0083ca;
            opacity: 0.8;
        }
        
        .document {
            fill: white;
            stroke: #ced4da;
        }
        
        /* Posicionamento dos itens do carrossel */
        .carousel-item:nth-child(1) {
            transform: translateX(-100%) scale(0.7);
            opacity: 0;
        }
        
        .carousel-item:nth-child(2) {
            transform: translateX(0) scale(1);
            opacity: 1;
        }
        
        .carousel-item:nth-child(3) {
            transform: translateX(100%) scale(0.7);
            opacity: 0;
        }
        
        /* Estilos para resultados em tempo real */
        #realTimeResults {
            max-height: 300px;
            overflow-y: auto;
            border-radius: 8px;
            background-color: #f8f9fa;
            display: none;
            margin-top: 25px;
        }
        
        #realTimeResultsList {
            padding: 10px 15px;
        }
        
        .realtime-result-item {
            padding: 10px;
            border-left: 3px solid #0083ca;
            margin-bottom: 10px;
            background-color: white;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,.1);
            transition: all 0.3s ease;
        }
        
        .realtime-result-item:hover {
            transform: translateX(3px);
            border-left-color: #005b8e;
            background-color: #f0f7fc;
        }
        
        .realtime-result-item a.result-link {
            color: #0083ca;
            text-decoration: none;
            font-weight: 500;
        }
        
        .realtime-result-item a.result-link:hover {
            text-decoration: underline;
        }
        
        /* Estilos aprimorados para destacar correspondências fuzzy */
        .fuzzy-match {
            background-color: #f8f9fa;
            padding: 12px 15px;
            border-left: 3px solid #17a2b8;
            margin-bottom: 15px;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,.05);
        }
        
        .match-info {
            display: block;
            font-size: 0.85rem;
            color: #6c757d;
            font-style: italic;
            margin-bottom: 10px;
            padding-bottom: 6px;
            border-bottom: 1px dotted #dee2e6;
        }
        
        .match-info small {
            color: #28a745;
            font-weight: 500;
            background: rgba(40, 167, 69, 0.1);
            padding: 1px 4px;
            border-radius: 3px;
        }
        
        .fuzzy-match mark {
            background-color: rgba(255, 193, 7, 0.4);
            padding: 2px 3px;
            border-radius: 3px;
            font-weight: 500;
            border-bottom: 1px dashed #fd7e14;
        }
        
        /* Animação para destacar novos termos incluídos na busca */
        @keyframes highlightNew {
            from {background-color: rgba(23, 162, 184, 0.2);}
            to {background-color: transparent;}
        }
        
        .new-term {
            animation: highlightNew 2s ease-out;
            border-radius: 2px;
        }

        /* Estilos para destacar variações de escrita */
        .spelling-variant-info {
            display: block;
            font-size: 0.85rem;
            color: #6c757d;
            font-style: italic;
            margin-bottom: 8px;
            padding-bottom: 5px;
            border-bottom: 1px dotted #dee2e6;
        }
        
        .spelling-variant-info::before {
            content: "\f071";
            font-family: "Font Awesome 5 Free";
            font-weight: 900;
            color: #fd7e14;
            margin-right: 5px;
        }

        /* Estilos para as estatísticas detalhadas */
        .stats-icon {
            cursor: pointer;
            color: #0083ca;
            margin-left: 5px;
            transition: all 0.2s ease;
        }
        
        .stats-icon:hover {
            color: #005b8e;
            transform: scale(1.1);
        }
        
        .popover-stats {
            max-width: 400px;
            font-size: 0.9rem;
        }
        
        .popover-stats .popover-header {
            background-color: #0083ca;
            color: white;
            font-weight: 600;
            border-bottom: 0;
        }
        
        .popover-stats .popover-body {
            padding: 15px;
            color: #495057;
        }
        
        .stats-table {
            width: 100%;
            margin-bottom: 0;
        }
        
        .stats-table td {
            padding: 6px 0;
            border-top: 1px solid #e9ecef;
        }
        
        .stats-table tr:first-child td {
            border-top: 0;
        }
        
        .stats-table td:first-child {
            font-weight: 600;
            color: #495057;
        }
        
        .stats-table td:last-child {
            text-align: right;
        }
        
        .stats-metric {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            margin-right: 0.5rem;
            border-radius: 0.25rem;
            font-weight: 600;
            font-size: 0.85rem;
        }
        
        .stats-metric-primary {
            background-color: rgba(0, 131, 202, 0.15);
            color: #0083ca;
        }
        
        .stats-metric-success {
            background-color: rgba(40, 167, 69, 0.15);
            color: #28a745;
        }
        
        .stats-metric-warning {
            background-color: rgba(255, 193, 7, 0.15);
            color: #ffc107;
        }
        
        .stats-metric-info {
            background-color: rgba(23, 162, 184, 0.15);
            color: #17a2b8;
        }
        
        .filename-truncated {
            max-width: 200px;
            display: inline-block;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            vertical-align: middle;
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
                                           placeholder="Separe múltiplas palavras-chave com espaço" required>
                                    <div class="input-group-append">
                                        <button type="submit" class="btn btn-primary btn-search">
                                            <i class="fas fa-search mr-1"></i> Buscar
                                        </button>
                                    </div>
                                </div>
                                <!-- Filtros em uma única linha -->
                                <div class="form-row ">
                                    
                                    <!-- Título da seção de filtros -->
                                    <div class="col-auto mb-2 d-flex align-items-center mr-2">
                                        <i class="fas fa-filter mr-1"></i>
                                        <strong>Filtros:</strong>
                                    </div>
                                    <!-- CAMPO: Ano do processo -->
                                    <div style="width: 120px;" class="mb-2 mr-3">
                                        <select class="form-control" id="searchYear" name="searchYear">
                                            <option value="">Ano Processos</option>
                                            <cfset currentYear = year(now())>
                                            <cfoutput>
                                                <cfloop from="2019" to="#currentYear#" index="yr">
                                                    <option value="#yr#">#yr#</option>
                                                </cfloop>
                                            </cfoutput>
                                        </select>
                                    </div>
                                    
                                    <!-- CAMPO: Superintendência Regional -->
                                    <div style="width: 180px;" class="mb-2 mr-3">
                                        <select class="form-control" id="searchSuperintendence" name="searchSuperintendence">
                                            <option value="">Todas as SE e CS</option>
                                            <option value="01">CS - 01</option>
                                            <option value="03">SE/ACR - 03</option>
                                            <option value="04">SE/AL - 04</option>
                                            <option value="06">SE/AM - 06</option>
                                            <option value="05">SE/AP - 05</option>
                                            <option value="08">SE/BA - 08</option>
                                            <option value="10">SE/BSB - 10</option>
                                            <option value="12">SE/CE - 12</option>
                                            <option value="14">SE/ES - 14</option>
                                            <option value="16">SE/GO - 16</option>
                                            <option value="18">SE/MA - 18</option>
                                            <option value="20">SE/MG - 20</option>
                                            <option value="22">SE/MS - 22</option>
                                            <option value="24">SE/MT - 24</option>
                                            <option value="28">SE/PA - 28</option>
                                            <option value="30">SE/PB - 30</option>
                                            <option value="32">SE/PE - 32</option>
                                            <option value="34">SE/PI - 34</option>
                                            <option value="36">SE/PR - 36</option>
                                            <option value="50">SE/RJ - 50</option>
                                            <option value="60">SE/RN - 60</option>
                                            <option value="26">SE/RO - 26</option>
                                            <option value="65">SE/RR - 65</option>
                                            <option value="64">SE/RS - 64</option>
                                            <option value="68">SE/SC - 68</option>
                                            <option value="70">SE/SE - 70</option>
                                            <option value="74">SE/SPI - 74</option>
                                            <option value="72">SE/SPM - 72</option>
                                            <option value="75">SE/TO - 75</option>
                                        </select>
                                    </div>
                                    
                                    <!-- CAMPO: Número do processo (apenas números, 10 dígitos) -->
                                    <div style="width: 180px;" class="mb-2">
                                        <div class="input-group">
                                            
                                            <input type="text" 
                                                class="form-control" 
                                                id="searchTitle" 
                                                name="searchTitle" 
                                                placeholder="N° Processo" 
                                                pattern="[0-9]{10}" 
                                                maxlength="10" 
                                                title="Digite exatamente 10 dígitos (apenas números)">
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Opções avançadas de busca (colapsáveis) -->
                                <div class="d-flex justify-content-between align-items-center mb-2" style="margin-top:20px;">
                                   
                                    <a class="options-toggle text-primary" data-toggle="collapse" href="#advancedOptions">
                                        <i class="fas fa-cog mr-1"></i> Opções avançadas <i class="fas fa-chevron-down ml-1"></i>
                                    </a>
                                </div>
                                
                                <div class="collapse" id="advancedOptions" >
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
                                                        <option value="-1">Em qualquer parte</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="col-md-5">
                                                <div class="form-group">
                                                    <label class="font-weight-bold text-primary mb-2">Opções adicionais</label>
                                                    <div class="custom-control custom-checkbox mb-2">
                                                        <input type="checkbox" id="searchUseSynonyms" class="custom-control-input">
                                                        <label class="custom-control-label" for="searchUseSynonyms">Considerar sinônimos</label>
                                                        <small class="form-text text-muted">Inclui sinônimos dos termos buscados</small>
                                                    </div>
                                                    <div class="custom-control custom-checkbox mb-2">
                                                        <input type="checkbox" id="searchUseSpellingVariants" class="custom-control-input">
                                                        <label class="custom-control-label" for="searchUseSpellingVariants">Considerar escritas erradas</label>
                                                        <small class="form-text text-muted">Encontra palavras mesmo com erros de digitação ou parte da palavra</small>
                                                    </div>
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
                            <!-- Indicador de carregamento - SVG animado de documentos -->
                            <div class="text-center" id="searchLoading" style="display:none;">
                                <div class="document-scanner-container">
                                    <svg class="document-scanner-svg" viewBox="0 0 500 150" xmlns="http://www.w3.org/2000/svg">
                                        <defs>
                                            <g id="pdf-document">
                                                <!-- Documento base com sombra suave -->
                                                <rect x="1" y="1" width="60" height="80" rx="3" ry="3" fill="#e0e0e0" opacity="0.5"/>
                                                <rect class="document" width="60" height="80" rx="3" ry="3" stroke-width="1" fill="white" stroke="#cccccc"/>
                                                
                                                <!-- Faixa vermelha no topo para o PDF -->
                                                <rect x="0" y="0" width="60" height="15" fill="#f40f02" rx="3" ry="0"/>
                                                <text x="30" y="11" text-anchor="middle" font-size="10" fill="white" font-weight="bold">PDF</text>
                                                
                                                <!-- Linhas de conteúdo simulado -->
                                                <rect x="10" y="22" width="40" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="28" width="40" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="34" width="40" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="40" width="40" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="46" width="30" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="52" width="40" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="58" width="25" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="64" width="35" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                                <rect x="10" y="70" width="20" height="2" fill="#e6e6e6" rx="1" ry="1"/>
                                            </g>
                                            <rect id="scanLine" class="scan-line" width="56" height="3" rx="1" ry="1"/>
                                        </defs> 

                                        <!-- Área de escaneamento central com animação de surgimento suave -->
                                        <rect class="scanner-area" x="220" y="35" width="70" height="90" rx="5" ry="5" stroke-dasharray="4,2" opacity="0">
                                            <animate 
                                                attributeName="opacity" 
                                                from="0" to="1" 
                                                begin="0s" dur="0.8s" 
                                                fill="freeze"
                                                id="scannerAppear" />
                                        </rect>
                                        
                                        <!-- Documento com animação sequencial -->
                                        <g id="animated-document" opacity="0">
                                            <use href="#pdf-document" x="0" y="40">
                                                <!-- Animação com parada no meio para escaneamento -->
                                                <animateTransform 
                                                    attributeName="transform" 
                                                    type="translate" 
                                                    values="-100,0; 225,0; 225,0; 600,0" 
                                                    keyTimes="0; 0.3; 0.7; 1" 
                                                    dur="1.5s" 
                                                    repeatCount="indefinite" 
                                                    id="docAnimation" 
                                                    begin="indefinite" />
                                                <animate 
                                                    attributeName="opacity" 
                                                    values="0; 1; 1; 0" 
                                                    keyTimes="0; 0.3; 0.7; 1" 
                                                    dur="1.5s" 
                                                    repeatCount="indefinite" 
                                                    id="opacityAnimation" 
                                                    begin="indefinite" />
                                            </use>
                                            <use href="#scanLine" x="227" y="45">
                                                <animate 
                                                    attributeName="y"
                                                    values="45; 45; 115; 45" 
                                                    keyTimes="0; 0.3; 0.7; 1" 
                                                    dur="1.5s" 
                                                    repeatCount="indefinite" 
                                                    begin="indefinite"
                                                    id="scanLineAnimation"/>
                                                <animate 
                                                    attributeName="opacity"
                                                    values="0; 1; 1; 0" 
                                                    keyTimes="0; 0.3; 0.7; 1" 
                                                    dur="1.5s" 
                                                    repeatCount="indefinite" 
                                                    begin="indefinite"
                                                    id="scanLineOpacity"/>
                                            </use>
                                        </g> 
                                    </svg>
                                </div>
                                <p class="mt-3 lead">Procurando nos documentos. Isso pode levar alguns instantes...</p>
                                
                                <!-- Barra de progresso e status -->
                                <div class="progress pdf-progress mx-auto" style="width:70%; height: 8px;">
                                    <div class="progress-bar bg-primary progress-bar-striped progress-bar-animated" id="processingProgress" role="progressbar" style="width: 0%"></div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mt-2 mx-auto" style="width:70%;">
                                    <small id="processingStatus" class="form-text text-muted">Preparando busca...</small>
                                    <button id="cancelSearch" class="btn btn-sm btn-outline-danger">
                                        <i class="fas fa-times mr-1"></i> Cancelar busca
                                    </button>
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
                        </div>
                        
                        <!-- Lista de resultados -->
                        <div class="search-results" id="searchResults" style="padding:0 10px 10px!important"></div>
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
        // Suprimir warnings específicos do pdf.worker.min.js
        window.TT = window.TT || {};
        window.TT.noop = function() {};
        
        // Configurar o worker do PDF.js
        if (typeof pdfjsLib !== 'undefined') {
            // Definir a fonte do worker manualmente
            pdfjsLib.GlobalWorkerOptions.workerSrc = 'plugins/pdf.js/pdf.worker.min.js';
        } else {
            console.error("PDF.js não foi carregado corretamente.");
        }
    </script>
    
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
            });
            
            // Adicionar efeito hover aos badges de busca recente
            $(document).on('mouseenter', '.recent-searches .badge', function() {
                $(this).addClass('shadow-sm');
            }).on('mouseleave', '.recent-searches .badge', function() {
                $(this).removeClass('shadow-sm');
            });
            
            // CORREÇÃO: Não iniciar animações no submit do formulário, mas deixar o PdfSearchManager gerenciar isso
            // Remover a manipulação direta das animações SVG e delegar para o código de busca
            $('#searchFaqForm').on('submit', function(e) {
                e.preventDefault();
                // Apenas chama performSearch sem iniciar animações diretamente
                PdfSearchManager.performSearch();
            });
            
            // SOLUÇÃO DEFINITIVA: Substituir popover por modal para estatísticas
            $(document).off('click', '.stats-icon').on('click', '.stats-icon', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                if (window.statsDetailsHtml) {
                    $('#statsModalBody').html(window.statsDetailsHtml);
                    $('#statsModal').modal('show');
                } else {
                    alert("Estatísticas não disponíveis no momento");
                }
            });
        });
    </script>
    
    <!-- Adicionar modal para estatísticas detalhadas -->
    <div class="modal fade" id="statsModal" tabindex="-1" role="dialog" aria-labelledby="statsModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title" id="statsModalLabel">Estatísticas Detalhadas</h5>
            <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body" id="statsModalBody">
            <!-- O conteúdo será inserido via JavaScript -->
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
          </div>
        </div>
      </div>
    </div>
</body>
</html>
