<cfparam name="anoSelecionado" default="">
<cfparam name="mcuSelecionado" default="Todos">
<cfparam name="statusSelecionado" default="Todos">

<!--- Card para Métricas Principais --->
<div class="card mb-4" id="card-metricas-processo">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-tachometer-alt mr-2"></i>Indicadores de Processos
        </h3>
    </div>
    <div class="card-body">
        <!-- Cards de métricas em grid - Preparado para múltiplos cards -->
        <div class="row">
            <!-- Card Total de Processos com tamanho reduzido -->
            <div class="col-md-4 col-lg-3 mb-3">
                <div class="small-box bg-primary">
                    <div class="inner">
                        <h3 id="totalProcessos">0</h3>
                        <p>Total de Processos</p>
                    </div>
                    <div class="icon">
                        <i class="fas fa-file-alt"></i>
                    </div>
                </div>
            </div>
            <!-- Espaço reservado para futuros cards de métricas -->
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.cardsMetricasProcessoLoaded === 'undefined') {
        window.cardsMetricasProcessoLoaded = true;
        
        // Função para animação dos números
        window.animateNumberValue = function(el, start, end, duration) {
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
        window.previousCardValues = {
            totalProcessos: 0
        };
        
        // Função para atualizar os cards de métricas
        window.atualizarCardsProcMet = function(resultado) {
            if (!resultado) return;
            
            // Extrair apenas o valor total de processos
            const totalProcessos = parseInt(resultado.totalProcessos) || 0;
            
            // Animar valor
            const elTotalProcessos = document.getElementById("totalProcessos");
            window.animateNumberValue(elTotalProcessos, window.previousCardValues.totalProcessos, totalProcessos, 1000);
            window.previousCardValues.totalProcessos = totalProcessos;
        };
    }
});
</script>
