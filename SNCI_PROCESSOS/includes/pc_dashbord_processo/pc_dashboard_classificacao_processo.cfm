<cfprocessingdirective pageencoding = "utf-8">
<style>
    #classificacao-container .tipo-item {
        display: flex;
        margin-bottom: 0.75rem;
        padding: 0.75rem;
        border-radius: 6px;
        border-left: 4px solid #6f42c1; /* Diferente cor para diferenciar */
        background-color: rgba(0,0,0,0.03);
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    }
    #classificacao-container .tipo-item:hover {
        background-color: rgba(0,0,0,0.05);
        transform: translateX(3px);
        box-shadow: 0 2px 5px rgba(0,0,0,0.12);
    }
    #classificacao-container .tipo-badge {
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
    }
    #classificacao-container .tipo-info {
        flex: 1 1 auto;
        min-width: 0; /* Importante para permitir truncamento */
        overflow: hidden;
    }
    #classificacao-container .tipo-descricao {
        font-weight: 500;
        font-size: 0.85rem;
        margin-bottom: 0.5rem;
        color: #333;
        line-height: 1.3;
        /* Configuração para quebra de texto adequada */
        white-space: normal;
        word-wrap: break-word;
        overflow-wrap: break-word;
        hyphens: auto;
    }
    #classificacao-container .tipo-metricas {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.4rem;
        flex-wrap: wrap; /* Permite quebra em telas pequenas */
    }
    #classificacao-container .tipo-quantidade {
        font-size: 1rem;
        font-weight: 600;
        color: #111;
        margin-right: 1rem;
    }
    #classificacao-container .tipo-percentual {
        font-size: 0.75rem;
        color: #777;
        white-space: nowrap;
    }
    #classificacao-container .progress {
        height: 6px;
        margin-bottom: 0.25rem;
        border-radius: 3px;
        background-color: rgba(0,0,0,0.05);
    }
    
    /* Responsividade para diferentes tamanhos de tela */
    @media (max-width: 992px) {
        #classificacao-container .tipo-metricas {
            flex-direction: row;
            justify-content: space-between;
        }
    }
    
    @media (max-width: 767px) {
        #classificacao-container .tipo-badge {
            width: 30px;
            height: 30px;
            min-width: 30px;
            font-size: 0.9rem;
            margin-right: 0.6rem;
        }
        #classificacao-container .tipo-descricao {
            font-size: 0.8rem;
        }
        #classificacao-container .tipo-quantidade {
            font-size: 0.9rem;
        }
    }
</style>

<div class="alert alert-info text-center initial-loading">
    <i class="fas fa-spinner fa-spin mr-2"></i> Carregando classificações...
</div>

<script>
$(document).ready(function() {
    // Cores para as diferentes classificações
    const coresTipos = [
        '#6f42c1', // roxo (alterado para iniciar com roxo para classificação)
        '#007bff', // azul
        '#e83e8c', // rosa
        '#fd7e14', // laranja
        '#20c997', // verde-água
        '#17a2b8', // ciano
        '#28a745', // verde
        '#ffc107', // amarelo
        '#dc3545'  // vermelho
    ];
    
    // Função para atualizar a visualização de classificações de processos
    window.atualizarClassificacaoProcessos = function(classificacaoData, totalProcessos) {
        console.log("atualizarClassificacaoProcessos chamado com dados:", classificacaoData);
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
                    <div class="tipo-metricas">
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
    };
});
</script>
