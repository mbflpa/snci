<cfprocessingdirective pageencoding="utf-8">


<!--- Adicionar cfparam para url.mesFiltro ANTES de usar a variável --->
<cfparam name="url.mesFiltro" default="">

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

<!--- Debug: verificar valores dos meses --->
<cfoutput>
    <!-- DEBUG: nomeMesAtual = "#nomeMesAtual#" -->
    <!-- DEBUG: mesAtualId = "#mesAtualId#" -->
    <!-- DEBUG: trim(nomeMesAtual) = "#trim(nomeMesAtual)#" -->
    <!-- DEBUG: lcase(trim(nomeMesAtual)) = "#lcase(trim(nomeMesAtual))#" -->
</cfoutput>

<!--- Testar múltiplas condições para janeiro --->
<cfset isJaneiro = (
    lcase(trim(nomeMesAtual)) EQ "janeiro" OR 
    lcase(trim(nomeMesAtual)) CONTAINS "jan" OR 
    mesAtualId EQ 1 OR
    month(now()) EQ 1
)>

<!--- Função para abreviar nomes dos meses --->
<cfscript>
    function abreviarMes(nomeMes) {
        var mes = lcase(trim(nomeMes));
        switch(mes) {
            case "janeiro": return "JAN";
            case "fevereiro": return "FEV";
            case "março": return "MAR";
            case "abril": return "ABR";
            case "maio": return "MAI";
            case "junho": return "JUN";
            case "julho": return "JUL";
            case "agosto": return "AGO";
            case "setembro": return "SET";
            case "outubro": return "OUT";
            case "novembro": return "NOV";
            case "dezembro": return "DEZ";
            default: return ucase(left(mes, 3));
        }
    }
</cfscript>

<!--- Debug da condição --->
<cfoutput>
    <!-- DEBUG: isJaneiro = "#isJaneiro#" -->
</cfoutput>

<!--- Usar dados já processados do CFC --->
<cfset dados = dadosDesempenho.dadosAssunto>

<!--- Calcular totais de eventos para percentuais --->
<cfset totalEventosAtual = 0>
<cfset totalEventosAnterior = 0>
<cfloop collection="#dados#" item="chave">
    <cfset registro = dados[chave]>
    <cfset totalEventosAtual = totalEventosAtual + registro.atual>
    <cfset totalEventosAnterior = totalEventosAnterior + registro.anterior>
</cfloop>

