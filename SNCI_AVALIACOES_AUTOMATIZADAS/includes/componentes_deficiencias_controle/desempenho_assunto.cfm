<cfprocessingdirective pageencoding="utf-8">

<cfparam name="titulo" default="Desempenho por Assunto">
<cfparam name="cssClass" default="main-dashboard">
<cfparam name="showAnimation" default="true">
<cfparam name="dados" default="#structNew()#">
<cfparam name="heroMessage" default="">



<!--- Verifica os dados comparativos caso não sejam fornecidos --->
<cfif structIsEmpty(dados)>
    <cfset dados = {
        pendenciasProter = {
            titulo = "Pendências no PROTER",
            maio = { valor = 26879, percentual = 97.5 },
            junho = { valor = 27543, percentual = 100 },
            mudanca = { valor = 664, tipo = "increase", percentual = 2, texto = "Aumentou 2%" }
        },
        funcionamentoAlarme = {
            titulo = "Funcionamento do alarme",
            maio = { valor = 6391, percentual = 95.9 },
            junho = { valor = 6663, percentual = 100 },
            mudanca = { valor = 272, tipo = "increase", percentual = 4, texto = "Aumentou 4%" }
        },
        embarqueDesembarque = {
            titulo = "Embarque e desembarque da carga",
            maio = { valor = 2255, percentual = 42.8 },
            junho = { valor = 5267, percentual = 100 },
            mudanca = { valor = 3012, tipo = "increase", percentual = 134, texto = "Aumentou 134%" }
        },
        cnhVencida = {
            titulo = "CNH vencida há mais de 30 dias",
            maio = { valor = 6017, percentual = 100 },
            junho = { valor = 5207, percentual = 86.5 },
            mudanca = { valor = 810, tipo = "decrease", percentual = 13, texto = "Reduziu 13%" }
        }
    }>
</cfif>

<cfif len(heroMessage) eq 0>
    <cfset heroMessage = "Em Junho, o total de eventos com deficiências do controle <strong>aumentou 32%</strong> em relação ao mês anterior.">
</cfif>

