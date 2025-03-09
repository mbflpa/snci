<cfparam name="anoSelecionado" default="">
<cfparam name="mcuSelecionado" default="Todos">
<cfparam name="statusSelecionado" default="Todos">

<style>
    /* Estilos específicos para os cards de métricas */
    .card-metricas-processo {
        margin-bottom: 1.5rem;
        border-radius: 8px;
    }
    
    .card-metricas-processo .card-body {
        padding: 1.25rem;
    }
    
    /* Estilo para os small-box (cards de métricas) */
    .small-box {
        border-radius: 8px;
        position: relative;
        display: block;
        margin-bottom: 20px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
        overflow: hidden; /* Impede que o ícone saia do card */
    }
    
    .small-box:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 15px rgba(0, 0, 0, 0.15);
    }
    
    .small-box .inner {
        padding: 20px;
        color: white;
    }
    
    .small-box h3 {
        font-size: 2.2rem;
        font-weight: 700;
        margin: 0 0 10px 0;
        white-space: nowrap;
        padding: 0;
        color: white;
    }
    
    .small-box p {
        font-size: 1rem;
        margin-bottom: 0;
        color: white;
    }
    
    
    
    /* Cores específicas por tipo de métrica */
    .bg-primary {
        background-color: #007bff !important;
    }
    
    .bg-warning {
        background-color: #fd7e14 !important;
    }
    
    .bg-success {
        background-color: #28a745 !important;
    }
    
    .bg-danger {
        background-color: #dc3545 !important;
    }
    
    /* Responsividade para diferentes tamanhos de tela */
    @media (max-width: 767px) {
        .small-box {
            text-align: center;
        }
        
        .small-box .icon {
            display: none;
        }
        
        .small-box h3 {
            font-size: 1.8rem;
        }
    }
</style>

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
