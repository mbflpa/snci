<cfprocessingdirective pageencoding = "utf-8">
<style>
    /* Layout horizontal para os cards de status */
    .status-card {
        transition: all 0.3s ease;
        display: flex;
        flex-direction: row;
        align-items: center;
        text-align: left;
        padding: 0.5rem 0.75rem;
        height: 100%;
        min-height: 80px;
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
    
    /* Ajuste para garantir que os cards fiquem em linha única mas se adaptem à tela */
    #status-cards-row {
        display: flex;
        overflow-x: auto;
        padding-bottom: 5px;
        margin: 0 -5px;
        flex-wrap: nowrap !important;
    }
    
    /* Classe para cada card individual */
    .status-card-col {
        padding: 0 5px;
        flex: 0 0 auto;
        width: auto;
        min-width: 240px;
        max-width: 280px;
    }
    
    /* Ajuste responsivo */
    @media (min-width: 1400px) {
        .status-card-col {
            flex: 0 0 auto;
            min-width: 240px;
            max-width: 300px;
        }
    }
    
    @media (max-width: 768px) {
        .status-card-col {
            min-width: 240px;
        }
        
        .status-card .status-number {
            font-size: 1.3rem;
        }
        
        .status-card .status-label {
            font-size: 0.75rem;
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
</style>

<div id="status-cards-row" class="row">
    <!-- Cards de status serão inseridos aqui via JavaScript -->
    <div class="col-12">
        <div class="alert alert-info text-center">
            <i class="fas fa-spinner fa-spin mr-2"></i> Carregando dados...
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Função para atualizar os cards de status
    window.atualizarStatusCards = function(statusData) {
        console.log("atualizarStatusCards chamado com dados:", statusData);
        
        if (!statusData || !statusData.length) {
            $('#status-cards-row').html('<div class="col-12"><div class="alert alert-warning text-center">Nenhum dado disponível para os filtros selecionados.</div></div>');
            return;
        }
        
        // Verificar o filtro de status atual
        var statusSelecionado = window.statusSelecionado || "Todos";
        
        // Filtrar os dados se um status específico foi selecionado
        var dadosFiltrados = statusData;
        if (statusSelecionado !== "Todos") {
            dadosFiltrados = statusData.filter(function(status) {
                return status.id === parseInt(statusSelecionado);
            });
            
            if (dadosFiltrados.length === 0) {
                $('#status-cards-row').html('<div class="col-12"><div class="alert alert-warning text-center">Nenhum dado disponível para o status selecionado.</div></div>');
                return;
            }
        }
        
        // Usar layout responsivo sem rolagem horizontal
        let htmlStatus = '';
        
        dadosFiltrados.forEach(function(status) {
            // Determinar o ícone com base no ID do status (sem animação)
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
            
            // Card com layout responsivo
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
        
        $('#status-cards-row').html(htmlStatus);
    };
});
</script>
