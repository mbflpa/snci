<cfprocessingdirective pageencoding = "utf-8">
<style>
    .orgaos-heading {
        font-size: 1.1rem;
        margin-bottom: 1.5rem;
        font-weight: 500;
        color: #333;
        display: flex;
        align-items: center;
    }
    .orgaos-heading i {
        margin-right: 0.5rem;
        color: #007bff;
    }
    .orgao-container {
        width: 100%;
        padding-right: 0;
        overflow: visible; /* Remover rolagem vertical */
        height: auto; /* Altura automática */
        max-height: none; /* Remover limite de altura */
    }
    .orgao-card {
        display: flex;
        align-items: center;
        padding: 0.75rem; /* Reduzir padding para economizar espaço */
        border-radius: 8px;
        margin-bottom: 0.75rem; /* Reduzir espaçamento para caber mais itens */
        background-color: #fff;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        transition: all 0.2s ease;
        width: 100%;       /* Garantir largura completa */
        min-width: 0;      /* Permitir que encolha se necessário */
        box-sizing: border-box;
    }
    .orgao-card:hover {
        transform: translateX(5px);
        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        border-left: 3px solid #007bff;
    }
    .orgao-posicao {
        font-size: 1.5rem;
        font-weight: 700;
        color: #007bff;
        width: 30px; /* Menor largura */
        text-align: center;
        margin-right: 0.75rem; /* Menor margem */
    }
    .orgao-info {
        flex-grow: 1;
        min-width: 0;      /* Permitir que encolha se necessário */
        overflow: hidden;  /* Ocultar conteúdo que não couber */
    }
    .orgao-sigla {
        font-weight: 600;
        margin-bottom: 0.25rem;
        font-size: 1rem;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .orgao-mcu {
        font-size: 0.8rem;
        color: #6c757d;
    }
    .orgao-quantidade {
        font-size: 1.2rem;
        font-weight: 600;
        color: #28a745;
        margin-left: 1rem;
        white-space: nowrap;
    }
    .orgao-badge {
        display: inline-block;
        font-size: 0.75rem;
        border-radius: 30px;
        padding: 0.25rem 0.75rem;
        margin-left: 0.5rem;
        background-color: rgba(0, 123, 255, 0.1);
        color: #007bff;
    }
    .orgao-grafico-barra {
        height: 6px;
        background: #f1f1f1;
        border-radius: 3px;
        margin-top: 0.25rem;
        overflow: hidden;
    }
    .orgao-grafico-progresso {
        height: 100%;
        background: linear-gradient(90deg, #007bff, #00c6ff);
        border-radius: 3px;
    }
    .sem-dados {
        text-align: center;
        padding: 2rem;
        background-color: #f8f9fa;
        border-radius: 8px;
        color: #6c757d;
        font-size: 1.1rem;
    }
    .sem-dados i {
        font-size: 3rem;
        margin-bottom: 1rem;
        opacity: 0.5;
        display: block;
    }
    /* Estilizar barras para top 3 */
    .orgao-card:nth-child(1) .orgao-grafico-progresso {
        background: linear-gradient(90deg, #fd7e14, #ffc107);
    }
    .orgao-card:nth-child(1) .orgao-posicao {
        color: #fd7e14;
    }
    .orgao-card:nth-child(2) .orgao-grafico-progresso {
        background: linear-gradient(90deg, #6f42c1, #e83e8c);
    }
    .orgao-card:nth-child(2) .orgao-posicao {
        color: #6f42c1;
    }
    .orgao-card:nth-child(3) .orgao-grafico-progresso {
        background: linear-gradient(90deg, #20c997, #17a2b8);
    }
    .orgao-card:nth-child(3) .orgao-posicao {
        color: #20c997;
    }
    /* Responsividade para telas menores */
    @media (max-width: 768px) {
        .orgao-card {
            padding: 0.6rem;
        }
        
        .orgao-posicao {
            font-size: 1.25rem;
            width: 25px;
            margin-right: 0.5rem;
        }
        
        .orgao-sigla {
            font-size: 0.9rem;
        }
        
        .orgao-quantidade {
            font-size: 1rem;
        }
    }
    /* Estilos adicionais para órgãos - complementando os já existentes */
    .orgaos-controls {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1.5rem;
    }
    
    .orgaos-filter {
        display: flex;
        gap: 0.5rem;
    }
    
    .orgaos-filter-btn {
        padding: 0.25rem 0.75rem;
        font-size: 0.8rem;
        border-radius: 5px;
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
        color: #495057;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    
    .orgaos-filter-btn:hover,
    .orgaos-filter-btn.active {
        background-color: #007bff;
        color: #fff;
        border-color: #007bff;
    }
    
    .orgao-details {
        margin-top: 0.5rem;
        font-size: 0.8rem;
        color: #6c757d;
    }
    
    .orgao-details-item {
        display: inline-flex;
        align-items: center;
        margin-right: 1rem;
    }
    
    .orgao-details-item i {
        margin-right: 0.25rem;
    }
    
    /* Animações para os cards de órgãos */
    @keyframes slideInRight {
        0% { transform: translateX(30px); opacity: 0; }
        100% { transform: translateX(0); opacity: 1; }
    }
    
    .orgao-card {
        animation: slideInRight 0.3s forwards;
        animation-delay: calc(0.05s * var(--animOrder, 0));
        opacity: 0;
    }
    
    /* Responsividade adicional */
    @media (max-width: 576px) {
        .orgaos-controls {
            flex-direction: column;
            align-items: flex-start;
            gap: 0.75rem;
        }
        
        .orgao-badge {
            display: none; /* Esconder badge em telas muito pequenas */
        }
    }
</style>

<!--- Card para Órgãos Avaliados --->
<div class="card mb-4" id="card-orgaos">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-building mr-2"></i><span id="orgaos-avaliados-titulo">Top 10 Órgãos Avaliados</span>
        </h3>
    </div>
    <div class="card-body">
        <div id="orgaos-content">
            <div class="tab-loader">
              <i class="fas fa-spinner fa-spin"></i> Carregando informações dos órgãos...
            </div>
            
            <!--- Conteúdo específico do componente de órgãos --->
            <div id="orgaos-container" style="display: none;">
                <div id="orgaos-mais-avaliados-container" class="orgao-container">
                    <!-- Conteúdo gerado dinamicamente pelo JavaScript -->
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Verificar se a variável global já existe para evitar redefinição
if (typeof window.atualizarDadosComponentes === 'undefined') {
    window.atualizarDadosComponentes = [];
}

$(document).ready(function() {
    // Definir a função de atualização
    window.atualizarViewOrgaos = function(dados) {
        // Remove indicador de carregamento
        $("#orgaos-content .tab-loader").hide();
        
        // Mostra o container de órgãos
        $("#orgaos-container").show();
        
        // Atualizar o título baseado no ano selecionado
        const anoSelecionado = window.anoSelecionado || "Todos";
        const anoInicial = window.anoInicial || "";
        const anoFinal = window.anoFinal || "";
        
        if (anoSelecionado === "Todos") {
            if (anoInicial && anoFinal) {
                $('#orgaos-avaliados-titulo').text(`Top 10 Órgãos Avaliados ( ${anoInicial} - ${anoFinal} )`);
            } else {
                $('#orgaos-avaliados-titulo').text("Top 10 Órgãos Avaliados");
            }
        } else {
            $('#orgaos-avaliados-titulo').text("Órgãos Avaliados de " + anoSelecionado);
        }

        if (!dados || !dados.orgaosMaisAvaliados || dados.orgaosMaisAvaliados.length === 0) {
            // Se não houver dados, mostrar mensagem
            $('#orgaos-mais-avaliados-container').html(`
                <div class="sem-dados">
                    <i class="fas fa-building"></i>
                    <p>Não há dados de órgãos avaliados disponíveis para os filtros selecionados.</p>
                </div>
            `);
            return;
        }
        
        console.log("Visualização de órgãos atualizada com dados:", dados);
        
        // Ordenar os órgãos por quantidade (decrescente)
        const orgaosOrdenados = dados.orgaosMaisAvaliados.sort((a, b) => b.quantidade - a.quantidade);
        
        // Verificar se o ano selecionado é "Todos" para aplicar limite
        let orgaosExibidos = orgaosOrdenados;
        if (anoSelecionado === "Todos" && orgaosOrdenados.length > 10) {
            orgaosExibidos = orgaosOrdenados.slice(0, 10);
        }
        
        // Encontrar o maior valor para calcular percentuais
        const maxQuantidade = orgaosExibidos.length > 0 ? orgaosExibidos[0].quantidade : 0;
        
        // Construir o HTML para cada órgão
        let html = '';
        
        orgaosExibidos.forEach((orgao, index) => {
            // Calcular percentual para a barra de progresso
            const percentual = maxQuantidade > 0 ? (orgao.quantidade / maxQuantidade) * 100 : 0;
            
            html += `
            <div class="orgao-card" style="--animOrder: ${index}">
                <div class="orgao-posicao">${index + 1}</div>
                <div class="orgao-info">
                    <div class="d-flex align-items-center">
                        <div class="orgao-sigla">${orgao.sigla}</div>
                        <div class="orgao-badge">${orgao.mcu}</div>
                    </div>
                    <div class="orgao-grafico-barra">
                        <div class="orgao-grafico-progresso" style="width: ${percentual}%"></div>
                    </div>
                </div>
                <div class="orgao-quantidade">${orgao.quantidade}</div>
            </div>
            `;
        });
        
        // Atualizar o conteúdo no container
        $('#orgaos-mais-avaliados-container').html(html);
    };

    // Registrar a função de atualização no array global
    if (Array.isArray(window.atualizarDadosComponentes) &&
        !window.atualizarDadosComponentes.includes(window.atualizarViewOrgaos)) {
        window.atualizarDadosComponentes.push(window.atualizarViewOrgaos);
    }
    
    // Informar ao script principal que este componente está carregado
    if (typeof window.componentesCarregados !== 'undefined') {
        window.componentesCarregados.orgaosView = true;
        
        // Verificar se o outro componente também está carregado
        if (window.componentesCarregados.graficos) {
            // Chamar a atualização de dados se ambos estiverem carregados
            if (typeof window.atualizarDados === 'function') {
                window.atualizarDados();
            }
        }
    }
});
</script>
