<cfprocessingdirective pageencoding = "utf-8">

<!-- Card para Distribuição de Status -->
<div class="card mb-4" id="card-distribuicao-status">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-chart-pie mr-2"></i>Distribuição de Processos por Status
        </h3>
    </div>
    <div class="card-body">
        <div class="componente-distribuicao-status">
            <div class="status-cards-container" id="distribuicao-status-container">
                <!-- Cards de status serão inseridos aqui via JavaScript -->
                <div class="sem-dados-status">
                    <i class="fas fa-spinner fa-spin mr-2"></i> Carregando dados...
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    /* Layout para os cards de status - atualizado para grid responsiva */
    .status-card {
        transition: all 0.3s ease;
        display: flex;
        flex-direction: row;
        align-items: center;
        text-align: left;
        padding: 0.4rem 0.6rem; /* Reduzido de 0.5rem 0.75rem */
        height: 100%;
        min-height: 75px; /* Reduzido de 80px */
        border-radius: 6px;
        position: relative;
        overflow: hidden;
    }
    .status-card:hover {
        transform: translateY(2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .status-card .status-icon {
        position: absolute;
        right: 0.75rem;
        top: 50%;
        transform: translateY(-50%);
        font-size: 2rem;
        opacity: 0.3;
    }
    .status-card .status-info {
        flex-grow: 1;
        margin-right: 3rem;
    }
    .status-card .status-number {
        font-size: 1.5rem;
        font-weight: 700;
        margin-bottom: 0.1rem;
        line-height: 1;
    }
    .status-card .status-label {
        font-size: 0.8rem;
        margin: 0;
        opacity: 0.9;
        white-space: normal;
        line-height: 1.2;
        max-width: 95%;
    }
    
    /* Ajuste para grid responsiva em vez de rolagem horizontal - reduzindo o gap entre os cards */
    .status-cards-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
        gap: 6px; /* Reduzido de 10px para 6px */
        width: 100%;
    }
    
    /* Classe para cada card individual - adaptada para grid */
    .status-card-col {
        width: 100%;
        padding: 0; /* Remover qualquer padding */
    }
    
    /* Ajuste responsivo para telas diferentes */
    @media (min-width: 1400px) {
        .status-cards-container {
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); 
            gap: 6px; 
        }
    }
    
    @media (max-width: 992px) {
        .status-cards-container {
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 5px; 
        }
    }
    
    @media (max-width: 768px) {
        .status-cards-container {
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        }
        
        .status-card .status-number {
            font-size: 1.3rem;
        }
        
        .status-card .status-label {
            font-size: 0.75rem;
        }
    }
    
    @media (max-width: 576px) {
        .status-cards-container {
            grid-template-columns: 1fr;
        }
    }
    
    /* Remover exceções de cores para maior consistência */
    .status-card.bg-secondary .status-icon,
    .status-card.bg-warning .status-icon,
    .status-card.bg-danger .status-icon,
    .status-card.bg-info .status-icon,
    .status-card.bg-success .status-icon {
        color: white;
    }
    
    /* Contêiner principal do componente */
    .componente-distribuicao-status {
        width: 100%;
    }
    
    /* Estilos para quando não há dados */
    .sem-dados-status {
        text-align: center;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 6px;
        color: #6c757d;
    }

    /* Estilos específicos para a distribuição de status */
    .distribuicao-status-container {
        padding: 1rem 0.5rem;
    }
    
    .status-title {
        font-size: 1.1rem;
        font-weight: 600;
        margin-bottom: 1.5rem;
        color: #495057;
    }
    
    .status-progress-container {
        margin-bottom: 1.5rem;
    }
    
    .status-label {
        display: flex;
        justify-content: space-between;
        margin-bottom: 0.5rem;
    }
    
    .status-label-text {
        font-weight: 500;
        font-size: 0.9rem;
    }
    
    .status-label-value {
        font-weight: 700;
        font-size: 0.9rem;
    }
    
    .status-progress {
        height: 10px;
        border-radius: 5px;
        background-color: #e9ecef;
        overflow: hidden;
    }
    
    .status-progress-bar {
        height: 100%;
        border-radius: 5px;
        transition: width 1s ease;
    }
    
    /* Classes de cores para status específicos */
    .status-andamento {
        background-color: #007bff;
    }
    
    .status-concluido {
        background-color: #28a745;
    }
    
    .status-pendente {
        background-color: #fd7e14;
    }
    
    .status-cancelado {
        background-color: #dc3545;
    }
    
    .status-outro {
        background-color: #6c757d;
    }
    
    /* Animação para barras de progresso */
    @keyframes progressAnimation {
        0% { width: 0; }
    }
    
    .status-progress-bar {
        animation: progressAnimation 1.5s ease-in-out;
    }
