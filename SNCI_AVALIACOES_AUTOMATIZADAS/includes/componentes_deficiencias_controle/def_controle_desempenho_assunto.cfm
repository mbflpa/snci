<cfprocessingdirective pageencoding="utf-8">

<!--- Verificar se a unidade foi localizada --->
<cfif NOT structKeyExists(application, "rsUsuarioParametros") OR NOT structKeyExists(application.rsUsuarioParametros, "Und_Descricao") OR NOT len(trim(application.rsUsuarioParametros.Und_Descricao))>
    <div class="container snci-desempenho-assunto">
        <div class="desempenho-container">
            <div class="comparison-container">
                <h2>Desempenho por Assunto</h2>
                <div style="text-align: center; padding: 40px 20px; color: #64748b;">
                    <i class="fas fa-building" style="font-size: 3rem; margin-bottom: 16px; opacity: 0.5;"></i>
                    <h3 style="color: #e63946; margin-bottom: 8px;">Unidade Não Localizada</h3>
                    <p style="margin: 0; font-size: 1rem;">Não foi possível identificar a unidade para exibir os dados de desempenho.</p>
                </div>
            </div>
        </div>
    </div>
    <cfabort>
</cfif>

<!--- Usar dados específicos do CFC --->
<!--- Verificar se há filtro de mês na URL --->
<cfparam name="url.mesFiltro" default="">

<cfset objDados = createObject("component", "cfc.DeficienciasControleDados")>
<cfset dadosDesempenho = objDados.obterDadosDesempenhoAssunto(application.rsUsuarioParametros.Und_MCU, url.mesFiltro)>

<cfset dadosMeses = dadosDesempenho.meses>
<cfset nomeMesAtual = dadosMeses.nomeMesAtual>
<cfset nomeMesAnterior = dadosMeses.nomeMesAnterior>
<cfset mesAtualId = dadosMeses.mesAtualId>
<cfset mesAnteriorId = dadosMeses.mesAnteriorId>

<!--- Usar dados já processados do CFC --->
<cfset dados = dadosDesempenho.dadosAssunto>

<!--- Calcular evolução percentual e encontrar o maior valor para escala das barras --->
<cfset maxValor = 0>
<cfloop collection="#dados#" item="chave">
    <cfset registro = dados[chave]>
    <cfset anterior = registro.anterior>
    <cfset atual = registro.atual>
    <cfset delta = atual - anterior>
    <cfset percentual = (anterior GT 0 ? round((delta/anterior)*100) : (atual GT 0 ? 100 : 0))>
    <cfset tipo = (delta GTE 0 ? "increase" : "decrease")>
    <cfset registro.percentual = percentual>
    <cfset registro.tipo = tipo>
    <cfset registro.delta = delta>
    <cfif anterior GT maxValor>
        <cfset maxValor = anterior>
    </cfif>
    <cfif atual GT maxValor>
        <cfset maxValor = atual>
    </cfif>
</cfloop>

<!--- Função de comparação para ordenação --->
<cfscript>
    function compararAtual(a, b) {
        if (a.atual > b.atual) return -1;
        if (a.atual < b.atual) return 1;
        return 0;
    }
    
    function compararAnterior(a, b) {
        if (a.anterior > b.anterior) return -1;
        if (a.anterior < b.anterior) return 1;
        return 0;
    }
</cfscript>

<!--- Classificar dados por prioridade --->
<cfset dadosOrdenados = arrayNew(1)>

<!--- 1. Primeiro: assuntos com maior valor no mês atual --->
<cfset assuntosAtual = arrayNew(1)>
<cfloop collection="#dados#" item="chave">
    <cfset item = dados[chave]>
    <cfif item.atual GT 0>
        <cfset item.chave = chave>
        <cfset arrayAppend(assuntosAtual, item)>
    </cfif>
</cfloop>

<!--- Ordenar por valor atual (maior primeiro) --->
<cfif arrayLen(assuntosAtual) GT 1>
    <cfset arraySort(assuntosAtual, compararAtual)>
</cfif>

<!--- 2. Segundo: assuntos com maior valor no mês anterior (que não estão no atual) --->
<cfset assuntosAnterior = arrayNew(1)>
<cfloop collection="#dados#" item="chave">
    <cfset item = dados[chave]>
    <cfif item.atual EQ 0 AND item.anterior GT 0>
        <cfset item.chave = chave>
        <cfset arrayAppend(assuntosAnterior, item)>
    </cfif>
