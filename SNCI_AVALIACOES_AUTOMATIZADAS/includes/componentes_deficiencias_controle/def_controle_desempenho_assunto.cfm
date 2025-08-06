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

<!--- Obter lista de tabelas de evidências --->
<cftry>
    <cfif NOT isDefined("objEvidencias")>
        <cfset objEvidencias = createObject("component", "cfc.EvidenciasManager")>
    </cfif>
    <cfset tabelasEvidencias = objEvidencias.listarTabelasEvidencias()>
    
    <!--- Debug: mostrar resultado imediatamente --->
    <cflog file="evidencias_debug" text="Página principal: objEvidencias criado com sucesso">
    <cflog file="evidencias_debug" text="Página principal: tabelasEvidencias retornou #arrayLen(tabelasEvidencias)# tabelas">
    
    <!--- REMOVER a criação de tabelas fictícias - usar apenas as reais --->
    <cfloop from="1" to="#arrayLen(tabelasEvidencias)#" index="i">
        <cflog file="evidencias_debug" text="Tabela #i#: #tabelasEvidencias[i].nome# (código: #tabelasEvidencias[i].codigo#)">
    </cfloop>
    
    <cfcatch type="any">
        <cfset tabelasEvidencias = arrayNew(1)>
        <cflog file="evidencias_erro" text="Erro ao carregar tabelas de evidências: #cfcatch.message#">
        <cflog file="evidencias_debug" text="ERRO na página principal: #cfcatch.message#">
    </cfcatch>
</cftry>

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

<!--- Obter o maior mês disponível para verificar se é o atual --->
<cfset maiorMesDisponivel = "">
<cftry>
    <cfset objDadosMeses = createObject("component", "cfc.DeficienciasControleDados")>
    <cfset resultadoMeses = objDadosMeses.obterMesesDisponiveis()>
    
    <cfif resultadoMeses.success AND arrayLen(resultadoMeses.data) GT 0>
        <!--- O primeiro item do array já é o maior mês (mais recente) --->
        <cfset maiorMesDisponivel = resultadoMeses.data[1].id>
    </cfif>
    
    <cfcatch type="any">
        <cflog file="evidencias_erro" text="Erro ao obter maior mês disponível: #cfcatch.message#">
        <cfset maiorMesDisponivel = "">
    </cfcatch>
</cftry>

<!--- Verificar se o mês atual corresponde ao maior mês disponível --->
<cfset mesAtualEhMaiorDisponivel = (len(trim(maiorMesDisponivel)) GT 0 AND mesAtualId EQ maiorMesDisponivel)>

