<cfprocessingdirective pageencoding = "utf-8">

<!-- Card para Tipos de Processos -->
<div class="card mb-4" id="card-tipos-processo">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-clipboard-list mr-2"></i><span class="tipos-processo-titulo">Top 10 Tipos de Processos</span>
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
    
    /* Removido o header redundante já que agora usamos o card header */
    .tipos-processo-header {
        display: none;
    }
    
    .tipo-item {
        display: flex;
        align-items: center;
        margin-bottom: 0.75rem;
        padding: 0.75rem;
        border-radius: 6px;
        border-left: 4px solid #007bff;
        background-color: rgba(0,0,0,0.03);
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    }
    .tipo-item:hover {
        background-color: rgba(0,0,0,0.05);
        transform: translateX(3px);
        box-shadow: 0 2px 5px rgba(0,0,0,0.12);
    }
    .tipo-badge {
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
    .tipo-info {
        flex: 1 1 auto;
        min-width: 0; /* Importante para permitir truncamento */
        overflow: hidden;
    }
    .tipo-descricao {
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
    .tipo-metricas {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.4rem;
        flex-wrap: wrap; /* Permite quebra em telas pequenas */
    }
    .tipo-quantidade {
        font-size: 1rem;
        font-weight: 600;
        color: #111;
        margin-right: 1rem;
    }
    .tipo-percentual {
        font-size: 0.75rem;
        color: #777;
        white-space: nowrap;
    }
    .progress {
        display: none;
    }
    .tipo-grafico-barra {
        height: 6px;
        background: #f1f1f1;
        border-radius: 3px;
        margin-top: 0.25rem;
        overflow: hidden;
    }
    
    .tipo-grafico-progresso {
        height: 100%;
        border-radius: 3px;
        background: linear-gradient(90deg, #007bff, #00c6ff);
    }
    
    /* Estilizar cores para top 3 tipos */
    .tipo-item:nth-child(1) .tipo-grafico-progresso {
        background: linear-gradient(90deg, #fd7e14, #ffc107);
    }
    
    .tipo-item:nth-child(2) .tipo-grafico-progresso {
        background: linear-gradient(90deg, #6f42c1, #e83e8c);
    }
    
    .tipo-item:nth-child(3) .tipo-grafico-progresso {
        background: linear-gradient(90deg, #20c997, #17a2b8);
    }
    
    /* Estilos para quando não há dados */
    .sem-dados-tipos {
        text-align: center;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 6px;
        color: #6c757d;
    }
    
    /* Responsividade para diferentes tamanhos de tela */
    @media (max-width: 992px) {
        .tipo-metricas {
            flex-direction: row;
            justify-content: space-between;
        }
    }
    
    @media (max-width: 767px) {
        .tipo-badge {
            width: 30px;
            height: 30px;
            min-width: 30px;
            font-size: 0.9rem;
            margin-right: 0.6rem;
        }
        .tipo-descricao {
            font-size: 0.8rem;
        }
        .tipo-quantidade {
            font-size: 0.9rem;
        }
    }

       
    .tipo-processo-item {
        display: flex;
        align-items: center;
        margin-bottom: 1rem;
        padding: 0.75rem;
        border-radius: 8px;
        transition: all 0.2s ease;
        background-color: #f8f9fa;
    }
    
    .tipo-processo-item:hover {
        background-color: #f1f3f5;
        transform: translateX(5px);
    }
    
    .tipo-processo-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 1rem;
        color: white;
        font-size: 1.2rem;
    }
    
    .tipo-processo-info {
        flex-grow: 1;
    }
    
    .tipo-processo-title {
        font-weight: 600;
        font-size: 0.95rem;
        margin-bottom: 0.25rem;
    }
    
    .tipo-processo-count {
        font-size: 0.85rem;
        color: #6c757d;
    }
    
    .tipo-processo-percent {
        font-weight: 700;
        font-size: 1.1rem;
        margin-left: 1rem;
    }
    
    /* Cores para diferentes tipos de processo */
    .tipo-inspeção .tipo-processo-icon {
        background-color: #007bff;
    }
    
    .tipo-auditoria .tipo-processo-icon {
        background-color: #fd7e14;
    }
    
    .tipo-sindicância .tipo-processo-icon {
        background-color: #dc3545;
    }
    
    .tipo-acompanhamento .tipo-processo-icon {
        background-color: #28a745;
    }
</style>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.tiposProcessoLoaded === 'undefined') {
        window.tiposProcessoLoaded = true;
        
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
        
        // Função para atualizar o título com base no ano selecionado
        function atualizarTituloTiposProcesso() {
            const anoSelecionado = window.anoSelecionado || "Todos";
            const anoInicial = window.anoInicial || "";
            const anoFinal = window.anoFinal || "";
            
            let novoTitulo = "Top 10 Tipos de Processos";
            
            if (anoSelecionado === "Todos") {
                if (anoInicial && anoFinal) {
                    novoTitulo = `Top 10 Tipos de Processos ( ${anoInicial} - ${anoFinal} )`;
                }
            } else {
                novoTitulo = `Tipos de Processos de ${anoSelecionado}`;
            }
            
            $('.tipos-processo-titulo').text(novoTitulo);
        }
        
        // Função para atualizar a visualização de tipos de processos
        window.atualizarTiposProcesso = function(tiposData, totalProcessos) {
            // Atualizar o título dos tipos de processos com base no ano selecionado
            atualizarTituloTiposProcesso();
            
            if (!tiposData || !tiposData.length) {
                $('#tipos-processo-content').html('<div class="sem-dados-tipos">Nenhum tipo de processo disponível para os filtros selecionados.</div>');
                return;
            }
            
            // Ordenar por quantidade (decrescente)
            tiposData.sort((a, b) => b.quantidade - a.quantidade);
            
            // Verificar se o ano selecionado é "Todos" para limitar a 10 itens
            const anoSelecionado = window.anoSelecionado || "Todos";
            let tiposExibidos = tiposData;
            if (anoSelecionado === "Todos") {
                tiposExibidos = tiposData.slice(0, 10); // Limitar aos 10 primeiros apenas quando for "Todos"
            }
            
            let htmlTipos = '';
            
            // Calcular total real somando as quantidades de todos os tipos
            const totalReal = tiposData.reduce((sum, tipo) => {
                // Converter para número e somar
                const quantidade = parseInt(tipo.quantidade.toString().replace(/[^0-9]/g, ''), 10) || 0;
                return sum + quantidade;
            }, 0);
            
            tiposExibidos.forEach(function(tipo, index) {
                // Garantir que a quantidade seja um número
                const quantidadeTipo = parseInt(tipo.quantidade.toString().replace(/[^0-9]/g, ''), 10) || 0;
                
                // Calcular o percentual usando o total real
                const percentual = totalReal > 0 ? ((quantidadeTipo / totalReal) * 100).toFixed(1) : 0;
                
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
                            <div class="tipo-quantidade">${quantidadeTipo}</div>
                            <div class="tipo-percentual">${percentual}% dos processos</div>
                        </div>
                        <div class="tipo-grafico-barra">
                            <div class="tipo-grafico-progresso" style="width: ${percentual}%; background: linear-gradient(90deg, ${corTipo}, ${corTipo}CC);"></div>
                        </div>
                    </div>
                </div>`;
            });
            
            $('#tipos-processo-content').html(htmlTipos);
        };
        
        // Registrar um listener para mudanças no ano selecionado
        $(document).on('change', 'input[name="opcaoAno"]', function() {
            setTimeout(atualizarTituloTiposProcesso, 100);
        });

        // Adicionar este código para garantir que o componente seja incluído na atualização de dados
        if (typeof window.atualizarDadosComponentes !== 'function') {
            window.atualizarDadosComponentes = [];
        }
        
        // Registrar este componente para ser atualizado quando os dados forem carregados
        window.atualizarDadosComponentes.push(function(dados) {
            if (dados && dados.distribuicaoTipos) {
                window.atualizarTiposProcesso(dados.distribuicaoTipos, dados.totalProcessos);
            }
        });
        
        // Verificar se já existem dados disponíveis no momento da carga do componente
        if (window.dadosAtuais && window.dadosAtuais.distribuicaoTipos) {
            window.atualizarTiposProcesso(window.dadosAtuais.distribuicaoTipos, window.dadosAtuais.totalProcessos);
        }
    }
});
</script>