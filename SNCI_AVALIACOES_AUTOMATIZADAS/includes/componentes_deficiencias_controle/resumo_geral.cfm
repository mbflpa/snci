<cfprocessingdirective pageencoding="utf-8">

<cfset anoAtual = dateFormat(now(), "yyyy")>
<cfparam name="attributes.titulo" default="Resumo Geral de #anoAtual#">
<cfparam name="attributes.cssClass" default="">
<cfparam name="attributes.showAnimation" default="true">
<cfparam name="attributes.dados" default="#structNew()#">
<!-- Verifica os dados da unidade de lotação do usuário na tabela fato_verificacao -->
<cfquery name="rsDadosHistoricos" datasource="#application.dsn_avaliacoes_automatizadas#">
    SELECT   COUNT(DISTINCT CASE WHEN suspenso = 0 AND sk_grupo_item <> 12 THEN sk_grupo_item END) AS testesEnvolvidos
            ,SUM(NC_Eventos) AS totalEventos
            ,COUNT(CASE WHEN sigla_apontamento in('C','N') THEN sigla_apontamento END) AS testesAplicados
            ,COUNT(CASE WHEN sigla_apontamento = 'C' THEN sigla_apontamento END) AS conformes
            ,COUNT(CASE WHEN sigla_apontamento = 'N' THEN sigla_apontamento END) AS deficienciasControle
            ,SUM(
                    COALESCE(valor_falta, 0) + 
                    COALESCE(valor_sobra, 0) + 
                    CASE 
                        WHEN nm_teste <> '239-4' THEN COALESCE(valor_risco, 0)
                        ELSE 0
                    END
                ) AS valorEnvolvido
            ,SUM(nr_reincidente) AS reincidencia
    FROM fato_verificacao f
    WHERE f.sk_mcu = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.rsUsuarioParametros.Und_MCU#"> 
    </cfquery>


<!--- Estrutura padrão dos dados caso não seja fornecida --->
<cfif structIsEmpty(attributes.dados)>
    <cfset attributes.dados = {
        testesEnvolvidos = {
            valor = rsDadosHistoricos.testesEnvolvidos,
            icone = "fas fa-list-ul",
            titulo = "Testes Envolvidos",
            cor = "",
            ordem= 1
        },
        testesAplicados = {
            valor = rsDadosHistoricos.testesAplicados,
            icone = "fas fa-tasks",
            titulo = "Testes Aplicados",
            cor = "",
            ordem= 2
        },
        conformes = {
            valor = rsDadosHistoricos.conformes,
            icone = "fas fa-check-circle",
            titulo = "Conformes",
            cor = "decrease",
            ordem= 3
        },
        deficienciasControle = {
            valor = rsDadosHistoricos.deficienciasControle,
            icone = "fas fa-exclamation-triangle",
            titulo = "Deficiência do Controle",
            cor = "increase",
            ordem= 4
        },
        totalEventos = {
            valor = rsDadosHistoricos.totalEventos,
            icone = "fas fa-chart-bar",
            titulo = "Total de Eventos",
            cor = "",
            ordem= 5
        },
        reincidencia= {
            valor = rsDadosHistoricos.reincidencia,
            icone = "fas fa-redo",
            titulo = "Reincidência",
            cor = "",
            ordem= 6
        },
        valorEnvolvido = {
            valor = rsDadosHistoricos.valorEnvolvido,
            icone = "fas fa-dollar-sign",
            titulo = "Valor Envolvido",
            cor = "",
            formatacao = "moeda",
            ordem= 7
        }
    }>
</cfif>

<style>
    /* Container principal harmonizado com desempenho_assunto */
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
    .snci-resumo-geral .kpi-card .text .title {
        font-size: 0.85rem;
        color: #64748b;
        margin-bottom: 4px;
        line-height: 1.2;
        font-weight: 500;
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
    }
</style>

<div class="snci-resumo-geral <cfoutput>#attributes.cssClass#</cfoutput>">
    <div class="desempenho-container">
        <div class="comparison-container">
            <h2><cfoutput>#attributes.titulo#</cfoutput></h2>
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
        </div>
    </div>
</div>

<script language="JavaScript">
    $(document).ready(function() {
        // Função para animar números
        function animateNumbers() {
            $('.desempenho-container .animated-number').each(function() {
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
            }, 600);
            <cfelse>
            $('.desempenho-container .fade-in-up').addClass('animate');
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
            var container = $('.desempenho-container')[0];
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
</script>
