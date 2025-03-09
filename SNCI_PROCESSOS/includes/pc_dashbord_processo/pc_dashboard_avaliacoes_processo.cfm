<cfprocessingdirective pageencoding = "utf-8">
<style>
    /* Layout horizontal para os cards de status - ajustado para tamanho uniforme e linha única */
    .status-card {
        transition: all 0.3s ease;
        display: flex;
        flex-direction: row;
        align-items: center;
        text-align: left;
        padding: 0.5rem 0.75rem; /* Reduzido */
        height: 100%;
        min-height: 80px; /* Reduzido */
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
        font-size: 2rem; /* Reduzido */
        opacity: 0.3;
    }
    .status-card .status-info {
        flex-grow: 1;
        margin-right: 3rem;
    }
    .status-card .status-number {
        font-size: 1.5rem; /* Reduzido */
        font-weight: 700;
        margin-bottom: 0.1rem; /* Reduzido */
        line-height: 1;
    }
    .status-card .status-label {
        font-size: 0.8rem; /* Reduzido */
        margin: 0;
        opacity: 0.9;
        white-space: normal;
        line-height: 1.2;
        max-width: 95%;
    }
    
    /* Ajuste para garantir que os cards fiquem em linha única mas se adaptem à tela */
    #status-cards-container {
        display: flex;
        flex-wrap: wrap !important; /* Permitir quebra de linha para responsividade */
        padding-bottom: 5px;
        margin: 0 -5px;
        overflow-x: visible; /* Remover rolagem horizontal */
    }
    
    /* Classe para cada card individual - responsivo */
    .status-card-col {
        padding: 0 5px; /* Reduzido */
        flex: 1 1 240px; /* Flexível, mas com largura mínima de 240px */
        margin-bottom: 10px;
    }
    
    /* Remover exceções de cores para maior consistência */
    .status-card.bg-secondary .status-icon,
    .status-card.bg-warning .status-icon,
    .status-card.bg-danger .status-icon,
    .status-card.bg-info .status-icon,
    .status-card.bg-success .status-icon {
        color: white;
    }
    
    .distribuicao-status-container {
        margin-bottom: 1.5rem;
    }
    .distribuicao-tipos-container {
        margin-top: 2rem;
    }
    .icon-title {
        font-size: 1rem;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
    }
    .icon-title i {
        margin-right: 0.5rem;
    }
    .progress {
        height: 8px;
        margin-bottom: 0.5rem;
    }
    .tipo-item {
        display: flex;
        margin-bottom: 0.75rem;
        padding: 0.5rem;
        border-radius: 4px;
        border-left: 3px solid var(--cor-processo-andamento);
        background-color: rgba(0,0,0,0.03);
    }
    .tipo-item:hover {
        background-color: rgba(0,0,0,0.05);
    }
    .tipo-badge {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        border-radius: 50%;
        margin-right: 1rem;
        flex-shrink: 0;
    }
    .tipo-info {
        flex-grow: 1;
    }
    .tipo-descricao {
        font-weight: 500;
        font-size: 0.9rem;
        margin-bottom: 0.25rem;
        color: #333;
    }
    .tipo-quantidade {
        font-size: 1.1rem;
        font-weight: 600;
        color: #111;
    }
    .tipo-percentual {
        font-size: 0.8rem;
        color: #777;
    }
    
    /* Responsividade para os cards */
    @media (max-width: 768px) {
        .status-card-col {
            flex: 1 1 calc(50% - 10px); /* 50% da largura em telas médias menos o padding */
        }
        
        .status-card .status-number {
            font-size: 1.3rem;
        }
        
        .status-card .status-label {
            font-size: 0.75rem;
        }
    }
    
    @media (max-width: 576px) {
        .status-card-col {
            flex: 1 0 100%; /* 100% da largura em telas pequenas */
        }
    }

    /* Ajuste para garantir que os cards fiquem em linha única mas se adaptem à tela */
    #status-cards-container {
        display: flex;
        overflow-x: auto;
        padding-bottom: 5px;
        margin: 0 -5px;
        flex-wrap: nowrap !important;
    }
    
    /* Classe para cada card individual - responsivo com largura mínima maior */
    .status-card-col {
        padding: 0 5px;
        flex: 0 0 auto;
        width: auto;
        min-width: 240px; /* Aumentado para 240px conforme solicitado */
        max-width: 280px;
    }
    
    /* Ajuste responsivo para garantir que a largura dos cards se adapte ao container */
    @media (min-width: 1400px) {
        .status-card-col {
            flex: 0 0 auto;
            min-width: 240px;
            max-width: 300px; /* Limitar tamanho máximo em telas grandes */
        }
    }
    
    @media (max-width: 768px) {
        .status-card-col {
            min-width: 240px; /* Mantida a largura mínima mesmo em telas menores */
        }
        
        .status-card .status-number {
            font-size: 1.3rem;
        }
        
        .status-card .status-label {
            font-size: 0.75rem;
        }
    }
