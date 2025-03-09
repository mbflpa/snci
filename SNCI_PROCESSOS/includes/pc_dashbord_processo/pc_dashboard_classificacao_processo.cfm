<cfprocessingdirective pageencoding = "utf-8">

<!-- Card para Classificação de Processos -->
<div class="card mb-4" id="card-classificacao-processo">
    <div class="card-header">
        <h3 class="card-title">
            <i class="fas fa-tag mr-2"></i>Classificação de Processos
        </h3>
    </div>
    <div class="card-body">
        <div class="classificacao-processo-container">
            <div id="classificacao-processo-content">
                <div class="sem-dados-classificacao">
                    <i class="fas fa-spinner fa-spin mr-2"></i> Carregando classificações...
                </div>
            </div>
        </div>
    </div>
</div>

<style>
    .classificacao-processo-container {
        width: 100%;
    }
    
    /* Removido o header redundante já que agora usamos o card header */
    .classificacao-processo-header {
        display: none;
    }
    
    .classificacao-item {
        display: flex;
        margin-bottom: 0.75rem;
        padding: 0.75rem;
        border-radius: 6px;
        border-left: 4px solid #6f42c1; /* Cor diferente da de tipos */
        background-color: rgba(0,0,0,0.03);
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    }
    .classificacao-item:hover {
        background-color: rgba(0,0,0,0.05);
        transform: translateX(3px);
        box-shadow: 0 2px 5px rgba(0,0,0,0.12);
    }
    .classificacao-badge {
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
    .classificacao-info {
        flex: 1 1 auto;
        min-width: 0; /* Importante para permitir truncamento */
        overflow: hidden;
    }
    .classificacao-descricao {
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
    .classificacao-metricas {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.4rem;
        flex-wrap: wrap; /* Permite quebra em telas pequenas */
    }
    .classificacao-quantidade {
        font-size: 1rem;
        font-weight: 600;
        color: #111;
        margin-right: 1rem;
    }
    .classificacao-percentual {
        font-size: 0.75rem;
        color: #777;
        white-space: nowrap;
    }
    .classificacao-progress {
        height: 6px;
        margin-bottom: 0.25rem;
        border-radius: 3px;
        background-color: rgba(0,0,0,0.05);
    }
    
    /* Estilos para quando não há dados */
    .sem-dados-classificacao {
        text-align: center;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 6px;
        color: #6c757d;
    }
    
    /* Responsividade para diferentes tamanhos de tela */
    @media (max-width: 992px) {
        .classificacao-metricas {
            flex-direction: row;
            justify-content: space-between;
        }
    }
    
    @media (max-width: 767px) {
        .classificacao-badge {
            width: 30px;
            height: 30px;
            min-width: 30px;
            font-size: 0.9rem;
            margin-right: 0.6rem;
        }
        .classificacao-descricao {
            font-size: 0.8rem;
        }
        .classificacao-quantidade {
            font-size: 0.9rem;
        }
    }

    /* Estilos específicos para classificação de processos */
    .classificacao-container {
        padding: 1rem;
    }
    
    .classificacao-item {
        padding: 1rem;
        margin-bottom: 1rem;
        border-radius: 8px;
        background-color: #f8f9fa;
        position: relative;
        overflow: hidden;
        transition: all 0.2s ease;
    }
    
    .classificacao-item:hover {
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
        background-color: #fff;
    }
    
    .classificacao-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.75rem;
    }
    
    .classificacao-title {
        font-weight: 600;
        font-size: 1rem;
        color: #495057;
    }
    
    .classificacao-count {
        font-weight: 700;
        font-size: 1.1rem;
        color: #007bff;
    }
    
    .classificacao-progress {
        height: 8px;
        background-color: #e9ecef;
        border-radius: 4px;
        overflow: hidden;
    }
    
    .classificacao-progress-bar {
        height: 100%;
        border-radius: 4px;
        transition: width 0.8s ease;
    }
    
    .classificacao-badge {
        position: absolute;
        top: 0.5rem;
        right: 0.5rem;
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
        font-weight: 600;
        border-radius: 20px;
    }
    
    /* Cores por classificação */
    .classificacao-normal .classificacao-progress-bar {
        background-color: #17a2b8;
    }
    
    .classificacao-urgente .classificacao-progress-bar {
        background-color: #fd7e14;
    }
    
    .classificacao-prioritario .classificacao-progress-bar {
        background-color: #dc3545;
    }
    
    .classificacao-baixa .classificacao-progress-bar {
        background-color: #6c757d;
    }
</style>

<script>
$(document).ready(function() {
    // Verificar se o script já foi carregado para evitar duplicidade
    if (typeof window.classificacaoProcessoLoaded === 'undefined') {
        window.classificacaoProcessoLoaded = true;
        
        // Cores para as diferentes classificações
        const coresClassificacao = [
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
        window.atualizarClassificacaoProcesso = function(classificacaoData, totalProcessos) {
            if (!classificacaoData || !classificacaoData.length) {
                $('#classificacao-processo-content').html('<div class="sem-dados-classificacao">Nenhuma classificação disponível para os filtros selecionados.</div>');
                return;
            }
            
            let htmlClassificacao = '';
            
            classificacaoData.forEach(function(classificacao, index) {
                const percentual = totalProcessos > 0 ? ((classificacao.quantidade / totalProcessos) * 100).toFixed(1) : 0;
                // Usar cores alternadas para as classificações
                const corIndex = index % coresClassificacao.length;
                const corClassificacao = coresClassificacao[corIndex];
                
                htmlClassificacao += `
                <div class="classificacao-item">
                    <div class="classificacao-badge" style="background-color: ${corClassificacao}; color: white;">
                        ${index + 1}
                    </div>
                    <div class="classificacao-info">
                        <div class="classificacao-descricao">${classificacao.descricao}</div>
                        <div class="classificacao-metricas">
                            <div class="classificacao-quantidade">${classificacao.quantidade}</div>
                            <div class="classificacao-percentual">${percentual}% dos processos</div>
                        </div>
                        <div class="progress classificacao-progress">
                            <div class="progress-bar" role="progressbar" style="width: ${percentual}%; background-color: ${corClassificacao}" 
                                aria-valuenow="${percentual}" aria-valuemin="0" aria-valuemax="100"></div>
                        </div>
                    </div>
                </div>`;
            });
            
            $('#classificacao-processo-content').html(htmlClassificacao);
        };

        // Adicionar este código para garantir que o componente seja incluído na atualização de dados
        if (typeof window.atualizarDadosComponentes !== 'function') {
            window.atualizarDadosComponentes = [];
        }
        
        // Registrar este componente para ser atualizado quando os dados forem carregados
        window.atualizarDadosComponentes.push(function(dados) {
            if (dados && dados.distribuicaoClassificacao) {
                window.atualizarClassificacaoProcesso(dados.distribuicaoClassificacao, dados.totalProcessos);
            }
        });
        
        // Verificar se já existem dados disponíveis no momento da carga do componente
        if (window.dadosAtuais && window.dadosAtuais.distribuicaoClassificacao) {
            window.atualizarClassificacaoProcesso(window.dadosAtuais.distribuicaoClassificacao, window.dadosAtuais.totalProcessos);
        }
    }
});
</script>