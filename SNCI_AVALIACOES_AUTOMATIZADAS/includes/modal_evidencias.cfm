<cfprocessingdirective pageencoding="utf-8">

<!-- Modal de Evidências -->
<div class="modal fade" id="modalEvidencias" tabindex="-1" role="dialog" aria-labelledby="modalEvidenciasLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered" role="document" style="max-width: 95%; width: 95%;">
        <div class="modal-content modern-modal">
            <div class="modal-header modern-header">
                <h5 class="modal-title d-flex align-items-center" id="modalEvidenciasLabel">
                    <i class="fas fa-table mr-2 modern-icon"></i>
                    Evidências
                </h5>
                <button type="button" class="close modern-close" data-dismiss="modal" aria-label="Fechar">
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
    /* Modernização geral */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

/* Modal com sombra e bordas arredondadas */
#modalEvidencias .modern-modal {
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
    overflow: hidden;
}

/* Cabeçalho moderno */
#modalEvidencias .modern-header {
    background: linear-gradient(90deg, #007bff 0%, #0056b3 100%);
    color: white;
    border-bottom: 1px solid #dee2e6;
}

/* Título do modal */
#modalEvidencias .modal-title {
    font-size: 1.1rem;
    font-weight: 600;
}

/* Ícone com destaque */
#modalEvidencias .modern-icon {
    font-size: 1.2rem;
    color: #ffffff;
}

/* Botão de fechar moderno */
#modalEvidencias .modern-close {
    color: white;
    opacity: 0.8;
    font-size: 1.5rem;
    transition: all 0.2s ease-in-out;
}

#modalEvidencias .modern-close:hover {
    color: #ffdddd;
    opacity: 1;
    transform: scale(1.1);
}

/* Corpo do modal mais limpo */
#modalEvidencias .modal-body {
    background-color: #f8f9fa;
}

/* Estilo do loading */
#modalEvidencias #evidenciasLoading p {
    color: #555;
    font-size: 0.95rem;
}

/* Erro visual */
#modalEvidencias #evidenciasError {
    border-left: 4px solid #dc3545;
    background-color: #f8d7da;
}

</style>

