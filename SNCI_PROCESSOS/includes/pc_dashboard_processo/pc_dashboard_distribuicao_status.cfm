<cfprocessingdirective pageencoding = "utf-8">
<!-- Carregamento direto do CSS específico do componente -->
<link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Status.css">

<!-- Card para Distribuição de Status -->
<div class="card mb-4" id="card-distribuicao-status">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-tasks mr-2"></i>Distribuição por Status
        </h3>
    </div>
    <div class="card-body">
        <div class="componente-distribuicao-status">
            <div class="status-cards-container">
                <!-- Conteúdo gerado dinamicamente via JavaScript -->
            </div>
        </div>
    </div>
</div>



<script>
// Carregar o componente base se ainda não foi carregado
if (typeof DashboardComponentFactory === 'undefined') {
    document.write('<script src="dist/js/snciDashboardComponent.js"><\/script>');
}

// Definir o componente de distribuição de status usando a fábrica
document.addEventListener("DOMContentLoaded", function() {
    // Esperar pelo carregamento da biblioteca de componentes
    var checkComponentLibrary = setInterval(function() {
        if (typeof DashboardComponentFactory !== 'undefined') {
            clearInterval(checkComponentLibrary);
            initDistribuicaoStatusComponent();
        }
    }, 100);

    // Inicializar o componente de distribuição de status
    function initDistribuicaoStatusComponent() {
        // Criar a instância do componente
        var DashboardStatus = DashboardComponentFactory.criar({
            nome: 'DistribuicaoStatus',
            dependencias: [],
            containerId: '.componente-distribuicao-status .status-cards-container',
            cardId: 'card-distribuicao-status',
            path: 'includes/pc_dashboard_processo/pc_dashboard_distribuicao_status.cfm',
            titulo: 'Distribuição por Status',
            dataUrl: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
            debug: true
        });
        
        // Sobrescrever método de atualização com a função específica para este componente
        DashboardStatus.atualizar = function(dados) {
            if (!dados || !dados.distribuicaoStatus || !dados.distribuicaoStatus.length) {
                $(".componente-distribuicao-status .status-cards-container").html(
                    '<div class="sem-dados-status">Nenhum dado de status disponível para os filtros selecionados.</div>'
                );
                return DashboardStatus;
            }
            
            var statusData = dados.distribuicaoStatus;
            var htmlStatus = '';
            
            statusData.forEach(function(status) {
                // Determinar o ícone com base no ID do status
                let statusIcon = "fas fa-question-circle";
                let statusClass = "bg-secondary";
                
                // Lógica de atribuição de ícones e classes
                switch(parseInt(status.id)) {
                    case 1: statusIcon = "fas fa-calendar-check"; statusClass = "bg-warning"; break;
                    case 2: statusIcon = "fas fa-tasks"; statusClass = "bg-info"; break;
                    case 3: statusIcon = "fas fa-clipboard-check"; statusClass = "bg-info"; break;
                    case 4: statusIcon = "fas fa-check-circle"; statusClass = "bg-success"; break;
                    case 5: statusIcon = "fas fa-award"; statusClass = "bg-success"; break;
                    case 6: statusIcon = "fas fa-times-circle"; statusClass = "bg-danger"; break;
                    case 7: statusIcon = "fas fa-pause-circle"; statusClass = "bg-secondary"; break;
                }
                
                if (status.estilo && status.estilo.trim() !== '') {
                    statusClass = '';
                }
                
                htmlStatus += `
                <div class="status-card-col">
                    <div class="status-card ${statusClass}" style="${status.estilo || ''}">
                        <div class="status-info">
                            <div class="status-number">${status.quantidade}</div>
                            <div class="status-label" title="${status.descricao}">${status.descricao}</div>
                        </div>
                        <div class="status-icon">
                            <i class="${statusIcon}"></i>
                        </div>
                    </div>
                </div>`;
            });
            
            $(".componente-distribuicao-status .status-cards-container").html(htmlStatus);
            return DashboardStatus;
        };
        
        // Inicializar e registrar o componente
        DashboardStatus.init().registrar();
        
        // Adicionar ícone de favorito ao card
        if (typeof initFavoriteIcon === 'function') {
            initFavoriteIcon('card-distribuicao-status', 
                            'includes/pc_dashboard_processo/pc_dashboard_distribuicao_status.cfm', 
                            'Distribuição por Status');
        }
        
        // Compatibilidade com interface antiga
        window.atualizarDistribuicaoStatus = DashboardStatus.atualizar;
        
        // Verificar se já existem dados disponíveis no momento da carga do componente
        if (window.dadosAtuais && window.dadosAtuais.distribuicaoStatus) {
            DashboardStatus.atualizar(window.dadosAtuais);
        }
    }
});
</script>