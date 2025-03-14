<cfprocessingdirective pageencoding = "utf-8">
<!-- Carregamento direto do CSS específico do componente -->
<link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Tipos.css">

<!-- Card para Tipos de Processos -->
<div class="card mb-4 dashboard-card-fixed" id="card-tipos-processo">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-project-diagram mr-2"></i>Tipos de Processos
        </h3>
    </div>
    <div class="card-body">
        <div class="tipos-processo-container dashboard-content-scroll">
            <div id="tipos-processo-content">
                <div class="sem-dados-tipos">
                    <i class="fas fa-spinner fa-spin mr-2"></i> Carregando tipos de processos...
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
            dataUrl: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
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
           
            // Verificar se há dados de tipos disponíveis
            if (!dados || !dados.distribuicaoTipos || dados.distribuicaoTipos.length === 0) {
                $('#tipos-processo-content').html('<div class="sem-dados-tipos">Nenhum tipo de processo disponível para os filtros selecionados.</div>');
                return DashboardTipos;
            }
            
            // Obter os dados de tipos de processo
            let tiposData = dados.distribuicaoTipos || [];
            
            
            
            // Ordenar por quantidade (decrescente) como no componente de classificação
            tiposData = [...tiposData].sort((a, b) => b.quantidade - a.quantidade);
            let tiposExibidos = tiposData;
            
                     
            
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
        
        // Adicionar ícone de favorito ao card
        if (typeof initFavoriteIcon === 'function') {
            initFavoriteIcon('card-tipos-processo', 
                            'includes/pc_dashboard_processo/pc_dashboard_tipos_processo.cfm', 
                            'Tipos de Processos');
        }
        
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