<!--- Calcular evolução percentual e encontrar o maior valor para escala das barras --->
<cfset maxValor = 0>
<cfloop collection="#dados#" item="chave">
    <cfset registro = dados[chave]>
    <cfset anterior = registro.anterior>
    <cfset atual = registro.atual>
    <cfset delta = atual - anterior>
    <!--- Se anterior for zero, percentual sempre será zero --->
    <cfif anterior EQ 0>
        <cfset percentual = 0>
    <cfelse>
        <cfset percentual = round((delta/anterior)*100)>
    </cfif>
    <cfset tipo = (delta GTE 0 ? "increase" : "decrease")>
    <cfset registro.percentual = percentual>
    <cfset registro.tipo = tipo>
    <cfset registro.delta = delta>
    
    <!--- Calcular percentuais em relação ao total --->
    <cfif totalEventosAtual GT 0>
        <cfset registro.percentualAtual = numberFormat((atual/totalEventosAtual)*100, "0")>
    <cfelse>
        <cfset registro.percentualAtual = "0">
    </cfif>

    <cfif totalEventosAnterior GT 0>
        <cfset registro.percentualAnterior = numberFormat((anterior/totalEventosAnterior)*100, "0")>
    <cfelse>
        <cfset registro.percentualAnterior = "0">
    </cfif>
    
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
    .card-header {
        border:none!important;
        padding-left: 0!important;
        padding-right: 0!important;
        min-height: 63px;
    }
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
        overflow-x: auto; /* Permite barra de rolagem horizontal */
        overflow-y: visible;
        padding: 0 60px;
        width: 100%;
        padding-top: 10px;
        scrollbar-width: thin;
        scrollbar-color: #457b9d #e2e8f0;
        
    }
    .snci-desempenho-assunto .carousel-track {
        display: flex;
        gap: 24px;
        width: max-content; /* Garante largura para scroll */
        min-width: 100%;
        transition: transform 0.5s ease-in-out;
        /* Remover cursor: grab */
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }
    /* Barra de rolagem customizada para navegadores Webkit */
    .snci-desempenho-assunto .carousel-container::-webkit-scrollbar {
        height: 12px;
        cursor: pointer;
    }
    .snci-desempenho-assunto .carousel-container::-webkit-scrollbar-thumb {
        background: #457b9d;
        border-radius: 6px;
        cursor: pointer;
    }
    .snci-desempenho-assunto .carousel-container::-webkit-scrollbar-thumb:hover {
        background: #1e3d59;
        cursor: pointer;
    }
    .snci-desempenho-assunto .carousel-container::-webkit-scrollbar-track {
        background: #e2e8f0;
        border-radius: 6px;
        cursor: pointer;
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
        right: 70px;
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
        border: 1px solid #e2e8f0;
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
        min-height: 200px;
        margin-bottom: 10px;
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
        margin-bottom: 0px;
    }

    /* Nova seção de comparação moderna */
    .snci-desempenho-assunto .comparison-section {
        background: transparent;
    }

    .snci-desempenho-assunto .comparison-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
        margin-bottom: 16px;
    }

    .snci-desempenho-assunto .period-card {
        background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
        border-radius: 10px;
        padding: 12px;
        text-align: center;
        border: 2px solid transparent;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;
    }

    .snci-desempenho-assunto .period-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        transition: all 0.3s ease;
    }

    .snci-desempenho-assunto .period-card.current::before {
        background: linear-gradient(90deg, #457b9d, #1e3d59);
    }

    .snci-desempenho-assunto .period-card.previous::before {
        background: linear-gradient(90deg, #a8dadc, #7fb3d3);
    }

    .snci-desempenho-assunto .period-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(69, 123, 157, 0.15);
        border-color: rgba(69, 123, 157, 0.2);
    }

    .snci-desempenho-assunto .period-label {
        font-size: 0.7rem;
        font-weight: 600;
        color: #64748b;
        margin-bottom: 4px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .snci-desempenho-assunto .period-value {
        font-size: 1.8rem;
        font-weight: 700;
        color: #1e293b;
        line-height: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
    }

    .snci-desempenho-assunto .period-card.current .period-value {
        color: #457b9d;
    }

    .snci-desempenho-assunto .period-card.previous .period-value {
        color: #7fb3d3;
    }

    .snci-desempenho-assunto .value-icon {
        font-size: 1.2rem;
        opacity: 0.7;
    }

    /* Indicador de tendência aprimorado */
    .snci-desempenho-assunto .trend-indicator {
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 10px;
        font-size: 0.8rem;
        font-weight: 600;
        background: rgba(255,255,255,0.6);
        border: 2px solid transparent;
        transition: all 0.3s ease;
    }

    .snci-desempenho-assunto .trend-indicator:hover {
        transform: scale(1.02);
    }

    .snci-desempenho-assunto .trend-icon {
        font-size: 1.1rem;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        background: rgba(255,255,255,0.8);
    }

    /* Vermelho adobe para aumento */
    .snci-desempenho-assunto .trend-indicator.increase {
        color: #e63946;
        border-color: rgba(230, 57, 70, 0.2);
        background: rgba(254, 226, 226, 0.4);
    }

    /* Verde para redução */
    .snci-desempenho-assunto .trend-indicator.decrease {
        color: #059669;
        border-color: rgba(5, 150, 105, 0.2);
        background: rgba(209, 250, 229, 0.4);
    }

    .snci-desempenho-assunto .trend-indicator.stable {
        color: #6b7280;
        border-color: rgba(107, 114, 128, 0.2);
        background: rgba(243, 244, 246, 0.4);
    }

    .snci-desempenho-assunto .trend-text {
        display: flex;
        align-items: center;
        gap: 4px;
    }

    .snci-desempenho-assunto .trend-percentage {
        font-size: 0.9rem;
        font-weight: 700;
    }

    .snci-desempenho-assunto .trend-label {
        font-size: 0.7rem;
        opacity: 0.8;
        text-transform: lowercase;
    }

    .performance-card.empty-card::before {
        display: none !important;
        content: none !important;
    }

    /* Background vermelho discreto para cards com valor atual > 0 */
    .snci-desempenho-assunto .performance-card.has-current-value {
        background: linear-gradient(135deg, rgba(220, 38, 38, 0.15) 0%, rgba(248, 113, 113, 0.08) 100%);
        border-color: rgba(220, 38, 38, 0.25);
    }

    .snci-desempenho-assunto .performance-card.has-current-value:hover {
        background: linear-gradient(135deg, rgba(220, 38, 38, 0.2) 0%, rgba(248, 113, 113, 0.12) 100%);
        border-color: rgba(220, 38, 38, 0.35);
    }

    /* Ajustar borda superior dos cards com valor atual */
    .snci-desempenho-assunto .performance-card.has-current-value::before {
        background: linear-gradient(90deg, #dc2626, #ef4444);
    }

    /* Ajustar cores dos period-cards internos para melhor contraste */
    .snci-desempenho-assunto .performance-card.has-current-value .period-card {
        background: rgba(255, 255, 255, 0.85);
        border: 1px solid rgba(220, 38, 38, 0.1);
    }

    .snci-desempenho-assunto .performance-card.has-current-value .period-card:hover {
        background: rgba(255, 255, 255, 0.95);
        border-color: rgba(220, 38, 38, 0.2);
    }

    /* Ajustar indicador de tendência para melhor contraste */
    .snci-desempenho-assunto .performance-card.has-current-value .trend-indicator {
        background: rgba(255, 255, 255, 0.8);
        border-color: rgba(220, 38, 38, 0.15);
    }

    /* Background verde para cards com redução (decrease) */
    .snci-desempenho-assunto .performance-card.has-reduction {
        background: linear-gradient(135deg, rgba(5, 150, 105, 0.15) 0%, rgba(34, 197, 94, 0.08) 100%);
        border-color: rgba(5, 150, 105, 0.25);
    }

    .snci-desempenho-assunto .performance-card.has-reduction:hover {
        background: linear-gradient(135deg, rgba(5, 150, 105, 0.2) 0%, rgba(34, 197, 94, 0.12) 100%);
        border-color: rgba(5, 150, 105, 0.35);
    }

    /* Ajustar borda superior dos cards com redução */
    .snci-desempenho-assunto .performance-card.has-reduction::before {
        background: linear-gradient(90deg, #059669, #22c55e);
    }

    /* Ajustar cores dos period-cards internos para melhor contraste */
    .snci-desempenho-assunto .performance-card.has-reduction .period-card {
        background: rgba(255, 255, 255, 0.85);
        border: 1px solid rgba(5, 150, 105, 0.1);
    }

    .snci-desempenho-assunto .performance-card.has-reduction .period-card:hover {
        background: rgba(255, 255, 255, 0.95);
        border-color: rgba(5, 150, 105, 0.2);
    }

    /* Ajustar indicador de tendência para cards com redução */
    .snci-desempenho-assunto .performance-card.has-reduction .trend-indicator {
        background: rgba(255, 255, 255, 0.8);
        border-color: rgba(5, 150, 105, 0.15);
    }

    /* Estilo para o container dos eventos com posicionamento relativo */
    .snci-desempenho-assunto .eventos-container {
        position: relative;
        font-size: 0.7rem; 
        color: #64748b; 
        text-align: center;
        margin-top: -4px; /* Move a div "eventos" um pouco mais para cima */
    }

    /* Estilo para centralizar o badge reincidente */
    .snci-desempenho-assunto .badge-reincidente {
        position: relative;
        font-size: 0.65rem;
        color: #dc3545;
        font-weight: 700;
        z-index: 5;
        white-space: nowrap;
    }

    /* Estilo para o valor envolvido */
    .valor-envolvido {
        display: block;
        font-size: 0.6rem;
        color: #6b7280;
        font-weight: 600;
        text-align: center;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 4px;
        border: 1px solid #e5e7eb;
        box-shadow: 0 1px 2px rgba(0,0,0,0.1);
    }


</style>

<div class="snci-desempenho-assunto">
    <div class="desempenho-container" style="position:relative;">
        <div class="container-header">
            <h2>Desempenho por Assunto 
             <i class=" info-icon-automatizadas" style="position: relative;bottom: 12px;" 
                data-toggle="popover" 
                data-trigger="hover" 
                data-placement="right"
                data-html="false"
                data-content="Agrupamento realizado de acordo com a temática do teste. Ex.: Financeiro, Abastecimento, Carga Postal...">
            </i>
            <span class="subtitle"><cfoutput>(#nomeMesAtual# x #nomeMesAnterior#)</cfoutput></span></h2>
        </div>
        <!-- Botões alinhados horizontalmente, ambos fora do container rolável -->
        <div style="position: relative;">
            <div class="carousel-controls carousel-prev" style="position: absolute; left: 0!important; top: 50%; transform: translateY(-50%); z-index: 10;">
                <i class="fas fa-chevron-left"></i>
            </div>
            <div class="carousel-controls carousel-next" style="position: absolute; right:0!important; top: 50%; transform: translateY(-50%); z-index: 10;">
                <i class="fas fa-chevron-right"></i>
            </div>
            <div class="carousel-container" id="carouselScrollContainer" style="overflow-x:auto;">
                <div class="carousel-track" id="carouselTrack">
                    <cfloop array="#dadosOrdenados#" index="item">
                        <div class="performance-card<cfif item.atual GT 0> has-current-value<cfelseif item.tipo eq 'decrease'> has-reduction</cfif>">
                            <div class="card-header">
                                <h3 class="card-title"><cfoutput>#trim(item.titulo)#</cfoutput>
                                    <i class=" info-icon-automatizadas" 
                                        data-toggle="popover" 
                                        data-trigger="hover" 
                                        data-placement="right"
                                        data-html="false"
                                        data-content=
                                        "<cfoutput>
                                            <strong>Descrição:</strong> #HTMLEditFormat(item.descricao)#<br>
                                            <strong>Fonte de dados:</strong> #HTMLEditFormat(item.fonte_dados)#<br>
                                            <strong>Critério:</strong> #HTMLEditFormat(item.criterio)#
                                        </cfoutput>">
                                    </i>
                                </h3> 
                                  
                                
                                <p class="card-subtitle"><cfoutput>(#item.teste#)</cfoutput>
                                    <i class=" info-icon-automatizadas" 
                                        data-toggle="popover" 
                                        data-trigger="hover" 
                                        data-placement="right"
                                        data-html="false"
                                        data-content="<strong>Grupo-Item:</strong> numeração atribuída a cada teste de controle interno.">
                                    </i>
                                </p>
                            </div>

                            <div class="comparison-section">
                                <!-- Grid de comparação lado a lado -->
                                <div class="comparison-grid">
                                    <div class="period-card current">
                                        <div class="period-label"><cfoutput>#abreviarMes(nomeMesAtual)#</cfoutput></div>
                                        <div class="period-value">
                                            <cfoutput>#item.atual#</cfoutput>
                                        </div>
                                        
                                        <div class="eventos-container">
                                            eventos 
                                            <cfif item.atual GT 0>
                                                (<cfoutput>#item.percentualAtual#%</cfoutput>)
                                            </cfif>
                                            <cfif item.reincidencia && item.atual GT 0>
                                                <span class="badge-reincidente">Reincidente</span>
                                            </cfif>
                                        </div>
                                        <cfif item.valorEnvolvido GT 0>
                                            <div class="valor-envolvido">Valor Envolvido:<br>R$ <span class="valor-formatada" data-valor="<cfoutput>#item.valorEnvolvido#</cfoutput>">0,00</span></div>
                                        </cfif>
                                    </div>
                                    <div class="period-card previous">
                                        <div class="period-label"><cfoutput>#abreviarMes(nomeMesAnterior)#</cfoutput></div>
                                        <div class="period-value">
                                            
                                            <cfif isJaneiro>
                                                <span style="color:#64748b; font-size:1.2rem;">sem dados</span>
                                            <cfelse>
                                                <cfoutput>#item.anterior#</cfoutput>
                                            </cfif>
                                        </div>
                                        <cfif NOT isJaneiro>
                                            <div class="eventos-container">eventos <cfif item.anterior GT 0>(<cfoutput>#item.percentualAnterior#%</cfoutput>)</cfif></div>
                                        </cfif>
                                        <cfif NOT isJaneiro AND structKeyExists(item, "valorEnvolvidoAnterior") AND item.valorEnvolvidoAnterior GT 0>
                                            <div class="valor-envolvido">Valor Envolvido:<br>R$ <span class="valor-formatada" data-valor="<cfoutput>#item.valorEnvolvidoAnterior#</cfoutput>">0,00</span></div>
                                        </cfif>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </cfloop>
                    <div class="performance-card empty-card" style="background:transparent; border:none; box-shadow:none; pointer-events:none;"></div>
                </div>
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

        // Animar gráficos de comparação
        setTimeout(function() {
            $('.animated-chart').each(function(){
                var height = $(this).data('height');
                $(this).css('height', height);
                $(this).addClass('visible');
            });
        }, 500);

        // Configuração do carrossel
        const track = $('#carouselTrack');
        const cards = track.find('.performance-card');
        const prevBtn = $('.carousel-prev');
        const nextBtn = $('.carousel-next');
        const indicators = $('#carouselIndicators');
        
        let currentSlide = 0;
        let itemsToShow = getItemsToShow();
        let totalSlides = Math.max(0, cards.length - itemsToShow + 1);

        // Variáveis para drag
        let isDragging = false;
        let startPos = 0;
        let currentTranslate = 0;
        let prevTranslate = 0;
        let animationId = 0;

        // Função para calcular quantos itens mostrar
        function getItemsToShow() {
            const containerWidth = $('.carousel-container').width() - 120;
            const singleCardWidth = $('.performance-card').first().outerWidth(true);
            
            if (singleCardWidth === 0) return 1;
            
            const itemsPossible = Math.floor(containerWidth / singleCardWidth);
            return Math.max(1, itemsPossible);
        }

        // Função para calcular largura exata de um card
        function getCardWidth() {
            return $('.performance-card').first().outerWidth(true) || 274;
        }

        // Atualizar carrossel
        function updateCarousel() {
            const cardWidth = getCardWidth();
            const translateX = -currentSlide * cardWidth;
            
            track.css('transform', `translateX(${translateX}px)`);
            
            // Atualizar controles
            prevBtn.toggleClass('disabled', currentSlide === 0);
            nextBtn.toggleClass('disabled', currentSlide >= totalSlides - 1);
            
            // Atualizar indicadores
            updateIndicators();
        }

        // Criar indicadores
        function createIndicators() {
            indicators.empty();
            
            if (totalSlides <= 1) return;
            
            const totalPages = Math.ceil(totalSlides / itemsToShow);
            
            for (let i = 0; i < totalPages; i++) {
                const dot = $('<div class="indicator-dot"></div>');
                if (i === 0) dot.addClass('active');
                
                dot.click(function() {
                    currentSlide = i * itemsToShow;
                    currentSlide = Math.min(currentSlide, totalSlides - 1);
                    updateCarousel();
                });
                
                indicators.append(dot);
            }
        }

        // Atualizar indicadores
        function updateIndicators() {
            const currentPage = Math.floor(currentSlide / itemsToShow);
            indicators.find('.indicator-dot').removeClass('active').eq(currentPage).addClass('active');
        }

        // Navegação próximo item
        function slideNext() {
            if (currentSlide < totalSlides - 1) {
                currentSlide++;
                updateCarousel();
            }
        }

        // Navegação item anterior
        function slidePrev() {
            if (currentSlide > 0) {
                currentSlide--;
                updateCarousel();
            }
        }

        // Redimensionar
        function handleResize() {
            const newItemsToShow = getItemsToShow();
            
            if (newItemsToShow !== itemsToShow) {
                itemsToShow = newItemsToShow;
                totalSlides = Math.max(0, cards.length - itemsToShow + 1);
                
                currentSlide = Math.min(currentSlide, totalSlides - 1);
                currentSlide = Math.max(0, currentSlide);
                
                createIndicators();
                updateCarousel();
            }
        }

        // Função para obter posição X do evento
        function getPositionX(event) {
            return event.type.includes('mouse') ? event.clientX : event.touches[0].clientX;
        }

        // Função para definir posição do slider
        function setSliderPosition() {
            const cardWidth = getCardWidth();
            currentTranslate = currentSlide * -cardWidth;
            prevTranslate = currentTranslate;
            track.css('transform', `translateX(${currentTranslate}px)`);
        }

        // Função de animação durante o drag
        function animation() {
            track.css('transform', `translateX(${currentTranslate}px)`);
            if (isDragging) requestAnimationFrame(animation);
        }

        // Início do drag/touch
        function dragStart(event) {
            if (event.type === 'mousedown') {
                event.preventDefault();
            }
            
            isDragging = true;
            startPos = getPositionX(event);
            
            track.addClass('dragging');
            track.css('transition', 'none');
            
            animationId = requestAnimationFrame(animation);
        }

        // Movimento durante drag/touch
        function dragMove(event) {
            if (isDragging) {
                event.preventDefault();
                const currentPosition = getPositionX(event);
                currentTranslate = prevTranslate + currentPosition - startPos;
            }
        }

        // Fim do drag/touch
        function dragEnd() {
            isDragging = false;
            cancelAnimationFrame(animationId);
            
            track.removeClass('dragging');
            track.css('transition', 'transform 0.5s ease-in-out');
            
            const movedBy = currentTranslate - prevTranslate;
            const cardWidth = getCardWidth();
            
            // Se moveu mais que 100px, mudar slide
            if (movedBy < -100 && currentSlide < totalSlides - 1) {
                currentSlide++;
            }
            
            if (movedBy > 100 && currentSlide > 0) {
                currentSlide--;
            }
            
            setSliderPosition();
            updateIndicators();
            
            // Atualizar controles
            prevBtn.toggleClass('disabled', currentSlide === 0);
            nextBtn.toggleClass('disabled', currentSlide >= totalSlides - 1);
        }

        // Habilita barra de rolagem horizontal manual
        // E permite que os controles avancem/voltem via scroll
        const scrollContainer = document.getElementById('carouselScrollContainer');
        const cardWidth = () => $('.performance-card').first().outerWidth(true) || 274;

        $('.carousel-next').off('click').on('click', function() {
            scrollContainer.scrollBy({ left: cardWidth(), behavior: 'smooth' });
        });
        $('.carousel-prev').off('click').on('click', function() {
            scrollContainer.scrollBy({ left: -cardWidth(), behavior: 'smooth' });
        });
        
        // Formatar valores monetários em pt-BR
        $('.valor-formatada').each(function() {
            var $this = $(this);
            var valor = parseFloat($this.data('valor'));
            if (!isNaN(valor)) {
                $this.text(valor.toLocaleString('pt-BR', {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2
                }));
            }
        });
    });
</script>