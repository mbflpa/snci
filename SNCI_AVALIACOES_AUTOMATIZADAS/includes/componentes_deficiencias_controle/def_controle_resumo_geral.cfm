<cfprocessingdirective pageencoding="utf-8">


<!--- Adicionar cfparam para url.mesFiltro ANTES de usar a variável --->
<cfparam name="url.mesFiltro" default="">

<!--- Verificar se a unidade foi localizada --->
<cfif NOT structKeyExists(application, "rsUsuarioParametros") OR NOT structKeyExists(application.rsUsuarioParametros, "Und_Descricao") OR NOT len(trim(application.rsUsuarioParametros.Und_Descricao))>
    <div class="snci-resumo-geral">
        <div class="desempenho-container">
            <div class="comparison-container">
                <h2>Resumo Geral</h2>
                <div style="text-align: center; padding: 40px 20px; color: #64748b;">
                    <i class="fas fa-building" style="font-size: 3rem; margin-bottom: 16px; opacity: 0.5;"></i>
                    <h3 style="color: #e63946; margin-bottom: 8px;">Unidade Não Localizada</h3>
                    <p style="margin: 0; font-size: 1rem;">Não foi possível identificar a unidade para exibir os dados.</p>
                </div>
            </div>
        </div>
    </div>
    <cfabort>
</cfif>

<cfset anoAtual = dateFormat(now(), "yyyy")>

<!--- Definir título baseado no filtro --->
<cfif len(trim(url.mesFiltro))>
    <cfset tituloDefault = "Resumo Geral até " & monthAsString(listLast(url.mesFiltro, "-")) & "/" & listFirst(url.mesFiltro, "-")>
<cfelse>
    <cfset tituloDefault = "Resumo Geral de " & anoAtual>
</cfif>

<cfparam name="attributes.tituloResumo" default="#tituloDefault#">
<cfparam name="attributes.cssClass" default="">
<cfparam name="attributes.showAnimation" default="true">
<cfparam name="attributes.dados" default="#structNew()#">

<!--- Usar dados do CFC se não foram fornecidos dados personalizados --->
<cfif structIsEmpty(attributes.dados)>
    <!--- url.mesFiltro já definido acima --->
    
    <cfset objDados = createObject("component", "cfc.DeficienciasControleDados")>
    <cfset dadosResumo = objDados.obterDadosResumoGeral(application.rsUsuarioParametros.Und_MCU, url.mesFiltro)>
    <cfset dadosHistoricos = dadosResumo.dadosHistoricos>
    
    <cfset attributes.dados = {
        testesEnvolvidos = {
            valor = dadosHistoricos.testesEnvolvidos,
            icone = "fas fa-list-ul",
            titulo = "Testes Envolvidos",
            cor = "",
            definicao = "Conjunto de testes definidos para avaliarem a efetividade operacional dos controles, ou seja, se os controles realmente impedem ou revelam a ocorrência de falhas nas atividades controladas e se eles estão funcionando da forma estabelecida;",
            ordem= 1
        },
        testesAplicados = {
            valor = dadosHistoricos.testesAplicados,
            icone = "fas fa-tasks",
            titulo = "Testes Aplicados",
            cor = "",
            definicao = "Conjunto de testes que foram efetivamente aplicados para verificar a conformidade dos controles.",
            ordem= 2
        },
        conformes = {
            valor = dadosHistoricos.conformes,
            icone = "fas fa-check-circle",
            titulo = "Conformes",
            cor = "decrease",
            definicao = "Conjunto de testes que foram considerados conformes, ou seja, que atenderam aos critérios estabelecidos.",
            ordem= 3
        },
        deficienciasControle = {
            valor = dadosHistoricos.deficienciasControle,
            icone = "fas fa-exclamation-triangle",
            titulo = "Deficiência do Controle",
            cor = "increase",
            definicao = "Conjunto de testes que foram considerados não conformes, ou seja, que não atenderam aos critérios estabelecidos.",
            ordem= 4
        },
        totalEventos = {
            valor = dadosHistoricos.totalEventos,
            icone = "fas fa-chart-bar",
            titulo = "Total de Eventos",
            cor = "",
            definicao = "Total de eventos registrados durante o período.",
            ordem= 5
        },
        reincidencia= {
            valor = dadosHistoricos.reincidencia,
            icone = "fas fa-redo",
            titulo = "Reincidência",
            cor = "",
            definicao = "Número de eventos que se repetiram durante o período.",
            ordem= 6
        },
        valorEnvolvido = {
            valor = dadosHistoricos.valorEnvolvido,
            icone = "fas fa-dollar-sign",
            titulo = "Valor Envolvido",
            cor = "",
            formatacao = "moeda",
            definicao = "Valor financeiro total envolvido nos eventos registrados.",
            ordem= 7
        }
    }>
