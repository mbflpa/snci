<cfprocessingdirective pageencoding = "utf-8">
<style>
    .orgaos-heading {
        font-size: 1.1rem;
        margin-bottom: 1.5rem;
        font-weight: 500;
        color: #333;
        display: flex;
        align-items: center;
    }
    .orgaos-heading i {
        margin-right: 0.5rem;
        color: #007bff;
    }
    .orgao-container {
        width: 100%;
        padding-right: 0;
        overflow: visible; /* Remover rolagem vertical */
        height: auto; /* Altura automática */
        max-height: none; /* Remover limite de altura */
    }
    .orgao-card {
        display: flex;
        align-items: center;
        padding: 0.75rem; /* Reduzir padding para economizar espaço */
        border-radius: 8px;
        margin-bottom: 0.75rem; /* Reduzir espaçamento para caber mais itens */
        background-color: #fff;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        transition: all 0.2s ease;
        width: 100%;       /* Garantir largura completa */
        min-width: 0;      /* Permitir que encolha se necessário */
        box-sizing: border-box;
    }
    .orgao-card:hover {
        transform: translateX(5px);
        box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        border-left: 3px solid #007bff;
    }
    .orgao-posicao {
        font-size: 1.5rem;
        font-weight: 700;
        color: #007bff;
        width: 30px; /* Menor largura */
        text-align: center;
        margin-right: 0.75rem; /* Menor margem */
    }
    .orgao-info {
        flex-grow: 1;
        min-width: 0;      /* Permitir que encolha se necessário */
        overflow: hidden;  /* Ocultar conteúdo que não couber */
    }
    .orgao-sigla {
        font-weight: 600;
        margin-bottom: 0.25rem;
        font-size: 1rem;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .orgao-mcu {
        font-size: 0.8rem;
        color: #6c757d;
    }
    .orgao-quantidade {
        font-size: 1.2rem;
        font-weight: 600;
        color: #28a745;
        margin-left: 1rem;
        white-space: nowrap;
    }
    .orgao-badge {
        display: inline-block;
        font-size: 0.75rem;
        border-radius: 30px;
        padding: 0.25rem 0.75rem;
        margin-left: 0.5rem;
        background-color: rgba(0, 123, 255, 0.1);
        color: #007bff;
    }
    .orgao-grafico-barra {
        height: 6px;
        background: #f1f1f1;
        border-radius: 3px;
        margin-top: 0.25rem;
        overflow: hidden;
    }
    .orgao-grafico-progresso {
        height: 100%;
        background: linear-gradient(90deg, #007bff, #00c6ff);
        border-radius: 3px;
    }
    .sem-dados {
        text-align: center;
        padding: 2rem;
        background-color: #f8f9fa;
        border-radius: 8px;
        color: #6c757d;
        font-size: 1.1rem;
    }
    .sem-dados i {
        font-size: 3rem;
        margin-bottom: 1rem;
        opacity: 0.5;
        display: block;
    }
    /* Estilizar barras para top 3 */
    .orgao-card:nth-child(1) .orgao-grafico-progresso {
        background: linear-gradient(90deg, #fd7e14, #ffc107);
    }
    .orgao-card:nth-child(1) .orgao-posicao {
        color: #fd7e14;
    }
    .orgao-card:nth-child(2) .orgao-grafico-progresso {
        background: linear-gradient(90deg, #6f42c1, #e83e8c);
    }
    .orgao-card:nth-child(2) .orgao-posicao {
        color: #6f42c1;
    }
    .orgao-card:nth-child(3) .orgao-grafico-progresso {
        background: linear-gradient(90deg, #20c997, #17a2b8);
    }
    .orgao-card:nth-child(3) .orgao-posicao {
        color: #20c997;
    }
    /* Responsividade para telas menores */
    @media (max-width: 768px) {
        .orgao-card {
            padding: 0.6rem;
        }
        
        .orgao-posicao {
            font-size: 1.25rem;
            width: 25px;
            margin-right: 0.5rem;
        }
        
        .orgao-sigla {
            font-size: 0.9rem;
        }
        
        .orgao-quantidade {
            font-size: 1rem;
        }
    }
</style>

<!-- Conteúdo dos órgãos mais avaliados -->
<div id="orgaos-mais-avaliados-container" class="orgao-container">
    <!-- Conteúdo será preenchido dinamicamente pelo JavaScript -->
    <div class="alert alert-info">
        <i class="fas fa-spinner fa-spin mr-2"></i> Carregando dados dos órgãos avaliados...
    </div>
</div>

<script>
$(document).ready(function() {
    // Função para atualizar a visualização dos órgãos mais avaliados
    window.atualizarViewOrgaos = function(dados) {
        if (!dados || !dados.orgaosMaisAvaliados || dados.orgaosMaisAvaliados.length === 0) {
            // Se não houver dados, mostrar mensagem
            $('#orgaos-mais-avaliados-container').html(`
                <div class="sem-dados">
                    <i class="fas fa-building"></i>
                    <p>Não há dados de órgãos avaliados disponíveis para os filtros selecionados.</p>
                </div>
            `);
            return;
        }
        
        // Ordenar os órgãos por quantidade (decrescente) e limitar aos top 10
        const orgaosOrdenados = dados.orgaosMaisAvaliados
            .sort((a, b) => b.quantidade - a.quantidade)
            .slice(0, 10);
        
        // Encontrar o maior valor para calcular percentuais
        const maxQuantidade = orgaosOrdenados.length > 0 ? orgaosOrdenados[0].quantidade : 0;
        
        // Construir o HTML para cada órgão
        let html = '';
        
        orgaosOrdenados.forEach((orgao, index) => {
            // Calcular percentual para a barra de progresso
            const percentual = maxQuantidade > 0 ? (orgao.quantidade / maxQuantidade) * 100 : 0;
            
            html += `
            <div class="orgao-card">
                <div class="orgao-posicao">${index + 1}</div>
                <div class="orgao-info">
                    <div class="d-flex align-items-center">
                        <div class="orgao-sigla">${orgao.sigla}</div>
                        <div class="orgao-badge">${orgao.mcu}</div>
                    </div>
                    <div class="orgao-grafico-barra">
                        <div class="orgao-grafico-progresso" style="width: ${percentual}%"></div>
                    </div>
                </div>
                <div class="orgao-quantidade">${orgao.quantidade}</div>
            </div>
            `;
        });
        
        // Atualizar o conteúdo no container
        $('#orgaos-mais-avaliados-container').html(html);
    };
});
</script>