</style>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.distribuicaoStatusLoaded === 'undefined') {
        window.distribuicaoStatusLoaded = true;
        
        // Função para atualizar os cards de status
        window.atualizarDistribuicaoStatus = function(statusData) {
            if (!statusData || !statusData.length) {
                $('#distribuicao-status-container').html('<div class="sem-dados-status">Nenhum dado disponível para os filtros selecionados.</div>');
                return;
            }
            
            // Verificar se há um filtro de status global
            var statusSelecionado = window.statusSelecionado || "Todos";
            
            // Filtrar os dados se um status específico foi selecionado
            var dadosFiltrados = statusData;
            if (statusSelecionado !== "Todos") {
                dadosFiltrados = statusData.filter(function(status) {
                    return status.id === parseInt(statusSelecionado);
                });
                
                if (dadosFiltrados.length === 0) {
                    $('#distribuicao-status-container').html('<div class="sem-dados-status">Nenhum dado disponível para o status selecionado.</div>');
                    return;
                }
            }
            
            // Usar layout responsivo
            let htmlStatus = '';
            
            dadosFiltrados.forEach(function(status) {
                // Determinar o ícone com base no ID do status
                let statusIcon = 'fas fa-question-circle';
                let statusClass = 'bg-secondary';
                
                switch (parseInt(status.id)) {
                    case 1: // Planejado
                        statusIcon = 'fas fa-calendar-check';
                        statusClass = 'bg-warning';
                        break;
                    case 2: // Em Andamento
                        statusIcon = 'fas fa-tasks';
                        statusClass = 'bg-info';
                        break;
                    case 3: // Em Andamento (variação)
                        statusIcon = 'fas fa-clipboard-check';
                        statusClass = 'bg-info';
                        break;
                    case 4: // Concluído
                        statusIcon = 'fas fa-check-circle';
                        statusClass = 'bg-success';
                        break;
                    case 5: // Concluído (variação)
                        statusIcon = 'fas fa-award';
                        statusClass = 'bg-success';
                        break;
                    case 6: // Cancelado
                        statusIcon = 'fas fa-times-circle';
                        statusClass = 'bg-danger';
                        break;
                    case 7: // Suspenso
                        statusIcon = 'fas fa-pause-circle';
                        statusClass = 'bg-secondary';
                        break;
                }
                
                // Se há estilo específico definido no banco de dados, usar ele
                if (status.estilo && status.estilo.trim() !== '') {
                    statusClass = ''; // Limpar classes padrão para usar o estilo personalizado
                }
                
                // Card com layout responsivo - agora adaptado para grid
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
            
            $('#distribuicao-status-container').html(htmlStatus);
        };

         // Inicializar o ícone de favorito para este card
        const cardId = 'card-distribuicao-status';
        const componentPath = 'includes/pc_dashboard_processo/pc_dashboard_distribuicao_status.cfm';
        const componentTitle = 'Indicadores de Processos';
        
        // Verificar se a função initFavoriteIcon está disponível
        if (typeof initFavoriteIcon === 'function') {
            // Adicionar o ícone de favorito ao cabeçalho do card
            initFavoriteIcon(cardId, componentPath, componentTitle);
        } else {
            console.error('A função initFavoriteIcon não está disponível. Verifique se o arquivo snciProcesso.js foi carregado corretamente.');
        }
    }
    
    // Adicionar este código para garantir que o componente seja incluído na atualização de dados
    if (typeof window.atualizarDadosComponentes !== 'function') {
        window.atualizarDadosComponentes = [];
    }
    
    // Registrar este componente para ser atualizado quando os dados forem carregados
    window.atualizarDadosComponentes.push(function(dados) {
        if (dados && dados.distribuicaoStatus) {
            window.atualizarDistribuicaoStatus(dados.distribuicaoStatus);
        }
    });
    
    // Verificar se já existem dados disponíveis no momento da carga do componente
    if (window.dadosAtuais && window.dadosAtuais.distribuicaoStatus) {
        window.atualizarDistribuicaoStatus(window.dadosAtuais.distribuicaoStatus);
    }
});
</script>