</cfloop>

<!--- Ordenar por valor anterior (maior primeiro) --->
<cfif arrayLen(assuntosAnterior) GT 1>
    <cfset arraySort(assuntosAnterior, compararAnterior)>
</cfif>

<!--- 3. Terceiro: assuntos com valores zerados --->
<cfset assuntosZerados = arrayNew(1)>
<cfloop collection="#dados#" item="chave">
    <cfset item = dados[chave]>
    <cfif item.atual EQ 0 AND item.anterior EQ 0>
        <cfset item.chave = chave>
        <cfset arrayAppend(assuntosZerados, item)>
    </cfif>
</cfloop>

<!--- Juntar todos os arrays na ordem correta --->
<cfloop from="1" to="#arrayLen(assuntosAtual)#" index="i">
    <cfset arrayAppend(dadosOrdenados, assuntosAtual[i])>
</cfloop>
<cfloop from="1" to="#arrayLen(assuntosAnterior)#" index="i">
    <cfset arrayAppend(dadosOrdenados, assuntosAnterior[i])>
</cfloop>
<cfloop from="1" to="#arrayLen(assuntosZerados)#" index="i">
    <cfset arrayAppend(dadosOrdenados, assuntosZerados[i])>
</cfloop>

<style>
    .snci-desempenho-assunto {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        width: 100%;
        margin: 0;
        padding: 0;
    }

    .snci-desempenho-assunto .desempenho-container {
        background: #fff;
        padding: 24px;
        width: 100%;
        box-sizing: border-box;
    }

    .snci-desempenho-assunto .container-header {
        border-radius: 8px 8px 0 0;
        padding-top: 20px;
        padding-left: 0;
        padding-right: 0;
    }

    .snci-desempenho-assunto .container-header h2 {
        font-size: 1.25rem;
        font-weight: 600;
        margin-bottom: 16px;
        color: #1e293b;
        padding-bottom: 6px;
        position: relative;
        text-align: left;
    }

    .snci-desempenho-assunto .container-header h2::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 2px;
        background: linear-gradient(90deg, #457b9d, #a8dadc);
        border-radius: 1px;
    }

    .snci-desempenho-assunto .subtitle {
        font-size: 0.9rem;
        color: #64748b;
        margin: 8px 0 0 0;
        font-weight: 500;
        text-align: left;
    }

    /* Carrossel */
    .snci-desempenho-assunto .carousel-container {
        position: relative;
        overflow: hidden;
        padding: 0 60px;
        width: 100%;
        padding-top: 10px;
    }

    .snci-desempenho-assunto .carousel-track {
        display: flex;
        transition: transform 0.5s ease-in-out;
        gap: 24px;
        width: 100%;
    }

    .snci-desempenho-assunto .carousel-controls {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        background: #fff;
        border: 2px solid #e2e8f0;
        border-radius: 50%;
        width: 45px;
        height: 45px;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        z-index: 10;
        transition: all 0.3s ease;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .snci-desempenho-assunto .carousel-controls:hover {
        background: #f8fafc;
        border-color: #457b9d;
        transform: translateY(-50%) scale(1.1);
        box-shadow: 0 6px 20px rgba(0,0,0,0.2);
    }

    .snci-desempenho-assunto .carousel-controls.disabled {
        opacity: 0.3;
        cursor: not-allowed;
        pointer-events: none;
    }

    .snci-desempenho-assunto .carousel-prev {
        left: 10px;
    }

    .snci-desempenho-assunto .carousel-next {
        right: 10px;
    }

    .snci-desempenho-assunto .carousel-controls i {
        color: #457b9d;
        font-size: 18px;
    }

    /* Cards */
    .snci-desempenho-assunto .performance-card {
        flex: 0 0 250px;
        background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
        border-radius: 16px;
        padding: 10px;
        padding-top:0;
        border: 1px solid #e2e8f0;
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
        min-height: 280px;
    }

    .snci-desempenho-assunto .performance-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #457b9d, #a8dadc);
    }

    .snci-desempenho-assunto .performance-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        border-color: #cbd5e1;
    }


    .snci-desempenho-assunto .card-title {
        font-size: 0.6rem;
        font-weight: 700;
        color: #1e293b;
        margin-bottom: 6px;
        line-height: 1.2;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        text-align: center;
        display: block;
        width: 100%;
        background: linear-gradient(135deg, #457b9d, #1e3d59);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        text-shadow: 0 1px 2px rgba(0,0,0,0.1);
    }

    .snci-desempenho-assunto .card-subtitle {
        font-size: 0.7rem;
        color: #64748b;
        margin: 0;
        font-weight: 500;
        text-align: center;
        display: block;
        width: 100%;
    }

    .snci-desempenho-assunto .card-metrics {
        margin-bottom: 20px;
    }

    .snci-desempenho-assunto .metric-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
        padding: 8px 12px;
        background: rgba(255,255,255,0.6);
        border-radius: 8px;
    }

    .snci-desempenho-assunto .metric-row:last-child {
        margin-bottom: 0;
    }

    .snci-desempenho-assunto .metric-label {
        font-size: 0.85rem;
        color: #475569;
        font-weight: 500;
    }

    .snci-desempenho-assunto .metric-value {
        font-size: 1.1rem;
        font-weight: 600;
        color: #1e293b;
    }

    /* Barras de progresso */
    .snci-desempenho-assunto .progress-section {
        margin-bottom: 20px;
    }

    .snci-desempenho-assunto .progress-bar-container {
        margin-bottom: 12px;
    }

    .snci-desempenho-assunto .progress-label {
        display: flex;
        justify-content: space-between;
        font-size: 0.75rem;
        color: #64748b;
        margin-bottom: 4px;
    }

    .snci-desempenho-assunto .progress-bar-wrapper {
        background-color: #f1f5f9;
        border-radius: 6px;
        height: 8px;
        position: relative;
        overflow: hidden;
    }

    .snci-desempenho-assunto .progress-bar {
        height: 100%;
        border-radius: 6px;
        transition: width 1.5s ease-in-out;
        position: absolute;
        top: 0;
        left: 0;
    }

    .snci-desempenho-assunto .progress-bar.anterior {
        background: linear-gradient(90deg, #a8dadc, #7fb3d3);
    }

    .snci-desempenho-assunto .progress-bar.atual {
        background: linear-gradient(90deg, #457b9d, #1e3d59);
    }

    /* Indicador de mudança */
    .snci-desempenho-assunto .change-indicator {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 12px;
        border-radius: 12px;
        background: rgba(255,255,255,0.8);
        border: 2px solid #e2e8f0;
    }

    .snci-desempenho-assunto .change-value {
        font-size: 1.2rem;
        font-weight: 700;
        margin-right: 8px;
    }

    .snci-desempenho-assunto .change-details {
        text-align: center;
    }

    .snci-desempenho-assunto .change-percentage {
        font-size: 0.9rem;
        font-weight: 600;
        margin-bottom: 2px;
    }

    .snci-desempenho-assunto .change-label {
        font-size: 0.75rem;
        opacity: 0.8;
    }

    .snci-desempenho-assunto .increase {
        color: #dc2626;
    }

    .snci-desempenho-assunto .increase .change-indicator {
        border-color: #fecaca;
        background: rgba(254, 202, 202, 0.2);
    }

    .snci-desempenho-assunto .decrease {
        color: #059669;
    }

    .snci-desempenho-assunto .decrease .change-indicator {
        border-color: #a7f3d0;
        background: rgba(167, 243, 208, 0.2);
    }

    /* Indicadores de navegação */
    .snci-desempenho-assunto .carousel-indicators {
        display: flex;
        justify-content: center;
        margin-top: 20px;
        gap: 8px;
    }

    .snci-desempenho-assunto .indicator-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: #cbd5e1;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .snci-desempenho-assunto .indicator-dot.active {
        background: #457b9d;
        transform: scale(1.2);
    }

    /* Responsividade */
    @media (max-width: 1400px) {
        .snci-desempenho-assunto .performance-card {
            flex: 0 0 300px;
        }
    }

    @media (max-width: 1200px) {
        .snci-desempenho-assunto .performance-card {
            flex: 0 0 280px;
        }
        
        .snci-desempenho-assunto .carousel-container {
            padding: 0 50px;
        }
    }

    @media (max-width: 992px) {
        .snci-desempenho-assunto .performance-card {
            flex: 0 0 260px;
        }
        
        .snci-desempenho-assunto .desempenho-container {
            padding: 20px;
        }
    }

    @media (max-width: 768px) {
        .snci-desempenho-assunto .carousel-container {
            padding: 0 40px;
        }

        .snci-desempenho-assunto .performance-card {
            flex: 0 0 250px;
            padding: 16px;
        }

        .snci-desempenho-assunto .carousel-controls {
            width: 35px;
            height: 35px;
        }

        .snci-desempenho-assunto .carousel-prev {
            left: 2px;
        }

        .snci-desempenho-assunto .carousel-next {
            right: 2px;
        }

        .snci-desempenho-assunto .desempenho-container {
            padding: 16px;
        }
    }

    @media (max-width: 480px) {
        .snci-desempenho-assunto .carousel-container {
            padding: 0 30px;
        }

        .snci-desempenho-assunto .performance-card {
            flex: 0 0 220px;
            padding: 14px;
        }

        .snci-desempenho-assunto .container-header h2 {
            font-size: 1.25rem;
        }

        .snci-desempenho-assunto .desempenho-container {
            padding: 12px;
        }
    }
</style>

<div class="snci-desempenho-assunto">
    <div class="desempenho-container">
        <div class="container-header">
            <h2>Desempenho por Assunto <span class="subtitle"><cfoutput>(#nomeMesAtual# x #nomeMesAnterior#)</cfoutput></span></h2>
            
        </div>

        <div class="carousel-container">
            <div class="carousel-controls carousel-prev">
                <i class="fas fa-chevron-left"></i>
            </div>
            
            <div class="carousel-track" id="carouselTrack">
                <cfloop array="#dadosOrdenados#" index="item">
                    <div class="performance-card">
                        <div class="card-header">
                            <h3 class="card-title"><cfoutput>#trim(item.titulo)#</cfoutput></h3>
                            <p class="card-subtitle"><cfoutput>(#item.teste#)</cfoutput></p>
                        </div>

                        <div class="progress-section">

                            <div class="progress-bar-container">
                                <div class="progress-label">
                                    <span><cfoutput>#nomeMesAtual#</cfoutput></span>
                                    <span><cfoutput>#item.atual#</cfoutput></span>
                                </div>
                                <div class="progress-bar-wrapper">
                                    <div class="progress-bar atual animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.atual/maxValor*100) : 0)#%</cfoutput>"></div>
                                </div>
                            </div>

                            <div class="progress-bar-container">
                                <div class="progress-label">
                                    <span><cfoutput>#nomeMesAnterior#</cfoutput></span>
                                    <span><cfoutput>#item.anterior#</cfoutput></span>
                                </div>
                                <div class="progress-bar-wrapper">
                                    <div class="progress-bar anterior animated-bar" style="width:0%;" data-width="<cfoutput>#(maxValor GT 0 ? round(item.anterior/maxValor*100) : 0)#%</cfoutput>"></div>
                                </div>
                            </div>

                        </div>

                        <div class="change-indicator <cfoutput>#item.tipo#</cfoutput>">
                            <span class="change-value">
                                <cfif item.tipo eq "increase">↗<cfelse>↘</cfif>
                                <cfoutput>#abs(item.delta)#</cfoutput>
                            </span>
                            <div class="change-details">
                                <div class="change-percentage">
                                    <cfif item.anterior GT 0>
                                        <cfoutput>#abs(item.percentual)#%</cfoutput>
                                    <cfelse>
                                        <cfoutput>#(item.atual GT 0 ? 100 : 0)#%</cfoutput>
                                    </cfif>
                                </div>
                                <div class="change-label">
                                    <cfif item.tipo eq "increase">aumento<cfelse>redução</cfif>
                                </div>
                            </div>
                        </div>
                    </div>
                </cfloop>
            </div>

            <div class="carousel-controls carousel-next">
                <i class="fas fa-chevron-right"></i>
            </div>
        </div>

        <div class="carousel-indicators" id="carouselIndicators">
            <!-- Indicadores serão gerados pelo JavaScript -->
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        // Animar barras de progresso
        $('.animated-bar').each(function(){
            var width = $(this).data('width');
            $(this).css('width', width);
        });

        // Configuração do carrossel
        const track = $('#carouselTrack');
        const cards = track.find('.performance-card');
        const prevBtn = $('.carousel-prev');
        const nextBtn = $('.carousel-next');
        const indicators = $('#carouselIndicators');
        
        let currentIndex = 0;
        let cardsPerView = getCardsPerView();
        let totalSlides = Math.ceil(cards.length / cardsPerView);

        function getCardsPerView() {
            const containerWidth = $('.carousel-container').width() - 120; // Subtraindo padding dos controles
            const cardWidth = $('.performance-card').outerWidth(true) || 344; // Card width + gap
            return Math.floor(containerWidth / cardWidth) || 1;
        }

        function updateCarousel() {
            const cardWidth = 280 + 20; // Card width + gap
            const translateX = -currentIndex * cardsPerView * cardWidth;
            track.css('transform', `translateX(${translateX}px)`);
            
            // Atualizar controles
            prevBtn.toggleClass('disabled', currentIndex === 0);
            nextBtn.toggleClass('disabled', currentIndex >= totalSlides - 1);
            
            // Atualizar indicadores
            indicators.find('.indicator-dot').removeClass('active').eq(currentIndex).addClass('active');
        }

        function createIndicators() {
            indicators.empty();
            for (let i = 0; i < totalSlides; i++) {
                const dot = $('<div class="indicator-dot"></div>');
                if (i === 0) dot.addClass('active');
                dot.click(function() {
                    currentIndex = i;
                    updateCarousel();
                });
                indicators.append(dot);
            }
        }

        function handleResize() {
            const newCardsPerView = getCardsPerView();
            if (newCardsPerView !== cardsPerView) {
                cardsPerView = newCardsPerView;
                totalSlides = Math.ceil(cards.length / cardsPerView);
                currentIndex = Math.min(currentIndex, totalSlides - 1);
                createIndicators();
                updateCarousel();
            }
        }

        // Eventos dos controles
        nextBtn.click(function() {
            if (currentIndex < totalSlides - 1) {
                currentIndex++;
                updateCarousel();
            }
        });

        prevBtn.click(function() {
            if (currentIndex > 0) {
                currentIndex--;
                updateCarousel();
            }
        });

        // Suporte a touch/swipe para mobile
        let startX = 0;
        let isDragging = false;

        track.on('touchstart mousedown', function(e) {
            startX = e.type === 'touchstart' ? e.originalEvent.touches[0].clientX : e.clientX;
            isDragging = true;
            track.css('transition', 'none');
        });

        $(document).on('touchmove mousemove', function(e) {
            if (!isDragging) return;
            e.preventDefault();
            
            const currentX = e.type === 'touchmove' ? e.originalEvent.touches[0].clientX : e.clientX;
            const diff = startX - currentX;
            
            if (Math.abs(diff) > 50) {
                if (diff > 0 && currentIndex < totalSlides - 1) {
                    currentIndex++;
                } else if (diff < 0 && currentIndex > 0) {
                    currentIndex--;
                }
                isDragging = false;
                track.css('transition', 'transform 0.5s ease-in-out');
                updateCarousel();
            }
        });

        $(document).on('touchend mouseup', function() {
            if (isDragging) {
                isDragging = false;
                track.css('transition', 'transform 0.5s ease-in-out');
            }
        });

        // Navegação por teclado
        $(document).keydown(function(e) {
            if (e.keyCode === 37) { // Seta esquerda
                prevBtn.click();
            } else if (e.keyCode === 39) { // Seta direita
                nextBtn.click();
            }
        });

        // // Auto-play (opcional)
        // let autoplayInterval;
        // function startAutoplay() {
        //     autoplayInterval = setInterval(function() {
        //         if (currentIndex < totalSlides - 1) {
        //             currentIndex++;
        //         } else {
        //             currentIndex = 0;
        //         }
        //         updateCarousel();
        //     }, 5000);
        // }

        // function stopAutoplay() {
        //     clearInterval(autoplayInterval);
        // }

        // Pausar autoplay ao passar o mouse
        //$('.snci-desempenho-assunto').hover(stopAutoplay, startAutoplay);

        // Inicialização
        createIndicators();
        updateCarousel();
       // startAutoplay();

        // Redimensionamento da tela
        $(window).resize(handleResize);
    });
</script>