</cfif>

<style>
    /* Container principal harmonizado com desempenho_assunto */
    .snci-resumo-geral {
        margin-bottom: 20px;
    }
    .snci-resumo-geral .desempenho-container {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .snci-resumo-geral .comparison-container {
        background: #fff;
        padding: 12px 16px;
        border-radius: 12px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        border: 1px solid #e2e8f0;
    }

    .snci-resumo-geral .comparison-container h2 {
        font-size: 1.25rem;
        font-weight: 600;
        margin-bottom: 16px;
        color: #1e293b;
        padding-bottom: 6px;
        position: relative;
        text-align: left;
    }
    .snci-resumo-geral .comparison-container h2::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 2px;
        background: linear-gradient(90deg, #457b9d, #a8dadc);
        border-radius: 1px;
    }

    /* Cards alinhados horizontalmente */
    .snci-resumo-geral .kpi-row {
        display: flex;
        flex-direction: row;

        justify-content: center;
        align-items: stretch;
        flex-wrap: wrap;
    }

    .snci-resumo-geral .kpi-card {
        background: #fff;
        padding: 12px 16px;
        border-radius: 12px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        display: flex;
        align-items: center;
        gap: 10px;
        text-align: left;
        transition: all 0.3s ease;
        border: 1px solid #e2e8f0;
        min-width: 180px;
        flex: 1 1 180px;
        max-width: 250px;
    }

    .snci-resumo-geral .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 16px rgba(0,0,0,0.08);
    }

    .snci-resumo-geral .kpi-card .icon {
        font-size: 1.5rem;
        color: var(--primary-color, #003366);
        background-color: rgba(0, 51, 102, 0.08);
        height: 44px;
        width: 44px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    .snci-resumo-geral .kpi-card .icon.increase {
        color: #e63946;
        background-color: rgba(230, 57, 70, 0.08);
    }
    .snci-resumo-geral .kpi-card .icon.decrease {
        color: #2a9d8f;
        background-color: rgba(42, 157, 143, 0.08);
    }

    .snci-resumo-geral .kpi-card .text {
        flex: 1;
        min-width: 0;
    }
    
    /* Título com ícone de informação */
    .snci-resumo-geral .kpi-card .text .title {
        font-size: 0.85rem;
        color: #64748b;
        margin-bottom: 4px;
        line-height: 1.2;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    
    .snci-resumo-geral .info-icon {
        color: #94a3b8;
        font-size: 0.75rem;
        cursor: pointer;
        transition: all 0.2s ease;
        opacity: 0.7;
        flex-shrink: 0;
        padding: 2px;
        border-radius: 50%;
    }
    
    .snci-resumo-geral .info-icon:hover {
        color: #457b9d;
        opacity: 1;
        transform: scale(1.1);
        background-color: rgba(69, 123, 157, 0.1);
    }
    
    /* Estilos do tooltip usando Popper */
    .metric-tooltip {
        background: linear-gradient(135deg, var(--azul_correios, #00416B) 55%, var(--azul_claro_correios, #0083CA)) !important;
        color: #fff !important;
        padding: 12px 16px;
        border-radius: 8px;
        font-size: 0.8rem;
        line-height: 1.4;
        max-width: 280px;
        z-index: 1000;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2) !important;
        font-weight: 400;
        font-family: inherit;
        border: none !important;
        text-align: justify !important;
        word-wrap: break-word;
        hyphens: auto;
    }
    
    .metric-tooltip[data-popper-placement^='top'] > .tooltip-arrow {
        bottom: -4px;
    }
    
    .metric-tooltip[data-popper-placement^='bottom'] > .tooltip-arrow {
        top: -4px;
    }
    
    .metric-tooltip[data-popper-placement^='left'] > .tooltip-arrow {
        right: -4px;
    }
    
    .metric-tooltip[data-popper-placement^='right'] > .tooltip-arrow {
        left: -4px;
    }
    
    .tooltip-arrow,
    .tooltip-arrow::before {
        position: absolute;
        width: 8px;
        height: 8px;
        background: linear-gradient(135deg, var(--azul_correios, #00416B) 55%, var(--azul_claro_correios, #0083CA)) !important;
    }
    
    .tooltip-arrow {
        visibility: hidden;
    }
    
    .tooltip-arrow::before {
        visibility: visible;
        content: '';
        transform: rotate(45deg);
    }

    .snci-resumo-geral .kpi-card .text .value {
        font-size: 1.35rem;
        font-weight: 600;
        color: #1e293b;
        line-height: 1.2;
    }
    .snci-resumo-geral .kpi-card .text .value.loading {
        color: #64748b;
    }

    /* Animações */
    .snci-resumo-geral .fade-in-up {
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.6s ease;
    }
    .snci-resumo-geral .fade-in-up.animate {
        opacity: 1;
        transform: translateY(0);
    }

    /* Responsividade */
    @media (max-width: 1100px) {
        .snci-resumo-geral .kpi-row {
            flex-wrap: wrap;
            gap: 12px;
        }
        .snci-resumo-geral .kpi-card {
            min-width: 160px;
            max-width: 100%;
        }
        
        .metric-tooltip {
            max-width: 250px;
        }
    }
    @media (max-width: 768px) {
        .snci-resumo-geral .kpi-row {
            flex-direction: column;
            gap: 10px;
        }
        .snci-resumo-geral .kpi-card {
            min-width: 0;
            width: 100%;
            padding: 12px;
        }
        .snci-resumo-geral .comparison-container h2 {
            font-size: 1.1rem;
        }
        
        .metric-tooltip {
            max-width: 200px;
            font-size: 0.75rem;
            padding: 10px 12px;
        }
    }
    
    @media (max-width: 480px) {
        .metric-tooltip {
            max-width: 90vw;
        }
    }
</style>

<div class="snci-resumo-geral <cfoutput>#attributes.cssClass#</cfoutput>">
    <div class="desempenho-container">
        <div class="comparison-container">
            <h2><cfoutput>#attributes.tituloResumo#</cfoutput></h2>
            <div class="kpi-row">
                <!--- Criar array ordenado pela propriedade ordem --->
                <cfset dadosOrdenados = arrayNew(1)>
                <cfloop collection="#attributes.dados#" item="chave">
                    <cfset item = attributes.dados[chave]>
                    <cfset item.chave = chave>
                    <cfset arrayAppend(dadosOrdenados, item)>
                </cfloop>
                <!--- Ordenar por ordem usando bubble sort --->
                <cfloop from="1" to="#arrayLen(dadosOrdenados)#" index="i">
                    <cfloop from="1" to="#arrayLen(dadosOrdenados)-1#" index="j">
                        <cfif dadosOrdenados[j].ordem GT dadosOrdenados[j+1].ordem>
                            <cfset temp = dadosOrdenados[j]>
                            <cfset dadosOrdenados[j] = dadosOrdenados[j+1]>
                            <cfset dadosOrdenados[j+1] = temp>
                        </cfif>
                    </cfloop>
                </cfloop>
                <!--- Loop pelos dados ordenados --->
                <cfloop array="#dadosOrdenados#" index="item">
                    <div class="kpi-card <cfif attributes.showAnimation eq 'true'>fade-in-up</cfif>" data-delay="<cfoutput>#item.ordem * 100#</cfoutput>">
                        <div class="icon <cfif structKeyExists(item, 'cor') and len(item.cor)><cfoutput>#item.cor#</cfoutput></cfif>">
                            <i class="<cfoutput>#item.icone#</cfoutput>"></i>
                        </div>
                        <div class="text">
                            <div class="title">
                                <cfoutput>#item.titulo#</cfoutput>
                                <cfif structKeyExists(item, 'definicao') and len(trim(item.definicao))>
                                    <i class="fas fa-info-circle info-icon" 
                                       data-bs-toggle="tooltip" 
                                       data-bs-placement="auto"
                                       data-bs-custom-class="metric-tooltip"
                                       data-bs-title="<cfoutput>#htmlEditFormat(item.definicao)#</cfoutput>"
                                       data-bs-html="false"></i>
                                </cfif>
                            </div>
                            <div class="value <cfif attributes.showAnimation eq 'true'>loading</cfif>">
                                <cfif structKeyExists(item, 'formatacao') and item.formatacao eq 'moeda'>
                                    R$ <span class="animated-number" data-target="<cfoutput>#numberFormat(item.valor, '_.00')#</cfoutput>" data-type="money">0,00</span>
                                <cfelse>
                                    <span class="animated-number" data-target="<cfoutput>#item.valor#</cfoutput>">0</span>
                                </cfif>
                            </div>
                        </div>
                    </div>
                </cfloop>
            </div>
        </div>
    </div>
</div>

<script language="JavaScript">
    $(document).ready(function() {
        // Variável global para armazenar tooltips ativos
        var activeTooltips = [];
        
        // Função para inicializar tooltips - versão simplificada sem Popper
        function initTooltips() {
            // Limpar tooltips existentes primeiro
            cleanupTooltips();
            
            $('.info-icon[data-bs-title]').each(function() {
                var $trigger = $(this);
                var content = $trigger.attr('data-bs-title');
                
                if (!content || $trigger.data('tooltip-initialized')) {
                    return;
                }
                
                $trigger.data('tooltip-initialized', true);
                
                // Criar tooltip element
                var $tooltip = $('<div class="metric-tooltip" style="position: absolute; opacity: 0; visibility: hidden; pointer-events: none; z-index: 1000;">' + 
                                content + 
                                '</div>');
                
                $('body').append($tooltip);
                
                // Função para calcular posição do tooltip
                function calculateTooltipPosition() {
                    var triggerOffset = $trigger.offset();
                    var triggerHeight = $trigger.outerHeight();
                    var triggerWidth = $trigger.outerWidth();
                    var windowWidth = $(window).width();
                    var windowHeight = $(window).height();
                    var scrollTop = $(window).scrollTop();
                    var scrollLeft = $(window).scrollLeft();
                    
                    // Forçar tooltip a aparecer para obter dimensões
                    $tooltip.css({
                        'position': 'absolute',
                        'visibility': 'hidden',
                        'opacity': '1',
                        'top': '-9999px',
                        'left': '-9999px'
                    });
                    
                    var tooltipHeight = $tooltip.outerHeight();
                    var tooltipWidth = $tooltip.outerWidth();
                    
                    // Esconder novamente
                    $tooltip.css({
                        'opacity': '0',
                        'visibility': 'hidden'
                    });
                    
                    // Calcular posição inicial (acima do elemento)
                    var top = triggerOffset.top - tooltipHeight - 8;
                    var left = triggerOffset.left - (tooltipWidth / 2) + (triggerWidth / 2);
                    
                    // Ajustar horizontalmente se sair da tela
                    if (left < scrollLeft + 10) {
                        left = scrollLeft + 10;
                    } else if (left + tooltipWidth > scrollLeft + windowWidth - 10) {
                        left = scrollLeft + windowWidth - tooltipWidth - 10;
                    }
                    
                    // Ajustar verticalmente se sair da tela (colocar abaixo)
                    if (top < scrollTop + 10) {
                        top = triggerOffset.top + triggerHeight + 8;
                    }
                    
                    // Verificar se ainda sai da tela na parte de baixo
                    if (top + tooltipHeight > scrollTop + windowHeight - 10) {
                        top = scrollTop + windowHeight - tooltipHeight - 10;
                    }
                    
                    return { top: top, left: left };
                }
                
                // Função para mostrar tooltip
                function showTooltip() {
                    var position = calculateTooltipPosition();
                    $tooltip.css({
                        'position': 'absolute',
                        'top': position.top + 'px',
                        'left': position.left + 'px',
                        'opacity': '1',
                        'visibility': 'visible'
                    });
                }
                
                // Função para esconder tooltip
                function hideTooltip() {
                    $tooltip.css({
                        'opacity': '0',
                        'visibility': 'hidden'
                    });
                }
                
                // Eventos
                $trigger.on('mouseenter.tooltip', function(e) {
                    e.stopPropagation();
                    showTooltip();
                });
                
                $trigger.on('mouseleave.tooltip', function(e) {
                    e.stopPropagation();
                    setTimeout(hideTooltip, 100);
                });
                
                $trigger.on('focus.tooltip', function(e) {
                    e.stopPropagation();
                    showTooltip();
                });
                
                $trigger.on('blur.tooltip', function(e) {
                    e.stopPropagation();
                    hideTooltip();
                });
                
                // Esconder tooltip ao clicar fora
                var clickEventName = 'click.tooltip-' + Date.now();
                $(document).on(clickEventName, function(e) {
                    if (!$trigger.is(e.target) && !$tooltip.is(e.target) && $tooltip.has(e.target).length === 0) {
                        hideTooltip();
                    }
                });
                
                // Esconder tooltip ao fazer scroll
                $(window).on('scroll.tooltip resize.tooltip', function() {
                    hideTooltip();
                });
                
                // Armazenar referências para cleanup
                activeTooltips.push({
                    trigger: $trigger,
                    tooltip: $tooltip,
                    clickEvent: clickEventName
                });
            });
        }
        
        // Cleanup dos tooltips
        function cleanupTooltips() {
            activeTooltips.forEach(function(tooltip) {
                if (tooltip.trigger) {
                    tooltip.trigger.off('.tooltip');
                    tooltip.trigger.removeData('tooltip-initialized');
                }
                if (tooltip.tooltip) {
                    tooltip.tooltip.remove();
                }
                if (tooltip.clickEvent) {
                    $(document).off(tooltip.clickEvent);
                }
            });
            activeTooltips = [];
            
            // Remover eventos globais
            $(window).off('.tooltip');
        }

        // Função para animar números
        function animateNumbers() {
            $('.desempenho-container .animated-number').each(function() {
                var $this = $(this);
                var target = parseFloat($this.data('target'));
                var isMoney = $this.data('type') === 'money';
                
                if (target && !$this.hasClass('animated')) {
                    $this.addClass('animated');
                    $({ countNum: 0 }).animate({
                        countNum: target
                    }, {
                        duration: 1500,
                        easing: 'swing',
                        step: function() {
                            if (isMoney) {
                                $this.text(this.countNum.toLocaleString('pt-BR', {
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                }));
                            } else {
                                $this.text(Math.floor(this.countNum).toLocaleString('pt-BR'));
                            }
                        },
                        complete: function() {
                            if (isMoney) {
                                $this.text(this.countNum.toLocaleString('pt-BR', {
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                }));
                            } else {
                                $this.text(this.countNum.toLocaleString('pt-BR'));
                            }
                            $this.closest('.value').removeClass('loading');
                        }
                    });
                }
            });
        }
        
        // Função para animar entrada dos cards
        function animateCards() {
            <cfif attributes.showAnimation eq 'true'>
            $('.desempenho-container .fade-in-up').each(function(i) {
                var $this = $(this);
                var delay = $this.data('delay') || (i * 100);
                
                setTimeout(function() {
                    $this.addClass('animate');
                }, delay);
            });
            
            // Inicia animação dos números após os cards aparecerem
            setTimeout(function() {
                animateNumbers();
                // Inicializar tooltips após as animações
                setTimeout(function() {
                    initTooltips();
                }, 300);
            }, 600);
            <cfelse>
            $('.desempenho-container .fade-in-up').addClass('animate');
            animateNumbers();
            // Inicializar tooltips imediatamente
            setTimeout(function() {
                initTooltips();
            }, 100);
            </cfif>
        }
        
        // Verifica se o componente está visível na tela
        function isElementInViewport(el) {
            var rect = el.getBoundingClientRect();
            return (
                rect.top >= 0 &&
                rect.left >= 0 &&
                rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
                rect.right <= (window.innerWidth || document.documentElement.clientWidth)
            );
        }
        
        // Observer para animar quando visível
        var hasAnimated = false;
        
        function checkVisibility() {
            if (!hasAnimated && $('.desempenho-container').length > 0) {
                var container = $('.desempenho-container')[0];
                if (isElementInViewport(container)) {
                    hasAnimated = true;
                    animateCards();
                    $(window).off('scroll.visibility resize.visibility');
                }
            }
        }
        
        // Verificar visibilidade no carregamento e nos eventos
        checkVisibility();
        $(window).on('scroll.visibility resize.visibility', checkVisibility);
        
        // Cleanup ao descarregar a página
        $(window).on('beforeunload', function() {
            cleanupTooltips();
        });
    });
</script>
           