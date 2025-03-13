<cfprocessingdirective pageencoding = "utf-8">
<!-- Carregamento direto do CSS específico do componente -->
<link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Classificacao.css">

<!-- Card para Classificação de Processos -->
<div class="card mb-4" id="card-classificacao-processo">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-tags mr-2"></i>Classificação de Processos
        </h3>
    </div>
    <div class="card-body">
        <div class="classificacao-processo-container">
            <!-- Conteúdo gerado dinamicamente via JavaScript -->
        </div>
    </div>
</div>



<script>
// Carregar o componente base se ainda não foi carregado
if (typeof DashboardComponentFactory === 'undefined') {
    document.write('<script src="dist/js/snciDashboardComponent.js"><\/script>');
}

// Definir o componente de classificação de processos usando a fábrica
document.addEventListener("DOMContentLoaded", function() {
    // Esperar pelo carregamento da biblioteca de componentes
    var checkComponentLibrary = setInterval(function() {
        if (typeof DashboardComponentFactory !== 'undefined') {
            clearInterval(checkComponentLibrary);
            initClassificacaoComponent();
        }
    }, 100);

    // Inicializar o componente de classificação de processos
    function initClassificacaoComponent() {
        // Criar a instância do componente
        var DashboardClassificacao = DashboardComponentFactory.criar({
            nome: 'ClassificacaoProcessos',
            dependencias: [],
            containerId: '.classificacao-processo-container',
            cardId: 'card-classificacao-processo',
            path: 'includes/pc_dashboard_processo/pc_dashboard_classificacao_processo.cfm',
            titulo: 'Classificação de Processos',
            dataUrl: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
            debug: true
        });
        
        // Sobrescrever método de atualização com a função específica deste componente
        DashboardClassificacao.atualizar = function(dados, totalProcessosParam) {
            if (!dados || !dados.distribuicaoClassificacao || !dados.distribuicaoClassificacao.length) {
                $('.classificacao-processo-container').html('<div class="sem-dados-classificacao">Nenhuma classificação disponível para os filtros selecionados.</div>');
                return DashboardClassificacao;
            }
            
            const coresClassificacao = [
                '#6f42c1', '#007bff', '#e83e8c', '#fd7e14', '#20c997',
                '#17a2b8', '#28a745', '#ffc107', '#dc3545'
            ];
            
            let classificacaoData = [...dados.distribuicaoClassificacao];
            // Ordenar por quantidade (decrescente)
            classificacaoData = classificacaoData.sort((a, b) => b.quantidade - a.quantidade);
            
            // Verificar se o ano selecionado é "Todos" para aplicar limite
            const anoSelecionado = window.anoSelecionado || "Todos";
            let classificacoesExibidas = classificacaoData;
            if (anoSelecionado === "Todos" && classificacaoData.length > 10) {
                classificacoesExibidas = classificacaoData.slice(0, 10);
            }
            
            const totalProcessos = totalProcessosParam || dados.totalProcessos || 0;
            let htmlClassificacao = '';
            
            classificacoesExibidas.forEach(function(classificacao, index) {
                const percentual = totalProcessos > 0 ? ((classificacao.quantidade / totalProcessos) * 100).toFixed(1) : 0;
                const corIndex = index % coresClassificacao.length;
                const corClassificacao = coresClassificacao[corIndex];
                
                htmlClassificacao += `
                <div class="classificacao-item">
                    <div class="classificacao-badge" style="background-color: ${corClassificacao}; color: white;">${index + 1}</div>
                    <div class="classificacao-info">
                        <div class="classificacao-descricao">${classificacao.descricao}</div>
                        <div class="classificacao-metricas">
                            <div class="classificacao-quantidade">${classificacao.quantidade} <span class="classificacao-label">processo(s)</span></div>
                            <div class="classificacao-percentual">${percentual}% dos processos</div>
                        </div>
                        <div class="classificacao-grafico-barra">
                            <div class="classificacao-grafico-progresso" style="width: ${percentual}%; background: linear-gradient(90deg, ${corClassificacao}, ${corClassificacao}CC);"></div>
                        </div>
                    </div>
                </div>`;
            });
            
            $('.classificacao-processo-container').html(htmlClassificacao);
            return DashboardClassificacao;
        };
        
        // Inicializar e registrar o componente
        DashboardClassificacao.init().registrar();
        
        // Adicionar ícone de favorito ao card
        if (typeof initFavoriteIcon === 'function') {
            initFavoriteIcon('card-classificacao-processo', 
                            'includes/pc_dashboard_processo/pc_dashboard_classificacao_processo.cfm', 
                            'Classificação de Processos');
        }
        
        // Compatibilidade com interface antiga
        window.atualizarClassificacaoProcesso = function(dados, totalProcessos) {
            if (Array.isArray(dados)) {
                // Formatação antiga - converter para o novo formato
                DashboardClassificacao.atualizar({distribuicaoClassificacao: dados}, totalProcessos);
            } else {
                // Já está no novo formato
                DashboardClassificacao.atualizar(dados, totalProcessos);
            }
        };
        
        // Verificar se já existem dados disponíveis
        if (window.dadosAtuais && window.dadosAtuais.distribuicaoClassificacao) {
            DashboardClassificacao.atualizar(window.dadosAtuais);
        }
    }
});
</script>