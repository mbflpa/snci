<cfprocessingdirective pageencoding="utf-8">

<cfparam name="attributes.titulo" default="Resumo Geral">
<cfparam name="attributes.cssClass" default="">
<cfparam name="attributes.showAnimation" default="true">
<cfparam name="attributes.dados" default="#structNew()#">

<!--- Estrutura padrão dos dados caso não seja fornecida --->
<cfif structIsEmpty(attributes.dados)>
    <cfset attributes.dados = {
        testesAplicados = {
            valor = 123552,
            icone = "fas fa-tasks",
            titulo = "Testes Aplicados",
            cor = ""
        },
        conformes = {
            valor = 94094,
            icone = "fas fa-check-circle",
            titulo = "Conformes",
            cor = "decrease"
        },
        deficienciasControle = {
            valor = 29458,
            icone = "fas fa-exclamation-triangle",
            titulo = "Deficiência do Controle",
            cor = "increase"
        },
        totalEventos = {
            valor = 1947292,
            icone = "fas fa-chart-bar",
            titulo = "Total de Eventos",
            cor = ""
        },
        valorEnvolvido = {
            valor = 79256842,
            icone = "fas fa-dollar-sign",
            titulo = "Valor Envolvido",
            cor = "",
            formatacao = "moeda"
        }
    }>
</cfif>

<style>
    .resumo-geral-container {
        display: flex;
        flex-direction: column;
        gap: 15px;
        text-align: center;
    }
    
    .resumo-geral-titulo {
        font-size: 1.5rem;
        font-weight: 600;
        margin: 0;
        color: var(--text-primary, #1e293b);
    }
    
    .kpi-card {
        background: var(--card-bg-color, #ffffff);
        padding: 20px;
        border-radius: var(--border-radius, 16px);
        box-shadow: var(--shadow, 0 10px 15px -3px rgb(0 0 0 / 0.05), 0 4px 6px -4px rgb(0 0 0 / 0.05));
        display: flex;
        align-items: center;
        gap: 16px;
        text-align: left;
        transition: all 0.3s ease;
        border: 1px solid var(--border-color, #e2e8f0);
    }
    
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 10px 10px -5px rgb(0 0 0 / 0.04);
    }
    
    .kpi-card .icon {
        font-size: 1.5rem;
        color: var(--primary-color, #003366);
        background-color: rgba(0, 51, 102, 0.1);
        height: 48px;
        width: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
    }
    
    .kpi-card .icon.increase {
        color: var(--danger-color, #e63946);
        background-color: rgba(230, 57, 70, 0.1);
    }
    
    .kpi-card .icon.decrease {
        color: var(--success-color, #2a9d8f);
        background-color: rgba(42, 157, 143, 0.1);
    }
    
    .kpi-card .text {
        flex: 1;
        min-width: 0;
    }
    
    .kpi-card .text .title {
        font-size: 0.9rem;
        color: var(--text-secondary, #64748b);
        margin-bottom: 4px;
        line-height: 1.2;
    }
    
    .kpi-card .text .value {
        font-size: 1.5rem;
        font-weight: 600;
        color: var(--text-primary, #1e293b);
        line-height: 1.2;
    }
    
    .kpi-card .text .value.loading {
        color: var(--text-secondary, #64748b);
    }
    
    /* Animações */
    .fade-in-up {
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.6s ease;
    }
    
    .fade-in-up.animate {
        opacity: 1;
        transform: translateY(0);
    }
    
    /* Responsividade */
    @media (max-width: 768px) {
        .kpi-card {
            padding: 16px;
            gap: 12px;
        }
        
        .kpi-card .icon {
            height: 40px;
            width: 40px;
            font-size: 1.2rem;
        }
        
        .kpi-card .text .value {
            font-size: 1.3rem;
        }
        
        .resumo-geral-titulo {
            font-size: 1.3rem;
        }
    }
</style>

<div class="resumo-geral-container <cfoutput>#attributes.cssClass#</cfoutput>">
    <h2 class="resumo-geral-titulo"><cfoutput>#attributes.titulo#</cfoutput></h2>
    
    <cfloop collection="#attributes.dados#" item="chave">
        <cfset item = attributes.dados[chave]>
        <div class="kpi-card <cfif attributes.showAnimation eq 'true'>fade-in-up</cfif>" data-delay="<cfoutput>#listFindNoCase(structKeyList(attributes.dados), chave) * 100#</cfoutput>">
            <div class="icon <cfif structKeyExists(item, 'cor') and len(item.cor)><cfoutput>#item.cor#</cfoutput></cfif>">
                <i class="<cfoutput>#item.icone#</cfoutput>"></i>
            </div>
            <div class="text">
                <div class="title"><cfoutput>#item.titulo#</cfoutput></div>
                <div class="value <cfif attributes.showAnimation eq 'true'>loading</cfif>">
                    <cfif structKeyExists(item, 'formatacao') and item.formatacao eq 'moeda'>
                        R$ <span class="animated-number" data-target="<cfoutput>#item.valor#</cfoutput>">0</span>
                    <cfelse>
                        <span class="animated-number" data-target="<cfoutput>#item.valor#</cfoutput>">0</span>
                    </cfif>
                </div>
            </div>
        </div>
    </cfloop>
</div>

<script language="JavaScript">
    $(document).ready(function() {
        // Função para animar números
        function animateNumbers() {
            $('.resumo-geral-container .animated-number').each(function() {
                var $this = $(this);
                var target = parseInt($this.data('target'));
                
                if (target && !$this.hasClass('animated')) {
                    $this.addClass('animated');
                    $({ countNum: 0 }).animate({
                        countNum: target
                    }, {
                        duration: 1500,
                        easing: 'swing',
                        step: function() {
                            $this.text(Math.floor(this.countNum).toLocaleString('pt-BR'));
                        },
                        complete: function() {
                            $this.text(this.countNum.toLocaleString('pt-BR'));
                            $this.closest('.value').removeClass('loading');
                        }
                    });
                }
            });
        }
        
        // Função para animar entrada dos cards
        function animateCards() {
            <cfif attributes.showAnimation eq 'true'>
            $('.resumo-geral-container .fade-in-up').each(function(i) {
                var $this = $(this);
                var delay = $this.data('delay') || (i * 100);
                
                setTimeout(function() {
                    $this.addClass('animate');
                }, delay);
            });
            
            // Inicia animação dos números após os cards aparecerem
            setTimeout(function() {
                animateNumbers();
            }, 600);
            <cfelse>
            $('.resumo-geral-container .fade-in-up').addClass('animate');
            animateNumbers();
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
            var container = $('.resumo-geral-container')[0];
            if (container && isElementInViewport(container) && !$(container).hasClass('animated')) {
                $(container).addClass('animated');
                animateCards();
            }
        }
        
        // Verifica visibilidade no scroll e no carregamento
        $(window).on('scroll resize', checkVisibility);
        checkVisibility();
    });
</script>