<!--- Debug da verificação --->
<cfoutput>
    <!-- DEBUG: maiorMesDisponivel = "#maiorMesDisponivel#" -->
    <!-- DEBUG: mesAtualId = "#mesAtualId#" -->
    <!-- DEBUG: mesAtualEhMaiorDisponivel = "#mesAtualEhMaiorDisponivel#" -->
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

    /* Estilo para cards clicáveis com evidências */
    .snci-desempenho-assunto .period-card.evidencias-clickable {
        cursor: pointer;
        transition: all 0.3s ease;
        position: relative;
    }

    .snci-desempenho-assunto .period-card.evidencias-clickable:hover {
        transform: translateY(-3px) scale(1.02);
        box-shadow: 0 8px 20px rgba(69, 123, 157, 0.25);
        border-color: rgba(69, 123, 157, 0.4);
    }

    .snci-desempenho-assunto .period-card.evidencias-clickable::after {
        content: '📊';
        position: absolute;
        top: 5px;
        right: 5px;
        font-size: 0.8rem;
        opacity: 0.6;
        transition: opacity 0.3s ease;
    }

    .snci-desempenho-assunto .period-card.evidencias-clickable:hover::after {
        opacity: 1;
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
                                    <!--- Debug: listar todas as tabelas disponíveis PRIMEIRO --->
                                    <cfoutput>
                                        <!-- TABELAS DISPONÍVEIS NO BANCO: -->
                                        <cfloop array="#tabelasEvidencias#" index="tab">
                                            <!-- Tabela: "#tab.nome#" | Código: "#tab.codigo#" -->
                                        </cfloop>
                                        <!-- FIM LISTA TABELAS -->
                                    </cfoutput>
                                    
                                    <!--- Buscar tabela de evidências correspondente usando o código do teste --->
                                    <cfset tabelaEvidencia = "">
                                    <cfset tituloEvidencia = "">
                                    
                                    <!--- Debug melhorado: mostrar todas as tentativas de match --->
                                    <cfoutput>
                                        <!-- DEBUG DETALHADO: -->
                                        <!-- item.chave = "#item.chave#" -->
                                        <!-- item.teste = "#item.teste#" -->
                                        <!-- arrayLen(tabelasEvidencias) = "#arrayLen(tabelasEvidencias)#" -->
                                    </cfoutput>
                                    
                                    <!--- Garantir que objEvidencias existe --->
                                    <cfif NOT isDefined("objEvidencias")>
                                        <cfset objEvidencias = createObject("component", "cfc.EvidenciasManager")>
                                    </cfif>
                                    
                                    <!--- Usar função do CFC para buscar tabela --->
                                    <cfif len(trim(item.teste))>
                                        <cfset tabelaEvidencia = objEvidencias.buscarTabelaPorCodigo(item.teste, tabelasEvidencias)>
                                        <cfif len(trim(tabelaEvidencia))>
                                            <cfset tituloEvidencia = item.titulo & " - Evidências (" & item.teste & ")">
                                        </cfif>
                                        <cfoutput>
                                            <!-- RESULTADO BUSCA POR TESTE "#item.teste#": "#tabelaEvidencia#" -->
                                        </cfoutput>
                                    </cfif>
                                    
                                    <!--- Fallback: buscar usando a chave se não encontrou pelo teste --->
                                    <cfif len(trim(tabelaEvidencia)) EQ 0 AND len(trim(item.chave))>
                                        <cfset tabelaEvidencia = objEvidencias.buscarTabelaPorCodigo(item.chave, tabelasEvidencias)>
                                        <cfif len(trim(tabelaEvidencia))>
                                            <cfset tituloEvidencia = item.titulo & " - Evidências (" & item.chave & ")">
                                        </cfif>
                                        <cfoutput>
                                            <!-- RESULTADO BUSCA POR CHAVE "#item.chave#": "#tabelaEvidencia#" -->
                                        </cfoutput>
                                    </cfif>
                                    
                                    <!--- Debug: resultado final --->
                                    <cfoutput>
                                        <!-- RESULTADO FINAL: tabelaEvidencia = "#tabelaEvidencia#" -->
                                        <!-- len(trim(tabelaEvidencia)) = "#len(trim(tabelaEvidencia))#" -->
                                        <!-- Será clicável: #(len(trim(tabelaEvidencia)) GT 0 ? "SIM" : "NÃO")# -->
                                    </cfoutput>
                                    
                                    <div class="period-card current<cfif len(trim(tabelaEvidencia)) AND item.atual GT 0 AND mesAtualEhMaiorDisponivel> evidencias-clickable</cfif>" 
                                         <cfif len(trim(tabelaEvidencia)) AND item.atual GT 0 AND mesAtualEhMaiorDisponivel>
                                         data-tabela="<cfoutput>#HTMLEditFormat(tabelaEvidencia)#</cfoutput>" 
                                         data-titulo="<cfoutput>#HTMLEditFormat(tituloEvidencia)#</cfoutput>"
                                         title="Clique para ver evidências - <cfoutput>#HTMLEditFormat(tabelaEvidencia)#</cfoutput>"
                                         <cfelse>
                                         <cfif len(trim(tabelaEvidencia)) AND item.atual GT 0 AND NOT mesAtualEhMaiorDisponivel>
                                         title="Evidências disponíveis apenas para o período mais recente"
                                         </cfif>
                                         </cfif>>
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

        // Inicializar popovers
        $('[data-toggle="popover"]').popover();

        // Função para abrir modal de evidências com DataTables real
        window.abrirModalEvidencias = function(nomeTabela, titulo) {
            console.log('abrirModalEvidencias chamada:', nomeTabela, titulo);
            
            if (!nomeTabela) {
                console.error('Nome da tabela não informado');
                return;
            }
            
            // Verificar se o modal existe
            if ($('#modalEvidencias').length === 0) {
                alert('Modal de evidências não encontrado. Verifique se o modal_evidencias.cfm foi incluído.');
                return;
            }
            
            // Atualizar título do modal
            $('#modalEvidenciasLabel').html('<i class="fas fa-table mr-2"></i>' + (titulo || 'Evidências'));
            
            // Mostrar loading
            $('#evidenciasLoading').show();
            $('#evidenciasContent').hide();
            $('#evidenciasError').hide();
            
            // Abrir modal
            $('#modalEvidencias').modal('show');
            
            // Carregar dados reais via DataTables
            carregarEvidenciasDataTable(nomeTabela, titulo);
        };

        // Função para carregar evidências com DataTables
        function carregarEvidenciasDataTable(nomeTabela, titulo) {
            console.log('Iniciando carregamento de evidências para:', nomeTabela);
            
            // Verificar e destruir DataTable existente de forma mais robusta
            if ($.fn.DataTable.isDataTable('#tabelaEvidencias')) {
                console.log('Destruindo DataTable existente...');
                try {
                    $('#tabelaEvidencias').DataTable().clear();
                    $('#tabelaEvidencias').DataTable().destroy(true);
                } catch (e) {
                    console.warn('Erro ao destruir DataTable:', e);
                }
            }
            
            // Remover completamente a instância do DOM
            $('#tabelaEvidencias').remove();
            
            // Recriar elemento da tabela do zero
            const novaTabela = '<table id="tabelaEvidencias" class="table table-striped table-bordered table-hover compact nowrap" style="width: 100%;"></table>';
            $('.table-container').html(novaTabela);
            
            try {
                // Obter estrutura da tabela para configurar DataTables
                $.ajax({
                    url: 'cfc/EvidenciasManager.cfc?method=obterEstruturasTabela&returnformat=json',
                    type: 'GET',
                    data: { 
                        nomeTabela: nomeTabela
                    },
                    dataType: 'json',
                    timeout: 30000,
                    success: function(response) {
                        console.log('Estrutura da tabela recebida:', response);
                        if (response && response.length > 0) {
                            inicializarDataTable(nomeTabela, response, titulo);
                        } else {
                            mostrarErroEvidencias('Nenhuma coluna encontrada para esta tabela.');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Erro ao obter estrutura:', error);
                        console.error('Status:', status);
                        console.error('Response:', xhr.responseText);
                        mostrarErroEvidencias('Erro ao carregar estrutura da tabela: ' + error);
                    }
                });
                
            } catch (error) {
                console.error('Erro ao carregar evidências:', error);
                mostrarErroEvidencias('Erro ao inicializar: ' + error.message);
            }
        }
        
        // Função para inicializar DataTable
        function inicializarDataTable(nomeTabela, colunas, titulo) {
            console.log('Inicializando DataTable para:', nomeTabela, 'com', colunas.length, 'colunas');
            
            // Verificar se o elemento existe
            if ($('#tabelaEvidencias').length === 0) {
                console.error('Elemento tabelaEvidencias não encontrado');
                mostrarErroEvidencias('Erro: Elemento da tabela não encontrado');
                return;
            }
            
            try {
                // Criar estrutura HTML da tabela antes de inicializar DataTables
                let tableHTML = '<thead class="thead-dark"><tr>';
                colunas.forEach(function(coluna) {
                    tableHTML += '<th>' + coluna.nome + '</th>';
                });
                tableHTML += '</tr></thead><tbody></tbody>';
                
                // Inserir HTML na tabela
                $('#tabelaEvidencias').html(tableHTML);
                
                // Aguardar um pouco para garantir que o DOM foi atualizado
                setTimeout(function() {
                    criarDataTableInstance(nomeTabela, colunas, titulo);
                }, 100);
                
            } catch (error) {
                console.error('Erro ao criar estrutura da tabela:', error);
                mostrarErroEvidencias('Erro ao criar estrutura da tabela: ' + error.message);
            }
        }
        
        // Função separada para criar a instância do DataTable
        function criarDataTableInstance(nomeTabela, colunas, titulo) {
            try {
                // Configurar colunas para DataTables com larguras mais flexíveis
                const columnDefs = colunas.map(function(coluna, index) {
                    let config = {
                        targets: index,
                        className: 'text-center'
                        // Remover width fixo para permitir largura automática
                    };
                    
                    // Configurações específicas por tipo de dados sem larguras fixas
                    if (coluna.tipo === 'datetime' || coluna.tipo === 'date') {
                        config.className = 'text-center';
                        config.minWidth = '140px'; /* Usar minWidth ao invés de width */
                    } else if (coluna.tipo === 'money' || coluna.tipo === 'decimal' || coluna.tipo === 'numeric') {
                        config.className = 'text-right';
                        config.minWidth = '100px';
                    } else if (coluna.tipo === 'bit') {
                        config.className = 'text-center';
                        config.minWidth = '60px';
                    } else if (coluna.tipo === 'int' || coluna.tipo === 'bigint') {
                        config.className = 'text-center';
                        config.minWidth = '80px';
                    } else if (coluna.tipo === 'varchar' || coluna.tipo === 'nvarchar') {
                        config.className = 'text-left';
                        config.minWidth = coluna.tamanho > 100 ? '200px' : '120px';
                    } else {
                        config.className = 'text-left';
                        config.minWidth = '120px';
                    }
                    
                    return config;
                });
                
                // Configurar colunas com dados corretos
                const columns = colunas.map(function(coluna, index) {
                    return { 
                        data: index,
                        name: coluna.nome,
                        title: coluna.nome,
                        searchable: true,
                        orderable: true
                    };
                });
                
                console.log('Criando instância do DataTable...');
                
                // Inicializar DataTable com configurações otimizadas
                const dataTable = $('#tabelaEvidencias').DataTable({
                    processing: true,
                    serverSide: true,
                    destroy: true,
                    ajax: {
                        url: 'cfc/EvidenciasManager.cfc?method=obterDadosTabela&returnformat=json',
                        type: 'GET',
                        timeout: 30000,
                        data: function(d) {
                            return {
                                nomeTabela: nomeTabela,
                                start: d.start,
                                length: d.length,
                                searchValue: d.search.value,
                                orderColumn: d.order[0].column,
                                orderDirection: d.order[0].dir,
                                draw: d.draw
                            };
                        },
                        dataSrc: function(json) {
                            console.log('Dados recebidos do servidor:', json);
                            if (json.error) {
                                mostrarErroEvidencias(json.error);
                                return [];
                            }
                            // Verificar se os dados estão no formato correto
                            if (json.data && Array.isArray(json.data)) {
                                console.log('Total de registros:', json.recordsTotal);
                                console.log('Primeira linha de dados:', json.data[0]);
                                return json.data;
                            }
                            return [];
                        },
                        error: function(xhr, error, thrown) {
                            console.error('Erro AJAX completo:', {
                                error: error,
                                thrown: thrown,
                                status: xhr.status,
                                statusText: xhr.statusText,
                                responseText: xhr.responseText
                            });
                            mostrarErroEvidencias('Erro ao carregar dados: ' + error);
                        }
                    },
                    columns: columns,
                    columnDefs: columnDefs,
                    
                    // Configurações de layout e responsividade
                    dom: '<"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6"f>>' +
                         '<"row"<"col-sm-12"tr>>' +
                         '<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>',
                    
                    // Habilitar rolagem horizontal e vertical
                    scrollX: true,
                    scrollY: '50vh',
                    scrollCollapse: true,
                    
                    // Habilitar autoWidth para permitir larguras automáticas
                    autoWidth: true, /* Mudado para true */
                    
                    // Configurações de exibição
                    pageLength: 25,
                    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "Todos"]],
                    
                    // Classes CSS para estilo compacto sem nowrap excessivo
                    className: 'compact',
                    
                    // Configurar ordenação padrão
                    order: [[0, 'asc']],
                    
                    // Configurar busca
                    search: {
                        smart: true,
                        regex: false,
                        caseInsensitive: true
                    },
                    
                    // Idioma em português
                    language: {
                        "decimal": "",
                        "emptyTable": "Nenhum dado disponível na tabela",
                        "info": "Mostrando _START_ a _END_ de _TOTAL_ entradas",
                        "infoEmpty": "Mostrando 0 a 0 de 0 entradas",
                        "infoFiltered": "(filtrado de _MAX_ entradas totais)",
                        "infoPostFix": "",
                        "thousands": ".",
                        "lengthMenu": "Mostrar _MENU_ entradas",
                        "loadingRecords": "Carregando...",
                        "processing": "Processando...",
                        "search": "Buscar:",
                        "zeroRecords": "Nenhum registro correspondente encontrado",
                        "paginate": {
                            "first": "Primeiro",
                            "last": "Último",
                            "next": "Próximo",
                            "previous": "Anterior"
                        },
                        "aria": {
                            "sortAscending": ": ativar para classificar a coluna em ordem crescente",
                            "sortDescending": ": ativar para classificar a coluna em ordem decrescente"
                        }
                    },
                    
                    // Callbacks
                    drawCallback: function(settings) {
                        // Esconder loading e mostrar conteúdo quando dados carregarem
                        $('#evidenciasLoading').hide();
                        $('#evidenciasContent').show();
                        
                        // Atualizar informações no footer com verificações de segurança
                        try {
                            const api = this.api();
                            const info = api.page.info();
                            
                            // Verificar se info existe e tem as propriedades necessárias
                            if (info && typeof info.recordsTotal !== 'undefined' && typeof info.recordsFiltered !== 'undefined') {
                                $('#evidenciasInfo').html(
                                    `<strong>Tabela:</strong> ${nomeTabela} | ` +
                                    `<strong>Registros:</strong> ${info.recordsTotal.toLocaleString('pt-BR')} | ` +
                                    `<strong>Colunas:</strong> ${colunas.length} | ` +
                                    `<strong>Filtrados:</strong> ${info.recordsFiltered.toLocaleString('pt-BR')}`
                                );
                            } else {
                                $('#evidenciasInfo').html(
                                    `<strong>Tabela:</strong> ${nomeTabela} | ` +
                                    `<strong>Colunas:</strong> ${colunas.length} | ` +
                                    `<strong>Status:</strong> Carregando...`
                                );
                            }
                        } catch (error) {
                            console.error('Erro no drawCallback:', error);
                            $('#evidenciasInfo').html(
                                `<strong>Tabela:</strong> ${nomeTabela} | ` +
                                `<strong>Colunas:</strong> ${colunas.length}`
                            );
                        }
                    },
                    
                    initComplete: function(settings, json) {
                        console.log('DataTable inicializado com sucesso');
                        if (json && json.error) {
                            mostrarErroEvidencias(json.error);
                        } else {
                            // Forçar ajuste de colunas e habilitar rolagem horizontal
                            setTimeout(() => {
                                this.api().columns.adjust();
                                // Garantir que o scrollX está funcionando
                                $('.dataTables_scrollBody').css('overflow-x', 'auto');
                            }, 200);
                        }
                    }
                });
                
                // Adicionar evento de redimensionamento
                $(window).off('resize.evidencias').on('resize.evidencias', function() {
                    if (dataTable && typeof dataTable.columns !== 'undefined') {
                        dataTable.columns.adjust();
                    }
                });
                
            } catch (error) {
                console.error('Erro ao inicializar DataTable:', error);
                mostrarErroEvidencias('Erro ao inicializar tabela: ' + error.message);
            }
        }

        // Função para mostrar erro
        function mostrarErroEvidencias(mensagem) {
            $('#evidenciasLoading').hide();
            $('#evidenciasContent').hide();
            $('#evidenciasErrorMessage').text(mensagem);
            $('#evidenciasError').show();
        }

        // Event listener para period-cards clicáveis (ÚNICO - remover duplicação)
        $(document).off('click', '.period-card.evidencias-clickable').on('click', '.period-card.evidencias-clickable', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            console.log('Card clicado!'); // Debug
            
            const nomeTabela = $(this).data('tabela');
            const titulo = $(this).data('titulo');
            
            console.log('Tabela:', nomeTabela, 'Título:', titulo); // Debug
            
            if (nomeTabela) {
                // Chamar a função global
                if (typeof window.abrirModalEvidencias === 'function') {
                    window.abrirModalEvidencias(nomeTabela, titulo);
                } else {
                    console.error('Função abrirModalEvidencias não encontrada');
                    alert('Erro: Função abrirModalEvidencias não está disponível');
                }
            } else {
                console.log('Nome da tabela não encontrado');
                alert('Erro: Nome da tabela não foi encontrado nos dados do card');
            }
        });

        // Event listener de debug para TODOS os cards current
        $(document).on('click', '.period-card.current', function(e) {
            console.log('=== DEBUG CARD CLICK ===');
            console.log('Card current clicado');
            console.log('Tem classe evidencias-clickable:', $(this).hasClass('evidencias-clickable'));
            console.log('Classes do elemento:', $(this).attr('class'));
            console.log('Data tabela:', $(this).data('tabela'));
            console.log('Data título:', $(this).data('titulo'));
            console.log('HTML do card:', $(this).prop('outerHTML').substring(0, 200) + '...');
            console.log('========================');
        });

        // Limpar modal quando fechar - versão mais robusta
        $('#modalEvidencias').on('hidden.bs.modal', function() {
            console.log('Modal fechado - limpando DataTable');
            
            // Remover event listeners
            $(window).off('resize.evidencias');
            
            // Destruir DataTable de forma mais completa
            if ($.fn.DataTable.isDataTable('#tabelaEvidencias')) {
                try {
                    $('#tabelaEvidencias').DataTable().clear();
                    $('#tabelaEvidencias').DataTable().destroy(true);
                } catch (e) {
                    console.warn('Erro ao destruir DataTable no fechamento:', e);
                }
            }
            
            // Limpar completamente o container
            $('#tabelaEvidencias').remove();
            $('.table-container').html('<table id="tabelaEvidencias" class="table table-striped table-bordered table-hover compact nowrap" style="width: 100%;"></table>');
            $('#evidenciasInfo').empty();
            
            // Reset do estado do modal
            $('#evidenciasLoading').show();
            $('#evidenciasContent').hide();
            $('#evidenciasError').hide();
        });

        // Debug: verificar se existem cards clicáveis ao carregar a página
        setTimeout(function() {
            const cardsClicaveis = $('.period-card.evidencias-clickable');
            const cardsTotal = $('.period-card.current');
            console.log('=== DEBUG INICIAL ===');
            console.log('Total de cards current:', cardsTotal.length);
            console.log('Total de cards clicáveis encontrados:', cardsClicaveis.length);
            
            // Verificar se as tabelas de evidências foram carregadas
            console.log('Verificando se objEvidencias existe:', typeof objEvidencias !== 'undefined');
            
            // Mostrar informações de cada card
            cardsTotal.each(function(index) {
                const $card = $(this);
                console.log('Card ' + (index + 1) + ':', {
                    tabela: $card.data('tabela'),
                    titulo: $card.data('titulo'),
                    classes: $card.attr('class'),
                    temDados: $card.closest('.performance-card').find('.period-value').text().trim() !== '0'
                });
            });
            
            console.log('====================');
        }, 2000);
    });
</script>

<!--- Incluir modal primeiro --->
<cfinclude template="../modal_evidencias.cfm">