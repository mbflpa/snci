<cfprocessingdirective pageencoding = "utf-8">
<style>
    #tipos-container .tipo-item {
        display: flex;
        margin-bottom: 0.75rem;
        padding: 0.75rem;
        border-radius: 6px;
        border-left: 4px solid #007bff;
        background-color: rgba(0,0,0,0.03);
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    }
    #tipos-container .tipo-item:hover {
        background-color: rgba(0,0,0,0.05);
        transform: translateX(3px);
        box-shadow: 0 2px 5px rgba(0,0,0,0.12);
    }
    #tipos-container .tipo-badge {
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
    #tipos-container .tipo-info {
        flex: 1 1 auto;
        min-width: 0; /* Importante para permitir truncamento */
        overflow: hidden;
    }
    #tipos-container .tipo-descricao {
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
    #tipos-container .tipo-metricas {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.4rem;
        flex-wrap: wrap; /* Permite quebra em telas pequenas */
    }
    #tipos-container .tipo-quantidade {
        font-size: 1rem;
        font-weight: 600;
        color: #111;
        margin-right: 1rem;
    }
    #tipos-container .tipo-percentual {
        font-size: 0.75rem;
        color: #777;
        white-space: nowrap;
    }
    #tipos-container .progress {
        height: 6px;
        margin-bottom: 0.25rem;
        border-radius: 3px;
        background-color: rgba(0,0,0,0.05);
    }
    
    /* Responsividade para diferentes tamanhos de tela */
    @media (max-width: 992px) {
        #tipos-container .tipo-metricas {
            flex-direction: row;
            justify-content: space-between;
        }
    }
    
    @media (max-width: 767px) {
        #tipos-container .tipo-badge {
            width: 30px;
            height: 30px;
            min-width: 30px;
            font-size: 0.9rem;
            margin-right: 0.6rem;
        }
        #tipos-container .tipo-descricao {
            font-size: 0.8rem;
        }
        #tipos-container .tipo-quantidade {
            font-size: 0.9rem;
        }
    }
</style>

<div class="alert alert-info text-center initial-loading">
    <i class="fas fa-spinner fa-spin mr-2"></i> Carregando tipos de processos...
</div>

<script>
$(document).ready(function() {
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
    
    // Função para atualizar a visualização de tipos de processos
    window.atualizarTiposProcessos = function(tiposData, totalProcessos) {
        console.log("atualizarTiposProcessos chamado com dados:", tiposData);
        
        // Atualizar o título dos tipos de processos com base no ano selecionado
        const anoSelecionado = window.anoSelecionado || "Todos";
        const anoInicial = window.anoInicial || "";
        const anoFinal = window.anoFinal || "";
        
        if (anoSelecionado === "Todos") {
            if (anoInicial && anoFinal) {
                $('#tipos-processo-titulo').text(`Top 10 Tipos de Processos ( ${anoInicial} - ${anoFinal} )`);
            } else {
                $('#tipos-processo-titulo').text("Top 10 Tipos de Processos");
            }
        } else {
            $('#tipos-processo-titulo').text("Tipos de Processos de " + anoSelecionado);
        }
        
        if (!tiposData || !tiposData.length) {
            $('#tipos-container').html('<div class="alert alert-warning text-center">Nenhum tipo de processo disponível para os filtros selecionados.</div>');
            return;
        }
        
        // Ordenar por quantidade (decrescente)
        tiposData.sort((a, b) => b.quantidade - a.quantidade);
        
        // Verificar se o ano selecionado é "Todos" para limitar a 10 itens
        let tiposExibidos = tiposData;
        if (anoSelecionado === "Todos") {
            tiposExibidos = tiposData.slice(0, 10); // Limitar aos 10 primeiros apenas quando for "Todos"
        }
        
        let htmlTipos = '';
        
        tiposExibidos.forEach(function(tipo, index) {
            const percentual = totalProcessos > 0 ? ((tipo.quantidade / totalProcessos) * 100).toFixed(1) : 0;
            const corIndex = index % coresTipos.length;
            const corTipo = coresTipos[corIndex];
            
            htmlTipos += `
            <div class="tipo-item">
                <div class="tipo-badge" style="background-color: ${corTipo}; color: white;">
                    ${index + 1}
                </div>
                <div class="tipo-info">
                    <div class="tipo-descricao">${tipo.descricao}</div>
                    <div class="tipo-metricas">
                        <div class="tipo-quantidade">${tipo.quantidade}</div>
                        <div class="tipo-percentual">${percentual}% dos processos</div>
                    </div>
                    <div class="progress">
                        <div class="progress-bar" role="progressbar" style="width: ${percentual}%; background-color: ${corTipo}" 
                            aria-valuenow="${percentual}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>`;
        });
        
        $('#tipos-container').html(htmlTipos);
    };
});
</script>