<style>
    .snci-desempenho-assunto .desempenho-container {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }
    
    /* Card de Resumo Principal (Hero) */
    .snci-desempenho-assunto .hero-card {
        background: linear-gradient(135deg,var(--azul_claro_correios) 0%, var(--azul_correios) 100%);
        color: white;
        padding: 5px;
        border-radius: var(--border-radius, 16px);
        box-shadow: var(--shadow, 0 10px 15px -3px rgb(0 0 0 / 0.05), 0 4px 6px -4px rgb(0 0 0 / 0.05));
        transition: all 0.3s ease;
    }
    
    .snci-desempenho-assunto .hero-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 10px 10px -5px rgb(0 0 0 / 0.04);
    }
    
    .snci-desempenho-assunto .hero-summary {
        display: flex;
        align-items: center;
        gap: 16px;
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        backdrop-filter: blur(5px);
    }
    
    .snci-desempenho-assunto .hero-summary .icon {
        font-size: 2rem;
        flex-shrink: 0;
        padding: 10px;
    }
    
    .snci-desempenho-assunto .hero-summary .text {
        font-size: 1.1rem;
        font-weight: 500;
        line-height: 1.4;
    }
    
    .snci-desempenho-assunto .hero-summary .text strong {
        font-size: 1.2rem;
        font-weight: 700;
        color: var(--secondary-color, #FFD200);
    }

    /* Lista de Comparação Gráfica */
    .snci-desempenho-assunto .comparison-container {
        background: var(--card-bg-color, #ffffff);
        padding: 20px;
        border-radius: var(--border-radius, 16px);
        box-shadow: var(--shadow, 0 10px 15px -3px rgb(0 0 0 / 0.05), 0 4px 6px -4px rgb(0 0 0 / 0.05));
        border: 1px solid var(--border-color, #e2e8f0);
        transition: all 0.3s ease;
    }
    
    .snci-desempenho-assunto .comparison-container:hover {
        box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 10px 10px -5px rgb(0 0 0 / 0.04);
    }
    
    .snci-desempenho-assunto .comparison-container h2 {
        font-size: 1.5rem;
        font-weight: 600;
        margin: 0 0 24px 0;
        color: var(--text-primary, #1e293b);
        position: relative;
        padding-bottom: 10px;
    }
    
    .snci-desempenho-assunto .comparison-container h2::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 50px;
        height: 3px;
        background: linear-gradient(90deg, var(--azul_correios), var(--azul_claro_correios));
        border-radius: 2px;
    }
    
    .snci-desempenho-assunto .comparison-item {
        display: grid;
        grid-template-columns: 2fr 3fr 1fr;
        align-items: center;
        gap: 10px;
        padding: 15px 0;
        border-bottom: 1px solid var(--border-color, #e2e8f0);
        transition: all 0.3s ease;
    }
    
    .snci-desempenho-assunto .comparison-item:last-child { 
        border-bottom: none; 
    }
    
    .snci-desempenho-assunto .comparison-item:hover {
        background-color: rgba(0, 51, 102, 0.02);
        padding-left: 10px;
        border-radius: 8px;
    }
    
    .snci-desempenho-assunto .item-title { 
        font-weight: 500;
        color: var(--text-primary, #1e293b);
        font-size: 0.95rem;
    }
    
    .snci-desempenho-assunto .item-bars {
        position: relative;
    }
    
    .snci-desempenho-assunto .item-bars .bar {
        height: 12px;
        border-radius: 6px;
        background-color: var(--border-color, #e2e8f0);
        transition: width 1.5s ease-in-out;
        position: relative;
        overflow: hidden;
    }
    
    .snci-desempenho-assunto .item-bars .bar.maio { 
        background: linear-gradient(90deg, #a8dadc, #7fb3d3);
        margin-bottom: 8px;
    }
    
    .snci-desempenho-assunto .item-bars .bar.junho { 
        background: linear-gradient(90deg, #457b9d, #1e3d59);
    }
    
    .snci-desempenho-assunto .item-bars .label {
        display: flex;
        justify-content: space-between;
        font-size: 0.8rem;
        color: var(--text-secondary, #64748b);
        margin-bottom: 6px;
        font-weight: 500;
    }
    
    .snci-desempenho-assunto .item-change {
        text-align: right;
    }
    
    .snci-desempenho-assunto .item-change .value {
        font-size: 1.1rem;
        font-weight: 600;
        display: block;
        margin-bottom: 4px;
    }
    
    .snci-desempenho-assunto .item-change .status { 
        font-size: 0.85rem;
        opacity: 0.8;
    }
    
    .snci-desempenho-assunto .increase { 
        color: var(--danger-color, #e63946);
    }
    
    .snci-desempenho-assunto .decrease { 
        color: var(--success-color, #2a9d8f);
    }

    /* Animações */
    .snci-desempenho-assunto .fade-in-up {
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.6s ease;
    }
    
    .snci-desempenho-assunto .fade-in-up.animate {
        opacity: 1;
        transform: translateY(0);
    }

    /* Responsividade */
    @media (max-width: 1200px) {
        .snci-desempenho-assunto .comparison-item {
            grid-template-columns: 1fr;
            gap: 16px;
            padding: 20px 0;
        }
        .snci-desempenho-assunto .item-change { 
            text-align: left; 
        }
    }
    
    @media (max-width: 768px) {
        .snci-desempenho-assunto .desempenho-container {
            gap: 15px;
        }
        
        .snci-desempenho-assunto .hero-summary {
            flex-direction: column;
            text-align: center;
            gap: 12px;
        }
        
        .snci-desempenho-assunto .hero-summary .text {
            font-size: 1rem;
        }
        
        .snci-desempenho-assunto .comparison-container {
            padding: 15px;
        }
        
        .snci-desempenho-assunto .comparison-container h2 {
            font-size: 1.3rem;
        }
    }
</style>

<div class="snci-desempenho-assunto">
    <div class="desempenho-container <cfoutput>#cssClass#</cfoutput>">
        <!-- Card Hero -->
        <div class="hero-card <cfif showAnimation eq 'true'>fade-in-up</cfif>" data-delay="100">
            <div class="hero-summary">
                <div class="icon"><i class="fas fa-chart-line increase"></i></div>
                <div class="text">
                    <cfoutput>#heroMessage#</cfoutput>
                </div>
            </div>
        </div>

        <!-- Container de Comparação -->
        <div class="comparison-container <cfif showAnimation eq 'true'>fade-in-up</cfif>" data-delay="200">
            <h2><cfoutput>#titulo#</cfoutput></h2>
            
            <!--- Loop direto pelos dados (sem ordenação) --->
            <cfloop collection="#dados#" item="chave">
                <cfset item = dados[chave]>
                <div class="comparison-item <cfif showAnimation eq 'true'>fade-in-up</cfif>" data-delay="300">
                    <div class="item-title"><cfoutput>#item.titulo#</cfoutput></div>
                    <div class="item-bars">
                        <div class="label">
                            <span>Maio</span> 
                            <span><cfoutput>#numberFormat(item.maio.valor, "999,999")#</cfoutput></span>
                        </div>
                        <div class="bar maio animated-bar" style="width:0%;" data-width="<cfoutput>#item.maio.percentual#%</cfoutput>"></div>
                        <div class="label" style="margin-top:8px;">
                            <span>Junho</span> 
                            <span><cfoutput>#numberFormat(item.junho.valor, "999,999")#</cfoutput></span>
                        </div>
                        <div class="bar junho animated-bar" style="width:0%;" data-width="<cfoutput>#item.junho.percentual#%</cfoutput>"></div>
                    </div>
                    <div class="item-change <cfoutput>#item.mudanca.tipo#</cfoutput>">
                        <span class="value">
                            <cfif item.mudanca.tipo eq "increase">↑<cfelse>↓</cfif> 
                            <cfoutput>#numberFormat(item.mudanca.valor, "999,999")#</cfoutput>
                        </span>
                        <span class="status"><cfoutput>#item.mudanca.texto#</cfoutput></span>
                    </div>
                </div>
            </cfloop>
        </div>
    </div>
</div>

<script language="JavaScript">
    $(document).ready(function() {
        // Função para animar barras de progresso
        function animateBars() {
            $('.desempenho-container .animated-bar').each(function(){
                var $this = $(this);
                var targetWidth = $this.data('width');
                
                if (!$this.hasClass('animated')) {
                    $this.addClass('animated');
                    $this.css('width', '0%').animate({
                        width: targetWidth
                    }, 1500, 'swing');
                }
            });
        }
        
        // Função para animar entrada dos elementos
        function animateElements() {
            <cfif showAnimation eq 'true'>
            $('.desempenho-container .fade-in-up').each(function(i) {
                var $this = $(this);
                var delay = $this.data('delay') || (i * 100);
                
                setTimeout(function() {
                    $this.addClass('animate');
                }, delay);
            });
            
            // Inicia animação das barras após os elementos aparecerem (delay reduzido)
            setTimeout(function() {
                animateBars();
            }, 100);
            <cfelse>
            $('.desempenho-container .fade-in-up').addClass('animate');
            animateBars();
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
        
        // Inicia animação quando o componente fica visível
        function checkVisibility() {
            var container = $('.desempenho-container')[0];
            if (container && isElementInViewport(container) && !$(container).hasClass('animated')) {
                $(container).addClass('animated');
                animateElements();
            }
        }
        
        // Verifica visibilidade no scroll e no carregamento
        $(window).on('scroll resize', checkVisibility);
        checkVisibility();
    });
</script>


