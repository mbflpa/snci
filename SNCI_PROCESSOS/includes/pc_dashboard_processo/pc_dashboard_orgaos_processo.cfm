<cfprocessingdirective pageencoding = "utf-8">
<!-- Carregamento direto do CSS específico do componente -->
<link rel="stylesheet" href="dist/css/stylesSNCI_ProcessosDashboard_Orgaos.css">

<!--- Card para Órgãos Avaliados --->
<div class="card mb-4" id="card-orgaos">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-building mr-2"></i><span id="orgaos-avaliados-titulo">Órgãos Avaliados</span>
        </h3>
    </div>
    <div class="card-body">
        <div id="orgaos-content">
            <div class="tab-loader">
              <i class="fas fa-spinner fa-spin"></i> Carregando informações dos órgãos...
            </div>
            
            <!--- Conteúdo específico do componente de órgãos --->
            <div id="orgaos-container" style="display: block !important;">
                <div id="orgaos-mais-avaliados-container" class="orgao-container" style="display: block !important; visibility: visible !important;">
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
            dataUrl: 'cfc/pc_cfcProcessosDashboard.cfc?method=getEstatisticasDetalhadas&returnformat=json',
            notificationKey: 'orgaosView',
            debug: true
        });
        
        // Tornar acessível globalmente
        window.DashboardOrgaos = DashboardOrgaos;
        
        // Sobrescrever método de atualização com a função específica deste componente
        DashboardOrgaos.atualizar = function(dados) {
           
            
            try {
                // Mostrar o container explicitamente com !important para garantir visibilidade
                $("#orgaos-container").attr("style", "display: block !important");
                $("#orgaos-mais-avaliados-container").attr("style", "display: block !important; visibility: visible !important");
                $("#orgaos-content .tab-loader").hide();
                
                // Atualizar o título baseado no ano selecionado
                const anoSelecionado = window.anoSelecionado || "Todos";
                const anoInicial = window.anoInicial || "";
                const anoFinal = window.anoFinal || "";
                
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

                // Após renderizar o conteúdo, certificar-se de que está visível
                setTimeout(function() {
                    $("#orgaos-container").attr("style", "display: block !important");
                    $("#orgaos-mais-avaliados-container").attr("style", "display: block !important; visibility: visible !important");
                }, 100);
                
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
            
            // Adicionar ícone de favorito ao card
            if (typeof initFavoriteIcon === 'function') {
                initFavoriteIcon('card-orgaos', 
                                'includes/pc_dashboard_processo/pc_dashboard_orgaos_processo.cfm', 
                                'Órgãos Avaliados');
            }
            
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
        
        // Garantir que o container esteja visível com !important
        $("#orgaos-container").attr("style", "display: block !important");
        $("#orgaos-mais-avaliados-container").attr("style", "display: block !important; visibility: visible !important");
        $("#orgaos-content .tab-loader").hide();
    }
});
</script>
