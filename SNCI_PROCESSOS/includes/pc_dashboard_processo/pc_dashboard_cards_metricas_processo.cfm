<cfparam name="anoSelecionado" default="">
<cfparam name="mcuSelecionado" default="Todos">
<cfparam name="statusSelecionado" default="Todos">

<!-- Carregamento direto do CSS específico do componente -->
<link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Metricas.css">

<!--- Card para Métricas Principais --->
<div class="card mb-4 card-metricas-processo" id="card-metricas-processo">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-tachometer-alt mr-2"></i>Indicadores de Processos
        </h3>
    </div>
    <div class="card-body">
        <!-- Cards de métricas em grid - Preparado para múltiplos cards -->
        <div class="row">
            <!-- Card Total de Processos -->
            <div class="col-md-4 col-lg-3 mb-3">
                <div class="small-box bg-primary card-processos-total">
                    <div class="inner">
                        <h3 id="totalProcessos">0</h3>
                        <p>Total de Processos</p>
                    </div>
                    <div class="icon " >
                        <i class="fas fa-file-alt" style="font-size: 3.5rem;"></i>
                    </div>
                </div>
            </div>
            <!-- Espaço reservado para futuros cards de métricas -->
        </div>
    </div>
</div>

<script>
// Carregar o componente base se ainda não foi carregado
if (typeof DashboardComponentFactory === 'undefined') {
    document.write('<script src="dist/js/snciDashboardComponent.js"><\/script>');
}

// Definir o componente de cards de métricas usando a fábrica
document.addEventListener("DOMContentLoaded", function() {
    // Esperar pelo carregamento da biblioteca de componentes
    var checkComponentLibrary = setInterval(function() {
        if (typeof DashboardComponentFactory !== 'undefined') {
            clearInterval(checkComponentLibrary);
            initCardsMetricasComponent();
        }
    }, 100);

    // Inicializar o componente de cards de métricas
    function initCardsMetricasComponent() {
        // Função para animação dos números
        function animateNumberValue(el, start, end, duration) {
            let startTimestamp = null;
            const step = (timestamp) => {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = Math.min((timestamp - startTimestamp) / duration, 1);
                const currentValue = Math.floor(start + progress * (end - start));
                el.textContent = currentValue;
                
                if (progress < 1) {
                    window.requestAnimationFrame(step);
                }
            };
            window.requestAnimationFrame(step);
        }
        
        // Armazenar valores anteriores para permitir animação
        var previousCardValues = {
            totalProcessos: 0
        };
        
        // Criar a instância do componente com configuração simplificada e URL configurada
        var DashboardMetricas = DashboardComponentFactory.criar({
            nome: 'MetricasProcessos',
            containerId: 'totalProcessos',
            cardId: 'card-metricas-processo',
            path: 'includes/pc_dashboard_processo/pc_dashboard_cards_metricas_processo.cfm',
            titulo: 'Indicadores de Processos',
            dataUrl: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json'
        });
        
        // Disponibilizar função de animação publicamente
        window.animateNumberValue = animateNumberValue;
        
        // Sobrescrever método de atualização
        DashboardMetricas.atualizar = function(dados) {
            if (!dados) return DashboardMetricas;
            
            // Extrair apenas o valor total de processos
            const totalProcessos = parseInt(dados.totalProcessos) || 0;
            
            // Animar valor
            const elTotalProcessos = document.getElementById("totalProcessos");
            if (elTotalProcessos) {
                animateNumberValue(elTotalProcessos, previousCardValues.totalProcessos, totalProcessos, 1000);
                previousCardValues.totalProcessos = totalProcessos;
            }
            
            return DashboardMetricas;
        };
        
        // Inicializar e registrar o componente
        DashboardMetricas.init().registrar();
        
        // Compatibilidade com interface antiga
        window.atualizarCardsProcMet = DashboardMetricas.atualizar;
        
        // Verificar se já existem dados disponíveis
        if (window.dadosAtuais) {
            DashboardMetricas.atualizar(window.dadosAtuais);
        }
    }
});
</script>
