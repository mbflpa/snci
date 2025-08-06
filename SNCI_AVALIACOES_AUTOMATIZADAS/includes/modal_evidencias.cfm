<cfprocessingdirective pageencoding="utf-8">

<!-- Modal de Evidências -->
<div class="modal fade" id="modalEvidencias" tabindex="-1" role="dialog" aria-labelledby="modalEvidenciasLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl" role="document" style="max-width: 95%; width: 95%;">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalEvidenciasLabel" style="font-size: 1rem;">
                    <i class="fas fa-table mr-2"></i>Evidências
                </h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Fechar">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            
            <div class="modal-body p-0">
                <div id="evidenciasLoading" class="text-center p-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="sr-only">Carregando...</span>
                    </div>
                    <p class="mt-2">Carregando dados da tabela...</p>
                </div>
                
                <div id="evidenciasContent" style="display: none;" class="p-3">
                    <div class="table-container" style="width: 100%; overflow: hidden;">
                        <table id="tabelaEvidencias" class="table table-striped table-bordered table-hover compact nowrap" style="width: 100%;">
                            <!-- Estrutura será criada dinamicamente pelo JavaScript -->
                        </table>
                    </div>
                </div>
                
                <div id="evidenciasError" style="display: none;" class="alert alert-danger m-3">
                    <h6><i class="fas fa-exclamation-triangle"></i> Erro ao carregar dados</h6>
                    <p id="evidenciasErrorMessage"></p>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* Estilos específicos para o modal de evidências */
#modalEvidencias .modal-dialog {
    margin: 1rem;
}

#modalEvidencias .modal-header {
    padding: 12px 20px; /* Reduzir altura do cabeçalho */
    min-height: auto;
}

#modalEvidencias .table-container {
    max-height: 75vh; /* Aumentar altura disponível para a tabela */
    overflow: auto;
    width: 100%;
}

#modalEvidencias table.dataTable {
    font-size: 0.85rem;
    border-collapse: collapse !important;
    width: auto !important; /* Permitir largura automática */
    min-width: 100%;
}

#modalEvidencias table.dataTable thead th {
    background-color: #343a40 !important;
    color: white !important;
    font-weight: 600;
    font-size: 0.8rem;
    padding: 8px 12px; /* Aumentar padding horizontal */
    text-align: center;
    border: 1px solid #495057;
    position: sticky;
    top: 0;
    z-index: 10;
    white-space: nowrap; /* Evitar quebra de linha nos cabeçalhos */
    min-width: 120px; /* Largura mínima para cabeçalhos */
}

#modalEvidencias table.dataTable tbody td {
    padding: 6px 12px; /* Aumentar padding horizontal */
    border: 1px solid #dee2e6;
    font-size: 0.8rem;
    white-space: nowrap;
    overflow: visible; /* Permitir overflow visível */
    text-overflow: clip; /* Não cortar texto */
    min-width: 120px; /* Largura mínima para células */
}

#modalEvidencias table.dataTable tbody tr:hover {
    background-color: #f8f9fa;
}

/* Configurar wrapper do DataTables para rolagem horizontal */
#modalEvidencias .dataTables_wrapper {
    overflow-x: auto;
    width: 100%;
}

#modalEvidencias .dataTables_scrollBody {
    overflow-x: auto !important;
    overflow-y: auto !important;
}

/* Ajustar controles do DataTables */
#modalEvidencias .dataTables_wrapper .dataTables_filter {
    float: right;
    text-align: right;
    margin-bottom: 10px;
}

#modalEvidencias .dataTables_wrapper .dataTables_length {
    float: left;
    margin-bottom: 10px;
}

/* Centralizar controles de paginação */
#modalEvidencias .dataTables_wrapper .dataTables_paginate {
    text-align: center !important;
    float: none !important;
    display: block;
    margin: 10px auto;
    padding-top: 0.25em;
}

/* Estilo para botão de exportação Excel */
#modalEvidencias .dt-buttons {
    text-align: center;
    margin: 10px 0;
}

#modalEvidencias .dt-button.excel-btn {
    background: #1f7a1f !important;
    border: 1px solid #1f7a1f !important;
    color: white !important;
    padding: 8px 16px;
    border-radius: 4px;
    font-size: 0.875rem;
    font-weight: 500;
    transition: all 0.3s ease;
    display: inline-flex;
    align-items: center;
    gap: 8px;
}

#modalEvidencias .dt-button.excel-btn:hover {
    background: #155d15 !important;
    border-color: #155d15 !important;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(31, 122, 31, 0.3);
}

#modalEvidencias .dt-button.excel-btn:active {
    transform: translateY(0);
    box-shadow: 0 2px 4px rgba(31, 122, 31, 0.3);
}

/* Ícone Excel personalizado */
#modalEvidencias .excel-icon {
    font-size: 1rem;
    color: white;
}

/* Ajustar layout dos controles */
#modalEvidencias .dataTables_wrapper .dataTables_info {
    clear: both;
    float: none;
    text-align: center;
    padding-top: 0.755em;
    margin: 5px 0;
}

/* Responsividade para telas menores */
@media (max-width: 768px) {
    #modalEvidencias .modal-dialog {
        margin: 0.5rem;
        max-width: 98%;
        width: 98%;
    }
    
    #modalEvidencias .modal-header {
        padding: 10px 15px; /* Reduzir ainda mais em telas pequenas */
    }
    
    #modalEvidencias .modal-title {
        font-size: 0.9rem; /* Fonte menor em mobile */
    }
    
    #modalEvidencias .table-container {
        max-height: 65vh; /* Ajustar altura em mobile */
    }
    
    #modalEvidencias table.dataTable tbody td {
        min-width: 100px;
        font-size: 0.75rem;
    }
    
    #modalEvidencias table.dataTable thead th {
        min-width: 100px;
        font-size: 0.75rem;
    }
}
</style>
