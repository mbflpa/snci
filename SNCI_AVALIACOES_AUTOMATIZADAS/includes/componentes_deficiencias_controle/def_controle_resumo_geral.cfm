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
            titulo = "Testes Conformes",
            cor = "decrease",
            definicao = "Tratam-se de situações identificadas nas avaliações realizadas nas unidades operacionais, por meio da aplicação de testes de controle (Plano de Testes), que estão de acordo com o previsto em normas internas dos Correios, documentos de orientações vigentes (ofícios) e legislações.",
            ordem= 3
        },
        deficienciasControle = {
            valor = dadosHistoricos.deficienciasControle,
            icone = "fas fa-exclamation-triangle",
            titulo = "Testes c/ Deficiência do Controle",
            cor = "increase",
            definicao = "Tratam-se de situações identificadas nas avaliações realizadas nas unidades operacionais, por meio da aplicação de testes de controle (Plano de Testes), que não condizem com o previsto em normas internas dos Correios, documentos de orientações vigentes (ofícios) e legislações.",
            ordem= 4
        },
        totalEventos = {
            valor = dadosHistoricos.totalEventos,
            icone = "fas fa-chart-bar",
            titulo = "Total de Eventos",
            cor = "",
            definicao = "Contempla os registros das deficiências dos controles identificados no sistemas/bases. Os registros identificados são aplicados conforme o objetivo de cada teste.",
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
    .snci-resumo-geral {
        margin-bottom: 1.25rem;
    }
    .snci-resumo-geral .desempenho-container {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
    }
    .snci-resumo-geral .comparison-container {
        background: #fff;
        padding: 0.75rem 1rem;
        border-radius: 0.75rem;
        box-shadow: 0 0.25rem 0.5rem rgba(0, 0, 0, 0.05);
        border: 0.0625rem solid #e2e8f0;
    }
    .snci-resumo-geral .comparison-container h2 {
        font-size: 1.25rem;
        font-weight: 600;
        margin-bottom: 1rem;
        color: #1e293b;
        padding-bottom: 0.375rem;
        position: relative;
        text-align: left;
    }
    .snci-resumo-geral .comparison-container h2::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 0.125rem;
        background: linear-gradient(90deg, #457b9d, #a8dadc);
        border-radius: 0.0625rem;
    }
    .snci-resumo-geral .kpi-row {
        display: flex;
        flex-direction: row;
        gap: 0.3125rem;
        justify-content: center;
        align-items: stretch;
        flex-wrap: wrap;
    }
    .snci-resumo-geral .kpi-card {
        background: #fff;
        padding: 0.625rem;
        border-radius: 0.75rem;
        box-shadow: 0 0.25rem 0.5rem rgba(0, 0, 0, 0.05);
        display: flex;
        align-items: center;
        gap: 0.625rem;
        text-align: left;
        transition: all 0.3s ease;
        border: 0.0625rem solid #e2e8f0;
        min-width: 11.25rem;
        flex: 1 1 11.25rem;
        max-width: 15.625rem;
    }
    .snci-resumo-geral .kpi-card:hover {
        transform: translateY(-0.125rem);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.08);
    }
    .snci-resumo-geral .kpi-card .icon {
        font-size: 1.5rem;
        color: var(--primary-color, #003366);
        background-color: rgba(0, 51, 102, 0.08);
        height: 2.75rem;
        width: 2.75rem;
        border-radius: 0.625rem;
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
        margin-bottom: 0.25rem;
        line-height: 1.2;
        font-weight: 500;
        display: flex;
        align-items: center;
        gap: 0.375rem;
    }
    .snci-resumo-geral .kpi-card .text .value {
        font-size: 1.2rem;
        font-weight: 600;
        color: #1e293b;
        line-height: 1.2;
    }
    .snci-resumo-geral .fade-in-up,
    .snci-resumo-geral .fade-in-up.animate,
    .snci-resumo-geral .kpi-card .text .value.loading {
        /* removido */
    }
    @media (max-width: 1100px) {
        .snci-resumo-geral .kpi-row {
            gap: 0.75rem;
        }
        .snci-resumo-geral .kpi-card {
            min-width: 10rem;
            max-width: 100%;
        }
        .metric-tooltip {
            max-width: 15.625rem;
        }
    }
    @media (max-width: 768px) {
        .snci-resumo-geral .kpi-row {
            flex-direction: column;
            gap: 0.625rem;
        }
        .snci-resumo-geral .kpi-card {
            min-width: 0;
            width: 100%;
            padding: 0.75rem;
        }
        .snci-resumo-geral .comparison-container h2 {
            font-size: 1.1rem;
        }
        .metric-tooltip {
            max-width: 12.5rem;
            font-size: 0.75rem;
            padding: 0.625rem 0.75rem;
        }
    }
    @media (max-width: 480px) {
        .metric-tooltip {
            max-width: 90vw;
        }
    }
    .popover .popover-body {
        text-align: justify !important;
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
                    <div class="kpi-card">
                        <div class="icon <cfif structKeyExists(item, 'cor') and len(item.cor)><cfoutput>#item.cor#</cfoutput></cfif>">
                            <i class="<cfoutput>#item.icone#</cfoutput>"></i>
                        </div>
                        <div class="text">
                            <div class="title">
                                <cfoutput>#item.titulo#</cfoutput>
                                <cfif structKeyExists(item, 'definicao') and len(trim(item.definicao))>
                                    <i class=" info-icon-automatizadas" 
                                       data-toggle="popover" 
                                       data-trigger="hover" 
                                       data-placement="top"
                                       data-html="false"
                                       data-content="<cfoutput>#htmlEditFormat(item.definicao)#</cfoutput>"></i>
                                </cfif>
                            </div>
                            <div class="value">
                                <cfif structKeyExists(item, 'formatacao') and item.formatacao eq 'moeda'>
                                    <span class="valor-moeda"><cfoutput>#item.valor#</cfoutput></span>
                                <cfelse>
                                    <cfif isNumeric(item.valor)>
                                        <span class="valor-numero"><cfoutput>#item.valor#</cfoutput></span>
                                    <cfelse>
                                        <cfoutput>#item.valor#</cfoutput>
                                    </cfif>
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
        // Inicializar popovers usando Bootstrap nativo
        $('[data-toggle="popover"]').popover({
            container: 'body',
            html: false,
            trigger: 'hover'
        });

        // Formatar valores monetários pt-br
        $('.valor-moeda').each(function() {
            var valor = parseFloat($(this).text().replace(',', '.'));
            if (!isNaN(valor)) {
                $(this).text('R$ ' + valor.toLocaleString('pt-BR', {minimumFractionDigits: 2, maximumFractionDigits: 2}));
            }
        });

        // Formatar valores inteiros pt-br
        $('.valor-numero').each(function() {
            var valor = parseInt($(this).text());
            if (!isNaN(valor)) {
                $(this).text(valor.toLocaleString('pt-BR'));
            }
        });
    });
</script>
