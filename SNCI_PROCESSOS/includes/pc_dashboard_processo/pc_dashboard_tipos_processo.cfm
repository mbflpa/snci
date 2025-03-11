<cfprocessingdirective pageencoding = "utf-8">

<!-- Card para Tipos de Processos -->
<div class="card mb-4" id="card-tipos-processo">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-project-diagram mr-2"></i>Tipos de Processos
        </h3>
    </div>
    <div class="card-body">
        <div class="tipos-processo-container">
            <div id="tipos-processo-content">
                <div class="sem-dados-tipos">
                    <i class="fas fa-spinner fa-spin mr-2"></i> Carregando tipos de processos...
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    .tipos-processo-container {
        width: 100%;
    }
    
    .tipo-processo-item {
        display: flex;
        margin-bottom: 0.75rem;
        padding: 0.75rem;
        border-radius: 6px;
        border-left: 4px solid #007bff;
        background-color: rgba(0,0,0,0.03);
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    }
    
    .tipo-processo-item:hover {
        background-color: rgba(0,0,0,0.05);
        transform: translateX(3px);
        box-shadow: 0 2px 5px rgba(0,0,0,0.12);
    }
    
    .tipo-processo-badge {
        width: 36px;
        height: 36px;
        min-width: 36px;
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
    
    .tipo-processo-info {
        flex: 1 1 auto;
        min-width: 0;
        overflow: hidden;
    }
    
    .tipo-processo-descricao {
        font-weight: 500;
        font-size: 0.85rem;
        margin-bottom: 0.5rem;
        color: #333;
        line-height: 1.3;
        white-space: normal;
        word-wrap: break-word;
        overflow-wrap: break-word;
        hyphens: auto;
    }
    
    .tipo-processo-metricas {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.4rem;
        flex-wrap: wrap;
    }
    
    .tipo-processo-quantidade {
        font-size: 1rem;
        font-weight: 600;
        color: #111;
        margin-right: 1rem;
    }
    
    .tipo-processo-percentual {
        font-size: 0.75rem;
        color: #777;
        white-space: nowrap;
    }
    
    .tipo-processo-grafico-barra {
        height: 6px;
        background: #f1f1f1;
        border-radius: 3px;
        margin-top: 0.25rem;
        overflow: hidden;
    }
    
    .tipo-processo-grafico-progresso {
        height: 100%;
        border-radius: 3px;
        background: linear-gradient(90deg, #007bff, #17a2b8);
    }
    
    .sem-dados-tipos {
        text-align: center;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 6px;
        color: #6c757d;
    }
    
    /* Estilo para o label de processos */
    .tipo-processo-label {
        font-size: 0.7rem;
        color: #888;
        font-weight: normal;
    }
    
    /* Responsividade para telas menores */
    @media (max-width: 768px) {
        .tipo-processo-item {
            padding: 0.6rem;
        }
        
        .tipo-processo-badge {
            width: 30px;
            height: 30px;
            min-width: 30px;
            font-size: 0.9rem;
            margin-right: 0.6rem;
        }
        
        .tipo-processo-descricao {
            font-size: 0.8rem;
        }
        
        .tipo-processo-quantidade {
            font-size: 0.9rem;
        }
    }
</style>

<script>
// Carregar o componente base se ainda não foi carregado
if (typeof DashboardComponentFactory === 'undefined') {
    document.write('<script src="dist/js/snciDashboardComponent.js"><\/script>');
}

// Definir o componente de tipos de processos usando a fábrica
document.addEventListener("DOMContentLoaded", function() {
    // Esperar pelo carregamento da biblioteca de componentes
    var checkComponentLibrary = setInterval(function() {
        if (typeof DashboardComponentFactory !== 'undefined') {
            clearInterval(checkComponentLibrary);
            initTiposProcessoComponent();
        }
    }, 100);

    // Inicializar o componente de tipos de processos
    function initTiposProcessoComponent() {
        // Criar a instância do componente
        var DashboardTipos = DashboardComponentFactory.criar({
            nome: 'TiposProcessos',
            dependencias: [], // Não tem dependências externas
            containerId: 'tipos-processo-content',
            cardId: 'card-tipos-processo',
            path: 'includes/pc_dashboard_processo/pc_dashboard_tipos_processo.cfm',
            titulo: 'Tipos de Processos',
            debug: true
        });
        
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
        
        // Sobrescrever método de atualização com a função específica deste componente
        DashboardTipos.atualizar = function(dados, totalProcessosParam) {
            console.log("[TiposProcessos] Atualizando componente de tipos. Ano selecionado:", 
                window.anoSelecionado || "Não definido");
            
            // Verificar se há dados de tipos disponíveis
            if (!dados || !dados.distribuicaoTipos || dados.distribuicaoTipos.length === 0) {
                $('#tipos-processo-content').html('<div class="sem-dados-tipos">Nenhum tipo de processo disponível para os filtros selecionados.</div>');
                return DashboardTipos;
            }
            
            // Obter os dados de tipos de processo
            let tiposData = dados.distribuicaoTipos || [];
            
            console.log("[TiposProcessos] Total de tipos encontrados:", tiposData.length);
            
            // Ordenar por quantidade (decrescente) como no componente de classificação
            tiposData = [...tiposData].sort((a, b) => b.quantidade - a.quantidade);
            
            // Verificar se o ano selecionado é "Todos" para aplicar limite de 10 itens
            const anoSelecionado = window.anoSelecionado || "Todos";
            
            // Aplicar a limitação a 10 itens quando "Todos" é selecionado
            let tiposExibidos = tiposData;
            if (anoSelecionado === "Todos" && tiposData.length > 10) {
                console.log("[TiposProcessos] Limitando a 10 itens porque o ano selecionado é:", anoSelecionado);
                tiposExibidos = tiposData.slice(0, 10);
            } else {
                console.log("[TiposProcessos] Não limitando porque o ano selecionado é:", anoSelecionado);
            }
            
            // Atualizar título do card para refletir a seleção
            let cardTitle = $('#card-tipos-processo .card-title');
            if (anoSelecionado === "Todos") {
                cardTitle.html('<i class="fas fa-project-diagram mr-2"></i>Top 10 Tipos de Processos');
            } else {
                cardTitle.html('<i class="fas fa-project-diagram mr-2"></i>Tipos de Processos em ' + anoSelecionado);
            }
            
            // Usar o total passado como parâmetro ou extrair dos dados
            const totalProcessos = totalProcessosParam || dados.totalProcessos || 0;
            
            let htmlTipos = '';
            
            tiposExibidos.forEach(function(tipo, index) {
                // Calcular o percentual em relação ao total
                const percentual = totalProcessos > 0 ? ((tipo.quantidade / totalProcessos) * 100).toFixed(1) : 0;
                
                // Usar cores alternadas para os tipos
                const corIndex = index % coresTipos.length;
                const corTipo = coresTipos[corIndex];
                
                // Gerar o HTML para cada tipo de processo
                htmlTipos += `
                <div class="tipo-processo-item">
                    <div class="tipo-processo-badge" style="background-color: ${corTipo}; color: white;">
                        ${index + 1}
                    </div>
                    <div class="tipo-processo-info">
                        <div class="tipo-processo-descricao">${tipo.descricao}</div>
                        <div class="tipo-processo-metricas">
                            <div class="tipo-processo-quantidade">${tipo.quantidade} <span class="tipo-processo-label">processo(s)</span></div>
                            <div class="tipo-processo-percentual">${percentual}% dos processos</div>
                        </div>
                        <div class="tipo-processo-grafico-barra">
                            <div class="tipo-processo-grafico-progresso" style="width: ${percentual}%; background: linear-gradient(90deg, ${corTipo}, ${corTipo}CC);"></div>
                        </div>
                    </div>
                </div>`;
            });
            
            $('#tipos-processo-content').html(htmlTipos);
            
            return DashboardTipos;
        };
        
        // Inicializar e registrar o componente
        DashboardTipos.init().registrar();
        
        // Compatibilidade com interface antiga
        window.atualizarTiposProcesso = function(dados, totalProcessos) {
            if (Array.isArray(dados)) {
                // Formatação antiga - converter para o novo formato
                return DashboardTipos.atualizar({distribuicaoTipos: dados}, totalProcessos);
            } else {
                // Já está no novo formato
                return DashboardTipos.atualizar(dados, totalProcessos);
            }
        };
        
        // Verificar se já existem dados disponíveis no momento da carga do componente
        if (window.dadosAtuais && window.dadosAtuais.distribuicaoTipos) {
            DashboardTipos.atualizar(window.dadosAtuais);
        } else {
            // Carregar dados se necessário
            setTimeout(function() {
                var params = {};
                if (typeof window.anoSelecionado !== 'undefined') params.ano = window.anoSelecionado;
                if (typeof window.mcuSelecionado !== 'undefined') params.mcuOrigem = window.mcuSelecionado;
                
                if (Object.keys(params).length > 0) {
                    DashboardTipos.carregarDados(params);
                }
            }, 1000);
        }
    }
});
</script>