</style>

<div class="row distribuicao-status-container">
    <div class="col-12">
        <h5 class="icon-title">
            <i class="fas fa-chart-pie"></i>Distribuição de Processos por Status
        </h5>
    </div>
    <div id="status-cards-container" class="row">
        <!-- Cards de status serão inseridos aqui via JavaScript -->
        <div class="col-12">
            <div class="alert alert-info text-center">
                <i class="fas fa-spinner fa-spin mr-2"></i> Carregando dados...
            </div>
        </div>
    </div>
</div>

<div class="row distribuicao-tipos-container">
    <div class="col-md-6">
        <h5 class="icon-title">
            <i class="fas fa-clipboard-list"></i><span id="tipos-processo-titulo">Top 10 Tipos de Processos</span>
        </h5>
        <div id="tipos-container">
            <!-- Tipos de processos serão inseridos aqui via JavaScript -->
            <div class="alert alert-info text-center">
                <i class="fas fa-spinner fa-spin mr-2"></i> Carregando dados...
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <h5 class="icon-title">
            <i class="fas fa-tag"></i>Classificação de Processos
        </h5>
        <div id="classificacao-container">
            <!-- Classificações serão inseridas aqui via JavaScript -->
            <div class="alert alert-info text-center">
                <i class="fas fa-spinner fa-spin mr-2"></i> Carregando dados...
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Cores para os diferentes tipos de processos
    const coresTipos = [
        '#007bff', // azul
        '#6f42c1', // roxo
        '#e83e8c', // rosa
        '#fd7e14', // laranja
        '#20c997', // verde-água
        '#17a2b8', // ciano
        '#28a745', // verde
        '#ffc107', // amarelo
        '#dc3545'  // vermelho
    ];
    
    // Função para gerar uma cor aleatória para tipos adicionais se necessário
    function getRandomColor() {
        const letters = '0123456789ABCDEF';
        let color = '#';
        for (let i = 0; i < 6; i++) {
            color += letters[Math.floor(Math.random() * 16)];
        }
        return color;
    }
    
    // Função para atualizar a visualização de status
    window.atualizarViewStatus = function(dados) {
        if (!dados) return;
        
        // Atualizar o título dos tipos de processos com base no ano selecionado
        const anoSelecionado = window.anoSelecionado || "Todos";
        const anoInicial = window.anoInicial || "";
        const anoFinal = window.anoFinal || "";
        
        if (anoSelecionado === "Todos") {
            if (anoInicial && anoFinal) {
                $('#tipos-processo-titulo').text(`Top 10 Tipos de Processos ( ${anoInicial} - ${anoFinal} )`);
            } else {
                $('#tipos-processo-titulo').text("Top 10 Tipos de Processos");
            }
        } else {
            $('#tipos-processo-titulo').text("Tipos de Processos de " + anoSelecionado);
        }
        
        // Atualizar cards de status, passando o status selecionado
        atualizarCardsStatus(dados.distribuicaoStatus);
        
        // Atualizar tipos de processos
        atualizarTiposProcessos(dados.distribuicaoTipos, dados.totalProcessos);
        
        // Atualizar classificações de processos
        atualizarClassificacaoProcessos(dados.distribuicaoClassificacao, dados.totalProcessos);
    };
   
    // Função para atualizar os cards de status
    function atualizarCardsStatus(statusData) {
        if (!statusData || !statusData.length) {
            $('#status-cards-container').html('<div class="col-12"><div class="alert alert-warning text-center">Nenhum dado disponível para os filtros selecionados.</div></div>');
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
                $('#status-cards-container').html('<div class="col-12"><div class="alert alert-warning text-center">Nenhum dado disponível para o status selecionado.</div></div>');
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
                <div class="status-card-container w-100">
                    <div class="status-card ${statusClass} w-100" style="${status.estilo || ''}">
                        <div class="status-info">
                            <div class="status-number">${status.quantidade}</div>
                            <div class="status-label" title="${status.descricao}">${status.descricao}</div>
                        </div>
                        <div class="status-icon">
                            <i class="${statusIcon}"></i>
                        </div>
                    </div>
                </div>
            </div>`;
        });
        
        $('#status-cards-container').html(htmlStatus);
    }
    
    // Função para atualizar a visualização de tipos de processos
    function atualizarTiposProcessos(tiposData, totalProcessos) {
        if (!tiposData || !tiposData.length) {
            $('#tipos-container').html('<div class="alert alert-warning text-center">Nenhum tipo de processo disponível para os filtros selecionados.</div>');
            return;
        }
        
        // Ordenar por quantidade (decrescente)
        tiposData.sort((a, b) => b.quantidade - a.quantidade);
        
        // Verificar se o ano selecionado é "Todos" para limitar a 10 itens
        const anoSelecionado = window.anoSelecionado || "Todos";
        let tiposExibidos = tiposData;
        if (anoSelecionado === "Todos") {
            tiposExibidos = tiposData.slice(0, 10); // Limitar aos 10 primeiros apenas quando for "Todos"
        }
        
        let htmlTipos = '';
        
        tiposExibidos.forEach(function(tipo, index) {
            // Usar a descrição que já vem formatada corretamente do servidor
            let tipoDescricao = tipo.descricao;
            
            const percentual = totalProcessos > 0 ? ((tipo.quantidade / totalProcessos) * 100).toFixed(1) : 0;
            const corIndex = index % coresTipos.length;
            const corTipo = coresTipos[corIndex];
            
            htmlTipos += `
            <div class="tipo-item">
                <div class="tipo-badge" style="background-color: ${corTipo}; color: white;">
                    ${index + 1}
                </div>
                <div class="tipo-info">
                    <div class="tipo-descricao">${tipoDescricao}</div>
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="tipo-quantidade">${tipo.quantidade}</div>
                        <div class="tipo-percentual">${percentual}% dos processos</div>
                    </div>
                    <div class="progress">
                        <div class="progress-bar" role="progressbar" style="width: ${percentual}%; background-color: ${corTipo}" 
                            aria-valuenow="${percentual}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>`;
        });
        
        $('#tipos-container').html(htmlTipos);
    }
    
    // Função para atualizar a visualização de classificações de processos
    function atualizarClassificacaoProcessos(classificacaoData, totalProcessos) {
        if (!classificacaoData || !classificacaoData.length) {
            $('#classificacao-container').html('<div class="alert alert-warning text-center">Nenhuma classificação disponível para os filtros selecionados.</div>');
            return;
        }
        
        let htmlClassificacao = '';
        
        classificacaoData.forEach(function(classificacao, index) {
            const percentual = totalProcessos > 0 ? ((classificacao.quantidade / totalProcessos) * 100).toFixed(1) : 0;
            // Usar cores alternadas para as classificações
            const corIndex = index % coresTipos.length;
            const corClassificacao = coresTipos[corIndex];
            
            htmlClassificacao += `
            <div class="tipo-item">
                <div class="tipo-badge" style="background-color: ${corClassificacao}; color: white;">
                    ${index + 1}
                </div>
                <div class="tipo-info">
                    <div class="tipo-descricao">${classificacao.descricao}</div>
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="tipo-quantidade">${classificacao.quantidade}</div>
                        <div class="tipo-percentual">${percentual}% dos processos</div>
                    </div>
                    <div class="progress">
                        <div class="progress-bar" role="progressbar" style="width: ${percentual}%; background-color: ${corClassificacao}" 
                            aria-valuenow="${percentual}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>`;
        });
        
        $('#classificacao-container').html(htmlClassificacao);
    }
});
</script>
