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
        border-radius: 6px;
        margin-bottom: 0.75rem; /* Reduzir espaçamento para caber mais itens */
        background-color: rgba(0,0,0,0.03);
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        transition: all 0.2s ease;
        width: 100%;       /* Garantir largura completa */
        min-width: 0;      /* Permitir que encolha se necessário */
        box-sizing: border-box;
        border-left: 4px solid #20c997; /* Cor diferente dos outros componentes */
    }
    .orgao-card:hover {
        background-color: rgba(0,0,0,0.05);
        transform: translateX(3px);
        box-shadow: 0 2px 5px rgba(0,0,0,0.12);
    }
    .orgao-posicao {
        width: 36px;
        height: 36px;
        min-width: 36px; /* Garante tamanho mínimo */
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.1rem;
        border-radius: 50%;
        margin-right: 0.8rem;
        flex-shrink: 0;
        font-weight: 600;
        color: white;
    }
    .orgao-info {
        flex-grow: 1;
        min-width: 0;      /* Permitir que encolha se necessário */
        overflow: hidden;  /* Ocultar conteúdo que não couber */
    }
    .orgao-sigla {
        font-weight: 500;
        margin-bottom: 0.25rem;
        font-size: 0.85rem;
        color: #333;
    }
    .orgao-mcu {
        font-size: 0.75rem;
        color: #777;
        margin-bottom: 0.5rem;
    }
    .orgao-quantidade {
        font-size: 1rem;
        font-weight: 600;
        color: #111;
        margin-right: 1rem;
    }
    .orgao-percentual {
        font-size: 0.75rem;
        color: #777;
        white-space: nowrap;
    }
    .orgao-badge {
        font-size: 0.75rem;
        color: #007bff;
        background-color: rgba(0, 123, 255, 0.1);
        border-radius: 30px;
        padding: 0.25rem 0.75rem;
        margin-left: 0.5rem;
    }
    .orgao-metricas {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.4rem;
        flex-wrap: wrap;
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
        background: linear-gradient(90deg, #20c997, #17a2b8);
        border-radius: 3px;
    }
    .sem-dados {
        text-align: center;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 6px;
        color: #6c757d;
        font-size: 1.1rem;
    }
    .sem-dados i {
        font-size: 3rem;
        margin-bottom: 1rem;
        opacity: 0.5;
        display: block;
    }
    /* Removendo as regras específicas para o top 3 */
    .orgao-card:nth-child(1) .orgao-posicao,
    .orgao-card:nth-child(2) .orgao-posicao,
    .orgao-card:nth-child(3) .orgao-posicao,
    .orgao-card:nth-child(n+4) .orgao-posicao {
        background-color: initial; /* Removendo as cores específicas */
    }
    
    .orgao-card:nth-child(1) .orgao-grafico-progresso,
    .orgao-card:nth-child(2) .orgao-grafico-progresso,
    .orgao-card:nth-child(3) .orgao-grafico-progresso {
        background: initial; /* Removendo os gradientes específicos */
    }
    /* Responsividade para telas menores */
    @media (max-width: 768px) {
        .orgao-card {
            padding: 0.6rem;
        }
        
        .orgao-posicao {
            width: 30px;
            height: 30px;
            min-width: 30px;
            font-size: 0.9rem;
            margin-right: 0.6rem;
        }
        
        .orgao-sigla {
            font-size: 0.8rem;
        }
        
        .orgao-quantidade {
            font-size: 0.9rem;
        }
    }
    @media (max-width: 576px) {
        .orgao-badge {
            display: none; /* Esconder badge em telas muito pequenas */
        }
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
    
    /* Estilo para o label de processos */
    .orgao-label {
        font-size: 0.7rem;
        color: #888;
        font-weight: normal;
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
            <div id="orgaos-container">
                <div id="orgaos-mais-avaliados-container" class="orgao-container">
                    <!-- Conteúdo gerado dinamicamente pelo JavaScript -->
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Carregar o componente base se ainda não foi carregado
if (typeof DashboardComponentFactory === 'undefined') {
    document.write('<script src="dist/js/snciDashboardComponent.js"><\/script>');
}

// Registrar função global imediatamente para evitar problemas de timing
window.atualizarViewOrgaos = function(dados) {
    console.log("[OrgaosView] Chamada direta para atualizarViewOrgaos");
    if (window.DashboardOrgaos && typeof window.DashboardOrgaos.atualizar === 'function') {
        return window.DashboardOrgaos.atualizar(dados);
    } else {
        console.error("[OrgaosView] DashboardOrgaos não está inicializado ainda");
        window.orgaosDadosPendentes = dados;
        return false;
    }
};

// Definir o componente de órgãos usando a fábrica
document.addEventListener("DOMContentLoaded", function() {
    // Esperar pelo carregamento da biblioteca de componentes
    var checkComponentLibrary = setInterval(function() {
        if (typeof DashboardComponentFactory !== 'undefined') {
            clearInterval(checkComponentLibrary);
            initOrgaosComponent();
        }
    }, 100);

    // Inicializar o componente de órgãos
    function initOrgaosComponent() {
        // Cores para os diferentes órgãos
        const coresOrgaos = [
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
        
        // Criar a instância do componente com configuração simplificada
        var DashboardOrgaos = DashboardComponentFactory.criar({
            nome: 'OrgaosProcessos',
            dependencias: [], 
            containerId: 'orgaos-mais-avaliados-container', // Importante: apontando diretamente para o container final
            cardId: 'card-orgaos',
            path: 'includes/pc_dashboard_processo/pc_dashboard_orgaos_processo.cfm',
            titulo: 'Órgãos Avaliados',
            notificationKey: 'orgaosView',
            debug: true
        });
        
        // Tornar acessível globalmente
        window.DashboardOrgaos = DashboardOrgaos;
        
        // Sobrescrever método de atualização com a função específica deste componente
        DashboardOrgaos.atualizar = function(dados) {
            console.log("[OrgaosView] Atualizando componente de órgãos");
            
            try {
                // Mostrar o container diretamente - sem animações complexas
                $("#orgaos-container").show();
                $("#orgaos-content .tab-loader").hide();
                
                // Atualizar o título baseado no ano selecionado
                const anoSelecionado = window.anoSelecionado || "Todos";
                const anoInicial = window.anoInicial || "";
                const anoFinal = window.anoFinal || "";
                
                if (anoSelecionado === "Todos") {
                    if (anoInicial && anoFinal) {
                        $('#orgaos-avaliados-titulo').text(`Top 10 Órgãos Avaliados (${anoInicial} - ${anoFinal})`);
                    } else {
                        $('#orgaos-avaliados-titulo').text("Top 10 Órgãos Avaliados");
                    }
                } else {
                    $('#orgaos-avaliados-titulo').text(`Órgãos Avaliados em ${anoSelecionado}`);
                }
                
                // Se dados não é um objeto ou é null/undefined
                if (!dados || typeof dados !== 'object') {
                    $('#orgaos-mais-avaliados-container').html(`
                        <div class="sem-dados">
                            <i class="fas fa-building"></i>
                            <p>Não há dados de órgãos disponíveis.</p>
                        </div>
                    `);
                    return DashboardOrgaos;
                }

                // Verificação específica para orgaosMaisAvaliados
                var orgaosMaisAvaliados = dados.orgaosMaisAvaliados;
                if (!orgaosMaisAvaliados || !Array.isArray(orgaosMaisAvaliados) || orgaosMaisAvaliados.length === 0) {
                    $('#orgaos-mais-avaliados-container').html(`
                        <div class="sem-dados">
                            <i class="fas fa-building"></i>
                            <p>Não há dados de órgãos avaliados disponíveis para os filtros selecionados.</p>
                        </div>
                    `);
                    return DashboardOrgaos;
                }
                
                // Ordenar os órgãos por quantidade (decrescente)
                const orgaosOrdenados = [...orgaosMaisAvaliados].sort((a, b) => b.quantidade - a.quantidade);
                
                // Verificar se o ano selecionado é "Todos" para aplicar limite
                let orgaosExibidos = orgaosOrdenados;
                if (anoSelecionado === "Todos" && orgaosOrdenados.length > 10) {
                    orgaosExibidos = orgaosOrdenados.slice(0, 10);
                }
                
                // Usar o total geral de processos fornecido pelos dados
                const totalProcessos = dados.totalProcessos || orgaosExibidos.reduce((sum, o) => sum + o.quantidade, 0);
                
                // Encontrar o maior valor entre os órgãos exibidos para cálculo da barra de progresso
                const maxQuantidade = orgaosExibidos.length > 0 ? orgaosExibidos[0].quantidade : 0;
                
                // Construir o HTML para cada órgão
                let html = '';
                
                orgaosExibidos.forEach((orgao, index) => {
                    // Verificar se o órgão tem todas as propriedades necessárias
                    if (!orgao.sigla || !orgao.mcu || orgao.quantidade === undefined) {
                        return; // Skip this item
                    }
                    
                    // Calcular percentual em relação ao total geral de processos
                    const percentual = totalProcessos > 0 ? (orgao.quantidade / totalProcessos) * 100 : 0;
                    
                    // Calcular a largura da barra apenas para visual (em relação ao máximo exibido)
                    const larguraBarra = maxQuantidade > 0 ? (orgao.quantidade / maxQuantidade) * 100 : 0;
                    
                    // Usar cores alternadas para os órgãos
                    const corIndex = index % coresOrgaos.length;
                    const corOrgao = coresOrgaos[corIndex];
                    
                    html += `
                    <div class="orgao-card" style="--animOrder: ${index}">
                        <div class="orgao-posicao" style="background-color: ${corOrgao};">${index + 1}</div>
                        <div class="orgao-info">
                            <div class="orgao-sigla">${orgao.sigla}
                                <span class="orgao-badge">${orgao.mcu}</span>
                            </div>
                            <div class="orgao-metricas">
                                <div class="orgao-quantidade">${orgao.quantidade} <span class="orgao-label">processo(s)</span></div>
                                <div class="orgao-percentual">${percentual.toFixed(1)}% do total</div>
                            </div>
                            <div class="orgao-grafico-barra">
                                <div class="orgao-grafico-progresso" style="width: ${larguraBarra}%; background: linear-gradient(90deg, ${corOrgao}, ${corOrgao}CC);"></div>
                            </div>
                        </div>
                    </div>`;
                });
                
                // Se nenhum órgão válido foi encontrado
                if (html === '') {
                    html = `
                    <div class="sem-dados">
                        <i class="fas fa-building"></i>
                        <p>Não foi possível exibir órgãos com os dados fornecidos.</p>
                    </div>
                    `;
                }
                
                // Atualizar o conteúdo no container diretamente - sem animações
                $('#orgaos-mais-avaliados-container').html(html);
                
                // Notificar que o componente está carregado
                window.componentesCarregados = window.componentesCarregados || {};
                window.componentesCarregados.orgaosView = true;
                
            } catch (error) {
                console.error("[OrgaosView] Erro ao processar dados:", error);
                $('#orgaos-mais-avaliados-container').html(`
                    <div class="sem-dados">
                        <i class="fas fa-exclamation-triangle"></i>
                        <p>Erro ao processar dados: ${error.message}</p>
                    </div>
                `);
            }
            
            return DashboardOrgaos;
        };
        
        // Inicializar e registrar o componente com fluxo simplificado
        DashboardOrgaos.init(function() {
            // Registrar o componente
            DashboardOrgaos.registrar();
            
            // Carregar os dados pendentes ou disponíveis
            if (window.orgaosDadosPendentes) {
                DashboardOrgaos.atualizar(window.orgaosDadosPendentes);
                window.orgaosDadosPendentes = null;
            } 
            else if (window.dadosAtuais) {
                DashboardOrgaos.atualizar(window.dadosAtuais);
            }
            else {
                // Carregar dados via AJAX somente se necessário
                var params = {};
                if (typeof window.anoSelecionado !== 'undefined') params.ano = window.anoSelecionado;
                if (typeof window.mcuSelecionado !== 'undefined') params.mcuOrigem = window.mcuSelecionado;
                
                if (Object.keys(params).length > 0) {
                    DashboardOrgaos.carregarDados(params);
                }
            }
        });
    }
});
</script>
